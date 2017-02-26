MainLoop:
{
	print "MainLoopPos: $",pc
	mov   y, !RegTimer0
	beq   MainLoop             ; wait for counter 0 increment, used to regulate the process to only at a rate that would sync with the tempo
if !MusicSlowDownReduce = !true
	mov   !TaskCounter, y
else
	push  y
	push  y
endif

TaskLoop:
	mov   a, #$38					;\
if !MusicSlowDownReduce = !false
	mul   ya						; |
endif
	clrc							; | $44 = $44 + ((!RegTimer0 * 38) AND #$00FF))
	adc   a, !RegisterCheckCalculate; |
	mov   !RegisterCheckCalculate, a;/
	bcc   PWMSync					;	Only check 5A22 interaction registers if $44 + ((Tempo * 38) AND #$00FF) was not more than #$FF
									;	Updates every time a cycle checks APU0, APU1, APU2 and APU3
	
	call	ProcessSFX
	
	call  ProcessAPU1Input			; APU1 has to come first since it receives the "pause" sound effects that it pseudo-sends to APU0.
	call  ProcessAPU0Input
	call  ProcessAPU3Input
	mov   x, #$00
	call  ReadInputRegister             ; read/send APU0
	mov   x, #$01
	call  ReadInputRegister             ; read/send APU1
	mov   x, #$03
	call  ReadInputRegister             ; read/send APU3
	
	mov	a, !ProtectSFX6
	beq	+
	mov	!RegValue, #$00
+
	mov	a, !ProtectSFX7
	beq	+
	mov	!RegValue+3, #$00
+

;--------- PWM Function
PWMSync:
	setp
	mov   a, !PWMFreq
	;beq   pwmNop
if !MusicSlowDownReduce = !false
	pop   y
	mul   ya
endif
	clrc
	adc   a, !PWMSyncedTimer
	mov   !PWMSyncedTimer, a
	bcc   pwmNop
PWMCall:
	call  ProcessPWM
pwmNop:
	clrp

L_0573:
	mov   a, !Tempo
if !MusicSlowDownReduce = !false
	pop   y						
	mul   ya					; !RegTimer0 * !Tempo. It's not necessarily going to be 0 just because it's 0 when the main loop proceeds!
endif
	clrc
	adc   a, !TempoSyncedTimer
	mov   !TempoSyncedTimer, a
	bcc   L_058D				; if $49 + (!RegTimer0 * !Tempo) < #$0100, then don't check for updated music data, effectively is $49 += Tempo * (#$00-to-#$0F)
	mov   a, !PauseMusic		; Don't continue reading music info if paused. (Allows it to hold the current position in the song)
	bne   L_0586				
	call  ProcessAPU2Input		; Also handles playing the current music.
L_0586:
	mov   x, #$02
	call  ReadInputRegister             ; read/send APU2
if !MusicSlowDownReduce = !true
	dbnz  !TaskCounter, TaskLoop
endif
	bra MainLoop					; disabled byte sending to try to optimize code
L_058D:

if !MusicSlowDownReduce = !true
	dbnz  !TaskCounter, TaskLoop
endif

	mov   a, !CurrentSong      ; if writing 0 to APU2 then
	beq   MainLoop             ;   restart main loop
								; Execute code for each channel.
	mov   x, #$0e            				; foreach voice
	mov   !ChannelProcessingFlags, #$80		;*starting with channel 7 and decrementing to channel 0
L_0596:	
	mov   a, !ChannelHiByte+x		;* safety check, the song channel data is not going to be in $0000-$00FF!!!
	beq   L_059D             		; skip call if vptr == 0
	call  HandleVoice             ; do per-voice fades/dsps?
L_059D:
	lsr   !ChannelProcessingFlags			;*bitwise drop to lower channel
	dec   x
	dec   x
	bpl   L_0596             ; loop for each voice
	bra   MainLoop             ; restart main loop

}

 incsrc "S2A_ReadInput.asm"
