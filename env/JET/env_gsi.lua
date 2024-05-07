help([[
This module loads libraries for running GSI on
the JET using Intel-2022.1.2 (Rocky 8)
]])

whatis([===[Loads libraries needed for running GSI on Jet ]===])

load(pathJoin("intel", os.getenv("intel_ver") or "2022.1.2"))
load(pathJoin("impi", os.getenv("impi_ver") or "2022.1.2"))
load(pathJoin("hdf5parallel", os.getenv("hdf5parallel_ver") or "1.10.6"))
load(pathJoin("netcdf-hdf5parallel", os.getenv("netcdf_hdf5parallel_ver") or "4.7.4"))
