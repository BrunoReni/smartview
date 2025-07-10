#INCLUDE "MATA012.CH"
#INCLUDE "PROTHEUS.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ MATA012  ³ Autor ³Rodrigo de A Sartorio  ³ Data ³03/02/05  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa de atualizacao de documentos                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Void MATA012(void)                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function MATA012()
Local cTipoNf  := SuperGetMV("MV_TPNRNFS")
Local lGrpCNPJ := MaIsNumCgc()

Private cCadastro	:= STR0006
Private aRotina 	:= {}
	
If cTipoNf == "3"
	
	aRotina 	:= MenuDef()
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Browse da Controle de Geracao de Documentos. ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oMBrowse := FWMBrowse():New()
	oMBrowse:SetAlias("SD9")
	oMBrowse:SetDescription(STR0006) //"Oportunidade de Venda"
	
	If lGrpCNPJ // Agrupamento por CNPJ
		oMBrowse:SetFilterDefault("D9_CNPJ == '" + SM0->M0_CGC + "'")
	EndIf
	
	oMBrowse:Activate()
	
Else
	MsgAlert(STR0007,STR0008) //"Parametro MV_TPNRNFS nao configurado para esta opcao !!"###"ATENCAO"			
EndIf
	
Return(.T.)

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³MTA012Inc ³ Autor ³Rodrigo de A Sartorio  ³ Data ³ 03/02/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Inclusao de documentos para uma serie determinada          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ Void MTA012Inc(ExpC1,ExpN1)                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias do arquivo                                   ³±±
±±³          ³ ExpN1 = Numero do registro                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATA012()                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function MTA012Inc(cAlias,nReg,nOpc)
Local nTentativas := 0
Local aCpos       := {"D9_DOC","D9_SERIE","D9_NSU","D9_MOTIVO"}
Local lGrpCNPJ    := MaIsNumCgc()
Local nOpca       := 0

If lGrpCNPJ
	aAdd(aCpos,"D9_CNPJ")
EndIf

// Trava arquivo para somente este usuario utilizar rotina
While !LockByName("A461NUMNF",.T.,!Empty(xFilial("SD9")),.T.) .And. nTentativas <= 50
	nTentativas++
	Sleep(5000)
End

// Se apos 50 tentativas nao conseguir travar chave aborta sistema
If nTentativas >= 50
	MsgAlert(STR0009,STR0008) //"NAO CONSEGUI LOCKBYNAME A461NUMNF !!"###"ATENCAO"
Else
	Begin Transaction
	nOpca := AxInclui(cAlias,nReg,nOpc,aCpos,,,"A012TudoOk(nOpc)")	 		
	
	If nOpca == 1 //Confirmou a inclusao
		Reclock("SD9", .F.)
		If lGrpCNPJ 
			SD9->D9_FILIAL := Space( FWSizeFilial() )
		EndIf

		SerieNfId("SD9",1,"D9_SERIE",dDataBase,A460Especie(Substr(SD9->D9_SERIE,1,3)),SD9->D9_SERIE)

		SD9->( MsUnlock() )
	EndIf
	
	End Transaction
	
	UnLockByName("A461NUMNF",.T.,!Empty(xFilial("SD9")),.T.)
EndIf

Return Nil

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³MTA012Alt ³ Autor ³Rodrigo de A Sartorio  ³ Data ³ 03/02/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Alteracao de documentos para uma serie determinada         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ Void MTA012Alt(ExpC1,ExpN1)                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias do arquivo                                   ³±±
±±³          ³ ExpN1 = Numero do registro                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATA012()                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function MTA012Alt(cAlias,nReg,nOpc)
Local nOpca      	:= 0
Local nTentativas	:= 0
Local aCpos      	:= {"D9_DOC","D9_DTUSO","D9_HORA","D9_NSU","D9_MOTIVO"}
Local lGrpCNPJ   	:= MaIsNumCgc()
Local cD9FilAnt  	:= ""
Local nD9Recno   	:= 0
Local lD9FilEmpty	:= .F.
Local lRetorno	:= .T.
Local lUsaNewKey:= TamSX3("F2_SERIE")[1] == 14 // Verifica se o novo formato de gravacao do Id nos campos _SERIE esta em uso

If lGrpCNPJ
	aAdd(aCpos,"D9_CNPJ")
EndIf

If !Empty(SD9->D9_DTUSO)
	MsgAlert(STR0010,STR0008) //"Somente documentos nao utilizados podem ser alterados !!"###"ATENCAO"
	lRetorno := .F.
EndIf

If lRetorno 

	// Trava arquivo para somente este usuario utilizar rotina
	While !LockByName("A461NUMNF",.T.,!Empty(xFilial("SD9")),.T.) .And. nTentativas <= 50
		nTentativas++
		Sleep(5000)
	End

	// Se apos 50 tentativas nao conseguir travar chave aborta sistema
	If nTentativas >= 50
		MsgAlert(STR0009,STR0008) //"NAO CONSEGUI LOCKBYNAME A461NUMNF !!"###"ATENCAO"
		lRetorno := .F.
	Else
		Begin Transaction
		
			lD9FilEmpty := Empty(SD9->D9_FILIAL)
			
			If lGrpCNPJ .And. lD9FilEmpty
				cD9FilAnt := SD9->D9_FILIAL
				nD9Recno  := SD9->(Recno())
				Reclock("SD9",.F.)
				SD9->D9_FILIAL := FWxFilial()
				SD9->( MsUnlock() )
			EndIf
			
			nOpcA := AxAltera(cAlias,nReg,nOpc,,aCpos,,,"A012TudoOk(nOpc)",,"A012PreValid(nOpc)")
	
			If lUsaNewKey
				Reclock("SD9", .F.)
				SerieNfId("SD9",1,"D9_SERIE",SD9->D9_DTUSO,A460Especie(Substr(SD9->D9_SERIE,1,3)),SD9->D9_SERIE)
				SD9->( MsUnlock() )			
            EndIf

			If lGrpCNPJ .And. lD9FilEmpty
				// Caso a data de uso esteja em branco retornar a Filial anteior 
				If Empty(SD9->D9_DTUSO)  
					SD9->( DbGoTo( nD9Recno ) )
					Reclock("SD9", .F.)
					SD9->D9_FILIAL := cD9FilAnt
					SD9->( MsUnlock() )			
				Endif
			EndIf
            
		End Transaction
		
		UnLockByName("A461NUMNF",.T.,!Empty(xFilial("SD9")),.T.)
		
	EndIf
	
EndIf

Return(lRetorno) 

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³MTA012Exc ³ Autor ³Rodrigo de A Sartorio  ³ Data ³ 03/02/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Exclusao de documentos para uma serie determinada          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ Void MTA012Exc(ExpC1,ExpN1)                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias do arquivo                                   ³±±
±±³          ³ ExpN1 = Numero do registro                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATA012()                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function MTA012Exc(cAlias,nReg,nOpc)
Local nOpca       := 0
Local nTentativas := 0

If Empty(D9_DTUSO)

	// Trava arquivo para somente este usuario utilizar rotina
	While !LockByName("A461NUMNF",.T.,!Empty(xFilial("SD9")),.T.) .And. nTentativas <= 50
		nTentativas++
		Sleep(5000)
	End
	// Se apos 50 tentativas nao conseguir travar chave aborta sistema
	If nTentativas >= 50
		MsgAlert(STR0009,STR0008) //"NAO CONSEGUI LOCKBYNAME A461NUMNF !!"###"ATENCAO"
	Else
		Begin Transaction
		
			nOpcA := AxDeleta(cAlias,nReg,nOpc)
		
		End Transaction
		
		UnLockByName("A461NUMNF",.T.,!Empty(xFilial("SD9")),.T.)
	EndIf
	
Else
	MsgAlert(STR0011,STR0008) //"Somente documentos nao utilizados podem ser excluidos !!"###"ATENCAO"
EndIf

Return Nil

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³MTA012Viz ³ Autor ³By Wise Consulting     ³ Data ³13/09/2013³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Visualizacao de documentos para uma serie determinada      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ Void MTA012Viz(ExpC1,ExpN1)                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias do arquivo                                   ³±±
±±³          ³ ExpN1 = Numero do registro                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATA012()                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function MTA012Viz(cAlias,nReg,nOpc)
Local nOpca       := 0
Local nTentativas := 0
Local lGrpCNPJ    := MaIsNumCgc()
Local cD9FilAnt   := ""
Local nD9Recno    := 0
Local lD9FilEmpty := .F.

// Trava arquivo para somente este usuario utilizar rotina
While !LockByName("A461NUMNF",.T.,!Empty(xFilial("SD9")),.T.) .And. nTentativas <= 50
	nTentativas++
	Sleep(5000)
End

// Se apos 50 tentativas nao conseguir travar chave aborta sistema
If nTentativas >= 50
	MsgAlert(STR0009,STR0008) //"NAO CONSEGUI LOCKBYNAME A461NUMNF !!"###"ATENCAO"
Else
	Begin Transaction

		lD9FilEmpty := Empty(SD9->D9_FILIAL)
	
		If lGrpCNPJ .And. lD9FilEmpty
			cD9FilAnt := SD9->D9_FILIAL
			nD9Recno  := SD9->( Recno() )
	
			Reclock("SD9", .F.)
			SD9->D9_FILIAL := FWxFilial()
			SD9->( MsUnlock() )
		EndIf
	
		nOpcA := AxVisual(cAlias,nReg,nOpc)
	
		If lGrpCNPJ .And. lD9FilEmpty
			SD9->(DbGoTo(nD9Recno))
			Reclock("SD9", .F.)
			SD9->D9_FILIAL := cD9FilAnt
			SD9->(MsUnlock())
		EndIf
		
	End Transaction
	
	UnLockByName("A461NUMNF",.T.,!Empty(xFilial("SD9")),.T.)
	
EndIf

Return Nil

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A012TudoOk³ Autor ³Rodrigo de A Sartorio  ³ Data ³ 03/02/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao de validacao do documento incluido / alterado        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ Void A012TudoOk(ExpN1)                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 = Opcao escolhida                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATA012()                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A012TudoOk(nOpc)
Local lRet      := .T.
Local aArea     := GetArea()
Local aAreaSD9  := SD9->(GetArea())
Local cLastDoc  := Criavar("D9_DOC",.F.)
Local cLastNSU  := Criavar("D9_NSU",.F.)
Local cQuery    := ""
Local cAliasNew := ""
Local lGrpCNPJ  := GetMv("MV_FATGCGC",,.F.) 
Local aFilCGC   := {"",""}
Local lUsaNewKey:= TamSX3("F2_SERIE")[1] == 14 // Verifica se o novo formato de gravacao do Id nos campos _SERIE esta em uso

If nOpc == 4 //Altera

	If IIf(lUsaNewKey,SD9->D9_SDOC,SD9->D9_SERIE)+SD9->D9_DOC <> M->D9_SERIE+M->D9_DOC
	
		If lGrpCNPJ

			If lUsaNewKey
				SD9->(dbSetOrder(10)) //D9_CNPJ+D9_SDOC+D9_DOC+DTOS(D9_DTUSO)
			ELse
				SD9->(dbSetOrder(5)) //D9_CNPJ+D9_SERIE+D9_DOC+DTOS(D9_DTUSO)
			EndIf	
				
			If SD9->( DbSeek( PadR(SM0->M0_CGC, TamSX3("D9_CNPJ")[1] ) + M->D9_SERIE + M->D9_DOC ) )
				MsgAlert(STR0012,STR0008)			//"Documento ja existe !!"###"ATENCAO"
				lRet := .F.
			EndIf	
		Else

			If lUsaNewKey
				dbSetOrder(7) // D9_FILIAL+D9_SDOC+D9_DOC+DTOS(D9_DTUSO)
			Else
				dbSetOrder(2) // D9_FILIAL+D9_SERIE+D9_DOC+DTOS(D9_DTUSO)
			EndIf

			If SD9->(dbSeek(xFilial("SD9")+M->D9_SERIE+M->D9_DOC)) .Or. !VldSX5Num(M->D9_DOC,M->D9_SERIE,.F., SerieNfId("SD9",4,"D9_SERIE",M->D9_DTUSO,A460Especie(M->D9_SERIE),M->D9_SERIE) )
				MsgAlert(STR0012,STR0008)			//"Documento ja existe !!"###"ATENCAO"
				lRet := .F.
			EndIf
		EndIf
		
	EndIf

ElseIf nOpc == 3 //Inclui

	If lGrpCNPJ

		If lUsaNewKey
			SD9->(dbSetOrder(10)) //D9_CNPJ+D9_SDOC+D9_DOC+DTOS(D9_DTUSO)
		ELse
			SD9->(dbSetOrder(5)) //D9_CNPJ+D9_SERIE+D9_DOC+DTOS(D9_DTUSO)
		EndIf

		If SD9->( dbSeek( PadR(SM0->M0_CGC, TamSX3("D9_CNPJ")[1] ) + M->D9_SERIE + M->D9_DOC ) ) .Or. !VldSX5Num(M->D9_DOC,M->D9_SERIE,.F., SerieNfId("SD9",4,"D9_SERIE",M->D9_DTUSO,A460Especie(M->D9_SERIE),M->D9_SERIE) )
			MsgAlert(STR0012,STR0008)			//"Documento ja existe !!"###"ATENCAO"
			lRet:=.F.
		EndIf
	Else

		If lUsaNewKey
			dbSetOrder(7) // D9_FILIAL+D9_SDOC+D9_DOC+DTOS(D9_DTUSO)
		Else
			dbSetOrder(2) // D9_FILIAL+D9_SERIE+D9_DOC+DTOS(D9_DTUSO)
		EndIf

		If SD9->(dbSeek(xFilial("SD9")+M->D9_SERIE+M->D9_DOC)) .Or. !VldSX5Num(M->D9_DOC,M->D9_SERIE,.F. , SerieNfId("SD9",4,"D9_SERIE",M->D9_DTUSO,A460Especie(M->D9_SERIE),M->D9_SERIE) )
			MsgAlert(STR0012,STR0008)			//"Documento ja existe !!"###"ATENCAO"
			lRet:=.F.
		EndIf
	EndIf

EndIf

// ORDEM 3 - D9_FILIAL+D9_NSU+D9_SERIE+D9_DOC    
If cPaisLoc == "BRA"     
	If SD9->D9_NSU <> M->D9_NSU
		SD9->(dbSetOrder(3))
		If SD9->(dbSeek(xFilial("SD9")+M->D9_NSU))
			MsgAlert(STR0016,STR0008)			//"NSU ja existe!"###"ATENCAO"
			lRet := .F.
		EndIf	
	EndIf
EndIf	

If lRet .And. cPaisLoc == "BRA"

	// Obtem ultimo numero
	// Obtem o ultimo numero da filial
	cAliasNew := GetNextAlias()
	cQuery := "SELECT MAX(D9_NSU) D9_NSU FROM " + RetSqlName( "SD9" )
	
	If lUsaNewKey
		cQuery += " WHERE D9_FILIAL = '" + xFilial( "SD9" ) + "' AND D9_SDOC  = '"+M->D9_SERIE+"' AND D9_NSU <> '"+cLastNSU+"'"
 	Else
		cQuery += " WHERE D9_FILIAL = '" + xFilial( "SD9" ) + "' AND D9_SERIE = '"+M->D9_SERIE+"' AND D9_NSU <> '"+cLastNSU+"'"
 	EndIf
 	
	cQuery += " AND D_E_L_E_T_ = ' '"
	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasNew,.F.,.T.)
	DbSelectArea(cAliasNew)
	If !(Eof()) .And. !Empty((cAliasNew)->D9_NSU)
		cLastNSU:=(cAliasNew)->D9_NSU
	EndIf
	
	(cAliasNew)->(DBCloseArea())
	
	If M->D9_NSU > Soma1(cLastNSU)
		lRet := Aviso(STR0008,STR0017+cLastNSU,{STR0014,STR0015}) == 1 //"ATENCAO"###"NSU informada nao esta na sequencia. Ultima NSU gravada foi No. "###"Confirma"###"Abandona"
	EndIf		
	
EndIf
	
If lRet .And. nOpc == 4
	
	// Obtem ultimo numero
	// Obtem o ultimo numero da filial
	cAliasNew := GetNextAlias()
	cQuery := " SELECT MAX(D9_DOC) D9_DOC"
	cQuery += " FROM " + RetSqlName( "SD9" )
		
	If lGrpCNPJ // Utilizando o conceito de Agrupamento por CNPJ
		aFilCGC := MatFilCgc(SM0->M0_CGC,"SD9") // Retorna o Compartilhamento conforme CNPJ
		cQuery += " WHERE D9_FILIAL IN " + FormatIN(aFilCGC[1],aFilCGC[2])
	Else
		cQuery += " WHERE D9_FILIAL = '" + xFilial( "SD9" ) + "'"
	Endif
		
	If lUsaNewKey
		cQuery += "    AND D9_SDOC = '"+M->D9_SERIE+"'"
	Else
		cQuery += "    AND D9_SERIE = '"+M->D9_SERIE+"'"
	EndIf

	cQuery += "    AND D9_DTUSO <> ' ' "
	cQuery += "    AND D9_DOC <> '"+cLastDoc+"'"
	cQuery += "    AND D_E_L_E_T_ = ' '"
	cQuery := ChangeQuery(cQuery)
		
	DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasNew,.F.,.T.)
	DbSelectArea(cAliasNew)
	If !(Eof()) .And. !Empty((cAliasNew)->D9_DOC)
		cLastDoc := (cAliasNew)->D9_DOC
	EndIf
	
	(cAliasNew)->(DBCloseArea())
	
	If M->D9_DOC < cLastDoc
		lRet := Aviso(STR0008,STR0013,{STR0014,STR0015}) == 1 //"ATENCAO"###"Foi sugerido um documento menor que o ultimo documento desta serie. Quanto a esta alteracao ?"###"Confirma"###"Abandona"
	EndIf

EndIf

SD9->(RestArea(aAreaSD9))

RestArea(aArea)

Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³MenuDef   ³ Autor ³ Marco Bianchi         ³ Data ³01/09/2006³±±
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
±±³          ³		1 - Pesquisa e Posiciona em um Banco de Dados         ³±±
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
     
Private aRotina := {	{STR0001,"AxPesqui"	, 0 , 1,0,.F.},;		// "Pesquisar"
							{STR0002,"MTA012Viz"	, 0 , 2,0,NIL},;    // "Visualizar"
							{STR0003,"MTA012Inc"	, 0 , 3,0,NIL},;    // "Incluir"
							{STR0004,"MTA012Alt"	, 0 , 4,82,NIL},;		// "Alterar"
							{STR0005,"MTA012Exc"	, 0 , 5,0,NIL}}     // "Excluir"

If ExistBlock("MT012MNU")
	ExecBlock("MT012MNU",.F.,.F.)
EndIf

Return(aRotina)

//-------------------------------------------------------------------
/*/{Protheus.doc} A012PreValid
Função executada antes da abertura da Enchoice.

@author Squad CRM & FAT
@since 22/02/2019
@version 12
@param nOpc, numeric, Operação que está sendo executada
/*/
//-------------------------------------------------------------------
Function A012PreValid(nOpc)

Local lRet := .T.

If nOpc == 4	//Alteração
	M->D9_USUARIO := CUSERNAME
EndIf

Return lRet