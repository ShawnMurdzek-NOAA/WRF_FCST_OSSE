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

prepend_path("MODULEPATH", "/work/noaa/epic/role-epic/spack-stack/hercules/spack-stack-1.5.0/envs/unified-env/install/modulefiles/Core")
load(pathJoin("stack-intel", os.getenv("stack_intel_ver") or "2021.9.0"))
load(pathJoin("bacio", os.getenv("bacio_ver") or "2.4.1"))
load(pathJoin("w3emc", os.getenv("w3emc_ver") or "2.10.0"))
load(pathJoin("w3nco", os.getenv("w3nco_ver") or "2.4.1"))
load(pathJoin("g2", os.getenv("g2_ver") or "3.4.5"))
load(pathJoin("ip", os.getenv("ip_ver") or "4.3.0"))
load(pathJoin("sp", os.getenv("sp_ver") or "2.3.3"))

setenv("NETCDF","/work2/noaa/wrfruc/murdzek/src/HRRR/hercules/WRFV3.9_jet/netcdf_links")
setenv("NETCDFF","/apps/spack-managed/oneapi-2023.1.0/netcdf-fortran-4.6.0-md53fp73mfkib5jgdsxwyvxda5nvbpme")
setenv("HDF5","/apps/spack-managed/oneapi-2023.1.0/hdf5-1.14.1-2-w5swe6kh2cfgenig4q7g3ayn77qog673")
setenv("JASPERLIB","/work/noaa/epic/role-epic/spack-stack/hercules/spack-stack-1.5.0/envs/unified-env/install/intel/2021.9.0/jasper-2.0.32-rnh2ieo/lib64/")
setenv("JASPERINC","/work/noaa/epic/role-epic/spack-stack/hercules/spack-stack-1.5.0/envs/unified-env/install/intel/2021.9.0/jasper-2.0.32-rnh2ieo/include/")
