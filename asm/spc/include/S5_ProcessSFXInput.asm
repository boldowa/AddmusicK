if !PSwitchIsSFX = !true

incsrc "p-switch/PMusic.asm"

endif

incsrc "S5A_SpeedUpMusic.asm"

ProcessAPU0Input:
{
	mov	a, $00				; \ If the value from $1DF9 was $80+, then play the "time is running out!" jingle.
	bmi	SpeedUpMusic			; /
	cmp	$00, #$11			; \
	beq	.skipSpeedUpCheck		; | Handle which sound effects can overwrite others (pause, unpause, low time)
	cmp	$00, #$12			; |
	beq	.skipSpeedUpCheck		; |
	cmp	$04, #$1d			; | Don't overwrite the "sound is running out!" sound effect.
	bne	.speedUpSFXIsOff			; /
.speedupSFXisOn	
	cmp	!ChSFXPtrs+$0d, #$00		; \ But if #$1d is no longer playing... 
	beq	.speedUpSFXIsOff		; /
	ret	
.skipSpeedUpCheck
.speedUpSFXIsOff
	mov	x, #$0c					; \ 
	mov	y, #$00					; | 
	mov	$10, #$40				; | 
	bra 	ProcessSFXInput		; / Actually a subroutine.
}
	
if !PSwitchIsSFX = !true

incsrc "include/p-switch/PlayPMusicAsSFX.asm"

endif

ProcessAPU3Input:
{
			if !PSwitchIsSFX = !true
				mov	a, $03				;
				bmi	PlayPSwitchSFX			;
			endif

	cmp	$07, #$1d				; \ No sound effects can overwrite #$1d
	bne .speedUpSFXIsOff		; | *flipped the flag and what branches off to save a simple branch. Originally this beq to the instruction below
								; / *but if it is going to just return if !ChSFXPTrs+$0f == #$00 and branch to .speedupSFXIsOff3 otherwise, why not set it up this way?
	cmp	!ChSFXPtrs+$0f, #$00	; \ But if #$1d is no longer playing... 
	bne EasyBail				; /
.speedUpSFXIsOff
	mov	x, #$0e				; \
	mov	y, #$03				; | 
	mov	$10, #$80			; | * goes to ProcessSFXInput directly due to reordering of branches
}

ProcessSFXInput:				; X = channel number * 2 to play a potential SFX on, y = input port to process, $10 = bitwise indicator of the current channel.
{
	mov	a, $0000+y			; \ If we've just received data from the SNES, prepare to process it.
	bne	PrepareForSFX		; / This involves keying off the correct channel.
EasyBail:
	ret					;

}
	
incsrc "S5B_PrepareForSFX.asm"	; ProcessSFXInput goes into this if new data for APU0 or APU3 occured



;***** SUB ROUTINE FOR PITCH SLIDE CALCULATION *****
L_09CD: ; add pitch slide delta and set DSP pitch, then jumps to SetPitch
{
	%L_1075PitchFadeSetup()                               
	mov	a, !CurrentNote+x
	mov	y, a
	call DDEEFix
	movw	$10, ya
	mov	!ChannelProcessingFlags, #$00          ; vbit flags = 0 (to force DSP set)
	jmp	SetPitch             ; force voice DSP pitch from 02B0/1
}

;******This file contains the 1DFA commands and their related subroutines, making it simpler to read and more structured. As a bonus, it actually saves a few bytes, too!

	incsrc "../1DFACommands.asm"

TableLookup1DFA:	;used to poll the different sound effects and commands used by 1DFA
	asl	a
	mov	x, a
	mov	a, #$00
	jmp	(CommandTable1DFA+x)        ;similar to L_0D40
	
ProcessAPU1Input:				; Input from SMW $1DFA
{
;#$FF = L_099C (Prepare for Data), #$01 = Jump SFX (unused in AMK typically) #$02 = EnableYoshiDrums, #03 = DisableYoshiDrums
;#$04 = Grinder Click (unused in AMK typically), #$05 = SFX Echo Off, #$06 = SFX Echo On, #$07 = Pause Music, #$08 = Unpause Music
	mov a, $01
	beq ProcessAPU1SFX		; nothing new
	inc a
	cmp a, #!CommandCount1DFA 	;no value higher than #$08 should have been received unless it was #$FF
	bcs ProcessAPU1SFX			
	call TableLookup1DFA		
	mov a, $01
	inc a						
	bne ProcessAPU1SFX			; #$FF + 1 = #$00 = BEQ, means #$FF will jump to the upload routine, otherwise, process APU1 SFX because it's not uploading
	jmp	L_12F2             	; do standardish SPC transfer                                ;ERROR
							; Note that after this, the program is "reset"; it jumps to wherever the 5A22 tells it to.
							; The stack is also cleared.
ProcessAPU1SFX:
	mov a, $05
	cmp a, #$01
	beq JumpSFXProcess			; L_0A51
	cmp a, #$05
	beq GrinderSFXProcess		; L_0A11
	ret
JumpSFXProcess: 	jmp L_0A51	;L_0A51
GrinderSFXProcess: 	jmp L_0B08 	;L_0B08
