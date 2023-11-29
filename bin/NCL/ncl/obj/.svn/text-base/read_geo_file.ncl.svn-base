; reads the geo_em.d01.nc file for map attributes
;
cdf_file = addfile("geo_em.d01.nc","r")
;
center_lat = cdf_file@CEN_LAT
center_lon = cdf_file@CEN_LON
truelat1 = cdf_file@TRUELAT1
truelat2 = cdf_file@TRUELAT2
stand_lon = cdf_file@STAND_LON
pole_lat = cdf_file@POLE_LAT
pole_lon = cdf_file@POLE_LON
;
LcLat = cdf_file@corner_lats(0)
LcLon = cdf_file@corner_lons(0)
RcLat = cdf_file@corner_lats(2)
RcLon = cdf_file@corner_lons(2)
;

