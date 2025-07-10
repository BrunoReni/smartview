#INCLUDE "MATA179.CH"
#INCLUDE "FILEIO.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "FWFILTER.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} MATA179()
Cadastro dos campos de controle da matriz de abastecimento
@author Leonardo Quintania
@since 28/01/2013
@version 1.0
@return NIL
/*/
//-------------------------------------------------------------------
Function MATA179() 
Local oBrowse := Nil

//-- A nova central de compras so roda em TOP
Private aRotina := MenuDef()

oBrowse := FWMBrowse():New()
oBrowse:SetAlias("DBJ")
// Definição da legenda
oBrowse:AddLegend( "DBJ_FLAG=='1'", "GREEN", STR0001 )//"Normal"
oBrowse:AddLegend( "DBJ_FLAG=='2'", "RED" , STR0002 )//"Efetivado"
oBrowse:SetDescription(STR0003) // Central de compras - Parametros//"Central de compras - Parâmetros"
oBrowse:DisableDetails()
oBrowse:Activate()

Return NIL
                                                                                    
//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Menu Funcional

@author Leonardo Quintania
@since 28/01/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

ADD OPTION aRotina TITLE STR0004     	ACTION "AxPesqui"        	OPERATION 1 ACCESS 0//"Pesquisar"
ADD OPTION aRotina TITLE STR0005		ACTION "VIEWDEF.MATA179" 	OPERATION 3 ACCESS 0//"Gerar Sugestão"
ADD OPTION aRotina TITLE STR0006		ACTION "MT179Vis"			OPERATION 2 ACCESS 0//"Visualizar"
ADD OPTION aRotina TITLE STR0007      	ACTION "MT179EFE" 		  	OPERATION 4 ACCESS 0//"Alterar"
ADD OPTION aRotina TITLE STR0008      	ACTION "A181EFET" 		  	OPERATION 4 ACCESS 0//"Efetivar"
ADD OPTION aRotina TITLE STR0066      	ACTION "A179ChanMd" 		OPERATION 4 ACCESS 0//"Mudar Visao"
ADD OPTION aRotina TITLE STR0009      	ACTION "VIEWDEF.MATA179" 	OPERATION 5 ACCESS 0//"Excluir"

Return aRotina

//------------------------------------------------------------------
/*/{Protheus.doc} MT179Efe()
Definicao de qual modelo de dados sera chamado
@author Leonardo Quintania
@since 28/01/2013
@version 1.0
@return oModel
/*/
Function MT179Efe()

If DBJ->DBJ_TPAGLU == "1"	
	FWExecView (STR0010, "MATA181", MODEL_OPERATION_UPDATE ,/*oDlg*/ , {||.T.},/*bOk*/ ,/*nPercReducao*/ ,/*aEnableButtons*/ , /*bCancel*/ )//"Efetivar"
Else
	FWExecView (STR0011, "MATA182", MODEL_OPERATION_UPDATE ,/*oDlg*/ , {||.T.},/*bOk*/ ,/*nPercReducao*/ ,/*aEnableButtons*/ , /*bCancel*/ )	//"Efetivar"
EndIf	

Return .T.

//------------------------------------------------------------------
/*/{Protheus.doc} MT179Vis()
Visualizacao da tela de processamento
@author Leonardo Quintania
@since 28/01/2013
@version 1.0
@return oModel
/*/
Function MT179Vis()
	
If DBJ->DBJ_TPAGLU == "1"	
	FWExecView (STR0012, "MATA181", MODEL_OPERATION_VIEW ,/*oDlg*/ , {||.T.},/*bOk*/ ,/*nPercReducao*/ ,/*aEnableButtons*/ , /*bCancel*/ )//"Visualizar"
Else
	FWExecView (STR0013, "MATA182", MODEL_OPERATION_VIEW ,/*oDlg*/ , {||.T.},/*bOk*/ ,/*nPercReducao*/ ,/*aEnableButtons*/ , /*bCancel*/ )	//"Visualizar"
EndIf	

Return .T.

//------------------------------------------------------------------
/*/{Protheus.doc} A179ChanMd()
Muda a visão do modelo
@author Leonardo Quintania
@since 28/01/2013
@version 1.0
@return oModel
/*/
Function A179ChanMd()

RecLock("DBJ",.F.)
DBJ->DBJ_TPAGLU := If(DBJ->DBJ_TPAGLU == "1","2","1")
DBJ->(MsUnlock())

If DBJ->DBJ_FLAG # "1"		
	MT179Vis()
Else
	MT179Efe()
EndIf

Return .T.

//------------------------------------------------------------------
/*/{Protheus.doc} ModelDef()
Definicao do Modelo
@author Leonardo Quintania
@since 28/01/2013
@version 1.0
@return oModel
/*/
//-------------------------------------------------------------------
Static Function ModelDef()

Local oModel		:= MPFormModel():New("MATA179",/*Pre-Validacao*/, { |oModel| A179TudoOk( oModel ) },  { |oModel| A179GrvFil( oModel, oModel181 ) },/*Cancel*/)
Local oStruMain 	:= FWFormStruct(1,"DBJ") //Estrutura pai
Local oStruFilF 	:= FWFormStruct(1,"DB5",{|cCampo| AllTrim(cCampo) $ "DB5_FILABA|DB5_NFILAB|DB5_OK"})  //Estrutura Filiais abastecidas
Local oStruFilT 	:= NIL // Cria a estrutura filtro por tipo
Local oStruFilG 	:= FWFormStruct(1,"SBM",{|cCampo| AllTrim(cCampo) $ "BM_GRUPO|BM_DESC"}) //Campos do filtro por grupo de produtos
Local oStruFilC 	:= NIL 																						//Campos do filtro por categoria
Local oStruFilM	:= FWFormStruct(1,"MFU",{|cCampo| AllTrim(cCampo) $ "MFU_CODIGO|MFU_PRODUT|MFU_DESCRI"}) //Campos do filtro por categoria
Local oStruFil	:= FWFormStruct(1,"DBJ",{|cCampo| AllTrim(cCampo) $ "DBJ_FILSQL"}) 					// Cria a estrutura filtro padrao

Static oModel181
//------------------------------------------------
//		Cria a estrutura basica manualmente
//------------------------------------------------
oStruFilT	:= FWFormModelStruct():New()
oStruFilC	:= FWFormModelStruct():New()
oStruFilM:AddTrigger( "MFU_PRODUT", "MFU_DESCRI", {|| .T.},;
		 {|oModel|Padr(Posicione("SB1",1,xFilial("SB1") + oModel:GetValue("MFU_PRODUT"), "B1_DESC"),TamSx3("MFU_DESCRI")[1]) } )

//-- Campo Mark da aba de filtro por tipo
oStruFilT:AddField("" 																,;	// 	[01]  C   Titulo do campo  
				 ""																	,;	// 	[02]  C   ToolTip do campo 
				 "CHECKTP"															,;	// 	[03]  C   Id do Field
				 "L"																,;	// 	[04]  C   Tipo do campo
				 1																	,;	// 	[05]  N   Tamanho do campo
				 0																	,;	// 	[06]  N   Decimal do campo
				 NIL																,;	// 	[07]  B   Code-block de validação do campo
				 NIL																,;	// 	[08]  B   Code-block de validação When do campo
				 NIL																,;	//	[09]  A   Lista de valores permitido do campo
				 .F.																,;	//	[10]  L   Indica se o campo tem preenchimento obrigatório
				 FwBuildFeature( STRUCT_FEATURE_INIPAD, ".T." )			   			,; 	//	[11]  B   Code-block de inicializacao do campo
				 NIL																,;	//	[12]  L   Indica se trata-se de um campo chave
				 NIL																,;	//	[13]  L   Indica se o campo pode receber valor em uma operação de update.
				 .F.																)	// 	[14]  L   Indica se o campo é virtual
		 			 
//-- Campo Codigo da aba de filtro por tipo
oStruFilT:AddField("" 																,;	// 	[01]  C   Titulo do campo  
				 ""															   		,;	// 	[02]  C   ToolTip do campo 
				 "CODIGO"															,;	// 	[03]  C   Id do Field
				 "C"																,;	// 	[04]  C   Tipo do campo
				 TAMSX3("X5_CHAVE")[1]												,;	// 	[05]  N   Tamanho do campo
				 0																	,;	// 	[06]  N   Decimal do campo
				 NIL																,;	// 	[07]  B   Code-block de validação do campo
				 NIL																,;	// 	[08]  B   Code-block de validação When do campo
				 NIL																,;	//	[09]  A   Lista de valores permitido do campo
				 .F.																,;	//	[10]  L   Indica se o campo tem preenchimento obrigatório
				 NIL																,;	//	[11]  B   Code-block de inicializacao do campo
				 NIL																,;	//	[12]  L   Indica se trata-se de um campo chave
				 NIL																,;	//	[13]  L   Indica se o campo pode receber valor em uma operação de update.
				 .F.																)	// 	[14]  L   Indica se o campo é virtual

//-- Campo descricao da aba de filtro por tipo
oStruFilT:AddField("" 														   		,; 	// 	[01]  C   Titulo do campo  
				 ""																	,;	// 	[02]  C   ToolTip do campo
				 "DESCRICAO"														,;	// 	[03]  C   Id do Field
				 "C"																,;	// 	[04]  C   Tipo do campo
				 TAMSX3("X5_DESCRI")[1]										   		,; 	// 	[05]  N   Tamanho do campo
				 0																	,;	// 	[06]  N   Decimal do campo
				 NIL																,;	// 	[07]  B   Code-block de validação do campo
				 NIL																,;	// 	[08]  B   Code-block de validação When do campo
				 NIL																,;	//	[09]  A   Lista de valores permitido do campo
				 .F.																,;	//	[10]  L   Indica se o campo tem preenchimento obrigatório
				 NIL																,;	//	[11]  B   Code-block de inicializacao do campo
				 NIL																,;	//	[12]  L   Indica se trata-se de um campo chave
				 NIL																,;	//	[13]  L   Indica se o campo pode receber valor em uma operação de update.
				 .F.																)	// 	[14]  L   Indica se o campo é virtual		

//-- Campo Mark do Filtro por Grupo
oStruFilG:AddField("" 																,;	// 	[01]  C   Titulo do campo 
				 ""															  		,;	// 	[02]  C   ToolTip do campo
				 "CHECKGRP"													  		,;	// 	[03]  C   Id do Field
				 "L"																,;	// 	[04]  C   Tipo do campo
				 1																	,;	// 	[05]  N   Tamanho do campo
				 0																	,;	// 	[06]  N   Decimal do campo
				 NIL																,;	// 	[07]  B   Code-block de validação do campo
				 NIL																,;	// 	[08]  B   Code-block de validação When do campo
				 NIL																,;	//	[09]  A   Lista de valores permitido do campo
				 .F.																,;	//	[10]  L   Indica se o campo tem preenchimento obrigatório
				 FwBuildFeature( STRUCT_FEATURE_INIPAD, ".T." )			   			,;	//	[11]  B   Code-block de inicializacao do campo
				 NIL																,;	//	[12]  L   Indica se trata-se de um campo chave
				 NIL																,;	//	[13]  L   Indica se o campo pode receber valor em uma operação de update.
				 .F.																)	// 	[14]  L   Indica se o campo é virtual
				 
//-- Campo Codigo do Filtro por Categoria
oStruFilC:AddField("" 															,;	// 	[01]  C   Titulo do campo
				 ""																	,;	// 	[02]  C   ToolTip do campo
				 "CODCAT"															,;	// 	[03]  C   Id do Field
				 "C"																,;	// 	[04]  C   Tipo do campo
				 50																	,;	// 	[05]  N   Tamanho do campo
				 0																	,;	// 	[06]  N   Decimal do campo
				 NIL																,;	// 	[07]  B   Code-block de validação do campo
				 NIL																,;	// 	[08]  B   Code-block de validação When do campo
				 NIL																,;	//	[09]  A   Lista de valores permitido do campo
				 .F.																,;	//	[10]  L   Indica se o campo tem preenchimento obrigatório
				 NIL																,;	//	[11]  B   Code-block de inicializacao do campo
				 NIL																,;	//	[12]  L   Indica se trata-se de um campo chave
				 NIL																,;	//	[13]  L   Indica se o campo pode receber valor em uma operação de update.
				 .F.																)	// 	[14]  L   Indica se o campo é virtual

//-- Campo Codigo do Filtro por Categoria
oStruFilC:AddField("" 															,;	// 	[01]  C   Titulo do campo
				 ""																	,;	// 	[02]  C   ToolTip do campo
				 "DESCCAT"															,;	// 	[03]  C   Id do Field
				 "C"																,;	// 	[04]  C   Tipo do campo
				 30																	,;	// 	[05]  N   Tamanho do campo
				 0																	,;	// 	[06]  N   Decimal do campo
				 NIL																,;	// 	[07]  B   Code-block de validação do campo
				 NIL																,;	// 	[08]  B   Code-block de validação When do campo
				 NIL																,;	//	[09]  A   Lista de valores permitido do campo
				 .F.																,;	//	[10]  L   Indica se o campo tem preenchimento obrigatório
				 FwBuildFeature( STRUCT_FEATURE_INIPAD,"If(!INCLUI,Posicione('ACU',1,xFilial('ACU')+ FwFldGet('CODCAT'),'ACU_DESC'),'')" )																,;	//	[11]  B   Code-block de inicializacao do campo
				 NIL																,;	//	[12]  L   Indica se trata-se de um campo chave
				 NIL																,;	//	[13]  L   Indica se o campo pode receber valor em uma operação de update.
				 .T.																)	// 	[14]  L   Indica se o campo é virtual
				 			 				 
//-- Botao Monta Filtro
oStruFil:AddField(STR0014 												   			,;	// 	[01]  C   Titulo do campo//"Monta Filtro"
				 STR0015															,;	// 	[02]  C   ToolTip do campo//"Monta Filtro"
				 "BROWSE_NEWFILTER"													,;	// 	[03]  C   Id do Field
				 "BT"																,;	// 	[04]  C   Tipo do campo
				 1																	,;	// 	[05]  N   Tamanho do campo
				 0																	,;	// 	[06]  N   Decimal do campo
				 {|a,b,c| A179VldFil(a,b,c) }										,;	// 	[07]  B   Code-block de validação do campo
				 NIL																,;	// 	[08]  B   Code-block de validação When do campo
				 NIL																,;	//	[09]  A   Lista de valores permitido do campo
				 .F.																,;	//	[10]  L   Indica se o campo tem preenchimento obrigatório
				 NIL																,;	//	[11]  B   Code-block de inicializacao do campo
				 NIL																,;	//	[12]  L   Indica se trata-se de um campo chave
				 NIL																,;	//	[13]  L   Indica se o campo pode receber valor em uma operação de update.
				 .F.																)	// 	[14]  L   Indica se o campo é virtual
				 
//-- Botao Limpa Filtro
oStruFil:AddField(STR0016 											   				,;	// 	[01]  C   Titulo do campo   //"Limpa Filtro"
				 STR0017															,;	// 	[02]  C   ToolTip do campo  //"Monta Filtro"
				 "BROWSE_FILCLEAN"													,;	// 	[03]  C   Id do Field
				 "BT"																,;	// 	[04]  C   Tipo do campo
				 1																	,;	// 	[05]  N   Tamanho do campo
				 0																	,;	// 	[06]  N   Decimal do campo
				 {|a,b,c| A179VldFil(a,b,c) }										,;	// 	[07]  B   Code-block de validação do campo
				 NIL																,;	// 	[08]  B   Code-block de validação When do campo
				 NIL																,;	//	[09]  A   Lista de valores permitido do campo
				 .F.																,;	//	[10]  L   Indica se o campo tem preenchimento obrigatório
				 NIL																,;	//	[11]  B   Code-block de inicializacao do campo
				 NIL																,;	//	[12]  L   Indica se trata-se de um campo chave
				 NIL																,;	//	[13]  L   Indica se o campo pode receber valor em uma operação de update.
				 .F.																)	// 	[14]  L   Indica se o campo é virtual				 

//-- Botao Limpa Filtro
oStruFil:AddField(STR0018 															,;	// 	[01]  C   Titulo do campo   //"Filtro"
				 STR0019															,;	// 	[02]  C   ToolTip do campo  //"Filtro"
				 "BROWSE_FILDETAIL"													,;	// 	[03]  C   Id do Field
				 "M"																,;	// 	[04]  C   Tipo do campo
				 10																	,;	// 	[05]  N   Tamanho do campo
				 0																	,;	// 	[06]  N   Decimal do campo
				 {|a,b,c| A179VldFil(a,b,c) }										,;	// 	[07]  B   Code-block de validação do campo
				 NIL																,;	// 	[08]  B   Code-block de validação When do campo
				 NIL																,;	//	[09]  A   Lista de valores permitido do campo
				 .F.																,;	//	[10]  L   Indica se o campo tem preenchimento obrigatório
				 NIL																,;	//	[11]  B   Code-block de inicializacao do campo
				 NIL																,;	//	[12]  L   Indica se trata-se de um campo chave
				 NIL																,;	//	[13]  L   Indica se o campo pode receber valor em uma operação de update.
				 .F.																)	// 	[14]  L   Indica se o campo é virtual

oStruFilC:AddTrigger( "CODCAT", "DESCCAT", {|| .T.},;
	{|oModel|Padr(Posicione("ACU",1,xFilial("ACU") + oModel:GetValue("CODCAT"), "ACU_DESC"),TamSx3("ACU_DESC")[1]) } )
 
//------------------------------------------------------
//		Adiciona o componente de formulario no model 
//     Nao sera usado, mas eh obrigatorio ter
//------------------------------------------------------						
oModel:AddFields("CTMASTER"	 ,/*cOwner*/,oStruMain ,/*Pre-Validacao*/,/*Pos-Validacao*/, /*bLoad*/) //-- Central de Compras - Parametros
oModel:AddGrid  ("FIL_FILIAL","CTMASTER",oStruFilF ,/*Pre-Validacao*/,/*Pos-Validacao*/,/*bPre*/,/*bPost*/,{ |oModel| A179LdFil(oModel) }) //-- Filtro por Filiais
oModel:AddGrid  ("FIL_TIPO"  ,"CTMASTER",oStruFilT ,/*Pre-Validacao*/,/*Pos-Validacao*/,/*bPre*/,/*bPost*/,{ |oModel| A179LdTip(oModel) }) //-- Filtro por Tipo
oModel:AddGrid  ("FIL_GRUPO" ,"CTMASTER",oStruFilG ,/*Pre-Validacao*/,/*Pos-Validacao*/,/*bPre*/,/*bPost*/,{ |oModel| A179LdGrp(oModel) }) //-- Filtro por Grupo
oModel:AddGrid  ("FIL_CAT"   ,"CTMASTER",oStruFilC ,/*Pre-Validacao*/,/*Pos-Validacao*/,/*bPre*/,/*bPost*/,{ |oModel| A179LdCat(oModel) }) //-- Filtro por Categoria
oModel:AddGrid  ("FIL_MIX"   ,"CTMASTER",oStruFilM ,/*Pre-Validacao*/,/*Pos-Validacao*/,/*bPre*/,/*bPost*/,{ |oModel| A179LdMix(oModel) }) //-- Filtro por Mix 
oModel:AddFields("FIL_PAD" 	 ,"CTMASTER",oStruFil  ,/*Pre-Validacao*/,/*Pos-Validacao*/, { |oModel| A179LdPad( oModel ) }) //-- Filtro padrao

//--------------------------------------
//		Configura o model
//--------------------------------------
oModel:SetPrimaryKey( {} ) 		//Obrigatorio setar a chave primaria (mesmo que vazia)
oModel:SetDescription(STR0020) 	//Obrigatorio ter alguma descricao//"Central de Compras - Parâmetros"

oModel:GetModel( "FIL_TIPO" ):SetOptional( .T. )
oModel:GetModel( "FIL_GRUPO"):SetOptional( .T. )
oModel:GetModel( "FIL_CAT" 	):SetOptional( .T. )
oModel:GetModel( "FIL_MIX"  ):SetOptional( .T. )
oModel:GetModel( "FIL_PAD" 	):SetOptional( .T. )

oModel:GetModel( "FIL_TIPO" ):SetMaxLine(9999) //Limite de Linhas do aCols
oModel:GetModel( "FIL_GRUPO"):SetMaxLine(9999) //Limite de Linhas do aCols
oModel:GetModel( "FIL_CAT" 	):SetMaxLine(9999) //Limite de Linhas do aCols

//--------------------------------------
//		Configura descricao dos modelos
//--------------------------------------
oModel:GetModel("CTMASTER" 	 ):SetDescription(STR0021) //"Central de Compras - Parametros" //"Central de Compras - Parâmetros"
oModel:GetModel("FIL_FILIAL" ):SetDescription(STR0022)   	//STR0022 //"Por Filial"
oModel:GetModel("FIL_TIPO" 	 ):SetDescription(STR0023)     	//STR0023 //"Por Tipo"
oModel:GetModel("FIL_GRUPO"	 ):SetDescription(STR0024)    	//STR0024 //"Por Grupo"
oModel:GetModel("FIL_CAT"  	 ):SetDescription(STR0025)		//STR0025 //"Por Categoria"
oModel:GetModel("FIL_MIX"    ):SetDescription(STR0078)		//STR0078 //"Por Mix"
oModel:GetModel("FIL_PAD"  	 ):SetDescription(STR0026)     //"Filtro Padrao"//"Filtro"

//--------------------------------------
//		Validacao para nao permitir execucao de registros ja processados
//--------------------------------------
oModel:SetVldActivate( {|oModel| A179VLMod(oModel) } )

//--------------------------------------
//		Realiza carga dos grids antes da exibicao
//--------------------------------------
oModel:SetActivate( { |oModel| A179FilAct( oModel ) } )

//--------------------------------------
//		Nao gravar dados de um componente do modelo de dados
//--------------------------------------
oModel:GetModel( "FIL_FILIAL"):SetOnlyQuery ( .T. )
oModel:GetModel( "FIL_TIPO"  ):SetOnlyQuery ( .T. )
oModel:GetModel( "FIL_GRUPO" ):SetOnlyQuery ( .T. )
oModel:GetModel( "FIL_CAT"   ):SetOnlyQuery ( .T. ) 
oModel:GetModel( "FIL_MIX"   ):SetOnlyQuery ( .T. )
oModel:GetModel( "FIL_PAD"   ):SetOnlyQuery ( .T. )

//Muda comportamento de grid não criando acols
oModel:GetModel( 'FIL_FILIAL' ):SetUseOldGrid( .F. )
oModel:GetModel( 'FIL_TIPO' ):SetUseOldGrid( .F. )
oModel:GetModel( 'FIL_GRUPO' ):SetUseOldGrid( .F. )
oModel:GetModel( 'FIL_CAT' ):SetUseOldGrid( .F. )

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
Local oModel		:= FWLoadModel("MATA179")
Local oView	  	:= FWFormView():New()
Local oStruMain	:= FWFormStruct(2,"DBJ",{|cCampo| !AllTrim(cCampo) $ "DBJ_NFILDI|DBJ_MFILIA|DBJ_MTIPO|DBJ_MGRUPO|DBJ_MCATEG|DBJ_MFILT|DBJ_FILSQL|DBJ_FLAG"})
Local oStruFilF 	:= FWFormStruct(2,"DB5",{|cCampo| AllTrim(cCampo) $ "DB5_FILABA|DB5_NFILAB|DB5_OK"}) //Campos do filtro por filiais
Local oStruFilT	:= NIL
Local oStruFilG 	:= FWFormStruct(2,"SBM",{|cCampo| AllTrim(cCampo) $ "BM_GRUPO|BM_DESC"}) //Campos do filtro por grupo de produtos
Local oStruFilC 	:= NIL
Local oStruFilM 	:= FWFormStruct(2,"MFU",{|cCampo| AllTrim(cCampo) $ "MFU_CODIGO|MFU_PRODUT|MFU_DESCRI"}) //Campos do filtro por Mix
Local oStruFil	:= NIL
Local aAux			:= {}

//----------------------------------------------------------
//		Cria a estrutura View
//----------------------------------------------------------
oStruFilT:=FWFormViewStruct():New()
oStruFilC:=FWFormViewStruct():New()   
oStruFil :=FWFormViewStruct():New()  

//--------------------------------------
//		Associa o View ao Model
//--------------------------------------
oView:SetModel(oModel)  //-- Define qual o modelo de dados será utilizado
oView:SetUseCursor(.F.) //-- Remove cursor de registros'

//-- Campo Check da aba de filtro por tipo
oStruFilT:AddField(	"CHECKTP"														,;	// [01]  C   Nome do Campo
				"01"																,;	// [02]  C   Ordem
				"" 																	,;	// [03]  C   Titulo do campo
				""																	,;	// [04]  C   Descricao do campo
				NIL																	,;	// [05]  A   Array com Help
				"L"																	,;	// [06]  C   Tipo do campo
				""																	,;	// [07]  C   Picture
				NIL																	,;	// [08]  B   Bloco de Picture Var
				NIL																	,;	// [09]  C   Consulta F3
				.T.																	,;	// [10]  L   Indica se o campo é alteravel
				NIL																	,;	// [11]  C   Pasta do campo
				NIL																	,;	// [12]  C   Agrupamento do campo
				NIL																	,;	// [13]  A   Lista de valores permitido do campo (Combo)
				NIL																	,;	// [14]  N   Tamanho maximo da maior opção do combo
				NIL																	,;	// [15]  C   Inicializador de Browse
				.F.																	,;	// [16]  L   Indica se o campo é virtual
				NIL																	,;	// [17]  C   Picture Variavel
				NIL																	)	// [18]  L   Indica pulo de linha após o campo	

//-- Campo Codigo da aba de filtro por tipo
oStruFilT:AddField(	"CODIGO"														,;	// [01]  C   Nome do Campo
				"02"																,;	// [02]  C   Ordem
				STR0027																,;	// [03]  C   Titulo do campo//"Código"
				STR0028																,;	// [04]  C   Descricao do campo//"Código"
				NIL																	,;	// [05]  A   Array com Help
				"C"																	,;	// [06]  C   Tipo do campo
				""																	,;	// [07]  C   Picture
				NIL																	,;	// [08]  B   Bloco de Picture Var
				NIL																	,;	// [09]  C   Consulta F3
				.F.																	,;	// [10]  L   Indica se o campo é alteravel
				NIL																	,;	// [11]  C   Pasta do campo
				NIL																	,;	// [12]  C   Agrupamento do campo
				NIL																	,;	// [13]  A   Lista de valores permitido do campo (Combo)
				NIL																	,;	// [14]  N   Tamanho maximo da maior opção do combo
				NIL																	,;	// [15]  C   Inicializador de Browse
				.F.																	,;	// [16]  L   Indica se o campo é virtual
				NIL																	,;	// [17]  C   Picture Variavel
				NIL																	)	// [18]  L   Indica pulo de linha após o campo					

//-- Campo Codigo da aba de filtro por tipo
oStruFilT:AddField(	"DESCRICAO"														,;	// [01]  C   Nome do Campo
				"03"																,;	// [02]  C   Ordem
				STR0029																,;	// [03]  C   Titulo do campo//"Descrição"
				STR0030																,;	// [04]  C   Descricao do campo//"Descrição"
				NIL																	,;	// [05]  A   Array com Help
				"C"																	,;	// [06]  C   Tipo do campo
				""																	,;	// [07]  C   Picture
				NIL																	,;	// [08]  B   Bloco de Picture Var
				NIL																	,;	// [09]  C   Consulta F3
				.F.																	,;	// [10]  L   Indica se o campo é alteravel
				NIL																	,;	// [11]  C   Pasta do campo
				NIL																	,;	// [12]  C   Agrupamento do campo
				NIL																	,;	// [13]  A   Lista de valores permitido do campo (Combo)
				NIL																	,;	// [14]  N   Tamanho maximo da maior opção do combo
				NIL																	,;	// [15]  C   Inicializador de Browse
				.F.																	,;	// [16]  L   Indica se o campo é virtual
				NIL																	,;	// [17]  C   Picture Variavel
				NIL																	)	// [18]  L   Indica pulo de linha após o campo
			
//-- Campo Check Filtro por Grupo
oStruFilG:AddField(	"CHECKGRP"														,;	// [01]  C   Nome do Campo
				"01"																,;	// [02]  C   Ordem
				"" 																	,;	// [03]  C   Titulo do campo
				""																	,;	// [04]  C   Descricao do campo
				NIL																	,;	// [05]  A   Array com Help
				"L"																	,;	// [06]  C   Tipo do campo
				""																	,;	// [07]  C   Picture
				NIL																	,;	// [08]  B   Bloco de Picture Var
				NIL																	,;	// [09]  C   Consulta F3
				.T.																	,;	// [10]  L   Indica se o campo é alteravel
				NIL																	,;	// [11]  C   Pasta do campo
				NIL																	,;	// [12]  C   Agrupamento do campo
				NIL																	,;	// [13]  A   Lista de valores permitido do campo (Combo)
				NIL																	,;	// [14]  N   Tamanho maximo da maior opção do combo
				NIL																	,;	// [15]  C   Inicializador de Browse
				.F.																	,;	// [16]  L   Indica se o campo é virtual
				NIL																	,;	// [17]  C   Picture Variavel
				NIL																	)	// [18]  L   Indica pulo de linha após o campo	
				
//-- Campo Check Filtro por Categoria
oStruFilC:AddField(	"CODCAT"													,;	// [01]  C   Nome do Campo
				"01"																,;	// [02]  C   Ordem
				"Codigo"															,;	// [03]  C   Titulo do campo
				"Codigo"															,;	// [04]  C   Descricao do campo
				NIL																	,;	// [05]  A   Array com Help
				"C"																	,;	// [06]  C   Tipo do campo
				""																	,;	// [07]  C   Picture
				NIL																	,;	// [08]  B   Bloco de Picture Var
				"ACU"																,;	// [09]  C   Consulta F3
				.T.																	,;	// [10]  L   Indica se o campo é alteravel
				NIL																	,;	// [11]  C   Pasta do campo
				NIL																	,;	// [12]  C   Agrupamento do campo
				NIL																	,;	// [13]  A   Lista de valores permitido do campo (Combo)
				NIL																	,;	// [14]  N   Tamanho maximo da maior opção do combo
				NIL																	,;	// [15]  C   Inicializador de Browse
				.F.																	,;	// [16]  L   Indica se o campo é virtual
				NIL																	,;	// [17]  C   Picture Variavel
				NIL																	)	// [18]  L   Indica pulo de linha após o campo


//-- Campo Check Filtro por Categoria
oStruFilC:AddField(	"DESCCAT"													,;	// [01]  C   Nome do Campo
				"02"																,;	// [02]  C   Ordem
				"Descrição"														,;	// [03]  C   Titulo do campo
				"Descrição"														,;	// [04]  C   Descricao do campo
				NIL																	,;	// [05]  A   Array com Help
				"C"																	,;	// [06]  C   Tipo do campo
				""																	,;	// [07]  C   Picture
				NIL																	,;	// [08]  B   Bloco de Picture Var
				NIL																	,;	// [09]  C   Consulta F3
				.F.																	,;	// [10]  L   Indica se o campo é alteravel
				NIL																	,;	// [11]  C   Pasta do campo
				NIL																	,;	// [12]  C   Agrupamento do campo
				NIL																	,;	// [13]  A   Lista de valores permitido do campo (Combo)
				NIL																	,;	// [14]  N   Tamanho maximo da maior opção do combo
				NIL																	,;	// [15]  C   Inicializador de Browse
				.T.																	,;	// [16]  L   Indica se o campo é virtual
				NIL																	,;	// [17]  C   Picture Variavel
				NIL																	)	// [18]  L   Indica pulo de linha após o campo
				
//-- Campo Monta Filtro
oStruFil:AddField( "BROWSE_NEWFILTER" 												,;	// [01]  C   Nome do Campo
				"01"																,;	// [02]  C   Ordem
				STR0031																,;	// [03]  C   Titulo do campo//"Monta Filtro"
				STR0032																,;	// [04]  C   Descricao do campo//"Monta Filtro"
				{STR0033,""}														,;	// [05]  A   Array com Help//"Informe a filtro que será utilizado no filtro do Browse"
				"BT"																,;	// [06]  C   Tipo do campo
				""																	,;	// [07]  C   Picture
				NIL																	,;	// [08]  B   Bloco de Picture Var
				NIL																	,;	// [09]  C   Consulta F3
				.T.																	,;	// [10]  L   Indica se o campo é alteravel
				NIL																	,;	// [11]  C   Pasta do campo
				"GRP005"															,;	// [12]  C   Agrupamento do campo
				NIL																	,;	// [13]  A   Lista de valores permitido do campo (Combo)
				NIL																	,;	// [14]  N   Tamanho maximo da maior opção do combo
				NIL																	,;	// [15]  C   Inicializador de Browse
				.F.																	,;	// [16]  L   Indica se o campo é virtual
				NIL																	,;	// [17]  C   Picture Variavel
				NIL																	)	// [18]  L   Indica pulo de linha após o campo

//-- Campo Filtro
oStruFil:AddField(	"BROWSE_FILCLEAN" 												,;	// [01]  C   Nome do Campo
				"02"																,;	// [02]  C   Ordem
				STR0034																,;	// [03]  C   Titulo do campo//"Limpa Filtro"
				STR0035																,;	// [04]  C   Descricao do campo//"Limpa Filtro"
				{STR0036,""}														,;	// [05]  A   Array com Help//"Realiza a limpeza do filtro"
				"BT"																,;	// [06]  C   Tipo do campo
				""																	,;	// [07]  C   Picture
				NIL																	,;	// [08]  B   Bloco de Picture Var
				NIL																	,;	// [09]  C   Consulta F3
				.T.																	,;	// [10]  L   Indica se o campo é alteravel
				NIL																	,;	// [11]  C   Pasta do campo
				"GRP005"															,;	// [12]  C   Agrupamento do campo
				NIL																	,;	// [13]  A   Lista de valores permitido do campo (Combo)
				NIL																	,;	// [14]  N   Tamanho maximo da maior opção do combo
				NIL																	,;	// [15]  C   Inicializador de Browse
				.F.																	,;	// [16]  L   Indica se o campo é virtual
				NIL																	,;	// [17]  C   Picture Variavel
				NIL																	)	// [18]  L   Indica pulo de linha após o campo				
				
//-- Campo Filtro
oStruFil:AddField(	"BROWSE_FILDETAIL" 												,;	// [01]  C   Nome do Campo
				"03"																,;	// [02]  C   Ordem
				STR0037																,;	// [03]  C   Titulo do campo//"Filtro"
				STR0038																,;	// [04]  C   Descricao do campo//"Filtro"
				{STR0039,""}														,;	// [05]  A   Array com Help//"Indica o filtro que será realizado no Browse"
				"M"																	,;	// [06]  C   Tipo do campo
				""																	,;	// [07]  C   Picture
				NIL																	,;	// [08]  B   Bloco de Picture Var
				NIL																	,;	// [09]  C   Consulta F3
				.T.																	,;	// [10]  L   Indica se o campo é alteravel
				NIL																	,;	// [11]  C   Pasta do campo
				"GRP005"															,;	// [12]  C   Agrupamento do campo
				NIL																	,;	// [13]  A   Lista de valores permitido do campo (Combo)
				NIL																	,;	// [14]  N   Tamanho maximo da maior opção do combo
				NIL																	,;	// [15]  C   Inicializador de Browse
				.F.																	,;	// [16]  L   Indica se o campo é virtual
				NIL																	,;	// [17]  C   Picture Variavel
				NIL																	)	// [18]  L   Indica pulo de linha após o campo

//--------------------------------------
//		Insere os componentes na view
//--------------------------------------
oView:AddField("VIEW_MASTER",oStruMain,"CTMASTER")
oView:AddGrid ("FIL_FILIAL"	,oStruFilF,"FIL_FILIAL")
oView:AddGrid ("FIL_TIPO"  	,oStruFilT,"FIL_TIPO")
oView:AddGrid ("FIL_GRUPO"  ,oStruFilG,"FIL_GRUPO")
oView:AddGrid ("FIL_CAT"    ,oStruFilC,"FIL_CAT")
oView:AddGrid ("FIL_MIX"		,oStruFilM,"FIL_MIX")
oView:AddField("FIL_PAD"		,oStruFil ,"FIL_PAD")

//--------------------------------------
//		Cria os Groups
//--------------------------------------
oStruMain:AddGroup( "GRPMAIN"	, STR0040	, "" , 2 )//"Dados Gerais"
oStruMain:AddGroup( "GRPCOMSLD"	, STR0041	, "" , 2 )//"Composição de saldo "
oStruMain:AddGroup( "GRPPRVCON"	, STR0042	, "" , 2 )//"Previsão de consumo "

//--------------------------------------
//		Cria os Box's
//--------------------------------------
oView:CreateHorizontalBox( "CABEC"    ,60)
oView:CreateHorizontalBox( "INFERIOR" ,40)

//--------------------------------------
//		Cria Folder na view
//--------------------------------------
oView:CreateFolder( "FILTROS" , "INFERIOR" )

//--------------------------------------
//		Cria pastas nas folders
//--------------------------------------
oView:AddSheet( "FILTROS", 'ABA01', STR0043 )	//"Filiais Abastecidas"
oView:AddSheet( "FILTROS", 'ABA02', STR0044 )	//"Filtrar Tipo"
oView:AddSheet( "FILTROS", 'ABA03', STR0045 )	//"Filtrar Grupo"
oView:AddSheet( "FILTROS", 'ABA04', STR0046 )	//"Filtrar Categoria"
oView:AddSheet( "FILTROS", 'ABA06', STR0077 )	//"Filtrar Mix"
oView:AddSheet( "FILTROS", 'ABA05', STR0047 )	//"Fórmula"

oView:SelectFolder("FILTROS", 1, 2) // Deixa a primeira aba selecionada ao montar a tela.

//-------------------------------------------------------------
//	Criar "box" horizontal para receber algum elemento da view
//-------------------------------------------------------------
oView:CreateVerticalBox( "ABAS11"	, 8 ,,, "FILTROS", "ABA01" )
oView:CreateVerticalBox( "ABAS1"	, 92,,, "FILTROS", "ABA01" )
oView:CreateVerticalBox( "ABAS21"	, 8 ,,, "FILTROS", "ABA02" )
oView:CreateVerticalBox( "ABAS2" 	, 92,,, "FILTROS", "ABA02" )
oView:CreateVerticalBox( "ABAS31"	, 8 ,,, "FILTROS", "ABA03" )
oView:CreateVerticalBox( "ABAS3" 	, 92,,, "FILTROS", "ABA03" )

oView:CreateHorizontalBox( "ABAS4" , 100,,, "FILTROS", "ABA04" )
oView:CreateHorizontalBox( "ABAS6" , 100,,, "FILTROS", "ABA06" )
oView:CreateHorizontalBox( "ABAS5" , 100,,, "FILTROS", "ABA05" )

oView:AddOtherObject("MARK_FILAB",{|oPanel| a179Mark( oPanel, oView, oModel, "FILAB" )})
oView:AddOtherObject("MARK_TIPO" ,{|oPanel| a179Mark( oPanel, oView, oModel, "TIPO" )})
oView:AddOtherObject("MARK_GRUPO",{|oPanel| a179Mark( oPanel, oView, oModel, "GRUPO" )})

//--------------------------------------
//		Associa os componentes
//--------------------------------------
oView:SetOwnerView("VIEW_MASTER","CABEC"  )
oView:SetOwnerView("FIL_FILIAL" ,"ABAS1"  )
oView:SetOwnerView("FIL_TIPO"   ,"ABAS2"  )
oView:SetOwnerView("FIL_GRUPO"  ,"ABAS3"  )
oView:SetOwnerView("FIL_CAT"    ,"ABAS4"  )
oView:SetOwnerView("FIL_MIX"    ,"ABAS6"  )
oView:SetOwnerView("FIL_PAD"    ,"ABAS5"  )
oView:SetOwnerView("MARK_FILAB" ,"ABAS11"  )
oView:SetOwnerView("MARK_TIPO"  ,"ABAS21"  )
oView:SetOwnerView("MARK_GRUPO" ,"ABAS31"  )

//--------------------------------------
//		Associa os campos aos Groups
//--------------------------------------
oStruMain:SetProperty( "DBJ_FILDIS" , MVC_VIEW_GROUP_NUMBER, "GRPMAIN" )
oStruMain:SetProperty( "DBJ_SUGEST" , MVC_VIEW_GROUP_NUMBER, "GRPMAIN" )
oStruMain:SetProperty( "DBJ_TPSUG"  , MVC_VIEW_GROUP_NUMBER, "GRPMAIN" )
oStruMain:SetProperty( "DBJ_DOCCOM" , MVC_VIEW_GROUP_NUMBER, "GRPMAIN" )
oStruMain:SetProperty( "DBJ_COMPRA" , MVC_VIEW_GROUP_NUMBER, "GRPMAIN" )
oStruMain:SetProperty( "DBJ_ENTREG" , MVC_VIEW_GROUP_NUMBER, "GRPMAIN" )
oStruMain:SetProperty( "DBJ_TPOPER" , MVC_VIEW_GROUP_NUMBER, "GRPMAIN" )
oStruMain:SetProperty( "DBJ_TSTRAN" , MVC_VIEW_GROUP_NUMBER, "GRPMAIN" )
oStruMain:SetProperty( "DBJ_TPAGLU" , MVC_VIEW_GROUP_NUMBER, "GRPMAIN" )

oStruMain:SetProperty( "DBJ_CONEST" , MVC_VIEW_GROUP_NUMBER, "GRPCOMSLD" )
oStruMain:SetProperty( "DBJ_RESERV" , MVC_VIEW_GROUP_NUMBER, "GRPCOMSLD" )
oStruMain:SetProperty( "DBJ_EMPENH" , MVC_VIEW_GROUP_NUMBER, "GRPCOMSLD" )
oStruMain:SetProperty( "DBJ_PRVENT" , MVC_VIEW_GROUP_NUMBER, "GRPCOMSLD" )
oStruMain:SetProperty( "DBJ_PDCART" , MVC_VIEW_GROUP_NUMBER, "GRPCOMSLD" )
oStruMain:SetProperty( "DBJ_SLDTRA" , MVC_VIEW_GROUP_NUMBER, "GRPCOMSLD" )
oStruMain:SetProperty( "DBJ_ESTSEG" , MVC_VIEW_GROUP_NUMBER, "GRPCOMSLD" )
oStruMain:SetProperty( "DBJ_LTEEMB" , MVC_VIEW_GROUP_NUMBER, "GRPCOMSLD" )


oStruMain:SetProperty( "DBJ_METODO" , MVC_VIEW_GROUP_NUMBER, "GRPPRVCON" )
oStruMain:SetProperty( "DBJ_DTDE"	 , MVC_VIEW_GROUP_NUMBER, "GRPPRVCON" )
oStruMain:SetProperty( "DBJ_DTATE"  , MVC_VIEW_GROUP_NUMBER, "GRPPRVCON" )
oStruMain:SetProperty( "DBJ_INCREM" , MVC_VIEW_GROUP_NUMBER, "GRPPRVCON" )
oStruMain:SetProperty( "DBJ_DIASCO" , MVC_VIEW_GROUP_NUMBER, "GRPPRVCON" )
oStruMain:SetProperty( "DBJ_DEVVEN" , MVC_VIEW_GROUP_NUMBER, "GRPPRVCON" )

oStruFilF:SetProperty( "DB5_FILABA" , MVC_VIEW_CANCHANGE,.F.)

oStruFilG:SetProperty( "BM_GRUPO"   , MVC_VIEW_CANCHANGE,.F.)
oStruFilG:SetProperty( "BM_DESC"    , MVC_VIEW_CANCHANGE,.F.)
oStruFil:SetProperty( "BROWSE_FILDETAIL" , MVC_VIEW_CANCHANGE,.F.)

Return oView

//--------------------------------------------------------------------
/*/{Protheus.doc} A179VLMod()
Carga inicial do modelo.
@author Leonardo Quintania
@since 28/01/2013
@version 1.0
@return aReturn
/*/
//--------------------------------------------------------------------
Static Function A179VLMod(oModel)
Local lRet 		:= .T.
Local nOperation := oModel:GetOperation()

If DBJ->DBJ_FLAG # "1" 
	If nOperation == MODEL_OPERATION_UPDATE
		Help(" ",1,"A179ALTER")//"A sugestao esta efetivada, nao sera possível alteracao"
		lRet:= .F.
	ElseIf nOperation == MODEL_OPERATION_DELETE
		Help(" ",1,"A179DEL")//"A sugestao esta efetivada, nao sera possível exclusao"
		lRet:= .F.
	EndIf
EndIf

Return lRet

//--------------------------------------------------------------------
/*/{Protheus.doc} A179FilAct()
Carga inicial do modelo.
@author Leonardo Quintania
@since 28/01/2013
@version 1.0
@return aReturn
/*/
//--------------------------------------------------------------------
Static Function A179FilAct(oModel)
Local oModelSX5	 := oModel:GetModel("FIL_TIPO")
Local oModelSBM	 := oModel:GetModel("FIL_GRUPO")
Local aX5Tab02   :=  FWGetSX5( "02" )
Local nLinha	 := 0
Local nI		 := 0
Local nOperation := oModel:GetOperation()

If(nOperation == MODEL_OPERATION_INSERT)
	//--------------------------------------
	//		Configura modelo SX5
	//--------------------------------------
	oModelSX5:SetNoInsertLine( .F. )
	oModelSX5:SetNoDeleteLine( .F. )
	
	//--------------------------------------
	//		Preenche a tabela de tipos de produto SX5-02
	//--------------------------------------
	For nI := 1 to len(aX5Tab02)
		nLinha++
		If nLinha # 1
			oModelSX5:AddLine()
		EndIf
		oModelSX5:GoLine( nLinha )
		oModelSX5:SetValue("CHECKTP"	, .T. )
		oModelSX5:SetValue("CODIGO"		, aX5Tab02[nI][3] )
		oModelSX5:SetValue("DESCRICAO"	, aX5Tab02[nI][4] )

	Next nI
	//--------------------------------------
	//		Configura permissao dos modelos
	//--------------------------------------
	oModelSX5:GoLine( 1 )
	oModelSX5:SetNoInsertLine( .T. )
	oModelSX5:SetNoDeleteLine( .T. )
	
	//--------------------------------------
	//		Configura modelo SBM
	//--------------------------------------
	oModelSBM:SetNoInsertLine( .F. )
	oModelSBM:SetNoDeleteLine( .F. )
	nLinha:= 0
	//--------------------------------------
	//		Preenche a tabela de tipos de produto - SBM
	//--------------------------------------
	BeginSQL Alias "SBMTMP"
		SELECT *
   		FROM %Table:SBM% SBM
   		WHERE SBM.BM_FILIAL=%xFilial:SBM% AND SBM.%NotDel%
	EndSQL
	
	While !SBMTMP->(EOF())
		nLinha++
		If nLinha # 1
			oModelSBM:AddLine()
		EndIf
		oModelSBM:GoLine( nLinha )
		oModelSBM:LoadValue("CHECKGRP", .T. )
		oModelSBM:LoadValue("BM_GRUPO", SBMTMP->BM_GRUPO)
		oModelSBM:LoadValue("BM_DESC" , SBMTMP->BM_DESC )
		SBMTMP->(dbSkip())
	EndDo
	//--------------------------------------
	//		Configura permissao dos modelos
	//--------------------------------------
	oModelSBM:GoLine( 1 )
	oModelSBM:SetNoInsertLine( .T. )
	oModelSBM:SetNoDeleteLine( .T. )
	
	SBMTMP->(dbCloseArea())

Endif
	
Return .T.

//--------------------------------------------------------------------
/*/{Protheus.doc} A179ExpNiv()
Funcao responsavel pela explosao dos niveis de categoria
@author Leonardo Quintania
@since 28/01/2013
@version 1.0
@return aReturn
/*/
//--------------------------------------------------------------------
Function A179ExpNiv(cPai,cResult)
Local nRecno  	:= 0
Default cResult	:= ""

cPai:= Padr(cPai ,TamSx3("ACU_CODPAI")[1]) //Manter o tamanho igual
ACU->(dbSetOrder(2))
ACU->(dbSeek(xFilial("ACU")+cPai))
While !ACU->(EOF()) .And. ACU->(ACU_FILIAL+ACU_CODPAI) == xFilial("ACU")+cPai
	nRecno := ACU->(Recno())
	cResult+= ",'" + ACU->ACU_COD + "'"
	A179ExpNiv(ACU->ACU_COD,@cResult)
	ACU->(MsGoTo(nRecno))
	ACU->(dbSkip())
EndDo

Return cResult

//--------------------------------------------------------------------
/*/{Protheus.doc} A179FilFi()
Realiza o Load da aba de Filtro das filiais abastecidas.
@author Leonardo Quintania
@since 28/01/2013
@version 1.0
@return aReturn
/*/
//--------------------------------------------------------------------
Function A179FilFi(cFilDis)
Local oModel		:= FWModelActive()
Local oModelDB5	:= oModel:GetModel("FIL_FILIAL")
Local oModelMFU	:= Nil
Local nLinha		:= 0
Local nX			:= 0
Local nI			:= 0
Local lRet			:= .T.
Local aEmpAccess	:= FWEmpLoad(.F.)

If aScan(aEmpAccess,{|x| x[3] == FwFldGet('DBJ_FILDIS')}) == 0
	Help(" ",1,"A179NOACCESS",,,1,0)
	lRet := .F.
Else
	oModelDB5:SetNoInsertLine( .F. )
	oModelDB5:SetNoDeleteLine( .F. )

	//-------------------------------------------------------------------
	// Deleta as linhas do Grid para alimentar com novos dados
	//-------------------------------------------------------------------
	nX := oModelDB5:GetQtdLine()
	For nI := nX To 1 STEP -1
		oModelDB5:GoLine(nI)
		oModelDB5:DeleteLine(.T.,.T.)             
	Next nX

	BeginSQL Alias "DB5TMP"
		SELECT *
	   	FROM %Table:DB5% DB5
   		WHERE DB5.DB5_FILIAL=%xFilial:DB5% AND DB5.DB5_FILDIS=%Exp:cFilDis% AND DB5.%NotDel%
	EndSQL
	//-------------------------------------------------------------------
	// Preenche as linhas do Grid com novos dados
	//-------------------------------------------------------------------
	While !DB5TMP->(EOF())
		nLinha++
		If nLinha > oModelDB5:GetQtdLine()
			oModelDB5:AddLine()
		Else
			oModelDB5:UndeleteLine()
		EndIf
		oModelDB5:LoadValue("DB5_FILABA", DB5TMP->DB5_FILABA )
		oModelDB5:LoadValue("DB5_NFILAB", AllTrim(FwFilialName(,DB5TMP->DB5_FILABA)))
		oModelDB5:LoadValue("DB5_OK"	 , .T. )
		DB5TMP->(dbSkip())
	EndDo

	oModelDB5:GoLine( 1 )
	oModelDB5:SetNoInsertLine( .T. )
	oModelDB5:SetNoDeleteLine( .T. )

	DB5TMP->(dbCloseArea())
	
	//-- Faz a carga dos produtos de Mix no grid
	oModelMFU := oModel:GetModel("FIL_MIX") 
	
		//-- Configura modelo MFU
	oModelMFU:GoLine( 1 )
	oModelMFU:SetNoInsertLine( .F. )
	oModelMFU:SetNoDeleteLine( .F. )
	
		//-- Deleta as linhas do Grid para alimentar com novos dados
	nX := oModelMFU:GetQtdLine()
	For nI := nX To 1 STEP -1
		oModelMFU:GoLine(nI)
		oModelMFU:DeleteLine(.T.,.T.)             
	Next nX
	
	If oModelMFU:GetQtdLine() == 1 
		oModelMFU:GoLine(1)
		If oModelMFU:IsDeleted() 
			oModelMFU:UndeleteLine()
			oModelMFU:LoadValue("MFU_CODIGO" 	, "" )
			oModelMFU:LoadValue("MFU_PRODUT" 	, "" )
			oModelMFU:LoadValue("MFU_DESCRI" 	, "" )
		EndIf
	EndIf	 
	
		//-- Preenche a tabela de Mix
	BeginSQL Alias "MFUTMP"
		
			SELECT *
			FROM  %Table:MFU% MFU INNER JOIN
	              %Table:MFW% MFW ON MFU.MFU_CODIGO = MFW.MFW_CODIGO
			WHERE (MFU.MFU_FILIAL = %Exp:cFilDis% 	AND 
					MFW.MFW_FILIAL = %Exp:cFilDis% 	AND
					MFW.MFW_ATIVO = "1" 	        AND
					MFU.%NotDel%					AND
					MFW.%NotDel%)
		
	EndSQL
	If MFUTMP->(EOF())
		oModelMFU:LoadValue("MFU_CODIGO","")
	EndIf
	
	nLinha:= 0
	
	While !MFUTMP->(EOF())
		nLinha++
		If nLinha # 1
			oModelMFU:AddLine()
		Else
			oModelMFU:UndeleteLine()
		EndIf
		
		cSpace:= ""
		oModelMFU:LoadValue("MFU_CODIGO" 	,cSpace + MFUTMP->MFU_CODIGO  )
		oModelMFU:LoadValue("MFU_PRODUT" 	, MFUTMP->MFU_PRODUT )
		oModelMFU:LoadValue("MFU_DESCRI" 	, POSICIONE('SB1',1,XFILIAL('SB1')+MFUTMP->MFU_PRODUT,'B1_DESC')    ) 
		MFUTMP->(dbSkip())
	EndDo

	//-- Configura permissao dos modelos
	oModelMFU:GoLine(1)
	oModelMFU:SetNoInsertLine(.T.)
	oModelMFU:SetNoDeleteLine(.T.)
	MFUTMP->(dbCloseArea())
	
Endif

Return .T.

//--------------------------------------------------------------------
/*/{Protheus.doc} A179TudoOk()
Validacao TudoOK do formulario
@author Leonardo Quintania
@since 28/01/2013
@version 1.0
@return aReturn
/*/
//--------------------------------------------------------------------
Static Function A179TudoOk(oModel)
Local lRet 		:= .F.
Local nX			:= 0
Local nI			:= 0
Local oModelDBJ	:= oModel:GetModel("CTMASTER")
Local oModelDB5	:= oModel:GetModel("FIL_FILIAL")
Local oModelSX5	:= oModel:GetModel("FIL_TIPO")
Local oModelSBM	:= oModel:GetModel("FIL_GRUPO")
Local oModelACU	:= oModel:GetModel("FIL_CAT")
Local cFilDist	:= xFilial("SA1", oModelDBJ:GetValue("DBJ_FILDIS") )
Local lUsaFilTrf:= UsaFilTrf()
Local aAreaSM0  := SM0->(GetArea())
Local nOperation:= oModel:GetOperation()

oModel181	:=	FWLoadModel("MATA181")

// Validar se foi selecionado ao menos uma filial abastecida.
For nX:=1 to oModelDB5:length()
	oModelDB5:GoLine( nX )
	If oModelDB5:GetValue("DB5_OK")
		lRet := .T.
		Exit
	EndIf
Next nX
If !lRet // Caso nenhuma filial abastecida tenha sido selecionado
	Help(" ",1,"MTA179FIAB",,STR0067,1,0)// Ao menos uma filial abastecida deve ser selecionada.
EndIf

Do Case
	Case oModelDBJ:GetValue("DBJ_TPSUG") == "2"
		If Empty(oModelDBJ:GetValue("DBJ_TSTRAN"))
			Help(" ",1,"MTA179TES")//Ao seleciona o tipo de sugestão de transferência é obrigatório informar o campo Ts Transf.
			lRet := .F.
		EndIf	
	Case oModelDBJ:GetValue("DBJ_METODO") == "1" 
		If Empty(oModelDBJ:GetValue("DBJ_DTDE")) .Or. Empty(oModelDBJ:GetValue("DBJ_DTATE")) .Or. Empty(oModelDBJ:GetValue("DBJ_DIASCO"))
			Help(" ",1,"MTA179MD")//Ao seleciona o tipo de método média de vendas, é obrigatório informar os campos De, Até e Dias Cobert. 
			lRet := .F.
		EndIf
	Case oModelDBJ:GetValue("DBJ_METODO") == "2"
		If Empty(oModelDBJ:GetValue("DBJ_DTDE")) .Or. Empty(oModelDBJ:GetValue("DBJ_DTATE"))
			Help(" ",1,"MTA179PRV")//Ao seleciona o tipo de método previsão de vendas, é obrigatório informar os campos De e Ate
			lRet := .F.
		EndIf	
	Otherwise
		If Empty(oModelDBJ:GetValue("DBJ_DIASCO"))
			Help(" ",1,"MTA179DEM")//Ao seleciona o tipo de método demanda gerada, é obrigatório informar o campo de Dias Cobert. 
			lRet := .F.
		EndIf		
EndCase
//Define se sera utilizado o metodo antigo de localizacao do cliente/
//fornecedor (CNPJ) ou se utilizara o metodo novo, atraves dos campos
//A1_FILTRF.
If lRet .And. oModelDBJ:GetValue("DBJ_TPSUG") == "2"
	If lRet .And. !lUsaFilTrf // procedimento padrao, localizar filial atraves do CNPJ do cliente
		For nX:= 1 To oModelDB5:GetQtdLine()
			oModelDB5:GoLine( nX )
			If oModelDB5:GetValue("DB5_FILABA") == oModelDBJ:GetValue("DBJ_FILDIS")
				Loop
			EndIf
			If oModelDB5:GetValue("DB5_OK")
				SM0->(dbSeek(cEmpAnt+oModelDB5:GetValue("DB5_FILABA")))
				dbSelectArea("SA1")
				dbSetOrder(3)
				If !SA1->(dbSeek(cFilDist + SM0->M0_CGC ))
					Help(" ",1,"MTA179CLI")//Não é possivel efetuar o cadastro, pois existem filiais abastecidas que não possuem cadastro de clientes na filial distribuidora.
					lRet := .F.
					Exit				
				EndIf
			EndIf
		Next nX			
	Else //Metodo novo, atraves dos campos A1_FILTRF.
		For nX:= 1 To oModelDB5:GetQtdLine()
			oModelDB5:GoLine( nX )
			If oModelDB5:GetValue("DB5_FILABA") == oModelDBJ:GetValue("DBJ_FILDIS")
				Loop
			EndIf
			If oModelDB5:GetValue("DB5_OK")
				BeginSQL Alias "SA1TMP"
					SELECT *
					FROM %Table:SA1% SA1
					WHERE SA1.A1_FILIAL=%xFilial:SA1% AND SA1.A1_FILTRF=%Exp:oModelDB5:GetValue("DB5_FILABA")% AND SA1.%NotDel%
				EndSQL
					
				If SA1TMP->(EOF())
					Help(" ",1,"MTA179CLI")//Não é possivel efetuar o cadastro, pois existem filiais abastecidas que não possuem cadastro de clientes na filial distribuidora.
					lRet := .F.
				EndIf
				
				SA1TMP->(dbCloseArea())
				
				If !lRet
					Exit
				EndIf
			EndIf
		Next nX
	EndIf
EndIf
If lRet
	// Verifica se o usuário está cadastrado como comprador
	dbSelectArea("SY1")
	dbSetOrder(3)
	dbSeek(xFilial("SY1")+RetCodUsr())
	If !Found() .And. FwFldGet("DBJ_TPSUG") == "1"
		Help(" ",1,"A179NOCOMP")
		lRet := .F.
	Endif
EndIf

If lRet .And. FUNNAME() == "MATA179"
	If nOperation == MODEL_OPERATION_DELETE
		If !MsgYesNo(STR0065 + oModel:GetModel():GetModel("CTMASTER"):GetValue("DBJ_SUGEST") + '?',STR0062) //'"Confirma a exclusão da sugestão de compra "
			lRet := .F.
		EndIf 
	ElseIf !MsgYesNo(STR0061 + oModel:GetModel():GetModel("CTMASTER"):GetValue("DBJ_FILDIS") + '?',STR0062) //'Confirma o processamento para efetuar o cálculo da matriz '/'Central de Compras'
		HELP(" ",1,"CANCEL",,STR0063,1)
		lRet := .F.
	EndIf
EndIf
RestArea(aAreaSM0)

If lRet
	If(nOperation == MODEL_OPERATION_INSERT)
		For nI:= 1 To oModelDB5:GetQtdLine()
			oModelDB5:GoLine( nI )
			If !oModelDB5:GetValue("DB5_OK")
				oModelDBJ:SetValue("DBJ_MFILIA",oModelDB5:GetValue("DB5_FILABA") + "|" + oModelDBJ:GetValue("DBJ_MFILIA"))			
			EndIf
		Next nI
		
		For nI:= 1 To oModelSX5:GetQtdLine()
			oModelSX5:GoLine( nI )
			If !oModelSX5:GetValue("CHECKTP")
				oModelDBJ:SetValue("DBJ_MTIPO",oModelSX5:GetValue("CODIGO") + "|" + oModelDBJ:GetValue("DBJ_MTIPO"))			
			EndIf
		Next nI
		
		For nI:= 1 To oModelSBM:GetQtdLine()
			oModelSBM:GoLine( nI )
			If !oModelSBM:GetValue("CHECKGRP")
				oModelDBJ:SetValue("DBJ_MGRUPO",oModelSBM:GetValue("BM_GRUPO") + "|" + oModelDBJ:GetValue("DBJ_MGRUPO"))			
			EndIf
		Next nI
		
		For nI:= 1 To oModelACU:GetQtdLine()
			oModelACU:GoLine( nI )
			oModelDBJ:SetValue("DBJ_MCATEG",Alltrim(oModelACU:GetValue("CODCAT")) + "|" + Alltrim(oModelDBJ:GetValue("DBJ_MCATEG")))			
		Next nI
		
		oProcess := MSNewProcess():New( { | lEnd | lRet := A179CalCen( @lEnd, oModel, oModel181) }, STR0049, STR0048, .F. ) //'Aguarde, processando o cálculo...'//'Calculando'
		oProcess:Activate()
		
	EndIf
EndIf

Return lRet

//--------------------------------------------------------------------
/*/{Protheus.doc} A179GrvFil()
Realiza gravacao manual dos campos de filtros e realiza processamento de calculos
@author Leonardo Quintania
@since 28/01/2013
@version 1.0
@return aReturn
/*/
//--------------------------------------------------------------------
Static Function A179GrvFil(oModel, oModel181)
Local lRet			:= .T.
Local nOperation	:= oModel:GetOperation()
Local lMT179SUG	:= ExistBlock("MT179SUG")
Local oModelDBH	:= oModel181:GetModel("DBHDETAILS")
Local oModelDBI	:= oModel181:GetModel("DBIDETAILS")

BEGIN TRANSACTION
	If FWFormCommit(oModel)
		If nOperation == MODEL_OPERATION_DELETE
			//³Instancia modelo de dados(Model) para fetuar exclusao das tabelas DBI e DBH ³
			oModel181	:= FWLoadModel("MATA181")
			oModel181:SetOperation(nOperation)
			
			DBH->(dbSetOrder(1))
			DBH->(dbSeek(xFilial("DBH")+DBJ->DBJ_SUGEST)) //Posiciona registro da tabela
			//³Ativa o modelo de dados ³
			If (lRet := oModel181:Activate()) // Ativa o modelo com os dados posicionados
				//³Valida os dados e integridade conforme dicionario do Model ³
				If (lRet := oModel181:VldData())
					//³Efetiva gravacao dos dados na tabela ³
					lRet := oModel181:CommitData()
				EndIf
			EndIf
		Else
			//³Valida os dados e integridade conforme dicionario do Model ³
			If lRet := oModel181:VldData()
				//³Efetiva gravacao dos dados na tabela ³
				lRet := oModel181:CommitData()
			EndIf
		EndIf
	EndIf
END TRANSACTION

// Ponto de entrada para manipulacao dos registros DBH/DBI
// Este trecho nao e contemplado pelo ponto de entrada padrao do MVC
If lMT179SUG
	ExecBlock("MT179SUG",.F.,.F.,{oModelDBH,oModelDBI})
EndIf
		
oModel181:DeActivate()
oModel181:Destroy()

Return lRet

//--------------------------------------------------------------------
/*/{Protheus.doc} A179LdFil()
Realiza o Load das filiais
@author Leonardo Quintania
@since 28/01/2013
@version 1.0
@return aReturn
/*/
//--------------------------------------------------------------------
Static Function A179LdFil(oModel)
Local nI			:= 0
Local cFilDis		:= DBJ->DBJ_FILDIS
Local aRet		:= {}
Local aLine		:= {}
Local aReg		:= StrTokArr ( DBJ->DBJ_MFILIA, "|" )

//-------------------------------------------------------------------
// Procura as filiais abastecidas conforme a filial distribuidora enviada
//-------------------------------------------------------------------
BeginSQL Alias "DB5TMP"
	SELECT *
   	FROM %Table:DB5% DB5
   	WHERE DB5.DB5_FILIAL=%xFilial:DB5% AND DB5.DB5_FILDIS=%Exp:cFilDis% AND DB5.%NotDel%
EndSQL

//-------------------------------------------------------------------
// Preenche as linhas do Grid com novos dados
//-------------------------------------------------------------------
While !DB5TMP->(EOF())
	//-------------------------------------------------------------------
	// Desmarca as filiais que nao foram selecionada conforme campo DBJ_MFILIA
	//-------------------------------------------------------------------
	For nI:= 1 To Len(aReg)
		If aReg[nI] == DB5TMP->DB5_FILABA
			Aadd(aLine, .F.)
			Exit
		EndIf			
	Next nI
	//-------------------------------------------------------------------
	// Se nao existe pelo menos uma ocorrencia fica marcado
	//-------------------------------------------------------------------
	If Empty(aLine)
		Aadd(aLine, .T.)
	EndIf
	
	Aadd(aLine, DB5TMP->DB5_FILABA)
	Aadd(aLine, FwFilialName(,DB5TMP->DB5_FILABA))
	Aadd(aRet,{ DB5TMP->(Recno()),aLine})
	aLine	:= {}
	DB5TMP->(dbSkip())
EndDo

DB5TMP->(dbCloseArea())
Return aRet

//--------------------------------------------------------------------
/*/{Protheus.doc} A179LdTip()
Realiza o Load da grid de tipo
@author Leonardo Quintania
@since 28/01/2013
@version 1.0
@return aReturn
/*/
//--------------------------------------------------------------------
Static Function A179LdTip(oModel)
Local nI	:= 0
Local nY	:= 0
Local aRet	:= {}
Local aLine	:= {}
Local aReg	:= StrTokArr ( DBJ->DBJ_MTIPO, "|" )
Local aX5Tab02   :=  FWGetSX5( "02" )
//--------------------------------------
//		Preenche a tabela de tipos de produto SX5-02
//--------------------------------------

//-------------------------------------------------------------------
// Preenche as linhas do Grid com novos dados
//-------------------------------------------------------------------
For nY := 1 to len(aX5Tab02)
	//-------------------------------------------------------------------
	// Desmarca os registros que nao foram selecionada conforme campo DBJ_MTIPO
	//-------------------------------------------------------------------
	For nI:= 1 To Len(aReg)
		If aReg[nI] ==  aX5Tab02[nY][3] 
			Aadd(aLine, .F.)
			Exit
		EndIf			
	Next nI

	//-------------------------------------------------------------------
	// Se nao existe pelo menos uma ocorrencia fica marcado
	//-------------------------------------------------------------------
	If Empty(aLine)
		Aadd(aLine, .T.)
	EndIf
	
	Aadd(aLine,  aX5Tab02[nY][3] )
	Aadd(aLine,  aX5Tab02[nY][4] )
	Aadd(aRet,{ nY,aLine})
	aLine	:= {}
next NY
Return aRet

//--------------------------------------------------------------------
/*/{Protheus.doc} A179LdGrp()
Realiza o Load da da grid de grupo
@author Leonardo Quintania
@since 28/01/2013
@version 1.0
@return aReturn
/*/
//--------------------------------------------------------------------
Static Function A179LdGrp(oModel)
Local nI		:= 0
Local aRet	:= {}
Local aLine	:= {}
Local aReg	:= StrTokArr ( DBJ->DBJ_MGRUPO, "|" )

//--------------------------------------
//		Preenche a tabela de tipos de produto - SBM
//--------------------------------------
BeginSQL Alias "SBMTMP"
	SELECT *
   		FROM %Table:SBM% SBM
   		WHERE SBM.BM_FILIAL=%xFilial:SBM% AND SBM.%NotDel%
EndSQL
//-------------------------------------------------------------------
// Preenche as linhas do Grid com novos dados
//-------------------------------------------------------------------
While !SBMTMP->(EOF())

	Aadd(aLine, SBMTMP->BM_GRUPO )
	Aadd(aLine, SBMTMP->BM_DESC)
	//-------------------------------------------------------------------
	// Desmarca os registros que nao foram selecionada conforme campo DBJ_MTIPO
	//-------------------------------------------------------------------
	For nI:= 1 To Len(aReg)
		If aReg[nI] == SBMTMP->BM_GRUPO
			Aadd(aLine, .F.)
			Exit
		EndIf			
	Next nI
	//-------------------------------------------------------------------
	// Se nao existe pelo menos uma ocorrencia fica marcado
	//-------------------------------------------------------------------
	If Len(aLine)==2		
		Aadd(aLine, .T.)
	EndIf	
	Aadd(aRet,{ SBMTMP->(Recno()),aLine})
	aLine	:= {}
	SBMTMP->(dbSkip())
EndDo

SBMTMP->(dbCloseArea())

Return aRet

//--------------------------------------------------------------------
/*/{Protheus.doc} A179LdCat()
Realiza o Load da grid de categoria
@author Leonardo Quintania
@since 28/01/2013
@version 1.0
@return aReturn
/*/
//--------------------------------------------------------------------
Static Function A179LdCat(oModel)
Local nI			:= 0
Local aRet			:= {}
Local aLine		:= {}
Local aReg			:= StrTokArr ( DBJ->DBJ_MCATEG, "|" )
Local cFilialACU	:= xFilial("ACU")
Local nOperation	:= oModel:GetOperation()

If nOperation # MODEL_OPERATION_INSERT
	For nI:= 1 To Len(aReg)
		If ACU->(dbSeek(cFilialACU+aReg[nI]))
			Aadd(aLine, aReg[nI])
			Aadd(aLine, ACU->ACU_DESC)
			Aadd(aRet,{ ACU->(Recno()),aLine})
			aLine	:= {}
		EndIf
	Next nI
EndIf
Return aRet


//--------------------------------------------------------------------
/*/{Protheus.doc} A179LdMix()
Realiza o Load da da grid de Mix
@author Varejo
@since 09/06/2014
@version 1.0
@return aReturn
/*/

//--------------------------------------------------------------------
Static Function A179LdMix(oModel) 
Local nI			:= 0
Local cFilDis		:= DBJ->DBJ_FILDIS
Local aRet		:= {}
Local aLine		:= {}
Local aReg	:= StrTokArr ( DBI->DBI_PRODUT, "|" )


//-------------------------------------------------------------------
// Procura os produtos selecionados conforme a filial setada no Mix
//-------------------------------------------------------------------
BeginSQL Alias "MFUTMP"
	SELECT *
   	FROM %Table:MFU% MFU
   	WHERE MFU.MFU_FILIAL=%Exp:cFilDis% AND MFU.%NotDel%
EndSQL

//-------------------------------------------------------------------
// Preenche as linhas do Grid com novos dados
//-------------------------------------------------------------------
While !MFUTMP->(EOF())

	Aadd(aLine, MFUTMP->MFU_CODIGO )
	Aadd(aLine, MFUTMP->MFU_PRODUT )
		
	//-------------------------------------------------------------------
	// Desmarca os registros que nao foram selecionada conforme campo DBJ_MTIPO
	//-------------------------------------------------------------------
	For nI:= 1 To Len(aReg)
		If aReg[nI] == MFUTMP->MFU_CODIGO
			Aadd(aLine, .F.)
			Exit
		EndIf			
	Next nI
	//-------------------------------------------------------------------
	// Se nao existe pelo menos uma ocorrencia fica marcado
	//-------------------------------------------------------------------
	If Len(aLine)==2		
		Aadd(aLine, POSICIONE('SB1',1,XFILIAL('SB1')+MFUTMP->MFU_PRODUT,'B1_DESC'))
	EndIf	
		Aadd(aRet,{ MFUTMP->(Recno()),aLine})
		aLine	:= {}
		MFUTMP->(dbSkip())
EndDo

MFUTMP->(dbCloseArea())

Return aRet


//--------------------------------------------------------------------
/*/{Protheus.doc} A179LdPad()
Realiza o Load do filtro padrao
@author Leonardo Quintania
@since 28/01/2013
@version 1.0
@return aReturn
/*/
//--------------------------------------------------------------------
Static Function A179LdPad(oModel)
Local aRet		:= {}

Aadd(aRet, DBJ->DBJ_FILSQL)
Aadd(aRet, 1)
Aadd(aRet, 1)
Aadd(aRet, DBJ->DBJ_MFILT)

Return aRet

//--------------------------------------------------------------------
/*/{Protheus.doc} A179VldMet()
Realiza validacao com base no que foi informado no campo DBJ_METODO
@author Leonardo Quintania
@since 28/01/2013
@version 1.0
@return aReturn
/*/
//--------------------------------------------------------------------
Function A179VldMet()
Local oModel		:= FWModelActive()
Local oModelDBJ	:= oModel:GetModel("CTMASTER")

If oModelDBJ:GetValue("DBJ_METODO") == "1"
	oModelDBJ:LoadValue("DBJ_DTDE"  , CTOD("  /  /  ") )	
	oModelDBJ:LoadValue("DBJ_DTATE" , CTOD("  /  /  ") )
	oModelDBJ:LoadValue("DBJ_INCREM", 0 )
	oModelDBJ:LoadValue("DBJ_DIASCO", 0 )
	oModelDBJ:LoadValue("DBJ_DEVVEN", .T. )	
Else
	oModelDBJ:LoadValue("DBJ_DTDE"  , CTOD("  /  /  ") )	
	oModelDBJ:LoadValue("DBJ_DTATE" , CTOD("  /  /  ") )
	oModelDBJ:LoadValue("DBJ_INCREM", 0 )
	oModelDBJ:LoadValue("DBJ_DIASCO", 0 )
	oModelDBJ:LoadValue("DBJ_DEVVEN", .F. )
EndIf

Return .T.

//--------------------------------------------------------------------
/*/{Protheus.doc} A179VldFil()
Realiza criação de filtro da tabela SB1
@author Leonardo Quintania
@since 28/01/2013
@version 1.0
@return aReturn
/*/
//--------------------------------------------------------------------
Static Function A179VldFil(oModel,cField,xConteud)
Local oFWFilter 
Local oMaster		:= oModel:GetModel()
Local oModelDBJ		:= oMaster:GetModel("CTMASTER")
Local lRet			:= .T.
Local aFields		:= {}
Local nI			:= 0
Local nX			:= 0
Local cFiltro		:= ""

If cField == "BROWSE_FILCLEAN"
	//------------------------------------------------------------------- 
	// Realiza a limpeza do filtro 
	//------------------------------------------------------------------- 
	oModel:LoadValue("BROWSE_FILDETAIL","")  
	
ElseIf cField == "BROWSE_NEWFILTER"
	//-------------------------------------------------------------------
	// Apresenta a interface de filtro para configuração
	//-------------------------------------------------------------------
	oFWFilter := FWFilter():New()
	oFWFilter:SetButton()
	oFWFilter:SetCanFilterAsk(.F.)
	//-------------------------------------------------------------------
	// Carrega os campos utilizados para o filtro
	//-------------------------------------------------------------------
	dbSelectArea("SB1")
	aStruct := DbStruct()
	For nI := 1 To Len(aStruct)
		Aadd( aFields, { aStruct[nI,1], aStruct[nI,1], aStruct[nI,2], aStruct[nI,3], aStruct[nI,4], } )
	Next nI
	oFWFilter:SetField(aFields)
	oFWFilter:EditFilter()
	//-------------------------------------------------------------------
	// Atualiza o filtro no campo MEMO
	//-------------------------------------------------------------------
	If !Empty(oFWFilter:aFilter)
		oModel:LoadValue("BROWSE_FILDETAIL",oFWFilter:aFilter[1,FILTER])
		cFiltro :=  oFWFilter:aFilter[1,FILTER_SQL]

		For nX := 1 to len(oFWFilter:aFilter[1][4])
			If oFWFilter:aFilter[1][4][nx][2] == "FUNCTION"
				cFiltro :=  STRTRAN(cFiltro,oFWFilter:aFilter[1][4][nx][1],&(oFWFilter:aFilter[1][4][nx][1]))
			EndIf
		next

		oModel:LoadValue("BROWSE_FILDETAIL",oFWFilter:aFilter[1,FILTER])
		oModelDBJ:SetValue("DBJ_FILSQL"	   ,cFiltro)
		oModelDBJ:SetValue("DBJ_MFILT"	   ,oFWFilter:aFilter[1,FILTER])

	EndIf
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} A179CalCen()
Realiza processamento conforme parametros informado.
@author Rodrigo Toledo
@since 02/02/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function A179CalCen(lEnd, oModel, oModel181)
Local nSldDispon	:= 0
Local nQtdeReg	:= 0                     
Local nX			:= 0
Local nY			:= 0
Local nPrevCons	:= 0
Local nPrecoProd	:= 0
Local nNecessCalc	:= 0
Local nPos			:= 0
Local nRetry_0	:= 0
Local nRetry_1	:= 0
Local nHdl			:= 0
Local nThreads	:= 0
Local nTot			:= 0
Local aSaldoSB1	:= {}
Local aNecessCalc	:= {}
Local aThreads	:= {}
Local aQuebraThr	:= {}
Local aProdutos	:= {}
Local aJobAux		:= {}
Local aStruDBI	:= {}
Local aErro		:= {}
Local aFiltro		:= {}
Local oMaster		:= oModel:GetModel("CTMASTER")
Local oGrdTpPrd	:= oMaster:GetModel():GetModel("FIL_TIPO")
Local oGrdGrPrd	:= oMaster:GetModel():GetModel("FIL_GRUPO")
Local oGrdCtPrd	:= oMaster:GetModel():GetModel("FIL_CAT")
Local oGrdMxPrd	:= oMaster:GetModel():GetModel("FIL_MIX")
Local oGrdFilial	:= oMaster:GetModel():GetModel("FIL_FILIAL")
Local oModelDBH	:= oModel181:GetModel("DBHDETAILS")
Local oModelDBI	:= oModel181:GetModel("DBIDETAILS")
Local lRet			:= .F.
Local lProcessa	:= .F.
Local lFilTpPrd	:= .T.
Local lFilGrPrd	:= .T.
Local lFilMxPrd	:= .T.
Local lUsaFilTrf	:= UsaFilTrf()
Local lUtilizaMix	:= .F.
Local cFilAntBkp	:= cFilAnt
Local cFiltroDB5	:= "%%"
Local cJoin		:= "%%"
Local cFiltFabri	:= "%%"
Local cCodForCli	:= ""
Local cLojForCli	:= ""
Local cFilPrcFor	:= ""
Local cLogErro		:= ""
Local cCondPagto	:= ""
Local cFiltroSB1	:= ""
Local cWhere		:= ""
Local cFilTpPrd		:= ""
Local cFilGrPrd 	:= ""
Local cFilCtPrd 	:= ""
Local cFilMxPrd   	:= "" 
Local cFilAbast 	:= ""
Local cFilialDBI	:= ""
Local cFilialSA2	:= ""
Local cFilialSA5	:= ""
Local cFilialSB1	:= ""
Local cFilialSB2	:= ""
Local cJobFile	:= ""
Local cJobAux		:= ""
Local cTabelaTMP	:= ""
Local cDbj_FilDis	:= oMaster:GetValue("DBJ_FILDIS")
Local cDbj_TpSug	:= oMaster:GetValue("DBJ_TPSUG")
Local cDbj_DocCom	:= oMaster:GetValue("DBJ_DOCCOM")
Local cDbj_Sugest	:= oMaster:GetValue("DBJ_SUGEST")
Local cDbj_Compra	:= oMaster:GetValue("DBJ_COMPRA")
Local cDbj_Entreg	:= oMaster:GetValue("DBJ_ENTREG")
Local cDbj_Metodo	:= oMaster:GetValue("DBJ_METODO")
Local dDbj_DtDe	:= oMaster:GetValue("DBJ_DTDE")
Local dDbj_DtAte	:= oMaster:GetValue("DBJ_DTATE")
Local cStartPath	:= GetSrvProfString("Startpath","")
Local aAux			:= {}
Local lExistMsBl	:= SB1->(FieldPos("B1_MSBLQL")) > 0
Local lFabri		:= SuperGetMV("MV_CCFABRI",.F.,.F.)
Local cRestCom	:= SuperGetMV("MV_RESTCOM",.F.,'N')
Local lPrdImport	:= SuperGetMV("MV_PRDIMPO",.F.,.F.)
Local oTmpTable		:= Nil

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿	
//³ Inicializa o log de processamento   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ProcLogIni( {},"MATA179")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Atualiza o log de processamento   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ProcLogAtu("INICIO")

// Montra a Estrutura do arquivo temporario (Tabela DBI)
aStruDBI := {}
aTam := TamSX3("DBI_FILABA") 
AADD(aStruDBI ,{"DBI_FILABA","C",aTam[1],aTam[2]})
aTam := TamSX3("DBI_PRODUT") 
AADD(aStruDBI ,{"DBI_PRODUT","C",aTam[1],aTam[2]})
aTam := TamSX3("DBI_DESCPR") 
AADD(aStruDBI ,{"DBI_DESCPR","C",aTam[1],aTam[2]})
aTam := TamSX3("DBI_CONSUM") 
AADD(aStruDBI ,{"DBI_CONSUM","N",aTam[1],aTam[2]})
aTam := TamSX3("DBI_SLDABA") 
AADD(aStruDBI ,{"DBI_SLDABA","N",aTam[1],aTam[2]})
aTam := TamSX3("DBI_FORNEC") 
AADD(aStruDBI ,{"DBI_FORNEC","C",aTam[1],aTam[2]})
aTam := TamSX3("DBI_LOJA") 
AADD(aStruDBI ,{"DBI_LOJA","C",aTam[1],aTam[2]})
aTam := TamSX3("DBI_COND") 
AADD(aStruDBI ,{"DBI_COND","C",aTam[1],aTam[2]})
aTam := TamSX3("DBI_PRECO") 
AADD(aStruDBI ,{"DBI_PRECO" ,"N",aTam[1],aTam[2]})
aTam := TamSX3("DBI_SLDTRA") 
AADD(aStruDBI ,{"DBI_SLDTRA","N",aTam[1],aTam[2]})
aTam := TamSX3("DBI_NECALC") 
AADD(aStruDBI ,{"DBI_NECALC","N",aTam[1],aTam[2]})
aTam := TamSX3("DBI_NECINF") 
AADD(aStruDBI ,{"DBI_NECINF","N",aTam[1],aTam[2]})
aTam := TamSX3("DBI_DOCOMP") 
AADD(aStruDBI ,{"DBI_DOCOMP","C",aTam[1],aTam[2]})
aTam := TamSX3("DBI_QTDCOM") 
AADD(aStruDBI ,{"DBI_QTDCOM","N",aTam[1],aTam[2]})
aTam := TamSX3("DBI_SLDTRA") //Guarda o saldo do array aSaldoSB1
AADD(aStruDBI ,{"DBI_SLDSB1","N",aTam[1],aTam[2]})
AADD(aStruDBI ,{"DBI_SLDFIX","N",aTam[1],aTam[2]})

oModel181:SetOperation(3)

cFiltroSB1 := "%"

SA5->(dbSetOrder(1))

//-- Prepara filtro por tipo de produto
For nX := 1 To oGrdTpPrd:GetQtdLine()
	oGrdTpPrd:GoLine(nX)
	If 	oGrdTpPrd:GetValue("CHECKTP")
		cFilTpPrd += If(Empty(cFilTpPrd), "'" + Alltrim(oGrdTpPrd:GetValue("CODIGO")) + "'", ",'" + AllTrim(oGrdTpPrd:GetValue("CODIGO")) + "'")
	ElseIf lFilTpPrd
		lFilTpPrd := .F.
	EndIf
Next nX
If !Empty(cFilTpPrd) .And. !(lFilTpPrd)
	cFiltroSB1 += " AND SB1.B1_TIPO IN ("+cFilTpPrd+")"
EndIf
	
//-- Prepara filtro por grupo de produto	
For nX := 1 To oGrdGrPrd:GetQtdLine()
	oGrdGrPrd:GoLine(nX)
	If 	oGrdGrPrd:GetValue("CHECKGRP")
		cFilGrPrd += If(Empty(cFilGrPrd), "'" + Alltrim(oGrdGrPrd:GetValue("BM_GRUPO")) + "'", ",'" + AllTrim(oGrdGrPrd:GetValue("BM_GRUPO")) + "'")
	ElseIf lFilGrPrd
		lFilGrPrd := .F.
	EndIf
Next nX	

If !Empty(cFilGrPrd) .And. !(lFilGrPrd) 
	cFiltroSB1 += " AND SB1.B1_GRUPO IN ("+cFilGrPrd+")"
EndIf

//-- Prepara filtro por categoria de produto
For nX := 1 To oGrdCtPrd:GetQtdLine()
	oGrdCtPrd:GoLine(nX)
	If 	!Empty(oGrdCtPrd:GetValue("CODCAT"))
		cFilCtPrd += If(Empty(cFilCtPrd), "'" + Alltrim(oGrdCtPrd:GetValue("CODCAT")) + "'", ",'" + AllTrim(oGrdCtPrd:GetValue("CODCAT")) + "'")
		cFilCtPrd += A179ExpNiv(oGrdCtPrd:GetValue("CODCAT")) //Recursividade para ao selecionar o pai buscar todos os seus filhos e considerar no filtro.
	EndIf
Next nX

If !Empty(cFilCtPrd) 
	cFiltroSB1 += " AND ACV.ACV_CATEGO IN ("+cFilCtPrd+")"
EndIf

//-- Prepara filtro por fórmula
If !Empty(oMaster:GetValue("DBJ_FILSQL"))
	cFiltroSB1 += " AND (" + oMaster:GetValue("DBJ_FILSQL") + ")"
EndIf

If lExistMsBl // Considera bloqueados
	cFiltroSB1 += " AND SB1.B1_MSBLQL = '2' "
EndIf

//Considera os produtos importados
If !lPrdImport
	cFiltroSB1 += " AND SB1.B1_IMPORT <> 'S'"
EndIf

cFiltroSB1 += "%"

//-- Prepara filtro das filiais abastecidas
For nX := 1 To oGrdFilial:GetQtdLine()
	oGrdFilial:GoLine(nX)
	If !oGrdFilial:GetValue("DB5_OK")
		cFilAbast += If(Empty(cFilAbast), "'" + Alltrim(oGrdFilial:GetValue("DB5_FILABA")) + "'", ",'" + AllTrim(oGrdFilial:GetValue("DB5_FILABA")) + "'")
	EndIf
Next nX

If !Empty(cFilAbast)	
	cFiltroDB5 := "%DB5_FILABA NOT IN ("+cFilAbast+") AND%"
EndIf

//Ponto de entrada para manipulação dos filtros cFiltroSB1 e cFiltroDB5.
If ExistBlock("MT179FIL")
	aFiltro := ExecBlock("MT179FIL",.F.,.F.,{cFiltroSB1,cFiltroDB5})
	If ValType(aFiltro) == "A" .And. Len(aFiltro) > 1	
		cFiltroSB1 := aFiltro[1]
		cFiltroDB5 := aFiltro[2]
	EndIf
EndIf

//-- Executa query para obtenção das filiais abastecidas a processar
BeginSQL Alias "TMPDB5"
	SELECT DB5_FILDIS, DB5_FILABA, DB5_PRIORI
	FROM %Table:DB5%
	WHERE	%NotDel% AND DB5_FILIAL = %xFilial:DB5% AND
		%Exp:cFiltroDB5%
		DB5_FILDIS = %Exp:cDbj_FilDis%		
	ORDER BY DB5_PRIORI	
EndSQL

oModel181:Activate()	//-- Ativa modelo

//Popula modelo DBJ do MATA181
aAux := oModel:GetModel("CTMASTER"):GetStruct():GetFields()
For nY := 1 To Len(aAux)	
	oModel181:LoadValue("DBJMASTER",aAux[nY,3],oModel:GetValue("CTMASTER",aAux[nY,3]))	
Next nY

If TMPDB5->(!EOF())
	//-- Seta a quantidade de registros para ser utilizado na barra de processamento
	TMPDB5->(dbEval({|| nQtdeReg++}))
	oProcess:SetRegua1(nQtdeReg)
		
	TMPDB5->(dbGoTop())
	While !TMPDB5->(EOF())
		oProcess:IncRegua1(STR0050 + TMPDB5->DB5_FILABA + '...' ) //'Aguarde... Processando o cálculo da filial '//"Aguarde... Processando o cálculo da filial "
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Atualiza o log de processamento			    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		ProcLogAtu("MENSAGEM",STR0088 + TMPDB5->DB5_FILABA,STR0088 + TMPDB5->DB5_FILABA)  //"Processando o calculo da Filial: "

		//-- Se transferência, valida cadastro da filial abastecida como cliente na distribuidora
		If cDbj_TpSug == "2"
			cCodForCli := ""
			cLojForCli := ""
			cCondPagto := ""
			
			If !lUsaFilTrf //-- Valida pelo CNPJ
				nPos := SM0->(Recno())
				SM0->(dbSeek(cEmpAnt+TMPDB5->DB5_FILABA))
				SA1->(dbSetOrder(3))
				If SA1->(MsSeek(xFilial("SA1",TMPDB5->DB5_FILDIS)+SM0->M0_CGC)) 
					cCodForCli := SA1->A1_COD
					cLojForCli := SA1->A1_LOJA
					cCondPagto := SA1->A1_COND
				EndIf
				SM0->(MsGoTo(nPos))
			Else			//-- Valida pelo campo _FILTRF 
				BeginSQL Alias "SA1TMP"
					SELECT A1_COD, A1_LOJA, A1_COND
					FROM %Table:SA1% SA1
					WHERE SA1.%NotDel% AND SA1.A1_FILIAL = %Exp:xFilial("SA1",TMPDB5->DB5_FILDIS)% AND
						SA1.A1_FILTRF = %Exp:TMPDB5->DB5_FILABA%
				EndSQL
				If !SA1TMP->(EOF())
					cCodForCli := SA1TMP->A1_COD
					cLojForCli := SA1TMP->A1_LOJA
					cCondPagto := SA1TMP->A1_COND
				EndIf
				SA1TMP->(dbCloseArea())
			EndIf
			
			If Empty(cCodForCli) .And. TMPDB5->DB5_FILABA <> TMPDB5->DB5_FILDIS //-- Não validar quando distribuidora tb for abastecida.
				cLogErro += "A filial "+TMPDB5->DB5_FILABA+ " não está cadastrada como cliente na filial "+TMPDB5->DB5_FILDIS+" e isto impede o processo de transferência. Esta filial será desconsiderada no cálculo."+CRLF+CRLF
				TMPDB5->(dbSkip())
				Loop
			ElseIf Empty(cCondPagto) .And. TMPDB5->DB5_FILABA <> TMPDB5->DB5_FILDIS //-- Não validar quando distribuidora tb for abastecida.
				cLogErro += "A filial "+TMPDB5->DB5_FILDIS+" não tem condição de pagamento definida no cadastro de fornecedor ("+AllTrim(cCodForCli)+"/"+cLojForCli+") na filial "+TMPDB5->DB5_FILABA+" e isto impede o processo de transferência. Esta filial será desconsiderada no cálculo."+CRLF+CRLF
				TMPDB5->(dbSkip())
				Loop
			EndIf
		EndIf 
				
	    cJoin	:= ''
	    
	    If !Empty(cFilCtPrd)
			cJoin	:= "JOIN " +RetSQLName("ACV") +" ACV ON ACV.D_E_L_E_T_ <> '*' AND "
			cJoin	+= "ACV.ACV_FILIAL = '" +xFilial("ACV",TMPDB5->DB5_FILABA) +"' AND "
			cJoin	+= "ACV.ACV_CODPRO = SB1.B1_COD"
		EndIf
		
		cWhere:= ""

		If cDbj_Metodo == "1"
			cWhere+= "% EXISTS (SELECT 1 from " + RetSQLName("SD2") +" SD2, " + RetSQLName("SF4") +" SF4 "
			cWhere+= "WHERE SD2.D2_FILIAL  = '" + xFilial("SD2",TMPDB5->DB5_FILABA) +"' "
			cWhere+= "AND SD2.D2_COD = SB1.B1_COD "
			cWhere+= "AND SD2.D2_EMISSAO BETWEEN '" + DtoS(dDbj_DtDe) + "' AND '" + DtoS(dDbj_DtAte) + "' "
			cWhere+= "AND SD2.D2_ORIGLAN <> 'LF' "
			cWhere+= "AND SF4.F4_FILIAL  = '" + xFilial("SF4",TMPDB5->DB5_FILABA) +"' "
			cWhere+= "AND SF4.F4_CODIGO  = SD2.D2_TES "
			cWhere+= "AND SF4.F4_ESTOQUE = 'S' "
			cWhere+= "AND SF4.D_E_L_E_T_ = '' "
			cWhere+= "AND SD2.D_E_L_E_T_ = '' )%"
			//cWhere+= "% (SELECT ISNULL(SUM(SD2.D2_QUANT),0) FROM " + RetSQLName("SD2") +" SD2 where SD2.D2_FILIAL= '" + xFilial("SD2",TMPDB5->DB5_FILABA) +"' AND SD2.D2_COD = SB1.B1_COD AND SD2.D2_EMISSAO BETWEEN '" + DtoS(dDbj_DtDe) + "' AND '" + DtoS(dDbj_DtAte) + "' AND SD2.D_E_L_E_T_ = ' ' ) > 0%"
		ElseIf cDbj_Metodo == "2"
			cWhere+= "% EXISTS (SELECT 1 from " + RetSQLName("SC4") +" SC4 "
			cWhere+= "WHERE SC4.C4_FILIAL  = '" + xFilial("SC4",TMPDB5->DB5_FILABA) +"' "
			cWhere+= "AND SC4.C4_PRODUTO = SB1.B1_COD "
			cWhere+= "AND SC4.C4_DATA BETWEEN '" + DtoS(dDbj_DtDe) + "' AND '" + DtoS(dDbj_DtAte) + "' "
			cWhere+= "AND SC4.D_E_L_E_T_ = '')%"
			//cWhere+= "% (SELECT ISNULL(SUM(SC4.C4_QUANT),0) FROM " + RetSQLName("SC4") +" SC4 where SC4.C4_FILIAL= '" + xFilial("SC4",TMPDB5->DB5_FILABA) +"' AND SC4.C4_PRODUTO = SB1.B1_COD AND SC4.C4_DATA BETWEEN '" + DtoS(dDbj_DtDe) + "' AND '" + DtoS(dDbj_DtAte) + "' AND SC4.D_E_L_E_T_ = ' ' ) > 0%"
		Else
			cWhere+= "% EXISTS (SELECT 1 from " + RetSQLName("SBL") +" SBL "
			cWhere+= "WHERE SBL.BL_FILIAL  = '" + xFilial("SBL",TMPDB5->DB5_FILABA) +"' "
			cWhere+= "AND SBL.BL_PRODUTO = SB1.B1_COD "
			cWhere+= "AND SBL.D_E_L_E_T_ = '')%"
			//cWhere+= "% (SELECT ISNULL(SUM(SBL.BL_DEMANDA),0) FROM " + RetSQLName("SBL") +" SBL where SBL.BL_FILIAL= '" + xFilial("SBL",TMPDB5->DB5_FILABA) +"' AND SBL.BL_PRODUTO = SB1.B1_COD AND SBL.D_E_L_E_T_ = ' ') > 0%"
		EndIf
		
		cJoin	+= " JOIN " + RetSQLName("SB2") +" SB2 ON "
		cJoin	+= "SB2.B2_FILIAL = '" + xFilial("SB2",TMPDB5->DB5_FILABA) +"' AND "
		cJoin	+= "SB2.B2_COD = SB1.B1_COD AND SB2.D_E_L_E_T_ = '' " 
		
		If lUtilizaMix
			If !Empty(cFilMxPrd) .And. !(lFilMxPrd)
				cJoinMFU	:= "%JOIN " + RetSQLName("MFU") +" MFU ON MFU.D_E_L_E_T_ <> '*' AND "
				cJoinMFU	+= "MFU.MFU_FILIAL = '" + xFilial("MFU",TMPDB5->DB5_FILABA) +"' AND "
				cJoinMFU	+= "MFU.MFU_CODIGO = SB1.B1_COD%"
			EndIf
		EndIf	
			
		//Caso o produto seja fabricado na própria empresa e o parametro MV_CCFABRI esteja ativo filtra o produto
		If lFabri		
			cFiltFabri := "% NOT  EXISTS(SELECT SG1.G1_COD FROM "+ RetSQLName("SG1") +" SG1 WHERE SG1.G1_COD  = SB1.B1_COD AND SG1.G1_FILIAL = '"+ xFilial("SG1",TMPDB5->DB5_FILABA) +"' AND SG1.D_E_L_E_T_ <> '*' ) AND %"
		EndIf
		
		cJoin	:= "%" + cJoin + "%"
		
		//Verifica se o parametro MV_RESTCOM está ativo, caso esteja filtra apenas os produtos que o comprador tem autorização para solicitar
		If cRestCom == 'S'			
			//Função que busca se o usuário pertence a algum grupo de compras
			aGrupos := UsrGrComp(RetCodUsr())
			cNewGrp := "%''"			
			For nX := 1 to Len(aGrupos)
				If nX == 1
					cNewGrp := "%'"+aGrupos[nX]+"'"
				Else
					cNewGrp += " OR SAJ.AJ_GRCOM = '"+aGrupos[nX] +"'"
				EndIf
			Next nX
			cNewGrp += "%"
			//Busca se na tabela de solicitantes o comprador tem autorização para todos os produtos (*)
			BeginSql Alias "SAIALL"
				SELECT COUNT (*) ASTERISCO
				  FROM 
   				       %Table:SAI% SAI
			      JOIN 
				       %Table:SAJ% SAJ ON SAI.AI_GRUPCOM = SAJ.AJ_GRCOM
        		 WHERE SAI.AI_GRUSER = '*'
				    OR SAI.AI_GRUPO = '*'  
				   AND ( SAJ.AJ_GRCOM = %Exp:cNewGrp% )
				   AND SAI.AI_FILIAL = %Exp:xFilial("SAI",TMPDB5->DB5_FILABA)%
				   AND SAJ.AJ_FILIAL = %Exp:xFilial("SAJ",TMPDB5->DB5_FILABA)%
				   AND SAI.%NotDel%
				   AND SAJ.%NotDel%			
			EndSQL					
			nNumAst := SAIALL->ASTERISCO
			SAIALL->(dbCloseArea())

			//Caso encontre algum resultado traz todos os produtos
			If nNumAst > 0				
         	    //-- Executa query para obtenção dos produtos a processar
       			BeginSql Alias "TMPSB1"
					SELECT DISTINCT SB1.B1_COD PRODUTO,
			    		   SB1.B1_UPRC,
					       SB1.B1_PROC,
					       SB1.B1_LOJPROC,
			    		   SB1.B1_LOCPAD,
					       SB1.B1_CUSTD,
						   SB1.B1_MCUSTD,
					       SB1.B1_UCALSTD
					 FROM %Table:SB1% SB1
			    		  %Exp:cJoin%
					WHERE %Exp:cFiltFabri% 
						   SB1.%NotDel% AND 
				          SB1.B1_FILIAL = %Exp:xFilial("SB1",TMPDB5->DB5_FILABA)% AND
						   SB1.%NotDel%
				          %Exp:cFiltroSB1% AND 
				          %Exp:cWhere%
				EndSql
	
			// se nao encontrar traz apenas os produtos que o comprador tem autorizacao
			Else				

				BeginSql Alias "TMPSB1"
					SELECT SB1.B1_COD PRODUTO,
					       SB1.B1_UPRC,
					       SB1.B1_PROC,
					       SB1.B1_LOJPROC,
					       SB1.B1_LOCPAD,
						   SB1.B1_CUSTD,
						   SB1.B1_MCUSTD,
						   SB1.B1_UCALSTD
					  FROM 
						   %Table:SB1% SB1
					  JOIN 
						   %Table:SAI% SAI ON SB1.B1_COD = SAI.AI_PRODUTO AND SAI.AI_FILIAL = %Exp:xFilial("SAI",TMPDB5->DB5_FILABA)% 
					  JOIN 
						   %Table:SAJ% SAJ ON SAI.AI_GRUPCOM = SAJ.AJ_GRCOM AND SAJ.AJ_FILIAL = %Exp:xFilial("SAJ",TMPDB5->DB5_FILABA)%
				     WHERE 
							SAJ.AJ_GRCOM = %Exp:cNewGrp% AND
							SB1.B1_FILIAL = %Exp:xFilial("SB1",TMPDB5->DB5_FILABA)% AND
							SB1.%NotDel% AND						
							SAI.%NotDel% AND
							SAJ.%NotDel% 
							%Exp:cFiltroSB1% AND
							%Exp:cWhere%
					UNION
	
					SELECT SB1.B1_COD PRODUTO,
					       SB1.B1_UPRC,
					       SB1.B1_PROC,
					       SB1.B1_LOJPROC,
					       SB1.B1_LOCPAD,
						   SB1.B1_CUSTD,
						   SB1.B1_MCUSTD,
						   SB1.B1_UCALSTD
					FROM 
						%Table:SB1% SB1
					JOIN
						%Table:SBM% SBM ON SB1.B1_GRUPO   = SBM.BM_GRUPO AND SBM.BM_FILIAL = %Exp:xFilial("SBM",TMPDB5->DB5_FILABA)%
					JOIN 
						%Table:SAI% SAI ON SBM.BM_GRUPO   = SAI.AI_GRUPO AND SAI.AI_FILIAL = %Exp:xFilial("SAI",TMPDB5->DB5_FILABA)%
					JOIN 
						%Table:SAJ% SAJ ON SAI.AI_GRUPCOM = SAJ.AJ_GRCOM AND SAJ.AJ_FILIAL = %Exp:xFilial("SAJ",TMPDB5->DB5_FILABA)%
					WHERE 
						SAJ.AJ_GRCOM  = %Exp:cNewGrp% AND
						SB1.B1_FILIAL = %Exp:xFilial("SB1",TMPDB5->DB5_FILABA)% AND
						SB1.%NotDel% AND
						SBM.%NotDel% AND
						SAI.%NotDel% AND
						SAJ.%NotDel% 
						%Exp:cFiltroSB1% AND
						%Exp:cWhere%
				EndSql

			EndIf

		Else

			//-- Executa query para obtencao dos produtos a processar
			BeginSql Alias "TMPSB1"
				SELECT DISTINCT SB1.B1_FILIAL,SB1.B1_COD PRODUTO, SB1.B1_UPRC, SB1.B1_PROC, SB1.B1_LOJPROC, SB1.B1_LOCPAD,
					   SB1.B1_CUSTD, SB1.B1_MCUSTD, SB1.B1_UCALSTD
				FROM %Table:SB1% SB1
				%Exp:cJoin% 
				WHERE %Exp:cFiltFabri%
					  SB1.%NotDel%
					  AND SB1.B1_FILIAL = %Exp:xFilial("SB1",TMPDB5->DB5_FILABA)% AND
					  SB1.%NotDel%
					  %Exp:cFiltroSB1% AND
					  %Exp:cWhere%
				GROUP BY SB1.B1_FILIAL,SB1.B1_COD,SB1.B1_UPRC,SB1.B1_PROC,SB1.B1_LOJPROC,SB1.B1_LOCPAD,SB1.B1_CUSTD,SB1.B1_MCUSTD,SB1.B1_UCALSTD 
			EndSql

		EndIf		
		
		oModelDBI:SetNoDeleteLine(.F.) //-- Se a filial não tiver produtos, sera exibida com tal grid vazia
		oModelDBI:SetMaxLine(99999)		//-- Limite de linhas do aCols

		If !Empty(oModelDBH:GetValue("DBH_FILABA")) //-- Tratamento para a primeira linha
			oModelDBH:AddLine(.T.)
		EndIf
		oModelDBH:LoadValue("DBH_FILIAL",xFilial("DBH"))				
		oModelDBH:LoadValue("DBH_SUGEST",cDbj_Sugest)
		oModelDBH:LoadValue("DBH_FILDIS",cDbj_FilDis)		
		oModelDBH:LoadValue("DBH_FILABA",TMPDB5->DB5_FILABA)
		oModelDBH:LoadValue("DBH_PRIORI",TMPDB5->DB5_PRIORI)
 	 
		//-- Verifica se os produtos serão comprados na filial distribuidora ou abastecida para poder pesquisar fornecedores	
		cFilPrcFor := IIf(cDbj_TpSug == "2" .Or. cDbj_Compra == "1",TMPDB5->DB5_FILDIS,TMPDB5->DB5_FILABA)
		cFilialDBI	:= xFilial("DBI")
		cFilialSA2	:= xFilial("SA2",cFilPrcFor)
		cFilialSA5	:= xFilial("SA5",cFilPrcFor)
		cFilialSB1	:= xFilial("SB1",cFilPrcFor)
		cFilialSB2	:= xFilial("SB2",cFilPrcFor)

	    //-- Calcula a quantidade de Threads
	   	aQuebraThr := MT179QtdThr("TMPSB1")
       	aThreads   := aQuebraThr[1]
       	aProdutos  := aQuebraThr[2]
       	aJobAux    := {}
        
		// Execucao do processamento por Threds
		For nX :=1 to Len(aThreads)

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Atualiza o log de processamento			    ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			ProcLogAtu("MENSAGEM",STR0089 + StrZero(nX,2),STR0089 + StrZero(nX,2)) //"Iniciando calculo de Produtos | Thread: "
			// Informacoes do semaforo
			cJobFile:= cStartPath + CriaTrab(Nil,.F.)+".job"
			
			// Cria arquivo de trabalho
			cTabelaTMP := GetNextAlias()
			oTmpTable := FWTemporaryTable():New( cTabelaTMP )
			oTmpTable:SetFields(aStruDBI)
			oTmpTable:Create()	

			// Adiciona o nome do arquivo de Job no array aJobAux
			aAdd(aJobAux,{StrZero(nX,2),cJobFile,cTabelaTMP})
	
			// Inicializa variavel global de controle de thread
			cJobAux:="cGlb"+cEmpAnt+cFilAnt+StrZero(nX,2)
			PutGlbValue(cJobAux,"0")
			GlbUnLock()

			// Parametros utilizados para executar as threads (NAO ALTERAR A ORDEM)
			aParametros := {	cFilAnt	  	,;						// 01. 
								cEmpAnt   	,;						// 02.
								cDbj_TpSug	,;						// 03.
								cCondPagto	,;						// 04.
								cCodForCli	,;						// 05.
								cLojForCli	,;						// 06.
								nPrecoProd 	,;						// 07.
								cFilialSB1  ,;						// 08.
								cFilialSA5  ,;						// 09.
								cDbj_DocCom ,;						// 10.
								cFilPrcFor  ,;						// 11.
								cFilAntBkp  ,; 						// 12.
								cFilialSB2  ,; 						// 13.
								cDbj_FilDis ,;						// 14.
								TMPDB5->DB5_FILABA ,; 				// 15.
								DBJ->(FieldPos("DBJ_ESTSEG")) > 0 .And. oMaster:GetValue("DBJ_ESTSEG") ,;	//16.
								oMaster:GetValue("DBJ_CONEST")	,;	//17.
								oMaster:GetValue("DBJ_RESERV")	,;	//18.
								oMaster:GetValue("DBJ_EMPENH")	,;	//19.
								oMaster:GetValue("DBJ_PRVENT")	,;	//20.
								oMaster:GetValue("DBJ_PDCART")	,;	//21.
								oMaster:GetValue("DBJ_SLDTRA")	,;	//22.
								ExistBlock("A179ARMZ")			,;	//23.
								oMaster:GetValue("DBJ_METODO")	,;	//24.
								oMaster:GetValue("DBJ_DTDE")	,;	//25.
								oMaster:GetValue("DBJ_DTATE")	,;	//26.
								oMaster:GetValue("DBJ_DEVVEN")	,;	//27.
								oMaster:GetValue("DBJ_INCREM")	,;	//28.
								oMaster:GetValue("DBJ_DIASCO")	,;	//29.
								TMPDB5->DB5_FILDIS 				,;	//30.
								cFilialSA2						,;	//31.
								oTmpTable:GetRealName() 		,;	//32.
								cFilialDBI						,; 	//33.
								dDatabase						,;	//34.
								oMaster:GetValue("DBJ_LTEEMB")} //35.
																
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Dispara thread para Stored Procedure        ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ                          
			StartJob("MT179JOB",GetEnvServer(),.F.,aParametros,aThreads[nX],aProdutos,cJobFile,StrZero(nX,2))
        Next nX

		nThreads := Len(aThreads)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Controle de Seguranca para MULTI-THREAD                                   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		Do While .T.
	        oProcess:SetRegua2(Len(aThreads))
			For nX :=1 to Len(aThreads)
	
				oProcess:IncRegua2(STR0087 + StrZero(nX,2)) //"Calculo de produtos | Job numero -> "
	
				nPos := ASCAN(aJobAux,{|x| x[1] == StrZero(nX,2)})
					
				// Tabela Temporaria
				cTabelaTMP:= aJobAux[nPos,3]
				
				// Informacoes do semaforo
				cJobFile:= aJobAux[nPos,2]
	
	   			// Inicializa variavel global de controle de thread
				cJobAux:="cGlb"+cEmpAnt+cFilAnt+StrZero(nX,2)
	    	
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Analise das Threads em Execucao                              ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				Do Case
					// TRATAMENTO PARA ERRO DE SUBIDA DE THREAD
					Case GetGlbValue(cJobAux) == '0'
                        If nRetry_0 > 50
							Conout(Replicate("-",65))				//"-----------------------------------------------------"
							Conout(STR0079 + " " + StrZero(nX,3) )	//"MATA179: Não foi possivel realizar a subida da thread"
							Conout(Replicate("-",65))  				//"-----------------------------------------------------"
							Final(STR0080) 							//"Não foi possivel realizar a subida da thread"
                        Else
                        	nRetry_0 ++
                        EndIf
					// TRATAMENTO PARA ERRO DE CONEXAO
					Case GetGlbValue(cJobAux) == '1'
						If FCreate(cJobFile) # -1
							If nRetry_1 > 5
								Conout(Replicate("-",65))  			//"------------------------------------------------"
								Conout(STR0081) 					//"MATA179: Erro de conexao na thread"
								Conout(STR0082 + cJobAux )			//"Thread numero : "
								Conout(STR0083)						//"Numero de tentativas excedidas"
								Conout(Replicate("-",65))  			//"------------------------------------------------"
								//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
								//³ Atualiza o log de processamento			    ³
								//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
								ProcLogAtu("MENSAGEM",STR0090 + StrZero(nX,2),STR0090 + StrZero(nX,2)) //"Erro de conexao | Thread: "
								Final(STR0081)	//"MATA179: Erro de conexao na thread"
							EndIf
							nRetry_1 ++ 
						EndIf
					// TRATAMENTO PARA ERRO DE APLICACAO
					Case GetGlbValue(cJobAux) == '2'
						If FCreate(cJobFile) # -1
							Conout(Replicate("-",65))				//"-------------------------------------------------"	
							Conout(STR0085)							//"MATA179: Erro de aplicacao na thread (Verifique error.log)"
							Conout(STR0082+cJobAux)					//"Thread numero : "
							Conout(Replicate("-",65))  				//"--------------------------------------------------"	
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³ Atualiza o log de processamento			    ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							ProcLogAtu("MENSAGEM",STR0091 + StrZero(nX,2),STR0091 + StrZero(nX,2)) //"Erro de aplicacao na Thread (Verifique error.log) | Thread: "
							Final(STR0085)	//"MATA179: Erro de aplicacao na thread (Verifique error.log)"
						EndIf
					// THREAD PROCESSADA CORRETAMENTE
					Case GetGlbValue(cJobAux) == '3'
						If File(cJobFile)
							nHdl := FOpen( cJobFile, FO_READ )
							If nHdl > -1
								fRead(nHdl,@cLogErro,1024)
								FClose(nHdl)
								fErase(cJobFile)
							EndIf	
						EndIf	
						// Limpa variavel global de controle de thread
						ClearGlbValue(cJobAux)
    					// Processa a informacao para o MVC
						lProcessa := MT179AddLine(cTabelaTMP,cFilialDBI,cDbj_Sugest,TMPDB5->DB5_FILABA,cDbj_DocCom,cDbj_Compra,cDbj_Entreg,TMPDB5->DB5_FILDIS,oProcess,@oModelDBI,cDbj_TpSug,@aSaldoSB1)
						// Se processar pelo menos um registros deve retornar lRet := .T.
						If lProcessa
							lRet := lProcessa
						EndIf						

						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Atualiza o log de processamento			    ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						ProcLogAtu("MENSAGEM",STR0092 + StrZero(nX,2),STR0092 + StrZero(nX,2)) //"Termino do calculo de Produtos | Thread: "
						nThreads--
				EndCase
				Sleep(2500)
			Next nX
        	// Encerrar monitor de seguranca
			If nThreads <= 0
				Exit
			EndIf
		End    
	
		TMPSB1->(dbCloseArea())
	
		//-- Caso nao tenha adicionado produtos para esta filial, remove linha de produto vazio
		If oModelDBI:GetQtdLine() >= 1 
			For nX := 1 To oModelDBI:GetQtdLine()
				oModelDBI:GoLine(nX)
				If Empty(oModelDBI:GetValue("DBI_PRODUT")) .AND. !oModelDBI:IsDeleted() 
					oModelDBI:DeleteLine()				
				EndIF
			Next nX					 
		EndIf											

		TMPDB5->(dbSkip())
	End

	If lRet
		//-- Realiza gravação do campo de quantidade a distribuir 
		For nX:= 1 To oModelDBH:GetQtdLine()
			oModelDBH:GoLine(nX)
			For nY:= 1 To oModelDBI:GetQtdLine()
				oModelDBI:GoLine(nY)
				If !oModelDBI:IsDeleted()
					If cDbj_TpSug == "1"
						nTot := nTot + (oModelDBI:GetValue("DBI_PRECO")*oModelDBI:GetValue("DBI_QTDCOM"))
					EndIf
				EndIf
			Next nY
			If cDbj_TpSug == "1"
				oModelDBH:LoadValue("DBH_VALTOT",nTot)
			EndIf
			oModelDBI:GoLine( 1 )
			nTot:= 0
		Next nX
	Else
		Help('',1,'MTA179PRD') //-- Não foram encontrados produtos para as filiais abastecidas conforme os parâmetros do filtro, REGRAS DE ALÇADA NECEOU SSIDADE DE ABASTECimento.
		lRet := .F.
	EndIf
	
	If !Empty(cLogErro)
		MostErCCom(cLogErro)
	EndIf

EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Atualiza o log de processamento   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ProcLogAtu("FIM")

//-- Encerra a tabela temporaria
TMPDB5->(dbCloseArea())

If Type("oTmpTable") == "O"
	oTmpTable:Delete()
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} A179SldFil()
Busca o saldo das filiais distribuidora e abastecedora.
@author Rodrigo Toledo
@since 16/02/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Function A179SldFil(cFilDisAba,cProduto,lFilDist,lDbj_EstSeg,lDbj_ConEst,lDbj_Reserv,lDbj_Empenh,lDbj_PrvEnt,lDbj_PdcArt,lDbj_SldTra,lA179ARMZ)
Local aAreaAnt      := GetArea()
Local aAreaSB1      := SB1->(GetArea())
Local aAreaSB2		:= SB2->(GetArea())
Local nSaldoFil		:= 0
Local nEstSeg		:= 0
Local nX			:= 0
Local aDescArm		:= {}
Local cCodArmaz		:= ""
Local cFiltroSB2	:= "%"
Local cFilialSB2	:= xFilial("SB2",cFilDisAba)
Local cFilialSD1	:= xFilial("SD1",cFilDisAba)
Local cFilialSD2	:= xFilial("SD2",cFilDisAba)
Local cFilialSF4	:= xFilial("SF4")
Local cMVLocTran	:= SuperGetMV("MV_LOCTRAN",.F.,"95")

Default lDbj_EstSeg	:= .F.
Default lDbj_ConEst	:= .F.
Default lDbj_Reserv	:= .F.
Default lDbj_Empenh	:= .F.
Default lDbj_PrvEnt	:= .F.
Default lDbj_PdcArt	:= .F.
Default lDbj_SldTra	:= .F.
Default lA179ARMZ	:= .F.

// ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿ 	 
// |  Ponto de entrada utilizado para buscar os armazens que serao desconsiderados para a disponibilizacao do saldo |	
// ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
If lA179ARMZ
	aDescArm := ExecBlock("A179ARMZ",.F.,.F.,{cFilialSB2,cProduto})
	If ValType(aDescArm) == "A"
		For nX:=1 to Len(aDescArm)
			cCodArmaz += If(Empty(cCodArmaz), "'" + Alltrim(aDescArm[nX]) + "'", ",'" + AllTrim(aDescArm[nX]) + "'")
		Next nX
	EndIf
	If !Empty(cCodArmaz)
		cFiltroSB2 := "%"
		cFiltroSB2 += " AND SB2.B2_LOCAL NOT IN ("+cCodArmaz+")"
		cFiltroSB2 += "%"		
	EndIf
EndIf

/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³ EXECUTA A QUERY NA TABELA SB2 PARA FAZER A COMPOSICAO DO SALDO NA FILIAL ABASTECEDORA³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
BeginSQL Alias "TMPSB2"
	SELECT SB2.B2_COD, SUM(B2_QATU) 	AS SLDESTOQ,;
			SUM(B2_RESERVA) 			AS SLDRES,;
			SUM(B2_QEMP+B2_QEMPSA) 		AS SLDEMP,;
			SUM(B2_SALPEDI) 			AS SLDENT,;
			SUM(B2_QPEDVEN) 			AS SLDVEN
	FROM %Table:SB2% SB2
	WHERE	SB2.B2_FILIAL = %Exp:cFilialSB2% AND
			SB2.B2_COD    = %Exp:cProduto% AND
			SB2.B2_LOCAL  <> %Exp:cMVLocTran% AND
			SB2.B2_STATUS <> '2' AND
		  	SB2.%NotDel%
		  	%Exp:cFiltroSB2%		
	GROUP BY SB2.B2_COD	  	
EndSQL		
While !TMPSB2->(Eof())
	If lDbj_ConEst
		nSaldoFil += TMPSB2->SLDESTOQ
	EndIf
	If lDbj_Reserv
		nSaldoFil -= TMPSB2->SLDRES
	EndIf
	If lDbj_Empenh
		nSaldoFil -= TMPSB2->SLDEMP
	EndIf
	If lDbj_PrvEnt
		nSaldoFil += TMPSB2->SLDENT
	EndIf
	If lDbj_PdcArt
		nSaldoFil -= TMPSB2->SLDVEN
	EndIf
	If lDbj_EstSeg
		nEstSeg	:= A179Prod(cFilDisAba,TMPSB2->B2_COD)
		nSaldoFil -= nEstSeg						
	EndIf
	TMPSB2->(dbSkip())
End
TMPSB2->(dbCloseArea())

If lDbj_SldTra
	/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	  ³ EXECUTA AS QUERYS PARA BUSCAR O SALDO EM TRANSITO ATRAVES DO MV_LOCTRAN ³
	  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	BeginSQL Alias "TMPTRANS"
		SELECT SUM(SB2.B2_QATU) AS SLDTRANS
		FROM	%Table:SB2% SB2
		WHERE	SB2.B2_COD    = %Exp:cProduto% AND
				SB2.B2_FILIAL = %Exp:cFilialSB2% AND
				SB2.B2_LOCAL  = %Exp:cMVLocTran% AND 
				SB2.B2_STATUS <> '2' AND 
				SB2.%NotDel%
	EndSql
	If !TMPTRANS->(EOF())
		nSaldoFil += TMPTRANS->SLDTRANS
	EndIf
	TMPTRANS->(dbCloseArea())

	/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	  ³ Executa a query para buscar o saldo dos produtos que ainda nao foram classificados ³
	  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	BeginSQL Alias "TMPTRANS"	
		SELECT SUM(SD2.D2_QUANT) TRANSITO
		FROM %Table:SD2% SD2 
		JOIN %Table:SF4% SF4 ON  SF4.F4_CODIGO = SD2.D2_TES
		JOIN %Table:SD1% SD1 ON  SD1.D1_FILIAL =  %Exp:cFilialSD1% AND 
		                         SD1.D1_TES    = '   ' AND 
		                         SD1.D1_DOC    = SD2.D2_DOC AND
		                         SD1.D1_SERIE  = SD2.D2_SERIE AND
		                         SD1.D1_COD    = SD2.D2_COD
		WHERE 	SD2.D2_FILIAL  <> %Exp:cFilialSD2% AND
		      	SD2.D2_COD     =  %Exp:cProduto%   AND 
				SF4.F4_FILIAL  =  %Exp:cFilialSF4% AND
		        SF4.F4_ESTOQUE = 'S'   AND
		        SF4.F4_TRANFIL = '1'   AND
				SF4.%NotDel% AND
				SD1.%NotDel% AND
				SD2.%NotDel% 
	EndSql

	If !TMPTRANS->(Eof())
		nSaldoFil += TMPTRANS->TRANSITO
	EndIf
	TMPTRANS->(dbCloseArea())
	
EndIf

RestArea(aAreaSB2)
RestArea(aAreaSB1)
RestArea(aAreaAnt)
Return nSaldoFil

//-------------------------------------------------------------------
/*/{Protheus.doc} A179PrCons()
Busca o saldo de consumo dos produtos da filial abastecedora.
@author Rodrigo Toledo
@since 16/02/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function A179PrCons(cFilAba,cProduto,cDbj_Metodo,dDbj_DtDe,dDbj_DtAte,lDbj_DevVen,nDbj_Increm,nDbj_DiasCo,cFornece,cLoja,lDbj_EstSeg,lDbj_LtEEmb) 
Local nSldConsumo	:= 0
Local nPrazo		:= 0
Local nRetConsum	:= 0
Local cAnoMes	  	:= ""
Local cFilAntBkp  	:= cFilAnt
Local aAreaAnt    	:= GetArea()
Local aAreaSB1    	:= SB1->(GetArea())
Local cFilialSC4  	:= xFilial("SC4",cFilAba)
Local cFilialSD1  	:= xFilial("SD1",cFilAba)
Local cFilialSD2  	:= xFilial("SD2",cFilAba)
Local cFilialSF4  	:= xFilial("SF4",cFilAba)
Local lMt179Cons  	:= ExistBlock("MT179CONS")
Local lArrSldC	  	:= SuperGetMV("MV_ARRSLDC",.F.,.F.)

Default cDbj_Metodo	:= ""
Default dDbj_DtDe	:= CTOD(" / / ")
Default dDbj_DtAte	:= CTOD(" / / ")
Default lDbj_DevVen	:= .F.
Default nDbj_Increm	:= 0
Default nDbj_DiasCo	:= 0
Default cFornece	:= ""
Default cLoja		:= ""
Default lDbj_EstSeg := .F. 
Default lDbj_LtEEmb := .F. 

/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³ EXECUTA AS QUERYS PARA BUSCAR O SALDO DA PREVISAO DE CONSUMO ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
Do Case
	Case cDbj_Metodo == "1"
		/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		  ³ EXECUTA A QUERY PARA BUSCAR A MEDIA DE VENDAS ³    
		  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
		BeginSQL Alias "TMPCONS"
			SELECT SUM(SD2.D2_QUANT) AS QtdeVendas
			FROM %Table:SD2% SD2,%Table:SF4% SF4
			WHERE	SD2.D2_FILIAL = %Exp:cFilialSD2% AND
					SD2.D2_COD    = %Exp:cProduto% AND
					SD2.D2_TIPO   = 'N' AND
					SD2.D2_EMISSAO BETWEEN %Exp:dDbj_DtDe% AND %Exp:dDbj_DtAte% AND
					SD2.%NotDel% AND
					SF4.F4_FILIAL  = %Exp:cFilialSF4% AND 
					SF4.F4_CODIGO  = SD2.D2_TES AND
					SF4.F4_ESTOQUE = 'S' AND
					SF4.F4_PODER3 <> 'R' AND
					SF4.%NotDel%
		EndSQL
		If !TMPCONS->(Eof())
			/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			  ³ EXECUTA A QUERY PARA BUSCAR AS DEVOLUCOES OCORRIDAS ³
			  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
			If lDbj_DevVen
				BeginSql Alias "TMPDEV"
					SELECT SUM(D1_QUANT) AS QtdeDev
					FROM %table:SD1% SD1,%table:SF4% SF4
					WHERE	SD1.D1_FILIAL = %Exp:cFilialSD1% AND 
							SD1.D1_TIPO   = 'D' AND
							SD1.D1_COD    = %Exp:cProduto% AND
							SD1.D1_DTDIGIT BETWEEN %Exp:dDbj_DtDe% AND %Exp:dDbj_DtAte% AND
							SD1.%NotDel% AND
							SF4.F4_FILIAL = %Exp:cFilialSF4% AND
							SF4.F4_CODIGO = SD1.D1_TES AND
							SF4.F4_ESTOQUE = 'S' AND
							SF4.F4_PODER3 <> 'R' AND
							SF4.%NotDel%
				EndSql
				If !TMPDEV->(Eof())
					nSldConsumo := (TMPCONS->QtdeVendas - TMPDEV->QtdeDev)
				Else
					nSldConsumo := TMPCONS->QtdeVendas
				EndIf
				TMPDEV->(dbCloseArea())
			Else
				nSldConsumo := TMPCONS->QtdeVendas
			EndIf

			/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			  ³ EXECUTA A QUERY PARA BUSCAR AS TRANSFERENCIAS EFETUADAS ³
			  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
			BeginSql Alias "TMPTRANSF"
				SELECT SD2.D2_PEDIDO, SUM(SD2.D2_QUANT) AS QtdTransf
				FROM %Table:SD2% SD2,%Table:SF4% SF4,%Table:CPM% CPM
				WHERE	SD2.D2_FILIAL = %Exp:cFilialSD2% AND
						SD2.D2_COD    = %Exp:cProduto% AND
						SD2.D2_TIPO   = 'N' AND
						SD2.D2_EMISSAO BETWEEN %Exp:dDbj_DtDe% AND %Exp:dDbj_DtAte% AND
						SD2.%NotDel% AND
						SF4.F4_FILIAL  = %Exp:cFilialSF4% AND 
						SF4.F4_CODIGO  = SD2.D2_TES AND
						SF4.F4_ESTOQUE = 'S' AND
						SF4.F4_PODER3 <> 'R' AND
						SF4.%NotDel% AND
						CPM.CPM_NUMDOC = SD2.D2_PEDIDO AND
						CPM.CPM_PRODUT = SD2.D2_COD AND
						CPM.CPM_TIPO = '4' AND
						CPM.CPM_FILABA <> SD2.D2_FILIAL AND
						CPM.%NotDel%
				GROUP BY SD2.D2_PEDIDO
			EndSql
			If !TMPTRANSF->(Eof())
				nSldConsumo := (nSldConsumo - TMPTRANSF->QtdTransf)
			EndIf
			TMPTRANSF->(dbCloseArea())

			nSldConsumo := nSldConsumo / Max(1,(dDbj_DtAte-dDbj_DtDe+1))
		EndIF
		TMPCONS->(dbCloseArea())
		/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		  ³ INCREMENTANDO O PERCENTUAL INFORMADO NA MEDIA DE VENDAS OBTIDA ³
		  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
		nPrazo:= CalcPrazo(cProduto,nSldConsumo,cFornece,cLoja,.T.,dDataBase)
		If Empty(nDbj_Increm) .Or. nDbj_Increm = 0
			nSldConsumo := (nSldConsumo * (nDbj_DiasCo+nPrazo))
		Else 
			nSldConsumo := ((1+(nDbj_Increm/100)) * nSldConsumo) * (nDbj_DiasCo+nPrazo)
		EndIf
	Case cDbj_Metodo == "2"
		/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		  ³ EXECUTA A QUERY PARA BUSCAR AS PREVISOES DE VENDA ³
		  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
		BeginSQL Alias "TMPSC4"
			SELECT SUM(C4_QUANT) AS QtdeVendas
			FROM %Table:SC4% SC4
			WHERE	SC4.C4_FILIAL  = %Exp:cFilialSC4% AND
		   			SC4.C4_PRODUTO = %Exp:cProduto% AND
					SC4.C4_DATA BETWEEN %Exp:dDbj_DtDe% AND %Exp:dDbj_DtAte% AND
					SC4.%NotDel%
		EndSQL
		If !TMPSC4->(Eof())
			nSldConsumo := TMPSC4->QtdeVendas
		EndIf
		TMPSC4->(dbCloseArea())
	Case cDbj_Metodo == "3"
		IF Month(dDataBase)==1
			cAnoMes := StrZero(Year(dDataBase)-1,4)+"12"
		Else
			cAnoMes := StrZero(Year(dDataBase),4)+StrZero(Month(dDataBase)-1,2)
		EndIF
		A179AltFil(cFilAba)
		SB1->(dbSetOrder(1))
		SBL->(dbSetOrder(2))
		SB1->(MsSeek(xFilial("SB1")+cProduto))
		SBL->(MsSeek(xFilial("SBL")+cAnoMes+cProduto))
		nSldConsumo := Max(0,A297CalDem(cAnoMes,cProduto,nDbj_DiasCo))
		A179AltFil(cFilAntBkp)			
EndCase

// Ponto de entrada para recalcular a previsao de consumo para o produto na filial a abastecer
If lMt179Cons
	nRetConsum := ExecBlock("MT179CONS",.F.,.F.,{cProduto,nSldConsumo,cFilAba,cDbj_Metodo,dDbj_DtDe,dDbj_DtAte,lDbj_DevVen,nDbj_Increm,nDbj_DiasCo,cFornece,cLoja})
	If ValType(nRetConsum) == "N"
		nSldConsumo := nRetConsum
	EndIf
EndIf

//Arredonda o saldo de consumo
If lArrSldC .And. nSldConsumo > 0 .And. !lDbj_EstSeg .And. !lDbj_LtEEmb
	nSldConsumo := Round(nSldConsumo,0)
EndIf

RestArea(aAreaSB1)
RestArea(aAreaAnt)
Return nSldConsumo

//-------------------------------------------------------------------
/*/{Protheus.doc} A179AltFil()
Altera o codigo cFilAnt para buscar o codigo da filial distribuidora ou abastecida.
@author Rodrigo Toledo
@since 27/02/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Function A179AltFil(cFilTabPrc)
Local aAreaSM0 := SM0->(GetArea())

//-- Troca filial para buscar a tabela de preco
SM0->(dbSetOrder(1))
If SM0->(MsSeek(cEmpAnt+cFilTabPrc))
	cFilAnt := cFilTabPrc
EndIf

RestArea(aAreaSM0)
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} A179VldDat()
Valida se a data final informada e menor que a data inicial
@author Leonardo Quintania
@since 27/02/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Function A179VldDat()
Local lRet := .T.

If FwFldGet("DBJ_DTATE") < FwFldGet("DBJ_DTDE")
      Help(" ",1,"DATA2INVAL")//"A Data de Fim não pode ser menor do que a Data de Inicio.
      lRet := .F.
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} MostErCCom()
Mostra erros durante o processamento do calculo
@author Rodrigo Toledo
@since 04/03/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Function MostErCCom(cLog)
Local oDlg
Local cMemo	   := cLog
Local cFile    :=""
Local cMask    := "Arquivos Texto (*.TXT) |*.txt|"
Local oFont 

DEFINE FONT oFont NAME "Courier New" SIZE 6,15   //6,15

DEFINE MSDIALOG oDlg TITLE STR0064 From 3,0 to 340,550 PIXEL //"Itens com Ocorrências"
@ 5,5 GET oMemo  VAR cMemo MEMO SIZE 267,145 OF oDlg PIXEL 
oMemo:bRClicked := {||AllwaysTrue()}
oMemo:oFont:=oFont
DEFINE SBUTTON  FROM 153,230 TYPE 1 ACTION oDlg:End() ENABLE OF oDlg PIXEL //Apaga
DEFINE SBUTTON  FROM 153,200 TYPE 13 ACTION (cFile:=cGetFile(cMask,OemToAnsi("Salvar Como...")),If(cFile="",.T.,MemoWrite(cFile,cMemo)),oDlg:End()) ENABLE OF oDlg PIXEL //Salva e Apaga //"Salvar Como..." //"Salvar Como..."

ACTIVATE MSDIALOG oDlg CENTER

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} A179Prod(cCod)
Posiciona na SB1 e retorna 
@author antenor.silva
@since 14/11/2013
@version 1.0
@return cEstSeg
/*/
//-------------------------------------------------------------------
Static Function A179Prod(cFilDisAba,cCod)
Local aAreaSB1	:= SB1->(GetArea())
Local cEstSeg		:= 0	

SB1->(dbSetOrder(1))
If SB1->(MsSeek(xFilial('SB1',cFilDisAba)+cCod))
	cEstSeg := SB1->B1_ESTSEG
EndIf

RestArea(aAreaSB1)

Return cEstSeg

//-------------------------------------------------------------------
/*/{Protheus.doc} MT179QtdThr()
Funcao utilizada para calcular a quantidade de threads a serem 
executadas em paralelo.
@author Marcos V. Ferreira
@since 05/07/2014
@version 1.0
@return aThreads
/*/
//-------------------------------------------------------------------
Static Function MT179QtdThr(cAliasTop)
Local aAreaAnt  := GetArea()
Local aProdutos := {}
Local aThreads  := {}
Local nX        := 0
Local nInicio   := 0
Local nRegProc  := 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ MV_M179THR parametro utilizado para informar o numero |
//| de threads para o processamento.                      |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local nThreads  := SuperGetMv('MV_M179THR',.F.,10)

If Select(cAliasTop) > 0
	//-- Carrega Array aProdutos
	Do While (cAliasTop)->(!Eof())
		aAdd(aProdutos,(cAliasTop)->PRODUTO)
		(cAliasTop)->(dbSkip())
	EndDo
EndIf
	
//-- Verifica Limite Maximo de 40 Threads
If nThreads > 40
	nThreads := 40
EndIf

//-- Analisa a quantidade de Threads X nRegistros
If Len(aProdutos) == 0
	aThreads := {}
ElseIf Len(aProdutos) < nThreads
	aThreads := ARRAY(1)			// Processa somente em uma thread
Else
	aThreads := ARRAY(nThreads)		// Processa com o numero de threads informada
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Calcula o registro original de cada thread e     ³
//³ aciona thread gerando arquivo de fila.           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nX:=1 to Len(aThreads)

	aThreads[nX]:={"","",1}
    
	// Registro inicial para processamento
	nInicio  := IIf( nX == 1 , 1 , aThreads[nX-1,3]+1 )

	// Quantidade de registros a processar
	nRegProc += IIf( nX == Len(aThreads) , Len(aProdutos) - nRegProc, Int(Len(aProdutos)/Len(aThreads)) )
	
	aThreads[nX,1] := nInicio
	aThreads[nX,2] := nRegProc
	aThreads[nX,3] := nRegProc

Next nX

RestArea(aAreaAnt)
Return {aThreads,aProdutos}

//-------------------------------------------------------------------
/*/{Protheus.doc} MT179JOB()
Funcao utilizada realizar o calculo de saldos por JOB (PERFORMANCE)
@author Marcos V. Ferreira
@since 05/07/2014
@version 1.0
@return Nil
/*/
//-------------------------------------------------------------------
Function MT179JOB(aParametros,aThread,aProdutos,cJobFile,cThread)
Local nHd1	     	:= 0
Local nSldDispon 	:= 0
Local nPrevCons  	:= 0 
Local nX         	:= 0
Local nPos       	:= 0
Local cFil       	:= aParametros[01]
Local cEmp       	:= aParametros[02]
Local cDbj_TpSug 	:= aParametros[03]
Local cCondPagto 	:= aParametros[04]
Local cCodForCli 	:= aParametros[05]
Local cLojForCli 	:= aParametros[06]
Local nPrecoProd 	:= aParametros[07]
Local cFilialSB1 	:= aParametros[08]
Local cFilialSA5 	:= aParametros[09]
Local cDbj_DocCom	:= aParametros[10]
Local cFilPrcFor 	:= aParametros[11]
Local cFilAntBkp 	:= aParametros[12]
Local cFilialSB2 	:= aParametros[13]
Local cDbj_FilDis	:= aParametros[14]
Local cDb5_FilAba	:= aParametros[15]
Local lDbj_EstSeg	:= aParametros[16]
Local lDbj_ConEst	:= aParametros[17]
Local lDbj_Reserv	:= aParametros[18]
Local lDbj_Empenh	:= aParametros[19]
Local lDbj_PrvEnt	:= aParametros[20]
Local lDbj_PdcArt	:= aParametros[21]
Local lDbj_SldTra	:= aParametros[22]
Local lA179ARMZ  	:= aParametros[23]
Local cDbj_Metodo	:= aParametros[24]
Local dDbj_DtDe	 	:= aParametros[25]
Local dDbj_DtAte 	:= aParametros[26]
Local lDbj_DevVen	:= aParametros[27]
Local nDbj_Increm	:= aParametros[28]
Local nDbj_DiasCo	:= aParametros[29]
Local cDb5_FilDis	:= aParametros[30]
Local cFilialSA2 	:= aParametros[31]
Local cTempDbi 	 	:= aParametros[32]
Local nSldDis
Local cLogErro   	:= ''
Local aSaldoSB1  	:= {}
Local lDbj_LtEEmb	:= aParametros[35]
Local nQE		 	:= 0

Local xData:= aParametros[34]

Local lMt179SAb := ExistBlock("MT179SAB") // Ponto de entrada para tratar o saldo da filial abastecida.
Local nSaldPE   := 0

// declaração das varias do insert da tabela temporária.
Local nInsNecCalc := 0
Local cDocomp     := ""
Local nSldTra     := 0
Local nSldSB1  	  := 0 
Local nSldFix     := 0
Local cCampos     := ""    
Local cValores    := ""
// Apaga arquivo ja existente
If File(cJobFile)
	fErase(cJobFile)
EndIf

// Criacao do arquivo de controle de jobs
nHd1 := MSFCreate(cJobFile)

// STATUS 1 - Iniciando execucao do Job
PutGlbValue("cGlb"+cEmp+cFil+cThread, "1" )
GlbUnLock()

// Seta job para nao consumir licensas
RpcSetType(3) 

// Seta job para empresa filial desejada
RpcSetEnv( cEmp, cFil,,,'EST')

//Restaura a DataBase
dDatabase:= xData

// STATUS 2 - Conexao efetuada com sucesso
PutGlbValue("cGlb"+cEmp+cFil+cThread, "2" )
GlbUnLock()

ConOut(dtoc(Date())+" "+Time()+" "+STR0086+" "+cJobFile) //" Inicio do job de geração do saldo produtos do MATA179 "

//-- Processamento dos Produtos Selecionados
For nX := aThread[1] to aThread[2]

	dbSelectArea("SB1")
	dbSetOrder(1)
	If MsSeek(cFilialSB1+aProdutos[nX]) 

		//-- Posiciona armazém padrão para análise do custo
		SB2->(dbSetOrder(1))
		SB2->(MsSeek(cFilialSB2+SB1->B1_COD+SB1->B1_LOCPAD))
	 	  
		//-- aSaldoSB1 é o array de controle do uso do saldo disponível na filial distribuidora	
		If aScan(aSaldoSB1, {|x| x[1] == SB1->B1_COD}) == 0
			nSldDis:= A179SldFil(cDbj_FilDis,SB1->B1_COD,.T.,lDbj_EstSeg,lDbj_ConEst,lDbj_Reserv,lDbj_Empenh,lDbj_PrvEnt,lDbj_PdcArt,lDbj_SldTra,lA179ARMZ)
			aAdd(aSaldoSB1,{SB1->B1_COD,nSldDis,nSldDis}) //Codigo ; Saldo Distribuido; Saldo Distribuidora
		EndIf
			
		//-- Se compra, busca fornecedor, preço e cond. pagto para o produto
		If cDbj_TpSug == "1"
			cCondPagto	:= ""
			cCodForCli	:= ""
			cLojForCli	:= ""
			nPrecoProd	:= 0
			//-- Se possui fornecedor padrão, o utiliza
			If !Empty(SB1->B1_PROC)
				cCodForCli := SB1->B1_PROC
				cLojForCli := SB1->B1_LOJPROC
			//-- Senão executa query para pesquisa de fornecedores na amarração Produto X Fornecedor (SA5)
			Else
				BeginSQL Alias "TMPSA5"
					SELECT SA5.A5_FORNECE,SA5.A5_LOJA,SA5.A5_CODTAB
					FROM %Table:SA5% SA5
					WHERE	SA5.A5_FILIAL = %Exp:cFilialSA5% AND
							SA5.A5_PRODUTO = %Exp:SB1->B1_COD% AND
							SA5.%NotDel%
					ORDER BY SA5.A5_NOTA DESC
				EndSQL
				If !TMPSA5->(EOF())
					cCodForCli := TMPSA5->A5_FORNECE
					cLojForCli := TMPSA5->A5_LOJA
				EndIf
				TMPSA5->(dbCloseArea())
				
				//-- Se configurado para gerar pedido e nao encontrou fornecedor, mudará para solicitação 							
				If cDbj_DocCom == "2" .And. Empty(cCodForCli)
					cLogErro += STR0073+AllTrim(SB1->B1_COD)+STR0070+cFilPrcFor+STR0071+cDb5_FilAba+STR0072+CRLF+CRLF // "Não foram localizados fornecedores para o produto " + " na filial " + ". O tipo de documento para este produto na filial " + +" foi trocado para Solicitação de Compra."
					fWrite(nHd1,cLogErro)
				EndIf
			EndIf
			
			//-- Se encontrou fornecedor, busca condição de pagamento
			SA2->(dbSetOrder(1))
			If !Empty(cCodForCli) .And. SA2->(MsSeek(cFilialSA2+cCodForCli+cLojForCli)) .And. Empty(cCondPagto := SA2->A2_COND) .And. cDbj_DocCom == "2"
				cLogErro += STR0068+AllTrim(cCodForCli)+"/"+cLojForCli+STR0069+AllTrim(SB1->B1_COD)+STR0070+cFilPrcFor+STR0071+cDb5_FilAba+STR0072+CRLF+CRLF // "Não foi localizada condição de pagamento (A2_COND) para o fornecedor " +" do produto " + " na filial " + ". O tipo de documento para este produto na filial " + +" foi trocado para Solicitação de Compra."
				fWrite(nHd1,cLogErro)
			EndIf
	
			//-- Executa query para pesquisa do preço a aplicar
			dbSelectArea("SA5")
			SA5->(dbSetOrder(1))
			If MsSeek(cFilialSA5+cCodForCli+cLojForCli+SB1->B1_COD)
				A179AltFil(cFilPrcFor)
				nPrecoProd := MaTabPrCom(SA5->A5_CODTAB,SB1->B1_COD,0,cCodForCli,cLojForCli)
				A179AltFil(cFilAntBkp)
			EndIf
		EndIf
		
		//-- Calcula saldo disponível do produto na filial a abastecer
		nSldDispon := A179SldFil(cDb5_FilAba,SB1->B1_COD,Iif(cDb5_FilAba == cDb5_FilDis, .T., .F.),lDbj_EstSeg,lDbj_ConEst,lDbj_Reserv,lDbj_Empenh,lDbj_PrvEnt,lDbj_PdcArt,lDbj_SldTra,lA179ARMZ)
		
		If cDb5_FilAba == cDb5_FilDis // Se filial abastecida for igual a filial distribuidora.
			
			// Ponto de entrada para tratar o saldo da abastecida.
			If lMt179SAb
				
				nSaldPE := ExecBlock("MT179SAB", .F., .F., {SB1->B1_COD, nSldDispon})
				
				If ValType(nSaldPE) == "N" // Verifica se o retorno do P.E. e numero.
					
					nSldDispon := nSaldPE
					
				EndIf
				
			EndIf
			
		EndIf
		
		//-- Calcula previsão de consumo para o produto na filial a abastecer
		nPrevCons := A179PrCons(cDb5_FilAba,SB1->B1_COD,cDbj_Metodo,dDbj_DtDe,dDbj_DtAte,lDbj_DevVen,nDbj_Increm,nDbj_DiasCo,cCodForCli,cLojForCli,lDbj_EstSeg,lDbj_LtEEmb)
				
		If cDbj_TpSug == "2"
			A179AltFil(cDb5_FilDis)
			nPrecoProd := MaTabPrVen(SA1->A1_TABELA,SB1->B1_COD,Max(0,nPrevCons-nSldDispon),cCodForCli,cLojForCli)
			A179AltFil(cFilAntBkp)
		EndIf
	
		If nPrecoProd == 0 //-- Se tabela vazia
			Do Case
			Case RetFldProd(SB1->B1_COD,"B1_UPRC") > 0 //-- Tenta ultimo preço de compra
				nPrecoProd := RetFldProd(SB1->B1_COD,"B1_UPRC")
			Case RetFldProd(SB1->B1_COD,"B1_CUSTD") > 0 //-- Senão custo standard
				nPrecoProd := xMoeda(RetFldProd(SB1->B1_COD,"B1_CUSTD"),Val(RetFldProd(SB1->B1_COD,"B1_MCUSTD")),1,RetFldProd(SB1->B1_COD,"B1_UCALSTD"))						
			Case SB2->B2_CM1 > 0	//-- Senão custo médio
				nPrecoProd := SB2->B2_CM1					
			Case !Empty(cCodForCli) .And. cDbj_TpSug == "1" .And. cDbj_DocCom == "2"
				cLogErro += STR0074 +AllTrim(SB1->B1_COD)+STR0070+cFilPrcFor+STR0071+cDb5_FilAba+STR0072+CRLF+CRLF //"Não há preço de compra para o produto " + " na filial " + ". O tipo de documento para este produto na filial " + " foi trocado para Solicitação de Compra."
				fWrite(nHd1,cLogErro)
			Case !Empty(cCodForCli) .And. cDbj_TpSug == "2"
				cLogErro += STR0075+AllTrim(SB1->B1_COD)+STR0070+cDb5_FilAba+STR0076+CRLF+CRLF //"Não há preço para transferência do produto " +" para a filial " + " e isto impede o processo de transferência. Este produto será desconsiderado no cálculo desta filial."
				fWrite(nHd1,cLogErro)
			EndCase
		EndIf

		//-- Grava dados no modelo dos produtos
		nNecessCalc := Max(0,nPrevCons - nSldDispon)
	    If nNecessCalc > 0
			nInsNecCalc := nNecessCalc 
			If cDbj_TpSug == "1" .And. (Empty(cCodForCli) .Or. Empty(cCondPagto) .Or. Empty(nPrecoProd))
				cDocomp := "1"
			Else
				cDocomp := cDbj_DocCom
			EndIf
		//-- Verifica se há necessidade e se tem saldo na filial distribuidora para consumi-lo
			nPos := aScan(aSaldoSB1,{|x| x[1] == aProdutos[nX]})
			If nNecessCalc > 0 .And. nPos > 0 .And. aSaldoSB1[nPos,2] > 0
				If (cDb5_FilAba # cDb5_FilDis)
					nSldTra := Min(nNecessCalc,aSaldoSB1[nPos,2]) // utilizar variavel
				Else
					nNecessCalc -=  Min(nNecessCalc,aSaldoSB1[nPos,2])
				End
				aSaldoSB1[nPos,2] -= Min(nNecessCalc,aSaldoSB1[nPos,2]) 						 
			Else
				nSldTra := 0
			EndIf
			If nPos > 0
				nSldSB1	:= aSaldoSB1[nPos,2]
				nSldFix	:= aSaldoSB1[nPos,3]
			EndIf
			nNecessCalc -= nSldTra
			If lDbj_LtEEmb
				nQE	  := RetFldProd(SB1->B1_COD,"B1_QE","SB1")
				If nQE > 0
					nPrevCons := If(nPrevCons < nQE,nQE,Round(nPrevCons / nQE, 0) * nQE)
					nNecessCalc := If(nNecessCalc < nQE,nQE,Round(nNecessCalc / nQE, 0) * nQE)
				EndIf
			EndIf			
			cCampos  :=   "DBI_PRODUT ,DBI_DESCPR  ,DBI_CONSUM,DBI_SLDABA,DBI_NECALC ,DBI_NECINF ,DBI_FORNEC,DBI_LOJA  ,DBI_COND  ,DBI_PRECO ,DBI_DOCOMP,DBI_SLDTRA,DBI_SLDSB1,DBI_SLDFIX,DBI_QTDCOM"    
		 // cValores ----  SB1->B1_COD,SB1->B1_DESC,nPrevCons ,nSldDispon,nInsNecCalc,nInsNecCalc,cCodForCli,cLojForCli,cCondPagto,nPrecoProd,cDocomp   ,nSldTra   ,nSldSB1   ,nSldFix   ,nNecessCalc      
			cValores := "'"+SB1->B1_COD+"',"+ ;   
						"'"+SB1->B1_DESC+"',"+ ;  	
							PadR(nPrevCons,TamSx3("DBI_CONSUM")[1]) +","+;   
							PadR(nSldDispon,TamSx3("DBI_SLDABA")[1]) +","+;
							PadR(nInsNecCalc,TamSx3("DBI_NECALC")[1]) +","+;
							PadR(nInsNecCalc,TamSx3("DBI_NECINF")[1]) +","+;
						"'"+cCodForCli+"',"+;
						"'"+cLojForCli+"',"+;
						"'"+cCondPagto+"',"+;
							PadR(nPrecoProd,TamSx3("DBI_PRECO")[1]) +","+;
						"'"+cDocomp   +"',"+;
							PadR(nSldTra,TamSx3("DBI_SLDTRA")[1]) +","+;
							PadR(nSldSB1,TamSx3("DBI_SLDTRA")[1]) +","+;
							PadR(nSldFix,TamSx3("DBI_SLDTRA")[1]) +","+;
							PadR(nNecessCalc,TamSx3("DBI_QTDCOM")[1])  			
			
			tcsqlexec( " Insert Into "+cTempDbi+" ("+cCampos+") Values ("+cValores+")")
		EndIf	
	EndIf
Next nX

// STATUS 3 - Processamento efetuado com sucesso
PutGlbValue("cGlb"+cEmp+cFil+cThread,"3")
GlbUnLock()

// Fecha arquivo de controle do MATA179
fClose(nHd1)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} MT179AddLine()
Funcao utilizada atualizar as linhas do objeto MVC 
@author Marcos V. Ferreira
@since 05/07/2014
@version 1.0
@return Nil
/*/
//-------------------------------------------------------------------
Static Function MT179AddLine(cArqTemp,cFilialDBI,cDbj_Sugest,cDb5_FilAba,cDbj_DocCom,cDbj_Compra,cDbj_Entreg,cDb5_FilDis,oProcess,oModelDBI,cDbj_TpSug,aSaldoSB1)

Local lRet        := .F.
Local nNecessCalc := 0
Local nPrevCons	  := 0
Local nPrecoProd  := 0
Local nSldDispon  := 0
Local nDbi_QtdCom := 0
Local nDbi_SldTra := 0
Local nDbi_SldSB1 := 0
Local nDbi_SldFix := 0
Local cProduto 	  := ''
Local cCodForCli  := ''
Local cLojForCli  := ''
Local cCondPagto  := ''

If Select(cArqTemp) > 0
	
	(cArqTemp)->(dBGoTop())
	oProcess:SetRegua2((cArqTemp)->(LastRec()))

	Do While (cArqTemp)->(!Eof())

		cProduto 		:= (cArqTemp)->DBI_PRODUT
		cProdDesc		:= (cArqTemp)->DBI_DESCPR
		nPrevCons 		:= (cArqTemp)->DBI_CONSUM
		nSldDispon 		:= (cArqTemp)->DBI_SLDABA
		cCodForCli 		:= (cArqTemp)->DBI_FORNEC
		cLojForCli 		:= (cArqTemp)->DBI_LOJA
		cCondPagto 		:= (cArqTemp)->DBI_COND
		nPrecoProd 		:= (cArqTemp)->DBI_PRECO
		nDbi_SldTra 	:= (cArqTemp)->DBI_SLDTRA 
		nDbi_SldSB1 	:= (cArqTemp)->DBI_SLDSB1
		nDbi_SldFix 	:= (cArqTemp)->DBI_SLDFIX
		nDbi_QtdCom 	:= (cArqTemp)->DBI_QTDCOM		
	
		oProcess:IncRegua2(STR0093 + AllTrim(cProduto) + '...') //"Concluindo calculo do produto: "

		//-- aSaldoSB1 e o array de controle do uso do saldo disponível na filial distribuidora	
		If aScan(aSaldoSB1, {|x| x[1] == cProduto}) == 0
			aAdd(aSaldoSB1,{cProduto,nDbi_SldFix,nDbi_SldFix})
		EndIf

		//-- Grava dados no modelo dos produtos
		nNecessCalc := Max(0,nPrevCons - nSldDispon)
	
		If nNecessCalc > 0 .And. !Empty(cProduto)
	
			lRet := .T. //-- Sinaliza que processou ao menos um produto
			If !Empty(oModelDBI:GetValue("DBI_PRODUT")) //Quando for a primeira linha
				oModelDBI:AddLine(.T.)
			EndIf
			oModelDBI:LoadValue("DBI_FILIAL",cFilialDBI )
			oModelDBI:LoadValue("DBI_SUGEST",cDbj_Sugest)
			oModelDBI:LoadValue("DBI_FILABA",cDb5_FilAba)
			oModelDBI:LoadValue("DBI_PRODUT",cProduto   )
			oModelDBI:LoadValue("DBI_DESCPR",cProdDesc  )
			oModelDBI:LoadValue("DBI_CONSUM",nPrevCons  )
			oModelDBI:LoadValue("DBI_SLDABA",nSldDispon )
			oModelDBI:LoadValue("DBI_NECALC",nNecessCalc)
			oModelDBI:LoadValue("DBI_NECINF",nNecessCalc)
			oModelDBI:LoadValue("DBI_SLDTRA",nDbi_SldTra)

			If cDbj_TpSug == "1" .And. (Empty(cCodForCli) .Or. Empty(cCondPagto) .Or. Empty(nPrecoProd))
				oModelDBI:LoadValue("DBI_DOCOMP","1")
			Else
				oModelDBI:LoadValue("DBI_DOCOMP",cDbj_DocCom)
			EndIf
			oModelDBI:LoadValue("DBI_COMPNA",cDbj_Compra)
			oModelDBI:LoadValue("DBI_ENTRNA",cDbj_Entreg)
			If !Empty(cCodForCli)
				oModelDBI:LoadValue("DBI_FORNEC",cCodForCli)
				oModelDBI:LoadValue("DBI_LOJA"	,cLojForCli)						
			EndIf
			If !Empty(cCondPagto)
				oModelDBI:LoadValue("DBI_COND"	,cCondPagto)
			EndIf
			If !Empty(nPrecoProd)
				oModelDBI:LoadValue("DBI_PRECO"	,nPrecoProd)
			EndIf
	
			//-- Verifica se há necessidade e se tem saldo na filial distribuidora para consumi-lo
			nPos := aScan(aSaldoSB1,{|x| x[1] == cProduto})
			If nNecessCalc > 0 .And. aSaldoSB1[nPos,2] > 0
				If cDb5_FilAba # cDb5_FilDis
					oModelDBI:LoadValue("DBI_SLDTRA",Min(nNecessCalc,aSaldoSB1[nPos,2]))
				Else
					nNecessCalc -=  Min(nNecessCalc,aSaldoSB1[nPos,2])
				End
				aSaldoSB1[nPos,2] -= Min(nNecessCalc,aSaldoSB1[nPos,2])
			Else
				oModelDBI:LoadValue("DBI_SLDTRA",0)
			EndIf
	
			nNecessCalc -= oModelDBI:GetValue("DBI_SLDTRA")
			oModelDBI:LoadValue("DBI_QTDCOM",nNecessCalc)
			oModelDBI:LoadValue("DBI_SLDDIS",Max(aSaldoSB1[nPos,2],0))
			oModelDBI:LoadValue("DBI_SLDFIS",Max(aSaldoSB1[nPos,3],0))
		EndIf		

		(cArqTemp)->(dbSkip())

	EndDo	

    //Encerra a tabela temporaria
	(cArqTemp)->( dbCloseArea() )

EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} a179Mark()
Adiciona botões para controlar o checkbox dos filtros de Tipo e Grupo 
@author José Eulálio
@since 23/06/2016
@version 1.0
@return Nil
/*/
//-------------------------------------------------------------------
Static Function a179Mark(oPanel, oView, oModel, cFiltro)
Local lWhen	:= .T.

@ oPanel:nTop + 5, 5  Button STR0098 Size 37, 10 Message STR0099 Pixel Action a179MrkInv(oView,oModel,cFiltro) of oPanel When lWhen
@ oPanel:nTop + 20, 5 Button STR0100 Size 37, 10 Message STR0101 Pixel Action a179MrkInv(oView,oModel,cFiltro,.T.) of oPanel When lWhen

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} a179MrkInv()
Função para inverter a seleção do checkbox dos filtros de Tipo e Grupo 
@author José Eulálio
@since 23/06/2016
@version 1.0
@return Nil
/*/
//-------------------------------------------------------------------
Static Function a179MrkInv(oView,oModel,cFiltro,lInvert)
Local nX	:= 0
Local cCampo
Local lMark
Local oModFil

//Define se será inversão ou marcar/desmarcar todos
Default lInvert := .F.

//Seleciona modelo e campo de acordo com a aba posicionada
Do Case
	Case cFiltro == "FILAB"
		oModFil	:= oModel:GetModel("FIL_FILIAL")
		cCampo		:= "DB5_OK"
	Case cFiltro == "TIPO"
		oModFil	:= oModel:GetModel("FIL_TIPO")
		cCampo		:= "CHECKTP"
	Case cFiltro == "GRUPO"
		oModFil	:= oModel:GetModel("FIL_GRUPO")
		cCampo		:= "CHECKGRP"
End Case

//Atualiza todas as linhas da grid
For nX := 1 to oModFil:length()
	oModFil:GoLine(nX)
	//Se baseia na primeira linha para marcar/desmarcar todos ou inverte a seleção
	If nX == 1 .Or. lInvert
		lMark := oModFil:GetValue(cCampo)
	EndIf
	oModFil:LoadValue(cCampo	, !lMark )
Next nX

//Atualiza a tela
oModFil:GoLine(1)
oView:Refresh()

Return .T.
