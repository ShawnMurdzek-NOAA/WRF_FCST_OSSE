help([[
]])

prepend_path("MODULEPATH", "/apps/contrib/spack-stack/spack-stack-2.1.1/envs/ue-oneapi-2025.3.1/modules/Core")
prepend_path("MODULEPATH", "/apps/contrib/spack-stack/modulefiles")

local stack_python_ver=os.getenv("stack_python_ver") or "3.11.11"
local stack_intel_ver=os.getenv("stack_intel_ver") or "2025.3.1"
local stack_impi_ver=os.getenv("stack_impi_ver") or "2021.17"
local cmake_ver=os.getenv("cmake_ver") or "3.31.8"
local prod_util_ver=os.getenv("prod_util_ver") or "2.1.2"

load(pathJoin("stack-intel-oneapi-compilers", stack_intel_ver))
load(pathJoin("stack-intel-oneapi-mpi", stack_impi_ver))
load(pathJoin("python", stack_python_ver))
load(pathJoin("cmake", cmake_ver))

load("gsi_common")
load(pathJoin("prod_util", prod_util_ver))
load("intel-oneapi-mkl/2025.3.0")

pushenv("CFLAGS", "-xHOST")
pushenv("FFLAGS", "-xHOST")

--pushenv("GSI_BINARY_SOURCE_DIR", "/work/noaa/global/glopara/fix/gsi/20230911")

whatis("Description: GSI environment on Hercules with Intel Compilers")
