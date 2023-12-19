#!/bin/ksh --login
##########################################################################
#
#Script Name: ungrib.ksh
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
# Purpose: This is a complete  rewrite of the grib_prep.pl  script that is 
#          distributed with  the WRF Standard Initialization.  This script
#          may be run on the command line, or it may be submitted directly
#          to a  batch queueing system.  A few environment variables  must
#          be set before it is run:
#
#           INSTALL_ROOT = Location of compiled wrfsi binaries and scripts.
#           DATAROOT = Top level directory of grib_prep configuration data.
#           DATAHOME = Top level directory of grib_prep output
#            FCST_LENGTH = The length of the forecast in hours.  If not set,
#                          the default value of 48 is used.
#          FCST_INTERVAL = The interval, in hours, between each forecast.
#                          If not set, the default value of 3 is used.
#                 SOURCE = The data source to process.
#             START_TIME = The cycle time to use for the initial time. 
#                          If not set, the system clock is used.
# 
#          It is also HIGHLY recommended that you set the FORMAT environment
#          variable to specify the format of the ungrib filenames you are
#          processing.  The FORMAT environment variable works similarly to 
#          the format associated with UNIX date command:
#
#            %Y - Represents a four digit year, YYYY
#            %y - Represents a two digit year, YY
#            %j - Represents a three digit julian day, JJJ
#            %m - Represents a two digit month, 01 thru 12
#            %d - Represents a two digit day, 01 thru 31
#            %H - Represents a two digit hour, 00 thru 23
#            %F - Represents a four digit forecast hour, FFFF
#            %f - Represents a two digit forecast hour, FF
#          
#          Examples:
#
#             FORMAT="%Y%m%d%H%F.grib" would match files named:
#
#                       YYYYMMDDHHFFFF.grib
#
#             FORMAT="%Y%j%H%F.grib" would match files named:
#
#                       YYYYJJJHHFFFF.grib
#
#             FORMAT="eta.t%Hz.pgrb.%f would match files named:
#
#                       eta.tHHz.pgrb.ff
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
module load intel/18.0.5.274
module load impi/2018.4.274
module load szip/2.1 hdf5/1.8.9 netcdf/4.2.1.1
module load pnetcdf/1.6.1
module load nco/4.1.0
module load cnvgrib/1.4.0
module load imagemagick/7.0.8-34
module load ncl/6.5.0

# Make sure we are using GMT time zone for time computations
export TZ="GMT"
ulimit -s 512000

# Make sure we give other group members write access to the files we create
umask 2

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
CUT=`which cut`
AWK="/bin/gawk --posix"
SED=/bin/sed
DATE=/bin/date

ulimit -s 512000

# Set up some constants
export WPSNAMELIST=${STATIC_DIR}/namelist.wps
export UNGRIB=${WPS_ROOT}/ungrib.exe

# Print run parameters
${ECHO}
${ECHO} "ungrib.ksh started at `${DATE}`"
${ECHO}
${ECHO} "WPS_ROOT       = ${WPS_ROOT}"
${ECHO} "DATAROOT   = ${DATAROOT}"
${ECHO} "DATAHOME   = ${DATAHOME}"
${ECHO} "SOURCE         = ${SOURCE}"
${ECHO} "SOURCE_PATH    = ${SOURCE_PATH}"
${ECHO} "START_TIME     = ${START_TIME}"
${ECHO} "FCST_LENGTH    = ${FCST_LENGTH}"
${ECHO} "FCST_INTERVAL  = ${FCST_INTERVAL}"
${ECHO} "DELAY          = ${DELAY}"
${ECHO}

# Check to make sure that WPS_ROOT exists
if [ ! -d ${WPS_ROOT} ]; then
  ${ECHO} "ERROR: ${WPS_ROOT} does not exist"
  exit 1
fi

# Check to make sure the ungrib executable exists
if [ ! -x ${UNGRIB} ]; then
  ${ECHO} "ERROR: ${UNGRIB} does not exist, or is not executable"
  exit 1
fi

# Check to make sure that the DATAROOT exists
if [ ! -d ${DATAROOT} ]; then
  ${ECHO} "ERROR: ${DATAROOT} does not exist"
  exit 1
fi

# Check to make sure the source has been specified
if [ ! "${SOURCE}" ]; then
  ${ECHO} "ERROR: The data source (e.g. ETA, AVN, RUC, etc.) has not been specified"
  exit 1
fi

# Check to make sure the source path has been specified
if [ ! "${SOURCE_PATH}" ]; then
  ${ECHO} "ERROR: The data source path has not been specified"
  exit 1
fi

# Check to make sure the namelist exists
if [ ! -r ${WPSNAMELIST} ]; then
  ${ECHO} "ERROR: ${WPSNAMELIST} does not exist, or is not readable"
  exit 1
fi

# Check to make sure START_TIME was specified
if [ ! "${START_TIME}" ]; then
  ${ECHO} "ERROR: \$START_TIME is not set!"
  exit 1
fi

# Check to make sure FCST_LENGTH was specified
if [ ! "${FCST_LENGTH}" ]; then
  ${ECHO} "ERROR: \$FCST_LENGTH is not set!"
  exit 1
fi

# Check to make sure DATA_INTERVAL was specified
if [ ! "${DATA_INTERVAL}" ]; then
  ${ECHO} "ERROR: \$DATA_INTERVAL is not set!"
  exit 1
fi

# Check to make sure FCST_INTERVAL was specified
if [ ! "${FCST_INTERVAL}" ]; then
  ${ECHO} "ERROR: \$FCST_INTERVAL is not set!"
  exit 1
fi

# Check to make sure the Vtable for the source exists
if [ ! -r ${STATIC_DIR}/Vtable.${SOURCE} ]; then
  ${ECHO} "ERROR: ${STATIC_DIR}/Vtable.${SOURCE} does not exist or is not readable"
  exit 1
fi

# Make sure the START_TIME is in the correct format
if [ `${ECHO} "${START_TIME}" | ${AWK} '/^[[:digit:]]{10}$/'` ]; then
  START_TIME=`${ECHO} "${START_TIME}" | ${SED} 's/\([[:digit:]]\{2\}\)$/ \1/'`
elif [ ! "`${ECHO} "${START_TIME}" | ${AWK} '/^[[:digit:]]{8}[[:blank:]]{1}[[:digit:]]{2}$/'`" ]; then
  ${ECHO} "ERROR: start time, '${START_TIME}', is not in 'yyyymmddhh' or 'yyyymmdd hh' format"
  exit 1
fi

# Calculate start and end time date strings
START_TIME=`${DATE} -d "${START_TIME}"`
END_TIME=`${DATE} -d "${START_TIME}  ${FCST_LENGTH} hours"`
start_yyyymmdd_hhmmss=`${DATE} +%Y-%m-%d_%H:%M:%S -d "${START_TIME}"`
end_yyyymmdd_hhmmss=`${DATE} +%Y-%m-%d_%H:%M:%S -d "${END_TIME}"`
cycle_hour=`${DATE} +%H -d "${START_TIME}"`

#echo $start_yyyymmdd_hhmmss
#echo $end_yyyymmdd_hhmmss

# Get the forecast interval in seconds
(( fcst_interval_sec = ${FCST_INTERVAL} * 3600 ))

# Set up the work directory and cd into it
workdir=${DATAHOME}/${SOURCE}.`${DATE} +%s.%N`
${RM} -rf ${workdir}
${MKDIR} -p ${workdir}
cd ${workdir}

# Link the Vtable into the work directory
${RM} -f Vtable
${LN} -s ${STATIC_DIR}/Vtable.${SOURCE} Vtable

# Copy the namelist into the work directory
${CP} ${WPSNAMELIST} .
WPSNAMELIST=${workdir}/`basename ${WPSNAMELIST}`

# Create a poor man's namelist hash
#
# Strip off comments, section names, slashes, and remove white space.
# Then loop over each line to create an array of names, an array of
# values, and variables that contain the index of the names in the
# array of names.  Each variable that contains an index of a namelist
# name is named $_NAME_ where 'NAME' is one of the names in the namelist
# The $_NAME_ vars are always capitalized even if the names in the namelist
# are not.
i=-1
for name in `${SED} 's/[[:blank:]]//g' ${WPSNAMELIST} | ${AWK} '/^[^#&\/]/' | ${SED} 's/[[:cntrl:]]//g'`
do
  # If there's an = in the line
  if [ `${ECHO} ${name} | ${AWK} /=/` ]; then
    (( i=i+1 ))
    left=`${ECHO} ${name} | ${CUT} -d"=" -f 1 | ${AWK} '{print toupper($0)}'`
    right=`${ECHO} ${name} | ${CUT} -d"=" -f 2`
#    var[${i}]=${left}
    val[${i}]=${right}
    (( _${left}_=${i} ))
  else
    val[${i}]=${val[${i}]}${name}
  fi
done

# Create patterns for updating the namelist
equal=[[:blank:]]*=[[:blank:]]*
start=[Ss][Tt][Aa][Rr][Tt]
end=[Ee][Nn][Dd]
date=[Dd][Aa][Tt][Ee]
interval=[Ii][Nn][Tt][Ee][Rr][Vv][Aa][Ll]
seconds=[Ss][Ee][Cc][Oo][Nn][Dd][Ss]
prefix=[Pp][Rr][Ee][Ff][Ii][Xx]
yyyymmdd_hhmmss='[[:digit:]]\{4\}-[[:digit:]]\{2\}-[[:digit:]]\{2\}_[[:digit:]]\{2\}:[[:digit:]]\{2\}:[[:digit:]]\{2\}'

# Update the start and end date in namelist
${CAT} ${WPSNAMELIST} | ${SED} "s/\(${start}_${date}\)${equal}'${yyyymmdd_hhmmss}'/\1 = '${start_yyyymmdd_hhmmss}'/" \
                      | ${SED} "s/\(${end}_${date}\)${equal}'${yyyymmdd_hhmmss}'/\1 = '${end_yyyymmdd_hhmmss}'/"     \
                      > ${WPSNAMELIST}.new
${MV} ${WPSNAMELIST}.new ${WPSNAMELIST}

# Update interval in namelist
${CAT} ${WPSNAMELIST} | ${SED} "s/\(${interval}_${seconds}\)${equal}[[:digit:]]\{1,\}/\1 = ${fcst_interval_sec}/" \
                      > ${WPSNAMELIST}.new 
${MV} ${WPSNAMELIST}.new ${WPSNAMELIST}

# Update the prefix in the namelist
${CAT} ${WPSNAMELIST} | ${SED} "s/\(${prefix}\)${equal}'[[:alnum:]]\{1,\}'/\1 = '${SOURCE}'/" \
                      > ${WPSNAMELIST}.new 
${MV} ${WPSNAMELIST}.new ${WPSNAMELIST}

# Get start time components to use for matching with grib files
if [ ! "${DELAY}" ]; then
  new_delay=0
else
  new_delay=$(( cycle_hour % 6 + DELAY ))
fi
echo "new_delay = ${new_delay}"
start_year=`${DATE} +%Y -d "${START_TIME} ${new_delay} hours ago"`
start_yr=`${DATE} +%y -d "${START_TIME} ${new_delay} hours ago"`
start_month=`${DATE} +%m -d "${START_TIME} ${new_delay} hours ago"`
start_day=`${DATE} +%d -d "${START_TIME} ${new_delay} hours ago"`
start_jday=`${DATE} +%j -d "${START_TIME} ${new_delay} hours ago"`
start_hour=`${DATE} +%H -d "${START_TIME} ${new_delay} hours ago"`

# Get a list of files in the SRCPATH directory
grib_files=`${LS} -1 ${SOURCE_PATH} | sort`
ngribfiles=0

# Select files to create links to based on a file name format.
# The format is a string optionally containing the following:
#
#  %y - Two digit year (e.g. 03)
#  %Y - Four digit year (e.g. 2003)
#  %m - Two digit month (i.e. 01, 02,...,12)
#  %d - Two digit day of month (i.e. 01,02,...31)
#  %j - Three digit julian day (i.e. 01,02,...366)
#  %H - Two digit hour (i.e. 00,01,...23)
#  %f - Two digit forecast hour (e.g. 00, 01, 12, 24, 48, etc.)
#  %F - Four digit forecast hour (e.g. 0000, 0001, 0012, 0048, 0096, 0144, etc.)
#
if [ ${FORMAT} ]; then
  new_format=`${ECHO} ${FORMAT} | ${SED} "s/%Y/${start_year}/g"  \
                                | ${SED} "s/%y/${start_yr}/g"    \
                                | ${SED} "s/%m/${start_month}/g" \
                                | ${SED} "s/%d/${start_day}/g"   \
                                | ${SED} "s/%j/${start_jday}/g"  \
                                | ${SED} "s/%H/${start_hour}/g"`
  ${ECHO} "Using format: '${new_format}'"

  set -A flags H j d m y Y F f
  for file in ${grib_files}; do

    # Check to see if the file conforms to the specified format
    filter=`${ECHO} ${new_format} | ${SED} 's/%Y/[[:digit:]][[:digit:]][[:digit:]][[:digit:]]/' \
                           | ${SED} 's/%y/[[:digit:]][[:digit:]]/'                       \
                           | ${SED} 's/%j/[[:digit:]][[:digit:]][[:digit:]]/'            \
                           | ${SED} 's/%m/[[:digit:]][[:digit:]]/'                       \
                           | ${SED} 's/%d/[[:digit:]][[:digit:]]/'                       \
                           | ${SED} 's/%H/[[:digit:]][[:digit:]]/'                       \
                           | ${SED} 's/%F/[[:digit:]][[:digit:]][[:digit:]][[:digit:]]/' \
                           | ${SED} 's/%f/[[:digit:]][[:digit:]]/'`

    if [ ! "`${ECHO} ${file} | ${AWK} "/^${filter}$/"`" ]; then
      continue
    fi

    # Clear any previous values for the flags
    for flag in ${flags[*]}; do
      eval unset _${flag}_
    done

    # The file conforms to the format, extract the values for each flag
    for flag in ${flags[*]}; do

      # If the flag is used, get its value
      if [ "`${ECHO} ${new_format} | ${AWK} "/%${flag}/"`" ]; then
        flagstr="\\\(%${flag}\\\)"
        format=`${ECHO} ${new_format} | ${SED} "s/%${flag}/${flagstr}/"`
        filter=`${ECHO} ${format} | ${SED} 's/%Y/[[:digit:]][[:digit:]][[:digit:]][[:digit:]]/' \
                               | ${SED} 's/%y/[[:digit:]][[:digit:]]/'                       \
                               | ${SED} 's/%j/[[:digit:]][[:digit:]][[:digit:]]/'            \
                               | ${SED} 's/%m/[[:digit:]][[:digit:]]/'                       \
                               | ${SED} 's/%d/[[:digit:]][[:digit:]]/'                       \
                               | ${SED} 's/%H/[[:digit:]][[:digit:]]/'                       \
                               | ${SED} 's/%F/[[:digit:]][[:digit:]][[:digit:]][[:digit:]]/' \
                               | ${SED} 's/%f/[[:digit:]][[:digit:]]/'`
        val=`${ECHO} ${file}| ${SED} "s/${filter}/\1/"`
        eval _${flag}_="${val}"

        # Improve performance by early rejection of the files that do not match the times we want
        if [ -n "${_H_}" -a "${_H_}" -ne "${start_hour}" ]; then
          break
        elif [ -n "${_j_}" -a "${_j_}" -ne "${start_jday}" ]; then
          break
        elif [ -n "${_d_}" -a "${_d_}" -ne "${start_day}" ]; then
          break
        fi
      fi

    done

    # Check the value of each flag against the start time, fcst_length, and fcst_interval
    if [ -z "${_H_}" -o "${_H_}" -eq "${start_hour}" ]; then
      if [ -z "${_j_}" -o "${_j_}" -eq "${start_jday}" ]; then
        if [ -z "${_d_}" -o "${_d_}" -eq "${start_day}" ]; then
          if [ -z "${_m_}" -o "${_m_}" -eq "${start_month}" ]; then
            if [ -z "${_y_}" -o "${_y_}" -eq "${start_yr}" ]; then
              if [ -z "${_Y_}" -o "${_Y_}" -eq "${start_year}" ]; then
                if [ -z "${_f_}" -a -z "${_F_}" ]; then
                  gribfiles[${ngribfiles}]=${file}
                  (( ngribfiles=ngribfiles + 1 ))
                else
                  if [ -n "${_F_}" ]; then
                    fhour=${_F_}
                  elif [ -n "${_f_}" ]; then
                    fhour=${_f_}
                  fi
                  if (( (fhour >= new_delay) && (fhour <= FCST_LENGTH+new_delay) && ((fhour-new_delay) % FCST_INTERVAL==0) )) then
                    gribfiles[${ngribfiles}]=${file}
                    (( ngribfiles=ngribfiles + 1 ))
                  fi
                fi
              fi
            fi
          fi
        fi
      fi
    fi

  done

fi

# If a filter is provided, try matching grib files using the filter
if [ ${ngribfiles} -eq 0 ]; then
  if [ ${FILTER} ]; then
    ${ECHO} "TRYING FILTER = ${FILTER}"
    for file in ${grib_files}; do
      if [ `${ECHO} ${file} | ${AWK} "/${FILTER}/"` ]; then
        gribfiles[${ngribfiles}]=${file}
        (( ngribfiles=ngribfiles + 1 ))
      fi
    done
  fi
fi

# Try linking to all (non dot) files in the srcpath
if [ ${ngribfiles} -eq 0 ]; then
  filter="^[^.].*"
  ${ECHO} "Filters found no grib files; linking to all files"
  for file in ${grib_files}; do
    if [ "`${ECHO} ${file} | ${AWK} "/${filter}/"`" ]; then
      gribfiles[${ngribfiles}]=${file}
      (( ngribfiles=ngribfiles + 1 ))      
    fi
  done
fi

# Check to make sure we linked to some grib files
if [ ${ngribfiles} -eq 0 ]; then
  ${ECHO} "${SOURCE_PATH} appears to be empty"
  ${ECHO} "ERROR: No grib files could be linked to"
  exit 1
fi

${ECHO}

# Create a set of id's for use in naming the links
set -A alphabet A B C D E F G H I J K L M N O P Q R S T U V W X Y Z
i=0
j=0
k=0
n=0
while [ ${i} -lt ${#alphabet[*]} -a ${n} -lt ${#gribfiles[*]} ]; do
  while [ ${j} -lt ${#alphabet[*]} -a ${n} -lt ${#gribfiles[*]} ]; do
    while [ ${k} -lt ${#alphabet[*]} -a ${n} -lt ${#gribfiles[*]} ]; do
      id="${alphabet[${i}]}${alphabet[${j}]}${alphabet[${k}]}"
      ${LN} -s ${SOURCE_PATH}/${gribfiles[${n}]} ${workdir}/GRIBFILE.${id}
      (( k=k+1 ))
      (( n=n+1 ))
    done
    k=0
    (( j=j+1 ))
  done
  j=0
  (( i=i+1 ))
done

# Run ungrib
${UNGRIB}
error=$?
if [ ${error} -ne 0 ]; then
  ${ECHO} "ERROR: ${UNGRIB} exited with status: ${error}"
  exit ${error}
fi

# Check to see if we've got all the files we're expecting
fcst=0
while [ ${fcst} -le ${FCST_LENGTH} ]; do
  filename=${workdir}/${SOURCE}:`${DATE} +%Y-%m-%d_%H -d "${START_TIME}  ${fcst} hours"`
  if [ ! -s ${filename} ]; then
    echo "ERROR: ${filename} is missing"
    exit 1
  fi
  (( fcst=fcst+FCST_INTERVAL ))
done

# Move the output files to the extprd directory
${MKDIR} -p ${DATAHOME}
for file in `${LS} -1 ${workdir} | ${GREP} ^${SOURCE}:`; do
  ${MV} ${file} ${DATAHOME}
done


${ECHO} "ungrib.ksh terminated at `${DATE}`"

exit 0
