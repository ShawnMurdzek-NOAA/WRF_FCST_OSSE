#!/bin/bash

#
#-----------------------------------------------------------------------
#
# This script runs the Python GSI diag plotting script
#
#-----------------------------------------------------------------------
#

#
#-----------------------------------------------------------------------
#
# Source the variable definitions file and the bash utility functions.
#
#-----------------------------------------------------------------------
#

# Load modules and proper Python environment
module purge
module use ${ENV_DIR}
module load env_python
conda activate base
conda activate ${MYPY_ENV}
export PYTHONPATH=$PYTHONPATH:${SUBMODULES_DIR}

date
export PS4='+ $SECONDS + '
#
#-----------------------------------------------------------------------
#
# Save current shell options (in a global array).  Then set new options
# for this script/function.
#
#-----------------------------------------------------------------------
#
{ save_shell_opts; set -u -x; } > /dev/null 2>&1
shopt -s nullglob
#
#-----------------------------------------------------------------------
#
# Get the full path to the file in which this script/function is located 
# (scrfunc_fp), the name of that file (scrfunc_fn), and the directory in
# which the file is located (scrfunc_dir).
#
#-----------------------------------------------------------------------
#
scrfunc_fp=$( readlink -f "${BASH_SOURCE[0]}" )
scrfunc_fn=$( basename "${scrfunc_fp}" )
scrfunc_dir=$( dirname "${scrfunc_fp}" )
#
#-----------------------------------------------------------------------
#
# Print message indicating entry into script.
#
#-----------------------------------------------------------------------
#
echo
echo "========================================================================"
echo "Entering script:  \"${scrfunc_fn}\""
echo "In directory:     \"${scrfunc_dir}\""
echo "========================================================================"
echo
#
#-----------------------------------------------------------------------
#
# Check whether we need to run GSI diag plots
#
#-----------------------------------------------------------------------
#
HH=`date +"%H" -d "${TIME::8} ${TIME:8:2}"`

# Skip if GSI was not run
if [ ${SPINUP} -eq 1 ] && [ ${SKIP_GSI_FIRST_SPINUP} -eq 1 ]; then
  if [ ${HH} -eq "03" ] || [ ${HH} -eq "15" ]; then
    exit 0
  fi
fi
#
#-----------------------------------------------------------------------
#
# Set the run directory and post directories.
#
#-----------------------------------------------------------------------
#
mkdir -p "${OUT_DIR}"
cd ${OUT_DIR}
#
#-----------------------------------------------------------------------
#
# Call the graphics driver script.
#
#-----------------------------------------------------------------------
#
cp ${GSI_DIAG_PLOTS_DIR}/gsi_diag_plots.py .
python -u gsi_diag_plots.py \
	${DATAGSIHOME}/diag_results.conv_ges \
	${DATAGSIHOME}/diag_results.conv_anl \
	${TIME} \
	${OUT_DIR}
err=$?
#
#-----------------------------------------------------------------------
#
# Zip output
#
#-----------------------------------------------------------------------
#
if [[ ${err} -eq 0 ]]; then
  out_pngs=(*png)
  if [[ ${#out_pngs[@]} -gt 0 ]]; then
    echo "Zipping PNG files"
    zip gsi_diag_plots.zip *png
    rm *.png
  fi
fi
#
#-----------------------------------------------------------------------
#
# Print exit message.
#
#-----------------------------------------------------------------------
#
echo "========================================================================"
echo "Exiting script:  \"${scrfunc_fn}\""
echo "In directory:    \"${scrfunc_dir}\""
echo "========================================================================"
#
#-----------------------------------------------------------------------
#
# Restore the shell options saved at the beginning of this script/function.
#
#-----------------------------------------------------------------------
#
exit ${err}
