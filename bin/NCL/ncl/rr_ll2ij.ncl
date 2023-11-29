load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
;
fname = asciiread("arw_file.txt",-1,"string")
grb_file = addfile(fname,"r")
;
lat = grb_file->gridlat_0(:,:)
lon = grb_file->gridlon_0(:,:)
;
; Get the closest grid point for the lat/lon point
;
RAOBLAT=39.4095
RAOBLON=-83.8285
gridpts1 = wrf_latlon_to_ij(lat, lon, RAOBLAT, RAOBLON)
i1 = gridpts1(0)
j1 = gridpts1(1)
print("i1 = "+i1)
print("j1 = "+j1)
;
end
