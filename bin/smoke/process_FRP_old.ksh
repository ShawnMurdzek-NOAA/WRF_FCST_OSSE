#!/bin/ksh --login

np=`cat $PBS_NODEFILE | wc -l`

# Load modules
source ${MODULE_FILE}

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
CNVGRIB=${EXE_ROOT}/cnvgrib.exe
CNVOPTS='-g12 -p32'

# Print run parameters
${ECHO}
${ECHO} "process_FRP.ksh started at `${DATE}`"
${ECHO}
${ECHO} "DATAHOME = ${DATAHOME}"
${ECHO} "DATAHOME_RAW = ${DATAHOME_RAW}"
${ECHO} "DATAHOME_PROC = ${DATAHOME_PROC}"
${ECHO} "VIIRS_ROOT = ${VIIRS_ROOT}"
${ECHO} "MODIS_ROOT = ${MODIS_ROOT}"
${ECHO} "NOAA20_ROOT = ${NOAA20_ROOT}"
${ECHO} "START_TIME = ${START_TIME}"
${ECHO} "START_JULIAN = ${START_JULIAN}"
${ECHO} "MCD_FILE = ${MCD_FILE}"
${ECHO} "BIOME_FILE = ${BIOME_FILE}"
${ECHO} "RNPP_EXEC = ${RNPP_EXEC}"
${ECHO} "RMODIS_EXEC = ${RMODIS_EXEC}"
${ECHO} "RNOAA20_EXEC = ${RNOAA20_EXEC}"
${ECHO} "FRP_EXEC = ${FRP_EXEC}"
${ECHO} "BBM_EXEC = ${BBM_EXEC}"

# Check to make sure that the DATAHOME exists
if [ ! ${DATAHOME} ]; then
  ${ECHO} "ERROR: DATAHOME, \$DATAHOME, is not defined"
  exit 1
fi

# Check to make sure that the DATAHOME_RAW exists
if [ ! ${DATAHOME_RAW} ]; then
  ${ECHO} "ERROR: DATAHOME_RAW, \$DATAHOME_RAW, is not defined"
  exit 1
fi

# Check to make sure that the DATAHOME_PROC exists
if [ ! ${DATAHOME_PROC} ]; then
  ${ECHO} "ERROR: DATAHOME_PROC, \$DATAHOME_PROC, is not defined"
  exit 1
fi

# Check to make sure that the VIIRS_ROOT directory exists
if [ ! ${VIIRS_ROOT} ]; then
  ${ECHO} "ERROR: VIIRS_ROOT, \$VIIRS_ROOT, is not defined"
  exit 1
fi

# Check to make sure that the MODIS_ROOT directory exists
if [ ! ${MODIS_ROOT} ]; then
  ${ECHO} "ERROR: MODIS_ROOT, \$MODIS_ROOT, is not defined"
  exit 1
fi

# Check to make sure that the NOAA20_ROOT directory exists
if [ ! ${NOAA20_ROOT} ]; then
  ${ECHO} "ERROR: NOAA20_ROOT, \$NOAA20_ROOT, is not defined"
  exit 1
fi

# Check to make sure that the START_TIME is defined and in the correct format
if [ ! "${START_TIME}" ]; then
  ${ECHO} "ERROR: START_TIME, \$START_TIME, is not defined"
  exit 1
fi

# Convert START_TIME from 'YYYYMMDDHH' format to Unix date format, e.g. "Fri May  6 19:50:23 GMT 2005"
if [ `${ECHO} "${START_TIME}" | ${AWK} '/^[[:digit:]]{10}$/'` ]; then
  START_TIME=`${ECHO} "${START_TIME}" | ${SED} 's/\([[:digit:]]\{2\}\)$/ \1/'`
else
  ${ECHO} "ERROR: start time, '${START_TIME}', is not in 'yyyymmddhh' or 'yyyymmdd hh' format"
  exit 1
fi
YYYYMMDDHH=`${DATE} +"%Y%m%d%H" -d "${START_TIME}"`
YYYYMMDD=`${DATE} +"%Y%m%d" -d "${START_TIME}"`
OLD_DAY=`${DATE} +"%Y%m%d" -d "${START_TIME} 1 day ago"`
OLD_JULIAN=`${DATE} +"%Y%j" -d "${START_TIME} 1 day ago"`
HH=`${DATE} +"%H" -d "${START_TIME}"`

# Check to make sure that the START_JULIAN is defined and in the correct format
if [ ! "${START_JULIAN}" ]; then
  ${ECHO} "ERROR: START_JULIAN, \$START_JULIAN, is not defined"
  exit 1
fi

# Check to make sure that the MCD static file exists
if [ ! ${MCD_FILE} ]; then
  ${ECHO} "ERROR: MCD_FILE, \$MCD_FILE, is not defined"
  exit 1
fi

# Check to make sure that the BIOME static file exists
if [ ! ${BIOME_FILE} ]; then
  ${ECHO} "ERROR: BIOME_FILE, \$BIOME_FILE, is not defined"
  exit 1
fi

# Check to make sure that the RNPP_EXEC executable exists
if [ ! ${RNPP_EXEC} ]; then
  ${ECHO} "ERROR: RNPP_EXEC, \$RNPP_EXEC, is not defined"
  exit 1
fi

# Check to make sure that the RMODIS_EXEC executable exists
if [ ! ${RMODIS_EXEC} ]; then
  ${ECHO} "ERROR: RMODIS_EXEC, \$RMODIS_EXEC, is not defined"
  exit 1
fi

# Check to make sure that the RNOAA20_EXEC executable exists
if [ ! ${RNOAA20_EXEC} ]; then
  ${ECHO} "ERROR: RNOAA20_EXEC, \$RNOAA20_EXEC, is not defined"
  exit 1
fi

# Check to make sure that the FRP_EXEC executable exists
if [ ! ${FRP_EXEC} ]; then
  ${ECHO} "ERROR: FRP_EXEC, \$FRP_EXEC, is not defined"
  exit 1
fi

# Check to make sure that the BBM_EXEC directory exists
if [ ! ${BBM_EXEC} ]; then
  ${ECHO} "ERROR: BBM_EXEC, \$BBM_EXEC, is not defined"
  exit 1
fi

# Set up the work directory and cd into it
workdir=${DATAHOME}/${YYYYMMDDHH}
#${RM} -rf ${workdir}
${MKDIR} -p ${workdir}
${RM} -rf ${DATAHOME_RAW}
${MKDIR} -p ${DATAHOME_RAW}
${RM} -rf ${DATAHOME_PROC}
${MKDIR} -p ${DATAHOME_PROC}
cd ${VIIRS_ROOT}

# Process each individual VIIRS hour, then copy into second working directory

evening_run='00'

if [ ${HH} -eq ${evening_run} ]; then
  for file in AF_v1r1_npp_s${OLD_DAY}*.txt
  do
    hour=$(echo ${file} | cut -c22-25)
    ${RNPP_EXEC} ${file} ${DATAHOME_RAW}/${OLD_JULIAN}${hour}_vii3km.txt ${MCD_FILE}
    cp ${file} ${DATAHOME_RAW}/
    cp ${DATAHOME_RAW}/${OLD_JULIAN}${hour}_vii3km.txt ${DATAHOME_PROC}/
  done
else
  hh=00
  while [[ $hh -lt 24 ]] ; do
    if [[ $hh -ge ${HH} ]] then
      for file in AF_v1r1_npp_s${OLD_DAY}${hh}*.txt
      do
        hour=$(echo ${file} | cut -c22-25)
        ${RNPP_EXEC} ${file} ${DATAHOME_RAW}/${OLD_JULIAN}${hour}_vii3km.txt ${MCD_FILE}
        cp ${file} ${DATAHOME_RAW}/
        cp ${DATAHOME_RAW}/${OLD_JULIAN}${hour}_vii3km.txt ${DATAHOME_PROC}/
      done
    else
      for file in AF_v1r1_npp_s${YYYYMMDD}${hh}*.txt
      do
        hour=$(echo ${file} | cut -c22-25)
        ${RNPP_EXEC} ${file} ${DATAHOME_RAW}/${START_JULIAN}${hour}_vii3km.txt ${MCD_FILE}
        cp ${file} ${DATAHOME_RAW}/
        cp ${DATAHOME_RAW}/${START_JULIAN}${hour}_vii3km.txt ${DATAHOME_PROC}/
      done
    fi
    hh=$((hh + 1))
    if [[ $hh -lt 10 ]] then
      hh=0$hh
    fi
  done
fi

# Process each individual NOAA20 hour, then copy into second working directory

cd ${NOAA20_ROOT}

evening_run='00'

if [ ${HH} -eq ${evening_run} ]; then
  for file in AF_v1r1_j01_s${OLD_DAY}*.txt
  do
    hour=$(echo ${file} | cut -c22-25)
    ${RNOAA20_EXEC} ${file} ${DATAHOME_RAW}/${OLD_JULIAN}${hour}_noa3km.txt ${MCD_FILE}
    cp ${file} ${DATAHOME_RAW}
    cp ${DATAHOME_RAW}/${OLD_JULIAN}${hour}_noa3km.txt ${DATAHOME_PROC}/
  done
else
  hh=00
  while [[ $hh -lt 24 ]] ; do
    if [[ $hh -ge ${HH} ]] then
      for file in AF_v1r1_j01_s${OLD_DAY}${hh}*.txt
      do
        hour=$(echo ${file} | cut -c22-25)
        ${RNOAA20_EXEC} ${file} ${DATAHOME_RAW}/${OLD_JULIAN}${hour}_noa3km.txt ${MCD_FILE}
        cp ${file} ${DATAHOME_RAW}/
        cp ${DATAHOME_RAW}/${OLD_JULIAN}${hour}_noa3km.txt ${DATAHOME_PROC}/
      done
    else
      for file in AF_v1r1_j01_s${YYYYMMDD}${hh}*.txt
      do
        hour=$(echo ${file} | cut -c22-25)
        ${RNOAA20_EXEC} ${file} ${DATAHOME_RAW}/${START_JULIAN}${hour}_noa3km.txt ${MCD_FILE}
        cp ${file} ${DATAHOME_RAW}/
        cp ${DATAHOME_RAW}/${START_JULIAN}${hour}_noa3km.txt ${DATAHOME_PROC}/
      done
    fi
    hh=$((hh + 1))
    if [[ $hh -lt 10 ]] then
      hh=0$hh
    fi
  done
fi

# Process each MODIS day, then copy into second working directory

cd ${DATAHOME_RAW}

if [ ${HH} -eq ${evening_run} ]; then
  cp ${MODIS_ROOT}/MODIS_C6_Global_MCD14DL_NRT_${OLD_JULIAN}.txt .
  ${RMODIS_EXEC} MODIS_C6_Global_MCD14DL_NRT_${OLD_JULIAN}.txt ${MCD_FILE} 00 24
  cp ${DATAHOME_RAW}/${OLD_JULIAN}*_mod_HRRR.txt ${DATAHOME_PROC}/
else
  cp ${MODIS_ROOT}/MODIS_C6_Global_MCD14DL_NRT_${OLD_JULIAN}.txt .
  cp ${MODIS_ROOT}/MODIS_C6_Global_MCD14DL_NRT_${START_JULIAN}.txt .
  ${RMODIS_EXEC} MODIS_C6_Global_MCD14DL_NRT_${OLD_JULIAN}.txt ${MCD_FILE} ${HH} 24
  ${RMODIS_EXEC} MODIS_C6_Global_MCD14DL_NRT_${START_JULIAN}.txt ${MCD_FILE} 00 ${HH}
  cp ${DATAHOME_RAW}/${OLD_JULIAN}*_mod_HRRR.txt ${DATAHOME_PROC}/
  cp ${DATAHOME_RAW}/${START_JULIAN}*_mod_HRRR.txt ${DATAHOME_PROC}/
fi

cd ${DATAHOME_PROC}
cat * > ${START_JULIAN}${HH}_daily3km.txt

# Integrate VIIRS data

${FRP_EXEC} ${START_JULIAN}${HH}_daily3km.txt ${START_JULIAN}${HH}_frp3km.txt
${BBM_EXEC} ${START_JULIAN}${HH}_frp3km.txt f${START_JULIAN}${HH}_bbm3km.txt ${MCD_FILE} ${BIOME_FILE}

exit 0
