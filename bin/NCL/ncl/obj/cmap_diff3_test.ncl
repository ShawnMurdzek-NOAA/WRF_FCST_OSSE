function gen_colormap( )
begin
        ;This procedure explicitly sets the red, green, and blue
        ;intensities for each element in a colormap array.
        ;
        return( (/ (/.000,.000,.000/), \   ; 0 (background)
                (/1.000,1.000,1.000/), \   ; 1 (foreground)
                (/.700,.700,.700/), \     ; 18 lt grey
                (/.200,.400,1.000/), \      ; 5 blue
                (/.700,.700,.700/), \     ; 18 lt grey
                (/.400,.800,1.000/), \      ; 6 lt blue
                (/.700,.700,.700/), \     ; 18 lt grey
                (/.000,.600,.000/), \      ; 8 dk green
                (/.700,.700,.700/), \     ; 18 lt grey
                (/.000,.900,.400/), \      ; 7 lt green
                (/1.000,1.000,1.000/), \   ; 10 white
                (/1.000,.600,.200/), \     ; 13 orange
                (/.700,.700,.700/), \     ; 18 lt grey
                (/.800,.400,.400/), \     ; 16 peach
                (/.700,.700,.700/), \     ; 18 lt grey
                (/1.000,.200,.000/), \     ; 14 red
                (/.700,.700,.700/), \     ; 18 lt grey
                (/.700,.500,.200/), \     ; 12 brown
                (/.700,.700,.700/), \     ; 18 lt grey
                (/.700,.700,.700/) /) )    ; 19 dk grey
end

