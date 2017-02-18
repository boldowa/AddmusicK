PlayPSwitchSFX:
	mov	!ChSFXPtrs+$0a, #PSwitchCh5
	mov	!ChSFXPtrs+$0b, #PSwitchCh5>>8
	mov	!ChSFXPtrs+$0c, #PSwitchCh6
	mov	!ChSFXPtrs+$0d, #PSwitchCh6>>8
	mov	!ChSFXPtrs+$0e, #PSwitchCh7
	mov	!ChSFXPtrs+$0f, #PSwitchCh7>>8

	mov	y, #$06				; \
-						; |
	mov	a, !ChSFXPtrs+$0009+y		; | Copy the SFX pointers to the backup pointers.
	mov	!ChSFXPtrBackup+$09+y, a	; |
	dbnz	y, -				; /
	
	mov	a, #$03
	setp
	mov	!ChSFXNoteTimer+$0e, a		; \
	mov	!ChSFXNoteTimer+$0c, a		; | Set the timers to 3, not 1.
	mov	!ChSFXNoteTimer+$0a, a		; /*uses the "short" version due to page set to $01xx
	clrp
	mov	a, #$e0
	call	KeyOffVoices
	
	or	$1d, #$e0			; Mute these channels.
	ret
