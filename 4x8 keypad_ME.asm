; THIS SUBROUTINE RETRIEVES DATA FROM THE KEYPAD AND IDENTIFIES THE KEY PRESSED
; IT STORES THE ASCII CODE OF THE KEY PRESSED IN THE CHARACTER DISPLAY MEMORY (ie CDM 31H)
; IT ALSO HAS IN IT SOME STATUTORY FLAGS SUCH AS: 01H(KEY PRESSED FLAG)

//       				EN 			BIT P3.3 					; 
//       				RS 			BIT P2.5
			
					ORG		 	00H

					MOV 		P1,#0FFH					; MAKE PORT1 AN INPUT PORT
					MOV 		P3, #00001100B
       				ACALL 		LCD_SET

M1:					CALL   		KEYPAD_ID
					SJMP   		M1
       
KEYPAD_ID:			;ACALL 		LCD_DLY						; 20mS KEYBOARD/PAD DEBOUNCER
					MOV 		P1,#0FFH					; MAKE PORT1 AN INPUT PORT
					MOV 		P3, #00001100B
        			MOV 		A, P1
       				CJNE 		A, #11111111B, K_ID_1
					JMP   		KEYFNL
       
K_ID_1: 	 		ACALL 		LCD_DLY						; 20mS KEYBOARD/PAD DEBOUNCER
		       		MOV 		A, P1
       				CJNE 		A, #11111111B, K_ID_2
					JMP 	  	KEYFNL
       
K_ID_2:				MOV 		P3, #11111110B
       				MOV 		A, P1
       				CJNE 		A, #11111111B, ROW_0
       
       				MOV 		P3, #11111101B
       				MOV 		A, P1
       				CJNE 		A, #11111111B, ROW_1
       
       				MOV 		P3, #11101111B
       				MOV 		A, P1
       				CJNE 		A, #11111111B, ROW_2
       
       				MOV 		P3, #11011111B
   					MOV 		A, P1
					CJNE 		A, #11111111B, ROW_3
      
					JMP 	  	KEYFNL
       
ROW_0: 				MOV 		DPTR, #LT_ROW_1
       				SJMP 		K_ID_3						; FIND ROW 1
	
ROW_1:		 		MOV 		DPTR, #LT_ROW_2
       				SJMP 		K_ID_3						; FIND ROW 2

ROW_2: 				MOV 		DPTR, #LT_ROW_3
       				SJMP 		K_ID_3						; FIND ROW 3

ROW_3: 				MOV 		DPTR, #LT_ROW_4
															; FIND ROW 4
K_ID_3: 			RRC 		A
      				JNC 		K_ID_4						; MATCH
      				INC 		DPTR
      				SJMP 		K_ID_3
      
K_ID_4:				ACALL 		LCD_DLY						; THIS SR IS TO ENSURE THAT THE USER RELEASES THE KEY TO AVOID KEY REPETITION
					MOV 		P1,#0FFH					; MAKE PORT 1 AN INPUT PORT
					MOV 		P3, #00001100B
					MOV 		A, P1
       				CJNE 		A, #11111111B, K_ID_4
					
					CLR 		A
       				MOVC 		A, @A+DPTR
;	        		MOV			31H, A						; TEMPORARY SAVE THE ASCII CHARACTERR OF THE KEY IDENTIFIED
					ACALL 		LCD_DLY	
;					SETB		01H							; FLAG INDICATES A KEY IS PRESSED
	        		ACALL 		LCD_SHO
KEYFNL:	   			RET										; RETURN TO KEYPAD_ID
       
; ---------------------------------------------------------------------------------------------------------------------------------------
GET_READY:
; THIS SUBROUTINE CHECKS BUSY FLAG (P0.7=D7) TO ENABLE COMMAND OR DATA LATCH-IN
; SFR BITS: P0.7 (D7), P2.5 (RS), P2.6 (R/!W), P3.3 (EN)
					SETB 		P1.7 						; MAKE P0.7 INPUT PORT
					CLR 		P2.5	 					; RS=0 ACCESS LCD COMMAND REG
					SETB 		P2.6 						; R/W=1 READ COMMAND REG
															; READ COMMAND REG AND CHECK BUSY FLAG
BACK:	
					CLR 		P3.3	 					; E=0 L-TO-H PULSE
					SETB 		P3.3 						; E=1 FOR L-TO-H PULSE
					JB 			P1.7, BACK					; STAY UNTIL BUSY FLAG=0
					RET										; RETURN TO THE CALLER PROGRAM

; ---------------------------------------------------------------------------------------------------------------------------------------
LCD_CMD:
; THIS SUBROUTINE SENDS THE ASCII CODE FOR THE COMMAND CHARATER TO BE DISPLAYED ON THE LCD
; IT CALLS READY (OSR) TO CHECK BUSY FLAG FOR COMMAND TO BE LATCHED-IN
; OPERATING REGISTER: A
; SFR BITS: P0 (LCD DATA PORT D0-D7), P2.5 (RS), P2.6 (R/!W), P3.3 (EN)
 
					ACALL 		GET_READY 					; IS LCD READY?
					MOV   		P1, A						; LATCH COMMAND INTO LCD DATA PORT	  
					CLR   		P2.5						; RS=0 ACCESS LCD COMMAND REG
					CLR			P2.6						; WRITE
					SETB  	 	P3.3						; H-TO-L PULSE TO LATCH-IN
					CLR   		P3.3						; H-TO-L PULSE TO LATCH-IN
					RET										; RETURN TO THE CALLER PROGRAM

; ---------------------------------------------------------------------------------------------------------------------------------------
LCD_DLY:
					MOV   		R6,#3BH
HERE2:
					MOV   		R7,#0A8H
HERE1:
					DJNZ   		R7,HERE1	
					DJNZ   		R6,HERE2
					RET

; ---------------------------------------------------------------------------------------------------------------------------------------
LCD_SET:
; THIS SUBROUTINE SETS THE MODE OF OPERATION OF THE LCD
; IT CALLS LCD_CMD OSR TO LATCH-IN THE COMMAND
; OPERATING REGISTER: A									
					MOV   		A, #38H						; 2 LINES, 5 X 7 MATRIX DISPLAY
					CALL  	 	LCD_CMD						; LATCH COMMAND JUST ABOVE INTO THE LCD
					MOV   		A, #80H						; DISPLAY ON SECOND LINE
					CALL 	  	LCD_CMD						; LATCH COMMAND JUST ABOVE INTO THE LCD
					MOV   		A, #06H						; INCREMENT FROM LEFT TO RIGHT
					CALL 	  	LCD_CMD						; LATCH COMMAND JUST ABOVE INTO THE LCD
 		         	MOV 		A, #0EH						; DISPLAY ON, CURSOR BLINKING
					CALL 	  	LCD_CMD						; LATCH COMMAND JUST ABOVE INTO THE LCD
  		        	MOV 		A, #01H						; CLEAR AND RETURN TO HOME
					CALL   		LCD_CMD						; LATCH COMMAND JUST ABOVE INTO THE LCD
					RET										; RETURN TO THE CALLER PROGRAM

; ---------------------------------------------------------------------------------------------------------------------------------------
LCD_SHO:
; THIS SUBROUTINE SENDS THE ASCII CODE FOR THE DATA CHARATER TO BE DISPLAYED ON THE LCD
; IT CALLS READY (OSR) TO CHECK BUSY FLAG FOR DATA TO BE LATCHED-IN
; OPERATING REGISTER: A
; SFR BITS: P0 (LCD DATA PORT D0-D7), P2.5 (RS), P2.6 (R/!W), P3.3 (EN)
					ACALL 		GET_READY 					; IS LCD READY?
					MOV   		P1, A						; LATCH DATA INTO LCD DATA PORT	
					SETB   		P2.5						; RS=1, ACCESS LCD DATA REG
					CLR			P2.6						; R/!W=0, WRITE
					SETB   		P3.3						; H-TO-L PULSE TO LATCH-IN
					CLR   		P3.3						; H-TO-L PULSE TO LATCH-IN
					RET

; **********************************************
	       			ORG 		200H

LT_ROW_1: 			DB 			'0','1','2','3','4','5','6','7'		; DATA STORED IN ASCII CODE
LT_ROW_2: 			DB 			'E','R','T','U','I','O','P','8'
LT_ROW_3: 			DB 			'A','S','D','F','H','J','L','9'
LT_ROW_4: 			DB 			'Z','X','C','V','B','N','M','*'		; '*' IS RESERVED FOR THE FUNCTION 'NEXT'

					END