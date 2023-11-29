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
;print("mfrp")
;print(min(mfrp))
;print(max(mfrp))
if (min(mfrp) .eq. -0.0001 .and. max(mfrp) .eq. -0.0001) then ; constant field, no fires
  print("constant field - exiting")
  exit
end if
delete(mfrp)
;
trcr = cdf_file->$TRACER1HYBNAME$(0,0,:,:)
tvar = trcr
hybtemp = nat_file->$TMPHYBNAME$(0,:,:)
hybpres = nat_file->$PRESHYBNAME$(0,:,:)
dens = (1./287.)*(hybpres/hybtemp)
;dens = cdf_file->$DENSHYBNAME$(0,0,:,:)
tvar = trcr * dens
;
;tvar = log10(tvar) * 100.
tvarsave = tvar
;
uvar = cdf_file->$U10MNAME$(0,:,:) * 1.9429 ; convert to knots
vvar = cdf_file->$V10MNAME$(0,:,:) * 1.9429 ; convert to knots
;
print(date_str)
print("tracer 1")
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
wid = gsn_open_wks(wks_type,"sfc_trc1")
;
; Assign the colormap to the workstation.
;
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
if ( max(tvar(lly:ury,llx:urx)) .le. 4 ) then  ; set the corner pt to avoid a constant field plot
  tvar(lly,llx) = 5
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
; Create a VectorField object.
;
vfield = create "VectorField" vectorFieldClass appid
    "vfUDataArray" : uvar
    "vfVDataArray" : vvar
    "vfXCStartSubsetV" : llx
    "vfYCStartSubsetV" : lly
    "vfXCEndSubsetV" : urx
    "vfYCEndSubsetV" : ury
;    "vfMissingVValueV" : vvar@_FillValue
;    "vfMissingUValueV" : uvar@_FillValue
    "vfXCStride" : wstride        ; i.e., plot a vector at every (n+1)th point.
    "vfYCStride" : wstride
end create
;
; Create a VectorPlot object.
;
vcid = create "vectorplot" vectorPlotClass wid
    "vcVectorFieldData":  vfield
    "vcGlyphStyle" : "WindBarb"
;    "vcWindBarbLineThicknessF" : 1.2
    "vcWindBarbColor" : 0
;    "vcWindBarbTickSpacingF" : 0.1875
    "vcRefAnnoOn" : False
    "pmTickMarkDisplayMode" : "NoCreate"
    "vpXF"      : vpx        ; set viewport
    "vpYF"      : vpy
    "vpWidthF"  : vpwidth
    "vpHeightF" : vpheight
end create
;
setvalues vcid
  "vcMinMagnitudeF" : 0
end setvalues
;
; Create ContourPlot objects.
;
load "$NCL_HOME/obj/pwtr.ncl"
;
setvalues cnid
    "cnFillColors" : (/ 2,21,40,59,78,97,116,135,154,173,192,211,230,249,255 /)
    "cnLevels" : (/ 1,2,4,6,8,12,16,20,25,30,40,60,100,200 /)
    "lbAutoManage" : False
    "lbLabelFontHeightF" : 0.02
end setvalues
;
titlestring = "Near-Surface Smoke (~F33~m~F22~g/m~S~3~N~ ), 10m Wind (kt)"
load "$NCL_HOME/obj/add_titles_rr.ncl"
;
; Draw map
;
draw(cnid)
draw(mpid)
draw(vcid)
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
imprefix = "sfc_trc1"
;load "$NCL_HOME/obj/add_noaa_logo.ncl"
;
end

