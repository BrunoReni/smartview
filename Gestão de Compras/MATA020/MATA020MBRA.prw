#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
#include 'MATA020.ch'

#DEFINE SOURCEFATHER "MATA020"

/*/{Protheus.doc} MATA020BRA
Cadastro de fornecedor localizado para BRASIL.

O fonte contém browse, menu, model e view propria, todos herdados do MATA020. 
Qualquer regra que se aplique somente para a BRASIL deve ser definida aqui.

As validações e integrações realizadas após/durante a gravação estão definidas nos eventos do modelo, 
na classe MATA020EVBRA.

@type function
 
@author Juliane Venteu
@since 02/02/2017
@version P12.1.17
/*/
Function MATA020MBRA()
Local oBrowse := BrowseDef()
	
	oBrowse:Activate()
	
	//Limpa a tecla de atalho do F12
	A020F12End()
	
Return

Static Function BrowseDef()
Local oBrowse := FwLoadBrw("MATA020")
Return oBrowse

Static Function ModelDef()

Local oModel := FWLoadModel("MATA020")
Local oEvent := MATA020EVBRA():New()
Local oFOK   := Nil

	oModel:InstallEvent("BRASIL",,oEvent)

	// Relacionamento Fornecedor X Tipos de Retencao (FOK)
	If (FindFunction("FTemMotor") .And. FTemMotor()) .And. FindFunction("FINA024FOR")
	
		oFOK := FWFormStruct( 1, "FOK", { |x| AllTrim(x) $ "FOK_FILIAL,FOK_FORNEC,FOK_LOJA,FOK_CODIGO,FOK_IDFKK" } )
	
		oModel:AddGrid( "FOKTIPRET", "SA2MASTER", oFOK )
		oFOK:AddField(	STR0079,;																// [01] Titulo do campo "Descrição"
						STR0080,;																// [02] ToolTip do campo 	//"Detalhamento do tipo de imposto"
						"FOK_DESCR",;															// [03] Id do Field
						"C"	,;																	// [04] Tipo do campo
						40,;																	// [05] Tamanho do campo
						0,;																		// [06] Decimal do campo
						{ || .T. }	,;															// [07] Code-block de validação do campo
						{ || .T. }	,;															// [08] Code-block de validação When do campo
						,;																		// [09] Lista de valores permitido do campo
						.F.	,;																	// [10]	Indica se o campo tem preenchimento obrigatório
						FWBuildFeature(STRUCT_FEATURE_INIPAD, "RetFDesc('FOK_DESCR', 2)") ,;	// [11] Inicializador Padrão do campo
						,; 																		// [12] 
						,; 																		// [13] 
						.T.	) 																	// [14] Virtual
	
		oFOK:AddTrigger("FOK_CODIGO", "FOK_DESCR", { || .T.}, { || RetFDesc("FOK_DESCR", 1) })
		oFOK:SetProperty( 'FOK_FORNEC', MODEL_FIELD_OBRIGAT, .F. )
		oFOK:SetProperty( 'FOK_LOJA', MODEL_FIELD_OBRIGAT, .F. )
	
		oModel:SetRelation('FOKTIPRET', {	{ 'FOK_FILIAL', 'xFilial("FOK")' },;
											{ 'FOK_FORNEC', 'A2_COD' },;
											{ 'FOK_LOJA', 'A2_LOJA' } }, FOK->(IndexKey(1)) )
	
		oModel:getModel('FOKTIPRET'):SetOptional(.T.)
		oModel:GetModel('FOKTIPRET'):SetUniqueLine( { 'FOK_CODIGO' } )
	
	EndIf

Return oModel

Static Function ViewDef() 
Local nOpcao := 2
Local oView	 := FWLoadView("MATA020")
Local oFOK   := Nil
	
	If TableInDic("FKJ")
			
		If IsInCallStack("A020Altera")
			nOpcao := 4
		Else
		 	If IsInCallStack("A020Inclui")
			  	nOpcao := 3
			Endif
		Endif	  	
		
		oView:addUserButton(STR0077, 'CONTAINER', {|| FINA993( nOpcao ) } ) //"CPFs IR Progr."
		
	EndIf
	// BUSCA SICAF NO INCLUIR FORNECEDOR
	If nModulo == 87
		oView:AddUserButton(OemToAnsi(STR0072),OemToAnsi(STR0003), {|| lSicaf := A020BSCSCF( M->A2_CGC )},/*cToolTip*/,/*nShortCut*/,{MODEL_OPERATION_INSERT} ) // "Integração SICAF"		
	EndIf

	// Botao para relacionamento Fornecedor X Tipos de Retencao
	If (FindFunction("FTemMotor") .And. FTemMotor()) .And. FindFunction("FINA024FOR")
		oFOK := FWFormStruct(2, 'FOK', { |x| AllTrim(x) $ 'FOK_CODIGO' } )
		oView:AddUserButton(STR0078,'FOKTIPRET',{|| A020FOKTRet(oView) }) // "Tipos de Retencoes"
	EndIf 

	// Botao para relacionamento Fornecedor X Perfis Tributarios
	If FwAliasInDic("F20") .And. FindFunction("FSA172VIEW")
		oView:AddUserButton(STR0087,'', {|| FSA172VIEW({STR0088, M->A2_COD, M->A2_LOJA})},,,{MODEL_OPERATION_VIEW,MODEL_OPERATION_UPDATE,MODEL_OPERATION_DELETE}) // Perfis Tributarios # FORNECEDOR
	EndIf

Return oView

Static Function MenuDef()
Local aRotina := FWLoadMenuDef("MATA020")
	
Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} A020BSCSCF()
Rotina que realiza consulta às habilitações do fornecedor no site do SICAF
@author Rogerio Melonio
@since 09/06/2015
@version 1.0
@return NIL
/*/
//-------------------------------------------------------------------
//RETIRAR STATIC
Static Function A020BSCSCF(cCGC)
Local cUrl1		:= "http://compras.dados.gov.br/fornecedores/v1/fornecedores.xml"
Local cUrl2		:= ""
Local cGetPar		:= ""
Local nTimeOut	:= 120 //Segundos
Local aHeaderStr	:= {}
Local cHeaderRet	:= ""
Local cResponse	:= ""
Local cAviso   	:= ""
Local cErro     	:= ""
Local lRet 		:= .T. 
Local lSicaf 		:= .F. 
Local lBasica    	:= .F.
Local lDetalhada 	:= .F.
Local cMun
Local nPos
Local nX
Local cCPFCNPJ	:= ""
Local cRazao 	 	:= ""
Local cNome 	 	:= ""
Local cFantasia  	:= ""
Local cLogradouro	:= ""
Local cBairro	 	:= ""
Local cMunicipio 	:= ""
Local cUF  		:= ""
Local cCep       	:= ""

Local nTamA2Nome		:= TamSX3("A2_NOME")[1]
Local nTamA2Reduz		:= TamSX3("A2_NREDUZ")[1]
Local nTamA2Ender		:= TamSX3("A2_END")[1]
Local nTamA2Bairro	:= TamSX3("A2_BAIRRO")[1]
Local nTamA2Mun		:= TamSX3("A2_MUN")[1]

Default cCGC := &(ReadVar())
cCPFCNPJ := AllTrim(cCGC)

If Len(cCPFCNPJ) = 14
	cGetPar	:= "cnpj=" + cCPFCNPJ
	cUrl2 	:= "http://compras.dados.gov.br/fornecedores/doc/fornecedor_pj/" + cCPFCNPJ + ".xml"
Else
	Alert("Consulta disponível apenas para Pessoa Jurídica")
	lRet := .F. 
Endif           

If lRet
	aAdd(aHeaderStr,"Content-Type: application/x-www-form-urlencoded")

	//--> realiza consulta basica
	cResponse := HTTPGet( cUrl1, cGetPar, nTimeOut, aHeaderStr, @cHeaderRet )
	nErro1 := HTTPGetStatus(cErro)
	
	// se ocorreu erro no get do site do SICAF exibe erro
	If nErro1 <> 200
		cMsg := "Problemas consultando dados básicos do fornecedor" + CRLF + CRLF + cErro 
		Alert(cMsg)
	Else
		oResponse1 := XmlParser(cResponse,"_",@cAviso,@cErro)
		//--> oEmbedded existe somente para a URL http://compras.dados.gov.br/fornecedores/v1/fornecedores.xml 
		oEmbedded := XmlGetchild( oResponse1:_RESOURCE , XmlChildCount( oResponse1:_RESOURCE ))

		//--> se estrutura do oEmbedded está correta, extrai campos 
		If Valtype(oEmbedded) == "O"
			oResource :=  XmlChildEx ( oEmbedded, "_RESOURCE" )

			//--> se estrutura do oResource está correta, extrai campos 
			If Valtype(oResource) == "O"
				oNome := XmlChildEx ( oResource, "_NOME" )
				//Tipo=Object -> Tamanho=3
				cNome := Upper(oNome:TEXT)
		
				oAtivo := XmlChildEx ( oResource, "_ATIVO" )
				//Tipo=Object -> Tamanho=3
				cAtivo := Alltrim(Upper(oAtivo:TEXT)) // "true"
				lAtivo := cAtivo == "TRUE"
				
				oEstado := XmlChildEx ( oResource, "_UF" )
				//Tipo=Object -> Tamanho=3
				cUF := AllTrim(Upper(oEstado:TEXT)) // "SP"
		
				oRecadastro := XmlChildEx ( oResource, "_RECADASTRADO" ) 
				// Tipo=Object -> Tamanho=3
				cRecadastro := AllTrim(Upper(oRecadastro:TEXT)) // "false"
				lRecadastro := cRecadastro == "TRUE"
				
				M->A2_NOME 	:= Padr(cNome,nTamA2Nome)
				M->A2_NREDUZ	:= Padr(cNome,nTamA2Reduz)
				M->A2_EST		:= cUF
				M->A2_TIPO		:= Iif(Len(cCPFCNPJ)=11,"F",Iif(Len(cCPFCNPJ)=14,"J","X")) 

				lBasica := .T.
			Else
				Alert("Fornecedor não encontrado na consulta básica")
			Endif
		Endif 
	Endif

	//--> realiza consulta detalhada
	cErro     := ""
	cResponse := HTTPGet( cUrl2 , "" , nTimeOut, aHeaderStr, @cHeaderRet )
	nErro2 := HTTPGetStatus(cErro)

	If nErro2 <> 200
		cMsg := "Problemas consultando dados detalhados do fornecedor" + CRLF + CRLF + cErro 
		Alert(cMsg)
	Else
		oResponse2 := XmlParser(cResponse,"_",@cAviso,@cErro)
	
		If Valtype(oResponse2) == "O"
			oResource :=  XmlChildEx ( oResponse2, "_RESOURCE" ) 
			//Tipo=Object -> Tamanho=15
	
			oRazao := XmlChildEx ( oResource, "_RAZAO_SOCIAL" )
			If ValType(oRazao) == "O"
				cRazao := AllTrim(Upper(oRazao:TEXT)) 
			Endif

			oNome := XmlChildEx ( oResource, "_NOME" )
			If ValType(oNome) == "O" 
				cNome := AllTrim(Upper(oNome:TEXT)) 
			Endif
		
			oFantasia := XmlChildEx ( oResource, "_NOME_FANTASIA" )
			If ValType(oFantasia) == "O"
				cFantasia := Upper(oFantasia:TEXT)
			Endif
			
			oLogradouro := XmlChildEx ( oResource, "_LOGRADOURO" )
			If ValType(oLogradouro) == "O"
				cLogradouro := Upper(oLogradouro:TEXT)
			Endif
		
			oBairro := XmlChildEx ( oResource, "_BAIRRO" )
			If ValType(oBairro) == "O"
				cBairro := Upper(oBairro:TEXT)
			Endif
		
			oCEP := XmlChildEx ( oResource, "_CEP" )
			If ValType(oCEP) == "O"
				cCEP := StrTran(oCEP:TEXT,"-","")
			Endif
			
			oAtivo := XmlChildEx ( oResource, "_ATIVO" )
			cAtivo := Alltrim(Upper(oAtivo:TEXT)) // "true"
			lAtivo := cAtivo == "TRUE"
					
			oRecadastro := XmlChildEx ( oResource, "_RECADASTRADO" ) 
			cRecadastro := AllTrim(Upper(oRecadastro:TEXT)) // "false"
			lRecadastro := cRecadastro == "TRUE" 
									
			If Empty(cMunicipio)
				oLinks :=  XmlChildEx ( oResource, "__LINKS" )
				oLink := XmlGetChild( oLinks , XmlChildCount( oLinks ) )
				
				If ValType(oLink) ==  "A"
					For nX := 1 To Len(oLink)
						If "MUNICIPIO" $ Upper(oLink[nX]:_TITLE:TEXT)
							cMun := Upper(oLink[nX]:_TITLE:TEXT)
							nPos := At( ":" , cMun )
							cMunicipio := AllTrim(Substr(cMun,nPos+1))
							cMunicipio := Padr(cMunicipio,nTamA2Mun)
							Exit
						Endif
					Next
				Endif
			Endif 
			
					
			// Quando é pessoa fisica, é retornado o nome e não a razão social
			cRazao := Iif(Empty(cNome),cRazao, cNome )
		
			// caso o nome fantasia venha vazio, assume a razao social
			cFantasia := Iif( Empty(cFantasia), Left(cRazao,nTamA2Reduz), cFantasia )
			
			//cUF := Iif( Empty(cUF), aCNPJs[nW][03], cUF )
		
			M->A2_NOME 		:= Padr(cRazao		,nTamA2Nome	)
			M->A2_NREDUZ		:= Padr(cFantasia		,nTamA2Reduz	)
			M->A2_END			:= Padr(cLogradouro	,nTamA2Ender	)
			M->A2_BAIRRO		:= Padr(cBairro		,nTamA2Bairro	)
			M->A2_CEP			:= cCep
			M->A2_MUN			:= cMunicipio
			M->A2_TIPO			:= Iif(Len(cCPFCNPJ)=11,"F",Iif(Len(cCPFCNPJ)=14,"J","X")) 
	
			lDetalhada := .T.
		Else
			Alert("Fornecedor não encontrado na consulta detalhada")
		Endif
	Endif
Endif 

lSicaf := ( lBasica .Or. lDetalhada ) 

Return lSicaf

/*/{Protheus.doc} A020FOKTRet()
Funcao para montagem da view da amarração com tipo de retenção.

@param cField - Campo a ser preenchido do campo FOI_CODIGO
@param nProperty - 2 = Gatilho / 1 = Inicializador padrao

@author Totvs Sa
@since	14/09/2017
@version 12
/*/
Function A020FOKTRet(oView)

Local oModel := oView:GetModel()
Local oExecView
Local oStr
Local cFieldsBanco :=  "FOK_CODIGO"

	oStr:= FWFormStruct(2, 'FOK', {|cField| AllTrim(Upper(cField)) $ AllTrim(Upper(cFieldsBanco)) })

	oStr:AddField(	"FOK_DESCR", "05", STR0079, STR0080, {}, "C", "@!", ; //"Descrição" "Detalhamento do tipo de imposto"
							/*bPictVar*/, /*cLookUp*/, .F./*lCanChange*/,/*cFolder*/, ;
							/*cGroup*/, /*aComboValues*/, /*nMaxLenCombo*/,/*cIniBrow*/,;
							.T., /*cPictVar*/, /*lInsertLine*/ )

	oStr:SetProperty('FOK_CODIGO', MVC_VIEW_LOOKUP, { || FN024FF3("FOK_CODIGO") } )

	//--------------------------------------------------------------------------------
	//	Monta a view para exibir o grid
	// oView é passado por parametro para indicar que oViewBancos é filho do oView
	//--------------------------------------------------------------------------------
	oViewTpRet := FWFormView():New(oView) 	
	oViewTpRet:SetModel(oModel)
	oViewTpRet:AddGrid('FORMFOKTIPRET' , oStr,'FOKTIPRET' )	
	oViewTpRet:CreateHorizontalBox( 'BOXFOKTIPRET', 100)
	oViewTpRet:SetOwnerView('FORMFOKTIPRET','BOXFOKTIPRET')
	oViewTpRet:SetCloseOnOk({|| .T.})

	//--------------------------------------------------------------------------------
	// Monta a janela para exibir o view. Não é usado o FWExecView porque o FWExecView
	// obriga a passar o fonte para carregar a View e aqui já temos a view pronta
	//--------------------------------------------------------------------------------
	oExecView := FWViewExec():New()
	oExecView:SetView(oViewTpRet)
	oExecView:setTitle(STR0078)//"Tipos de Retenções"
	oExecView:SetModel(oModel)
	oExecView:setModal(.F.)					
	oExecView:setOperation(oModel:GetOperation())
	oExecView:openView(.F.)	

Return

/*/{Protheus.doc} FGetTpRet()
Funcao para preenchimento dos campos virtuais do tipo retenção

@param cField - Campo a ser preenchido do campo FOI_CODIGO
@param nProperty - 2 = Gatilho / 1 = Inicializador padrao

@author Totvs Sa
@since	14/09/2017
@version 12
/*/
Function RetFDesc( cField, nProperty )

Local nOper		:= 0

Local cCodigo	:= ""
Local cRet		:= ""

Local oModel	:= NIL

DEFAULT cField	:= " "
DEFAULT nProperty	:= 1

oModel	:= FWModelActive()
nOper	:= oModel:GetOperation()
cRet	:= If(nProperty == 1 .And. !Empty(cField), oModel:GetValue("FOKTIPRET", cField), " " )

If nProperty == 2
	If nOper == MODEL_OPERATION_INSERT
		cRet := ""
	ElseIf nOper == MODEL_OPERATION_UPDATE
		
		If !(FWIsInCallStack("ADDLINE"))
			If FOK->FOK_FORNEC <> SA2->A2_COD
				cRet := ""
			Else
				cRet := Posicione( "FKK", 1, xFilial("FKK") + FOK->FOK_IDFKK, "FKK_DESCR" )//
			EndIf
		ElseIf FWIsInCallStack("ADDLINE")
			cRet := ""
		EndIf
	Else
		cRet := Posicione( "FKK", 1, xFilial("FKK") + FOK->FOK_IDFKK, "FKK_DESCR" )//
	EndIf
ElseIf (nProperty == 1 .Or. nOper != MODEL_OPERATION_INSERT)
	cCodigo := oModel:GetValue("FOKTIPRET", "FOK_CODIGO")	
	
	If !Empty(cCodigo)
		cRet := Posicione("FKK", 3, xFilial("FKK") + "1" + cCodigo, "FKK_DESCR")
	EndIf
EndIf

Return cRet
