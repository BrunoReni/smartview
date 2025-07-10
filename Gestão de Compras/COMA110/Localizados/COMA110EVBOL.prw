#include 'Protheus.ch'
#include 'FWMVCDef.ch'
#INCLUDE "CM110.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} COMA110EVBOL
Fonte de eventos para a localiza��o Bol�via.
@author Luiz Henrique Bourscheid
@since 21/10/2017
@version 1.0
@return NIL
/*/
//-------------------------------------------------------------------
CLASS COMA110EVBOL From FWModelEvent
	
	METHOD New() CONSTRUCTOR
	
ENDCLASS

//-----------------------------------------------------------------
METHOD New() CLASS COMA110EVBOL
Return