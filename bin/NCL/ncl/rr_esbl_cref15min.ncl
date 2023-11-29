load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCL_HOME/obj/plot_titles_hrrr.ncl"
load "names_grib2.txt"
;
load "$NCL_HOME/obj/cmap1_esbl.ncl"
;
begin
;
airport_id = asciiread("Airports_id.txt",-1,"string")
airport_loc = asciiread("Airports_locs.txt",(/dimsizes(airport_id),2/),"float")
;
fname = asciiread("newvil.txt",-1,"string")
grb_file = addfile(fname,"r")
;
check = ""
check = systemfunc("ls subh_back1_file.txt")
fnameback1test = 0
fnameback2test = 0
if (.not.ismissing(check.eq."subh_back1_file.txt")) then
   fnameback1 = asciiread("subh_back1_file.txt",-1,"string")
   back1exists = isfilepresent(fnameback1)
   if (back1exists) then
     print("reading "+fnameback1)
     fnameback1test = 1
     grb_file_back1 = addfile(fnameback1,"r")
   else
     print("error - missing file "+fnameback1)
   end if
end if
check2 = ""
check2 = systemfunc("ls subh_back2_file.txt")
if (.not.ismissing(check2.eq."subh_back2_file.txt")) then
   fnameback2 = asciiread("subh_back2_file.txt",-1,"string")
   back2exists = isfilepresent(fnameback2)
   if (back2exists) then
     print("reading "+fnameback2)
     fnameback2test = 1
     grb_file_back2 = addfile(fnameback2,"r")
   else
     print("error - missing file "+fnameback2)
   end if
end if
;
; Create an application object.
;
appid = create "mdss" appClass defaultapp
    "appUsrDir" : "./"
    "appDefaultParent" : True
end create
;
; Set only one of the following three params to 1, depending on the type
; of output desired (NCGM=metacode file, X11=screen, PS=PostScript file)
;
    NCGM=1
    X11=0
    PS=0
;
    if (NCGM .eq. 1) then
;
; Create an ncgmWorkstation object.
;
        wid = create "mdssWork" ncgmWorkstationClass defaultapp
           "wkMetaName" : "./esbl_cref15min.ncgm"
        end create
    else
      if (X11 .eq. 1) then
;
; Create an XWorkstation object.
;
        wid = create "mdssWork" xWorkstationClass defaultapp
            "wkPause" : True
        end create
      else
        if (PS .eq. 1) then
;
; Create a PSWorkstation object.
;
          wid = create "mdssWork" psWorkstationClass defaultapp
           "wkPSFileName" : "./esbl_cref15min.ps"
          end create
        end if
      end if
    end if
;
; Assign the colormap to the workstation.
setvalues wid
   "wkColorMap" : gen_colormap()
end setvalues
;
setvalues NhlGetWorkspaceObjectId()
   "wsMaximumSize": 247108864
end setvalues
;
; Load static file for parameters we need
;
static_file = addfile("geo_em.d01.nc","r")
;
WE = "WEST-EAST_GRID_DIMENSION"
nx = static_file@$WE$
SN = "SOUTH-NORTH_GRID_DIMENSION"
ny = static_file@$SN$
nx = nx - 1
ny = ny - 1
;
intm = grb_file->$T2MNAME$@initial_time
if (fnameback1test .eq. 1) then
  intmback1 = grb_file_back1->$T2MNAME$@initial_time
else
  intmback1 = -999
end if
if (fnameback2test .eq. 1) then
  intmback2 = grb_file_back2->$T2MNAME$@initial_time
else
  intmback2 = -999
end if
;
lat = static_file->XLAT_M(0,:,:)
lon = static_file->XLONG_M(0,:,:)
latin1 = static_file@TRUELAT1
latin2 = static_file@TRUELAT2
lov = static_file@STAND_LON
;
startyear = stringtointeger(getSubString(intm,6,9))
startmon  = stringtointeger(getSubString(intm,0,1))
startday  = stringtointeger(getSubString(intm,3,4))
starthour = stringtointeger(getSubString(intm,12,13))
startminute = 0
startsecond = 0
time = (/0.0/)
time@units = "seconds since 1970-01-01 00:00:0.0"
date = ut_inv_calendar(startyear,startmon,startday,starthour,startminute,0,time@units, 0)
;
if (fnameback1test .eq. 1) then
  startyearback1 = stringtointeger(getSubString(intmback1,6,9))
  startmonback1  = stringtointeger(getSubString(intmback1,0,1))
  startdayback1  = stringtointeger(getSubString(intmback1,3,4))
  starthourback1 = stringtointeger(getSubString(intmback1,12,13))
  startminuteback1 = 0
  startsecondback1 = 0
  timeback1 = (/0.0/)
  timeback1@units = "seconds since 1970-01-01 00:00:0.0"
  dateback1 = ut_inv_calendar(startyearback1,startmonback1,startdayback1, \
                              starthourback1,startminuteback1,0,timeback1@units, 0)
end if
;
if (fnameback2test .eq. 1) then
  startyearback2 = stringtointeger(getSubString(intmback2,6,9))
  startmonback2  = stringtointeger(getSubString(intmback2,0,1))
  startdayback2  = stringtointeger(getSubString(intmback2,3,4))
  starthourback2 = stringtointeger(getSubString(intmback2,12,13))
  startminuteback2 = 0
  startsecondback2 = 0
  timeback2 = (/0.0/)
  timeback2@units = "seconds since 1970-01-01 00:00:0.0"
  dateback2 = ut_inv_calendar(startyearback2,startmonback2,startdayback2, \
                              starthourback2,startminuteback2,0,timeback2@units, 0)
end if
;
fcindex = 3  ; needed for the special case of current time = 00
;
if (isfilevar(grb_file,"forecast_time0")) then
  numfcst = dimsizes(grb_file->forecast_time0) - 1
else
  numfcst = 0
end if
;
do iloop = 0, numfcst
;
if (isfilevar(grb_file,"forecast_time0")) then
  fctm = grb_file->forecast_time0(iloop)
else
  fctm = 0
end if
if (fnameback1test .eq. 1) then
  if (isfilevar(grb_file,"forecast_time0")) then
    fctmback1 = grb_file_back1->forecast_time0(iloop)
  else
    fctmback1 = grb_file_back1->forecast_time0(fcindex)
  end if
else
  fctmback1 = -999
end if
if (fnameback2test .eq. 1) then
  if (isfilevar(grb_file,"forecast_time0")) then
    fctmback2 = grb_file_back2->forecast_time0(iloop)
  else
    fctmback2 = grb_file_back2->forecast_time0(fcindex)
  end if
else
  fctmback2 = -999
end if
;
fcsttime = fctm * 60 ; find forecast time in seconds
fcstvalidtime = date + fcsttime
fcstvalidtime@units = "seconds since 1970-01-01 00:00:0.0"
utc_date = ut_calendar(fcstvalidtime, 0)
;
if (fnameback1test .eq. 1) then
  fcsttimeback1 = fctmback1 * 60 ; find forecast time in seconds
  fcstvalidtimeback1 = dateback1 + fcsttimeback1
  fcstvalidtimeback1@units = "seconds since 1970-01-01 00:00:0.0"
  utc_date_back1 = ut_calendar(fcstvalidtimeback1, 0)
end if
;
if (fnameback2test .eq. 1) then
  fcsttimeback2 = fctmback2 * 60 ; find forecast time in seconds
  fcstvalidtimeback2 = dateback2 + fcsttimeback2
  fcstvalidtimeback2@units = "seconds since 1970-01-01 00:00:0.0"
  utc_date_back2 = ut_calendar(fcstvalidtimeback2, 0)
end if
;
if (isfilevar(grb_file,"forecast_time0")) then
;  tvar = grb_file->$CREFNAME$(fcindex,:,:)
  tvar = grb_file->$CREFNAME$(iloop,:,:)
else
  tvar = grb_file->$CREFNAME$(:,:)
end if
tvar = where (.not. ismissing(tvar) .and. tvar .lt. 0, 0, tvar)
if (fnameback1test .eq. 1) then
  if (isfilevar(grb_file,"forecast_time0")) then
    tvarback1 = grb_file_back1->$CREFNAME$(iloop,:,:)
  else
    tvarback1 = grb_file_back1->$CREFNAME$(fcindex,:,:)
  end if
  tvarback1 = where (.not. ismissing(tvarback1) .and. tvarback1 .lt. 0, 0, tvarback1)
end if
if (fnameback2test .eq. 1) then
  if (isfilevar(grb_file,"forecast_time0")) then
    tvarback2 = grb_file_back2->$CREFNAME$(iloop,:,:)
  else
    tvarback2 = grb_file_back2->$CREFNAME$(fcindex,:,:)
  end if
  tvarback2 = where (.not. ismissing(tvarback2) .and. tvarback2 .lt. 0, 0, tvarback2)
end if
;
year   = floattointeger(utc_date(:,0))    ; Convert to integer for
month  = floattointeger(utc_date(:,1))    ; use in the sprinti function.
day    = floattointeger(utc_date(:,2))
hour   = floattointeger(utc_date(:,3))
minute = floattointeger(utc_date(:,4))
second = utc_date(:,5)
date_str = "Valid " + sprinti("%0.2i/", month) + sprinti("%0.2i/",day) + \
           sprinti("%0.4i", year) + " " + sprinti("%0.2i:", hour) + \
           sprinti("%0.2i", minute) + " UTC"
;
print(date_str)
print("comp reflectivity current")
print(min(tvar))
print(max(tvar))
if (fnameback1test .eq. 1) then
  print("comp reflectivity back1")
  print(min(tvarback1))
  print(max(tvarback1))
end if
if (fnameback2test .eq. 1) then
  print("comp reflectivity back2")
  print(min(tvarback2))
  print(max(tvarback2))
end if
;
load "$NCL_HOME/obj/hrrr_tiles_loop.ncl"
;
load "$NCL_HOME/obj/hrrr_map_blk_counties_blk.ncl"
;
; Create a ScalarField object.
;
if (min(tvar(lly:ury,llx:urx)) .eq. max(tvar(lly:ury,llx:urx))) then
  tvar(lly,llx) = 5.01
end if
tfield = create "ScalarField" scalarFieldClass appid
    "sfDataArray" : tvar
    "sfXCStartSubsetV" : llx
    "sfYCStartSubsetV" : lly
    "sfXCEndSubsetV" : urx
    "sfYCEndSubsetV" : ury
;    "sfMissingValueV" : tvar@_FillValue
end create
;
if (fnameback1test .eq. 1) then
  if (min(tvarback1(lly:ury,llx:urx)) .eq. max(tvarback1(lly:ury,llx:urx))) then
    tvarback1(lly,llx) = 5.01
  end if
  tfieldback1 = create "ScalarField" scalarFieldClass appid
      "sfDataArray" : tvarback1
      "sfXCStartSubsetV" : llx
      "sfYCStartSubsetV" : lly
      "sfXCEndSubsetV" : urx
      "sfYCEndSubsetV" : ury
      "sfMissingValueV" : tvarback1@_FillValue
  end create
end if
;
if (fnameback2test .eq. 1) then
  if (min(tvarback2(lly:ury,llx:urx)) .eq. max(tvarback2(lly:ury,llx:urx))) then
    tvarback2(lly,llx) = 5.01
  end if
  tfieldback2 = create "ScalarField" scalarFieldClass appid
      "sfDataArray" : tvarback2
      "sfXCStartSubsetV" : llx
      "sfYCStartSubsetV" : lly
      "sfXCEndSubsetV" : urx
      "sfYCEndSubsetV" : ury
      "sfMissingValueV" : tvarback2@_FillValue
  end create
end if
;
tvarbkg = tvar * 0.
tvarbkg(lly,llx) = 41.
tfieldbkg = create "ScalarField" scalarFieldClass appid
    "sfDataArray" : tvarbkg
    "sfXCStartSubsetV" : llx
    "sfYCStartSubsetV" : lly
    "sfXCEndSubsetV" : urx
    "sfYCEndSubsetV" : ury
    "sfMissingValueV" : tvarbkg@_FillValue
end create
;
cl0 = 5
cl1 = 35
cl2 = 45
cl3 = 55
cl4 = 65
;
load "$NCL_HOME/obj/cref_bkg.ncl"
;
intmdate = getSubString(intm,0,9)
intminit = getSubString(intm,12,13)
intmcurrentruntime = intmdate+" "+intminit+"Z"
fchr = floattoint(floor(fcsttime / 3600))
fcmn = floattoint(((fcsttime / 3600.) - floor(fcsttime / 3600.)) * 60)
currentstring = intmcurrentruntime+" "+sprinti("%0.2i:", fchr)+sprinti("%0.2i", fcmn)+"hr fcst"
if (fnameback2test .eq. 1) then
  load "$NCL_HOME/obj/cref_back2_abv5.ncl"
  setvalues cnidback2abv5
    "cnFillMode" : "AreaFill"
    "cnLevels" : (/ cl0 /)
    "cnFillColors" : (/ -1,53 /)
  end setvalues
  load "$NCL_HOME/obj/cref_back2.ncl"
  setvalues cnidback2
    "cnFillMode" : "AreaFill"
    "cnLevels" : (/ cl1,cl2,cl3,cl4 /)
    "cnFillColors" : (/ -1,35,32,29,26 /)
  end setvalues
  intmback2date = getSubString(intmback2,0,9)
  intmback2init = getSubString(intmback2,12,13)
  intmback2runtime = intmback2date+" "+intmback2init+"Z"
  fchrback2 = floattoint(floor(fcsttimeback2 / 3600))
  fcmnback2 = floattoint(((fcsttimeback2 / 3600.) - floor(fcsttimeback2 / 3600.)) * 60)
  back2string = intmback2runtime+" "+sprinti("%0.2i:", fchrback2)+sprinti("%0.2i", fcmnback2)+"hr fcst"
else
  back2string = "MISSING"
end if
if (fnameback1test .eq. 1) then
  load "$NCL_HOME/obj/cref_back1_abv5.ncl"
  setvalues cnidback1abv5
    "cnFillMode" : "AreaFill"
    "cnLevels" : (/ cl0 /)
    "cnFillColors" : (/ -1,53 /)
  end setvalues
  load "$NCL_HOME/obj/cref_back1.ncl"
  setvalues cnidback1
    "cnFillMode" : "AreaFill"
    "cnLevels" : (/ cl1,cl2,cl3,cl4 /)
    "cnFillColors" : (/ -1,23,20,17,14 /)
  end setvalues
  intmback1date = getSubString(intmback1,0,9)
  intmback1init = getSubString(intmback1,12,13)
  intmback1runtime = intmback1date+" "+intmback1init+"Z"
  fchrback1 = floattoint(floor(fcsttimeback1 / 3600))
  fcmnback1 = floattoint(((fcsttimeback1 / 3600.) - floor(fcsttimeback1 / 3600.)) * 60)
  back1string = intmback1runtime+" "+sprinti("%0.2i:", fchrback1)+sprinti("%0.2i", fcmnback1)+"hr fcst"
else
  back1string = "MISSING"
end if
load "$NCL_HOME/obj/cref_current_abv5.ncl"
setvalues cnidcurrentabv5
  "cnFillMode" : "AreaFill"
  "cnLevels" : (/ cl0 /)
  "cnFillColors" : (/ -1,53 /)
end setvalues
load "$NCL_HOME/obj/cref_current.ncl"
setvalues cnid
  "cnFillMode" : "AreaFill"
  "cnLevels" : (/ cl1,cl2,cl3,cl4 /)
  "cnFillColors" : (/ -1,11,8,5,2 /)
end setvalues
;
scl0 = tostring(cl0)
scl1 = tostring(cl1)
scl2 = tostring(cl2)
scl3 = tostring(cl3)
scl4 = tostring(cl4)
;
lbid = create "LabelBar" labelBarClass wid
    "lbOrientation" : "Horizontal"
    "lbAutoManage" : False
    "lbLabelFont" : 21
    "lbLabelFontHeightF" : .01
    "lbLabelFontThicknessF" : 2
    "lbLabelFontColor" : 1
    "lbPerimOn" : False
    "lbBoxCount" : 20
    "lbBoxLinesOn" : False
    "lbFillColors" : (/ 52,53,35,32,29,26,0,52,53,23,20,17,14,0,52,53,11,8,5,2 /)
    "lbMonoFillPattern" : True
    "lbLabelAlignment" : "InteriorEdges"
    "lbLabelPosition" : "Bottom"
    "lbLabelStrings" : (/ scl0,scl1,scl2,scl3,scl4,"","",scl0,scl1,scl2,scl3,scl4, \
                          "","",scl0,scl1,scl2,scl3,scl4 /)
    "vpXF"      : vpx
    "vpYF"      : (vpy - vpheight) - 0.008
    "vpWidthF"  : vpwidth
    "vpHeightF" : 0.06
end create
;
titlestring = "Ensemble Composite Reflectivity (dBZ)"
load "$NCL_HOME/obj/add_titles_subh.ncl"
;
; Draw map
;
draw(cnidbkg)
;
; Draw low level reflectivity from all runs first
;
if (fnameback2test .eq. 1) then
  draw(cnidback2abv5)
end if
if (fnameback1test .eq. 1) then
  draw(cnidback1abv5)
end if
draw(cnidcurrentabv5)
;
if (fnameback2test .eq. 1) then
  draw(cnidback2)
end if
if (fnameback1test .eq. 1) then
  draw(cnidback1)
end if
draw(cnid)
;
draw(mpid)
draw(lbid)
;
setvalues lbid
  "lbLabelAlignment" : "InteriorEdges"
  "lbLabelPosition" : "Top"
  "lbFillColors" : (/ 52,53,35,32,29,26,0,52,53,23,20,17,14,0,52,53,11,8,5,2 /)
  "lbLabelFont" : 21
  "lbLabelFontHeightF" : .01
  "lbLabelFontThicknessF" : 2
  "lbLabelFontColor" : 1
  "lbLabelStrings" : (/ "","",back2string,"","","","","","",back1string, \
                        "","","","","","",currentstring,"","" /)
  "vpXF"      : vpx
  "vpYF"      : (vpy - vpheight) + 0.011
  "vpWidthF"  : vpwidth
  "vpHeightF" : 0.06
end setvalues
;
draw(lbid)
;
;gsres = True
;if (iq .eq. 0) then
;  do i = 0,dimsizes(airport_id)-1
;    gsres@gsMarkerIndex = 16
;    gsres@gsMarkerColor = 23
;    gsres@gsMarkerSizeF = 0.004
;    gsn_polymarker(wid,mpid,airport_loc(i,1),airport_loc(i,0),gsres)
;    gsres@gsMarkerIndex = 16
;    gsres@gsMarkerColor = 1
;    gsres@gsMarkerSizeF = 0.002
;    gsn_polymarker(wid,mpid,airport_loc(i,1),airport_loc(i,0),gsres)
;  end do
;else
;  do i = 0,dimsizes(airport_id)-1
;    gsres@gsMarkerIndex = 16
;    gsres@gsMarkerColor = 23
;    gsres@gsMarkerSizeF = 0.01
;    gsn_polymarker(wid,mpid,airport_loc(i,1),airport_loc(i,0),gsres)
;    gsres@gsMarkerIndex = 16
;    gsres@gsMarkerColor = 1
;    gsres@gsMarkerSizeF = 0.005
;    gsn_polymarker(wid,mpid,airport_loc(i,1),airport_loc(i,0),gsres)
;  end do
;end if
;
frame(wid)
;
end do  ; end of iq
;
end do  ; end of iloop
;
end
