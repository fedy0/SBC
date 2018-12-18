       		EN 			BIT P3.3 
       		RS 			BIT P2.5
			
			ORG		 	00H

			MOV 		P1,#0FFH							;MAKE PORT1 AN INPUT PORT
			MOV 		P3, #00001000B
       		ACALL 		INIT_LCD
       
K2:    		ACALL 		DELAY
        	MOV 		A,P1
       		CJNE 		A, #11111111B, OVER
       		MOV 		P3, #00001000B
       		SJMP 		K2
       
OVER:  		ACALL 		DELAY
       		MOV 		A, P1
       		CJNE 		A, #11111111B, OVER1
       		SJMP 		K2
       
OVER1: 		MOV 		P3, #11111110B
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
      
       		LJMP 		K2
       
ROW_0: 		MOV 		DPTR, #LT_ROW_1
       		SJMP 		FIND

ROW_1: 		MOV 		DPTR, #LT_ROW_2
       		SJMP 		FIND

ROW_2: 		MOV 		DPTR, #LT_ROW_3
       		SJMP 		FIND

ROW_3: 		MOV 		DPTR, #LT_ROW_4

FIND: 		RRC 		A
      		JNC 		MATCH
      		INC 		DPTR
      		SJMP 		FIND
      
MATCH: 		CLR 		A
       		MOVC 		A, @A+DPTR
	        ACALL 		DATA_WRT
    		ACALL 		DELAY
       		ACALL 		DELAY
       		LJMP 		K2
       
DELAY:	  	MOV 		R2,#50
			MOV 		R1,#255

DELAYA:		DJNZ 		R1, DELAYA
       		DJNZ 		R2, DELAYA
       		RET
       
DATA_WRT: 	MOV 		P0, A
          	SETB 		RS
          	;CLR RW
          	SETB 		EN
          	ACALL 		DELAY
          	CLR 		EN
          	RET

COM_WRT: 	MOV 		P0, A
         	CLR 		RS
         	;CLR RW		
         	SETB 		EN
         	ACALL 		DELAY
         	CLR 		EN
         	RET

INIT_LCD: 	MOV 		A, #38H						;2 LINES 5X7 MATRIX
          	ACALL 		COM_WRT
          	ACALL 		DELAY
          	MOV 		A, #0EH						;DISPLAY ON, CURSOR BLINKING
          	ACALL 		COM_WRT
          	ACALL 		DELAY
          	MOV 		A, #01H						;CLEAR AND RETURN TO HOME
          	ACALL 		COM_WRT
          	ACALL 		DELAY
          	MOV 		A, #0CH						;POSITION
          	ACALL 		COM_WRT
          	ACALL 		DELAY
          	RET
  
	       	ORG 		100H
LT_ROW_1: 				DB 			'0','1','2','3','4','5','6','7'		; DATA STORED IN ASCII CODE
LT_ROW_2: 				DB 			'E','R','T','U','I','O','P','8'
LT_ROW_3: 				DB 			'A','S','D','F','H','J','L','9'
LT_ROW_4: 				DB 			'Z','X','C','V','B','N','M','*'		; '*' IS RESERVED FOR THE FUNCTION 'NEXT'

			END