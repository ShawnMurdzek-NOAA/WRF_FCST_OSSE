#!/bin/ksh --login

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

# Vars used for testing.  Should be commented out for production mode

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

# Create the ram work directory and cd into it
workdir=${DATAHOME}
cd ${workdir}

# Read conventional observation diag files

${CAT} << EOF > namelist.conv
 &iosetup
  dirname='${workdir}',
  outfilename='./diag_results',
  ndate=${YYMMDDHH},
  nloop=1,0,1,0,0,
  $iosetup
 /     
EOF

cp ${GSI_ROOT}/read_diag_conv.exe .
./read_diag_conv.exe > stdout_read_diag_conv 2>&1

# Read radiance diag file
${CAT} << EOF > namelist.rad
 &iosetup
  dirname='${workdir}',
  outfilename='./diag_results',
  ndate=${YYMMDDHH},
  nloop=1,0,1,0,0,
  instrument='amsub_n16','amsub_n17','hirs3_n17',
  $iosetup
 /
EOF

cp ${GSI_ROOT}/read_diag_rad.exe .
./read_diag_rad.exe > stdout_read_diag_rad 2>&1

#
#  Data number summary
#
cp ${GSI_ROOT}/count_obs.exe . 
./count_obs.exe > stdout_count_obs 2>&1
cat obs_num_summary.txt >> ${DATABASE_DIR}/loghistory/HRRR_GSI_dataNumber.log

exit 0
