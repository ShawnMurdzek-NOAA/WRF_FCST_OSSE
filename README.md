# WRF_FCST_OSSE

A WRF-Based forecast system for OSSEs. Loosely based on HRRRv4.

## Contents

- `bin`: Scripts used to run the various forecast system components (e.g., preprocesser, DA, forecast model, postprocessor).
- `static`: Subset of the static files needed to run the WRF_FCST_OSSE. Mainly just includes namelist files.
- `xml`: Rocoto workflow for the forecast system

## Running WRF_FCST_OSSE

All development is currently being done on Jet. No other NOAA RDHPCS systems have been tested.

## Notes

In order to run WRF_FCST_OSSE, the following directories are also needed:

- `exec`: Executables for the WRF_FCST_OSSE components.
- `log`: An empty directory for WRF_FCST_OSSE logs.
- `loghistory`: An empty directory for WRF_FCST_OSSE logs.
- `run`: An empty directory for WRF_FCST_OSSE output.
- `static`: The remaining static files that are too large to keep on GitHub.
