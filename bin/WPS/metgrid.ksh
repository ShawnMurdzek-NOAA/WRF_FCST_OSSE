#!/bin/ksh --login
##########################################################################
#
#Script Name: metgrid.ksh
# 
#     Author: Christopher Harrop
#             Forecast Systems Laboratory
#             325 Broadway R/FST
#             Boulder, CO. 80305
#
#   Released: 10/30/2003
#    Version: 1.0
#    Changes: None
#
# Purpose: This is a complete rewrite of the metgrid portion of the 
#          wrfprep.pl script that is distributed with the WRF Standard 
#          Initialization.  This script may be run on the command line, or 
#          it may be submitted directly to a batch queueing system.  A few 
#          environment variables must be set before it is run:
#
#           INSTALL_ROOT = Location of compiled wrfsi binaries and scripts.
#          DATAROOT = Top level directory of wrf domain configuration data.
#          DATAHOME = Top level directory of wrf output
#            FCST_LENGTH = The length of the forecast in hours.  If not set,
#                          the default value of 48 is used.
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

# Load modules
module purge
module use ${ENV_DIR}
module load env_wps
module list
echo "NETCDF = ${NETCDF}"

# Necessary on Hercules to avoid crashes
ulimit -s unlimited
ulimit -a

# Make sure we are using GMT time zone for time computations
export TZ="GMT"

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
MPIRUN="srun"

# Set up some constants
export WPSNAMELIST=${DATAHOME}/namelist.wps
export METGRID=${WPS_ROOT}/metgrid.exe

# Print run parameters
${ECHO}
${ECHO} "metgrid.ksh started at `${DATE}`"
${ECHO}
${ECHO} "    WPS_ROOT  = ${WPS_ROOT}"
${ECHO} "DATAROOT = ${DATAROOT}"
${ECHO} "DATAHOME = ${DATAHOME}"
${ECHO}

# Check to make sure that WPS_ROOT exists
if [ ! -d ${WPS_ROOT} ]; then
  ${ECHO} "ERROR: ${WPS_ROOT} does not exist"
  exit 1
fi

# Check to make sure the metgrid executable exists
if [ ! -x ${METGRID} ]; then
  ${ECHO} "ERROR: ${METGRID} does not exist, or is not executable"
  exit 1
fi

# Check to make sure that the DATAROOT exists
if [ ! -d ${DATAROOT} ]; then
  ${ECHO} "ERROR: ${DATAROOT} does not exist"
  exit 1
fi

# Check to make sure the source path has been specified
##if [ ! "${SOURCE_PATH}" ]; then
##  ${ECHO} "ERROR: The data source path has not been specified"
##  exit 1
##fi

# Check to make sure the namelist exists
if [ ! -r ${STATIC_DIR}/namelist.wps ]; then
  ${ECHO} "ERROR: ${STATIC_DIR}/namelist.wps does not exist, or is not readable"
  exit 1
fi

# Check to make sure START_TIME was specified
if [ ! "${START_TIME}" ]; then
  ${ECHO} "ERROR: \$START_TIME is not defined!"
  exit 1
fi

# Get the forecast length
if [ ! "${FCST_LENGTH}" ]; then
  ${ECHO} "ERROR: \$FCST_LENGTH is not defined!"
  exit 1
fi

# Get the forecast interval
if [ ! "${FCST_INTERVAL}" ]; then
  ${ECHO} "ERROR: \$FCST_INTERVAL is not defined!"
  exit 1
fi

# Make sure the START_TIME is in the correct format
if [ `${ECHO} "${START_TIME}" | ${AWK} '/^[[:digit:]]{10}$/'` ]; then
  START_TIME=`${ECHO} "${START_TIME}" | ${SED} 's/\([[:digit:]]\{2\}\)$/ \1/'`
elif [ ! "`${ECHO} "${START_TIME}" | ${AWK} '/^[[:digit:]]{8}[[:blank:]]{1}[[:digit:]]{2}$/'`" ]; then
  ${ECHO} "ERROR: start time, '${START_TIME}', is not in 'yyyymmddhh' or 'yyyymmdd hh' format"
  exit 1
fi

# Calculate start and end time date strings
START_TIME=`${DATE} -d "${START_TIME}"`
END_TIME=`${DATE} -d "${START_TIME}  ${FCST_LENGTH} hours"`
start_yyyymmdd_hhmmss=`${DATE} +%Y-%m-%d_%H:%M:%S -d "${START_TIME}"`
end_yyyymmdd_hhmmss=`${DATE} +%Y-%m-%d_%H:%M:%S -d "${END_TIME}"`

# Calculate the forecast interval in seconds
(( fcst_interval_sec = ${FCST_INTERVAL} * 3600 ))

# Print the forecast length, interval, start time, and end time
${ECHO} "START TIME    = "`${DATE} +"%Y/%m/%d %H:%M:%S" -d "${START_TIME}"`
${ECHO} "  END TIME    = "`${DATE} +"%Y/%m/%d %H:%M:%S" -d "${END_TIME}"`
${ECHO} "FCST LENGTH   = ${FCST_LENGTH}"
${ECHO} "FCST INTERVAL = ${FCST_INTERVAL}"
${ECHO}

# Create (if necessary) and cd to workdir
workdir=${DATAHOME}
${MKDIR} -p ${workdir}
cd ${workdir}

# Copy the namelist to the static dir
${CP} ${STATIC_DIR}/namelist.wps ${WPSNAMELIST}

# Link to geogrid static files
${RM} -f geo_*.d01.nc
${LN} -s ${STATIC_DIR}/geo_*.d01.nc .

# Create patterns for updating the namelist
equal=[[:blank:]]*=[[:blank:]]*
start=[Ss][Tt][Aa][Rr][Tt]
end=[Ee][Nn][Dd]
date=[Dd][Aa][Tt][Ee]
interval=[Ii][Nn][Tt][Ee][Rr][Vv][Aa][Ll]
seconds=[Ss][Ee][Cc][Oo][Nn][Dd][Ss]
prefix=[Pp][Rr][Ee][Ff][Ii][Xx]
fg_name=[Ff][Gg][_][Nn][Aa][Mm][Ee]
constants_name=[Cc][Oo][Nn][Ss][Tt][Aa][Nn][Tt][Ss][_][Nn][Aa][Mm][Ee]
opt_metgrid_tbl_path=[Oo][Pp][Tt][_][Mm][Ee][Tt][Gg][Rr][Ii][Dd][_][Tt][Bb][Ll][_][Pp][Aa][Tt][Hh]
yyyymmdd_hhmmss='[[:digit:]]\{4\}-[[:digit:]]\{2\}-[[:digit:]]\{2\}_[[:digit:]]\{2\}:[[:digit:]]\{2\}:[[:digit:]]\{2\}'

# Update the start and end date in namelist
${CAT} ${WPSNAMELIST} | ${SED} "s/\(${start}_${date}\)${equal}'${yyyymmdd_hhmmss}'/\1 = '${start_yyyymmdd_hhmmss}'/" \
                      | ${SED} "s/\(${end}_${date}\)${equal}'${yyyymmdd_hhmmss}'/\1 = '${end_yyyymmdd_hhmmss}'/"     \
                      > ${WPSNAMELIST}.new
${MV} ${WPSNAMELIST}.new ${WPSNAMELIST}

# Update interval in namelist
${CAT} ${WPSNAMELIST} | ${SED} "s/\(${interval}_${seconds}\)${equal}[[:digit:]]\{1,\}/\1 = ${fcst_interval_sec}/" \
                      > ${WPSNAMELIST}.new 
${MV} ${WPSNAMELIST}.new ${WPSNAMELIST}

# Update fg_name if SOURCE is defined
if [ "${SOURCE}" ]; then

  # Format the SOURCE string so it looks like: 'xxx','yyy',...,'zzz',
  source_str=`${ECHO} ${SOURCE} | ${SED} "s/\([^',]*\),*/'\1',/g"`

  # Update fg_name
  ${CAT} ${WPSNAMELIST} | ${SED} "s/\(${fg_name}\)${equal}.*/\1 = ${source_str}/" \
                        > ${WPSNAMELIST}.new
  ${MV} ${WPSNAMELIST}.new ${WPSNAMELIST}

fi

# Update constants_name if CONSTANTS is defined
if [ "${CONSTANTS}" ]; then

  # Format the CONSTANTS string so it looks like: 'xxx','yyy',...,'zzz',
  constants_str=`${ECHO} ${CONSTANTS} | ${SED} "s/\([^',]*\),*/'\1',/g"`

  # Update constants_name
  ${CAT} ${WPSNAMELIST} | ${SED} "s/\(${constants_name}\)${equal}.*/\1 = ${constants_str}/" \
                        > ${WPSNAMELIST}.new
  ${MV} ${WPSNAMELIST}.new ${WPSNAMELIST}

fi

# Update METGRID TBL file, it it exists
if [ -f "${STATIC_DIR}/METGRID.TBL" ]; then

  # Format the STATIC_DIR string so it looks like: 'xxx','yyy',...,'zzz',
  static_dir_str=`${ECHO} ${STATIC_DIR} | ${SED} "s/\([^',]*\),*/'\1',/g"`

  # Update METGRID TBL path (note that the delimiter needs to be changed b/c static_dir_str contains
  # the / character
  ${CAT} ${WPSNAMELIST} | ${SED} "s-\(${opt_metgrid_tbl_path}\)${equal}.*-\1 = ${static_dir_str}-" \
                        > ${WPSNAMELIST}.new
  ${MV} ${WPSNAMELIST}.new ${WPSNAMELIST}

fi

# Get the start and end time components
#start_year=`${DATE} +%Y -d "${START_TIME}"`
#start_month=`${DATE} +%m -d "${START_TIME}"`
#start_day=`${DATE} +%d -d "${START_TIME}"`
#start_hour=`${DATE} +%H -d "${START_TIME}"`
#start_minute=`${DATE} +%M -d "${START_TIME}"`
#start_second=`${DATE} +%S -d "${START_TIME}"`
#end_year=`${DATE} +%Y -d "${END_TIME}"`
#end_month=`${DATE} +%m -d "${END_TIME}"`
#end_day=`${DATE} +%d -d "${END_TIME}"`
#end_hour=`${DATE} +%H -d "${END_TIME}"`
#end_minute=`${DATE} +%M -d "${END_TIME}"`
#end_second=`${DATE} +%S -d "${END_TIME}"`


# Create a poor man's namelist hash
#
# Strip off comments, section names, slashes, and remove white space.
# Then loop over each line to create an array of names, an array of
# values, and variables that contain the index of the names in the
# array of names.  Each variable that contains an index of a namelist
# name is named $_NAME_ where 'NAME' is one of the names in the namelist
# The $_NAME_ vars are always capitalized even if the names in the namelist
# are not.
i=-1
for name in `${SED} 's/[[:blank:]]//g' ${WPSNAMELIST} | ${AWK} '/^[^#&\/]/'`
do
  # If there's an = in the line
  if [ `${ECHO} ${name} | ${AWK} /=/` ]; then
    (( i=i+1 ))
    left=`${ECHO} ${name} | ${CUT} -d"=" -f 1 | ${AWK} '{print toupper($0)}'`
    right=`${ECHO} ${name} | ${CUT} -d"=" -f 2`
    val[${i}]=${right}
    (( _${left}_=${i} ))
  else
    val[${i}]=${val[${i}]}${name}
  fi
done

# Get an array of fg_names from the namelist
set -A source_list `${ECHO} ${val[${_FG_NAME_}]} | ${SED} "s/[',]\{1,\}/ /g"`

# Get an array of constants_names from the namelist
set -A constant_list `${ECHO} ${val[${_CONSTANTS_NAME_}]} | ${SED} "s/[',]\{1,\}/ /g"`

# Make sure SOURCE_PATH is defined if source_list is not empty
if [ ${#source_list[*]} -gt 0 ]; then
  if [ ! "${SOURCE_PATH}" ]; then
    ${ECHO} "ERROR: fg_name is not empty, but \$SOURCE_PATH is not defined!"
    exit 1
  fi

  # Create an array of SOURCE PATHS
  set -A source_path_list `${ECHO} ${SOURCE_PATH} | ${SED} "s/[',]\{1,\}/ /g"`

  # Make sure source_list and source_path_list are the same length
  if [ ${#source_list[*]} -ne ${#source_path_list[*]} ]; then
    ${ECHO} "ERROR: The number of paths in \$SOURCE_PATH does not match the number of sources in fg_name"
    exit 1
  fi  

fi

# Make sure CONSTANT_PATH is defined if constant_list is not empty
if [ ${#constant_list[*]} -gt 0 ]; then
  if [ ! "${CONSTANT_PATH}" ]; then
    ${ECHO} "ERROR: constants_name is not empty, but \$CONSTANT_PATH is not defined!"
    exit 1
  fi

  # Create an array of CONSTANT PATHS
  set -A constant_path_list `${ECHO} ${CONSTANT_PATH} | ${SED} "s/[',]\{1,\}/ /g"`

  # Make sure constant_list and constant_path_list are the same length
  if [ ${#constant_list[*]} -ne ${#constant_path_list[*]} ]; then
    ${ECHO} "ERROR: The number of paths in \$CONSTANT_PATH does not match the number of constants in constants_name"
    exit 1
  fi  

fi

# Create links to all the fg_name sources
i=0
for src in ${source_list[*]}; do
  fcst=0
  while [ ${fcst} -le ${FCST_LENGTH} ]; do
    datestr=`${DATE} +"%Y-%m-%d_%H" -d "${START_TIME}  ${fcst} hours"`
    ${RM} -f ${src}:${datestr}
    if [ -e ${source_path_list[${i}]}/${src}:${datestr} ]; then
      ${LN} -s ${source_path_list[${i}]}/${src}:${datestr}
    fi
    (( fcst=fcst+${FCST_INTERVAL} ))
  done
  (( i=i+1 ))
done

# Create linkes to all the constants_name constant files
i=0
for const in ${constant_list[*]}; do
  ${RM} -f ${const}
  if [ -e ${constant_path_list[${i}]}/${const} ]; then
    ${LN} -s ${constant_path_list[${i}]}/${const}
  else
    ${ECHO} "WARNING: Constant file ${constant_path_list[${i}]}/${const} does not exist!"
  fi
  (( i=i+1 ))
done

# Get the WRF core
core=`${ECHO} ${val[${_WRF_CORE_}]} | ${SED} "s/[',]\{1,\}//g"`

# Get the metgrid output format
output_format=`${ECHO} ${val[${_IO_FORM_METGRID_}]} | ${SED} "s/[',]\{1,\}//g"`

# Set core specific variables
if [ "${core}" == "ARW" ]; then
  metgrid_prefix="met_em"
elif [ "${core}" == "NMM" ]; then
  metgrid_prefix="met_nmm"
else
  ${ECHO} "ERROR: WRF Core, ${core}, is not supported!"
  exit 1
fi

# Set the output file suffix
if [ ${output_format} -eq 2 ]; then
  metgrid_suffix=".nc"
else
  metgrid_suffix=""
fi

# Remove pre-existing metgrid files
fcst=0
while [ ${fcst} -le ${FCST_LENGTH} ]; do
  time_str=`${DATE} +%Y-%m-%d_%H:%M:%S -d "${START_TIME}  ${fcst} hours"`
  ${RM} -f ${metgrid_prefix}.d01.${time_str}${metgrid_suffix}
  (( fcst=${fcst} + ${FCST_INTERVAL} ))
done

# Run metgrid
/usr/bin/time ${MPIRUN} ${METGRID}
error=$?
if [ ${error} -ne 0 ]; then
  ${ECHO} "ERROR: ${METGRID} exited with status: ${error}"
  exit ${error}
else

  # Check to see if the output is there:
  fcst=0
  while [ ${fcst} -le ${FCST_LENGTH} ]; do
    time_str=`${DATE} +%Y-%m-%d_%H:%M:%S -d "${START_TIME}  ${fcst} hours"`
    if [ ! -e "${metgrid_prefix}.d01.${time_str}${metgrid_suffix}" ]; then
      ${ECHO} "${METGRID} failed to complete"
      exit 1
    fi
    (( fcst=${fcst} + ${FCST_INTERVAL} ))
  done

  ${ECHO} "metgrid.ksh completed successfully at `${DATE}`"
fi

exit 0
