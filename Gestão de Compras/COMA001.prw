#Include "COMA001.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} COMA001()
Cadastro de Grupo de Fornecedores

@author guilherme.pimentel	
@since 27/08/2014
@version 1.0
@return NIL
/*/
//-------------------------------------------------------------------
Function COMA001()
Local oBrowse

oBrowse := FWMBrowse():New()
oBrowse:SetAlias('CPW')
oBrowse:SetDescription(STR0007)//'Entrega por Terceiros'
oBrowse:Activate()

Return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef()
Função para criação do menu 

@author guilherme.pimentel
@since 27/08/2014
@version 1.0
@return aRotina 
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

ADD OPTION aRotina TITLE STR0002 	ACTION 'VIEWDEF.COMA001' 	OPERATION 2 ACCESS 0//"Visualizar"
ADD OPTION aRotina TITLE STR0003    ACTION 'VIEWDEF.COMA001'	OPERATION 3 ACCESS 0//"Incluir"
ADD OPTION aRotina TITLE STR0004	ACTION 'VIEWDEF.COMA001'	OPERATION 4 ACCESS 0//"Alterar"
ADD OPTION aRotina TITLE STR0005    ACTION 'VIEWDEF.COMA001' 	OPERATION 5 ACCESS 0//"Excluir"
ADD OPTION aRotina TITLE STR0006   	ACTION 'VIEWDEF.COMA001'	OPERATION 8 ACCESS 0//"Imprimir"

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Definição do modelo de Dados

@author guilherme.pimentel
@since 27/08/2014
@version 1.0
@Return oModel
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oModel
Local oStrCPW:= FWFormStruct(1,'CPW')
Local oStrCPX:= FWFormStruct(1,'CPX')

oModel := MPFormModel():New('COMA001')
oModel:AddFields('CPWMASTER',/*cOwner*/ , oStrCPW)
oModel:AddGrid(  'CPXDETAIL','CPWMASTER', oStrCPX,{|oModelGrid,nLine,cAction, cField |COM001PVLD(oModelGrid,nLine,cAction,cField)})

oModel:SetRelation('CPXDETAIL', { { 'CPX_FILIAL', 'xFilial("CPX")' }, { 'CPX_CODIGO', 'CPW_CODIGO' }, { 'CPX_LOJA', 'CPW_LOJA' } }, CPX->(IndexKey(1)) )

oModel:GetModel("CPXDETAIL"):SetUniqueLine({"CPX_CODFOR", "CPX_LOJFOR"})

oModel:GetModel('CPWMASTER'):SetDescription(STR0008)//"Grupo"
oModel:GetModel('CPXDETAIL'):SetDescription(STR0009)//"Fornecedores"

oModel:SetDescription(STR0007)//'Entrega por Terceiros'

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Definição do interface

@author guilherme.pimentel
@since 27/08/2014
@version 1.0
@Return oView
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oView
Local oModel := ModelDef()
Local oStrCPW:= FWFormStruct(2, 'CPW')
Local oStrCPX:= FWFormStruct(2, 'CPX',{|cCampo| !AllTrim(cCampo) $ "CPX_CODIGO, CPX_LOJA"})

oView := FWFormView():New()

oView:SetModel(oModel)

oView:AddField('VIEW_CPW' , oStrCPW, 'CPWMASTER' )
oView:AddGrid( 'VIEW_CPX' , oStrCPX, 'CPXDETAIL' )

oView:CreateHorizontalBox( 'CPW', 30)
oView:CreateHorizontalBox( 'CPX', 70)

oView:SetOwnerView('VIEW_CPW','CPW')
oView:SetOwnerView('VIEW_CPX','CPX')

oView:AddIncrementField( 'VIEW_CPX', 'CPX_ITEM' )

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} COM001VldF
Validação dos fornecedores

@author guilherme.pimentel
@since 28/08/2014
@param cModel Modelo a ser validado
@version 1.0
@Return oView
/*/
//-------------------------------------------------------------------
Function COM001VldF(cModel)
Local lRet		:= .T.
Local oModel	:= FWModelActive()
Local oModelCPW	:= oModel:GetModel('CPWMASTER')
Local oModelCPX	:= oModel:GetModel('CPXDETAIL')
Local nX		:= 0

If cModel:GetID() == 'CPWMASTER'
	For nX := 1 to oModelCPX:Length()
		oModelCPX:GoLine(nX)
		If !oModelCPX:IsDeleted() .And. oModelCPX:GetValue('CPX_CODFOR') == oModelCPW:GetValue('CPW_CODIGO') .And. ;
		   oModelCPX:GetValue('CPX_LOJFOR') == oModelCPW:GetValue('CPW_LOJA')
			lRet := .F.
			Help(" ",1,"COM001VldF",,STR0010,1,1) //"Fornecedor não permitido pois esse registro existe nos itens. Favor alterar."
		EndIf
	Next
	If !Empty(oModelCPW:GetValue('CPW_LOJA')) .And. SA2->(DbSeek(xFilial('SA2')+oModelCPW:GetValue('CPW_CODIGO')+oModelCPW:GetValue('CPW_LOJA'))) .And. lRet
		oModelCPW:LoadValue('CPW_NOME',SA2->A2_NOME)
	End
Else
	If oModelCPX:GetValue('CPX_CODFOR') == oModelCPW:GetValue('CPW_CODIGO') .And. oModelCPX:GetValue('CPX_LOJFOR') == oModelCPW:GetValue('CPW_LOJA')
		lRet := .F.
		Help(" ",1,"COM001VldF",,STR0011,1,1) //"Fornecedor não permitido pois é o mesmo do cabeçalho. Favor alterar."
	EndIf
	If !Empty(oModelCPX:GetValue('CPX_LOJFOR')) .And. SA2->(DbSeek(xFilial('SA2')+oModelCPX:GetValue('CPX_CODFOR')+oModelCPX:GetValue('CPX_LOJFOR'))) .And. lRet
		oModelCPX:LoadValue('CPX_NOME',SA2->A2_NOME)
	End 
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} COM001PVLD(oModelGrid, nLinha, cAcao, cCampo)
Rotina de Pre validação do modelo

@author guilherme.pimentel

@param oModelGrid Modelo
@param nLinha Linha corrente
@param cAcao  Ação ("DELETE", "SETVALUE", e etc)
@param cCampo Campo atualizado
@return lRet
@since 28/08/2014
@version 1.0
/*/
//------------------------------------------------------------------
Function COM001PVLD(oModelGrid,nLinha,cAcao,cCampo)
Local lRet		:= .T.
Local oModel	:= Nil
Local oModelCPW	:= Nil
Local oModelCPX	:= Nil

If cAcao == 'UNDELETE'
	oModel	:= FWModelActive()
	oModelCPW	:= oModel:GetModel('CPWMASTER')
	oModelCPX	:= oModel:GetModel('CPXDETAIL')

	If oModelCPX:GetValue('CPX_CODFOR') == oModelCPW:GetValue('CPW_CODIGO') .And. oModelCPX:GetValue('CPX_LOJFOR') == oModelCPW:GetValue('CPW_LOJA')
		lRet := .F.
		Help(" ",1,"COM001VldF",,STR0012,1,1) //"Fornecedor não permitido pois é o mesmo do cabeçalho. Favor alterar o cabeçalho."
	EndIf		
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} COM001VldI
Validação de integridade do fornecedor

@author guilherme.pimentel
@since 28/08/2014
@param cModel Modelo a ser validado
@version 1.0
@Return oView
/*/
//-------------------------------------------------------------------
Function COM001VldI(cTipo)
Local lRet := .T.

If cTipo == 'CPW'
	lRet := IF(Empty(FWFldGet('CPW_LOJA')),.T., ExistChav("CPW",FWFldGet('CPW_CODIGO')+FWFldGet('CPW_LOJA'))) .And. ;
			    ExistCpo("SA2",FWFldGet("CPW_CODIGO")+IF(Empty(FWFldGet("CPW_LOJA")),'',FWFldGet("CPW_LOJA")))
Else
	lRet := ExistCpo("SA2",FWFldGet('CPX_CODFOR')+IF(Empty(FWFldGet("CPX_LOJFOR")),'',FWFldGet("CPX_LOJFOR")))
EndIf

Return lRet
