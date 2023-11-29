load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCL_HOME/obj/plot_titles_hrrr.ncl"
load "names_grib2.txt"
;
load "$NCL_HOME/obj/cmap_ci.ncl"
;
begin
;
airport_id = asciiread("Airports_id.txt",-1,"string")
airport_loc = asciiread("Airports_locs.txt",(/dimsizes(airport_id),2/),"float")
;
fname = asciiread("newvil.txt",-1,"string")
grb_file = addfile(fname,"r")
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
           "wkMetaName" : "./sfc_ca115min.ncgm"
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
           "wkPSFileName" : "./sfc_ca115min.ps"
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
;
time = (/0.0/)
time@units = "seconds since 1970-01-01 00:00:0.0"
date = ut_inv_calendar(startyear,startmon,startday,starthour,startminute,0,time@units, 0)
;
fcindex = -1
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
;
fcsttime = fctm * 60 ; find forecast time in seconds
fcstvalidtime = date + fcsttime
fcstvalidtime@units = "seconds since 1970-01-01 00:00:0.0"
utc_date = ut_calendar(fcstvalidtime, 0)
;
fcindex = fcindex + 1
;
if (isfilevar(grb_file,"forecast_time0")) then
  tvar = grb_file->$CA1NAME$(fcindex,0,:,:)
  uvar = grb_file->$U10MNAME$(fcindex,0,:,:) * 1.9429 ; convert to knots
  vvar = grb_file->$V10MNAME$(fcindex,0,:,:) * 1.9429 ; convert to knots
else
  tvar = grb_file->$CA1NAME$(0,:,:)
  uvar = grb_file->$U10MNAME$(0,:,:) * 1.9429 ; convert to knots
  vvar = grb_file->$V10MNAME$(0,:,:) * 1.9429 ; convert to knots
end if
;
tvarsave = tvar
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
print("Convective Activity - based on lightning threat")
print(min(tvar))
print(max(tvar))
;
load "$NCL_HOME/obj/hrrr_tiles_loop.ncl"
;
if (min(tvar(lly:ury,llx:urx)) .ge. 80) then
  tvar = 975
  tvar(lly,llx) = 70  ; avoid constant value map
end if
;
load "$NCL_HOME/obj/hrrr_map_blk_counties_blk.ncl"
;
tvar = tvarsave
;
if (min(tvar(lly:ury,llx:urx)) .eq. max(tvar(lly:ury,llx:urx))) then
  tvar = 975
  tvar(lly,llx) = 79  ; avoid constant value map
end if
;
; Create a ScalarField object.
;
tfield = create "ScalarField" scalarFieldClass appid
    "sfDataArray" : tvar
    "sfXCStartSubsetV" : llx
    "sfYCStartSubsetV" : lly
    "sfXCEndSubsetV" : urx
    "sfYCEndSubsetV" : ury
;    "sfMissingValueV" : tvar@_FillValue
end create
;
; Create a VectorField object.
;
if (iq .ne. 0) then
  vfield = create "VectorField" vectorFieldClass appid
      "vfUDataArray" : uvar
      "vfVDataArray" : vvar
      "vfXCStartSubsetV" : llx
      "vfYCStartSubsetV" : lly
      "vfXCEndSubsetV" : urx
      "vfYCEndSubsetV" : ury
;      "vfMissingVValueV" : vvar@_FillValue
;      "vfMissingUValueV" : uvar@_FillValue
      "vfXCStride" : 15          ; i.e., plot a vector at every (n+1)th point.
      "vfYCStride" : 15
  end create
else
  vfield = create "VectorField" vectorFieldClass appid
      "vfUDataArray" : uvar
      "vfVDataArray" : vvar
      "vfXCStartSubsetV" : llx
      "vfYCStartSubsetV" : lly
      "vfXCEndSubsetV" : urx
      "vfYCEndSubsetV" : ury
;      "vfMissingVValueV" : vvar@_FillValue
;      "vfMissingUValueV" : uvar@_FillValue
      "vfXCStride" : 30          ; i.e., plot a vector at every (n+1)th point.
      "vfYCStride" : 30
  end create
end if
;
; Create a VectorPlot object.
;
vcid = create "vectorplot" vectorPlotClass wid
    "vcVectorFieldData":  vfield
    "vcGlyphStyle" : "WindBarb"
;    "vcWindBarbLineThicknessF" : 1.2
    "vcWindBarbColor" : 0
;    "vcWindBarbTickSpacingF" : 0.1875
    "vcRefAnnoOn" : False
    "pmTickMarkDisplayMode" : "NoCreate"
    "vpXF"      : vpx        ; set viewport
    "vpYF"      : vpy
    "vpWidthF"  : vpwidth
    "vpHeightF" : vpheight
end create
;
setvalues vcid
  "vcMinMagnitudeF" : 0
end setvalues
;
; Create a ContourPlot object.
;
load "$NCL_HOME/obj/ci.ncl"
;
;if (iq .ge. 8) then
;  setvalues cnid
;    "cnFillMode" : "AreaFill"
;  end setvalues
;end if
;
titlestring = "Minutes since last Conv Activity (based on lightning threat)"
load "$NCL_HOME/obj/add_titles_subh.ncl"
;
; Draw map
;
draw(cnid)
draw(mpid)
;draw(vcid)
;
gsres = True
if (iq .eq. 0) then
  do i = 0,dimsizes(airport_id)-1
    gsres@gsMarkerIndex = 16
    gsres@gsMarkerColor = 11
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
    gsres@gsMarkerColor = 11
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
end do  ; end of iq
;
end do  ; end of iloop
;
end
