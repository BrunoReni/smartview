#INCLUDE "COMA087.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE 'FWMVCDef.CH'

/*/{Protheus.doc} COMA087
Cadastro de compradores em MVC

@type Static Function
@author Capeli / Willian
@since 12/11/2018
@version P12.1.17
/*/
Function COMA087(xRotAuto,nOpcAuto)

Local oBrowse 	:= Nil

Default nOpcAuto := 3

If ValType(xRotAuto) == "A"
	FWMVCRotAuto(ModelDef(),"SY1", nOpcAuto, {{"SY1MASTER",xRotAuto}},,.T.)
Else
	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias("SY1")
	oBrowse:SetDescription(STR0001) //"Cadastro de Compradores"
	oBrowse:Activate()
EndIf

Return

/*/{Protheus.doc} ModelDef
Define o model padrão para o cadastro de compradores

@type Static Function
@author Capeli / Willian
@since 12/11/2018
@version P12.1.17
/*/
Static Function ModelDef()

Local oModel
Local oStrSY1   := FWFormStruct(1,"SY1")

oStrSY1:SetProperty('Y1_COD', MODEL_FIELD_INIT, FwBuildFeature(STRUCT_FEATURE_INIPAD, 'GetSXENum("SY1","Y1_COD")'))		//Ini Padrão

oStrSY1:SetProperty('Y1_GRAPROV', MODEL_FIELD_VALID, FwBuildFeature(STRUCT_FEATURE_VALID, 'VAZIO() .OR. EXISTCPO("SAL",FWFldGet("Y1_GRAPROV"))'))		//Valid

oStrSY1:SetProperty('Y1_GRUPCOM', MODEL_FIELD_VALID, FwBuildFeature(STRUCT_FEATURE_VALID, 'VAZIO() .OR. EXISTCPO("SAJ",FWFldGet("Y1_GRUPCOM"))'))		//Valid

oStrSY1:SetProperty('Y1_GRAPRCP', MODEL_FIELD_VALID, FwBuildFeature(STRUCT_FEATURE_VALID, 'VAZIO() .OR. EXISTCPO("SAL",FWFldGet("Y1_GRAPRCP"))'))		//Valid

oStrSY1:SetProperty("Y1_USER",MODEL_FIELD_WHEN,{|| oModel:GetOperation() == MODEL_OPERATION_INSERT})

oStrSY1:SetProperty('Y1_NOME', MODEL_FIELD_WHEN, FwBuildFeature(STRUCT_FEATURE_WHEN, '.F.'))		//When

oStrSY1:AddTrigger('Y1_USER', 'Y1_NOME', {|| .T.},{||UsrFullName(FWFldGet("Y1_USER"))})	// Trigger

oModel := MPFormModel():New('COMA087',/*bPreValid*/,{|oModel| CM087TOK(oModel)})
oModel:SetDescription(STR0001)

oModel:addFields('SY1MASTER',,oStrSY1)

Return oModel

/*/{Protheus.doc} ViewDef
Define a view padrão para o cadastro de compradores

@type Static Function
@author Capeli / Willian
@since 14/02/2018
@version P12.1.17
/*/
Static Function ViewDef()

Local oView
Local oModel    := FWLoadModel('COMA087')
Local oStrSY1   := FWFormStruct(2,'SY1',{|cCampo| !(AllTrim(cCampo) $ "Y1_COD")})

oView := FWFormView():New()
oView:SetModel(oModel)

oView:showUpdateMsg(.F.)
oView:showInsertMsg(.F.)

oStrSY1:SetProperty('Y1_USER',MVC_VIEW_ORDEM,'00')

oView:AddField('FORMSY1',oStrSY1,'SY1MASTER')
oView:CreateHorizontalBox('SY1CAB',100)
oView:SetOwnerView('FORMSY1', 'SY1CAB')


Return oView

/*/{Protheus.doc} MenuDef
Define o menu padrão para o cadastro de compradores

@type Static Function
@author Capeli / Willian
@since 14/02/2018
@version P12.1.17
/*/
Static Function MenuDef()

Local aRotina 		:= {} //Array utilizado para controlar opcao selecionada

ADD OPTION aRotina TITLE STR0002	ACTION "VIEWDEF.COMA087"	OPERATION 2		ACCESS 0  	//"Visualizar"
ADD OPTION aRotina TITLE STR0003	ACTION "VIEWDEF.COMA087"	OPERATION 3  	ACCESS 0	//"Incluir"
ADD OPTION aRotina TITLE STR0004	ACTION "VIEWDEF.COMA087"	OPERATION 4 	ACCESS 0	//"Alterar"
ADD OPTION aRotina TITLE STR0005	ACTION "VIEWDEF.COMA087"	OPERATION 5  	ACCESS 3	//"Excluir"

Return(aRotina)

/*/{Protheus.doc} CM087TOK
Funcao para PosValid do cadastro de compradores

@type Static Function
@author Capeli / Willian
@since 14/02/2018
@version P12.1.17
/*/
Static Function CM087TOK(oModel)

Local oModelSY1 := oModel:GetModel("SY1MASTER")
Local lRet      := .T.

If oModel:GetOperation() == MODEL_OPERATION_DELETE
	DbSelectArea("SAJ")
	SAJ->(DbSetOrder(2))
	If SAJ->(DbSeek(xFilial("SAJ") + oModelSY1:GetValue("Y1_USER") ))
		Help(" ",1,"CM087DEL",,STR0006,1,0)	// "Este comprador ja foi utilizado em um Grupo de Compras e nao podera ser excluido. Para excluir o Comprador, o mesmo nao devera ser utilizado em nenhum Grupo de Compras."
		lRet := .F.
	EndIf
EndIf

Return lRet

/*/{Protheus.doc} IntegDef
Chamada da Mensagem Unica de Cadastro de Comprador

@param cXml Xml passado para a rotina
@param nType Determina se e uma mensagem a ser enviada/recebida ( TRANS_SEND ou TRANS_RECEIVE)
@param cTypeMsg Tipo de mensagem ( EAI_MESSAGE_WHOIS,EAI_MESSAGE_RESPONSE,EAI_MESSAGE_BUSINESS)

@return aRet[1] boleano determina se a mensagem foi executada ou nao com sucesso
@return aRet[2] string xml

@author Capeli / Willian
@since 12/11/2018
@version P12.1.17
/*/
Static Function IntegDef( cXml, nTypeTrans, cTypeMessage )

Local aRet := {}

aRet:= MATI087( cXml, nTypeTrans, cTypeMessage )

Return aRet
