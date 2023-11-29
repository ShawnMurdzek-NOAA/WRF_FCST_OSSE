load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl";
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCL_HOME/obj/plot_titles_hrrr.ncl"
load "./names_grib2.txt"
;
load "$NCL_HOME/obj/cmap_cref.ncl"
;
begin
;
airport_id = asciiread("Airports_id.txt",-1,"string")
airport_loc = asciiread("Airports_locs.txt",(/dimsizes(airport_id),2/),"float")
;
fname = asciiread("arw_file.txt",-1,"string") 
grb_file = addfile(fname,"r")
;
fname2 = asciiread("arw_file2.txt",-1,"string")
grb_file2 = addfile(fname2,"r")
;
hr3sizes = filevardimsizes(grb_file,LATNAME)
ny = hr3sizes(0)
nx = hr3sizes(1)
;
intm = grb_file->$T2MNAME$@initial_time
fctm = grb_file->$T2MNAME$@forecast_time
fctm2 = grb_file2->$T2MNAME$@forecast_time
lat = grb_file->$LATNAME$(:,:)
lon = grb_file->$LONNAME$(:,:)
latin1 = grb_file->$LONNAME$@Latin1
latin2 = grb_file->$LONNAME$@Latin2
lov = grb_file->$LONNAME$@Lov
;
mvar = grb_file->$MSLPNAME$(:,:) * .01
;
if (fctm .eq. 0) then
  exit
end if
;
if (fctm .eq. 1) then
  zz = TPNAME
else
  zz = TPNAME + fctm + "h"
end if
tvar1 = grb_file->$zz$(:,:) * 0.03937 ; convert to inches
;
if (fctm2 .eq. 0) then
  exit
end if
;
if (fctm2 .eq. 1) then
  yy = TPNAME
else
  yy = TPNAME + fctm2 + "h"
end if
tvar2 = grb_file2->$yy$(:,:) * 0.03937 ; convert to inches
tvar = tvar1 - tvar2
;
load "$NCL_HOME/obj/get_date_str.ncl"
;
print(date_str)
print("6hp")
print(min(tvar))
print(max(tvar))
print("slp")
print(min(mvar))
print(max(mvar))
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
           "wkMetaName" : "./sfc_6hp.ncgm"
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
           "wkPSFileName" : "./sfc_6hp.ps"
          end create
        end if
      end if
    end if
;
; Assign the colormap to the workstation.
;
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
mpid = create "mapplot" mapPlotClass wid 
;
  "mpProjection" : "LambertConformal"
  "mpLambertParallel1F" : latin1
  "mpLambertParallel2F" : latin2
;
  "mpLimitMode" : "Corners"    ; Limit the map view.
  "mpLambertMeridianF" : lov
  "mpLeftCornerLonF" : LcLon
  "mpLeftCornerLatF" : LcLat
  "mpRightCornerLonF" : RcLon
  "mpRightCornerLatF" : RcLat
  "mpOutlineBoundarySets" : "AllBoundaries"
  "mpNationalLineColor" : "background"
  "mpUSStateLineColor" : "background"
  "mpUSStateLineThicknessF" : 1.25
  "mpGridAndLimbOn" : False
  "mpGeophysicalLineColor" : "background"
  "vpXF"      : vpx        ; set viewport
  "vpYF"      : vpy
  "vpWidthF"  : vpwidth 
  "vpHeightF" : vpheight
;
end create
;
if (iq .ne. 0) then
  setvalues mpid
    "mpDataBaseVersion" : "Ncarg4_1"
    "mpDataSetName" : "Earth..2"
    "mpUSStateLineThicknessF" : 1.5
  end setvalues
end if
;
; Create ScalarField objects.
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
mfield = create "ScalarField" scalarFieldClass appid
    "sfDataArray" : mvar
    "sfXCStartSubsetV" : llx
    "sfYCStartSubsetV" : lly
    "sfXCEndSubsetV" : urx
    "sfYCEndSubsetV" : ury
    "sfMissingValueV" : mvar@_FillValue
end create
;
; Create ContourPlot objects.
;
; total precip
;
load "$NCL_HOME/obj/precip_0-6_whtbkg.ncl"
;
; MSLP
;
cnid4 = create "contourplot" contourPlotClass wid
    "cnScalarFieldData":  mfield
    "cnFillOn" : False
    "cnLevelSelectionMode" : "ManualLevels"
    "cnMinLevelValF" : 900
    "cnMaxLevelValF" : 1100
    "cnLevelSpacingF" : 2
    "cnLevelFlags" : (/"LineAndLabel"/) 
    "cnInfoLabelOn" : False 
    "cnLinesOn" : True
    "cnLineColor" : 23
    "cnLineLabelsOn" : True
    "cnLineLabelInterval" : 1 
    "cnLineLabelFont" : 21
    "cnLineLabelFontHeightF" : 0.01
    "cnLineLabelFontColor" : "Background"
    "cnLineLabelBackgroundColor" : "Foreground"
    "cnLineLabelPlacementMode" : "Computed"
;    "cnLineLabelDensityF" : 0.5
    "cnLineThicknessF" : 1.0
    "pmTickMarkDisplayMode" : "NoCreate"
    "vpXF"      : vpx        ; set viewport
    "vpYF"      : vpy       
    "vpWidthF"  : vpwidth
    "vpHeightF" : vpheight
end create
;
if (iq .ne. 0) then
  setvalues cnid4
    "cnLineThicknessF" : 2.0
  end setvalues
end if
;
titlestring = fctm + "h Total Precip (in), MSLP (mb)"
load "$NCL_HOME/obj/add_titles_rr.ncl"
;
; Draw map
;
draw(cnid)
;draw(cnid4)
draw(mpid)
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
