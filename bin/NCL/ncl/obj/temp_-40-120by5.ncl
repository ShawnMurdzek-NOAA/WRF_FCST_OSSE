cnid = create "contourplot" contourPlotClass wid
    "cnScalarFieldData":  tfield
;    "cnFillColors" : (/ 2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20, \
;                        21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36 /)
    "cnFillColors" : (/ 2,3,4,5,6,7,8,9,10,17,16,15,14,13,12,11,18,19,20,21,22,29,28,27, \
                        26,25,24,23,30,31,32,33,34,35,36 /)
    "cnLevelSelectionMode" : "ManualLevels"
    "cnMinLevelValF" : -40
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
