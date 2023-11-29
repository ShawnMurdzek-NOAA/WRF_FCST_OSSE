; geopotential height
;
cnid4 = create "contourplot" contourPlotClass wid
    "cnScalarFieldData":  hfield
    "cnLevelSelectionMode" : "ManualLevels"
    "cnMinLevelValF" : 900
    "cnMaxLevelValF" : 3900
    "cnLevelSpacingF" : 12
    "cnLineThicknessF" : 1.5
    "cnMonoLineColor" : True
    "cnLineLabelPlacementMode" : "Computed"
    "cnInfoLabelOn" : False
    "cnLinesOn" : True
    "cnLineColor" : 1
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

