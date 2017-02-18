DDEEFix:
{
	mov	a, !PitchFadeDuration+x
	beq	+
	mov	a, !PitchFadeDestination+x
	bra ++
+
	mov	a, !Portamento+x
	mov	!PitchFadeDestination+x, a
++
	ret
}