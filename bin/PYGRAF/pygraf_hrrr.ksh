#!/bin/bash

#
#-----------------------------------------------------------------------
#
# This script runs the pygraf create_graphics driver for creating
# PNG figures and zipping them for dissemination to the web.
#
# Loosely based on JRRFS_RUN_PYTHON_GRAPHICS from rrfs-workflow for 
# RRFSv1
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
module load env_pygraf
conda activate base
conda activate ${PYGRAF_ENV}

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
# Set the run directory and post directories.
#
#-----------------------------------------------------------------------
#
postprd_dir="${DATAUPPHOME}"
run_dir="${DATAHOME}/pyprd"
zip_dir="${DATAHOME}/nclprd"

fcst_length=${FCST_LEN_HRS}
tiles=${TILES:-full}

# Choose the appropriate file template for graphics type
case ${GRAPHICS_TYPE} in

  "maps")

    file_tmpl="wrfprs_hrconus_{FCST_TIME:02d}.grib2"
    file_type=prs
    extra_args="\
      --tiles ${tiles} \
      --images ${IMAGES_YML_FILE} hourly"
    if [ ${ALL_LEADS:-true} = "true" ] ; then
        extra_args="\
          ${extra_args} \
          --all_leads"
    fi
    ;;

  "skewts")

    file_tmpl="wrfnat_hrconus_{FCST_TIME:02d}.grib2"
    file_type=nat
    extra_args="\
      --sites ${SITE_FILE} \
      --max_plev 100"
    ;;

  *)
    err_exit "\
      GRAPHICS_TYPE \"${GRAPHICS_TYPE}\" is not recognized."
    ;;
esac
mkdir -p "${run_dir}"
#
#-----------------------------------------------------------------------
#
# Call the graphics driver script.
#
#-----------------------------------------------------------------------
#
cd ${PYTHON_GRAPHICS_DIR}
python -u ${PYTHON_GRAPHICS_DIR}/create_graphics.py \
  ${GRAPHICS_TYPE} \
  -a ${age:-3} \
  -d ${postprd_dir} \
  -f ${start_hour:-0} ${fcst_length} \
  --file_tmpl ${file_tmpl} \
  --file_type ${file_type} \
  -m "WRF_FCST_OSSE" \
  -n ${SLURM_CPUS_ON_NODE:-12} \
  -o ${run_dir} \
  -s ${CDATE} \
  -w ${wait_time:-30} \
  -z ${zip_dir} \
  ${extra_args}
err=$?
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
