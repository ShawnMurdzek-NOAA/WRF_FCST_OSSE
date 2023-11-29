; do loop to make domains for FIM from grid 174 (1/8 deg global)
;
do idom = 0,5
;
lon = lonorig
if (isvar((/"uvar"/))) then
  uvar = uvarorig
  vvar = vvarorig
end if
if (isvar((/"tvar"/))) then
  tvar = tvarorig
end if
if (isvar((/"hvar"/))) then
  hvar = hvarorig
end if
if (isvar((/"t32"/))) then
  t32 = t32orig
end if
if (isvar((/"mvar"/))) then
  mvar = mvarorig
end if
if (isvar((/"thick"/))) then
  thick = thickorig
end if
if (isvar((/"vort"/))) then
  vort = vortorig
end if
;
if (idom .eq. 0) then ; Africa domain
  llx = 1119
  lly = 400
  urx = 1920
  ury = 1039
  lon = fliplon
  if (isvar((/"uvar"/))) then
    uvar = flipuvar
    vvar = flipvvar
    wstrid = 15
  end if
  if (isvar((/"tvar"/))) then
    tvar = fliptvar
  end if
  if (isvar((/"hvar"/))) then
    hvar = fliphvar
  end if
  if (isvar((/"t32"/))) then
    t32 = flipt32
  end if
  if (isvar((/"mvar"/))) then
    mvar = flipmvar
  end if
  if (isvar((/"thick"/))) then
    thick = flipthick
  end if
  if (isvar((/"vort"/))) then
    vort = flipvort
  end if
end if
;
if (idom .eq. 1) then ; E. Pacific domain
  llx = 1439
  lly = 719
  urx = 2399
  ury = 1199
  wstrid = 15
end if
;
if (idom .eq. 2) then ; Europe domain
  llx = 1199
  lly = 839
  urx = 2040
  ury = 1319
  lon = fliplon
  if (isvar((/"uvar"/))) then
    uvar = flipuvar
    vvar = flipvvar
    wstrid = 15
  end if
  if (isvar((/"tvar"/))) then
    tvar = fliptvar
  end if
  if (isvar((/"hvar"/))) then
    hvar = fliphvar
  end if
  if (isvar((/"t32"/))) then
    t32 = flipt32
  end if
  if (isvar((/"mvar"/))) then
    mvar = flipmvar
  end if
  if (isvar((/"thick"/))) then
    thick = flipthick
  end if
  if (isvar((/"vort"/))) then
    vort = flipvort
  end if
end if
;
if (idom .eq. 3) then ; floating domain
  llx = 840
  lly = 919
  urx = 1040
  ury = 1119
  wstrid = 4
end if
;
if (idom .eq. 4) then ; W. Pacific domain
  llx = 720
  lly = 400
  urx = 1919
  ury = 1119
  wstrid = 20
end if
;
if (idom .eq. 5) then ; Cambodia domain
  llx = 720
  lly = 719
  urx = 960
  ury = 919
  wstrid = 5
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
LcLon = lon(llx)
LcLat = lat(lly)
RcLon = lon(urx)
RcLat = lat(ury)
;
