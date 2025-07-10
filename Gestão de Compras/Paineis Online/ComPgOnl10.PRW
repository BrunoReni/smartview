#INCLUDE "Protheus.ch"
#INCLUDE "ComPgOnl10.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ComPgOnl10³ Autor ³Alexandre Inacio Lemes ³ Data ³ 13/03/2007 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Monta array para Painel de Gestao Tipo 3:                     ³±±
±±³          ³Indice de Eficiencia do Processo de Compras                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Array = {{cText1,cValor,nColorValor,bClick},...}             ³±±
±±³          ³ cTexto1     = Texto da Coluna                       		    ³±±
±±³          ³ cValor      = Valor a ser exibido (string)          		    ³±±
±±³          ³ nColorValor = Cor do valor no formato RGB (opcional)         ³±±
±±³          ³ bClick      = Funcao executada no click do valor (opcional)  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGACOM                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/        
Function ComPgOnl10()

Local aPanel    := {}

Local cAliasSD1 := "SD1"
Local cIndSD1   := ""
Local cHelp     := ""

Local nPrazoBase:= 0
Local nPrecoBase:= 0
Local nIndiceA  := 0
Local nIndiceB  := 0
Local nIndiceC  := 0
Local nDescIndA := 0
Local nDescIndB := 0
Local nDescIndC := 0
Local nPesoA    := 0
Local nPesoB    := 0
Local nPesoC    := 0
Local nSemPrazo := 0
Local nTotEfcz  := 0
Local nEficaz   := 0

Local lPreco    := .T.
Local lPrazo    := .T.
Local lNeces    := .T.       
Local lQuery    := .F.

dbSelectArea("SC7")  
dbSetOrder(14)

dbSelectArea("SC8")  
dbSetOrder(3)

dbSelectArea("SD1") 
dbSetOrder(1)

lQuery    := .T.
cAliasSD1 := GetNextAlias()	

BeginSql Alias cAliasSD1

SELECT SD1.D1_FILIAL,SD1.D1_DOC,SD1.D1_SERIE,SD1.D1_EMISSAO,SD1.D1_DTDIGIT,SD1.D1_FORNECE,SD1.D1_LOJA,
       SD1.D1_PEDIDO,SD1.D1_ITEMPC,SD1.D1_ITEM,SD1.D1_COD,SD1.D1_QUANT,SD1.D1_VUNIT,SD1.D1_TOTAL,SD1.R_E_C_N_O_ SD1RecNo 

FROM %table:SD1% SD1

WHERE SD1.D1_FILIAL = %xFilial:SD1%  
    AND SD1.D1_DTDIGIT >= %Exp:DtoS(dDataBase - 90)% 
    AND SD1.D1_DTDIGIT <= %Exp:DtoS(dDataBase)%
    AND SD1.D1_PEDIDO <> ' '
AND SD1.%NotDel% 
		  
ORDER BY %Order:SD1% 
		
EndSql 

nTotEfcz  := 0
nDescIndA := 0
nDescIndB := 0
nDescIndC := 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Serao avaliados apenas os itens entregue que tenham passado pelo processo    ³
//³ completo de Compras composto por  SC - Cotacao - Pedido de Compras - NFE.    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea(cAliasSD1)
While ( !(cAliasSD1)->(Eof()) .And. (cAliasSD1)->D1_FILIAL == xFilial("SD1") )
	
	SC7->(dbSetOrder(14))
	SC7->(MsSeek(xFilEnt(xFilial("SC7"))+(cAliasSD1)->D1_PEDIDO+(cAliasSD1)->D1_ITEMPC))
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ A data de Emissao do PC e a dataBase usada na Analise da Cotacao para     ³
	//³ compor a data de entrega do PC atraves da soma do C8_PRAZO.               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nPrazoBase := SC7->C7_DATPRF - SC7->C7_EMISSAO
	nPrecoBase := SC7->C7_PRECO
	
	If !Empty(SC7->C7_NUMCOT)
		
		SC8->(dbSetOrder(3))
		SC8->(MsSeek(xFilial("SC8")+SC7->C7_NUMCOT+SC7->C7_PRODUTO))
		
		lPreco := .T.
		lPrazo := .T.
		lNeces := .T.
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Avalia toda a cotacao do produto entregue para verificar se o preco   ³
		//³ e prazo escolhido foi o melhor da cotacao do produto, se nao for,sera ³
		//³ descontado o Indice A para Precos e B para Prazos para a composicao   ³
		//³ da eficiencia total do processo de compras.                           ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		While ( !SC8->(Eof()) .And. SC8->C8_FILIAL == xFilial("SC8") .And. ;
			SC8->C8_NUM == SC7->C7_NUMCOT .And. SC8->C8_PRODUTO == SC7->C7_PRODUTO )
			
			If SC8->C8_FORNECE+SC8->C8_LOJA+SC8->C8_NUMPED+SC8->C8_ITEMPED <> SC7->C7_FORNECE+SC7->C7_LOJA+SC7->C7_NUM+SC7->C7_ITEM
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Regra para descontar o Indice A - Menor Preco, Se encontrar   ³
				//³ um outro Fornecedor com o preco menor na cotacao passa apenas ³
				//³ uma vez para alimentar a variavel nDescIndA.                  ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If lPreco .And. SC8->C8_PRECO > 0 .And. SC8->C8_PRECO < nPrecoBase
					
					nDescIndA++
					
					lPreco := .F.
					
				EndIf
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Regra para descontar o Indice B - Menor Prazo, Se encontrar   ³
				//³ um outro Fornecedor com o prazo menor na cotacao passa apenas ³
				//³ uma vez para alimentar a variavel nDescIndB.                  ³
				//³ Avalia somente os Fornecedores que informaram precos na Cot.  ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If lPrazo .And. SC8->C8_PRAZO > 0 .And. ( ( SC7->C7_EMISSAO + SC8->C8_PRAZO ) - SC7->C7_EMISSAO ) < nPrazoBase
					
					nDescIndB++
					
					lPrazo := .F.
					
				EndIf
				
			EndIf
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Se for encontrado precos e prazos menores interrompe o While pois ³
			//³ nao sera necessario rodar a cotacao inteira.                      ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If !lPreco .And. !lPrazo
				Exit
			EndIf
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Avalia se todos os itens deste produto na cotacao nao foram infor ³
			//³ mados o prazo de entrega pelo fornecedor, caso isso ocorra a varia³
			//³ vel lNeces sera .T. indicando que essa entrega foi gerada pela da ³
			//³ ta da necessidade e dever ser deduzido o peso do IndiceB desta    ³
			//³ entrega acrescentando a diferenca desconta para o IndiceC.        ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If SC8->C8_PRAZO > 0
				lNeces := .F.
			EndIf
			
			SC8->(dbSkip())
			
		EndDo
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Alimenta as entregas que foram geradas por data de necessidade para   ³
		//³ deduzir o peso do Indice B.                                           ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lNeces
			nSemPrazo++
		EndIf
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Regra para descontar o Indice C - Cumprimento do Prazo de Entrega.    ³
		//³ Avalia se o prazo de Entrega da NFE foi maior do que o definido no PC ³
		//³ se for deduzira o percentual do Indice C.                             ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If StoD((cAliasSD1)->D1_DTDIGIT) > SC7->C7_DATPRF
			nDescIndC++
		EndIf
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ A variavel nTotEfcz acumula o total das entregas avaliadas para compor³
		//³ os 100%.                                                              ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nTotEfcz++
		
	EndIf
	
	(cAliasSD1)->(dbSkip())
	
EndDo

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Calcula o percentual de cada Indice em relacao ao total de Entregas.         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nIndiceA  := ( ( ( nTotEfcz - nDescIndA ) / nTotEfcz ) * 100 )
nIndiceB  := ( ( ( nTotEfcz - nDescIndB ) / nTotEfcz ) * 100 )
nIndiceC  := ( ( ( nTotEfcz - nDescIndC ) / nTotEfcz ) * 100 )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Definicao padrao dos pesos matematicos de cada Indice conforme a Importancia.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nPesoA    := 5
nPesoB    := 3
nPesoC    := 2

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Deduz percentualmente do Indice B as entregas que foram geradas pela data da ³
//³ necessidade na cotacao e acrescenta essa diferenca ao peso do Indice C.      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nSemPrazo > 0
	nPesoB := nPesoB * ( ( nTotEfcz - nSemPrazo ) / nTotEfcz )
	nPesoC := nPesoC + ( 3 - nPesoB )
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Calcula o Percentual de Eficiencia do Processo completo de compra do item    ³
//³ conforme os Indices e pesos Calculados.                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nEficaz   := ( ( nIndiceA * nPesoA ) + ( nIndiceB * nPesoB ) + ( nIndiceC * nPesoC ) ) / 10

cHelp := "'"+STR0005 + "'+chr(13)+chr(10)+" //"Para chegar ao Indice Total de Eficiência o sistema pesquisa os últimos  "
cHelp += "'"+STR0006 + "'+chr(13)+chr(10)+" //"90 dias somente das entregas que foram originadas do processo de cotação."
cHelp += "'"+"     " + "'+chr(13)+chr(10)+"
cHelp += "'"+STR0007 + "'+chr(13)+chr(10)+" //"Formula do Indice Eficiência =((Indice A * Peso A) + (Indice B * Peso B) + (Indice C * Peso C)) / 10 "
cHelp += "'"+"     " + "'+chr(13)+chr(10)+"
cHelp += "'"+STR0008 + "'+chr(13)+chr(10)+" //"Indice A = % de vezes que o Vencedor escolhido da cotação é o que tem o melhor preço"
cHelp += "'"+STR0009 + "'+chr(13)+chr(10)+"	//"Indice B = % de vezes que o Vencedor escolhido da cotação é o que tem o menor prazo de entrega"
cHelp += "'"+STR0010 + "'+chr(13)+chr(10)+"	//"Indice C = % de vezes em que a entrega do material (Documento de Entrada) ocorre dentro da data Prevista no Pedido de Compras."
cHelp += "'"+"     " + "'+chr(13)+chr(10)+"
cHelp += "'"+STR0011 + "'+chr(13)+chr(10)+" //"Definição dos Pesos Utilizados na Formula : "
cHelp += "'"+"     " + "'+chr(13)+chr(10)+"
cHelp += "'"+STR0012 + "'+chr(13)+chr(10)+"	//"Peso A = 5  Peso B = 3  Peso C = 2"
cHelp += "'"+STR0013 + "'+chr(13)+chr(10)+"	//"O Peso B sofre um desconto percentual em relação ao total de entregas "
cHelp += "'"+STR0014 + "'+chr(13)+chr(10)+"	//"analisadas toda vez que na cotação do material analisado a data de "
cHelp += "'"+STR0015 + "'+chr(13)+chr(10)+"	//"entrega não foi informada ou o pedido foi gerado a partir da data da "
cHelp += "'"+STR0016 + "'+chr(13)+chr(10)+"	//"necessidade do material. Quando esse desconto é realizado o mesmo é adicionado ao Peso C."
cHelp += "'"+"     " + "'+chr(13)+chr(10)+"
cHelp += "'"+STR0017 + "'+chr(13)+chr(10)+"	//"Exemplo :"
cHelp += "'"+"     " + "'+chr(13)+chr(10)+"
cHelp += "'"+STR0018 + "'+chr(13)+chr(10)+"	//"Em 90 dias foram analisadas 1000 Entregas onde 250 foram originadas de "
cHelp += "'"+STR0019 + "'+chr(13)+chr(10)+"	//"cotações por data de necessidade ou sem data de entrega informada. Os Pesos "
cHelp += "'"+STR0020 + "'+chr(13)+chr(10)+"	//"B e C seriam :"
cHelp += "'"+STR0021 + "'+chr(13)+chr(10)+"	//"PesoB = ( ( 1000 - 250 ) / 1000 ) * 3 que resulta em 2.25 "
cHelp += "'"+STR0022 + "'+chr(13)+chr(10)"	//"PesoC = a Diferenca de 3 - 2.25 = 0.75  somada ao Indice C 2 que Resulta em 2.75"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ O Aadd contem informacoes de todos os Indicadores para Painel do Tipo 1      ³
//³ Alterado para Painel Tipo 3 - Aguardando definicoes do Projeto.              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Aadd( aPanel, { STR0001,Transform(nIndiceA,"@R 999.99")+" %",Iif(nIndiceA > 50,CLR_HBLUE,CLR_HRED),}) //"Melhores Preços " //"Melhores Preços "
Aadd( aPanel, { STR0002,Transform(nIndiceB,"@R 999.99")+" %",Iif(nIndiceB > 50,CLR_HBLUE,CLR_HRED),}) //"Melhores Prazos " //"Melhores Prazos "
Aadd( aPanel, { STR0003,Transform(nIndiceC,"@R 999.99")+" %",Iif(nIndiceC > 50,CLR_HBLUE,CLR_HRED),}) //"Prazos Cumpridos" //"Prazos Cumpridos"
Aadd( aPanel, { STR0004,Transform(nEficaz ,"@R 999.99")+" %",Iif(nEficaz  > 50,CLR_HBLUE,CLR_HRED),}) //"Indice de Eficiência" //"Indice de Eficiência"

aPanel:= {STR0023,Transform(nEficaz,"@R 999.99")+"%",/* "% Mês" */,Iif(nEficaz > 60,CLR_HBLUE,CLR_HRED),"{ || MsgInfo("+cHelp+") }",0,100,nEficaz }	 //"Eficiência do Processo de Compras em 90 Dias."

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Apaga arquivos de trabalho,cancela filtros e restabelece as ordens originais.|
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lQuery
	dbSelectArea(cAliasSD1)
	dbCloseArea()
Else
	dbSelectArea("SD1")
	RetIndex("SD1")
	dbClearFilter()
	Ferase(cIndSD1+OrdBagExt())
EndIf

Return aPanel 
