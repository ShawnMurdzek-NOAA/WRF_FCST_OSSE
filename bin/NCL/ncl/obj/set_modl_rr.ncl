;
modl = getenv("MODEL") + " "
if (modl .eq. "WRF-RR ") then
  modl = "RAP-primary-ESRL "
end if
if (modl .eq. "WRF-RR ARW ") then
  modl = "RAP-devel-ESRL "
end if
if (modl .eq. "WRF-RR2 ARW ") then
  modl = "RR-devel2 "
end if
if (modl .eq. "RR ") then
  modl = "RAP-cold-start-ESRL "
end if

