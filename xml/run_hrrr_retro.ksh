#!/bin/ksh --login

module load intel/18.0.5.274
module load rocoto

rocotorun -w HRRR_retro.xml -d HRRR_retro.db

exit 0
