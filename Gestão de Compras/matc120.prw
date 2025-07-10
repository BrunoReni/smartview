#INCLUDE "MATC120.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE 'DBTREE.CH'
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MATC120   ºAutor  ³Fernando J. Siquini º Data ³ 05/01/2004  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Consulta a Pedidos / Producao                              º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MP8                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
FUNCTION MATC120

LOCAL aAlias     := {}

PRIVATE aRotina    := MenuDef()
PRIVATE cCadastro  := STR0003 //'Consulta a Pedidos/Producao' 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ativa tecla F12 para acessar os parametros                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Pergunte('MTC120', .F.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica as perguntas selecionadas                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para parametros                         ³
//³ mv_par01        // Data inicial                              ³
//³ mv_par02        // Data final                                ³
//³ mv_par03        // De  Armazem         ?                     ³
//³ mv_par04        // Ate Armazem         ?                     ³
//³ mv_par05        // Cons Saldo Em/De 3o.?                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
SetKey( VK_F12, {|| Pergunte('MTC120', .T.)})

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Endereca a funcao de BROWSE                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
mBrowse(6, 1, 22, 75, 'SB1')

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Desativa tecla F12                                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Set Key VK_F12	To

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Recupera a Ordem Original do arquivo principal               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea('SB1')
dbSetOrder(1)

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³MC120Con  ³ Autor ³ Fernando J. Siquini   ³ Data ³ 05/01/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Monta a dialog da consulta                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATC120                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function MC120Con()
LOCAL aEnch[17]
LOCAL aSavPerg   := MTC120Per(.T.) // Salva valor das perguntas existentes nesse momento
LOCAL aSVAlias   := {}
Local aTotais    := {}
LOCAL aButtons   := {{'S4WB005N',  {|| MaComView(SB1->B1_COD)}, STR0006}} //'Historico'
LOCAL bChange    := {|| Nil }
LOCAL lFoundSB2  := .F.
LOCAL lFoundSB5  := .F.
LOCAL nSaldoIni  := 0
LOCAL nTop       := oMainWnd:nTop+23
LOCAL nLeft      := oMainWnd:nLeft+5
LOCAL nBottom    := oMainWnd:nBottom-60
LOCAL nRight     := oMainWnd:nRight-10
LOCAL nOldEnch   := 1
LOCAL oTree
LOCAL oDlg
LOCAL oFont
LOCAL oPanel

Pergunte('MTC120', .F.)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica as perguntas selecionadas                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para parametros                         ³
//³ mv_par01        // Data inicial                              ³
//³ mv_par02        // Data final                                ³
//³ mv_par03        // De  Armazem         ?                     ³
//³ mv_par04        // Ate Armazem         ?                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Carrega as variaveis de memoria do SB1               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aAdd(aSVAlias, 'SB1')
RegToMemory('SB1' , .F.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Posiciona para carregar variaveis de memoria do SB2  ³
//³ Executa esse processo para agilizar na visualizacao  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea('SB2')
dbSetOrder(1)
lFoundSB2 := MsSeek(xFilial()+SB1->B1_COD, .F.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Posiciona para carregar variaveis de memoria do SB5  ³
//³ Executa esse processo para agilizar na visualizacao  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea('SB5')
dbSetOrder(1)
lFoundSB5 := MsSeek(xFilial()+SB1->B1_COD, .F.)

DEFINE FONT oFont NAME 'Arial' SIZE 0, -10
DEFINE MSDIALOG oDlg TITLE cCadastro OF oMainWnd PIXEL FROM nTop,nLeft TO nBottom, nRight
oFolder                    := TFolder():New(12,0,{STR0007,STR0031},{},oDlg,,,, .T., .F.,(nRight-nLeft)/2,nBottom-nTop-12,) //'Dados'###'Legenda'
oFolder:aDialogs[1]:oFont  := oDlg:oFont
oPanel                     := TPanel():New(2,160,'',oFolder:aDialogs[1], oDlg:oFont, .T., .T.,, ,(nRight-nLeft)/2-160,((nBottom-nTop)/2)-25,.T.,.T. )
lOneColumn                 := If((nRight-nLeft)/2-178>312,.F.,.T.)
If lFoundSB2
	aAdd(aSVAlias,'SB2')
	RegToMemory('SB2',.F.)
	aEnch[2]:= MsMGet():New('SB2',SB2->(RecNo()),2,,,,,{0,0,((nBottom-nTop)/2)-25,(nRight-nLeft)/2-160},,3,,,,oPanel,,.T.,lOneColumn)
	aEnch[2]:Hide()
EndIf
If lFoundSB5
	AADD(aSVAlias,'SB5')
	RegToMemory('SB5',.F.)
	aEnch[4]:= MsMGet():New('SB5', SB5->(RecNo()),2,,,,,{0,0,((nBottom-nTop)/2)-25,(nRight-nLeft)/2-160},,3,,,,oPanel,,.T.,lOneColumn)
	aEnch[4]:Hide()
EndIf
aEnch[1]      := MsMGet():New('SB1', SB1->(RecNo()),2,,,,,{0,0,((nBottom-nTop)/2)-25,(nRight-nLeft)/2-160},,3,,,,oPanel,,.T.,lOneColumn)
oTree         := dbTree():New(2, 2,((nBottom-nTop)/2)-24,159,oFolder:aDialogs[1],,,.T.)
oTree:bChange := {|| If(Val(SubStr(oTree:GetCargo(),6,12))#0,Eval({||(SubStr(oTree:GetCargo(),3,3))->(MsGoto(Val(SubStr(oTree:GetCargo(),6,12)))),RegToMemory(SubStr(oTree:GetCargo(),3,3),.F.,aScan(aSVAlias,SubStr(oTree:GetCargo(),3,3))==0)}),Nil),MTC120DlgV(@oTree,aSValias,@aEnch,{0,0,((nBottom-nTop)/2)-24,(nRight-nLeft)/2-160},@nOldEnch,@oPanel,aTotais,nSaldoIni),Eval(bChange)}
oTree:SetFont(oFont)
oTree:lShowHint := .F.
MTC120Tree(@oTree, aTotais,@nSaldoIni)
// Informacoes da Legenda
@ 10,08 BITMAP oBmp RESNAME "PMSEDT3" Of oFolder:aDialogs[2] Size 9,9 Pixel NoBorder
@ 10,23 SAY STR0024 Of oFolder:aDialogs[2] Size 100,50 Pixel
@ 20,08 BITMAP oBmp RESNAME "PMSTASK2" Of oFolder:aDialogs[2] Size 9,9 Pixel NoBorder
@ 20,23 SAY STR0023 Of oFolder:aDialogs[2] Size 100,50 Pixel
@ 30,08 BITMAP oBmp RESNAME "PMSDOC" Of oFolder:aDialogs[2] Size 9,9 Pixel NoBorder
@ 30,23 SAY STR0028 Of oFolder:aDialogs[2] Size 100,50 Pixel
@ 40,08 BITMAP oBmp RESNAME "ENGRENAGEM" Of oFolder:aDialogs[2] Size 9,9 Pixel NoBorder
@ 40,23 SAY STR0029 Of oFolder:aDialogs[2] Size 100,50 Pixel
@ 50,08 BITMAP oBmp RESNAME "CLIPS" Of oFolder:aDialogs[2] Size 9,9 Pixel NoBorder
@ 50,23 SAY STR0030 Of oFolder:aDialogs[2] Size 100,50 Pixel
ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||oDlg:End()},{||oDlg:End()},,aButtons)
Release Object oTree
MTC120Per(.F.,aSavPerg) //-- Restaura valor anterior das perguntas

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³MTC120DlgV³ Autor ³Fernando J. Siquini    ³ Data ³ 05-01-2004 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao que mostra as informacoes detalhadas da consulta       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³MATC120                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Mtc120DlgV(oTree, aSVAlias, aEnch, aPos, nOldEnch, oPanel, aTotais, nSaldoIni)

Local aDados     := {}
Local aArea		  := GetArea()
Local cAlias	  := SubStr(oTree:GetCargo(),3,3)
Local nRecView	  := Val(SubStr(oTree:GetCargo(),6,12))
Local nPosAlias  := aScan(aSVAlias,cAlias)
Local nPostotais := Ascan(aTotais,{|x| x[1]== SubStr(oTree:GetCargo(),3,3)})
Local lOneColumn := If(aPos[4]-aPos[2]>312,.F.,.T.)
Local oScroll

If !(nRecView) == 0
	dbSelectArea(cAlias)
	MsGoto(nRecView)
	RegtoMemory(cAlias,.F.)
	oPanel:Hide()
	MsFreeObj(@oPanel, .T.) 
	MsMGet():New(cAlias,(cAlias)->(RecNo()),2,,,,,aPos,,3,,,,oPanel,,.T.,lOneColumn)
	oPanel:Show()
Else
	If nPosTotais > 0
		Do Case
			Case cAlias == 'SB2'
				AADD(aDados,{aTotais[nPosTotais,2],''})
				AADD(aDados,{'',''})
				AADD(aDados,{STR0008, Transform(aTotais[nPosTotais,3],PesqPict('SB2','B2_QATU'   ,14))}) //"Quantidade"  
				AADD(aDados,{STR0009, Transform(aTotais[nPosTotais,4],PesqPict('SB2','B2_QTSEGUM',14))}) //'Quantidade 2a UM' 
				AADD(aDados,{STR0010, Transform((aTotais[nPosTotais,3]-aTotais[nPosTotais,10]),PesqPict('SB2','B2_QATU'   ,14))}) //'Status Disponivel' 
				AADD(aDados,{STR0011, Transform(aTotais[nPosTotais,10],PesqPict('SB2','B2_QATU'   ,14))}) //'Status Indisponivel'
				AADD(aDados,{STR0012,Transform(aTotais[nPosTotais,11],PesqPict('SB2','B2_QATU'   ,14))}) //'Disponivel para movimentacao' 
				AADD(aDados,{STR0013, Transform(aTotais[nPosTotais,5],PesqPict('SB2','B2_VATU1'  ,14))}) //'Valor Moeda 1' 
				AADD(aDados,{STR0014, Transform(aTotais[nPosTotais,6],PesqPict('SB2','B2_VATU2'  ,14))}) //'Valor Moeda 2'  
				AADD(aDados,{STR0015, Transform(aTotais[nPosTotais,7],PesqPict('SB2','B2_VATU3'  ,14))}) //'Valor Moeda 3'  
				AADD(aDados,{STR0016, Transform(aTotais[nPosTotais,8],PesqPict('SB2','B2_VATU4'  ,14))}) //'Valor Moeda 4'  
				AADD(aDados,{STR0017, Transform(aTotais[nPosTotais,9],PesqPict('SB2','B2_VATU5'  ,14))}) //'Valor Moeda 5'  
				C120DISP(aDados,@oScroll,@oPanel,aPos,{{1,CLR_BLUE}})
			Case cAlias == "SC6"
				AADD(aDados,{aTotais[nPosTotais,2],""})
				AADD(aDados,{"",""})
				AADD(aDados,{STR0008,Transform(aTotais[nPosTotais,3],PesqPict("SC6","C6_QTDVEN",14))}) //"Quantidade"
				AADD(aDados,{STR0018,Transform(aTotais[nPosTotais,4],PesqPict("SC6","C6_QTDVEN",14))}) //"Quantidade ja entregue"
				C120DISP(aDados,@oScroll,@oPanel,aPos,{{1,CLR_BLUE}})
			Case cAlias == 'SC2'
				AADD(aDados,{aTotais[nPosTotais,2],""})
				AADD(aDados,{"",""})
				AADD(aDados,{STR0008,Transform(aTotais[nPosTotais,3],PesqPict("SC2","C2_QUANT",14))}) //"Quantidade"
				AADD(aDados,{STR0018,Transform(aTotais[nPosTotais,4],PesqPict("SC2","C2_QUANT",14))}) //"Quantidade ja entregue"
				AADD(aDados,{STR0019,Transform(aTotais[nPosTotais,5],PesqPict("SC2","C2_QUANT",14))}) //"Quantidade perdida"
				C120DISP(aDados,@oScroll,@oPanel,aPos,{{1,CLR_BLUE}})
		EndCase
		aEnch[17] := oScroll
		aEnch[17]:Show()
		nOldEnch  := 17
	Else
		AADD(aDados,{STR0020}) //'Nao existem totais para essa consulta.'  
		AADD(aDados,{''})
		AADD(aDados,{STR0021}) //'Pressione o botao na barra de ferramentas para expandir a consulta.'  
		C120DISP(aDados,@oScroll,@oPanel,aPos,{{1,CLR_RED}})
		aEnch[17] := oScroll
		aEnch[17]:Show()
		nOldEnch := 17
	EndIf
EndIf

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³MTC120Tree³ Autor ³Fernando J. Siquini    ³ Data ³ 11-01-2004 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao que monta o Tree da consulta de produto                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³MATC120                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function MTC120Tree(oTree,aTotais,nSaldoIni)

Local aArea	     := GetArea()
Local aAreaBack  := {}
Local cAliasTop  := ''
Local cNumOp     := ""
Local cItemOP    := ""
Local cCargoOri  := ""
Local nAcho      := 0
Local aOps       :={}

//-- Monta tree na primeira vez
oTree:BeginUpdate()
oTree:Reset()
oTree:EndUpdate()

oTree:BeginUpdate()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica dados cadastrais do produto                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oTree:TreeSeek('')
oTree:AddItem(STR0022+Space(30), '01SB1'+StrZero(SB1->(Recno()),12), 'PMSEDT3', 'PMSEDT3',,,1) //'Dados Cadastrais'  
	
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica saldos em estoque do produto                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea('SB2')
aAreaBack := GetArea()
dbSetOrder(1)
If MsSeek(xFilial()+SB1->B1_COD, .F.)
	oTree:TreeSeek('01SB1'+StrZero(SB1->(Recno()),12))
	oTree:AddItem(STR0023, '02SB2'+StrZero(0,12),'PMSEDT3','PMSEDT3',,,2) //"Saldo Fisico / Financeiro" 
	oTree:TreeSeek('02SB2'+StrZero(0,12))
	AADD(aTotais,{'SB2',STR0024+STR0023,0,0,0,0,0,0,0,0,0}) //"Totais "###"Saldo Fisico / Financeiro"  
	Do While !Eof() .And. B2_FILIAL+B2_COD == xFilial()+SB1->B1_COD
		//-- Efetua Filtragem dos armazens
		If B2_LOCAL < mv_par03 .Or. B2_LOCAL > mv_par04
			dbSkip()
			Loop
		EndIf
		oTree:AddItem(STR0025+B2_LOCAL,'02SB2'+StrZero(SB2->(Recno()),12),'PMSTASK2','PMSTASK2',,,2) //'Armazem '  
		aTotais[Len(aTotais), 03] += B2_QATU    // Quantidade
		aTotais[Len(aTotais), 04] += B2_QTSEGUM // Quantidade 2a UM
		aTotais[Len(aTotais), 05] += B2_VATU1   // Valor atual1
		aTotais[Len(aTotais), 06] += B2_VATU2   // Valor atual2
		aTotais[Len(aTotais), 07] += B2_VATU3   // Valor atual3
		aTotais[Len(aTotais), 08] += B2_VATU4   // Valor atual4
		aTotais[Len(aTotais), 09] += B2_VATU5   // Valor atual5
		If B2_STATUS == '2'
			aTotais[Len(aTotais),10] += B2_QATU  // Quantidade Bloqueada
		EndIf
		aTotais[Len(aTotais),11] += SaldoMov()
		nSaldoIni += SB2->B2_QATU
		If mv_par05 == 1 // Considera Qtde De/Em Terceiros
			nSaldoIni += SB2->B2_QNPT - SB2->B2_QTNP
		EndIf
		dbSkip()
	EndDo
EndIf
RestArea(aAreaBack)
	
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se existem dados de demanda do produto      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea('SB3')
dbSetOrder(1)
If dbSeek(xFilial()+SB1->B1_COD)
	oTree:TreeSeek('01SB1'+StrZero(SB1->(Recno()),12))
	oTree:AddItem(STR0026,'03SB3'+StrZero(SB3->(Recno()),12),'PMSEDT3','PMSEDT3',,,2) //'Demandas'  
EndIf
RestArea(aAreaBack)
	
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se existem dados complementares do produto  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea('SB5')
dbSetOrder(1)
If dbSeek(xFilial()+SB1->B1_COD)
	oTree:TreeSeek('01SB1'+StrZero(SB1->(Recno()),12))
	oTree:AddItem(STR0027,'04SB5'+StrZero(SB5->(Recno()),12),'PMSEDT3','PMSEDT3',,,2) //'Dados Complementares' 
EndIf


// Monta Pedidos de Venda
dbSelectArea("SC6") 
aAreaBack:=GetArea()
lQuery    := .F.
	lQuery:=.T.
	cAliasTop := CriaTrab(NIL,.f.)
	cQuery := "SELECT C6_QTDVEN, C6_FILIAL, C6_PRODUTO, C6_QTDENT, C6_BLQ, C6_LOCAL, C6_TES, C6_NUMOP, C6_ITEMOP,"
	cQuery += "C6_ITEM, C6_NUM, C6_ENTREG, C6_CLI, C6_LOJA, C6_RESERVA, R_E_C_N_O_ C6REC "
	cQuery += "FROM "+RetSqlName("SC6")+" SC6, "
	cQuery += "WHERE SC6.C6_FILIAL='"+xFilial("SC6")+"' AND "
	cQuery += "SC6.C6_PRODUTO='" + SB1->B1_COD + "' AND "
	cQuery += "SC6.C6_QTDENT < SC6.C6_QTDVEN AND "
	cQuery += "SC6.C6_BLQ <> 'R ' AND "
	cQuery += "SC6.C6_LOCAL >= '" +mv_par03+"' AND "
	cQuery += "SC6.C6_LOCAL <= '" +mv_par04+"' AND "
	cQuery += "SC6.D_E_L_E_T_=' ' "
	cQuery += "ORDER BY "+SqlOrder(SC6->(IndexKey(2)))
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTop,.T.,.T.)
	aEval(SC6->(dbStruct()), {|x| If(x[2] <> "C", TcSetField(cAliasTop,x[1],x[2],x[3],x[4]),Nil)})
dbSelectArea(cAliasTop)
If !lQuery
	dbSetOrder(2)
	dbSeek(xFilial()+SB1->B1_COD)
Endif
If !Eof()
	While !Eof() .and. (lQuery .Or. C6_FILIAL+C6_PRODUTO == xFilial()+SB1->B1_COD)
		SF4->(dbSeek(xFilial("SF4")+(cAliasTop)->C6_TES))
		If (!lQuery .And. (C6_QTDENT >= C6_QTDVEN .or. Alltrim((cAliasTop)->C6_BLQ) == "R") .Or. C6_LOCAL < mv_par03 .Or. C6_LOCAL > mv_par04) .or. SF4->F4_ESTOQUE # "S"
			dbSkip()
			Loop
		Endif                
		// Cria totais no pedido de venda
		nAcho := Ascan(aTotais,{|x| x[1]== "SC6"})
		If nAcho == 0
			oTree:TreeSeek("01SB1"+StrZero(SB1->(Recno()),12))
			oTree:AddItem(STR0028,"05SC6"+StrZero(0,12),"PMSEDT3","PMSEDT3",,,2) //"Pedidos de Venda"
			oTree:TreeSeek("05SC6"+StrZero(0,12))
			AADD(aTotais,{"SC6",STR0024+STR0028,0,0}) //"Totais "###"Pedidos de Venda"
			nAcho:=Len(aTotais)
		EndIf
		// Adiciona item no pedido de venda
		oTree:AddItem(C6_NUM+" / "+C6_ITEM,"05SC6"+StrZero(If(lQuery,C6REC,Recno()),12),"PMSDOC","PMSDOC",,,2)
		// Salva posicao original
		cCargoOri:=oTree:GetCargo()
		// Totaliza informacoes do pedido de venda
		aTotais[nAcho,3]+=C6_QTDVEN // Quantidade
		aTotais[nAcho,4]+=C6_QTDENT	// Quantidade ja entregue	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Pesquisa existencia de OPs relacionadas ao pedido de venda   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cNumOp :=IF(!Empty((cAliasTop)->C6_NUMOP),(cAliasTop)->C6_NUMOP,(cAliasTop)->C6_NUM)
		cItemOp:=IF(!Empty((cAliasTop)->C6_ITEMOP),(cAliasTop)->C6_ITEMOP,(cAliasTop)->C6_ITEM)		
		dbSelectArea("SC2")
		dbSetOrder(1)
		dbSeek(xFilial()+cNumOp+cItemOp)
		Do While !Eof() .And. C2_FILIAL+C2_NUM+C2_ITEM == (xFilial()+cNumOp+cItemOp)
			If Empty(C2_PEDIDO) .Or. C2_PEDIDO # (cAliasTop)->C6_NUM
				dbSkip()
				Loop
			EndIf
			If Empty(C2_ITEMPV) .Or. C2_ITEMPV # (cAliasTop)->C6_ITEM
				dbSkip()
				Loop
			EndIf
			nAcho := Ascan(aTotais,{|x| x[1]== "SC2"})
			If nAcho == 0
				oTree:TreeSeek("01SB1"+StrZero(SB1->(Recno()),12))
				oTree:AddItem(STR0029,"07SC2"+StrZero(0,12),"PMSEDT3","PMSEDT3",,,2) //"Ordens de Producao"
				AADD(aTotais,{"SC2",STR0024+STR0029,0,0,0}) //"Totais "###"Ordens de Producao" 
				nAcho:=Len(aTotais)
				// Restura posicao original do tree
				oTree:TreeSeek(cCargoOri)
			EndIf
			// Adiciona OP
			oTree:AddItem(C2_NUM+C2_ITEM+C2_SEQUEN+C2_ITEMGRD,"06SC2"+StrZero(Recno(),12),"CLIPS","CLIPS",,,2)
			// Adiciona em array para nao repetir as OPs
			AADD(aOps,C2_NUM+C2_ITEM+C2_SEQUEN+C2_ITEMGRD)
			// Adiciona totais na OP
			aTotais[nAcho,3]+=C2_QUANT // Quantidade
			aTotais[nAcho,4]+=C2_QUJE  // Quantidade ja entregue
			aTotais[nAcho,5]+=C2_PERDA // Quantidade perdida
			dbSkip()
		EndDo 
		// Restura posicao original do tree
		oTree:TreeSeek(cCargoOri)
		dbSelectArea(cAliasTop)
		dbSkip()
	End                        
	If lQuery
		dbSelectArea(cAliasTop)
		dbCloseArea()
		dbSelectArea("SC6")
	Else	
		RestArea(aAreaBack)
	EndIf
EndIf	

// Monta Ordens de Producao
dbSelectArea("SC2")
aAreaBack:=GetArea()
cAliasTop := "SC2"
lQuery    := .F.
	lQuery:=.T.
	cAliasTop := CriaTrab(NIL,.f.)
	cQuery := "SELECT SC2.* ,R_E_C_N_O_ C2REC "
	cQuery += "FROM "+RetSqlName("SC2")+" SC2, "
	cQuery += "WHERE SC2.C2_FILIAL='"+xFilial("SC2")+"' AND "
	cQuery += "SC2.C2_PRODUTO='" + SB1->B1_COD + "' AND "
	cQuery += "SC2.C2_DATRF = '" + Space(Len(DTOS(SC2->C2_DATRF))) + "' AND "
	cQuery += "SC2.C2_EMISSAO >= '" + DTOS(mv_par01) + "' AND "
	cQuery += "SC2.C2_EMISSAO <= '" + DTOS(mv_par02) + "' AND "
	cQuery += "SC2.C2_LOCAL >= '" +mv_par03+"' AND "
	cQuery += "SC2.C2_LOCAL <= '" +mv_par04+"' AND "
	cQuery += "SC2.D_E_L_E_T_=' ' "
	cQuery += "ORDER BY "+SqlOrder(SC2->(IndexKey(2)))
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTop,.T.,.T.)
	aEval(SC2->(dbStruct()), {|x| If(x[2] <> "C", TcSetField(cAliasTop,x[1],x[2],x[3],x[4]),Nil)})
dbSelectArea(cAliasTop)
If !lQuery
	dbSetOrder(2)
	dbSeek(xFilial()+SB1->B1_COD)
Endif
If !Eof()
	While !Eof() .and. (lQuery .Or. C2_FILIAL+C2_PRODUTO == xFilial()+SB1->B1_COD)
		// Filtra OPs
		If !lQuery .And. (!Empty(C2_DATRF) .Or. C2_LOCAL < mv_par03 .Or. C2_LOCAL > mv_par04)
			dbSkip()
			Loop
		Endif
		// Verifica se a OP ja nao foi apresentada relacionada ao pedido de venda
		nAcho := Ascan(aOps,C2_NUM+C2_ITEM+C2_SEQUEN+C2_ITEMGRD)
		If nAcho # 0
			dbSkip()
			Loop
		EndIf
		nAcho := Ascan(aTotais,{|x| x[1]== "SC2"})
		If nAcho == 0
			oTree:TreeSeek("01SB1"+StrZero(SB1->(Recno()),12))
			oTree:AddItem(STR0029,"07SC2"+StrZero(0,12),"PMSEDT3","PMSEDT3",,,2) //"Ordens de Producao"
			oTree:TreeSeek("07SC2"+StrZero(0,12))
			AADD(aTotais,{"SC2",STR0024+STR0029,0,0,0}) //"Totais "###"Ordens de Producao" 
			nAcho:=Len(aTotais)
		Else
			oTree:TreeSeek("07SC2"+StrZero(0,12)) 
		EndIf
		oTree:AddItem(C2_NUM+C2_ITEM+C2_SEQUEN+C2_ITEMGRD,"07SC2"+StrZero(If(lQuery,C2REC,Recno()),12),"ENGRENAGEM","ENGRENAGEM",,,2)
		aTotais[nAcho,3]+=C2_QUANT // Quantidade
		aTotais[nAcho,4]+=C2_QUJE  // Quantidade ja entregue
		aTotais[nAcho,5]+=C2_PERDA // Quantidade perdida
		dbSkip()
	End
Endif
If lQuery
	dbSelectArea(cAliasTop)
	dbCloseArea()
	dbSelectArea("SC2")
Else
	RestArea(aAreaBack)
EndIf

oTree:EndUpdate()
oTree:Refresh()
RestArea(aArea)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³C120DISP   ³ Autor ³Rodrigo de A. Sartorio³ Data ³ 20-12-2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Monta scroll box com texto dinamico                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Generico                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function C120DISP(aInfo,oScroll,oPanel,aPos,aCoresCols,aCoresLines)
Local nX,ny,nAchou
Local cCor,cCorDefault:=CLR_BLACK
Local nCols   :=1,nSomaCols:=0
Local nLinAtu := 5
Local nColAtu := 45
Local oBmp
DEFAULT aCoresCols:={}
DEFAULT aCoresLines:={}
DEFINE FONT oFont NAME "Arial" SIZE 0,-11 BOLD
If Len(aInfo) > 0
	oScroll:= TScrollBox():New(oPanel,aPos[1],aPos[2],aPos[3],aPos[4])
	@ 0,0 BITMAP oBmp RESNAME "LOGIN" oF oScroll SIZE 45,aPos[3] ADJUST NOBORDER WHEN .F. PIXEL
	nCols:=Len(aInfo[1])
	For nx := 1 to Len(aInfo)
		For ny := 1 to nCols
			If CalcFieldSize("C",Len(aInfo[nx,ny]),0) > nSomaCols
				nSomaCols:=CalcFieldSize("C",Len(aInfo[nx,ny]),0)
			EndIf
		Next ny
	Next
	ny := 1
	For nx := 1 to Len(aInfo)
		nAchou  := Ascan(aCoresLines,{|x| x[1]== nx})
		If nAchou > 0
			cCor:=aCoresLines[nAchou,2]
		Else
			cCor:=cCorDefault
		EndIf
		nAchou  := Ascan(aCoresCols,{|x| x[1]== ny})
		If nAchou > 0
			cCor:=aCoresCols[nAchou,2]
		EndIf
		cTextSay:= "{||' "+STRTRAN(aInfo[nx][ny],"'",'"')+" '}"
		oSay    := TSay():New(nLinAtu,nColAtu,MontaBlock(cTextSay),oScroll,,oFont,,,,.T.,cCor,,,,,,,,)
		nLinAtu += 9
	Next
	nLinAtu := 5
	nColAtu := 45
	For nx := 1 to Len(aInfo)
		For ny := 2 to nCols
			nAchou  := Ascan(aCoresLines,{|x| x[1]== nx})
			If nAchou > 0
				cCor:=aCoresLines[nAchou,2]
			Else
				cCor:=cCorDefault
			EndIf
			nAchou  := Ascan(aCoresCols,{|x| x[1]== ny})
			If nAchou > 0
				cCor:=aCoresCols[nAchou,2]
			EndIf
			cTextSay:= "{||' "+STRTRAN(aInfo[nx][ny],"'",'"')+" '}"
			oSay    := TSay():New(nLinAtu,nColAtu,MontaBlock(cTextSay),oScroll,,oFont,,.T.,,.T.,cCor,,,,,,,,)
			nColAtu += nSomaCols
		Next ny
		nLinAtu += 9
		nColAtu := 45
	Next
EndIf
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³MCTC120Per³ Autor ³ Rodrigo de A. Sartorio³ Data ³ 06/05/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Salva / Restaura as perguntas existentes                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATC120                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function MTC120Per(lSalvaPerg,aPerguntas)
Local ni
DEFAULT lSalvaPerg:=.F.
DEFAULT aPerguntas:=Array(40)
For ni := 1 to Len(aPerguntas)
	If lSalvaPerg
		aPerguntas[ni] := &("mv_par"+StrZero(ni,2))
	Else
		&("mv_par"+StrZero(ni,2)) :=	aPerguntas[ni]
	EndIf
Next ni
Return aPerguntas  

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³MenuDef   ³ Autor ³ Fabio Alves Silva     ³ Data ³09/11/2006³±±
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
±±³          ³		1 - Pesquisa e Posiciona em um Banco de Dados           ³±±
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
PRIVATE aRotina := {{STR0001, 'AxPesqui', 0 , 1, 0, .F.}, ; //'Pesquisar'
					{ STR0002, 'MC120Con', 0, 2, 0, nil}} //'Consulta'	

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ponto de entrada utilizado para inserir novas opcoes no array aRotina  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock("MTC120MNU")
	ExecBlock("MTC120MNU",.F.,.F.)
EndIf
Return(aRotina) 