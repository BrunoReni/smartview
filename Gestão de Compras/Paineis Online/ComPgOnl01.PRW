#INCLUDE "Protheus.ch"
#INCLUDE "compgonl01.ch"

Static aViewSLD  := {}
Static aViewPC   := {}
Static aViewAE   := {} 
Static aViewCP   := {}

/*
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪哪勘�
北矲un噮o    矯omPgOnl01� Autor 矨lexandre Inacio Lemes � Data � 27/01/2007 潮�
北媚哪哪哪哪呐哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪哪幢�
北矰escri噮o 矼onta array para Painel de Gestao Tipo 1:                     潮�
北�          砈aldo Disponivel para Aprovacao de processos                  潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砇etorno   � Array = {{cText1,cValor,nColorValor,bClick},...}             潮�
北�          � cTexto1     = Texto da Coluna                       		    潮�
北�          � cValor      = Valor a ser exibido (string)          		    潮�
北�          � nColorValor = Cor do valor no formato RGB (opcional)         潮�
北�          � bClick      = Funcao executada no click do valor (opcional)  潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砋so       � SIGACOM                                                      潮�
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
*/        
Function ComPgOnl01()

Local aStruSCR  := {}
Local aArraySCR := {}
Local aPanel    := {}
Local aAprovador:= {}
Local aPutVar   := {}

Local cAliasSCR := "SCR"
Local cIndSCR	:= ""
Local cQuery    := ""
Local cTipo     := ""
Local cSimbMoeda:= ""

Local nValLibPC := 0
Local nValLibAE := 0
Local nValLibCP := 0
Local nTotLibPC := 0
Local nTotLibAE := 0
Local nTotLibCP := 0
Local nSaldo    := 0
Local nX        := 0
Local cSIMB1	:= GetMv("MV_SIMB1")

Local lQuery    := .F.

dbSelectArea("SCS")
dbSetOrder(2)

dbSelectArea("SAK")
dbSetOrder(2)

dbSelectArea("SCR")
dbSetOrder(1)

lQuery := .T.
cAliasSCR := GetNextAlias()
aStruSCR  := SCR->(dbStruct())
cQuery := "SELECT * "
cQuery += "FROM "+RetSqlName("SCR")+" "
cQuery += "WHERE CR_FILIAL='"+xFilial("SCR")+"' AND "
cQuery += "( CR_STATUS='01' OR CR_STATUS='02' ) AND "
cQuery += "D_E_L_E_T_ = ' ' "
cQuery += "ORDER BY "+SqlOrder(SCR->(IndexKey()))

cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSCR)

For nX := 1 To len(aStruSCR)
	If aStruSCR[nX][2] <> "C"
		TcSetField(cAliasSCR,aStruSCR[nX][1],aStruSCR[nX][2],aStruSCR[nX][3],aStruSCR[nX][4])
	EndIf
Next nX
dbSelectArea(cAliasSCR)

While ( !(cAliasSCR)->(Eof()) .And. (cAliasSCR)->CR_FILIAL == xFilial("SCR") )
	
	If Ascan(aArraySCR,(cAliasSCR)->CR_NUM + (cAliasSCR)->CR_TIPO ) == 0
		
		Aadd(aArraySCR, (cAliasSCR)->CR_NUM + (cAliasSCR)->CR_TIPO )
		
		SAK->(dbSetOrder(2))
		SAK->(MsSeek(xFilial("SAK") + (cAliasSCR)->CR_USER))
		If (cAliasSCR)->CR_TIPO <> "NF"
			If Ascan(aAprovador, SAK->AK_COD ) == 0
				Aadd(aAprovador,SAK->AK_COD)
				aRetSaldo := MaSalAlc((cAliasSCR)->CR_APROV,dDataBase)
				nSaldo 	  := nSaldo + xMoeda(aRetSaldo[1],SAK->AK_MOEDA,1,dDataBase)
				
				If SAK->AK_TIPO == "D"
					cTipo := STR0001 //"Diario"
				ElseIf SAK->AK_TIPO == "S"
					cTipo := STR0002 //"Semanal"
				ElseIf SAK->AK_TIPO == "M"
					cTipo := STR0003 //"Mensal"
				EndIf
				
				If aRetSaldo[1] > 0
					Aadd(aViewSLD,{Substr(SAK->AK_COD,1,6),AllTrim(Substr(SAK->AK_NOME,1,20)),cSIMB1+" "+AllTrim(TransForm(xMoeda(aRetSaldo[1],SAK->AK_MOEDA,1,dDataBase),"@E 9,999,999.99")),Substr(cTipo,1,7) })
				EndIf
			EndIf
		EndIf
		
		if !empty((cAliasSCR)->CR_MOEDA) .and. alltrim((cAliasSCR)->CR_MOEDA) <> "0" 
           	cSimbMoeda := buscamoeda((cAliasSCR)->CR_MOEDA)
		Else
			cSimbMoeda := BuscaMoeda(SAK->AK_MOEDA)
	    endif
		nTxMoedaSCR:= IIF((cAliasSCR)->CR_TXMOEDA > 0,(cAliasSCR)->CR_TXMOEDA,Nil)
		
		If (cAliasSCR)->CR_TIPO == "PC"
			nValLibPC := nValLibPC + xMoeda((cAliasSCR)->CR_TOTAL,(cAliasSCR)->CR_MOEDA,1,(cAliasSCR)->CR_EMISSAO,,nTxMoedaSCR)
			nTotLibPC ++
			
			Aadd(aViewPC,{DtoC((cAliasSCR)->CR_EMISSAO),Substr((cAliasSCR)->CR_NUM,1,6),cSimbMoeda+" "+TransForm((cAliasSCR)->CR_TOTAL,"@E 9,999,999.99"),SAK->AK_NOME })
			
		ElseIf (cAliasSCR)->CR_TIPO == "AE"
			nValLibAE := nValLibAE + xMoeda((cAliasSCR)->CR_TOTAL,(cAliasSCR)->CR_MOEDA,1,(cAliasSCR)->CR_EMISSAO,,nTxMoedaSCR)
			nTotLibAE ++
			
			Aadd(aViewAE,{DtoC((cAliasSCR)->CR_EMISSAO),Substr((cAliasSCR)->CR_NUM,1,6),cSimbMoeda+" "+TransForm((cAliasSCR)->CR_TOTAL,"@E 9,999,999.99"),SAK->AK_NOME })
			
		ElseIf (cAliasSCR)->CR_TIPO == "CP"
			nValLibCP := nValLibCP + xMoeda((cAliasSCR)->CR_TOTAL,(cAliasSCR)->CR_MOEDA,1,(cAliasSCR)->CR_EMISSAO,,nTxMoedaSCR)
			nTotLibCP ++
			
			Aadd(aViewCP,{DtoC((cAliasSCR)->CR_EMISSAO),Substr((cAliasSCR)->CR_NUM,1,6),cSimbMoeda+" "+TransForm((cAliasSCR)->CR_TOTAL,"@E 9,999,999.99"),SAK->AK_NOME })
			
		EndIf
		
	EndIf
	
	(cAliasSCR)->(dbSkip())
	
EndDo

If Empty(aViewSLD)
	aViewSLD := {{"","",""}}
EndIf

If Empty(aViewPC)
	aViewPC := {{"","","",""}}
EndIf

If Empty(aViewAE)
	aViewAE := {{"","","",""}}
EndIf

If Empty(aViewCP)
	aViewCP := {{"","","",""}}
EndIf

//-- Salva as variaveis no server de paineis
aPutVar := { aViewSLD, aViewPC, aViewAE, aViewCP }
PutServerVar("COMPGONL01",aPutVar)

Aadd( aPanel, { STR0004,GetMv("MV_SIMB1")+" "+Transform(nSaldo,"@R 9,999,999.99"),CLR_HBLUE, '{ || COMPView01("SLD") }' } ) //"Saldo dos Aprovadores"
Aadd( aPanel, { Transform(nTotLibPC,"@R 9999")+" "+STR0005,GetMv("MV_SIMB1")+" "+Transform(nValLibPC,"@R 9,999,999.99"),CLR_HRED, '{ || COMPView01("PC") }' } ) //"PCs para Aprovar"
Aadd( aPanel, { Transform(nTotLibAE,"@R 9999")+" "+STR0006,GetMv("MV_SIMB1")+" "+Transform(nValLibAE,"@R 9,999,999.99"),CLR_HRED, '{ || COMPView01("AE") }' } ) //"AEs para Aprovar"
Aadd( aPanel, { Transform(nTotLibCP,"@R 9999")+" "+STR0007,GetMv("MV_SIMB1")+" "+Transform(nValLibCP,"@R 9,999,999.99"),CLR_HRED, '{ || COMPView01("CP") }' } ) //"CPs para Aprovar"

//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
//� Apaga os arquivos de trabalho, cancela os filtros e restabelece as ordens originais.|
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
If lQuery
	dbSelectArea(cAliasSCR)
	dbCloseArea()
Else
	dbSelectArea("SCR")
	RetIndex("SCR")
	dbClearFilter()
	Ferase(cIndSCR+OrdBagExt())
EndIf

Return aPanel

/*
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪哪勘�
北矲un噮o    矯OMPView01� Autor 矨lexandre Inacio Lemes � Data � 27/01/2007 潮�
北媚哪哪哪哪呐哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪哪幢�
北矰escri噮o 矯onsulta os documentos em processo de liberacao na tabela SCR 潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砋so       � ComPanel01                                                   潮�
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
*/
Function COMPView01(cTipo)

Local aHeadView := {}
Local aGetVar   := {}
Local cTitle    := Iif(cTipo == "SLD",STR0008,STR0009 )   //"Saldo dos Aprovadores Envolvidos"###"Consulta dos Documentos aguardando libera玢o"
Local oDialog
Local oBrowse

//-- Restaura as variaveis no server de paineis
aGetVar := GetServerVar("COMPGONL01")
If !Empty(aGetVar)
	aViewSLD := aGetVar[1]
	aViewPC  := aGetVar[2]
	aViewAE  := aGetVar[3]
	aViewCP  := aGetVar[4]
EndIf

If cTipo == "PC"
	aView := aViewPC
	aHeadView := {STR0010,STR0011,STR0012,STR0013}  //"Emissao"###"Pedido"###"Valor"###"Aguardando Aprovador"
ElseIf cTipo == "AE"
	aView := aViewAE
	aHeadView := {STR0010,STR0014,STR0012,STR0013}  //"Emissao"###"Aut.Entrega"###"Valor"###"Aguardando Aprovador"
ElseIf cTipo == "CP"
	aView := aViewCP
	aHeadView := {STR0010,STR0015,STR0012,STR0013}  //"Emissao"###"Contrato"###"Valor"###"Aguardando Aprovador"
ElseIf cTipo == "SLD"
	aView := aViewSLD
	aHeadView := {STR0016,STR0017,"Saldo",STR0018}  //"Aprovador"###"Nome"###"Limite"
EndIf

DEFINE MSDIALOG oDialog FROM 000,000 TO 245,392 TITLE cTitle OF oMainWnd PIXEL

oBrowse:= TWBrowse():New( 000,000,245,392,,aHeadView,,oDialog,,,,,,,,,,,,.F.,,.T.,,.F.,,,)
oBrowse:SetArray(aView)
oBrowse:bLine := { || aView[oBrowse:nAT] }

ACTIVATE MSDIALOG oDialog CENTERED

Return   
  
/*
北谀哪哪哪哪穆哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪哪勘�
北矲un噮o    砨uscamoeda�							    � Data � 26/10/2018 潮�
北媚哪哪哪哪呐哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪哪幢�
北矰escri噮o  Busca moeda utilizada, de acordo com a configurada no parametro  MV 潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砋so       � ComPanel01                                                   潮�
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
*/  

Static function buscamoeda(cMoeda)
  Local cRet
   	cRet:= PadR(GetMv("MV_SIMB"+Alltrim(STR(cMoeda,2,0))),6)
return cRet
