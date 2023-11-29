load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCL_HOME/obj/plot_titles_hrrr.ncl"
load "./names_grib2.txt"
;
load "$NCL_HOME/obj/cmap1_dbl.ncl"
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
if (fctm .eq. 0) then
  exit
end if
;
if (fctm .eq. 1) then
  wind = grb_file->$MAXDNWINDNAME$(:,:); * 1.9429 ; convert to knots
else
  wind = grb_file->$MAXDNWIND1HNAME$(:,:); * 1.9429 ; convert to knots
end if
;
load "$NCL_HOME/obj/get_date_str.ncl"
;
print(date_str)
print("max downdraft")
print(min(wind))
print(max(wind))
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
           "wkMetaName" : "./mdn_wind.ncgm"
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
           "wkPSFileName" : "./mdn_wind.ps"
          end create
        end if
      end if
    end if
;
; Assign the colormap to the workstation.
setvalues wid
;   "wkColorMap" : gen_colormap()
   "wkColorMap" : "amwg"
   "wkBackgroundColor" : "black"
   "wkForegroundColor" : "white"
end setvalues
;
setvalues NhlGetWorkspaceObjectId()
   "wsMaximumSize": 247108864
end setvalues
;
load "$NCL_HOME/obj/hrrr_tiles_loop.ncl"
;
load "$NCL_HOME/obj/hrrr_map_blk_counties_blk.ncl"
;
; Create a ScalarField object.
;
tfield = create "ScalarField" scalarFieldClass appid
    "sfDataArray" : wind
    "sfXCStartSubsetV" : llx
    "sfYCStartSubsetV" : lly
    "sfXCEndSubsetV" : urx
    "sfYCEndSubsetV" : ury
    "sfMissingValueV" : wind@_FillValue
end create
;
; Create a ContourPlot object.
;
load "$NCL_HOME/obj/mdn.ncl"
;
if (iq .ge. 8) then
  setvalues cnid
    "cnFillMode" : "AreaFill"
  end setvalues
end if
;
lbid = create "LabelBar" labelBarClass wid
    "lbOrientation" : "Horizontal"
    "lbAutoManage" : False
    "lbLabelFont" : 0
    "lbLabelFontHeightF" : .01
    "lbPerimOn" : False
    "lbBoxCount" : 19
    "lbBoxLinesOn" : False
    "lbLabelFontColor" : "white"
    "lbMonoFillPattern" : True
    "lbFillPattern" : "SolidFill"
;    "lbFillColors" : (/ 0,1,3,4,5,6,7,8,9,10,11,12,13,21,22,2,3,4,5,6 /)
;    "lbFillColors" : (/ 0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19 /)
    "lbFillColors" : (/ 0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,0 /)
;    "lbLabelStrings" : (/ "0","-2.5","-5","-7.5","-10","-12.5","-15","-17.5", \
;                          "-20","-22.5","-25","-27.5","-30","-32.5","-35","-37.5", \
;                          "-40","-42.5","-45" /)
    "lbLabelStrings" : (/ "0","-.5","-1","-1.5","-2","-2.5","-5","-7.5", \
                          "-10","-12.5","-15","-17.5","-20","-22.5","-25","-30", \
                          "-35","-40" /)
    "lbLabelAlignment" : "InteriorEdges"
;    "lbLabelStride" : 2
    "vpXF"      : vpx 
    "vpYF"      : (vpy - vpheight) + 0.005
    "vpWidthF"  : vpwidth
    "vpHeightF" : 0.055
end create
;
titlestring = "Max Downdraft Velocity (over previous hour) (m/s)"
load "$NCL_HOME/obj/add_titles_rr.ncl"
;
; Draw map
;
draw(cnid)
draw(mpid)
draw(lbid)
;
getvalues(wid)
  "wkColorMapLen" : len
end getvalues
;
NhlSetColor(wid,len,.392,.392,.392)
gsres = True
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
