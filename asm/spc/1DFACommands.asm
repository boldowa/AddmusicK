;;;;;1DFA Commands and Sounds Table;;;;;

!CommandCount1DFA	= !InstructionCount1DFA+2 ;amount of commands + 1 to compensate for #$FF being in the table, this is what shall be read in main.asm
!InstructionCount1DFA = $08	; amount of commands

;assumes the following setup:
	;mov a, $01
	;beq ProcessAPU1SFX		; nothing new
	;inc a
	;cmp a, #$0A ;no value higher than #$08 (#$09 after the inc) should have been received unless it was #$FF (#$00 after the inc)
	;bcs ProcessAPU1SFX		
	;call 1DFATableLookup		
	;mov a, $01
	;inc a						
	;bne ProcessAPU1SFX			; #$FF + 1 = #$00 = BEQ, means #$FF will jump to the upload routine, otherwise, process APU1 SFX because it's not uploading
	;jmp	L_12F2             	; do standardish SPC transfer                                ;ERROR
							; Note that after this, the program is "reset"; it jumps to wherever the 5A22 tells it to.
							; The stack is also cleared.
;ProcessAPU1SFX:
	;mov a, $05
	;cmp a, #$01
	;beq JumpSFXProcess			; L_0A51
	;cmp a, #$05
	;beq GrinderSFXProcess		; L_0A11
	;ret
;JumpSFXProcess: 	jmp L_0A51	;L_0A51
;GrinderSFXProcess: jmp L_0B08 	;L_0B08

;******
;1DFATableLookup:
;	asl	a
;	mov	x, a
;	mov	a, #$00
;	jmp	(1DFACommandTable+x)        ;similar to L_0D40
;
;	incsrc "1DFACommands.asm"
;;;;;


CommandTable1DFA:
dw DataReceptionInit; #$FF ; previously labelled as L_09CC
dw no1DFAInstruct	; #$00 ; nothing to do, this would have been the result after it figured out that it wasn't any of the following in the original routine
dw MarioJumpSFXStart; #$01 ; previously labelled as L_0A14 (Jump SFX)
dw EnableYoshiDrums ; #$02
dw DisableYoshiDrums; #$03
dw NotJumpSFX		; #$04 ; (Grinder SFX) ;beq L_0A0E ;jmp L_0ACE 
dw ForceSFXEchoOff	; #$05
dw ForceSFXEchoOn	; #$06
dw PauseMusic		; #$07
dw UnpauseMusic		; #$08

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; PauseMusic and UnpauseMusic (#$07, #$08)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


UnpauseMusic:
	mov !ProtectSFX6, a	; a is already #$00
	mov a, #$12
	bra +
PauseMusic:
	mov a, #$11
	mov !ProtectSFX6, a
+
	mov !RegValue, a		; calls the equivalent of $1DF9 = #$11 if music paused, #$12 if not, these are of course the pause/unpause sfx
no1DFAInstruct:
	ret
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Force SFX Echo On/Off (#$05, #$06)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

ForceSFXEchoOff:
	mov	a, #$00
	bra	+
ForceSFXEchoOn:
	mov	a, #$ff
+	mov	!SFXEchoChannels, a
	call	EffectModifier
	ret
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Yoshi Drums Enable/Disable (#$02, #$03)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

EnableYoshiDrums:				; Enable Yoshi drums.
	mov	a, #$01
DisableYoshiDrums:				; And disable them. A is already passed as being #$00, so don't worry about assigning it
	mov	!YoshiDrumsEnable, a

HandleYoshiDrums:				; Subroutine.  Call it any time anything Yoshi-drum related happens.
	bne	.drumsOn			;
	mov	a, !YoshiDrumTracks	; 
	or	a, !ChannelMuted	;
	bra	+
.drumsOn					
	mov	a, !YoshiDrumTracks	; \ $5E = ($5E --/--> $6E)
	eor	a, #$ff				; | (Or $5E = $5E & ~$5C)
	and	a, !ChannelMuted	; / Basically, we're reverting whatever the Yoshi drums did to $5E.
+
	mov	!ChannelMuted, a
	call	KeyOffVoices
	ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Grinder Sound Effect (#$04), can theoretically be used for other special 1DFA sounds . . . . 
; but is relatively redundant with it occupying the same channel as $1DFC in Ch. 7. Would otherwise be straightforward to set up
; more sounds if 3 sound effect channels were still used like SMW initially did, but that would come at the cost of less complex music
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

NotJumpSFX:
	mov	a, $05			;
	cmp	a, #$01			;
	beq	SpecialSFXEnd	; Mario's jump sfx always has priority over other "normal" 1DFA sfx
	mov a, $01
	mov	$05, a
	bra SpecialSFXFinalize ;jumps into the following routine. Turns out the Grinder SFX startup code was a near duplicate of the Mario Jump's starting code.

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Jump Sound Effect (#$01)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

MarioJumpSFXStart:
	inc a
	mov	$05, a				; saves one byte, but works since a is #$0 before this
SpecialSFXFinalize:
	mov	a, #$04				; \
	mov	!SFXDelay, a	; / $0383 is a timer for the jump sound effect?
	mov	a, #$80				; \ Key off channel 7.
	call	KeyOffVoices
	set1	!ChannelOccupancyFlags.7		; Turn off channel 7's music
	;mov	a, #$00			;
	;mov	y, #$20		;
	;mov !ArpLength7, a	;* originally had L_0A28 here, which would clear out $0300-$031F. This meant that Mario's jumping could actually kill arpeggios!
	;mov !ArpTimeLeft7, a	;* so now it only does so on the channel it should. $1DFA commands now play on channel #7
SpecialSFXEnd:
	ret			; /

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Prepare to Receive Data (#$FF)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


DataReceptionInit:
	mov	!RegDSPComAdd, #$6c		; Mute, disable echo.  We don't want any rogue sounds during upload
	mov	!RegDSPComDat, #$60		; and we ESPECIALLY don't want the echo buffer to overwrite anything.
	mov	!NCKValue, #$60
	
	mov	a, #$ff
	call	KeyOffVoices
	
	mov	!RegDSPComAdd, #$7d		; Also set the delay to 0.
	mov	!RegDSPComDat, #$00		; 

	mov	a, #$00
	mov	!RegValue+2, a				; "Current" song value to be received
	mov	!CurrentSong, a				; Reset the song number
	mov	!LastRegValue+2, a			; Last Song byte received
	mov	!ChannelOccupancyFlags, a	;
	mov	a, !MaxEchoDelay	;
	call	EffectModifier
	ret								; do standardish SPC transfer   
				
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
; Mario Jump SFX Active Routine
; Not called from the table, it's done from main.asm to allow it to continue playing
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		

	
L_0A51:								;;;;;;;;/ Code change
	mov	a, !SFXDelay				; Process the $1DFA sound
	bne	L_0A2E						;* if the delay for the Jump SFX is not done decrementing, go to L_0A23, which will decrement it
	dbnz	!1DFASFXTimer, L_0A38	;* decrements $1C and goes to L_0A38 for pitchbend shenanigans if it's timer is not over
	mov	$05, #$00					;* done on the last frame to set the music back to normal
	clr1	!ChannelOccupancyFlags.7
	mov	x, #$0e
	mov	a, !BackupSRCN+$0e
	bne	RestoreSample7
	mov	a, !Sample7
	beq	L_0AB0			; -> ret, moved from L_0A67 branch to L_0AB0
	jmp	L_0D4B			; Restore the current instrument on the channel?
RestoreSample7:
	jmp	RestoreMusicSample
L_0A2E:
	dec	!SFXDelay				;* loop until the timer ends (#$04---->#$00)
	bne	L_0AB0					;* -> ret @ L_0A0D, change this to a more reasonable ret to branch to in order to keep this subroutine segregated
	mov	!1DFASFXTimer, #$30		;* set secondary timer for jump sfx	
L_0A68:
	call	L_0AB1
	mov	a, #$b2
	mov	!CurrentChannel, #$0e
	mov	x, #$0e
	call	NoteVCMD
	mov	y, #$00			;\*!PitchFadeDuration set to #$00 on channel 7
	mov	!PitchFadeDelay7, y			;| $91+x set to #$05 on channel 7 
	mov	y, #$05			;|
	mov	!PitchFadeDuration7, y			;/
	mov	a, #$b5			
	call	CalcPortamentoDelta
	mov	a, #$38
	mov	$10, a
	mov	y, #$70
	call	DSPWrite
	mov	a, #$38
	mov	$10, a
	mov	y, #$71
	call	DSPWrite
	mov	a, #$80
	call	KeyOnVoices
	bra L_0A99
L_0A38:
	cmp	!1DFASFXTimer, #$2a		;* when $1C drops down to #$2A, pitch the sound upward
	bne	L_0A99					;* why this wasn't placed closer to L_0A99 is anyone's guess
	mov	!CurrentChannel, #$0e
	mov	x, #$0e
	mov	y, #$00
	mov	!PitchFadeDelay7, y
	mov	y, #$12
	mov	!PitchFadeDuration7, y
	mov	a, #$b9
	call	CalcPortamentoDelta
L_0A99:
	mov	a, #$02
	cbne	!1DFASFXTimer, L_0AA5
	mov	a, #$80			;only set to #$80 and key off if the timer has hit the last frame for the jump sound
	call	KeyOffVoices
L_0AA5:
	clr1	$13.7
	mov	a, !PitchFadeDuration7
	beq	L_0AB0
	mov	x, #$0e
	call	L_09CD	; pitch slide subroutine
L_0AB0:
	ret
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Grinder SFX Active Routine
; Not called from the table, it's done from main.asm to allow it to continue playing
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

L_0B08:					;* misleading order, starts here and then jumps up in original file
{
	mov	a, !SFXDelay	;*Only do the the following if the delay is over, prevents $!DFA sounds from playing every frame
	bne	L_0AE8
	dbnz	!1DFASFXTimer, L_0AF2	;*if $1c is not on it's last loop, then go to L_0AF2, otherwise do the following
	mov	$05, #$00
	clr1	!ChannelOccupancyFlags.7
	mov	x, #$0e
	mov	a, !Sample7
	jmp	L_0D4B		; see cmdDA in Commands.asm for more
	
L_0AE8:

	dec	!SFXDelay			;* If there isn't a $1DFA sound currently playing
	bne	L_0B3F				;* ret, previously L_0AE7's
	mov	!1DFASFXTimer, #$18	;* sets the SFX timer to #$18
	bra	L_0AF7
	
L_0AF2:
	cmp	!1DFASFXTimer, #$0c	;* if it's at #$0C, alter the note
	bne	L_0B33
L_0AF7:
	mov	a, #$07
	call	L_0AB3
	mov	a, #$a4
	mov	!CurrentChannel, #$0e
	mov	x, #$0e
	call	NoteVCMD
L_0B1C:

	mov	a, #$28
	mov	$10, a
	mov	y, #$70
	call	DSPWrite
	mov	a, #$28
	mov	$10, a
	mov	y, #$71
	call	DSPWrite
	mov	a, #$80
	call	KeyOnVoices
L_0B33:
	mov	a, #$02
	cbne	!1DFASFXTimer, L_0B3F		;*only mov #$80 into a if $1c = #$02
	mov	a, #$80
	call	KeyOffVoices
L_0B3F:
	ret
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;******* 1DFA SFX Subroutine, Must Be Called And Not Jumped To ******
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

L_0AB1:				;called  by L_0A68 for the jump sfx
{
	mov	a, #$08
L_0AB3:				;called with a = #$07 by L_0AF7
	mov	y, #$09
	mul	ya
	mov	x, a
	mov	y, #$70
	mov	$12, #$08
L_0ABC:
	mov	a, SFXInstrumentTable+x
	call	DSPWrite
	inc	x
	inc	y
	dbnz	$12, L_0ABC
	mov	a, SFXInstrumentTable+x
	mov	!PitchMultiplier7, a
	ret
}
