#include 'Protheus.ch'
#include 'FWMVCDef.ch'
#include 'MATA020.ch'
Static lOGXUtlOri := FindFunction("OGXUtlOrig")
Static lOGA010InC := FindFunction("OGA010InCl")
Static lOGA010AlC := FindFunction("OGA010AlCl")
Static lOGA010ExC := FindFunction("OGA010ExCl")

/*/{Protheus.doc} MATA020EVPE
Eventos especificos para tratar chamadas a pontos de entrada já suportados pelo MVC.

Essa classe existe para manter o legado dos pontos de entrada do MATA020 quando não era MVC.
Os pontos de entrada são chamados nos mesmos momentos que é chamado no MATA020 sem MVC.

O ideal é que os clientes passem a usar o ponto de entrada do MVC e aos poucos não exista
mais a necessidade de manter a compatibilidade com o legado. Quando isso acontecer, basta
remover a instalação dessa classe no modelo MATA020.

Documentação sobre eventos do MVC: http://tdn.totvs.com/pages/viewpage.action?pageId=269552294

@type classe

@author Juliane Venteu
@since 02/02/2017
@version P12.1.17
/*/
CLASS MATA020EVPE FROM FWModelEvent

	DATA nOpc

	DATA lAuto
	DATA lMA020TOK
	DATA lMA020ALT
	DATA lA020DELE
	DATA lEICPMS01
	DATA lA020EOK
	DATA lMA020TDOK
	DATA lM020INC
	DATA lM020ALT
	DATA lM020EXC
	DATA lMT20FOPOS

	METHOD New() CONSTRUCTOR
	METHOD ModelPosVld()
	METHOD inTTS()
	METHOD AfterTTS()

ENDCLASS

//-----------------------------------------------------------------
METHOD New() CLASS MATA020EVPE
	::lMA020TOK := ExistBlock("MA020TOK")
	::lMA020ALT := ExistBlock("MA020ALT")
	::lA020DELE := Existblock("A020DELE")
	::lEICPMS01 := ExistBlock("EICPMS01")
	::lA020EOK := ExistBlock("A020EOK")
	::lMA020TDOK := ExistBlock("MA020TDOK")
	::lM020INC := ExistBlock("M020INC")
	::lM020ALT := ExistBlock("M020ALT")
	::lM020EXC := ExistBlock("M020EXC")
Return

/*/{Protheus.doc} ModelPosVld
Executa a validação do modelo antes de realizar a gravação dos dados.
Se retornar falso, não permite gravar.

@type metodo

@author Juliane Venteu
@since 02/02/2017
@version P12.1.17
/*/
METHOD ModelPosVld(oModel, cID) CLASS MATA020EVPE

Local lValid     := .T.
Local aArea      := GetArea()
Local aAreaSA2   := SA2->(GetArea())
Local aAreaSM0   := SM0->(GetArea())
Local aFilial    := {}
Local cBckFil    := cFilAnt
Local oViewAct   := FWViewActive()
Local nX

//------------------------------------------------------------------------------------------------------
// Tratamento para manter a variavel private l020Auto acessivel dentro dos pontos de entrada
//------------------------------------------------------------------------------------------------------
::lAuto := !(oViewAct <> NIL .And. oViewAct:oModel <> NIL .And. oViewAct:GetModel():GetSource() == "MATA020")
Private l020Auto := ::lAuto

::nOpc := oModel:GetOperation()

If ::nOpc == MODEL_OPERATION_INSERT
	If ::lMA020TDOK
		lValid := ExecBlock("MA020TDOK",.F.,.F.)
		If VALTYPE(lValid) <> "L"
			lValid := .T.
		EndIf
	EndIf

	If ::lMA020TOK .And. lValid
		lValid := ExecBlock("MA020TOK",.F.,.F.)
		If ValType(lValid) <> "L"
			lValid := .T.
		EndIf
	EndIf

ElseIf ::nOpc == MODEL_OPERATION_UPDATE
	If ::lMA020TDOK
		lValid := ExecBlock("MA020TDOK",.F.,.F.)
		If VALTYPE(lValid) <> "L"
			lValid := .T.
		EndIf
	EndIf

	If ::lMA020ALT .And. lValid
		lValid := ExecBlock("MA020ALT",.F.,.F.)
		If Valtype(lValid) <> "L"
			lValid := .T.
		EndIf
	EndIf

ElseIf ::nOpc == MODEL_OPERATION_DELETE
	If ::lA020DELE
		lValid := ExecBlock("A020DELE",.F.,.F.)
		If Valtype(lValid) <> "L"
			lValid := .T.
		EndIf
	EndIf

	If ::lEICPMS01 .And. lValid
		lValid := ExecBlock("EICPMS01",.F.,.F.,"CADFAB")
		If Valtype(lValid) <> "L"
			lValid := .F.
		EndIf
	EndIf

	If lValid
		If Empty(xFilial("SA2"))
			dbSelectArea("SM0")
			MsSeek(cEmpAnt)
			While ! Eof() .And. SM0->M0_CODIGO == cEmpAnt
				Aadd(aFilial,FWGETCODFILIAL)
				dbSkip()
			EndDo
		Else
			aadd(aFilial,cFilAnt)
		EndIf

		For nX := 1 To Len(aFilial)
			cFilAnt := aFilial[nX]

			If ::lA020EOK
				lValid := ExecBlock("A020EOK",.F.,.F.)
				If Valtype(lValid) <> "L"
					lValid := .T.
				EndIf
			EndIf

			If !lValid
				Exit
			EndIf
		Next nX
	EndIf
EndIf

cFilAnt := cBckFil
aSize(aFilial, 0)
RestArea(aAreaSM0)
RestArea(aAreaSA2)
RestArea(aArea)

Return lValid

/*/{Protheus.doc} inTTS
Metodo executado após a gravação dos dados, mas dentro da transação.

@type metodo

@author Juliane Venteu
@since 02/02/2017
@version P12.1.17
/*/
METHOD inTTS(oModel, cID) CLASS MATA020EVPE

Local aArea      := GetArea()
Local aAreaSA2   := SA2->(GetArea())

Private l020Auto := ::lAuto

If ::nOpc == MODEL_OPERATION_INSERT
	// *** Agroindustria ***
	If lOGXUtlOri .and. lOGA010InC .and. OGXUtlOrig()
		OGA010InCl()
	Endif

	If ::lM020INC
		ExecBlock("M020INC",.F.,.F.)
	EndIf

ElseIf ::nOpc == MODEL_OPERATION_UPDATE
	// *** Agroindustria ***
	If lOGXUtlOri .and. lOGA010AlC .and. OGXUtlOrig()
		OGA010AlCl()
	Endif

	If ::lM020ALT
		ExecBlock("M020ALT",.F.,.F.,{cFilAnt} )
	EndIf

ElseIf ::nOpc == MODEL_OPERATION_DELETE
	// *** Agroindustria ***
	If lOGXUtlOri .and. lOGA010ExC .and. OGXUtlOrig()
		OGA010ExCl()
	Endif

	If ::lM020EXC
		ExecBlock("M020EXC",.F.,.F.)
	EndIf
EndIf

RestArea(aAreaSA2)
RestArea(aArea)

Return .T.

/*/{Protheus.doc} AfterTTS
Metodo executado após a gravação dos dados e fora da transação.

@type metodo

@author Juliane Venteu
@since 02/02/2017
@version P12.1.17
/*/
METHOD AfterTTS(oMode, cID) CLASS MATA020EVPE
Private l020Auto := ::lAuto

If ::lMT20FOPOS
	ExecBlock("MT20FOPOS",.F.,.F.,{::nOpc})
EndIf
Return