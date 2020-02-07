#include <p16f887.inc>
list p=16f887 

	cblock 0x20
		led_cnt
		aux1
		aux2
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
	call	RotinaInicializacao
	goto 	Main
	
RotinaInicializacao:
	bcf		STATUS, RP1
	bcf		STATUS, RP0	;INDO PARA O BANCO 0
	movlw	0x0F
	movwf	PORTA		; SERVE PARA INDICAR SE A SA�DA OU ENTRADA EST�
						; EM NIVEL ALTO OU BAIXO(0OU1)
						;NESSE VAMOS SETAR OS PINOS RA0-RA3 POR ISSO
						; ESTA 0X0F(00001111)
	call	Delay_1s	;chama		
	
	clrf	led_cnt		; contador=0
	
LedCountLoop:	
	clrf	PORTA		;limpa os pinos RA0-RA3
	
	movlw	.0
	subwf	led_cnt,W	; subtrai w de f resultado de f-w
	btfsc	STATUS, Z	; verifica se o resultado � 0 ou 1, LED_CNT=0?
	bsf		PORTA, RA0	;se for 0 ele pula essa linha e executa a proxima, se for 1 ele executa essa linha	
	
	movlw	.1
	subwf	led_cnt,W	; subtrai w de f resultado de f-w
	btfsc	STATUS, Z	; verifica se o resultado � 0 ou 1, LED_CNT=0?
	bsf		PORTA, RA1	;se for 0 ele pula essa linha e executa a proxima, se for 1 ele executa essa linha
	
	movlw	.2
	subwf	led_cnt,W	; subtrai w de f resultado de f-w
	btfsc	STATUS, Z	; verifica se o resultado � 0 ou 1, LED_CNT=0?
	bsf		PORTA, RA2	;se for 0 ele pula essa linha e executa a proxima, se for 1 ele executa essa linha
	
	movlw	.3
	subwf	led_cnt,W	; subtrai w de f resultado de f-w
	btfsc	STATUS, Z	; verifica se o resultado � 0 ou 1, LED_CNT=0?
	bsf		PORTA, RA3	;se for 0 ele pula essa linha e executa a proxima, se for 1 ele executa essa linha
	
	call	Delay_200ms
	incf	led_cnt, F	; incrementa o led_cnt
	
	movlw	.4
	subwf	led_cnt, W	
	btfss	STATUS, Z	;LED_CNT=4?
	goto	LedCountLoop	;n�o
	clrf	PORTA		; sim
	return
	
Delay_1s:
	call	Delay_200ms
	call	Delay_200ms
	call	Delay_200ms
	call	Delay_200ms
	call	Delay_200ms
	return
	
Delay_1ms:
	
	movlw	.248
	movwf	aux1
	
Delay1:
	nop	
	decfsz	aux1, F		; decrementa a aux1
	goto	Delay1
	return
		
Delay_200ms:
	
	movlw	.200
	movwf	aux2
	
Delay2:
	call	Delay_1ms
	decfsz	aux2, F
	goto	Delay2
	return
	
	
	end