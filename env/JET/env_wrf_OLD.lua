
-- This environment uses libraries from /lfs4, which may be retired soon. 
-- Thus, using this environment is not recommended. Use env_wrf.lua instead.

help([[
This module loads libraries for building WRF on
the JET using Intel-2022.1.2 (Rocky 8)
]])

whatis([===[Loads libraries needed for building WRF on Jet ]===])

load(pathJoin("intel", os.getenv("intel_ver") or "2022.1.2"))
load(pathJoin("impi", os.getenv("impi_ver") or "2022.1.2"))
load(pathJoin("netcdf", os.getenv("netcdf_ver") or "4.7.0"))
load(pathJoin("hdf5", os.getenv("hdf5_ver") or "1.10.6"))

append_path("MODULEPATH", "/mnt/lfs4/HFIP/hfv3gfs/nwprod/NCEPLIBS/modulefiles")
load(pathJoin("wgrib2", os.getenv("wgrib2_ver")))
load(pathJoin("g2", os.getenv("g2_ver") or "v3.1.0"))
load(pathJoin("g2tmpl", os.getenv("g2tmpl_ver") or "v1.6.0"))
load(pathJoin("jasper", os.getenv("jasper_ver") or "v1.900.1"))
load(pathJoin("png", os.getenv("png_ver") or "v1.2.44"))
load(pathJoin("z", os.getenv("z_ver") or "v1.2.6"))
load(pathJoin("w3emc", os.getenv("w3emc_ver") or "v2.4.0"))
load(pathJoin("w3nco", os.getenv("w3nco_ver") or "v2.0.6"))
load(pathJoin("bufr", os.getenv("bufr_ver") or "v11.3.0"))
load(pathJoin("bacio", os.getenv("bacio_ver") or "v2.0.2"))
load(pathJoin("ip", os.getenv("ip_ver") or "v2.0.0"))
load(pathJoin("sp", os.getenv("sp_ver") or "v2.0.2"))

load(pathJoin("ncl", os.getenv("ncl_ver") or "6.6.2"))
load(pathJoin("nco", os.getenv("nco_ver") or "5.1.6"))

append_path("MODULEPATH", "/contrib/miniconda3/modulefiles")
load(pathJoin("miniconda3", os.getenv("miniconda3_ver") or "4.12.0"))
