; do: standardish SPU transfer
L_12F2:
{
	print "ReuploadPos: $",pc		
				; This is where the engine should jump to when downloading consecutive blocks of data.
	
				; The following is a near identical copy of the SPC IPL ROM, just modified a touch to emulate
				; SMW sending data to ($14)+y instead of ($00)+y.  See "http:;www.romhacking.net/documents/197/".
			
			

		
	
	mov	!RegCPU_IO, #$AA		; Signal "ready" to 5A22: $2140-1 will return #$BBAA
	mov	!RegCPU_IO_1, #$BB
Wait:
	cmp	!RegCPU_IO, #$CC		; wait for 5A22 to write #$CC to $2140
	bne	Wait
	bra	Start
Trans:
	mov	y, !RegCPU_IO		; *** TRANSFER ROUTINE ***
	bne	Trans		; First, wait for 5A22 to indicate Byte 0 ready on $2140
StartLoop:
	cmp	y, !RegCPU_IO		; start loop: wait for "next byte/end" signal on $2140
	bne	Unexpected
	mov	a, !RegCPU_IO_1		; Got "next byte" ($2140 matches expected byte index)
	mov	!RegCPU_IO, y		; Read byte-to-write from $2141, echo $2140 to signal
	mov	($14)+y, a		; ready, and write the byte and update the counter.
	inc	y
	bne	StartLoop
	inc	$15			; (handle $xxFF->$xx00 overflow case on increment)
Unexpected:
	bpl	StartLoop
	cmp	y, !RegCPU_IO		; If "next byte/end" is not equal to expected next byte
	bpl	StartLoop		; index, it's "end": drop back into the main loop.
Start:
	movw	ya, !RegCPU_IO_2		; *** MAIN LOOP ***
	movw	$14, ya		; Get address from 5A22's $2142-3, 
	movw	ya, !RegCPU_IO		; mode from $2141, and echo $2140 back
	mov	!RegCPU_IO, a
	mov	a, y
	mov	x, a
	bne	Trans		; Mode non-0: begin transfer	
	
				; reset ports, keep timer running
	mov	!RegDSPControl, #$31		; Has to be done quickly or else subsequent writes
				; to the SPC will be ignored (playing music right
				; after loading it, for example).  Important to note:
				; even despite doing this as quickly as possible, the
				; 5A22 will still have to wait a bit (6 NOPs or so)
				; before sending any data.
	
	mov	a, #$00
	mov	y, a
	movw	!RegCPU_IO, ya
	movw	!RegCPU_IO_2, ya
	movw	!CurrentRegValue, ya
	movw	!CurrentSong, ya
	setp		; Clear the output ports
	movw	!SendByte1_Short, ya	;\*blanks data at $0166-$0169
	movw	!SendByte2_Short, ya	;/
	clrp		;
	
	mov	!PauseMusic, a
	mov	$0389, a
	
	mov	!MaxEchoDelay, a
	
	mov	x, #$cf		; Reset the stack pointer.
	mov	sp, x
	
	mov	x, #$00
	mov	!RegValue+1, x
	
	mov	!NCKValue, #$20
	mov	a, #$00
	call	ModifyNoise
	
	mov	y, #$10
	mov	a, #$00
-
	mov	!ChSFXPtrs-1+y, a	; \ Turn off sound effects
	dbnz	y, -			; /
	
	jmp	($0014+x)		; Jump to address
	
GetSampleTableLocation:

	print "SRCNTableCodePos: $",pc		
				; This is where the engine should jump to after uploading samples.

-	cmp	!RegCPU_IO, #$CC	; Wait for the 5A22 to send #$CC to $2140.
	bne -			; By then it should have also written DIR to $2141
				; as well as the jump address to $2142-$2143.
				
	mov	y, #$5d	
	mov	!RegDSPComAdd, y
	mov	a, !RegCPU_IO_1
	call	DSPWrite		; Set DIR to the 5A22's $2141
	push	a
	
	movw	ya, !RegCPU_IO_2
	movw	$14, ya
	mov	!RegDSPControl, #$31		; Reset input ports
	pop	a
	mov	!RegCPU_IO_1, a		; Echo back DIR
	mov	y, #$00
	jmp	($0014+x)		; Jump to the upload location.
}	


incsrc "../InstrumentData.asm"

	
	
