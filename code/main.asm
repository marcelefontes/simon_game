#include <p16f887.inc>
list p=16f887 

	cblock 0x20
		contador_led
	endc

	org 	0x00	; vetor de reset
	goto 	Start
	
	org 	0x04	; vetor de interrup��o
	retfie			; sai da interrup��o
	
Start:
	; --- I/O config ---
	bsf 	STATUS,RP0	; seleciona o banco 1
	movlw	B'11110000'
	movwf	TRISA		; TRIS SERVE PARA INDICAR SE VAI SER ENTRADA OU SA�DA
						;configurando as portas de sa�da RA0-RA3
						; e as portas de entrada RA4-RA7
	bsf		STATUS, RP1	;PARA IR PARA O BANCO 3 USAR O ANSEL
	clrf	ANSEL		; CONFIGURANDO TODOS OS PORTA, PINOS DIGITAL
						; ENTRADA E SA�DA
						
Main:
	goto	RotinaInicializacao
	
RotinaInicializacao:
	bcf		STATUS, RP1
	bcf		STATUS, RP0	;INDO PARA O BANCO 0
	movlw	0x0F
	movwf	PORTA		; SERVE PARA INDICAR SE A SA�DA OU ENTRADA EST�
						; EM NIVEL ALTO OU BAIXO(0OU1)
						;NESSE VAMOS SETAR OS PINOS RA0-RA3 POR ISSO
						; ESTA 0X0F(00001111)
	call	Delay_1s	;chama
	clrf	PORTA		
	
Delay_1s: