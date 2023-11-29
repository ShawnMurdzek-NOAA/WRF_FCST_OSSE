load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "skewt_func.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
load "names_grib2.txt"
load "plot_hodo.ncl"
;
; Open GRIB file
;
fname = asciiread("nat_file.txt",-1,"string")
grb_file = addfile(fname,"r")
;
land_file = addfile("hrrrterrainland.grib2","r")
land = land_file->LAND_P0_L1_GLC0(:,:)
sfchgt = land_file->HGT_P0_L1_GLC0(:,:)
;
;fnameprs=""
;fnameprs = asciiread("prs_file.txt",-1,"string")
;if (isfilepresent(fnameprs))
;  grb_file2 = addfile(fnameprs,"r")
;else
;  print("prs file not found -- exiting")
;  exit
;end if
;
; Change GRIB vertical level type here (p for pressure or n for native)
;
;LEVELS="p"
LEVELS="n"
;
; Change output file path/name here without filename extension
;
OUTFILENAME="sfc_skewt3"
;
; Get lat/lon sounding points
;
countstations = asciiread("conus_raobs3.txt",-1,"string")
numstations = dimsizes(countstations)
stations = asciiread("conus_raobs3.txt",numstations,"string")
raob_longname = new(numstations,"string")
raob_id = new(numstations,"string")
raob_wban = new(numstations,"integer")
raob_wmo = new(numstations,"integer")
raob_lat = new(numstations,"float")
raob_lon = new(numstations,"float")
raob_elev = new(numstations,"integer")
do iraob = 0,numstations-1
  ilen = strlen(stations(iraob))
  raob_longname(iraob) = getSubString(stations(iraob),37,ilen)
  station_parts = str_split(stations(iraob)," ")
  raob_id(iraob) = station_parts(0)
  raob_wban(iraob) = tointeger(station_parts(1))
  raob_wmo(iraob) = tointeger(station_parts(2))
  raob_lat(iraob) = tofloat(station_parts(3))
  raob_lon(iraob) = tofloat(station_parts(4))
  raob_lon(iraob) = -raob_lon(iraob)
  raob_elev(iraob) = tointeger(station_parts(5))
  delete(station_parts)
end do
;
begin
;
; Set plotting resources
;
res					= True
;
; Resources for plot size
;
res@gsnMaximize				= True
res@gsnShape				= True
res@gsnDraw				= False
res@gsnFrame				= False
res@tfDoNDCOverlay			= True
;
; Set only one of the following three params to 1, depending on the type
; of output desired (NCGM=metacode file, X11=screen, PS=PostScript file)
;
    NCGM=0
    X11=0
    PS=1
;
    if (NCGM .eq. 1) then
;
; Create an ncgmWorkstation object.
;
        wks = create "mdssWork" ncgmWorkstationClass defaultapp
           "wkMetaName" : "./sfc_skewt3.ncgm"
        end create
    else
      if (X11 .eq. 1) then
;
; Create an XWorkstation object.
;
        wks = create "mdssWork" xWorkstationClass defaultapp
            "wkPause" : True
        end create
      else
        if (PS .eq. 1) then
;
; Create a PSWorkstation object.
;
          wks = create "mdssWork" psWorkstationClass defaultapp
           "wkPSFileName" : "./sfc_skewt3.ps"
          end create
        end if
      end if
    end if
;
; Assign the colormap to the workstation.
setvalues wks
   "wkColorMap" : "radar_1"
end setvalues
;
;gsn_define_colormap(wks, "radar_1")
setvalues NhlGetWorkspaceObjectId()
  "wsMaximumSize" : 67108864
end setvalues
;
intm = grb_file->$T2MNAME$@initial_time
fctm = grb_file->$T2MNAME$@forecast_time
lat = grb_file->$LATNAME$(:,:)
lon = grb_file->$LONNAME$(:,:)
latin1 = grb_file->$LONNAME$@Latin1
latin2 = grb_file->$LONNAME$@Latin2
lov = grb_file->$LONNAME$@Lov
;
load "$NCL_HOME/obj/get_date_str.ncl"
;
; Start loop
;
do ii = 0,numstations-1
;
print("ii = "+ii)
RAOBLAT= raob_lat(ii)
RAOBLON= raob_lon(ii)
;
; Get the closest grid point for the lat/lon point
;
gridpts1 = wrf_latlon_to_ij(lat, lon, RAOBLAT, RAOBLON)
i1 = gridpts1(0)
j1 = gridpts1(1)
i1tmp = i1
j1tmp = j1
if (land(i1,j1) .eq. 0) then  ; point is over water, get new point
;
  if (RAOBLAT .ge. lat(i1,j1) .and. RAOBLON .le. lon(i1,j1)) then ; upper-left points
    i1tmp = -999
    j1tmp = -999
    if (land(i1-1,j1) .eq. 1) then
      i1tmp = i1-1
      j1tmp = j1
    else
      if (land(i1,j1+1) .eq. 1) then
        i1tmp = i1
        j1tmp = j1+1
      else
        if (land(i1-1,j1+1) .eq. 1) then
          i1tmp = i1-1
          j1tmp = j1+1
        end if
      end if
    end if
  end if
;
  if (RAOBLAT .ge. lat(i1,j1) .and. RAOBLON .gt. lon(i1,j1)) then ; upper-right points
    i1tmp = -999
    j1tmp = -999
    if (land(i1+1,j1) .eq. 1) then
      i1tmp = i1+1
      j1tmp = j1
    else
      if (land(i1,j1+1) .eq. 1) then
        i1tmp = i1
        j1tmp = j1+1
      else
        if (land(i1+1,j1+1) .eq. 1) then
          i1tmp = i1+1
          j1tmp = j1+1
        end if
      end if
    end if
  end if
;
  if (RAOBLAT .lt. lat(i1,j1) .and. RAOBLON .le. lon(i1,j1)) then ; lower-left points
    i1tmp = -999
    j1tmp = -999
    if (land(i1-1,j1) .eq. 1) then
      i1tmp = i1-1
      j1tmp = j1
    else
      if (land(i1,j1-1) .eq. 1) then
        i1tmp = i1
        j1tmp = j1-1
      else
        if (land(i1-1,j1-1) .eq. 1) then
          i1tmp = i1-1
          j1tmp = j1-1
        end if
      end if
    end if
  end if
;
  if (RAOBLAT .lt. lat(i1,j1) .and. RAOBLON .gt. lon(i1,j1)) then ; lower-right points
    i1tmp = -999
    j1tmp = -999
    if (land(i1+1,j1) .eq. 1) then
      i1tmp = i1+1
      j1tmp = j1
    else
      if (land(i1,j1-1) .eq. 1) then
        i1tmp = i1
        j1tmp = j1-1
      else
        if (land(i1+1,j1-1) .eq. 1) then
          i1tmp = i1+1
          j1tmp = j1-1
        end if
      end if
    end if
  end if
;
  i1 = i1tmp
  j1 = j1tmp
;
end if
;
if (i1tmp .eq. -999 .and. j1tmp .eq. -999) then ; all points over water
  print("all surrounding points over water")
end if 
;
; Get fields from file for either pressure or natural coordinate grids
;
if(LEVELS.ne."n") then
  tk1 = grb_file->$TNAME$(:,i1,j1)
  tdk1 = grb_file->$DPTNAME$(:,i1,j1)
  press1 = grb_file->$NUMPLEVS$(:)
;  press1 = 100*press1
  z1 = grb_file->$GHNAME$(:,i1,j1)
  z1sfc = sfchgt(i1,j1)
  z1 = z1 - z1sfc  ; convert heights to agl
  uwrf1 = grb_file->$UNAME$(:,:,:)
  vwrf1 = grb_file->$VNAME$(:,:,:)
  ustm1 = grb_file->$USTMNAME$(:,:)
  vstm1 = grb_file->$VSTMNAME$(:,:)
else
  tk1 = grb_file->$TMPNATNAME$(:,i1,j1)
  sh1 = grb_file->$SPFHNATNAME$(:,i1,j1)
  qvapor1 = sh1/(1 - sh1)
  press1 = grb_file->$PRESNATNAME$(:,i1,j1)
  tdk1 = wrf_td(press1, qvapor1) + 273.15
  z1 = grb_file->$GHNATNAME$(:,i1,j1)
  z1sfc = sfchgt(i1,j1)
  z1 = z1 - z1sfc  ; convert heights to agl
  uwrf1 = grb_file->$UNATNAME$(:,:,:)
  vwrf1 = grb_file->$VNATNAME$(:,:,:)
  ustm1 = grb_file->$USTMNAME$(:,:)
  vstm1 = grb_file->$VSTMNAME$(:,:)
end if
;
ushr01 = grb_file->$USHRNAME$(0,:,:)
vshr01 = grb_file->$VSHRNAME$(0,:,:)
ushr06 = grb_file->$USHRNAME$(1,:,:)
vshr06 = grb_file->$VSHRNAME$(1,:,:)
cape = grb_file->$CAPENAME$(i1,j1)
cin = grb_file->$CINNAME$(i1,j1)
mucape = grb_file->$MUCAPENAME$(2,i1,j1)
mucin = grb_file->$MUCINNAME$(2,i1,j1)
li = grb_file->$LINAME$(i1,j1)
bli = grb_file->$BLINAME$(i1,j1)
lcl = grb_file->$LCLNAME$(i1,j1)
lpl = grb_file->$PLPLNAME$(i1,j1)
srh03 = grb_file->$HLCYAGLNAME$(1,i1,j1) ; NCL switch
srh01 = grb_file->$HLCYAGLNAME$(0,i1,j1) ; NCL switch
pw = grb_file->$PWNAME$(i1,j1)
rhpw = grb_file->$RHPWNAME$(i1,j1)
;
; Calculate earth-relative wind
;
uvmet1 = wrf_uvmet(uwrf1, vwrf1, lat, lon, lat@Lov, 0)
u1 = uvmet1(0,:,i1,j1)
v1 = uvmet1(1,:,i1,j1)
uvmetst = wrf_uvmet(ustm1, vstm1, lat, lon, lat@Lov, 0)
ust = uvmetst(0,i1,j1)
vst = uvmetst(1,i1,j1)
uvmetshr01 = wrf_uvmet(ushr01, vshr01, lat, lon, lat@Lov, 0)
ush01 = uvmetshr01(0,i1,j1)
vsh01 = uvmetshr01(1,i1,j1)
uvmetshr06 = wrf_uvmet(ushr06, vshr06, lat, lon, lat@Lov, 0)
ush06 = uvmetshr06(0,i1,j1)
vsh06 = uvmetshr06(1,i1,j1)
;
; Reverse order of all arrays so they are bottom to top
;
if(LEVELS.ne."n") then
  tk1 = tk1(::-1)
  tdk1 = tdk1(::-1)
  press1 = press1(::-1)
  z1 = z1(::-1)
  u1 = u1(::-1)
  v1 = v1(::-1)
end if
;
; Convert variables to appropriate units (celcius for temps, mb for pressure, kts for wind)
;
r2d = 45.0/atan(1.0)
t1 = tk1 - 273.15
td1 = tdk1 - 273.15
p1 = press1/100.0
lcl = tointeger(lcl)
lpl = tointeger(lpl/100.0)
Uspd1 = 1.94384449*sqrt(u1*u1 + v1*v1)
Udir1 = atan2(u1, v1) * r2d + 180.0
SMspd = tointeger(1.94384449*sqrt(ust*ust + vst*vst))
SMdir = tointeger(atan2(ust, vst) * r2d + 180.0)
SMdir_string = sprinti("%0.3i",SMdir)
shear01 = tointeger(1.94384449*sqrt(ush01*ush01 + vsh01*vsh01))
shear06 = tointeger(1.94384449*sqrt(ush06*ush06 + vsh06*vsh06))
srh01 = round(srh01,3)
pw = round(pw*10.,1)/10.
;
; Change title here or leave blank
;
title1=intm+" "+fctm+" hr fcst          "+date_str
title2=raob_id(ii)+" "+raob_wmo(ii)+" "+raob_longname(ii)+" at nearest HRRR grid pt over land "+lat(i1,j1)+","+lon(i1,j1)
;
; Plot sounding background
;
skewtOpts                  		= True
skewtOpts@tiMainString     		= title1
skewtOpts@tiMainFontHeightF     	= 0.015
skewtOpts@tiMainOffsetYF                = -0.007
skewt_bkgd = skewT_BackGround(wks, skewtOpts)
draw(skewt_bkgd)
;
; Second title line
;
delete(skewtOpts)
skewtOpts                               = True
skewtOpts@tiMainString                  = title2
skewtOpts@tiMainFontHeightF             = 0.015
skewtOpts@tiMainOffsetYF                = -0.029
skewt_bkgd = skewT_BackGround(wks, skewtOpts)
draw(skewt_bkgd)
;
; Resources for the sounding
;
dataOpts 				= True
dataOpts@ThermoInfo       		= True
dataOpts@PrintZ				= False
dataOpts@colTemperature 		= "red"
dataOpts@colDewPt       		= "blue"
dataOpts@colCape        		= "orange"
dataOpts@colWindP       		= "blue"
dataOpts@colWindZ       		= "black"                                        
dataOpts@colWindH       		= "black"                                        
dataOpts@linePatternTemperature 	= 0
dataOpts@linePatternDewPt       	= 0
dataOpts@linePatternCape        	= 0
dataOpts@xpWind                 	= 45
;
; Draw the sounding
;
skewt_data = skewT_PlotData(wks, skewt_bkgd, p1, t1, td1, z1, Uspd1, Udir1, dataOpts)
draw(skewt_data)
;
; Draw the inset info box background
;
bpRes                  = True
bpRes@tmXBOn           = False
bpRes@tmXBBorderOn     = False
bpRes@tmXTOn           = False
bpRes@tmXTBorderOn     = False
bpRes@tmYROn           = False
bpRes@tmYRBorderOn     = False
bpRes@tmYLOn           = False
bpRes@tmYLBorderOn     = False
bpRes@gsnFrame         = False
infobox = gsn_blank_plot(wks,bpRes)
setvalues infobox
  "vpXF" : 0.61
  "vpYF" : 0.924
  "vpWidthF" : 0.152
  "vpHeightF" : 0.284
end setvalues
gsRes                  = True
gsRes@gsFillColor      = "White"
gsn_polygon(wks,infobox,(/0.0,1.0,1.0,0.0/),(/1.0,1.0,0.0,0.0/),gsRes)
;
; Draw the inset info box text
;
txidcape = create "TextItems" textItemClass wks
  "txFuncCode" : "~"
  "txString" : "CAPE: "+cape+" J/kg"
  "txFontHeightF" : 0.012
  "txFontColor" : "black"
end create
;
ianno = NhlAddAnnotation(infobox,txidcape)
setvalues ianno
  "amTrackData":      False
  "amZone":           1
  "amSide":           "top"
  "amJust":           "topleft"
  "amParallelPosF":    0.0
  "amOrthogonalPosF":  0.0
end setvalues
;
txidcin = create "TextItems" textItemClass wks
  "txFuncCode" : "~"
  "txString" : "CIN: "+cin+" J/kg"
  "txFontHeightF" : 0.012
  "txFontColor" : "black"
end create
;
ianno = NhlAddAnnotation(infobox,txidcin)
setvalues ianno
  "amTrackData":      False
  "amZone":           1
  "amSide":           "top"
  "amJust":           "topleft"
  "amParallelPosF":    0.0
  "amOrthogonalPosF":  0.06
end setvalues
;
txidmucape = create "TextItems" textItemClass wks
  "txFuncCode" : "~"
  "txString" : "MUCAPE: "+mucape+" J/kg"
  "txFontHeightF" : 0.012
  "txFontColor" : "black"
end create
;
ianno = NhlAddAnnotation(infobox,txidmucape)
setvalues ianno
  "amTrackData":      False
  "amZone":           1
  "amSide":           "top"
  "amJust":           "topleft"
  "amParallelPosF":    0.0
  "amOrthogonalPosF":  0.12
end setvalues
;
txidmucin = create "TextItems" textItemClass wks
  "txFuncCode" : "~"
  "txString" : "MUCIN: "+mucin+" J/kg"
  "txFontHeightF" : 0.012
  "txFontColor" : "black"
end create
;
ianno = NhlAddAnnotation(infobox,txidmucin)
setvalues ianno
  "amTrackData":      False
  "amZone":           1
  "amSide":           "top"
  "amJust":           "topleft"
  "amParallelPosF":    0.0
  "amOrthogonalPosF":  0.18
end setvalues
;
txidli = create "TextItems" textItemClass wks
  "txFuncCode" : "~"
  "txString" : "LI: "+li+" K"
  "txFontHeightF" : 0.012
  "txFontColor" : "black"
end create
;
ianno = NhlAddAnnotation(infobox,txidli)
setvalues ianno
  "amTrackData":      False
  "amZone":           1
  "amSide":           "top"
  "amJust":           "topleft"
  "amParallelPosF":    0.0
  "amOrthogonalPosF":  0.24
end setvalues
;
txidbli = create "TextItems" textItemClass wks
  "txFuncCode" : "~"
  "txString" : "BLI: "+bli+" K"
  "txFontHeightF" : 0.012
  "txFontColor" : "black"
end create
;
ianno = NhlAddAnnotation(infobox,txidbli)
setvalues ianno
  "amTrackData":      False
  "amZone":           1
  "amSide":           "top"
  "amJust":           "topleft"
  "amParallelPosF":    0.0
  "amOrthogonalPosF":  0.30
end setvalues
;
txidlcl = create "TextItems" textItemClass wks
  "txFuncCode" : "~"
  "txString" : "LCL: "+lcl+" m"
  "txFontHeightF" : 0.012
  "txFontColor" : "black"
end create
;
ianno = NhlAddAnnotation(infobox,txidlcl)
setvalues ianno
  "amTrackData":      False
  "amZone":           1
  "amSide":           "top"
  "amJust":           "topleft"
  "amParallelPosF":    0.0
  "amOrthogonalPosF":  0.36
end setvalues
;
txidlpl = create "TextItems" textItemClass wks
  "txFuncCode" : "~"
  "txString" : "LPL: "+lpl+" mb"
  "txFontHeightF" : 0.012
  "txFontColor" : "black"
end create
;
ianno = NhlAddAnnotation(infobox,txidlpl)
setvalues ianno
  "amTrackData":      False
  "amZone":           1
  "amSide":           "top"
  "amJust":           "topleft"
  "amParallelPosF":    0.0
  "amOrthogonalPosF":  0.42
end setvalues
;
txidsrh03 = create "TextItems" textItemClass wks
  "txFuncCode" : "~"
  "txString" : "SRH03: "+srh03+" m~S~2~N~/s~S~2~E~ "
  "txFontHeightF" : 0.012
  "txFontColor" : "black"
end create
;
ianno = NhlAddAnnotation(infobox,txidsrh03)
setvalues ianno
  "amTrackData":      False
  "amZone":           1
  "amSide":           "top"
  "amJust":           "topleft"
  "amParallelPosF":    0.0
  "amOrthogonalPosF":  0.47
end setvalues
;
txidsrh01 = create "TextItems" textItemClass wks
  "txFuncCode" : "~"
  "txString" : "SRH01: "+srh01+" m~S~2~N~/s~S~2~E~ "
  "txFontHeightF" : 0.012
  "txFontColor" : "black"
end create
;
ianno = NhlAddAnnotation(infobox,txidsrh01)
setvalues ianno
  "amTrackData":      False
  "amZone":           1
  "amSide":           "top"
  "amJust":           "topleft"
  "amParallelPosF":    0.0
  "amOrthogonalPosF":  0.53
end setvalues
;
txidshear06 = create "TextItems" textItemClass wks
  "txFuncCode" : "~"
  "txString" : "SHR06: "+shear06+" kt"
  "txFontHeightF" : 0.012
  "txFontColor" : "black"
end create
;
ianno = NhlAddAnnotation(infobox,txidshear06)
setvalues ianno
  "amTrackData":      False
  "amZone":           1
  "amSide":           "top"
  "amJust":           "topleft"
  "amParallelPosF":    0.0
  "amOrthogonalPosF":  0.6
end setvalues
;
txidshear01 = create "TextItems" textItemClass wks
  "txFuncCode" : "~"
  "txString" : "SHR01: "+shear01+" kt"
  "txFontHeightF" : 0.012
  "txFontColor" : "black"
end create
;
ianno = NhlAddAnnotation(infobox,txidshear01)
setvalues ianno
  "amTrackData":      False
  "amZone":           1
  "amSide":           "top"
  "amJust":           "topleft"
  "amParallelPosF":    0.0
  "amOrthogonalPosF":  0.66
end setvalues
;
txidcell = create "TextItems" textItemClass wks
  "txFuncCode" : "~"
  "txString" : "CELL: "+SMdir_string+"/"+SMspd+" kt"
  "txFontHeightF" : 0.012
  "txFontColor" : "black"
end create
;
ianno = NhlAddAnnotation(infobox,txidcell)
setvalues ianno
  "amTrackData":      False
  "amZone":           1
  "amSide":           "top"
  "amJust":           "topleft"
  "amParallelPosF":    0.0
  "amOrthogonalPosF":  0.72
end setvalues
;
txidpw = create "TextItems" textItemClass wks
  "txFuncCode" : "~"
  "txString" : "PW: "+pw+" mm"
  "txFontHeightF" : 0.012
  "txFontColor" : "black"
end create
;
ianno = NhlAddAnnotation(infobox,txidpw)
setvalues ianno
  "amTrackData":      False
  "amZone":           1
  "amSide":           "top"
  "amJust":           "topleft"
  "amParallelPosF":    0.0
  "amOrthogonalPosF":  0.78
end setvalues
;
txidrhpw = create "TextItems" textItemClass wks
  "txFuncCode" : "~"
  "txString" : "RHPW: "+rhpw+"%"
  "txFontHeightF" : 0.012
  "txFontColor" : "black"
end create
;
ianno = NhlAddAnnotation(infobox,txidrhpw)
setvalues ianno
  "amTrackData":      False
  "amZone":           1
  "amSide":           "top"
  "amJust":           "topleft"
  "amParallelPosF":    0.0
  "amOrthogonalPosF":  0.84
end setvalues
;
draw(infobox)
;
; Draw the hodograph on the sounding
;
hodores = True
hodores@gsnDraw  = False
hodores@gsnFrame = False
;
hodo1 = plot_hodo(wks, u1, v1, z1, ust, vst, hodores)
;
setvalues hodo1
  "vpXF" : 0.07
  "vpYF" : 0.925
  "vpWidthF" : 0.27
  "vpHeightF" : 0.27
end setvalues
;
draw(hodo1)
;
frame(wks)
;
end do ; end of do ii loop
;
end
