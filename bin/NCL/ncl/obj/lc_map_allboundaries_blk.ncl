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
  "mpDataBaseVersion" : "Ncarg4_1"
  "mpDataSetName" : "Earth..4"
;  "mpDataResolution" : "FinestResolution"
  "mpOutlineBoundarySets" : "AllBoundaries"
  "mpNationalLineColor" : "background"
  "mpNationalLineThicknessF" : 2
  "mpGeophysicalLineColor" : "background"
  "mpGeophysicalLineThicknessF" : 2
  "mpGridAndLimbOn" : False
  "vpXF"      : vpx        ; set viewport
  "vpYF"      : vpy
  "vpWidthF"  : vpwidth
  "vpHeightF" : vpheight
;
end create

