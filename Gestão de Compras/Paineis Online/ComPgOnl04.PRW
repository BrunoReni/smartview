#INCLUDE "Protheus.ch"
#INCLUDE "MSgraphi.ch"
#INCLUDE "ComPgOnl04.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ComPgOnl04³Autor  ³Alexandre Inacio Lemes ³Data  ³06/02/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Monta array para Painel de Gestao On-line Tipo\Padrao 2.2: ³±±
±±³          ³ Solicitacoes de Compras em Aberto                          ³±±
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
Function ComPgOnl04()

Local aTitle    := {STR0001,STR0002,STR0003,STR0004}  //"Solicitação"###"Data Emissão"###"Data Necessidade"###"Filial de Entrega"
Local aTipoSC1  := {}
Local aQtdSC1   := {}
Local aSC1Open  := {}
Local aSC1Parc  := {}
Local aSC1Bloq  := {}
Local aPanel    := {}
Local aTable    := {}

Local cAliasSC1 := "SC1"
Local cWhere    := ""
Local cCondicao := ""
Local cIndSC1	:= ""
Local cNumSC1   := ""
Local cFilEntr  := ""
Local cPerg     := "COMPGONL04"         

Local dEmissao  := dDataBase
Local dEntrega  := dDataBase

Local nOrderSC1 := 0

Local lQuery    := .F.
Local lOpen     := .F.
Local lParcial  := .F.
Local lBloqued  := .F.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para parametros                         ³
//³                                                              ³
//³ mv_par01            // Produto                     (Range)   ³
//³ mv_par02            // Data de Emissao             (Range)   ³
//³ mv_par03            // Data de Necessidade         (Range)   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Pergunte(cPerg,.F.)
FullRange(cPerg)

dbSelectArea("SC1")
dbSetOrder(1)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Transforma parametros Range em expressao SQL                            ³	
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
MakeSqlExpr(cPerg)
mv_par01 := '%'+mv_par01+'%'
mv_par02 := '%'+mv_par02+'%'
mv_par03 := '%'+mv_par03+'%'

    lQuery    := .T.
cAliasSC1 := GetNextAlias()	

cWhere :="%"
cWhere += " (C1_QUANT - C1_QUJE) > 0 AND ( C1_COTACAO = '      ' OR C1_COTACAO = 'XXXXXX' ) AND C1_RESIDUO = ' ' "	
cWhere +="%"	

BeginSql Alias cAliasSC1

SELECT SC1.* , SC1.R_E_C_N_O_ SC1RecNo 

FROM %table:SC1% SC1

WHERE SC1.C1_FILIAL = %xFilial:SC1%  
AND %Exp:cWhere%
AND SC1.%NotDel% 
AND %Exp:mv_par01%
AND %Exp:mv_par02%
AND %Exp:mv_par03%
		  
ORDER BY %Order:SC1% 
		
EndSql 

dbSelectArea(cAliasSC1)

cNumSC1  := (cAliasSC1)->C1_NUM 
cFilEntr := (cAliasSC1)->C1_FILENT
dEmissao := STOD((cAliasSC1)->C1_EMISSAO)
dEntrega := STOD((cAliasSC1)->C1_DATPRF)

Do While (cAliasSC1)->(!Eof()) .And. (cAliasSC1)->C1_FILIAL = xFilial("SC1")

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Identifica se a SC esta em aberto, sendo que nao deve existir nenhum item da SC parcialmente atendida ³	
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If (cAliasSC1)->C1_QUJE == 0 .And. (cAliasSC1)->C1_APROV $" ,L" .And. lParcial == .F. .And. lBloqued == .F.
        lOpen    := .T.	
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Se exitir um item da SC parcialmente atendido ou atendida a SC sera considerada parcialmente atendida ³	
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
	If (cAliasSC1)->C1_QUJE > 0 .And. (cAliasSC1)->C1_APROV $" ,L" .And. lBloqued == .F.
        lOpen    := .F.	
        lParcial := .T.    
    EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Se um item da SC estiver Bloqueado independente dos demais itens sera considerada Aguardando liberacao³	
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	    
	If (cAliasSC1)->C1_APROV == "B" .Or. (cAliasSC1)->C1_APROV == "R"
        lOpen    := .F.	
        lParcial := .F.    
        lBloqued := .T.
	EndIf

	(cAliasSC1)->(dbSkip())

    If (cAliasSC1)->C1_NUM <> cNumSC1 .Or. (cAliasSC1)->(Eof())

	    If lOpen
			Aadd(aSC1Open,{cNumSC1,dEmissao,dEntrega,cFilEntr })          
		ElseIf lParcial
	 		Aadd(aSC1Parc,{cNumSC1,dEmissao,dEntrega,cFilEntr })          
	    ElseIf lBloqued
			Aadd(aSC1Bloq,{cNumSC1,dEmissao,dEntrega,cFilEntr })          
	    EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Apos a Classificacao da SC alimenta as variaveis para avaliacao da proxima SC a ser classificada. ³	
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	    
		cNumSC1  := (cAliasSC1)->C1_NUM 
		cFilEntr := (cAliasSC1)->C1_FILENT
		dEmissao := STOD((cAliasSC1)->C1_EMISSAO)
		dEntrega := STOD((cAliasSC1)->C1_DATPRF)
		
        lOpen    := .F.
        lParcial := .F.
        lBloqued := .F.

    EndIf
     
EndDo

If !Empty(aSC1Open)
	Aadd(aTipoSC1,STR0005)  //"Não Atendidos"
	Aadd(aTable , {aTipoSC1[Len(aTipoSC1)] , aTitle , aSC1Open})
	Aadd(aQtdSC1,Len(aSC1Open))  
EndIf

If !Empty(aSC1Parc)
	Aadd(aTipoSC1,STR0006)  //"Parcialmente Atendidos"
	Aadd(aTable , {aTipoSC1[Len(aTipoSC1)] , aTitle , aSC1Parc})
	Aadd(aQtdSC1,Len(aSC1Parc))  
EndIf

If !Empty(aSC1Bloq)
	Aadd(aTipoSC1, STR0007)  //"Aguardando Liberação"
	Aadd(aTable , {aTipoSC1[Len(aTipoSC1)] , aTitle , aSC1Bloq})
	Aadd(aQtdSC1,Len(aSC1Bloq))
EndIf

If Empty(aSC1Open) .And. Empty(aSC1Parc) .And. Empty(aSC1Bloq)
	Aadd(aTipoSC1, STR0010)  //"Nao foram encotradas Solicitações de Compras em Aberto"
	Aadd(aTable , {aTipoSC1[Len(aTipoSC1)] , aTitle , {{" "," "," "," "}} })
	Aadd(aQtdSC1,1)
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Preenche array do Painel de Gestao                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aPanel:= {GRP_PIE, {STR0008,/*bClickG*/,aTipoSC1,aQtdSC1}, ;  //"Solicitações de Compras em Aberto"
{STR0009,{ |x| COMPView04( x[1] ) },aTable}} //"Solicitações de Compras"
			
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Apaga os arquivos de trabalho, cancela os filtros e restabelece as ordens originais.|
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lQuery
	dbSelectArea(cAliasSC1)
	dbCloseArea()
Else
  	dbSelectArea("SC1") 
	RetIndex("SC1") 
	dbClearFilter()
	Ferase(cIndSC1+OrdBagExt())
EndIf

Return aPanel 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³COMPView04³ Autor ³Alexandre Inacio Lemes ³ Data ³ 06/02/2007 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Consulta os documentos de Solicitacao de Compras              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ ComPgOnl04                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/   
Function COMPView04(cSolicita)

Local aArea := GetArea()

dbSelectArea("SC1")
dbSetOrder(1)
If MsSeek(xFilial("SC1")+Substr(cSolicita,1,len(SC1->C1_NUM)))
	INCLUI := .F.
	ALTERA := .F.
//	Mata110(NIL,NIL,2) // Aguardando Depto de tecnologia para definicao das regras para chamadas dos programas. 06/02/2007 
EndIf

RestArea(aArea)

Return
