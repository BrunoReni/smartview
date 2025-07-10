#INCLUDE "MATA119.CH" 
#INCLUDE "PROTHEUS.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ MATA119  ³ Autor ³ Edson Maricate         ³ Data ³14.03.2000³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa de Digitacao de Despesas de Importacao             ³±±
±±³          ³ Utiliza a funcao MATA103 p/ gerar a Nota Fiscal de Entrada  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function MATA119()

Local lInclui	:= .T.
Local lRet		:= .T.

&("M->F1_CHVNFE") := ""

//Checa a assinatura dos fontes complementares estão corretos.
lRet := A119ChkSig()

If lRet
	While lInclui 
		Mata119A(@lInclui)
	EndDo
Endif

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ MATA119  ³ Autor ³ Edson Maricate         ³ Data ³14.03.2000³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa de Digitacao de Despesas de Importacao             ³±±
±±³          ³ Utiliza a funcao MATA103 p/ gerar a Nota Fiscal de Entrada  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Mata119A(lInclui)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local cFiltro    := ""
Local cQuery     := ""
Local cFornOri   := ""
Local cLojaOri   := ""
Local nTipoOri   := 0
Local aIndexSF1  := {}
Local lContinua  := .T.
Local lMT119FLT	   := (ExistBlock("MT119FLT"))
Local dDataIni	   := dDataBase
Local dDataFim	   := dDataBase   
Local aUsButtons   := {}
Local aMT119FLT    := {}
Local lPergMTA119  := .T.
Local bIniWndw    := {|| A119ClrMk() }
Local nX		  := 0
If cPaisLoc <> "BRA"
	Aviso("",STR0001,{"OK"},2,STR0002) //"Use a rotina de inclusao de notas de entrada, selecionado o tipo FRETE, para incluir notas fiscais de despesa de importacao. "###"Rotina fora de uso"
	lContinua := .F.
EndIf
PRIVATE lAglutProd	 := .F.
PRIVATE bFiltraBrw	 := {|| Nil}
PRIVATE cCadastro	 := STR0003 //"Despesa de Importação"
PRIVATE oFoco103
PRIVATE dEmisOld     := ""
PRIVATE cCA100ForOld := ""
PRIVATE cCondicaoOld := ""
PRIVATE aTrocaF3	 := {}
PRIVATE aNFEDanfe    := {}
PRIVATE aDanfeComp   := {} 
PRIVATE lGeraComFi	 := .F.
PRIVATE cMarca:= GetMark()
PRIVATE aRotina := {}
Private aRecMark := {}
// Variaveis utilizadas no MATA103
PRIVATE aCompFutur := {}
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³   01 -  Data Inicial         mv_par01            ³
//³   02 -  Data Final           mv_par02            ³
//³   03 -  Quanto a Nota        mv_par03 GeraXExclui³
//³   04 -  Fornecedor/Cliente   mv_par04            ³
//³   05 -  Loja                 mv_par05            ³
//³   06 -  Considera Notas      mv_par06 DevXNormal ³
//³   07 -  Aglutina produtos    mv_par07 Sim x Nao  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lContinua .And. Pergunte("MTA114",.T.)
	dDataIni	:= mv_par01
	dDataFim	:= mv_par02
	lGera		:= mv_par03==2
	cFornOri	:= mv_par04
	cLojaOri	:= mv_par05
	nTipoOri	:= mv_par06
	lAglutProd	:= IIf(mv_par07==1,.T.,.F.)
	lGeraComFi  := Iif(mv_par08==1,.T.,.F.)    
	aRotina := MenuDef()
	lPergMTA119 := Pergunte("MTA119",.T.)
	While lGera
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica os parametros                                       ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
		dbSelectArea("SF4")
		dbSetOrder(1)
		dbSelectArea("SF1")
		dbSetOrder(1)						
		dbSelectArea("SA2")
		dbSetOrder(1)

		If lPergMTA119
			Do Case
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Valida o codigo da TES utilizada.                            ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			Case ( mv_par02==2 .And. Empty(mv_par03) )
				Help(" ",1,"F1_DOC")	
				lContinua := .F.
				Exit
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Valida o codigo da TES utilizada.                            ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			Case Empty(mv_par07)
				Help(" ",1,"A115TES")
				lContinua := .F.
				Exit
			Case !(SF4->(MsSeek(xFilial("SF4")+mv_par07)))
				Help(" ",1,".MTA11506.")	
				lContinua := .F.
				Exit					
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Verifica se a NF ja existe.                                  ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			Case mv_par02==2 .And. lGera .And. SF1->(MsSeek(xFilial("SF1")+mv_par03+mv_par04+mv_par05+mv_par06))
				HELP(" ",1,"A100EXIST")
				lContinua := .F.
				Exit
 			Case Empty(mv_par06) .And. !(SA2->(MsSeek(xFilial("SA2")+mv_par05)))
				HELP("  ",1,"REGNOIS")
				lContinua := .F.
				Exit
 			Case !Empty(mv_par06) .And. !(SA2->(MsSeek(xFilial("SA2")+mv_par05+mv_par06)))
				HELP("  ",1,"REGNOIS")
				lContinua := .F.
				Exit
			OtherWise       
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Verifica se os Registros estao Bloqueados.³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If SA2->(RegistroOk("SA2")) .And. SF4->(RegistroOk("SF4"))
                   Exit
                EndIf                
			EndCase
		Else
			lContinua := .F.
			Exit
		EndIf	
	EndDo
	If lContinua
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Inicializa o filtro															³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea("SF1")
		dbSetOrder(1)
		cFiltro	:= "F1_FILIAL=='"+xFilial("SF1")+"' .AND. "
		cFiltro += "!EMPTY(F1_STATUS) .AND. "
		cFiltro	+= "DTOS(F1_DTDIGIT)>='"+DTOS(dDataIni)+"' .AND. "
		cFiltro 	+= "DTOS(F1_DTDIGIT)<='"+DTOS(dDataFim)+"' .AND. "
		If !lGera 	// Exclusao
			cFiltro	+="F1_TIPO=='C'.AND.F1_ORIGLAN==' D'"
		Else			// Inclusao
			If nTipoOri==1
				cFiltro	+= "F1_TIPO=='N'"
			Else
				cFiltro	+="F1_TIPO$'DB'"
			EndIf
		EndIf
		If !Empty(cFornOri).And.!Empty(cLojaOri)
			cFiltro	+= ".AND.F1_FORNECE=='"+cFornOri+"'.AND.F1_LOJA=='"+cLojaOri+"'"
		EndIf
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Ponto de Entrada para Verificar a existencia de Filtros na mBrowse ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lMT119FLT
			aMT119FLT := ExecBlock("MT119FLT",.F.,.F.,{cFiltro,cQuery})
				         						
			If valtype(aMT119FLT) == "A"
				if len(aMT119FLT) >= 1 .And. valtype(aMT119FLT[1]) == "C"
					cFiltro:= aMT119FLT[1]
				EndIf
				if len(aMT119FLT) >= 2 .And. valtype(aMT119FLT[2]) == "C"
					cQuery:= aMT119FLT[2]
				EndIf			
			EndIf
		EndIf


		SF1->(dbSeek(xFilial("SF1")))
		If SF1->(Eof())
			HELP(" ",1,"RECNO")
		Else
			If !lGera
				mBrowse( 6, 1,22,75,"SF1",,,,,,,,,,,,,,cQuery,,,,cFiltro)
			Else
				MarkBrow("SF1","F1_OK","",,.F.,cMarca,'A119Mark("'+cMarca+'", .T.)',,,,'A119Mark("'+cMarca+'", .F.)',bIniWndw,cQuery,,,,,cFiltro)
				For nX := 1 To Len(aRecMark) 
					SF1->(dbGoto(aRecMark[nX]))   
					RecLock("SF1",.F.)
					SF1->F1_OK := Space(Len(SF1->F1_OK))   
					SF1->(MsUnlock())
			    Next nX
			EndIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Ponto de Entrada apos a escolha das notas                           ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If ExistBlock('MT115MRK')
				ExecBlock('MT115MRK', .F., .F.)
			EndIf			
		EndIf	
	
	EndIf
Else
	lInclui := .F.
EndIf
Return .T.
/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³A119Inclui³ Autor ³Edson Maricate         ³ Data ³27.03.2000 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³Rotina de inclusao de Despesa de importacao                  ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1: Alias do Arquivo                                      ³±±
±±³          ³ExpC2: Nome do campo utilizado como marca                    ³±±
±±³          ³ExpN3: Opcao selecionada no aRotina                          ³±±
±±³          ³ExpC4: Marca utilizada na Markbrowse                         ³±±
±±³          ³ExpL5: Flag de indicativo de inversao da marca               ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                       ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Esta rotina tem como objetivo efetuar o rateio das despesas  ³±±
±±³          ³de importacao sobre as notas de entrada.                     ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Materiais                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
FUNCTION A119Inclui(cAlias,cCampo,nOpcX,cMarca,lInverte)

Local lContinua	 := .T.
Local l119Inclui := .F.
Local l119Exclui := .F.
Local l119Visual := .F.
Local lQuery     := .F.
Local lDigita    := .F.
Local lAglutina  := .F.
Local lGeraLanc  := .F.
Local lMT119QRY	 := (ExistBlock("MT119QRY"))
Local lMT119FIL	 := (ExistBlock("MT119FIL"))
Local lM119ACOL	 := (ExistBlock("M119ACOL"))
Local lMT119SX5  := ExistBlock("MT119SX5")
Local lMA119BUT  := ExistBlock("MA119BUT" )
Local lMT119AGR  := ExistBlock("MT119AGR")
Local lProcSD1	 := .T.
Local lAviso     := .T.
Local lSubSerie  := cPaisLoc == "BRA" .And. SF1->(ColumnPos("F1_SUBSERI")) > 0 .And. SuperGetMv("MV_SUBSERI",.F.,.F.)
Local lTrbGen    := IIf(FindFunction("ChkTrbGen"),ChkTrbGen("SD1", "D1_IDTRIB"),.F.) // Verifica se esta preparado para o motor de tributos genericos
Local lIntMnt    := SuperGetMV("MV_NGMNTES",.F.,"N") == "S" .Or. SuperGetMV("MV_NGMNTCM",.F.,"N") == "S"
Local lGravaOri  := .F.
Local bCabOk     := {|| .T.}
Local bIPRefresh:= {|| MaFisToCols(aHeader,aCols,,"MT100"),Eval(bRefresh),Eval(bGdRefresh)}	// Carrega os valores da Funcao fiscal e executa o Refresh
Local cItemSDE	 := ""
Local cPrefixo 	 := If(Empty(SF1->F1_PREFIXO),&(GetMV("MV_2DUPREF")),SF1->F1_PREFIXO)
Local cItem		 := ""
Local cQuery     := ""
Local cAliasSF1  := "SF1"
Local cAliasSF3  := "SF3"
Local cAliasSF8  := "SF8"
Local cAliasSD1  := "SD1"
Local cAliasSDE  := "SDE"
Local cAliasSE2  := "SE2" 
Local cFiltraSD1 := ""
Local cIndex     := "" 
Local cCond      := "" 
Local cVarFoco   := "     "                
Local xFilBrw    := nil
Local nTpRodape  := 0
Local nPClaFis   := 0
Local nPesoTotal := 0
Local nTotRateio := 0
Local nOpcA		 := 0
Local nUsado	 := 0
Local nVlrTotal	 := 0
Local nDifTotal	 := 0
Local nPItem     := 0
Local nPProduto  := 0
Local nPNumCQ    := 0
Local nPConta    := 0
Local nPItemCta  := 0
Local nPCCusto   := 0
Local nPPeso     := 0
Local nPLocal    := 0
Local nPTotal    := 0
Local nPVlUnit   := 0
Local nPosCF     := 0
Local nPTes      := 0
Local nPUM       := 0
Local nPSegum    := 0
Local nPicms     := 0
Local nPipi      := 0
Local nPClvl     := 0
Local nPosNfOri  := 0
Local nPosSeriOri:= 0
Local nPosItemOri:= 0
Local nPosCodlan := 0
Local nPosOP     := 0
Local nPosOrd    := 0
Local cModRetPIS 	:= GetNewPar( "MV_RT10925", "1" )
Local lPCCBaixa 	:= SuperGetMv("MV_BX10925",.T.,"2") == "1"
Local lCat8309 		:= SuperGetMv("MV_CAT8309",.F.,.F.)
Local cCQ 			:= SuperGetMv("MV_CQ")
Local cRatDesp	    := GetMV("MV_RATDESP")
Local nRatDesp   := Val(SubStr(cRatDesp,At("DESP=",cRatDesp)+5,1))
Local nRatFrete  := Val(SubStr(cRatDesp,At("FR=",cRatDesp)+3,1))
Local nRatSeg    := Val(SubStr(cRatDesp,At("SEG=",cRatDesp)+4,1))
Local nX         := 0
Local nY         := 0
Local nZ         := 0
Local nw         := 0
Local nMaxItem   := 0
Local nItemSDE   := 0
Local nIndexSE2  := 0 
Local nRecSF1	 := 0
Local nInfDiv    := 0
Local nPosGetLoja:= IIF(TamSX3("A2_COD")[1]< 10,(2.5*TamSX3("A2_COD")[1])+(110),(2.8*TamSX3("A2_COD")[1])+(100))
Local nTrbGen    := 0
Local nColsSE2   := 0
Local dCtbValiDt := Ctod("")
Local aRecSD1	 := {}
Local aRecSE2	 := {}
Local aRecSF3	 := {}
Local aRecSF8	 := {}
Local aRecSDE	 := {}
Local aRecSF1Ori := {}
Local aCPOS2     := {"D1_VUNIT","D1_TOTAL","D1_PICM","D1_IPI","D1_CONTA","D1_CC","D1_VALICM","D1_CF","D1_TES","D1_BASEICM","D1_BASEIPI","D1_VALIPI","D1_ITEMCTA","D1_CLVL","D1_CLASFIS","D1_BASEISS","D1_ALIQISS","D1_VALISS"}
Local aCpoUsr    := {"D1_OP","D1_ORDEM"}
Local aChave 	 := Array(4)
Local aInfo 	 := {}
Local aPosGet	 := {}
Local aPosObj	 := {}
Local aAmarrAFN	 := {}
Local aInfForn	 := {"","",CTOD("  /  /  "),CTOD("  /  /  "),"","","",""}
Local aValores	 := {0,0,0,0,0,0,0,0,0,0}
Local aTitles	 := {	STR0008,; //"Totais"
						STR0009,; //"Inf. Fornecedor/Cliente"
						STR0010,; //"Descontos/Frete/Despesas"
						STR0011,; //"Impostos"
						STR0012,; //"Livros Fiscais"
						STR0013}	 //"Duplicatas"
Local aButtons	 := { {'S4WB013N',{||NfeRatCC(aHeadSDE,aColsSDE,l119Inclui)},STR0015, STR0014} }
Local aUsButtons := {}
Local aSizeAut	 := MsAdvSize(,.F.,400)
Local aStruSD1   := {}
Local aStruSF1   := {}
Local aStruSF8   := {}
Local aStruSDE   := {}
Local aStruSF3   := {}
Local aStruSE2   := {}
Local aHeadSE2   := {}
Local aHeadSEV   := {}
Local aBackSDE   := {}
Local aHeadSDE	 := {}
Local aColsSDE   := {}
Local aColsSE2   := {}
Local aColsSEV   := {}
Local aNotas     := {}
Local aItIcm     := {}
Local aCtbInf    := {}	//Array contendo os dados para contabilizacao online:
						//		[1] - Arquivo (cArquivo)
						//		[2] - Handle (nHdlPrv)
						//		[3] - Lote (cLote)
						//      [4] - Habilita Digitacao (lDigita)
						//      [5] - Habilita Aglutinacao (lAglutina)
						//      [6] - Controle Portugal (aCtbDia)
						//		[7,x] - Campos flags atualizados na CA100INCL
						//		[7,x,1] - Descritivo com o campo a ser atualizado (FLAG)
						//		[7,x,2] - Conteudo a ser gravado na flag
						//		[7,x,3] - Alias a ser atualizado
						//		[7,x,4] - Recno do registro a ser atualizado

Local aColTrbGen := {}
Local aParcTrGen := {}
Local lTemICM    := .F.
Local aFldCBAtu  := Array(Len(aTitles))
Local oDlg
Local oGetDados
Local oLivro
Local oSize         := nil
Local cFornIss		:= Space(Len(SE2->E2_FORNECE))
Local cLojaIss		:= Space(Len(SE2->E2_LOJA))
Local dVencISS		:= CtoD("")
Local aCodR			:=	{}
Local cRecIss		:=	"1"
Local oRecIss
Local aAUTOISS		:= &(GetNewPar("MV_AUTOISS",'{"","","",""}'))
Local oCombo
Local oCodRet
Local nCombo		:= 2
Local lMemo
Local aPages	 	:= {"HEADER"}
Local lRet			:= .T.
Local lUsaNewKey:= TamSX3("F1_SERIE")[1] == 14 // Verifica se o novo formato de gravacao do Id nos campos _SERIE esta em uso
Local cSerieId := ""
Local cTplGeraComFi := Type("lGeraComFi")
Local l119NotReg	:= .F.

Private lDKD		:= ChkFile("DKD") //Tabela Complementar SD1
Private lTabAuxD1	:= .F.
Private aHeadDKD	:= {}
Private aColsDKD	:= {}
Private aAltDKD		:= {}
Private oGetDKD		:= Nil

//Verifica se selecionou algum documento
If Len(aRecMark) == 0 .And. lGera  
	Help(" ",1,"A119NOTREG",,STR0022,1,0) //"Selecione documento para geração da despesa."
	l119NotReg	:= .T.
	lContinua	:= .F.
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Adiciona a Aba Danfe                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lContinua .And. cPaisLoc == "BRA"
    Aadd(aTitles,STR0017)
	aAdd(aFldCBAtu,Nil)
	nInfDiv := 	Len(aTitles)
	A103CargaDanfe()
	If Len(aNfeDanfe)>0
		aNfeDanfe[1] := CriaVar("F1_TRANSP")
		aNfeDanfe[2] := CriaVar("F1_PLIQUI")
		aNfeDanfe[3] := CriaVar("F1_PBRUTO")
		aNfeDanfe[4] := CriaVar("F1_ESPECI1")
		aNfeDanfe[5] := CriaVar("F1_VOLUME1")
		aNfeDanfe[13]:= CriaVar("F1_CHVNFE")
	EndIf 
EndIf

If lContinua .And. lTrbGen
	Aadd(aTitles,STR0018) // "Tributos Genéricos"
	nTrbGen := Len(aTitles)
	aAdd(aFldCBAtu,Nil) 
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ CAT83 - Permite Manutenção no aCols  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lContinua .And. V103CAT83()
    aaDD(aCpos2,"D1_CODLAN")
EndIf

If lContinua .And. lPccBaixa
	cModRetPis := "3"
EndIf

Private lReajuste  := .F.
Private lAmarra    := .F.
Private lConsLoja  := .F.
Private lPrecoDes  := .F.
Private lDataUCOM  := .F.
Private lAtuAmarra := .F.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Carrega as perguntas utilizadas no mata103              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Pergunte("MTA103",.F.)
lDigita     := mv_par01==1
lAglutina   := mv_par02==1
lGeraLanc   := mv_par06==1
lReajuste   := mv_par04==1
lAmarra     := mv_par05==1
lConsLoja   := mv_par07==1
IsTriangular ( mv_par08==1 )
nTpRodape   := mv_par09
lPrecoDes   := mv_par10==1
lDataUcom   := mv_par11==1
lAtuAmarra  := mv_par12==1

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Carrega as perguntas utilizadas no processamento.       ³
//³ mv_par01 - Valor Total do Frete                         ³
//³ mv_par02 - Formulario Proprio  1-Sim     2-Nao          ³
//³ mv_par03 - Numero da despesa de importacao              ³
//³ mv_par04 - Serie do Despesa                             ³
//³ mv_par05 - Cod. Fornecedor de Transp.                   ³
//³ mv_par06 - Loja do Fornecedor de Transp.                ³
//³ mv_par07 - TES da NF de Frete                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Pergunte("MTA119",.F.)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define a funcao utilizada ( Incl.,Alt.,Visual.,Exclu.)  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private l103Visual := .F.
Private INCLUI     := .F.

Do Case
Case aRotina[nOpcx][4] == 6
	l119Inclui := .T.
	l103Visual := .F.
	INCLUI     := .T.
	SA2->(MsSeek(xFilial("SA2")+mv_par05+mv_par06))
Case aRotina[nOpcx][4] == 5
	l119Exclui := .T.
	l103Visual := .T.
	INCLUI     := .F.
	nRecSF1	  := SF1->(RecNo())
OtherWise
	l119Visual	       := .T.
	l103Visual := .T.
	INCLUI     := .F.
	nRecSF1    := SF1->(RecNo())
EndCase

PRIVATE	aCols		:= {}
PRIVATE	aHeader 	:= {}
PRIVATE	cTipo		:= IIf(l119Inclui,"C",SF1->F1_TIPO)
PRIVATE	cTpCompl	:= ""
PRIVATE	cFormul		:= IIf(l119Inclui,IIf(mv_par02==1,"S","N"),SF1->F1_FORMUL)
PRIVATE	cNFiscal 	:= IIf(l119Inclui,IIf(cFormul=="S",CriaVar("F1_DOC",.F.),mv_par03),SF1->F1_DOC)
PRIVATE	cSerie		:= IIf(l119Inclui,IIf(cFormul=="S",SerieNfId("SF1",5,"F1_SERIE"),mv_par04),SerieNfId("SF1",2,"F1_SERIE"))
PRIVATE	cSubSerie   := ""
Private dDEmissao   := IIf(l119Inclui,dDataBase,SF1->F1_EMISSAO)
PRIVATE	cA100For	:= IIf(l119Inclui,mv_par05,SF1->F1_FORNECE)
PRIVATE	cLoja		:= IIf(l119Inclui,mv_par06,SF1->F1_LOJA)
PRIVATE	cEspecie	:= IIf(l119Inclui,CriaVar("F1_ESPECIE"),SF1->F1_ESPECIE)
PRIVATE	cCondicao  := IIf(l119Inclui,SA2->A2_COND,SF1->F1_COND)
PRIVATE n           := 1
PRIVATE nMoedaCor   := 1
PRIVATE aRatVei     := {}
PRIVATE aRatFro     := {}
PRIVATE aArraySDG   := {}
PRIVATE aRatAFN     := {}

PRIVATE bRefresh  := {|nX| NfeFldChg(nX,nY,,aFldCBAtu)}
PRIVATE bGDRefresh:= {|| IIf(oGetDados<>Nil,(oGetDados:oBrowse:Refresh()),.F.) }		// Efetua o Refresh da GetDados
PRIVATE oFisRod
PRIVATE oFisTrbGen
PRIVATE cDirf		:= Space(Len(SE2->E2_DIRF))
PRIVATE cCodRet		:= Space(Len(SE2->E2_CODRET))
PRIVATE lMudouNum   := .F. 	
PRIVATE	nValDesp   	:= MV_PAR01
PRIVATE cCfop       := ""
PRIVATE cForAntNFE	:= ""
PRIVATE cLojAntNFE 	:= ""

If lContinua .And. SF1->(ColumnPos("F1_TPCOMPL")) > 0
	cTpCompl	:= IIF(l119Inclui,"",SF1->F1_TPCOMPL)
EndIf

If lContinua .And. lSubSerie
	cSubSerie := IIF(l119Inclui,CriaVar("F1_SUBSERI"),SF1->F1_SUBSERI)
EndIf

If lContinua .And. ( Type("aNFEDanfe") == "U" )
	PRIVATE aNFEDanfe := {}
EndIf

If lContinua .And. ( Type("aDanfeComp") == "U" )
	PRIVATE aDanfeComp:= {}
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Preenche automaticamente o fornecedor/loja ISS atraves do parâmetro                   ³
//³MV_AUTOISS = {Fornecedor,Loja,Dirf,CodRet}                                            ³
//³Apenas efetua o processamento se todas as posicoes do parametro estiverem preenchidas ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lContinua .And. aAUTOISS <> NIL .And. Len(aAUTOISS) == 4	//Sempre vai entrar, o default eh todas as posicoes do array vazio, porem quando for 
		   										//	vazio temos de manter a qtd de caracteres definidas na declaracao LOCAL das variaveis cFornIss, 
												//	cLojaIss, cDirf e cCodRet, senao nao eh permitido a digitacao no rodape da NF devido ao tamanho 
												//	ser ZERO (declaracao LOCAL do aAUTOISS).
	cFornIss	:= Iif (Empty (aAUTOISS[01]), cFornIss, aAUTOISS[01])
	cLojaIss	:= Iif (Empty (aAUTOISS[02]), cLojaIss, aAUTOISS[02])
	cDirf		:= Iif (Empty (aAUTOISS[03]), cDirf, aAUTOISS[03])
	cCodRet		:= Iif (Empty (aAUTOISS[04]), cCodRet, aAUTOISS[04])
	
	If !Empty( cCodRet )
		If aScan( aCodR, {|aX| aX[4]=="IRR"})==0
			aAdd( aCodR, {99, cCodRet, 1, "IRR"} )
		Else
			aCodR[aScan( aCodR, {|aX| aX[4]=="IRR"})][2]	:=	cCodRet
		EndIf
	EndIf

	// Somente ira preencher se o cadastro no SA2 existir
	If !SA2->(MsSeek(xFilial("SA2")+cFornIss+cLojaIss))
		cFornIss := Space(Len(SE2->E2_FORNECE))
		cLojaIss := Space(Len(SE2->E2_LOJA))
	Endif         
	
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica o numero maximo de itens da nota fiscal           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lContinua
	nMaxItem   := a460NumIt(cSerie,.T.)
	If l119Inclui
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Validacoes para Inclusao/Classificacao de NF de Entrada    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cCadastro := STR0003
		If !NfeVldIni(.F.,lGeraLanc)
			lContinua := .F.
		EndIf
	ElseIf l119Exclui
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Validacoes para Exclusao de NF de Entrada.                 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !MaCanDelF1(nRecSF1,Nil,@aRecSE2,Nil,.T.)
			lContinua := .F.
		EndIf
	EndIf
Endif

If lContinua 
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Montagem do aHeader                                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("SX3")
	dbSetOrder(1)
	MsSeek("SD1")
	While !Eof() .And. (SX3->X3_ARQUIVO == "SD1")
		IF X3Uso(SX3->X3_USADO) .AND. cNivel >= SX3->X3_NIVEL .And. AllTrim(SX3->X3_CAMPO) <> "D1_GERAPV"
		
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ CAT83 - Nao adiciona campo ao aCols se parametro estiver desligado  | 
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If Trim(SX3->X3_CAMPO)="D1_CODLAN" .And. !lCat8309 		
				dbSelectArea("SX3")
				dbSkip()
			EndIF
			
			nUsado++
			aadd(aHeader,{ TRIM(X3Titulo()),;
				SX3->X3_CAMPO,;
				SX3->X3_PICTURE,;
				SX3->X3_TAMANHO,;
				SX3->X3_DECIMAL,;
				SX3->X3_VALID,;
				SX3->X3_USADO,;
				SX3->X3_TIPO,;
				SX3->X3_ARQUIVO,;
				SX3->X3_CONTEXT})
			If SX3->X3_PROPRI =="U" .And. SX3->X3_VISUAL <> "V"
				aadd(aCpos2,Alltrim(SX3->X3_CAMPO))
				aadd(aCpoUsr,Alltrim(SX3->X3_CAMPO))
			EndIf
			If Subs(alltrim(SX3->X3_CAMPO),3) == "_ITEM"
				nPItem := nUsado
			ElseIf Subs(alltrim(SX3->X3_CAMPO),3) == "_COD"
				nPProduto := nUsado
			ElseIf Subs(alltrim(SX3->X3_CAMPO),3) == "_TOTAL"
				nPTotal := nUsado
			ElseIf Subs(alltrim(SX3->X3_CAMPO),3) == "_VUNIT"
				nPVlUnit  := nUsado
			ElseIf Subs(alltrim(SX3->X3_CAMPO),3) == "_TES"
				nPTes  := nUsado
			ElseIf Subs(alltrim(SX3->X3_CAMPO),3) == "_UM"
				nPUM  := nUsado
			ElseIf Subs(alltrim(SX3->X3_CAMPO),3) == "_SEGUM"
				nPSegum  := nUsado
			ElseIf Subs(alltrim(SX3->X3_CAMPO),3) == "_NUMCQ"
				nPNumCQ:= nUsado
			ElseIf Subs(alltrim(SX3->X3_CAMPO),3) == "_LOCAL"
				nPLocal  := nUsado
			ElseIf Subs(alltrim(SX3->X3_CAMPO),3) == "_PESO"
				nPPeso := nUsado
			ElseIf Subs(alltrim(SX3->X3_CAMPO),3) == "_CONTA"
				nPConta := nUsado
			ElseIf Subs(alltrim(SX3->X3_CAMPO),3) == "_ITEMCTA"
				nPItemCta := nUsado
			ElseIf Subs(alltrim(SX3->X3_CAMPO),3) == "_CC"
				nPCCusto := nUsado
			ElseIf Subs(alltrim(SX3->X3_CAMPO),3) == "_PICM"
				nPicms := nUsado
			ElseIf Subs(alltrim(SX3->X3_CAMPO),3) == "_IPI"
				nPipi := nUsado
			ElseIf Subs(alltrim(SX3->X3_CAMPO),3) == "_CLVL"	
				nPClvl:= nUsado
	        ElseIf Subs(alltrim(SX3->X3_CAMPO),3) == "_CLASFIS"
		 		nPClaFis := nUsado
			ElseIf Subs(alltrim(x3_campo),3) == "_NFORI"
		        nPosNfOri := nUsado				        
			ElseIf Subs(alltrim(x3_campo),3) == "_SERIORI"
		        nPosSeriOri := nUsado				        
			ElseIf Subs(alltrim(x3_campo),3) == "_ITEMORI"
		        nPosItemOri := nUsado				        
 	  		ElseIf Subs(alltrim(x3_campo),3) == "_CODLAN"
		        nPosCodLan := nUsado
		    ElseIf Subs(alltrim(x3_campo),3) == "_CF"
	   			nPosCF := nUsado				        
		    ElseIf Subs(alltrim(x3_campo),3) == "_OP"
	   			nPosOP := nUsado
		    ElseIf Subs(alltrim(x3_campo),3) == "_ORDEM"
	   			nPosOrd := nUsado
			EndIf
		EndIf
		dbSelectArea("SX3")
		dbSkip()
	EndDo

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Adiciona os campos de Alias e Recno ao aHeader para WalkThru.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	ADHeadRec("SD1",aHeader)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica as notas de origem                                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("SF1")
	If l119Inclui
		If Empty(aStruSF1)
			aStruSF1 := SF1->(dbStruct())
		EndIf
		xFilBrw := Eval(bFiltrabrw,1)

		lQuery := .T.
		cAliasSF1 := "SF1"
		cQuery := "SELECT SF1.*,SF1.R_E_C_N_O_ SF1RECNO "
		cQuery += "FROM "+RetSqlName("SF1")+" SF1 "
		cQuery += "WHERE "
		cQuery += Iif(ValType(xFilBrw)=='C',xFilBrw + ' AND ',"")
		cQuery += "F1_OK='"+cMarca+"'  AND "
		cQuery += "SF1.D_E_L_E_T_=' ' "
		cQuery += "ORDER BY "+SqlOrder(SF1->(IndexKey()))
		cQuery := ChangeQuery(cQuery)
		
		dbSelectArea("SF1")
		dbCloseArea()
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSF1,.T.,.T.)

		For nX := 1 To Len(aStruSF1)
			If aStruSF1[nX][2] <> "C"
				TcSetField(cAliasSF1,aStruSF1[nX][1],aStruSF1[nX][2],aStruSF1[nX][3],aStruSF1[nX][4])
			EndIf
		Next nX			
		
		While !Eof()
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifica os itens marcados                                   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If xFilial("SF1") == (cAliasSF1)->F1_FILIAL .And. IsMark("F1_OK",ThisMark(),ThisInv())
				aadd(aRecSF1Ori,If(lQuery,(cAliasSF1)->SF1RECNO,SF1->(RecNo())))
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Verifica os itens da nota de origem                          ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				dbSelectArea("SD1")
				dbSetOrder(1)      
				If Empty(aStruSD1)
					aStruSD1 := SD1->(dbStruct())
				EndIf
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Verifica se existe campo MEMO          ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				lMemo := aScan(aStruSD1,{|x| x[2]=="M"})>0
				If lQuery .And. !lMemo
					cAliasSD1 := "SD1"
					cQuery := "SELECT SD1.*,SD1.R_E_C_N_O_ SD1RECNO "
					cQuery += "FROM "+RetSqlName("SD1")+" SD1 "
					cQuery += "WHERE "
					cQuery += "SD1.D1_FILIAL='"+xFilial("SD1")+"' AND "
					cQuery += "SD1.D1_DOC='"+(cAliasSF1)->F1_DOC+"' AND "
					cQuery += "SD1.D1_SERIE='"+(cAliasSF1)->F1_SERIE+"' AND "
					cQuery += "SD1.D1_FORNECE='"+(cAliasSF1)->F1_FORNECE+"' AND "
					cQuery += "SD1.D1_LOJA='"+(cAliasSF1)->F1_LOJA+"' AND "
					cQuery += "SD1.D1_FORMUL='"+(cAliasSF1)->F1_FORMUL+"' AND "
					cQuery += "SD1.D_E_L_E_T_=' ' "
					If lMT119QRY					
						cFiltraSD1 := ExecBlock("MT119QRY",.F.,.F.)
						If ValType(cFiltraSD1) == "C"
							cQuery += cFiltraSD1
						EndIf
					EndIf
					cQuery += " ORDER BY "+SqlOrder(SD1->(IndexKey()))
					cQuery := ChangeQuery(cQuery)

					dbSelectArea("SD1")
					dbCloseArea()				 	
					dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSD1,.T.,.T.)
					For nX := 1 To Len(aStruSD1)
						If aStruSD1[nX][2] <> "C"
							TcSetField(cAliasSD1,aStruSD1[nX][1],aStruSD1[nX][2],aStruSD1[nX][3],aStruSD1[nX][4])
						EndIf
					Next nX					
				Else
					MsSeek(xFilial("SD1")+(cAliasSF1)->F1_DOC+(cAliasSF1)->F1_SERIE+(cAliasSF1)->F1_FORNECE+(cAliasSF1)->F1_LOJA)
				EndIf
				// Carrega o vetor aChave com as informacoes do documento processado				   
				aChave[1]:= (cAliasSF1)->F1_DOC
				aChave[2]:= (cAliasSF1)->F1_SERIE
				aChave[3]:= (cAliasSF1)->F1_FORNECE
				aChave[4]:= (cAliasSF1)->F1_LOJA				
				While !Eof() .And. (cAliasSD1)->D1_FILIAL==xFilial("SD1") .And.;
						(cAliasSD1)->D1_DOC == (cAliasSF1)->F1_DOC .And.;
						(cAliasSD1)->D1_SERIE == (cAliasSF1)->F1_SERIE .And.;
						(cAliasSD1)->D1_FORNECE == (cAliasSF1)->F1_FORNECE .And.;
						(cAliasSD1)->D1_LOJA == (cAliasSF1)->F1_LOJA

					If (cAliasSF1)->F1_FORMUL==(cAliasSD1)->D1_FORMUL 
					
						If lMT119FIL					
							lProcSD1 := ExecBlock("MT119FIL",.F.,.F.)
							If ValType(lProcSD1) == "L" .And. !lProcSD1
								dbSelectArea(cAliasSD1)
								dbSkip()
								Loop
							EndIf
						EndIf
						If (cAliasSD1)->D1_ORIGLAN $"FD|F | D" .And. lAviso
							Aviso("",STR0016,{"OK"},2) //"Entre os itens selecionados ja existe um documento de frete e ou despesa de importacao vinculado."
				   			lAviso := .F.
				        EndIf 
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Verifica se deve aglutinar os itens da nota fiscal de entrada³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If !lAglutProd
							nX := 0
						Else
							nX	:= aScan(aCols, { |x| x[nPProduto] == (cAliasSD1)->D1_COD .And.;
								x[nPLocal] == (cAliasSD1)->D1_LOCAL .And.;
								x[nPNumCQ] == (cAliasSD1)->D1_NUMCQ })
						EndIf

						// Para integracao com SIGAMNT deve preservar OP, OS, NF, Serie e Item da nota origem
						If lIntMnt
							lGravaOri := .F.
							If !Empty((cAliasSD1)->D1_OP) .And. !Empty((cAliasSD1)->D1_ORDEM) .And. ;
								nPLocal > 0 .And. nPNumCQ > 0 .And. nPosOP > 0 .And. nPosOrd > 0 .And. nPosNfOri > 0 .And. nPosSeriOri > 0 .And. nPosItemOri > 0
								lGravaOri := .T.
								nX := aScan(aCols,{|x|	x[nPProduto] == (cAliasSD1)->D1_COD .And. x[nPLocal] == (cAliasSD1)->D1_LOCAL .And. x[nPNumCQ] == (cAliasSD1)->D1_NUMCQ .And. ;
														x[nPosOP]    == (cAliasSD1)->D1_OP  .And. x[nPosOrd] == (cAliasSD1)->D1_ORDEM .And. ;
														x[nPosNfOri] == (cAliasSD1)->D1_DOC .And. x[nPosSeriOri] == (cAliasSD1)->D1_SERIE .And. x[nPosItemOri] == (cAliasSD1)->D1_ITEM })
							EndIf
						EndIf

						If nX == 0
							aAdd(aAmarrAFN,{})
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³ Faz a montagem de uma linha em branco no aCols.              ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ						
							aadd(aCols,	Array(Len(aHeader)+1))
							nX	:= Len(aCols)
							For nY := 1 to Len(aHeader)
					            If IsHeadRec(aHeader[nY][2])
								    aCols[nX][nY] := IIf(lQuery .And. !lMemo, (cAliasSD1)->SD1RECNO , SD1->(Recno())  )
					            ElseIf IsHeadAlias(aHeader[nY][2])
								    aCols[nX][nY] := "SD1"
								ElseIf aHeader[nY,10] <> "V" .And. aScan(aCpoUsr,{|x| x==AllTrim(aHeader[nY,2])})<>0
									aCols[nX][nY] := (cAliasSD1)->(FieldGet(FieldPos(AllTrim(aHeader[nY,2]))))
								Else
									aCols[nX][nY] := CriaVar(aHeader[nY][2])
								EndIf
							Next nY
							aCols[nX][Len(aHeader)+1] := .F.
						EndIf
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Verifica os itens apontados ao SIGAPMS                    ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						dbSelectArea("AFN")
						dbSetOrder(2)
						MsSeek(xFilial()+(cAliasSD1)->D1_DOC+(cAliasSD1)->D1_SERIE+(cAliasSD1)->D1_FORNECE+(cAliasSD1)->D1_LOJA+(cAliasSD1)->D1_ITEM)
						While !Eof() .And. xFilial()+(cAliasSD1)->D1_DOC+(cAliasSD1)->D1_SERIE+(cAliasSD1)->D1_FORNECE+(cAliasSD1)->D1_LOJA+(cAliasSD1)->D1_ITEM==;
															AFN_FILIAL+AFN_DOC+AFN_SERIE+AFN_FORNEC+AFN_LOJA+AFN_ITEM
							If AFN->AFN_REVISA==PmsAF8Ver(AFN->AFN_PROJET)
								aAdd(aAmarrAFN[nx],{AFN->AFN_PROJET,AFN->AFN_REVISA,AFN->AFN_TAREFA,(cAliasSD1)->D1_TOTAL*(AFN->AFN_QUANT/(cAliasSD1)->D1_QUANT),(cAliasSD1)->D1_PESO*(AFN->AFN_QUANT/(cAliasSD1)->D1_QUANT),0,0,"",(cAliasSD1)->D1_COD})
							EndIf
							dbSelectArea("AFN")
							dbSkip()
						End
						
						dbSelectArea("SF4")
						dbSetOrder(1)	
						SF4->(DbSeek(xFilial("SF4")+MV_PAR07))
						
						If nPosCF > 0 
							aCols[nx,nPosCF] := SF4->F4_CF
						EndIf
						
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Preenche os campos com base nas notas originais              ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						aCols[nX,nPProduto] := (cAliasSD1)->D1_COD
						aCols[nX,nPLocal]   := (cAliasSD1)->D1_LOCAL
						aCols[nX,nPTes]     := MV_PAR07
						If !lAglutProd .Or. lGravaOri
							aCols[nX,nPosNfOri]  := (cAliasSD1)->D1_DOC
							aCols[nX,nPosSeriOri]:= (cAliasSD1)->D1_SERIE
							aCols[nX,nPosItemOri]:= (cAliasSD1)->D1_ITEM
						EndIf	
						If nPNumCQ <> 0
							aCols[nX,nPNumCQ]   := (cAliasSD1)->D1_NUMCQ
						EndIf
						aCols[nX,nPUM]      := (cAliasSD1)->D1_UM
						If nPSegum <> 0
							aCols[nX,nPSegum]   := (cAliasSD1)->D1_SEGUM
						EndIf
						If nPConta >0
							aCols[nX,nPConta]:= (cAliasSD1)->D1_CONTA
						EndIf
						If nPItemCta >0
							aCols[nX,nPItemCta] := (cAliasSD1)->D1_ITEMCTA
						EndIf
						If nPCCusto >0
							aCols[nX,nPCCusto] := (cAliasSD1)->D1_CC
						EndIf
						aCols[nX,nPTotal] += (cAliasSD1)->D1_TOTAL
						If nPPeso <> 0
							aCols[nX,nPPeso]  += (cAliasSD1)->D1_PESO
						EndIf
						If nPLocal > 0 .And. (cAliasSD1)->D1_LOCAL == cCQ
							aCols[nX][nPLocal] := cCQ
						EndIf
						If nPicms >0
							aCols[nX,nPicms] := (cAliasSD1)->D1_PICM
					        If (cAliasSD1)->D1_PICM == 0
						        AAdd(aItIcm,nX)
							Else
								lTemIcm := .T.
				            Endif	
						EndIf
						If nPipi >0
							aCols[nX,nPipi] := (cAliasSD1)->D1_IPI
						EndIf
						If nPClvl >0
							aCols[nX,nPClvl] := (cAliasSD1)->D1_CLVL
						EndIf
    	                If nPClaFis >0
          		        	aCols[nX,nPClaFis] := Iif((cAliasSD1)->D1_TES == MV_PAR07, (cAliasSD1)->D1_CLASFIS, SubStr((cAliasSD1)->D1_CLASFIS,1,1)+SF4->F4_SITTRIB)
                		EndIf						
                		
        				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ CAT83	                  ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ        
						If nPosCodLan >0
							aCols[nX,nPosCodLan]:=A103CAT83(nX)    
						EndIf                                 
						
						If lM119ACOL
							ExecBlock("M119ACOL",.F.,.F.,{cAliasSD1,nX,aChave})
						EndIf
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Atualiza os acumuladores do rateio                           ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						nPesoTotal += (cAliasSD1)->D1_PESO
						nVlrTotal  += (cAliasSD1)->D1_TOTAL
					EndIf
					dbSelectArea(cAliasSD1)
					dbSkip()
				EndDo
				If lQuery
					dbSelectArea(cAliasSD1)
					dbCloseArea()
					ChkFile("SD1")
					dbSelectArea("SD1")
				EndIf
			EndIf
			dbSelectArea(cAliasSF1)
			dbSkip()
		EndDo
		If lQuery
			dbSelectArea(cAliasSF1)
			dbCloseArea()
			ChkFile("SF1")
			dbSelectArea("SF1")
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Faz o rateio do frete nos itens                         ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		For nX	:= 1 To Len(aCols)
			If nRatDesp == 2 .And. nPesoTotal > 0
				aCols[nX][nPTotal]	:= NoRound((aCols[nX][nPPeso]/nPesoTotal)*mv_par01,2,@nDifTotal)
				For nw := 1 to Len(aAmarrAFN[nx])
					aAmarrAFN[nx,nw][6] := NoRound((aAmarrAFN[nx,nw][5]/nPesoTotal)*mv_par01,2)
					aAmarrAFN[nx,nw][7]	 := aCols[nX][nPTotal]
				Next nw
				If NoRound(nDifTotal,2) >= 0.01
					aCols[nX][nPTotal]	+= NoRound(nDifTotal,2)
					nDifTotal -= NoRound(nDifTotal,2)
				EndIf
				aCols[nX][nPVlUnit]	:= aCols[nX][nPTotal]
				nTotRateio += aCols[nX][nPTotal]
			Else
				aCols[nX][nPTotal]	:= NoRound((aCols[nX][nPTotal]/nVlrTotal)*mv_par01,2,@nDifTotal)

				For nw := 1 to Len(aAmarrAFN[nx])
					aAmarrAFN[nx,nw][6] := NoRound((aAmarrAFN[nx,nw][4]/nVlrTotal)*mv_par01,2)
					aAmarrAFN[nx,nw][7]	 := aCols[nX][nPTotal]
				Next nw

				If NoRound(nDifTotal,2) >= 0.01
					aCols[nX][nPTotal]	+= NoRound(nDifTotal,2)
					nDifTotal -= NoRound(nDifTotal,2)
				EndIf
				aCols[nX][nPVlUnit]	:= aCols[nX][nPTotal]
				nTotRateio += aCols[nX][nPTotal]
			EndIf
			// Acerto se houver diferenca no total rateado, ajusta no ultimo
			If nX = Len(aCols) .And. nTotRateio < mv_par01
				aCols[nX][nPTotal] += NoRound(mv_par01 - nTotRateio,2)
			EndIf
		Next nX
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Monta um Array de Notas conforme o numero de itens      ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If cFormul=="S"
			nY := 0
			For nX := 1 To Len(aCols)
				If nY==0
					aadd(aNotas,{})
				EndIf
				aadd(aNotas[Len(aNotas)],aCols[nX])
				nY++
				If nY == nMaxItem
					nY := 0
				EndIf
			Next nX
		Else
			aadd(aNotas,aCols)
		EndIf
	Else
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Trava os registros do SF1 - Exclusao                   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If l119Exclui
			If !SoftLock("SF1")
				lContinua := .F.
			EndIf
		EndIf
		If l119Visual .Or. l119Exclui
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Monta array contendo os registros fiscais SF3.          ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			dbSelectArea("SF3")
			dbSetOrder(4)

			lQuery    := .T.
			cAliasSF3 := "A119INCLUI"
			aStruSF3  := SF3->(dbStruct())
			cQuery    := "SELECT SF3.*,SF3.R_E_C_N_O_ SF3RECNO "
			cQuery    += "FROM "+RetSqlName("SF3")+" SF3 "
			cQuery    += "WHERE SF3.F3_FILIAL='"+xFilial("SF3")+"' AND "
			cQuery    += "SF3.F3_CLIEFOR='"+SF1->F1_FORNECE+"' AND "
			cQuery    += "SF3.F3_LOJA='"+SF1->F1_LOJA+"' AND "
			cQuery    += "SF3.F3_NFISCAL='"+SF1->F1_DOC+"' AND "
			cQuery    += "SF3.F3_SERIE='"+SF1->F1_SERIE+"' AND "
			cQuery    += "SF3.F3_FORMUL='"+SF1->F1_FORMUL+"' AND "
			cQuery    += "SF3.D_E_L_E_T_=' ' "
			cQuery    += "ORDER BY "+SqlOrder(SF3->(IndexKey()))

			cQuery := ChangeQuery(cQuery)

			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSF3,.T.,.T.)
			For nX := 1 To Len(aStruSF3)
				If aStruSF3[nX,2]<>"C"
					TcSetField(cAliasSF3,aStruSF3[nX,1],aStruSF3[nX,2],aStruSF3[nX,3],aStruSF3[nX,4])
				EndIf
			Next nX

		While !Eof() .And. lContinua .And.;
					xFilial("SF3") == (cAliasSF3)->F3_FILIAL .And.;
					SF1->F1_FORNECE == (cAliasSF3)->F3_CLIEFOR .And.;
					SF1->F1_LOJA == (cAliasSF3)->F3_LOJA .And.;
					SF1->F1_DOC == (cAliasSF3)->F3_NFISCAL .And.;
					SF1->F1_SERIE == (cAliasSF3)->F3_SERIE
				If Substr((cAliasSF3)->F3_CFO,1,1) < "5" .And. (cAliasSF3)->F3_FORMUL == SF1->F1_FORMUL
					aadd(aRecSF3,If(lQuery,(cAliasSF3)->SF3RECNO,SF3->(RecNo())))
				EndIf
				dbSelectArea(cAliasSF3)
				dbSkip()
			EndDo
			If lQuery
				dbSelectArea(cAliasSF3)
				dbCloseArea()
				dbSelectArea("SF3")
			EndIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Monta o Array contendo as registros do SDE           ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			dbSelectArea("SDE")
			dbSetOrder(1)		
			
			lQuery    := .T.
			aStruSDE  := SDE->(dbStruct())
			cAliasSDE := "A119INCLUI"
			cQuery    := "SELECT SDE.*,SDE.R_E_C_N_O_ SDERECNO "
			cQuery    += "FROM "+RetSqlName("SDE")+" SDE "
			cQuery    += "WHERE SDE.DE_FILIAL='"+xFilial("SDE")+"' AND "
			cQuery    += "SDE.DE_DOC='"+SF1->F1_DOC+"' AND "
			cQuery    += "SDE.DE_SERIE='"+SF1->F1_SERIE+"' AND "
			cQuery    += "SDE.DE_FORNECE='"+SF1->F1_FORNECE+"' AND "
			cQuery    += "SDE.DE_LOJA='"+SDE->DE_LOJA+"' AND "
			cQuery    += "SDE.D_E_L_E_T_=' ' "
			cQuery    += "ORDER BY "+SqlOrder(SDE->(IndexKey()))

			cQuery := ChangeQuery(cQuery)

			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSDE,.T.,.T.)
			For nX := 1 To Len(aStruSDE)
				If aStruSDE[nX,2]<>"C"
					TcSetField(cAliasSDE,aStruSDE[nX,1],aStruSDE[nX,2],aStruSDE[nX,3],aStruSDE[nX,4])
				EndIf
			Next nX
			
			While ( !Eof() .And. lContinua .And.;
					xFilial('SDE') == (cAliasSDE)->DE_FILIAL .And.;
					SF1->F1_DOC == (cAliasSDE)->DE_DOC .And.;
					SF1->F1_SERIE == (cAliasSDE)->DE_SERIE .And.;
					SF1->F1_FORNECE == (cAliasSDE)->DE_FORNECE .And.;
					SF1->F1_LOJA == (cAliasSDE)->DE_LOJA )
				If Empty(aBackSDE)
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Montagem do aHeader                                          ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					dbSelectArea("SX3")
					dbSetOrder(1)
					MsSeek("SDE")
					While ( !EOF() .And. SX3->X3_ARQUIVO == "SDE" )
						If X3USO(SX3->X3_USADO) .AND. cNivel >= SX3->X3_NIVEL .And. !"DE_CUSTO"$SX3->X3_CAMPO
							aadd(aBackSDE,{ TRIM(X3Titulo()),;
								SX3->X3_CAMPO,;
								SX3->X3_PICTURE,;
								SX3->X3_TAMANHO,;
								SX3->X3_DECIMAL,;
								SX3->X3_VALID,;
								SX3->X3_USADO,;
								SX3->X3_TIPO,;
								SX3->X3_ARQUIVO,;
								SX3->X3_CONTEXT })
						EndIf
						dbSelectArea("SX3")
						dbSkip()
					EndDo
					aHeadSDE  := aBackSDE
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Adiciona os campos de Alias e Recno ao aHeader para WalkThru.³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					ADHeadRec("SDE",aHeadSDE)
				EndIf
				aadd(aRecSDE,If(lQuery,(cAliasSDE)->SDERECNO,SDE->(RecNo())))					
				If cItemSDE <> 	(cAliasSDE)->DE_ITEMNF
					cItemSDE	:= (cAliasSDE)->DE_ITEMNF
					aadd(aColsSDE,{cItemSDE,{}})
					nItemSDE++
				EndIf
				aadd(aColsSDE[nItemSDE][2],Array(Len(aHeadSDE)+1))
				For nY := 1 to Len(aHeadSDE)
					If IsHeadRec(aHeadSDE[nY][2])
						aColsSDE[nItemSDE][2][Len(aColsSDE[nItemSDE][2])][nY] := IIf(lQuery , (cAliasSDE)->SDERECNO , SDE->(Recno())  )
					ElseIf IsHeadAlias(aHeadSDE[nY][2])
						aColsSDE[nItemSDE][2][Len(aColsSDE[nItemSDE][2])][nY] := "SDE"
					ElseIf ( aHeadSDE[nY][10] <> "V")
						aColsSDE[nItemSDE][2][Len(aColsSDE[nItemSDE][2])][nY] := (cAliasSDE)->(FieldGet(FieldPos(aHeadSDE[nY][2])))
					Else
						aColsSDE[nItemSDE][2][Len(aColsSDE[nItemSDE][2])][nY] := (cAliasSDE)->(CriaVar(aHeadSDE[nY][2]))
					EndIf
					aColsSDE[nItemSDE][2][Len(aColsSDE[nItemSDE][2])][Len(aHeadSDE)+1] := .F.
				Next nY
				dbSelectArea(cAliasSDE)
				dbSkip()
			EndDo
			If lQuery
				dbSelectArea(cAliasSDE)
				dbCloseArea()
				dbSelectArea("SDE")
			EndIf
		EndIf
		If l119Exclui .And. lContinua
			aRecSF8	:=	A119GetSF8()
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Monta o Array contendo as duplicatas SE2             ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If l119Visual .Or. l119Exclui
			If Empty(aRecSE2)
				dbSelectArea("SE2")
				dbSetOrder(6)

				lQuery    := .T.
				aStruSE2  := SE2->(dbStruct())
				cAliasSE2 := "A119INCLUI"
				cQuery    := "SELECT SE2.*,SE2.R_E_C_N_O_ SE2RECNO "
				cQuery    += "FROM "+RetSqlName("SE2")+" SE2 "
				cQuery    += "WHERE SE2.E2_FILIAL='"+xFilial("SE2")+"' AND "
				cQuery    += "SE2.E2_FORNECE='"+SF1->F1_FORNECE+"' AND "
				cQuery    += "SE2.E2_LOJA='"+SF1->F1_LOJA+"' AND "
				cQuery    += "SE2.E2_PREFIXO='"+cPrefixo+"' AND "
				cQuery    += "SE2.E2_NUM='"+SF1->F1_DUPL+"' AND "
				cQuery    += "SE2.E2_TIPO='NF ' AND "
				cQuery    += "SE2.D_E_L_E_T_=' ' "
				cQuery    += "ORDER BY "+SqlOrder(SE2->(IndexKey()))

				cQuery := ChangeQuery(cQuery)

				dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSE2,.T.,.T.)
				For nX := 1 To Len(aStruSE2)
					If aStruSE2[nX][2]<>"C"
						TcSetField(cAliasSE2,aStruSE2[nX][1],aStruSE2[nX][2],aStruSE2[nX][3],aStruSE2[nX][4])
					EndIf
				Next nX

				While ( !Eof() .And. lContinua .And.;
						xFilial("SE2") == (cAliasSE2)->E2_FILIAL .And.;
						SF1->F1_FORNECE == (cAliasSE2)->E2_FORNECE .And.;
						SF1->F1_LOJA == (cAliasSE2)->E2_LOJA .And.;
						cPrefixo == (cAliasSE2)->E2_PREFIXO .And.;
						SF1->F1_DUPL == (cAliasSE2)->E2_NUM )
					If (cAliasSE2)->E2_TIPO == "NF "
						aadd(aRecSE2,If(lQuery,(cAliasSE2)->SE2RECNO,(cAliasSE2)->(RecNo())))
					EndIf
					dbSelectArea(cAliasSE2)
					dbSkip()
				EndDo
				If lQuery
					dbSelectArea(cAliasSE2)
					dbCloseArea()
					dbSelectArea("SE2")
				EndIf
			EndIf
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Faz a montagem do aCols com os dados do SD1                  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea("SD1")
		dbSetOrder(1)

		lQuery    := .T.
		cAliasSD1 := "A119INCLUI"
		aStruSD1  := SD1->(dbStruct())
		cQuery    := "SELECT SD1.*,SD1.R_E_C_N_O_ SD1RECNO "
		cQuery    += "FROM "+RetSqlName("SD1")+" SD1 "
		cQuery    += "WHERE SD1.D1_FILIAL='"+xFilial("SD1")+"' AND "
		cQuery    += "SD1.D1_DOC='"+SF1->F1_DOC+"' AND "
		cQuery    += "SD1.D1_SERIE='"+SF1->F1_SERIE+"' AND "
		cQuery    += "SD1.D1_FORNECE='"+SF1->F1_FORNECE+"' AND "
		cQuery    += "SD1.D1_LOJA='"+SF1->F1_LOJA+"' AND "
		cQuery    += "SD1.D1_FORMUL='"+SF1->F1_FORMUL+"' AND "
		cQuery    += "SD1.D_E_L_E_T_=' ' "
		cQuery    += "ORDER BY "+SqlOrder(SD1->(IndexKey()))

		cQuery := ChangeQuery(cQuery)

		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSD1,.T.,.T.)
		For nX := 1 To Len(aStruSD1)
			If aStruSD1[nX][2]<>"C"
				TcSetField(cAliasSD1,aStruSD1[nX][1],aStruSD1[nX][2],aStruSD1[nX][3],aStruSD1[nX][4])
			EndIf
		Next nX

		While ( !Eof().And. lContinua .And. ;
				(cAliasSD1)->D1_FILIAL== xFilial("SD1") .And. ;
				(cAliasSD1)->D1_DOC == SF1->F1_DOC .And. ;
				(cAliasSD1)->D1_SERIE == SF1->F1_SERIE .And. ;
				(cAliasSD1)->D1_FORNECE == SF1->F1_FORNECE .And. ;
				(cAliasSD1)->D1_LOJA == SF1->F1_LOJA )

			aadd(aRecSD1,If(lQuery,{(cAliasSD1)->SD1RECNO,(cAliasSD1)->D1_ITEM},{(cAliasSD1)->(RecNo()),(cAliasSD1)->D1_ITEM}))

			aadd(aCols,Array(Len(aHeader)+1))

			For nY := 1 To Len(aHeader)
				If IsHeadRec(aHeader[nY][2])
					aCols[Len(aCols)][nY] := IIf(lQuery , (cAliasSD1)->SD1RECNO , SD1->(Recno())  )
				ElseIf IsHeadAlias(aHeader[nY][2])
					aCols[Len(aCols)][nY] := "SD1"
				ElseIf ( aHeader[nY][10] <> "V")
					aCols[Len(aCols)][nY] := FieldGet(FieldPos(aHeader[nY][2]))
				Else
					aCols[Len(aCols)][nY] := CriaVar(aHeader[nY][2])
				EndIf
				aCols[Len(aCols)][Len(aHeader)+1] := .F.
			Next nY
			dbSelectArea(cAliasSD1)
			dbSkip()
		EndDo
		
		If lQuery
			dbSelectArea(cAliasSD1)
			dbCloseArea()
			dbSelectArea("SD1")
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Monta um Array de Notas conforme o numero de itens      ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aadd(aNotas,aCols)
	EndIf

	If lContinua .And. Len(aNotas[1])>0
		For nX := 1 To Len(aNotas)
			If nX >= 2 .And. cFormul == "S"
				If lMT119SX5
					cNFiscal := ExecBlock("MT119SX5",.F.,.F.,{cSerie})
					If ValType(cNFiscal) <> "C" .Or. Empty(cNFiscal)
						nOpcA	 := 0
						cNFiscal := Space(Len(SF1->F1_DOC))
					EndIf
				Else
					cSerieId := IIf( lUsaNewKey , SerieNfId("SF1",4,"F1_SERIE",dDataBase,cEspecie,cSerie),cSerie )
					cNFiscal := NxtSX5Nota(cSerie,,,,,,cSerieId)
				EndIf
			EndIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Inicializa a funcao fiscal                                   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			MaFisIni(cA100For,cLoja,"F","C","R",MaFisRelImp("MT100",{"SD1","SF1"}),"D",!l119Exclui,,,,,,,,,,,,,,,,,,,,,,,,,lTrbGen)
			
			If l103Visual .Or. l119Exclui
				If !Empty( MaFisScan("NF_RECISS",.F.) )
					MaFisAlt("NF_RECISS",SF1->F1_RECISS)
					cRecIss	:=	MaFisRet(,"NF_RECISS")
				EndIf
			EndIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Recupera o acols desta nota e renumera os itens              ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
			aCols := aNotas[nX]
			If l119Inclui
				cItem := StrZero(0,Len(SD1->D1_ITEM))
				For nY := 1 To Len(aCols)
					cItem := Soma1(cItem,Len(SD1->D1_ITEM))
					aCols[nY][nPItem]   := cItem
					For nw := 1 to Len(aAmarrAFN[ny])
						aAmarrAFN[ny,nw][8]	 := cItem
					Next nw
				Next nY
			EndIf
			MaColsToFis(aHeader,aCols,,"MT100",.T.)

			If l119Inclui .And. lTemICM
			    For nZ := 1 to Len(aItIcm)             
			        MaFisAlt("IT_ALIQICM",0,aItIcm[nZ])
			    Next	    
			Endif	
		
			MaFisToCols(aHeader,aCols,,"MT100")

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Inicializa a gravacao dos lancamentos do SIGAPCO          ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			PcoIniLan("000054")

			If lDKD //Tem DKD, verifica se tem campos adicionais para serem apresentados
				lTabAuxD1 := A103DKD(.F.,l103Visual) //MATA103COM
			Endif

			If nOpcA == 0     
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Avalia botoes do usuario                                       ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If lMA119BUT
					If ValType( aUsButtons := ExecBlock( "MA119BUT", .F., .F. ) ) == "A"
						AEval( aUsButtons, { |x| AAdd( aButtons, x ) } ) 	 	
					EndIf 	
				EndIf   			

				aInfo := { aSizeAut[ 1 ], aSizeAut[ 2 ], aSizeAut[ 3 ], aSizeAut[ 4 ], 3, 3 }

				aPosGet := MsObjGetPos(aSizeAut[3]-aSizeAut[1],310,;
					{If(lSubSerie,{8,30,72,92,130,150,180,200,235,250,275,295},{8,35,75,100,140,165,194,220,260,280}),; 
					{8,35,75,100,nPosGetLoja,194,220},;
					{5,70,160,205,295},;
					{6,34,200,215},;
					{6,34,75,103,148,164,230,253},;
					{6,34,200,218,280},;
					{11,50,150,190},;
					{273,130,190,293,205},;
					{005,025,065,085,125,145,185,205,250,275}})

				DEFINE MSDIALOG oDlg FROM aSizeAut[7],0 TO aSizeAut[6],aSizeAut[5] TITLE cCadastro Of oMainWnd PIXEL

				// Tratamento para recalcular corretamente o vencimento da duplicata ao alterar a data de emissao da nota
				// Funcao localizada no MATA103X
				SetVar113(cToD(""))

				oSize := FwDefSize():New(.T.,,,oDlg)
	
				oSize:AddObject('HEADER',100,40,.T.,.F.)
				oSize:AddObject('GRID'  ,100,10,.T.,.T.)
				oSize:AddObject('FOOT'  ,100,90,.T.,.F.)			
	
				oSize:aMargins 	:= { 3, 3, 3, 3 }
				oSize:Process()
	
				aAdd(aPosObj,{oSize:GetDimension('HEADER', 'LININI'),oSize:GetDimension('HEADER', 'COLINI'),oSize:GetDimension('HEADER', 'LINEND'),oSize:GetDimension('HEADER', 'COLEND')})
				aAdd(aPosObj,{oSize:GetDimension('GRID'  , 'LININI'),oSize:GetDimension('GRID'  , 'COLINI'),oSize:GetDimension('GRID'  , 'LINEND'),oSize:GetDimension('GRID'  , 'COLEND')})
				aAdd(aPosObj,{oSize:GetDimension('FOOT'  , 'LININI'),oSize:GetDimension('FOOT'  , 'COLINI'),oSize:GetDimension('FOOT'  , 'LINEND'),oSize:GetDimension('FOOT'  , 'COLEND')})
					
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Objeto criado para receber o foco quando pressionado o botao confirma ³
				//³ da dialog. Usado para identificar quando foi pressionado o botao      ³
				//³ confirma, atraves do parametro passado ao lostfocus                   ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				@ 100000,100000 MSGET oFoco103 VAR cVarFoco SIZE 12,09 PIXEL OF oDlg 
				oFoco103:Cargo := {.T.,.T.}
				oFoco103:Disable()			

				NfeCabDoc(oDlg,{aPosGet[1],aPosGet[2],aPosObj[1]},@bCabOk,.F..Or.l103Visual,,,,,@nCombo,@oCombo,@cCodRet,@oCodRet,,@aCodR,@cRecIss,,,,aNfeDanfe)

				If !lDKD .Or. (lDKD .And. !lTabAuxD1)
					oGetDados := MSGetDados():New(aPosObj[2,1],aPosObj[2,2],aPosObj[2,3],aPosObj[2,4],nOpcx,'A119LinOk','A119TudOk','+D1_ITEM',.T.,aCpos2,,,900,,,,'NfeDelItem')
				Else
					oGetDados := MSGetDados():New(aPosObj[2,1],aPosObj[2,2],aPosObj[2,3]-50,aPosObj[2,4],nOpcx,'A119LinOk','A119TudOk','+D1_ITEM',.T.,aCpos2,,,900,,,,'NfeDelItem')

					oGetDKD		:= MsNewGetDados():New(aPosObj[2,3]-50,aPosObj[2,2],aPosObj[2,3],aPosObj[2,4],Iif(nOpcx == 2,0,GD_UPDATE+GD_INSERT+GD_DELETE),/*"a103xLOk"*/"",/*"a103xLOk"*/"","+DKD_ITEM",aAltDKD,/*freeze*/,1,/*fieldok*/,/*superdel*/,/*"LancDel("+cVisual+")*/"",oDlg,aHeadDKD,aColsDKD)
					If l103Visual
						A103DKDATU(1) 
					Endif 
				Endif

				oGetDados:oBrowse:bGotFocus	:= bCabOk
				oGetDados:oBrowse:bChange := {|| Iif(lTrbGen, MaFisLinTG(oFisTrbGen,oGetDados:oBrowse:nAt) ,.T.),;
												 Iif(lDKD .And. lTabAuxD1,A103DKDATU(),.T.) }

				oFolder := TFolder():New(aPosObj[3,1],aPosObj[3,2],aTitles,{"AHEADER"},oDlg,,,, .T., .F.,aPosObj[3,4]-aPosObj[3,2],aPosObj[3,3]-aPosObj[3,1],)
				oFolder:bSetOption := {|nDst| NfeFldChg(nDst,oFolder:nOption,oFolder,aFldCBAtu)}
				bRefresh := {|nX| NfeFldChg(nX,oFolder:nOption,oFolder,aFldCBAtu)}
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Folder dos Totalizadores                                     ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				oFolder:aDialogs[1]:oFont := oDlg:oFont
				NfeFldTot(oFolder:aDialogs[1],aValores,aPosGet[3],@aFldCBAtu[1])
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Folder dos Fornecedores                                      ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				oFolder:aDialogs[2]:oFont := oDlg:oFont
				NfeFldFor(oFolder:aDialogs[2],aInfForn,{aPosGet[4],aPosGet[5],aPosGet[6]},@aFldCBAtu[2])
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Folder das Despesas acessorias e descontos                   ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				oFolder:aDialogs[3]:oFont := oDlg:oFont
				NfeFldDsp(oFolder:aDialogs[3],aValores,{aPosGet[7],aPosGet[8]},@aFldCBAtu[3])
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Folder dos Livros Fiscais                                    ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				oFolder:aDialogs[4]:oFont := oDlg:oFont	
				oLivro := MaFisBrwLivro(oFolder:aDialogs[4],{5,4,( aPosObj[3,4]-aPosObj[3,2] ) - 10,53},.T.,IIf(!.F.,aRecSF3,Nil),.T.)
				aFldCBAtu[4] := {|| oLivro:Refresh()}
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Folder dos Impostos                                          ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				oFolder:aDialogs[5]:oFont := oDlg:oFont	
				oFisRod	:=	MaFisRodape(nTpRodape,oFolder:aDialogs[5],,{5,4,( aPosObj[3,4]-aPosObj[3,2] )-10,53},@bIPRefresh,l103Visual,@cFornIss,@cLojaIss,aRecSE2,@cDirf,@cCodRet,@oCodRet,@nCombo,@oCombo,@dVencIss,@aCodR,@cRecIss,@oRecIss)
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Folder do Financeiro                                         ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ			
				oFolder:aDialogs[6]:oFont := oDlg:oFont
				NfeFldFin(oFolder:aDialogs[6],l103Visual,aRecSE2,( aPosObj[3,4]-aPosObj[3,2] ) - 101,,@aHeadSE2,@aColsSE2,@aHeadSEV,@aColsSEV,@aFldCbAtu[6],.T.,@cModRetPIS,lPccBaixa,,,,@aColTrbGen,@nColsSE2,@aParcTrGen)
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Montagem do Folder Informacoes Diversas                             |
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				oFolder:aDialogs[nInfDiv]:oFont := oDlg:oFont			
				NfeFldDiv(oFolder:aDialogs[nInfDiv],{aPosGet[9]})

				// -- Folder de Tributos Genéricos
				If lTrbGen
					oFolder:aDialogs[nTrbGen]:oFont := oDlg:oFont 
					oFisTrbGen := MaFisBrwTG(oFolder:aDialogs[nTrbGen],{5,4,( aPosObj[3,4]-aPosObj[3,2] ) - 10,65}, l119Visual)
					aFldCBAtu[nTrbGen] := {|| Iif(lTrbGen , MaFisLinTG(oFisTrbGen,oGetDados:oBrowse:nAt) , .T.) }				
				EndIf

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
    			//³ Transfere o foco para a getdados - nao retirar                 ³
	   			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				oFoco103:bGotFocus := { || oGetDados:oBrowse:SetFocus() }			
				
				ACTIVATE MSDIALOG oDlg ON INIT (EnchoiceBar(oDlg,;
				{||Eval(bRefresh,IIf(oFolder:nOption==6,1,6)).And.oFoco103:Enable(),oFoco103:SetFocus(),oFoco103:Disable(),;
				If(oGetDados:TudoOk() .And. oFoco103:Cargo[1].And. If(l119Inclui,NfeTotFin(aHeadSE2,aColsSE2,.F.,,nColsSE2,aColTrbGen),.T.) .And. NfeVldSEV(oFoco103:Cargo[2],aHeader,aCols,aHeadSEV,aColsSEV) .And. IIf(FindFunction("A103ChamaHelp") .And. l119Inclui,A103ChamaHelp(),.T.) .And. NfeNextDoc(@cNFiscal,@cSerie,l119Inclui) .And. NfeFornece(cTipo,cA100For,cLoja,,,,,,,,,,.T.),(nOpcA:=1,oDlg:End()),Eval({||nOpcA:=0,oFoco103:Cargo[1] :=.T.}))},; 
				{||nOpc:=0,oDlg:End()},,aButtons),Eval(bRefresh))
				
			EndIf
			If nOpcA == 1 .And. (l119Inclui.Or.l119Exclui)
			
				//Verifica se existe bloqueio contábil
				If lRet
					If l119Exclui
						dCtbValiDt := GDFieldGet("D1_DTDIGIT")
					Else
						dCtbValiDt := dDataBase
					EndIf
					lRet := CtbValiDt(Nil,dCtbValiDt,/*.T.*/ ,Nil ,Nil ,{"COM001"}/*,"Data de apuração bloqueada pelo calendário contábil."*/) 
				EndIf
			
				If lRet
					
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Inicializa a gravacao atraves nas funcoes MATXFIS         ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					MaFisWrite()  
					
					Begin Transaction
						SF1->(dbClearFilter())
			            If nX >= 2 .And. cFormul == "S"
			           		// Para MultNotas (MV_NUMITEM) recalcular as parcelas por NF
			           		NfeFldFin(,.F.,@aRecSE2,0,.F.,@aHeadSE2,@aColsSE2,@aHeadSEV,@aColsSEV,,.T.,,,,,,@aColTrbGen,@nColsSE2,@aParcTrGen)
							nRecSF1 := 0
			            EndIf
		            	A103Grava(l119Exclui,lGeraLanc,lDigita,lAglutina,aHeadSE2,aColsSE2,aHeadSEV,aColsSEV,@nRecSF1,aRecSD1,aRecSE2,aRecSF3,Nil,aHeadSDE,aColsSDE,aRecSDE,.F.,.T.,@aRecSF1Ori,Nil,Nil,cFornIss,cLojaIss,Nil,Nil,cDirf,cCodRet,Nil,nIndexSE2,,dVencIss,,,,,,,aCodR,cRecIss,Nil,aCtbInf,aNfeDanfe,,,,,,,,,,,,,aParcTrGen)
						A119Grava(l119Exclui,nRecSF1,aRecSF1Ori,aRecSF8,aAmarrAFN,"MATA119")
			            If FindFunction("A017GrvCDV") 
						    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						    //³ Define o CFO  para Nota de Despesa de Importação e chama a função para grava a CDV  ³
						    //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						    aDadosCFO := {}
					 	    Aadd(aDadosCfo,{"OPERNF","E"})
					 	    Aadd(aDadosCfo,{"TPCLIFOR",SA2->A2_TIPO})					
					 	    Aadd(aDadosCfo,{"UFDEST"  ,SA2->A2_EST})
					 	    cCfop := MaFisCfo(,SF4->F4_CF,aDadosCfo)
						    
							A017GrvCDV(l119Exclui,"E",cEspecie,cFormul,cNFiscal,cSerie,cA100For,cLoja,,"MATA119",nValDesp,cCfop)
						Endif	
					End Transaction
					
					If cTplGeraComFi <> "U"
				   		If lGeraComFi .And. cPaisLoc == "BRA"
				   			AtuCompImp(l119Exclui,lAglutProd,aRecSF1Ori,nRecSF1)
				   		Endif
				   	Endif       
	
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Executa gravacao da contabilidade     ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If Len(aCtbInf) != 0
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Cria nova transacao para garantir atualizacao do documento ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						Begin Transaction
							//modulo CTB
							cA100Incl(aCtbInf[1],aCtbInf[2],3,aCtbInf[3],aCtbInf[4],aCtbInf[5],,,,aCtbInf[7],,aCtbInf[6])
						End Transaction					
					EndIf
					
					If lMT119AGR
						ExecBlock("MT119AGR",.F.,.F.)
					EndIf
				EndIf
			Else
				nX := Len(aNotas)
			EndIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Finaliza a gravacao dos lancamentos do SIGAPCO e apaga lancamentos de bloqueio nao utilizados ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			PcoFinLan("000054")
			
			MaFisEnd()
		Next nX
	EndIf		
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Destrava os registros na alteracao e exclusao          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	MsUnlockAll()
EndIf	

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Seleciona a area de trabalho 1 para manter uma chave de indice selecionada     ³
//³ Caso contrario ocorrera erro na funcao mbrowse                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
SF1->( dbSetOrder( 1 ) ) 

If lContinua .Or. (!lContinua .And. !l119NotReg)
	CloseBrowse()
Endif

Return .T.
/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³A119LinOk ³ Autor ³Edson Maricate         ³ Data ³27.03.2000 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³Rotina de validacao da Linha Ok da GetDados                  ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpO1: Objeto da GetDados                                    ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                       ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Esta rotina tem como objetivo efetuar a validacao do preenchi³±±
±±³          ³mento das linhas da getdados                                 ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Materiais                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function A119LINOK()

Local aArea	   := GetArea()
Local lRet	   := .T.
Local nPCod    := aScan(aHeader,{|x| AllTrim(x[2])=="D1_COD"})
Local nPUm     := aScan(aHeader,{|x| AllTrim(x[2])=="D1_UM"})
Local nPQuant  := aScan(aHeader,{|x| AllTrim(x[2])=="D1_QUANT"})
Local nPVUnit  := aScan(aHeader,{|x| AllTrim(x[2])=="D1_VUNIT"})
Local nPTotal  := aScan(aHeader,{|x| AllTrim(x[2])=="D1_TOTAL"})
Local nPTes    := aScan(aHeader,{|x| AllTrim(x[2])=="D1_TES"})
Local nPCfo    := aScan(aHeader,{|x| AllTrim(x[2])=="D1_CF"})
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica preenchimento dos campos da linha do acols      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If CheckCols(N,aCols)
	If !aCols[n][Len(aCols[n])]
		Do Case
		Case Empty(aCols[n][nPCod])   .Or. ;
				Empty(aCols[n][nPVUnit]) .Or. ;
				Empty(aCols[n][nPTotal]) .Or. ;
				Empty(aCols[n][nPCFO])   .Or. ;
				Empty(aCols[n][nPTES])
			Help("  ",1,"A100VZ")
		Case !ExistCpo('SF4',aCols[n][nPTes])
			lRet := .F.
		OtherWise
			lRet := .T.
		EndCase
	Else
		lRet := .T.
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Pontos de Entrada									     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lRet .And. lDKD .And. lTabAuxD1
		//Atualiza aColsDKD
		A103DKDATU() 
	Endif
	If lRet .And. (ExistTemplate("MT100LOK"))
		lRet := ExecTemplate("MT100LOK",.F.,.F.,{lRet})
		If ValType(lRet) <> "L"
			lRet := .T.			
		EndIf
	EndIf
	If lRet .And. (ExistBlock("MT100LOK"))
		lRet := ExecBlock("MT100LOK",.F.,.F.,{lRet})
		If ValType(lRet) <> "L"
			lRet := .T.			
		EndIf
	EndIf

Else
	lRet := .F.
EndIf
RestArea(aArea)

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A119TudOk ³ Autor ³ Edson Maricate        ³ Data ³08.02.2000³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Critica se as linhas digitadas estao OK.                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATA119                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A119Tudok()
Local lRet		:= .T.

//Verifica se existe bloqueio contábil
lRet := CtbValiDt(Nil,dDataBase,/*.T.*/ ,Nil ,Nil ,{"COM001"}/*,"Data de apuração bloqueada pelo calendário contábil."*/) 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica a condicao de pagamento.           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If MaFisRet(,"NF_BASEDUP") > 0 .And. Empty(cCondicao)
	HELP("  ",1,"A100COND")
	lRet := .F.
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica a natureza                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If MaFisRet(,"NF_BASEDUP") > 0 .And. Empty(MaFisRet(,"NF_NATUREZA")) .And. cTipo<>"D"
	If SuperGetMV("MV_NFENAT")
		Help("  ",1,"A103NATURE")
		If ( Type("l103Auto") == "U" .Or. !l103Auto )
			oFolder:nOption := 6
		EndIf
		lRet := .F.
	EndIf
EndIf

If lRet
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Faz chamada ao PE para permitir validar o aCols ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lRet .And. (ExistTemplate("MT100LOK"))
		lRet := ExecTemplate("MT100LOK",.F.,.F.,{lRet})
		If ValType(lRet) <> "L"
			lRet := .T.			
		EndIf
	EndIf
	If lRet .And. (ExistBlock("MT100LOK"))
		lRet := ExecBlock("MT100LOK",.F.,.F.,{lRet})
		If ValType(lRet) <> "L"
			lRet := .T.			
		EndIf
	EndIf
EndIf

If lRet .And. ExistBlock("MT119TOK")
	lRet := ExecBlock("MT119TOK",.F.,.F.,{lRet})
	If ValType(lRet) <> "L"
		lRet := .T.	
	EndIf
EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A119Grava ³ Autor ³ Edson Maricate        ³ Data ³08.02.2000³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Complementa a gravacao da NF de Frete                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATA119                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function  A119Grava(l119Exclui,nRecSF1,aRecSF1Ori,aRecSF8,aAmarrAFN,cOrigem)

Local aArea 	:= GetArea()
Local nX 		:= 0
Local ny 		:= 0
Local nw 		:= 0
Local nDecSD1 	:= TamSX3("D1_QUANT")[2]
Local nDecAFN 	:= TamSX3("AFN_QUANT")[2]
Local aSD1Vlr 	:= {}
Local cIdFrete 	:= ""
Local cChave1SF8 := "" 
Local cChave2SF8 := "" 

Default aAmarrAFN := {}
Default cOrigem   := ""

If !l119Exclui
	If !Empty(SF1->F1_DOC)
		dbSelectArea("SF1")
		MsGoto(nRecSF1)
		cNfFrete := SF1->F1_DOC
		cSeFrete := SF1->F1_SERIE
		cForFrete:= SF1->F1_FORNECE
		cLojFrete:= SF1->F1_LOJA
		cIdFrete := SF1->F1_MSIDENT
		For nX	:=  1 to Len(aRecSF1Ori)
			dbSelectArea("SF1")	
			MsGoto(aRecSF1Ori[nX])
			dbSelectArea("SF8")
			RecLock("SF8",.T.)
			SF8->F8_FILIAL	:= xFilial("SF8")
			SF8->F8_DTDIGIT := SF1->F1_DTDIGIT
			SF8->F8_NFDIFRE	:= cNfFrete
			SF8->F8_SEDIFRE	:= cSeFrete
			SF8->F8_TRANSP	:= cForFrete
			SF8->F8_LOJTRAN	:= cLojFrete
			SF8->F8_NFORIG	:= SF1->F1_DOC
			SF8->F8_SERORIG	:= SF1->F1_SERIE
			SF8->F8_FORNECE	:= SF1->F1_FORNECE
			SF8->F8_LOJA	:= SF1->F1_LOJA
			SF8->F8_TIPO	:= "D"
			MsUnlock()
	
			dbSelectArea("SF1")
			RecLock("SF1",.F.)
			SF1->F1_ORIGLAN	:= If(SF1->F1_ORIGLAN=="F ","FD"," D")
			SF1->F1_OK      := ""
			MsUnlock()
	
			dbSelectArea("SD1")
	        dbClearFilter()        
	        dbSetOrder(1)
			MsSeek(xFilial("SD1")+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA)
	        While ( !Eof() .And. SD1->D1_FILIAL == xFilial("SD1") .And.;
						            SD1->D1_DOC    == SF1->F1_DOC    .And.;
					 	            SD1->D1_SERIE  == SF1->F1_SERIE  .And.;
						            SD1->D1_FORNECE== SF1->F1_FORNECE.And.;
						            SD1->D1_LOJA   == SF1->F1_LOJA )
		
				RecLock("SD1",.F.,.T.)
				SD1->D1_ORIGLAN   := If(SD1->D1_ORIGLAN=="F ","FD"," D")
				MsUnlock()		
		
				If SD1->D1_QUANT >0 
					aAdd( aSD1Vlr ,{ cNFFrete,cSeFrete,cForFrete,cLojFrete,SD1->D1_COD,SD1->D1_QUANT } )
				EndIf
				
				dbSelectArea("SD1")
				dbSkip()
			EndDo
	
		Next nX
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Grava a tabela de apontamento do SIGAPMS                     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		For ny := 1 to Len(aAmarrAFN)
			For nw := 1 to Len(aAmarrAFN[ny])
				If aAmarrAFN[ny][nw][6] > 0
					RecLock("AFN",.T.)
					AFN->AFN_FILIAL := xFilial("AFN")
					AFN->AFN_PROJET	:= aAmarrAFN[ny][nw][1]
					AFN->AFN_REVISA	:= aAmarrAFN[ny][nw][2]
					AFN->AFN_TAREFA	:= aAmarrAFN[ny][nw][3]
					AFN->AFN_QUANT	:= 1
					AFN->AFN_DOC	:= cNfFrete
					AFN->AFN_SERIE	:= cSeFrete
					AFN->AFN_FORNEC	:= cForFrete
					AFN->AFN_LOJA	:= cLojFrete
					AFN->AFN_ITEM	:= aAmarrAFN[ny][nw][8]
					AFN->AFN_TIPONF	:= SF1->F1_TIPO
					AFN->AFN_COD	:= aAmarrAFN[ny][nw][9]
					AFN->AFN_ID 	:= cIdFrete
					
					MsUnlock()
	
					// busca pela nota de entrada q está gerando o frete
					If (nPos := aScan( aSD1Vlr ,{|x| x[1] == cNfFrete .and. x[2] == cSeFrete .and. x[3] == cForFrete .and. x[4] == cLojFrete .and. x[5] == aAmarrAFN[nY][nW][9] }))>0
						// calcula o percentual a ser rateado pro projeto e tarefa					
						nInd := NoRound(aAmarrAFN[nY][nW][6]/aAmarrAFN[nY][nW][7]*100,nDecAFN)/100
					Else
						nInd := 0
					Endif
					
					SD1->(dbSetOrder(1))
					If SD1->(MsSeek(xFilial("SD1")+cNfFrete + cSeFrete + cForFrete + cLojFrete + aAmarrAFN[nY][nW][9] ))
						aCusto := { NoRound( SD1->D1_CUSTO*nInd  ,nDecSD1 ) ;
						           ,NoRound( SD1->D1_CUSTO2*nInd ,nDecSD1 ) ;
						           ,NoRound( SD1->D1_CUSTO3*nInd ,nDecSD1 ) ;
						           ,NoRound( SD1->D1_CUSTO4*nInd ,nDecSD1 ) ;
						           ,NoRound( SD1->D1_CUSTO5*nInd ,nDecSD1 ) }
					EndIf
					PmsAvalAFN("AFN",1,.T.,aCusto)
	
				EndIf
			Next nw
		Next ny
	EndIf
Else
	For nX := 1 to Len(aRecSF8)
		dbSelectArea("SF8")
		MsGoto(aRecSF8[nX])
		cChave1SF8 := SF8->(F8_FILIAL+F8_NFORIG+F8_SERORIG+F8_FORNECE+F8_LOJA)
		cChave2SF8 := SF8->(F8_FILIAL+F8_NFDIFRE+F8_SEDIFRE+F8_FORNECE+F8_LOJA)
		SF8->(DbSetOrder(2))
		SF8->(DbSeek(cChave1SF8))
		While SF8->(!Eof()) .AND. cChave1SF8 == SF8->(F8_FILIAL+F8_NFORIG+F8_SERORIG+F8_FORNECE+F8_LOJA)
			If cChave2SF8 != SF8->(F8_FILIAL+F8_NFDIFRE+F8_SEDIFRE+F8_FORNECE+F8_LOJA)
				cChave1SF8 := ""
				Exit
			EndIf 
			SF8->(DbSkip())
		EndDo
		SF8->(MsGoto(aRecSF8[nX]))
		dbSelectArea("SF1")
		dbClearFilter()        
		dbSetOrder(1)
		If !Empty(cChave1SF8) .AND. SF1->(dbSeek(cChave1SF8))
			While cChave1SF8 == SF1->(F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA) .AND. !SF1->(Eof())
				If cOrigem != "MATA119" .Or. ; // Chamada via LOCXNF
					( aTrocaF3[1][2] == "SA1" .And. SF1->F1_TIPO $ "B|D" ) .Or. ;
					( aTrocaF3[1][2] == "FOR" .And. SF1->F1_TIPO == "N" )
					Reclock("SF1",.F.,.T.)
					SF1->F1_ORIGLAN   := If(SF1->F1_ORIGLAN=="FD","F ","  ")
					MsUnlock()
					dbSelectArea("SD1")
					dbClearFilter()        
					dbSetOrder(1)
					MsSeek(xFilial("SD1")+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA)
					While ( !Eof() .And. SD1->D1_FILIAL == xFilial("SD1") .And.;
							            SD1->D1_DOC    == SF1->F1_DOC    .And.;
						 	            SD1->D1_SERIE  == SF1->F1_SERIE  .And.;
							            SD1->D1_FORNECE== SF1->F1_FORNECE.And.;
							            SD1->D1_LOJA   == SF1->F1_LOJA )
			
						RecLock("SD1",.F.,.T.)
						SD1->D1_ORIGLAN   := IIF(SD1->D1_ORIGLAN=="FD","F ","  ")
						MsUnlock()		
		
						dbSelectArea("SD1")
						dbSkip()
					EndDo
				EndIf
			SF1->(dbSkip())
			EndDo
		EndIf

		RecLock("SF8",.F.,.T.)
		SF8->(dbDelete())
		MsUnlock()
	Next
EndIf
RestArea(aArea)
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A119GetSF8³ Autor ³ Bruno Sobieski        ³ Data ³22.07.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Pega os registros do SF8 referentes a nota fiscal atual     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³MATA119,LOCXNF (NAO DEFINIR COMO STATIC!!!)                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function a119GetSF8()
Local aRet		:=	{}
Local lQuery	:=	.F.
Local	cAliasSF8 := "SF8"
Local	aStruSF8 :=	{}
Local cQuery   := ""
Local nX       := 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Carrega os itens do SF8                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		
dbSelectArea("SF8")
dbSetOrder(1)
lQuery := .T.
cAliasSF8 := "A119INCLUI"
aStruSF8  := SF8->(dbStruct())
cQuery    := "SELECT SF8.*,SF8.R_E_C_N_O_ SF8RECNO "
cQuery    += "FROM "+RetSqlName("SF8")+" SF8 "
cQuery    += "WHERE SF8.F8_FILIAL = '"+xFilial("SF8")+"' AND "
cQuery    += "SF8.F8_NFDIFRE = '"+SF1->F1_DOC+"' AND "
cQuery    += "SF8.F8_SEDIFRE = '"+SF1->F1_SERIE+"' AND "
cQuery    += "SF8.F8_TRANSP = '"+SF1->F1_FORNECE+"' AND "
cQuery    += "SF8.F8_LOJTRAN = '"+SF1->F1_LOJA+"' AND "
cQuery    += "SF8.D_E_L_E_T_= ' ' "
cQuery    += "ORDER BY "+SqlOrder(SF8->(IndexKey()))

cQuery    := ChangeQuery(cQuery)

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSF8,.T.,.T.)
For nX := 1 To Len(aStruSF8)
	If aStruSF8[nX][2]<>"C"
		TcSetField(cAliasSF8,aStruSF8[nX][1],aStruSF8[nX][2],aStruSF8[nX][3],aStruSF8[nX][4])
	EndIf
Next nX

While !Eof() .And. xFilial("SF8") == F8_FILIAL .And.;
		SF1->F1_DOC == F8_NFDIFRE .And.;
		SF1->F1_SERIE == F8_SEDIFRE

	If SF1->F1_FORNECE == F8_TRANSP .And.;
			SF1->F1_LOJA == F8_LOJTRAN

		Aadd(aRet,If(lQuery,(cAliasSF8)->SF8RECNO,(cAliasSF8)->(RecNo())))

	EndIf
	dbSelectArea(cAliasSF8)
	dbSkip()
EndDo
If lQuery
	dbSelectArea(cAliasSF8)
	dbCloseArea()
	dbSelectArea("SF8")
EndIf

Return aRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ A119FORN ³ Autor ³Aline Sebrian          ³ Data ³ 01/07/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa de Validacao do Fornecedor Padrao.                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Void A119FORN(boolean)                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T. / .F.                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SX1->X1_VALID				                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A119Forn()

Local lRet  := .T.

If !Empty(mv_par06)
	lRet  := ExistCpo("SA2",mv_par05+mv_par06)
EndIf

If !lRet
	mv_par06 := Space(Len(SA2->A2_LOJA))
EndIF

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ A119VldF ³ Autor ³ TOTVS                 ³ Data ³ 09/08/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Validação do código do fornecedor na tela de parâmetros.   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ A119VldF()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A119VldF()

Local aArea		:= GetArea()
Local aAreaSA2	:= SA2->(GetArea())
Local cForn		:= MV_PAR04
Local cLoja		:= MV_PAR05
Local lRet		:= .T.

If !Empty(cForn)
	dbSelectArea("SA2")
	If Empty(cLoja) .Or. cLoja == Nil
		dbSetOrder(1)
		lRet := MsSeek(xFilial("SA2")+cForn)
		If !lRet
			HELP("  ",1,"REGNOIS")
		EndIf
	Else
		dbSetOrder(1)
		lRet := MsSeek(xFilial("SA2")+cForn+cLoja)
		If !lRet
			HELP("  ",1,"REGNOIS")
		EndIf
	EndIf
EndIf

RestArea(aAreaSA2)
RestArea(aArea)
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³AltConF3     ³ Autor ³ TOTVS                   ³ Data ³09/12/11       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³Altera a consulta padrao do Fornecedor/Cliente na tela de parâmetros  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³AltConF3()                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                                      ³±±
±±³          |                         										        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³MATA119	                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function AltConF3(cVar)

If cVar=="MV_PAR01"
	If MV_PAR06==2			// Nota de Devolução/Beneficiamento
		aTrocaF3 := {{"MV_PAR04","SA1"}}
	EndIf
Else 
	If MV_PAR06==1			// Nota Normal
		aTrocaF3 := {{"MV_PAR04","FOR"}}
	Else					// MV_PAR06==2 - Nota de Devolução/Beneficiamento
		aTrocaF3 := {{"MV_PAR04","SA1"}}
	EndIf
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³AltConF3     ³ Autor ³ TOTVS                     ³ Data ³09/12/11     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³Altera a consulta padrao do Fornecedor/Cliente na tela de parâmetros  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³AltConF3()                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                                      ³±±
±±³          |                         										        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³MATA119	                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A114Forn(cTipo)

Local lRet := .T.
Local aArea := {}
Local aAreaSA2 := {}

If MV_PAR06==1	// Nota Normal
	
	aArea := GetArea()
	aAreaSA2 := SA2->(GetArea())
	
	IF cTipo == "F"
		IF mv_par04 <> SA2->A2_COD
			dbSelectArea("SA2")
			dbSetOrder(1)
			dbSeek(xFilial("SA2") + mv_par04)
		EndIf
		
		If SA2->(!EOF())
			If mv_par04 <> SA2->A2_COD
				mv_par04 := SA2->A2_COD
			EndIf
		Else
			mv_par04 := SPACE(Len(SA2->A2_COD))
		Endif
		
		mv_par05 := SA2->A2_LOJA
		
	Endif
	
	IF cTipo == "L"
		If !Empty(mv_par05)
			IF SA2->(!dbSeek(xFilial("SA2") + Padr(mv_par04,TamSx3("A2_COD")[1]) + Padr(mv_par05,TamSx3("A2_LOJA")[1])))
				lRet := .F.
			EndIF
		Endif
	Endif
	
	RestArea(aAreaSA2)
	RestArea(aArea)

Else	// MV_PAR06==2 - Nota de Devolução/Beneficiamento
	If mv_par05 <> SA1->A1_LOJA
		mv_par05 := SA1->A1_LOJA
	EndIF
EndIf

Return(lRet)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    |AtuCompImp| Autor ³Luccas Curcio                 ³ Data ³15.08.2012³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Atualizacao do Complemento Fiscal de Importacao                   ³±±
±±³          ³                                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ExpL1 := AtuCompImp (lExclusao, lAglutProd, aRecSF1Ori, nRecSF1)   ³±±
±±³          ³                                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros|lExclusao  -> Indica se eh Exclusao ou Inclusao                    ³±±
±±³          ³lAglutProd -> Indica se existe aglutinacao por produto             ³±±
±±³          ³aRecSF1Ori -> RecNo da Nota Fiscal Original                        ³±± 
±±³          ³nRecSF1    -> RecNo da Nota Fiscal que esta sendo gerada           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpL1 - Nil                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGACOM - SIGAFIS                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function AtuCompImp(lExclusao,lAglutProd,aRecSF1Ori,nRecSF1)
Local	cChvCD5		:=	""
Local	cChvCDB		:=	""
Local	cChvSFT		:=	""
Local	cItemCDB	:=	""
Local	cCodCDB		:=	""
Local   cDtEntrada  :=  ""
Local	aAreaSF1	:=	SF1->(GetArea())
Local	aItens		:=	{}
Local	aItens2		:=	{}
Local	aCabec		:=	{}
Local	aCmpsCD5	:=	{}
Local	aCmpsNum	:=	{}
Local	nX			:=	0
Local	nI			:=	0
Local	nPos		:=	0
Local	nPos2		:=	0
Local	nPosItem	:=	0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Gravo as informacoes da nota que esta sendo gerada no array aCabec³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If cPaisLoc == "BRA"
	SF1->(dbGoTo(nRecSF1))
	aCabec	:=	{SF1->F1_FILIAL, SF1->F1_DOC, SF1->F1_SERIE, SF1->F1_ESPECIE, SF1->F1_FORNECE, SF1->F1_LOJA}
	
	//ÚÄÄÄÄÄÄÄÄ¿
	//³Inclusao³
	//ÀÄÄÄÄÄÄÄÄÙ
	If !lExclusao
	    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Posiciono a nota fiscal de origem, para buscar os dados originais³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		SF1->(dbGoTo(aRecSF1Ori[1]))
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Crio chave para as tabelas CD5 (Compl Importacao), CDB (Log auditoria de Complementos) e SFT (Itens do Livro)  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cChvCD5	:=	SF1->(F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA)
		cChvCDB	:=	SF1->(F1_FILIAL+"E"+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA)
		cChvSFT	:=	SF1->(F1_FILIAL+"E"+F1_SERIE+F1_DOC+F1_FORNECE+F1_LOJA)
	    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Abro a tabela CDB	 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	    DbSelectArea("CDB")
	    CDB->(dbSetOrder(1))
	    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Posiciona a tabela CD5³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		DbSelectArea("CD5")
		CD5->(DbSetOrder(4))
		If CD5->(MsSeek(cChvCD5))
	
		    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Procuro no dicionario quais campos numericos de valor que serao utilizados em situacao de aglutinacao³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			dbSelectArea("SX3")
			dbSetOrder(1)
			MsSeek("CD5")
			While !Eof() .And. (SX3->X3_ARQUIVO == "CD5")
				If SX3->X3_TIPO == "N" .And. SX3->X3_TAMANHO > 7
					aAdd(aCmpsNum,Alltrim(SX3->X3_CAMPO))
				Endif
				SX3->(DbSkip())
			Enddo
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Construo o array a CmpsCD5 com a estrutura da tabela CD5, com todos os campos presentes no dicionario ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			aCmpsCD5	:=	CD5->(DbStruct())
	        //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Faco um laco na tabela CD5, utilizando como chave a nota original, buscando os registros relacionados a ela ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			While !CD5->(Eof()) .And. cChvCD5 == CD5->(CD5_FILIAL+CD5_DOC+CD5_SERIE+CD5_FORNECE+CD5_LOJA)
			    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Posiciono a tabela SFT para buscar o codigo do produto do registro na CD5.				³
				//³Guardo o codigo no array aItens2 e relaciono com a posicao do array, pois caso a rotina	³
				//³aglutinar por produto, irei somar os valores na posicao correto do array aItens.			³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				nPos := 0
				DbSelectArea("SFT")
				SFT->(DbSetOrder(1))
				If SFT->(MsSeek(cChvSFT+CD5->CD5_ITEM))
					If (nPos := aScan(aItens2, {|z| z[2] == SFT->FT_PRODUTO})) == 0
						aAdd(aItens2, {Len(aItens2),SFT->FT_PRODUTO})
					Endif	
				Endif
			    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Se utilizo aglutinacao e o codigo ja foi utilizado em outro registro, vou varrer a estrutura		³
				//³da tabela CD5 procurando pelos campos numericos ja informados em aCmpsNum, e entao irei somar	³
				//³os valores para o array aItens, que sera gravado nos novos registro da tabela CD5				³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If lAglutProd .And. nPos > 0
					For nX := 1 To Len(aCmpsCD5)
						If aScan(aCmpsNum,{|x| x==aCmpsCD5[nX][1]}) > 0
							If (nPos2 := aScan(aItens[nPos],{|a| a[1]==aCmpsCD5[nX][1]})) > 0
								aItens[nPos][nPos2][2] += CD5->(&(aCmpsCD5[nX][1]))
							Endif
						Endif
					Next nX
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Construo nova posicao no array a Itens e gravo os valores originais, exceto para os campos do 	³
				//³cabecalho, que devo utilizar as informacoes da nota que esta sendo gerada						³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				Else
					aAdd(aItens, {})
					nPos := Len(aItens)	
						
					For nX := 1 To Len(aCmpsCD5)
					    If aCmpsCD5[nX][1]$"CD5_ITEM"
					    	aAdd(aItens[nPos],{aCmpsCD5[nX][1],{CD5->(&(aCmpsCD5[nX][1])),StrZero(nPos,4)}})	 
						Elseif !(aCmpsCD5[nX][1]$"CD5_FILIAL/CD5_DOC/CD5_SERIE/CD5_FORNECE/CD5_LOJA/CD5_ESPEC")
							aAdd(aItens[nPos],{aCmpsCD5[nX][1],CD5->(&(aCmpsCD5[nX][1]))})
						Endif
					Next nX
				Endif
				CD5->(DbSkip())
			Enddo
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Efetua gravacao das tabelas CD5 e CDB³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			For nX := 1 To Len(aItens)
			
				CD5->(RecLock("CD5",.T.))
			
				CD5->CD5_FILIAL		:=	aCabec[1]
				CD5->CD5_DOC		:=	aCabec[2]
				CD5->CD5_SERIE		:=	aCabec[3]
				CD5->CD5_ESPEC		:=	aCabec[4]
				CD5->CD5_FORNECE	:=	aCabec[5]
				CD5->CD5_LOJA		:=	aCabec[6]
			
				For nI := 1 To Len(aItens[nX])
					If (nPos := aScan(aCmpsCD5, {|x| x[1] == aItens[nX][nI][1]})) > 0
						If aItens[nX][nI][1]$"CD5_ITEM"
							nPosItem := nI
							If lAglutProd
								CD5->(&(aCmpsCD5[nPos][1])) := aItens[nX][nI][2][2]
							Else
								CD5->(&(aCmpsCD5[nPos][1])) := aItens[nX][nI][2][1]
							Endif	
						Else 
							CD5->(&(aCmpsCD5[nPos][1])) := aItens[nX][nI][2]
						Endif
					Endif
				Next nI
				
				CD5->(MsUnLock())
				FkCommit()
				
				If CDB->(MsSeek(cChvCDB+aItens[nX][nPosItem][2][1]))
					cItemCDB	:=	aItens[nX][nPosItem][2][2]
					cCodCDB		:=	CDB->CDB_COD	
					If !(CDB->(MsSeek(xFilial("CDB")+"E"+aCabec[2]+aCabec[3]+aCabec[5]+aCabec[6]+CDB->CDB_ITEM+CDB->CDB_COD+"7")))
						RecLock("CDB",.T.)
						CDB->CDB_FILIAL	:= xFilial("CDB")
						CDB->CDB_TPMOV	:= "E"
						CDB->CDB_DOC	:= aCabec[2]
				  		CDB->CDB_SERIE	:= aCabec[3]
						CDB->CDB_ESPEC	:= aCabec[4]
						CDB->CDB_CLIFOR	:= aCabec[5]
						CDB->CDB_LOJA	:= aCabec[6]
						CDB->CDB_ITEM	:= cItemCDB
						CDB->CDB_COD	:= cCodCDB
						CDB->CDB_COMPL	:= "7"
						MsUnLock()
						FkCommit()
					Endif
				Endif
			
				DbSelectArea("CDT")
				DbSetOrder(1)
				If !(CDT->(MsSeek(xFilial("CDT")+"E"+aCabec[2]+aCabec[3]+aCabec[5]+aCabec[6])))
					RecLock("CDT",.T.)
					CDT->CDT_FILIAL := xFilial("CDT")
					CDT->CDT_TPMOV	:= "E"
					CDT->CDT_DOC 	:= aCabec[2]
					CDT->CDT_SERIE 	:= aCabec[3]
					CDT->CDT_CLIFOR := aCabec[5]
					CDT->CDT_LOJA 	:= aCabec[6]
				EndIf 
			Next nX
		Endif
	//ÚÄÄÄÄÄÄÄÄ¿
	//³Exclusao³
	//ÀÄÄÄÄÄÄÄÄÙ
	Else
		cChvCD5	:=	SF1->(F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA)
		cChvCDT	:=	SF1->(F1_FILIAL+"E"+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA)
		
		DbSelectArea("CD5")
		CD5->(dbSetOrder(4))

		DbSelectArea("CDT")
		CDT->(DbSetOrder(1))
			
		If CD5->(MsSeek(cChvCD5))
	
			Begin Transaction
				While !CD5->(Eof()) .And. cChvCD5 == CD5->(CD5_FILIAL+CD5_DOC+CD5_SERIE+CD5_FORNECE+CD5_LOJA)
	
					RecLock("CD5",.F.)
					CD5->(dbDelete())
					MsUnLock()

					CD5->(DbSkip())
				Enddo
				If CDT->(MsSeek(cChvCDT))
					RecLock("CDT",.F.)
					CDT->(dbDelete())
					MsUnLock()
				EndIf
			End Transaction
		Endif
	Endif

RestArea(aAreaSF1)
EndIf
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³DespVisual³ Autor ³Aline S Damasceno      ³ Data ³23.01.2013³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Botao para visualizar documentos de entrada                 ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGACOM			                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Function DespVisual()
PRIVATE cCadastro	 := STR0003 + " - " + STR0005 //"Despesa de Importação"

A103NFiscal( "SF1", SF1->( RecNo() ), 2 )
Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³MenuDef   ³ Autor ³ Materiais       ³ Data ³01/11/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Utilizacao de menu Funcional                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function MenuDef()

Private aRotina := {}

If !(Type("lGera") == "U")
	If lGera
		aAdd(aRotina,{OemtoAnsi(STR0007),"A119Inclui",0,6}) //"Gera Despesa"
	Else
		aAdd(aRotina,{OemtoAnsi(STR0006),"A119Inclui",0,5}) //"Excluir"
		lInclui := .F.
	EndIf
	aAdd(aRotina,{OemtoAnsi(STR0004),"PesqBrw",0,1}) //"Pesquisar"
	aAdd(aRotina,{OemtoAnsi(STR0005),"DespVisual",0,2}) //"Visualizar"
Else
	// Inclusao das opcoes para que seja possivel conceder as permissoes a usuarios
	// para geracao e exclusao de despesa de importacao via Configurador 
	aAdd(aRotina,{OemtoAnsi(STR0007),"A119Inclui",0,6}) //"Gera Despesa"
	aAdd(aRotina,{OemtoAnsi(STR0006),"A119Inclui",0,5}) //"Excluir"
EndIf

If ExistBlock( "MT116BUT" )
	If ValType( aUsButtons := ExecBlock( "MT116BUT", .F., .F.)) == "A"
		AEval( aUsButtons, { |x| AAdd( aRotina, x ) } )
	EndIf
EndIf

Return(aRotina)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ A115VALOR³ Autor ³ Cristina Ogura         ³ Data ³ 20/03/95 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Checa o valor do frete se esta zerado                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ MATA115                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A115VALOR()
LOCAL x
x:= &(ReadVar())
If x <= 0
	Help(" ",1,"A119VL",,STR0019,1,0,,,,,,{STR0020})
	lRet := .f.
Else
	lRet := .t.
Endif
Return (lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ A115TES  ³ Autor ³Rodrigo de A. Sartorio  ³ Data ³ 28/05/96 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Checa se a TES digitada existe ou n„o.      	               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ MATA115                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
FUNCTION A115TES()
LOCAL lRet:=.T.
If !(SF4->(dbSeek(xFilial("SF4")+&(ReadVar()))))
	Help(" ",1,".MTA11506.")
	lRet:=.F.
EndIf
Return lRet

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} A119Mark
Função que processa a marca das NFs selecionadas

@author    leonardo.magalhaes
@version   1.00
@since     21/03/2019
/*/
//------------------------------------------------------------------------------------------
Function A119Mark(cMark, lMarkAll)     

Local aAreaSF1 := {}

Default cMark := ThisMark()
Default lMarkAll := .F.
	
	aAreaSF1 := SF1->(GetArea())
	
	If lMarkAll
		SF1->(dbGoTop())
		While SF1->(!Eof())
			A119F1Ok(cMark)
		    SF1->(dbSkip())
		EndDo
	Else
		A119F1Ok()
		MarkBRefresh()
	EndIf
	
	RestArea(aAreaSF1)

Return Nil


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} A119F1Ok
Função que grava a marca das NFs selecionadas

@author    leonardo.magalhaes
@version   1.00
@since     21/03/2019
/*/
//------------------------------------------------------------------------------------------
Static Function A119F1Ok(cMark)

Local nPos := 0 

Default cMark := ThisMark()

	nPos := aScan(aRecMark,{|x| x == SF1->(Recno())})
	
	RecLock("SF1",.F.) 
	If IsMark("F1_OK", cMark)
		SF1->F1_OK := Space(Len(SF1->F1_OK))
		If nPos > 0
			aDel(aRecMark, nPos)
			aSize(aRecMark, Len(aRecMark)-1)
		EndIf
	Else
		SF1->F1_OK := cMark
		If nPos == 0
			aAdd(aRecMark, SF1->(Recno()))
		EndIf
	EndIf
	SF1->(MsUnlock())  
		
Return Nil

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} A119ClrMk
Função que limpa a marca gravada em F1_OK na abertura da MarkBrow para registros legados.

@author    leonardo.magalhaes
@version   1.00
@since     21/03/2019
/*/
//------------------------------------------------------------------------------------------
Static Function A119ClrMk()

Local aAreaSF1 := SF1->(GetArea())

While SF1->(!Eof()) 
	If !Empty(SF1->F1_OK)
		RecLock("SF1",.F.)
		SF1->F1_OK := Space(Len(SF1->F1_OK))
		SF1->(MsUnlock())
	EndIf
	SF1->(DbSkip())
EndDo

RestArea(aAreaSF1)

Return Nil

/*/{Protheus.doc} A119ChkSig
//TODO Checa a assinatura dos fontes complementares estão corretos.

@author rodrigo m pontes
@since 04/04/2020
@version 1.0
/*/

Static Function A119ChkSig()

Local lRet := .F.

lRet := FindFunction("FCalcISS")
If !lRet
	Help(" ",1,"FINXIMP",,STR0021,1,0) // "Por favor, atualize o fonte FINXIMP para uma versão igual ou superior a 29/11/2019" 
EndIf

Return lRet
