cnid = create "contourplot" contourPlotClass wid
    "cnScalarFieldData":  tfield
;    "cnFillColors" : (/ -1,2,9,11,13 /)
    "cnFillColors" : (/ -1,11,8,5,2 /)
    "cnLevelSelectionMode" : "ExplicitLevels"
    "cnLevels" : (/ 25,100,200,300 /)
    "cnFillOn" : True
    "cnLinesOn" : False
    "cnLineLabelsOn" : False
    "cnInfoLabelOn" : False
    "cnRasterModeOn" : True
    "pmTickMarkDisplayMode" : "NoCreate"
;    "pmLabelBarDisplayMode" : "ALWAYS"
    "pmLabelBarDisplayMode" : "NEVER"
    "pmLabelBarHeightF" : .05
    "pmLabelBarWidthF" : 0.9
    "pmLabelBarSide" : "bottom"
    "pmLabelBarOrthogonalPosF" : 0.0
    "lbAutoManage" : False
    "lbLabelFontHeightF" : 0.02
    "lbOrientation" : "horizontal"
    "lbTitleFont" : 22 
    "lbPerimOn" : False
    "lbBoxLinesOn" : 0
    "vpXF"      : vpx        ; set viewport
    "vpYF"      : vpy       
    "vpWidthF"  : vpwidth
    "vpHeightF" : vpheight
end create
