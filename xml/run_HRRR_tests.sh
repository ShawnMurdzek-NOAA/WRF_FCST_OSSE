
module load contrib rocoto

# Boot conventional_gsi so that each cycle is active

# Ungrib
#rocotorewind -w HRRR_retro.xml -d HRRR_retro.db -c 202204291200 -t ungrib_SST
#rocotorewind -w HRRR_retro.xml -d HRRR_retro.db -c 202204291200 -t ungrib_GFS_bc_long
#rocotoboot -w HRRR_retro.xml -d HRRR_retro.db -c 202204291200 -t conventional_gsi
rocotoboot -w HRRR_retro.xml -d HRRR_retro.db -c 202204291200 -t ungrib_SST
rocotoboot -w HRRR_retro.xml -d HRRR_retro.db -c 202204291200 -t ungrib_GFS_bc_long

# Metgrid
#rocotorewind -w HRRR_retro.xml -d HRRR_retro.db -c 202204291300 -t metgrid_GFS_bc_short
#rocotoboot -w HRRR_retro.xml -d HRRR_retro.db -c 202204291300 -t conventional_gsi
#rocotocomplete -w HRRR_retro.xml -d HRRR_retro.db -c 202204291300 -t ungrib_SST
#rocotocomplete -w HRRR_retro.xml -d HRRR_retro.db -c 202204291300 -t ungrib_GFS_bc_short
rocotoboot -w HRRR_retro.xml -d HRRR_retro.db -c 202204291300 -t metgrid_GFS_bc_short

# Real
#rocotorewind -w HRRR_retro.xml -d HRRR_retro.db -c 202204291400 -t real_arw_bc_short
#rocotoboot -w HRRR_retro.xml -d HRRR_retro.db -c 202204291400 -t conventional_gsi
rocotoboot -w HRRR_retro.xml -d HRRR_retro.db -c 202204291400 -t real_arw_bc_short

# WRF
#rocotorewind -w HRRR_retro.xml -d HRRR_retro.db -c 202204291500 -t wrf_arw_spinup
#rocotoboot -w HRRR_retro.xml -d HRRR_retro.db -c 202204291500 -t conventional_gsi
rocotoboot -w HRRR_retro.xml -d HRRR_retro.db -c 202204291500 -t wrf_arw_spinup

# GSI
#rocotorewind -w HRRR_retro.xml -d HRRR_retro.db -c 202204291700 -t gsi_hyb_spinup
#rocotoboot -w HRRR_retro.xml -d HRRR_retro.db -c 202204291700 -t conventional_gsi
rocotoboot -w HRRR_retro.xml -d HRRR_retro.db -c 202204291700 -t gsi_hyb_spinup
