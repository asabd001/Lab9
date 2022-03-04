.orig x3000
;this stack lab computes the polish notation of a set of calls
;push_val(4) pushes the value 4 onto the stack [4]


;push_val(3) pushes the value 3 onto the stack [4,3]



;push_val(2) pushes the value 2 onto the stack [4,3,2]



;add_val() pop 3,2 and push the result of 3+2 onto the stack [4,5]



;add_val() pop 4,5 and push the result of 4+5 onto the stack[9]




;move the top value of the stack into r4
	
	LD R4, BASE
	LD R5, MAX
	LD R6, TOS
	
	; Reverse polish calculator
	LD R4, BASE
	LD R5, MAX
	LD R6, TOS
	
	; Enter first number & push on stack
	LEA R0, ENTER_MSG
	PUTS
	GETC
	OUT
	LD R1, ZERO
	NOT R1, R1
	ADD R1, R1, #1
	ADD R0, R0, R1 ; subtracts x30 from inputted number, converting from ascii to number
	
	LD R1, SUB_STACK_PUSH_PTR
	JSRR R1
	LD R0, NEWLINE
	OUT
	
	
	; Enter second number & push on stack
	LEA R0, ENTER_MSG
	PUTS
	GETC
	OUT
	LD R1, ZERO
	NOT R1, R1
	ADD R1, R1, #1
	ADD R0, R0, R1 ; subtracts x30 from inputted number

	LD R1, SUB_STACK_PUSH_PTR
	JSRR R1
	LD R0, NEWLINE
	OUT
	
	; assume operation is +
	LEA R0, OP_MSG
	PUTS
	GETC
	OUT
	LD R0, NEWLINE
	OUT
	
    ; call reverse polish notation subroutine	
	LD R1, SUB_RPN_ADD1
	JSRR R1

    ; pop the result and print
	LD R1, SUB_STACK_POP_PTR
    JSRR R1

	LD R2, ZERO
	ADD R0, R0, R2
	OUT
	
halt
;-----------------------------------------------------------------------------------------------
; test harness local data:

BASE .FILL   xA000
MAX .FILL   xA005
TOS .FILL   xA000
ZERO .FILL   x30
HEX_20  .FILL   x20
NEWLINE .FILL #10
SUB_STACK_PUSH_PTR  .FILL x3200
SUB_STACK_POP_PTR  .FILL x3400
SUB_RPN_ADD1        .FILL x3600
ENTER_MSG   .STRINGZ    "Enter a number "
OP_MSG   .STRINGZ    "Enter an operation "

.end

.ORIG XA000
THE_STACK   .BLKW   x5
;===============================================================================================
.end

;------------------------------------------------------------------------------------------
; Subroutine: SUB_STACK_PUSH
; Parameter (R0): The value to push onto the stack
; Parameter (R4): BASE: A pointer to the base (one less than the lowest available
;                       address) of the stack
; Parameter (R5): MAX: The "highest" available address in the stack
; Parameter (R6): TOS (Top of Stack): A pointer to the current top of the stack
; Postcondition: The subroutine has pushed (R0) onto the stack (i.e to address TOS+1). 
;		    If the stack was already full (TOS = MAX), the subroutine has printed an
;		    overflow error message and terminated.
; Return Value: R6 ← updated TOS
;------------------------------------------------------------------------------------------
.orig x3200 ;;push_val(int val)implement your push function that will push a value onto the stack

	SUB_STACK_PUSH
	
	    ST R0, BACKUP_R0_3200
	    ST R2, BACKUP_R2_3200
	    ST R4, BACKUP_R4_3200
	    ST R5, BACKUP_R5_3200

        ADD R2, R5, #0      ;store negative of max in R2
        NOT R2, R2
        ADD R2, R2, #1
        
        ADD R2, R2, R6
        BRzp ERROR          ;compare max and tos

        ADD R6, R6, #1      ;move tos
        STR R0, R6, #0      ;add value to stack
        BR EXIT
        
    ERROR
        LEA R0, ERROR_MSG
        PUTS

    EXIT
	    LD R0, BACKUP_R0_3200
	    LD R2, BACKUP_R2_3200
	    LD R4, BACKUP_R4_3200
	    LD R5, BACKUP_R5_3200
ret
;-----------------------------------------------------------------------------------------------
; SUB_STACK_PUSH local data

    BACKUP_R0_3200  .BLKW   #1
    BACKUP_R2_3200  .BLKW   #1
    BACKUP_R4_3200  .BLKW   #1
    BACKUP_R5_3200  .BLKW   #1
    ERROR_MSG   .STRINGZ    "Error: Overflow\n"

;===============================================================================================
.end
.orig x3400 ;; add_val() pops two values from the top of the stack and pushes the result of adding the poppped value into the stack

	SUB_STACK_POP
	
	    ST R2, BACKUP_R2_3400
	    ST R4, BACKUP_R4_3400
	    ST R5, BACKUP_R5_3400

        ADD R2, R4, #0      ;store negative of base in R2
        NOT R2, R2
        ADD R2, R2, #1
        
        ADD R2, R2, R6
        BRnz ERROR1 ; compare base and tos

        LDR R0, R6, #0      ;store tos to R0
        ADD R6, R6, #-1     ;move tos back by one
        BR EXIT1
        
    ERROR1
        LEA R0, ERROR_MSG1
        PUTS
        AND R0, R0, #0

    EXIT1
	    LD R2, BACKUP_R2_3400
	    LD R4, BACKUP_R4_3400
	    LD R5, BACKUP_R5_3400
ret
;-----------------------------------------------------------------------------------------------
; SUB_STACK_POP local data

    BACKUP_R2_3400  .BLKW   #1
    BACKUP_R4_3400  .BLKW   #1
    BACKUP_R5_3400  .BLKW   #1
    ERROR_MSG1   .STRINGZ   "Error: Underflow\n"

.end

;------------------------------------------------------------------------------------------
; Subroutine: SUB_RPN_ADD
; Parameter (R4): BASE: A pointer to the base (one less than the lowest available
;                       address) of the stack
; Parameter (R5): MAX: The "highest" available address in the stack
; Parameter (R6): TOS (Top of Stack): A pointer to the current top of the stack
; Postcondition: The subroutine has popped off the top two values of the stack,
;		    added them together, and pushed the resulting value back
;		    onto the stack.
; Return Value: R6 ← updated TOS address
;------------------------------------------------------------------------------------------
.orig x3600 ;;data you might need

	SUB_RPN_ADD			 
	
	ST R1, BACKUP_R1_3600
	ST R2, BACKUP_R2_3600
	ST R4, BACKUP_R4_3600
	ST R5, BACKUP_R5_3600
	ST R7, BACKUP_R7_3600

	LD R1, SUB_STACK_POP_PTR1
	JSRR R1
	
	ADD R2, R0, #0
	
	LD R1, SUB_STACK_POP_PTR1 ;pops the top of stack...
	JSRR R1
	
	ADD R2, R2, R0  ; and adds it to R2
	ADD R0, R2, #0  ; result stored in R0...

    LD R1, SUB_STACK_PUSH_PTR1 ; so it can go to the top of the stack
	JSRR R1
	
	LD R1, BACKUP_R1_3600
	LD R2, BACKUP_R2_3600
	LD R4, BACKUP_R4_3600
	LD R5, BACKUP_R5_3600
	LD R7, BACKUP_R7_3600
ret
;-----------------------------------------------------------------------------------------------
; SUB_RPN_ADD local data

    BACKUP_R1_3600  .BLKW   #1
    BACKUP_R2_3600  .BLKW   #1
    BACKUP_R4_3600  .BLKW   #1
    BACKUP_R5_3600  .BLKW   #1
    BACKUP_R7_3600  .BLKW   #1
    SUB_STACK_PUSH_PTR1  .FILL x3200
    SUB_STACK_POP_PTR1  .FILL x3400
    ZERO2 .FILL   x30

;===============================================================================================

.end


