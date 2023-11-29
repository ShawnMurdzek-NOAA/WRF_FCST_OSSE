load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCL_HOME/obj/plot_titles_hrrr.ncl"
load "./names_grib2.txt"
;
load "$NCL_HOME/obj/cmap1.ncl"
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
;
levnam = grb_file->$LEVELNAME$
;
do ii = 0, dimsizes(levnam)-1
  if (levnam(ii) .eq. 50000) then
    level500 = ii
  end if
  if (levnam(ii) .eq. 52500) then
    level525 = ii
  end if
  if (levnam(ii) .eq. 55000) then
    level550 = ii
  end if
  if (levnam(ii) .eq. 57500) then
    level575 = ii
  end if
  if (levnam(ii) .eq. 60000) then
    level600 = ii
  end if
  if (levnam(ii) .eq. 62500) then
    level625 = ii
  end if
  if (levnam(ii) .eq. 65000) then
    level650 = ii
  end if
  if (levnam(ii) .eq. 67500) then
    level675 = ii
  end if
  if (levnam(ii) .eq. 70000) then
    level700 = ii
  end if
  if (levnam(ii) .eq. 72500) then
    level725 = ii
  end if
  if (levnam(ii) .eq. 75000) then
    level750 = ii
  end if
  if (levnam(ii) .eq. 77500) then
    level775 = ii
  end if
  if (levnam(ii) .eq. 80000) then
    level800 = ii
  end if
  if (levnam(ii) .eq. 82500) then
    level825 = ii
  end if
  if (levnam(ii) .eq. 85000) then
    level850 = ii
  end if
end do
;
uvar = grb_file->$UNAME$(level700,:,:) * 1.9429 ; convert to knots
vvar = grb_file->$VNAME$(level700,:,:) * 1.9429 ; convert to knots
rh85 = grb_file->$RHNAME$(level850,:,:)
rh82 = grb_file->$RHNAME$(level825,:,:)
rh80 = grb_file->$RHNAME$(level800,:,:)
rh77 = grb_file->$RHNAME$(level775,:,:)
rh75 = grb_file->$RHNAME$(level750,:,:)
rh72 = grb_file->$RHNAME$(level725,:,:)
rh70 = grb_file->$RHNAME$(level700,:,:)
rh67 = grb_file->$RHNAME$(level675,:,:)
rh65 = grb_file->$RHNAME$(level650,:,:)
rh62 = grb_file->$RHNAME$(level625,:,:)
rh60 = grb_file->$RHNAME$(level600,:,:)
rh57 = grb_file->$RHNAME$(level575,:,:)
rh55 = grb_file->$RHNAME$(level550,:,:)
rh52 = grb_file->$RHNAME$(level525,:,:)
rh50 = grb_file->$RHNAME$(level500,:,:)
mnrh = (rh85 + rh82 + rh80 + rh77 + rh75 + rh72 + rh70 + rh67 + rh65 + rh62 + rh60 + rh57 + rh55 + rh52 + rh50) / 15
;
load "$NCL_HOME/obj/get_date_str.ncl"
;
print(date_str)
print("mean RH")
print(min(mnrh))
print(max(mnrh))
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
           "wkMetaName" : "./ua_rh.ncgm"
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
           "wkPSFileName" : "./ua_rh.ps"
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
load "$NCL_HOME/obj/hrrr_tiles_loop.ncl"
;
load "$NCL_HOME/obj/hrrr_map_blk_counties_blk.ncl"
;
; Create a ScalarField object.
;
tfield = create "ScalarField" scalarFieldClass appid
    "sfDataArray" : mnrh
    "sfXCStartSubsetV" : llx
    "sfYCStartSubsetV" : lly
    "sfXCEndSubsetV" : urx
    "sfYCEndSubsetV" : ury
    "sfMissingValueV" : mnrh@_FillValue
end create
;
; Create a VectorField object
;
vfield = create "VectorField" vectorFieldClass appid
    "vfUDataArray" : uvar
    "vfVDataArray" : vvar
    "vfXCStartSubsetV" : llx
    "vfYCStartSubsetV" : lly
    "vfXCEndSubsetV" : urx
    "vfYCEndSubsetV" : ury
    "vfMissingVValueV" : vvar@_FillValue
    "vfMissingUValueV" : uvar@_FillValue
    "vfXCStride" : wstride        ; i.e., plot a vector at every (n+1)th point.
    "vfYCStride" : wstride
end create
;
; Create a VectorPlot object.
;
vcidt = create "vectorplot" vectorPlotClass wid
    "vcVectorFieldData":  vfield
    "vcGlyphStyle" : "WindBarb"
    "vcWindBarbLineThicknessF" : 1.2
    "vcWindBarbColor" : 0
    "vcRefAnnoOn" : False
    "vcWindBarbTickSpacingF" : 0.1875
    "pmTickMarkDisplayMode" : "NoCreate"
    "vpXF"      : vpx        ; set viewport
    "vpYF"      : vpy
    "vpWidthF"  : vpwidth
    "vpHeightF" : vpheight
end create
;
setvalues vcidt
  "vcMinMagnitudeF" : 0
end setvalues
;
; Create a ContourPlot object.
;
load "$NCL_HOME/obj/rh.ncl"
;
if (iq .ge. 8) then
  setvalues cnid
    "cnFillMode" : "AreaFill"
  end setvalues
end if
;
titlestring = "850-500mb mean Rel Hum (%), 700mb Wind (kt)"
load "$NCL_HOME/obj/add_titles_rr.ncl"
;
; Draw map
;
draw(cnid)
draw(mpid)
draw(vcidt)
;
gsres = True
if (iq .eq. 0) then
  do i = 0,dimsizes(airport_id)-1
    gsres@gsMarkerIndex = 16
    gsres@gsMarkerColor = 20
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
    gsres@gsMarkerColor = 20
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
