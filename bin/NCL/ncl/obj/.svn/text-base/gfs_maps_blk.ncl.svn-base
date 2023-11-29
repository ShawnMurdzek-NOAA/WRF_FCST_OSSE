mpid = create "mapplot" mapPlotClass wid
;
  "mpProjection" : "CylindricalEquidistant"
;
  "mpLimitMode" : "MaximalArea"    ; Limit the map view.
  "mpCenterLonF" : 180.
  "mpDataBaseVersion" : "Ncarg4_1"
  "mpOutlineBoundarySets" : "Geophysical"
  "mpNationalLineColor" : "background"
  "mpNationalLineThicknessF" : 1.5
  "mpGridAndLimbOn" : False
  "mpGeophysicalLineColor" : "background"
  "mpGeophysicalLineThicknessF" : 1.5
  "vpXF"      : vpx        ; set viewport
  "vpYF"      : vpy
  "vpWidthF"  : vpwidth
  "vpHeightF" : vpheight
;
end create
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
setvalues mpid
  "mpGridAndLimbOn" : True
  "mpGridLatSpacingF" : 15
  "mpGridLonSpacingF" : 30
  "mpLabelsOn" : True
  "mpLabelFontColor" : 0
  "mpGridLineColor" : 0
end setvalues
;
