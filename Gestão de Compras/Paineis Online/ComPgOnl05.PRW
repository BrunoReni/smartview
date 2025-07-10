#INCLUDE "Protheus.ch"
#INCLUDE "MSgraphi.ch"
#INCLUDE "ComPgOnl05.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ComPgOnl05³Autor  ³Alexandre Inacio Lemes ³Data  ³06/02/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Monta array para Painel de Gestao On-line Tipo\Padrao 2.2: ³±±
±±³          ³ Pedidos de Compras em aberto                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ComPgOnl05(nTipo)1 = Pedido Compras  2 = Autorizacao Entrega³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Array = {cTypeGraf,{cTitleG,bClickG,aEixoX,aEixoY},        ³±±
±±³          ³ {cTitleT,bClickT,aTabela}}                                 ³±±
±±³          ³ cTypeGraph = Tipo do grafico                       		  ³±±
±±³          ³ cTitleG    = Titulo do grafico                      		  ³±±
±±³          ³ bClickG    = Bloco de codigo executado no click do grafico ³±±
±±³          ³ aEixoX     = Atributos do eixo X                           ³±±
±±³          ³ aEixoY     = Atributos do eixo Y                           ³±±
±±³          ³ cTitleT    = Titulo da tabela                              ³±±
±±³          ³ bClickT    = Bloco de codigo executado no click da tabela  ³±±
±±³          ³ aTabela    = Array multidimensional contendo os array por  ³±±
±±³          ³ filtro, no formato{"filtro",aCabec,aValores}               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGACOM                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function ComPgOnl05(oObj,nTipo)

Local aTitle    := {} 
Local aTipoSC7  := {}
Local aQtdSC7   := {}
Local aSC7Open  := {}
Local aSC7Parc  := {}
Local aSC7Bloq  := {}
Local aPanel    := {}
Local aTable    := {}

Local cAliasSC7 := "SC7"
Local cWhere    := ""
Local cCondicao := ""
Local cIndSC7	:= ""
Local cNumSC7   := ""
Local cFilEntr  := ""
Local cPerg     := ""         
Local dEmissao  := dDataBase
Local dEntrega  := dDataBase

Local nOrderSC7 := 0
Local lQuery    := .F.
Local lOpen     := .F.
Local lParcial  := .F.
Local lBloqued  := .F.

DEFAULT nTipo := 1

aTitle := {Iif(nTipo == 1,STR0001,STR0002),STR0003,STR0004,STR0005,STR0006}  //"Pedido"###"Autorização de Entrega"###"Fornecedor"###"Data Emissão"###"Data Entrega"###"Filial de Entrega"

If nTipo == 1 
	cPerg := "COMPGONL05" 
else
	cPerg := "COMPGONL06" 
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para parametros                         ³
//³                                                              ³
//³ mv_par01            // Produto                     (Range)   ³
//³ mv_par02            // Fornecedor                  (Range)   ³
//³ mv_par03            // Loja                        (Range)   ³
//³ mv_par04            // Data de Emissao             (Range)   ³
//³ mv_par05            // Data de Entrega             (Range)   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Pergunte(cPerg,.F.)
FullRange(cPerg)

dbSelectArea("SA2")
dbSetOrder(1)

dbSelectArea("SC7")
dbSetOrder(1)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Transforma parametros Range em expressao SQL                            ³	
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
MakeSqlExpr(cPerg)
mv_par01 := '%'+mv_par01+'%'
mv_par02 := '%'+mv_par02+'%'
mv_par03 := '%'+mv_par03+'%'
mv_par04 := '%'+mv_par04+'%'
mv_par05 := '%'+mv_par05+'%'

    lQuery    := .T.
cAliasSC7 := GetNextAlias()	

cWhere :="%"
cWhere += " (C7_QUANT - C7_QUJE) > 0 AND C7_RESIDUO = ' ' "	
 
    If nTipo == 1
	cWhere += " AND C7_TIPO = 1 "		
    Else
	cWhere += " AND C7_TIPO = 2 "		    
    EndIf 

cWhere +="%"	

BeginSql Alias cAliasSC7

SELECT SC7.* , SC7.R_E_C_N_O_ SC7RecNo 

FROM %table:SC7% SC7

WHERE SC7.C7_FILIAL = %xFilial:SC7%  
AND %Exp:cWhere%
AND SC7.%NotDel% 
AND %Exp:mv_par01%
AND %Exp:mv_par02%
AND %Exp:mv_par03%
AND %Exp:mv_par04%
AND %Exp:mv_par05%
		  
ORDER BY %Order:SC7% 
		
EndSql 
	
dbSelectArea(cAliasSC7)

cNumSC7  := (cAliasSC7)->C7_NUM 
cFilEntr := (cAliasSC7)->C7_FILENT
dEmissao := STOD((cAliasSC7)->C7_EMISSAO)
dEntrega := STOD((cAliasSC7)->C7_DATPRF)

Do While (cAliasSC7)->(!Eof()) .And. (cAliasSC7)->C7_FILIAL = xFilial("SC7")
	
	SA2->(dbSetOrder(1))
	SA2->(dbSeek( xFilial("SA2") + (cAliasSC7)->C7_FORNECE + (cAliasSC7)->C7_LOJA ))
			
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Identifica se o PC esta em aberto, sendo que nao deve existir nenhum item do PC parcialmente atendido ³	
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If (cAliasSC7)->C7_QUJE == 0 .And. (cAliasSC7)->C7_CONAPRO <> "B" .And. lParcial == .F.
        lOpen    := .T.	
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Se exitir um item do PC parcialmente atendido ou atendido o PC sera considerado parcialmente atendido ³	
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
	If (cAliasSC7)->C7_QUJE > 0 .And. (cAliasSC7)->C7_CONAPRO <> "B"
        lOpen    := .F.	
        lParcial := .T.    
    EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Se o PC estiver Bloqueado independente do atendimento será considerado Aguardando liberacao.          ³	
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	    
	If (cAliasSC7)->C7_CONAPRO == "B"
        lBloqued := .T.
	EndIf

	(cAliasSC7)->(dbSkip())

    If (cAliasSC7)->C7_NUM <> cNumSC7 .Or. (cAliasSC7)->(Eof())

	    If lOpen
			Aadd(aSC7Open,{cNumSC7,SA2->A2_NOME,dEmissao,dEntrega,cFilEntr })          
		ElseIf lParcial
	 		Aadd(aSC7Parc,{cNumSC7,SA2->A2_NOME,dEmissao,dEntrega,cFilEntr })          
	    ElseIf lBloqued
			Aadd(aSC7Bloq,{cNumSC7,SA2->A2_NOME,dEmissao,dEntrega,cFilEntr })          
	    EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Apos a Classificacao do PC alimenta as variaveis para avaliacao do proximo PC a ser classificado. ³	
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	    
		cNumSC7  := (cAliasSC7)->C7_NUM 
		cFilEntr := (cAliasSC7)->C7_FILENT
		dEmissao := STOD((cAliasSC7)->C7_EMISSAO)
		dEntrega := STOD((cAliasSC7)->C7_DATPRF)
		
        lOpen    := .F.
        lParcial := .F.
        lBloqued := .F.

    EndIf
     
EndDo

If !Empty(aSC7Open)
	Aadd(aTipoSC7,STR0007)  //"Não Atendidos"
	Aadd(aTable , {aTipoSC7[Len(aTipoSC7)] , aTitle , aSC7Open})
	Aadd(aQtdSC7,Len(aSC7Open))  
EndIf

If !Empty(aSC7Parc)
	Aadd(aTipoSC7,STR0008)  //"Parcialmente Atendidos"
	Aadd(aTable , {aTipoSC7[Len(aTipoSC7)] , aTitle , aSC7Parc})
	Aadd(aQtdSC7,Len(aSC7Parc))  
EndIf

If !Empty(aSC7Bloq)
	Aadd(aTipoSC7, STR0009)  //"Aguardando Liberação"
	Aadd(aTable , {aTipoSC7[Len(aTipoSC7)] , aTitle , aSC7Bloq})
	Aadd(aQtdSC7,Len(aSC7Bloq))
EndIf

If Empty(aSC7Open) .And. Empty(aSC7Parc) .And. Empty(aSC7Bloq)
	Aadd(aTipoSC7, STR0014) //"Nao foram encotrados Pedidos de Compras em Aberto"
	Aadd(aTable , {aTipoSC7[Len(aTipoSC7)] , aTitle , {{" "," "," "," "," "}} })
	Aadd(aQtdSC7,1)
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Preenche array do Painel de Gestao                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aPanel:= {GRP_PIE, { Iif( nTipo == 1 ,STR0010,STR0011) ,/*bClickG*/,aTipoSC7,aQtdSC7}, ;  //"Numero de Pedidos em Aberto"###"Autorizações de Entrega em Aberto"
{Iif( nTipo == 1 ,STR0012,STR0013),{ |x| COMPView05( x[1] ) },aTable}} //"Pedidos de Compras"###"Autorizaçôes de Entrega"
			
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Apaga os arquivos de trabalho, cancela os filtros e restabelece as ordens originais.|
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lQuery
	dbSelectArea(cAliasSC7)
	dbCloseArea()
Else
  	dbSelectArea("SC7") 
	RetIndex("SC7") 
	dbClearFilter()
	Ferase(cIndSC7+OrdBagExt())
EndIf

Return aPanel 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³COMPView05³ Autor ³Alexandre Inacio Lemes ³ Data ³ 06/02/2007 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Consulta os documentos de Pedido de Compras                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ ComPgOnl05                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function COMPView05(cPedido)

Local aArea := GetArea()

dbSelectArea("SC7")
dbSetOrder(1)
If MsSeek(xFilial("SC7")+Substr(cPedido,1,len(SC7->C7_NUM)))
//	Mata120(NIL,NIL,NIL,2) // Aguardando Depto de tecnologia para definicao das regras para chamadas dos programas. 06/02/2007 
EndIf

RestArea(aArea)

Return
