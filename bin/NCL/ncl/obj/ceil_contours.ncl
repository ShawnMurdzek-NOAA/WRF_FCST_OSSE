cnid4 = create "contourplot" contourPlotClass wid
    "cnScalarFieldData":  tempfield
    "cnLevelSelectionMode" : "ExplicitLevels"
    "cnLevels" : (/ 0,0.1,0.3,0.5,1,2,3,5,10,15,20,30 /)
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
