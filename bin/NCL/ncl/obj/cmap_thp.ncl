function gen_colormap( )
begin
        ;This procedure explicitly sets the red, green, and blue
        ;intensities for each element in a colormap array.
        ;
        return( (/ (/.000,.000,.000/), \   ; 0 (background)
                (/1.000,1.000,1.000/), \   ; 1 (foreground)
                (/.671,1.000,1.000/), \    ; 2
                (/.110,.000,1.000/), \     ; 3
                (/.490,.902,.361/), \      ; 4 
                (/.118,.600,.239/), \      ; 5
                (/1.000,1.000,.400/), \    ; 6
                (/1.000,.529,.298/), \     ; 7
                (/1.000,.098,.098/), \     ; 8
                (/.651,.188,.188/), \      ; 9
                (/.933,.000,.933/), \      ; 10
                (/.392,.392,.392/) /) )    ; 11
end
