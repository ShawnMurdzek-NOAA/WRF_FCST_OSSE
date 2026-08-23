help([[
This module loads libraries for running WRF on
HERCULES using spack-stack-2.1.0
]])

whatis([===[Loads libraries needed for running WRF on Hercules ]===])

append_path("MODULEPATH", "/apps/contrib/spack-stack/modulefiles")
append_path("MODULEPATH", "/apps/contrib/spack-stack/spack-stack-2.1.0/envs/ue-oneapi-2025.3.1/modules/Core")
load(pathJoin("stack-intel-oneapi-compilers", os.getenv("stack_intel_oneapi_compilers_ver") or "2025.3.1"))
load(pathJoin("stack-intel-oneapi-mpi", os.getenv("stack_intel_oneapi_mpi_ver") or "2021.17"))
--load(pathJoin("netcdf-c", os.getenv("netcdf_c_ver") or "4.9.2"))
--load(pathJoin("netcdf-fortran", os.getenv("netcdf_fortran_ver") or "4.6.1"))
load(pathJoin("hdf5", os.getenv("hdf5_ver") or "1.14.5"))

load(pathJoin("libjpeg", os.getenv("libjpeg_ver") or "3.0.4"))
load(pathJoin("jasper", os.getenv("jasper_ver") or "4.2.4"))
load(pathJoin("libpng", os.getenv("libpng_ver") or "1.6.37"))

load(pathJoin("wgrib2", os.getenv("wgrib2_ver") or "3.1.1"))
load(pathJoin("g2", os.getenv("g2_ver") or "3.5.1"))
load(pathJoin("g2tmpl", os.getenv("g2tmpl_ver") or "1.17.0"))
load(pathJoin("w3emc", os.getenv("w3emc_ver") or "2.13.0"))
load(pathJoin("w3nco", os.getenv("w3nco_ver") or "2.4.1"))
load(pathJoin("bufr", os.getenv("bufr_ver") or "12.1.0"))
load(pathJoin("bacio", os.getenv("bacio_ver") or "2.6.0"))
load(pathJoin("ip", os.getenv("ip_ver") or "5.4.0"))

setenv("NETCDF", "/work2/noaa/wrfruc/murdzek/src/HRRR/hercules/spack-stack-2.1.0/netcdf_links")
append_path("PATH", "/work2/noaa/wrfruc/murdzek/src/HRRR/hercules/spack-stack-2.1.0/netcdf_links/bin")
append_path("LD_LIBRARY_PATH", "/work2/noaa/wrfruc/murdzek/src/HRRR/hercules/spack-stack-2.1.0/netcdf_links/lib")
setenv("HDF5", "/apps/contrib/spack-stack/spack-stack-2.1.0/envs/ue-oneapi-2025.3.1/install/intel-oneapi-compilers/2025.3.1/hdf5-1.14.5-24ez6ow")
setenv("JASPERLIB", "/apps/contrib/spack-stack/spack-stack-2.1.0/envs/ue-oneapi-2025.3.1/install/intel-oneapi-compilers/2025.3.1/jasper-4.2.4-6eomiwh/lib64/")
setenv("JASPERINC", "/apps/contrib/spack-stack/spack-stack-2.1.0/envs/ue-oneapi-2025.3.1/install/intel-oneapi-compilers/2025.3.1/jasper-4.2.4-6eomiwh/include/")
