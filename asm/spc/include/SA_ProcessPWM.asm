;-----------------------------------------------------------
; ProcessPWM
;   Notice: pFlag = 1 (use dp1)
;-----------------------------------------------------------
ProcessPWM:
{
	mov	a, !PWMPulsePtr
	lsr	a
	mov	y, a
	mov	a, (!PWMBrrPtr)+y
	bcc	+
	eor	a, #$0f
	bra	++
+	eor	a, #$f0
++	mov	(!PWMBrrPtr)+y, a
	inc	!PWMPulsePtr
	mov	a, !PWMPulsePtr
	mov	y, #0
	mov	x, #18
	div	ya, x
	mov	a, y
	bne	+
	inc	!PWMPulsePtr
	inc	!PWMPulsePtr
	bra	++
+	mov	a, !PWMPulsePtr
	cmp	a, #71			;\  * This "71" means brr sampe 63
	bne	++			; |   If PWMPulseptr reaches lastblock-1,
	mov	a, #3			; |   return to firstblock+1.
	mov	!PWMPulsePtr, a		;/
++	ret
}

;-----------------------------------------------------------
; ProcessPWM
;   args : y = brr number
;   Notice: p flag = 0 (use dp0)
;-----------------------------------------------------------
SetPWMBrrPtr:
{
	mov	!RegDSPComAdd, #$5d		; #$5d : DIR
	mov	a, !RegDSPComDat
	mov	$17, a
	mov	$16, #2				; this "2" means refer BRR LOOP
	mov	a, y
	asl	a
	asl	a
	mov	y, a
	bcc	+
	inc	$17
+	mov	a, ($16)+y			;\
	push	a				; | get brr loop start address
	inc	y				; |
	mov	a, ($16)+y			; |
	mov	y, a				; |
	pop	a				;/
	setp
	movw	!PWMBrrPtr, ya
	mov	!PWMPulsePtr, #3		; init pulse overwrite point
	clrp
	ret
}
