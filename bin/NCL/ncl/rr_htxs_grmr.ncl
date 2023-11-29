load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "WRFUserARW.ncl"
modl = getenv("MODEL") + " "
if (modl .eq. "WRF-RR ") then
  modl = "RR-primary "
end if
if (modl .eq. "WRF-RR ARW ") then
  modl = "RR-devel "
end if
if (modl .eq. "RR ") then
  modl = "RR-cold-start "
end if
;
load "$NCL_HOME/obj/cmap1_cref_merged.ncl"
;
begin
;
fname = asciiread("arw_file.txt",-1,"string")
grb_file = addfile(fname,"r")
;
parms = asciiread("parms_file.txt",-1,"float")  ; read lat,lon of x-section end points
start_lat = parms(0)
start_lon = parms(1)
end_lat = parms(2)
end_lon = parms(3)
htfrac = parms(4)
;
intm = grb_file->T_GDS3_HTGL@initial_time
fctm = grb_file->T_GDS3_HTGL@forecast_time
lat = grb_file->g3_lat_0(:,:)
lon = grb_file->g3_lon_1(:,:)
latin1 = grb_file->g3_lon_1@Latin1
latin2 = grb_file->g3_lon_1@Latin2
lov = grb_file->g3_lon_1@Lov
;
hr3sizes = filevardimsizes(grb_file,"g3_lat_0")
planny = hr3sizes(0)
plannx = hr3sizes(1)
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
           "wkMetaName" : "./htxs_grmr.ncgm"
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
           "wkPSFileName" : "./htxs_grmr.ps"
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
; Increase workspace memory
setvalues NhlGetWorkspaceObjectId()
   "wsMaximumSize": 247108864
end setvalues
;
hvar = grb_file->GH_GDS3_SIGL(:,:,:) / 1000 ; convert to km
;sfchvar = grb_file->GH_GDS3_SFC(:,:) / 1000 ; convert to km
grmr = grb_file->GRMR_GDS3_SIGL(:,:,:) * 1000. ; convert to g/kg
rwmr = grb_file->RWMR_GDS3_SIGL(:,:,:)
pvar = grb_file->P_GDS3_SIGL(:,:,:) / 100. ; convert to mb
shvar = grb_file->SH_GDS3_SIGL(:,:,:)
mrvar = shvar / (1. - shvar)
tempvar = grb_file->T_GDS3_SIGL(:,:,:)
vtvar = tempvar * (1 + (0.61 * mrvar) - rwmr)
vptvar = vtvar * ((1000. / pvar) ^ 0.2854)
print("Graupel Mixing Ratio")
tvar = grmr
print(min(tvar))
print(max(tvar))
;
s1d = grb_file->lv_SIGL2(:) * 1.0
hgt = conform(tvar, s1d, 0)
;
startpts = wrf_latlon_to_ij(lat, lon, start_lat, start_lon)
endpts = wrf_latlon_to_ij(lat, lon, end_lat, end_lon)
planepts = (/ startpts(1), startpts(0), endpts(1), endpts(0) /) * 1.0
;
plane = wrf_user_intrp3d(tvar, hvar, "v", planepts, 0.0, True)
if (max(plane) .eq. min(plane)) then
  plane(0,0) = 0.2
end if
vptplane = wrf_user_intrp3d(vptvar, hvar, "v", planepts, 0.0, True)
planehts = wrf_user_intrp3d(hvar, hvar, "v", planepts, 0.0, True)
planepres = wrf_user_intrp3d(pvar, hvar, "v", planepts, 0.0, True)
dims = dimsizes(plane)
distance = gc_latlon(lat(startpts(0), startpts(1)), lon(startpts(0),startpts(1)), \
                     lat(endpts(0), endpts(1)), lon(endpts(0), endpts(1)), 0, 4)
if ( distance/10 .gt. 10 ) then
  numlabels = 11
  distlabels = fspan(0, distance, numlabels)
  distlabels = round(distlabels,3)
else
  numlabels = 2
  distlabels = fspan(0, distance, numlabels)
  distlabels = (/ 0,distance /)
end if
;
nx = dims(1)
ny = dims(0)
nx2 = nx
ny2 = ny
do ii = 1,20
  if (nx2 .gt. ny2) then
    ny2 = ny2 + ny
  end if
  if (ny2 .gt. nx2) then
    nx2 = nx2 + nx
  end if
  aspect = (ny2 * 1.0)/(nx2 * 1.0)
  diffaspect = abs(1.0 - aspect)
  if (ii .eq. 1) then
    prevdiffaspect = diffaspect
    holdnx2 = nx2
    holdny2 = ny2
  else
    if (diffaspect .lt. prevdiffaspect) then
      prevdiffaspect = diffaspect
      holdnx2 = nx2
      holdny2 = ny2
    end if
  end if
end do
nx2 = holdnx2
ny2 = holdny2
;
xdim = nx2 - 1
ydim = ny2 - 1
rnx = 1.*xdim
rny = 1.*ydim
if (rny .ge. rnx) then
  vpheight = .8
  vpy = 1.-((1.-vpheight)/2.)
  vpwidth = (vpheight/rny)*rnx
  vpx = (1.-((vpheight/rny)*rnx))/2.
else
  vpwidth = .8
  vpx = (1.-vpwidth)/2.
  vpheight = (vpwidth/rnx)*rny
  vpy = 1.-((1.-((vpwidth/rnx)*rny))/2.)
end if
;
; Create ScalarField objects.
;
midpt = (ny - 1) * htfrac
tfield = create "ScalarField" scalarFieldClass appid
    "sfDataArray" : plane
    "sfYCStartSubsetV" : 0
    "sfYCEndSubsetV" : midpt
    "sfMissingValueV" : plane@_FillValue
end create
vptfield = create "ScalarField" scalarFieldClass appid
    "sfDataArray" : vptplane
    "sfYCStartSubsetV" : 0
    "sfYCEndSubsetV" : midpt
    "sfMissingValueV" : vptplane@_FillValue
end create
;
; Create ContourPlot objects.
;
load "$NCL_HOME/obj/precip_0-2_whtbkg.ncl"
;
setvalues cnid
  "cnFillMode" : "AreaFill"
  "lbTopMarginF" : 0.35
  "lbAutoManage" : False
  "lbLabelFontHeightF" : 0.015
  "tiYAxisString" : "Height (km)"
  "tiYAxisFontHeightF" : 0.012
  "tiYAxisOffsetXF" : -0.022
  "tiXAxisString" : "Distance (km)"
  "tiXAxisFontHeightF" : 0.012
  "tiXAxisOffsetYF" : -0.01
end setvalues
;
cnid2 = create "contourplot" contourPlotClass wid
    "cnScalarFieldData":  vptfield
    "cnLevelSelectionMode" : "ManualLevels"
    "cnMinLevelValF" : 260
    "cnMaxLevelValF" : 900
    "cnLevelSpacingF" : 4
    "cnLinesOn" : True
    "cnMonoLineColor" : True
    "cnLineColor" : 0
    "cnLineThicknessF" : 1.25
    "cnLineLabelsOn" : True
    "cnLineLabelFontHeightF" : 0.0125
    "cnLineLabelFontThicknessF" : 2.0
    "cnLineLabelPlacementMode" : "Computed"
    "cnLineLabelDensityF" : 0.5
    "cnInfoLabelOn" : False
    "cnLineLabelInterval" : 1
    "cnLineLabelFont" : 21
    "cnLineLabelFontColor" : "Background"
    "cnLineLabelBackgroundColor" : -1
    "pmTickMarkDisplayMode" : "NoCreate"
    "cnFillOn" : False
    "cnGridBoundPerimOn" : False
    "vpXF"      : vpx        ; set viewport
    "vpYF"      : vpy
    "vpWidthF"  : vpwidth
    "vpHeightF" : vpheight
end create
;
mxplnht = max(planehts) * htfrac
mxplnhtm = mxplnht * 1000.
;
; Read in the stdatm.txt file to get relevant pressure to mxplnht
;
stdatmvars = asciiread("stdatm.txt",(/40001,6/),"float")
do findpres = 0,39999
  if (mxplnhtm.ge.stdatmvars(findpres,0) .and. mxplnhtm.lt.stdatmvars(findpres+1,0)) then
    mnplnpres = stdatmvars(findpres,2)
  end if
end do
;
toppres = round(mnplnpres,3)
prlevs = (/ 0.11, 1.457, 3.013, 5.579, 7.193, 9.177, \
            10.379, 11.806, 13.637, 16.221, 20.643, mxplnht /)
prlevslabs = (/ 1000,850,700,500,400, \
                300,250,200,150,100,50,toppres /)
;
tmid = create "TickMarks" tickMarkClass wid
  "tmBorderLineColor" : 20
  "tmXBDataLeftF" : 0
  "tmXBDataRightF" : distance
  "tmXBMode" : "Explicit"
  "tmXBValues" : distlabels
  "tmXBLabels" : distlabels
  "tmXBLabelFontHeightF" : 0.012
  "tmXBLabelDeltaF" : -0.5
  "tmXBMinorLengthF" : 0.01
  "tmXBMinorLineColor" : 20
  "tmXBMajorLengthF" : 0.01
  "tmXBMajorLineColor" : 20
  "tmYLDataBottomF" : 0
  "tmYLDataTopF" : mxplnht
  "tmYLMode" : "Manual"
  "tmYLTickSpacingF" : 5
  "tmYLLabelFontHeightF" : 0.012
  "tmYLLabelDeltaF" : -0.5
  "tmYLMinorLengthF" : 0.01
  "tmYLMinorLineColor" : 20
  "tmYLMinorPerMajor" : 4
  "tmYLMajorLengthF" : 0.01
  "tmYLMajorLineColor" : 20
  "tmYUseLeft" : False
  "tmYROn" : True
  "tmYRLabelsOn" : True
  "tmYRDataBottomF" : 0
  "tmYRDataTopF" : mxplnht
  "tmYRMode" : "Explicit"
  "tmYRValues" : prlevs
  "tmYRLabels" : prlevslabs
  "tmYRLabelFontHeightF" : 0.012
  "tmYRLabelDeltaF" : 0.5
  "tmYRMajorLengthF" : 0.01
  "tmYRMajorLineColor" : 20
  "vpXF"      : vpx        ; set viewport
  "vpYF"      : vpy
  "vpWidthF"  : vpwidth
  "vpHeightF" : vpheight
end create
;
titleid = create "TextItems" textItemClass wid
  "txFuncCode" : "~"
  "txString" : "Graupel Mixing Ratio (g/kg) X-sect from "+start_lat+","+start_lon+ \
               " to "+end_lat+","+end_lon
  "txFont" : 22
  "txFontHeightF" : 0.02
  "txFontColor" : 1
end create
;
txid = create "TextItems" textItemClass wid
  "txFuncCode" : "~"
  "txString" : modl+intm+" "+fctm+" hr fcst"
  "txFont" : 22
  "txFontHeightF" : 0.015
  "txFontColor" : 1
end create
;
txid2 = create "TextItems" textItemClass wid
  "txFuncCode" : "~"
  "txString" : date_str
  "txFont" : 22
  "txFontHeightF" : 0.015
  "txFontColor" : 1
end create
;
txid3 = create "TextItems" textItemClass wid
  "txFuncCode" : "~"
  "txAngleF" : 270.0
  "txString" : "Pressure (mb, from Std. Atm.)"
  "txFont" : 21
  "txFontHeightF" : 0.0125
  "txFontColor" : 1
end create
;
txid4 = create "TextItems" textItemClass wid
  "txFuncCode" : "~"
  "txString" : start_lat+","+start_lon
  "txFont" : 22
  "txFontHeightF" : 0.015
  "txFontColor" : 1
end create
;
txid5 = create "TextItems" textItemClass wid
  "txFuncCode" : "~"
  "txString" : end_lat+","+end_lon
  "txFont" : 22
  "txFontHeightF" : 0.015
  "txFontColor" : 1
end create
;
iannotitle = NhlAddAnnotation(cnid,titleid)
setvalues iannotitle
  "amZone":           10
  "amSide":           "top"
  "amJust":           "bottomright"
  "amParallelPosF":    1.0
  "amOrthogonalPosF":  0.0
end setvalues
;
if (vpheight .ge. vpwidth) then
  opos = 0.032
else
  opos = 0.1 - ((vpheight/vpwidth)*0.07)
end if
;
ianno = NhlAddAnnotation(cnid,txid)
setvalues ianno
  "amZone":           10
  "amSide":           "top"
  "amJust":           "bottomleft"
  "amParallelPosF":    0.0
  "amOrthogonalPosF":  opos
end setvalues
;
ianno2 = NhlAddAnnotation(cnid,txid2)
setvalues ianno2
  "amZone":           10
  "amSide":           "top"
  "amJust":           "bottomright"
  "amParallelPosF":    1.0
  "amOrthogonalPosF":  opos + 0.005
end setvalues
;
ianno3 = NhlAddAnnotation(cnid,txid3)
setvalues ianno3
  "amZone":           10
  "amSide":           "right"
  "amJust":           "centerleft"
  "amParallelPosF":    0.5
;  "amOrthogonalPosF":  opos + 0.005
end setvalues
;
ianno4 = NhlAddAnnotation(cnid,txid4)
setvalues ianno4
  "amZone":           10
  "amSide":           "bottom"
  "amJust":           "topleft"
  "amParallelPosF":    0.0 - (opos * 2)
  "amOrthogonalPosF":  -(opos * 2.5)
end setvalues
;
ianno5 = NhlAddAnnotation(cnid,txid5)
setvalues ianno5
  "amZone":           10
  "amSide":           "bottom"
  "amJust":           "topright"
  "amParallelPosF":    1.0 + (opos * 2)
  "amOrthogonalPosF":  -(opos * 2.5)
end setvalues
;
; Draw cross section
;
draw(cnid)
draw(cnid2)
draw(tmid)
;
; Plot the transect line in plan view (picture-in-picture)
;
newvpx = vpx + (vpwidth - (vpwidth * .2))
newvpy = vpy
newvpwidth = vpwidth * .2
newvpheight = vpheight * .2
;
cref = grb_file->REFC_GDS3_EATM(:,:)
;
xdim = plannx - 1
ydim = planny - 1
;
; find the approximate center point of the cross section
;
midlat = (lat(startpts(0),startpts(1)) + lat(endpts(0),endpts(1))) / 2.
midlon = (lon(startpts(0),startpts(1)) + lon(endpts(0),endpts(1))) / 2.
;
; RR grid spacing is 13km, so use that to determine how many pts in x and y
; (the actual grid spacing is 13.545 but using 12 provides a little margin
; so that the line endpoints can be seen)
;
  res = True
  res@MAP_PROJ  = 1
  res@TRUELAT1  = grb_file->g3_lat_0@Latin1
  res@TRUELAT2  = grb_file->g3_lat_0@Latin2
  res@STAND_LON = grb_file->g3_lat_0@Lov
  res@DX        = grb_file->g3_lat_0@Dx
  res@DY        = grb_file->g3_lat_0@Dy
  res@POLE_LAT = 90.0
  res@POLE_LON =  0.0
  res@LATINC = 0.0
  res@LONINC = 0.0
  res@REF_LON = lon(0,0)
  res@REF_LAT = lat(0,0)
  res@KNOWNI = 0
  res@KNOWNJ = 0
;
; Use the grid spacing to determine how many pts in x and y
; (subtracting 1 provides a little margin so that the line 
; endpoints can be seen)
;
  gdist = distance / floattointeger(res@DX / 1000.) - 1
;
  centerpt = wrf_latlon_to_ij(lat, lon, midlat, midlon)
  llx = floattointeger(centerpt(1) - (gdist/2))
  lly = floattointeger(centerpt(0) - (gdist/2))
  urx = floattointeger(centerpt(1) + (gdist/2))
  ury = floattointeger(centerpt(0) + (gdist/2))
  Lc = wrf_ij_to_ll(llx, lly, res)
  Rc = wrf_ij_to_ll(urx, ury, res)
  LcLon = Lc(0)
  LcLat = Lc(1)
  RcLon = Rc(0)
  RcLat = Rc(1)
  crefsub = cref(lly:ury,llx:urx)
  if (max(crefsub) .eq. min(crefsub)) then
    cref(lly,llx) = 0.  ; set the corner pt to avoid constant field plot
  end if
;
creffield = create "ScalarField" scalarFieldClass appid
    "sfDataArray" : cref
    "sfXCStartSubsetV" : llx
    "sfYCStartSubsetV" : lly
    "sfXCEndSubsetV" : urx
    "sfYCEndSubsetV" : ury
    "sfMissingValueV" : cref@_FillValue
end create
;
cnid3 = create "contourplot" contourPlotClass wid
    "cnScalarFieldData":  creffield
    "cnLevelSelectionMode" : "ExplicitLevels"
    "cnLevels" : (/ 0.,5.,10.,15.,20.,25.,30.,35.,40.,45.,50.,55.,60.,65.,70.,75. /)
    "cnFillColors" : (/21,21,25,24,23,41,27,28,29,42,30,31,40,39,36,35,21/)    ; greg's
    "cnFillOn" : True
    "cnFillMode" : "RasterFill"
    "cnLinesOn" : False
    "cnLineLabelsOn" : False
    "cnInfoLabelOn" : False
    "pmTickMarkDisplayMode" : "NoCreate"
    "pmLabelBarDisplayMode" : "NEVER"
    "pmLabelBarHeightF" : .05
    "pmLabelBarWidthF" : 0.9
    "pmLabelBarSide" : "bottom"
    "pmLabelBarOrthogonalPosF" : 0.0
    "lbOrientation" : "horizontal"
    "lbTitleFont" : 22
    "lbPerimOn" : False
    "lbBoxLinesOn" : True
    "vpXF"      : newvpx        ; set viewport
    "vpYF"      : newvpy
    "vpWidthF"  : newvpwidth
    "vpHeightF" : newvpheight
end create
;
draw(cnid3)
;
mpid2 = create "mapplot" mapPlotClass wid
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
  "mpDataBaseVersion" : "Ncarg4_1"
  "mpDataSetName" : "Earth..2"
;  "mpDataSetName" : "Earth..4"
  "mpOutlineBoundarySets" : "GeophysicalAndUSStates"
  "mpOutlineSpecifiers" : (/"Canada : Provinces"/)
  "mpNationalLineColor" : 10
  "mpUSStateLineColor" : 10
  "mpUSStateLineThicknessF" : 1.25
  "mpGridAndLimbOn" : False
  "mpGeophysicalLineColor" : 10
  "mpPerimOn" : True
  "mpPerimLineColor" : 10
  "vpXF"      : newvpx        ; set viewport
  "vpYF"      : newvpy
  "vpWidthF"  : newvpwidth
  "vpHeightF" : newvpheight
;
end create
;
if (distance .lt. 500.) then
  setvalues mpid2
    "mpOutlineBoundarySets" : "AllBoundaries"
    "mpUSStateLineThicknessF" : 2
  end setvalues
end if
;
draw(mpid2)
;
gsres = True
gsres@gsLineColor = 19
gsres@gsLineThicknessF = 2
lons = new(2,float)
lats = new(2,float)
lons(0) = lon(startpts(0),startpts(1))
lons(1) = lon(endpts(0),endpts(1))
lats(0) = lat(startpts(0),startpts(1))
lats(1) = lat(endpts(0),endpts(1))
gsn_polyline(wid,mpid2,lons,lats,gsres)
;
frame(wid)
;
end
;
