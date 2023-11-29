; do loop to make subdomain tiles for HRRR
;
ntiles = 11
all_llx = new(ntiles,"integer")
all_lly = new(ntiles,"integer")
all_urx = new(ntiles,"integer")
all_ury = new(ntiles,"integer")
;
print("nx = "+nx+"  ny = "+ny)
do iq = 0,ntiles - 1
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
  wstride = 10
end if
;
if (iq .eq. 2) then ; NC tile
  llx = 608
  lly = 506
  urx = 1180
  ury = 940
  wstride = 10
end if
;
if (iq .eq. 3) then ; NE tile
  llx = 1095
  lly = 434
  urx = 1717
  ury = 988
  wstride = 10
end if
;
if (iq .eq. 4) then ; SW tile
  llx = 97
;  lly = 280
  lly = 100
  urx = 705
  ury = 771
  wstride = 10
end if
;
if (iq .eq. 5) then ; SC tile
  llx = 608
  lly = 48
  urx = 1180
  ury = 665
  wstride = 10
end if
;
if (iq .eq. 6) then ; SE tile
  llx = 1055
  lly = 48
  urx = 1565
  ury = 566
  wstride = 10
end if
;
if (iq .eq. 7) then ; SEA domain
  llx = 180
  lly = 840
  urx = 370
  ury = 1010
  wstride = 3
end if
;
if (iq .eq. 8) then ; SFO domain
  llx = 120
  lly = 500
  urx = 280
  ury = 660
  wstride = 2
end if
;
if (iq .eq. 9) then ; So. CA domain
  llx = 270
  lly = 280
  urx = 590
  ury = 560
  wstride = 7
end if
;
if (iq .eq. 10) then ; NW-Large (formerly WE-CAN domain)
  llx = 120
  lly = 300
  urx = 921
  ury = 1058
  wstride = 10
end if
;
all_llx(iq) = llx
all_lly(iq) = lly
all_urx(iq) = urx
all_ury(iq) = ury
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

