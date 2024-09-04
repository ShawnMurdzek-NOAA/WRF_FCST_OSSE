help([[
This module loads libraries for running pygraf on
the JET (Rocky 8)
]])

whatis([===[Loads libraries needed for running pygraf on Jet ]===])

prepend_path("MODULEPATH", "/mnt/lfs5/BMC/wrfruc/murdzek/conda/modulefiles")
load(pathJoin("miniconda3", os.getenv("miniconda_ver") or "24.1.2"))
setenv("PYGRAF_ENV", "/mnt/lfs5/BMC/wrfruc/murdzek/conda/env/my_pygraf")
