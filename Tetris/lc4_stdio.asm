;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Description: 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; This file has 1 big job:
;;;
;;; It defines "wrapper" subroutines for the TRAPS
;;; in os.asm.  The purpose of which is to provide
;;; a standard way of passing arguments to and from 
;;; the TRAPS in os.asm
;;;
;;; NOTE: each time we add a trap to os.asm
;;; we must create a 'wrapper' in this file
;;; if we wish to call that trap from our C programs
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;; WRAPPER SUBROUTINES FOLLOW ;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    
.CODE
.ADDR x0010    ;; we start after line 10, to preserve USER_START


;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; TRAP_PUTC Wrapper ;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;

.FALIGN
lc4_putc

	;; prologue
	STR R7, R6, #-2	; save caller’s return address
	STR R5, R6, #-3	; save caller’s frame pointer
	ADD R6, R6, #-3 ; update stack pointer
	ADD R5, R6, #0	; update frame pointer
	; no local variables, so no need to allocate for them

	;; function body 

	; setup arguments for TRAP_PUTC:
	LDR R0, R5, #3	; copy param (c) from stack, into register R0
	TRAP x01        ; R0 has been set, so we can call TRAP_PUTC
	
	; TRAP_PUTC has no return value, so nothing to copy back to stack

	;; epilogue
	ADD R6, R5, #0	;; pop locals off stack
	ADD R6, R6, #3	;; free space for return address, base pointer, and return value
	STR R7, R6, #-1	;; store return value
	LDR R5, R6, #-3	;; restore base pointer
	LDR R7, R6, #-2	;; restore return address
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; TRAP_GETC Wrapper ;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

.FALIGN
lc4_getc
	;; prologue
	STR R7, R6, #-2	; save caller’s return address
	STR R5, R6, #-3	; save caller’s frame pointer
	ADD R6, R6, #-3 ; update stack pointer
	ADD R5, R6, #0	; update frame pointer
	; no local variables, so no need to allocate for them

	;; function body 

	TRAP x00        ; R0 has been set, so we can call TRAP_PUTC
	ADD R7, R0, #0	; Load R0 into R7
	
	; TRAP_PUTC has no return value, so nothing to copy back to stack

	;; epilogue
	ADD R6, R5, #0	;; pop locals off stack
	ADD R6, R6, #3	;; free space for return address, base pointer, and return value
	STR R7, R6, #-1	;; store return value
	LDR R5, R6, #-3	;; restore base pointer
	LDR R7, R6, #-2	;; restore return address
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; TRAP_VIDEO_COLOR Wrapper ;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

.FALIGN
lc4_video_color
	;; prologue
	STR R7, R6, #-2	; save caller’s return address
	STR R5, R6, #-3	; save caller’s frame pointer
	ADD R6, R6, #-3 ; update stack pointer
	ADD R5, R6, #0	; update frame pointer
	; no local variables, so no need to allocate for them

	;;Store R5 and R6 somewhere so they don't get overwritten
	CONST R3 x00
	HICONST R3 x43
	STR R5, R3, #0
	STR R6, R3, #1
	
	;; function body 
	LDR R0, R5, #3	; put color into R0
	TRAP x03        ; R0 has been set, so we can call TRAP_PUTC
	
	; TRAP_PUTC has no return value, so nothing to copy back to stack

	;;Get R5 and R6 back before continuing
	CONST R3 x00
	HICONST R3 x43
	LDR R5, R3, #0
	LDR R6, R3, #1

	;; epilogue
	ADD R6, R5, #0	;; pop locals off stack
	ADD R6, R6, #3	;; free space for return address, base pointer, and return value
	STR R7, R6, #-1	;; store return value
	LDR R5, R6, #-3	;; restore base pointer
	LDR R7, R6, #-2	;; restore return address
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; TRAP_VIDEO_BOX Wrapper ;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

.FALIGN
lc4_video_box
	;; prologue
	STR R7, R6, #-2	; save caller’s return address
	STR R5, R6, #-3	; save caller’s frame pointer
	ADD R6, R6, #-3 ; update stack pointer
	ADD R5, R6, #0	; update frame pointer
	; no local variables, so no need to allocate for them

	;;Store R5 and R6 somewhere so they don't get overwritten
	CONST R3 x00
	HICONST R3 x43
	STR R5, R3, #0
	STR R6, R3, #1

	;; function body 
	LDR R0, R5, #3	; put color into R0
	LDR R1, R5, #4	; put starting row into R1
	LDR R2, R5, #5	; put starting column into R2
	TRAP x04        ; R0 has been set, so we can call TRAP_PUTC
	
	; TRAP_PUTC has no return value, so nothing to copy back to stack

	;;Get R5 and R6 back before continuing
	CONST R3 x00
	HICONST R3 x43
	LDR R5, R3, #0
	LDR R6, R3, #1

	;; epilogue
	ADD R6, R5, #0	;; pop locals off stack
	ADD R6, R6, #3	;; free space for return address, base pointer, and return value
	STR R7, R6, #-1	;; store return value
	LDR R5, R6, #-3	;; restore base pointer
	LDR R7, R6, #-2	;; restore return address
	RET