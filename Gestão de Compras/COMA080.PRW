#Include "Protheus.Ch"
#Include "COMA080.Ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCOMA080   บAutor  ณTiago Tudisco       บ Data ณ  02/05/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRegistrar o tempo entre  os processos de solicitacoes de	  บฑฑ
ฑฑบ          ณcompra ate a conclusao do processo.                         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณCNI                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿

Alterado por Rodrigo Guerato
Data: 08/11/2012
*/
Function COMA080(cNumSC,cItemSC,cTabela,aChave,campoDt,campoUser, lEstorno, cUser, cCampoDoc, cNumDoc, cItemPed, cFilTrans)
	Local aArea	:= GetArea()		
	Local cDtHora         
	Local cChave	:= ''
	Local nX      := 0     
	Local lHabLog := GetMV("MV_HABLOG") //Parametro para habilitar ou nao a gravacao do log                         
	Local lRet		:= .T.
	Local cItLog
	Local nTamItSC := TamSX3("COH_ITEM")[1]
	Local nTamItPC := TamSX3("COH_ITPED")[1]
	Local nTamItCOI:= TamSX3("COI_ITEM")[1]
	Local nTamItCOK:= TamSX3("COK_ITEM")[1]

	Default lEstorno  := .F.
	Default cUser     := CUSERNAME
	Default cNumDoc   := ""
	Default cItemPed  := ""
	Default cFilTrans := "" 
	SET DATE FORMAT TO "dd/mm/yyyy"	//Ajusta formato da data p/ gravar log
	
	If lEstorno
		Return COMA080Del(cNumSC,cItemSC,cTabela,aChave,campoDt,campoUser, cCampoDoc)
	End If
	
	cDtHora := DtoC(Date()) + ' ' + Time() //Caio.Santos - FSW - 06/02/2012 - Correcao na gravacao da data
	
	For nX := 1 to Len(aChave)
		If Empty(cChave)
			cChave := aChave[nX]		
		else
			cChave += aChave[nX]		
		Endif	
	Next nX

	Do While lHabLog	   	
	   	//Verifica se o campo existe
		SX3->(dbSetOrder(2))//X3_CAMPO
		If !SX3->(dbSeek(campoDt))
			lRet := .F.  
			MsgAlert(STR0001+campoDt) //"Nใo serแ gravado log de refer๊ncia, pois o campo de refer๊ncia nใo existe: "
			Exit
		EndIF
		
		//Seleciona a tabela para que a mesmo seja criada
		dbSelectArea(cTabela)


		//Verifico qual tabela deve ser atualizada
		Do Case
			Case AllTrim(cTabela) == "COI"
				//Verifico se esta no inicio do Fluxo (Solicita็ใo)
				If (campoDt == 'COI_DTHSOL')
					If &(cTabela)->(dbSeek(xFilial(cTabela) + cNumSC + RIGHT(cItemSC,nTamItCOI) + cChave)) //NumSC+Item + Chave em branco
						lRet := .F.
						Exit
					EndIf
					
					RecLock(cTabela,.T.)
				   
					COI->COI_FILIAL := xFilial(cTabela)
					COI->COI_NUMSC  := cNumSC
					COI->COI_ITEM   := RIGHT(cItemSC,nTamItCOI)
					COI->COI_DTHSOL := cDtHora
					COI->COI_USOL   := cUser
					COI->COI_DOCSC  := cNumDoc
				  
					MsUnlock(cTabela)
					Exit
				Else
					If !(&(cTabela)->(dbSeek(xFilial(cTabela)+ cNumSC + RIGHT(cItemSC,nTamItCOI) + cChave)))
						lRet :=.F.  
						If (campoDt != 'COI_DTHCOT')
							MsgAlert(STR0002 + cNumSC +" / "+ cItemSC) //"Nใo serแ gravado log de refer๊ncia, pois a Solicitacao/Item nใo existe: "
						EndIf
						Exit
					Endif

					If (campoDt == 'COI_DTHAPR').And.(!Empty(COI->COI_DTHCOT))
						lRet :=.F.
						Exit
					EndIf
					
					RecLock(cTabela,.F.)
					If !Empty(campoDt)
						COI->(&(campoDt)) := cDtHora //macro substituicao
					EndIf
					
					If !Empty(campoUser)
						COI->(&(campoUser)) := cUser //Caio.Santos - FSW - 08/02/2012 - Correcao na gravacao usuario workflow
					EndIf
					
					If !Empty(cCampoDoc)
						COI->(&(cCampoDoc)) := cNumDoc
					EndIf
					//Rodrigo Guerato - FSW - Incluido o tratamento para gerar o restante dos campos no caso de transferencia
					If campoDt == "COI_DTHTRA"
						//Grava o Item e a Filia de destino
						COI->COI_ITTRA  := cItemPed //aproveito o mesmo parametro
						COI->COI_FILTRA := cFilTrans 
					EndIf 
					MsUnlock(cTabela)
					Exit
				Endif    
			Case AllTrim(cTabela) == "COK"
			
				COK->(dbSetOrder(0))	
			
				//Posiciona na ๚ltima posi็ใo fํsica para atualizar o log
				COK->(DbGoBottom())
				//Inicia o campo de log se estiver vazio ou atualiza
				If Empty( COK->COK_ITLOG )
					cItLog := STRZERO (1, TamSX3("COK_ITLOG")[1] )
				Else
					cItLog := Soma1(COK->COK_ITLOG)
				EndIf
				
				COK->(dbSetOrder(1))
				
				If (campoDt != "COK_DTHATL") .And. (Empty(SC7->C7_NUMCOT) .Or. !Empty(SC7->C7_CONTRA) .And. Empty(CN9->CN9_NUMCOT))
						COK->(dbSetOrder(2))
						cChave := PadR(aChave[1],TamSX3("COK_DOCPED")[1]) + aChave[2]
				Endif
			
				//Verifico se esta no inicio do Fluxo (Atuali็ใo)
				If (campoDt == 'COK_DTHATL')
					If &(cTabela)->(dbSeek(xFilial(cTabela)+ cNumSC + RIGHT(cItemSC,nTamItCOK) + cChave)) //NumSC+Item+
						lRet := .F.
						Exit
					EndIf
						
					RecLock(cTabela,.T.)
					COK->COK_FILIAL := xFilial(cTabela)
					COK->COK_NUMSC  := cNumSC
					COK->COK_ITEM   := RIGHT(cItemSC,nTamItCOK)
					COK->COK_FORNEC := aChave[1]
					COK->COK_LOJA   := aChave[2]
					COK->COK_DTHATL := cDtHora 
					COK->COK_UATL   := cUser
					COK->COK_DOCATL := cNumDoc
					COK->COK_ITLOG  := cItLog
					
					(cTabela)->(MsUnlock())
					Exit
				Else
					if (campoDt = "COK_DTHPED")
						if Len(aChave) == 4
							cChave := aChave[1] + aChave[2] + PadR(aChave[3],TamSX3("COK_DOCPED")[1]) + aChave[4]
						Endif
						
						//+---------------------------------------------------------------+
						//|Tratamento para localizar o registro em casos de medicao       |
						//|dos contratos, onde posso ter varios pedidos para o mesmo Forn |
					   //+---------------------------------------------------------------+  
						
						if &(cTabela)->(dbSeek(xFilial(cTabela)+ cNumSC + RIGHT(cItemSC,nTamItCOK) + cChave)) .Or. !&(cTabela)->(dbSeek(xFilial(cTabela)+cChave))
						
							//Grava o Log
							RecLock(cTabela,.T.)
		
							COK->COK_FILIAL := xFilial(cTabela)
							COK->COK_NUMSC  := cNumSC
							COK->COK_ITEM   := RIGHT(cItemSC,nTamItCOK)
							COK->COK_FORNEC := SC7->C7_FORNECE			//aChave[1]			//iif(Len(aChave) == 2,aChave[1],"") //Gravando direto do pedido de compra
							COK->COK_LOJA   := SC7->C7_LOJA				//aChave[2]			//iif(Len(aChave) == 4,aChave[2],"") //Gravando direto do pedido de compra
							COK->COK_DTHPED := cDtHora 
							COK->COK_UPED   := cUser
							COK->COK_DOCPED := cNumDoc
							COK->COK_ITPED  := cItemPed
							COK->COK_ITLOG  := cItLog 
		
							(cTabela)->(MsUnlock()) 
							
							Exit
		
						Endif
					Else
						// Registro de Log de aprovacao de Pedido de Compra
						If (campoDt = "COK_DTHLIB")
							If !&(cTabela)->(dbSeek(xFilial(cTabela)+ cNumSC + RIGHT(cItemSC,nTamItCOK) + cChave))
						
								RecLock(cTabela,.T.)
			
								COK->COK_FILIAL := xFilial(cTabela)
								COK->COK_NUMSC  := cNumSC
								COK->COK_ITEM   := RIGHT(cItemSC,nTamItCOK)
								COK->COK_FORNEC := SC7->C7_FORNECE			//aChave[1]			//iif(Len(aChave) == 2,aChave[1],"") //Gravando direto do pedido de compra
								COK->COK_LOJA   := SC7->C7_LOJA				//aChave[2]			//iif(Len(aChave) == 4,aChave[2],"") //Gravando direto do pedido de compra
								COK->COK_DTHLIB := cDtHora 
								COK->COK_ULIB   := cUser
								COK->COK_DOCLIB := cNumDoc
								COK->COK_DOCPED := cNumDoc
								COK->COK_ITPED  := cItemPed
								COK->COK_ITLOG  := cItLog
			
								(cTabela)->(MsUnlock()) 
								
								Exit
							Endif
						EndIf
					Endif
					
					If !(&(cTabela)->(dbSeek(xFilial(cTabela)+ cNumSC + RIGHT(cItemSC,nTamItCOK) + cChave))) //NumSC+Item+Fornecedor+Loja
						lRet :=.F.  
						MsgAlert("Nใo serแ gravado log de refer๊ncia, pois a Solicitacao/Item nใo existe: " + cNumSC + " / " + cItemSC)

						Exit
					Endif
						
					/* Comentado para tratamento nos editais 
					If (campoDt == 'COK_DTHPED').And.(Empty(COK->COK_DTHATL))
						lRet :=.F.
						Exit
					EndIf */
						
					RecLock(cTabela,.F.)
					If !Empty(campoDt)
						COK->(&(campoDt)) := cDtHora //macro substituicao
					EndIf
					
					If !Empty(campoUser)
						COK->(&(campoUser)) := cUser //Caio.Santos - FSW - 08/02/2012 - Correcao na gravacao usuario workflow
					EndIf
					
					If !Empty(cCampoDoc)
						COK->(&(cCampoDoc)) := cNumDoc
					EndIf
						
					//Tratamento para Incluir o Item do Pedido sem mudar as estruturas da fun็ใo
					If (campoDt == 'COK_DTHPED').And.(!Empty(cItemPed))
						COK->COK_ITPED := cItemPed //Item do Pedido de Compra
					EndIf
						
					MsUnlock(cTabela)
					Exit
				Endif    
			Case AllTrim(cTabela) == "COH"
				cChave := PadR(aChave[1],TamSX3("COH_DOCPED")[1])+RIGHT(aChave[2],nTamItPC)+aChave[3]
			
				//Verifico se esta no inicio do Fluxo (Pre Nota)
				//ChavePreNota = F1_DOC + F1_SERIE + F1_FORNECE + F1_LOJA + F1_FORMUL
				If (campoDt == 'COH_DTHLPN')
					If &(cTabela)->(dbSeek(xFilial(cTabela)+ cNumSC + RIGHT(cItemSC,nTamItSC) + cChave)) //NumPedido+ItemPedido+ChavePreNota
						lRet := .F.
						Exit
					EndIf
					
					//Nใo permite gravar a Pre-Nota de um pedido que nใo esta na tabela COK
					dbSelectArea("COK")
					dbSetOrder(2) //Filial+DocPed+ItPed
					
					If !COK->(dbSeek(xFilial("COK") + cNumSC + RIGHT(cItemSC,nTamItCOK) + PadR(aChave[1],(TamSX3("COK_DOCPED")[1]))+aChave[2]))

						COK->(dbCloseArea())
						lRet := .F.
						Exit
					Endif
					
					RecLock(cTabela,.T.)
				   
					COH->COH_FILIAL := xFilial(cTabela)
					COH->COH_NUMSC  := cNumSC
					COH->COH_ITEM   := RIGHT(cItemSC,nTamItSC)
					COH->COH_DOCPED := aChave[1]
					COH->COH_ITPED  := RIGHT(aChave[2],nTamItPC)
					COH->COH_PNCHAV := aChave[3]
					COH->COH_DTHLPN := cDtHora
					COH->COH_ULPN   := cUser
				  
					MsUnlock()
					Exit
				Else
					If !(&(cTabela)->(dbSeek(xFilial(cTabela)+cNumSC + RIGHT(cItemSC,nTamItSC) + cChave))) //NumSC+ItemSC+NumPedido+ItemPedido+ChavePreNota
						lRet :=.F.  

						Exit
					Endif

					If (campoDt == 'COH_DTHCLS').And.(Empty(COH->COH_PNCHAV))
						lRet :=.F.
						Exit
					EndIf
					
					RecLock(cTabela,.F.)
					If !Empty(campoDt)
						COH->(&(campoDt)) := cDtHora //macro substituicao
					EndIf
					
					If !Empty(campoUser)
						COH->(&(campoUser)) := cUser //Caio.Santos - FSW - 08/02/2012 - Correcao na gravacao usuario workflow
					EndIf
					
					If !Empty(cCampoDoc)
						COH->(&(cCampoDoc)) := cNumDoc
					EndIf
					
					MsUnlock(cTabela)
					Exit
				Endif    
		EndCase
	EndDo
		
	RestArea(aArea)
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCOMA080EstบAutor  ณFabricio Romera     บ Data ณ  10/13/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Trata log de estornos dos processos de compras.            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function COMA080Del(cNumSC,cItemSC,cTabela,aChave,cCpoDt,cCpoUser,cCampoDoc)
	Local lRet   := .T.
	Local nX     := 0
	Local aArea  := GetArea()
	Local cChave := ""     
	Local lFlag  := .T.
	Local nTamItSC := TamSX3("COH_ITEM")[1]
	Local nTamItPC := TamSX3("COH_ITPED")[1]
	Local nTamItCOI:= TamSX3("COI_ITEM")[1]
	Local nTamItCOK:= TamSX3("COK_ITEM")[1]

	For nX := 1 to Len(aChave)
		If Empty(cChave)
			cChave := aChave[nX]		
		else
			cChave += aChave[nX]		
		Endif
	Next nX
	
	Do Case
		Case AllTrim(cTabela) == "COI"
			COI->(DbSetOrder(1))
			If !COI->(DbSeek(xFilial("COI")+ cNumSC + RIGHT(cItemSC,nTamItCOI) + cChave)) //NumSC+ItemSC
				Return .F.
			EndIf
			
			//Verifico se esta no inicio do Fluxo
			If cCpoDt = "COI_DTHSOL"
				//Exclui registro
				RecLock("COI",.F.)
				COI->(dbDelete())				
				MsUnlock("COI")
			Else	
				//Limpa os campos
				RecLock("COI",.F.)
				If !Empty(cCpoDt)
					COI->&(cCpoDt)   := ""
				EndIf
				
				If !Empty(cCpoUser)
					COI->&(cCpoUser) := ""
				EndIf
				
				If !Empty(cCampoDoc)
					COI->&(cCampoDoc) := "" 
				EndIf
				
				//Tratamento para os casos de transferencia
				If cCpoDt == "COI_DTHTRA"
					COI->COI_ITTRA  := ""
					COI->COI_FILTRA := "" 
				EndIf
				
				MsUnlock("COI")
			EndIf
		Case AllTrim(cTabela) == "COK"
			COK->(DbSetOrder(1))     
			
			If (cCpoDt != "COK_DTHATL") .And. (Empty(SC7->C7_NUMCOT) .Or. !Empty(SC7->C7_CONTRA) .And. Empty(CN9->CN9_NUMCOT));
				.Or. (cCpoDt == "COK_DTHPED") .And. !Empty(SC7->C7_NUMCOT)
					COK->(dbSetOrder(2)) //NumSC+ItemSC+Pedido+ItemPedido
				
					//Trata a variavel da chave
					//Caso nใo seja atualiza็ใo a chave ้ o pdido de compra mais o Item do Pedido      
					cChave := PadR(aChave[1], TamSX3("COK_DOCPED")[1]) + aChave[2]
					
			Endif      
			
			if Len(aChave) == 4
				cChave := aChave[1] + aChave[2] + PadR(aChave[3],TamSX3("COK_DOCPED")[1]) + aChave[4]
			//Else
			   //cChave := aChave[1] + aChave[2] //Padrao
			Endif
			
			
			If !COK->(DbSeek(xFilial("COK")+ cNumSC + RIGHT(cItemSC,nTamItCOK) + cChave)) //NumSC+Item+Fornecedor+Loja
				Return .F.
			EndIf
			
			//Verifico se esta no inicio do Fluxo
			If cCpoDt = "COK_DTHATL" .Or. cCpoDt == "COK_DTHPED"
				//Exclui registro
				RecLock("COK",.F.)
				COK->(dbDelete())				
				MsUnlock("COK")
			Else	
				//Limpa os campos
				RecLock("COK",.F.)
				If !Empty(cCpoDt)
					COK->&(cCpoDt)   := ""
				EndIf
				
				If !Empty(cCpoUser)
					COK->&(cCpoUser) := ""
				EndIf
				
				If !Empty(cCampoDoc)
					COK->&(cCampoDoc) := "" 
				EndIf
				
				If cCpoDt = "COK_DTHPED"
					//Limpa o item do Pedido
					COK->COK_ITPED := ""
				Endif   
				
				//Tratamento para excluir a linha em branco 
				For nX := 1 To COK->(FCount())   
					If !(COK->(FieldName(nX)) $ "COK_NUMSC|COK_ITEM|COK_FILIAL")  
						If !Empty(COK->&(FieldName(Nx)))
							lFlag := .F.						
						Endif
					Endif
				Next Nx
				
				If lFlag
					COK->(dbDelete())
				Endif				
				
				MsUnlock("COK")
			EndIf
		Case AllTrim(cTabela) == "COH"
			///tratamento na chave da tabela
			aChave[3] := StrTran(aChave[3]," ")		
			
			cChave := PadR(aChave[1],TamSX3("COH_DOCPED")[1])+RIGHT(aChave[2],nTamItPC)+aChave[3]


			//ChavePreNota = F1_DOC + F1_SERIE + F1_FORNECE + F1_LOJA + F1_FORMUL
			COH->(DbSetOrder(1))
			If !COH->(DbSeek(xFilial("COH")+ cNumSC + RIGHT(cItemSC,nTamItSC) + cChave)) //NumPed+ItemPed+ChavePreNota
				Return .F.
			EndIf
			
			//Verifico se esta no inicio do Fluxo
			If cCpoDt = "COH_DTHLPN"
				//Exclui registro
				RecLock("COH",.F.)
				COH->(dbDelete())				
				MsUnlock("COH")
			Else	
				//Limpa os campos
				RecLock("COH",.F.)
				If !Empty(cCpoDt)
					COH->&(cCpoDt)   := ""
				EndIf
				
				If !Empty(cCpoUser)
					COH->&(cCpoUser) := ""
				EndIf
				
				If !Empty(cCampoDoc)
					COH->&(cCampoDoc) := "" 
				EndIf
				
				MsUnlock("COH")
			EndIf
	EndCase
	
	RestArea(aArea)
Return lRet


////////////////////////////////////////////////////////////////////////////
//ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ//
//ฑฑ Fun็ใo: RSTSCLOG        Autor: Caio Santos        Data: 12.04.2012 ฑฑ//
//ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ//
//ฑฑ Descri็ใo: Rastreia SC de acordo com os fluxos do processo de		  ฑฑ//
//ฑฑ compras para gravar log das opera็๕es.								  ฑฑ//
//ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ//
//ฑฑ Requisito 72 - CNI												         ฑฑ//
//ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ//
////////////////////////////////////////////////////////////////////////////
//ฑฑ Altera็๕es: Rodrigo Guerato - 12/01/2013                           ฑฑ//
////////////////////////////////////////////////////////////////////////////
Function RSTSCLOG(cEtapa,nEvento,cUser,cDados)

Local cAliasSC1 := GetNextAlias()
Local cAliasSD1 := GetNextAlias()
Local aAreas    := {SC1->(GetArea()), SC7->(GetArea()), SC8->(GetArea()), SD1->(GetArea()), CO1->(GetArea()), CO2->(GetArea()), CN9->(GetArea()), CNB->(GetArea()), CNE->(GetArea()), GetArea()}
Local aComa080  := {}   
Local cBusca    := ""
Local cBuscSCOri:= ""   
Local lOrigem   := .F.               //Define se a flial foi localizada atraves da origem
Local cNumPed 	:= ""
Local cItemPed	:= ""
Local cFilCtr	:= ""
Local cContrato := ""
//Variaveis Auxiliares
Local nPos    := 0
Local cFilBkp := cFilAnt //Armazeno a Filial Corrente


//+---------------------------------------------+
//|Tratamento para Compras Compartilhadas       |
//|Procuro em qual filial ocorreu os tramites   |
//+---------------------------------------------+   
If cEtapa $ "PED#LIB"
	SC1->(dbSetOrder(1)) //C1_FILIAL + C1_NUM + C1_ITEM
	If (!Empty(SC7->C7_NUMSC)) .and. (!Empty(SC7->C7_ITEMSC)) .and. (!Empty(SC7->C7_FISCORI))
		If SC1->( dbSeek(SC7->(C7_FISCORI+C7_NUMSC+C7_ITEMSC) ) )
			//Troco para a filial da SC
			cFilAnt := SC1->C1_FILIAL
			SM0->(dbSeek(cEmpAnt+cFilAnt)) //Posiciona no Sigamat por seguran็a
		Endif
	Elseif (!Empty(SC7->C7_FISCORI)) //Verifico novamente, pois na medicao do contrato que veio de cota็ใo eu nใo tenha a SC ainda
		cFilAnt := SC7->C7_FISCORI 
		SM0->(dbSeek(cEmpAnt+cFilAnt)) //Posiciona no Sigamat por seguran็a
	Endif
	
Elseif cEtapa $ "LPN#ATS#CLS"    
	//+-------------------------------------------------------+
	//|Procuro a Origem do Pedido Pode ser FISCORI ou FILENT  |
	//+-------------------------------------------------------+  
	SC7->(dbSetOrder(19)) //C7_FILENT + C7_PRODUTO + C7_NUM + C7_ITEM 
	SC1->(dbSetOrder(1)) //C1_FILIAL + C1_NUM + C1_ITEM

	If SC7->( dbSeek( xFilial("SC7")+SD1->(D1_COD+D1_PEDIDO+D1_ITEMPC) ) )
		If (!Empty(SC7->C7_NUMSC)) .and. (!Empty(SC7->C7_ITEMSC))
			If !Empty(SC7->C7_FISCORI)
				cBusca := SC7->(C7_FISCORI+C7_NUMSC+C7_ITEMSC)
			Else
				cBusca := SC7->(C7_FILIAL+C7_NUMSC+C7_ITEMSC)
			Endif
		
			If SC1->( dbSeek( cBusca ) )
				//Troco para a filial da SC
				cFilAnt := SC1->C1_FILIAL
				SM0->(dbSeek(cEmpAnt+cFilAnt))
				
				If !Empty(SC7->C7_FISCORI)
					lOrigem := .T.				
				Endif 
			Endif
		Endif
	Endif
	
	SC7->(dbSetOrder(1) )
	
Endif

//Tratamento para eventos do processo de compras
Do Case
	Case cEtapa == "SOL"
	
		//Manutencao da SC - MATA110/COMXFUN
		If nEvento == 1
			COMA080(SC1->C1_NUM, SC1->C1_ITEM,"COI",{},"COI_DTHSOL","COI_USOL",/*lEstorno*/,/*cUser*/,"COI_DOCSC",SC1->C1_NUM)
		EndIf
		
		//Exclusao da SC - MATA110
		If nEvento == 2
			COMA080(SC1->C1_NUM, SC1->C1_ITEM,"COI",{},"COI_DTHSOL","COI_USOL",.T.,cUser,"COI_DOCSC")
		EndIf
		
	Case cEtapa == "APR"
	
		//Aprovacao da SC - CWKFA001/MATA110/SICOMA04
		If nEvento == 1
			COMA080(SC1->C1_NUM, SC1->C1_ITEM,"COI",{},"COI_DTHAPR","COI_UAPR",/*lEstorno*/,cUser,"COI_DOCAPR",SC1->C1_NUM)
		EndIf
		
		//Estorno da aprovacao da SC - MATA110
		If nEvento == 2
			BeginSQL Alias cAliasSC1
        		SELECT C1_NUM, C1_ITEM
        		FROM %Table:SC1% SC1
        		WHERE C1_FILIAL = %xFilial:SC1% AND C1_NUM = %Exp:SC1->C1_NUM% AND C1_APROV = 'B' AND SC1.%NotDel%
   			EndSQL
   			
        	(cAliasSC1)->(dbGoTop())
        	While !(cAliasSC1)->(EOF())
	 	    	COMA080((cAliasSC1)->C1_NUM,(cAliasSC1)->C1_ITEM,"COI",{},"COI_DTHAPR","COI_UAPR",.T.,cUser,"COI_DOCAPR")
 		 		(cAliasSC1)->(dbSkip())
 	 		EndDo
 	 		
	 	 	(cAliasSC1)->(dbCloseArea())
		EndIf
		
		//Estorno da aprovacao da SC - SICOMA04
		If nEvento == 3
			COMA080(SC1->C1_NUM,SC1->C1_ITEM,"COI",{},"COI_DTHAPR","COI_UAPR",.T.,cUser,"COI_DOCAPR")
		EndIf
		
	Case cEtapa == "EDT"
	
		//Vinculo de SC com item do edital - CNIXEDIT/GCPA002
		If nEvento == 1
			aComa080 := {}
			COMA080(SC1->C1_NUM,SC1->C1_ITEM,"COI",aComa080,"COI_DTHEDT","COI_UEDT",/*lEstorno*/,/*cUser*/,"COI_DOCEDT",SC1->C1_CODED)
		EndIf
		
		//Desvinculo de SC com item do edital - CNIXEDIT/GCPA002
		If nEvento == 2
			aComa080 := {}
			COMA080(SC1->C1_NUM,SC1->C1_ITEM,"COI",aComa080,"COI_DTHEDT","COI_UEDT",.T.,/*cUser*/,"COI_DOCEDT")
		EndIf
		
	Case cEtapa == "COT"
	
		//Inclusao da Cotacao - MATA130
		If nEvento == 1
			aComa080 := {}
			COMA080(SC1->C1_NUM,SC1->C1_ITEM,"COI",aComa080,"COI_DTHCOT","COI_UCOT",/*lEstorno*/,/*cUser*/,"COI_DOCCOT",SC1->C1_COTACAO)
		EndIf
		
		//Exclusao da Cotacao - COMXFUN
		If nEvento == 2
			aComa080 := {}
			COMA080(SC1->C1_NUM,SC1->C1_ITEM,"COI",aComa080,"COI_DTHCOT","COI_UCOT",.T.,/*cUser*/,"COI_DOCCOT")
			
			//Faz uma query para excluir as cota็๕es do Log
			BeginSQL Alias cAliasSC1
				SELECT SC8.C8_FORNECE, SC8.C8_LOJA
				FROM %Table:SC8% SC8
				WHERE SC8.C8_FILIAL  = %xFilial:SC8%
				  AND SC8.C8_NUMSC   = %Exp:SC1->C1_NUM%
				  AND SC8.C8_PRODUTO = %Exp:SC1->C1_PRODUTO%
				  AND SC8.C8_IDENT   = %Exp:SC1->C1_IDENT%
//				  AND SC8.%NotDel% - No momento da chamada, o registro da esta deletado logicamente
			EndSQL
			
			(cAliasSC1)->(dbGoTop())
			While !(cAliasSC1)->(Eof())
				aComa080 := {(cAliasSC1)->C8_FORNECE,(cAliasSC1)->C8_LOJA}
				COMA080(SC1->C1_NUM,SC1->C1_ITEM,"COK",aComa080,"COK_DTHATL","COK_UATL",.T.,/*cUser*/,"COK_DOCATL")
				
				(cAliasSC1)->(dbSkip())
			EndDo
			(cAliasSC1)->(dbCloseArea())
		EndIf
	
	Case cEtapa == "ATL"               
		//Atualizacao da Cotacao - MATA150
		If nEvento == 1
			BeginSQL Alias cAliasSC1
				SELECT C1_NUM, C1_ITEM
				FROM %Table:SC1% SC1
				WHERE C1_FILIAL = %xFilial:SC1% AND C1_COTACAO = %Exp:SC8->C8_NUM% AND C1_PRODUTO = %Exp:SC8->C8_PRODUTO% AND C1_IDENT = %Exp:SC8->C8_IDENT% AND SC1.%NotDel%
			EndSQL
			(cAliasSC1)->(dbGoTop())
			While !(cAliasSC1)->(EOF())
				aComa080 := {SC8->C8_FORNECE,SC8->C8_LOJA}
				COMA080((cAliasSC1)->C1_NUM,(cAliasSC1)->C1_ITEM,"COK",aComa080,"COK_DTHATL","COK_UATL",/*lEstorno*/,/*cUser*/,"COK_DOCATL",SC8->C8_NUM)
				(cAliasSC1)->(dbSkip())
			EndDo
			(cAliasSC1)->(dbCloseArea())
		EndIf       
		
		//Exclusao da Atualizacao da Cotacao - MATA150
		If nEvento == 2      
			BeginSQL Alias cAliasSC1
				SELECT C1_NUM, C1_ITEM
				FROM %Table:SC1% SC1
				WHERE C1_FILIAL = %xFilial:SC1% AND C1_COTACAO = %Exp:SC8->C8_NUM% AND C1_PRODUTO = %Exp:SC8->C8_PRODUTO% AND C1_IDENT = %Exp:SC8->C8_IDENT% AND SC1.%NotDel%
			EndSQL
			(cAliasSC1)->(dbGoTop())
			While !(cAliasSC1)->(EOF())
				aComa080 := {SC8->C8_FORNECE,SC8->C8_LOJA}
				COMA080((cAliasSC1)->C1_NUM,(cAliasSC1)->C1_ITEM,"COK",aComa080,"COK_DTHATL","COK_UATL",.T.,/*cUser*/,"COK_DOCATL")
				(cAliasSC1)->(dbSkip())
			EndDo
			(cAliasSC1)->(dbCloseArea())
		Endif
	
	Case cEtapa == "ANL"
	
		//Analise da Cotacao - MATA160
		If nEvento == 1
			BeginSQL Alias cAliasSC1
        		SELECT C1_NUM, C1_ITEM
        		FROM %Table:SC1% SC1
        		WHERE C1_FILIAL = %xFilial:SC1% AND C1_COTACAO = %Exp:SC8->C8_NUM% AND SC1.%NotDel%
   			EndSQL
        	(cAliasSC1)->(dbGoTop())
        	While !(cAliasSC1)->(EOF())
        		aComa080 := {}
	 	    	COMA080((cAliasSC1)->C1_NUM,(cAliasSC1)->C1_ITEM,"COI",aComa080,"COI_DTHANL","COI_UANL",/*lEstorno*/,/*cUser*/,"COI_DOCANL",SC8->C8_NUM)
				(cAliasSC1)->(dbSkip())
			EndDo
			(cAliasSC1)->(dbCloseArea())
		EndIf
		
	Case cEtapa == "CTR"     
	
		//Inclusao de contrato via SC - MATA110
		If nEvento == 1
			aComa080 := {}
			
			If(SC1->(FieldPos("C1_XCTADT")) > 0)				
				cContrato := SC1->C1_XCTADT
			Else
				CNB->(DbSetOrder(2))//CNB_FILIAL+CNB_NUMSC+CNB_ITEMSC
				If(CNB->(DbSeek(xFilial("CNB", SC1->C1_FILENT) + SC1->(C1_NUM + C1_ITEM))))			
					cContrato := CNB->CNB_CONTRA
				EndIf
			EndIf
			
			COMA080(SC1->C1_NUM,SC1->C1_ITEM,"COI",aComa080,"COI_DTHCTR","COI_UCTR",/*lEstorno*/,/*cUser*/,"COI_DOCCTR", cContrato)
		EndIf

		//Exclusao de contrato via SC - MATA110
		If nEvento == 2
			aComa080 := {}
			COMA080(SC1->C1_NUM,SC1->C1_ITEM,"COI",aComa080,"COI_DTHCTR","COI_UCTR",.T.,/*cUser*/,"COI_DOCCTR")
		EndIf
		
		//Inclusao de contrato via edital - GCPA013
		If nEvento == 3
			CO2->(dbSetOrder(1))
			If CO2->(dbSeek(xFilial("CO2")+CO1->CO1_CODEDT+CO1->CO1_NUMPRO+CNB->CNB_PRODUT))
				SC1->(dbSetOrder(8))
				If SC1->(dbSeek(xFilial("SC1")+CO2->(CO2_CODEDT+CO2_NUMPRO+CO2_CODPRO)))
					While !SC1->(EOF()) .And. SC1->(C1_FILIAL+C1_CODED+C1_NUMPR+C1_PRODUTO) == CO2->(CO2_FILIAL+CO2_CODEDT+CO2_NUMPRO+CO2_CODPRO)
						//SC->EDT->CT
						//+------------------------------------------------------+
						//|Alterado devido ao processo de compras compartilhadas |
						//+------------------------------------------------------+
						If ( SC1->(C1_NUM+C1_ITEM) == CNB->(CNB_NUMSC+CNB_ITEMSC) ) 					
							aComa080 := {}
							COMA080(SC1->C1_NUM,SC1->C1_ITEM,"COI",aComa080,"COI_DTHCTR","COI_UCTR",/*lEstorno*/,/*cUser*/,"COI_DOCCTR",CNB->CNB_CONTRA)
						Endif						
						
						SC1->(dbSkip())
					EndDo
				EndIf
			EndIf
		EndIf
		
		//Inclusao de contrato via analise de cotacao - CNIA100
		If nEvento == 4
			SC1->(dbSetOrder(5))
			cBusca := xFilial("SC1") + SC8->(C8_NUM+C8_PRODUTO+C8_IDENT)
			If SC1->(dbSeek(cBusca))
				
				cBuscSCOri := SC1->(C1_FISCORI+C1_SCORI+C1_ITSCORI)
				
				While SC1->(!EOF() .And. C1_FILIAL+C1_COTACAO+C1_PRODUTO+C1_IDENT == cBusca)
					aComa080 := {}
					COMA080(SC1->C1_NUM,SC1->C1_ITEM,"COI",aComa080,"COI_DTHCTR","COI_UCTR",/*lEstorno*/,/*cUser*/,"COI_DOCCTR",SC8->C8_NUMCON)					
					SC1->(dbSkip())
				EndDo
				
				If(!Empty(cBuscSCOri))
					SC1->(DbSetOrder(1))//C1_FILIAL+C1_NUM+C1_ITEM+C1_ITEMGRD
					If SC1->(dbSeek(cBuscSCOri))
						If(cFilAnt != SC1->C1_FILENT)
							cFilAnt := SC1->C1_FILENT
						EndIf
						
						While SC1->(!EOF() .And. C1_FILIAL+C1_NUM+C1_ITEM == cBuscSCOri)//Atualiza o Log da SC original						
							aComa080 := {}
							COMA080(SC1->C1_NUM,SC1->C1_ITEM,"COI",aComa080,"COI_DTHCTR","COI_UCTR",/*lEstorno*/,/*cUser*/,"COI_DOCCTR",SC8->C8_NUMCON)					
							SC1->(dbSkip())
						EndDo
						
						cFilAnt := cFilBkp
					EndIf					
				EndIf
			EndIf
		EndIf
		
	Case cEtapa == "PED"              
		nPos := TamSX3("C7_NUM")[1] + 1  //Tamanho do Pedido 
		aComa080 := {SubStr(cDados,1,TamSX3("C7_NUM")[1]), SubStr(cDados,nPos, TamSX3("C7_ITEM")[1])} //Busco os dados do Pedido que esta posicionado
		
		Do Case
		
			Case (nEvento == 1)//Manutencao do PC - MATA120
				CO2->(dbSetOrder(1))
				CNE->(dbSetOrder(1))
				If CO2->(dbSeek(xFilial("CO2")+SC7->(C7_CODED+C7_NUMPR+C7_PRODUTO)))
					SC1->(dbSetOrder(8))
					If SC1->(dbSeek(xFilial("SC1")+CO2->(CO2_CODEDT+CO2_NUMPRO+CO2_CODPRO)))
						While !SC1->(EOF()) .And. SC1->(C1_FILIAL+C1_CODED+C1_NUMPR+C1_PRODUTO) == CO2->(CO2_FILIAL+CO2_CODEDT+CO2_NUMPRO+CO2_CODPRO)
							If ( !Empty(SC7->C7_NUMSC) .and. !Empty(SC7->C7_ITEMSC) )
								If SC7->(C7_NUMSC+C7_ITEMSC) == SC1->(C1_NUM+C1_ITEM)
									//SC->EDT->PC
									COMA080(SC1->C1_NUM,SC1->C1_ITEM,"COK",aComa080,"COK_DTHPED","COK_UPED",/*lEstorno*/,cUser,"COK_DOCPED",cA120Num,SubStr(cDados,nPos, TamSX3("COK_ITPED")[1]))
								Endif
							Else
								//SC->EDT->PC
								COMA080(SC1->C1_NUM,SC1->C1_ITEM,"COK",aComa080,"COK_DTHPED","COK_UPED",/*lEstorno*/,cUser,"COK_DOCPED",cA120Num,SubStr(cDados,nPos, TamSX3("COK_ITPED")[1]))
						 	Endif
						 	
					 		SC1->(dbSkip())
					 	EndDo
					 EndIf
				Elseif !Empty(SC7->C7_NUMCOT)   
					//+----------------------------------------------------------------+
					//| Testes realizados alterando a chamada da funcao RSTSCLOG()     |
					//| A funcao sera chamadao apos a inclusao do cabecalho dos pedido |
					//+----------------------------------------------------------------+
					aComa080 := {SC7->C7_FORNECE,SC7->C7_LOJA} 
					If !Empty(SC7->C7_NUMSC) .AND. !Empty(SC7->C7_ITEMSC)
						//SC->COT-PC				
						COMA080(SC7->C7_NUMSC,SC7->C7_ITEMSC,"COK",aComa080,"COK_DTHPED","COK_UPED",/*lEstorno*/,cUser,"COK_DOCPED",cA120Num,SubStr(cDados,nPos, TamSX3("COK_ITPED")[1]))
					Endif
				Else
					If !Empty(SC7->C7_NUMSC) .AND. !Empty(SC7->C7_ITEMSC)
						//SC->PC
						COMA080(SC7->C7_NUMSC,SC7->C7_ITEMSC,"COK",aComa080,"COK_DTHPED","COK_UPED",/*lEstorno*/,cUser,"COK_DOCPED",cA120Num,SubStr(cDados,nPos, TamSX3("COK_ITPED")[1]))
	 				EndIf
	 			EndIf
		
			Case (nEvento == 2)//Exclusao do PC - MATA120
				CNE->(dbSetOrder(1))
				CO2->(dbSetOrder(1))
				If CNE->(dbSeek(xFilial("CNE", iif(cFilAnt == cFilBkp,cFilAnt,cFilBkp) )+SC7->(C7_CONTRA+C7_CONTREV+C7_PLANILH+C7_MEDICAO)))
					CN9->(dbSetOrder(1))
					CN9->(dbSeek(xFilial("CN9", iif(cFilAnt == cFilBkp,cFilAnt,cFilBkp) )+CNE->(CNE_CONTRA+CNE_REVISA)))
					While !CNE->(EOF()) .And. CNE->(CNE_FILIAL+CNE_CONTRA+CNE_REVISA+CNE_NUMERO+CNE_NUMMED) == SC7->(C7_FILIAL+C7_CONTRA+C7_CONTREV+C7_PLANILH+C7_MEDICAO)
						If CNE->CNE_QUANT > 0 .And. PadL(CNE->CNE_ITEM,TamSX3("C7_ITEM")[1],"0") == SC7->C7_ITEM
							SC1->(dbSetOrder(11))
							CO2->(dbSetOrder(1))
							SC8->(dbSetOrder(3))
							If SC1->(dbSeek(xFilial("SC1")+CNE->(CNE_CONTRA+CNE_PRODUT+"0"+CNE_ITEM)))
								//SC->CT->PC
								COMA080(SC1->C1_NUM,SC1->C1_ITEM,"COK",aComa080,"COK_DTHLIB","COK_ULIB",.T.,cUser,"COK_DOCLIB")
								COMA080(SC1->C1_NUM,SC1->C1_ITEM,"COK",aComa080,"COK_DTHPED","COK_UPED",.T.,cUser,"COK_DOCPED")
					 		ElseIf CO2->(dbSeek(xFilial("CO2")+CN9->(CN9_CODED+CN9_NUMPR)+CNE->CNE_PRODUT))
				    			SC1->(dbSetOrder(8))
								If SC1->(dbSeek(xFilial("SC1")+CO2->(CO2_CODEDT+CO2_NUMPRO+CO2_CODPRO)))
									While !SC1->(EOF()) .And. SC1->(C1_FILIAL+C1_CODED+C1_NUMPR+C1_PRODUTO) == CO2->(CO2_FILIAL+CO2_CODEDT+CO2_NUMPRO+CO2_CODPRO)
										//SC->EDT->CT->PC
										COMA080(SC1->C1_NUM,SC1->C1_ITEM,"COK",aComa080,"COK_DTHLIB","COK_ULIB",.T.,cUser,"COK_DOCLIB")
										COMA080(SC1->C1_NUM,SC1->C1_ITEM,"COK",aComa080,"COK_DTHPED","COK_UPED",.T.,cUser,"COK_DOCPED")
										SC1->(dbSkip())
									EndDo
								EndIf
							ElseIf SC8->(dbSeek(xFilial("SC8")+CN9->CN9_NUMCOT+CNE->CNE_PRODUT))
		 	  						SC1->(dbSetOrder(5))
		 	  						If SC1->(dbSeek(xFilial("SC1")+SC8->(C8_NUM+C8_PRODUTO+C8_IDENT)))
									While !SC1->(EOF()) .And. SC1->(C1_COTACAO+C1_PRODUTO+C1_IDENT) == SC8->(C8_NUM+C8_PRODUTO+C8_IDENT)
										//SC->COT->CT->PC
										COMA080(SC1->C1_NUM,SC1->C1_ITEM,"COK",aComa080,"COK_DTHLIB","COK_ULIB",.T.,cUser,"COK_DOCLIB")
										COMA080(SC1->C1_NUM,SC1->C1_ITEM,"COK",aComa080,"COK_DTHPED","COK_UPED",.T.,cUser,"COK_DOCPED")
										SC1->(dbSkip())
									EndDo
								EndIf
							EndIf
					 	EndIf
						CNE->(dbSkip())
					EndDo
				ElseIf CO2->(dbSeek(xFilial("CO2")+SC7->(C7_CODED+C7_NUMPR+C7_PRODUTO)))
					SC1->(dbSetOrder(8))
					If SC1->(dbSeek(xFilial("SC1")+CO2->(CO2_CODEDT+CO2_NUMPRO+CO2_CODPRO)))
						While !SC1->(EOF()) .And. SC1->(C1_FILIAL+C1_CODED+C1_NUMPR+C1_PRODUTO) == CO2->(CO2_FILIAL+CO2_CODEDT+CO2_NUMPRO+CO2_CODPRO)
							//SC->EDT->PC
							COMA080(SC1->C1_NUM,SC1->C1_ITEM,"COK",aComa080,"COK_DTHLIB","COK_ULIB",.T.,cUser,"COK_DOCLIB")
							COMA080(SC1->C1_NUM,SC1->C1_ITEM,"COK",aComa080,"COK_DTHPED","COK_UPED",.T.,cUser,"COK_DOCPED")
				 	    	SC1->(dbSkip())
				 		EndDo
				 	EndIf
			 	Elseif !Empty(SC7->C7_NUMCOT)
					aComa080 := {SC7->C7_FORNECE,SC7->C7_LOJA} 
					If !Empty(SC7->C7_NUMSC) .AND. !Empty(SC7->C7_ITEMSC)
						//SC->COT->PC
						COMA080(SC7->C7_NUMSC,SC7->C7_ITEMSC,"COK",aComa080,"COK_DTHLIB","COK_ULIB",.T.,cUser,"COK_DOCLIB")
						COMA080(SC7->C7_NUMSC,SC7->C7_ITEMSC,"COK",aComa080,"COK_DTHPED","COK_UPED",.T.,cUser,"COK_DOCPED")
					EndIf
			 	Else
					If !Empty(SC7->C7_NUMSC) .AND. !Empty(SC7->C7_ITEMSC)
						//SC->PC
						COMA080(SC7->C7_NUMSC,SC7->C7_ITEMSC,"COK",aComa080,"COK_DTHLIB","COK_ULIB",.T.,cUser,"COK_DOCLIB")
						COMA080(SC7->C7_NUMSC,SC7->C7_ITEMSC,"COK",aComa080,"COK_DTHPED","COK_UPED",.T.,cUser,"COK_DOCPED")
					EndIf
				EndIf
				
			Case (nEvento == 3)//Inclusao PC via analise da cotacao - COMXFUN
				//+----------------------------------------------------------------------------+
				//|Na analise das Cota็๕es, tenho que passar o fornecedor e loja para a fun็ใo |
				//|Pois neste momento ja existe um registro com as cota็๕es na tabela COK      |
				//+----------------------------------------------------------------------------+
				aComa080 := {SC8->C8_FORNECE,SC8->C8_LOJA}
			
				BeginSQL Alias cAliasSC1
					SELECT C1_NUM, C1_ITEM
					FROM %Table:SC1% SC1
					WHERE C1_FILIAL = %xFilial:SC1% AND C1_COTACAO = %Exp:SC8->C8_NUM% AND C1_PRODUTO = %Exp:SC8->C8_PRODUTO% AND C1_IDENT = %Exp:SC8->C8_IDENT% AND SC1.%NotDel%
				EndSQL
				(cAliasSC1)->(dbGoTop())
				While !(cAliasSC1)->(EOF())
					COMA080((cAliasSC1)->C1_NUM,(cAliasSC1)->C1_ITEM,"COK",aComa080,"COK_DTHPED","COK_UPED",/*lEstorno*/,/*cUser*/,;
					        "COK_DOCPED",SubStr(cDados,1,TamSX3("C7_NUM")[1]),SubStr(cDados,nPos, TamSX3("C7_ITEM")[1]))
					(cAliasSC1)->(dbSkip())
				EndDo
				(cAliasSC1)->(dbCloseArea())
			
			Case (nEvento == 4)//Exclusao PC incluido via analise de cotacao - COMXFUN
				COMA080(SC1->C1_NUM,SC1->C1_ITEM,"COK",aComa080,"COK_DTHLIB","COK_ULIB",.T.,/*cUser*/,"COK_DOCLIB")
				COMA080(SC1->C1_NUM,SC1->C1_ITEM,"COK",aComa080,"COK_DTHPED","COK_UPED",.T.,/*cUser*/,"COK_DOCPED")
				
				If SC1->C1_QUJE == 0
					COMA080(SC1->C1_NUM,SC1->C1_ITEM,"COI",aComa080,"COI_DTHANL","COI_UANL",.T.,/*cUser*/,"COI_DOCANL")
					If Empty(SC1->C1_COTACAO)
						COMA080(SC1->C1_NUM,SC1->C1_ITEM,"COK",aComa080,"COK_DTHATL","COK_UATL",.T.,/*cUser*/,"COK_DOCATL")
						COMA080(SC1->C1_NUM,SC1->C1_ITEM,"COK",aComa080,"COI_DTHCOT","COI_UCOT",.T.,/*cUser*/,"COI_DOCCOT")
					EndIf
				EndIf
				
			Case (nEvento == 5)//Inclusao PC via medicao de contrato - CNTA120
				cFilCtr := IIF(cFilAnt == cFilBkp,cFilAnt,cFilBkp)
				CNE->(dbSetOrder(1))
				If CNE->(dbSeek(xFilial("CNE", cFilCtr) + SC7->(C7_CONTRA+C7_CONTREV+C7_PLANILH+C7_MEDICAO+C7_ITEMED)))
					
					cNumPed := aComa080[1]
					cItemPed:= aComa080[2]
					
					SC1->(dbSetOrder(11))//C1_FISCORI+C1_SCORI+C1_ITSCORI+C1_PRODUTO
					CO2->(dbSetOrder(1))
					SC8->(dbSetOrder(3))
					CN9->(dbSetOrder(1))
					CN9->(dbSeek(xFilial("CN9", cFilCtr) + CNE->(CNE_CONTRA+CNE_REVISA)))
					CNB->(DbSetOrder(1))//CNB_FILIAL+CNB_CONTRA+CNB_REVISA+CNB_NUMERO+CNB_ITEM				
				   
					If CO2->(dbSeek(xFilial("CO2")+CN9->(CN9_CODED+CN9_NUMPR)+CNE->CNE_PRODUT))//Procura na tabela de Produtos por Edital
						SC1->(dbSetOrder(8))
						If SC1->(dbSeek(xFilial("SC1")+CO2->(CO2_CODEDT+CO2_NUMPRO+CO2_CODPRO)))
							While !SC1->(EOF()) .And. SC1->(C1_FILIAL+C1_CODED+C1_NUMPR+C1_PRODUTO) == CO2->(CO2_FILIAL+CO2_CODEDT+CO2_NUMPRO+CO2_CODPRO)
								//SC->EDT->CT->PC
								COMA080(SC1->C1_NUM,SC1->C1_ITEM,"COK",aComa080,"COK_DTHPED","COK_UPED",/*lEstorno*/,/*cUser*/,;
								"COK_DOCPED",cNumPed,cItemPed)
								SC1->(dbSkip())
							EndDo
						EndIf
					ElseIf SC1->(dbSeek(xFilial("SC1")+CNE->(CNE_CONTRA+CNE_PRODUT+"0"+CNE_ITEM)))
						//SC->CT->PC
						COMA080(SC1->C1_NUM,SC1->C1_ITEM,"COK",aComa080,"COK_DTHPED","COK_UPED",/*lEstorno*/,/*cUser*/,;
						  "COK_DOCPED",cNumPed,cItemPed)
					ElseIf SC8->(dbSeek(xFilial("SC8")+CN9->CN9_NUMCOT+CNE->CNE_PRODUT))//Procura em cota็๕es
						SC1->(dbSetOrder(5))
						If SC1->(dbSeek(xFilial("SC1")+SC8->(C8_NUM+C8_PRODUTO+C8_IDENT)))
							//+-----------------------------------------------------------------+
							//|Neste momento, eu pego o fornecedor da Cotacao, pois em teoria	  |
							//|Na medicao de um contrato que possui cotacao,ja esta posicionado |
							//+-----------------------------------------------------------------+	  	  
							aComa080 := {SC7->C7_FORNECE,;
											 SC7->C7_LOJA,;
											 cNumPed,;
											 SubStr(cDados,nPos,TamSX3("C7_ITEM")[1])}
										 
							While !SC1->(EOF()) .And. SC1->(C1_COTACAO+C1_PRODUTO+C1_IDENT) == SC8->(C8_NUM+C8_PRODUTO+C8_IDENT)
								//SC->COT->CT->PC
								COMA080(SC1->C1_NUM,SC1->C1_ITEM,"COK",aComa080,"COK_DTHPED","COK_UPED",/*lEstorno*/,/*cUser*/,;
								  "COK_DOCPED",cNumPed,cItemPed)
								SC1->(dbSkip())
							EndDo
						EndIf
					ElseIf(CNB->(DbSeek(xFilial("CNB", cFilCtr) + CNE->(CNE_CONTRA+CNE_REVISA+CNE_NUMERO+CNE_ITEM))))//Procura em itens da planilha de contratos
						If(!Empty(CNB->(CNB_NUMSC+CNB_ITEMSC)))							 
							COMA080(CNB->CNB_NUMSC,CNB->CNB_ITEMSC,"COK",aComa080,"COK_DTHPED","COK_UPED",,,"COK_DOCPED",SC7->C7_NUM, SC7->C7_ITEM)						  
						EndIf
					EndIf
				EndIf				
		EndCase
		
	Case cEtapa == "LIB"
		aComa080 := {SC7->C7_NUM,SC7->C7_ITEM}

       //Liberacao de PC - CWKFA003/MATA097
		If nEvento == 1
			cFilCtr := IIF(cFilAnt == cFilBkp,cFilAnt,cFilBkp)
			CNE->(dbSetOrder(1))
			CO2->(dbSetOrder(1))
			SC8->(dbSetOrder(3))
			If CNE->(dbSeek(xFilial("CNE", cFilCtr )+SC7->(C7_CONTRA+C7_CONTREV+C7_PLANILH+C7_MEDICAO)))
				CN9->(dbSetOrder(1))
				CN9->(dbSeek(xFilial("CN9", cFilCtr )+CNE->(CNE_CONTRA+CNE_REVISA)))
				While !CNE->(EOF()) .And. CNE->(CNE_FILIAL+CNE_CONTRA+CNE_REVISA+CNE_NUMERO+CNE_NUMMED) == SC7->(C7_FILIAL+C7_CONTRA+C7_CONTREV+C7_PLANILH+C7_MEDICAO)
					If CNE->CNE_QUANT > 0 .And. PadL(CNE->CNE_ITEM,TamSX3("C7_ITEM")[1],"0") == SC7->C7_ITEM
						SC1->(dbSetOrder(11))
						CO2->(dbSetOrder(1))
						SC8->(dbSetOrder(3))
						If SC1->(dbSeek(xFilial("SC1")+CNE->(CNE_CONTRA+CNE_PRODUT+"0"+CNE_ITEM)))
							//SC->CT->PC
	 				    	COMA080(SC1->C1_NUM,SC1->C1_ITEM,"COK",aComa080,"COK_DTHLIB","COK_ULIB",/*lEstorno*/,cUser,"COK_DOCLIB",SC7->C7_NUM)
						ElseIf CO2->(dbSeek(xFilial("CO2")+CN9->(CN9_CODED+CN9_NUMPR)+CNE->CNE_PRODUT))
			    			SC1->(dbSetOrder(8))
							If SC1->(dbSeek(xFilial("SC1")+CO2->(CO2_CODEDT+CO2_NUMPRO+CO2_CODPRO)))
								While !SC1->(EOF()) .And. SC1->(C1_FILIAL+C1_CODED+C1_NUMPR+C1_PRODUTO) == CO2->(CO2_FILIAL+CO2_CODEDT+CO2_NUMPRO+CO2_CODPRO)
									//Devido a geracao do pedido nas pontas, tenho que tratar por pedido dentro do edital
									If SC7->(C7_NUM + C7_ITEM) == SC1->(C1_PEDIDO + C1_ITEMPED)
										//SC->EDT->CT->PC
				 				    	COMA080(SC1->C1_NUM,SC1->C1_ITEM,"COK",aComa080,"COK_DTHLIB","COK_ULIB",/*lEstorno*/,cUser,"COK_DOCLIB",SC7->C7_NUM)
				 				    Endif
				 				    
									SC1->(dbSkip())
								EndDo
							EndIf
						ElseIf SC8->(dbSeek(xFilial("SC8")+CN9->CN9_NUMCOT+CNE->CNE_PRODUT))
 	  						SC1->(dbSetOrder(5))
 	  						If SC1->(dbSeek(xFilial("SC1")+SC8->(C8_NUM+C8_PRODUTO+C8_IDENT)))
 	  							//aComa080 := {} CHAVE -> PC+ITEMPC+FORNECEDOR+LOJA
								While !SC1->(EOF()) .And. SC1->(C1_COTACAO+C1_PRODUTO+C1_IDENT) == SC8->(C8_NUM+C8_PRODUTO+C8_IDENT)
									//SC->COT->CT->PC
			 				    	COMA080(SC1->C1_NUM,SC1->C1_ITEM,"COK",aComa080,"COK_DTHLIB","COK_ULIB",/*lEstorno*/,cUser,"COK_DOCLIB",SC7->C7_NUM)
									SC1->(dbSkip())
								EndDo
							EndIf
						ElseIf(CNB->(DbSeek(xFilial("CNB", cFilCtr) + CNE->(CNE_CONTRA+CNE_REVISA+CNE_NUMERO+CNE_ITEM))))
							If(!Empty(CNB->(CNB_NUMSC+CNB_ITEMSC)))
								COMA080(CNB->CNB_NUMSC, CNB->CNB_ITEMSC,"COK",aComa080,"COK_DTHLIB","COK_ULIB",/*lEstorno*/,cUser,"COK_DOCLIB",SC7->C7_NUM)
							EndIf
						EndIf
					EndIf
					CNE->(dbSkip())
				EndDo
			ElseIf CO2->(dbSeek(xFilial("CO2")+SC7->(C7_CODED+C7_NUMPR+C7_PRODUTO)))
				SC1->(dbSetOrder(8))
				If SC1->(dbSeek(xFilial("SC1")+CO2->(CO2_CODEDT+CO2_NUMPRO+CO2_CODPRO)))
					While !SC1->(EOF()) .And. SC1->(C1_FILIAL+C1_CODED+C1_NUMPR+C1_PRODUTO) == CO2->(CO2_FILIAL+CO2_CODEDT+CO2_NUMPRO+CO2_CODPRO)
						If SC7->(C7_NUM + C7_ITEM) == SC1->(C1_PEDIDO + C1_ITEMPED)
							//SC->EDT->PC
 					    	COMA080(SC1->C1_NUM,SC1->C1_ITEM,"COK",aComa080,"COK_DTHLIB","COK_ULIB",/*lEstorno*/,cUser,"COK_DOCLIB",SC7->C7_NUM)
 					    Endif
			 	    	SC1->(dbSkip())
			 		EndDo
				EndIf
			ElseIf SC8->(dbSeek(xFilial("SC8")+SC7->(C7_NUMCOT+C7_PRODUTO+C7_FORNECE+C7_LOJA+C7_NUM+C7_ITEM)))
				SC1->(dbSetOrder(5))
				If SC1->(dbSeek(xFilial("SC1")+SC8->(C8_NUM+C8_PRODUTO+C8_IDENT)))
					aComa080 := {SC7->C7_FORNECE,SC7->C7_LOJA}
					While !SC1->(EOF()) .And. (SC1->(C1_FILIAL+C1_COTACAO+C1_PRODUTO+C1_IDENT) == SC8->(C8_FILIAL+C8_NUM+C8_PRODUTO+C8_IDENT))
						//SC->COT->PC
 				    	COMA080(SC1->C1_NUM,SC1->C1_ITEM,"COK",aComa080,"COK_DTHLIB","COK_ULIB",/*lEstorno*/,cUser,"COK_DOCLIB",SC7->C7_NUM)
 				    	SC1->(dbSkip())
 					EndDo
 				EndIf
 			Else
				//SC->PC
 				COMA080(SC7->C7_NUMSC,SC7->C7_ITEMSC,"COK",aComa080,"COK_DTHLIB","COK_ULIB",/*lEstorno*/,cUser,"COK_DOCLIB",SC7->C7_NUM)
 			EndIf
		EndIf
		
		//Estorno da liberacao do PC - MATA120
		If nEvento == 2
			If SC7->C7_CONAPRO == "B"
				CO2->(dbSetOrder(1))
				SC8->(dbSetOrder(3))
				If CO2->(dbSeek(xFilial("CO2")+SC7->(C7_CODED+C7_NUMPR+C7_PRODUTO)))
					SC1->(dbSetOrder(8))
					If SC1->(dbSeek(xFilial("SC1")+CO2->(CO2_CODEDT+CO2_NUMPRO+CO2_CODPRO)))
						While !SC1->(EOF()) .And. SC1->(C1_FILIAL+C1_CODED+C1_NUMPR+C1_PRODUTO) == CO2->(CO2_FILIAL+CO2_CODEDT+CO2_NUMPRO+CO2_CODPRO)
							//SC->EDT->PC
							COMA080(SC1->C1_NUM,SC1->C1_ITEM,"COK",aComa080,"COK_DTHLIB","COK_ULIB",.T.,cUser,"COK_DOCLIB")
				 	    	SC1->(dbSkip())
				 		EndDo
					EndIf
				ElseIf SC8->(dbSeek(xFilial("SC8")+SC7->(C7_NUMCOT+C7_PRODUTO+C7_FORNECE+C7_LOJA+C7_NUM+C7_ITEM)))
					SC1->(dbSetOrder(5))
					If SC1->(dbSeek(xFilial("SC1")+SC8->(C8_NUM+C8_PRODUTO+C8_IDENT)))
						aComa080 := {SC7->C7_FORNECE,SC7->C7_LOJA}
						While !SC1->(EOF()) .And. (SC1->(C1_FILIAL+C1_COTACAO+C1_PRODUTO+C1_IDENT) == SC8->(C8_FILIAL+C8_NUM+C8_PRODUTO+C8_IDENT))
							//SC->COT->PC
							COMA080(SC1->C1_NUM,SC1->C1_ITEM,"COK",aComa080,"COK_DTHLIB","COK_ULIB",.T.,cUser,"COK_DOCLIB")
	 						SC1->(dbSkip())
	 					EndDo
	 				EndIf
	 				Else
				//SC->PC
				COMA080(SC7->C7_NUMSC,SC7->C7_ITEMSC,"COK",aComa080,"COK_DTHLIB","COK_ULIB",.T.,cUser,"COK_DOCLIB")
				EndIf
			EndIf
		EndIf
		
	    //Estorno da liberacao do PC - MATA097
		If nEvento == 3
			CNE->(dbSetOrder(1))
			CO2->(dbSetOrder(1))
			SC8->(dbSetOrder(3))
			If CNE->(dbSeek(xFilial("CNE", iif(cFilAnt == cFilBkp,cFilAnt,cFilBkp) )+SC7->(C7_CONTRA+C7_CONTREV+C7_PLANILH+C7_MEDICAO)))
			    CN9->(dbSetOrder(1))
				CN9->(dbSeek(xFilial("CN9", iif(cFilAnt == cFilBkp,cFilAnt,cFilBkp) )+CNE->(CNE_CONTRA+CNE_REVISA)))
				While !CNE->(EOF()) .And. CNE->(CNE_FILIAL+CNE_CONTRA+CNE_REVISA+CNE_NUMERO+CNE_NUMMED) == SC7->(C7_FILIAL+C7_CONTRA+C7_CONTREV+C7_PLANILH+C7_MEDICAO)
					If CNE->CNE_QUANT > 0 .And. PadL(CNE->CNE_ITEM,TamSX3("C7_ITEM")[1],"0") == SC7->C7_ITEM
						SC1->(dbSetOrder(11))
						CO2->(dbSetOrder(1))
						SC8->(dbSetOrder(3))
						If SC1->(dbSeek(xFilial("SC1")+CNE->(CNE_CONTRA+CNE_PRODUT+"0"+CNE_ITEM)))
							//SC->CT->PC
	 				    	COMA080(SC1->C1_NUM,SC1->C1_ITEM,"COK",aComa080,"COK_DTHLIB","COK_ULIB",.T.,cUser,"COK_DOCLIB")
						ElseIf CO2->(dbSeek(xFilial("CO2")+CN9->(CN9_CODED+CN9_NUMPR)+CNE->CNE_PRODUT))
			    			SC1->(dbSetOrder(8))
							If SC1->(dbSeek(xFilial("SC1")+CO2->(CO2_CODEDT+CO2_NUMPRO+CO2_CODPRO)))
								While !SC1->(EOF()) .And. SC1->(C1_FILIAL+C1_CODED+C1_NUMPR+C1_PRODUTO) == CO2->(CO2_FILIAL+CO2_CODEDT+CO2_NUMPRO+CO2_CODPRO)
									//SC->EDT->CT->PC
			 				    	COMA080(SC1->C1_NUM,SC1->C1_ITEM,"COK",aComa080,"COK_DTHLIB","COK_ULIB",.T.,cUser,"COK_DOCLIB")
									SC1->(dbSkip())
								EndDo
							EndIf
						ElseIf SC8->(dbSeek(xFilial("SC8")+CN9->CN9_NUMCOT+CNE->CNE_PRODUT))
 	  						SC1->(dbSetOrder(5))
 	  						If SC1->(dbSeek(xFilial("SC1")+SC8->(C8_NUM+C8_PRODUTO+C8_IDENT)))
 	  							//aComa080 := {} CHAVE -> PC+ITEMPC+FORNECEDOR+LOJA
								While !SC1->(EOF()) .And. SC1->(C1_COTACAO+C1_PRODUTO+C1_IDENT) == SC8->(C8_NUM+C8_PRODUTO+C8_IDENT)
									//SC->COT->CT->PC
			 				    	COMA080(SC1->C1_NUM,SC1->C1_ITEM,"COK",aComa080,"COK_DTHLIB","COK_ULIB",.T.,cUser,"COK_DOCLIB")
									SC1->(dbSkip())
								EndDo
							EndIf
						EndIf
					EndIf
					CNE->(dbSkip())
				EndDo
			ElseIf CO2->(dbSeek(xFilial("CO2")+SC7->(C7_CODED+C7_NUMPR+C7_PRODUTO)))
				SC1->(dbSetOrder(8))
				If SC1->(dbSeek(xFilial("SC1")+CO2->(CO2_CODEDT+CO2_NUMPRO+CO2_CODPRO)))
					While !SC1->(EOF()) .And. SC1->(C1_FILIAL+C1_CODED+C1_NUMPR+C1_PRODUTO) == CO2->(CO2_FILIAL+CO2_CODEDT+CO2_NUMPRO+CO2_CODPRO)
						//SC->EDT->PC
 				    	COMA080(SC1->C1_NUM,SC1->C1_ITEM,"COK",aComa080,"COK_DTHLIB","COK_ULIB",.T.,cUser,"COK_DOCLIB")
			 	    	SC1->(dbSkip())
			 		EndDo
				EndIf
			ElseIf SC8->(dbSeek(xFilial("SC8")+SC7->(C7_NUMCOT+C7_PRODUTO+C7_FORNECE+C7_LOJA+C7_NUM+C7_ITEM)))
				SC1->(dbSetOrder(5))
				If SC1->(dbSeek(xFilial("SC1")+SC8->(C8_NUM+C8_PRODUTO+C8_IDENT)))
					aComa080 := {SC7->C7_FORNECE,SC7->C7_LOJA}
					While !SC1->(EOF()) .And. (SC1->(C1_FILIAL+C1_COTACAO+C1_PRODUTO+C1_IDENT) == SC8->(C8_FILIAL+C8_NUM+C8_PRODUTO+C8_IDENT))
						//SC->COT->PC
 				    	COMA080(SC1->C1_NUM,SC1->C1_ITEM,"COK",aComa080,"COK_DTHLIB","COK_ULIB",.T.,cUser,"COK_DOCLIB")
 				    	SC1->(dbSkip())
 					EndDo
 				EndIf
 			Else
				//SC->PC
 				COMA080(SC7->C7_NUMSC,SC7->C7_ITEMSC,"COK",aComa080,"COK_DTHLIB","COK_ULIB",.T.,cUser,"COK_DOCLIB")
 			EndIf
		EndIf
		
	Case cEtapa == "LPN"
		aComa080 := {SD1->D1_PEDIDO,SD1->D1_ITEMPC,C080NF(cNFiscal,cSerie,cA100For,cLoja,IIf(cFormul=="S","S"," "))}    
		
		//Lancamento Pre-Nota - MATA140
		If nEvento == 1
			SC7->(dbSetOrder(1))                                                     
			//Parametro incluido para testes 
			If SC7->(dbSeek(xFilial("SC7", iif(lOrigem,cFilBkp,Nil) )+SD1->D1_PEDIDO+SD1->D1_ITEMPC)) 
				CNE->(dbSetOrder(1))
				CO2->(dbSetOrder(1))
				SC8->(dbSetOrder(3))                    
				If CNE->(dbSeek(xFilial("CNE", iif(cFilAnt == cFilBkp,cFilAnt,cFilBkp))+SC7->(C7_CONTRA+C7_CONTREV+C7_PLANILH+C7_MEDICAO+C7_ITEMED)))
				   CN9->(dbSetOrder(1))
					CN9->(dbSeek(xFilial("CN9", iif(cFilAnt == cFilBkp,cFilAnt,cFilBkp) )+CNE->(CNE_CONTRA+CNE_REVISA)))
					SC1->(dbSetOrder(11))
					CO2->(dbSetOrder(1))
					If SC1->(dbSeek(xFilial("SC1")+CNE->(CNE_CONTRA+CNE_PRODUT+"0"+CNE_ITEM)))
						//SC->CT->PC
						COMA080(SC1->C1_NUM,SC1->C1_ITEM,"COH",aComa080,"COH_DTHLPN","COH_ULPN")
					ElseIf CO2->(dbSeek(xFilial("CO2")+CN9->(CN9_CODED+CN9_NUMPR)+CNE->CNE_PRODUT))
		    			SC1->(dbSetOrder(8))
						If SC1->(dbSeek(xFilial("SC1")+CO2->(CO2_CODEDT+CO2_NUMPRO+CO2_CODPRO)))
							While !SC1->(EOF()) .And. SC1->(C1_FILIAL+C1_CODED+C1_NUMPR+C1_PRODUTO) == CO2->(CO2_FILIAL+CO2_CODEDT+CO2_NUMPRO+CO2_CODPRO)
								//SC->EDT->CT->PC
								COMA080(SC1->C1_NUM,SC1->C1_ITEM,"COH",aComa080,"COH_DTHLPN","COH_ULPN")
								SC1->(dbSkip())
							EndDo
						EndIf
					ElseIf SC8->(dbSeek(xFilial("SC8")+CN9->CN9_NUMCOT+CNE->CNE_PRODUT))
			 	  		SC1->(dbSetOrder(5))
			 			If SC1->(dbSeek(xFilial("SC1")+SC8->(C8_NUM+C8_PRODUTO+C8_IDENT)))
							While !SC1->(EOF()) .And. SC1->(C1_COTACAO+C1_PRODUTO+C1_IDENT) == SC8->(C8_NUM+C8_PRODUTO+C8_IDENT)
								//SC->COT->CT->PC
								COMA080(SC1->C1_NUM,SC1->C1_ITEM,"COH",aComa080,"COH_DTHLPN","COH_ULPN")
								SC1->(dbSkip())
							EndDo
						EndIf
					EndIf
				ElseIf CO2->(dbSeek(xFilial("CO2")+SC7->(C7_CODED+C7_NUMPR+C7_PRODUTO)))
					SC1->(dbSetOrder(8))
					If SC1->(dbSeek(xFilial("SC1")+CO2->(CO2_CODEDT+CO2_NUMPRO+CO2_CODPRO)))
						While !SC1->(EOF()) .And. SC1->(C1_FILIAL+C1_CODED+C1_NUMPR+C1_PRODUTO) == CO2->(CO2_FILIAL+CO2_CODEDT+CO2_NUMPRO+CO2_CODPRO)
							//SC->EDT->PC
							COMA080(SC1->C1_NUM,SC1->C1_ITEM,"COH",aComa080,"COH_DTHLPN","COH_ULPN")
				 	    	SC1->(dbSkip())
				 		EndDo
				 	EndIf
				ElseIf SC8->(dbSeek(xFilial("SC8")+SC7->(C7_NUMCOT+C7_PRODUTO+C7_FORNECE+C7_LOJA+C7_NUM+C7_ITEM)))
					SC1->(dbSetOrder(5))
					If SC1->(dbSeek(xFilial("SC1")+SC8->(C8_NUM+C8_PRODUTO+C8_IDENT)))
						While !SC1->(EOF()) .And. (SC1->(C1_FILIAL+C1_COTACAO+C1_PRODUTO+C1_IDENT) == SC8->(C8_FILIAL+C8_NUM+C8_PRODUTO+C8_IDENT))
							//SC->COT->PC
							COMA080(SC1->C1_NUM,SC1->C1_ITEM,"COH",aComa080,"COH_DTHLPN","COH_ULPN")
							SC1->(dbSkip())
						EndDo
					EndIf
				Else
					//SC->PC
					COMA080(SC7->C7_NUMSC,SC7->C7_ITEMSC,"COH",aComa080,"COH_DTHLPN","COH_ULPN")
				EndIf
			EndIf
		EndIf
		
		//Exclusao Pre-Nota - MATA140
		If nEvento == 2
			SC7->(dbSetOrder(1))
			If SC7->(dbSeek(xFilial("SC7", iif(lOrigem,cFilBkp,Nil) )+SD1->D1_PEDIDO+SD1->D1_ITEMPC))
				CNE->(dbSetOrder(1))
				CO2->(dbSetOrder(1))
				SC8->(dbSetOrder(3))
				If CNE->(dbSeek(xFilial("CNE", iif(cFilAnt == cFilBkp,cFilAnt,cFilBkp))+SC7->(C7_CONTRA+C7_CONTREV+C7_PLANILH+C7_MEDICAO+C7_ITEMED)))
				    CN9->(dbSetOrder(1))
					CN9->(dbSeek(xFilial("CN9", iif(cFilAnt == cFilBkp,cFilAnt,cFilBkp) )+CNE->(CNE_CONTRA+CNE_REVISA)))
					SC1->(dbSetOrder(11))
					CO2->(dbSetOrder(1))
					If SC1->(dbSeek(xFilial("SC1")+CNE->(CNE_CONTRA+CNE_PRODUT+"0"+CNE_ITEM)))
						//SC->CT->PC
						COMA080(SC1->C1_NUM,SC1->C1_ITEM,"COH",aComa080,"COH_DTHLPN","COH_ULPN",.T.)
						COMA080(SC1->C1_NUM,SC1->C1_ITEM,"COH",aComa080,"COH_DTHATS","COH_UATS",.T.)
					ElseIf CO2->(dbSeek(xFilial("CO2")+CN9->(CN9_CODED+CN9_NUMPR)+CNE->CNE_PRODUT))
		    			SC1->(dbSetOrder(8))
						If SC1->(dbSeek(xFilial("SC1")+CO2->(CO2_CODEDT+CO2_NUMPRO+CO2_CODPRO)))
							While !SC1->(EOF()) .And. SC1->(C1_FILIAL+C1_CODED+C1_NUMPR+C1_PRODUTO) == CO2->(CO2_FILIAL+CO2_CODEDT+CO2_NUMPRO+CO2_CODPRO)
								//SC->EDT->CT->PC
								COMA080(SC1->C1_NUM,SC1->C1_ITEM,"COH",aComa080,"COH_DTHLPN","COH_ULPN",.T.)
								COMA080(SC1->C1_NUM,SC1->C1_ITEM,"COH",aComa080,"COH_DTHATS","COH_UATS",.T.)
								SC1->(dbSkip())
							EndDo
						EndIf
					ElseIf SC8->(dbSeek(xFilial("SC8")+CN9->CN9_NUMCOT+CNE->CNE_PRODUT))
			 	  		SC1->(dbSetOrder(5))
			 	  		If SC1->(dbSeek(xFilial("SC1")+SC8->(C8_NUM+C8_PRODUTO+C8_IDENT)))
							While !SC1->(EOF()) .And. SC1->(C1_COTACAO+C1_PRODUTO+C1_IDENT) == SC8->(C8_NUM+C8_PRODUTO+C8_IDENT)
								//SC->COT->CT->PC
								COMA080(SC1->C1_NUM,SC1->C1_ITEM,"COH",aComa080,"COH_DTHLPN","COH_ULPN",.T.)
								COMA080(SC1->C1_NUM,SC1->C1_ITEM,"COH",aComa080,"COH_DTHATS","COH_UATS",.T.)
								SC1->(dbSkip())
							EndDo
						EndIf
					EndIf
				ElseIf CO2->(dbSeek(xFilial("CO2")+SC7->(C7_CODED+C7_NUMPR+C7_PRODUTO)))
					SC1->(dbSetOrder(8))
					If SC1->(dbSeek(xFilial("SC1")+CO2->(CO2_CODEDT+CO2_NUMPRO+CO2_CODPRO)))
						While !SC1->(EOF()) .And. SC1->(C1_FILIAL+C1_CODED+C1_NUMPR+C1_PRODUTO) == CO2->(CO2_FILIAL+CO2_CODEDT+CO2_NUMPRO+CO2_CODPRO)
							//SC->EDT->PC
							COMA080(SC1->C1_NUM,SC1->C1_ITEM,"COH",aComa080,"COH_DTHLPN","COH_ULPN",.T.)
							COMA080(SC1->C1_NUM,SC1->C1_ITEM,"COH",aComa080,"COH_DTHATS","COH_UATS",.T.)
				 	    	SC1->(dbSkip())
				 		EndDo
				 	EndIf
				ElseIf SC8->(dbSeek(xFilial("SC8")+SC7->(C7_NUMCOT+C7_PRODUTO+C7_FORNECE+C7_LOJA+C7_NUM+C7_ITEM)))
					SC1->(dbSetOrder(5))
					If SC1->(dbSeek(xFilial("SC1")+SC8->(C8_NUM+C8_PRODUTO+C8_IDENT)))
						While !SC1->(EOF()) .And. (SC1->(C1_FILIAL+C1_COTACAO+C1_PRODUTO+C1_IDENT) == SC8->(C8_FILIAL+C8_NUM+C8_PRODUTO+C8_IDENT))
							//SC->COT->PC
							COMA080(SC1->C1_NUM,SC1->C1_ITEM,"COH",aComa080,"COH_DTHLPN","COH_ULPN",.T.)
							COMA080(SC1->C1_NUM,SC1->C1_ITEM,"COH",aComa080,"COH_DTHATS","COH_UATS",.T.)
							SC1->(dbSkip())
						EndDo
					EndIf
				Else
					//SC->PC
					COMA080(SC7->C7_NUMSC,SC7->C7_ITEMSC,"COH",aComa080,"COH_DTHLPN","COH_ULPN",.T.)
					COMA080(SC7->C7_NUMSC,SC7->C7_ITEMSC,"COH",aComa080,"COH_DTHATS","COH_UATS",.T.)
				EndIf
			EndIf
		EndIf

	Case cEtapa == "ATS"
	
		//Atesto da Pre-Nota - COMA130
		If nEvento == 1
			BeginSQL Alias cAliasSD1
				SELECT D1_PEDIDO, D1_ITEMPC
				FROM %Table:SD1% SD1
				WHERE D1_FILIAL = %xFilial:SD1% AND D1_DOC = %Exp:SF1->F1_DOC% AND D1_SERIE = %Exp:SF1->F1_SERIE% AND D1_FORNECE = %Exp:SF1->F1_FORNECE% AND D1_LOJA = %Exp:SF1->F1_LOJA% AND SD1.%NotDel%
			EndSQL
			(cAliasSD1)->(dbGoTop())
			SC7->(dbSetOrder(1))
			While !(cAliasSD1)->(EOF())
				If SC7->(dbSeek(xFilial("SC7", iif(lOrigem,cFilBkp,Nil) )+(cAliasSD1)->D1_PEDIDO+(cAliasSD1)->D1_ITEMPC))
					CNE->(dbSetOrder(1))
					CO2->(dbSetOrder(1))
					SC8->(dbSetOrder(3))
					If CNE->(dbSeek(xFilial("CNE",iif(cFilAnt == cFilBkp,cFilAnt,cFilBkp) )+SC7->(C7_CONTRA+C7_CONTREV+C7_PLANILH+C7_MEDICAO)))
						CN9->(dbSetOrder(1))
						CN9->(dbSeek(xFilial("CN9", iif(cFilAnt == cFilBkp,cFilAnt,cFilBkp) )+CNE->(CNE_CONTRA+CNE_REVISA)))
						While !CNE->(EOF()) .And. CNE->(CNE_FILIAL+CNE_CONTRA+CNE_REVISA+CNE_NUMERO+CNE_NUMMED) == SC7->(C7_FILIAL+C7_CONTRA+C7_CONTREV+C7_PLANILH+C7_MEDICAO)
							If CNE->CNE_QUANT > 0 .And. PadL(CNE->CNE_ITEM,TamSX3("C7_ITEM")[1],"0") == SC7->C7_ITEM
								SC1->(dbSetOrder(11))
								CO2->(dbSetOrder(1))
								If SC1->(dbSeek(xFilial("SC1")+CNE->(CNE_CONTRA+CNE_PRODUT+"0"+CNE_ITEM)))
									//SC->CT->PC
									aComa080 := {(cAliasSD1)->D1_PEDIDO,(cAliasSD1)->D1_ITEMPC,C080NF(SF1->F1_DOC,SF1->F1_SERIE,SF1->F1_FORNECE,SF1->F1_LOJA,IIf(SF1->F1_FORMUL=="S","S"," "))}
									COMA080(SC1->C1_NUM,SC1->C1_ITEM,"COH",aComa080,"COH_DTHATS","COH_UATS")
								ElseIf CO2->(dbSeek(xFilial("CO2")+CN9->(CN9_CODED+CN9_NUMPR)+CNE->CNE_PRODUT))
					    			SC1->(dbSetOrder(8))
									If SC1->(dbSeek(xFilial("SC1")+CO2->(CO2_CODEDT+CO2_NUMPRO+CO2_CODPRO)))
										While !SC1->(EOF()) .And. SC1->(C1_FILIAL+C1_CODED+C1_NUMPR+C1_PRODUTO) == CO2->(CO2_FILIAL+CO2_CODEDT+CO2_NUMPRO+CO2_CODPRO)
											//SC->EDT->CT->PC
											aComa080 := {(cAliasSD1)->D1_PEDIDO,(cAliasSD1)->D1_ITEMPC,C080NF(SF1->F1_DOC,SF1->F1_SERIE,SF1->F1_FORNECE,SF1->F1_LOJA,IIf(SF1->F1_FORMUL=="S","S"," "))}
											COMA080(SC1->C1_NUM,SC1->C1_ITEM,"COH",aComa080,"COH_DTHATS","COH_UATS")
											SC1->(dbSkip())
										EndDo
									EndIf
								ElseIf SC8->(dbSeek(xFilial("SC8")+CN9->CN9_NUMCOT+CNE->CNE_PRODUT))
						 	  		SC1->(dbSetOrder(5))
						 	  		If SC1->(dbSeek(xFilial("SC1")+SC8->(C8_NUM+C8_PRODUTO+C8_IDENT)))
										While !SC1->(EOF()) .And. SC1->(C1_COTACAO+C1_PRODUTO+C1_IDENT) == SC8->(C8_NUM+C8_PRODUTO+C8_IDENT)
											//SC->COT->CT->PC
											aComa080 := {(cAliasSD1)->D1_PEDIDO,(cAliasSD1)->D1_ITEMPC,C080NF(SF1->F1_DOC,SF1->F1_SERIE,SF1->F1_FORNECE,SF1->F1_LOJA,IIf(SF1->F1_FORMUL=="S","S"," "))}
											COMA080(SC1->C1_NUM,SC1->C1_ITEM,"COH",aComa080,"COH_DTHATS","COH_UATS")
											SC1->(dbSkip())
										EndDo
									EndIf
						 		EndIf
						 	EndIf
							CNE->(dbSkip())
						EndDo
					ElseIf CO2->(dbSeek(xFilial("CO2")+SC7->(C7_CODED+C7_NUMPR+C7_PRODUTO)))
						SC1->(dbSetOrder(8))
						If SC1->(dbSeek(xFilial("SC1")+CO2->(CO2_CODEDT+CO2_NUMPRO+CO2_CODPRO)))
							While !SC1->(EOF()) .And. SC1->(C1_FILIAL+C1_CODED+C1_NUMPR+C1_PRODUTO) == CO2->(CO2_FILIAL+CO2_CODEDT+CO2_NUMPRO+CO2_CODPRO)
								//SC->EDT->PC
								aComa080 := {(cAliasSD1)->D1_PEDIDO,(cAliasSD1)->D1_ITEMPC,C080NF(SF1->F1_DOC,SF1->F1_SERIE,SF1->F1_FORNECE,SF1->F1_LOJA,IIf(SF1->F1_FORMUL=="S","S"," "))}
								COMA080(SC1->C1_NUM,SC1->C1_ITEM,"COH",aComa080,"COH_DTHATS","COH_UATS")
					 	    	SC1->(dbSkip())
					 		EndDo
					 	EndIf
					ElseIf SC8->(dbSeek(xFilial("SC8")+SC7->(C7_NUMCOT+C7_PRODUTO+C7_FORNECE+C7_LOJA+C7_NUM+C7_ITEM)))
						SC1->(dbSetOrder(5))
						If SC1->(dbSeek(xFilial("SC1")+SC8->(C8_NUM+C8_PRODUTO+C8_IDENT)))
							While !SC1->(EOF()) .And. (SC1->(C1_FILIAL+C1_COTACAO+C1_PRODUTO+C1_IDENT) == SC8->(C8_FILIAL+C8_NUM+C8_PRODUTO+C8_IDENT))
								//SC->COT->PC
								aComa080 := {(cAliasSD1)->D1_PEDIDO,(cAliasSD1)->D1_ITEMPC,C080NF(SF1->F1_DOC,SF1->F1_SERIE,SF1->F1_FORNECE,SF1->F1_LOJA,IIf(SF1->F1_FORMUL=="S","S"," "))}
								COMA080(SC1->C1_NUM,SC1->C1_ITEM,"COH",aComa080,"COH_DTHATS","COH_UATS")
		 				    	SC1->(dbSkip())
	 						EndDo
		 				EndIf
		 			Else
						//SC->PC
						aComa080 := {(cAliasSD1)->D1_PEDIDO,(cAliasSD1)->D1_ITEMPC,C080NF(SF1->F1_DOC,SF1->F1_SERIE,SF1->F1_FORNECE,SF1->F1_LOJA,IIf(SF1->F1_FORMUL=="S","S"," "))}
						COMA080(SC7->C7_NUMSC,SC7->C7_ITEMSC,"COH",aComa080,"COH_DTHATS","COH_UATS")
					EndIf
				EndIf
				(cAliasSD1)->(dbSkip())
			EndDo
			(cAliasSD1)->(dbCloseArea())
		EndIf

		//Estorno de atesto da Pre-Nota - COMA130
		If nEvento == 2
			BeginSQL Alias cAliasSD1
				SELECT D1_PEDIDO, D1_ITEMPC
				FROM %Table:SD1% SD1
				WHERE D1_FILIAL = %xFilial:SD1% AND D1_DOC = %Exp:SF1->F1_DOC% AND D1_SERIE = %Exp:SF1->F1_SERIE% AND D1_FORNECE = %Exp:SF1->F1_FORNECE% AND D1_LOJA = %Exp:SF1->F1_LOJA% AND SD1.%NotDel%
			EndSQL
			(cAliasSD1)->(dbGoTop())
			SC7->(dbSetOrder(1))
			While !(cAliasSD1)->(EOF())
				If SC7->(dbSeek(xFilial("SC7")+(cAliasSD1)->D1_PEDIDO+(cAliasSD1)->D1_ITEMPC))
					CNE->(dbSetOrder(1))
					CO2->(dbSetOrder(1))
					SC8->(dbSetOrder(3))
					If CNE->(dbSeek(xFilial("CNE", iif(cFilAnt == cFilBkp,cFilAnt,cFilBkp) )+SC7->(C7_CONTRA+C7_CONTREV+C7_PLANILH+C7_MEDICAO)))
						CN9->(dbSetOrder(1))
						CN9->(dbSeek(xFilial("CN9", iif(cFilAnt == cFilBkp,cFilAnt,cFilBkp) )+CNE->(CNE_CONTRA+CNE_REVISA)))
						While !CNE->(EOF()) .And. CNE->(CNE_FILIAL+CNE_CONTRA+CNE_REVISA+CNE_NUMERO+CNE_NUMMED) == SC7->(C7_FILIAL+C7_CONTRA+C7_CONTREV+C7_PLANILH+C7_MEDICAO)
							If CNE->CNE_QUANT > 0 .And. PadL(CNE->CNE_ITEM,TamSX3("C7_ITEM")[1],"0") == SC7->C7_ITEM
								SC1->(dbSetOrder(11))
								CO2->(dbSetOrder(1))
								If SC1->(dbSeek(xFilial("SC1")+CNE->(CNE_CONTRA+CNE_PRODUT+"0"+CNE_ITEM)))
									//SC->CT->PC
									aComa080 := {(cAliasSD1)->D1_PEDIDO,(cAliasSD1)->D1_ITEMPC,C080NF(SF1->F1_DOC,SF1->F1_SERIE,SF1->F1_FORNECE,SF1->F1_LOJA,IIf(SF1->F1_FORMUL=="S","S"," "))}
									COMA080(SC1->C1_NUM,SC1->C1_ITEM,"COH",aComa080,"COH_DTHATS","COH_UATS",.T.)
								ElseIf CO2->(dbSeek(xFilial("CO2")+CN9->(CN9_CODED+CN9_NUMPR)+CNE->CNE_PRODUT))
					    			SC1->(dbSetOrder(8))
									If SC1->(dbSeek(xFilial("SC1")+CO2->(CO2_CODEDT+CO2_NUMPRO+CO2_CODPRO)))
										While !SC1->(EOF()) .And. SC1->(C1_FILIAL+C1_CODED+C1_NUMPR+C1_PRODUTO) == CO2->(CO2_FILIAL+CO2_CODEDT+CO2_NUMPRO+CO2_CODPRO)
											//SC->EDT->CT->PC
											aComa080 := {(cAliasSD1)->D1_PEDIDO,(cAliasSD1)->D1_ITEMPC,C080NF(SF1->F1_DOC,SF1->F1_SERIE,SF1->F1_FORNECE,SF1->F1_LOJA,IIf(SF1->F1_FORMUL=="S","S"," "))}
											COMA080(SC1->C1_NUM,SC1->C1_ITEM,"COH",aComa080,"COH_DTHATS","COH_UATS",.T.)
											SC1->(dbSkip())
										EndDo
									EndIf
								ElseIf SC8->(dbSeek(xFilial("SC8")+CN9->CN9_NUMCOT+CNE->CNE_PRODUT))
						 	  		SC1->(dbSetOrder(5))
						 	  		If SC1->(dbSeek(xFilial("SC1")+SC8->(C8_NUM+C8_PRODUTO+C8_IDENT)))
										While !SC1->(EOF()) .And. SC1->(C1_COTACAO+C1_PRODUTO+C1_IDENT) == SC8->(C8_NUM+C8_PRODUTO+C8_IDENT)
											//SC->COT->CT->PC
											aComa080 := {(cAliasSD1)->D1_PEDIDO,(cAliasSD1)->D1_ITEMPC,C080NF(SF1->F1_DOC,SF1->F1_SERIE,SF1->F1_FORNECE,SF1->F1_LOJA,IIf(SF1->F1_FORMUL=="S","S"," "))}
											COMA080(SC1->C1_NUM,SC1->C1_ITEM,"COH",aComa080,"COH_DTHATS","COH_UATS",.T.)
											SC1->(dbSkip())
										EndDo
									EndIf
						 		EndIf
						 	EndIf
							CNE->(dbSkip())
						EndDo
					ElseIf CO2->(dbSeek(xFilial("CO2")+SC7->(C7_CODED+C7_NUMPR+C7_PRODUTO)))
						SC1->(dbSetOrder(8))
						If SC1->(dbSeek(xFilial("SC1")+CO2->(CO2_CODEDT+CO2_NUMPRO+CO2_CODPRO)))
							While !SC1->(EOF()) .And. SC1->(C1_FILIAL+C1_CODED+C1_NUMPR+C1_PRODUTO) == CO2->(CO2_FILIAL+CO2_CODEDT+CO2_NUMPRO+CO2_CODPRO)
								//SC->EDT->PC
								aComa080 := {(cAliasSD1)->D1_PEDIDO,(cAliasSD1)->D1_ITEMPC,C080NF(SF1->F1_DOC,SF1->F1_SERIE,SF1->F1_FORNECE,SF1->F1_LOJA,IIf(SF1->F1_FORMUL=="S","S"," "))}
								COMA080(SC1->C1_NUM,SC1->C1_ITEM,"COH",aComa080,"COH_DTHATS","COH_UATS",.T.)
				 	    		SC1->(dbSkip())
					 		EndDo
					 	EndIf
					ElseIf SC8->(dbSeek(xFilial("SC8")+SC7->(C7_NUMCOT+C7_PRODUTO+C7_FORNECE+C7_LOJA+C7_NUM+C7_ITEM)))
						SC1->(dbSetOrder(5))
						If SC1->(dbSeek(xFilial("SC1")+SC8->(C8_NUM+C8_PRODUTO+C8_IDENT)))
							While !SC1->(EOF()) .And. (SC1->(C1_FILIAL+C1_COTACAO+C1_PRODUTO+C1_IDENT) == SC8->(C8_FILIAL+C8_NUM+C8_PRODUTO+C8_IDENT))
								//SC->COT->PC
								aComa080 := {(cAliasSD1)->D1_PEDIDO,(cAliasSD1)->D1_ITEMPC,C080NF(SF1->F1_DOC,SF1->F1_SERIE,SF1->F1_FORNECE,SF1->F1_LOJA,IIf(SF1->F1_FORMUL=="S","S"," "))}
								COMA080(SC1->C1_NUM,SC1->C1_ITEM,"COH",aComa080,"COH_DTHATS","COH_UATS",.T.)
		 				    	SC1->(dbSkip())
	 						EndDo
		 				EndIf
		 			Else
						//SC->PC
						aComa080 := {(cAliasSD1)->D1_PEDIDO,(cAliasSD1)->D1_ITEMPC,C080NF(SF1->F1_DOC,SF1->F1_SERIE,SF1->F1_FORNECE,SF1->F1_LOJA,IIf(SF1->F1_FORMUL=="S","S"," "))}
						COMA080(SC7->C7_NUMSC,SC7->C7_ITEMSC,"COH",aComa080,"COH_DTHATS","COH_UATS",.T.)
					EndIf
				EndIf
				(cAliasSD1)->(dbSkip())
			EndDo
			(cAliasSD1)->(dbCloseArea())
		EndIf
		
	Case cEtapa == "CLS"
	
	    //Classificacao da Pre-Nota - MATA103
		If nEvento == 1
			SC7->(dbSetOrder(1))
			If SC7->(dbSeek(xFilial("SC7", iif(lOrigem,cFilBkp,Nil) )+SD1->D1_PEDIDO+SD1->D1_ITEMPC))
				CNE->(dbSetOrder(1))
				CO2->(dbSetOrder(1))
				SC8->(dbSetOrder(3))
				If CNE->(dbSeek(xFilial("CNE", iif(cFilAnt == cFilBkp,cFilAnt,cFilBkp) )+SC7->(C7_CONTRA+C7_CONTREV+C7_PLANILH+C7_MEDICAO)))
					CN9->(dbSetOrder(1))
					CN9->(dbSeek(xFilial("CN9", iif(cFilAnt == cFilBkp,cFilAnt,cFilBkp) )+CNE->(CNE_CONTRA+CNE_REVISA)))
					While !CNE->(EOF()) .And. CNE->(CNE_FILIAL+CNE_CONTRA+CNE_REVISA+CNE_NUMERO+CNE_NUMMED) == SC7->(C7_FILIAL+C7_CONTRA+C7_CONTREV+C7_PLANILH+C7_MEDICAO)
						If CNE->CNE_QUANT > 0 .And. PadL(CNE->CNE_ITEM,TamSX3("C7_ITEM")[1],"0") == SC7->C7_ITEM
							SC1->(dbSetOrder(11))
							CO2->(dbSetOrder(1))
							If SC1->(dbSeek(xFilial("SC1")+CNE->(CNE_CONTRA+CNE_PRODUT+"0"+CNE_ITEM)))
								//SC->CT->PC
								aComa080 := {SD1->D1_PEDIDO,SD1->D1_ITEMPC,C080NF(SD1->D1_DOC,SD1->D1_SERIE,SD1->D1_FORNECE,SD1->D1_LOJA,IIf(SD1->D1_FORMUL=="S","S"," "))}
								COMA080(SC1->C1_NUM,SC1->C1_ITEM,"COH",aComa080,"COH_DTHCLS","COH_UCLS")
							ElseIf CO2->(dbSeek(xFilial("CO2")+CN9->(CN9_CODED+CN9_NUMPR)+CNE->CNE_PRODUT))
				    			SC1->(dbSetOrder(8))
								If SC1->(dbSeek(xFilial("SC1")+CO2->(CO2_CODEDT+CO2_NUMPRO+CO2_CODPRO)))
									While !SC1->(EOF()) .And. SC1->(C1_FILIAL+C1_CODED+C1_NUMPR+C1_PRODUTO) == CO2->(CO2_FILIAL+CO2_CODEDT+CO2_NUMPRO+CO2_CODPRO)
										//SC->EDT->CT->PC
										aComa080 := {SD1->D1_PEDIDO,SD1->D1_ITEMPC,C080NF(SD1->D1_DOC,SD1->D1_SERIE,SD1->D1_FORNECE,SD1->D1_LOJA,IIf(SD1->D1_FORMUL=="S","S"," "))}
										COMA080(SC1->C1_NUM,SC1->C1_ITEM,"COH",aComa080,"COH_DTHCLS","COH_UCLS")
										SC1->(dbSkip())
									EndDo
								EndIf
							ElseIf SC8->(dbSeek(xFilial("SC8")+CN9->CN9_NUMCOT+CNE->CNE_PRODUT))
					 	  		SC1->(dbSetOrder(5))
					 	  		If SC1->(dbSeek(xFilial("SC1")+SC8->(C8_NUM+C8_PRODUTO+C8_IDENT)))
									While !SC1->(EOF()) .And. SC1->(C1_COTACAO+C1_PRODUTO+C1_IDENT) == SC8->(C8_NUM+C8_PRODUTO+C8_IDENT)
										//SC->COT->CT->PC
										aComa080 := {SD1->D1_PEDIDO,SD1->D1_ITEMPC,C080NF(SD1->D1_DOC,SD1->D1_SERIE,SD1->D1_FORNECE,SD1->D1_LOJA,IIf(SD1->D1_FORMUL=="S","S"," "))}
										COMA080(SC1->C1_NUM,SC1->C1_ITEM,"COH",aComa080,"COH_DTHCLS","COH_UCLS")
										SC1->(dbSkip())
									EndDo
								EndIf
					 		EndIf
					 	EndIf
						CNE->(dbSkip())
					EndDo
				ElseIf CO2->(dbSeek(xFilial("CO2")+SC7->(C7_CODED+C7_NUMPR+C7_PRODUTO)))
					SC1->(dbSetOrder(8))
					If SC1->(dbSeek(xFilial("SC1")+CO2->(CO2_CODEDT+CO2_NUMPRO+CO2_CODPRO)))
						While !SC1->(EOF()) .And. SC1->(C1_FILIAL+C1_CODED+C1_NUMPR+C1_PRODUTO) == CO2->(CO2_FILIAL+CO2_CODEDT+CO2_NUMPRO+CO2_CODPRO)
							//SC->EDT->PC
							aComa080 := {SD1->D1_PEDIDO,SD1->D1_ITEMPC,C080NF(SD1->D1_DOC,SD1->D1_SERIE,SD1->D1_FORNECE,SD1->D1_LOJA,IIf(SD1->D1_FORMUL=="S","S"," "))}
							COMA080(SC1->C1_NUM,SC1->C1_ITEM,"COH",aComa080,"COH_DTHCLS","COH_UCLS")
			 	    		SC1->(dbSkip())
				 		EndDo
				 	EndIf
				ElseIf SC8->(dbSeek(xFilial("SC8")+SC7->(C7_NUMCOT+C7_PRODUTO+C7_FORNECE+C7_LOJA+C7_NUM+C7_ITEM)))
					SC1->(dbSetOrder(5))
					If SC1->(dbSeek(xFilial("SC1")+SC8->(C8_NUM+C8_PRODUTO+C8_IDENT)))
						While !SC1->(EOF()) .And. (SC1->(C1_FILIAL+C1_COTACAO+C1_PRODUTO+C1_IDENT) == SC8->(C8_FILIAL+C8_NUM+C8_PRODUTO+C8_IDENT))
							//SC->COT->PC
							aComa080 := {SD1->D1_PEDIDO,SD1->D1_ITEMPC,C080NF(SD1->D1_DOC,SD1->D1_SERIE,SD1->D1_FORNECE,SD1->D1_LOJA,IIf(SD1->D1_FORMUL=="S","S"," "))}
							COMA080(SC1->C1_NUM,SC1->C1_ITEM,"COH",aComa080,"COH_DTHCLS","COH_UCLS")
	 				    	SC1->(dbSkip())
	 					EndDo
	 				EndIf
	 			Else
					//SC->PC
					aComa080 := {SD1->D1_PEDIDO,SD1->D1_ITEMPC,C080NF(SD1->D1_DOC,SD1->D1_SERIE,SD1->D1_FORNECE,SD1->D1_LOJA,IIf(SD1->D1_FORMUL=="S","S"," "))}
					COMA080(SC7->C7_NUMSC,SC7->C7_ITEMSC,"COH",aComa080,"COH_DTHCLS","COH_UCLS")
				EndIf
			EndIf
		EndIf
		
		//Exclusao da Pre-Nota classificada(NF) - MATA103
		If nEvento == 2
			SC7->(dbSetOrder(1))
			If SC7->(dbSeek(xFilial("SC7", iif(lOrigem,cFilBkp,Nil) )+SD1->D1_PEDIDO+SD1->D1_ITEMPC))
				CNE->(dbSetOrder(1))
				CO2->(dbSetOrder(1))
				SC8->(dbSetOrder(3))
				If CNE->(dbSeek(xFilial("CNE", iif(cFilAnt == cFilBkp,cFilAnt,cFilBkp) )+SC7->(C7_CONTRA+C7_CONTREV+C7_PLANILH+C7_MEDICAO)))
					CN9->(dbSetOrder(1))
					CN9->(dbSeek(xFilial("CN9", iif(cFilAnt == cFilBkp,cFilAnt,cFilBkp) )+CNE->(CNE_CONTRA+CNE_REVISA)))
					While !CNE->(EOF()) .And. CNE->(CNE_FILIAL+CNE_CONTRA+CNE_REVISA+CNE_NUMERO+CNE_NUMMED) == SC7->(C7_FILIAL+C7_CONTRA+C7_CONTREV+C7_PLANILH+C7_MEDICAO)
						If CNE->CNE_QUANT > 0 .And. PadL(CNE->CNE_ITEM,TamSX3("C7_ITEM")[1],"0") == SC7->C7_ITEM
							SC1->(dbSetOrder(11))
							CO2->(dbSetOrder(1))
							If SC1->(dbSeek(xFilial("SC1")+CNE->(CNE_CONTRA+CNE_PRODUT+"0"+CNE_ITEM)))
								//SC->CT->PC
								aComa080 := {SD1->D1_PEDIDO,SD1->D1_ITEMPC,C080NF(SD1->D1_DOC,SD1->D1_SERIE,SD1->D1_FORNECE,SD1->D1_LOJA,IIf(SD1->D1_FORMUL=="S","S"," "))}
								COMA080(SC1->C1_NUM,SC1->C1_ITEM,"COH",aComa080,"COH_DTHLPN","COH_ULPN",.T.,/*cUser*/,"COH_PNCHAV")
							ElseIf CO2->(dbSeek(xFilial("CO2")+CN9->(CN9_CODED+CN9_NUMPR)+CNE->CNE_PRODUT))
				    			SC1->(dbSetOrder(8))
								If SC1->(dbSeek(xFilial("SC1")+CO2->(CO2_CODEDT+CO2_NUMPRO+CO2_CODPRO)))
									While !SC1->(EOF()) .And. SC1->(C1_FILIAL+C1_CODED+C1_NUMPR+C1_PRODUTO) == CO2->(CO2_FILIAL+CO2_CODEDT+CO2_NUMPRO+CO2_CODPRO)
										//SC->EDT->CT->PC
										aComa080 := {SD1->D1_PEDIDO,SD1->D1_ITEMPC,C080NF(SD1->D1_DOC,SD1->D1_SERIE,SD1->D1_FORNECE,SD1->D1_LOJA,IIf(SD1->D1_FORMUL=="S","S"," "))}
										COMA080(SC1->C1_NUM,SC1->C1_ITEM,"COH",aComa080,"COH_DTHLPN","COH_ULPN",.T.,/*cUser*/,"COH_PNCHAV")
										SC1->(dbSkip())
									EndDo
								EndIf
							ElseIf SC8->(dbSeek(xFilial("SC8")+CN9->CN9_NUMCOT+CNE->CNE_PRODUT))
					 	  		SC1->(dbSetOrder(5))
					 	  		If SC1->(dbSeek(xFilial("SC1")+SC8->(C8_NUM+C8_PRODUTO+C8_IDENT)))
									While !SC1->(EOF()) .And. SC1->(C1_COTACAO+C1_PRODUTO+C1_IDENT) == SC8->(C8_NUM+C8_PRODUTO+C8_IDENT)
										//SC->COT->CT->PC
										aComa080 := {SD1->D1_PEDIDO,SD1->D1_ITEMPC,C080NF(SD1->D1_DOC,SD1->D1_SERIE,SD1->D1_FORNECE,SD1->D1_LOJA,IIf(SD1->D1_FORMUL=="S","S"," "))}
										COMA080(SC1->C1_NUM,SC1->C1_ITEM,"COH",aComa080,"COH_DTHLPN","COH_ULPN",.T.,/*cUser*/,"COH_PNCHAV")
										SC1->(dbSkip())
									EndDo
								EndIf
					 		EndIf
					 	EndIf
						CNE->(dbSkip())
					EndDo
				ElseIf CO2->(dbSeek(xFilial("CO2")+SC7->(C7_CODED+C7_NUMPR+C7_PRODUTO)))
					SC1->(dbSetOrder(8))
					If SC1->(dbSeek(xFilial("SC1")+CO2->(CO2_CODEDT+CO2_NUMPRO+CO2_CODPRO)))
						While !SC1->(EOF()) .And. SC1->(C1_FILIAL+C1_CODED+C1_NUMPR+C1_PRODUTO) == CO2->(CO2_FILIAL+CO2_CODEDT+CO2_NUMPRO+CO2_CODPRO)
							//SC->EDT->PC
							aComa080 := {SD1->D1_PEDIDO,SD1->D1_ITEMPC,C080NF(SD1->D1_DOC,SD1->D1_SERIE,SD1->D1_FORNECE,SD1->D1_LOJA,IIf(SD1->D1_FORMUL=="S","S"," "))}
							COMA080(SC1->C1_NUM,SC1->C1_ITEM,"COH",aComa080,"COH_DTHLPN","COH_ULPN",.T.,/*cUser*/,"COH_PNCHAV")
		 	    			SC1->(dbSkip())
				 		EndDo
				 	EndIf
				ElseIf SC8->(dbSeek(xFilial("SC8")+SC7->(C7_NUMCOT+C7_PRODUTO+C7_FORNECE+C7_LOJA+C7_NUM+C7_ITEM)))
					SC1->(dbSetOrder(5))
					If SC1->(dbSeek(xFilial("SC1")+SC8->(C8_NUM+C8_PRODUTO+C8_IDENT)))
						While !SC1->(EOF()) .And. (SC1->(C1_FILIAL+C1_COTACAO+C1_PRODUTO+C1_IDENT) == SC8->(C8_FILIAL+C8_NUM+C8_PRODUTO+C8_IDENT))
							//SC->COT->PC
							aComa080 := {SD1->D1_PEDIDO,SD1->D1_ITEMPC,C080NF(SD1->D1_DOC,SD1->D1_SERIE,SD1->D1_FORNECE,SD1->D1_LOJA,IIf(SD1->D1_FORMUL=="S","S"," "))}
							COMA080(SC1->C1_NUM,SC1->C1_ITEM,"COH",aComa080,"COH_DTHLPN","COH_ULPN",.T.,/*cUser*/,"COH_PNCHAV")
	 				    	SC1->(dbSkip())
 						EndDo
	 				EndIf
	 			Else
					//SC->PC
					aComa080 := {SD1->D1_PEDIDO,SD1->D1_ITEMPC,C080NF(SD1->D1_DOC,SD1->D1_SERIE,SD1->D1_FORNECE,SD1->D1_LOJA,IIf(SD1->D1_FORMUL=="S","S"," "))}
					COMA080(SC7->C7_NUMSC,SC7->C7_ITEMSC,"COH",aComa080,"COH_DTHLPN","COH_ULPN",.T.,/*cUser*/,"COH_PNCHAV")
				EndIf
			EndIf
		EndIf

		//Estorno da classificacao da Pre-Nota - MATA103
		If nEvento == 3
			SC7->(dbSetOrder(1))
			If SC7->(dbSeek(xFilial("SC7")+SD1->D1_PEDIDO+SD1->D1_ITEMPC))
				CNE->(dbSetOrder(1))
				CO2->(dbSetOrder(1))
				SC8->(dbSetOrder(3))
				If CNE->(dbSeek(xFilial("CNE", iif(cFilAnt == cFilBkp,cFilAnt,cFilBkp) )+SC7->(C7_CONTRA+C7_CONTREV+C7_PLANILH+C7_MEDICAO)))
					CN9->(dbSetOrder(1))
					CN9->(dbSeek(xFilial("CN9", iif(cFilAnt == cFilBkp,cFilAnt,cFilBkp) )+CNE->(CNE_CONTRA+CNE_REVISA)))
					While !CNE->(EOF()) .And. CNE->(CNE_FILIAL+CNE_CONTRA+CNE_REVISA+CNE_NUMERO+CNE_NUMMED) == SC7->(C7_FILIAL+C7_CONTRA+C7_CONTREV+C7_PLANILH+C7_MEDICAO)
						If CNE->CNE_QUANT > 0 .And. PadL(CNE->CNE_ITEM,TamSX3("C7_ITEM")[1],"0") == SC7->C7_ITEM
							SC1->(dbSetOrder(11))
							CO2->(dbSetOrder(1))
							If SC1->(dbSeek(xFilial("SC1")+CNE->(CNE_CONTRA+CNE_PRODUT+"0"+CNE_ITEM)))
								//SC->CT->PC
								aComa080 := {SD1->D1_PEDIDO,SD1->D1_ITEMPC,C080NF(SD1->D1_DOC,SD1->D1_SERIE,SD1->D1_FORNECE,SD1->D1_LOJA,IIf(SD1->D1_FORMUL=="S","S"," "))}
								COMA080(SC1->C1_NUM,SC1->C1_ITEM,"COH",aComa080,"COH_DTHCLS","COH_UCLS",.T.)
							ElseIf CO2->(dbSeek(xFilial("CO2")+CN9->(CN9_CODED+CN9_NUMPR)+CNE->CNE_PRODUT))
				    			SC1->(dbSetOrder(8))
								If SC1->(dbSeek(xFilial("SC1")+CO2->(CO2_CODEDT+CO2_NUMPRO+CO2_CODPRO)))
									While !SC1->(EOF()) .And. SC1->(C1_FILIAL+C1_CODED+C1_NUMPR+C1_PRODUTO) == CO2->(CO2_FILIAL+CO2_CODEDT+CO2_NUMPRO+CO2_CODPRO)
										//SC->EDT->CT->PC
										aComa080 := {SD1->D1_PEDIDO,SD1->D1_ITEMPC,C080NF(SD1->D1_DOC,SD1->D1_SERIE,SD1->D1_FORNECE,SD1->D1_LOJA,IIf(SD1->D1_FORMUL=="S","S"," "))}
										COMA080(SC1->C1_NUM,SC1->C1_ITEM,"COH",aComa080,"COH_DTHCLS","COH_UCLS",.T.)
										SC1->(dbSkip())
									EndDo
								EndIf
							ElseIf SC8->(dbSeek(xFilial("SC8")+CN9->CN9_NUMCOT+CNE->CNE_PRODUT))
					 	  		SC1->(dbSetOrder(5))
					 	  		If SC1->(dbSeek(xFilial("SC1")+SC8->(C8_NUM+C8_PRODUTO+C8_IDENT)))
									While !SC1->(EOF()) .And. SC1->(C1_COTACAO+C1_PRODUTO+C1_IDENT) == SC8->(C8_NUM+C8_PRODUTO+C8_IDENT)
										//SC->COT->CT->PC
										aComa080 := {SD1->D1_PEDIDO,SD1->D1_ITEMPC,C080NF(SD1->D1_DOC,SD1->D1_SERIE,SD1->D1_FORNECE,SD1->D1_LOJA,IIf(SD1->D1_FORMUL=="S","S"," "))}
										COMA080(SC1->C1_NUM,SC1->C1_ITEM,"COH",aComa080,"COH_DTHCLS","COH_UCLS",.T.)
										SC1->(dbSkip())
									EndDo
								EndIf
					 		EndIf
					 	EndIf
						CNE->(dbSkip())
					EndDo
				ElseIf CO2->(dbSeek(xFilial("CO2")+SC7->(C7_CODED+C7_NUMPR+C7_PRODUTO)))
					SC1->(dbSetOrder(8))
					If SC1->(dbSeek(xFilial("SC1")+CO2->(CO2_CODEDT+CO2_NUMPRO+CO2_CODPRO)))
						While !SC1->(EOF()) .And. SC1->(C1_FILIAL+C1_CODED+C1_NUMPR+C1_PRODUTO) == CO2->(CO2_FILIAL+CO2_CODEDT+CO2_NUMPRO+CO2_CODPRO)
							//SC->EDT->PC
							aComa080 := {SD1->D1_PEDIDO,SD1->D1_ITEMPC,C080NF(SD1->D1_DOC,SD1->D1_SERIE,SD1->D1_FORNECE,SD1->D1_LOJA,IIf(SD1->D1_FORMUL=="S","S"," "))}
							COMA080(SC1->C1_NUM,SC1->C1_ITEM,"COH",aComa080,"COH_DTHCLS","COH_UCLS",.T.)
			 	    		SC1->(dbSkip())
				 		EndDo
				 	EndIf
				ElseIf SC8->(dbSeek(xFilial("SC8")+SC7->(C7_NUMCOT+C7_PRODUTO+C7_FORNECE+C7_LOJA+C7_NUM+C7_ITEM)))
					SC1->(dbSetOrder(5))
					If SC1->(dbSeek(xFilial("SC1")+SC8->(C8_NUM+C8_PRODUTO+C8_IDENT)))
						While !SC1->(EOF()) .And. (SC1->(C1_FILIAL+C1_COTACAO+C1_PRODUTO+C1_IDENT) == SC8->(C8_FILIAL+C8_NUM+C8_PRODUTO+C8_IDENT))
							//SC->COT->PC
							aComa080 := {SD1->D1_PEDIDO,SD1->D1_ITEMPC,C080NF(SD1->D1_DOC,SD1->D1_SERIE,SD1->D1_FORNECE,SD1->D1_LOJA,IIf(SD1->D1_FORMUL=="S","S"," "))}
							COMA080(SC1->C1_NUM,SC1->C1_ITEM,"COH",aComa080,"COH_DTHCLS","COH_UCLS",.T.)
	 				    	SC1->(dbSkip())
 						EndDo
	 				EndIf
	 			Else
					//SC->PC
					aComa080 := {SD1->D1_PEDIDO,SD1->D1_ITEMPC,C080NF(SD1->D1_DOC,SD1->D1_SERIE,SD1->D1_FORNECE,SD1->D1_LOJA,IIf(SD1->D1_FORMUL=="S","S"," "))}
					COMA080(SC7->C7_NUMSC,SC7->C7_ITEMSC,"COH",aComa080,"COH_DTHCLS","COH_UCLS",.T.)
				EndIf
			EndIf
		EndIf
		
End Case 

//+--------------------------+
//|Recupero a Filial Logada  |
//+--------------------------+
cFilAnt := cFilBkp
SM0->(dbSeek(cEmpAnt+cFilAnt))

aEval(aAreas,{|x| RestArea(x), FwFreeArray(x) })
FwFreeArray(aAreas)
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณC080NF  ณRodrigo M Pontes     บ Data ณ  12/03/18			    บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Trata para que a chave do documento respeito o tamanho dos บฑฑ
ฑฑบ          ณ campos correspondentes                                     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function C080NF(cNF,cSeNF,cFoNF,cLoNF,cFPNF)

Local cRet			:= ""
Local nTamNF		:= TamSx3("F1_DOC")[1]
Local nTamSeNF	:= TamSx3("F1_SERIE")[1]
Local nTamFoNF	:= TamSx3("F1_FORNECE")[1]
Local nTamLoNF	:= TamSx3("F1_LOJA")[1]
Local nTamFPNF	:= TamSx3("F1_FORMUL")[1]

cRet := PadR(cNF,nTamNF) + PadR(cSeNF,nTamSeNF) + PadR(cFoNF,nTamFoNF) + PadR(cLoNF,nTamLoNF) + PadR(cFPNF,nTamFPNF)

Return cRet
