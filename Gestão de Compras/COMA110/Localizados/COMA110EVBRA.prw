#include 'Protheus.ch'
#include 'FWMVCDef.ch'
#INCLUDE "CM110.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} COMA110EVBRA
Fonte de eventos para a localização Brasil.
@author Luiz Henrique Bourscheid
@since 21/10/2017
@version 1.0
@return NIL
/*/
//-------------------------------------------------------------------
CLASS COMA110EVBRA From FWModelEvent
	
	METHOD New() CONSTRUCTOR
	
ENDCLASS

//-----------------------------------------------------------------
METHOD New() CLASS COMA110EVBRA
Return