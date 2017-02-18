EffectModifier:					; Call this whenever either $1d or the various echo, noise, or pitch modulaion addresses are modified.
{	
	;push	x
	push	y
	mov	$10, #!MusicPModChannels	;
	mov	$12, #!SFXPModChannels		;
	mov	$14, #$d1			; The DSP register for pitch modulation - $10 and reversed.
	mov	y, #$00				;
	mov	$11, y				;
	mov	$13, y				;
	
						; $10 = the current music whatever
						; $12 = the current SFX whatever
-						
						; Formula: The output for the DSP register is
						; S'M + SE
						; Where 
						; M is !WhateverMusicChannels,
						; E is !WhateverSFXChannels.
						; and S is $1d (the current channels for which SFX are enabled)
						; Yay logic!
						
	mov	a, !ChannelOccupancyFlags	; \ a = S
	eor	a, #$ff						; | a = S'
	and	a, ($10)+y					; / a = S'M
	
	mov	$15, a

	mov	a, ($12)+y					; \ a = S
	and	a, !ChannelOccupancyFlags	; | a = SE
	or	a, $15						; / a = S'M + SE
	
	push y

	mov	y, a

	inc	$14				; \
	mov	a, $14				; | Get the next DSP register into a.
	xcn	a				; /
	
	mov	!RegDSPComAdd, a				; \ Write to the relevant DSP register.
	mov	!RegDSPComDat, y				; / (coincidentally, the order is the opposite of DSPWrite)
	
	pop	y				; \ Do this three times.
	inc y				; |
	cmp	y, #$03			; |
	bne	-				; /

	pop	y
	;pop	x
	ret
}