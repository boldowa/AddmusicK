; fade volume out over 240 counts
FadeOut:
{
	mov	x, #$f0
	mov	!MasterVolumeFadeDuration, x
	mov	a, #$00
	mov	!MasterVolumeFadeDestination, a
	setc
	sbc	a, !MasterVolume
	call	Divide16
	movw	!MasterVolumeFadeDelta, ya            ; set volume fade out after 240 counts
	bra	L_0BE7

;
;L_0BE7 is in S7_ProcessMusicInput, which this is a dependency of. 
;It checks to see if the wait time between song checks is over and if a new song has been set after branching from the fadeout