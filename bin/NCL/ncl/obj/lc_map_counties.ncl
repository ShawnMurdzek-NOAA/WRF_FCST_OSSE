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
;  "mpDataBaseVersion" : "Ncarg4_1"
;  "mpDataSetName" : "Earth..2"
;  "mpOutlineBoundarySets" : "AllBoundaries"
;  "mpNationalLineColor" : "background"
;  "mpUSStateLineColor" : "background"
;  "mpUSStateLineThicknessF" : 1.5
;  "mpGeophysicalLineThicknessF" : 1.5
;  "mpGridAndLimbOn" : False
;  "mpGeophysicalLineColor" : "background"
  "mpPerimOn" : True
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
;  "mpOutlineSpecifiers" : (/"United States : States","Canada : Provinces"/)
  "mpNationalLineColor" : "background"
  "mpNationalLineThicknessF" : 1.0
  "mpUSStateLineColor" : "background"
  "mpUSStateLineThicknessF" : 2.0
  "mpGeophysicalLineColor" : "background"
  "mpGeophysicalLineThicknessF" : 2.0
  "mpGridAndLimbOn" : False
end setvalues

