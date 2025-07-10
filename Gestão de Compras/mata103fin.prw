#INCLUDE "PROTHEUS.CH"
#INCLUDE "MATA103FIN.CH"

/**************************************** FUNCOES RELACIONADAS AO FOLDER DE DUPLICATAS DO DOCUMENTO DE ENTRADA ****************************************/ 
/*********************************************** E TODOS OS TRATAMENTOS REFERENTES AO MODULO FINANCEIRO ***********************************************/
/*
/* FUTURAMENTE TRANSFERIR PARA ESTE FONTE AS SEGUINTES FUNCOES:
/*
/* NfeFldFin   (MATA103X)
/* NfeRFldFin  (MATA103X)
/* NfeLOkSE2   (MATA103X)
/* NfeTOkSE2   (MATA103X)
/* NfeMultNat  (MATA103X)
/* NfeLOkSEV   (MATA103X)
/* NfeTOkSEV   (MATA103X)
/* NfeVldSEV   (MATA103X)
/* NfeRatSEV   (MATA103X)
/* NfeRatImp   (MATA103X)
/* NfeCond     (MATA103X)
/* NfeCond2    (MATA103X)
/* NfeTotFin   (MATA103X)
/* A103CalcRt  (MATA103X)
/* A103Radio   (MATA103X)
/* A103Recal   (MATA103X)
/* A103ValNat  (MATA103X)
/* A103VencSE2 (MATA103X)
/* A103CodR    (MATA103X)
/* A103AtuSE2  (MATA103)
/* NfeCalcRet  (MATA103)
/* A103MNat    (MATA103)
/* A103CCompAd (MATA103)
/* A103CompAdR (MATA103)
*/ 

/*/{Protheus.doc} A103TrbGen()
Criacao do array contendo os valores do motor de tributos genericos por parcela de duplicata
Este array sera passado para a funcao A103ATUSE2 para geracao dos tributos no Financeiro

@param	aVencto    - Array com quantidade de parcelas da duplicata
        aTribGen   - Array com os tributos genericos retornados pelo motor
        aColTrbGen - Array com as colunas que serao adicionadas na aba duplicatas
        aRateio    - Array com as posicoes para controle de rateio de cada coluna da duplicata
        aRatBasTG  - Array com as posicoes para controle de rateio da base de calculo de cada coluna da duplicata
		cIdsTrGen  - String que receberá os ids de impostos calculados pelo Configurador de Tributos.
@return Array
@author Carlos Capeli
@since 21/11/18
@version 12
/*/
Function A103TrbGen(aVencto,aTribGen,aColTrbGen,aRateio,aRatBasTG,cIdsTrGen)

Local aParcTrGen := {}
Local nX         := 0
Local nY         := 0

Default aVencto    := {}
Default aTribGen   := {}
Default aColTrbGen := {}
Default aRateio    := {}
Default aRatBasTG  := {}
Default cIdsTrGen  := ""
// Cada parcela de duplicata tera um array com os tributos gerericos calculados pelo motor
For nX := 1 To Len(aVencto)
	aAdd(aParcTrGen,{})		// Parcela da duplicata
	For nY := 1 To Len(aTribGen)
		aAdd(aParcTrGen[Len(aParcTrGen)],{aTribGen[nY][4],	;			// Cod. Regra Financeira FKK
										 0,					;			// Base de calculo - Este valor sera preenchido na funcao NFERFLDFIN
										 0,					;			// Valor calculado - Este valor sera preenchido na funcao NFERFLDFIN
										 aTribGen[nY][5],	;			// ID da regra fiscal F2B
										 FinParcFKK(aTribGen[nY][4]),;	// Indica se retem integralmente na primeira parcela
										 aTribGen[nY][6],	;			// Codigo da URF
										 aTribGen[nY][7]})				// Percentual aplicavel a URF
		//preenchendo a variável de Ids de tributos genéricos.
		If !(aTribGen[nY][11] $ cIdsTrGen)
			cIdsTrGen += aTribGen[nY][11] + "|"
		EndIf
	Next nY
Next nX

// Adiciona elementos nos arrays de controle de saldo a ratear
For nX := 1 To Len(aColTrbGen)
	aAdd(aRateio,0)		// Array de rateio dos valores da duplicata
	aAdd(aRatBasTG,0)	// Array de rateio da base de calculo
Next nX

Return aParcTrGen

/*/{Protheus.doc} A103AtuTrG()
Atualiza valores do motor de tributos genericos no array aParcTrGen caso tenham sido alterados manualmente

@param	aParcTrGen - Array contendo os valores do motor de tributos genericos por parcela de duplicata
        aColTrbGen - Array com as colunas que serao adicionadas na aba duplicatas
        aTribGen   - Array com os tributos genericos retornados pelo motor
		aColsSE2   - aCols de Duplicatas
        nColsSE2   - Variavel que contem o numero de colunas da tabela SE2 exibidas na aba Duplicatas
@return Array
@author Carlos Capeli
@since 21/11/18
@version 12
/*/
Function A103AtuTrG(aParcTrGen,aColTrbGen,aTribGen,aColsSE2,nColsSE2)

Local nPosValTrb := 0
Local nX         := 0
Local nY         := 0

Default aParcTrGen := {}
Default aColTrbGen := {}
Default aTribGen   := {}
Default aColsSE2   := {}
Default nColsSE2   := 0

For nX := 1 To Len(aParcTrGen)

	For nY := 1 To Len(aTribGen)

		If (nPosValTrb := aScan(aColTrbGen,{|x| x[1] == aTribGen[nY][1]}) ) > 0	// Encontra a coluna da duplicata referente ao tributo generico

			If Len(aParcTrGen[nX]) >= nY

				aParcTrGen[nX][nY][3] := aColsSE2[nX][nColsSE2+nPosValTrb]		// Atualiza array de tributos genericos para que os valores fiquem coerentes com a aba Duplicatas, pois as colunas sao editaveis

			EndIf

		EndIf

	Next nY

Next nX

Return

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} FxCtbPAdt
Contabilização das compensações entre titulos e adiantamentos
Emissão da NF - MAtA103

@param aRecSE5, vetor com duas posições.
				[1] - Recno da SE5 ref a baixa da contabilização da compensação
				[2] - Recno da SE2 ref a baixa da contabilização da compensação
				[3] - Recno da FK2 ref a baixa da contabilização da compensação

@author Mauricio Pequim Jr
@since  18/11/2019
@version 12
@type function
/*/
//------------------------------------------------------------------------------------------
Function FxCtbPAdt(aRecSE5)

	Local lContabil	:= .F.
	Local lDigita	:= .F.
	Local lAglutina	:= .F.
	Local lUsaFlag	:= SuperGetMV( "MV_CTBFLAG" , .T. /*lHelp*/, .F. /*cPadrao*/)
	Local cArqCtb	:= ""
	Local cPadrao	:= "597" 
	Local nValor	:= 0
	Local nRecSe2	:= 0
	Local nRecSe5	:= 0
	Local nRecFK2	:= 0
	Local nX		:= 0
	Local nTotCtbil := 0
	Local lPCCBaixa := SuperGetMv("MV_BX10925",.T.,"2") == "1"
	Local lIssBaixa := SuperGetMv("MV_MRETISS",.F.,"1") == "2"	
	Local lIRPFBaixa:= .F.
	Local lImpComp  := SuperGetMV("MV_IMPCOM", .T., .F.)

	Private nHdlPrv		:= 0
	Private ABATIMENTO	:= 0
	Private aFlagCTB	:= {}
	Private cLote		:= ""
	Private NPIS340     := 0
	Private NCOF340     := 0
	Private NCSL340     := 0
	Private NIRF340     := 0
	Private NISS340     := 0
	
	Default aRecSE5 := {}

	If Len(aRecSE5) > 0

		//Carrega o pergunte da rotina de compensação financeira
		Pergunte("AFI340",.F.)

		lContabil	 	:= MV_PAR11 == 1
		lDigita			:= MV_PAR09 == 1
		lAglutina		:= MV_PAR08 == 1
		lPadrao			:= VerPadrao(cPadrao)

		If lContabil
			LoteCont("FIN")
			If nHdlPrv <= 0
				nHdlPrv := HeadProva(cLote, "FINA340", Substr(cUsuario, 7, 6), @cArqCtb)
			EndIf
		
			If nHdlPrv > 0

				For nX := 1 to Len(aRecSE5)
					
					SE5->(dbGoTo(aRecSe5[nX,1]))
					SE2->(dbGoTo(aRecSe5[nX,2]))
					FK2->(dbGoTo(aRecSe5[nX,3]))

					If lPadrao .And. lContabil .and. nHdlPrv > 0
						STRLCTPAD := SE2->(E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA)
						VALOR     := If(Val(SE5->E5_MOEDA) == 1, SE5->E5_VALOR, SE5->E5_VLMOED2)
						VALOR2    := SE5->E5_VLCORRE
						nTotCtbil += VALOR

						If lImpComp .and. SE5->(E5_VRETPIS+E5_VRETCOF+E5_VRETCSL+E5_VRETIRF+E5_VRETISS) > 0
							//PCC
							If lPCCBaixa .And. SE5->(E5_VRETPIS+E5_VRETCOF+E5_VRETCSL) > 0
								//Alimenta variáveis de contabilização
								NPIS340 := SE5->E5_VRETPIS 
								NCOF340 := SE5->E5_VRETCOF
								NCSL340 := SE5->E5_VRETCSL
							Endif
							//Irf
							lIRPFBaixa := If(cPaisLoc = "BRA" , SA2->A2_CALCIRF == "2", .F.) .And. Posicione("SED",1,xfilial("SED",SE2->E2_FILORIG) + SE2->(E2_NATUREZ),"ED_CALCIRF") = "S"
							If lIRPFBaixa .And. SE5->E5_VRETIRF > 0
								//Alimenta variável de contabilização
								NIRF340 := If(SE5->E5_PRETIRF == "1",0,SE5->E5_VRETIRF)
							Endif
							//Iss
							If lIssBaixa .And. SE5->E5_VRETISS > 0
								//contabilização do imposto
								NISS340 := SE5->E5_VRETISS
							Endif
						Endif

						If lUsaFlag  // Armazena em aFlagCTB para atualizar no modulo Contabil
							aAdd( aFlagCTB, {"E5_LA" , "S", "SE5", SE5->( Recno() ), 0, 0, 0} )
							aAdd( aFlagCTB, {"FK2_LA", "S", "FK2", FK2->( Recno() ), 0, 0, 0} )
						Endif

						nValor 	  += DetProva(nHdlPrv, cPadrao, "FINA340", cLote,/*nLinha*/,/*lExecuta*/,/*cCriterio*/,/*lRateio*/,/*cChaveBusca*/,/*aCT5*/,/*lPosiciona*/,@aFlagCTB,/*aTabRecOri*/,/*aDadosProva*/)

						If !lUsaFlag
							RecLock("SE5",.F.)
							SE5->E5_LA := "S "
							MsUnLock()

							RecLock("FK2",.F.)
							FK2->FK2_LA := "S"
							MsUnlock()
						Endif

						VALOR   := 0
						VALOR2  := 0
						NPIS340 := 0
						NCOF340 := 0
						NCSL340 := 0
						NIRF340	:= 0
						NISS340	:= 0
					EndIf
				Next

				//Contabilização
				If lPadrao .And. nValor > 0
					VALOR := nValor
					nRecSe2 := SE2->(Recno())
					nRecSe5 := SE2->(Recno())
					nRecFK2 := FK2->(Recno())

					SE2->(DBGoBottom())
					SE2->(dbSkip())
					SE5->(DBGoBottom())
					SE5->(dbSkip())
					FK2->(DBGoBottom())
					FK2->(dbSkip())

					RodaProva(nHdlPrv, nValor)
					cA100Incl(cArqCtb, nHdlPrv, 1, cLote, lDigita, lAglutina, Nil, Nil, Nil, @aFlagCTB)			
					aFlagCTB := {}

					SE2->(dbGoTo(nRecSE2))
					SE5->(dbGoTo(nRecSE5))
					FK2->(dbGoTo(nRecFK2))

				EndIf
			Endif
		Endif

		Pergunte("MTA103",.F.)

	Endif	

Return

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} A103IdGen
Verifica se os impostos são calculados pelo configurador e atribue .T. as variáveis para não ser gerado os títulos pelo legado

@param 
	cIdsTrbGen - Ids de tributos genéricos
	lPccMR - Retenção de Pis Cofins e CSL	- id do Imposto CSLL       "000026", COFRET     "000043", PISRET     "000045", 
	lIrfMR - Retenção de IR					- id do Imposto IR         "000018"
	lInsMR - Retenção de INSS				- id do Imposto INSS       "000019"
	lIssMR - Retenção de ISS				- id do Imposto ISS        "000020"
	lCidMR - Retenção de CID				- id do Imposto CIDE       "000023"
	lSestMR - Retenção Sest					- id do Imposto SEST       "000013"

@author r.cavalcante
@since  08/09/2022
@version 12
@type function
/*/
//------------------------------------------------------------------------------------------
 
Function A103IdGen(cIdsTrbGen,lPccMR,lIrfMR,lInsMR,lIssMR,lCidMR,lSestMR,lFunMR,lInsPMR,lFamadMR,lFethabMR,lFacsMR,lImaMR,lFabovMR)
	Default cIdsTrbGen := ""
	
	If "000026"$ cIdsTrbGen .OR. "000043" $ cIdsTrbGen .OR. "000045"$ cIdsTrbGen
		lPccMR := .T.
	EndIf
	If "000018" $ cIdsTrbGen
		lIrfMR := .T.
	EndIf
	If "000019" $ cIdsTrbGen
		lInsMR := .T.
	EndIf
	If "000020" $ cIdsTrbGen
		lIssMR := .T.
	EndIf
	If "000023" $ cIdsTrbGen
		lCidMR := .T.
	EndIf
	If "000013" $ cIdsTrbGen
		lSestMR := .T.
	EndIf
	If "000002" $ cIdsTrbGen
		lFunMR := .T.
	EndIf
	If "000036" $ cIdsTrbGen
		lInsPMR := .T.
	EndIf
	If "000007" $ cIdsTrbGen
		lFamadMR := .T.
	EndIf
	If "000009" $ cIdsTrbGen
		lFethabMR := .T.
	EndIf
	If "000006" $ cIdsTrbGen
		lFacsMR := .T.
	EndIf
	If "000012" $ cIdsTrbGen
		lImaMR := .T.
	EndIf
	If "000005" $ cIdsTrbGen
		lFabovMR := .T.
	EndIf

Return

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} NfeDedImp
Botão - Deduções - Documento de entrada

Tela para visualização de deduções de impostos dentro do documento de entrada
aba duplicatas.

@author Leandro Fini
@since  11/10/2022
@version 12
@type function
/*/
//------------------------------------------------------------------------------------------
Function NfeDedImp()

Local nTotDed		:= 0
Local nVlrTot 		:= 0
Local oDlgDed      	:= Nil
Local oGetDed		:= Nil
Local aHeadDed		:= {}
Local aColsDed 		:= {}
Local nX 			:= 0
Local nNFBaseDup	:= 0
Local nNFValInss	:= 0
Local nNFValGilRat	:= 0
Local nNFValSenar	:= 0
Local xPesqPict		:= Nil

If !l103Auto .and. MaFisFound("NF") .and. MaFisRet(,"NF_BASEDUP") > 0 .and. ( MaFisRet(,"NF_VALINS") > 0 .or. MaFisRet(,"NF_FUNRURAL") > 0 .Or. MaFisRet(,"NF_VLSENAR") > 0 )
	nNFValSenar		:= MaFisRet(,"NF_VLSENAR")
	nNFBaseDup		:= MaFisRet(,"NF_BASEDUP") + nNFValSenar //Soma SENAR, pois BaseDup ja deduz SENAR
	nNFValInss		:= MaFisRet(,"NF_VALINS")
	nNFValGilRat	:= MaFisRet(,"NF_FUNRURAL")
	xPesqPict		:= PesqPict("SE2","E2_VALOR") 

	aAdd(aHeadDed, {STR0010, "XX_IMPOSTO",  ""			, 015, 0, ""	, ".T.", "C", "", ""} )//"Imposto"
	aAdd(aHeadDed, {STR0011, "XX_TOTAL"  ,  xPesqPict	, 015, 0, ".T."	, ".T.", "N", "", ""} )//"Valor Dedução"

	aAdd(aColsDed, { "INSS"		, nNFValInss	, .F. })
	aAdd(aColsDed, { "GILRAT"	, nNFValGilRat	, .F. })
	aAdd(aColsDed, { "SENAR"	, nNFValSenar	, .F. })

	for nX := 1 to len(aColsDed)
		nTotDed += aColsDed[nX][2]
	next nX

	nVlrTot := nNFBaseDup - nTotDed 

	DEFINE MSDIALOG oDlgDed FROM 100,100 TO 345,500 TITLE STR0012 Of oMainWnd PIXEL //"Deduções de Impostos"

	oGetDed := MsNewGetDados():New(35,3,90,200,0,,,,,,1,,,,oDlgDed,aHeadDed,aColsDed)

	@ 6 ,8 SAY STR0013 OF oDlgDed PIXEL SIZE 50,11//"Valor do título: "
	@ 6 ,58 SAY Alltrim(TransForm(nNFBaseDup,xPesqPict)) OF oDlgDed PIXEL SIZE 50,11
	@ 6 ,102 SAY STR0014 OF oDlgDed PIXEL SIZE 50,11//"Total de deduções: "
	@ 6 ,150 SAY Alltrim(TransForm(nTotDed,xPesqPict)) OF oDlgDed PIXEL SIZE 50,11
	@ 17,8 SAY STR0015 OF oDlgDed PIXEL SIZE 50,11//"Total com dedução: "
	@ 17,58 SAY Alltrim(TransForm(nVlrTot,xPesqPict)) OF oDlgDed PIXEL SIZE 50,11

	Define SButton From 100,170 Type 1 Of oDlgDed Enable Action oDlgDed:End()

	ACTIVATE MSDIALOG oDlgDed CENTERED

Else 
	Help(" ",1,"A103DEDIMP",,STR0016,1,0)//"Não há dedução de impostos a serem visualizados."
EndIf

Return
