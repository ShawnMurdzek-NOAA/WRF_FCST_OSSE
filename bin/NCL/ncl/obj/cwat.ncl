;
; uses cmap_cwat
;
cnid = create "contourplot" contourPlotClass wid
    "cnScalarFieldData":  tfield
    "cnFillColors" : (/ 0,2,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17 /)
    "cnLevelSelectionMode" : "ExplicitLevels"
    "cnLevels" : (/ 0.0001,0.0002,0.0005,0.001,0.002,0.005,0.01,0.02,0.05,0.1,0.2,0.5,1,2,5,10,20 /)
    "cnExplicitLabelBarLabelsOn" : True
    "cnFillOn" : True
    "cnLinesOn" : False
    "cnLineLabelsOn" : False
    "cnInfoLabelOn" : False
    "cnGridBoundPerimOn" : False
    "cnMissingValFillColor" : "Foreground"
    "cnRasterModeOn" : True
    "pmTickMarkDisplayMode" : "NoCreate"
    "pmLabelBarDisplayMode" : "ALWAYS"
    "pmLabelBarHeightF" : .05
    "pmLabelBarWidthF" : 0.9
    "pmLabelBarSide" : "bottom"
    "pmLabelBarOrthogonalPosF" : 0.0
    "lbAutoManage" : False
    "lbOrientation" : "horizontal"
    "lbTitleFont" : 22
    "lbPerimOn" : False
    "lbBoxLinesOn" : 0
    "lbLabelStrings" : (/ "0.0001","0.0002","0.0005","0.001","0.002","0.005","0.01","0.02","0.05", \
                          "0.1","0.2","0.5","1","2","5","10","20" /)
    "lbLabelStride" : 1
    "lbLabelFontHeightF" : 0.009
    "vpXF"      : vpx        ; set viewport
    "vpYF"      : vpy
    "vpWidthF"  : vpwidth
    "vpHeightF" : vpheight
end create

