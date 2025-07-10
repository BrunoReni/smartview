#INCLUDE "PROTHEUS.CH"
#INCLUDE "CM110.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "FWMVCDEF.CH"                 
#INCLUDE "FWADAPTEREAI.CH"
#include "TbIconn.ch"
#include "TopConn.ch"

/*/{Protheus.doc} COMA110EVEIC
Eventos do MVC relacionado a integração da solicitação de compras
com o modulo SIGAEIC
@author Leonardo Bratti
@since 28/09/2017
@version P12.1.17 
/*/

CLASS COMA110EVEIC FROM FWModelEvent
	DATA lMvEasy
	
	METHOD New() CONSTRUCTOR
	METHOD GridLinePosVld()
	
ENDCLASS

METHOD New() CLASS  COMA110EVEIC
	::lMvEasy := SuperGetMV('MV_EASY',,'N') $ "Y1S" 
	
Return

//----------------------------------------------------------------------
/*/{Protheus.doc} GridLinePosVld()
Validações de linha do EIC
@author Leonardo Bratti
@since 09/10/2017
@version 1.0
@return .T.
/*/
//----------------------------------------------------------------------
METHOD GridLinePosVld(oModel, cID, nLine) CLASS COMA110EVEIC
 	Local lRet          := .T.
 	Local cProduto     
 	Local cSegUm       
 	Local nQtde2Um     

 	If cID == "SC1DETAIL"
 		cProduto      := oModel:getValue("C1_PRODUTO")
 		cSegUm        := oModel:getValue("C1_SEGUM")
 		nQtde2Um      := oModel:getValue("C1_QTSEGUM")
 		If ::lMvEasy
 			//Valida Segunda Unidade de Medida EIC
 			If (!Empty(cSegUm) .and. ! nQtde2Um > 0) .or. (Empty(cSegUm) .and.  nQtde2Um > 0)
				Help(" ",1,"SC2UMEIC")
				lRet := .F.
			EndIf
 		EndIf

	EndIf
Return lRet

//--------------------------------------------------------------------
/*/{Protheus.doc} LoadLegSI()
Carrega as legendas do EIC
@author Leonardo Bratti
@since 27/09/2017
@version 1.0
@return lRetorno
/*/
//--------------------------------------------------------------------
Function LoadLegSI(oBrowse)
		oBrowse:AddLegend('C1_QUJE == 0 .And. (C1_COTACAO == Space(Len(C1_COTACAO)) .Or. C1_COTACAO == "IMPORT") .And. C1_APROV == "R"','BR_LARANJA' , STR0076    )
		oBrowse:AddLegend('C1_QUJE == 0 .And. (C1_COTACAO == Space(Len(C1_COTACAO)) .Or. C1_COTACAO == "IMPORT") .And. C1_APROV == "B"','BR_CINZA'   , STR0077    )
		oBrowse:AddLegend('C1_QUJE == 0 .And. C1_COTACAO <> Space(Len(C1_COTACAO)) .And. C1_IMPORT == "S" .And.C1_APROV $ " ,L"','BR_PINK'           , STR0078    )		
Return