;
; uses cmap3
;
cloudsid = create "contourplot" contourPlotClass wid
    "cnScalarFieldData":  ctopfield
    "cnFillColors" : (/ -1,35,2,36,3,37,4,38,39,40,1 /)
    "cnLevelSelectionMode" : "ExplicitLevels"
    "cnLevels" : (/ 0,5,10,15,20,25,30,35,40,45 /)
    "cnFillOn" : True
    "cnLinesOn" : False
    "cnLineLabelsOn" : False
    "cnInfoLabelOn" : False
    "cnGridBoundPerimOn" : False
    "cnMissingValFillColor" : -1
    "cnRasterModeOn" : False
    "pmTickMarkDisplayMode" : "NoCreate"
    "pmLabelBarDisplayMode" : "NEVER"
    "vpXF"      : vpx        ; set viewport
    "vpYF"      : vpy       
    "vpWidthF"  : vpwidth
    "vpHeightF" : vpheight
end create
