
# Copy the executables, static files, and initial surface state required for a 
# WRF_FCST_OSSE experiment

# Inputs

machine='hercules'
season='winter'

#===================================================================================================
# You shouldn't need to change anything below here

# Machine-specific options
echo "Machine = ${machine}"
if [[ ${machine} == 'hercules' ]]; then
  gsi_exec=('/work2/noaa/wrfruc/murdzek/src/HRRR/hercules/attempt2/hrrr_full_cycle_surface.fd/hrrr_full_cycle_surface.exe'
	    '/work2/noaa/wrfruc/murdzek/src/HRRR/hercules/attempt2/rrfs-workflow/exec/gsi.x'
	    '/work2/noaa/wrfruc/murdzek/src/HRRR/hercules/attempt2/hrrr_process_imssnow.fd/process_NESDIS_imssnow.exe'
	    '/work2/noaa/wrfruc/murdzek/src/HRRR/hercules/attempt2/hrrr_process_sst.fd/process_SST.exe'
	    '/work2/noaa/wrfruc/murdzek/src/HRRR/hercules/attempt2/GSI-utils/bin/bin/read_diag_conv.x')
  pygraf_dir='/work/noaa/wrfruc/murdzek/HRRR_OSSE/exec/PYGRAF/pygraf'
  upp_exec='/work2/noaa/wrfruc/murdzek/src/HRRR/hercules/attempt2/UPP/exec/upp.x'
  wps_exec=('/work2/noaa/wrfruc/murdzek/src/HRRR/hercules/attempt2/hrrr_wps.fd/WPSV3.9.1/geogrid.exe'
	    '/work2/noaa/wrfruc/murdzek/src/HRRR/hercules/attempt2/hrrr_wps.fd/WPSV3.9.1/metgrid.exe'
	    '/work2/noaa/wrfruc/murdzek/src/HRRR/hercules/attempt2/hrrr_wps.fd/WPSV3.9.1/ungrib.exe'
	    '/work/noaa/epic/role-epic/spack-stack/hercules/spack-stack-1.6.0/envs/unified-env/install/intel/2021.9.0/wgrib2-2.0.8-53fnkln/bin/wgrib2')
  wrf_exec=('/work2/noaa/wrfruc/murdzek/src/HRRR/hercules/attempt2/hrrr_update_bc.fd/hrrr_update_bc.exe'
	    '/work2/noaa/wrfruc/murdzek/src/HRRR/hercules/attempt2/WRFV3.9_no_pnetcdf/main/real.exe'
	    '/work2/noaa/wrfruc/murdzek/src/HRRR/hercules/attempt2/WRFV3.9_no_pnetcdf/main/wrf.exe')
  wps_static_dir='/work/noaa/wrfruc/murdzek/HRRR_OSSE/static/WPS'
  wrf_static_dir='/work/noaa/wrfruc/murdzek/HRRR_OSSE/static/WRF'
  geo_em_name='geo_em.d01_modis15s_lake_Saltlake_modisalb_newtopo_newsoil_lakemod.new_GWD_fields.nc'
  sfc_state_dir='/work/noaa/wrfruc/murdzek/HRRR_OSSE/init_sfc_state'
else
  echo "Machine option ${machine} is not recognized"
  exit 0
fi

# Copy executables
echo "Copying executables"

mkdir -p ./exec/GSI
cd ./exec/GSI
for e in ${gsi_exec[@]}; do
  cp ${e} .
  IFS='/' read -ra name <<< ${e}
  ln -sf ${e} ${name[-1]}.src
done
cd ../../

mkdir -p ./exec/PYGRAF
cp -r ${pygraf_dir} ./exec/PYGRAF/

mkdir -p ./exec/UPP
cd ./exec/UPP
cp ${upp_exec} .
IFS='/' read -ra name <<< ${upp_exec}
ln -sf ${upp_exec} ${name[-1]}.src
cd ../../

mkdir -p ./exec/WPS
cd ./exec/WPS
for e in ${wps_exec[@]}; do
  cp ${e} .
  IFS='/' read -ra name <<< ${e}
  ln -sf ${e} ${name[-1]}.src
done
cd ../../

mkdir -p ./exec/WRF
cd ./exec/WRF
for e in ${wrf_exec[@]}; do
  cp ${e} .
  IFS='/' read -ra name <<< ${e}
  ln -sf ${e} ${name[-1]}.src
done
cd ../../

# Additional linking for executables
case ${machine} in

  'hercules')
    cd ./exec/GSI
    ln -sf gsi.x HRRR_gsi_hyb
    ln -sf hrrr_full_cycle_surface.exe full_cycle_surface.exe
    ln -sf read_diag_conv.x read_diag_conv.exe
    cd ../..

    cd ./exec/UPP
    ln -sf upp.x ncep_post.exe
    cd ../../
  ;;

esac

# Copy static files
echo "Copying static files"

cd ./static/WPS
cp ${wps_static_dir}/${geo_em_name} .
if [[ ${geo_em_name} != 'geo_em.d01.nc' ]]; then
  ln -sf ${geo_em_name} geo_em.d01.nc
fi
cp ${wps_static_dir}/GWD_mdt_10newfields.HRRR.nc .

cd ../WRF
cp -r ${wrf_static_dir}/run .
cd ../../

# Make required directories
echo "Making directories"
mkdir -p log
mkdir -p loghistory
mkdir -p run/surface

# Copy initial surface state
echo "Copying initial surface state for ${season}"
if [[ ${season} == 'winter' ]]; then
  cp ${sfc_state_dir}/wrfout_sfc_2022020104.nc ./run/surface/wrfout_sfc_04
  cp ./run/surface/wrfout_sfc_04 ./run/surface/wrfout_sfc_04_ORIGINAL
elif [[ ${season} == 'spring' ]]; then
  cp ${sfc_state_dir}/wrfout_sfc_2022042916.nc ./run/surface/wrfout_sfc_16
  cp ./run/surface/wrfout_sfc_16 ./run/surface/wrfout_sfc_16_ORIGINAL
else
  echo "Season ${season} is not recognized"
  exit 0
fi
