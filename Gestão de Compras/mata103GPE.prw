#INCLUDE "MATA103.CH"  
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWADAPTEREAI.CH"

/*/{Protheus.doc} A103SRKGPE
Rotina de integracao com a folha de pagamento

@param	ExpN1: Codigo da operação
				[1] Inclusao de Verba
				[2] Exclusao de Verba
		ExpA2: Header das duplicatas
		ExpA3: aCols das duplicatas
@author Eduardo Riera
@since 14.03.2006
/*/
Function A103SRKGPE(nOpcA,aHeadSE2,aColsSE2)

Local aArea     := GetArea()
Local aAreaSB5  := SB5->(GetArea())
Local aCodFol   := {}
Local aRecSRK   := {}
Local cVerbaFol := ""
Local cVerbaIse := ""
Local cVerbaISS	:= ""
Local cDocFol   := ""
Local nParcela  := 0
Local nValor    := 0
Local nValIpi   := 0
Local nValSol   := 0
Local nValFolha := 0
Local nFolhaIpi := 0
Local nFolhaSol := 0
Local nValIsento:= 0
Local nIpiIsento:= 0
Local nSolIsento:= 0
Local nX        := 0
Local nPosCod   := aScan(aHeader,{|x| AllTrim(x[2])=="D1_COD"})
Local lAutMEI   := .F.
Local nPE2VlrTit:= 0
Local nPE2DtVenc:= 0
Local nPE2ISS	:= 0
Local dDtVencto	:= CtoD("//")
Local nVlrParc	:= 0
Local nVlrTotal	:= 0
Local nVlrISS	:= 0
Local nOpcGpe110:= 3
Local aCab		:= {}
Local aItem		:= {}
Local aItens	:= {}
Local aErroAuto	:= {}
Local lRet		:= .T.
Local cMsgRet	:= ""
Local cCadBkp	:= IIF(Type("cCadastro") == "C", cCadastro, STR0009) 
Private lMsErroAuto 	:= .F.
Private lAutoErrNoFile 	:= .T.

Do Case
Case nOpcA == 1 
	nPE2VlrTit	:= aScan(aHeadSE2,{|x| AllTrim(x[2])=="E2_VALOR"}) //Valor Titulo
	nPE2DtVenc	:= aScan(aHeadSE2,{|x| AllTrim(x[2])=="E2_VENCTO"}) //Data Vencimento
	nPE2ISS		:= aScan(aHeadSE2,{|x| AllTrim(x[2])=="E2_ISS"}) //Data Vencimento
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Identifica o funcionario                                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DbSelectArea("SRA")
	DbSetOrder(1)
	If MsSeek(xFilial("SRA")+SF1->F1_NUMRA) .And. FP_CODFOL(@aCodFol,SRA->RA_FILIAL)

		// Verifica se o autonomo e MEI
		If SRA->RA_AUTMEI == "1"
			lAutMEI := .T.
		EndIf

		SB5->(dbSetOrder(1))
		For nX := 1 To Len(aCols)
			If !aCols[nX][Len(aHeader)+1]

				nValor  := NoRound(xMoeda(MaFisRet(nX,"IT_BASEDUP"),MaFisRet(,"NF_MOEDA"),SF1->F1_MOEDA,dDEmissao,Nil,Nil,MaFisRet(,"NF_TXMOEDA")),2)
				nValIpi := Iif( nValor > 0, NoRound(xMoeda(MaFisRet(nX,"IT_VALIPI") ,MaFisRet(,"NF_MOEDA"),SF1->F1_MOEDA,dDEmissao,Nil,Nil,MaFisRet(,"NF_TXMOEDA")),2), 0 )
				nValSol := Iif( nValor > 0, NoRound(xMoeda(MaFisRet(nX,"IT_VALSOL") ,MaFisRet(,"NF_MOEDA"),SF1->F1_MOEDA,dDEmissao,Nil,Nil,MaFisRet(,"NF_TXMOEDA")),2), 0 )

				If lAutMEI .And. (Posicione("SB5",1,xFilial("SB5")+aCols[nX][nPosCod],"B5_INSSPAT") == "2")	// Incide INSS Patronal = Nao
					nValIsento += nValor
					nIpiIsento += nValIpi
					nSolIsento += nValSol
				Else
					nValFolha  += nValor
					nFolhaIpi  += nValIpi
					nFolhaSol  += nValSol
				EndIf
			EndIf
		Next nX

		If nValFolha > 0
			// Obtem o codigo da verba
			cVerbaFol := aCodFol[218,001] //Pagamento de autonomos
			If !Empty(cVerbaFol)
				DbSelectArea("SRK")
				DbSetOrder(1)
	
				MsSeek(xFilial("SRK")+SF1->F1_NUMRA+Soma1(cVerbaFol),.T.)
				dbSkip(-1)
	
				If xFilial("SRK")+SF1->F1_NUMRA+cVerbaFol == SRK->RK_FILIAL+SRK->RK_MAT+SRK->RK_PD
					cDocFol := Soma1(SRK->RK_DOCUMEN)
				Else
					cDocFol := StrZero(1,Len(SRK->RK_DOCUMEN))
				EndIf
				
				For nX := 1 To Len(aColsSE2)
					If nPE2VlrTit > 0 .And. nPE2DtVenc > 0
						nParcela++
						If nX == 1
							dDtVencto	:= aColsSE2[nX,nPE2DtVenc]
							nVlrParc	:= aColsSE2[nX,nPE2VlrTit]
						Endif
						nVlrTotal += aColsSE2[nX,nPE2VlrTit]
					Endif
				Next nX
				
				aAdd(aCab,{"RA_FILIAL"	,xFilial("SRK"),Nil})
				aAdd(aCab,{"RA_MAT"		,PadR(SF1->F1_NUMRA,TamSx3("RA_MAT")[1]),Nil})
				
				aAdd(aItem,{"RK_PD"		,cVerbaFol,Nil})
				aAdd(aItem,{"RK_VALORTO",nVlrTotal,Nil})
				aAdd(aItem,{"RK_PARCELA",nParcela,Nil})
				aAdd(aItem,{"RK_VALORPA",nVlrParc,Nil})
				aAdd(aItem,{"RK_DTMOVI"	,dDataBase,Nil})
				aAdd(aItem,{"RK_DTVENC"	,dDtVencto,Nil})
				aAdd(aItem,{"RK_DOCUMEN",cDocFol,Nil})
				aAdd(aItem,{"RK_CC"		,SRA->RA_CC,Nil})
				aAdd(aItens,aItem)
				
				MSExecAuto({|x,y,z| GPEA110(x,y,z)},nOpcGpe110,aCab,aItens)
				
				If lMsErroAuto
					lRet := .F.
					aErroAuto := GetAutoGRLog()
					For nX := 1 To Len(aErroAuto)
						cMsgRet += AllTrim(aErroAuto[nX])
					Next nX
				Else
					If cPaisLoc == "BRA"
						RecLock("SF1")
						SF1->F1_DOCFOL   := cDocFol
						SF1->F1_VERBAFO  := cVerbaFol
						MsUnLock()
					EndIf
				EndIf
			EndIf
		EndIf

		If lRet .And. nValIsento > 0 .And. Len(aCodFol) >= 1413
			// Obtem o codigo da verba
			cVerbaIse := aCodFol[1413,001] //Pagamento de autonomos
			If !Empty(cVerbaIse)
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Obtem o proximo numero de documento                          ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				DbSelectArea("SRK")
				DbSetOrder(1)
				MsSeek(xFilial("SRK")+SF1->F1_NUMRA+Soma1(cVerbaIse),.T.)
				dbSkip(-1)
				If xFilial("SRK")+SF1->F1_NUMRA+cVerbaIse == SRK->RK_FILIAL+SRK->RK_MAT+SRK->RK_PD
					cDocFol := Soma1(SRK->RK_DOCUMEN)
				Else
					cDocFol := StrZero(1,Len(SRK->RK_DOCUMEN))
				EndIf
				
				For nX := 1 To Len(aColsSE2)
					If nPE2VlrTit > 0 .And. nPE2DtVenc > 0
						nParcela++
						If nX == 1
							dDtVencto	:= aColsSE2[nX,nPE2DtVenc]
							nVlrParc	:= aColsSE2[nX,nPE2VlrTit]
						Endif
						nVlrTotal += aColsSE2[nX,nPE2VlrTit]
					Endif
				Next nX
					
				aAdd(aCab,{"RA_FILIAL"	,xFilial("SRK"),Nil})
				aAdd(aCab,{"RA_MAT"		,PadR(SF1->F1_NUMRA,TamSx3("RA_MAT")[1]),Nil})
								
				aAdd(aItem,{"RK_PD"		,cVerbaIse,Nil})
				aAdd(aItem,{"RK_VALORTO",nVlrTotal,Nil})
				aAdd(aItem,{"RK_PARCELA",nParcela,Nil})
				aAdd(aItem,{"RK_VALORPA",nVlrParc,Nil})
				aAdd(aItem,{"RK_DTMOVI"	,dDataBase,Nil})
				aAdd(aItem,{"RK_DTVENC"	,dDtVencto,Nil})
				aAdd(aItem,{"RK_DOCUMEN",cDocFol,Nil})
				aAdd(aItem,{"RK_CC"		,SRA->RA_CC,Nil})
				aAdd(aItens,aItem)
				
				MSExecAuto({|x,y,z| GPEA110(x,y,z)},nOpcGpe110,aCab,aItens)
				
				If lMsErroAuto
					lRet := .F.
					aErroAuto := GetAutoGRLog()
					For nX := 1 To Len(aErroAuto)
						cMsgRet += AllTrim(aErroAuto[nX])
					Next nX
				Else
					If cPaisLoc == "BRA"
						RecLock("SF1")
						SF1->F1_DOCISEN := cDocFol
						SF1->F1_VERBAIS := cVerbaIse
						MsUnLock()
					EndIf
				EndIf
			Endif
		EndIf
		
		If lRet .And. Len(aColsSe2) > 0 .And. nPE2ISS > 0 .And. Len(aCodFol) >= 1638
			nParcela := 0
			aCab	 := {}
			aItem	 := {}
			aItens	 := {}
			cMsgRet	 := ""
			For nX := 1 To Len(aColsSE2)
				nParcela++
				nVlrISS += aColsSE2[nX,nPE2ISS]
				If nX == 1
					dDtVencto	:= aColsSE2[nX,nPE2DtVenc]
					nVlrParc	:= aColsSE2[nX,nPE2ISS]
				Endif
			Next nX
			
			If nVlrISS > 0
				cVerbaISS := aCodFol[1638,001]
				If !Empty(cVerbaISS)
					aAdd(aCab,{"RA_FILIAL"	,xFilial("SRK"),Nil})
					aAdd(aCab,{"RA_MAT"		,PadR(SF1->F1_NUMRA,TamSx3("RA_MAT")[1]),Nil})
									
					aAdd(aItem,{"RK_PD"		,cVerbaISS,Nil})
					aAdd(aItem,{"RK_VALORTO",nVlrISS,Nil})
					aAdd(aItem,{"RK_PARCELA",nParcela,Nil})
					aAdd(aItem,{"RK_VALORPA",nVlrParc,Nil})
					aAdd(aItem,{"RK_DTMOVI"	,dDataBase,Nil})
					aAdd(aItem,{"RK_DTVENC"	,dDtVencto,Nil})
					aAdd(aItem,{"RK_DOCUMEN",cDocFol,Nil})
					aAdd(aItem,{"RK_CC"		,SRA->RA_CC,Nil})
					aAdd(aItens,aItem)
					
					MSExecAuto({|x,y,z| GPEA110(x,y,z)},nOpcGpe110,aCab,aItens)
					
					If lMsErroAuto
						lRet := .F.
						aErroAuto := GetAutoGRLog()
						For nX := 1 To Len(aErroAuto)
							cMsgRet += AllTrim(aErroAuto[nX])
						Next nX
					EndIf
				Endif
			Endif
		Endif		
	EndIf
	
Case nOpcA == 2 .And. !Empty(SF1->F1_NUMRA)
	DbSelectArea("SRA")
	DbSetOrder(1)
	If MsSeek(xFilial("SRA")+SF1->F1_NUMRA)
		If cPaisLoc == "BRA"
			cVerbaFol := SF1->F1_VERBAFO
			cVerbaIse := SF1->F1_VERBAIS
		EndIf

		If !Empty(cVerbaFol) .And. cPaisLoc == "BRA" .And. !Empty(SF1->F1_DOCFOL)
			aRecSRK := {}
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Analise se o documento foi pago                              ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			DbSelectArea("SRK")
			DbSetOrder(1)
			If MsSeek(xFilial("SRK")+Padr(AllTrim(SF1->F1_NUMRA),TamSX3("RK_MAT")[1])+Padr(AllTrim(cVerbaFol),TamSX3("RK_PD")[1]))
				While !Eof() .And. xFilial("SRK") == SRK->RK_FILIAL .And.;
						Alltrim(SF1->F1_NUMRA) == Alltrim(SRK->RK_MAT) .And.;
						Alltrim(cVerbaFol) == Alltrim(SRK->RK_PD)

					If Alltrim(SF1->F1_DOCFOL) == Alltrim(SRK->RK_DOCUMEN)
						aadd(aRecSRK,SRK->(Recno()))
					EndIf

					DbSelectArea("SRK")
					dbSkip()
				EndDo
				For nX := 1 To Len(aRecSRK)

					SRK->(MsGoto(aRecSRK[nX]))

					RecLock("SRK")
					If SRK->RK_VLRPAGO == 0
						dbDelete()
						MsUnLock()
					Else
						nValor := SRK->RK_VALORTO

						DbSelectArea("SRK")
						DbSetOrder(1)
						MsSeek(xFilial("SRK")+SF1->F1_NUMRA+cVerbaFol+Soma1(SF1->F1_DOCFOL),.T.)
						dbSkip(-1)
						nParcela := SRK->RK_PARCELA+1

						RecLock("SRK",.T.)
						SRK->RK_FILIAL  := xFilial("SRK")
						SRK->RK_MAT     := SF1->F1_NUMRA
						SRK->RK_PD      := cVerbaFol
						SRK->RK_VALORTO := -1*nValor
						SRK->RK_PARCELA := nParcela
						SRK->RK_VALORPA := -1*nValor
						SRK->RK_DTMOVI  := dDataBase
						SRK->RK_DTVENC  := dDataBase
						SRK->RK_DOCUMEN := cDocFol
						SRK->RK_CC      := SRA->RA_CC
						SRK->RK_STATUS  := "2"
						MsUnLock()
					EndIf
				Next nX
			EndIf
		EndIf
		If !Empty(cVerbaIse) .And. cPaisLoc == "BRA" .And. !Empty(SF1->F1_DOCISEN)
			aRecSRK := {}
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Analise se o documento foi pago                              ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			DbSelectArea("SRK")
			DbSetOrder(1)
			If MsSeek(xFilial("SRK")+Padr(AllTrim(SF1->F1_NUMRA),TamSX3("RK_MAT")[1])+Padr(AllTrim(cVerbaIse),TamSX3("RK_PD")[1]))
				While !Eof() .And. xFilial("SRK") == SRK->RK_FILIAL .And.;
						Alltrim(SF1->F1_NUMRA) == Alltrim(SRK->RK_MAT) .And.;
						Alltrim(cVerbaIse) == Alltrim(SRK->RK_PD)

					If Alltrim(SF1->F1_DOCISEN) == Alltrim(SRK->RK_DOCUMEN)
						aadd(aRecSRK,SRK->(Recno()))
					EndIf

					DbSelectArea("SRK")
					dbSkip()
				EndDo
				For nX := 1 To Len(aRecSRK)

					SRK->(MsGoto(aRecSRK[nX]))

					RecLock("SRK")
					If SRK->RK_VLRPAGO == 0
						dbDelete()
						MsUnLock()
					Else
						nValor := SRK->RK_VALORTO

						DbSelectArea("SRK")
						DbSetOrder(1)
						MsSeek(xFilial("SRK")+SF1->F1_NUMRA+cVerbaIse+Soma1(SF1->F1_DOCISEN),.T.)
						dbSkip(-1)
						nParcela := SRK->RK_PARCELA+1

						RecLock("SRK",.T.)
						SRK->RK_FILIAL  := xFilial("SRK")
						SRK->RK_MAT     := SF1->F1_NUMRA
						SRK->RK_PD      := cVerbaIse
						SRK->RK_VALORTO := -1*nValor
						SRK->RK_PARCELA := nParcela
						SRK->RK_VALORPA := -1*nValor
						SRK->RK_DTMOVI  := dDataBase
						SRK->RK_DTVENC  := dDataBase
						SRK->RK_DOCUMEN := cDocFol
						SRK->RK_CC      := SRA->RA_CC
						SRK->RK_STATUS  := "2"
						MsUnLock()
					EndIf
				Next nX
			EndIf
		EndIf
		
		If cPaisLoc == "BRA" .And. !Empty(SF1->F1_DOCFOL) .And. FP_CODFOL(@aCodFol,SRA->RA_FILIAL) .And. Len(aCodFol) >= 1638
			cVerbaISS := aCodFol[1638,001]
			
			aRecSRK := {}
			
			//³ Analise se o documento foi pago                              ³
			DbSelectArea("SRK")
			DbSetOrder(1)
			If MsSeek(xFilial("SRK")+Padr(AllTrim(SF1->F1_NUMRA),TamSX3("RK_MAT")[1])+Padr(AllTrim(cVerbaISS),TamSX3("RK_PD")[1]))
				While !Eof() .And. xFilial("SRK") == SRK->RK_FILIAL .And.;
						Alltrim(SF1->F1_NUMRA) == Alltrim(SRK->RK_MAT) .And.;
						Alltrim(cVerbaISS) == Alltrim(SRK->RK_PD)

					If Alltrim(SF1->F1_DOCFOL) == Alltrim(SRK->RK_DOCUMEN)
						aadd(aRecSRK,SRK->(Recno()))
					EndIf

					DbSelectArea("SRK")
					dbSkip()
				EndDo
				
				For nX := 1 To Len(aRecSRK)

					SRK->(MsGoto(aRecSRK[nX]))

					RecLock("SRK")
					If SRK->RK_VLRPAGO == 0
						dbDelete()
						MsUnLock()
					Else
						nValor := SRK->RK_VALORTO

						DbSelectArea("SRK")
						DbSetOrder(1)
						MsSeek(xFilial("SRK")+SF1->F1_NUMRA+cVerbaISS+Soma1(SF1->F1_DOCFOL),.T.)
						dbSkip(-1)
						nParcela := SRK->RK_PARCELA+1

						RecLock("SRK",.T.)
						SRK->RK_FILIAL  := xFilial("SRK")
						SRK->RK_MAT     := SF1->F1_NUMRA
						SRK->RK_PD      := cVerbaISS
						SRK->RK_VALORTO := -1*nValor
						SRK->RK_PARCELA := nParcela
						SRK->RK_VALORPA := -1*nValor
						SRK->RK_DTMOVI  := dDataBase
						SRK->RK_DTVENC  := dDataBase
						SRK->RK_DOCUMEN := cDocFol
						SRK->RK_CC      := SRA->RA_CC
						SRK->RK_STATUS  := "2"
						MsUnLock()
					EndIf
				Next nX
			EndIf
		EndIf
		
	EndIf
EndCase

RestArea(aArea)
FwFreeArray(aArea)
RestArea(aAreaSB5)
FwFreeArray(aAreaSB5)

cCadastro := cCadBkp //Restaura o titulo da tela

Return {lRet,cMsgRet}
