; calculate portamento delta
CalcPortamentoDelta:
{
	and	a, #$7f
	mov	!PortamentoFadeDestination+x, a         ;* final portamento value ($02d0+x)
	setc
	sbc	a, !CurrentNote+x         ; note number
	push	a
	mov	a, !PitchFadeDuration+x           ;* portamento steps ($90+x)
	mov	x, a
	pop	a
	call	Divide16
	mov	!PortamentoDelta+x, a
	mov	a, y
	mov	!PortamentoTo+x, a         ; portamento delta
	ret
}

; signed 16 bit division
Divide16:
{
	bcs	L_0F85
	eor	a, #$ff
	inc	a
	call	L_0F85
	movw	$14, ya
	movw	ya, !Easy16bitZero
	subw	ya, $14
	ret
L_0F85:
	mov	y, #$00
	div	ya, x
	push	a
	mov	a, #$00
	div	ya, x
	pop	y
	mov	x, !CurrentChannel ;Makes sure to place the channel back in since we used x for containing a division calculation 
	ret
}

;************** add fade delta to value (set final value at end)
L_1075:
{
	movw	$14, ya		;* plugs $0240 as the 16-bit address contained if called from volume fade, $02b0 if pitch slide, $0280 if pan fade
	bne	L_1088			;* Branches if !PanFadeDuration, !PitchSlideDuration or !VolumeFadeDuration is not 0 ---***
						;* This is presumably done such that on the last fade cycle ($80+x = #$01 dec -> $80+x = #$00) it instead processes the following
	clrc				; \* $16 gets the passed pointer, and stores the address 20 further
	adc	a, #$20			; |* then $16 = address $0260 if called from volumefade, $02D0 from pitchslide and $02A0 from pan slide
	movw	$16, ya		; /
	mov	a, x			; \ mov y, x 
	mov	y, a			; / mov y, $48
	mov	a, #$00			;
	push	a			;*	pushes a value of #$00 to insert into ($14)+y later
	mov	a, ($16)+y		;* 	a gets this channel's pan-to/pitch-to/vol-fade-to value by looking for the address $0260+y/$02D0+y/$02A0+y
	inc	y				; 
	bra	L_109A			;
L_1088:				;
	clrc			;*	then $16 = address $0250 if called from volumefade, $02C0 from pitchslide and $0290 from pan slide
	adc	a, #$10		;
	movw	$16, ya	;
	mov	a, x		;
	mov	y, a		;* moves x into y because they didn't include an opcode for mov a, ($zz)+x in the SPC's set
	mov	a, ($14)+y	;
	clrc			;* a gets the value at $0240+y/$02B0+y/$0280+y
	adc	a, ($16)+y	;* and adds the value at $0250+y/$02C0+y/$0290+y 
	push	a		;* pushes a value of ($14)+y + ($16)+y to insert into ($14)+y
	inc	y			;
	mov	a, ($14)+y	;* a gets the value at $0241+y/$02B1+y/$0281+y
	adc	a, ($16)+y	;* and adds the value at $0251+y/$02C1+y/$0291+y
L_109A:				;
	mov	($14)+y, a	;* assigns the value to $0241+y/$02B1+y/$0281+y (!Pan = $0281+y, etc)
	dec	y			;* on last cycle assigns the fade destination value to the pan/pitch/volume so that it ends up exactly at the value requested
	pop	a			;* assigns the delta value of $0240+$0250/$02B0+$02C0/$0280+$0290
	mov	($14)+y, a	;* on last cycle assigns #$00 for the pan/pitch/volume delta at $0240+y/$02B0+y/$0280+y to indicate the slide is done
	ret			;
}