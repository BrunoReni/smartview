#INCLUDE "MATA060.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

/*/{Protheus.doc} MATA010Fornecedores
Evento usado pela rotina MATA010 para o relacionamento Produto x Fornecedor.
Como a rotina MATA010 e MATA061 possuem o mesmo grid (SA5) essa classe herda os eventos do MATA061
e sobrescreve apenas os metodos referentes aos dados do produto, pois na MATA010 o produto está no modelo com os
dados do SB1 e no MATA061 com os dados do SA5.

Importante: Use somente a função Help para exibir mensagens ao usuario, pois apenas o help
é tratado pelo MVC. 

Documentação sobre eventos do MVC: http://tdn.totvs.com/pages/viewpage.action?pageId=269552294

@type classe
 
@author Juliane Venteu
@since 14/03/2017
@version P12.1.17
 
/*/
CLASS MATA010Fornecedores FROM MATA061EVDEF

	METHOD New() CONSTRUCTOR
	
	METHOD getCodProduto()
	METHOD getRefGrade()
	METHOD getDesRefGrade()
	METHOD VldDelete()
	METHOD GridLinePosVld()
	METHOD Before()
ENDCLASS

//-----------------------------------------------------------------
METHOD New(cIDSA5) CLASS MATA010Fornecedores
	_Super:New(cIDSA5)
Return

METHOD getCodProduto(oModel) CLASS MATA010Fornecedores	
Return oModel:GetValue("SB1MASTER", "B1_COD")

METHOD getRefGrade(oModel) CLASS MATA010Fornecedores
Return oModel:GetValue("MdGridSA5", "A5_REFGRD")

METHOD getDesRefGrade(oModel) CLASS MATA010Fornecedores
Return oModel:GetValue("MdGridSA5", "A5_DESREF")

METHOD VldDelete(oModel, cID) CLASS MATA010Fornecedores
Local oGrid
Local lRet := .T.
Local nLineAtu
Local cFornece
Local cLoja
Local nX
Local cProduto
Local aAreaQEK := QEK->(GetArea())
Local aAreaQF4 := QF4->(GetArea())
Local aAreaSB1 := SB1->(GetArea())
Local cEasy := GetMv("MV_EASY")
	
	If cID == ::cIDSA5Grid		
		oGrid := oModel:GetModel(::cIDSA5Grid)
		nLineAtu := oGrid:GetLine()		
		cProduto := ::getCodProduto(oModel)
			
		QEK->(dbSetOrder(1))
		QF4->(dbSetOrder(1))
		
		For nX := 1 To oGrid:Length()
			oGrid:GoLine(nX)
				
			cFornece := oGrid:GetValue("A5_FORNECE")
			cLoja := oGrid:GetValue("A5_LOJA")
				
			//-- Valida relacionamentos do EIC
			If cEasy = "S" .And. !(lRet := A060Dele())
				Exit
			EndIf
						
				//-- Valida relacionamentos do QIE
			If lRet .And. RetFldProd(cProduto,"B1_TIPOCQ") == 'Q'
					//-- Verifica se existem entradas cadastradas	
				If QEK->(dbSeek(xFilial("QEK")+cFornece+cLoja+cProduto))
					Help(" ",1,"QEXISTENTR")
					lRet := .F.
					Exit
					//-- Verifica se existem planos de amostragens por ensaios associados ao fornecedor
				ElseIf QF4->(dbSeek(xFilial("QF4")+cFornece+cLoja+cProduto))
					Help(" ",1,"QEXISTPLAM")
					lRet := .F.
					Exit
				EndIf
			EndIf
				
			If lRet .And. oModel:GetValue("SB1MASTER","B1_MONO") == 'S' .And. oModel:GetValue("SB1MASTER", "B1_PROC") == cFornece
				Help(" ",1,"EXISTFDC")
				lRet := .F.
				Exit
			EndIf
		Next nX
			
		oGrid:GoLine(nLineAtu)
	EndIf
	
RestArea(aAreaSB1)
RestArea(aAreaQF4)
RestArea(aAreaQEK)	
Return lRet

METHOD GridLinePosVld(oSubModel, cID, nLine) CLASS MATA010Fornecedores
Local lRet := .T.
Local oModel
Local oView := FWViewActive()
	
	If cID == ::cIDSA5Grid			
		oModel := oSubModel:GetModel()			
				
		If oModel:GetValue("SB1MASTER","B1_MONO") == 'S' .And. oModel:GetValue("SB1MASTER", "B1_PROC") <> oSubModel:GetValue("A5_FORNECE")
			Help(" ",1, STR0024)
			lRet := .F.
		EndIf
				
		If lRet
			lRet := _Super:GridLinePosVld(oSubModel, cID, nLine)
		EndIf
	EndIf
	
Return lRet

METHOD Before(oSubModel,cID,cAlias,lNewRecord) CLASS MATA010Fornecedores
	
	If cID == ::cIDSA5Grid 
		If (oSubModel:GetModel():GetOperation() == MODEL_OPERATION_INSERT) .Or. oSubModel:GetModel():GetOperation() == MODEL_OPERATION_UPDATE
			oSubModel:LoadValue("A5_NOMPROD", oSubModel:GetModel():GetValue("SB1MASTER","B1_DESC"))
		EndIf
		
		_Super:Before(oSubModel,cID,cAlias,lNewRecord)
	EndIf
	
Return