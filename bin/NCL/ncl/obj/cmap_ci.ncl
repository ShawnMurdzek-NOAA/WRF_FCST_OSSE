function gen_colormap( )
begin
        ;This procedure explicitly sets the red, green, and blue
        ;intensities for each element in a colormap array.
        ;
        return( (/ (/.000,.000,.000/), \   ; 0 (background)
                (/1.000,1.000,1.000/), \   ; 1 (foreground)
                (/.067,.576,.067/), \      ; 2
                (/.067,.816,.067/), \      ; 3
                (/.533,1.000,.067/), \     ; 4 
                (/1.000,.855,.067/), \     ; 5
                (/.816,.553,.067/), \      ; 6
                (/1.000,.533,.067/), \     ; 7
                (/.937,.302,.067/), \      ; 8
                (/.816,.067,.067/), \      ; 9
                (/.576,.067,.067/), \      ; 10
                (/.392,.392,.392/) /) )    ; 11
end
