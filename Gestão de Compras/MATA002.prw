#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "MATA002.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} MATA002()
Cadastro dos Campos da Amarracao Tipo de Operacao X CFOP
@author Bruno Schmidt
@since 22/04/2015
@version 1.0
@return NIL
/*/
//-------------------------------------------------------------------
Function MATA002() 
 
Local oBrowse

Private cAlias002	:= ""
Private lIntLogix	:= A002LOGIX()

If lIntLogix
	cAlias002 := "DHO"
Else
	cAlias002 := "DHJ"
Endif  

If cPaisLoc == "BRA"
	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias(cAlias002)                                          
	oBrowse:SetDescription(STR0001) 
	oBrowse:Activate()
EndIf

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef()
Definicao do Menu
@author Bruno Schmidt
@since 22/04/2015
@version 1.0
@return aRotina (vetor com botoes da EnchoiceBar)
/*/
//-------------------------------------------------------------------
Static Function MenuDef()  

Local aRotina := {} //Array utilizado para controlar opcao selecionada

aAdd(aRotina,{STR0002,"PesqBrw"			,0,1,NIL})//"Pesquisar"
aAdd(aRotina,{STR0003,"VIEWDEF.MATA002"	,0,2,NIL})//"Visualizar"
aAdd(aRotina,{STR0004,"VIEWDEF.MATA002"	,0,3,NIL})//"Incluir"
aAdd(aRotina,{STR0005,"VIEWDEF.MATA002"	,0,4,NIL})//"Alterar"
aAdd(aRotina,{STR0006,"VIEWDEF.MATA002"	,0,5,NIL})//"Excluir"

Return aRotina


//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef()
Definicao do Modelo
@author Bruno Schmidt
@since 22/04/2015
@version 1.0
@return oModel
/*/
//-------------------------------------------------------------------
Static Function ModelDef()  

Local oStruCab	:= Nil 
Local oStruGrid	:= Nil
Local oModel  	:= Nil //Modelo de Dados MVC

If Type("cAlias002") == "U"
	cAlias002 := ""
Endif

If Type("lIntLogix") == "U"
	lIntLogix := A002LOGIX()
Endif

If lIntLogix
	cAlias002 := "DHO"
Else
	cAlias002 := "DHJ"
Endif

If (cAlias002)->(ColumnPos(cAlias002+"_TPOPSA")) > 0 .And. (cAlias002)->(ColumnPos(cAlias002+"_DESTPS")) > 0
	oStruCab	:= FWFormStruct(1,cAlias002,{|cCampo| AllTrim(cCampo) $ cAlias002+"_TPOP|" + cAlias002+"_DESCTP|" + cAlias002+"_TPOPSA|" + cAlias002+"_DESTPS" }) //Estrutura Cabecalho Matriz Abastecimento 
	oStruGrid	:= FWFormStruct(1,cAlias002,{|cCampo| !(AllTrim(cCampo) $ cAlias002+"_TPOP|" + cAlias002+"_DESCTP|" + cAlias002+"_TPOPSA|" + cAlias002+"_DESTPS")})//Estrutura Itens Matriz Abastecimento
Else
	oStruCab	:= FWFormStruct(1,cAlias002,{|cCampo| AllTrim(cCampo) $ cAlias002+"_TPOP|" + cAlias002+"_DESCTP" }) //Estrutura Cabecalho Matriz Abastecimento 
	oStruGrid	:= FWFormStruct(1,cAlias002,{|cCampo| !(AllTrim(cCampo) $ cAlias002+"_TPOP|" + cAlias002+"_DESCTP")})//Estrutura Itens Matriz Abastecimento	
Endif

If cPaisLoc == "BRA"
	//------------------------------------------------------
	//        Cria a estrutura basica
	//------------------------------------------------------
	oModel:= MPFormModel():New("MATA002", /*Pre-Validacao*/,/*Pos-Validacao*/,/*Commit*/,/*Cancel*/)
	
	//------------------------------------------------------
	//        Adiciona o componente de formulario no model 
	//     Nao sera usado, mas eh obrigatorio ter
	//------------------------------------------------------    
	oModel:AddFields("DHJMASTER",/*cOwner*/,oStruCab)
	oModel:AddGrid("DHJDETAILS","DHJMASTER",oStruGrid)
	
	//--------------------------------------
	//        Configura o model
	//--------------------------------------
	oModel:SetPrimaryKey( {} ) //Obrigatorio setar a chave primaria (mesmo que vazia)
	
	If lIntLogix
		oModel:SetRelation("DHJDETAILS",{{"DHO_FILIAL",'xFilial("DHO")'},{"DHO_TPOP","DHO_TPOP"}},DHO->(IndexKey(1)))
		oModel:GetModel("DHJDETAILS"):SetUniqueLine({"DHO_CFOP","DHO_CUSTOM","DHO_SERIE"})
	Else
		If (cAlias002)->(ColumnPos(cAlias002+"_TPOPSA")) > 0 .And. (cAlias002)->(ColumnPos(cAlias002+"_DESTPS")) > 0
			oModel:SetRelation("DHJDETAILS",{{"DHJ_FILIAL",'xFilial("DHJ")'},{"DHJ_TPOP","DHJ_TPOP"},{"DHJ_TPOPSA","DHJ_TPOPSA"}},DHJ->(IndexKey(1)))
		EndIf
		oModel:GetModel("DHJDETAILS"):SetUniqueLine({"DHJ_CFOP"})
	Endif
EndIf

Return oModel 


//--------------------------------------------------------------------
/*/{Protheus.doc} ViewDef()
Definicao da View
@author Bruno Schmidt
@since 22/04/2015
@version 1.0
@return oView
/*/
//--------------------------------------------------------------------
Static Function ViewDef()  

Local oModel	:= FWLoadModel( "MATA002" )     //Carrega model definido
Local oStruCab	:= Nil 
Local oStruGrid	:= Nil
Local oView		:= FWFormView():New()

If Type("cAlias002") == "U"
	cAlias002 := ""
Endif

If Type("lIntLogix") == "U"
	lIntLogix := A002LOGIX()
Endif

If lIntLogix
	cAlias002 := "DHO"
Else
	cAlias002 := "DHJ"
Endif

If (cAlias002)->(ColumnPos(cAlias002+"_TPOPSA")) > 0 .And. (cAlias002)->(ColumnPos(cAlias002+"_DESTPS")) > 0
	oStruCab	:= FWFormStruct(2,cAlias002,{|cCampo| AllTrim(cCampo) $ cAlias002+"_TPOP|" + cAlias002+"_DESCTP|" + cAlias002+"_TPOPSA|" + cAlias002+"_DESTPS"}) //Estrutura Cabecalho Matriz Abastecimento  
	oStruGrid	:= FWFormStruct(2,cAlias002,{|cCampo| !(AllTrim(cCampo) $ cAlias002+"_TPOP|" + cAlias002+"_DESCTP|" + cAlias002+"_TPOPSA|" + cAlias002+"_DESTPS")})//Estrutura Itens Matriz Abastecimento
Else
	oStruCab	:= FWFormStruct(2,cAlias002,{|cCampo| AllTrim(cCampo) $ cAlias002+"_TPOP|" + cAlias002+"_DESCTP"}) //Estrutura Cabecalho Matriz Abastecimento  
	oStruGrid	:= FWFormStruct(2,cAlias002,{|cCampo| !(AllTrim(cCampo) $ cAlias002+"_TPOP|" + cAlias002+"_DESCTP")})//Estrutura Itens Matriz Abastecimento	
Endif

//--------------------------------------
//        Associa o View ao Model
//--------------------------------------
oView:SetModel(oModel)  //-- Define qual o modelo de dados será utilizado
oView:SetUseCursor(.F.) //-- Remove cursor de registros'

//--------------------------------------
//      Insere os componentes na view
//--------------------------------------
oView:AddField("MASTER_DHJ",oStruCab,"DHJMASTER")   //Cabecalho da matriz de abastecimento
oView:AddGrid("DETAILS_DHJ",oStruGrid,"DHJDETAILS")      //Itens da matriz de abastecimento

//--------------------------------------
//        Cria os Box's
//--------------------------------------
oView:CreateHorizontalBox("CABEC",20)
oView:CreateHorizontalBox("GRID",80)

//--------------------------------------
//        Associa os componentes
//--------------------------------------
oView:SetOwnerView("MASTER_DHJ","CABEC")
oView:SetOwnerView("DETAILS_DHJ","GRID")

Return oView

//--------------------------------------------------------------------
/*/{Protheus.doc} A002LOGIX()
Valida se esta habilitada busca pela TES inteligente acrescentando os 
campos DHJ_CUSTOM + DHJ_SERIE + DHJ_FLAG

Obs: Deve ser utilizado apenas com a integração Logix x Protheus
@author Rodrigo M Pontes
@since 08/12/2017
@version 1.0
@return lRet
/*/
//--------------------------------------------------------------------

Function A002LOGIX()

Local lRet			:= .F.
Local lTesLogix	:= SuperGetMv("MV_TESLOGI",.F.,.F.)
Local lDHO			:= AliasInDic("DHO")
Local lCpoCustom	:= .F.
Local lCpoSerie	:= .F.
Local lCpoFlag	:= .F.

If lDHO
	lCpoCustom	:= DHO->(FieldPos("DHO_CUSTOM")) > 0
	lCpoSerie	:= DHO->(FieldPos("DHO_SERIE")) > 0
	lCpoFlag	:= DHO->(FieldPos("DHO_FLAG")) > 0
Endif	

If lTesLogix .And. lCpoCustom .And. lCpoSerie .And. lCpoFlag
	lRet := .T.
Endif

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc}M002TPDHO
Consulta Tipo Operação pelo CFOP + CustomerCode + Serie

@author Rodrigo M Pontes	
@since 08/12/17
@version P12
/*/
//-------------------------------------------------------------------
Function M002TPDHO(cCfop,cCustomer,cSerie)

Local cTp := ""

cCfop 		:= PadR(cCfop,TamSx3("DHO_CFOP")[1])
cCustomer	:= PadR(cCustomer,TamSx3("DHO_CUSTOM")[1])
cSerie 	:= PadR(cSerie,TamSx3("DHO_SERIE")[1])

If cPaisLoc == "BRA"
	DHO->(DbSetOrder(1))
	If DHO->(DbSeek(xFilial("DHO")+cCfop+cCustomer+cSerie))
		cTp := AllTrim(DHO->DHO_TPOP)
	EndIf
EndIf

Return cTp

//-------------------------------------------------------------------
/*/{Protheus.doc}M002EXFIS
Exceções fiscais

@author Rodrigo M Pontes	
@since 08/12/17
@version P12
/*/
//-------------------------------------------------------------------
Function M002EXFIS(cCfop,cCustomer,cSerie,nVlrICMS)

Local lRet		:= .F.
Local lCFOPFE	:= SubStr(cCFOP,1,1) == "6" //Fora estado
Local lICMSZe	:= nVlrICMS == 0
Local lAG		:= .F.

cCfop 		:= PadR(cCfop,TamSx3("DHO_CFOP")[1])
cCustomer	:= PadR(cCustomer,TamSx3("DHO_CUSTOM")[1])
cSerie 	:= PadR(cSerie,TamSx3("DHO_SERIE")[1])

If cPaisLoc == "BRA"
	DHO->(DbSetOrder(1))
	If DHO->(DbSeek(xFilial("DHO")+cCfop+cCustomer+cSerie))
		lAG := AllTrim(DHO->DHO_FLAG) == "2"
	EndIf
EndIf

If lCFOPFE .And. lICMSZe .And. lAG
	lRet := .T.
Endif

Return lRet
