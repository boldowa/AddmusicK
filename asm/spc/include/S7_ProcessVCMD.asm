incsrc "S7A_SongRead.asm"

L_0C46:
	mov	x, #$00
	mov	!ChannelKeyUpdate, x
	mov	!ChannelProcessingFlags, #$01          ; foreach voice
L_0C4D:
	mov	!CurrentChannel, x
	mov	a, !ChannelHiByte+x
	bne	+			; (fix an out-of-range error)
	jmp	L_0CC9             ; next if vptr hi zero
+
	dec	!NoteDuration+x             ; dec duration counter
	beq	L_0C57		; (fix another out-of-range error)
	jmp	L_0CC6             ; if not zero, skip to voice readahead
L_0C57:
	call	GetCommandDataFast             ; get next vbyte
	bne	L_0C7A
	mov	a, !runningRemoteCode
	beq	+
	ret
+
	mov	a, !RepeatCounter+x ; vcmd 00: end repeat/return
	beq	L_0C01             ;  goto next $40 section if rpt count 0, located in S6C_SongRead.asm
	dec	!RepeatCounter+x   ;  dec repeat count
	bne	L_0C6E             ;  if zero then
	mov	a, !LoopToPointLo+x
	mov	!ChannelByte+x, a
	mov	a, !LoopToPointHi+x
	bra	L_0C76             ;   goto 03E0/1
L_0C6E:
	mov	a, !LoopFromPointLo+x         ;  else
	mov	!ChannelByte+x, a
	mov	a, !LoopFromPointHi+x         ;   goto 03F0/1
L_0C76:
	mov	!ChannelHiByte+x, a
	bra	L_0C57             ;  continue to next vbyte
L_0C7A:
	bmi	L_0C9F             ; vcmds 01-7f
	
	mov	!NoteLength+x, a         ;  set cmd as duration
	call	GetCommandDataFast             ;  get next vcmd
	bmi	L_0C9F             ;  if not note then
	push	a
	xcn	a					;\*shifts bits 5-8 into 1-4 and discards of the previous bits 1-4 and 8
	and	a, #$07				;/64th-16th ($00-$08 -> $00), Eighth Note/Triplet ($18/$10 -> $01), Quarter Triplet ($20 -> $02)
	mov	y, a				;/Quarter ($30 -> $03), Half Triplet/Whole ($40/$C0 -> $04), Half ($60 -> $06), Whole Triplet ($80 -> $00???)
	mov	a, NoteDurations+y
	mov	!NoteCompensation+x, a         ; set dur% from high nybble
	pop	a
	and	a, #$0f			
	cmp	!SecondVTable, #$00	; \ 
	beq	+			; | Get the correct velocity table index
	or	a, #$10			; |
+					; |
	mov	y, a			; /
	mov	a, VelocityValues+y
	mov	!NoteVolume+x, a         ; set per-note vol from low nybble
	or	(!ChannelVolumeUpdate), (!ChannelProcessingFlags)       ; mark vol changed?
	call	GetCommandDataFast             ; get next vbyte
L_0C9F:
	cmp	a, #$da
	bcc	L_0CA8             ; vcmd da-ff:
	
	call	L_0D40             ; dispatch vcmd
	bra	L_0C57             ; do next vcmd
	
incsrc "S7B_ProcessNote.asm"
incsrc "S7C_NoteCalculations.asm" ;goes straight into S7D
incsrc "S7D_KeyOnVoices.asm"
incsrc "S7E_DispatchCommands.asm" ;contains the call to Commands.asm
incsrc "S7F_VolumeWrite.asm"
incsrc "S7G_DeltaCalc.asm"
incsrc "S7H_NoteTables.asm"
