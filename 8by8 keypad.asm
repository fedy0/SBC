
       ORG 00h
      mov P1,#0ffh							;make port1 an input port
       mov P2,#00h
       en bit P0.0 
       RS bit P0.1
       acall init_lcd
       
   
     
   K2:    acall delay
          mov a,P1
          cjne a,#11111111b,over
          mov P2,#00h
          sjmp K2
       
       
       
Over:  acall delay
       mov a,P1
       cjne a,#11111111b,over1
       sjmp K2
       
over1: 
          
       mov P2,#11111110b
       mov a,P1
       cjne a,#11111111b,row_0
       
       mov P2, #11111101b
       mov a,P1
       cjne a,#11111111b,row_1
       
       mov P2, #11111011b
       mov a,P1
       cjne a,#11111111b,row_2
       
       mov P2, #11110111b
       mov a,P1
       cjne a,#11111111b,row_3
       
        mov P2,#11101111b
       mov a,P1
       cjne a,#11111111b,row_0
       
       mov P2, #11011111b
       mov a,P1
       cjne a,#11111111b,row_1
       
       mov P2, #10111111b
       mov a,P1
       cjne a,#11111111b,row_2
       
       mov P2, #01111111b
       mov a,P1
       cjne a,#11111111b,row_3
       ljmp K2
       
row_0:
       mov dptr,#LT_ROW_1
       sjmp find
row_1:
       mov dptr,#LT_ROW_2
       sjmp find
row_2: 
       mov dptr,#LT_ROW_3
       sjmp find
row_3: 
       mov dptr,#LT_ROW_4

find: rrc a
      jnc match
      inc dptr
      sjmp find
      
match:;acall E
       clr a
       movc a,@a+dptr
       ;mov P0,a
       acall data_wrt
       acall delay
       acall delay
       ljmp K2
       
delay:
mov r2,#50
mov r1,#255

delaya:Djnz r1,delaya
       Djnz r2,delaya
       ret
       
data_wrt: 
          mov P3,a
          setb RS
          ;clr RW
          setb en
          acall delay
          clr en
          ret
com_wrt: mov P3,a
         clr RS
         ;clr RW
         setb en
         acall delay
         clr en
         ret
init_lcd: mov a,#38h;2 lines 5x7 matrix
          acall com_wrt
          acall delay
          mov a,#0eh;display on, cursor blinking
          acall com_wrt
          acall delay
          ;mov a,#01h;clear and return to home
          ;acall com_wrt
          ;acall delay
          ;mov a,#06h;increment cursor to right
          ;acall com_wrt
          ;acall delay
          mov a,#80h;position
          acall com_wrt
          acall delay
          ret
          
    ; E:     ;mov a,#01h
            ;acall com_wrt
            ;acall delay
     ;       mov a,#80h
      ;      acall com_wrt
       ;     acall delay
        ;    ret
       
       ORG 300h
LT_ROW_1: 				DB 			'0','1','2','3','4','5','6','7'		; DATA STORED IN ASCII CODE
LT_ROW_2: 				DB 			'E','R','T','U','I','O','P','8'
LT_ROW_3: 				DB 			'A','S','D','F','H','J','L','9'
LT_ROW_4: 				DB 			'Z','X','C','V','B','N','M','*'		; '*' IS RESERVED FOR THE FUNCTION 'NEXT'

//db_0: db '123'
//db_1: db '456'
//db_2: db '789'
//db_3: db '*0#'
end