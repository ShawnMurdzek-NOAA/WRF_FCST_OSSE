mpid = create "mapplot" mapPlotClass wid
;
  "mpProjection" : "LambertConformal"
  "mpLambertParallel1F" : latin1
  "mpLambertParallel2F" : latin2
  "mpLimitMode" : "Corners"    ; Limit the map view.
  "mpLambertMeridianF" : lov
  "mpLeftCornerLonF" : LcLon
  "mpLeftCornerLatF" : LcLat
  "mpRightCornerLonF" : RcLon
  "mpRightCornerLatF" : RcLat
;  "mpOutlineBoundarySets" : "AllBoundaries"
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
if (iq .ne. 0) then
  setvalues mpid
    "mpDataBaseVersion" : "Ncarg4_1"
    "mpDataSetName" : "Earth..2"
    "mpOutlineBoundarySets" : "AllBoundaries"
    "mpNationalLineColor" : "foreground"
    "mpGeophysicalLineColor" : "background"
    "mpGeophysicalLineThicknessF" : 2
    "mpUSStateLineColor" : "background"
    "mpUSStateLineThicknessF" : 2
    "mpGridAndLimbOn" : False
  end setvalues
else
  setvalues mpid
    "mpOutlineBoundarySets" : "AllBoundaries"
    "mpNationalLineColor" : "foreground"
    "mpGeophysicalLineColor" : "background"
    "mpGeophysicalLineThicknessF" : 2
    "mpUSStateLineColor" : "background"
    "mpUSStateLineThicknessF" : 2
    "mpGridAndLimbOn" : False
  end setvalues
end if

