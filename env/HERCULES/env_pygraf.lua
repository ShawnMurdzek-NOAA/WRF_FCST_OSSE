help([[
This module loads libraries for running pygraf on Hercules
]])

whatis([===[Loads libraries needed for running pygraf on Hercules ]===])

prepend_path("MODULEPATH", "/work2/noaa/wrfruc/murdzek/conda/miniconda_hercules/modulefiles")
load(pathJoin("miniconda3", os.getenv("miniconda_ver") or "24.1.2"))
setenv("PYGRAF_ENV", "/work2/noaa/wrfruc/murdzek/conda/miniconda_hercules/env/pygraf")
