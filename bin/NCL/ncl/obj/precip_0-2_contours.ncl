cnid4 = create "contourplot" contourPlotClass wid
    "cnScalarFieldData":  tempfield
;    "cnLevels" : (/ 0.01, 0.05, 0.1, 0.25, 0.5, 0.75, 1, 2/)
    "cnLevels" : (/ 0.1, 0.5, 1, 2/)
    "cnLevelSelectionMode" : "ExplicitLevels"
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
    "pmTickMarkDisplayMode" : "NoCreate"
    "pmLabelBarDisplayMode" : "NEVER"
    "vpXF"      : vpx        ; set viewport
    "vpYF"      : vpy       
    "vpWidthF"  : vpwidth
    "vpHeightF" : vpheight
end create
