#!/bin/ksh --login

module load slurm

ulimit -s 512000

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

# Set paths to unix commands
ECHO=/bin/echo
MKDIR=/bin/mkdir
RM=/bin/rm
LN=/bin/ln
LS=/bin/ls
CAT=/bin/cat
CP=/bin/cp
DATE=/bin/date
AWK="/bin/awk --posix"
SED=/bin/sed

# Make sure DATAHOME is defined
if [ ! "${DATAHOME}" ]; then
  ${ECHO} "ERROR: \$DATAHOME is not defined!"
  exit 1
fi

# Make sure START_TIME is defined and in the correct format
if [ ! "${START_TIME}" ]; then
  ${ECHO} "ERROR: \$START_TIME is not defined!"
  exit 1
else
  if [ `${ECHO} "${START_TIME}" | ${AWK} '/^[[:digit:]]{10}$/'` ]; then
    START_TIME=`${ECHO} "${START_TIME}" | ${SED} 's/\([[:digit:]]\{2\}\)$/ \1/'`
  else
    if [ ! "`${ECHO} "${START_TIME}" | ${AWK} '/^[[:digit:]]{8}[[:blank:]]{1}[[:digit:]]{2}$/'`" ]; then
      ${ECHO} "ERROR: start time, '${START_TIME}', is not in 'yyyymmddhh' or 'yyyymmdd hh' format"
      exit 1
    fi
  fi
  START_TIME=`${DATE} -d "${START_TIME}"`
fi

# Make sure PREPBUFR is defined and that the directory exists
if [ ! "${PREPBUFR}" ]; then
  ${ECHO} "ERROR: \$PREPBUFR is not defined"
  exit 1
fi
if [ ! -d "${PREPBUFR}" ]; then
  ${ECHO} "ERROR: directory '${PREPBUFR}' does not exist!"
  exit 1
fi
if [ ! "${PREPBUFR_SAT}" ]; then
  ${ECHO} "ERROR: \$PREPBUFR_SAT is not defined"
  exit 1
fi
if [ ! -d "${PREPBUFR_SAT}" ]; then
  ${ECHO} "ERROR: directory '${PREPBUFR_SAT}' does not exist!"
  exit 1
fi
if [ ! "${EARLY}" ]; then
  ${ECHO} "ERROR: \$EARLY is not defined"
  exit 1
fi

# Create the obsprd directory if necessary and cd into it
if [ ! -d "${DATAHOME}" ]; then
  ${MKDIR} -p ${DATAHOME}
fi
cd ${DATAHOME}

# Compute date & time components for prepbufr filename
YYYYMMDD=`${DATE} +"%Y%m%d" -d "${START_TIME}"`
YYYYMMDDHH=`${DATE} +"%Y%m%d%H" -d "${START_TIME}"`
YYYYJJJHH00=`${DATE} +"%Y%j%H00" -d "${START_TIME}"`
YYYYJJJHH=`${DATE} +"%Y%j%H" -d "${START_TIME}"`
PREYYJJJHH=`${DATE} +"%y%j%H" -d "${START_TIME} 1 hour ago"`
YYJJJHH=`${DATE} +"%y%j%H" -d "${START_TIME}"`
YYYY=`${DATE} +"%Y" -d "${START_TIME}"`
MM=`${DATE} +"%m" -d "${START_TIME}"`
DD=`${DATE} +"%d" -d "${START_TIME}"`
HH=`${DATE} +"%H" -d "${START_TIME}"`

# Copy the prepbufr to obs directory so we never do I/O to /public directly
if [ ${EARLY} -eq 0 ]; then
  if [ -r "${PREPBUFR}_test/${YYYYMMDDHH}.rap.t${HH}z.prepbufr.tm00.test" ]; then
    ${CP} ${PREPBUFR}_test/${YYYYMMDDHH}.rap.t${HH}z.prepbufr.tm00.test ./${YYYYJJJHH00}.rap.t${HH}z.prepbufr.tm00.${YYYYMMDD}.test
    ${LN} -s ${YYYYJJJHH00}.rap.t${HH}z.prepbufr.tm00.${YYYYMMDD}.test prepbufr
    ${LN} -s ${YYYYMMDDHH}.rap.t${HH}z.prepbufr.tm00.test newgblav.${YYYYMMDD}.rap.t${HH}z.prepbufr
  else
    if [ -r "${PREPBUFR}/${YYYYMMDDHH}.rap.t${HH}z.prepbufr.tm00" ]; then
      ${ECHO} "Warning: ${YYYYMMDDHH}.rap.t${HH}z.prepbufr.tm00.test does not exist!"
      ${CP} ${PREPBUFR}/${YYYYMMDDHH}.rap.t${HH}z.prepbufr.tm00 ./${YYYYJJJHH00}.rap.t${HH}z.prepbufr.tm00.${YYYYMMDD}
      ${LN} -s ${YYYYJJJHH00}.rap.t${HH}z.prepbufr.tm00.${YYYYMMDD} prepbufr
      ${LN} -s ${YYYYMMDDHH}.rap.t${HH}z.prepbufr.tm00 newgblav.${YYYYMMDD}.rap.t${HH}z.prepbufr
    else
      ${ECHO} "Warning: ${YYYYMMDDHH}.rap.t${HH}z.prepbufr.tm00 does not exist!"
      ${ECHO} "ERROR: No prepbufr files exist!"
      exit 1
    fi
  fi
else
  if [ ${EARLY} -eq 1 ]; then
    if [ -r "${PREPBUFR}_test/${YYYYMMDDHH}.rap_e.t${HH}z.prepbufr.tm00.test" ]; then
      ${CP} ${PREPBUFR}_test/${YYYYMMDDHH}.rap_e.t${HH}z.prepbufr.tm00.test ./${YYYYJJJHH00}.rap_e.t${HH}z.prepbufr.tm00.${YYYYMMDD}.test
      ${LN} -s ${YYYYJJJHH00}.rap_e.t${HH}z.prepbufr.tm00.${YYYYMMDD}.test prepbufr
      ${LN} -s ${YYYYMMDDHH}.rap_e.t${HH}z.prepbufr.tm00.test newgblav.${YYYYMMDD}.rap.t${HH}z.prepbufr
    else
      if [ -r "${PREPBUFR}/${YYYYMMDDHH}.rap_e.t${HH}z.prepbufr.tm00" ]; then
        ${CP} ${PREPBUFR}/${YYYYMMDDHH}.rap_e.t${HH}z.prepbufr.tm00 ./${YYYYJJJHH00}.rap_e.t${HH}z.prepbufr.tm00.${YYYYMMDD}
        ${LN} -s ${YYYYJJJHH00}.rap_e.t${HH}z.prepbufr.tm00.${YYYYMMDD} prepbufr
        ${LN} -s ${YYYYMMDDHH}.rap_e.t${HH}z.prepbufr.tm00 newgblav.${YYYYMMDD}.rap.t${HH}z.prepbufr
      else
        ${ECHO} "Warning: ${YYYYMMDDHH}.rap_e.t${HH}z.prepbufr.tm00 does not exist!"
        ${ECHO} "ERROR: No prepbufr files exist!"
        exit 1
      fi
    fi
  else
    ${ECHO} "ERROR: EARLY ${EARLY} is not defined or invalid"
    exit 1
  fi
fi

# Set links to radiance data if available
if [ -r "${PREPBUFR_SAT}/${YYYYJJJHH00}.rap.t${HH}z.1bamua.tm00.bufr_d.${YYYYMMDD}" ]; then
  ${CP} ${PREPBUFR_SAT}/${YYYYJJJHH00}.rap.t${HH}z.1bamua.tm00.bufr_d.${YYYYMMDD} .
  ${LN} -s ${YYYYJJJHH00}.rap.t${HH}z.1bamua.tm00.bufr_d.${YYYYMMDD} newgblav.${YYYYMMDD}.rap.t${HH}z.1bamua
else
  ${ECHO} "Warning: ${PREPBUFR_SAT}/${YYYYJJJHH00}.rap.t${HH}z.1bamua.tm00.bufr_d.${YYYYMMDD} dones not exist!"
fi

if [ -r "${PREPBUFR_SAT}/${YYYYJJJHH00}.rap.t${HH}z.1bamub.tm00.bufr_d.${YYYYMMDD}" ]; then
  ${CP} ${PREPBUFR_SAT}/${YYYYJJJHH00}.rap.t${HH}z.1bamub.tm00.bufr_d.${YYYYMMDD} .
  ${LN} -s ${YYYYJJJHH00}.rap.t${HH}z.1bamub.tm00.bufr_d.${YYYYMMDD} newgblav.${YYYYMMDD}.rap.t${HH}z.1bamub
else
  ${ECHO} "Warning: ${PREPBUFR_SAT}/${YYYYJJJHH00}.rap.t${HH}z.1bamub.tm00.bufr_d.${YYYYMMDD} dones not exist!"
fi

if [ -r "${PREPBUFR_SAT}/${YYYYJJJHH00}.rap.t${HH}z.1bhrs3.tm00.bufr_d.${YYYYMMDD}" ]; then
  ${CP} ${PREPBUFR_SAT}/${YYYYJJJHH00}.rap.t${HH}z.1bhrs3.tm00.bufr_d.${YYYYMMDD} .
  ${LN} -s ${YYYYJJJHH00}.rap.t${HH}z.1bhrs3.tm00.bufr_d.${YYYYMMDD} newgblav.${YYYYMMDD}.rap.t${HH}z.1bhrs3
else
  ${ECHO} "Warning: ${PREPBUFR_SAT}/${YYYYJJJHH00}.rap.t${HH}z.1bhrs3.tm00.bufr_d.${YYYYMMDD} dones not exist!"
fi

if [ -r "${PREPBUFR_SAT}/${YYYYJJJHH00}.rap.t${HH}z.1bhrs4.tm00.bufr_d.${YYYYMMDD}" ]; then
  ${CP} ${PREPBUFR_SAT}/${YYYYJJJHH00}.rap.t${HH}z.1bhrs4.tm00.bufr_d.${YYYYMMDD} .
  ${LN} -s ${YYYYJJJHH00}.rap.t${HH}z.1bhrs4.tm00.bufr_d.${YYYYMMDD} newgblav.${YYYYMMDD}.rap.t${HH}z.1bhrs4
else
  ${ECHO} "Warning: ${PREPBUFR_SAT}/${YYYYJJJHH00}.rap.t${HH}z.1bhrs4.tm00.bufr_d.${YYYYMMDD} dones not exist!"
fi

if [ -r "${PREPBUFR_SAT}/${YYYYJJJHH00}.rap.t${HH}z.1bmhs.tm00.bufr_d.${YYYYMMDD}" ]; then
  ${CP} ${PREPBUFR_SAT}/${YYYYJJJHH00}.rap.t${HH}z.1bmhs.tm00.bufr_d.${YYYYMMDD} .
  ${LN} -s ${YYYYJJJHH00}.rap.t${HH}z.1bmhs.tm00.bufr_d.${YYYYMMDD} newgblav.${YYYYMMDD}.rap.t${HH}z.1bmhs
else
  ${ECHO} "Warning: ${PREPBUFR_SAT}/${YYYYJJJHH00}.rap.t${HH}z.1bmhs.tm00.bufr_d.${YYYYMMDD} dones not exist!"
fi

# Radial velocity included
if [ -r "${RADVELLEV2_DIR}/${YYYYJJJHH00}.rap.t${HH}z.nexrad.tm00.bufr_d" ]; then
  ${CP} ${RADVELLEV2_DIR}/${YYYYJJJHH00}.rap.t${HH}z.nexrad.tm00.bufr_d .
  ${LN} -s ${YYYYJJJHH00}.rap.t${HH}z.nexrad.tm00.bufr_d newgblav.${YYYYMMDD}.rap.t${HH}z.nexrad
else
  ${ECHO} "Warning: ${RADVELLEV2_DIR}/${YYYYJJJHH00}.rap.t${HH}z.nexrad.tm00.bufr_d does not exist!"
fi

if [ -r "${RADVELLEV2P5_DIR}/${YYYYJJJHH00}.rap.t${HH}z.radwnd.tm00.bufr_d" ]; then
  ${CP} ${RADVELLEV2P5_DIR}/${YYYYJJJHH00}.rap.t${HH}z.radwnd.tm00.bufr_d .
  ${LN} -s ${YYYYJJJHH00}.rap.t${HH}z.radwnd.tm00.bufr_d newgblav.${YYYYMMDD}.rap.t${HH}z.radwnd
else
  ${ECHO} "Warning: ${RADVELLEV2P5_DIR}/${YYYYJJJHH00}.rap.t${HH}z.radwnd.tm00.bufr_d does not exist!"
fi

#  AMV wind
if [ -r "${SATWND_DIR}/${YYYYJJJHH00}.rap.t${HH}z.satwnd.tm00.bufr_d" ]; then
  ${CP} ${SATWND_DIR}/${YYYYJJJHH00}.rap.t${HH}z.satwnd.tm00.bufr_d .
  ${LN} -s ${YYYYJJJHH00}.rap.t${HH}z.satwnd.tm00.bufr_d newgblav.${YYYYMMDD}.rap.t${HH}z.satwnd
else
  ${ECHO} "Warning: ${SATWND_DIR}/${YYYYJJJHH00}.rap.t${HH}z.satwnd.tm00.bufr_d does not exist!"
fi

#  Lightning obs 
if [ -r "${BUFRLIGHTNING}/${YYYYMMDDHH}.rap.t${HH}z.lghtng.tm00.bufr_d" ]; then
  ${CP} ${BUFRLIGHTNING}/${YYYYMMDDHH}.rap.t${HH}z.lghtng.tm00.bufr_d .
  ${LN} -s ${YYYYMMDDHH}.rap.t${HH}z.lghtng.tm00.bufr_d newgblav.${YYYYMMDD}.rap.t${HH}z.lghtng
else
  ${ECHO} "Warning: ${BUFRLIGHTNING}/${YYYYMMDDHH}.rap.t${HH}z.lghtng.tm00.bufr_d does not exist!"
fi

# TC vitals
if [ -r "${TCVITALS_DIR}/${YYYYMMDDHH}00.tcvitals" ]; then
  ${CP} ${TCVITALS_DIR}/${YYYYMMDDHH}00.tcvitals .
  ${LN} -s ${YYYYMMDDHH}00.tcvitals newgblav.${YYYYMMDD}.tcvitals.t${HH}z
else
  ${ECHO} "Warning: ${TCVITALS_DIR}/${YYYYMMDDHH}00.tcvitals does not exist!"
fi

# Add nacelle, tower and sodar observations if available
if [ -r "${NACELLE_RSD}/${YYJJJHH}000010o" ]; then
  ${LN} -s ${NACELLE_RSD}/${YYJJJHH}000010o ./nacelle_restriced.nc
  ${CP} ${GSI_ROOT}/process_nacelledata_rt.exe .
  ./process_nacelledata_rt.exe > stdout_nacelledata
  ${RM} -f nacelle_restriced.nc
else
  ${ECHO} "Warning: ${NACELLE_RSD}/${YYJJJHH}000010o does not exist!"
fi

if [ -r "${TOWER_RSD}/${YYJJJHH}000010o" ]; then
  ${LN} -s ${TOWER_RSD}/${YYJJJHH}000010o ./tower_restricted.nc
  ${LN} -s ${TOWER_RSD}/${YYJJJHH}000010o ./tower_data.nc
  ${CP} ${GSI_ROOT}/process_towerdata_rt.exe .
  ./process_towerdata_rt.exe > stdout_tower_re
  ${RM} -f tower_restricted.nc
  ${RM} -f tower_data.nc
else
  ${ECHO} "Warning: ${TOWER_RSD}/${YYJJJHH}000010o does not exist!"
fi

if [ -r "${TOWER_NRSD}/${YYJJJHH}000100o" ]; then
  ${LN} -s ${TOWER_NRSD}/${YYJJJHH}000100o ./tower_public.nc
  ${LN} -s ${TOWER_NRSD}/${YYJJJHH}000100o ./tower_data.nc
  ${CP} ${GSI_ROOT}/process_towerdata_rt.exe .
  ./process_towerdata_rt.exe > stdout_tower_nr
  ${RM} -f tower_public.nc
  ${RM} -f tower_data.nc
else
  ${ECHO} "Warning: ${TOWER_NRSD}/${YYJJJHH}000100o does not exist!"
fi

if [ -r "${SODAR_NRSD}/${YYJJJHH}000015o" ]; then
  ${LN} -s ${SODAR_NRSD}/${YYJJJHH}000015o ./sodar_data.nc
  ${CP} ${GSI_ROOT}/process_sodardata_rt.exe .
  ./process_sodardata_rt.exe > stdout_sodar_nr
  ${RM} -f sodar_data.nc
else
  ${ECHO} "Warning: ${SODAR_NRSD}/${YYJJJHH}000015o does not exist!"
fi

exit 0
