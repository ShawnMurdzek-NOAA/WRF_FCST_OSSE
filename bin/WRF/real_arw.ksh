#!/bin/ksh --login
##########################################################################
#
#Script Name: real_wps.ksh
# 
#     Author: Christopher Harrop
#             Forecast Systems Laboratory
#             325 Broadway R/FST
#             Boulder, CO. 80305
#
# Purpose: This is a complete rewrite of the real portion of the 
#          wrfprep.pl script that is distributed with the WRF Standard 
#          Initialization.  This script may be run on the command line, or 
#          it may be submitted directly to a batch queueing system.  
#
##########################################################################
#          REQUIRED Environment variables:
##########################################################################
#
#               WRF_ROOT = The full path of WRFV2 directory
#               WRF_CORE = The core to run (e.g. ARW or NMM)
#          DATAROOT = Top level directory of wrf domain data
#          DATAHOME = Top level directory of wrf output
#            FCST_LENGTH = The length of the forecast in hours.
#          FCST_INTERVAL = The interval, in hours, between each forecast.
#             START_TIME = The cycle time to use for the initial time.
#               REALPROC = The number of processors to run real with
#
##########################################################################
#          OPTIONAL Environment variables:
##########################################################################
#
#         INPUT_DATAROOT = Top level directory containing wpsprd directory
#                          which contains the input files
#                          (If not set, $DATAHOME is used)
#           INPUT_FORMAT = NETCDF or BINARY (If not set, NETCDF is assumed)
# 
##########################################################################
#           OPTIONAL Environment variables that relate to cycling:
##########################################################################
#
#            CYCLE_FCSTS = List of previous forecast lengths allowed for 
#                          cycling (e.g. "01 02 03 04 05 06").  The version
#                          of real that is used must support cycling if this
#                          is set!  Defining this variable turns cycling 
#                          mode on
#         WRF_CYCLE_ROOT = The full path of WRFV2 directory for a version
#                          of WRF that supports cycling.  Ignored if
#                          CYCLE_FCSTS is not defined, but REQUIRED if
#                          CYCLE_FCSTS is defined. Can be equal to
#                          WRF_ROOT if the same code supports non-cycling
#                          and cycling modes both.
#      DATAROOT_ALT = Alternate DATAROOT in which to look for
#                          previous forecasts if one is not found in the
#                          DATAROOT.
#               PREPBUFR = Path of the prepbufr obs files used in cycling
#
##########################################################################
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

# Set the pathname of the WRF namelist
WRF_NAMELIST=${DATAHOME}/namelist.input

# Make sure WRF_ROOT is set and that it exists
if [ ! "${WRF_ROOT}" ]; then
  ${ECHO} "ERROR: \$WRF_ROOT is not defined"
  exit 1
fi
if [ ! -d "${WRF_ROOT}" ]; then
  ${ECHO} "ERROR: WRF_ROOT directory, '${WRF_ROOT}', does not exist"
  exit 1
fi

# Make sure that WRF_CORE is set to a valid value, and set some core dependent vars
if [ ! "${WRF_CORE}" ]; then
  ${ECHO} "ERROR: \$WRF_CORE is not defined"
  exit 1
elif [ "${WRF_CORE}" == "ARW" ]; then
  REAL=${WRF_ROOT}/real.exe
  real_prefix="met_em"
elif [ "${WRF_CORE}" == "NMM" ]; then
  REAL=${WRF_ROOT}/real_nmm.exe
  real_prefix="met_nmm"
else
  ${ECHO} "ERROR: Unsupported WRF CORE, '${WRF_CORE}'"
  exit 1
fi

# Make sure the real executable exists
if [ ! -x ${REAL} ]; then
  ${ECHO} "ERROR: real executable, '${REAL}', does not exist, or is not executable"
  exit 1
fi

# Make sure that the DATAROOT is defined and that it exists
if [ ! "${DATAROOT}" ]; then
  ${ECHO} "ERROR: \$DATAROOT is not defined"
  exit 1
fi
if [ ! -d "${DATAROOT}" ]; then
  ${ECHO} "ERROR: DATAROOT directory, '${DATAROOT}', does not exist"
  exit 1
fi

# Make sure the DATAHOME is defined (it doesn't need to exist yet)
if [ ! "${DATAHOME}" ]; then
  ${ECHO} "ERROR: \$DATAHOME is not defined"
  exit 1
fi

# Make sure $INPUT_DATAROOT is defined
if [ ! "${INPUT_DATAHOME}" ]; then
  ${ECHO} "ERROR: \$INPUT_DATAHOME is not defined"
  exit 1
fi

# Check for INPUT_DATAHOME directory 
if [ ! -d "${INPUT_DATAHOME}" ]; then
  ${ECHO} "ERROR: \$INPUT_DATAHOME does not exist "
  exit 1
fi
  
# Make working directory
if [ ! -d "${DATAHOME}" ]; then
  ${MKDIR} -p ${DATAHOME}
fi

# Set the input format
if [ ! "${INPUT_FORMAT}" ]; then
  INPUT_FORMAT=NETCDF
fi
if [ "${INPUT_FORMAT}" == "NETCDF" ]; then
  real_suffix=".nc"
elif [ "${INPUT_FORMAT}" == "BINARY" ]; then :
  real_suffix=""
else
  ${ECHO} "ERROR: Unsupported INPUT_FORMAT, '${INPUT_FORMAT}'"
  exit 1
fi

if [ ! "${START_TIME}" ]; then
  ${ECHO} "ERROR: \$START_TIME is not defined!"
  exit 1
fi

# Make sure the FCST_LENGTH is defined
if [ ! "${FCST_LENGTH}" ]; then
  ${ECHO} "ERROR: \$FCST_LENGTH is not defined"
  exit 1
fi

# Make sure the FCST_INTERVAL is defined
if [ ! "${FCST_INTERVAL}" ]; then
  ${ECHO} "ERROR: \$FCST_INTERVAL is not defined"
  exit 1
fi

# Initialize an array of WRF DAT files that need to be linked
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
                     ${STATIC_DIR}/run/qr_acr_qs.dat

# Check to make sure WRF DAT files exist
for file in ${WRF_DAT_FILES[@]}; do
  if [ ! -s ${file} ]; then
    ${ECHO} "ERROR: ${file} either does not exist or is empty"
    exit 1
  fi
done

# Make sure START_TIME is defined and in the correct format
if [ `${ECHO} "${START_TIME}" | ${AWK} '/^[[:digit:]]{10}$/'` ]; then
  START_TIME=`${ECHO} "${START_TIME}" | ${SED} 's/\([[:digit:]]\{2\}\)$/ \1/'`
else
  ${ECHO} "ERROR: start time, '${START_TIME}', is not in 'yyyymmddhh' or 'yyyymmdd hh' format"
  exit 1
fi
START_TIME=`${DATE} -d "${START_TIME}"`

# Calculate the forecast end time
END_TIME=`${DATE} -d "${START_TIME}  ${FCST_LENGTH} hours"`

# Print run parameters
${ECHO}
${ECHO} "real.ksh started at `${DATE}`"
${ECHO}
${ECHO} "WRF_ROOT       = ${WRF_ROOT}"
${ECHO} "WRF_CORE       = ${WRF_CORE}"
${ECHO}
${ECHO} "DATAROOT  = ${DATAROOT}"
${ECHO} "DATAHOME  = ${DATAHOME}"
${ECHO}
${ECHO} "INPUT_DATAROOT = ${INPUT_DATAROOT}"
${ECHO} "INPUT_FORMAT   = ${INPUT_FORMAT}"
${ECHO}
${ECHO} "FCST_LENGTH    = ${FCST_LENGTH}"
${ECHO} "FCST_INTERVAL  = ${FCST_INTERVAL}"
${ECHO}
${ECHO} "START_TIME     = "`${DATE} +"%Y/%m/%d %H:%M:%S" -d "${START_TIME}"`
${ECHO} "END_TIME       = "`${DATE} +"%Y/%m/%d %H:%M:%S" -d "${END_TIME}"`
${ECHO}

# Check to make sure the work directory (wrfprd) exists and cd into it
workdir=${DATAHOME}
${MKDIR} -p ${workdir}
#if [ "`stat -f -c %T $DIR`" == "lustre" ]; then
#  lfs setstripe --count 8 ${workdir}
#fi
cd ${workdir}

# Check to make sure the real input files (e.g. met_em.d01.*) are available
# and make links to them
fcst=0
while [ ${fcst} -le ${FCST_LENGTH} ]; do
  time_str=`${DATE} "+%Y-%m-%d_%H:%M:%S" -d "${START_TIME}  ${fcst} hours"`
  if [ ! -r "${INPUT_DATAHOME}/${real_prefix}.d01.${time_str}${real_suffix}" ]; then
    echo "ERROR: Input file '${INPUT_DATAHOME}/${real_prefix}.d01.${time_str}${real_suffix}' is missing"
    exit 1
  fi
  ${RM} -f ${real_prefix}.d01.${time_str}${real_suffix}
  ${LN} -s ${INPUT_DATAHOME}/${real_prefix}.d01.${time_str}${real_suffix}
  (( fcst = fcst + ${FCST_INTERVAL} ))
done

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

# Copy the wrf namelist to the workdir as namelist.input
${CP} ${STATIC_DIR}/real.nl ${WRF_NAMELIST}

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
${ECHO} "fcst_interval_sec = ${fcst_interval_sec}"
${CAT} ${WRF_NAMELIST} | ${SED} "s/\(${interval}${second}[Ss]\)${equal}[[:digit:]]\{1,\}/\1 = ${fcst_interval_sec}/" \
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

# Get the current time
now=`${DATE} +%Y%m%d%H%M%S`

# Run real
${MPIRUN} ${REAL}
error=$?
if [ ${error} -ne 0 ]; then
  ${ECHO} "ERROR: ${REAL} exited with status: ${error}"
  exit ${error}
else

  # Check to see if the output is there:
  if [ ${FCST_LENGTH} -eq 0 ]; then
    if [ ! -s "wrfinput_d01" ]; then
      ${ECHO} "${REAL} failed to complete"
      exit 1
    fi
  else
    if [ ! -s "wrfbdy_d01" -o ! -s "wrfinput_d01" ]; then
      ${ECHO} "${REAL} failed to complete"
      exit 1
    fi
  fi

  ${ECHO} "real_arw.ksh completed successfully at `${DATE}`"
fi

# Save a copy of the RSL files
rsldir=rsl.real.${now}
${MKDIR} ${rsldir}
mv rsl.out.* ${rsldir}
mv rsl.error.* ${rsldir}

exit 0
