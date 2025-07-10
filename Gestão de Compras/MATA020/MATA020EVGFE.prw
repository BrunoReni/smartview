#include 'Protheus.ch'
#include 'FWMVCDef.ch'
#include 'MATA020.ch'

/*/{Protheus.doc} MATA020EVGFE
Eventos do MVC relacionados a integração de Fornecedor com o modulo GFE.
Qualquer regra que seja referente ao GFE deve ser criada aqui.

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
CLASS MATA020EVGFE FROM FWModelEvent

	DATA oModelGU3F

	DATA nOPC

	DATA lMATA020IPG

	METHOD New() CONSTRUCTOR
	METHOD ModelPosVld()
	METHOD InTTS(oModel, nOpc)
	METHOD Destroy()

	METHOD VldPE()
	METHOD VldGU3()
	METHOD RegraIdSA2()

ENDCLASS

//-----------------------------------------------------------------
METHOD New() CLASS MATA020EVGFE
	::lMATA020IPG := ExistBlock("MATA020IPG")
Return

/*/{Protheus.doc} ModelPosVld
Executa a validação do modelo antes de realizar a gravação dos dados.
Se retornar falso, não permite gravar.

@type metodo

@author Juliane Venteu
@since 02/02/2017
@version P12.1.17

/*/
METHOD ModelPosVld(oModel, cID) CLASS MATA020EVGFE
Local lValid := .T.
Local lRetIPG:= .T.

	::nOPC := oModel:GetOperation()

	lRetIPG := ::VldPE()

	If lRetIPG
		lValid := ::VldGU3(oModel)
	EndIf

Return lValid

/*/{Protheus.doc} VldPE
Executa, se existir, o ponto de entrada MATA020IPG que define se a integração deve ser efetuada.

@type metodo

@author Juliane Venteu
@since 02/02/2017
@version P12.1.17

/*/
METHOD VldPE() CLASS MATA020EVGFE
Local lValid := .T.

	If ::lMATA020IPG
		lValid := ExecBlock( 'MATA020IPG' , .F. , .F. , {::nOPC} )
	EndIf

Return lValid

/*/{Protheus.doc} InTTS
Realiza a gravação dos dados do fornecedor no GFE.
Se chegou até aqui é porque os dados já foram todos validados, então só precisa gravar.

@type metodo

@author Juliane Venteu
@since 02/02/2017
@version P12.1.17

/*/
METHOD InTTS(oModel, nOpc) CLASS MATA020EVGFE
	If ::oModelGU3F <> NIL
		::oModelGU3F:CommitData()
		::oModelGU3F:Deactivate()
	Endif
	FWModelActive(oModel)
Return

/*/{Protheus.doc} VldGU3
Cria o modelo de dados do GFE, seta os dados do fornecedor e valida se os dados estão corretos.
Se retornar algum erro, impede que o usuario grave os dados.

Aqui é realizada apenas a validação do modelo do GFE, a gravação é efetuada apenas depois da gravação
dos dados do fornecedor.

@type metodo

@author Juliane Venteu
@since 02/02/2017
@version P12.1.17

/*/
METHOD VldGU3(oModelSA2) CLASS MATA020EVGFE
Local lRet			:= .T.
Local nTipoOpSet	:= 0
Local cMsg			:= ""
Local cIdFor		:= ""
Local cRet			:= "2"
Local lNumProp		:= Iif(FindFunction( "GFEEMITMP"),GFEEMITMP(),.F.)
Local lEAICodUnq	:= TMSCODUNQ()
Local lTMSGFE    	:= TmsIntGFE()
Private N := 1

	If ::oModelGU3F == NIL
		// ---------------------------------------------------------------------------------------------
		// Se faz a criação no NEW do evento, gera um erro de uma private de algum fonte relacionado
		//----------------------------------------------------------------------------------------------
		::oModelGU3F := FWLoadModel("GFEA015")
	Else
		::oModelGU3F:Deactivate()
		FWModelActive(oModelSA2)
	EndIf

	If !lNumProp
		cIdFor := ::RegraIdSA2(::nOPC,@lRet,@cMsg)
	ElseIf lEAICodUnq
		cIdFor := Iif(::nOPC == MODEL_OPERATION_DELETE, SA2->A2_COD, M->A2_COD)
	EndIf

	If lRet
		If !lNumProp .Or. lEAICodUnq
			GU3->(dbSetOrder(1))
			GU3->(dbSeek(xFilial("GU3")+cIdFor))
			If !GU3->(EOF()) .And. GU3->GU3_FILIAL == xFilial("GU3");
					.And. AllTrim(GU3->GU3_CDEMIT) == AllTrim(cIdFor);

					::oModelGU3F:SetOperation(MODEL_OPERATION_UPDATE)
				nTipoOpSet := MODEL_OPERATION_UPDATE
			Else
				::oModelGU3F:SetOperation(MODEL_OPERATION_INSERT)
				nTipoOpSet := MODEL_OPERATION_INSERT
			EndIf
		Else
			If FindFunction( "GFEM011COD")
				If ::nOpc == MODEL_OPERATION_INSERT .Or. ::nOpc == MODEL_OPERATION_UPDATE
					cIdFor := GFEM011COD(M->A2_COD,M->A2_LOJA,2,,)
				Else
					cIdFor := GFEM011COD(SA2->A2_COD,SA2->A2_LOJA,2,,)
				EndIf
			EndIf	

			If Empty(cIdFor)
				If ::nOpc == MODEL_OPERATION_INSERT .Or. ::nOpc == MODEL_OPERATION_UPDATE
					::oModelGU3F:SetOperation(MODEL_OPERATION_INSERT)
					nTipoOpSet := MODEL_OPERATION_INSERT
				Elseif ::nOpc = MODEL_OPERATION_DELETE
					::oModelGU3F:SetOperation(MODEL_OPERATION_DELETE)
					nTipoOpSet := MODEL_OPERATION_DELETE
				Endif
			Else
				GU3->(dbSetOrder(1))
				If GU3->(MsSeek(xFilial("GU3")+cIdFor))
					If ::nOpc == MODEL_OPERATION_INSERT .Or. ::nOpc == MODEL_OPERATION_UPDATE
						::oModelGU3F:SetOperation(MODEL_OPERATION_UPDATE)
						nTipoOpSet := MODEL_OPERATION_UPDATE
					Elseif ::nOpc = MODEL_OPERATION_DELETE
						::oModelGU3F:SetOperation(MODEL_OPERATION_DELETE)
						nTipoOpSet := MODEL_OPERATION_DELETE
					Endif
				Else
					lRet := .F.
				EndIf
			EndIf
		EndIf

		::oModelGU3F:Activate()

		If ::nOpc <> MODEL_OPERATION_DELETE
			::oModelGU3F:SetValue('GFEA015_GU3','GU3_NMEMIT',M->A2_NOME)
			::oModelGU3F:SetValue('GFEA015_GU3','GU3_NMFAN' ,M->A2_NREDUZ)
			::oModelGU3F:SetValue('GFEA015_GU3','GU3_NATUR' ,M->A2_TIPO)
			::oModelGU3F:LoadValue('GFEA015_GU3','GU3_FORN'  ,'1')
			::oModelGU3F:LoadValue('GFEA015_GU3','GU3_EMFIL',IIF(M->A2_TIPO<>'X',A030CliFil(M->A2_CGC),'2') )
			::oModelGU3F:SetValue('GFEA015_GU3','GU3_ENDER' ,M->A2_END)
			::oModelGU3F:SetValue('GFEA015_GU3','GU3_COMPL' ,M->A2_COMPLEM)
			::oModelGU3F:SetValue('GFEA015_GU3','GU3_BAIRRO',M->A2_BAIRRO)
			::oModelGU3F:SetValue('GFEA015_GU3','GU3_CEP'   ,M->A2_CEP)
			::oModelGU3F:LoadValue('GFEA015_GU3','GU3_NRCID' ,TMS120CDUF(M->A2_EST, '1')+M->A2_COD_MUN)
			::oModelGU3F:SetValue('GFEA015_GU3','GU3_NMCID' ,M->A2_MUN)
			::oModelGU3F:SetValue('GFEA015_GU3','GU3_UF'    ,M->A2_EST)
			::oModelGU3F:SetValue('GFEA015_GU3','GU3_IDFED' ,IIF(M->A2_TIPO <> 'X',M->A2_CGC,''))
			::oModelGU3F:SetValue('GFEA015_GU3','GU3_IE'    ,M->A2_INSCR)
			::oModelGU3F:SetValue('GFEA015_GU3','GU3_IM'    ,M->A2_INSCRM)
			::oModelGU3F:SetValue('GFEA015_GU3','GU3_CXPOS' ,SubStr(M->A2_CX_POST,1,10))
			::oModelGU3F:SetValue('GFEA015_GU3','GU3_EMAIL' ,M->A2_EMAIL)
			::oModelGU3F:SetValue('GFEA015_GU3','GU3_FONE1' ,SubStr(M->A2_TEL,1,15))
			::oModelGU3F:SetValue('GFEA015_GU3','GU3_FAX'   ,M->A2_FAX)
			::oModelGU3F:SetValue('GFEA015_GU3','GU3_WSITE' ,M->A2_HPAGE)
			::oModelGU3F:SetValue('GFEA015_GU3','GU3_CONICM',M->A2_CONTRIB)

			If M->A2_SIMPNAC == "1"
				::oModelGU3F:SetValue('GFEA015_GU3','GU3_TPTRIB' ,"2")
			ElseIf M->A2_SIMPNAC == "2"
				::oModelGU3F:SetValue('GFEA015_GU3','GU3_TPTRIB' ,"1")
			EndIf

			::oModelGU3F:SetValue('GFEA015_GU3','GU3_CONICM',M->A2_CONTRIB)

			If M->A2_SIMPNAC == "1"
				::oModelGU3F:SetValue('GFEA015_GU3','GU3_TPTRIB' ,"2")
			Elseif M->A2_SIMPNAC == "2"
				::oModelGU3F:SetValue('GFEA015_GU3','GU3_TPTRIB' ,"1")
			Endif

			If lTMSGFE .And. M->A2_PAGGFE == StrZero(1, Len(SA2->A2_PAGGFE))
				::oModelGU3F:LoadValue( 'GFEA015_GU3', 'GU3_TRANSP', If(M->A2_TIPO == 'J', '1', '2') )
				::oModelGU3F:LoadValue( 'GFEA015_GU3', 'GU3_AUTON' , If(M->A2_TIPO == 'F', '1', '2') )
			ElseIf lNumProp
				If FindFunction( "GFEM011TRP")
					::oModelGU3F:LoadValue( 'GFEA015_GU3', 'GU3_CDTERP' , GFEM011TRP(M->A2_CGC, M->A2_INSCR) )
				EndIf
				::oModelGU3F:LoadValue( 'GFEA015_GU3', 'GU3_TRANSP' , IsPJouPF('1','SA2')  )		
				::oModelGU3F:LoadValue( 'GFEA015_GU3', 'GU3_AUTON'  , IsPJouPF('2','SA2')  )							
			EndIf

			If nTipoOpSet == MODEL_OPERATION_UPDATE
				If ::nOpc == MODEL_OPERATION_INSERT .And. GU3->GU3_SIT <> "1" .And. M->A2_MSBLQL <> "1"
					::oModelGU3F:LoadValue('GFEA015_GU3','GU3_SIT',"1")
				EndIf
			Else
				::oModelGU3F:SetValue('GFEA015_GU3','GU3_FILIAL', xFilial("SA2") )

				If !lNumProp
					::oModelGU3F:SetValue('GFEA015_GU3','GU3_CDEMIT',cIdFor)
				Else
					If lEAICodUnq
						::oModelGU3F:SetValue('GFEA015_GU3','GU3_CDEMIT',cIdFor)
					Else
						::oModelGU3F:LoadValue('GFEA015_GU3','GU3_CDEMIT',GETSXENUM('GU3','GU3_CDEMIT'))
					EndIf
					::oModelGU3F:SetValue('GFEA015_GU3','GU3_CDERP' ,M->A2_COD)
					::oModelGU3F:SetValue('GFEA015_GU3','GU3_CDCERP',M->A2_LOJA)
				EndIf

				::oModelGU3F:LoadValue( 'GFEA015_GU3', 'GU3_ORIGEM', "2" )
			EndIf
			If M->A2_MSBLQL == "1"
				If lNumProp
					::oModelGU3F:LoadValue( 'GFEA015_GU3', 'GU3_FORN' , '1' )
					::oModelGU3F:LoadValue( 'GFEA015_GU3', 'GU3_SIT', '2' )
				Else
					::oModelGU3F:LoadValue( 'GFEA015_GU3', 'GU3_FORN' , '2' )
					::oModelGU3F:LoadValue( 'GFEA015_GU3', 'GU3_SIT', '2' )
				EndIf
				If nTipoOpSet == MODEL_OPERATION_UPDATE
					If GU3->GU3_CLIEN == "2" .And. GU3->GU3_EMFIL == "2" .And. GU3->GU3_TRANSP == "2" .And. GU3->GU3_AUTON == "2"
						::oModelGU3F:LoadValue( 'GFEA015_GU3', 'GU3_SIT', '2' )
					EndIf
				EndIf
			Else
				::oModelGU3F:LoadValue( 'GFEA015_GU3', 'GU3_FORN' , '1' )
				::oModelGU3F:LoadValue( 'GFEA015_GU3', 'GU3_SIT', '1' )
			EndIf
		Else
			If nTipoOpSet <> MODEL_OPERATION_DELETE
				::oModelGU3F:LoadValue( 'GFEA015_GU3', 'GU3_FORN'  , '2' )
				cRet := IIF(GU3->GU3_CLIEN == "2" .And. GU3->GU3_EMFIL == "2" .And. GU3->GU3_TRANSP == "2" .And. GU3->GU3_AUTON == "2" ,"2","1")

				If cRet <> "1"
					::oModelGU3F:LoadValue( "GFEA015_GU3", "GU3_SIT", cRet )
				EndIf
			EndIf
		EndIf

		If !::oModelGU3F:VldData()
			cMsg := STR0060+CRLF+CRLF+::oModelGU3F:GetErrorMessage()[6]//"Inconsistência com o Frete Embarcador (SIGAGFE): "##
			lRet := .F.
		EndIf
	EndIf

	If !lRet
		Help( ,, STR0011,,cMsg, 1, 0 ) //Atenção
	EndIf

Return lRet

/*/{Protheus.doc} VldGU3
Verifica valores dos campos SA4 e retorna valor correspondente

@type metodo

@author Felipe Machado de Oliveira
@since 18/04/2013
@version P12.1.17

/*/
METHOD RegraIdSA2(nOperation,lRet,cMsg) CLASS MATA020EVGFE
Local cRet := ""

If nOperation == MODEL_OPERATION_INSERT
	If M->A2_TIPO == "X"
		cRet := AllTrim(M->A2_COD) + AllTrim(M->A2_LOJA)
	Else
		If Empty(M->A2_CGC)
			cMsg := STR0054 //"Informe o campo CNPJ/CPF (A2_CGC)."
			lRet := .F.
		Else
			cRet := M->A2_CGC
		EndIf
	EndIf
ElseIf nOperation == MODEL_OPERATION_UPDATE
	If SA2->A2_TIPO == "X"
		If SA2->A2_TIPO <> M->A2_TIPO
			cMsg := STR0055 //"Não é possivel alterar o Tipo para diferente de 'X=Outros'."
			lRet := .F.
		Else
			cRet := AllTrim(SA2->A2_COD)+AllTrim(SA2->A2_LOJA)
		EndIf
	Else
		If M->A2_TIPO == "X"
			cMsg := STR0056 //"Não é possivel alterar o Tipo para 'X=Outros'."
			lRet := .F.
		Else
			If !Empty(SA2->A2_CGC)
				If SA2->A2_CGC <> M->A2_CGC
					cMsg := STR0057 //"CNPJ/CPF não pode ser alterado por servir como chave de identificação no SIGAGFE"
					lRet := .F.
				Else
					cRet := SA2->A2_CGC
				Endif
			Else
				If Empty(M->A2_CGC)
					cMsg := STR0054 //"Informe o campo CNPJ/CPF (A2_CGC)."
					lRet := .F.
				Else
					cRet := SA2->A2_CGC
				EndIf
			EndIf
		EndIf
	EndIf
ElseIf nOperation == MODEL_OPERATION_DELETE
	If SA2->A2_TIPO == "X"
		cRet := AllTrim(SA2->A2_COD) + AllTrim(SA2->A2_LOJA)
	Else
		cRet := SA2->A2_CGC
	EndIf
EndIf

Return cRet

/*/{Protheus.doc} Destroy
Quando o modelo do fornecedor é destruido, destroi também o modelo do GFE.
Tratamento realizado para não deixar lixo na memória.

@type metodo

@author Juliane Venteu
@since 02/02/2017
@version P12.1.17

/*/
METHOD Destroy() CLASS MATA020EVGFE
	If ::oModelGU3F <> NIL
		::oModelGU3F:DeActivate()
		::oModelGU3F:Destroy()
	EndIf
Return
