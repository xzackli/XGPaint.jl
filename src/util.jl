using HDF5
using Healpix
using Random
using Random: MersenneTwister

"""
    read_halo_catalog_hdf5(filename)

Utility function to read an HDF5 table with x, y, z, M_h as the four rows.
The hdf5 record is "halos". This is a format we use to distribute Websky halos.

## Example
```julia-repl
julia> halo_pos, halo_mass = read_halo_catalog_hdf5(
    "/global/cfs/cdirs/sobs/www/users/Radio_WebSky/websky_halos-light.hdf5")
```
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
    chunk(arr_len, chunksize::Integer)

Generates a list of tuples which describe starting and ending chunk indices.
Useful for parallelizing an array operation.
"""
function chunk(arr_len, chunksize::Integer)
    return [(i, min(i + chunksize-1, arr_len))
        for i in range(1, arr_len, step=chunksize)]
end


function getrange(n)
    tid = Threads.threadid()
    nt = Threads.nthreads()
    d , r = divrem(n, nt)
    from = (tid - 1) * d + min(r, tid - 1) + 1
    to = from + d - 1 + (tid ≤ r ? 1 : 0)
    from:to
end


function threaded_rand!(arr::Array{T,1};
      chunksize=4096) where T

   num = size(arr,1)
   Threads.@threads for (i1, i2) in chunk(num, chunksize)
      @views rand!(arr[i1:i2])
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
    get_basic_halo_properties(halo_pos::Array{T,2}, model::AbstractForegroundModel,
                              cosmo::Cosmology.FlatLCDM{T}, res::Resolution) where T

Compute distance, redshift, and healpix indices from halo positions and a cosmology.
"""
function get_basic_halo_properties(halo_pos::Array{T,2}, model::AbstractForegroundModel,
                                   cosmo::Cosmology.FlatLCDM{T}, res::Resolution) where T
    N_halos = size(halo_pos, 2)
    hp_ind = Array{Int64}(undef, N_halos)  # healpix index of halo
    redshift = Array{T}(undef, N_halos)
    dist = Array{T}(undef, N_halos)

    r2z = build_r2z_interpolator(
        model.min_redshift, model.max_redshift, cosmo)
    Threads.@threads for i in 1:N_halos
        dist[i] = sqrt(halo_pos[1,i]^2 + halo_pos[2,i]^2 + halo_pos[3,i]^2)
        redshift[i] = r2z(dist[i])
        hp_ind[i] = Healpix.vec2pixRing(res, halo_pos[1,i], halo_pos[2,i], halo_pos[3,i])
    end

    return dist, redshift, hp_ind
end

"""
Compute angles of halos
"""
function get_angles(halo_pos::Array{T,2}) where T
    N_halos = size(halo_pos, 2)
    θ = Array{T}(undef, N_halos)
    ϕ = Array{T}(undef, N_halos)

    Threads.@threads for i in 1:N_halos
        θ[i], ϕ[i] = Healpix.vec2ang(halo_pos[1,i], halo_pos[2,i], halo_pos[3,i])
    end

    return θ, ϕ
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


function catalog2map!(m::Map{T,RingOrder}, flux, theta, phi) where T
    res = m.resolution
    pixel_array = m.pixels
    N_halo = length(flux)

    # try to prevent thread issues by sorting by theta
    perm = sortperm(theta, rev=true, alg=ThreadsX.MergeSort)
    Threads.@threads for i_perm in 1:N_halo
        i_halo = perm[i_perm]
        hp_ind = Healpix.ang2pixRing(res, theta[i_halo], phi[i_halo])
        pixel_array[hp_ind] += flux[i_halo]
    end

    # divide by healpix pixel size
    per_pixel_steradian = 1 / nside2pixarea(res.nside)
    pixel_array .*= per_pixel_steradian
end
