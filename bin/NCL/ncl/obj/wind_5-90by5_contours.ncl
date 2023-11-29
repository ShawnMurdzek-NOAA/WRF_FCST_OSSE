;
cnid4 = create "contourplot" contourPlotClass wid
  "cnScalarFieldData":  tempfield
  "cnLevelSelectionMode" : "ExplicitLevels"
  "cnLevels" : (/ 5,10,15,20,25,30,35,40,45,50,55,60,65,70,75,80,85,90 /)
  "cnFillOn" : False
  "cnLinesOn" : True
  "cnMonoLineColor" : True
  "cnLineColor" : 0
  "cnLineLabelsOn" : True
  "cnLineLabelPlacementMode" : "Computed"
  "cnLineLabelInterval" : 1
  "cnLineLabelFont" : 21
  "cnLineLabelFontHeightF" : 0.01
  "cnLineLabelFontColor" : "Foreground"
  "cnLineLabelBackgroundColor" : "Background"
  "cnInfoLabelOn" : False
  "pmTickMarkDisplayMode" : "NoCreate"
  "pmLabelBarDisplayMode" : "NEVER"
  "vpXF"      : vpx        ; set viewport
  "vpYF"      : vpy
  "vpWidthF"  : vpwidth
  "vpHeightF" : vpheight
end create
