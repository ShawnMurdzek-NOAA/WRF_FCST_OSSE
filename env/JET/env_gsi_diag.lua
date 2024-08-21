help([[
This module loads libraries for running GSI-utils on
the JET using Intel-2021.5.0 (Rocky 8)
]])

whatis([===[Loads libraries needed for building GSI-utils on Jet ]===])

prepend_path("MODULEPATH","/contrib/spack-stack/spack-stack-1.6.0/envs/unified-env-rocky8/install/modulefiles/Core")
load(pathJoin("stack-intel", os.getenv("stack_intel_ver") or "2021.5.0"))
load(pathJoin("stack-intel-oneapi-mpi", os.getenv("stack_intel_oneapi_mpi_ver") or "2021.5.1"))
load(pathJoin("hdf5", os.getenv("hdf5_ver") or "1.14.0"))
load(pathJoin("netcdf-c", os.getenv("netcdf_c_ver") or "4.9.2"))
load(pathJoin("netcdf-cxx4", os.getenv("netcdf_cxx4_ver") or "4.3.1"))
load(pathJoin("netcdf-fortran", os.getenv("netcdf_fortran_ver") or "4.6.1"))
load(pathJoin("wgrib2", os.getenv("wgrib2_ver")))

load(pathJoin("g2", os.getenv("g2_ver") or "3.4.5"))
load(pathJoin("g2tmpl", os.getenv("g2tmpl_ver") or "1.10.2"))
load(pathJoin("jasper", os.getenv("jasper_ver") or "4.2.0"))
load(pathJoin("libpng", os.getenv("png_ver") or "1.6.37"))
load(pathJoin("zlib", os.getenv("z_ver") or "1.2.13"))
load(pathJoin("w3emc", os.getenv("w3emc_ver") or "2.10.0"))
load(pathJoin("w3nco", os.getenv("w3nco_ver") or "2.4.1"))
load(pathJoin("bufr", os.getenv("bufr_ver") or "12.0.1"))
load(pathJoin("bacio", os.getenv("bacio_ver") or "2.4.1"))
load(pathJoin("ip", os.getenv("ip_ver") or "4.3.0"))
load(pathJoin("sp", os.getenv("sp_ver") or "2.5.0"))
load(pathJoin("sigio", os.getenv("sigio_ver") or "2.3.2"))
load(pathJoin("sfcio", os.getenv("sfcio_ver") or "1.4.1"))
load(pathJoin("nemsio", os.getenv("nemsio_ver") or "2.5.4"))
load(pathJoin("ncio", os.getenv("ncio_ver") or "1.1.2"))
load(pathJoin("wrf-io", os.getenv("wrf_io_ver") or "1.2.0"))
load(pathJoin("gsi-ncdiag", os.getenv("gsi_ncdiag_ver") or "1.1.2"))

load(pathJoin("nco", os.getenv("nco_ver") or "5.1.6"))

append_path("MODULEPATH", "/contrib/miniconda3/modulefiles")
load(pathJoin("miniconda3", os.getenv("miniconda3_ver") or "4.12.0"))
