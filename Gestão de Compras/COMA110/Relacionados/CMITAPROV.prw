#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "CM110.CH"
#INCLUDE "FWMVCDEF.CH"                 
#INCLUDE "FWADAPTEREAI.CH"
#include "TbIconn.ch"
#include "TopConn.ch"

//-------------------------------------------------------------------
/*/{Protheus.doc} CMITAPROV
Aprovação de item da solicitação de compras
@author Leonardo Bratti
@since 23/09/2017
@version 1.0
@return NIL
/*/
//-------------------------------------------------------------------
Function CMITAPROV()
	Local oBrowse	
	
	oBrowse := BrowseDef()	
	oBrowse:Activate()					   	
Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} BrowseDef
Definição do browse
@author Leonardo Bratti
@since 17/11/2017
@version 1.0
@return oBrowse
/*/
//-------------------------------------------------------------------
Static Function BrowseDef()
	Local oBrowse		
		
	oBrowse := FWMBrowse():New()	
	oBrowse:SetAlias("SC1")		
	oBrowse:SetDescription(STR0079) 		
	
Return oBrowse

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef()
Definicao do Menu
@author Leonardo Bratti
@since 17/11/2017
@version 1.0
@return aRotina (vetor com botoes da EnchoiceBar)
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
	Local aRotina	:= {}
	
	ADD OPTION aRotina TITLE  STR0027    ACTION 'VIEWDEF.SCITAPROV'   OPERATION MODEL_OPERATION_UPDATE ACCESS 0 //Alterar
	
Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef()
Definicao do Modelo
@author Leonardo Bratti
@since 17/11/2017
@version 1.0
@return oModel
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
	Local oModel
	Local oStruSC1   := FWFormStruct(1, 'SC1',{|cCampo| ALLTRIM(cCampo) $ cFieldsSC1+"|C1_ITEM|C1_PRODUTO|C1_UM|C1_QUANT|C1_SEGUM|C1_QTSEGUM|C1_LOCAL" })
		
	oModel := MPFormModel():New('CMITAPROV', ,)
		
	oModel:AddFields( 'SC1MASTER', /*cOwner*/, oStruSC1  , , )
	
	oModel:SetPrimaryKey( {'C1_NUM'} ) 
	
	oModel:SetDescription(STR0079)
	oModel:getModel('SC1MASTER'):SetDescription(STR0032)
	
Return oModel

//--------------------------------------------------------------------
/*/{Protheus.doc} ViewDef()
Definicao da View
@author Leonardo Bratti
@since 17/11/2017
@version 1.0
@return oView
/*/
//--------------------------------------------------------------------
Static Function ViewDef()	

	Local oView
	Local oModel    := FWLoadModel( 'CMITAPROV' )
	Local oStruSC1  := FWFormStruct(2, 'SC1',{|cCampo| ALLTRIM(cCampo) $ cFieldSC1V+"|C1_ITEM|C1_PRODUTO|C1_UM|C1_QUANT|C1_SEGUM|C1_QTSEGUM" })

	oStruSC1:SetProperty( 'C1_NUM'     , MVC_VIEW_ORDEM ,'01')
	oStruSC1:SetProperty( 'C1_SOLICIT' , MVC_VIEW_ORDEM ,'02')
	oStruSC1:SetProperty( 'C1_UNIDREQ' , MVC_VIEW_ORDEM ,'03')
	oStruSC1:SetProperty( 'C1_CODCOMP' , MVC_VIEW_ORDEM ,'04')
	oStruSC1:SetProperty( 'C1_ITEM'    , MVC_VIEW_ORDEM ,'05')
	oStruSC1:SetProperty( 'C1_PRODUTO' , MVC_VIEW_ORDEM ,'06')
	oStruSC1:SetProperty( 'C1_UM'      , MVC_VIEW_ORDEM ,'07')
	oStruSC1:SetProperty( 'C1_QUANT'   , MVC_VIEW_ORDEM ,'08')
	oStruSC1:SetProperty( 'C1_SEGUM'   , MVC_VIEW_ORDEM ,'09')
	oStruSC1:SetProperty( 'C1_QTSEGUM' , MVC_VIEW_ORDEM ,'10')
	oStruSC1:SetProperty( 'C1_EMISSAO' , MVC_VIEW_ORDEM ,'11')
	oStruSC1:SetProperty( 'C1_FILENT'  , MVC_VIEW_ORDEM ,'12')
	
	oStruSC1:AddGroup( 'GRUPO01', STR0089 , '', 2 )
	oStruSC1:SetProperty( '*' , MVC_VIEW_GROUP_NUMBER, 'GRUPO01' )
	
	oView := FWFormView():New()
	oView:SetModel( oModel )
	
	oView:AddField('VIEW_SC1' ,  oStruSC1 , 'SC1MASTER' )	
	oView:AddOtherObject("BTN_APROV", {|oButton| C110ADDBT(oButton)})
	
	oView:CreateHorizontalBox( 'SUPERIOR', 7 )
	oView:CreateHorizontalBox( 'INFERIOR', 93 )
	
	oView:SetOwnerView( 'BTN_APROV' , 'SUPERIOR' )
	oView:SetOwnerView( 'VIEW_SC1', 'INFERIOR' )
	
	
Return oView

//----------------------------------------------------------------------
/*/{Protheus.doc} C110ADDBT()
Adicionas os botões na tela
@author Leonardo Bratti
@since 18/11/2017
@version 1.0
@return .T.
/*/
//----------------------------------------------------------------------
Static Function C110ADDBT(oButton)
	Local oModel := FWModelActive()

	@3,5   Button STR0077  Size 80,18 Pixel Action {|| BloqSC() }   of oButton
	@3,87  Button STR0080  Size 80,18 Pixel Action {|| LiberaSC() } of oButton
	@3,169 Button STR0076  Size 80,18 Pixel Action {|| RejeitaSC()} of oButton
Return Nil

//----------------------------------------------------------------------
/*/{Protheus.doc} LiberaSC()
Aprova SC
@author Leonardo Bratti
@since 18/11/2017
@version 1.0
@return .T.
/*/
//----------------------------------------------------------------------
Static Function LiberaSC()
	Local oModel     := FWModelActive()	
	Local oModelSC1  := oModel:GetModel('SC1MASTER')
	Local nX         := 0 
	Local cNumSC     := ''
	Local cItem      := ''
	Local cProduto   := ''
	Local cLocal     := ''
	Local cStatusAnt := ''
	Local lIntegDef  := FWHasEAI("MATA110",.T.,,.T.)
	Local lSCSldBl   := SuperGetMv("MV_SCSLDBL",.F.,.F.)
	Local lSb1TES    := SuperGetMv("MV_SB1TES",.F.,.F.)
	Local cEntrega   := If(SuperGetMv("MV_PCFILEN"),If(Empty(SC1->C1_FILENT),xFilial("SB2"),SB2->(xFilEnt(SC1->C1_FILENT))),xFilial("SB2"))	
	
	cNumSC   := oModelSC1:GetValue("C1_NUM")
	cItem    := oModelSC1:GetValue("C1_ITEM")
	cProduto := oModelSC1:GetValue("C1_PRODUTO")
	cLocal   := oModelSC1:GetValue("C1_LOCAL")
	SC1->(DbSetOrder(1))
	If SC1->(MsSeek(xFilial("SC1")+cNumSC+cItem))
		If !PcoVldLan('000051','02','MATA110',/*lUsaLote*/,/*lDeleta*/, .F./*lVldLinGrade*/)  // valida bloqueio na aprovacao de SC
			Return
		Endif
		Begin Transaction
			RecLock('SC1', .F.)
			cStatusAnt := SC1->C1_APROV
			If SC1->C1_APROV $ " ,B,R"
				SC1->C1_APROV   := "L"
				SC1->C1_NOMAPRO := UsrRetName(RetCodUsr())						
			EndIf
			MsUnlock()				
			If lIntegDef .And. SuperGetMV("MV_MKPLACE",.F.,.F.)
				SB5->(DbSetOrder(1))
				If SB5->(DbSeek( xFilial("SB5") + SC1->C1_PRODUTO ) )
					If SB5->B5_ENVMKT == "1"
						Inclui := .T.             
						SetRotInteg('MATA110' )
						FwIntegDef( 'MATA110' )
					EndIf
				EndIf
			EndIf
			If lSCSldBl .And. cStatusAnt $ "B*R"
				dbSelectArea("SB2")
				SB2->(dbSetOrder(1))
				If !msSeek(cEntrega+cProduto+cLocal) 
					CriaSB2(SC1->C1_PRODUTO,SC1->C1_LOCAL,cEntrega)
				EndIf
				If SC1->(FieldPos("C1_ESTOQUE")) > 0 .And. lSb1TES
					If SC1->C1_ESTOQUE=="S" .Or.  Empty(SC1->C1_ESTOQUE)
						GravaB2Pre("+",SC1->C1_QUANT-SC1->C1_QUJE,SC1->C1_TPOP,SC1->C1_QTSEGUM-SC1->C1_QUJE2)
					EndIf
				Else 
					GravaB2Pre("+",SC1->C1_QUANT-SC1->C1_QUJE,SC1->C1_TPOP,SC1->C1_QTSEGUM-SC1->C1_QUJE2)
				EndIf
			EndIf
		End Transaction
		Aviso(STR0083, STR0082, {STR0086})					
	EndIf								
	
Return .T.

//----------------------------------------------------------------------
/*/{Protheus.doc} RejeitaSC()
Rejeita SC
@author Leonardo Bratti
@since 20/11/2017
@version 1.0
@return .T.
/*/
//----------------------------------------------------------------------
Static Function RejeitaSC()
	Local oModel     := FWModelActive()	
	Local oModelSC1  := oModel:GetModel('SC1MASTER')
	Local nX         := 0 
	Local cNumSC     := ''
	Local cProduto   := ''
	Local cLocal     := ''
	Local cItem      := ''
	Local cStatusAnt := ''
	Local lSCSldBl   := SuperGetMv("MV_SCSLDBL",.F.,.F.)
	Local lSb1TES    := SuperGetMv("MV_SB1TES",.F.,.F.)
	Local cEntrega   := If(SuperGetMv("MV_PCFILEN"),If(Empty(SC1->C1_FILENT),xFilial("SB2"),SB2->(xFilEnt(SC1->C1_FILENT))),xFilial("SB2"))
	
	cNumSC   := oModelSC1:GetValue("C1_NUM")
	cItem    := oModelSC1:GetValue("C1_ITEM")
	cProduto := oModelSC1:GetValue("C1_PRODUTO")
	cLocal   := oModelSC1:GetValue("C1_LOCAL")

	SC1->(DbSetOrder(1))
	If SC1->(MsSeek(xFilial("SC1")+cNumSC+cItem))
		RecLock('SC1', .F.)
		cStatusAnt := SC1->C1_APROV
		If SC1->C1_APROV $ "B,L, "
		   SC1->C1_APROV := "R"
		   SC1->C1_NOMAPRO := UsrRetName(RetCodUsr())
		EndIf
		MsUnlock()				
		LancaPCO("SC1","000051","02","MATA110",.T.)	
		dbSelectArea("SB2")
		SB2->(dbSetOrder(1))
		If ( !MsSeek(cEntrega+cProduto+cLocal) )
			CriaSB2(SC1->C1_PRODUTO,SC1->C1_LOCAL,cEntrega)
		EndIf
		If lSCSldBl .And. cStatusAnt $ "L* "
			If SC1->(FieldPos("C1_ESTOQUE")) > 0 .And. lSb1TES
			   	If SC1->C1_ESTOQUE=="S" .Or.  Empty(SC1->C1_ESTOQUE)  
					GravaB2Pre("-",SC1->C1_QUANT-SC1->C1_QUJE,SC1->C1_TPOP,SC1->C1_QTSEGUM-SC1->C1_QUJE2)
				EndIf
			Else 
				GravaB2Pre("-",SC1->C1_QUANT-SC1->C1_QUJE,SC1->C1_TPOP,SC1->C1_QTSEGUM-SC1->C1_QUJE2)
			EndIf
		EndIf			
		Aviso(STR0085, STR0084, {STR0086})	
	EndIf
Return .T.

//----------------------------------------------------------------------
/*/{Protheus.doc} BloqSC()
Bloqueia a  SC
@author Leonardo Bratti
@since 20/11/2017
@version 1.0
@return .T.
/*/
//----------------------------------------------------------------------
Static Function BloqSC()
	Local oModel     := FWModelActive()	
	Local oModelSC1  := oModel:GetModel('SC1MASTER')
	Local nX         := 0 
	Local cNumSC     := ''
	Local cItem      := ''
	Local cProduto   := ''
	Local cLocal     := ''
	Local cStatusAnt := ''
	Local lSCSldBl   := SuperGetMv("MV_SCSLDBL",.F.,.F.)
	Local lSb1TES    := SuperGetMv("MV_SB1TES",.F.,.F.)
	Local cEntrega  := If(SuperGetMv("MV_PCFILEN"),If(Empty(SC1->C1_FILENT),xFilial("SB2"),SB2->(xFilEnt(SC1->C1_FILENT))),xFilial("SB2"))
		
	cNumSC   := oModelSC1:GetValue("C1_NUM")
	cItem    := oModelSC1:GetValue("C1_ITEM")
	cProduto := oModelSC1:GetValue("C1_PRODUTO")
	cLocal   := oModelSC1:GetValue("C1_LOCAL")	
			
	SC1->(DbSetOrder(1))
	If SC1->(MsSeek(xFilial("SC1")+cNumSC+cItem))
		RecLock('SC1', .F.)
		cStatusAnt := SC1->C1_APROV
		If SC1->C1_APROV $ " ,L,R"
		   SC1->C1_APROV := "B"
		   SC1->C1_NOMAPRO := UsrRetName(RetCodUsr())
		EndIf
		MsUnlock()			
		LancaPCO("SC1","000051","02","MATA110",.T.)
		dbSelectArea("SB2")
		SB2->(DbSetOrder(1))
		If !(MsSeek(cEntrega+cProduto+cLocal)) 
			CriaSB2(SC1->C1_PRODUTO,SC1->C1_LOCAL,cEntrega)
		EndIf
		If lSCSldBl .And. cStatusAnt $ "L* "
			If SC1->(FieldPos("C1_ESTOQUE")) > 0 .And. lSb1TES
			   	If SC1->C1_ESTOQUE=="S" .Or.  Empty(SC1->C1_ESTOQUE)  
					GravaB2Pre("-",SC1->C1_QUANT-SC1->C1_QUJE,SC1->C1_TPOP,SC1->C1_QTSEGUM-SC1->C1_QUJE2)
				EndIf
			Else 
				GravaB2Pre("-",SC1->C1_QUANT-SC1->C1_QUJE,SC1->C1_TPOP,SC1->C1_QTSEGUM-SC1->C1_QUJE2)
			EndIf
		EndIf			
		Aviso(STR0088, STR0087, {STR0086})	
	EndIf
Return .T.
