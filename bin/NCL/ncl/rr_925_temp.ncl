load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCL_HOME/obj/plot_titles_hrrr.ncl"
load "./names_grib2.txt"
;
load "$NCL_HOME/obj/cmap1_dbl2.ncl"
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
do ii = 0, dimsizes(levnam)-1
  if (levnam(ii) .eq. 92500) then
    level = ii
  end if
end do
;
load "$NCL_HOME/obj/get_date_str.ncl"
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
           "wkMetaName" : "./925_temp.ncgm"
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
           "wkPSFileName" : "./925_temp.ps"
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
   "wsMaximumSize": 247108864
end setvalues
;
load "$NCL_HOME/obj/hrrr_tiles_loop.ncl"
;
load "$NCL_HOME/obj/hrrr_map_blk_counties_wht.ncl"
;
setvalues mpid
  "mpCountyLineColor" : 5  ; lt grey
end setvalues
;
tvar = grb_file->$TNAME$(level,:,:) - 273.15
hvar = grb_file->$GHNAME$(level,:,:) / 10. ; convert to decameters
uvar = grb_file->$UNAME$(level,:,:) * 1.9429 ; convert to knots
vvar = grb_file->$VNAME$(level,:,:) * 1.9429 ; convert to knots
psfcvar = grb_file->$PSFCNAME$(:,:)
;
uv2 = uvar * uvar
vv2 = vvar * vvar
wind = sqrt(uv2 + vv2)
;
if (iq .eq. 0) then
  print("925 temp")
  print(min(tvar))
  print(max(tvar))
  print("gh")
  print(min(hvar))
  print(max(hvar))
  print("wind")
  print(min(wind))
  print(max(wind))
  print("psfc")
  print(min(psfcvar))
  print(max(psfcvar))
end if
;
; Create ScalarField objects.
;
; Temperature
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
; Geopotential Height
;
hfield = create "ScalarField" scalarFieldClass appid
    "sfDataArray" : hvar
    "sfXCStartSubsetV" : llx
    "sfYCStartSubsetV" : lly
    "sfXCEndSubsetV" : urx
    "sfYCEndSubsetV" : ury
    "sfMissingValueV" : hvar@_FillValue
end create
;
; Surface pressure
;
psfcfield = create "ScalarField" scalarFieldClass appid
    "sfDataArray" : psfcvar
    "sfXCStartSubsetV" : llx
    "sfYCStartSubsetV" : lly
    "sfXCEndSubsetV" : urx
    "sfYCEndSubsetV" : ury
    "sfMissingValueV" : psfcvar@_FillValue
end create
;
; Create a VectorField object.
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
; Create VectorPlot objects.
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
; Create ContourPlot objects.
;
load "$NCL_HOME/obj/temp_-40-40by2.5.ncl"
;
if (iq .ge. 8) then
  setvalues cnid
    "cnFillMode" : "AreaFill"
  end setvalues
end if
;
load "$NCL_HOME/obj/0_contour.ncl"
;
setvalues cnid6
  "cnLineColors" : (/30/)
  "cnLineLabelDensityF" : 2
  "cnLineLabelBackgroundColor" : 30
end setvalues
;
load "$NCL_HOME/obj/psfc_mask_925.ncl"
;
; geopotential height
;
cnid4 = create "contourplot" contourPlotClass wid
    "cnScalarFieldData":  hfield
    "cnLevelSelectionMode" : "ManualLevels"
    "cnMinLevelValF" : 3
    "cnMaxLevelValF" : 600
    "cnLevelSpacingF" : 3
    "cnLineThicknessF" : 1.5
    "cnMonoLineColor" : True
    "cnLineLabelPlacementMode" : "Computed"
    "cnInfoLabelOn" : False
    "cnLinesOn" : True
    "cnLineColor" : 1
    "cnLineLabelsOn" : True
    "cnLineLabelInterval" : 1
    "cnLineLabelDensityF" : 0.5
    "cnLineLabelFont" : 21
    "cnLineLabelFontHeightF" : 0.01
    "cnLineLabelFontColor" : "Foreground"
    "cnLineLabelBackgroundColor" : "Background"
    "pmTickMarkDisplayMode" : "NoCreate"
    "vpXF"      : vpx        ; set viewport
    "vpYF"      : vpy       
    "vpWidthF"  : vpwidth
    "vpHeightF" : vpheight
end create
;
titlestring = "925mb Temperature (C), Height (dm), Wind (kt)"
load "$NCL_HOME/obj/add_titles_rr.ncl"
;
; Draw map
;
draw(cnid)
draw(mpid)
draw(vcidt)
draw(cnid4)
draw(cnid6)
draw(cnid8)
;
gsres = True
if (iq .eq. 0) then
  do i = 0,dimsizes(airport_id)-1
    gsres@gsMarkerIndex = 16
    gsres@gsMarkerColor = 48
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
    gsres@gsMarkerColor = 48
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
