cnid = create "contourplot" contourPlotClass wid
    "cnScalarFieldData":  tfield
    "cnRasterModeOn":  True
    "cnLevelSelectionMode" : "ExplicitLevels"
    "cnLevels" : (/ 0.,5.,10.,15.,20.,25.,30.,35.,40.,45.,50.,55.,60.,65.,70.,75. /)
    "cnFillColors" : (/ 1,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,1 /)
    "cnFillOn" : True
    "cnLinesOn" : False
    "cnLineLabelsOn" : False
    "cnInfoLabelOn" : False
    "pmTickMarkDisplayMode" : "NoCreate"
    "pmLabelBarDisplayMode" : "ALWAYS"
    "pmLabelBarHeightF" : .05
    "pmLabelBarWidthF" : 0.9
    "pmLabelBarSide" : "bottom"
    "pmLabelBarOrthogonalPosF" : 0.0
    "lbOrientation" : "horizontal"
    "lbBoxLineColor" : "background"
    "lbTitleFont" : 22
    "lbPerimOn" : False
    "lbBoxLinesOn" : True
    "vpXF"      : vpx        ; set viewport
    "vpYF"      : vpy
    "vpWidthF"  : vpwidth
    "vpHeightF" : vpheight
end create

