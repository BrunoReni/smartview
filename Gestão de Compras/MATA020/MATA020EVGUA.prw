#include 'Protheus.ch'
#include 'FWMVCDef.ch'
#include 'MATA020.ch'

/*/{Protheus.doc} MATA020EVGUA
Eventos do MVC para a GUATEMALA, qualquer regra que se aplique somente para GUATEMALA
deve ser criada aqui, se for uma regra geral deve estar em MATA020EVDEF.

Todas as validações de modelo, linha, pré e pos, também todas as interações com a gravação
são definidas nessa classe.

Importante: Use somente a função Help para exibir mensagens ao usuario, pois apenas o help
é tratado pelo MVC. 

Documentação sobre eventos do MVC: http://tdn.totvs.com/pages/viewpage.action?pageId=269552294

@type classe
 
@author Juliane Venteu
@since 02/02/2017
@version P12.1.17
/*/
CLASS MATA020EVGUA From FWModelEvent

	METHOD New() CONSTRUCTOR
	
	METHOD ModelPosVld()
	
ENDCLASS

//-----------------------------------------------------------------
METHOD New() CLASS MATA020EVGUA
Return

/*/{Protheus.doc} ModelPosVld
Executa a validação do modelo antes de realizar a gravação dos dados.
Se retornar falso, não permite gravar.

@type metodo
 
@author Juliane Venteu
@since 02/02/2017
@version P12.1.17
 
/*/
METHOD ModelPosVld(oModel, cID) CLASS MATA020EVGUA
Local lValid := .T.
Local nOpc
	
	nOpc := oModel:GetOperation()
	::cCodigo := oModel:GetValue("SA2MASTER","A2_COD")
	::cLoja := oModel:GetValue("SA2MASTER","A2_LOJA")
		
	If nOpc == MODEL_OPERATION_UPDATE .Or. nOpc == MODEL_OPERATION_INSERT
		lValid  := A020ValDoc()
	EndIf

Return lValid

