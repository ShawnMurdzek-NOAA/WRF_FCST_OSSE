cnid = create "contourplot" contourPlotClass wid
    "cnScalarFieldData":  tfield
    "cnLevels" : (/-.2, -.1, -0.075, -0.05, -0.025, -0.01, -0.005, -0.001, \
                   0.001, 0.005, 0.01, 0.025, 0.05, 0.075, .1, .2/)
    "cnFillColors" : (/2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18/)
    "cnLevelSelectionMode" : "ExplicitLevels"
    "cnFillOn" : True
    "cnLinesOn" : False
    "cnInfoLabelOn" : False
    "cnLineLabelsOn" : False 
    "cnRasterModeOn" : True
    "cnRasterSmoothingOn" : True
    "pmTickMarkDisplayMode" : "NoCreate"
    "pmLabelBarDisplayMode" : "ALWAYS"
    "pmLabelBarHeightF" : .05
    "pmLabelBarWidthF" : 1.0
    "pmLabelBarSide" : "bottom"
    "pmLabelBarOrthogonalPosF" : 0.0
    "lbAutoManage" : False
    "lbOrientation" : "horizontal"
    "lbTitleFont" : 22 
    "lbPerimOn" : False
    "lbBoxLinesOn" : 0
    "lbLabelFontHeightF" : 0.012
    "vpXF"      : vpx        ; set viewport
    "vpYF"      : vpy       
    "vpWidthF"  : vpwidth
    "vpHeightF" : vpheight
end create

