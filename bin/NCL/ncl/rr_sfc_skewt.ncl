load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
;load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/skewt_func.ncl"
load "skewt_func.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
load "names_grib2.txt"
;
; Open GRIB file
;
fname = asciiread("arw_file.txt",-1,"string")
grb_file = addfile(fname,"r")
;
; Change GRIB vertical level type here (p for pressure or n for native)
;
LEVELS="n"
;
; Change output file path/name here without filename extension
;
OUTFILENAME="sfc_skewt"
;
; Get lat/lon sounding points
;
countstations = asciiread("conus_raobs.txt",-1,"string")
numstations = dimsizes(countstations)
stations = asciiread("conus_raobs.txt",numstations,"string")
raob_id = new(numstations,"string")
raob_wban = new(numstations,"integer")
raob_wmo = new(numstations,"integer")
raob_lat = new(numstations,"float")
raob_lon = new(numstations,"float")
raob_elev = new(numstations,"integer")
do iraob = 0,numstations-1
  station_parts = str_split(stations(iraob)," ")
  raob_id(iraob) = station_parts(0)
  raob_wban(iraob) = tointeger(station_parts(1))
  raob_wmo(iraob) = tointeger(station_parts(2))
  raob_lat(iraob) = tofloat(station_parts(3))
  raob_lon(iraob) = tofloat(station_parts(4))
  raob_lon(iraob) = -raob_lon(iraob)
  raob_elev(iraob) = tointeger(station_parts(5))
  print(raob_id(iraob))
  print(raob_lat(iraob))
  print(raob_lon(iraob))
end do
;
begin
;
; Change GRIB vertical level type here (p for pressure or n for native)
;
LEVELS="n"
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
; Set SkewT background options
;
skewtOpts                  		= True
;
; Resources for title text
;
skewtOpts@tiMainFont			= 22
skewtOpts@tiMainFontHeightF		= 0.015
;
; Resources for skewT background
;
skewtOpts@DrawColAreaFill  		= True
skewtOpts@DrawHeightScale  		= True
skewtOpts@DrawHeightScaleFt 		= False
skewtOpts@DrawFahrenheit    		= True
;
; Resources for workstation
;
skewtOpts@wkBackgroundColor		= "white"
skewtOpts@wkForegroundColor		= "black"
;
; Set SkewT data options 
;
dataOpts 				= True
dataOpts@ThermoInfo       		= True
dataOpts@PrintZ				= False
;
; Resources for output filetype and resolution
;
;wkstype				= "pdf"
;wkstype				= "png"
wkstype					= "ncgm"
wkstype@wkWidth				= 1280
wkstype@wkHeight			= 960
;
; Resources for workstation colors
;
wkstype@wkBackgroundColor		= "white"
wkstype@wkForegroundColor		= "black"
;  
;
; Open output file
;
wks = gsn_open_wks(wkstype, OUTFILENAME)
gsn_define_colormap(wks, "radar_1")
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
RAOBLAT= raob_lat(ii)
RAOBLON= raob_lon(ii)
;
; Get the closest grid point for the lat/lon point
;
gridpts1 = wrf_latlon_to_ij(lat, lon, RAOBLAT, RAOBLON)
i1 = gridpts1(0)
j1 = gridpts1(1)
;
; Get fields from file for either pressure or natural coordinate grids
;
if(LEVELS.ne."n") then
  tk1 = grb_file->$TNAME$(:,i1,j1)
  tdk1 = grb_file->$DPTNAME$(:,i1,j1)
  press1 = grb_file->$NUMPLEVS$(:)
  press1 = 100*press1
  z1 = grb_file->$GHNAME$(:,i1,j1)
  uwrf1 = grb_file->$UNAME$(:,:,:)
  vwrf1 = grb_file->$VNAME$(:,:,:)
else
  tk1 = grb_file->$TMPNATNAME$(:,i1,j1)
  sh1 = grb_file->$SPFHNATNAME$(:,i1,j1)
  qvapor1 = sh1/(1 - sh1)
  press1 = grb_file->$PRESNATNAME$(:,i1,j1)
  tdk1 = wrf_td(press1, qvapor1) + 273.15
  z1 = grb_file->$GHNATNAME$(:,i1,j1)
  uwrf1 = grb_file->$UNATNAME$(:,:,:)
  vwrf1 = grb_file->$VNATNAME$(:,:,:)
end if
;
; Calculate earth-relative wind
;
uvmet1 = wrf_uvmet(uwrf1, vwrf1, lat, lon, lat@Lov, 0)
u1 = uvmet1(0,:,i1,j1)
v1 = uvmet1(1,:,i1,j1)
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
Uspd1 = 1.94384449*sqrt(u1*u1 + v1*v1)
Udir1 = atan2(u1, v1) * r2d + 180.0
;
; Change title here or leave blank
;
TITLE4=intm+" "+fctm+" hr fcst, "+raob_id(ii)+" Lat: "+lat(i1,j1)+" Lon: "+lon(i1,j1)
;
; Plot sounding background
skewtOpts@tiMainString     		= TITLE4
skewt_bkgd = skewT_BackGround(wks, skewtOpts)
draw(skewt_bkgd)
;
; Resources for the sounding
;
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
frame(wks)
;
end do ; end of do ii loop
;
end
