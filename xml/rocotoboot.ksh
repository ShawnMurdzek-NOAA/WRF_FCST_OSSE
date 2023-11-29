#!/bin/ksh --login

module load intel
module load rocoto

rocotoboot -w /lfs4/BMC/wrfruc/ejames/hrrrretro/HRRRv4_sep2019_control2/xml/HRRR_retro.xml -d /lfs4/BMC/wrfruc/ejames/hrrrretro/HRRRv4_sep2019_control2/xml/HRRR_retro.db -c 201909011200 -t wrf_arw_long

exit 0
