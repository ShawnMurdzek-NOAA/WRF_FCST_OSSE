; do loop to make subdomain tiles for HRRR
;
;do iq = 0,8
iq = 0
;
if (iq .eq. 0) then ; full domain
;  llx = 0
;  lly = 0
;  urx = nx - 1
;  ury = ny - 1
  llx = 4400
  lly = 900
  urx = 6100
  ury = 2800
  wstride = 30
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
print("lon "+llx+" = "+lon(llx))
print("lat "+lly+" = "+lat(lly))
print("lon "+urx+" = "+lon(urx))
print("lat "+ury+" = "+lat(ury))
LcLon = lon(llx)
LcLat = lat(lly)
RcLon = lon(urx)
RcLat = lat(ury)

