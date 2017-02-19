incsrc "S6A_PlaySong.asm"
incsrc "S6B_MusicFadeOut.asm" ;contains FadeOut

ProcessAPU2Input:

	; MODIFIED CODE START
	
	mov	a,!SNESSync	; Get the special AMM byte.
	and	a,#$02		; If the second bit is set, then we've enabled sync.
	beq	.nothing	; Otherwise, do nothing.
	setp						; \ 
	incw !SendByte1_Short		; | Increase $166-$167.
	clrp						; / 
				; Note that this is different from AMM's code.
				; The old code never let the low byte go above #$C0.
				; A good idea in theory, but it both assumes that all
				; songs use 4/4 time, and it makes, for example,
				; using the song's time as an index to a table more difficult.
				; If the SNES needs 0 <= value < #$C0, it can limit the value itself.
.nothing			; 

	mov	a, !RegValue+2
	bmi	FadeOut		
	beq	L_0BE7
	call	PlaySong            ; play song in A, see S6_PlaySong.asm
	mov	a, !RegTimer0			; read counter for clear
	ret
L_0BE7:
	mov	a, !SongCheckWait	;* if $0c is #$01, go to L_0C01, if it's #$02 or higher, return, if it's #$00, check if !CurrentSong is valid and if it is, go to L_0C46
	bne	L_0BFE				; see S6A_SongRead.asm, close enough to not need a jump unless this is edited
	mov	a, !CurrentSong
	bne	L_0C46
L_0BEF:
	ret
	
}


;PlaySong	in	S6_PlaySong.asm
;L_0BF0		in  S7A_SongRead.asm
;L_0BFE		in	S7A_SongRead.asm, goes straight into S7_ProcessVCMD.asm after
;L_0C46		in	S7_ProcessVCMD.asm
