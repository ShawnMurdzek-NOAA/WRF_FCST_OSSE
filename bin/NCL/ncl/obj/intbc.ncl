;
; uses cmap3
;
cnid = create "contourplot" contourPlotClass wid
    "cnScalarFieldData":  tfield
    "cnFillColors" : (/ 1,38,37,36,25,26,27,28,29 /)
    "cnLevelSelectionMode" : "ExplicitLevels"
    "cnLevels" : (/ .1,.3,.6,.9,1.2,1.5,1.8,2.1 /)
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
    "lbLabelFont" : 22
    "lbLabelStride" : 1 
    "lbLabelFontHeightF" : 0.02
    "vpXF"      : vpx        ; set viewport
    "vpYF"      : vpy       
    "vpWidthF"  : vpwidth
    "vpHeightF" : vpheight
end create
