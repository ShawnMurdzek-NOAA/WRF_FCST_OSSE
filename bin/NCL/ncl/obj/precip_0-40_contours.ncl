cnid4 = create "contourplot" contourPlotClass wid
    "cnScalarFieldData":  tempfield
;    "cnLevels" : (/0.10, 0.25, 0.5, 1, 2, 3, 5, 10, 20, 40/)
    "cnLevels" : (/ 0.5, 1, 2, 5, 10, 20 /)
    "cnLevelSelectionMode" : "ExplicitLevels"
    "cnFillOn" : False
    "cnInfoLabelOn" : False
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
    "pmTickMarkDisplayMode" : "NoCreate"
    "pmLabelBarDisplayMode" : "NEVER"
    "vpXF"      : vpx        ; set viewport
    "vpYF"      : vpy       
    "vpWidthF"  : vpwidth
    "vpHeightF" : vpheight
end create
