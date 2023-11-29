;
if (domainname .eq. "fim" .or. domainname .eq. "174") then
;
  mpid = create "mapplot" mapPlotClass wid
;
    "mpProjection" : "CylindricalEquidistant"
;
    "mpLimitMode" : "Corners"    ; Limit the map view.
    "mpLeftCornerLonF" : LcLon
    "mpLeftCornerLatF" : LcLat
    "mpRightCornerLonF" : RcLon
    "mpRightCornerLatF" : RcLat
    "mpCenterLonF" : 0.
;    "mpDataBaseVersion" : "Ncarg4_1"
    "mpOutlineOn" : True
;    "mpOutlineBoundarySets" : "Geophysical"
;    "mpNationalLineColor" : "background"
;    "mpNationalLineThicknessF" : 1.5
;    "mpUSStateLineColor" : "background"
;    "mpUSStateLineThicknessF" : 1.5
;    "mpGridAndLimbOn" : False
;    "mpGeophysicalLineColor" : "background"
;    "mpGeophysicalLineThicknessF" : 1.5
    "vpXF"      : vpx        ; set viewport
    "vpYF"      : vpy
    "vpWidthF"  : vpwidth
    "vpHeightF" : vpheight
;
  end create
;
  setvalues mpid
    "mpDataBaseVersion" : "Ncarg4_1"
;    "mpDataSetName" : "Earth..2"
    "mpOutlineBoundarySets" : "AllBoundaries"
    "mpOutlineSpecifiers" : (/"United States : States","Canada : Provinces"/)
    "mpNationalLineColor" : "background"
    "mpNationalLineThicknessF" : 1.5
    "mpUSStateLineColor" : "background"
    "mpUSStateLineThicknessF" : 1.5
    "mpGeophysicalLineColor" : "background"
    "mpGeophysicalLineThicknessF" : 1.5
  end setvalues
;
  txres = True
  txres@txFont = 4
  txres@txFontColor = 0
  txres@txFontHeightF = 0.008
  labels = new(4,graphic)
  labels(0) = gsn_add_text(wid,mpid,"90W",-90,-85,txres)
  labels(1) = gsn_add_text(wid,mpid,"90E",90,-85,txres)
  labels(2) = gsn_add_text(wid,mpid,"30N",5,30,txres)
  labels(3) = gsn_add_text(wid,mpid,"30S",5,-30,txres)
;
end if
;
if (domainname .eq. "236") then
;
  LcLon = lon(0,0)
  LcLat = lat(0,0)
  RcLon = lon(ydim,xdim)
  RcLat = lat(ydim,xdim)
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
;    "mpDataBaseVersion" : "Ncarg4_1"
;    "mpDataSetName" : "Earth..2"
    "mpOutlineOn" : True
;    "mpOutlineBoundarySets" : "AllBoundaries"
;    "mpOutlineSpecifiers" : (/"United States : States","Canada : Provinces"/)
;    "mpNationalLineColor" : "background"
;    "mpNationalLineThicknessF" : 1.5
;    "mpUSStateLineColor" : "background"
;    "mpUSStateLineThicknessF" : 1.5
;    "mpGridAndLimbOn" : False
;    "mpGeophysicalLineColor" : "background"
;    "mpGeophysicalLineThicknessF" : 1.5
;    "mpGridAndLimbOn" : False
    "vpXF"      : vpx        ; set viewport
    "vpYF"      : vpy
    "vpWidthF"  : vpwidth
    "vpHeightF" : vpheight
;
  end create
;
  setvalues mpid
    "mpDataBaseVersion" : "Ncarg4_1"
;    "mpDataSetName" : "Earth..2"
    "mpOutlineBoundarySets" : "AllBoundaries"
    "mpOutlineSpecifiers" : (/"United States : States","Canada : Provinces"/)
    "mpNationalLineColor" : "background"
    "mpNationalLineThicknessF" : 1.5
    "mpUSStateLineColor" : "background"
    "mpUSStateLineThicknessF" : 1.5
    "mpGeophysicalLineColor" : "background"
    "mpGeophysicalLineThicknessF" : 1.5
  end setvalues
;
  txres = True
  txres@txFont = 4
  txres@txFontColor = 0
  txres@txFontHeightF = 0.008
  labels = new(4,graphic)
  labels(0) = gsn_add_text(wid,mpid,"75W",-75,55,txres)
  labels(1) = gsn_add_text(wid,mpid,"120W",-120,55,txres)
  labels(2) = gsn_add_text(wid,mpid,"50N",-127.5,50,txres)
  labels(3) = gsn_add_text(wid,mpid,"30N",-127.5,30,txres)
;
end if
;
if (domainname .eq. "africa") then
;
  mpid = create "mapplot" mapPlotClass wid
;
    "mpProjection" : "CylindricalEquidistant"
;
    "mpLimitMode" : "LatLon"    ; Limit the map view.
    "mpMinLatF" : -40
    "mpMaxLatF" : 40
    "mpMinLonF" : -40
    "mpMaxLonF" : 60
;    "mpDataBaseVersion" : "Ncarg4_1"
    "mpOutlineOn" : True
;    "mpOutlineBoundarySets" : "AllBoundaries"
;    "mpGridAndLimbOn" : False
;    "mpGeophysicalLineColor" : "background"
;    "mpNationalLineColor" : "background"
;    "mpGeophysicalLineThicknessF" : 1.5
    "vpXF"      : vpx        ; set viewport
    "vpYF"      : vpy
    "vpWidthF"  : vpwidth
    "vpHeightF" : vpheight
;
  end create
;
  setvalues mpid
    "mpDataBaseVersion" : "Ncarg4_1"
;    "mpDataSetName" : "Earth..2"
    "mpOutlineBoundarySets" : "AllBoundaries"
    "mpOutlineSpecifiers" : (/"United States : States","Canada : Provinces"/)
    "mpNationalLineColor" : "background"
    "mpNationalLineThicknessF" : 1.5
    "mpUSStateLineColor" : "background"
    "mpUSStateLineThicknessF" : 1.5
    "mpGeophysicalLineColor" : "background"
    "mpGeophysicalLineThicknessF" : 1.5
  end setvalues
;
  txres = True
  txres@txFont = 4
  txres@txFontColor = 0
  txres@txFontHeightF = 0.008
  labels = new(4,graphic)
  labels(0) = gsn_add_text(wid,mpid,"30W",-30,-37,txres)
  labels(1) = gsn_add_text(wid,mpid,"45E",45,-37,txres)
  labels(2) = gsn_add_text(wid,mpid,"30N",-37,30,txres)
  labels(3) = gsn_add_text(wid,mpid,"30S",-37,-30,txres)
;
end if
;
if (domainname .eq. "europe") then
;
  mpid = create "mapplot" mapPlotClass wid
;
    "mpProjection" : "CylindricalEquidistant"
;
    "mpLimitMode" : "LatLon"    ; Limit the map view.
    "mpMinLatF" : 15
    "mpMaxLatF" : 75
    "mpMinLonF" : -15
    "mpMaxLonF" : 90
;    "mpDataBaseVersion" : "Ncarg4_1"
    "mpOutlineOn" : True
;    "mpOutlineBoundarySets" : "AllBoundaries"
;    "mpUSStateLineColor" : "background"
;    "mpUSStateLineThicknessF" : 1.5
;    "mpGridAndLimbOn" : False
;    "mpGeophysicalLineColor" : "background"
;    "mpGeophysicalLineThicknessF" : 1.5
;    "mpNationalLineColor" : "background"
;    "mpNationalLineThicknessF" : 1.5
    "vpXF"      : vpx        ; set viewport
    "vpYF"      : vpy
    "vpWidthF"  : vpwidth
    "vpHeightF" : vpheight
;
  end create
;
  setvalues mpid
    "mpDataBaseVersion" : "Ncarg4_1"
;    "mpDataSetName" : "Earth..2"
    "mpOutlineBoundarySets" : "AllBoundaries"
    "mpOutlineSpecifiers" : (/"United States : States","Canada : Provinces"/)
    "mpNationalLineColor" : "background"
    "mpNationalLineThicknessF" : 1.5
    "mpUSStateLineColor" : "background"
    "mpUSStateLineThicknessF" : 1.5
    "mpGeophysicalLineColor" : "background"
    "mpGeophysicalLineThicknessF" : 1.5
  end setvalues
;
  txres = True
  txres@txFont = 4
  txres@txFontColor = 0
  txres@txFontHeightF = 0.008
  labels = new(4,graphic)
  labels(0) = gsn_add_text(wid,mpid,"45E",45,65,txres)
  labels(1) = gsn_add_text(wid,mpid,"75E",75,65,txres)
  labels(2) = gsn_add_text(wid,mpid,"60N",85,60,txres)
  labels(3) = gsn_add_text(wid,mpid,"30N",85,30,txres)
;
end if
;
if (domainname .eq. "219") then
;
  LcLon = lon(0,0)
  LcLat = lat(0,0)
  RcLon = lon(ydim,xdim)
  RcLat = lat(ydim,xdim)
;
  mpid = create "mapplot" mapPlotClass wid
;
    "mpProjection" : "Stereographic"
;
    "mpLimitMode" : "Corners"    ; Limit the map view.
    "mpCenterLatF" : 90
    "mpCenterLonF" : 280
    "mpLeftCornerLonF" : LcLon
    "mpLeftCornerLatF" : LcLat
    "mpRightCornerLonF" : RcLon
    "mpRightCornerLatF" : RcLat
;    "mpDataBaseVersion" : "Ncarg4_1"
    "mpOutlineOn" : True
;    "mpOutlineBoundarySets" : "AllBoundaries"
;    "mpOutlineSpecifiers" : (/"United States : States"/)
;    "mpUSStateLineColor" : "background"
;    "mpUSStateLineThicknessF" : 1.5
;    "mpGridAndLimbOn" : False
;    "mpGeophysicalLineColor" : "background"
;    "mpGeophysicalLineThicknessF" : 1.5
;    "mpNationalLineColor" : "background"
;    "mpNationalLineThicknessF" : 1.5
    "vpXF"      : vpx        ; set viewport
    "vpYF"      : vpy
    "vpWidthF"  : vpwidth
    "vpHeightF" : vpheight
;
  end create
;
  setvalues mpid
    "mpDataBaseVersion" : "Ncarg4_1"
;    "mpDataSetName" : "Earth..2"
    "mpOutlineBoundarySets" : "AllBoundaries"
    "mpOutlineSpecifiers" : (/"United States : States","Canada : Provinces"/)
    "mpNationalLineColor" : "background"
    "mpNationalLineThicknessF" : 1.5
    "mpUSStateLineColor" : "background"
    "mpUSStateLineThicknessF" : 1.5
    "mpGeophysicalLineColor" : "background"
    "mpGeophysicalLineThicknessF" : 1.5
  end setvalues
;
  txres = True
  txres@txFont = 4
  txres@txFontColor = 0
  txres@txFontHeightF = 0.008
  labels = new(4,graphic)
  labels(0) = gsn_add_text(wid,mpid,"60E",60,65,txres)
  labels(1) = gsn_add_text(wid,mpid,"90E",90,65,txres)
  labels(2) = gsn_add_text(wid,mpid,"60N",85,60,txres)
  labels(3) = gsn_add_text(wid,mpid,"40N",85,40,txres)
;
end if
;
if (domainname .eq. "244") then
;
  LcLon = -29.75
  LcLat = -0.205
  RcLon = 261.75
  RcLat = 50.75
;
  mpid = create "mapplot" mapPlotClass wid
;
    "mpProjection" : "CylindricalEquidistant"
;
    "mpLimitMode" : "Corners"    ; Limit the map view.
    "mpLeftCornerLonF" : LcLon
    "mpLeftCornerLatF" : LcLat
    "mpRightCornerLonF" : RcLon
    "mpRightCornerLatF" : RcLat
;    "mpDataBaseVersion" : "Ncarg4_1"
    "mpOutlineOn" : True
;    "mpOutlineBoundarySets" : "AllBoundaries"
;    "mpOutlineSpecifiers" : (/"United States : States"/)
;    "mpUSStateLineColor" : "background"
;    "mpUSStateLineThicknessF" : 1.5
;    "mpNationalLineColor" : "background"
;    "mpNationalLineThicknessF" : 1.5
;    "mpGridAndLimbOn" : False
;    "mpGeophysicalLineColor" : "background"
;    "mpGeophysicalLineThicknessF" : 1.5
    "vpXF"      : vpx        ; set viewport
    "vpYF"      : vpy
    "vpWidthF"  : vpwidth
    "vpHeightF" : vpheight
;
  end create
;
  setvalues mpid
    "mpDataBaseVersion" : "Ncarg4_1"
;    "mpDataSetName" : "Earth..2"
    "mpOutlineBoundarySets" : "AllBoundaries"
    "mpOutlineSpecifiers" : (/"United States : States","Canada : Provinces"/)
    "mpNationalLineColor" : "background"
    "mpNationalLineThicknessF" : 1.5
    "mpUSStateLineColor" : "background"
    "mpUSStateLineThicknessF" : 1.5
    "mpGeophysicalLineColor" : "background"
    "mpGeophysicalLineThicknessF" : 1.5
  end setvalues
;
  txres = True
  txres@txFont = 4
  txres@txFontColor = 0
  txres@txFontHeightF = 0.008
  labels = new(4,graphic)
  labels(0) = gsn_add_text(wid,mpid,"45W",-45,2,txres)
  labels(1) = gsn_add_text(wid,mpid,"90W",-90,2,txres)
  labels(2) = gsn_add_text(wid,mpid,"50N",-32,50,txres)
  labels(3) = gsn_add_text(wid,mpid,"20N",-32,20,txres)
;
end if
;
if (domainname .eq. "w_pacific") then
;
  LcLon = 90
  LcLat = -40
  RcLon = -120
  RcLat = 50
;
  mpid = create "mapplot" mapPlotClass wid
;
    "mpProjection" : "CylindricalEquidistant"
;
    "mpLimitMode" : "Corners"    ; Limit the map view.
    "mpLeftCornerLonF" : LcLon
    "mpLeftCornerLatF" : LcLat
    "mpRightCornerLonF" : RcLon
    "mpRightCornerLatF" : RcLat
    "mpCenterLonF" : -210
;    "mpDataBaseVersion" : "Ncarg4_1"
    "mpOutlineOn" : True
;    "mpOutlineBoundarySets" : "AllBoundaries"
;    "mpOutlineSpecifiers" : (/"United States : States"/)
;    "mpUSStateLineColor" : "background"
;    "mpUSStateLineThicknessF" : 1.5
;    "mpNationalLineColor" : "background"
;    "mpNationalLineThicknessF" : 1.5
;    "mpGridAndLimbOn" : False
;    "mpGeophysicalLineColor" : "background"
;    "mpGeophysicalLineThicknessF" : 1.5
    "vpXF"      : vpx        ; set viewport
    "vpYF"      : vpy
    "vpWidthF"  : vpwidth
    "vpHeightF" : vpheight
;
  end create
;
  setvalues mpid
    "mpDataBaseVersion" : "Ncarg4_1"
;    "mpDataSetName" : "Earth..2"
    "mpOutlineBoundarySets" : "AllBoundaries"
    "mpOutlineSpecifiers" : (/"United States : States","Canada : Provinces"/)
    "mpNationalLineColor" : "background"
    "mpNationalLineThicknessF" : 1.5
    "mpUSStateLineColor" : "background"
    "mpUSStateLineThicknessF" : 1.5
    "mpGeophysicalLineColor" : "background"
    "mpGeophysicalLineThicknessF" : 1.5
  end setvalues
;
  txres = True
  txres@txFont = 4
  txres@txFontColor = 0
  txres@txFontHeightF = 0.008
  labels = new(4,graphic)
  labels(0) = gsn_add_text(wid,mpid,"105E",105,-35,txres)
  labels(1) = gsn_add_text(wid,mpid,"135W",-135,-35,txres)
  labels(2) = gsn_add_text(wid,mpid,"40N",97,40,txres)
  labels(3) = gsn_add_text(wid,mpid,"30S",97,-30,txres)
;
end if
;
if (domainname .eq. "28") then
;
  LcLon = lon(0,0)
  LcLat = lat(0,0)
  RcLon = lon(ydim,xdim)
  RcLat = lat(ydim,xdim)
;
  mpid = create "mapplot" mapPlotClass wid
;
    "mpProjection" : "Stereographic"
;
    "mpLimitMode" : "Corners"    ; Limit the map view.
    "mpCenterLatF" : -90
    "mpCenterLonF" : 100
    "mpLeftCornerLonF" : LcLon
    "mpLeftCornerLatF" : LcLat
    "mpRightCornerLonF" : RcLon
    "mpRightCornerLatF" : RcLat
;    "mpDataBaseVersion" : "Ncarg4_1"
    "mpOutlineOn" : True
;    "mpOutlineBoundarySets" : "AllBoundaries"
;    "mpUSStateLineColor" : "background"
;    "mpUSStateLineThicknessF" : 1.5
;    "mpGridAndLimbOn" : False
;    "mpGeophysicalLineColor" : "background"
;    "mpGeophysicalLineThicknessF" : 1.5
;    "mpNationalLineColor" : "background"
;    "mpNationalLineThicknessF" : 1.5
    "vpXF"      : vpx        ; set viewport
    "vpYF"      : vpy
    "vpWidthF"  : vpwidth
    "vpHeightF" : vpheight
;
  end create
;
  setvalues mpid
    "mpDataBaseVersion" : "Ncarg4_1"
;    "mpDataSetName" : "Earth..2"
    "mpOutlineBoundarySets" : "AllBoundaries"
    "mpOutlineSpecifiers" : (/"United States : States","Canada : Provinces"/)
    "mpNationalLineColor" : "background"
    "mpNationalLineThicknessF" : 1.5
    "mpUSStateLineColor" : "background"
    "mpUSStateLineThicknessF" : 1.5
    "mpGeophysicalLineColor" : "background"
    "mpGeophysicalLineThicknessF" : 1.5
  end setvalues
;
  txres = True
  txres@txFont = 4
  txres@txFontColor = 0
  txres@txFontHeightF = 0.008
  labels = new(4,graphic)
  labels(0) = gsn_add_text(wid,mpid,"90W",-90,-5,txres)
  labels(1) = gsn_add_text(wid,mpid,"150W",-150,-5,txres)
  labels(2) = gsn_add_text(wid,mpid,"EQ",-172,0,txres)
  labels(3) = gsn_add_text(wid,mpid,"20S",-172,-20,txres)
;
end if
;
if (domainname .eq. "floating") then
;
  LcLon = lon(0)
  LcLat = lat(0)
  RcLon = lon(ydim)
  RcLat = lat(xdim)
  xc = round(xdim/2,3)
  cenLon = lon(xc)
;
  mpid = create "mapplot" mapPlotClass wid
;
    "mpProjection" : "CylindricalEquidistant"
;
    "mpLimitMode" : "Corners"    ; Limit the map view.
    "mpLeftCornerLonF" : LcLon
    "mpLeftCornerLatF" : LcLat
    "mpRightCornerLonF" : RcLon
    "mpRightCornerLatF" : RcLat
    "mpCenterLonF" : cenLon
;    "mpDataBaseVersion" : "Ncarg4_1"
    "mpOutlineOn" : True
;    "mpOutlineBoundarySets" : "AllBoundaries"
;    "mpGridAndLimbOn" : False
;    "mpGeophysicalLineColor" : "background"
;    "mpNationalLineColor" : "background"
;    "mpGeophysicalLineThicknessF" : 1.5
    "vpXF"      : vpx        ; set viewport
    "vpYF"      : vpy
    "vpWidthF"  : vpwidth
    "vpHeightF" : vpheight
;
  end create
;
  setvalues mpid
    "mpDataBaseVersion" : "Ncarg4_1"
    "mpDataSetName" : "Earth..2"
    "mpOutlineBoundarySets" : "AllBoundaries"
    "mpOutlineSpecifiers" : (/"United States : States","Canada : Provinces"/)
    "mpNationalLineColor" : "background"
    "mpNationalLineThicknessF" : 1.5
    "mpUSStateLineColor" : "background"
    "mpUSStateLineThicknessF" : 1.5
    "mpGeophysicalLineColor" : "background"
    "mpGeophysicalLineThicknessF" : 1.5
  end setvalues
;
end if
;
if (domainname .eq. "e_pacific") then
;
  LcLon = 180
  LcLat = -10
  RcLon = -60
  RcLat = 50
;
  mpid = create "mapplot" mapPlotClass wid
;
    "mpProjection" : "CylindricalEquidistant"
;
    "mpLimitMode" : "Corners"    ; Limit the map view.
    "mpLeftCornerLonF" : LcLon
    "mpLeftCornerLatF" : LcLat
    "mpRightCornerLonF" : RcLon
    "mpRightCornerLatF" : RcLat
    "mpCenterLonF" : -120
;    "mpDataBaseVersion" : "Ncarg4_1"
    "mpOutlineOn" : True
;    "mpOutlineBoundarySets" : "AllBoundaries"
;    "mpOutlineSpecifiers" : (/"United States : States"/)
;    "mpUSStateLineColor" : "background"
;    "mpUSStateLineThicknessF" : 1.5
;    "mpNationalLineColor" : "background"
;    "mpNationalLineThicknessF" : 1.5
;    "mpGridAndLimbOn" : False
;    "mpGeophysicalLineColor" : "background"
;    "mpGeophysicalLineThicknessF" : 1.5
    "vpXF"      : vpx        ; set viewport
    "vpYF"      : vpy
    "vpWidthF"  : vpwidth
    "vpHeightF" : vpheight
;
  end create
;
  setvalues mpid
    "mpDataBaseVersion" : "Ncarg4_1"
;    "mpDataSetName" : "Earth..2"
    "mpOutlineBoundarySets" : "AllBoundaries"
    "mpOutlineSpecifiers" : (/"United States : States","Canada : Provinces"/)
    "mpNationalLineColor" : "background"
    "mpNationalLineThicknessF" : 1.5
    "mpUSStateLineColor" : "background"
    "mpUSStateLineThicknessF" : 1.5
    "mpGeophysicalLineColor" : "background"
    "mpGeophysicalLineThicknessF" : 1.5
  end setvalues
;
  txres = True
  txres@txFont = 4
  txres@txFontColor = 0
  txres@txFontHeightF = 0.008
  labels = new(4,graphic)
  labels(0) = gsn_add_text(wid,mpid,"75W",-75,-5,txres)
  labels(1) = gsn_add_text(wid,mpid,"165W",-165,-5,txres)
  labels(2) = gsn_add_text(wid,mpid,"40N",-175,40,txres)
  labels(3) = gsn_add_text(wid,mpid,"EQ",-175,0,txres)
;
end if
;
if (domainname .eq. "fim" .or. domainname .eq. "173") then
  setvalues mpid
    "mpGridAndLimbOn" : True
    "mpGridLatSpacingF" : 15
    "mpGridLonSpacingF" : 30
    "mpLabelsOn" : True
    "mpLabelFontColor" : 0
    "mpGridLineColor" : 0
  end setvalues
else
  setvalues mpid
    "mpGridAndLimbOn" : True
    "mpGridLatSpacingF" : 10
    "mpGridLonSpacingF" : 15
    "mpLabelsOn" : True
    "mpLabelFontColor" : 0
    "mpGridLineColor" : 0
  end setvalues
end if

