PrepareForSFX:	
{				;
	mov	$0004+y, a			; > Tell the SPC to process this SFX.
	mov	a, $10				; \
	push	y
	call	KeyOffVoices
	pop	y
	or	(!ChannelOccupancyFlags), ($10)			;
	call	EffectModifier
	mov	a, #$00						; \
	mov	!PitchEnvelopeDuration+x, a	; /
	
	push	y				;
	mov	a, $0004+y			; \ 
	asl	a					; |
	mov	y, a				; | Y = SFX * 2, index to a table.
	pop	a					; | If a is 0, then the table we load from table 1.
	cmp	a, #$00				; | Otherwise, we load from table 2.
	beq	+					; /
	
	mov	a, SFXTable1-2+y		; \
	push	a					; | Move the pointer to the current SFX to the correct pointer.
	mov	a, SFXTable1-1+y		; |
	bra	.gottenPointer			;
						
+						;
	mov	a, SFXTable0-2+y		; \
	push	a					; |
	mov	a, SFXTable0-1+y		; /
	
.gottenPointer
	mov	!ChSFXPtrs+1+x, a			; Store to current pointer
	mov	!ChSFXPtrBackup+1+x, a		; And backup pointer.
	pop	a							;
	mov	!ChSFXPtrs+x, a				; Store to current pointer.
	mov	!ChSFXPtrBackup+x, a		; And backup pointer.
	
	mov	a, #$02
	setp
	mov	!ChSFXNoteTimer+x, a		; Prevent an edge case.
	clrp
	ret
}

;call KeyOffVoices		in	S7D_KeyOnVoices.asm
;call EffectModifier	in 	S4A_EffectModifier.asm	
