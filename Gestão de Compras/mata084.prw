#include "MATA084.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"


//-------------------------------------------------------------------
/*/{Protheus.doc} MATA084()
Cadastro de Solicitantes
@author Alexandre gimenez
@since 26/08/2013
@version 1.0
@return NIL
/*/
//-------------------------------------------------------------------
Function MATA084() 
Local oBrowse  

oBrowse := BrowseDef()
oBrowse:Activate()

Return

Static Function BrowseDef()
Local oBrowse as object

oBrowse := FWMBrowse():New()
oBrowse:SetAlias("SAI")                                          
oBrowse:SetDescription(STR0001) //"Cadastro de Solicitantes"

Return oBrowse


//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Definição do modelo de Dados

@author alexandre.gimenez

@since 26/08/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oModel
Local lDbkDomi	:= DBK->(FIELDPOS("DBK_DOMINI")) > 0 //campo criado posteriormente para evitar chave duplicada na DBK.
Local oStr1		:= FWFormStruct(1,'SAI',{|cCampo| AllTrim(cCampo) $ "AI_USER|AI_USRNAME|AI_GRUSER|AI_GRPNAME"})
Local oStr2		:= FWFormStruct(1,'SAI',{|cCampo| !AllTrim(cCampo) $ "AI_USER|AI_USRNAME|AI_GRUSER|AI_GRPNAME"})
Local oStr3		:= FWFormStruct(1,'DBK')
Local aUniqLn 	:= {}


oModel := MPFormModel():New('MATA084',,{|oModel|A084TudoOk(oModel)})
oModel:SetDescription(STR0006)//'Cadastro de Solicitantes'

oModel:AddFields('SAI',,oStr1,)
oModel:AddGrid('SAI_GD','SAI'	 	,	oStr2,,{|oModel|A084VldGd(oModel)}) 
oModel:AddGrid('DBK_GD','SAI_GD' 	,	oStr3,,{||A084EClOK()})

oModel:SetPrimaryKey({ 'AI_FILIAL', 'AI_USER', 'AI_GRUSER' })

//Criação de UniqueLine para Entidades Contabeis
aUniqLn := { 'DBK_CC', 'DBK_CONTA', 'DBK_ITEMCT', 'DBK_CLVL' }

If cPaisLoc != "RUS"
	aUniqLn := MTGETFEC("DBK","DBK", aUniqLn)
EndIf

oModel:GetModel('DBK_GD'):SetUniqueLine( aUniqLn )
oModel:GetModel('SAI_GD'):SetUniqueLine( { 'AI_GRUPO', 'AI_PRODUTO', 'AI_DOMINIO' } )

oModel:SetRelation('SAI_GD', { { 'AI_FILIAL', 'xFilial("SAI")' }, { 'AI_USER', 'AI_USER' }, { 'AI_GRUSER', 'AI_GRUSER' } }, SAI->(IndexKey(1)) )
if lDbkDomi
	oModel:SetRelation('DBK_GD', { { 'DBK_FILIAL', 'xFilial("DBK")' }, { 'DBK_GRUPO', 'AI_GRUPO' }, { 'DBK_PRODUT', 'AI_PRODUTO' }, { 'DBK_USER', 'AI_USER' }, { 'DBK_GRUSER', 'AI_GRUSER' }, { 'DBK_DOMINI', 'AI_DOMINIO' } }, DBK->(IndexKey(1)) )
else 
	oModel:SetRelation('DBK_GD', { { 'DBK_FILIAL', 'xFilial("DBK")' }, { 'DBK_GRUPO', 'AI_GRUPO' }, { 'DBK_PRODUT', 'AI_PRODUTO' }, { 'DBK_USER', 'AI_USER' }, { 'DBK_GRUSER', 'AI_GRUSER' } }, DBK->(IndexKey(1)) )
endif
oModel:GetModel('SAI'):SetDescription(STR0007)//'Cadastro de Solicitantes'
oModel:GetModel('DBK_GD'):SetOptional(.T.)

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Definição da interface

@author alexandre.gimenez
@since 26/08/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oView
Local lDbkDomi	:= DBK->(FIELDPOS("DBK_DOMINI")) > 0
Local oModel 	:= ModelDef()
Local oStr1		:= FWFormStruct(2,'SAI',{|cCampo|  AllTrim(cCampo) $ "AI_USER|AI_USRNAME|AI_GRUSER|AI_GRPNAME"})
Local oStr2		:= FWFormStruct(2,'SAI',{|cCampo| !AllTrim(cCampo) $ "AI_USER|AI_USRNAME|AI_GRUSER|AI_GRPNAME"})
Local oStr3

if lDbkDomi
	oStr3 := FWFormStruct(2,'DBK',{|cCampo| !AllTrim(cCampo) $ "DBK_PRODUT|DBK_GRUPO|DBK_GRUSER|DBK_USER|DBK_DOMINI"})
else 
	oStr3 := FWFormStruct(2,'DBK',{|cCampo| !AllTrim(cCampo) $ "DBK_PRODUT|DBK_GRUPO|DBK_GRUSER|DBK_USER"})
endif

oView := FWFormView():New()

oView:SetModel(oModel)
oView:SetDescription(STR0002)//'Cadastro de Solicitantes'

oView:AddField('VMASTER_SAI' , oStr1,'SAI' )
oView:AddGrid('VGRID_SAI' , oStr2,'SAI_GD')
oView:AddGrid('VGRID_DBK' , oStr3,'DBK_GD')   

oView:CreateHorizontalBox( 'BOXFORM1', 150,,.T.)
oView:CreateHorizontalBox( 'BOXFORM3', 50)
oView:CreateHorizontalBox( 'BOXFORM5', 50)

oView:SetOwnerView('VMASTER_SAI','BOXFORM1')
oView:SetOwnerView('VGRID_SAI','BOXFORM3')
oView:SetOwnerView('VGRID_DBK','BOXFORM5')

oView:EnableTitleView('VMASTER_SAI' , STR0003 ) //'Cadastro de Solicitantes'
oView:EnableTitleView('VGRID_DBK' , STR0004 ) //'Entidades Contábeis'
oView:EnableTitleView('VGRID_SAI' , STR0005 ) //'Produtos'

oView:AddIncrementField('VGRID_SAI' , 'AI_ITEM' ) 
oView:AddIncrementField( 'VGRID_DBK', 'DBK_ITEM' )

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef()
Definicao do Menu
@author Alexandre Gimenez
@since 26/08/2013
@version 1.0
@return aRotina 
/*/
//-------------------------------------------------------------------
Static Function MenuDef()  

Local aRotina := {}

ADD OPTION aRotina TITLE STR0012  	ACTION 'AxPesqui'       	OPERATION 1 ACCESS 0	//"Pesquisar"
ADD OPTION aRotina TITLE STR0013	ACTION 'VIEWDEF.MATA084'	OPERATION 2 ACCESS 0	//"Visualizar"
ADD OPTION aRotina TITLE STR0008	ACTION 'VIEWDEF.MATA084'	OPERATION 3 ACCESS 0	//"Incluir"
ADD OPTION aRotina TITLE STR0009   ACTION 'VIEWDEF.MATA084'	OPERATION 4 ACCESS 0	//"Alterar"
ADD OPTION aRotina TITLE STR0010   ACTION "VIEWDEF.MATA084"	OPERATION 5 ACCESS 0	//"Excluir"


Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} A084Group()
Valid do campo AI_GRUPO
@author alexandre.gimenez
@since 26/08/2013
@version 1.0
@return lRet 
/*/
//-------------------------------------------------------------------
Function A084Group()
Local oModel := FWModelActive()
Local oSAI_GD := oModel:GetModel('SAI_GD')
Local cVar	:= oSAI_GD:GetValue('AI_GRUPO')
Local lRet := .T.


If !Empty(cVar) .And. PadR('*',len(cVar)) <> cVar 
	lRet := ExistCpo("SBM",M->AI_GRUPO)
EndIf

Return lRet 

//-------------------------------------------------------------------
/*/{Protheus.doc} A084Prod()
Valid do campo AI_PRODUTO
@author alexandre.gimenez
@since 26/08/2013
@version 1.0
@return lRet 
/*/
//-------------------------------------------------------------------
Function A084Prod()
Local oModel := FWModelActive()
Local oSAI_GD := oModel:GetModel('SAI_GD')
Local cVar	:= oSAI_GD:GetValue('AI_PRODUTO')
Local lRet	:= .T.

If !Empty(cVar) .And. PadR('*',len(cVar)) <> cVar
	dbSelectArea("SB1")
	dbSetOrder(1)
	If !dbSeek(xFilial()+cVar)
		HELP(" ",1,"REGNOIS")
		lRet := .F.
	EndIf
	// Verifica se o Registro esta Bloqueado.
	If lRet .And. !RegistroOk("SB1")
       lRet := .F.
	EndIf
EndIf
	
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} A084AjtSAI()
Função para ajustar tabela SAI, eliminando ****** dos campos AI_USER e AI_GRUSER
adequando a versões superiores a 11.80
@author alexandre.gimenez
@since 26/08/2013
@version 1.0
@return Nil 
/*/
//-------------------------------------------------------------------
Static Function A084AjtSAI()

BeginSQL Alias "AITEMP"
		
SELECT SAI.R_E_C_N_O_ RecSAI
		
FROM %table:SAI% SAI
		
WHERE ( SAI.AI_USER  = '******'  
	OR SAI.AI_GRUSER  = '******' )
	AND SAI.AI_USER != SAI.AI_GRUSER 
	AND SAI.%NotDel%
		
EndSql

While AITEMP->(!Eof())
	SAI->(DbGoTo(AITEMP->RecSAI))
	RecLock("SAI",.F.)
	If SAI->AI_USER == replicate("*",len(AllTrim(SAI->AI_USER)))
		SAI->AI_USER := CRIAVAR("AI_USER",.F.)
	ElseIf SAI->AI_GRUSER == replicate("*",len(AllTrim(SAI->AI_GRUSER)))
		SAI->AI_GRUSER := CRIAVAR("AI_GRUSER",.F.)
	EndIf
	MsUnlock()
	AITEMP->(DbSkip())
EndDo

AITEMP->(dbCloseArea())

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} A084GrUser()
Valid do campo AI_GRUSER
@author alexandre.gimenez
@since 26/08/2013
@version 1.0
@return lRet 
/*/
//-------------------------------------------------------------------
Function A084GrUser()
	Local lRet	:= .T.
	Local oModel:= FWModelActive()
	Local oSAI	:= oModel:GetModel('SAI')
	Local aAreaAI:= {}
	
	If !Empty(oSAI:GetValue("AI_GRUSER"))
		If AllTrim(oSAI:GetValue("AI_GRUSER")) == replicate("*",len(AllTrim(oSAI:GetValue("AI_GRUSER")))) 
			oSAI:LoadValue("AI_GRUSER",replicate("*",TamSx3("AI_GRUSER")[1]))
		Else
			lRet := UsrExist(oSAI:GetValue("AI_GRUSER"),.F.)
		EndIf
	EndIf
	If lRet
		aAreaAI:= SAI->(GetArea())
		SAI->(DbSetOrder(1))
		If SAI->(MsSeek(xFilial("SAI")+oSAI:GetValue("AI_GRUSER")))
			lRet := .F.
			Help('',1,'A084GRUSER',,'Grupo ja cadastrado',1,0) 
		EndIf
		RestArea(aAreaAI)
	EndIf

Return lRet 
//-------------------------------------------------------------------
/*/{Protheus.doc} A084User()
Valid do campo AI_USER
@author alexandre.gimenez
@since 26/08/2013
@version 1.0
@return lRet 
/*/
//-------------------------------------------------------------------
Function A084User()
Local lRet	:= .T.
Local oModel:= FWModelActive()
Local oSAI	:= oModel:GetModel('SAI')
Local aAreaAI:= {}

If !Empty(oSAI:GetValue("AI_USER"))
	If AllTrim(oSAI:GetValue("AI_USER")) == replicate("*",len(AllTrim(oSAI:GetValue("AI_USER"))))
		oSAI:LoadValue("AI_USER",replicate("*",TamSx3("AI_USER")[1]))
	Else
		lRet := UsrExist(oSAI:GetValue("AI_USER"))
	EndIf
EndIf

	If lRet
	aAreaAI:= SAI->(GetArea())
	SAI->(DbSetOrder(2))
	If SAI->(MsSeek(xFilial("SAI")+oSAI:GetValue("AI_USER")))
		lRet := .F.
		Help('',1,'A084USER',,'Usuario ja cadastrado',1,0) 
	EndIf
	RestArea(aAreaAI)
	EndIf
Return lRet 


//-------------------------------------------------------------------
/*/{Protheus.doc} A084TudoOk(oModel)
//PosValid do modelo, esta função Valida o Modelo e adiciona * ao usuario ou grupo caso necessário
@author alexandre.gimenez
@since 26/08/2013
@version 1.0
@return lRet 
/*/
//-------------------------------------------------------------------
Function A084TudoOk(oModel)
Local lRet		:= .T.
Local oSAI		:= oModel:GetModel('SAI')
Local oSAIGD 	:= oModel:GetModel('SAI_GD')
Local oDBKGD	:= oModel:GetModel('DBK_GD')
Local cSeek 	:= ""
Local nX		:= 0
Local nY		:= 0

If !Empty(oSAI:GetValue("AI_USER")) .Or. !Empty(oSAI:GetValue("AI_GRUSER"))

	For nX := 1 To oSAIGD:Length()
		oSAIGD:GoLine(nX)
		lRet := A084VldGd(oSAIGD)
		If !lRet
			Exit
		EndIf
		For nY := 1 To oDBKGD:Length()
			oDBKGD:GoLine(nY)
			lRet := A084EClOK()
			If !lRet
				Exit
			EndIf
		Next nY
		If !lRet
			Exit
		Else
			// Insere '*' no campo Produto caso tenha selecionado um grupo valido, e '*' no Grupo caso tenha selecionado um produto valido
			If oModel:GetOperation() <> MODEL_OPERATION_DELETE
				cGrupoMat := oSAIGD:GetValue('AI_GRUPO')
				cProduto  := oSAIGD:GetValue('AI_PRODUTO')
			
				If !Empty(cGrupoMat) .And. PadR('*',Len(cGrupoMat)) <> cGrupoMat 
					oSAIGD:LoadValue("AI_PRODUTO","*")
				EndIf
			
				If !Empty(cProduto) .And. PadR('*',Len(cProduto)) <> cProduto 
					oSAIGD:LoadValue("AI_GRUPO","*")
				EndIf
			EndIf
		EndIf
	Next Nx

	If oModel:GetOperation() == MODEL_OPERATION_INSERT
		SAI->(DBSetOrder(3))
		If (oSAI:GetValue("AI_GRUSER") == replicate("*",TamSx3("AI_GRUSER")[1])) .Or. (oSAI:GetValue("AI_USER") == replicate("*",TamSx3("AI_USER")[1]))
			cSeek := xFilial("SAI") + replicate("*",(TamSx3("AI_GRUSER")[1] + TamSx3("AI_USER")[1]))
		Else
			cSeek := xFilial("SAI")+oSAI:GetValue("AI_GRUSER")+oSAI:GetValue("AI_USER")
		EndIf	

		//Inseri * nos campos usuario ou grupo
		If lRet .And. oModel:GetOperation() <> MODEL_OPERATION_DELETE	
			If oSAI:GetValue("AI_USER") == replicate("*",len(AllTrim(oSAI:GetValue("AI_USER")))) .Or. (Empty(oSAI:GetValue("AI_GRUSER")) .And. Empty(oSAI:GetValue("AI_USER")))
				oSAI:LoadValue("AI_GRUSER",replicate("*",TamSx3("AI_GRUSER")[1]))
			EndIf
			If oSAI:GetValue("AI_GRUSER") == replicate("*",len(AllTrim(oSAI:GetValue("AI_GRUSER")))) .Or. (Empty(oSAI:GetValue("AI_GRUSER")) .And. Empty(oSAI:GetValue("AI_USER")))
				oSAI:LoadValue("AI_USER",replicate("*",TamSx3("AI_USER")[1]))
			EndIf
		EndIf
		If SAI->(DBSeek(cSeek))
			lRet:= .F.
			Help(' ', 1,'JAGRAVADO')
		EndIf
	EndIf
	
	If lRet .And. oModel:GetOperation() <> MODEL_OPERATION_DELETE
		If !Empty(oSAI:GetValue("AI_USER")) .And. Empty(oSAI:GetValue("AI_GRUSER"))
			oSAI:LoadValue("AI_GRUSER",replicate("*",TamSx3("AI_GRUSER")[1]))
		ElseIf !Empty(oSAI:GetValue("AI_GRUSER")) .And. Empty(oSAI:GetValue("AI_USER"))
			oSAI:LoadValue("AI_USER",replicate("*",TamSx3("AI_USER")[1]))
		EndIf
	EndIf
	
Else
	Help(' ', 1,'A084USRGRP') //Não foram preenchidos os campos usuário ou grupo de usuário do cabeçalho de solicitantes.
	lRet:= .F.  
EndIf

Return lRet 

//-------------------------------------------------------------------
/*/{Protheus.doc} A084EClOK()
//Pre Valid (LinhaOK) do Modelo DBK, verifica se ao menos uma EC foi informada
@author alexandre.gimenez
@since 26/08/2013
@version 1.0
@return lRet 
/*/
//-------------------------------------------------------------------
Static Function A084EClOK()
Local lRet			:= .T.
Local nX		 	:= 0
Local aCampos 		:= { 'DBK_CC', 'DBK_CONTA', 'DBK_ITEMCT', 'DBK_CLVL' } 
Local oModelPai 	:= FWModelActive()
Local oModelSAI  	:= oMOdelPai:GetModel("SAI_GD")
Local oModelDBK  	:= oMOdelPai:GetModel("DBK_GD") 

//Criação de array para Entidades Contabeis
If cPaisLoc != "RUS"
	aCampos := MTGETFEC("DBK","DBK", aCampos)
EndIf

If !oModelDBK:IsDeleted()
	lRet := .F. 	
	For nX := 1 TO Len(aCampos)
		If !Empty(oModelDBK:GetValue(aCampos[nX]))	
			lRet := .T.
			Exit
		EndiF
	Next nX
EndIf

If !lRet
	If oModelDBK:Length() > 1 	
		Help(' ', 1,'A084EC',,STR0011 + oModelSAI:GetValue("AI_ITEM") ,1,0)//"Ao menos deve ser informado uma entidade contábil para o Item "
	Else
		lRet := .T.		
	EndIf		
EndIf 

Return lRet 

//-------------------------------------------------------------------
/*/{Protheus.doc} A084VldGd(oModel)
//Pre Valid (LinhaOK) do Modelo SAI_GD, verifica se ao menos um Grupo de Materiais ou um Produto
@author alexandre.gimenez
@since 26/08/2013
@version 1.0
@return lRet 
/*/
//-------------------------------------------------------------------
Static Function A084VldGd(oModel)
Local lRet		:= .T.

If (Empty(oModel:GetValue('AI_GRUPO'))) .And.( Empty(oModel:GetValue('AI_PRODUTO'))) .And. (!oModel:IsDeleted())
	lRet := .F.
	Help(' ', 1,'A084GRPPROD')
EndIf 

Return lRet 

//-------------------------------------------------------------------
/*/{Protheus.doc} A084Gatilh(oModel)
//Função para tratamento do gatilho do campo do campo AI_PRODUTO
@author manuela.cavalcante
@since 04/02/2016
/*/
//-------------------------------------------------------------------
Function A084Gatilh()
Local cGrupo := ""

If FWFLDGET("AI_PRODUTO") == PadR("*",TamSx3("AI_PRODUTO")[1]) 
	If Empty(FWFLDGET("AI_GRUPO"))
		cGrupo := "*"
	Else
		cGrupo := FWFLDGET("AI_GRUPO")
	EndIf
Else 
	cGrupo := "*"
EndIf

Return cGrupo

//-------------------------------------------------------------------
/*/{Protheus.doc} AjustaSX7(oModel)
//Ajusta o X7_REGRA do campo AI_PRODUTO
@author manuela.cavalcante
@since 04/02/2016
/*/
//-------------------------------------------------------------------

Function A084GatGrp()
Local cProd := " "

	IF FWFLDGET("AI_GRUPO") == PadR("*",TamSx3("AI_GRUPO")[1])
		If Empty(FWFLDGET("AI_PRODUTO"))
			cProd := "*"
		Else
			cProd := FWFLDGET("AI_PRODUTO")
		EndIf
	else
		cProd := "*" 
	Endif           

Return cProd
