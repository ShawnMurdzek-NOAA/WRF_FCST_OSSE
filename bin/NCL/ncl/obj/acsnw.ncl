cnid = create "contourplot" contourPlotClass wid
    "cnScalarFieldData":  tfield
    "cnFillColors" : (/ 1,20,3,4,5,6,7,8,9,10,11,12,13,1 /)
    "cnLevelSelectionMode" : "ExplicitLevels"
    "cnLevels" : (/ .01,.1,1,2,3,4,6,8,10,12,18,24,38 /)
    "cnExplicitLabelBarLabelsOn" : True
    "cnFillOn" : True
    "cnLinesOn" : False
    "cnLineLabelsOn" : False
    "cnInfoLabelOn" : False
    "cnGridBoundPerimOn" : True
    "cnRasterModeOn" : True
    "pmTickMarkDisplayMode" : "NoCreate"
    "pmLabelBarDisplayMode" : "ALWAYS"
    "pmLabelBarHeightF" : .05
    "pmLabelBarWidthF" : 0.9
    "pmLabelBarSide" : "bottom"
    "pmLabelBarOrthogonalPosF" : 0.0
    "pmLabelBarParallelPosF" : 0.5
    "lbAutoManage" : False
    "lbOrientation" : "horizontal"
    "lbLabelFont" : 22
    "lbPerimOn" : False
    "lbBoxLinesOn" : 0
    "lbLabelStrings" : (/ ".01",".1","1","2","3","4","6","8","10","12","18", \
                          "24","38" /)
    "vpXF"      : vpx        ; set viewport
    "vpYF"      : vpy       
    "vpWidthF"  : vpwidth
    "vpHeightF" : vpheight
end create
