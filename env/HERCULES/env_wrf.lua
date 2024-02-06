help([[
This module loads libraries for building WRF on
the MSU machine Hercules using Intel-2023.1.0
]])

whatis([===[Loads libraries needed for building WRF on Hercules ]===])

load(pathJoin("intel-oneapi-compilers", os.getenv("intel_oneapi_compilers_ver") or "2023.1.0"))
load(pathJoin("intel-oneapi-mpi", os.getenv("intel_oneapi_mpi_ver") or "2021.9.0"))
load(pathJoin("netcdf-c", os.getenv("netcdf_c_ver") or "4.9.2"))
load(pathJoin("netcdf-fortran", os.getenv("netcdf_fortran_ver") or "4.6.0"))
load(pathJoin("parallel-netcdf", os.getenv("parallel_netcdf_ver") or "1.12.3"))
load(pathJoin("jasper", os.getenv("jasper_ver") or "3.0.3"))
load(pathJoin("libpng", os.getenv("libpng_ver") or "1.6.37"))

setenv("NETCDF","/work2/noaa/wrfruc/murdzek/src/HRRR/hercules/WRFV3.9_jet/netcdf_links")
setenv("NETCDFF","/apps/spack-managed/oneapi-2023.1.0/netcdf-fortran-4.6.0-verl5y5gs7s3qrsre75ikipm65wmaqjg/")
setenv("JASPERLIB","/apps/spack-managed/gcc-11.3.1/jasper-3.0.3-sljov5omt3f2e4db4zcoqnp2wbbd5ivr/lib64/")
setenv("JASPERINC","/apps/spack-managed/gcc-11.3.1/jasper-3.0.3-sljov5omt3f2e4db4zcoqnp2wbbd5ivr/include/")
