#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'  
#INCLUDE 'MATA022.CH'

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ MATA022  บAutor  ณAndre Anjos		 บ Data ณ  26/08/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Cadastro de N.S.H.                                         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Generico                                                	  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function MATA022(aAuto,nOpcAuto)

If cPaisLoc $ "ANG|EQU|HAI"
	If aAuto <> NIL        	//verifica se ้ rotina automatica
		Private aRotina := MenuDef()
		FWMVCRotAuto(ModelDef(),"SCD",nOpcAuto,{{"SCDMASTER",aAuto}}) 
	Else
		DEFINE FWMBROWSE oMBrowse ALIAS "SCD"
		oMBrowse:DisableDetails()
		ACTIVATE FWMBROWSE oMBrowse
	EndIf
EndIf

Return NIL
//-------------------------------------------------------------------
/*	Menu funcional
@autor  	Ramon Neves
@data 		20/04/2012
@return 		aRotina*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina	:= {} 
Local aRotAdic	:= {}

ADD OPTION aRotina Title STR0002				   		Action 'VIEWDEF.MATA022'	OPERATION MODEL_OPERATION_VIEW 		ACCESS 0 	//Visualizar
ADD OPTION aRotina Title STR0003						Action 'VIEWDEF.MATA022'	OPERATION MODEL_OPERATION_INSERT	ACCESS 0 	//Incluir
ADD OPTION aRotina Title STR0004						Action 'VIEWDEF.MATA022'	OPERATION MODEL_OPERATION_UPDATE 	ACCESS 0 	//Alterar
ADD OPTION aRotina Title STR0005						Action 'VIEWDEF.MATA022'	OPERATION MODEL_OPERATION_DELETE 	ACCESS 0 	//Excluir     

If ExistBlock("MA022MNU")
	aRotAdic := ExecBlock("MA022MNU",.F.,.F.)
	If ValType(aRotAdic) == "A"
		AEval(aRotAdic,{|x| AAdd(aRotina,x)})
	EndIf
EndIf

Return aRotina
//-------------------------------------------------------------------
/*	Modelo de Dados
@autor  	Ramon Neves
@data 		11/06/2012
@return 		oModel Objeto do Modelo*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oStruSCD := FWFormStruct( 1, "SCD")                              
Local oModel := MPFormModel():New("MATA022_SCD")

oModel:AddFields("SCDMASTER",, oStruSCD)
oModel:GetModel( 'SCDMASTER' ):SetDescription(STR0007) 

Return oModel
//-------------------------------------------------------------------
/*	Interface da aplicacao
@autor  	Ramon Neves
@data 		20/04/2012
@return 		oView Objeto da Interface*/
//-------------------------------------------------------------------
Static Function ViewDef()

// Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
Local oModel	:= FWLoadModel( 'MATA022' )
Local oStruSCD	:= FWFormStruct( 2, 'SCD'/*,{|cCampo|AvaliaCampo(cCampo)}*/)
Local aButtons	:= {} 
Local nx		:= 0   


Local oView  

oView := FWFormView():New()
oView:SetModel(oModel)

oView:AddField("VIEW_SCD",oStruSCD,"SCDMASTER")

If ExistBlock("MA022BUT")
	aButtons := ExecBlock("MA022BUT",.F.,.F.)
	If ValType(aButtons) # "A"
		aButtons := {}
	EndIf
EndIf        

//loop para incluir todos os botoes na View
FOR nX := 1 to len(aButtons)
	oView:AddUserButton(aButtons[nX][3], aButtons[nX][1],aButtons[nX][2]) 
Next nX	

Return oView 