help([[
This module loads libraries for building WRF on
the JET using Intel-18.0.5.274
]])

whatis([===[Loads libraries needed for building WRF on Jet ]===])

load(pathJoin("intel", os.getenv("intel_ver") or "18.0.5.274"))
load(pathJoin("impi", os.getenv("impi_ver") or "2018.4.274"))
load(pathJoin("szip", os.getenv("szipver") or "2.1"))
load(pathJoin("hdf5", os.getenv("hdf5_ver") or "1.8.9"))
load(pathJoin("netcdf", os.getenv("netcdf_ver") or "4.2.1.1"))
load(pathJoin("pnetcdf", os.getenv("pnetcdf_ver") or "1.6.1"))
load(pathJoin("nco", os.getenv("nco_ver") or "4.1.0"))
load(pathJoin("cnvgrib", os.getenv("cnvgrib_ver") or "1.4.0"))
load(pathJoin("imagemagick", os.getenv("imagemagick_ver") or "7.0.8-34"))
load(pathJoin("ncl", os.getenv("ncl_ver") or "6.5.0"))
