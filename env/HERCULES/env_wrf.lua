help([[
This module loads libraries for running WRF on
HERCULES using spack-stack-1.6.0
]])

whatis([===[Loads libraries needed for running WRF on Hercules ]===])

append_path("MODULEPATH", "/work/noaa/epic/role-epic/spack-stack/hercules/spack-stack-1.6.0/envs/gsi-addon-env/install/modulefiles/Core")
load(pathJoin("stack-intel", os.getenv("stack_intel_ver") or "2021.9.0"))
load(pathJoin("stack-intel-oneapi-mpi", os.getenv("stack_intel_oneapi_mpi_ver") or "2021.9.0"))
--load(pathJoin("netcdf-c", os.getenv("netcdf_c_ver") or "4.9.2"))
--load(pathJoin("netcdf-fortran", os.getenv("netcdf_fortran_ver") or "4.6.1"))
load(pathJoin("hdf5", os.getenv("hdf5_ver") or "1.14.0"))
load(pathJoin("snappy", os.getenv("snappy_ver") or "1.1.10"))
load(pathJoin("nghttp2", os.getenv("nghttp2_ver") or "1.57.0"))
load(pathJoin("curl", os.getenv("curl_ver") or "8.4.0"))
load(pathJoin("c-blosc", os.getenv("c_blosc_ver") or "1.21.5"))

load(pathJoin("jasper", os.getenv("jasper_ver") or "2.0.32"))
load(pathJoin("libpng", os.getenv("libpng_ver") or "1.6.37"))

load(pathJoin("wgrib2", os.getenv("wgrib2_ver") or "2.0.8"))
load(pathJoin("g2", os.getenv("g2_ver") or "3.4.5"))
load(pathJoin("g2tmpl", os.getenv("g2tmpl_ver") or "1.10.2"))
load(pathJoin("w3emc", os.getenv("w3emc_ver") or "2.10.0"))
load(pathJoin("w3nco", os.getenv("w3nco_ver") or "2.4.1"))
load(pathJoin("bufr", os.getenv("bufr_ver") or "11.7.0"))
load(pathJoin("bacio", os.getenv("bacio_ver") or "2.4.1"))
load(pathJoin("ip", os.getenv("ip_ver") or "4.3.0"))
load(pathJoin("sp", os.getenv("sp_ver") or "2.5.0"))
--load(pathJoin("nco", os.getenv("nco_ver") or "5.0.6"))

-- Not sure if these are needed, but I'm adding them so this environment perfectly matches the compile environment
load(pathJoin("ncurses", os.getenv("ncurses_ver") or "6.4"))
load(pathJoin("openssl", os.getenv("openssl_ver") or "1.1.1t"))
load(pathJoin("cmake", os.getenv("cmake_ver") or "3.26.3"))

setenv("NETCDF", "/work2/noaa/wrfruc/murdzek/src/HRRR/hercules/attempt2/netcdf_links")
append_path("PATH", "/work2/noaa/wrfruc/murdzek/src/HRRR/hercules/attempt2/netcdf_links/bin")
append_path("LD_LIBRARY_PATH", "/work2/noaa/wrfruc/murdzek/src/HRRR/hercules/attempt2/netcdf_links/lib")
setenv("HDF5", "/work/noaa/epic/role-epic/spack-stack/hercules/spack-stack-1.6.0/envs/unified-env/install/intel/2021.9.0/hdf5-1.14.0-htxkrrh")
setenv("JASPERLIB", "/work/noaa/epic/role-epic/spack-stack/hercules/spack-stack-1.6.0/envs/unified-env/install/intel/2021.9.0/jasper-2.0.32-jk3acwt/lib64/")
setenv("JASPERINC", "/work/noaa/epic/role-epic/spack-stack/hercules/spack-stack-1.6.0/envs/unified-env/install/intel/2021.9.0/jasper-2.0.32-jk3acwt/include/")
