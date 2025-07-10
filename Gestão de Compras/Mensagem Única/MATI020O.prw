#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWADAPTEREAI.CH"
#INCLUDE "MATI020.CH"
#INCLUDE "PMSXSOLUM.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MATI020O   ºAutor  ³Totvs Cascavel     º Data ³  31/05/2018 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Funcao de integracao com o adapter EAI para recebimento e  º±±
±±º          ³ envio de informações do cadastro de Fornecedores (SA2)     º±±
±±º          ³ utilizando o conceito de mensagem unica JSON.        	  º±±
±±º          ³ JSON                                                       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MATI020O                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function MATI020O( oEAIObEt, nTypeTrans, cTypeMessage )

	Local lRet     		:= .T.
	Local aRet     		:= {}
	Local cCodVer 		:= "" //Codigo completo da versao
	Local lMvcM020		:= TableInDic( "G3Q", .F. )

	Local nCount       	:= 0
	Local nX           	:= 0
	Local cValGov      	:= 0
	Local cMarca       	:= ""
	Local cValInt      	:= ""
	Local cValExt      	:= ""
	Local cAlias       	:= "SA2"
	Local cField       	:= "A2_COD"
	Local cCode       	:= ""
	Local cLoja        	:= ""
	Local cBcoExt      	:= ""
	Local cCdBco       	:= ""
	Local cAgBco       	:= ""
	Local cDgAgBco     	:= ""
	Local cCCBco       	:= ""
	Local cDgCCBco    	:= ""
	Local lRet        	:= .T.
	Local lA2Pais		:= .F.
	Local aRet        	:= {}
	Local aVendor     	:= {}
	Local aAux         	:= {}
	Local aAreaSA6    	:= {}
	Local lMktPlace  	:= SuperGetMv("MV_MKPLACE",.F.,.F.)

	//Trans_Send
	Local cBcoName     	:= ""
	Local cLograd     	:= ""
	Local cNumero      	:= ""
	Local cCodEst     	:= ""
	Local cCodMun      	:= ""
	Local cEvent      	:= ""
	Local cCNPJCPF    	:= ""
	Local cEst        	:= ""

	Local cFILFil		:= FWxFilial("FIL")
	Local aFILArea		:= {}
	Local nAccounts		:= 0
	Local cBanco 		:= ""
	Local cAgencia 		:= ""
	Local cConta 		:= ""
	Local cDvAGencia   	:= ""
	Local cDvConta		:= ""
	Local cTpConta		:= ""
	Local cMoeda		:= ""
	Local cPrincipal	:= ""
	Local cEndereco		:= ""
	Local cTel			:= ""
	Local aContasFIL 	:= {}
	Local lHotel	   	:= SuperGetMV( "MV_INTHTL", , .F. )
	Local cNatFor		:= ""
	Local lIniPadCod   	:= .F.
	Local cPais 		:= ""
	Local cEst			:= ""
	Local aRetPe		:= {}
	Local lFornecPJ		:= .T.
	Local nCont			:= 1
	Local cOwnerMsg		:= "CUSTOMERVENDOR"
	Local cLogErro		:= ""
	Local cTypeReg		:= ""
	
	//Instancia objeto JSON
	Local ofwEAIObj		:= FWEAIobj():NEW()
	
	Local cPISSRA		:= ""

	Default nTypeTrans		:= 0
	Default cTypeMessage	:= ""

	Private lMsErroAuto    := .F.
	Private lAutoErrNoFile := .T.
	Private lMsHelpAuto    := .T.
	
	//--------------------------------------
	//recebimento mensagem
	//--------------------------------------
	If nTypeTrans == TRANS_RECEIVE
	
		//--------------------------------------
		//chegada de mensagem de negocios
		//--------------------------------------
		If cTypeMessage == EAI_MESSAGE_BUSINESS
			
			//Ajustado para receber o Type conforme documentacao API Totvs
			//Tipo do Registro: Customer Cliente, Vendor Fornecedor, Both Ambos
			//Identifica se o emitente é apenas Cliente, apenas Fornecedor ou Ambos 
			//1 – Cliente  
			//2 – Fornecedor 
			//3 – Ambos 
			Do Case
				Case oEAIObEt:getPropValue("Type") == 1 //Cliente
					cTypeReg := "CUSTOMER"
				Case oEAIObEt:getPropValue("Type") == 2 //Fornecedor
					cTypeReg := "VENDOR"
				Case oEAIObEt:getPropValue("Type") == 3 //Ambos
					cTypeReg := "BOTH"
			Endcase
			
			If cTypeReg == "VENDOR" .Or. cTypeReg == "BOTH"   
				If cTypeReg == "BOTH"  
					
					aAdd(aRet, FWIntegDef("MATA030", cTypeMessage, nTypeTrans, oEAIObEt))
					
					If ValType(aRet) == "A"
						If !Empty(aRet)
							lRet := aRet[1][1]
							cLogErro := aRet[1][2]
						EndIf
					Endif
				EndIf

				// Obtém a marca
				If oEAIObEt:getHeaderValue("ProductName") !=  nil .And. !Empty( oEAIObEt:getHeaderValue("ProductName") ) 
					cMarca :=  oEAIObEt:getHeaderValue("ProductName")
				Else
					lRet := .F.
					cLogErro := ""	
					ofwEAIObj:Activate()
					ofwEAIObj:setProp("ReturnContent")
					cLogErro := STR0010 // "Product é obrigatório!"
					ofwEAIObj:getPropValue("ReturnContent"):setProp("Error", cLogErro)			
													
				EndIf

				// Verifica se a filial atual é a mesma filial de inclusão do cadastro
				aAux := IntChcEmp(oEAIObEt, cAlias, cMarca) 
				If !aAux[1]
					lRet := aAux[1]
					cLogErro := ""	
				  	ofwEAIObj:Activate()
				 	ofwEAIObj:setProp("ReturnContent")
				   	cLogErro := aAux[2] 
					ofwEAIObj:getPropValue("ReturnContent"):setProp("Error", cLogErro)			
						
				EndIf

				// Obtém o Valor externo
				If oEAIObEt:getPropValue("InternalId") != nil .And. !Empty( oEAIObEt:getPropValue("InternalId") )
					cValExt := oEAIObEt:getPropValue("InternalId")
				Else
					lRet := .F.
					cLogErro := ""	
					ofwEAIObj:Activate()
					ofwEAIObj:setProp("ReturnContent")
					cLogErro := STR0011 // "InternalId é obrigatório!"
					ofwEAIObj:getPropValue("ReturnContent"):setProp("Error", cLogErro)			
													
				EndIf

				// Obtém o code
				If oEAIObEt:getPropValue("Code") != nil .And. !Empty( oEAIObEt:getPropValue("Code") )
					cCode := oEAIObEt:getPropValue("Code")
				Else
	            	//Se for integração com hotelaria, irá gerar um código sequencial ou considerar o inicializador padrão do campo código
	        		If !lHotel
	     				lRet := .F.
						cLogErro := ""	
						ofwEAIObj:Activate()
						ofwEAIObj:setProp("ReturnContent")
						cLogErro := STR0012 // "Code é obrigatório!"
						ofwEAIObj:getPropValue("ReturnContent"):setProp("Error", cLogErro)			
														
	        		Endif
				EndIf

				// Obtém a loja
				If oEAIObEt:getPropValue("StoreId") != nil  
					cLoja := oEAIObEt:getPropValue("StoreId")
				EndIf
				
				//Obtém o valor interno
				aAux := IntForInt(cValExt, cMarca)
				
	            cEvent := AllTrim(oEAIObEt:getEvent())

				// Se o evento é Upsert
				If ( Upper(cEvent) == "UPSERT" ) .Or. ( Upper(cEvent) == "REQUEST" ) 
					// Se o registro existe
					If Len( aAux ) > 0
						If aAux[1] .And. ITFINDREG(aAux[2,3],aAux[2,4])
							nOpcx := 4 // Update
						Endif
					Else
						nOpcx := 3 // Insert
					EndIf
				// Se o evento é Delete
				ElseIf ( Upper(cEvent) == "DELETE" )  
					// Se o registro existe
					If Len( aAux ) > 0
						If aAux[1] .And. ITFINDREG(aAux[2,3],aAux[2,4])
							nOpcx := 5 // Delete
						Endif
					Else
						lRet := .F.
						cLogErro := ""	
						ofwEAIObj:Activate()
						ofwEAIObj:setProp("ReturnContent")
						cLogErro := STR0013 // "O registro a ser excluído não existe na base Protheus!"
						ofwEAIObj:getPropValue("ReturnContent"):setProp("Error", cLogErro)			
														
					EndIf
				Else
					lRet := .F.
					cLogErro := ""	
					ofwEAIObj:Activate()
					ofwEAIObj:setProp("ReturnContent")
					cLogErro := STR0014 // "O evento informado é inválido!"
					ofwEAIObj:getPropValue("ReturnContent"):setProp("Error", cLogErro)			
														
				EndIf

				// Se é Insert
				If nOpcx == 3
					// Se não há inicializador padrão
					lIniPadCod := ! Empty(Posicione('SX3', 2, Padr('A2_COD', 10), 'X3_RELACAO'))
					If ! lIniPadCod
						//Se for integração com hotelaria, gera um código sequencial (pode ser alterada a lógica através de incializador padrão)
						If lHotel
							cCode := ProxNum()
						Endif
                  
						aAdd(aVendor, {"A2_COD", cCode, Nil}) // Código
					EndIf
               
					If Empty(Posicione('SX3', 2, Padr('A2_LOJA', 10), 'X3_RELACAO'))
						//Se for integração com hotelaria, fixa a loja como "00" (pode ser alterada a lógica através de incializador padrão) 
						If lHotel
							cLoja := "00"
						Endif
            	    
						aAdd(aVendor, {"A2_LOJA", cLoja, Nil}) // Loja
					EndIf
				Else
					cValInt := IntForExt(, , aAux[2][3], aAux[2][4])[2]

					cCode := PadR( aAux[2][3], TamSX3("A2_COD")[1] )
					cLoja := PadR( aAux[2][4], TamSX3("A2_LOJA")[1] )

					aAdd(aVendor, {"A2_COD",  cCode, Nil}) // Código
					aAdd(aVendor, {"A2_LOJA", cLoja, Nil}) // Loja
				EndIf

				// Se não for DELETE
				If nOpcx != 5
					// Obtém o Nome ou Razão Social
					If oEAIObEt:getPropValue("Name") != nil  
						aAdd(aVendor, {"A2_NOME", AllTrim(oEAIObEt:getPropValue("Name")), Nil})
					EndIf

					// Obtém o Nome de Fantasia
					If oEAIObEt:getPropValue("ShortName") != nil  
						aAdd(aVendor, {"A2_NREDUZ", AllTrim(oEAIObEt:getPropValue("ShortName")), Nil})
					EndIf

					// Obtém o Tipo do Fornecedor
					If oEAIObEt:getPropValue("EntityType") != nil  
						
						//Ajustado para receber o campo EntityType conforme documentacao API Totvs
						//Identifica se o emitente é Pessoa Física, Jurídica, Estrangeiro ou Trading 
						//1 – Pessoa Física 
						//2 – Pessoa Jurídica 
						//3 – Estrangeiro 
						//4 – Trading						
						
						If oEAIObEt:getPropValue("EntityType") == 1 //"PERSON" 
							aAdd(aVendor, {"A2_TIPO", "F", Nil})
							lFornecPJ := .F.
						ElseIf oEAIObEt:getPropValue("EntityType") == 2 //"COMPANY"  
							aAdd(aVendor, {"A2_TIPO", "J", Nil})
						EndIf
					Else
						aAdd(aVendor, {"A2_TIPO", "X", Nil})
					EndIf

					// Obtém o Endereço do Fornecedor
					If oEAIObEt:getpropvalue("Address") != nil  
						cEndereco := UPPER(AllTrim(oEAIObEt:getPropValue("Address"):getPropValue("Address")))

						If oEAIObEt:getPropValue("Address"):getPropValue("Number") != nil   
							If !Empty(AllTrim(oEAIObEt:getPropValue("Address"):getPropValue("Number")))
								cEndereco += ", " + AllTrim(oEAIObEt:getPropValue("Address"):getPropValue("Number"))
								Aadd( aVendor, { "A2_NR_END", oEAIObEt:getPropValue("Address"):getPropValue("Number"), Nil }) 
							Endif
						Endif

						cEndereco := AllTrim(Upper(cEndereco))

						Aadd( aVendor, { "A2_END",cEndereco, Nil })
					EndIf

					// Obtém o Complemento do Endereço
					If oEAIObEt:getPropValue("Address"):getPropValue("Complement") != nil 
						aAdd(aVendor, {"A2_COMPLEM", oEAIObEt:getPropValue("Address"):getPropValue("Complement"), Nil})
					EndIf

					// Obtém o Bairro do Fornecedor
					If oEAIObEt:getPropValue("Address"):getPropValue("District") != nil 
						aAdd(aVendor, {"A2_BAIRRO", oEAIObEt:getPropValue("Address"):getPropValue("District"), Nil})
					EndIf

					// Obtém a descrição do Município do Fornecedor
					If oEAIObEt:getPropValue("Address"):getPropValue("City"):getPropValue("CityDescription") != nil 
						aAdd(aVendor, {"A2_MUN", oEAIObEt:getPropValue("Address"):getPropValue("City"):getPropValue("CityDescription"), Nil})
					EndIf

					// Obtém o Cod Endereçamento Postal
					If oEAIObEt:getPropValue("Address"):getPropValue("ZIPCode") != NIL 
						aAdd(aVendor, {"A2_CEP", oEAIObEt:getPropValue("Address"):getPropValue("ZIPCode"), Nil})
					EndIf
					
					//Tabela Pais
					DbSelectArea("SYA")

					//Obtém o Pais do Fornecedor pelo código
					If oEAIObEt:getPropValue("Address"):getPropValue("Country") != NIL .AND. oEAIObEt:getPropValue("Address"):getPropValue("Country"):getPropValue("CountryCode") != NIL				 
						cPais := AllTrim(oEAIObEt:getPropValue("Address"):getPropValue("Country"):getPropValue("CountryCode"))
						cPais := PadR( cPais, TamSX3("A2_PAIS")[1] )
						
						SYA->(DbSetOrder(1))
						If SYA->(DbSeek(xFilial("SYA") + cPais))
							lA2Pais := .T.
						Endif
						
						If lA2Pais
							Aadd( aVendor, { "A2_PAIS", cPais, Nil })
						Else
							If oEAIObEt:getPropValue("Address"):getPropValue("Country") != Nil .AND. oEAIObEt:getPropValue("Address"):getPropValue("Country"):getPropValue("CountryDescription") != Nil 
								cPais := AllTrim(DecodeUTF8(Upper(oEAIObEt:getPropValue("Address"):getPropValue("Country"):getPropValue("CountryDescription")))) 	
								
								cCodPais := PadR(Posicione("SYA",2,xFilial("SYA") + PadR(cPais,TamSx3("YA_DESCR")[1]),"YA_CODGI"),TamSx3("A2_PAIS")[1])
									
								If !Empty(cCodPais)
									If cCodPais <> A2030PALOC("SA2",1)
										cEst := "EX"
									Endif
									Aadd( aVendor, { "A2_PAIS",cCodPais, Nil })
								Else
									If cPais <> A2030PALOC("SA2",2)
										cEst := "EX"
									Endif
								Endif
								SYA->(DbSetOrder(1))
							Endif
						Endif
					Else
						//Obtém o Pais do Fornecedor pela descrição						
						If oEAIObEt:getPropValue("Address"):getPropValue("Country") != Nil .AND. oEAIObEt:getPropValue("Address"):getPropValue("Country"):getPropValue("CountryDescription") != Nil 
							cPais := AllTrim(DecodeUTF8(Upper(oEAIObEt:getPropValue("Address"):getPropValue("Country"):getPropValue("CountryDescription"))))
						 	
							cCodPais := PadR(Posicione("SYA",2,xFilial("SYA") + PadR(cPais,TamSx3("YA_DESCR")[1]),"YA_CODGI"),TamSx3("A2_PAIS")[1])
								
							If !Empty(cCodPais)
								If cCodPais <> A2030PALOC("SA2",1)
									cEst := "EX"
								Endif
									
								Aadd( aVendor, { "A2_PAIS",cCodPais, Nil })
							Else
								If cPais <> A2030PALOC("SA2",2)
									cEst := "EX"
								Endif
							Endif
							
							SYA->(DbSetOrder(1))
						Endif
					Endif
				
					// Obtém a Sigla da Federação
					If oEAIObEt:getPropValue("Address"):getPropValue("State"):getPropValue("StateCode") != Nil  
						If Empty(cEst)
							cEst := AllTrim(Upper(oEAIObEt:getPropValue("Address"):getPropValue("State"):getPropValue("StateCode")))
						Endif
						aAdd(aVendor, {"A2_EST", cEst, Nil})
					EndIf

					// Obtém o Código do Município
					If cEst <> "EX" .And. oEAIObEt:getPropValue("Address"):getPropValue("City"):getPropValue("CityCode") != Nil  
						aAdd(aVendor, {"A2_COD_MUN", Right(oEAIObEt:getPropValue("Address"):getPropValue("City"):getPropValue("CityCode"), 5), Nil})
					EndIf

					// Obtém Inscrição Estadual/Inscrição Municipal/CNPJ/CPF do Fornecedor
					If oEAIObEt:getPropValue("GovernmentalInformation") != nil
						oTaxes := oEAIObEt:getPropValue("GovernmentalInformation")
						For nX := 1 To Len( oTaxes )
							If oTaxes[nX]:getPropValue("Name") != nil
								cValGov := oTaxes[nX]:getPropValue("Id")
								
								If RTrim(Upper(oTaxes[nX]:getPropValue("Name"))) == "INSCRICAO ESTADUAL"
									aAdd(aVendor, {"A2_INSCR", cValGov,  Nil})
								ElseIf RTrim(Upper(oTaxes[nX]:getPropValue("Name"))) == "INSCRICAO MUNICIPAL"
									aAdd(aVendor, {"A2_INSCRM", cValGov,  Nil})
								ElseIf RTrim(Upper(oTaxes[nX]:getPropValue("Name"))) $ "CPF/CNPJ"
									aAdd(aVendor, {"A2_CGC", cValGov,  Nil})
								ElseIf RTrim(Upper(oTaxes[nX]:getPropValue("Name"))) $ 'INSCRICAO PIS'
									cPISSRA := cValGov //Indica que funcionario e autonomo
								EndIf
							Endif
						Next nX
					EndIf
					

					// Obtém a Caixa Postal
					If oEAIObEt:getPropValue("Address"):getPropValue("POBox") != Nil 
						aAdd(aVendor, {"A2_CX_POST", oEAIObEt:getPropValue("Address"):getPropValue("POBox"), Nil})
					EndIf

					// Obtém o E-Mail
					If oEAIObEt:getPropValue("ListOfCommunicationInformation") != Nil 
						oLtOfCom := oEAIObEt:getPropValue("ListOfCommunicationInformation")
						aAdd(aVendor, {"A2_EMAIL", oLtOfCom[Len(oLtOfCom)]:getpropvalue('Email'), Nil})
					EndIf

					// Obtém o Número do Telefone
					If oEAIObEt:getPropValue("ListOfCommunicationInformation") != Nil  
						oLtOfCom := oEAIObEt:getPropValue("ListOfCommunicationInformation")
						
						cStringTemp:=RemCharEsp(oLtOfCom[Len(oLtOfCom)]:getpropvalue('PhoneNumber'))
						aTelefone := RemDddTel(cStringTemp)
						aAdd(aVendor, {"A2_TEL",aTelefone[1], Nil})
						
						If !Empty(aTelefone[2])
							If Len(AllTrim(aTelefone[2])) == 2
								aTelefone[2] := "0" + aTelefone[2]
							Endif
							aAdd(aVendor, {"A2_DDD",aTelefone[2], Nil})
						EndIf
						If !Empty(aTelefone[3])
							aAdd(aVendor, {"A2_DDI",aTelefone[3], Nil})
						EndIf
						
					EndIf

					// Obtém o Número do Fax do Fornec.
					If oEAIObEt:getPropValue("ListOfCommunicationInformation") != Nil  
						oLtOfCom := oEAIObEt:getPropValue("ListOfCommunicationInformation")
						
						cStringTemp:=RemCharEsp(oLtOfCom[Len(oLtOfCom)]:getpropvalue('FaxNumber'))
						aTelefone := RemDddTel(cStringTemp)
						aAdd(aVendor, {"A2_FAX", aTelefone[1], Nil})
					EndIf

					// Obtém a Home-Page
					If oEAIObEt:getPropValue("ListOfCommunicationInformation") != Nil   
						oLtOfCom := oEAIObEt:getPropValue("ListOfCommunicationInformation")
						aAdd(aVendor, {"A2_HPAGE", oLtOfCom[Len(oLtOfCom)]:getpropvalue('HomePage'),   Nil})
					EndIf

					// Obtém o Contato na Empresa
					If oEAIObEt:getPropValue("ListOfContacts") != nil  
						oLtOfCont := oEAIObEt:getPropValue("ListOfContacts")
						aAdd(aVendor, {"A2_CONTATO", oLtOfCont[Len(oLtOfCont)]:getpropvalue('ContactInformationName'), Nil})
					EndIf

					// Obtém Bloqueia o Fornecedor?
					If oEAIObEt:getPropValue("RegisterSituation") != Nil   
						If Upper(oEAIObEt:getPropValue("RegisterSituation")) == 'ACTIVE' .And. !lMktPlace 
							aAdd(aVendor, {"A2_MSBLQL", "2",  Nil})
						Else
							aAdd(aVendor, {"A2_MSBLQL", "1",  Nil})
						EndIf
					Else
						aAdd(aVendor, {"A2_MSBLQL", "1",  Nil})
					EndIf

					// Banco/Cod Agência/Cta Corrente
					If oEAIObEt:getPropValue("ListOfBankingInformation") != Nil 
						oLtOfBank := oEAIObEt:getPropValue("ListOfBankingInformation")
						
						//Verifica se foi informado somente um unico banco
						If Len( oLtOfBank ) == 1   
							cBcoExt := oLtOfBank[Len(oLtOfBank)]:getpropvalue('BankInternalId') 
							aAux := M70GetInt(cBcoExt, cMarca)
		
							If aAux[1]
								cCdBco := PadR(aAux[2][3], TamSX3("A2_BANCO")[1])
								cAgBco := PadR(aAux[2][4], TamSX3("A2_AGENCIA")[1])
								cCCBco := PadR(aAux[2][5], TamSX3("A2_NUMCON")[1])
		
								dbSelectArea("SA6")
								aAreaSA6 := SA6->(GetArea())
								dbSetOrder(1)
		
								aAdd(aVendor, {"A2_BANCO",   cCdBco, Nil})
								aAdd(aVendor, {"A2_AGENCIA", cAgBco, Nil})
								
								cDgAgBco := Posicione("SA6", 1, PadR(aAux[2][2], TamSX3("A6_FILIAL")[1]) + cCdBco + cAgBco + cCCBco, "A6_DVAGE")								
								aAdd(aVendor, {"A2_DVAGE",   cDgAgBco, Nil})
								aAdd(aVendor, {"A2_NUMCON",  cCCBco,   Nil})
								
								cDgCCBco := Posicione("SA6", 1, PadR(aAux[2][2], TamSX3("A6_FILIAL")[1]) + cCdBco + cAgBco + cCCBco, "A6_DVCTA")
								aAdd(aVendor, {"A2_DVCTA", cDgCCBco, Nil})
		
								RestArea(aAreaSA6)
							Else
								lRet 	 := .F.
								cLogErro := ""	
								ofwEAIObj:Activate()
								ofwEAIObj:setProp("ReturnContent")
								cLogErro := STR0015 + " -> " + cBcoExt // "O banco informado não foi encontrado no cadastro do Protheus"
								ofwEAIObj:getPropValue("ReturnContent"):setProp("Error", cLogErro)			
																		
							EndIf
						Else
							// Banco
							If oLtOfBank[1]:getpropvalue('BankInternalId') != nil 
								cCdBco := oLtOfBank[1]:getpropvalue('BankInternalId')
								aAdd(aVendor, {"A2_BANCO", cCdBco, Nil})
							EndIf
		
							// Agência
							If  oLtOfBank[1]:getpropvalue('BranchCode') != nil 
								cAgBco := oLtOfBank[1]:getpropvalue('BranchCode')
								aAdd(aVendor, {"A2_AGENCIA", cAgBco, Nil})
							EndIf
		
							// Dígito Agência
							If oLtOfBank[1]:getpropvalue('BranchKey') != nil 
								cDgAgBco := oLtOfBank[1]:getpropvalue('BranchKey')
								aAdd(aVendor, {"A2_DVAGE", cDgAgBco, Nil})
							EndIf
		
							// Cta Corrente
							If oLtOfBank[1]:getpropvalue('CheckingAccountNumber') != nil 
								cCCBco := oLtOfBank[1]:getpropvalue('CheckingAccountNumber')
								aAdd(aVendor, {"A2_NUMCON", cCCBco, Nil})
							EndIf
		
							// Dígito Conta Corrente
							If oLtOfBank[1]:getpropvalue('CheckingAccountNumberKey') != nil 
								cDgCCBco := oLtOfBank[1]:getpropvalue('CheckingAccountNumberKey') != nil
								aAdd(aVendor, {"A2_DVCTA", cDgCCBco, Nil})
							EndIf
		
							// Tipo da Conta
							If oLtOfBank[1]:getpropvalue('CheckingAccountType') != nil 
								cTpConta := oLtOfBank[1]:getpropvalue('CheckingAccountType')
								Aadd(aVendor, {"A2_TIPCTA", cTpConta, Nil})
							EndIf
		
							//Pega a lista de contas do fornecedor
							If Type("oLtOfBank") == 'A'
								For nAccounts := 2 To Len(oLtOfBank)
									If oLtOfBank[nAccounts]:getpropvalue('MainAccount') != nil 
										cBanco 		:= oLtOfBank[nAccounts]:getpropvalue('BankCode') 
										cAgencia 	:= oLtOfBank[nAccounts]:getpropvalue('BranchCode') 
										cConta 		:= oLtOfBank[nAccounts]:getpropvalue('CheckingAccountNumber') 
										cDvAGencia	:= oLtOfBank[nAccounts]:getpropvalue('BranchKey') 
										cDvConta 	:= oLtOfBank[nAccounts]:getpropvalue('CheckingAccountNumberKey') 
										cTpConta 	:= oLtOfBank[nAccounts]:getpropvalue('CheckingAccountType') 
										cMoeda 		:= oLtOfBank[nAccounts]:getpropvalue('CurrencyAccount') 
										cPrincipal	:= oLtOfBank[nAccounts]:getpropvalue('MainAccount') 
		
										//Adiciona os dados da conta em um vetor, para gravar na FIL após a inclusão do fornecedor pela ExecAuto
										aAdd( aContasFIL, {cBanco, cAgencia, cDvAGencia, cConta, cDvConta, cTpConta, cMoeda, cPrincipal} )
		
										//Caso seja conta principal, atualiza os dados bancários na SA2
										If cPrincipal	== "1"
											aAdd( aVendor, {"A2_BANCO",   cBanco, 	  Nil} )
											aAdd( aVendor, {"A2_AGENCIA", cAgencia,   Nil} )
											aAdd( aVendor, {"A2_DVAGE",   cDvAGencia, Nil} )
											aAdd( aVendor, {"A2_NUMCON",  cConta, 	  Nil} )
											aAdd( aVendor, {"A2_DVCTA",   cDvConta,   Nil} )
											aAdd( aVendor, {'A2_TIPCTA',  cTpConta,   Nil} )
										EndIf
									EndIf
								Next nAccounts
							EndIf
						EndIf
					EndIf
					
					//Se for integração com hotelaria, define o campo de natureza do fornecedor de acordo com o parâmetro MV_HTLNAPF ou MV_HTLNAPJ (essa natureza será utilizada no título de comissão a pagar)
					If lHotel
						//Se o fornecedor for PJ, pega a natureza do parâmetro MV_HTLNAPJ. Do contrário, lê o parâmetro MV_HTLNAPF.
						If lFornecPJ
							cNatFor := SuperGetMV( "MV_HTLNAPJ", , "" )              	
						Else
							cNatFor := SuperGetMV( "MV_HTLNAPF", , "" )
						Endif
              	
						If ! Empty( cNatFor )
							aAdd(aVendor, {"A2_NATUREZ", cNatFor, Nil})
						Endif
					EndIf 

				EndIf

				//Ponto de entrada para incluir campos no array aVendor
				If ExistBlock("MTI020NOM")
					aRetPe := ExecBlock("MTI020NOM",.F.,.F.,{aVendor,oEAIObEt:getPropValue("Name")})
					If ValType(aRetPe) == "A" .And. Len(aRetPe) >0
						If ValType(aRetPe) == "A"
							aVendor := aClone(aRetPe)
						EndIf
					EndIf
				EndIf

				//Verifica se houve erro antes da rotina automatica
				If Empty( cLogErro )
				
					BEGIN TRANSACTION
						//Ordena Array conforme dicionario de dados
						//aVendor := FWVetByDic( aVendor, 'SA2' )						
	
						// Executa Rotina Automática conforme evento
						MSExecAuto({|x, y| MATA020(x, y)}, aVendor, nOpcx)
	
						// Se a Rotina Automática retornou erro
						If lMsErroAuto
			               // Obtém o log de erros''
							aErroAuto := GetAutoGRLog()
			
			               // Varre o array obtendo os erros e quebrando a linha
							cLogErro := ""
							For nCount := 1 To Len(aErroAuto)
								cLogErro += StrTran( StrTran( aErroAuto[nCount], "<", "" ), "-", "" ) + CRLF
							Next nCount
							
							ofwEAIObj:Activate()
							ofwEAIObj:setProp("ReturnContent")
						  	ofwEAIObj:getPropValue("ReturnContent"):setProp("Error", cLogErro)		
						  	
						  	lRet := .F.				
						  	
							//Cancela a utilização do código sequencial
							If lHotel .AND. ! lIniPadCod
								RollBackSX8()
							Endif
	               
							DisarmTransaction()
							MsUnLockAll()
						Else
							//Grava as informações da FIL (Bancos x Fornec)
							If Len( aContasFIL ) > 0
								lRet := M020FILGrv( cFILFil, cCode, cLoja, aContasFIL )
								If !lRet
									cLogErro := ""	
									ofwEAIObj:Activate()
									ofwEAIObj:setProp("ReturnContent")
									cLogErro := OemToAnsi(STR0030) //"Erro na gravação da(s) conta(s) do fornecedor (FIL)."
									ofwEAIObj:getPropValue("ReturnContent"):setProp("Error", cLogErro)							
								
									DisarmTransaction()
									MsUnLockAll()
								Endif
							Endif
	
							If lRet
								cValSRAInt := GPEI090NRcv( CFGA070INT( cMarca, "SRA", "RA_MAT", cValExt ), { "RA_FILIAL", "RA_MAT" } )
	
								If (!Empty(cPISSRA) .AND. (nOpcx == 3 .OR. nOpcx == 4) ) .OR. !Empty(cValSRAInt)
									Gp265GrvFun(nOpcX, cPISSRA, cMarca, cCampo, cValExt, cAlias, cValSRAInt)
								EndIf
	
								// CRUD do XXF (de/para)
								If nOpcx == 3 // Insert
									cValInt := IntForExt(, , SA2->A2_COD, SA2->A2_LOJA)[2]
									CFGA070Mnt(cMarca, cAlias, cField, cValExt, cValInt, .F.)
		                  
									//Confirma a utilização do código sequencial
									If lHotel .AND. ! lIniPadCod
										ConfirmSX8()
									Endif								
								ElseIf nOpcx == 4 // Update
									CFGA070Mnt(cMarca, cAlias, cField, cValExt, cValInt, .F.)
								Else  // Delete
									CFGA070Mnt(cMarca, cAlias, cField, cValExt, cValInt, .T.)
								EndIf
										
								// Monta o JSON de retorno
								ofwEAIObj:Activate()
																						
								ofwEAIObj:setProp("ReturnContent")
													
								ofwEAIObj:getPropValue("ReturnContent"):setProp("ListOfInternalID",{},'InternalId',,.T.)
								ofwEAIObj:getPropValue("ReturnContent"):get("ListOfInternalID")[1]:setprop("Name",cOwnerMsg,,.T.)
								ofwEAIObj:getPropValue("ReturnContent"):get("ListOfInternalID")[1]:setprop("Origin",cValExt,,.T.)
								ofwEAIObj:getPropValue("ReturnContent"):get("ListOfInternalID")[1]:setprop("Destination",cValInt,,.T.)	
								If nOpcx != 5 .And. !Empty(cCdBco)
									ofwEAIObj:getPropValue("ReturnContent"):setProp("ListOfInternalID",{},'InternalId',,.T.)
									ofwEAIObj:getPropValue("ReturnContent"):get("ListOfInternalID")[1]:setprop("Name","Bank",,.T.)
									ofwEAIObj:getPropValue("ReturnContent"):get("ListOfInternalID")[1]:setprop("Origin",cBcoExt,,.T.)
									ofwEAIObj:getPropValue("ReturnContent"):get("ListOfInternalID")[1]:setprop("Destination",M70MontInt(xFilial('SA6'), cCdBco, cAgBco, cCCBco),,.T.)							
								Endif							
							Endif
	
						EndIf
	
					END TRANSACTION
					
				Endif

			ElseIf cTypeReg == "CUSTOMER"   
				aRet := FWIntegDef("MATA030", cTypeMessage, nTypeTrans, oEAIObEt)
				
				If ValType(aRet) == "A"
					If !Empty(aRet)
						lRet := aRet[1][1]
						cLogErro := aRet[1][2]
					EndIf
				Endif
				
			EndIf
			
		//--------------------------------------
		//resposta da mensagem Unica TOTVS
		//--------------------------------------
		ElseIf cTypeMessage == EAI_MESSAGE_RESPONSE
			
			// Se não houve erros na resposta
			If Upper(oEAIObEt:getPropValue("ProcessingInformation"):getPropValue("Status")) == "OK" 
				// Verifica se a marca foi informada
				If oEAIObEt:getHeaderValue("ProductName") !=  nil .And. !Empty( oEAIObEt:getHeaderValue("ProductName") ) 
					cProduct := oEAIObEt:getHeaderValue("ProductName")
				Else
					lRet := .F.
					cLogErro := ""	
					ofwEAIObj:Activate()
					ofwEAIObj:setProp("ReturnContent")
					cLogErro := STR0016 // "Erro no retorno. O Product é obrigatório!"
					ofwEAIObj:getPropValue("ReturnContent"):setProp("Error", cLogErro)
															
				EndIf

				If oEAIObEt:getPropValue("ReturnContent"):getPropValue("ListOfInternalID") !=  nil   
					// Verifica se o código interno foi informado
					If oEAIObEt:getPropValue("ReturnContent"):getPropValue("ListOfInternalID")[1]:getPropValue("Origin") != nil 
						cValInt := oEAIObEt:getPropValue("ReturnContent"):getPropValue("ListOfInternalID")[1]:getPropValue("Origin")
					Else
						lRet := .F.
						cLogErro := ""	
						ofwEAIObj:Activate()
						ofwEAIObj:setProp("ReturnContent")
						cLogErro := STR0017 // "Erro no retorno. O OriginalInternalId é obrigatório!"
						ofwEAIObj:getPropValue("ReturnContent"):setProp("Error", cLogErro)
																
					EndIf

					// Verifica se o código externo foi informado
					If oEAIObEt:getPropValue("ReturnContent"):getPropValue("ListOfInternalID")[1]:getPropValue("Destination") != nil
						cValExt := oEAIObEt:getPropValue("ReturnContent"):getPropValue("ListOfInternalID")[1]:getPropValue("Destination")
					Else
						lRet := .F.
						cLogErro := ""	
						ofwEAIObj:Activate()
						ofwEAIObj:setProp("ReturnContent")
						cLogErro := STR0018 // "Erro no retorno. O DestinationInternalId é obrigatório"
						ofwEAIObj:getPropValue("ReturnContent"):setProp("Error", cLogErro)
																
					EndIf
					
	            	If Upper(AllTrim(oEAIObEt:getPropValue("ReceivedMessage"):getPropValue("Event"))) == "UPSERT"
	            		CFGA070Mnt(cProduct, cAlias, cField, cValExt, cValInt, .F.)
	            	Elseif Upper(AllTrim(oEAIObEt:getPropValue("ReceivedMessage"):getPropValue("Event"))) == "DELETE"
	            		CFGA070Mnt(cProduct, cAlias, cField, cValExt, cValInt, .T.)
	            	Endif
	            	
				EndIf
			Else
				cLogErro := ""
				If oEAIObEt:getpropvalue('ProcessingInformation') != nil
					oMsgError := oEAIObEt:getpropvalue('ProcessingInformation'):getpropvalue("ListOfMessages")
					For nX := 1 To Len( oMsgError )
						cLogErro += oMsgError[nX]:getpropvalue('Message') + CRLF
					Next nX
				Endif
	
				lRet := .F.
				ofwEAIObj:Activate()
				ofwEAIObj:setProp("ReturnContent")
				ofwEAIObj:getPropValue("ReturnContent"):setProp("Error", cLogErro )
			EndIf
		
		//--------------------------------------
	  	//whois
	  	//--------------------------------------		
		ElseIf cTypeMessage == EAI_MESSAGE_WHOIS
			ofwEAIObj := "1.000|2.000|2.001|2.002|2.003|2.004|2.005"
		EndIf
		
	//--------------------------------------
	//envio mensagem
	//--------------------------------------	
	ElseIf nTypeTrans == TRANS_SEND
	
		If !Inclui .And. !Altera
			cEvent := "delete"
			CFGA070Mnt("PROTHEUS","SA2","A2_COD",,IntForExt(, , SA2->A2_COD, SA2->A2_LOJA)[2],.T.)
		Else
			cEvent := "upsert"
		EndIf

		// Obtém o nome do Banco
		cBcoName := BankName(SA2->A2_BANCO, SA2->A2_AGENCIA, SA2->A2_NUMCON)

		// Trata endereço separando Logradouro e Número
		cLograd := trataEnd(SA2->A2_END, "L")
		cNumero := trataEnd(SA2->A2_END, "N")

		//-- Retorna o codigo do estado a partir da sigla
		cCodEst  := Tms120CdUf(SA2->A2_EST, '1')

		//-- Envio do codigo de acordo com padrao IBGE (cod. estado + cod. municipio)
		If !Empty(SA2->A2_COD_MUN)
			cCodMun := Rtrim(cCodEst) + Rtrim(SA2->A2_COD_MUN)
		Endif
		
		//Montagem da mensagem
		ofwEAIObj:Activate()
		ofwEAIObj:setEvent(cEvent)
		
		ofwEAIObj:setprop("CompanyId", 	AllTrim(cEmpAnt))
		ofwEAIObj:setprop("BranchId", 	AllTrim(cFilAnt))
		ofwEAIObj:setprop("CompanyInternalId", cEmpAnt + '|' + cFilAnt)
		ofwEAIObj:setprop("Code", 		Rtrim(SA2->A2_COD))
		ofwEAIObj:setprop("StoreId", 	Rtrim(SA2->A2_LOJA))
		ofwEAIObj:setprop("InternalId", IntForExt(, , SA2->A2_COD, SA2->A2_LOJA)[2])
		ofwEAIObj:setprop("ShortName", 	AllTrim(SA2->A2_NREDUZ))
		ofwEAIObj:setprop("Name", 		AllTrim(SA2->A2_NOME))
		
		//Ajustado para enviar o tipo conforme documentacao API Totvs
		//Identifica se o emitente é apenas Cliente, apenas Fornecedor ou Ambos 
		//1 – Cliente 
		//2 – Fornecedor 
		//3 – Ambos
		ofwEAIObj:setprop("Type", 2 ) //'Vendor'

		//Ajustado para enviar o tipo conforme documentacao API Totvs
		//Identifica se o emitente é Pessoa Física, Jurídica, Estrangeiro ou Trading 
		//1 – Pessoa Física 
		//2 – Pessoa Jurídica 
		//3 – Estrangeiro 
		//4 – Trading		
		If SA2->A2_TIPO == 'F'
			ofwEAIObj:setprop("EntityType", 1)
			cCNPJCPF   := 'CPF'
		Else
			ofwEAIObj:setprop("EntityType", 2)
			cCNPJCPF   := 'CNPJ'
		EndIf		
		
		ofwEAIObj:setprop("RegisterDate", SubStr(DToC(DDATABASE), 7, 4) + '-' + SubStr(DToC(DDATABASE), 4, 2) + '-' + SubStr(DToC(DDATABASE), 1, 2))
		
		If SA2->A2_MSBLQL == '1'
			ofwEAIObj:setprop("RegisterSituation", "Inactive")
		Else
			ofwEAIObj:setprop("RegisterSituation", "Active")
		EndIf
		
		If !Empty(SA2->A2_INSCR) .Or. !Empty(SA2->A2_INSCRM) .Or. !Empty(SA2->A2_CGC)
			ofwEAIObj:setprop('GovernmentalInformation',{},'Tax',,.T.)
       		ofwEAIObj:get("GovernmentalInformation")[1]:setprop("Name"   	, "INSCRICAO ESTADUAL",,.T.)
	        ofwEAIObj:get("GovernmentalInformation")[1]:setprop("Scope"     , "State",,.T.)
	        ofwEAIObj:get("GovernmentalInformation")[1]:setprop("Id"       	, Rtrim(SA2->A2_INSCR),,.T.)
	        ofwEAIObj:setprop('GovernmentalInformation',{},'Tax',,.T.)
	     	ofwEAIObj:get("GovernmentalInformation")[2]:setprop("Name"   	,"INSCRICAO MUNICIPAL",,.T.)
	        ofwEAIObj:get("GovernmentalInformation")[2]:setprop("Scope"     , "Municipal",,.T.)
	        ofwEAIObj:get("GovernmentalInformation")[2]:setprop("Id"       	, Rtrim(SA2->A2_INSCRM),,.T.)
			ofwEAIObj:setprop('GovernmentalInformation',{},'Tax',,.T.)
	     	ofwEAIObj:get("GovernmentalInformation")[3]:setprop("Name"   	, cCNPJCPF,,.T.)
	        ofwEAIObj:get("GovernmentalInformation")[3]:setprop("Scope"     , "Federal",,.T.)
	        ofwEAIObj:get("GovernmentalInformation")[3]:setprop("Id"       	, Rtrim(SA2->A2_CGC),,.T.)
		EndIf
		
		oAddress := ofwEAIObj:setprop("Address")
		oAddress:setprop("Address", Rtrim(cLograd) )
		oAddress:setprop("Number", Rtrim(cNumero) )
		oAddress:setprop("Complement", Iif(Empty(SA2->A2_COMPLEM),_NoTags(trataEnd(SA2->A2_END, "C")),_NoTags(Rtrim(SA2->A2_COMPLEM))) )
		
		If !Empty(SA2->A2_COD_MUN) .Or. !Empty(SA2->A2_MUN)
			oAddress:setprop("City")
			If !Empty(cCodMun)
				oAddress:getPropValue("City"):setprop("CityCode", cCodMun )
				oAddress:getPropValue("City"):setprop("CityInternalId", cCodMun )
			Else
				oAddress:getPropValue("City"):setprop("CityCode", "" )
				oAddress:getPropValue("City"):setprop("CityInternalId", "" )
			EndIf
			oAddress:getPropValue("City"):setprop("CityDescription", Rtrim(SA2->A2_MUN) )
		EndIf
		
		oAddress:setprop("District", Rtrim(SA2->A2_BAIRRO) )
		
		If !Empty(SA2->A2_EST)
			oAddressState := oAddress:setprop("State")
			oAddressState:setprop("StateCode", AllTrim( SA2->A2_EST ) )
			oAddressState:setprop("StateInternalId", AllTrim( SA2->A2_EST ) )
			oAddressState:setprop("StateDescription", Rtrim(Posicione("SX5",1, xFilial("SX5") + "12" + SA2->A2_EST, "X5DESCRI()" )) )
		EndIf
		
		If !Empty(SA2->A2_PAIS)
			oAddressCountry := oAddress:setprop("Country")
			oAddressCountry:setprop("CountryCode", Rtrim(SA2->A2_PAIS) )
			oAddressCountry:setprop("CountryInternalId", Rtrim(SA2->A2_PAIS) )
		EndIf
			
		oAddress:setprop("ZIPCode", Rtrim(SA2->A2_CEP) )
		oAddress:setprop("POBox", Rtrim(SA2->A2_CX_POST) )
		
		If !Empty(SA2->A2_TEL) .Or. !Empty(SA2->A2_FAX) .Or. !Empty(SA2->A2_HPAGE) .Or. !Empty(SA2->A2_EMAIL)
			If !Empty(SA2->A2_DDI)
				cTel := AllTrim(SA2->A2_DDI)
			Endif

			If !Empty(SA2->A2_DDD)
				If !Empty(cTel)
					cTel += AllTrim(SA2->A2_DDD)
				Else
					cTel := AllTrim(SA2->A2_DDD)
				Endif
			Endif

			If !Empty(cTel)
				cTel += AllTrim(SA2->A2_TEL)
			Else
				cTel := AllTrim(SA2->A2_TEL)
			Endif
			
			ofwEAIObj:setprop('ListOfCommunicationInformation',{},'CommunicationInformation',,.T.)
			ofwEAIObj:get("ListOfCommunicationInformation")[1]:setprop("PhoneNumber", cTel,,.T.)
			ofwEAIObj:get("ListOfCommunicationInformation")[1]:setprop("FaxNumber", Rtrim(SA2->A2_FAX),,.T.)
			ofwEAIObj:get("ListOfCommunicationInformation")[1]:setprop("HomePage", _NoTags(Rtrim(SA2->A2_HPAGE)),,.T.)
			ofwEAIObj:get("ListOfCommunicationInformation")[1]:setprop("Email", _NoTags(Rtrim(SA2->A2_EMAIL)),,.T.)
		EndIf
		
		If !Empty(SA2->A2_CONTATO)
			ofwEAIObj:setprop('ListOfContacts',{},'Contact',,.T.)
			ofwEAIObj:get("ListOfContacts")[1]:setprop("ContactInformationName", _NoTags(Rtrim(SA2->A2_CONTATO)),,.T.)
		EndIf
		
		If !Empty(SA2->A2_BANCO)
			ofwEAIObj:setprop('ListOfBankingInformation',{},'BankingInformation',,.T.)	
			ofwEAIObj:get("ListOfBankingInformation")[nCont]:setprop("BankCode", Rtrim(SA2->A2_BANCO),,.T.)
			ofwEAIObj:get("ListOfBankingInformation")[nCont]:setprop("BankInternalId",  M70MontInt(xFilial('SA6'), SA2->A2_BANCO, SA2->A2_AGENCIA, SA2->A2_NUMCON),,.T.)
			ofwEAIObj:get("ListOfBankingInformation")[nCont]:setprop("BankName", cBcoName,,.T.)
			ofwEAIObj:get("ListOfBankingInformation")[nCont]:setprop("BranchCode", RTrim(SA2->A2_AGENCIA),,.T.)
			ofwEAIObj:get("ListOfBankingInformation")[nCont]:setprop("BranchKey", RTrim(SA2->A2_DVAGE),,.T.)
			ofwEAIObj:get("ListOfBankingInformation")[nCont]:setprop("CheckingAccountNumber", RTrim(SA2->A2_NUMCON),,.T.)
			ofwEAIObj:get("ListOfBankingInformation")[nCont]:setprop("CheckingAccountNumberKey", RTrim(SA2->A2_DVCTA),,.T.)
			ofwEAIObj:get("ListOfBankingInformation")[nCont]:setprop("CheckingAccountType", RTrim(SA2->A2_TIPCTA),,.T.)
			ofwEAIObj:get("ListOfBankingInformation")[nCont]:setprop("MainAccount", "1",,.T.)
			ofwEAIObj:get("ListOfBankingInformation")[nCont]:setprop("CurrencyAccount", "01",,.T.)
			
			DbSelectArea("FIL")
			aFILArea	:= FIL->(GetArea())
			If FIL->(DbSeek( cFILFil + SA2->A2_COD + SA2->A2_LOJA ))
				While FIL->(!Eof() .AND. cFILFil + SA2->A2_COD + SA2->A2_LOJA == FIL->FIL_FILIAL + FIL->FIL_FORNEC + FIL->FIL_LOJA)
					If RTrim(FIL->FIL_TIPO) <> "1" //Se não for a conta principal, pois a mesma já foi considerada acima
						nCont++
						ofwEAIObj:setprop('ListOfBankingInformation',{},'BankingInformation',,.T.)
						ofwEAIObj:get("ListOfBankingInformation")[nCont]:setprop("BankCode", Rtrim(FIL->FIL_BANCO),,.T.)
						ofwEAIObj:get("ListOfBankingInformation")[nCont]:setprop("BranchCode", RTrim(FIL->FIL_AGENCI),,.T.)
						ofwEAIObj:get("ListOfBankingInformation")[nCont]:setprop("BranchKey", RTrim(FIL->FIL_DVAGE),,.T.)
						ofwEAIObj:get("ListOfBankingInformation")[nCont]:setprop("CheckingAccountNumber", RTrim(FIL->FIL_CONTA),,.T.)
						ofwEAIObj:get("ListOfBankingInformation")[nCont]:setprop("CheckingAccountNumberKey", RTrim(FIL->FIL_DVCTA),,.T.)
						ofwEAIObj:get("ListOfBankingInformation")[nCont]:setprop("CheckingAccountType", RTrim(FIL->FIL_TIPCTA),,.T.)
						ofwEAIObj:get("ListOfBankingInformation")[nCont]:setprop("MainAccount", RTrim(FIL->FIL_TIPO),,.T.)
						ofwEAIObj:get("ListOfBankingInformation")[nCont]:setprop("CurrencyAccount", RTrim(CVALTOCHAR(FIL->FIL_MOEDA)),,.T.)
					Endif
					FIL->(DbSkip())
				EndDo
			EndIf
			RestArea(aFILArea)
		EndIf
				
	EndIf

Return { lRet, ofwEAIObj, cOwnerMsg } 


// --------------------------------------------------------------------------------------
/*/{Protheus.doc} BankName
Obtem o nome do Banco conforme indice informado

@param cCod Codigo do Banco
@param cAge Agencia
@param cCon Conta Corrente

@author  Leandro Luiz da Cruz
@version P11
@since   04/12/2012 - 17:36
@return  cResult Variavel com o valor obtido
/*/
// --------------------------------------------------------------------------------------

Static Function BankName(cCod, cAge, cCon)

	Local cResult  := ""
	Local aAreaAnt := GetArea()
	
	// Altera área
	DbSelectArea("SA6")
	SA6->(DbSetOrder(1))
	
	// Obtém o nome do Banco conforme índice informado
	If SA6->(dbSeek(xFilial("SA6") + cCod + cAge + cCon))
		cResult := AllTrim(SA6->A6_NOME)
	EndIf
	
	// Restaura área anterior
	RestArea(aAreaAnt)
		
Return cResult

//-------------------------------------------------------------------
/*/{Protheus.doc} IntForExt
Monta o InternalID do Fornecedor de acordo com o código passado
no parâmetro.

@param   cEmpresa   Código da empresa (Default cEmpAnt)
@param   cFil       Código da Filial (Default cFilAnt)
@param   cFornec    Código do Fornecedor
@param   cLoja      Loja   do Fornecedor
@param   cVersao    Versão da mensagem única (Default 2.000)

@author  Leandro Luiz da Cruz
@version P11
@since   08/02/2013
@return  aResult Array contendo no primeiro parâmetro uma variável
lógica indicando se o registro foi encontrado.
No segundo parâmetro uma variável string com o InternalID
montado.

@sample  IntForExt(, , '00001', '01') irá retornar {.T., '01|01|00001|01|F'}
/*/
//-------------------------------------------------------------------
Static Function IntForExt(cEmpresa, cFil, cFornec, cLoja )
	
	Local   aResult  := {}
	Default cEmpresa := cEmpAnt
	Default cFil     := xFilial('SA2')
	
	aAdd(aResult, .T.)
	aAdd(aResult, cEmpresa + '|' + RTrim(cFil) + '|' + RTrim(cFornec) + '|' + RTrim(cLoja) + '|F')

Return aResult

//-------------------------------------------------------------------
/*/{Protheus.doc} IntForInt
Recebe um InternalID e retorna o código do Fornecedor.

@param   cInternalID InternalID recebido na mensagem.
@param   cRefer      Produto que enviou a mensagem
@param   cVersao     Versão da mensagem única (Default 2.000)

@author  Leandro Luiz da Cruz
@version P11
@since   08/02/2013
@return  aResult Array contendo no primeiro parâmetro uma variável
         lógica indicando se o registro foi encontrado no de/para.
         No segundo parâmetro uma variável array com a empresa,admin
         filial, o código do fornecedor e a loja do fornecedor.

@sample  IntLocInt('01|01|00001|01') irá retornar
{.T., {'01', '01', '00001', '01', 'F'}}
/*/
//-------------------------------------------------------------------
Static Function IntForInt(cInternalID, cRefer )

	Local   aResult  := {}
	Local   aTemp    := {}
	Local   cTemp    := ''
	Local   cAlias   := 'SA2'
	Local   cField   := 'A2_COD'
	
	cTemp := CFGA070Int(cRefer, cAlias, cField, cInternalID)
	
	If !Empty(cTemp)
		aAdd(aResult, .T.)
		aTemp := Separa(cTemp, '|')
		aAdd(aResult, aTemp)
	EndIf
	
Return aResult

//-------------------------------------------------------------------
/*/{Protheus.doc} M020FILDel
Função para deletar as informações bancárias do fornecedor (tabela FIL)

@param cFILFil, Filial atual referente a tabela FIL
@param cCode, Código do fornecedor
@param cLoja, Loja do fornecedor
@author Pedro Alencar
@since 02/07/2014
@version P11
/*/
//-------------------------------------------------------------------
Static Function M020FILDel ( cFILFil, cCode, cLoja )

	Local aAreaAnt := GetArea()
	
	dbSelectArea("FIL")
	dbSetOrder(1) //FIL_FILIAL+FIL_FORNEC+FIL_LOJA+FIL_TIPO+FIL_BANCO+FIL_AGENCI+FIL_CONTA
	IF MsSeek( cFILFil+cCode+cLoja )
		While FIL->( !EOF() ) .AND. FIL_FILIAL == cFILFil .AND. FIL_FORNEC == cCode .AND. FIL_LOJA == cLoja
			RecLock( 'FIL', .F. )
			FIL->( dbDelete() )
			FIL->( msUnlock() )
			FIL->( dbSkip() )
		EndDo
	Endif
	
	RestArea( aAreaAnt )
	
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} M020FILGrv
Função para tratar as informações bancárias do fornecedor

@param cFILFil, Filial atual referente a tabela FIL
@param cCode, Código do fornecedor
@param cLoja, Loja do fornecedor
@param aContasFIL, Vetor com as contas do fornecedor
@return lRet, Retorna se salvou ou não a FIL
@author Pedro Alencar
@since 02/07/2014
@version P11
/*/
//-------------------------------------------------------------------
Static Function M020FILGrv ( cFILFil, cCode, cLoja, aContasFIL )

	Local lRet 		 := .T.
	Local cBanco 	 := ""
	Local cAgencia 	 := ""
	Local cConta 	 := ""
	Local cDvAGencia := ""
	Local cDvConta	 := ""
	Local cTpConta	 := ""
	Local cMoeda	 := ""
	Local cPrincipal := ""
	Local nI		 := 0
	
	//Apaga os bancos do fornecedor para atualizar de acordo com as novas informações recebidas
	M020FILDel ( cFILFil, cCode, cLoja )
	
	If Len( aContasFIL ) > 0
		For nI := 1 To Len( aContasFIL )
			cBanco 	:= aContasFIL[nI][1]
			cAgencia 	:= aContasFIL[nI][2]
			cDvAGencia	:= aContasFIL[nI][3]
			cConta 	:= aContasFIL[nI][4]
			cDvConta 	:= aContasFIL[nI][5]
			cTpConta 	:= aContasFIL[nI][6]
			cMoeda 	:= aContasFIL[nI][7]
			cPrincipal	:= aContasFIL[nI][8]
	
			If RecLock( 'FIL', .T. )
				FIL->FIL_FILIAL := cFILFil
				FIL->FIL_FORNEC := cCode
				FIL->FIL_LOJA := cLoja
				FIL->FIL_BANCO := cBanco
				FIL->FIL_AGENCI := cAgencia
				FIL->FIL_DVAGE := cDvAGencia
				FIL->FIL_CONTA := cConta
				FIL->FIL_DVCTA := cDvConta
				FIL->FIL_TIPCTA := cTpConta
				FIL->FIL_TIPO := cPrincipal
				FIL->FIL_MOEDA := VAL( cMoeda )
	
				FIL->( MsUnLock() )
			Else
				lRet := .F.
				Exit
			Endif
	
		Next nI
	Endif

Return lRet

/*/{Protheus.doc} ITFINDREG
Busca fornecedor e posiciona

@param cFILFil, Filial atual referente a tabela FIL
@param cCode, Código do fornecedor
@param cLoja, Loja do fornecedor
@param aContasFIL, Vetor com as contas do fornecedor

@return lRet, Retorna se salvou ou não a FIL

@author Rodrigo Machado Pontes
@since 18/08/2015

@version P12
/*/
Static Function ITFINDREG(cFornece,cLoja)

	Local cQry		:= ""
	Local lRet		:= .F.

	cQry	:= " SELECT R_E_C_N_O_ AS REG"
	cQry	+= " FROM " + RetSqlName("SA2") + " SA2"
	cQry	+= " WHERE	SA2.A2_COD 		= '" + cFornece 	+ "'"
	cQry	+= " AND 	SA2.A2_LOJA 		= '" + cLoja 	+ "'"
	cQry	+= " AND 	SA2.A2_FILIAL		= '" + xFilial("SA2")+ "'"
	cQry	+= " AND 	SA2.D_E_L_E_T_ 	= ''"

	cQry := ChangeQuery(cQry)

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),"SA2REG",.T.,.T.)

	DbSelectArea("SA2REG")
	SA2REG->(DbGotop())
	If SA2REG->(!EOF())
		lRet := .T.

		DbSelectArea("SA2")
		SA2->(DbSetOrder(1))
		SA2->(DbGoto(SA2REG->REG))
	Endif

	SA2REG->(DbCloseArea())

Return lRet

/*/{Protheus.doc} ProxNum
Rotina para retornar o Proximo numero para gravação

@return cRet, Código sequêncial válido

@author Pedro Alencar
@since 26/05/2015
@version 12.1.6
/*/
Static Function ProxNum()

	Local aAreaSA2 := {}
	Local cRet := ""
	Local lLivre := .F.
	
	aAreaSA2 := SA2->( GetArea() )
	cRet := GetSxeNum( "SA2", "A2_COD" )
	SA2->( dbSetOrder( 1 ) )
	
	While !lLivre
		If SA2->( msSeek( FWxFilial("SA2") + cRet ) )
			ConfirmSX8()
			cRet := GetSxeNum( "SA2", "A2_COD" )
		Else
			lLivre := .T.
		Endif
	Enddo
	
	SA2->( RestArea( aAreaSA2 ) )
	
Return cRet




//-------------------------------------------------------------------
/*/{Protheus.doc} IntChcEmp
Função que retorna a filial do registro recebido.
O RM permite estar logado em uma filial no contexto e manipular registros
de outras filiais. Neste caso o EAI utiliza a filial do Messageinformation
(contexto) para logar no Protheus e esta função altera a filial corrente
para a filial do registro.
No execauto dos formulários MVC não informamos o código da filial. Ele
utiliza a filial logada.

@param   oEAIObEt Objeto JSON
@param   cAlias   Alias da tabela do cadastro
@param   cProduto Produto da integração
@author  Totvs Cascavel
@version P11
@since   08/05/2018

@return aEmpresas Valor booleano indicando se o de/para de empresa
         foi informado corretamente e a filial a ser utilizada no cadastro.
         
         Realizado ajuste para trabalhar com objeto JSON
/*/
//-------------------------------------------------------------------
Static Function IntChcEmp(oEAIObEt, cAlias, cProduto)

   Local aFilialP := {}
   Local cEmp     := ""
   Local cFil     := ""
   Local cEmpProt := ""
   Local cFilProt := ""
   Local lLog     := FindFunction("AdpLogEAI")

   If oEAIObEt:getPropValue("CompanyId") != nil .And. !Empty( oEAIObEt:getPropValue("CompanyId") )
      cEmp := oEAIObEt:getPropValue("CompanyId")
   EndIf

   If oEAIObEt:getPropValue("BranchId") != nil .And. !Empty( oEAIObEt:getPropValue("BranchId") )
      cFil := oEAIObEt:getPropValue("BranchId")
   EndIf

   // Se o cadastro é compartilhado a nível de filial ou a nível de empresa no RM
   // As tags CompanyID e BranchId podem vir vazias
   If Empty(cEmp)
      If lLog
         AdpLogEAI(2, STR0129 + Chr(10) + STR0130) //"Empresa compartilhada." "Tag CompanyId do BusinessContent veio vazia."
      EndIf
   EndIf

   If Empty(cFil)
      If lLog
         AdpLogEAI(2, STR0131 + Chr(10) + STR0132) //"Filial compartilhada." "Tag BranchId do BusinessContent veio vazia."
      EndIf
   EndIf

   If Empty(cEmp) .Or. Empty(cFil)
      aAdd(aFilialP, .T.)
      aAdd(aFilialP, cFilProt)

      Return aFilialP
   EndIf
   
   aFilialP := FWEAIEMPFIL(cEmp, cFil, UPPER(cProduto))

   If Empty(aFilialP)
      If lLog
         AdpLogEAI(2, STR0133 + cEmp + "/" + cFil + STR0134 + cProduto + ".") //"Empresa/Filial " " recebida no BusinessContent não esta cadastrada no de/para para o produto "
      EndIf

      cEmpProt := cEmpAnt
      cFilProt := cFilAnt
   Else
      cEmpProt := aFilialP[1]
      cFilProt := aFilialP[2]
   EndIf

   If cEmpProt != cEmpAnt
      If lLog
         AdpLogEAI(2, STR0104 + " " + cEmpProt + STR0134 + cEmpAnt + STR0135) //"Empresa" " recebida no BusinessContent é diferente da empresa " " enviada no MessageInformation."
      EndIf

      cEmpProt := cEmpAnt
      cFilProt := cFilAnt
   EndIf

   aFilialP := {}

   If cFilAnt != cFilProt
      If lLog
         AdpLogEAI(2, "Alteração de filial.") //"Alteração de filial."
         AdpLogEAI(2, "Filial Anterior: " + cFilAnt) //"Filial Anterior: "
      EndIf

      cFilAnt := cFilProt

      If lLog
         AdpLogEAI(2, "Nova Filial: " + cFilAnt) //"Nova Filial: "
      EndIf
   EndIf

   aAdd(aFilialP, .T.)
   aAdd(aFilialP, cFilProt)
   
Return aFilialP
