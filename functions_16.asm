; Various sub-routines that will be useful to the boot loader code	

; Output Carriage-Return/Line-Feed (CRLF) sequence to screen using BIOS

Console_Write_CRLF:
	mov 	ah, 0Eh						; Output CR
    mov 	al, 0Dh
    int 	10h
    mov 	al, 0Ah						; Output LF
    int 	10h
    ret

; Write to the console using BIOS.
; 
; Input: SI points to a null-terminated string

Console_Write_16:
	mov 	ah, 0Eh						; BIOS call to output value in AL to screen

Console_Write_16_Repeat:
    mov		al, [si]
	inc     si
    test 	al, al						; If the byte is 0, we are done
	je 		Console_Write_16_Done
	int 	10h							; Output character to screen
	jmp 	Console_Write_16_Repeat

Console_Write_16_Done:
    ret

; Write string to the console using BIOS followed by CRLF
; 
; Input: SI points to a null-terminated string

Console_WriteLine_16:
	call 	Console_Write_16
	call 	Console_Write_CRLF
	ret










; ; Parameters declaration
; %assign x0 12
; %assign y0 10
; %assign	x1	8
; %assign y1 6
; %assign colour 4

; ; Local variables declaration
; %assign saveAX 16
; %assign saveCX 14
; %assign e2 12
; %assign err 10
; %assign sy 8
; %assign sx 6
; %assign deltaX 4
; %assign deltaY 2
; DrawLine:
; 	push 	bp	
; 	mov		bp, sp				; Push the stack

; 	sub		sp, 16				; Reserve space for local variables

; 	mov 	[bp - saveAX], ax
; 	mov		[bp - saveCX], cx

; 	mov		ax, [bp + x1]
; 	sub		ax,	[bp + x0]
	
; 	cmp 	ax, 0
; 	jge		DrawLineNeg
; 	neg 	ax

; DrawLineNeg:

; 	mov		[bp - deltaX], ax  	; dx = x1 - x0

; 	mov		ax, [bp + y1]
; 	sub		ax, [bp + y0]

; 	cmp 	ax, 0
; 	jge		DrawLineNegative
; 	neg		ax

; DrawLineNegative:
; 	mov		[bp - deltaY], ax	; dy = y1 - y0

; 	mov		ax, [bp + x0] 		; 0x903b
; 	cmp		ax, [bp + x1]		; compare x0 to x1

; 	jl		LessThanX
; 	jge		BiggerEqualThanX

; DrawLineContinue:

; 	mov		ax, [bp + y0]
; 	cmp		ax, [bp + y1]		; compare y0 to y1

; 	jl		LessThanY
; 	jge		BiggerEqualThanY

; DrawLineContinue2:

; 	mov		ax, [bp - deltaX]
; 	sub		ax, [bp - deltaY]
; 	mov		[bp - err], ax		; err = deltaX - deltaY

; 	call	LoopDraw	; 0x9058

; 	; mov		si, [bp - deltaX]
; 	; call	Console_WriteLine_16

; 	; mov		si,	[bp - deltaY]
; 	; call	Console_WriteLine_16

; 	mov		ax, [bp - saveAX]
; 	mov		cx, [bp - saveCX]

; 	mov 	sp, bp
; 	pop		bp				

; 	ret		10					; clear stack and memory

; 	; 0x9023

; LessThanX:
; 	xor		ax, ax				; set ax to 0
; 	add		ax, 1				
; 	mov		[bp - sx], ax		; sx = 1
; 	jmp		DrawLineContinue

; BiggerEqualThanX:
; 	xor		ax, ax				; set ax to 0
; 	add		ax, -1
; 	mov		[bp - sx], ax		; sx = 1
; 	jmp		DrawLineContinue

; LessThanY:
; 	xor		ax, ax				; set ax to 0
; 	add		ax, 1
; 	mov		[bp - sy], ax		; sy = 1
; 	jmp		DrawLineContinue2

; BiggerEqualThanY:
; 	xor		ax, ax				; set ax to 0
; 	add		ax, -1
; 	mov		[bp - sy], ax		; sy = -1
; 	jmp		DrawLineContinue2

; LoopDraw:
; 	push	word [bp + x0]		; 0x9089
; 	push	word [bp + y0]
; 	push	word [bp + colour]
; 	call	DrawPixelToMemory			; 0x9092

; 	mov		ax, [bp + x0] 		; 0x909b
; 	cmp		ax, [bp + x1]		; comapre x0 to x1
; 	;xor		ax, ax
; 	je		LoopEqualX
; 	jne		LoopDrawLoop		; if equal, compare y0 to y1. if not, enter the draw loop

; LoopDraw2:

; 	cmp		ax, 0
; 	jne		LoopDrawLoop
	
; 	ret

; LoopDrawLoop:
; 	mov		ax, [bp - err]
; 	imul	ax, 2				
; 	mov		[bp - e2], ax		; e2 = 2 * err
; 	xor		ax, ax
; 	sub		ax, [bp - deltaY]	; ex = -deltaY
; 	cmp		ax, [bp - e2]		; compare e2 to (-deltaY)

; 	jl		LoopLessDY			; if less, jump

; LoopDrawLoop2:

; 	mov		ax, [bp - deltaX]
; 	cmp		ax, [bp - e2]		; compare deltaX to e2

; 	jg		LoopGreaterDX		; if greater. jump

; LoopDrawLoop3:

; 	jmp		LoopDraw			; loop again





; ; ------------------------ JUMPS --------------------------------






; LoopEqualX:
; 	mov		ax, [bp + y0]
; 	cmp 	ax, [bp + y1]	; compare y0 to y1
; 	;xor		ax, ax
; 	je		LoopEqualY			
; 	jne		LoopDrawLoop	; if equal, return. if not, enter the draw loop
; LoopEqualX2:
; 	jmp		LoopDraw2

; LoopEqualY:
; 	ret						; if x0 == x1 and y0 == y1, return

; LoopLessDY:
; 	mov		ax, [bp - err]
; 	sub		ax, [bp - deltaY]
; 	mov		[bp - err], ax	; err = err - deltaY

; 	mov		ax, [bp + x0]
; 	add		ax, [bp - sx]
; 	mov		[bp + x0], ax	; x0 = ex + sx

; 	jmp		LoopDrawLoop2

; LoopGreaterDX:
; 	mov		ax, [bp - err]
; 	add		ax, [bp - deltaX]
; 	mov		[bp - err], ax	; err = err + deltaX;

; 	mov		ax, [bp + y0]
; 	add		ax, [bp - sy]
; 	mov		[bp + y0], ax	; y0 = y0 + sy

; 	jmp		LoopDrawLoop3




; ; ----------------------------------------------------------------------------------



; %assign a 8
; %assign b 6
; %assign	colour2	4
; DrawPixel:
; 	push	bp
; 	mov		bp, sp

; 	mov		cx, [bp + a]
; 	mov		dx, [bp + b]
; 	mov		al, [bp + colour2]
; 	mov 	ah, 0ch
; 	int 	10h	

; 	mov 	sp, bp
; 	pop		bp

; 	ret		6


; %assign a 8
; %assign b 6
; %assign colour2 4
; DrawPixelToMemory:
; 	push	bp
; 	mov		bp, sp
	
; 	mov ax, 0A000h
; 	mov es, ax

; 	mov		ax, [bp + b]
; 	mov		bx, 320
; 	mul		bx

; 	mov		di, ax
; 	add		di, [bp + a]

; 	mov		al, [bp + colour2]
; 	stosb

; 	mov 	sp, bp
; 	pop		bp

; 	ret		6
; ; Equal:

; ; PutPixel:
; ; 	mov cx, 10  ; column
; ; 	mov dx, 20  ; row
; ; 	mov al, 15  ; white
; ; 	mov ah, 0ch ; put pixel
; ; 	int 10h
; ; 	ret
