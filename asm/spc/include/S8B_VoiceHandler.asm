;
L_1170:
	mov	$12, a
	asl	a
	asl	a
	bcc	L_1178
	eor	a, #$ff
L_1178:
	mov	y, a
	mov	a, !Vibrato+x
	cmp	a, #$f1
	bcs	L_1185
	mul	ya
	mov	a, y
	mov	y, #$00
	bra	L_1188
L_1185:
	and	a, #$0f
	mul	ya
L_1188:
	bbc1	$12.7, L_1191
	movw	$12, ya
	movw	ya, !Easy16bitZero
	subw	ya, $12
L_1191:
	addw	ya, $10
	movw	$10, ya
L_1195:
	jmp	SetPitch
; per-voice fades/dsps?

HandleVoice:
{
	clr1	$13.7
	
	mov	a, !Tremolo+x
	beq	L_11A7					; can skip if tremolo is inactive
	mov	a, !TremoloDelay+x
	cbne	!VolumeUpdate+x, L_11A7
	call	L_122D             ; voice vol calculations
L_11A7:
	mov	a, !Pan+x
	mov	y, a
	mov	a, !PanDelta+x
	movw	$10, ya            ; $10/11 = voice pan value
	mov	a, !PanFadeDuration+x           ; voice pan fade counter
	bne	L_11B9
	bbs1	$13.7, L_11C3
	bra	L_11C6
L_11B9:
	mov	a, !PanTo+x
	mov	y, a
	mov	a, !PanToDelta+x         ; pan fade delta
	call	L_1201             ; add delta (with mutations)?
L_11C3:
	call	L_1036             ; set voice DSP regs, pan from $10/11
L_11C6:
	clr1	$13.7
	mov	a, !CurrentNote+x
	mov	y, a
	call DDEEFix
	movw	$10, ya            ; notenum to $10/11
	mov	a, !PitchFadeDuration+x; pitch slide counter
	beq	L_11E3
	mov	a, !PitchFadeDelay+x
	bne	L_11E3
	mov	a, !PortamentoTo+x
	mov	y, a
	mov	a, !PortamentoDelta+x
	call	L_11FF             ; add pitch slide delta
L_11E3:
	mov	a, !Vibrato+x			;\*More calculating to be done if Vibrato is active
	bne	L_11EB					;/*
L_11E7:
	bbs1	$13.7, L_1195		;\*brach if L_11FF was called, since it specifically sets $13.7. This happens if the pitch bend is active and no delay has occured
	ret							;/*the branch in particular is one to a jmp to SetPitch
L_11EB:
	mov	a, !VibratoDelay+x					;\*Keep processing as long as the vibrato has not met the full delay
	cbne	!VibratoDelayTimer+x, L_11E7	;/*Otherwise calculate the vibrato
	mov	y, !TempoSyncedTimer
	mov	a, !VibratoRate+x
	mul	ya
	mov	a, y
	clrc
	adc	a, !TrueVibrato+x
	jmp	L_1170
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

L_11FF:
{
	set1	$13.7
;
L_1201:
	movw	$16, ya
	mov	$12, y
	bbc1	$12.7, L_120E
	movw	ya, !Easy16bitZero
	subw	ya, $16
	movw	$16, ya
L_120E:
	mov	y, !TempoSyncedTimer
	mov	a, $16
	mul	ya
	mov	$14, y
	mov	$15, #$00
	mov	y, !TempoSyncedTimer
	mov	a, $17
	mul	ya
	addw	ya, $14
	bbc1	$12.7, L_1228
	movw	$14, ya
	movw	ya, !Easy16bitZero
	subw	ya, $14
L_1228:
	addw	ya, $10
	movw	$10, ya
	ret
}