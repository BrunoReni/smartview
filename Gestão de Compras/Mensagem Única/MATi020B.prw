#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWADAPTEREAI.CH"
#INCLUDE "MATA020B.CH"

/*/{Protheus.doc} MATI020B
// Rotina de Integração EAI - Consulta/Atualiza sequencia de numeracao unica 
@author tiago.dsantos
@since 08/06/2017
@version undefined
@param cXML    , characters, Xml retornado pelo request na comunicação EAI
@param nType   , numeric   , Tipo da Transmissão TRANS_SEND ou TRANS_RECEIVE
@param cMsgType, characters, quando tipo for TRANS_RECEIVE pode assumir: 
                             20=EAI_MESSAGE_BUSINESS;21=EAI_MESSAGE_RESPONSE;
                             22=EAI_MESSAGE_RECEIPT;24=EAI_MESSAGE_WHOIS
@param cVersion, characters, versao do adapter 1.0,2.0, n.0
@type function
/*/
Function MATI020B(cXML,nType,cMsgType,cVersion)
Local  aResult     := {}
Local  cRotina     := "MATA020B"
Local  aErrors     := {}
Local  cAsinc      := "1" //| 1-Sincrono;2-Assincrono; Usar para proteger a integracao de usar sincrono ou assincrono de acordo com o que for definido.
Local  cXmlRet     := ""
Local  cEntityName := "CUSTOMERVENDORRESERVEID"

Default cXML		:= ""
Default nType		:= 1 
Default cMsgType	:= ""
Default cVersion 	:= "1.000"

If Type("cUnqOrigem") == "U"
	Private cUnqOrigem := FunName()
EndIf

If Type("lHasCode") == "U"
	Private lHasCode := .F.
EndIf

If Type("cCodResult") == "U"
	Private cCodResult	:= ""
EndIf

//Trata o Envio/Recebimento do XML
If nType == TRANS_SEND
	aResult := FSend(cVersion,cEntityName)

//Recebimento
ElseIf nType == TRANS_RECEIVE     
  	aResult := FReceive(cXML,cMsgType,cVersion,cEntityName) 
EndIf
  
AAdd(aResult,cEntityName)	

Return aResult

/*/{Protheus.doc} FSend
//TODO Trata o envio
@author tiago.dsantos
@since 08/06/2017
@version undefined
@param cVersion, characters, descricao
@param cEntityName, characters, descricao
@type function
/*/
Static Function FSend(cVersion,cEntityName) 
Local lRet        := .T.
Local cXMLRet     := ""
Local cEvent      := "upsert"
Local cInternalId := cEmpAnt + "|" + cFilAnt
Local cCodigo     := ""
Local cCNPJCPF    := "" // CPF ou CNPJ 
Local cINSCRME    := "" // Inscricao Municipal ou Estadual
Local cDataEnv    := INTDTANO(Date()) + "T" + Time()
Local lExistIFIE  := .F.
Local cRG		  := ""

Default cVersion	:= ""
Default cEntityName	:= ""

If !INCLUI .And. !ALTERA
	cEvent	:= "delete"
Else
	cEvent	:= "upsert"
EndIf

//| Cadastro de Fornecedores
If Upper(cUnqOrigem) == "MATA020"

	cCodigo   	:= IIf( type("M->A2_COD"  ) 	== "U",Space(TamSx3("A2_COD"  )[1])		,M->A2_COD)
	cINSCRME  	:= IIf( type("M->A2_INSCR") 	== "U",Space(TamSx3("A2_INSCR")[1])		,M->A2_INSCR) 
	cRG			:= IIf( type("M->A2_PFISICA") 	== "U",Space(TamSx3("A2_PFISICA")[1])	,M->A2_PFISICA)
	cCNPJCPF  	:= IIf( type("M->A2_CGC"  ) 	== "U",Space(TamSx3("A2_CGC"  )[1])		,M->A2_CGC)
		
//| Cadastro de Clientes
ElseIf Upper(cUnqOrigem) == "MATA030"

	cCodigo   	:= M->A1_COD
	cINSCRME  	:= M->A1_INSCR
	cRG			:= M->A1_PFISICA
	cCNPJCPF  	:= M->A1_CGC

//| Cadastro de transportadores
ElseIf Upper(cUnqOrigem) == "MATA050"

	cCodigo   	:= M->A4_COD
	cCNPJCPF  	:= M->A4_CGC
	cINSCRME  	:= M->A4_INSEST
	cRG			:= ""
	
EndIf

//| Se já existe o preenchimento do CNPJ/CPF e Inscrição Estadual ou Municipal muda o flag para true
//| e libera o envio via tag GovernmentalInformation
If !Empty(cCNPJCPF) .Or. !Empty(cINSCRME)
	lExistIFIE := .T.
EndIf

cXMLRet := FWEAIBusRequest( cEvent ) 

cXMLRet += "<BusinessContent>"
cXMLRet +=       "<CompanyId>"          + cEmpAnt              + "</CompanyId>"
cXMLRet +=       "<BranchId>"           + cFilAnt              + "</BranchId>"
cXMLRet +=       "<BranchInternalId>"   + cFilAnt              + "</BranchInternalId>"
cXMLRet +=       "<CompanyInternalId>"  + cEmpAnt              + "</CompanyInternalId>"
cXMLRet +=       "<InternalId>"         + cInternalId          + "</InternalId>"

If !Empty(cCodigo) .And. lHasCode
	cXMLRet +=       "<Code>"               + RTrim(cCodigo) + "</Code>"
EndIf

If lExistIFIE
	cXMLRet +=       "<GovernmentalInformation>"
	cXMLRET +=              "<Id name='INSCRICAO ESTADUAL' scope='State' expiresOn='' issueOn='" + cDataEnv + "'>" + RTrim(cINSCRME) + "</Id>"
	cXMLRET +=              "<Id name='CPFCNPJ' scope='Federal' expiresOn='' issueOn='"          + cDataEnv + "'>" + RTrim(cCNPJCPF) + "</Id>"
	cXMLRET +=              "<Id name='RG' scope='Federal' expiresOn='' issueOn='"          	 + cDataEnv + "'>" + RTrim(cRG) + "</Id>"
	cXMLRet +=       "</GovernmentalInformation>"
EndIf

cXMLRet += "</BusinessContent>"

Return {lRet,cXMLRet}

/*/{Protheus.doc} FReceive
//TODO Descrição auto-gerada.
@author tiago.dsantos
@since 08/06/2017
@version undefined
@param   cXML    , characters, XML Recebido da aplicação externa 
@param   cMsgType, characters, tipo da mensagem, sendo: EAI_MESSAGE_BUSINESS; EAI_MESSAGE_RESPONSE;
                                                         EAI_MESSAGE_RECEIPT;EAI_MESSAGE_WHOIS
@param   cVersion, characters, versao da mensagem
@type function
/*/
Static Function FReceive(cXML,cMsgType,cVersion,cEntityName)
Local lRet    := .T.
Local aResult := {}

//+---------------------------------------
//| Retorna a versao disponivel do EAI
//+---------------------------------------
If cMsgType == EAI_MESSAGE_WHOIS
	aResult := {lRet,"1.0"}

	//+---------------------------------------
	//| Response Message
	//+---------------------------------------
ElseIf cMsgType == EAI_MESSAGE_RESPONSE
	aResult :=  FResponse(cXML,cVersion,cEntityName)

	//+---------------------------------------
	//| Receipt Message
	//+---------------------------------------
ElseIf cMsgType == EAI_MESSAGE_RECEIPT
	aResult := FReceipt(cXML,cVersion,cEntityName)

	//+---------------------------------------
	//| Business Message
	//+---------------------------------------
ElseIf cMsgType == EAI_MESSAGE_BUSINESS
	aResult := FBusiness(cXML,cVersion,cEntityName)

EndIf

Return aResult

/*/{Protheus.doc} FReceipt
// Processa a Mensagem de Recepcao
@author tiago.dsantos
@since 08/06/2017
@version undefined
@param cXML, characters, descricao
@param cVersion, characters, descricao
@param cEntityName, characters, descricao
@type function
/*/
Static Function FReceipt(cXML,cVersion,cEntityName)
Local aResult := {}
Local lRet    := .T.
Local cXMLRet := ""
Local oXML    := Nil

aResult :={lRet,cXMLRet}

Return aResult


/*/{Protheus.doc} FResponse
// Processa a mensagem de resposta
@author tiago.dsantos
@since 08/06/2017
@version undefined
@param cXML, characters, descricao
@param cVersion, characters, descricao
@param cEntityName, characters, descricao
@type function
/*/
Static Function FResponse(cXML,cVersion,cEntityName)
Local aResult   := {}
Local lRet      := .T.
Local cXMLRet   := ""
Local oXML      := NIL
Local aErrorMsg := {}
Local cErrorXml := ""
Local cWarnXml  := ""
Local cCode     := ""
Local cAlias    := ""
Local cCampo    := ""
Local nSqlError := 0
Local cUpdQuery := ""
Local cUnqKey   := ""
	
oXml := TXmlManager():New()

If oXml:Parse(cXML) 
         
	//+---------------------------------------------------------------
	//| Preenche o código dos cadastros de acordo com a origem
	//+---------------------------------------------------------------
	If Upper(oXml:xPathGetNodeValue("/TOTVSMessage/ResponseMessage/ProcessingInformation/Status")) == "OK"
     
         cCode      := oXML:xPathGetNodeValue("/TOTVSMessage/ResponseMessage/ReturnContent/Code")
         
         If Upper(cUnqOrigem) == "MATA020"
              If cCode <> "0" 
                   cCode := PadR(cCode,TamSx3("A2_COD")[1]," ")
                   M->A2_COD  := cCode
              EndIf
                  
              cCodResult := M->A2_COD 
              cAlias    := "SA2"
              cCampo    := "A2_COD"     
                    
         ElseIf Upper(cUnqOrigem) == "MATA030"
              If cCode <> "0"
                  cCode := PadR(cCode,TamSx3("A1_COD")[1]," ")
                  M->A1_COD  := cCode                  
              EndIf
            
              cCodResult := M->A1_COD
              cAlias    := "SA1"
              cCampo    := "A1_COD"              
              
	     ElseIf Upper(cUnqOrigem) == "MATA050"
	          If cCode <> "0"
	               cCode := PadR(cCode,TamSx3("A4_COD")[1]," ")
	               M->A4_COD := cCode  
	          EndIf
	          
	          cCodResult := M->A4_COD
	          cAlias    := "SA4"
	          cCampo    := "A4_COD"

         EndIf
                  
         //-- Monta a mensagem de erro
         If !Empty(aErrorMsg)
             lRet := .F.
             cXmlRet := FWEAILOfMessages( aErrorMsg )
         EndIf

	 //+---------------------------------------------------------------
	 //| Status <> 'OK' trada mensagem de erro retornada...
	 //+---------------------------------------------------------------
	 Else
	      lRet := .F.
	      oXML := XmlParser(cXml,"_",@cErrorXml, @cWarnXml)
	      If oXML != NIL
	           aErrorMsg := ListErrors(oXML)
	      EndIf
	 EndIf
Else
   lRet := .F.
   
   cErrorXml := oXML:Error()
   Aadd(aErrorMsg,{cErrorXml,1,"ENQ-001"})
       
EndIf
       
If !Empty(aErrorMsg)
	lRet := .F.
	cXmlRet := FWEAILOfMessages( aErrorMsg )
EndIf

aResult := {lRet,cXMLRet}
Return aResult

/*/{Protheus.doc} FBusiness
//Processamento da Mensagem de Negocios
@author tiago.dsantos
@since 08/06/2017
@version undefined
@param cXML, characters, descricao
@param cVersion, characters, descricao
@param cEntityName, characters, descricao
@type function
/*/
Static Function FBusiness(cXML,cVersion,cEntityName)
Local aResult    := {}
Local lRet       := .T.
Local cXMLRet    := ""
Local oXML       := NIL
Local aErrorMsg  := {}
Local cRotInt    := ""
Local cCode      := ""
Local cEvent     := ""
Local cMarca     := ""
Local cDATATU    := Transform(DtoS(Date()),"@R 9999-99-99") + "T" + Time()
Local cCNPJCPF   := ""
Local cInscEst   := ""
Local cIntId     := "" 

//+------------------------------------------------------------------------------
//| Parse do XML
//+------------------------------------------------------------------------------
oXML := TXmlManager():New()
If !oXml:Parse(cXml)
	AAdd(aErrorMsg,{"Não foi possível ler o xml recebido.Verifique.",1,"ENQ-002"})
	           
	lRet    := .F.
	cXmlRet := FwEAILOfMessages( aErrorMsg )
	
	Return {lRet,cXMLRet}
EndIf

//+------------------------------------------------------------------------------
//| Processa o XML recebido
//+------------------------------------------------------------------------------
cMarca     := oXml:XPathGetAtt( "/TOTVSMessage/MessageInformation/Product", "name" )
cEvent     := Upper(oXml:xPathGetNodeValue("/TOTVSMessage/BusinessMessage/BusinessRequest/Operation")) 
cIntId     := oXml:xPathGetNodeValue("/TOTVSMessage/BusinessMessage/BusinessContent/origen")
cCode      := oXml:xPathGetNodeValue("/TOTVSMessage/BusinessMessage/BusinessContent/Code")

//-- xPathGetChildArray é utilizado para converter as tags em vetor e getAttrib e utilizado para obter o atributo
aTemp      := oXml:xPathGetChildArray("/TOTVSMessage/BusinessMessage/BusinessContent/GovernmentalInformation")

cCnpjCpf   := getAttrib(oXml,aTemp,"NAME","CPFCNPJ")
cInscEst   := getAttrib(oXml,aTemp,"NAME","INSCRICAO ESTADUAL")

aTemp      := oXml:xPathGetChildArray("/TOTVSMessage/BusinessMessage/BusinessContent/InternalId")
cIntId     := getAttrib(oXml,aTemp,"NAME","InternalId")

//+------------------------------------------------------------------------------
//| Monta Retorno para a aplicação de origem
//+------------------------------------------------------------------------------
If lRet 
	If Empty(cCode)
         cXMLRet := "<Code>" + AllTrim(SubStr(GetSx8Num("SA1","A1_COD"),2,TamSx3("A1_COD")[1])) + "</Code>"
    Else 
     	//-- por ser um simulado devolve o mesmo código, mas o correto é validar a reserva em tabela...
     	cXMLRet := "<Code>" + cCode + "</Code>"
     EndIf

    cXMLRet += "<ListOfInternalId>"
    cXMLRet +=        "<Name>" + cEntityName + "</Name>"
    cXMLRet +=        "<Origin>" + cIntId + "</Origin>"
    cXMLRet +=        "<Destination>2</Destination>"
    cXMLRet += "</ListOfInternalId>"

Else
     cXMLRet := "Erro de Operacao| Não foi possível recuperar o código"
EndIf

aResult := {lRet,cXMLRet}
Return aResult

/*/{Protheus.doc} getAttrib
//Função para obter o valor de um atributo de um Nó 
@author tiago.dsantos
@since 08/06/2017
@version undefined
@param oXml        , object    , objeto do XML traduzido
@param aNodes      , array     , vetor contendo as repetições dentro de um grupo.
@param cAttrName   , characters, nome do atributo
@param cAttrValue  , characters, valor vinculado ao atributo
@type function
/*/
Static Function getAttrib(oXml,aNodes,cAttrName,cAttrValue)
Local cResult := ""
Local nI      := 0
Local nPos    := 0

If Empty(aNodes)
	Return cResult
EndIf
  
For nI:=1 To Len(aNodes)
	aAttrib := oXml:xPathGetAttArray(aNodes[nI][2])
  
	nPos    := AScan(aAttrib, {|v| Upper(v[1]) == Upper(cAttrName) .And. Upper(v[2]) == Upper(cAttrValue) })
   
	If nPos > 0
       cResult := aNodes[nI][3] //| Conteudo da Tag ...não é o conteúdo do atributo.
       Exit
   EndIf
Next nI
      
Return cResult


/*/{Protheus.doc} SalvaMsgInt
//TODO Descrição auto-gerada.
@author tiago.dsantos
@since 08/06/2017
@version undefined
@param oXml, object, descricao
@param cAlias, characters, descricao
@param cCampo, characters, descricao
@param aMsgERet, array, descricao
@type function
/*/
Static Function SalvaMsgInt(oXml,cAlias,cCampo,aMsgERet)
Local lRet         := .T.
Local nX           := 1
Local cMarca       := oXml:_TOTVSMessage:_MessageInformation:_Product:_Name:Text
Local lStatus      := .F.
Local oXmlContent  := NIL 
Local cContType    := ""
Local cOrigin      := ""
Local cDestin      := ""
Local cEvent       := "upsert"
Local aMessages    := {}

lStatus := Upper(oXml:_TOTVSMessage:_ResponseMessage:_ProcessingInformation:_Status:Text) == "OK"

If XmlChildEx( oXml:_TOTVSMessage:_ResponseMessage,"_RECEIVEDMESSAGE") <> Nil
	If XmlChildEx( oXml:_TOTVSMessage:_ResponseMessage:_ReceivedMessage,"_EVENT") <> Nil
		cEvent := Upper(oXml:_TOTVSMessage:_ResponseMessage:_ReceivedMessage:_Event:Text)
	EndIf
EndIf

//| Tratamento do Retorno da Mensagem para gravar os InternalIds necessarios
//| para o controle da aplicação.
IF lStatus == .T.

	oXmlContent := oXml:_TOTVSMessage:_ResponseMessage:_ReturnContent//:_ReturnContent

	If (XmlChildEx( oXmlContent                  , '_LISTOFINTERNALID' ) <> Nil .And. ;
		XmlChildEx( oXmlContent:_ListOfInternalId, '_INTERNALID'       ) <> Nil) .Or.  ;
		XmlChildEx( oXmlContent                   , '_InternalID')

		cContType := ValType(oXmlContent:_ListOfInternalId:_InternalId)

		//| Quando houver mais de um InternalId da mensagem
		If cContType == "A"

			XmlNode2Arr( oXmlContent:_ListOfInternalId:_InternalId,"_InternalId")

			//| Salva os codigos dos produtos na tabela XXF
			For nX:=1 to Len(oXmlContent:_ListOfInternalId:_InternalId)

				cOrigin := oXmlContent:_ListOfInternalId:_InternalId[nx]:_Origin:Text
				cDestin := oXmlContent:_ListOfInternalId:_InternalId[nx]:_Destination:Text

				CFGA070MNT( cMarca,cAlias,cCampo ,;
							cDestin ,; //| Código da outra aplicação
							cOrigin ,; //| código gerado para o Protheus
							(cEvent == "DELETE")) // Quando .T. deleta o registro de depara.

			Next nX

			//| Para apenas um InternalId na mensagem
		Else
			cOrigin := oXmlContent:_ListOfInternalId:_InternalId:_Origin:Text
			cDestin := oXmlContent:_ListOfInternalId:_InternalId:_Destination:Text

			CFGA070MNT( cMarca, "DTY", "DTY_NUMCTC" ,;
						cDestin ,;           //| Código da outra aplicação
						cOrigin ,;           //| código gerado pelo Protheus
						(cEvent == "DELETE")) //| Quando .T. deleta o registro de depara.

		EndIf

	EndIf 

	
Else
	//| Tratamento do Retorno da Mensagem de Erro
	lRet    := .F.

	aMsgERet := ListErrors(oXML)
	AAdd(aMsgERet,{STR0003,2,"WA001"})// 'Houve um erro na mensagem e este não pôde ser identificado.'
EndIf
       
Return lRet


/*/{Protheus.doc} ListErrors
//TODO Descrição auto-gerada.
@author tiago.dsantos
@since 08/06/2017
@version undefined
@param oXML, object, descricao
@type function
/*/
Static Function ListErrors(oXML)
Local aLisMsg := {}
Local cMsg    := ""
Local cType   := ""
Local cCode   := ""
Local nType   := 1
Local nCount  := 0
     
//-- Mensagens de erro no padrao ListOfMessages
If XmlChildEx(oXml:_TOTVSMessage, '_RESPONSEMESSAGE' ) != Nil .And.;
	XmlChildEx(oXml:_TOTVSMessage:_ResponseMessage, '_PROCESSINGINFORMATION' ) != Nil .And.;
	XmlChildEx(oXml:_TOTVSMessage:_ResponseMessage:_ProcessingInformation, '_LISTOFMESSAGES' ) != Nil .And.;
	XmlChildEx(oXml:_TOTVSMessage:_ResponseMessage:_ProcessingInformation:_ListOfMessages, '_MESSAGE' ) != Nil

	//-- Se nao for array
	If ValType(oXml:_TOTVSMessage:_ResponseMessage:_ProcessingInformation:_ListOfMessages:_Message) != "A"
		//-- Transforma em array
		XmlNode2Arr(oXml:_TOTVSMessage:_ResponseMessage:_ProcessingInformation:_ListOfMessages:_Message, "_Message")
	EndIf

	//-- Percorre o array para obter os erros gerados
	For nCount := 1 To Len(oXml:_TOTVSMessage:_ResponseMessage:_ProcessingInformation:_ListOfMessages:_Message)

		cMsg    := ""
		cType   := ""
		cCode   := ""
		nType   := 1

		cMsg := oXml:_TOTVSMessage:_ResponseMessage:_ProcessingInformation:_ListOfMessages:_Message[nCount]:Text

		//-- Verifica se o tipo da mensagem foi informado
		If XmlChildEx(oXml:_TOTVSMessage:_ResponseMessage:_ProcessingInformation:_ListOfMessages:_Message[nCount], '_TYPE' ) != Nil .And.;
			!Empty(oXml:_TOTVSMessage:_ResponseMessage:_ProcessingInformation:_ListOfMessages:_Message[nCount]:_type:Text)
			
			cType := oXml:_TOTVSMessage:_ResponseMessage:_ProcessingInformation:_ListOfMessages:_Message[nCount]:_type:Text
			Do Case
				Case (Upper(cType) == "ERROR")
				nType := 1
				Case (Upper(cType) == "WARNING")
				nType := 2
			EndCase
			
		EndIf

		//-- Verifica se o codigo da mensagem foi informado
		If XmlChildEx(oXml:_TOTVSMessage:_ResponseMessage:_ProcessingInformation:_ListOfMessages:_Message[nCount], '_CODE' ) != Nil .And.;
			!Empty(oXml:_TOTVSMessage:_ResponseMessage:_ProcessingInformation:_ListOfMessages:_Message[nCount]:_code:Text)
			
			cCode := oXml:_TOTVSMessage:_ResponseMessage:_ProcessingInformation:_ListOfMessages:_Message[nCount]:_code:Text
		EndIf

		If ! Empty(cCode)
			cMsg += " (" + cCode + ")"
		EndIf

		Aadd(aLisMsg, {cMsg, nType, cCode})
	Next nCount
EndIf

Return aLisMsg


//-------------------------------------------------------------------
/*/ {Protheus.doc} A020CodUnq
	
Retorna se deve a rotina é código único, restaurando a XX4 posicionada, 
antes da chamada da FWHASEAI.
		 
@sample	A020CodUnq()
			
@param		Nenhum
				
@author    Leandro Paulino	
@since		04/07/2015
@version	P12 
/*/
//-------------------------------------------------------------------
Function A020CodUnq()
Local lRet 		  := .F.
Local aXX4Area    := XX4->(GetArea()) //-- não deve ser inicializado depois do FWHasEAI para não desposicionar o XX4

lRet := FindFunction("GETROTINTEG") .And. FindFunction("FWHASEAI") .And. FwHASEAI("MATA020B")

RestArea(aXX4Area)

Return lRet
