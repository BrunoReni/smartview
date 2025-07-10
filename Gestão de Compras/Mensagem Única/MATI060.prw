#Include 'PROTHEUS.CH'
#Include 'FWADAPTEREAI.CH'	//Include para rotinas de integração com EAI
#Include 'MATI060.CH'
#INCLUDE "TBICONN.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±º Funcao   ³ MATI060     º Autor ³ Danilo Dias       º Data ³ 03/05/2012  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Desc.    ³ Funcao de integracao com o adapter EAI para envio das        º±±
±±º          ³ alteracoes do cadastro de Produtos X Fornecedores(SA5)       º±±
±±º          ³ utilizando o conceito de mensagem unica.                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Param.   ³ cXML - Variavel com conteudo xml para envio/recebimento.     º±±
±±º          ³ nTypeTrans - Tipo de transacao. (Envio/Recebimento)          º±±
±±º          ³ cTypeMessage - Tipo de mensagem. (Business Type, WhoIs, etc) º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Retorno  ³ aRet - Array contendo o resultado da execucao e a mensagem   º±±
±±º          ³        Xml de retorno.                                       º±±
±±º          ³ aRet[1] - (boolean) Indica o resultado da execução da função º±±
±±º          ³ aRet[2] - (caracter) Mensagem Xml para envio                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Uso      ³ MATA060                                                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function MATI060( cXml, nTypeTrans, cTypeMessage, cVersion )

Local aArea 	 := GetArea()			//Salva contexto atual
Local lRet 		 := .T.					//Retorna se a execucao foi bem sucedida ou nao
Local cXmlRet	 := ''					//Xml de retorno da IntegDef
Local cEvent 	 := 'upsert'			//Evento da transacao ( Upsert/Delete )
Local cError 	 := ''					//Mensagem de erro do parse
Local cWarning 	 := ''					//Mensagem de warning do parse
Local nOpcx		 := 0
Local cCodForn	 := ''
Local cCodFor2   := ''
Local cCodProd	 := ''
Local cCodPrf    := ''
Local cNomProd   := ''
Local aErroAuto	 := {}
Local cLogErro	 := ''
Local cValInt	 := ""
Local cValExt	 := ""
Local cMarca	 := ""
Local cPrdVer	 := RTrim(PmsMsgUVer('ITEM','MATA010')) //Versão do Produto
Local lMktPlace	 := SuperGetMv("MV_MKPLACE",.F.,.F.)
Local nTamCodFor := TamSx3("A5_FORNECE")[1]
Local nTamLojFor := TamSx3("A5_LOJA")[1]
Local nTamCodprod:= TamSx3("A5_PRODUTO")[1]
Local nTamNomFor := TamSx3("A5_NOMEFOR")[1]
Local nTamNomPrd := TamSx3("A5_NOMPROD")[1]
Local nTamCodPrf := TamSx3("A5_CODPRF")[1]

Local oModel := Nil
Local oXml									//Objeto Xml completo
Local oXmlEvent							//Objeto Xml com o conteudo da BusinessEvent apenas
Local oXmlContent							//Objeto Xml com o conteudo da BusinessContent apenas

Private lMsErroAuto := .F.

//Verifica o tipo de transacao (Envio/Recebimento)
Do Case 

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Trata o envio de mensagem                                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Case ( nTypeTrans == TRANS_SEND )
		
		If ( !INCLUI ) .And. ( !ALTERA )
			cEvent := 'delete'
		EndIf
		
		//Montagem da mensagem de Relacionamento Produtos X Fornecedores
		cXMLRet := '<BusinessEvent>'
		cXMLRet +=     '<Entity>ProductSupplierRelationShip</Entity>'
		cXMLRet +=     '<Identification>'
		cXMLRet +=         '<key name="InternalID">' + xFilial('SA5') + '|' + SA5->A5_FORNECE + '|' + SA5->A5_LOJA + '|' + SA5->A5_PRODUTO + '</key>'
		cXMLRet +=     '</Identification>'
		cXMLRet +=     '<Event>' + cEvent + '</Event>'	//Tipo de evento (upsert/delete) 
		cXMLRet += '</BusinessEvent>'
		
		cXmlRet += '<BusinessContent>'
		cXmlRet += 	'<CompanyInternalId>' +cEmpAnt +"|"+ xFilial("SA5") + '</CompanyInternalId>'				
		cXmlRet += 	'<CustomerVendorInternalId>' +IntForExt(,,SA5->A5_FORNECE ,SA5->A5_LOJA)[2] + '</CustomerVendorInternalId>'			//PARADIMA UTILZA ESSA TA
		cXmlRet += 	'<InternalId>' +cEmpAnt + "|"+ xFilial("SB1")+ "|" + SA5->A5_PRODUTO + '</InternalId>'		
		cXmlRet += 	'<VendorCode>' + IntForExt(,,SA5->A5_FORNECE ,SA5->A5_LOJA)[2]+ '</VendorCode>'
		cXmlRet += 	'<VendorName>' + _NoTags(AllTrim(SA5->A5_NOMEFOR)) + '</VendorName>'		
		If lMktPlace
			cXMLRet +=	'<ItemInternalId>' + cEmpAnt + '|' + RTrim(xFilial("SA5"))+ "|" + RTrim(SA5->A5_PRODUTO) + '</ItemInternalId>' //MATI010
		Else
			cXMLRet +=	'<ItemInternalId>' + IntProExt(/*cEmpresa*/, /*cFilial*/, SA5->A5_PRODUTO, cPrdVer)[2] + '</ItemInternalId>' //MATI010
		Endif	
		cXmlRet += 	'<ItemCode>' + SA5->A5_PRODUTO + '</ItemCode>'
		cXmlRet += 	'<ItemName>' + _NoTags(AllTrim(SA5->A5_NOMPROD)) + '</ItemName>'
		cXmlRet += 	'<ItemVendorCode>' + _NoTags(AllTrim(SA5->A5_CODPRF)) + '</ItemVendorCode>'
		cXmlRet += 	'<Situation>' + '1' +'</Situation>' 
		cXmlRet += '</BusinessContent>'

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Trata recebimento de mensagens                               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Case ( nTypeTrans == TRANS_RECEIVE )
		
		Do Case 

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Recebimento da WhoIs                                         ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
			Case ( cTypeMessage == EAI_MESSAGE_WHOIS )
			
				cXmlRet := '1.000|2.000'
	
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Recebimento da Response Message                              ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
			Case ( cTypeMessage == EAI_MESSAGE_RESPONSE )
				
				cXmlRet := STR0001	//'Mensagem processada'

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Receipt Message (Aviso de receb. em transmissoes assincronas)³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			Case ( cTypeMessage == EAI_MESSAGE_RECEIPT )

				cXmlRet := STR0002	//'Mensagem recebida'
				
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Recebimento da Business Message                              ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			Case ( cTypeMessage == EAI_MESSAGE_BUSINESS )
				oXML := XmlParser( cXML, '_', @cError, @cWarning )	
				//Instancia objetos com conteudo parcial do Xml									
				If ( ( oXML <> Nil ) .And. ( Empty(cError) ) .And. ( Empty(cWarning) ) )
					oXMLEvent 		:= oXML:_TOTVSMessage:_BusinessMessage:_BusinessEvent
					oXMLContent 	:= oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent

					If Type("oXml:_TotvsMessage:_MessageInformation:_Product:_Name:Text") != "U" .And. !Empty(oXml:_TotvsMessage:_MessageInformation:_Product:_Name:Text)
						cMarca :=  oXml:_TotvsMessage:_MessageInformation:_Product:_Name:Text
					EndIf
					
					If ( XmlChildEx( oXmlContent, '_VENDORCODE') != Nil )
						cCodForn := oXmlContent:_VendorCode:Text
						cValExt	 := cCodForn
						cCodFor2 :=	PadR(cCodForn,nTamCodFor)
						cCodLoj  := SUBSTR(cCodForn,nTamCodFor+1,nTamLojFor)

						If Empty(cCodLoj)
							cCodLoj := GetAdvFVal("SA2","A2_LOJA",xFilial("SA2") + cCodFor2,1)
						Endif
					EndIf					
						
					If ( XmlChildEx( oXmlContent, '_ITEMCODE') != Nil )
						cCodProd := Padr(oXmlContent:_ItemCode:Text,nTamCodprod)
						cValExt	 += cCodProd
					EndIf
				
					dbSelectArea('SA5')
					SA5->( dbSetOrder(1) )	//A5_FILIAL + A5_FORNECE + A5_LOJA + A5_PRODUTO
					
					If ( SA5->( dbSeek( xFilial('SA5') + cCodFor2 + cCodLoj + cCodProd ) ) )
						If ( Upper( oXmlEvent:_Event:Text ) == 'UPSERT' )
							nOpcx := 4
						Else
							nOpcx := 5
						Endif
					Else
						nOpcx := 3
					EndIf

					oModel := FWLoadModel('MATA061')
					oModel:SetOperation(nOpcx)
					oModel:Activate()

					If nOpcx <> 5
						//Cabeçalho
						If !Empty(cCodProd )
							oModel:SetValue('MdFieldSA5','A5_PRODUTO',cCodProd)
						EndIf

						If ( XmlChildEx( oXmlContent, '_ITEMNAME') != Nil )
							cNomProd := Padr(oXmlContent:_ItemName:Text,nTamNomPrd)
							oModel:SetValue('MdFieldSA5','A5_NOMPROD',cNomProd)
						EndIf
						
						//Grid
						If 	!Empty(cCodFor2) 
							oModel:SetValue('MdGridSA5','A5_FORNECE',cCodFor2)
							oModel:SetValue('MdGridSA5','A5_LOJA'	,cCodLoj)
						EndIf	

						If ( XmlChildEx( oXmlContent, '_ITEMVENDORCODE') != Nil )
							cCodPrf:= Padr(oXmlContent:_ItemVendorCode:Text,nTamCodPrf)
							oModel:SetValue('MdGridSA5','A5_CODPRF',cCodPrf)
						EndIf					
						
						If ( XmlChildEx( oXmlContent, '_VENDORNAME') != Nil )
							cNomFor := Padr(oXmlContent:_VendorName:Text,nTamNomFor)
							oModel:SetValue('MdGridSA5','A5_NOMEFOR',cNomFor)
						EndIf
					Endif

					If oModel:VldData()
						oModel:CommitData()

						cValInt := xFilial('SA5') + '|' + cCodFor2 + '|' + cCodLoj + '|' + cCodProd

						If nOpcx <> 5
							CFGA070Mnt(cMarca, "SA5", "A5_FORNECE", cValExt, cValInt, .F.)
						Else  // Delete
							CFGA070Mnt(cMarca, "SA5", "A5_FORNECE", cValExt, cValInt, .T.)
						Endif

						cXmlRet := "<ListOfInternalId>"
						cXmlRet +=    "<InternalId>"
						cXmlRet +=       "<Name>ProductSupplierRelationship</Name>"
						cXmlRet +=       "<Origin>" + cValExt + "</Origin>"
						cXmlRet +=       "<Destination>" + cValInt + "</Destination>"
						cXmlRet +=    "</InternalId>"
						cXmlRet += "</ListOfInternalId>"
					Else
						aErroAuto   := oModel:GetErrorMessage()
						cLogErro := aErroAuto[6] + CRLF +aErroAuto[7]  //[6] ExpC: mensagem do erro    [7] ExpC: mensagem da solução
						//Monta XML de Erro de execução da rotina automatica.
						lRet := .F.
						cXMLRet := EncodeUTF8( cLogErro ) 
					Endif

					oModel:DeActivate()
					oModel:Destroy()

			   Else
					//Tratamento no erro do parse Xml
					lRet := .F.
					cXMLRet := STR0003	//'Erro na manipulação do Xml recebido'
					cXMLRet += IIf ( !Empty(cError), cError, cWarning )
					cXMLRet := EncodeUTF8( cXMLRet )

				EndIf				
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Fim do recebimento da Business Message                       ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		End Case	
End Case

RestArea( aArea )

Return { lRet, cXmlRet, "ProductSupplierRelationship" }