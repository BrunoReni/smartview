#include "protheus.ch"
#include "fwmvcdef.ch"
#include "coma015.ch"

//-------------------------------------------------------------------
/*/{Protheus.doc} COMA015
Cadastro de SC x Grupo de Aprovador
@since 11/02/2019
/*/
//-------------------------------------------------------------------
Function COMA015()
Local oBrowse
	
	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias('COJ')
	oBrowse:SetDescription('SC X Grupo de Aprovacao')
	oBrowse:Activate()
		
Return

Static Function MenuDef()
Local aRotina := {}

ADD OPTION aRotina TITLE 'Visualizar' ACTION 'VIEWDEF.COMA015' OPERATION 2 ACCESS 0
ADD OPTION aRotina TITLE 'Incluir'    ACTION 'VIEWDEF.COMA015' OPERATION 3 ACCESS 0
ADD OPTION aRotina TITLE 'Alterar'    ACTION 'VIEWDEF.COMA015' OPERATION 4 ACCESS 0
ADD OPTION aRotina TITLE 'Excluir'    ACTION 'VIEWDEF.COMA015' OPERATION 5 ACCESS 0
ADD OPTION aRotina TITLE 'Imprimir'   ACTION 'VIEWDEF.COMA015' OPERATION 8 ACCESS 0

Return aRotina

Static Function ModelDef()
Local oModel
Local oStruCOJ := FWFormStruct(1,"COJ")

oModel := MPFormModel():New('COMA015', /*bPreValidacao*/, {|oModel|a015Valid(oModel)}/*bPosValidacao*/, /*bCommit*/, /*bCancel*/ )
oModel:SetDescription('COMA015')

oModel:addFields('MASTERCOJ',,oStruCOJ)
oModel:getModel('MASTERCOJ'):SetDescription('COMA015')
 
Return oModel

Static Function ViewDef()
Local oModel := ModelDef()
Local oView
Local oStrCOJ:= FWFormStruct(2, 'COJ')
	
oView := FWFormView():New()
oView:SetModel(oModel)

oView:AddField('FORM_SC' , oStrCOJ,'MASTERCOJ' ) 
oView:CreateHorizontalBox( 'BOX_FORM_SC', 100)
oView:SetOwnerView('FORM_SC','BOX_FORM_SC')	

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} a015Valid
Validacao de cadastro existente. 

@since 12/02/19
@version P12.1.17
/*/
//-------------------------------------------------------------------
Static Function a015Valid(oModel)

Local lRet := .T.
Local nOperation := oModel:GetOperation() 
Local cCusto	:= oModel:GetValue( 'MASTERCOJ', 'COJ_CUSTO' ) 
Local cPrefix	:= oModel:GetValue( 'MASTERCOJ', 'COJ_PREFIX' )

If nOperation == 3 .Or. ;
(nOperation == 4 .And. cCusto + cPrefix <> COJ->(COJ_CUSTO+COJ_PREFIX))
	dbSelectArea("COJ")
	dbSetOrder(1)
	If dbSeek(xFilial("COJ") + cCusto + cPrefix)
		lRet := .F.
		Help("",1,STR0001,,STR0002,4,1)
	EndIf	
EndIf

Return lRet

