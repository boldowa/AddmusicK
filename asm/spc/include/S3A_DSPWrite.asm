DSPWriteWithCheck:	
	push	a
	mov	a, !ChannelProcessingFlags	;\*if the current channel's bit flag
	and	a, !ChannelOccupancyFlags	;/*is also set to be muted on the mute channel's bit flag
	pop	a
	bne	+							;* then don't bother to DSP write since it's not receiving the note	
									; write A to DSP reg Y
DSPWrite:
	mov	!RegDSPComAdd, y			; DSP Communication Address
	mov	!RegDSPComDat, a			; DSP Communication Data
+	
	ret
	
ModifyNoise:				; A should contain the noise value.
	and	a, #$1f
	and	!NCKValue, #$e0		; Clear the current noise bits.
	or	a, !NCKValue		; \ Set and save the current noise bits.
	mov	!NCKValue, a		; / 
	mov	y, #$6c			; \ Write
	bra	DSPWrite		; /