#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "MATA183.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} MATA183()
Cadastro de Alteracao Massiva
@author Leonardo Quintania
@since 28/01/2013
@version 1.0
@return NIL
/*/
//-------------------------------------------------------------------
Function MATA183() 

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef()
Definicao do Modelo
@author Leonardo Quintania
@since 28/01/2013
@version 1.0
@return oModel
/*/
//-------------------------------------------------------------------
Static Function ModelDef()  
Local oStruCab 	:= FWFormModelStruct():New() //Estrutura Cabecalho 
Local oStruDB5 	:= FWFormStruct(1,"DB5",{|cCampo| AllTrim(cCampo) $ "DB5_FILABA|DB5_NFILAB|DB5_OK"})  //Estrutura Filiais abastecidas
Local oModel   	:= MPFormModel():New("MATA183",/*Pre-Validacao*/, /*Pos-Validacao*/,  { |oModel| A183Commit( oModel ) },/*Cancel*/)

//-- Campo Doc. de Compra
oStruCab:AddField(STR0001															,;	// 	[01]  C   Titulo do campo  - Doc. de Compra
				 STR0001															,;	// 	[02]  C   ToolTip do campo - Doc. de Compra
				 "DOCOMP"															,;	// 	[03]  C   Id do Field
				 "C"																,;	// 	[04]  C   Tipo do campo
				 1																	,;	// 	[05]  N   Tamanho do campo
				 0																	,;	// 	[06]  N   Decimal do campo
				 NIL																,;	// 	[07]  B   Code-block de validação do campo
				 NIL																,;	// 	[08]  B   Code-block de validação When do campo
				 {STR0002,STR0003}													,;	//	[09]  A   Lista de valores permitido do campo
				 .F.																,;	//	[10]  L   Indica se o campo tem preenchimento obrigatório
				 FwBuildFeature( STRUCT_FEATURE_INIPAD, "'1'" )						,;	//	[11]  B   Code-block de inicializacao do campo
				 NIL																,;	//	[12]  L   Indica se trata-se de um campo chave
				 NIL																,;	//	[13]  L   Indica se o campo pode receber valor em uma operação de update.
				 .F.																)	// 	[14]  L   Indica se o campo é virtual
				 
//-- Campo Comprar na
oStruCab:AddField(STR0004															,;	// 	[01]  C   Titulo do campo  - Comprar na
				 STR0004															,;	// 	[02]  C   ToolTip do campo - Comprar na //"Comprar na"
				 "COMPNA"															,;	// 	[03]  C   Id do Field
				 "C"																,;	// 	[04]  C   Tipo do campo
				 1																	,;	// 	[05]  N   Tamanho do campo
				 0																	,;	// 	[06]  N   Decimal do campo
				 NIL																,;	// 	[07]  B   Code-block de validação do campo
				 NIL																,;	// 	[08]  B   Code-block de validação When do campo
				 {STR0005,STR0006}													,;	//	[09]  A   Lista de valores permitido do campo  //"1=Distribuidora"##"2=Abastecida"
				 .F.																,;	//	[10]  L   Indica se o campo tem preenchimento obrigatório
				 FwBuildFeature( STRUCT_FEATURE_INIPAD, "'1'" )						,;	//	[11]  B   Code-block de inicializacao do campo
				 NIL																,;	//	[12]  L   Indica se trata-se de um campo chave
				 NIL																,;	//	[13]  L   Indica se o campo pode receber valor em uma operação de update.
				 .F.																)	// 	[14]  L   Indica se o campo é virtual

//-- Campo Entregar na
oStruCab:AddField(STR0007															,;	// 	[01]  C   Titulo do campo  - Entregar na  //"Entregar na"
				 STR0007															,;	// 	[02]  C   ToolTip do campo - Entregar na
				 "ENTRNA"															,;	// 	[03]  C   Id do Field
				 "C"																,;	// 	[04]  C   Tipo do campo
				 1																	,;	// 	[05]  N   Tamanho do campo
				 0																	,;	// 	[06]  N   Decimal do campo
				 NIL																,;	// 	[07]  B   Code-block de validação do campo
				 NIL																,;	// 	[08]  B   Code-block de validação When do campo
				 {STR0005,STR0006}													,;	//	[09]  A   Lista de valores permitido do campo  //"1=Distribuidora"##"2=Abastecida"
				 .F.																,;	//	[10]  L   Indica se o campo tem preenchimento obrigatório
				 FwBuildFeature( STRUCT_FEATURE_INIPAD, "'1'" )						,;	//	[11]  B   Code-block de inicializacao do campo
				 NIL																,;	//	[12]  L   Indica se trata-se de um campo chave
				 NIL																,;	//	[13]  L   Indica se o campo pode receber valor em uma operação de update.
				 .F.																)	// 	[14]  L   Indica se o campo é virtual
				 
//------------------------------------------------------
//		Cria a estrutura basica
//------------------------------------------------------
oModel:= MPFormModel():New("MATA183", /*Pre-Validacao*/,/*Pos-Validacao*/,/*bCommit*/,/*Cancel*/)
oModel:SetDescription(STR0008) //Obrigatorio ter alguma descricao //ALteracao Massiva

//------------------------------------------------------
//		Adiciona o componente de formulario no model 
//     Nao sera usado, mas eh obrigatorio ter
//------------------------------------------------------	
oModel:AddFields("DBIMASTER",/*cOwner*/ ,oStruCab) //Cabecalho
oModel:AddGrid("DB5DETAILS","DBIMASTER" ,oStruDB5) //Filiais DB5

//--------------------------------------
//		Configura o model
//--------------------------------------
oModel:SetPrimaryKey( {} ) //Obrigatorio setar a chave primaria (mesmo que vazia)
oModel:SetRelation("DB5DETAILS",{{"DBI_FILIAL",'xFilial("DBI")'}},DBI->(IndexKey(1)))	

oModel:GetModel("DBIMASTER" ):SetDescription("Documentos")   		  //"Documentos" 
oModel:GetModel("DB5DETAILS" ):SetDescription("Filiais Abastecidas") //"Abastecidas"

Return oModel 

//--------------------------------------------------------------------
/*/{Protheus.doc} ViewDef()
Definicao da View
@author Leonardo Quintania
@since 28/01/2013
@version 1.0
@return oView
/*/
//--------------------------------------------------------------------
Static Function ViewDef()  
Local oModel   	:= FWLoadModel( "MATA183" )	 //Carrega model definido
Local oStruCab 	:= FWFormViewStruct():New()  //Estrutura Cabecalho 
Local oStruDB5 	:= FWFormStruct(2,"DB5",{|cCampo| AllTrim(cCampo) $ "DB5_FILABA|DB5_NFILAB|DB5_OK"})  //Estrutura Filiais abastecidas
Local oView	  	:= FWFormView():New()

//-- Campo Doc. de Compra
oStruCab:AddField(	"DOCOMP"														,;	// [01]  C   Nome do Campo
				"29"																,;	// [02]  C   Ordem
				STR0001																,;	// [03]  C   Titulo do campo     //	"Doc. de Compra"
				STR0001																,;	// [04]  C   Descricao do campo  //	"Doc. de Compra"
				NIL																	,;	// [05]  A   Array com Help
				"C"																	,;	// [06]  C   Tipo do campo
				""																	,;	// [07]  C   Picture
				NIL																	,;	// [08]  B   Bloco de Picture Var
				NIL																	,;	// [09]  C   Consulta F3
				.T.																	,;	// [10]  L   Indica se o campo é alteravel
				NIL																	,;	// [11]  C   Pasta do campo
				NIL																	,;	// [12]  C   Agrupamento do campo
				{STR0002,STR0003}													,;	// [13]  A   Lista de valores permitido do campo (Combo)  //"1=Solicitação de Compra","2=Pedido de Compra"
				NIL																	,;	// [14]  N   Tamanho maximo da maior opção do combo
				NIL																	,;	// [15]  C   Inicializador de Browse
				.F.																	,;	// [16]  L   Indica se o campo é virtual
				NIL																	,;	// [17]  C   Picture Variavel
				NIL																	)	// [18]  L   Indica pulo de linha após o campo
				
//-- Campo Comprar na
oStruCab:AddField(	"COMPNA"														,;	// [01]  C   Nome do Campo
				"32"																,;	// [02]  C   Ordem
				STR0004 															,;	// [03]  C   Titulo do campo		//"Comprar na"
				STR0004																,;	// [04]  C   Descricao do campo     //"Comprar na"
				NIL																	,;	// [05]  A   Array com Help
				"C"																	,;	// [06]  C   Tipo do campo
				""																	,;	// [07]  C   Picture
				NIL																	,;	// [08]  B   Bloco de Picture Var
				NIL																	,;	// [09]  C   Consulta F3
				.T.																	,;	// [10]  L   Indica se o campo é alteravel
				NIL																	,;	// [11]  C   Pasta do campo
				NIL																	,;	// [12]  C   Agrupamento do campo
				{STR0005,STR0006}													,;	// [13]  A   Lista de valores permitido do campo (Combo)
				NIL																	,;	// [14]  N   Tamanho maximo da maior opção do combo
				NIL																	,;	// [15]  C   Inicializador de Browse
				.F.																	,;	// [16]  L   Indica se o campo é virtual
				NIL																	,;	// [17]  C   Picture Variavel
				NIL																	)	// [18]  L   Indica pulo de linha após o campo	

//-- Campo Entregar na
oStruCab:AddField(	"ENTRNA"														,;	// [01]  C   Nome do Campo
				"33"																,;	// [02]  C   Ordem
				STR0007 															,;	// [03]  C   Titulo do campo
				STR0007																,;	// [04]  C   Descricao do campo
				NIL																	,;	// [05]  A   Array com Help
				"C"																	,;	// [06]  C   Tipo do campo
				""																	,;	// [07]  C   Picture
				NIL																	,;	// [08]  B   Bloco de Picture Var
				NIL																	,;	// [09]  C   Consulta F3
				.T.																	,;	// [10]  L   Indica se o campo é alteravel
				NIL																	,;	// [11]  C   Pasta do campo
				NIL																	,;	// [12]  C   Agrupamento do campo
				{STR0005,STR0006}													,;	// [13]  A   Lista de valores permitido do campo (Combo) //"1=Distribuidora""2=Abastecida"
				NIL																	,;	// [14]  N   Tamanho maximo da maior opção do combo
				NIL																	,;	// [15]  C   Inicializador de Browse
				.F.																	,;	// [16]  L   Indica se o campo é virtual
				NIL																	,;	// [17]  C   Picture Variavel
				NIL																	)	// [18]  L   Indica pulo de linha após o campo	

//--------------------------------------
//		Associa o View ao Model
//--------------------------------------
oView:SetModel(oModel)  //-- Define qual o modelo de dados será utilizado
oView:SetUseCursor(.F.) //-- Remove cursor de registros'

//--------------------------------------
//		Insere os componentes na view
//--------------------------------------
oView:AddField("MASTER_DBI",oStruCab,"DBIMASTER")   //Cabecalho dos campos que podem ser alterados
oView:AddGrid("DETAILS_DB5",oStruDB5,"DB5DETAILS")	  //Filiais que processadas

//--------------------------------------
//		Cria os Box's
//--------------------------------------
oView:CreateHorizontalBox("CABEC",30)
oView:CreateHorizontalBox("GRIDDB5",70)

//--------------------------------------
//		Associa os componentes
//--------------------------------------
oView:SetOwnerView("MASTER_DBI" ,"CABEC")
oView:SetOwnerView("DETAILS_DB5","GRIDDB5")

Return oView

//--------------------------------------------------------------------
/*/{Protheus.doc} A183Commit()
Commit Manual
@author Leonardo Quintania
@since 28/01/2013
@version 1.0
@return aReturn
/*/
//--------------------------------------------------------------------
Static Function A183Commit(oModel)
Local lRet := .T.

If lRet

EndIf

Return lRet