PSwitchCh5:
	db $DA, $02					; @2
	db $30, $00,      $C6 		;     r=24
	db $20, $00, $26, $A4		; y0o4c=16
	db $10, $0A, $1D, $9F		; y5o3g=8
	db $10, $00,      $C6		;     r=8
	db $10, $13, $13, $AB		;y10o4g=8
	db $10, $17, $0F, $9F		;y12o3c=8
	db $20, $1D, $0A, $A4		;y15o4c=4
	db $10, $26, $00, $9F		;y20o3g=8
	
	db $30, $00,      $C6		;      r=24
	db $20, $26, $00, $A5		;y20o4c+=16
	db $10, $1D, $0A, $A0		;y15o3g+=8
	db $10, $00,      $C6		;      r=8
	db $10, $13, $13, $AC		;y10o4g+=8
	db $10, $0C, $18, $A0		; y7o3c+=8
	db $20, $1D, $0A, $A5		; y5o4c+=4
	db $10, $00, $26, $A0		; y0o3g+=8
	db $FE						; loop
	
PSwitchCh6:
	db $DA, $02	; @2
	db $20, $26, $00, $8C		; y0o2c=16	
	db $40,           $93		; y0o2g=8^24
	db $30,           $98		; y0o3c=24
	db                $93		; y0o2g=24

	db $20, $04, $22, $8D		; y2o2c+=16	
	db $40, $0A, $1D, $94		; y5o2g+=8^24
	db $30, $13, $13, $99		;y10o3c+=24
	db $30, $1E, $08, $94		;y16o2g+=24
	db $FE
	
PSwitchCh7:
	db $DA, $09					; @9
	db $10, $0D, $B0			; o4g=8
	db 	$B0						; o4g=8
	db	$B9						; o5e=8
	db	$B9						; o5e=8
	db $FE			
	