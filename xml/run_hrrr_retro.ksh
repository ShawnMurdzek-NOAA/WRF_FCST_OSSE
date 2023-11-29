#!/bin/ksh --login

module load intel/18.0.5.274
module load rocoto

rocotorun -w /lfs4/BMC/wrfruc/murdzek/HRRR_OSSE/syn_data/winter/xml/HRRR_retro.xml -d /lfs4/BMC/wrfruc/murdzek/HRRR_OSSE/syn_data/winter/xml/HRRR_retro.db

exit 0
