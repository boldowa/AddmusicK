HandleSFXVoice:
{
	setp
	dec	!ChSFXNoteTimer+x
	clrp
	beq	+	
	jmp	.processSFXPitch
+
.getMoreSFXData
	call	GetNextSFXByte
	beq	EndSFX			; If the current byte is zero, then end it.
	bmi	.noteOrCommand		; If it's negative, then it's a command or note.
	mov	!ChSFXNoteTimerBackup+x, a			
					; The current byte is the duration.
	
	call	GetNextSFXByte		; Get the next byte.  It's either a volume or a command/note.
	bmi	.noteOrCommand		; If it's negative, then it's a command or a note.
	push	a			; \ This is a volume command.  Remember it for a moment.
	mov	a, !CurrentChannel			; | 
	lsr	a			; |
	xcn	a			; | Put the left volume DSP register for this channel into y.
	mov	y, a			; |
	pop	a			; |
	call	DSPWrite		; / Set the volume for the left speaker.
	inc	y			; \
	call	DSPWrite		; / Set the volume for the right speaker.  We might change it later, but this saves space.
	call	GetNextSFXByte		;
	bmi	.noteOrCommand		; If the byte is positive, then set the right volume to the byte we just got.

	call	DSPWrite		; > Set the volume for the right speaker.
	call	GetNextSFXByte		;
	bra	.noteOrCommand		; At this point, we must have gotten a command/note.  Assume that it is, even if it's not.
	
.executeCode				; 
	call	GetNextSFXByte		; \ 
	mov	$14, a			; | Get the address of the code to execute and put it into $14w
	call	GetNextSFXByte		; |
	mov 	$15, a			; / 
	push	x			; \ 
	mov	x, #$00			; | Jump to that address
	call	+			; | (no "call (d+x)")
	pop	x			; / 
	bra	.getMoreSFXData		;
+					;
	jmp	($14+x)			;
	
.noteOrCommand				; SFX commands!
	cmp	a, #$da			; \ 
	beq	.instrumentCommand	; / $DA is the instrument command.
	cmp	a, #$dd			; \ 
	beq	.pitchBendCommand	; / $DD is the pitch bend command.
	cmp	a, #$eb			; \ 
	beq	.pitchBendCommand2	; /*$EB is pitch bend release
	cmp	a, #$fd			; \ 
	beq	.executeCode		; / $FD is the code execution command.
	cmp	a, #$fe			; \
	beq	.loopSFX		; / $FE is the restart SFX command.
	cmp	a, #$ff			; \ 
	bne	.playNote		; / Play a note.
	mov	y, #$03			; Move back three bytes.
	;mov	x, $46			; \
-	mov	a, !ChSFXPtrs+x		; |
	bne	+			; |
	dec	!ChSFXPtrs+1+x		; | #$FF is the loop the last note command.
+					; |
	dec	!ChSFXPtrs+x		; |
	dbnz	y, -
	bra	.getMoreSFXData		; /
; other $80+
.loopSFX
	mov	a, !ChSFXPtrBackup+1+x	; \
	mov	!ChSFXPtrs+1+x, a	; | Set the current pointer to the backup pointer,
	mov	a, !ChSFXPtrBackup+x	; | Thus restarting this sound effect.
	mov	!ChSFXPtrs+x, a		; /
	bra	.getMoreSFXData
	
.playNote
	call	NoteVCMD		; Loooooooong routine that starts playing the note in A on channel (X/2).
	mov	a, !CurrentChannelAlt
	call	KeyOnVoices		; Key on the voice.
.setNoteLength
	mov	x, !CurrentChannel
	mov	a, !ChSFXNoteTimerBackup+x	
					; \ Get the length of the note back
	setp
	mov	!ChSFXNoteTimer+x, a	; / And since it was actually a length, store it.
	clrp
.processSFXPitch
	clr1	$13.7			; I...still don't know what $13.7 does...
	mov	a, !PitchFadeDuration+x		; pitch slide counter
	beq	++
	mov a, !PitchFadeDelay+x
	bmi ++
	bne +
	
	
	call	L_09CD			; add pitch slide delta and set DSP pitch
	jmp	.return1
+
	dec !PitchFadeDelay+x
	
++

	mov	a, #$02			; \
	;setp				; |
	;cmp a, !ChSFXNoteTimer,x
	;clrp
	cmp	a, !ChSFXNoteTimer|$0100+x	; |*this probably looks odd, but this is done to avoid setp/clrp usage on $01d0+x since the cmp command can accept it
	
	bne	.return1					; | If the time between notes is 2 ticks
	mov	a, !CurrentChannelAlt		; | Then key off this channel in preparation for the next note.
	call	KeyOffVoices
.return1
	ret
; DD
.pitchBendCommand			; This command is all sorts of weird.
	call	GetNextSFXByte		; The pitch of the note is this byte.
	call	NoteVCMD		; 
	mov	a, !CurrentChannelAlt			; \
	call	KeyOnVoices		; /
; EB
.pitchBendCommand2
	call	GetNextSFXByte			;
	mov	!PitchFadeDelay+x, a		;* How long before the pitch fade delay starts
	call	GetNextSFXByte			;
	mov	!PitchFadeDuration+x, a		;* Pitch duration
	push	a			;
	call	GetNextSFXByte		;
	pop	y			; I DON'T KNOW WHAT ANY OF THIS DOES! *sobs*
	call	CalcPortamentoDelta	; \ Calculate the pitch difference.
	bra	.setNoteLength		; /

; DA
.instrumentCommand
	mov	a, #$00					; \ Disable sub-tuning
	mov	!PitchSubmultiplier+x, a; /
	
	mov	a, !CurrentChannelAlt	; \
	eor	a, #$ff					; |
	and	a, !SFXNoiseChannels	; | Disable noise for this channel.
	mov	!SFXNoiseChannels, a	; /
					; (EffectModifier is called a bit later)
.getInstrumentByte
	call	GetNextSFXByte		; Get the parameter for the instrument command.
	bmi	.noise					; If it's negative, then it's a noise command.
	mov	y, #$09					; \ No noise here!
	mul	ya						; | Set up the instrument table for SFX
	mov	x, a					; |
	mov	a, !CurrentChannel		; | \
	xcn	a						; | | Get the correct DSP register "base" into y.
	lsr	a						; | |
	mov	y, a					; | /
	mov	$12, #$08				; / 9 bytes of instrument data.
-								; \
	mov	a, SFXInstrumentTable+x	; |
	call	DSPWrite			; | Loop that sets various DSP registers.
	inc	x						; |
	inc	y						; |
	dbnz	$12, -    			; / 
	mov	a, SFXInstrumentTable+x ; \
	mov	x, !CurrentChannel		; |
	mov	!PitchMultiplier+x, a	; / Something to do with pitch...?
	jmp	.getMoreSFXData			; / We're done here; get the next SFX command.
.noise	
	and	a, #$1f					; \ Noise can only be from #$00 - #$1F
	call	ModifyNoise
	
	or	(!SFXNoiseChannels), (!CurrentChannelAlt)

	bra	.getInstrumentByte	; Now we...go back until we find an actual instrument?  Odd way of doing it, but I guess that works.
}

;NoteVCMD 		in 	S3_NoteVCMD.asm
;DSPWrite 		in	S3A_DSPWrite.asm
;ModifyNoise	in	S3A_DSPWrite.asm
;GetNextSFXByte	in	S4B_GetNextSFXByte.asm
;KeyOnVoices	in	S7D_KeyOnVoices.asm
