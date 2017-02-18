incsrc "S8A_SkipKeyOff.asm"

L_10A1:
{
	mov	a, !remoteCodeType+x
	cmp	a, #$01
	bne	.noRemoteCode2
	mov	a, !remoteCodeTimeLeft+x
	dec	a
	mov	!remoteCodeTimeLeft+x, a
	bne	.noRemoteCode2
	call	RunRemoteCode

.noRemoteCode2

	setp						;
	dec	$00+x					;
	clrp						;
	beq	.doKeyOffCheck 			;L_10AC					;
	
	mov	a, !remoteCodeType+x			; \ Branch away if we have no code to run before a note ends.
	cmp	a, #$02					; |
	bne 	.noRemoteCode				; /

	mov	a, !remoteCodeTimeValue+x		; \
	cmp	a, !remoteCodeCheck+x				; | Also branch if we're not ready to run said code yet.
	bne	.noRemoteCode				; /
	
	call	ShouldSkipKeyOff			; \ If we're going to skip the keyoff, then also don't run the code.
	bcc	.noRemoteCode				; /
	
	call	RunRemoteCode				;
	
.noRemoteCode
	mov	a, !WaitTime				;
	cbne	!NoteDuration+x, +				;
.doKeyOffCheck
	call	ShouldSkipKeyOff
	
	bcc	+
	mov	a, !ChannelProcessingFlags
	call	KeyOffVoicesWithCheck 
+
	
	clr1	$13.7					;
	mov	a, !PitchFadeDuration+x		;
	beq	L_10E4					;
	mov	a, !ChannelProcessingFlags					;
	and	a, !ChannelOccupancyFlags					;
	beq	L_1111					;
L_10E4:
	mov	a, (!ChannelByte+x)				; Code for handling the $DD command.
	cmp	a, #$dd							; I don't know why this is here instead of in its dispatch table.
	bne	L_112A							; Maybe so that it can properly do the "read-ahead" effect?
	mov	a, !ChannelProcessingFlags		; \ 
	and	a, !ChannelOccupancyFlags		; | Check to see if the current channel is disabled with a sound effect.
	beq	L_10FB							; /
	mov	$10, #$04
L_10F3:
	call	L_1260
	dbnz	$10, L_10F3
	bra	L_1111
L_10FB:
	call	L_1260					; \ 
	call	GetCommandDataFast			; |
	mov	!PitchFadeDelay+x, a				; | Get the $DD parameters.
	call	GetCommandDataFast			; |
	mov	!PitchFadeDuration+x, a				; |
	call	GetCommandDataFast			; /
	clrc
	adc	a, !Transpose
	call	CalcPortamentoDelta
L_1111:
	mov	a, !PitchFadeDelay+x		;\ *If there is no pitch fade
	beq	L_1119						; |*Skip pitch fade calculations
	dec	!PitchFadeDelay+x			; |*Otherwise decrement the pitch slide delay
	bra	L_112A						;/ *and no need to calculate pitch slide since it hasn't started
L_1119:
	mov	a, !ChannelOccupancyFlags			; \ Check to see if this channel is muted (by a sound effect or whatever)
	and	a, !ChannelProcessingFlags			; |
	bne	L_112A								; /* if it is, then don't alter a pitch bend
	set1	$13.7						;
	%L_1075PitchFadeSetup()
L_112A:
	mov	a, !CurrentNote+x
	mov	y, a
	call DDEEFix
	;mov	a, $02b0+x
	movw	$10, ya            ; note num -> $10/11
	mov	a, !Vibrato+x
	beq	L_1140
	mov	a, !VibratoDelay+x		;\
	cmp	a, !VibratoDelayTimer+x	; |*only update the delay timer if it hasn't meant the specified delay
	beq	L_1144					; |
	inc	!VibratoDelayTimer+x	;/
L_1140:
	bbs1	$13.7, L_1195
-
	ret
L_1144:					; This seems to handle things related to vibrato and pitch slides?

	mov	a, !PlayingVoices					; \ 
	and	a, !ChannelProcessingFlags			; | If there's no voice playing on this channel,
	beq	-									; / then don't do all these time-consuming calculations.
	
	mov	a, !VibratoFadeDuration+x			;\
	beq	L_1166								;/ *Don't bother processing the following if the vibrato isn't fading
	cmp	a, !VibratoFadeCounter+x			;\ *If the vibrato fade has met it's intended length
	bne	L_1155								; |*Go ahead and resurrect the vibrato from the preserved value
	mov	a, !VibratoPreserve+x				; |
	mov	!Vibrato+x, a						;/
	bra	L_1166
L_1155:
	mov	a, !VibratoFadeCounter+x				;\  *If the vibratofade has just started, Vibrato+x = VibratoFadeDelta+x
	beq	L_115C									; | *otherwise
	mov	a, !Vibrato+x							;/  *Vibrato+x += VibratoFadeDelta+x.
L_115C:
	clrc
	adc	a, !VibratoFadeDelta+x
	mov	!Vibrato+x, a
	setp
	inc	!VibratoFadeCounterShort+x				; for every step that delta is applied, we increment $0110+x
	clrp
L_1166:
	mov	a, !TrueVibrato+x
	clrc
	adc	a, !VibratoRate+x
	mov	!TrueVibrato+x, a

incsrc "S8B_VoiceHandler.asm"	
incsrc "S8C_VolumeHandler.asm"
incsrc "S8D_GetCommandData.asm"
	
;goes straight into S8B
}


