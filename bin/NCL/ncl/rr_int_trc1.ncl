load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl";
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCL_HOME/obj/plot_titles_hrrr.ncl"
load "./names_wrfout.txt"
;
begin
;
fname = asciiread("cdf_file.txt",-1,"string")
cdf_file = addfile(fname,"r")
;
fname2 = asciiread("nat_file.txt",-1,"string")
nat_file = addfile(fname2,"r")
;
sd = cdf_file@$STARTDATENAME$
fc = cdf_file->Times
fcst_date = str_concat(fc)
;
load "$NCL_HOME/obj/get_date_str_wrfout.ncl"
;
hr3sizes = filevardimsizes(cdf_file,LATNAME)
ny = hr3sizes(1)
nx = hr3sizes(2)
;
lat = cdf_file->$LATNAME$(0,:,:)
lon = cdf_file->$LONNAME$(0,:,:)
latin1 = cdf_file@$LATIN1NAME$
latin2 = cdf_file@$LATIN2NAME$
lov = cdf_file@$CENLONNAME$
;
mfrp = cdf_file->$MFRPNAME$(0,:,:)
mfrp = where(mfrp.eq.0, -0.0001, mfrp)
;
if (min(mfrp) .eq. -0.0001 .and. max(mfrp) .eq. -0.0001) then ; constant field, no fires
  print("constant field - exiting")
  exit
end if
delete(mfrp)
;
hybhgt = cdf_file->$GHHYBNAME$(0,:,:,:) / 9.8  ; convert geopotential to geopotential height
trcr = cdf_file->$TRACER1HYBNAME$(0,:,:,:)
hybtemp = nat_file->$TMPHYBNAME$(:,:,:)
hybpres = nat_file->$PRESHYBNAME$(:,:,:)
dens = (1./287.)*(hybpres/hybtemp)
;dens = cdf_file->$DENSHYBNAME$(0,:,:,:)
;
numhyblevs = getfilevardimsizes(cdf_file,TRACER1HYBNAME)
tvar = lat * 0.
tvartmp = lat * 0.
dz = lat * 0.
lasthgt = lat * 0.
do ihlev = 1,numhyblevs(1)-1
  tvartmp = 0.
  tvartmp = trcr(ihlev,:,:) * dens(ihlev,:,:)
  dz = hybhgt(ihlev,:,:) - hybhgt(ihlev-1,:,:)
  tvar = tvar + (tvartmp * dz)
  lasthgt = hybhgt(ihlev,:,:)
end do
;tvar = tvar / (lasthgt - hybhgt(0,:,:))
;;
;;    if (tvar(jj,ii) .lt. 1.) then
;;      tvar(jj,ii) = 1.
;;    end if
;;
;;tvar = log10(tvar) * 100.
;tvar = tvar * 1000000.
tvar = tvar / 1000.  ; convert to mg
tvarsave = tvar
;
load "$NCL_HOME/obj/get_date_str_wrfout.ncl"
;
print(date_str)
print("integrated tracer 1")
print(min(tvar))
print(max(tvar))
;
; Create an application object.
;
appid = create "mdss" appClass defaultapp
    "appUsrDir" : "./"
    "appDefaultParent" : True
end create
;
load "$NCL_HOME/obj/set_png_wks_hrrr.ncl"
wid = gsn_open_wks(wks_type,"int_trc1")
;
; Assign the colormap to the workstation.
;
;setvalues wid
;   "wkColorMap" : gen_colormap()
;end setvalues
setvalues wid
   "wkColorMap" : "WhiteBlueGreenYellowRed"
   "wkBackgroundColor" : "black"
   "wkForegroundColor" : "white"
end setvalues
NhlSetColor(wid,255,0.55,0.14,0.80)
;
setvalues NhlGetWorkspaceObjectId()
   "wsMaximumSize": 247108864
end setvalues
;
load "$NCL_HOME/obj/hrrr_smoke_tiles_loop.ncl"
;
tvar = tvarsave
if ( max(tvar(lly:ury,llx:urx)) .le. 0.01 ) then  ; set the corner pt to avoid a constant field plot
  tvar(lly,llx) = 0.02
end if
;
load "$NCL_HOME/obj/hrrr_map_blk_counties_blk.ncl"
;
if (iq .eq. 16) then
  setvalues mpid
    "mpCountyLineColor" : 0
  end setvalues
end if
;
; Create ScalarField objects.
;
tfield = create "ScalarField" scalarFieldClass appid
    "sfDataArray" : tvar
    "sfXCStartSubsetV" : llx
    "sfYCStartSubsetV" : lly
    "sfXCEndSubsetV" : urx
    "sfYCEndSubsetV" : ury
;    "sfMissingValueV" : tvar@_FillValue
end create
;
; Create ContourPlot objects.
;
load "$NCL_HOME/obj/pwtr.ncl"
;
setvalues cnid
;    "cnFillColors" : (/ 14,20,13,12,11,10,9,8,7,6,5,4,3,2,21,22,23,24 /)
;    "cnLevels" : (/ 2,4,8,12,16,20,24,28,32,36,40,44,48,52,56,60,64 /)
;    "cnFillColors" : (/ 2,17,32,47,62,77,92,107,122,137,152,167,182,197,212,227,242,255 /)
;    "cnLevels" : (/ 4,10,16,22,28,34,40,46,52,58,64,70,76,82,88,94,100 /)
    "cnFillColors" : (/ 2,21,40,59,78,97,116,135,154,173,192,211,230,249,255 /)
    "cnLevels" : (/ 2,5,8,11,15,20,25,30,40,50,75,150,250,500 /)
end setvalues
;
;titlestring = "Integral fire PM2.5 (~F33~m~F22~g/m~S~2~N~)"
;titlestring = "Integral fire PM2.5 (mg/m~S~2~N~)"
titlestring = "Vertically Integrated Smoke (mg/m~S~2~N~)"
load "$NCL_HOME/obj/add_titles_rr.ncl"
;
; Draw map
;
draw(cnid)
draw(mpid)
;
; Plot airports
;
;gsres = True
;if (iq .eq. 0) then
;  do i = 0,dimsizes(airport_id)-1
;    gsres@gsMarkerIndex = 16
;    gsres@gsMarkerColor = 20
;    gsres@gsMarkerSizeF = 0.004
;    gsn_polymarker(wid,mpid,airport_loc(i,1),airport_loc(i,0),gsres)
;    gsres@gsMarkerIndex = 16
;    gsres@gsMarkerColor = 1
;    gsres@gsMarkerSizeF = 0.002
;    gsn_polymarker(wid,mpid,airport_loc(i,1),airport_loc(i,0),gsres)
;  end do
;else
;  do i = 0,dimsizes(airport_id)-1
;    gsres@gsMarkerIndex = 16
;    gsres@gsMarkerColor = 20
;    gsres@gsMarkerSizeF = 0.01
;    gsn_polymarker(wid,mpid,airport_loc(i,1),airport_loc(i,0),gsres)
;    gsres@gsMarkerIndex = 16
;    gsres@gsMarkerColor = 1
;    gsres@gsMarkerSizeF = 0.005
;    gsn_polymarker(wid,mpid,airport_loc(i,1),airport_loc(i,0),gsres)
;  end do
;end if
;
frame(wid)
;
end do  ; loop starts in hrrr_tiles_loop.ncl
;
imprefix = "int_trc1"
;load "$NCL_HOME/obj/add_noaa_logo.ncl"
;
end

