#include 'Protheus.ch'
#include 'FWMVCDef.ch'
#INCLUDE "MATA020.CH"

/*/{Protheus.doc} MATA020EVCOL
Eventos do MVC para a COLOMBIA, qualquer regra que se aplique somente para COLOMBIA
deve ser criada aqui, se for uma regra geral deve estar em MATA020EVDEF.

Todas as valida��es de modelo, linha, pr� e pos, tamb�m todas as intera��es com a grava��o
s�o definidas nessa classe.

Importante: Use somente a fun��o Help para exibir mensagens ao usuario, pois apenas o help
� tratado pelo MVC. 

Documenta��o sobre eventos do MVC: http://tdn.totvs.com/pages/viewpage.action?pageId=269552294

@type classe
 
@author Juliane Venteu
@since 02/02/2017
@version P12.1.17
/*/
CLASS MATA020EVCOL From FWModelEvent
	
	DATA cCodigo
	DATA cLoja
	
	DATA nOPC
	
	METHOD New() CONSTRUCTOR
	
	METHOD InTTS()
	METHOD ModelPosVld()
	
ENDCLASS

//-----------------------------------------------------------------
METHOD New() CLASS MATA020EVCOL

Return

/*/{Protheus.doc} InTTS
Metodo executado ap�s a grava��o dos dados, mas dentro da transa��o.

N�o retorna nada, se chegou at� aqui os dados ser�o gravados.

@type metodo
 
@author Juliane Venteu
@since 02/02/2017
@version P12.1.17
 
/*/
METHOD InTTS(oModel, cID) CLASS MATA020EVCOL
Local aAreaCV0 := CV0->(GetArea())

M020AltCV0(::nOpc,::cCodigo)

RestArea(aAreaCV0)
Return

/*/{Protheus.doc} ModelPosVld
Executa a valida��o do modelo antes de realizar a grava��o dos dados.
Se retornar falso, n�o permite gravar.

@type metodo
 
@author Juliane Venteu
@since 02/02/2017
@version P12.1.17
 
/*/
METHOD ModelPosVld(oModel, cID) CLASS MATA020EVCOL
Local lValid := .T.

	::nOpc := oModel:GetOperation()
	::cCodigo := oModel:GetValue("SA2MASTER","A2_COD")
	::cLoja := oModel:GetValue("SA2MASTER","A2_LOJA")
		
	If ::nOpc == MODEL_OPERATION_UPDATE .Or. ::nOpc == MODEL_OPERATION_INSERT
		lValid  := A020ValDoc()

		If !Empty(M->A2_TIPDOC)
			If M->A2_TIPDOC=="31" //Tipo de Documento de Indetificacion NIT
				If EMPTY(M->A2_CGC)	                                          
					Help( ,, 'HELP',, STR0073, 1, 0) //Se debe indicar el campo NIT del Proveedor
					lValid:=.F.
			EndIf              
				IF !EMPTY(M->A2_PFISICA)
					Help( ,, 'HELP',, STR0074, 1, 0)//El campo RG/Ced Ext, debe estara Vacio
					lValid:=.F.
				Endif
			Else
				If !EMPTY(M->A2_CGC)	                                          
					Help( ,, 'HELP',, STR0075, 1, 0)//"El campo NIT del Proveedor, debe estara Vacio"
					lValid:=.F.
				EndIf              
				If EMPTY(M->A2_PFISICA)
					Help( ,, 'HELP',, STR0076, 1, 0)//Se debe indicar el campo RG/Ced Ext
					lValid:=.F.
				EndIf
			Endif  
		EndIf             
	EndIf

Return lValid

