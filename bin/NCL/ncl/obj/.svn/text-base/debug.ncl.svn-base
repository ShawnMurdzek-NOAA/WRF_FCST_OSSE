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

