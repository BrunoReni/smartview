#INCLUDE "PROTHEUS.CH"
#INCLUDE "COMA020.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ COMA020  ³ Autor ³ Aline Correa do Vale  ³ Data ³ 10.11.2003 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Cadastro de Tolerancia no Recebimento de Materiais           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ PROGRAMADOR  ³ DATA   ³ BOPS ³  MOTIVO DA ALTERACAO                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function COMA020()

	PRIVATE aRotina		:= MenuDef()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Define o cabecalho da tela de atualizacoes                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	PRIVATE cCadastro := OemtoAnsi(STR0001)	//"Tolerancia de Recebimento de Materiais"

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Endereca a funcao de BROWSE                                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	mBrowse( 6, 1,22,75,"AIC")
Return


/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³CM020Inclui³ Autor ³ Aline Correa do Vale ³ Data ³10.11.2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa de Inclusao de Tes Inteligente                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias do arquivo                                   ³±±
±±³          ³ ExpN1 = Numero do registro                                 ³±±
±±³          ³ ExpN2 = Numero da opcao selecionada                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ COMA020()                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CM020Inclui(cAlias,nReg,nOpc)

	Local nOpca := 0
	INCLUI := .T.
	ALTERA := .F.

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Envia para processamento dos Gets          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nOpcA:=0

	Begin Transaction
		nOpcA:=AxInclui( cAlias, nReg, nOpc,,,,"CM020TudOk(nOpc)")
	End Transaction

	dbSelectArea(cAlias)
Return


/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³CM020Altera³ Autor ³ Aline Correa do Vale ³ Data ³10.11.2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa de Inclusao de Tes Inteligente                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias do arquivo                                   ³±±
±±³          ³ ExpN1 = Numero do registro                                 ³±±
±±³          ³ ExpN2 = Numero da opcao selecionada                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ COMA020()                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CM020Altera(cAlias,nReg,nOpc)

	Local nOpca := 0
	INCLUI := .F.
	ALTERA := .T.

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Envia para processamento dos Gets          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nOpcA:=0

	Begin Transaction
		nOpcA:=AxAltera( cAlias, nReg, nOpc,,,,,"CM020TudOk(nOpc)")
	End Transaction

	dbSelectArea(cAlias)
Return

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³CM020Exclui³ Autor ³ Turibio Miranda		³ Data ³17.03.2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa de Exclusao de Tolerancia	                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias do arquivo                                   ³±±
±±³          ³ ExpN1 = Numero do registro                                 ³±±
±±³          ³ ExpN2 = Numero da opcao selecionada                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ COMA020()                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CM020Exclui(cAlias,nReg,nOpc)

	Local nOpca := 0
	INCLUI := .F.
	ALTERA := .F.
	lRet   := CM020TudOk(nOpc)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Envia para processamento dos Gets          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nOpcA:=0
	If lRet
		Begin Transaction
			nOpcA:=AxDeleta( cAlias, nReg, nOpc )
		End Transaction
	EndIf	  
	dbSelectArea(cAlias)
Return

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³CM020TudOk ³ Autor ³ Aline Correa do Vale ³ Data ³10.11.2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Verifica se o registro esta com chave duplicada             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³CM020TudOk()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³COMA020                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CM020TudOk(nOpc)
	Local lRet      := .T.
	Local lRetPE    := .T.

	dbSetOrder(2)
	If INCLUI .And. dbSeek(xFilial("AIC")+M->AIC_FORNEC+M->AIC_LOJA+M->AIC_PRODUT+M->AIC_GRUPO)
		Help(" ",1,"JAGRAVADO")
		lRet := .F.
	Endif
	dbSetOrder(1)

	If lRet .And. ExistBlock("CM020VLD")
		lRetPE:= ExecBlock("CM020VLD",.F.,.F.,{nOpc})
		If ValType(lRetPE) == "L"
			lRet:= lRetPE
		EndIf
	EndIf

Return lRet


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ COMA020  ³ Autor ³ Aline Correa do Vale  ³ Data ³ 10.11.2003 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe: MaValToler(ExpC1,ExpC2,ExpC3,ExpN1,ExpN2,ExpN3,ExpN4,ExpL1,ExpL2)±±
±±ÃÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ ExpC1 = Codigo do Fornecedor                                 ³±±
±±³          ³ ExpC2 = Loja do Fornecedor                                   ³±±
±±³          ³ ExpC3 = Codigo do Produto                                    ³±±
±±³          ³ ExpN1 = Quantidade a entregar                                ³±±
±±³          ³ ExpN2 = Quantidade Original do Pedido                        ³±±
±±³          ³ ExpN3 = Preco a receber                                      ³±±
±±³          ³ ExpN4 = Preco Original do Pedido                             ³±±
±±³          ³ ExpL1 = Exibir Help                                          ³±±
±±³          ³ ExpL2 = Indica se verifica Quantidade                        ³±±
±±³          ³ ExpL3 = Indica se verifica Preço                             ³±±
±±³          ³ ExpL4 = Indica se verifica Data                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ PROGRAMADOR  ³ DATA   ³ BOPS ³  MOTIVO DA ALTERACAO                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function MaAvalToler(cFornece,cLoja,cProduto, nQtde, nQtdeOri, nPreco, nPrecoOri, lHelp, lQtde, lPreco, lData, lPedido )

	Local aArea		:= GetArea()
	Local aAreaSA2	:= SA2->(GetArea())
	Local aAreaSB1	:= SB1->(GetArea())
	Local aAreaSAK	:= {}
	Local aAreaSAL	:= {}
	Local dDatPrf	:= SC7->C7_DATPRF
	Local cAliasAIC := "AIC"         
	Local cGrupo	:= ""
	Local cGrupoPE	:= ""
	Local lAchou    := .F.
	Local lBloqueio := .F.
	Local lBLQTolNeg:= .F. 				
	Local nPQtde    := 0
	Local nPPreco   := 0
	Local nDiaTol	:= 0
	Local cTolent	:= SuperGetMV("MV_TOLENT" , .F.,"") 
	Local lTolerNeg := SuperGetMV("MV_TOLENEG",.F.,.F.)
	Local lTolerZer := SuperGetMV("MV_TOLZERO",.F.,.F.) //Aceita ou não tolerância de 0 dias para bloqueio de documento
	Local lTolRegGrp := SuperGetMV("MV_TOREGGR",.F.,.F.) //Prioriza Grupo de Produto para Regra de Tolerância de Recebimento
	Local lOk 		:= .T.
	Local lCMA20Blq := .F.

	DEFAULT cFornece := ""
	DEFAULT cLoja    := ""
	DEFAULT cProduto := ""
	DEFAULT nQtde    := 0
	DEFAULT nQtdeOri := 0
	DEFAULT nPreco   := 0
	DEFAULT nPrecoOri:= 0
	DEFAULT lHelp	 := .F.
	DEFAULT lQtde	 := .T.
	DEFAULT lPreco	 := .T.
	DEFAULT lData 	 := .T.
	DEFAULT lPedido	 := .T.

	If cPaisLoc $ "ARG|BOL|COS"
		If lPedido
			If SC7->C7_MOEDA==1 .And. nMoedaNF<>1
				nPrecoOri:= nPrecoOri*SM2->M2_MOEDA1  
			ElseIf SC7->C7_MOEDA==2 .And. nMoedaNF<>2
				nPrecoOri:= nPrecoOri*SM2->M2_MOEDA2  
			ElseIf SC7->C7_MOEDA==3 .And. nMoedaNF<>3
				nPrecoOri:= nPrecoOri*SM2->M2_MOEDA3  
			ElseIf SC7->C7_MOEDA==4 .And. nMoedaNF<>4
				nPrecoOri:= nPrecoOri*SM2->M2_MOEDA4  
			ElseIf SC7->C7_MOEDA==5 .And. nMoedaNF<>5
				nPrecoOri:= nPrecoOri*SM2->M2_MOEDA5  
			EndIf
		Else
			If SF1->F1_MOEDA==1 .And. nMoedaNF<>1
				nPrecoOri:= nPrecoOri*SM2->M2_MOEDA1  
			ElseIf SF1->F1_MOEDA==2 .And. nMoedaNF<>2
				nPrecoOri:= nPrecoOri*SM2->M2_MOEDA2 
			ElseIf SF1->F1_MOEDA==3 .And. nMoedaNF<>3
				nPrecoOri:= nPrecoOri*SM2->M2_MOEDA3
			EndIf
		EndIf
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica o grupo de tributacao do cliente/fornecedor         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("SA2")
	dbSetOrder(1)
	MsSeek(xFilial("SA2")+cFornece+cLoja)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica o grupo do produto                                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("SB1")
	dbSetOrder(1)
	MsSeek(xFilial("SB1")+cProduto)
	cGrpPrd := SB1->B1_GRUPO
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Pesquisa por todas as regras validas para este caso          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("AIC")
	dbSetOrder(2)
	lAchou := .F.
	If !lTolRegGrp	
		If !Empty(cFornece+cLoja)
			If !Empty(cProduto)
				If !MsSeek(xFilial("AIC")+cFornece+cLoja+cProduto)
					lAchou := MsSeek(xFilial("AIC")+cFornece+Space(Len(cLoja))+cProduto)
				Else
					lAchou := .T.
				EndIf
			Endif	
			If !lAchou .And. !Empty(cGrpPrd)
				If !MsSeek(xFilial("AIC")+cFornece+cLoja+Space(Len(cProduto))+cGrpPrd)
					lAchou := MsSeek(xFilial("AIC")+cFornece+Space(Len(cLoja+cProduto))+cGrpPrd)
				Else
					lAchou := .T.
				EndIf
			Endif	
			If !lAchou .and. MsSeek(xFilial("AIC")+cFornece+cLoja)
				While !lAchou .AND. !Eof() .AND. AIC->AIC_FORNECE == cFornece .AND. AIC->AIC_LOJA == cLoja
					If Empty(Alltrim(AIC->AIC_PRODUT + AIC->AIC_GRUPO))
						lAchou := .T.
					else
						dbSkip()
					Endif
				Enddo
			Endif		
			IF !lAchou .and. MsSeek(xFilial("AIC")+cFornece)
					While !lAchou .AND. !Eof() .AND. AIC->AIC_FORNECE == cFornece
						If Empty(Alltrim(AIC->AIC_LOJA + AIC->AIC_PRODUT + AIC->AIC_GRUPO))
							lAchou := .T.
						else
							dbSkip()
						Endif						
					Enddo
			Endif
		EndIf
		If !lAchou .And. !Empty(cProduto)
			lAchou := MsSeek(xFilial("AIC")+Space(Len(cFornece+cLoja))+cProduto)
		EndIf
		If !lAchou .and. !Empty(cGrpPrd)
			If !MsSeek(xFilial("AIC")+Space(Len(cFornece+cLoja+cProduto))+cGrpPrd)
				If !MsSeek(xFilial("AIC")+cFornece+Space(Len(cLoja+cProduto))+cGrpPrd)
					If !MsSeek(xFilial("AIC")+cFornece+cLoja+Space(Len(cProduto))+cGrpPrd)
						If !MsSeek(xFilial("AIC")+Space(Len(cFornece+cLoja+cProduto))+cGrpPrd)
							lAchou := MsSeek(xFilial("AIC")+Space(Len(cFornece+cLoja+cProduto+cGrpPrd)))
						Else
							lAchou := .T.
						EndIf
					Else
						lAchou := .T.
					EndIf
				Else
					lAchou := .T.
				EndIf                        
			Else
				lAchou := .T.
			EndIf
		Endif
		If !lAchou
			lAchou := MsSeek(xFilial("AIC")+cFornece+cLoja+Space(Len(cProduto))+Space(Len(cGrpPrd)))
		EndIf

		If !lAchou 
			lAchou := MsSeek(xFilial("AIC")+Space(Len(cFornece+cLoja))+Space(Len(cProduto))+Space(Len(cGrpPrd)))
		EndIf
	Else
		If !lAchou .And. !Empty(cGrpPrd)
			If !MsSeek(xFilial("AIC")+cFornece+cLoja+cProduto+cGrpPrd)
				If !MsSeek(xFilial("AIC")+cFornece+cLoja+Space(Len(cProduto))+cGrpPrd)
					If !MsSeek(xFilial("AIC")+cFornece+Space(Len(cLoja+cProduto))+cGrpPrd)
						lAchou := MsSeek(xFilial("AIC")+Space(Len(cFornece+cLoja+cProduto))+cGrpPrd)
					Else
						lAchou := .T.
					Endif
				else
					lAchou := .T.
				Endif
			Else
				lAchou := .T.
			EndIf
		Endif

		If !lAchou .And. !Empty(cProduto)
			If !MsSeek(xFilial("AIC")+cFornece+cLoja+cProduto+Space(Len(cGrpPrd)))
				If !MsSeek(xFilial("AIC")+cFornece+Space(Len(cLoja))+cProduto+Space(Len(cGrpPrd)))
					lAchou := MsSeek(xFilial("AIC")+Space(Len(cFornece+cLoja))+cProduto+Space(Len(cGrpPrd)))
				Else
					lAchou := .T.
				Endif
			Else
				lAchou := .T.
			EndIf
		Endif

		If !lAchou .And. !Empty(cFornece)  
			If !MsSeek(xFilial("AIC")+cFornece+cLoja+Space(Len(cProduto))+Space(Len(cGrpPrd)))
				lAchou := MsSeek(xFilial("AIC")+cFornece+Space(Len(cLoja))+Space(Len(cProduto))+Space(Len(cGrpPrd)))
			Else
				lAchou := .T.
			EndIf
		Endif
		If !lAchou 
			lAchou := MsSeek(xFilial("AIC")+Space(Len(cFornece+cLoja))+Space(Len(cProduto))+Space(Len(cGrpPrd)))
		EndIf		
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Pesquisa por todas as regras validas para este caso          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !(cAliasAIC)->(Eof()) .And. lAchou
		nPPreco := (cAliasAIC)->AIC_PPRECO
		nPQtde  := (cAliasAIC)->AIC_PQTDE
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Se o parametro MV_TOLENEG estiver .T. o percentual de tolerancia ³
	//³ do preco e da quantidade passam a validar tambem os valores da   |
	//³ NFE que estiverem a menor que o PC aplicando o bloqueio quando os³
	//³ valores ultrapassarem o percentual estabelecido da qtd e do Preco|
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lAchou
		If (nQtde+nQtdeOri) > 0 .Or. (nPreco+nPrecoOri) > 0		
			If lTolerNeg
				If lQtde 
					If ABS(((nQtde / nQtdeOri) -1) * 100) > nPQtde
						lBLQTolNeg := .T. 				
					EndIf
				Endif
				If lPreco
					If ABS(((nPreco / nPrecoOri) -1)*100) > nPPreco
						lBLQTolNeg := .T. 				
					EndIf				
				Endif
			EndIf		
		EndIf
	EndIf

	If lQtde
		If lAchou .And. (nQtde+nQtdeOri) > 0
			If (((nQtde / nQtdeOri) -1)*100) > nPQtde .Or. lBLQTolNeg
				If lHelp
					Help(" ",1,"QTDLIBMAI")
				EndIf
				lBloqueio := .T.
				if Type("aNFMotBloq") = "A"
					aAdd(aNFMotBloq,Alltrim(SC7->C7_ITEM)+"Q")//"Quantidade"
				endif
			EndIf
		EndIf
	EndIf                 

	If !lBloqueio .and. lPreco
		If lAchou .And. (nPreco+nPrecoOri) > 0
			If (((nPreco / nPrecoOri) -1)*100) > nPPreco .Or. lBLQTolNeg
				If lHelp
					Help(" ",1,"PRCLIBMAI")
				EndIf
				lBloqueio := .T.
				if Type("aNFMotBloq") = "A"
					aAdd(aNFMotBloq,Alltrim(SC7->C7_ITEM)+"P")//"Preço"
				endif
			EndIf
		EndIf
	Endif   

 	If !lBloqueio .And. lData
		nDiaTol := (cAliasAIC)->AIC_TOLENT
		If lAchou .And. nDiaTol >= 0
			lOk := .T.

			If nDiaTol == 0 .and. !lTolerZer
				lOk := .F.
			EndIf

			If lOk
				Do Case
					Case cTolent == "1" .and. (dDatPrf + nDiaTol) < dDataBase
					lBloqueio := .T.
					Case cTolent == "2" .and. (dDatPrf - nDiaTol) > dDataBase
					lBloqueio := .T.
					Case cTolent == "3" .and. ((dDatPrf + nDiaTol) < dDataBase .or. (dDatPrf - nDiaTol) > dDataBase)
					lBloqueio := .T.
				EndCase
			
				if Type("aNFMotBloq") = "A" .and. lBloqueio 
					aAdd(aNFMotBloq,Alltrim(SC7->C7_ITEM)+"E") //Prz de entrega.
				endif 
			Endif
		Endif         
		If lHelp .and. lBloqueio
			Help(" ",1,"DATLIBMAI")
		Endif
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Ponto de entrada para regra de Bloqueio do Usuario       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lAchou .And. ExistBlock("CMA20BLQ")
		lCMA20Blq := ExecBlock("CMA20BLQ",.F.,.F.,{lBloqueio})
		If Valtype( lCMA20Blq ) == "L"
			lBloqueio := lCMA20Blq
		EndIf
	EndIf

	If lBloqueio
		cGrupo := SuperGetMv("MV_NFAPROV")
		If IsInCallStack('MATA140')
			If ExistBlock("MT140APV")
				cGrupoPE := ExecBlock("MT140APV",.F.,.F.,{cGrupo})
			EndIf
		ElseIf IsInCallStack('MATA103')
			If ExistBlock("MT103APV")
				cGrupoPE := ExecBlock("MT103APV",.F.,.F.)
			EndIf
		EndIf	

		If ValType(cGrupoPE) == "C" .And. !Empty(cGrupoPE)
			cGrupo := cGrupoPE
		EndIf

		cGrupo:= If(Empty(SF1->F1_APROV),cGrupo,SF1->F1_APROV)

		//Validação do cadastro do grupo de aprovação
		aAreaSAK:=SAK->(GetArea())
		aAreaSAL:=SAL->(GetArea())

		SAL->(dbSetOrder(1))
		SAK->(dbSetOrder(1))

		If !Empty(cGrupo)
			lBloqueio := SAL->(dbSeek(xFilial("SAL")+cGrupo)) .And. ;
			SAK->(dbSeek(xFilial("SAK")+SAL->AL_APROV)) 
		EndIf
		RestArea(aAreaSAK)
		RestArea(aAreaSAL)
	EndIf

	RestArea(aAreaSA2)
	RestArea(aAreaSB1)
	RestArea(aArea)
Return({lBloqueio,nPQtde, nPPreco})


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³MenuDef   ³ Autor ³ Ricardo Berti         ³ Data ³31/01/2008³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Utilizacao de menu Funcional                               ³±±
±±³          ³                                                            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Array com opcoes da rotina.                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Parametros do array a Rotina:                               ³±±
±±³          ³1. Nome a aparecer no cabecalho                             ³±±
±±³          ³2. Nome da Rotina associada                                 ³±±
±±³          ³3. Reservado                                                ³±±
±±³          ³4. Tipo de Transa‡„o a ser efetuada:                        ³±±
±±³          ³	  1 - Pesquisa e Posiciona em um Banco de Dados           ³±±
±±³          ³    2 - Simplesmente Mostra os Campos                       ³±±
±±³          ³    3 - Inclui registros no Bancos de Dados                 ³±±
±±³          ³    4 - Altera o registro corrente                          ³±±
±±³          ³    5 - Remove o registro corrente do Banco de Dados        ³±±
±±³          ³5. Nivel de acesso                                          ³±±
±±³          ³6. Habilita Menu Funcional                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MenuDef()

	PRIVATE aRotina	:= {}

	aAdd(aRotina,{STR0002,"AxPesqui"	, 0, 1, 0, .F.}) //"Pesquisar"
	aAdd(aRotina,{STR0003,"AxVisual"	, 0, 2, 0, nil}) //"Visualizar"
	aAdd(aRotina,{STR0004,"CM020Inclui"	, 0, 3, 0, nil}) //"Incluir"
	aAdd(aRotina,{STR0005,"CM020Altera"	, 0, 4, 0, nil}) //"Alterar"
	aAdd(aRotina,{STR0006,"CM020Exclui"	, 0, 5, 0, nil}) //"Excluir"

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Ponto de entrada utilizado para inserir novas opcoes no array aRotina  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ExistBlock("CMA020MNU")
		ExecBlock("CMA020MNU",.F.,.F.)
	EndIf
Return(aRotina)
