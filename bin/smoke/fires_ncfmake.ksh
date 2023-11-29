#!/bin/ksh --login

np=`cat $PBS_NODEFILE | wc -l`

# Load modules
module purge
module load szip/2.1
module load intel/18.0.5.274
module load impi/2018.4.274
module load hdf5/1.8.9
module load netcdf/4.2.1.1
module load pnetcdf/1.6.1

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
MPIRUN=srun
CNVGRIB=${EXE_ROOT}/cnvgrib.exe
CNVOPTS='-g12 -p32'

# Print run parameters
${ECHO}
${ECHO} "fires_ncfmake.ksh started at `${DATE}`"
${ECHO}
${ECHO} "DATAHOME = ${DATAHOME}"
${ECHO} "START_TIME = ${START_TIME}"

# Check to make sure that the DATAHOME exists
if [ ! ${DATAHOME} ]; then
  ${ECHO} "ERROR: DATAHOME, \$DATAHOME, is not defined"
  exit 1
fi

# Check to make sure that the START_TIME is defined and in the correct format
if [ ! "${START_TIME}" ]; then
  ${ECHO} "ERROR: START_TIME, \$START_TIME, is not defined"
  exit 1
fi

# Check to make sure that the EXECUTABLE exists
if [ ! ${EXEC} ]; then
  ${ECHO} "ERROR: EXEC, \$EXEC, is not defined"
  exit 1
fi

# Check to make sure the wrf_inout file exists
if [ ! -r ${DATAGSIHOME}/wrf_inout ]; then
  ${ECHO} "ERROR: ${DATAGSIHOME}/wrf_inout does not exist, or is not readable"
  exit 1
fi

# cd into the work directory
workdir=${DATAHOME}/${START_TIME}
cd ${workdir}/emisprd

# Check to make sure the emissions file exists
if [ ! -r ${workdir}/emisprd/emissfire_d01 ]; then
  ${ECHO} "ERROR: ${workdir}/emisprd/emissfire_d01 does not exist, or is not readable"
  exit 1
fi

ln -s ${DATAGSIHOME}/wrf_inout ./wrfinput_d01
input_file=${workdir}/emisprd/wrfinput_d01
binary_file=${workdir}/emisprd/emissfire_d01

${EXEC} ${input_file} ${binary_file}

${ECHO} "fires_ncfmake.ksh completed at `${DATE}`"

exit 0
