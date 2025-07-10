#INCLUDE "PROTHEUS.CH"
#INCLUDE "MATA103REINF.CH"

/*/{Protheus.doc} A103NATREN
Interface para informacao dos valores de natureza de rendimento - Projeto REINF
@author rodrigo.mpontes
@since 28/03/2018
@version 12.1.17
@type function
/*/

Function A103NatRen(aHeadDHR,aColsDHR,lIncNat,lClaNat,aColRotAut,cPrdNatRend)

Local aArea     	:= GetArea()
Local aInDHR		:= {"DHR_NATREN"}
Local aNotDHR		:= {"DHR_FILIAL","DHR_DOC","DHR_SERIE","DHR_FORNEC","DHR_LOJA"}
Local aColNatRend	:= {}
Local nPosItNf		:= aScan(aHeader,{|x| AllTrim(x[2]) == "D1_ITEM"} )
Local nItemDHR  	:= 0
Local nX			:= 0
Local nPosCpo		:= 0
Local nItem			:= 0
Local nOpcA    		:= 0
Local nA			:= 0
Local nB			:= 0
Local nC			:= 0
Local oDlgNR      	:= Nil
Local lNatRenF2Q	:= F2Q->(FieldPos("F2Q_NATREN")) > 0

Default aHeadDHR	:= {}
Default aColsDHR	:= {}
Default aColRotAut	:= {}
Default lIncNat		:= .T.
Default lClaNat		:= .T.
Default cPrdNatRend	:= ""

// Montagem do aHeader DHR
If Empty(aHeadDHR)
	aHeadDHR := COMXHDCO("DHR",aInDHR)
EndIf

// Montagem do aHeader DHR - Suspensão
If Empty(aHdSusDHR)
	aHdSusDHR := COMXHDCO("DHR",,aNotDHR)
EndIf

// Montagem do aCols DHR
If !lIncNat .And. Empty(aColsDHR)	// Entra nesta condicao somente quando for Visualizacao, Classificacao ou Exclusao
	DbSelectArea("DHR")
	DHR->(DbSetOrder(1))
	If DHR->(DbSeek(xFilial("DHR")+cNFiscal+cSerie+cA100For+cLoja))
		While DHR->(!Eof()) .And. ; 
				xFilial("DHR") == DHR->DHR_FILIAL .And. ;
				DHR->DHR_DOC == cNFiscal .And. ;
				DHR->DHR_SERIE == cSerie .And. ;
				DHR->DHR_FORNEC == cA100For .And. ;
				DHR->DHR_LOJA == cLoja

			aAdd(aColsDHR,{DHR->DHR_ITEM,{Array(Len(aHeadDHR)+1)}})
			nItemDHR++
			For nX := 1 To Len(aHeadDHR)
				aColsDHR[nItemDHR][2][Len(aColsDHR[nItemDHR][2])][nX] := Iif(aHeadDHR[nX][10]<>"V",DHR->(FieldGet(FieldPos(aHeadDHR[nX][2]))),DHR->(CriaVar(aHeadDHR[nX][2])))
			Next nX
			aColsDHR[nItemDHR][2][Len(aColsDHR[nItemDHR][2])][Len(aHeadDHR)+1] := .F.

			DHR->(DbSkip())
		Enddo
	EndIf
	
ElseIf l103Auto .And. Len(aColRotAut) > 0	// Entra nesta condicao somente quando for rotina automatica
	If MsGetDAuto(aAutoItens,,,aAutoCab,3)
		For nA := 1 To Len(aColRotAut)
			aAdd(aCoSusDHR,{aColRotAut[nA][1],{Array(Len(aHdSusDHR)+1)}})
			For nB := 1 To Len(aHdSusDHR)
				aCoSusDHR[Len(aCoSusDHR)][2][1][nB] := CriaVar(aHdSusDHR[nB,2])
			Next nB

			For nB := 1 To Len(aColRotAut[nA,2])
				For nC := 1 To Len(aColRotAut[nA,2,nB])
					nPosCpo := aScan(aHdSusDHR,{|x| AllTrim(x[2]) == aColRotAut[nA,2,nB,nC,1]})
					If nPosCpo > 0
						aCoSusDHR[Len(aCoSusDHR)][2][1][nPosCpo] := aColRotAut[nA,2,nB,nC,2]
					EndIf
				Next nC
				aCoSusDHR[Len(aCoSusDHR)][2][1][Len(aHdSusDHR)+1] := .F.
			Next nB
		Next nA

		A103UpdDHR()
	Endif
EndIf

If !l103Auto
	If (nItem := aScan(aColsDHR,{|x| x[1] == aCols[n][nPosItNf]})) > 0
		aColNatRend := aClone(aColsDHR[nItem][2])
		If lNatRenF2Q .And. !Empty(cPrdNatRend)
			aColNatRend[Len(aColNatRend),1] := GetAdvFVal("F2Q","F2Q_NATREN", FwxFilial("F2Q") + PadR(cPrdNatRend,TamSX3("F2Q_PRODUT")[1]),1)
		Endif
	Else
		aAdd(aColNatRend,Array(Len(aHeadDHR)+1))
		For nX := 1 To Len(aHeadDHR)
			If lNatRenF2Q .And. !Empty(cPrdNatRend)
				aColNatRend[1,nX] := GetAdvFVal("F2Q","F2Q_NATREN", FwxFilial("F2Q") + PadR(cPrdNatRend,TamSX3("F2Q_PRODUT")[1]),1)
			Else
				aColNatRend[1,nX] := CriaVar(aHeadDHR[nX,2])
			Endif
		Next nX
		aColNatRend[1,Len(aHeadDHR)+1] := .F.
	EndIf

	If Empty(cPrdNatRend) 

		DEFINE MSDIALOG oDlgNR FROM 100,100 TO 280,550 TITLE STR0001 Of oMainWnd PIXEL //"Natureza de Rendimento"

		oGetDHR := MsNewGetDados():New(20,3,65,215,IIF((lIncNat.Or.lClaNat),GD_INSERT+GD_UPDATE+GD_DELETE,0),,,,,,1,,,,oDlgNR,aHeadDHR,aColNatRend)

		@ 6 ,4 SAY AllTrim(RetTitle("F1_DOC"))+":" OF oDlgNR PIXEL SIZE 30,09
		@ 6 ,36 SAY cNFiscal +"-"+ Substr(cSerie,1,3) OF oDlgNR PIXEL SIZE 50,09
		@ 6 ,90 SAY AllTrim(RetTitle("D1_ITEM"))+":" OF oDlgNR PIXEL SIZE 30,09
		@ 6 ,112 SAY aCols[n][nPosItNf] OF oDlgNR PIXEL SIZE 20,09

		If !lIncNat .And. !lClaNat
			@ 73,112 BUTTON STR0010 SIZE 40,11 ACTION A103DetSus() OF oDlgNR PIXEL //"Mais Detalhes" 
		Endif

		Define SButton From 73,195 Type 1 Of oDlgNR Enable Action ( nOpcA := 1, oDlgNR:End() )
		Define SButton From 73,160 Type 2 Of oDlgNR Enable Action oDlgNR:End()

		ACTIVATE MSDIALOG oDlgNR CENTERED

		If nOpcA == 1 .And. (lIncNat .Or. lClaNat)
			If nItem > 0
				aColsDHR[nItem][2] := aClone(oGetDHR:aCols)
			Else
				aAdd(aColsDHR,{aCols[n][nPosItNf],aClone(oGetDHR:aCols)})
			EndIf
		EndIf
	Else
		If nItem > 0
			aColsDHR[nItem][2] := aClone(aColNatRend)
		Else
			aAdd(aColsDHR,{aCols[n][nPosItNf],aClone(aColNatRend)})
		EndIf
	Endif

EndIf

RestArea(aArea)

Return

/*/{Protheus.doc} A103FKW
Tabela intermediaria FKW Natureza de Rendimentos - Projeto REINF

@param cOpc		I-Inclusão/E-Exclusão
@param aITD1	aCols dos itens da NF
@param aITE2	Recno dos titulos a pagar gerados

@author rodrigo.mpontes
@since 28/03/2018
@version 12.1.17
@type function
/*/

Function A103FKW(cOpc,aITD1,aITE2)

Local aArea		:= GetArea()
Local aNatPerc	:= {}
Local aNatDoc	:= {}
Local aAux		:= {}
Local aDados	:= {}
Local aSusp		:= {}
Local cChave	:= ""
Local cChaveTit	:= ""
Local nTDHRDoc	:= TamSX3("DHR_DOC")[1]
Local nTDHRSer	:= TamSX3("DHR_SERIE")[1]
Local nTDHRFor	:= TamSX3("DHR_FORNEC")[1]
Local nTDHRLoj	:= TamSX3("DHR_LOJA")[1]
Local nTDHRIte	:= TamSX3("DHR_ITEM")[1]
Local nPITE		:= aScan(aHeader,{|x| AllTrim(x[2]) == "D1_ITEM"})
Local nPIRR		:= aScan(aHeader,{|x| AllTrim(x[2]) == "D1_VALIRR"})
Local nPPIS		:= aScan(aHeader,{|x| AllTrim(x[2]) == "D1_VALPIS"})
Local nPCOF		:= aScan(aHeader,{|x| AllTrim(x[2]) == "D1_VALCOF"})
Local nPCSL		:= aScan(aHeader,{|x| AllTrim(x[2]) == "D1_VALCSL"})
Local nPTOT		:= aScan(aHeader,{|x| AllTrim(x[2]) == "D1_TOTAL"})
Local nPBIRR	:= aScan(aHeader,{|x| AllTrim(x[2]) == "D1_BASEIRR"})
Local nPBPIS	:= aScan(aHeader,{|x| AllTrim(x[2]) == "D1_BASEPIS"})
Local nPBCOF	:= aScan(aHeader,{|x| AllTrim(x[2]) == "D1_BASECOF"})
Local nPBCSL	:= aScan(aHeader,{|x| AllTrim(x[2]) == "D1_BASECSL"})
Local nTotIRR	:= 0
Local nTotPIS	:= 0
Local nTotCOF	:= 0
Local nTotCSL	:= 0
Local nTotTOT	:= 0
Local nTotBIRR	:= 0
Local nTotBPIS	:= 0
Local nTotBCOF	:= 0
Local nTotBCSL	:= 0
Local nTotNRIRR	:= 0
Local nTotNRPIS	:= 0
Local nTotNRCOF	:= 0
Local nTotNRCSL	:= 0
Local nTotNRTOT := 0
Local nTotNRBIRR:= 0
Local nTotNRBPIS:= 0
Local nTotNRBCOF:= 0
Local nTotNRBCSL:= 0
Local nI		:= 0
Local nX		:= 0
Local nPos		:= 0
Local nPerc		:= 0
Local nValor	:= 0
Local nBase		:= 0
Local aNatRenExc:= A103FKXTRIB()

DbSelectArea("DHR")
DHR->(DbSetOrder(1))

DbSelectArea("SD1")
SD1->(DbSetOrder(1))

If cOpc == "I" //Inclusão
	For nI := 1 To Len(aITD1)
		If nPIRR > 0 //Total de IRRF
			nTotIRR += aITD1[nI,nPIRR]
		Endif
		
		If nPPIS > 0 //Total de PIS
			nTotPIS += aITD1[nI,nPPIS]
		Endif
		
		If nPCOF > 0 //Total de COFINS
			nTotCOF += aITD1[nI,nPCOF]
		Endif
		
		If nPCSL > 0 //Total de CSLL
			nTotCSL += aITD1[nI,nPCSL]
		Endif

		If nPTOT > 0 //Total do Item
			nTotTOT += aITD1[nI,nPTOT]
		Endif

		If nPBIRR > 0 //Total Base IRRF
			nTotBIRR += aITD1[nI,nPBIRR]
		Endif

		If nPBPIS > 0 //Total Base PIS
			nTotBPIS += aITD1[nI,nPBPIS]
		Endif

		If nPBCOF > 0 //Total Base COF
			nTotBCOF += aITD1[nI,nPBCOF]
		Endif

		If nPBCSL > 0 //Total Base CSL
			nTotBCSL += aITD1[nI,nPBCSL]
		Endif
		
		//Naturezas de Rendimentos e Itens da NF
		cChave := xFilial("DHR") + Padr(cNFiscal,nTDHRDoc) + Padr(cSerie,nTDHRSer) + Padr(cA100For,nTDHRFor) + Padr(cLoja,nTDHRLoj) + Padr(aITD1[nI,nPITE],nTDHRIte)
		If DHR->(DbSeek(cChave))
			nPos := aScan(aNatDoc,{|x| Alltrim(x[1]) == AllTrim(DHR->DHR_NATREN)})
			If nPos == 0
				aAdd(aNatDoc,{AllTrim(DHR->DHR_NATREN),DHR->DHR_ITEM})
			Else
				aNatDoc[nPos,2] += "|" + DHR->DHR_ITEM
			Endif
		Endif
	Next nI
	
	For nI := 1 To Len(aNatDoc)
		aAux := Separa(aNatDoc[nI,2],"|") 
		
		nTotNRIRR := 0
		nTotNRPIS := 0
		nTotNRCOF := 0
		nTotNRCSL := 0
		nTotNRTOT := 0
		nTotNRBIRR:= 0
		nTotNRBPIS:= 0
		nTotNRBCOF:= 0
		nTotNRBCSL:= 0
		
		//Total de IR/PCC por Natureza de Rendimento
		For nX := 1 To Len(aAux)
			nPos := aScan(aITD1,{|x| AllTrim(x[nPITE]) == AllTrim(aAux[nX])})
			If nPos > 0
				If aITD1[nPos,nPIRR] > 0 //Total de IRRF
					nTotNRIRR += aITD1[nPos,nPIRR]
				Endif
				
				If aITD1[nPos,nPPIS] > 0 //Total de PIS
					nTotNRPIS += aITD1[nPos,nPPIS]
				Endif
				
				If aITD1[nPos,nPCOF] > 0 //Total de COFINS
					nTotNRCOF += aITD1[nPos,nPCOF]
				Endif
				
				If aITD1[nPos,nPCSL] > 0 //Total de CSLL
					nTotNRCSL += aITD1[nPos,nPCSL]
				Endif

				If aITD1[nPos,nPTOT] > 0 //Total do item
					nTotNRTOT += aITD1[nPos,nPTOT]
				Endif

				If aITD1[nPos,nPBIRR] > 0 //Total base IRRF
					nTotNRBIRR += aITD1[nPos,nPBIRR]
				Endif

				If aITD1[nPos,nPBPIS] > 0 //Total base PIS
					nTotNRBPIS += aITD1[nPos,nPBPIS]
				Endif

				If aITD1[nPos,nPBCOF] > 0 //Total base COF
					nTotNRBCOF += aITD1[nPos,nPBCOF]
				Endif

				If aITD1[nPos,nPBCSL] > 0 //Total base CSL
					nTotNRBCSL += aITD1[nPos,nPBCSL]
				Endif
			Endif
		Next nX
		
		//Proporcionamento de imposto x natureza de rendimento
		//IRRF
		If nTotIRR > 0
			nPerc := nTotNRIRR * 100 / nTotIRR
			
			aAdd(aNatPerc,{aNatDoc[nI,1],"IRF",nPerc})
			//Fornecedor PF - IRRF na baixa
		Elseif nTotIRR == 0 .And. nTotBIRR > 0 .And. GetAdvFVal("SA2","A2_CALCIRF", FwxFilial("SA2") + ca100For + cLoja,1) == "2" .AND. ;
				((GetAdvFVal("SA2","A2_TIPO", FwxFilial("SA2") + ca100For + cLoja,1) == "F" ) .OR.;
				 (GetAdvFVal("SA2","A2_TIPO", FwxFilial("SA2") + ca100For + cLoja,1) == "J" .AND. GetAdvFVal("SA2","A2_IRPROG", FwxFilial("SA2") + ca100For + cLoja,1) == "1") )
			nPerc := nTotNRBIRR * 100 / nTotBIRR

			aAdd(aNatPerc,{aNatDoc[nI,1],"IRFB",nPerc}) 
		Elseif nTotIRR == 0 .And. nTotBIRR == 0 //Suspensão total imposto
			aAdd(aNatPerc,{aNatDoc[nI,1],"IRFT",100}) 
		Endif
		
		//PIS
		If nTotPIS > 0 
			nPerc := nTotNRPIS * 100 / nTotPIS
			
			aAdd(aNatPerc,{aNatDoc[nI,1],"PIS",nPerc})
		Elseif nTotPIS == 0 .And. nTotBPIS == 0 //Suspensão total imposto
			aAdd(aNatPerc,{aNatDoc[nI,1],"PIST",100}) 
		Endif
		
		//COFINS
		If nTotCOF > 0
			nPerc := nTotNRCOF * 100 / nTotCOF
			
			aAdd(aNatPerc,{aNatDoc[nI,1],"COF",nPerc})
		Elseif nTotCOF == 0 .And. nTotBCOF == 0 //Suspensão total imposto
			aAdd(aNatPerc,{aNatDoc[nI,1],"COFT",100})
		Endif
		
		//CSLL
		If nTotCSL > 0
			nPerc := nTotNRCSL * 100 / nTotCSL
			
			aAdd(aNatPerc,{aNatDoc[nI,1],"CSL",nPerc})
		Elseif nTotCSL == 0 .And. nTotBCSL == 0 //Suspensão total imposto
			aAdd(aNatPerc,{aNatDoc[nI,1],"CSLT",100})
		Endif

		//Natureza Rendimento - Exceção - Sem Imposto
		If nTotTOT > 0 .And. Len(aNatRenExc) > 0
			nPerc := nTotNRTOT * 100 / nTotTOT
			
			nPos := aScan(aNatRenExc,{|x| x == aNatDoc[nI,1]})
			If nPos > 0
				aAdd(aNatPerc,{aNatDoc[nI,1],"SEMIMP",nPerc}) 
			Endif
		Endif
	Next nI
	
	DbSelectArea("SE2") 
	
	//Gera dados para a tabela intermediaria a partir dos titulos (SE2) x Natureza de rendimentos
	For nI := 1 To Len(aITE2)
		SE2->(DbGoTo(aITE2[nI]))
		
		cChaveTit := FINGRVFK7("SE2", xFilial("SE2")+"|"+SE2->E2_PREFIXO+"|"+SE2->E2_NUM+"|"+SE2->E2_PARCELA+"|"+SE2->E2_TIPO+"|"+SE2->E2_FORNECE+"|"+SE2->E2_LOJA)
		
		For nX := 1 To Len(aNatDoc)
			nPos := aScan(aNatPerc,{|x| x[1] == aNatDoc[nX,1] .And. AllTrim(x[2]) == "IRF"})
			If nPos > 0
				nPerc	:= aNatPerc[nPos,3]
				nValor	:= (SE2->E2_IRRF * nPerc) / 100
				nBase	:= (SE2->E2_BASEIRF * nPerc ) / 100
				aSusp	:= A103SUSPDHR("IRF",aNatDoc[nX,1],Len(aITE2)) 
				
				If Len(aSusp) > 0 .And. (nValor > 0 .Or. (nValor == 0 .And. A103SusNat(aNatDoc[nX,1],"IRF",nI)))
					aadd(aDados,{xFilial("FKW"),;
								 cChaveTit,;
								 "IRF",;
								 aNatDoc[nX,1],;
								 nPerc,;
								 nBase,;
								 nValor,;
								 aSusp[1],;
								 aSusp[2],;
								 aSusp[3],;
								 aSusp[4],;
								 aSusp[5],;
								 aSusp[6]})
				Endif
			Endif 

			nPos := aScan(aNatPerc,{|x| x[1] == aNatDoc[nX,1] .And. AllTrim(x[2]) == "IRFB"})
			If nPos > 0
				nPerc	:= aNatPerc[nPos,3]
				nValor	:= (SE2->E2_IRRF * nPerc) / 100
				nBase	:= (SE2->E2_BASEIRF * nPerc ) / 100
				aSusp	:= A103SUSPDHR("IRF",aNatDoc[nX,1],Len(aITE2)) 
				
				If Len(aSusp) > 0
					aadd(aDados,{xFilial("FKW"),;
								 cChaveTit,;
								 "IRF",;
								 aNatDoc[nX,1],;
								 nPerc,;
								 nBase,;
								 nValor,;
								 aSusp[1],;
								 aSusp[2],;
								 aSusp[3],;
								 aSusp[4],;
								 aSusp[5],;
								 aSusp[6]})
				Endif
			Endif

			nPos := aScan(aNatPerc,{|x| x[1] == aNatDoc[nX,1] .And. AllTrim(x[2]) == "IRFT"})
			If nPos > 0
				nPerc	:= aNatPerc[nPos,3]
				nValor	:= (SE2->E2_IRRF * nPerc) / 100
				nBase	:= (SE2->E2_BASEIRF * nPerc ) / 100
				aSusp	:= A103SUSPDHR("IRF",aNatDoc[nX,1],Len(aITE2)) 
				
				If Len(aSusp) > 0
					aadd(aDados,{xFilial("FKW"),;
								 cChaveTit,;
								 "IRF",;
								 aNatDoc[nX,1],;
								 nPerc,;
								 nBase,;
								 nValor,;
								 aSusp[1],;
								 aSusp[2],;
								 aSusp[3],;
								 aSusp[4],;
								 aSusp[5],;
								 aSusp[6]})
				Endif
			Endif
		
			nPos := aScan(aNatPerc,{|x| x[1] == aNatDoc[nX,1] .And. x[2] == "PIS"})
			If nPos > 0
				nPerc	:= aNatPerc[nPos,3]
				nValor	:= (SE2->E2_PIS * nPerc) / 100
				nBase	:= (SE2->E2_BASEPIS * nPerc ) / 100
				aSusp	:= A103SUSPDHR("PIS",aNatDoc[nX,1],Len(aITE2))
				
				If Len(aSusp) > 0 .And. (nValor > 0 .Or. (nValor == 0 .And. A103SusNat(aNatDoc[nX,1],"PIS",nI)))
					aadd(aDados,{xFilial("FKW"),;
								 cChaveTit,;
								 "PIS",;
								 aNatDoc[nX,1],;
								 nPerc,;
								 nBase,;
								 nValor,;
								 aSusp[1],;
								 aSusp[2],;
								 aSusp[3],;
								 aSusp[4],;
								 aSusp[5],;
								 aSusp[6]})
				Endif
			Endif

			nPos := aScan(aNatPerc,{|x| x[1] == aNatDoc[nX,1] .And. x[2] == "PIST"})
			If nPos > 0
				nPerc	:= aNatPerc[nPos,3]
				nValor	:= (SE2->E2_PIS * nPerc) / 100
				nBase	:= (SE2->E2_BASEPIS * nPerc ) / 100
				aSusp	:= A103SUSPDHR("PIS",aNatDoc[nX,1],Len(aITE2))
				
				If Len(aSusp) > 0
					aadd(aDados,{xFilial("FKW"),;
								 cChaveTit,;
								 "PIS",;
								 aNatDoc[nX,1],;
								 nPerc,;
								 nBase,;
								 nValor,;
								 aSusp[1],;
								 aSusp[2],;
								 aSusp[3],;
								 aSusp[4],;
								 aSusp[5],;
								 aSusp[6]})
				Endif
			Endif
		
			nPos := aScan(aNatPerc,{|x| x[1] == aNatDoc[nX,1] .And. x[2] == "COF"})
			If nPos > 0
				nPerc	:= aNatPerc[nPos,3]
				nValor	:= (SE2->E2_COFINS * nPerc) / 100
				nBase	:= (SE2->E2_BASECOF * nPerc ) / 100
				aSusp	:= A103SUSPDHR("COF",aNatDoc[nX,1],Len(aITE2))
				
				If Len(aSusp) > 0 .And. (nValor > 0 .Or. (nValor == 0 .And. A103SusNat(aNatDoc[nX,1],"COF",nI)))
					aadd(aDados,{xFilial("FKW"),;
								 cChaveTit,;
								 "COF",;
								 aNatDoc[nX,1],;
								 nPerc,;
								 nBase,;
								 nValor,;
								 aSusp[1],;
								 aSusp[2],;
								 aSusp[3],;
								 aSusp[4],;
								 aSusp[5],;
								 aSusp[6]})
				Endif
			Endif

			nPos := aScan(aNatPerc,{|x| x[1] == aNatDoc[nX,1] .And. x[2] == "COFT"})
			If nPos > 0
				nPerc	:= aNatPerc[nPos,3]
				nValor	:= (SE2->E2_COFINS * nPerc) / 100
				nBase	:= (SE2->E2_BASECOF * nPerc ) / 100
				aSusp	:= A103SUSPDHR("COF",aNatDoc[nX,1],Len(aITE2))
				
				If Len(aSusp) > 0
					aadd(aDados,{xFilial("FKW"),;
								 cChaveTit,;
								 "COF",;
								 aNatDoc[nX,1],;
								 nPerc,;
								 nBase,;
								 nValor,;
								 aSusp[1],;
								 aSusp[2],;
								 aSusp[3],;
								 aSusp[4],;
								 aSusp[5],;
								 aSusp[6]})
				Endif
			Endif

			nPos := aScan(aNatPerc,{|x| x[1] == aNatDoc[nX,1] .And. x[2] == "CSL"})
			If nPos > 0
				nPerc	:= aNatPerc[nPos,3]
				nValor	:= (SE2->E2_CSLL * nPerc) / 100
				nBase	:= (SE2->E2_BASECSL * nPerc ) / 100
				aSusp	:= A103SUSPDHR("CSL",aNatDoc[nX,1],Len(aITE2))
				
				If Len(aSusp) > 0 .And. (nValor > 0 .Or. (nValor == 0 .And. A103SusNat(aNatDoc[nX,1],"CSL",nI)))
					aadd(aDados,{xFilial("FKW"),;
								 cChaveTit,;
								 "CSL",;
								 aNatDoc[nX,1],;
								 nPerc,;
								 nBase,;
								 nValor,;
								 aSusp[1],;
								 aSusp[2],;
								 aSusp[3],;
								 aSusp[4],;
								 aSusp[5],;
								 aSusp[6]})
				Endif
			Endif

			nPos := aScan(aNatPerc,{|x| x[1] == aNatDoc[nX,1] .And. x[2] == "CSLT"})
			If nPos > 0
				nPerc	:= aNatPerc[nPos,3]
				nValor	:= (SE2->E2_CSLL * nPerc) / 100
				nBase	:= (SE2->E2_BASECSL * nPerc ) / 100
				aSusp	:= A103SUSPDHR("CSL",aNatDoc[nX,1],Len(aITE2))
				
				If Len(aSusp) > 0
					aadd(aDados,{xFilial("FKW"),;
								 cChaveTit,;
								 "CSL",;
								 aNatDoc[nX,1],;
								 nPerc,;
								 nBase,;
								 nValor,;
								 aSusp[1],;
								 aSusp[2],;
								 aSusp[3],;
								 aSusp[4],;
								 aSusp[5],;
								 aSusp[6]})
				Endif
			Endif

			nPos := aScan(aNatPerc,{|x| x[1] == aNatDoc[nX,1] .And. x[2] == "SEMIMP"})
			If nPos > 0
				nPerc	:= aNatPerc[nPos,3]
				nValor	:= (SE2->E2_VALOR * nPerc) / 100
				aadd(aDados,{xFilial("FKW"),;
							cChaveTit,;
							"SEMIMP",;
							aNatDoc[nX,1],;
							nPerc,;
							nValor,;
							0,;
							0,;
							0,;
							"",;
							"",;
							"",;
							0})
			Endif

		Next nX
	Next nI

	If Len(aDados) > 0 .And. FindFunction("F070Grv") //Gravação na tabela intermediaria
		F070Grv(aDados,3,"1")
	Endif
		
Elseif cOpc == "E"

	//Exclusão da tabela intermediaria a partir dos titulos (SE2)
	For nI := 1 To Len(aITE2)
		SE2->(DbGoTo(aITE2[nI]))
		
		If Empty(SE2->E2_TITPAI) //Somente Titulos da NF
			cChaveTit := FINGRVFK7("SE2", xFilial("SE2")+"|"+SE2->E2_PREFIXO+"|"+SE2->E2_NUM+"|"+SE2->E2_PARCELA+"|"+SE2->E2_TIPO+"|"+SE2->E2_FORNECE+"|"+SE2->E2_LOJA)
			
			aadd(aDados,{xFilial("FKW"),;
					 	 cChaveTit})
		Endif
	Next nI

	If Len(aDados) > 0 .And. FindFunction("F070Grv") //Gravação na tabela intermediaria
		F070Grv(aDados,5,"1")
	Endif
	
Endif

RestArea(aArea)

Return

/*/{Protheus.doc} A103NATVLD
Valid do campo DHR_NATREN - Natureza de Rendimento

@author rodrigo.mpontes
@since 28/03/2018
@version 12.1.17
@type function
/*/

Function A103NATVLD()

Local lRet	:= .T.

//Verifica se existe natureza de rendimento
lRet := ExistCpo("FKX",M->DHR_NATREN,1)

//valida se fornecedor pode ser vinculado a natureza de rendimento
If lRet .And. FindFunction("VldNatRen")
	lRet := VldNatRen(M->DHR_NATREN,"1",cA100For,cLoja)
Endif

Return lRet

/*/{Protheus.doc} A103VldSusp
Verifica se podera haver alguma suspensão dos impostos IR/PIS/COFINS/CSLL

@param aHdD1	aHeader da SD1 (Itens da NF)
@param aLinD1	aCols da SD1 (Itens da NF)

@author rodrigo.mpontes
@since 30/08/2019
@version P12.1.17
 /*/
 
Function A103VldSusp(aHdD1,aLinD1)

Local lRet		:= .T.
Local lIrPcc	:= .F.
Local nI		:= 0
Local nPIRR		:= aScan(aHeader,{|x| AllTrim(x[2]) == "D1_BASEIRR"})
Local nPPIS		:= aScan(aHeader,{|x| AllTrim(x[2]) == "D1_BASEPIS"})
Local nPCOF		:= aScan(aHeader,{|x| AllTrim(x[2]) == "D1_BASECOF"})
Local nPCSL		:= aScan(aHeader,{|x| AllTrim(x[2]) == "D1_BASECSL"})

//Verifica existencia das tabelas do REINF, se tem imposto IR e/ou PCC, se tem natureza de rendimento
//e se fornecedor possuir amarração com algum processo referenciado.
If ChkFile("DHS") .And. ChkFile("DHT") .And. ChkFile("DHR") .And. ChkFile("FKW") .And. nPIRR > 0 .And. nPPIS > 0 .And. nPCOF > 0 .And. nPCSL > 0 .And. ;
	 Len(aColsDHR) > 0 .And. (type("l103Visual") == "L" .and. !l103Visual)
   
	For nI := 1 To Len(aLinD1)
		If aCols[nI,nPIRR] > 0 .Or. aCols[nI,nPPIS] > 0 .Or. aCols[nI,nPCOF] > 0 .Or. aCols[nI,nPCSL] > 0
			lIrPCC := .T.
			Exit
		Endif
	Next nI
	
	If lIrPCC
		DbSelectArea("DHS")
		DHS->(DbSetOrder(1))
		If DHS->(DbSeek(xFilial("DHS") + cA100For + cLoja))
			If MsgYesNo(STR0002)//"Deseja aplicar alguma suspensão DE TRIBUTOS neste documento?"
				lRet := A103TelaSusp(aHdD1,aLinD1,.F.)
			Endif
		Endif
	Endif
Endif

Return lRet 

/*/{Protheus.doc} A103TelaSusp
Tela para informar as suspensões dos impostos IR/PIS/COFINS/CSLL

@param aHdD1	aHeader da SD1 (Itens da NF)
@param aLinD1	aCols da SD1 (Itens da NF)
@param lVisual	T = Visualização / F Inclusão

@author rodrigo.mpontes
@since 30/08/2019
@version P12.1.17
 /*/

Static Function A103TelaSusp(aHdD1,aLinD1,lVisual)

Local lRet		:= .T.
Local nPITE		:= aScan(aHeader,{|x| AllTrim(x[2]) == "D1_ITEM"})
Local nPBIRR	:= aScan(aHeader,{|x| AllTrim(x[2]) == "D1_BASEIRR"})
Local nPVIRR	:= aScan(aHeader,{|x| AllTrim(x[2]) == "D1_VALIRR"})
Local nPBPIS	:= aScan(aHeader,{|x| AllTrim(x[2]) == "D1_BASEPIS"})
Local nPVPIS	:= aScan(aHeader,{|x| AllTrim(x[2]) == "D1_VALPIS"})
Local nPBCOF	:= aScan(aHeader,{|x| AllTrim(x[2]) == "D1_BASECOF"})
Local nPVCOF	:= aScan(aHeader,{|x| AllTrim(x[2]) == "D1_VALCOF"})
Local nPBCSL	:= aScan(aHeader,{|x| AllTrim(x[2]) == "D1_BASECSL"})
Local nPVCSL	:= aScan(aHeader,{|x| AllTrim(x[2]) == "D1_VALCSL"})
Local nPNAT		:= aScan(aHeadDHR,{|x| AllTrim(x[2]) == "DHR_NATREN"})
Local nI		:= 0
Local nPos		:= 0
Local nOpca		:= 0
Local nTamProc	:= TamSx3("DHR_PSIR")[1]
Local nTamTp	:= TamSx3("DHR_TSIR")[1]
Local nTamInd	:= TamSx3("DHR_ISIR")[1]
Local aItemNat	:= {}
Local oSize		:= Nil
Local aAlterDHR	:= {"DHR_PSIR","DHR_TSIR","DHR_ISIR","DHR_PSPIS","DHR_TSPIS","DHR_ISPIS","DHR_PSCOF","DHR_TSCOF","DHR_ISCOF","DHR_PSCSL","DHR_TSCSL","DHR_ISCSL",;
					"DHR_BASUIR","DHR_VLRSIR","DHR_BSUPIS","DHR_VLSPIS","DHR_BSUCOF","DHR_VLSCOF","DHR_BSUCSL","DHR_VLSCSL"}
Local aHdDHR	:= {}

Private oDHRGet	:= Nil

For nI := 1 To Len(aColsDHR)
	nPos := aScan(aLinD1,{|x| x[nPITE] == aColsDHR[nI,1]})
	If nPos > 0 .And. !aLinD1[nPos,Len(aHeader)+1]
		If !Empty(aColsDHR[nI,1]) .And. !Empty(aColsDHR[nI,2])
			If !lVisual
				aAdd(aItemNat,{aColsDHR[nI,1],aColsDHR[nI,2,1,nPNAT],Space(nTamProc),Space(nTamTp),Space(nTamInd),Space(nTamProc),Space(nTamTp),Space(nTamInd),;
								Space(nTamProc),Space(nTamTp),Space(nTamInd),Space(nTamProc),Space(nTamTp),Space(nTamInd),;
								0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,.F.})
			Else
				If aColsDHR[nI,1] == aLinD1[n,nPITE] //Somente item posicionado sera visualizado
					aAdd(aItemNat,{aColsDHR[nI,1],aColsDHR[nI,2,1,nPNAT],Space(nTamProc),Space(nTamTp),Space(nTamInd),Space(nTamProc),Space(nTamTp),Space(nTamInd),;
								Space(nTamProc),Space(nTamTp),Space(nTamInd),Space(nTamProc),Space(nTamTp),Space(nTamInd),;
								0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,.F.})
				Endif
			Endif
		Endif
	Endif
Next nI

If !lVisual
	For nI := 1 To Len(aItemNat)
		nPos := aScan(aLinD1,{|x| x[nPITE] == aItemNat[nI,1]})
		If nPos > 0
			aItemNat[nI,15] := aLinD1[nPos,nPBIRR] //Base IR
			aItemNat[nI,16] := aLinD1[nPos,nPVIRR] //Valor IR
			aItemNat[nI,19] := aLinD1[nPos,nPBIRR] //Base NF IR
			aItemNat[nI,20] := aLinD1[nPos,nPVIRR] //Valor NF IR
			
			aItemNat[nI,21] := aLinD1[nPos,nPBPIS] //Base PIS
			aItemNat[nI,22] := aLinD1[nPos,nPVPIS] //Valor PIS
			aItemNat[nI,25] := aLinD1[nPos,nPBPIS] //Base NF PIS
			aItemNat[nI,26] := aLinD1[nPos,nPVPIS] //Valor NF PIS
			
			aItemNat[nI,27] := aLinD1[nPos,nPBCOF] //Base COF
			aItemNat[nI,28] := aLinD1[nPos,nPVCOF] //Valor COF
			aItemNat[nI,31] := aLinD1[nPos,nPBCOF] //Base NF COF
			aItemNat[nI,32] := aLinD1[nPos,nPVCOF] //Valor NF COF
			
			aItemNat[nI,33] := aLinD1[nPos,nPBCSL] //Base CSL
			aItemNat[nI,34] := aLinD1[nPos,nPVCSL] //Valor CSL
			aItemNat[nI,37] := aLinD1[nPos,nPBCSL] //Base NF CSL
			aItemNat[nI,38] := aLinD1[nPos,nPVCSL] //Valor NF CSL
		Endif
	Next nI
Else
	aHdDHR := COMXHDCO("DHR")
	DbSelectArea("DHR")
	DHR->(DbSetOrder(1))
	If DHR->(MsSeek(xFilial("DHR") + cNFiscal + cSerie + ca100For + cLoja + aLinD1[n,nPITE]))
		For nI := 3 To Len(aHdDHR)
			aItemNat[Len(aItemNat)][nI] := DHR->(FieldGet(FieldPos(aHdDHR[nI][2])))
		Next nI
	Endif
Endif

oSize := FwDefSize():New()
oSize:AddObject( "DHR" ,  100, 100, .T., .T. )	// Totalmente dimensionavel
oSize:lProp 	:= .T.							// Proporcional
oSize:aMargins 	:= { 3, 3, 3, 3 }				// Espaco ao lado dos objetos 0, entre eles 3
oSize:Process()									// Dispara os calculos

DEFINE MSDIALOG oDlgSusp TITLE "Suspensão - REINF" FROM oSize:aWindSize[1],oSize:aWindSize[2] TO oSize:aWindSize[3],oSize:aWindSize[4] PIXEL

oDHRGet := MsNewGetDados():New(	oSize:GetDimension("DHR","LININI"),oSize:GetDimension("DHR","COLINI"),oSize:GetDimension("DHR","LINEND"),;
								oSize:GetDimension("DHR","COLEND"),Iif(lVisual,0,GD_UPDATE+GD_INSERT+GD_DELETE),"AllwaysTrue","AllwaysTrue",/*cIniCpos*/,aAlterDHR,,Len(aItemNat),;
								"A103CALCSUS","","AllwaysTrue", oDlgSusp, aHdSusDHR, aItemNat)

ACTIVATE MSDIALOG oDlgSusp CENTERED ON INIT EnchoiceBar(oDlgSusp,{|| Iif(A103TOKDHR(lVisual),(nOpca := 1,oDlgSusp:End()),.F.)},{||(nOpca := 0,oDlgSusp:End())},,)

If !lVisual
	If nOpca == 1
		For nI := 1 To Len(oDHRGet:aCols)
			nPos:= aScan(aCoSusDHR,{|x| x[1] == oDHRGet:aCols[nI,1]})
			If nPos > 0
				aCoSusDHR[nPos][2] := aClone(oDHRGet:aCols)
			Else
				aAdd(aCoSusDHR,{oDHRGet:aCols[nI,1],aClone(oDHRGet:aCols)})
			Endif
		Next nI
		MaFisToCols(aHeader,aCols,,"MT100")
		Eval(bRefresh,5)
		Eval(bRefresh,6)
		Eval(bGdRefresh)
	Else
		aCols := aClone(aLinD1)
		MaColsToFis(aHeader,aCols,,"MT100")
		For nI := 1 To Len(aCols)
			n := nI
			NfeDelItem()
		Next nI
		n := 1
		Eval(bRefresh,5)
		Eval(bRefresh,6)
		Eval(bGdRefresh)
		lRet := .F.
	Endif
Endif

Return lRet

/*/{Protheus.doc} A103TOKDHR
Tudo OK - DHR

@author rodrigo.mpontes
@since 30/08/2019
@version P12.1.17
 /*/

Function A103TOKDHR(lVisual)

Local lRet		:= .T.

Local nPSIR		:= aScan(oDHRGet:aHeader,{|x| AllTrim(x[2]) == "DHR_PSIR"})
Local nTSIR		:= aScan(oDHRGet:aHeader,{|x| AllTrim(x[2]) == "DHR_TSIR"})
Local nISIR		:= aScan(oDHRGet:aHeader,{|x| AllTrim(x[2]) == "DHR_ISIR"})
Local nBASUIR	:= aScan(oDHRGet:aHeader,{|x| AllTrim(x[2]) == "DHR_BASUIR"})
Local nVLRSIR	:= aScan(oDHRGet:aHeader,{|x| AllTrim(x[2]) == "DHR_VLRSIR"})
Local nPSPIS	:= aScan(oDHRGet:aHeader,{|x| AllTrim(x[2]) == "DHR_PSPIS"})
Local nTSPIS	:= aScan(oDHRGet:aHeader,{|x| AllTrim(x[2]) == "DHR_TSPIS"})
Local nISPIS	:= aScan(oDHRGet:aHeader,{|x| AllTrim(x[2]) == "DHR_ISPIS"})
Local nBSUPIS	:= aScan(oDHRGet:aHeader,{|x| AllTrim(x[2]) == "DHR_BSUPIS"})
Local nVLSPIS	:= aScan(oDHRGet:aHeader,{|x| AllTrim(x[2]) == "DHR_VLSPIS"})
Local nPSCOF	:= aScan(oDHRGet:aHeader,{|x| AllTrim(x[2]) == "DHR_PSCOF"})
Local nTSCOF	:= aScan(oDHRGet:aHeader,{|x| AllTrim(x[2]) == "DHR_TSCOF"})
Local nISCOF	:= aScan(oDHRGet:aHeader,{|x| AllTrim(x[2]) == "DHR_ISCOF"})
Local nBSUCOF	:= aScan(oDHRGet:aHeader,{|x| AllTrim(x[2]) == "DHR_BSUCOF"})
Local nVLSCOF	:= aScan(oDHRGet:aHeader,{|x| AllTrim(x[2]) == "DHR_VLSCOF"})
Local nPSCSL	:= aScan(oDHRGet:aHeader,{|x| AllTrim(x[2]) == "DHR_PSCSL"})
Local nTSCSL	:= aScan(oDHRGet:aHeader,{|x| AllTrim(x[2]) == "DHR_TSCSL"})
Local nISCSL	:= aScan(oDHRGet:aHeader,{|x| AllTrim(x[2]) == "DHR_ISCSL"})
Local nBSUCSL	:= aScan(oDHRGet:aHeader,{|x| AllTrim(x[2]) == "DHR_BSUCSL"})
Local nVLSCSL	:= aScan(oDHRGet:aHeader,{|x| AllTrim(x[2]) == "DHR_VLSCSL"})
Local nI		:= 0
Local nX		:= 0
Local aVldPro	:= {{nPSIR ,nTSIR ,nISIR ,"DHR_PSIR"},;
					{nPSPIS,nTSPIS,nISPIS,"DHR_PSPIS"},;
					{nPSCOF,nTSCOF,nISCOF,"DHR_PSCOF"},;
					{nPSCSL,nTSCSL,nISCSL,"DHR_PSCSL"}}

If !lVisual	
	For nI := 1 To Len(oDHRGet:aCols)
		If !oDHRGet:aCols[nI,Len(oDHRGet:aHeader)+1]
			//Validação processos (CCF)
			For nX := 1 To Len(aVldPro)
				If !Empty(oDHRGet:aCols[nI,aVldPro[nX,1]]) .And. !Empty(oDHRGet:aCols[nI,aVldPro[nX,2]])
					lRet := A103VLDPRO(oDHRGet:aCols[nI,aVldPro[nX,1]],oDHRGet:aCols[nI,aVldPro[nX,2]],oDHRGet:aCols[nI,aVldPro[nX,3]],ca100For,cLoja,aVldPro[nX,4])
					If !lRet
						Exit
					Endif
				Endif
			Next nX


			If lRet .And. (!Empty(oDHRGet:aCols[nI,nPSIR]) .And. oDHRGet:aCols[nI,nBASUIR] == 0 .And. oDHRGet:aCols[nI,nVLRSIR] == 0) .Or. ; //IRRF
				(!Empty(oDHRGet:aCols[nI,nPSPIS]) .And. oDHRGet:aCols[nI,nBSUPIS] == 0 .And. oDHRGet:aCols[nI,nVLSPIS] == 0) .Or. ; //PIS
				(!Empty(oDHRGet:aCols[nI,nPSCOF]) .And. oDHRGet:aCols[nI,nBSUCOF] == 0 .And. oDHRGet:aCols[nI,nVLSCOF] == 0) .Or. ; //COFINS
				(!Empty(oDHRGet:aCols[nI,nPSCSL]) .And. oDHRGet:aCols[nI,nBSUCSL] == 0 .And. oDHRGet:aCols[nI,nVLSCSL] == 0) //CSLL
				lRet := .F.
				Help( ,, 'A103SUSPENSAO',,STR0003 + " (IRRF/PIS/COFINS/CSLL)",1,0) //"Processo informado, mas sem base/valor de suspensão" 
			Endif
		Endif
		
		If !lRet
			Exit
		Endif
	Next nI
Endif

Return lRet

/*/{Protheus.doc} A103CALCSUS
Calculo da suspensão dos impostos IR/PIS/COFINS/CSLL

@author rodrigo.mpontes
@since 30/08/2019
@version P12.1.17
 /*/

Function A103CALCSUS()

Local lRet		:= .T.
Local cCpo		:= StrTran(AllTrim(ReadVar()),"M->","")
Local cPrTpInd	:= ""
Local nPos		:= 0
Local nBaseVlr	:= 0
Local nI		:= 0
Local nPItNat	:= aScan(oDHRGet:aHeader,{|x| AllTrim(x[2]) == "DHR_ITEM"})
Local nPSIR		:= aScan(oDHRGet:aHeader,{|x| AllTrim(x[2]) == "DHR_PSIR"})
Local nTSIR		:= aScan(oDHRGet:aHeader,{|x| AllTrim(x[2]) == "DHR_TSIR"})
Local nISIR		:= aScan(oDHRGet:aHeader,{|x| AllTrim(x[2]) == "DHR_ISIR"})
Local nPSPIS	:= aScan(oDHRGet:aHeader,{|x| AllTrim(x[2]) == "DHR_PSPIS"})
Local nTSPIS	:= aScan(oDHRGet:aHeader,{|x| AllTrim(x[2]) == "DHR_TSPIS"})
Local nISPIS	:= aScan(oDHRGet:aHeader,{|x| AllTrim(x[2]) == "DHR_ISPIS"})
Local nPSCOF	:= aScan(oDHRGet:aHeader,{|x| AllTrim(x[2]) == "DHR_PSCOF"})
Local nTSCOF	:= aScan(oDHRGet:aHeader,{|x| AllTrim(x[2]) == "DHR_TSCOF"})
Local nISCOF	:= aScan(oDHRGet:aHeader,{|x| AllTrim(x[2]) == "DHR_ISCOF"})
Local nPSCSL	:= aScan(oDHRGet:aHeader,{|x| AllTrim(x[2]) == "DHR_PSCSL"})
Local nTSCSL	:= aScan(oDHRGet:aHeader,{|x| AllTrim(x[2]) == "DHR_TSCSL"})
Local nISCSL	:= aScan(oDHRGet:aHeader,{|x| AllTrim(x[2]) == "DHR_ISCSL"})
Local nBASEIR	:= aScan(oDHRGet:aHeader,{|x| AllTrim(x[2]) == "DHR_BASEIR"})
Local nVLRIR	:= aScan(oDHRGet:aHeader,{|x| AllTrim(x[2]) == "DHR_VLRIR"})
Local nBASUIR	:= aScan(oDHRGet:aHeader,{|x| AllTrim(x[2]) == "DHR_BASUIR"})
Local nVLRSIR	:= aScan(oDHRGet:aHeader,{|x| AllTrim(x[2]) == "DHR_VLRSIR"})
Local nBANFIR	:= aScan(oDHRGet:aHeader,{|x| AllTrim(x[2]) == "DHR_BANFIR"})
Local nVLNFIR	:= aScan(oDHRGet:aHeader,{|x| AllTrim(x[2]) == "DHR_VLNFIR"})
Local nBASPIS	:= aScan(oDHRGet:aHeader,{|x| AllTrim(x[2]) == "DHR_BASPIS"})
Local nVLRPIS	:= aScan(oDHRGet:aHeader,{|x| AllTrim(x[2]) == "DHR_VLRPIS"})
Local nBSUPIS	:= aScan(oDHRGet:aHeader,{|x| AllTrim(x[2]) == "DHR_BSUPIS"})
Local nVLSPIS	:= aScan(oDHRGet:aHeader,{|x| AllTrim(x[2]) == "DHR_VLSPIS"})
Local nBNFPIS	:= aScan(oDHRGet:aHeader,{|x| AllTrim(x[2]) == "DHR_BNFPIS"})
Local nVNFPIS	:= aScan(oDHRGet:aHeader,{|x| AllTrim(x[2]) == "DHR_VNFPIS"})
Local nBASCOF	:= aScan(oDHRGet:aHeader,{|x| AllTrim(x[2]) == "DHR_BASCOF"})
Local nVLRCOF	:= aScan(oDHRGet:aHeader,{|x| AllTrim(x[2]) == "DHR_VLRCOF"})
Local nBSUCOF	:= aScan(oDHRGet:aHeader,{|x| AllTrim(x[2]) == "DHR_BSUCOF"})
Local nVLSCOF	:= aScan(oDHRGet:aHeader,{|x| AllTrim(x[2]) == "DHR_VLSCOF"})
Local nBNFCOF	:= aScan(oDHRGet:aHeader,{|x| AllTrim(x[2]) == "DHR_BNFCOF"})
Local nVNFCOF	:= aScan(oDHRGet:aHeader,{|x| AllTrim(x[2]) == "DHR_VNFCOF"})
Local nBASCSL	:= aScan(oDHRGet:aHeader,{|x| AllTrim(x[2]) == "DHR_BASCSL"})
Local nVLRCSL	:= aScan(oDHRGet:aHeader,{|x| AllTrim(x[2]) == "DHR_VLRCSL"})
Local nBSUCSL	:= aScan(oDHRGet:aHeader,{|x| AllTrim(x[2]) == "DHR_BSUCSL"})
Local nVLSCSL	:= aScan(oDHRGet:aHeader,{|x| AllTrim(x[2]) == "DHR_VLSCSL"})
Local nBNFCSL	:= aScan(oDHRGet:aHeader,{|x| AllTrim(x[2]) == "DHR_BNFCSL"})
Local nVNFCSL	:= aScan(oDHRGet:aHeader,{|x| AllTrim(x[2]) == "DHR_VNFCSL"})
Local nNatRenIT	:= Val(oDHRGet:aCols[oDHRGet:nAt,nPItNat]) //Para correto calculo na MATXFIS
Local aVldPro	:= {{"DHR_PSIR",0    ,nTSIR,nISIR},{"DHR_PSPIS",0     ,nTSPIS,nISPIS},{"DHR_PSCOF",0     ,nTSCOF,nISCOF},{"DHR_PSCSL",0     ,nTSCSL,nISCSL},;
					{"DHR_TSIR",nPSIR,0    ,nISIR},{"DHR_TSPIS",nPSPIS,0     ,nISPIS},{"DHR_TSCOF",nPSCOF,0     ,nISCOF},{"DHR_TSCSL",nPSCSL,0     ,nISCSL},;
					{"DHR_ISIR",nPSIR,nTSIR,0    },{"DHR_ISPIS",nPSPIS,nTSPIS,0     },{"DHR_ISCOF",nPSCOF,nTSCOF,0     },{"DHR_ISCSL",nPSCSL,nTSCSL,0     }}

//Validação Processo referenciado IRRF
If cCpo == "DHR_PSIR" .Or. cCpo == "DHR_TSIR" .Or. cCpo == "DHR_ISIR" .Or. ; //IRRF
   cCpo == "DHR_PSPIS" .Or. cCpo == "DHR_TSPIS" .Or. cCpo == "DHR_ISPIS" .Or. ; //PIS
   cCpo == "DHR_PSCOF" .Or. cCpo == "DHR_TSCOF" .Or. cCpo == "DHR_ISCOF" .Or. ; //COF
   cCpo == "DHR_PSCSL" .Or. cCpo == "DHR_TSCSL" .Or. cCpo == "DHR_ISCSL" //CSLL
    
	cPrTpInd := &cCpo

	For nI := 1 To Len(aVldPro) //IRRF/PIS/COFINS/CSLL
		If cCpo == aVldPro[nI,1] .And. SubStr(cCpo,5,1) == "P" //Processo
			If !Empty(cPrTpInd) .And. !Empty(oDHRGet:aCols[oDHRGet:nAt,aVldPro[nI,3]])
				lRet := A103VLDPRO(cPrTpInd,oDHRGet:aCols[oDHRGet:nAt,aVldPro[nI,3]],oDHRGet:aCols[oDHRGet:nAt,aVldPro[nI,4]],ca100For,cLoja,cCpo)
			Endif
		ElseIf cCpo == aVldPro[nI,1] .And. SubStr(cCpo,5,1) == "T" //Tipo Processo
			If !Empty(oDHRGet:aCols[oDHRGet:nAt,aVldPro[nI,2]]) .And. !Empty(cPrTpInd)
				lRet := A103VLDPRO(oDHRGet:aCols[oDHRGet:nAt,aVldPro[nI,2]],cPrTpInd,oDHRGet:aCols[oDHRGet:nAt,aVldPro[nI,4]],ca100For,cLoja,cCpo)
			Endif
		ElseIf cCpo == aVldPro[nI,1] .And. SubStr(cCpo,5,1) == "I" //IndSus
			If !Empty(oDHRGet:aCols[oDHRGet:nAt,aVldPro[nI,2]]) .And. !Empty(oDHRGet:aCols[oDHRGet:nAt,aVldPro[nI,3]])
				lRet := A103VLDPRO(oDHRGet:aCols[oDHRGet:nAt,aVldPro[nI,2]],oDHRGet:aCols[oDHRGet:nAt,aVldPro[nI,3]],cPrTpInd,ca100For,cLoja,cCpo)
			Endif
		Endif

		If !lRet
			Exit
		Endif
	Next nI	
Endif

//Preenchimento da Base ou Valor de suspensão do IRRF
If lRet .And. cCpo == "DHR_BASUIR" .Or. cCpo == "DHR_VLRSIR"
	nBaseVlr := &cCpo
	If nPSIR > 0 .And. nBaseVlr > 0
		If Empty(oDHRGet:aCols[oDHRGet:nAt,nPSIR]) //Processo IR em branco
			Help(" ",1,'A103SUSPENSAO',,STR0006,1,0) //"Não é possivel informar uma suspensão, sem informar o processo referente ao imposto"
			lRet := .F.
		Endif
	Endif
	
	If lRet
		If cCpo == "DHR_BASUIR" .And. nBaseVlr > 0
			If nBaseVlr > oDHRGet:aCols[oDHRGet:nAt,nBASEIR]
				Help(" ",1,'A103SUSPENSAO',,STR0007,1,0) //"Valor da base suspensa é maior que a base do imposto."
				lRet := .F.
			Else
				MaFisAlt("IT_BASEIRR",nBaseVlr,nNatRenIT)
				
				oDHRGet:aCols[oDHRGet:nAt,nBASUIR] := MaFisRet(nNatRenIT,"IT_BASEIRR")	//Base Suspensa
				oDHRGet:aCols[oDHRGet:nAt,nVLRSIR] := MaFisRet(nNatRenIT,"IT_VALIRR")		//Valor Suspenso
				
				oDHRGet:aCols[oDHRGet:nAt,nBANFIR] := oDHRGet:aCols[oDHRGet:nAt,nBASEIR] - MaFisRet(nNatRenIT,"IT_BASEIRR") 	//Base IR NF
				oDHRGet:aCols[oDHRGet:nAt,nVLNFIR] := oDHRGet:aCols[oDHRGet:nAt,nVLRIR] - MaFisRet(nNatRenIT,"IT_VALIRR")		//Valor IR NF
				
				MaFisAlt("IT_BASEIRR",oDHRGet:aCols[oDHRGet:nAt,nBANFIR],nNatRenIT)
			Endif
			
		Elseif cCpo == "DHR_VLRSIR" .And. nBaseVlr > 0
			If nBaseVlr > oDHRGet:aCols[oDHRGet:nAt,nVLRIR]
				Help(" ",1,'A103SUSPENSAO',,STR0008,1,0) //"Valor da suspensão é maior que valor do imposto."
				lRet := .F.
			Else
				If nBaseVlr == oDHRGet:aCols[oDHRGet:nAt,nVLRIR]
					oDHRGet:aCols[oDHRGet:nAt,nBASUIR] := oDHRGet:aCols[oDHRGet:nAt,nBASEIR]	//Base Suspensa
				Else
					oDHRGet:aCols[oDHRGet:nAt,nBASUIR] := 0	//Base Suspensa
				Endif
				oDHRGet:aCols[oDHRGet:nAt,nVLRSIR] := nBaseVlr								//Valor Suspenso
				
				oDHRGet:aCols[oDHRGet:nAt,nBANFIR] := oDHRGet:aCols[oDHRGet:nAt,nBASEIR]		//Base IR NF
				oDHRGet:aCols[oDHRGet:nAt,nVLNFIR] := oDHRGet:aCols[oDHRGet:nAt,nVLRIR] - oDHRGet:aCols[oDHRGet:nAt,nVLRSIR]		//Valor IR NF
				
				MaFisAlt("IT_BASEIRR",oDHRGet:aCols[oDHRGet:nAt,nBANFIR],nNatRenIT)
				MaFisAlt("IT_VALIRR",oDHRGet:aCols[oDHRGet:nAt,nVLNFIR],nNatRenIT)
			Endif
		Elseif nBaseVlr == 0
			oDHRGet:aCols[oDHRGet:nAt,nBANFIR] := oDHRGet:aCols[oDHRGet:nAt,nBASEIR]
			oDHRGet:aCols[oDHRGet:nAt,nVLNFIR] := oDHRGet:aCols[oDHRGet:nAt,nVLRIR]
			
			oDHRGet:aCols[oDHRGet:nAt,nBASUIR] := 0
			oDHRGet:aCols[oDHRGet:nAt,nVLRSIR] := 0
		Endif
	Endif
Endif

//Preenchimento da Base ou Valor de suspensão do PIS
If lRet .And. cCpo == "DHR_BSUPIS" .Or. cCpo == "DHR_VLSPIS"
	nBaseVlr := &cCpo
	If nPSPIS > 0 .And. nBaseVlr > 0
		If Empty(oDHRGet:aCols[oDHRGet:nAt,nPSPIS]) //Processo PIS em branco
			Help(" ",1,'A103SUSPENSAO',,STR0006,1,0) //"Não é possivel informar uma suspensão, sem informar o processo referente ao imposto"
			lRet := .F.
		Endif
	Endif
	
	If lRet
		If cCpo == "DHR_BSUPIS" .And. nBaseVlr > 0
			If nBaseVlr > oDHRGet:aCols[oDHRGet:nAt,nBASPIS]
				Help(" ",1,'A103SUSPENSAO',,STR0007,1,0) //"Valor da base suspensa é maior que a base do imposto."
				lRet := .F.
			Else
				MaFisAlt("IT_BASEPIS",nBaseVlr,nNatRenIT)
				
				oDHRGet:aCols[oDHRGet:nAt,nBSUPIS] := MaFisRet(nNatRenIT,"IT_BASEPIS")	//Base Suspensa
				oDHRGet:aCols[oDHRGet:nAt,nVLSPIS] := MaFisRet(nNatRenIT,"IT_VALPIS")		//Valor Suspenso
				
				oDHRGet:aCols[oDHRGet:nAt,nBNFPIS] := oDHRGet:aCols[oDHRGet:nAt,nBASPIS] - MaFisRet(nNatRenIT,"IT_BASEPIS") 	//Base PIS NF
				oDHRGet:aCols[oDHRGet:nAt,nVNFPIS] := oDHRGet:aCols[oDHRGet:nAt,nVLRPIS] - MaFisRet(nNatRenIT,"IT_VALPIS")		//Valor PIS NF
				
				MaFisAlt("IT_BASEPIS",oDHRGet:aCols[oDHRGet:nAt,nBNFPIS],nNatRenIT)
			Endif
		Elseif cCpo == "DHR_VLSPIS" .And. nBaseVlr > 0
			If nBaseVlr > oDHRGet:aCols[oDHRGet:nAt,nVLRPIS]
				Help(" ",1,'A103SUSPENSAO',,STR0008,1,0) //"Valor da suspensão é maior que valor do imposto."
				lRet := .F.
			Else
				If nBaseVlr == oDHRGet:aCols[oDHRGet:nAt,nVLRPIS]
					oDHRGet:aCols[oDHRGet:nAt,nBSUPIS] := oDHRGet:aCols[oDHRGet:nAt,nBASPIS]	//Base Suspensa
				Else
					oDHRGet:aCols[oDHRGet:nAt,nBSUPIS] := 0	//Base Suspensa
				Endif
				oDHRGet:aCols[oDHRGet:nAt,nVLSPIS] := nBaseVlr								//Valor Suspenso
				
				oDHRGet:aCols[oDHRGet:nAt,nBNFPIS] := oDHRGet:aCols[oDHRGet:nAt,nBASPIS]		//Base PIS NF
				oDHRGet:aCols[oDHRGet:nAt,nVNFPIS] := oDHRGet:aCols[oDHRGet:nAt,nVLRPIS] - oDHRGet:aCols[oDHRGet:nAt,nVLSPIS]		//Valor PIS NF
				
				MaFisAlt("IT_BASEPIS",oDHRGet:aCols[oDHRGet:nAt,nBNFPIS],nNatRenIT)
				MaFisAlt("IT_VALPIS",oDHRGet:aCols[oDHRGet:nAt,nVNFPIS],nNatRenIT)
			Endif
		Elseif nBaseVlr == 0
			oDHRGet:aCols[oDHRGet:nAt,nBNFPIS] := oDHRGet:aCols[oDHRGet:nAt,nBASPIS]
			oDHRGet:aCols[oDHRGet:nAt,nVNFPIS] := oDHRGet:aCols[oDHRGet:nAt,nVLRPIS]
			
			oDHRGet:aCols[oDHRGet:nAt,nBSUPIS] := 0
			oDHRGet:aCols[oDHRGet:nAt,nVLSPIS] := 0
		Endif
	Endif
Endif

//Preenchimento da Base ou Valor de suspensão do COFINS
If lRet .And. cCpo == "DHR_BSUCOF" .Or. cCpo == "DHR_VLSCOF"
	nBaseVlr := &cCpo
	If nPSCOF > 0 .And. nBaseVlr > 0
		If Empty(oDHRGet:aCols[oDHRGet:nAt,nPSCOF]) //Processo COFINS em branco
			Help(" ",1,'A103SUSPENSAO',,STR0006,1,0) //"Não é possivel informar uma suspensão, sem informar o processo referente ao imposto"
			lRet := .F.
		Endif
	Endif
	
	If lRet
		If cCpo == "DHR_BSUCOF" .And. nBaseVlr > 0
			If nBaseVlr > oDHRGet:aCols[oDHRGet:nAt,nBASCOF]
				Help(" ",1,'A103SUSPENSAO',,STR0007,1,0) //"Valor da base suspensa é maior que a base do imposto."
				lRet := .F.
			Else
				MaFisAlt("IT_BASECOF",nBaseVlr,nNatRenIT)
				
				oDHRGet:aCols[oDHRGet:nAt,nBSUCOF] := MaFisRet(nNatRenIT,"IT_BASECOF")	//Base Suspensa
				oDHRGet:aCols[oDHRGet:nAt,nVLSCOF] := MaFisRet(nNatRenIT,"IT_VALCOF")		//Valor Suspenso
				
				oDHRGet:aCols[oDHRGet:nAt,nBNFCOF] := oDHRGet:aCols[oDHRGet:nAt,nBASCOF] - MaFisRet(nNatRenIT,"IT_BASECOF") 	//Base COF NF
				oDHRGet:aCols[oDHRGet:nAt,nVNFCOF] := oDHRGet:aCols[oDHRGet:nAt,nVLRCOF] - MaFisRet(nNatRenIT,"IT_VALCOF")	//Valor COF NF
				
				MaFisAlt("IT_BASECOF",oDHRGet:aCols[oDHRGet:nAt,nBNFCOF],nNatRenIT)
			Endif
		Elseif cCpo == "DHR_VLSCOF" .And. nBaseVlr > 0
			If nBaseVlr > oDHRGet:aCols[oDHRGet:nAt,nVLRCOF]
				Help(" ",1,'A103SUSPENSAO',,STR0008,1,0) //"Valor da suspensão é maior que valor do imposto."
				lRet := .F.
			Else
				If nBaseVlr == oDHRGet:aCols[oDHRGet:nAt,nVLRCOF]
					oDHRGet:aCols[oDHRGet:nAt,nBSUCOF] := oDHRGet:aCols[oDHRGet:nAt,nBASCOF]	//Base Suspensa
				Else
					oDHRGet:aCols[oDHRGet:nAt,nBSUCOF] := 0	//Base Suspensa
				Endif
				oDHRGet:aCols[oDHRGet:nAt,nVLSCOF] := nBaseVlr								//Valor Suspenso
				
				oDHRGet:aCols[oDHRGet:nAt,nBNFCOF] := oDHRGet:aCols[oDHRGet:nAt,nBASCOF]		//Base COF NF
				oDHRGet:aCols[oDHRGet:nAt,nVNFCOF] := oDHRGet:aCols[oDHRGet:nAt,nVLRCOF] - oDHRGet:aCols[oDHRGet:nAt,nVLSCOF]		//Valor COF NF
				
				MaFisAlt("IT_BASECOF",oDHRGet:aCols[oDHRGet:nAt,nBNFCOF],nNatRenIT)
				MaFisAlt("IT_VALCOF",oDHRGet:aCols[oDHRGet:nAt,nVNFCOF],nNatRenIT)
			Endif
		Elseif nBaseVlr == 0
			oDHRGet:aCols[oDHRGet:nAt,nBNFCOF] := oDHRGet:aCols[oDHRGet:nAt,nBASCOF]
			oDHRGet:aCols[oDHRGet:nAt,nVNFCOF] := oDHRGet:aCols[oDHRGet:nAt,nVLRCOF]
			
			oDHRGet:aCols[oDHRGet:nAt,nBSUCOF] := 0
			oDHRGet:aCols[oDHRGet:nAt,nVLSCOF] := 0
		Endif
	Endif
Endif

//Preenchimento da Base ou Valor de suspensão do CSLL
If lRet .And. cCpo == "DHR_BSUCSL" .Or. cCpo == "DHR_VLSCSL"
	nBaseVlr := &cCpo
	If nPSCSL > 0 .And. nBaseVlr > 0
		If Empty(oDHRGet:aCols[oDHRGet:nAt,nPSCSL]) //Processo COFINS em branco
			Help(" ",1,'A103SUSPENSAO',,STR0006,1,0) //"Não é possivel informar uma suspensão, sem informar o processo referente ao imposto"
			lRet := .F.
		Endif
	Endif
	
	If lRet
		If cCpo == "DHR_BSUCSL" .And. nBaseVlr > 0
			If nBaseVlr > oDHRGet:aCols[oDHRGet:nAt,nBASCSL]
				Help(" ",1,'A103SUSPENSAO',,STR0007,1,0) //"Valor da base suspensa é maior que a base do imposto."
				lRet := .F.
			Else
				MaFisAlt("IT_BASECSL",nBaseVlr,nNatRenIT)
				
				oDHRGet:aCols[oDHRGet:nAt,nBSUCSL] := MaFisRet(nNatRenIT,"IT_BASECSL")	//Base Suspensa
				oDHRGet:aCols[oDHRGet:nAt,nVLSCSL] := MaFisRet(nNatRenIT,"IT_VALCSL")		//Valor Suspenso
				
				oDHRGet:aCols[oDHRGet:nAt,nBNFCSL] := oDHRGet:aCols[oDHRGet:nAt,nBASCSL] - MaFisRet(nNatRenIT,"IT_BASECSL") 	//Base CSL NF
				oDHRGet:aCols[oDHRGet:nAt,nVNFCSL] := oDHRGet:aCols[oDHRGet:nAt,nVLRCSL] - MaFisRet(nNatRenIT,"IT_VALCSL")	//Valor CSL NF
				
				MaFisAlt("IT_BASECSL",oDHRGet:aCols[oDHRGet:nAt,nBNFCSL],nNatRenIT)
			Endif
		Elseif cCpo == "DHR_VLSCSL" .And. nBaseVlr > 0
			If nBaseVlr > oDHRGet:aCols[oDHRGet:nAt,nVLRCSL]
				Help(" ",1,'A103SUSPENSAO',,STR0008,1,0) //"Valor da suspensão é maior que valor do imposto."
				lRet := .F.
			Else
				If nBaseVlr == oDHRGet:aCols[oDHRGet:nAt,nVLRCSL]
					oDHRGet:aCols[oDHRGet:nAt,nBSUCSL] := oDHRGet:aCols[oDHRGet:nAt,nBASCSL]	//Base Suspensa
				Else
					oDHRGet:aCols[oDHRGet:nAt,nBSUCSL] := 0	//Base Suspensa
				Endif
				oDHRGet:aCols[oDHRGet:nAt,nVLSCSL] := nBaseVlr								//Valor Suspenso
				
				oDHRGet:aCols[oDHRGet:nAt,nBNFCSL] := oDHRGet:aCols[oDHRGet:nAt,nBASCSL]		//Base CSL NF
				oDHRGet:aCols[oDHRGet:nAt,nVNFCSL] := oDHRGet:aCols[oDHRGet:nAt,nVLRCSL] - oDHRGet:aCols[oDHRGet:nAt,nVLSCSL]		//Valor CSL NF
				
				MaFisAlt("IT_BASECSL",oDHRGet:aCols[oDHRGet:nAt,nBNFCSL],nNatRenIT)
				MaFisAlt("IT_VALCSL",oDHRGet:aCols[oDHRGet:nAt,nVNFCSL],nNatRenIT)
			Endif
		Elseif nBaseVlr == 0
			oDHRGet:aCols[oDHRGet:nAt,nBNFCSL] := oDHRGet:aCols[oDHRGet:nAt,nBASCSL]
			oDHRGet:aCols[oDHRGet:nAt,nVNFCSL] := oDHRGet:aCols[oDHRGet:nAt,nVLRCSL]
			
			oDHRGet:aCols[oDHRGet:nAt,nBSUCSL] := 0
			oDHRGet:aCols[oDHRGet:nAt,nVLSCSL] := 0
		Endif
	Endif
Endif

If lRet
	oDHRGet:Refresh()
Endif

Return lRet

/*/{Protheus.doc} A103VLDPRO
validação da existencia do processo referenciado

@param cProcesso	Numero do processo
@param cTipo		Tipo do processo
@param cIndSusp		Codigo indicativo da suspensão
@param cForn		Fornecedor
@param cLoj			Loja
@param cCpo			Campo selecionado

@author rodrigo.mpontes
@since 30/08/2019
@version P12.1.17
 /*/

Static Function A103VLDPRO(cProcesso,cTipo,cIndSusp,cForn,cLoj,cCpo)

Local lRet 		:= .F.
Local cQry 		:= ""
Local cFiltro	:= ""
Local cAliasTmp	:= GetNextAlias()
Local cImpTxt	:= ""

If cCpo == "DHR_PSIR" .Or. cCpo == "DHR_TSIR" .Or. cCpo == "DHR_ISIR" //IRRF
	cFiltro := "9"
	cImpTxt := "IRRF"
Elseif cCpo == "DHR_PSPIS" .Or. cCpo == "DHR_TSPIS" .Or. cCpo == "DHR_ISPIS" //PIS
	cFiltro := "7"
	cImpTxt := "PIS"
Elseif cCpo == "DHR_PSCOF" .Or. cCpo == "DHR_TSCOF" .Or. cCpo == "DHR_ISCOF" //COF
	cFiltro := "8"
	cImpTxt := "COFINS"
Elseif cCpo == "DHR_PSCSL" .Or. cCpo == "DHR_TSCSL" .Or. cCpo == "DHR_ISCSL" //CSLL
	cFiltro := "A"
	cImpTxt := "CSLL"
Endif

cQry := " SELECT R_E_C_N_O_ AS RECNO"
cQry += " FROM " + RetSqlName("CCF")
cQry += " WHERE D_E_L_E_T_ = ''"
cQry += " AND CCF_FILIAL = '" + xFilial("CCF") + "'" 
cQry += " AND CCF_NUMERO = '" + cProcesso + "'"   
cQry += " AND CCF_TIPO = '" + cTipo + "'"
cQry += " AND CCF_INDSUS = '" + cIndSusp + "'"
cQry += " AND CCF_TRIB = '" + cFiltro + "'"
cQry := ChangeQuery(cQry)  

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),cAliasTmp,.T.,.T.)

DbSelectArea(cAliasTmp)
If (cAliasTmp)->(!EOF())
	lRet := .T.
Endif

(cAliasTmp)->(DbCloseArea())

//Valida se processo esta vinculado ao fornecedor
If lRet
	lRet		:= .F.
	cAliasTmp	:= GetNextAlias()

	cQry := " SELECT R_E_C_N_O_ AS RECNO"
	cQry += " FROM " + RetSqlName("DHS")
	cQry += " WHERE D_E_L_E_T_ = ''"
	cQry += " AND DHS_FILIAL = '" + xFilial("DHS") + "'"
	cQry += " AND DHS_FORN = '" + cForn + "'"   
	cQry += " AND DHS_LOJA = '" + cLoj + "'"   
	cQry += " AND DHS_NUMERO = '" + cProcesso + "'"   
	cQry += " AND DHS_TIPO = '" + cTipo + "'"
	cQry += " AND DHS_INDSUS = '" + cIndSusp + "'"
	cQry := ChangeQuery(cQry)

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),cAliasTmp,.T.,.T.)

	DbSelectArea(cAliasTmp)
	If (cAliasTmp)->(!EOF())
		lRet := .T.
	Endif

	(cAliasTmp)->(DbCloseArea())

	If !lRet
		Help( ,, 'A103SUSPENSAO',,STR0009 + " (" + cImpTxt + ")",1,0) //"Processo não esta vinculado ao fornecedor (DHS)" 
	Endif
Else
	Help( ,, 'A103SUSPENSAO',,STR0005 + "(" + cImpTxt + ")",1,0) //"Processo não existe no cadastro de processos referenciados (CCF) ou não pertence ao imposto"
Endif

Return lRet

/*/{Protheus.doc} A103SUSPDHR
Busca base ou valor de suspensão do imposto

@param cImposto		Imposto
@param cNatRen		Natureza de Rendimento
@param nQtdParc		Quantidade de Parcelas

@author rodrigo.mpontes
@since 30/08/2019
@version P12.1.17
 /*/

Static Function A103SUSPDHR(cImposto,cNatRen,nQtdParc)

Local nI		:= 0
Local nBSusNF	:= 0
Local nVSusNF	:= 0
Local nBSusImp	:= 0
Local nVSusImp	:= 0
Local nPercNat	:= 0
Local nPercPar	:= 0
Local aCpo		:= {}
Local aRet		:= {}
Local cQry		:= ""
Local cAliasTmp	:= GetNextAlias()
Local cAliasNat	:= GetNextAlias()
Local cAliasPro	:= GetNextAlias()

If cImposto	== "IRF"
	aCpo := {"DHR_BASUIR","DHR_VLRSIR","DHR_PSIR","DHR_TSIR","DHR_ISIR"}
Elseif cImposto == "PIS"
	aCpo := {"DHR_BSUPIS","DHR_VLSPIS","DHR_PSPIS","DHR_TSPIS","DHR_ISPIS"}
Elseif cImposto == "COF"
	aCpo := {"DHR_BSUCOF","DHR_VLSCOF","DHR_PSCOF","DHR_TSCOF","DHR_ISCOF"}
Elseif cImposto == "CSL"
	aCpo := {"DHR_BSUCSL","DHR_VLSCSL","DHR_PSCSL","DHR_TSCSL","DHR_ISCSL"}
Endif

//Base / Valor Suspensão NF
cQry := " SELECT "

For nI := 1 To 2
	If nI == 1
		cQry += " SUM(" + aCpo[nI] + ") AS BASESUS"
	Elseif nI == 2
		cQry += ", SUM(" + aCpo[nI] + ") AS VALORSUS"
	Endif
Next nI

cQry += " FROM " + RetSqlName("DHR")
cQry += " WHERE D_E_L_E_T_ = ''"
cQry += " AND DHR_FILIAL = '" + xFilial("DHR") + "'"
cQry += " AND DHR_DOC = '" + cNFiscal + "'"
cQry += " AND DHR_SERIE = '" + cSerie + "'"
cQry += " AND DHR_FORNEC = '" + cA100For + "'"
cQry += " AND DHR_LOJA = '" + cLoja + "'"

cQry := ChangeQuery(cQry)

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),cAliasTmp,.T.,.T.)

DbSelectArea(cAliasTmp)

If (cAliasTmp)->(!EOF())
	nBSusNF := (cAliasTmp)->BASESUS
	nVSusNF := (cAliasTmp)->VALORSUS
Endif

(cAliasTmp)->(DbCloseArea())

//Base / Valor Suspensão - Natureza Rendimento
cQry := " SELECT "

For nI := 1 To 2
	If nI == 1
		cQry += " SUM(" + aCpo[nI] + ") AS BASESUS"
	Elseif nI == 2
		cQry += ", SUM(" + aCpo[nI] + ") AS VALORSUS"
	Endif
Next nI

cQry += " FROM " + RetSqlName("DHR")
cQry += " WHERE D_E_L_E_T_ = ''"
cQry += " AND DHR_FILIAL = '" + xFilial("DHR") + "'"
cQry += " AND DHR_DOC = '" + cNFiscal + "'"
cQry += " AND DHR_SERIE = '" + cSerie + "'"
cQry += " AND DHR_FORNEC = '" + cA100For + "'"
cQry += " AND DHR_LOJA = '" + cLoja + "'"
cQry += " AND DHR_NATREN = '" + cNatRen + "'"

cQry := ChangeQuery(cQry)

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),cAliasNat,.T.,.T.)

DbSelectArea(cAliasNat)

If (cAliasNat)->(!EOF())
	nBSusImp := (cAliasNat)->BASESUS
	nVSusImp := (cAliasNat)->VALORSUS
Endif

//Percentual de Suspensão do Imposto
nPercNat := nBSusImp * 100 / nBSusNF

//Percentual de Suspensão do Imposto por Titulo
nPercPar := nPercNat / nQtdParc

aAdd(aRet, nBSusNF*nPercPar/100 )
aAdd(aRet, nVSusNF*nPercPar/100 )

(cAliasNat)->(DbCloseArea())

//Processo / Tipo / Ind Suspensão - Natureza Rendimento
cQry := " SELECT "

For nI := 3 To Len(aCpo)
	If nI == 3
		cQry += aCpo[nI] + " AS PROCESSO"
	Elseif nI == 4
		cQry += ", " + aCpo[nI] + " AS TIPO"
	Elseif nI == 5
		cQry += ", " + aCpo[nI] + " AS INDSUS"
	Endif
Next nI

cQry += " FROM " + RetSqlName("DHR")
cQry += " WHERE D_E_L_E_T_ = ''"
cQry += " AND DHR_FILIAL = '" + xFilial("DHR") + "'"
cQry += " AND DHR_DOC = '" + cNFiscal + "'"
cQry += " AND DHR_SERIE = '" + cSerie + "'"
cQry += " AND DHR_FORNEC = '" + cA100For + "'"
cQry += " AND DHR_LOJA = '" + cLoja + "'"
cQry += " AND DHR_NATREN = '" + cNatRen + "'"
cQry += " AND " + aCpo[3] + " <> ''"

cQry := ChangeQuery(cQry)

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),cAliasPro,.T.,.T.)

DbSelectArea(cAliasPro)

If (cAliasPro)->(!EOF())
	aAdd(aRet, (cAliasPro)->PROCESSO )
	aAdd(aRet, (cAliasPro)->TIPO )
	aAdd(aRet, (cAliasPro)->INDSUS )
Else
	aAdd(aRet, "" )
	aAdd(aRet, "" )
	aAdd(aRet, "" )
Endif

aAdd(aRet,nPercNat)

(cAliasPro)->(DbCloseArea())

Return aRet

/*/{Protheus.doc} A103INCDHR
Gravação da DHR - Naturezade Rendimento (Com ou Sem Suspensão)

@param aCabDHR		aHeader DHR
@param aLinDHR		aCols DHR
@param nPosItem		Item posicionado
@param lSuspensao	Indica se houve ou não suspensão

@author rodrigo.mpontes
@since 30/08/2019
@version P12.1.17
 /*/

Function A103INCDHR(aCabDHR,aLinDHR,nPosItem,lSuspensao)

Local lAchou 	:= .F.
Local nZ		:= 0
Local nW		:= 0
Local nDHRIT	:= 0
Local nPNatRen	:= GdFieldPos("DHR_NATREN",aCabDHR)

If !lSuspensao
	If !Empty(aLinDHR[nPosItem][2])
		DHR->(DbSetOrder(1))
		If !aLinDHR[nPosItem][2][1][Len(aCabDHR)+1] .And. nPNatRen > 0 .And. !Empty(aLinDHR[nPosItem][2][1][nPNatRen])
			lAchou := DHR->(MsSeek(xFilial("DHR")+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA+SD1->D1_ITEM))
			If RecLock("DHR",!lAchou)
				For nZ := 1 To Len(aCabDHR)
					If aCabDHR[nZ][10] <> "V" .And. aLinDHR[nPosItem][2][1][nZ] <> Nil
						DHR->(FieldPut(FieldPos(aCabDHR[nZ][2]),aLinDHR[nPosItem][2][1][nZ]))
					EndIf
				Next nZ
				DHR->DHR_FILIAL := xFilial("DHR")
				DHR->DHR_DOC    := SD1->D1_DOC
				DHR->DHR_SERIE  := SD1->D1_SERIE
				DHR->DHR_FORNEC := SD1->D1_FORNECE
				DHR->DHR_LOJA   := SD1->D1_LOJA
				DHR->DHR_ITEM	:= SD1->D1_ITEM
				DHR->(MsUnlock())
			Endif
		EndIf
	EndIf
	DHR->(FkCommit())
Else
	If !Empty(aLinDHR[nPosItem][2])
		DHR->(DbSetOrder(1))
		For nW := 1 To Len(aLinDHR[nPosItem][2])
			nDHRIT := aScan(aCabDHR,{|x| AllTrim(x[2]) == "DHR_ITEM"})
			If !aLinDHR[nPosItem][2][nW][Len(aCabDHR)+1] .And. nPNatRen > 0 .And. !Empty(aLinDHR[nPosItem][2][nW][nPNatRen])
				lAchou := DHR->(MsSeek(xFilial("DHR")+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA+aLinDHR[nPosItem][2][nW][nDHRIT]))
				RecLock("DHR",!lAchou)
				For nZ := 1 To Len(aCabDHR)
					If aCabDHR[nZ][10] <> "V" .And. aLinDHR[nPosItem][2][nW][nZ] <> Nil
						DHR->(FieldPut(FieldPos(aCabDHR[nZ][2]),aLinDHR[nPosItem][2][nW][nZ]))
					EndIf
				Next nZ
				DHR->DHR_FILIAL := xFilial("DHR")
				DHR->DHR_DOC    := SD1->D1_DOC
				DHR->DHR_SERIE  := SD1->D1_SERIE
				DHR->DHR_FORNEC := SD1->D1_FORNECE
				DHR->DHR_LOJA   := SD1->D1_LOJA
				DHR->(MsUnlock())
			EndIf
		Next nZ
	EndIf
	DHR->(FkCommit())
Endif

Return

/*/{Protheus.doc} A103EXCDHR
Exclusão da DHR - Naturezade Rendimento (Com ou Sem Suspensão)

@author rodrigo.mpontes
@since 30/08/2019
@version P12.1.17
 /*/

Function A103EXCDHR()

DbSelectArea("DHR")
DHR->(dbSetOrder(1))
If DHR->(DbSeek(xFilial("DHR")+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA))
	While DHR->(!Eof()) .And. xFilial("DHR") == DHR->DHR_FILIAL .And. ;
			DHR->DHR_DOC == SF1->F1_DOC .And. ;
			DHR->DHR_SERIE == SF1->F1_SERIE .And. ;
			DHR->DHR_FORNEC == SF1->F1_FORNECE .And. ;
			DHR->DHR_LOJA == SF1->F1_LOJA

		RecLock("DHR",.F.)
		DHR->(dbDelete())
		DHR->(MsUnlock())
		DHR->(DbSkip())
	Enddo
	// Tratamento da gravacao do SDE na Integridade Referencial
	DHR->(FkCommit())
EndIf	

Return			

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} A103FKXTRIB
Natureza de rendimento - exceção sem impostos

@author rodrigo.mpontes
@since  11/10/2022
@version 12
@type function
/*/
//------------------------------------------------------------------------------------------

Static Function A103FKXTRIB()

Local oFKXTrib	:= Nil
Local cAliTmp	:= ""
Local cQry		:= ""
Local cQryStat	:= ""
Local aRet		:= {}

If ChkFile("FKX")
	cAliTmp := GetNextAlias()
		
	oFKXTrib := FWPreparedStatement():New()  

	cQry := " SELECT FKX_CODIGO FROM " + RetSqlName("FKX")
	cQry += " WHERE D_E_L_E_T_ = ' '" 
	cQry += " AND FKX_FILIAL = ?"
	cQry += " AND FKX_TRIBUT = ' '"
	cQry := ChangeQuery(cQry)

	oFKXTrib:SetQuery(cQry)
	oFKXTrib:SetString(1,FwxFilial("FKX"))
	
	cQryStat := oFKXTrib:GetFixQuery()
	MpSysOpenQuery(cQryStat,cAliTmp)

	While (cAliTmp)->(!EOF())
		aAdd(aRet,(cAliTmp)->FKX_CODIGO)
		(cAliTmp)->(DbSkip())
	Enddo

	(cAliTmp)->(DbCloseArea()) 
Endif

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} F103TRIB
Retorna o filtro da CCF para exibir na consulta padrão conforme o tipo de imposto selecionado do complemento

    1=Contribuição previdenciária (INSS)
    2=Contribuição previdenciária especial (INSS)
    3=FUNRURAL
    4=SENAR
    5=CPRB
    6=ICMS
    7=PIS
    8=COFINS
	9=IRRF
	A=CSLL

@since  12/06/2017
@version P12
/*/
//-------------------------------------------------------------------

Function F103TRIB()

Local cRet      := ""
Local cFiltro   := ""
Local cCpo		:= SubStr(ReadVar(),4)

If FwIsInCallStack("MATA020") .And. cCpo == "DHS_NUMERO"
	cFiltro := "7|8|9|A"
Elseif FwIsInCallStack("MATA103")
	If cCpo == "DHR_PSPIS" //"PIS"
		cFiltro := "7"
	Elseif cCpo == "DHR_PSCOF" //"COF"
		cFiltro := "8"
	Elseif cCpo == "DHR_PSIR" //"IRRF" 
		cFiltro := "9"
	Elseif cCpo == "DHR_PSCSL" //"CSL"
		cFiltro := "A"				
	EndIf
Endif

If !Empty(cFiltro)
	cRet := "CCF->CCF_TRIB $ '" + cFiltro + "'"
EndIf

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} A103DetSus
Tela de visualização das suspensões

@since  12/06/2017
@version P12
/*/
//-------------------------------------------------------------------

Static Function A103DetSus()

If !Empty(oGetDHR:aCols[oGetDHR:nAt,1])
	A103TelaSusp(aHeader,aCols,.T.)
Endif

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} A103SusNat
Verifica se foi suspensão total do imposto por natureza de rendimento

@param		cNatRen		Natureza de rendimento
@param		cImp		Imposto

@since  12/06/2017
@version P12
/*/
//-------------------------------------------------------------------

Static Function A103SusNat(cNatRen,cImp,nParcela)

Local lRet 		:= .F.
Local nI		:= 0
Local nX		:= 0
Local nBaseNF	:= 0
Local cCpoVld	:= ""
Local nPosCpo	:= 0
Local nPosNat	:= 0
Local nPosIte	:= 0
Local cItem		:= ""
Local lMVImp	:= .T.
Local lZeroMV	:= .F.

If cImp == "IRF"
	cCpoVld := "DHR_BANFIR"
	lMVImp	:= SuperGetMV("MV_RATIRRF",.F.,.F.)
Elseif cImp == "PIS"
	cCpoVld := "DHR_BNFPIS"
	lMVImp	:= SuperGetMV("MV_RATPIS",.F.,.F.)
Elseif cImp == "COF"
	cCpoVld := "DHR_BNFCOF"
	lMVImp	:= SuperGetMV("MV_RATCOF",.F.,.F.)
Elseif cImp == "CSL"
	cCpoVld := "DHR_BNFCSL"
	lMVImp	:= SuperGetMV("MV_RATCSLL",.F.,.F.)
Endif

nPosIte	:= aScan(aHdSusDHR,{|x| AllTrim(x[2]) == "DHR_ITEM"})
nPosNat	:= aScan(aHdSusDHR,{|x| AllTrim(x[2]) == "DHR_NATREN"})
nPosCpo := aScan(aHdSusDHR,{|x| AllTrim(x[2]) == cCpoVld})

If nParcela > 1 .And. !lMVImp //Valor do imposto na primeira parcela, não grava
	lRet := .F.
	lZeroMV := .T.
Endif

If !lZeroMV .And. Len(aCoSusDHR) > 0 .And. nPosCpo > 0 .And. nPosNat > 0 .And. nPosIte > 0
	For nI := 1 To Len(aCoSusDHR)
		cItem := aCoSusDHR[nI,1]
		For nX := 1 To Len(aCoSusDHR[nI,2])
			If aCoSusDHR[nI,2,nX,nPosIte] == cItem .And. aCoSusDHR[nI,2,nX,nPosNat] == cNatRen
				nBaseNF += aCoSusDHR[nI,2,nX,nPosCpo]
			Endif
		Next nX
	Next nI
	If nBaseNF == 0 //Suspensão total pela natureza de rendimento
		lRet := .T.
	Endif
Endif

Return lRet 

//-------------------------------------------------------------------
/*/{Protheus.doc} A103UpdDHR
Atualiza DHR quando for execauto

@since  12/06/2017
@version P12
/*/
//-------------------------------------------------------------------


Static Function A103UpdDHR()

Local nA		:= 0
Local nB		:= 0
Local nPos		:= 0
Local nPosA		:= 0
Local nPosB		:= 0
Local nPosC		:= 0
Local nPosD		:= 0
Local aImpDHR	:= {{"DHR_BASEIR","IT_BASEIRR"},{"DHR_VLRIR","IT_VALIRR"},;
					{"DHR_BASPIS","IT_BASEPIS"},{"DHR_VLRPIS","IT_VALPIS"},;
					{"DHR_BASCOF","IT_BASECOF"},{"DHR_VLRCOF","IT_VALCOF"},;
					{"DHR_BASCSL","IT_BASECSL"},{"DHR_VLRCSL","IT_VALCSL"}}
Local aCalcSDHR	:= {{"DHR_BASUIR","IT_BASEIRR","DHR_VLRSIR","IT_VALIRR"},;
					{"DHR_BSUPIS","IT_BASEPIS","DHR_VLSPIS","IT_VALPIS"},;
					{"DHR_BSUCOF","IT_BASECOF","DHR_VLSCOF","IT_VALCOF"},;
					{"DHR_BSUCSL","IT_BASECSL","DHR_VLSCSL","IT_VALCSL"}}

Local aCalcNFDHR:= {{"DHR_BASEIR","DHR_BASUIR","IT_BASEIRR","IT_VALIRR","DHR_BANFIR","DHR_VLNFIR"},;
					{"DHR_BASPIS","DHR_BSUPIS","IT_BASEPIS","IT_VALPIS","DHR_BNFPIS","DHR_VNFPIS"},;
					{"DHR_BASCOF","DHR_BSUCOF","IT_BASECOF","IT_VALCOF","DHR_BNFCOF","DHR_VNFCOF"},;
					{"DHR_BASCSL","DHR_BSUCSL","IT_BASECSL","IT_VALCSL","DHR_BNFCSL","DHR_VNFCSL"}}

For nA := 1 To Len(aCoSusDHR)
	//Atualiza Original
	For nB := 1 To Len(aImpDHR)
		nPos := aScan(aHdSusDHR,{|x| AllTrim(x[2]) == aImpDHR[nB,1]})
		If nPos > 0
			If aCoSusDHR[nA,2,1,nPos] == 0
				aCoSusDHR[nA,2,1,nPos] := MaFisRet(nA,aImpDHR[nB,2])
			Endif
		Endif
	Next nB

	//Atualiza Suspensão
	For nB := 1 To Len(aCalcSDHR)
		nPosA := aScan(aHdSusDHR,{|x| AllTrim(x[2]) == aCalcSDHR[nB,1]}) 
		nPosB := aScan(aHdSusDHR,{|x| AllTrim(x[2]) == aCalcSDHR[nB,3]}) 
		If nPosA > 0 .And. nPosB > 0
			MaFisAlt(aCalcSDHR[nB,2],aCoSusDHR[nA,2,1,nPosA],nA)
			aCoSusDHR[nA,2,1,nPosB] := MaFisRet(nA,aCalcSDHR[nB,4])
		Endif
	Next nB

	//Atualiza NF
	For nB := 1 To Len(aCalcNFDHR)
		nPosA := aScan(aHdSusDHR,{|x| AllTrim(x[2]) == aCalcNFDHR[nB,1]}) 
		nPosB := aScan(aHdSusDHR,{|x| AllTrim(x[2]) == aCalcNFDHR[nB,2]}) 
		nPosC := aScan(aHdSusDHR,{|x| AllTrim(x[2]) == aCalcNFDHR[nB,5]}) 
		nPosD := aScan(aHdSusDHR,{|x| AllTrim(x[2]) == aCalcNFDHR[nB,6]}) 
		If nPosA > 0 .And. nPosB > 0 .And. nPosC > 0 .And. nPosD > 0
			aCoSusDHR[nA,2,1,nPosC] := aCoSusDHR[nA,2,1,nPosA] - aCoSusDHR[nA,2,1,nPosB]
			
			MaFisAlt(aCalcNFDHR[nB,3],aCoSusDHR[nA,2,1,nPosC],nA)
			aCoSusDHR[nA,2,1,nPosD] := MaFisRet(nA,aCalcNFDHR[nB,4])
		Endif
	Next nB
Next nA

Return
