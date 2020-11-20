; -------------------------------- DrawSquare --------------------------------

%assign startingPointX 12
%assign startingPointY 10
%assign width 8
%assign height 6
%assign squareColour 4

%assign endX 4
%assign endY 2
DrawSquare:
	push 	bp
	mov		bp, sp

	sub		sp, 4				; Reserve space for local variables

	push	ax
	push	bx
	
	mov		bx, [bp + startingPointY]
	add		bx, [bp + height]

	mov		[bp - endY], bx		; Calculate the biggest Y point

DrawsSquareLoop:
	mov		ax, [bp + startingPointX]
	add		ax, [bp + width]

	mov		[bp - endX], ax		; Calculate the biggest X point

	push	word [bp + startingPointX]
	push	word [bp + startingPointY]
	push	word [bp - endX]
	push	word [bp + startingPointY]
	push	word [bp + squareColour]
	call	DrawLine			; Draw a line

    mov     ax, [bp + startingPointY]
    inc     ax
    cmp     ax, [bp - endY]
    mov     [bp + startingPointY], ax
    jl      DrawsSquareLoop		; If current Y point is less than the greatest, loop, else the square is fully drawn
    
DrawSquareFinish:
	pop		bx
	pop 	ax
	mov		sp, bp
	pop		bp

	ret 10

; -------------------------------- Draw Line --------------------------------

; Parameters declaration
%assign x0 12
%assign y0 10
%assign	x1	8
%assign y1 6
%assign colour 4

; Local variables declaration
%assign e2 12
%assign err 10
%assign sy 8
%assign sx 6
%assign deltaX 4
%assign deltaY 2
DrawLine:
	push 	bp	
	mov		bp, sp				; Push the stack

	sub		sp, 12				; Reserve space for local variables

    push    ax
    push    bx                  ; push the registers to save then after leaving the function
    push    cx

	mov		ax, [bp + x1]
	sub		ax,	[bp + x0]       ; ax = x1 - x0;
	
	cmp 	ax, 0               ; Compare ax (x1 - x0) with 0. If negative, negate it to get the absolute
	jge		DrawLine_DeltaXPositive
	neg 	ax

DrawLine_DeltaXPositive:

	mov		[bp - deltaX], ax  	; dx = x1 - x0

	mov		ax, [bp + y1]
	sub		ax, [bp + y0]       ; ax = y1 - y0

	cmp 	ax, 0               ; Compare ax (y1 - y0) with 0. If negative, negate it to get the absolute
	jge		DrawLine_DeltaYPositive 
	neg		ax

DrawLine_DeltaYPositive:
	mov		[bp - deltaY], ax	; dy = y1 - y0

	mov		ax, [bp + x0]
	cmp		ax, [bp + x1]		; compare x0 to x1

	jl		SetSXToOne
	jge		SetSXToMinusOne

DrawLine_CompareY0Y1:

	mov		ax, [bp + y0]
	cmp		ax, [bp + y1]		; compare y0 to y1

	jl		SetSyToOne
	jge		SetSyToMinusOne

DrawLine_SetErr:

	mov		ax, [bp - deltaX]
	sub		ax, [bp - deltaY]
	mov		[bp - err], ax		; err = deltaX - deltaY

	call	LoopDraw

    pop     cx
    pop     bx
    pop     ax

	mov 	sp, bp
	pop		bp				

	ret		10					; clear stack and memory

SetSXToOne:
	xor		ax, ax				; set ax to 0
	add		ax, 1				
	mov		[bp - sx], ax		; sx = 1
	jmp		DrawLine_CompareY0Y1

SetSXToMinusOne:
	xor		ax, ax				; set ax to 0
	add		ax, -1
	mov		[bp - sx], ax		; sx = -1
	jmp		DrawLine_CompareY0Y1

SetSyToOne:
	xor		ax, ax				; set ax to 0
	add		ax, 1
	mov		[bp - sy], ax		; sy = 1
	jmp		DrawLine_SetErr

SetSyToMinusOne:
	xor		ax, ax				; set ax to 0
	add		ax, -1
	mov		[bp - sy], ax		; sy = -1
	jmp		DrawLine_SetErr

LoopDraw:
	push	word [bp + x0]
	push	word [bp + y0]
	push	word [bp + colour]
	call	DrawPixelToMemory   ; push the parameters and draw pixel

	mov		ax, [bp + x0]
	cmp		ax, [bp + x1]		; comapre x0 to x1
	je		LoopDraw_X0EqualX1
	jne		LoopDraw_ContinueLoop		; if equal, compare y0 to y1. if not, continue the loop

LoopDraw_ContinueLoop:
	mov		ax, [bp - err]
	imul	ax, 2				
	mov		[bp - e2], ax		; e2 = 2 * err

	xor		ax, ax
	sub		ax, [bp - deltaY]	; ex = -deltaY
	cmp		ax, [bp - e2]		; compare e2 to (-deltaY)

	jle		LoopDraw_E2Greater			; if -dy <= e2 (e2 > -dy), execute

LoopDraw_ContinueLoop2:

	mov		ax, [bp - e2]
	cmp		ax, [bp - deltaX]		; compare deltaX to e2

	jl		LoopDraw_E2Smaller		; if e2 < deltaX, execute

LoopDraw_ContinueLoop3:

	jmp		LoopDraw			; loop again

; -------------------------------- JUMPS --------------------------------

LoopDraw_X0EqualX1:
	mov		ax, [bp + y0]
	cmp 	ax, [bp + y1]	; compare y0 to y1
    
	je		LoopDraw_Y0EqualY1			
	jne		LoopDraw_ContinueLoop	; if equal, leave the loop. if not, continue

LoopDraw_Y0EqualY1:
	ret						; if x0 == x1 and y0 == y1, return

LoopDraw_E2Greater:
	mov		ax, [bp - err]
	sub		ax, [bp - deltaY]
	mov		[bp - err], ax	; err = err - deltaY

	mov		ax, [bp + x0]
	add		ax, [bp - sx]
	mov		[bp + x0], ax	; x0 = ex + sx

	jmp		LoopDraw_ContinueLoop2

LoopDraw_E2Smaller:
	mov		ax, [bp - err]
	add		ax, [bp - deltaX]
	mov		[bp - err], ax	; err = err + deltaX;

	mov		ax, [bp + y0]
	add		ax, [bp - sy]
	mov		[bp + y0], ax	; y0 = y0 + sy

	jmp		LoopDraw_ContinueLoop3

; -------------------------------- Draw Pixel --------------------------------

%assign a 8
%assign b 6
%assign	colour2	4
DrawPixel:
	push	bp
	mov		bp, sp

	push	ax
	push	cx
	push	dx

	mov		cx, [bp + a]
	mov		dx, [bp + b]
	mov		al, [bp + colour2]
	mov 	ah, 0ch
	int 	10h	

	pop		dx
	pop		cx
	pop		ax

	mov 	sp, bp
	pop		bp

	ret		6

%assign a 8
%assign b 6
%assign colour2 4
DrawPixelToMemory:
	push	bp
	mov		bp, sp

	push	ax
	push 	bx
	push	cx
	push	dx
	
	mov ax, 0A000h
	mov es, ax

	mov		ax, [bp + b]
	mov		bx, 320
	mul		bx

	mov		di, ax
	add		di, [bp + a]

	mov		al, [bp + colour2]
	stosb

	;pop		es
	pop		dx
	pop		cx
	pop		bx
	pop		ax

	mov 	sp, bp
	pop		bp

	ret		6