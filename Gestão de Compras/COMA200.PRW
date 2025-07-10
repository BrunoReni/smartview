#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "COMA200.CH"

//-------------------------------------------------------------------
/*{Protheus.doc} COMA200
Cadastro de Tipo de Compra

@author Flavio Lopes Rasta
@since 25/08/2015
@version 12
*/
//-------------------------------------------------------------------
Function COMA200()
Local oBrowse		:= Nil
Private aRotina := Menudef()

oBrowse := FWMBrowse():New()
oBrowse:SetAlias('DHK')
oBrowse:SetDescription(STR0008) // 'Tipos de Compra'
oBrowse:Activate()

Return

//-------------------------------------------------------------------
/*{Protheus.doc} MenuDef()
Menu Funcional

@author Flavio Lopes Rasta
@since 25/08/2015
@version 12
*/
//-------------------------------------------------------------------
Static Function MenuDef()  
Local aRotina := {}

ADD OPTION aRotina Title STR0001 Action 'CM200INCLUI()' 	OPERATION 3 ACCESS 0 // "Incluir"
ADD OPTION aRotina Title STR0006 Action 'CM200Altera()' 	OPERATION 4 ACCESS 0 // "Alterar"
ADD OPTION aRotina Title STR0002 Action 'VIEWDEF.COMA200'	OPERATION 5 ACCESS 0 // "Excluir"
ADD OPTION aRotina Title STR0003 Action 'VIEWDEF.COMA200'	OPERATION 2 ACCESS 0 // "Visualizar"

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef()
Definicao do Modelo
@author Flavio Lopes Rasta
@since 25/08/2015
@version 12
@return oModel
/*/
//-------------------------------------------------------------------
Static Function ModelDef()  
Local oModel   := Nil 
Local oStruDHK	:= FWFormStruct(1,"DHK") 

oModel:= MPFormModel():New('COMA200', /*Pre-Validacao*/,{|oModel| CM200PosVl(oModel)},/*Commit*/,/*Cancel*/)

oModel:AddFields("DHKMASTER",,oStruDHK)

oModel:SetPrimaryKey( {} ) //Obrigatorio setar a chave primaria (mesmo que vazia)

Return oModel 

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef()
Definicao da View
@author Flavio Lopes Rasta
@since 25/08/2015
@version 12
@return oModel
/*/
//-------------------------------------------------------------------
Static Function ViewDef()  
Local oModel	:= FWLoadModel( 'COMA200' ) 
Local oStruDHK	:= FWFormStruct(2,"DHK")  
Local oView		:= FWFormView():New()
Local lInclui	:= IsInCallStack('CM200Inclui')
Local lAltera	:= IsInCallStack('CM200Altera')

oView:SetModel(oModel)  

oView:AddField("VIEW_DHK",oStruDHK,"DHKMASTER")  
oView:CreateHorizontalBox("CABEC",100)
oView:SetOwnerView("VIEW_DHK","CABEC")

If lInclui .OR. lAltera
	oView:AddUserButton(STR0004, 'CLIPS', {|oView|  CM200GrvEx(oModel,'DHK_SOLCOM','SC1')}) //'Condição SC'
	oView:AddUserButton(STR0005, 'CLIPS', {|oView|  CM200GrvEx(oModel,'DHK_PEDCOM','SC7')}) //'Condição PC'
Endif

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} CM200Inclui(oModel)
Rotina de inclusão do tipo de compra

@author Flavio Lopes Rasta
@param oModel Modelo ativo
@return Nil
@since 13/09/2013
@version 1.0
/*/
//------------------------------------------------------------------

Function CM200Inclui()

FWExecView(STR0001, "COMA200", MODEL_OPERATION_INSERT ,/*oDlg*/ , {||.T.},/*bOk*/ ,/*nPercReducao*/ ,/*aEnableButtons*/ ,  /*bCancel*/ ) // "Incluir"

Return Nil

//------------------------------------------------------------------
/*/{Protheus.doc} CM200Altera()
Rotina de Alteração do tipo de compra

@author Flavio Lopes Rasta
@param oModel Modelo ativo
@return Nil
@since 13/09/2013
@version 1.0
/*/
//------------------------------------------------------------------

Function CM200Altera()

FWExecView(STR0006, "COMA200", MODEL_OPERATION_UPDATE ,/*oDlg*/ , {||.T.},/*bOk*/ ,/*nPercReducao*/ ,/*aEnableButtons*/ ,  /*bCancel*/ ) // "Alterar"

Return Nil


//-------------------------------------------------------------------
/*/{Protheus.doc} CM200ScApE()
Valid do campo de Aprovação especial SC
@author Flavio Lopes Rasta
@since 25/08/2015
@version 12
@return lRet
/*/
//-------------------------------------------------------------------
Function CM200ScApE()
Local lRet 		:= .T.
Local oModel 	:= FwModelActive()
Local oModelDHK := oModel:GetModel('DHKMASTER')

If !oModelDHK:GetValue('DHK_APROVE')
	oModelDHK:LoadValue('DHK_APROVP',.T.)
EndIf
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} CM200ScApP()
Valid do campo de Aprovação Padrão SC
@author Flavio Lopes Rasta
@since 25/08/2015
@version 12
@return lRet
/*/
//-------------------------------------------------------------------
Function CM200ScApP()
Local lRet 		:= .T.
Local oModel 	:= FwModelActive()
Local oModelDHK := oModel:GetModel('DHKMASTER')

If !oModelDHK:GetValue('DHK_APROVP')
	oModelDHK:LoadValue('DHK_APROVE',.T.)
EndIf
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} CM200ScApE()
Valid do campo de Aprovação especial PC
@author Flavio Lopes Rasta
@since 25/08/2015
@version 12
@return lRet
/*/
//-------------------------------------------------------------------
Function CM200PcApE()
Local lRet 		:= .T.
Local oModel 	:= FwModelActive()
Local oModelDHK := oModel:GetModel('DHKMASTER')

If !oModelDHK:GetValue('DHK_PAPRES')
	oModelDHK:LoadValue('DHK_PAPRPA',.T.)
EndIf
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} CM200ScApP()
Valid do campo de Aprovação Padrão PC
@author Flavio Lopes Rasta
@since 25/08/2015
@version 12
@return lRet
/*/
//-------------------------------------------------------------------
Function CM200PcApP()
Local lRet 		:= .T.
Local oModel 	:= FwModelActive()
Local oModelDHK := oModel:GetModel('DHKMASTER')

If !oModelDHK:GetValue('DHK_PAPRPA')
	oModelDHK:LoadValue('DHK_PAPRES',.T.)
EndIf
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} CM200GrvEx()
Função de criação do Objeto de expressão para SC e PC
@author Flavio Lopes Rasta
@since 25/08/2015
@version 12
@return lRet
/*/
//-------------------------------------------------------------------
Function CM200GrvEx(oModel,cCampo,cTab)
	Local oView 	:= FwViewActive()
	Local oModelDHK := oModel:GetModel('DHKMASTER')
	Local oFWFilter := FWFilter():New(GetWndDefault())
	Local cFiltro	:= ""
	Local cCondTpCom:= ""
	Local nPos		:= 0
	Local aDlgFields:= {}
	Local aExpNot	:= {"%","#","**","^"}
	Local lOk		:= .T.
	Local aCamposNUs:= {}
	Local aCpoCabC1	:= {"C1_NUM","C1_SOLICIT","C1_EMISSAO","C1_UNIDREQ","C1_CODCOMP","C1_FILENT"}
	Local aCpoCabC7	:= {"C7_NUM","C7_EMISSAO","C7_FORNECE","C7_LOJA","C7_COND","C7_CONTATO","C7_FILENT","C7_MOEDA","C7_TXMOEDA"}
	Local aNotCpo	:= {"C1_FILIAL","C1_TIPCLEG","C7_FILIAL","C7_TIPCLEG"}
	Local aCpoFilter:= {}
	PRIVATE aHeader := {}
	PRIVATE N       := 1
	PRIVATE aCols   := {}
	PRIVATE oGrade	:= NIL
	
	DbSelectArea(cTab)
	oFWFilter:SetAlias(cTab)
	oFWFilter:SetProfileID("CM200GrvEx")
	DbSelectArea("SX3")
	SX3->(DbSetOrder(1))
	SX3->(MsSeek(cTab))
	While ( SX3->(!EOF()) .And. SX3->X3_ARQUIVO == cTab )
		If (X3USO(SX3->X3_USADO) .AND. cNivel >= SX3->X3_NIVEL .And. (aScan(aNotCpo,{|x| AllTrim(x) == AllTrim(SX3->X3_CAMPO)}) == 0)) .Or. ;
			(cTab == "SC1" .And. (aScan(aCpoCabC1,{|x| AllTrim(x) == AllTrim(SX3->X3_CAMPO)}) > 0)) .Or. ;
			(cTab == "SC7" .And. (aScan(aCpoCabC7,{|x| AllTrim(x) == AllTrim(SX3->X3_CAMPO)}) > 0))
			aAdd(aHeader,{ TRIM(X3Titulo()),;
				SX3->X3_CAMPO,;
				SX3->X3_PICTURE,;
				SX3->X3_TAMANHO,;
				SX3->X3_DECIMAL,;
				SX3->X3_VALID,;
				SX3->X3_USADO,;
				SX3->X3_TIPO,;
				SX3->X3_F3,;
				SX3->X3_CONTEXT })
 
			aAdd(aCpoFilter,{SX3->X3_CAMPO,;
							TRIM(X3Titulo()),;
							SX3->X3_TIPO,;
							SX3->X3_TAMANHO,;
							SX3->X3_DECIMAL,;
							SX3->X3_PICTURE,;
							,,,})
		Else
			aAdd(aCamposNUs,SX3->X3_CAMPO) 
		EndIf
		SX3->(dbSkip())
	EndDo
		
	aCols:= Array(1,Len(aHeader)+1)
	aCols[1,Len(aHeader)+1] := .F.
     
	If cTab =="SC1"	
		aAdd(aDlgFields,{"C1_NUM","cA110Num"}) 
	Else				
		aAdd(aDlgFields,{"C7_NUM","cA120Num"})
	EndIf
	oFwFilter:LoadFilter()
	oFwFilter:SetField(aCpoFilter)
	If oFWFilter:FilterBar()
		cFiltro	:= oFWFilter:GetExprADVPL()
		cFiltro := StrTran(cFiltro,"[0]","[1]")
			
		//-- Avalia expressões não permitidas
		If lOk .And. !EMPTY(cFiltro)
			For nPos := 1 To Len(aExpNot)
				If  ALLTRIM(Upper (aExpNot[nPos])) $ ALLTRIM(Upper(cFiltro))				
					lOk     := .F.
					cFiltro := ""
					EXIT 		
				EndIf
			Next nPos
		EndIf
		
		//-- Avalia campos não permitidos
		If lOk .And. !EMPTY(cFiltro)
			For nPos := 1 to Len(aCamposNUs)
				If ALLTRIM(Upper (aCamposNUs[nPos])) $ ALLTRIM(Upper(cFiltro))
					lOk     := .F.
					cFiltro := ""
					EXIT
				EndIf
			Next nPos
		EndIf
		
		If lOk
			cCondTpCom := MTAjustExp(cFiltro,aDlgFields,,.T.)
		Endif
		
		//-- Processa a expressão
		If lOk .And. MTExecExp(cCondTpCom,.T.) 	
			oModelDHK:SetValue(cCampo,cFiltro)
		Else 
			Help(,, "CM200GrvEx",, STR0009, 1, 0,,,,,,{STR0010}) // Str0009 "A pesquisa não aceita campos classificados como não usados e expressões advpl"
			 													 // Str0010 "não utilizar campos não usados, funções Advpl e as expressões ('$','%','#','**','^')"
		EndIf		
		
		oView:SetModified(.T.)
	EndIf

	oFWFilter:CleanFilter()
	oFWFilter:DeActivate()
	
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} CM200PosVl()
Função de criação do Objeto de expressão para pedido de compra
@author Flavio Lopes Rasta
@since 25/08/2015
@version 12
@return lRet
/*/
//-------------------------------------------------------------------
Function CM200PosVl(oModel)
Local lRet 		:= .T.
Local oModelDHK	:= oModel:GetModel("DHKMASTER")

If Empty(oModelDHK:GetValue("DHK_SOLCOM")) .And. Empty(oModelDHK:GetValue("DHK_PEDCOM"))
	Help(" ",1,"COMA200EXPCOM",,STR0007,4,1) // "É necessário preencher ao menos uma condição (Solicitação ou Pedido de compra)"
	lRet:= .F.
Endif
 
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} CM200TolLb()
Valid do campo de Libreação automatica do Pedido
@author Flavio Lopes Rasta
@since 15/09/2015
@version 12
@return lRet
/*/
//-------------------------------------------------------------------
Function CM200TolLb()
Local lRet 		:= .T.
Local oModel 	:= FwModelActive()
Local oModelDHK := oModel:GetModel('DHKMASTER')

If !oModelDHK:GetValue('DHK_LIBPC')
	oModelDHK:LoadValue('DHK_TOLERA',.F.)
	oModelDHK:LoadValue('DHK_TOLDFS',0)
EndIf
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} CM200Esc()
Valid dos campos de Escalonamento
@author Rafael Duram Santos
@since 09/09/2019
@version 12
@return lRet
/*/
//-------------------------------------------------------------------
Function CM200Esc()
Local lRet 		:= .T.
Local oModel 	:= FwModelActive()
Local oModelDHK := oModel:GetModel('DHKMASTER')
Local cCampo	:= ReadVar()

If 'DHK_ESCALO' $ cCampo .And. !oModelDHK:GetValue('DHK_ESCALO')
	oModelDHK:LoadValue('DHK_ESCTSC',.F.)
Elseif 'DHK_ESCALP' $ cCampo .And. !oModelDHK:GetValue('DHK_ESCALP')
	oModelDHK:LoadValue('DHK_ESCTPC',.F.)
Elseif 'DHK_ESCTPC' $ cCampo .And. oModelDHK:GetValue('DHK_ESCTPC')
	oModelDHK:LoadValue('DHK_ESCALP',.T.)
Elseif 'DHK_ESCTSC' $ cCampo .And. oModelDHK:GetValue('DHK_ESCTSC')
	oModelDHK:LoadValue('DHK_ESCALO',.T.)
Endif


Return lRet

//-------------------------------------------------------------------
