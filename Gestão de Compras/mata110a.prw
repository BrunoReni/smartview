#INCLUDE "MATA110A.CH"
#INCLUDE "FWADAPTEREAI.CH"


// --------------------------------------------------------------------------------------
/*/{Protheus.doc} MATA110A
Criada somente para usar a IntegDef
@author  Raphael Augustos
@version P11.8
@since   13/05/2013
/*/
// --------------------------------------------------------------------------------------

Function MATA110A()

Return


// --------------------------------------------------------------------------------------
/*/{Protheus.doc} IntegDef
FNão

@param   cXml          Variável com conteúdo XML para envio/recebimento.
@param   nTypeTrans    Tipo de transação. (Envio/Recebimento)
@param   cTypeMessage  Tipo de mensagem. (Business Type, WhoIs, etc)

@author  Raphael Augustos
@version P11.8
@since   13/05/2013
@return  lRet - (boolean)  Indica o resultado da execução da função
         cXmlRet - (caracter) Mensagem XML para envio
/*/
// --------------------------------------------------------------------------------------

Static Function IntegDef( cXML, nTypeTrans, cTypeMessage )
Local aRet := {}

aRet := MATI110A(cXml, nTypeTrans, cTypeMessage )

Return aRet


// --------------------------------------------------------------------------------------
/*/{Protheus.doc} MATI110A
Cancelamento da requisição de compra.

@param   cXml          Variável com conteúdo XML para envio/recebimento.
@param   nTypeTrans    Tipo de transação. (Envio/Recebimento)
@param   cTypeMessage  Tipo de mensagem. (Business Type, WhoIs, etc)

@author  Raphael Augustos
@version P11.8
@since   13/05/2013
@return  lRet - (boolean)  Indica o resultado da execução da função
         cXmlRet - (caracter) Mensagem XML para envio
/*/
// --------------------------------------------------------------------------------------


Function MATI110A( cXML, nTypeTrans, cTypeMessage )
Local lRet     	 := .T.
Local cXmlRet    := ""
Local cError     := ""
Local cWarning   := ""
Local aCab       := {}
Local aItem      := {} 
Local nCount     := 1

Private oXml110A
Private oBusinessC

Private lMsErroAuto

If nTypeTrans == TRANS_RECEIVE

	//-- Recebimento da WhoIs - Qual é a versão da mensagem
	If cTypeMessage == EAI_MESSAGE_WHOIS 
		cXMLRet := '1.000'
			
	//-- Recebimento da Response Message
	ElseIf cTypeMessage == EAI_MESSAGE_RESPONSE
		cXMLRet := STR0006 //"OK"
		
	//-- Receipt Message (Aviso de receb. em transmissoes assincronas)
	ElseIf ( cTypeMessage == EAI_MESSAGE_RECEIPT )
		cXMLRet := STR0006 //"OK"
	ElseIf cTypeMessage == EAI_MESSAGE_BUSINESS  
		//Parser no XML
		oXml110A := XmlParser(cXml, "_", @cError, @cWarning)
		//Verifica se o XML está correto
		If ( oXml110A <> Nil ) .And. ( Empty(cError) ) .And. ( Empty(cWarning) ) 			
			oBusinessC := oXml110A:_TOTVSMessage:_BusinessMessage:_BusinessContent // Mapeamento			
			If Type("oBusinessC:_RequestInternalId:Text") != "U" .And. !Empty(oBusinessC:_RequestInternalId:Text)
				If Type("oBusinessC:_Type:Text") != "U" .And. !Empty(oBusinessC:_Type:Text)
					If AllTrim(oBusinessC:_Type:Text) == "000"					
						aRequest   := Separa(oBusinessC:_RequestInternalId:Text,"|")			
						If SC1->( DbSeek( xFilial("SC1") + PadR(aRequest[3], TamSX3('C1_NUM')[1]) + PadR(aRequest[4], TamSX3('C1_ITEM')[1])  ))
							 RecLock("SC1",.F.)
								SC1->C1_ACCPROC := "2"
								SC1->C1_ACCNUM  := ""
								SC1->C1_ACCITEM := ""
							 MsUnLock()
							 cXmlRet    := STR0005 //"Operação de cancelamento da solicitação de compra efetuda com sucesso."
						Else
							lRet := .F.
							cXmlRet    := STR0004 //"A solicitação informada na tag RequestInternalId não foi localizada na base de dados."
						EndIf
					Else
						lRet := .F.
						cXmlRet    := STR0003 //Tag 'Type' com valor inválido. Opção disponível: 000."					
					EndIf					
				Else
					lRet := .F.
					cXmlRet    := STR0002 //"Informe a tag 'Type'."					
				EndIf							
			Else
				lRet := .F.
				cXmlRet    := STR0001 //"Informe a tag: RequestInternalId"
			EndIf			
		EndIf
	EndIf
	
ElseIf nTypeTrans == TRANS_SEND

EndIf


Return { lRet, cXMLRet }