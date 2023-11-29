cnid = create "contourplot" contourPlotClass wid
    "cnScalarFieldData":  tfield
;    "cnFillColors" : (/ 1,2,3,4,5,6,7,8,9,10,11,12,13,2,3,4,5,6,7,8,9,10 /)
;    "cnFillColors" : (/ 2,5,10,15,20,25,30,35,40,45,50,55,60,65,70,75,80,85,90,95,100, \
;                        105,110,115,120,125,130,135,140,145,150, \
;                        155,160,165,170,175,180,185,190,195,200 /)
    "cnFillColors" : (/ 200,195,190,185,180,175,170,165, \
                        160,155,150,145,140,135,130,125, \
                        75,70,65,60,55,50,45,40,35,30,25,20,15,10,5,2 /)
    "cnLevelSelectionMode" : "ExplicitLevels"
    "cnLevels" : (/ -15,-14,-13,-12,-11,-10, \
                    -9,-8,-7,-6,-5,-4,-3,-2,-1,0, \
                    1,2,3,4,5,6,7,8,9,10, \
                    11,12,13,14,15 /)
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
    "lbTitleFont" : 22
    "lbPerimOn" : False
    "lbBoxLinesOn" : 0
    "lbLabelFontHeightF" : 0.01
;    "lbLabelStride" : 2
    "vpXF"      : vpx        ; set viewport
    "vpYF"      : vpy       
    "vpWidthF"  : vpwidth
    "vpHeightF" : vpheight
end create
