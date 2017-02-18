;;;;;;;;;;;;;;;

L_0CA8:
	push	a                 ; vcmd 80-d9 (note)
	
	mov a, !ChannelOccupancyFlags
	or  a, !ChannelMuted
	and a, !ChannelProcessingFlags
	mov $10, a	
					; Warning: The code ahead gets messy thanks to arpeggio modifications.
	pop y
	
	cmp	y, #$c6			; \ If the note is a rest or tie, then don't save the current note pitch.
	bcs	+				; /
.anythingGoes
	mov a, y
	mov	!PreviousNote+x, a	; Save the current note pitch.  The arpeggio command needs it.
+
	%ArpeggioFunction()
	mov	a, !NoteLength+x		
	mov	!NoteDuration+x, a           ; set duration counter from duration
	mov	y, a
	mov	a, !NoteCompensation+x
	mul	ya
	mov	a, y
	bne	L_0CC1
	inc	a
L_0CC1:
	mov	!remoteCodeCheck+x, a         ; set note dur counter from dur * dur%
	bra	L_0CC9
L_0CC6:
	call	L_10A1             ; do voice readahead
L_0CC9:	
	;call	HandleArpeggio	; Handle all things related to arpeggio.
	inc	x
	inc	x
	asl	!ChannelProcessingFlags
	bcs	L_0CD2				; jump to 0CD2 after processing all channels
	jmp	L_0C4D             ; loop

;proceeds into S7C_NoteCalculations.asm

;L_10A1 	in	S8_RemoteCommands.asm