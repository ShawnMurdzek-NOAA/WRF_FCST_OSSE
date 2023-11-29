load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl";
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCL_HOME/obj/plot_titles_hrrr.ncl"
load "./names_grib2.txt"
;
load "$NCL_HOME/obj/cmap_ci.ncl"
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
if (fctm .eq. 0) then
  exit
end if
;
;if (fctm .eq. 1) then
  tvar = grb_file->$CI3NAME$(5,:,:)  ; convective init (based on lightning threat)
  tvarsave = tvar
;else
;  tvar = grb_file->$HLCY1HNAME$(:,:)  ; updraft helicity
;end if
uvar = grb_file->$USHRNAME$(0,:,:) * 1.9429 ; convert to knots  ; correct?
vvar = grb_file->$VSHRNAME$(0,:,:) * 1.9429 ; convert to knots  ; correct?
;
load "$NCL_HOME/obj/get_date_str.ncl"
;
print(date_str)
print("Convective Initiation 3 - 35 dBz at -10 C")
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
           "wkMetaName" : "./sfc_ci3.ncgm"
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
           "wkPSFileName" : "./sfc_ci3.ps"
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
load "$NCL_HOME/obj/hrrr_map_blk_counties_blk.ncl"
;
; Create a ScalarField object.
;
tvar = tvarsave
;
if (min(tvar(lly:ury,llx:urx)) .ge. 80) then
  tvar = 1020
  tvar(lly,llx) = 79  ; avoid constant value map
end if
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
;if (iq .ne. 0) then
;  vfield = create "VectorField" vectorFieldClass appid
;      "vfUDataArray" : uvar
;      "vfVDataArray" : vvar
;      "vfXCStartSubsetV" : llx
;      "vfYCStartSubsetV" : lly
;      "vfXCEndSubsetV" : urx
;      "vfYCEndSubsetV" : ury
;      "vfMissingVValueV" : vvar@_FillValue
;      "vfMissingUValueV" : uvar@_FillValue
;      "vfXCStride" : 15          ; i.e., plot a vector at every (n+1)th point.
;      "vfYCStride" : 15
;  end create
;else
;  vfield = create "VectorField" vectorFieldClass appid
;      "vfUDataArray" : uvar
;      "vfVDataArray" : vvar   
;      "vfXCStartSubsetV" : llx
;      "vfYCStartSubsetV" : lly
;      "vfXCEndSubsetV" : urx
;      "vfYCEndSubsetV" : ury
;      "vfMissingVValueV" : vvar@_FillValue
;      "vfMissingUValueV" : uvar@_FillValue
;      "vfXCStride" : 30          ; i.e., plot a vector at every (n+1)th point.
;      "vfYCStride" : 30
;  end create
;end if
;;
;; Create a VectorPlot object.
;;
;vcid = create "vectorplot" vectorPlotClass wid
;    "vcVectorFieldData":  vfield
;    "vcGlyphStyle" : "WindBarb"
;;    "vcWindBarbLineThicknessF" : 1.2
;    "vcWindBarbColor" : 23
;;    "vcWindBarbTickSpacingF" : 0.1875
;    "vcRefAnnoOn" : False
;    "pmTickMarkDisplayMode" : "NoCreate"
;    "vpXF"      : vpx        ; set viewport
;    "vpYF"      : vpy
;    "vpWidthF"  : vpwidth
;    "vpHeightF" : vpheight
;end create
;;
;setvalues vcid
;  "vcMinMagnitudeF" : 0
;end setvalues
;
; Create a ContourPlot object.
;
load "$NCL_HOME/obj/ci.ncl"
;
;if (iq .ge. 8) then
;  setvalues cnid
;    "cnFillMode" : "AreaFill"
;  end setvalues
;end if
;
titlestring = "Minutes since last Conv Init (based on 35 dBZ at -10 C)"
load "$NCL_HOME/obj/add_titles_rr.ncl"
;
; Draw map
;
draw(cnid)
draw(mpid)
;draw(vcid)
;
gsres = True
if (iq .eq. 0) then
  do i = 0,dimsizes(airport_id)-1
    gsres@gsMarkerIndex = 16
    gsres@gsMarkerColor = 11
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
    gsres@gsMarkerColor = 11
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
