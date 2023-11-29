cnid = create "contourplot" contourPlotClass wid
    "cnScalarFieldData":  tfield
    "cnFillColors" : (/ 2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20, \
                        21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36 /)
    "cnLevelSelectionMode" : "ExplicitLevels"
    "cnLevels" : (/ -40,-37.5,-35,-32.5,-30,-27.5,-25,-22.5,-20,-17.5,-15,-12.5, \
                    -10,-7.5,-5,-2.5,0,2.5,5,7.5,10,12.5,15,17.5,20,22.5,25,27.5, \
                     30,32.5,35,37.5,40 /)
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
