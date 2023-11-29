mpid = create "mapplot" mapPlotClass wid
;
  "mpProjection" : "CylindricalEquidistant"
  "mpCenterLatF" : center_lat
  "mpCenterLonF" : center_lon
;
  "mpLimitMode" : "Corners"    ; Limit the map view.
  "mpLeftCornerLonF" : LcLon
  "mpLeftCornerLatF" : LcLat
  "mpRightCornerLonF" : RcLon
  "mpRightCornerLatF" : RcLat
  "mpDataBaseVersion" : "Ncarg4_1"
  "mpDataSetName" : "Earth..2"
  "mpOutlineBoundarySets" : "GeophysicalAndUSStates"
  "mpOutlineSpecifiers" : (/"Canada : Provinces"/)
  "mpNationalLineColor" : "foreground"
  "mpUSStateLineColor" : "foreground"
  "mpUSStateLineThicknessF" : 1.25
  "mpGridAndLimbOn" : False
  "mpGeophysicalLineColor" : "foreground"
  "vpXF"      : vpx        ; set viewport
  "vpYF"      : vpy
  "vpWidthF"  : vpwidth
  "vpHeightF" : vpheight
;
end create

