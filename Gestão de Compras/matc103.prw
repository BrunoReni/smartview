#include "MatC103.ch"
#include "FiveWin.ch"
#include "Folder.ch"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ FUNCAO   ³ MATC103  ³ AUTOR ³ Aline Correa do Vale  ³ DATA ³ 29.11.2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ DESCRICAO³ Visualizar Notas Fiscais de Compra                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ PROGRAMADOR  ³ DATA   ³ BOPS ³  MOTIVO DA ALTERACAO                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function MatC103()
Local aFixe :=	{{	OemToAnsi(STR0001),"D1_DOC    " },; //"Numero da NF"
					{	OemToAnsi(STR0002),"D1_SERIE  " },; //"Serie da NF "
               {	OemToAnsi(STR0003),"D1_FORNECE" }}  //"Fornecedor  "

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica a permissao do programa em relacao aos modulos      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE lDigita, lAglutina,lGeraLanc, lAbandona := .F.
PRIVATE lIntegracao := IF(GetMV("MV_EASY")=="S",.T.,.F.)
PRIVATE aRotina := {		{ STR0004,"AxPesqui"		, 0 , 1},;		//"Pesquisar"
								{ STR0005,"C103Visual"	, 0 , 2} }		//"Visualizar"

PRIVATE cCadastro	:= OemToAnsi(STR0009)          //"Notas Fiscais de Entrada"
PRIVATE cTit, cNome :=""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Endereca a funcao de BROWSE                                  ³
//³ Obs.: O parametro aFixe nao e' obrigatorio e pode ser omitido³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
mBrowse( 6, 1,22,75,"SD1",aFixe,"D1_TES" )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Recupera a Integridade dos dados                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SC7")
dbSetOrder(1)

dbSelectArea("SB8")
dbSetOrder(1)

dbSelectArea("SF3")
dbSetOrder(1)

Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A100Visual³ Autor ³ Claudinei M. Benzi    ³ Data ³          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa de visualizacao das notas fiscais de entrada.     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ A100Visual(ExpC1,ExpN1,ExpN2)                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias do arquivo                                   ³±±
±±³          ³ ExpN1 = Numero do registro                                 ³±±
±±³          ³ ExpN2 = Numero da opcao selecionada                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function C103Visual(cAlias,nReg,nOpcx)
Local cSeek ,nCnt
Local oDlg ,oGet
Local cConhecNBM	:= If(lintegracao,SD1->D1_CONHEC,"")
Local cCampo		:= "",i
Local aArea 		:= GetArea()
Local cSavAlias	:= cAlias

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Padronizacao do cAlias para Browsers no SF1                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If cAlias == "SF1"
	dbSelectArea("SD1")
	dbSetOrder(1)
	dbSeek(xFilial()+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA)
	cAlias := "SD1"
EndIf

dbSelectArea(cAlias)
If D1_FILIAL != xFilial()
      HELP(" ",1,"A000FI")
      Return (.T.)
Endif

PRIVATE dDatCont := dDataBase ,nUsado := 0 ,nOpcA

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta a entrada de dados do arquivo                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE aHeader[0],Continua:=.F.,nOpc:=3,aDUPL[0]

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Montagem do aHeader                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("Sx3")
dbSeek(cAlias)
While !Eof() .And. (x3_arquivo == cAlias)
      IF x3uso(x3_usado) .AND. cNivel >= x3_nivel
            nUsado++
            AADD(aHeader,{ TRIM(X3Titulo()), x3_campo, x3_picture,;
						x3_tamanho, x3_decimal, x3_valid,;
						x3_usado, x3_tipo, x3_arquivo, x3_context } )
      Endif
      dbSkip()
EndDo

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Posiciona ponteiro do arquivo cabeca e inicializa variaveis  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cSeek := SD1->D1_DOC+SD1->D1_SERIE+SD1->D1_FORNECE+SD1->D1_LOJA
dbSelectArea("SF1")
dbSetOrder(1)
dbSeek( xFilial()+cSeek )
PRIVATE cTipo  :=F1_TIPO ,cNFiscal :=F1_DOC     ,cSerie   :=SerieNfId("SF1",2,"F1_SERIE"),;
      dDEmissao:=F1_EMISSAO ,nTotNot  :=F1_VALBRUT ,cA100For :=F1_FORNECE,;
      cLoja    :=F1_LOJA    ,nTotMerc :=F1_VALMERC ,nValFrete:=F1_FRETE,;
      nValDesp :=F1_DESPESA ,nTotIcm  :=F1_VALICM  ,nTotIpi  :=F1_VALIPI,;
      nValDesc :=F1_DESCONT ,nBRetIcms:=F1_BRICMS  ,nIcmsRet :=F1_ICMSRET,;
      nBaseFrete :=F1_BASEFD,nTotBase2 :=F1_BASEICM ,nBaseItem:=0.00,;
      nlIcmsRet:=.F.        ,nValFun  :=F1_CONTSOC ,cFormul  :=F1_FORMUL,;
      dDigit      := F1_DTDIGIT ,cEspecie :=F1_ESPECIE

PRIVATE aLivro:={}, lDesc:=.F.
PRIVATE cTipoNF:='E' 									// Flag utilizada na AliqIcm()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Montagem do aCols                                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea(cAlias)
dbSetOrder(1)
dbSeek(xFilial()+cSeek)
aCols:={}
nCnt := 0
Do While !Eof() .And. D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA == xFilial()+cSeek
      nCnt++
      nUsado:=0
      AADD(aCols,Array(Len(aHeader)))
      For i:=1 to Len(aHeader)
            cCampo:=Alltrim(aHeader[i,2])
            If aHeader[i,10] # "V"
                  aCOLS[Len(aCols)][i] := FieldGet(FieldPos(cCampo))
            ElseIF aHeader[i,10] == "V"
                  aCOLS[Len(aCols)][i] := CriaVar(cCampo)
            EndIf
      Next i
      dbSelectArea(cAlias)
      dbSkip()
EndDo

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Caso nao ache nenhum item , abandona rotina.         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nCnt == 0
      dbSetOrder(1)
      Return .T.
EndIf

DEFINE MSDIALOG oDlg TITLE cCadastro From 9,0 To 28,80 OF oMainWnd         //"Nota de Entrada de Mercadorias"

@ 11, 005 TO 48, 310 LABEL "" OF oDlg  PIXEL
@ 18, 010 SAY OemtoAnsi(STR0011)	SIZE 15,07	OF oDlg PIXEL          //"Tipo"
@ 18, 030 MSGET cTipo           		SIZE 09,10	OF oDlg PIXEL WHEN (.F.)
@ 18, 050 SAY OemtoAnsi(STR0012)	SIZE 50,07	OF oDlg PIXEL         //"Formul rio Pr¢prio"
@ 18, 105 MSGET cFormul         		SIZE 09,10	OF oDlg PIXEL WHEN (.F.)
@ 18, 125 SAY OemtoAnsi(STR0013) 	SIZE 40,07	OF oDlg PIXEL         //"Nota Fiscal"
If Len(cNFiscal)>6
		@ 18, 155 MSGET cNFiscal SIZE 45,10 OF oDlg PIXEL PICTURE "@R 9999-99999999" WHEN (.F.)
Else
		@ 18, 170 MSGET cNFiscal SIZE 25,10 OF oDlg PIXEL WHEN (.F.)
Endif
@ 18,205 SAY OemtoAnsi(STR0014)	SIZE 15,07 OF oDlg PIXEL           //"S‚rie"
@ 18,225 MSGET cSerie         	SIZE 16,10 OF oDlg PIXEL WHEN (.F.)
@ 18,250 SAY OemtoAnsi(STR0015)	SIZE 16,07 OF oDlg PIXEL          //"Data"
@ 18,265 MSGET dDEmissao       	SIZE 39,10 OF oDlg PIXEL WHEN (.F.)
If cTipo $ "DB"
		@ 33, 010 SAY OemtoAnsi(STR0016) SIZE 40, 7 OF oDlg PIXEL   //"Cliente   "
Else
		@ 33, 010 SAY OemtoAnsi(STR0017) SIZE 40, 7 OF oDlg PIXEL   //"Fornecedor"
Endif
@ 33, 050 MSGET cA100For          SIZE 30, 10 OF oDlg PIXEL WHEN (.F.)
@ 33, 085 MSGET cLoja             SIZE 14, 10 OF oDlg PIXEL WHEN (.F.)
If lIntegracao .And. SF1->F1_IMPORT == "S"
	@ 33,125 SAY OemtoAnsi(STR0018)	SIZE 40,07 OF oDlg PIXEL       //"Conhecimento :"
	@ 33,170 MSGET cConhecNBM			SIZE 40,10 OF oDlg PIXEL WHEN (.F.)
Endif
@ 33,225 SAY OemtoAnsi(STR0019) SIZE 50,07 OF oDlg PIXEL          //"Tipo de Documento"
@ 33,272 MSGET cEspecie       	SIZE 25,10 OF oDlg PIXEL WHEN (.F.)
dbSelectArea(If(cTipo$"DB","SA1","SA2"))
dbSeek(xFilial()+SubStr(cA100For,1,Len(SA2->A2_COD))+cLoja)

@ 122, 005 TO 143, 310 LABEL "" OF oDlg  PIXEL
cTit := IIF(cTipo$'DB',STR0020,STR0021)         //'Cliente: '###'Fornecedor: '
@ 129,010 SAY OemToAnsi(STR0022)+DtoC(dDigit)+" "+OemtoAnsi(cTit)+IIf(cTipo$'DB',SA1->A1_NOME,SA2->A2_NOME) SIZE 150,7 OF oDlg PIXEL            //"Dt Entr:"
@ 129,200 SAY OemtoAnsi(STR0023) SIZE 45,7 OF oDlg PIXEL          //'Total da Nota'
@ 129,250 MSGET nTotNot PICTURE "@E 999,999,999,999.99" SIZE 50,10 OF oDlg PIXEL RIGHT WHEN (.F.)

oGet := MSGetDados():New(50,5,124,310,nOpcx,"A100LinOk","A100TudOk","",.F.)

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||nOpca:=1,A100Rodape(.f.),oDlg:End()},{||oDlg:End()})

dbSelectArea(cAlias)
dbSeek(xFilial()+cSeek)

cAlias := cSavAlias

RestArea(aArea)
Return