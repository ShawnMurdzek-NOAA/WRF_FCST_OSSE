;
if (fctm .eq. 2 .or. \
    fctm .eq. 8 .or. \
    fctm .eq. 14 .or. \
    fctm .eq. 20 .or. \
    fctm .eq. 26 .or. \
    fctm .eq. 32 .or. \
    fctm .eq. 38 .or. \
    fctm .eq. 44 .or. \
    fctm .eq. 50 .or. \
    fctm .eq. 56 .or. \
    fctm .eq. 62 .or. \
    fctm .eq. 68 .or. \
    fctm .eq. 74 .or. \
    fctm .eq. 80) then
;
fctm = fctm + 256
;
end if
;
year = stringtointeger(getSubString(intm,6,9))
mon  = stringtointeger(getSubString(intm,0,1))
day  = stringtointeger(getSubString(intm,3,4))
hour = stringtointeger(getSubString(intm,12,13))
time = (/0.0/)
time@units = "seconds since 1970-01-01 00:00:0.0"
date = ut_inv_calendar(year,mon,day,hour,0,0,time@units, 0)
fcst = (/date + stringtointeger(fctm)*3600/)
fcst@units = "seconds since 1970-01-01 00:00:0.0"
utc_date = ut_calendar(fcst, 0)
year   = floattointeger(utc_date(:,0))    ; Convert to integer for
month  = floattointeger(utc_date(:,1))    ; use in the sprinti function.
day    = floattointeger(utc_date(:,2))
hour   = floattointeger(utc_date(:,3))
minute = floattointeger(utc_date(:,4))
second = utc_date(:,5)
date_str = "Valid " + sprinti("%0.2i/", month) + sprinti("%0.2i/",day) + \
           sprinti("%0.4i", year) + " " + sprinti("%0.2i:00 ", hour)  + \
           "UTC"

