#INCLUDE "Protheus.ch"
#INCLUDE "MSgraphi.ch"
#INCLUDE "ComPgOnl08.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ComPgOnl08³Autor  ³Alexandre Inacio Lemes ³Data  ³06/02/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Monta array para Painel de Gestao On-line Tipo\Padrao 2.2: ³±±
±±³          ³ Cotacoes de Compras em Aberto                              ³±±
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
Function ComPgOnl08()

Local aTitle    := {STR0001,STR0002} //"Cotação"###"Data Emissao"
Local aTipoSC8  := {}
Local aQtdSC8   := {}
Local aSC8Open  := {}
Local aSC8Parc  := {}
Local aSC8Bloq  := {}
Local aPanel    := {}
Local aTable    := {}

Local cAliasSC8 := "SC8"
Local cWhere    := ""
Local cCondicao := ""
Local cIndSC8	:= ""
Local cNumSC8   := ""
Local cPerg     := "COMPGONL08"         
Local dEmissao  := dDataBase

Local nOrderSC8 := 0
Local lQuery    := .F.
Local lOpen     := .F.
Local lAnalise  := .F.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para parametros                         ³
//³                                                              ³
//³ mv_par01            // Produto                     (Range)   ³
//³ mv_par02            // Fornecedor                  (Range)   ³
//³ mv_par03            // Loja                        (Range)   ³
//³ mv_par04            // Proposta                    (Range)   ³
//³ mv_par05            // Data de Emissao             (Range)   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Pergunte(cPerg,.F.)
FullRange(cPerg)

dbSelectArea("SC8")
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
cAliasSC8 := GetNextAlias()	

cWhere :="%"
cWhere += " C8_NUMPED = ' ' "	
cWhere +="%"	

BeginSql Alias cAliasSC8

SELECT SC8.* , SC8.R_E_C_N_O_ SC8RecNo 

FROM %table:SC8% SC8

WHERE SC8.C8_FILIAL = %xFilial:SC8%  
AND %Exp:cWhere%
AND SC8.%NotDel% 
AND %Exp:mv_par01%
AND %Exp:mv_par02%
AND %Exp:mv_par03%
AND %Exp:mv_par04%
AND %Exp:mv_par05%
		  
ORDER BY %Order:SC8% 
		
EndSql 

dbSelectArea(cAliasSC8)

cNumSC8   := (cAliasSC8)->C8_NUM 
dEmissao  := STOD((cAliasSC8)->C8_EMISSAO)

Do While (cAliasSC8)->(!Eof()) .And. (cAliasSC8)->C8_FILIAL = xFilial("SC8")

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Identifica se a Cotacao esta em aberto, sendo que nao deve existir nenhum item da Cotacao com Preco   ³	
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If (cAliasSC8)->C8_PRECO == 0 .And. lAnalise == .F.
        lOpen    := .T.	
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Se exitir um item da Cotacao ja atualizado com preco a cotacao sera considerada em Analise.           ³	
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
	If (cAliasSC8)->C8_PRECO <> 0
        lOpen    := .F.	
        lAnalise := .T.    
    EndIf

	(cAliasSC8)->(dbSkip())

    If (cAliasSC8)->C8_NUM <> cNumSC8 .Or. (cAliasSC8)->(Eof())

	    If lOpen
			Aadd(aSC8Open,{cNumSC8,dEmissao})          
		ElseIf lAnalise
	 		Aadd(aSC8Parc,{cNumSC8,dEmissao})          
	    EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Apos a Classificacao do PC alimenta as variaveis para avaliacao do proximo PC a ser classificado. ³	
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	    
		cNumSC8   := (cAliasSC8)->C8_NUM 
		dEmissao  := STOD((cAliasSC8)->C8_EMISSAO)
		
        lOpen     := .F.
        lAnalise  := .F.

    EndIf
     
EndDo

If !Empty(aSC8Open)
	Aadd(aTipoSC8,STR0003)     //"Em Aberto"
	Aadd(aTable , {aTipoSC8[Len(aTipoSC8)] , aTitle , aSC8Open})
	Aadd(aQtdSC8,Len(aSC8Open))  
EndIf

If !Empty(aSC8Parc)
	Aadd(aTipoSC8,STR0004)   //"Em Analise"
	Aadd(aTable , {aTipoSC8[Len(aTipoSC8)] , aTitle , aSC8Parc})
	Aadd(aQtdSC8,Len(aSC8Parc))  
EndIf

If Empty(aSC8Open) .And. Empty(aSC8Parc) 
	Aadd(aTipoSC8, STR0007)  //"Nao foram encotradas Cotações de Compras em Aberto"
	Aadd(aTable , {aTipoSC8[Len(aTipoSC8)] , aTitle , {{" "," "}} })
	Aadd(aQtdSC8,1)
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Preenche array do Painel de Gestao                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aPanel:= {GRP_PIE, {STR0005,/*bClickG*/,aTipoSC8,aQtdSC8},{STR0006,{ |x| COMPView08( x[1] ) },aTable}} //"Numero de Cotações em Aberto"###"Cotações de Compras"
			
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Apaga os arquivos de trabalho, cancela os filtros e restabelece as ordens originais.|
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lQuery
	dbSelectArea(cAliasSC8)
	dbCloseArea()
Else
  	dbSelectArea("SC8") 
	RetIndex("SC8") 
	dbClearFilter()
	Ferase(cIndSC8+OrdBagExt())
EndIf

Return aPanel 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³COMPView08³ Autor ³Alexandre Inacio Lemes ³ Data ³ 06/02/2007 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Consulta os documentos de Cotacao de Compras                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ ComPgOnl07                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function COMPView08(cCotacao)

Local aArea := GetArea()

dbSelectArea("SC8")
dbSetOrder(1)
If MsSeek(xFilial("SC8")+Substr(cCotacao,1,len(SC8->C8_NUM)))
//	Mata160(NIL,2) // Aguardando Depto de tecnologia para definicao das regras para chamadas dos programas. 06/02/2007 
EndIf

RestArea(aArea)

Return
