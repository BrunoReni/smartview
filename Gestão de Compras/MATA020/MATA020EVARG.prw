#include 'Protheus.ch'
#include 'FWMVCDef.ch'
#include 'MATA020.ch'

/*/{Protheus.doc} MATA020EVARG
Eventos do MVC para a ARGENTINA, qualquer regra que se aplique somente para ARGENTINA
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
CLASS MATA020EVARG From FWModelEvent
	
	DATA nOpc
	
	METHOD New() CONSTRUCTOR
	
	METHOD ModelPosVld()
	METHOD InTTS()
	
ENDCLASS

//-----------------------------------------------------------------
METHOD New() CLASS MATA020EVARG
Return

/*/{Protheus.doc} ModelPosVld
Executa a validação do modelo antes de realizar a gravação dos dados.
Se retornar falso, não permite gravar.

@type metodo
 
@author Juliane Venteu
@since 02/02/2017
@version P12.1.17
 
/*/
METHOD ModelPosVld(oModel, cID) CLASS MATA020EVARG
Local lValid := .T.
	
	::nOpc := oModel:GetOperation()	
	
	If ::nOpc == MODEL_OPERATION_INSERT .Or. ::nOpc == MODEL_OPERATION_UPDATE
		If M->A2_PORIVA < 100.00 .And. (Empty(M->A2_IVPCCOB) .Or. Dtos(M->A2_IVPCCOB) < Dtos(dDataBase))
			Help( ,, "A020IVA",, STR0017+Chr(13)+STR0018, 1, 0) //"Cuando el percentagen de retenciî‰¢ del IVA es menor que 100% es necesario "+Chr(13)+"ingresar una fecha valida para la observaciî‰¢."		
			lValid := .F.
		EndIf
	EndIf
			
Return lValid

/*/{Protheus.doc} InTTS
Metodo executado após a gravação dos dados, mas dentro da transação.

Não retorna nada, se chegou até aqui os dados serão gravados.

@type metodo
 
@author José Eulálio
@since 25/08/2017
@version P12.1.18

TSSERMI01-173 | Jose Glez | Se modifica la clase a MATA020EVARG
/*/
METHOD InTTS(oModel, cID) CLASS MATA020EVARG
Local lECommerce := SuperGetMV("MV_LJECOMM",.F.,.F.)
Local lRet       := .T.

//Limpa variavel para exportacao de dados do e-commerce.
If  lECommerce
	SA2->A2_ECDTEX := ""	
EndIf

Return lRet


