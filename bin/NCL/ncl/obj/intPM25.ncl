;
; uses cmap3
;
cnid = create "contourplot" contourPlotClass wid
    "cnScalarFieldData":  tfield
    "cnFillColors" : (/ 1,12,13,14,15,16,17,18,19,20,21,22,23,24,25,28,29,31,32 /)
    "cnLevelSelectionMode" : "ExplicitLevels"
    "cnLevels" : (/ .1,.5,1,1.5,1.8,2.1,2.4,2.7,3,3.3,3.5,3.7,3.9,4.1,4.3, \
                    4.5,4.7,5 /)
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
    "lbLabelFontHeightF" : 0.015
    "vpXF"      : vpx        ; set viewport
    "vpYF"      : vpy       
    "vpWidthF"  : vpwidth
    "vpHeightF" : vpheight
end create
