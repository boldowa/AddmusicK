; send 04+X to APUX; get APUX to 00+X with "debounce"?
ReadInputRegister:
{
L_05AC:
	mov   a, !RegCPU_IO+x			; \ Get the input byte
	cmp   a, !RegCPU_IO+x			; | Keep getting it until it's "stable"
	bne   L_05AC					; /
	mov   y, a						; \ 
	mov   a, !LastRegValue+x		; |*holds the last used register value for this APU register (0-3) in a, then 
	mov   !LastRegValue+x, y		; |*stores the newest value into that register
	cbne  !LastRegValue+x, L_05C1	; |*if the new register info is the same as the last received 
	mov   y, #$00					; |*then assume it's not an updated value and disregard 
	mov   !RegValue+x, y			; |*clear out $00 (!RegValue), indicating nothing needs to be done
L_05C0:								; |
	ret								; /
L_05C1:								; \
	mov   !RegValue+x, y			; |*store the value from the register into $00 (!RegValue)
	;mov   a, y						; |*put it into a even though nothing takes advantage of this . . . . 
	ret								; /*
}	