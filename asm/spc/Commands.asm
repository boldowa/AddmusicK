arch spc700-raw
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
cmdDA:					; Change the instrument (also contains code relevant to $E5 and $F3).
{
	mov	x, !CurrentChannel			;;; get channel*2 in X
	mov	a, #$00			; \ It's not a raw sample playing on this channel.
	mov	!BackupSRCN+x, a	; /
	
	mov	a, !ChannelProcessingFlags			; \ 
	eor	a, #$ff			; | No noise is playing on this channel.
	and	a, !MusicNoiseChannels	; | (EffectModifier is called later)
	mov	!MusicNoiseChannels, a	; /
	
	call	GetCommandData		; 
SetInstrument:				; Call this to start playing the instrument in A.
	mov	$14, #InstrumentTable	; \ $14w = the location of the instrument data.
	mov	$15, #InstrumentTable>>8 ;/
	mov	y, #$06			; Normal instruments have 6 bytes of data.
	
	inc	a				; \ 
L_0D4B:					; |		???
	mov	!Sample+x, a	; |* $c1+x
	dec	a				; /
	
	bpl	.normalInstrument	; \ 
	mov	$14,#PercussionTable	; | If the instrument was negative, then we use the percussion table instead.	
	mov	$15,#PercussionTable>>8	; /
	setc				; \ 
	sbc	a, #$cf			; | Also "correct" A. (Percussion instruments are stored "as-is", otherwise we'd subtract #$d0.
	inc	y			; / Percussion instruments have 7 bytes of data.
	bra	+
	
	
.normalInstrument 
	cmp	a, #30			; \ 
	bcc 	+			; | If this instrument is >= $30, then it's a custom instrument.
	push	a			; |
	movw	ya, !CustomInstrumentPos ;| So we'll use the custom instrument table.
	movw	$14, ya			; |
	pop	a			; |
	setc				; |
	sbc	a, #30			; |
	mov	y, #$06			; /
+


ApplyInstrument:			; Call this to play the instrument in A whose data resides in a table pointed to by $14w with a width of y.
	mul	ya			; \ 
	addw	ya, $14			; |
	movw	$14, ya			; /

	mov   a, !ChannelProcessingFlags 			; \ 
	and   a, !ChannelOccupancyFlags				; | If there's a sound effect playing, then don't change anything.
	bne   .noSet								; /
	
	call	GetBackupInstrTable	; \
	movw	$10, ya			; /
	
	push	x			; \ 
	mov	a, x			; |
	xcn	a			; | Make x contain the correct DSP register for this channel's voice.
	lsr	a			; |
	or	a, #$04			; |
	mov	x, a			; /
	
	
	
	
	mov	y, #$00			; \ 
	mov	a, ($14)+y		; / Get the first instrument byte (the sample)
	
	mov	($10)+y, a		; (save it in the backup table)
	
	bpl	+			; If the byte was positive, then it was a sample.  Just write it like normal.
	
	push	y
	call	ModifyNoise		; EffectModifier is called at the end of this routine, since it messes up $14 and $15.
	pop	y
	or	(!MusicNoiseChannels), ($48)
	inc	x
	inc	y

-
	mov	a, ($14)+y			; \ 
+	mov	!RegDSPComAdd, x	; | 	
	mov	!RegDSPComDat, a	; |
	mov	($10)+y, a			; |
	inc	x					; | This loop will write to the correct DSP registers for this instrument.
	inc	y					; | And correctly set up the backup table.
	cmp	y, #$04				; |
	bne	-					; /
	
	pop	x
	mov	a, ($14)+y		; The next byte is the pitch multiplier.
	mov	$0210+x, a		;
	mov	($10)+y, a		;
	inc	y			;
	mov	a, ($14)+y		; The final byte is the sub multiplier.
	mov	$02f0+x, a		;
	mov	($10)+y, a		;
	
	inc	y			; If this was a percussion instrument,
	mov	a, ($14)+y		; Then it had one extra pitch byte.  Get it just in case.
	
	push	a	
	call	EffectModifier
	pop	a

.noSet
	ret
	
RestoreMusicSample:
	mov	a, #$01			; \ Force !BackupSRCN to contain a non-zero value.
	mov	!BackupSRCN+x, a	; /
	call	GetBackupInstrTable	; \ 
	movw	$14, ya			; |
UpdateInstr:
	mov	y, #$06
	mov	a, #$00
	jmp	ApplyInstrument		; / Set up the current instrument using the backup table instead of the main table.

GetBackupInstrTable:
	mov	$10, #$30		; \ 
	mov	$11, #$01		; |
	mov	y, #$06			; |
	mov	a, x			; | This short routine sets ya to contain a pointer to the current channel's backup instrument data.
	lsr	a			; | 
	mul	ya			; |	
	addw	ya, $10			; /
	ret

}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
cmdDB:					; Change the pan
{
	call  GetCommandData
	and   a, #$1f
	mov   !Pan+x, a         ; voice pan value
	mov   a, y
	and   a, #$c0
	mov   !SurroundSound+x, a         ; negate voice vol bits
	mov   a, #$00
	mov   !PanDelta+x, a	;* make sure that it won't try to pansweep since we set a value it should automatically be
	or    (!ChannelVolumeUpdate), (!ChannelProcessingFlags)       ; set vol chg flag
	ret
}
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
cmdDC:					; Fade the pan
{
	call  GetCommandData
	mov   !PanFadeDuration+x, a
	push  a
	call  GetCommandDataFast
	mov   !PanFadeDestination+x, a
	setc
	sbc   a, !Pan+x         ; current pan value
	pop   x
	call  Divide16             ; delta = pan value / steps
	mov   !PanToDelta+x, a
	mov   a, y
	mov   !PanTo+x, a
	ret
}
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
cmdDD:					; Pitch bend
{
	; Handled elsewhere.
}
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
cmdDE:					; Vibrato on
{
	call  GetCommandData
	mov   !VibratoDelay+x, a
	mov   a, #$00					;\*Clears the vibrato duration since there is no vibrato yet
	mov   !VibratoFadeDuration+x, a	;/*
	call  GetCommandDataFast
	mov   !VibratoRate+x, a ;$0331+x
	call  GetCommandDataFast
}
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
cmdDF:					; Vibrato off (vibrato on goes straight into this, so be wary.)
{
	mov   x, !CurrentChannel	;\
	mov   !Vibrato+x, a			;/
	ret
}
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
cmdE0:					; Change the master volume
{
	call  GetCommandData
	mov   !MasterVolume, a
	mov   !MasterVolumeWide, #$00			; 16-bit calculations should clear the MVol high bit
	mov   !ChannelVolumeUpdate, #$ff          ; all vol chgd
	ret
}
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
cmdE1:					; Fade the master volume
{
	call  GetCommandData
	mov   !MasterVolumeFadeDuration, a
	call  GetCommandDataFast
	mov   !MasterVolumeFadeDestination, a
	mov   x, !MasterVolumeFadeDuration
	setc
	sbc   a, !MasterVolume
	call  Divide16
	movw  !MasterVolumeFadeDelta, ya
	ret
}
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
cmdE2:					; Change the tempo
{
	call  GetCommandData
L_0E14: 
	adc   a, !LoTimeTempoSpeedGain			; WARNING: This is sometimes called to change the tempo.  Changing this function is NOT recommended!
	mov   !Tempo, a
	mov   !TempoWide, #$00
	ret
}
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
cmdE3:					; Fade the tempo
{
	call  GetCommandData
	mov   !TempoFadeDuration, a
	call  GetCommandDataFast
	adc   a, !LoTimeTempoSpeedGain
	mov   !TempoFadeDestination, a
	mov   x, !TempoFadeDuration
	setc
	sbc   a, !Tempo
	call  Divide16
	movw  !TempoFadeDelta, ya
	ret
}
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
cmdE4:					; Change the global transposition
{
	call  GetCommandData
	mov   !Transpose, a
	ret
}
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
cmdE5:					; Tremolo on
{
	call  GetCommandData
	;bmi   TSampleLoad		; We're allowed the whole range now.
	mov   !TremoloDelay+x, a
	call  GetCommandDataFast
	mov   !TremoloDuration+x, a
	call  GetCommandDataFast
;cmdE6:					; Normally would be tremolo off
cmdTremoloOff:
	mov   x, !CurrentChannel
	mov   !Tremolo+x, a
	ret
	
	;0DCA
TSampleLoad:
	and   a, #$7F
MSampleLoad:
	push	a
	mov	a, #$01
	mov	!BackupSRCN+x, a
	call	GetBackupInstrTable	; \ 
	movw	$14, ya			; /
	pop	a			; \ 
	mov	y, #$00			; | Write the sample to the backup table.
	mov	($14)+y, a		; /
	call	GetCommandData		; \ 
	mov	y, #$04			; | Get the pitch multiplier byte.
	mov	($14)+y, a		; /
	jmp	UpdateInstr

}	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
cmdE6:					; Second loop
{
	call  GetCommandData
	
	bne   label2			;* Branch if it's not the start of a subloop
	mov   a,!ChannelByte+x			; \
	mov   !SubloopPreserveByte+x,a	; | Save the current song position into $01e0
	mov   a,!ChannelHiByte+x		; |
	mov   !SubloopPreserveHiByte+x,a; /
	mov   a,#$ff				; \ Set init loop code(#$ff means loop count didn't init.)
	mov   !SubloopCounter+x,a	; / * done to tell the SPC engine that when it meets the subloop that it is the first loop
	ret				;
label2:					;
	mov	  y, a				
	mov   a,!SubloopCounter+x	;
	cmp   a,#$01			;
	bne   label3			; * if it's not the start of a subloop ($00) and it's the last loop ($01), then don't skip back, the subloop is done
	ret				;
label3:	
	cmp   a,#$ff				; * If this is the first time looping back, then branch, it requires initialization of the loop count
	beq   label4
	;setp								;\*
	;dec	!SubloopCounter_Short+x		;|* decrement the subloop counter
	;clrp								/*
	mov   a,!SubloopCounter+x			;\*
	dec   a								;|* decrement the subloop counter
	mov   !SubloopCounter+x,a			;/*
	bra   label5
label4:	
	mov	  a, y						; more efficient than push/pop, y will be cleared anyway
	mov   !SubloopCounter+x,a
label5:	
	mov   a,!SubloopPreserveByte+x
	mov   !ChannelByte+x,a
	mov   a,!SubloopPreserveHiByte+x
	mov   !ChannelHiByte+x,a
	ret
}	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
cmdED:					; ADSR
{
	
	call	GetCommandData		; \ 
	push	a			; /
	
	mov	a, #$01			; \ Force !BackupSRCN to contain a non-zero value.
	mov	!BackupSRCN+x, a	; /
	
	call	GetBackupInstrTable	; \ 
	movw	$14, ya			; /
	
	pop	a			; \ 
	eor	a,#$80			; | Write ADSR 1 to the table.
	bpl	.GAIN
	mov	y, #$01			; | 
	mov	($14)+y, a		; /
	call	GetCommandData		; \ 
	mov	y, #$02			; | Write ADSR 2 to the table.
-	mov	($14)+y, a		; /
	
	jmp	UpdateInstr
	
.GAIN
	mov	y, #$01			; \ 
	mov	($14)+y, a		; /
	call	GetCommandData		; \ 
	mov	y, #$03			; | Write GAIN to the table.
	bra	-
		
}
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
cmdE7:					; Change the volume
{
	call  GetCommandData
	mov   !Volume+x, a
	mov   a, #$00
	mov   !VolumeDelta+x, a	;*Ensures no attempt at a volume fade is made
	or    (!ChannelVolumeUpdate), (!ChannelProcessingFlags)       ; mark volume changed
	ret
}
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
cmdE8:					; Fade the volume
{
	call  GetCommandData
	mov   !VolumeFadeDuration+x, a
	push  a
	call  GetCommandDataFast
	mov   !VolumeFadeDestination+x, a
	setc
	sbc   a, !Volume+x
	pop   x
	call  Divide16
	mov   !VolumeToDelta+x, a		
	mov   a, y
	mov   !VolumeTo+x, a
	ret
}
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
cmdE9:					; Loop
{
	call  GetCommandData
	push  a
	call  GetCommandDataFast
	push  a
	call  GetCommandDataFast
	mov   !RepeatCounter+x, a           ; repeat counter = op3
	mov   a, !ChannelByte+x
	mov   !LoopToPointLo+x, a
	mov   a, !ChannelHiByte+x
	mov   !LoopToPointHi+x, a         ; save current vptr in 3E0/1+X
	pop   a
	mov   !ChannelHiByte+x, a
	mov   !LoopFromPointHi+x, a
	pop   a
	mov   !ChannelByte+x, a
	mov   !LoopFromPointLo+x, a         ; set vptr/3F0/1+X to op1/2
	ret
}
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
cmdEA:					; Fade the vibrato
{
	call  GetCommandData
	mov   !VibratoFadeDuration+x, a
	push  a
	mov   a, !Vibrato+x
	mov   !VibratoPreserve+x, a
	pop   x
	mov   y, #$00
	div   ya, x
	mov   x, !CurrentChannel
	mov   !VibratoFadeDelta+x, a
	ret
}
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
cmdEB:					; Pitch envelope (release)
{
	mov   a, #$01
	bra   L_0E55
}
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
cmdEC:					; Pitch envelope (attack)
{
	mov   a, #$00
L_0E55: 
	mov   x, !CurrentChannel
	mov   !PitchEnvelopeType+x, a ;$0320+x
	call  GetCommandData
	mov   !PitchEnvelopeDelay+x, a ;$0301+x
	call  GetCommandDataFast
	mov   !PitchEnvelopeDuration+x, a ;$0300+x
	call  GetCommandDataFast
	
	mov   !PitchEnvelopeSemitone+x, a ;$0321+x
	ret
}

cmdPitchEnvOff:
{
	mov   x, !CurrentChannel
	mov   !PitchEnvelopeDuration+x, a
	ret
}
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
cmdEE:					; Set the tuning
{
	call  GetCommandData
	mov   !Portamento+x, a
	ret
}
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
cmdEF:					; Echo command 1 (channels, volume)
{
	call	GetCommandData
	mov	!MusicEchoChannels, a
	call	EffectModifier
	call	GetCommandDataFast
	mov	a, #$00
	movw	!EchoVolumeLeft, ya            ; set 61/2 from op2 * $100 (evol L)
	call	GetCommandDataFast
	mov	a, #$00
	movw	!EchoVolumeRight, ya            ; set 63/4 from op3 * $100 (evol R)
				
; set echo vols from shadows
L_0EEB: 
	mov	a, !EchoVolumeLeftLo
	mov	y, #$2c
	call	DSPWrite             ; set echo vol L DSP from $62
	mov	a, !EchoVolumeRightLo
	mov	y, #$3c
	jmp	DSPWrite             ; set echo vol R DSP from $64
}
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
cmdF0:					; Echo off
{
	mov	x, !CurrentChannel	
	mov	!MusicEchoChannels, a           ; clear all echo vbits
	push	a
	call	EffectModifier
	pop	a
L_0F22: 
	mov	y, a
	movw	!EchoVolumeLeft, ya     ; zero echo vol L shadow
	movw	!EchoVolumeRight, ya    ; zero echo vol R shadow
	call	L_0EEB             		; set echo vol DSP regs from shadows
	or	a, #$20
	mov	y, #$6c
	mov	!NCKValue, a
	jmp	DSPWrite             ; disable echo write, noise freq 0
}
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
cmdF1:					; Echo command 2 (delay, feedback, FIR)
{
	call	GetCommandData
	cmp	a, !MaxEchoDelay
	beq	.justSet
	bcc	.justSet
	bra	.needsModifying
.justSet
	mov	!EchoDelay, a		; \
	mov	!RegDSPComAdd, #$7d		; | Write the new delay.
	mov	!RegDSPComDat, a			; /
	bra	+++++++++		; Go to the rest of the routine.
.needsModifying
	call	ModifyEchoDelay

+++++++++		
	;mov	$f2, #$6c		; \ Enable echo and sound once again.
	;mov	$f3, !NCKValue		; /
	and	!NCKValue, #$1f
	mov	a, #$00
	call	ModifyNoise
	
	call	GetCommandData		; From here on is the normal code.
	mov	y, #$0d			;
	call	DSPWrite		; set echo feedback from op2
	call	GetCommandDataFast	;
	mov	y, #$08			;
	mul	ya			;
	mov	x, a			;
	mov	y, #$0f			;
- 					;
	mov	a, EchoFilter0+x	; filter table
	call	DSPWrite		;
	inc	x			;
	mov	a, y			;
	clrc				;
	adc	a, #$10			;
	mov	y, a			;
	bpl	-			; set echo filter from table idx op3
	mov	x, !CurrentChannel			;

	jmp	L_0EEB			; Set the echo volume.
	
WaitForDelay:				; This stalls the SPC for the correct amount of time depending on the value in !EchoDelay.
	mov	a, !EchoDelay		; a delay of $00 doesn't need this
	beq	+
	mov	$14, #$00
	mov	!RegDSPComAdd, #$6D
	mov	$15, !RegDSPComDat ;* read value in DSP regiter $6D to locate the echo waveform location
	mov	a, #$00
	mov	y, a
	
-	mov	($14)+y, a		; clear the whole echo buffer
	dbnz	y, -
	inc	$15
	bne	-
	
+	ret
	
GetBufferAddress:		;if
	cmp	a, #$00		;
	beq	+
	and a, #$0F			;\
	xcn a				;/*equivalent of 4 asl a, saves a whopping 1 byte ~wow~
	;asl	a			; \
	;asl	a			; |
	;asl	a			; |
	;asl	a			; | Gets the size of the buffer needed to hold an echo delay this large.
	mov	y, #$80			; |
	mul	ya			; /
	
	;eor	a, #$ff			; \
	;mov	x, a			; |
	;mov	a, y			; |
	;eor	a, #$ff			; | All this needed to flip a and y (at least it's only 8 bytes).
	;mov	y, a			; |
	;mov	a, x			; /
	;inc	a			; \ incw in this case.
	;inc	y			; /
	mov	a, y
	eor a, #$ff
	inc a
	
	ret				; 
+
	;mov	a, #$fc			; \ A delay of 0 needs 4 bytes for no adequately explained reason.
	;mov	y, #$ff			; /
	dec a ;equivalent of mov a, #$ff
	ret
	
	
ModifyEchoDelay:			; a should contain the requested delay.

	push	a			; Save the requested delay.
	call	GetBufferAddress
	push	a

	mov	!NCKValue, #$60
	mov	a, #$00
	call	ModifyNoise
	
	pop	y			; \
	mov	!RegDSPComAdd, #$6d		; | Write the new buffer address.
	mov	!RegDSPComDat, y			; / 
	
	pop	a
	mov	!RegDSPComAdd, #$7d		; \
	mov	!RegDSPComDat, a			; | Write the new delay.
	mov	!EchoDelay, a		; |
	mov	!MaxEchoDelay, a	; /
	
	call	WaitForDelay		; > Wait until we can be sure that the echo buffer has been moved safely.

	
	mov	!NCKValue, #$40
	mov	a, #$00
	call	ModifyNoise
	
	
	
	call	WaitForDelay		; > Clear out the RAM associated with the new echo buffer.  This way we avoid noise from whatever data was there before.
	
	mov	!NCKValue, #$00
	mov	a, #$00
	jmp	ModifyNoise
	
}
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
cmdF2:					; Echo fade
{
	call  GetCommandData
	mov   !EchoFadeDuration, a
	call  GetCommandDataFast
	mov   !EchoFadeVolumeLeft, a
	mov   x, !EchoFadeDuration
	setc
	sbc   a, !EchoVolumeLeftLo
	call  Divide16
	movw  !EchoFadeVolumeLeftDelta, ya
	call  GetCommandDataFast
	mov   !EchoFadeVolumeRight, a
	mov   x, !EchoFadeDuration
	setc
	sbc   a, !EchoVolumeRightLo
	call  Divide16
	movw  !EchoFadeVolumeRightDelta, ya
	ret
}
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
cmdF3:					; Sample load command
{
	call GetCommandData
	jmp  MSampleLoad
}
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
cmdF4:					; Misc. command
{
	call	GetCommandData
	asl	a
	mov	x,a
	mov	a, #0
	jmp	(SubC_table+x)

SubC_table:
	dw	cmdYoshiBongoToggleCh5Only		; $00
	dw	cmdLegato				; $01
	dw	cmdLightStaccato			; $02
	dw	cmdEchoToggle				; $03
	dw	$0000					; $04
	dw	cmdSyncSNES				; $05
	dw	cmdYoshiBongoToggle			; $06
	dw	cmdNoTempoHike				; $07
	dw	cmdVTableToggle				; $08
	dw	cmdInstRestore				; $09
	dw	cmdTremoloOff				; $0A
	dw	cmdPitchEnvOff				; $0B
	dw	cmdRemoteCmdResetAll			; $0C
	dw	cmdRemoteCmdResetKOn			; $0D
	dw	cmdRemoteCmdResetVar			; $0E
	
cmdSyncSNES:
	mov    !SendByte1B, a	;|*but for whatever reason, does not do so for the second set, only the high byte and byte of the first are modified
	mov    !SendByte1, a	;/
	mov	a,#$02				; bit 2 is the toggle for sync in $0160
	bra	SNESSyncToggle
	
cmdYoshiBongoToggle:
	eor	(!YoshiDrumTracks), (!ChannelProcessingFlags); Handle the Yoshi drums.
	bra	YoshiBongoToggle
cmdYoshiBongoToggleCh5Only:
	eor (!YoshiDrumTracks), #$20
YoshiBongoToggle:
	call	HandleYoshiDrums		; Handle the Yoshi drums.
	mov	a,#$01
SNESSyncToggle:
	eor	a,!SNESSync
	mov	!SNESSync,a
	mov     x, !CurrentChannel
	ret

cmdLegato:
	mov	a, !LegatoEnabled
	eor	a, !ChannelProcessingFlags
	mov	!LegatoEnabled,a
	mov	a, !ChannelProcessingFlags	;\
	eor	a,#$FF						;| *sets the LegatoActive bit for this channel
	and	a, !LegatoActive			;|
	mov	!LegatoActive,a				;/
	mov     x, !CurrentChannel
	ret

cmdLightStaccato:
	mov	a, !WaitTime
	eor	a,#$03
	mov	!WaitTime,a
	mov     x, !CurrentChannel	
	ret

cmdEchoToggle:
	eor	(!MusicEchoChannels), (!ChannelProcessingFlags)
	mov     x, !CurrentChannel	
	jmp	EffectModifier
	

	

	
cmdNoTempoHike:
	mov	!LoTimeTempoSpeedGain, a	; | Set the tempo to normal.
	mov	x, !CurrentChannel			; |
	mov	a, !Tempo					; |
	jmp	L_0E14						; /
	
cmdVTableToggle:
	mov	!SecondVTable, #$01		; \
	mov	x, !CurrentChannel		; | Toggle which velocity table we're using.
	ret							; /
	
cmdInstRestore:
	mov     x, !CurrentChannel					; \ 
	mov	!BackupSRCN+x, a		; | And make sure it's an instrument, not a sample or something.
	jmp	RestoreInstrumentInformation	; / This ensures stuff like an instrument's ADSR is restored as well.
	
	
}
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
cmdF5:					; FIR Filter command.
{
		mov   y,#$0f
-		push  y
		call  GetCommandData
		pop   y
		call  DSPWrite
		mov   a,y
		clrc
		adc   a,#$10
		mov   y,a
		bpl   -
		ret
}
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
cmdF6:					; DSP Write command.
{
	call GetCommandData
	push a
	call GetCommandDataFast
	pop y
	jmp DSPWrite
	;ret
}
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
cmdF7:					; Originally the "write to ARAM command". Disabled by default.
{
;	call GetCommandData
;	push a
;	call GetCommandDataFast
;	mov $21, a
;	call GetCommandDataFast
;	mov $20, a
;	pop a
;	mov y, #$00
;	mov ($20)+y, a
;	ret
}
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
cmdF8:					; Noise command.
{
Noiz:
		call	GetCommandData
		or	(!MusicNoiseChannels), (!ChannelProcessingFlags)
		call	ModifyNoise
		jmp	EffectModifier		
}
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
cmdF9:					; Send data to 5A22 command.
{
	call	GetCommandData		; \ Get the next byte
	mov	!SendByte1B,a			; / Store it to the low byte of the timer.
	call	GetCommandDataFast	; \ Get the next byte
	mov	!SendByte1,a			; / Store it to the high byte of the timer.
	ret
}
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
cmdFA:					; Misc. comamnd that takes a parameter.
;HTuneValues
{
	call 	GetCommandData
	asl	a
	mov	x,a
	jmp	(SubC_table2+x)

SubC_table2:
	dw	.PitchMod		; 00
	dw	.GAIN			; 01
	dw	.HFDTune		; 02
	dw	.superVolume		; 03
	dw	.reserveBuffer		; 04
	dw	.gainRest		; 05
	dw	.manualVTable		; 06
	dw	.SetPWMBrrNum		; 07
	dw	.SetPWMFreq		; 08

.PitchMod
	call    GetCommandData		; \ Get the next byte
	mov     !MusicPModChannels, a	; | This is for music.
	jmp	EffectModifier		; / Call the effect modifier routine.
	
.GAIN	
	call    GetCommandData		; \ Get the next byte
	push	a			; / And save it.
	
	mov	a, #$01
	mov	!BackupSRCN+x, a
	
	call	GetBackupInstrTable	; \ 
	movw	$14, ya			; /
	
	pop	a			;
	mov     y, #$03			; \ GAIN byte = parameter
	mov 	($14)+y, a		; /
	mov	y, #$01			
	mov	a, ($14)+y		; \ Clear ADSR bit 7.
	and	a, #$7f			; /
	mov	($14)+y, a		;
	jmp	UpdateInstr
.HFDTune
	call	GetCommandData
	mov     !HTuneValues+x, a
	ret

.superVolume
	call    GetCommandData		; \ Get the next byte
	mov	!VolumeMult+x, a	; / Store it.
	or	(!ChannelVolumeUpdate), (!ChannelProcessingFlags)		; Mark volume changed.
	ret
	
.reserveBuffer
;	
	
	call	GetCommandData
	beq	.modifyEchoDelay
	cmp	a, !MaxEchoDelay
	beq	+
	bcc	+
	bra	.modifyEchoDelay
+
	mov	!EchoDelay, a		; \
	mov	!RegDSPComAdd, #$7d		; | Write the new delay.
	mov	!RegDSPComDat, a			; /
	
	and	!NCKValue, #$20
	mov	a, #$00
	jmp	ModifyNoise
	
	ret
	
.modifyEchoDelay
	push	a
	or	!NCKValue, #$20
	call	ModifyEchoDelay		; /
	pop	a			;
	mov	!MaxEchoDelay, a	;
	mov	x, !CurrentChannel			;
	ret				;
	
.gainRest
	;call	GetCommandData
	;mov	!RestGAINReplacement+x, a
	ret
	
.manualVTable
	call	GetCommandData		; \ Argument is which table we're using
	mov	!SecondVTable, a	; |
	mov	!ChannelVolumeUpdate, #$ff		; | Mark all channels as needing a volume refresh
	mov	x, !CurrentChannel			;
	ret				; /
	
.SetPWMBrrNum
	call	GetCommandData
	jmp	SetPWMBrrPtr

.SetPWMFreq
	call	GetCommandData
	mov	($100+!PWMFreq), a
	ret
}
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
cmdFB:					; Arpeggio command.
{
	ret
}	
	
cmdFC:
{
	call	GetCommandData				; \
	push	a					; | Get and save the remote address (we don't know where it's going).
	call	GetCommandDataFast			; |
	push	a					; /
	call	GetCommandDataFast			; \
	cmp	a, #$ff					; |
	beq	.noteStartCommand			; | Handle types #$ff, #$04, and #$00. #$04 and #$00 take effect now; #$ff has special properties.
	cmp	a, #$04					; |
	beq	.immediateCall				; |
	cmp	a, #$00					; |
	beq	ClearRemoteCodeAddressesPre		; /
							;
	pop	a					; \
	mov	!remoteCodeTargetAddr+1+x, a		; | Normal code; get the address back and store it where it belongs.
	pop	a					; |
	mov	!remoteCodeTargetAddr+x, a		; /
							;
	mov	a, y					; \ Store the code type.
	cmp	a, #$05
	bne +
	mov	a, #$03
	+
	mov	!remoteCodeType+x, a			; |
	call	GetCommandDataFast			; \ Store the argument.
	mov	!remoteCodeTimeValue+x, a		; /
	ret						;
	
	
.noteStartCommand					;
	pop	a					; \
	mov	!remoteCodeTargetAddr2+1+x, a		; | Note start code; get the address back and store it where it belongs.
	pop	a					; |
	mov	!remoteCodeTargetAddr2+x, a		; /
-							;
	call	GetCommandDataFast			; \ Get the argument and discard it.
	ret						; /
							
.immediateCall						;
	mov	a, !remoteCodeTargetAddr+x		; \
	mov	$14, a					; | Save the current code address.
	mov	a, !remoteCodeTargetAddr+1+x		; |
	mov	$15, a					; /
							;
	pop	a					; \
	mov	!remoteCodeTargetAddr+1+x, a		; | Retrieve this command's code address
	pop	a					; | And pretend this is where it belongs.
	mov	!remoteCodeTargetAddr+x, a		; /
	
	mov	a, $15					; \
	push	a					; | Push onto the stack, since there's a very good chance
	mov	a, $14					; | that whatever code we call modifies $14.w
	push	a					; /
	
	call	RunRemoteCode				; 
							;
	pop	a					; \
	mov	!remoteCodeTargetAddr+x, a		; | Restore the standard remote code.
	pop	a					; |
	mov	!remoteCodeTargetAddr+1+x, a		; /
							;
	;call	GetCommandDataFast			; \ Get the argument, discard it, and return.
	bra	-					; /

	
ClearRemoteCodeAddressesPre:
	pop	a
	pop	a
	call	GetCommandDataFast
	
ClearRemoteCodeAddresses:
	mov	a, #$00
RemoteCmdResetAll:
; Reset Key-ON type remote command
	call	cmdRemoteCmdResetKOn2

; Reset Remote command 1 - ...
RemoteCmdResetVar:
	mov	!remoteCodeTargetAddr+1+x, a
	mov	!remoteCodeTargetAddr+x, a
	mov	!remoteCodeTimeValue+x, a
	mov	!remoteCodeTimeLeft+x, a
	mov	!remoteCodeType+x, a
	mov	!runningRemoteCode, a
	ret
}

;---------------------------------------
; Reset Remote command All
;---------------------------------------
cmdRemoteCmdResetAll:
{
	mov	x, !CurrentChannel
	bra	RemoteCmdResetAll
}
;---------------------------------------
; Reset Non-KeyOn Remote command
;---------------------------------------
cmdRemoteCmdResetVar:
{
	mov	x, !CurrentChannel
	bra	RemoteCmdResetVar
}
;---------------------------------------
; Reset Key-ON type Remote command
;---------------------------------------
cmdRemoteCmdResetKOn:
{
	mov	x, !CurrentChannel
cmdRemoteCmdResetKOn2:
	mov	!remoteCodeTargetAddr2+1+x, a		; | Note start code; get the address back and store it where it belongs.
	mov	!remoteCodeTargetAddr2+x, a		; /
	ret
}

;---------------------------------------
; Subroutine-break command
;---------------------------------------
cmdFD:
cmdFE:
cmdFF:
;ret

;$f4 $0a        ; Tremolo off cmd (like $e5$00$00$00)
;$f4 $0b        ; Pitchenv off cmd (like $eb$00$00$00)
;$f4 $0c        ; Remote command reset all (like $fc$xx$xx$00$xx)
;$f4 $0d        ; Remote command reset (Key-ON type)
;$f4 $0e        ; Remote command reset (Non-Key-On type)
;$f4 $0f		; Exloop Return (uses 20 bytes for quick access to beginning of info)

 
;$fd            ; Loop break cmd
;$fe $xx $yy    ; Jump command.
               ; This command is used for #exloop.

;$fd ; loop break command
;$fe ; note macro set
;$fe $00			; no macro
;$fe $01-$7F		; play macro as long as note is running (no pitch adjust)
;$fe $80 $01-$7F 	; play macro's full length (no pitch adjust, ignores "true" note duration, use for patterns that exceed a whole note)
;$fe $80 $81-$FF 	; play macro's full length (with pitch adjust, ignores "true" note duration, use for patterns that exceed a whole note)
;$fe $81-$FF		; play macro as long as note is running (adjusted for pitch from middle C)
;$ff $xx; note macro loop, offset of $xx
