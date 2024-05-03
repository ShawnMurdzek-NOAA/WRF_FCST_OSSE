help([[
This module loads libraries for running GSI on
the JET using Intel-2022.1.2 (Rocky 8)
]])

whatis([===[Loads libraries needed for building WRF on Jet ]===])

load(pathJoin("intel", os.getenv("intel_ver") or "2022.1.2"))
load(pathJoin("impi", os.getenv("impi_ver") or "2022.1.2"))
load(pathJoin("hdf5parallel", os.getenv("hdf5parallel_ver") or "1.10.6"))
load(pathJoin("netcdf-hdf5parallel", os.getenv("netcdf_hdf5parallel_ver") or "4.7.4"))

append_path("MODULEPATH","/contrib/wrap-mpi/modulefiles")
load(pathJoin("wrap-mpi", os.getenv("wrap_mpi_ver")))
