SpeedUpMusic:
{
	mov	a, #$0a
	mov	!LoTimeTempoSpeedGain, a
	mov	a, !Tempo
	call	L_0E14             	; add #$0A to tempo; zero tempo low. See Commands.asm
	mov	a, #$1d					; adds #$1d to $00 and $03, #$00 to $04 and $07
	mov	$03, a
	mov	$00, a
	mov	a, #$00
	mov	$04, a
	mov	$07, a
}							; goes directly into ProcessAPU0Input
