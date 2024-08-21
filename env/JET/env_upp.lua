help([[
This module loads libraries for running UPP on
the JET using Intel-2021.5.0 (Rocky 8)
]])

whatis([===[Loads libraries needed for building WRF on Jet ]===])

prepend_path("MODULEPATH","/contrib/spack-stack/spack-stack-1.6.0/envs/unified-env-rocky8/install/modulefiles/Core")
load(pathJoin("stack-intel", os.getenv("stack_intel_ver") or "2021.5.0"))
load(pathJoin("stack-intel-oneapi-mpi", os.getenv("stack_intel_oneapi_mpi_ver") or "2021.5.1"))
load(pathJoin("hdf5", os.getenv("hdf5_ver") or "1.14.0"))
load(pathJoin("netcdf-c", os.getenv("netcdf_c_ver") or "4.9.2"))
load(pathJoin("netcdf-cxx4", os.getenv("netcdf_cxx4_ver") or "4.3.1"))
load(pathJoin("netcdf-fortran", os.getenv("netcdf_fortran_ver") or "4.6.1"))
load(pathJoin("crtm", os.getenv("crtm_ver") or "2.4.0.1"))
