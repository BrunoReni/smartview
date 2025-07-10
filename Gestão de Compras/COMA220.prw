#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
#Include 'COMA220.ch'
 
Static aFIL := {}
Static aFCC := {}
Static aATU := {}
Static aCON := {}
//------------------------------------------------------------------
/*/{Protheus.doc} COMA220() 
Substituição de Aprovadores
@author guilherme.pimentel
@since 15/10/2015
@version 1.0
@return NIL
/*/
//-------------------------------------------------------------------
Function COMA220()

Local oBrowse := nil

oBrowse := FWMBrowse():New()
oBrowse:setAlias("SAL")
oBrowse:SetDescription(STR0001) // "Aprovação: Situação de Contrato"                                                                                                                                                                                                                                                                                                                                                                                                                                                                                
oBrowse:Activate()

Return NIL

//------------------------------------------------------------------
/*/{Protheus.doc} MenuDef()
Menu de opções do Browse

@author guilherme.pimentel

@since 15/10/2015
@version 1.0
@return aRotina
/*/
//-------------------------------------------------------------------

STATIC Function MenuDef()

Local aRotina	:= {}

ADD OPTION aRotina TITLE 'Visualizar'	ACTION 'VIEWDEF.COMA220' OPERATION 2 ACCESS 0 // 'Visualizar'
ADD OPTION aRotina TITLE 'Incluir'		ACTION 'VIEWDEF.COMA220' OPERATION 3 ACCESS 0 // 'Incluir'
ADD OPTION aRotina TITLE 'Alterar'		ACTION 'VIEWDEF.COMA220' OPERATION 4 ACCESS 0 // 'Alterar'
ADD OPTION aRotina TITLE 'Excluir'		ACTION 'VIEWDEF.COMA220' OPERATION 5 ACCESS 0 // 'Excluir'
						
Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Definição do modelo de Dados

@author guilherme.pimentel

@since 15/10/2015
@version 1.0
/*/
//-------------------------------------------------------------------

Static Function ModelDef()

Local oModel 	:= Nil

Local oStru1 	:= FWFormModelStruct():New()
Local oStru2 	:= FWFormModelStruct():New()
Local oStru3 	:= FWFormModelStruct():New()
Local oStru4 	:= FWFormModelStruct():New()

Local bWFalse	:= {||.F.}
Local aGatilho:= NIl

oStru1:AddTable("   ",{" "}," ")
oStru2:AddTable("   ",{" "}," ")
oStru3:AddTable("   ",{" "}," ")
oStru4:AddTable("   ",{" "}," ")

// -----------------------------------------------------------------------
// ESTRUTURA DO ARRAY
// --> [01] - campo, [02] - tipo, [03] - tamanho, [04] mascara, [05] - descrição, [06] - titulo, [07] - combo, [08] - consulta padrão, [09] - bWhen, [10] - bValid, [11] bInit, [12] - Visual
// -----------------------------------------------------------------------

// -----------------------------------------------------------------------
// GERAÇÃO DA PRIMEIRA ESTRUTURA
// -----------------------------------------------------------------------
If empty(aFIL)
	aAdd( aFIL,{'FIL_PERFIL'	,'C' , TAMSX3("DHL_COD")[1]		, '@!'	,'Perfil'		,'Perfil'		,NIL	,'DHL'	, NIL		, {|a,b,c,d| A220VldPad('perfil'	,a,b,c,d) }, Nil, .T.  } )
	aAdd( aFIL,{'FIL_DESPER'	,'C' , TAMSX3("DHL_DESCRI")[1] 	, '@!'	,'Desc.Perfil'	,'Desc.Perfil'	,NIL	, NIL	, Nil		, Nil, Nil, .F.  } )
	aAdd( aFIL,{'FIL_LOGIN'		,'C' , TAMSX3("AK_LOGIN")[1] 	, '@!'	,'Login'		,'Login'		,NIL	, NIL	, Nil		, {|a,b,c,d| A220VldPad('login'		,a,b,c,d) }, Nil, .T.  } )
	aAdd( aFIL,{'FIL_USU'		,'C' , TAMSX3("AK_USER")[1]		, '@!'	,'Usuário'		,'Usuário'		,NIL	,'USR'	, Nil		, {|a,b,c,d| A220VldPad('usuario'	,a,b,c,d) }, Nil, .T.  } )
	aAdd( aFIL,{'FIL_APROV'		,'C' , TAMSX3("AK_COD")[1]		, '@!'	,'Aprovador'	,'Aprovador'	,NIL	,'SAK'	, Nil		, {|a,b,c,d| A220VldPad('aprovador'	,a,b,c,d) }, Nil, .T.  } )
	aAdd( aFIL,{'FIL_NOMAPR'	,'C' , TAMSX3("AK_NOME")[1]		, '@!'	,'Nome Aprov.'	,'Nome Aprov.'	,NIL	, NIL	, Nil		, Nil, Nil, .F.  } )
	aAdd( aFIL,{'FIL_SUPERI'	,'C' , TAMSX3("AK_APROSUP")[1]	, '@!'	,'Superior'		,'Superior'		,NIL	,'SAK'	, Nil		, {|a,b,c,d| A220VldPad('superior'	,a,b,c,d) }, Nil, .T.  } )
	aAdd( aFIL,{'FIL_NOMSUP'	,'C' , TAMSX3("AK_NOME")[1]	 	, '@!'	,'Nome Super.'	,'Nome Super.'	,NIL	, NIL	, Nil		, Nil, Nil, .F.  } )
EndIf

COM220Mod(aFIL,"STRU1_",oStru1)

// -----------------------------------------------------------------------
// GERAÇÃO DA SEGUNDA ESTRUTURA
// -----------------------------------------------------------------------
If empty(aFCC)
	aAdd( aFCC,{'FCC_CC'		,'C' , TAMSX3("DBL_CC")[1] 		, '@!'	,'Centro Custo'	,'Centro Custo'	,NIL	, 'CTT'	, NIL		, {||CTB105CC(FwFldGet('FCC_CC'))}		, Nil, .T.   } )
	aAdd( aFCC,{'FCC_CCTB'		,'C' , TAMSX3("DBL_CONTA")[1]	, '@!'	,'Conta Ctb.'	,'Conta Ctb.'	,NIL	, 'CT1'	, Nil		, {||Ctb105Cta(FwFldGet('FCC_CCTB'))}	, Nil, .T.   } )
	aAdd( aFCC,{'FCC_IC'		,'C' , TAMSX3("DBL_ITEMCT")[1]	, '@!'	,'Item Ctb.'	,'Item Ctb.'	,NIL	, 'CTD'	, Nil		, {||Ctb105Item(FwFldGet('FCC_IC'))}	, Nil, .T.   } )
	aAdd( aFCC,{'FCC_CV'		,'C' , TAMSX3("DBL_CLVL")[1] 	, '@!'	,'Classe Val.'	,'Classe Val.'	,NIL	, 'CTH'	, Nil		, {||Ctb105ClVl(FwFldGet('FCC_CV'))}	, Nil, .T.   } )
EndIf

COM220Mod(aFCC,"STRU2_",oStru2)

// -----------------------------------------------------------------------
// GERAÇÃO DA TERCEIRA ESTRUTURA
// -----------------------------------------------------------------------
If empty(aATU)
	aAdd( aATU,{'ATU_PERFIL'	,'C' , TAMSX3("DHL_COD")[1]		, '@!'	,'Perfil'		,'Perfil'		,NIL	,'DHL'	, NIL		, {|a,b,c,d| A220VldPad('perfil'	,a,b,c,d) }, Nil, .T.  } )
	aAdd( aATU,{'ATU_DESPER'	,'C' , TAMSX3("DHL_DESCRI")[1]	, '@!'	,'Desc.Perfil'	,'Desc.Perfil'	,NIL	, NIL	, Nil		, Nil, Nil, .F.  } )
	aAdd( aATU,{'ATU_LOGIN'		,'C' , TAMSX3("AK_LOGIN")[1] 	, '@!'	,'Login'		,'Login'		,NIL	, NIL	, Nil		, {|a,b,c,d| A220VldPad('login'		,a,b,c,d) }, Nil, .T.  } )
	aAdd( aATU,{'ATU_USU'		,'C' , TAMSX3("AK_USER")[1]		, '@!'	,'Usuário'		,'Usuário'		,NIL	,'USR'	, Nil		, {|a,b,c,d| A220VldPad('usuario'	,a,b,c,d) }, Nil, .T.  } )
	aAdd( aATU,{'ATU_APROV'		,'C' , TAMSX3("AK_COD")[1]		, '@!'	,'Aprovador'	,'Aprovador'	,NIL	,'SAK'	, Nil		, {|a,b,c,d| A220VldPad('aprovador',a,b,c,d) }, Nil, .T.  } )
	aAdd( aATU,{'ATU_NOMAPR'	,'C' , TAMSX3("AK_NOME")[1] 	, '@!'	,'Nome Aprov.'	,'Nome Aprov.'	,NIL	, NIL	, Nil		, Nil, Nil, .F.  } )
	aAdd( aATU,{'ATU_SUPERI'	,'C' , TAMSX3("AK_APROSUP")[1]	, '@!'	,'Superior'		,'Superior'		,NIL	,'SAK'	, Nil		, {|a,b,c,d| A220VldPad('superior'	,a,b,c,d) }, Nil, .T.  } )
	aAdd( aATU,{'ATU_NOMSUP'	,'C' , TAMSX3("AK_NOME")[1]	 	, '@!'	,'Nome Super.'	,'Nome Super.'	,NIL	, NIL	, Nil		, Nil, Nil, .F.  } )
EndIf

COM220Mod(aATU,"STRU3_",oStru3)

// -----------------------------------------------------------------------
// GERAÇÃO DA QUARTA ESTRUTURA
// -----------------------------------------------------------------------
If empty(aCON)
	aAdd( aCON,{'CON_OK'		,'L' , 1 						, '@!'	,' '			,' '				,NIL	, NIL	, NIL	, Nil, Nil, .T.   } )
	aAdd( aCON,{'CON_NOMAPR'	,'C' , TAMSX3("AL_NOME")[1] 	, '@!'	,'Nome Aprov.'	,'Nome Aprov.'		,NIL	, NIL	, NIL	, Nil, Nil, .F.   } )
	aAdd( aCON,{'CON_GRUPO'		,'C' , TAMSX3("AL_COD")[1]		, '@!'	,'Grupo'		,'Grupo'			,NIL	, NIl	, NIL	, Nil, Nil, .F.   } )
	aAdd( aCON,{'CON_APROV'		,'C' , TAMSX3("AK_COD")[1]		, '@!'	,'Aprovador'	,'Aprovador'		,NIL	,'SAK'	, NIL	, {|a,b,c,d| A220VldPad('aprovador',a,b,c,d) }, Nil, .F.   } )
	aAdd( aCON,{'CON_PERFIL'	,'C' , TAMSX3("DHL_COD")[1]		, '@!'	,'Perfil'		,'Perfil'			,NIL	,'DHL'	, NIL	, {|a,b,c,d| A220VldPad('perfil'	,a,b,c,d) }, Nil, .F.   } )
	aAdd( aCON,{'CON_SUPERI'	,'C' , TAMSX3("AK_APROSUP")[1]	, '@!'	,'Superior'		,'Superior'			,NIL	,'SAK'	, NIL	, {|a,b,c,d| A220VldPad('superior'	,a,b,c,d) }, Nil, .F.   } )
	      
	aAdd( aCON,{'CON_NAPROV'	,'C' , TAMSX3("AK_COD")[1]		, '@!'	,'Novo Aprov.'	,'Novo Aprovador'	,NIL	,'SAK'	, NIL	, {|a,b,c,d|A220VldPad('aprovador',a,b,c,d) .And. A220VldApr(a,b,c,d)}, Nil, .T.   } )
	aAdd( aCON,{'CON_NPERF'		,'C' , TAMSX3("DHL_COD")[1]		, '@!'	,'Novo Perfil'	,'Novo Perfil'		,NIL	,'DHL'	, NIL	, {|a,b,c,d| A220VldPad('perfil'	,a,b,c,d) }, Nil, .T.   } )
	aAdd( aCON,{'CON_NSUPER'	,'C' , TAMSX3("AK_APROSUP")[1]	, '@!'	,'Novo Super.'	,'Novo Superior'	,NIL	,'SAK'	, NIL	, {|a,b,c,d| A220VldPad('superior'	,a,b,c,d) }, Nil, .T.   } )
EndIf

COM220Mod(aCON,"STRU4_",oStru4)

// -----------------------------------------------------------------------
// Gatilhos
// -----------------------------------------------------------------------
aGatilho := FwStruTrigger ('FIL_USU' /*cDom*/, 'FIL_APROV' /*cCDom*/, "SAK->AK_COD" /*cRegra*/, .T. /*lSeek*/, "SAK" /*cAlias*/, 2 /*nOrdem*/,'xFilial("SAK")+FwFldGet("FIL_USU")'/*cChave*/, /*cCondic*/ )
oStru1:AddTrigger( aGatilho[1] /*cIdField*/, aGatilho[2] /*cTargetIdField*/, aGatilho[3] /*bPre*/, aGatilho[4] /*bSetValue*/ )

aGatilho := FwStruTrigger ( 'FIL_PERFIL' /*cDom*/, 'FIL_DESPER' /*cCDom*/, "A220Trigger('FIL_PERFIL')" /*cRegra*/, .F. /*lSeek*/, /*cAlias*/,  /*nOrdem*/, /*cChave*/, /*cCondic*/ )
oStru1:AddTrigger( aGatilho[1] /*cIdField*/, aGatilho[2] /*cTargetIdField*/, aGatilho[3] /*bPre*/, aGatilho[4] /*bSetValue*/ )

aGatilho := FwStruTrigger ( 'FIL_APROV' /*cDom*/, 'FIL_NOMAPR' /*cCDom*/, "A220Trigger('FIL_APROV')" /*cRegra*/, .F. /*lSeek*/, /*cAlias*/,  /*nOrdem*/, /*cChave*/, /*cCondic*/ )
oStru1:AddTrigger( aGatilho[1] /*cIdField*/, aGatilho[2] /*cTargetIdField*/, aGatilho[3] /*bPre*/, aGatilho[4] /*bSetValue*/ )

aGatilho := FwStruTrigger ( 'FIL_SUPERI' /*cDom*/, 'FIL_NOMSUP' /*cCDom*/, "A220Trigger('FIL_SUPERI')" /*cRegra*/, .F. /*lSeek*/, /*cAlias*/,  /*nOrdem*/, /*cChave*/, /*cCondic*/ )
oStru1:AddTrigger( aGatilho[1] /*cIdField*/, aGatilho[2] /*cTargetIdField*/, aGatilho[3] /*bPre*/, aGatilho[4] /*bSetValue*/ )

aGatilho := FwStruTrigger ( 'ATU_PERFIL' /*cDom*/, 'ATU_DESPER' /*cCDom*/, "A220Trigger('ATU_PERFIL')" /*cRegra*/, .F. /*lSeek*/, /*cAlias*/,  /*nOrdem*/, /*cChave*/, /*cCondic*/ )
oStru3:AddTrigger( aGatilho[1] /*cIdField*/, aGatilho[2] /*cTargetIdField*/, aGatilho[3] /*bPre*/, aGatilho[4] /*bSetValue*/ )

aGatilho := FwStruTrigger ( 'ATU_APROV' /*cDom*/, 'ATU_NOMAPR' /*cCDom*/, "A220Trigger('ATU_APROV')" /*cRegra*/, .F. /*lSeek*/, /*cAlias*/,  /*nOrdem*/, /*cChave*/, /*cCondic*/ )
oStru3:AddTrigger( aGatilho[1] /*cIdField*/, aGatilho[2] /*cTargetIdField*/, aGatilho[3] /*bPre*/, aGatilho[4] /*bSetValue*/ )

aGatilho := FwStruTrigger ( 'ATU_SUPERI' /*cDom*/, 'ATU_NOMSUP' /*cCDom*/, "A220Trigger('ATU_SUPERI')" /*cRegra*/, .F. /*lSeek*/, /*cAlias*/,  /*nOrdem*/, /*cChave*/, /*cCondic*/ )
oStru3:AddTrigger( aGatilho[1] /*cIdField*/, aGatilho[2] /*cTargetIdField*/, aGatilho[3] /*bPre*/, aGatilho[4] /*bSetValue*/ )


// -----------------------------------------------------------------------
// Construção do modelo
// -----------------------------------------------------------------------
oModel := MPFormModel():New('COMA220', /*bPreValidacao*/, {|oModel|A220VldApGr(omodel)}/*bPosValidacao*/, {|oModel|A220Grv(omodel)}/*bCommit*/, /*bCancel*/ )

// -----------------------------------------------------------------------
// Adiciona ao modelo uma estrutura de formulário de edição por campo 
// -----------------------------------------------------------------------
oModel:AddFields(	'FILMASTER', 	/*Owner*/	, oStru1, /*bPreValidacao*/	, /*bPosValidacao*/	, /* bLoad*/)
oModel:AddGrid(		'FCCDETAIL', 	'FILMASTER'	, oStru2, /*bPreValidacao*/	, /*bPosValidacao*/	, /* bLoad*/)
oModel:AddFields(	'ATUDETAIL', 	'FCCDETAIL'	, oStru3, /* bLinePre*/ 	, /* bLinePost */	, /* bPre*/, /* bLinePost */, /* bLoad*/ )
oModel:AddGrid(		'CONDETAIL', 	'ATUDETAIL'	, oStru4, /* bLinePre*/ 	, /* bLinePost */	, /* bPre*/, /* bLinePost */, /* bLoad*/ )

// -----------------------------------------------------------------------
// Adiciona a descricao do Modelo de Dados
// -----------------------------------------------------------------------
oModel:SetDescription(STR0001)

// -----------------------------------------------------------------------
// Adiciona a descricao do Componente do Modelo de Dados
// -----------------------------------------------------------------------
oModel:GetModel( 'FILMASTER' ):SetDescription( 'Dados atuais / Filtro' )
oModel:GetModel( 'FCCDETAIL' ):SetDescription( 'Centro de Custo' )
oModel:GetModel( 'ATUDETAIL' ):SetDescription( 'Novos dados / Atualização' )
oModel:GetModel( 'CONDETAIL' ):SetDescription( 'Atualização de Aprovadores' )

// -----------------------------------------------------------------------
// Propriedades específicas do modelo
// -----------------------------------------------------------------------
oModel:GetModel( 'FCCDETAIL' ):SetNoInsertLine(.T.)

oModel:GetModel( 'CONDETAIL' ):SetNoInsertLine(.T.)
oModel:GetModel( 'CONDETAIL' ):SetNoDeleteLine(.T.)
oModel:GetModel( 'CONDETAIL' ):SetNoUpdateLine(.T.)

oModel:GetModel('FCCDETAIL'):SetOptional(.T.)

oModel:SetPrimaryKey( {} )
oModel:SetActivate({|oModel| A220Activ(oModel)})

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} A220Activate
Actvate do modelo

@param oModel Modelo de dados
@author Flavio Lopes Rasta
@since 28/01/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Function A220Activ(oModel)

Local oModelFIL := oModel:GetModel('FILMASTER')
Local cOldValue	:= oModelFIL:GetValue('FIL_PERFIL')

oModelFIL:LoadValue('FIL_PERFIL',cOldValue)

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} WF300Model
Função para adicionar dinamicamente os campos na estrutura

@param aCampos Estrutura dos campos que serão adicionados
@param cStru Descrição da estrutura onde os campos serão adicionados
@param oStru Objeto referente a estrutura

@author guilherme.pimentel

@since 15/10/2015
@version 1.0
/*/
//-------------------------------------------------------------------

Function COM220Mod(aCampos,cStru,oStru)

Local nCampo := 1

For nCampo := 1 To Len(aCampos)
	
	//-- Adiciona campos header do filtro de busca de fornecedor 
	oStru:AddField(aCampos[nCampo][05]		,;	// 	[01]  C   Titulo do campo
					aCampos[nCampo][06]		,;	// 	[02]  C   ToolTip do campo
				 	aCampos[nCampo][01]		,;	// 	[03]  C   Id do Field
				 	aCampos[nCampo][02]		,;	// 	[04]  C   Tipo do campo
				 	aCampos[nCampo][03]		,;	// 	[05]  N   Tamanho do campo
				 	0						,;	// 	[06]  N   Decimal do campo
				 	aCampos[nCampo][10]		,;	// 	[07]  B   Code-block de validação do campo
				 	aCampos[nCampo][09]		,;	// 	[08]  B   Code-block de validação When do campo
				 	aCampos[nCampo][07]		,;	//	[09]  A   Lista de valores permitido do campo
				 	.F.						,;	//	[10]  L   Indica se o campo tem preenchimento obrigatório
				 	aCampos[nCampo][11]		,;	//	[11]  B   Code-block de inicializacao do campo
				 	.F.						,;	//	[12]  L   Indica se trata-se de um campo chave
				 	.T.						,;	//	[13]  L   Indica se o campo pode receber valor em uma operação de update.
				 	.T.						)	// 	[14]  L   Indica se o campo é virtual
Next nCampo

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Definição do interface

@author guilherme.pimentel

@since 15/10/2015
@version 1.0
/*/
//-------------------------------------------------------------------

Static Function ViewDef()

Local oModel	:= ModelDef()
// Cria a estrutura a ser usada na View
Local oStru1	:= FWFormViewStruct():New()
Local oStru2	:= FWFormViewStruct():New()
Local oStru3	:= FWFormViewStruct():New()
Local oStru4	:= FWFormViewStruct():New()

COM220View(aFIL,'FIL_',oStru1)
COM220View(aFCC,'FCC_',oStru2)
COM220View(aATU,'ATU_',oStru3)
COM220View(aCON,'CON_',oStru4)

// -----------------------------------------------------------------------
// Monta o modelo da interface do formulario
// -----------------------------------------------------------------------
oView := FWFormView():New()

// -----------------------------------------------------------------------
// Define qual o Modelo de dados será utilizado
// -----------------------------------------------------------------------
oView:SetModel(oModel)

oView:AddField('VIEW_FIL', oStru1,'FILMASTER')
oView:AddGrid( 'VIEW_FCC', oStru2,'FCCDETAIL')
oView:AddField('VIEW_ATU', oStru3,'ATUDETAIL')
oView:AddGrid( 'VIEW_CON', oStru4,'CONDETAIL')

oView:CreateHorizontalBox( 'FIL' ,30 )
oView:CreateHorizontalBox( 'FCC' ,10 )
oView:CreateHorizontalBox( 'ATU' ,30 )
oView:CreateHorizontalBox( 'CON' ,30 )

oView:SetOwnerView('VIEW_FIL','FIL')
oView:SetOwnerView('VIEW_FCC','FCC')
oView:SetOwnerView('VIEW_ATU','ATU')
oView:SetOwnerView('VIEW_CON','CON')
// -----------------------------------------------------------------------
// Adiciona a descricao do Componente do Modelo de Dados
// -----------------------------------------------------------------------
oModel:GetModel( 'FILMASTER' ):SetDescription(STR0002)
oModel:GetModel( 'FCCDETAIL' ):SetDescription(STR0003)
oModel:GetModel( 'ATUDETAIL' ):SetDescription(STR0004)
oModel:GetModel( 'CONDETAIL' ):SetDescription(STR0005)

oView:EnableTitleView('VIEW_FIL' ,STR0002)
oView:EnableTitleView('VIEW_ATU' ,STR0006)
oView:EnableTitleView('VIEW_CON' ,STR0005)

aWF1 := {}
aWF2 := {}
aWF3 := {}
aWF4 := {}

oView:AddUserbutton(STR0007,STR0007,{|| Com220GetA() })
Return oView 

//-------------------------------------------------------------------
/*/{Protheus.doc} COM220View
Função para adicionar dinamicamente os campos na view

@param aCampos Estrutura dos campos que serão adicionados
@param cStru Descrição da estrutura onde os campos serão adicionados
@param oStru Objeto referente a estrutura

@author guilherme.pimentel

@since 15/10/2015
@version 1.0
/*/
//-------------------------------------------------------------------

Function COM220View(aCampos,cStru,oStru)

Local nCampo := 0

For nCampo := 1 To Len(aCampos)

	cOrdem := StrZero(nCampo,2)
	//-- Adiciona campos header do filtro de busca de fornecedor 
	oStru:AddField(aCampos[nCampo][01]			,;	// [01]  C   Nome do Campo
					cOrdem						,;	// [02]  C   Ordem
					aCampos[nCampo][05] 		,;	// [03]  C   Titulo do campo
					aCampos[nCampo][06] 		,;	// [04]  C   Descricao do campo
					{}							,;	// [05]  A   Array com Help
					aCampos[nCampo][02]			,;	// [06]  C   Tipo do campo
					aCampos[nCampo][04]			,;	// [07]  C   Picture
					NIL							,;	// [08]  B   Bloco de Picture Var
					aCampos[nCampo][08]			,;	// [09]  C   Consulta F3
					aCampos[nCampo][12]			,;	// [10]  L   Indica se o campo é alteravel
					NIL							,;	// [11]  C   Pasta do campo
					NIL							,;	// [12]  C   Agrupamento do campo
					aCampos[nCampo][07]			,;	// [13]  A   Lista de valores permitido do campo (Combo)
					NIL							,;	// [14]  N   Tamanho maximo da maior opção do combo
					NIL							,;	// [15]  C   Inicializador de Browse
					.T.							,;	// [16]  L   Indica se o campo é virtual
					NIL							,;	// [17]  C   Picture Variavel
					.F.							)	// [18]  L   Indica pulo de linha após o campo
Next nCampo

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} Com220GetA
Consulta dos aprovadores dentro dos critérios de filtro

@author guilherme.pimentel

@since 19/10/2015
@version 1.0
/*/
//-------------------------------------------------------------------

Function Com220GetA()

Local lRet	:= .T.
Local nX	:= 0
Local nLine	:= 0
Local nLineClean := 0

Local oModel	:= FWModelActive()
Local oModelFIL	:= oModel:GetModel('FILMASTER')
Local oModelFCC	:= oModel:GetModel('FCCDETAIL')
Local oModelCON	:= oModel:GetModel('CONDETAIL')
Local oModelATU	:= oModel:GetModel('ATUDETAIL')
Local cAliasSAL	:= GetNextAlias()
Local cQuery	:= ''
Local cValue	:= ''

// -----------------------------------------------------------------------
// Filtro dos aprovadores compatíveis
// -----------------------------------------------------------------------

cQuery :=	" SELECT DISTINCT SAK.AK_NOME, SAL.AL_COD, SAL.AL_APROV, SAL.AL_PERFIL, SAL.AL_APROSUP" 
cQuery +=	" FROM " + RetSQLName("SAL") + " SAL"
cQuery +=	" INNER JOIN " + RetSQLName("SAK") + " SAK"
cQuery +=	"				ON SAL.AL_FILIAL = '" + xFilial("SAL") + "'"
cQuery +=	"				AND SAK.AK_FILIAL = '" + xFilial("SAK") + "'"
cQuery +=	"		    	AND SAL.AL_USER  = SAK.AK_USER"
 	
cQuery +=	" LEFT JOIN " + RetSQLName("DBL") + " DBL" 
cQuery +=	"				ON DBL.DBL_FILIAL = '" + xFilial("DBL") + "'"
cQuery +=	"				AND SAL.AL_FILIAL = '" + xFilial("SAL") + "'"
cQuery +=	"		    	AND SAL.AL_COD  = DBL.DBL_GRUPO"

cQuery +=	"				AND DBL.D_E_L_E_T_  = '' "		
cQuery +=	" WHERE SAL.AL_FILIAL  = '" + xFilial('SAL') + "'"
cQuery +=	" AND SAL.D_E_L_E_T_  = '' "
cQuery +=	A220Query("		AND SAL.AL_PERFIL = "  , oModelFil:GetValue('FIL_PERFIL'))
cQuery +=	A220Query("		AND SAL.AL_APROV = "   , oModelFil:GetValue('FIL_APROV'))
cQuery +=	A220Query("		AND SAL.AL_APROSUP = " , oModelFil:GetValue('FIL_SUPERI'))

cQuery +=	A220Query("		AND DBL.DBL_CC = "     , oModelFCC:GetValue('FCC_CC'))
cQuery +=	A220Query("		AND DBL.DBL_CONTA = "  , oModelFCC:GetValue('FCC_CCTB'))
cQuery +=	A220Query("		AND DBL.DBL_ITEMCT = " , oModelFCC:GetValue('FCC_IC'))
cQuery +=	A220Query("		AND DBL.DBL_CLVL = "   , oModelFCC:GetValue('FCC_CV'))

cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSAL,.F.,.T.)
		

// -----------------------------------------------------------------------
// Limpeza dos registros caso seja feita nova consulta
// -----------------------------------------------------------------------
If !Empty(oModelCON:GetValue('CON_NOMAPR')) .Or. oModelCON:IsUpdated()   
	oModelCON:SetNoInsertLine(.F.)
	oModelCON:SetNoUpdateLine(.F.)
	nLineClean := oModelCON:AddLine()
	oModelCON:LineShift(1,nLineClean)
	For nX := oModelCON:Length() To 1 STEP -1
		oModelCON:GoLine(nX)
		oModelCON:DeleteLine(.T.,.T.)
	Next nX
	oModelCON:UndeleteLine()
EndIf

// -----------------------------------------------------------------------
// Inserção dos registros para atualização
// -----------------------------------------------------------------------
If (cAliasSAL)->(Eof())
	Help(" ",1,"Com220GetA",,STR0008,1,4)	
Else
	oModelCON:SetNoInsertLine(.F.)
	oModelCON:SetNoUpdateLine(.F.)
	
	While (cAliasSAL)->(!Eof())
		If oModelCON:GetLine() == nLine .And. !Empty(oModelCON:GetValue('CON_NOMAPR'))
			nLine := oModelCON:AddLine()
		Else
			nline := oModelCON:GetLine()
		EndIf
		oModelCON:GoLine(nLine)
		oModelCON:LoadValue('CON_NOMAPR'	,(cAliasSAL)->AK_NOME)
		oModelCON:LoadValue('CON_GRUPO'		,(cAliasSAL)->AL_COD)
		oModelCON:LoadValue('CON_APROV'		,(cAliasSAL)->AL_APROV)
		oModelCON:LoadValue('CON_PERFIL'	,(cAliasSAL)->AL_PERFIL)
		oModelCON:LoadValue('CON_SUPERI'	,(cAliasSAL)->AL_APROSUP)
		                    
		// -----------------------------------------------------------------------
		// Adicionado para validar presença de mesmo aprovador no grupo casa haja
		// a substituição automática de aprovador configurada
		// -----------------------------------------------------------------------
		If !Empty(oModelATU:GetValue('ATU_APROV'))
			cValue := oModelATU:GetValue('ATU_APROV')
		Else
			cValue := (cAliasSAL)->AL_APROV
		EndIf	
		oModelCON:LoadValue('CON_NAPROV',cValue)
		
		cValue := If(Empty(oModelATU:GetValue('ATU_PERFIL')),(cAliasSAL)->AL_PERFIL,oModelATU:GetValue('ATU_PERFIL') )
		oModelCON:LoadValue('CON_NPERF'	,cValue)
		
		cValue := If(Empty(oModelATU:GetValue('ATU_SUPERI')),(cAliasSAL)->AL_APROSUP,oModelATU:GetValue('ATU_SUPERI') )
		oModelCON:LoadValue('CON_NSUPER',cValue)
		
		(cAliasSAL)->(DbSkip())
	End
EndIf

oModelCON:SetNoInsertLine(.T.)

oModelCON:GoLine(1)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} A220Query
Adiciona expressões a query somente se o valor não estiver vazio

@author guilherme.pimentel

@since 20/10/2015
@version 1.0
/*/
//-------------------------------------------------------------------

Function A220Query(cExp,cValue)

Local cRet := ''

If !Empty(cValue)
	cRet := cExp+ "'" + cValue + "'"
EndIf

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} A220Grv
Commit do modelo onde haverá a substituição dos aprovadores

@author guilherme.pimentel

@since 20/10/2015
@version 1.0
/*/
//-------------------------------------------------------------------

Function A220Grv(oModel)

Local lRet 		:= .T.
Local oModelCON := oModel:GetModel('CONDETAIL')
Local nX 		:= 1
Local aAreaSAK	:= SAK->(GetArea()) 
Local aAreaSAL	:= SAL->(GetArea())

SAL->(DbSetOrder(3))

// -----------------------------------------------------------------------
// Efetiva informações
// -----------------------------------------------------------------------
If lRet
	For nX := 1 To oModelCON:Length()  
		oModelCON:GoLine(nX)
		
		If oModelCON:GetValue('CON_OK')
			If SAL->(DbSeek(xFilial("SAL") + oModelCON:GetValue('CON_GRUPO') + oModelCON:GetValue('CON_APROV') ))
				RecLock("SAL",.F.)
				SAL->AL_APROV 	:= oModelCON:GetValue('CON_NAPROV')
				SAL->AL_PERFIL 	:= oModelCON:GetValue('CON_NPERF')	 
				SAL->AL_APROSUP := oModelCON:GetValue('CON_NSUPER')
				SAL->AL_USER	:= Posicione("SAK",1,xFilial("SAK") + oModelCON:GetValue('CON_NAPROV'),"AK_USER")  
				MsUnlock()					
			EndIf  
		EndIf
	
	Next nX
EndIf

lRet := FWFormCommit(oModel)

RestArea(aAreaSAK)
RestArea(aAreaSAL)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} A220VldApr
Validação do novo aprovador

@author guilherme.pimentel

@since 20/10/2015
@version 1.0
/*/
//-------------------------------------------------------------------

Function A220VldApr(oModel,cField,cValue,cOldValue)

Local lRet := .T.
Local aAreaSAL	:= SAL->(GetArea())

SAL->(DbSetOrder(3))
If SAL->(DbSeek(xFilial("SAL") + oModel:GetValue('CON_GRUPO') + cValue ))
	lRet := .F.
	If !IsInCallStack('Com220GetA')
		Help(" ",1,"A220VldApr",,STR0009+ Chr(13) + Chr(10) +STR0010+ cValToChar(cValue) +STR0011+ Chr(13) + Chr(10) + Chr(13) + Chr(10) +STR0012+ cValToChar(oModel:GetValue('CON_GRUPO')) + Chr(13) + Chr(10) +STR0013+SAL->AL_NIVEL+'.' + Chr(13) + Chr(10) + Chr(13) + Chr(10)  +STR0014+ Chr(13) + Chr(10) +STR0015,1,4)
	EndIf
EndIf

RestArea(aAreaSAL)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} A220VldApGr
Validação do novo aprovador atualização em Lote

@author Willian.Alves	

@since 24/01/2019
@version 1.0
/*/
//-------------------------------------------------------------------

Function A220VldApGr(oModel)

Local lRet 		:= .T.
Local lVazio	:= .T.
Local lHelp		:= .F.
Local oModelCON := oModel:GetModel('CONDETAIL')
Local oModelATU := oModel:GetModel('ATUDETAIL')
Local nX 		:= 1
Local aAreaSAK	:= SAK->(GetArea()) 
Local aAreaSAL	:= SAL->(GetArea())
Local aGroup	:= ""

SAL->(DbSetOrder(3))

// -----------------------------------------------------------------------
// Efetiva informações
// -----------------------------------------------------------------------

For nX := 1 To oModelCON:Length()  
	oModelCON:GoLine(nX)
	
	If oModelCON:GetValue('CON_OK')
		If SAL->(DbSeek(xFilial("SAL") + oModelCON:GetValue('CON_GRUPO') + oModelATU:GetValue('ATU_APROV') ))
			lRet 	:=.F.
			lHelp	:=.T.	
			aGroup 	:= aGroup + '- ' + cValToChar(oModelCON:GetValue('CON_GRUPO')) + Chr(13) + Chr(10)
		EndIf
		lVazio :=.F.
	Endif

Next nX

If	lVazio
	lRet :=.F.
Endif

If !lRet
	If lVazio
		Help(" ",1,"A220VldApGr",,STR0016,1,4, NIL, NIL, NIL, NIL, NIL, {STR0017})
	Else
		Help(" ",1,"A220VldApGr",,STR0018+ Chr(13) + Chr(10) + Chr(13) + Chr(10) +STR0010+ cValToChar(oModelATU:GetValue('ATU_APROV')) +STR0019+  Chr(13) + Chr(10) + Chr(13) + Chr(10) + aGroup + Chr(13) + Chr(10) +STR0020+ Chr(13) + Chr(10),1,4, NIL, NIL, NIL, NIL, NIL, {STR0021})
	Endif
Endif

RestArea(aAreaSAK)
RestArea(aAreaSAL)

Return lRet




//-------------------------------------------------------------------
/*/{Protheus.doc} A220VldPad
Validação padrão dos campos

@author guilherme.pimentel

@since 20/10/2015
@version 1.0
/*/
//-------------------------------------------------------------------

Function A220VldPad(cValid,oModel,cField,cValue,cOldValue)

Local lRet := .T.

If upper(cValid) ==  'PERFIL'
	lRet := Empty(cValue) .Or. ExistCpo("DHL",cValue)
elseif upper(cValid) == 'LOGIN'
	PSWORDER(2)
	If lRet := Empty(cValue) .Or. PSWSEEK(cValue)
		A220SetSAK(cField,oModel,cValue,!IsInCallStack('A220SetSAK'))
	EndIf
	
elseif upper(cValid) == 'USUARIO'
	If lRet := Empty(cValue) .Or. UsrExist(cValue)
		A220SetSAK(cField,oModel,cValue,!IsInCallStack('A220SetSAK'))
	EndIf
	
elseif upper(cValid) == 'APROVADOR'
	If lRet := Empty(cValue) .Or. ExistCpo("SAK",cValue,1)
		A220SetSAK(cField,oModel,cValue,!IsInCallStack('A220SetSAK'))
	EndIf
	
elseif upper(cValid) == 'SUPERIOR'
	lRet := Empty(cValue) .Or. ExistCpo('SAK',cValue,3)
	
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} A220SetSAK
Consulta na SAK para preenchimento automático dos campos

@param cField campo onde alterado
@param oModel parde do modelo de dados referente ao campo
@param cValue valor que esta sendo colocado
@param lExecute validaçao se executa o tratamentos

@Obs o parametr lExecute foi adicionado para que nao acha loop
na chamada da função, uma vez que está com SetValue

@author guilherme.pimentel

@since 20/10/2015
@version 1.0
/*/
//-------------------------------------------------------------------

Function A220SetSAK(cField,oModel,cValue,lExecute)

Local cPrefixo := Substr(cField,1,At('_',cField))
Local aAreaSAK	:= SAK->(GetArea())

If lExecute .And. !Empty(cValue) .And. cPrefixo <> 'CON_'
	If 'APROV' $ cField 
		SAK->(DbSetOrder(1))
		If SAK->(DbSeek(xFilial("SAK")+cValue))
			oModel:SetValue( cPrefixo+'LOGIN'	, SAK->AK_LOGIN )
			oModel:SetValue( cPrefixo+'USU'		, SAK->AK_USER )
			oModel:SetValue( cPrefixo+'SUPERI'	, SAK->AK_APROSUP )
		EndIf
	
	ElseIf 'LOGIN' $ cField 
		SAK->(DbSetOrder(4))
		If SAK->(DbSeek(xFilial("SAK")+cValue))
			oModel:SetValue( cPrefixo+'APROV'	, SAK->AK_COD )
			oModel:SetValue( cPrefixo+'USU'		, SAK->AK_USER )
			oModel:SetValue( cPrefixo+'SUPERI'	, SAK->AK_APROSUP )
		EndIf
		
	ElseIf 'USU' $ cField 
		SAK->(DbSetOrder(2))
		If SAK->(DbSeek(xFilial("SAK")+cValue))
			oModel:SetValue( cPrefixo+'LOGIN'	, SAK->AK_LOGIN	)
			oModel:SetValue( cPrefixo+'APROV'	, SAK->AK_COD		)
			oModel:SetValue( cPrefixo+'SUPERI' , SAK->AK_APROSUP	)
		EndIf
	EndIf
EndIf

RestArea(aAreaSAK)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} A220Trigger
Gatilho dos campos

@author guilherme.pimentel

@since 20/10/2015
@version 1.0
/*/
//-------------------------------------------------------------------

Function A220Trigger(cCampo)

Local aAreaSAK	:= SAK->(GetArea())
Local aAreaDHL	:= DHL->(GetArea())
Local cRet		:= ""

If ('APROV' $ Upper(cCampo)) .Or. ('SUPERI' $ Upper(cCampo))
	cRet := Posicione("SAK",1,xFilial("DHL")+FwFldGet(cCampo),"AK_NOME")
ElseIf ('USU' $ Upper(cCampo))
	cRet := Posicione("SAK",2,xFilial("DHL")+FwFldGet(cCampo),"AK_NOME")
ElseIf 'PERFIL' $ Upper(cCampo)
	cRet := Posicione("DHL",1,xFilial("DHL")+FwFldGet(cCampo),"DHL_DESCRI")
EndIf

RestArea(aAreaSAK)
RestArea(aAreaDHL)

Return AllTrim(cRet)

