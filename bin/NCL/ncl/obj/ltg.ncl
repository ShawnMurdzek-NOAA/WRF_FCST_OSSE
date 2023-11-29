;
; uses cmap_ltg
;
cnid = create "contourplot" contourPlotClass wid
    "cnScalarFieldData":  tfield
    "cnLevelSelectionMode" : "ExplicitLevels"
    "cnFillColors" : (/ 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15 /)
    "cnLevels" : (/ .01,.50,1.0,1.5,2.0,2.5,3.0,4.0,5.0,6.0,7.0,8.0,10.0,12.0 /)
    "cnFillOn" : True
    "cnLinesOn" : False
    "cnLineLabelsOn" :False
    "cnInfoLabelOn" : False
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
    "lbLabelFontHeightF" : 0.015
    "lbLabelStride" : 1
    "vpXF"      : vpx        ; set viewport
    "vpYF"      : vpy       
    "vpWidthF"  : vpwidth
    "vpHeightF" : vpheight
end create
