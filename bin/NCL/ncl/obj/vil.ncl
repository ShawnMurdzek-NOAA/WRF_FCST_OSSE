;
cnid = create "contourplot" contourPlotClass wid
    "cnScalarFieldData":  tfield
    "cnFillColors" : (/1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18/)
    "cnLevelSelectionMode" : "ExplicitLevels"
    "cnLevels" : (/0.05,0.15,0.76,3.47,6.92,12.0,31.6,35,40,45,50,55,60,65,70/)
    "cnFillOn" : True
    "cnFillMode" : "RasterFill"
    "cnLinesOn" : False
    "cnLineLabelsOn" : False
    "cnInfoLabelOn" : False
    "cnGridBoundPerimOn" : True
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
    "lbLabelStride" : 1
    "lbLabelFontHeightF" : 0.015
    "vpXF"      : vpx        ; set viewport
    "vpYF"      : vpy
    "vpWidthF"  : vpwidth
    "vpHeightF" : vpheight
end create

