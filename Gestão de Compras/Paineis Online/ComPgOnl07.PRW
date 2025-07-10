#INCLUDE "Protheus.ch"
#INCLUDE "MSgraphi.ch"
#INCLUDE "ComPgOnl07.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ComPgOnl07³Autor  ³Alexandre Inacio Lemes ³Data  ³06/02/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Monta array para Painel de Gestao On-line Tipo\Padrao 2.2: ³±±
±±³          ³ Contratos de Parceria em Aberto                            ³±±
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
Function ComPgOnl07()

Local aTitle    := {STR0001,STR0002,STR0003,STR0004,STR0005,STR0006} //"Contrato"###"Fornecedor"###"Data Emissão"###"Data Incial"###"Data Final"###"Filial de Entrega"
Local aTipoSC3  := {}
Local aQtdSC3   := {}
Local aSC3Open  := {}
Local aSC3Parc  := {}
Local aSC3Bloq  := {}
Local aPanel    := {}
Local aTable    := {}

Local cAliasSC3 := "SC3"
Local cWhere    := ""
Local cCondicao := ""
Local cIndSC3	:= ""
Local cNumSC3   := ""
Local cFilEntr  := ""
Local cPerg     := "COMPGONL07"         
Local dEmissao  := dDataBase
Local dInicialCP:= dDataBase
Local dFinalCP  := dDataBase

Local nOrderSC3 := 0
Local lQuery    := .F.
Local lOpen     := .F.
Local lParcial  := .F.
Local lBloqued  := .F.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para parametros                         ³
//³                                                              ³
//³ mv_par01            // Produto                     (Range)   ³
//³ mv_par02            // Fornecedor                  (Range)   ³
//³ mv_par03            // Loja                        (Range)   ³
//³ mv_par04            // Data de Emissao             (Range)   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Pergunte(cPerg,.F.)
FullRange(cPerg)

dbSelectArea("SA2")
dbSetOrder(1)

dbSelectArea("SC3")
dbSetOrder(1)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Transforma parametros Range em expressao SQL                            ³	
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
MakeSqlExpr(cPerg)
mv_par01 := '%'+mv_par01+'%'
mv_par02 := '%'+mv_par02+'%'
mv_par03 := '%'+mv_par03+'%'
mv_par04 := '%'+mv_par04+'%'

    lQuery    := .T.
cAliasSC3 := GetNextAlias()	

cWhere :="%"
cWhere += " (C3_QUANT - C3_QUJE) > 0 AND C3_RESIDUO = ' ' "	
cWhere +="%"	

BeginSql Alias cAliasSC3

SELECT SC3.* , SC3.R_E_C_N_O_ SC3RecNo 

FROM %table:SC3% SC3

WHERE SC3.C3_FILIAL = %xFilial:SC3%  
AND %Exp:cWhere%
AND SC3.%NotDel% 
AND %Exp:mv_par01%
AND %Exp:mv_par02%
AND %Exp:mv_par03%
AND %Exp:mv_par04%
		  
ORDER BY %Order:SC3% 
		
EndSql 

dbSelectArea(cAliasSC3)

cNumSC3   := (cAliasSC3)->C3_NUM 
cFilEntr  := (cAliasSC3)->C3_FILENT
dEmissao  := STOD((cAliasSC3)->C3_EMISSAO)
dInicialCP:= STOD((cAliasSC3)->C3_DATPRI)
dFinalCP  := STOD((cAliasSC3)->C3_DATPRF)

Do While (cAliasSC3)->(!Eof()) .And. (cAliasSC3)->C3_FILIAL = xFilial("SC3")
	
	SA2->(dbSetOrder(1))
	SA2->(dbSeek( xFilial("SA2") + (cAliasSC3)->C3_FORNECE + (cAliasSC3)->C3_LOJA ))
			
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Identifica se o CP esta em aberto, sendo que nao deve existir nenhum item do CP parcialmente atendido ³	
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If (cAliasSC3)->C3_QUJE == 0 .And. (cAliasSC3)->C3_CONAPRO <> "B" .And. lParcial == .F.
        lOpen    := .T.	
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Se exitir um item do CP parcialmente atendido ou atendido o CP sera considerado parcialmente atendido ³	
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
	If (cAliasSC3)->C3_QUJE > 0 .And. (cAliasSC3)->C3_CONAPRO <> "B"
        lOpen    := .F.	
        lParcial := .T.    
    EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Se o CP estiver Bloqueado independente do atendimento sera considerado Aguardando liberacao.          ³	
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	    
	If (cAliasSC3)->C3_CONAPRO == "B"
        lBloqued := .T.
	EndIf

	(cAliasSC3)->(dbSkip())

    If (cAliasSC3)->C3_NUM <> cNumSC3 .Or. (cAliasSC3)->(Eof())

	    If lOpen
			Aadd(aSC3Open,{cNumSC3,SA2->A2_NOME,dEmissao,dInicialCP,dFinalCP,cFilEntr })          
		ElseIf lParcial
	 		Aadd(aSC3Parc,{cNumSC3,SA2->A2_NOME,dEmissao,dInicialCP,dFinalCP,cFilEntr })          
	    ElseIf lBloqued
			Aadd(aSC3Bloq,{cNumSC3,SA2->A2_NOME,dEmissao,dInicialCP,dFinalCP,cFilEntr })          
	    EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Apos a Classificacao do PC alimenta as variaveis para avaliacao do proximo PC a ser classificado. ³	
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	    
		cNumSC3   := (cAliasSC3)->C3_NUM 
		cFilEntr  := (cAliasSC3)->C3_FILENT
		dEmissao  := STOD((cAliasSC3)->C3_EMISSAO)
		dInicialCP:= STOD((cAliasSC3)->C3_DATPRI)
		dFinalCP  := STOD((cAliasSC3)->C3_DATPRF)
		
        lOpen     := .F.
        lParcial  := .F.
        lBloqued  := .F.

    EndIf
     
EndDo

If !Empty(aSC3Open)
	Aadd(aTipoSC3,STR0007)  //"Não Atendidos"
	Aadd(aTable , {aTipoSC3[Len(aTipoSC3)] , aTitle , aSC3Open})
	Aadd(aQtdSC3,Len(aSC3Open))  
EndIf

If !Empty(aSC3Parc)
	Aadd(aTipoSC3,STR0008)  //"Parcialmente Atendidos"
	Aadd(aTable , {aTipoSC3[Len(aTipoSC3)] , aTitle , aSC3Parc})
	Aadd(aQtdSC3,Len(aSC3Parc))  
EndIf

If !Empty(aSC3Bloq)
	Aadd(aTipoSC3, STR0009)  //"Aguardando Liberação"
	Aadd(aTable , {aTipoSC3[Len(aTipoSC3)] , aTitle , aSC3Bloq})
	Aadd(aQtdSC3,Len(aSC3Bloq))
EndIf

If Empty(aSC3Open) .And. Empty(aSC3Parc) .And. Empty(aSC3Bloq)
	Aadd(aTipoSC3, STR0012) //"Nao foram encotrados Contratos de Parceria em Aberto"
	Aadd(aTable , {aTipoSC3[Len(aTipoSC3)] , aTitle , {{" "," "," "," "," "," "}} })
	Aadd(aQtdSC3,1)
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Preenche array do Painel de Gestao                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aPanel:= {GRP_PIE, {STR0010,/*bClickG*/,aTipoSC3,aQtdSC3},{STR0011,{ |x| COMPView07( x[1] ) },aTable}} //"Numero de Contratos em Aberto"###"Contratos de Parceria"
			
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Apaga os arquivos de trabalho, cancela os filtros e restabelece as ordens originais.|
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lQuery
	dbSelectArea(cAliasSC3)
	dbCloseArea()
Else
  	dbSelectArea("SC3") 
	RetIndex("SC3") 
	dbClearFilter()
	Ferase(cIndSC3+OrdBagExt())
EndIf

Return aPanel 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³COMPView07³ Autor ³Alexandre Inacio Lemes ³ Data ³ 06/02/2007 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Consulta os documentos de Contrato de Parceria                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ ComPgOnl07                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function COMPView07(cContrato)

Local aArea := GetArea()

dbSelectArea("SC3")
dbSetOrder(1)
If MsSeek(xFilial("SC3")+Substr(cContrato,1,len(SC3->C3_NUM)))
//	Mata125(NIL,NIL,NIL,2) // Aguardando Depto de tecnologia para definicao das regras para chamadas dos programas. 06/02/2007 
EndIf

RestArea(aArea)

Return
