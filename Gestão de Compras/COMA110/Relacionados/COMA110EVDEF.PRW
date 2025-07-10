#INCLUDE "PROTHEUS.CH"
#INCLUDE "CM110.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "FWMVCDEF.CH"                 
#INCLUDE "FWADAPTEREAI.CH"
#include "TbIconn.ch"
#include "TopConn.ch"

/*/{Protheus.doc} COMA110EVDEF
Eventos padrão da solicitação de compras
@author Leonardo Bratti
@since 28/09/2017
@version P12.1.17 
/*/

CLASS COMA110EVDEF FROM FWModelEvent
	DATA n110TotLib
	
	METHOD New() CONSTRUCTOR
	
	METHOD GridLinePosVld()
	METHOD ModelPosVld()
	METHOD InTTS()
	METHOD Before()
	METHOD BeforeTTS()
	
ENDCLASS

METHOD New() CLASS  COMA110EVDEF
	::n110TotLib := 0
Return

//----------------------------------------------------------------------
/*/{Protheus.doc} GridLinePosVld()
Validações de linha padrão
@author Leonardo Bratti
@since 09/10/2017
@version 1.0
@return .T.
/*/
//----------------------------------------------------------------------
METHOD GridLinePosVld(oModel, cID, nLine) CLASS COMA110EVDEF
 	Local lRet          := .T.
 	Local cProduto , cLocal , cItem , cNum        	
 	Local lGrade        := MaGrade()
 	Local lReferencia   := .F.
 	Local aInfGrd       := {}

 	If cID == "SC1DETAIL"
 		cProduto := oModel:getValue("C1_PRODUTO")
 		cLocal   := oModel:getValue("C1_LOCAL")
 		cItem    := oModel:getValue("C1_ITEM") 
 		cNum     := oModel:getValue("C1_NUM") 
	 	If 	!(oModel:IsDeleted())
	 		lRet := MaAvalPerm(3,{cLocal,cProduto})
	 	
			If lGrade
				lReferencia := MatGrdPrrf(@cProduto)		
				If lReferencia
					aInfGrd := Ma110ValGr()
					If Empty(aInfGrd) .Or. aInfGrd[1]==NIL      
						Help( , , 'Help', ,STR0071, 1, 0 ) 
						lRet := .F.
					Endif    
				Endif		
			Endif 
		Else		
			If !(oModel:IsInserted())
				dbSelectArea("SC1")
				dbSetOrder(1)
				If MsSeek(xFilial("SC1")+cNum+cItem )
					lRet := MaCanDelSC("SC1")
				EndIf
			EndIf
		EndIf	
 	EndIf 	
Return lRet

//----------------------------------------------------------------------
/*/{Protheus.doc} BeforeTTS()
Dentro da transação antes do commit
@author Leonardo Bratti
@since 01/11/2017
@version 1.0
@return .T.
/*/
//----------------------------------------------------------------------
METHOD BeforeTTS(oModel, cModelId) Class COMA110EVDEF	
	If oModel:GetOperation() == 4 .And. VerifGrade(oModel)
		dbSelectArea("SC1")
		dbSetOrder(1)
		 If dbSeek(xFilial("SC1")+FwFldGet("C1_NUM"))
			While SC1->C1_FILIAL + SC1->C1_NUM == xFilial("SC1")+FwFldGet("C1_NUM")
				RecLock("SC1", .F.)
				dbDelete()
				MsUnLock()
				SC1->(DbSkip())
			EndDo
		EndIf
	EndIf

Return .T.
//----------------------------------------------------------------------
/*/{Protheus.doc} ModelPosVld()
Pos validação do modeo
@author Leonardo Bratti
@since 09/10/2017
@version 1.0
@return .T.
/*/
//----------------------------------------------------------------------
METHOD ModelPosVld(oModel, cModelId) Class COMA110EVDEF		
	Local oModelSC1G := oModel:GetModel("SC1DETAIL")
	Local oModelSCXG := oModel:GetModel("SCXDETAIL")	
	
	If oModel:GetOperation() <> 5
		C110GraGr(oModelSC1G , oModelSCXG)
	Endif
		
Return .T.

//----------------------------------------------------------------------
/*/{Protheus.doc} Before()
No momento do commit do modelo
@author Leonardo Bratti
@since 09/10/2017
@version 1.0
@return .T.
/*/
//----------------------------------------------------------------------
METHOD Before(oModel, cModelId, cAlias, lNewRecord) Class COMA110EVDEF	
	Local lRet    	:= .T.
	Local cUser   	:= ""
	Local cPoduto 	:= ""
	Local cImport 	:= ""
	Local cCota   	:= ""
	Local cClass		:= ""
	Local lIntegDef  	:=  FWHasEAI("MATA110",.T.,,.T.)
	Local lMkPlace	:= .F.
	Local lAprovSC	:= SuperGetMv("MV_APROVSC")
	Local lAprsc 		:= SuperGetMv("MV_APRSCEC",.F.,.F.)
	Local lSCSldBl	:= SuperGetMv("MV_SCSLDBL",.F.,.F.)
	Local lSb1TES 	:= SuperGetMv("MV_SB1TES",.F.,.F.)
	Local cEntrega	:= ""
	Local cFilEnt  	:= "" 
	Local cLocal 		:= ""
	Local cEstoque	:= ""
	Local cTpOp     	:= ""
	Local nQuje  		:= 0
	Local nQuant  	:= 0
	Local nQSegUM  	:= 0
	Local nQuje2   	:= 0
	Local nVlUnit   	:= 0
					

	If cModelId == "SC1DETAIL"
		If oModel:GetOperation() <> 5
			cProduto := oModel:getValue("C1_PRODUTO")
			cImport  := oModel:getValue("C1_IMPORT")
			cCota    := oModel:getValue("C1_COTACAO")
			cClass   := oModel:getValue("C1_CLASS")
			nQuje    := oModel:getValue("C1_QUJE")
			nQuje2   := oModel:getValue("C1_QUJE2")
			cFilEnt  := oModel:getValue("C1_FILENT")
			cLocal   := oModel:getValue("C1_LOCAL")
			cEstoque := oModel:getValue("C1_ESTOQUE")
			nQuant	  := oModel:getValue("C1_QUANT")		
			cTpOp 	  := oModel:getValue("C1_TPOP")
			nQSegUM  := oModel:getValue("C1_QTSEGUM")
			nVlUnit  := oModel:getValue("C1_VUNIT")
			cEntrega := If(SuperGetMv("MV_PCFILEN"),If(Empty(cFilEnt),xFilial("SB2"),SB2->(xFilEnt(cFilEnt))),xFilial("SB2"))
			
			If Empty(oModel:getValue("C1_USER"))
				cUser := RetCodUsr()
				oModel:LoadValue("C1_USER", cUser)
				oModel:LoadValue("C1_GRUPCOM", MaRetComSC(cProduto,UsrRetGrp(),cUser))
			EndIf
			
			If cImport == "S"
				If cCota<>"IMPORX"
					oModel:LoadValue("C1_COTACAO", "IMPORT")
				EndIf
				oModel:LoadValue("C1_CLASS", IIf(Empty(cClass),"1",cClass))
			ElseIf cImport == "N" .And. cCota == "IMPORT"
					oModel:LoadValue("C1_COTACAO", "")
				Else
					oModel:LoadValue("C1_COTACAO", If( nQuje == 0 .And. cCota == "XXXXXX" ,"", cCota))
			EndIf
			
			If Empty(oModel:getValue("C1_SCORI"))	
				
				If lAprovSC .AND. !( lAprsc ) .And. !(nQuje > 0) .And. !Empty(oModel:getValue("C1_COTACAO"))
					oModel:LoadValue("C1_APROV", "L")
		   		ElseIf lAprovSC .AND. !( lAprsc ) .And. !(nQuje > 0) // Verifica se a SC foi atendida total ou parcialmente
			  		oModel:LoadValue("C1_APROV", IIf(MaVldSolic(cProduto,/*aGrupo*/,/*cUser*/,.F.),"L","B"))
	   			ElseIf lAprovSC .AND. lAprsc	//-- Se compra centralizada, apenas atualiza flag da descentralização 
		  			oModel:LoadValue("C1_APROV", "B")
		  			oModel:LoadValue("C1_COMPRAC", '2')
		  		EndIf	 
		  		 		
				SB5->(DbSetOrder(1))
				If SB5->(DbSeek( xFilial("SB5") + cPoduto ) )
					If SB5->B5_ENVMKT == "1"
						lMkPlace := .T.				
					EndIf
				EndIf	
						
				If lIntegDef .And. oModel:getValue("C1_APROV") $ " ,L" .And. SuperGetMV("MV_MKPLACE",.F.,.F.) .And. lMkPlace             
					SetRotInteg('MATA110' )
					FwIntegDef( 'MATA110' )				
				EndIf	
						
			EndIf
			
			dbSelectArea("SB2")
			dbSetOrder(1)
			If ( !MsSeek(cEntrega+cProduto+cLocal) )
				CriaSB2(cProduto,cLocal,cEntrega)
			EndIf
			
			If !lSCSldBl .Or. (lSCSldBl .And. oModel:getValue("C1_APROV") <> 'B')
				If lSb1TES
				   	If cEstoque == "S" .Or.  Empty(cEstoque)
						GravaB2Pre("+",nQuant - nQuje , cTpOp ,nQSegUM - nQuje2)
					EndIf
				Else 
					GravaB2Pre("+",nQuant - nQuje , cTpOp ,nQSegUM - nQuje2)
				EndIf
			EndIf
			If GetMV("MV_INTPMS",,"N") == "S"
				PMSWriteSC(1,cAlias)
			EndIf
			LancaPCO("SC1","000051","01","MATA110")
			::n110TotLib += nQuant * Iif( nVlUnit > 0 , nVlUnit , MTGetVProd(cProduto))
		
			oModel:LoadValue("C1_TIPO", 1)
		Else 		
			SFJ->(dbSetOrder(2))
			If SFJ->(dbSeek(xFilial("SFJ")+oModel:getValue("C1_NUM")))
				RecLock("SFJ",.F.)
				SFJ->FJ_SOLICIT:=""
				SFJ->FJ_FORNECE:=""
				SFJ->FJ_LOJA   :=""
				SFJ->FJ_FILENT :=""
				SFJ->FJ_TIPGER :=""
				SFJ->FJ_COND   :=""
				MsUnlock()
				SDF->(MsSeek(xFilial("SDF")+SFJ->FJ_CODIGO))
				While (SDF->DF_CODIGO == SFJ->FJ_CODIGO) .and. xFilial("SDF")==SDF->DF_FILIAL .and. ! SDF->(Eof())
					RecLock("SDF",.F.)
					SDF->DF_FLAG    := "A"
					SDF->(MsUnlock())
					SDF->(DbSkip())
				EndDo
			EndIf	
		EndIf
	EndIf 
Return lRet
//----------------------------------------------------------------------
/*/{Protheus.doc} After()
Depois do commit antes da transação
@author Leonardo Bratti
@since 09/10/2017
@version 1.0
@return .T.
/*/
//----------------------------------------------------------------------
METHOD InTTS(oModel, cModelId) Class COMA110EVDEF	
	Local lGeraSCR   := SuperGetMv("MV_APROVSC",.F.,.F.)
	Local lAlcSolCtb := SuperGetMv("MV_APRSCEC",.F.,.F.)
	Local cGrpAprov  := SuperGetMv("MV_APGRDFL",.F.,"")
	Local oModelSC1G := oModel:GetModel("SC1DETAIL")
	Local oModelSCX  := oModel:GetModel("SCXDETAIL")
	Local dA110Data  := oModelSC1G:getValue("C1_EMISSAO")
	Local aColsSC1   := oModelSC1G:GetOldData()[2]  
	Local aHeadSC1   := oModelSC1G:GetOldData()[1]
	Local aColsSCX   := oModelSCX:GetOldData()[2]  
	Local aHeadSCX   := oModelSCX:GetOldData()[1]	
	
	If lGeraSCR .Or. lAlcSolCtb 	
		If oModelSC1G:GetOperation()  <> 5
			If lAlcSolCtb // Gera alçada por entidade contábil (DBM)
				If oModelSC1G:GetOperation() == 4
					MaEntCtb("SC1","SCX",SC1->C1_NUM,"SC",aHeadSC1,aColsSC1,aHeadSCX,aColsSCX,3,dA110Data)
				EndIf
				MaEntCtb("SC1","SCX",SC1->C1_NUM,"SC",aHeadSC1,aColsSC1,aHeadSCX,aColsSCX,1,dA110Data)
			Elseif !Empty(cGrpAprov) // Gera alçada sem entidade contábil
				If oModelSC1G:GetOperation() == 4
					MaAlcDoc({SC1->C1_NUM,"SC",,,,cGrpAprov,,,,dA110Data},,3)
				EndIf
				MaAlcDoc({SC1->C1_NUM,"SC",::n110TotLib,,,cGrpAprov,,,,dA110Data},,1)
			Endif
		Else
			MaAlcDoc({SC1->C1_NUM,"SC",,,,cGrpAprov,,,,dA110Data},,3)
		Endif
	EndIf 		
	
Return .T.

//----------------------------------------------------------------------
/*/{Protheus.doc} C110GraGr()
Faz a Compatibilização do acols
@author Leonardo Bratti
@since 09/10/2017
@version 1.0
@return .T.
/*/
//----------------------------------------------------------------------
Function C110GraGr(oModelSC1G , oModelSCXG)

	Local nCntFor    := 0     // Contador
	Local nLinha     := 0     // Contador de Linhas
	Local nColuna    := 0     // Contador de Colunas
	Local nCont      := 0     
	Local cProdRef   := ""    // Codigo do Produto Grade
	Local cItem      := "00"  // Controle de Itens do Pedido de Venda
	Local lRet       := .T.
	Local aSaveLines := FWSaveRows()
	Local cProduto   := ""
	Local nNewLinha  := 0
	Local nTamG      := oModelSC1G:Length()
	Local aDados     := {}
	Local aDadosSCX  := {}
	Local nX		   := 0 
	Local nNewRat    := 0
			
	If MaGrade() .And. Type("oGrade")=="O" .And. Len(oGrade:aColsGrade[1])>0
		For nCntFor := 1 To nTamG
			oModelSC1G:GoLine( nCntFor )
			cItem      := oModelSC1G:GetValue("C1_ITEM")
			cItemGrdT   := "000"
			cProdRef   := oModelSC1G:GetValue("C1_PRODUTO")
			If ( !Empty(cProdRef) )
				oGrade:nPosLinO := nCntFor
				If ( Len(oGrade:aHeadGrade)>0 .And. oGrade:aHeadGrade[nCntFor][1] == "R" ) .And. oModelSC1G:GetValue("C1_GRADE")  == "S"
					For nLinha := 1 To Len(oGrade:aColsGrade[nCntFor])
						For nColuna := 2 To Len(oGrade:aHeadGrade[nCntFor])
							If ( oGrade:aColsFieldByName("C1_QUANT",nCntFor,nLinha,nColuna) <> 0 .And. !(oModelSC1G:IsDeleted())) 								
								cItemGrdT := Soma1(cItemGrdT,Len(SC1->C1_ITEMGRD))
								cProdRef := oModelSC1G:GetValue("C1_PRODUTO")
								MatGrdPrRf(@cProdRef)
								cProdRef  := oGrade:GetNameProd(cProdRef,nLinha,nColuna)		
								aDados    := oModelSC1G:GetData()
								aDadosSCX := oModelSCXG:GetData()				
								nNewLinha := oModelSC1G:AddLine()
								oModelSC1G:GoLine(nNewLinha)
								
								For nCont := 1 to len(oGrade:AHEADAUX)
									oModelSC1G:LoadValue(oGrade:AHEADAUX[nCont][2], aDados[1][1][1][nCont])
								Next nCont
								
								If !(Empty(aDadosSCX[1][1][1][6])) .And. cItemGrdT == '001'
									For nX := 1 To Len(aDadosSCX)
									
										If nX <> 1
											nNewRat := oModelSCXG:AddLine()
											oModelSCXG:GoLine(nNewRat)
										Else
											oModelSCXG:GoLine(1)	
										EndIf
										
										For nCont := 1 to len(oModelSCXG:aHeader)
											oModelSCXG:LoadValue(oModelSCXG:aHeader[nCont][2], aDadosSCX[nX][1][1][nCont])
										Next nCont
									Next nX
								Endif
								oModelSC1G:LoadValue("C1_PRODUTO", PadR(cProdRef,Len(SB1->B1_COD)))							
								oModelSC1G:LoadValue("C1_ITEM", cItem)
								oModelSC1G:LoadValue("C1_ITEMGRD", cItemGrdT)
								oModelSC1G:LoadValue("C1_QUANT", oGrade:aColsFieldByName("C1_QUANT",nCntFor,nLinha,nColuna))
								oModelSC1G:LoadValue("C1_QTSEGUM", oGrade:aColsFieldByName("C1_QTSEGUM",nCntFor,nLinha,nColuna))
								oModelSC1G:LoadValue("C1_GRADE", "S")
								oModelSC1G:LoadValue("C1_DATPRF", oGrade:aColsFieldByName("C1_DATPRF",nCntFor,nLinha,nColuna))							
							Else							
								If ( !Empty(oGrade:aColsFieldByName("C1_ITEM",nCntFor,nLinha,nColuna)) )
								 lRet := oModelSC1G:DeleteLine() 							
								EndIf
							EndIf
						Next nColuna
					Next nLinha
					cItemGrdT := ""					
					oModelSC1G:GoLine(nCntFor)
					lRet := oModelSC1G:DeleteLine()
				EndIf
			EndIf
		Next nCntFor
		oGrade:aColsGrade  := {}
		oGrade:aHeadGrade  := {}
	EndIf
	FWRestRows( aSaveLines )
Return lRet


