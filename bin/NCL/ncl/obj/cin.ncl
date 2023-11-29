cnid = create "contourplot" contourPlotClass wid
    "cnScalarFieldData":  tfield
    "cnFillColors" : (/ 13,12,11,10,9,8,7,6,5,4,3,1 /)
;    "cnLevelSelectionMode" : "ManualLevels"
    "cnLevelSelectionMode" : "ExplicitLevels"
    "cnLevels" : (/ -300,-200,-150,-100,-75,-50,-40,-30,-20,-10,-1 /)
;    "cnMaxLevelValF" : 0
;    "cnLevelSpacingF" : 50 
    "cnFillOn" : True
    "cnLinesOn" : False
    "cnLineLabelsOn" : False
    "cnInfoLabelOn" : False
    "cnRasterModeOn" : True
    "cnRasterSmoothingOn" : True
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
    "vpXF"      : vpx        ; set viewport
    "vpYF"      : vpy       
    "vpWidthF"  : vpwidth
    "vpHeightF" : vpheight
end create
