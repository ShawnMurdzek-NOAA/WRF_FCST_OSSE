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
;  "mpDataBaseVersion" : "Ncarg4_1"
;  "mpDataSetName" : "Earth..2"
;  "mpOutlineBoundarySets" : "GeophysicalAndUSStates"
;  "mpOutlineSpecifiers" : (/"Canada : Provinces"/)
;  "mpNationalLineColor" : "background"
;  "mpUSStateLineColor" : "background"
;  "mpUSStateLineThicknessF" : 1.25
;  "mpGridAndLimbOn" : False
;  "mpGeophysicalLineColor" : "background"
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
;  "mpOutlineBoundarySets" : "GeophysicalAndUSStates"
  "mpOutlineSpecifiers" : (/"United States : States","Canada : Provinces"/)
  "mpNationalLineColor" : "background"
  "mpNationalLineThicknessF" : 1.5
  "mpUSStateLineColor" : "background"
  "mpUSStateLineThicknessF" : 1.5
  "mpGeophysicalLineColor" : "background"
  "mpGeophysicalLineThicknessF" : 1.5
  "mpGridAndLimbOn" : False
end setvalues


