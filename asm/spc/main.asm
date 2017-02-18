
; Super Mario World's modified SPC Program - Kipernal
; Heavily based on loveemu labo's assembly, which in turn was heavily based on C.Bongo's assembly.
; Bugs have been fixed and all addresses above $04FF have been turned into labels to make things portable.
;
; Easy way to tell whose comments are whose: My comments are indented with tabs, while loveemu labo's
; comments are indented with spaces. Additional comments by Codec contain an asterisk.
;
; Notable code changes have been marked.  Or rather, they were.  Eventually the changes just got so
; massive that this stopped becoming feasible (though some marks still exist).
;
; Note: The L_XXXX labels are generic and almost none of them accurately reflect their placement in ARAM
; anymore.  Do not use them to locate a code's position.
;
; Major, major thanks to loveemu labo.  I could never have done this without this disassembly or without
; their documentation on the N-SPC engine.
!false = 0
!true = 1

!PSwitchIsSFX = !false		; If you set this to true, then the P-switch song will be a sound effect
				; instead of a song that interrupts the current music.
				; Note, however, that it is hardcoded and cannot be changed unless you
				; do it yourself.

;Potential Optimization:
;
;!PitchEnvelopeType = $0320+x can be turned from 8 bytes into a single one, bitwise. It's just a binary toggle and not read unless there is a fade active
;!SNESSync = $0160 can be used for more things than just bit 2 if set up well, it set bit 1 for Yoshi bongos previously, but it didn't actually affect anything
;

incsrc "include/S0_Labels.asm"			; All ARAM labels lower than 0x400

incsrc "include/S0_Macros.asm"			; All macros, these are not inserted here but instead where asked below. Commands that begin with % are present in this file.

;;;;;;;;;;;;;;;;;;

arch spc700-raw
org $000000
base $0400			; Do not change this.

;Initialization Code
incsrc "include/S1_ProgramSetup.asm"	;S1_ProgramSetup.asm
;Main Loop For Program
incsrc "include/S2_MainLoop.asm"		;S2_MainLoop.asm			MainLoop
									;S2A_ReadInput.asm
	
incsrc "include/S3_NoteVCMD.asm"		;S3_NoteVCMD.asm			NoteVCMD
									;S3A_DSPWrite.asm			DSPWriteWithCheck, 	DSPWrite,	ModifyNoise
									;S3B_RunRemoteCode.asm		RunRemoteCode, 		RunRemoteCode2
									;S3C_DDEEFix.asm			DDEEFix

incsrc "include/S4_ProcessSFX.asm"		;S4_ProcessSFX.asm			ProcessSFX 	
										;***(calls 1DFACommands.asm)***
									;S4A_EffectModifier.asm		EffectModifier									(also used by music)
									;S4B_GetNextSFXByte.asm		GetNextSFXByte
									;S4C_EndSFX.asm				EndSFX, 			RestoreInstrumentInformation

									;p-switch/PMusic.asm
									;p-switch/PlayMusicAsSFX.asm
incsrc "include/S5_ProcessSFXInput.asm"	;S5_ProcessAPUInput.asm		ProcessAPU0Input, ProcessAPU3Input, ProcessAPU1Input
									;S5A_SpeedUpMusic.asm		SpeedUpMusic
									;S5B_PrepareForSFX.asm		PrepareForSFX



									;S6A_PlaySong.asm
									;S6B_MusicFadeOut.asm		FadeOut
incsrc "include/S6_ProcessMusicInput.asm";S6_ProcessMusicInput.asm	ProcessAPU2Input
									

									;S7A_SongRead.asm			L_0BF0, L_0BFE, L_0C01, L_0C22
incsrc "include/S7_ProcessVCMD.asm"		;S7_ProcessVCMD.asm			L_0C46
									;S7B_ProcessNote.asm		L_0CA8
									;S7C_NoteCalculations.asm	L_0CD2
									;S7D_KeyOnVoices.asm		KeyOnVoices,	KeyOffVoicesWithCheck,	KeyOffVoices
									;S7E_DispatchCommands.asm	L_0D40 
										;***(calls Commands.asm)***
										;***(calls CommandTable.asm)***
									;S7F_VolumeWrite.asm		L_0FDB
									;S7G_DeltaCalc.asm			CalcPortamentoDelta,	Divide16, L_1075
									;S7H_NoteTables.asm			NoteDurations, VelocityValues, PanValues, DefDSPValues, DefDSPRegs,
									;								EchoFilter0, EchoFilter1, PitchTable
									
									;S8A_SkipKeyOff.asm			ShouldSkipKeyOff
incsrc "include/S8_RemoteCommands.asm"	;S8_RemoteCommands.asm		L_10A1
									;S8B_VoiceHandler.asm		HandleVoice, L_1170, L_11FF, L_1201
									;S8C_VolumeHandler.asm		L_122D, L_123A, L_123F, L_124D
									;S8D_GetCommandData.asm		GetCommandData, GetCommandDataFast, L_1260 (readahead)


incsrc "include/S9_UploadRoutine.asm"	;S9_UploadRoutine.asm		L_12F2
										;***(calls InstrumentData.asm)***	
		
SFXTable0:
SFXTable1:
SongPointers:
