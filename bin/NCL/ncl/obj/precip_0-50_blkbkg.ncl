cnid = create "contourplot" contourPlotClass wid
    "cnScalarFieldData":  tfield
    "cnMonoLineColor" : False
;    "cnLevels" : (/0.25, 0.5, 1, 2, 5, 10, 25, 50/)
;    "cnFillColors" : (/0,5,6,7,8,9,10,11,12/)
    "cnLevels" : (/0.10, 0.25, 0.5, 1, 2, 3, 5, 10, 20, 40/)
    "cnFillColors" : (/0,20,5,6,7,8,9,10,11,12,13/)
    "cnLevelSelectionMode" : "ExplicitLevels"
    "cnFillOn" : True
    "cnLinesOn" : False
    "cnInfoLabelOn" : False
    "cnLineLabelsOn" : False 
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
    "lbLabelFontHeightF" : 0.015
    "vpXF"      : vpx        ; set viewport
    "vpYF"      : vpy       
    "vpWidthF"  : vpwidth
    "vpHeightF" : vpheight
end create
