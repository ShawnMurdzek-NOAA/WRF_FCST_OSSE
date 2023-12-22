#!/bin/ksh --login

np=`cat $PBS_NODEFILE | wc -l`

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

# Set up paths to unix commands
RM=/bin/rm
CP=/bin/cp
MV=/bin/mv
LN=/bin/ln
MKDIR=/bin/mkdir
CAT=/bin/cat
ECHO=/bin/echo
LS=/bin/ls
CUT=/bin/cut
WC=/usr/bin/wc
DATE=/bin/date
AWK="/bin/awk --posix"
SED=/bin/sed
TAIL=/usr/bin/tail
CNVGRIB=/apps/cnvgrib/1.4.0/bin/cnvgrib
MPIRUN=srun

# Set endian conversion options for use with Intel compilers
## export F_UFMTENDIAN="big;little:10,15,66"
## export F_UFMTENDIAN="big;little:10,13,15,66"
## export GMPIENVVAR=F_UFMTENDIAN
## export MV2_ON_DEMAND_THRESHOLD=256

# Set the path to the gsi executable
GSI=${GSI_ROOT}/HRRR_gsi_hyb

# Set the path to the GSI static files
fixdir=${FIX_ROOT}

# Make sure DATAHOME is defined and exists
if [ ! "${DATAHOME}" ]; then
  ${ECHO} "ERROR: \$DATAHOME is not defined!"
  exit 1
fi

#  PREPBUFR
if [ ! "${PREPBUFR}" ]; then
  ${ECHO} "ERROR: \$PREPBUFR is not defined!"
  exit 1
fi
#if [ ! -d "${PREPBUFR}" ]; then
#  ${ECHO} "ERROR: directory '${PREPBUFR}' does not exist!"
#  exit 1
#fi

#  NCEPSNOW
if [ ! "${NCEPSNOW}" ]; then  ${ECHO} "ERROR: \$NCEPSNOW is not defined!"
  exit 1
fi
#if [ ! -d "${NCEPSNOW}" ]; then
#  ${ECHO} "ERROR: directory '${NCEPSNOW}' does not exist!"
#  exit 1
#fi

# Make sure GSI_ROOT is defined and exists
if [ ! "${GSI_ROOT}" ]; then
  ${ECHO} "ERROR: \$GSI_ROOT is not defined!"
  exit 1
fi
if [ ! -d "${GSI_ROOT}" ]; then
  ${ECHO} "ERROR: GSI_ROOT directory '${GSI_ROOT}' does not exist!"
  exit 1
fi

# Check to make sure that STATIC_PATH exists
if [ ! -d ${STATIC_DIR} ]; then
  ${ECHO} "ERROR: ${STATIC_DIR} does not exist"
  exit 1
fi

# Check to make sure that ENKF_FCST exists
if [ ! -d ${ENKF_FCST} ]; then
  ${ECHO} "ERROR: ${ENKF_FCST} does not exist"
  exit 1
fi

# Check to make sure that FULLCYC exists
if [ ! "${FULLCYC}" ]; then
  ${ECHO} "ERROR: FULLCYC '${FULLCYC}' does not exist"
  exit 1
fi

# Make sure START_TIME is defined and in the correct format
if [ ! "${START_TIME}" ]; then
  ${ECHO} "ERROR: \$START_TIME is not defined!"
  exit 1
else
  if [ `${ECHO} "${START_TIME}" | ${AWK} '/^[[:digit:]]{10}$/'` ]; then
    START_TIME=`${ECHO} "${START_TIME}" | ${SED} 's/\([[:digit:]]\{2\}\)$/ \1/'`
  elif [ ! "`${ECHO} "${START_TIME}" | ${AWK} '/^[[:digit:]]{8}[[:blank:]]{1}[[:digit:]]{2}$/'`" ]; then
    ${ECHO} "ERROR: start time, '${START_TIME}', is not in 'yyyymmddhh' or 'yyyymmdd hh' format"
    exit 1
  fi
  START_TIME=`${DATE} -d "${START_TIME}"`
fi

# Make sure the GSI executable exists
if [ ! -x "${GSI}" ]; then
  ${ECHO} "ERROR: ${GSI} does not exist!"
  exit 1
fi

echo "Running system: ${SYSTEM_ID}"
# Compute date & time components for the analysis time
YYYYJJJHH00=`${DATE} +"%Y%j%H00" -d "${START_TIME}"`
YYYYJJJHH=`${DATE} +"%Y%j%H" -d "${START_TIME}"`
YYYYMMDDHH=`${DATE} +"%Y%m%d%H" -d "${START_TIME}"`
YYYYMMDD=`${DATE} +"%Y%m%d" -d "${START_TIME}"`
YYJJJHH=`${DATE} +"%y%j%H" -d "${START_TIME}"`
YYYY=`${DATE} +"%Y" -d "${START_TIME}"`
MM=`${DATE} +"%m" -d "${START_TIME}"`
DD=`${DATE} +"%d" -d "${START_TIME}"`
HH=`${DATE} +"%H" -d "${START_TIME}"`

YYYYMMDD_2=`${DATE} +"%Y%m%d" -d "${START_TIME} -1 day"`
YYYY_2=`${DATE} +"%Y" -d "${START_TIME} -1 day"`
MM_2=`${DATE} +"%m" -d "${START_TIME} -1 day"`
DD_2=`${DATE} +"%d" -d "${START_TIME} -1 day"`
HH_2=`${DATE} +"%H" -d "${START_TIME} -1 day"`

# Create the working directory and cd into it
workdir=${DATAHOME}
${RM} -rf ${workdir}
${MKDIR} -p ${workdir}
# if [ "`stat -f -c %T ${workdir}`" == "lustre" ]; then
#  lfs setstripe --count 8 ${workdir}
# fi
cd ${workdir}

# Define the output log file depending on if this is the full or partial cycle
ifsoilnudge=.true.
if [ ${FULLCYC} -eq 0 ]; then
  logfile=${DATABASE_DIR}/loghistory/HRRR_GSI_HYB_PCYC.log
  ifsoilnudge=.true.
elif [ ${FULLCYC} -eq 1 ]; then
  logfile=${DATABASE_DIR}/loghistory/HRRR_GSI_HYB.log
  ifsoilnudge=.true.
elif [ ${FULLCYC} -eq 2 ]; then
  logfile=${DATABASE_DIR}/loghistory/HRRR_GSI_HYB_early.log
  ifsoilnudge=.true.
else  
  echo "ERROR: Unknown CYCLE ${FULLCYC} definition!"
  exit 1
fi

# Save a copy of the GSI executable in the workdir
${CP} ${GSI} .

# Bring over background field (it's modified by GSI so we can't link to it)
time_str=`${DATE} "+%Y-%m-%d_%H_%M_%S" -d "${START_TIME}"`
${ECHO} " time_str = ${time_str}"

# Define background forecast file
if [ ${SPINUP} -eq 1 ]; then
  if [ ${HH} -eq "03" ] || [ ${HH} -eq "15" ]; then
    BACKGRD_FILE=${DATAHOME_IC}/wrfinput_d01
  else
    BACKGRD_FILE=${DATAHOME_SPINUP}/wrfout_d01_${time_str}
  fi
else
  if [ ${HH} -eq "09" ] || [ ${HH} -eq "21" ]; then
    BACKGRD_FILE=${DATAHOME_SPINUP}/wrfout_d01_${time_str}
  else
    BACKGRD_FILE=${DATAHOME_PROD}/wrfout_d01_${time_str}
  fi
fi

# Look for background from pre-forecast background
if [ -r ${BACKGRD_FILE} ]; then
  ${ECHO} " Cycled run using ${BACKGRD_FILE}"
  cp ${BACKGRD_FILE} ./wrf_inout
  ${ECHO} " Cycle ${YYYYMMDDHH}: GSI background=${BACKGRD_FILE}" >> ${logfile}

# No background available so abort
else
  ${ECHO} "${BACKGRD_FILE} does not exist!!"
  ${ECHO} "ERROR: No background file for analysis at ${time_run}!!!!"
  ${ECHO} " Cycle ${YYYYMMDDHH}: GSI failed because of no background" >> ${logfile} 
  exit 1
fi

# Insert land surface variables into the wrf_inout file (only needed at beginning of partial cycles)
if [ ${SPINUP} -eq 1]; then
  if [ ${HH} -eq "03" ] || [ ${HH} -eq "15" ]; then
    if [ -r "${DATAROOT}/surface/wrfout_sfc_${HH}" ]; then
      echo "cycle Surface fields based on ${DATAROOT}/surface/wrfout_sfc_${HH} "
      ${LN} -s ${DATAROOT}/surface/wrfout_sfc_${HH} ./wrfout_d01_save
      ${MPIRUN} --ntasks=1 ${GSI_ROOT}/full_cycle_surface.exe > stdout_cycleSurface 2>&1
      error=$?
      if [ ${error} -ne 0 ]; then
        ${ECHO} "ERROR: full_cycle_surface.exe crashed  Exit status=${error}"
        exit ${error}
      fi  
    # No time matched HRRR land surface file available
    else
      ${ECHO} "${DATAROOT}/surface/wrfout_sfc_${HH} does not exist!!"
      ${ECHO} "ERROR: No land surface data cycled for background at ${time_str}!!!!"
#      exit 1
    fi
  fi
fi

# Skip GSI for first spinup cycle
if [ ${SPINUP} -eq 1 ] && [ ${SKIP_GSI_FIRST_SPINUP} -eq 1 ]; then
  if [ ${HH} -eq "03" ] || [ ${HH} -eq "15" ] ; then
    exit 0
  fi
fi

# Compute date & time components for the SST analysis time relative to current analysis time
YYJJJ00000000=`${DATE} +"%y%j00000000" -d "${START_TIME} 1 day ago"`
YYJJJ1200=`${DATE} +"%y%j1200" -d "${START_TIME} 1 day ago"`

if [ ${HH} -eq ${UPDATE_SST} ]; then
  echo "Update SST"
  if [ -r "${SST_ROOT}/latest.SST" ]; then
    cp ${SST_ROOT}/latest.SST .
  elif [ -r "${SST_ROOT}/${YYJJJ00000000}" ]; then
    cp ${SST_ROOT}/${YYJJJ00000000} latest.SST
  else
    ${ECHO} "${SST_ROOT} data does not exist!!"
    ${ECHO} "ERROR: No SST update at ${time_str}!!!!"
  fi  
  if [ -r "latest.SST" ]; then
    ${CP} ${STATIC_DIR}/UPP/RTG_SST_landmask.dat ./RTG_SST_landmask.dat
    ${CP} ${STATIC_DIR}/WPS/geo_em.d01.nc ./geo_em.d01.nc
    ${MPIRUN} ${GSI_ROOT}/process_SST.exe > stdout_sstupdate 2>&1
  else
    ${ECHO} "ERROR: No latest SST file for update at ${time_str}!!!!"
  fi
else
  ${ECHO} "NOTE: No update for SST at ${time_str}!"
fi

# Link to the prepbufr data in obsproc directory if available
# turn off the link to prepbufr_tamdar because NCEP feed works. Aug 4th, 2017
if [ -r ${DATAOBSHOME}/prepbufr_tamdar ]; then
  ${LN} -s ${DATAOBSHOME}/prepbufr_tamdar ./prepbufr
elif [ -r ${DATAOBSHOME}/prepbufr ]; then
  ${LN} -s ${DATAOBSHOME}/prepbufr ./prepbufr
# If obsproc has not executed then look for prepbufr file directly on /public
#else 2020082723.rap.t23z.prepbufr.tm00
  # Copy the prepbufr to obs directory so we never do I/O to /public directly
#  if [[ ${HH} -ne 00 && ${HH} -ne 12 ]]; then
#    if [ -r "${PREPBUFR}_test/${YYYYJJJHH00}.rap.t${HH}z.prepbufr.tm00.test" ]; then
#      ${CP} ${PREPBUFR}_test/${YYYYJJJHH00}.rap.t${HH}z.prepbufr.tm00.test .
#      ${LN} -s ${YYYYJJJHH00}.rap.t${HH}z.prepbufr.tm00.test ./prepbufr
#    else
#      if [ -r "${PREPBUFR}/${YYYYJJJHH00}.rap.t${HH}z.prepbufr.tm00.${YYYYMMDD}" ]; then
#        ${ECHO} "Warning: ${YYYYJJJHH00}.rap.t${HH}z.prepbufr.tm00.${YYYYMMDD} does not exist!"
#        ${CP} ${PREPBUFR}/${YYYYJJJHH00}.rap.t${HH}z.prepbufr.tm00.${YYYYMMDD} .
#        ${LN} -s ${YYYYJJJHH00}.rap.t${HH}z.prepbufr.tm00.${YYYYMMDD} ./prepbufr
#      else
#        ${ECHO} "Warning: ${YYYYJJJHH00}.rap.t${HH}z.prepbufr.tm00.${YYYYMMDD} does not exist!"
#      fi
#    fi
#  else
#    if [[ ${HH} -eq 00 || ${HH} -eq 12 ]]; then
#      if [ -r "${PREPBUFR}_test/${YYYYJJJHH00}.rap_e.t${HH}z.prepbufr.tm00.test" ]; then
#        ${CP} ${PREPBUFR}_test/${YYYYJJJHH00}.rap_e.t${HH}z.prepbufr.tm00.test .
#        ${LN} -s ${YYYYJJJHH00}.rap_e.t${HH}z.prepbufr.tm00.test ./prepbufr
#      else
#        if [ -r "${PREPBUFR}/${YYYYJJJHH00}.rap_e.t${HH}z.prepbufr.tm00.${YYYYMMDD}" ]; then
#          ${CP} ${PREPBUFR}/${YYYYJJJHH00}.rap_e.t${HH}z.prepbufr.tm00.${YYYYMMDD} .
#          ${LN} -s ${YYYYJJJHH00}.rap_e.t${HH}z.prepbufr.tm00.${YYYYMMDD} ./prepbufr
#        else
#          ${ECHO} "Warning: ${YYYYJJJHH00}.rap_e.t${HH}z.prepbufr.tm00.${YYYYMMDD} does not exist!"
#        fi
#      fi
#    else
#      ${ECHO} "ERROR: EARLY ${EARLY} is not defined or invalid"
#    fi
#  fi
fi



if [ -r "${DATAOBSHOME}/NSSLRefInGSI.bufr" ]; then
  ${LN} -s ${DATAOBSHOME}/NSSLRefInGSI.bufr ./refInGSI
else
  ${ECHO} "Warning: ${DATAOBSHOME}/NSSLRefInGSI.bufr dones not exist!"
fi

if [ -r "${DATAOBSHOME}/60/LightningInGSI.bufr" ]; then
  ${LN} -s ${DATAOBSHOME}/60/LightningInGSI.bufr ./lghtInGSI
else
  ${ECHO} "Warning: ${DATAOBSHOME}/60/LightningInGSI.bufr dones not exist!"
fi

if [ -r "${DATAOBSHOME}/NASALaRCCloudInGSI_bufr.bufr" ]; then
  ${LN} -s ${DATAOBSHOME}/NASALaRCCloudInGSI_bufr.bufr ./larcInGSI
else
  ${ECHO} "Warning: ${DATAOBSHOME}/NASALaRCCloudInGSI_bufr.bufr dones not exist!"
fi

# Link statellite radiance data (only turn on (when RAD=1) for HRRRV4/AK now 08/2019)
if [ ${RAD} -eq 1 ]; then
   if [ -r "${DATAOBSHOME}/newgblav.${YYYYMMDD}.rap.t${HH}z.1bamua" ]; then
      ${LN} -s ${DATAOBSHOME}/newgblav.${YYYYMMDD}.rap.t${HH}z.1bamua ./amsuabufr
   else
    ${ECHO} "Warning: ${DATAOBSHOME}/newgblav.${YYYYMMDD}.rap.t${HH}z.1bamua does not exist!"
   fi

   # for amsua rars data 
   if [ -r "${DATAOBSHOME}/newgblav.${YYYYMMDD}.rap.t${HH}z.esamua" ]; then
      ${LN} -s ${DATAOBSHOME}/newgblav.${YYYYMMDD}.rap.t${HH}z.esamua ./amsuabufrears
   else
      ${ECHO} "Warning: ${DATAOBSHOME}/newgblav.${YYYYMMDD}.rap.t${HH}z.esamua does not exist!"
   fi

   # for hirs4 data 
   if [ -r "${DATAOBSHOME}/newgblav.${YYYYMMDD}.rap.t${HH}z.1bhrs4" ]; then
     ${LN} -s ${DATAOBSHOME}/newgblav.${YYYYMMDD}.rap.t${HH}z.1bhrs4 ./hirs4bufr
   else
     ${ECHO} "Warning: ${DATAOBSHOME}/newgblav.${YYYYMMDD}.rap.t${HH}z.1bhrs4 does not exist!"
    fi

    # for mhs regular feed dat 
    if [ -r "${DATAOBSHOME}/newgblav.${YYYYMMDD}.rap.t${HH}z.1bmhs" ]; then
       ${LN} -s ${DATAOBSHOME}/newgblav.${YYYYMMDD}.rap.t${HH}z.1bmhs ./mhsbufr
    else
       ${ECHO} "Warning: ${DATAOBSHOME}/newgblav.${YYYYMMDD}.rap.t${HH}z.1bmhs does not exist!"
    fi

    # for mhs rars data 
    if [ -r "${DATAOBSHOME}/newgblav.${YYYYMMDD}.rap.t${HH}z.esmhs" ]; then
       ${LN} -s ${DATAOBSHOME}/newgblav.${YYYYMMDD}.rap.t${HH}z.esmhs ./mhsbufrears
    else
       ${ECHO} "Warning: ${DATAOBSHOME}/newgblav.${YYYYMMDD}.rap.t${HH}z.esmhs does not exist!"
    fi

     ##for goes sounder data
    if [ -r "${DATAOBSHOME}/newgblav.${YYYYMMDD}.rap.t${HH}z.goesnd" ]; then
       ${LN} -s ${DATAOBSHOME}/newgblav.${YYYYMMDD}.rap.t${HH}z.goesnd ./gsnd1bufr
    else
       ${ECHO} "Warning: ${DATAOBSHOME}/newgblav.${YYYYMMDD}.rap.t${HH}z.goesnd does not exist!"
    fi

    ##for sevcsr data 
    if [ -r "${DATAOBSHOME}/newgblav.${YYYYMMDD}.rap.t${HH}z.sevcsr" ]; then
       ${LN} -s ${DATAOBSHOME}/newgblav.${YYYYMMDD}.rap.t${HH}z.sevcsr ./seviribufr
       else
       ${ECHO} "Warning: ${DATAOBSHOME}/newgblav.${YYYYMMDD}.rap.t${HH}z.sevcsr does not exist!"
    fi

    ##for atms regular feed data 
    if [ -r "${DATAOBSHOME}/newgblav.${YYYYMMDD}.rap.t${HH}z.atms" ]; then
       ${LN} -s ${DATAOBSHOME}/newgblav.${YYYYMMDD}.rap.t${HH}z.atms ./atmsbufr
       else
       ${ECHO} "Warning: ${DATAOBSHOME}/newgblav.${YYYYMMDD}.rap.t${HH}z.atms does not exist!"
    fi

    ##for atms db data 
    if [ -r "${DATAOBSHOME}/newgblav.${YYYYMMDD}.rap.t${HH}z.atmsdb" ]; then
      ${LN} -s ${DATAOBSHOME}/newgblav.${YYYYMMDD}.rap.t${HH}z.atmsdb ./atmsbufr_db
    else
       ${ECHO} "Warning: ${DATAOBSHOME}/newgblav.${YYYYMMDD}.rap.t${HH}z.atmsdb does not exist!"
    fi

     ##for atms RARS data 
    if [ -r "${DATAOBSHOME}/newgblav.${YYYYMMDD}.rap.t${HH}z.esatms" ]; then
       ${LN} -s ${DATAOBSHOME}/newgblav.${YYYYMMDD}.rap.t${HH}z.esatms ./atmsbufrears
    else
        ${ECHO} "Warning: ${DATAOBSHOME}/newgblav.${YYYYMMDD}.rap.t${HH}z.esatms does not exist!"
    fi

    ##for cris regular feed data  
    if [ -r "${DATAOBSHOME}/newgblav.${YYYYMMDD}.rap.t${HH}z.cris" ]; then
       ${LN} -s ${DATAOBSHOME}/newgblav.${YYYYMMDD}.rap.t${HH}z.cris ./crisbufr
    else
       ${ECHO} "Warning: ${DATAOBSHOME}/newgblav.${YYYYMMDD}.rap.t${HH}z.cris does not exist!"
    fi

    ##for crisf4 regular feed data  
    if [ -r "${DATAOBSHOME}/newgblav.${YYYYMMDD}.rap.t${HH}z.crisf4" ]; then
       ${LN} -s ${DATAOBSHOME}/newgblav.${YYYYMMDD}.rap.t${HH}z.crisf4 ./crisfsbufr
    else
       ${ECHO} "Warning: ${DATAOBSHOME}/newgblav.${YYYYMMDD}.rap.t${HH}z.crisf4 does not exist!"
    fi

    ##for cris db data link to crisbufr_db  and crisfsbufr_db
   if [ -r "${DATAOBSHOME}/newgblav.${YYYYMMDD}.rap.t${HH}z.crisdb" ]; then
      ${LN} -s ${DATAOBSHOME}/newgblav.${YYYYMMDD}.rap.t${HH}z.crisdb ./crisbufr_db
      ${LN} -s ${DATAOBSHOME}/newgblav.${YYYYMMDD}.rap.t${HH}z.crisdb ./crisfsbufr_db
   else
     ${ECHO} "Warning: ${DATAOBSHOME}/newgblav.${YYYYMMDD}.rap.t${HH}z.crisdb does not exist!"
   fi

   ##for cris rars data 
   if [ -r "${DATAOBSHOME}/newgblav.${YYYYMMDD}.rap.t${HH}z.escris" ]; then
      ${LN} -s ${DATAOBSHOME}/newgblav.${YYYYMMDD}.rap.t${HH}z.escris ./crisbufrears
   else
     ${ECHO} "Warning: ${DATAOBSHOME}/newgblav.${YYYYMMDD}.rap.t${HH}z.escris does not exist!"
   fi

   ##for airs data 
   if [ -r "${DATAOBSHOME}/newgblav.${YYYYMMDD}.rap.t${HH}z.airsev" ]; then
     ${LN} -s ${DATAOBSHOME}/newgblav.${YYYYMMDD}.rap.t${HH}z.airsev ./airsbufr
   else
    ${ECHO} "Warning: ${DATAOBSHOME}/newgblav.${YYYYMMDD}.rap.t${HH}z.airsev does not exist!"
  fi

   ##for ssmisu data 
   if [ -r "${DATAOBSHOME}/newgblav.${YYYYMMDD}.rap.t${HH}z.ssmisu" ]; then
     ${LN} -s ${DATAOBSHOME}/newgblav.${YYYYMMDD}.rap.t${HH}z.ssmisu ./ssmisbufr
   else
     ${ECHO} "Warning: ${DATAOBSHOME}/newgblav.${YYYYMMDD}.rap.t${HH}z.ssmisu does not exist!"
   fi

   ##for iasi regular feed data 
   if [ -r "${DATAOBSHOME}/newgblav.${YYYYMMDD}.rap.t${HH}z.mtiasi" ]; then
     ${LN} -s ${DATAOBSHOME}/newgblav.${YYYYMMDD}.rap.t${HH}z.mtiasi ./iasibufr
   else
     ${ECHO} "Warning: ${DATAOBSHOME}/newgblav.${YYYYMMDD}.rap.t${HH}z.mtiasi does not exist!"
   fi

   ##for iasi db data 
   if [ -r "${DATAOBSHOME}/newgblav.${YYYYMMDD}.rap.t${HH}z.iasidb" ]; then
     ${LN} -s ${DATAOBSHOME}/newgblav.${YYYYMMDD}.rap.t${HH}z.iasidb ./iasibufr_db
   else
     ${ECHO} "Warning: ${DATAOBSHOME}/newgblav.${YYYYMMDD}.rap.t${HH}z.iasidb does not exist!"
   fi

   ##for iasi rars data 
   if [ -r "${DATAOBSHOME}/newgblav.${YYYYMMDD}.rap.t${HH}z.esiasi" ]; then
     ${LN} -s ${DATAOBSHOME}/newgblav.${YYYYMMDD}.rap.t${HH}z.esiasi ./iasibufrears
  else
     ${ECHO} "Warning: ${DATAOBSHOME}/newgblav.${YYYYMMDD}.rap.t${HH}z.esiasi does not exist!"
  fi

  ## for abi data 
  if [ -r "${DATAOBSHOME}/newgblav.${YYYYMMDD}.rap.t${HH}z.gsrcsr" ]; then
     ${LN} -s ${DATAOBSHOME}/newgblav.${YYYYMMDD}.rap.t${HH}z.gsrcsr ./abibufr
  else
     ${ECHO} "Warning: ${DATAOBSHOME}/newgblav.${YYYYMMDD}.rap.t${HH}z.gsrcsr does not exist!"
  fi


fi ##end of links to satellite radiance data if RAD=1

# Link the radial velocity data

if [ -r "${DATAOBSHOME}/newgblav.${YYYYMMDD}.rap.t${HH}z.radwnd" ]; then
  ${LN} -s ${DATAOBSHOME}/newgblav.${YYYYMMDD}.rap.t${HH}z.radwnd ./radarbufr
else
  ${ECHO} "Warning: ${DATAOBSHOME}/newgblav.${YYYYMMDD}.rap.t${HH}z.radwnd dones not exist!"
fi
if [ -r "${DATAOBSHOME}/newgblav.${YYYYMMDD}.rap.t${HH}z.nexrad" ]; then
  ${LN} -s ${DATAOBSHOME}/newgblav.${YYYYMMDD}.rap.t${HH}z.nexrad ./l2rwbufr
else
  ${ECHO} "Warning: ${DATAOBSHOME}/newgblav.${YYYYMMDD}.rap.t${HH}z.nexrad dones not exist!"
fi

# Link the AMV data
if [ -r "${DATAOBSHOME}/newgblav.${YYYYMMDD}.rap.t${HH}z.satwnd" ]; then
  ${LN} -s ${DATAOBSHOME}/newgblav.${YYYYMMDD}.rap.t${HH}z.satwnd ./satwndbufr
else
  ${ECHO} "Warning: ${DATAOBSHOME}/newgblav.${YYYYMMDD}.rap.t${HH}z.satwnd dones not exist!"
fi

# Link the TC vital data
if [ -r "${DATAOBSHOME}/newgblav.${YYYYMMDD}.tcvitals.t${HH}z" ]; then
   ${LN} -s ${DATAOBSHOME}/newgblav.${YYYYMMDD}.tcvitals.t${HH}z ./tcvitl
else
   ${ECHO} "Warning: ${DATAOBSHOME}/newgblav.${YYYYMMDD}.tcvitals.t${HH}z dones not exist!"
fi

## 
## Find closest GFS EnKF forecast to analysis time
##
# Make a list of the latest GFS EnKF ensemble
## 
stampcycle=`date -d "${START_TIME}" +%s`
minHourDiff=100
loops="009"
for loop in $loops; do
  for timelist in `ls ${ENKF_FCST}/*.gdas.t*z.atmf${loop}.mem080.nc`; do
    availtimeyy=`basename ${timelist} | cut -c 1-2`
    availtimeyyyy=20${availtimeyy}
    availtimejjj=`basename ${timelist} | cut -c 3-5`
    availtimemm=`date -d "${availtimeyyyy}0101 +$(( 10#${availtimejjj} - 1 )) days" +%m`
    availtimedd=`date -d "${availtimeyyyy}0101 +$(( 10#${availtimejjj} - 1 )) days" +%d`
    availtimehh=`basename ${timelist} | cut -c 6-7`
    availtime=${availtimeyyyy}${availtimemm}${availtimedd}${availtimehh}
    AVAIL_TIME=`${ECHO} "${availtime}" | ${SED} 's/\([[:digit:]]\{2\}\)$/ \1/'`
    AVAIL_TIME=`${DATE} -d "${AVAIL_TIME}"`

    stamp_avail=`date -d "${AVAIL_TIME} ${loop} hours" +%s`

    hourDiff=`echo "($stampcycle - $stamp_avail) / (60 * 60 )" | bc`;
    if [[ ${stampcycle} -lt ${stamp_avail} ]]; then
       hourDiff=`echo "($stamp_avail - $stampcycle) / (60 * 60 )" | bc`;
    fi

    if [[ ${hourDiff} -lt ${minHourDiff} ]]; then
       minHourDiff=${hourDiff}
       enkfcstname=${availtimeyy}${availtimejjj}${availtimehh}00.gdas.t${availtimehh}z.atmf${loop}
    fi
  done
done
EYYYYMMDD=$(echo ${availtime} | cut -c1-8)
EHH=$(echo ${availtime} | cut -c9-10)
${LS} ${ENKF_FCST}/${enkfcstname}.mem???.nc > filelist03

# SSM 20221127: Use GDAS instead of HRRRDAS
#
#----------------------------------------------------
# generate list of HRRRDAS members for ensemble covariances
# Use 1-hr forecasts from the HRRRDAS cycling
#time_1hour_ago=`${DATE} -d "${START_TIME} 1 hour ago" +%Y%m%d%H`
#if [ ${HRRRDAS_SMALL} -eq 1 ]; then
#  ls ${HRRRDAS_DIR}/${time_1hour_ago}/wrfprd_mem????/wrfout_small_d02_${YYYY}-${MM}-${DD}_${HH}_00_00 > filelist.hrrrdas
#else
#  ls ${HRRRDAS_DIR}/${time_1hour_ago}/wrfprd_mem????/wrfout_d02_${YYYY}-${MM}-${DD}_${HH}_00_00 > filelist.hrrrdas
#fi
#c=1
#while [[ $c -le 36 ]]; do
# if [ $c -lt 10 ]; then
#  cc="0"$c
# else
#  cc=$c
# fi
# if [ ${HRRRDAS_SMALL} -eq 1 ]; then
#   hrrre_file=${HRRRDAS_DIR}/${time_1hour_ago}/wrfprd_mem00${cc}/wrfout_small_d02_${YYYY}-${MM}-${DD}_${HH}_00_00
# else
#   hrrre_file=${HRRRDAS_DIR}/${time_1hour_ago}/wrfprd_mem00${cc}/wrfout_d02_${YYYY}-${MM}-${DD}_${HH}_00_00
# fi
# ln -sf ${hrrre_file} wrf_en0${cc}
# ((c = c + 1))
#done

# Determine if hybrid option is available
beta1_inv=1.0
ifhyb=.false.
nummem=`more filelist03 | wc -l`
nummem=$((nummem - 3 ))
#hrrrmem=`more filelist.hrrrdas | wc -l`
#hrrrmem=$((hrrrmem - 3 ))
#if [[ ${hrrrmem} -gt 30 ]] && [[ ${HRRRDAS_BEC} -eq 1  ]]; then  #if HRRRDAS BEC is available, use it as first choice
#  echo "Do hybrid with HRRRDAS BEC"
#  nummem=${hrrrmem}
#  cp filelist.hrrrdas filelist03
#
#  beta1_inv=0.15
#  ifhyb=.true.
#  regional_ensemble_option=3
#  grid_ratio_ens=1
#  i_en_perts_io=0
#  ens_fast_read=.true. 
#  ${ECHO} " Cycle ${YYYYMMDDHH}: GSI hybrid uses HRRRDAS BEC with n_ens=${nummem}" >> ${logfile}
#elif [[ ${nummem} -eq 80 ]]; then
  echo "Do hybrid with GDAS"
  beta1_inv=0.15
  ifhyb=.true.
  regional_ensemble_option=1
  grid_ratio_ens=12
  i_en_perts_io=1
  ens_fast_read=.false. 
  ${ECHO} " Cycle ${YYYYMMDDHH}: GSI hybrid uses GDAS with n_ens=${nummem}" >> ${logfile}
#fi

# Set fixed files
#   berror   = forecast model background error statistics
#   specoef  = CRTM spectral coefficients
#   trncoef  = CRTM transmittance coefficients
#   emiscoef = CRTM coefficients for IR sea surface emissivity model
#   aerocoef = CRTM coefficients for aerosol effects
#   cldcoef  = CRTM coefficients for cloud effects
#   satinfo  = text file with information about assimilation of brightness temperatures
#   satangl  = angle dependent bias correction file (fixed in time)
#   pcpinfo  = text file with information about assimilation of prepcipitation rates
#   ozinfo   = text file with information about assimilation of ozone data
#   errtable = text file with obs error for conventional data (regional only)
#   convinfo = text file with information about assimilation of conventional data
#   bufrtable= text file ONLY needed for single obs test (oneobstest=.true.)
#   bftab_sst= bufr table for sst ONLY needed for sst retrieval (retrieval=.true.)

anavinfo=${fixdir}/anavinfo_arw_netcdf
BERROR=${fixdir}/rap_berror_stats_global_RAP_tune
##SATANGL=${fixdir}/global_satangbias.txt
SATINFO=${fixdir}/global_satinfo.txt
CONVINFO=${fixdir}/nam_regional_convinfo_RAP.txt
OZINFO=${fixdir}/global_ozinfo.txt
PCPINFO=${fixdir}/global_pcpinfo.txt
OBERROR=${fixdir}/nam_errtable.r3dv
ATMS_BEAMWIDTH=${fixdir}/atms_beamwidth.txt


# Fixed fields
cp $anavinfo anavinfo
cp $BERROR   berror_stats
##cp $SATANGL  satbias_angle
cp $SATINFO  satinfo
cp $CONVINFO convinfo
cp $OZINFO   ozinfo
cp $PCPINFO  pcpinfo
cp $OBERROR  errtable
cp $ATMS_BEAMWIDTH atms_beamwidth.txt

# CRTM Spectral and Transmittance coefficients
CRTMFIX=${fixdir}/CRTM_Coefficients
emiscoef_IRwater=${CRTMFIX}/Nalli.IRwater.EmisCoeff.bin
emiscoef_IRice=${CRTMFIX}/NPOESS.IRice.EmisCoeff.bin
emiscoef_IRland=${CRTMFIX}/NPOESS.IRland.EmisCoeff.bin
emiscoef_IRsnow=${CRTMFIX}/NPOESS.IRsnow.EmisCoeff.bin
emiscoef_VISice=${CRTMFIX}/NPOESS.VISice.EmisCoeff.bin
emiscoef_VISland=${CRTMFIX}/NPOESS.VISland.EmisCoeff.bin
emiscoef_VISsnow=${CRTMFIX}/NPOESS.VISsnow.EmisCoeff.bin
emiscoef_VISwater=${CRTMFIX}/NPOESS.VISwater.EmisCoeff.bin
emiscoef_MWwater=${CRTMFIX}/FASTEM6.MWwater.EmisCoeff.bin
aercoef=${CRTMFIX}/AerosolCoeff.bin
cldcoef=${CRTMFIX}/CloudCoeff.bin

ln -s $emiscoef_IRwater ./Nalli.IRwater.EmisCoeff.bin
ln -s $emiscoef_IRice ./NPOESS.IRice.EmisCoeff.bin
ln -s $emiscoef_IRsnow ./NPOESS.IRsnow.EmisCoeff.bin
ln -s $emiscoef_IRland ./NPOESS.IRland.EmisCoeff.bin
ln -s $emiscoef_VISice ./NPOESS.VISice.EmisCoeff.bin
ln -s $emiscoef_VISland ./NPOESS.VISland.EmisCoeff.bin
ln -s $emiscoef_VISsnow ./NPOESS.VISsnow.EmisCoeff.bin
ln -s $emiscoef_VISwater ./NPOESS.VISwater.EmisCoeff.bin
ln -s $emiscoef_MWwater ./FASTEM6.MWwater.EmisCoeff.bin
ln -s $aercoef  ./AerosolCoeff.bin
ln -s $cldcoef  ./CloudCoeff.bin
# Copy CRTM coefficient files based on entries in satinfo file
for file in `awk '{if($1!~"!"){print $1}}' ./satinfo | sort | uniq` ;do
   ln -s ${CRTMFIX}/${file}.SpcCoeff.bin ./
   ln -s ${CRTMFIX}/${file}.TauCoeff.bin ./
done

# Get aircraft reject list
# Timing is set up to mimic realtime as of 24 Jun 2016
# We switch to the new day file at 08 UTC
if [[ ${HH} -eq '00' || ${HH} -eq '01' || ${HH} -eq '02' || ${HH} -eq '03' || ${HH} -eq '04' || ${HH} -eq '05' || ${HH} -eq '06' || ${HH} -eq '07' ]]; then
  cp ${AIRCRAFT_REJECT}/${YYYYMMDD_2}_rejects.txt ./current_bad_aircraft
else
  cp ${AIRCRAFT_REJECT}/${YYYYMMDD}_rejects.txt ./current_bad_aircraft
fi

# Similar thing for mesonet uselist
# We switch to the new day file at 10 UTC
if [[ ${HH} -eq '00' || ${HH} -eq '01' || ${HH} -eq '02' || ${HH} -eq '03' || ${HH} -eq '04' || ${HH} -eq '05' || ${HH} -eq '06' || ${HH} -eq '07' || ${HH} -eq '08' || ${HH} -eq '09' ]]; then
   cp ${SFCOBS_USELIST}/${YYYY_2}-${MM_2}-${DD_2}_meso_uselist.txt ./gsd_sfcobs_uselist.txt
else
   cp ${SFCOBS_USELIST}/${YYYY}-${MM}-${DD}_meso_uselist.txt ./gsd_sfcobs_uselist.txt
fi

cp ${fixdir}/gsd_sfcobs_provider.txt gsd_sfcobs_provider.txt

# Only need this file for single obs test
bufrtable=${fixdir}/prepobs_prep.bufrtable
cp $bufrtable ./prepobs_prep.bufrtable

# Set some parameters for use by the GSI executable and to build the namelist
export JCAP=62
export LEVS=60
export DELTIM=${DELTIM:-$((3600/($JCAP/20)))}
ndatrap=62
grid_ratio=1
cloudanalysistype=0  # Turn off cloud analysis

# Build the GSI namelist on-the-fly
. ${fixdir}/gsiparm.anl.sh
cat << EOF > gsiparm.anl
$gsi_namelist
EOF

## satellite bias correction
latest_bias=${DATAROOT}/satbias/satbias_out_latest
latest_bias_pc=${DATAROOT}/satbias/satbias_pc.out_latest
latest_radstat=${DATAROOT}/satbias/radstat.rap_latest

cp $latest_bias ./satbias_in
cp $latest_bias_pc ./satbias_pc
cp $latest_radstat ./radstat.rap

listdiag=`tar xvf radstat.rap | cut -d' ' -f2 | grep _ges`
for type in $listdiag; do
       diag_file=`echo $type | cut -d',' -f1`
       fname=`echo $diag_file | cut -d'.' -f1`
       date=`echo $diag_file | cut -d'.' -f2`
       gunzip $diag_file
       fnameanl=$(echo $fname|sed 's/_ges//g')
       mv $fname.$date $fnameanl
done


# Run GSI
#${MPIRUN} ${GSI} < gsiparm.anl > stdout 2>&1
module load contrib wrap-mpi
mpirun ${GSI} < gsiparm.anl > stdout 2>&1
error=$?
if [ ${error} -ne 0 ]; then
  ${ECHO} "ERROR: ${GSI} crashed  Exit status=${error}"
  cp stdout ../.
  exit ${error}
fi

ls -l > GSI_workdir_list

# Look for successful completion messages in rsl files
nsuccess=`${TAIL} -20 stdout | ${AWK} '/PROGRAM GSI_ANL HAS ENDED/' | ${WC} -l`
ntotal=1 
${ECHO} "Found ${nsuccess} of ${ntotal} completion messages"
if [ ${nsuccess} -ne ${ntotal} ]; then
   ${ECHO} "ERROR: ${GSI} did not complete sucessfully  Exit status=${error}"
   cp stdout ../.
   cp GSI_workdir_list ../.
   if [ ${error} -ne 0 ]; then
     exit ${error}
   else
     exit 1
   fi
fi

# Loop over first and last outer loops to generate innovation
# diagnostic files for indicated observation types (groups)
#
# NOTE:  Since we set miter=2 in GSI namelist SETUP, outer
#        loop 03 will contain innovations with respect to 
#        the analysis.  Creation of o-a innovation files
#        is triggered by write_diag(3)=.true.  The setting
#        write_diag(1)=.true. turns on creation of o-g
#        innovation files.
#

loops="01 03"
for loop in $loops; do

case $loop in
  01) string=ges;;
  03) string=anl;;
   *) string=$loop;;
esac

#  Collect diagnostic files for obs types (groups) below
listall="hirs2_n14 msu_n14 sndr_g08 sndr_g11 sndr_g11 sndr_g12 sndr_g13 sndr_g08_prep sndr_g11_prep sndr_g12_prep sndr_g13_prep sndrd1_g11 sndrd2_g11 sndrd3_g11 sndrd4_g11 sndrd1_g15 sndrd2_g15 sndrd3_g15 sndrd4_g15 sndrd1_g13 sndrd2_g13 sndrd3_g13 sndrd4_g13 hirs3_n15 hirs3_n16 hirs3_n17 amsua_n15 amsua_n16 amsua_n17 amsua_n18 amsua_n19 amsua_metop-a amsua_metop-b amsub_n15 amsub_n16 amsub_n17 hsb_aqua airs_aqua amsua_aqua imgr_g08 imgr_g11 imgr_g12 pcp_ssmi_dmsp pcp_tmi_trmm conv sbuv2_n16 sbuv2_n17 sbuv2_n18 omi_aura ssmi_f13 ssmi_f14 ssmi_f15 hirs4_n18 hirs4_metop-a mhs_n18 mhs_n19 mhs_metop-a mhs_metop-b amsre_low_aqua amsre_mid_aqua amsre_hig_aqua ssmis_las_f16 ssmis_uas_f16 ssmis_img_f16 ssmis_env_f16 iasi_metop-a iasi_metop-b seviri_m08 seviri_m09 seviri_m10 seviri_m11 cris_npp atms_npp ssmis_f17 cris-fsr_npp cris-fsr_n20 atms_n20 abi_g16"
   for type in $listall; do
      count=`ls pe*.${type}_${loop}* | wc -l`
      if [[ $count -gt 0 ]]; then
         `cat pe*.${type}_${loop}* > diag_${type}_${string}.${YYYYMMDDHH}`
      fi
   done
done



# save results from 1st run
${CP} fort.201    fit_p1.${YYYYMMDDHH}
${CP} fort.202    fit_w1.${YYYYMMDDHH}
${CP} fort.203    fit_t1.${YYYYMMDDHH}
${CP} fort.204    fit_q1.${YYYYMMDDHH}
${CP} fort.207    fit_rad1.${YYYYMMDDHH}
cat fort.* > ${DATABASE_DIR}/log/fits_${YYYYMMDDHH}.txt

#---------------------------------------------------------------------
# Compute date & time components for the snow cover analysis time relative to current analysis time
YYJJJHH00000000=`${DATE} +"%y%j%H00000000" -d "${START_TIME} 4 hours ago"`

if [[ ${HH} -eq ${UPDATE_SNOW} ]]; then
  echo "Update snow cover based on imssnow"
  if [ -r "${NCEPSNOW}/latest.SNOW_IMS" ]; then
     ${CP} ${NCEPSNOW}/latest.SNOW_IMS ./imssnow2
  elif [ -r "${NCEPSNOW}/${YYJJJHH00000000}" ]; then
     ${CP} ${NCEPSNOW}/${YYJJJHH00000000} ./imssnow2
  else
    ${ECHO} "${NCEPSNOW} data does not exist!!"
    ${ECHO} "ERROR: No snow triming for background at ${time_str}!!!!"
  fi  
  if [ -r "imssnow2" ]; then
     ${CNVGRIB} -g21 imssnow2 imssnow
     ${CP} ${STATIC_DIR}/WPS/geo_em.d01.nc ./geo_em.d01.nc
     ${CP} ${STATIC_DIR}/UPP/nam_imsmask ./nam_imsmask
     ${MPIRUN} --ntasks=1 ${GSI_ROOT}/process_NESDIS_imssnow.exe > stdout_snowupdate 2>&1
  else
    ${ECHO} "ERROR: No imssnow2 file for snow triming for background at ${time_str}!!!!"
  fi  
else
  ${ECHO} "NOTE: No update for snow cover at ${time_str}!"
fi

# Update HRRR fractional sea ice with FVCOM data for every run
# We are currently dealing with an 8h 30min latency in the files...
if [ ${HH} -eq 00 -o ${HH} -eq 12 ]; then
  hour_diff=4
  YYYYJJJHH_fvcom=`${DATE} +"%Y%j%H" -d "${START_TIME} 12 hours ago"`
elif [ ${HH} -eq 01 -o ${HH} -eq 13 ]; then
  hour_diff=4
  YYYYJJJHH_fvcom=`${DATE} +"%Y%j%H" -d "${START_TIME} 13 hours ago"`
elif [ ${HH} -eq 02 -o ${HH} -eq 14 ]; then
  hour_diff=5
  YYYYJJJHH_fvcom=`${DATE} +"%Y%j%H" -d "${START_TIME} 14 hours ago"`
elif [ ${HH} -eq 03 -o ${HH} -eq 15 ]; then
  hour_diff=5
  YYYYJJJHH_fvcom=`${DATE} +"%Y%j%H" -d "${START_TIME} 15 hours ago"`
elif [ ${HH} -eq 04 -o ${HH} -eq 16 ]; then
  hour_diff=5
  YYYYJJJHH_fvcom=`${DATE} +"%Y%j%H" -d "${START_TIME} 16 hours ago"`
elif [ ${HH} -eq 05 -o ${HH} -eq 17 ]; then
  hour_diff=6
  YYYYJJJHH_fvcom=`${DATE} +"%Y%j%H" -d "${START_TIME} 17 hours ago"`
elif [ ${HH} -eq 06 -o ${HH} -eq 18 ]; then
  hour_diff=6
  YYYYJJJHH_fvcom=`${DATE} +"%Y%j%H" -d "${START_TIME} 18 hours ago"`
elif [ ${HH} -eq 07 -o ${HH} -eq 19 ]; then
  hour_diff=6
  YYYYJJJHH_fvcom=`${DATE} +"%Y%j%H" -d "${START_TIME} 19 hours ago"`
elif [ ${HH} -eq 08 -o ${HH} -eq 20 ]; then
  hour_diff=7
  YYYYJJJHH_fvcom=`${DATE} +"%Y%j%H" -d "${START_TIME} 20 hours ago"`
elif [ ${HH} -eq 09 -o ${HH} -eq 21 ]; then
  hour_diff=3
  YYYYJJJHH_fvcom=`${DATE} +"%Y%j%H" -d "${START_TIME} 9 hours ago"`
elif [ ${HH} -eq 10 -o ${HH} -eq 22 ]; then
  hour_diff=3
  YYYYJJJHH_fvcom=`${DATE} +"%Y%j%H" -d "${START_TIME} 10 hours ago"`
else
  hour_diff=4
  YYYYJJJHH_fvcom=`${DATE} +"%Y%j%H" -d "${START_TIME} 11 hours ago"`
fi

cat << EOF > fvcom.namelist
   &SETUP
     update_type = 2,
     t2 = ${hour_diff},
   /
EOF

if [ -r "${FVCOM}/tsfc_hrrrgrid_${YYYYJJJHH_fvcom}.nc" ]; then
  echo "FVCOM update for fractional lake ice."
  ${CP} ${FVCOM}/tsfc_hrrrgrid_${YYYYJJJHH_fvcom}.nc ./fvcom.nc
  ${CP} ${STATIC_DIR}/WPS/geo_em.d01.nc ./geo_em.d01.nc
  ${MPIRUN} --ntasks=1 ${GSI_ROOT}/process_FVCOM.exe < fvcom.namelist > stdout_fvcomice 2>&1
else
  ${ECHO} "${FVCOM}/tsfc_hrrrgrid_${YYYYJJJHH_fvcom}.nc does not exist!!"
  ${ECHO} "ERROR: No FVCOM update at ${time_str}!!!!"
fi

${MV} fvcom.namelist fvcom.namelist.ice

cat << EOF > fvcom.namelist
   &SETUP
     update_type = 1,
     t2 = ${hour_diff},
   /
EOF

if [ -r "${FVCOM}/tsfc_hrrrgrid_${YYYYJJJHH_fvcom}.nc" ]; then
  echo "FVCOM update for lake surface temperatures."
  ${CP} ${FVCOM}/tsfc_hrrrgrid_${YYYYJJJHH_fvcom}.nc ./fvcom.nc
  ${MPIRUN} --ntasks=1 ${GSI_ROOT}/process_FVCOM.exe < fvcom.namelist > stdout_fvcomsst 2>&1
else
  ${ECHO} "${FVCOM}/tsfc_hrrrgrid_${YYYYJJJHH_fvcom}.nc does not exist!!"
  ${ECHO} "ERROR: No FVCOM update at ${time_str}!!!!"
fi

exit 0
