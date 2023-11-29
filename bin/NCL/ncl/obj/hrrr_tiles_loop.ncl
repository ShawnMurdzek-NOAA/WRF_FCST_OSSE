; do loop to make subdomain tiles for HRRR
;
do iq = 0,13
;
if (iq .eq. 0) then ; full domain
  llx = 0
  lly = 0
  urx = nx - 1
  ury = ny - 1
  wstride = 30
end if
;
if (iq .eq. 1) then ; NW tile
  llx = 97
  lly = 578
  urx = 705
  ury = 1058
  wstride = 15
end if
;
if (iq .eq. 2) then ; NC tile
  llx = 608
  lly = 506
  urx = 1180
  ury = 940
  wstride = 15
end if
;
if (iq .eq. 3) then ; NE tile
  llx = 1095
  lly = 434
  urx = 1717
  ury = 988
  wstride = 15
end if
;
if (iq .eq. 4) then ; SW tile
  llx = 97
;  lly = 280
  lly = 100
  urx = 705
  ury = 771
  wstride = 15
end if
;
if (iq .eq. 5) then ; SC tile
  llx = 608
  lly = 48
  urx = 1180
  ury = 665
  wstride = 15
end if
;
if (iq .eq. 6) then ; SE tile
  llx = 1055
  lly = 48
  urx = 1565
  ury = 566
  wstride = 15
end if
;
if (iq .eq. 7) then ; Great Lakes tile
  llx = 970
  lly = 492
  urx = 1548
  ury = 1028
  wstride = 15
end if
;
if (iq .eq. 8) then ; NE Colorado
  llx = 600
  lly = 475
  urx = 770
  ury = 645
  wstride = 3
end if
;
if (iq .eq. 9) then ; SEA domain
  llx = 170
  lly = 840
  urx = 360
  ury = 1010
  wstride = 3
end if
;
if (iq .eq. 10) then ; SFO domain
  llx = 120
  lly = 550
  urx = 240
  ury = 660
  wstride = 2
end if
;
if (iq .eq. 11) then ; MKX domain
  llx = 1060
  lly = 560
  urx = 1300
  ury = 760
  wstride = 4
end if
;
if (iq .eq. 12) then ; OKX domain
  llx = 1430
  lly = 640
  urx = 1680
  ury = 790
  wstride = 4
end if
;
if (iq .eq. 13) then ; IAD domain
  llx = 1380
  lly = 530
  urx = 1570
  ury = 680
  wstride = 3
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

