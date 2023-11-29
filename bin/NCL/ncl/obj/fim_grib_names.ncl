; get the domain and test for a variable
;
grib1file = False
grib2file = False
if (domainname .eq. "fim") then
  gridname = "4"
  LAT="lat_4"
  LON="lon_4"
end if
if (domainname .eq. "129" .or. domainname .eq. "174" .or. \
    domainname .eq. "244") then 
  gridname = domainname
  LAT="lat_"+gridname
  LON="lon_"+gridname
end if
if (domainname .eq. "83" .or. domainname .eq. "130" .or. \
    domainname .eq. "236" .or. domainname .eq. "201" .or. \
    domainname .eq. "28") then
  gridname = domainname
  LAT="gridlat_"+gridname
  LON="gridlon_"+gridname
  ROT="gridrot_"+gridname
end if
if (domainname .eq. "africa" .or. domainname .eq. "cambodia" .or. \
    domainname .eq. "e_pacific" .or. domainname .eq. "europe" .or. \
    domainname .eq. "floating" .or. domainname .eq. "w_pacific") then
  gridname = "GDS0"
  LAT="g0_lat_1"
  LON="g0_lon_2"
end if
;
if (domainname .eq. "129") then
  if (isfilevar(grb_file,"APCP_P8_L1_GGA0_acc")) then
    grib2file = True
  else
    grib1file = True
  end if
else
  if (isfilevar(grb_file,"T_"+gridname+"_SFC")) then
    grib1file = True
  else
    grib2file = True
  end if
end if
;
if (.not.grib1file) then
  LAT="lat_0"
  LON="lon_0"
  sufx="_GLL0"
  if (domainname .eq. "83" .or. domainname .eq. "130" .or. \
      domainname .eq. "236" .or. domainname .eq. "201" .or. \
      domainname .eq. "28") then
    LAT="gridlat_0"
    LON="gridlon_0"
    ROT="gridrot_0"
    sufx="_GLC0"
  end if
  if (domainname .eq. "129") then
    sufx="_GGA0"
  end if
  if (domainname .eq. "83") then
    sufx="_GRLL0"
  end if
  if (domainname .eq. "201") then
    sufx="_GST0"
  end if
  LEVEL="lv_ISBL0"
  NATLEVEL="lv_HYBL1"
  TSFC="TMP_P0_L1"+sufx
  TISBL="TMP_P0_L100"+sufx
  T2M="TMP_P0_L103"+sufx
  TNAT="TMP_P0_L105"+sufx
  PVPTEMP="POT_P0_L7"+sufx
  DPTNAT="DPT_P0_L105"+sufx
  LHTFL="LHTFL_P0_L1"+sufx
  SHTFL="SHTFL_P0_L1"+sufx
  RHISBL="RH_P0_L100"+sufx
  RHNAT="RH_P0_L105"+sufx
  PW="PWAT_P0_L1"+sufx
  RHPW="CNWAT_P0_L200"+sufx
  TP="APCP_P0_L1"+sufx  ; accumulated over last fcst period
  CP="ACPCP_P0_L1"+sufx  ; accumulated over last fcst period
  WEASD="WEASD_P0_L1"+sufx
  PVU="UGRD_P0_L7"+sufx
  UISBL="UGRD_P0_L100"+sufx
  U10M="UGRD_P0_L103"+sufx
  PVV="VGRD_P0_L7"+sufx  ; not vertical velocity
  VISBL="VGRD_P0_L100"+sufx
  V10M="VGRD_P0_L103"+sufx
  WS80M="WIND_P0_L103"+sufx
  VVEL="VVEL_P0_L100"+sufx  ; this is vertical velocity
  PVPRES="PRES_P0_L7"+sufx
  CEIL="HGT_P0_L2"+sufx
  CTOP="HGT_P0_L3"+sufx
  GHISBL="HGT_P0_L100"+sufx
  GHNAT="HGT_P0_L105"+sufx
  MSLP="MSLMA_P0_L101"+sufx
  DSWRF="DSWRF_P0_L1"+sufx
  USWRF="USWRF_P0_L1"+sufx
  OLR="NLWRT_P0_L1"+sufx
  DLWRF="DLWRF_P0_L1"+sufx
  ULWRF="ULWRF_P0_L1"+sufx
  CWAT="CWAT_P0_L1"+sufx
  O3MR="O3MR_P0_L105"+sufx
  CNWAT="CNWAT_P0_L200"+sufx
  TPACC="APCP_P8_L1"+sufx+"_acc"  ; total precip, init to fcst
  CPACC="ACPCP_P8_L1"+sufx+"_acc"  ; total conv precip, init to fcst
  WEASDACC="WEASD_P8_L1"+sufx+"_acc"
  CIN=""  ; undefined, previously used for ash1
  GFLUX=""  ; undefined, previously used for ash2
  CFNSF=""  ; undefined, previously used for integrated ash
  BLI=""  ; undefined, previously used for integrated black carbon
  CFNLF=""  ; undefined, previously used for Cs1,Cs1b
  VBDSF=""  ; undefined, previously used for Cs2,Cs2b
  SI=""  ; undefined, previously used for integrated fine dust
  SLI=""  ; undefined, previously used for integrated organic carbon
  EMSP=""  ; undefined, previously used for integrated PM25
  KI=""  ; undefined, previously used for integrated sulf
  NLWRT="NLWRT_P0_L1"+sufx
  BLYDP="BLYDP_P0_L1"+sufx  ; old variable used for olr flux
  PV2PRES="PRES_P0_L7"+sufx
  PV2PTEMP="POT_P0_L7"+sufx
  PV2U="UGRD_P0_L7"+sufx
  PV2V="VGRD_P0_L7"+sufx
  AOD="MCONV_P0_L1"+sufx
else
  ;LAT defined above
  ;LON defined above
  ;ROT defined above
  LEVEL="lv_ISBL3"
  NATLEVEL="lv_HYBL4"
  TSFC="T_"+gridname+"_SFC"
  TISBL="T_"+gridname+"_ISBL"
  T2M="T_"+gridname+"_HTGL"
  TNAT="T_"+gridname+"_HYBL"
  PVPTEMP="POT_"+gridname+"_TRO"
  DPTNAT="DPT_"+gridname+"_HYBL"
  LHTFL="LHTFL_"+gridname+"_SFC"
  SHTFL="SHTFL_"+gridname+"_SFC"
  RHISBL="RH_"+gridname+"_ISBL"
  RHNAT="RH_"+gridname+"_HYBL"
  PW="PW_"+gridname+"_SFC"
  RHPW="CNWAT_"+gridname+"_EATM"
  TP="TP_"+gridname+"_SFC"  ; accumulated over last fcst period
  CP="CP_"+gridname+"_SFC"  ; accumulated over last fcst period
  WEASD="WEASD_"+gridname+"_SFC"
  PVU="UW_"+gridname+"_TRO"
  UISBL="UW_"+gridname+"_ISBL"
  U10M="UW_"+gridname+"_HTGL"
  PVV="VW_"+gridname+"_TRO"  ; not vertical velocity
  VISBL="VW_"+gridname+"_ISBL"
  V10M="VW_"+gridname+"_HTGL"
  WS80M="WS_"+gridname+"_HTGL"
  VVEL="PVV_"+gridname+"_ISBL"  ; this is vertical velocity
  PVPRES="P_"+gridname+"_TRO"
  CEIL="GH_"+gridname+"_CBL"
  CTOP="GH_"+gridname+"_CTL"
  GHISBL="GH_"+gridname+"_ISBL"
  GHNAT="GH_"+gridname+"_HYBL"
  MSLP="MMSP_"+gridname+"_MSL"
  DSWRF="DSWRF_"+gridname+"_SFC"
  USWRF="USWRF_"+gridname+"_SFC"
  OLR="NLWRT_"+gridname+"_SFC"
  DLWRF="DLWRF_"+gridname+"_SFC"
  ULWRF="ULWRF_"+gridname+"_SFC"
  CWAT="CWAT_"+gridname+"_SFC"
  O3MR="O3MR_"+gridname+"_HYBL"
  CNWAT="CNWAT_"+gridname+"_EATM"
  TPACC="TP_"+gridname+"_SFC_acc"  ; total precip, init to fcst
  CPACC="CP_"+gridname+"_SFC_acc"  ; total conv precip, init to fcst
  WEASDACC="WEASD_"+gridname+"_SFC_acc"
  CIN=""  ; undefined, previously used for ash1
  GFLUX=""  ; undefined, previously used for ash2
  CFNSF=""  ; undefined, previously used for integrated ash
  BLI=""  ; undefined, previously used for integrated black carbon
  CFNLF=""  ; undefined, previously used for Cs1,Cs1b
  VBDSF=""  ; undefined, previously used for Cs2,Cs2b
  SI=""  ; undefined, previously used for integrated fine dust
  SLI=""  ; undefined, previously used for integrated organic carbon
  EMSP=""  ; undefined, previously used for integrated PM25
  KI=""  ; undefined, previously used for integrated sulf
  NLWRT="NLWRT_"+gridname+"_SFC"
  BLYDP="BLYDP_"+gridname+"_SFC"  ; old variable used for olr flux
  PV2PRES="P_"+gridname+"_TRO"
  PV2PTEMP="POT_"+gridname+"_TRO"
  PV2U="UW_"+gridname+"_TRO"
  PV2V="VW_"+gridname+"_TRO"
  AOD="MCONV_"+gridname+"_SFC"
end if
