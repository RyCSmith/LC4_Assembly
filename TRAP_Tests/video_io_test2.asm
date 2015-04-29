; Ryan Smith
; HW #9 Test Program to test TRAP_VIDEO_BOX 
; Purpose: Draws a 10x10 pixel box at the location specified by the caller

;;; Define some colors

BLACK .UCONST x0000	; 0 00000 00000 00000
RED   .UCONST x7C00	; 0 11111 00000 00000
GREEN .UCONST x03E0	; 0 00000 11111 00000
BLUE  .UCONST x001F	; 0 00000 00000 11111
WHITE .UCONST x7FFF	; 0 11111 11111 11111



;;; Program to test trap: TRAP_VIDEO_BOX

.CODE
.ADDR x0000       ; load the following code into USER CODE region: x0000

.FALIGN
	LC R0, WHITE		;; Sets color to white
	CONST R1 x0A 		;; Sets location for beginning x coordinate
	HICONST R1 x00 		
	CONST R2 x0A 		;; Sets location for beginning y coordinate
	HICONST R2 x00
	TRAP x04 			;; Executes Trap
END
	BRnzp END