modl = getenv("MODEL") + " "
if (modl .eq. "HRRR ") then
  modl = "HRRRX "
end if
if (modl .eq. "HRRR-DEVEL ") then
  modl = "HRRRX DEVEL "
end if

