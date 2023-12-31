function gen_colormap( )
begin
        ;This procedure explicitly sets the red, green, and blue
        ;intensities for each element in a colormap array.
        ;
        return( (/ (/.000,.000,.000/), \   ; 0 (background)
                (/1.000,1.000,1.000/), \   ; 1 (foreground)
                (/.000,.184,1.000/), \     ; 2
                (/.082,.506,1.000/), \     ; 3
                (/.141,.675,.925/), \      ; 4 
                (/.000,.890,.902/), \      ; 5
                (/.333,.890,.000/), \      ; 6
                (/.667,1.000,.000/), \     ; 7
                (/1.000,1.000,.000/), \    ; 8
                (/1.000,.800,.000/), \     ; 9
                (/1.000,.600,.000/), \     ; 10
                (/1.000,.263,.000/), \     ; 11
                (/1.000,.392,1.000/), \    ; 12
                (/1.000,.620,.910/), \     ; 13
                (/1.000,1.000,1.000/), \   ; 14
                (/.000,.000,.000/), \      ; 15
                (/.749,1.000,1.000/), \    ; 16
                (/.000,.000,.588/), \      ; 17
                (/.000,.518,.000/), \      ; 18
                (/.980,.157,.157/), \      ; 19
                (/.392,.392,.392/), \      ; 20
                (/.500,.000,.500/), \      ; 21
                (/.350,.000,.350/), \      ; 22
                (/1.000,.000,.000/), \     ; 23 red added for hurricane tracks
                (/.600,.000,1.000/), \     ; 24 purple for 32 isotherm
                (/.600,.600,.600/) /) )    ; 25 
end
