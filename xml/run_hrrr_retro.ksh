#!/bin/ksh --login

module load contrib rocoto

rocotorun -w HRRR_retro.xml -d HRRR_retro.db

exit 0
