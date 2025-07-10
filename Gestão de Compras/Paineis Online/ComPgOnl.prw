#INCLUDE "protheus.ch"
#INCLUDE "PanelOnLine.ch"
#INCLUDE "ComPgOnl.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ COMPGOnl ³ Autor ³Alexandre Inacio Lemes ³ Data ³23/01/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Painel de Gestao On-line (SIGACOM)                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ COMPGOnl(ExpO1)                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpO1 = obj do proces.                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGACOM                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function ComPGOnl(oPGOnline)

Local aToolBar:= {}
Local cHelp   := ""

PANELONLINE oPGOnline ADDPANEL ;
	TITLE STR0001 ; //"Saldo de Alçadas"
	DESCR STR0002 ; //"Saldo Disponivel para Aprovação de processos (Valores Convertidos)"
	TYPE 1 ;
	ONLOAD "ComPgOnl01" ;
	REFRESH 100 ;
	NAME "1" 

PANELONLINE oPGOnline ADDPANEL ;
	TITLE STR0003 ; //"Alçadas com Saldo"
	DESCR STR0004 ; //"Aprovadores com Saldo Disponível para Aprovação"
	TYPE 5 ;
	ONLOAD "ComPgOnl02" ;
	REFRESH 200 ;
	NAME "2" 

PANELONLINE oPGOnline ADDPANEL ;
	TITLE STR0005 ; //"Alçadas sem Saldo"
	DESCR STR0006 ; //"Aprovadores sem Saldo Disponível para Aprovação"
	TYPE 5 ;
	ONLOAD "ComPgOnl03" ;
	REFRESH 300 ;
	NAME "3" 

cHelp := STR0017 //"Para chegar ao Indice Total de Eficiencia o sistema pesquisa os ultimos  "
cHelp += STR0018 //"90 dias somente das entregas que foram originadas do processo de cotacao. "
cHelp += STR0019 //"Formula do Indice Eficiencia =((Indice A * Peso A) + (Indice B * Peso B) + (Indice C * Peso C)) / 10 "
cHelp += STR0020 //"Indice A = Percentual de vezes que o Vencedor escolhido da cotacao e o que tem o melhor preco "
cHelp += STR0021 //"Indice B = Percentual de vezes que o Vencedor escolhido da cotacao e o que tem o menor prazo de entrega "
cHelp += STR0022 //"Indice C = Percentual de vezes em que a entrega do material (Documento de Entrada) ocorre dentro da data Prevista no Pedido de Compras. "
cHelp += STR0023 //"Definicao dos Pesos Utilizados na Formula : "
cHelp += STR0024 //"Peso A = 5  Peso B = 3  Peso C = 2 "
cHelp += STR0025 //"O Peso B sofre um desconto percentual em relacao ao total de entregas "
cHelp += STR0026 //"analisadas toda vez que na cotacao do material analisado a data de "
cHelp += STR0027 //"entrega nao foi informada ou o pedido foi gerado a partir da data da "
cHelp += STR0028 //"necessidade do material. Quando esse desconto e realizado o mesmo e adicionado ao Peso C. "
cHelp += STR0029 //"Exemplo :"
cHelp += STR0030 //"Em 90 dias foram analisadas 1000 Entregas onde 250 foram originadas de "
cHelp += STR0031 //"cotacoes por data de necessidade ou sem data de entrega informada. Os Pesos "
cHelp += STR0032 //"B e C seriam : "
cHelp += STR0033 //"PesoB = ( ( 1000 - 250 ) / 1000 ) * 3 que resulta em 2.25 "
cHelp += STR0034 //"PesoC = a Diferenca de 3 - 2.25 = 0.75  somada ao Indice C 2 que Resulta em 2.75"

aToolBar  := {}
Aadd( aToolBar, { "S4WB016N","Help",&('{ || MsgInfo(Lower("'+cHelp+'")) }') } )

PANELONLINE oPGOnline ADDPANEL ;
	TITLE STR0015 ; // "Eficiência de Compras" 
	DESCR STR0016 ; //"Indice de Eficiência de Compras"
	TYPE 3 ;
	ONLOAD "ComPgOnl10" ;
	REFRESH 1000;
	TOOLBAR aToolBar ;
	NAME "10" ;
	PYME

PANELONLINE oPGOnline ADDPANEL ;
	TITLE STR0007 ; //"Solicitações de Compras em Aberto"
	DESCR STR0007 ; //"Solicitações de Compras em Aberto"
	TYPE 2 ;
	PARAMETERS "COMPGONL04";
	ONLOAD "ComPgOnl04";
	REFRESH 400 ;        	
	DEFAULT 2 ;
	NAME "4" ;  
    TITLECOMBO STR0008 ;//"Status"
    PYME
 
PANELONLINE oPGOnline ADDPANEL ;
	TITLE STR0009 ; //"Pedidos de Compras em Aberto"
	DESCR STR0009 ; //"Pedidos de Compras em Aberto"
	TYPE 2 ;
	PARAMETERS "COMPGONL05";
	ONLOAD "ComPgOnl05";
	REFRESH 500 ;        	
	DEFAULT 2 ;
	NAME "5" ; 
    TITLECOMBO STR0008 ;//"Status"
    PYME

PANELONLINE oPGOnline ADDPANEL ;
	TITLE STR0010 ; //"Autorizações de Entrega em Aberto"
	DESCR STR0010 ; //"Autorizações de Entrega em Aberto"
	TYPE 2 ;
	PARAMETERS "COMPGONL06";
	ONLOAD "ComPgOnl06";
	REFRESH 600 ;
	DEFAULT 2 ;
	NAME "6" ; 
    TITLECOMBO STR0008 //"Status"
  
PANELONLINE oPGOnline ADDPANEL ;
	TITLE STR0011 ; //"Contratos de Parceria em Aberto"
	DESCR STR0011 ; //"Contratos de Parceria em Aberto"
	TYPE 2 ;
	PARAMETERS "COMPGONL07";
	ONLOAD "ComPgOnl07";
	REFRESH 700 ;
	DEFAULT 2 ;
	NAME "7" ; 
    TITLECOMBO STR0008 //"Status"

PANELONLINE oPGOnline ADDPANEL ;
	TITLE STR0012 ; //"Cotações em Aberto"
	DESCR STR0012 ; //"Cotações em Aberto"
	TYPE 2 ;
	PARAMETERS "COMPGONL08";
	ONLOAD "ComPgOnl08";
	REFRESH 800 ;
	DEFAULT 2 ;
	NAME "8" ; 
    TITLECOMBO STR0008 ;//"Status"
    PYME
               
If cPaisLoc == "EQU"
	PANELONLINE oPGOnline ADDPANEL ;
		TITLE STR0035 ; // "RCN sem NF"
		DESCR STR0036 ; // "Guia de Recepção sem Factura de Entrada"
		TYPE 5 ;
		PARAMETERS "MTREQ1";
		ONLOAD "ComPgOnl11";
		REFRESH 800 ;  
		DEFAULT 1 ;
		NAME "11" ; 
	    PYME    
	
	PANELONLINE oPGOnline ADDPANEL ;
		TITLE STR0037 ; // "RCD sem NCP"
		DESCR STR0038 ; // "Dev. Guia Recepção sem Nota Cred."
		TYPE 5 ;
		PARAMETERS "MTREQ2";
		ONLOAD "ComPgOnl12";
		REFRESH 800 ;  
		DEFAULT 1 ;
		NAME "12" ; 
	    PYME
EndIf

Return
