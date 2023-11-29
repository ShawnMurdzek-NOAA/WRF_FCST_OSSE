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
checkb1h = ""
checkb1h = systemfunc("ls back1_hour.txt") 
checkb1f = ""
checkb1f = systemfunc("ls back1_file.txt") 
checkb1fb1h = "" 
checkb1fb1h = systemfunc("ls back1_file_back1_hour.txt") 
checkb2f = ""
checkb2f = systemfunc("ls back2_file.txt") 
checkb2fb1h = "" 
checkb2fb1h = systemfunc("ls back2_file_back1_hour.txt") 
fnameb1htest = 0
fnameb1ftest = 0
fnameb1fb1htest = 0
fnameb2ftest = 0
fnameb2fb1htest = 0
if (.not.ismissing(checkb1h.eq."back1_hour.txt")) then
   fnameb1h = asciiread("back1_hour.txt",-1,"string")
   b1hexists = isfilepresent(fnameb1h)
   if (b1hexists) then
     print("reading "+fnameb1h)
     fnameb1htest = 1
     grb_file_b1h = addfile(fnameb1h,"r")
   else
     print("error - missing file "+fnameb1h)
   end if
end if
if (.not.ismissing(checkb1f.eq."back1_file.txt")) then 
   fnameb1f = asciiread("back1_file.txt",-1,"string")
   b1fexists = isfilepresent(fnameb1f)
   if (b1fexists) then
     print("reading "+fnameb1f)
     fnameb1ftest = 1
     grb_file_b1f = addfile(fnameb1f,"r")
   else
     print("error - missing file "+fnameb1f)
   end if
end if 
if (.not.ismissing(checkb1fb1h.eq."back1_file_back1_hour.txt")) then 
   fnameb1fb1h = asciiread("back1_file_back1_hour.txt",-1,"string")
   b1fb1hexists = isfilepresent(fnameb1fb1h)
   if (b1fb1hexists) then
     print("reading "+fnameb1fb1h)
     fnameb1fb1htest = 1
     grb_file_b1fb1h = addfile(fnameb1fb1h,"r")
   else
     print("error - missing file "+fnameb1fb1h)
   end if
end if 
if (.not.ismissing(checkb2f.eq."back2_file.txt")) then
   fnameb2f = asciiread("back2_file.txt",-1,"string")
   b2fexists = isfilepresent(fnameb2f)
   if (b2fexists) then
     print("reading "+fnameb2f)
     fnameb2ftest = 1
     grb_file_b2f = addfile(fnameb2f,"r")
   else
     print("error - missing file "+fnameb2f)
   end if
end if
if (.not.ismissing(checkb2fb1h.eq."back2_file_back1_hour.txt")) then
   fnameb2fb1h = asciiread("back2_file_back1_hour.txt",-1,"string")
   b2fb1hexists = isfilepresent(fnameb2fb1h)
   if (b2fb1hexists) then
     print("reading "+fnameb2fb1h)
     fnameb2fb1htest = 1
     grb_file_b2fb1h = addfile(fnameb2fb1h,"r")
   else
     print("error - missing file "+fnameb2fb1h)
   end if
end if
;
if (fnameb1htest .eq. 1) then
  print("fnameb1h ="+fnameb1h)
  intmb1h = grb_file_b1h->$T2MNAME$@initial_time
  fctmb1h = grb_file_b1h->$T2MNAME$@forecast_time
else
  intmb1h = -999
  fctmb1h = -999
end if
if (fnameb1ftest .eq. 1) then
  print("fnameb1f ="+fnameb1f)
  intmb1f = grb_file_b1f->$T2MNAME$@initial_time
  fctmb1f = grb_file_b1f->$T2MNAME$@forecast_time
else
  intmb1f = -999
  fctmb1f = -999
end if
if (fnameb1fb1htest .eq. 1) then
  print("fnameb1fb1h ="+fnameb1fb1h)
  intmb1fb1h = grb_file_b1fb1h->$T2MNAME$@initial_time
  fctmb1fb1h = grb_file_b1fb1h->$T2MNAME$@forecast_time
else
  intmb1fb1h = -999
  fctmb1fb1h = -999
end if
if (fnameb2ftest .eq. 1) then
  print("fnameb2f = "+fnameb2f)
  intmb2f = grb_file_b2f->$T2MNAME$@initial_time
  fctmb2f = grb_file_b2f->$T2MNAME$@forecast_time
else
  intmb2f = -999
  fctmb2f = -999
end if
if (fnameb2fb1htest .eq. 1) then
  print("fnameb2fb1h ="+fnameb2fb1h)
  intmb2fb1h = grb_file_b1fb1h->$T2MNAME$@initial_time
  fctmb2fb1h = grb_file_b1fb1h->$T2MNAME$@forecast_time
else
  intmb2fb1h = -999
  fctmb2fb1h = -999
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
if (fnameb1htest .eq. 1) then
  uvar = grb_file->$U10MNAME$(1,:,:) * 1.9429 ; convert to knots, index 1 is 80m
  vvar = grb_file->$V10MNAME$(1,:,:) * 1.9429 ; convert to knots, index 1 is 80m
  uvarb1h = grb_file_b1h->$U10MNAME$(1,:,:) * 1.9429 ; convert to knots, index 1 is 80m
  vvarb1h = grb_file_b1h->$V10MNAME$(1,:,:) * 1.9429 ; convert to knots, index 1 is 80m
;
  uv2 = uvar * uvar
  vv2 = vvar * vvar
  wind = sqrt(uv2 + vv2)
  uv2b1h = uvarb1h * uvarb1h
  vv2b1h = vvarb1h * vvarb1h
  windb1h = sqrt(uv2b1h + vv2b1h)
  tvar = wind - windb1h
  tvar = where (.not. ismissing(tvar) .and. tvar .lt. 0, 0, tvar)
else
  exit
end if
;
if (fnameb1ftest .eq. 1 .and. fnameb1fb1htest .eq. 1) then
  uvarb1f = grb_file_b1f->$U10MNAME$(1,:,:) * 1.9429 ; convert to knots, index 1 is 80m
  vvarb1f = grb_file_b1f->$V10MNAME$(1,:,:) * 1.9429 ; convert to knots, index 1 is 80m
  uvarb1fb1h = grb_file_b1fb1h->$U10MNAME$(1,:,:) * 1.9429 ; convert to knots, index 1 is 80m
  vvarb1fb1h = grb_file_b1fb1h->$V10MNAME$(1,:,:) * 1.9429 ; convert to knots, index 1 is 80m
;
  uv2b1f = uvarb1f * uvarb1f
  vv2b1f = vvarb1f * vvarb1f
  windb1f = sqrt(uv2b1f + vv2b1f)
  uv2b1fb1h = uvarb1fb1h * uvarb1fb1h
  vv2b1fb1h = vvarb1fb1h * vvarb1fb1h
  windb1fb1h = sqrt(uv2b1fb1h + vv2b1fb1h)
  tvarb1f = windb1f - windb1fb1h
  tvarb1f = where (.not. ismissing(tvarb1f) .and. tvarb1f .lt. 0, 0, tvarb1f)
end if
;
if (fnameb2ftest .eq. 1 .and. fnameb2fb1htest .eq. 1) then
  uvarb2f = grb_file_b2f->$U10MNAME$(1,:,:) * 1.9429 ; convert to knots, index 1 is 80m
  vvarb2f = grb_file_b2f->$V10MNAME$(1,:,:) * 1.9429 ; convert to knots, index 1 is 80m
  uvarb2fb1h = grb_file_b2fb1h->$U10MNAME$(1,:,:) * 1.9429 ; convert to knots, index 1 is 80m
  vvarb2fb1h = grb_file_b2fb1h->$V10MNAME$(1,:,:) * 1.9429 ; convert to knots, index 1 is 80m
;
  uv2b2f = uvarb2f * uvarb2f
  vv2b2f = vvarb2f * vvarb2f
  windb2f = sqrt(uv2b2f + vv2b2f)
  uv2b2fb1h = uvarb2fb1h * uvarb2fb1h
  vv2b2fb1h = vvarb2fb1h * vvarb2fb1h
  windb2fb1h = sqrt(uv2b2fb1h + vv2b2fb1h)
  tvarb2f = windb2f - windb2fb1h
  tvarb2f = where (.not. ismissing(tvarb2f) .and. tvarb2f .lt. 0, 0, tvarb2f)
end if
;
load "$NCL_HOME/obj/get_date_str.ncl"
;
print(date_str)
print("TL-esbl 1h 80m Wind Speed Change")
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
           "wkMetaName" : "./esbl_wchg.ncgm"
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
           "wkPSFileName" : "./esbl_wchg.ps"
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
tvar(lly,llx) = 4.1
if (fnameb1ftest .eq. 1) then
  tvarb1f(lly,llx) = 4.1
end if
if (fnameb2ftest .eq. 1) then
  tvarb2f(lly,llx) = 4.1
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
if (fnameb1ftest .eq. 1) then
  tfieldback1 = create "ScalarField" scalarFieldClass appid
      "sfDataArray" : tvarb1f
      "sfXCStartSubsetV" : llx
      "sfYCStartSubsetV" : lly
      "sfXCEndSubsetV" : urx
      "sfYCEndSubsetV" : ury
      "sfMissingValueV" : tvarb1f@_FillValue
  end create
end if
;
if (fnameb2ftest .eq. 1) then
  tfieldback2 = create "ScalarField" scalarFieldClass appid
      "sfDataArray" : tvarb2f
      "sfXCStartSubsetV" : llx
      "sfYCStartSubsetV" : lly
      "sfXCEndSubsetV" : urx
      "sfYCEndSubsetV" : ury
      "sfMissingValueV" : tvarb2f@_FillValue
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
cl0 = 4
cl1 = 8
cl2 = 12
cl3 = 16
cl4 = 20
;
load "$NCL_HOME/obj/cref_bkg.ncl"
intmdate = getSubString(intm,0,9)
intminit = getSubString(intm,12,13)
intmcurrentruntime = intmdate+" "+intminit+"Z"
currentstring = intmcurrentruntime+" "+fctm+"hr fcst"
if (fnameb2ftest .eq. 1) then
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
  intmb2fdate = getSubString(intmb2f,0,9)
  intmb2finit = getSubString(intmb2f,12,13)
  intmb2fruntime = intmb2fdate+" "+intmb2finit+"Z"
  b2fstring = intmb2fruntime+" "+fctmb2f+"hr fcst"
;  print("b2fstring is "+b2fstring)
else
  b2fstring = "MISSING"
end if
if (fnameb1ftest .eq. 1) then
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
  intmb1fdate = getSubString(intmb1f,0,9)
  intmb1finit = getSubString(intmb1f,12,13)
  intmb1fruntime = intmb1fdate+" "+intmb1finit+"Z"
  b1fstring = intmb1fruntime+" "+fctmb1f+"hr fcst"
;  print("b1fstring is "+b1fstring)
else
  b1fstring = "MISSING"
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
lbid = create "LabelBar" labelBarClass wid
    "lbOrientation" : "Horizontal"
    "lbAutoManage" : False
    "lbLabelAutoStride" : False
    "lbLabelFont" : 21
    "lbLabelFontHeightF" : .011
    "lbLabelFontThicknessF" : 2
    "lbLabelFontColor" : 1
    "lbPerimOn" : False 
    "lbBoxCount" : 20
    "lbBoxLinesOn" : False
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
titlestring = "TL-Ensemble 1h 80m Wind Speed Change (kt)"
load "$NCL_HOME/obj/add_titles_rr.ncl"
;
; Draw map
;
draw(cnidbkg)
;
; Draw low level wind speed change from all runs first
;
if (fnameb2ftest .eq. 1 .and. fnameb2fb1htest .eq. 1) then
  draw(cnidback2abv5)
end if
if (fnameb1ftest .eq. 1 .and. fnameb1fb1htest .eq. 1) then
  draw(cnidback1abv5)
end if
draw(cnidcurrentabv5)
;
if (fnameb2ftest .eq. 1 .and. fnameb2fb1htest .eq. 1) then
  draw(cnidback2)
end if
if (fnameb1ftest .eq. 1 .and. fnameb1fb1htest .eq. 1) then
  draw(cnidback1)
end if
draw(cnid)
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
  "lbLabelFontHeightF" : .011
  "lbLabelFontThicknessF" : 2
  "lbLabelFontColor" : 1
  "lbLabelStrings" : (/ "","",b2fstring,"","","","","","",b1fstring, \
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
;print("b2fstring is "+b2fstring)
;print("b1fstring is "+b1fstring)
;print("currentstring is "+currentstring)
draw(lbid)
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
