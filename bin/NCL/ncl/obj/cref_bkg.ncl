cnidbkg = create "contourplot" contourPlotClass wid
    "cnScalarFieldData":  tfieldbkg
;    "cnFillColors" : (/ 52,26,33,35,37 /)
    "cnFillColors" : (/ 1,26,33,35,37 /)
    "cnLevelSelectionMode" : "ExplicitLevels"
    "cnLevels" : (/ 25,100,200,300 /)
    "cnFillOn" : True
    "cnLinesOn" : False
    "cnLineLabelsOn" : False
    "cnInfoLabelOn" : False
    "cnRasterModeOn" : True
    "pmTickMarkDisplayMode" : "NoCreate"
    "pmLabelBarDisplayMode" : "NEVER"
    "pmLabelBarHeightF" : .05
    "pmLabelBarWidthF" : 0.9
    "pmLabelBarSide" : "bottom"
    "pmLabelBarOrthogonalPosF" : 0.0
    "lbOrientation" : "horizontal"
    "lbTitleFont" : 22 
    "lbPerimOn" : False
    "lbBoxLinesOn" : 0
    "vpXF"      : vpx        ; set viewport
    "vpYF"      : vpy       
    "vpWidthF"  : vpwidth
    "vpHeightF" : vpheight
end create
