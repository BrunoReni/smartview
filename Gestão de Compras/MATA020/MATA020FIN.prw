#INCLUDE "MATA020.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"                 
#INCLUDE "FWADAPTEREAI.CH"
#include "TbIconn.ch"
#include "TopConn.ch"
 
/*/{Protheus.doc} A020BCOFIN
Abre uma view com o grid de bancos do fornecedor.
Esse grid faz parte do modelo de dados do fornecedor, por isso, os dados dele serão salvos
somente quando o modelo MATA020 for gravado. 

@type function
 
@author Juliane Venteu
@since 02/02/2017
@version P12.1.17
 
/*/

Function A020BCOFIN(oView,cFieldsBanco)

Local oModel := oView:GetModel()
Local oViewBancos
Local oExecView
Local oStr
Local aMT020FIL

DEFAULT cFieldsBanco :=  "|FIL_BANCO|FIL_AGENCI|FIL_CONTA|FIL_TIPO|FIL_DETRAC|FIL_MOEDA|FIL_DVAGE|FIL_DVCTA|FIL_TIPCTA|FIL_MOVCTO|"
	
	//Adiciona na view campos que o usuario desejar da tabela FIL
	If ExistBlock("MT020FIL")
		aMT020FIL := ExecBlock("MT020FIL", .F.,.F.)
		If ValType(aMT020FIL) == 'A' .And. Len("aMT020FIL") >= 2
			cFieldsBanco	+= aMT020FIL[1]			
		EndIf
	EndIf
	
	oStr:= FWFormStruct(2, 'FIL', {|cField| AllTrim(Upper(cField)) $ AllTrim(Upper(cFieldsBanco)) })
	
	//--------------------------------------------------------------------------------
	//	Monta a view para exibir o grid
	// oView é passado por parametro para indicar que oViewBancos é filho do oView
	//--------------------------------------------------------------------------------
	oViewBancos := FWFormView():New(oView) 	
	oViewBancos:SetModel(oModel)
	oViewBancos:AddGrid('FORM' , oStr,'BANCOS' )	
	oViewBancos:CreateHorizontalBox( 'BOX', 100)
	oViewBancos:SetOwnerView('FORM','BOX')
	oViewBancos:SetCloseOnOk({|| A020MVldBc(oView)})
	oViewBancos:SetAfterOkButton({|| A020MSetBc(oView)})

	//--------------------------------------------------------------------------------
	// Monta a janela para exibir o view. Não é usado o FWExecView porque o FWExecView
	// obriga a passar o fonte para carregar a View e aqui já temos a view pronta
	//--------------------------------------------------------------------------------
	oExecView := FWViewExec():New()
	oExecView:SetView(oViewBancos)
	oExecView:setTitle(STR0084)
	oExecView:SetModel(oModel)
	oExecView:setModal(.F.)					
	oExecView:setOperation(oModel:GetOperation())
	oExecView:openView(.F.)	
	
Return

/*/{Protheus.doc} A020MVldBc
Funcao de validacao do botao Ok da interface de bancos

@type Static Function
@author Totvs
@since 20/02/2018
@version P12.1.17
/*/
Static Function A020MVldBc(oView)
 
Local oModel  := oView:GetModel()
Local oGrid   := oModel:GetModel("BANCOS")
Local nOpc    := oModel:GetOperation()
Local nX      := 0
Local nPrinc  := 0
Local nLine   := 0
Local lRet    := .T.

If nOpc == MODEL_OPERATION_INSERT .Or. nOpc == MODEL_OPERATION_UPDATE
	//-----------------------------------------------------------------------------
	// Verifica se existe uma e somente uma conta principal
	//-----------------------------------------------------------------------------
	If !oGrid:IsEmpty() .And. oGrid:Length(.T.) > 0 //Verifica se tem alguma linha nao deletada
		For nX := 1 To oGrid:Length()
			If !oGrid:IsDeleted(nX)
				If oGrid:GetValue("FIL_TIPO",nX) == "1"
					nPrinc++
					nLine := nX
				EndIf
			EndIf
		Next nX
 
		If nPrinc > 1
			lRet := .F.
			Help( ,, 'BANCOS',, STR0040+CRLF+STR0043, 1, 0)
		ElseIf nPrinc == 0 .And. oGrid:GetLine() > 0 .And. ;
			(!Empty(oGrid:GetValue("FIL_BANCO",oGrid:GetLine())) .Or. !Empty(oGrid:GetValue("FIL_AGENCI",oGrid:GetLine())) .Or.;
			!Empty(oGrid:GetValue("FIL_CONTA ",oGrid:GetLine())))
			lRet := .F.
			Help( ,, 'BANCOS',, STR0041+CRLF+STR0042, 1, 0)
		ElseIf nPrinc == 1 .And. nLine > 0
			If Empty(oGrid:GetValue("FIL_BANCO",nLine)) .Or. Empty(oGrid:GetValue("FIL_AGENCI",nLine)) .Or. Empty(oGrid:GetValue("FIL_CONTA ",nLine))
				lRet := .F.
			Help( ,, 'BANCOS',, STR0083, 1, 0)
			EndIf 
		EndIf
	EndIf
EndIf

Return lRet

/*/{Protheus.doc} A020MSetBc
Caso o fornecedor possua bancos relacionados, seta os dados da conta principal
no model do fornecedor

@type Static Function
@author Totvs
@since 20/02/2018
@version P12.1.17
/*/
Static Function A020MSetBc(oView)

Local oModel    := oView:GetModel()
Local oGrid     := oModel:GetModel("BANCOS")
Local oField    := oModel:GetModel("SA2MASTER")
Local nOpc      := oModel:GetOperation()
Local nX        := 0
Local lTemDados := .F.

If nOpc == MODEL_OPERATION_INSERT .Or. nOpc == MODEL_OPERATION_UPDATE
	If !oGrid:IsEmpty()
		For nX:=1 to oGrid:Length()
			If !oGrid:IsDeleted(nX) .And. oGrid:GetValue("FIL_TIPO",nX) == "1" .And. !Empty(oGrid:GetValue("FIL_BANCO",nX)) .And. !Empty(oGrid:GetValue("FIL_AGENCI",nX)) .And. !Empty(oGrid:GetValue("FIL_CONTA ",nX))
				lTemDados := .T.
				If oGrid:HasField("FIL_BANCO") .and. (cPaisLoc <> "RUS" .Or. Iif(empty(GetSx3Cache("A2_BANCO", "X3_WHEN")),.T.,&(GetSx3Cache("A2_BANCO", "X3_WHEN") )))
					oField:SetValue("A2_BANCO", oGrid:GetValue("FIL_BANCO",nX))
				EndIf
				If oGrid:HasField("FIL_AGENCI") .and. (cPaisLoc <> "RUS" .Or. Iif(empty(GetSx3Cache("A2_AGENCIA", "X3_WHEN")),.T.,&(GetSx3Cache("A2_AGENCIA", "X3_WHEN") )))
					oField:SetValue("A2_AGENCIA", oGrid:GetValue("FIL_AGENCI",nX))
				EndIf
				If oGrid:HasField("FIL_DVAGE") .and. (cPaisLoc <> "RUS" .Or. Iif(empty(GetSx3Cache("A2_DVAGE", "X3_WHEN")),.T.,&(GetSx3Cache("A2_DVAGE", "X3_WHEN") )))
					oField:SetValue("A2_DVAGE", oGrid:GetValue("FIL_DVAGE",nX))
				EndIf
				If oGrid:HasField("FIL_CONTA") .and. (cPaisLoc <> "RUS" .Or. Iif(empty(GetSx3Cache("A2_NUMCON", "X3_WHEN")),.T.,&(GetSx3Cache("A2_NUMCON", "X3_WHEN") )))
					oField:SetValue("A2_NUMCON", oGrid:GetValue("FIL_CONTA",nX))
				EndIf
				If oGrid:HasField("FIL_DVCTA") .and. (cPaisLoc <> "RUS" .Or. Iif(empty(GetSx3Cache("A2_DVCTA", "X3_WHEN")),.T.,&(GetSx3Cache("A2_DVCTA", "X3_WHEN") )))
					oField:SetValue("A2_DVCTA", oGrid:GetValue("FIL_DVCTA",nX))
				EndIf
				If oGrid:HasField("FIL_TIPCTA") .and. (cPaisLoc <> "RUS" .Or. Iif(empty(GetSx3Cache("A2_TIPCTA", "X3_WHEN")),.T.,&(GetSx3Cache("A2_TIPCTA", "X3_WHEN") )))
					oField:SetValue("A2_TIPCTA", oGrid:GetValue("FIL_TIPCTA",nX))
				EndIf
				Exit
			EndIf
		Next nX
		If !lTemDados
			oField:SetValue("A2_BANCO", " ")
			oField:SetValue("A2_AGENCIA", " ")
			oField:SetValue("A2_DVAGE",  " ")
			oField:SetValue("A2_NUMCON",  " ")
			oField:SetValue("A2_DVCTA",  " ")
			oField:SetValue("A2_TIPCTA",  oField:InitValue("A2_TIPCTA"))
		EndIf
	EndIf
EndIf

Return

/*/{Protheus.doc} A020PROCREF
Abre uma view com o grid de processos referenciados
 
@author rodrigo.mpontes
@since 30/08/2019
@version P12.1.17
 
/*/

Function A020PROCREF(oView)

Local oModel 		:= oView:GetModel()
Local oViewProcRef
Local oExecView
Local oStr

oStr:= FWFormStruct(2,'DHS')

//--------------------------------------------------------------------------------
//	Monta a view para exibir o grid
// oView é passado por parametro para indicar que oViewBancos é filho do oView
//--------------------------------------------------------------------------------
oViewProcRef := FWFormView():New(oView) 	
oViewProcRef:SetModel(oModel)
oViewProcRef:AddGrid('FORM',oStr,'PROCREF' )	
oViewProcRef:CreateHorizontalBox('BOX', 100)
oViewProcRef:SetOwnerView('FORM','BOX')
oViewProcRef:SetCloseOnOk({|| A020VldDHS(oView)})

//--------------------------------------------------------------------------------
// Monta a janela para exibir o view. Não é usado o FWExecView porque o FWExecView
// obriga a passar o fonte para carregar a View e aqui já temos a view pronta
//--------------------------------------------------------------------------------
oExecView := FWViewExec():New()
oExecView:SetView(oViewProcRef)
oExecView:setTitle(STR0089) //"Fornecedor x Processos Referenciados (REINF)"
oExecView:SetModel(oModel)
oExecView:setModal(.F.)					
oExecView:setOperation(oModel:GetOperation())
oExecView:openView(.F.)	
	
Return

/*/{Protheus.doc} A020VldDHS
validação da grid de processos referenciados
 
@author rodrigo.mpontes
@since 30/08/2019
@version P12.1.17
 
/*/

Static Function A020VldDHS(oView)

Local oModel  := oView:GetModel()
Local oGrid   := oModel:GetModel("PROCREF")
Local nOpc    := oModel:GetOperation()
Local nX      := 0
Local lRet    := .T.

If nOpc == MODEL_OPERATION_INSERT .Or. nOpc == MODEL_OPERATION_UPDATE
	If !oGrid:IsEmpty() .And. oGrid:Length(.T.) > 0 //Verifica se tem alguma linha nao deletada
		For nX := 1 To oGrid:Length()
			If !oGrid:IsDeleted(nX)
				If Empty(oGrid:GetValue("DHS_NUMERO",nX))
					lRet := .F.
					Help( ,, 'PROCREF',,STR0090, 1, 0) //"Informar o numero do processo referenciado."
					Exit
				Elseif !Empty(oGrid:GetValue("DHS_NUMERO",nX)) .And. Empty(oGrid:GetValue("DHS_TIPO",nX))
					lRet := .F.
					Help( ,, 'PROCREF',,STR0094, 1, 0) //"Preencher o tipo de suspensão"
					Exit
				Elseif !Empty(oGrid:GetValue("DHS_NUMERO",nX)) .And. !Empty(oGrid:GetValue("DHS_TIPO",nX))
					lRet := A020VLDPRO(oGrid:GetValue("DHS_NUMERO",nX),oGrid:GetValue("DHS_TIPO",nX),oGrid:GetValue("DHS_INDSUS",nX))
					If !lRet
						Help( ,, 'PROCREF',,STR0095,1,0) //"Processo não existe no cadastro de processos referenciados (CCF)"
						Exit
					Endif 
				EndIf
			EndIf
		Next nX
	Endif
EndIf

Return lRet

/*/{Protheus.doc} A020VLDPRO
validação da existencia do processo referenciado

@param cProcesso	Numero do processo
@param cTipo		Tipo do processo
@param cIndSusp		Codigo indicativo da suspensão

@author rodrigo.mpontes
@since 30/08/2019
@version P12.1.17
 
/*/

Static Function A020VLDPRO(cProcesso,cTipo,cIndSusp)

Local lRet 		:= .F.
Local cQry 		:= ""
Local cAliasTmp	:= GetNextAlias()

cQry := " SELECT R_E_C_N_O_ AS RECNO"
cQry += " FROM " + RetSqlName("CCF")
cQry += " WHERE D_E_L_E_T_ = ''"
cQry += " AND CCF_FILIAL = '" + xFilial("CCF") + "'"
cQry += " AND CCF_NUMERO = '" + cProcesso + "'"   
cQry += " AND CCF_TIPO = '" + cTipo + "'"

If !Empty(cIndSusp)
	cQry += " AND CCF_INDSUS = '" + cIndSusp + "'"
Endif

cQry := ChangeQuery(cQry)

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),cAliasTmp,.T.,.T.)

DbSelectArea(cAliasTmp)
If (cAliasTmp)->(!EOF())
	lRet := .T.
Endif

(cAliasTmp)->(DbCloseArea())

Return lRet

/*/{Protheus.doc} A020DEP
Abre uma view com o grid de dependentes
 
@author rodrigo.mpontes
@since 30/08/2019
@version P12.1.17
 
/*/

Function A020DEP(oView)

Local oModel 		:= oView:GetModel()
Local oViewDep
Local oExecView
Local oStr

oStr:= FWFormStruct(2,'DHT')
	
//--------------------------------------------------------------------------------
//	Monta a view para exibir o grid
// oView é passado por parametro para indicar que oViewBancos é filho do oView
//--------------------------------------------------------------------------------
oViewDep := FWFormView():New(oView) 	
oViewDep:SetModel(oModel)
oViewDep:AddGrid('FORM',oStr,'SA2DEP' )	
oViewDep:CreateHorizontalBox('BOX', 100)
oViewDep:SetOwnerView('FORM','BOX')
oViewDep:AddIncrementField("SA2DEP", "DHT_COD")
oViewDep:SetCloseOnOk({|| A020VldDHT(oView)})

//--------------------------------------------------------------------------------
// Monta a janela para exibir o view. Não é usado o FWExecView porque o FWExecView
// obriga a passar o fonte para carregar a View e aqui já temos a view pronta
//--------------------------------------------------------------------------------
oExecView := FWViewExec():New()
oExecView:SetView(oViewDep)
oExecView:setTitle(STR0091) //"Fornecedor x Dependentes (REINF)"
oExecView:SetModel(oModel)
oExecView:setModal(.F.)					
oExecView:setOperation(oModel:GetOperation())
oExecView:openView(.F.)
	
Return

/*/{Protheus.doc} A020VldDHT
validação da grid de dependentes
 
@author rodrigo.mpontes
@since 30/08/2019
@version P12.1.17
 
/*/

Static Function A020VldDHT(oView)

Local oModel  := oView:GetModel()
Local oGrid   := oModel:GetModel("SA2DEP")
Local nOpc    := oModel:GetOperation()
Local nX      := 0
Local nZ	  := 0
Local lRet    := .T.

If nOpc == MODEL_OPERATION_INSERT .Or. nOpc == MODEL_OPERATION_UPDATE
	If !oGrid:IsEmpty() .And. oGrid:Length(.T.) > 0 //Verifica se tem alguma linha nao deletada
		For nX := 1 To oGrid:Length()
			If !oGrid:IsDeleted(nX)
				If Empty(oGrid:GetValue("DHT_NOME",nX)) .Or. Empty(oGrid:GetValue("DHT_CPF",nX)) .Or. Empty(oGrid:GetValue("DHT_DTNASC",nX)) .Or. Empty(oGrid:GetValue("DHT_RELACA",nX))
					lRet := .F.
					Help( ,, 'SA2DEP',,STR0092, 1, 0) //"Preencher todos as informações"
					Exit
				Elseif !Empty(oGrid:GetValue("DHT_CPF",nX))
					lRet := CGC(oGrid:GetValue("DHT_CPF",nX))
					
					If lRet
						For nZ := nX+1 To oGrid:Length()
							If oGrid:GetValue("DHT_CPF",nX) == oGrid:GetValue("DHT_CPF",nZ)
								lRet := .F.
								Help( ,, 'SA2DEP',,STR0096, 1, 0) //"CPF em duplicidade."
								Exit
							Endif
						Next nZ
					Endif
					
					If !lRet
						Exit
					Endif
				EndIf
			EndIf
		Next nX
	Endif
EndIf

Return lRet
