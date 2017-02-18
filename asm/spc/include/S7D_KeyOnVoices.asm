KeyOnVoices:
	push	a
	;mov	y, #$5c
	mov	a, #$00
	call	KeyOffVoices             ; key off none
	pop	a
	mov	y, #$4c
	call	DSPWrite             ; key on voices from A
	or	a, !PlayingVoices
	mov	!PlayingVoices, a
	ret

KeyOffVoicesWithCheck:
	push	a
	mov	a, !ChannelProcessingFlags
	and	a, !ChannelOccupancyFlags
	pop	a
	bne	+
KeyOffVoices:
	push	a
	eor	a, #$ff
	and	a, !PlayingVoices
	mov	!PlayingVoices, a
	pop	a
	mov	y, #$5c
	jmp	DSPWrite
+
	ret
	
;DSPWrite	in	S3A_DSPWrite.asm