load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
;
begin
;
  fname = asciiread("arw_file.txt",-1,"string")
  grb_file = addfile(fname,"r")
;
  names = getfilevarnames(grb_file)  ; Get the variable names in the
  print(names)                       ; GRIB file and print them out.
;
  do i = 0, dimsizes( names ) - 1
    print("Variable Name: " + names(i))
    dims = getfilevardims(grb_file,names(i))
    sizes = filevardimsizes(grb_file,names(i))
    print(dimsizes(sizes) + " Dimensions:")
    if(.not.any(ismissing(dims))) then
      do j = 0, dimsizes(dims) -1
        print( j + ") " + dims(j) + ": " + sizes(j))
      end do  
    end if
    atts = getfilevaratts(grb_file,names(i))
    if(.not.any(ismissing(atts))) then
      do k = 0, dimsizes(atts) -1
        print(atts(k) + ": " +grb_file->$names(i)$@$atts(k)$)
      end do
    end if
    delete(atts)
    delete(dims)
    delete(sizes)
    print("")
  end do
  atts = getfilevaratts(grb_file,names(0)) ; Get the variable attributes and
  dims = getfilevardims(grb_file,names(0)) ; dimension names from the GRIB
  print(atts)                              ; file and print them out.
  print(dims)
;
;levs = grb_file->lv_ISBL0(:)
;print(levs)
; originally 166,319
lat = grb_file->gridlat_0(166,319)
print(lat)
lon = grb_file->gridlon_0(166,319)
print(lon)
cape = grb_file->CAPE_P0_L1_GLC0(166,319)
print(cape)
cin = grb_file->CIN_P0_L1_GLC0(166,319)
print(cin)
;lat = grb_file->gridlat_252(:,:)
;lon = grb_file->gridlon_252(:,:)
;hlcy = grb_file->HLCY_P0_2L103_GLC0(1,:,:)
;print(hlcy)
;print(grb_file->HLCY_P0_2L103_GLC0(0,:,:))
;print(levs)
;pres = grb_file->PRES_P0_L104_GLC0(49,:,:)
;print(pres)
;weasd = grb_file->WEASD_P0_L1_GLC0(:,:)
;print(weasd)
;
end
