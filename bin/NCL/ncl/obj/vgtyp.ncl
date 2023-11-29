cnid = create "contourplot" contourPlotClass wid
    "cnScalarFieldData":  tfield
    "cnMonoLineColor" : False
    "cnLevels" : (/1, 2, 3, 4, 5, 6, 7, 8, 9, 10, \
                   11, 12, 13, 14, 15, 16, 17, 18, 19, 20/)
    "cnFillColors" : (/6,8,10,14,16,18,20,21,22,23,24,25,26,27,28, \
                       29,30,32,34,36/)
    "cnLevelSelectionMode" : "ExplicitLevels"
    "cnFillOn" : True
    "cnLinesOn" : False
    "cnInfoLabelOn" : False
    "cnLineLabelsOn" : False 
    "cnRasterModeOn" : True
    "pmTickMarkDisplayMode" : "NoCreate"
    "pmLabelBarDisplayMode" : "Always"
    "pmLabelBarHeightF" : 0.6
    "pmLabelBarWidthF" : 0.05
    "pmLabelBarSide" : "Right"
    "pmLabelBarOrthogonalPosF" : -0.002
    "lbAutoManage" : False
    "lbOrientation" : "Vertical"
    "lbTitleFont" : 22 
    "lbPerimOn" : False
    "lbBoxLinesOn" : 0
    "lbLabelStrings" : (/"1","2","3","4","5","6","7","8","9","10","11","12", \
                         "13","14","15","16","17","18","19","20"/)
    "lbLabelAlignment" : "BoxCenters"
    "lbLabelFontHeightF" : 0.015
    "vpXF"      : vpx        ; set viewport
    "vpYF"      : vpy       
    "vpWidthF"  : vpwidth
    "vpHeightF" : vpheight
end create
;
;lbid = create "LabelBar" labelBarClass wid
;    "pmLabelBarDisplayMode" : "ALWAYS"
;    "pmLabelBarHeightF" : 0.9
;    "pmLabelBarWidthF" : 0.05
;    "pmLabelBarSide" : "Right"
;    "lbOrientation" : "Vertical"
;    "lbAutoManage" : False
;    "lbLabelFont" : 4
;    "lbLabelFontHeightF" : .011
;    "lbMonoFillPattern" : True
;    "lbFillPattern" : "SolidFill"
;;    "lbMonoFillScale" : False
;;    "lbFillScales" : (/ 0.4,0.4,0.4,0.4 /)
;    "lbPerimOn" : False
;    "lbBoxCount" : 20
;    "lbLabelFontColor" : "white"
;    "lbFillColors" : (/6,8,10,14,16,18,20,21,22,23,24,25,26,27,28, \
;                       29,30,32,34,36/)
;    "lbLabelAlignment" : "BoxCenters"
;    "lbLabelOffsetF" : -0.24
;;    "lbLabelStrings" : (/"SNOW","FREEZING RAIN","RAIN","ICE PELLETS"/)
;    "lbLabelStrings" : (/"1","2","3","4","5","6","7","8","9","10","11","12", \
;                         "13","14","15","16","17","18","19","20"/)
;    "vpXF"      : 0.18
;    "vpYF"      : (vpy - vpheight); + 0.015
;    "vpWidthF"  : vpwidth-0.26
;    "vpHeightF" : 0.08
;end create

