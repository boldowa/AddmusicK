GetNextSFXByte:
{
	mov	x, !CurrentChannel	; Ensure x contains the channel number * 2.
	mov	a, (!ChSFXPtrs+x)	; Get the byte.
	push	p			; Remember the flags (negative and zero).
	inc	!ChSFXPtrs+x		; \ 
	bne	+			; | Increase the correct SFX pointer.
	inc	!ChSFXPtrs+1+x		; /
+					;
	pop	p			; Get the flags back.  inc modifies them.
	ret				;
}