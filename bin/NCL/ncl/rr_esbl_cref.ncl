load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl";
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
load "$NCL_HOME/obj/plot_titles_hrrr.ncl"
load "./names_grib2.txt"
;
load "$NCL_HOME/obj/cmap1_esbl.ncl"
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
tvar = grb_file->$CREFNAME$(:,:)
tvar = where (.not. ismissing(tvar) .and. tvar .lt. 0, 0, tvar)
tvarback1 = tvar * 0.
tvarback2 = tvar * 0.
tvarovlp1 = tvar * 0.
tvarovlp2 = tvar * 0.
if (fnameback1test .eq. 1) then
  tvarback1 = grb_file_back1->$CREFNAME$(:,:)
  tvarback1 = where (.not. ismissing(tvarback1) .and. tvarback1 .lt. 0, 0, tvarback1)
  tvarovlp_c_b1 = tvar + tvarback1
end if
if (fnameback2test .eq. 1) then
  tvarback2 = grb_file_back2->$CREFNAME$(:,:)
  tvarback2 = where (.not. ismissing(tvarback2) .and. tvarback2 .lt. 0, 0, tvarback2)
  tvarovlp_c_b2 = tvar + tvarback2
end if
if (fnameback1test .eq. 1 .and. fnameback2test .eq. 1) then
  tvarovlp_b1_b2 = tvarback1 + tvarback2
  tvarovlp_all = tvar + tvarback1 + tvarback2
  print("tvarovlp_b1_b2")
  print(min(tvarovlp_b1_b2))
  print(max(tvarovlp_b1_b2))
  print("tvarovlp_all")
  print(min(tvarovlp_all))
  print(max(tvarovlp_all))
end if
;
load "$NCL_HOME/obj/get_date_str.ncl"
;
print(date_str)
print("TL-esbl comp reflectivity")
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
           "wkMetaName" : "./esbl_cref.ncgm"
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
           "wkPSFileName" : "./esbl_cref.ps"
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
tvar(lly,llx) = 41.
if (fnameback1test .eq. 1) then
  tvarback1(lly,llx) = 41.
  tvarovlp_c_b1(lly,llx) = 81.
end if
if (fnameback2test .eq. 1) then
  tvarback2(lly,llx) = 41.
  tvarovlp_c_b2(lly,llx) = 81.
end if
if (fnameback1test .eq. 1 .and. fnameback2test .eq. 1) then
  tvarovlp_b1_b2(lly,llx) = 81.
  tvarovlp_all(lly,llx) = 121.
end if
tvarbkg = tvar * 0.
tvarbkg(lly,llx) = 41.
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
      "sfMissingValueV" : tvarback1@_FillValue
  end create
  tfieldovlp_c_b1 = create "ScalarField" scalarFieldClass appid
      "sfDataArray" : tvarovlp_c_b1
      "sfXCStartSubsetV" : llx
      "sfYCStartSubsetV" : lly
      "sfXCEndSubsetV" : urx
      "sfYCEndSubsetV" : ury
      "sfMissingValueV" : tvarovlp_c_b1@_FillValue
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
      "sfMissingValueV" : tvarback2@_FillValue
  end create
  tfieldovlp_c_b2 = create "ScalarField" scalarFieldClass appid
      "sfDataArray" : tvarovlp_c_b2
      "sfXCStartSubsetV" : llx
      "sfYCStartSubsetV" : lly
      "sfXCEndSubsetV" : urx
      "sfYCEndSubsetV" : ury
      "sfMissingValueV" : tvarovlp_c_b2@_FillValue
  end create
end if
;
if (fnameback1test .eq. 1 .and. fnameback2test .eq. 1) then
  tfieldovlp_b1_b2 = create "ScalarField" scalarFieldClass appid
      "sfDataArray" : tvarovlp_b1_b2
      "sfXCStartSubsetV" : llx
      "sfYCStartSubsetV" : lly
      "sfXCEndSubsetV" : urx
      "sfYCEndSubsetV" : ury
      "sfMissingValueV" : tvarovlp_b1_b2@_FillValue
  end create
  tfieldovlp_all = create "ScalarField" scalarFieldClass appid
      "sfDataArray" : tvarovlp_all
      "sfXCStartSubsetV" : llx
      "sfYCStartSubsetV" : lly
      "sfXCEndSubsetV" : urx
      "sfYCEndSubsetV" : ury
      "sfMissingValueV" : tvarovlp_all@_FillValue
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
; Composite Reflectivity
;
cl0 = 5
cl1 = 35
cl2 = 45
cl3 = 55
cl4 = 65
;
ol1 = 80  ; these 4 values for overlap of 2 times
ol2 = 90
ol3 = 100
ol4 = 110
;
ol5 = 120  ; these 4 values for overlap of all 3 times
ol6 = 130
ol7 = 140
ol8 = 150
;
load "$NCL_HOME/obj/cref_bkg.ncl"
intmdate = getSubString(intm,0,9)
intminit = getSubString(intm,12,13)
intmcurrentruntime = intmdate+" "+intminit+"Z"
currentstring = intmcurrentruntime+" "+fctm+"hr fcst"
if (fnameback2test .eq. 1) then
  load "$NCL_HOME/obj/cref_back2_abv5.ncl"
  setvalues cnidback2abv5
    "cnFillMode" : "AreaFill"
    "cnLevels" : (/ cl0 /)
    "cnFillColors" : (/ -1,53 /) 
  end setvalues
  load "$NCL_HOME/obj/cref_back2.ncl"
  setvalues cnidback2
    "cnFillMode" : "AreaFill"
    "cnLevels" : (/ cl1,cl2,cl3,cl4 /)
    "cnFillColors" : (/ -1,35,32,29,26 /) 
  end setvalues
  load "$NCL_HOME/obj/cref_ovlp_c_b2.ncl"
  setvalues cnidovlp_c_b2
    "cnFillMode" : "AreaFill"
    "cnLevels" : (/ ol1,ol2,ol3,ol4 /)
  end setvalues
  intmback2date = getSubString(intmback2,0,9)
  intmback2init = getSubString(intmback2,12,13)
  intmback2runtime = intmback2date+" "+intmback2init+"Z"
  back2string = intmback2runtime+" "+fctmback2+"hr fcst"
else
  back2string = "MISSING"
end if
if (fnameback1test .eq. 1) then
  load "$NCL_HOME/obj/cref_back1_abv5.ncl"
  setvalues cnidback1abv5
    "cnFillMode" : "AreaFill"
    "cnLevels" : (/ cl0 /)
    "cnFillColors" : (/ -1,53 /)            
  end setvalues
  load "$NCL_HOME/obj/cref_back1.ncl"
  setvalues cnidback1
    "cnFillMode" : "AreaFill"
    "cnLevels" : (/ cl1,cl2,cl3,cl4 /)
    "cnFillColors" : (/ -1,23,20,17,14 /)
  end setvalues
  load "$NCL_HOME/obj/cref_ovlp_c_b1.ncl"
  setvalues cnidovlp_c_b1
    "cnFillMode" : "AreaFill"
    "cnLevels" : (/ ol1,ol2,ol3,ol4 /)
  end setvalues
  intmback1date = getSubString(intmback1,0,9)
  intmback1init = getSubString(intmback1,12,13)
  intmback1runtime = intmback1date+" "+intmback1init+"Z"
  back1string = intmback1runtime+" "+fctmback1+"hr fcst"
else
  back1string = "MISSING"
end if
if (fnameback2test .eq. 1 .and. fnameback1test .eq. 1) then
  load "$NCL_HOME/obj/cref_ovlp_b1_b2.ncl"
  setvalues cnidovlp_b1_b2
    "cnFillMode" : "AreaFill"
    "cnLevels" : (/ ol1,ol2,ol3,ol4 /)
  end setvalues
  load "$NCL_HOME/obj/cref_ovlp_all.ncl"
  setvalues cnidovlp_all
    "cnFillMode" : "AreaFill"
    "cnLevels" : (/ ol5,ol6,ol7,ol8 /)
  end setvalues
end if
;
load "$NCL_HOME/obj/cref_current_abv5.ncl"
setvalues cnidcurrentabv5
  "cnFillMode" : "AreaFill"
  "cnLevels" : (/ cl0 /)
  "cnFillColors" : (/ -1,53 /)
end setvalues
load "$NCL_HOME/obj/cref_current.ncl"
setvalues cnid
  "cnFillMode" : "AreaFill"
  "cnLevels" : (/ cl1,cl2,cl3,cl4 /)
  "cnFillColors" : (/ -1,11,8,5,2 /)
end setvalues
;
scl0 = tostring(cl0)
scl1 = tostring(cl1)
scl2 = tostring(cl2)
scl3 = tostring(cl3)
scl4 = tostring(cl4)
;
sol1 = tostring(ol1)
sol2 = tostring(ol2)
sol3 = tostring(ol3)
sol4 = tostring(ol4)
;
sol5 = tostring(ol5)
sol6 = tostring(ol6)
sol7 = tostring(ol7)
sol8 = tostring(ol8)
;
lbid = create "LabelBar" labelBarClass wid
    "lbOrientation" : "Horizontal"
    "lbAutoManage" : False
    "lbLabelAutoStride" : False
    "lbLabelFont" : 4
    "lbLabelFontHeightF" : .011
    "lbPerimOn" : False 
    "lbBoxCount" : 20
    "lbBoxLinesOn" : False
    "lbLabelFont" : 21
    "lbLabelFontColor" : 1
    "lbLabelFontThicknessF" : 2
;    "lbFillColors" : (/ 52,53,35,32,29,26,0,52,53,23,20,17,14,0,52,53,11,8,5,2 /)
    "lbFillColors" : (/ 1,53,35,32,29,26,0,1,53,23,20,17,14,0,1,53,11,8,5,2 /)
    "lbMonoFillPattern" : True
    "lbLabelAlignment" : "InteriorEdges"
    "lbLabelPosition" : "Bottom"
    "lbLabelStrings" : (/ scl0,scl1,scl2,scl3,scl4,"","",scl0,scl1,scl2,scl3,scl4, \
                          "","",scl0,scl1,scl2,scl3,scl4 /)
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
lbid2 = create "LabelBar" labelBarClass wid
    "lbOrientation" : "Vertical"
    "lbAutoManage" : False
    "lbLabelFont" : 4
    "lbLabelFontHeightF" : .011
    "lbPerimOn" : False
    "lbBoxCount" : 20
    "lbBoxLinesOn" : False
    "lbLabelFontColor" : 39
    "lbFillColors" : (/ 52,23,20,17,14,52,44,45,46,47,52,40,41,42,43, \
                        52,53,54,55,56 /)
    "lbMonoFillPattern" : True
    "lbLabelAlignment" : "InteriorEdges"
    "lbLabelPosition" : "Bottom"
    "lbLabelStrings" : (/ sol1,sol2,sol3,sol4,"",sol1,sol2,sol3,sol4, \
                          "",sol1,sol2,sol3,sol4,"",sol5,sol6,sol7,sol8 /)
    "vpXF"      : (vpx + vpwidth) - 0.028
;    "vpXF"      : vpx
;    "vpYF"      : vpy
    "vpYF"      : vpy
    "vpWidthF"  : 0.07
    "vpHeightF" : vpheight
end create
;
titlestring = "Ensemble Composite Reflectivity (dBZ)"
load "$NCL_HOME/obj/add_titles_rr.ncl"
;
; Draw map
;
draw(cnidbkg)
;
; Draw low level reflectivity from all runs first
;
if (fnameback2test .eq. 1) then
  draw(cnidback2abv5)
end if
if (fnameback1test .eq. 1) then
  draw(cnidback1abv5)
end if
draw(cnidcurrentabv5)
;
if (fnameback2test .eq. 1) then
  draw(cnidback2)
end if
if (fnameback1test .eq. 1) then
  draw(cnidback1)
end if
draw(cnid)
;if (fnameback2test .eq. 1 .and. fnameback1test .eq. 1) then
;  draw(cnidovlp_b1_b2)
;end if
;if (fnameback2test .eq. 1) then
;  draw(cnidovlp_c_b2)
;end if
;if (fnameback1test .eq. 1) then
;  draw(cnidovlp_c_b1)
;end if
;if (fnameback2test .eq. 1 .and. fnameback1test .eq. 1) then
;  draw(cnidovlp_all)
;end if
draw(mpid)
draw(lbid)
;draw(lbid2)
;
setvalues lbid
  "lbLabelAlignment" : "InteriorEdges"
  "lbLabelPosition" : "Top"
;  "lbFillColors" : (/ 52,53,35,32,29,26,0,52,53,23,20,17,14,0,52,53,11,8,5,2 /)
  "lbFillColors" : (/ 1,53,35,32,29,26,0,1,53,23,20,17,14,0,1,53,11,8,5,2 /)
  "lbLabelFont" : 21
  "lbLabelFontColor" : 1
  "lbLabelFontThicknessF" : 2
  "lbLabelStrings" : (/ "","",back2string,"","","","","","",back1string, \
                        "","","","","","",currentstring,"","" /)

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
;
ovlp_b1_b2_string = fctmback1+"HR + "+fctmback2+"HR"
if (fctmback1 .eq. -999) then
  ovlp_b1_b2_string = "MSG + "+fctmback2+"HR"
end if
if (fctmback2 .eq. -999) then
  ovlp_b1_b2_string = fctmback1+"HR + MSG"
end if
if (fctmback1 .eq. -999 .and. fctmback2 .eq. -999) then
  ovlp_b1_b2_string = "MSG + MSG"
end if
;  
ovlp_c_b2_string = "CURRENT + "+fctmback2+"HR"
if (fctmback2 .eq. -999) then
  ovlp_c_b2_string = "CURRENT + MSG"
end if
ovlp_c_b1_string = "CURRENT + "+fctmback1+"HR"
if (fctmback1 .eq. -999) then
  ovlp_c_b1_string = "CURRENT + MSG"
end if
ovlp_all_string = "ALL TIMES"
;
setvalues lbid2
  "lbOrientation" : "Vertical"
  "lbAutoManage" : False
  "lbLabelFont" : 4
  "lbLabelFontHeightF" : .009
  "lbLabelAngleF" : 90.
  "lbPerimOn" : False
  "lbBoxCount" : 20
  "lbBoxLinesOn" : False
  "lbLabelFontColor" : 1
  "lbFillColors" : (/ 52,23,20,17,14,52,44,45,46,47,52,40,41,42,43, \
                      52,53,54,55,56 /)
  "lbMonoFillPattern" : True
  "lbLabelAlignment" : "InteriorEdges"
  "lbLabelPosition" : "Top"
  "lbLabelStrings" : (/ "","",ovlp_b1_b2_string,"","","","",ovlp_c_b2_string, \
                        "","","","",ovlp_c_b1_string,"","","","", \
                        ovlp_all_string,"" /)
  "vpXF"      : (vpx + vpwidth) - 0.056
  "vpYF"      : vpy
  "vpWidthF"  : 0.07
  "vpHeightF" : vpheight
end setvalues
;
;draw(lbid2)
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
