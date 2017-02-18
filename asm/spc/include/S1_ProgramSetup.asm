{		; Program setup
	clrp
	mov   x, #$cf
	mov   sp, x              ; set SP to 01cf
	mov   a, #$00				; value to clear $0100-$03FF with
	
	mov	y, #$00					; used to initialize the loop
	
-	mov	$0100+y, a				; \* clears out RAM at $100-$1FF, not blanking out $00-$ff as it contains important transferred data
	dbnz	y, -				; /* and $00-$ff gets updated before use anyway by the song/sfx
-	mov	$0200+y, a				; \* clears out RAM at $200-$2FF
	dbnz	y, -				; /*
-	mov	$0300+y, a				; \* clears out RAM at $300-$3FF
	dbnz	y, -				; /*
	
	movw	$00, ya				;* clears $00 and $01
	

	
	
	mov   x, #$0b
L_0529:
	;these cycles are used to format the DSP registers to prevent garbage from being audible
	;cycle B: DSP Reg $7D set to #$00 (Echo Delay disabled on all channels)
	;cycle A: DSP Reg $6D set to #$60 (Echo Location is at ARAM $6000)
	;cycle 9: DSP Reg $5D set to #$2F (Sample Location is at ARAM $2F00)
	;cycle 8: DSP Reg $4D set to #$00 (Echo disabled on all channels)
	;cycle 7: DSP Reg $3D set to #$00 (Noise mode disabled on all channels)
	;cycle 6: DSP Reg $2D set to #$00 (Pitch modulation disabled on all channels)
	;cycle 5: DSP Reg $0D set to #$60 (Echo feedback disabled except for channels 5 and 6)
	;cycle 4: DSP Reg $6C set to #$2F (Misc Voice Control enabled except for Mute and Reset)
	;cycle 3: DSP Reg $3C set to #$00 (Echo Volume R set to 00)
	;cycle 2: DSP Reg $2C set to #$00 (Echo Volume L set to 00)
	;cycle 1: DSP Reg $1C set to #$7F (Master Volume R set to max)
	;cycle 0: DSP Reg $0C set to #$7F (Master Volume L set to max)
	
	mov   a, DefDSPRegs+x		; DSP registers 
	mov   y, a
	mov   a, DefDSPValues+x
	call  DSPWrite             ; write A to DSP reg Y
	dec   x
	bpl   L_0529             ; set initial DSP reg values
	
	mov   !RegDSPControl, #$f0			; Reset ports, disable timers
	mov   !RegTimer0Target, #$10		; Set Timer 0's frequency to 2 ms
	mov   !Tempo, #$36					; Set the tempo to #$36
	mov   !RegDSPControl, #$01			; Reset and start timer 0
}	;goes straight into S2_MainLoop.asm