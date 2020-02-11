#include <p16f887.inc>
#define  button PORTB, RB0
list p=16f887 
__CONFIG _CONFIG1, 0x2FF4
__CONFIG _CONFIG2, 0x3FFF

	cblock 0x20
		led_cnt
		aux1
		aux2
		_wreg
		_status
		timer_counter_5s
		timer_counter_500ms
		level ; level:
			  ;	0 = hard
			  ; 1 = easy
		sequency
		move
		last_move
		last_input
		timeout	; 0 = não ocorreu timout
				; 1 = ocorreu timout
		current_move
	endc
	HARD_TIMEOUT	EQU .3
	EASY_TIMEOUT	EQU .5
	MOVE_BASE_ADDR	EQU	0X5F
	
	TMR0_50MS	EQU .61
	LED_RED		EQU B'00000001'
	LED_YELLOW	EQU	B'00000010'
	LED_GREEN	EQU	B'00000100'
	LED_BLUE	EQU	B'00001000'
	
	org 	0x00	; vetor de reset
	goto 	Start
	
	org 	0x04	; vetor de interrupção
	movwf	_wreg
	swapf	STATUS, W
	movwf	_status
	clrf	STATUS
	btfsc	INTCON, T0IF	;T0IF==1?
	goto	Timer0Interrupt	;sim
	goto	ExitInterrupt	;não
	
Timer0Interrupt:
	bcf		INTCON, T0IF
	incf	timer_counter_5s, F	
	incf	timer_counter_500ms, F
	movlw	TMR0_50MS
	movwf	TMR0			;reset tmr0 counter	
	goto	ExitInterrupt

ExitInterrupt:
	swapf	_status, W
	movwf	STATUS
	swapf	_wreg, F
	swapf	_wreg, W
	retfie
	
Start:
	; --- I/O config ---
	
	clrf	timer_counter_5s
	clrf	timer_counter_500ms
	bsf 	STATUS,RP0	; seleciona o banco 1
	movlw	B'11110000'
	movwf	TRISA		; TRIS SERVE PARA INDICAR SE VAI SER ENTRADA OU SAÍDA
						;configurando as portas de saída RA0-RA3
						; e as portas de entrada RA4-RA7
	bcf		TRISB, TRISB0	; config RB0 as input - start
	bcf		TRISB, TRISB1	; config RB1 as input - level
	bsf		STATUS, RP1	;PARA IR PARA O BANCO 3 USAR O ANSEL
	clrf	ANSEL		; CONFIGURANDO TODOS OS PORTA, PINOS DIGITAL
						; ENTRADA E SAÍDA
	clrf	ANSELH		; PORTB pins as digital I/O
	
	;--- TMR0 configuração ---
	; INTCON, TMR0, OPTION_REG
	; OPTION_REG
	; T0CS=0 (INTOSC/4)
	; PSA=0 (PRESCALER TMR0)
	; PS=111
	bcf		STATUS, RP1	 	; change to bank1
	movlw	b'00000111'
	iorwf	OPTION_REG, F	; set PSA<2:0>
	movlw   b'11010111' 	
	andwf	OPTION_REG, F	; clear T0CS, PSA
	bcf		STATUS, RP0		; change to bank0
	movlw	.61
	movwf 	TMR0
	bcf		INTCON, T0IF	; clear interrupt flag
	bsf		INTCON, T0IE	; enable TMR0 interrut
	bsf		INTCON, GIE		; enable interrupts
	call	RotinaInicializacao
	
	movlw	MOVE_BASE_ADDR
	movwf	FSR
	bcf		STATUS, IRP
	clrf	last_move
					
Main:
	btfsc	button		; button start pressed?
	goto 	Main
	
	movf	TMR0, W
	movwf	move		; copy TMR0 to move
	clrf	sequency	; sequency = 0
	btfsc	PORTB, RB1 	; level select
	goto	LevelEasy
	goto	LevelHard
	
LevelEasy:
	bcf		level, 0
	goto	Main_Loop
LevelHard:
	bsf		level, 0	
	goto 	Main_Loop
	
Main_Loop:
	call	SorteiaNumero
	call	StoreNumber
	goto 	Main
;-------------
;Recebe move	
SorteiaNumero:
	movlw 	0x03
	andwf	move	;clear bits <7:2>
	
	movlw 	.0
	subwf	move, W
	btfsc	STATUS, Z
	retlw	LED_RED
	
	movlw 	.1
	subwf	move, W
	btfsc	STATUS, Z
	retlw	LED_YELLOW
	
	movlw 	.2
	subwf	move, W
	btfsc	STATUS, Z
	retlw	LED_GREEN
	
	movlw 	.3
	subwf	move, W
	btfsc	STATUS, Z
	retlw	LED_BLUE

StoreNumber:
	movwf	INDF
	incf	FSR, F
	incf	last_move, F
	return
		
EntradaMovimento:
	bcf		STATUS, RP1
	bcf		STATUS, RP0; VAI PARA O BANCO 0
	clrf	last_input
	movlw	MOVE_BASE_ADDR
	movwf	FSR	
	
InputLoop:
	movf	PORTD, W
	andlw	0x0F		; clear RD<7:4>
	sublw	0x00
	btfsc	STATUS, Z	; test inputs
	goto	ButtonNotPressed
	goto 	ButtonPressed
ButtonNotPressed:
	btfss	timeout, 0 	; occoreu timeout?
	goto	InputLoop	; não
	return

ButtonPressed:
	movwf	current_move
	call 	CompareInput
	sublw	.0
	btfsc	STATUS, Z ; botão correto pressionado?
	return			; não
	incf	last_input, F ;sim	
	incf 	FSR, F
	movf	last_input, W
	subwf	last_move, W
	btfsc	STATUS, C ;	last_input > last_move?
	return	
	goto	InputLoop	
	
	
CompareInput:
	movf	current_move
	subwf	INDF, W
	btfss	STATUS, Z
	retlw	.0			; bottão errado
	retlw	current_move
	
	
RotinaInicializacao:
	bcf		STATUS, RP1
	bcf		STATUS, RP0	;INDO PARA O BANCO 0
	movlw	0x0F
	movwf	PORTA		; SERVE PARA INDICAR SE A SAÍDA OU ENTRADA ESTÁ
						; EM NIVEL ALTO OU BAIXO(0OU1)
						;NESSE VAMOS SETAR OS PINOS RA0-RA3 POR ISSO
						; ESTA 0X0F(00001111)
	call	Delay_1s	;chama		
	
	clrf	led_cnt		; contador=0
	
LedCountLoop:	
	clrf	PORTA		;limpa os pinos RA0-RA3
	
	movlw	.0
	subwf	led_cnt,W	; subtrai w de f resultado de f-w
	btfsc	STATUS, Z	; verifica se o resultado é 0 ou 1, LED_CNT=0?
	bsf		PORTA, RA0	;se for 0 ele pula essa linha e executa a proxima, se for 1 ele executa essa linha	
	
	movlw	.1
	subwf	led_cnt,W	; subtrai w de f resultado de f-w
	btfsc	STATUS, Z	; verifica se o resultado é 0 ou 1, LED_CNT=0?
	bsf		PORTA, RA1	;se for 0 ele pula essa linha e executa a proxima, se for 1 ele executa essa linha
	
	movlw	.2
	subwf	led_cnt,W	; subtrai w de f resultado de f-w
	btfsc	STATUS, Z	; verifica se o resultado é 0 ou 1, LED_CNT=0?
	bsf		PORTA, RA2	;se for 0 ele pula essa linha e executa a proxima, se for 1 ele executa essa linha
	
	movlw	.3
	subwf	led_cnt,W	; subtrai w de f resultado de f-w
	btfsc	STATUS, Z	; verifica se o resultado é 0 ou 1, LED_CNT=0?
	bsf		PORTA, RA3	;se for 0 ele pula essa linha e executa a proxima, se for 1 ele executa essa linha
	
	call	Delay_200ms
	incf	led_cnt, F	; incrementa o led_cnt
	
	movlw	.4
	subwf	led_cnt, W	
	btfss	STATUS, Z	;LED_CNT=4?
	goto	LedCountLoop	;não
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