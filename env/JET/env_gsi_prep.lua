help([[
This module loads libraries for runnings GSI utility programs on
the JET using Intel-2022.1.2 (Rocky 8)
]])

whatis([===[Loads libraries needed for building WRF on Jet ]===])

load(pathJoin("intel", os.getenv("intel_ver") or "2022.1.2"))
load(pathJoin("impi", os.getenv("impi_ver") or "2022.1.2"))
load(pathJoin("netcdf", os.getenv("netcdf_ver") or "4.7.0"))
load(pathJoin("hdf5", os.getenv("hdf5_ver") or "1.10.6"))
