#!/bin/bash

module purge
module use ${ENV_DIR}
module load env_upp

cd $PATH1
pwd

for file in wrfout_d01_2019-*
do

date=$(echo $file | /bin/sed "s/wrfout_..._//;s/:..:..//");

ncks -A -d bottom_top,0,0 -v Times,LAKE_DEPTH,LAKEDEPTH2D,LAKEMASK,LANDMASK,TSK,T_GRND2D,SNL2D,SAVEDTKE12D,SNOWDP2D,H2OSNO2D,SNOW,SNOWH,SNOWFALLAC,ACSNOM,RAINNC,RAINNCV,SEAICE,ZNT,GLW,SWDOWN,T2,Q2,QVG,QCG,HFX,QFX,LH,GRDFLX $file $PATH1"/out_surf_"$date".nc"
ncks -A -d bottom_top,0,14 -v Times,DZ3D,Z_LAKE3D,DZ_LAKE3D,Z3D,ZI3D,H2OSOI_VOL3D,LAKE_ICEFRAC3D,T_SOISNO3D,T_LAKE3D,TSLB,SMOIS $file $PATH1"/out_3D_"$date".nc"

echo "out_surf_"$date".nc"
echo "out_3D_"$date".nc"

done
