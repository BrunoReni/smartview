#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "CM110.CH"
#INCLUDE "FWMVCDEF.CH"                 
#INCLUDE "FWADAPTEREAI.CH"
#include "TbIconn.ch"
#include "TopConn.ch"

//-------------------------------------------------------------------
/*/{Protheus.doc} CM110APROV
Aprovação de solicitações de compras
@author Leonardo Bratti
@since 23/09/2017
@version 1.0
@return NIL
/*/
//-------------------------------------------------------------------
Function CM110APROV()
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
	
	ADD OPTION aRotina TITLE  STR0001    ACTION 'VIEWDEF.CM110APROV'   OPERATION MODEL_OPERATION_UPDATE ACCESS 0 //Alterar
	
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
	Local oStruSC1   := FWFormStruct(1, 'SC1',{|cCampo| ALLTRIM(cCampo) $ cFieldsSC1 })
	Local oStruSC1G  := FWFormStruct(1, 'SC1',)
	Local lAProvSI 	:= SuperGetMv("MV_APROVSI",.F.,.F.)
		
	oModel := MPFormModel():New('CM110APROV',/*{|oView| PreVldMdl(oView)}*/,)
		
	oModel:AddFields( 'SC1MASTER', /*cOwner*/, oStruSC1  , , )
	oModel:AddGrid( 'SC1DETAIL'  ,'SC1MASTER', oStruSC1G , , , , ,)
	
	oModel:SetPrimaryKey( {'C1_NUM'} ) 
	oModel:SetRelation("SC1DETAIL", {{"C1_FILIAL",'xFilial("SC1")'},{"C1_NUM","C1_NUM"}},SC1->(IndexKey(1)))
	//oModel:GetModel( 'SC1DETAIL' ):SetUseOldGrid( .T. )	
	oModel:SetDescription(STR0079)
	oModel:getModel('SC1MASTER'):SetDescription(STR0031)
	oModel:getModel('SC1DETAIL'):SetDescription(STR0032)

	oModel:GetModel('SC1DETAIL'):SetLoadFilter( { { 'C1_APROV', "{'B','R','L',' '}", MVC_LOADFILTER_IS_CONTAINED } , {'C1_QUJE','0',MVC_LOADFILTER_EQUAL} , ;
	{'C1_RESIDUO',"'"+Space(TAMSX3("C1_RESIDUO")[1])+"'",MVC_LOADFILTER_EQUAL} , {'C1_COTACAO',"'"+Space(TAMSX3("C1_COTACAO")[1])+"'",MVC_LOADFILTER_EQUAL} } )	
		
	If lAProvSI
		oModel:GetModel('SC1DETAIL'):SetLoadFilter( { { 'C1_APROV', "{'B','R','L',' '}", MVC_LOADFILTER_IS_CONTAINED } , {'C1_QUJE','0',MVC_LOADFILTER_EQUAL} , ;
		{'C1_RESIDUO',"'"+Space(TAMSX3("C1_RESIDUO")[1])+"'",MVC_LOADFILTER_EQUAL} , { 'C1_COTACAO',"'"+Space(TAMSX3("C1_COTACAO")[1])+"'" }, { 'C1_COTACAO',"IMPORT",, MVC_LOADFILTER_OR } } )
		
	EndIf	
		
		
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
	Local oModel    := FWLoadModel( 'CM110APROV' )
	Local oStruSC1  := FWFormStruct(2, 'SC1',{|cCampo| ALLTRIM(cCampo) $ cFieldSC1V })
	Local oStruSC1G := FWFormStruct(2, 'SC1')
	
	oView := FWFormView():New()
	oView:SetModel( oModel )
	
	oView:AddField('VIEW_SC1' ,  oStruSC1 , 'SC1MASTER' )
	oView:AddGrid( 'VIEW_SC1G',  oStruSC1G, 'SC1DETAIL' )		
	oView:AddOtherObject("BTN_APROV", {|oButton| C110ADDBT(oButton)})
	
	oView:CreateHorizontalBox( 'SUPERIOR', 19 )
	oView:CreateHorizontalBox( 'MID', 73 )
	oView:CreateHorizontalBox( 'INFERIOR', 8 )
	
	oView:SetOwnerView( 'VIEW_SC1' , 'SUPERIOR' )
	oView:SetOwnerView( 'VIEW_SC1G', 'MID' )
	oView:SetOwnerView( 'BTN_APROV', 'INFERIOR' )
	
	oView:AddIncrementField( 'VIEW_SC1G', 'C1_ITEM' )
	
	oStruSC1G:SetProperty( 'C1_TIPCLEG' , MVC_VIEW_TITULO , ''    )
	oStruSC1G:SetProperty( 'C1_TIPCLEG' , MVC_VIEW_PICT   , '@BMP')
	
	oStruSC1G:RemoveField( 'C1_ITEMPED' )
	oStruSC1G:RemoveField( 'C1_COTACAO' )
	oStruSC1G:RemoveField( 'C1_PEDIDO'  )
	oStruSC1G:RemoveField( 'C1_SOLICIT' )
	oStruSC1G:RemoveField( 'C1_IDENT'   )
	oStruSC1G:RemoveField( 'C1_QUJE'    )
	oStruSC1G:RemoveField( 'C1_TX'      )
	oStruSC1G:RemoveField( 'C1_OK'      )
	oStruSC1G:RemoveField( 'C1_CODCOMP' )
	oStruSC1G:RemoveField( 'C1_NUM_SI'  )
	oStruSC1G:RemoveField( 'C1_QUJE2'   )
	oStruSC1G:RemoveField( 'C1_GRUPCOM' )
	oStruSC1G:RemoveField( 'C1_USER'    )
	oStruSC1G:RemoveField( 'C1_ORIGEM'  )
	oStruSC1G:RemoveField( 'C1_CODGRP'  )
	oStruSC1G:RemoveField( 'C1_CODITE'  )
	oStruSC1G:RemoveField( 'C1_APROV'   )
	oStruSC1G:RemoveField( 'C1_TIPO'    )
	oStruSC1G:RemoveField( 'C1_MOEDA'   )
	oStruSC1G:RemoveField( 'C1_NOMAPRO' )
	oStruSC1G:RemoveField( 'C1_SIGLA'   )
	oStruSC1G:RemoveField( 'C1_QTDREEM' )
	oStruSC1G:RemoveField( 'C1_NOMCOMP' )
	oStruSC1G:RemoveField( 'C1_ACCNUM'  )
	oStruSC1G:RemoveField( 'C1_ACCITEM' )
	oStruSC1G:RemoveField( 'C1_IDAPS'   )
	oStruSC1G:RemoveField( 'C1_COMPRAC' )
	oStruSC1G:RemoveField( 'C1_USRCODE' )
	oStruSC1G:RemoveField( 'C1_PRDREF'  )
	oStruSC1G:RemoveField( 'C1_FILIAL'  )
	oStruSC1G:RemoveField( 'C1_NUM'     )
	oStruSC1G:RemoveField( 'C1_PRECO'   )
	oStruSC1G:RemoveField( 'C1_TOTAL'   )
	oStruSC1G:RemoveField( 'C1_FILENT'  )
	oStruSC1G:RemoveField( 'C1_LOJFABR' )
	oStruSC1G:RemoveField( 'C1_LOJFABR' )
	oStruSC1G:RemoveField( 'C1_FABRICA' )	
	
	oView:SetViewProperty("VIEW_SC1", "ONLYVIEW") 
	oView:SetViewProperty("VIEW_SC1G", "ONLYVIEW")	
		
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

	@2,5   Button STR0014  Size 80,18 Pixel Action {|| BloqSC() }   of oButton
	@2,87  Button STR0080  Size 80,18 Pixel Action {|| LiberaSC() } of oButton
	@2,169 Button STR0013  Size 80,18 Pixel Action {|| RejeitaSC()} of oButton
Return Nil

//----------------------------------------------------------------------
/*/{Protheus.doc} PreVldMdl()
Verifica se existe item a ser alterado no modelo
@author Leonardo Bratti
@since 18/11/2017
@version 1.0
@return .T.
/*/
//----------------------------------------------------------------------
Static Function PreVldMdl(oModel)
	Local oModelGrid := oModel:GetModel('SC1DETAIL')
	Local lRet := .T.	
	lRet := Empty(oModelGrid:getValue("C1_PRODUTO"))
	 If lRet
	 	lRet := .F.
	 	Help( , , 'Help', ,STR0081, 1, 0 )
	 EndIf
Return lRet

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
	Local oModelSC1G := oModel:GetModel('SC1DETAIL')
	Local nX         := 0 
	Local cNumSC     := ''
	Local cItem      := ''
	Local cProduto   := ''
	Local cLocal     := ''
	Local cStatusAnt := ''
	Local aSaveLines := FWSaveRows()
	Local lIntegDef  := FWHasEAI("MATA110",.T.,,.T.)
	Local lSCSldBl   := SuperGetMv("MV_SCSLDBL",.F.,.F.)
	Local lSb1TES    := SuperGetMv("MV_SB1TES",.F.,.F.)
	Local cEntrega  := If(SuperGetMv("MV_PCFILEN"),If(Empty(SC1->C1_FILENT),xFilial("SB2"),SB2->(xFilEnt(SC1->C1_FILENT))),xFilial("SB2"))
	
	If  !(PreVldMdl(oModel))		
		For nX := 1 To oModelSC1G:Length()
			oModelSC1G:Goline(nX)
			cNumSC := oModelSC1G:GetValue("C1_NUM")
			cItem  := oModelSC1G:GetValue("C1_ITEM")
			cProduto := oModelSC1G:GetValue("C1_PRODUTO")
			cLocal   := oModelSC1G:GetValue("C1_LOCAL")
			SC1->(DbSetOrder(1))
			If SC1->(MsSeek(xFilial("SC1")+cNumSC+cItem))
				If !PcoVldLan('000051','02','MATA110',/*lUsaLote*/,/*lDeleta*/, .F./*lVldLinGrade*/)  // valida bloqueio na aprovacao de SC
					Exit
				Endif
				Begin Transaction
					RecLock('SC1', .F.)
					cStatusAnt := SC1->C1_APROV
					If SC1->C1_APROV $ " ,B,R"
						SC1->C1_APROV := "L"
						SC1->C1_NOMAPRO := UsrRetName(RetCodUsr())						
					EndIf
					MsUnlock()				
					If lIntegDef .And. SuperGetMV("MV_MKPLACE",.F.,.F.)
						SB5->(DbSetOrder(1))
						If SB5->(DbSeek( xFilial("SB5") + SC1->C1_PRODUTO ) )
							If SB5->B5_ENVMKT == "1"
								Inclui:=.T.             
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
			EndIf						
		Next nX		
		Aviso(STR0083, STR0082, {STR0086})	
	EndIf
	FWRestRows( aSaveLines )
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
	Local oModelSC1G := oModel:GetModel('SC1DETAIL')
	Local nX         := 0 
	Local cNumSC     := ''
	Local cProduto   := ''
	Local cLocal     := ''
	Local cItem      := ''
	Local cStatusAnt := ''
	Local aSaveLines := FWSaveRows()
	Local lSCSldBl   := SuperGetMv("MV_SCSLDBL",.F.,.F.)
	Local lSb1TES    := SuperGetMv("MV_SB1TES",.F.,.F.)
	Local cEntrega  := If(SuperGetMv("MV_PCFILEN"),If(Empty(SC1->C1_FILENT),xFilial("SB2"),SB2->(xFilEnt(SC1->C1_FILENT))),xFilial("SB2"))
	
	If  !(PreVldMdl(oModel))	
		For nX := 1 To oModelSC1G:Length()
			oModelSC1G:Goline(nX)
			cNumSC   := oModelSC1G:GetValue("C1_NUM")
			cItem    := oModelSC1G:GetValue("C1_ITEM")
			cProduto := oModelSC1G:GetValue("C1_PRODUTO")
			cLocal   := oModelSC1G:GetValue("C1_LOCAL")

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
			EndIf
		Next nX	
		Aviso(STR0085, STR0084, {STR0086})	
	EndIf
	FWRestRows( aSaveLines )	
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
	Local oModelSC1G := oModel:GetModel('SC1DETAIL')
	Local nX         := 0 
	Local cNumSC     := ''
	Local cItem      := ''
	Local cProduto   := ''
	Local cLocal     := ''
	Local cStatusAnt := ''
	Local aSaveLines := FWSaveRows()
	Local lSCSldBl   := SuperGetMv("MV_SCSLDBL",.F.,.F.)
	Local lSb1TES    := SuperGetMv("MV_SB1TES",.F.,.F.)
	Local cEntrega  := If(SuperGetMv("MV_PCFILEN"),If(Empty(SC1->C1_FILENT),xFilial("SB2"),SB2->(xFilEnt(SC1->C1_FILENT))),xFilial("SB2"))
	
	If  !(PreVldMdl(oModel))	
		For nX := 1 To oModelSC1G:Length()
			oModelSC1G:Goline(nX)
			cNumSC := oModelSC1G:GetValue("C1_NUM")
			cItem  := oModelSC1G:GetValue("C1_ITEM")
			cProduto := oModelSC1G:GetValue("C1_PRODUTO")
			cLocal   := oModelSC1G:GetValue("C1_LOCAL")			
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
			EndIf						
		Next nX			
		Aviso(STR0088, STR0087, {STR0086})	
	EndIf
	FWRestRows( aSaveLines )
Return .T.
