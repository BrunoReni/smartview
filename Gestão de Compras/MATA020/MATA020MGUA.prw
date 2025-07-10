#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
#include 'MATA020.ch'

#DEFINE SOURCEFATHER "MATA020"

/*/{Protheus.doc} MATA020GUA
Cadastro de fornecedor localizado para GUATEMALA.

O fonte contém browse, menu, model e view propria, todos herdados do MATA020. 
Qualquer regra que se aplique somente para a GUATEMALA deve ser definida aqui.

As validações e integrações realizadas após/durante a gravação estão definidas nos eventos do modelo, 
na classe MATA020EVCOL.

@type function
 
@author Juliane Venteu
@since 02/02/2017
@version P12.1.17
/*/
Function MATA020GUA()
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
Local oEvent := MATA020EVGUA():New()
	
	oModel:InstallEvent("GUATELAMA",,oEvent)	
	
Return oModel

Static Function ViewDef()
Local oView := FWLoadView("MATA020")
Return oView

Static Function MenuDef()
Local aRotina := FWLoadMenuDef("MATA020")	
Return aRotina