#include 'Protheus.ch'
#include 'FWMVCDef.ch'
#include 'MATA020.ch'

/*/{Protheus.doc} MATA020EVRUS
Eventos do MVC para a RUSSIA, qualquer regra que se aplique somente para RUSSIA
deve ser criada aqui, se for uma regra geral deve estar em MATA020EVDEF.

Todas as valida��es de modelo, linha, pr� e pos, tamb�m todas as intera��es com a grava��o
s�o definidas nessa classe.

Importante: Use somente a fun��o Help para exibir mensagens ao usuario, pois apenas o help
� tratado pelo MVC. 

Documenta��o sobre eventos do MVC: http://tdn.totvs.com/pages/viewpage.action?pageId=269552294

@type classe
 
@author Jos� Eul�lio
@since 26/09/2017
@version P12.1.17
/*/
CLASS MATA020EVRUS From FWModelEvent
	
	DATA nOpc
	
	METHOD New() CONSTRUCTOR
	
	METHOD Activate()
	METHOD GridLinePosVld()
	
ENDCLASS

//-----------------------------------------------------------------
METHOD New() CLASS MATA020EVRUS
Return

//-------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GridLinePosVld
M�todo que � chamado pelo MVC quando ocorrer as a��es de p�s valida��o da linha do Grid

@type metodo
 
@author Felipe Morais
@since 07/02/2018
@version P12.1.17
/*/
//-------------------------------------------------------------------------------------------------------
METHOD GridLinePosVld(oSubModel, cModelID, nLine) CLASS MATA020EVRUS
Local lValid	:= .T.

If cModelId == "BANCOS"
	If Empty(oSubModel:GetValue("FIL_CONTA"))
		Help(" ",1,"MA020NOACCOUNT")//It is mandatory to fill the field Account number.
		lValid := .F.
	ElseIf Empty(oSubModel:GetValue("FIL_AGENCI"))
		Help(" ",1,"MA020NOAGENCY")//It is mandatory to fill the field Agency/BIK code.
		lValid := .F.
	EndIf
	
	If oSubModel:GetValue("FIL_TIPO") == "1" .And. oSubModel:GetValue("FIL_CLOSED") == "1"
		Help(" ",1,"MA020BLKMAIN") //It is not possible to block a Main Account or set as main a blocked account.
		lValid := .F.
	EndIf
	
EndIf

Return lValid

//-------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Activate
M�todo que � chamado pelo MVC quando ocorrer a ativa��o do Model.

@type metodo
 
@author Jos� Eul�lio
@since 22/09/2017
@version P12.1.17
/*/
//-------------------------------------------------------------------------------------------------------
METHOD Activate(oModel, lCopy) CLASS MATA020EVRUS

::nOpc := oModel:GetOperation()

//Remove tecla de atalho
Set Key VK_F2 To
Set Key K_CTRL_A To

If ::nOpc == MODEL_OPERATION_UPDATE
	SetKey(VK_F2,{|| TDFieldActv()})
	SetKey(K_CTRL_A,{|| CRMA680RUS("SA2",xFilial("SA2")+ SA2->A2_COD + SA2->A2_LOJA)})
ElseIf ::nOpc == MODEL_OPERATION_VIEW
	SetKey(K_CTRL_A,{|| CRMA680RUS("SA2",xFilial("SA2")+ SA2->A2_COD + SA2->A2_LOJA,.T.)})
EndIf

Return