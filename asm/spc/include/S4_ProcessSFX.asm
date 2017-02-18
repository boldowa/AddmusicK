ProcessSFX:	
{					
					; Major code changes ahead.
					; Originally, the SMW SFX were handled within their port handling routines.
					; This meant that there was a near duplicate copy of the 1DF9 code for 1DFC SFX.
					; It also meant that SFX were limited to just #4 and #6 (#7 was a special case).
					; This fixes that.
	
	mov	!ChannelProcessingFlags, #$00		; Let NoteVCMD know that this is SFX code.
	
	mov	x, #$0e						; For each voice (x = current channel * 2)
	mov	!CurrentChannelAlt, #$80	; $18 = bitwise indicator of current channel
.loop							;
	mov	a, !ChSFXPtrs+1+x		; If the high byte is zero, then there's no SFX here.  Skip it.
	beq	.nothing				;
	mov	!CurrentChannel, x		; $46 gets the channel currently being processed.
	call	HandleSFXVoice		;
.nothing						;
	lsr	!CurrentChannelAlt			;
	dec	x							;
	dec	x							;
	bpl	.loop						;
}	;goes straight into S4A_EffectModifier.asm, the others are dependencies

incsrc "S4A_EffectModifier.asm"
incsrc "S4B_GetNextSFXByte.asm"
incsrc "S4C_EndSFX.asm"
incsrc "S4D_HandleSFXVoice.asm"
