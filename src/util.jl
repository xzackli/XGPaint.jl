using HDF5
using Healpix
using Random
using Random: MersenneTwister
using Future: randjump

"""
Utility function to read an HDF5 table with x, y, z, M_h as the four rows.
The hdf5 record is "halos".
"""
function read_halo_catalog_hdf5(filename)
    hdata = h5open(filename, "r") do file
        read(file, "halos")
    end
    pos = hdata[1:3,:]
    halo_mass = hdata[4,:]
    return pos, halo_mass
end

"""
Generate an array of random number generators, for each thread.

From KissThreading.jl, which doesn't look like a very stable package.
"""
function trandjump(rng = MersenneTwister(0); jump=big(10)^20)
    n = Threads.nthreads()
    rngjmp = Vector{MersenneTwister}(undef, n)
    for i in 1:n
        rngjmp[i] = randjump(rng, jump*i)
    end
    rngjmp
end

"""
Generates a list of tuples which describe starting and ending chunk indices.
Useful for parallelizing an array operation.
"""
function chunk(arr_len, chunksize)
    return [(i, min(i + chunksize-1, arr_len))
        for i in range(1, arr_len, step=chunksize)]
end


function threaded_rand!(random_number_generators, arr::Array{T,1};
      chunksize=4096) where T

   num = size(arr,1)
   Threads.@threads for (i1, i2) in chunk(num, chunksize)
      @views rand!(random_number_generators[Threads.threadid()], arr[i1:i2])
   end
end

"""
Generate an array where the value at index i corresponds to the index of the
first source of halo i. Takes an array where the value at index i corresponds
to the number of subhalos that halo i has.
"""
function generate_subhalo_offsets(num_subhalos)
    result = cumsum(num_subhalos)
    prepend!(result, 0)
    return result
end


"""
Fill in basic halo properties.
"""
function get_basic_halo_properties(halo_pos::Array{T,2}, model::AbstractForegroundModel,
                                   cosmo::Cosmology.FlatLCDM{T}, res::Resolution) where T
    N_halos = size(halo_pos, 2)
    hp_ind = Array{Int64}(undef, N_halos)  # healpix index of halo
    redshift = Array{T}(undef, N_halos)
    dist = Array{T}(undef, N_halos)
    r2z = XGPaint.build_r2z_interpolator(
        model.min_redshift, model.max_redshift, cosmo)
    Threads.@threads for i in 1:N_halos
        dist[i] = sqrt(halo_pos[1,i]^2 + halo_pos[2,i]^2 + halo_pos[3,i]^2)
        redshift[i] = r2z(dist[i])
        hp_ind[i] = Healpix.vec2pixRing(res,
            halo_pos[1,i], halo_pos[2,i], halo_pos[3,i])
    end

    return dist, redshift, hp_ind
end

"""
Utility function which prepends some zeros to an array. It makes a copy instead
of modifying the input.
"""
function ellpad(arr::Array{T,N}; nzeros=1) where {T,N}
    result = arr[:]
    pushfirst!(result, zeros(T, nzeros)...)
    return result
end

export read_halo_catalog_hdf5, chunk, generate_subhalo_offsets, trandjump