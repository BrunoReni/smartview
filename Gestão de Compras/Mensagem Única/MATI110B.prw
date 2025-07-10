#Include 'Protheus.ch' 
#Include 'RwMake.ch'
#Include 'TopConn.ch'
#Include "FWAdapterEAI.ch" 
#Include "MATI110B.ch"  

/*/{Protheus.doc} MATI110B(cXML,nTypeTrans,cTypeMessage,cVersion)
	Rastreabilidade de solicitação de compra ou armazem                                
		
	@param	cXML      		Conteudo xml para envio/recebimento
	@param nTypeTrans		Tipo de transacao. (Envio/Recebimento)              
	@param	cTypeMessage  Tipo de mensagem. (Business Type, WhoIs, etc)
	@param	cVersion		Versão em uso
	
	@retorno aRet			Array contendo o resultado da execucao e a mensagem Xml de retorno.
				aRet[1]	(boolean) Indica o resultado da execução da função
				aRet[2]	(caracter) Mensagem Xml para envio                             
	
	@author	Rodrigo Machado Pontes
	@version	P11
	@since	21/03/2013
/*/

Function MATI110B(cXML, nTypeTrans, cTypeMessage, cVersion)

Local aArea		:= GetArea()
Local aSolArm		:= {} 
Local aSolCom		:= {}
Local aBaixas		:= {}
Local aCotaca		:= {} 
Local aPedCom		:= {}
Local aNfEntr		:= {}
Local cError		:= ""
Local cWarning	:= ""
Local cNumero		:= ""
Local cXMLRet		:= ""
Local cTipoRast	:= ""
Local cMarca		:= ""
Local cValExt		:= ""
Local cValInt		:= ""
Local cForn		:= ""
Local cLoja		:= ""
Local lRast		:= .T.
Local nI			:= 0

Private oXmlM110B	:= Nil

If ( nTypeTrans == TRANS_SEND )

	cXMLRet += '<BusinessRequest>'
	cXMLRet += 	'<Operation>MATI110B</Operation>'						
	cXMLRet += '</BusinessRequest>'
	
	cXMLRet += '<BusinessContent>'
	
	If AllTrim(FunName()) == "MATA105" //Solicitação de Armazem
		cXMLRet += 	'<InternalId>' + cEmpAnt + '|' + RTrim(xFilial("SCP")) + '|' + RTrim(SCP->CP_NUM) + '</InternalId>'
		cXMLRet += 	'<CompanyInternalId>' + cEmpAnt + '|' + RTrim(cFilAnt) + '</CompanyInternalId>'
		cXMLRet += 	'<CompanyId>' + cEmpAnt + '</CompanyId>'
		cXMLRet += 	'<BranchId>' + RTrim(cFilAnt) + '</BranchId>'
		cXMLRet += 	'<Type>000</Type>'
	Elseif AllTrim(FunName()) == "MATA110" //Solicitação de Compras
		cXMLRet += 	'<InternalId>' + cEmpAnt + '|' + RTrim(xFilial("SC1")) + '|' + RTrim(SC1->C1_NUM) + '</InternalId>'
		cXMLRet += 	'<CompanyInternalId>' + cEmpAnt + '|' + RTrim(cFilAnt) + '</CompanyInternalId>'
		cXMLRet += 	'<CompanyId>' + cEmpAnt + '</CompanyId>'
		cXMLRet += 	'<BranchId>' + RTrim(cFilAnt) + '</BranchId>'
		cXMLRet += 	'<Type>001</Type>'
	Endif
	
	cXMLRet += '</BusinessContent>'
	
Elseif ( nTypeTrans == TRANS_RECEIVE )

	If	( cTypeMessage == EAI_MESSAGE_WHOIS )
		
		cXMLRet := '1.000'
	
	//-- Recebimento da Business Message
	ElseIf ( cTypeMessage == EAI_MESSAGE_BUSINESS )
	
		oXmlM110B := XmlParser(cXml, "_", @cError, @cWarning)
		
		//Valida se houve erro no parser
		If ( oXmlM110B <> Nil ) .And. ( Empty(cError) ) .And. ( Empty(cWarning) ) 
			
			If Type("oXmlM110B:_TotvsMessage:_MessageInformation:_Product:_Name:Text") <> "U" 					
				cMarca := oXmlM110B:_TotvsMessage:_MessageInformation:_Product:_Name:Text
			Endif
			
			If Type("oXmlM110B:_TOTVSMessage:_BusinessMessage:_BusinessContent:_InternalId:Text") <> "U"
				cValExt := oXmlM110B:_TOTVSMessage:_BusinessMessage:_BusinessContent:_InternalId:Text
			Endif
			
			If Type("oXmlM110B:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Type:Text") <> "U"
				cTipoRast	:= AllTrim(oXmlM110B:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Type:Text)
			Endif
			
			If cTipoRast == "000" //Solicitação de armazem
				//Busca valor interno
				cValInt:= CFGA070Int(cMarca,"SCP","CP_NUM",cValExt)
				
				If !Empty(cValInt)
					cNumero	:= AllTrim(Separa(cValInt,"|")[3])
					
					//Busca solicitação armazem
					aSolArm := A110BSA(cNumero)
					
					If Len(aSolArm) > 0
						aBaixas := A110BBX(cNumero) 
						aSolCom := A110BSC(cNumero,1)
						aCotaca := A110BCO(aSolCom,1) 
						aPedCom := A110BPC(aSolCom,1)
						aNfEntr := A110BNFE(aPedCom)
					Else
						cXMLRet := "SA não encontrada no Protheus"
						lRast := .F.
					Endif
				Else
					cXMLRet := "SA não encontrada no de/para"
					lRast := .F.
				Endif
			Elseif cTipoRast == "001" //Solicitação de compras
				//Busca valor interno
				cValInt:= CFGA070Int(cMarca,"SC1","C1_NUM",cValExt)
				
				If !Empty(cValInt)
					cNumero	:= AllTrim(Separa(cValInt,"|")[3])
					
					//Busca solicitação compras
					aSolCom := A110BSC(cNumero,2)
					
					If Len(aSolCom) > 0
						aCotaca := A110BCO(cNumero,2) 
						aPedCom := A110BPC(cNumero,2)
						aNfEntr := A110BNFE(aPedCom)
					Else
						cXMLRet := "SC não encontrada no Protheus"
						lRast := .F.
					Endif
				Else
					cXMLRet := "SC não encontrada no de/para"
					lRast := .F.	
				Endif
			Endif
			
			If lRast
			
				cXMLRet := '<ReturnTraceability>'
				
				If cTipoRast == "000" //SA			
					For nI := 1 To Len(aSolArm)
						aItens		:= aSolArm[nI,6]
						aRatCC		:= aSolArm[nI,7]
						aRatPrj	:= aSolArm[nI,8]
						
						cXMLRet += 	'<InternalId>' + IntSArExt(,,aSolArm[nI,1])[2] + '</InternalId>'
			  			cXMLRet += 	'<CompanyInternalId>' + AllTrim(cEmpAnt) + '|' + AllTrim(cFilAnt) + '</CompanyInternalId>'
			  			cXMLRet += 	'<CompanyId>' + AllTrim(cEmpAnt) + '</CompanyId>'
			  			cXMLRet += 	'<BranchId>' + AllTrim(cFilAnt) + '</BranchId>'
			  			cXMLRet += 	'<Number>' + AllTrim(aSolArm[nI,1]) + '</Number>'
			  			cXMLRet += 	'<Status>' + AllTrim(aSolArm[nI,5]) + '</Status>'
			  			cXMLRet += 	'<RegisterDate>' + INTDTANO(aSolArm[nI,2]) + '</RegisterDate>'
			  			cXMLRet += 	'<Requester>' + AllTrim(aSolArm[nI,3]) + '</Requester>'
			  			cXMLRet += 	'<Value>' + AllTrim(cValToChar(aSolArm[nI,4])) + '</Value>'
			  			cXMLRet += 	'<Type>' + AllTrim(cTipoRast) + '</Type>'
			  			cXMLRet += A110BXMLIT(aItens,aRatCC,aRatPrj,"SA",aSolArm[nI,1],,,,StoD(aSolArm[nI,2]))
		  			Next nI
		  		Elseif cTipoRast == "001" //SC
		  			For nI := 1 To Len(aSolCom)
						aItens		:= aSolCom[nI,6]
						aRatCC		:= aSolCom[nI,7]
						aRatPrj	:= aSolCom[nI,8]
						
						cXMLRet += 	'<InternalId>' + IntSCoExt(,,aSolCom[nI,1])[2] + '</InternalId>'
			  			cXMLRet += 	'<CompanyInternalId>' + AllTrim(cEmpAnt) + '|' + AllTrim(cFilAnt) + '</CompanyInternalId>'
			  			cXMLRet += 	'<CompanyId>' + AllTrim(cEmpAnt) + '</CompanyId>'
			  			cXMLRet += 	'<BranchId>' + AllTrim(cFilAnt) + '</BranchId>'
			  			cXMLRet += 	'<Number>' + AllTrim(aSolCom[nI,1]) + '</Number>'
			  			cXMLRet += 	'<Status>' + AllTrim(aSolCom[nI,5]) + '</Status>'
			  			cXMLRet += 	'<RegisterDate>' + INTDTANO(aSolCom[nI,2]) + '</RegisterDate>'
			  			cXMLRet += 	'<Requester>' + AllTrim(aSolCom[nI,3]) + '</Requester>'
			  			cXMLRet += 	'<Value>' + AllTrim(cValToChar(aSolCom[nI,4])) + '</Value>'
			  			cXMLRet += 	'<Type>' + AllTrim(cTipoRast) + '</Type>'
			  			cXMLRet += A110BXMLIT(aItens,aRatCC,aRatPrj,"SC",aSolCom[nI,1])
		  			Next nI
		  		Endif
		  		
		  		cXMLRet += 	'<ListOfTraceability>'
		  		
		  		If cTipoRast == "000" //SA
	  				If Len(aSolCom) > 0
						For nI := 1 To Len(aSolCom)
		    				aItens		:= aSolCom[nI,6]
		    				aRatCC		:= aSolCom[nI,7]
		    				aRatPrj	:= aSolCom[nI,8]
		    				
		    				cXMLRet += 		'<Request>'
			      			cXMLRet += 			'<InternalId>' + IntSCoExt(,,aSolCom[nI,1])[2]  + '</InternalId>'
			      			cXMLRet += 			'<CompanyInternalId>' + AllTrim(cEmpAnt) + '|' + AllTrim(cFilAnt) + '</CompanyInternalId>'
			      			cXMLRet += 			'<CompanyId>' + AllTrim(cEmpAnt) + '</CompanyId>'
			      			cXMLRet += 			'<BranchId>' + AllTrim(cFilAnt) + '</BranchId>'
			      			cXMLRet += 			'<Number>' + AllTrim(aSolCom[nI,1]) + '</Number>'
			      			cXMLRet += 			'<Status>' + AllTrim(aSolCom[nI,5]) + '</Status>'
			      			cXMLRet += 			'<RegisterDate>' + INTDTANO(aSolCom[nI,2]) + '</RegisterDate>'
			      			cXMLRet += 			'<Requester>' + AllTrim(aSolCom[nI,3]) + '</Requester>'
			      			cXMLRet += 			'<Value>' + AllTrim(cValToChar(aSolCom[nI,4])) + '</Value>'
							cXMLRet += A110BXMLIT(aItens,aRatCC,aRatPrj,"SC",aSolCom[nI,1])      			
							cXMLRet += 			'<ListOfParentInternalId>'
			        		cXMLRet += 				'<ParentInternalId>'
			          		cXMLRet += 					'<InternalId>' + IntSArExt(,,aSolCom[nI,9])[2] + '</InternalId>'
			          		cXMLRet += 					'<TypeCode>000</TypeCode>'
			        		cXMLRet += 				'</ParentInternalId>'
			      			cXMLRet += 			'</ListOfParentInternalId>'
			    			cXMLRet += 		'</Request>'
			    		Next nI
		    		Else
		    			cXMLRet += 		'<Request/>'
	    			Endif
		    		
		    		If Len(aBaixas) > 0
		    			For nI := 1 to Len(aBaixas)
		    				aItens		:= aBaixas[nI,6]
		    				aRatCC		:= aBaixas[nI,7]
		    				aRatPrj	:= aBaixas[nI,8]
							
							cXMLRet += 		'<StockTurnOver>'	    			
			      			cXMLRet += 			'<InternalId>' + IntSArExt(,,aBaixas[nI,1])[2] + '</InternalId>'
			      			cXMLRet += 			'<CompanyInternalId>' + AllTrim(cEmpAnt) + '|' + AllTrim(cFilAnt) + '</CompanyInternalId>'
			      			cXMLRet += 			'<CompanyId>' + AllTrim(cEmpAnt) + '</CompanyId>'
			      			cXMLRet += 			'<BranchId>' + AllTrim(cFilAnt) + '</BranchId>'
			      			cXMLRet += 			'<Number>' + AllTrim(aBaixas[nI,1]) + '</Number>'
			      			cXMLRet += 			'<Status>' + AllTrim(aBaixas[nI,5]) + '</Status>'
			      			cXMLRet += 			'<RegisterDate>' + INTDTANO(aBaixas[nI,2]) + '</RegisterDate>'
			      			cXMLRet += 			'<Value>' + AllTrim(cValToChar(aBaixas[nI,4])) + '</Value>'
			      			cXMLRet += A110BXMLIT(aItens,aRatCC,aRatPrj,"BX",aBaixas[nI,1],,,,StoD(aBaixas[nI,2]))
			      			cXMLRet += 			'<ListOfParentInternalId>'
			        		cXMLRet += 				'<ParentInternalId>'
			          		cXMLRet += 					'<InternalId>' + IntSArExt(,,aBaixas[nI,1])[2] + '</InternalId>'
			          		cXMLRet += 					'<TypeCode>000</TypeCode>'
			        		cXMLRet += 				'</ParentInternalId>'
			      			cXMLRet += 			'</ListOfParentInternalId>'
			      			cXMLRet += 		'</StockTurnOver>'
			      		Next nI
		    		Else
		    			cXMLRet += 		'<StockTurnOver/>'
		    		Endif
		    	Endif
		    		
	    		If Len(aCotaca) > 0
	    			For nI := 1 To Len(aCotaca)
	    				aItens 	:= aCotaca[nI,7]
	    				aRatCC		:= aCotaca[nI,8]
	    				aRatPrj	:= aCotaca[nI,9]
	    				
	    				cXMLRet += 		'<Quotation>'
		      			cXMLRet += 			'<InternalId>' + AllTrim(cEmpAnt) + '|' + AllTrim(xFilial("SC8")) + '|' + AllTrim(aCotaca[nI,1]) + '</InternalId>'
		      			cXMLRet += 			'<CompanyInternalId>' + AllTrim(cEmpAnt) + '|' + AllTrim(cFilAnt) + '</CompanyInternalId>'
		      			cXMLRet += 			'<CompanyId>' + AllTrim(cEmpAnt) + '</CompanyId>'
		      			cXMLRet += 			'<BranchId>' + AllTrim(cFilAnt) + '</BranchId>'
		      			cXMLRet += 			'<Number>' + AllTrim(aCotaca[nI,1]) + '</Number>'
		      			cXMLRet += 			'<Status>' + AllTrim(aCotaca[nI,6]) + '</Status>'
		      			cXMLRet += 			'<RegisterDate>' + INTDTANO(aCotaca[nI,5]) + '</RegisterDate>'
		      			cXMLRet += 			'<ProposalsQuantity>' + AllTrim(cValToChar(aCotaca[nI,2])) + '</ProposalsQuantity>'
		      			cXMLRet += 			'<AverageUnitPrice>' + AllTrim(cValToChar(aCotaca[nI,3])) + '</AverageUnitPrice>'
		      			cXMLRet += 			'<AverageTotalPrice>' + AllTrim(cValToChar(aCotaca[nI,4])) + '</AverageTotalPrice>'
		      			cXMLRet += A110BXMLIT(aItens,aRatCC,aRatPrj,"CO",aCotaca[nI,1])
		      			cXMLRet += 			'<ListOfParentInternalId>'
		        		cXMLRet += 				'<ParentInternalId>'
		          		cXMLRet += 					'<InternalId>' + IntSCoExt(,,aCotaca[nI,10])[2] + '</InternalId>'
		          		cXMLRet += 					'<TypeCode>001</TypeCode>'
		        		cXMLRet += 				'</ParentInternalId>'
		      			cXMLRet += 			'</ListOfParentInternalId>'
		      			cXMLRet += 		'</Quotation>'
		      		Next nI
	    		Else
	    			cXMLRet += 		'<Quotation/>'
	    		Endif
		    	
	    		If Len(aPedCom) > 0
	    			For nI := 1 to Len(aPedCom)
	    				aItens		:= aPedCom[nI,7]
	    				aRatCC		:= aPedCom[nI,8]
	    				aRatPrj	:= aPedCom[nI,9]
	    				cForn		:= Separa(aPedCom[nI,4],"|")[1]
	    				cLoja		:= Separa(aPedCom[nI,4],"|")[2]
	    				
	    				cXMLRet += 		'<Order>'
		      			cXMLRet += 			'<InternalId>' + IntPdCExt(,,aPedCom[nI,1])[2] + '</InternalId>'
		      			cXMLRet += 			'<CompanyInternalId>' + AllTrim(cEmpAnt) + '|' + AllTrim(cFilAnt) + '</CompanyInternalId>'
						cXMLRet += 			'<CompanyId>' + AllTrim(cEmpAnt) + '</CompanyId>'
		      			cXMLRet += 			'<BranchId>' + AllTrim(cFilAnt) + '</BranchId>'
		      			cXMLRet += 			'<Number>' + AllTrim(aPedCom[nI,1]) + '</Number>'
		      			cXMLRet += 			'<Status>' + AllTrim(aPedCom[nI,6]) + '</Status>'
		      			cXMLRet += 			'<RegisterDate>' + INTDTANO(aPedCom[nI,2]) + '</RegisterDate>'
		      			cXMLRet += 			'<DeliveryDate>' + INTDTANO(aPedCom[nI,3]) + '</DeliveryDate>'
		      			cXMLRet += 			'<VendorInternalId>' + IntForExt(,,cForn,cLoja)[2] + '</VendorInternalId>'
		      			cXMLRet += 			'<Value>' + AllTrim(cValToChar(aPedCom[nI,5])) + '</Value>'
		      			cXMLRet += A110BXMLIT(aItens,aRatCC,aRatPrj,"PC",aPedCom[nI,1])
		      			cXMLRet += 			'<ListOfParentInternalId>'
		        		cXMLRet += 				'<ParentInternalId>'
		          		cXMLRet += 					'<InternalId>' + IntSCoExt(,,aPedCom[nI,10])[2] + '</InternalId>'
		          		cXMLRet += 					'<TypeCode>001</TypeCode>'
		        		cXMLRet += 				'</ParentInternalId>'
		      			cXMLRet += 			'</ListOfParentInternalId>'
		      			cXMLRet += 		'</Order>'
		      		Next nI
	    		Else
	    			cXMLRet += 		'<Order/>'
	    		Endif
		    		
	    		If Len(aNfEntr) > 0
	    			For nI := 1 To Len(aNfEntr)
	    				aItens		:= aNfEntr[nI,8]
	    				aRatCC		:= aNfEntr[nI,9]
	    				aRatPrj	:= aNfEntr[nI,10]
	    				cForn		:= Separa(aNfEntr[nI,4],"|")[1]
	    				cLoja		:= Separa(aNfEntr[nI,4],"|")[2]
	    				
	    				cXMLRet += 		'<Invoice>'
		      			cXMLRet += 			'<InternalId>' + IntInvExt(,,aNfEntr[nI,1],aNfEntr[nI,2],cForn,cLoja)[2] + '</InternalId>'
		      			cXMLRet += 			'<CompanyInternalId>' + AllTrim(cEmpAnt) + '|' + AllTrim(cFilAnt) + '</CompanyInternalId>'
		      			cXMLRet += 			'<CompanyId>' + AllTrim(cEmpAnt) + '</CompanyId>'
		      			cXMLRet += 			'<BranchId>' + AllTrim(cFilAnt) + '</BranchId>'
		      			cXMLRet += 			'<Number>' + AllTrim(aNfEntr[nI,1]) + '</Number>'
		      			cXMLRet += 			'<Serie>' + AllTrim(aNfEntr[nI,2]) + '</Serie>'
		      			cXMLRet += 			'<Status>' + AllTrim(aNfEntr[nI,7]) + '</Status>'
		      			cXMLRet += 			'<IssueDate>' + INTDTANO(aNfEntr[nI,3]) + '</IssueDate>'
		      			cXMLRet += 			'<VendorInternalId>' + IntForExt(,,cForn,cLoja)[2] + '</VendorInternalId>'
		      			cXMLRet += 			'<Value>' + AllTrim(cValToChar(aNfEntr[nI,6])) + '</Value>'
		      			cXMLRet += 			'<TypeOfDocument>' + AllTrim(aNfEntr[nI,5]) + '</TypeOfDocument>'
		      			cXMLRet += A110BXMLIT(aItens,aRatCC,aRatPrj,"NFE",aNfEntr[nI,1],aNfEntr[nI,2],cForn,cLoja)
		      			cXMLRet += 			'<ListOfParentInternalId>'
		        		cXMLRet += 				'<ParentInternalId>'
		          		cXMLRet += 					'<InternalId>' + IntPdCExt(,,aNfEntr[nI,11])[2] + '</InternalId>'
		          		cXMLRet += 					'<TypeCode>004</TypeCode>'
		        		cXMLRet += 				'</ParentInternalId>'
		      			cXMLRet += 			'</ListOfParentInternalId>'
		      			cXMLRet += 		'</Invoice>'
		      		Next nI
	    		Else
	    			cXMLRet += 		'<Invoice/>' 
	    		Endif
	    		
		  		cXMLRet += 	'</ListOfTraceability>'
		  		cXMLRet += '</ReturnTraceability>'
			Endif
		Endif
	Endif
Endif

RestArea(aArea)

Return {lRast,cXMLRet}

/*/{Protheus.doc} A110BSA()
Busca SA + Itens + Rateio Projeto + Rateio Centro Custo

@param	cNumero	Numero da SA

@author Rodrigo M. Pontes
@since 29/08/2016
@version 11
/*/

Function A110BSA(cNumero)

Local aAreaSCP	:= SCP->(GetArea())
Local aAreaSGS	:= SGS->(GetArea())
Local aAreaAFH	:= AFH->(GetArea())
Local aItens		:= {}
Local aRatCC		:= {}
Local aRatPrj		:= {}
Local aRet			:= {}
Local nTotal		:= 0
Local cQry			:= ""
Local cSituacao	:= ""
Local cFilialCP	:= xFilial("SCP")
Local cFilialGS	:= xFilial("SGS")
Local cFilialAFH	:= xFilial("AFH")
Local lTabSCPExc	:= A110BTABEXC("SCP")
Local lTabSGSExc	:= A110BTABEXC("SGS")
Local lTabAFHExc	:= A110BTABEXC("AFH")

//Cabeçalho
cQry := " SELECT CP_EMISSAO,"
cQry += "        CP_SOLICIT"
cQry += " FROM " + RetSqlName("SCP") + " CP"
cQry += " WHERE  CP.D_E_L_E_T_ = ''"
cQry += "        AND CP.CP_NUM = '" + cNumero + "'"

If lTabSCPExc
	cQry += " AND CP.CP_FILIAL = '" + cFilialCP + "'"
Endif

cQry += " GROUP  BY CP.CP_EMISSAO,"
cQry += "           CP.CP_SOLICIT"
	
cQry := ChangeQuery(cQry)
		
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),"CABEC",.T.,.T.)
	
DbSelectArea("CABEC")
If CABEC->(!EOF())
	cSituacao := A110BSITUACA("SA",cNumero)
				
	//Itens da solicitação
	cQry := " SELECT CP_ITEM,"
	cQry += "        CP_PRODUTO,"
	cQry += "        CP_UM,"
	cQry += "        Round(CP_QUANT, 2) AS CP_QUANT,"
	cQry += "        Round(CP_VUNIT, 2) AS CP_VUNIT,"
	cQry += "        Round (Round(CP_QUANT, 2) * Round(CP_VUNIT, 2), 2) AS TOTAL,"
	cQry += "        CP_LOCAL"
	cQry += " FROM " + RetSqlName("SCP") + " CP"
	cQry += " WHERE  CP.D_E_L_E_T_ = ''" 
	cQry += " AND CP.CP_NUM = '" + cNumero + "'"
	
	If lTabSCPExc
		cQry += " AND CP.CP_FILIAL = '" + cFilialCP + "'"
	Endif
		
	cQry := ChangeQuery(cQry)
		
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),"ITENS",.T.,.T.)
		
	DbSelectArea("ITENS")
	While ITENS->(!EOF())
		aAdd(aItens,{ITENS->CP_ITEM,ITENS->CP_PRODUTO,ITENS->CP_UM,ITENS->CP_QUANT,ITENS->CP_VUNIT,ITENS->TOTAL,ITENS->CP_LOCAL})
		nTotal+=ITENS->TOTAL
		ITENS->(DbSkip())
	Enddo
		
	ITENS->(DbCloseArea())
		
	//Rateio por centro de custo
	cQry := " SELECT GS_ITEMSOL,"
	cQry += "        GS_CC,"
	cQry += "        Sum(GS_PERC) AS PERC"
	cQry += " FROM " + RetSqlName("SGS") + " SGS"
	cQry += " WHERE  SGS.D_E_L_E_T_ = ''"
	cQry += "        AND SGS.GS_SOLICIT = '" + cNumero + "'"
	
	If lTabSGSExc
		cQry += "    AND SGS.GS_FILIAL = '" + cFilialGS + "'"
	Endif
	
	cQry += " GROUP  BY SGS.GS_ITEMSOL,"
	cQry += "           SGS.GS_CC"
		
	cQry := ChangeQuery(cQry)
		
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),"RATCC",.T.,.T.)
		
	DbSelectArea("RATCC")
	While RATCC->(!EOF())
		aAdd(aRatCC,{RATCC->GS_CC,RATCC->PERC,RATCC->GS_ITEMSOL})
		RATCC->(DbSkip())
	Enddo
		
	RATCC->(DbCloseArea())
		
	//Rateio Projeto
	cQry := " SELECT AFH_COD,"
	cQry += "        AFH_PROJET,"
	cQry += "        AFH_TAREFA,"
	cQry += "        AFH_QUANT,"
	cQry += "        AFH_REVISA"
	cQry += " FROM " + RetSqlName("AFH") + " AFH"
	cQry += " WHERE  AFH.D_E_L_E_T_ = ''"
	cQry += "        AND AFH.AFH_NUMSA = '" + cNumero + "'"
	
	If lTabAFHExc
		cQry += "    AND AFH.AFH_FILIAL = '" + cFilialAFH + "'"
	Endif
	
	cQry += " GROUP BY AFH_COD,"
	cQry += "          AFH_PROJET,"
	cQry += "          AFH_TAREFA,"
	cQry += "          AFH_QUANT,"
	cQry += "          AFH_REVISA"
		
	cQry := ChangeQuery(cQry)
		
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),"RATPRJ",.T.,.T.)
		
	DbSelectArea("RATPRJ")
	While RATPRJ->(!EOF())
		aAdd(aRatPrj,{RATPRJ->AFH_PROJET,RATPRJ->AFH_TAREFA,RATPRJ->AFH_QUANT,RATPRJ->AFH_COD,RATPRJ->AFH_REVISA})
		RATPRJ->(DbSkip())
	Enddo
		
	RATPRJ->(DbCloseArea())
		
	If Len(aItens) > 0
		aAdd(aRet,{cNumero,CABEC->CP_EMISSAO,CABEC->CP_SOLICIT,nTotal,cSituacao,aItens,aRatCC,aRatPrj})
	Endif
Endif
		
CABEC->(DbCloseArea())
	
RestArea(aAreaSCP)
RestArea(aAreaSGS)
RestArea(aAreaAFH)

Return aRet

/*/{Protheus.doc} A110BBX()
Busca baixas da SA + Itens + Rateio Projeto + Rateio Centro Custo

@param	cNumero	Numero da SA

@author Rodrigo M. Pontes
@since 29/08/2016
@version 11
/*/

Function A110BBX(cNumSA)

Local aAreaSCQ	:= SCQ->(GetArea())
Local aAreaSCP	:= SCP->(GetArea())
Local aItens		:= {}
Local aRatCC		:= {}
Local aRatPrj		:= {}
Local aRet			:= {}
Local nTotal		:= 0
Local cQry			:= ""
Local cSituacao	:= ""
Local cFilialCQ	:= xFilial("SCQ")
Local cFilialCP	:= xFilial("SCP")
Local cFilialD3	:= xFilial("SD3")
Local lTabSCQExc	:= A110BTABEXC("SCQ")
Local lTabSCPExc	:= A110BTABEXC("SCP")
Local lTabSD3Exc	:= A110BTABEXC("SD3")

cQry := " SELECT CP_EMISSAO,"
cQry += "        CP_SOLICIT"
cQry += " FROM " + RetSqlName("SCP") + " CP"

//Baixa SA
cQry += " JOIN " + RetSqlName("SCQ") + " CQ"
cQry += " 		ON CQ.CQ_NUM = CP.CP_NUM"
cQry += " 		AND CQ.CQ_ITEM = CP.CP_ITEM"
cQry += " 		AND CQ.D_E_L_E_T_ = ''"

cQry += " WHERE  CP.D_E_L_E_T_ = ''"
cQry += "        AND CP.CP_NUM = '" + cNumSA + "'"

If lTabSCPExc
	cQry += " AND CP.CP_FILIAL = '" + cFilialCP + "'"
Endif

cQry += " GROUP  BY CP.CP_EMISSAO,"
cQry += "           CP.CP_SOLICIT"

cQry := ChangeQuery(cQry)

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),"CABEC",.T.,.T.)
	
DbSelectArea("CABEC")
If CABEC->(!EOF())
	cSituacao := A110BSITUACA("BX",cNumSA)
	
	//Itens da solicitação
	cQry := " SELECT CP_ITEM,"
	cQry += "        CP_PRODUTO,"
	cQry += "        CP_UM,"
	cQry += "        Round(D3.D3_QUANT, 2) AS QUANT,"
	cQry += "        Round((D3.D3_CUSTO1 / D3.D3_QUANT), 2) AS VUNIT,"
	cQry += "        Round(D3.D3_CUSTO1, 2) AS TOTAL,"
	cQry += "        CP_LOCAL"
	cQry += " FROM " + RetSqlName("SCP") + " CP"
	cQry += " JOIN " + RetSqlName("SCQ") + " CQ"
	cQry += " 		ON CQ.CQ_NUM = CP.CP_NUM"
	cQry += " 		AND CQ.CQ_ITEM = CP.CP_ITEM"
	cQry += " 		AND CQ.D_E_L_E_T_ = ' '"
	
	If lTabSCQExc
		cQry += " AND CQ.CQ_FILIAL = '" + cFilialCQ + "'"
	Endif
	
	cQry += " JOIN " + RetSqlName("SD3") + " D3"
	cQry += " 		ON D3.D3_NUMSEQ = CQ.CQ_NUMREQ"
	cQry += " 		AND D3.D3_COD = CQ.CQ_PRODUTO"
	cQry += " 		AND D3.D3_LOCAL = CQ.CQ_LOCAL"
	cQry += " 		AND D3.D3_CF = 'RE0'"
	cQry += " 		AND D3.D_E_L_E_T_ = ' '"
	If lTabSD3Exc
		cQry += " AND D3.D3_FILIAL = '" + cFilialD3 + "'"
	EndIf

	cQry += " WHERE  CP.D_E_L_E_T_ = ' '"
	cQry += " AND CP.CP_NUM = '" + cNumSA + "'"
	cQry += " AND CQ.CQ_NUMREQ <> ' ' "

	If lTabSCPExc
		cQry += " AND CP.CP_FILIAL = '" + cFilialCP + "'"
	Endif
		
	cQry := ChangeQuery(cQry)
		
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),"ITENS",.T.,.T.)
		
	DbSelectArea("ITENS")
	While ITENS->(!EOF())
		aAdd(aItens,{ITENS->CP_ITEM,ITENS->CP_PRODUTO,ITENS->CP_UM,ITENS->QUANT,ITENS->VUNIT,ITENS->TOTAL,ITENS->CP_LOCAL})
		nTotal+=ITENS->TOTAL
		ITENS->(DbSkip())
	Enddo
		
	ITENS->(DbCloseArea())
	
	If Len(aItens) > 0
		aAdd(aRet,{cNumSA,CABEC->CP_EMISSAO,CABEC->CP_SOLICIT,nTotal,cSituacao,aItens,aRatCC,aRatPrj,cNumSA})
	Endif
Endif
		
CABEC->(DbCloseArea())

RestArea(aAreaSCQ)
RestArea(aAreaSCP)

Return aRet

/*/{Protheus.doc} A110BSC()
Busca SC + Itens + Rateio Projeto + Rateio Centro Custo

@param	cNumSASC		Numero da SA/SC
@param	nTipo			1-SA, 2-SC

@author Rodrigo M. Pontes
@since 29/08/2016
@version 11
/*/

Function A110BSC(cNumSASC,nTipo)

Local aAreaSCP	:= SCP->(GetArea())
Local aAreaSC1	:= SC1->(GetArea())
Local aAreaSCX	:= SCX->(GetArea())
Local aAreaAFG	:= AFG->(GetArea())
Local aItens		:= {}
Local aRatCC		:= {}
Local aRatPrj		:= {}
Local aRet			:= {}
Local aSCInfo		:= {}
Local nI			:= 0
Local nTotal		:= 0
Local cQry			:= ""
Local cSituacao	:= ""
Local cFilialC1	:= xFilial("SC1")
Local cFilialCX	:= xFilial("SCX")
Local cFilialAFG	:= xFilial("AFG")
Local cFilialDHN	:= xFilial("DHN")
Local lTabSCPExc	:= A110BTABEXC("SCP")
Local lTabSC1Exc	:= A110BTABEXC("SC1")
Local lTabSGXExc	:= A110BTABEXC("SCX")
Local lTabAFGExc	:= A110BTABEXC("AFG")

//Busca as solicitações de compra
If nTipo == 1 //SA
	cQry := " SELECT DHN_DOCDES "
	cQry += " FROM " + RetSqlName("DHN") + " DHN "
	cQry += " WHERE DHN.D_E_L_E_T_ = ''"
	cQry += " AND DHN.DHN_DOCORI = '" + cNumSASC + "'"
	cQry += " AND DHN.DHN_TIPO = '1'"
	
	If lTabSCPExc
		cQry += "    AND DHN.DHN_FILIAL = '" + cFilialDHN + "'"
	Endif
	
	cQry += " GROUP BY DHN_DOCDES "
	
	cQry := ChangeQuery(cQry)
		
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),"SASC",.T.,.T.) 
	
	DbSelectArea("SASC")
	While SASC->(!EOF())
		aAdd(aSCInfo,SASC->DHN_DOCDES)
		SASC->(DbSkip())
	Enddo
	
	SASC->(DbCloseArea())
Else
	aAdd(aSCInfo,cNumSASC)
Endif

For nI := 1 To Len(aSCInfo)

	//Cabeçalho
	cQry := " SELECT C1_EMISSAO,"
	cQry += "        C1_FORNECE,"
	cQry += "        C1_LOJA"
	cQry += " FROM " + RetSqlName("SC1") + " C1"
	cQry += " WHERE  C1.D_E_L_E_T_ = ''"
	cQry += "        AND C1.C1_NUM = '" + aSCInfo[nI] + "'"
	
	If lTabSC1Exc
		cQry += "    AND C1.C1_FILIAL = '" + cFilialC1 + "'"
	Endif
	
	cQry += " GROUP  BY C1_EMISSAO,"
	cQry += "           C1_FORNECE,"
	cQry += "           C1_LOJA"
	
	cQry := ChangeQuery(cQry)
	
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),"CABEC",.T.,.T.)
	
	DbSelectArea("CABEC")
	If CABEC->(!EOF())
		cSituacao := A110BSITUACA("SC",aSCInfo[nI]) 
		
		//Itens da solicitação
		cQry := " SELECT C1_ITEM,"
		cQry += "        C1_PRODUTO,"
		cQry += "        C1_UM,"
		cQry += "        Round(C1_QUANT, 2) as C1_QUANT,"
		cQry += "        Round(C1_VUNIT, 2) as C1_VUNIT,"
		cQry += "        Round(Round(C1_QUANT, 2) * Round(C1_VUNIT, 2), 2) as TOTAL,"
		cQry += "        C1_LOCAL"
		cQry += " FROM " + RetSqlName("SC1") + " C1"
		cQry += " WHERE  C1.D_E_L_E_T_ = ''"
		cQry += "        AND C1.C1_NUM = '" + aSCInfo[nI] + "'"
		
		If lTabSC1Exc
			cQry += "    AND C1.C1_FILIAL = '" + cFilialC1 + "'"
		Endif 
			
		cQry := ChangeQuery(cQry)
		
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),"ITENS",.T.,.T.)
			
		DbSelectArea("ITENS")
		While ITENS->(!EOF())
			aAdd(aItens,{ITENS->C1_ITEM,ITENS->C1_PRODUTO,ITENS->C1_UM,ITENS->C1_QUANT,ITENS->C1_VUNIT,ITENS->TOTAL,ITENS->C1_LOCAL})
			nTotal+=ITENS->TOTAL
			ITENS->(DbSkip())
		Enddo
			
		ITENS->(DbCloseArea())
		
		//Rateio por centro de custo
		cQry := " SELECT CX_ITEMSOL,"
		cQry += "        CX_CC,"
		cQry += "        Sum(CX_PERC) AS PERC"
		cQry += " FROM " + RetSqlName("SCX") + " SCX"
		cQry += " WHERE  SCX.D_E_L_E_T_ = ''"
		cQry += "        AND SCX.CX_SOLICIT = '" + aSCInfo[nI] + "'"
		
		If lTabSGXExc
			cQry += "    AND SCX.CX_FILIAL = '" + cFilialCX + "'"
		Endif
		
		cQry += " GROUP  BY SCX.CX_ITEMSOL,"
		cQry += "           SCX.CX_CC"
			
		cQry := ChangeQuery(cQry)
		
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),"RATCC",.T.,.T.)
			
		DbSelectArea("RATCC")
		While RATCC->(!EOF())
			aAdd(aRatCC,{RATCC->CX_CC,RATCC->PERC,RATCC->CX_ITEMSOL})
			RATCC->(DbSkip())
		Enddo
			
		RATCC->(DbCloseArea())
		
		If nTipo == 2 //Originado de uma SA, rateio de projeto sera visualizado pela SA	
			//Rateio Projeto
			cQry := " SELECT AFG_COD,"
			cQry += "        AFG_PROJET,"
			cQry += "        AFG_TAREFA,"
			cQry += "        AFG_QUANT,"
			cQry += "        AFG_REVISA"
			cQry += " FROM " + RetSqlName("AFG") + " AFG"
			cQry += " WHERE  AFG.D_E_L_E_T_ = ''"
			cQry += "        AND AFG.AFG_NUMSC = '" + aSCInfo[nI] + "'"
			
			If lTabAFGExc
				cQry += "    AND AFG.AFG_FILIAL = '" + cFilialAFG + "'"
			Endif
			
			cQry += " GROUP BY AFG_COD,"
			cQry += "          AFG_PROJET,"
			cQry += "          AFG_TAREFA,"
			cQry += "          AFG_QUANT,"
			cQry += "          AFG_REVISA"
			
			cQry := ChangeQuery(cQry)
			
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),"RATPRJ",.T.,.T.)
				
			DbSelectArea("RATPRJ")
			While RATPRJ->(!EOF())
				aAdd(aRatPrj,{RATPRJ->AFG_PROJET,RATPRJ->AFG_TAREFA,RATPRJ->AFG_QUANT,RATPRJ->AFG_COD,RATPRJ->AFG_REVISA})
				RATPRJ->(DbSkip())
			Enddo
				
			RATPRJ->(DbCloseArea())
		Endif
		
		//Relacionamento com SA
		If nTipo == 1
			aAdd(aRet,{aSCInfo[nI],CABEC->C1_EMISSAO,CABEC->C1_FORNECE+"|"+CABEC->C1_LOJA,nTotal,cSituacao,aItens,aRatCC,aRatPrj,cNumSASC})
		Elseif nTipo == 2 //SC
			aAdd(aRet,{aSCInfo[nI],CABEC->C1_EMISSAO,CABEC->C1_FORNECE+"|"+CABEC->C1_LOJA,nTotal,cSituacao,aItens,aRatCC,aRatPrj})
		Endif
	Endif
		
	CABEC->(DbCloseArea())
	
	aItens		:= {}
	aRatCC		:= {}
	aRatPrj	:= {}
	
Next nI
	
RestArea(aAreaSCP)
RestArea(aAreaSC1)
RestArea(aAreaSCX)
RestArea(aAreaAFG)

Return aRet

/*/{Protheus.doc} A110BCO()
Busca Cotação + Itens

@param	xSCs	Array com as SC ou Numero da SC
@param	nTipo	1-Array com SC, 2-Numero SC

@author Rodrigo M. Pontes
@since 29/08/2016
@version 11
/*/

Function A110BCO(xSCs,nTipo)

Local aAreaSC8	:= SC8->(GetArea())
Local aAreaSC1	:= SC1->(GetArea())
Local aSCInfo		:= {}
Local aItens		:= {}
Local aRatCC		:= {}
Local aRatPrj		:= {}
Local aRet			:= {}
Local nI			:= 0
Local cQry			:= ""
Local cSituacao	:= ""
Local cFilialC8	:= xFilial("SC8")
Local cFilialC1	:= xFilial("SC1")
Local lTabSC8Exc	:= A110BTABEXC("SC8")
Local lTabSC1Exc	:= A110BTABEXC("SC1")

If nTipo == 1 //Array com SC
	For nI := 1 To Len(xSCs)
		aAdd(aSCInfo,xSCs[nI,1])
	Next nI
Else
	aAdd(aSCInfo,xSCs)
Endif

For nI := 1 To Len(aSCInfo)
	
	cQry := " SELECT C8.C8_NUM,"
	cQry += "        C8.C8_EMISSAO,"
	cQry += "        Count(C8.C8_NUMPRO)                              AS PROPOSTAS,"
	cQry += "        Round(Sum(C8.C8_PRECO) / Count(C8.C8_NUMPRO), 2) AS PRECO_MEDIO,"
	cQry += "        Round(Sum(C8.C8_TOTAL) / Count(C8.C8_NUMPRO), 2) AS MEDIA_TOTAL"
	cQry += " FROM " + RetSqlName("SC8") + " C8"
	cQry += " WHERE  C8.D_E_L_E_T_ = ''"
	cQry += "        AND C8.C8_NUMPED NOT IN ( 'XXXXXX' )"
	cQry += "        AND C8.C8_NUMSC = '" + aSCInfo[nI] + "'"
	
	If lTabSC8Exc
		cQry += " AND C8.C8_FILIAL = '" + cFilialC8 + "'"
	Endif
	
	cQry += " GROUP  BY C8.C8_NUM,"
	cQry += "           C8.C8_EMISSAO"
	
	cQry := ChangeQuery(cQry)
		
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),"CABEC",.T.,.T.)

	DbSelectArea("CABEC")
	While CABEC->(!EOF())
		cSituacao := A110BSITUACA("CO",CABEC->C8_NUM)
		
		//Itens Cotação
		cQry := " SELECT C8_ITEM,"
		cQry += "        C8_PRODUTO,"
		cQry += "        C8_UM,"
		cQry += "        C8_QUANT,"
		cQry += "        C8_PRECO,"
		cQry += "        C8_TOTAL,"
		cQry += "        C1_LOCAL,"
		cQry += "        C8_FORNECE"
		cQry += " FROM " + RetSqlName("SC8") + " C8"
		cQry += "        JOIN " + RetSqlName("SC1") + " C1"
		cQry += "          ON C1.C1_NUM = C8.C8_NUMSC"
		cQry += "          AND C1.D_E_L_E_T_ = ''"
		
		If lTabSC1Exc
			cQry += "          AND C1.C1_FILIAL = '" + cFilialC1 + "'"
		Endif		
		
		cQry += " WHERE  C8.D_E_L_E_T_ = ''"
		cQry += "        AND C8.C8_NUM = '" + CABEC->C8_NUM + "'"
		
		If lTabSC8Exc
			cQry += "          AND C8.C8_FILIAL = '" + cFilialC8 + "'"
		Endif		
		
		cQry += " GROUP  BY C8_ITEM,"
		cQry += "           C8_PRODUTO,"
		cQry += "           C8_UM,"
		cQry += "           C8_QUANT,"
		cQry += "           C8_PRECO,"
		cQry += "           C8_TOTAL,"
		cQry += "           C1_LOCAL,"
		cQry += "           C8_FORNECE"
		
		cQry := ChangeQuery(cQry)
		
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),"ITENS",.T.,.T.)
		
		DbSelectArea("ITENS")
		While ITENS->(!EOF())
			aAdd(aItens,{ITENS->C8_ITEM,ITENS->C8_PRODUTO,ITENS->C8_UM,ITENS->C8_QUANT,ITENS->C8_PRECO,ITENS->C8_TOTAL,ITENS->C1_LOCAL})
			ITENS->(DbSkip())
		Enddo
	
		ITENS->(DbCloseArea())

		If Len(aItens) > 0
			aAdd(aRet,{CABEC->C8_NUM,CABEC->PROPOSTAS,CABEC->PRECO_MEDIO,CABEC->MEDIA_TOTAL,CABEC->C8_EMISSAO,cSituacao,aItens,aRatCC,aRatPrj,aSCInfo[nI]})
		Endif
		
		aItens := {}
		CABEC->(DbSkip())
	Enddo
	
	CABEC->(DbCloseArea()) 
Next nI

RestArea(aAreaSC8)
RestArea(aAreaSC1)

Return aRet

/*/{Protheus.doc} A110BPC()
Busca PC + Itens + Rateio Projeto + Rateio Centro Custo

@param	cNumero	Numero da PC

@author Rodrigo M. Pontes
@since 29/08/2016
@version 11
/*/

Function A110BPC(xSCs,nTipo)

Local aAreaSC7	:= SC7->(GetArea())
Local aAreaSCH	:= SCH->(GetArea())
Local aAreaAJ7	:= AJ7->(GetArea())
Local aSCInfo		:= {}
Local aRet			:= {}
Local aItens		:= {}
Local aRatCC		:= {}
Local aRatPrj		:= {}
Local nI			:= 0
Local nTotal		:= 0
Local cQry			:= ""
Local cSituacao	:= ""
Local cFilialC7	:= xFilial("SC7")
Local cFilialCH	:= xFilial("SCH")
Local cFilialAJ7	:= xFilial("AJ7")
Local lTabSC7Exc	:= A110BTABEXC("SC7")
Local lTabSCHExc	:= A110BTABEXC("SCH")
Local lTabAJ7Exc	:= A110BTABEXC("AJ7")

If nTipo == 1 //Array com SC
	For nI := 1 To Len(xSCs)
		aAdd(aSCInfo,xSCs[nI,1])
	Next nI
Elseif nTipo == 2 //SC
	aAdd(aSCInfo,xSCs)
Elseif nTipo == 3 //PC
	aAdd(aSCInfo,xSCs)
Endif

For nI := 1 To Len(aSCInfo)

	//Cabeçalho
	cQry := " SELECT C7_NUM,"
	cQry += "        C7_EMISSAO,"
	cQry += "        C7_DATPRF,"
	cQry += "        C7_FORNECE,"
	cQry += "        C7_LOJA"
	cQry += " FROM " + RetSqlName("SC7") + " C7"
	cQry += " WHERE  C7.D_E_L_E_T_ = ''"
	
	//SC
	If nTipo <> 3
		cQry += "        AND C7.C7_NUMSC = '" + aSCInfo[nI] + "'"
	Else //PC
		cQry += "        AND C7.C7_NUM = '" + aSCInfo[nI] + "'"
	Endif
	
	If lTabSC7Exc
		cQry += "    AND C7.C7_FILIAL = '" + cFilialC7 + "'"
	Endif
	
	cQry += " GROUP  BY C7.C7_NUM,"
	cQry += "           C7.C7_EMISSAO,"
	cQry += "           C7.C7_DATPRF,"
	cQry += "           C7.C7_FORNECE,"
	cQry += "           C7.C7_LOJA"
	
	cQry := ChangeQuery(cQry)
		
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),"CABEC",.T.,.T.)
	
	DbSelectArea("CABEC")
	While CABEC->(!EOF())
		cSituacao	:= A110BSITUACA("PC",CABEC->C7_NUM)
		
		//Itens do Pedido de compra
		cQry := " SELECT C7_ITEM,"
		cQry += "        C7_PRODUTO,"
		cQry += "        C7_UM,"
		cQry += "        C7_QUANT,"
		cQry += "        Round(C7_PRECO,2) as C7_PRECO,"
		cQry += "        Round(C7_TOTAL,2) as C7_TOTAL,"
		cQry += "        C7_LOCAL"
		cQry += " FROM " + RetSqlName("SC7") + " C7"
		cQry += " WHERE  C7.D_E_L_E_T_ = ''"
		cQry += "        AND C7.C7_NUM = '" + CABEC->C7_NUM + "'"
		
		If lTabSC7Exc
			cQry += "    AND C7.C7_FILIAL = '" + cFilialC7 + "'"
		Endif
		
		cQry := ChangeQuery(cQry)
		
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),"ITENS",.T.,.T.)
		
		DbSelectArea("ITENS")
		While ITENS->(!EOF())
			aAdd(aItens,{ITENS->C7_ITEM,ITENS->C7_PRODUTO,ITENS->C7_UM,ITENS->C7_QUANT,ITENS->C7_PRECO,ITENS->C7_TOTAL,ITENS->C7_LOCAL})
			nTotal+=ITENS->C7_TOTAL
			ITENS->(DbSkip())
		Enddo
		
		ITENS->(DbCloseArea())
		
		//Rateio por Centro de custo
		cQry := " SELECT CH_ITEMPD,"
		cQry += "        CH_CC,"
		cQry += "        Sum(CH_PERC) AS PERC"
		cQry += " FROM " + RetSqlName("SCH") + " CH"
		cQry += " WHERE  CH.D_E_L_E_T_ = ''"
		cQry += "        AND CH.CH_PEDIDO = '" + CABEC->C7_NUM + "'"
		
		If lTabSCHExc
			cQry += "    AND CH.CH_FILIAL = '" + cFilialCH + "'"
		Endif
		
		cQry += " GROUP  BY CH_ITEMPD,"
		cQry += "           CH_CC"
		
		cQry := ChangeQuery(cQry)
		
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),"RATCC",.T.,.T.)
		
		DbSelectArea("RATCC")
		RATCC->(DbGotop())
		While RATCC->(!EOF())
			aAdd(aRatCC,{RATCC->CH_CC,RATCC->PERC,RATCC->CH_ITEMPD})
			RATCC->(DbSkip())
		Enddo
		
		RATCC->(DbCloseArea())
		
		//Rateio Projeto
		cQry := " SELECT AJ7_COD,"
		cQry += "        AJ7_PROJET,"
		cQry += "        AJ7_TAREFA,"
		cQry += "        AJ7_QUANT,"
		cQry += "        AJ7_REVISA"
		cQry += " FROM " + RetSqlName("AJ7") + " AJ7"
		cQry += " WHERE  AJ7.D_E_L_E_T_ = ''"
		cQry += "        AND AJ7.AJ7_NUMPC = '" + CABEC->C7_NUM + "'"
		
		If lTabAJ7Exc
			cQry += "    AND AJ7.AJ7_FILIAL = '" + cFilialAJ7 + "'"
		Endif
		
		cQry += " GROUP BY AJ7_COD,"
		cQry += "          AJ7_PROJET,"
		cQry += "          AJ7_TAREFA,"
		cQry += "          AJ7_QUANT,"
		cQry += "          AJ7_REVISA"
		
		cQry := ChangeQuery(cQry)
		
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),"RATPRJ",.T.,.T.)
		
		DbSelectArea("RATPRJ")
		RATPRJ->(DbGotop())
		While RATPRJ->(!EOF())
			aAdd(aRatPrj,{RATPRJ->AJ7_PROJET,RATPRJ->AJ7_TAREFA,RATPRJ->AJ7_QUANT,RATPRJ->AJ7_COD,RATPRJ->AJ7_REVISA})
			RATPRJ->(DbSkip())
		Enddo
		
		RATPRJ->(DbCloseArea())
		
		If Len(aItens) > 0
			aAdd(aRet,{CABEC->C7_NUM,CABEC->C7_EMISSAO,CABEC->C7_DATPRF,CABEC->C7_FORNECE+"|"+CABEC->C7_LOJA,nTotal,cSituacao,aItens,aRatCC,aRatPrj,aSCInfo[nI]})
		Endif
				
		aItens		:= {}
		aRatCC		:= {}
		aRatPrj	:= {}
		
		nTotal := 0 //Zera a variavel para não duplicar os valor total
		CABEC->(DbSkip())
	Enddo

	
	CABEC->(DbCloseArea())
Next nI

RestArea(aAreaSC7)
RestArea(aAreaSCH)
RestArea(aAreaAJ7)

Return aRet

/*/{Protheus.doc} A110BNFE(aPCs)
Busca NFe + Itens + Rateio Projeto + Rateio Centro Custo

@param	cNumero	Numero da SA

@author Rodrigo M. Pontes
@since 29/08/2016
@version 11
/*/

Function A110BNFE(aPCs)

Local aAreaSF1	:= SF1->(GetArea())
Local aAreaSD1	:= SD1->(GetArea())
Local aAreaSDE	:= SDE->(GetArea())
Local aAreaAFN	:= AFN->(GetArea())
Local aRet			:= {}
Local aItens		:= {}
Local aRatCC		:= {}
Local aRatPrj		:= {}
Local aPCInfo		:= {}
Local nI			:= 0
Local cQry			:= ""
Local cSituacao	:= ""
Local cFilialF1	:= xFilial("SF1")
Local cFilialD1	:= xFilial("SD1")
Local cFilialDE	:= xFilial("SDE")
Local cFilialAFN	:= xFilial("AFN")
Local lTabSF1Exc	:= A110BTABEXC("SF1")
Local lTabSD1Exc	:= A110BTABEXC("SD1")
Local lTabSDEExc	:= A110BTABEXC("SDE")
Local lTabAFNExc	:= A110BTABEXC("AFN")

For nI := 1 To Len(aPCs)
	aAdd(aPCInfo,aPCs[nI,1])
Next nI

For nI := 1 To Len(aPCInfo)
	
	//Cabeçalho
	cQry := " SELECT F1_DOC,"
	cQry += "        F1_SERIE,"
	cQry += "        F1_STATUS,"
	cQry += "        F1_EMISSAO,"
	cQry += "        F1_FORNECE,"
	cQry += "        F1_LOJA,"
	cQry += "        F1_TIPO,"
	cQry += "        F1_CHVNFE,"
	cQry += "        Round(F1_VALBRUT, 2) AS F1_VALBRUT"
	cQry += " FROM " + RetSqlName("SF1") + " F1"
	cQry += "       JOIN " + RetSqlName("SD1") + " D1 ON D1.D_E_L_E_T_ = ''"
	cQry += "           AND F1.F1_DOC = D1.D1_DOC"
	cQry += "           AND F1.F1_SERIE = D1.D1_SERIE"
	cQry += "           AND F1.F1_FORNECE = D1.D1_FORNECE"
	cQry += "           AND F1.F1_LOJA = D1.D1_LOJA"
	
	If lTabSD1Exc
		cQry += "    AND D1.D1_FILIAL = '" + cFilialD1 + "'"
	Endif
	
	cQry += "           AND D1.D1_PEDIDO = '" + aPCInfo[nI] + "'"
	
	cQry += " WHERE  F1.D_E_L_E_T_ = ''"
	
	If lTabSF1Exc
		cQry += "    AND F1.F1_FILIAL = '" + cFilialF1 + "'"
	Endif
	
	cQry += " GROUP  BY F1.F1_DOC,"
	cQry += "           F1.F1_SERIE,"
	cQry += "           F1.F1_STATUS,"
	cQry += "           F1.F1_EMISSAO,"
	cQry += "           F1.F1_FORNECE,"
	cQry += "           F1.F1_LOJA,"
	cQry += "           F1.F1_TIPO,"
	cQry += "           F1.F1_CHVNFE,"
	cQry += "           F1.F1_VALBRUT"
	
	cQry := ChangeQuery(cQry)
		
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),"CABEC",.T.,.T.)
	
	DbSelectArea("CABEC")
	While CABEC->(!EOF())
		If Empty(CABEC->F1_STATUS)
			cSituacao := STR0007 //"NF Não Classificada"
		Elseif AllTrim(CABEC->F1_STATUS) == "B"
			cSituacao := STR0008 //"NF Bloqueada"
		Elseif AllTrim(CABEC->F1_STATUS) == "C"
			cSituacao := STR0009 //"NF Bloqueada s/classf."
		Elseif AllTrim(CABEC->F1_TIPO) == "N"
		 	cSituacao := STR0010 //"NF Normal"
		Elseif AllTrim(CABEC->F1_TIPO) == "P"
		 	cSituacao := STR0011 //"NF de Compl. IPI"
		Elseif AllTrim(CABEC->F1_TIPO) == "I"
			cSituacao := STR0012 //"NF de Compl. ICMS"
		Elseif AllTrim(CABEC->F1_TIPO) == "C"
			cSituacao := STR0013 //"NF de Compl. Preco/Frete"
		Elseif AllTrim(CABEC->F1_TIPO) == "B"
			cSituacao := STR0014 //"NF de Beneficiamento"
		Elseif AllTrim(CABEC->F1_TIPO) == "D"
			cSituacao := STR0015 //"NF de Devolucao"
		Endif
		
		//Itens da NF Entrada
		cQry := " SELECT D1_ITEM,"
		cQry += "        D1_COD,"
		cQry += "        D1_UM,"
		cQry += "        D1_QUANT,"
		cQry += "        D1_VUNIT,"
		cQry += "        D1_TOTAL,"
		cQry += "        D1_LOCAL"
		cQry += " FROM " + RetSqlName("SD1") + " D1"
		cQry += " WHERE  D1.D_E_L_E_T_ = ''"
		cQry += "        AND D1.D1_DOC = '" + CABEC->F1_DOC + "'"
		cQry += "        AND D1.D1_SERIE = '" + CABEC->F1_SERIE + "'"
		cQry += "        AND D1.D1_FORNECE = '" + CABEC->F1_FORNECE + "'"
		cQry += "        AND D1.D1_LOJA = '" + CABEC->F1_LOJA + "'"
		cQry += "        AND D1.D1_TIPO = '" + CABEC->F1_TIPO + "'"
		
		If lTabSD1Exc
			cQry += "    AND D1.D1_FILIAL = '" + cFilialD1 + "'"
		Endif
		
		cQry := ChangeQuery(cQry)
		
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),"ITENS",.T.,.T.)
	
		DbSelectArea("ITENS")
		ITENS->(DbGotop())
		While ITENS->(!EOF())
			aAdd(aItens,{ITENS->D1_ITEM,ITENS->D1_COD,ITENS->D1_UM,ITENS->D1_QUANT,ITENS->D1_VUNIT,ITENS->D1_TOTAL,ITENS->D1_LOCAL})
			ITENS->(DbSkip())
		Enddo
		
		ITENS->(DbCloseArea())
		
		//Rateio Centro de Custo
		cQry := " SELECT DE_ITEMNF,"
		cQry += "        DE_CC,"
		cQry += "        Sum(DE_PERC) AS PERC"
		cQry += " FROM " + RetSqlName("SDE") + " DE"
		cQry += " WHERE  DE.D_E_L_E_T_ = ''"
		cQry += "        AND DE.DE_DOC = '" + CABEC->F1_DOC + "'"
		cQry += "        AND DE.DE_SERIE = '" + CABEC->F1_SERIE + "'"
		cQry += "        AND DE.DE_FORNECE = '" + CABEC->F1_FORNECE + "'"
		cQry += "        AND DE.DE_LOJA = '" + CABEC->F1_LOJA + "'"
		
		If lTabSDEExc
			cQry += "    AND DE.DE_FILIAL = '" + cFilialDE + "'"
		Endif
		
		cQry += " GROUP  BY DE.DE_ITEMNF,"
		cQry += "           DE.DE_CC"
		
		cQry := ChangeQuery(cQry)
		
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),"RATCC",.T.,.T.)
		
		DbSelectArea("RATCC")
		RATCC->(DbGotop())
		While RATCC->(!EOF())
			aAdd(aRatCC,{RATCC->DE_CC,RATCC->PERC,RATCC->DE_ITEMNF})
			RATCC->(DbSkip())
		Enddo
		
		RATCC->(DbCloseArea())
		
		//Rateio Projeto
		cQry := " SELECT AFN_COD,"
		cQry += "        AFN_PROJET,"
		cQry += "        AFN_TAREFA,"
		cQry += "        AFN_QUANT,"
		cQry += "        AFN_REVISA"
		cQry += " FROM " + RetSqlName("AFN") + " AFN"
		cQry += " WHERE  AFN.D_E_L_E_T_ = ''"
		cQry += "        AND AFN.AFN_DOC = '" + CABEC->F1_DOC + "'"
		cQry += "        AND AFN.AFN_SERIE = '" + CABEC->F1_SERIE + "'"
		cQry += "        AND AFN.AFN_FORNEC = '" + CABEC->F1_FORNECE + "'"
		cQry += "        AND AFN.AFN_LOJA = '" + CABEC->F1_LOJA + "'"
		
		If lTabAFNExc
			cQry += "    AND AFN.AFN_FILIAL = '" + cFilialAFN + "'"
		Endif
		
		cQry += " GROUP BY AFN_COD,"
		cQry += "          AFN_PROJET,"
		cQry += "          AFN_TAREFA,"
		cQry += "          AFN_QUANT,"
		cQry += "          AFN_REVISA"		
		
		cQry := ChangeQuery(cQry)
		
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),"RATPRJ",.T.,.T.)
		
		DbSelectArea("RATPRJ")
		RATPRJ->(DbGotop())
		While RATPRJ->(!EOF())
			aAdd(aRatPrj,{RATPRJ->AFN_PROJET,RATPRJ->AFN_TAREFA,RATPRJ->AFN_QUANT,RATPRJ->AFN_COD,RATPRJ->AFN_REVISA})
			RATPRJ->(DbSkip())
		Enddo
		
		RATPRJ->(DbCloseArea())
		
		If Len(aItens) > 0
			aAdd(aRet,{CABEC->F1_DOC,CABEC->F1_SERIE,CABEC->F1_EMISSAO,CABEC->F1_FORNECE+"|"+CABEC->F1_LOJA,CABEC->F1_TIPO,CABEC->F1_VALBRUT,cSituacao,aItens,aRatCC,aRatPrj,aPCInfo[nI],CABEC->F1_CHVNFE})
		Endif
		
		aItens		:= {}
		aRatCC		:= {}
		aRatPrj	:= {}
		CABEC->(DbSkip())
	Enddo
	
	CABEC->(DbCloseArea())

Next nI

RestArea(aAreaSF1)
RestArea(aAreaSD1)
RestArea(aAreaSDE)
RestArea(aAreaAFN)

Return aRet

/*/{Protheus.doc} A110BSITUACA()
Busca situação da SA/SC/CO/PC/NF

@param	cTipo		Tipo do documento
@param	cNumero	Numero da SA/SC/CO/PC/NF 

@author Rodrigo M. Pontes
@since 29/08/2016
@version 11
/*/

Static Function A110BSITUACA(cTipo,cNumero)

Local lPrjCni		:= ValidaCNI()
Local lAProvSI	:= GetNewPar("MV_APROVSI",.F.)
Local lMkPlace	:= SuperGetMv("MV_MKPLACE",.F.,.F.)
Local cTpCto		:= Iif(lPrjCni,GETMV("MV_TPSCCT"),'')
Local cRet			:= ""

If cTipo == "SA" //Solicitação Armazem
	cQry := " SELECT CP_NUM,"
	cQry += "        CP_PREREQU,"
	cQry += "        CP_STATSA"
	cQry += " FROM " + RetSqlName("SCP") + " CP"
	cQry += " WHERE  CP.D_E_L_E_T_ = ''"
	cQry += "        AND CP.CP_NUM = '" + cNumero + "'"
	
	If A110BTABEXC("SCP")
		cQry += "    AND CP_FILIAL = '" + xFilial("SCP") + "'"
	Endif
	
	cQry += " GROUP  BY CP.CP_NUM,"
	cQry += "           CP.CP_PREREQU,"
	cQry += "           CP.CP_STATSA" 
	
	cQry := ChangeQuery(cQry)
		
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),"SIT",.T.,.T.)
	
	DbSelectArea("SIT")
	If SIT->(!EOF())
		If !Empty(SIT->CP_PREREQU) .And. SIT->CP_STATSA <> 'B'
			cRet := STR0001 //"Pré-requisição gerada"
		Elseif Empty(SIT->CP_PREREQU) .And. SIT->CP_STATSA <> 'B'
			cRet := STR0002 //"Gerar pré-requisição"
		Elseif SIT->CP_STATSA == 'B'
			cRet := STR0003 //"SA bloqueada"
		Elseif SIT->CP_STATSA == 'R'
			cRet := "SA Rejeitada"
		Endif
	Endif
	SIT->(DbCloseArea())

ElseIf cTipo == "BX" //Baixas
	cQry := " SELECT Sum(CP_QUANT) AS CP_QUANT,"
	cQry += " 		   Sum(CP_QUJE)  AS CP_QUJE"
	cQry += " FROM " + RetSqlName("SCP")
	cQry += " WHERE  D_E_L_E_T_ = ''"
	cQry += "        AND CP_NUM = '" + cNumero + "'"
	
	If A110BTABEXC("SCP")
		cQry += "    AND CP_FILIAL = '" + xFilial("SCP") + "'"
	Endif
	
	cQry := ChangeQuery(cQry)
		
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),"SIT",.T.,.T.)
	
	DbSelectArea("SIT")
	If SIT->(!EOF())
		If SIT->CP_QUANT == SIT->CP_QUJE
			cRet := STR0043 //"Baixada"
		Elseif SIT->CP_QUJE == 0
			cRet := STR0044 //"Aberto"
		Else
			cRet := STR0045 //"Parcialmente Baixado"
		Endif
	Endif
	SIT->(DbCloseArea())

Elseif cTipo == "SC" //Solicitação de compras
	cQry := " SELECT C1_PEDIDO,"
	cQry += "        C1_ACCPROC,"
	cQry += "        C1_RESIDUO,"
	cQry += "        C1_COMPRAC,"
	cQry += "        C1_APROV,"
	
	If lPrjCni
		cQry += "        C1_XCLASSI,"
		cQry += "        C1_XSTGCT,"
		cQry += "        C1_XTIPOSC,"
	Endif
	
	cQry += "        C1_FLAGGCT,"
	cQry += "        Sum(C1_QUJE)  AS C1_QUJE,"
	cQry += "        Sum(C1_QUANT) AS C1_QUANT,"
	cQry += "        C1_TIPO,"
	cQry += "        C1_COTACAO,"
	cQry += "        C1_TPSC,"
	cQry += "        C1_IMPORT,"
	cQry += "        C1_CODED"
	cQry += " FROM " + RetSqlName("SC1")
	cQry += " WHERE  D_E_L_E_T_ = ''"
	cQry += "        AND C1_NUM = '" + cNumero + "'"
	
	If A110BTABEXC("SC1")
		cQry += "    AND C1_FILIAL = '" + xFilial("SC1") + "'"
	Endif	
	
	cQry += " GROUP  BY C1_PEDIDO,"
	cQry += "           C1_ACCPROC,"
	cQry += "           C1_RESIDUO,"
	cQry += "           C1_COMPRAC,"
	cQry += "           C1_APROV,"
	
	If lPrjCni
		cQry += "        C1_XCLASSI,"
		cQry += "        C1_XSTGCT,"
		cQry += "        C1_XTIPOSC,"
	Endif
	
	cQry += "           C1_FLAGGCT,"
	cQry += "           C1_TIPO,"
	cQry += "           C1_COTACAO,"
	cQry += "           C1_TPSC,"
	cQry += "           C1_IMPORT,"
	cQry += "           C1_CODED"
	
	cQry := ChangeQuery(cQry)
		
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),"SIT",.T.,.T.)
	
	DbSelectArea("SIT")
	If SIT->(!EOF())
		If SIT->C1_ACCPROC == "1" .And. SIT->C1_PEDIDO == Space(Len(SIT->C1_PEDIDO))
			cRet := STR0025 //"Solicitação Pendente (MarketPlace)"
		Elseif (SIT->C1_ACCPROC == "1" .Or. SIT->C1_ACCPROC == "2") .And. SIT->C1_PEDIDO == Space(Len(SIT->C1_PEDIDO)) .And. SIT->C1_COTACAO <> Space(Len(SIT->C1_COTACAO))
			cRet := STR0026 //"Solicitação em Processo de Cotação (MarketPlace)"
		Elseif SIT->C1_RESIDUO == "S" .And. SIT->C1_COMPRAC == "1"
			cRet := STR0027 //"SC em Compra Centralizada"
		Elseif lPrjCni .And. SIT->C1_XCLASSI .And. SIT->C1_APROV == "B"
			cRet := STR0028 //"Integracao com o modulo de Gestao de Contratos"
		Elseif lPrjCni .And. Empty(SIT->C1_RESIDUO) .And. SIT->C1_XSTGCT == "1" .And. SIT->C1_APROV $ " ,L" .And. SIT->C1_XTIPOSC == "'" + cTpCto + "'"
			cRet := STR0029 //"Solicitação para licitação "
		Elseif lPrjCni .And. Empty(SIT->C1_RESIDUO) .And. SIT->C1_XSTGCT == "2" .And. SIT->C1_APROV $ " ,L" .And. SIT->C1_XTIPOSC == "'" + cTpCto + "'" 
			cRet := STR0030 //"Solicitação em processo de edital "
		Elseif SIT->C1_FLAGGCT == "1" .And. SIT->C1_QUJE < SIT->C1_QUANT
			cRet := STR0031 //"SC Totalmente Atendida pelo SIGAGCT"
		Elseif SIT->C1_TIPO == 2
			cRet := STR0032 //"Solicitacao de Importação"
		Elseif !Empty(SIT->C1_RESIDUO)
			cRet := STR0033 //"SC Eliminada por Residuo"
		Elseif SIT->C1_QUJE == SIT->C1_QUANT
			cRet := STR0034 //"SC com Pedido Colocado"
		Elseif SIT->C1_TPSC == "2" .And. SIT->C1_QUJE == 0 .And. !Empty(SIT->C1_CODED)
			cRet := STR0040 //"Solicitação em Processo de Edital"			
		Elseif SIT->C1_QUJE == 0 .And. SIT->C1_APROV $ " ,L" .And. ((SIT->C1_COTACAO == Space(Len(SIT->C1_COTACAO)) .And. SIT->C1_TPSC == "2") .Or. (SIT->C1_COTACAO == "ANALIS"))
			cRet := STR0035 //"Solicitacao para Licitacao"
		Elseif lPrjCni .And. SIT->C1_XTIPOSC <> + "'" + cTpCto + "'" .And. SIT->C1_QUJE == 0 .And. SIT->C1_COTACAO == Space(Len(SIT->C1_COTACAO)) .And. SIT->C1_APROV $ " ,L"
			cRet := STR0036 //"SC em Aberto"
		Elseif SIT->C1_QUJE == 0 .And. SIT->C1_COTACAO == Space(Len(SIT->C1_COTACAO)) .And. SIT->C1_APROV $ " ,L"
			cRet := STR0036 //"SC em Aberto"
		Elseif lAprovSI .And. SIT->C1_QUJE == 0 .And. (SIT->C1_COTACAO == Space(Len(SIT->C1_COTACAO)) .Or. SIT->C1_COTACAO == "IMPORT") .And. SIT->C1_APROV == "R"
			cRet := STR0037 //"SC Rejeitada"
		Elseif lAprovSI .And. SIT->C1_QUJE == 0 .And. (SIT->C1_COTACAO == Space(Len(SIT->C1_COTACAO)) .Or. SIT->C1_COTACAO == "IMPORT") .And. SIT->C1_APROV == "B"
			cRet := STR0038 //"SC Bloqueada"
		Elseif SIT->C1_QUJE == 0 .And. SIT->C1_COTACAO == Space(Len(SIT->C1_COTACAO)) .And. SIT->C1_APROV == "R"
			cRet := STR0037 //"SC Rejeitada"
		Elseif SIT->C1_QUJE == 0 .And. SIT->C1_COTACAO == Space(Len(SIT->C1_COTACAO)) .And. SIT->C1_APROV == "B"
			cRet := STR0038 //"SC Bloqueada"
		Elseif SIT->C1_QUJE > 0
			cRet := STR0039 //"SC com Pedido Colocado Parcial"
		Elseif SIT->C1_TPSC != "2" .And. SIT->C1_COTACAO <> Space(Len(SIT->C1_COTACAO)) .And. SIT->C1_IMPORT <> "S"
			cRet := STR0041 //"SC em Processo de Cotacao"
		Elseif lAprovSI .And. SIT->C1_QUJE == 0 .And. SIT->C1_COTACAO <> Space(Len(SIT->C1_COTACAO)) .And. SIT->C1_IMPORT == "S" .And. SIT->C1_APROV $ " ,L"
			cRet := STR0042 //"SC com Produto Importado"
		Elseif SIT->C1_QUJE == 0 .And. SIT->C1_COTACAO <> Space(Len(SIT->C1_COTACAO)) .And. SIT->C1_IMPORT == "S" 
		 	cRet := STR0042 //"SC com Produto Importado"
		Endif	
	Endif
	
	SIT->(DbCloseArea())

Elseif cTipo == "CO" //Cotação

	cQry := " SELECT C8_ACCNUM,"
	cQry += " 		   C8_NUMPED,"
	cQry += " 		   C8_PRECO"
	cQry += " FROM " + RetSqlName("SC8")
	cQry += " WHERE  D_E_L_E_T_ = ''"
	cQry += "        AND C8_NUM = '" + cNumero + "'"
	
	If A110BTABEXC("SC8")
		cQry += "    AND C8_FILIAL = '" + xFilial("SC8") + "'"
	Endif
	
	cQry := ChangeQuery(cQry)
		
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),"SIT",.T.,.T.)
	
	DbSelectArea("SIT")
	If SIT->(!EOF())
		If !Empty(SIT->C8_ACCNUM) .And. Empty(SIT->C8_NUMPED)
			cRet := "Cotação em compra através do portal ACC"
		Elseif !(!Empty(SIT->C8_ACCNUM) .And. Empty(SIT->C8_NUMPED)) .And. Empty(SIT->C8_NUMPED) .And. SIT->C8_PRECO <> 0
			cRet := "Cotação em aberto"
		Elseif !Empty(SIT->C8_NUMPED)
			cRet := "Cotação baixada"
		Elseif !(!Empty(SIT->C8_ACCNUM) .And. Empty(SIT->C8_NUMPED)) .And. SIT->C8_PRECO == 0 .And. Empty(SIT->C8_NUMPED)
			cRet := "Cotação não digitada"
		Endif
	Endif
	SIT->(DbCloseArea())

Elseif cTipo == "PC" // Pedido de compra
	
	cQry := " SELECT C7_TIPO,"
	cQry += "        C7_RESIDUO,"
	cQry += "        C7_ACCPROC,"
	cQry += "        C7_ACCNUM,"
	cQry += "        C7_CONAPRO,"
	cQry += "        Sum(C7_QUJE)  AS C7_QUJE,"
	cQry += "        Sum(C7_QUANT) AS C7_QUANT,"
	cQry += "        C7_CONTRA,"
	cQry += "        C7_QTDACLA"
	cQry += " FROM " + RetSqlName("SC7")
	cQry += " WHERE  D_E_L_E_T_ = ''"
	cQry += "        AND C7_NUM = '" + cNumero + "'"
	
	If A110BTABEXC("SC7")
		cQry += "    AND C7_FILIAL = '" + xFilial("SC7") + "'"
	Endif
	
	cQry += " GROUP  BY C7_TIPO,"
	cQry += "           C7_RESIDUO,"
	cQry += "           C7_ACCPROC,"
	cQry += "           C7_ACCNUM,"
	cQry += "           C7_CONAPRO,
	cQry += "           C7_CONTRA,
	cQry += "           C7_QTDACLA
	
	cQry := ChangeQuery(cQry)
		
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),"SIT",.T.,.T.)
		
	DbSelectArea("SIT")
	If SIT->(!EOF())
		If SIT->C7_TIPO <> 1
			cRet := STR0016 //"Autorizacao de Entrega ou Pedido"
		Elseif !Empty(SIT->C7_RESIDUO)
			cRet := STR0017 //"Eliminado por Residuo"
		Elseif SIT->C7_ACCPROC <> "1" .And. SIT->C7_CONAPRO == "B" .And. SIT->C7_QUJE < SIT->C7_QUANT
			cRet := STR0018 //"Bloqueado"
		Elseif SIT->C7_ACCPROC <> "1" .And. SIT->C7_CONAPRO == "R" .And. SIT->C7_QUJE < SIT->C7_QUANT
			cRet := STR0018 //"Bloqueado"
		Elseif !Empty(SIT->C7_CONTRA) .And. Empty(SIT->C7_RESIDUO)
			cRet := STR0019 //"Integracao com o Modulo de Gestao de Contratos"
		Elseif lMkPlace .And. SIT->C7_ACCPROC == "1"
			cRet := STR0020 //"Integracao com o portal marketplace"
		Elseif lMkPlace .And. SIT->C7_ACCPROC == "2" .And. !Empty(SIT->C7_ACCNUM) .And. SIT->C7_QUJE == 0 .And. SIT->C7_QTDCLA == 0
			cRet := "Aprovado pelo fornecedor (Marketplace)" 
		Elseif SIT->C7_QUJE == 0 .And. SIT->C7_QTDACLA == 0
			cRet := STR0021 //"Pendente"
		Elseif SIT->C7_QUJE <> 0 .And. SIT->C7_QUJE < SIT->C7_QUANT
			cRet := STR0022 //"Pedido Parcialmente Atendido"
		Elseif SIT->C7_QUJE >= SIT->C7_QUANT
			cRet := STR0023 //"Pedido Atendido"
		Elseif SIT->C7_QTDACLA > 0
			cRet := STR0024 //"Pedido Usado em Pre-Nota"
		Endif
	Endif
	
	SIT->(DbCloseArea())
Endif

Return cRet

/*/{Protheus.doc} A110BTABEXC(cTab)
	Dados do pedido de compra ou venda

	@param	cTab		Alias da tabela

	@retorno lRet		.T. - Se for exclusiva, .F. - compartilhado

	@author	Rodrigo Machado Pontes
	@version	P11
	@since	19/03/2013
/*/

Static Function A110BTABEXC(cTab)

Local lRet	:= .F.

If FWModeAccess(cTab,1) == "E" .Or. FWModeAccess(cTab,2) == "E" .Or. FWModeAccess(cTab,3) == "E"
	lRet := .T.
Endif

Return lRet

/*/{Protheus.doc} A110BXMLIT(aItens,aRatCC,aRatPrj,cFilRast)
	Dados da solicitação de armazem (ou baixa) ou compra

	@param	aItens		Itens a serem informados
	@param aRatCC   	Rateio por centro de custo a ser informado
	@param	aRatPrj   	Rateio por projeto a ser informado
	@param	cFilRast  	Filial para rastrear

	@retorno cRet		XML formatado

	@author	Rodrigo Machado Pontes
	@version	P11
	@since	24/03/2013
/*/

Function A110BXMLIT(aItens,aRatCC,aRatPrj,cTipo,cNum,cSer,cFor,cLoj,dEmissao)

Local cRet		:= ""
Local nK		:= 0
Local nY		:= 0

If Len(aItens) > 0
	cRet += 	'<ListOfItem>'
	For nK	:= 1 To Len(aItens)
    	cRet += 		'<Item>'
    	
    	If cTipo == "SA" .Or. cTipo == "BX"
    	  	cRet += 			'<InternalId>' + IntSArExt(,,cNum,aItens[nK,1],dEmissao)[2] + '</InternalId>'
    	Elseif cTipo == "SC"
    		cRet += 			'<InternalId>' + IntSCoExt(,,cNum,aItens[nK,1])[2] + '</InternalId>'
    	Elseif cTipo == "CO"
    		cRet += 			'<InternalId>' + AllTrim(cEmpAnt) + '|' + AllTrim(xFilial("SC8")) + '|' + AllTrim(cNum) + '|' + AllTrim(aItens[nK,1]) + '</InternalId>'
    	Elseif cTipo == "PC"
    		cRet += 			'<InternalId>' + IntPdCExt(,,cNum,aItens[nK,1])[2] + '</InternalId>'
    	Elseif cTipo == "NFE"
    		cRet += 			'<InternalId>' + IntInvExt(,,cNum,cSer,cFor,cLoj,aItens[nK,2],aItens[nK,1])[2] + '</InternalId>'
    	Endif

    	cRet += 			'<Number>' + AllTrim(aItens[nK,1]) + '</Number>'
    	cRet += 			'<ItemInternalId>' + IntProExt(,,aItens[nK,2])[2] + '</ItemInternalId>'
    	cRet += 			'<UnitofMeasureInternalId>' + IntUndExt(,,aItens[nK,3])[2] + '</UnitofMeasureInternalId>'
    	cRet += 			'<Quantity>' + AllTrim(cValToChar(aItens[nK,4])) + '</Quantity>'
    	cRet += 			'<UnitPrice>' + AllTrim(cValToChar(aItens[nK,5])) + '</UnitPrice>'
    	cRet += 			'<TotalPrice>' + AllTrim(cValToChar(aItens[nK,6])) + '</TotalPrice>'
    	cRet += 			'<WarehouseInternalId>' + IntLocExt(,,aItens[nK,7])[2] + '</WarehouseInternalId>'
    	
    	If Len(aRatCC) > 0
    		cRet += 			'<ListOfApportionCost>'
    		For nY := 1 to Len(aRatCC)
    			If AllTrim(aItens[nK,1]) == AllTrim(aRatCC[nY,3])
    				cRet += 			'<ApportionCost>'
    				
    				If cTipo == "SA" .Or. cTipo == "BX"
			    	  	cRet += 			'<InternalId>' + IntSArExt(,,cNum,aRatCC[nY,3],dEmissao)[2] + '</InternalId>'
			    	Elseif cTipo == "SC"
			    		cRet += 			'<InternalId>' + IntSCoExt(,,cNum,aRatCC[nY,3])[2] + '</InternalId>'
			    	Elseif cTipo == "CO"
			    		cRet += 			'<InternalId>' + AllTrim(cEmpAnt) + '|' + AllTrim(xFilial("SC8")) + '|' + AllTrim(cNum) + '|' + AllTrim(aRatCC[nY,3]) + '</InternalId>'
			    	Elseif cTipo == "PC"
			    		cRet += 			'<InternalId>' + IntPdCExt(,,cNum,aRatCC[nY,3])[2] + '</InternalId>'
			    	Elseif cTipo == "NFE"
			    		cRet += 			'<InternalId>' + IntInvExt(,,cNum,cSer,cFor,cLoj,aItens[nK,2],aRatCC[nY,3])[2] + '</InternalId>'
			    	Endif
    				
      				cRet += 				'<CostCenterInternalId>' + IntCusExt(,,aRatCC[nY,1])[2] + '</CostCenterInternalId>'
      				cRet += 				'<Percentual>' + AllTrim(cValToChar(aRatCC[nY,2])) + '</Percentual>'
      				cRet += 			'</ApportionCost>'
      			Endif
      		Next nY
      		cRet += 			'</ListOfApportionCost>'
      	Else
      		cRet += 			'<ListOfApportionCost/>'
      	Endif
      	
      	If Len(aRatPrj) > 0
      		cRet += 			'<ListOfApportionTask>'
      		For nY := 1 to Len(aRatPrj)
      			If AllTrim(aItens[nK,2]) == AllTrim(aRatPrj[nY,4])
      				cRet += 			'<ApportionTask>'
      				cRet += 				'<InternalId>' + IntProExt(,,aRatPrj[nY,4])[2] + '</InternalId>'
      				cRet += 				'<ProjectInternalId>' + IntPrjExt(,,aRatPrj[nY,1])[2] + '</ProjectInternalId>'
      				cRet += 				'<SubProjectInternalId></SubProjectInternalId>'
      				cRet += 				'<TaskInternalId>' + IntTrfExt(,,aRatPrj[nY,1],aRatPrj[nY,5],aRatPrj[nY,2])[2] + '</TaskInternalId>'
      				cRet += 				'<Quantity>' + AllTrim(cValToChar(aRatPrj[nY,3])) + '</Quantity>'
      				cRet += 			'</ApportionTask>'
      			Endif
      		Next nY
      		cRet += 			'</ListOfApportionTask>'
   		Else
   			cRet += 			'<ListOfApportionTask/>'
   		Endif
		cRet += 		'</Item>'
    Next nK
  	cRet += 	'</ListOfItem>'
Else
	cRet += 	'<ListOfItem/>'
Endif

Return cRet 
