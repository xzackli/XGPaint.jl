var documenterSearchIndex = {"docs":
[{"location":"#XGPaint.jl-1","page":"Home","title":"XGPaint.jl","text":"","category":"section"},{"location":"#","page":"Home","title":"Home","text":"","category":"page"},{"location":"#","page":"Home","title":"Home","text":"Modules = [XGPaint]","category":"page"},{"location":"#XGPaint.CIBModel","page":"Home","title":"XGPaint.CIBModel","text":"CIBModel{T}(model parameters...)\n\nDefine CIB model parameters. Defaults are from Viero et al. 2013.\n\nmodel = CIBModel{Float32}(shang_Mpeak=10^12.4)\n\n\n\n\n\n","category":"type"},{"location":"#XGPaint.build_c_lnm2r_interp-Union{Tuple{}, Tuple{T}} where T","page":"Home","title":"XGPaint.build_c_lnm2r_interp","text":"Generates an interpolator r(c, lnm)\n\nGenerate a LinearInterpolation object that turns concentration and ln(M_halo) into satellite radius.\n\n\n\n\n\n","category":"method"},{"location":"#XGPaint.build_r2z_interpolator-Union{Tuple{T}, Tuple{T,T,Any}} where T","page":"Home","title":"XGPaint.build_r2z_interpolator","text":"Construct a fast r2z linear interpolator.\n\n\n\n\n\n","category":"method"},{"location":"#XGPaint.build_shang_interpolator-Union{Tuple{T}, Tuple{T,T,CIBModel}} where T","page":"Home","title":"XGPaint.build_shang_interpolator","text":"Build a linear interpolation function which maps log(Mh) to Nsat.\n\n\n\n\n\n","category":"method"},{"location":"#XGPaint.build_sigma_sat_ln-Union{Tuple{T}, Tuple{T,T,Any}} where T","page":"Home","title":"XGPaint.build_sigma_sat_ln","text":"Build a linear interpolator that takes in ln(M_halo) and returns sigma.\n\n\n\n\n\n","category":"method"},{"location":"#XGPaint.get_cosmology-Union{Tuple{}, Tuple{T}} where T","page":"Home","title":"XGPaint.get_cosmology","text":"Construct a cosmology with typing. The type of the output will the type of h and OmegaM. The types of h and OmegaM must match.\n\n\n\n\n\n","category":"method"},{"location":"#XGPaint.integrand_L-Tuple{Any,Any,CIBModel}","page":"Home","title":"XGPaint.integrand_L","text":"<L_sat> interpolation values\n\n\n\n\n\n","category":"method"},{"location":"#XGPaint.m2r-Union{Tuple{T}, Tuple{T,Cosmology.FlatLCDM{T}}} where T","page":"Home","title":"XGPaint.m2r","text":"Convert virial mass to virial radius.\n\n\n\n\n\n","category":"method"},{"location":"#XGPaint.mz2c-Union{Tuple{T}, Tuple{T,T,Cosmology.FlatLCDM{T}}} where T","page":"Home","title":"XGPaint.mz2c","text":"Compute concentration factor from Duffy et al. 2008.\n\n\n\n\n\n","category":"method"}]
}
