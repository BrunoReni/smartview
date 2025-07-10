#INCLUDE "PROTHEUS.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ COMR040  ³ Autor ³ Totvs                 ³ Data ³ Out/2009 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Listar pedidos com detalhes do pedido e abertura 		  ³±±
±±³          ³ analítica por status. ID166.                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function COMR040()
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Define Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	Local cDesc1 := "Lista pedido de compra com o status de cada item. "
	Local cDesc2 := " "
	Local cDesc3 := " "
	Local aArea  := GetArea()
	
	Private cString  :="SC7"
	Private Tamanho  := "M"
	Private m_pag	 := 1
	Private Limite   := 132
	Private aOrd     := {}
	Private aReturn  := { "Zebrado", 1,"Administracao", 1, 2, 1, "",1 }
	Private nTipo    := 18
	Private wnrel 	 := "COMR040"            //Nome Default do relat¢rio em Disco
	Private nomeprog :="COMR040"
	Private nLastKey := 0
	Private cPerg    :="COMR040   "                  
	Private titulo   :="Detalhe do PC"
	
	//+--------------------------+
	//| Cria as perguntas em SX1 |
	//+--------------------------+
	AjustaSX1( cPerg )
	
	pergunte(cPerg,.F.)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Envia controle para a fun‡„o SETPRINT                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	wnrel := SetPrint(cString,wnrel,cPerg,@Titulo,cDesc1,cDesc2,cDesc3,.F.,aOrd,.F.,Tamanho,.F.,.F.)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Se teclar ESC, sair³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nLastKey == 27
		Return(Nil)
	EndIf
	
	SetDefault(aReturn,cString)
	
	If nLastKey == 27
		Return(Nil)
	EndIf
	
	nTipo := If(aReturn[4]==1,15,18)
	
	//Chama rotina de impressao
	RptStatus({|lEnd| RotImp(@lEnd,wnRel,cString)},"Aguarde...", "Imprimindo o Relatório", .T. )
	
	RestArea(aArea)

Return(Nil)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ RotImp   ³ Autor ³ Cadubitski            ³ Data ³ Out/2009 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Rotina de impressao do relatorio                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ RCOMR01Imp(lEnd,wnRel,cString)                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ lEnd    - A‡Æo do Codeblock                                ³±±
±±³          ³ wnRel   - T¡tulo do relat¢rio                              ³±±
±±³          ³ cString - Mensagem                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Gen‚rico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function RotImp(lEnd,wnRel,cString)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Vari veis utilizadas para Impress„o do Cabe‡alho e Rodap‚    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	Local cQuery := ""
	Local titulo :="Relatorio de Nf de Cobrança x Remessa"
	Local cabec1 := ""
	Local cabec2 := ""
	Local aColu  := {}
	Local li     := 60             
	Local cStatus:= ""            
	Local cTpDoc := ""
	                
	//	       0         10        20        30        40        50        60        70        80        90        100       110       120       130       140       150       160       170       180       190       200       210       220
	//	       012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234
	//         XXXXXX XXXX XXXXXXXXXXXXXXX XXXXXXXXXXXXXXXXXXXX XX 999,999.99 999,999.99 9,999,999.99 DD/MM/AAAA 999999 XXXXXXXXXXXXXX XXXXXXXXXXXXX
	cabec1 := "PEDIDO ITEM PRODUTO         DESCRICAO            UM QUANTIDADE    VL.UNIT     VL.TOTAL ENTREGA      SC   STATUS          TIPO DOC"
	
	AAdd(aColu,000)//01-Numero do pedido
	AAdd(aColu,007)//02-Item
	AAdd(aColu,012)//03-Cod Produto
	AAdd(aColu,028)//04-Descricao do Produto
	AAdd(aColu,049)//05-UM
	AAdd(aColu,052)//06-Quantidade
	AAdd(aColu,063)//07-Vl Unit
	AAdd(aColu,074)//08-Vl. Total
	AAdd(aColu,087)//09-Data de entrega
	AAdd(aColu,098)//10-SC
	AAdd(aColu,105)//11-Status 
	AAdd(aColu,120)//12-Tipo de Documento
	
	cQuery := "SELECT * "
	cQuery += " FROM "+RetSqlName("SC7")+" SC7 "
	cQuery += " INNER JOIN "
	cQuery += RetSqlName("SC1")+" SC1 ON "
	cQuery += " 	C1_FILIAL = '"+xFilial("SC1")+"' "
	cQuery += " 	AND C1_NUM = C7_NUMSC "
	cQuery += " 	AND C1_ITEM = C7_ITEMSC "
	
	//If MV_PAR05 <> 5 //Todas
	cQuery += " 	AND C1_XTIPOSC = '"+Alltrim((MV_PAR05))+"' "
	//EndIf
	
	cQuery += " 	AND SC1.D_E_L_E_T_ = ' ' "
	cQuery += " WHERE C7_FILIAL = '"+xFilial("SC7")+"'  "
	cQuery += " AND C7_NUM BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"' "
	cQuery += " AND C7_EMISSAO BETWEEN '"+DTOS(MV_PAR03)+"' AND '"+DTOS(MV_PAR04)+"' "
	cQuery += " AND SC7.D_E_L_E_T_ <> '*' "
	cQuery += " ORDER BY C7_NUM,C7_ITEM "
		                        
	cQuery := ChangeQuery( cQuery )
	dbUseArea( .T., "TopConn", TCGenQry(,,cQuery), "TRB", .T., .T. )
	//U_MONTAQRY(cQuery,"TRB")  
	
	DbSelectArea("TRB")
	
	SetRegua(RecCount())
	
	While !Eof()
	
		If lEnd
			@PROW()+1,001 PSAY "CANCELADO PELO OPERADOR"
			lContinua:=.F.
			Exit
		EndIf
		
		IncRegua("Gerando relatorio... "+TRB->C7_NUM+" ...")
	
		If li > 55
			cabec(titulo,cabec1,cabec2,nomeprog,tamanho,nTipo)
			li := 8
		EndIF
	
		//Verifica o Status do Pedido
		If !Empty(TRB->C7_RESIDUO)
			cStatus := "Elim. Residuo"
		ElseIf TRB->C7_CONAPRO == "B" .And. TRB->C7_QUJE < TRB->C7_QUANT
			cStatus := "Bloqueado"
		ElseIf !Empty(TRB->C7_CONTRA) .And. Empty(TRB->C7_RESIDUO)
			cStatus := "Int GCT"
		ElseIf TRB->C7_QUJE == 0 .And. TRB->C7_QTDACLA == 0 .and. Empty(TRB->C7_XSTATUS)
			cStatus := "Pendente"
		ElseIf TRB->C7_QUJE <> 0 .And. TRB->C7_QUJE < TRB->C7_QUANT
			cStatus := "Parc. Atendido"
		ElseIf TRB->C7_QUJE >= TRB->C7_QUANT
			cStatus := "Ped. Atendido"
		ElseIf TRB->C7_QTDACLA > 0
			cStatus := "Ped Pre-Nota"
		ElseIf TRB->C7_QUJE==0 .And. TRB->C7_QTDACLA==0 .AND. TRB->C7_XSTATUS == '1'
			cStatus := "Rec. Fornec"
		ElseIf TRB->C7_QUJE==0 .And. TRB->C7_QTDACLA==0 .AND. TRB->C7_XSTATUS == '2'
			cStatus := "Confir. Fornec"
		EndIf       
		
		//Verifica tipo de contrato
	 /*	If TRB->C1_XTIPOSC ==  "1"
			cTpDoc := "Materiais"
		ElseIf C1_XTIPOSC == "2"
			cTpDoc := "Servicos"	
		ElseIf C1_XTIPOSC == "3"
			cTpDoc := "Adit Contrat"	
		ElseIf C1_XTIPOSC == "4"
			cTpDoc := "Almoxarifado"	
		Else
			cTpDoc := Space(13)	
		EndIf */
		
		@li, aColu[01] PSAY TRB->C7_NUM
		@li, aColu[02] PSAY TRB->C7_ITEM
		@li, aColu[03] PSAY SubStr(TRB->C7_PRODUTO,1,15)
		@li, aColu[04] PSAY SubStr(TRB->C7_DESCRI,1,20)
		@li, aColu[05] PSAY TRB->C7_UM
		@li, aColu[06] PSAY TRB->C7_QUANT Picture '@E 999,999.99'
		@li, aColu[07] PSAY TRB->C7_PRECO Picture '@E 999,999.99'
		@li, aColu[08] PSAY TRB->C7_TOTAL Picture '@E 9,999,999.99'
		@li, aColu[09] PSAY STOD(TRB->C7_DATPRF)
		@li, aColu[10] PSAY TRB->C7_NUMSC
		@li, aColu[11] PSAY cStatus
		@li, aColu[12] PSAY Posicione("COL",1,xFilial("COL")+TRB->C1_XTIPOSC,"COL->COL_DESC") //cTpDoc
		
		li++
		
		cStatus := ""
		//cTpDoc  := ""
	
		DbSelectArea("TRB")
		DbSkip()                      
		
	EndDo
	          
	If aReturn[5] == 1
		Set Printer TO
		dbCommitAll()
		Ourspool(wnrel)
	EndIf
	
	Ms_Flush()
	           
	TRB->(dbCloseArea())
	
Return()         


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºRotina    ³ AjustaSX1º Autor ³ Totvs 			 º Data ³  11/06/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Ajusta as perguntas do SX1                                 º±±
±±º          ³ 								                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ C.N.I.                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function AjustaSX1(cPerg)

	Local aArea := GetArea()
	Local aRegs := {}
	Local i
	 
	aAdd(aRegs,{"01","Pedido de ?"	,""	,"", "mv_ch01", "C", 6, 0, 0,"G", "","SC7" ,""	,,"mv_par01"})
	aAdd(aRegs,{"02","Pedido ate ?"	,""	,"", "mv_ch02", "C", 6, 0, 0,"G", "","SC7" ,""	,,"mv_par02"})
	aAdd(aRegs,{"03","Emissao de ?"	,""	,"", "mv_ch03", "D", 8, 0, 0,"G", "",""	   ,""	,,"mv_par03"})
	aAdd(aRegs,{"04","Emissao ate ?",""	,"", "mv_ch04", "D", 8, 0, 0,"G", "",""	   ,""	,,"mv_par04"})
	aAdd(aRegs,{"05","Tipo Doc ?"	,""	,"", "mv_ch05", "C", 3, 0, 0,"G", "","COD1",""  ,,"mv_par51"})

	dbSelectArea("SX1")
	dbSetOrder(1)
	For i:=1 to Len(aRegs)
		If !dbSeek(cPerg+aRegs[i][1])
			RecLock("SX1",.T.)
			SX1->X1_GRUPO    := cPerg
			SX1->X1_ORDEM    := aRegs[i][01]
			SX1->X1_PERGUNT  := aRegs[i][02]
			SX1->X1_PERSPA   := aRegs[i][03]
			SX1->X1_PERENG   := aRegs[i][04]
			SX1->X1_VARIAVL  := aRegs[i][05]
			SX1->X1_TIPO     := aRegs[i][06]
			SX1->X1_TAMANHO  := aRegs[i][07]
			SX1->X1_DECIMAL  := aRegs[i][08]
			SX1->X1_PRESEL   := aRegs[i][09]
			SX1->X1_GSC      := aRegs[i][10]
			SX1->X1_VALID    := aRegs[i][11]
			SX1->X1_F3       := aRegs[i][12]
			SX1->X1_GRPSXG   := aRegs[i][13]
			SX1->X1_PYME     := aRegs[i][14]
			SX1->X1_VAR01    := aRegs[i][15]
			MsUnlock()
		Endif
	Next 

	RestArea(aArea)
Return