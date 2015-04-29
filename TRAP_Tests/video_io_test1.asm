; Ryan Smith
; HW #9 Test Program to test TRAP_VIDEO_COLOR 
; Purpose: Paints each pixel of the video output a color specified by the caller


;;; Define some colors

BLACK .UCONST x0000	; 0 00000 00000 00000
RED   .UCONST x7C00	; 0 11111 00000 00000
GREEN .UCONST x03E0	; 0 00000 11111 00000
BLUE  .UCONST x001F	; 0 00000 00000 11111
WHITE .UCONST x7FFF	; 0 11111 11111 11111



;;; Program to test trap: TRAP_VIDEO_COLOR

.CODE
.ADDR x0000       ; load the following code into USER CODE region: x0000

.FALIGN
	LC R0, RED		;; color to draw on screen
	TRAP x03 		;; call the trap
END
	BRnzp END
