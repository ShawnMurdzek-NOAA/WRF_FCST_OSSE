help([[
This module loads libraries for building WRF on
the MSU machine Hercules using Intel-2022.2.1
]])

whatis([===[Loads libraries needed for building WRF on Hercules ]===])

load(pathJoin("intel-oneapi-compilers", os.getenv("intel_oneapi_compilers_ver") or "2022.2.1"))
load(pathJoin("mpich", os.getenv("mpich_ver") or "4.0.2"))
load(pathJoin("netcdf-c", os.getenv("netcdf_c_ver") or "4.9.0"))
load(pathJoin("netcdf-fortran", os.getenv("netcdf_fortran_ver") or "4.6.0"))
load(pathJoin("jasper", os.getenv("jasper_ver") or "3.0.3"))
load(pathJoin("libpng", os.getenv("libpng_ver") or "1.6.37"))
load(pathJoin("zlib", os.getenv("zlib_ver") or "1.2.13"))

load(pathJoin("hdf5", os.getenv("hdf5_ver") or "1.12.2"))
load(pathJoin("parallel-netcdf", os.getenv("parallel_netcdf_ver") or "1.12.3"))

setenv("NETCDF","/work2/noaa/wrfruc/murdzek/src/HRRR/hercules/WRFV3.9/netcdf_links")
setenv("NETCDFF","/apps/spack-managed/oneapi-2022.2.1/netcdf-fortran-4.6.0-2xezb3fxalllfj3vhawwjpwimdanushy/")
setenv("JASPERLIB","/apps/spack-managed/gcc-11.3.1/jasper-3.0.3-sljov5omt3f2e4db4zcoqnp2wbbd5ivr/lib64/")
setenv("JASPERINC","/apps/spack-managed/gcc-11.3.1/jasper-3.0.3-sljov5omt3f2e4db4zcoqnp2wbbd5ivr/include/")
