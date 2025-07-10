#INCLUDE "CTBANFE.CH" 
#INCLUDE "PROTHEUS.CH"

#DEFINE OPT_SELECT 1
#DEFINE OPT_FROM   2
#DEFINE OPT_WHERE  3

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Posicao do array para controle do processamento MultThread³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
#DEFINE ARQUIVO		 		1
#DEFINE MARCA		 	  	2  
#DEFINE QTD_REGISTROS		3
#DEFINE VAR_STATUS			4

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Flag de processamento escrito no arquivo de controle ³
//³de threads                                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
#DEFINE OK		 		"OK"
#DEFINE ERRO		 	"ERRO"

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³CTBANFE   ³Autor  ³ Eduardo Riera         ³ Data ³20.10.2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³Rotina de processamento da contabilizacao off-line dos Docu- ³±±
±±³          ³mentos de Entrada.                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpA1: Parametros da rotina                                  ³±±
±±³          ³       Quando informado nao existe a necessidade de interface³±±
±±³          ³       com o usuario. Pode ser colocado como um servico do   ³±±
±±³          ³       sistema.                                              ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                       ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Esta rotina tem como objetivo contabilizar os documentos de  ³±±
±±³          ³entrada com base nas regras dos lancamentos padronizados.    ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ CTB/COM/OMS                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function CTBANFE(aPergunte)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Variaveis locais                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local aSays    := {}
Local aButtons := {}
Local nOpcA    := 0
Local nX       := 0
Local nOpcABkp := 0
Local cPerg    := "CTBNFE"
Local cMvPar   := ""
Local cString  := ""
Local lAuto    := aPergunte<>Nil
Local oRegua   := Nil 
Local nNumProc := GetMv("MV_CNFETHR", .F., 1 )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define variaveis Private                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private aRotina   := { { STR0001 ,"AllwaysTrue", 0 , 3} }  //"Parametros"
Private cCadastro := STR0002  //"Lan‡amentos Contabeis Off-Line"
Private INCLUI    := .T.
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Desliga Refresh no Lock do Top                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
TCInternal(5,"*OFF")
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ mv_par01 - Mostra Lancamentos Contabeis ?  Sim Nao           ³
//³ mv_par02 - Aglutina Lancamentos         ?  Sim Nao           ³
//³ mv_par03 - Gerar Lancamentos Por        ?  Doc Periodo Dia   ³
//³ mv_par04 - Data Inicial                                      ³
//³ mv_par05 - Data Final                                        ³
//³ mv_par06 - Da Filial                                         ³
//³ mv_par07 - At‚ a Filial                                      ³
//³ mv_par08 - Contabilizar notas de credito? Sim Nao            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Montagem da inteface de processamento                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa o log de processamento                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ProcLogIni( aButtons )

If Empty(aPergunte)
	If !IsBlind()
		Pergunte(cPerg,.F.)
		aadd(aSays,STR0003) //"   Este programa tem como objetivo gerar automaticamente os"
		aadd(aSays,STR0004) //"lan‡amentos cont beis dos movimentos de saida."
		aadd(aSays,STR0005) //"   ATEN€AO: A visualiza‡„o do lan‡amentos por Nota Fiscal   "
		aadd(aSays,STR0006) //"ter  uma grande interferˆncia manual.                       "

		aadd(aButtons, { 5,.T.,{|| Pergunte(cPerg,.T. ) } } )
		aadd(aButtons, { 1,.T.,{|| nOpcA:= 1, FechaBatch() }} )
		aadd(aButtons, { 2,.T.,{|| FechaBatch() }} )		
		FormBatch( cCadastro, aSays, aButtons )		
	Else
		If !FWGetRunSchedule()
			Pergunte(cPerg,.F.)
		EndIf
		nOpcA := 1
	EndIf
Else
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Inicializacao do processamento automatico                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	ConOut("-",80)
	ConOut(STR0002+" - "+STR0007,80) //"Lan‡amentos Contabeis Off-Line"###"Documento de Entrada"
	ConOut("")
	ConOut(STR0001) //"Parametros"
	ConOut("")	
	nOpcA := 1
	Pergunte(cPerg,.F.)
	dbSelectArea("SX1")
	dbSetOrder(1)
	MsSeek(Padr( cPerg, Len( X1_GRUPO ) , ' ' ))
	While SX1->(!Eof()) .And. SX1->X1_GRUPO == Padr( cPerg, Len( X1_GRUPO ) , ' ' )
		nX++		
		If nX <= Len(aPergunte)
			cMvPar  := "M->MV_PAR"+StrZero(nX,2)
			&cMvPar := aPergunte[nX]

			Do Case
			Case SX1->X1_TIPO=="N"
				cString := AllTrim(Str(aPergunte[nX],SX1->X1_TAMANHO,SX1->X1_DECIMAL))
			Case SX1->X1_TIPO=="D"
				cString := Dtoc(aPergunte[nX])
			Case SX1->X1_TIPO=="C"
				cString := 	aPergunte[nX]
			OtherWise
				cString := "NULL"
			EndCase
		Else
			cString := "NULL"
		EndIf
		ConOut(X1Pergunt()+": "+cString)
		SX1->( dbSkip() )
	EndDo
	ConOut("")
	ConOut("-",80)
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ CTBVALOK - Ponto de Entrada para validar o Processamento     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock("CTBVALOK")
	nOpcABkp := ExecBlock("CTBVALOK",.F.,.F.,{nOpcA,mv_par04,mv_par05,mv_par06,mv_par07})
	If Valtype(nOpcABkp) == "N"
		nOpcA := nOpcABkp
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÊ
//³Validação para multthread.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÊ
nNumProc:= IIF(nNumProc < 1 , 1, nNumProc) 

If nNumProc > 1 .And. nOpcA == 1
	If CtbValMult(.T.,MV_PAR02 == 1,MV_PAR01 == 1,MV_PAR03 ) 
		nOpcA := 1
	Else
		nOpcA := 0
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Processamento                                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If	nOpcA == 1
	If CanProcItvl(mv_par04, mv_par05,mv_par06,mv_par07,"CTBNFE")
		Do Case
		Case IsBlind() .And. !lAuto
			If nNumProc == 1
				ProcLogAtu("INICIO")
			Endif

			BatchProcess( 	cCadastro, 	STR0003 + Chr(13) + Chr(10) +;
				STR0004 + Chr(13) + Chr(10) +;
				STR0005 + Chr(13) + Chr(10) +;
				STR0006, "CTBNFE",;
				{ ||	MaCtbNfe(MV_PAR01==1,MV_PAR02==1,MV_PAR03,MV_PAR04,;
				MV_PAR05,MV_PAR06,MV_PAR07,If(cPaisLoc<>"BRA",MV_PAR08==1,.F.),Nil,.F.) },{ || .F. })
			
			If nNumProc == 1
				ProcLogAtu("FIM") 	
			Endif
		Case nNumProc > 1 .And. !lAuto .And. CtbValMult(.F.,MV_PAR02 == 1, MV_PAR01 == 1, MV_PAR03 )
			MsgRun( STR0016,, {|| CtbNFEMult(mv_par04,mv_par05,mv_par06,mv_par07,If(cPaisLoc<>"BRA",MV_PAR08==1,.F.),nNumProc) } ) //"Contabilizando..."
		Case !lAuto
			If nNumProc == 1
				ProcLogAtu("INICIO")
			Endif

			oRegua := MsNewProcess():New({|lEnd| MaCtbNfe(MV_PAR01==1,;
				MV_PAR02==1,;
				MV_PAR03,;
				MV_PAR04,;
				MV_PAR05,;
				MV_PAR06,;
				MV_PAR07,;
				If(cPaisLoc<>"BRA",MV_PAR08==1,.F.),;
				oRegua,;
				@lEnd) },STR0002,"",.T.)//"Lan‡amentos Contabeis Off-Line"
			oRegua:Activate() 

			If nNumProc == 1
				ProcLogAtu("FIM")
			Endif
		OtherWise
			If nNumProc == 1
				ProcLogAtu("INICIO")
			Endif

			MaCtbNfe(MV_PAR01==1,;
				MV_PAR02==1,;
				MV_PAR03,;
				MV_PAR04,;
				MV_PAR05,;
				MV_PAR06,;
				MV_PAR07,;
				If(cPaisLoc<>"BRA",MV_PAR08==1,.F.),;
				Nil,;
				.F.)
			ConOut("Finished: "+Time())
			
			If nNumProc == 1
				ProcLogAtu("FIM")					
			Endif
		EndCase                           
	EndIf
	FreeProcItvl("CTBNFE")
EndIf

// Inicializa as variaveis staticas da contabilização
ClearCx105()

Return(.T.)
/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³MaCtbNfe  ³Autor  ³ Eduardo Riera         ³ Data ³20.10.2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³Rotina de contabilizacao dos documentos de entrada off-line  ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpL1: Mostra Lancamento Contabil                            ³±±
±±³          ³ExpL2: Aglutina lancamentos contabeis                        ³±±
±±³          ³ExpN3: Contabilizar por:                                     ³±±
±±³          ³       [1] Documento de Saida                                ³±±
±±³          ³       [2] Periodo                                           ³±±
±±³          ³ExpD4: Data de emissao inicial                               ³±±
±±³          ³ExpD5: Data de emissao final                                 ³±±
±±³          ³ExpC6: Codigo da filial inicial                              ³±±
±±³          ³ExpC7: Codigo da filial final                                ³±±
±±³          ³ExpO8: Objeto da interface                              (OPC)³±±
±±³          ³ExpL9: Flag de cancelamento da rotina                        ³±±
±±³          ³PARAMETROS PARA PROCESSAMENTO MULTITHREAD                    ³±±
±±³          ³ExpL10: Flag para processamento de Pedido                     ³±±
±±³          ³ExpL11: Flag para processamento de Nota Fiscal                ³±±
±±³          ³ExpL12: Pedido a ser Processado                               ³±±
±±³          ³ExpL13: Nota Fiscal a ser processada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                       ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Esta rotina tem como objetivo contabilizar os documentos de  ³±±
±±³          ³entrada com base nas regras dos lancamentos padronizados.    ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ CTB/COM/OMS                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MaCtbNfe(lDigita,lAglutina,nTpCtb,dDataIni,dDataFim,cFilDe,cFilAte,lContNCC,oObj,lEnd,lContPed,lContNFE,lMulti,cCodIni,cCodFim,lDevolucao)
Local aArea      := GetArea()
Local aStruSF1   := {}
Local aStruSD1   := {}
Local aStruSB1   := {}
Local aStruSF4   := {}
Local aStruSA1   := {}
Local aStruSA2   := {}
Local aStruSC7   := {}
Local aStruDKD   := {}
Local aCT5       := {}
Local aOptimize  := {}
Local aFilUser   := {}
Local aCTBAtu    := {}
Local aRecSEV 	 := {}
Local dSavBase   := dDataBase
Local dDataProc  := Ctod("")
Local lCtNfsDt   := ExistBlock("CTNFEDT")
Local lFilSf1    := Existblock("CTNFEFIL")
Local lLctPad40  := VerPadrao("640")	// Devolucao de Vendas 		  - SD1
Local lLctPad50  := VerPadrao("650")	// Debito de Estoque/Despesas - SD1
Local lLctPd50C  := VerPadrao("65C")	// Rateio Multiplas Naturezas - SD1
Local lLctPad51  := VerPadrao("651")	// Debito de Estoque/Despesas - SDE
Local lLctPad52  := VerPadrao("652")	// Pedido de Compra           - SC7
Local lLctPad60  := VerPadrao("660")	// Credito de Fornecedores/Credito da Compra - SF1
Local lLctPad42  := VerPadrao("642")	// Devolucao de Vendas - Total - SF1
Local lLctPad95  := VerPadrao("950")	// Credito de Fornecedores/Credito da compra - SF1 (SIGAEIC)
Local lLctPad59  := VerPadrao("659") .and. VerPadrao("652") .and. AliasInDic("SCH")	// Efetua Rateio Pedido de Venda?
Local lLctPad    := .F.
Local lDetProva  := .F.
Local lHeader    := .F.
Local lContinua  := .T.
Local lValido    := .F.
Local lInterface := oObj<>Nil
Local lOptimize  := .F.
Local lSkipSF1   := .F.
Local lFirst     := .F.
Local lRetPE     := .F.
Local lCTNFEORD  := .T.
Local lD1Cancel  := SD1->(FieldPos("D1_CANCEL")) > 0
Local lD1CtaRec  := SD1->(ColumnPos("D1_CTAREC")) > 0
Local cLoteCtb   := ""
Local cArqCtb    := ""
Local cAliasSD1  := "SD1"
Local cAliasSB1  := "SB1"
Local cAliasSF4  := "SF4"
Local cAliasSA1  := "SA1"
Local cAliasSA2  := "SA2"
Local cAliasSC7  := "SC7"
Local cAliasSF1  := "SF1"
Local cAliasBkp  := ""
Local cFornece   := ""
Local cLoja      := ""
Local cDocumento := ""
Local cSerie     := ""
Local cTipoNf    := ""
Local c640       := Nil
Local c650       := Nil
Local c65C		 := Nil 
Local c651       := Nil
Local c652       := Nil
Local c660       := Nil
Local c642       := Nil
Local c950       := Nil
Local dDtDigit   
Local dDtEmissao
Local cQuery     := ""
Local cQueryOrd  := ""
Local cString    := ""
Local cPedido    := ""
Local cDataCtb	 := "F1_DTDIGIT"
Local cKey       := ""
Local cCtaRec	 := ""
Local cSevTemp   := ""
Local nHdlPrv    := 0
Local nTotalCtb  := 0
Local nParcCtb	 := 0
Local nRecSF1    := 0
Local nRecSC7    := 0
Local nX         := 0
Local nY         := 0
Local nCar       := 0
Local nC         := 0
Local nV		 := 0

Local aFlagCTB   := {}
Local lUsaFlag   := GetNewPar("MV_CTBFLAG",.F.)
Local lOptNFe    := GetNewPar("MV_OPTNFE",.F.)
Local cCTBPais   := GetNewPar("MV_CTBPAIS","CHI,MEX")

Local lCTBNFE	 := ExistBlock("CTBNFE")
Local lCTBPC	 := ExistBlock("CTBPC")
Local lMvCTNFEORD:= ExistBlock("CTNFEORD")

//Variaveis para gravação do código de correlativo
Local aDiario    := {}
Local lSeqCorr   := UsaSeqCor("SF1/SF2/SC7")

Local lTemMov    := .F.
Local lExecLP    := .F.
Local cD1_TEC    := ""
Local aSM0       := AdmAbreSM0()
Local nContFil   := 0
Local __cFilAnt  := cFilAnt
Local lDKD		 := ChkFile("DKD") .and. hasCustomFields('DKD') //Tabela Complementar SD1

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa parametros DEFAULT                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DEFAULT lDigita    := .F.
DEFAULT lAglutina  := .F.
DEFAULT nTpCtb     := 1
DEFAULT dDataIni   := FirstDay(dDataBase)
DEFAULT dDataFim   := LastDay(dDataBase)
DEFAULT cFilDe     := cFilAnt
DEFAULT cFilAte    := cFilAnt  
DEFAULT lContNCC   := .T.
DEFAULT lEnd       := .F.
DEFAULT lContPed   := .T.
DEFAULT lContNFE   := .T.
DEFAULT lMulti     := .F.
DEFAULT cCodIni    := ""
DEFAULT cCodFim    := ""
DEFAULT lDevolucao := .F.

If !CtbInUse()				/// SIGACON NÃO FAZ A MARCAÇÃO DOS FLAGS DE CONTABILIZACAO
	lUsaFlag := .F.			/// MANTEM A MARCACAO DOS FLAGS PELA ROTINA DE CONTABILIZAÇÃO
Endif

IF Len( aSM0 ) <= 0
	Help(" ",1,"NOFILIAL")
	Return
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Compatibilizacao dos lancamentos contabeis                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
lLctPad  := lLctPad40 .Or. lLctPad50 .Or. lLctPad51 .Or. lLctPad52 .Or. lLctPad60 .Or. lLctPad42 .Or. lLctPad95
lContinua := lLctPad

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Montagem da primeira regua por filiais                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lInterface
	oObj:SetRegua1(Len(aSM0))
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Retorna as Filiais do usuário corrente  |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aFilUser := MatFilCalc(.f.,,,,,,.T.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ponto de entrada CTBNFEDT para alterar a contabilizacao para data de emissao        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock("CTBNFEDT")
	lRetPE:= ExecBlock("CTBNFEDT",.F.,.F.)
	If ValType (lRetPE) == "L" .And. lRetPE
		cDataCtb:= "F1_EMISSAO"
	EndIf
EndIf

//Verifica se é devolução e multithread
lDevolucao := lDevolucao .And. lMulti

For nContFil := 1 to Len(aSM0)
	
	If aSM0[nContFil][SM0_CODFIL] < cFilDe .Or. aSM0[nContFil][SM0_CODFIL] > cFilAte .Or. aSM0[nContFil][SM0_GRPEMP] != cEmpAnt  
		Loop
	EndIf
	
	If !lContinua
		Exit
	EndIf 
	cFilAnt := aSM0[nContFil][SM0_CODFIL]
	If aScan(aFilUser,{|x| ALLTRIM(x[2]) ==  ALLTRIM(cFilAnt)}) >0 .Or. !lInterface
		aCT5    := {}
		c640    := Nil
		c650    := Nil
		c65C	:= Nil 
		c651    := Nil
		c652    := Nil
		c660    := Nil
		c642    := Nil
		c950    := Nil	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Atualiza a regua de processamento de filiais                 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lInterface
			oObj:IncRegua1(STR0008+": "+aSM0[nContFil][SM0_CODFIL]+"/"+aSM0[nContFil][SM0_NOMRED]) //"Contabilizando"
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Contabilizando Pedido de Compra                              ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lLctPad52 .And. lContPed
		
			dbSelectArea("SC7")
			dbSetOrder(5)   // C7_EMISSAO + C7_NUM + C7_ITEM + C7_SEQUEN 
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifica o parametro de otimizacao                           ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lOptNFe
				lOptimize := .T.
			EndIf 
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Demonstra regua de processamento da query                    ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lInterface
				If lOptimize
					oObj:IncRegua2(STR0010) //"Executando processo de otimizacao com query"
				Else
					oObj:IncRegua2(STR0011) //"Executando query"
				EndIf
			EndIf				

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Montagem do Array de otimizacao de Query                     ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			aOptimize := {}					
			aadd(aOptimize,{}) //SELECT
			aadd(aOptimize,{}) //FROM
			aadd(aOptimize,{})	//WHERE

			If lOptimize
				cAliasSC7 := "CTBANFE"
				cAliasSB1 := "CTBANFE"
				cAliasSA2 := "CTBANFE"
			Else
				cAliasSC7 := "SC7_QRY"
				cAliasSB1 := "SC7_QRY"
				cAliasSA2 := "SC7_QRY"
			EndIf

			aStruSC7  := SC7->(dbStruct())
			aStruSB1  := SB1->(dbStruct())
			aStruSA2  := SA2->(dbStruct())
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Montagem da instrucao select                                 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			For nX := 1 To Len(aStruSC7)
				aadd(aOptimize[OPT_SELECT],aStruSC7[nX])
			Next nX
			If lOptimize
				For nX := 1 To Len(aStruSA2)
					If aStruSA2[nX][1]$"A2_FILIAL,A2_COD,A2_LOJA,A2_CONTA,A2_NOME,A2_NREDUZ"
						aadd(aOptimize[OPT_SELECT],aStruSA2[nX])
					EndIf
				Next nX
				For nX := 1 To Len(aStruSB1)
					If aStruSB1[nX][1]$"B1_FILIAL,B1_COD,B1_CONTA"
						aadd(aOptimize[OPT_SELECT],aStruSB1[nX])
					EndIf
				Next nX
			EndIf

			For nX := Len(aOptimize[OPT_SELECT]) To 1 Step -1 //Posicionando campo Memo no final do array
				If aOptimize[OPT_SELECT][nX][2] == "M"
					aadd(aOptimize[OPT_SELECT],aOptimize[OPT_SELECT][nX])
					aDel(aOptimize[OPT_SELECT],nX) 
					aSize(aOptimize[OPT_SELECT],Len(aOptimize[OPT_SELECT]) - 1)
				Endif
			Next		

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Montagem da instrucao from                                   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			aadd(aOptimize[OPT_FROM],{RetSqlName("SC7"),"SC7"})
			aadd(aOptimize[OPT_FROM],{RetSqlName("SB1"),"SB1"})
			aadd(aOptimize[OPT_FROM],{RetSqlName("SA2"),"SA2"})
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Montagem da instrucao where                                  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			aOptimize[OPT_WHERE] := "SC7.C7_FILIAL='"+xFilial("SC7")+"' AND "
			aOptimize[OPT_WHERE] += "SC7.C7_EMISSAO >= '"+Dtos(dDataIni)+"' AND "
			aOptimize[OPT_WHERE] += "SC7.C7_EMISSAO <= '"+Dtos(dDataFim)+"' AND "
			If lMulti .And. !Empty(cCodIni) .And. !Empty(cCodFim)
				aOptimize[OPT_WHERE] += "SC7.C7_NUM BETWEEN '" + cCodIni + "' AND '" + cCodFim + "' AND " 
			EndIf
			aOptimize[OPT_WHERE] += "SC7.C7_DTLANC = '"+Dtos(Ctod(""))+"' AND "
			aOptimize[OPT_WHERE] += "SC7.D_E_L_E_T_=' ' AND "
			aOptimize[OPT_WHERE] += "SB1.B1_FILIAL='"+xFilial("SB1")+"' AND "
			aOptimize[OPT_WHERE] += "SB1.B1_COD=SC7.C7_PRODUTO AND "
			aOptimize[OPT_WHERE] += "SB1.D_E_L_E_T_=' ' AND "
			aOptimize[OPT_WHERE] += "SA2.A2_FILIAL='"+xFilial("SA2")+"' AND "
			aOptimize[OPT_WHERE] += "SA2.A2_COD = SC7.C7_FORNECE AND "
			aOptimize[OPT_WHERE] += "SA2.A2_LOJA = SC7.C7_LOJA AND "
			aOptimize[OPT_WHERE] += "SA2.D_E_L_E_T_=' ' "
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Execucao do execblock para alteracao da query de otimizacao  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lCTBPC
				aOptimize := ExecBlock("CTBPC",.F.,.F.,aOptimize)
			EndIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Montagem da Query                                            ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ				
			cString := ""
			For nX := 1 To Len(aOptimize[OPT_SELECT])
				cString += ","+aOptimize[OPT_SELECT][nX][1]
			Next nX
			If lOptimize
				cQuery := "SELECT SC7.R_E_C_N_O_ SC7RECNO"+cString
			Else
				cQuery := "SELECT SC7.R_E_C_N_O_ SC7RECNO,"
				cQuery += "SA2.R_E_C_N_O_ SA2RECNO,"
				cQuery += "SB1.R_E_C_N_O_ SB1RECNO"+cString
			EndIf
			cString := ""
			For nX := 1 To Len(aOptimize[OPT_FROM])
				cString += ","+aOptimize[OPT_FROM][nX][1]+" "+aOptimize[OPT_FROM][nX][2]
			Next nX
			cQuery += " FROM "+SubStr(cString,2)
			cQuery += " WHERE "+aOptimize[OPT_WHERE]

			cQuery += " ORDER BY "+SqlOrder(SC7->(IndexKey()))

			cQuery := ChangeQuery(cQuery)

			If !lOptimize
				dbSelectArea("SC7")
				dbCloseArea()
			EndIf

			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSC7,.T.,.T.)

			For nX := 1 To Len(aOptimize[OPT_SELECT])
				If aOptimize[OPT_SELECT][nX][2]<>"C"
					TcSetField(cAliasSC7,aOptimize[OPT_SELECT][nX][1],aOptimize[OPT_SELECT][nX][2],aOptimize[OPT_SELECT][nX][3],aOptimize[OPT_SELECT][nX][4])
				EndIf
			Next nX
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Preparacao da contabilizacao por periodo                     ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If nTpCtb == 2
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Verifica o numero do lote contabil                           ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				dbSelectArea("SX5")
				dbSetOrder(1)
				If MsSeek(xFilial("SX5")+"09COM")
					cLoteCtb := AllTrim(X5Descri())
				Else
					cLoteCtb := "COM "
				EndIf		
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Executa um execblock                                         ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If At(UPPER("EXEC"),X5Descri()) > 0
					cLoteCtb := &(X5Descri())
				EndIf
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Inicializa o arquivo de contabilizacao                       ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		
				nHdlPrv:=HeadProva(cLoteCtb,"CTBANFE",Subs(cUsuario,7,6),@cArqCtb)
				IF nHdlPrv <= 0
					HELP(" ",1,"SEM_LANC")
					lContinua := .F.
				Else
					lHeader := .T.
				EndIf		
			EndIf			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Montagem da segunda regua por periodo                        ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lInterface
				oObj:SetRegua2(dDataFim+1-dDataIni)
			EndIf
			dDataProc := dDataIni
			dbSelectArea(cAliasSC7)

			While ( !Eof() .And. (cAliasSC7)->C7_FILIAL == xFilial("SC7") .And.;
					(cAliasSC7)->C7_EMISSAO <= dDataFim .And. lContinua)
	
				lValido   := .T.
				lDetProva := .F.                                          			
				cPedido   := (cAliasSC7)->C7_NUM                          
				dDtEmissao:= (cAliasSC7)->C7_EMISSAO                        
	
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Verifica se a nota nao foi contabilizada                     ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If !Empty((cAliasSC7)->C7_DTLANC)
					lValido := .F.
				EndIf
					
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Inicia a contabilizacao deste documento de saida             ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ			
				If lValido
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Posiciona no Cabecalho do documento de saida                 ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If !lOptimize
						SC7->(MsGoto((cAliasSC7)->SC7RECNO))
					Else
						nRecSC7 := (cAliasSC7)->SC7RECNO
					EndIf

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Define as chaves de relacionamento SIGACTB
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If lLctPad40
						c640       := CtRelation("640",.F.,{{cAliasSC7,"SC7"},{cAliasSC7,"SC7_QRY"},{cAliasSC7,"CTBANFE"}})
					Endif
					If lLctPad50
						c650       := CtRelation("650",.F.,{{cAliasSC7,"SC7"},{cAliasSC7,"SC7_QRY"},{cAliasSC7,"CTBANFE"}})
					Endif
					If lLctPd50C
						c65C       := CtRelation("65C",.F.,{{cAliasSC7,"SC7"},{cAliasSC7,"SC7_QRY"},{cAliasSC7,"CTBANFE"}})
					EndIf
					If lLctPad51
						c651       := CtRelation("651",.F.,{{cAliasSC7,"SC7"},{cAliasSC7,"SC7_QRY"},{cAliasSC7,"CTBANFE"}})
					Endif
					If lLctPad52
						c652       := CtRelation("652",.F.,{{cAliasSC7,"SC7"},{cAliasSC7,"SC7_QRY"},{cAliasSC7,"CTBANFE"}})
					Endif
					If lLctPad60
						c660       := CtRelation("660",.F.,{{cAliasSC7,"SC7",{cAliasSC7,"SC7_QRY"},{cAliasSC7,"CTBANFE"}}})
					Endif
					If lLctPad42
						c642       := CtRelation("642",.F.,{{cAliasSC7,"SC7"},{cAliasSC7,"SC7_QRY"},{cAliasSC7,"CTBANFE"}})
					Endif
					If lLctPad95
						c950       := CtRelation("950",.F.,{{cAliasSC7,"SC7"},{cAliasSC7,"SC7_QRY"},{cAliasSC7,"CTBANFE"}})
					Endif	
	
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Ajusta a data base com a data de contabilizacao              ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					Do Case
					Case nTpCtb == 1 .Or. nTpCtb == 3 
						dDataBase := (cAliasSC7)->C7_EMISSAO
					Case nTpCtb == 2
						dDataBase := dDataFim
					EndCase
	
					If lUsaFlag
						aAdd(aFlagCTB,{"C7_DTLANC",dDataBase,"SC7",(cAliasSC7)->SC7RECNO,0,0,0})
					EndIf
					If lSeqCorr
						aAdd(aDiario, {"SC7",(cAliasSC7)->SC7RECNO,(cAliasSC7)->C7_DIACTB,"C7_NODIA","C7_DIACTB"} )
					EndIf
	
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Preparacao da contabilizacao por documento                   ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					Begin Transaction
						If 	!lHeader
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³ Verifica o numero do lote contabil                           ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							dbSelectArea("SX5")
							dbSetOrder(1)
							If MsSeek(xFilial("SX5")+"09COM")
								cLoteCtb := AllTrim(X5Descri())
							Else
								cLoteCtb := "COM "
							EndIf		
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³ Executa um execblock                                         ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							If At("EXEC",Upper(X5Descri())) > 0
								cLoteCtb := &(X5Descri())
							EndIf
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³ Inicializa o arquivo de contabilizacao                       ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							nHdlPrv:=HeadProva(cLoteCtb,"CTBANFE",Subs(cUsuario,7,6),@cArqCtb)
							IF nHdlPrv <= 0
								HELP(" ",1,"SEM_LANC")
								lContinua := .F.
							Else
								lHeader := .T.
							EndIf		
						EndIf
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Posiciona registros vinculados ao Pedido de compra           ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						dbSelectArea("SA2")
						dbSetOrder(1)
						If !lOptimize
							SA2->(MsGoto((cAliasSA2)->SA2RECNO))
						EndIf
						dbSelectArea(cAliasSC7)
						dbSelectArea("SB1")
						dbSetOrder(1)
						If !lOptimize
							SB1->(MsGoto((cAliasSB1)->SB1RECNO))
						EndIf
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Executa os lancamentos contabeis ( 652 ) - Item              ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If lHeader
							lDetProva := .T.
								nParcCtb 	:= DetProva(nHdlPrv,"652","CTBANFE",cLoteCtb,,,,,@c652,@aCT5,,@aFlagCTB )
							If lLctPad59
								CTBANFERAT(xFilial("SC7")+SC7->C7_NUM+SC7->C7_FORNECE+SC7->C7_LOJA+SC7->C7_ITEM,@nParcCtb,nHdlPrv,cLoteCtb,@c652,@aCT5,@aFlagCTB)
							EndIf
							If nParcCtb > 0
								nTotalCtb 	+= nParcCtb
							ElseIf Len(aFlagCTB) > 0
								aDel (aFlagCTB,Len(aFlagCTB))
								aSize(aFlagCTB,Len(aFlagCTB)-1)
							EndIf							
						EndIf
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Atualiza a data de lancamento contabil para nao refaze-lo    ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If lDetProva .And. lHeader
							If  lOptimize
								SC7->(MsGoto(nRecSC7))
							EndIf
							If !lUsaFlag
								RecLock("SC7")
								SC7->C7_DTLANC := dDataBase
								MsUnlock()
							EndIf
						EndIf
					End Transaction
				EndIf		    	
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Verifico a quebra de Pedido de compra                        ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	    	
				dbSelectArea(cAliasSC7)
				dbSkip()
				If nTpCtb == 1 .And. lHeader .And. cPedido <> (cAliasSC7)->C7_NUM
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Fecha os lancamentos contabeis                               ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					lHeader   := .F.
					RodaProva(nHdlPrv,nTotalCtb)
					If nTotalCtb > 0
						nTotalCtb := 0
						cA100Incl(cArqCtb,nHdlPrv,1,cLoteCtb,lDigita,lAglutina,,,,@aFlagCTB,,aDiario)
						aDiario := {}
					EndIf
				EndIf
				dbSelectArea(cAliasSC7)
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Atualiza a regua de processamento por periodo                ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If dDataProc<>(cAliasSC7)->C7_EMISSAO
					While dDataProc<=(cAliasSC7)->C7_EMISSAO
						If lInterface
							oObj:IncRegua2(STR0013+": "+Dtoc((cAliasSC7)->C7_EMISSAO)) //"Pedido de Compra "
						EndIf
						dDataProc++
					EndDo
				EndIf
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Verifica se a contabilizacao foi abortada                    ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If lInterface .And. lEnd
					oObj:IncRegua2(STR0012) //"Aguarde abortando execucao"
				EndIf	 
				If lEnd
					Exit
				EndIf  	 
												
				If nTpCtb == 3 .And. (cAliasSC7)->C7_EMISSAO <> dDtEmissao //-- Contabiliza por Dia
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Fecha os lancamentos contabeis                               ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					lHeader   := .F.
					RodaProva(nHdlPrv,nTotalCtb)
					If nTotalCtb > 0
						nTotalCtb := 0			
						cA100Incl(cArqCtb,nHdlPrv,1,cLoteCtb,lDigita,lAglutina,,,,@aFlagCTB,,aDiario)
						aDiario := {}
					EndIf
				EndIf
					
			EndDo
			If nTpCtb == 2 .And. lHeader
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Fecha os lancamentos contabeis                               ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				lHeader   := .F.
				RodaProva(nHdlPrv,nTotalCtb)
				If nTotalCtb > 0
					nTotalCtb := 0			
					cA100Incl(cArqCtb,nHdlPrv,1,cLoteCtb,lDigita,lAglutina,,,,@aFlagCTB,,aDiario)
					aDiario := {}
				EndIf
			EndIf
	
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Retorna a situacao inicial                                   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			dbSelectArea(cAliasSC7)
			dbCloseArea()
			If !lOptimize
				ChkFile("SC7")
			Else
				dbSelectArea("SC7")
			EndIf
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica se a contabilizacao foi abortada                    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lEnd
			Exit
		EndIf	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Contabilizando do documento de entrada                       ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		
		If lContNFE
			For nY := 1 To 2
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Processa os documentos de entrada da filial corrente         ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				dbSelectArea("SF1")
				dbSetOrder(1)
				dbSelectArea("SD1")
				dbSetOrder(1)
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Verifica o parametro de otimizacao                           ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If lOptNFe
					lOptimize := .T.
				EndIf
				
				//Se for devolução evita o primeiro loop
				If lDevolucao .And. nY == 1
					Loop
				EndIf

				//Se for devolução não deve sair do loop
				If lMulti .And. nY == 2 .And. !lDevolucao
					Exit
				EndIf

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Demonstra regua de processamento da query                    ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If lInterface
					If lOptimize
						oObj:IncRegua2(STR0010) //"Executando processo de otimizacao com query"
					Else
						oObj:IncRegua2(STR0011) //"Executando query"
					EndIf
				EndIf				

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Montagem do Array de otimizacao de Query                     ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				aOptimize := {}					
				aadd(aOptimize,{}) //SELECT
				aadd(aOptimize,{}) //FROM
				aadd(aOptimize,{})	//WHERE

				If lOptimize
					cAliasSF1 := "CTBANFE"
					cAliasSD1 := "CTBANFE"
					cAliasSB1 := "CTBANFE"
					cAliasSF4 := "CTBANFE"
					cAliasSA1 := "CTBANFE"
					cAliasSA2 := "CTBANFE"
				Else
					cAliasSF1 := "QRYSD1"
					cAliasSD1 := "QRYSD1"
					cAliasSB1 := "QRYSD1"
					cAliasSF4 := "QRYSD1"
					cAliasSA1 := "QRYSD1"
					cAliasSA2 := "QRYSD1"
				EndIf

				aStruSF1  := SF1->(dbStruct())
				aStruSD1  := SD1->(dbStruct())
				aStruSB1  := SB1->(dbStruct())
				aStruSF4  := SF4->(dbStruct())
				aStruSA1  := SA1->(dbStruct())
				aStruSA2  := SA2->(dbStruct())
				If lDKD
					aStruDKD  := DKD->(dbStruct())
				EndIf

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Montagem da instrucao select                                 ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				For nX := 1 To Len(aStruSF1)
					If !"F1_BASE"$aStruSF1[nX][1] .and. !"F1_BASI"$aStruSF1[nX][1]
						aadd(aOptimize[OPT_SELECT],aStruSF1[nX])
					EndIf
				Next nX
				For nX := 1 To Len(aStruSD1)
					If !"D1_BASE"$aStruSD1[nX][1] .and. !"D1_BASI"$aStruSD1[nX][1] .and. !"D1_ALQI"$aStruSD1[nX][1] .And. !"D1_CP"$aStruSD1[nX][1]
						aadd(aOptimize[OPT_SELECT],aStruSD1[nX])
					EndIf
				Next nX 
				If lDKD .and. lOptimize
					For nX := 1 To Len(aStruDKD)
						If !"DKD_FILIAL"$aStruDKD[nX][1] .And. !"DKD_DOC"$aStruDKD[nX][1] .And. !"DKD_SERIE"$aStruDKD[nX][1] .And.;
							!"DKD_FORNEC"$aStruDKD[nX][1] .And. !"DKD_LOJA"$aStruDKD[nX][1] .And. !"DKD_EMISSA"$aStruDKD[nX][1] .And.;
							!"DKD_ESPECI"$aStruDKD[nX][1] .And. !"DKD_ITEM"$aStruDKD[nX][1]
							aadd(aOptimize[OPT_SELECT],aStruDKD[nX])
						EndIf
					Next nX
				EndIf

				If lOptimize
					If nY == 1
						For nX := 1 To Len(aStruSA2)
							If aStruSA2[nX][1]$"A2_FILIAL,A2_COD,A2_LOJA,A2_CONTA,A2_NOME,A2_NREDUZ"
								aadd(aOptimize[OPT_SELECT],aStruSA2[nX])
							EndIf
						Next nX
					Else
						For nX := 1 To Len(aStruSA1)
							If aStruSA1[nX][1]$"A1_FILIAL,A1_COD,A1_LOJA,A1_CONTA,A1_NOME,A1_NREDUZ"
								aadd(aOptimize[OPT_SELECT],aStruSA1[nX])
							EndIf
						Next nX					
					EndIf
					For nX := 1 To Len(aStruSB1)
						If aStruSB1[nX][1]$"B1_FILIAL,B1_COD,B1_CONTA"
							aadd(aOptimize[OPT_SELECT],aStruSB1[nX])
						EndIf
					Next nX
					For nX := 1 To Len(aStruSF4)
						If aStruSF4[nX][1]$"F4_FILIAL,F4_CODIGO,F4_CF"
							aadd(aOptimize[OPT_SELECT],aStruSF4[nX])
						EndIf
					Next nX
				EndIf	

				For nX := Len(aOptimize[OPT_SELECT]) To 1 Step -1 //Posicionando campo Memo no final do array
					If aOptimize[OPT_SELECT][nX][2] == "M"
						aadd(aOptimize[OPT_SELECT],aOptimize[OPT_SELECT][nX])
						aDel(aOptimize[OPT_SELECT],nX) 
						aSize(aOptimize[OPT_SELECT],Len(aOptimize[OPT_SELECT]) - 1)
					Endif
				Next	
					
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Montagem da instrucao from                                   ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				aadd(aOptimize[OPT_FROM],{RetSqlName("SF1"),"SF1"})
				aadd(aOptimize[OPT_FROM],{RetSqlName("SD1"),"SD1"})
				aadd(aOptimize[OPT_FROM],{RetSqlName("SB1"),"SB1"})
				aadd(aOptimize[OPT_FROM],{RetSqlName("SF4"),"SF4"})
				If lDKD .and. lOptimize
					aadd(aOptimize[OPT_FROM],{RetSqlName("DKD"),"DKD"})
				EndIf
				If nY == 1
					aadd(aOptimize[OPT_FROM],{RetSqlName("SA2"),"SA2"})
				Else
					aadd(aOptimize[OPT_FROM],{RetSqlName("SA1"),"SA1"})					
				EndIf
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Montagem da instrucao where                                  ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				aOptimize[OPT_WHERE] := "SF1.F1_FILIAL='"+xFilial("SF1")+"' AND "
				aOptimize[OPT_WHERE] += "SF1."+cDataCtb+" >= '"+Dtos(dDataIni)+"' AND "
				aOptimize[OPT_WHERE] += "SF1."+cDataCtb+" <= '"+Dtos(dDataFim)+"' AND "
				If lMulti .And. !Empty(cCodIni) .And. !Empty(cCodFim)
					aOptimize[OPT_WHERE] += "SF1.F1_DOC BETWEEN '" + cCodIni + "' AND '" + cCodFim + "' AND "
				EndIf
				aOptimize[OPT_WHERE] += "SF1.F1_DTLANC = '"+Dtos(Ctod(""))+"' AND "
				aOptimize[OPT_WHERE] += "SF1.D_E_L_E_T_=' ' AND "
				aOptimize[OPT_WHERE] += "SD1.D1_FILIAL = '"+xFilial("SD1")+"' AND "
				aOptimize[OPT_WHERE] += "SD1.D1_DOC = SF1.F1_DOC AND "
				aOptimize[OPT_WHERE] += "SD1.D1_SERIE = SF1.F1_SERIE AND "
				aOptimize[OPT_WHERE] += "SD1.D1_FORNECE = SF1.F1_FORNECE AND "
				aOptimize[OPT_WHERE] += "SD1.D1_LOJA = SF1.F1_LOJA AND "
				aOptimize[OPT_WHERE] += "SD1.D1_TIPO = SF1.F1_TIPO AND "
				aOptimize[OPT_WHERE] += "SD1.D1_TES <> '"+Space(Len(SD1->D1_TES))+"' AND "
				aOptimize[OPT_WHERE] += "SD1.D_E_L_E_T_=' ' AND "
				aOptimize[OPT_WHERE] += "(SD1.D1_ORIGLAN<>'LF' OR SF1.F1_IMPORT='S') AND "
				If lDKD .and. lOptimize
					aOptimize[OPT_WHERE] += "DKD.DKD_FILIAL='"+xFilial("DKD")+"' AND "
					aOptimize[OPT_WHERE] += "DKD.DKD_DOC=SD1.D1_DOC AND "
					aOptimize[OPT_WHERE] += "DKD.DKD_SERIE=SD1.D1_SERIE AND "
					aOptimize[OPT_WHERE] += "DKD.DKD_FORNEC=SD1.D1_FORNECE AND "
					aOptimize[OPT_WHERE] += "DKD.DKD_LOJA=SD1.D1_LOJA AND "
					aOptimize[OPT_WHERE] += "DKD.DKD_EMISSA=SD1.D1_EMISSAO AND "
					aOptimize[OPT_WHERE] += "DKD.DKD_ESPECI=SF1.F1_ESPECIE AND "
					aOptimize[OPT_WHERE] += "DKD.DKD_ITEM=SD1.D1_ITEM AND "
					aOptimize[OPT_WHERE] += "DKD.D_E_L_E_T_=' ' AND "
				EndIf
				aOptimize[OPT_WHERE] += "SB1.B1_FILIAL='"+xFilial("SB1")+"' AND "
				aOptimize[OPT_WHERE] += "SB1.B1_COD=SD1.D1_COD AND "
				aOptimize[OPT_WHERE] += "SB1.D_E_L_E_T_=' ' AND "
				aOptimize[OPT_WHERE] += "SF4.F4_FILIAL='"+xFilial("SF4")+"' AND "
				aOptimize[OPT_WHERE] += "SF4.F4_CODIGO=SD1.D1_TES AND "	
				aOptimize[OPT_WHERE] += "SF4.D_E_L_E_T_=' ' AND "
				If nY == 1
					aOptimize[OPT_WHERE] += "SA2.A2_FILIAL='"+xFilial("SA2")+"' AND "
					aOptimize[OPT_WHERE] += "SA2.A2_COD = SF1.F1_FORNECE AND "
					aOptimize[OPT_WHERE] += "SA2.A2_LOJA = SF1.F1_LOJA AND "
					aOptimize[OPT_WHERE] += "SA2.D_E_L_E_T_=' ' AND "
					aOptimize[OPT_WHERE] += "SF1.F1_TIPO NOT IN('D','B') "
				Else
					aOptimize[OPT_WHERE] += "SA1.A1_FILIAL='"+xFilial("SA1")+"' AND "
					aOptimize[OPT_WHERE] += "SA1.A1_COD = SF1.F1_FORNECE AND "
					aOptimize[OPT_WHERE] += "SA1.A1_LOJA = SF1.F1_LOJA AND "
					aOptimize[OPT_WHERE] += "SA1.D_E_L_E_T_=' ' AND "
					aOptimize[OPT_WHERE] += "SF1.F1_TIPO IN('D','B') "
				EndIf

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Execucao do execblock para alteracao da query de otimizacao  ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If lCTBNFE
					aOptimize := ExecBlock("CTBNFE",.F.,.F.,aOptimize)
				EndIf
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Montagem da Query                                            ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ				
				cString := ""
				For nX := 1 To Len(aOptimize[OPT_SELECT])
					cString += ","+aOptimize[OPT_SELECT][nX][1]
				Next nX
				If lOptimize
					cQuery := "SELECT SF1.R_E_C_N_O_ SF1RECNO,"
					cQuery += "SD1.R_E_C_N_O_ SD1RECNO"
					If lDKD
						cQuery += ",DKD.R_E_C_N_O_ DKDRECNO"
					EndIf
					cQuery += cString
				Else
					cQuery := "SELECT SF1.R_E_C_N_O_ SF1RECNO,"
					If nY == 1
						cQuery += "SA2.R_E_C_N_O_ SA2RECNO,"
					Else
						cQuery += "SA1.R_E_C_N_O_ SA1RECNO,"						
					EndIf
					cQuery += "SF4.R_E_C_N_O_ SF4RECNO,"
					cQuery += "SD1.R_E_C_N_O_ SD1RECNO,"
					cQuery += "SB1.R_E_C_N_O_ SB1RECNO"
					cQuery += cString
				EndIf
				cString := ""
				For nX := 1 To Len(aOptimize[OPT_FROM])
					cString += ","+aOptimize[OPT_FROM][nX][1]+" "+aOptimize[OPT_FROM][nX][2]
				Next nX
				cQuery += " FROM "+SubStr(cString,2)
				cQuery += " WHERE "+aOptimize[OPT_WHERE]

				If nTpCtb == 3
					If cPaisLoc<>"PER"
						cQueryOrd := " ORDER BY " + SqlOrder("F1_FILIAL+"+cDataCtb+"+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA+F1_TIPO")+","+SqlOrder(SD1->(IndexKey()))
					Else
						cQueryOrd := " ORDER BY " + SqlOrder("F1_FILIAL+"+cDataCtb+"+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA+F1_TIPO")+","+SqlOrder(SD1->(IndexKey()))
					EndIf
				Else  
					If cPaisLoc<>"PER"
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Modificar o Ordenacao para que seja igual ao DBF³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If lMvCTNFEORD
							lCTNFEORD := ExecBlock("CTNFEORD",.F.,.F.)
						EndIf 
						If lCTNFEORD
							cQueryOrd := " ORDER BY " + SqlOrder(SF1->(IndexKey()))+","+SqlOrder(SD1->(IndexKey()))
						Else
							cQueryOrd := " ORDER BY F1_FILIAL,F1_DTDIGIT,F1_SERIE,F1_DOC,F1_FORNECE,F1_LOJA,F1_TIPO"
						EndIf	            
					Else
						If MV_PAR03==1   //Especifico para Peru - tratamento correlativos.
							cQueryOrd:= "ORDER BY "
							cKey := SqlOrder(SF1->(IndexKey()))
							nCar:=AT("F1_DOC",cKey)
							If nCar>0
								cQueryOrd +=Substr(cKey,1,nCar-1)+"F1_DTDIGIT,"+Subs(cKey,nCar,Len(cKey))
							EndIf 

							cKey:=SqlOrder(SD1->(IndexKey())) 
							nCar:=AT("D1_DOC",cKey)
							If nCar>0
								cQueryOrd +=","+Substr(cKey,1,nCar-1)+"D1_DTDIGIT,"+Subs(cKey,nCar,Len(cKey))
							EndIf
						Else
							cQueryOrd := " ORDER BY " + SqlOrder(SF1->(IndexKey()))+","+SqlOrder(SD1->(IndexKey()))            
						EndIf
					EndIf
				EndIf

				cQuery += cQueryOrd
				cQuery := ChangeQuery(cQuery)

				dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSF1,.T.,.T.)				

				For nX := 1 To Len(aOptimize[OPT_SELECT])
					If aOptimize[OPT_SELECT][nX][2]<>"C"
						TcSetField(cAliasSF1,aOptimize[OPT_SELECT][nX][1],aOptimize[OPT_SELECT][nX][2],aOptimize[OPT_SELECT][nX][3],aOptimize[OPT_SELECT][nX][4])
					EndIf
				Next nX
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Preparacao da contabilizacao por periodo                     ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If lLctPad .And. nTpCtb == 2
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Verifica o numero do lote contabil                           ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					dbSelectArea("SX5")
					dbSetOrder(1)
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ No chile contabiliza NCC separada de NF, por isto deve ser   ³
					//³ contabilizado com LOTE DIFERENCIADO.                         ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		     		If cPaisLoc $ cCTBPais .And. (AllTrim(cModulo) == "FAT") 
						If MsSeek(xFilial("SX5")+"09FAT")
							cLoteCtb := AllTrim(X5Descri())
						Else
							cLoteCtb := "FAT "
						EndIf		
					Else
						If MsSeek(xFilial("SX5")+"09COM")
							cLoteCtb := AllTrim(X5Descri())
						Else
							cLoteCtb := "COM "
						EndIf		
					Endif
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Executa um execblock                                         ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If At(UPPER("EXEC"),X5Descri()) > 0
						cLoteCtb := &(X5Descri())
					EndIf
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Inicializa o arquivo de contabilizacao                       ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		
					nHdlPrv:=HeadProva(cLoteCtb,"CTBANFE",Subs(cUsuario,7,6),@cArqCtb)
					IF nHdlPrv <= 0
						HELP(" ",1,"SEM_LANC")
						lContinua := .F.
					Else
						lHeader := .T.
					EndIf		
				EndIf			
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Montagem da segunda regua por periodo                        ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If lInterface
					oObj:SetRegua2(dDataFim+1-dDataIni)
				EndIf
				dDataProc := dDataIni
				dbSelectArea(cAliasSF1)
				While ( !Eof() .And. (cAliasSF1)->F1_FILIAL == xFilial("SF1") .And.;
						&((cAliasSF1)->(cDataCtb)) <= dDataFim .And. lContinua)
		
					lValido   := .T.
					lDetProva := .F.
					lSkipSF1  := .T.
		         	dDtDigit  := &((cAliasSF1)->(cDataCtb))
		
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Verifica se a nota nao foi contabilizada                     ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If Empty((cAliasSF1)->F1_DTLANC)
						If cPaisLoc <> "BRA" .And. !Empty(&((cAliasSF1)->(cDataCtb))) 
			           		If (cPaisLoc $ cCTBPais .And. ((AllTrim(cModulo) $ "COM|EST") .And. Alltrim((cAliasSF1)->F1_TIPO) == "D") .Or. ((AllTrim(cModulo) == "FAT") .And. Alltrim((cAliasSF1)->F1_TIPO) <> "D")) .And. !(Alltrim((cAliasSF1)->D1_ESPECIE) == "NCC") 
							    lValido := .F.
							Else
								If Alltrim((cAliasSF1)->F1_TIPO) == "D"
									lValido := lContNCC //verifica se contabiliza ou nao as notas de credito.
								EndIf							
							EndIf	
						Endif
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Executa a filtragem da customizacao                          ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If lFilSf1
							If !(Execblock("CTNFEFIL",.F.,.F.,{cAliasSF1}))
								lValido := .F.
							EndIf
						EndIf
					Else
						lValido := .F.
					EndIf
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Inicia a contabilizacao deste documento de saida             ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ			
					If lValido
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Posiciona no Cabecalho do documento de saida                 ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If !lOptimize
							SF1->(MsGoto((cAliasSF1)->SF1RECNO))
						Else
							nRecSF1 := (cAliasSF1)->SF1RECNO
						EndIf
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Ajusta a data base com a data de contabilizacao              ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						Do Case
						Case nTpCtb == 1 .Or. nTpCtb == 3 
							dDataBase := &((cAliasSF1)->(cDataCtb))
							If lCtNfsDt
								dDataBase := Execblock("CTNFEDT",.F.,.F.)
							EndIf
						Case nTpCtb == 2
							dDataBase := dDataFim
						EndCase
		
						If lUsaFlag
							aAdd(aFlagCTB,{"F1_DTLANC",dDataBase,"SF1",(cAliasSF1)->SF1RECNO,0,0,0})
						EndIf
						If lSeqCorr
							aAdd(aDiario, {"SF1",(cAliasSF1)->SF1RECNO,(cAliasSF1)->F1_DIACTB,"F1_NODIA","F1_DIACTB"})
						EndIf
		
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Preparacao da contabilizacao por documento                   ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						Begin Transaction
							If 	!lHeader
								//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
								//³ Verifica o numero do lote contabil                           ³
								//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
								dbSelectArea("SX5")
								dbSetOrder(1)
								If MsSeek(xFilial("SX5")+"09COM")
									cLoteCtb := AllTrim(X5Descri())
								Else
									cLoteCtb := "COM "
								EndIf		
		                        
								//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
								//³ No chile contabiliza NCC separada de NF, por isto deve ser   ³
								//³ contabilizado com LOTE DIFERENCIADO.                         ³
								//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					     		If cPaisLoc $ cCTBPais .And. (AllTrim(cModulo) == "FAT")
							   		If  (cAliasSF1)->F1_TIPO =="D" 
										SX5->(MsSeek(xFilial("SX5")+"09FAT")) 
										cLoteCtb := AllTrim(X5Descri())
									Else
										cLoteCtb := "FAT "
									EndIf	
								EndIf
								//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
								//³ Executa um execblock                                         ³
								//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
								If At("EXEC",Upper(X5Descri())) > 0
									cLoteCtb := &(X5Descri())
								EndIf
								//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
								//³ Inicializa o arquivo de contabilizacao                       ³
								//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
								nHdlPrv:=HeadProva(cLoteCtb,"CTBANFE",Subs(cUsuario,7,6),@cArqCtb)
								IF nHdlPrv <= 0
									HELP(" ",1,"SEM_LANC")
									lContinua := .F.
								Else
									lHeader := .T.
								EndIf		
							EndIf
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³ Posiciona registros vinculados ao cabecalho do documento     ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							If (cAliasSF1)->F1_TIPO $ "DB"
								dbSelectArea("SA1")
								dbSetOrder(1)
								If !lOptimize
									SA1->(MsGoto((cAliasSA1)->SA1RECNO))
								EndIf
							Else
								dbSelectArea("SA2")
								dbSetOrder(1)
								If !lOptimize
									SA2->(MsGoto((cAliasSA2)->SA2RECNO))
								EndIf
							EndIf
							dbSelectArea(cAliasSF1)

							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³ Processa os itens do documento de saida                      ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							dbSelectArea(cAliasSF1)
		
							cFornece   := (cAliasSF1)->F1_FORNECE
							cLoja      := (cAliasSF1)->F1_LOJA
							cDocumento := (cAliasSF1)->F1_DOC
							cSerie     := (cAliasSF1)->F1_SERIE
							cTipoNf    := (cAliasSF1)->F1_TIPO
							lValido    := .F.
							lFirst     := .T.
							lTemMov    := .F.
							lExecLP    := .F.
		
							While ( !Eof() .And. (cAliasSD1)->D1_FILIAL == xFilial("SD1") .And.;
									(cAliasSD1)->D1_DOC == cDocumento .And.;
									(cAliasSD1)->D1_SERIE == cSerie .And.;
									(cAliasSD1)->D1_FORNECE == cFornece .And.;
									(cAliasSD1)->D1_LOJA == cLoja )
		
								If 	( (cAliasSD1)->D1_ORIGLAN <> "LF" .Or. (cAliasSF1)->F1_IMPORT=="S" ) .And. ;
										!Empty((cAliasSD1)->D1_TES) .And. ;
										(cAliasSD1)->D1_TIPO==cTipoNf .And. ;
										IIf(lD1Cancel,(cAliasSD1)->D1_CANCEL<>"S",.T.)
		
									lValido := .T.
									//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
									//³ Posiciona registros vinculados ao item do documento          ³
									//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
									dbSelectArea("SB1")
									dbSetOrder(1)
									If !lOptimize
										SB1->(MsGoto((cAliasSB1)->SB1RECNO))
									EndIf
		
									dbSelectArea("SF4")
									dbSetOrder(1)
									If !lOptimize
										SF4->(MsGoto((cAliasSF4)->SF4RECNO))
									EndIf

									If !lOptimize
										dbSelectArea("SD1")
										dbSetOrder(1)
										MsGoTo((cAliasSD1)->(SD1RECNO))
									EndIf

									If lDKD .and. !lOptimize

										dbSelectArea("DKD")
										DKD->(dbSetOrder(1))//DKD_FILIAL+DKD_DOC+DKD_SERIE+DKD_FORNEC+DKD_LOJA+DKD_ITEM+DKD_EMISSA+DKD_ESPECI

										If DKD->(Msseek(SD1->(D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA+D1_ITEM)+DtoS(SD1->D1_EMISSAO)+SF1->F1_ESPECIE))
											DKD->(MsGoto(DKD->(Recno())))
										EndIf
									EndIf						
		                                         
				                    lTemMov := .T.
		                     
									//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
									//³ Executando os LP 660, 642 e 950 nesse momento, os lancamentos nao ficarao na mesma ordem ³
									//³ da contabilizacao On-Line, pois o parametro MV_OPTNFE esta .T.. Assim, ficara na ordem   ³
									//³ que a query gerar.   																							³
									//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ                                      
									If lFirst
										lFirst   := .F.
										cD1_TEC := (cAliasSD1)->D1_TEC
										If lOptimize
											ExecLP( lOptimize,lLctPad60,lHeader,cAliasSF1,@c660,cAliasSD1,@lDetProva,@nTotalCTB,;
													  nHdlPrv,cLoteCTB,@aCT5,@aFlagCTB,lLctPad42,@c642,lLctPad95,@c950,cTipoNF,cD1_TEC )
											lExecLP := .T.
										EndIf	        
									EndIf	       
			                  
									//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
									//³ Executa os lancamentos contabeis ( 640 ) - Item              ³
									//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
									If lLctPad40 .And. lHeader .And. (cAliasSD1)->D1_TIPO$"DB"
										c640       	:= CtRelation("640",.F.,{{cAliasSF1,"SF1"},{cAliasSD1,"SD1"},{cAliasSD1,"CTBANFE"}})
										lDetProva 	:= .T.
										nTotalCtb 	+= DetProva(nHdlPrv,"640","CTBANFE",cLoteCtb,,,,,@c640,@aCT5,,@aFlagCTB)
									ElseIf !(cAliasSD1)->D1_TIPO$"DB"
							 			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
										//³ Executa os lancamentos contabeis ( 650 ) - Item              ³
										//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
										cCtaRec := "" //Limpa a variavel devido processamento em laço
										c650       	:= CtRelation("650",.F.,{{cAliasSF1,"SF1"},{cAliasSD1,"SD1"},{cAliasSD1,"CTBANFE"}})
										lDetProva 	:= .T.
										nTotalCtb 	+= DetProva(nHdlPrv,"650","CTBANFE",cLoteCtb,,,,,@c650,@aCT5,,@aFlagCTB,,,,,,,@cCtaRec)
										// Adequacao para Gravar a Conta de Receita do Item da Nota, para uso no EFD-Contribuicoes
										If lD1CtaRec .And. !Empty(cCtaRec)
											Aadd(aCTBAtu,{"D1_CTAREC",cCtaRec,"SD1",(cAliasSD1)->(SD1RECNO),0,0,0})

											SFT->(DbSetOrder(1))
											If SFT->(DbSeek(xFilial("SFT")+"E"+(cAliasSD1)->(D1_SERIE+D1_DOC+D1_FORNECE+D1_LOJA+Padr(D1_ITEM,TAMSX3("FT_ITEM")[1])+D1_COD))) //FT_FILIAL+FT_TIPOMOV+FT_SERIE+FT_NFISCAL+FT_CLIEFOR+FT_LOJA+FT_ITEM+FT_PRODUTO 
												Aadd(aCTBAtu,{"FT_CONTA",cCtaRec,"SFT",SFT->(Recno()),0,0,0})
											EndIf
										EndIf
									EndIf
									//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
									//³ Processa lancamentos do rateio do item do documento - SDE    ³
									//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
									If (cAliasSD1)->D1_RATEIO=="1"
										dbSelectArea("SDE")
										dbSetOrder(1)
										MsSeek(xFilial("SDE")+(cAliasSD1)->D1_DOC+(cAliasSD1)->D1_SERIE+(cAliasSD1)->D1_FORNECE+(cAliasSD1)->D1_LOJA+(cAliasSD1)->D1_ITEM)
		
										While !Eof() .And. SDE->DE_FILIAL == xFilial("SDE") .And.;
												SDE->DE_DOC == (cAliasSD1)->D1_DOC .And.;
												SDE->DE_SERIE == (cAliasSD1)->D1_SERIE .And.;
												SDE->DE_FORNECE == (cAliasSD1)->D1_FORNECE .And.;
												SDE->DE_LOJA == (cAliasSD1)->D1_LOJA .And.;
												SDE->DE_ITEMNF == (cAliasSD1)->D1_ITEM
		
											If lLctPad51 .And. lHeader
												If !lOptimize
													dbSelectArea("SDE")
												EndIf
												c651      := CtRelation("651",.F.,{{cAliasSF1,"SF1"},{cAliasSD1,"SD1"},{cAliasSD1,"CTBANFE"}})
												lDetProva := .T.
												nTotalCtb += DetProva(nHdlPrv,"651","CTBANFE",cLoteCtb,,,,,@c651,@aCT5,,@aFlagCTB)
											EndIf
		
											dbSelectArea("SDE")
											dbSkip()                  
										EndDo								
									EndIf			
								EndIf
		
								dbSelectArea(cAliasSD1)
								dbSkip()
								lSkipSF1 := .F.
							EndDo

							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³ Processamento da LP 65C - Contabilização multiplas naturezas³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							If lLctPd50C

								//Posiciono na SE2 para que a função CtRelation abaixo retorne a chave de relacionamento
								//correta que está cadastrada na tabela CTL, assim preenchendo corretamente o campo CT2_KEY.
								DbSelectArea("SE2")
								SE2->(DbSetOrder(6))//E2_FILIAL+E2_FORNECE+E2_LOJA+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO
								If SE2->(DbSeek(fwxFilial("SE2") + cFornece + cLoja + cSerie + cDocumento)) 

									cSevTemp := GetNextAlias()	
									
									BeginSql Alias cSevTemp
									SELECT SEV.R_E_C_N_O_ AS RECNOSEV
									FROM	%Table:SEV% SEV
									WHERE SEV.EV_FILIAL = %xFilial:SEV%
										AND SEV.EV_NUM = %Exp:cDocumento%
										AND SEV.EV_CLIFOR = %Exp:cFornece%'
										AND SEV.EV_LOJA = %Exp:cLoja%
										AND SEV.%NotDel%
									EndSql

									aRecSEV := {}
									While ( (cSevTemp)->(!Eof()) )		
										aAdd(aRecSEV,{ (cSevTemp)->RECNOSEV})
										(cSevTemp)->(dbSkip())
									End
									
									DbSelectArea("SEV")
									For nV := 1 To Len(aRecSEV)
										SEV->(MsGoto(aRecSEV[nV][1]))
										c65C      := CtRelation("65C",.F.,{{cAliasSF1,"SF1"},{cAliasSD1,"SD1"},{cAliasSD1,"CTBANFE"}})
										lDetProva := .T.
										nTotalCtb += DetProva(nHdlPrv,"65C","CTBANFE",cLoteCtb,,,,,@c65C,@aCT5,,@aFlagCTB)
										SEV->(RecLock("SEV",.F.))
										SEV->EV_LA := "S"
										MsUnlock()
									Next nV

									(cSevTemp)->(DbCloseArea())
								Endif 

							EndIf				
							
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³ Executar os LP 660, 642 e 950 nesse momento, para que os lancamentos fiquem na mesma ordem da ³
							//³ contabilizacao On-Line. Executara somente se o parametro MV_OPTNFE estiver .F. ou se for      ³
							//³ ambiente CodBase																										  ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ                                      
							If lTemMov .And. !lExecLP
								//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
								//³ Atenção: O Alias é alterado quando for Query e não possuir Otimização de Query devido estar   ³
								//³          com o registro disposicionado ou seja: em situações onde for contabilizada apenas    |
								//|          uma NFE, a tabela de trabalho gerada pela query estará sem conteudo fazendo com que  |
								//|          na função:CtRelation não seja encontrada a chaves de relacionamento cadastradas na   |
								//|          tabela CTL.                                                                          |
								//|          Em situações onde existe mais de uma Nota Fiscal, a tabela fica posicionada sempre na|
								//|          próxima nota fiscal, fazendo com que por exemplo o campo: CT2_KEY fique com informa- |
								//|          ções da próxima nota ao invés da nota corrente.                                      |
		   						//|ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ|
							    if !lOptimize  
							        cAliasBkp := cAliasSF1
									cAliasSF1 := "SF1"    
							    EndIf                         
		
								ExecLP( lOptimize,lLctPad60,lHeader,cAliasSF1,@c660,cAliasSD1,@lDetProva,@nTotalCTB,;
										  nHdlPrv,cLoteCTB,@aCT5,@aFlagCTB,lLctPad42,@c642,lLctPad95,@c950,cTipoNF,cD1_TEC )
		
							    if !lOptimize  
									cAliasSF1 := cAliasBkp
							    EndIf
										  
		        	        EndIf
		               
							If Len(aFlagCtb) > 0 .And. aFlagCtb[Len(aFlagCTB),5] == 0 .And. aFlagCtb[Len(aFlagCTB),6] == 0 .And.;
							aFlagCtb[Len(aFlagCTB),7] == 0
								aDel (aFlagCTB,Len(aFlagCTB))
								aSize(aFlagCTB,Len(aFlagCTB)-1)								
							EndIf                             

							If Len(aCTBAtu) > 0
								For nC := 1 To Len(aCTBAtu)
									aAdd(aFlagCTB,aCTBAtu[nC])
								Next nC
							EndIf
							aCTBAtu := {}

							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³ Atualiza a data de lancamento contabil para nao refaze-lo    ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							If lOptimize
								SF1->(MsGoto(nRecSF1))
							EndIf
						
							If lDetProva .And. lHeader .And. nTotalCtb > 0
								If !lUsaFlag
									RecLock("SF1")
									SF1->F1_DTLANC := dDataBase
									MsUnlock()
								EndIf
							EndIf
						End Transaction
						If nTpCtb == 1 .And. lHeader
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³ Fecha os lancamentos contabeis                               ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							lHeader   := .F.
							RodaProva(nHdlPrv,nTotalCtb)
							If nTotalCtb > 0
								nTotalCtb := 0
								cA100Incl(cArqCtb,nHdlPrv,1,cLoteCtb,lDigita,lAglutina,,,,@aFlagCTB,,aDiario)
								aDiario := {}
							EndIf
						EndIf
					EndIf
					If lSkipSF1 
						dbSelectArea(cAliasSF1)
						dbSkip()
					Else
						dbSelectArea(cAliasSF1)
					EndIf
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Atualiza a regua de processamento por periodo                ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If dDataProc<> &((cAliasSF1)->(cDataCtb))
						While dDataProc<=&((cAliasSF1)->(cDataCtb))
							If lInterface
								oObj:IncRegua2(STR0014+": "+Dtoc(&((cAliasSF1)->(cDataCtb)))) //"Documento de"
							Endif
							dDataProc++
						EndDo
					EndIf
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Verifica se a contabilizacao foi abortada                    ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If lEnd
						Exit
					EndIf
		
					If nTpCtb == 3 .And. &((cAliasSF1)->(cDataCtb)) <> dDtDigit
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Fecha os lancamentos contabeis                               ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						lHeader   := .F.
						RodaProva(nHdlPrv,nTotalCtb)
						If nTotalCtb > 0
							nTotalCtb := 0			
							cA100Incl(cArqCtb,nHdlPrv,1,cLoteCtb,lDigita,lAglutina,,,,@aFlagCTB,,aDiario)
							aDiario := {}
						EndIf
					EndIf						
				EndDo
				
				If nTpCtb == 2 .And. lHeader
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Fecha os lancamentos contabeis                               ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					lHeader   := .F.
					RodaProva(nHdlPrv,nTotalCtb)
					If nTotalCtb > 0
						nTotalCtb := 0			
						cA100Incl(cArqCtb,nHdlPrv,1,cLoteCtb,lDigita,lAglutina,,,,@aFlagCTB,,aDiario)
						aDiario := {}
					EndIf
				EndIf						
		
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Retorna a situacao inicial                                   ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				dbSelectArea(cAliasSF1)
				dbCloseArea()
				If !lOptimize
					ChkFile("SD1")
				Else
					dbSelectArea("SD1")
				EndIf
			Next nY
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica se o arquivo e compartilhado para encerrar a contab.³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If Empty(FWFilial("SF1"))
			Exit
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica se a contabilizacao foi abortada                    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	EndIf
	If lEnd
		Exit
	EndIf
Next nContFil

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Restaura a integridade da Rotina                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
RestArea(aArea)
cFilAnt := __cFilAnt
dDataBase := dSavBase
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Efetua lancamentos contabeis do Remito                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If cPaisLoc <> "BRA"
	LocBlock("C230A",.F.,.F.)
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ CTBNFEFIM - Ponto de Entrada no final do processamento       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock("CTBNFEFIM")
	ExecBlock("CTBNFEFIM",.F.,.F.,{nTpCtb,dDataIni,dDataFim,cFilDe,cFilAte,lContNCC,lEnd})
EndIf

Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³EXECLP    ºAutor  ³Microsiga           º Data ³  05/19/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Executa os lancamentos padrao 660, 642 e 950               º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ExecLP( lOptimize,lLctPad60,lHeader,cAliasSF1,c660,cAliasSD1,lDetProva,nTotalCTB,;
                        nHdlPrv,cLoteCTB,aCT5,aFlagCTB,lLctPad42,c642,lLctPad95,c950,cTipoNF,cD1_TEC )
Default cD1_TEC := ""

If !lOptimize
	dbSelectArea("SF1")
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Executa os lancamentos contabeis ( 660 ) - Cabecalho         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lLctPad60 .And. lHeader .And. !(cTipoNF $ "DB")
	c660       := CtRelation("660",.F.,{{cAliasSF1,"SF1"},{cAliasSD1,"SD1"},{cAliasSD1,"CTBANFE"}})
	lDetProva  := .T.
	nTotalCtb  += DetProva(nHdlPrv,"660","CTBANFE",cLoteCtb,,,,,@c660,@aCT5,,@aFlagCTB)
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Executa os lancamentos contabeis ( 642 )-Cabecalho-Dev.Total ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lLctPad42 .And. lHeader .And. cTipoNF $ "DB"
	c642      := CtRelation("642",.F.,{{cAliasSF1,"SF1"},{cAliasSD1,"SD1"},{cAliasSD1,"CTBANFE"}})
	lDetProva := .T.
	nTotalCtb += DetProva(nHdlPrv,"642","CTBANFE",cLoteCtb,,,,,@c642,@aCT5,,@aFlagCTB)
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Executa os lancamentos contabeis ( 950 ) - Cabecalho         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lLctPad95 .And. lHeader .And. !Empty(cD1_TEC)
	c950      := CtRelation("950",.F.,{{cAliasSF1,"SF1"},{cAliasSD1,"SD1"},{cAliasSD1,"CTBANFE"}})
	lDetProva := .T.
	nTotalCtb += DetProva(nHdlPrv,"950","CTBANFE",cLoteCtb,,,,,@c950,@aCT5,,@aFlagCTB) 
EndIf

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CtbNFEMultºAutor  ³Alvaro Camillo Neto º Data ³  05/19/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Contabilização MultiThread de pedido de venda e NFE        º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function CtbNFEMult(dDataIni,dDataFim,cFilDe,cFilAte,lContNCC,nNumProc)
Local aArea 	  := GetArea()
Local aSM0 		  := AdmAbreSM0()
Local nContFil	  := 0
Local cFilIni	  := cFilAnt 
Local nX		  := 0  
Local lRet		  := .T.
Local lLctPad52  := VerPadrao("652",.T.)	// Pedido de Compra           - SC7

For nContFil := 1 to Len(aSM0)
	If aSM0[nContFil][SM0_CODFIL] < cFilDe .Or. aSM0[nContFil][SM0_CODFIL] > cFilAte .Or. aSM0[nContFil][SM0_GRPEMP] != cEmpAnt  
		Loop
	EndIf
	cFilAnt := aSM0[nContFil][SM0_CODFIL] 

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Atualiza o log de processamento   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	ProcLogAtu("INICIO")

	If lLctPad52
		//Contabilização de Pedido de Compras
		lRet := CtbMComPed(dDataIni,dDataFim,nNumProc)
    EndIf
    
	If lRet 
		For nX := 1 to 2
			//Contabilização de Nota Fiscal de Entrada
			lRet := CtbMComNFE(dDataIni,dDataFim,lContNCC,nNumProc , nX == 2)
		Next nX
		If !lRet
			Exit
		EndIf 
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Atualiza o log de processamento   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	ProcLogAtu("FIM")

Next nContFil

cFilAnt := cFilIni
RestArea(aArea)
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CtbMComNFEºAutor  ³Alvaro Camillo Neto º Data ³  05/19/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Contabilização da nota fiscal de entrada                    º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function CtbMComNFE(dDataIni,dDataFim,lContNCC,nNumProc,lDevolucao)
Local aArea := GetArea()
Local lRet	:= .T.
Local nX	:= 0
Local aProcs 		:= {}
Local aNfeMult	:= {}
Local nTotalReg	:= 0
Local cRaizNome	:= 'CTBNFEPROC'
Local cChave 	    := SF1->(IndexKey(1))  

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Monta o arquivo de trabalho³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aNfeMult := CtbGrvNFE(dDataIni,dDataFim,lDevolucao,cChave)

nTotalReg := Len(aNfeMult)

If nTotalReg > 0
	
	If nNumProc > 40
		nNumProc := 40
	Endif
	
	If  nTotalReg >= nNumProc .And. nNumProc > 1 // MultiThread
		aProcs := CTBPrepNFE(nNumProc,nTotalReg,cRaizNome,aNfeMult)
		//Inicializa as Threads Transação controlada nas Threads
		For nX := 1 to Len(aProcs)
			StartJob("JOBCTBNFE", GetEnvServer(), .F., cEmpAnt,cFilAnt,aProcs[nX][MARCA],aProcs[nX][ARQUIVO],lContNCC,dDataIni,dDataFim,cValToChar(nX),aProcs[nX][VAR_STATUS],cChave,__cUserId,cUserName,cAcesso,cUsuario,aProcs[nX][5],aProcs[nX][6],lDevolucao)
			Sleep(3000)
		Next nX
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Realiza o controle das Threads³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		Sleep(3000)
		lRet := NFEMonitor(aProcs,IIF(lDevolucao,2,1) )
	Else
		lRet := CtbProcNFE(lContNCC,dDataIni,dDataFim,"","",lDevolucao)
	EndIf
EndIf

RestArea(aArea)

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CtbMComPedºAutor  ³Alvaro Camillo Neto º Data ³  05/19/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Contabilização do pedido de compra                          º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function CtbMComPed(dDataIni,dDataFim,nNumProc)
Local aArea 		:= GetArea()
Local lRet 			:= .T.
Local nX			:= 0
Local aProcs 		:= {}
Local aPedMult		:= {}
Local cChave		:= SC7->(IndexKey(1))
Local nTotalReg		:= 0
Local cRaizNome	:= 'CTBNFEPROC'

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Monta o arquivo de trabalho³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aPedMult := CtbGrvPC(dDataIni,dDataFim,cChave)

nTotalReg := Len(aPedMult)

If nTotalReg > 0

	If nNumProc > 40
		nNumProc := 40
	EndIf                                                       

	If  nTotalReg >= nNumProc .And. nNumProc > 1 // MultiThread
		aProcs := CTBPrepNFE(nNumProc,nTotalReg,cRaizNome,aPedMult)
		//Inicializa as Threads Transação controlada nas Threads
		For nX := 1 to Len(aProcs)
			StartJob("JOBCTBPC", GetEnvServer(), .F., cEmpAnt,cFilAnt,aProcs[nX][MARCA],aProcs[nX][ARQUIVO],dDataIni,dDataFim,cValToChar(nX),aProcs[nX][VAR_STATUS],cChave,__cUserId,cUserName,cAcesso,cUsuario,aProcs[nX][5],aProcs[nX][6])
			Sleep(3000)
		Next nX
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Realiza o controle das Threads³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		Sleep(3000)
		lRet := NFEMonitor(aProcs,1)
	Else
		lRet := CtbProcPC(dDataIni,dDataFim,"","")
	EndIf
EndIf

RestArea(aArea)

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CtbGrvPC   ºAutor  ³Alvaro Camillo Netoº Data ³  15/04/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Grava arquivo temporario dos pedidos de compra              º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function CtbGrvPC(dDataIni,dDataFim,cChave)

Local cQuery		:= ""
Local cAliasSC7		:= GetNextAlias()
Local aPedidos	 	:= {}
Local aArea		:= GetArea() 

cQuery := "SELECT DISTINCT SC7.C7_FILIAL, SC7.C7_NUM "
cQuery += "FROM "
cQuery += 		 RetSqlName("SC7")	+ " SC7 "
cQuery += "WHERE "
cQuery += 		"SC7.C7_FILIAL = '" + xFilial("SC7")+"' AND "
cQuery += 		"SC7.C7_EMISSAO >= '"+Dtos(dDataIni)+"' AND "
cQuery += 		"SC7.C7_EMISSAO <= '"+Dtos(dDataFim)+"' AND "
cQuery +=		"SC7.C7_DTLANC   = '"+Dtos(Ctod(""))+"' AND "
cQuery += 		"SC7.D_E_L_E_T_ = ' ' "
cQuery += "ORDER BY SC7.C7_FILIAL, SC7.C7_NUM "

cQuery := ChangeQuery(cQuery)

If Select(cAliasSC7) > 0
	dbSelectArea(cAliasSC7)
	dbCloseArea()
EndIf

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSC7,.F.,.T.)

// Carrega Array aPedidos
While (cAliasSC7)->(!Eof())
	aAdd(aPedidos,(cAliasSC7)->C7_NUM)
	(cAliasSC7)->(dbSkip())
EndDo

If Select(cAliasSC7) > 0
	dbSelectArea(cAliasSC7)
	dbCloseArea()
EndIf

RestArea(aArea)

Return aPedidos

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CtbGrvNFE  ºAutor  ³Alvaro Camillo Netoº Data ³  15/04/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Grava arquivo temporario das notas fiscais de entrada       º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function CtbGrvNFE(dDataIni,dDataFim,lDevolucao,cChave)

Local cQuery		:= ""
Local cDataCtb	:= "F1_DTDIGIT"
Local cAliasSF1	:= GetNextAlias()
Local aNotas		:= {}
Local aArea		:= GetArea()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ponto de entrada CTBNFEDT para alterar a contabilizacao para data de emissao        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock("CTBNFEDT")
	lRetPE:= ExecBlock("CTBNFEDT",.F.,.F.)
	If ValType (lRetPE) == "L" .And. lRetPE
		cDataCtb:= "F1_EMISSAO"
	EndIf
EndIf

cQuery := "SELECT DISTINCT SF1.F1_DOC "
cQuery += "FROM "
cQuery += 		 RetSqlName("SF1")	+ " SF1 "
cQuery += "WHERE "
cQuery += 		"SF1.F1_FILIAL = '" + xFilial("SF1")+"' AND "
cQuery +=		"SF1."+cDataCtb+" >= '"+Dtos(dDataIni)+"' AND "
cQuery +=		"SF1."+cDataCtb+" <= '"+Dtos(dDataFim)+"' AND "
cQuery +=		"SF1.F1_DTLANC   = '"+Dtos(Ctod(""))+"' AND "
If !lDevolucao
	cQuery  += "SF1.F1_TIPO NOT IN('D','B') AND "
Else
	cQuery  += "SF1.F1_TIPO IN('D','B') AND "
EndIf
cQuery += "SF1.D_E_L_E_T_ = ' ' "
cQuery += "ORDER BY SF1.F1_DOC"

cQuery := ChangeQuery(cQuery)

If Select(cAliasSF1) > 0
	dbSelectArea(cAliasSF1)
	dbCloseArea()
EndIf

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSF1,.F.,.T.)

// Carrega Array aNotas
While (cAliasSF1)->(!Eof())
	aAdd(aNotas,(cAliasSF1)->F1_DOC)
	(cAliasSF1)->(dbSkip())
EndDo

If Select(cAliasSF1) > 0
	dbSelectArea(cAliasSF1)
	dbCloseArea()
EndIf

RestArea(aArea)

Return aNotas

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³JOBCTBPC  ºAutor  ³Alvaro Camillo Netoº Data ³  15/04/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Job da contabilização do Pedido de Compra                  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function JOBCTBPC(cEmpX,cFilX,cMarca,cFileLck,dDataIni,dDataFim,cId,cVarStatus,cChave,cXUserId,cXUserName,cXAcesso,cXUsuario,cCodIni,cCodFim)

Local nHandle	 := 0
Local lRet		 := .T.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Abre o arquivo de Lock parao controle externo das threads³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private lMsErroAuto 
Private lMsHelpAuto 
Private lAutoErrNoFile 

nHandle := NFELock(cFileLck)
// STATUS 1 - Iniciando execucao do Job
PutGlbValue(cVarStatus, "1" )
GlbUnLock()

//Seta job para nao consumir licensas
RpcSetType(3)
RpcClearEnv()
// Seta job para empresa filial desejada
RpcSetEnv( cEmpX,cFilX,,,,,)

// STATUS 2 - Conexao efetuada com sucesso
PutGlbValue(cVarStatus, "2" )
GlbUnLock()

//Set o usuário para buscar as perguntas do profile
lMsErroAuto := .F.
lMsHelpAuto := .T. 
lAutoErrNoFile := .T.

__cUserId := cXUserId 
cUserName := cXUserName
cAcesso   := cXAcesso
cUsuario  := cXUsuario

ConOut("Starting: "+Time())

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Realiza o processamento³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
lRet := CtbProcPC(dDataIni,dDataFim,cCodIni,cCodFim)

JOBNFEEnd(cVarStatus,nHandle,lRet)

ConOut("Finished: "+Time())

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³JOBCTBNFE  ºAutor  ³Alvaro Camillo Netoº Data ³  15/04/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Job da contabilização da Nota Fiscal de Entrada            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function JOBCTBNFE(cEmpX,cFilX,cMarca,cFileLck,lContNCC,dDataIni,dDataFim,cId,cVarStatus,cChave,cXUserId,cXUserName,cXAcesso,cXUsuario,cCodIni,cCodFim,lDevolucao)

Local nHandle	 := 0
Local lRet		 := .T.

Private lMsErroAuto 
Private lMsHelpAuto 
Private lAutoErrNoFile 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Abre o arquivo de Lock parao controle externo das threads³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nHandle := NFELock(cFileLck)

// STATUS 1 - Iniciando execucao do Job
PutGlbValue(cVarStatus, "1" )
GlbUnLock()

//Seta job para nao consumir licensas
RpcSetType(3)
RpcClearEnv()
// Seta job para empresa filial desejada
RpcSetEnv( cEmpX,cFilX,,,,"CTBANFE",) //RpcSetEnv - Abertura do ambiente em rotinas automáticas ( [ cRpcEmp ] [ cRpcFil ] [ cEnvUser ] [ cEnvPass ] [ cEnvMod ] [ cFunName ] [ aTables ] [ lShowFinal ] [ lAbend ] [ lOpenSX ] [ lConnect ]

// STATUS 2 - Conexao efetuada com sucesso
PutGlbValue(cVarStatus, "2" )
GlbUnLock()

//Set o usuário para buscar as perguntas do profile
lMsErroAuto := .F.
lMsHelpAuto := .T. 
lAutoErrNoFile := .T.

__cUserId := cXUserId 
cUserName := cXUserName
cAcesso   := cXAcesso
cUsuario  := cXUsuario

ConOut("Starting: "+Time())

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Realiza o processamento³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
lRet := CtbProcNFE(lContNCC,dDataIni,dDataFim,cCodIni,cCodFim,lDevolucao)

JOBNFEEnd(cVarStatus,nHandle,lRet)

ConOut("Finished: "+Time())

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CtbProcNFE ºAutor  ³Alvaro Camillo Netoº Data ³  15/04/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     Processa a contabilização                                    º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function CtbProcNFE(lContNCC,dDataIni,dDataFim,cCodIni,cCodFim,lDevolucao)
Local aArea := GetArea()
Local lRet := .T.

MaCtbNfe(.F.,.F.,1,dDataIni,dDataFim,xFilial("SF1"),xFilial("SF1"),lContNCC,Nil,.F.,.F.,.T.,.T.,cCodIni,cCodFim,lDevolucao)

RestArea(aArea)
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CtbProPC ºAutor  ³Alvaro Camillo Netoº Data ³  15/04/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     Processa a contabilização                                    º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function CtbProcPC(dDataIni,dDataFim,cCodIni,cCodFim)
Local aArea := GetArea()
Local lRet := .T.

MaCtbNfe(.F.,.F.,1,dDataIni,dDataFim,xFilial("SC7"),xFilial("SC7"),.F.,Nil,.F., .T. ,.F.,.T.,cCodIni,cCodFim)

RestArea(aArea)
Return lRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³NFEMonitorºAutor³Alvaro Camillo Netoº Data ³  15/04/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Função responsavel por monitorar as threads de processamen º±±
±±º          ³ to                                                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function NFEMonitor(aProcs,nTipo)
Local lRet			:= .T.
Local nX			:= 0
Local aConcluido	:= {}
Local nHandle		:= 0
Local cMsg			:= ""
Local cRotErro		:= ""
Local cTipoErro		:= ""
Local cMsgErro		:= ""
Local aErros		:= {}

Default nTipo := 1

While .T.
	For nX := 1 to Len(aProcs)
		nHandle := NFELock(aProcs[nX][ARQUIVO])
		If  nHandle >= 0
			fClose(nHandle)
			If aScan(aConcluido,{|aItem| aItem[3] == aProcs[nX][MARCA]} ) == 0
				AADD(aConcluido, { nHandle, aProcs[nX][ARQUIVO], aProcs[nX][MARCA]})
			EndIf
		EndIf
	Next nX
	
	If Len(aConcluido) >= Len(aProcs)
		Exit
	EndIF
	Sleep(5000)
End

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se todas a threads foram processadas corretamente³
//³libera o recurso e apaga o arquivo                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nX := 1 to Len(aConcluido)
	FT_FUse(aConcluido[nX][2])
	FT_FGoTop()
	cMsg := FT_FReadLn()
	FT_FUse()
	fErase(aConcluido[nX][2])
	If lRet .And. ALLTRIM(cMsg) != OK
		lRet := .F.
	EndIf
Next nX



//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica quais threads deram erro³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !lRet       
	Do Case
		Case nTipo == 1 //Pedido de Compra
			cRotErro := STR0022 //" Erro no processamento do pedido de compra: "
		Case nTipo == 2 //Nota Fiscal de Entrada                     
			cRotErro := STR0023//" Erro no processamento de nota fiscal de entrada: "
		Case nTipo == 3 //Nota Fiscal de Devolução                   	
			cRotErro := STR0024//" Erro no processamento do nota fiscal de devolução: "	
	EndCase
	
	For nX := 1 to Len(aProcs)
		cStatus := GetGlbValue(aProcs[nX][VAR_STATUS])
		If cStatus != '3' // Concluido com sucesso 
	        Do Case
				Case cStatus == "1" // Erro na Conexão
					cTipoErro := STR0025 //" Erro na inicialização do processo"
				Case cStatus == "2" // Erro no Processamento
				   	cTipoErro := STR0026 //" Erro no processo de contabilização"			
			EndCase
			cMsgErro := cRotErro + cTipoErro + STR0027 + cValTochar(nX) //" processo numero "
			ProcLogAtu("ERRO",STR0028,cMsgErro)//"Erro no Processamento"
			aAdd(aErros,cMsgErro)
		EndIf
	Next nX
EndIf

If !lRet
	If MsgYesNo(STR0029)//"Ocorreram inconsistencia no processo, deseja imprimir o relatorio de erros?"
		CtRConOut(aErros)
	EndIf
EndIf

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³NFEUnLock³ Autor ³Marcos Justo            ³ Data ³ 15/04/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Encerra a trava                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function NFEUnLock(nHandle,lOk)
Local cMsg := IIF(lOk,OK,ERRO)
FWRITE(nHandle,cMsg)
FCLOSE(nHandle)
Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³NFELock ºAutor  ³Alvaro Camillo Netoº Data ³  15/04/10   º±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Cria arquivo para travar processos e garantir que sao unicos³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function NFELock(cFile)
Local nHJob := 0
If File(cFile)
	nHJob := FOPEN(cFile,2)
Else
	nHJob := FCREATE(cFile)
EndIf
Return nHJob

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CTBPrepNFE  ºAutor³Alvaro Camillo Netoº Data ³  15/04/10    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Prepara as informacoes para o processamento multithread     º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function CTBPrepNFE(nNumProc,nTotalReg,cRaizNome,aRegsProc)
Local aProcs 		:= Array(nNumProc)
Local nX		 	:= 0
Local cDirSem  		:= "\Semaforo\"
Local cNomeArq		:= ""
Local cMarca  		:= ""
Local nRegAProc		:= 0 // Registros a processar
Local nRegJProc		:= 0 // Total de registros já processados 
Local cVarStatus	:= ""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Cria a pasta do semaforo caso não exista³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !ExistDir(cDirSem)
	MontaDir(cDirSem)
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Realiza o calculos das quantidades de registros³
//³que cada thread irá processar e                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nX := 1 to Len(aProcs)
	cNomeArq 	:= cDirSem + cRaizNome +cEmpAnt + cFilAnt +cValtoChar(nX)+cValtoChar(INT(Seconds())) + '.lck'
	cMarca		:= GetMark()
	nRegAProc	:= IIf( nX == 1 , 1 , aProcs[nX-1,7]+1 )
	nRegJProc	+= IIf( nX == Len(aProcs), nTotalReg-nRegJProc, Int(nTotalReg / nNumProc) )
	cVarStatus  :="cNFEP"+cEmpAnt+cFilAnt+StrZero(nX,2)+cMarca
	PutGlbValue(cVarStatus,"0")
	GlbUnLock()
	aProcs[nX]	:= {cNomeArq,cMarca,nRegAProc,cVarStatus,aRegsProc[nRegAProc],aRegsProc[nRegJProc],nRegJProc}
Next nX

Return aProcs

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CtbValMult ºAutor  ³Alvaro Camillo Netoº Data ³  05/19/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Valida se o processamento será feito MultiThread           º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function CtbValMult(lMostraHelp,lAglutina,lMostraLanc,nTipo) 
Local lRet 		:= .T. 
Local lBlind    := IsBlind()
Local nHelp		:= 1 
Default lMostraHelp := .F.
Default nTipo 		:= 1
Default lMostraLanc := .F.

If lMostraHelp .And. !lBlind  
	nHelp := 1
Else
	nHelp := 0
EndIf 

If lRet .And. nTipo != 1
	If lMostraHelp .And. !lBlind  
		lRet := MsgYesNo(STR0017,STR0018)//"O processamento Multithread está disponivel apenas para processamento por documento, o processamento será feito sem multithread. Concorda com operação?"##"Atenção"
	Else
		lRet := .F.
	EndIf
EndIf

If lRet .And. lAglutina
	If lMostraHelp .And. !lBlind  
		lRet := MsgYesNo(STR0019,STR0018)//"O processamento Multithread está disponivel apenas para processamento sem aglutinação, o processamento será feito sem multithread. Concorda com operação?" ##"Atenção"
	Else
		lRet := .F.
	EndIf
EndIf  

If lRet
	lCtbInTran := CTBINTRAN(nHelp,lMostraLanc)
	
	If !lCtbInTran
		If lMostraHelp .And. !lBlind   
			lRet := MsgYesNo(STR0020,STR0018)//"O processamento será feito sem multithread. Concorda com operação?" ##"Atenção"
		ElseIf lBlind
			lRet := .T.
		Else
			lRet := .F.
		EndIf
	EndIf
EndIf



Return lRet 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³JOBFINEnd   ºAutor  ³Microsiga           º Data ³  06/21/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³  Finaliza a Thread verificando se ocorrer help (erro)      º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function JOBNFEEnd(cVarStatus,nHandle,lRet)
Local nX	:= 0
Local aLog  := {}
Local cMsg	:= ""
aLog  := GETAUTOGRLOG()

If !Empty(aLog)
	For nX := 1 to Len(aLog)
		cMsg := aLog[nX] 	
	Next
	UserException( "Error CTBNFE- " + cMsg )	
Else
	// STATUS 3 - Processado com Sucesso
	PutGlbValue(cVarStatus, "3" )
	GlbUnLock()
	NFEUnLock(nHandle,lRet)
Endif

Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CTBANFERATºAutor  ³Anieli Rodrigues    º Data ³  29/05/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Contabilizacao offline do rateio do pedido de compras      º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ CTBANFE	                                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CTBANFERAT(cChave,nParcCtb,nHdlPrv,cLoteCtb,c652,aCT5,aFlagCTB)
	Default nParcCtb	:= 0
	Default nHdlPrv		:= 0
	Default cLoteCtb	:= ""

	SCH->(DbSetOrder(1)) //CH_FILIAL+CH_PEDIDO+CH_FORNECE+CH_LOJA+CH_ITEMPD+CH_ITEM	
	If SCH->(DbSeek(cChave)) 
		While SCH->(!EOF()) .and. cChave == xFilial("SCH")+SCH->CH_PEDIDO+SCH->CH_FORNECE+SCH->CH_LOJA+SCH->CH_ITEMPD
	   		If nHdlPrv > 0
	   			If nParcCtb > 0
					nParcCtb 	:= DetProva(nHdlPrv,"659","MATA120",cLoteCtb,,,,,,,,,{"SCH",SCH->(RECNO())})
				Else 
					nParcCtb 	:= DetProva(nHdlPrv,"659","MATA120",cLoteCtb,,,,,c652,aCT5,,aFlagCTB)
				Endif				
	   		Else
	   			Exit
	   		EndIf
	   		SCH->(DbSkip())		
        EndDo
    EndIf
Return Nil

/*/{Protheus.doc} SchedDef()
Preparação para rotinas automaticas por Schedule

@author Fabiano Dantas
@since 30/10/2020
@version 1.0
@return 
/*/
//-------------------------------------------------------------------
Static Function SchedDef()
Local aReturn := { "P",;
				   "CTBNFE",;
					Nil,;
					Nil,;
					Nil ;
				}
						
Return aReturn

/*/{Protheus.doc} hasCustomFields
	Retorna se há campo de usuário criado na tabela passada.
@author Leandro Fini
@since 14/04/2023
@param cTable, character, alias da tabela.
@return aCustomFields, array, listagem de campos customizados.
/*/
Static Function hasCustomFields(cTable as Character)
  Local nX             as Numeric
  Local aStruct        as Array
  Local lRet  		   as Logical
  
    Default cTable  := ""
    aStruct         := {}
    lRet 		    := .F.

    aStruct := FWSX3Util():GetListFieldsStruct(cTable , .F.)
    For nX := 1 To Len(aStruct)  
        If X3Usado(aStruct[nX][1]) .and. AllTrim(GetSX3Cache(aStruct[nX][1], 'X3_PROPRI')) == "U"
            lRet := .T.
			Exit
        EndIf
    Next nX

Return lRet
