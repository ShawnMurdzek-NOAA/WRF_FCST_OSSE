; temperature
;
cnid4 = create "contourplot" contourPlotClass wid
    "cnScalarFieldData":  tempfield
    "cnLevelSelectionMode" : "ManualLevels"
    "cnMinLevelValF" : -100
    "cnMaxLevelValF" : 150
    "cnLevelSpacingF" : 10
    "cnLineThicknessF" : 1.0
    "cnMonoLineColor" : True
    "cnLineLabelPlacementMode" : "Computed"
    "cnInfoLabelOn" : False
    "cnLinesOn" : True
    "cnLineColor" : 0
    "cnLineLabelsOn" : True
    "cnLineLabelInterval" : 1
    "cnLineLabelFont" : 21
    "cnLineLabelFontHeightF" : 0.01
    "cnLineLabelFontColor" : "Foreground"
    "cnLineLabelBackgroundColor" : "Background"
    "pmTickMarkDisplayMode" : "NoCreate"
    "vpXF"      : vpx        ; set viewport
    "vpYF"      : vpy       
    "vpWidthF"  : vpwidth
    "vpHeightF" : vpheight
end create

