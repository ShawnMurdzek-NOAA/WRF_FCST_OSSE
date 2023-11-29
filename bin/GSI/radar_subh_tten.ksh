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
MPIRUN=srun
NCKS=ncks  #use default ncks in loaded nco version

## export MV2_ON_DEMAND_THRESHOLD=256
export MPI_VERBOSE=1
export MPI_DISPLAY_SETTINGS=1
export MPI_BUFS_PER_PROC=128
export MPI_BUFS_PER_HOST=128
export MPI_IB_RAILS=2
export MPI_GROUP_MAX=128
export WRFIO_NCD_LARGE_FILE_SUPPORT=1

# Set the path to the reftten executable
TTENEXE=${GSI_ROOT}/ref2tten.exe

# Set the path to the GSI static files
fixdir=${FIX_ROOT}

# Make sure DATAHOME is defined and exists
if [ ! "${DATAHOME}" ]; then
  ${ECHO} "ERROR: \$DATAHOME is not defined!"
  exit 1
fi

# Make sure GSI_ROOT is defined and exists
if [ ! "${GSI_ROOT}" ]; then
  ${ECHO} "ERROR: \$GSI_ROOT is not defined!"
  exit 1
fi
if [ ! -d "${GSI_ROOT}" ]; then
  ${ECHO} "ERROR: GSI_ROOT directory '${GSI_ROOT}' does not exist!"
  exit 1
fi

# Make sure DATAHOME_BK is defined and exists
if [ ! "${DATAHOME_BK}" ]; then
  ${ECHO} "ERROR: \$DATAHOME_BK is not defined!"
  exit 1
fi
if [ ! -d "${DATAHOME_BK}" ]; then
  ${ECHO} "ERROR: DATAHOME_BK directory '${DATAHOME_BK}' does not exist!"
  exit 1
fi

# Check to make sure that STATIC_PATH exists
if [ ! -d ${STATIC_DIR} ]; then
  ${ECHO} "ERROR: ${STATIC_DIR} does not exist"
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

# Make sure the reflectivity to tten executable exists
if [ ! -x "${TTENEXE}" ]; then
  ${ECHO} "ERROR: ${TTENEXE} does not exist!"
  exit 1
fi

# Compute date & time components for the analysis time
YYYYJJJHH00=`${DATE} +"%Y%j%H00" -d "${START_TIME}"`
YYYYMMDDHH=`${DATE} +"%Y%m%d%H" -d "${START_TIME}"`
YYYYMMDD=`${DATE} +"%Y%m%d" -d "${START_TIME}"`
YYYY=`${DATE} +"%Y" -d "${START_TIME}"`
MM=`${DATE} +"%m" -d "${START_TIME}"`
DD=`${DATE} +"%d" -d "${START_TIME}"`
HH=`${DATE} +"%H" -d "${START_TIME}"`

# Create the working directory and cd into it
workdir=${DATAHOME}
${RM} -rf ${workdir}
${MKDIR} -p ${workdir}
cd ${workdir}

# Save a copy of the reflectivity to tten executable in the workdir
${CP} ${TTENEXE} .

# Bring over background field (it's modified so we can't link to it)
if [ -r ${DATAHOME_BK}/wrfinput_d01 ]; then
  ${ECHO} " Run using ${DATAHOME_BK}/wrfinput_d01"
  cp ${DATAHOME_BK}/wrfinput_d01 ./wrf_inout

  if [ ! -r "${HRRRDAS_MEAN}" ]; then
    ${ECHO} " Cycle ${YYYYMMDDHH}: TTEN background is from RAP: ${DATAHOME_BK}/wrfinput_d01"

  else ##use HRRRDAS mean
    ensmean_list="U,V,W,PH,PHB,T,MU,MUB,P,PB,P_HYD,Q2,T2,TH2,PSFC,U10,V10,WSPD10,WSPD80,QVAPOR,QCLOUD,QRAIN,QICE,QSNOW,QGRAUP,QNICE,QNRAIN,QNCLOUD,TSLB,SMOIS,TSK,RAINC,RAINNC,REFL_10CM,SWDOWN,W_UP_MAX,PREC_ACC_NC"
    if [ ! -s "${HRRRDAS_MEAN}" ]; then
      ${ECHO} "ERROR: HRRRDAS_MEAN '${HRRRDAS_MEAN}' has zero size!"
      exit 1
    fi
    ncks -A -H -d west_east,0,1798 -d west_east_stag,0,1799 -d south_north,0,1058 -d south_north_stag,0,1059 -v ${ensmean_list} ${HRRRDAS_MEAN} ./wrf_inout
    ${ECHO} " Cycle ${YYYYMMDDHH}: TTEN background is from HRRRDAS: ${HRRRDAS_MEAN}"
  fi

# No background available so abort
else
  ${ECHO} "${DATAHOME_BK}/wrfinput_d01 does not exist"
  ${ECHO} "ERROR: No background file for analaysis at ${YYYYMMDDHH}!!!!"
  ${ECHO} " Cycle ${YYYYMMDDHH}: TTEN failed because of no background"
  exit 1
fi

# Insert land surface variables into the wrf_inout file
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
  exit 1
fi

# Update GVF with real-time data
if [ -r ${GVF}/GVF-WKL-GLB_v2r3_npp_*_c${YYYYMMDD}*.grib2 ]; then
   echo "Update GVF based on VIIRS"
   ln -s ${fixdir}/gvf_VIIRS_4KM.MIN.1gd4r.new gvf_VIIRS_4KM.MIN.1gd4r.new
   ln -s ${fixdir}/gvf_VIIRS_4KM.MAX.1gd4r.new gvf_VIIRS_4KM.MAX.1gd4r.new
   cp ${GVF}/GVF-WKL-GLB_v2r3_npp_*_c${YYYYMMDD}*.grib2 GVF-WKL-GLB.grib2
   ${MPIRUN} --ntasks=1 ${GSI_ROOT}/update_GVF.exe > stdout_updateGVF 2>&1
else
   ${ECHO} "${GVF}/GVF-WKL-GLB_v1r0_npp_${YYYYMMDD} does not exist!!"
   ${ECHO} "Warning: No GVF real-time data available for background at ${time_str}!!!!"
fi

# Link to the radar binary data
subhtimes="15 30 45 60"
count=1
for subhtime in ${subhtimes}; do
  if [ -r "${DATAOBSHOME}/${subhtime}/RefInGSI3D.dat" ]; then
    ${LN} -s ${DATAOBSHOME}/${subhtime}/RefInGSI3D.dat ./RefInGSI3D.dat_0${count}
  else
    ${ECHO} "Warning ${DATAOBSHOME}/${subhtime}/RefInGSI3D.dat does not exist!"
  fi
  count=$((count + 1))
done

# Link to the lightning binary data
subhtimes="15 30 45 60"
count=1
for subhtime in ${subhtimes}; do
  if [ -r "${DATAOBSHOME}/${subhtime}/LightningInGSI.dat" ]; then
    ${LN} -s ${DATAOBSHOME}/${subhtime}/LightningInGSI.dat ./LightningInGSI.dat_0${count}
  else
    ${ECHO} "Warning ${DATAOBSHOME}/${subhtime}/LightningInGSI.dat does not exist!"
  fi  
  count=$((count + 1))
done

# Link to the satcast binary data
#subhtimes="15 30 45 60"
#count=1
#for subhtime in ${subhtimes}; do
#  if [ -r "${DATAOBSHOME}/${subhtime}/ScstInGSI.dat" ]; then
#    ${LN} -s ${DATAOBSHOME}/${subhtime}/ScstInGSI.dat ./ScstInGSI3D.dat_0${count}
#  else
#    ${ECHO} "Warning ${DATAOBSHOME}/${subhtime}/ScstInGSI.dat does not exist!"
#  fi  
#  count=$((count + 1))
#done

# Run radar to tten
${MPIRUN} ${TTENEXE} > stdout_refltotten 2>&1
error=$?
if [ ${error} -ne 0 ]; then
  ${ECHO} "ERROR: ${TTENEXE} crashed  Exit status=${error}"
  exit ${error}
fi

exit 0
