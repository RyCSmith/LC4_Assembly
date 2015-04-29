; Ryan Smith
; HW #9 Part 3, Program to test moving graphics display 
; Purpose: Draws a 10x10 pixel box and moves based on user input using keyboard.
; Commands: "i"-up, "m"-down, "j"-left, "k"-right

;;; Define some colors

BLACK .UCONST x0000	; 0 00000 00000 00000
RED   .UCONST x7C00	; 0 11111 00000 00000
GREEN .UCONST x03E0	; 0 00000 11111 00000
BLUE  .UCONST x001F	; 0 00000 00000 11111
WHITE .UCONST x7FFF	; 0 11111 11111 11111

;;; Program code

.CODE
.ADDR x0000         	;; load the following code into USER CODE region: x0000

.FALIGN
	LC R0, BLACK		;; Draw full black background
	TRAP x03 		
	LC R0, WHITE
	CONST R6 x00 		;; Assign a Data Memory location to store position
	HICONST R6 x47
	CONST R1 x40 		;; Beginning Position from caller
	HICONST R1 x00
	CONST R2 x40
	HICONST R2 x00
	CONST R3 x00 		;; Max left/top position for x/y
	HICONST R3 x00
	CONST R4 x76 		;; Max position (w/offset 10) for x
	HICONST R4 x00
	CONST R5 x72 		;; Max position (w/offset 10) for y
	HICONST R5 x00
	STR R1 R6 0 	
	STR R2 R6 1
	STR R3 R6 2
	STR R4 R6 3
	STR R5 R6 4
	TRAP x04 			;; Draw first position

MOVE_COMMAND
	TRAP x00 			;; Get Character from Keyboard
	CMPI R0 x0A			;; Checks for Carriage Return (QUIT)
	BRz End	
LEFT	
	CONST R1 x6A 		;; R1 = "j"
	HICONST R1 x00
	CMP R0 R1			;; Compares to look for "j"
	BRnp RIGHT
	CONST R6 x00 		;; R6 = location of location holder in DM
	HICONST R6 x47
	LDR R1 R6 0 		;; Loads location
	LDR R2 R6 1
	LC R0, BLACK 		;; Fills in current location with Black (ERASE)
	TRAP x04
	CONST R6 x00 		;; R6 = location of location holder in DM
	HICONST R6 x47
	LDR R1 R6 0 		;; Loads location
	LDR R2 R6 1
	LDR R3 R6 2			;; Loads max left position
	ADD R4 R2 -10       ;; Subtracts 10 from position to check move
	CMP R4 R3
	BRn LIMIT_LEFT 		
	ADD R2 R2 -10 		;; Adjust values per user request
	STR R2 R6 1 		;; Stores updated location
	LC R0, WHITE
	TRAP x04 			;; Paints box in new location
	BRnzp MOVE_COMMAND
LIMIT_LEFT
	LC R0, WHITE 		;; Draws box in current position if move is not allowed
	TRAP x04
	BRnzp MOVE_COMMAND
RIGHT
	CONST R1 x6B 		;; R1 = "k"
	HICONST R1 x00
	CMP R0 R1			;; Compares to look for "k"
	BRnp UP 	
	CONST R6 x00 		;; R6 = location of location holder in DM
	HICONST R6 x47
	LDR R1 R6 0 		;; Loads location
	LDR R2 R6 1
	LC R0, BLACK 		;; Fills in current location with Black (ERASE)
	TRAP x04
	CONST R6 x00 		;; R6 = location of location holder in DM
	HICONST R6 x47
	LDR R1 R6 0 		;; Loads location
	LDR R2 R6 1
	LDR R3 R6 3			;; Loads max right position
	ADD R4 R2 10        ;; Adds 10 from position to check move
	CMP R4 R3
	BRp LIMIT_RIGHT 
	ADD R2 R2 10 		;;Adjusts values as per user request
	STR R2 R6 1 		;; Stores updated location
	LC R0, WHITE
	TRAP x04 			;; Paints box in new location
	BRnzp MOVE_COMMAND
LIMIT_RIGHT
	LC R0, WHITE 		;; Draws box in current position if move is not allowed
	TRAP x04
	BRnzp MOVE_COMMAND
UP
	CONST R1 x69 		;; R1 = "i"
	HICONST R1 x00
	CMP R0 R1			;; Compares to look for "i"
	BRnp DOWN 	
	CONST R6 x00 		;; R6 = location of location holder in DM
	HICONST R6 x47
	LDR R1 R6 0 		;; Loads location
	LDR R2 R6 1
	LC R0, BLACK 		;; Fills in current location with Black (ERASE)
	TRAP x04
	CONST R6 x00 		;; R6 = location of location holder in DM
	HICONST R6 x47
	LDR R1 R6 0 		;; Loads location
	LDR R2 R6 1
	LDR R3 R6 2			;; Loads max up position
	ADD R4 R1 -10       ;; Subtracts 10 from position to check move
	CMP R4 R3
	BRn LIMIT_UP
	ADD R1 R1 -10 		;;Adjusts values as per user request
	STR R1 R6 0 		;; Stores updated location
	LC R0, WHITE	
	TRAP x04 			;; Paints box in new location
	BRnzp MOVE_COMMAND
LIMIT_UP
	LC R0, WHITE 		;; Draws box in current position if move is not allowed
	TRAP x04
	BRnzp MOVE_COMMAND
DOWN
	CONST R1 x6D 		;; R1 = "m"
	HICONST R1 x00
	CMP R0 R1			;; Compares to look for "m"
	BRnp MOVE_COMMAND 	
	CONST R6 x00 		;; R6 = location of location holder in DM
	HICONST R6 x47
	LDR R1 R6 0 		;; Loads location
	LDR R2 R6 1
	LC R0, BLACK 		;; Fills in current location with Black (ERASE)
	TRAP x04
	CONST R6 x00 		;; R6 = location of location holder in DM
	HICONST R6 x47
	LDR R1 R6 0 		;; Loads location
	LDR R2 R6 1
	LDR R3 R6 4			;; Loads max down position
	ADD R4 R1 10        ;; Adds 10 from position to check move
	CMP R4 R3
	BRzp LIMIT_DOWN 
	ADD R1 R1 10 		;;Adjusts values as per user request
	STR R1 R6 0 		;; Stores updated location
	LC R0, WHITE
	TRAP x04 			;; Paints box in new location
	BRnzp MOVE_COMMAND
LIMIT_DOWN
	LC R0, WHITE 		;; Draws box in current position if move is not allowed
	TRAP x04
	BRnzp MOVE_COMMAND
END
	BRnzp END