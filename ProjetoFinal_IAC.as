;=====================================================================================================
;Projeto de Arqutitectura de Computadores
;LEIC-A IST 2016

;Programa "R-TYPE"

;João Bernardo 86443
;Pedro Antunes 86493
;=====================================================================================================
;===================================ZONA EQU - Definicao de constantes================================

ESPACO   		EQU     ' '
FIM_TEXTO       EQU     '@'
CARD            EQU     '#'
ON 				EQU     1
MASCARA			EQU		1000000000010110b
TESTABITS		EQU		0001h
CAR1            EQU     100h
CAR2            EQU     200h

LIMINF			EQU     0015h
LIMSUP			EQU     0002h
LIMD			EQU	    4E00h
LIME            EQU  	0100h
POS_INICIAL     EQU     0000h
POS_INICIAL2    EQU     1700h
POSI_CANHAO  	EQU     0503h
MOVI 			EQU     100h

LEDS 			EQU 	FFF8h
IO_CTRL         EQU     FFFCh
IO_WRITE        EQU     FFFEh 
CURSOR_CORD		EQU		FFF4h
ESCREVER_CORD	EQU		FFF5h

DISP0			EQU 	FFF0h		; escrever no primeiro display de 7 segmentos
DISP1			EQU		FFF1h		; escrever no segundo display de 7 segmentos
DISP2			EQU		FFF2h		; escrever no terceiro display de 7 segmentos
DISP3			EQU		FFF3h		; escrever no quarto display de 7 segmentos

TOPO_PILHA		EQU		FDFFh ;endereco do topo da pilha
TIMERVALUE		EQU 	FFF6h ;endereco do temporizador
ENABLETIMER		EQU		0001h
INTMASK         EQU     FFFAh ;endereco da mascara de interrupcoes
INTMASKMOV		EQU 	1100000000011111b
INTMASKMOV1		EQU		0100000000000000b
INTMASKFIM		EQU		0111111111111111b
TIMERCONTROL	EQU		FFF7h ;endereco do controlo do temporizador
TIMELONG		EQU 	0001h

;Posicao das mensagens:
PrepPos			EQU		0b22h ;msg prep escrita na linha 12 coluna 34
PrimaBotaoPos	EQU 	0d1Fh ;msg prima botao na linha 14 coluna 31
FimJogoPos		EQU		0b21h ;msg prep escrita na linha 12 coluna 33
PontFinalPos	EQU 	0d24h ;msg prima botao na linha 14 coluna 38
;=====================================================================================================
;=============================================ZONA TAB================================================

				ORIG	8000h

TabAsteroides	TAB		13 ;guarda as posicoes onde estao os asteroides
TabBN			TAB 	5

;=====================================================================================================
;=============================================ZONA STR================================================
SPACE			STR		' ', FIM_TEXTO
TRACO  		    STR     '-', FIM_TEXTO
ASTEROIDES		STR		'*', FIM_TEXTO
BURACONEGRO		STR 	'O', FIM_TEXTO
CANHAO          STR		'>)\/' ;Ordem por que vao ser escritos, a partir da posicao atual
Prep            STR  	'Prepare-se', FIM_TEXTO
PrimaBotao      STR  	'Prima o botao IE', FIM_TEXTO
FimJogoMsg      STR  	'Fim do Jogo', FIM_TEXTO
ApagaStr		STR		'                                                                               ', FIM_TEXTO
LinhaCardinal	STR		'###############################################################################', FIM_TEXTO

;=====================================================================================================
;==================================ZONA WORD - Definicao de variaveis=================================

POS_CANHAO      WORD    POSI_CANHAO
POS_TIRO		WORD 	0000h ;3000h
NumeroDeAst		WORD	0h ;Sempre que esta variavel esta a 3 vai ser escrito um Buraco Negro
QuandoEscreve	WORD	12 ;Sempre que esta a 0, vai ser escrito um Ast ou BN no ecra

FlagReinicio	WORD 	0h
FlagTiroColAst 	WORD 	0h
FlagExisteTiro	WORD	0h
TimerFlag		WORD	0h
Left            WORD 	0h
Right           WORD  	0h
Up             	WORD  	0h
Down            WORD   	0h
IE				WORD 	0h
RANDOM			WORD	2828h
CRIAPOSICAO		WORD	0h
FlagTiro		WORD    0h
Aster			WORD    0h
PosTiroInicial	WORD	0h
FlagMoveObst	WORD	2h
Pontuacao 		WORD 	0h
FlagHaLEDS		WORD 	0h
Un				WORD 	0030h
Dez				WORD 	0030h
Cent			WORD 	0030h
Mil				WORD 	0030h

;=====================================================================================================
;=======================================TABELA DE INTERRUPCOES========================================

				ORIG 	FE00h
INT0 			WORD 	Baixo
INT1			WORD 	Cima
INT2			WORD 	Esquerda
INT3            WORD 	Direita	
INT4			WORD	MandaTiro

				ORIG 	FE0Eh
INTIE			WORD	IEPremido
INT15			WORD	TimerInt

;=====================================================================================================
;==================================ZONA III: codigo===================================================

                ORIG    0000h
			
				JMP		Inicio	

;______________________________________________________________________________________________________
;____________________________________ROTINAS DE INTERRUPCAO:___________________________________________


;IEPremido:	Rotina que indica que foi pressionado o botao para iniciar o jogo.
;		Entradas: ---
;		Saidas: M[IE]
;		Efeitos: Altera o valor da WORD IE, indicando que o utilizador quer comecar o jogo.		
IEPremido:		PUSH	R1
				MOV		R1, ON
				MOV		M[IE],R1
				MOV 	M[FlagReinicio], R1
				CALL    Coordenadas
				POP 	R1
				RTI					
					
;Baixo: Rotina que indica que foi pressionado o botao para mover a nave para baixo.
;		Entradas: ---
;		Saidas:	M[Down]
;		Efeitos: Altera o valor da WORD Down, indicando que a nave se deve mover para baixo.		
Baixo:			PUSH	R1
				MOV     R1, ON
				MOV		M[Down],R1
				MOV 	M[FlagReinicio], R1
				CALL    Coordenadas
				POP 	R1
				RTI	
				
;Cima: Rotina que indica que foi pressionado o botao para mover a nave para cima.
;		Entradas: ---
;		Saidas:	M[Up]
;		Efeitos: Altera o valor da WORD Up, indicando que a nave se deve mover para cima.			
Cima:           PUSH	R1
				MOV     R1, ON
				MOV		M[Up],R1
				MOV 	M[FlagReinicio], R1
				CALL    Coordenadas
				POP		R1
				RTI			
				
;Direita: Rotina que indica que foi pressionado o botao para mover a nave para a direita.
;		Entradas: ---
;		Saidas:	M[Right]
;		Efeitos: Altera o valor da WORD Right, indicando que a nave se deve mover para a direita.
Direita:        PUSH	R1
				MOV     R1, ON
				MOV		M[Right],R1
				MOV 	M[FlagReinicio], R1
				CALL    Coordenadas
				POP		R1
				RTI	
				
;Esquerda: Rotina que indica que foi pressionado o botao para mover a nave para a esquerda.
;		Entradas: ---
;		Saidas:	M[Left]
;		Efeitos: Altera o valor da WORD Left, indicando que a nave se deve mover para a esquerda.				
Esquerda:       PUSH	R1
				MOV     R1, ON
				MOV		M[Left],R1
				MOV 	M[FlagReinicio], R1
				CALL    Coordenadas
				POP		R1
				RTI

;MandaTiro: Rotina que indica que foi pressionado o botao para disparar um tiro.
;		Entradas: ---
;		Saidas:	M[FlagTiro]
;		Efeitos: Altera o valor da WORD FlagTiro, indicando que a nave deve disparar um tiro.	
MandaTiro:		PUSH	R1
				MOV     R1, ON
				MOV 	M[FlagReinicio], R1
				MOV		M[FlagTiro],R1
				POP		R1
				RTI

;Timer:				
TimerInt:		PUSH	R3
				MOV		R3, ON
				MOV		M[TimerFlag],R3
				MOV 	R3,TIMELONG
				MOV 	M[TIMERVALUE],R3 ; definir valor de contagem do timer
				MOV 	R3,ENABLETIMER
				MOV 	M[TIMERCONTROL],R3 ; inicia contagem
				POP		R3
				RTI

;______________________________________________________________________________________________________
;_______________________________________ROTINA VALOR ALEATORIO:________________________________________

;Aleatorio - Rotina que gera um valor aleatorio	
;		Entradas: M[RANDOM] 
;		Saidas: ---
;		Efeitos: Altera valores das posicoes RANDOM e CRIAPOSICAO
Aleatorio:		PUSH	R1
				PUSH	R2
				MOV		R2, M[RANDOM]
				TEST 	R2, M[TESTABITS] ;testa o bit de menor peso de RANDOM
				BR.Z	AleatorioZero
				BR		AleatorioNZero
				
AleatorioZero:	MOV 	R1, M[RANDOM]
				ROR 	R1, TESTABITS
				MOV 	M[RANDOM], R1
				JMP		FimAleatorio
				
AleatorioNZero:	MOV 	R1, M[RANDOM]
				XOR 	R1, MASCARA
				ROR	 	R1, TESTABITS
				MOV		M[RANDOM], R1
				JMP		FimAleatorio

FimAleatorio:	MOV		R1, M[RANDOM]
				MOV 	R2, 20
				DIV		R1, R2
				ADD		R2, 2
				SHL		R2, 8
				ADD		R2, 004Eh			;faz com que seja escrito na ultima coluna em vez de na primeira
				MOV 	M[CRIAPOSICAO], R2
				POP		R2
				POP		R1
				RET

;______________________________________________________________________________________________________
;___________________________________ROTINAS DE ESCRITA EM ASCII:_______________________________________

;PontASCII - Rotina que escreve	a pontuacao final em funcao de carateres ASCII
;		Entradas: M[Un], M[Dez], M[Cent], M[Mil] 
;		Saidas: M[Un], M[Dez], M[Cent], M[Mil] 
;		Efeitos: Altera o valor de M[Un], M[Dez], M[Cent], M[Mil]
PontASCII:		PUSH	R1
				PUSH 	R2
				MOV 	R1, 0030
				MOV 	R2, 9
				CMP 	M[Un], R2
				BR.NZ	IncrementaUn
				CMP 	M[Dez], R2
				BR.NZ 	IncrementaDez
				CMP		M[Cent], R2
				BR.NZ 	IncrementaCent
				CMP 	M[Mil], R2
				BR.NZ 	IncrementaMil
PontASCIIFim:	POP 	R2
				POP 	R1
				RET

IncrementaUn:	INC M[Un]
				BR PontASCIIFim

IncrementaDez:	INC M[Dez]
				MOV	M[Un], R1
				BR PontASCIIFim
				
IncrementaCent:	INC M[Cent]
				MOV M[Dez], R1
				MOV M[Un], R1
				BR PontASCIIFim
				
IncrementaMil:	INC M[Mil]
				MOV M[Cent], R1
				MOV M[Dez], R1
				MOV M[Un], R1
				BR PontASCIIFim 			
;______________________________________________________________________________________________________
;_________________________________________ROTINAS DE DESENHO:__________________________________________

;ApagaCanhao: Rotina que apaga a nave.	
; 		Entradas: M[POS_CANHAO]
;		Saidas: ---
; 		Efeitos: ---			
ApagaCanhao:    MOV     R6,M[POS_CANHAO]
				MOV     M[IO_CTRL],R6
				MOV     R4,ESPACO
				MOV     M[IO_WRITE],R4
				DEC     R6
				MOV     M[IO_CTRL],R6
				MOV     M[IO_WRITE],R4
				SUB     R6,CAR1
				MOV     M[IO_CTRL],R6
				MOV 	M[IO_WRITE],R4
				ADD     R6,CAR2
				MOV     M[IO_CTRL],R6
				MOV 	M[IO_WRITE],R4
				RET	
				
;ApagaEcra: Rotina que apaga a janela de texto.
; 		Entradas: ---
;		Saidas: ---
; 		Efeitos: ---
ApagaEcra:		PUSH	R1
				PUSH	R2
				MOV		R1, R0
				MOV		R2, 1800h				
ApEcraCiclo:	PUSH	R1
				PUSH	ApagaStr
				CALL	EscStrLinha
				ADD		R1, 0100h
				CMP		R1, R2
				BR.NZ	ApEcraCiclo
				POP		R2
				POP		R1
				RET

;Border: Rotina que escreve no ecra o limite superior e o limite inferior
; 		Entradas: M[POS_INICIAL] e M[POS_INICIAL2]
;		Saidas: ---
; 		Efeitos: Escreve no ecra os limites do campo de jogo
Border:	PUSH 	POS_INICIAL
		PUSH 	LinhaCardinal
		CALL 	EscStrLinha
		PUSH 	POS_INICIAL2
		PUSH 	LinhaCardinal
		CALL 	EscStrLinha
		RET

;DesenhaCanhao: Rotina que escreve a nave em funcao da posicao do canhao.
; 		Entradas: M[POS_CANHAO] e M[CANHAO]
;		Saidas: ---
; 		Efeitos: Desenha cada carater da string CANHAO na posicao onde esta colocado o cursor. Essa posicao
;				 e controlada pela posicao do canha M[POS_CANHAO].			
DesenhaCanhao:  PUSH	R6
				PUSH	R5
				PUSH	R4
				MOV     R6,M[POS_CANHAO] 
				CALL	NaveContraAst	;Verifica se > vai colidir com um Asteroide
				CALL 	NaveContraBN	;Verifica se > vai colidir com um Buraco Negro
				MOV     M[IO_CTRL],R6   ;Colocar cursor na posicao do canhao
				MOV     R5,CANHAO 
				MOV     R4,M[R5]
				MOV     M[IO_WRITE],R4   
				INC		R5
				MOV     R4,M[R5]
				DEC     R6
				MOV     M[IO_CTRL],R6
				MOV     M[IO_WRITE],R4
				INC		R5
				MOV 	R4,M[R5]
				SUB     R6,CAR1
				CALL	NaveContraAst	;Verifica se \ vai colidir com um Asteroide
				CALL 	NaveContraBN	;Verifica se \ vai colidir com um Buraco Negro
				MOV     M[IO_CTRL],R6
				MOV 	M[IO_WRITE],R4
				INC		R5
				MOV 	R4,M[R5]
				ADD     R6,CAR2
				CALL	NaveContraAst	;Verifica se / vai colidir com um Asteroide
				CALL 	NaveContraBN	;Verifica se / vai colidir com um Buraco Negro
				MOV     M[IO_CTRL],R6
				MOV 	M[IO_WRITE],R4
				POP		R4
				POP		R5
				POP		R6
				RET
				
;NaveContraAst: Rotina que verifica se a nave chocou com um Asteroide.
; 		Entradas: ---
;		Saidas: ---
; 		Efeitos: Percorre todos os endereços de memoria associados a tabela de Asteroides e verifica se algum
; 				 dos asteroides guardados vai ocupar a mesma posicao que o elemento da nave. Caso ocupe chamamos
;				 a rotina Colidiu.
NaveContraAst:	PUSH	R1
				PUSH	R2
				MOV 	R1, TabAsteroides		;R1 = Slot em que estamos na TabAsteroides
				MOV		R2, 13
				ADD 	R2, R1 					;R2 = TabAsteroides+13 = Limite
				DEC 	R1
NaveCAstCiclo:	INC		R1			;Faz com que andemos para o slot seguinte da TabAsteroides
				CMP		R1, R2
				BR.Z	NaveCAstFim
				CMP 	M[R1], R6 	;Compara a posicao em que vamos escrever a nave com a posicao desse asteroide
				BR.Z 	Colidiu
				BR		NaveCAstCiclo			
NaveCAstFim:	POP 	R2
				POP		R1
				RET
							
;NaveContraBN: Rotina que verifica se a nave chocou com um Buraco Negro.
; 		Entradas: ---
;		Saidas: ---
; 		Efeitos: Percorre todos os endereços de memoria associados a tabela de Buracos Negros e verifica se algum
; 				 dos Buracos Negros guardados vai ocupar a mesma posicao que o elemento da nave. Caso ocupe chamamos
;				 a rotina Colidiu.
NaveContraBN:	PUSH	R1
				PUSH	R2
				MOV 	R1, TabBN		;R1 = Slot em que estamos na TabBN
				MOV		R2, 5
				ADD 	R2, R1 			;R2 = TabBN+5 = Limite
				DEC 	R1
NaveCBNCiclo:	INC		R1			;Faz com que andemos para o slot seguinte da TabAsteroides
				CMP		R1, R2
				BR.Z	NaveCBNFim
				CMP 	M[R1], R6 	;Compara a posicao em que vamos escrever a nave com a posicao desse asteroide
				BR.Z 	Colidiu
				BR		NaveCBNCiclo			
NaveCBNFim:		POP 	R2
				POP		R1
				RET			
				
;Colidiu: Esta rotina e chamada pela NaveContraAst e NaveContraBN quando a nave colide com um obstaculo.
; 		Entradas: ---
;		Saidas: ---
; 		Efeitos: Salta para o ecra de FimJogo.
Colidiu:		POP		R2
				POP		R1
				JMP		FimJogo			
;______________________________________________________________________________________________________
;_________________________________________ROTINAS DE ESCRITA:__________________________________________

;EscreveCar: Rotina que escreve um caracter na janela de texto.
; 		Entradas: Pilha - posicao do cursor e caracter a escrever
; 		Saidas: ---
; 		Efeitos: Coloca a posicao do cursor e o caracter a escrever nos
;                portos respetivos da janela de texto 
EscreveCar:		PUSH	R1
				MOV		R1, M[SP+4]
				MOV		M[IO_CTRL], R1		; Posiciona cursor na janela.
				MOV		R1, M[SP+3]	
				MOV		M[IO_WRITE], R1		; Escreve caracter recebido.
				POP		R1
				RETN	2				

;EscStrLinha: Rotina que escreve uma string numa linha da janela de texto.
; 		Entradas: Pilha - posicao do cursor e string a escrever
; 		Saidas: ---
; 		Efeitos: ---
EscStrLinha:	PUSH	R1
				PUSH	R2
				PUSH	R3
				MOV		R2, M[SP+5]		; O que se pretende escrever.
				MOV		R3, M[SP+6]		; Onde se pretende escrever.	
EscSLCiclo:		MOV		R1, M[R2]
				CMP		R1, FIM_TEXTO
				BR.Z	EscSLFim
				PUSH	R3
				PUSH	R1
				CALL	EscreveCar
				INC		R2
				INC		R3
				BR		EscSLCiclo
EscSLFim:		POP		R3
				POP		R2
				POP		R1
				RETN	2			
				
;MensagensIn: Rotina que escreve as mensagens iniciais
; 		Entradas: --- 
;		Saidas: ---	
; 		Efeitos: ---
MensagensIn:	PUSH	PrepPos			; Escreve na posicao 0b22h
				PUSH	Prep			; 'Prepare-se',
				CALL	EscStrLinha		
				PUSH	PrimaBotaoPos 	; Escreve na posicao 0d1Fh
				PUSH	PrimaBotao		;'Prima o botao IE'
				CALL	EscStrLinha		
				RET
				
;MensagensFim: Rotina que escreve as mensagens finais
; 		Entradas: --- 
;		Saidas: ---
; 		Efeitos: ---
MensagensFim:	PUSH 	R1
				PUSH 	R2
				PUSH	FimJogoPos		 ; Escreve na posicao 0b21h
				PUSH	FimJogoMsg		 ; 'Fim do Jogo'
				CALL	EscStrLinha	
				
				MOV 	R1, PontFinalPos
				MOV 	R2, M[Mil]
				MOV     M[IO_CTRL], R1	
				MOV     M[IO_WRITE], R2	  ;Escreve o algarismo dos milhares
				INC 	R1
				MOV 	R2, M[Cent]
				MOV     M[IO_CTRL], R1
				MOV     M[IO_WRITE], R2   ;Escreve o algarismo das centenas
				INC 	R1
				MOV 	R2, M[Dez]				
				MOV     M[IO_CTRL], R1
				MOV     M[IO_WRITE], R2   ;Escreve o algarismo das dezenas
				INC 	R1
				MOV 	R2,	M[Un]
				MOV     M[IO_CTRL], R1
				MOV     M[IO_WRITE], R2   ;Escreve o algarismo das unidades
				
				POP		R2
				POP 	R1
				RET
;______________________________________________________________________________________________________
;___________________________________________ROTINAS DE LCD:____________________________________________
;Coordenadas: Rotina que desenha as coordenadas do canhao da nave na primeira linha do LCD. Esta rotina vai
;			  ser chamada sempre que uma das rotinas de movimentacao da nave for chamada.
; 		Entradas: M[POS_CANHAO]
;		Saidas: ---
; 		Efeitos: desenha as coordenadas do canhao na primeira linha do LCD.
Coordenadas:	PUSH R2
				PUSH R3
				PUSH R4
				PUSH R5
				MOV R2, M[POS_CANHAO]
				MOV R3, R0
				MVBH R3, R2            ; R3 - XX00
				SHR R3, 8
				AND R2, 00FFh		   ;Elimina os 8 bits mais significativos, ficando com as colunas 
				MOV R4, 8000h
				MOV M[CURSOR_CORD], R4
				MOV R5, 000Ah
				DIV R3, R5
				ADD R3, 0030h
				MOV M[ESCREVER_CORD], R3
				INC R4
				MOV M[CURSOR_CORD], R4
				ADD R5, 0030h
				MOV M[ESCREVER_CORD], R5
				INC R4
				INC R4
				MOV R5, 000Ah
				MOV M[CURSOR_CORD], R4
				DIV R2, R5
				ADD R2, 0030h
				MOV M[ESCREVER_CORD], R2
				INC R4
				MOV M[CURSOR_CORD], R4
				ADD R5, 0030h
				MOV M[ESCREVER_CORD], R5
				POP R5
				POP R4
				POP R3
				POP R2
				RET

;______________________________________________________________________________________________________
;________________________________________ROTINAS DE MOVIMENTO:_________________________________________

;MovBaixo: Rotina que trata do movimento da nave para baixo.
;		Entradas: M[POS_CANHAO]
;		Saidas: M[POS_CANHAO], M[Down]
;		Efeitos: Se puder, apaga a nave e escreve-a uma posicao abaixo
MovBaixo:		PUSH	R2
				PUSH	R1
				MOV     R2,M[POS_CANHAO]
                SHR     R2,8
				CMP     R2,LIMINF
				Br.Z	FimMovBaixo    
                CALL    ApagaCanhao
                MOV     R1,M[POS_CANHAO]
				ADD     R1,MOVI
				MOV     M[POS_CANHAO],R1
				CALL 	Coordenadas
				CALL 	DesenhaCanhao
FimMovBaixo:	MOV     M[Down],R0
				POP		R1
				POP		R2
				RET     
				
;MovCima: Rotina que trata do movimento da nave para cima.
;		Entradas: M[POS_CANHAO]
;		Saidas: M[POS_CANHAO], M[Up]
;		Efeitos: Se puder, apaga a nave e escreve-a uma posicao a cima			
MovCima:		PUSH	R2
				PUSH	R1
				MOV     R2,M[POS_CANHAO]
                SHR     R2,8
				CMP     R2,LIMSUP
				Br.Z	FimMovCima    
                CALL    ApagaCanhao
                MOV     R1,M[POS_CANHAO]
				SUB     R1,MOVI
				MOV     M[POS_CANHAO],R1
				CALL 	Coordenadas
				CALL 	DesenhaCanhao
FimMovCima:	    MOV     M[Up],R0
				POP		R1
				POP		R2
				RET     
				
;MovDireita: Rotina que trata do movimento do canhao para a direita.
;		Entradas: M[POS_CANHAO]
;		Saidas: M[POS_CANHAO], M[Right]
;		Efeitos: Se puder, apaga a nave e escreve-a uma casa a direita				
MovDireita:     PUSH	R2
				PUSH	R1
				MOV     R2,M[POS_CANHAO]
                SHL     R2,8
				CMP     R2,LIMD
				Br.Z	FimMovDireita
				CALL    ApagaCanhao
                MOV     R1,M[POS_CANHAO]
				INC     R1
				MOV     M[POS_CANHAO],R1
				CALL 	Coordenadas
				CALL 	DesenhaCanhao
FimMovDireita:  MOV     M[Right],R0
				POP		R1
				POP		R2
				RET    
				
;MovEsquerda: Rotina que trata do movimento da nave para a esquerda.
;		Entradas: M[POS_CANHAO]
;		Saidas: M[POS_CANHAO], M[Left]
;		Efeitos: Se puder, apaga a nave e escreve-a uma casa a esquerda				
MovEsquerda:    PUSH	R2
				PUSH	R1
				MOV     R2,M[POS_CANHAO]
                SHL     R2,8
				CMP     R2,LIME
				Br.Z	FimMovEsquerda
				CALL    ApagaCanhao
                MOV     R1,M[POS_CANHAO]
				DEC     R1
				MOV     M[POS_CANHAO],R1
				CALL 	Coordenadas
				CALL 	DesenhaCanhao
FimMovEsquerda:	MOV     M[Left],R0
				POP		R1
				POP		R2
				RET  
				
;______________________________________________________________________________________________________
;________________________________________ROTINA QND TIMERFLAG = 1:_____________________________________
;TimerFlagA1: Rotina efetuada quando a TimerFlag = 1.
;		Entradas: --- 
;		Saidas: ---
;		Efeitos: ---	

TimerFlagA1: 	CMP 	M[FlagHaLEDS], R0
				BR.Z 	SaltaLEDS
				DEC 	M[FlagHaLEDS]
				CMP 	M[FlagHaLEDS], R0
				BR.NZ  	SaltaLEDS
				MOV 	M[LEDS], R0
SaltaLEDS:		CALL	MoveTiro
				DEC		M[FlagMoveObst]  ;Sempre que o timer faz 1 ciclo, vai decrementar FlagMoveObst
				DEC		M[QuandoEscreve]  ;Sempre que o timer faz 1 ciclo, vai decrementar QuandoEscreve
				MOV		M[TimerFlag], R0
				RET

;______________________________________________________________________________________________________
;_________________________________________ROTINAS DE TIRO:_____________________________________________
;TiroInicial: Rotina efetuada quando FlagExisteTiro = 0
;		Entradas: --- 
;		Saidas: M[POS_TIRO], M[FlagTiro]
;		Efeitos: Escreve o primeiro tiro, quando nao ha mais tiros na tela e I4 e premido. Apos escrever vai 
; 				 colocar a FlagTiro = 0 e a FlagExisteTiro = 1.
TiroInicial:	PUSH	R1
				PUSH 	R2
				CMP		M[FlagExisteTiro], R0		;rotina so e efetuada quando FlagExisteTiro = 0
				BR.NZ	TiroInicialFim
				MOV		R1, M[POS_CANHAO]
				INC 	R1
				PUSH 	R1
				PUSH	TRACO
				CALL 	EscStrLinha
				MOV		M[FlagTiro], R0
				MOV		M[POS_TIRO], R1
				INC     M[FlagExisteTiro]    		;quando TiroInicial e escrito FlagExisteTiro = 1
TiroInicialFim:	POP		R2
				POP		R1
				RET

;MoveTiro: Rotina efetuada quando FlagExisteTiro = 1
;		Entradas: --- 
;		Saidas: M[POS_TIRO], M[TimerFlag] e M[FlagTiroColAst]
;		Efeitos: Movimenta o tiro pelo ecra comparando a posicao incrementada do tiro com o limite direito e com
; 				 os obstaculos.
MoveTiro:		PUSH	R2
				PUSH	R3
				CMP		M[FlagExisteTiro],R0		;rotina so e efetuada quando FlagExisteTiro = 1
				BR.Z	FimMoveTiro
				CALL 	ApagaTiro	
				MOV		R2, M[POS_TIRO]
				INC		R2	
				MOV 	R3, R2
				SHL 	R2,8	
				CMP 	R2, LIMD				
				CALL.Z	AtivaExisteTiro
				CMP 	R2, LIMD				
				BR.Z	FimMoveTiro
				MOV 	M[POS_TIRO], R3
				CALL 	ColTiroAst
				CMP 	M[FlagTiroColAst], R0 ; Tiro so e escrito se n houve colisao M[FlagTiroColAst] = 0
				CALL.Z 	EscreveTiro			
FimMoveTiro:	MOV		M[TimerFlag], R0
				MOV 	M[FlagTiroColAst], R0
				POP		R3
				POP		R2
				RET

;ApagaTiro:
;		Entradas: M[POS_TIRO] 
;		Saidas: ---
;		Efeitos: Apaga o tiro da sua posicao atual	no ecra		
ApagaTiro: 		PUSH 	M[POS_TIRO]
				PUSH 	SPACE
				CALL	EscStrLinha
				RET
	
;EscreveTiro:
;		Entradas: M[POS_TIRO] 
;		Saidas: ---
;		Efeitos: Escreve o tiro na sua nova posicao no ecra	(posicao antiga incrementada)
EscreveTiro:	PUSH 	M[POS_TIRO] ;ja vai estar atualizada
				PUSH 	TRACO
				CALL	EscStrLinha
				RET

;AtivaExisteTiro:
;		Entradas: ---
;		Saidas: M[FlagExisteTiro], M[FlagTiro]
;		Efeitos: Vai colocar a FlagExisteTiro = 0 e a FlagTiro = 0
AtivaExisteTiro:MOV		M[FlagExisteTiro],R0
				MOV 	M[FlagTiro], R0
				RET	
;______________________________________________________________________________________________________
;__________________________ROTINAS DE ASTEROIDES E BURACOS NEGROS:_____________________________________

;SelectAstBN: Rotina que seleciona se vai ser escrito um Asteroide ou um BN
;		Entradas: ---
;		Saidas: M[QuandoEscreve], M[NumeroDeAst]
;		Efeitos: ---
SelectAstBN:	PUSH	R1							
				PUSH	R2
				MOV		R2, 12
				MOV  	M[QuandoEscreve], R2
				MOV  	R1, 3
				CMP		M[NumeroDeAst], R1	
				BR.Z	BNInicial			              ;NumeroDeAst = 3 -> BNInicial				
;AstInicial: SubRotina que escreve um Asteroide (inicial)
AstInicial:		POP		R2
				POP		R1
				INC		M[NumeroDeAst]
				CALL	Aleatorio
				CALL	GuardaPosAst
				PUSH	M[CRIAPOSICAO]
				PUSH	ASTEROIDES
				CALL	EscStrLinha				
				RET
;BNInicial: SubRotina que escreve um BN (inicial)				
BNInicial:		POP		R2
				POP		R1
				MOV 	M[NumeroDeAst], R0
				CALL	Aleatorio
				CALL	GuardaPosBN							
				PUSH	M[CRIAPOSICAO]
				PUSH	BURACONEGRO
				CALL	EscStrLinha							
				RET			
			
;GuardaPosAst: Rotina que guarda a posicao dos Asteroides na TabAsteroides.
;		Entradas: M[CRIAPOSICAO]
;		Saidas: ---
;		Efeitos: ---
GuardaPosAst:	PUSH	R1
				PUSH	R2
				PUSH	R3
				MOV 	R2, M[CRIAPOSICAO]
				MOV		R1, TabAsteroides ;R1 vai ser usada para percorrer a TAB
				MOV		R3, R1
				ADD		R3, 13 ; R3 = TabAsteroides+13
				DEC		R1
PercorreTabela: INC		R1
				CMP		R1, R3
				BR.Z	FimCicloPT
				CMP		M[R1],R0  ;Procura um espaco de memoria vazio para preencher com a posicao do Asteroide
				BR.NZ	PercorreTabela	
				MOV 	M[R1], R2					
FimCicloPT:		POP		R3
				POP		R2
				POP		R1
				RET	
						
;GuardaPosBN: Rotina que guarda a posicao dos Buracos Negros na TabBN.
;		Entradas: M[CRIAPOSICAO]
;		Saidas: ---
;		Efeitos: ---
GuardaPosBN:	PUSH	R1
				PUSH	R2
				PUSH	R3
				MOV 	R2, M[CRIAPOSICAO]
				MOV		R1, TabBN ;R1 vai ser usada para percorrer a TAB
				MOV		R3, R1
				ADD		R3, 5
				DEC		R1
PercorreTabela2:INC		R1
				CMP		R1, R3
				BR.Z	FimCicloPT2
				CMP		M[R1],R0  ;Procura um espaco de memoria vazio para preencher com a posicao do BN
				BR.NZ	PercorreTabela2	
				MOV 	M[R1], R2					
FimCicloPT2:	POP		R3
				POP		R2
				POP		R1
				RET	

;MoveObstaculos: Rotina que invoca duas rotinas que irao mover Asteroides e Buracos Negros
;		Entradas: ---
;		Saidas: M[FlagMoveObst]
;		Efeitos: Move os obstaculos			
MoveObstaculos:	PUSH	R7
				MOV 	R7, 2
				MOV		M[FlagMoveObst], R7	;Quando efetuamos a rotina voltamos a meter FlagMoveObst = 2
				CALL	MoveAst
				CALL	MoveBN			
MoveObstFim:	POP		R7
				RET
							
;MoveAst: Rotina responsavel pela movimentacao dos asteroides. E chamada pela MoveObstaculos
;		Entradas: ---
;		Saidas: ---
;		Efeitos: ---
MoveAst: 		PUSH	R1
				PUSH	R2
				PUSH	R3
				PUSH	R4
				MOV 	R1, TabAsteroides		;R1 = Slot em que estamos na TabAsteroides
				MOV		R2, 13
				ADD 	R2, R1 					;R2 = TabAsteroides+13 = Limite
				DEC 	R1
MoveAstCiclo:	INC		R1		;Faz com que andemos para o slot seguinte da TabAsteroides
				CMP		R1, R2
				BR.Z	MoveAstFim
				CMP		M[R1], R0
				BR.Z	MoveAstCiclo ;Se o slot estiver vazio, analisamos o proximo slot
				PUSH	M[R1]   ;Posicao a apagar
				PUSH	SPACE
				CALL	EscStrLinha	
				MOV 	R3, M[R1]
				SHL 	R3, 8
				CMP		R3, R0
				BR.Z	MoveAstLimite
				MOV		R4, M[R1]
				DEC		R4
				MOV  	M[R1], R4
				CALL	ColObstNave
				PUSH	R4   ;Posicao a escrever 
				PUSH	ASTEROIDES
				CALL	EscStrLinha
				BR		MoveAstCiclo		
				CMP		R1, R2	;Verifica se atingiu o LIME
MoveAstFim:		POP		R4
				POP		R3
				POP		R2
				POP		R1
				RET
				
MoveAstLimite:	MOV 	M[R1], R0
				JMP		MoveAstCiclo

				
;MoveBN: Rotina responsavel pela movimentacao dos buracos negros. E chamada pela MoveObstaculos
;		Entradas: ---
;		Saidas: ---
;		Efeitos: ---
MoveBN: 		PUSH	R1
				PUSH	R2
				PUSH	R3
				PUSH	R4
				MOV 	R1, TabBN		;R1 = Slot em que estamos na TabBN
				MOV		R2, 5
				ADD 	R2, R1 					;R2 = TabBN+5 = Limite
				DEC 	R1
MoveBNCiclo:	INC		R1		;Faz com que andemos para o slot seguinte da TabBN
				CMP		R1, R2
				BR.Z	MoveBNFim
				CMP		M[R1], R0
				BR.Z	MoveBNCiclo ;Se o slot estiver vazio, analisamos o proximo slot
				PUSH	M[R1]   ;Posicao a apagar
				PUSH	SPACE
				CALL	EscStrLinha	
				MOV 	R3, M[R1]
				SHL 	R3, 8
				CMP		R3, R0
				BR.Z	MoveBNLimite
				MOV		R4, M[R1]
				DEC		R4
				MOV  	M[R1], R4
				CALL	ColObstNave
				PUSH	R4   ;Posicao a escrever 
				PUSH	BURACONEGRO
				CALL	EscStrLinha
				BR		MoveBNCiclo		
				CMP		R1, R2	;Verifica se atingiu o LIME
MoveBNFim:		POP		R4
				POP		R3
				POP		R2
				POP		R1
				RET		
				
MoveBNLimite:	MOV 	M[R1], R0
				JMP		MoveBNCiclo

;______________________________________________________________________________________________________
;_______________________________________ROTINAS DE COLISÕES:___________________________________________

;ColObstNave: Quando obstaculo colide com a nave, termina o jogo
;		Entradas: M[POS_CANHAO]
;		Saidas: ---
;		Efeitos: E chamada a tela final do jogo
ColObstNave:	PUSH	R5
				CMP		R4, M[POS_CANHAO] ;R4 = posicao do Obst
				JMP.Z	FimColObstNave
				MOV		R5, M[POS_CANHAO]
				SUB		R5, 0101h 		  ;R5 = posicao superior da nave (\)
				CMP		R4,	R5
				JMP.Z	FimColObstNave
				ADD		R5,	0200h		  ;R5 = posicao inferior da nave (/)
				CMP		R4, R5
				JMP.Z	FimColObstNave
				POP		R5
				RET
FimColObstNave:	POP 	R5
				JMP		FimJogo
				RET

;ColTiroAst: Quando um Ast colide com o tiro, apagamos o tiro, o asteroide e incrementamos a pontuacao.
;		Entradas: M[POS_TIRO]
;		Saidas: ---
;		Efeitos: ---
ColTiroAst:		PUSH	R1
				PUSH	R2
				PUSH	R5
				MOV 	R1, TabAsteroides
				MOV 	R2, R1
				ADD		R2, 13
				DEC 	R1
ColTiroAstCiclo:INC		R1
				MOV 	R5, M[POS_TIRO]
				CMP		R5, M[R1]
				BR.Z 	ColidiuAstTiro
				INC		R5
				CMP		R5, M[R1]
				BR.Z 	ColidiuAstTiro
				INC  	R5
				CMP		R5, M[R1]
				BR.Z 	ColidiuAstTiro
				INC  	R5
				CMP		R5, M[R1]
				BR.Z 	ColidiuAstTiro
				SUB  	R5, 3
				CMP		R5, M[R1]
				BR.Z 	ColidiuAstTiro
				DEC		R5
				CMP		R5, M[R1]
				BR.Z 	ColidiuAstTiro
				DEC		R5
				CMP		R5, M[R1]
				BR.Z 	ColidiuAstTiro
				DEC		R5
				CMP		R5, M[R1]
				BR.Z 	ColidiuAstTiro				
				CMP 	R1, R2
				BR.NZ 	ColTiroAstCiclo
ColTiroAstFim:	POP 	R5
				POP 	R2
				POP 	R1
				RET
				
;ColidiuAstTiro: Existe uma colisao entre o Asteroide e o Tiro
;		Entradas: ---
;		Saidas: ---
;		Efeitos: Atualiza a pontuacao em ASCII, liga os LEDS, atualiza a FlagHaLEDS = 2,
;				 atualiza FlagExisteTiro = 0, atualiza FlagTiroColAst = 0, incrementa a pontuacao ecra
;				 atualiza o display de 7 segementos.
ColidiuAstTiro:	PUSH 	R7
				PUSH 	R4
				PUSH 	R6
				CALL 	PontASCII
				MOV 	R4, FFFFh
				MOV 	M[LEDS], R4
				MOV 	R6, 2
				MOV 	M[FlagHaLEDS], R6
				MOV 	M[FlagExisteTiro], R0
				MOV 	R7, 1
				MOV 	M[FlagTiroColAst], R7
				INC 	M[Pontuacao]
				CALL    Atualiza_7Segm
				PUSH 	M[R1]
				PUSH 	SPACE
				CALL 	EscStrLinha
				MOV 	M[R1], R0
				POP 	R6
				POP 	R4
				POP		R7
				POP		R5
				POP 	R2
				POP 	R1
				RET		

;Atualiza_7Segm: Atualiza o display de 7 segmentos com a pontucao atual.				
;		Entradas: M[Pontuacao]
;		Saidas: ---
;		Efeitos: M[DISP0], M[DISP1], M[DISP2], M[DISP3]	
Atualiza_7Segm:	PUSH 	R1
				PUSH 	R3
				MOV     R1,M[Pontuacao]
				MOV 	R3, 10
				DIV 	R1, R3
				MOV 	M[DISP0], R3
				MOV 	R3, 10
				DIV 	R1, R3
				MOV 	M[DISP1], R3
				MOV 	R3, 10
				DIV 	R1, R3
				MOV 	M[DISP2], R3
				MOV 	R3, 10
				DIV 	R1, R3
				MOV 	M[DISP3], R3
				POP 	R3
				POP 	R1
				RET
;______________________________________________________________________________________________________
;________________________________________PROGRAMA PRINCIPAL:___________________________________________

;Inicio: Inicializa a pilha, o porto de controlo da janela de texto e a mascara de interrupcoes.
;		Entradas: ---
;		Saidas: M[IO_CTRL], M[INTMASK] e M[IO_CTRL]
;		Efeitos: ---		
Inicio:        	MOV     R7, TOPO_PILHA
                MOV     SP, R7
                MOV     R6, FFFFh
                MOV     M[IO_CTRL],R6
				MOV     R1,INTMASKMOV1
				MOV     M[INTMASK],R1
				ENI 
				
;EsperaJogo: 
;		Entradas: ---
;		Saidas: ---
;		Efeitos: Rotina escreve mensagens iniciais e e efetuada em loop enquanto esperamos que o utilizador prima
; 				 o botao IE. Apos este ser premido apagamos o ecra, desenhamos as borders e o canhao. Inicializamos
; 				 o temporizador e a mascara de interrupcoes.
EsperaJogo:		CALL 	MensagensIn
				INC		M[RANDOM]
				CMP		M[IE], R0
				Br.Z	EsperaJogo
				CALL	ApagaEcra
				CALL 	Border
				CALL 	DesenhaCanhao
				PUSH	R5
				MOV 	R5,TIMELONG
				MOV 	M[TIMERVALUE],R5 ; definir valor de contagem do timer
				MOV 	R5,ENABLETIMER
				MOV 	M[TIMERCONTROL],R5 ; inicia contagem
				MOV     R1,INTMASKMOV
				MOV     M[INTMASK],R1
				POP		R3
;Ciclo: Ciclo principal do jogo
;		Entradas: ---
;		Saidas: ---
;		Efeitos: Esta rotina vai efetuar em loop a verificacao das flags.
Ciclo:			PUSH	R1
				CMP     M[Down],R0
				CALL.NZ MovBaixo
				CMP		M[Up],R0
				CALL.NZ MovCima
				CMP		M[Right],R0
				CALL.NZ MovDireita
				CMP		M[Left],R0
				CALL.NZ MovEsquerda
				CMP		M[FlagTiro], R0  ;Quando clicamos no I4 e chamada a rotina TiroInicial
				CALL.NZ	TiroInicial
				CMP		M[TimerFlag], R0 ;Quando o Timer chega a 0, TimerFlag fica a 1
				CALL.NZ	TimerFlagA1
				CMP		M[FlagMoveObst], R0 
				CALL.Z 	MoveObstaculos
				CMP 	M[QuandoEscreve], R0 ;Quando QuandoEscreve = 0, e escrito um Ast ou BN no ecra
				CALL.Z	SelectAstBN
				POP		R1
				JMP		Ciclo
				
;FimJogo: Rotina que efetua a escrita das mensagens finais e reinicia o jogo.
;		Entradas: ---
;		Saidas: ---
;		Efeitos: escrever mensagens finais e reiniciar o jogo				
FimJogo:		MOV 	M[FlagReinicio], R0
				CALL 	Inicializa2
				MOV     R1,INTMASKFIM	
				MOV     M[INTMASK],R1
				CALL	ApagaEcra		;Rotina que apaga o ecra
				CALL 	MensagensFim	;NOTA: Ainda temos de meter a pontuacao
FimJogoEspera:	CMP		M[FlagReinicio], R0
				BR.Z    FimJogoEspera
				JMP		Inicio

;Inicializa2: Apos jogo ser reiniciado esta rotina vai voltar a inicializar as variaveis.
;		Entradas: ---
;		Saidas: ---
;		Efeitos: Reiniciailiza as variaveis.
Inicializa2:	PUSH 	R1
				MOV 	R1, M[POSI_CANHAO]
				MOV 	M[POS_CANHAO], R1
				MOV 	M[POS_TIRO], R0
				MOV 	M[NumeroDeAst], R0
				MOV 	R1, 12
				MOV 	M[QuandoEscreve], R1
				MOV 	M[FlagTiroColAst], R0
				MOV 	M[FlagExisteTiro], R0
				MOV 	M[TimerFlag], R0
				MOV		M[Left], R0
				MOV 	M[Right], R0
				MOV 	M[Up], R0
				MOV 	M[Down], R0
				MOV 	M[IE], R0
				MOV 	R1, 2828h
				MOV 	M[RANDOM], R1
				MOV 	M[CRIAPOSICAO], R0
				MOV 	M[FlagTiro], R0
				MOV 	M[Aster], R0
				MOV 	M[PosTiroInicial], R0
				MOV 	R1, 2
				MOV 	M[FlagMoveObst], R1
				MOV		M[Pontuacao], R0
				MOV		M[FlagHaLEDS], R0
				POP 	R1
				RET
               