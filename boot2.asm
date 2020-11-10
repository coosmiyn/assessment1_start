; Second stage of the boot loader

BITS 16

ORG 9000h
	jmp 	Second_Stage

%include "functions_16.asm"

;	Start of the second stage of the boot loader
	
Second_Stage:
    mov 	si, second_stage_msg	; Output our greeting message
    call 	Console_WriteLine_16

	; Put your test code here

	mov ah, 0   ; set display mode function.
	mov al, 13h ; mode 13h = 320x200 pixels, 256 colors.
	int 10h     ; set it!

	push	word 50		;x0
	push	word 50 		;y0
	push	word 50;		;x1
	push	word 50		;y1
	push	word 5 		;colour
	call 	DrawLine	; 0x9121

	; push	word 10		;x0
	; push	word 10 		;y0
	; push	word 15			;colour
	; call 	DrawPixel

	;call	PutPixel

	; This never-ending loop ends the code.  It replaces the hlt instruction
	; used in earlier examples since that causes some odd behaviour in 
	; graphical programs.
endloop:
	jmp		endloop

second_stage_msg	db 'Second stage loaded', 0

	times 3584-($-$$) db 0	