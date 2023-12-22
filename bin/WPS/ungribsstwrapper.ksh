#!/bin/ksh --login
##########################################################################
#
#Script Name: sstungribwrapper_retro.ksh
# 
#     Author: Christopher Harrop
#             Forecast Systems Laboratory
#             325 Broadway R/FST
#             Boulder, CO. 80305
#
#   Released: 7/10/2006
#    Version: 1.0
#    Changes: None
#
# Purpose:  This script calculates the start time that corresponds to the
#           sst file which is named according to the start time passed in to
#           the script. It then calls ungrib.ksh with that time assigned to 
#           START_TIME in order to process it.
#
#               EXE_ROOT = Location of the wgrib binary and the ungrib.ksh script
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

# Make sure we are using GMT time zone for time computations
export TZ="GMT"

LS=/bin/ls
LN=/bin/ln
RM=/bin/rm
AWK="/bin/gawk --posix"
SED=/bin/sed
ECHO=/bin/echo
CUT=`which cut`
DATE=/bin/date

# Make sure START_TIME is defined
if [ ! "${START_TIME}" ]; then
  ${ECHO} "ERROR: \$START_TIME was not specified"
  exit 1
fi

# Make sure START_TIME is in the correct format
if [ `${ECHO} "${START_TIME}" | ${AWK} '/^[[:digit:]]{10}$/'` ]; then
  START_TIME=`${ECHO} "${START_TIME}" | ${SED} 's/\([[:digit:]]\{2\}\)$/ \1/'`
elif [ ! "`${ECHO} "${START_TIME}" | ${AWK} '/^[[:digit:]]{8}[[:blank:]]{1}[[:digit:]]{2}$/'`" ]; then
  ${ECHO} "ERROR: start time, '${START_TIME}', is not in 'yyyymmddhh' or 'yyyymmdd hh' format"
  exit 1
fi
START_TIME=`${DATE} -d "${START_TIME}"`

# Make sure SCRIPTS is defined
if [ ! "${SCRIPTS}" ]; then
  ${ECHO} "ERROR: \$SCRIPTS was not specified"
  exit 1
fi

# Calculate the name of the SST file we are going to use
SSTFILE="${SOURCE_PATH}/${FORMAT}"

${ECHO} "    START_TIME = `${DATE} +"%Y%m%d %H" -d "${START_TIME}"`"
${ECHO} "       SSTFILE = ${SSTFILE}"
${ECHO} "        FORMAT = `basename ${SSTFILE}`"

# Calculate the actual start time to pass to ungrib.ksh based on data in the SST file
LATEST_CYCLE=`${WGRIB} ${SSTFILE} | ${CUT} -d":" -f 3 | ${CUT} -d"=" -f 2`
YYYY=`${ECHO} ${LATEST_CYCLE} | ${CUT} -c1-4`
MM=`${ECHO} ${LATEST_CYCLE} | ${CUT} -c5-6`
DD=`${ECHO} ${LATEST_CYCLE} | ${CUT} -c7-8`
HH=`${ECHO} ${LATEST_CYCLE} | ${CUT} -c9-10`
START_TIME=`${DATE} +"%Y%m%d %H" -d "${MM}/${DD}/${YYYY} ${HH}:00:00"`

${ECHO} "SST START_TIME = ${START_TIME}"
${ECHO}

# Call ungrib.ksh
${SCRIPTS}/ungrib.ksh
error=$?
if [ ${error} -ne 0 ]; then
  ${ECHO} "ERROR: ungrib.ksh crashed  Exit status=${error}"
  exit ${error}
fi

# Make a link to the SST file 
cd  ${DATAHOME}
${RM} -f SST
${LN} -s SST:`${DATE} +"%Y-%m-%d_%H" -d "${START_TIME}"` SST
mkdir -p ${DATAHOME_BDY}
cd ${DATAHOME_BDY}
${RM} -f SST
${LN} -s ${DATAHOME}/SST:`${DATE} +"%Y-%m-%d_%H" -d "${START_TIME}"` SST

exit 0
