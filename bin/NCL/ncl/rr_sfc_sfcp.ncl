load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl";
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCL_HOME/obj/plot_titles_hrrr.ncl"
load "./names_grib2.txt"
;
load "$NCL_HOME/obj/cmap1_dbl2.ncl"
;
begin
;
airport_id = asciiread("Airports_id.txt",-1,"string")
airport_loc = asciiread("Airports_locs.txt",(/dimsizes(airport_id),2/),"float")
;
fname = asciiread("arw_file.txt",-1,"string")
grb_file = addfile(fname,"r")
;
hr3sizes = filevardimsizes(grb_file,LATNAME)
ny = hr3sizes(0)
nx = hr3sizes(1)
;
intm = grb_file->$T2MNAME$@initial_time
fctm = grb_file->$T2MNAME$@forecast_time
lat = grb_file->$LATNAME$(:,:)
lon = grb_file->$LONNAME$(:,:)
latin1 = grb_file->$LONNAME$@Latin1
latin2 = grb_file->$LONNAME$@Latin2
lov = grb_file->$LONNAME$@Lov
;
tvar = grb_file->$PSFCNAME$(:,:) / 100 ; convert to mb
;
load "$NCL_HOME/obj/get_date_str.ncl"
;
print(date_str) 
print("surface pressure")
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
           "wkMetaName" : "./sfc_sfcp.ncgm"
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
           "wkPSFileName" : "./sfc_sfcp.ps"
          end create
        end if
      end if
    end if
;
; Assign the colormap to the workstation.
setvalues wid
;   "wkColorMap" : gen_colormap()
;   "wkColorMap" : "wh-bl-gr-ye-re"
   "wkColorMap" : "BkBlAqGrYeOrReViWh200"
   "wkForegroundColor" : "white"
   "wkBackgroundColor" : "black"
end setvalues
;
getvalues wid
   "wkColorMapLen" : len
end getvalues
;
; Add grayscale to low end
NhlSetColor(wid,2,1.00,1.00,1.00)
NhlSetColor(wid,3,0.94,0.94,0.94)
NhlSetColor(wid,4,0.88,0.88,0.88)
NhlSetColor(wid,5,0.82,0.82,0.82)
NhlSetColor(wid,6,0.76,0.76,0.76)
NhlSetColor(wid,7,0.70,0.70,0.70)
NhlSetColor(wid,8,0.64,0.64,0.64)
NhlSetColor(wid,9,0.58,0.58,0.58)
NhlSetColor(wid,10,0.52,0.52,0.52)
NhlSetColor(wid,11,0.46,0.46,0.46)
NhlSetColor(wid,12,0.40,0.40,0.40)
NhlSetColor(wid,13,0.34,0.34,0.34)
NhlSetColor(wid,14,0.28,0.28,0.28)
NhlSetColor(wid,15,0.22,0.22,0.22)
;
; Add airport color at end
NhlSetColor(wid,len,0.32,0.32,0.32)
;
; ilevs = ispan(4,200,4)
ilevsa = ispan(2,52,1)
ilevsb = ispan(86,104,1)
ilevs1 = array_append_record(ilevsa,ilevsb,0)
ilevsc = ispan(110,150,2)
ilevsd = ispan(172,201,2)
ilevs1a = array_append_record(ilevsc,ilevsd,0)
; ;ilevsb = ilevsb(::-1)
ilevs2 = array_append_record(ilevs1,ilevs1a,0) ; used for contour levels
;
setvalues NhlGetWorkspaceObjectId()
   "wsMaximumSize": 247108864
end setvalues
;
load "$NCL_HOME/obj/hrrr_tiles_loop.ncl"
;
load "$NCL_HOME/obj/hrrr_map_blk_counties_blk.ncl"
;
if (iq .ne. 0) then
  setvalues mpid
    "mpDataBaseVersion" : "Ncarg4_1"
    "mpDataSetName" : "Earth..2"
    "mpUSStateLineThicknessF" : 2
    "mpCountyLineColor" : "background"
  end setvalues
end if
;
; Create a ScalarField object.
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
; Create a ContourPlot object.
;
; Precipitable Water
;
load "$NCL_HOME/obj/sfcp.ncl"
;
setvalues cnid
;
    "cnMinLevelValF" : 650
    "cnMaxLevelValF" : 1050
    "cnLevelSpacingF" : 4
    "cnFillColors" : ilevs2
    "cnLevelSelectionMode" : "ManualLevels"
    "cnFillOn" : True
    "cnLinesOn" : False
    "cnLineLabelsOn" : False
    "cnInfoLabelOn" : False
    "cnRasterModeOn" : True
    "pmTickMarkDisplayMode" : "NoCreate"
    "pmLabelBarDisplayMode" : "ALWAYS"
    "pmLabelBarHeightF" : .05
    "pmLabelBarWidthF" : 0.9
    "pmLabelBarSide" : "bottom"
    "pmLabelBarOrthogonalPosF" : 0.0
    "lbAutoManage" : False
    "lbOrientation" : "horizontal"
    "lbLabelFontHeightF" : 0.01
    "lbLabelStride" : 5
    "lbTitleFont" : 22
    "lbPerimOn" : False
    "lbBoxLinesOn" : 0
;
end setvalues
;
if (iq .ge. 8) then
  setvalues cnid
;    "cnFillMode" : "AreaFill"
    "cnRasterSmoothingOn" : True
  end setvalues
end if
;
titlestring = "Surface Pressure (mb)"
load "$NCL_HOME/obj/add_titles_rr.ncl"
;
; Draw map
;
draw(cnid)
draw(mpid)
;
gsres = True
;
if (iq .eq. 0) then
  do i = 0,dimsizes(airport_id)-1
    gsres@gsMarkerIndex = 16
    gsres@gsMarkerColor = len
    gsres@gsMarkerSizeF = 0.004
    gsn_polymarker(wid,mpid,airport_loc(i,1),airport_loc(i,0),gsres)
    gsres@gsMarkerIndex = 16
    gsres@gsMarkerColor = 1
    gsres@gsMarkerSizeF = 0.002
    gsn_polymarker(wid,mpid,airport_loc(i,1),airport_loc(i,0),gsres)
  end do
else
  do i = 0,dimsizes(airport_id)-1
    gsres@gsMarkerIndex = 16
    gsres@gsMarkerColor = len
    gsres@gsMarkerSizeF = 0.01
    gsn_polymarker(wid,mpid,airport_loc(i,1),airport_loc(i,0),gsres)
    gsres@gsMarkerIndex = 16
    gsres@gsMarkerColor = 1
    gsres@gsMarkerSizeF = 0.005
    gsn_polymarker(wid,mpid,airport_loc(i,1),airport_loc(i,0),gsres)
  end do
end if
;
frame(wid)
;
end do
;
end

