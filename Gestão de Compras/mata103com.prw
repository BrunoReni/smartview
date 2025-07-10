#INCLUDE "MATA103COM.CH"
#include "protheus.ch"

Static lDHQInDic  := (FwAliasInDic("DHQ") .and. SF4->(FieldPos("F4_EFUTUR") > 0))
Static nPrecisao  := TamSX3("D1_VUNIT")[2]
Static lLGPD  	  := FindFunction("SuprLGPD") .And. SuprLGPD()

/*/{Protheus.doc} A103FutSel
Seleciona a nota fiscal de compra com entrega futura para relacionar à nota de remessa.

@author  Felipe Raposo
@version P12
@since   11/06/2018
@return  Nenhum.
/*/
Function A103FutSel(aCompFutur, cFornec, cLoja, cProduto, oGetDb, aComFut)

Local aArea      := {}
Local aDocumento := {}
Local nX, nY
Local nPItemNF   := aScan(aHeader,{|x| AllTrim(x[2]) == "D1_ITEM"} )

Local cQuery     := ""
Local cTopAlias  := ""

Local cTMPAlias  := "COMFUT"
Local cTMPTabela := ""
Local cTMPIndice := ""
Local cTMPCampo  := ""
Local aTMPCampos := {}
Local aTMPHeader := {}
Local aTMPStruct := {}

Local aSize      := {}
Local aObjects   := {}
Local aInfo      := {}
Local aPosObj    := {}

Local oDlg, oPanel, oCombo
Local nOpcA      := 0
Local aTexto     := {"", ""}
Local cCombo     := ""
Local cComboFor  := ""
Local cForTer    := cFornec
Local cLojaTer   := cLoja
Local aOrdem     := {}
Local xPesq
Local lEntTerc   := SuperGetMV("MV_FORPCNF",.F.,.F.)
Local lFutTer    := (aComFut != Nil)
Local lRet 		 := .F. 

Default oGetDb  := Nil
Default aComFut := {}

If lDHQInDic
	aArea := GetArea()

	// Ajusta o tamanho da variavel de acordo com os itens da nota
	aSize(aCompFutur, Len(aCols))
	For nX := 1 To Len(aCompFutur)
		If aCompFutur[nX] == Nil
			aCompFutur[nX] := {" "," "," ",0," "," "," "}
		EndIf
	Next nX

	cQuery := "select DHQ.R_E_C_N_O_ DHQRecNo, SD1.R_E_C_N_O_ SD1RecNo " + CRLF
	cQuery += "from " + RetSQLName("DHQ") + " DHQ " + CRLF
	cQuery += "inner join " + RetSQLName("SD1") + " SD1 on SD1.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "and SD1.D1_FILIAL  = '" + xFilial("SD1") + "' " + CRLF
	cQuery += "and SD1.D1_DOC     = DHQ.DHQ_DOC " + CRLF
	cQuery += "and SD1.D1_SERIE   = DHQ.DHQ_SERIE " + CRLF
	cQuery += "and SD1.D1_FORNECE = DHQ.DHQ_FORNEC " + CRLF
	cQuery += "and SD1.D1_LOJA    = DHQ.DHQ_LOJA " + CRLF
	cQuery += "and SD1.D1_ITEM    = DHQ.DHQ_ITEM " + CRLF
	cQuery += "and SD1.D1_COD     = DHQ.DHQ_COD " + CRLF
	cQuery += "where DHQ.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "and DHQ.DHQ_FILIAL = '" + xFilial("DHQ") + "' " + CRLF
	cQuery += "and DHQ.DHQ_FORNEC = '" + cFornec + "' " + CRLF
	cQuery += "and DHQ.DHQ_LOJA   = '" + cLoja + "' " + CRLF
	cQuery += "and DHQ.DHQ_COD    = '" + cProduto + "' " + CRLF
	cQuery += IIF(cTipo == "C","and DHQ.DHQ_TIPO   IN('1','2') " + CRLF,"and DHQ.DHQ_TIPO   = '1' " + CRLF )
	cQuery += IIF(cTipo == "C","and DHQ.DHQ_STATUS IN('1','9') " + CRLF,"and DHQ.DHQ_STATUS = '1' " + CRLF )
	If !cTipo == "C"
		cQuery += "and DHQ.DHQ_QTORI  > DHQ.DHQ_QTREC " + CRLF  // 1-Aberto.
	EndIf
	cQuery += "and DHQ.DHQ_DESFAZ  = ' ' " + CRLF
	cQuery += "order by DHQ.DHQ_DTREC, DHQ.DHQ_DOC, DHQ.DHQ_SERIE, DHQ.DHQ_ITEM " + CRLF
	cQuery := ChangeQuery(cQuery)
	cTopAlias := MPSysOpenQuery(cQuery)

	Do While (cTopAlias)->(!eof())
		(cTopAlias)->(aAdd(aDocumento, {DHQRecNo, SD1RecNo}))
		(cTopAlias)->(dbSkip())
	EndDo
	(cTopAlias)->(dbCloseArea())

	//Se for nota de complemento verifica se o tipo eh diferente de complemento de preço
	If cTipo == "C"
		lRet := cTpCompl != "1"
	EndIf 

	// Exibe a tela para o usuário selecionar a nota de origem.
	If !lRet .And. !Empty(aDocumento) .Or. lEntTerc

		If lFutTer .And. Select(cTMPAlias) > 0
			FWCloseTemp(cTMPAlias, cTMPTabela)
		EndIf

		// Cria tabela de trabalho.
		aTMPCampos := {"DHQ->DHQ_DOC", "DHQ->DHQ_SERIE", "DHQ->DHQ_ITEM", "DHQ->DHQ_DTREC", "DHQ->DHQ_QTORI",;
		"DHQ->DHQ_QTREC", "SD1->D1_VUNIT", "SD1->D1_CF", "SD1->D1_ORIGEM", "SD1->D1_FCICOD"}
		For nX := 1 to len(aTMPCampos)
			SX3->(dbSetOrder(2))  // X3_CAMPO.
			If SX3->(dbSeek(SubStr(aTMPCampos[nX], 6), .F.))
				aAdd(aTMPStruct, {SX3->X3_CAMPO, SX3->X3_TIPO, SX3->X3_TAMANHO, SX3->X3_DECIMAL, StrZero(nX, 2)})
				aAdd(aTMPHeader, {AllTrim(X3Titulo()), SX3->X3_CAMPO, SX3->X3_PICTURE, SX3->X3_TAMANHO, SX3->X3_DECIMAL,;
				SX3->X3_VALID, SX3->X3_USADO, SX3->X3_TIPO, SX3->X3_ARQUIVO, SX3->X3_CONTEXT, StrZero(nX, 2)})
			Endif
		Next nX
		cTMPTabela := FWOpenTemp(cTMPAlias, aTMPStruct,, .T.)

		// Cria índice e configuração de pesquisa.
		aChave := {"DHQ_DOC+DHQ_SERIE+DHQ_ITEM", "DHQ_DTREC"}
		aPesq  := {{Space(Len(DHQ->DHQ_DOC + DHQ->DHQ_SERIE)), "@!"}, {ctod(""), ""}}
		For nX := 1 To Len(aChave)
			cTMPIndice := cTMPAlias + "_" + Str(nX, 1)
			(cTMPAlias)->(IndRegua(cTMPAlias, cTMPIndice, aChave[nX]))
			aChave[nX] := cTMPIndice
		Next nX
		(cTMPAlias)->(dbClearIndex())
		For nX := 1 To Len(aChave)
			(cTMPAlias)->(dbSetIndex(aChave[nX]))
		Next nX

		// Popula a tabela de trabalho.
		For nX := 1 to Len(aDocumento)
			DHQ->(dbGoTo(aDocumento[nX, 1]))
			SD1->(dbGoTo(aDocumento[nX, 2]))
			RecLock(cTMPAlias, .T.)
			For nY := 1 to len(aTMPCampos)
				cTMPCampo := SubStr(aTMPCampos[nY], 6)
				(cTMPAlias)->(&cTMPCampo) := &(aTMPCampos[nY])
			Next nY
			(cTMPAlias)->(msUnLock())
		Next nX

		If !lFutTer	// Chamada via funcao A103FutTer nao deve montar a Dialog novamente, somente atualizar o objeto oGetDb
			// Posiciona tabelas.
			(cTMPAlias)->(dbSetOrder(1))
			(cTMPAlias)->(dbGoTop())
			SA2->(dbSetOrder(1))  // A2_FILIAL, A2_COD, A2_LOJA.
			SA2->(dbSeek(xFilial() + cFornec + cLoja, .F.))
			SB1->(dbSetOrder(1))  // B1_FILIAL, B1_COD.
			SB1->(dbSeek(xFilial() + cProduto, .F.))
	
			// Calcula as coordenadas da tela.
			aSize := MsAdvSize(.F.)
			aSize[1] /= 1.5; aSize[2] /= 1.5; aSize[3] /= 1.5; aSize[4] /= 1.3
			aSize[5] /= 1.5; aSize[6] /= 1.3; aSize[7] /= 1.5
			aAdd(aObjects, {100, 020, .T., .F., .T.})
			aAdd(aObjects, {100, 060, .T., .T.})
			aAdd(aObjects, {100, 022, .T., .F.})
			aInfo   := {aSize[1], aSize[2], aSize[3], aSize[4], 3, 3}
			aPosObj := MsObjSize(aInfo, aObjects, .T.)
	
			// Monta a tela.
			DEFINE MSDIALOG oDlg TITLE STR0001 FROM aSize[7], 000 TO aSize[6], aSize[5] OF oMainWnd PIXEL  // "Notas fiscais de origem (compra com entrega futura)"
	
			@ aPosObj[1, 1], aPosObj[1, 2] MSPANEL oPanel PROMPT "" SIZE aPosObj[1, 3], aPosObj[1, 4]+IIf(lEntTerc,7,0) OF oDlg CENTERED LOWERED
	
			If !lEntTerc
				aTexto[1] := AllTrim(RetTitle("DHQ_FORNEC")) + "/" + AllTrim(RetTitle("DHQ_LOJA")) + ": " + SA2->A2_COD + "/" + SA2->A2_LOJA + " - " + RetTitle("A2_NOME") + ": " + ;
				If(lLGPD,RetTxtLGPD(SA2->A2_NOME,"A2_NOME"),SA2->A2_NOME)
				@ 002, 005 SAY aTexto[1] SIZE aPosObj[1, 3], 008 OF oPanel PIXEL
	
				aTexto[2] := AllTrim(RetTitle("DHQ_COD")) + ": " + SB1->B1_COD + " - " + rtrim(SB1->B1_DESC)
				@ 012, 005 SAY aTexto[2] SIZE aPosObj[1, 3], 008 OF oPanel PIXEL
			Else
				aTexto[1] := AllTrim(RetTitle("DHQ_FORNEC")) + "/" + AllTrim(RetTitle("DHQ_LOJA")) + ": "
				@ 005, 005 SAY aTexto[1] SIZE aPosObj[1, 3], 008 OF oPanel PIXEL
				@ 007, 055 MSCOMBOBOX oComboBox VAR cComboFor ITEMS MTGetForRl(cA100For,cLoja) SIZE 392,9 OF oDlg PIXEL ON CHANGE A103FutTer(aCompFutur, cProduto, cComboFor, @oGetDb, cTMPAlias, aPosObj, @aDocumento, @cForTer, @cLojaTer)
	
				aTexto[2] := AllTrim(RetTitle("DHQ_COD")) + ": " + SB1->B1_COD + " - " + rtrim(SB1->B1_DESC)
				@ 018, 005 SAY aTexto[2] SIZE aPosObj[1, 3], 008 OF oPanel PIXEL
			EndIf
	
			Private aHeader := aTMPHeader
			oGetDb := MsGetDB():New(aPosObj[2, 1]+IIf(lEntTerc,8,0), aPosObj[2, 2], aPosObj[2, 3], aPosObj[2, 4], 1, "AllwaysTrue", "AllwaysTrue", "", .F.,,, .F.,, cTMPAlias)
	
			aOrdem := {AllTrim(RetTitle("DHQ_DOC")) + "+" + AllTrim(RetTitle("DHQ_SERIE")), AllTrim(RetTitle("DHQ_DTREC"))}
			@ aPosObj[3, 1], aPosObj[3, 2] + 000 SAY STR0002 PIXEL  // "Pesquisar por"
			@ aPosObj[3, 1], aPosObj[3, 2] + 040 MSCOMBOBOX oCombo VAR cCombo ITEMS aOrdem SIZE 60, 12 OF oDlg PIXEL;
			VALID ((cTMPAlias)->(dbSetOrder(oCombo:nAt), xPesq := aPesq[oCombo:nAt, 1], .T.))
	
			xPesq := aPesq[1, 1]
			@ aPosObj[3, 1], aPosObj[3, 2] + 120 SAY STR0003 PIXEL  // "Localizar"
			@ aPosObj[3, 1], aPosObj[3, 2] + 150 MSGET xPesq PICTURE aPesq[oCombo:nAt, 2] Of oDlg PIXEL;
			VALID (cTMPAlias)->(MsSeek(If(ValType(xPesq) == "C", AllTrim(xPesq), xPesq), .T.), oGetDb:oBrowse:Refresh(), .T.)
	
			DEFINE SBUTTON FROM aPosObj[3, 1] + 00, aPosObj[3, 4] - 25 TYPE 1 ACTION (nOpcA := 1, oDlg:End()) ENABLE OF oDlg
			DEFINE SBUTTON FROM aPosObj[3, 1] + 12, aPosObj[3, 4] - 25 TYPE 2 ACTION (nOpcA := 0, oDlg:End()) ENABLE OF oDlg
	
			ACTIVATE MSDIALOG oDlg CENTERED
	
			// Verifica se o usuário confirmou a tela.
			If nOpcA = 1 .And. nBrLin > 0 .And. nBrLin < 5000 .And. nBrLin <= Len(aDocumento)	// A MSGetDB cria a variavel publica nBrLin que indica qual a linha posicionada do aCols.
				(cTMPAlias)->(aCompFutur[N] := {DHQ_DOC, DHQ_SERIE, DHQ_ITEM})
				aAdd(aCompFutur[N],aDocumento[nBrLin][2])	// Guarda o Recno da DHQ
				aAdd(aCompFutur[N],aCols[N][nPItemNF])		// Guarda o item do aCols
				aAdd(aCompFutur[N],cForTer)					// Guarda o fornecedor
				aAdd(aCompFutur[N],cLojaTer)				// Guarda a loja do fornecedor
			EndIf

			// Apaga a tabela de trabalho do banco de dados.
			FWCloseTemp(cTMPAlias, cTMPTabela)
		EndIf
	Else
		If cTipo == "C" .And. lRet 
			Help("  ", 1, "MATA103COM",, STR0022, 1, 0)
		Else
			Help("  ", 1, "MATA103COM",, STR0010, 1, 0)  // "Não há notas fiscais de entrega futura com saldo a receber."
		EndIf 
	EndIf
	If !lFutTer
		RestArea(aArea)
	EndIf
EndIf

If lFutTer
	aComFut := aClone(aDocumento)
EndIf

Return


/*/{Protheus.doc} A103FutVld
Verifica o recebimento da nota de compra com entrega futura.
Nessa função é verificado o saldo a receber e o valor unitário das notas.

@author  Felipe Raposo
@version P12
@since   12/06/2018
@return  lRet - indicando se pode continuar o processamento.
/*/
Function A103FutVld(lDelete, aCompFutur, nLinha, lTudoOk)

Local lRet       := .F.
Local aArea      := {}
Local cQuery     := ""
Local cTopAlias  := ""
Local nSaldo     := 0
Local nX         := 0
Local nLinVld    := 0

If !lDHQInDic
	lRet := .T.
Else
	aArea := GetArea()

	If !lDelete
		// Verifica se o usuario selecionou a nota de entrega futura
		If Len(aCompFutur) >= N .And. ValType(aCompFutur[N]) = "A" .And. Len(aCompFutur[N]) >= 3

			nLinVld := Iif(lTudoOk,nLinha,N)

			cQuery := "select DHQ.DHQ_QTORI - DHQ.DHQ_QTREC SALDO, DHQ.DHQ_VLUNIT VLUNIT " + CRLF
			cQuery += "from " + RetSQLName("DHQ") + " DHQ " + CRLF
			cQuery += "where DHQ.D_E_L_E_T_ = ' ' " + CRLF
			cQuery += "and DHQ.DHQ_FILIAL = '" + xFilial("DHQ") + "' " + CRLF
			cQuery += "and DHQ.DHQ_DOC    = '" + aCompFutur[nLinVld, 1] + "' " + CRLF
			cQuery += "and DHQ.DHQ_SERIE  = '" + aCompFutur[nLinVld, 2] + "' " + CRLF
			cQuery += "and DHQ.DHQ_FORNEC = '" + aCompFutur[nLinVld, 6] + "' " + CRLF
			cQuery += "and DHQ.DHQ_LOJA   = '" + aCompFutur[nLinVld, 7] + "' " + CRLF
			cQuery += "and DHQ.DHQ_ITEM   = '" + aCompFutur[nLinVld, 3] + "' " + CRLF
			cQuery += "and DHQ.DHQ_COD    = '" + GdFieldGet("D1_COD", nLinVld) + "' " + CRLF
			cQuery += IIF(cTipo == "C","and DHQ.DHQ_TIPO   IN('1','2') " + CRLF,"and DHQ.DHQ_TIPO   = '1' " + CRLF )
			If !cTipo == "C"
				cQuery += "and DHQ.DHQ_QTORI  > DHQ.DHQ_QTREC " + CRLF  // 1-Aberto
			EndIf 
			cQuery += "and DHQ.DHQ_DESFAZ  = ' ' " + CRLF
			cQuery := ChangeQuery(cQuery)
			cTopAlias := MPSysOpenQuery(cQuery)

			If (cTopAlias)->(Eof())
				Help("  ", 1, "MATA103COM",, STR0004, 1, 0)  // "Selecione uma NF de entrega futura com saldo (F7)."
			ElseIf (cTopAlias)->SALDO < GdFieldGet("D1_QUANT", nLinha) .And. !cTipo == 'C'
				Help("  ", 1, "MATA103COM",, STR0014, 1, 0)  // "A quantidade não pode ser superior ao saldo do item na nota de compra futura vinculada."
			ElseIf lTudoOk .And. !cTipo == 'C'  // Se for no TudoOk, valida se outras linhas não estão consumindo o mesmo item.
				nSaldo := (cTopAlias)->SALDO
				For nX := 1 To (nLinha - 1)
					If !Atail(aCols[nX]) .And. aCompFutur[nX] != Nil .And. Len(aCompFutur[nX]) >= 3 .And. aCompFutur[nX, 1] == aCompFutur[nLinha, 1] .And. aCompFutur[nX, 2] == aCompFutur[nLinha, 2] .And. aCompFutur[nX, 3] == aCompFutur[nLinha, 3]
						nSaldo -= GdFieldGet("D1_QUANT", nX)
					EndIf
				Next nX

				lRet := (Atail(aCols[nX])) .or. (nSaldo >= GdFieldGet("D1_QUANT", nLinha))
				If !lRet
					Help("  ", 1, "MATA103COM",, STR0014, 1, 0)  // "Selecione uma NF de entrega futura com saldo (F7)."
				EndIf
			Else
				lRet := .T.
			EndIf

			(cTopAlias)->(dbCloseArea())
		Else
			Help("  ", 1, "MATA103COM",, STR0004, 1, 0)  // "Selecione uma NF de entrega futura com saldo (F7)."
		EndIf
	Else
		// Verifica se a NF a ser excluída é de entrega futura, e possui saldo consumido.
		cQuery := "select CON.DHQ_IDENT IDENT " + CRLF
		cQuery += "from " + RetSQLName("DHQ") + " DHQ " + CRLF
		cQuery += "inner join " + RetSQLName("DHQ") + " CON on CON.D_E_L_E_T_ = ' ' " + CRLF
		cQuery += "and CON.DHQ_FILIAL = '" + xFilial("DHQ") + "' " + CRLF
		cQuery += "and CON.DHQ_IDENT  = DHQ.DHQ_IDENT " + CRLF
		cQuery += "and CON.DHQ_TIPO   = '2' " + CRLF  // 2-Entrega.
		cQuery += "where DHQ.D_E_L_E_T_ = ' ' " + CRLF
		cQuery += "and DHQ.DHQ_FILIAL = '" + xFilial("DHQ") + "' " + CRLF
		cQuery += "and DHQ.DHQ_DOC    = '" + SD1->D1_DOC + "' " + CRLF
		cQuery += "and DHQ.DHQ_SERIE  = '" + SD1->D1_SERIE + "' " + CRLF
		cQuery += "and DHQ.DHQ_FORNEC = '" + SD1->D1_FORNECE + "' " + CRLF
		cQuery += "and DHQ.DHQ_LOJA   = '" + SD1->D1_LOJA + "' " + CRLF
		cQuery += "and DHQ.DHQ_TIPO   = '1' " + CRLF  // 1-Compra futura.
		cQuery := ChangeQuery(cQuery)
		cTopAlias := MPSysOpenQuery(cQuery)
		lRet := (cTopAlias)->(eof())
		(cTopAlias)->(dbCloseArea())

		If !lRet
			Help("  ", 1, "MATA103COM",, STR0006, 1, 0)  // "Existe nota de remessa vinculada a essa nota de compra futura."
		EndIf
	EndIf

	RestArea(aArea)
EndIf

Return lRet


/*/{Protheus.doc} A103FutFat
Efetua a gravação do saldo de nota fiscal de compra com entrega futura (faturamento).

@author  Felipe Raposo
@version P12
@since   11/06/2018
@return  Nenhum.
/*/
Function A103FutFat(lDelete)

Local aArea      := {}
Local cQuery     := ""
Local cTopAlias  := ""
Local cIdent     := ""

If lDHQInDic
	aArea := GetArea()

	If !lDelete
		// Pega o número de identificação do saldo da entrega futura.
		// DHQ índice 2 -> DHQ_FILIAL, DHQ_IDENT, DHQ_TIPO, DHQ_DOC, DHQ_SERIE, DHQ_ITEM.
		cIdent := GetSXENum("DHQ", "DHQ_IDENT")
		Do While DHQ->(dbSetOrder(2), dbSeek(xFilial() + cIdent, .F.))
			ConfirmSX8()
			cIdent := GetSXENum("DHQ", "DHQ_IDENT")
		EndDo

		// Cria o saldo a receber.
		RecLock("DHQ", .T.)
		DHQ->DHQ_FILIAL := xFilial("DHQ")
		DHQ->DHQ_IDENT  := cIdent
		DHQ->DHQ_TIPO   := "1"  // 1-Compra futura.
		DHQ->DHQ_DOC    := SD1->D1_DOC
		DHQ->DHQ_SERIE  := SD1->D1_SERIE
		DHQ->DHQ_FORNEC := SD1->D1_FORNECE
		DHQ->DHQ_LOJA   := SD1->D1_LOJA
		DHQ->DHQ_ITEM   := SD1->D1_ITEM
		DHQ->DHQ_DTREC  := SD1->D1_DTDIGIT
		DHQ->DHQ_STATUS := "1"  // 1-Aberto.
		DHQ->DHQ_COD    := SD1->D1_COD
		DHQ->DHQ_QTORI  := SD1->D1_QUANT
		DHQ->DHQ_VLUNIT := SD1->D1_VUNIT
		DHQ->DHQ_ESTOQ  := SF4->F4_ESTOQUE
		DHQ->(msUnLock())
		ConfirmSX8()

		// Atualiza o saldo a receber no SB2.
		MaAvalCF(1, SD1->D1_COD, SD1->D1_LOCAL, SD1->D1_QUANT)
	Else
		// Exclui registro de eliminação de resíduo, se houver.
		If !cTipo == "C"
			cQuery := "select CON.R_E_C_N_O_ DHQRecNo " + CRLF
			cQuery += "from " + RetSQLName("DHQ") + " DHQ " + CRLF
			cQuery += "inner join " + RetSQLName("DHQ") + " CON on CON.D_E_L_E_T_ = ' ' " + CRLF
			cQuery += "and CON.DHQ_FILIAL = '" + xFilial("DHQ") + "' " + CRLF
			cQuery += "and CON.DHQ_IDENT  = DHQ.DHQ_IDENT " + CRLF
			cQuery += "and CON.DHQ_TIPO   = '9' " + CRLF  // 9-Elim. resíduo.
			cQuery += "where DHQ.D_E_L_E_T_ = ' ' " + CRLF
			cQuery += "and DHQ.DHQ_FILIAL = '" + xFilial("DHQ") + "' " + CRLF
			cQuery += "and DHQ.DHQ_DOC    = '" + SD1->D1_DOC + "' " + CRLF
			cQuery += "and DHQ.DHQ_SERIE  = '" + SD1->D1_SERIE + "' " + CRLF
			cQuery += "and DHQ.DHQ_FORNEC = '" + SD1->D1_FORNECE + "' " + CRLF
			cQuery += "and DHQ.DHQ_LOJA   = '" + SD1->D1_LOJA + "' " + CRLF
			cQuery += "and DHQ.DHQ_ITEM   = '" + SD1->D1_ITEM + "' " + CRLF
			cQuery += "and DHQ.DHQ_COD    = '" + SD1->D1_COD + "' " + CRLF
			cQuery += "and DHQ.DHQ_TIPO   = '1' " + CRLF  // 1-Compra futura.
			cQuery := ChangeQuery(cQuery)
			cTopAlias := MPSysOpenQuery(cQuery)

			If (cTopAlias)->(!eof())
				DHQ->(dbGoTo((cTopAlias)->DHQRecNo))

				// Exclui o saldo a receber.
				RecLock("DHQ", .F.)
				DHQ->(dbDelete())
				DHQ->(msUnLock())
			Endif
			(cTopAlias)->(dbCloseArea())

			// Exclui o saldo a receber.
			cQuery := "select DHQ.R_E_C_N_O_ DHQRecNo " + CRLF
			cQuery += "from " + RetSQLName("DHQ") + " DHQ " + CRLF
			cQuery += "where DHQ.D_E_L_E_T_ = ' ' " + CRLF
			cQuery += "and DHQ.DHQ_FILIAL = '" + xFilial("DHQ") + "' " + CRLF
			cQuery += "and DHQ.DHQ_DOC    = '" + SD1->D1_DOC + "' " + CRLF
			cQuery += "and DHQ.DHQ_SERIE  = '" + SD1->D1_SERIE + "' " + CRLF
			cQuery += "and DHQ.DHQ_FORNEC = '" + SD1->D1_FORNECE + "' " + CRLF
			cQuery += "and DHQ.DHQ_LOJA   = '" + SD1->D1_LOJA + "' " + CRLF
			cQuery += "and DHQ.DHQ_ITEM   = '" + SD1->D1_ITEM + "' " + CRLF
			cQuery += "and DHQ.DHQ_COD    = '" + SD1->D1_COD + "' " + CRLF
			cQuery += "and DHQ.DHQ_TIPO   = '1' " + CRLF  // 1-Compra futura.
			cQuery := ChangeQuery(cQuery)
			cTopAlias := MPSysOpenQuery(cQuery)

			If (cTopAlias)->(!eof())
				DHQ->(dbGoTo((cTopAlias)->DHQRecNo))

				// Exclui o saldo a receber.
				RecLock("DHQ", .F.)
				DHQ->(dbDelete())
				DHQ->(msUnLock())

				// Atualiza o saldo a receber no SB2.
				MaAvalCF(2, SD1->D1_COD, SD1->D1_LOCAL, SD1->D1_QUANT)
			Endif
			(cTopAlias)->(dbCloseArea())
		EndIf 
	Endif
	RestArea(aArea)
Endif

Return


/*/{Protheus.doc} A103FutRem
Efetua a gravação do consumo de saldo da nota fiscal de compra com entrega futura (remessa).

@author  Felipe Raposo
@version P12
@since   12/06/2018
@return  Nenhum.
/*/
Function A103FutRem(lDelete, aCompFutur)

Local aArea      := {}
Local cQuery     := ""
Local cTopAlias  := ""
Local aIdent     := {}

If lDHQInDic
	aArea := GetArea()

	If !lDelete
		cQuery := "select DHQ.R_E_C_N_O_ DHQRecNo " + CRLF
		cQuery += "from " + RetSQLName("DHQ") + " DHQ " + CRLF
		cQuery += "where DHQ.D_E_L_E_T_ = ' ' " + CRLF
		cQuery += "and DHQ.DHQ_FILIAL = '" + xFilial("DHQ") + "' " + CRLF
		cQuery += "and DHQ.DHQ_DOC    = '" + aCompFutur[1] + "' " + CRLF
		cQuery += "and DHQ.DHQ_SERIE  = '" + aCompFutur[2] + "' " + CRLF
		cQuery += "and DHQ.DHQ_FORNEC = '" + aCompFutur[6] + "' " + CRLF
		cQuery += "and DHQ.DHQ_LOJA   = '" + aCompFutur[7] + "' " + CRLF
		cQuery += "and DHQ.DHQ_ITEM   = '" + aCompFutur[3] + "' " + CRLF
		cQuery += "and DHQ.DHQ_COD    = '" + SD1->D1_COD + "' " + CRLF
		cQuery += IIF(cTipo == "C","and DHQ.DHQ_TIPO   IN('1','2') " + CRLF,"and DHQ.DHQ_TIPO   = '1' " + CRLF )
		cQuery := ChangeQuery(cQuery)
		cTopAlias := MPSysOpenQuery(cQuery)

		If (cTopAlias)->(!eof())

			DHQ->(dbGoTo((cTopAlias)->DHQRecNo))
			aIdent := {DHQ->DHQ_IDENT}

			// Consome o saldo a receber da nota de compras.
			RecLock("DHQ", .F.)
			DHQ->DHQ_QTREC += SD1->D1_QUANT
			If DHQ->DHQ_QTREC < DHQ->DHQ_QTORI
				DHQ->DHQ_STATUS := "1"  // 1-Aberto.
			Else
				DHQ->DHQ_STATUS := "9"  // 9-Encerrado.
			Endif
			DHQ->(msUnLock())

			// Grava o registro do consumo.
			RecLock("DHQ", .T.)
			DHQ->DHQ_FILIAL := xFilial("DHQ")
			DHQ->DHQ_IDENT  := aIdent[1]
			IIF(cTipo == "C",DHQ->DHQ_TIPO := "3",DHQ->DHQ_TIPO := "2" )//DHQ_TIPO = 3 (Compl. de preço) | DHQ_TIPO = 2 (Entrega)
			DHQ->DHQ_DOC    := SD1->D1_DOC
			DHQ->DHQ_SERIE  := SD1->D1_SERIE
			DHQ->DHQ_FORNEC := SD1->D1_FORNECE
			DHQ->DHQ_LOJA   := SD1->D1_LOJA
			DHQ->DHQ_ITEM   := SD1->D1_ITEM
			DHQ->DHQ_DTREC  := SD1->D1_DTDIGIT
			DHQ->DHQ_STATUS := "9"  // 9-Encerrado.
			DHQ->DHQ_COD    := SD1->D1_COD
			DHQ->DHQ_QTREC  := SD1->D1_QUANT
			DHQ->DHQ_VLUNIT := SD1->D1_VUNIT
			DHQ->DHQ_ESTOQ  := SF4->F4_ESTOQUE
			DHQ->(msUnLock())

			// Atualiza o saldo a receber no SB2.
			If !cTipo == "C" //Nota tipo complemento de preço não possui quantidade
				MaAvalCF(3, SD1->D1_COD, SD1->D1_LOCAL, SD1->D1_QUANT)
			EndIf
		Endif
		(cTopAlias)->(dbCloseArea())
	Else
		cQuery := "select DHQ.R_E_C_N_O_ DHQRecNo " + CRLF
		cQuery += "from " + RetSQLName("DHQ") + " DHQ " + CRLF
		cQuery += "where DHQ.D_E_L_E_T_ = ' ' " + CRLF
		cQuery += "and DHQ.DHQ_FILIAL = '" + xFilial("DHQ") + "' " + CRLF
		cQuery += "and DHQ.DHQ_DOC    = '" + SD1->D1_DOC + "' " + CRLF
		cQuery += "and DHQ.DHQ_SERIE  = '" + SD1->D1_SERIE + "' " + CRLF
		cQuery += "and DHQ.DHQ_FORNEC = '" + SD1->D1_FORNECE + "' " + CRLF
		cQuery += "and DHQ.DHQ_LOJA   = '" + SD1->D1_LOJA + "' " + CRLF
		cQuery += "and DHQ.DHQ_ITEM   = '" + SD1->D1_ITEM + "' " + CRLF
		cQuery += "and DHQ.DHQ_COD    = '" + SD1->D1_COD + "' " + CRLF
		cQuery += IIF(cTipo == "C","and DHQ.DHQ_TIPO = '3' " + CRLF,"and DHQ.DHQ_TIPO = '2' " + CRLF )
		cQuery := ChangeQuery(cQuery)
		cTopAlias := MPSysOpenQuery(cQuery)

		If (cTopAlias)->(!eof())
			DHQ->(dbGoTo((cTopAlias)->DHQRecNo))
			aIdent := {DHQ->DHQ_IDENT, DHQ->DHQ_QTREC}

			// Exclui o consumo do saldo a receber da nota de compras.
			RecLock("DHQ", .F.)
			DHQ->(dbDelete())
			DHQ->(msUnLock())
		Endif
		(cTopAlias)->(dbCloseArea())

		// Ajusta o saldo do nota de entrega futura.
		If !empty(aIdent) .And. !cTipo == "C"
			cQuery := "select DHQ.R_E_C_N_O_ DHQRecNo " + CRLF
			cQuery += "from " + RetSQLName("DHQ") + " DHQ " + CRLF
			cQuery += "where DHQ.D_E_L_E_T_ = ' ' " + CRLF
			cQuery += "and DHQ.DHQ_FILIAL = '" + xFilial("DHQ") + "' " + CRLF
			cQuery += "and DHQ.DHQ_IDENT  = '" + aIdent[1] + "' " + CRLF
			cQuery += "and DHQ.DHQ_TIPO   = '1' " + CRLF  // 1-Compra futura.
			cQuery += "and DHQ.DHQ_DESFAZ  = ' ' " + CRLF
			cQuery := ChangeQuery(cQuery)
			cTopAlias := MPSysOpenQuery(cQuery)

			If (cTopAlias)->(!eof())
				DHQ->(dbGoTo((cTopAlias)->DHQRecNo))

				// Ajusta o saldo a receber da nota de compras.
				RecLock("DHQ", .F.)
				DHQ->DHQ_QTREC -= aIdent[2]
				If DHQ->DHQ_QTREC < DHQ->DHQ_QTORI
					DHQ->DHQ_STATUS := "1"  // 1-Aberto.
				Else
					DHQ->DHQ_STATUS := "9"  // 9-Encerrado.
				Endif
				DHQ->(msUnLock())

				// Atualiza o saldo a receber no SB2.
				MaAvalCF(4, SD1->D1_COD, SD1->D1_LOCAL, aIdent[2])
			Endif
			(cTopAlias)->(dbCloseArea())
		Endif
	Endif

	RestArea(aArea)
Endif

Return


/*/{Protheus.doc} A103CFRes
Elimina resíduo de saldo a receber de compra futura (Desfazimento).

@author  Felipe Raposo
@version P12
@since   12/06/2018
@return  Nenhum.
/*/
Function A103Desfaz()

Local lDHQInDic  := AliasInDic("DHQ") .And. SF4->(ColumnPos("F4_EFUTUR") > 0)
Local lRet       := .F.
Local aArea      := {}
Local cQuery     := ""
Local cTopAlias  := ""
Local aIdent     := {}
Local nOpcDesfaz := 0

If !lDHQInDic
	Help(Nil, 1, "A103CFDESF", Nil, STR0012, 1, 0, Nil, Nil, Nil, Nil, Nil, {STR0013})	// "Tabela DHQ ou campo F4_EFUTUR não encontrados no dicionário de dados." / "Para executar a rotina de Desfazimento atualize seu dicionário de acordo com a funcionalidade de Compra com Entrega Futura."
	lRet := .F.
Else
	aArea := GetArea()
	
	cQuery := "select DHQ.R_E_C_N_O_ DHQRecNo, SD1.R_E_C_N_O_ SD1RecNo " + CRLF
	cQuery += "from " + RetSQLName("DHQ") + " DHQ " + CRLF
	cQuery += "inner join " + RetSQLName("SD1") + " SD1 on SD1.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "and SD1.D1_FILIAL  = '" + xFilial("SD1") + "' " + CRLF
	cQuery += "and SD1.D1_DOC     = DHQ.DHQ_DOC " + CRLF
	cQuery += "and SD1.D1_SERIE   = DHQ.DHQ_SERIE " + CRLF
	cQuery += "and SD1.D1_FORNECE = DHQ.DHQ_FORNEC " + CRLF
	cQuery += "and SD1.D1_LOJA    = DHQ.DHQ_LOJA " + CRLF
	cQuery += "and SD1.D1_ITEM    = DHQ.DHQ_ITEM " + CRLF
	cQuery += "and SD1.D1_COD     = DHQ.DHQ_COD " + CRLF
	cQuery += "where DHQ.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "and DHQ.DHQ_FILIAL = '" + xFilial("DHQ") + "' " + CRLF
	cQuery += "and DHQ.DHQ_DOC    = '" + SF1->F1_DOC + "' " + CRLF
	cQuery += "and DHQ.DHQ_SERIE  = '" + SF1->F1_SERIE + "' " + CRLF
	cQuery += "and DHQ.DHQ_FORNEC = '" + SF1->F1_FORNECE + "' " + CRLF
	cQuery += "and DHQ.DHQ_LOJA   = '" + SF1->F1_LOJA + "' " + CRLF
	cQuery += "and DHQ.DHQ_TIPO   = '1' " + CRLF  // 1-Compra futura.
	cQuery += "and DHQ.DHQ_STATUS = '1' " + CRLF  // 1-Aberto.
	cQuery += "and DHQ.DHQ_QTORI  > DHQ.DHQ_QTREC " + CRLF  // 1-Aberto.
	cQuery += "order by DHQ.DHQ_DTREC, DHQ.DHQ_DOC, DHQ.DHQ_SERIE, DHQ.DHQ_ITEM " + CRLF
	cQuery := ChangeQuery(cQuery)
	cTopAlias := MPSysOpenQuery(cQuery)

	If (cTopAlias)->(!Eof())
		nOpcDesfaz := Aviso(STR0011,STR0007,{STR0015,STR0016},2)	// "Desfazimento" , "Essa rotina irá eliminar o saldo a receber (desfazimento) do processo abaixo. Deseja continuar?" , "Sim" , "Não"
		If nOpcDesfaz == 1	// Sim
			Begin Transaction
				Do While (cTopAlias)->(!eof())
					DHQ->(dbGoTo((cTopAlias)->DHQRecNo))
					SD1->(dbGoTo((cTopAlias)->SD1RecNo))
					aIdent := {DHQ->DHQ_IDENT, DHQ->DHQ_QTORI - DHQ->DHQ_QTREC}
	
					// Consome o saldo a receber da nota de compras.
					RecLock("DHQ", .F.)
					DHQ->DHQ_QTREC += aIdent[2]
					DHQ->DHQ_STATUS := "9"  // 9-Encerrado.
					DHQ->DHQ_DESFAZ  := "S"
					DHQ->(msUnLock())
	
					// Grava o registro do consumo.
					RecLock("DHQ", .T.)
					DHQ->DHQ_FILIAL := xFilial("DHQ")
					DHQ->DHQ_IDENT  := aIdent[1]
					DHQ->DHQ_TIPO   := "9"  // 9-Elim. resíduo.
					DHQ->DHQ_DTREC  := dDataBase
					DHQ->DHQ_STATUS := "9"  // 9-Encerrado.
					DHQ->DHQ_COD    := SD1->D1_COD
					DHQ->DHQ_QTREC  := aIdent[2]
					DHQ->(msUnLock())
	
					// Atualiza o saldo a receber no SB2.
					MaAvalCF(9, SD1->D1_COD, SD1->D1_LOCAL, aIdent[2])
	
					(cTopAlias)->(dbSkip())
				EndDo
			End Transaction

			MsgInfo(STR0008, STR0001)   // "Desfazimento realizado com sucesso." / "Notas fiscais de origem (compra com entrega futura)"
		EndIf
	Else
		Help(" ", 1, "A103CFSLD", , STR0009, 1, 0)	// "Esta nota fiscal não possui saldo de compra com entrega futura a receber."
		lRet := .F.
	EndIf
	(cTopAlias)->(dbCloseArea())

	RestArea(aArea)
EndIf

Return lRet


/*/{Protheus.doc} MaAvalCF
Efetua o ajuste do saldo a receber do produto ao ajustar tabela de compra com entrega futura.

nEvento - código do evento.
	[1] - Inclusão de compra com entrega futura (simples faturamento).
	[2] - Exclusão de compra com entrega futura (simples faturamento).
	[3] - Consumo de compra com entrega futura (remessa).
	[4] - Estorno no consumo de compra com entrega futura (remessa).
	[9] - Elimina resíduo do saldo a receber de compra com entrega futura.

@author  Felipe Raposo
@version P12
@since   25/07/2018
@return  Nenhum.
/*/
Function MaAvalCF(nEvento, cProduto, cLocal, nQtdeUM1)

Local nQtdeUM2 := ConvUm(cProduto, nQtdeUM1, 0, 2)

// [1] - Inclusão de compra com entrega futura (simples faturamento).
// [4] - Estorno no consumo de compra com entrega futura (remessa).
If nEvento = 1 .or. nEvento = 4

	// Atualiza o saldo a receber no SB2.
	SB2->(dbSetOrder(1))  // B2_FILIAL, B2_COD, B2_LOCAL.
	If SB2->(!MsSeek(xFilial() + cProduto + cLocal, .F.))
		CriaSB2(cProduto, cLocal)
	Endif
	RecLock("SB2", .F.)
	SB2->B2_SALPEDI += nQtdeUM1
	SB2->B2_SALPED2 += nQtdeUM2
	SB2->(msUnLock())

	// [2] - Exclusão de compra com entrega futura (simples faturamento).
	// [3] - Consumo de compra com entrega futura (remessa).
	// [9] - Elimina resíduo do saldo a receber de compra com entrega futura.
ElseIf nEvento = 2 .or. nEvento = 3 .or. nEvento = 9

	// Atualiza o saldo a receber no SB2.
	SB2->(dbSetOrder(1))  // B2_FILIAL, B2_COD, B2_LOCAL.
	If SB2->(MsSeek(xFilial() + cProduto + cLocal, .F.))
		RecLock("SB2", .F.)
		SB2->B2_SALPEDI := max(0, SB2->B2_SALPEDI - nQtdeUM1)
		SB2->B2_SALPED2 := max(0, SB2->B2_SALPED2 - nQtdeUM2)
		SB2->(msUnLock())
	Endif
Endif

Return

/*/{Protheus.doc} A103Refaz
Funcao destinada a reprocessar os saldos acumulados de compra com entrega futura (chamada via rotina MATA215)

cFilAnt - código da filial
cFirst  - código da primeira filial
lBat    - indica se o processamento e via batch
oObj    - objeto para exibir as mensagens informativas do processamento

@author  Felipe Raposo
@version P12
@since   25/07/2018
@return  Nenhum.
/*/
Function A103Refaz(cFilAnt, cFirst, lBat, oObj, l215Regua, cFilProc)

Local cMensagem := STR0017
Local cAliasDHQ := "DHQMA215PROC"
Local cQuery    := ""
Local aStru     := TamSX3("DHQ_QTORI")

Default l215Regua  := .F.
Default cFilProc   := ""
// Atualiza os dados acumulados do compras com entrega futura.
If (!Empty(xFilial("DHQ")) .Or. cFilAnt == cFirst )

	dbSelectArea("DHQ")
	dbSetOrder(1)

	cQuery := "select DHQ.DHQ_FILIAL FILIAL, DHQ.DHQ_COD PRODUTO, SD1.D1_LOCAL ALMOX, DHQ.DHQ_QTORI - DHQ.DHQ_QTREC QUANT_UM1 " + CRLF
	cQuery += "from " + RetSQLName("DHQ") + " DHQ " + CRLF
	cQuery += "inner join " + RetSQLName("SD1") + " SD1 on SD1.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "and SD1.D1_FILIAL  = '" + xFilial("SD1") + "' " + CRLF
	cQuery += "and SD1.D1_DOC     = DHQ.DHQ_DOC " + CRLF
	cQuery += "and SD1.D1_SERIE   = DHQ.DHQ_SERIE " + CRLF
	cQuery += "and SD1.D1_FORNECE = DHQ.DHQ_FORNEC " + CRLF
	cQuery += "and SD1.D1_LOJA    = DHQ.DHQ_LOJA " + CRLF
	cQuery += "and SD1.D1_ITEM    = DHQ.DHQ_ITEM " + CRLF
	cQuery += "and SD1.D1_COD     = DHQ.DHQ_COD " + CRLF
	cQuery += "where DHQ.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "and DHQ.DHQ_FILIAL = '" + xFilial("DHQ") + "' " + CRLF
	cQuery += "and DHQ.DHQ_TIPO   = '1' " + CRLF  // 1-Compra futura.
	cQuery += "and DHQ.DHQ_STATUS = '1' " + CRLF  // 1-Aberto.
	cQuery += "and DHQ.DHQ_QTORI  <> DHQ.DHQ_QTREC " + CRLF
	cQuery += "and DHQ.DHQ_DESFAZ  = ' ' " + CRLF
	cQuery += "order by 1, 2, 3 "
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasDHQ,.T.,.T.)

	TcSetField(cAliasDHQ, "QUANT_UM1", "N", aStru[1], aStru[2])

	If !lBat
		If l215Regua
			oObj:SetRegua1(DHQ->(LastRec()))
			oObj:IncRegua1(cMensagem)
		Else
			oObj:cCaption := cFilProc + cMensagem;ProcessMessages()
		EndIf
	EndIf

	Do While (cAliasDHQ)->(!eof())
		MaAvalCF(1, (cAliasDHQ)->PRODUTO, (cAliasDHQ)->ALMOX, (cAliasDHQ)->QUANT_UM1)
		If l215Regua
			oObj:IncRegua1(cMensagem)
		EndIf
		(cAliasDHQ)->(dbSkip())
	EndDo
	(cAliasDHQ)->(dbCloseArea())
	dbSelectArea("DHQ")
EndIf

Return

/*/{Protheus.doc} A103VldTES
Funcao destinada a validar a configuracao da TES quando utilizada para compra com entrega futura (chamada via rotina MATA080)

@author  Felipe Raposo
@version P12
@since   25/07/2018
@return  lRet
/*/
Function A103VldTES()

Local lRet := .T.

If M->F4_EFUTUR == "1" .And. M->F4_ESTOQUE == "S"
	Help(Nil, 1, "F4_EFUTUR", Nil, STR0018, 1, 0, Nil, Nil, Nil, Nil, Nil, {STR0019})
	lRet := .F.
EndIf

Return lRet

/*/{Protheus.doc} A103FutTer
Funcionalidade para utilizar o recurso de Entrega por Terceiros na compra com entrega futura

@author  Carlos Capeli
@version P12
@since   12/07/2019
@return  Nenhum.
/*/
Function A103FutTer(aCompFutur, cProduto, cComboFor, oGetDb, cTMPAlias, aPosObj, aDocumento, cForTer, cLojaTer)

Local aComFut     := {}
Local cForLojTer  := ""
Local cFornTer    := ""
Local cLojTer    := ""

Default oGetDb     := Nil
Default aCompFutur := {}
Default aDocumento := {}
Default cProduto   := ""
Default cComboFor  := ""
Default cTMPAlias  := ""
Default cForTer    := ""
Default cLojaTer   := ""

cForLojTer := SubStr(cComboFor, At(' | ',cComboFor)+3, Len(cComboFor))
cForLojTer := SubStr(cForLojTer,1, At(' - ',cForLojTer)-1)

cFornTer := SubStr(cForLojTer, 1, At('/',cForLojTer)-1)
cLojTer  := SubStr(cForLojTer, At('/',cForLojTer)+1, Len(cForLojTer))
cForTer  := cFornTer
cLojaTer := cLojTer

A103FutSel(aCompFutur, cFornTer, cLojTer, cProduto, oGetDb, @aComFut)

aDocumento := aClone(aComFut)

oGetDb := MsGetDB():New(aPosObj[2, 1]+8, aPosObj[2, 2], aPosObj[2, 3], aPosObj[2, 4], 1, "AllwaysTrue", "AllwaysTrue", "", .F.,,, .F.,, cTMPAlias)

oGetDb:ForceRefresh()

Return

/*/{Protheus.doc} A103DKDDIC
Avaliar dicionario DKD

@author  rodrigo.mpontes
@version P12
@since   11/06/2022
/*/
Function A103DKD(lClas103,lVis103,lAlt140,lVis140)

Local aDKDStruct	:= {}
Local nI			:= 0
Local nZ			:= 0
Local nPos			:= 0
Local aChvDKD		:= {"DKD_FILIAL","DKD_DOC","DKD_SERIE","DKD_FORNEC","DKD_LOJA","DKD_TIPO","DKD_ESPECI","DKD_EMISSA"}
Local lRet			:= .F.
Local nTamDKDIt		:= TamSX3("DKD_ITEM")[1]
Local nPosD1It		:= GdFieldPos("D1_ITEM",aHeader)

Default lClas103 	:= .F.
Default lVis103		:= .F.
Default lAlt140		:= .F.
Default lVis140		:= .F.

aDKDStruct := FWSX3Util():GetListFieldsStruct("DKD",.T.)  

For nI := 1 To Len(aDKDStruct)
	nPos := aScan(aChvDKD,{|x| Alltrim(x) == AllTrim(aDKDStruct[nI,1])})
	If nPos == 0 .And. AllTrim(aDKDStruct[nI,1]) <> "DKD_ITEM" //Possui campo customizado
		aAdd(aAltDKD,AllTrim(aDKDStruct[nI,1]))
	Endif
Next nI

lRet := Len(aAltDKD) > 0 //Possui campo customizado

If lRet 
	aColsDKD := {}
	aHeadDKD := COMXHDCO("DKD",,aChvDKD) //Header

	//Execauto ou Classificação ou Visualização 103 ou Alteração ou Visualização 140
	If (Type("aAutoDKD") == "A" .And. Len(aAutoDKD) > 0) .Or. lClas103 .Or. lVis103 .Or. lAlt140 .Or. lVis140
		For nI := 1 To Len(aCols)
			aadd(aColsDKD,Array(Len(aHeadDKD)+1)) //aCols
			For nZ := 1 to Len(aHeadDKD)
				If AllTrim(aHeadDKD[nZ,2]) == "DKD_ITEM"
					aColsDKD[Len(aColsDKD)][nZ] := aCols[nI,nPosD1It]
				Else
					aColsDKD[Len(aColsDKD)][nZ] := A103DKDDADOS(aCols[nI,nPosD1It],lClas103,aHeadDKD[nZ,2],lVis103,lAlt140,lVis140)
				Endif
			Next nZ
			aColsDKD[Len(aColsDKD)][Len(aHeadDKD)+1] := .F. 	
		Next nI
	Else
		aadd(aColsDKD,Array(Len(aHeadDKD)+1)) //aCols
		For nI := 1 to Len(aHeadDKD)
			If AllTrim(aHeadDKD[nI,2]) == "DKD_ITEM"
				aColsDKD[1,nI] 	:= StrZero(1,nTamDKDIt)
			Else
				aColsDKD[1,nI] := CriaVar(aHeadDKD[nI,2])
			EndIf
			aColsDKD[1][Len(aHeadDKD)+1] := .F.
		Next nI
	Endif
Endif
Return lRet

/*/{Protheus.doc} A103DKDDADOS
Atualiza aColsDKD

@author  rodrigo.mpontes
@version P12
@since   11/06/2022
/*/
Function A103DKDDADOS(cItem,lClas103,cCampo,lVis103,lAlt140,lVis140)

Local nPos1	:= 0
Local nPos2	:= 0
Local nI	:= 0
Local xRet	:= Nil

If (Type("aAutoDKD") == "A" .And. Len(aAutoDKD) > 0)
	For nI := 1 To Len(aAutoDKD)
		nPos1 := aScan(aAutoDKD[nI],{|x| AllTrim(x[1]) == "DKD_ITEM"})
		If nPos1 > 0
			If aAutoDKD[nI,nPos1,2] == cItem
				nPos2  := aScan(aAutoDKD[nI],{|x| AllTrim(x[1]) == AllTrim(cCampo)})
				If nPos2 > 0
					xRet := aAutoDKD[nI,nPos2,2]
					Exit
				Endif
			Endif
		Endif
	Next nI
Elseif lClas103 .Or. lVis103 .Or. lAlt140 .Or. lVis140
	xRet := GetAdvFVal("DKD",cCampo,xFilial("DKD") + cNFiscal + cSerie + cA100For + cLoja + cItem + DtoS(dDEmissao) + cEspecie,1)
Endif

If ValType(xRet) == "U"
	xRet := CriaVar(cCampo)
Endif

Return xRet

/*/{Protheus.doc} A103DKDATU
Atualiza aColsDKD e visualização em tela

@author  rodrigo.mpontes
@version P12
@since   11/06/2022
/*/
Function A103DKDATU(nOpc,lVincPc)

Local nItDKD	:= GdFieldPos("DKD_ITEM",aHeadDKD)
Local nItSD1	:= GdFieldPos("D1_ITEM",aHeader)
Local nI		:= 0
Local nZ		:= 0

Default nOpc    := 0
Default lVincPc := .F.

If Len(aColsDKD) <> Len(aCols)  //Cria nova posição aColsDKD
	For nI := 1 To Len(aCols)
		If nI > Len(aColsDKD)
			aadd(aColsDKD,Array(Len(aHeadDKD)+1)) //aCols
			For nZ := 1 to Len(aHeadDKD)
				If AllTrim(aHeadDKD[nZ,2]) == "DKD_ITEM"
					aColsDKD[Len(aColsDKD),nZ] 	:= aCols[nI,nItSD1]
				Else
					aColsDKD[Len(aColsDKD),nZ] := CriaVar(aHeadDKD[nZ,2]) 
				EndIf
				aColsDKD[Len(aColsDKD)][Len(aHeadDKD)+1] := .F.
			Next nZ			
		Endif
	Next nI
Endif

//Atualizar dados do oGetDKD:aCols (visualiza) para aColsDKD (todos os itens)
For nI := 1 To Len(aColsDKD)
	If aColsDKD[nI,nItDKD] == oGetDKD:aCols[oGetDKD:nAt,nItDKD]  .and. !lVincPc
		For nZ := 1 to Len(aHeadDKD)
			aColsDKD[nI,nZ] := oGetDKD:aCols[oGetDKD:nAt,nZ]
		Next nZ
	Endif
Next nI

//Atualiza informaçao a ser apresentada - Posicionado na SD1
For nI := 1 To Len(aColsDKD)
	If aColsDKD[nI,nItDKD] == aCols[Iif(nOpc==1,1,n),nItSD1]
		For nZ := 1 to Len(aHeadDKD)
			oGetDKD:aCols[oGetDKD:nAt,nZ] := aColsDKD[nI,nZ]
		Next nZ
	Endif
Next nI

If nOpc == 1 //Ajuste oGetDKD:aCols (l103Class ou Execauto)
	If Len(oGetDKD:aCols) > 1
		For nI := 2 To Len(oGetDKD:aCols)
			If nI <= Len(oGetDKD:aCols) 
				aDel( oGetDKD:aCols, nI )
				aSize( oGetDKD:aCols, Len(oGetDKD:aCols)-1)
				nI := 1
			Endif
		Next nI
	Endif
Endif

oGetDKD:Refresh()
oGetDKD:oBrowse:Refresh()

Return

/*/{Protheus.doc} A103DKDGRV
Gravação do complemento de itens da NF

@author  rodrigo.mpontes
@version P12
@since   11/06/2022
/*/
Function A103DKDGRV(aHeadDKD,aColsDKD,nPosIt,cDel)

Local nI 		:= 1
Local lGrv		:= .F.
Local nItDKD	:= GdFieldPos("DKD_ITEM",aHeadDKD)
Local lSeekDkd  := .F.

Default cDel	:= ""

DbSelectArea("DKD")
DKD->(DbSetOrder(1)) //DKD_FILIAL, DKD_DOC, DKD_SERIE, DKD_FORNEC, DKD_LOJA, DKD_ITEM, DKD_EMISSA, DKD_ESPECI
lSeekDkd := DKD->(MsSeek(xFilial("DKD") + cNFiscal + cSerie + cA100For + cLoja + aColsDKD[nPosIt][nItDKD] + DtoS(dDEmissao) + cEspecie))
If !lSeekDkd
	lGrv := .T. 
Endif

lGrv := Iif(Empty(cDel),lGrv,.F.)

If Empty(cDel) .and. RecLock("DKD",lGrv)
	DKD->DKD_FILIAL	:= xFilial("DKD") 
	DKD->DKD_DOC	:= cNFiscal
	DKD->DKD_SERIE	:= cSerie
	DKD->DKD_FORNEC	:= cA100For
	DKD->DKD_LOJA	:= cLoja
	DKD->DKD_EMISSA	:= dDEmissao
	DKD->DKD_ESPECI	:= cEspecie
	For nI := 1 to Len(aHeadDKD)
		DKD->(FieldPut(FieldPos(aHeadDKD[nI,2]),aColsDKD[nPosIt][nI]))
	Next nI
	DKD->(MsUnlock())
ElseIf lSeekDkd .and. RecLock("DKD",.F.)
	DKD->(Dbdelete())
	DKD->(MsUnlock())
Endif
	
Return

/*/{Protheus.doc} A103DKDGAT
Função generica para utilização de gatilhos

@author  rodrigo.mpontes
@version P12
@since   11/06/2022 
/*/

Function A103DKDGAT(cAliasFind,nIndFind,cChvFind,cCpoRet,cCpoDKD)

Local xRet		:= Nil
Local nPosDKD	:= GdFieldPos(cCpoDKD,aHeadDKD)

xRet := GetAdvFVal(cAliasFind,cCpoRet,xFilial(cAliasFind) + cChvFind,nIndFind)

If ValType(xRet) == "U"
	xRet := CriaVar(cCpoDKD) 
Endif

If nPosDKD > 0
	oGetDKD:aCols[oGetDKD:nAt,nPosDKD] := xRet
	oGetDKD:Refresh()
	oGetDKD:oBrowse:Refresh()

Endif

Return xRet

/*/{Protheus.doc} A103DKDGAT
Aciona os gatilhos da dkd

@author  Leandro Nishihata
@version P12
@since   11/06/2022 
/*/

Function gatilhadkd()
Local cCpo := ""
Local nI := 0
	DbSelectArea("SX7")
	SX7->( dbSetOrder( 1 ) )

	If SX7->( dbSeek( 'D1_' ) )
		While !SX7->( Eof() ) .And. LEFT(SX7->X7_CAMPO,3) == "D1_"		
			IF LEFT(SX7->X7_CDOMIN,4) == "DKD_" .AND. cCpo <> SX7->X7_CAMPO
				FOR nI := 1 to len(acols)
					cCpo := SX7->X7_CAMPO
					RunTrigger(2,nI,,,alltrim(SX7->X7_CAMPO))
				Next ni
			Endif
			SX7->( DbSkip() )
		End
	EndIf

Return
