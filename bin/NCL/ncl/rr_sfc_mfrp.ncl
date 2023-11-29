load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl";
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCL_HOME/obj/plot_titles_hrrr.ncl"
load "./names_wrfout.txt"
;
load "$NCL_HOME/obj/cmap1b.ncl"
;
begin
;
fname = asciiread("cdf_file.txt",-1,"string") 
cdf_file = addfile(fname,"r")
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
tvar = cdf_file->$MFRPNAME$(0,:,:)
tvar = where(tvar.eq.0, -0.0001, tvar)
tvarsave = tvar
;
print(date_str)
print("mfrp")
print(min(tvar))
print(max(tvar))
if (min(tvar) .eq. -0.0001 .and. max(tvar) .eq. -0.0001) then ; constant field, no fires
  print("constant field - exiting")
  exit
end if
;
; Create an application object.
;
appid = create "mdss" appClass defaultapp
    "appUsrDir" : "./"
    "appDefaultParent" : True
end create
;
load "$NCL_HOME/obj/set_png_wks_hrrr.ncl"
wid = gsn_open_wks(wks_type,"sfc_mfrp")
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
    "sfMissingValueV" : tvar@_FillValue
end create
;
; Create ContourPlot objects.
;
load "$NCL_HOME/obj/pwtr.ncl"
;
setvalues cnid
;    "cnFillColors" : (/ 14,20,13,11,9,7,5 /)
    "cnFillColors" : (/ 2,35,73,102,178,204,230 /)
    "cnLevels" : (/ 0,10,25,50,100,250 /)
    "lbAutoManage" : False
    "lbLabelFontHeightF" : 0.02
    "lbFillColors" : (/ 2,35,73,102,178,204,230 /) 
end setvalues
;
titlestring = "Fire Radiative Power (MW)" 
load "$NCL_HOME/obj/add_titles_rr.ncl"
NhlRemoveAnnotation(cnid,ianno)
NhlRemoveAnnotation(cnid,ianno2)
txid = create "TextItems" textItemClass wid
  "txFuncCode" : "~"
  "txString" : modl+intm+" - EXPERIMENTAL"
  "txFont" : 22
  "txFontHeightF" : 0.015
  "txFontColor" : 1
end create
ianno = NhlAddAnnotation(cnid,txid)
setvalues ianno
  "amZone":           10
  "amSide":           "top"
  "amJust":           "bottomleft"
  "amParallelPosF":    0.0
  "amOrthogonalPosF":  opos
end setvalues
;
; Draw map
;
draw(cnid)
draw(mpid)
;
gsres = True
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
; Plot a dot at frp locations
;
do j = 0,ny-1
  do i = 0,nx-1
    if (iq .eq. 0) then
      if (tvar(j,i) .gt. 0 .and. tvar(j,i) .le. 10) then
        gsres@gsMarkerIndex = 16
        gsres@gsMarkerColor = 35
        gsres@gsMarkerSizeF = 0.004
        gsn_polymarker(wid,mpid,lon(j,i),lat(j,i),gsres)
      end if
      if (tvar(j,i) .gt. 10 .and. tvar(j,i) .le. 25) then
        gsres@gsMarkerIndex = 16
        gsres@gsMarkerColor = 73
        gsres@gsMarkerSizeF = 0.004
        gsn_polymarker(wid,mpid,lon(j,i),lat(j,i),gsres)
      end if
      if (tvar(j,i) .gt. 25 .and. tvar(j,i) .le. 50) then
        gsres@gsMarkerIndex = 16
        gsres@gsMarkerColor = 102
        gsres@gsMarkerSizeF = 0.004
        gsn_polymarker(wid,mpid,lon(j,i),lat(j,i),gsres)
      end if
      if (tvar(j,i) .gt. 50 .and. tvar(j,i) .le. 100) then
        gsres@gsMarkerIndex = 16
        gsres@gsMarkerColor = 178
        gsres@gsMarkerSizeF = 0.004
        gsn_polymarker(wid,mpid,lon(j,i),lat(j,i),gsres)
      end if
      if (tvar(j,i) .gt. 100 .and. tvar(j,i) .le. 250) then
        gsres@gsMarkerIndex = 16
        gsres@gsMarkerColor = 204
        gsres@gsMarkerSizeF = 0.004
        gsn_polymarker(wid,mpid,lon(j,i),lat(j,i),gsres)
      end if
      if (tvar(j,i) .gt. 250) then
        gsres@gsMarkerIndex = 16
        gsres@gsMarkerColor = 230
        gsres@gsMarkerSizeF = 0.004
        gsn_polymarker(wid,mpid,lon(j,i),lat(j,i),gsres)
      end if
    else
      if (tvar(j,i) .gt. 0 .and. tvar(j,i) .le. 10) then
        gsres@gsMarkerIndex = 16
        gsres@gsMarkerColor = 35
        gsres@gsMarkerSizeF = 0.005
        gsn_polymarker(wid,mpid,lon(j,i),lat(j,i),gsres)
      end if
      if (tvar(j,i) .gt. 10 .and. tvar(j,i) .le. 25) then
        gsres@gsMarkerIndex = 16
        gsres@gsMarkerColor = 73
        gsres@gsMarkerSizeF = 0.005
        gsn_polymarker(wid,mpid,lon(j,i),lat(j,i),gsres)
      end if
      if (tvar(j,i) .gt. 25 .and. tvar(j,i) .le. 50) then
        gsres@gsMarkerIndex = 16
        gsres@gsMarkerColor = 102
        gsres@gsMarkerSizeF = 0.005
        gsn_polymarker(wid,mpid,lon(j,i),lat(j,i),gsres)
      end if
      if (tvar(j,i) .gt. 50 .and. tvar(j,i) .le. 100) then
        gsres@gsMarkerIndex = 16
        gsres@gsMarkerColor = 178
        gsres@gsMarkerSizeF = 0.005
        gsn_polymarker(wid,mpid,lon(j,i),lat(j,i),gsres)
      end if
      if (tvar(j,i) .gt. 100 .and. tvar(j,i) .le. 250) then
        gsres@gsMarkerIndex = 16
        gsres@gsMarkerColor = 204
        gsres@gsMarkerSizeF = 0.005
        gsn_polymarker(wid,mpid,lon(j,i),lat(j,i),gsres)
      end if
      if (tvar(j,i) .gt. 250) then
        gsres@gsMarkerIndex = 16
        gsres@gsMarkerColor = 230
        gsres@gsMarkerSizeF = 0.005
        gsn_polymarker(wid,mpid,lon(j,i),lat(j,i),gsres)
      end if
    end if
  end do
end do
;
frame(wid)
;
end do  ; loop starts in hrrr_tiles_loop.ncl
;
imprefix = "sfc_mfrp"
;load "$NCL_HOME/obj/add_noaa_logo.ncl"
;
end

