load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl";
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
load "$NCL_HOME/obj/plot_titles_hrrr.ncl"
load "./names_grib2.txt"
;
load "$NCL_HOME/obj/cmap1_esbl.ncl"
;load "$NCL_HOME/obj/cmap1_track.ncl"
;
begin
;
airport_id = asciiread("Airports_id.txt",-1,"string")
airport_loc = asciiread("Airports_locs.txt",(/dimsizes(airport_id),2/),"float")
;
fname = asciiread("arw_file.txt",-1,"string") 
grb_file = addfile(fname,"r")
;
check = ""
check = systemfunc("ls back1_file.txt") 
fnameback1test = 0
fnameback2test = 0
if (.not.ismissing(check.eq."back1_file.txt")) then 
   fnameback1 = asciiread("back1_file.txt",-1,"string")
   back1exists = isfilepresent(fnameback1)
   if (back1exists) then
     print("reading "+fnameback1)
     fnameback1test = 1
     grb_file_back1 = addfile(fnameback1,"r")
   else
     print("error - missing file "+fnameback1)
   end if
end if 
check2 = ""
check2 = systemfunc("ls back2_file.txt") 
if (.not.ismissing(check2.eq."back2_file.txt")) then 
   fnameback2 = asciiread("back2_file.txt",-1,"string")
   back2exists = isfilepresent(fnameback2)
   if (back2exists) then
     print("reading "+fnameback2)
     fnameback2test = 1
     grb_file_back2 = addfile(fnameback2,"r")
   else
     print("error - missing file "+fnameback2)
   end if
end if 
;
if (fnameback1test .eq. 1) then
  print("fnameback1 ="+fnameback1)
  intmback1 = grb_file_back1->$T2MNAME$@initial_time
  fctmback1 = grb_file_back1->$T2MNAME$@forecast_time
else
  intmback1 = -999
  fctmback1 = -999
end if
if (fnameback2test .eq. 1) then
  print("fnameback2 = "+fnameback2)
  intmback2 = grb_file_back2->$T2MNAME$@initial_time
  fctmback2 = grb_file_back2->$T2MNAME$@forecast_time
else
  intmback2 = -999
  fctmback2 = -999
end if
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
;if (fctm .eq. 0) then
;  exit
;end if
;
if (fctm .le. 1) then
  tvar = grb_file->$HLCYNAME$(0,:,:)  ; updraft helicity
else
  tvar = grb_file->$HLCY1HNAME$(0,:,:)  ; updraft helicity
end if
if (fnameback1test .eq. 1) then
  if (fctmback1 .le. 1) then
    tvarback1 = grb_file_back1->$HLCYNAME$(0,:,:)
  else
    tvarback1 = grb_file_back1->$HLCY1HNAME$(0,:,:)
  end if
end if
if (fnameback2test .eq. 1) then
  if (fctmback2 .le. 1) then
    tvarback2 = grb_file_back2->$HLCYNAME$(0,:,:)
  else
    tvarback2 = grb_file_back2->$HLCY1HNAME$(0,:,:)
  end if
end if
uvar = grb_file->$USHRNAME$(0,:,:) * 1.9429 ; convert to knots
vvar = grb_file->$VSHRNAME$(0,:,:) * 1.9429 ; convert to knots
;
load "$NCL_HOME/obj/get_date_str.ncl"
;
print(date_str)
print("Max Updraft Helicity")
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
           "wkMetaName" : "./esbl_hlcy.ncgm"
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
           "wkPSFileName" : "./esbl_hlcy.ps"
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
load "$NCL_HOME/obj/hrrr_tiles_loop.ncl"
;
; set the LL corner point in each field to avoid constant value plots
;
tvar(lly,llx) = 26.
if (fnameback1test .eq. 1) then
  tvarback1(lly,llx) = 26.
end if
if (fnameback2test .eq. 1) then
  tvarback2(lly,llx) = 26.
end if
tvarbkg = tvar * 0.
tvarbkg(lly,llx) = 26.
;
load "$NCL_HOME/obj/hrrr_map_blk_counties_blk.ncl"
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
if (fnameback1test .eq. 1) then
  tfieldback1 = create "ScalarField" scalarFieldClass appid
      "sfDataArray" : tvarback1
      "sfXCStartSubsetV" : llx
      "sfYCStartSubsetV" : lly
      "sfXCEndSubsetV" : urx
      "sfYCEndSubsetV" : ury
      "sfMissingValueV" : tvar@_FillValue
  end create
end if
;
if (fnameback2test .eq. 1) then
  tfieldback2 = create "ScalarField" scalarFieldClass appid
      "sfDataArray" : tvarback2
      "sfXCStartSubsetV" : llx
      "sfYCStartSubsetV" : lly
      "sfXCEndSubsetV" : urx
      "sfYCEndSubsetV" : ury
      "sfMissingValueV" : tvar@_FillValue
  end create
end if
;
tfieldbkg = create "ScalarField" scalarFieldClass appid
    "sfDataArray" : tvarbkg
    "sfXCStartSubsetV" : llx
    "sfYCStartSubsetV" : lly
    "sfXCEndSubsetV" : urx
    "sfYCEndSubsetV" : ury
    "sfMissingValueV" : tvarbkg@_FillValue
end create
;
if (iq .ne. 0) then
  vfield = create "VectorField" vectorFieldClass appid
      "vfUDataArray" : uvar
      "vfVDataArray" : vvar
      "vfXCStartSubsetV" : llx
      "vfYCStartSubsetV" : lly
      "vfXCEndSubsetV" : urx
      "vfYCEndSubsetV" : ury
      "vfMissingVValueV" : vvar@_FillValue
      "vfMissingUValueV" : uvar@_FillValue
      "vfXCStride" : 15          ; i.e., plot a vector at every (n+1)th point.
      "vfYCStride" : 15
  end create
else
  vfield = create "VectorField" vectorFieldClass appid
      "vfUDataArray" : uvar
      "vfVDataArray" : vvar   
      "vfXCStartSubsetV" : llx
      "vfYCStartSubsetV" : lly
      "vfXCEndSubsetV" : urx
      "vfYCEndSubsetV" : ury
      "vfMissingVValueV" : vvar@_FillValue
      "vfMissingUValueV" : uvar@_FillValue
      "vfXCStride" : 30          ; i.e., plot a vector at every (n+1)th point.
      "vfYCStride" : 30
  end create
end if
;
; Create a VectorPlot object.
;
vcid = create "vectorplot" vectorPlotClass wid
    "vcVectorFieldData":  vfield
    "vcGlyphStyle" : "WindBarb"
;    "vcWindBarbLineThicknessF" : 1.2
    "vcWindBarbColor" : 23
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
; Create a ContourPlot object.
;
; Helicity
;
load "$NCL_HOME/obj/helicity_bkg.ncl"
intmdate = getSubString(intm,0,9)
intminit = getSubString(intm,12,13)
intmcurrentruntime = intmdate+" "+intminit+"Z"
;intmcurrent = getSubString(intm,0,13)+"Z)"
currentstring = intmcurrentruntime+" "+fctm+"hr fcst"
if (fnameback2test .eq. 1) then
  load "$NCL_HOME/obj/helicity_back2.ncl"
  setvalues cnidback2
    "cnFillMode" : "AreaFill"
  end setvalues
  intmback2date = getSubString(intmback2,0,9)
  intmback2init = getSubString(intmback2,12,13)
  intmback2runtime = intmback2date+" "+intmback2init+"Z"
;  intmback2 = getSubString(intmback2,0,13)+"Z)"
  back2string = intmback2runtime+" "+fctmback2+"hr fcst"
else
  back2string = "MISSING"
end if
if (fnameback1test .eq. 1) then
  load "$NCL_HOME/obj/helicity_back1.ncl"
  setvalues cnidback1
    "cnFillMode" : "AreaFill"
  end setvalues
  intmback1date = getSubString(intmback1,0,9)
  intmback1init = getSubString(intmback1,12,13)
;  intmback1 = getSubString(intmback1,0,13)+"Z)"
  intmback1runtime = intmback1date+" "+intmback1init+"Z"
  back1string = intmback1runtime+" "+fctmback1+"hr fcst"
else
  back1string = "MISSING"
end if
load "$NCL_HOME/obj/helicity_current.ncl"
setvalues cnid
  "cnFillMode" : "AreaFill"
end setvalues
;
lbid = create "LabelBar" labelBarClass wid
    "lbOrientation" : "Horizontal"
    "lbAutoManage" : False
    "lbLabelAutoStride" : False
    "lbLabelFont" : 21
    "lbLabelFontHeightF" : .011
    "lbLabelFontThicknessF" : 2
    "lbLabelFontColor" : 1
    "lbPerimOn" : False 
    "lbBoxCount" : 17
    "lbBoxLinesOn" : False
    "lbFillColors" : (/ 1,35,32,29,26,0,1,23,20,17,14,0,1,11,8,5,2 /)
    "lbMonoFillPattern" : True
    "lbLabelAlignment" : "InteriorEdges"
    "lbLabelPosition" : "Bottom"
    "lbLabelStrings" : (/ "25","100","200","300","","","25","100","200","300", \
                          "","","25","100","200","300" /)
;    "vpXF"      : 0.18 
    "vpXF"      : vpx
    "vpYF"      : (vpy - vpheight) - 0.008
;    "vpYF"      : (vpy - vpheight)
;    "vpWidthF"  : vpwidth-0.26
    "vpWidthF"  : vpwidth
;    "vpHeightF" : 0.1
    "vpHeightF" : 0.06
end create
;
titlestring = "Ensemble Max Updraft Helicity (over prev hour) (m~S~2~N~/s~S~2~E~ )"
load "$NCL_HOME/obj/add_titles_rr.ncl"
;
; Draw map
;
draw(cnidbkg)
if (fnameback2test .eq. 1) then
  draw(cnidback2)
end if
if (fnameback1test .eq. 1) then
  draw(cnidback1)
end if
draw(cnid)
draw(mpid)
draw(lbid)
;
setvalues lbid
  "lbLabelAlignment" : "BoxCenters"
  "lbLabelPosition" : "Top"
;  "lbFillColors" : (/ 1,26,33,35,37,0,1,14,21,23,25,0,1,2,9,11,13 /)
  "lbFillColors" : (/ 1,35,32,29,26,0,1,23,20,17,14,0,1,11,8,5,2 /)
  "lbLabelFont" : 21
  "lbLabelFontHeightF" : .011
  "lbLabelFontThicknessF" : 2
  "lbLabelFontColor" : 1
  "lbLabelStrings" : (/ "","",back2string,"","","","","",back1string, \
                        "","","","","",currentstring,"","" /)

;  "vpXF"      : 0.18
  "vpXF"      : vpx
  "vpYF"      : (vpy - vpheight) + 0.011
;  "vpYF"      : (vpy - vpheight)
;  "vpWidthF"  : vpwidth-0.26
  "vpWidthF"  : vpwidth
;  "vpHeightF" : 0.1
  "vpHeightF" : 0.06
end setvalues
;
draw(lbid)
;draw(vcid)
;
gsres = True
if (iq .eq. 0) then
  do i = 0,dimsizes(airport_id)-1
    gsres@gsMarkerIndex = 16
    gsres@gsMarkerColor = 38
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
    gsres@gsMarkerColor = 38
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
;
