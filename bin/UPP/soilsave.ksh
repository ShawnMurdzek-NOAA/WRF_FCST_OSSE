#!/bin/ksh --login
##########################################################################
#
#Script Name: post.ksh
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
# Purpose: This script post processes wrf output.  It is based on scripts
#          whose authors are unknown.
#
#               EXE_ROOT = The full path of the post executables
#          DATAHOME = Top level directory of wrf output and
#                          configuration data.
#             START_TIME = The cycle time to use for the initial time. 
#                          If not set, the system clock is used.
#              FCST_TIME = The two-digit forecast that is to be posted
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
module load env_upp

# Make sure we are using GMT time zone for time computations
export TZ="GMT"

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
CUT=/bin/cut
AWK="/bin/gawk --posix"
SED=/bin/sed
DATE=/bin/date
BC=/usr/bin/bc

# Print run parameters
${ECHO}
${ECHO} "soilsave.ksh started at `${DATE}`"
${ECHO}
${ECHO} "DATAWRFHOME = ${DATAWRFHOME}"

# Check to make sure that the DATAWRFHOME exists
if [ ! ${DATAWRFHOME} ]; then
  ${ECHO} "ERROR: DATAWRFHOME, \$DATAWRFHOME, is not defined"
  exit 1
fi

# Check to make sure that the DATAROOT exists
if [ ! ${DATAROOT} ]; then
  ${ECHO} "ERROR: DATAROOT, \$DATAROOT, is not defined"
  exit 1
fi

# If START_TIME is not defined, use the current time
if [ ! "${START_TIME}" ]; then
  START_TIME=`${DATE} +"%Y%m%d %H"`
else
  if [ `${ECHO} "${START_TIME}" | ${AWK} '/^[[:digit:]]{10}$/'` ]; then
    START_TIME=`${ECHO} "${START_TIME}" | ${SED} 's/\([[:digit:]]\{2\}\)$/ \1/'`
  elif [ ! "`${ECHO} "${START_TIME}" | ${AWK} '/^[[:digit:]]{8}[[:blank:]]{1}[[:digit:]]{2}$/'`" ]; then
    ${ECHO} "ERROR: start time, '${START_TIME}', is not in 'yyyymmddhh' or 'yyyymmdd hh' format"
    exit 1
  fi
  START_TIME=`${DATE} -d "${START_TIME}"`
fi

# Print out times
${ECHO} "   START TIME = "`${DATE} +%Y%m%d%H -d "${START_TIME}"`
${ECHO} "    FCST_TIME = ${FCST_TIME}"

timestr=`${DATE} +%Y-%m-%d_%H_%M_%S -d "${START_TIME}  ${FCST_TIME} hours"`

# Save files for land surface cycling  and after long outages in full cycle
if [[ ${FCST_TIME} -lt '18' ]]; then
  timeHH=`${DATE} +%H -d "${START_TIME} ${FCST_TIME} hours"`
  ${ECHO} "Copying ${DATAWRFHOME}/wrfout_d01_${timestr} ${DATAROOT}/surface/wrfout_sfc_${timeHH}_temp"
  cp ${DATAWRFHOME}/wrfout_d01_${timestr} ${DATAROOT}/surface/wrfout_sfc_${timeHH}_temp
  mv ${DATAROOT}/surface/wrfout_sfc_${timeHH}_temp ${DATAROOT}/surface/wrfout_sfc_${timeHH}
fi

${ECHO} "soilsave.ksh completed at `${DATE}`"

exit 0
