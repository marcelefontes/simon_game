#include <p16f887.inc>
list p=16f887 

	cblock 0x20
		contador_led
	endc

	org 	0x00	; vetor de reset
	goto 	Start
	
	org 	0x04	; vetor de interrupção
	retfie			; sai da interrupção
	
Start:
	; --- I/O config ---
	bsf 	STATUS,RP0	; seleciona o banco 1
	movlw	B'11110000'
	movwf	TRISA		; TRIS SERVE PARA INDICAR SE VAI SER ENTRADA OU SAÍDA
						;configurando as portas de saída RA0-RA3
						; e as portas de entrada RA4-RA7
	bsf		STATUS, RP1	;PARA IR PARA O BANCO 3 USAR O ANSEL
	clrf	ANSEL		; CONFIGURANDO TODOS OS PORTA, PINOS DIGITAL
						; ENTRADA E SAÍDA
						
Main:
	goto	RotinaInicializacao
	
RotinaInicializacao:
	bcf		STATUS, RP1
	bcf		STATUS, RP0	;INDO PARA O BANCO 0
	movlw	0x0F
	movwf	PORTA		; SERVE PARA INDICAR SE A SAÍDA OU ENTRADA ESTÁ
						; EM NIVEL ALTO OU BAIXO(0OU1)
						;NESSE VAMOS SETAR OS PINOS RA0-RA3 POR ISSO
						; ESTA 0X0F(00001111)
	call	Delay_1s	;chama
	clrf	PORTA		
	
Delay_1s: