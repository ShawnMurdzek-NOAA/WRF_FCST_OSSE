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

# Necessary on Hercules to avoid crashes
ulimit -s unlimited
ulimit -a

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
CNVOPTS='-g12 -p32'

# Print run parameters
${ECHO}
${ECHO} "unipost.ksh started at `${DATE}`"
${ECHO}
${ECHO} "DATAHOME = ${DATAHOME}"
${ECHO} "     EXE_ROOT = ${EXE_ROOT}"

# Set up some constants
if [ "${MODEL}" == "RAP" ]; then
  export POST=${EXE_ROOT}/ncep_post.exe
  export CORE=RAPR
elif [ "${MODEL}" == "WRF-RR NMM" ]; then
  export POST=${EXE_ROOT}/ncep_post.exe
  export CORE=NMM
fi

# Check to make sure the EXE_ROOT var was specified
if [ ! -d ${EXE_ROOT} ]; then
  ${ECHO} "ERROR: EXE_ROOT, '${EXE_ROOT}', does not exist"
  exit 1
fi

# Check to make sure the post executable exists
if [ ! -x ${POST} ]; then
  ${ECHO} "ERROR: ${POST} does not exist, or is not executable"
  exit 1
fi

# Check to make sure that the DATAHOME exists
if [ ! ${DATAHOME} ]; then
  ${ECHO} "ERROR: DATAHOME, \$DATAHOME, is not defined"
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

# Set up the work directory and cd into it
workdir=${DATAHOME}/${FCST_TIME}
${RM} -rf ${workdir}
${MKDIR} -p ${workdir}
cd ${workdir}

# Set up some constants
export XLFRTEOPTS="unit_vars=yes"
export MP_SHARED_MEMORY=yes
export SPLNUM=47
export SPL=2.,5.,7.,10.,20.,30.\
,50.,70.,75.,100.,125.,150.,175.,200.,225.\
,250.,275.,300.,325.,350.,375.,400.,425.,450.\
,475.,500.,525.,550.,575.,600.,625.,650.\
,675.,700.,725.,750.,775.,800.,825.,850.\
,875.,900.,925.,950.,975.,1000.,1013.2


timestr=`${DATE} +%Y-%m-%d_%H_%M_%S -d "${START_TIME}  ${FCST_TIME} hours"`
timestr2=`${DATE} +%Y-%m-%d_%H:%M:%S -d "${START_TIME}  ${FCST_TIME} hours"`

post_yyyy=`${DATE} +%Y -d "${START_TIME}  ${FCST_TIME} hours"`
post_mm=`${DATE} +%m -d "${START_TIME}  ${FCST_TIME} hours"`
post_dd=`${DATE} +%d -d "${START_TIME}  ${FCST_TIME} hours"`
post_hh=`${DATE} +%H -d "${START_TIME}  ${FCST_TIME} hours"`
post_min=`${DATE} +%M -d "${START_TIME}  ${FCST_TIME} hours"`

cat > itag <<EOF
&model_inputs
 fileName='${DATAWRFHOME}/wrfout_d01_${timestr}'
 IOFORM='netcdf'
 grib='grib2'
 DateStr='${post_yyyy}-${post_mm}-${post_dd}_${post_hh}:${post_min}:00'
 MODELNAME='RAPR'
 SUBMODELNAME=''
 fileNameFlux='${DATAWRFHOME}/wrfout_d01_${timestr}'
 fileNameFlat='postxconfig-NT.txt'
/

 &NAMPGB
 KPO=47,PO=1013.2,1000.,975.,950.,925.,900.,875.,850.,825.,800.,775.,750.,725.,700.,675.,650.,625.,600.,575.,550.,525.,500.,475.,450.,425.,400.,375.,350.,325.,300.,275.,250.,225.,200.,175.,150.,125.,100.,75.,70.,50.,30.,20.,10.,7.,5.,2.,
 /
EOF

#${CAT} > itag <<EOF
#${DATAWRFHOME}/wrfout_d01_${timestr}
#netcdf
#grib2
#${timestr2}
#${CORE}
#${SPLNUM}
#${SPL}
#${VALIDTIMEUNITS}
#EOF

${RM} -f fort.*
ln -s ${STATIC_DIR}/post_avblflds.xml post_avblflds.xml
ln -s ${STATIC_DIR}/params_grib2_tbl_new params_grib2_tbl_new
if [ "${MACHINE}" == "HERCULES" ]; then
  # Newer HRRR flat text file for Hercules (generated using ${STATIC_DIR}/postcntrl_hrrr_hercules.xml)
  ln -s ${STATIC_DIR}/postxconfig-NT-hrrr-hercules.txt postxconfig-NT.txt
  ln -s ${STATIC_DIR}/postcntrl_hrrr_hercules.xml postcntrl.xml
else
  # Original flat text file, which does not work on Hercules
  ln -s ${STATIC_DIR}/postxconfig-NT.txt postxconfig-NT.txt
  ln -s ${STATIC_DIR}/postcntrl.xml postcntrl.xml
fi
ln -s ${STATIC_DIR}/gtg.config.raphrrr gtg.config
if [ "${MODEL}" == "RAP" ]; then
  ln -s ${STATICWRF_DIR}/run/ETAMPNEW_DATA eta_micro_lookup.dat
elif [ "${MODEL}" == "WRF-RR NMM" ]; then
  ln -s ${STATICWRF_DIR}/run/ETAMPNEW_DATA eta_micro_lookup.dat
fi

# Link all binary files instead of doing each on individually
ln -snf ${CRTM}/*bin ./

#ln -s ${CRTM}/imgr_g11.SpcCoeff.bin imgr_g11.SpcCoeff.bin
#ln -s ${CRTM}/imgr_g12.SpcCoeff.bin imgr_g12.SpcCoeff.bin
#ln -s ${CRTM}/imgr_g13.SpcCoeff.bin imgr_g13.SpcCoeff.bin
#ln -s ${CRTM}/imgr_g15.SpcCoeff.bin imgr_g15.SpcCoeff.bin
#ln -s ${CRTM}/imgr_mt1r.SpcCoeff.bin imgr_mt1r.SpcCoeff.bin
#ln -s ${CRTM}/imgr_mt2.SpcCoeff.bin imgr_mt2.SpcCoeff.bin
#ln -s ${CRTM}/amsre_aqua.SpcCoeff.bin amsre_aqua.SpcCoeff.bin
#ln -s ${CRTM}/tmi_trmm.SpcCoeff.bin tmi_trmm.SpcCoeff.bin
#ln -s ${CRTM}/ssmi_f13.SpcCoeff.bin ssmi_f13.SpcCoeff.bin
#ln -s ${CRTM}/ssmi_f14.SpcCoeff.bin ssmi_f14.SpcCoeff.bin
#ln -s ${CRTM}/ssmi_f15.SpcCoeff.bin ssmi_f15.SpcCoeff.bin
#ln -s ${CRTM}/ssmis_f16.SpcCoeff.bin ssmis_f16.SpcCoeff.bin
#ln -s ${CRTM}/ssmis_f17.SpcCoeff.bin ssmis_f17.SpcCoeff.bin
#ln -s ${CRTM}/ssmis_f18.SpcCoeff.bin ssmis_f18.SpcCoeff.bin
#ln -s ${CRTM}/ssmis_f19.SpcCoeff.bin ssmis_f19.SpcCoeff.bin
#ln -s ${CRTM}/ssmis_f20.SpcCoeff.bin ssmis_f20.SpcCoeff.bin
#ln -s ${CRTM}/seviri_m10.SpcCoeff.bin seviri_m10.SpcCoeff.bin
#ln -s ${CRTM}/v.seviri_m10.SpcCoeff.bin v.seviri_m10.SpcCoeff.bin
#ln -s ${CRTM}/imgr_insat3d.SpcCoeff.bin imgr_insat3d.SpcCoeff.bin

#ln -s ${CRTM}/imgr_g11.TauCoeff.bin imgr_g11.TauCoeff.bin
#ln -s ${CRTM}/imgr_g12.TauCoeff.bin imgr_g12.TauCoeff.bin
#ln -s ${CRTM}/imgr_g13.TauCoeff.bin imgr_g13.TauCoeff.bin
#ln -s ${CRTM}/imgr_g15.TauCoeff.bin imgr_g15.TauCoeff.bin
#ln -s ${CRTM}/imgr_mt1r.TauCoeff.bin imgr_mt1r.TauCoeff.bin
#ln -s ${CRTM}/imgr_mt2.TauCoeff.bin imgr_mt2.TauCoeff.bin
#ln -s ${CRTM}/amsre_aqua.TauCoeff.bin amsre_aqua.TauCoeff.bin
#ln -s ${CRTM}/tmi_trmm.TauCoeff.bin tmi_trmm.TauCoeff.bin
#ln -s ${CRTM}/ssmi_f13.TauCoeff.bin ssmi_f13.TauCoeff.bin
#ln -s ${CRTM}/ssmi_f14.TauCoeff.bin ssmi_f14.TauCoeff.bin
#ln -s ${CRTM}/ssmi_f15.TauCoeff.bin ssmi_f15.TauCoeff.bin
#ln -s ${CRTM}/ssmis_f16.TauCoeff.bin ssmis_f16.TauCoeff.bin
#ln -s ${CRTM}/ssmis_f17.TauCoeff.bin ssmis_f17.TauCoeff.bin
#ln -s ${CRTM}/ssmis_f18.TauCoeff.bin ssmis_f18.TauCoeff.bin
#ln -s ${CRTM}/ssmis_f19.TauCoeff.bin ssmis_f19.TauCoeff.bin
#ln -s ${CRTM}/ssmis_f20.TauCoeff.bin ssmis_f20.TauCoeff.bin
#ln -s ${CRTM}/seviri_m10.TauCoeff.bin seviri_m10.TauCoeff.bin
#ln -s ${CRTM}/v.seviri_m10.TauCoeff.bin v.seviri_m10.TauCoeff.bin
#ln -s ${CRTM}/imgr_insat3d.TauCoeff.bin imgr_insat3d.TauCoeff.bin

#ln -s ${CRTM}/CloudCoeff.bin CloudCoeff.bin
#ln -s ${CRTM}/AerosolCoeff.bin AerosolCoeff.bin
#ln -s ${CRTM}/EmisCoeff.bin EmisCoeff.bin

#ln -s ${CRTM}/ssmi_f10.SpcCoeff.bin ssmi_f10.SpcCoeff.bin
#ln -s ${CRTM}/ssmi_f10.TauCoeff.bin ssmi_f10.TauCoeff.bin
#ln -s ${CRTM}/ssmi_f11.SpcCoeff.bin ssmi_f11.SpcCoeff.bin
#ln -s ${CRTM}/ssmi_f11.TauCoeff.bin ssmi_f11.TauCoeff.bin
#ln -s ${CRTM}/FASTEM6.MWwater.EmisCoeff.bin FASTEM6.MWwater.EmisCoeff.bin
#ln -s ${CRTM}/Nalli.IRwater.EmisCoeff.bin Nalli.IRwater.EmisCoeff.bin
#ln -s ${CRTM}/NPOESS.IRice.EmisCoeff.bin NPOESS.IRice.EmisCoeff.bin
#ln -s ${CRTM}/NPOESS.IRland.EmisCoeff.bin NPOESS.IRland.EmisCoeff.bin
#ln -s ${CRTM}/NPOESS.IRsnow.EmisCoeff.bin NPOESS.IRsnow.EmisCoeff.bin

# Run unipost
${MPIRUN} ${POST}< itag
error=$?
if [ ${error} -ne 0 ]; then
  ${ECHO} "${POST} crashed!  Exit status=${error}"
  exit ${error}
fi

# Append entire wrftwo to wrfprs
${CAT} ${workdir}/WRFPRS.GrbF${FCST_TIME} ${workdir}/WRFTWO.GrbF${FCST_TIME} > ${workdir}/WRFPRS.GrbF${FCST_TIME}.new
${MV} ${workdir}/WRFPRS.GrbF${FCST_TIME}.new ${workdir}/wrfprs_hrconus_${FCST_TIME}.grib2

# Append entire wrftwo to wrfnat
${CAT} WRFNAT.GrbF${FCST_TIME} WRFTWO.GrbF${FCST_TIME} > ${workdir}/WRFNAT.GrbF${FCST_TIME}.new
${MV} WRFNAT.GrbF${FCST_TIME}.new ${workdir}/wrfnat_hrconus_${FCST_TIME}.grib2

${MV} ${workdir}/WRFTWO.GrbF${FCST_TIME} ${workdir}/wrftwo_hrconus_${FCST_TIME}.grib2
#${MV} ${workdir}/WRFMSL.GrbF${FCST_TIME} ${workdir}/wrfmsl_hrconus_${FCST_TIME}.grib2

# Check to make sure all Post  output files were produced
if [ ! -s "${workdir}/wrfprs_hrconus_${FCST_TIME}.grib2" ]; then
  ${ECHO} "unipost crashed! wrfprs_hrconus_${FCST_TIME}.grib2 is missing"
  exit 1
fi
if [ ! -s "${workdir}/wrftwo_hrconus_${FCST_TIME}.grib2" ]; then
  ${ECHO} "unipost crashed! wrftwo_hrconus_${FCST_TIME}.grib2 is missing"
  exit 1
fi
if [ ! -s "${workdir}/wrfnat_hrconus_${FCST_TIME}.grib2" ]; then
  ${ECHO} "unipost crashed! wrfnat_hrconus_${FCST_TIME}.grib2 is missing"
  exit 1
fi
#if [ ! -s "${workdir}/wrfmsl_hrconus_${FCST_TIME}.grib2" ]; then
#  ${ECHO} "unipost crashed! wrfmsl_hrconus_${FCST_TIME}.grib2 is missing"
#  exit 1
#fi

# Move the output files to postprd
${MV} ${workdir}/wrfprs_hrconus_${FCST_TIME}.grib2 ${DATAHOME}
${MV} ${workdir}/wrftwo_hrconus_${FCST_TIME}.grib2 ${DATAHOME}
${MV} ${workdir}/wrfnat_hrconus_${FCST_TIME}.grib2 ${DATAHOME}
#${MV} ${workdir}/wrfmsl_hrconus_${FCST_TIME}.grib2 ${DATAHOME}
${RM} -rf ${workdir}

${ECHO} "unipost.ksh completed at `${DATE}`"

exit 0
