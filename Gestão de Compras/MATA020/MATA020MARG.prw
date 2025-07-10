#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
#include 'MATA020.ch'

#DEFINE SOURCEFATHER "MATA020"

/*/{Protheus.doc} MATA020ARG
Cadastro de fornecedor localizado para ARGENTINA.

O fonte contém browse, menu, model e view propria, todos herdados do MATA020. 
Qualquer regra que se aplique somente para a ARGENTINA deve ser definida aqui.

As validações e integrações realizadas após/durante a gravação estão definidas nos eventos do modelo, 
na classe MATA020EVARG.

@type function
 
@author Juliane Venteu
@since 02/02/2017
@version P12.1.17
/*/
Function MATA020MARG()
Local oBrowse := BrowseDef()
	
	oBrowse:Activate()
	
	//Limpa a tecla de atalho do F12
	A020F12End()
Return

Static Function BrowseDef()
Local oBrowse := FwLoadBrw("MATA020") 
Return oBrowse

Static Function ModelDef()
Local oModel := FWLoadModel("MATA020")
Local oEvent := MATA020EVARG():New()
	
	oModel:InstallEvent("ARGENTINA",,oEvent)	
	
Return oModel

Static Function ViewDef()
Local oView := FWLoadView("MATA020")
Return oView

Static Function MenuDef()
Local aRotina := FWLoadMenuDef("MATA020")	
Return aRotina
