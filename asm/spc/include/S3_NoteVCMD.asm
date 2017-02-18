; handle a note vcmd
NoteVCMD:			
{	
				; X should contain the current channel * 2.
				; A should contain the note (can be percussion or a normal pitch note).
	cmp	a, #$d0				 ;\*if bits 4, 6 and 7 are set
	bcs	PercNote             ;/*it's a percussion note
	cmp	a,#$C6			;;;;;;;;;;;;Code change
	beq	L_05CD			;\*skip if it's set to a value of #$C6
	bcs	if_rest			; |otherwise #$C7-#$CF are rest types
	bra	NormalNote		;/ and anything below #$C6 is some kind of note
if_rest:
	mov	a, #$01
	mov	!InRest+x, a				;flag to indicate the channel is in a rest
	
	mov	a, !ChannelProcessingFlags	;\*
	and	a, !ChannelOccupancyFlags	; |*if not 0, it means the current channel is occupied, so go ahead and cease proceeding
	bne	L_05CD						;/
	mov	a, !remoteCodeType+x		;\
	cmp	a, #$03						; |*if remoteCodeType is 3, then go ahead and cease proceeding, it will be handled elsewhere
	beq	L_05CD						;/
	mov	a, !ChannelProcessingFlags
	call	KeyOffVoices
	eor	a, #$FF						;\*Ensures the only bit being zeroed is the one for the current channel
	and	a, !LegatoActive			; |
	mov	!LegatoActive, a			;/*Ends legato activity on this channel since it is currently in a rest
L_05CD:
	ret
	
PercNote:
	
	mov	!Sample+x, a	;*a value of #$D0-#$FF is sent here
	setc				;*
	sbc	a, #$d0			;*turns it into #$00-#$2F
	mov	y, #$07			;sets an index of 6 to Y
	mov	$14, #PercussionTable		;sends a 16-bit address to where the Percussion Table is located for the current song
	mov	$15, #PercussionTable>>8	;
	call	ApplyInstrument             ; set sample A-$D0 in bank $5FA5 width 6
NormalNote:						;;;;;;;;;;/ Code change
	
	and	a, #$7f			; Right now the note is somewhere between #$80 and #$C6 or so.  Get rid of the MSB to bring it down to #$00 - #$46
	push	a			;*stores the note value into the tack to run addmusic code
						; MODIFIED CODE
	mov	a, #$00			;\*It's playing a note, therefore this channel is not in a rest
	mov	!InRest+x, a	;/
	
	mov	a, !ChannelProcessingFlags		; If $48 is 0, then this is SFX code.
	beq	NoPitchAdjust	; Don't adjust the pitch.
	
				; That says no pitch adjust, but we do more stuff here related to the "no sound effects allowed" club.

	mov	a, !remoteCodeType+x	;\*
	cmp	a, #$01					;|*branches if remoteCodeType is a value other than 1
	bne	.notType1RemoteCode		;/*
	
	mov	a, !remoteCodeTimeValue+x	;\*remoteCodeType mode 1
	mov	!remoteCodeTimeLeft+x, a	;/*
	
.notType1RemoteCode
	
	mov	a, !remoteCodeTargetAddr2+1+x 	;\ no remote code if the high bit of the address is "00", that'd be within RAM used for calculations!
	beq	.noRemoteCode					;/ 

	call	RunRemoteCode2
	
.noRemoteCode
	
	
	mov	a, !Portamento+x			; \*$02d1+x
	mov	!PitchFadeDestination+x, a	; / Portamento (tuning?) into $02b0+x	
	
	
	pop	a				; obtains the note value
	clrc				; \ Add the global transpose
	adc	a, !Transpose	; /*Since the percussion note samples are called earlier, this will only alter their pitch, which is what most people want anyway 
	clrc				; \
	adc	a, !HTuneValues+x		; / Add the h tune...
	;clrc				; \
	;adc	a, !ArpCurrentDelta+x	; / Add the arpeggio delta...
	
	bra +
NoPitchAdjust:
	mov	a, #$00						;\
	mov	!PitchFadeDestination+x, a 	; |*No pitch fade is needed, so there shouldn't be a value indicating where to pitch to
	pop	a							;/ *obtains the note value
+
	mov	!CurrentNote+x, a	; $02b1 gets the note to play.
	mov	a, #$00				; \ 
	mov	!TrueVibrato+x, a			; | 
	mov	!TrueTremolo+x, a			; | Zero out some addresses..?
	mov	!VibratoDelayTimer+x, a			; |
	mov	!VibratoFadeCounter+x, a		; | Clears the fade counter for vibrato
	mov	!VolumeUpdate+x, a	; /
	or	(!ChannelVolumeUpdate), (!ChannelProcessingFlags)       ; set volume changed flg
	or	(!ChannelKeyUpdate), (!ChannelProcessingFlags)       	; set key on shadow vbit
	
	mov	a, !PitchEnvelopeDuration+x			;\ 
	mov	!PitchFadeDuration+x, a				; |*Updates the pitch fade duration
	beq	L_062B								;/ *However, if there was no envelope fade period, no point in trying to calculate what it would be like
	mov	a, !PitchEnvelopeDelay+x	; Beyond here it gets a bit crazy.  No clue what's happening.
	mov	!PitchFadeDelay+x, a		; A bit farther below it looks like it calculates the pitch for the current note.
	mov	a, !PitchEnvelopeType+x		;\ *if the envelope type affects attack
	bne	L_0621						;/ *then do the following
	mov	a, !CurrentNote+x			;\ *
	setc							; |*
	sbc	a, !PitchEnvelopeSemitone+x	; |*
	mov	!CurrentNote+x, a			;/ *current note = current note - $0321+x
L_0621:								
	mov	a, !PitchEnvelopeSemitone+x		;\
	clrc								; |*release envelope doesn't need to affect attack
	adc	a, !CurrentNote+x				;/
	call	CalcPortamentoDelta
L_062B:
	mov	a, !CurrentNote+x	;
	mov	y, a				;
	call DDEEFix
	movw	$10, ya		;
; set DSP pitch from $10/11
SetPitch:			;
	push	x
	mov	a, $11
	asl	a
	mov	y, #$00
	mov	x, #$18
	div	ya, x
	mov	x, a
	mov	a, PitchTable+1+y
	mov	$15, a
	mov	a, PitchTable+0+y
	mov	$14, a             ; set $14/5 from pitch table
	mov	a, PitchTable+3+y
	push	a
	mov	a, PitchTable+2+y
	pop	y
	subw	ya, $14
	mov	y, $10
	mul	ya
	mov	a, y
	mov	y, #$00
	addw	ya, $14
	mov	$15, y
	asl	a
	rol	$15
	mov	$14, a
	bra	+
-	lsr	$15
	ror	a
	inc	x
+	cmp	x, #$06
	bne	-
	mov	$14, a
	pop	x
	mov	a, !PitchSubmultiplier+x
	mov	y, $15
	mul	ya
	movw	$16, ya
	mov	a, !PitchSubmultiplier+x
	mov	y, $14
	mul	ya
	push	y
	mov	a, !PitchMultiplier+x
	mov	y, $14
	mul	ya
	addw	ya, $16
	movw	$16, ya
	mov	a, !PitchMultiplier+x
	mov	y, $15
	mul	ya
	mov	y, a
	pop	a
	addw	ya, $16
	movw	$16, ya
	mov	a, x               ; set voice X pitch DSP reg from $16/7
	xcn	a                 ;  (if vbit clear in $1a)
	lsr	a
	or	a, #$02
	mov	y, a               ; Y = voice X pitch DSP reg
	mov	a, $16
	
	call	DSPWriteWithCheck
	inc	y
	mov	a, $17
				; write A to DSP reg Y if vbit clear in $1d
				;goes directly into S3A_DSPWRite (DSPWriteWithCheck)
}

incsrc "S3A_DSPWrite.asm"
incsrc "S3B_RunRemoteCode.asm"
incsrc "S3C_DDEEFix.asm"
