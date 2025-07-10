#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWADAPTEREAI.CH" 
#INCLUDE "MATI130.CH"
 
#DEFINE ACCNUM	1
#DEFINE ACCITEM	2
#DEFINE NUMSC		3
#DEFINE EMISSAO	4
#DEFINE FORNECE	5
#DEFINE WINNER	6
#DEFINE COND		7
#DEFINE TPFRETE	8
#DEFINE OBS		9
#DEFINE PRECO 	10
#DEFINE VALFRE	11
#DEFINE MOEDA	   12
#DEFINE ENDDATE  13
#DEFINE PRAZO	   14
#DEFINE QUANT	   15
#DEFINE ACCUSER  16



// --------------------------------------------------------------------------------------
/*/{Protheus.doc} MATI130
Função de integração com o adapter EAI para recebimetno de cotação


@param   cXml          Variavél com conteúdo do XML para envio/recebimento.
@param   nTypeTrans    Tipo de transação. (Envio/Recebimento)
@param   cTypeMessage  Tipo de mensagem. (Business Type, WhoIs, etc)

@author  Raphael Augustos
@version P11.8
@since   13/05/2013
@return  lRet - (boolean)  Indica o resultado da execução da função
         cXmlRet - (caracter) Mensagem XML para envio
/*/
// --------------------------------------------------------------------------------------

Function MATI130( cXML, nTypeTrans, cTypeMessage, cVersion )
Local lRet     	 := .T.
Local cXMLRet  	 := "" // Retorno de função
Local cError	 := "" //ParserXML
Local cWarning 	 := "" //ParserXML
Local aArea		 := GetArea()
Local aRet       := {}
Local aDadosMkt  := {} 			//Contém os dados do XML enviado pelo Mkt place
Local nX		 := 1	
Private oXmlA130   := Nil
Private aDePara    := {}

//Tratamento do recebimento de mensagens
If nTypeTrans == TRANS_RECEIVE
	//-- Recebimento da WhoIs - Qual é a versãoo da mensagem
	If cTypeMessage == EAI_MESSAGE_WHOIS 
		cXMLRet := '1.000'
	//-- Recebimento da Response Message
	ElseIf cTypeMessage == EAI_MESSAGE_RESPONSE
		cXMLRet := '<TAGX>TESTE DE RECEPCAO RESPONSE MESSAGE</TAGX>'
	//-- Receipt Message (Aviso de receb. em transmissoes assincronas)
	ElseIf ( cTypeMessage == EAI_MESSAGE_RECEIPT )
		cXMLRet := '<TAGX>TESTE DE RECEPCAO RECEIPT MESSAGE</TAGX>'
	ElseIf cTypeMessage == EAI_MESSAGE_BUSINESS  
		//Parser no XML
		oXmlA130 := XmlParser(cXml, "_", @cError, @cWarning)
		//Verifica se o XML está correto
		If ( oXmlA130 <> Nil ) .And. ( Empty(cError) ) .And. ( Empty(cWarning) ) 
			
			aDadosMkt := I130LECOTA()     
			 
			If aDadosMkt[1]
				aRet := A130IGRAVA(aDadosMkt[2])
				If !aRet[1]
					//Problema de de gravação
					cXmlRet := aRet[2]
					lRet := aRet[1]
				Else 
					cXmlRet := "OK"
				EndIf
			Else
				//Problema estrutural do XML
			 	lRet := aDadosMkt[1] 
			 	For nX:=1 to len(aDadosMkt[3])
					cXmlRet+= '<Message type="ERROR" code="c2">'+ aDadosMkt[3][nX] + '</Message>'
				Next
			EndIf
		EndIf
		
	EndIf
	
ElseIf nTypeTrans == TRANS_SEND

EndIf


RestArea( aArea )
Return { lRet, cXMLRet } 

// --------------------------------------------------------------------------------------
/*/{Protheus.doc} MATI130
Função responsável por gerar a cotação e pedido de compra.

@param   aGrava

@author  Raphael Augustos
@version P11.8
@since   13/05/2013
@return  lRet - (boolean)  Indica o resultado da execução da função
         cXmlRet - (caracter) Mensagem XML para envio
/*/
// --------------------------------------------------------------------------------------

Function A130IGRAVA(aGrava)
Local nX         := 1
Local cCompACC   := ""
Local cComprador := ""
Local cACCNum    := ""
Local cACCItem   := ""
Local aReqNum    := ""
Local aReqItem   := ""

//-- Variaveis da ExecAuto 150
Local aHeader150 := {}
Local aItens150  := {}
Local aCabec     := {}
Local cFilEn     := ""
Local nPPreco	 := 0
Local nPItem	 := 0
LOcal nPQuant	 := 0
Local nPTotal	 := 0
Local nItem		 := 0
Local nPFilen    := 0    
Local cRet       := ""
Local nIndItem   := 0

//-- Variaveis da ExecAuto 160
Local aAutoCab 	 := {}
Local aAutoItm 	 := {}

Local aErroAuto	:= {}
Local nCount	:= 1
Local cXMLRet	:= ""       
Local lRet		:= .T.
Local dDatNec	:= dDataBase
Local lConfirm	:= .F.
Local nSaveSX8	:= 0
Local nY		:= 0
Local cItemCot	:= "0000"
Local lMTI130C8	:= ExistBlock('MTI130C8') 

//Obtem as requisições e o fornecedor
Local aRequest   	:= {}
Local aFornec    	:= {}
Local cFornec    	:= {}
Local cLoja      	:= {}
Local aRecSC8		:= {}
Local lInsert			:= .F.
Private aSCComCe   := {} 
Private lMsErroAuto		:= .F.
Private lAutoErrNoFile	:= .T.

aAdd(aCabec,"C8_NUM")
aAdd(aCabec,"C8_FORNECE")
aAdd(aCabec,"C8_LOJA")
aAdd(aCabec,"C8_COND")
aAdd(aCabec,"C8_CONTATO")
aAdd(aCabec,"C8_MOEDA")
aAdd(aCabec,"C8_EMISSAO")
aAdd(aCabec,"C8_TOTFRE")
aAdd(aCabec,"C8_VALDESC")
aAdd(aCabec,"C8_DESPESA")
aAdd(aCabec,"C8_SEGURO")
aAdd(aCabec,"C8_DESC1")
aAdd(aCabec,"C8_DESC2")
aAdd(aCabec,"C8_DESC3") 

DbSelectArea("SC1")
DbSelectArea("SB1")

cNumSC8  := GetNumSC8()
lConfirm := .T.

aSort(aGrava,,,{|x,y| x[3] < y[3]})

For nX := 1 to Len(aGrava)	
	
	aRequest   := I130RetSc(aGrava[nX][NUMSC]) 			// Retorna Empresa|Filial|Request|Item amarrados ao item da cotação
	aFornec	   := Separa(aGrava[nX][FORNECE], "|") 	// Fornecedor
	aCond      := Separa(aGrava[nX][COND], "|") 		// Condicao de Pagamento
	aMoeda     := Separa(aGrava[nX][MOEDA],"|")		// Moeda
	cFornec    := Padr( aFornec[3] , TamSX3("A2_COD")[1] )    
	cLoja      := Padr( aFornec[4] , TamSX3("A2_LOJA")[1] )
	cACCNum    := Padr( aGrava[nX][ACCNUM] , TamSX3("C8_ACCNUM")[1] )
	cACCItem   := Padr( aGrava[nX][ACCITEM] , TamSX3("C8_ACCNUM")[1] )
	
	//Obtém o código do comprador informado na mensagem de Request
	If !Empty( aGrava[nX][ACCUSER] )
		cCompACC := aGrava[nX][ACCUSER]
		If !Empty( cCompACC )
			SY1->( DbSetOrder(3) )
			If SY1->( DbSeek(xFilial("SY1")+cCompACC) )
				cComprador := SY1->Y1_USER
			EndIf
		EndIf
	EndIf

	SA2->( dbSetOrder(1) )
	SC8->( dbOrderNickname("ACC") )
	If !SC8->( DbSeek( xFilial("SC8") + cACCNum + cACCItem + cFornec + cLoja ) ) 
		SC8->( DbSetOrder(1) )
		If SA2->( DbSeek(xFilial("SA2")+cFornec+cLoja) )

			If aScan ( aRequest , {|x| Padr( x[2] , Len(cFilAnt)) # xFilial("SC1") } ) > 0
				I130ComSC(aRequest)
			EndIf

			aReqNum    := PadR( aRequest[1][3], TamSX3('C1_NUM')[1] )
			aReqItem   := PadR( aRequest[1][4] , TamSX3('C1_ITEM')[1] )
			SC1->( DbSetOrder(1) )
			If SC1->( DbSeek( xFilial("SC1") + aReqNum + aReqItem ) )			
				SB1->(DbSeek(xFilial("SB1")+SC1->C1_PRODUTO))
				
				SC8->(DbSetOrder(3))
				lInsert := !SC8->(DbSeek(xFilial("SC8") + cNumSC8 + SC1->C1_PRODUTO))
				
				If(!lInsert)
					//Se a Data for diferente, insere um novo registro e não aglutina.
					lInsert := (SC8->C8_DATPRF  != SC1->C1_DATPRF)
				EndIf
				
				If lInsert
					cItemCot   := soma1(cItemCot)
				Endif
				
				RecLock("SC8",lInsert)			
				SC8->C8_FILIAL  := xFilial("SC8")
				SC8->C8_FILENT  := SC1->C1_FILENT
				SC8->C8_NUM  	:= cNumSC8
				SC8->C8_ITEM    := cItemCot
				SC8->C8_EMISSAO	:= dDataBase
				SC8->C8_GRUPCOM := SC1->C1_GRUPCOM
				SC8->C8_COND    := aCond[3]
				SC8->C8_FORNECE := SA2->A2_COD
				SC8->C8_LOJA    := SA2->A2_LOJA
				SC8->C8_FORNOME := SA2->A2_NOME
				SC8->C8_PRODUTO := SC1->C1_PRODUTO
				SC8->C8_MOEDA   := Val(aMoeda[3])
				SC8->C8_NUMPRO  := "01"			
				SC8->C8_UM      := SC1->C1_UM
				SC8->C8_QUANT   := IIf(lInsert,aGrava[nX][QUANT],SC8->C8_QUANT+aGrava[nX][QUANT])
				SC8->C8_VALIDA  := dDatabase + 30
				SC8->C8_ACCNUM  := aGrava[nX][ACCNUM]
				SC8->C8_ACCITEM := aGrava[nX][ACCITEM]
				SC8->C8_PRAZO   := IIf(Empty(aGrava[nX][PRAZO]),RetFldProd(SC1->C1_PRODUTO,"B1_PE"),aGrava[nX][PRAZO])
				SC8->C8_DATPRF  := SC1->C1_DATPRF
				SC8->C8_SEGUM	:= SC1->C1_SEGUM
				SC8->C8_QTSEGUM := SC1->C1_QTSEGUM
				SC8->C8_ORIGEM  := SC1->C1_ORIGEM
				SC8->C8_NUMSC   := SC1->C1_NUM
				SC8->C8_ITEMSC  := SC1->C1_ITEM
				SC8->C8_PICM    := SB1->B1_PICM
				SC8->C8_ALIIPI  := SB1->B1_IPI				
				SC8->C8_OBS     := SC1->C1_OBS											
				SC8->C8_IDENT   := Iif(lInsert,cItemCot,SC8->C8_ITEM)
				
				If lMTI130C8
					ExecBlock("MTI130C8",.F.,.F.) //Grava campos de usuario
				EndIf
				
				SC8->(MsUnlock())
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Confirma a utilizacao do SX8  ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				While lConfirm .And. (GetSX8Len() > nSaveSX8)
					ConfirmSx8()
				End
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Grava a Cotacao na Solicitacao  ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				I130GrvSC(aRequest,cNumSC8,cItemCot) 
				
				If lInsert
					aAdd(aRecSC8,{	SC8->(Recno()),;	// 1- Recno na tabela SC8
						cFilAnt,;						// 2- Filial
						SC8->C8_NUM,;					// 3- Cotacao Protheus
						SC8->C8_ITEM,;					// 4- Item da cotacao Protheus
						aGrava[nX][ACCNUM],;			// 5- Cotacao ACC
						aGrava[nX][ACCITEM],;			// 6- Item da cotacao ACC
						SA2->A2_COD,;					// 7- Fornecedor vencedor
						SA2->A2_LOJA,;					// 8- Loja do fornecedor vencedor
						cItemCot,;						// 9- Item do pedido ACC
						aGrava[nX][QUANT],; 			// 10- Quantidade finalizada
						aGrava[nX][PRECO],; 			// 11- Preco finalizado
						SC8->C8_NUMPRO}) 				// 12- Numero da Proposta
				Else
					nPos := aScan(aRecSC8,{|x| x[3]+x[4] == SC8->C8_NUM + SC8->C8_ITEM})
					If nPos > 0
						aRecSC8[nPos,10] := SC8->C8_QUANT
					Endif
				Endif
					
				aAdd ( aDePara , { aGrava[nX][ACCNUM] + ";" + aGrava[nX][ACCITEM] , SC8->C8_NUM +"|" + SC8->C8_ITEM })  
			Else 
				cXmlRet := STR0015 + AllTrim( aRequest[1][3] ) +"/"+  AllTrim( aRequest[1][4] ) // "Solicitação não encontrada na base de dados. Numero: "
				lRet := .F.
	  		EndIf
		Else
			cXmlRet := STR0014 // "Fornecedor não cadastrado na base de dados."
			lRet := .F.
  		EndIf
	Else
		aAdd ( aDePara , { aGrava[nX][ACCNUM] + ";" + aGrava[nX][ACCITEM] , SC8->C8_NUM +"|" + SC8->C8_ITEM })  
		Conout( STR0023 + aGrava[nX][ACCNUM] + "|" + aGrava[nX][ACCITEM] ) // "MATI130 - Cotação já existe na base de dados: " #
	EndIf

Next nX
  
If !Empty(aRecSC8)
	//Ordena por filial e numero de cotacao
	aSort(aRecSC8,,,{|x,y| y[2]+y[3]+y[4] > x[2]+x[3]+x[4]})
	nX := 1                              
	
	SX3->(dbSetOrder(1))
	SX3->(dbSeek("SC8"))
	While !SX3->(Eof()) .And. SX3->X3_ARQUIVO == "SC8"
		If X3Uso(SX3->X3_USADO) .And. SX3->X3_CONTEXT <> "V" .And. aScan(aCabec,{|x| x == AllTrim(SX3->X3_CAMPO)}) == 0
			aAdd(aHeader150,SX3->X3_CAMPO)   
		Endif
		SX3->(dbSkip())                         
	End
	
	dbSelectArea("SC8")
	dbSetOrder(1)
		                                                  
	While nX <= Len(aRecSC8)
		cQuebra := aRecSC8[nX,2]+aRecSC8[nX,3]
		aAdd(aAutoCab,{"C8_NUM" ,aRecSC8[nX,3],NIL}) 
		aAdd(aAutoCab,{"COMPACC",cComprador,NIL}) 
		cFilAnt := aRecSC8[nX,2]
		While nX <= Len(aRecSC8) .And. cQuebra == aRecSC8[nX,2]+aRecSC8[nX,3]
			//-- Caso novo preco, atualiza via MATA150
			SC8->(dbGoTo(aRecSC8[nX,1]))
			If aRecSC8[nX,11] # SC8->C8_PRECO 
				//-- Monta cabecalho para MATA150				
				Mt150Itens(aHeader150,aItens150,SC8->(C8_FILIAL+C8_NUM+aRecSC8[nX,7]+aRecSC8[nX,8]),@aCabec)
				Mt150AtuIt(@aItens150,aRecSC8)
								
				lMSErroAuto	:= .F.
				lAutoErrNoFile := .T.
				MSExecAuto({|x,y,z| MATA150(x,y,z)},aCabec,aItens150,3)
				
				If lMsErroAuto
					aErro := GetAutoGRLog()
					For nY := 1 To Len(aErro)
						cXmlRet += aErro[nY] +CRLF // Gera ResposeMessage com erro do ExecAuto
					Next nY
					nX++
					lRet := .F.
					Loop
				EndIf
			EndIf			
			SC8->(dbGoTo(aRecSC8[nX,1]))
			
			If !Empty(aAutoItm)
				nIndItem := aScan(aAutoItm,{|x| Trim(x[1,1,2]) == aRecSC8[nX,4]})
			EndIf
			
			If nIndItem == 0
				aAdd(aAutoItm,{})
				nIndItem := Len(aAutoItm)
			EndIf
			
			//-- Adiciona novos participantes
			aAdd(aAutoItm[nIndItem],{})					
			aAdd(aTail(aAutoItm[nIndItem]),{"CE_ITEMCOT",aRecSC8[nX,4],NIL})
			aAdd(aTail(aAutoItm[nIndItem]),{"CE_FORNECE",aRecSC8[nX,7],NIL})
			aAdd(aTail(aAutoItm[nIndItem]),{"CE_LOJA"   ,aRecSC8[nX,8],NIL})
			aAdd(aTail(aAutoItm[nIndItem]),{"CE_NUMCOT" ,cNumSC8,NIL})
			aAdd(aTail(aAutoItm[nIndItem]),{"CE_NUMPRO" ,aRecSC8[nX,12],NIL})
			aAdd(aTail(aAutoItm[nIndItem]),{"CE_QUANT"  ,aRecSC8[nX,10],NIL})			
			aAdd(aTail(aAutoItm[nIndItem]),{"ACCNUM",aRecSC8[nX,5],NIL})
			aAdd(aTail(aAutoItm[nIndItem]),{"ACCITEM",aRecSC8[nX,6],NIL})			
			nX++
		End

		If lRet
			dbSeek(xFilial("SC8")+aAutoCab[1,2])
			lMSErroAuto	:=	.F.
			lAutoErrNoFile := .T.
			//MSExecAuto({|x,y,z| MATA160(,x,,y,z)},6,aAutoCab,aAutoItm)
			MATA160(,6,,aAutoCab,aAutoItm)
			If lMsErroAuto	
				aErro := GetAutoGRLog()
				For nY := 1 To Len(aErro)
					cXmlRet += aErro[nY] +CRLF
				Next nY
				lRet := .F.
			Endif
		EndIf
		aAutoCab := {}
		aAutoItm := {}         			
		aAtuSC8  := {}         
		nIndItem := 0
	End
EndIf

Return {lRet,cXMLRet}

Static Function Mt150AtuIt(aItens150,aRecSC8)

Local nX		:= 1
Local nItem		:= 0
Local nPPreco	:= aScan(aItens150[1],{|x| AllTrim(x[1]) == "C8_PRECO"})
Local nPItem 	:= aScan(aItens150[1],{|x| AllTrim(x[1]) == "C8_ITEM"})						
Local nPQuant	:= aScan(aItens150[1],{|x| AllTrim(x[1]) == "C8_QUANT"})						
Local nPTotal	:= aScan(aItens150[1],{|x| AllTrim(x[1]) == "C8_TOTAL"})
Local nPFilen	:= aScan(aItens150[1],{|x| AllTrim(x[1]) == "C8_FILENT"})

For nX := 1 To Len(aRecSC8)
	nItem := aScan(aItens150,{|x| x[nPItem,2] == aRecSC8[nX,4]})				
				
	aItens150[nItem,nPPreco,2] := aRecSC8[nX,11]
	aItens150[nItem,nPTotal,2] := aItens150[nItem,nPQuant,2] * aRecSC8[nX,11]
	aItens150[nItem,nPFilen,2] := SC8->C8_FILENT
Next nX

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} GetNumSC8
Retorna o próximo número disponível para geração da cotação na tabela SC8
@author Eduardo Riera
@since 24/05/2013
/*/
//-------------------------------------------------------------------
Static Function GetNumSC8()
Local aArea	     := GetArea()
Local aAreaSC8   := SC8->( GetArea() )
Local cNumCot    := GetSx8Num("SC8","C8_NUM")
Local nSaveSX8   := GetSX8Len()

DbSelectArea("SC8")
DbSetOrder(1)

While SC8->(MsSeek(xFilial("SC8")+cNumCot))
	While ( GetSX8Len() > nSaveSX8 )		
	EndDo
	cNumCot := GetSx8Num("SC8","C8_NUM")
End

RestArea( aAreaSC8 )
RestArea( aArea )
Return( cNumCot )

//-------------------------------------------------------------------
/*/{Protheus.doc} GetAcolsSC8
Captura o aCols da rotina SC8 com base na chave informada
@author Raphael Augustos
@since 24/05/2013
/*/
//-------------------------------------------------------------------
Static Function Mt150Itens(aHeader,aItens,cChave,aCabec)
Local aArea      := GetArea()
Local aAreaSC8   := SC8->( GetArea() )
Local nX	     := 0
			
aItens := {}
aCabec := {}

dbSelectArea("SC8")
dbSetOrder(1) //C8_FILIAL+C8_NUM+C8_FORNECE+C8_LOJA+C8_ITEM+C8_NUMPRO+C8_ITEMGRD 
dbSeek(cChave)
While !EOF() .And. C8_FILIAL+C8_NUM+C8_FORNECE+C8_LOJA == cChave
	If Empty(C8_NUMPED) 
		aAdd(aItens,{})				
		For nX := 1 To Len(aHeader)
			aAdd(aItens[Len(aItens)],{aHeader[nX],&(aHeader[nX]),Nil})
		Next nX
	EndIf
	dbSkip()
End
dbSkip(-1)

aAdd(aCabec,{"C8_NUM"    ,C8_NUM	 ,Nil})
aAdd(aCabec,{"C8_FORNECE",C8_FORNECE,Nil})
aAdd(aCabec,{"C8_LOJA"	 ,C8_LOJA	,Nil})
aAdd(aCabec,{"C8_COND"	 ,C8_COND   ,Nil})
aAdd(aCabec,{"C8_CONTATO",C8_CONTATO,Nil})
aAdd(aCabec,{"C8_MOEDA"  ,C8_MOEDA  ,Nil})
aAdd(aCabec,{"C8_EMISSAO",C8_EMISSAO,Nil})

RestArea(aAreaSC8)
RestArea(aArea)
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} I130LECOTA
Efetua a leitura do XML oriundo do Market Place e retorna um array com os dados necessários para executação dos 'EXECAUTOS'
@author Raphael Augustos
@since 24/05/2013
/*/
//-------------------------------------------------------------------
Static Function I130LECOTA()
Local aGrava     := {} // Retorna array para executar ExecAuto
Local nX 
Local nY
Local nZ
Local aErro      := {}
Local lRet       := .T.
Local lMktPlace 	:= SuperGetMv("MV_MKPLACE",.F.,.F.)
                        
Private oBMessage // BusinessMessage
Private oBContent // BusinessContent 
Private oQuotItem // ITENS
Private oQuotProp // PROPOSTAS DO ITEM
Private oDelivery // ENTREA DA PROPOSTA 

oBMessage  := oXmlA130:_TOTVSMessage:_BusinessMessage 					// Mapeamento
oBContent  := oBMessage:_BusinessContent  								// Mapeamento

If Type("oBContent:_ListOfQuotationItem:_QuotationItem ") != "A"
	XmlNode2Arr(oBContent:_ListOfQuotationItem:_QuotationItem , "_QuotationItem")
EndIf 	

oQuotItem  := oBContent:_ListOfQuotationItem:_QuotationItem             // Mapeamento

For nX     := 1 To Len(oQuotItem) 
	//SERIALIZE
	If Type('oQuotItem['+AllTrim(Str(nX))+']:_ListOfQuotationProposal:_QuotationProposal') != "A"
		XmlNode2Arr(oQuotItem[nX]:_ListOfQuotationProposal:_QuotationProposal , "_QuotationProposal")
	EndIf 	

	oQuotProp  := oQuotItem[nX]:_ListOfQuotationProposal:_QuotationProposal		// Mapeamento
	
	//PROPOSTAS
	For nY := 1 To Len(oQuotProp) 
		If oQuotProp[nY]:_Winner:Text == "1"
			AAdd( aGrava , {})
					
			// Obtém código externo da cotação - ACCNUM - 1 - C8_ACCNUM 
			If Type("oBContent:_ExternalCode") <> "U" .And. !Empty(oBContent:_ExternalCode:Text) 
				AAdd( aGrava[nX] , oBContent:_ExternalCode:Text ) 
			Else
				lRet := .F.
				AAdd( aErro, STR0001 ) //  "Obrigatório informar a tag ExternalCode na BusinessContent."
			EndIf
			
			// ACCITEM		2 - C8_ACCITEM
			If  Type('oQuotItem['+str(nX)+']:_ExternalItemCode') <> "U" .And. !Empty( oQuotItem[nX]:_ExternalItemCode:Text ) 
				AAdd( aGrava[nX] , oQuotItem[nX]:_ExternalItemCode:Text	) 
			Else
				lRet := .F.
				AAdd( aErro, STR0002 + str(nX) ) //  "Obrigatório informar a tag ExternalItemCode na QuotationItem. Item numero: "
			EndIf                 
			
			// NUMSC		3 -C8_NUMSC|C8_ITEMSC Cod. da Requisição
			If Type("oQuotItem["+str(nX)+"]:_RequestInternalId") <> "U" .And. !Empty( oQuotItem[nX]:_RequestInternalId:Text ) 
				AAdd( aGrava[nX] , oQuotItem[nX]:_RequestInternalId:Text ) 
			Else
				lRet := .F.
				AAdd( aErro, STR0003 + str(nX)) //  "Obrigatório informar a tag RequestInternalId na QuotationItem Item numero: " 
			EndIf			
			
			 // EMISSAO		4 - C8_EMISAO - Data de cadastro da proposta			
			If Type("oQuotProp["+str(nY)+"]:_RegistrationDate") <> "U" .And. !Empty( oQuotProp[nY]:_RegistrationDate:Text ) 
				AAdd( aGrava[nX] , oQuotProp[nY]:_RegistrationDate:Text )
			Else
				lRet := .F.
				AAdd( aErro, STR0004 + str(nX) + " Proposta " + str(nY)) // "Obrigatório informar a tag RegistrationDate na QuotationProposal. Item numero: " 
			EndIf                                                            
			
			// FORNECE		5 - C8_FORNECE - Código do fornecedor no caso da cotação de compra
			If Type("oQuotProp["+str(nY)+"]:_CustomerVendorCode") <> "U" .And. !Empty( oQuotProp[nY]:_CustomerVendorCode:Text ) 
				AAdd( aGrava[nX] , oQuotProp[nY]:_CustomerVendorCode:Text ) 
			Else
				lRet := .F.
				AAdd( aErro, STR0005 + str(nX) + " Proposta " + str(nY)) // "Obrigatório informar a tag CustomerVendorCode na QuotationProposal.Item numero: "
			EndIf                     
			
			// WINNER		6 -  1 Vencedor - 0 Perdedor		
			If !Empty( oQuotProp[nY]:_Winner:Text ) //oQuotProp[nY]:_Winner:Text
				AAdd( aGrava[nX] , oQuotProp[nY]:_Winner:Text ) 
			Else
				lRet := .F.
				AAdd( aErro, STR0006 + str(nX) + " Proposta " + str(nY))  //  "Obrigatório informar a tag Winner na QuotationItem. Item numero: "
			EndIf
			
			// COND		7 - C8_COND - Codigo da condicao de pagamento da proposta na cotacao feita pelo fornecedor
			If Type("oQuotProp["+str(nY)+"]:_PaymentTermCode") <> "U" .And. !Empty( oQuotProp[nY]:_PaymentTermCode:Text ) 
				AAdd( aGrava[nX]  , oQuotProp[nY]:_PaymentTermCode:Text	) 
			Else
				lRet := .F.
				AAdd( aErro, STR0007 + str(nX) + " Proposta " + str(nY)) //  "Obrigatório informar a tag PaymentTermCode na QuotationProposal. Item numero: "
			EndIf                                                                         
			
			//TPFRETE		8 - C8_TPFRETE - 1 -CIF | 2 - FOB | 3 - POR CONTA TERCEIROS | 4 - SFT-Sem Frete
			If Type("oQuotProp["+str(nY)+"]:_FreightType") <> "U" .And. !Empty( oQuotProp[nY]:_FreightType:Text ) 
				AAdd( aGrava[nX] , oQuotProp[nY]:_FreightType:Text ) 
			Else
				lRet := .F.
				AAdd( aErro, STR0008 + str(nX) + " Proposta " + str(nY)) // "Obrigatório informar a tag PaymentTermCode na QuotationProposal. Item numero: "
			EndIf                                     
			
			//OBS			9 - C8_OBS - Observação do item da cotação
			If Type("oQuotProp["+str(nY)+"]:_Observation") <> "U" .And. !Empty( oQuotProp[nY]:_Observation:Text ) 
				AAdd( aGrava[nX] , oQuotProp[nY]:_Observation:Text ) 
			Else
				AAdd( aGrava[nX] 			, ""			) 		
				//cXmlRet := "Informar a tag informar a tag Observation na QuotationProposal. Item numero: " + str(nX) + " Proposta " + str(nY)
			EndIf
			        
			//PRECO 	   10 - C8_PRECO - Preço unitário
			If Type("oQuotProp["+str(nY)+"]:_UnitPrice") <> "U" .And. !Empty( oQuotProp[nY]:_UnitPrice:Text ) 
				AAdd( aGrava[nX] , Val(oQuotProp[nY]:_UnitPrice:Text) ) // 
			Else
				lRet := .F.
				AAdd( aErro, STR0009 + str(nX) + " Proposta " + str(nY)) //  "Obrigatório informar a tag UnitPrice na QuotationProposal. Item numero: "
			EndIf                                                         
			
			//VALFRE	   11 - C8_VALFRE - Valor do Frete
			If Type("oQuotProp["+str(nY)+"]:_FreightValue") <> "U" .And. !Empty( oQuotProp[nY]:_FreightValue:Text )
				AAdd( aGrava[nX] , Val(oQuotProp[nY]:_FreightValue:Text) )
			Else
				lRet := .F.
				AAdd( aErro, STR0010 + str(nX) + " Proposta " + str(nY)) // "Obrigatório informar a tag FreightValue na QuotationProposal. Item numero: "
			EndIf                                                                                                        	
			//MOEDA	   12 - C8_MOEDA - Código da moeda
			If Type("oBContent:_CurrencyCode:Text") <> "U" .And. !Empty( oBContent:_CurrencyCode:Text ) 
				AAdd( aGrava[nX] , oBContent:_CurrencyCode:Text )
			Else
				lRet := .F.
				AAdd( aErro, STR0011 ) //  "Obrigatório informar a tag CurrencyCode na BusinessContent."
			EndIf
			//ENDDATE    13 - C8_VALIDA
			If Type("oBContent:_ValidityEndDate:Text ") <> "U" .And. !Empty( oBContent:_ValidityEndDate:Text ) 
				AAdd( aGrava[nX] , oBContent:_ValidityEndDate:Text )
			Else
				lRet := .F.
				AAdd( aErro, STR0012 ) //  "Obrigatório informar a tag ValidityEndDate na BusinessContent."
			EndIf
			
			//SERIALIZE
			If Type("oQuotProp["+str(nY)+"]:_ListOfDeliveries:_Deliveries") != "A"
				XmlNode2Arr( oQuotProp[nY]:_ListOfDeliveries:_Deliveries , "_Deliveries")
			EndIf 	
			
			oDelivery  := oQuotProp[nY]:_ListOfDeliveries:_Deliveries		// Mapeamento	
			
			//DELIVERYS - Não trataremos mais de um entrega
			For nZ := 1 To  1 //Len(oDelivery) 
	            //PRAZO	   14 - C8_PRAZO - Numeração da entrega dentro da Requisição no ERP
				If Type("oDelivery["+str(nZ)+"]:_DeliveryDate") <> "U" .And. !Empty( oDelivery[nZ]:_DeliveryDate:Text ) 
					AAdd( aGrava[nX] , AI130CalPr(oQuotProp[nY]:_RegistrationDate:Text,oDelivery[nZ]:_DeliveryDate:Text))
				Else
					AAdd( aGrava[nX] 			, ""			) 				
				EndIf		
			   //QUANT	   15 - C8_QUANT
				If Type("oDelivery["+str(nZ)+"]:_Quantity") <> "U" .And. !Empty( oDelivery[nZ]:_Quantity:Text ) 
					AAdd( aGrava[nX] , Val(oDelivery[nZ]:_Quantity:Text) )	// C8_QUANT - Quantidade para entrega na data em questÃ£o proposta pelo Fornecedor
				Else
					lRet := .F.
					AAdd( aErro, STR0013 ) //  "Obrigatório informar a tag Quantity na DeliveryItem."
				EndIf
			Next nZ	
			
			If lMktPlace
				//Obtem o código do comprador - ACCUSER - 16
				If Type("oBContent:_UserInternalId") <> "U" .And. !Empty(oBContent:_UserInternalId:Text) 
					AAdd( aGrava[nX] , oBContent:_UserInternalId:Text ) 
				Else
					AAdd( aGrava[nX] , "" ) 
				EndIf
			Endif
			
			lRet :=	I130VldGrv(aGrava[nX][NUMSC],aGrava[nX][FORNECE],aGrava[nX][COND],aGrava[nX][MOEDA],@aErro , nY )
			
		EndIf        

		If !lRet	
			Exit
		EndIf
				 
	Next nY 		 	
	
		If !lRet	
			Exit
		EndIf	
		
Next nX

Return {lRet,aGrava,aErro}


//-------------------------------------------------------------------
/*/{Protheus.doc} I130RetSc
Retorna todas as solicitações amarradas no item da cotação do MarketPlace
@author Raphael Augustos
@since 10/05/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function I130RetSc(cString)  
Local nX         := 0
Local aRet       := {} 
Local aRequest   := {}
Default cString    := ""

If At(";", cString ) == 0
	//Possui apenas uma requisição para o item da cotação	
	AAdd ( aRet , Separa( cString, "|" ) )
Else  
	//Possui vários SC para única cotação
	aRequest := Separa(cString ,";")	
	For nX := 1 To Len (aRequest)
		AAdd ( aRet , Separa( aRequest[nX], "|" ) )
	Next
EndIf

Return aRet     


//-------------------------------------------------------------------
/*/{Protheus.doc} I130GrvSC
Grava o número da cotação na solicição de compra. Utilizando o array aRequest como referência
@author Raphael Augustos
@since 10/05/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function I130GrvSC( aRequest , cNumSC8 , cItem)
Local nX   
Local cSCNum     := ""
Local cSCIt      := ""

DEFAULT cNumSC8    := ""
DEFAULT cItem      := ""

For nX := 1 To Len(aRequest)
	cSCNum    := PadR(aRequest[nX][3], TamSX3('C1_NUM')[1])
	cSCIt     := PadR(aRequest[nX][4], TamSX3('C1_ITEM')[1])
	SC1->( DbSetOrder (1) )		
	If SC1->( DbSeek( xFilial("SC1") + cSCNum + cSCIt ))
		RecLock("SC1", .F.)
		SC1->C1_COTACAO := cNumSC8
		SC1->C1_IDENT   := cItem
		SC1->C1_ACCPROC := "2"
		SC1->C1_QUJE	:= SC1->C1_QUANT		
		MsUnlock()
	EndIf
Next nX

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} I130VldGrv
Valida o conteúdo dos campos obrigatórios enviados pela marca antes de efetuar a gravação.
@author Raphael Augustos
@since 10/05/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function I130VldGrv( cNumSc , cFornece , cCond , cMoeda , aRet , nItem)
Local lRet       := .T.
Local cEmp       := ""
Local cFil       := ""
Local aRequest   := {}
Local nX
DEFAULT aRet       := ""
DEFAULT nItem      := ""

aRequest   := I130RetSc(cNumSc)
For nX := 1 To Len (aRequest)
	If Len(aRequest[nX]) # 4
		lRet       := .F.
		aadd( aRet , STR0018 + AllTrim( Str(nItem) ) ) // " O conteúdo da tag  RequestInternalId está fora do padrão da mensagem única. Proposta: "
	EndIf
Next nX	

If Len( Separa( cFornece , "|") ) < 3
	lRet := .F.
	aadd( aRet , STR0019 + AllTrim(cFornece) + STR0020 + AllTrim( Str(nItem) )  ) // "O conteúdo da tag CustomerVendorCode está fora do layout da mensagem única: " # ". Proposta: " #
EndIf

If Len( Separa( cCond , "|") ) < 3
	lRet := .F.
	aadd( aRet , STR0021 + AllTrim(cCond) + STR0020 + AllTrim( Str(nItem) ) ) // "O conteúdo da tag PaymentTermCode está fora do layout da mensagem única: " # ". Proposta: " #
EndIf

If Len( Separa( cMoeda , "|") ) < 3
	lRet := .F.   	
	aaDD( aRet , STR0022 + AllTrim(cMoeda) + STR0020 + AllTrim(Str(nItem))  ) // "O conteúdo da tag CurrencyCode está fora do layout da mensagem única: " # ". Proposta: " #
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} I130ComSC

@author Raphael Augustos
@since 10/05/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function I130ComSC( aRequest )
Local nX
Local cSCEmp     := ""
Local cSCFil     := ""
Local cSCNum     := ""
Local cSCIt      := ""  
Local aDados     := {}

DEFAULT aSCComCe   := {}
DEFAULT aRequest   := {} 

For nX := 1 To Len(aRequest)
	cSCEmp    := PadR(aRequest[nX][1], Len(cEmpAnt) )
	cSCFil    := PadR(aRequest[nX][2], Len(cFilAnt) )
	cSCNum    := PadR(aRequest[nX][3], TamSX3('C1_NUM')[1])
	cSCIt     := PadR(aRequest[nX][4], TamSX3('C1_ITEM')[1])
	If cSCEmp == cEmpAnt .And. cSCFil # xFilial("SC1")
		SC1->( DbSetOrder(1) )		
		If SC1->( DbSeek( cSCFil + cSCNum + cSCIt ))
		    aAdd( aDados , { .T. , SC1->C1_FILIAL , SC1->C1_NUM , SC1->C1_SOLICIT , DToS(SC1->C1_EMISSAO) , SC1->C1_ITEM , SC1->C1_PRODUTO , SC1->C1_QUANT , DToS(SC1->C1_DATPRF) } )

			MAPComCent( cFilAnt , aDados, @aSCComCe )

			If ValType(aSCComCe) == "A" .And. Len(aSCComCe) > 0
				//Atualiza o aRequest com as solicitações geradas pelo Compra Cetralizada
				aRequest[nX][1] := cEmpAnt 
				aRequest[nX][2] := cFilAnt
				aRequest[nX][3] := aSCComCe[1][1]
				aRequest[nX][4] := aSCComCe[1][2]
			EndIf		
		EndIf
	EndIf
Next nX

Return

//---------------------------------------------------------------------------------------------
/*/{Protheus.doc} AI130CalPr
Calcula o prazo de entrega conforme as datas de emissao e entrega contidas no arquivo XML.
@author Raphael Augustos
@since 25/07/2013
@version 1.0
/*/
//---------------------------------------------------------------------------------------------
Static Function AI130CalPr(cDataEmis,cDataEntr)
Local nPrazoEnt := 0
Local nPos := 0
Local nMes := 0
Local cDia := 0

cDataEmis := CToD(AI130DataF(cDataEmis))
cDataEntr := CToD(AI130DataF(cDataEntr))

If !Empty(cDataEmis) .And. !Empty(cDataEntr)
	nPrazoEnt := cDataEntr - cDataEmis
EndIf

Return nPrazoEnt


//---------------------------------------------------------------------------------------------
/*/{Protheus.doc} AI130DataF
Altera formato da data para ser utilizada na função CToD
@author Raphael Augustos
@since 25/07/2013
@version 1.0
/*/
//---------------------------------------------------------------------------------------------
Static Function AI130DataF(cData)
Local cP := 0
Local cS := 0
Local cDia := ""
Local cMes := ""
Local cAno := ""

cP := at("/",cData)
cS := at("/",cData,cp+1)

cMes := SubStr(cData,1,cP-1) 
cDia := SubStr(cData,cP+1,cS-cP-1)
cAno := SubStr(cData,cS+1,Len(cData))

Return cDia+"/"+cMes+"/"+cAno