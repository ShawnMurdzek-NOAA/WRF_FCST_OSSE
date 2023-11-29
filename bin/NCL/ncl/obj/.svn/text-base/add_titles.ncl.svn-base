;
titleid = create "TextItems" textItemClass wid
  "txFuncCode" : "~"
  "txString" : titlestring
  "txFont" : 22
  "txFontHeightF" : 0.02
  "txFontColor" : 1
end create
;
txid = create "TextItems" textItemClass wid
  "txFuncCode" : "~"
  "txString" : modl+intm+" "+fctm+" hr fcst"
  "txFont" : 22
  "txFontHeightF" : 0.015
  "txFontColor" : 1
end create
;
txid2 = create "TextItems" textItemClass wid
  "txFuncCode" : "~"
  "txString" : date_str
  "txFont" : 22
  "txFontHeightF" : 0.015
  "txFontColor" : 1
end create
;
iannotitle = NhlAddAnnotation(cnid,titleid)
setvalues iannotitle
  "amZone":           10
  "amSide":           "top"
  "amJust":           "bottomright"
  "amParallelPosF":    1.0
  "amOrthogonalPosF":  0.0
end setvalues
;
if (vpheight .ge. vpwidth) then
  opos = 0.032
else
  opos = 0.1 - ((vpheight/vpwidth)*0.07)
end if
;
ianno = NhlAddAnnotation(cnid,txid)
setvalues ianno
  "amZone":           10
  "amSide":           "top"
  "amJust":           "bottomleft"
  "amParallelPosF":    0.0
  "amOrthogonalPosF":  opos
end setvalues
;
ianno2 = NhlAddAnnotation(cnid,txid2)
setvalues ianno2
  "amZone":           10
  "amSide":           "top"
  "amJust":           "bottomright"
  "amParallelPosF":    1.0
  "amOrthogonalPosF":  opos
end setvalues
;

