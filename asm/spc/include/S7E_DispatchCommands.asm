;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
; dispatch vcmd in A calls the Commands.asm command list
L_0D40:
{
	asl	a
	mov	x, a
	mov	a, #$00
	jmp	(CommandDispatchTable-$B4+x)         ; $DA minimum? (F90)

	incsrc "../Commands.asm"
	
; vcmd DA: set instrument
; vcmd DB: set pan
; vcmd DC: pan fade
; vcmd DE: vibrato on
; vcmd DF: vibrato off
; vcmd EA: vibrato fade
; vcmd E0: set master volume
; vcmd E1: master vol fade
; vcmd E2: tempo
; vcmd E3: tempo fade
; vcmd E4: transpose (global)
; vcmd E5: tremolo on
; vcmd E6: tremolo off
; vcmd EB: pitch envelope (release)
; vcmd EC: pitch envelope (attack)
; vcmd E7: set voice volume base
; vcmd E8: voice volume base fade
; vcmd EE: tuning
; vcmd E9: call subroutine
; vcmd EF: set echo vbits/volume
; vcmd F2: echo volume fade
; vcmd F0: disable echo
; vcmd F1: set echo delay, feedback, filter
}
; dispatch table for 0d44 (vcmds)

		;106B
incsrc "../CommandTable.asm"
