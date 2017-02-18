				; Call this routine to play the song currently in A.
PlaySong:
{
	mov	!SFXEchoChannels, y
L_0B5A:
	mov	!CurrentSong, a		; Song number goes into $06.
	asl a
	push a
	; MODIFIED CODE START
	mov	a,#$00			; Clear various new addresses.
	mov	x,#$07			; These weren't used before, so they weren't cleared before.
-					
	mov	!SNESSync+x,a		;
	dec	x					;
	bpl	-					;
	
	mov	!WaitTime, #$02		;
	mov	!SongCheckWait,#$02		;
	;MODIFIED CODE END
	pop y						;* Get the pointer for the current song, note that song value #$01 will be the start of the table
	mov	a, SongPointers-$02+y	;* so instead of being SongPointers and SongPointers+$01, it compensates for this since the song value is multiplied by two and zero should never reach this
	push	a				; MODIFIED
	mov	!SongRead, a
	mov	a, SongPointers-$01+y
	push	a				; MODIFIED
	mov	!SongReadLo, a		; $40.w now points to the current song.
	
	; MODIFIED CODE START
-	
	call	L_0BF0		; Get the first measure address.
	movw	$16, ya		; This is guaranteed to be valid, so save it and get the next one.
	mov	a, y		;
	bne	-			; Loop until the high byte of the measure address is 0
	
	mov	a, $16		; If the low byte of the current measure is #$FF, then we have one more to skip.
	beq	+			;
	call	L_0BF0		;
+
	movw	ya, !SongRead
	movw	!CustomInstrumentPos, ya
	
	pop	a
	mov	!SongReadLo, a
	pop	a
	mov	!SongRead, a
	; MODIFIED CODE END
	
	mov	x, #$0e            ; Loop through every channel
L_0B6D:
	mov	a, #$0a
	mov	!Pan+x, a         ; Pan[ch] = #$0A
	mov	a, #$ff
	mov	!Volume+x, a         ; Volume[ch] = #$FF
	%PlaySongClearOut()		; See S0_Macros.asm
	dec	x
	dec	x
	bpl	L_0B6D	
	%PlaySongClearOutB()	; a is still #$00, so the macro will be fine. See S0_Macros.asm
	mov	y, #$20
	
L_0B9C:
	mov	$02ff+y, a		
	dbnz	y, L_0B9C		; Clear out 0300-031f (this is a useful opcode...)
	
	call	EffectModifier
	bra	L_0BA5
;
L_0BA3:
	mov	!CurrentSong, a		; ???
L_0BA5:
	mov	a, !NCKValue		; \ 
	and	a, #$20			; | Disable mute and reset, reset the noise clock, keep echo off.
	mov	!NCKValue, a		; |
	mov	a, #$00			; |
	call	ModifyNoise		; /
	mov	a, !ChannelOccupancyFlags	
	eor	a, #$ff		
	jmp	KeyOffVoices		; Set the key off for each voice to ~$1D.  Note that there is a ret in DSPWrite, so execution ends here. (goto L_0586?)

}	


;ModifyNoise			in	S3A_DSPWrite.asm
;EffectModifier			in	S4A_EffectModifier.asm
;%PlaySongClearOut()	in	S0_Macros.asm
;%PlaySongClearOutB()	in	S0_Macros.asm
;KeyOffVoices			in
;L_0BF0					in	S6C_SongRead.asm