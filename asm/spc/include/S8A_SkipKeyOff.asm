;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	
ShouldSkipKeyOff:		; Returns with carry set if the key off should be skipped.  Otherwise, the key off should be performed.	
{
;L_10AC:							;
	mov	a, !ChannelByte+x			; \ 
	mov	y, !ChannelHiByte+x			; |
	movw	$14, ya					; |
	mov	y, #$00					; |
L_10B4:							; |
	mov	a, ($14)+y				; | Loop until the next byte is a note/command.
	beq	L_10D1					; |
	bmi	L_10BF					; |
L_10BA:							; |
	inc	y					; |
	mov	a, ($14)+y				; |
	bpl	L_10BA					; /
L_10BF:
	cmp	a, #$c6					; \ C6 is a tie.
	beq	skip_keyoff				; / So we shouldn't key off the voice.
	cmp	a, #$da					; \ Anything less than $DA is a note (or percussion, which counts as a note)
	bcc	L_10D1					; / So we have to key off in preparation
	push	y					;
	cmp	a, #$fb					; \ FB is a variable-length command.
	bne	.normalCommand				; / So it has special handling.
	pop	y					; y = the current "offset".
	inc	y					; \ 
	mov	a, ($14)+y				; / Get the next byte
	bpl	.normal					; \ 
	mov	a, y
	clrc
	adc	a, #$03
	bra	+
.normal
	mov	$10, a					; Store it for a moment...
	mov	a, y					; Now a has the offset.
	clrc						; \
	adc	a, $10					; / Add the number of bytes in the command.
	inc	a					; \
	inc	a					; / Plus the number of bytes the command itself takes up .
	bra	+					;
	
.normalCommand
	mov	y, a					; \ 
	pop	a					; |
	clrc						; |
	adc	a, CommandLengthTable-$DA+y		; | Add the length of the current command to y (so we get the next note/command/whatever).
+							; |
	mov	y, a					; |
	bra	L_10B4					; /

;;;;;;;;;;
	
L_10D1:							;
	mov	$10, a
	mov	a, !ChannelProcessingFlags	; \ 
	;mov	y, #$5c					; |
	and	a,!LegatoEnabled			; | Key off the current voice (with conditions).
	and	a,!LegatoActive				; |
	bne	skip_keyoff				; |

	mov	a, !InRest+x
	bne	+
	mov	a, !remoteCodeType+x
	cmp	a, #$03
	bne	keyoff
	mov	a, $10
	cmp	a, #$c7
	beq	skipKeyOffAndRunCode
	mov	a, !NoteDuration+x
	cmp	a, !WaitTime
	beq	keyoff
skipKeyOffAndRunCode:
	call	RunRemoteCode
	bra	skip_keyoff
+
keyoff:
	setc
	ret
skip_keyoff:
	clrc
	ret
}