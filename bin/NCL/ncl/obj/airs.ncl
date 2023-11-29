cnid = create "contourplot" contourPlotClass wid
    "cnScalarFieldData":  tfield
;    "cnFillColors" : (/ 2,10,18,24,26,34,38,64,72,80,88,94,98,102 /)
    "cnFillColors" : (/ 2,10,18,24,26,34,38,54,72,80,88,94,98,102 /)
    "cnLevelSelectionMode" : "ExplicitLevels"
    "cnLevels" : (/ -3, -2.5,-2, -1.5, -1, -0.5, 0, 0.5, 1, 1.5, 2, 2.5, 3.0 /)
    "cnExplicitLabelBarLabelsOn" : True
    "cnFillOn" : True
    "cnLinesOn" : False
    "cnLineLabelsOn" : False
    "cnInfoLabelOn" : False
    "cnGridBoundPerimOn" : True
    "cnRasterModeOn" : True
    "pmTickMarkDisplayMode" : "NoCreate"
    "pmLabelBarDisplayMode" : "ALWAYS"
    "pmLabelBarHeightF" : .05
    "pmLabelBarWidthF" : 0.9
    "pmLabelBarSide" : "bottom"
    "pmLabelBarOrthogonalPosF" : 0.0
    "pmLabelBarParallelPosF" : 0.5
    "lbAutoManage" : False
    "lbOrientation" : "horizontal"
    "lbLabelFont" : 22
    "lbPerimOn" : False
    "lbBoxLinesOn" : 0
    "vpXF"      : vpx        ; set viewport
    "vpYF"      : vpy       
    "vpWidthF"  : vpwidth
    "vpHeightF" : vpheight
end create
