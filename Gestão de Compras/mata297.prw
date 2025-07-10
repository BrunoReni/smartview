#INCLUDE "MATA297.CH" 
#INCLUDE "PROTHEUS.CH"

#DEFINE DSugest  MV_PAR01
#DEFINE ClasCust MV_PAR02
#DEFINE TipPrc   MV_PAR03
#DEFINE ABCVend  MV_PAR04
#DEFINE Impot    MV_PAR05
#DEFINE GpDE     MV_PAR06
#DEFINE GpAte    MV_PAR07
#DEFINE cProdDe  MV_PAR08
#DEFINE cProdAte MV_PAR09

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Descri‡…o ³ PLANO DE MELHORIA CONTINUA                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ITEM PMC  ³ Responsavel              ³ Data         |BOPS:		      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³      01  ³                          |              |                  ³±±
±±³      02  ³                          ³              |                  ³±±
±±³      03  ³                          ³              |                  ³±±
±±³      04  ³                          ³              |                  ³±±
±±³      05  ³ Alexandre Inacio Lemes   ³ 04/09/2006   |106805            ³±±
±±³      06  ³ Alexandre Inacio Lemes   ³ 04/09/2006   |106805            ³±±
±±³      07  ³                          ³              |                  ³±±
±±³      08  ³                          ³              |                  ³±±
±±³      09  ³                          ³              |                  ³±±
±±³      10  ³                          ³              |                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ Mata297  ³ Autor ³ Valdir F. Silva       ³ Data ³ 10/05/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Rotina p/ Cadastro de Sugestao de Compras                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³Mata297()                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Generico                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Mata297()  

Local aCores := {}

PRIVATE lMSErroAuto := .F.
PRIVATE lMsHelpAuto := .F.
PRIVATE aSvAtela := {{},{}}
PRIVATE aSvAGets := {{},{}}
PRIVATE aTela :={}
PRIVATE aGets :={}
PRIVATE oEnc01
PRIVATE oEnc02
PRIVATE cCadastro := OemToAnsi(STR0001) //"Sugestao de Compras"
PRIVATE aRotina := MenuDef()

PRIVATE cOk  		:= GetMark()
PRIVATE nTipPrc :=SFJ->FJ_TIPPRC
PRIVATE nQtdGer := 1
PRIVATE cSugegs :=""

AADD(aCores,{ 'Empty(FJ_SOLICIT)','ENABLE'})	// Sugestao em aberto
AADD(aCores,{'!Empty(FJ_SOLICIT)','DISABLE'})	// Sugestao efetivada

mBrowse( 6, 1,22,75,"SFJ",,,,,,aCores)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Mt297Inc  ³ Autor ³ Valdir F. Silva       ³ Data ³ 10/05/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Rotina p/ Cadastro de Sugestao de Compras                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³Mt297Inc(Alias,opcao)                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Generico                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function MT297Inc(cAlias,nOpcao)
Local cAnoMes
Local lGrava :=.F.
IF Pergunte("MTA297",.T.)
	
	IF Month(dDataBase)==1
		cAnoMes := StrZero(Year(dDataBase)-1,4)+"12"
	Else
		cAnoMes := StrZero(Year(dDataBase),4)+StrZero(Month(dDataBase)-1,2)
	EndIF
	
	DbSelectArea("SBL")
	DBSetOrder(2)  //SBL Acum.Sugest.Compra	->BL_FILIAL+BL_ANO+BL_MES
	IF MsSeek(xFilial("SBL")+cAnoMes)
		Processa({ || lGrava := MT297IncG(cAlias,nOpcao) })
		IF !lGrava
			Help(" ",1,"MTA297NGER")
		EndIF
	Else
		Help(" ",1,"MTA297INC")
		Return .f.
	EndIF
Endif

Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ MT297IncG³ Autor ³ Valdir F. Silva       ³ Data ³ 10/05/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Inclusao de Sugestao de Compras                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³MT297IncG()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function MT297IncG(cAlias,nOpcao)

Local aSE       :={0,0,0}
Local aConsumo  :={}

Local cAliasAnt := GetArea()
Local cABC      := ""
Local cAnoMes   := ""
Local cImport   := ""
Local cTipCusto := ""
Local cCodigo   := CriaVar("FJ_CODIGO",.T.)
Local cMta297Fil := ""

Local nX        := 0
Local nSaldo    := 0
Local nDemanda  := 0

Local lGrava    := .F.
Local lGerou2   := .F.
Local lProcessa := .T.
Local nSaveSX8  := GetSX8Len()
Local aSFJCpo	:= {}
Local cX3Rel	:= ""
Local nI		:= 0

Private nAtual     := 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ponto de entrada de filtro do usuario                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock("MT297FIL")
	cMta297Fil:=ExecBlock("MT297FIL",.F.,.F.)
EndIf

If nOpcao == 9
	lGerou2 :=.t.
EndIf

IF Month(dDataBase)==1
	cAnoMes := StrZero(Year(dDataBase)-1,4)+"12"
Else
	cAnoMes := StrZero(Year(dDataBase),4)+StrZero(Month(dDataBase)-1,2)
EndIF

IF lGerou2
	Pergunte("MTA297",.f.)
	nQtdGer++
Else
	ProcRegua(SB1->(Reccount()))
EndIF

cImport :=IF(Impot==1,STR0009,STR0010) //"S"###"N"
cTipCusto := Str(ClasCust,1)

If Alltrim(ABCVend) == "*"
	cABC:="AA/AB/AC/BA/BB/BC/CA/CB/CC/"
Else
	For nX:=1 to Len(AllTrim(ABCVend)) Step 2
		cABC:=cABC+Upper(SubStr(ABCVend,nX,2))+"/"
	Next
EndIf

SDF->(DbSetOrder(2))
SM4->(DbSetOrder(1))

nX:=1

DBSelectArea("SB1")
DbSetOrder(1) //SB1 Produtos		    ->B1_FILIAL+B1_COD
DBSelectArea("SBL")
DbSetOrder(2)  //Filial+Ano+Mes
DbSeek(xFilial("SBL")+cAnoMes)

While (SBL->BL_ANO+SBL->BL_MES == cAnoMes .and. xFilial("SBL")==SBL->BL_FILIAL .and. ! SBL->(Eof()))
	
	lProcessa := .T.
	
	//Verifica produto de ate
	IF SBL->BL_PRODUTO < cProdDe .or. SBL->BL_PRODUTO > cProdAte
		lProcessa := .F.
	EndIF
	
	//Verifica Tipo custo 4=Todos
	IF cTipCusto # "4"
		IF  SBL->BL_TIPCUST # cTipCusto
			lProcessa := .F.
		EndIF
	EndIF
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica curva ABC                                                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	IF ! SBL->BL_ABCVEND+SBL->BL_ABCCUST+"/" $ cABC
		lProcessa := .F.
	EndIF
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Procura o Produto se Nao achar vai p/ proximo SBL, Se Achar Verifica.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	SB1->(dbSetOrder(1))
	IF SB1->(MsSeek(XFilial("SB1")+SBL->BL_PRODUTO))
		IF  SB1->B1_FLAGSUG # "1" .or. SB1->B1_CLASSVE # "1"
			lProcessa := .F.
		EndIF
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica se eh produto importado                                     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		IF  SB1->B1_IMPORT <> cImport
			lProcessa := .F.
		EndIF
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica Grupo de e Grupo ate                                        ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		IF  SB1->B1_GRUPO < GpDE .or. SB1->B1_GRUPO > GpAte
			lProcessa := .F.
		EndIF
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Roda o filtro do usuario                                            ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !Empty( cMta297Fil )
			If !( &( cMta297Fil ) )
				lProcessa := .F.
			EndIf
		EndIf
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica SE EXISTE SUGESTAO EM ABERTO                               ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		IF SDF->(MsSeek(xFilial("SDF")+"A"+SBL->BL_PRODUTO))
			lProcessa := .F.
		EndIF
	Else
		lProcessa := .F.
	Endif
	
	If lProcessa		
		Incproc()		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica se a sugestao de compra obteve saldo ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If (nDemanda := A297CalDem(cAnoMes,SB1->B1_COD,DSugest,@aConsumo)) <= 0
			SBL->(DbSkip())
			Loop
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Grava SDF                                                           ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		
		aSE := SaldoEst(SBL->BL_PRODUTO)
		
		nSaldo := aSE[1]+aSE[2]
		
		If ExistBlock("MT297SLD")
			nSaldo := ExecBlock("MT297SLD",.F.,.F.)
		Endif

		IF Round(nDemanda - nSaldo,TamSx3("DF_QTDSUG")[2]) > 0
			RecLock("SDF",.T.)
			SDF->DF_FILIAL  := xFilial("SDF")
			SDF->DF_CODIGO  := cCodigo
			SDF->DF_FLAG    := "A"
			SDF->DF_PRODUTO := SBL->BL_PRODUTO
			SDF->DF_QTDSUGM := nDemanda
			SDF->DF_QTDEST  := aSE[1]
			SDF->DF_QTDPC   := aSE[2]
			SDF->DF_QTDSUG  := SDF->DF_QTDSUGM-(nSaldo)
			IF RetFldProd(SB1->B1_COD,"B1_QE") > 0
				SDF->DF_QTDSUG:=int(SDF->DF_QTDSUG/RetFldProd(SB1->B1_COD,"B1_QE"))*RetFldProd(SB1->B1_COD,"B1_QE")
				SDF->DF_QTDSUG+=RetFldProd(SB1->B1_COD,"B1_QE")
			EndIF
			IF TipPrc == 1
				SDF->DF_VLRTOT  := (SDF->DF_QTDSUG*RetFldProd(SB1->B1_COD,"B1_CUSTD"))
			ElseIF TipPrc == 2
				SDF->DF_VLRTOT  := (SDF->DF_QTDSUG*RetFldProd(SB1->B1_COD,"B1_UPRC"))
			Else
				SDF->DF_VLRTOT  := (SDF->DF_QTDSUG*SB1->B1_PRV1)
			EndIF
			SDF->DF_QTDINF  := 0
			SDF->DF_M03     := (aConsumo[nAtual-1]+aConsumo[nAtual-2]+aConsumo[nAtual-3])/3
			SDF->DF_M12     := (aConsumo[nAtual-1]+aConsumo[nAtual-2]+aConsumo[nAtual-3]+aConsumo[nAtual-4]+;
			aConsumo[nAtual-5]+aConsumo[nAtual-6]+aConsumo[nAtual-7]+aConsumo[nAtual-8]+;
			aConsumo[nAtual-9]+aConsumo[nAtual-10]+aConsumo[nAtual-11]+aConsumo[nAtual-12])/12
			SDF->DF_QE      :=RetFldProd(SB1->B1_COD,"B1_QE")
			SDF->DF_D01     :=aConsumo[nAtual]
			SDF->DF_D02     :=aConsumo[nAtual-1]
			SDF->DF_D03     :=aConsumo[nAtual-2]
			SDF->DF_D04     :=aConsumo[nAtual-3]
			SDF->DF_D05     :=aConsumo[nAtual-4]
			SDF->DF_D06     :=aConsumo[nAtual-5]
			SDF->DF_D07     :=aConsumo[nAtual-6]
			SDF->DF_D08     :=aConsumo[nAtual-7]
			SDF->DF_D09     :=aConsumo[nAtual-8]
			SDF->DF_D10     :=aConsumo[nAtual-9]
			SDF->DF_D11     :=aConsumo[nAtual-10]
			SDF->DF_D12     :=aConsumo[nAtual-11]
			MsUnlock()
			
			If ExistBlock("MT297SDF")
				ExecBlock("MT297SDF",.F.,.F.,{nSaldo})
			Endif
			
			DBSelectArea("SBL")
			lGrava:=.T.
			nX++
		EndIF
	Endif
	
	DbSkip()
	
endDo

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se tem registro no SBL Grava                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
IF  lGrava
	
	While ( GetSX8Len() > nSaveSX8 )
		ConfirmSX8()
	EndDo
	
	DbSelectArea("SFJ")
	IF ! MsSeek(xFilial("SFJ")+cCodigo)
		
		RecLock("SFJ",.T.)
		cSugegs+=IF(cSugegs="",+cCodigo," / "+cCodigo)
		SFJ->FJ_FILIAL  := xFilial("SFJ")
		SFJ->FJ_CODIGO  := cCodigo
		SFJ->FJ_DATREF  := dDataBase
		SFJ->FJ_DIASSUG := DSugest
		SFJ->FJ_CUSUNIT := Str(ClasCust,1)
		SFJ->FJ_TIPPRC  := Str(TipPrc,1)
		SFJ->FJ_IMPORT  := Str(Impot,1)
		SFJ->FJ_CLASSIF := cABC
		SFJ->FJ_ANO     := SubStr(cAnoMes,1,4)
		SFJ->FJ_MES     := SubStr(cAnoMes,5,2)
		SFJ->FJ_GRUPODE := GpDE
		SFJ->FJ_GRUPOAT := GpAte
		SFJ->FJ_SOLICIT:=""

		aSFJCpo	:= {"FJ_TIPGER","FJ_FILENT"}

		For nI := 1 To Len(aSFJCpo)
			SFJ->&(aSFJCpo[nI]) := CriaVar(aSFJCpo[nI],.T.)
		Next nI		
		
		If ExistBlock("MT297SFJ")
			ExecBlock("MT297SFJ",.F.,.F.)
		Endif
		
	EndIF
	
	MsUnlock()
	
Else
	While ( GetSX8Len() > nSaveSX8 )
		RollBackSx8()
	EndDo
EndIF

SDF->(DbSetOrder(1))

IF lGerou2
	MsgInfo(STR0065+Str(nQtdGer,3)+STR0066+" --> "+cSugegs)
	nQtdGer:=1
	cSugegs:=""
EndIF

dbSelectArea("SBL")
RetIndex("SBL")
dbClearFilter()

RestArea(cAliasAnt)
Return(lGrava)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ MT297Vis ³ Autor ³ Valdir F. Silva       ³ Data ³ 10/05/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Visualizacao de Sugestao de Compras                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³MT297Vis()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function MT297Vis()
Local aAltEnChoice := {}//CAMPOS P/ ALTERAR NA ENCHOICE
Local lRet
Local nI := 0
PRIVATE nOpca   := 2
PRIVATE aCols   := {}
PRIVATE aHeader := {}
PRIVATE aAltGetDados := {}// CAMPO P/ ATERAR NO GETDADOS/ITEM
PRIVATE aCpoGetDados := {"DF_FILIAL","DF_CODIGO","DF_DESC","DF_M12","DF_M03","DF_D01","DF_D02","DF_D03","DF_D04",;
"DF_D05","DF_D06","DF_D07","DF_D08","DF_D09","DF_D10","DF_D11","DF_D12","DF_QTDEST","DF_QTDPC","DF_QTDSUGM","DF_PE","DF_FLAG"}//CAMPO P/ NAO MOSTAR NO GETDADOS/ITEM
PRIVATE aCpoEnChoice := {{"FJ_CODIGO","FJ_DATREF","FJ_DIASSUG","FJ_TIPPRC","FJ_CUSUNIT","FJ_IMPORT","FJ_GRUPODE","FJ_GRUPOAT","FJ_CLASSIF",;
"FJ_TIPGER","FJ_FORNECE","FJ_LOJA","FJ_FILENT","FJ_COND"},;
{"DF_DESC","DF_PE","DF_M12","DF_M03","DF_QTDSUGM","DF_QTDEST","DF_QTDPC","DF_QE",;
"DF_D01","DF_D02","DF_D03","DF_D04","DF_D05","DF_D06","DF_D07","DF_D08","DF_D09","DF_D10","DF_D11","DF_D12"}}  //CAMPOS P/ MOSTRA NA ENCHOICE

For nI := 1 to Len(aCpoGetDados)
	aCpoGetDados[nI] := Padr(aCpoGetDados[nI],10)
Next
RegToMemory("SFJ",.F.)
MontaCols()
lRet := Mt297Tela(cCadastro,"SFJ","SDF",aCpoEnChoice,"MTA297Li()","MTA297OK()",2,4,,,,aAltEnchoice,"",aAltGetDados)
Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ MT297Exc ³ Autor ³ Valdir F. Silva       ³ Data ³ 10/05/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Exclusao de Sugestao de Compras                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³MT297Exc()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function MT297Exc()
Local aAltEnChoice := {}//CAMPOS P/ ALTERAR NA ENCHOICE
Local lRet
Local nI := 0
PRIVATE nOpca   := 2
PRIVATE aCols   := {}
PRIVATE aHeader := {}
PRIVATE aAltGetDados := {}// CAMPO P/ ATERAR NO GETDADOS/ITEM
PRIVATE aCpoGetDados := {"DF_FILIAL","DF_CODIGO","DF_DESC","DF_M12","DF_M03","DF_D01","DF_D02","DF_D03",;
"DF_D04","DF_D05","DF_D06","DF_D07","DF_D08","DF_D09","DF_D10","DF_D11","DF_D12",;
"DF_QTDEST","DF_QTDPC","DF_QTDSUGM","DF_PE","DF_FLAG"}//CAMPO P/ NAO MOSTAR NO GETDADOS/ITEM

PRIVATE aCpoEnChoice := {{"FJ_CODIGO","FJ_DATREF","FJ_DIASSUG","FJ_TIPPRC","FJ_CUSUNIT","FJ_IMPORT","FJ_GRUPODE","FJ_GRUPOAT","FJ_CLASSIF",;
"FJ_TIPGER","FJ_FORNECE","FJ_LOJA","FJ_FILENT","FJ_COND"},;
{"DF_DESC","DF_PE","DF_M12","DF_M03","DF_QTDSUGM","DF_QTDEST","DF_QTDPC","DF_QE",;
"DF_D01","DF_D02","DF_D03","DF_D04","DF_D05","DF_D06","DF_D07","DF_D08","DF_D09","DF_D10","DF_D11","DF_D12"}}  //CAMPOS P/ MOSTRA NA ENCHOICE

For nI := 1 to Len(aCpoGetDados)
	aCpoGetDados[nI] := Padr(aCpoGetDados[nI],10)
Next
IF ! Empty(SFJ->FJ_SOLICIT)
	Help(" ",1,"MTA297EXC")
Else
	RegToMemory("SFJ",.F.)
	MontaCols()
	lRet:=Mt297Tela(cCadastro,"SFJ","SDF",aCpoEnChoice,,"MTA297OK()",5,4,,,,aAltEnchoice,"",aAltGetDados)
	IF lRet
		SDF->(MsSeek(xFilial("SDF")+SFJ->FJ_CODIGO))
		While SDF->DF_CODIGO==SFJ->FJ_CODIGO .and. SDF->DF_FILIAL==xFilial("SDF") .and. ! SDF->(Eof())
			SDF->(RecLock("SDF",.F.))
			SDF->(DbDelete())
			SDF->(MsUnlock())
			SDF->(DbSkip())
		EndDo
		SFJ->(RecLock("SFJ",.F.))
		SFJ->(DbDelete())
		SFJ->(MsUnlock())
	EndIF
EndIF
Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ MT297Alt ³ Autor ³ Valdir F. Silva       ³ Data ³ 10/05/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Alteracao de Sugestao de Compras                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³MT297Alt()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function MT297Alt()

Local aAltEnChoice := {"FJ_TIPPRC","FJ_TIPGER","FJ_FORNECE","FJ_LOJA","FJ_FILENT","FJ_COND"}//CAMPOS P/ ALTERAR NA ENCHOICE
Local lRet
Local nI

PRIVATE nOpca   := 4
PRIVATE aCols   := {}
PRIVATE aHeader := {}
PRIVATE aAltGetDados := {"DF_QTDINF"}// CAMPO P/ ATERAR NO GETDADOS/ITEM
PRIVATE aCpoGetDados := {"DF_FILIAL","DF_CODIGO","DF_DESC","DF_M12","DF_M03","DF_D01","DF_D02","DF_D03",;
"DF_D04","DF_D05","DF_D06","DF_D07","DF_D08","DF_D09","DF_D10","DF_D11","DF_D12",;
"DF_QTDEST","DF_QTDPC","DF_QTDSUGM","DF_PE","DF_FLAG"}//CAMPO P/ NAO MOSTAR NO GETDADOS/ITEM
PRIVATE aCpoEnChoice := {{"FJ_CODIGO","FJ_DATREF","FJ_DIASSUG","FJ_TIPPRC","FJ_CUSUNIT","FJ_IMPORT","FJ_GRUPODE","FJ_GRUPOAT","FJ_CLASSIF",;
"FJ_TIPGER","FJ_FORNECE","FJ_LOJA","FJ_FILENT","FJ_COND"},;
{"DF_DESC","DF_PE","DF_M12","DF_M03","DF_QTDSUGM","DF_QTDEST","DF_QTDPC","DF_QE",;
"DF_D01","DF_D02","DF_D03","DF_D04","DF_D05","DF_D06","DF_D07","DF_D08","DF_D09","DF_D10","DF_D11","DF_D12"}}  //CAMPOS P/ MOSTRA NA ENCHOICE

For nI := 1 to Len(aCpoGetDados)
	aCpoGetDados[nI] := Padr(aCpoGetDados[nI],10)
Next
IF Empty(SFJ->FJ_SOLICIT)
	nTipPrc := SFJ->FJ_TIPPRC
	RegToMemory("SFJ",.F.)
	MontaCols()
	lRet := Mt297Tela(cCadastro,"SFJ","SDF",aCpoEnChoice,"MTA297Li()","MTA297OK()",4,4,,,,aAltEnchoice,"",aAltGetDados)
Else
	Help(" ",1,"MTA297GER")
EndIF
Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ MT297Ger ³ Autor ³ Valdir F. Silva       ³ Data ³ 10/05/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Geracao de Solicitacao/Pedido de Compras                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³MT297Ger()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Mata297                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function MT297Ger(nViaTrans,cCodTrans,nPagto48h,cPedFab,cTipPed)
Local cAliasAnt:=GetArea()
Local nCont    :=1
Local aCab     :={}
Local aItem    :={}
Local aCabItem :={}
Local cScAnt
Local cItem    := StrZero(0,Len(SC1->C1_ITEM))
Local cNumero
Local nSaveSX8  := GetSX8Len()
Local aSaveGets := {,}

Local aTamSX3:=TamSX3("C1_SOLICIT")
Local nTamUser:=IIF(aTamSX3[1]<=15,aTamSX3[1],15)

IF ! Empty(SFJ->FJ_SOLICIT)
	Help(" ",1,"MTA297GER")
	Return
EndIF

IF M->FJ_TIPGER=="1"
	cNumero  :=CriaVar("C1_NUM",.T.)
	SC1->(DbSetOrder(1))
	IF !(SC1->(MsSeek(xFilial("SC1")+cNumero)))
		cScAnt := NextNumero("SC1",1,"C1_NUM",.F.,cNumero)
		IF  cScAnt # cNumero
			cNumero := cScAnt
		EndIF
	EndIF
	
	aCab := {{"C1_NUM"		, cNumero  ,Nil},;
	{"C1_EMISSAO"	,dDataBase ,Nil},;
	{"C1_SOLICIT"	,Substr(cUsuario,7,nTamUser) }}
	
	SDF->(MsSeek(xFilial("SDF")+SFJ->FJ_CODIGO))
	While (SDF->DF_CODIGO == SFJ->FJ_CODIGO) .and. xFilial("SDF")==SDF->DF_FILIAL .and. ! SDF->(Eof())
		SB1->(DbSetOrder(1))
		SB1->(MsSeek(xFilial("SB1")+SDF->DF_PRODUTO))
		
		cItem := Soma1(cItem,Len(SC1->C1_ITEM))
		
		AADD(aItem,{{"C1_ITEM"   ,cItem ,Nil },;
		{"C1_PRODUTO" ,SDF->DF_PRODUTO  ,Nil },;
		{"C1_UM" ,SB1->B1_UM ,Nil },;
		{"C1_QUANT"   ,IF(SDF->DF_QTDINF > 0,SDF->DF_QTDINF,SDF->DF_QTDSUG),Nil },;
		{"C1_FORNECE" ,SB1->B1_PROC,Nil }})
		nCont++
		SDF->(DbSkip())
	EndDo
	lMsErroAuto := .f.
	
	If ExistBlock("MT297ASC")
		aCabItem:= ExecBlock("MT297ASC",.F.,.F.,{aCab,aItem})
		aCab	:= aCabItem[1]
		aItem	:= aCabItem[2]
		aCabItem:= {}
	EndIf

	aSaveGets := {aClone(aHeader),aClone(aCols)}
	aHeader := Nil
	aCols 	:= Nil
	
	MSExecAuto({|x,y| MATA110(x,y)},aCab,aItem)

	aHeader := aClone(aSaveGets[1])
	aCols   := aClone(aSaveGets[2])
	
	IF ! lMSErroAuto
		While ( GetSX8Len() > nSaveSX8 )
			ConfirmSX8()
		EndDo
		RecLock("SFJ",.F.)
		SFJ->FJ_SOLICIT:=cNumero
		SFJ->FJ_TIPGER :=M->FJ_TIPGER
		SFJ->(MsUnlock())
		SDF->(MsSeek(xFilial("SDF")+SFJ->FJ_CODIGO))
		While (SDF->DF_CODIGO == SFJ->FJ_CODIGO) .and. xFilial("SDF")==SDF->DF_FILIAL .and. ! SDF->(Eof())
			RecLock("SDF",.F.)
			SDF->DF_FLAG    := "F"
			SDF->(MsUnlock())
			SDF->(DbSkip())
		EndDo
	Else
		Help(" ",1,"MTA297GER1")
		While ( GetSX8Len() > nSaveSX8 )
			RollBackSx8()
		EndDo
		DisarmTransaction()
		Break
	EndIF
ElseIF M->FJ_TIPGER=="2"
	If Empty(M->FJ_FORNECE) .or. Empty(M->FJ_LOJA) .or. Empty(M->FJ_COND)
		Help(" ",1,"MTA297GER2")
		Return
	EndIF
	cNumero  :=CriaVar("C7_NUM",.T.)
	SA2->(MsSeek(xFilial("SA2")+M->FJ_FORNECE+M->FJ_LOJA))
	aCab:={{"C7_NUM"       ,cNumero  	     ,Nil},; // Numero do Pedido
	{"C7_EMISSAO" ,dDataBase  	     ,Nil},; // Data de Emissao
	{"C7_FORNECE" ,M->FJ_FORNECE    ,Nil},; // Fornecedor
	{"C7_LOJA"    ,M->FJ_LOJA       ,Nil},; // Loja do Fornecedor
	{"C7_COND"    ,M->FJ_COND	     ,Nil},; // Condicao de pagamento
	{"C7_CONTATO" ,"               ",Nil},; // Contato
	{"C7_FILENT"  ,M->FJ_FILENT  ,Nil}} // Filial Entrega
	
	SDF->(MsSeek(xFilial("SDF")+SFJ->FJ_CODIGO))
	cCodMar:=Traz_Marca(SDF->DF_PRODUTO)
	While (SDF->DF_CODIGO == SFJ->FJ_CODIGO) .and. xFilial("SDF")==SDF->DF_FILIAL .and. ! SDF->(Eof())
		SB1->(DbSetOrder(1))
		SB1->(MsSeek(xFilial("SB1")+SDF->DF_PRODUTO))
		
		cItem := Soma1(cItem,Len(SC7->C7_ITEM))
		
		aadd(aItem,{{"C7_ITEM"     ,cItem           ,Nil},; //Numero do Item
		{"C7_PRODUTO",SDF->DF_PRODUTO ,Nil},; //Codigo do Produto
		{"C7_UM"     ,SB1->B1_UM ,Nil},; //Unidade de Medida
		{"C7_QUANT"  ,IF(SDF->DF_QTDINF > 0,SDF->DF_QTDINF,SDF->DF_QTDSUG),Nil},; //Quantidade
		{"C7_PRECO"  ,(SDF->DF_VLRTOT/SDF->DF_QTDSUG),Nil},; //Preco
		{"C7_DATPRF" ,dDataBase		 ,Nil},; //Data De Entrega
		{"C7_FLUXO"  ,"S"			 	 ,Nil},; //Fluxo de Caixa (S/N)
		{"C7_LOCAL"  ,RetFldProd(SB1->B1_COD,"B1_LOCPAD")	 ,Nil}}) //Localizacao
		
		nCont++
		SDF->(DbSkip())
	EndDo
	lMsErroAuto := .f.
	
	If ExistBlock("MT297APC")
		aCabItem:= ExecBlock("MT297APC",.F.,.F.,{aCab,aItem})
		aCab	:= aCabItem[1]
		aItem	:= aCabItem[2]
		aCabItem:={}
	EndIf
	
	MSExecAuto({|v,x,y,z| MATA120(v,x,y,z)},1,aCab,aItem,3)
	IF ! lMSErroAuto
		While ( GetSX8Len() > nSaveSX8 )
			ConfirmSX8()
		EndDo
		RecLock("SFJ",.F.)
		SFJ->FJ_SOLICIT:=cNumero
		SFJ->FJ_FORNECE:=M->FJ_FORNECE
		SFJ->FJ_LOJA   :=M->FJ_LOJA
		SFJ->FJ_TIPGER :=M->FJ_TIPGER
		SFJ->FJ_FILENT :=M->FJ_FILENT
		SFJ->FJ_COND   :=M->FJ_COND
		SFJ->(MsUnlock())
		SDF->(MsSeek(xFilial("SDF")+SFJ->FJ_CODIGO))
		While (SDF->DF_CODIGO == SFJ->FJ_CODIGO) .and. xFilial("SDF")==SDF->DF_FILIAL .and. ! SDF->(Eof())
			RecLock("SDF",.F.)
			SDF->DF_FLAG := "F"
			SDF->(MsUnlock())
			SDF->(DbSkip())
		EndDo
		//Gravar Pedido da MIL aqui
		If GetMV("MV_VEICULO") == "S"
			If !("VEI"$cFopened)
				ChkFile("VEI",.F.)
			EndIf
			RecLock("VEI",.T.)
			VEI->VEI_FILIAL :=xFilial("VEI")
			VEI->VEI_CODMAR :=cCodMar
			VEI->VEI_NUM    :=cNumero
			VEI->VEI_PEDFAB :=cPedFab
			VEI->VEI_TIPPED :=cTipPed
			VEI->VEI_VIATRA :=Str(nViaTrans,1)
			VEI->VEI_TRANSP :=cCodTrans
			VEI->VEI_PGT48H :=Str(nPagto48h,1)
			VEI->VEI_DATSC7 :=dDataBase
			VEI->VEI_HORSC7 :=Val(Substr(Time(),1,2)+Substr(Time(),4,2))
			VEI->(MsUnlock())
		EndIF
	Else
		Help(" ",1,"MTA297GER1")
		While ( GetSX8Len() > nSaveSX8 )
			RollBackSx8()
		EndDo
		DisarmTransaction()
		Break
	EndIF
EndIF
RestArea(cAliasAnt)
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ MT297Can ³ Autor ³ Valdir F. Silva       ³ Data ³ 10/05/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Cancelamento de Solicitacao/Pedido de Compras               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³MT297Can()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Mata297                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function MT297Can()
Local aCpoEnChoice := {{"FJ_CODIGO","FJ_DATREF","FJ_DIASSUG","FJ_TIPPRC","FJ_CUSUNIT","FJ_IMPORT","FJ_GRUPODE",;
"FJ_GRUPOAT","FJ_CLASSIF","FJ_TIPGER","FJ_FORNECE","FJ_LOJA","FJ_FILENT","FJ_COND"},;
{"DF_DESC","DF_PE","DF_M12","DF_M03","DF_QTDSUGM","DF_QTDEST","DF_QTDPC","DF_QE",;
"DF_D01","DF_D02","DF_D03","DF_D04","DF_D05","DF_D06","DF_D07","DF_D08","DF_D09","DF_D10","DF_D11","DF_D12"}}  //CAMPOS P/ MOSTRA NA ENCHOICE

Local aAltEnChoice := {}//CAMPOS P/ ALTERAR NA ENCHOICE
Local lRet
Local aCab      :={}
Local aItem     :={}
Local nI        := 0
PRIVATE nOpca   := 5
PRIVATE aCols   := {}
PRIVATE aHeader := {}
PRIVATE aAltGetDados := {}// CAMPO P/ ATERAR NO GETDADOS/ITEM
PRIVATE aCpoGetDados := {"DF_FILIAL","DF_CODIGO","DF_DESC","DF_M12","DF_M03","DF_D01","DF_D02","DF_D03","DF_D04","DF_D05","DF_D06","DF_D07","DF_D08","DF_D09","DF_D10","DF_D11","DF_D12","DF_QTDEST","DF_QTDPC","DF_QTDSUGM","DF_PE","DF_FLAG"}//CAMPO P/ NAO MOSTAR NO GETDADOS/ITEM
For nI := 1 to Len(aCpoGetDados)
	aCpoGetDados[nI] := Padr(aCpoGetDados[nI],10)
Next
IF Empty(SFJ->FJ_SOLICIT)
	Help(" ",1,"MTA297CAN")
Else
	RegToMemory("SFJ",.F.)
	MontaCols()
	lRet:=Mt297Tela(cCadastro,"SFJ","SDF",aCpoEnChoice,,"MTA297OK()",5,4,,,,aAltEnchoice,"",aAltGetDados)
	lMshelpAuto := .t.
	Begin Transaction
	IF lRet .and. M->FJ_TIPGER=="1" //Cancela Solicitacao de Compra
		AADD(aCab ,{"C1_NUM"	,SFJ->FJ_SOLICIT ,Nil})
		AADD(aItem,{{"C1_NUM"	,SFJ->FJ_SOLICIT ,Nil}})
		lMsErroAuto := .f.
		MSExecAuto({|x,y,z| MATA110(x,y,z)},aCab,aItem,5)
	ElseIF lRet .and. M->FJ_TIPGER=="2" //Cancela Pedido de Compra
		AADD(aCab ,{"C7_NUM"	,SFJ->FJ_SOLICIT ,Nil})
		AADD(aItem,{{"C7_NUM"	,SFJ->FJ_SOLICIT ,Nil}})
		lMsErroAuto := .f.
		MSExecAuto({|v,x,y,z| MATA120(v,x,y,z)},1,aCab,aItem,5)
	EndIF
	IF ! lMSErroAuto
        If lRet  
			RecLock("SFJ",.F.)
			SFJ->FJ_SOLICIT:=""
			SFJ->FJ_FORNECE:=""
			SFJ->FJ_LOJA   :=""
			SFJ->FJ_FILENT :=""
			SFJ->FJ_TIPGER :=""
			SFJ->FJ_COND   :=""
			MsUnlock()
			SDF->(MsSeek(xFilial("SDF")+SFJ->FJ_CODIGO))
			While (SDF->DF_CODIGO == SFJ->FJ_CODIGO) .and. xFilial("SDF")==SDF->DF_FILIAL .and. ! SDF->(Eof())
				RecLock("SDF",.F.)
				SDF->DF_FLAG    := "A"
				SDF->(MsUnlock())
				SDF->(DbSkip())
			EndDo	
        EndIf  
	Else
		Help(" ",1,"MTA297CAN1")
		DisarmTransaction()
		Break
	EndIF
	End Transaction
	IF lMsErroAuto
		MostraErro()
	EndIF
	lMsErroAuto := .f.
	lMsHelpAuto := .f.
EndIF
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ MT297Imp ³ Autor ³ Valdir F. Silva       ³ Data ³ 10/05/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Impressao de Sugestao de Compras                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³Mt297Imp()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function MT297Imp()
Local cAliasAnt := GetArea()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local aOrd := {}
Local cDesc1       := STR0012 //"Este programa tem como objetivo imprimir relatorio "
Local cDesc2       := STR0013 //"de acordo com os parametros informados pelo usuario."
Local cDesc3       := ""
Local nLin         := 220
Local Cabec1       := ""
Local Cabec2       := ""

Private li         := 0
Private Tamanho   := "G"
Private At_Prg     := "MATA297" // Coloque aqui o nome do programa para impressao no cabecalho
Private nTipo      := 15
Private aReturn    := {STR0014, 1, STR0015, 2, 2, 1, "", 1} //"Zebrado"###"Administracao"
Private nLastKey   := 0
Private Titulo     := STR0001 //"Sugestao de Compras"
Private CONTFL     := 01
Private m_pag      := 01
Private wnrel      := "SugComp" // Coloque aqui o nome do arquivo usado para impressao em disco
Private cString    := "SDF"
dbSelectArea("SDF")
dbSetOrder(1)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta a interface padrao com o usuario...                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

wnrel := SetPrint(cString,At_Prg,"",@titulo,cDesc1,cDesc2,cDesc3,.F.,aOrd,.T.,Tamanho,,.T.)

IF nLastKey == 27
	Return
EndIF

SetDefault(aReturn,cString)

IF nLastKey == 27
	Return
EndIF
nTipo := IF(aReturn[4]==1,15,18)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Processamento. RPTSTATUS monta janela com a regua de processamento. ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
RptStatus({|| M297ImpR(Cabec1,Cabec2,Titulo,nLin) },Titulo)

RestArea(cAliasAnt)
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ M297ImpR ³ Autor ³ Valdir F. Silva       ³ Data ³ 10/05/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Impressao de Sugestao de Compras                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³M297ImpR(Cabec1,Cabec2,Titulo,nLin)                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function M297ImpR(Cabec1,Cabec2,Titulo,nLin)
Local cText := ""
Local nCont := 0
Local nTot  := 0
Local nValor:= 0

dbSelectArea("SDF")
dbSetOrder(1)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ SETREGUA -> Indica quantos registros serao processados para a regua ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
SetRegua(RecCount())

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta o cabecalho                                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
AvalImp()

nCabec0 := 4
cCabec1 := STR0016 + SFJ->FJ_CODIGO + STR0017 + DtoC(SFJ->FJ_DATREF) + STR0018 + Str(SFJ->FJ_DIASSUG,2) //"Numero : "###"     Referencia : "###"     Sugestao p/ "
cCabec1 := cCabec1 + STR0021 //"     Tipo de Preco : "
cCabec1 := cCabec1 + IIF(SFJ->FJ_TIPPRC="1",STR0022,IIF(SFJ->FJ_TIPPRC="2",STR0023,STR0024)) //"Custo Medio"###"Reposicao"###"Preco de Venda"
cCabec1 := cCabec1 + STR0025 + IIF(SFJ->FJ_CUSUNIT="1",STR0026,IIF(SFJ->FJ_CUSUNIT="2",STR0027,IIF(SFJ->FJ_CUSUNIT="3",STR0028,STR0064))) //"     Custo Unitario : "###"Alto"###"Medio"###"Baixo"## Todos
cCabec1 := cCabec1 + STR0029 + IF(SFJ->FJ_IMPORT="1",STR0030,STR0031)+STR0032+SFJ->FJ_CLASSIF+If(!Empty(SFJ->FJ_SOLICIT),If(SFJ->FJ_TIPGER == "1",STR0072,STR0073),"")+SFJ->FJ_SOLICIT   //"     Importado : "###"Sim"###"Nao"###"     ClassIFicacao : " //"  N. Solicitacao: "###"  N. Pedido: "
cCabec2 := __PrtThinLine()
cCabec3 := Space(80) + STR0033 + STR0034+STR0035+STR0036+STR0037+STR0038+STR0039 //"Ultima                      "###"Media   "###"Media    "###"Media       "###"A      "###"Qtd. "###"------------------------------- Demanda -------------------------------"
cCabec4 := STR0040 + STR0041 + STR0042 + STR0043 + STR0044 + STR0045 + STR0046 + STR0047 + STR0048+STR0049 + STR0050 + STR0051 + STR0052 //"Gir/Fin "###"Codigo               "###"Descricao                   "###"G.D Sugestao  "###"Pedido   "###"Compra       "###"Preco Total "###"12 Meses "###"3 Meses "###"p/ Calc. "###"Disp. "###"Receb. "###"Emb. "
//         <<A/A>>     000000000000000000000   XXXXXXXXXXXXXXXXXXXXXXXXXX   999999999999     9999999     99/99/99      999,999,999.99    99999999    99999999   99999999
For nCont:=1 to 12
	cCabec4:=cCabec4 + StrZero(Month(CToD("15/"+SFJ->FJ_MES+"/"+SFJ->FJ_ANO,"dd/mm/yy")-365+(nCont*30)),2)+"/"
	cCabec4:=cCabec4 + SubStr(StrZero(Year(CToD("15/"+SFJ->FJ_MES+"/"+SFJ->FJ_ANO,"dd/mm/yy")-365+(nCont*30)),4),3,2)+Space(1)
Next

SDF->(DbSetOrder(1))
SDF->(MsSeek(xFilial("SDF")+SFJ->FJ_CODIGO))

While SDF->DF_FILIAL==xFilial("SDF") .and. SDF->DF_CODIGO == SFJ->FJ_CODIGO .and. !EOF()
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Localiza o SBL correspondente                                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	SBL->(dbSetOrder(1))
	SBL->(MsSeek(xFilial("SBL")+SDF->DF_PRODUTO+SFJ->FJ_ANO+SFJ->FJ_MES))
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Localiza o produto                                                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	SB1->(dbSetOrder(1))
	SB1->(MsSeek(xFilial("SB1")+SDF->DF_PRODUTO))
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta dados a serem impressos                                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cText := "<<"  + SBL->BL_ABCVEND+"/"+SBL->BL_ABCCUST+">> "       //Giro / Finaceiro
	cText := cText + SDF->DF_PRODUTO+Space(6)+SubStr(SB1->B1_DESC,1,28)
	cText := cText + Transform(SDF->DF_QTDSUG,"999999999999")+" >"+Transform(SDF->DF_QTDINF,"999999")+"< "
	cTExt:=cText+DToC(RetFldProd(SB1->B1_COD,"B1_UCOM"))+Space(2)
	cText := cText + Transform(SDF->DF_VLRTOT,"@E 9999,999,999.99")+Transform(SDF->DF_M12,"999999999")
	cText := cText + Transform(SDF->DF_M03,"99999999")+Transform(SDF->DF_QTDSUGM,"999999999")
	cText := cText + Transform(SDF->DF_QTDEST,"999999")+Transform(SDF->DF_QTDPC,"9999999")+Transform(SDF->DF_QE,"99999")
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Demanda dos ultimos 12 meses                                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cText := cText + IF(SDF->DF_D12 >0,Transform(SDF->DF_D12,"999999"),"     -")+IF(SDF->DF_D11 >0,Transform(SDF->DF_D11,"999999"),"     -")
	cText := cText + IF(SDF->DF_D10 >0,Transform(SDF->DF_D10,"999999"),"     -")+IF(SDF->DF_D09 >0,Transform(SDF->DF_D09,"999999"),"     -")
	cText := cText + IF(SDF->DF_D08 >0,Transform(SDF->DF_D08,"999999"),"     -")+IF(SDF->DF_D07 >0,Transform(SDF->DF_D07,"999999"),"     -")
	cText := cText + IF(SDF->DF_D06 >0,Transform(SDF->DF_D06,"999999"),"     -")+IF(SDF->DF_D05 >0,Transform(SDF->DF_D05,"999999"),"     -")
	cText := cText + IF(SDF->DF_D04 >0,Transform(SDF->DF_D04,"999999"),"     -")+IF(SDF->DF_D03 >0,Transform(SDF->DF_D03,"999999"),"     -")
	cText := cText + IF(SDF->DF_D02 >0,Transform(SDF->DF_D02,"999999"),"     -")+IF(SDF->DF_D01 >0,Transform(SDF->DF_D01,"999999"),"     -")
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Imprime os dados                                                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Impr(cText,"C")
	
	nValor += SDF->DF_VLRTOT
	nTot   += SDF->DF_QTDSUG
	SDF->(dbSkip()) // Avanca o ponteiro do registro no arquivo
EndDo

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Imprime totais                                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Impr(Space(61)+"--------"+Space(19)+"----------------","C")
Impr(Space(61)+Transform(nTot,"99999999")+Space(21)+Transform(nValor,"@E 999,999,999.99"),"C")
Impr("","F")
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Finaliza a execucao do relatorio...                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
SET DEVICE TO SCREEN
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se impressao em disco, chama o gerenciador de impressao...          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
IF aReturn[5]==1
	dbCommitAll()
	SET PRINTER TO
	OurSpool(wnrel)
EndIF

MS_FLUSH()

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³Impr		³ Autor ³           			³ Data ³ 16.02.95 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Controle de Linhas de Impressao e Cabecalho			      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³Generico                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function IMPR(Detalhe,Fimfolha,Pos_cabec)
Local Colunas := ""
Local x_impr  := 0
Local xTmp    := 0

Colunas := IIF(Tamanho=="P",80,IIF(Tamanho=="G",220,132))

IF FIMFOLHA = "F"
	@ 61 ,000		 PSAY __PrtThinLine()
	@ 62 ,000		 PSAY " Microsiga "
	@ 62 ,PCOL()	 PSAY " - Software S/A. "
	@ 63 ,000		 PSAY __PrtThinLine()
	@ 64 ,000		 PSAY "       "
	RETURN Nil
EndIF
IF FIMFOLHA = "P" .OR. LI >= 60
	@ LI,00 PSAY __PrtThinLine()
	LI := 00
	IF FIMFOLHA = "P"
		RETURN Nil
	EndIF
EndIF
IF LI=00
	
	@ 00,000 PSAY __PrtThinLine()
	@ 01,000 PSAY SM0->M0_NOME
	COL_AUX = IF(COLUNAS = 220,210,COLUNAS)
	WCOL	  = INT((COL_AUX - (LEN(TRIM(TITULO))))/2)
	WPAGINA = SUBSTR(STR(CONTFL+100000,6),2,5)
	IF TYPE("POS_CABEC")= "U"
		@ 01,COLUNAS-20 PSAY STR0053 + WPAGINA  //"Folha:        "
	EndIF
	@ 02,000 PSAY CHR(83) + CHR(46) + CHR(73) + CHR(46) + CHR(71) + CHR(46) + CHR(65) + CHR(46) + " / "  + AT_PRG
	@ 02,WCOL		 PSAY TRIM(TITULO)
	IF TYPE("POS_CABEC")= "U"
		@ 02,COLUNAS-20 PSAY STR0054 //"DT.Ref.:"
		@ 02,COLUNAS-11 PSAY PADL(dDataBase,10)
	EndIF
	@ 03,000 PSAY STR0055 + TIME() //"*Hora...: "
	IF TYPE("POS_CABEC")= "U"
		@ 03,COLUNAS-20 PSAY STR0056 //"Emissao:"
		@ 03,COLUNAS-11 PSAY PADL(DATE(),10)
	EndIF
	@ 04,000 PSAY __PrtThinLine()
	IF TYPE("POS_CABEC") # "U"
		LI_cCabec = 6
	Else
		LI_cCabec = 5
	EndIF
	IF nCabec0 == 0
		IF TYPE("POS_CABEC") # "U"
			@ 06,00 PSAY STR0057 + WPAGINA //"*Folha:       "
			@ 07,00 PSAY STR0058 //"*DT.Ref.:  "
			@ 07,14 PSAY dDataBase
			@ 08,00 PSAY STR0059 //"*Emissao:"
			@ 08,14 PSAY DATE()
			LI_cCabec = 10
		EndIF
		@ LI_cCabec,000 PSAY __PrtThinLine()
	EndIF
	IF nCabec0 <> 0
		FOR X_IMPR = 1 TO nCabec0
			IF TYPE("POS_CABEC") # "U"
				IF X_IMPR = 1
					@ LI_cCabec,00 PSAY STR0057 + WPAGINA //"*Folha:       "
				ElseIF X_IMPR = 2
					@ LI_cCabec,00 PSAY STR0058 //"*DT.Ref.:  "
					@ LI_cCabec,14 PSAY dDataBase
				ElseIF X_IMPR = 3
					@ LI_cCabec,00 PSAY STR0059 //"*Emissao:"
					@ LI_cCabec,14 PSAY DATE()
				EndIF
			EndIF
			AUX_IMPR = "cCabec" + ALLTRIM(STR(X_IMPR))
			IF X_IMPR <= 3
				@ LI_cCabec,IIF(TYPE("POS_CABEC")="U",000,025) PSAY &AUX_IMPR
			Else
				@ LI_cCabec,000 PSAY &AUX_IMPR
			EndIF
			LI_cCabec = LI_cCabec + 1
		NEXT
		IF TYPE("POS_CABEC") # "U"
			IF X_IMPR <=3
				FOR XTMP = X_IMPR-1 TO 3
					IF XTMP = 2
						@ LI_cCabec,00 PSAY STR0058 //"*DT.Ref.:  "
						@ LI_cCabec,14 PSAY dDataBAse
					Else
						@ LI_cCabec,00 PSAY STR0059 //"*Emissao:"
						@ LI_cCabec,14 PSAY DATE()
					EndIF
					LI_cCabec = LI_cCabec + 1
				NEXT
			EndIF
		EndIF
		@ LI_cCabec,000 PSAY __PrtThinLine()
	EndIF
	LI 	 = LI_cCabec+1
	CONTFL = CONTFL+1
	
	__LogPages()
	
EndIF
@ LI,00 PSAY DETALHE
LI = LI+1
RETURN Nil

Static Function AL_InicioEnc()
aTela := aClone(aSvATela[1])
aGets := aClone(aSvAGets[1])
dbSelectArea("SFJ")
Return .F.

Static Function AL_EntraEnc(nE,cAlias)
aTela := AClone(aSvAtela[nE])
aGets := AClone(aSvaGets[nE])
dbSelectArea(cAlias)
Return

//
Static Function Al_Saienc(nE)
aSvATela[nE]	:= aClone(aTela)
aSvAGets[nE] 	:= aClone(aGets)
Return

Static Function Traz_Marca(cProduto)
Local cMarca := ""
SB1->(dbSetOrder(1))
SB1->(MsSeek(xFilial("SB1")+cProduto))

SBM->(dbSetOrder(1))
SBM->(MsSeek(xFilial("SBM")+SB1->B1_GRUPO))

cMarca := SBM->BM_CODMAR
Return cMarca

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ MTA297Li ³ Autor ³ Valdir F. Silva       ³ Data ³ 10/05/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Muda de Linha                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATA297                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function MTA297Li()
Local lRet := .T.
Local lDeleted := .F.
Local nx

IF ValType(aCols[n,Len(aCols[n])]) == "L"
	lDeleted := aCols[n,Len(aCols[n])]      // Verifica se esta Deletado
EndIF
IF !lDeleted
	For nx = 1 To Len(aCols)
		IF Mod(aCols[nx,ProcH('DF_QTDINF')],If(aCols[nx,ProcH('DF_QE')] > 0,aCols[nx,ProcH('DF_QE')],1)  ) > 0
			Help(" ",1,"MTA297LIN")
			lRet := .f.
		EndIF
		IF !lRet
			Exit
		EndIF
	Next nx
	If lRet .And. (nOpca == 3 .Or. nOpca == 4)
		a297ChkQtd()
	EndIf
EndIF
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ MTA297OK ³ Autor ³ Valdir F. Silva       ³ Data ³ 10/05/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Tudo Ok                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATA297                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function MTA297OK()

Local lRet     := .T.
Local lDeleted := .F.
Local lContinua:= .F.
Local nX

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Valida a Quantidade.                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nOpca == 3 .Or. nOpca == 4 //Alterar
	For nX := 1 to Len(aCols)
		A297ChkQtd(nX)
	Next nX
EndIf

If nOpca == 4 //Alterar

	If M->FJ_TIPGER == "1"

		lContinua:=MsgYesNo(STR0070,STR0062) //"Confirma a Geracao da Solicitacao de Compras"

	ElseIf M->FJ_TIPGER == "2"
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica se o preco esta preenchido para gerar Pedido  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		For nX :=1 To Len( aCols )
			If !aCols[nX][Len(aCols[nX])]
				If Empty(aCols[nX][ProcH('DF_VLRTOT')])
					lMshelpAuto := .F.
					Help(" ",1,"A12003")
					lRet := .F.
				EndIf
			EndIf
		Next nX
		
		If lRet .And. ( Empty(M->FJ_FORNECE) .Or. Empty(M->FJ_LOJA) .Or. Empty(M->FJ_FILENT) .Or. Empty(M->FJ_COND))
			lMshelpAuto := .F.
			Help(" ",1,"MTA297PED")
			lRet := .F.
		EndIf

        If lRet

			lContinua:=MsgYesNo(STR0071,STR0062) //"Confirma a Geracao do Pedido de Compra"
	
			If lContinua .and. GetMV("MV_VEICULO") == "S"
				If !Pergunte("MT297A",.T.)
					lRet := .F.
				EndIF
			EndIF
			
        EndIf 
	EndIf
	
	lMshelpAuto := .T.
	
	If lRet .And. lContinua

		Begin Transaction
		
		For nX:=1 to Len(aCols)

			If ValType(aCols[nX,Len(aCols[nX])]) == "L"
				lDeleted := aCols[nX,Len(aCols[nX])]      // Verfiica se esta Deletado
			EndIf
			If ! lDeleted
				If SDF->(MsSeek(xFilial("SDF")+SFJ->FJ_CODIGO+aCols[nX,ProcH('DF_PRODUTO')]))
					SDF->(RecLock("SDF",.F.))
					SDF->DF_QTDINF := aCols[nX,ProcH('DF_QTDINF')]
					SDF->DF_VLRTOT := aCols[nX,ProcH('DF_VLRTOT')]
					SDF->(MsUnlock())
				EndIf
			Else
				If SDF->(MsSeek(xFilial("SDF")+SFJ->FJ_CODIGO+aCols[nX,ProcH('DF_PRODUTO')]))
					SDF->(RecLock("SDF",.F.))
					SDF->(DbDelete())
					SDF->(MsUnlock())
				EndIf
			EndIF

		Next nX

		If M->FJ_TIPPRC # nTipPrc
			SFJ->(RecLock("SFJ",.F.))
			SFJ->FJ_TIPPRC := M->FJ_TIPPRC
			SFJ->(MsUnlock())
		EndIf
		
		MT297Ger(MV_PAR01,MV_PAR02,MV_PAR03,MV_PAR04,MV_PAR05)

		End Transaction

		If lMsErroAuto
			MostraErro()
			lRet := .F.
		EndIf
	
		lMsErroAuto := .F.
		lMsHelpAuto := .F.

	EndIf

EndIf

Return lRet

// Funcoes Estaticas
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ SaldoEst ³ Autor ³ Valdir F. Silva       ³ Data ³ 10/05/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³SaldoEst                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³SaldoEst(cCod)                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATA297                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function SaldoEst(cCod)
Local cAlias :=GetArea()
Local nSaldo :=0
Local nPend  :=0
Local nVezes :=0
Local nCustoM:=0
DbSelectArea("SB2")
DBSetOrder(1)  //SB2 Acum.Sugest.Compra	->B2_FILIAL+B2_COD+B2_LOCAL
MsSeek(xFilial("SB2")+cCod)
While ! eof() .and. B2_FILIAL == xFilial("SB2") .and. B2_COD == cCod
	If Trim(GetMV("MV_VEICULO")) == "S" .and. B2_LOCAL > '50'
		DbSkip()
		Loop
	EndIf
	nVezes++
	nSaldo  += B2_QATU
	nPend   += B2_SALPEDI
	nCustoM += B2_CM1
	DbSkip()
EndDo
RestArea(cAlias)
IF nVezes > 0
	nCustoM := (nCustoM/nVezes)
EndIF
Return {nSaldo,nPend,nCustoM}

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ MontaCols³ Autor ³ Valdir F. Silva       ³ Data ³ 10/05/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Monta Cols                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³MontaCols()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATA297                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function MontaCols()

Local aNoFields := {"DF_FILIAL","DF_CODIGO","DF_DESC","DF_M12","DF_M03","DF_D01","DF_D02","DF_D03","DF_D04","DF_D05","DF_D06","DF_D07","DF_D08","DF_D09","DF_D10","DF_D11","DF_D12","DF_QTDEST","DF_QTDPC","DF_QTDSUGM","DF_PE","DF_FLAG"}
Local cSeek     := xFilial("SDF")+SFJ->FJ_CODIGO 
Local cWhile    := "SDF->DF_FILIAL+SDF->DF_CODIGO" 

DbSelectArea("SDF")
DbSetOrder(1)

aHeader := {}
aCols   := {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Sintaxe da FillGetDados(/*nOpcX*/,/*Alias*/,/*nOrdem*/,/*cSeek*/,/*bSeekWhile*/,/*uSeekFor*/,/*aNoFields*/,/*aYesFields*/,/*lOnlyYes*/,/*cQuery*/,/*bMontCols*/,/*lEmpty*/,/*aHeaderAux*/,/*aColsAux*/,/*bAfterCols*/) |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
FillGetDados(4,"SDF",1,cSeek,{|| &cWhile },,aNoFields,,,,,,,,)

Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³Mt297Tela	  ³ Autor ³ Wilson		        ³ Data ³ 17/03/97 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Enchoice e GetDados                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³lRet:=Mt297Tela(cTitulo,cAlias1,cAlias2,aMyEncho,cLinOk, 	  ³±±
±±³			 ³cTudoOk,nOpcE,nOpcG,cFieldOk,lVirtual,nLinhas,aAltEnchoice  ³±±
±±³			 ³  ,nFreeze,aAlter)                                          ³±±
±±³			 ³lRet=Retorno .T. Confirma / .F. Abandona                    ³±±
±±³			 ³cTitulo=Titulo da Janela                                    ³±±
±±³			 ³cAlias1=Alias da Enchoice                                   ³±±
±±³			 ³cAlias2=Alias da GetDados                                   ³±±
±±³			 ³aMyEncho=Array com campos da Enchoice                       ³±±
±±³			 ³cLinOk=LinOk                                                ³±±
±±³			 ³cTudOk=TudOk                                                ³±±
±±³			 ³nOpcE=nOpc da Enchoice                                      ³±±
±±³			 ³nOpcG=nOpc da GetDados                                      ³±±
±±³			 ³cFieldOk=validacao para todos os campos da GetDados 		  ³±±
±±³			 ³lVirtual=Permite visualizar campos virtuais na enchoice	  ³±±
±±³			 ³nLinhas=Numero Maximo de linhas na getdados                 ³±±
±±³			 ³aAltEnchoice=Array com campos da Enchoice Alteraveis		  ³±±
±±³			 ³nFreeze=Congelamento das colunas.                           ³±±
±±³			 ³aAlter =Campos do GetDados a serem alterados.               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³MTA297                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±³         nAtualIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador  ³ Data   ³ BOPS ³  Motivo da Alteracao                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Valdir F. Sil³11/05/00³XXXXXX³Colocar campos alteraveis no GetDados    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Mt297Tela(cTitulo,cAlias1,cAlias2,aMyEncho,cLinOk,cTudoOk,nOpcE,nOpcG,cFieldOk,lVirtual,nLinhas,aAltEnchoice,nFreeze,aAlter)

Local lRet       := .T.
Local nOpca      := 0
Local nReg       := (cAlias1)->(Recno())
Local oDlg
Local aSize      := MsAdvSize(,.F. )
Local aPosObj1   := {}
Local aObjects   := {}
Local aButtons	 := {}
Local aButtonUsr := {}
Local nX         := 0

DEFAULT nOpcE    := 3
DEFAULT nOpcG    := 3
DEFAULT lVirtual := .F.
DEFAULT nLinhas  := 99

If ( ExistBlock("MT297BUT") )
	aButtonUsr := ExecBlock("MT297BUT",.F.,.F.,{nOpcE})
	If ( ValType(aButtonUsr) == "A" )
		For nX := 1 To Len(aButtonUsr)
			Aadd(aButtons,aClone(aButtonUsr[nX]))
		Next nX
	EndIf
EndIf

aObjects := {}
AAdd( aObjects, { 100, 082, .T., .F. } )
AAdd( aObjects, { 100, 100, .T., .T. } )
AAdd( aObjects, { 100, 053, .T., .F. } )

aInfo    := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 0, 0 }
aPosObj1 := MsObjSize( aInfo, aObjects)


DEFINE MSDIALOG oDlg TITLE cTitulo From aSize[7],000 to aSize[6],aSize[5] of oMainWnd PIXEL

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Enchoice 01							                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aTela := {}
aGets := {}
dbSelectArea("SFJ")
RegToMemory("SFJ")
Zero()

oEnc01:= MsMGet():New("SFJ" ,nReg ,nOpcE,,,,aMyEncho[1],{aPosObj1[1,1],aPosObj1[1,2],aPosObj1[1,3],aPosObj1[1,4]},aAltEnchoice,3,,,,oDLG,,,lVirtual,"aSvATela[1]")
oEnc01:oBox:bGotFocus   := {|| AL_EntraEnc(1,"SFJ")}
oEnc01:oBox:bLostFocus  := {|| AL_SaiEnc(1)}

aSvATela[1] := aClone(aTela)
aSvAGets[1] := aClone(aGets)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Enchoice 02							                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aTela := {}
aGets := {}

dbSelectArea("SDF")
DbSetOrder(1)
MsSeek( xFilial("SDF")+SFJ->FJ_CODIGO )
If Type('M->DF_PRODUTO') == 'U'
	M->DF_PRODUTO := Space(15)
Endif

RegToMemory("SDF",.F.)

Zero()

oEnc02:= MsMGet():New("SDF" ,nReg ,5,,,,aMyEncho[2],{aPosObj1[3,1]+5,aPosObj1[3,2],aPosObj1[3,3],aPosObj1[3,4]},nil,4,,,,oDLG,,,lVirtual,"aSvATela[2]")
oEnc02:oBox:bGotFocus   := {|| AL_EntraEnc(2,"SDF")}
oEnc02:oBox:bLostFocus  := {|| AL_SaiEnc(2)}
aSvATela[2] := aClone(aTela)
aSvAGets[2] := aClone(aGets)

oGetDados := MsGetDados():New(aPosObj1[2,1]+5,aPosObj1[2,2],aPosObj1[2,3],aPosObj1[2,4],nOpcG,cLinOk,cTudoOk,"",IF(nOpcE==4,.t.,.f.),aAlter,nFreeze,,nLinhas,cFieldOk)
oGetDados:oBrowse:bDrawSelect := {|| MTA297AT()}
oGetDados:oBrowse:bChange := {|| MTA297AT()}

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||nOpca:=1,IF(oGetDados:TudoOk(),IF(!obrigatorio(aGets,aTela),nOpca := 0,oDlg:End()),nOpca := 0)},{||oDlg:End()},AL_InicioEnc(),aButtons) CENTERED

lRet:=(nOpca==1)

If (ExistBlock("M297EXIT"))
	lRet := ExecBlock("M297EXIT",.F.,.F.,{lRet,nOpca})
EndIf

Return lRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³297FilEnt ³ Autor ³ Valdir F. Silva      ³ Data ³25.08.2000³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Verif. existencia da Filial para Entrega do Pedido em SM0. ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ 297FilEnt(ExpC1)                                       	 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 := Codigo da Filial de Entrega                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Mata297  		                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A297FilEnt(cFilialEnt)

Local aArea		:= GetArea()
Local lRet 		:= .T.
Local aAreaSM0  := SM0->(GetArea())

If M->FJ_TIPGER == "2"
	If !Empty(cFilialEnt).And.Empty(xFilial("SFJ"))
		Help(" ",1,"FILENTC")
		lRet := .T.
	ElseIF Empty(cFilialEnt).And.!Empty(xFilial("SFJ"))
		Help(" ",1,"FILENTE")
		lRet := .F.
	Else
		dbSelectArea("SM0")
		dbSetOrder(1)
		If !MsSeek(SUBS(cNumEmp,1,2)+cFilialEnt)	// Procura pelo Numero da Empresa e Filial para Entrega.
			Help(" ",1,"C7_FILENT")
			lRet := .F.
		EndIf
	EndIf
EndIf
RestArea(aAreaSM0)
RestArea(aArea)
Return lRet

//Atualiza a acols
Static Function MTA297AT()
SDF->(DbSetOrder(1))
SDF->(MsSeek( xFilial("SDF")+SFJ->FJ_CODIGO+aCols[n,ProcH('DF_PRODUTO')]))
RegToMemory("SDF",.F.)
oEnc02:EnchRefreshAll()
oEnc01:EnchRefreshAll()
Return
//Valida e atualiza os totais
Function MT297VLD()
Local lRet := .T.
Local aSE  := {}
Local nX
For nX:=1 to Len(aCols)
	SB1->(DbSetOrder(1))
	SB1->(MsSeek(xFilial("SB1")+aCols[nX,ProcH('DF_PRODUTO')]))
	aSE      :=SaldoEst(aCols[nX,ProcH('DF_PRODUTO')])
	IF M->FJ_TIPPRC == "1"
		aCols[nX,ProcH('DF_VLRTOT')] := aCols[nX,ProcH('DF_QTDSUG')]*RetFldProd(SB1->B1_COD,"B1_CUSTD")
	ElseIF M->FJ_TIPPRC == "2"
		aCols[nX,ProcH('DF_VLRTOT')] := aCols[nX,ProcH('DF_QTDSUG')]*RetFldProd(SB1->B1_COD,"B1_UPRC")
	Else
		aCols[nX,ProcH('DF_VLRTOT')] := aCols[nX,ProcH('DF_QTDSUG')]*SB1->B1_PRV1
	EndIF
Next

oGetDados:oBrowse:Refresh()

Return lRet

Static Function ProcH(cCampo)
Return aScan(aHeader,{|x|Trim(x[2])== cCampo })

Function A297ChkQtd(nLinha)
Local nOpcao:=0
Local nQuantInf:=0
Default nLinha:=N
nQuantInf:=GDFieldGet("DF_QTDINF",nLinha)
If QtdComp(nQuantInf) <= QtdComp(0)
	nOpcao:=Aviso(OemToAnsi(STR0074),OemToAnsi(STR0075)+Alltrim(Str(nLinha))+OemToAnsi(STR0076),{OemToAnsi(STR0077),OemToAnsi(STR0078)})
	If nOpcao == 1
		GDFieldPut("DF_QTDINF",GDFieldGet("DF_QTDSUG",nLinha),nLinha)								
	Else
		IF ValType(aCols[nLinha,Len(aCols[nLinha])]) == "L"
			aCols[nLinha,Len(aCols[nLinha])]:=.T.
		Else
			GDFieldPut("DF_QTDINF",GDFieldGet("DF_QTDSUG",nLinha),nLinha)												
		EndIF
	EndIf
EndIF
RETURN 

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³MenuDef   ³ Autor ³ Fabio Alves Silva     ³ Data ³04/10/2006³±±
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
Private aRotina	:= {{STR0002  ,"AxPesqui", 0 , 1,0,.F.},; //"Pesquisar"
							{STR0003  ,"MT297Vis", 0 , 2,0,nil},; //"Visualizar"
							{STR0067  ,"MT297Inc", 0 , 3,0,nil},; //"Incluir"
							{STR0068  ,"MT297Alt", 0 , 6,0,nil},; //"Efetivar"
							{STR0069  ,"MT297Can", 0 , 5,0,nil},; //"Cancelar Efet."
							{STR0007  ,"MT297Imp", 0 , 5,0,nil},; //"Imprimir"
							{STR0008  ,"MT297Exc", 0 , 5,0,nil},;  //"Excluir"    
							{STR0079  ,"MT297Leg", 0 , 2,0,nil}}  //"Legenda"  
If ExistBlock("MTA297MNU")
	ExecBlock ("MTA297MNU",.F.,.F.)
Endif								
return (aRotina)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³A297CalDem³ Autor ³ Rodrigo Toeldo Silva  ³ Data ³ 14/02/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Calcula o saldo demanda gerada para que seja utlizado nas  ³±±
±±³			 ³ sugestao de compra(MATA297) e cen?tral de compras(MATA179)  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cExp1 == Ano/Mes para ser utilizado na sugestao de compra  ³±±
±±³			 ³ cExp2 == Codigo do produto que sera utilizado no calculo	  ³±±
±±³			 ³ nExp3 == Dias de sugestao para ser utilizado no calculo	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Mata297/Mata179                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A297CalDem(cAnoMes,cProduto,nDSugest,aConsumo)
Local aAreaSBL		:= SBL->(GetArea())
Local bFormula  	:= {|| 0}
Local nDiasRep		:= 0
Local nSldCalc		:= 0
Local lRet			:= .T.
Local lSM4Form		:= .F.

Default cAnoMes		:= dDataBase
Default cProduto 	:= ""

aConsumo := Mt295Cons(cAnoMes,cProduto)
nAtual   := Len(aConsumo)
If SBL->BL_CODFORM == "PES"
	bFormula := {|x,y| x[y-1]}
ElseIf SBL->BL_CODFORM == "PME"
	bFormula := {|x,y| (x[y-1] + x[y-2] + x[y-3]) / 3}
ElseIf SBL->BL_CODFORM == "PTE"
	bFormula := {|x,y| x[y-1] +(x[y-1] - x[y-2])}
ElseIf SBL->BL_CODFORM == "PSA"
	bFormula := {|x,y| x[y-12]*((x[y-1]+x[y-2]+x[y-3])/(x[y-13]+x[y-14]+x[y-15]))}
Else
	If SM4->(MsSeek(xFilial("SM4")+SBL->BL_CODFORM))
		bFormula := "{ || " + &(SM4->M4_FORMULA) + " }"
		bFormula := StrTran(bFormula,'"','')
		bFormula := &(bFormula)		
		lSM4Form := .T.
	Else   
	    lRet := .F.
	EndIf
EndIf
If lRet
	nDiasRep := CalcPrazo(cProduto)
	nSldCalc := Round(Iif(lSM4Form,Eval(bFormula),Eval(bFormula,aConsumo,nAtual)) * (nDSugest+nDiasRep)/30,TamSx3("DF_QTDSUG")[2])
Else
	nSldCalc := 0
EndIf

RestArea(aAreaSBL)
Return nSldCalc

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³MT297Leg   ³ Autor ³ Carlos Capeli        ³ Data ³04.09.2015 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³Exibe uma janela contendo a legenda da mBrowse.              ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Exclusivo MATA297                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function MT297Leg()

Local aCores     := {}

aAdd(aCores,{"ENABLE"	,STR0080})	// Sugestao em aberto
aAdd(aCores,{"DISABLE"	,STR0081})	// Sugestao efetivada

BrwLegenda(cCadastro,STR0079,aCores)

Return
