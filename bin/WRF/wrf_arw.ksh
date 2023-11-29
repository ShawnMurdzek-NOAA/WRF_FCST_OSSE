#!/bin/ksh --login
##########################################################################
#
#Script Name: wrf_wps.ksh
# 
#     Author: Christopher Harrop
#             Forecast Systems Laboratory
#             325 Broadway R/FST
#             Boulder, CO. 80305
#
# Purpose: This is a complete rewrite of the run_wrf.pl script that is 
#          distributed with the WRF Standard Initialization.  This script 
#          may be run on the command line, or it may be submitted directly 
#          to a batch queueing system.  A few environment variables must be 
#          set before it is run:
#
#               WRF_ROOT = The full path of WRFV1 directory
#          DATAHOME = Top level directory of wrf output
#          DATAROOT = Top level directory of wrf configuration data
#            FCST_LENGTH = The length of the forecast in hours.  If not set,
#                          the default value of 48 is used.
#      RUNLENGTH_DFI_FWD = The length of DFI forward integration in min
#      RUNLENGTH_DFI_BCK = The length of DFI backward integration in min
#          FCST_INTERVAL = The interval, in hours, between each forecast.
#                          If not set, the default value of 3 is used.
#             START_TIME = The cycle time to use for the initial time. 
#                          If not set, the system clock is used.
# 
# A short and simple "control" script could be written to call this script
# or to submit this  script to a batch queueing  system.  Such a "control" 
# script  could  also  be  used to  set the above environment variables as 
# appropriate  for  a  particular experiment.  Batch  queueing options can
# be  specified on the command  line or  as directives at  the top of this
# script.  A set of default batch queueing directives is provided.
#
##########################################################################

np=`cat $PBS_NODEFILE | wc -l`

# Set IMPI I/O performance variables
export I_MPI_EXTRA_FILESYSTEM=on
export I_MPI_EXTRA_FILESYSTEM_LIST=lustre:panfs

# Load modules
module purge
module load intel/18.0.5.274
module load impi/2018.4.274
module load szip/2.1 hdf5/1.8.9 netcdf/4.2.1.1
module load pnetcdf/1.6.1
module load nco/4.1.0
module load cnvgrib/1.4.0
module load imagemagick/7.0.8-34
module load ncl/6.5.0
module load nco

# Set up paths to shell commands
LS=/bin/ls
LN=/bin/ln
RM=/bin/rm
MKDIR=/bin/mkdir
CP=/bin/cp
MV=/bin/mv
ECHO=/bin/echo
CAT=/bin/cat
GREP=/bin/grep
CUT=`which cut`
AWK="/bin/gawk --posix"
SED=/bin/sed
DATE=/bin/date
BC=/usr/bin/bc
MPIRUN=srun

# Create a list of nodes used by this job
NODES=$(cat $PBS_NODEFILE | sort | uniq)

# Set up some constants
export WRF_NAMELIST=${DATAHOME}/namelist.input
export WRF=${WRF_ROOT}/wrf.exe
export UPDATEBC=${WRF_ROOT}/da_update_bc.exe
export UPDATEBC_PARA=${STATIC_DIR}/parame.in

# Initialize an array of WRF input dat files that need to be linked
set -A WRF_DAT_FILES ${STATIC_DIR}/run/LANDUSE.TBL          \
                     ${STATIC_DIR}/run/RRTM_DATA            \
                     ${STATIC_DIR}/run/RRTM_DATA_DBL        \
                     ${STATIC_DIR}/run/RRTMG_LW_DATA        \
                     ${STATIC_DIR}/run/RRTMG_LW_DATA_DBL    \
                     ${STATIC_DIR}/run/RRTMG_SW_DATA        \
                     ${STATIC_DIR}/run/RRTMG_SW_DATA_DBL    \
                     ${STATIC_DIR}/run/VEGPARM.TBL          \
                     ${STATIC_DIR}/run/GENPARM.TBL          \
                     ${STATIC_DIR}/run/SOILPARM.TBL         \
                     ${STATIC_DIR}/run/MPTABLE.TBL          \
                     ${STATIC_DIR}/run/URBPARM.TBL          \
                     ${STATIC_DIR}/run/URBPARM_UZE.TBL      \
                     ${STATIC_DIR}/run/ETAMPNEW_DATA        \
                     ${STATIC_DIR}/run/ETAMPNEW_DATA.expanded_rain        \
                     ${STATIC_DIR}/run/ETAMPNEW_DATA.expanded_rain_DBL    \
                     ${STATIC_DIR}/run/ETAMPNEW_DATA_DBL    \
                     ${STATIC_DIR}/run/co2_trans            \
                     ${STATIC_DIR}/run/ozone.formatted      \
                     ${STATIC_DIR}/run/ozone_lat.formatted  \
                     ${STATIC_DIR}/run/ozone_plev.formatted \
                     ${STATIC_DIR}/run/bulkdens.asc_s_0_03_0_9 \
                     ${STATIC_DIR}/run/bulkradii.asc_s_0_03_0_9  \
                     ${STATIC_DIR}/run/capacity.asc         \
                     ${STATIC_DIR}/run/CCN_ACTIVATE.BIN     \
                     ${STATIC_DIR}/run/coeff_p.asc          \
                     ${STATIC_DIR}/run/coeff_q.asc          \
                     ${STATIC_DIR}/run/constants.asc        \
                     ${STATIC_DIR}/run/kernels.asc_s_0_03_0_9  \
                     ${STATIC_DIR}/run/kernels_z.asc           \
                     ${STATIC_DIR}/run/masses.asc              \
                     ${STATIC_DIR}/run/termvels.asc            \
                     ${STATIC_DIR}/run/wind-turbine-1.tbl      \
                     ${STATIC_DIR}/run/tr49t85              \
                     ${STATIC_DIR}/run/tr49t67              \
                     ${STATIC_DIR}/run/tr67t85              \
                     ${STATIC_DIR}/run/grib2map.tbl         \
                     ${STATIC_DIR}/run/gribmap.txt          \
                     ${STATIC_DIR}/run/freezeH2O.dat        \
                     ${STATIC_DIR}/run/qr_acr_qg.dat        \
                     ${STATIC_DIR}/run/qr_acr_qs.dat        \
                     ${STATIC_DIR}/run/eclipse_besselian_elements.dat

# Check to make sure the wrf executable exists
if [ ! -x ${WRF} ]; then
  ${ECHO} "ERROR: ${WRF} does not exist, or is not executable"
  exit 1
fi

# Check to make sure the number of processors for running WRF was specified
if [ -z "${WRFPROC}" ]; then
  ${ECHO} "ERROR: The variable $WRFPROC must be set to contain the number of processors to run WRF"
  exit 1
fi

# Check to make sure that the DATAROOT exists
if [ ! -d ${DATAROOT} ]; then
  ${ECHO} "ERROR: ${DATAROOT} does not exist"
  exit 1
fi

# Make sure the forecast length is defined
if [ ! ${FCST_LENGTH} ]; then
  ${ECHO} "ERROR: \$FCST_LENGTH is not defined!"
  exit 1
fi

# Make sure the forecast interval is defined
if [ ! ${FCST_INTERVAL} ]; then
  ${ECHO} "ERROR: \$FCST_INTERVAL is not defined!"
  exit 1
fi

# Make sure START_TIME is specified
if [ ! "${START_TIME}" ]; then
  ${ECHO} "ERROR: \$START_TIME is not defined"
  exit 1
fi

# Check to make sure WRF DAT files exist
for file in ${WRF_DAT_FILES[@]}; do
  if [ ! -s ${file} ]; then
    ${ECHO} "ERROR: ${file} either does not exist or is empty"
    exit 1
  fi
done

# Convert START_TIME from 'YYYYMMDDHH' format to Unix date format, e.g. "Fri May  6 19:50:23 GMT 2005"
if [ `${ECHO} "${START_TIME}" | ${AWK} '/^[[:digit:]]{10}$/'` ]; then
  START_TIME=`${ECHO} "${START_TIME}" | ${SED} 's/\([[:digit:]]\{2\}\)$/ \1/'`
else
  ${ECHO} "ERROR: start time, '${START_TIME}', is not in 'yyyymmddhh' or 'yyyymmdd hh' format"
  exit 1
fi
START_TIME=`${DATE} -d "${START_TIME}"`
YYYYMMDDHH=`${DATE} +"%Y%m%d%H" -d "${START_TIME}"`

# Get the end time string
END_TIME=`${DATE} -d "${START_TIME}  ${FCST_LENGTH} hours"`

# Print run parameters
${ECHO}
${ECHO} "wrf.ksh started at `${DATE}`"
${ECHO}
${ECHO} "WRF_ROOT      = ${WRF_ROOT}"
${ECHO} "DATAROOT = ${DATAROOT}"
${ECHO} "DATAHOME = ${DATAHOME}"
${ECHO} "MV2_USE_HSAM  = ${MV2_USE_HSAM}"
${ECHO}
${ECHO} "FCST LENGTH   = ${FCST_LENGTH}"
${ECHO} "FCST INTERVAL = ${FCST_INTERVAL}"
${ECHO}
${ECHO} "START TIME = "`${DATE} +"%Y/%m/%d %H:%M:%S" -d "${START_TIME}"`
${ECHO} "  END TIME = "`${DATE} +"%Y/%m/%d %H:%M:%S" -d "${END_TIME}"`
${ECHO}

# Setup alternative START_TIME options
time_str=`${DATE} "+%Y-%m-%d_%H_%M_%S" -d "${START_TIME}"`
time_00hago=`${DATE} +"%Y%m%d%H" -d "${START_TIME}  0 hours ago"`
time_01hago=`${DATE} +"%Y%m%d%H" -d "${START_TIME}  1 hours ago"`
time_11hago=`${DATE} +"%Y%m%d%H" -d "${START_TIME}  11 hours ago"`

# Set up the work directory and cd into it
workdir=${DATAHOME}
${MKDIR} -p ${workdir}
#if [ "`stat -f -c %T ${workdir}`" == "lustre" ]; then
#  lfs setstripe --count 8 ${workdir}
#fi
cd ${workdir}
echo ${NODES} > ${workdir}/nodefile.txt

# Copy the wrf namelist from the static dir
if [ ${FULLCYC} -eq 0 ]; then
  ${CP} ${STATIC_DIR}/wrf.pcycle.nl ${WRF_NAMELIST}
elif [ ${FULLCYC} -eq 1 ]; then
  ${CP} ${STATIC_DIR}/wrf.nl ${WRF_NAMELIST}
else
  echo "ERROR: Unknown CYCLE ${FULLCYC} definition!"
  exit 1
fi

# Check to make sure the wrfinput_d01 file exists
if [ -r ${DATAGSIHOME}/wrf_inout ]; then
  ${ECHO} " Initial condition ${DATAGSIHOME}/wrf_inout "
  ${LN} -s ${DATAGSIHOME}/wrf_inout ${DATAHOME}/wrfinput_d01
  ${LN} -s ${DATAHOME}/wrfinput_d01 ${DATAHOME}/wrfvar_output
else
  ${ECHO} "ERROR: ${DATAGSIHOME}/wrf_inout does not exist, or is not readable"
  exit 1
fi

# Check to make sure the wrfbdy_d01 file exists
if [ -r ${DATAHOME_BC}/wrfbdy_d01 ]; then
  ${ECHO} " Boundary condition ${DATAHOME_BC}/wrfbdy_d01 "
  ${CP} ${DATAHOME_BC}/wrfbdy_d01 ${DATAHOME}/wrfbdy_d01
else
  ${ECHO} "ERROR: No viable wrfbdy_d01 boundary files found "
  exit 1
fi

# If this is a 1h pre-forecast, find the most recent 3D smoke forecast valid at this time
if [ ${FULLCYC} -eq 0 ]; then
  if [ -r ${DATAROOT}/${time_11hago}/wrfprd/wrfout_d01_${time_str} ]; then
    ${ECHO} " Cycled smoke using ${time_11hago}/wrfprd/wrfout_d01_${time_str}"
    ${LN} -s ${DATAROOT}/${time_11hago}/wrfprd/wrfout_d01_${time_str} ./wrfout_smoke
    ${ECHO} " Cycle ${YYYYMMDDHH}: Smoke background=${time_11hago}/wrfprd/wrfout_d01_${time_str}"
  else # Last resort zeroes
    ${ECHO} "No previous smoke forecast available; quit."
#    exit 1
  fi
  if [ ! -s wrfout_smoke ]; then
    ${ECHO} "File wrfout_smoke does not exist."
#    exit 1
  else
    ${ECHO} "Start 3D smoke ncks `${DATE}`"
    ncks -A -v smoke wrfout_smoke wrfinput_d01
    ${ECHO} "End 3D smoke ncks `${DATE}`"
  fi
fi

# Find the valid emissions file
if [ ${FULLCYC} -eq 0 ]; then
  if [ -r ${DATAHOME}/../../${YYYYMMDDHH}/gsiprd/wrf_inout ]; then
    ${LN} -s ${DATAHOME}/../../${YYYYMMDDHH}/gsiprd/wrf_inout ./wrffirechemi_d01
    ${ECHO} "Cycle ${YYYYMMDDHH}: Emissions=${YYYYMMDDHH}/gsiprd/wrf_inout"
    ${ECHO} "Start emissions fields ncks `${DATE}`"
    ncks -A -v MEAN_FRP,STD_FRP,MEAN_FSIZE,STD_FSIZE,EBB_SMOKE wrffirechemi_d01 wrfinput_d01
    ${ECHO} "End emissions fields ncks `${DATE}`"
  else # Last resort zeroes
    ${ECHO} "Cycle ${YYYYMMDDHH}: Emissions=${YYYYMMDDHH}/gsiprd/wrf_inout unavailable."
    exit 1
  fi
fi

# Make links to the WRF DAT files
for file in ${WRF_DAT_FILES[@]}; do
  ${RM} -f `basename ${file}`
  ${LN} -s ${file}
done

# Get the start and end time components
start_year=`${DATE} +%Y -d "${START_TIME}"`
start_month=`${DATE} +%m -d "${START_TIME}"`
start_day=`${DATE} +%d -d "${START_TIME}"`
start_hour=`${DATE} +%H -d "${START_TIME}"`
start_minute=`${DATE} +%M -d "${START_TIME}"`
start_second=`${DATE} +%S -d "${START_TIME}"`
end_year=`${DATE} +%Y -d "${END_TIME}"`
end_month=`${DATE} +%m -d "${END_TIME}"`
end_day=`${DATE} +%d -d "${END_TIME}"`
end_hour=`${DATE} +%H -d "${END_TIME}"`
end_minute=`${DATE} +%M -d "${END_TIME}"`
end_second=`${DATE} +%S -d "${END_TIME}"`

# Compute number of days and hours for the run
(( run_days = 0 ))
(( run_hours = 0 ))

# Create patterns for updating the wrf namelist
run=[Rr][Uu][Nn]
equal=[[:blank:]]*=[[:blank:]]*
start=[Ss][Tt][Aa][Rr][Tt]
end=[Ee][Nn][Dd]
year=[Yy][Ee][Aa][Rr]
month=[Mm][Oo][Nn][Tt][Hh]
day=[Dd][Aa][Yy]
hour=[Hh][Oo][Uu][Rr]
minute=[Mm][Ii][Nn][Uu][Tt][Ee]
second=[Ss][Ee][Cc][Oo][Nn][Dd]
interval=[Ii][Nn][Tt][Ee][Rr][Vv][Aa][Ll]

# Update the run_days in wrf namelist.input
${CAT} ${WRF_NAMELIST} | ${SED} "s/\(${run}_${day}[Ss]\)${equal}[[:digit:]]\{1,\}/\1 = ${run_days}/" \
   > ${WRF_NAMELIST}.new
${MV} ${WRF_NAMELIST}.new ${WRF_NAMELIST}

# Update the run_hours in wrf namelist
${CAT} ${WRF_NAMELIST} | ${SED} "s/\(${run}_${hour}[Ss]\)${equal}[[:digit:]]\{1,\}/\1 = ${run_hours}/" \
   > ${WRF_NAMELIST}.new
${MV} ${WRF_NAMELIST}.new ${WRF_NAMELIST}

# Update the start time in wrf namelist
${CAT} ${WRF_NAMELIST} | ${SED} "s/\(${start}_${year}\)${equal}[[:digit:]]\{4\}/\1 = ${start_year}/" \
   | ${SED} "s/\(${start}_${month}\)${equal}[[:digit:]]\{2\}/\1 = ${start_month}/"                   \
   | ${SED} "s/\(${start}_${day}\)${equal}[[:digit:]]\{2\}/\1 = ${start_day}/"                       \
   | ${SED} "s/\(${start}_${hour}\)${equal}[[:digit:]]\{2\}/\1 = ${start_hour}/"                     \
   | ${SED} "s/\(${start}_${minute}\)${equal}[[:digit:]]\{2\}/\1 = ${start_minute}/"                 \
   | ${SED} "s/\(${start}_${second}\)${equal}[[:digit:]]\{2\}/\1 = ${start_second}/"                 \
   > ${WRF_NAMELIST}.new
${MV} ${WRF_NAMELIST}.new ${WRF_NAMELIST}

# Update end time in wrf namelist
${CAT} ${WRF_NAMELIST} | ${SED} "s/\(${end}_${year}\)${equal}[[:digit:]]\{4\}/\1 = ${end_year}/" \
   | ${SED} "s/\(${end}_${month}\)${equal}[[:digit:]]\{2\}/\1 = ${end_month}/"                   \
   | ${SED} "s/\(${end}_${day}\)${equal}[[:digit:]]\{2\}/\1 = ${end_day}/"                       \
   | ${SED} "s/\(${end}_${hour}\)${equal}[[:digit:]]\{2\}/\1 = ${end_hour}/"                     \
   | ${SED} "s/\(${end}_${minute}\)${equal}[[:digit:]]\{2\}/\1 = ${end_minute}/"                 \
   | ${SED} "s/\(${end}_${second}\)${equal}[[:digit:]]\{2\}/\1 = ${end_second}/"                 \
   > ${WRF_NAMELIST}.new
${MV} ${WRF_NAMELIST}.new ${WRF_NAMELIST}

# Update interval in namelist
(( fcst_interval_sec = ${FCST_INTERVAL} * 3600 ))
${CAT} ${WRF_NAMELIST} | ${SED} "s/\(${interval}_${second}[Ss]\)${equal}[[:digit:]]\{1,\}/\1 = ${fcst_interval_sec}/" \
   > ${WRF_NAMELIST}.new 
${MV} ${WRF_NAMELIST}.new ${WRF_NAMELIST}

# Move existing rsl files to a subdir if there are any
${ECHO} "Checking for pre-existing rsl files"
if [ -f "rsl.out.0000" ]; then
  rsldir=rsl.`${LS} -l --time-style=+%Y%m%d%H%M%S rsl.out.0000 | ${CUT} -d" " -f 7`
  ${MKDIR} ${rsldir}
  ${ECHO} "Moving pre-existing rsl files to ${rsldir}"
  ${MV} rsl.out.* ${rsldir}
  ${MV} rsl.error.* ${rsldir}
else
  ${ECHO} "No pre-existing rsl files were found"
fi

# update bc
echo "begin update bc"
${CP} ${UPDATEBC_PARA} parame.in
${MPIRUN} --ntasks=1 ${UPDATEBC}
echo "end update bc"

# Get the current time
now=`${DATE} +%Y%m%d%H%M%S`

# Run wrf
${MPIRUN} ${WRF}
error=$?

# Save a copy of the RSL files
rsldir=rsl.wrf.${now}
${MKDIR} ${rsldir}
mv rsl.out.* ${rsldir}
mv rsl.error.* ${rsldir}

# Check the exit status of WRF
if [ ${error} -ne 0 ]; then
  ${ECHO} "ERROR: ${WRF} exited with status: ${error}"
  exit ${error}
else

  # Check to see if the output is there:
  endtime_str=`${DATE} +%Y-%m-%d_%H_%M_%S -d "${START_TIME}  ${FCST_LENGTH} hours"`
  if [ ! -e "wrfout_d01_${endtime_str}" ]; then
    ${ECHO} "${WRF} failed to complete"
    exit 1
  fi 
  
  # Output successful so write status to log
  if [ ${FULLCYC} -eq 0 ]; then
    ${ECHO} " Cycle ${YYYYMMDDHH}: ARW finished successfully at `${DATE}`" >> ${DATABASE_DIR}/loghistory/HRRR_ARW_PCYC.log
  elif [ ${FULLCYC} -eq 1 ]; then
    ${ECHO} " Cycle ${YYYYMMDDHH}: ARW finished successfully at `${DATE}`" >> ${DATABASE_DIR}/loghistory/HRRR_ARW.log
  else
    echo "ERROR: Unknown CYCLE ${FULLCYC} definition!"
    exit 1
  fi  

  ${ECHO} "wrf.ksh completed successfully at `${DATE}`"
fi

exit 0
