load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl";
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
load "$NCL_HOME/obj/plot_titles_hrrr.ncl"
load "./names_grib2.txt"
;
load "$NCL_HOME/obj/cmap_diff3.ncl"
;
begin
;
airport_id = asciiread("Airports_id.txt",-1,"string")
airport_loc = asciiread("Airports_locs.txt",(/dimsizes(airport_id),2/),"float")
;
fname = asciiread("arw_file.txt",-1,"string") 
grb_file = addfile(fname,"r")
;
check = ""
check = systemfunc("ls back1_hour.txt") 
print("check = "+check)
fnameback1test = 0
if (.not.ismissing(check.eq."back1_hour.txt")) then 
  print("found back1_hour.txt") 
  fnameback1 = asciiread("back1_hour.txt",-1,"string")
  fnameback1test = 1
  grb_file_back1 = addfile(fnameback1,"r")
else
  print("did not find back1_hour.txt") 
  exit
end if 
;
if (fnameback1test .eq. 1) then
  print("fnameback1 ="+fnameback1)
  intmback1 = grb_file_back1->$T2MNAME$@initial_time
  fctmback1 = grb_file_back1->$T2MNAME$@forecast_time
else
  intmback1 = -999
  fctmback1 = -999
end if
;
hr3sizes = filevardimsizes(grb_file,LATNAME)
ny = hr3sizes(0)
nx = hr3sizes(1)
;
intm = grb_file->$T2MNAME$@initial_time
fctm = grb_file->$T2MNAME$@forecast_time
lat = grb_file->$LATNAME$(:,:)
lon = grb_file->$LONNAME$(:,:)
latin1 = grb_file->$LONNAME$@Latin1
latin2 = grb_file->$LONNAME$@Latin2
lov = grb_file->$LONNAME$@Lov
;
if (fctm .eq. 0) then
  exit
end if
;
uvar = grb_file->$U10MNAME$(1,:,:) * 1.9429 ; convert to knots
vvar = grb_file->$V10MNAME$(1,:,:) * 1.9429 ; convert to knots
uvarback1 = grb_file_back1->$U10MNAME$(1,:,:) * 1.9429 ; convert to knots
vvarback1 = grb_file_back1->$V10MNAME$(1,:,:) * 1.9429 ; convert to knots
;
uv2 = uvar * uvar
vv2 = vvar * vvar
wind = sqrt(uv2 + vv2)
uv2back1 = uvarback1 * uvarback1
vv2back1 = vvarback1 * vvarback1
windback1 = sqrt(uv2back1 + vv2back1)
tvar = wind - windback1
;tvarsm = tvar
;p = 0.50
;q = 0.25 ; heavy local smooth
;npass = 10
;do np=1,npass
;  tvarsm = smth9 (tvarsm, p, q, True)
;end do
;tvar = tvarsm
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
           sprinti("%0.4i", year) + " " + sprinti("%0.2i:00 ", hour) + \
           "UTC"
;
print(date_str)
print("1hr 80m wind speed change")
print(min(tvar))
print(max(tvar))
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
           "wkMetaName" : "./80m_wchg.ncgm"
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
           "wkPSFileName" : "./80m_wchg.ps"
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
; Increase workspace memory
setvalues NhlGetWorkspaceObjectId()
   "wsMaximumSize": 494217728
end setvalues
;
load "$NCL_HOME/obj/hrrr_tiles_loop.ncl"
;
load "$NCL_HOME/obj/hrrr_map_blk_counties_blk.ncl"
;
tfield = create "ScalarField" scalarFieldClass appid
    "sfDataArray" : tvar
    "sfXCStartSubsetV" : llx
    "sfYCStartSubsetV" : lly
    "sfXCEndSubsetV" : urx
    "sfYCEndSubsetV" : ury
    "sfMissingValueV" : tvar@_FillValue
end create
;
load "$NCL_HOME/obj/diff_-32-32by4.ncl"
;
if (iq .ge. 8) then
  setvalues cnid
    "cnFillMode" : "AreaFill"
  end setvalues
end if
;
titlestring = "80m Wind Speed Change (over prev hour) (kt)"
load "$NCL_HOME/obj/add_titles_rr.ncl"
;
; Draw map
;
draw(cnid)
draw(mpid)
;
gsres = True
if (iq .eq. 0) then
  do i = 0,dimsizes(airport_id)-1
    gsres@gsMarkerIndex = 16
    gsres@gsMarkerColor = 19
    gsres@gsMarkerSizeF = 0.004
    gsn_polymarker(wid,mpid,airport_loc(i,1),airport_loc(i,0),gsres)
    gsres@gsMarkerIndex = 16
    gsres@gsMarkerColor = 1
    gsres@gsMarkerSizeF = 0.002
    gsn_polymarker(wid,mpid,airport_loc(i,1),airport_loc(i,0),gsres)
  end do
else
  do i = 0,dimsizes(airport_id)-1
    gsres@gsMarkerIndex = 16
    gsres@gsMarkerColor = 19
    gsres@gsMarkerSizeF = 0.01
    gsn_polymarker(wid,mpid,airport_loc(i,1),airport_loc(i,0),gsres)
    gsres@gsMarkerIndex = 16
    gsres@gsMarkerColor = 1
    gsres@gsMarkerSizeF = 0.005
    gsn_polymarker(wid,mpid,airport_loc(i,1),airport_loc(i,0),gsres)
  end do
end if
;
frame(wid)
;
end do
;
end
;
