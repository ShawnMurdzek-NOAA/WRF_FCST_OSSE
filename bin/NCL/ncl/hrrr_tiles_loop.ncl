; do loop to make subdomain tiles for HRRR
;
do iq = 0,6
;
if (iq .eq. 0) then ; full domain
  llx = 0
  lly = 0
  urx = nx - 1
  ury = ny - 1
end if
;
if (iq .eq. 1) then ; NW tile
  llx = 97
  lly = 578
  urx = 705
  ury = 1058
end if
;
if (iq .eq. 2) then ; NC tile
  llx = 608
  lly = 506
  urx = 1180
  ury = 940
end if
;
if (iq .eq. 3) then ; NE tile
  llx = 1095
  lly = 434
  urx = 1717
  ury = 988
end if
;
if (iq .eq. 4) then ; SW tile
  llx = 97
  lly = 280
  urx = 705
  ury = 771
end if
;
if (iq .eq. 5) then ; SC tile
  llx = 608
  lly = 48
  urx = 1180
  ury = 665
end if
;
if (iq .eq. 6) then ; SE tile
  llx = 1055
  lly = 48
  urx = 1565
  ury = 566
end if
;
tmpnx = urx - llx
tmpny = ury - lly
;xdim = nx - 1
;ydim = ny - 1
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

