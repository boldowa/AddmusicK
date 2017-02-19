{;RAM Value names, can be contracted for easy reading in Notepad++ with the provided User-Defined Language with AddmusicK
!RegValue				= $00	; *4 bytes, used to indicate the most newly-received data from APU0-3, respectively. 0 indicates that there was a repeat/nothing needs to be done
!CurrentRegValue		= $04	;\*4 bytes, used to indicate the data currently being processed
!CurrentSong			= $06	;/*a part of the above, indicates the last value from $2142/$1DFB that was utilized, important for song playing
!LastRegValue			= $08	; *4 bytes, used to indicate the previously used value from APU0-3, respectively.

!SongCheckWait			= $0c	;*Used to tell it not to look for a new song for 3 cycles after finding an old one. Likely to prevent garbage data or reload spam?
;$0d unused
!Easy16bitZero			= $0e	;\*MUST ALWAYS BE ZERO. Used to movw a #$0000 for math since you can not move that directly in for some bizarre reason
!Easy16bitZeroLo		= $0f	;/

;$10-$13 are scratch RAM, no point in labelling them because their purposes vary wildly

;$14-$17 are used for addressing indirectly, in most cases, $14 is the 16-bit address being written to by either calculating $14 and $16 together or being transferred from $16 outright

!CurrentChannelAlt		= $18	;*Similar to $46, used in specific cases to prevent $46 from being overwritten yet still want to loop through channels
;$19-$1B utilized in SetPitch
!1DFASFXTimer			= $1c	;*used by the jump sfx and grinder sfx on 1DFA to determine how the sound plays
!ChannelOccupancyFlags	= $1d	;*One byte, one bit per channel. Bit active is currently a channel being used by something else and will not be used when referenced.
;$1E-$1F unused

!ChSFXPtrs 				= $20		;\	$20+x, Two bytes per channel, so $20 - $2f.
!ChSFXPtrsHiByte		= $21		;/
!ChannelByte 			= $30		;\*	$30+x, 16-bit pointer to the next byte a channel reads. Two bytes per channel
!ChannelHiByte 			= $31		;/*


!SongRead				= $40		;\*$40-$41 are used for addressing in conjunction with $14-$17 to read song data
!SongReadLo				= $41		;/
!SongReadCheck			= $42		;* Used to ensure that SongRead is always in the intended page?

!Transpose				= $43		;* One byte, used to indicate the transposition for the song. #$00 = unaltered
!RegisterCheckCalculate	= $44		;* One byte, updates in order to determine how frequently it should read the registers in a way that moderately syncs with the tempo
!TaskCounter			= $45		;* One byte, used to task loop counter.
!CurrentChannel			= $46		;* Byte indicating the current channel*2 (i.e. channel 7 = $0E)
!ChannelKeyUpdate		= $47		;* One byte, one bit per channel. Bit active is a channel that needs a key updated
!ChannelProcessingFlags = $48		;* One byte, one bit per channel. Bit active is current channel
!TempoSyncedTimer		= $49		; used for math for tremolo, vibrato

!MusicPModChannels 		= $4a		; \ The music channels that have pitch modulation enabled on them.
!MusicNoiseChannels 	= $4b		; | The same as the above, but for noise.
!MusicEchoChannels 		= $4c		; / The same as the above, but for echo.

!SFXPModChannels 		= $4d		; \ The SFX channels that have pitch modulation enabled on them.
!SFXNoiseChannels	 	= $4e		; | (etc.)
!SFXEchoChannels 		= $4f		; / (etc.)

!TempoWide				= $50		;*Used for 16-bit fade calculations
!Tempo					= $51	
!TempoFadeDuration		= $52
!TempoFadeDestination	= $53
!TempoFadeDelta			= $54		;\*16-bit
!TempoFadeDeltaB		= $55		;/

!MasterVolumeWide			= $56	;*Used in conjunction with Master Volume to do 16-bit fade calculations
!MasterVolume 				= $57
!MasterVolumeFadeDuration 	= $58
!MasterVolumeFadeDestination = $59
!MasterVolumeFadeDelta		= $5a		;\*16-bit
!MasterVolumeFadeDeltaB		= $5b		;/

!ChannelVolumeUpdate 		= $5c		; One byte, used to indicate an update to the volume or note is needed
!EchoDelay 					= $5d		; The value for the echo delay.
!ChannelMuted 				= $5e		; One byte, one bit per channel
!NCKValue 					= $5f		; The value for the noise clock.

!EchoFadeDuration			= $60
!EchoVolumeLeft				= $61		;\*16-bit
!EchoVolumeLeftLo			= $62		;/*
!EchoVolumeRight			= $63		;\*16-bit
!EchoVolumeRightLo			= $64		;/*

!EchoFadeVolumeLeftDelta	= $65		;\*$65 	L 16-bit
!EchoFadeVolumeLeftDeltaLo	= $66		;/
!EchoFadeVolumeRightDelta	= $67		;\*$67 	R 16-bit
!EchoFadeVolumeRightDeltaLo	= $68		;/
!EchoFadeVolumeLeft			= $69
!EchoFadeVolumeRight		= $6a

!WaitTime 				= $6b			
!CustomInstrumentPos 	= $6c		; Position of the custom instrument table.
!CustomInstrumentPosHi	= $6d
!YoshiDrumTracks		= $6e		; Used to determine which channels are disabled by not being on Yoshi, bit-wise
!SecondVTable 			= $6f		; Set to 1 if we're using the N-SPC velocity table.

!NoteDuration			= $70
;$71+x Unused?
!VolumeFadeDuration		= $80
!PanFadeDuration 		= $81
!PitchFadeDuration		= $90
!PitchFadeDuration7		= $9E
!PitchFadeDelay			= $91
!PitchFadeDelay7		= $9F	
!VibratoDelayTimer		= $a0		
!Vibrato				= $a1
!VolumeUpdate			= $b0		;similar to $5c, but each bit is instead a byte, $b0+x
!Tremolo				= $b1

!RepeatCounter			= $c0 ;cmdE9 (Loop)
!Sample					= $c1 
!Sample7				= $cF ;part of !Sample

;$d0? unused, NoteMacroTable
;$d1? unused, NoteMacroTableHi

;$e0? free?

;$e1? free?

!RegDSPTest				= $f0
!RegDSPControl			= $f1
!RegDSPComAdd			= $f2
!RegDSPComDat			= $f3
!RegCPU_IO				= $f4	; CPU I/O register 0, interacts with 5A22 register $2140, called by $1DF9 in SMW
!RegCPU_IO_1			= $f5	; $2141, $1DFA
!RegCPU_IO_2			= $f6	; $2142, $1DFB (music)
!RegCPU_IO_3			= $f7	; $2143, $1DFC (most sfx)
!RegF8 = $f8 ;(effectively free RAM, these have no utility besides being two additional ram addresses that are treated as registers. Unused)
!RegF9 = $f9
!RegTimer0Target		= $fa
!RegTimer1Target		= $fb
!RegTimer2Target		= $fc
!RegTimer0				= $fd
!RegTimer1				= $fe
!RegTimer2				= $ff

!remoteCodeCheck		= $0100 ; 8 bytes
;$0101 related to remoteCodeCheck somehow???
!VibratoFadeCounter		= $0110 ;*used to see how far along the fade the vibrato fade is
!VibratoFadeCounterShort = $10	;*uses page set to determine it is $0110
!HTuneValues 			= $0120	; 

;$0121-$0151 backup sample pointers
!SNESSync				= $0160	;*bit 2 is used to determine SNES sync, bit 1 was not actually referenced in AddmusicK even though it was set by the Yoshi Drum command in F4 since 6E suits fine
!LegatoEnabled			= $0161 ;bitwise indicator of channels with legato on
!LegatoActive			= $0162 ;bitwise indicator if the channel is currently using a legato, cleared when in rests
;$0163-$0165???
!SendByte1				= $0166 ;\*16-bit
!SendByte1B				= $0167 ;/
!SendByte1_Short		= $66   ; some processes use a set page to determine that this is on $01xx
!SendByte2				= $0168 ;\*16-bit, note that these are effectively unused by normal song commands since the only sync commands just set $0166-$0167!
!SendByte2B				= $0169 ;/
!SendByte2_Short		= $68
;$016A-$016F???

;$0170-$0181???
!remoteCodeTargetAddr2 	= $0190	; The address to jump to for "start of note" code.  16-bit.
!remoteCodeTargetAddr2Hi = $0191
!remoteCodeTimeValue 	= $01a0	; The value to set the timer to when necessary.
!InRest 				= $01a1 ;* Although this is only binary, you can not consolidate this into a single byte since it is cleared by SFX when not associated with a music channel lane!
;$01b0-$01c1???
!ChSFXNoteTimer 		= $d0		; Actually $01d0.  Use setp/clrp to tell it such.
;!ChSFXNoteTimer			= $01d0

;!ChSFXTimeToStart = $d1		; Time until the SFX on this channel starts. (Same as above, use setp and clrp).

;!ChSFXTimeToStartTrue = $01d1 Unused????


!SubloopPreserveByte	= $01e0		;\ * unlike most of these values, these are only present in the Commands.asm file and never referenced here
!SubloopPreserveHiByte	= $01e1		; |*
!SubloopCounter			= $01f0		;/ *
!SubloopCounter_Short	= $f0
;$01f1+x-to-$201+x unused?????
!NoteLength				= $0200
!NoteCompensation		= $0201		; * done to prevent shorter notes from having too sharp of a sound
!PitchMultiplier		= $0210		; * related to instrument applying
!PitchMultiplier7		= $021e
!NoteVolume				= $0211 	; *
!BackupSRCN 			= $0220		; 
;$0221+x unused???
;!ArpNoteIndex 			= $0230		; What note number we're on.
;!ArpType 				= $0231		; The arpeggio type.  0 = arpeggio, 1 = trill, 2 = glissando.
!VolumeDelta			= $0240		;\*
!Volume 				= $0241		;/*
!VolumeToDelta			= $0250		;\*
!VolumeTo				= $0251		;/* Used during the process of a volume fade
!VolumeFadeDestination	= $0260
;!ArpNoteCount 			= $0261		; How many notes there are.
;!ArpCurrentDelta 		= $0270		; The current pitch change for the current channel, in semitones.
!PreviousNote 			= $0271		; The most recently played note for this channel.
!PanDelta				= $0280		;\*
!Pan 					= $0281		;/
!PanToDelta				= $0290		;\*
!PanTo					= $0291		;/* Used during the process of a pan fade
!PanFadeDestination		= $02a0		; the final value to fade to
!SurroundSound			= $02a1		; WARNING: POSSIBLE CONFLICT
!PitchFadeDestination	= $02b0		;\*contains the pitch to fade to followed by the current note, comprising two bytes per channel
!CurrentNote			= $02b1		;/
!PortamentoDelta		= $02c0		;\*
!PortamentoTo			= $02c1		;/*
!PortamentoFadeDestination = $02d0	;\*
!Portamento				= $02d1		;/*used to indicate gliding between notes, cmdEE


;!ArpSpecial 			= $02e0		; The index of the loop point for this arpeggio, or the pitch difference for trill and glissando.
!VolumeMult 			= $02e1
!PitchSubmultiplier		= $02f0		; * related to instrument applying

;$02f1+x unused???
!PitchEnvelopeDuration 	= $0300		;*
!PitchEnvelopeDelay 	= $0301		;*
;!ArpLength 				= $0310		; The length between each change in pitch, measured in ticks, for the arpeggio command.
;!ArpLength7				= $031e
;!ArpTimeLeft 			= $0311		; How much time until we get the next note.
;!ArpTimeLeft7			= $031f
!PitchEnvelopeType 		= $0320		;*
!PitchEnvelopeSemitone	= $0321		;*
!TrueVibrato			= $0330			;* Vibrato as it affects the DSP
!VibratoRate			= $0331 		;* Rate of the vibrato speed
!VibratoDelay			= $0340			;* Length of time for the vibrato to start activating upon a note
!VibratoFadeDuration	= $0341			;* Length of time for vibrato to fade to the value specified in $0331+x
!VibratoFadeDelta		= $0350			;* Used to calculate how quickly to change the vibrato
!VibratoPreserve		= $0351			;* Contains the vibrato from before the fade in order to determine how to fade
!TrueTremolo			= $0360		; * the tremolo as perceived by the DSP
!TremoloDuration		= $0361		; *
!TremoloDelay			= $0370		; *
!TrueVolume				= $0371		; * The volume as seen by the DSP

!runningRemoteCode 		= $0380		; Set if we're running remote code.  Used so that, when we hit a 0, we return to RunRemoteCode, instead of ending the song track/loop.
;$0381
!PlayingVoices 			= $0382		; Each bit is set to 1 if there's currently a voice playing on that channel (either by music or SFX).
!SFXDelay				= $0383		; Delay before a sfx called from $1DFA plays, to make it so that a new sound only happens every 5 frames
!SpeedUpBackUp 			= $0384		; Used to restore the speed after pausing the music.
;$0385
!YoshiDrumsEnable		= $0386		; Toggles whether to operate on the Yoshi drum channel(s)	
!LoTimeTempoSpeedGain 	= $0387
!PauseMusic 			= $0388		; Pauses the music if not zero.  Used in the pause SFX.
;$0389 cleared on uploading routine, but never used?
!ProtectSFX6 			= $038a		; If set, sound effects cannot start on channel #6 (but they can keep playing if they've already started)
!ProtectSFX7 			= $038b		; If set, sound effects cannot start on channel #7 (but they can keep playing if they've already started)
;$038c Unused?
!MaxEchoDelay 			= $038d		; The highest echo delay reached for the current song (cleared on SPC upload).
;$038e-038f unused?

!remoteCodeTargetAddr 	= $0390		; The address to jump to for remote code.  16-bit and this IS a table.
!remoteCodeTargetAddrHi = $0391		;$0391, high byte of above
!remoteCodeType 		= $03a0		; The remote code type.
!remoteCodeTimeLeft 	= $03a1		; The amount of time left until we run remote code if the type is 1 or 2.
;!ArpNotePtrs 			= $03b0		; The pointer for the sequence of pitch changes for the current arpeggio.
;!ArpNotePtrsHi			= $03b1		;$03b1, high byte of above
!ChSFXPtrBackup 		= $03c0		; A copy of $20w, only updated when a sound effect starts.  Used by the #$FE command to restart a sound effect.
;$03d0+x unused?
!ChSFXNoteTimerBackup 	= $03d1		; Used to save space when two consecutive notes use the same length.
!LoopToPointLo			= $03e0
!LoopToPointHi			= $03e1
!LoopFromPointLo		= $03f0
!LoopFromPointHi		= $03f1
