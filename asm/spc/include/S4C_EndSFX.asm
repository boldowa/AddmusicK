EndSFX:
{
	; Original code here would have cleared out $04, etc.
	; We can't do that, though, since it's impossible to know what input port was responsible for this sound effect.
	; Not that it's much of an issue...just useful for sanity checks and such, really.
	
	mov	a, #$00			; \ Zero out the high byte of this SFX
	mov	!ChSFXPtrs+1+x, a	; / This will ensure that it's no longer processed.
					; Old code simply set $04+inputport to 0 to do this.
					; Of course, that doesn't work so well when some channels don't map to input ports...
				
	mov !PitchFadeDelay+x, a
	mov !PitchFadeDuration+x, a
	mov	a, !CurrentChannelAlt		; \
	eor	a, #$ff						; | Clear the bit of $1d that this SFX corresponds to.
	mov	$10, a						; |
	and	a, !ChannelOccupancyFlags	; |
	mov	!ChannelOccupancyFlags, a	; /
	
	mov	a, $10			; \
	and	a, !SFXNoiseChannels	; | Turn noise off for this channel's SFX.
	mov	!SFXNoiseChannels, a	; /

	call	EffectModifier

	mov	x, !CurrentChannel			; \ 

RestoreInstrumentInformation:		; Call this with x = currentchannel*2 to restore all instrument properties for that channel.
	
	mov	a, !BackupSRCN+x	; |
	bne	.restoreSample		; |
	mov	a, !Sample+x		; | Fix instrument.
	beq	+					; |
	dec	a					; |
	jmp	SetInstrument		; | See Commands.asm
+							; /
	ret						;
							;
.restoreSample				; \ 
	jmp   RestoreMusicSample	; | Fix sample. See Commands.asm

}


;EffectModifier 	in 	S4A_EffectModifier.asm	
;SetInstrument		in	Commands.asm
;RestoreMusicSample in 	Commands.asm