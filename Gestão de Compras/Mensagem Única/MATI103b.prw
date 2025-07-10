#Include "Protheus.ch"
#Include "fwAdapterEAI.ch"
#Include "MATI103b.ch"

//-------------------------------------------------------------------
/*/{Protheus.doc} MATI103b
Funcao de integracao com o adapter EAI para envio e recebimento da
nota fiscal de entrada (SF1/SD1/SDE/AFN) utilizando o conceito de
mensagem unica (Invoice).

@param   cXML          Variavel com conteudo xml para envio/recebimento.
@param   cTypeTrans    Tipo de transacao. (Envio/Recebimento)
@param   cTypeMsg      Tipo de mensagem. (Business Type, WhoIs, etc)
@param   cVersion      Versão da Mensagem Única

@author  Mateus Gustavo de Freitas e Silva
@version P11
@since   23/02/2013
@return  aRet - Array contendo o resultado da execucao e a mensagem Xml de retorno.
aRet[1] - (boolean) Indica o resultado da execução da função
aRet[2] - (caracter) Mensagem Xml para envio
aRet[3] - (caracter) Nome da mensagem

@obs     O método irá retornar um objeto do tipo TOTVSBusinessEvent caso
o tipo da mensagem seja EAI_BUSINESS_EVENT ou um tipo
TOTVSBusinessRequest caso a mensagem seja do tipo TOTVSBusinessRequest.
O tipo da classe pode ser definido com a função EAI_BUSINESS_REQUEST.
/*/
//-------------------------------------------------------------------
Function MATI103b(cXML, cTypeTrans, cTypeMsg, cVersion)

Local cXmlRet   := ""
Local lRet      := .T.
Local aRetEAI   := {}
Local cEntity   := "Invoice"
Local nI        := 0
Local cError    := ""
Local cWarning  := ""
Local cValInt   := ""
Local cValExt   := ""
Local cProduct  := ""

Local lDePara   := .F.
Local cAlias    := "SF1"
Local cField    := "F1_DOC"
Local cDePara   := ""
Local aDePara   := {}
Local nCont     := 0

Private oXML    := Nil

AdpLogEAI(1, "MATI103b", cTypeTrans, cTypeMsg, cXML)

// Mensagem de Entrada
If cTypeTrans == TRANS_RECEIVE
	If cTypeMsg == EAI_MESSAGE_BUSINESS
		lRet := .F.
		cXmlRet := "Recebimento não implementado!"
		aRetEAI := {lRet, cXMLRet, cEntity}

	ElseIf cTypeMsg == EAI_MESSAGE_RESPONSE
		// Faz o parser do XML de retorno em um objeto
		oXML := xmlParser(cXML, "_", @cError, @cWarning)

		If Empty(oXML) .And. "UTF-8" $ Upper(cXML)
			oXML := xmlParser(EncodeUTF8(cXML), "_", @cError, @cWarning)
		EndIf

		// Se não houve erros na resposta
		If Upper(oXML:_TOTVSMessage:_ResponseMessage:_ProcessingInformation:_Status:Text) == "OK"
			// Verifica se a marca foi informada
			If Type("oXML:_TOTVSMessage:_MessageInformation:_Product:_name:Text") != "U" .And. !Empty(oXml:_TOTVSMessage:_MessageInformation:_Product:_name:Text)
				cProduct := oXml:_TOTVSMessage:_MessageInformation:_Product:_name:Text
			Else
				lRet    := .F.
				cXmlRet := STR0002 //"Erro no retorno. O Product é obrigatório!"
				AdpLogEAI(5, "MATI103b", cXMLRet, lRet)
				aRetEAI := {lRet, cXmlRet, cEntity}
				Return aRetEAI
			EndIf

			// Se não houve erros no parse
			If oXML <> Nil .And. Empty(cError) .And. Empty(cWarning)
				// Prepara array com Interna Id´s dos Itens Atualizar a tabela XXF
				//Se não for array

				If Type("oXML:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InternalId") != "U"

					If Type("oXML:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InternalId") != "A"
						//Transforma em array
						XmlNode2Arr(oXML:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InternalId, "_InternalId")
					EndIf

					For nI := 1 To Len(oXML:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InternalId)
						//Verifica se o InternalId foi informado
						If Type("oXML:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InternalId[" + Str(nI) + "]:_Origin:Text") != "U" .And. !Empty(oXML:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InternalId[nI]:_Origin:Text)
							cDePara := Upper(oXML:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InternalId[nI]:_Name:Text)

							cValInt := oXML:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InternalId[nI]:_Origin:Text
							If Type("oXML:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InternalId[" + Str(nI) + "]:_Destination:Text") != "U"
								cValExt := oXML:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InternalId[nI]:_Destination:Text
							Else
								cValExt := ""
							Endif

							// Não armazena Capa e Rateio
							If cDePara == 'INVOICEITEM'
								aAdd(aDePara, Array(4))
								nCont++
								aDePara[nCont][1] := cValInt
								aDePara[nCont][2] := cValExt
								aDePara[nCont][3] := "SD1"
								aDePara[nCont][4] := "D1_ITEM"

							ElseIf cDePara == 'APPORTIONINVOICEITEM'
								aAdd(aDePara, Array(4))
								nCont++
								aDePara[nCont][1] := cValInt
								aDePara[nCont][2] := cValExt
								aDePara[nCont][3] := "SDE"
								aDePara[nCont][4] := "DE_CC"

							ElseIf cDePara == 'ACCOUNTRECEIVABLEDOCUMENT'
								aAdd(aDePara, Array(4))
								nCont++
								aDePara[nCont][1] := cValInt
								aDePara[nCont][2] := cValExt
								aDePara[nCont][3] := "SE1"
								aDePara[nCont][4] := "E1_NUM"

							ElseIf cDePara == 'ACCOUNTPAYABLEDOCUMENT'
								aAdd(aDePara, Array(4))
								nCont++
								aDePara[nCont][1] := cValInt
								aDePara[nCont][2] := cValExt
								aDePara[nCont][3] := "SE2"
								aDePara[nCont][4] := "E2_NUM"

							ElseIf cDePara == 'INVOICE'
								aAdd(aDePara, Array(4))
								nCont++
								aDePara[nCont][1] := cValInt
								aDePara[nCont][2] := cValExt
								aDePara[nCont][3] := "SF1"
								aDePara[nCont][4] := "F1_DOC"

								lDePara := .T.
								AdpLogEAI(3, "cValInt: ", cValInt)
								AdpLogEAI(3, "cValExt: ", cValExt)
							EndIf
						Else
							lRet    := .F.
							cXmlRet := STR0004 //"Erro no retorno. O OriginalInternalId do Item é obrigatório!"
							AdpLogEAI(5, "MATI103b", cXMLRet, lRet)
							aRetEAI := {lRet, cXmlRet, cEntity}
							Return aRetEAI
						EndIf
					Next nI

					If !lDePara
						lRet    := .F.
						cXmlRet := STR0005 //"Erro no retorno. O DestinationInternalId é obrigatório!"
						AdpLogEAI(5, "MATI103b", cXMLRet, lRet)
						aRetEAI := {lRet, cXmlRet, cEntity}
						Return aRetEAI
					Endif

					If Upper(oXML:_TOTVSMessage:_ResponseMessage:_ReceivedMessage:_Event:Text) == "UPSERT"
						For nI := 1 To Len(aDePara)
							cValInt := aDePara[nI][1]
							cValExt := aDePara[nI][2]
							cAlias  := aDePara[nI][3]
							cField  := aDePara[nI][4]
							CFGA070Mnt(cProduct, cAlias, cField, cValExt, cValInt)
						Next nI
					Else
						lRet := .F.
						cXmlRet := STR0006 //"Evento do retorno inválido!"
						aRetEAI := {lRet, cXmlRet, cEntity}
					EndIf
				Else
					lRet := .F.
					cXmlRet := STR0006 //"Evento do retorno inválido!"
					aRetEAI := {lRet, cXmlRet, cEntity}
				Endif
			Else
				lRet := .F.
				cXmlRet := STR0007 //"Erro no parser do retorno!"
				AdpLogEAI(5, "MATI103b", cXMLRet, lRet)
				aRetEAI := {lRet, cXmlRet, cEntity}
				Return aRetEAI
			EndIf
		Else
			// Se não for array
			If Type("oXML:_TOTVSMessage:_ResponseMessage:_ProcessingInformation:_ListOfMessages:_Message") != "A"
				// Transforma em array
				XmlNode2Arr(oXML:_TOTVSMessage:_ResponseMessage:_ProcessingInformation:_ListOfMessages:_Message, "_Message")
			EndIf

			// Percorre o array para obter os erros gerados
			For nI := 1 To Len(oXML:_TOTVSMessage:_ResponseMessage:_ProcessingInformation:_ListOfMessages:_Message)
				cXmlRet += oXML:_TOTVSMessage:_ResponseMessage:_ProcessingInformation:_ListOfMessages:_Message[nI]:Text + Chr(10)
			Next nI

			lRet := .F.
			aRetEAI := {lRet, cXmlRet, cEntity}
		EndIf

	ElseIf cTypeMsg == EAI_MESSAGE_WHOIS
		cXMLRet := "3.001|3.006|3.007|4.000|4.001"
		aRetEAI := {lRet, cXmlRet, cEntity}
	Endif
ElseIf cTypeTrans == TRANS_SEND

	If cVersion = "3."
		aRetEAI := v3000(cXML, cTypeTrans, cTypeMsg, cVersion)
	ElseIf cVersion = "4."
		aRetEAI := v4000(cXML, cTypeTrans, cTypeMsg, cVersion)
	Else
		lRet := .F.
		cXMLRet := STR0008   // "Versão da Nota Fiscal não suportada."
		//Retorno
		aRetEAI := {lRet, cXmlRet, cEntity}
	EndIf
EndIf

AdpLogEAI(5, "MATI103b", cXMLRet, lRet)
Return aRetEAI

/*/{Protheus.doc} v3000
Implementação do adapter EAI, versão 3.x

@author  Alison Kaique
@version P12
@since   Jan/2019
/*/
Static Function v3000(cXML, cTypeTrans, cTypeMsg, cVersion)

Local cXmlRet   := ""
Local lRet      := .T.
Local cEntity   := "Invoice"
Local cEvent    := "upsert"
Local cIntId    := ""
Local aRestSD1  := {}
Local aRestAFN  := {}
Local aRestSDE  := {}
Local aRestCTO  := {}
Local aRateio   := {}
Local nCont     := 0
Local cRegSf1   := ""
Local cIntSd1   := ""
Local cMoedaDoc := ""
Local cMoedaInt := ""

// Verifica a operação realizada
Do Case
	Case Inclui
		AdpLogEAI(4, 3)
	Case Altera
		AdpLogEAI(4, 4)
	OtherWise
		AdpLogEAI(4, 5)
EndCase

//Abre as tabelas utilizadas
aRestSD1 := SD1->(GetArea())
SD1->(dbSetOrder(1)) //D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA+D1_COD+D1_ITEM
aRestAFN := AFN->(GetArea())
AFN->(dbSetOrder(2)) //AFN_FILIAL+AFN_DOC+AFN_SERIE+AFN_FORNEC+AFN_LOJA+AFN_ITEM+AFN_PROJET+AFN_REVISA+AFN_TAREFA
aRestSDE := SDE->(GetArea())
SDE->(dbSetOrder(1))//DE_FILIAL+DE_DOC+DE_SERIE+DE_FORNECE+DE_LOJA+DE_ITEMNF+DE_ITEM
aRestCTO := CTO->(GetArea())
CTO->(dbSetOrder(1)) //CTO_FILIAL+CTO_MOEDA

cIntId := IntInvExt(/*cEmpresa*/, SF1->F1_FILIAL, SF1->F1_DOC, SF1->F1_SERIE, SF1->F1_FORNECE, SF1->F1_LOJA)[2]

If !Inclui .And. !Altera
	cEvent := 'delete' //Exclusão
	CFGA070Mnt( , "SF1", "F1_DOC",, cIntId, .T. ) //Exclui o de/para da nota
EndIf

cMoedaDoc := AllTrim(cValToChar(SF1->F1_MOEDA))
If !CTO->(MsSeek(xFilial("CTO")+cMoedaDoc))
	If CTO->(MsSeek(xFilial("CTO")+ StrZero(SF1->F1_MOEDA,TamSX3("CTO_MOEDA")[1]) ))
		cMoedaDoc := StrZero(SF1->F1_MOEDA,TamSX3("CTO_MOEDA")[1])
	EndIf
EndIf
cMoedaInt := IntMoeExt(,,cMoedaDoc)[2]

cXMLRet := '<BusinessEvent>'
cXMLRet +=    '<Entity>' + cEntity + '</Entity>'
cXMLRet +=    '<Event>' + cEvent + '</Event>'
cXMLRet +=    '<Identification>'
cXMLRet +=       '<key name="InternalID">' + cIntId + '</key>'
cXMLRet +=    '</Identification>'
cXMLRet += '</BusinessEvent>'
cXMLRet += '<BusinessContent>'
cXMLRet +=    '<CompanyId>' + cEmpAnt + '</CompanyId>'
cXMLRet +=    '<BranchId>' + xFilial("SF1") + '</BranchId>'
cXMLRet +=    '<CompanyInternalId>' + cEmpAnt + '|' + xFilial("SF1") + '</CompanyInternalId>'
cXMLRet +=    '<InternalId>' + cIntId + '</InternalId>'
cXMLRet +=    '<InvoiceNumber>' + RTrim(SF1->F1_DOC) + '</InvoiceNumber>'
cXMLRet +=    '<InvoiceSerie>' + RTrim(SF1->F1_SERIE) + '</InvoiceSerie>'
cXMLRet +=    '<InvoiceSubSerie/>'
cXMLRet +=    '<InvoiceModel/>'
cXMLRet +=    '<InvoiceSituation>' + IIf(SF1->F1_STATUS $ "BC", "2", "1") + '</InvoiceSituation>'
cXMLRet +=    '<TypeOfDocument>' + TipDocExt(SF1->F1_TIPO) + '</TypeOfDocument>'
cXMLRet +=    '<VendorCode>' + RTrim(SF1->F1_FORNECE) + '</VendorCode>'
cXMLRet +=    '<VendorInternalId>' + RTrim(IntForExt(/*cEmpresa*/, /*cFilial*/, SF1->F1_FORNECE, SF1->F1_LOJA)[2]) + '</VendorInternalId>'
cXMLRet +=    '<IssueDate>' + INTDTANO(SF1->F1_EMISSAO) + '</IssueDate>'
cXMLRet +=    '<InputDate>' + INTDTANO(SF1->F1_DTDIGIT) + '</InputDate>'
cXMLRet +=    '<InvoiceAmount>' + AllTrim(cValToChar(SF1->F1_VALBRUT)) + '</InvoiceAmount>'
cXMLRet +=    '<ValueofGoods>' + AllTrim(cValToChar(SF1->F1_VALMERC)) + '</ValueofGoods>'
cXMLRet +=    '<FreightAmount>' + AllTrim(cValToChar(SF1->F1_FRETE)) + '</FreightAmount>'
cXMLRet +=    '<InsuranceAmount>' + AllTrim(cValToChar(SF1->F1_SEGURO)) + '</InsuranceAmount>'
cXMLRet +=    '<DiscountAmount>' + AllTrim(cValToChar(SF1->F1_DESCONT)) + '</DiscountAmount>'
cXMLRet +=    '<ExpenseAmount>' + AllTrim(cValToChar(SF1->F1_DESPESA)) + '</ExpenseAmount>'
cXMLRet +=    '<CurrencyRate>' + AllTrim(cValToChar(SF1->F1_TXMOEDA)) + '</CurrencyRate>'
cXMLRet +=    '<CurrencyInternalId>' + cMoedaInt + '</CurrencyInternalId>'
cXMLRet +=    '<PaymentConditionCode>' + RTrim(SF1->F1_COND) + '</PaymentConditionCode>'
cXMLRet +=    '<PaymentConditionInternalId>' + RTrim(IntConExt(/*cEmpresa*/, /*cFilial*/, SF1->F1_COND)[2]) + '</PaymentConditionInternalId>'
cXMLRet +=    '<CustomerCode/>'
cXMLRet +=    '<CustomerInternalId/>'
cXMLRet +=    '<StoreCode/>'
cXMLRet +=    '<ListOfItens>'

cRegSf1 := SF1->F1_FILIAL + SF1->F1_DOC + SF1->F1_SERIE + SF1->F1_FORNECE + SF1->F1_LOJA

If Inclui .Or. Altera
	If SD1->(dbSeek(SF1->F1_FILIAL + SF1->F1_DOC + SF1->F1_SERIE + SF1->F1_FORNECE + SF1->F1_LOJA))
		While SF1->F1_FILIAL + SF1->F1_DOC + SF1->F1_SERIE + SF1->F1_FORNECE + SF1->F1_LOJA == SD1->D1_FILIAL + SD1->D1_DOC + SD1->D1_SERIE + SD1->D1_FORNECE + SD1->D1_LOJA .And. !SD1->(Eof())
			cIntSd1 := IntInvExt(cEmpAnt, SD1->D1_FILIAL, SD1->D1_DOC, SD1->D1_SERIE, SD1->D1_FORNECE, SD1->D1_LOJA, SD1->D1_COD, SD1->D1_ITEM)[2]

			cXMLRet += '<Item>'
			cXMLRet +=    '<InternalId>' + cIntSd1 + '</InternalId>'
			cXMLRet +=    '<InvoiceSequence>' + SD1->D1_ITEM + '</InvoiceSequence>'
			cXMLRet +=    '<OrderNumber>' + SD1->D1_PEDIDO + '</OrderNumber>'
			cXMLRet +=    '<OrderInternalId>' + IntPdCExt(,,SD1->D1_PEDIDO,,)[2] + '</OrderInternalId>'
			cXMLRet +=    '<OrdemItem>' + SD1->D1_ITEMPC + '</OrdemItem>'
			cXMLRet +=    '<OrderItemInternalId>' + IntPdCExt(,,SD1->D1_PEDIDO,SD1->D1_ITEMPC,)[2] + '</OrderItemInternalId>'
			cXMLRet +=    A103REQIT(SD1->D1_PEDIDO,SD1->D1_ITEMPC)
			cXMLRet +=    '<ItemCode>' + RTrim(SD1->D1_COD) + '</ItemCode>'
			cXMLRet +=    '<ItemInternalId>' + RTrim(IntProExt(/*cEmpresa*/, /*cFilial*/, SD1->D1_COD)[2]) + '</ItemInternalId>'
			cXMLRet +=    '<Quantity>' + AllTrim(cValToChar(SD1->D1_QUANT)) + '</Quantity>'
			cXMLRet +=    '<UnitofMeasureCode>' + RTrim(SD1->D1_UM) + '</UnitofMeasureCode>'
			cXMLRet +=    '<UnitofMeasureInternalId>' + RTrim(IntUndExt(/*cEmpresa*/, /*cFilial*/, SD1->D1_UM)[2]) + '</UnitofMeasureInternalId>'
			cXMLRet +=    '<UnityPrice>' + AllTrim(cValToChar(SD1->D1_VUNIT)) + '</UnityPrice>'
			cXMLRet +=    '<GrossValue>' + AllTrim(cValToChar(SD1->D1_QUANT * SD1->D1_VUNIT)) + '</GrossValue>'
			cXMLRet +=    '<FreightValue>' + AllTrim(cValToChar(SD1->D1_VALFRE)) + '</FreightValue>'
			cXMLRet +=    '<InsuranceValue>' + AllTrim(cValToChar(SD1->D1_SEGURO)) + '</InsuranceValue>'
			cXMLRet +=    '<DiscountValue>' + AllTrim(cValToChar(SD1->D1_VALDESC)) + '</DiscountValue>'
			cXMLRet +=    '<ExpenseValue>' + AllTrim(cValToChar(SD1->D1_DESPESA)) + '</ExpenseValue>'
			cXMLRet +=    '<NetValue>' + AllTrim(cValToChar(SD1->D1_TOTAL)) + '</NetValue>'
			cXMLRet +=    '<AreAndLineOfBusinessCode/>'
			cXMLRet +=    '<WarehouseCode>' + RTrim(SD1->D1_LOCAL) + '</WarehouseCode>'
			cXMLRet +=    '<WarehouseInternalId>' + RTrim(IntLocExt(/*cEmpresa*/, /*cFilial*/, SD1->D1_LOCAL)[2]) + '</WarehouseInternalId>'
			cXMLRet +=    '<LotNumber>' + RTrim(SD1->D1_LOTECTL) + '</LotNumber>'
			cXMLRet +=    '<SubLotNumber>' + RTrim(SD1->D1_NUMLOTE) + '</SubLotNumber>'

			nQtdPrd:= MTICalPrd(SD1->(D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA+D1_COD))//Considera a quantidade do produto se estiver repetido na nota fiscal.

			If SB2->(dbSeek(xFilial("SB2")+SD1->D1_COD+SD1->D1_LOCAL))
				cXMLRet +=    '<TotalStock>' + AllTrim(cValToChar(SB2->B2_QATU - nQtdPrd ) ) + '</TotalStock>'
			EndIf
			If !Empty(SD1->D1_LOTECTL)
				nQtdPrd:= MTICalPrd(SD1->(D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA+D1_COD),SD1->D1_LOTECTL)//Considera a quantidade do produto se estiver repetido na nota fiscal considerando o lote
				cXMLRet +=    '<LotStock>' + AllTrim(cValToChar(SaldoLote(SD1->D1_COD,SD1->D1_LOCAL,SD1->D1_LOTECTL,NIL,.T.,.T.,NIL,dDataBase)- nQtdPrd )) + '</LotStock>'
			EndIf
			If SF4->(dbSeek(xFilial("SF4")+SD1->D1_TES))
				cXMLRet +=    '<UpdateStock>' + If(SF4->F4_ESTOQUE == 'S','true','false') + '</UpdateStock>'
			EndIf
			If !Empty(SD1->D1_DTVALID)
				cXMLRet +=    '<LotExpirationDate>' + INTDTANO(SD1->D1_DTVALID) + '</LotExpirationDate>'
			EndIf
			If !Empty(AFN->AFN_CONTRA)
				cXMLRet +=    '<ContractInternalID>' + IntCntExt(/*Empresa*/, xFilial("AFN"), AFN->AFN_PROJET, AFN->AFN_REVISA, AFN->AFN_CONTRA)[2] + '</ContractInternalID>' //Criar função
			EndIf

			cXMLRet +=  GetTaxes(cVersion)

			//Bloco de XML do Rateio
			aRateio := RatNFE(SD1->D1_FILIAL + SD1->D1_DOC + SD1->D1_SERIE + SD1->D1_FORNECE + SD1->D1_LOJA + SD1->D1_ITEM)
			cXMLRet += '<ListOfApportionInvoiceItem>'
			For nCont := 1 To Len(aRateio)
				cXMLRet += ' <ApportionInvoiceItem>'
				cXMLRet +=    '<InternalId>' + cIntSd1 + '|' + cValToChar(nCont) + '</InternalId>'
				cXMLRet +=    IIf(!Empty(aRateio[nCont][1]), '<CostCenterInternalId>' + IntCusExt(/*cEmpresa*/, /*cFilial*/, aRateio[nCont][1])[2] + '</CostCenterInternalId>', '<CostCenterInternalId/>')
				cXMLRet +=    IIf(!Empty(aRateio[nCont][2]), '<AccountantAcountInternalId>' + aRateio[nCont][2] + '</AccountantAcountInternalId>', '<AccountantAcountInternalId/>')

				//Se não for informado Projeto
				cXMLRet +=    IIf(Empty(aRateio[nCont][6]), '<ProjectInternalId/>', '<ProjectInternalId>' + IntPrjExt(/*cEmpresa*/, /*cFilial*/, aRateio[nCont][6])[2] + '</ProjectInternalId>')
				cXMLRet +=    IIf(Empty(aRateio[nCont][6]), '<TaskInternalId/>', '<TaskInternalId>' + Alltrim(IntTrfExt(/*cEmpresa*/, /*cFilial*/, aRateio[nCont][6], '0001', aRateio[nCont][7])[2]) + '</TaskInternalId>')
				cXMLRet +=    IIf(Empty(aRateio[nCont][8]), '<Value>0</Value>', '<Value>' + cValToChar(aRateio[nCont][8] * SD1->D1_VUNIT) + '</Value>')
				cXMLRet +=    '<Percentual>' + cValToChar(aRateio[nCont][5]) + '</Percentual>'
				cXMLRet +=    IIf(Empty(aRateio[nCont][8]), '<Quantity>0</Quantity>', '<Quantity>' + cValToChar(aRateio[nCont][8]) + '</Quantity>')
				cXMLRet += ' </ApportionInvoiceItem>'
			Next nCont
			cXMLRet += '</ListOfApportionInvoiceItem>'

			cXMLRet += '</Item>'
			SD1->(dbSkip())
		EndDo
	EndIf
Else
	cXMLRet += GetItens(cRegSf1)
EndIf

cXMLRet +=    '</ListOfItens>'
cXMLRet += '</BusinessContent>'

SD1->(RestArea(aRestSD1))
AFN->(RestArea(aRestAFN))
SDE->(RestArea(aRestSDE))
CTO->(RestArea(aRestCTO))

Return {lRet, cXMLRet, cEntity}

/*/{Protheus.doc} v4000
Implementação do adapter EAI, versão 4.x

@author  Alison Kaique
@version P12
@since   Jan/2019
/*/
Static Function v4000(cXML, cTypeTrans, cTypeMsg, cVersion)

Local cXmlRet   := ""
Local lRet      := .T.
Local cEntity   := "Invoice"
Local cEvent    := "upsert"
Local cIntId    := ""
Local aArea     := {}
Local aRestSD1  := {}
Local aRestAFN  := {}
Local aRestSDE  := {}
Local aRestCTO  := {}
Local aRestTit  := {}
Local aRateio   := {}
Local nCont     := 0
Local cRegSf1   := ""
Local cIntSd1   := ""
Local cMoedaDoc := ""
Local cMoedaInt := ""
Local cDuplic   := ""
Local cIntTitulo := ""

// Verifica a operação realizada
Do Case
	Case Inclui
		AdpLogEAI(4, 3)
	Case Altera
		AdpLogEAI(4, 4)
	OtherWise
		AdpLogEAI(4, 5)
EndCase

aArea    := GetArea()
aRestSD1 := SD1->(GetArea())
aRestAFN := AFN->(GetArea())
aRestSDE := SDE->(GetArea())
aRestCTO := CTO->(GetArea())

cIntId := IntInvExt(/*cEmpresa*/, SF1->F1_FILIAL, SF1->F1_DOC, SF1->F1_SERIE, SF1->F1_FORNECE, SF1->F1_LOJA)[2]

If !Inclui .And. !Altera
	cEvent := 'delete' // Exclusão
	CFGA070Mnt( , "SF1", "F1_DOC",, cIntId, .T. ) //Exclui o de/para da nota
EndIf

cMoedaDoc := cValToChar(SF1->F1_MOEDA)
CTO->(dbSetOrder(1))  // CTO_FILIAL, CTO_MOEDA.
If !CTO->(MsSeek(xFilial("CTO")+cMoedaDoc))
	If CTO->(MsSeek(xFilial("CTO")+ StrZero(SF1->F1_MOEDA,TamSX3("CTO_MOEDA")[1]) ))
		cMoedaDoc := StrZero(SF1->F1_MOEDA,TamSX3("CTO_MOEDA")[1])
	EndIf
EndIf
cMoedaInt := IntMoeExt(,,cMoedaDoc)[2]

cXMLRet := '<BusinessEvent>'
cXMLRet +=    '<Entity>' + cEntity + '</Entity>'
cXMLRet +=    '<Event>' + cEvent + '</Event>'
cXMLRet +=    '<Identification>'
cXMLRet +=       '<key name="InternalID">' + cIntId + '</key>'
cXMLRet +=    '</Identification>'
cXMLRet += '</BusinessEvent>'
cXMLRet += '<BusinessContent>'
cXMLRet +=    '<CompanyId>' + cEmpAnt + '</CompanyId>'
cXMLRet +=    '<BranchId>' + xFilial("SF1") + '</BranchId>'
cXMLRet +=    '<CompanyInternalId>' + cEmpAnt + '|' + xFilial("SF1") + '</CompanyInternalId>'
cXMLRet +=    '<InternalId>' + cIntId + '</InternalId>'
cXMLRet +=    '<InvoiceNumber>' + RTrim(SF1->F1_DOC) + '</InvoiceNumber>'
cXMLRet +=    '<InvoiceSerie>' + RTrim(SF1->F1_SERIE) + '</InvoiceSerie>'
cXMLRet +=    '<InvoiceSubSerie/>'
cXMLRet +=    '<InvoiceModel/>'
cXMLRet +=    '<InvoiceSituation>' + IIf(SF1->F1_STATUS $ "BC", "2", "1") + '</InvoiceSituation>'
cXMLRet +=    '<TypeOfDocument>' + TipDocExt(SF1->F1_TIPO) + '</TypeOfDocument>'
cXMLRet +=    '<VendorCode>' + RTrim(SF1->F1_FORNECE) + '</VendorCode>'
If SF1->F1_TIPO $ "DB"
	cXMLRet += '<CustomerInternalId>' + IntCliExt(,, SF1->F1_FORNECE, SF1->F1_LOJA)[2] + '</CustomerInternalId>'
Else
	cXMLRet += '<VendorInternalId>' + IntForExt(,, SF1->F1_FORNECE, SF1->F1_LOJA)[2] + '</VendorInternalId>'
Endif
cXMLRet +=    '<IssueDate>' + INTDTANO(SF1->F1_EMISSAO) + '</IssueDate>'
cXMLRet +=    '<InputDate>' + INTDTANO(SF1->F1_DTDIGIT) + '</InputDate>'
cXMLRet +=    '<InvoiceAmount>' + cValToChar(SF1->F1_VALBRUT) + '</InvoiceAmount>'
cXMLRet +=    '<ValueofGoods>' + cValToChar(SF1->F1_VALMERC) + '</ValueofGoods>'
cXMLRet +=    '<FreightAmount>' + cValToChar(SF1->F1_FRETE) + '</FreightAmount>'
cXMLRet +=    '<InsuranceAmount>' + cValToChar(SF1->F1_SEGURO) + '</InsuranceAmount>'
cXMLRet +=    '<DiscountAmount>' + cValToChar(SF1->F1_DESCONT) + '</DiscountAmount>'
cXMLRet +=    '<ExpenseAmount>' + cValToChar(SF1->F1_DESPESA) + '</ExpenseAmount>'
cXMLRet +=    '<CurrencyRate>' + cValToChar(SF1->F1_TXMOEDA) + '</CurrencyRate>'
cXMLRet +=    '<CurrencyInternalId>' + cMoedaInt + '</CurrencyInternalId>'
cXMLRet +=    '<PaymentConditionCode>' + RTrim(SF1->F1_COND) + '</PaymentConditionCode>'
cXMLRet +=    '<PaymentConditionInternalId>' + IntConExt(/*cEmpresa*/, /*cFilial*/, SF1->F1_COND)[2] + '</PaymentConditionInternalId>'

// Lista de títulos financeiros.
If val(cVersion) >= 4.001

	cXMLRet += '<ListOfFinancialDocument>'

	// Títulos a receber.
	aRestTit := SE1->(GetArea())
	cDuplic  := SF1->(xFilial("SE1") + F1_PREFIXO + F1_DUPL)
	SE1->(dbSetOrder(1))  // E1_FILIAL, E1_PREFIXO, E1_NUM, E1_PARCELA, E1_TIPO.
	SE1->(dbSeek(cDuplic, .F.))
	Do While SE1->(!eof() .and. E1_FILIAL + E1_PREFIXO + E1_NUM == cDuplic)
		cIntTitulo := SE1->( IntTRcExt(, E1_FILIAL, E1_PREFIXO, E1_NUM, E1_PARCELA, E1_TIPO)[2] )

		//Se for delete, exclui o de/para do título a receber
		If cEvent == 'delete'
			CFGA070Mnt( , "SE1", "E1_NUM",, cIntTitulo, .T. )
		EndIf

		cXMLRet +=    '<FinancialDocument>'
		cXMLRet +=      '<FinancialAccount>Receivable</FinancialAccount>'
		cXMLRet +=      '<DocumentPrefix>' + RTrim(SE1->E1_PREFIXO) + '</DocumentPrefix>'
		cXMLRet +=      '<DocumentNumber>' + RTrim(SE1->E1_NUM) + '</DocumentNumber>'
		cXMLRet +=      '<DocumentParcel>' + RTrim(SE1->E1_PARCELA) + '</DocumentParcel>'
		cXMLRet +=      '<DocumentTypeCode>' + RTrim(SE1->E1_TIPO) + '</DocumentTypeCode>'
		cXMLRet +=      '<CustomerVendorInternalId>' + IntCliExt(,, SE1->E1_CLIENTE, SE1->E1_LOJA)[2] + '</CustomerVendorInternalId>'
		cXMLRet +=      '<FinancialDocumentInternalId>' + cIntTitulo + '</FinancialDocumentInternalId>'
		cXMLRet +=      '<DueDate>' + INTDTANO(SE1->E1_VENCTO) + '</DueDate>'
		cXMLRet +=      '<RealDueDate>' + INTDTANO(SE1->E1_VENCREA) + '</RealDueDate>'
		cXMLRet +=      '<Value>' + cValToChar(SE1->E1_VALOR) + '</Value>'
		cXMLRet +=      '<CurrencyCode>' + PadL(SE1->E1_MOEDA, 2, '0') +'</CurrencyCode>'
		cXmlRet +=      '<CurrencyInternalId>' + IntMoeExt(,, PadL(SE1->E1_MOEDA, 2, '0'), PmsMsgUVer('CURRENCY','CTBA140'))[2] + '</CurrencyInternalId>'
		If Empty(SE1->E1_NATUREZ)
			cXMLRet +=  '<FinancialNatureInternalId/>'
		Else
			cXMLRet +=  '<FinancialNatureInternalId>' + F10MontInt(, SE1->E1_NATUREZ) + '</FinancialNatureInternalId>'
		EndIf
		cXMLRet +=    '</FinancialDocument>'

		SE1->(dbSkip())
	EndDo
	RestArea(aRestTit)

	// Títulos a pagar.
	aRestTit := SE2->(GetArea())
	cDuplic  := SF1->(xFilial("SE2") + F1_PREFIXO + F1_DUPL)
	SE2->(dbSetOrder(1))  // E2_FILIAL, E2_PREFIXO, E2_NUM, E2_PARCELA, E2_TIPO, E2_FORNECE, E2_LOJA.
	SE2->(dbSeek(cDuplic, .F.))
	Do While SE2->(!eof() .and. E2_FILIAL + E2_PREFIXO + E2_NUM == cDuplic)
		cIntTitulo := SE2->( IntTPgExt(, E2_FILIAL, E2_PREFIXO, E2_NUM, E2_PARCELA, E2_TIPO, E2_FORNECE, E2_LOJA)[2] )

		//Se for delete, exclui o de/para do título a pagar
		If cEvent == 'delete'
			CFGA070Mnt( , "SE2", "E2_NUM",, cIntTitulo, .T. )
		EndIf

		cXMLRet +=    '<FinancialDocument>'
		cXMLRet +=      '<FinancialAccount>Payable</FinancialAccount>'
		cXMLRet +=      '<DocumentPrefix>' + RTrim(SE2->E2_PREFIXO) + '</DocumentPrefix>'
		cXMLRet +=      '<DocumentNumber>' + RTrim(SE2->E2_NUM) + '</DocumentNumber>'
		cXMLRet +=      '<DocumentParcel>' + RTrim(SE2->E2_PARCELA) + '</DocumentParcel>'
		cXMLRet +=      '<DocumentTypeCode>' + RTrim(SE2->E2_TIPO) + '</DocumentTypeCode>'
		cXMLRet +=      '<CustomerVendorInternalId>' + IntForExt(,, SE2->E2_FORNECE, SE2->E2_LOJA)[2] + '</CustomerVendorInternalId>'
		cXMLRet +=      '<FinancialDocumentInternalId>' + cIntTitulo + '</FinancialDocumentInternalId>'
		cXMLRet +=      '<DueDate>' + INTDTANO(SE2->E2_VENCTO) + '</DueDate>'
		cXMLRet +=      '<RealDueDate>' + INTDTANO(SE2->E2_VENCREA) + '</RealDueDate>'
		cXMLRet +=      '<Value>' + cValToChar(SE2->E2_VALOR) + '</Value>'
		cXMLRet +=      '<CurrencyCode>' + PadL(SE2->E2_MOEDA, 2, '0') +'</CurrencyCode>'
		cXmlRet +=      '<CurrencyInternalId>' + IntMoeExt(,, PadL(SE2->E2_MOEDA, 2, '0'), PmsMsgUVer('CURRENCY','CTBA140'))[2] + '</CurrencyInternalId>'
		If Empty(SE2->E2_NATUREZ)
			cXMLRet +=  '<FinancialNatureInternalId/>'
		Else
			cXMLRet +=  '<FinancialNatureInternalId>' + F10MontInt(, SE2->E2_NATUREZ) + '</FinancialNatureInternalId>'
		EndIf
		cXMLRet +=    '</FinancialDocument>'

		SE2->(dbSkip())
	EndDo
	RestArea(aRestTit)

	cXMLRet += '</ListOfFinancialDocument>'
Endif

// Lista os itens da nota.
cXMLRet +=    '<ListOfItems>'
cRegSf1 := xFilial("SD1") + SF1->(F1_DOC + F1_SERIE + F1_FORNECE + F1_LOJA)
If Inclui .Or. Altera
	SD1->(dbSetOrder(1))  // D1_FILIAL, D1_DOC, D1_SERIE, D1_FORNECE, D1_LOJA, D1_COD, D1_ITEM.
	If SD1->(dbSeek(cRegSf1, .F.))
		While SD1->(!Eof() .and. D1_FILIAL + D1_DOC + D1_SERIE + D1_FORNECE + D1_LOJA == cRegSf1)
			cIntSd1 := IntInvExt(cEmpAnt, SD1->D1_FILIAL, SD1->D1_DOC, SD1->D1_SERIE, SD1->D1_FORNECE, SD1->D1_LOJA, SD1->D1_COD, SD1->D1_ITEM)[2]

			cXMLRet += '<Item>'
			cXMLRet +=    '<InternalId>' + cIntSd1 + '</InternalId>'
			cXMLRet +=    '<InvoiceSequence>' + SD1->D1_ITEM + '</InvoiceSequence>'
			cXMLRet +=    '<OrderNumber>' + SD1->D1_PEDIDO + '</OrderNumber>'
			cXMLRet +=    '<OrderInternalId>' + IntPdCExt(,,SD1->D1_PEDIDO,,)[2] + '</OrderInternalId>'
			cXMLRet +=    '<OrdemItem>' + SD1->D1_ITEMPC + '</OrdemItem>'
			cXMLRet +=    '<OrderItemInternalId>' + IntPdCExt(,,SD1->D1_PEDIDO,SD1->D1_ITEMPC,)[2] + '</OrderItemInternalId>'
			cXMLRet +=    A103REQIT(SD1->D1_PEDIDO,SD1->D1_ITEMPC)
			cXMLRet +=    '<ItemCode>' + RTrim(SD1->D1_COD) + '</ItemCode>'
			cXMLRet +=    '<ItemInternalId>' + RTrim(IntProExt(/*cEmpresa*/, /*cFilial*/, SD1->D1_COD)[2]) + '</ItemInternalId>'
			cXMLRet +=    '<Quantity>' + cValToChar(SD1->D1_QUANT) + '</Quantity>'
			cXMLRet +=    '<UnitofMeasureCode>' + RTrim(SD1->D1_UM) + '</UnitofMeasureCode>'
			cXMLRet +=    '<UnitofMeasureInternalId>' + RTrim(IntUndExt(/*cEmpresa*/, /*cFilial*/, SD1->D1_UM)[2]) + '</UnitofMeasureInternalId>'
			cXMLRet +=    '<UnityPrice>' + cValToChar(SD1->D1_VUNIT) + '</UnityPrice>'
			cXMLRet +=    '<GrossValue>' + cValToChar(SD1->D1_QUANT * SD1->D1_VUNIT) + '</GrossValue>'
			cXMLRet +=    '<FreightValue>' + cValToChar(SD1->D1_VALFRE) + '</FreightValue>'
			cXMLRet +=    '<InsuranceValue>' + cValToChar(SD1->D1_SEGURO) + '</InsuranceValue>'
			cXMLRet +=    '<DiscountValue>' + cValToChar(SD1->D1_VALDESC) + '</DiscountValue>'
			cXMLRet +=    '<ExpenseValue>' + cValToChar(SD1->D1_DESPESA) + '</ExpenseValue>'
			cXMLRet +=    '<NetValue>' + cValToChar(SD1->D1_TOTAL) + '</NetValue>'
			cXMLRet +=    '<AreAndLineOfBusinessCode/>'
			cXMLRet +=    '<WarehouseCode>' + RTrim(SD1->D1_LOCAL) + '</WarehouseCode>'
			cXMLRet +=    '<WarehouseInternalId>' + RTrim(IntLocExt(/*cEmpresa*/, /*cFilial*/, SD1->D1_LOCAL)[2]) + '</WarehouseInternalId>'
			cXMLRet +=    '<LotNumber>' + RTrim(SD1->D1_LOTECTL) + '</LotNumber>'
			cXMLRet +=    '<SubLotNumber>' + RTrim(SD1->D1_NUMLOTE) + '</SubLotNumber>'

			// Pega os impostos do item.
			cXMLRet +=  GetTaxes(cVersion)

			//Bloco de XML do Rateio
			aRateio := RatNFE(SD1->D1_FILIAL + SD1->D1_DOC + SD1->D1_SERIE + SD1->D1_FORNECE + SD1->D1_LOJA + SD1->D1_ITEM)
			cXMLRet += '<ListOfApportionInvoiceItem>'
			For nCont := 1 To Len(aRateio)
				cXMLRet += ' <ApportionInvoiceItem>'
				cXMLRet +=    '<InternalId>' + cIntSd1 + '|' + cValToChar(nCont) + '</InternalId>'
				cXMLRet +=    IIf(!Empty(aRateio[nCont][1]), '<CostCenterInternalId>' + IntCusExt(/*cEmpresa*/, /*cFilial*/, aRateio[nCont][1])[2] + '</CostCenterInternalId>', '<CostCenterInternalId/>')
				cXMLRet +=    IIf(!Empty(aRateio[nCont][2]), '<AccountantAcountInternalId>' + aRateio[nCont][2] + '</AccountantAcountInternalId>', '<AccountantAcountInternalId/>')

				//Se não for informado Projeto
				cXMLRet +=    IIf(Empty(aRateio[nCont][6]), '<ProjectInternalId/>', '<ProjectInternalId>' + IntPrjExt(/*cEmpresa*/, /*cFilial*/, aRateio[nCont][6])[2] + '</ProjectInternalId>')
				cXMLRet +=    IIf(Empty(aRateio[nCont][6]), '<TaskInternalId/>', '<TaskInternalId>' + Alltrim(IntTrfExt(/*cEmpresa*/, /*cFilial*/, aRateio[nCont][6], '0001', aRateio[nCont][7])[2]) + '</TaskInternalId>')
				cXMLRet +=    IIf(Empty(aRateio[nCont][8]), '<Value>0</Value>', '<Value>' + cValToChar(aRateio[nCont][8] * SD1->D1_VUNIT) + '</Value>')
				cXMLRet +=    '<Percentual>' + cValToChar(aRateio[nCont][5]) + '</Percentual>'
				cXMLRet +=    IIf(Empty(aRateio[nCont][8]), '<Quantity>0</Quantity>', '<Quantity>' + cValToChar(aRateio[nCont][8]) + '</Quantity>')
				cXMLRet += ' </ApportionInvoiceItem>'
			Next nCont
			cXMLRet += '</ListOfApportionInvoiceItem>'

			nQtdPrd:= MTICalPrd(SD1->(D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA+D1_COD))//Considera a quantidade do produto se estiver repetido na nota fiscal.

			SB2->(dbSetOrder(1))  // B2_FILIAL, B2_COD, B2_LOCAL.
			If SB2->(dbSeek(xFilial() + SD1->(D1_COD + D1_LOCAL), .F.))
				cXMLRet +=    '<TotalStock>' + cValToChar(SB2->B2_QATU - nQtdPrd) + '</TotalStock>'
			EndIf
			If !Empty(SD1->D1_LOTECTL)
				nQtdPrd:= MTICalPrd(SD1->(D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA+D1_COD),SD1->D1_LOTECTL)//Considera a quantidade do produto se estiver repetido na nota fiscal considerando o lote
				cXMLRet +=    '<LotStock>' + cValToChar(SaldoLote(SD1->D1_COD,SD1->D1_LOCAL,SD1->D1_LOTECTL,NIL,.T.,.T.,NIL,dDataBase)- nQtdPrd) + '</LotStock>'
			EndIf
			If SF4->(dbSeek(xFilial("SF4")+SD1->D1_TES))
				cXMLRet +=    '<UpdateStock>' + If(SF4->F4_ESTOQUE == 'S','true','false') + '</UpdateStock>'
			EndIf
			If !Empty(SD1->D1_DTVALID)
				cXMLRet +=    '<LotExpirationDate>' + INTDTANO(SD1->D1_DTVALID) + '</LotExpirationDate>'
			EndIf
			If !Empty(AFN->AFN_CONTRA)
				cXMLRet +=    '<ContractInternalID>' + IntCntExt(/*Empresa*/, xFilial("AFN"), AFN->AFN_PROJET, AFN->AFN_REVISA, AFN->AFN_CONTRA)[2] + '</ContractInternalID>' //Criar função
			EndIf

			cXMLRet += '</Item>'
			SD1->(dbSkip())
		EndDo
	EndIf
Else
	cXMLRet += GetItens(cRegSf1)
EndIf

cXMLRet +=    '</ListOfItems>'
cXMLRet += '</BusinessContent>'

SD1->(RestArea(aRestSD1))
AFN->(RestArea(aRestAFN))
SDE->(RestArea(aRestSDE))
CTO->(RestArea(aRestCTO))
RestArea(aArea)

Return {lRet, cXMLRet, cEntity}


/*/{Protheus.doc} A103REQIT
Busca as Solicitações de Compras amarrada a NF (Pedido)

@param   cPedido Numero de pedido de compra amarrado a NF
@param   cItemPC Item do pedido de compra amarrado a NF

@author  Rodrigo Machado Pontes
@version P11
@since   12/01/2016
@return  cResult - Lista de SCs
/*/
Static Function A103REQIT(cPedido,cItemPC)

Local aArea		:= GetArea()
Local cRet		:= ""
Local cQry		:= ""
Local aSCs		:= {}
Local nI		:= 0

If Select("SCNF") > 0
	SCNF->(DbCloseArea())
Endif

cQry := " SELECT C1_NUM,"
cQry += "        C1_ITEM"
cQry += " FROM " + RetSqlName("SC1")
cQry += " WHERE D_E_L_E_T_ = ''"
cQry += " AND C1_PEDIDO = '" + cPedido + "'"
cQry += " AND C1_ITEMPED = '" + cItemPC + "'"
cQry += " GROUP BY C1_NUM,"
cQry += "          C1_ITEM"

cQry := ChangeQuery(cQry)

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),"SCNF",.T.,.T.)

DbSelectArea("SCNF")
While SCNF->(!EOF())
	aAdd(aSCs,{SCNF->C1_NUM,SCNF->C1_ITEM})
	SCNF->(DbSkip())
Enddo

If Len(aSCs) > 0 .And. !Empty(cPedido)
	cRet := "<ListOfRequests>"

	For nI := 1 To Len(aSCs)
		cRet += "	<Requests>"
		cRet += "		<RequestItemInternalId>" + IntSCoExt(,,aSCs[nI,1],aSCs[nI,2],)[2] + "</RequestItemInternalId>"
		cRet += "	</Requests>"
	Next nI

	cRet += "</ListOfRequests>"
Else
	cRet := "<ListOfRequests/>"
Endif
RestArea(aArea)

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} TipDocExt
Funcao que recebe o tipo de documento do Protheus e retorna o tipo de
documento da mensagem Invoice.

@param   cValue Variavel com conteudo xml para envio/recebimento.

@author  Mateus Gustavo de Freitas e Silva
@version P11
@since   23/02/2013
@return  cResult - String com o tipo de documento do Protheus
/*/
//-------------------------------------------------------------------
Static Function TipDocExt(cValue)
Local cResult := ""

Do Case
	Case cValue == "N"
		cResult := "01" //NF Normal
	Case cValue == "C"
		cResult := "02" //Compl. Preço
	Case cValue == "D"
		cResult := "03" //Devolução
	Case cValue == "I"
		cResult := "04" //NF Compl. ICMS
	Case cValue == "P"
		cResult := "05" //NF Compl. IPI
	Case cValue == "B"
		cResult := "06" //NF Beneficiamento
	EndCase
Return cResult

//-------------------------------------------------------------------
/*/{Protheus.doc} RatNFE
Recebe a chave de busca do Documento de Entrada e monta o rateio de
acordo com a estrutura do RM Solum (TOTVS Obras e Projetos).

@author  Leandro Luiz da Cruz
@version P11
@since   12/03/2013

@return aResult
/*/
//-------------------------------------------------------------------
Static Function RatNFE(chaveSD1)

Local aResult  := {}
Local aPrjtTrf := {}
Local aCntrCst := {}
Local nI       := 0

// Povoa o array de Projeto
AFN->(dbSetOrder(2))  // AFN_FILIAL, AFN_DOC, AFN_SERIE, AFN_FORNEC, AFN_LOJA, AFN_ITEM, AFN_PROJET, AFN_REVISA, AFN_TAREFA.
If AFN->(dbSeek(chaveSD1))
	While !AFN->(Eof()) .And. chaveSD1 == AFN->AFN_FILIAL + AFN->AFN_DOC + AFN->AFN_SERIE + AFN->AFN_FORNEC + AFN->AFN_LOJA + AFN->AFN_ITEM
		aAdd(aPrjtTrf, Array(4))
		nI++
		aPrjtTrf[nI][1] := AFN->AFN_PROJET
		aPrjtTrf[nI][2] := AFN->AFN_REVISA
		aPrjtTrf[nI][3] := AFN->AFN_TAREFA
		aPrjtTrf[nI][4] := AFN->AFN_QUANT
		AFN->(dbSkip())
	EndDo
EndIf

nI := 0

//Povoa o array de Centro de Custo
If SD1->D1_RATEIO == '1' //Possui rateio de centro de custo
	SDE->(dbSetOrder(1))  // DE_FILIAL, DE_DOC, DE_SERIE, DE_FORNECE, DE_LOJA, DE_ITEMNF, DE_ITEM.
	If SDE->(dbSeek(chaveSD1))
		While !SDE->(Eof()) .And. chaveSD1 == SDE->DE_FILIAL + SDE->DE_DOC + SDE->DE_SERIE + SDE->DE_FORNECE + SDE->DE_LOJA + SDE->DE_ITEMNF
			aAdd(aCntrCst, Array(5))
			nI++
			aCntrCst[nI][1] := SDE->DE_CC
			aCntrCst[nI][2] := SDE->DE_CONTA
			aCntrCst[nI][3] := SDE->DE_ITEMCTA
			aCntrCst[nI][4] := SDE->DE_CLVL
			aCntrCst[nI][5] := SDE->DE_PERC
			SDE->(dbSkip())
		EndDo
	EndIf
EndIf

If Len(aCntrCst) == 0
	aAdd(aCntrCst,{SD1->D1_CC, SD1->D1_CONTA, SD1->D1_ITEMCTA, SD1->D1_CLVL, 100})
EndIf

aResult := IntRatPrjCC(aCntrCst, aPrjtTrf)
Return aResult

//-------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} IntInvExt
Monta o InternalID da Invoice ou dos itens de acordo com o código
passado no parâmetro.

@param   cEmpresa Código da empresa (Default cEmpAnt)
@param   cFil     Código da Filial (Default xFilial(SD1))
@param   cDoc     Número do documento/nota
@param   cSerie   Série da Nota Fiscal
@param   cFornec  Código do Fornecedor/Cliente
@param   cLoja    Loja do Fornecedor/Cliente
@param   cCod     Código do produto
@param   cItem    Item da Nota Fiscal
@param   cVersao  Versão da mensagem única (Default 3.001)

@author  Leandro Luiz da Cruz
@version P11
@since   01/07/2013
@return  aResult Array contendo no primeiro parâmetro uma variável
lógica indicando se o registro foi encontrado.
No segundo parâmetro uma variável string com o InternalID
montado.

@sample  IntInvExt(,,'0001','01','01','01','01','0001') irá retornar {.T.,'01|01|0001|01|01|01|01|0001'}
/*/
//-------------------------------------------------------------------------------------------------------
Function IntInvExt(cEmpresa, cFil, cDoc, cSerie, cFornec, cLoja, cCod, cItem, cVersao)
Local   aResult  := {}
Local   cTemp    := ""
Default cEmpresa := cEmpAnt
Default cFil     := xFilial('SF1')
Default cVersao  := '3.001'

If cVersao == '3.001'
	If Empty(cCod)
		// Montagem do InternalId de cabeçalho (SF1)
		cTemp := cEmpresa + '|' + RTrim(cFil) + '|' + RTrim(cDoc)+ '|' + RTrim(cSerie) + "|" + RTrim(cFornec) + "|" + RTrim(cLoja)
	Else
		// Montagem do InternalId do item (SD1)
		cTemp := cEmpresa + '|' + RTrim(xFilial('SD1')) + '|' + RTrim(cDoc)+ '|' + RTrim(cSerie) + "|" + RTrim(cFornec) + "|" + RTrim(cLoja) + "|" + RTrim(cCod) + "|" + RTrim(cItem)
	EndIf
	aAdd(aResult, .T.)
	aAdd(aResult, cTemp)
Else
	aAdd(aResult, .F.)
	aAdd(aResult, STR0008 + Chr(10) + STR0009) //"Versão da Nota Fiscal não suportada." "As versões suportadas são: 3.001"
EndIf
Return aResult

//-------------------------------------------------------------------
/*/{Protheus.doc} GetItens
Recebe o número da Invoice de Compra e monta o bloco de XML
contendo a ListOfRequestItens.

@param   cChave Registro SF1
@author  Leandro Luiz da Cruz
@version P11
@since   02/07/2013

@return aResult
/*/
//-------------------------------------------------------------------
Static Function GetItens(cChave)

Local cResult  	 := ""
Local cIntSd1  	 := ""
Local cIntApport := ""
Local aAreaAnt 	 := GetArea()
Local aRatExc  	 := {}
Local nI       	 := 0

DbSelectArea("SD1")
SD1->(dbSetOrder(1))  // D1_FILIAL, D1_DOC, D1_SERIE, D1_FORNECE, D1_LOJA, D1_COD, D1_ITEM.
If SD1->(DbSeek(cChave))
	While SD1->(!EOF()) .And. SD1->D1_FILIAL + SD1->D1_DOC + SD1->D1_SERIE + SD1->D1_FORNECE + SD1->D1_LOJA == cChave
		cIntSd1 := IntInvExt(cEmpAnt, SD1->D1_FILIAL, SD1->D1_DOC, SD1->D1_SERIE, SD1->D1_FORNECE, SD1->D1_LOJA, SD1->D1_COD, SD1->D1_ITEM)[2]

		//Exclui o de/para do item
		CFGA070Mnt( , "SD1", "D1_ITEM",, cIntSd1, .T. )

		cResult += "<Item>"
		cResult +=    '<InternalId>' + cIntSd1 + '</InternalId>'
		cResult +=    '<OrderInternalId>' + IntPdCExt(,,SD1->D1_PEDIDO,,)[2] + '</OrderInternalId>'
		cResult +=    '<OrderItemInternalId>' + IntPdCExt(,,SD1->D1_PEDIDO,SD1->D1_ITEMPC,)[2] + '</OrderItemInternalId>'
		cResult +=    A103REQIT(SD1->D1_PEDIDO,SD1->D1_ITEMPC)

		aRatExc := RatNFE(SD1->D1_FILIAL + SD1->D1_DOC + SD1->D1_SERIE + SD1->D1_FORNECE + SD1->D1_LOJA + SD1->D1_ITEM)
		cResult += '<ListOfApportionInvoiceItem>'
		For nI := 1 To Len(aRatExc)
			cIntApport := cIntSd1 + '|' + cValToChar(nI)

			//Exclui o de/para do rateio
			CFGA070Mnt( , "SDE", "DE_CC",, cIntApport, .T. )

			cResult += 	'<ApportionInvoiceItem>'
			cResult +=    	'<InternalId>' + cIntApport + '</InternalId>'
			cResult +=    IIf(!Empty(aRatExc[nI][1]), '<CostCenterInternalId>' + IntCusExt(/*cEmpresa*/, /*cFilial*/, aRatExc[nI][1])[2] + '</CostCenterInternalId>', '<CostCenterInternalId/>')
			cResult +=    IIf(Empty(aRatExc[nI][6]),  '<ProjectInternalId/>', '<ProjectInternalId>' + IntPrjExt(/*cEmpresa*/, /*cFilial*/, aRatExc[nI][6])[2] + '</ProjectInternalId>')
			cResult +=    IIf(Empty(aRatExc[nI][6]),  '<TaskInternalId/>', '<TaskInternalId>' + Alltrim(IntTrfExt(/*cEmpresa*/, /*cFilial*/, aRatExc[nI][6], '0001', aRatExc[nI][7])[2]) + '</TaskInternalId>')
			cResult +=    '<Percentual>' + cValToChar(aRatExc[nI][5]) + '</Percentual>'
			cResult +=    '<Quantity>' + cValToChar(aRatExc[nI][8]) + '</Quantity>'
			cResult += 	'</ApportionInvoiceItem>'
		Next nI
		cResult += '</ListOfApportionInvoiceItem>'

		cResult += "</Item>"
		SD1->(DbSkip())
	EndDo
EndIf

RestArea(aAreaAnt)
Return cResult

//-------------------------------------------------------------------
/*/{Protheus.doc} GetTaxes
Monta o xml com os impostos da nota fiscal.

@author      Mateus Gustavo de Freitas e Silva
@version     P11
@since       01/08/2013

@return cXML Variável com o xml gerado.
/*/
//-------------------------------------------------------------------
Static Function GetTaxes(cVersion)

Local cXML      := ""
Local aImpostos := {}
Local nI

Local lD1FECP   := SD1->(ColumnPos( "D1_ALQFECP" )) > 0 .And. SD1->(ColumnPos( "D1_VALFECP" )) > 0 .And. SD1->(ColumnPos( "D1_BASFECP" )) > 0 // Verifica se os campos FECP existem
Local lD1FECPST := SD1->(ColumnPos( "D1_ALFCPST" )) > 0 .And. SD1->(ColumnPos( "D1_VFECPST" )) > 0 .And. SD1->(ColumnPos( "D1_BSFCPST" )) > 0 // Verifica se os campos FECP_ST existem

If cPaisLoc == "BRA"
	// {Imposto, Valor, Aliquota, Base de Cálculo, Retenção}
	aAdd(aImpostos, {"IPI",     "SD1->D1_VALIPI",  "SD1->D1_IPI",     "SD1->D1_BASEIPI", .F.})
	aAdd(aImpostos, {"ICM",     "SD1->D1_VALICM",  "SD1->D1_PICM",    "SD1->D1_BASEICM", .F.})
	aAdd(aImpostos, {"ICMS_ST", "SD1->D1_ICMSRET", "SD1->D1_ALIQSOL", "SD1->D1_BRICMS",  .F.})
	aAdd(aImpostos, {"ISS",     "SD1->D1_VALISS",  "SD1->D1_ALIQISS", "SD1->D1_BASEISS", .F.})
	aAdd(aImpostos, {"PIS",     "SD1->D1_VALIMP6", "SD1->D1_ALQIMP6", "SD1->D1_BASIMP6", .F.})
	aAdd(aImpostos, {"CONFINS", "SD1->D1_VALIMP5", "SD1->D1_ALQIMP5", "SD1->D1_BASIMP5", .F.})
	aAdd(aImpostos, {"PIS",     "SD1->D1_VALPIS",  "SD1->D1_ALQPIS",  "SD1->D1_BASEPIS", .T.})
	aAdd(aImpostos, {"CONFINS", "SD1->D1_VALCOF",  "SD1->D1_ALQCOF",  "SD1->D1_BASECOF", .T.})
	aAdd(aImpostos, {"CSLL",    "SD1->D1_VALCSL",  "SD1->D1_ALQCSL",  "SD1->D1_BASECSL", .T.})
	aAdd(aImpostos, {"IRRF",    "SD1->D1_VALIRR",  "SD1->D1_ALIQIRR", "SD1->D1_BASEIRR", .T.})
	aAdd(aImpostos, {"INSS",    "SD1->D1_VALINS",  "SD1->D1_ALIQINS", "SD1->D1_BASEINS", .T.})

	//FECP e FECP-ST
	If (lD1FECP)
		aAdd(aImpostos, {"FECP", "SD1->D1_VALFECP", "SD1->D1_ALQFECP", "SD1->D1_BASFECP", .F.})
	EndIf

	If (lD1FECPST)
		aAdd(aImpostos, {"FECP_ST", "SD1->D1_VFECPST", "SD1->D1_ALFCPST", "SD1->D1_BSFCPST", .T.})
	EndIf
Else
	//-- Onde: ExpC1 := Código do TES
	//-- ExpA1[n][1] := Código do Imposto Ex: "IVA"
	//-- ExpA1[n][2] := Identifica em qual campos sera gravado o valor do imposto Ex: "VALIMP1"
	//-- ExpA1[n][3] := Define se o Imposto ser  somado ao total da Nota Fiscal. Ex: "S,N"
	//-- ExpA1[n][4] := Define se o Imposto ser  somado ao valor base das duplicatas. Ex: "S,N"
	//-- ExpA1[n][5] := Define se o Imposto ser  creditado ao custo. Ex: "S,N"
	//-- ExpA1[n][6] := Define se o Imposto ser  calculado com base no total dos itens ou no total das mercadorias. Ex: "S,N"
	//-- ExpA1[n][7] := Identifica em qual campo sera gravado a Base do  imposto Ex: "BASIMP1"
	//-- ExpA1[n][8] := Identifica em qual campo sera gravado a Aliquota do imposto Ex: "ALQIMP1

	aImpLoc := DefImposto(SD1->D1_TES)
	For nI := 1 To Len(aImpLoc)
		aAdd(aImpostos, {aImpLoc[nI, 1], "SD1->D1_" + aImpLoc[nI, 2], "SD1->D1_" + aImpLoc[nI, 8], "SD1->D1_" + aImpLoc[nI, 7], .F.})
	Next nI
EndIf

cXML := '<ListOfTaxes>'
For nI := 1 To Len(aImpostos)
	If &(aImpostos[Ni][2]) > 0
		cXML += '<Tax>'
		If val(cVersion) >= 4
			cXML +=    '<Tax>' + aImpostos[Ni, 1] + '</Tax>'
		Else
			cXML +=    '<Taxe>' + aImpostos[Ni, 1] + '</Taxe>'
		Endif
		cXML +=    '<StateCode>' + RTrim(SF1->F1_EST) + '</StateCode>'
		cXML +=    '<StateInternalId>' + RTrim(SF1->F1_EST) + '</StateInternalId>'
		cXML +=    '<CalculationBasis>' + cValToChar(&(aImpostos[Ni, 4])) + '</CalculationBasis>'
		cXML +=    '<Percentage>' + cValToChar(&(aImpostos[Ni, 3])) + '</Percentage>'
		cXML +=    '<Value>' + cValToChar(&(aImpostos[Ni, 2])) + '</Value>'
		cXML +=    '<WithHoldingTax>' + If(aImpostos[Ni, 5], 'true', 'false') + '</WithHoldingTax>'
		cXML += '</Tax>'
	EndIf
Next nI
cXML += '</ListOfTaxes>'

Return cXML

//-------------------------------------------------------------------
/*/{Protheus.doc} MTICalPrd()
Soma a quantidade de produtos iguais e do mesmo lote
para considerar no calculo do saldo anterior
@author Leonardo Quintania
@since 11/12/2013
@version 1.0
@return NIL
/*/
//-------------------------------------------------------------------
Static Function MTICalPrd(cChave,cLote)
Local nRet		:= 0
Local aRestSD1:= SD1->(GetArea())

Default cLote:= ""

If SD1->(DbSeek(cChave)) //D1_FILIAL + D1_DOC + D1_SERIE + D1_FORNECE + D1_LOJA + D1_COD
	While SD1->(!EOF()) .And. SD1->(D1_FILIAL + D1_DOC + D1_SERIE + D1_FORNECE + D1_LOJA + D1_COD) == cChave
		If Empty(cLote) .Or. SD1->D1_LOTECTL == cLote
			nRet+=	SD1->D1_QUANT
		EndIf
		SD1->(DbSkip())
	EndDo
EndIf

SD1->(RestArea(aRestSD1))

Return nRet
