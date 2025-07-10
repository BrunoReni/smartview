#include 'Protheus.ch'
#include 'FWMVCDef.ch'
#INCLUDE "MATA020.CH"

/*/{Protheus.doc} MATA020EVDEF
Eventos padrão do Fornecedor, as regras definidas aqui se aplicam a todos os paises.
Se uma regra for especifica para um ou mais paises ela deve ser feita no evento do pais correspondente. 

Todas as validações de modelo, linha, pré e pos, também todas as interações com a gravação
são definidas nessa classe.

Importante: Use somente a função Help para exibir mensagens ao usuario, pois apenas o help
é tratado pelo MVC. 

Documentação sobre eventos do MVC: http://tdn.totvs.com/pages/viewpage.action?pageId=269552294

@type classe
 
@author Juliane Venteu
@since 02/02/2017
@version P12.1.17
/*/
CLASS MATA020EVDEF From FWModelEvent
	
	DATA lIntTAF
	DATA lIntLox
	DATA lHistFiscal
	DATA lHistTab
	DATA lIntegDef
	
	DATA cCodigo
	DATA cLoja
	DATA cFiliais

	DATA aCmps
	DATA aFilial

	DATA bCampoSA2
	
	DATA nOpc
	
	METHOD New() CONSTRUCTOR
	
	METHOD ModelPosVld()
	METHOD InsertPosVld()
	METHOD AlterarPosVld()
	METHOD DeletePosVld()
	METHOD ConfirmMATA020B()
	
	METHOD VldDUJ()
	METHOD VldNO7()
	METHOD VldCO3()

	METHOD InTTS()
	METHOD BeforeTTS()
	METHOD AfterTTS()
	
	METHOD HistAlt()
	
ENDCLASS

//-----------------------------------------------------------------
METHOD New() CLASS MATA020EVDEF
	::lIntTAF  	:= FindFunction("TAFExstInt") .AND. TAFExstInt()
	::lIntLox	:= GetMV("MV_QALOGIX") == "1"
	::lHistFiscal := HistFiscal() 
	::lHistTab   := GetNewPar("MV_HISTTAB", .F.)  
	::lIntegDef:=  FWHasEAI("MATA020",.T.,,.T.)
	
	::cCodigo := ""
	::cLoja := ""
	::cFiliais := ""

	::aCmps := {}
	::aFilial := {}

	::bCampoSA2 := { |x| Field(x) }
Return

/*/{Protheus.doc} ModelPosVld
Executa a validação do modelo antes de realizar a gravação dos dados.
Se retornar falso, não permite gravar.

@type metodo
 
@author Juliane Venteu
@since 02/02/2017
@version P12.1.17
 
/*/
METHOD ModelPosVld(oModel, cID) CLASS MATA020EVDEF
Local lValid := .T.
	
	::nOpc := oModel:GetOperation()
	::cCodigo := oModel:GetValue("SA2MASTER","A2_COD")
	::cLoja := oModel:GetValue("SA2MASTER","A2_LOJA")
		
	If ::nOpc == MODEL_OPERATION_INSERT
		lValid := ::InsertPosVld()
	ElseIf ::nOpc == MODEL_OPERATION_UPDATE
		lValid := ::AlterarPosVld()
	ElseIf ::nOpc == MODEL_OPERATION_DELETE
		lValid := ::DeletePosVld()
	EndIf	

Return lValid

METHOD InsertPosVld() CLASS MATA020EVDEF
Local lValid := .T.
		
	lValid := ExistChav("SA2",::cCodigo+::cLoja)

	If lValid .And. ::lIntLox
		Help( ,, 'HELP',, STR0034, 1, 0) //"Por favor, realize a inclusao do fornecedor pelo ambiente Logix."
		lValid := .F.
	EndIf

	If lValid
		lValid := ::AlterarPosVld()
	EndIf
	
	If lValid
		lValid := ::ConfirmMata020B()
	Else
		::ConfirmMata020B(.F.)
	EndIf
		
Return lValid

METHOD AlterarPosVld() CLASS MATA020EVDEF 
Local lValid := .T.
Local lUsaFilTrf := IIF(FindFunction('UsaFilTrf'), UsaFilTrf(), .F.)
Local aAreaSA2
Local nOperation := ::nOpc

	If QE6->(LastRec())>0
		If !Empty(M->A2_FATAVA) .And. (Empty(M->A2_DTAVA) .Or. Empty(M->A2_DTVAL))
			Help( ,, 'HELP',, TRIM(::cCodigo)+"/"+TRIM(::cLoja)+" => "+STR0010, 1, 0) // "Datas Avaliaâ„¡o/Validade nãƒ» especificadas."###"Atenâ„¡o"			
			lValid := .F.
		EndIf
		
		If lValid
			If M->A2_DTAVA > M->A2_DTVAL
				lValid := .F.
			EndIf
		EndIf
			
	EndIf

	Inclui := .F.
	If nOperation == 3
	   Inclui := .T.
	EndIF
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Utilizado no Modulo PLS para verificar Homonimos	   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lValid .And. SuperGetMV("MV_PLSHOMO",,.F.) 
		If SA2->(FieldPos("A2_MATVID")) >0 
			PlsHomoni(M->A2_NOME,M->A2_CGC,M->A2_CONREG,NIL,M->A2_INSCR,M->A2_INSCRM,NIL,"SA2",M->A2_MATVID,Inclui)    
		EndIf
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Validacao do campo A1_FILTRF.(UPDEST39)                       ³
	//³Verificar se a filial informada neste campo existe realmente. ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lValid .And. lUsaFilTrf
		If !Empty(M->A2_FILTRF)
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Valida se a filial informada existe realmente                  |
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			lValid := IIf(FindFunction('MtValidFil'), MtValidFil(cEmpAnt+M->A2_FILTRF), lValid)
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verificar se nao existe outro cliente com a mesma filial associada |
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lValid
				aAreaSA2 := SA2->(GetArea())
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Monta filtro e indice temporario na SA2 ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				cArqIdx := CriaTrab(,.F.)
				IndRegua("SA2", cArqIdx, "A2_FILIAL+A2_FILTRF") //"Selecionando Registros ..."
				nIndex := RetIndex('SA2')
				#IFNDEF TOP
					dbSetIndex(cArqIdx+OrdBagExt())
				#ENDIF
				dbSetOrder(nIndex+1) // A1_FILIAL+A1_FILTRF
				If dbSeek(xFilial('SA2')+M->A2_FILTRF) .And. (SA2->A2_COD <> M->A2_COD)
					Help("",1,"SAVALFOR",, STR0044+': '+SA2->A2_COD+' - '+STR0045+': '+SA2->A2_LOJA, 4, 11 )
					lValid := .F.
				EndIf			
				RetIndex("SA2")
				Ferase( cArqIdx + OrdBagExt() )
				RestArea(aAreaSA2)
			EndIf
		EndIf
	EndIf
	
	If ::lHistFiscal .And. lValid .And. ::nOpc == MODEL_OPERATION_UPDATE	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica se algum campo foi alterado.³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If SA2->(FieldPos("A2_IDHIST"))>0 .And. ::lHistFiscal
			::aCmps 		 :=  RetCmps("SA2",::bCampoSA2)	
			M->A2_IDHIST := IdHistFis()
		EndIf		
	EndIf

	If lValid .AND. nModulo == 85 .AND. SuperGetMV("MV_ESS0027",,9) >= 10 .AND. FindFunction("RS400VldNIF") // GFP - 04/07/2016 - Validação SIGAESS
		lValid := RS400VldNIF("SA2")
	EndIf

	//-- Integracao Protheus x DRP NeoGrid (ALTERACAO)
	If lValid .and. ::nOpc == MODEL_OPERATION_UPDATE
		If SA2->(FieldPos("A2_DRPEXP")) > 0 
			M->A2_DRPEXP := ""   		
		EndIf
	EndIf

Return lValid

/*/{Protheus.doc} DeletePosVld
Verifica se o fornecedor pode ser excluido, verificando o SA2 x tabelas relacionadas.

@type metodo
 
@author Juliane Venteu
@since 02/02/2017
@version P12.1.17
 
/*/
METHOD DeletePosVld() CLASS MATA020EVDEF
Local lValid := .T.
Local aArea     := GetArea()
Local aAreaSA5  := SA5->(GetArea())
Local aAreaSM0  := SM0->(GetArea())
Local cBckFil    := cFilAnt
Local lNGVALSX9	:= FindFunction("NGVALSX9")
Local nX

	If ::lIntLox
		Help( ,, 'HELP',, STR0033, 1, 0) //"Realizar ADMIN	a exclusao do fornecedor/loja pelo ambiente Logix"
		lValid := .F.
	EndIf
	
	::cFiliais := "IN ("
	If Empty(xFilial("SA2"))
		dbSelectArea("SM0")
		MsSeek(cEmpAnt)
		While ! Eof() .And. SM0->M0_CODIGO == cEmpAnt
			Aadd(::aFilial,FWGETCODFILIAL)
			::cFiliais += "'"+FWGETCODFILIAL+"', "
			dbSkip()
		EndDo
	Else
		aadd(::aFilial,cFilAnt)
		::cFiliais += "'"+FWGETCODFILIAL+"', "
	EndIf
	::cFiliais := Left(::cFiliais, Len(::cFiliais)-2)+')'

	If lValid
		lValid := ::VldDUJ()
	EndIf
	
	If lValid
		lValid := ::VldNO7()
	EndIf

	If lValid
		lValid := ::VldCO3()
	EndIf

	For nX := 1 To Len(::aFilial)
		cFilAnt := ::aFilial[nX]
				
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Funcao Especifica NG INFORMATICA                           ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lValid .And. lNGVALSX9
			lValid := NGVALSX9("SA2",{"TMD","TN3","TNF"},.T.)
		Endif
								
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	    //³ Chamada de função para validação nos módulos SIGAEIC/SIGAESS     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	   	If lValid .AND. (nModulo == 17 .OR. nModulo == 85)
		   lValid := EICDelForn()
	   	EndIf
		
		If !lValid
			Exit
		EndIf
	Next nX

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Funcao Especifica SIGAMDT - NG INFORMATICA                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lValid
		If FindFunction("MdtValESA2")
			lValid := MdtValESA2(::cCodigo+::cLoja)
		EndIF
	Endif
			
	If ::lHistFiscal .And. lValid   
	   ::aCmps :=  RetCmps("SA2",::bCampoSA2)	   
	EndIf 		
		
	cFilAnt := cBckFil

RestArea(aAreaSM0)
RestArea(aAreaSA5)
RestArea(aArea)
Return lValid

METHOD VldDUJ() CLASS MATA020EVDEF
Local lValid := .T.
Local cQuery
Local cAliasQry
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se existe o Contrato de Fornecedores                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cQuery := "SELECT COUNT(*) QTDDUJ "
	cQuery += "FROM " + RetSQLName("DUJ") + " DUJ "
	If !Empty(xFilial("DUJ"))
		cQuery += "WHERE DUJ.DUJ_FILIAL " + ::cFiliais + " AND "
	Else
		cQuery += "WHERE DUJ.DUJ_FILIAL = '"+xFilial("DUJ")+"' AND "
	EndIf
	cQuery += "DUJ.DUJ_CODFOR = '"+::cCodigo+"' AND "
	cQuery += "DUJ.DUJ_LOJFOR = '"+::cLoja+"' AND "
	cQuery += "DUJ.D_E_L_E_T_ = ' '"
							
	cAliasQry := GetNextAlias()
							
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.F.,.T.)
							
	If (cAliasQry)->QTDDUJ > 0
		Help(" ",1,"A020CON",,STR0052,3,0) //"Este fornecedor não pode ser excluído, pois está sendo utilizado no cadastro de Contrato de Fornecedores"
		lValid := .F.
	EndIf
						
	(cAliasQry)->(dbCloseArea())
	
Return lValid

METHOD VldNO7() CLASS MATA020EVDEF
Local lValid := .T.
Local cQuery
Local cAliasQry
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se existe Contrato Financeiro para este fornecedor - modulo Gestao Agricola ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cQuery := "SELECT COUNT(*) QTDNO7 "
	cQuery += "FROM " + RetSQLName("NO7") + " NO7 "
	If !Empty(xFilial("NO7"))
		cQuery += "WHERE NO7.NO7_FILIAL " + ::cFiliais + " AND "
	Else
		cQuery += "WHERE NO7.NO7_FILIAL = '"+xFilial("NO7")+"' AND "
	EndIf
	cQuery += "NO7.NO7_CODFOR = '"+::cCodigo+"' AND "
	cQuery += "NO7.NO7_LOJFOR = '"+::cLoja+"' AND "
	cQuery += "NO7.D_E_L_E_T_ = ' '"
						
	cAliasQry := GetNextAlias()
						
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.F.,.T.)
						
	If (cAliasQry)->QTDNO7 > 0
		Help(" ",1,"MA020AGR",,"Filial: " + xFilial("NO7"),3,0)
		lValid := .F.
	EndIf
					
	(cAliasQry)->(dbCloseArea())
	
Return lValid

METHOD VldCO3() CLASS MATA020EVDEF
Local lValid := .T.
Local cQuery
Local cAliasQry

	//------------------------------------------------------------------- 
	// Verifica se o Fornecedor está associado a algum processo licitatório.
	//-------------------------------------------------------------------
	cQuery := "SELECT COUNT (CO3.CO3_CODIGO) CODIGO " 
	cQuery += "FROM " + RetSQLName("CO3") + " CO3 "
	If !Empty(xFilial("CO3"))
		cQuery += "WHERE CO3.CO3_FILIAL " + ::cFiliais + " AND "
	Else
		cQuery += "WHERE CO3.CO3_FILIAL = '"+xFilial("CO3")+"' AND "
	EndIf
	cQuery += "CO3.CO3_CODIGO = '"+::cCodigo+"' AND "
	cQuery += "CO3.CO3_LOJA = '"+::cLoja+"' AND "
	cQuery += "CO3.D_E_L_E_T_ = ' '"
					
	cAliasQry := GetNextAlias()
					
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.F.,.T.)
					
	If (cAliasQry)->CODIGO > 0
		Help(" ",1,"NODELETA")
		lValid := .F.
	EndIf
				
	(cAliasQry)->(dbCloseArea())
	
Return lValid

Method AfterTTS(oModel,cID) Class MATA020EVDEF
    
    Local cEventID    := "036"
    Local nOperation    := oModel:GetOperation()
    
    If nOperation == MODEL_OPERATION_INSERT
        MEnviaMail(cEventID,{SA2->A2_FILIAL,SA2->A2_COD,SA2->A2_LOJA,SA2->A2_NOME,SA2->A2_NREDUZ,CUSERNAME})
    EndIf
     
Return Nil 

METHOD InTTS(oModel, cID) CLASS MATA020EVDEF 
Local nX
Local cBckFil    := cFilAnt
Local aArea := GetArea()
	
	If ::nOpc == MODEL_OPERATION_UPDATE			
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Altera descricao da Amarracao Produto x Fornecedor           ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		For nX := 1 To Len(::aFilial)
			cFilAnt := ::aFilial[nX]
			If mv_par01 == 1
				If SA5->(FieldPos("A5_NOMEFOR")) > 0
					If !Empty(xFilial("SA5")) .Or. cFilAnt == cBckFil
						dbSelectArea("SA5")
						dbSetOrder(1)
						MsSeek( xFilial("SA5")+SA2->A2_COD+SA2->A2_LOJA)
						While !Eof() .And. SA5->A5_FILIAL == xFilial("SA5") .And.;
							SA5->A5_FORNECE == SA2->A2_COD .And.;
							SA5->A5_LOJA == SA2->A2_LOJA

							RecLock("SA5",.F.)
							SA5->A5_NOMEFOR := SA2->A2_NOME
							MsUnLock()

							dbSelectArea("SA5")
							dbSkip()
						EndDo
					EndIf
				EndIf

				If !Empty(xFilial("SAD")) .Or. cFilAnt == cBckFil
					dbSelectArea("SAD")
					dbSetOrder(1)
					MsSeek( xFilial("SAD")+SA2->A2_COD+SA2->A2_LOJA)
					While !Eof() .And. SAD->AD_FILIAL == xFilial("SAD") .And.;
						SAD->AD_FORNECE == SA2->A2_COD .And.;
						SAD->AD_LOJA == SA2->A2_LOJA

						RecLock("SAD",.F.)
						SAD->AD_NOMEFOR := SA2->A2_NOME
						MsUnLock()

						dbSelectArea("SAD")
						dbSkip()
					EndDo
				EndIf
			EndIf
		Next nX
		
		//Replica as alterações para a tabela TQF (Postos de Combustiveis)
		If FindFunction("NGCADICBASE") .And. NGCADICBASE('TQF_CODIGO','D','TQF',.F.)
			dbSelectArea("TQF")
			dbSetOrder(01)
			If dbSeek(xFilial("TQF")+SA2->A2_COD+SA2->A2_LOJA)
			   RecLock("TQF",.F.)
			   TQF->TQF_NREDUZ := M->A2_NREDUZ
			   TQF->TQF_BAIRRO := M->A2_BAIRRO
			   TQF->TQF_CIDADE := M->A2_MUN
			   TQF->TQF_ESTADO := M->A2_EST
			   TQF->TQF_CONTFN := MATAFN()
			   TQF->TQF_CNPJ   := SA2->A2_CGC
			   MsUnLock("TQF")
			EndIf
		EndIf
		      
		If ::lHistFiscal .And. Len(::aCmps)>0 
			GrvHistFis("SA2", "SS3", ::aCmps)				
		EndIf
		
	ElseIf ::nOpc == MODEL_OPERATION_DELETE
		//Remove a amarracao cod. Externo X cod. Interno - tabela XXF - De/Para
		If FWHasEAI("MATA020",.T.,.T.,.T.)
			CFGA070Mnt(,"SA2","A2_COD",::cCodigo+::cLoja,.T.)  
		EndIf
		
		For nX := 1 To Len(::aFilial)
			cFilAnt := ::aFilial[nX]
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Apaga tambem do SA5 -> amarracao produto x fornecedor        ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If !Empty(xFilial("SA5")) .Or. cFilAnt == cBckFil
				dbSelectArea("SA5")
				dbSetOrder(1)
				MsSeek(xFilial("SA5")+SA2->A2_COD+SA2->A2_LOJA)
				While !Eof() .And. SA5->A5_FILIAL == xFilial("SA5") .And.;
					SA5->A5_FORNECE == SA2->A2_COD .And.;
					SA5->A5_LOJA == SA2->A2_LOJA

					RecLock("SA5",.F.)
					dbDelete()
					MsUnLock()
					
					dbSelectArea("SA5")
					dbSkip()
				EndDo                                              
			EndIf
		Next nX
		
		If ::lHistFiscal .And. Len(::aCmps)>0 
			GrvHistFis("SA2", "SS3", ::aCmps)			
		EndIf
		
		GeoSavCoor(xFilial("SA2"),"SA2",SA2->A2_COD+SA2->A2_LOJA,/*cLatitude*/,/*cLongitude*/,.F.,.T.)			
	EndIf

	cFilAnt := cBckFil
		
RestArea(aArea)		
Return

/*/{Protheus.doc} HistAlt
Grava os campos alterados do cadastro do fornecedor.

@type metodo
 
@author Juliane Venteu
@since 02/02/2017
@version P12.1.17
 
/*/
METHOD HistAlt(oFieldSA2) CLASS MATA020EVDEF
Local dDataAlt := Date()
Local cHoraAlt := Time()
Local cFilialAIF := xFilial("AIF")
Local cFilialSA2 := xFilial("SA2")
Local aFields := oFieldSA2:GetStruct():GetFields()
Local nX
	
	//--------------------------------------------------------------------------------
	// Cria o historico das alteracoes antes de gravar os novos dados do fornecedor.
	// Se deixa pra fazer depois de gravar, não tem como pegar os valores que estavam
	// nos campos antes da alteração
	//--------------------------------------------------------------------------------	
	For nX:=1 to Len(aFields)
		If !aFields[nX][MODEL_FIELD_VIRTUAL] .And. oFieldSA2:IsFieldUpdated(aFields[nX][MODEL_FIELD_IDFIELD])
			MSGrvHist(cFilialAIF,;			// Filial de AIF
			          cFilialSA2,;			// Filial da tabela SA2
			          "SA2",;				// Tabela SA2
			          ::cCodigo,;			// Codigo do cliente
			          ::cLoja,;		// Loja do cliente
			          aFields[nX][MODEL_FIELD_IDFIELD],;	// Campo alterado
			          SA2->&(aFields[nX][MODEL_FIELD_IDFIELD]),;	// Conteudo antes da alteracao
			          dDataAlt,;			// Data da alteracao
			          cHoraAlt)				// Hora da alteracao	
		EndIf
	Next nX
	
Return

/*/{Protheus.doc} BeforeTTS
Executado dentro da transação, antes da gravação dos dados do fornecedor.

@type metodo
 
@author Juliane Venteu
@since 02/02/2017
@version P12.1.17
 
/*/
METHOD BeforeTTS(oModel, cID) CLASS MATA020EVDEF

	If ::nOpc == MODEL_OPERATION_UPDATE
		::HistAlt(oModel:getModel("SA2MASTER"))
	EndIf

Return

/*/{Protheus.doc} ConfirmMata020B
Confirmação da gravação da CustomerVendorReserveId

@type function
 
@author José Eulálio
@since 28/08/2017
@version P12.1.17
 
/*/
METHOD ConfirmMata020B(lConfirma) CLASS MATA020EVDEF
Local lRet			:= .T.
Local lIntUnqCod 	:= FwHasEAI("MATA020B")

Default lConfirma	:= .T.

RegToMemory("SA2", .F. )

//-- Inclusão ou Cancelamento da CustomerVendorReservID
If lIntUnqCod
	If lConfirma 						
		lRet	:= MATA020B(.T.,SA2->A2_COD,"MATA020", .F. , .T. , .F. )
	Else
		lIncluiBkp	:= INCLUI
		lAlteraBkp	:= ALTERA		
			
		INCLUI	:= .F. 
		ALTERA	:= .F. 		
		
		MATA020B(.T.,M->A2_COD,"MATA020", .F. , .T. , .F. )			
		
		INCLUI	:= lIncluiBkp	
		ALTERA	:= lAlteraBkp
	EndIf				
EndIf	

Return lRet

//------------------------------------------------------------------------------------------------------------------

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ MATAFN   ³ Autor ³ NG Informatica - Ltda ³ Data ³14/12/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Campo telefone c/DDD e Fone do SA2                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Tabelas   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATA020                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Telefone com DDD                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador          ³ Data   ³ F.O  ³  Motivo da Alteracao            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Evaldo Cevinscki Jr. ³14/12/06³      ³ Criacao da Funcao               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MATAFN()
Local cTel	:= ""
Local n	:= 0
Local nTam	:= 0

cTel := AllTrim(M->A2_DDD+M->A2_TEL) 

n := AT("-",cTel)
If n > 0
	cTel := SubStr(cTel,1,n-1)+SubStr(cTel,n+1,Len(cTel))
EndIf	

nTam := Len(AllTrim(cTel))
If SubStr(cTel,1,1) == "0"
   cTel := SubStr(cTel,2,nTam)
EndIf
If nTam <= 8
  	cTel := "xx"+cTel
EndIf	

Return cTel
