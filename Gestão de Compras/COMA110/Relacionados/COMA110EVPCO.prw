#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "FWMVCDEF.CH"                 
#INCLUDE "FWADAPTEREAI.CH"
#include "TbIconn.ch"
#include "TopConn.ch"

/*/{Protheus.doc} COMA110EVPCO
Eventos do MVC relacionado a integração da solicitação de compras
com o modulo SIGAPCO
@author Leonardo Bratti
@since 03/10/2017
@version P12.1.17 
/*/

CLASS COMA110EVPCO FROM FWModelEvent
	
	METHOD New() CONSTRUCTOR
	METHOD GridLinePosVld()
	METHOD BeforeTTS()
	METHOD InTTS()
	METHOD VldActivate()
	
ENDCLASS

METHOD New() CLASS  COMA110EVPCO

	
Return

//----------------------------------------------------------------------
/*/{Protheus.doc} GridLinePosVld()
Validações de linha do PCO
@author Leonardo Bratti
@since 09/10/2017
@version 1.0
@return .T.
/*/
//----------------------------------------------------------------------
METHOD GridLinePosVld(oModel, cID, nLine) CLASS COMA110EVPCO
 	Local lRet          := .T.

 	If cID == "SC1DETAIL"
 		lDeleted      := IsDeleted()
 		lRet:=	PcoVldLan('000051','01','MATA110',/*lUsaLote*/,lDeleted/*lDeleta*/, .T./*lVldLinGrade*/) 		
	EndIf
Return lRet

//----------------------------------------------------------------------
/*/{Protheus.doc} BeforeTTS()
Inicio da transação antes da gravação
@author Leonardo Bratti
@since 09/10/2017
@version 1.0
@return .T.
/*/
//----------------------------------------------------------------------
METHOD BeforeTTS(oModel, cModelId) Class COMA110EVPCO
	PcoIniLan("000051")
Return .T.

//----------------------------------------------------------------------
/*/{Protheus.doc} InTTS()
Após as gravações porém antes do final da transação
@author Leonardo Bratti
@since 09/10/2017
@version 1.0
@return .T.
/*/
//----------------------------------------------------------------------
Method InTTS(oModel, cModelId) Class COMA110EVPCO
	PcoFinLan("000051")
	PcoFreeBlq("000051",,,,,/*lCancela*/)	
Return .T.

Method VldActivate(oModel, cModelId) Class COMA110EVPCO	
	Local lRet  := .T.
	
	If cModelId == "SC1DETAIL" 
			lRet :=  PmsVldSC(oModel:GetOldData()[1],oModel:GetOldData()[2],SC1->C1_NUM, .T.) 		
	EndIf	
Return lRet