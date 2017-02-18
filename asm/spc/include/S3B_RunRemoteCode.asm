RunRemoteCode:
{
	mov $15, #$03	; remoteCodeTargetAddr = $0390+x
	bra RunRemoteCodePrepare		
RunRemoteCode2:
	mov $15, #$01	; remoteCodeTargetAddr2 = $0190+x
RunRemoteCodePrepare:
	mov $14, #$90	; remote address = $0z90+x
	mov a, x
	mov y, a		; since there is no ($zz)+x command yet there is a ($zz)+y command
RunRemoteCodeSub:
	mov	a, !ChannelByte+x
	push	a
	mov	a, !ChannelHiByte+x
	push	a
	mov	a, ($14)+y
	mov	!ChannelByte+x, a
	inc 	$14
	mov	a, ($14)+y
	mov	!ChannelHiByte+x, a
	mov	a, #$01
	mov	!runningRemoteCode, a
	call	L_0C57			; This feels evil.  Oh well.  At any rate, this'll run the code we give it.
	mov	a, #$00
	mov	!runningRemoteCode, a
	pop	a
	mov	!ChannelHiByte+x, a
	pop	a
	mov	!ChannelByte+x, a
	ret
}