cnid = create "contourplot" contourPlotClass wid
    "cnScalarFieldData":  tfield
;    "cnFillColors" : (/ 2,4,5,6,8,9,10,11,21 /)
    "cnFillColors" : (/ 11,10,9,8,6,5,4,2 /)
    "cnLevelSelectionMode" : "ExplicitLevels"
    "cnLevels" : (/ 0,.1,.2,.3,.4,.5,.6 /)
    "cnFillOn" : True
    "cnLinesOn" : False
    "cnLineLabelsOn" : False
    "cnInfoLabelOn" : False
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
    "lbLabelFontHeightF" : 0.02
    "lbPerimOn" : False
    "lbBoxLinesOn" : 0
    "vpXF"      : vpx        ; set viewport
    "vpYF"      : vpy       
    "vpWidthF"  : vpwidth
    "vpHeightF" : vpheight
end create
