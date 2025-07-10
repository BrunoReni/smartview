#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "MATA001.CH"
//-------------------------------------------------------------------
/*/{Protheus.doc} MATA001()
Cadastro dos campos de controle da matriz de abastecimento
@author Leonardo Quintania
@since 28/01/2013
@version 1.0
@return NIL
/*/
//-------------------------------------------------------------------
Function MATA001() 
Local oBrowse  

If !GetRpoRelease() > 'R7' .and. substr(GetRpoRelease(),1,2) <> '12'
	Aviso(STR0007,STR0008, {"Ok"})
	Return NIL
EndIf

oBrowse := FWMBrowse():New()
oBrowse:SetAlias("DB5")                                          
oBrowse:SetDescription(STR0001)  //"Matriz de Abastecimento"
oBrowse:Activate()

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef()
Definicao do Menu
@author Leonardo Quintania
@since 28/01/2013
@version 1.0
@return aRotina (vetor com botoes da EnchoiceBar)
/*/
//-------------------------------------------------------------------
Static Function MenuDef()  

Local aRotina := {} //Array utilizado para controlar opcao selecionada

aAdd(aRotina,{STR0002		,"PesqBrw",0,1,1,NIL}) 			 //"Pesquisar"
aAdd(aRotina,{STR0003		,"VIEWDEF.MATA001",0,2,1,NIL}) 	 //"Visualizar"
aAdd(aRotina,{STR0004		,"VIEWDEF.MATA001",0,3,1,NIL})	 //"Incluir"
aAdd(aRotina,{STR0005   	,"VIEWDEF.MATA001",0,4,1,NIL}) 	 //"Alterar"
aAdd(aRotina,{STR0006  		,"VIEWDEF.MATA001",0,5,1,NIL}) 	 //"Excluir"

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef()
Definicao do Modelo
@author Leonardo Quintania
@since 28/01/2013
@version 1.0
@return oModel
/*/
//-------------------------------------------------------------------
Static Function ModelDef()  

Local oStruCab := FWFormStruct(1,"DB5",{|cCampo| AllTrim(cCampo) $ "DB5_FILDIS|DB5_NFILDI"}) //Estrutura Cabecalho Matriz Abastecimento 
Local oStruDB5 := FWFormStruct(1,"DB5",{|cCampo| !AllTrim(cCampo) $ "DB5_FILDIS|DB5_NFILDI|DB5_OK"})//Estrutura Itens Matriz Abastecimento
Local oModel   := Nil //Modelo de Dados MVC 

//------------------------------------------------------
//		Cria a estrutura basica
//------------------------------------------------------
oModel:= MPFormModel():New("MATA001", /*Pre-Validacao*/,/*Pos-Validacao*/,/*Commit*/,/*Cancel*/)

//------------------------------------------------------
//		Adiciona o componente de formulario no model 
//     Nao sera usado, mas eh obrigatorio ter
//------------------------------------------------------	
oModel:AddFields("DB5MASTER",/*cOwner*/,oStruCab)
oModel:AddGrid("DB5DETAILS","DB5MASTER",oStruDB5,,{|oModelGrid| A001LinOk(oModelGrid)})

//--------------------------------------
//		Configura o model
//--------------------------------------
oModel:SetPrimaryKey( {} ) //Obrigatorio setar a chave primaria (mesmo que vazia)
oModel:SetRelation("DB5DETAILS",{{"DB5_FILIAL",'xFilial("DB5")'},{"DB5_FILDIS","DB5_FILDIS"}},DB5->(IndexKey(1)))
oModel:GetModel("DB5DETAILS"):SetUniqueLine({"DB5_FILABA"})


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

Local oModel   	:= FWLoadModel( "MATA001" )	 //Carrega model definido
Local oStruCab 	:= FWFormStruct(2,"DB5",{|cCampo| AllTrim(cCampo) $ "DB5_FILDIS|DB5_NFILDI"}) //Estrutura Cabecalho Matriz Abastecimento 
Local oStruDB5 	:= FWFormStruct(2,"DB5",{|cCampo| !AllTrim(cCampo) $ "DB5_FILDIS|DB5_NFILDI|DB5_OK"})//Estrutura Itens Matriz Abastecimento
Local oView	  	:= FWFormView():New()

//--------------------------------------
//		Associa o View ao Model
//--------------------------------------
oView:SetModel(oModel)  //-- Define qual o modelo de dados será utilizado
oView:SetUseCursor(.F.) //-- Remove cursor de registros'

//--------------------------------------
//		Insere os componentes na view
//--------------------------------------
oView:AddField("MASTER_DB5",oStruCab,"DB5MASTER")   //Cabecalho da matriz de abastecimento
oView:AddGrid("DETAILS_DB5",oStruDB5,"DB5DETAILS")	  //Itens da matriz de abastecimento

//--------------------------------------
//		Cria os Box's
//--------------------------------------
oView:CreateHorizontalBox("CABEC",20)
oView:CreateHorizontalBox("GRID",80)

//--------------------------------------
//		Associa os componentes
//--------------------------------------
oView:SetOwnerView("MASTER_DB5","CABEC")
oView:SetOwnerView("DETAILS_DB5","GRID")

oView:AddIncrementField( "DETAILS_DB5", "DB5_ITEM" )

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} A001LinOk()
Visualizacao do Cadastro de Produtos
@author Leonardo Quintania
@since 28/01/2013
@version 1.0
@return NIL
/*/
//-------------------------------------------------------------------
Static Function A001LinOk(oModel)
Local lRet := .T.
Local nX	:= 0
Local nL	:= oModel:nLine
Local cPri	:= oModel:GetValue("DB5_PRIORI")

If !lRet	
	Help(" ",1,"OBRIGAT2")
EndIf

If lRet
	For nX := 1 to oModel:Length()
		oModel:GoLine(nX)
		If nX <> nL .And. oModel:GetValue("DB5_PRIORI") == cPri .And. !oModel:IsDeleted()
			lRet:= .F.
			Help("",1,"A001PRIOR")
			Exit
		EndIf
	Next nX
EndIf



Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} A001IniCpo()
Inicializa Nome dos campos
@author Leonardo Quintania
@since 28/01/2013
@version 1.0
@return NIL
/*/
//-------------------------------------------------------------------
Function A001IniCpo(cFil)
Local cNomeFil  	:= ""
Local oModel   	:= FWModelActive()    
 
If ValType(oModel) != "U"
	If oModel:GetOperation() != MODEL_OPERATION_INSERT
		cNomeFil := FwFilialName(,cFil)
	EndIf
Else
	cNomeFil := FwFilialName(,cFil)
EndIf

Return cNomeFil

//-------------------------------------------------------------------
/*/{Protheus.doc} A001VldDis()
Inicializa Nome dos campos
@author Leonardo Quintania
@since 28/01/2013
@version 1.0
@return NIL
/*/
//-------------------------------------------------------------------
Function A001VldDis()
Local lRet  	:= .T.
 
DB5->(dbSetOrder(1))
lRet:= !DB5->(dbSeek(xFilial("DB5")+FwFldGet("DB5_FILDIS")))

If !lRet
	Help(" ",1,"JAGRAVADO")
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} A001VldAba()
Inicializa Nome dos campos
@author Leonardo Quintania
@since 28/01/2013
@version 1.0
@return NIL
/*/
//-------------------------------------------------------------------
Function A001VldAba()
Local lRet  	:= .T.

If FwFldGet("DB5_FILABA")==FwFldGet("DB5_FILDIS")
	//lRet:= .F.
	//Linha alterada para permitir que a a Filial Distribuidora seja abastecida por ela mesma
	lRet:= .T.
EndIf

If !lRet
	Help(" ",1,"JAGRAVADO")
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} A001Consult()
Consulta Especifica Filial Distribuidora
@author alexandre.gimenez
@since 02/12/2013
@version 1.0
@return NIL
/*/
//-------------------------------------------------------------------
Function A001Consult()
Local aArea		:= GetArea()
Local cAliasDist	:= GetNextAlias()
Local aItens		:= {}
Local lRet			:= .F.
Local nLinha		:= 0
Local oDlg
Local oBrowse

BeginSQL Alias cAliasDist
	SELECT  Distinct DB5_FILDIS 
		FROM %table:DB5% DB5
		WHERE DB5.%NotDel% AND
		DB5.DB5_FILIAL = %Exp:xFilial("DB5")%
EndSql

While (cAliasDist)->(!Eof())	
	aAdd(aItens,{(cAliasDist)->DB5_FILDIS ,FWFilialName(cEmpAnt,(cAliasDist)->DB5_FILDIS ,1) })
	(cAliasDist)->(dbSkip())	
End

If !Empty(aItens)
	DEFINE DIALOG oDlg TITLE "Consulta Filial Distribuidora" FROM 180,180 TO 550,680 PIXEL                 
		// Cria Browse
		oBrowse := TCBrowse():New( 01 , 01, 250, 165,,{'Fil.Distrib.','Nome'},{30,150},oDlg,,,,,{|| lRet := .T., nLinha:= oBrowse:nAt ,  oDlg:End() },,,,,,,.F.,,.T.,,.F.,,, )
		// Seta array para o browse                            
		oBrowse:SetArray(aItens) 
		// Adciona colunas
		oBrowse:AddColumn( TCColumn():New('Filial Distribuidora',{ || aItens[oBrowse:nAt,1] },,,,"LEFT",,.F.,.T.,,,,.F.,) ) 
		oBrowse:AddColumn( TCColumn():New('Filial Nome',{ || aItens[oBrowse:nAt,2] },,,,"LEFT",,.F.,.T.,,,,.F.,) )
		// Cria botões do Browse
		TButton():New( 170, 002, "Ok"			, oDlg,{|| lRet := .T., nLinha:= oBrowse:nAt ,  oDlg:End()	},40,010,,,.F.,.T.,.F.,,.F.,,,.F. )
		TButton():New( 170, 050, "Cancelar"	, oDlg,{|| oDlg:End() 											},40,010,,,.F.,.T.,.F.,,.F.,,,.F. )
	ACTIVATE DIALOG oDlg CENTERED
Else
	Help(" ",1,"NAOCADAST")
EndIf
 
If lRet
	VAR_IXB := aItens[nLinha,1]
EndIf

RestArea(aArea) 
Return lRet


