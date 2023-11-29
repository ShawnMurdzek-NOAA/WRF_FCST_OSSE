cnid = create "contourplot" contourPlotClass wid
    "cnScalarFieldData":  tfield
    "cnFillColors" : (/ 8,23,9,26,10,29,11,32,20,35,12,38,13,23,2,26, \
                        3,29,4,32,5,35,6,38,7,23,8,26,9,29,10,32,11,35, \
                        12,38,13,23,20 /)
    "cnLevelSelectionMode" : "ManualLevels"
    "cnMinLevelValF" : -60
    "cnMaxLevelValF" : 120
    "cnLevelSpacingF" : 5 
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
    "lbTitleFont" : 22
    "lbPerimOn" : False
    "lbBoxLinesOn" : 0
    "lbLabelStride" : 2
    "lbLabelFontHeightF" : 0.015
    "vpXF"      : vpx        ; set viewport
    "vpYF"      : vpy       
    "vpWidthF"  : vpwidth
    "vpHeightF" : vpheight
end create
