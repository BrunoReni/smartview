#INCLUDE "PROTHEUS.CH"  
#INCLUDE "TOTVS.CH" 
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWADAPTEREAI.CH"
#INCLUDE "MATI120.CH"

//----------------------------------------------------------------------------------
/*/{Protheus.doc} MATI120
Funcao de integracao com o adapter EAI para envio e recebimento do
Pedido de Compra (SC7/SCH/AJ7) utilizando o conceito de mensagem unica
(Order).

@param   cXML          Variavel com conteudo xml para envio/recebimento.
@param   nTypeTrans    Tipo de transacao. (Envio/Recebimento)
@param   cTypeMessage  Tipo de mensagem. (Business Type, WhoIs, etc)

@author  Leandro Luiz da Cruz
@version P11
@since   19/04/2013
@return  aRet - Array contendo o resultado da execucao e a mensagem Xml de retorno.
         aRet[1] - (boolean) Indica o resultado da execução da função
         aRet[2] - (caracter) Mensagem Xml para envio

@obs     O método irá retornar um objeto do tipo TOTVSBusinessEvent caso
         o tipo da mensagem seja EAI_BUSINESS_EVENT ou um tipo
         TOTVSBusinessRequest caso a mensagem seja do tipo TOTVSBusinessRequest.
         O tipo da classe pode ser definido com a função EAI_BUSINESS_REQUEST. 
/*/
//----------------------------------------------------------------------------------
Function MATI120(cXML, nTypeTrans, cTypeMessage, cVersion)

Local cVersao	:= ""
Local lRet		:= .T.
Local cXmlRet	:= ""
Local cNameMsg	:= "ORDER"
Local aRet		:= {} 
   
//Busca versão de envio e/ou recebimento
cVersao := StrTokArr(cVersion, ".")[1]

If nTypeTrans == TRANS_RECEIVE
	If cTypeMessage == EAI_MESSAGE_BUSINESS .Or. cTypeMessage == EAI_MESSAGE_RESPONSE
		If cVersao == "2"
			aRet := v2000(cXml, nTypeTrans, cTypeMessage)
		ElseIf cVersao == "3" .Or. cVersao == "4"
			aRet := v3002(cXml, nTypeTrans, cTypeMessage)
		Else
			lRet := .F.
			cXmlRet := STR0036 // "A versão da mensagem informada não foi implementada!"
		EndIf
	ElseIf cTypeMessage == EAI_MESSAGE_WHOIS
		aRet := v3002(cXml, nTypeTrans, cTypeMessage)
	EndIf
ElseIf nTypeTrans == TRANS_SEND
	If cVersao == "2"
		aRet := v2000(cXml, nTypeTrans, cTypeMessage)
	ElseIf cVersao == "3" .Or. cVersao == "4"
		aRet := v3002(cXml, nTypeTrans, cTypeMessage)
	Else
		lRet := .F.
		cXmlRet := STR0039 // "A versão da mensagem informada não foi implementada!"
	EndIf
Endif

If Len(aRet) > 0
	lRet 	:= aRet[1]
	cXmlRet := aRet[2]
Endif	

Return {lRet, cXmlRet, cNameMsg}

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³v2000     ºAutor  ³Jandir Deodato       º Data ³ 02/04/2012 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±³Descricao ³ M.U Cadastramento de Pedido de Compra                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ MATI120(cXml, nType, cTypeMsg)                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ºDesc.     ³Função para a interação com EAI                             º±±
±±º          ³envio e recebimento                                         º±±
±±º          ³                                                            º±±
±±º          ³                                                            º±±
±±º          ³ Pedido de Compra                                           º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function v2000(cXml, nType, cTypeMsg)

Local lRet				:= .T.
Local cXmlRet			:= ''
Local cEvent			:= 'upsert'
Local cErroXml			:= ""
Local cWarnXml			:= ""
Local aArea				:= GetArea()
Local aCab				:= {}
Local aItens			:= {}
Local aItensTemp		:= {}
Local aItensRat			:= {}
Local cFili				:= CriaVar("C7_FILIAL")
Local cLoja				 // variaveis utilizadas para melhor visualização do seek 
Local cValMoeda 		:= ''
Local cValProd			:= ''
Local cTipo				:= ''
Local cEmissao			:= ''
Local cC7_num			:= CriaVar("C7_NUM")
Local nValdesc			:= 0
Local cUSER				:= RetCodUsr()
Local cValCusto			:= ''
Local cCusto			:= ''
Local cVendor			
Local cValVendor		:= ''
Local nMoeda				
Local cLogErro			:= ""
Local cValCond			:= ''
Local aErroAuto			:= {}
Local nX				:= 0
Local nY
Local cVersaoCust		:= '1.000' ///adapter de centro de custo
Local aCusto:={}
Local nX2				:= 0
Local nX3				:= 0
Local nCount2			:= 0
Local nCount3			:= 0
Local nCount			:= 0
Local aAreaSC7
Local aAreaSA2			
Local cQuery
Local cAliasTMP
Local cMarca
Local cValext
Local cValInt
Local cAlias	
Local aAux:={}		
Local aValMoeda:={}	
Local cCampo				
Local nOpcExec
Local cMuVenVers		:= '1.000' //versao da mensagem unica de fornecedor
Local nQtd				:= 0
Local nVlrUni			:= 0
Local nVlrTotal			:= 0
Local lMktPlace 		:= SuperGetMv("MV_MKPLACE",.F.,.F.)
Local aValInt           := {}
Local cRetPE			:= ''
Private oXmlmati120		:= nil
Private oXmlDisc		:= nil
Private oXmlChild		:= nil
Private lMsErroAuto		:= .F.
Private lMsHelpAuto		:= .T.
Private lAutoErrNoFile	:= .T.
Private cMat120Num		:= ' '//variavel utilizada para receber o valor do pedido enviado via execauto, pois 

dbSelectArea("SC7")
aAreaSC7:= SC7->(GetArea())
SC7->(dbSetOrder(1))
dbSelectArea("SA2")
aAreaSA2 := SA2->(GetArea())
SA2->(dbSetOrder(1)) //A2_FILIAL+A2_COD+A2_LOJA
cMuVenVers:=AllTrim(PmsMsgUVer('CUSTOMERVENDOR','MATA020'))
Do Case 
	// verificação do tipo de transação recebimento ou envio
	// trata o envio
	Case  nType == TRANS_SEND 
	SC7->(dbSetOrder(1))
	SC7->(dbSeek(xFilial("SC7")+cA120Num))
		If ( INCLUI .OR. ALTERA )
			cXMLRet :='<BusinessEvent>'
			cXMLRet +=		'<Entity>Order</Entity>'
			cXMLRet +=		'<Event>' + cEvent + '</Event>'	//variável upsert para atualização ou delete para exclusao
			cXMLRet +=		'<Identification>'
			cXMLRet +=         '<key name="InternalId">' + xFilial('SC7')+SC7->C7_NUM+'</key>'
			cXMLRet +=     '</Identification>'
			cXMLRet +='</BusinessEvent>'
			cXMLRet +='<BusinessContent>'
			cXmlRet +=		'<OrderPurpose>1</OrderPurpose>'//1 - pedido de compra
			cXMLRet +=		'<CompanyId>'  		+ (cEmpAnt) + '</CompanyId>'
			cXMLRet +=		'<BranchId>' 	+ xFilial('SC7') + '</BranchId>'
			cXMLRet +=		'<CompanyInternalId>' + (cEmpAnt)+ "|"+xFilial('SC7') + '</CompanyInternalId>'
			cXMLRet +=		'<OrderId>' 	+ (SC7->C7_NUM) + '</OrderId>'
			cXMLRet +=		'<InternalId>' 	+ cEmpAnt+ "|" +xFilial('SC7')+ "|" +SC7->C7_NUM + '</InternalId>'			
			cXMLRet +=		'<CustomerOrderId>' 	+IntForExt(, , SC7->C7_FORNECE, SC7->C7_LOJA, cMuVenVers)[2] +'</CustomerOrderId>'
			
			SA2->(dbSeek(xFilial("SC7")+SC7->C7_FORNECE+SC7->C7_LOJA))
			cXMLRet +=		'<CustomerGovInfo>' 	+ (SA2->A2_CGC) + '</CustomerGovInfo>'
			cXMLRet +=		'<CustomerInternalId>' + IntForExt(, , SC7->C7_FORNECE, SC7->C7_LOJA)[2]+'</CustomerInternalId>'
			If Len( Separa(SC7->C7_ACCNUM,"|") ) > 1
				cXMLRet +=      '<contractnumber>' + Separa( SC7->C7_ACCNUM , "|" )[1] + "|" + Separa( SC7->C7_ACCNUM , "|" )[2] + '</contractnumber>'
			EndIf			
		
		If lMktPlace
			cXMLRet +=    '<CurrencyCode>' + PadR(RTrim(cValToChar(SC7->C7_MOEDA)), 2, '0') + '</CurrencyCode>'
			cXMLRet +=    '<CurrencyId>' + '|' + '|'+ PadL(RTrim(cValToChar(SC7->C7_MOEDA)), 3, '0') + '</CurrencyId>'
			cXMLRet +=    '<CurrencyRate>' + RTrim(cValToChar(SC7->C7_TXMOEDA)) + '</CurrencyRate>'
		Else
			cXMLRet +=		'<CurrencyCode>' 	+C40MontInt(,Iif((SC7->C7_MOEDA<10),STrZero(SC7->C7_MOEDA,TAMSx3("CTO_MOEDA")[1],0),cValtoChar(SC7->C7_MOEDA))) + '</CurrencyCode>'
			If SC7->C7_MOEDA < 10 
				cXMLRet +=		'<CurrencyId>' 	+ cEmpAnt + "|" + xFilial("CTO") + "|" + StrZero(SC7->C7_MOEDA,TamSX3("CTO_MOEDA")[1],0) + '</CurrencyId>'
			Else
				cXMLRet +=		'<CurrencyId>' 	+ cEmpAnt + "|" + xFilial("CTO") + "|" + cValToChar(SC7->C7_MOEDA) + '</CurrencyId>'
			EndIf
			cXMLRet +=		'<CurrencyRate>' 	+(cValToChar( SC7->C7_TXMOEDA)) + '</CurrencyRate>'
		Endif

			cXMLRet +=		'<PaymentTermCode>' 	+ RTrim(SC7->C7_COND) + '</PaymentTermCode>'
			cXMLRet +=		'<PaymentConditionInternalId>' + cEmpAnt + "|" + AllTrim(xFilial("SE4"))+"|"+ RTrim(SC7->C7_COND) + '</PaymentConditionInternalId>'						
			cXMLRet +=		'<RegisterDate>' 	+INTDTANO(SC7->C7_EMISSAO) + '</RegisterDate>'
			cXMLRet +=		'<UserInternalId>' 	+ IntUserReq() + '</UserInternalId>'
		    If AllTrim(SC7->C7_FREPPCC) == "C"
				cXMLRet +=		'<FreightType>1</FreightType>'
			ElseIf AllTrim(SC7->C7_FREPPCC) == "F"
				cXMLRet +=		'<FreightType>2</FreightType>'
			Else
				cXMLRet +=		'<FreightType>3</FreightType>'
			EndIf	
			
			If lMktPlace
				cXmlRet+=		'<OTHER>'
				cXmlRet+=			'<ADDFIELDS>'
				cXmlRet+=				'<ADDFIELD>'
				cXmlRet+=					'<field>TipoOrigem</field>'
				cXmlRet+=					'<value>' + QtType() + '</value>'
				cXmlRet+=				'</ADDFIELD>'
				
				//--------------------------------------
				// Ponto de entrada para adicionar dados 
				// ao cabecalho do pedido de compra
				//--------------------------------------
				If Existblock( 'MTI120PC')    
					cRetPE:= Execblock( "MTI120PC", .F., .F. )
					If ValType(cRetPE) = 'C'
						cXMLRet += cRetPE
					EndIf
				EndIf	
				
				cXmlRet+=			'</ADDFIELDS>'
				cXmlRet+=		'</OTHER>'
			EndIf
						
			cXMLRet +=		'<SalesOrderItens>' 				
			cAliasTMP:=GetNextAlias()
			cQuery := "Select C7_NUM,C7_ITEM,C7_PRODUTO,C7_UM,C7_DESCRI,C7_QUANT,C7_PRECO,C7_TOTAL,C7_CC,C7_DATPRF,C7_VLDESC,"
			cQuery +="C7_VALFRE,C7_SEGURO,C7_OBS  From  " + RetSqlName("SC7")
			cQuery +=" where C7_FILIAL = '" + xFilial("SC7")
			cQuery += "' AND C7_NUM = '" + SC7->C7_NUM
			cQuery +=	"'  Order By C7_ITEM"
			cQuery := ChangeQuery(cQuery)
			
			If Select(cAliasTMP)>0
				(cAliasTMP)->(dbCloseArea())
			Endif
			
			dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasTMP, .T., .T. )
			If Select(cAliasTMP)>0            
				(cAliasTMP)->(dbGoTop())
				While (cAliasTMP)->(!EOF())
					SC7->(dbSetOrder(1))
					SC7->(DbSeek(xFilial("SC7")+(cAliasTmp)->C7_NUM+(cAliasTmp)->C7_ITEM))
			   		cXmlRet+=			'<Item>'
			   		cXmlRet+=				'<CompanyId>'+cEmpAnt+'</CompanyId>'
			  		cXmlRet+=				'<BranchId>' +xFilial("SC7")+'</BranchId>'
			   		cXmlRet+=				'<OrderId>' +xFilial("SC7")+((cAliasTmp)->C7_NUM)+'</OrderId>'
			   		cXMLRet +=				'<OrderItem>'+ ((cAliasTmp)->C7_ITEM) +'</OrderItem>'
			   		cXMLRet +=				'<ItemCode>'+ ((cAliasTmp)->C7_PRODUTO)+'</ItemCode>'
					cXMLRet +=				'<ItemInternalId>'+ cEmpAnt +"|"+ RTrim(xFilial("SB1"))+"|"+ RTrim((cAliasTmp)->C7_PRODUTO)+'</ItemInternalId>'
					cXMLRet +=      		'<contractnumber>' + SC7->C7_ACCITEM+ '</contractnumber>'			   		
			   		cXmlRet+=				'<itemunitofmeasure>'+((cAliasTmp)->C7_UM)+'</itemunitofmeasure>'
			   		cXmlRet+=				'<ItemDescription>'+Posicione("SB1",1,xFilial("SB1")+((cAliasTmp)->C7_PRODUTO),"B1_DESC")+'</ItemDescription>'
			   		cXmlRet+=      			'<Quantity>'+(cValToChar((cAliasTmp)->C7_QUANT))+'</Quantity>'
			   		cXmlRet+=				'<UnityPrice>'+(cValToChar((cAliasTmp)->C7_PRECO))+'</UnityPrice>'
			   		cXmlRet+=				'<TotalPrice>'+(cValToChar((cAliasTmp)->C7_TOTAL))+'</TotalPrice>'
					If !lMktPlace
						cVersaoCust:=AllTrim(PmsMsgUVer('COSTCENTER','CTBA030'))
						
						If !Empty(((cAliasTmp)->C7_CC))
							cXmlRet+=				'<CostCenterCode>'+((cAliasTmp)->C7_CC)+'</CostCenterCode>'
							cXmlRet+=				'<CostCenterInternalId>' + IntCusExt(, , ((cAliasTmp)->C7_CC), cVersaoCust)[2] + '</CostCenterInternalId>'
						Else
							cXmlRet+=				'<CostCenterCode/>'
							cXmlRet+=				'<CostCenterInternalId/>'
						Endif
					Else
						If !Empty(((cAliasTmp)->C7_CC)) 
							cXmlRet+=				'<CostCenterCode>'+((cAliasTmp)->C7_CC)+'</CostCenterCode>'
							cXmlRet+=				'<CostCenterInternalId>' + IntCusExt(, , ((cAliasTmp)->C7_CC), cVersaoCust)[2] + '</CostCenterInternalId>'
						Else
							cXmlRet+=				'<CostCenterCode/>'
							cXmlRet+=				'<CostCenterInternalId/>'
						EndIf
					Endif
					cXmlRet+=				'<DeliveryDate>'+INTDTANO((cAliasTmp)->C7_DATPRF)+'</DeliveryDate>'
					cXmlRet+=				'<ItemDiscounts>'
					cXmlRet+=				'<ItemDiscount>'+(cValToChar((cAliasTmp)->C7_VLDESC))+'</ItemDiscount>'
					cXmlRet+=				'</ItemDiscounts>'
					cXmlRet+=				'<FreightValue>'+(cValToChar((cAliasTmp)->C7_VALFRE))+'</FreightValue>'
					cXmlRet+=				'<InsuranceValue>'+(cValToChar((cAliasTmp)->C7_SEGURO))+'</InsuranceValue>'
					cXmlRet+=				'<UnitWeight></UnitWeight>'
					cXmlRet+=				'<observation>'+((cAliasTmp)->C7_OBS)+'</observation>'

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Local de entrega das mercadorias |
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				  	cXmlRet += 				'<CROSSDOCKING>'
				 	cXmlRet +=					 '<CROSSDOCKING_ITEM>'
					cXmlRet += 						'<dhinidelivery>'+INTDTANO(SC7->C7_DATPRF)+"T00:00:00"+'</dhinidelivery>'
					cXmlRet += 						'<dhfindelivery>'+INTDTANO(SC7->C7_DATPRF)+"T23:59:00"+'</dhfindelivery>'
					cXmlRet += 						'<quantdelivery>'+AllTrim(Str(SC7->(C7_QUANT-C7_QUJE)))+'</quantdelivery>'	
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Unidade de Medida do Item do Ped.|
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					cUnidMed := A120IUnMed(AllTrim(SC7->C7_UM))
					If !Empty(cUnidMed)
						cXmlRet += 					'<mensuunit>'+cUnidMed+'</mensuunit>'
					EndIf
					cXmlRet += 						'<orderline>'+SC7->C7_ITEM+'</orderline>'
				 	cXmlRet += 					'</CROSSDOCKING_ITEM>'
				  	cXmlRet += 				'</CROSSDOCKING>' 
					
					If lMktPlace
						cXmlRet+=				'<LISTOFTAXESITEM>'
						cXmlRet+=					'<VALUESANDTAXES>'
						cXmlRet+=						'<tpvalue>1</tpvalue>'
						cXmlRet+=						'<tpreasondescandtax>1</tpreasondescandtax>'
						cXmlRet+=						'<valuedescandtaxes>1</valuedescandtaxes>'
						cXmlRet+=					'</VALUESANDTAXES>'
						cXmlRet+=				'</LISTOFTAXESITEM>'
					EndIf
															
					//-- Rateio do Pedido de Compra
					SCH->(DbSetOrder(1))
					If	SCH->(DbSeek(xFilial("SCH")+SC7->C7_NUM+SC7->C7_FORNECE+SC7->C7_LOJA+(cAliasTmp)->C7_ITEM))

						cXMLRet += '<ListOfApportionOrderItem>'

						While SCH->( !Eof() .And. SCH->CH_FILIAL+SCH->CH_PEDIDO+SCH->CH_FORNECE+SCH->CH_LOJA+SCH->CH_ITEMPD == xFilial("SCH")+SC7->C7_NUM+SC7->C7_FORNECE+SC7->C7_LOJA+(cAliasTmp)->C7_ITEM )

							cXMLRet += '<ApportionOrderItem>'

							cXMLRet += 	'<InternalId>' + cEmpAnt + '|' + xFilial('SCH') + '|' + SCH->CH_PEDIDO+ '|' + SCH->CH_FORNECE + '|' + SCH->CH_LOJA + '|' + SCH->CH_ITEMPD + '</InternalId>'
							cXMLRet += 	'<CostCenterInternalId>' + SCH->CH_CC + '</CostCenterInternalId>'
							cXMLRet += 	'<AccountantAcountInternalId>' + SCH->CH_CONTA + '</AccountantAcountInternalId>'
							cXMLRet += 	'<Percentual>' + cValToChar(SCH->CH_PERC) + '</Percentual>'

							cXMLRet += '</ApportionOrderItem>'

							SCH->(DbSkip())
						EndDo

						cXMLRet += '</ListOfApportionOrderItem>'
					EndIf

					cXmlRet+=			'</Item>'
					If lMktPlace
						SC7->(dbSetOrder(1))
						If SC7->(DbSeek(xFilial("SC7")+(cAliasTmp)->C7_NUM+(cAliasTmp)->C7_ITEM))
							RecLock("SC7")
							SC7->C7_ACCPROC := "1"
							MsUnlock()
						EndIf
					EndIf
					(cAliasTmp)->(dbSkip())
				EndDo
				(cAliasTMP)->(dbCloseArea())
			EndIf
			cXMLRet +=		'</SalesOrderItens>'
			cXMLRet +='</BusinessContent>'
		Else
			cEvent := 'delete'
			cXMLRet :='<BusinessEvent>'
			cXMLRet +=		'<Entity>Order</Entity>'
			cXMLRet +=		'<Event>' + cEvent + '</Event>'	//variável upsert para atualização ou delete para exclusao
			cXMLRet +=		'<Identification>'
			cXMLRet +=         '<key name="InternalId">' + xFilial('SC7')+cA120Num+'</key>'
			cXMLRet +=     '</Identification>'
			cXMLRet +='</BusinessEvent>'
			cXMLRet +='<BusinessContent>'
			cXmlRet +=		'<OrderPurpose>1</OrderPurpose>'//1 - pedido de compra
			cXMLRet +=		'<CompanyId>'+ cEmpAnt+ '</CompanyId>'
			cXMLRet +=		'<BranchId>'+xFilial('SC7')+' </BranchId>'
			cXMLRet +='</BusinessContent>'
			cAlias:="SC7"
			cCampo:="C7_NUM"
			CFGA070Mnt(,cAlias,cCampo,, xFilial('SC7')+cA120Num, .T. )
		Endif
	Case  nType == TRANS_RECEIVE 
		If cTypeMsg == EAI_MESSAGE_WHOIS
		cXMLRet := '2.000|3.001|3.002|3.004|3.005|3.006|3.007'
		ElseIf cTypeMsg == EAI_MESSAGE_RESPONSE 
			oXmlmati120 := XmlParser(cXml, "_", @cErroXml, @cWarnXml)
			If oXmlMati120 <> Nil .And. Empty(cErroXml) .And. Empty(cWarnXml)
				cAlias:= "SC7"
				cCampo:= "C7_NUM"
				
				If Type("oXmlmati120:_TotvsMessage:_MessageInformation:_Product:_Name:Text") <> "U" 					
					cMarca :=  oXmlmati120:_TotvsMessage:_MessageInformation:_Product:_Name:Text
				EndIf
				If Type("oXmlmati120:_TOTVSMessage:_ResponseMessage:_ReturnContent:_DestinationInternalId:Text") <> "U"	
					cValExt := oXmlmati120:_TOTVSMessage:_ResponseMessage:_ReturnContent:_DestinationInternalId:Text
				EndIf
				If Type("oXmlmati120:_TOTVSMessage:_ResponseMessage:_ReturnContent:_OriginInternalId:Text") <> "U"	
					cValInt := oXmlmati120:_TOTVSMessage:_ResponseMessage:_ReturnContent:_OriginInternalId:Text
				EndIf 
				If Empty(cValInt) .And. Type("oXmlmati120:_TOTVSMessage:_ResponseMessage:_ReturnContent:_OriginalInternalId:Text") <> "U"	
					cValInt := oXmlmati120:_TOTVSMessage:_ResponseMessage:_ReturnContent:_OriginalInternalId:Text
				EndIf 
				If !Empty(cValExt)
					If !Empty(cValInt)
						CFGA070Mnt( cMarca, cAlias,cCampo, cValExt, cValInt )
						
						If AllTrim(PmsMsgUVer('ORDER','MATA120')) == "2.000"
							cPC		 := SubStr(cValInt,TamSx3("C7_FILIAL")[1]+1,TamSx3("C7_NUM")[1])
						Elseif AllTrim(PmsMsgUVer('ORDER','MATA120')) $ "3.000|3.001|3.002|3.004|3.005|3.006|3.007"
							aValInt := Separa(cValInt,"|")
							cPC		 := aValInt[3]
						Endif
						
						If SC7->( DbSeek( xFilial("SC7") + cPC  ) )
							While SC7->( !EOF() )  .And. SC7->(C7_FILIAL+C7_NUM) == xFilial("SC7")+cPC
								RecLock("SC7",.F.)
									SC7->C7_ACCNUM   := cValExt
								MsUnLock()
								SC7->(DbSkip())										
							EndDo
						EndIf
					EndIf
				Endif
			Else
				lRet:=.F.
				cXmlRet+='<Message type="ERROR" code="c2">'+STR0002+'</Message>'//erro no xml
			EndIf	
	
		ElseIf ( cTypeMsg == EAI_MESSAGE_BUSINESS )
			
			oXmlmati120 := XmlParser(cXml, "_", @cErroXml, @cWarnXml)
			If oXmlmati120 <> Nil .And. Empty(cErroXml) .And. Empty(cWarnXml)
				If lMktPlace .And. Type("oXmlmati120:_TOTVSMessage:_BusinessMessage:_BusinessContent:_funcmsgorder") <> "U"
					If Type("oXmlmati120:_TOTVSMessage:_BusinessMessage:_BusinessContent:_InternalId:Text" )<> "U"
						cNumPc :=  PadR( StrToArray( oXmlmati120:_TOTVSMessage:_BusinessMessage:_BusinessContent:_InternalId:Text , "|")[3] , TamSX3('C7_NUM')[1])
						If oXmlmati120:_TOTVSMessage:_BusinessMessage:_BusinessContent:_funcmsgorder:text == "42" // Confirmação (Utilizada no Paradigma)
							If SC7->( DbSeek( xFilial("SC7") + cNumPc  ) )
								While SC7->( !EOF() )  .And. SC7->(C7_FILIAL+C7_NUM) == xFilial("SC7")+cNumPc
									RecLock("SC7",.F.)
										SC7->C7_ACCPROC := '2'
									MsUnLock()
									SC7->(DbSkip())										
								EndDo
							EndIf
						ElseIf oXmlmati120:_TOTVSMessage:_BusinessMessage:_BusinessContent:_funcmsgorder:text == '43' // Recusa (Utilizada no Paradigma)
							AADD(aCab  ,{"C7_NUM"	, cNumPc ,Nil})
							AADD(aItens,{{"C7_NUM"	, cNumPc ,Nil}})    
							lMsErroAuto := .F.
								       
							SC7->( dbSetOrder(1) )	
							If SC7->( DbSeek( xFilial("SC7") + cNumPc ) )    
								cNumCot := SC7->C7_NUMCOT 	
								cFornec := SC7->C7_FORNECE 
								cLoja   := SC7->C7_LOJA   
								cProduto:= SC7->C7_PRODUTO
												
								SC8->( dbSetOrder(3) ) 
								SC8->( DbSeek( xFilial("SC8") + cNumCot  + cFornec + cLoja + cNumPc ) )  		
								lMSErroAuto	:= .F.   
								MSExecAuto({|v,x,y,z| MATA120(v,x,y,z)},1,aCab,aItens,5)
									
								If lMsErroAuto	
									aErro := GetAutoGRLog()
									For nY := 1 To Len(aErro)
										cXmlRet += aErro[nY] +CRLF
									Next nY
									lRet := .F.
								Endif
									
								aCab   :={}
								aItens :={}                              
									
								aAdd(aCab,{"C8_NUM"    ,cNumCot,NIL})   
								aAdd(aCab,{"COMPACC"   ,""     ,NIL})   
								aAdd(aCab,{"C8_FORNECE",cFornec,Nil})    
								aAdd(aCab,{"C8_LOJA"   ,cLoja  ,Nil})
																									
								lMSErroAuto	:= .F.
								lAutoErrNoFile := .T.	      
								MSExecAuto({|x,y,z| MATA150(x,y,z)},aCab,aItens,5)	
									
								If lMsErroAuto	
									aErro := GetAutoGRLog()
									For nY := 1 To Len(aErro)
										cXmlRet += aErro[nY] +CRLF
									Next nY	
									lRet := .F.
								Else
									Return {.T.,"OK"}
								Endif									
										
							EndIf             
																
						EndIf
							
					EndIf					   					
				ElseIf Type("oXmlmati120:_TOTVSMessage:_BusinessMessage:_BusinessContent:_OrderPurpose:Text") # "U"
					If AllTrim(oXmlmati120:_TOTVSMessage:_BusinessMessage:_BusinessContent:_OrderPurpose:Text) == "1"
						cAlias:="SC7"
						cCampo:="C7_NUM"
						If Type("oXmlmati120:_TotvsMessage:_MessageInformation:_Product:_Name:Text") <> "U" 					
							cMarca :=  oXmlmati120:_TotvsMessage:_MessageInformation:_Product:_Name:Text
						EndIf
						If Type("oXmlmati120:_TOTVSMessage:_BusinessMessage:_BusinessEvent:_Identification:_Key:Text") <> "U"
							cValExt := oXmlmati120:_TOTVSMessage:_BusinessMessage:_BusinessEvent:_Identification:_Key:Text
						EndIf   
						If !Empty(cValExt)
							AADD(aCab,{"C7_FILIAL",xFilial('SC7'),NIL})
							cValInt := CFGA070INT( cMarca,  cAlias ,cCampo, cValExt )									  
							If !Empty(cValInt)
								cC7_num := Substr(cValInt,TamSX3("C7_FILIAL")[1]+1,TamSX3("C7_NUM")[1])
								If Upper(oXmlmati120:_TOTVSMessage:_BusinessMessage:_BusinessEvent:_Event:Text) == "UPSERT" 							
									If SC7->(dbSeek(xFilial("SC7")+cC7_num))
										Aadd(aCab,{"C7_NUM" , cC7_num , Nil })
										nOpcExec := 4	
									Else
										lRet:=.F.
										cXmlRet+='<Message type="ERROR" code="c2">'+STR0004+'</Message>'//Erro no processamento da operação. Verifique o de/para do pedido.
									EndIf	
								ElseIf Upper(oXmlmati120:_TOTVSMessage:_BusinessMessage:_BusinessEvent:_Event:Text) == "DELETE"  					
									nOpcExec := 5  
									If  SC7->(dbSeek(xFilial("SC7")+cC7_num))
										Aadd(aCab,{"C7_NUM" , cC7_num , Nil })
									Else
										lRet:=.F.
										cXmlRet+='<Message type="ERROR" code="c2">'+STR0005+'</Message>'//"Pedido não encontrado no Protheus."
									EndIf
								EndIf
							ElseIf Upper(oXmlmati120:_TOTVSMessage:_BusinessMessage:_BusinessEvent:_Event:Text) == "UPSERT"
								Aadd(aCab,{"C7_NUM" , "" , Nil })
								nOpcExec := 3
							ElseIf Upper(oXmlmati120:_TOTVSMessage:_BusinessMessage:_BusinessEvent:_Event:Text) == "DELETE"
								lRet:=.F.
								cXmlRet+='<Message type="ERROR" code="c2">'+STR0005+'</Message>'//"Pedido não encontrado no Protheus."
							Endif
							If lRet
								If nOpcExec # 5
									If Type("oXmlmati120:_TOTVSMessage:_BusinessMessage:_BusinessContent:_CustomerOrderId:Text") # "U"
										If cMuVenVers=='1.000'
											cValVendor:= CFGA070INT( cMarca,  "SA2" ,"A2_COD", oXmlmati120:_TOTVSMessage:_BusinessMessage:_BusinessContent:_CustomerOrderId:Text )	
											cVendor:=SubStr(cValVendor,1,TamSX3("C7_FORNECE")[1])
											cLoja:= SubStr(cValVendor,TamSX3("C7_FORNECE")[1]+1,TamSX3("C7_LOJA")[1])
										ElseIF cMuVenVers $ '2.000|2.001|2.002|2.003|2.004'
											aAux:=IntForInt(oXmlmati120:_TOTVSMessage:_BusinessMessage:_BusinessContent:_CustomerOrderId:Text , cMarca, cMuVenVers)
											If aAux[1]
												cVendor:=Padr(aAux[2][3],TamSx3("A2_COD")[1])
												cLoja:=Padr(aAux[2][4],TamSx3("A2_LOJA")[1])
											Endif
										Endif
										AADD(aCab,{"C7_FORNECE",cVendor,NIL})
										AADD(aCab,{"C7_LOJA",cLoja,NIL})
									EndIf
									IF Empty (cVendor) .or. Empty(cLoja)
										lRet:=.F.
										cXmlRet+='<Message type="ERROR" code="c2">'+STR0006+'</Message>'//"Cliente/Fornecedor ou Loja inválido. Verifique!"
									Endif
									If Type("oXmlmati120:_TOTVSMessage:_BusinessMessage:_BusinessContent:_CurrencyCode:Text") # "U"
										aValMoeda:= C40GetInt(oXmlmati120:_TOTVSMessage:_BusinessMessage:_BusinessContent:_CurrencyCode:Text, cMarca)
										
										If aValMoeda[1]
											cValMoeda:=aValMoeda[2][2]+aValMoeda[2][3]
										Endif
										
										If !Empty (cValMoeda).and. SubStr(cValMoeda,TamSx3("CTO_FILIAL")[1]+1,TamSx3("CTO_MOEDA")[1]) =="0"
											nMoeda:= Val(SubStr(cValMoeda,TamSx3("CTO_FILIAL")[1]+2,1))
										ElseIf !Empty (cValMoeda).and. !(SubStr(cValMoeda,TamSx3("CTO_FILIAL")[1]+1,TamSx3("CTO_MOEDA")[1]) =="0")
											nMoeda:= Val(SubStr(cValMoeda,TamSx3("CTO_FILIAL")[1]+1,TamSx3("CTO_MOEDA")[1]))
										Endif
									EndIf
									If Type("oXmlmati120:_TOTVSMessage:_BusinessMessage:_BusinessContent:_CurrencyRate:Text") # "U" .and.;
									!Empty(oXmlmati120:_TOTVSMessage:_BusinessMessage:_BusinessContent:_CurrencyRate:Text) 
										If !Empty(nMoeda)
											AADD(aCab,{"C7_MOEDA",nMoeda,NIL})
											AADD(aCab,{"C7_TXMOEDA",;
										 	Val(AllTrim(oXmlmati120:_TOTVSMessage:_BusinessMessage:_BusinessContent:_CurrencyRate:Text)),NIL})
										Else
											lRet:=.F.
											cXmlRet+='<Message type="ERROR" code="c2">'+STR0007+'</Message>'//"Foi Enviada Taxa da Moeda mas não a Moeda, ou a moeda nao existe no Protheus. Verifique."
										Endif
									ElseIf !Empty(nMoeda)
										lRet:=.F.
										cXmlRet+='<Message type="ERROR" code="c2">'+STR0008+'</Message>'//"Foi Enviada Moeda mas não a Taxa da Moeda. Verifique."
									Endif
									
									If Type("oXmlmati120:_TOTVSMessage:_BusinessMessage:_BusinessContent:_PaymentConditionInternalId:Text") # "U"
										cVerCondPgto := AllTrim(PmsMsgUVer('PAYMENTCONDITION','MATA360'))
										aCondPgto := IntConInt(oXmlmati120:_TOTVSMessage:_BusinessMessage:_BusinessContent:_PaymentConditionInternalId:Text, cMarca, cVerCondPgto)
										If aCondPgto[1]
											If cVerCondPgto == "1.000"
												cValCond := aCondPgto[2][2]
											Elseif cVerCondPgto == "2.000"
												cValCond := aCondPgto[2][3]
											Endif
											AADD(aCab,{"C7_COND",cValCond,NIL})
										Else
											If Type("oXmlmati120:_TOTVSMessage:_BusinessMessage:_BusinessContent:_PaymentTermCode:Text") # "U"
												AADD(aCab,{"C7_COND",oXmlmati120:_TOTVSMessage:_BusinessMessage:_BusinessContent:_PaymentTermCode:Text,NIL})
											Else
												lRet := .F.
												cXmlRet+='<Message type="ERROR" code="c2">Condição de pagamento não informada</Message>'
											Endif
										Endif
									Elseif Type("oXmlmati120:_TOTVSMessage:_BusinessMessage:_BusinessContent:_PaymentTermCode:Text") # "U"
										cValCond:=CFGA070INT( cMarca,  "SE4" ,"E4_CODIGO", oXmlmati120:_TOTVSMessage:_BusinessMessage:_BusinessContent:_PaymentTermCode:Text )	
										AADD(aCab,{"C7_COND",SubStr(cValCond,TamSX3("E4_FILIAL")[1]+1,TamSx3("E4_CODIGO")[1]),NIL})
									Else
										lRet := .F.
										cXmlRet+='<Message type="ERROR" code="c2">Condição de pagamento não informada</Message>'
									Endif
									
									If Type("oXmlmati120:_TOTVSMessage:_BusinessMessage:_BusinessContent:_RegisterDate:Text") # "U"
										cEmissao:=SubStr(oXmlmati120:_TOTVSMessage:_BusinessMessage:_BusinessContent:_RegisterDate:Text,1,4)+;
										Substr(oXmlmati120:_TOTVSMessage:_BusinessMessage:_BusinessContent:_RegisterDate:Text,6,2)+;
										SubStr(oXmlmati120:_TOTVSMessage:_BusinessMessage:_BusinessContent:_RegisterDate:Text,9,2)
										AADD(aCab,{"C7_EMISSAO",SToD(cEmissao),NIL})
									Endif   
										AADD(aCab,{"C7_TIPO",1,NIL}) 
									If Type("oXmlmati120:_TOTVSMessage:_BusinessMessage:_BusinessContent:_FreightType:Text") # "U"
										If AllTrim(oXmlmati120:_TOTVSMessage:_BusinessMessage:_BusinessContent:_FreightType:Text) == "1"
											AADD(aCab,{"C7_FREPPCC",;
											PadR("C",(TamSX3("C7_FREPPCC")[1]));
											,NIL})
										ElseIf AllTrim(oXmlmati120:_TOTVSMessage:_BusinessMessage:_BusinessContent:_FreightType:Text) == "2"
											AADD(aCab,{"C7_FREPPCC",;
											PadR("F",(TamSX3("C7_FREPPCC")[1]));
											,NIL})
										Endif 
									Endif  				
									AADD(aCab,{"C7_CONTATO"		, space(1), Nil})
									AADD(aCab,{"C7_FILENT"		, xFilial("SC7")	, Nil})
									//Tratamento dos itens do pedido				
									nX:=0
									If type("oXmlmati120:_TOTVSMessage:_BusinessMessage:_BusinessContent:_SalesOrderItens:_Item[1]")#"U"
										nCount:= Len( oXmlmati120:_TOTVSMessage:_BusinessMessage:_BusinessContent:_SalesOrderItens:_Item )
									Else
										nCount:=1
									Endif
									For nX :=1 to nCount
										nQtd:=0
										nVlrUni:=0
										nVlrTotal:=0
										nValDesc:=0
										aItensTemp := {}
										If nCount >1
											oXmlChild:= oXmlmati120:_TOTVSMessage:_BusinessMessage:_BusinessContent:_SalesOrderItens:_Item[nX]
										Else
											oXmlChild:= oXmlmati120:_TOTVSMessage:_BusinessMessage:_BusinessContent:_SalesOrderItens:_Item
										Endif
										If nOpcExec == 4 
											If SC7->(dbSeek(xFilial("SC7")+cC7_num+StrZero(nX,TamSX3("C7_ITEM")[1])))
												aadd( aItensTemp , {"LINPOS","C7_ITEM" , Padr(AllTrim(oXmlChild:_OrderItem:Text),TamSX3("C7_ITEM")[1])	, Nil } )
												aadd(aItensTemp,{"AUTDELETA","N",Nil})
											Else
												aadd( aItensTemp , {"C7_ITEM" , StrZero(nX,TamSX3("C7_ITEM")[1])	, Nil } )
											Endif
										Else 
											aadd( aItensTemp , {"C7_ITEM" , StrZero(nX,TamSX3("C7_ITEM")[1])	, Nil } )
										Endif
										
										cVerItem := AllTrim(PmsMsgUVer('ITEM','MATA010'))
											If Type("oXmlChild:_ItemInternalId:Text") # "U"
												aItemPC := IntProInt(oXmlChild:_ItemInternalId:Text, cMarca, cVerItem)
												If aItemPC[1]
													If cVerItem == '1.000' .Or. cVerItem == '1.001'
														cValProd := aItemPC[2]
													Else
														cValProd := aItemPC[2][3]
													Endif
													aadd( aItensTemp , {"C7_PRODUTO" ,cValProd, Nil } )
												Else
													If Type("oXmlChild:_ItemCode:Text") # "U"
													aadd( aItensTemp , {"C7_PRODUTO" ,oXmlChild:_ItemCode:Text, Nil } )
													Else
														lRet := .F.
													cXmlRet+='<Message type="ERROR" code="c2">' + STR0043 + '</Message>' //Item não encontrado
													Endif
												Endif
											ElseIf Type("oXmlChild:_ItemCode:Text") # "U"
											aadd( aItensTemp , {"C7_PRODUTO" ,oXmlChild:_ItemCode:Text, Nil } )
										Else
											lRet := .F.
											cXmlRet+='<Message type="ERROR" code="c2">' + STR0043 + '</Message>' //Item não encontrado
											Endif
										
										If Type("oXmlChild:_itemunitofmeasure:Text") # "U" 
											aadd( aItensTemp , {"C7_UM" , Padr(AllTrim(oXmlChild:_itemunitofmeasure:Text),TamSX3("C7_UM")[1])	, Nil } )
										Endif
										If Type("oXmlChild:_ItemDescription:Text") # "U"
											aadd( aItensTemp , {"C7_DESCRI" , Padr(AllTrim(oXmlChild:_ItemDescription:Text),TamSX3("C7_DESCRI")[1])	, Nil } )
										Endif
										If Type("oXmlChild:_Quantity:Text") # "U"
											nQtd:=  Val(AllTrim(oXmlChild:_Quantity:Text))
											aadd( aItensTemp , {"C7_QUANT" ,nQtd	, Nil } )
										Endif
										If Type("oXmlChild:_UnityPrice:Text") # "U"
											nVlrUni:=  Val(AllTrim(oXmlChild:_UnityPrice:Text))
											aadd( aItensTemp , {"C7_PRECO" ,nVlrUni	, Nil } )
										Endif
										If Type("oXmlChild:_TotalPrice:Text") # "U"
											If !Empty(oXmlChild:_TotalPrice:Text) 
												nVlrTotal:= Val(AllTrim(oXmlChild:_TotalPrice:Text))
											Endif
											If nVlrTotal == 0 
												nVlrTotal := nQtd*nVlrUni
											Endif
											aadd( aItensTemp , {"C7_TOTAL" , nVlrTotal	, Nil } )
										Endif
										If Type("oXmlChild:_CostCenterCode:Text") # "U"
											
											cVersaoCust:=AllTrim(PmsMsgUVer('COSTCENTER','CTBA030'))
											aCusto:=IntCusInt( oXmlChild:_CostCenterCode:Text, cMarca, cVersaoCust)
											If aCusto[1]
												If AllTrim(cVersaoCust)=='1.000'
													cCusto:=aCusto[2][2]
												Else
													cCusto:=aCusto[2][3]
												Endif
											Endif
											aadd( aItensTemp , {"C7_CC" ,cCusto	, Nil } )
										Endif
										If Type("oXmlChild:_ItemDiscounts:_ItemDiscount[1]") # "U"
											nCount2:=Len(oXmlChild:_ItemDiscounts:_ItemDiscount)
										Else 
											nCount2:=1
										Endif
										If nCount2 > 0
											For nX2:=1 to nCount2
												If nCount2 > 1
													oXmlDisc:=oXmlChild:_ItemDiscounts:_ItemDiscount[nX2]
												Else
													oXmlDisc:=oXmlChild:_ItemDiscounts:_ItemDiscount
												Endif
													nValDesc +=Val(oXmlDisc:Text)
											Next
											aadd( aItensTemp , {"C7_VLDESC" , nValDesc	, Nil } )
										Endif
										If Type("oXmlChild:_FreightValue:Text") # "U"
											aadd( aItensTemp , {"C7_VALFRE" , Val(AllTrim(oXmlChild:_FreightValue:Text))	, Nil } )
										Endif
										If Type("oXmlChild:_InsuranceValue:Text") # "U"
											aadd( aItensTemp , {"C7_SEGURO" , Val(AllTrim(oXmlChild:_InsuranceValue:Text))	, Nil } )
										Endif
										If Type("oXmlChild:_observation:Text") # "U"
											aadd( aItensTemp , {"C7_OBS" , Padr(AllTrim(oXmlChild:_observation:Text),TamSX3("C7_OBS")[1])	, Nil } )
										Endif
										aadd( aItensTemp , {"C7_USER" , cUser	, Nil } )
										aAdd(aItens,aItensTemp)

										nCount3:=0
										If XmlChildEx(oXmlChild,"_LISTOFAPPORTIONORDERITEM:_APPORTIONORDERITEM")<>Nil
											//-- Rateio por Centro de Custo
											If	Type("oXmlChild:_ListOfApportionOrderItem:_ApportionOrderItem[1]")#"U"
												nCount3:=Len(oXmlChild:_ListOfApportionOrderItem:_ApportionOrderItem)
											Else
												nCount3:=1
											EndIf
										EndIf
										If	nCount3 > 0
											aLinha := {}
											aItensRat:={}
											cItemSC7:=""
											For nX3 := 1 To nCount3
												If	nCount3 > 1
													oXmlRat := oXmlChild:_ListOfApportionOrderItem:_ApportionOrderItem[nX3]
												Else
													oXmlRat := oXmlChild:_ListOfApportionOrderItem:_ApportionOrderItem
												EndIf
													
												AAdd(aLinha,{"CH_ITEM",StrZero(nX3,Len(SCH->CH_ITEM)),Nil})
												If Type("oXmlRat:_Percentual:Text") # "U"
													AAdd(aLinha,{"CH_PERC",Val(AllTrim(oXmlRat:_Percentual:Text)),Nil})
													conout(oXmlRat:_Percentual:Text)
												EndIf
												If Type("oXmlRat:_CostCenterInternalId:Text") # "U"
													AAdd(aLinha,{"CH_CC",oXmlRat:_CostCenterInternalId:Text,Nil})
													conout(oXmlRat:_CostCenterInternalId:Text)
												EndIf
												If Type("oXmlRat:_AccountantAcountInternalId:Text") # "U"
													AAdd(aLinha,{"CH_CONTA",oXmlRat:_AccountantAcountInternalId:Text,Nil})
													conout(oXmlRat:_AccountantAcountInternalId:Text)
												EndIf

												If	cItemSC7 <> oXmlChild:_OrderItem:Text
													cItemSC7 := oXmlChild:_OrderItem:Text
													AAdd(aItensRat,{cItemSC7,{}})
												EndIf
												AAdd(aItensRat[Len(aItensRat),2],aLinha)
												aLinha := {}
											Next
										EndIf
									Next nCount
								Endif
								If lRet
									MsExecAuto({|u,v,x,y,z,a| MATA120(u,v,x,y,z,a)},1,aCab,aItens,nOpcExec,.F.,aItensRat)
									If lMsErroAuto
										aErroAuto := GetAutoGRLog()
										For nCount := 1 To Len(aErroAuto)
											cXmlRet+='<Message type="ERROR" code="c2">'+StrTran(StrTran(StrTran(aErroAuto[nCount],"<"," "),"-"," "),"/"," ")+" "+'</Message>'
										Next 
										lRet:=.F.                         
									Else
										If Empty(cValInt) .And. nOpcExec == 3
											cValInt:=(xFilial("SC7")+cMat120Num)
											CFGA070Mnt( cMarca, cAlias,cCampo, cValExt, cValInt )					
											cXMLRet += "<DestinationInternalId>"+ cValInt +"</DestinationInternalId>"  //-- Valor recebido na tag "BusinessMessage:BusinessContent:Code"
											cXMLRet += "<OriginInternalId>"+       cValExt       +"</OriginInternalId>"	//-- Valor gerado		
										ElseIf nOpcExec==5
											CFGA070Mnt(,cAlias,cCampo,, cValInt, .T. )
										Endif
									EndIf
								Endif
							Endif
						Else
							lRet:= .F.
							cXmlRet+='<Message type="ERROR" code="c2">'+STR0009+'</Message>'//"Valor Externo vazio ou não enviado."
						Endif
					ElseIf AllTrim(oXmlmati120:_TOTVSMessage:_BusinessMessage:_BusinessContent:_OrderPurpose:Text) == "2"
							lRet:= .F.
						cXmlRet+='<Message type="ERROR" code="c2">'+STR0011+'</Message>'//"O Pedido de Vendas ainda não está desenvolvido"
					Else
						lRet:= .F.
						cXmlRet+='<Message type="ERROR" code="c2">'+STR0012+'</Message>'//"Tipo de Pedido inválido!"
					Endif
				Else
					lRet:= .F.
					cXmlRet+='<Message type="ERROR" code="c2">'+STR0010+'</Message>'//"Tipo de Pedido nao enviado."
				Endif
			Else
				lRet   := .F.
				cXmlRet+='<Message type="ERROR" code="c2">'+STR0001+'</Message>'
				ConOut(STR0001)	//-- Atualize EAI
			Endif
		EndIf
EndCase
cXmlRet:=EncodeUTF8(cXmlRet)
RestArea(aAreaSC7)
RestArea(aAreaSA2)
RestArea( aArea )
Return { lRet, cXmlRet } 

//-------------------------------------------------------------------
/*{Protheus.doc} IntUserReq
	Retorna o InternalId do comprador com base no código do usuário logado no sistema
	
	@author	Raphael Augusto
	@version	P11
	@since	30/05/2013
*/
//-------------------------------------------------------------------
Static Function IntUserReq()
Local cRet	:= ""
Local aArea := SY1->(GetArea())

If !Empty(SC7->C7_USER)
	SY1->(DbSetOrder(3))
	IF SY1->( DbSeek( xFilial("SY1") +  SC7->C7_USER ) )
		cRet += SY1->Y1_USER
	EndIf
EndIf

RestArea(aArea)
Return cRet

//----------------------------------------------------------------------------------
/*/{Protheus.doc} v3002
Funcao de integracao com o adapter EAI para envio e recebimento do
Pedido de Compra (SC7/SCH/AJ7) utilizando o conceito de mensagem unica
(Order).

@param   cXML          Variavel com conteudo xml para envio/recebimento.
@param   nTypeTrans    Tipo de transacao. (Envio/Recebimento)
@param   cTypeMessage  Tipo de mensagem. (Business Type, WhoIs, etc)

@author  Leandro Luiz da Cruz
@version P11
@since   19/04/2013
@return  aRet - Array contendo o resultado da execucao e a mensagem Xml de retorno.
         aRet[1] - (boolean) Indica o resultado da execução da função
         aRet[2] - (caracter) Mensagem Xml para envio

@obs     O método irá retornar um objeto do tipo TOTVSBusinessEvent caso
         o tipo da mensagem seja EAI_BUSINESS_EVENT ou um tipo
         TOTVSBusinessRequest caso a mensagem seja do tipo TOTVSBusinessRequest.
         O tipo da classe pode ser definido com a função EAI_BUSINESS_REQUEST.
/*/
//----------------------------------------------------------------------------------
Static Function v3002(cXML, nTypeTrans, cTypeMessage)
   Local lRet             := .T.
   Local cAlias           := "SC7"
   Local cField           := "C7_NUM"
   Local cEvent           := "upsert"
   Local cUserPar         := AllTrim(GetNewPar("MV_SLMCOMP", ""))
   Local lSlmUsr         := Iif(SuperGetMv("MV_SLMPUSR",,"N")=="S",.T.,.F.)
   Local cUser	         := ""
   Local cXMLRet          := ""
   Local cError           := ""
   Local cWarning         := ""
   Local cValExt          := ""
   Local cValInt          := ""
   Local cValIntI         := ""
   Local cMarca           := ""
   Local cFornec          := ""
   Local cLoja            := ""
   Local cNumPed          := ""
   Local cItemSC7         := ""
   Local nOpcx            := 0
   Local nI               := 0
   Local nI2              := 0
   Local nI3              := 0
   Local nI4              := 0
   Local nI5              := 0
   Local nY				  := 0
   Local nCont            := 0
   Local nQtd             := 0
   Local nVlrUni          := 0
   Local nVlrTot          := 0
   Local aCab             := {}
   Local aAux             := {}
   Local aCCusto          := {}
   Local aProjeto         := {}
   Local aLinha           := {}
   Local aItens           := {}
   Local aItensRat        := {}
   Local aItensPrj        := {}
   Local aItemAux         := {}
   Local aDePara          := {}
   Local aRateio          := {}
   Local aRet             := {}
   Local aAdtPC           := {}
   Local nAux             := 0
   Local nDescTotal       := 0
   Local nValorTotal      := 0
   Local n1Cnt            := 0
   Local n2Cnt            := 0
   Local aDescUnit        := {}
   Local cCond            := ""
   Local cNameInternalId  := ""	  
   Local cVenVer          := RTrim(PmsMsgUVer('CUSTOMERVENDOR',         'MATA020')) //Versão do Fornecedor
   Local cCusVer          := RTrim(PmsMsgUVer('COSTCENTER',             'CTBA030')) //Versão do Centro de Custo
   Local cUndVer          := RTrim(PmsMsgUVer('UNITOFMEASURE',          'QIEA030')) //Versão da Unidade de Medida
   Local cConVer          := RTrim(PmsMsgUVer('PAYMENTCONDITION',       'MATA360')) //Versão da Condição de Pagamento
   Local cMoeVer          := RTrim(PmsMsgUVer('CURRENCY',               'CTBA140')) //Versão da Moeda
   Local cLocVer          := RTrim(PmsMsgUVer('WAREHOUSE',              'AGRA045')) //Versão do Local de Estoque
   Local cPrdVer          := RTrim(PmsMsgUVer('ITEM',                   'MATA010')) //Versão do Produto
   Local cPrjVer          := RTrim(PmsMsgUVer('PROJECT',                'PMSA200')) //Versão do Projeto
   Local cTrfVer          := RTrim(PmsMsgUVer('TASKPROJECT',            'PMSA203')) //Versão da Tarefa
   Local cTPgVer          := RTrim(PmsMsgUVer('ACCOUNTPAYABLEDOCUMENT', 'FINA050')) //Versão do Título a Pagar
   Local cPdCVer          := RTrim(PmsMsgUVer('ORDER',                  'MATA120')) //Versão do Pedido de Compra
   Local cSCoVer          := RTrim(PmsMsgUVer('REQUEST',                'MATA110')) //Versão da Solicitação de Compra
   Local lMktPlace        := SuperGetMv("MV_MKPLACE",.F.,.F.)
   Local lRestInc         := Iif(SuperGetMv("MV_RESTINC",,"N")=="S",.T.,.F.)
   Local cCodSc           := ""
   Local nPosMoeda        := ""
   Local nPosTxMoeda      := ""
   Local nMoedaInt        := ""
   Local nTxMoeInt        := ""
   Local cObsM			  := ""
   Local nPosProd		  := 0
      
   Private oXml           := Nil
   Private oXmlAux        := Nil
   Private oXmlRat        := Nil
   Private lMsErroAuto    := .F.
   Private lAutoErrNoFile := .T.
   Private cNumPCWS       := ""
   Private lRetDedFat     := A120RDFRM("I120")
   
   // Mensagem de Entrada
   If nTypeTrans == TRANS_RECEIVE
      // Regra de Negócio
      If cTypeMessage == EAI_MESSAGE_BUSINESS
         oXml := XmlParser(cXML, "_", @cError, @cWarning)
         //Valida se houve erro no parser
         If oXml != Nil .And. Empty(cError) .And. Empty(cWarning)
			If lMktPlace .And. Type("oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_funcmsgorder") <> "U"
				If Type("oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_InternalId:Text" )<> "U"
					cNumPc :=  PadR( StrToArray( oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_InternalId:Text , "|")[3] , TamSX3('C7_NUM')[1])
					If oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_funcmsgorder:text == "42" // Confirmação (Utilizada no Paradigma)
						If SC7->( DbSeek( xFilial("SC7") + cNumPc  ) )
							cCodSc := SC7->C7_NUMSC
							While SC7->( !EOF() )  .And. SC7->(C7_FILIAL+C7_NUM) == xFilial("SC7")+cNumPc
								RecLock("SC7",.F.)
								SC7->C7_ACCPROC := '2'
								MsUnLock()
								SC7->(DbSkip())
							EndDo
						EndIf
					ElseIf oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_funcmsgorder:text == '43' // Recusa (Utilizada no Paradigma)
						AADD(aCab  ,{"C7_NUM"	, cNumPc ,Nil})
						AADD(aItens,{{"C7_NUM"	, cNumPc ,Nil}})
						lMsErroAuto := .F.
					       
						SC7->( dbSetOrder(1) )
						If SC7->( DbSeek( xFilial("SC7") + cNumPc ) )
							cNumCot := SC7->C7_NUMCOT
							cFornec := SC7->C7_FORNECE
							cLoja   := SC7->C7_LOJA
							cProduto:= SC7->C7_PRODUTO
									
							SC8->( dbSetOrder(3) )
							SC8->( DbSeek( xFilial("SC8") + cNumCot  + cFornec + cLoja + cNumPc ) )
							lMSErroAuto	:= .F.
							MSExecAuto({|v,x,y,z| MATA120(v,x,y,z)},1,aCab,aItens,5)
						
							If lMsErroAuto
								aErro := GetAutoGRLog()
								For nY := 1 To Len(aErro)
									cXmlRet += aErro[nY] +CRLF
								Next nY
								lRet := .F.
							Endif
						
							aCab   :={}
							aItens :={}
						
							aAdd(aCab,{"C8_NUM"    ,cNumCot,NIL})
							aAdd(aCab,{"COMPACC"   ,""     ,NIL})
							aAdd(aCab,{"C8_FORNECE",cFornec,Nil})
							aAdd(aCab,{"C8_LOJA"   ,cLoja  ,Nil})
																						
							lMSErroAuto	:= .F.
							lAutoErrNoFile := .T.
							MSExecAuto({|x,y,z| MATA150(x,y,z)},aCab,aItens,5)
						
							If lMsErroAuto
								aErro := GetAutoGRLog()
								For nY := 1 To Len(aErro)
									cXmlRet += aErro[nY] +CRLF
								Next nY
								lRet := .F.
							Else
								Return {.T.,"OK"}
							Endif
						EndIf
					EndIf
				EndIf

			ElseIf Type("oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_OrderPurpose:Text") != "U" .And. !Empty(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_OrderPurpose:Text)
               If AllTrim(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_OrderPurpose:Text) == "1"
                  //Verifica se a marca foi informada
                  If Type("oXml:_TOTVSMessage:_MessageInformation:_Product:_name:Text") != "U" .And. !Empty(oXml:_TOTVSMessage:_MessageInformation:_Product:_name:Text)
                     cMarca := oXml:_TOTVSMessage:_MessageInformation:_Product:_name:Text
                  Else
                     lRet := .F.
                     cXmlRet := STR0014 // "Informe a Marca!"
                     Return {lRet, cXmlRet}
                  EndIf

                  // Verifica se a filial atual é a mesma filial de inclusão do cadastro
                  aAux := IntChcEmp(oXml, cAlias, cMarca)
                  If !aAux[1]
                    lRet := aAux[1]
                    cXmlRet := aAux[2]
                    Return {lRet, cXmlRet}
                  EndIf

                  //Verifica se o InternalId foi informado
                  If Type("oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_InternalId:Text") != "U" .And. !Empty(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_InternalId:Text)
                     cValExt := oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_InternalId:Text
                  Else
                     lRet := .F.
                     cXmlRet := STR0015 // "O InternalId é obrigatório!"
                     Return {lRet, cXmlRet}
                  EndIf

                  aAux := IntPdCInt(cValExt, cMarca, cPdCVer)
                  If aAux[1]
                     cNumPed := RTrim(aAux[2][3])

                     If Upper(oXml:_TOTVSMessage:_BusinessMessage:_BusinessEvent:_Event:Text) == "UPSERT"
                        If SC7->(dbSeek(xFilial(cAlias) + cNumPed))
                           nOpcx := 4 //UPDATE
                           cValInt := IntPdCExt(/*Empresa*/, /*Filial*/, aAux[2][3], Nil, cPdCVer)[2]
                           aAdd(aCab, {"C7_NUM", cNumPed, Nil})
                        Else
                           lRet := .F.
                           cXmlRet := STR0016 // "Erro no processamento da operação. Verifique o de/para do pedido."
                           Return {lRet, cXmlRet}
                        EndIf
                     ElseIf Upper(oXml:_TOTVSMessage:_BusinessMessage:_BusinessEvent:_Event:Text) == "DELETE"
                        If SC7->(dbSeek(xFilial("SC7") + cNumPed))
                           nOpcx := 5 //DELETE
                           cValInt := IntPdCExt(/*Empresa*/, /*Filial*/, aAux[2][3], Nil, cPdCVer)[2]
                           aAdd(aCab, {"C7_FILIAL", xFilial(cAlias), Nil})
                           aAdd(aCab, {"C7_NUM", cNumPed, Nil})
                           aDePara := GetDePara(cMarca, xFilial(cAlias) + cNumPed, cPdCVer)
                           
                           If lRestInc .OR. lSlmUsr
	                           	  
	                           If !Empty(cUserPar)
		                           //Atualiza variavel global para excluir o pedido
		                           cUserName	:= cUserPar
		                        Endif
	                        Endif
                        Else
                           lRet := .F.
                           cXmlRet := STR0017 // "Pedido a ser excluído não encontrado no Protheus."
                           Return {lRet, cXmlRet}
                        EndIf
                     EndIf
                  Else
                     If Upper(oXml:_TOTVSMessage:_BusinessMessage:_BusinessEvent:_Event:Text) == "UPSERT"
                        nOpcx := 3 //INSERT
                        
                        If Empty(Posicione('SX3', 2, Padr('C7_NUM', 10), 'X3_RELACAO'))
                        	If Type("oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Number:Text") != "U"
                        		aAdd(aCab, {"C7_NUM",oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Number:Text, Nil})
                        	Else
                        		lRet := .F.
		                        cXmlRet := "Informe um numero de pedido ou preencha o inicializador padrão."
		                        Return {lRet, cXmlRet}
                        	Endif
                        Endif
                     Else
                        lRet := .F.
                        cXmlRet := STR0018 // "O registro a ser excluído não foi encontrado na base Protheus."
                        Return {lRet, cXmlRet}
                     EndIf
                  EndIf

                  If nOpcx != 5
                     //Filial
                     aAdd(aCab, {"C7_FILIAL", xFilial("SC7"), Nil})

                     // Obtém o Código Interno do Fornecedor e a Loja
                     If Type("oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_CustomerInternalId:Text") != "U" .And. !Empty(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_CustomerInternalId:Text)
                        aAux := IntForInt(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_CustomerInternalId:Text, cMarca)
                        If !aAux[1]
                           lRet := aAux[1]
                           cXmlRet := aAux[2]
                           Return {lRet, cXmlRet}
                        Else
                           cFornec := PadR(aAux[2][3], TamSX3("C7_FORNECE")[1])
                           cLoja   := PadR(aAux[2][4], TamSX3("C7_LOJA")[1])
                           aAdd(aCab, {"C7_FORNECE", cFornec, Nil})
                           aAdd(aCab, {"C7_LOJA",    cLoja,   Nil})
                        EndIf
                     ElseIf Type("oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_CustomerCode:Text") != "U" .And. !Empty(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_CustomerCode:Text)
                        If Len(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_CustomerCode:Text) > TamSX3("C7_FORNECE")[1]
                           cFornec := SubStr(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_CustomerCode:Text, 1, TamSX3("C7_FORNECE")[1])
                           cLoja   := PadR(SubStr(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_CustomerCode:Text, TamSX3("C7_FORNECE")[1] + 1), TamSX3("C7_LOJA")[1])
                        Else
                           cFornec := PadR(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_CustomerCode:Text, TamSX3("C7_FORNECE")[1])
                           cLoja   := ""
                        EndIf
                        aAdd(aCab, {"C7_FORNECE", cFornec, Nil})
                        aAdd(aCab, {"C7_LOJA",    cLoja,   Nil})
                     Else
                     	lRet := .F.
                     	cXmlRet := STR0041 //"Fornecedor não informado"
                     	Return {lRet,cXmlRet}
                     EndIf

                     //Data de emissão
                     If Type("oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_RegisterDate:Text") != "U" .And. !Empty(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_RegisterDate:Text)
                         aAdd(aCab, {"C7_EMISSAO", SToD(StrTran(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_RegisterDate:Text, "-", "")), Nil})
                     Else
                     	aAdd(aCab, {"C7_EMISSAO", dDataBase, Nil})
                     EndIf

                     // Obtém o código interno da Condição de Pagamento
                     If Type("oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_PaymentConditionInternalId:Text") != "U" .And. !Empty(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_PaymentConditionInternalId:Text)
                        aAux := IntConInt(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_PaymentConditionInternalId:Text, cMarca)
                        If !aAux[1]
                           lRet := aAux[1]
                           cXmlRet := aAux[2]
                           Return {lRet, cXmlRet}
                        Else
                           cCond := aAux[2][3]
                           aAdd(aCab, {"C7_COND", cCond, Nil})
                        EndIf
                     //Se o InternalID não foi informado e é integração com o TOP (RM Solum) pegar a condição do parâmetro MV_SLMCOND
                     ElseIf IsIntegTop()
                        aAdd(aCab, {"C7_COND", GETMV("MV_SLMCOND", .F., ""), Nil})
                     ElseIf Type("oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_PaymentTermCode:Text") != "U" .And. !Empty(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_PaymentTermCode:Text)
                     	cCond := oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_PaymentTermCode:Text
                     		
							AADD(aCab,{"C7_COND",cCond,NIL})   
                     Else
                     	lRet := .F.
                     	cXmlRet := STR0042 //"Condição de pagamento não informada"
                     	Return {lRet,cXmlRet}	
                     EndIf

                     //Tipo do frete utilizado
                     If Type("oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_FreightType:Text") != "U" .And. !Empty(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_FreightType:Text)
                        aAdd(aCab, {"C7_TPFRETE", getTpFre(AllTrim(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_FreightType:Text), nTypeTrans), Nil})
                     EndIf

                     //Peso Bruto
                     If Type("oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_GrossWeight:Text") != "U" .And. !Empty(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_GrossWeight:Text)
                        aAdd(aCab, {"C7_PESO_B", Val(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_GrossWeight:Text), Nil})
                     EndIf

                     //Volume Cubado
                     If Type("oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_CubicVolume:Text") != "U" .And. !Empty(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_CubicVolume:Text)
                        aAdd(aCab, {"C7_MT3", Val(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_CubicVolume:Text), Nil})
                     EndIf

                     //Valor do Seguro Unitário
                     If Type("oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_InsuranceValue:Text") != "U" .And. !Empty(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_InsuranceValue:Text)
                        aAdd(aCab, {"C7_SEGURO", oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_InsuranceValue:Text, Nil})
                     EndIf

                     aAdd(aCab, {"C7_CONTATO", Space(1), Nil})
                     aAdd(aCab, {"C7_FILENT", xFilial("SC7"), Nil})

                     //Valor do Desconto
                     If Type("oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Discounts:_Discount") != "U" .And. !Empty(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Discounts:_Discount)
                        If Type("oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Discounts:_Discount") != "A"
                           XmlNode2Arr(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Discounts:_Discount, "_Discount")
                        EndIf

                        For nI := 1 To Len(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Discounts:_Discount)
                           nDescTotal += Val(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Discounts:_Discount[nI]:Text)
                        Next nI
                     EndIf

                     //Moeda
                     If Type("oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_CurrencyId:Text") != "U" .And. !Empty(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_CurrencyId:Text)
							cMoedaExt	:= oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_CurrencyId:Text
                     	
                        aAux := IntMoeInt(cMoedaExt, cMarca, cMoeVer)
                        If !aAux[1]
                           lRet := aAux[1]
	                        cXmlRet := aAux[2]
                           Return {lRet, cXmlRet}
                        Else
                        	   aAdd(aCab, {"C7_MOEDA",Iif(cMoeVer=="1.000",Val(aAux[2][2]),Val(aAux[2][3])), Nil})
                        EndIf
                     ElseIf Type("oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_CurrencyCode:Text") != "U" .And. !Empty(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_CurrencyCode:Text)
                        aAdd(aCab, {"C7_MOEDA", Val(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_CurrencyCode:Text), Nil})
                     EndIf
                     
                     If Type("oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_CurrencyRate:Text") != "U" .And. !Empty(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_CurrencyRate:Text)
                     	aAdd(aCab, {"C7_TXMOEDA", Val(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_CurrencyRate:Text), Nil})
                     Endif
                     
                     nPosMoeda		:= aScan(aCab,{|x| AllTrim(x[1]) == "C7_MOEDA"})
                     nPosTxMoeda	:= aScan(aCab,{|x| AllTrim(x[1]) == "C7_TXMOEDA"})
                     
                     //Esta sendo enviada a Moeda, e é preciso enviar a taxa da moeda
                     If nPosMoeda > 0
                     	nMoedaInt := aCab[nPosMoeda,2]
                     	
                     	If nMoedaInt == 1 //Moeda Local
                     		If nPosTxMoeda == 0
                     			aAdd(aCab, {"C7_TXMOEDA",1, Nil})
                     		Endif
                     	Else
                     		If nPosTxMoeda == 0
                     			nTxMoeInt := RecMoeda(dDataBase,nMoedaInt)
                     			If nTxMoeInt > 0
                     				aAdd(aCab, {"C7_TXMOEDA",nTxMoeInt, Nil})
                     			Else
                     				lRet := .F.
                     				cXmlRet := "Cadastrar taxa da moeda " + AllTrim(Str(nMoedaInt)) + "(" + AllTrim(cMoedaExt) + ") na data: " + DtoC(dDataBase)
                     				Return {lRet, cXmlRet}
                     			Endif
                     		Endif
                     	Endif
                     Endif
                     
                     //Origem
                     aAdd(aCab, {"C7_ORIGEM","MSGEAI",Nil})
                     
                     If SC7->(ColumnPos("C7_APROPRM")) > 0 .And. Type("oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_TaskCostAssignmentDocument:Text") != "U" .AND. !Empty(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_TaskCostAssignmentDocument:Text)
					 		cTpAprop := Alltrim(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_TaskCostAssignmentDocument:Text)
							AADD(aCab,{"C7_APROPRM",StrTran(cTpAprop,'0',''),NIL})
					 	Endif
                     
					 If Type("oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Observation:Text") != "U" .And. !Empty(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Observation:Text)
						cObsM := AllTrim(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Observation:Text)
					 Endif

                     // Se não for array
                     If Type("oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_SalesOrderItens:_Item") != "A"
                         XmlNode2Arr(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_SalesOrderItens:_Item, "_Item")
                     EndIf

                     For nI := 1 To Len(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_SalesOrderItens:_Item)
                        nQtd    := 0
                        nVlrUni := 0
                        nVlrTot := 0
                        aItemAux := {}

                        // Atualiza o objeto com a posição atual
                        oXmlAux := oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_SalesOrderItens:_Item[nI]

                        //Array e contador que serão usados para manipular o de/para
                        aAdd(aDePara, Array(4))
                        aDePara[nI][1] := oXmlAux:_InternalId:Text
                        aDePara[nI][2] := PadL(oXmlAux:_OrderItem:Text, TamSx3("C7_ITEM")[1], "0")
                        aDePara[nI][3] := 'SC7'
                        aDePara[nI][4] := 'C7_ITEM'

                        If nOpcx == 4
                           If SC7->(dbSeek(xFilial("SC7") + cNumPed + StrZero(nI, TamSX3("C7_ITEM")[1])))
                              aAdd(aItemAux, {"LINPOS", "C7_ITEM", StrZero(nI, TamSX3("C7_ITEM")[1]),Nil})
                              aAdd(aItemAux, {"AUTDELETA", "N", Nil}) 
                           Else
                              aAdd(aItemAux, {"C7_ITEM", StrZero(nI, TamSX3("C7_ITEM")[1]), Nil})
                           EndIf
                        Else
                           aAdd(aItemAux, {"C7_ITEM", StrZero(nI, TamSX3("C7_ITEM")[1]), Nil})
                        EndIf

                        cItemSC7 := StrZero(nI, TamSX3("C7_ITEM")[1])

                        //Obtém o Código Interno do produto
                        If Type("oXmlAux:_ItemInternalId:Text") != "U" .And. !Empty(oXmlAux:_ItemInternalId:Text)
                           aAux := IntProInt(oXmlAux:_ItemInternalId:Text, cMarca, cPrdVer)
                           If !aAux[1]
                              lRet := aAux[1]
                              cXmlRet := aAux[2]
                              Return {lRet, cXmlRet}
                           Else
                              aAdd(aItemAux, {"C7_PRODUTO", aAux[2][3], Nil})
                           EndIf
                        ElseIf Type("oXmlAux:_ItemCode:Text") != "U" .And. !Empty(oXmlAux:_ItemCode:Text)
                           aAdd(aItemAux, {"C7_PRODUTO", oXmlAux:_ItemCode:Text, Nil})
                        EndIf 
                        
                        //Descrição do produto
                        If Type("oXmlAux:_ItemDescription:Text") != "U" .And. !Empty(oXmlAux:_ItemDescription:Text)
                           aAdd(aItemAux , {"C7_DESCRI" , AllTrim(oXmlAux:_ItemDescription:Text), Nil})
                        EndIf

                        //Obtém o código interno do local de estoque
                        If Type("oXmlAux:_WarehouseInternalId:Text") != "U" .And. !Empty(oXmlAux:_WarehouseInternalId:Text)
                           aAux := IntLocInt(oXmlAux:_WarehouseInternalId:Text, cMarca, cLocVer)
                           If !aAux[1]
                              lRet := aAux[1]
                              cXmlRet := aAux[2]
                              Return {lRet, cXmlRet}
                           Else
                              aAdd(aItemAux, {"C7_LOCAL", aAux[2][3], Nil})
                           EndIf
                        EndIf

                        //Obtém o Código Internl da Unidade de Medida
                        If Type("oXmlAux:_UnitOfMeasureInternalId:Text") != "U" .And. !Empty(oXmlAux:_UnitOfMeasureInternalId:Text)
                           aAux := IntUndInt(oXmlAux:_UnitOfMeasureInternalId:Text, cMarca)
                           If !aAux[1]
                              lRet := aAux[1]
                              cXmlRet := aAux[2]
                              Return {lRet, cXmlRet}
                           Else
                              aAdd(aItemAux, {"C7_UM", aAux[2][3], Nil})
                           EndIf
                        ElseIf Type("oXmlAux:_itemunitofmeasure:Text") != "U" .And. !Empty(oXmlAux:_itemunitofmeasure:Text)
                           aAdd(aItemAux, {"C7_UM", oXmlAux:_itemunitofmeasure:Text, Nil})
                        EndIf

                        //Obtém o Centro de Custo
                        If Type("oXmlAux:_CostCenterInternalId:Text") != "U" .And. !Empty(oXmlAux:_CostCenterInternalId:Text)
                           aAux := IntCusInt(oXmlAux:_CostCenterInternalId:Text, cMarca)
                           If !aAux[1]
                              lRet := aAux[1]
                              cXmlRet := aAux[2]
                              Return {lRet, cXmlRet}
                           Else
                              aAdd(aItemAux, {"C7_CC", aAux[2][3], Nil})
                           EndIf
                        ElseIf Type("oXmlAux:_CostCenterCode:Text") != "U" .And. !Empty(oXmlAux:_CostCenterCode:Text)
                           aAdd(aItemAux, {"C7_CC", oXmlAux:_CostCenterCode:Text, Nil})
                        EndIf

                        //Quantidade
                        If Type("oXmlAux:_Quantity:Text") != "U"
                           nQtd := Val(AllTrim(oXmlAux:_Quantity:Text))
                           aAdd(aItemAux, {"C7_QUANT", nQtd, Nil})
                        EndIf

                        //Preço unitário
                        If Type("oXmlAux:_UnityPrice:Text") != "U"
                           nVlrUni := Val(AllTrim(oXmlAux:_UnityPrice:Text))
                           aAdd(aItemAux, {"C7_PRECO", nVlrUni, Nil})
                        EndIf

                        //Preço total
                        If Type("oXmlAux:_TotalPrice:Text") != "U" .And. !Empty(oXmlAux:_TotalPrice:Text)
                           nVlrTot := Val(oXmlAux:_TotalPrice:Text)
                           aAdd(aItemAux, {"C7_TOTAL", Val(oXmlAux:_TotalPrice:Text), Nil})
                        Else
                           nVlrTot := nQtd * nVlrUni
                           aAdd(aItemAux, {"C7_TOTAL", nVlrTot, Nil})
                        EndIf

                        //Monta o rateio do desconto da capa
                        aAdd(aDescUnit, {cItemSC7, nVlrTot, 0.0})
                        nValorTotal += nVlrTot

                        //Valor de desconto do item
                        If Type("oXmlAux:_ItemDiscounts:_ItemDiscount") != "U" .And. !Empty(oXmlAux:_ItemDiscounts:_ItemDiscount)
                           //Se não é array transforma em array
                           If Type("oXmlAux:_ItemDiscounts:_ItemDiscount") != "A"
                              XmlNode2Arr(oXmlAux:_ItemDiscounts:_ItemDiscount, "_ItemDiscount")
                           EndIf

                           For nI2 := 1 To Len(oXmlAux:_ItemDiscounts:_ItemDiscount)
                              nAux += Val(oXmlAux:_ItemDiscounts:_ItemDiscount[nI2]:Text)
                           Next nI2

                           aAdd(aItemAux, {"C7_VLDESC", nAux, Nil})
                        EndIf

                        //Valor do frete do item
                        If Type("oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_FreightValue:Text") != "U" .And. !Empty(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_FreightValue:Text)
                          aAdd(aCab, {"C7_VALFRE", Val(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_FreightValue:Text), Nil})
                        EndIf

                        //Valor do seguro
                        If Type("oXmlAux:_InsuranceValue:Text") != "U"
                           aAdd(aItemAux, {"C7_SEGURO", Val(AllTrim(oXmlAux:_InsuranceValue:Text)), Nil})
                        EndIf

                        //Observações
                        If !Empty(cObsM) .Or. (Type("oXmlAux:_Observation:Text") != "U" .And. !Empty(oXmlAux:_Observation:Text))
							cObsM := Iif(!Empty(cObsM),cObsM,AllTrim(oXmlAux:_Observation:Text))
							cObsM := Padr(cObsM, TamSX3("C7_OBSM")[1])
                        	aAdd(aItemAux, {"C7_OBSM",cObsM, Nil})
						EndIf

                        // Integração com o TOTVS Obras e Projetos
                        If IsIntegTop()
                           If lRestInc .OR. lSlmUsr
	                           // Código do usuário comprador
	                           If lSlmUsr 
									If Type("oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_UserInternalId:Text") != "U" .And. !Empty(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_UserInternalId:Text)
										cUser	  := RetCodUsr(AllTrim(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_UserInternalId:Text))
									EndIf
									
									If Empty(cUser)
										lRet := .F.
										cXmlRet := STR0049 + AllTrim(cUser) + STR0051 // "Usuário: " # " não encontrado nos usuarios do Protheus." 
										Return {lRet, cXmlRet}
									EndIf
							   ElseIf Empty(cUserPar)
									lRet := .F.
									cXmlRet := STR0045 // "Usuário comprador inválido. Verifique o parâmetro MV_SLMCOMP."
									Return {lRet, cXmlRet}
								Else
									cUser		:= RetCodUsr(cUserPar)
									
									If Empty(cUser)
										lRet := .F.
										cXmlRet := STR0049 + AllTrim(cUserPar) + STR0050 // "Usuário: " # " não encontrado nos usuarios do Protheus. Verifique o parametro e respeite as letras maiusculas e minusculas."
										Return {lRet, cXmlRet}
									EndIf	
								EndIf
	                           			                       	  
								If !Empty(cUser)
									aAdd(aItemAux, {"C7_USER", cUser, Nil})
								Endif
	                        Endif
                        EndIf
						   
 					    	aAdd(aItemAux, {"C7_ORIGEM","MSGEAI",Nil})
 					    	
 					    	If SC7->(ColumnPos("C7_APROPRM")) > 0 .And. Type("oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_TaskCostAssignmentDocument:Text") != "U" .AND. !Empty(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_TaskCostAssignmentDocument:Text)
					 			cTpAprop := Alltrim(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_TaskCostAssignmentDocument:Text)
								AADD(aItemAux,{"C7_APROPRM",StrTran(cTpAprop,'0',''),NIL})
					 		Endif
 					    	
 					    	//Dedução
 					    	If Type("oXmlAux:_DeductionValue:Text") != "U" .And. !Empty(oXmlAux:_DeductionValue:Text)
	                     	If lRetDedFat
	                     		aAdd(aItemAux, {"C7_DEDUCAO", Val(oXmlAux:_DeductionValue:Text), Nil})
	                     	Endif
	                     Endif
	                     
	                     //Retenção
	                     If Type("oXmlAux:_RetentionValue:Text") != "U" .And. !Empty(oXmlAux:_RetentionValue:Text)
	                     	If lRetDedFat
	                     		aAdd(aItemAux, {"C7_RETENCA", Val(oXmlAux:_RetentionValue:Text), Nil})
	                     	Endif
	                     Endif
	                     
	                     //Faturamento direto 
	                     If Type("oXmlAux:_DirectDeductionValue:Text") != "U" .And. !Empty(oXmlAux:_DirectDeductionValue:Text)
	                     	If lRetDedFat
	                     		aAdd(aItemAux, {"C7_FATDIRE", Val(oXmlAux:_DirectDeductionValue:Text), Nil})
	                     	Endif
	                     Endif
						   
                        aAdd(aItens, aClone(aItemAux))

                        //Se não for array
                        If Type("oXmlAux:_ListOfApportionOrderItem:_ApportionOrderItem") != "U"
                        
	                        If Type("oXmlAux:_ListOfApportionOrderItem:_ApportionOrderItem") != "A"
	                           //Transforma em array
	                           XmlNode2Arr(oXmlAux:_ListOfApportionOrderItem:_ApportionOrderItem, "_ApportionOrderItem")
	                        EndIf
	
	                        For nI2 := 1 To Len(oXmlAux:_ListOfApportionOrderItem:_ApportionOrderItem)
	                           //Atualiza objeto com a posição atual
	                           oXmlRat := oXmlAux:_ListOfApportionOrderItem:_ApportionOrderItem[nI2]
	
	                           //Possui centro de custo informado
	                           If Type("oXmlRat:_CostCenterInternalId:Text") != "U" .And. !Empty(oXmlRat:_CostCenterInternalId:Text)
	                              // Possui percentual informado
	                              If Type("oXmlRat:_Percentual:Text") != "U" .And. !Empty(oXmlRat:_Percentual:Text)
	                                 // O centro de Custo existe no de/para e na base
	                                 aAux := IntCusInt(oXmlRat:_CostCenterInternalId:Text, cMarca)
	                                 If !aAux[1]
	                                    lRet := .F.
	                                    cXmlRet := aAux[2] + STR0021 /*" Item "*/ + AllTrim(oXmlAux:_OrderItem:Text) + "."
	                                    Return {lRet, cXmlRet}
	                                 EndIf
	
	                                 //Valida o Centro de Custo obtido
	                                 aItemAux := IntVldCC(aAux[2][3], Date(), "MATI120")
	                                 If !aItemAux[1]
	                                    lRet := .F.
	                                    cXmlRet := aItemAux[2] + STR0021 /*" Item "*/ + AllTrim(oXmlAux:_OrderItem:Text) + "."
	                                    Return {lRet, cXmlRet}
	                                 EndIf
	
	                                 // Verifica se já existe o centro de custo para este item
	                                 nI3 := aScan(aCCusto, {|x| RTrim(x[3]) == RTrim(aAux[2][3])})
	
	                                 // Caso já exista o centro de custo para o item somar o %
	                                 If nI3 > 0
	                                    aCCusto[nI3][2] += Val(oXmlRat:_Percentual:Text)
	                                 Else
	                                    aAdd(aCCusto, {cItemSC7, Val(oXmlRat:_Percentual:Text), aAux[2][3]})
	                                 EndIf
	                              Else
	                                 lRet := .F.
	                                 cXmlRet := STR0022 + cItemSC7 + "." //"Percentual de rateio inválido para o item "
	                                 Return {lRet, cXmlRet}
	                              EndIf
	                           EndIf
	
	                           // Possui projeto informado
	                           If Type("oXmlRat:_ProjectInternalId:Text") != "U" .And. !Empty(oXmlRat:_ProjectInternalId:Text)
	                              // O projeto possui um código válido?
	                              aAux := IntPrjInt(oXmlRat:_ProjectInternalId:Text, cMarca, cPrjVer) //Empresa/Filial/Projeto
	                              If !aAux[1]
	                                 lRet := .F.
	                                 cXmlRet := aAux[2] + STR0021 /*" Item "*/ + AllTrim(oXmlAux:_OrderItem:Text) + "."
	                                 Return {lRet, cXmlRet}
	                              Else
	                                 xAux := aAux[2][3]
	                              EndIf
	
	                              // Possui tarefa informada
	                              If Type("oXmlRat:_TaskInternalId:Text") != "U" .And. !Empty(oXmlRat:_TaskInternalId:Text)
	                                 // A tarefa possui um código válido?
	                                 aAux := IntTrfInt(oXmlRat:_TaskInternalId:Text, cMarca, cTrfVer) //Empresa/Filial/Projeto/Revisao/Tarefa
	                                 If !aAux[1]
	                                    lRet := .F.
	                                    cXmlRet := aAux[2] + STR0021 /*" Item "*/ + AllTrim(oXmlAux:_OrderItem:Text) + "."
	                                    Return {lRet, cXmlRet}
	                                 EndIf
	                              Else
	                                 lRet := .F.
	                                 cXmlRet := STR0023 /*"Tarefa inválida para o item "*/ + cItemSC7 + "."
	                                 Return {lRet, cXmlRet}
	                              EndIf
	
	                              // Possui quantidade informada
	                              If Type("oXmlRat:_Quantity:Text") != "U" .And. !Empty(oXmlRat:_Quantity:Text)
	                                 // Verifica se já existe o projeto e tarefa para o item
	                                 nI4 := aScan(aProjeto, {|x| RTrim(x[1]) == RTrim(aAux[2][3]) .And. RTrim(x[3]) == RTrim(aAux[2][5])})
	
	                                 // Caso já exista o projeto/tarefa somar a quantidade
	                                 If nI4 > 0
	                                    aProjeto[nI4][4] += Val(oXmlRat:_Quantity:Text)
	                                 Else
	                                    aAdd(aProjeto, {xAux, aAux[2][4], aAux[2][5], Val(oXmlRat:_Quantity:Text), Nil, cItemSC7, Nil})
	                                 EndIf
	                              Else
	                                 lRet := .F.
	                                 cXmlRet := STR0024 /*"Quantidade de rateio inválido para o item "*/ + cItemSC7 + "."
	                                 Return {lRet, cXmlRet}
	                              EndIf
	                           EndIf
	                        Next nI2
	                    Endif
							
							If Len(aCCusto) > 0
	                        // Monta o array com os itens do rateio de centro de custo agrupados por centro de custo
	                        aAdd(aItensRat, Array(2))
	                        aItensRat[nI][1] := cItemSC7
	                        aItensRat[nI][2] := {}
	
	                        For nI5 := 1 To Len(aCCusto)
	                           aAdd(aLinha, {"CH_FILIAL", xFilial("SCH"),                       Nil})
	                           aAdd(aLinha, {"CH_ITEMPD", aCCusto[nI5][1],                      Nil})
	                           aAdd(aLinha, {"CH_ITEM",   PadL(nI5, TamSx3("CH_ITEM")[1], "0"), Nil})
	                           aAdd(aLinha, {"CH_PERC",   aCCusto[nI5][2],                      Nil})
	                           aAdd(aLinha, {"CH_CC",     aCCusto[nI5][3],                      Nil})
	
	                           aAdd(aItensRat[nI][2], aClone(aLinha))
	                           aLinha := {}
	                        Next nI5
							Endif

                        aCCusto := {}
							
							If Len(aProjeto) > 0
	                        // Monta o array com os itens do rateio de projeto agrupados por projeto/tarefa
	                        For nI5 := 1 To Len(aProjeto)
	                           aAdd(aLinha, {"AJ7_PROJET", PadR(aProjeto[nI5][1], TamSx3("AJ7_PROJET")[1]), Nil})
	                           aAdd(aLinha, {"AJ7_TAREFA", PadR(aProjeto[nI5][3], TamSx3("AJ7_TAREFA")[1]), Nil})
	                           aAdd(aLinha, {"AJ7_QUANT",  aProjeto[nI5][4],                                Nil})
	                           aAdd(aLinha, {"AJ7_ITEMPC", aProjeto[nI5][6],                       			Nil})
	                           aAdd(aLinha, {"AJ7_NUMPC", Iif(Empty(cNumPed),"cNumPCWS",cNumPed) , 			Nil})
	                           aAdd(aLinha, {"AJ7_REVISA", "0001",                                			Nil})

							   nPosProd := aScan(aItens[nI], {|x| x[1] == "C7_PRODUTO"})
							   If nPosProd > 0
									aAdd(aLinha, {"AJ7_COD", aItens[nI][nPosProd][2], Nil})
							   EndIf
		
	                           aAdd(aItensPrj, aClone(aLinha))
	                           aLinha := {}
	                        Next nI5
	                      Endif

                        aProjeto := {}
                        
                        If Len(aCCusto) > 0
								//Caso tenha rateio de centro de custo excluir o centro de custo do item para evitar erro
								nCount := aScan(aItens[nI], {|x| x[1] == "C7_CC"})
								If nCount > 0
									aDel(aItens[nI], nCount)
									aSize(aItens[nI], Len(aItens[nI]) - 1)
								EndIf
							EndIf
                     Next nI

                     //Se não for array
                     If Type("oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfCreditDocument:_CreditDocument") != "U" .And. !Empty(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfCreditDocument:_CreditDocument)
                        If !Adiantamento(cCond)
                           lRet    := .F.
                           cXmlRet := STR0046 //"Para utilizar título de adiantamento a condição de pagamento do pedido deve ser do tipo adiantamento."
                           Return {lRet, cXmlRet}
                        EndIf

                        If Type("oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfCreditDocument:_CreditDocument") != "A"
                           //Transforma em array
                           XmlNode2Arr(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfCreditDocument:_CreditDocument, "_CreditDocument")
                        EndIf

                        For nI := 1 To Len(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfCreditDocument:_CreditDocument)
                           //Atualiza objeto com a posição atual
                           oXmlAux := oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfCreditDocument:_CreditDocument[nI]

                           //Adiantamentos
                           If Type("oXmlAux:_CreditDocumentInternalId:Text") != "U" .And. !Empty(oXmlAux:_CreditDocumentInternalId:Text)
                              aAux := IntTPgInt(oXmlAux:_CreditDocumentInternalId:Text, cMarca, cTPgVer)

                              If !aAux[1]
                                 lRet    := aAux[1]
                                 cXmlRet := aAux[2]
                                 Return {lRet, cXmlRet}
                              EndIf
                           Else
                              lRet    := .F.
                              cXmlRet := STR0047 //"O InternalID do título de adiantamento não foi informado."
                              Return {lRet, cXmlRet}
                           EndIf

                           If Type("oXmlAux:_Value:Text") == "U" .Or. Empty(oXmlAux:_Value:Text)
                              lRet    := .F.
                              cXmlRet := STR0048 //"O valor a ser abatido no título de adiantamento não foi informado."
                              Return {lRet, cXmlRet}
                           EndIf

                           aAdd(aLinha, {"FIE_FILIAL", xFilial("FIE"),                            Nil})
                           aAdd(aLinha, {"FIE_CART",   "P",                                       Nil}) // Carteira pagar
                           aAdd(aLinha, {"FIE_PEDIDO", "",                                        Nil}) // Não precisa, pois quem trata é a a120adiantamento()
                           aAdd(aLinha, {"FIE_PREFIX", PadR(aAux[2][3], TamSX3("FIE_PREFIX")[1]), Nil})
                           aAdd(aLinha, {"FIE_NUM",    PadR(aAux[2][4], TamSX3("FIE_NUM")[1]),    Nil})
                           aAdd(aLinha, {"FIE_PARCEL", PadR(aAux[2][5], TamSX3("FIE_PARCEL")[1]), Nil})
                           aAdd(aLinha, {"FIE_TIPO",   PadR(aAux[2][6], TamSX3("FIE_TIPO")[1]),   Nil})
                           aAdd(aLinha, {"FIE_FORNEC", PadR(aAux[2][7], TamSX3("FIE_FORNEC")[1]), Nil})
                           aAdd(aLinha, {"FIE_LOJA",   PadR(aAux[2][8], TamSX3("FIE_LOJA")[1]),   Nil})
                           aAdd(aLinha, {"FIE_VALOR",  Val(oXmlAux:_Value:Text),                  Nil}) // Valor do pa que está vinculado ao pedido

                           aAdd(aAdtPC, aClone(aLinha))
                           aLinha := {}
                        Next nI
                     EndIf

                     // Rateio de desconto
                     For nI := 1 To Len(aDescUnit)
                        aDescUnit[nI][3] := Round(nDescTotal * aDescUnit[nI][2] / nValorTotal,TamSx3("C7_VLDESC")[2])

                        nI2 := aScan(aItens[nI], {|x| x[1] == "C7_VLDESC"})

                        If nI2 > 0
                           aItens[nI][nI2][2] += aDescUnit[nI][3]
                        Else
                           aAdd(aItens[nI], {"C7_VLDESC", aDescUnit[nI][3], Nil})
                        EndIf
                     Next nI
                  EndIf

                  If ExistBlock("ITMT120")
						aRetPe := ExecBlock("ITMT120",.F.,.F.,{aCab,aItens,aItensRat,aItensPrj})
						If ValType(aRetPe) == "A" .And. Len(aRetPe) >0
							If ValType(aRetPe[1]) == "A"
								aCab := aClone(aRetPe[1])
							EndIf
							If ValType(aRetPe[2]) == "A" 
								aItens := aClone(aRetPe[2])
							EndIf
							If ValType(aRetPe[3]) == "A" 
								aItensRat := aClone(aRetPe[3])
							EndIf
							If ValType(aRetPe[4]) == "A" 
								aItensPrj := aClone(aRetPe[4])
							EndIf
						EndIf
					 EndIf					
					 
                  BeginTran()
					
                  If nOpcx == 5
                     MsExecAuto({|v,x,y,z| MATA120(v, x, y, z)}, 1, aCab, aItens, nOpcx)
                  Else
              		If Len(aItensRat) > 0
                     	MsExecAuto({|v,x,y,z,a,b,c,d| MATA120(v,x,y,z,a,b,c,d)}, 1, aCab, aItens, nOpcx, .F., aItensRat, aAdtPC)
                 		Else
                     	MsExecAuto({|v,x,y,z,a,b,c,d| MATA120(v,x,y,z,a,b,c,d)}, 1, aCab, aItens, nOpcx, .F., , aAdtPC)
                     Endif
                  EndIf
      
                  // Se houve erros no processamento do MSExecAuto
                  If lMsErroAuto
                     aErroAuto := GetAutoGRLog()

                     cXMLRet := "<![CDATA["
                     For nI := 1 To Len(aErroAuto)
                        cXMLRet += aErroAuto[nI] + Chr(10)
                     Next nI
                     cXMLRet += "]]>"

                     lRet := .F.

                     //Desfaz a transacao
                     DisarmTransaction()
                     msUnlockAll()
                  Else
                  	If Len(aItensPrj) > 0
                  		If nOpcx <> 5
		                  	For n1Cnt := 1 To Len(aItensPrj)
									If (n2Cnt := aScan(aItensPrj[n1Cnt], {|x| x[1] == "AJ7_NUMPC"})) > 0
										aItensPrj[n1Cnt, n2Cnt, 2] := cNumPCWS
									EndIf
								Next n1Cnt
							Endif
						Else
							If nOpcX == 5
								aAdd(aLinha, {"AJ7_PROJET","", Nil})
	                       	aAdd(aLinha, {"AJ7_TAREFA","", Nil})
	                       	aAdd(aLinha, {"AJ7_QUANT",0,Nil})
	                       	aAdd(aLinha, {"AJ7_ITEMPC","",Nil})
	                       	aAdd(aLinha, {"AJ7_NUMPC",cNumPed,Nil})
	                       	aAdd(aLinha, {"AJ7_REVISA","0001",Nil})
	                       	
	                       	aAdd(aItensPrj,aClone(aLinha))
							Endif
						Endif
							
						If Len(aItensPrj) > 0
                  		pmsWs120(AllTrim(Str(nOpcx)),aItensPrj)
                  	Endif
                  	
                    If nOpcx == 3 //INSERT
                        // Monta o InternalId com a variável cNumPCWS (número do pedido gerado)
                        // Esta variável é povoada somente após a execução da Rotina Automática
                        cValInt := IntPdCExt(/*Empresa*/, /*Filial*/, cNumPCWS, Nil, cPdCVer)[2]
                        //Insere o registro na tabela XXF (de/para)
                        CFGA070Mnt(cMarca, cAlias, cField, cValExt, cValInt, .F., 1)
                     ElseIf nOpcx == 4 //UPDATE
                        //Atualiza o registro na tabela XXF (de/para)
                        CFGA070Mnt(cMarca, cAlias, cField, cValExt, cValInt, .F., 1)
                     Else //DELETE
                        //Exclui o registro na tabela XXF (de/para)
                        CFGA070Mnt(cMarca, cAlias, cField, cValExt, cValInt, .T., 1)
                     EndIf

                     //Loop para manipular os Itens na tabela XXF (de/para)
                     For nI := 1 To Len(aDePara)
                        If nOpcx == 3 // INSERT
                           cValIntI := IntPdCExt(/*Empresa*/, /*Filial*/, cNumPCWS, aDePara[nI][2], cPdCVer)[2]
                           CFGA070Mnt(cMarca, aDePara[nI][3], aDePara[nI][4], aDePara[nI][1], cValIntI, .F., 1)
                        ElseIf nOpcx == 4 // UPDATE
                           cValIntI := IntPdCExt(/*Empresa*/, /*Filial*/, cNumPed, aDePara[nI][2], cPdCVer)[2]
                           CFGA070Mnt(cMarca, aDePara[nI][3], aDePara[nI][4], aDePara[nI][1], cValIntI, .F., 1)
                        Else // DELETE
                           CFGA070Mnt(cMarca, aDePara[nI][3], aDePara[nI][4], aDePara[nI][1], aDePara[nI][2], .T., 1)
                        EndIf
                     Next nI

                     // Monta o XML de retorno (CAPA)
                     cXMLRet := "<ListOfInternalId>"
                     cXMLRet +=    "<InternalId>"
                     cXMLRet +=       "<Name>OrderInternalId</Name>"
                     cXMLRet +=       "<Origin>" + cValExt + "</Origin>"
                     If nOpcx == 3 // Insert
                        cXMLRet +=    "<Destination>" + IntPdCExt(/*Empresa*/, /*Filial*/, cNumPCWS, Nil, cPdCVer)[2] + "</Destination>"
                     Else
                        cXMLRet +=    "<Destination>" + IntPdCExt(/*Empresa*/, /*Filial*/, aAux[2][3], Nil, cPdCVer)[2] + "</Destination>"
                     EndIf
                     cXMLRet +=    "</InternalId>"
                     // Itens
                     For nI := 1 To Len(aDePara)
                        cXMLRet += "<InternalId>"
                        cXMLRet +=    "<Name>ItemInternalId</Name>"
                        cXMLRet +=    "<Origin>" + aDePara[nI][1] + "</Origin>"
                        If nOpcx == 3 // Insert
                           cXMLRet += "<Destination>" + IntPdCExt(/*Empresa*/, /*Filial*/, cNumPCWS, aDePara[nI][2], cPdCVer)[2] + "</Destination>"
                        ElseIf nOpcx == 3 // Update
                           cXMLRet += "<Destination>" + IntPdCExt(/*Empresa*/, /*Filial*/, cNumPed, aDePara[nI][2], cPdCVer)[2] + "</Destination>"
                        Else // Delete
                           cXMLRet += "<Destination>" + aDePara[nI][2] + "</Destination>"
                        EndIf
                        cXMLRet += "</InternalId>"
                     Next
                     cXMLRet += "</ListOfInternalId>"
                  EndIf

                  EndTran()
                  MsUnlockAll()
               ElseIf AllTrim(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_OrderPurpose:Text) == "2"
                  aAdd(aRet, FWIntegDef("MATA410", cTypeMessage, nTypeTrans, cXML))
					
                  If ValType(aRet) == "A"
	                  If !Empty(aRet)
	                     lRet := aRet[1][1]
	                     cXmlRet += aRet[1][2]
	                  EndIf
	               Endif
               Else
                  lRet:= .F.
                  cXmlRet := STR0025 // "Tipo de Pedido inválido!"
                  Return {lRet, cXmlRet}
               EndIf
            Else
               lRet := .F.
               cXmlRet := STR0026 // "Tipo de pedido não enviado."
               Return {lRet, cXmlRet}
            EndIf
         Else
            lRet := .F.
            cXMLRet := STR0027 // "Erro no parser!"
            Return {lRet, cXmlRet}
         EndIf
      ElseIf cTypeMessage == EAI_MESSAGE_RESPONSE
         //Faz o parser do XML de retorno em um objeto
         oXML := xmlParser(cXML, "_", @cError, @cWarning)

         //Se não houve erros na resposta
         If Upper(oXML:_TOTVSMessage:_ResponseMessage:_ProcessingInformation:_Status:Text) == "OK"
            //Verifica se a marca foi informada
            If Type("oXML:_TOTVSMessage:_MessageInformation:_Product:_name:Text") != "U" .And. !Empty(oXML:_TOTVSMessage:_MessageInformation:_Product:_name:Text)
               cMarca := oXML:_TOTVSMessage:_MessageInformation:_Product:_name:Text
            Else
               lRet := .F.
               cXmlRet := STR0028 // "Erro no retorno. O Product é obrigatório!"
               Return {lRet, cXmlRet}
            EndIf
			  
            If Type("oXML:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InternalId") != "U"
            
	            //Se não for array
	            If Type("oXML:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InternalId") != "A"
	               //Transforma em array
	               XmlNode2Arr(oXML:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InternalId, "_InternalId")
	            EndIf
	
	            For nI := 1 To Len(oXML:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InternalId)
	               aAdd(aDePara, Array(3))
					 cNameInternalId := oXML:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InternalId[nI]:_Name:Text
					 
	               //Verifica se o InternalId foi informado
	               If Type("oXML:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InternalId[" + Str(nI) + "]:_Origin:Text") != "U" .And. !Empty(oXML:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InternalId[nI]:_Origin:Text)
	                  //Não armazena Rateio
	                  If 'ORDER' $ AllTrim(Upper(cNameInternalId)) .Or. 'ITEM' $ AllTrim(Upper(cNameInternalId))
	                     aDePara[nI][1] := oXML:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InternalId[nI]:_Origin:Text
	                  EndIf
	               Else
	                  lRet    := .F.
	                  cXmlRet := STR0029 // "Erro no retorno. O OriginalInternalId é obrigatório!"
	                  Return {lRet, cXmlRet}
	               EndIf
	
	               //Verifica se o código externo foi informado
	               If Type("oXML:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InternalId[" + Str(nI) + "]:_Destination:Text") != "U" .And. !Empty(oXML:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InternalId[nI]:_Destination:Text)
	                  //Não armazena Rateio
	                  If 'ORDER' $ AllTrim(Upper(cNameInternalId)) .Or. 'ITEM' $ AllTrim(Upper(cNameInternalId))
	                     aDePara[nI][2] := oXML:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InternalId[nI]:_Destination:Text
	                  EndIf
	               Else
	                  lRet    := .F.
	                  cXmlRet := STR0030 // "Erro no retorno. O DestinationInternalId é obrigatório!"
	                  Return {lRet, cXmlRet}
	               EndIf
	
	               If 'ORDER' $ AllTrim(Upper(cNameInternalId))
	                  aDePara[nI][3] := cField
	               ElseIf 'ITEM' $ AllTrim(Upper(cNameInternalId))
	                  aDePara[nI][3] := "C7_ITEM"
	               EndIf
	
	               //Incrementa contador que será utilizado no de/para
	               If 'ORDER' $ AllTrim(Upper(cNameInternalId)) .Or. 'ITEM' $ AllTrim(Upper(cNameInternalId))
	                  nCont++
	               EndIf
	            Next nI
	
	            //Obtém a mensagem original enviada
	            If Type("oXML:_TOTVSMessage:_ResponseMessage:_ReceivedMessage:_MessageContent:Text") != "U" .And. !Empty(oXml:_TOTVSMessage:_ResponseMessage:_ReceivedMessage:_MessageContent:Text)
	               cXML := oXml:_TOTVSMessage:_ResponseMessage:_ReceivedMessage:_MessageContent:Text
	            Else
	               lRet := .F.
	               cXmlRet := STR0031 // "Conteúdo do MessageContent vazio!"
	               Return {lRet, cXmlRet}
	            EndIf
	
	            //Faz o parse do XML em um objeto
	            oXML := XmlParser(cXML, "_", @cError, @cWarning)
	
	            If Empty(oXML) .And. "UTF-8" $ Upper(cXML)
	               oXML := xmlParser(EncodeUTF8(cXML), "_", @cError, @cWarning)
	            EndIf
	
	            //Se não houve erros no parse
	            If oXML != Nil .And. Empty(cError) .And. Empty(cWarning)
	               //Loop para manipular os InternalId no de/para
	               For nI := 1 To nCont
	                  If Upper(oXML:_TOTVSMessage:_BusinessMessage:_BusinessEvent:_Event:Text) == "UPSERT"
	                     //Insere / Atualiza o registro na tabela XXF (de/para)
	                     CFGA070Mnt(cMarca, cAlias, aDePara[nI][3], aDePara[nI][2], aDePara[nI][1], .F., 1)
	                  ElseIf Upper(oXML:_TOTVSMessage:_BusinessMessage:_BusinessEvent:_Event:Text) == "DELETE"
	                     //Exclui o registro na tabela XXF (de/para)
	                     CFGA070Mnt(cMarca, cAlias, aDePara[nI][3], aDePara[nI][2], aDePara[nI][1], .T., 1)
	                  Else
	                     lRet := .F.
	                     cXmlRet := STR0032 // "Evento do retorno inválido!"
	                  EndIf
	               Next nI
	            Else
	               lRet := .F.
	               cXmlRet := STR0033 // "Erro no parser do retorno!"
	               Return {lRet, cXmlRet}
	            EndIf
	        Endif
         Else
            //Se não for array
            If Type("oXML:_TOTVSMessage:_ResponseMessage:_ProcessingInformation:_ListOfMessages:_Message") != "A"
               //Transforma em array
               XmlNode2Arr(oXML:_TOTVSMessage:_ResponseMessage:_ProcessingInformation:_ListOfMessages:_Message, "_Message")
            EndIf

            //Percorre o array para obter os erros gerados
            For nI := 1 To Len(oXML:_TOTVSMessage:_ResponseMessage:_ProcessingInformation:_ListOfMessages:_Message)
               cError := oXML:_TOTVSMessage:_ResponseMessage:_ProcessingInformation:_ListOfMessages:_Message[nI]:Text + Chr(10)
            Next nI

            lRet := .F.
            cXmlRet := cError
         EndIf
      ElseIf cTypeMessage == EAI_MESSAGE_WHOIS
         cXMLRet := '2.000|3.000|3.001|3.002|3.004|3.005|3.006|3.007|4.003'
      EndIf
   // Mensagem de Saída
   ElseIf nTypeTrans == TRANS_SEND
   	  	SC7->(dbSetOrder(1))
   	  	SC7->(dbSeek(xFilial("SC7")+Iif(Type("cA120Num")=="C",cA120Num,SC7->C7_NUM)))
      
      	If !Inclui .And. !Altera
      		cEvent := "delete"
      		CFGA070Mnt(,"SC7","C7_NUM",,IntPdCExt(/*Empresa*/, /*Filial*/, SC7->C7_NUM, Nil, cPdCVer)[2],.T.)
      		
      		cNumDel	:= SC7->C7_NUM
      		While SC7->(!EOF()) .And. SC7->C7_NUM == cNumDel
      			CFGA070Mnt(,"SC7","C7_ITEM",,IntPdCExt(/*Empresa*/, /*Filial*/, SC7->C7_NUM, SC7->C7_ITEM,cPdCVer)[2],.T.)
      			SC7->(DbSkip())
      		Enddo
      		
      		SC7->(dbSeek(xFilial("SC7")+Iif(Type("cA120Num")=="C",cA120Num,SC7->C7_NUM)))
      	Else
      		cEvent := "upsert"	
      	Endif
      	
      	cXMLRet := '<BusinessEvent>'
		cXMLRet +=    '<Entity>Order</Entity>'
		cXMLRet +=    '<Event>' + cEvent + '</Event>'
		cXMLRet +=    '<Identification>'
		cXMLRet +=       '<key name="InternalId">' + IntPdCExt(/*Empresa*/, /*Filial*/, SC7->C7_NUM, Nil, cPdCVer)[2] + '</key>'
		cXMLRet +=    '</Identification>'
		cXMLRet += '</BusinessEvent>'
		cXMLRet += '<BusinessContent>'
		cXmlRet +=    '<OrderPurpose>1</OrderPurpose>' // 1 - pedido de compra
		cXMLRet +=    '<CompanyId>' + cEmpAnt + '</CompanyId>'
		cXMLRet +=    '<BranchId>' + cFilAnt + '</BranchId>'
		cXMLRet +=    '<CompanyInternalId>' + cEmpAnt + "|" + cFilAnt + '</CompanyInternalId>'
		cXMLRet +=    '<InternalId>' + IntPdCExt(/*Empresa*/, /*Filial*/, SC7->C7_NUM, Nil, cPdCVer)[2] + '</InternalId>'
		cXMLRet +=    '<OrderId>' + SC7->C7_NUM + '</OrderId>'
		cXmlRet +=    '<CustomerInternalId>' + IntForExt(, , SC7->C7_FORNECE, SC7->C7_LOJA, cVenVer)[2] + '</CustomerInternalId>'
      
      	If Len( Separa(SC7->C7_ACCNUM,"|") ) > 1
      		cXMLRet +=      '<contractnumber>' + Separa( SC7->C7_ACCNUM , "|" )[1] + "|" + Separa( SC7->C7_ACCNUM , "|" )[2] + '</contractnumber>'
      	EndIf
      	
      	cXmlRet +=    '<CustomerCode>' + RTrim(SC7->C7_FORNECE) + '</CustomerCode>'
        
        If SA2->(dbSeek(xFilial("SC7") + SC7->C7_FORNECE + SC7->C7_LOJA))
        	cXMLRet += '<CustomerGovInfo>' + (SA2->A2_CGC) + '</CustomerGovInfo>'
        EndIf
        
        cXMLRet +=    '<CurrencyCode>' + StrZero(SC7->C7_MOEDA,TamSX3("CTO_MOEDA")[1],0) + '</CurrencyCode>'
		
		If lMktPlace
			cXMLRet +=    '<CurrencyId>' + '|' + '|' + StrZero(SC7->C7_MOEDA,TamSX3("CTO_MOEDA")[1],0) + '</CurrencyId>'
		Else
			cXMLRet +=    '<CurrencyId>' + C40MontInt(,StrZero(SC7->C7_MOEDA,TamSX3("CTO_MOEDA")[1],0)) + '</CurrencyId>'
		Endif
        
        cXMLRet +=    '<CurrencyRate>' + RTrim(cValToChar(SC7->C7_TXMOEDA)) + '</CurrencyRate>'
        cXMLRet +=    '<PaymentTermCode>' + RTrim(SC7->C7_COND) + '</PaymentTermCode>'
        cXmlRet +=    '<PaymentConditionInternalId >' + IntConExt(, , SC7->C7_COND, cConVer)[2] + '</PaymentConditionInternalId >'
        cXMLRet +=    '<RegisterDate>' + INTDTANO(SC7->C7_EMISSAO) + '</RegisterDate>'
        cXMLRet +=	   '<UserInternalId>' + SC7->C7_USER + '</UserInternalId>'
        
        If AllTrim(SC7->C7_FREPPCC) == "C"
        	cXMLRet +=		'<FreightType>1</FreightType>'
        ElseIf AllTrim(SC7->C7_FREPPCC) == "F"
        	cXMLRet +=		'<FreightType>2</FreightType>'
		Else
			cXMLRet +=		'<FreightType>3</FreightType>'
		Endif

        If lMktPlace
        	cXmlRet+=  '<OTHER>'
            cXmlRet+=     '<ADDFIELDS>'
            cXmlRet+=        '<ADDFIELD>'
            cXmlRet+=           '<field>TipoOrigem</field>'
            cXmlRet+=           '<value>' + QtType() + '</value>'
            cXmlRet+=        '</ADDFIELD>'

            //--------------------------------------
            // Ponto de entrada para adicionar dados
            // ao cabecalho do pedido de compra
            //--------------------------------------
            If Existblock( 'MTI120PC')
               cRetPE:= Execblock( "MTI120PC", .F., .F. )
               If ValType(cRetPE) = 'C'
                  cXMLRet += cRetPE
               EndIf
            EndIf

            cXmlRet+=    '</ADDFIELDS>'
            cXmlRet+= '</OTHER>'
         EndIf

         cXMLRet +=    '<SalesOrderItens>'

         cAliasTMP:=GetNextAlias()
		
		cQuery := "SELECT C7_NUM, C7_ITEM, C7_PRODUTO, C7_UM, C7_DESCRI, C7_QUANT, C7_PRECO, C7_TOTAL, C7_CC, C7_CONTA, C7_DATPRF, C7_VLDESC, C7_VALFRE"
		cQuery += ", C7_SEGURO, C7_OBS, C7_LOCAL, C7_FILIAL, C7_FORNECE, C7_LOJA, C7_RATEIO, C7_QUJE, C7_ENCER, C7_RESIDUO, C7_NUMSC, C7_ITEMSC"
		cQuery += " FROM " + RetSqlName("SC7")
		cQuery += " WHERE C7_FILIAL = '" + xFilial("SC7") + "'"
		cQuery += " AND C7_NUM = '" + SC7->C7_NUM + "'"
		cQuery += " AND D_E_L_E_T_ = ''"
		cQuery += " ORDER BY C7_ITEM"
		cQuery := ChangeQuery(cQuery)
         If Select(cAliasTMP) > 0
            (cAliasTMP)->(dbCloseArea())
         EndIf
         dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTMP,.T.,.T.)
         If Select(cAliasTMP) > 0
            (cAliasTMP)->(dbGoTop())
            While (cAliasTMP)->(!EOF())
               SC7->(dbSetOrder(1))
               SC7->(DbSeek(xFilial("SC7")+(cAliasTmp)->C7_NUM+(cAliasTmp)->C7_ITEM))

               cXmlRet += '<Item>'
               cXmlRet +=    '<CompanyId>' + cEmpAnt + '</CompanyId>'
               cXmlRet +=    '<BranchId>' + xFilial(cAlias) + '</BranchId>'
               cXmlRet +=    '<OrderId>' + (cAliasTmp)->C7_NUM + '</OrderId>'
               cXMLRet +=    '<OrderItem>' + (cAliasTmp)->C7_ITEM + '</OrderItem>'
               cXmlRet +=    '<InternalId>' + IntPdCExt(/*Empresa*/, /*Filial*/, (cAliasTMP)->C7_NUM, (cAliasTMP)->C7_ITEM, cPdCVer)[2] + '</InternalId>'
               cXMLRet +=    '<ItemCode>' + RTrim((cAliasTmp)->C7_PRODUTO) + '</ItemCode>'
				If lMktPlace
					cXMLRet +=	'<ItemInternalId>'+ cEmpAnt +"|"+ RTrim(xFilial("SB1")) +"|"+ RTrim((cAliasTmp)->C7_PRODUTO)+'</ItemInternalId>'
				Else
               cXmlRet +=    '<ItemInternalId>' + IntProExt(, , (cAliasTmp)->C7_PRODUTO, cPrdVer)[2] + '</ItemInternalId>'
				Endif
               cXMLRet +=    '<contractnumber>' + SC7->C7_ACCITEM+ '</contractnumber>'
               cXmlRet +=    '<ItemDescription>' + _NoTags(RTrim((cAliasTmp)->C7_DESCRI)) + '</ItemDescription>'
               cXmlRet +=    '<Quantity>' + RTrim(cValToChar((cAliasTmp)->C7_QUANT)) + '</Quantity>'
				cXMLRet +=	 '<QuantityReached>' + RTrim(cValToChar((cAliasTmp)->C7_QUJE)) + '</QuantityReached>'
               cXmlRet +=    '<UnityPrice>' + RTrim(cValToChar((cAliasTmp)->C7_PRECO)) + '</UnityPrice>'
               cXmlRet +=    '<TotalPrice>' + RTrim(cValToChar((cAliasTmp)->C7_TOTAL)) + '</TotalPrice>'
               If Empty((cAliasTmp)->C7_CC)
                  cXmlRet += '<CostCenterCode/>'
                  cXmlRet += '<CostCenterInternalId/>'
               Else
                  cXmlRet += '<CostCenterCode>' + RTrim((cAliasTmp)->C7_CC) + '</CostCenterCode>'
                  cXmlRet += '<CostCenterInternalId>' + IntCusExt(, , (cAliasTmp)->C7_CC, cCusVer)[2] + '</CostCenterInternalId>'
               EndIf
               cXmlRet +=    '<DeliveryDate>' + INTDTANO((cAliasTmp)->C7_DATPRF) + '</DeliveryDate>'
               cXmlRet +=    '<ItemDiscounts>'
               cXmlRet +=       '<ItemDiscount>' + RTrim(cValToChar((cAliasTmp)->C7_VLDESC)) + '</ItemDiscount>'
               cXmlRet +=    '</ItemDiscounts>'
               cXmlRet +=    '<FreightValue>' + RTrim(cValToChar((cAliasTmp)->C7_VALFRE)) + '</FreightValue>'
               cXmlRet +=    '<InsuranceValue>' + RTrim(cValToChar((cAliasTmp)->C7_SEGURO)) + '</InsuranceValue>'
               cXmlRet +=    '<itemunitofmeasure>' + RTrim((cAliasTmp)->C7_UM) + '</itemunitofmeasure>'
               cXmlRet +=    '<UnitOfMeasureInternalId>' + IntUndExt(, , (cAliasTmp)->C7_UM, cUndVer)[2] + '</UnitOfMeasureInternalId>'
               cXmlRet +=    '<WarehouseInternalId>' + IntLocExt(, , (cAliasTmp)->C7_LOCAL, cLocVer)[2] + '</WarehouseInternalId>'
               cXmlRet +=    '<observation>' + _NoTags(RTrim((cAliasTmp)->C7_OBS)) + '</observation>'

				If !Empty((cAliasTmp)->C7_NUMSC)
					cXmlRet +=    '<RequestItemInternalId>' + IntSCoExt(/*cEmpresa*/, /*cFilial*/, (cAliasTmp)->C7_NUMSC, (cAliasTmp)->C7_ITEMSC, cSCoVer)[2] + '</RequestItemInternalId>'
				Else
					cXmlRet +=    '<RequestItemInternalId/>' 
				Endif
               If lMktPlace
                  //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
                  //³ Local de entrega das mercadorias |
                  //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
                  cXmlRet += '<CROSSDOCKING>'
                  cXmlRet +=    '<CROSSDOCKING_ITEM>'
                  cXmlRet +=       '<dhinidelivery>'+INTDTANO(SC7->C7_DATPRF)+"T00:00:00"+'</dhinidelivery>'
                  cXmlRet +=       '<dhfindelivery>'+INTDTANO(SC7->C7_DATPRF)+"T23:59:00"+'</dhfindelivery>'
                  cXmlRet +=       '<quantdelivery>'+AllTrim(Str(SC7->(C7_QUANT-C7_QUJE)))+'</quantdelivery>'
                  //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
                  //³ Unidade de Medida do Item do Ped.|
                  //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
                  cUnidMed := A120IUnMed(AllTrim(SC7->C7_UM))
                  If !Empty(cUnidMed)
                     cXmlRet +=    '<mensuunit>'+cUnidMed+'</mensuunit>'
                  EndIf
                  cXmlRet +=       '<orderline>'+SC7->C7_ITEM+'</orderline>'
                  cXmlRet +=    '</CROSSDOCKING_ITEM>'
                  cXmlRet += '</CROSSDOCKING>'

                  cXmlRet+=  '<LISTOFTAXESITEM>'
                  cXmlRet+=     '<VALUESANDTAXES>'
                  cXmlRet+=        '<tpvalue>1</tpvalue>'
                  cXmlRet+=        '<tpreasondescandtax>1</tpreasondescandtax>'
                  cXmlRet+=        '<valuedescandtaxes>1</valuedescandtaxes>'
                  cXmlRet+=     '</VALUESANDTAXES>'
                  cXmlRet+=  '</LISTOFTAXESITEM>'
               EndIf

               // Integração com o TOTVS Obras e Projetos
               If IsIntegTop()
                  aRateio := RatPC((cAliasTmp)->C7_FILIAL + (cAliasTmp)->C7_NUM + (cAliasTmp)->C7_ITEM)

                  If Empty(aRateio)
                     cXMLRet += '<ListOfApportionOrderItem/>'
                  Else
                     cXMLRet += '<ListOfApportionOrderItem>'
                     For nI := 1 To Len(aRateio)
                        cXmlRet += '<ApportionOrderItem>'
                        cXmlRet +=    '<InternalId>' + IntPdCExt(/*Empresa*/, /*Filial*/, (cAliasTMP)->C7_NUM, (cAliasTMP)->C7_ITEM, cPdCVer)[2] + '|' + RTrim(cValToChar(nI)) + '</InternalId>'
                        cXMLRet +=    '<DepartamentCode/>'
                        cXMLRet +=    '<DepartamentInternalId/>'
                        If Empty(aRateio[nI][1])
                           cXmlRet += '<CostCenterInternalId/>'
                        Else
                           cXmlRet += '<CostCenterInternalId>' + IntCusExt(, , aRateio[nI][1], cCusVer)[2] + '</CostCenterInternalId>'
                        EndIf
                        If Empty((cAliasTMP)->C7_CONTA)
                           cXmlRet += '<AccountantAcountInternalId/>'
                        Else
                           cXmlRet += '<AccountantAcountInternalId>' + cEmpAnt + "|" + xFilial("CT1") + "|" + AllTrim(aRateio[nI][2]) + '</AccountantAcountInternalId>' //CTBI020
                        EndIf
                        If Empty(aRateio[nI][6])	//Codigo do Projeto
                           cXMLRet += '<ProjectInternalId/>'
                        Else
                           cXMLRet += '<ProjectInternalId>' + IntPrjExt(, , aRateio[nI][6], cPrjVer)[2] + '</ProjectInternalId>' //PMSI200
                        EndIf
                        cXMLRet +=    '<SubProjectInternalId/>'
                        If Empty(aRateio[nI][7])	//Codigo da Tarefa
                           cXMLRet += '<TaskInternalId/>'
                           cXMLRet += '<Value/>'
                           cXMLRet += '<Quantity/>'
                        Else
                           cXMLRet += '<TaskInternalId>' + IntTrfExt(, , aRateio[nI][6], '0001', aRateio[nI][7], cTrfVer)[2] + '</TaskInternalId>'
                           cXMLRet += '<Value>' + RTrim(cValToChar(aRateio[nI][8] * (cAliasTmp)->C7_PRECO)) + '</Value>'
                           cXMLRet += '<Quantity>' + cValToChar(aRateio[nI][8]) + '</Quantity>'
                        EndIf
                        cXMLRet +=    '<Percentual>' + cValToChar(aRateio[nI][5]) + '</Percentual>'
                        cXMLRet += '</ApportionOrderItem>'
                     Next nI

                     cXMLRet += '</ListOfApportionOrderItem>'
                  EndIf
               Else
                 //Rateio por Centro de Custo
                 SCH->(DbSetOrder(1))
                 If SCH->(DbSeek(xFilial(cAlias) + (cAliasTmp)->C7_NUM + (cAliasTmp)->C7_FORNECE + (cAliasTmp)->C7_LOJA + (cAliasTmp)->C7_ITEM))
                    cXmlRet += '<ListOfApportionOrderItem>'
                    nI := 1

                    While SCH->(!EOF() .And. SCH->CH_FILIAL + SCH->CH_PEDIDO + SCH->CH_FORNECE + SCH->CH_LOJA + SCH->CH_ITEMPD == xFilial(cAlias) + (cAliasTmp)->C7_NUM + (cAliasTmp)->C7_FORNECE + (cAliasTmp)->C7_LOJA + (cAliasTmp)->C7_ITEM )
                       cXmlRet += '<ApportionOrderItem>'
                       cXMLRet +=    '<InternalId>' + IntPdCExt(/*Empresa*/, /*Filial*/, (cAliasTMP)->C7_NUM, (cAliasTMP)->C7_ITEM, cPdCVer)[2] + '|' + RTrim(cValToChar(nI)) + '</InternalId>'
                       cXmlRet +=    '<CostCenterInternalId>' + IntCusExt(, , SCH->CH_CC, cCusVer)[2] + '</CostCenterInternalId>'
                       cXMLRet +=    '<AccountantAcountInternalId>' + cEmpAnt + "|" + xFilial("CT1") + "|" + AllTrim(SCH->CH_CONTA) + '</AccountantAcountInternalId>' //CTBI020
                       cXMLRet +=    '<Percentual>' + RTrim(cValToChar(SCH->CH_PERC)) + '</Percentual>'
                       cXmlRet += '</ApportionOrderItem>'

                       nI ++
                       SCH->(DbSkip())
                    EndDo

                    cXmlRet += '</ListOfApportionOrderItem>'
                 EndIf
               EndIf

               cXmlRet+= '</Item>'
           
				If lMktPlace
					SC7->(dbSetOrder(1))
					If SC7->(DbSeek(xFilial("SC7")+(cAliasTmp)->C7_NUM+(cAliasTmp)->C7_ITEM))
						RecLock("SC7")
						SC7->C7_ACCPROC := "1"
						MsUnlock()
					EndIf
				EndIf
       
               (cAliasTmp)->(dbSkip())
            EndDo

            (cAliasTMP)->(dbCloseArea())
         EndIf

         cXmlRet +=    '</SalesOrderItens>'

      cXmlRet += '</BusinessContent>'
   EndIf

Return {lRet, cXMLRet}

// --------------------------------------------------------------------------------------
/*/{Protheus.doc} getPType
Faz o de/para do Tipo de Frete

@param   cTipo      Tipo de Produto
@param   nTypeTrans Tipo da transação

@author  Leandro Luiz da Cruz
@version P11
@since   26/04/2013
@return  cResult Variavel com o valor obtido
/*/
// --------------------------------------------------------------------------------------
Static Function getTpFre(cTipo, nTypeTrans)
   Local cResult := ""

   If nTypeTrans == TRANS_RECEIVE
      Do Case
         Case cTipo == "1"
            cResult := "CIF"
         Case cTipo == "2"
            cResult := "FOB"
         Case cTipo == "3"
            cResult := "SFT"
      EndCase
   ElseIf nTypeTrans == TRANS_SEND
      Do Case
         Case cTipo == "CIF"
            cResult := "1"
         Case cTipo == "FOB"
            cResult := "2"
         Case cTipo == "STF"
            cResult := "3"
      EndCase
   EndIf
Return cResult

//-------------------------------------------------------------------
/*/{Protheus.doc} RatPC
Recebe a chave de busca do Pedido de Compra e monta o rateio.

@author  Leandro Luiz da Cruz
@version P11
@since   13/05/2013

@return aResult
/*/
//-------------------------------------------------------------------
Static Function RatPC(cChave)
   Local aResult  := {}
   Local aPrjtTrf := {}
   Local aCntrCst := {}
   Local nI       := 0
   Local cChaveCC := ""
   Local aAreaSC7 := SC7->(GetArea())
   Local aAreaAJ7 := AJ7->(GetArea())
   Local aAreaSCH := SCH->(GetArea())

   AJ7->(dbSetOrder(2)) // Rateio por Projeto/Tarefa   - AJ7_FILIAL+AJ7_NUMPC+AJ7_ITEMPC+AJ7_PROJET+AJ7_REVISA+AJ7_TAREFA
   SCH->(dbSetOrder(1)) // Rateios por Centro de Custo - CH_FILIAL+CH_PEDIDO+CH_FORNECE+CH_LOJA+CH_ITEMPD+CH_ITEM

   //Povoa o array de Projeto
   If AJ7->(dbSeek(cChave))
      While AJ7->(!EOF()) .And. cChave == AJ7->AJ7_FILIAL + AJ7->AJ7_NUMPC + AJ7->AJ7_ITEMPC
         aAdd(aPrjtTrf, Array(4))
         nI++
         aPrjtTrf[nI][1] := AJ7->AJ7_PROJET
         aPrjtTrf[nI][2] := AJ7->AJ7_REVISA
         aPrjtTrf[nI][3] := AJ7->AJ7_TAREFA
         aPrjtTrf[nI][4] := AJ7->AJ7_QUANT
         AJ7->(dbSkip())
      EndDo
   EndIf

   nI := 0
   cChaveCC := AllTrim((cAliasTmp)->C7_FILIAL + (cAliasTmp)->C7_NUM + (cAliasTmp)->C7_FORNECE + (cAliasTmp)->C7_LOJA + (cAliasTmp)->C7_ITEM)

   //Povoa o array de Centro de Custo
   If Upper((cAliasTmp)->C7_RATEIO) == '1' //Possui rateio de centro de custo
      If SCH->(dbSeek(cChaveCC))
         While SCH->(!EOF()) .And. SCH->CH_FILIAL + SCH->CH_PEDIDO + SCH->CH_FORNECE + SCH->CH_LOJA + SCH->CH_ITEMPD == cChaveCC

            aAdd(aCntrCst, Array(5))
            nI++
            aCntrCst[nI][1] := SCH->CH_CC
            aCntrCst[nI][2] := SCH->CH_CONTA
            aCntrCst[nI][3] := SCH->CH_ITEMCTA
            aCntrCst[nI][4] := SCH->CH_CLVL
            aCntrCst[nI][5] := SCH->CH_PERC
            SCH->(dbSkip())
         EndDo
      EndIf
   EndIf

   //Se não possui rateio de centro de custo buscar dados do item
   If Len(aCntrCst) == 0
      SC7->(dbSetOrder(1)) //C7_FILIAL+C7_NUM+C7_ITEM+C7_SEQUEN

      If SC7->(dbSeek(cChave))
         aAdd(aCntrCst, {SC7->C7_CC, SC7->C7_CONTA, SC7->C7_ITEMCTA, SC7->C7_CLVL, 100})
      EndIF
   EndIf

   aResult := IntRatPrjCC(aCntrCst, aPrjtTrf)

   RestArea(aAreaSC7)
   RestArea(aAreaAJ7)
   RestArea(aAreaSCH)
Return aResult

//-------------------------------------------------------------------
/*/{Protheus.doc} GetDePara
Função para tratamento do de/para de registros da SA7

@param   cValInt InternalID pai

@author  Leandro Luiz da Cruz
@version P11
@since   03/07/2013
@return  aResult Array contendo no primeiro parâmetro o valor do
         InternalId de origem e no segundo parâmetro o InternalId
         de destino.
/*/
//-------------------------------------------------------------------
Static Function GetDePara(cRefer, cChave, cVersao)
   Local aResult  := {}
   Local cValInt  := ""
   Local cValExt  := ""
   Local aAreaAnt := GetArea()

   DbSelectArea("SC7")
   SC7->(DbSetOrder(1))

   If SC7->(DbSeek(cChave))
      While SC7->(!EOF()) .And. xFilial("SC7") + SC7->C7_NUM == cChave
         cValInt := IntPdCExt(/*Empresa*/, /*Filial*/, SC7->C7_NUM, SC7->C7_ITEM, cVersao)[2]
         cValExt := RTrim(CFGA070Ext(cRefer, "SC7", "C7_ITEM", cValInt))
         aAdd(aResult, {cValExt, cValInt, "SC7", "C7_ITEM"})
         SC7->(DbSkip())
      EndDo
   EndIf

   RestArea(aAreaAnt)
Return aResult

//-------------------------------------------------------------------
/*/{Protheus.doc} IntPdCExt
Monta o InternalID do Pedido de compra ou dos itens de acordo
com os parâmetros passados

@param   cEmpresa Código da empresa (Default cEmpAnt)
@param   cFil     Código da Filial (Default xFilial(SC1))
@param   cDoc     Número do Pedido de compra
@param   cItem    Item do Pedido de compra
@param   cVersao  Versão da mensagem única (Default 3.002)

@author  Leandro Luiz da Cruz
@version P11
@since   03/07/2013
@return  aResult Array contendo no primeiro parâmetro uma variável
         lógica indicando se o registro foi encontrado.
         No segundo parâmetro uma variável string com o InternalID
         montado.

@sample  IntPdCExt(,,'0001','01') irá retornar {.T.,'01|01|00001|001|1'}
/*/
//-------------------------------------------------------------------
Function IntPdCExt(cEmpresa, cFil, cDoc, cItem, cVersao)
   Local   aResult  := {}
   Local   cTemp    := ""
   Local cVerWhois  := "3.000|3.001|3.002|3.004|3.005|3.006|3.007|4.003"
   Default cEmpresa := cEmpAnt
   Default cFil     := xFilial('SC7')
   Default cVersao  := '3.002'

   If cVersao == "2.000"
      If Empty(cItem)
         cTemp := cFil + cDoc
      Else
         cTemp := cFil + cDoc + cItem
      EndIf
      aAdd(aResult, .T.)
      aAdd(aResult, cTemp)
   ElseIf cVersao $ cVerWhois
      If Empty(cItem)
         // Montagem do InternalId de cabeçalho (SC7)
         cTemp := cEmpresa + '|' + RTrim(cFil) + '|' + RTrim(cDoc) + '|1'
      Else
         // Montagem do InternalId do item (SC7)
         cTemp := cEmpresa + '|' + RTrim(cFil) + '|' + RTrim(cDoc) + "|" + RTrim(cItem) + '|1'
      EndIf
      aAdd(aResult, .T.)
      aAdd(aResult, cTemp)
   Else
      aAdd(aResult, .F.)
      aAdd(aResult, "Versão não suportada. As versões suportadas são: 2.000|" + cVerWhois)
   EndIf
Return aResult

//--------------------------------------------------------------------
/*/{Protheus.doc} IntPdCInt
Recebe um InternalID e retorna o código do Pedido de Compra.

@param   cInternalID InternalID recebido na mensagem.
@param   cRefer      Produto que enviou a mensagem
@param   cVersao     Versão da mensagem única (Default 3.002)

@author  Leandro Luiz da Cruz
@version P11
@since   04/07/2013
@return  aResult Array contendo no primeiro parâmetro uma variável
         lógica indicando se o registro foi encontrado no de/para.
         No segundo parâmetro uma variável array com a empresa,
         filial, o número do pedido e o item do pedido caso seja o
         InternalID do item.

@sample  IntPdCInt('01|01|001') irá retornar {.T., {'01', '01', '001'}}
/*/
//--------------------------------------------------------------------
Function IntPdCInt(cInternalID, cRefer, cVersao)
   Local   aResult  := {}
   Local   aTemp    := {}
   Local   cTemp    := ''
   Local cVerWhois  := "3.000|3.001|3.002|3.004|3.005|3.006|3.007|4.003"
   Local   cAlias   := 'SC7'
   Local   cField   := 'C7_NUM'
   Default cVersao  := '3.002'

   cTemp := CFGA070Int(cRefer, cAlias, cField, cInternalID)

   If Empty(cTemp)
      cTemp := CFGA070Int(cRefer, cAlias, "C7_ITEM", cInternalID)
   EndIf

   If Empty(cTemp)
      aAdd(aResult, .F.)
      aAdd(aResult, "Pedido de Compra " + AllTrim(cInternalID) + " não encontrado no de/para")
   Else
      If cVersao == '2.000'
         aAdd(aResult, .T.)
         aAdd(aTemp, SubStr(cTemp, 1, TamSX3('C7_FILIAL')[1]))
         aAdd(aTemp, SubStr(cTemp, 1 + TamSX3('C7_FILIAL')[1], TamSX3('C7_NUM')[1]))
         aAdd(aResult, aTemp)
      ElseIf cVersao $ cVerWhois
         aAdd(aResult, .T.)
         aTemp := Separa(cTemp, '|')
         aAdd(aResult, aTemp)
      Else
         aAdd(aResult, .F.)
         aAdd(aResult, "Versão do pedido de compra não suportada. As versões suportadas são: 2.000|" + cVerWhois)
      EndIf
   EndIf
Return aResult

//--------------------------------------------------------------------
/*/{Protheus.doc} Adiantamento
Recebe uma condição de pagamento e retorna se ela é do tipo adiantamento.

@param   cCond Código da condição de pagamento.

@author  Mateus Gustavo de Freitas e Silva
@version P11
@since   10/12/2013
@return  cResult Valor lógico indicando se a condição de pagamento é do
          tipo adiantamento.
/*/
//--------------------------------------------------------------------
Static Function Adiantamento(cCond)
   Local cResult    := .F.
   Local cE4_CTRADT := ""

   cE4_CTRADT := Posicione("SE4", 1, xFilial("SE4") + PadR(cCond, TamSX3("E4_CODIGO")[1]), "E4_CTRADT")

   If cE4_CTRADT == "1"
      cResult := .T.
   EndIf
Return cResult

//-------------------------------------------------------------------
/*{Protheus.doc} QtType
	Retorna o tipo da cotação que gerou o pedido
	"1" - Leilão Reverso
	"2" - Cotação Normal
	
	@author	Flávio Teixeira Lopes
	@version	P11 / P12
	@since	03/07/2014
*/
//-------------------------------------------------------------------

Static Function QtType()
Local aArea:= GetArea()
Local cRet:=""

If !Empty(SC7->C7_NUMCOT)
	SC8->(dbSetOrder(1))
	If SC8->(dbSeek(xFilial("SC8")+SC7->C7_NUMCOT)) 
		If !Empty(SC8->C8_ACCNUM)
			cRet := AllTrim(STRTOKARR(SC8->C8_ACCNUM,'|')[2]) 
		Endif
	Endif
Endif

RestArea(aArea)
Return cRet
