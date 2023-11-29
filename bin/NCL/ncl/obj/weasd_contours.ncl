cnid4 = create "contourplot" contourPlotClass wid
    "cnScalarFieldData":  tempfield
    "cnLevelSelectionMode" : "ExplicitLevels"
    "cnLevels" : (/ .1,.25,.5,1,2,3,4,5,7.5,10,20 /)
    "cnFillOn" : False
    "cnInfoLabelOn" : False
    "cnLinesOn" : True
    "cnMonoLineColor" : True
    "cnLineColor" : 0
    "cnLineLabelsOn" : True
    "cnLineLabelInterval" : 1
    "cnLineLabelFont" : 21
    "cnLineLabelFontHeightF" : 0.01
    "cnLineLabelFontColor" : "Foreground"
    "cnLineLabelBackgroundColor" : "Background"
    "cnLineLabelPlacementMode" : "Computed"
    "pmTickMarkDisplayMode" : "NoCreate"
    "pmLabelBarDisplayMode" : "NEVER"
    "vpXF"      : vpx        ; set viewport
    "vpYF"      : vpy       
    "vpWidthF"  : vpwidth
    "vpHeightF" : vpheight
end create
