load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl";
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
mvar = grb_file->$MSLPNAME$(:,:) * .01
h5 = grb_file->$GHNAME$(18,:,:)
h10 = grb_file->$GHNAME$(38,:,:)
thick = (h5 - h10) / 10
;
if ( fctm .gt. 0 ) then
  if ( fctm .eq. 1 ) then
    zz = WEASD1HNAME
  else
    zz = WEASD1HNAME + fctm + "h"
  end if
  tvar = grb_file->$zz$(:,:)
else
  exit
end if
;
check = ""
check = systemfunc("ls back1_hour.txt")
fnameback1test = 0
if (.not.ismissing(check.eq."back1_hour.txt")) then
  fnameback1 = asciiread("back1_hour.txt",-1,"string")
  back1exists = isfilepresent(fnameback1)
  if (back1exists) then
    print("reading "+fnameback1)
    fnameback1test = 1
    grb_file_back1 = addfile(fnameback1,"r")
  else
    print("error - missing file "+fnameback1)
    exit
  end if
else
  print("error - missing back1_hour.txt")
  exit
end if
;
fctm2 = grb_file_back1->$T2MNAME$@forecast_time
tvar2 = tvar * 0.
if ( fctm2 .ge. 1 ) then
  if ( fctm2 .eq. 1 ) then
    zz2 = WEASD1HNAME
  else
    zz2 = WEASD1HNAME + fctm2 + "h"
    tvar2 = grb_file_back1->$zz2$(:,:)
  end if
end if
;
tvar = tvar - tvar2
;
tvar = tvar * 0.03937; convert to inches
tvar = tvar * 10.0 ; water to snow depth
;
if (fctm .gt. 0)
  j = 1
else
  j = 0
end if
;
load "$NCL_HOME/obj/get_date_str.ncl"
;
print(date_str)
print("hourly snowfall")
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
           "wkMetaName" : "./sfc_1hsnw.ncgm"
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
           "wkPSFileName" : "./sfc_1hsnw.ps"
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
if (min(tvar(lly:ury,llx:urx)) .eq. max(tvar(lly:ury,llx:urx))) then
  tvar(lly,llx) = .04
end if
;
if (max(tvar(lly:ury,llx:urx)) .lt. 0.03) then
  tvar(lly,llx) = .04
end if
;
load "$NCL_HOME/obj/hrrr_map_blk_counties_blk.ncl"
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
zfield = create "ScalarField" scalarFieldClass appid
    "sfDataArray" : thick
    "sfXCStartSubsetV" : llx
    "sfYCStartSubsetV" : lly
    "sfXCEndSubsetV" : urx
    "sfYCEndSubsetV" : ury
    "sfMissingValueV" : thick@_FillValue
end create
;
; Create ContourPlot objects.
;
load "$NCL_HOME/obj/weasd_hrrr.ncl"
;
if (iq .ge. 8) then
  setvalues cnid
    "cnFillMode" : "AreaFill"
  end setvalues
end if
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
; Thickness
;
cnid5 = create "contourplot" contourPlotClass wid
    "cnScalarFieldData":  zfield
    "cnFillOn" : False
    "cnLevelSelectionMode" : "ManualLevels"
    "cnMinLevelValF" : 402
    "cnMaxLevelValF" : 600
    "cnLevelSpacingF" : 6
    "cnLevelFlags" : (/"LineAndLabel"/) 
    "cnInfoLabelOn" : False 
    "cnLinesOn" : True
    "cnLineColor" : 2
    "cnLineDashPattern" : 5
    "cnLineLabelsOn" : True
    "cnLineLabelInterval" : 1
    "cnLineLabelFont" : 21
    "cnLineLabelFontHeightF" : 0.01
    "cnLineLabelFontColor" : "Foreground"
    "cnLineLabelBackgroundColor" : "Background"
    "cnLineLabelPlacementMode" : "Computed"
    "cnLineLabelDensityF" : 0.5
    "cnLineThicknessF" : 1.0
    "pmTickMarkDisplayMode" : "NoCreate"
    "vpXF"      : vpx        ; set viewport
    "vpYF"      : vpy       
    "vpWidthF"  : vpwidth
    "vpHeightF" : vpheight
end create
;
if (iq .ne. 0) then
  setvalues cnid5
    "cnLineThicknessF" : 2.0
  end setvalues
end if
;
if (modl .eq. "HRRR-NCEP ") then
  titlestring = "1hr Accumulated Snow/Sleet Using 10:1 Ratio (in)"
else
  titlestring = "1hr Accumulated Snow Using 10:1 Ratio (in)"
end if
load "$NCL_HOME/obj/add_titles_rr.ncl"
;
; Draw map
;
draw(cnid)
;draw(cnid4)
;draw(cnid5)
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

