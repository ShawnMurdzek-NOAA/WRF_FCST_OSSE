;
;2017-08-30_12:00:00
;0123456789012345678
cyear = getSubString(sd,0,3)
cmon  = getSubString(sd,5,6)
cday  = getSubString(sd,8,9)
chour = getSubString(sd,11,12)
intm = cyear+"-"+cmon+"-"+cday+" "+chour+" UTC"
year = stringtointeger(getSubString(sd,0,3))
mon  = stringtointeger(getSubString(sd,5,6))
day  = stringtointeger(getSubString(sd,8,9))
hour = stringtointeger(getSubString(sd,11,12))
time = (/0.0/)
time@units = "seconds since 1970-01-01 00:00:0.0"
date = ut_inv_calendar(year,mon,day,hour,0,0,time@units, 0)
;
fyear = stringtointeger(getSubString(fcst_date,0,3))
fmon  = stringtointeger(getSubString(fcst_date,5,6))
fday  = stringtointeger(getSubString(fcst_date,8,9))
fhour = stringtointeger(getSubString(fcst_date,11,12))
ftime = (/0.0/)
ftime@units = "seconds since 1970-01-01 00:00:0.0"
fdate = ut_inv_calendar(fyear,fmon,fday,fhour,0,0,ftime@units, 0)
fctm = (/fdate - date/) / 3600
fcst = (/fdate/)
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

