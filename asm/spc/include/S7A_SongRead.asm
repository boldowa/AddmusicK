; read next word at $40 into YA ************************
L_0BF0:
{
	mov	y, #$00
	mov	a, (!SongRead)+y
	incw	!SongRead
	push	a
	mov	a, (!SongRead)+y
	incw	!SongRead
	mov	y, a
	pop	a
	ret
}
; ********************************

L_0BFE:
	dbnz	!SongCheckWait, L_0BEF ;decrements wait timer for song checking
L_0C01:
	call	L_0BF0             ; read next word at $40
	movw	$16, ya            ; save in $16/17
	mov	a, y               ; high byte zero?
	bne	L_0C22
	mov	a, $16             ; refetch lo byte
	beq	L_0BA3             ; key off, return if also zero
	dec	!SongReadCheck
	beq	L_0C1C				; do not run L_0C15 unless $42 != 0
	bpl	L_0C15
	mov	!SongReadCheck, a	; if $42 dips into #$FF, it becomes the refetched lo byte
L_0C15:
	call	L_0BF0             ; read next word at $40
	movw	!SongRead, ya      ; "goto" that address
	bra	L_0C01             ; and continue
L_0C1C:
	incw	!SongRead		;* skip goto address, L_0BF0 normally does incw !SongRead twice, so this is simply doing so
	incw	!SongRead      	;* As to why this would be beneficial at all, this accomplishes effectively the same thing as
	bra	L_0C01             ; calling L_0BF0 and NOT moving it 16-bit into !SongRead before continuing the cycle

;*******	

L_0C22:
	mov	y, #$0f            ; high byte not zero:
	
L_0C24:				; This short loop sets $30 to contain the pointers to each track's starting "measure."
	mov	a, ($16)+y
	mov	!ChannelByte+y, a
	dec	y
	bpl	L_0C24             ; set vptrs from [$16]
	mov	x, #$0e
	mov	!ChannelProcessingFlags, #$80          ; foreach voice
L_0C31:
	mov	a, !ChannelHiByte+x
	beq	L_0C40             ;  next if vptr hi = 0
	mov	a, #$01
	mov	!NoteDuration+x, a           ;  set duration counter to 1
	mov	a, !Sample+x
	bne	L_0C40
	call	SetInstrument             ;  set instr to 0 if no instr set
L_0C40:
	lsr	!ChannelProcessingFlags
	dec	x
	dec	x
	bpl	L_0C31             ; loop
	
;goes straight into S7_ProcessVCMD.asm at L_0C46