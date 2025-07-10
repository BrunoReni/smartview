#include 'Protheus.ch'
#include 'FWMVCDef.ch'
#INCLUDE "CM110.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} COMA110EVEQU
Fonte de eventos para a localização Equador.
@author Luiz Henrique Bourscheid
@since 21/10/2017
@version 1.0
@return NIL
/*/
//-------------------------------------------------------------------
CLASS COMA110EVEQU From FWModelEvent
	
	METHOD New() CONSTRUCTOR
	
ENDCLASS

//-----------------------------------------------------------------
METHOD New() CLASS COMA110EVEQU
Return