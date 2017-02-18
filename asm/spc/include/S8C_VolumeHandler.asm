;;;;;;;;;;;;;;;;;;;;;;;;;;;;

L_122D:
{
	set1	$13.7				
	mov	y, !TempoSyncedTimer
	mov	a, !TremoloDuration+x
	mul	ya						; $49 * $0361+x
	mov	a, y
	clrc
	adc	a, !TrueTremolo+x
L_123A:
	asl	a
	bcc	L_123F					;* invert a if it was #$80 or higher before being multiplied by two????
	eor	a, #$ff					;* I presume this is to cover tremolo 
L_123F:
	mov	y, !Tremolo+x
	mul	ya
	mov	a, !NoteVolume+x
	mul	ya
	mov	a, y
	eor	a, #$ff
	setc
	adc	a, !NoteVolume+x
L_124D:
	mov	y, a
; set voice volume from master/base/A
	mov	a, !Volume+x	; Get volume
	mul	ya		; Multiply by qX
	mov	a, !MasterVolume             ; master volume
	mul	ya		; Multiply by master volume.
	mov	a, y		;
	mul	ya		; \ Vol = [(Vol^2) / 2] ?
	mov	a, y		; /
	mov	!TrueVolume+x, a         ; voice volume
	ret
}