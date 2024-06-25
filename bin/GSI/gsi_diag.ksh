#!/bin/ksh --login

ulimit -s 512000

# Vars used for testing.  Should be commented out for production mode
#ENV_DIR='/mnt/lfs4/BMC/wrfruc/murdzek/HRRR_OSSE/real_data_sims/winter/WRF_FCST_OSSE/env/JET'
#DATAHOME='/mnt/lfs4/BMC/wrfruc/murdzek/HRRR_OSSE/real_data_sims/winter/WRF_FCST_OSSE/run/2022020109/gsiprd'
#GSI_ROOT='/mnt/lfs4/BMC/wrfruc/murdzek/HRRR_OSSE/real_data_sims/winter/WRF_FCST_OSSE/exec/GSI'
#SPINUP=0
#SKIP_GSI_FIRST_SPINUP=1
#START_TIME=2022020109

# Load modules
module purge
module use ${ENV_DIR}
module load env_gsi_diag

# Set up paths to unix commands
RM=/bin/rm
CP=/bin/cp
MV=/bin/mv
LN=/bin/ln
MKDIR=/bin/mkdir
CAT=/bin/cat
ECHO=/bin/echo
CUT=/bin/cut
WC=/usr/bin/wc
DATE=/bin/date
AWK="/bin/awk --posix"
SED=/bin/sed
TAIL=/usr/bin/tail
MPIRUN=srun

# Make sure DATAHOME is defined and exists
if [ ! "${DATAHOME}" ]; then
  ${ECHO} "ERROR: \$DATAHOME is not defined!"
  exit 1
fi
if [ ! -d "${DATAHOME}" ]; then
  ${ECHO} "ERROR: DATAHOME directory '${DATAHOME}' does not exist!"
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

# Make sure SPINUP is defined
if [ ! "${SPINUP}" ]; then
  ${ECHO} "ERROR: \$SPINUP is not defined!"
  exit 1
fi

# Make sure SKIP_GSI_FIRST_SPINUP is defined
if [ ! "${SKIP_GSI_FIRST_SPINUP}" ]; then
  ${ECHO} "ERROR: \$SKIP_GSI_FIRST_SPINUP is not defined!"
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

# Compute date & time components for the analysis time
YYMMDDHH=`${DATE} +"%y%m%d%H" -d "${START_TIME}"`
YYYYMMDDHH=`${DATE} +"%Y%m%d%H" -d "${START_TIME}"`
HH=`${DATE} +"%H" -d "${START_TIME}"`

# Create the ram work directory and cd into it
workdir=${DATAHOME}
cd ${workdir}

# Skip if GSI was not run
if [ ${SPINUP} -eq 1 ] && [ ${SKIP_GSI_FIRST_SPINUP} -eq 1 ]; then
  if [ ${HH} -eq "03" ] || [ ${HH} -eq "15" ]; then
    exit 0
  fi
fi

# Read conventional observation diag files

# SSM 20240625 OLD - DO NOT USE
#${CAT} << EOF > namelist.conv
# &iosetup
#  dirname='${workdir}',
#  outfilename='./diag_results',
#  ndate=${YYMMDDHH},
#  nloop=1,0,1,0,0,
#  $iosetup
# /     
#EOF
#
#cp ${GSI_ROOT}/read_diag_conv.exe .
#./read_diag_conv.exe > stdout_read_diag_conv 2>&1

cp ${GSI_ROOT}/read_diag_conv.exe .

${CAT} << EOF > namelist.conv
 &iosetup
  infilename='${workdir}/diag_conv_ges.${YYYYMMDDHH}',
  outfilename='${workdir}/diag_results.conv_ges',
  l_obsprvdiag=.false.,
  dump_pseudo_obs_too=.true.,
  $iosetup
 /     
EOF
./read_diag_conv.exe > stdout_read_diag_conv_ges 2>&1

${CAT} << EOF > namelist.conv
 &iosetup
  infilename='${workdir}/diag_conv_anl.${YYYYMMDDHH}',
  outfilename='${workdir}/diag_results.conv_anl',
  l_obsprvdiag=.false.,
  dump_pseudo_obs_too=.true.,
  $iosetup
 /     
EOF
./read_diag_conv.exe > stdout_read_diag_conv_anl 2>&1


# SSM 20240625: Turn off GSI diag file reader for satellite radiances (no satellite DA in OSSE)
# Read radiance diag file
#${CAT} << EOF > namelist.rad
# &iosetup
#  dirname='${workdir}',
#  outfilename='./diag_results',
#  ndate=${YYMMDDHH},
#  nloop=1,0,1,0,0,
#  instrument='amsub_n16','amsub_n17','hirs3_n17',
#  $iosetup
# /
#EOF

# SSM 20240625: Turn off ob counter b/c I cannot find the executable
#
#  Data number summary
#
#cp ${GSI_ROOT}/count_obs.exe . 
#./count_obs.exe > stdout_count_obs 2>&1
#cat obs_num_summary.txt >> ${DATABASE_DIR}/loghistory/HRRR_GSI_dataNumber.log

exit 0
