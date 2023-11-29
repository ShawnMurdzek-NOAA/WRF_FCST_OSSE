; do loop to make subdomain tiles for RUC
;
do iq = 0,7
;
if (iq .eq. 0) then ; full domain
  llx = 0
  lly = 0
  urx = nx - 1
  ury = ny - 1
end if
;
if (iq .eq. 1) then ; NW tile
  llx = 50
  lly = 138
  urx = 203
  ury = 275
end if
;
if (iq .eq. 2) then ; NC tile
  llx = 150
  lly = 141
  urx = 305
  ury = 279
end if
;
if (iq .eq. 3) then ; NE tile
  llx = 293
  lly = 147
  urx = 450
  ury = 283
end if
;
if (iq .eq. 4) then ; SW tile
  llx = 45
  lly = 58
  urx = 201
  ury = 199
end if
;
if (iq .eq. 5) then ; SC tile
  llx = 152
  lly = 40
  urx = 305
  ury = 176
end if
;
if (iq .eq. 6) then ; SE tile
  llx = 266
  lly = 19
  urx = 424
  ury = 154
end if
;
if (iq .eq. 7) then ; Great Lakes tile
  llx = 227
  lly = 145
  urx = 383
  ury = 275
end if
;
tmpnx = urx - llx
tmpny = ury - lly
xdim = tmpnx
ydim = tmpny
rnx = 1.*xdim
rny = 1.*ydim
if (rny .ge. rnx) then
  vpheight = .88
  vpy = 1.-((1.-vpheight)/2.)
  vpwidth = (vpheight/rny)*rnx
  vpx = (1.-((vpheight/rny)*rnx))/2.
else
  vpwidth = .88
  vpx = (1.-vpwidth)/2.
  vpheight = (vpwidth/rnx)*rny
  vpy = 1.-((1.-((vpwidth/rnx)*rny))/2.)
end if
;
LcLon = lon(lly,llx)
LcLat = lat(lly,llx)
RcLon = lon(ury,urx)
RcLat = lat(ury,urx)

