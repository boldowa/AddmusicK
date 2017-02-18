;;;;;;;;;;;;;;;;;;;

L_0FDB:	
	
	mov	a, !VolumeFadeDuration+x		
	beq	L_0FEB								;* Don't bother with the next few commands if the VolumeFade is not being processed
	or	(!ChannelVolumeUpdate), (!ChannelProcessingFlags) 
	%L_1075VolumeFadeSetup()
L_0FEB:
	mov	a, !Tremolo+x		;\ *
	mov	y, a				; |*
	beq	L_1013				;/ * if $b1+x is #$00, then just get the volume from the note
	mov	a, !TremoloDelay+x	;
	cbne	!VolumeUpdate+x, L_1011 	;* $b0+x is used as a flag to dictate if volume needs updating
	or	(!ChannelVolumeUpdate), (!ChannelProcessingFlags) ;seems pretty wasteful to branch the way it does above, why not just and with channel processing???
	mov	a, !TrueTremolo+x		
	bpl	L_1005			;\ if $0360+x is a positive value
	inc	y				; | or $b1+x (high byte for $b0+x?) was previously not #$FF?
	bne	L_1005			; |  then $0360+x = $0360+x + $0361+x (TrueTremolo + TremoloDuration0)
	mov	a, #$80			;/	otherwise $0360+x = #$80
	bra	L_1009
L_1005:
	clrc
	adc	a, !TremoloDuration+x
L_1009:
	mov	!TrueTremolo+x, a		; $0360+x = $0360+x + Tremolo+x ($0361+x)
	call	L_123A		; unless Tremolo is #$FF and $0360+x was above #$80, in which case it IS #$80 (caps the value???)
	bra	L_1019
L_1011:
	inc	!VolumeUpdate+x	;* indicate to the program that this channel needs it's volume updated
L_1013:
	mov	a, !NoteVolume+x         ; volume from note
	call	L_124D             ; set voice vol from master/base/note
L_1019:
	mov	a, !PanFadeDuration+x		;\ * If the pan is not done fading
	bne	L_1024						;/ * do the pan fade
	mov	a, !ChannelProcessingFlags	;\ *If the volume needs updating for the pan
	and	a, !ChannelVolumeUpdate		; |*then don't end the function
	bne	L_102D						;/ *
	ret
; do: pan fade and set volume
L_1024:
	%L_1075PanFadeSetup()	; see S0_Macros.asm
L_102D:
	mov	a, !Pan+x		; Get the pan for this channel.
	mov	y, a			;
	mov	a, !PanDelta+x	;*
	movw	$10, ya            ; set $10/1 from voice pan
; set voice volume DSP regs with pan value from $10/1
L_1036:
	mov	a, x		;
	xcn	a			;
	lsr	a			;
	mov	$12, a             ; $12 = voice X volume DSP reg
L_103B:
	mov	y, $11
	mov	a, PanValues+$01+y         ; next pan val from table
	setc
	sbc	a, PanValues+y         ; pan val
	mov	y, $10
	mul	ya
	mov	a, y
	mov	y, $11
	clrc
	adc	a, PanValues+y         ; add integer part to pan val
	mov	y, a
	mov	a, !TrueVolume+x         ; volume
	mul	ya
	
	mov	$14, y				; \ 
	mov	a, !VolumeMult+x	; | Add the computed volume to (computedvolume * volumemultipier / $100)
	mul	ya					; |
	mov	a, y				; |
	clrc					; |
	adc	a, $14				; |
	mov	y, a				; /
	
	mov	a, !SurroundSound+x         ; bits 7/6 will negate volume L/R
	bbc1	$12.0, L_105A			;* if $12's lowest bit is set, then it is because this is doing the R chan vol
	asl	a							;* right shift !SuroundSound+x's value to get the info for the right channel
L_105A:								;\* branch if bit 7 of a (!SurroundSound+x bit 7, left channel, 1st cycle or bit 6, right channel, 2nd cycle left shifted) 
	bpl	L_1061						;/* is set, as it means that the sound for this note is NOT mono
	mov	a, y						;\* flip the value that is the volume for this channel compared to the left value
	eor	a, #$ff						; |
	inc	a							; |
	mov	y, a						;/
L_1061:
	mov	a, y
	mov	y, $12
	call	DSPWriteWithCheck             ; set DSP vol if vbit 1D clear
	mov	a, #$00
	mov	y, #$14
	subw	ya, $10
	movw	$10, ya            ; $10/11 = #$1400 - $10/11
	inc	$12               ; go back and do R chan vol
	bbc1	$12.1, L_103B ;works since the lowest two bits are never utilized by calculations done in L_1036 due to the way the bits were swapped
	ret
	
	
;DSPWriteWithCheck		in		S3A_DSPWrite.asm
;L_124D					in
;%L_1075PanFadeSetup()	in 		S0_Macros.asm