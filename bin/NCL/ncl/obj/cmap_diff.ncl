function gen_colormap( )
begin
        ;This procedure explicitly sets the red, green, and blue
        ;intensities for each element in a colormap array.
        ;
        return( (/ (/.000,.000,.000/), \   ; 0 (background)
                (/1.000,1.000,1.000/), \   ; 1 (foreground)
                (/1.000,.300,.125/), \     ; 2
                (/.875,.300,.250/), \      ; 3
                (/.750,.300,.375/), \      ; 4
                (/.625,.300,.500/), \      ; 5
                (/.500,.300,.625/), \      ; 6
                (/.375,.300,.750/), \      ; 7
                (/.250,.300,.875/), \      ; 8
                (/.125,.300,1.000/), \     ; 9
                (/1.000,1.000,1.000/), \   ; 10
                (/.125,.600,.000/), \      ; 11
                (/.250,.600,.000/), \      ; 12
                (/.375,.700,.000/), \      ; 13
                (/.500,.700,.000/), \      ; 14
                (/.625,.800,.000/), \      ; 15
                (/.750,.800,.000/), \      ; 16
                (/.875,.900,.000/), \      ; 17
                (/1.000,.900,.000/), \     ; 18
                (/.400,.400,.400/), \      ; 19
                (/.500,.500,.500/) /) )    ; 20
end

