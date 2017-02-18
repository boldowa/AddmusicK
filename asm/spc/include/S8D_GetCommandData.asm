; get next vcmd stream byte for voice $46
GetCommandData:
{
	mov	x, !CurrentChannel
; get next vcmd stream byte into A/Y
GetCommandDataFast:	;* Works since it assumes you already have the current channel in x now
	mov	a, (!ChannelByte+x)	;* Gets the value in the byte address listed in !ChannelByte (16-bit)
L_1260:
	inc	!ChannelByte+x			;* Move onto the next byte by incrementing $30, the holder of the current address for this channel
	bne	L_1266					;\* If it rolled over to 00, that means that you need to increment the high byte of the address 
	inc	!ChannelHiByte+x		;/*
L_1266:
	mov	y, a					;*Done to make certain calculations easier
	ret
}	
;;;;;