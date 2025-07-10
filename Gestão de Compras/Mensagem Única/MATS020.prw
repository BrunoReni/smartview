#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"


/*/{Protheus.doc} MATS030

API de integração do Cadastro de Fornecedor (Vendor) - SA2 

@author  Squad CRM Faturamento
@version P12
@since   27/08/2018
/*/

Function MATS020(oApiManager, aQueryString, nOpc, cChave, oJson, cBody)

	Local aCab				:= {}
	Local aCabBCO			:= {}
	Local aJson				:= {}
	Local cCodigo			:= ""
	Local cLoja				:= ""
	Local cPISSRA			:= ""
	Local cResp				:= ""
	Local cValSRAInt		:= ""
    Local lRet  			:= .T.
	Local nPosCod			:= 0
	Local nPosLoja			:= 0
	Local nX				:= 0

	Private lMsErroAuto 	:= .F.
	Private lAutoErrNoFile	:= .T.

	Default aQueryString	:= {}
	Default cChave 			:= ""
	Default nOpc			:= 2
	Default	oApiManager		:= Nil
	Default oJson			:= Nil
	Default cBody			:= ""

	oApiManager:SetApiAdapter("MATS020") 
	oApiManager:SetApiAlias({"SA2","items", "items"})
	oApiManager:SetApiMap(ApiMapSA2())
	oApiManager:Activate()

	DefRelation(@oApiManager)

	If nOpc != 5
		aJson := oApiManager:ToArray(cBody)
		If Len(aJson) > 0
			If Len(aJson[1][1]) > 0
				oApiManager:ToExecAuto(1, aJson[1][1][1][2], aCab)
			EndIf

			If Len(aJson[1][2]) > 0
				For nX := 1 To Len(aJson[1][2])
					If aJson[1][2][nX][1][1] == "SA2"
						oApiManager:ToExecAuto(1, aJson[1][2][nX][1][2], aCab)
					Else
						oApiManager:ToExecAuto(2, aJson[1][2][nX][1][2], aCabBCO)
					EndIf
				Next
			EndIf

			If Len(aCab) > 0
				ASORT(aCab, , , { | x,y | x[1] > y[1] } )
			Endif

			If Len(aJson[1][3]) > 0
				For nX := 1 To Len(aJson[1][3][1])
					MontaCab(aJson[1][3][1][nX], @aCab, @cPISSRA)
				Next
			EndIf
		EndIf
	EndIf

	If !Empty(cChave)
		cCodigo	:= SubStr(cChave, 1                       , TamSX3("A2_COD")[1] )
		cLoja	:= SubStr(cChave, TamSX3("A2_COD")[1] + 1 , Len(cChave)         )
	EndIf

	nPosCod	:= (aScan(aCab ,{|x| AllTrim(x[1]) == "A2_COD"}))
	nPosLoja:= (aScan(aCab ,{|x| AllTrim(x[1]) == "A2_LOJA"}))

	If nOpc == 3

		If nPosCod == 0 .And. nPosLoja == 0
			aAdd( aCab, {'A2_COD'	, MATS20NUM()	, Nil})
			aAdd( aCab, {'A2_LOJA'	,'01'			, Nil})
		ElseIf nPosCod == 0 .And. nPosLoja != 0
			aAdd( aCab, {'A2_COD',MATS20NUM(), Nil})
		ElseIf nPosCod != 0 .And. nPosLoja == 0
			aAdd( aCab, {'A2_LOJA'	,'01'		, Nil})
		EndIf

		If Empty(cCodigo) .OR. Empty(cLoja)
			cCodigo	:= aCab[aScan(aCab ,{|x| AllTrim(x[1]) == "A2_COD"})][2]
			cLoja	:= aCab[aScan(aCab ,{|x| AllTrim(x[1]) == "A2_LOJA"})][2]
		Endif
	Else 
		If nPosCod == 0 .And. nPosLoja == 0
			aAdd( aCab, {'A2_COD'	,cCodigo	, Nil})
			aAdd( aCab, {'A2_LOJA'	,cLoja		, Nil})
		Else
			aCab[nPosCod][2]  := cCodigo
			aCab[nPosLoja][2] := cLoja
		EndIf
	EndIf

	BEGIN TRANSACTION
		
		If lRet
			MsExecAuto({|x,y|Mata020(x,y)},aCab,nOpc)
			If lMsErroAuto
				aMsgErro := GetAutoGRLog()
				cResp	 := ""
				For nX := 1 To Len(aMsgErro)
					cResp += StrTran( StrTran( aMsgErro[nX], "<", "" ), "-", "" ) + (" ")
				Next nX
				lRet := .F.
				oApiManager:SetJsonError("400","Erro durante Inclusão/Alteração/Exclusão do fornecedor!.", cResp,/*cHelpUrl*/,/*aDetails*/)
			Else
				SA2->(DbSetOrder(1))
				SA2->(DbGoTop())
				If SA2->(DbSeek(xFilial("SA2") + cCodigo + cLoja))
				
					If (nOpc == 3 .Or. nOpc == 4) .And. Len(aCabBco) > 0
						M020GRVF(xFilial("FIL"), SA2->A2_COD, SA2->A2_LOJA, aCabBco)
					Endif
					
					cValSRAInt := GPEI090NRcv( CFGA070INT( "PROTHEUS", "SRA", "RA_MAT", SA2->A2_COD + SA2->A2_LOJA ), { "RA_FILIAL", "RA_MAT" } )

					If lRet .And. (!Empty(cPISSRA) .AND. (nOpc == 3 .OR. nOpc == 4) ) .OR. !Empty(cValSRAInt)
						Gp265GrvFun(nOpc, cPISSRA, "PROTHEUS", "A2_COD", SA2->A2_COD + SA2->A2_LOJA, "SA2", cValSRAInt)
					EndIf					
				Endif
			EndIf
		EndIf

	END TRANSACTION

	aSize(aCab,0)
	aSize(aCabBco,0)

Return lRet

/*/{Protheus.doc} MontaCab
Monta o array do cabeçalho que será utilizado no execauto

@param	oJson				, objeto  , Objeto com o array parseado
@param	aCab				, array   , Array que será populado com os dados do Json parciado

@author		Squad Faturamento/CRM
@since		29/08/2018
@version	12.1.17
/*/

Static Function MontaCab(oJson, aCab, cPISSRA)
	
	If AttIsMemberOf(oJson, "name") .And. AttIsMemberOf(oJson, "id") .And. !Empty(oJson:id) .And. !Empty(oJson:name)
		If AllTrim(oJson:name) $ "INSCRICAO ESTADUAL"
			aAdd( aCab, {'A2_INSCR'		,oJson:id, Nil}) 
		ElseIf AllTrim(oJson:name) $ "INSCRICAO MUNICIPAL"
			aAdd( aCab, {'A2_INSCRM' 	,oJson:id, Nil}) 
		ElseIf AllTrim(oJson:name) $ "CPF|CNPJ" 
			aAdd( aCab, {'A2_CGC' 		,oJson:id, Nil}) 
		ElseIf AllTrim(oJson:name) $ "RG"
			aAdd( aCab, {'A2_PFISICA' 	,oJson:id, Nil}) 
		ElseIf AllTrim(oJson:name) $ "INSCRICAO PIS"
			cPISSRA	:= oJson:id
		EndIf
	EndIf

Return Nil

/*/{Protheus.doc} MATS020G
Realiza o Get dos Fornecedores

@param oApiManager	, Objeto	, Objeto ApiManager inicializado no método 
@param Self			, Objeto	, Objeto Restful

@return lRet	, Lógico	, Retorna se conseguiu ou não processar o Get.

@author		Squad Faturamento/CRM
@since		06/08/2018
@version	12.1.20
/*/

Function MATS020G(oApiManager, Self , aFilter)

	Local aFatherAlias		:=	{"SA2","items"							, "items"}
	Local cIndexKey			:= "A2_FILIAL, A2_COD, A2_LOJA"
	Local lRet				:= .T.

	Default aFilter			:= {}

	oApiManager:SetApiAdapter("MATS020") 
   	oApiManager:SetApiAlias({"SA2","items", "items"})
	oApiManager:SetApiMap(APIMapSA2())
	oApiManager:Activate()

	If Len(oApiManager:GetApiRelation()) == 0
		DefRelation(@oApiManager)
	Endif	

	If Len(aFilter) > 0
		oApiManager:SetApiFilter(aFilter) 
	Endif

	lRet := GetMain(@oApiManager, Self:aQueryString, aFatherAlias, , cIndexKey)

Return lRet

/*/{Protheus.doc} DefRelation
Realiza o Get dos clientes

@param oApiManager	, Objeto	, Objeto ApiManager inicializado no método 

@return Nil	

@author		Squad Faturamento/CRM
@since		06/08/2018
@version	12.1.20
/*/
Static Function DefRelation(oApiManager)
	Local aRelation			:= {{"A2_FILIAL","A2_FILIAL"},{"A2_COD","A2_COD"},{"A2_LOJA","A2_LOJA"}}
	Local aRelationF		:= {{"A2_FILIAL","FIL_FILIAL"},{"A2_COD","FIL_FORNEC"},{"A2_LOJA","FIL_LOJA"}}
	Local aFatherAlias		:=	{"SA2","items"							, "items"}
	Local aChiMktSeg		:=	{"SA2","marketsegment"					, "marketsegment"}
	Local aChiGovInfo		:=	{"SA2","GovernmentalInformation"		, "GovernmentalInformation"}
	Local aChiInfoIE		:=	{"SA2",""		, "GovInfoIE"}
	Local aChiInfoIM		:=	{"SA2",""		, "GovInfoIM"}
	Local aChiInfoC			:=	{"SA2",""		, "GovInfoC"}
	Local aChiInfoPS		:=	{"SA2",""		, "GovInfoPIS"}
	Local aChiInfoRG		:=	{"SA2",""		, "GovInfoRG"}
	Local aChiEndM   		:= 	{"SA2","address"						, "addressM"}
	Local aChiCidM   		:= 	{"SA2","city"							, "cityM"}
	Local aChiEstM   		:= 	{"SA2","state"							, "stateM"}
	Local aChiConM   		:= 	{"SA2","country"						, "countryM"}
	Local aChiEndS 			:= 	{"SA2","shippingAddress"				, "shippingAddress"}
	Local aChiCidS   		:= 	{"SA2","city"							, "cityS"}
	Local aChiEstS   		:= 	{"SA2","state"							, "stateS"}
	Local aChiConS   		:= 	{"SA2","country"						, "countryS"}
	Local aChiComInfo		:=	{"SA2","listOfCommunicationInformation"	, "listOfCommunicationInformation"}
	Local aChiContacts		:=	{"SA2","listOfContacts"					, "listOfContacts"}
	Local aChiBankInf		:=	{"FIL","listOfBankingInformation"		, "listOfBankingInformation"}
	Local aChiFiscal		:=	{"SA2","fiscalInformation"				, "fiscalInformation"}
	Local aChiCredInf		:=	{"SA2","creditInformation"				, "creditInformation"}
	Local aChiVendType		:=	{"SA2","vendorInformation"				, "vendorInformation"}
	Local aChiTaxPayer		:=	{"SA2","taxPayer"						, "taxPayer"}
	Local aChiBillInfo		:=	{"SA2","billingInformation"				, "billingInformation"}
	Local aChiEndC			:=	{"SA2","address"						, "addressB"}
	Local aChiCidC			:=	{"SA2","city"							, "cityB"}
	Local aChiEstC			:=	{"SA2","state" 							, "stateB"}
	Local aChiConC			:=	{"SA2","country"						, "countryB"}
	Local aChiCntCom		:= 	{"SA2","CommunicationInformation"		, "CommunicationInformationCt"}
	Local aChiEndCnt		:=  {"SA2","ContactInformationAddress"		, "addressCnt"}
	Local aChiCidCnt		:=  {"SA2","city"							, "cityCt"}
	Local aChiEstCnt		:=	{"SA2","state"							, "stateCt"}
	Local aChiConCnt		:=	{"SA2","country"						, "countryCt"}
	Local cIndexKey			:= "A2_FILIAL, A2_COD, A2_LOJA"
	Local cIndexKeyF		:= "FIL_FILIAL, FIL_FORNEC, FIL_LOJA"

	oApiManager:SetApiRelation(aChiMktSeg	,aFatherAlias	, aRelation, cIndexKey)

	oApiManager:SetApiRelation(aChiGovInfo	,aFatherAlias	, aRelation, cIndexKey)
	oApiManager:SetApiRelation(aChiInfoIE	,aChiGovInfo	, aRelation, cIndexKey)
	oApiManager:SetApiRelation(aChiInfoIM	,aChiGovInfo	, aRelation, cIndexKey)
	oApiManager:SetApiRelation(aChiInfoC	,aChiGovInfo	, aRelation, cIndexKey)
	oApiManager:SetApiRelation(aChiInfoPS	,aChiGovInfo	, aRelation, cIndexKey)
	oApiManager:SetApiRelation(aChiInfoRG	,aChiGovInfo	, aRelation, cIndexKey)

	oApiManager:SetApiRelation(aChiEndM		,aFatherAlias	, aRelation, cIndexKey)
	oApiManager:SetApiRelation(aChiCidM		,aChiEndM		, aRelation, cIndexKey)
	oApiManager:SetApiRelation(aChiEstM		,aChiEndM		, aRelation, cIndexKey)
	oApiManager:SetApiRelation(aChiConM		,aChiEndM		, aRelation, cIndexKey)

	oApiManager:SetApiRelation(aChiEndS		,aFatherAlias	, aRelation, cIndexKey)
	oApiManager:SetApiRelation(aChiCidS		,aChiEndS		, aRelation, cIndexKey)
	oApiManager:SetApiRelation(aChiEstS		,aChiEndS		, aRelation, cIndexKey)
	oApiManager:SetApiRelation(aChiConS		,aChiEndS		, aRelation, cIndexKey)	

	oApiManager:SetApiRelation(aChiComInfo	,aFatherAlias	, aRelation, cIndexKey)

	oApiManager:SetApiRelation(aChiContacts	,aFatherAlias	, aRelation, cIndexKey)
	oApiManager:SetApiRelation(aChiCntCom	,aChiContacts	, aRelation, cIndexKey)
	oApiManager:SetApiRelation(aChiEndCnt	,aChiContacts	, aRelation, cIndexKey)
	oApiManager:SetApiRelation(aChiCidCnt	,aChiEndCnt		, aRelation, cIndexKey)
	oApiManager:SetApiRelation(aChiEstCnt	,aChiEndCnt		, aRelation, cIndexKey)
	oApiManager:SetApiRelation(aChiConCnt	,aChiEndCnt		, aRelation, cIndexKey)

	oApiManager:SetApiRelation(aChiBankInf	,aFatherAlias	, aRelationF, cIndexKeyF)
	oApiManager:SetApiRelation(aChiCredInf	,aFatherAlias	, aRelation, cIndexKey)
	oApiManager:SetApiRelation(aChiVendType	,aFatherAlias	, aRelation, cIndexKey)
	
	oApiManager:SetApiRelation(aChiFiscal	,aFatherAlias	, aRelation, cIndexKey)
	oApiManager:SetApiRelation(aChiTaxPayer	,aChiFiscal		, aRelation, cIndexKey)

	oApiManager:SetApiRelation(aChiBillInfo	,aFatherAlias	, aRelation, cIndexKey)
	oApiManager:SetApiRelation(aChiEndC		,aChiBillInfo	, aRelation, cIndexKey)
	oApiManager:SetApiRelation(aChiCidC		,aChiEndC		, aRelation, cIndexKey)
	oApiManager:SetApiRelation(aChiEstC		,aChiEndC		, aRelation, cIndexKey)
	oApiManager:SetApiRelation(aChiConC		,aChiEndC		, aRelation, cIndexKey)

Return

/*/{Protheus.doc} GetMain
Realiza o Get dos Fornecedores

@param oApiManager	, Objeto	, Objeto ApiManager inicializado no método 
@param aQueryString	, Array		, Array com os filtros a serem utilizados no Get
@param aFatherAlias	, Array		, Dados da tabela pai
@param lHasNext		, Logico	, Informa se informação se existem ou não mais paginas a serem exibidas
@param cIndexKey	, String	, Índice da tabela pai

@return lRet	, Lógico	, Retorna se conseguiu ou não processar o Get.

@author		Squad Faturamento/CRM
@since		06/08/2018
@version	12.1.17
/*/

Static Function GetMain(oApiManager, aQueryString, aFatherAlias, lHasNext, cIndexKey)

	Local aRelation 		:= {}
	Local aChildrenAlias	:= {}
	Local lRet 				:= .T.

	Default oApiManager		:= Nil	
	Default aQueryString	:={,}
	Default lHasNext		:= .T.
	Default cIndexKey		:= ""

	lRet := ApiMainGet(@oApiManager, aQueryString, aRelation , aChildrenAlias, aFatherAlias, cIndexKey, oApiManager:GetApiAdapter(), oApiManager:GetApiVersion(),;
	 lHasNext)

	FreeObj( aRelation )
	FreeObj( aChildrenAlias )
	FreeObj( aFatherAlias )

Return lRet

/*/{Protheus.doc} MATS20NUM
Pega o próximo código de Fornecedor válido

@return cProxNum	, String	, Código do Fornecedor a ser utilizado.

@author		Squad Faturamento/CRM
@since		06/08/2018
@version	12.1.20
/*/
Static Function MATS20NUM()

	Local cProxNum := ""

	cProxNum := GetSX8Num("SA2","A2_COD")

	While .T.
		If SA2->( DbSeek( xFilial("SA2")+ cProxNum ) )
			ConfirmSX8()
			cProxNum:= GetSXeNum("SA2","A2_COD")
		Else
			Exit
		Endif
	Enddo

Return cProxNum

/*/{Protheus.doc} ApiMapSA2
Estrutura a ser utilizada na classe ServicesApiManager

@return aApiMap	, Array	, Array com estrutura 

@author		Squad Faturamento/CRM
@since		06/08/2018
@version	12.1.17
/*/

Static Function ApiMapSA2()

	Local aApiMap		:= {}
	Local aStrSA2		:= {}
	Local aStrMktSeg	:= {}
	Local aStrGovInfo	:= {}
	Local aStrInfoIE	:= {}
	Local aStrInfoIM	:= {}
	Local aStrInfoC		:= {}
	Local aStrInfoPS	:= {}
	Local aStrInfoRG	:= {}
	Local aStrEndM		:= {}
	Local aStrCidM		:= {}
	Local aStrEstM		:= {}
	Local aStrConM		:= {}
	Local aStrEndS		:= {}
	Local aStrCidS		:= {}
	Local aStrConS		:= {}
	Local aStrComInfo	:= {}
	Local aStrContacts	:= {}
	Local aStrContCom	:= {}
	Local aStrContEnd	:= {}
	Local aStrCidCt		:= {}
	Local aStrEstCt		:= {}
	Local aStrConCt		:= {}
	Local aStrBankInf	:= {}
	Local aStrFiscal	:= {}
	Local aStrTaxPayer	:= {}
	Local aStrCredInf	:= {}
	Local aStrVendType	:= {}
	Local aStrBillInfo	:= {}
	Local aStrEndC		:= {}
	Local aStrCidC		:= {}
	Local aStrEstC		:= {}
	Local aStrConC		:= {}
	
	aStrSA2		:=	{"SA2","Field","items","items",;
							{;
								{"companyId"					, ""											},;
								{"branchId"						, "A2_FILIAL"									},;
								{"companyInternalId"			, "Exp:cEmpAnt, A2_FILIAL, A2_COD, A2_LOJA"		},;								
								{"code"							, "A2_COD"										},;
								{"storeId"						, "A2_LOJA"										},;
								{"internalId"					, ""											},;
								{"shortName"					, "A2_NREDUZ"									},;
								{"name"							, "A2_NOME"										},;
								{"type"							, "Exp:2"										},;								
								{"entityType"					, ""											},;
								{"registerdate"					, ""											},;
								{"registerSituation"			, "A2_MSBLQL"									},;
								{"comments"						, ""											},;
								{"paymentConditionCode"			, "A2_COND"										},;
								{"paymentConditionInternalId"	, ""											},;
								{"priceListHeaderItemCode"		, ""											},;
								{"carrierCode"					, "A2_TRANSP"									},;
								{"strategicCustomerType"		, "A2_TIPO"										},;
								{"rateDiscount"					, ""											},;
								{"sellerCode"					, ""											},;
								{"sellerInternalId"				, ""											};
							},;
						}

	aStrMktSeg	:=	{"SA2","Field","marketsegment","marketsegment",;
							{;
								{"marketSegmentCode"							, ""							},;
								{"marketSegmentInternalId"						, ""							},;
								{"marketSegmentDescription"						, ""							};
							},;
						}

	
	
	
	aStrGovInfo	:=	{"SA2","ITEM","GovernmentalInformation","GovernmentalInformation",;
						{},;
					}	
	aStrInfoIE	:=	{"SA2","Object","","GovInfoIE",;
						{;
							{"id"							, "A2_INSCR"									},;
							{"name"							, "Exp:'INSCRICAO ESTADUAL'"					},;
							{"scope"						, ""											},;
							{"expireOn"						, ""											},;
							{"issueOn"						, ""											};
						},;
					}
	aStrInfoIM	:=	{"SA2","Object","","GovInfoIM",;
						{;
							{"id"							, "A2_INSCRM"									},;
							{"name"							, "Exp:'INSCRICAO MUNICIPAL'"					},;
							{"scope"						, ""											},;
							{"expireOn"						, ""											},;
							{"issueOn"						, ""											};
						},;
					}
	aStrInfoC	:=	{"SA2","Object","","GovInfoC",;
						{;
							{"id"							, "A2_CGC"										},;
							{"name"							, "Exp:'CPF|CNPJ'"								},;
							{"scope"						, ""											},;
							{"expireOn"						, ""											},;
							{"issueOn"						, ""											};
						},;
					}
	aStrInfoPS	:=	{"SA2","Object","","GovInfoPIS",;
						{;
							{"id"							, ""											},;
							{"name"							, "Exp:'INSCRICAO PIS'"							},;
							{"scope"						, ""											},;
							{"expireOn"						, ""											},;
							{"issueOn"						, ""											};
						},;
					}
	aStrInfoRG	:=	{"SA2","Object","","GovInfoRG",;
							{;
								{"id"							, "A2_PFISICA"									},;
								{"name"							, "Exp:'RG'"									},;
								{"scope"						, ""											},;
								{"expireOn"						, ""											},;
								{"issueOn"						, ""											};
							},;
					}
	aStrEndM   	:= 	{"SA2","field","address","addressM",;
							{;
								{"address"						, "A2_END"										},;
								{"number"						, ""											},;
								{"complement"					, "A2_COMPLEM"									},;
								{"district"						, "A2_BAIRRO"									},;
								{"zipCode"						, "A2_CEP"  									},;
								{"region"						, ""											},;
								{"poBox"						, "A2_CX_POST"									},;
								{"mainAddress"					, "Exp:.T."										},;
								{"shippingAddress"				, "Exp:.F."										},;
								{"billingAddress"				, "Exp:.F."										};
							},;
					}	
	aStrCidM   	:= 	{"SA2","Field","city","cityM",;
							{;
								{"cityCode"						, "A2_COD_MUN"									},;
								{"cityInternalId"				, "A2_COD_MUN"									},;
								{"cityDescription"				, "A2_MUN"										};
							},;
					}

	aStrEstM   	:= 	{"SA2","Field","state","stateM",;
							{;
								{"stateId"						, "A2_EST"										},;
								{"stateInternalId"				, "A2_EST"										},;
								{"stateDescription"				, ""											};
							},;
					}

	aStrConM   	:= 	{"SA2","Field","country","countryM",;
							{;
								{"countryCode"					, "A2_PAIS"										},;
								{"countryInternalId"			, "A2_PAIS"										},;
								{"countryDescription"			, ""											};
							},;
					}																											

	aStrEndS 	:= 	{"SA2","Field","shippingAddress","shippingAddress",;
							{;
								{"address"						, ""											},;
								{"number"						, ""											},;
								{"complement"					, ""											},;
								{"district"						, ""											},;
								{"zipCode"						, ""  											},;
								{"region"						, ""											},;
								{"poBox"						, ""											},;
								{"mainAddress"					, "Exp:.F."										},;
								{"shippingAddress"				, "Exp:.T."										},;
								{"billingAddress"				, "Exp:.F."										};
							},;
					}		

	aStrCidS   	:= 	{"SA2","Field","city","cityS",;
							{;
								{"cityCode"						, ""											},;
								{"cityInternalId"				, ""											},;
								{"cityDescription"				, ""											};
							},;
					}

	aStrEstS   	:= 	{"SA2","Field","state","stateS",;
							{;
								{"stateId"						, ""											},;
								{"stateInternalId"				, ""											},;
								{"stateDescription"				, ""											};
							},;
					} 

	aStrConS   	:= 	{"SA2","Field","country", "countryS",;
							{;
								{"countryCode"					, ""											},;
								{"countryInternalId"			, ""											},;
								{"countryDescription"			, ""											};
							},;
					}
	aStrComInfo	:=	{"SA2","ITEM","listOfCommunicationInformation", "listOfCommunicationInformation",;
							{;
								{"type"							, ""											},;
								{"phoneNumber"					, "A2_TEL"										},;
								{"phoneExtension"				, ""											},;
								{"faxNumber"					, "A2_FAX"										},;
								{"faxNumberExtension"			, ""											},;
								{"homePage"						, "A2_HPAGE"									},;								
								{"email"						, "A2_EMAIL"									},;
								{"diallingCode"					, "A2_DDD"										},;
								{"internationalDiallingCode"	, "A2_DDI"										};
							},;
						}		
	aStrContacts:=	{"SA2","ITEM","listOfContacts", "listOfContacts",;
							{;
								{"ContactInformationCode"		, ""											},;
								{"ContactInformationInternalId"	, ""											},;
								{"ContactInformationTitle"		, ""											},;
								{"ContactInformationName"		, "A2_CONTATO"									},;
								{"ContactInformationDepartment" , ""											};
							},;
						}			
	aStrContCom := 	{"SA2","Field","CommunicationInformation","CommunicationInformationCt",;
							{;
								{"type"							,""												},;
								{"phoneNumber"					,""												},;
								{"phoneExtension"				,""												},;
								{"faxNumber"					,""												},;
								{"faxNumberExtension"			,""												},;
								{"homePage"						,""												},;
								{"email"						,""												},;
								{"diallingCode"					,""												},;
								{"internationalDiallingCode"	,""												};								
							},;
						} 
	aStrContEnd	:= 	{"SA2","Field","ContactInformationAddress","addressCnt",;
							{;
								{"address"						, ""											},;
								{"number"						, ""											},;
								{"complement"					, ""											},;
								{"district"						, ""											},;
								{"zipCode"						, ""  											},;
								{"region"						, ""											},;
								{"poBox"						, ""											},;
								{"mainAddress"					, "Exp:.F."										},;
								{"shippingAddress"				, "Exp:.F."										},;
								{"billingAddress"				, "Exp:.F."										};
							},;
						}
	aStrCidCt 	:= 	{"SA2","Field","city","cityCt",;
							{;
								{"cityCode"						, ""											},;
								{"cityInternalId"				, ""											},;
								{"cityDescription"				, ""											};
							},;
					}
	aStrEstCt  	:= 	{"SA2","Field","state","stateCt",;
							{;
								{"stateId"						, ""											},;
								{"stateInternalId"				, ""											},;
								{"stateDescription"				, ""											};
							},;
					}
	aStrConCt   := 	{"SA2","Field","country","countryCt",;
							{;
								{"countryCode"					, ""											},;
								{"countryInternalId"			, ""											},;
								{"countryDescription"			, ""											};
							},;
						}			
	aStrBankInf	:=	{"FIL","ITEM","listOfBankingInformation", "listOfBankingInformation",;
							{;
								{"bankCode"						, "FIL_BANCO"									},;
								{"bankInternalId"				, ""											},;
								{"bankName"						, ""											},;
								{"branchCode"					, "FIL_AGENCI"									},;
								{"branchKey"					, "FIL_DVAGE"									},;
								{"checkingAccountNumber"		, "FIL_CONTA"									},;
								{"checkingAccountNumberKey"		, "FIL_DVCTA"									},;								
								{"checkingAccountType"			, "FIL_TIPCTA"									},;
								{"mainAccount"					, "FIL_TIPO"									},;
								{"currencyAccount"				, "FIL_MOEDA"									};
							},;
						}			
	aStrFiscal	:=	{"SA2","Field","fiscalInformation"		, "fiscalInformation",;
							{;
								{"Category"						, ""											},;
								{"IsRetentionAgent"				, ""											};
							},;
						}	
	aStrTaxPayer:=	{"SA2","Field","taxPayer"				, "taxPayer",;
							{;
								{"taxName"						, ""											},;
								{"isPayer"						, ""											},;								
								{"mode"							, ""											};
							},;
						}	
	aStrCredInf	:=	{"SA2","Field","creditInformation", "creditInformation",;
							{;
								{"creditIndicator"				, ""											},;
								{"creditEvaluation"				, ""											},;								
								{"shipmentCreditEvaluation"		, ""											},;
								{"creditLimit"					, ""											},;								
								{"creditLimitCurrency"			, ""											},;
								{"creditLimitDate"				, ""											},;																								
								{"additionalCreditLimit"		, ""											},;																								
								{"additionalCreditLimitCurrency", ""											},;																								
								{"additionalCreditLimitDate"	, ""											},;
								{"latePeriods"					, ""											},;
								{"balanceOfCredit"				, ""											};
							},;
						}		

	aStrVendType:=	{"SA2","Field","vendorInformation", "vendorInformation",;
							{;
								{"vendorClassification"			, ""											},;
								{"vendorTypeCode"				, ""											},;								
								{"vendorTypeInternalId"			, ""											},;																
								{"vendorTypeDescription"		, ""											};
							},;
						}							
	aStrBillInfo:=	{"SA2","Field","billingInformation", "billingInformation",;
							{;
								{"billingCustomerCode"			, ""											},;
								{"billingCustomerInternalId"	, ""											};								
							},;
						}			

	aStrEndC 	:= 	{"SA2","Field","address", "addressB",;
							{;
								{"address"						, ""											},;
								{"number"						, ""											},;
								{"complement"					, ""											},;
								{"district"						, ""											},;
								{"zipCode"						, ""  											},;
								{"region"						, ""											},;
								{"poBox"						, ""											},;
								{"mainAddress"					, "Exp:.F."										},;
								{"shippingAddress"				, "Exp:.F."										},;
								{"billingAddress"				, "Exp:.T."										};
							},;
					}		

	aStrCidC   	:= 	{"SA2","Field","city", "cityB",;
							{;
								{"cityCode"						, ""											},;
								{"cityInternalId"				, ""											},;
								{"cityDescription"				, ""											};
							},;
					}

	aStrEstC   	:= 	{"SA2","Field","state", "stateB",;
							{;
								{"stateId"						, ""											},;
								{"stateInternalId"				, ""											},;
								{"stateDescription"				, ""											};
							},;
					}

	aStrConC   	:= 	{"SA2","Field","country", "countryB",;
							{;
								{"countryCode"					, ""											},;
								{"countryInternalId"			, ""											},;
								{"countryDescription"			, ""											};
							},;
					}


	aStructAlias  := {aStrSA2, aStrMktSeg, aStrGovInfo, aStrInfoIE, aStrInfoIM, aStrInfoC, aStrInfoPS, aStrInfoRG, aStrEndM, aStrCidM,;
	 aStrEstM, aStrConM, aStrEndS, aStrCidS, aStrEstS, aStrConS, aStrComInfo, aStrContacts, aStrBankInf, aStrFiscal, aStrCredInf, aStrVendType,;
	 aStrTaxPayer, aStrBillInfo, aStrEndC, aStrCidC, aStrEstC, aStrConC,aStrContCom,aStrContEnd,aStrCidCt,aStrEstCt,aStrConCT}

	aApiMap := {"MATS020","items","3.000","MATS020",aStructAlias, "items"}

Return aApiMap

/*/{Protheus.doc} M020GRVF
Função para tratar as informações bancárias do fornecedor

@param 		cFILFil		, Filial atual referente a tabela FIL
@param 		cCode		, Código do fornecedor
@param 		cLoja		, Loja do fornecedor
@param 		aContasFIL	, Vetor com as contas do fornecedor
@return 	lRet		, Retorna se salvou ou não a FIL
@author		Squad Faturamento/CRM
@since		29/08/2018
@version	12.1.17
/*/

Static Function M020GRVF(cFILFil, cCodigo, cLoja, aCabBCO)
	
	Local nI		:= 0
	Local nPosBco	:= 0
	Local nPosAg	:= 0
	Local nPosDvAg	:= 0
	Local nPosCta	:= 0
	Local nPosDvCta	:= 0
	Local nPosTpCta	:= 0
	Local nPosMain	:= 0
	Local nPosMoeda	:= 0
	
	M020DELF(cFILFil, cCodigo, cLoja)

	For nI := 1 To Len(aCabBCO)

		nPosBco		:= Ascan(aCabBCO[nI],{|x|AllTrim(x[1])=="FIL_BANCO"	})
		nPosAg		:= Ascan(aCabBCO[nI],{|x|AllTrim(x[1])=="FIL_AGENCI"})
		nPosDvAg	:= Ascan(aCabBCO[nI],{|x|AllTrim(x[1])=="FIL_DVAGE"	})
		nPosCta		:= Ascan(aCabBCO[nI],{|x|AllTrim(x[1])=="FIL_CONTA"	})
		nPosDvCta	:= Ascan(aCabBCO[nI],{|x|AllTrim(x[1])=="FIL_DVCTA"	})
		nPosTpCta	:= Ascan(aCabBCO[nI],{|x|AllTrim(x[1])=="FIL_TIPCTA"})
		nPosMain	:= Ascan(aCabBCO[nI],{|x|AllTrim(x[1])=="FIL_TIPO"	})
		nPosMoeda	:= Ascan(aCabBCO[nI],{|x|AllTrim(x[1])=="FIL_MOEDA"	})

		RecLock( "FIL", .T. )
		FIL->FIL_FILIAL := cFILFil
		FIL->FIL_FORNEC := cCodigo
		FIL->FIL_LOJA 	:= cLoja

		If nPosBco > 0
			FIL->FIL_BANCO 	:= aCabBCo[nI,nPosBco,2]
		Endif

		If nPosAg > 0
			FIL->FIL_AGENCI := aCabBCo[nI,nPosAg,2]
		Endif

		If nPosDvAg > 0
			FIL->FIL_DVAGE 	:= aCabBCo[nI,nPosDvAg,2]
		Endif

		If nPosCta > 0
			FIL->FIL_CONTA 	:= aCabBCo[nI,nPosCta,2]
		Endif

		If nPosDvCta > 0
			FIL->FIL_DVCTA 	:= aCabBCo[nI,nPosDvCta,2]
		Endif

		If nPosTpCta > 0
			FIL->FIL_TIPCTA := aCabBCo[nI,nPosTpCta,2]
		Endif

		If nPosMain > 0
			FIL->FIL_TIPO 	:= aCabBCo[nI,nPosMain,2]
		Endif

		If nPosMoeda > 0
			FIL->FIL_MOEDA 	:= aCabBCo[nI,nPosMoeda,2]
		Endif
		
		FIL->( MsUnLock() )
	Next nI

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} M020DELF
Função para deletar as informações bancárias do fornecedor

@param 		cFILFil	, Filial atual referente a tabela FIL
@param 		cCode	, Código do fornecedor
@param 		cLoja	, Loja do fornecedor
@author 	Squad Faturamento/CRM
@since 		29/08/2018
@version 	12.1.17
/*/
//-------------------------------------------------------------------
Static Function M020DELF ( cFILFil, cCodigo, cLoja )

	Local aAreaAnt := GetArea()

	dbSelectArea("FIL")
	dbSetOrder(1) //FIL_FILIAL+FIL_FORNEC+FIL_LOJA+FIL_TIPO+FIL_BANCO+FIL_AGENCI+FIL_CONTA
	IF MsSeek( cFILFil+cCodigo+cLoja )
		While FIL->( !EOF() ) .AND. FIL_FILIAL == cFILFil .AND. FIL_FORNEC == cCodigo .AND. FIL_LOJA == cLoja
			RecLock( "FIL", .F. )
			FIL->( dbDelete() )
			FIL->( msUnlock() )
			FIL->( dbSkip() )
		EndDo
	Endif

	RestArea( aAreaAnt )
	aSize(aAreaAnt, 0)

Return Nil