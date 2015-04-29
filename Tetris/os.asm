;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;   OS - TRAP VECTOR TABLE   ;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

.OS
.CODE
.ADDR x8000
	; TRAP vector table
	JMP TRAP_GETC		; x00
	JMP TRAP_PUTC		; x01
	JMP TRAP_DRAW_PIXEL	; x02
	JMP TRAP_VIDEO_COLOR	; x03
	JMP TRAP_VIDEO_BOX	; x04

	OS_KBSR_ADDR .UCONST xFE00  ; ‘alias’ for keyboard status reg
	OS_KBDR_ADDR .UCONST xFE02  ; ‘alias’ for keyboard data reg
	OS_ADSR_ADDR .UCONST xFE04
	OS_ADDR_ADDR .UCONST xFE06
	OS_VIDEO_NUM_COLS .UCONST #128
	OS_VIDEO_NUM_ROWS .UCONST #124		

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;; OS VIDEO MEMORY ;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	.DATA
	.ADDR xC000	
OS_VIDEO_MEM .BLKW x3E00


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;   OS - TRAP IMPLEMENTATION   ;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

.CODE
.ADDR x8200
.FALIGN
	;; by default, return to usercode: PC=x0000
	CONST R7, #0   ; R7 = 0
	RTI            ; PC = R7 ; PSR[15]=0


;;;;;;;;;;;;;;;;;;;;;;;;;;;   TRAP_GETC   ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Function: Get a single character from keyboard
;;; Inputs           - none
;;; Outputs          - R0 = ASCII character from keyboard

.CODE
TRAP_GETC
   	LC R0, OS_KBSR_ADDR  ; R0 = address of keyboard status reg
   	LDR R0, R0, #0       ; R0 = value of keyboard status reg
   	BRzp TRAP_GETC       ; if R0[15]=1, data is waiting!
                             ; else, loop and check again...

   	; reaching here, means data is waiting in keyboard data reg

   	LC R0, OS_KBDR_ADDR  ; R0 = address of keyboard data reg
   	LDR R0, R0, #0       ; R0 = value of keyboard data reg
	RTI                  ; PC = R7 ; PSR[15]=0


;;;;;;;;;;;;;;;;;;;;;;;;;;;   TRAP_PUTC   ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Function: Put a single character out to ASCII display
;;; Inputs           - R0 = ASCII character from keyboard
;;; Outputs          - none

.CODE
TRAP_PUTC
	LC R1, OS_ADSR_ADDR  ;Puts address of ASCII status register in R1
	LDR R1, R1, #0		 ;Loads value store at the location stored in R1 into R1
	BRzp TRAP_PUTC		 ;Loops if that value indicates that there is nothing there
	LC R1, OS_ADDR_ADDR  ;Loads into R1 the address of ASCII data register
	STR R0, R1, #0		 ;Stores the value in R0 to the ASCII data register (to screen)
	RTI 				 ; PC = R7 ; PSR[15]=0


;;;;;;;;;;;;;;;;;;;;;;;;;   TRAP_DRAW_PIXEL   ;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Function: Draw point on video display
;;; Inputs           - R0 = row to draw on (y)
;;;                  - R1 = column to draw on (x)
;;;                  - R2 = color to draw with
;;; Outputs          - none

.CODE
TRAP_DRAW_PIXEL
	LEA R3, OS_VIDEO_MEM	  ; R3=start address of video memory
	LC  R4, OS_VIDEO_NUM_COLS ; R4=number of columns

	MUL R4, R0, R4		  ; R4= (row * NUM_COLS)
	ADD R4, R4, R1	 	  ; R4= (row * NUM_COLS) + col
	ADD R4, R4, R3		  ; Add the offset to the start of video memory
	STR R2, R4, #0		  ; Fill in the pixel with color from user (R2)
	RTI			  ; PC = R7 ; PSR[15]=0
	
	

;;;;;;;;;;;;;;;;;;;;;;;;;   TRAP_VIDEO_COLOR   ;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Function: Set all pixels of VIDEO display to a certain color
;;; Inputs           - R0 = color to set all pixels to
;;; Outputs          - none

.CODE
TRAP_VIDEO_COLOR
	LEA R1, OS_VIDEO_MEM	 	;; R1=start address of video memory
	LC  R2, OS_VIDEO_NUM_COLS 	;; R2=number of columns
	LC  R3, OS_VIDEO_NUM_ROWS 	;; R3=number of rows
	CONST R4 x00 		;; creates row counter in R3, sets it to zero
	HICONST R4 x00
ROW_LOOP
	CMP R3 R4			;;compares counter to number of rows
	BRnz RETURN			;;if less continues, if not jumps down below
	CONST R5 x00		;;creates column counter in R5, sets it to 0
	HICONST R5 x00
COLUMN_LOOP
	MUL	R6 R4 R2 		;;multiples row counter by 128, stores in R6		
	CMP R2 R5			;;compares counter and number of columns
	BRnz NEXT_ROW_SECTION		;;if less continues, if not jumps down below
	ADD R6 R6 R5		;;adds column counter(R5) to R6, stores in R6
	ADD R6 R6 R1		;;adds the beginning index of the video memory stored in R1
	STR	R0 R6 0			;;stores RO(color) at  R6
	ADD R5 R5 1			;;Column counter R5 = R5 + 1
	BRnzp COLUMN_LOOP	;;Jumps back up to compare number of counter
NEXT_ROW_SECTION			
	ADD R4 R4 1 		;;Row counter (R3) = R3 + 1
	BRnzp ROW_LOOP		;;Jumps back up to compare number of rows
RETURN
	RTI			  		;; PC = R7 ; PSR[15]=0


;;;;;;;;;;;;;;;;;;;;;;;;;   TRAP_VIDEO_BOX   ;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Function: Set all pixels of a 10x10 box given by caller to color given by caller
;;; Inputs           - R0 = color to set all pixels to
;;;	Inputs			 - R1 = starting y coordinate (row)
;;;	Inputs			 - R2 = starting x coordinate (column)
;;; Outputs          - none

.CODE
TRAP_VIDEO_BOX
	CONST R3 x76 			;; these lines load max values for 
	HICONST R3 x00 			;; x and y the compare them with the
	CONST R4 x72 			;; caller values to make sure they
	HICONST R4 x00 			;; will not exit video memory
	CMP R3 R2
	BRnz FINISH
	CMP R4 R1
	BRnz FINISH
	CONST R3 x00 			;; R3 = Data Memory Address x4500
	HICONST R3 x45
	STR R0 R3 0				;; Stores Color choice in DM x4500
	STR R1 R3 1 			;; Stores starting y coordinate(row) in DM x4501
	STR R2 R3 2				;; Stores starting x coordinate(column) in DM x4502	
	CONST R2 x00 			;; "Housekeeping" - moves DM start address (x4500) to R2
	HICONST R2 x45
	LEA R0, OS_VIDEO_MEM	;; R0 = start address of video memory
	STR R0 R2 3				;; Stores start address of video memory in DM x4503
	CONST R0 x80 			;; Stores value 128 in R0
	HICONST R0 x00 			
	STR R0 R2 4
	CONST R0 x00 			;; Creates row counter in R0
	HICONST R0 x00 	
OUTER_LOOP
	CMPI R0 x0A 			;; Compares Row counter(R0) against 10
	BRzp FINISH 			;; If nz, jumps to RETURN
	CONST R1 x00 			;; Creates Column counter in R1
	HICONST R1 x00
INNER_LOOP
	CMPI R1 10 				;; Compares column counter with 10
	BRzp CONT_OUTER_LOOP	;; Advances if nz
	LDR R3 R2 1				;; R3 = starting y coordinate
	ADD R6 R0 R3			;; R6 = Row counter + starting y coordinate
	LDR R3 R2 4 			;; R3 = 128
	MUL R6 R6 R3 			;; R6 = (row counter + starting y) * 128
	LDR R3 R2 3				;; R3 = starting location of video memory
	ADD R6 R6 R3 			;; R6 = row location + video memory start location
	LDR R3 R2 2				;; R3 = starting x coordinate
	ADD R6 R6 R3			;; R6 = final row location + starting x coordinate
	ADD R6 R6 R1			;; R6 = destination (overall location + current x counter)
	LDR R3 R2 0 			;; R3 = color selection
	STR R3 R6 0				;; Stores color in Video Memory Location
	ADD R1 R1 1 			;; R1 = R1 + 1 (column counter)
	BRnzp INNER_LOOP		;; Return to Inner_Loop
CONT_OUTER_LOOP
	ADD R0 R0 1 			;; R0 = R0 + 1 (row counter)
	BRnzp OUTER_LOOP 		;; Return to Outer_Loop
FINISH
	RTI			 			;; PC = R7 ; PSR[15]=0






	
	