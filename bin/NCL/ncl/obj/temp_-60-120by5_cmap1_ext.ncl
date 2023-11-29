cnid = create "contourplot" contourPlotClass wid
    "cnScalarFieldData":  tfield
;    "cnFillColors" : (/ 8,9,10,11,20,12,13,2,3,4,5,6,7,8,9,10,11,12,13 /)
    "cnFillColors" : (/ 14,15,16,17,18,19,38,40,21,39,22,23,24,25,2,3,4,5,6,7,8,9,10, \
                        11,12,13,14,15,16,17,18,19,21,39,22,23,24,25,38,40 /)
    "cnLevelSelectionMode" : "ManualLevels"
    "cnMinLevelValF" : -65
    "cnMaxLevelValF" : 125
    "cnLevelSpacingF" : 5 
    "cnFillOn" : True
    "cnLinesOn" : False
    "cnLineLabelsOn" : False
    "cnInfoLabelOn" : False
    "cnGridBoundPerimOn" : True
    "cnRasterModeOn" : True
    "cnExplicitLabelBarLabelsOn" : True
    "pmTickMarkDisplayMode" : "NoCreate"
    "pmLabelBarDisplayMode" : "ALWAYS"
    "pmLabelBarHeightF" : .05
    "pmLabelBarWidthF" : 0.9
    "pmLabelBarSide" : "bottom"
    "pmLabelBarOrthogonalPosF" : 0.0
    "pmLabelBarParallelPosF" : 0.5
    "lbAutoManage" : False
;    "lbAutoManage" : True
    "lbOrientation" : "horizontal"
    "lbTitleFont" : 22
    "lbPerimOn" : False
    "lbBoxLinesOn" : 0
    "lbLabelStrings" : (/"","-60","","-50","","-40","","-30","","-20","","-10", \
                         "","0","","10","","20","","30","","40","","50","","60", \
                         "","70","","80","","90","","100","","110","","120",""/)
    "lbLabelFontHeightF" : 0.015
    "vpXF"      : vpx        ; set viewport
    "vpYF"      : vpy       
    "vpWidthF"  : vpwidth
    "vpHeightF" : vpheight
end create
