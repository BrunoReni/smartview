#INCLUDE "MATA060.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWADAPTEREAI.CH"
#INCLUDE "TbIconn.ch"
#INCLUDE "TopConn.ch"  

/*/{Protheus.doc} MATA061EVDEF
Eventos padrão do relacionamento Produto x Fornecedor, as regras definidas aqui se aplicam a todos os paises.
Se uma regra for especifica para um ou mais paises ela deve ser feita no evento do pais correspondente. 

Todas as validações de modelo, linha, pré e pos, também todas as interações com a gravação
são definidas nessa classe.

Importante: Use somente a função Help para exibir mensagens ao usuario, pois apenas o help
é tratado pelo MVC.

Documentação sobre eventos do MVC: http://tdn.totvs.com/pages/viewpage.action?pageId=269552294

@type classe
 
@author Juliane Venteu
@since 14/03/2017
@version P12.1.17
 
/*/
CLASS MATA061EVDEF FROM FWModelEvent
	
	DATA cIDSA5Grid
	DATA aSitHist
	DATA lECommerce
	DATA lHistTab
	
	METHOD New() CONSTRUCTOR
	METHOD ModelPosVld()
	
	METHOD After()
	METHOD Before()
	METHOD GridLinePosVld()
			
	METHOD getCodProduto()
	METHOD getRefGrade()
	METHOD getDesRefGrade()
	METHOD VldDelete()
	
ENDCLASS

//-----------------------------------------------------------------
METHOD New(cIDGrid) CLASS MATA061EVDEF

Default cIDGrid := 'MdGridSA5'

::cIDSA5Grid := cIDGrid
::aSitHist	 := {}
::lECommerce := SuperGetMV("MV_LJECOMM",.F.,.F.)
::lHistTab	 := SuperGetMV("MV_HISTTAB",.F.,.F.)

Return

/*/{Protheus.doc} ModelPosVld
Executa a validação do modelo antes de realizar a gravação dos dados.
Se retornar falso, não permite gravar.

@type metodo
 
@author Juliane Venteu
@since 14/03/2017
@version P12.1.17
 
/*/
METHOD ModelPosVld(oModel, cID) CLASS MATA061EVDEF

Local lRet		:= .T.
Local oGrid
Local cProduto
		
	oGrid     := oModel:GetModel(::cIDSA5Grid)
	cProduto := ::getCodProduto(oModel)
		
	If oModel:GetOperation() # MODEL_OPERATION_DELETE
		If Empty(cProduto) .And. Empty(::getRefGrade(oModel))
			Help(" ",1,"A060OBRIGA")
			lRet := .F.
		EndIf
			
		//-- Verifica se os dados referentes ao RIAI estao preenchidos
		If !((Empty(oGrid:GetValue("A5_RIAI")).And. Empty(oGrid:GetValue("A5_DTRIAI")) .And. Empty(oGrid:GetValue("A5_VALRIAI"))) .Or.	(!Empty(oGrid:GetValue("A5_RIAI")).And. !Empty(oGrid:GetValue("A5_DTRIAI")) .And. !Empty(oGrid:GetValue("A5_VALRIAI"))))
			Help(" ",1,"A100RIAOBR")	// Data do RIAI e de sua validade sao obrigatorias
			lRet := .F.
		EndIf
	Else	
		lRet := ::VldDelete(oModel)		
	EndIf

	//Integração - Mensagem Unica
	If oModel:GetOperation() == MODEL_OPERATION_DELETE .Or. MODEL_OPERATION_UPDATE .Or. MODEL_OPERATION_INSERT
		If oModel:GetOperation() == MODEL_OPERATION_DELETE
			INCLUI := .F.
			ALTERA := .F.
		Elseif MODEL_OPERATION_UPDATE
			INCLUI := .F.
			ALTERA := .T.
		Else
			INCLUI := .T.
			ALTERA := .F.
		Endif
		lRet := Integ061()
	Endif	

Return lRet

/*/{Protheus.doc} VldDelete
Valida se o fornecedor pode ser excluido.

@type metodo
 
@author Juliane Venteu
@since 02/02/2017
@version P12.1.17
 
/*/
METHOD VldDelete(oModel, cID) CLASS MATA061EVDEF
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
		
	If cID == ::cIDSA5Grid	
		oGrid := oModel:GetModel(::cIDSA5Grid)
		nLineAtu := oGrid:GetLine()
		cProduto := ::getCodProduto(oModel)
		
		SB1->(dbSetOrder(1))
		SB1->(dbSeek(xFilial("SB1")+cProduto))	
				
		QEK->(dbSetOrder(1))
		QF4->(dbSetOrder(1))
		
		For nX := 1 To oGrid:Length()
			oGrid:GoLine(nX)
				
			cFornece := oGrid:GetValue("A5_FORNECE")
			cLoja := oGrid:GetValue("A5_LOJA")
				
				//-- Valida relacionamentos do EIC
			If GetMv("MV_EASY") = "S" .And. !(lRet := A060Dele())
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
				
			If lRet .And. SB1->B1_MONO == 'S' .And. SB1->B1_PROC == cFornece
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

/*/{Protheus.doc} After
Metodo executado depois da gravação de cada linha do grid e dentro da transação.
Nesse momento é feito a integração do fornecedor com o modulo QIE.

@type metodo
 
@author Juliane Venteu
@since 02/02/2017
@version P12.1.17
 
/*/
METHOD After(oSubModel,cID,cAlias,lNewRecord) CLASS MATA061EVDEF
Local nOpc := oSubModel:GetModel():GetOperation()
Local cSitAnt
Local cSklAnt
Local cChvHis
		
	If cID == ::cIDSA5Grid 
		If nOpc <> MODEL_OPERATION_DELETE .And. !oSubModel:IsDeleted() 	
			If !lNewRecord .And. nModulo == 21 //-- SIGAQIE
				If Len(::aSitHist) > 0
						
					cSitAnt := ::aSitHist[1]
					cSklAnt := ::aSitHist[2]
					cChvHis := ::aSitHist[3]
						
					If cSitAnt <> oSubModel:GetValue("A5_SITU") .And. !Empty(cSitAnt)
						// Monta/Obtem a chave para o Historico/Justificativa
						If Empty(cChvHis)
							cChvHis := A060Chave()
						EndIf
							
						// Digita a Justificativa e gera Historico da Situacao
						QA_JUST(OemToAnsi(STR0018),"MATA060T",cChvHis,.F.,cSitAnt) //"Justificativa Situacao"
					EndIf
						
					If cSklAnt <> oSubModel:GetValue("A5_SKPLOT") .And. !Empty(cSklAnt)
							// Monta/Obtem a chave para o Historico/Justificativa
						If Empty(cChvHis)
							cChvHis := A060Chave()
						EndIf
						
						If Empty(SA5->A5_SKPLOT) //-- Alter. automat. pelo sistema, ao alterar a Situacao
							RecLock("QA3",.T.)
							QA3->QA3_FILIAL := xFilial("QA3")
							QA3->QA3_ESPEC  := "MATA060L"
							QA3->QA3_CHAVE  := cChvHis
							QA3->QA3_TEXTO  := STR0019 //"Atualizado automaticamente pelo sistema."
							QA3->QA3_DATA   := dDataBase
							QA3->QA3_DATINV := Inverte(dDataBase)
							QA3->QA3_ANT    := cSklAnt
							QA3->(MsUnlock())
						Else
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³ Digita a Justificativa e gera Historico do Skip-Lote            ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							QA_JUST(STR0020,"MATA060L",cChvHis,.F.,cSklAnt) //"Justificativa Skip-Lote"
						EndIf
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf
Return

/*/{Protheus.doc} Before
Metodo executado antes da gravação de cada linha do grid e dentro da transação.
Nesse momento é gravado o historico de alterações e obtido os dados para integração com o QIE

@type metodo
 
@author Juliane Venteu
@since 14/03/2017
@version P12.1.17
 
/*/
METHOD Before(oSubModel,cID,cAlias,lNewRecord) CLASS MATA061EVDEF
Local nOpc := oSubModel:GetModel():GetOperation()
Local cSitAnt
Local cSklAnt
Local cChvHis
Local aAreaSA5 := SA5->(GetArea())
Local aFields := oSubModel:GetStruct():GetFields()
Local nY
Local nRecno
	
	If cID == ::cIDSA5Grid
		aSize(::aSitHist, 0)
				
		If nOpc <> MODEL_OPERATION_DELETE
			
			nRecno := oSubModel:GetDataID()
			If !lNewRecord .And. nRecno > 0 .and. !oSubModel:IsDeleted() 	
				SA5->(dbGoTo(nRecno))
				
				If nModulo == 21 //-- SIGAQIE														
					cSitAnt := SA5->A5_SITU
					cSklAnt := SA5->A5_SKPLOT
					cChvHis := SA5->A5_CHAVE
													
					aAdd(::aSitHist, cSitAnt)
					aAdd(::aSitHist, cSklAnt)
					aAdd(::aSitHist, cChvHis)
				EndIf
												
				If ::lHistTab
					For nY:=1 to Len(aFields)
						If oSubModel:IsFieldUpdated(aFields[nY][MODEL_FIELD_IDFIELD])
							MSGrvHist(xFilial("AIF"),;					// Filial de AIF
							xFilial("SA5"),;							// Filial da tabela SA2
							"SA5",;										// Tabela SA2
							SA5->A5_FORNECE,;							// Codigo do cliente
							SA5->A5_LOJA,;								// Loja do cliente
							aFields[nY][MODEL_FIELD_IDFIELD],;			// Campo alterado
							oSubModel:GetValue(aFields[nY][MODEL_FIELD_IDFIELD],oSubModel:nLine),;	// Conteudo antes da alteracao
							Date(),;									// Data da alteracao
							Time(),;									// Hora da alteracao
							SA5->A5_PRODUTO	)							// Codigo do produto
						EndIf
					Next nY							
				EndIf
			EndIf
			If !oSubModel:IsDeleted()
				If Empty(oSubModel:GetValue("A5_CHAVE"))
					oSubModel:LoadValue("A5_CHAVE", A060Chave())
				EndIf
				If Empty(oSubModel:GetValue("A5_DESREF"))
					oSubModel:LoadValue("A5_DESREF", ::getDesRefGrade(oSubModel:GetModel()))
				EndIf
				If !FwIsInCallStack("MATA010") .And. Empty(oSubModel:GetValue("A5_NOMPROD"))
					oSubModel:LoadValue("A5_NOMPROD", oSubModel:GetModel():GetValue("MdFieldSA5","A5_NOMPROD"))
				EndIf
			EndIf
		EndIf
		
		If nOpc == MODEL_OPERATION_DELETE .Or. oSubModel:IsDeleted()		
			//-- Limpa o campo para a exportacao da exclusao para o e-commerce
			If ::lECommerce .And. ColumnPos( "A5_ECDTEX" )
				RecLock("SA5",.F.)
				SA5->A5_ECDTEX := " "
				SA5->(MsUnLock())
			EndIf
		EndIf
	EndIf
	
RestArea(aAreaSA5)
Return

/*/{Protheus.doc} getCodProduto
Metodo para obter o codigo do produto.
O metodo é especifico pois dependendo do modelo que implementar o evento, o dado pode ser obtido de forma diferente

@type metodo
 
@author Juliane Venteu
@since 14/03/2017
@version P12.1.17
 
/*/
METHOD getCodProduto(oModel) CLASS MATA061EVDEF	
Return oModel:GetValue("MdFieldSA5", "A5_PRODUTO")

/*/{Protheus.doc} getRefGrade
Metodo para obter o codigo da grade.
O metodo é especifico pois dependendo do modelo que implementar o evento, o dado pode ser obtido de forma diferente

@type metodo
 
@author Juliane Venteu
@since 14/03/2017
@version P12.1.17
 
/*/
METHOD getRefGrade(oModel) CLASS MATA061EVDEF
Return oModel:GetValue("MdFieldSA5", "A5_REFGRD")

/*/{Protheus.doc} getDesRefGrade
Metodo para obter o descrição da grade.
O metodo é especifico pois dependendo do modelo que implementar o evento, o dado pode ser obtido de forma diferente

@type metodo
 
@author Kevin Alexander
@since 14/10/2019
@version P12.1.25
 
/*/
METHOD getDesRefGrade(oModel) CLASS MATA061EVDEF
Return oModel:GetValue("MdFieldSA5", "A5_DESREF")
/*/{Protheus.doc} GridLinePosVld
Pós Validação da linha.

@type metodo
 
@author Juliane Venteu
@since 14/03/2017
@version P12.1.17
 
/*/
METHOD GridLinePosVld(oSubModel, cID, nLine) CLASS MATA061EVDEF
Local lRet := .T.
	
	If cID == ::cIDSA5Grid
		If nModulo == 21
			Do Case
			Case Empty(FwFldGet('A5_SITU'))
				lRet := .F.
			Case Empty(FwFldGet('A5_FABREV'))
				lRet := .F.
			Case Empty(FwFldGet('A5_TEMPLIM')) .And. !Empty(FwFldGet('A5_SKPLOT'))
				lRet := .F.
			EndCase
		EndIf	
		
		If !lRet
			Help(" ",1,"MA060QIE")
		EndIf
	EndIf
	
Return lRet

/*/{Protheus.doc} Integ061
Verifica se possui integração via mensagem unica
habilitada.
 
@author rodrigo.mpontes
@since 02/02/2020
@version P12.1.17
 
/*/

Static Function Integ061()

Local aRet		 := {}
Local lRet		 := .T.
Local lIntegDef	 := FWHasEAI("MATA060",.T.,,.T.)

If lIntegDef
	aRet := FwIntegdef("MATA060")

	If ValType(aRet) == "A"
		If aRet[1]
			lRet := .T.
		Else
			lRet := .F.
			If !Empty(aRet[2])	
				Help(" ",1,"FWINTEGDEF",, aRet[2] ,3,0)
			Else
				Help(" ",1,"FWINTEGDEF",, STR0036,3,0) //"Verificar problema no Monitor EAI"
			Endif
		Endif
	Endif
Endif

Return lRet