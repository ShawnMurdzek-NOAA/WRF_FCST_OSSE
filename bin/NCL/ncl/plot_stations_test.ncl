;   Example script - plot terrain (using some basic WRF scripts)
;   The map background is added via the special wrf_map_overlays function
;   We get the HGT_M field using the special function wrf_user_getvar
;   November 2008

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"


begin

nrows = numAsciiRow("AIRNowPMSite_hrly.txt")
ncolumns = numAsciiCol("AIRNowPMSite_hrly.txt")

table = asciiread("AIRNowPMSite_hrly.txt",nrows,"string")

delim=","
lats=stringtofloat(str_get_field(table(1:nrows-1),3,delim))
lons=stringtofloat(str_get_field(table(1:nrows-1),4,delim))
sitechars=stringtoint(str_get_field(table(1:nrows-1),5,delim))
sitecolors = onedtond("string",(nrows-1))

do i = 0,(nrows-2)

;   if (sitechars(i) .eq. 1) then
;      sitecolors(i)="green"
;   else if (sitechars(i) .eq. 2) then
;      sitecolors(i)="brown"
;   else  if (sitechars(i) .eq. 3) then
;      sitecolors(i)="red"
;   else
;      sitecolors(i)="white"
;   end if

   if (sitechars(i) .eq. 1) then
      sitecolors(i)="G"
   end if

   if (sitechars(i) .eq. 2) then
      sitecolors(i)="B"
   end if

   if (sitechars(i) .eq. 3) then
      sitecolors(i)="R"
   end if

   if (sitechars(i) .eq. 0) then
      sitecolors(i)="W"
   end if

end do

  a = addfile("./geo_em.d01.nc","r")           ; Open a file


; type = "x11"
 type = "pdf"
; type = "eps"
; type = "ps"
; type = "ncgm"
; type = "png"
 wks = gsn_open_wks(type,"terrain")     
    ; Create a plot workstation

setvalues NhlGetWorkspaceObjectId()
   "wsMaximumSize": 247108864
end setvalues

  opts = True                          
        ; Set some Basic Plot options
;  opts@MainTitle = "GEOGRID FIELDS"
opts@InitTime = False
opts@NoHeaderFooter = True
opts@Footer = False
opts@cnInfoLabelOn        = False
opts@cnConstFLabelOn      = False
opts@cnFillOn            = True
opts@cnLinesOn = False

  ter = wrf_user_getvar(a,"HGT",0)          
 ; Read the variable to memory
  lmask = wrf_user_getvar(a,"LANDMASK",0)      
     ; Read the variable to memory

;  res = opts                                
   ; Use basic options for this field
;  res@cnFillOn = True                      
    ; Create a color fill plot
;  res@ContourParameters = (/ .1, 4000., 500. /) ; Set the levels

   opts_ter = opts

   opts_ter@UnitLabel            = "m"
   opts_ter@cnLevelSelectionMode = "ExplicitLevels"
   opts_ter@cnLevels  = (/ .1, 500, 1000, 1500, 2000, 2500, 3000, 3500/)
;   opts_ter@cnFillColors = (/"Blue","DarkOliveGreen1",\
;                        "DarkOliveGreen3", \
;                        "Chartreuse",     "Chartreuse3", \
;                        "Green",          "ForestGreen", \
;                        "Yellow",         "Orange", \
;                        "Red",             "Violet"/)


  opts_ter@cnFillColors = (/"Blue", \
                        "Green3", "Green",  \
                        "Chartreuse",     "Yellow3", \
                        "Yellow",         "Orange", \
                        "Red",             "Red3"/)



;  opts_ter@gsnMaximize = True
  opts_ter@gsnPaperOrientation = "portrait"
;  opts_ter@MainTitle = "Terrain Elevation"
  opts_ter@FieldTitle = "Terrain Elevation"
; opts_ter@ContourParameters = (/ 100. /)
  opts_ter@cnInfoLabelOn = False
  contour_ter = wrf_contour(a,wks,ter,opts_ter)

   opts_lmask = opts

   opts_lmask@UnitLabel            = ""
   opts_lmask@cnLevelSelectionMode = "ExplicitLevels"
   opts_lmask@cnLevels  = (/0.,.5/)

  opts_lmask@cnFillColors = (/"Transparent","Blue","Transparent"/)
  opts_lmask@FieldTitle = ""
  opts_lmask@lbLabelBarOn = False
  contour_lmask = wrf_contour(a,wks,lmask,opts_lmask)

  pltres = True                                ; Set plot options
  mpres = True                                 ; Set map options


  plot = wrf_map_overlays(a,wks,(/contour_ter,contour_lmask/),\
         pltres,mpres)

  txres               = True
  txres@txFontHeightF = 0.010
  txres@txFont        = "helvetica-bold"
  txres@txFontColor        = "Black"

;  text  = gsn_add_text(wks,plot,sprinti("%1.0i",sitechars(0:nrows-2)),\
;  lons(0:nrows-2),lats(0:nrows-2),txres)

  text  = gsn_add_text(wks,plot,sitecolors(0:nrows-2),\
  lons(0:nrows-2),lats(0:nrows-2),txres)

;  wmlabs(wks,30,30,"SUN")
  draw(plot)      ; Now draw map with text strings and
  frame(wks)

end
