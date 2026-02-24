# WRF_FCST_OSSE

A WRF-Based forecast system for OSSEs. Loosely based on HRRRv4.

## Contents

- `bin`: Scripts used to run the various forecast system components (e.g., preprocesser, DA, forecast model, postprocessor).
- `env`: Lua files specifying the runtime environment on various HPC systems.
- `exec`: Directory holding executables. Currently empty except for a README describing the necessary executables.
- `static`: Subset of the static files needed to run the WRF_FCST_OSSE. Mainly just includes namelist files. Additional static files need to be downloaded.
- `xml`: Rocoto workflow for the forecast system

## Running WRF_FCST_OSSE

All development is currently being done on Jet. No other NOAA RDHPCS systems have been tested.

Steps to run WRF_FCST_OSSE:

1. Clone WRF_FCST_OSSE: `git clone --recursive https://github.com/ShawnMurdzek-NOAA/WRF_FCST_OSSE.git`
2. Link necessary executables in `exec`. See `exec/README.md` for a list of necessary executables.
3. Update environment lua files in `env` to match the environments used to compile the executables in `exec`.
4. Download the additional `static` files. See `static/README.md` for additional information.
5. Link `static/GSI_HRRR` or `static/GSI_RRFS` to `static/GSI`.
6. Create empty `run`, `log`, and `loghistory` directories (on the same level as `bin`, `env`, etc.).
7. Within `run`, create a subdirectory called `surface` and add surface data from a previous HRRR run to initialize the soil state. File naming convention is `wrfout_sfc_HH`, where `HH` is the hour.
8. Update the upper portion of `xml/HRRR_retro.xml.<machine>` to have the correct machine, directories, etc.
9. Link `xml/HRRR_retro.xml.<machine>` to `xml/HRRR_retro.xml`.
10. Run the workflow using `xml/run_hrrr_retro.ksh`.
11. NOTE: To start the initial spinup cycle, the wrf_arw_short and wrf_arw_long tasks for all initialization hours for that spinup period (i.e., 03-08 or 15-20 UTC) must be manually completed, because these tasks are dependencies for the gsi_hyb_spinup task.

Steps (2) - (7) above can be completed using the `setup_exp.sh` script on supported HPC platforms. Simply change the beginning of the script to reflect your HPC system and desired season.

## Input Data Formatting  
  
Input data for WRF_FCST_OSSE should follow these naming conventions (first part of each path is defined in `xml/HRRR_retro.xml`):  
  
- Conventional observations (prepBUFR format): `OBS_DIR/YYYYMMDDHH.rap.tHHz.prepbufr.tm00`
- Sea surface temperature analyses (GRIB2 format): `SST_DIR/YYJJJHH000000`
- GFS forecasts for ICs and LBCs (GRIB2 format): `GFS_DIR/YYJJJHH0000FF`
- GDAS forecasts for flow-dependent background error covariances (HDF5 format): `ENKFFCST_DIR/YYJJJJHH00.gdas.tHHz.atmf0FF.memMMM.nc`
- Commercial aircraft observation reject list (ASCII format): `AIRCRAFT_REJECT/YYYYMMDD_rejects.txt`
- Mesonet observation uselist (ASCII format): `SFCOBS_USELIST/YYYY-MM-DD_meso_uselist.txt`
- Snow and ice analyses (GRIB2 format): `NCEPSNOW_DIR/YYJJJHH00000000`

where... 
  
- `YYYY`: 4-digit year (valid time for obs, init time for models) 
- `MM`: 2-digit month (valid time for obs, init time for models) 
- `DD`: 2-digit day (valid time for obs, init time for models) 
- `JJJ`: 3-digit Julian day (valid time for obs, init time for models) 
- `HH`: 2-digit hour (valid time for obs, init time for models) 
- `FF`: 2-digit forecast hour  
- `MMM`: 3-digit ensemble member number  

## Notes

In order to run WRF_FCST_OSSE, the following directories are also needed:

- `log`: An empty directory for WRF_FCST_OSSE logs.
- `loghistory`: An empty directory for WRF_FCST_OSSE logs.
- `run`: A mostly empty directory for WRF_FCST_OSSE output. Only output needed to start a forecast run is surface data (see "Steps to run WRF_FCST_OSSE" above).

### Selecting a GSI Version

Two sets of GSI static files are provided: `static/GSI_HRRR` and `static/GSI_RRFS`. These include some of the input static files for running GSI using the HRRRv4-era version of GSI and the RRFS(FV3)-era of GSI. Choose the appropriate directory, then link it to the `static/GSI` directory (e.g., `ln -sf GSI_HRRR GSI`).
