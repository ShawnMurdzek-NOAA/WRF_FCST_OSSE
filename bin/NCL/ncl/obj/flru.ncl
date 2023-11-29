; uses cmap_ptyp.ncl
;
cnid = create "contourplot" contourPlotClass wid
    "cnScalarFieldData":  tfield
    "cnConstFLabelOn" : False
    "cnRasterModeOn" : True
    "cnFillColors" : (/ 6,2,19,13 /)
    "cnLevels" : (/ 1,2,3 /)
    "cnLevelSelectionMode" : "ExplicitLevels"
    "cnFillOn" : True
    "cnLinesOn" : False
    "cnLineLabelsOn" : False
    "cnInfoLabelOn" : False
    "pmTickMarkDisplayMode" : "NoCreate"
    "pmLabelBarDisplayMode" : "NoCreate"
    "vpXF"      : vpx        ; set viewport
    "vpYF"      : vpy
    "vpWidthF"  : vpwidth
    "vpHeightF" : vpheight
end create
;
lbid = create "LabelBar" labelBarClass wid
    "lbOrientation" : "Horizontal"
    "lbAutoManage" : False
    "lbLabelFont" : 4
    "lbLabelFontHeightF" : .011
    "lbPerimOn" : False
    "lbBoxCount" : 4
    "lbLabelFontColor" : "white"
    "lbFillColors" : (/ 13,19,2,6 /)
    "lbMonoFillPattern" : True
    "lbLabelAlignment" : "BoxCenters"
    "lbLabelStrings" : (/"LIFR","IFR","MVFR","VFR"/)
    "vpXF"      : 0.18
    "vpYF"      : (vpy - vpheight) + 0.015
    "vpWidthF"  : vpwidth-0.26
    "vpHeightF" : 0.1
end create

