#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "FWMVCDEF.CH"                 
#INCLUDE "FWADAPTEREAI.CH"
#include "TbIconn.ch"
#include "TopConn.ch"
#INCLUDE "CM110.CH"

#DEFINE SOURCEFATHER "COMA110"

//Controle de Pontos de Entrada
Static lMT110FIL  := ExistBlock("MT110FIL")
Static lMT110COR  := ExistBlock("MT110COR")
Static lMTA110MNU := ExistBlock("MTA110MNU")
Static lMT110MEM  := ExistBlock("MTA110MEM")

//-------------------------------------------------------------------
/*/{Protheus.doc} COMA110CHI
Solicitação de compras para a localização Chile.
@author Luiz Henrique Bourscheid
@since 21/10/2017
@version 1.0
@return NIL
/*/
//-------------------------------------------------------------------
Function COMA110CHI(xAutoCab,xAutoItens, nOpcAuto,lWhenGet)	
	Local oBrowse
	// Carregado do ponto de entrada M110STTS - 25/05/11 - FWS
	Local _nTotSC := 0     //_f110TotSC(_cNumSC)
	Local ntotsc1 := 0
	
	DEFAULT lWhenGet	:= .F.
	Private l110Auto	:= (xAutoCab <> Nil .and. (xAutoItens <> Nil .Or. nOpcAuto==5))
	Private lGrade      := MaGrade()
	Private lGatilha    := .T.           
	Private aRotina		:= MenuDef()
	Private bPmsDlgSC
	PRIVATE cFieldsSC1 := "C1_NUM|C1_UNIDREQ|C1_CODCOMP|C1_SOLICIT|C1_EMISSAO|C1_FILENT|C1_NATUREZ"
	PRIVATE cFieldSC1V := "C1_NUM|C1_UNIDREQ|C1_CODCOMP|C1_SOLICIT|C1_EMISSAO|C1_FILENT|C1_NATUREZ"
	Private cCadastro  := OemtoAnsi(STR0001)
	PRIVATE oGrade     := MsMatGrade():New('oGrade',,"C1_QUANT",,"C110GValid()",,;
  						{ 	{"C1_QUANT" ,.T., {{"C1_QTSEGUM",{|| ConvUm(AllTrim(oGrade:GetNameProd(,nLinha,nColuna)),aCols[nLinha][nColuna],0,2) } }} },;
  							{"C1_ITEM",NIL,NIL},;
							{"C1_DATPRF",NIL,NIL},;
  							{"C1_QTSEGUM",.T., {{"C1_QUANT",{|| ConvUm(AllTrim(oGrade:GetNameProd(,nLinha,nColuna)),0,aCols[nLinha][nColuna],1) }}} } })
	
	If ( AMIIn(02,04,05,06,07,09,10,12,19,34,97,98,44,67,69,72,87) )
		If !( l110Auto )
			SetKey(VK_F12,{|| Pergunte("MTA110",.T.)})
		EndIf		
		oBrowse := BrowseDef()	
		oBrowse:Activate()				
	EndIf	   	
Return .T.
//-------------------------------------------------------------------
/*/{Protheus.doc} BrowseDef
Definição do browse para a localização Chile.
@author Luiz Henrique Bourscheid
@since 21/10/2017
@version 1.0
@return NIL
/*/
//-------------------------------------------------------------------
Static Function BrowseDef()
	Local oBrowse := FwLoadBrw(SOURCEFATHER) 
Return oBrowse
//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Definição do modelo para a localização Chile.
@author Luiz Henrique Bourscheid
@since 21/10/2017
@version 1.0
@return NIL
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
	Local oModel   := FWLoadModel(SOURCEFATHER)
	Local oEvent   := COMA110EVCHI():New()
	Local oStruLoc := oModel:GetModelStruct('SC1DETAIL')[3]:oFormModelStruct 

	oStruLoc:RemoveField("C1_NATUREZ")

	oModel:GetModel("SC1DETAIL"):SetStruct(oStruLoc)
	
	oModel:InstallEvent("COMA110EVCHI",,oEvent)		
	
Return oModel
//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Definição da view para a localização Chile.
@author Luiz Henrique Bourscheid
@since 21/10/2017
@version 1.0
@return NIL
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
	Local oView
	Local oModel    := FWLoadModel( 'COMA110CHI' )
	Local oViewPad  := FWLoadView(SOURCEFATHER)
	Local oStruCab  := oViewPad:GetViewStruct('VIEW_SC1') // Busca Estrutura do padrão
	Local oStruItem := oViewPad:GetViewStruct('VIEW_SC1G')// Busca Estrutura do padrão

	oStruItem:RemoveField('C1_NATUREZ')
	oStruItem:RemoveField('C1_TIPOSOL')
	
	oView := FWFormView():New()
	oView:SetModel(oModel)
	
	oView:AddField('VIEW_SC1' 	 ,  oStruCab , 'SC1MASTER' )
	oView:AddGrid( 'VIEW_SC1G'   ,  oStruItem, 'SC1DETAIL' )
	
	oView:CreateHorizontalBox( 'SUPERIOR', 17 )
	oView:CreateHorizontalBox( 'INFERIOR', 83 )
	
	oView:SetOwnerView( 'VIEW_SC1'	, 'SUPERIOR' )
	oView:SetOwnerView( 'VIEW_SC1G'	, 'INFERIOR' )
	
	oView:AddIncrementField( 'VIEW_SC1G', 'C1_ITEM' )	
	
	oView:SetViewCanActivate({|oView| AddButtons(oView)})
	
Return oView
//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Definição do menu para a localização Chile.
@author Luiz Henrique Bourscheid
@since 21/10/2017
@version 1.0
@return NIL
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
	Local lGspInUseM := If(Type('lGspInUse')=='L', lGspInUse, .F.)
	PRIVATE aRotina	:= {}

	ADD OPTION aRotina TITLE  STR0016       ACTION 'PesqBrw'              OPERATION 1 ACCESS 0                      //Pesquisar
	ADD OPTION aRotina TITLE  STR0017       ACTION 'VIEWDEF.COMA110CHI'   OPERATION MODEL_OPERATION_VIEW   ACCESS 0 //Visualizar
	ADD OPTION aRotina TITLE  STR0018       ACTION 'VIEWDEF.COMA110CHI'   OPERATION MODEL_OPERATION_INSERT ACCESS 0 //Incluir
	ADD OPTION aRotina TITLE  STR0019       ACTION 'VIEWDEF.COMA110CHI'   OPERATION MODEL_OPERATION_UPDATE ACCESS 0 //Alterar
	ADD OPTION aRotina TITLE  STR0020       ACTION 'C110Excl'             OPERATION MODEL_OPERATION_DELETE ACCESS 0 //Excluir
	ADD OPTION aRotina TITLE  STR0021       ACTION 'VIEWDEF.COMA110CHI'   OPERATION 8 ACCESS 0                      //Imprimir
	ADD OPTION aRotina TITLE  STR0022       ACTION 'VIEWDEF.COMA110CHI'   OPERATION 9 ACCESS 0                      //Copiar
	ADD OPTION aRotina TITLE  STR0023       ACTION 'C110Cancela'          OPERATION 6 ACCESS 0                      //Cancelar SCs
	ADD OPTION aRotina TITLE  STR0024       ACTION 'MAComCent'            OPERATION 6 ACCESS 0                      //Compra Centralizada

	If !lGspInUseM
		ADD OPTION aRotina TITLE  STR0025 ACTION 'C110Aprov'     OPERATION MODEL_OPERATION_UPDATE ACCESS 0  //Aprovação
	EndIf	

	If !__lPyme
		ADD OPTION aRotina TITLE  STR0026 ACTION 'MsDocument' OPERATION 4 ACCESS 0  //Conhecimento
	EndIf

	If lMTA110MNU
		ExecBlock("MTA010MNU",.F.,.F.)
	EndIf
Return aRotina