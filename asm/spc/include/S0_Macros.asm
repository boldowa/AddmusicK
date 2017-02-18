{;------Macro catalog------

function hi8(n) = n>>8&255
function lo8(n) = n&255

{;***these three were moved up here to make it easier to modify fade RAM allocation for more extreme edits, as they query them differently than names can be tagged to.

macro L_1075VolumeFadeSetup()
	mov	a, #lo8(!VolumeDelta)				;* set up $0240 to be read from (VolumeDelta, Volume, VolumeToDelta, VolumeTo, VolumeFadeDestination)
	mov	y, #hi8(!VolumeDelta)
	dec	!VolumeFadeDuration+x				;*decrements the fade time left
	call	L_1075							;calls routine to alter addreses $0240/1+x, $0250/1+x and $0260+x related to volume fading
endmacro

macro L_1075PanFadeSetup()
	mov	a, #lo8(!PanDelta)		;* set up $0280 to be read from 
	mov	y, #hi8(!PanDelta)
	dec	!PanFadeDuration+x		;* the pan fade will last one cycle less now since one cycle has passed
	call	L_1075				;* calls routine to alter addreses $0280/1+x, $0290/1+x and $02A0+x, related to pan fading
endmacro

macro L_1075PitchFadeSetup()
	mov	a, #lo8(!PitchFadeDestination)	;
	mov	y, #hi8(!PitchFadeDestination)	;* assigns duration for the pitch fade address ($02b0) for $02B0, $02C0, $02D0
	dec	!PitchFadeDuration+x			;
	call	L_1075						;* calls routine to alter addreses $02b0/1+x, $02c0/1+x and $02d0+x
endmacro

}


{;***these are related to PlaySong's initialization to make it easier to read it

macro PlaySongClearOut()
	mov	a, #$00
	mov	!Portamento+x, a         ; Portamento[ch] = 0
	mov	!PanFadeDuration+x, a           ; PanFade[ch] = 0
	mov	!VolumeFadeDuration+x, a           ; VolVade[ch] = 0
	mov	!Vibrato+x, a		; Vibrato[ch] = 0
	mov	!Tremolo+x, a		; ?
	mov	!RepeatCounter+x, a     ; repeat ctr
	mov	!Sample+x, a           ; Instrument[ch] = 0
	mov	!LegatoEnabled+x, a	; Strong portamento
	mov	!HTuneValues+x, a	
	
	;mov	!ArpLength+x, a		; \
	;mov	!ArpNotePtrs+x, a	; |
	;mov	!ArpNotePtrs+1+x, a	; |
	;mov	!ArpTimeLeft+x, a	; | All things arpeggio-related.
	;mov	!ArpNoteIndex+x, a	; |
	;mov	!ArpNoteCount+x, a	; |
	;mov	!ArpCurrentDelta+x, a	; |
	;mov	!ArpSpecial+x, a	; /
	mov	!VolumeMult+x, a	
	call	ClearRemoteCodeAddresses
	mov	!PitchSubmultiplier+x, a	
	mov	!PitchMultiplier+x, a
endmacro

macro	PlaySongClearOutB()
	mov	!MusicPModChannels, a
	mov	!MusicEchoChannels, a
	mov	!MusicNoiseChannels, a
	mov	!SecondVTable, a
	; MODIFIED CODE END	
	mov	!MasterVolumeFadeDuration, a    ; MasterVolumeFade = 0
	mov	!EchoFadeDuration, a            ; EchoVolumeFade = 0
	mov	!TempoFadeDuration, a           ; TempoFade = 0
	mov	!Transpose, a       			; GlobalTranspose = 0
	mov	!PauseMusic, a					; Unpause the music, if it's been paused.
	mov	!ProtectSFX6, a					; Protection against START + SELECT
	mov	!ProtectSFX7, a					; Protection against START + SELECT
	mov	!YoshiDrumTracks,a				; MODIFIED, channels affected by Yoshi drums.
	mov	!ChannelMuted,a					; Also MODIFIED
	mov	!MasterVolume, #$c0          	; MasterVolume = #$C0
	mov	!Tempo, #$36          			; Tempo = #$36
endmacro

{
macro ArpeggioFunction()

	mov	a, $10
	bne	L_0CB3 ;previous arp code present in other copy

	mov	a, y
	call	NoteVCMD             ; handle note cmd if vbit 1D clear
L_0CB3:
}
endmacro

}