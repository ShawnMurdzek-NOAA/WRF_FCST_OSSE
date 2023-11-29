load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl";
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCL_HOME/obj/plot_titles_hrrr.ncl"
;
load "$NCL_HOME/obj/cmap_mucp.ncl"
;
begin
;
airport_id = asciiread("Airports_id.txt",-1,"string")
airport_loc = asciiread("Airports_locs.txt",(/dimsizes(airport_id),2/),"float")
;
fname = asciiread("arw_file.txt",-1,"string") 
grb_file = addfile(fname,"r")
;
debug = 0
if (debug.eq.1) then
  names = getfilevarnames(grb_file)  ; Get the variable names in the
  print(names)                       ; GRIB file and print them out.
;
  do i = 0, dimsizes( names ) - 1
    print("Variable Name: " + names(i))
    dims = getfilevardims(grb_file,names(i))
    sizes = filevardimsizes(grb_file,names(i))
    print(dimsizes(sizes) + " Dimensions:")
    if(.not.any(ismissing(dims))) then
      do j = 0, dimsizes(dims) -1
        print( j + ") " + dims(j) + ": " + sizes(j))
      end do  
    end if
    atts = getfilevaratts(grb_file,names(i))
    if(.not.any(ismissing(atts))) then
      do k = 0, dimsizes(atts) -1
        print(atts(k) + ": " +grb_file->$names(i)$@$atts(k)$)
      end do
    end if
    delete(atts)
    delete(dims)
    delete(sizes)
    print("")
  end do
end if
;
hr3sizes = filevardimsizes(grb_file,"g3_lat_0")
ny = hr3sizes(0)
nx = hr3sizes(1)
;
intm = grb_file->T_GDS3_HTGL@initial_time
fctm = grb_file->T_GDS3_HTGL@forecast_time
lat = grb_file->g3_lat_0(:,:)
lon = grb_file->g3_lon_1(:,:)
latin1 = grb_file->g3_lon_1@Latin1
latin2 = grb_file->g3_lon_1@Latin2
lov = grb_file->g3_lon_1@Lov
;
year = stringtointeger(getSubString(intm,6,9))
mon  = stringtointeger(getSubString(intm,0,1))
day  = stringtointeger(getSubString(intm,3,4))
hour = stringtointeger(getSubString(intm,12,13))
time = (/0.0/)
time@units = "seconds since 1970-01-01 00:00:0.0"
date = ut_inv_calendar(year,mon,day,hour,0,0,time@units, 0)
fcst = (/date + stringtointeger(fctm)*3600/)
fcst@units = "seconds since 1970-01-01 00:00:0.0"
utc_date = ut_calendar(fcst, 0)
year   = floattointeger(utc_date(:,0))    ; Convert to integer for
month  = floattointeger(utc_date(:,1))    ; use in the sprinti function.
day    = floattointeger(utc_date(:,2))
hour   = floattointeger(utc_date(:,3))
minute = floattointeger(utc_date(:,4))
second = utc_date(:,5)
date_str = "Valid " + sprinti("%0.2i/", month) + sprinti("%0.2i/",day) + \
           sprinti("%0.4i", year) + " " + sprinti("%0.2i:00 ", hour) + \
           "UTC"
;
; Create an application object.
;
appid = create "mdss" appClass defaultapp
    "appUsrDir" : "./"
    "appDefaultParent" : True
end create
;
; Set only one of the following three params to 1, depending on the type
; of output desired (NCGM=metacode file, X11=screen, PS=PostScript file)
;
    NCGM=1
    X11=0
    PS=0
;
    if (NCGM .eq. 1) then
;
; Create an ncgmWorkstation object.
;
        wid = create "mdssWork" ncgmWorkstationClass defaultapp
           "wkMetaName" : "./points.ncgm"
        end create
    else
      if (X11 .eq. 1) then
;
; Create an XWorkstation object.
;
        wid = create "mdssWork" xWorkstationClass defaultapp
            "wkPause" : True
        end create
      else
        if (PS .eq. 1) then
;
; Create a PSWorkstation object.
;
          wid = create "mdssWork" psWorkstationClass defaultapp
           "wkPSFileName" : "./points.ps"
          end create
        end if
      end if
    end if
;
; Assign the colormap to the workstation.
setvalues wid
   "wkColorMap" : gen_colormap()
end setvalues
;
; Increase workspace memory
setvalues NhlGetWorkspaceObjectId()
   "wsMaximumSize": 247108864
end setvalues
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
;
mpid = create "mapplot" mapPlotClass wid 
;
  "mpProjection" : "LambertConformal"
  "mpLambertParallel1F" : latin1
  "mpLambertParallel2F" : latin2
;
  "mpLimitMode" : "Corners"    ; Limit the map view.
  "mpLambertMeridianF" : lov
  "mpLeftCornerLonF" : LcLon
  "mpLeftCornerLatF" : LcLat
  "mpRightCornerLonF" : RcLon
  "mpRightCornerLatF" : RcLat
  "mpOutlineBoundarySets" : "AllBoundaries"
  "mpNationalLineColor" : "foreground"
  "mpUSStateLineColor" : "foreground"
  "mpUSStateLineThicknessF" : 1.25
  "mpGridAndLimbOn" : False
  "mpGeophysicalLineColor" : "foreground"
  "vpXF"      : vpx        ; set viewport
  "vpYF"      : vpy
  "vpWidthF"  : vpwidth 
  "vpHeightF" : vpheight
;
end create
;
if (iq .ne. 0) then
  setvalues mpid
    "mpDataBaseVersion" : "Ncarg4_1"
    "mpDataSetName" : "Earth..2"
    "mpUSStateLineThicknessF" : 1.5
  end setvalues
end if
;
; Create a ScalarField object.
;
titleid = create "TextItems" textItemClass wid
  "txFuncCode" : "~"
  "txString" : "Grid Points"
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
iannotitle = NhlAddAnnotation(mpid,titleid)
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
ianno = NhlAddAnnotation(mpid,txid)
setvalues ianno
  "amZone":           10
  "amSide":           "top"
  "amJust":           "bottomleft"
  "amParallelPosF":    0.0
  "amOrthogonalPosF":  opos
end setvalues
;
ianno2 = NhlAddAnnotation(mpid,txid2)
setvalues ianno2
  "amZone":           10
  "amSide":           "top"
  "amJust":           "bottomright"
  "amParallelPosF":    1.0
  "amOrthogonalPosF":  opos
end setvalues
;
;
gsres = True
gsres@gsMarkerIndex = 1
do i = llx,urx,2
  do j = lly,ury,2 
    gsres@gsMarkerIndex = 1
    gsres@gsMarkerColor = 20
    gsres@gsMarkerSizeF = 0.001
    gsn_polymarker(wid,mpid,lon(j,i),lat(j,i),gsres)
  end do
end do
;
; Draw map of Sfc RelHum, Wind
;
draw(mpid)
;
frame(wid)
;
end do
;
end
;
