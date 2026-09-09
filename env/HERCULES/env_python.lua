help([[
This module loads libraries for running python scripts on Hercules
]])

whatis([===[Loads libraries needed for running python scripts on Hercules ]===])

prepend_path("MODULEPATH", "/work2/noaa/wrfruc/murdzek/conda/miniforge_hercules/modulefiles")
load(pathJoin("miniforge3", os.getenv("miniforge_ver") or "25.3.0"))
setenv("PYGRAF_ENV", "/work2/noaa/wrfruc/murdzek/conda/miniforge_hercules/env/pygraf")
setenv("MYPY_ENV", "/work2/noaa/wrfruc/murdzek/conda/miniforge_hercules/env/my_py")
