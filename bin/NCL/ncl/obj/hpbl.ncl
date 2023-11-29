cnid = create "contourplot" contourPlotClass wid
    "cnScalarFieldData":  tfield
    "cnMonoLineColor" : False
    "cnLevels" : (/ 0, 250, 500, 750, 1000, 1250, 1500, 1750, 2000, \
                    2250, 2500, 2750, 3000, 3250, 3500, 3750, 4000, \
                    4250, 4500, 4750, 5000 /)
    "cnFillColors" : (/2,3,4,5,6,7,8,9,10,11,12,13,14, \
                       15,16,17,18,19,20,21,22/)
    "cnLevelSelectionMode" : "ExplicitLevels"
    "cnFillOn" : True
    "cnLinesOn" : False
    "cnInfoLabelOn" : False
    "cnLineLabelsOn" : False 
    "cnRasterModeOn" : False
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
    "lbLabelFontHeightF" : 0.015
    "lbLabelStride" : 4
    "vpXF"      : vpx        ; set viewport
    "vpYF"      : vpy       
    "vpWidthF"  : vpwidth
    "vpHeightF" : vpheight
end create
