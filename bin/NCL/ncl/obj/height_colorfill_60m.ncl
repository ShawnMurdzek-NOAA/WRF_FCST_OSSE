;
; uses cmap1_dbl2
;
cnid = create "contourplot" contourPlotClass wid
    "cnScalarFieldData":  hfield
    "cnFillColors" : (/ 6,7,8,9,10,11,12,13,14,15,16,17,18,19,20, \
                        21,22,23,24,25,26,27,28,29 /)
    "cnLevelSelectionMode" : "ExplicitLevels"
    "cnLevels" : (/ 480,486,492,498,504,510,516,522,528,534, \
                    540,546,552,558,564,570,576,582,588,594,600,606,612 /)
    "cnFillOn" : True
    "cnLinesOn" : False
    "cnLineLabelsOn" : False
    "cnInfoLabelOn" : False
    "cnRasterModeOn" : True
    "pmTickMarkDisplayMode" : "NoCreate"
    "pmLabelBarDisplayMode" : "ALWAYS"
    "pmLabelBarHeightF" : .05
    "pmLabelBarWidthF" : 0.9
    "pmLabelBarSide" : "bottom"
    "pmLabelBarOrthogonalPosF" : 0.0
    "lbOrientation" : "horizontal"
    "lbTitleFont" : 22
    "lbPerimOn" : False
    "lbBoxLinesOn" : 0
    "lbLabelFontHeightF" : 0.06
    "lbLabelStride" : 2
    "vpXF"      : vpx        ; set viewport
    "vpYF"      : vpy
    "vpWidthF"  : vpwidth
    "vpHeightF" : vpheight
end create
