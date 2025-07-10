#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
#include 'MATA020.ch'

#DEFINE SOURCEFATHER "MATA020"

/*/{Protheus.doc} MATA020MRUS
Cadastro de fornecedor localizado para RUSSIA.

O fonte contém browse, menu, model e view propria, todos herdados do MATA020. 
Qualquer regra que se aplique somente para a RUSSIA deve ser definida aqui.

As validações e integrações realizadas após/durante a gravação estão definidas nos eventos do modelo, 
na classe MATA020EVRUS.

@type function
 
@author José Eulálio
@since 22/09/2017
@version P12.1.17
/*/
Function MATA020MRUS()
Local oBrowse := BrowseDef()
	
	oBrowse:Activate()
	
	//Limpa a tecla de atalho do F12
	A020F12End()
	
Return

Static Function BrowseDef()
Local oBrowse := FwLoadBrw("MATA020") 
Return oBrowse

Static Function ModelDef()
Local oModel	:= FWLoadModel("MATA020") 
Local oEvent	:= MATA020EVRUS():New()
Local oModBco	:= oModel:GetModel("BANCOS")
	
	oModel:InstallEvent("RUSSIA",,oEvent)
	
	oModBco:GetStruct():SetProperty("FIL_TIPO",MODEL_FIELD_VALID,{|oModBco| Mt020FilTp(oModBco) .And. Pertence('12')})
	
Return oModel

Static Function ViewDef()
Local oView			:= FWLoadView("MATA020")
Local cCamposRus	:= "FIL_BANCO|FIL_CONTA|FIL_ACNAME|FIL_MOEDA|FIL_AGENCI|FIL_BKNAME|FIL_CORRAC|FIL_CITY|FIL_SWIFT|FIL_NMECOR|FIL_REASON|FIL_FOREIG|FIL_CLOSED|FIL_TIPO"
Local nPosBanco		:= 0
Local nX			:= 0

	//Envia os campos para a montagem da View de Bancos
	For nX := 1 To Len(oView:aUserButtons)
		nPosBanco := aScan(oView:aUserButtons[nX],STR0068)		
		If nPosBanco > 0
			oView:aUserButtons[nX][3] := {|| A020Bancos(oView,cCamposRus) }
			Exit
		EndIf
	Next nX
	oView:AddUserButton(STR0081,'AddrButton', {|| CRMA680RUS("SA2",xFilial("SA2")+ M->A2_COD + M->A2_LOJA,.F.,STR0081+ " " + M->A2_NOME)}, /*[cToolTip]*/,K_CTRL_A) // Other Actions - address button in viewdef
	
Return oView

Static Function MenuDef()
Local aRotina := FWLoadMenuDef("MATA020")	
Return aRotina

//-------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Before
Método que é chamado pelo MVC quando ocorrer as ações do commit
antes da gravação de cada submodelo (field ou cada linha de uma grid)

@type metodo
 
@author José Eulálio
@since 25/09/2017
@version P12.1.17
/*/
//-------------------------------------------------------------------------------------------------------
Function MX020FilTp(oModBco)
Local nX		:= 0
Local nLinha	:= oModBco:GetLine()
Local lRet		:= .T.

If oModBco:GetValue("FIL_TIPO") == "1"

	For nX := 1 to oModBco:Length()
		oModBco:GoLine(nX)
		If nX <> nLinha
			If oModBco:GetValue("FIL_TIPO") == "1"
				Help(" ",1,"MA020MAIN")//This supplier has already a Main Account!
				lRet := .F.
			EndIf
		EndIf
	Next nX
	
	oModBco:GoLine(nLinha)

EndIf

Return lRet
