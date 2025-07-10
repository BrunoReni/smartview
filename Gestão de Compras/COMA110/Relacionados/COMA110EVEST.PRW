#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "FWMVCDEF.CH"                 
#INCLUDE "FWADAPTEREAI.CH"
#include "TbIconn.ch"
#include "TopConn.ch"

/*/{Protheus.doc} COMA110EVPCO
Eventos do MVC relacionado a integração da solicitação de compras
com o modulo SIGAEST
@author Leonardo Bratti
@since 03/10/2017
@version P12.1.17 
/*/

CLASS COMA110EVEST FROM FWModelEvent
	
	METHOD New() CONSTRUCTOR
	METHOD GridLinePosVld()
	
ENDCLASS

METHOD New() CLASS  COMA110EVEST

	
Return

//----------------------------------------------------------------------
/*/{Protheus.doc} GridLinePosVld()
Validações de linha do EST
@author Leonardo Bratti
@since 09/10/2017
@version 1.0
@return .T.
/*/
//----------------------------------------------------------------------
METHOD GridLinePosVld(oModel, cID, nLine) CLASS COMA110EVEST
 	Local lRet      := .T.

 	If cID == "SC1DETAIL"
 		lRet := a241vldfan(oModel:getValue("C1_PRODUTO")) 		
	EndIf
Return lRet
