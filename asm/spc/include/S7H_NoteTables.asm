; for 0C89 - note dur%'s
NoteDurations:
	db $33, $66, $80, $99, $B3, $CC, $E6, $FF

; per-note velocity values
VelocityValues:
	db $08, $12, $1B, $24, $2C, $35, $3E, $47, $51, $5A, $62, $6B, $7D, $8F, $A1, $B3	; Normal, SMW velocities.
	db $19, $33, $4C, $66, $72, $7F, $8C, $99, $A5, $B2, $Bf, $CC, $D8, $E5, $F2, $FC	; Standard N-SPC velocities.

; pan table (max pan full L = $14.00)
PanValues:
	db $00, $01, $03, $07, $0D, $15, $1E, $29, $34, $42, $51, $5E, $67, $6E, $73, $77
	db $7A, $7C, $7D, $7E, $7F






; default values (1295) for DSP regs (12A1)
;  mvol L/R max, echo vol L/R zero, FLG = echo off/noise 400HZ
;  echo feedback = $60, echo/pitchmod/noise vbits off
;  source dir = $8000, echo ram = $6000, echo delay = 32ms

DefDSPValues:
		db $7F, $7F, $00, $00, $2F, $60, $00, $00, $00, $2F, $60, $00 

DefDSPRegs:
		db $0C, $1C, $2C, $3C, $6C, $0D, $2D, $3D, $4D, $5D, $6D, $7D

; echo filters 0 and 1
EchoFilter0:
	db $FF, $08, $17, $24, $24, $17, $08, $FF
EchoFilter1:
	db $7F, $00, $00, $00, $00, $00, $00, $00


; pitch table
PitchTable:
	dw $085f
	dw $08de
	dw $0965
	dw $09f4
	dw $0a8c
	dw $0b2c
	dw $0bd6
	dw $0c8b
	dw $0d4a
	dw $0e14
	dw $0eea
	dw $0fcd
	dw $10be