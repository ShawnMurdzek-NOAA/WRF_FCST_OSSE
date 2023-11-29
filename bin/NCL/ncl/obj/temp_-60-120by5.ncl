cnid = create "contourplot" contourPlotClass wid
    "cnScalarFieldData":  tfield
;    "cnFillColors" : (/ 8,9,10,11,20,12,13,2,3,4,5,6,7,8,9,10,11,12,13 /)
    "cnFillColors" : (/ 14,15,16,17,18,19,20,38,1,22,23,24,25,2,3,4,5,6,7,8,9,10, \
                        11,12,13,14,15,16,17,18,19,20,21,22,23,24,25 /)
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
