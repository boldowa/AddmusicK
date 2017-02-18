;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
L_0CD2:		
	mov	a, !TempoFadeDuration             ; do global fades
	beq	L_0CE3
	dbnz	!TempoFadeDuration, L_0CDC
	movw	ya, !TempoFadeDuration
	bra	L_0CE1
L_0CDC:
	movw	ya, !TempoFadeDelta
	addw	ya, !TempoWide
L_0CE1:
	movw	!TempoWide, ya
L_0CE3:
	mov	a, !EchoFadeDuration
	beq	L_0D03
	dbnz	!EchoFadeDuration, L_0CF4		;*If there is an echo fade operating, go to L_0CF4
	mov	a, #$00
	mov	y, !EchoVolumeLeftLo
	movw	!EchoVolumeLeft, ya
	mov	y, !EchoVolumeRightLo
	bra	L_0CFE
L_0CF4:
	movw	ya, !EchoFadeVolumeLeftDelta
	addw	ya, !EchoVolumeLeft	
	movw	!EchoVolumeLeft, ya
	movw	ya, !EchoFadeVolumeRightDelta
	addw	ya, !EchoVolumeRight
L_0CFE:
	movw	!EchoVolumeRight, ya
	call	L_0EEB
L_0D03:
	mov	a, !MasterVolumeFadeDuration
	beq	L_0D17
	dbnz	!MasterVolumeFadeDuration, L_0D0E
	movw	ya, !MasterVolumeFadeDuration
	bra	L_0D12
L_0D0E:
	movw	ya, !MasterVolumeFadeDelta
	addw	ya, !MasterVolumeWide
L_0D12:
	movw	!MasterVolumeWide, ya
	mov	!ChannelVolumeUpdate, #$ff          ; set all vol chg flags
L_0D17:
	mov	x, #$0e
	mov	!ChannelProcessingFlags, #$80
L_0D1C:
	mov	a, !ChannelHiByte+x		;*bail if it thinks the value is in $0000-$00FF
	beq	L_0D23
	call	L_0FDB             ; per-voice fades?
L_0D23:
	lsr	!ChannelProcessingFlags
	dec	x
	dec	x
	bpl	L_0D1C
	mov	!ChannelVolumeUpdate, #$00          ; clear volchg flags
	mov	a, !ChannelOccupancyFlags
	eor	a, #$FF		;;;;;;;;;;;;;;;Code change
	and	a, !ChannelKeyUpdate
	mov	$12, a
	mov	a, !LegatoActive
	push	a
	or	a, $12
	mov	!LegatoActive, a
	pop	a
	and	a, !LegatoEnabled
	eor	a, #$FF
	and	a, $12		
; key on voices in A

;goes straight 	in	S7D_KeyOnVoices
;L_0FDB 		in	S7F_VolumeWrite.asm