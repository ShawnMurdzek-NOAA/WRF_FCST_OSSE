load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl";
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCL_HOME/obj/plot_titles_hrrr.ncl"
load "./names_grib2.txt"
;
load "$NCL_HOME/obj/cmap_ptyp.ncl"
;
begin
;
airport_id = asciiread("Airports_id.txt",-1,"string")
airport_loc = asciiread("Airports_locs.txt",(/dimsizes(airport_id),2/),"float")
;
fname = asciiread("arw_file.txt",-1,"string") 
grb_file = addfile(fname,"r")
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

snow = grb_file->$SNOWNAME$(:,:) * 1 
icep = grb_file->$ICEPNAME$(:,:) * 2 
frzr = grb_file->$FRZRNAME$(:,:) * 4
rain = grb_file->$RAINNAME$(:,:) * 8
;
if (fctm .eq. 0) then
  exit
end if
;
if ( fctm .gt. 0 ) then
  if ( isfilevar(grb_file,TP1HNAME) ) then
    zz = TP1HNAME
  else
    if ( fctm .eq. 1 ) then
      zz = TPNAME
    else
      zz = TPNAME + fctm + "h"
    end if
  end if
  pcpvar = grb_file->$zz$(:,:) * 0.03937 ; convert to inches
else
  exit
end if
;
load "$NCL_HOME/obj/get_date_str.ncl"
;     
print("snow")
print(min(snow))
print(max(snow))
print("icepellets")
print(min(icep))
print(max(icep))
print("freezing rain")
print(min(frzr))
print(max(frzr))
print("rain")
print(min(rain))
print(max(rain))
;
; Create an application object.
;
appid = create "wrfsi" appClass defaultapp
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
        wid = create "wrfsiWork" ncgmWorkstationClass defaultapp
           "wkMetaName" : "./sfc_ptyp.ncgm"
        end create
    else
      if (X11 .eq. 1) then
;
; Create an XWorkstation object.
;
        wid = create "wrfsiWork" xWorkstationClass defaultapp
            "wkPause" : True
        end create
      else
        if (PS .eq. 1) then
;
; Create a PSWorkstation object.
;
          wid = create "wrfsiWork" psWorkstationClass defaultapp
           "wkPSFileName" : "./sfc_ptyp.ps"
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
   "wsMaximumSize": 33554432
end setvalues
;
load "$NCL_HOME/obj/hrrr_tiles_loop.ncl"
;
;vpheight = round((vpheight * 100),0) / 100  ; causing ARSCAM error, fixed below
;vpwidth = round((vpwidth * 100),0) / 100
vpheight = round(((vpheight + .005) * 100),0) / 100
vpwidth = round(((vpwidth + .005) * 100),0) / 100
;
load "$NCL_HOME/obj/hrrr_map_blk_counties_blk.ncl"
;
; Create a ScalarField object.
;
pcpfield = create "ScalarField" scalarFieldClass appid
    "sfDataArray" : pcpvar
    "sfXCStartSubsetV" : llx
    "sfYCStartSubsetV" : lly
    "sfXCEndSubsetV" : urx
    "sfYCEndSubsetV" : ury
    "sfMissingValueV" : pcpvar@_FillValue
end create
;
snowfield = create "ScalarField" scalarFieldClass appid
    "sfDataArray" : snow
    "sfXCStartSubsetV" : llx
    "sfYCStartSubsetV" : lly
    "sfXCEndSubsetV" : urx
    "sfYCEndSubsetV" : ury
    "sfMissingValueV" : snow@_FillValue
end create
;
rainfield = create "ScalarField" scalarFieldClass appid
    "sfDataArray" : rain
    "sfXCStartSubsetV" : llx
    "sfYCStartSubsetV" : lly
    "sfXCEndSubsetV" : urx
    "sfYCEndSubsetV" : ury
    "sfMissingValueV" : rain@_FillValue
end create
;
frzrfield = create "ScalarField" scalarFieldClass appid
    "sfDataArray" : frzr
    "sfXCStartSubsetV" : llx
    "sfYCStartSubsetV" : lly
    "sfXCEndSubsetV" : urx
    "sfYCEndSubsetV" : ury
    "sfMissingValueV" : frzr@_FillValue
end create
;
icepfield = create "ScalarField" scalarFieldClass appid
    "sfDataArray" : icep
    "sfXCStartSubsetV" : llx
    "sfYCStartSubsetV" : lly
    "sfXCEndSubsetV" : urx
    "sfYCEndSubsetV" : ury
    "sfMissingValueV" : icep@_FillValue
end create
;
; Create a ContourPlot object.
;
load "$NCL_HOME/obj/ptyp.ncl"
;
if (iq .ge. 8) then
  setvalues cnid
    "cnFillMode" : "AreaFill"
  end setvalues
end if
;
titlestring = "1h Total Precip (in), Precip Type"
load "$NCL_HOME/obj/add_titles_rr.ncl"
;
; Draw map
;
draw(cnid)
draw(mpid)
draw(cnid2)
draw(cnid3)
draw(cnid4)
draw(cnid5)
draw(lbid)
;
gsres = True
if (iq .eq. 0) then
  do i = 0,dimsizes(airport_id)-1
    gsres@gsMarkerIndex = 16
    gsres@gsMarkerColor = 21
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
    gsres@gsMarkerColor = 21
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
