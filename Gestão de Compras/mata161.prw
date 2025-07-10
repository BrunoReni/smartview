#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "MATA161.CH"

#INCLUDE 'FWLIBVERSION.CH' 

#DEFINE CAB_ARQTMP  01 
#DEFINE CAB_POSATU  02
#DEFINE CAB_SAYGET  03
#DEFINE CAB_HFLD1   04
#DEFINE CAB_HFLD2   05
#DEFINE CAB_HFLD3   06
#DEFINE CAB_MARK    07 
#DEFINE CAB_GETDAD  08                     
#DEFINE CAB_COTACAO 09
#DEFINE CAB_MSMGET  10
#DEFINE CAB_ULTFORN 11
#DEFINE CAB_HISTORI 12
#DEFINE ENTER CHR(13)+CHR(10)

Static lLGPD  := FindFunction("SuprLGPD") .And. SuprLGPD()

//-------------------------------------------------------------------
/*/{Protheus.doc} MATA161() 
Analise da cotação - Mapa de Cotação
@author Leonardo Quintania
@since 30/10/2013
@version 1.0
@return NIL
/*/
//-------------------------------------------------------------------
Function MATA161()

Local oBrowse 		:= Nil
Local lUsrFilter 	:= ExistBlock("MT161FIL")
Local cUsrFilter 	:= ""
Local aLegenda		:={}
Local aCoresUsr		:={}
Local nX			:= 0

Private aRotina 	:= MenuDef()
Private lMdText 	:= .F.
Private cStrBMemo 	:= ''
Private lMarkVenc 	:= .F.
Private lVencMark  	:= .F.
Private aGravaAud 	:= {}
Private aHeadAud 	:={}
Private aColsAud  	:= {}
Private aHistSld  	:= {}
Private lHistRst  	:= .T.
Private nQtdSldBkp 	:= 0

Private mvPAR01, mvPAR02, mvPAR03, mvPAR04, mvPAR05, mvPAR06, mvPAR07, mvPAR08


oBrowse := FWMBrowse():New()
oBrowse:SetAlias("SC8")

If ( ExistBlock("MT161LEG") )
	aCoresUsr := ExecBlock("MT161LEG",.F.,.F.,{aLegenda})
	If ( ValType(aCoresUsr) == "A" )
		aLegenda := aClone(aCoresUsr)
	EndIf
EndIf 

// Definição da legenda
aAdd(aLegenda,{"A161LegPc()","BLACK",STR0142})//Cotação analisada pelo processo de auditoria com pedido de compra em aberto
Aadd(aLegenda,{ "Empty(C8_NUMPED).And.C8_PRECO<>0.And.!Empty(C8_COND)", "GREEN"	, STR0001 })//"Em Analise"//'Em Analise'
Aadd(aLegenda,{ "!Empty(C8_NUMPED)", "RED" 	, STR0002 })//"Analisada"//'Analisada'
Aadd(aLegenda,{ "(C8_PRECO==0 .Or. Empty(C8_COND)).And.Empty(C8_NUMPED)", "YELLOW" 	, STR0003 })//"Em Aberto - Não Cotada"//'Em Aberto - Não Cotada'
Aadd(aLegenda,{ "(SC8->(FieldPos('C8_ACCNUM'))>0 .And. !Empty(SC8->C8_ACCNUM) .And. !Empty(SC8->C8_NUMPED))", "BLUE" 	, STR0004 })//"Cotação do MarketPlace"//'Cotação do MarketPlace'


For nX:= 1 to Len (aLegenda) STEP 1
	If(Len(aLegenda[nX]) >= 3)
		oBrowse:AddLegend(aLegenda[nX][1],aLegenda[nX][2],aLegenda[nX][3])	
	EndIf
Next nX
 
oBrowse:SetDescription(STR0005) ////'Mapa de Cotação'
oBrowse:DisableDetails()

SetKey(VK_F12,{|| xPergunte("MTA161",.T.)})	
xPergunte("MTA161",.F.)						

// Ponto de entrada para filtragem da Browse
If lUsrFilter
	cUsrFilter := ExecBlock("MT161FIL",.F.,.F.,{"SC8"})
	If ValType(cUsrFilter) == "C" .And. !Empty(cUsrFilter)
		oBrowse:SetFilterDefault(cUsrFilter)
	EndIf
EndIf


oBrowse:Activate()

//-- Limpa atalho
SetKey(VK_F12,Nil)

Return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} xPergunte()
Proteção de pergunta utilizada no processo do usuário em variável privada
@since 12/12/2017
@version 1.0
@return NIL
/*/
//------------------------------------------------------------------- 
Static Function xPergunte(cPerg,lExibe)

Local nPar := 0
Local cVar := ""
Local lRet

/*INICIO - Remover após release 12.1.20. Proteção perguntas de outros cPerg - Cfme alinhamento com P.O.*/
For nPar:=1 to 99 //Limpa todos os MV_PAR
	cVar := "MV_PAR"+PadL(nPar,2,"0")
	&cVar := ""
Next nPar
/*FIM - Remover após release 12.1.20. Proteção perguntas de outros cPerg - Cfme alinhamento com P.O.*/

lRet := Pergunte(cPerg,lExibe)

If Upper(AllTrim(cPerg)) == "MTA161"
	mvPAR01 := MV_PAR01
	mvPAR02 := MV_PAR02
	mvPAR03 := MV_PAR03
	mvPAR04 := MV_PAR04
	mvPAR05 := MV_PAR05
	mvPAR06 := MV_PAR06
	mvPAR07 := MV_PAR07
	If Empty(MV_PAR08)
		mvPAR08 := 1		//DT de Entrega PC: 1=DataBase + Prazo(DEFAULT), 2=Data Necessidade
	Else
		mvPAR08 := MV_PAR08
	EndIf
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef()
Definicao do Menu
@author Leonardo Quintania
@since 30/10/2013
@version 1.0
@return aRotina (vetor com botoes da EnchoiceBar)
/*/
//-------------------------------------------------------------------
Static Function MenuDef()

Local aRotina := {} //Array utilizado para controlar opcao selecionada
Local aAcoes	:= {}

ADD OPTION aRotina Title STR0006		Action 'PesqBrw'  		OPERATION 1 ACCESS 0 	//"Pesquisar"//'Pesquisar'
ADD OPTION aRotina Title STR0005		Action 'A161MapCot'		OPERATION 4 ACCESS 0  	//"Mapa de Cotação//'Mapa de Cotação'
ADD OPTION aRotina Title STR0079		Action "MsDocument('SC8',SC8->(RecNo()),2)"		OPERATION 2 ACCESS 0  	//"Conhecimento

//ÃšÃ„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Â¿
//Â³ Ponto de entrada utilizado para inserir novas opcoes no array aRotina  Â³
//Ã€Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã™
If ExistBlock("MTA161BUT")
	If ValType(aAcoes := ExecBlock( "MTA161BUT", .F., .F., {aRotina}) ) == "A"
		aRotina:= aAcoes
	EndIf
EndIf

Return aRotina

//-------------------------------------------------------------------
/*{Protheus.doc} A161MapCot
Função que efetua a montagem da tela de mapa de cotação
@author antenor.silva
@since 28/10/2013
@version P11.90
*/
//-------------------------------------------------------------------
Function A161MapCot()

Local oDlg
Local oSize			:= FWDefSize():New(.T.)

Local aArea			:= GetArea()
Local aAreaSC8		:= SC8->(GetArea())
Local aItens		:= {}
Local aPropostas	:= {}
Local aItensC		:= {STR0008,STR0009}//"Pedido de Compra"//"Contrato"
Local aButtons   	:= {}

Local cTpDoc		:= If(Val(SC8->C8_TPDOC)== 1,STR0008,STR0009)//"Pedido de Compra"//"Contrato"
Local nTpDoc		
Local nX			:= 0
Local nY			:= 0
Local cFilSC8 		:= xFilial("SC8")
Local cNumCot		:= SC8->C8_NUM

Local lblkForn      := .F. 
Local cCod
Local cLoja

Local lOk			:= .F.
Local lContinua		:= .T.
Local lRestCom		:= SuperGetMv("MV_RESTCOM",.F.,"N")=="S"
Local lIntPCO		:= SuperGetMV("MV_PCOINTE",.F.,"2")=="1"
Local lMT161Ok		:= .F. 
Local lLock			:= .T.
Local lGrade        := MaGrade()
Local lRet 			:= .T. 
Local nQtdCot       := 0
Local lMsg 			:= .F. 
Local nPosQtd 	    := 0
Local nPosForn	    := 0
Local nPosLoja 	    := 0
Local cfornece		:= ""
Local afornece		:= {}

PRIVATE cCadastro	:= STR0012 //"Análise de Cotação"
PRIVATE aHeadC7		:= {}
PRIVATE aHeadC8		:= {}
PRIVATE aColsC7		:= {}
PRIVATE aColsC8		:= {}
PRIVATE _nLinC7		:= 1
PRIVATE _nLinC8		:= 1
Private aForLjNom 	:= {}
Private lOkPCO		:= .T.
Private nPosMotC8	:= SC8->(FieldPos("C8_MOTVENC")) 
Private lMemoMotC8  := Iif(nPosMotC8 > 0, ValType(SC8->C8_MOTVENC) == "M", .F.)
Private nPosMotCE	:= SCE->(FieldPos("CE_MOTVENC")) 
Private lMemoMotCE  := Iif(nPosMotCE > 0, ValType(SCE->CE_MOTVENC) == "M", .F.)

lLock := LockByName("COT_" + cFilSC8 + cNumCot, .T., .F.)

If !lGrade .And. lLock
	//Query que retorna quantidade de produtos com o grade da cotação
	BeginSQL Alias "SC8GRD"
		SELECT COUNT(C8_GRADE) nNumGrd 
			FROM %Table:SC8% SC8
			WHERE %NotDel% AND
				C8_FILIAL = %xFilial:SC8% AND
				C8_NUM = %Exp:cNumCot% AND 
				C8_GRADE = 'S' AND
				SC8.%NotDel%
	EndSQL

	If SC8GRD->nNumGrd > 0 //Se houver produto com grade na cotação e o parametro MV_GRADE desabilitado, não permite acessar a cotação
		lRet := .F. 
	EndIf 

	SC8GRD->(dbCloseArea())
	
EndIf

If lRet 
	lRet := A161LegPc()//Ao clicar no botão Análise da Cotação, valida se a cotação foi analisada por auditoria e se todos os pedidos foram excluidos
	lMsg := .T. //Controla exibição do Help 
EndIf 

If lLock .And. lRet
	//Valida se usuario tem permissão para fazer a analise
	If lRestcom .And. !Empty(SC8->C8_GRUPCOM) .And. !VldAnCot(__cUserId,SC8->C8_GRUPCOM)
		Aviso(STR0080,STR0081+SC8->C8_GRUPCOM+ STR0082,{STR0083},2) //"Acesso Restrito"###"O  acesso  e  a utilizacao desta rotina e destinada apenas aos usuarios pertencentes ao grupo de compras : "###". com direito de analise de cotacao. "###"Voltar"
		lContinua := .F.
	EndIf

	If lContinua
		//ÃšÃ„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Â¿
		//Â³Iniciar lancamento do PCO                                       Â³
		//Ã€Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã™
		PcoIniLan("000051")
		PcoIniLan("000052")

		If lIntPCO
			//ÃšÃ„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Â¿
			//Â³ Montagem das variaveis aHeadC7 e aColsC7 utilizada na integracao com PCO Â³
			//Ã€Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã™
			dbSelectArea("SX3")
			dbSetOrder(1)
			dbSeek("SC7")
			While ( !Eof() .And. SX3->X3_ARQUIVO == "SC7" )
				If ( X3Uso(SX3->X3_USADO) .And. cNivel >= SX3->X3_NIVEL )
					AADD(aHeadC7,{ TRIM(X3Titulo()),;
						SX3->X3_CAMPO,;
						SX3->X3_PICTURE,;
						SX3->X3_TAMANHO,;
						SX3->X3_DECIMAL,;
						SX3->X3_VALID,;
						SX3->X3_USADO,;
						SX3->X3_TIPO,;
						SX3->X3_ARQUIVO,;
						SX3->X3_CONTEXT } )
				EndIf
				dbSelectArea("SX3")
				dbSkip()
			EndDo

			AADD(aColsC7,Array(Len(aHeadC7)+1))
			For nX := 1 To Len(aHeadC7)
				aColsC7[Len(aColsC7)][nX] := CriaVar(aHeadC7[nX][2],.T.)
			Next nX
			aColsC7[Len(aColsC7)][Len(aHeadC7)+1] := .F.

			//ÃšÃ„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Â¿
			//Â³ Montagem das variaveis aHeadC8 e aColsC8 utilizada na integracao com PCO Â³
			//Ã€Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã™
			dbSelectArea("SX3")
			dbSetOrder(1)
			dbSeek("SC8")
			While ( !Eof() .And. SX3->X3_ARQUIVO == "SC8" )
				If ( X3Uso(SX3->X3_USADO) .And. cNivel >= SX3->X3_NIVEL )
					AADD(aHeadC8,{ TRIM(X3Titulo()),;
						SX3->X3_CAMPO,;
						SX3->X3_PICTURE,;
						SX3->X3_TAMANHO,;
						SX3->X3_DECIMAL,;
						SX3->X3_VALID,;
						SX3->X3_USADO,;
						SX3->X3_TIPO,;
						SX3->X3_ARQUIVO,;
						SX3->X3_CONTEXT } )
				EndIf
				dbSelectArea("SX3")
				dbSkip()
			EndDo

			AADD(aColsC8,Array(Len(aHeadC8)+1))
			For nX := 1 To Len(aHeadC8)
				aColsC8[Len(aColsC8)][nX] := CriaVar(aHeadC8[nX][2],.T.)
			Next nX
			aColsC8[Len(aColsC8)][Len(aHeadC8)+1] := .F.

		EndIf

		DEFINE MSDIALOG oDlg TITLE cCadastro FROM oSize:aWindSize[1],oSize:aWindSize[2] TO oSize:aWindSize[3],oSize:aWindSize[4] PIXEL

		ACTIVATE MSDIALOG oDlg ON INIT (A161Layer(oDlg, @aItens, @aPropostas, @aItensC, @cTpDoc ,@aButtons),Iif(Len(aItens) == 0, oDlg:End(), EnchoiceBar(oDlg,{||Iif(A161TOK(aPropostas, aItens, cTpDoc), (lOk := .T., aItens := aClone(aItens) ,aPropostas := aClone(aPropostas), oDlg:End()), .T.)},{|| A161RstFld(aPropostas), lOk := .F., oDlg:End()},,aButtons)))
		
		If lOk
			lOk := A161Venc(aPropostas)	// Valida se existe fornecedor marcado como vencedor 
		EndIf

		If lOk .AND. ExistBlock("MT161OK")
			lMT161Ok := ExecBlock("MT161OK",.F.,.F.,{aPropostas,cTpDoc})
			If ValType( lMT161Ok ) == "L"
				lOk := lMT161Ok
			EndIf
		EndIf
		
		If lOk
			For nY := 1 To Len(aPropostas)
				For nX := 1 To Len(aPropostas[nY])
						If Len(aPropostas[nY][nX][1]) > 0
							cCod := Iif(!Empty(aPropostas[nY][nx][1][1]), aPropostas[nY][nx][1][1], "    ")
							cLoja := Iif(!Empty(aPropostas[nY][nx][1][2]), aPropostas[nY][nx][1][2], "    ")
							If !Empty(cCod) .And. !Empty(cLoja)
								If SA2->(MsSeek(xFilial("SA2")+cCod+cLoja))
									If aScan(aPropostas[nY][nx][2],{|x| x[1] == .T.  }) > 0  .and. !RegistroOk("SA2",.F.) .and. ascan(afornece,cCod+cLoja) == 0
										cfornece += ENTER + cCod +"/"+cLoja
										aadd(afornece,cCod+cLoja)
										lblkForn := .T.
									Endif
								EndIf
							EndIf
						Endif
				Next nX
			Next nY
		nPosQtd 	    := AScan(aHeadAud, {|x| x[2] == "CE_QUANT"})
		nPosForn	    := AScan(aHeadAud, {|x| x[2] == "CE_FORNECE"})
		nPosLoja 	    := AScan(aHeadAud, {|x| x[2] == "CE_LOJA"})
		If lOk .AND. nPosQtd > 0 .AND.  nPosForn > 0 .AND.  nPosLoja > 0
			For nY := 1 To Len(aGravaAud)
				For nX := 1 To Len(aGravaAud[nY][2])
					If aGravaAud[nY][2][nX][nPosQtd] > 0
						If SA2->(MsSeek(xFilial("SA2")+aGravaAud[nY][2][nX][nPosForn]+ aGravaAud[nY][2][nX][nPosLoja]))
							If !RegistroOk("SA2",.F.) .and. ascan(afornece,aGravaAud[nY][2][nX][nPosForn]+aGravaAud[nY][2][nX][nPosLoja]) == 0
								cfornece += ENTER + aGravaAud[nY][2][nX][nPosForn] +"/"+ aGravaAud[nY][2][nX][nPosLoja]
								aadd(afornece,aGravaAud[nY][2][nX][nPosForn]+aGravaAud[nY][2][nX][nPosLoja])
								lblkForn := .T.
							Endif
						Endif
					Endif
				Next	
			Next
		Endif
			If lblkForn
				Help(,,STR0107,, STR0146, 1, 0,,,,,,{ STR0145 + cfornece})//'Impossível analisar a cotação, os fornecedores listados estão bloqueados, por favor execute o desbloqueio para executar esta operação'
				lOk := .F.
			EndIf
		EndIf

		If lOk
			For nX := 1 To Len(aItens)
				If aItens[nX,9] 
					lOk := .F.
				Else
					lOk := .T.
					Exit
				EndIf
			Next nX
		EndIf	

		If lOk
			If !FwIsInCallStack("MAPREPVIEW")
				nTpDoc := aScan(aItensC,{|x| x == cTpDoc})

				//Realiza metrica das cotações com produtos que possuem grade 
				If lGrade
					nQtdCot++
					ComMetrCot('totcot',nQtdCot)
				EndIf

				A161GerDoc(aItens,aPropostas,nTpDoc) //Efetua a geração do pedido de compra ou contrato.
				If Len(aGravaAud) > 0
					aGravaAud := {}
				EndIf
			EndIf
		Else
			If Type("aGravaAud") == "A" .And. Len(aGravaAud) > 0
				aGravaAud := {}
			EndIf
			lHistRst := .T.
		EndIf

		//ÃšÃ„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Â¿
		//Â³ Finaliza processo de lancamento do PCO                    Â³
		//Ã€Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã™
		PcoFinLan("000051")
		PcoFinLan("000052")
		PcoFreeBlq("000051")
		PcoFreeBlq("000052")
	EndIf
Else
	If !lRet .And. lLock .And. lMsg
		Help(,,"A161COTAUDIT",, STR0143, 1, 0,,,,,,{STR0144})//Cotação analisada pelo processo de auditoria e possui pedidos de compra em aberto. Exclua todos os pedidos de compra gerados, para analisar a cotação.
	ElseIf !lRet .And. !lGrade .And. lLock
		Help("",1,STR0140,,STR0141,1,0) //Está cotação possui produto com grade porém, o parâmetro MV_GRADE esta desabilitado. Habilite o parâmetro para prosseguir!
	ElseIf !lLock
		Help(,, "A161LOCK",, STR0139, 1, 0) //-- "Cotação em uso por outra thread!"
	EndIf
Endif

If lLock 
	//-- Liberar registro para uso
	UnlockByName("COT_" + cFilSC8 + cNumCot, .T., .F.)
Endif

SetKey( VK_F4,{||NIL} )
SetKey( VK_F5,{||NIL} )
SetKey( VK_F6,{||NIL} )
SetKey( VK_F7,{||NIL} )

RestArea(aArea)
RestArea(aAreaSC8)

Return Nil

Static Function A161Layer(oDlg, aItens, aPropostas, aItensC, cTpDoc, aButtons)

Local oFWLayer
Local oPanel0
Local oPanel1
Local oPanel2
Local oPanel3
Local oBrowse1
Local oBrowse2
Local oBrowse3
Local oVlrFinal
Local oVlrForn1
Local oVlrForn2

Local bBlocoPE		:= {|| }

Local aRetPE		:= {}
Local aCamposPE		:= {}
Local aCposProd		:= {}
Local aButtonUsr 	:= {}
Local aPropPE		:= {}

Local dDataVld		:= SC8->C8_VALIDA
Local cCotacao		:= SC8->C8_NUM

Local cFor1			:= ''
Local cFor2			:= ''
Local oFor1			:= NIL
Local oFor2			:= NIL
Local cCondPag1		:= SC8->C8_COND
Local cCondPag2		:= Space(30)
Local cTpFrete1		:= Space(30)
Local cTpFrete2		:= Space(30)

Local nVlrFinal		:= 0
Local nPag			:= 1
Local nNumPag		:= 0
Local nProp1		:= 0
Local nProp2		:= 0
Local nVlTot1		:= 0
Local nVlTot2		:= 0
Local nX			:= 0
Local nTamProp		:= 0
Local nTamProd		:= 0
Local nCol			:= 0

Local nPercent1
Local nPercent2
Local nAltura

Local lSugere
Local lIntGC   		:= SuperGetMv("MV_VEICULO",.F.,"N") == "S"

If Type("mvPAR03") == "U"
	Private mvPAR01
	Private mvPAR02
	Private mvPAR03
	Private mvPAR04
	Private mvPAR05
	Private mvPAR06
	Private mvPAR07
	xPergunte("MTA161",.F.)
EndIf

If ValType(mvPAR03) == "C"
	lSugere := .F.
Else
	lSugere := mvPAR03==1
EndIf

Setkey( VK_F4,{||A161HisPro(aItens[oBrowse1:At()][1])})
Setkey( VK_F5,{||A161MovPag(aPropostas, @oBrowse2, @oBrowse3, IIF(nPag > 1,--nPag,1), @cFor1, @nProp1, @cCondPag1, @cTpFrete1, @nVlTot1,@cFor2, @nProp2, @cCondPag2, @cTpFrete2, @nVlTot2, @oPanel3,oBrowse1)})
Setkey( VK_F6,{||A161MovPag(aPropostas, @oBrowse2, @oBrowse3, IIF(Len(aPropostas) <= nPag,nPag,++nPag), @cFor1, @nProp1, @cCondPag1, @cTpFrete1, @nVlTot1,@cFor2, @nProp2, @cCondPag2, @cTpFrete2, @nVlTot2, @oPanel3,oBrowse1)})
SetKey( VK_F7,{||A161HisForn(aPropostas[nPag][1][1][1],aPropostas[nPag][1][1][2])})
SetKey( VK_F8,{||A161HisForn(aPropostas[nPag][2][1][1],aPropostas[nPag][2][1][2])})

A161Prop(cCotacao, @aItens, @aPropostas, lIntGC) //Efetua a montagem do array para ser usado na interface do Mapa de Cotação

//-- Se nao houver nenhum item no mapa de cotação apresenta help e não montará a tela
If Len(aItens) == 0
	Help("",1,"A161LAYER",, STR0128, 4,1,,,,,,{STR0129}) //-- "Nenhum item da cotação foi considerado na análise!" "Verifique os parâmetros 'Do Produto?' e 'Até o Produto?'"
Else

	// Ponto de entrada para adicionar campos nas grids de dados das propostas dos fornecedores
	If ExistBlock("MT161CPO")
		nTamProp := Len(aPropostas[1,1,2,1])
		nTamProd := Len(aItens[1])
		aRetPE := ExecBlock("MT161CPO",.F.,.F.,{aPropostas,aItens})
		If ValType(aRetPE) == "A"
			aPropostas := aRetPE[1] 
			aCamposPE  := aRetPE[2]
			aItens     := aRetPE[3]
			aCposProd  := aRetPE[4]
		EndIf
	EndIf

	nNumPag := Len(aPropostas)

	oPanel0:= tPanel():New(0,0,,oDlg,,,,,,0,0)
	oPanel0:Align := CONTROL_ALIGN_ALLCLIENT

	// Cria instancia do fwlayer
	oFWLayer := FWLayer():New()

	// Inicializa componente passa a Dialog criada,o segundo parametro é para 
	// criação de um botao de fechar utilizado para Dlg sem cabeçalho 		  
	oFWLayer:Init(oPanel0,.F./*,.T.*/)

	oPanel0:ReadClientCoors(.T.,.T.)
	nAltura := oPanel0:nHeight

	nPercent1 := (210 * 100) / nAltura
	nPercent2 := 100 - nPercent1 

	// Efetua a montagem das linhas das telas
	oFWLayer:addLine("LINHA1",nPercent1,.T.)
	oFWLayer:addLine("LINHA2",nPercent2,.F.)

	// Efetua a montagem das colunas das telas
	oFWLayer:AddCollumn("BOX1",34,.T.,"LINHA1")
	oFWLayer:AddCollumn("BOX2",33,.T.,"LINHA1")
	oFWLayer:AddCollumn("BOX3",33,.T.,"LINHA1")

	oFWLayer:AddCollumn("BOX4",34,.T.,"LINHA2")
	oFWLayer:AddCollumn("BOX5",33,.T.,"LINHA2")
	oFWLayer:AddCollumn("BOX6",33,.T.,"LINHA2")

	// Cria a window passando, nome da coluna onde sera criada, nome da window			 	
	// titulo da window, a porcentagem da altura da janela, se esta habilitada para click,	
	// se é redimensionada em caso de minimizar outras janelas e a ação no click do split 
	oFWLayer:AddWindow("BOX1","oPanel1",STR0013	,100,.F.,.T.,,"LINHA1",{ || })//"Dados da Cotação"
	oFWLayer:AddWindow("BOX2","oPanel2",STR0014	,100,.F.,.T.,,"LINHA1",{ || })//"Dados da Proposta"
	oFWLayer:AddWindow("BOX3","oPanel3",STR0014	,100,.F.,.T.,,"LINHA1",{ || })//"Dados da Proposta"

	oFWLayer:AddWindow("BOX4","oPanel4",STR0016	,85,.F.,.T.,,"LINHA2",{ || })//"Produtos"
	oFWLayer:AddWindow("BOX5","oPanel5",STR0017	,85,.F.,.T.,,"LINHA2",{ || })//"Item da Proposta"
	oFWLayer:AddWindow("BOX6","oPanel6",STR0017	,85,.F.,.T.,,"LINHA2",{ || })//"Item da Proposta"

	// Retorna o objeto do painel da Janela
	oPanel1 := oFWLayer:GetWinPanel("BOX1","oPanel1","LINHA1")
	oPanel2 := oFWLayer:GetWinPanel("BOX2","oPanel2","LINHA1")
	oPanel3 := oFWLayer:GetWinPanel("BOX3","oPanel3","LINHA1")

	oPanel4 := oFWLayer:GetWinPanel("BOX4","oPanel4","LINHA2")
	oPanel5 := oFWLayer:GetWinPanel("BOX5","oPanel5","LINHA2")
	oPanel6 := oFWLayer:GetWinPanel("BOX6","oPanel6","LINHA2")

	// Dados da cotação
	@ 7,2 SAY RetTitle("C8_NUM") OF oPanel1 PIXEL
	@ 5,37 MSGET cCotacao SIZE 30,10 WHEN .F. OF oPanel1 PIXEL

	@ 27,2 SAY RetTitle("C8_VALIDA") OF oPanel1 PIXEL
	@ 25,37 MSGET dDataVld SIZE 50,10 WHEN .F. OF oPanel1 PIXEL

	@ 47,2 SAY STR0074  OF oPanel1 PIXEL //"Valor Final"
	@ 45,37 MSGET oVlrFinal VAR nVlrFinal SIZE 50,10 WHEN .F. PICTURE PesqPict("SC8","C8_TOTAL") OF oPanel1 PIXEL

	@ 7,96 SAY RetTitle("C8_TPDOC") OF oPanel1 PIXEL
	@ 5,120 MSCOMBOBOX cTpDoc ITEMS aItensC SIZE 68,14 WHEN aScan(aItens,{|x| x[9] == .F.  }) >0 OF oPanel1 PIXEL

	@ 27,96 SAY STR0019 OF oPanel1 PIXEL//'Página'
	@ 25,120 MSGET nPag SIZE 20,10 VALID nPag > 0 .And. nPag <= nNumPag .And. ;
				A161MovPag(aPropostas, @oBrowse2, @oBrowse3, nPag, @cFor1, @nProp1, @cCondPag1, @cTpFrete1, @nVlTot1,@cFor2, @nProp2, @cCondPag2, @cTpFrete2, @nVlTot2,@oPanel3,oBrowse1);
					OF oPanel1 PIXEL

	@ 27,143 SAY STR0020 OF oPanel1 PIXEL//'/'
	@ 25,148 MSGET nNumPag SIZE 20,10 WHEN .F. OF oPanel1 PIXEL

	TButton():Create(oPanel1,63,2,STR0021,{||A161HisPro(aItens[oBrowse1:At()][1])},85,13,,,,.T.,,STR0021,,,,)//STR0022//'Histórico do Produto (F4)'
	TButton():Create(oPanel1,45,120,STR0023,{|| A161MovPag(aPropostas, @oBrowse2, @oBrowse3, IIF(nPag > 1,--nPag,1), @cFor1, @nProp1, @cCondPag1, @cTpFrete1, @nVlTot1,@cFor2, @nProp2, @cCondPag2, @cTpFrete2, @nVlTot2, @oPanel3,oBrowse1 )},67,13,,,,.T.,,STR0023,,,,)//STR0024//'Página Anterior (F5)'
	TButton():Create(oPanel1,63,120,STR0025 ,{|| A161MovPag(aPropostas, @oBrowse2, @oBrowse3, IIF(Len(aPropostas) <= nPag,nPag,++nPag), @cFor1, @nProp1, @cCondPag1, @cTpFrete1, @nVlTot1,@cFor2, @nProp2, @cCondPag2, @cTpFrete2, @nVlTot2, @oPanel3,oBrowse1)},67,13,,,,.T.,,STR0025,,,,)//STR0026//'Próxima Página (F6)'

	// Dados do PRIMEIRO fornecedor na tela
		if !Empty(aPropostas[1][1][1])
			cFor1 		:= aPropostas[1][1][1][3]
			nProp1		:= aPropostas[1][1][1][4]
			cCondPag1	:= aPropostas[1][1][1][5]
			cTpFrete1	:= A161DscFrt(aPropostas[1][1][1][6])
			nVlTot1	:= aPropostas[1][1][1][7] 
		Else
			oPanel3:lVisible := .F.
			oPanel6:lVisible := .F.
			SetKey( VK_F8,{||NIL} )
		EndIf

	@ 7,2 SAY STR0027 OF oPanel2 PIXEL//'Fornecedor'
	@ 5,35 MSGET oFor1 VAR cFor1 SIZE 153,10 WHEN .F. OF oPanel2 PIXEL
	If(lLGPD,OfuscaLGPD(oFor1,"C8_FORNOME"),.F.)

	@ 27,2 SAY STR0028 OF oPanel2 PIXEL//'Proposta'
	@ 25,35 MSGET nProp1 SIZE 30,10 WHEN .F. OF oPanel2 PIXEL

	@ 47,2 SAY STR0029	OF oPanel2 PIXEL//'Tp. Frete'
	@ 45,35 MSGET cTpFrete1 SIZE 30,10 WHEN .F. OF oPanel2 PIXEL

	@ 27,90 SAY STR0030 OF oPanel2 PIXEL//'Cond. Pagto'
	@ 25,125 MSGET cCondPag1 SIZE 63,10 WHEN .F. OF oPanel2 PIXEL

	@ 47,90 SAY STR0031 OF oPanel2 PIXEL//'Vl. Total'
	@ 45,125 MSGET oVlrForn1 VAR nVlTot1 SIZE 63,10 WHEN .F. PICTURE PesqPict("SC8","C8_TOTAL") OF oPanel2 PIXEL

	TButton():Create(oPanel2,63,35,STR0032,{||A161HisForn(aPropostas[nPag][1][1][1],aPropostas[nPag][1][1][2])},153,13,,,,.T.,,STR0032,,,,)//STR0033//'Histórico do Fornecedor (F7)'

	// Dados do SEGUNDO fornecedor na tela
	If !Empty(aPropostas[1,2,1])
		cFor2 		:= aPropostas[1][2][1][3]
		nProp2		:= aPropostas[1][2][1][4]
		cCondPag2	:= aPropostas[1][2][1][5]
		cTpFrete2	:= A161DscFrt(aPropostas[1][2][1][6])
		nVlTot2	:= aPropostas[1][2][1][7]  
		SetKey(VK_F8,{||A161HisForn(aPropostas[nPag][2][1][1],aPropostas[nPag][2][1][2])})	
	Else
		oPanel3:lVisible := .F.
		oPanel6:lVisible := .F.
		SetKey( VK_F8,{||NIL} )
	EndIf

	@ 7,2 SAY STR0027 OF oPanel3 PIXEL//'Fornecedor'
	@ 5,35 MSGET oFor2 VAR cFor2 SIZE 153,10 WHEN .F. OF oPanel3 PIXEL
	If(lLGPD,OfuscaLGPD(oFor2,"C8_FORNOME"),.F.)

	@ 27,2 SAY STR0028 OF oPanel3 PIXEL//'Proposta'
	@ 25,35 MSGET nProp2 SIZE 30,10 WHEN	 .F. OF oPanel3 PIXEL

	@ 47,2 SAY STR0029	OF oPanel3 PIXEL//'Tp. Frete'
	@ 45,35 MSGET cTpFrete2 SIZE 30,10 WHEN .F. OF oPanel3 PIXEL

	@ 27,90 SAY STR0030 OF oPanel3 PIXEL//'Cond. Pagto'
	@ 25,125 MSGET cCondPag2 SIZE 63,10 WHEN .F. OF oPanel3 PIXEL

	@ 47,90 SAY STR0031 OF oPanel3 PIXEL//'Vl. Total'
	@ 45,125 MSGET oVlrForn2 VAR nVlTot2 SIZE 63,10 WHEN .F. PICTURE PesqPict("SC8","C8_TOTAL") OF oPanel3 PIXEL

	TButton():Create(oPanel3,63,35,STR0039,{||A161HisForn(aPropostas[nPag][2][1][1],aPropostas[nPag][2][1][2])},153,13,,,,.T.,,STR0039,,,,)//STR0040//'Histórico do Fornecedor (F8)'

	// Carga de dados dos produtos
	DEFINE FWBROWSE oBrowse1 DATA ARRAY ARRAY aItens NO CONFIG  NO REPORT NO LOCATE OF oPanel4

	ADD LEGEND DATA {|| IIf(oBrowse1:At() > 0 .And. oBrowse1:At() <= Len(aItens), !aItens[oBrowse1:At(),9], Nil)} COLOR "GREEN" TITLE STR0124 OF oBrowse1 //"Legenda - Item sem pedido gerado"
	ADD LEGEND DATA {|| IIf(oBrowse1:At() > 0 .And. oBrowse1:At() <= Len(aItens), aItens[oBrowse1:At(),9], Nil)} COLOR "RED" TITLE STR0125 OF oBrowse1 //"Legenda - Item com pedido gerado"
	If lIntGC
		ADD COLUMN oColumn DATA { || IIf(oBrowse1:At()  > 0 .and. oBrowse1:At() <= Len(aItens) , aItens[oBrowse1:At(),16] , Nil) } TITLE STR0133 HEADERCLICKÂ {Â ||Â .T.Â } OF oBrowse1 //"Grupo" 
		ADD COLUMN oColumn DATA { || IIf(oBrowse1:At()  > 0 .and. oBrowse1:At() <= Len(aItens) , aItens[oBrowse1:At(),17] , Nil) } TITLE STR0134 HEADERCLICKÂ {Â ||Â .T.Â } OF oBrowse1 //"Cod. Produto (GC)"
	EndIf
	ADD COLUMN oColumn DATA { || IIf(oBrowse1:At()  > 0 .and. oBrowse1:At() <= Len(aItens) , aItens[oBrowse1:At(),1] ,Nil) } TITLE STR0041 HEADERCLICKÂ {Â ||Â .T.Â } OF oBrowse1//"Cod. Produto"
	ADD COLUMN oColumn DATA { || IIf(oBrowse1:At()  > 0 .and. oBrowse1:At() <= Len(aItens) , aItens[oBrowse1:At(),8], Nil) } TITLE STR0042 	HEADERCLICKÂ {Â ||Â .T.Â }	OF oBrowse1//"Descrição"
	ADD COLUMN oColumn DATA { || IIf(oBrowse1:At()  > 0 .and. oBrowse1:At() <= Len(aItens) , aItens[oBrowse1:At(),3], Nil) } TITLE STR0043 PICTURE PesqPict("SC8","C8_QUANT") HEADERCLICKÂ {Â ||Â .T.Â } OF oBrowse1//"Quantidade"
	ADD COLUMN oColumn DATA { || IIf(oBrowse1:At()  > 0 .and. oBrowse1:At() <= Len(aItens) , aItens[oBrowse1:At(),4], Nil) } TITLE STR0044 HEADERCLICKÂ {Â ||Â .T.Â } OF oBrowse1//"UM"
	ADD COLUMN oColumn DATA { || IIf(oBrowse1:At()  > 0 .and. oBrowse1:At() <= Len(aItens) , aItens[oBrowse1:At(),5], Nil) } TITLE STR0045 HEADERCLICKÂ {Â ||Â .T.Â } OF oBrowse1//"Necessidade"
	ADD COLUMN oColumn DATA { || IIf(oBrowse1:At()  > 0 .and. oBrowse1:At() <= Len(aItens) , aItens[oBrowse1:At(),6], Nil) } TITLE STR0046 HEADERCLICKÂ {Â ||Â .T.Â } OF oBrowse1//"Entrega"
	ADD COLUMN oColumn DATA { || IIf(oBrowse1:At()  > 0 .and. oBrowse1:At() <= Len(aItens) , aItens[oBrowse1:At(),7], Nil) } TITLE STR0047 PICTURE PesqPict("SC8","C8_TOTAL") HEADERCLICKÂ {Â ||Â .T.Â } OF oBrowse1//"Valor Final"

	For nX := 1 To Len(aCposProd)
		If TAMSX3(aCposProd[nX])[3] == 'M'
			nCol := 12+nX
			ADD COLUMN oColumn DATA {||'Memo'} PICTURE '@!' TITLE RetTitle(aCposProd[nX]) SIZE 20 READVAR aCposProd[nX] HEADERCLICKÂ {Â ||Â .T.Â } DOUBLECLICK {|| ShowBMemo(@aPropostas[nPag,1,2], @oBrowse1)}   OF oBrowse1
		Else 
			bBlocoPE := &( "{ || IIf(oBrowse1:At()  > 0 .and. oBrowse1:At() <= Len(aItens) , aItens[oBrowse1:At()," + cValToChar(nTamProd+nX) + "],Nil )}" )
			ADD COLUMN oColumn DATA bBlocoPE TITLE RetTitle(aCposProd[nX]) HEADERCLICKÂ {Â ||Â .T.Â } OF oBrowse1
		EndIf
	Next nX

	oBrowse1:bOnMove := {|oBrowse,nMoveType,nCursorPos,nQtdLinha,nVisbleRow| A161OnMove(oBrowse,nMoveType,nCursorPos,nQtdLinha,nVisbleRow,oBrowse1,oBrowse2,oBrowse3)}
	oBrowse1:SetLineHeight(35) // Alterado para 35 para alinhar corretamente as linhas entre os 3 browses.

	ACTIVATE FWBROWSE oBrowse1

	// Carga de dados da primeira proposta na tela
	DEFINE FWBROWSE oBrowse2 DATA ARRAY ARRAY aPropostas[nPag,1,2] NO CONFIG  NO REPORT NO LOCATE OF oPanel5
	oBrowse2:AddMarkColumns( { || IIf(oBrowse2:At()  > 0 .and. oBrowse2:At() <= Len(aItens) , IIf( aPropostas[nPag,1,2,oBrowse2:At(),1],"AVGLBPAR1","" ) ,Nil)},;
								{ || IIf(oBrowse2:At()  > 0 .and. oBrowse2:At() <= Len(aItens) , A161DesMark(nPag,1,oBrowse2:At(),@aPropostas,@aItens,oBrowse1,oBrowse2,oBrowse3,.F.),Nil),;
																nVlrFinal:= A161CalTot(aPropostas),oVlrFinal:Refresh()},;
								{ || A161MarkAll(nPag,1,@aPropostas,@aItens,oBrowse1,oBrowse2,oBrowse3),;
																nVlrFinal:= A161CalTot(aPropostas),oVlrFinal:Refresh()})
																
	oBrowse2:AddMarkColumns( { || IIf(oBrowse2:At()  > 0 .and. oBrowse2:At() <= Len(aItens) , IIf( aPropostas[nPag,1,2,oBrowse2:At(),14],"S4WB013N","" ) ,Nil)})

	ADD COLUMN oColumn DATA { || IIf(oBrowse2:At()  > 0 .and. oBrowse2:At() <= Len(aItens) , aPropostas[nPag,1,2,oBrowse2:At(),13],0 )} PICTURE PesqPict("SC8","C8_PRECO") TITLE STR0101 SIZE 20 HEADERCLICKÂ {Â ||Â .T.Â } OF oBrowse2//'Preco Un'						    
	ADD COLUMN oColumn DATA { || IIf(oBrowse2:At()  > 0 .and. oBrowse2:At() <= Len(aItens) , IIf(!Empty(aPropostas[nPag,1,2,oBrowse2:At(),2]),Transform(aPropostas[nPag,1,2,oBrowse2:At(),4], PesqPict("SC8","C8_TOTAL")),''),Nil)} TITLE STR0048 SIZE 20 HEADERCLICKÂ {Â ||Â .T.Â } OF oBrowse2//'Valor Total'
	ADD COLUMN oColumn DATA { || IIf(oBrowse2:At()  > 0 .and. oBrowse2:At() <= Len(aItens) , aPropostas[nPag,1,2,oBrowse2:At(),5],Nil) } PICTURE PesqPict("SC8","C8_DATPRF") Type 'D' TITLE STR0046 SIZE 20 HEADERCLICKÂ {Â ||Â .T.Â } OF oBrowse2//'Entrega'
	ADD COLUMN oColumn DATA {||'Memo'} PICTURE '@!' TITLE RetTitle("C8_OBS") SIZE 20 READVAR "C8_OBS" HEADERCLICKÂ {Â ||Â .T.Â } DOUBLECLICK {|| ShowBMemo(@aPropostas[nPag,1,2], @oBrowse2)}   OF oBrowse2
	If nPosMotC8 > 0 .And. lMemoMotC8
		ADD COLUMN oColumn DATA {||'Memo'} PICTURE '@!' TITLE RetTitle("C8_MOTVENC") SIZE 20 READVAR "C8_MOTVENC" HEADERCLICKÂ {Â ||Â .T.Â } DOUBLECLICK {|| ShowBMemo(@aPropostas[nPag,1,2], @oBrowse2)}   OF oBrowse2 //-- "Motivo Venc."
	EndIf

	For nX := 1 To Len(aCamposPE)
		If TAMSX3(aCamposPE[nX])[3] == 'M' 
			nCol := 14+nX
			ADD COLUMN oColumn DATA {||'Memo'} PICTURE '@!' TITLE RetTitle(aCamposPE[nX]) SIZE 20 READVAR aCamposPE[nX] HEADERCLICKÂ {Â ||Â .T.Â } DOUBLECLICK {|| ShowBMemo(@aPropostas[nPag,1,2], @oBrowse2)}   OF oBrowse2
		Else 
			bBlocoPE := &( "{ || aPropostas[nPag,1,2,oBrowse2:At()," + cValToChar(nTamProp+nX) + "] }" )
			ADD COLUMN oColumn DATA bBlocoPE PICTURE PesqPict("SC8",aCamposPE[nX]) TITLE RetTitle(aCamposPE[nX]) SIZE 20 HEADERCLICKÂ {Â ||Â .T.Â } OF oBrowse2
		EndIf
	Next nX

	oBrowse2:bOnMove := {|oBrowse,nMoveType,nCursorPos,nQtdLinha,nVisbleRow| A161OnMove(oBrowse,nMoveType,nCursorPos,nQtdLinha,nVisbleRow,oBrowse1,oBrowse2,oBrowse3)}
	oBrowse2:SetLineHeight(35) // Alterado para 35 para alinhar corretamente as linhas entre os 3 browses.
	oBrowse2:SetBlkBackColor({||IIf(oBrowse2:At()  > 0 .and. oBrowse2:At() <= Len(aItens) ,  IIf(Empty(aPropostas[nPag,1,2,oBrowse2:At(),5]), CLR_LIGHTGRAY, Nil) ,Nil)})

	ACTIVATE FWBROWSE oBrowse2

	// Carga de dados da segunda proposta na tela
	DEFINE FWBROWSE oBrowse3 DATA ARRAY ARRAY aPropostas[nPag,2,2] NO CONFIG  NO REPORT NO LOCATE OF oPanel6
		oBrowse3:AddMarkColumns(	{ || IIf(oBrowse3:At()  > 0 .and. oBrowse3:At() <= Len(aItens),IIf( !Empty(aPropostas[nPag,2,2]) .And. aPropostas[nPag,2,2,oBrowse3:At(),1], "AVGLBPAR1",""),Nil) },;
									{ || A161DesMark(nPag,2,oBrowse3:At(),@aPropostas,@aItens,oBrowse1,oBrowse2,oBrowse3,.F.),;
																nVlrFinal:= A161CalTot(aPropostas), oVlrFinal:Refresh()},;
									{ || A161MarkAll(nPag,2,@aPropostas,@aItens,oBrowse1,oBrowse2,oBrowse3),;
																nVlrFinal:= A161CalTot(aPropostas), oVlrFinal:Refresh()})
																
		oBrowse3:AddMarkColumns(	{ || IIf(oBrowse3:At()  > 0 .and. oBrowse3:At() <= Len(aItens),IIf( !Empty(aPropostas[nPag,2,2]) .And. aPropostas[nPag,2,2,oBrowse3:At(),14], "S4WB013N",""),Nil) })

	ADD COLUMN oColumn DATA { || IIf(oBrowse3:At()  > 0 .and. oBrowse3:At() <= Len(aItens) , aPropostas[nPag,2,2,oBrowse3:At(),13],0 )} PICTURE PesqPict("SC8","C8_PRECO") TITLE STR0101 SIZE 20 HEADERCLICKÂ {Â ||Â .T.Â } OF oBrowse3//'Preco Un'															
	ADD COLUMN oColumn DATA { || IIf(oBrowse3:At()  > 0 .and. oBrowse3:At() <= Len(aItens),IIf(!Empty(aPropostas[nPag,2,2]) .And. !Empty(aPropostas[nPag,2,2,oBrowse3:At(),2]),Transform(aPropostas[nPag,2,2,oBrowse3:At(),4], PesqPict("SC8","C8_TOTAL")),''),Nil) } TITLE STR0048 SIZE 20 HEADERCLICKÂ {Â ||Â .T.Â } OF oBrowse3//'Valor Total'
	ADD COLUMN oColumn DATA { || IIf(oBrowse3:At()  > 0 .and. oBrowse3:At() <= Len(aItens),IIf(!Empty(aPropostas[nPag,2,2]),aPropostas[nPag,2,2,oBrowse3:At(),5],''),Nil) } PICTURE PesqPict("SC8","C8_DATPRF") Type 'D' TITLE STR0046 SIZE 20 HEADERCLICKÂ {Â ||Â .T.Â } OF oBrowse3//'Entrega'															
	ADD COLUMN oColumn DATA {||'Memo'} PICTURE '@!' TITLE RetTitle("C8_OBS") SIZE 20 READVAR "C8_OBS" HEADERCLICKÂ {Â ||Â .T.Â } DOUBLECLICK {|| ShowBMemo(@aPropostas[nPag,2,2], @oBrowse3)}   OF oBrowse3
	If nPosMotC8 > 0 .And. lMemoMotC8
		ADD COLUMN oColumn DATA {||'Memo'} PICTURE '@!' TITLE RetTitle("C8_MOTVENC") SIZE 20 READVAR "C8_MOTVENC" HEADERCLICKÂ {Â ||Â .T.Â } DOUBLECLICK {|| ShowBMemo(@aPropostas[nPag,2,2], @oBrowse3)}   OF oBrowse3 //-- "Motivo Venc."
	EndIf
	For nX := 1 To Len(aCamposPE)
		If TAMSX3(aCamposPE[nX])[3] == 'M'
			nCol := 14+nX
			ADD COLUMN oColumn DATA {||'Memo'} PICTURE '@!' TITLE RetTitle(aCamposPE[nX]) SIZE 20 READVAR aCamposPE[nX] HEADERCLICKÂ {Â ||Â .T.Â } DOUBLECLICK {|| ShowBMemo(@aPropostas[nPag,2,2], @oBrowse3)}   OF oBrowse3
		Else 
			bBlocoPE := &( "{ || aPropostas[nPag,2,2,oBrowse3:At()," + cValToChar(nTamProp+nX) + "] }" )
			ADD COLUMN oColumn DATA bBlocoPE PICTURE PesqPict("SC8",aCamposPE[nX]) TITLE RetTitle(aCamposPE[nX]) SIZE 20 HEADERCLICKÂ {Â ||Â .T.Â } OF oBrowse3
		EndIf
	Next nX

	oBrowse3:bOnMove := {|oBrowse,nMoveType,nCursorPos,nQtdLinha,nVisbleRow| A161OnMove(oBrowse,nMoveType,nCursorPos,nQtdLinha,nVisbleRow,oBrowse1,oBrowse2,oBrowse3)}
	oBrowse3:SetLineHeight(35) // Alterado para 35 para alinhar corretamente as linhas entre os 3 browses.
	oBrowse3:SetBlkBackColor({|| IIf(oBrowse3:At()  > 0 .and. oBrowse3:At() <= Len(aItens),IIf(Empty(aPropostas[nPag,2,2,oBrowse3:At(),5]), CLR_LIGHTGRAY, Nil),Nil) })

	ACTIVATE FWBROWSE oBrowse3

	// -----------------------------------------------------------------------
	// Sugestão do Vencedor
	// -----------------------------------------------------------------------
	If lSugere .And. !FwIsInCallStack("MAMAKEVIEW")
		If mvPAR05 == 0 .And. mvPAR06 == 0 .And. mvPAR07 == 0 
			Help("",1,"A161CotVen",,STR0084,4,1)	
		Else
			A161CotVen(@aItens, aPropostas, oBrowse1, oBrowse2, oBrowse3, cCotacao)
		EndIf
	EndIf

	If ExistBlock("MT161PRO")
		aPropPE := ExecBlock("MT161PRO",.F.,.F.,{aPropostas})
		If ( ValType(aPropPE) == "A" )
			aPropostas := aClone(aPropPE)
		EndIf
	EndIf

	//Valor Final
	nVlrFinal:= A161CalTot(aPropostas)

	//Valor Forn 1
	If !Empty(aPropostas[nPag,1,1])
		nVlTot1	:= aPropostas[nPag,1,1,7]
	Endif

	//Valor Forn 2
	If !Empty(aPropostas[nPag,2,1])
		nVlTot2	:= aPropostas[nPag,2,1,7]
	Endif

	oPanel1:Refresh()
	oPanel2:Refresh()
	oPanel3:Refresh()
	oVlrFinal:Refresh() // Atualiza o campo Valor Final.
	oVlrForn1:Refresh() // Atualiza o campo Valor Final.
	oVlrForn2:Refresh() // Atualiza o campo Valor Final.

	oBrowse1:Refresh(.F.) // .F. para nao posicionar no primeiro registro apos a atualizacao.
	oBrowse2:Refresh(.F.) // .F. para nao posicionar no primeiro registro apos a atualizacao.
	oBrowse3:Refresh(.F.) // .F. para nao posicionar no primeiro registro apos a atualizacao.

	If (ExistBlock("MA161BAR"))
		aButtonUsr := ExecBlock("MA161BAR",.F.,.F.,{aItens,oBrowse1})
		If (ValType(aButtonUsr) == "A")
			For nX := 1 To Len(aButtonUsr)
				Aadd(aButtons,aClone(aButtonUsr[nX]))
			Next nX
		EndIf
	EndIf
EndIf
//Inclusão do botão Auditoria 
aAdd(aButtons,{'CLIPS',{||A161Audit(oBrowse1,cTpDoc,aItens,aPropostas,oBrowse2,oBrowse3, lIntGC)},STR0116}) //"Auditoria"

Return Nil

//-------------------------------------------------------------------
/*{Protheus.doc} A161OnMove
Função responsavel por atualizar cursor nas linhas do Browser
@author antenor.silva
@since 28/10/2013
@version P11.90
*/
//-------------------------------------------------------------------
Function A161OnMove(oBrowse,nMoveType,nCursorPos,nQtdLinha,nVisbleRow,oBrowse1,oBrowse2,oBrowse3)

oBrowse1:OnMove(oBrowse1:oBrowse,nMoveType,nCursorPos,nQtdLinha,nVisbleRow)
oBrowse2:OnMove(oBrowse2:oBrowse,nMoveType,nCursorPos,nQtdLinha,nVisbleRow)
oBrowse3:OnMove(oBrowse3:oBrowse,nMoveType,nCursorPos,nQtdLinha,nVisbleRow)

Return Nil

//-------------------------------------------------------------------
/*{Protheus.doc} A161Prop
Efetua montagem do array de tens para a grid fixa e o array para as propostas.

@author José Eulálio
@since 28/10/2013
@version P11.90
*/
//-------------------------------------------------------------------
Static Function A161Prop(cNum, aItens, aPropostas, lIntGC)
Local nPag 			:= 1
Local nProp 		:= 1
Local nX 			:= 0
Local nSc8 			:= 0
Local nPg 			:= 0
Local nNumPro 		:= 0
Local nY 			:= 1
Local nPosRef1 		:= 0
Local nPosRef2 		:= 0
Local nCusto 		:= 0
Local nPosRef 		:= 0
Local nArmPg  		:= 0 // Controle do AScan.
Local nUltPag 		:= 0 // Ultima pagina utilizada por um fornecedor.
Local nUltPro 		:= 0 // Ultima proposta utilizada por um fornecedor.
Local nP     		:= 0
Local nR     		:= 0
Local nI     		:= 0
Local nPosId 		:= 0
Local lBlqCot		:= .F. // Bloqueia o iten na analise da cotação
Local aPedCot		:= {} // array contendo os itens que há pedido vinculado

Local cPgto			:= ''
Local cQuery		:= ''
Local cCodRef 		:= ''
Local cAtuPos 		:= ''
Local cMT161CIT		:= ''
Local cFilSB1		:= xFilial("SB1")
Local cFilSC1		:= xFilial("SC1")
Local lCotParc	    := SuperGetMv('MV_COTPARC',, .T.) // Habilita a analise da cotacao parcial.
Local lNped			:= .F.

Local lWin 			:= .F.
Local lWinAud 		:= .F.
Local lFim 			:= .F.

Local aRefImpos 	:= {}
Local aAreaSC8 		:= SC8->(GetArea())
Local aPags   		:= {} // Armazena a pagina e proposta utilizada para cada fornecedor.

Default lIntGC   	:= SuperGetMv("MV_VEICULO",.F.,"N") == "S"

xPergunte("MTA161",.F.)
SC8->(dbSetOrder(1))

//Query que retorna quantidade de propostas
BeginSQL Alias "SC8PRO"
	SELECT COUNT(C8_FORNECE) nNumPro  FROM (
		SELECT DISTINCT C8_FORNECE,C8_LOJA,C8_NUMPRO, C8_FORNOME
		FROM %Table:SC8%
		WHERE %NotDel% AND
			C8_FILIAL = %xFilial:SC8% AND
			C8_NUM = %Exp:cNum%) TMP
EndSQL
 
nNumPro := SC8PRO->nNumPro

SC8PRO->(dbCloseArea())

//Query que organiza as cotações para o Array
cQuery := "SELECT C8_PRODUTO, "
If lIntGC
	cQuery += " (SELECT B1_CODITE FROM " + RetSQLName("SB1") + " SB1AUX WHERE B1_FILIAL = '" + cFilSB1 + "' AND B1_COD = C8_PRODUTO AND SB1AUX.D_E_L_E_T_=' ') AS C8_CODITE, "
	cQuery += " (SELECT B1_GRUPO FROM " + RetSQLName("SB1") + " SB1AUX WHERE B1_FILIAL = '" + cFilSB1 + "' AND B1_COD = C8_PRODUTO AND SB1AUX.D_E_L_E_T_=' ') AS C8_CODGRP, "
EndIf
cQuery += "R_E_C_N_O_ SC8REC, "
cQuery += "C8_IDENT, "
cQuery += "C8_ITEMGRD, "
cQuery += "C8_NUMPRO, "
cQuery += "C8_QUANT, "
cQuery += "C8_UM, "
cQuery += "C8_DATPRF, "
cQuery += "C8_FILENT, "
cQuery += "C8_NUMPED, "
cQuery += "C8_NUMCON, "
cQuery += "C8_FORNECE, "
cQuery += "C8_LOJA, "
cQuery += "C8_ITEM, "
cQuery += "C8_NUM, "
cQuery += "C8_COND, "
cQuery += "C8_FORNOME, "
cQuery += "C8_TPFRETE, "
cQuery += "C8_PRAZO, "
cQuery += "C8_NUMSC, "
cQuery += "C8_ITEMSC, "
cQuery += "C8_GRADE, "
cQuery += "C8_PRECO "
cQuery += "FROM " + RetSQLName("SC8") + " "
cQuery += "WHERE D_E_L_E_T_ = ' ' AND "
cQuery += "C8_FILIAL = '" + xFilial("SC8") + "' AND "
cQuery += "C8_NUM = '" + cNum + "' "

//-- Quando não for para o sistema marcar os vencedores ou for para marcar e o critério da análise for por item, permite definir range de produtos
If !FwIsInCallStack("MAMAKEVIEW") .And. (MV_PAR03 == 2 .Or. (MV_PAR03 == 1 .AND. MV_PAR04 == 1)) 
	cQuery += " AND (C8_PRODUTO >= '" + MV_PAR01 + "' "
	cQuery += " AND C8_PRODUTO <= '" + MV_PAR02 + "') "
EndIf

If ExistBlock("MT161CIT")
	cMT161CIT := ExecBlock( "MT161CIT", .f., .f.)
	cQuery +=  IIF(VALTYPE(cMT161CIT) == 'C',cMT161CIT,'')
Endif

cQuery += "ORDER BY C8_IDENT, C8_PRODUTO, C8_NUMPRO, C8_FORNECE, C8_LOJA, C8_FORNOME"

cQuery := ChangeQuery(cQuery)

AtuForNome(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"SC8MAPA",.F.,.T.)

//Quantidade de páginas
nPg := Int(nNumPro / 2)
If Mod(nNumPro,2) > 0
	nPg++
EndIf

//Array para a ReferÃªncia do Imposto
aRefImpos := MaFisRelImp("MT161", {"SC8"})

/*------- Estrutura do Array de aItens --------*/

//aItens[n,x]: Numero do item
//aItens[n,1]: C8_PRODUTO
//aItens[n,2]: C8_IDENT
//aItens[n,3]: C8_QUANT
//aItens[n,4]: C8_ UM
//aItens[n,5]: C8_ DATPRF
//aItens[n,6]: C8_ FILENT
//aItens[n,7]: valor do produto por proposta escolhida
//aItens[n,8]: Descrição do Produto
//aItens[n,9]: Flag finalizado
//aItens[n,10]: Fornecedor
//aItens[n,11]: Loja
//aItens[n,12]: Item
//aItens[n,13]: Numero da proposta
//aItens[n,14]: Item da solicitacao
//aItens[n,15]: Preco Unitário
//aItens[n,16]: B1_CODITE [Integração Gestão de Concessionárias - MV_VEICULO = S]
//aItens[n,17]: B1_GRUPO  [Integração Gestão de Concessionárias - MV_VEICULO = S]

/*------- Estrutura do Array de aPropostas --------*/

//CABEÃ‡ALHO//
//aPropostas[n]			: Número da página
//aPropostas[n,p]		: Posição do pedido na página (1,2)
//aPropostas[n,p,1,x]	: Dados do cabeçalho da proposta 
//aPropostas[n,p,1,1 ]	: Cod Fornecedor 
//aPropostas[n,p,1,2 ]	: Loja 
//aPropostas[n,p,1,3 ]	: Nome 
//aPropostas[n,p,1,4 ]	: Proposta 
//aPropostas[n,p,1,5 ]	: Cond pagto 
//aPropostas[n,p,1,6 ]	: Frete 
//aPropostas[n,p,1,7 ]	: Valor total (soma de nCusto dos itens)
//ITENS DA PROPOSTA// 
//aPropostas[n,p,2,x]		: Itens da proposta 
//aPropostas[n,p,2,x,1]		: Flag vencendor (lWin)
//aPropostas[n,p,2,x,2]		: Item (SC8->C8_ITEM)
//aPropostas[n,p,2,x,3]		: Cod produto (SC8->C8_PRODUTO)
//aPropostas[n,p,2,x,4]		: Valor total (nCusto)
//aPropostas[n,p,2,x,5]		: Data de entrega ((DATE()+SC8->C8_PRAZO))
//aPropostas[n,p,2,x,6]		: Observações (SC8->C8_OBS)
//aPropostas[n,p,2,x,7]		: Filial Entrega (SC8->C8_FILENT)
//aPropostas[n,p,2,x,8]		: Flag finalizado (lFim) 
//aPropostas[n,p,2,x,9]		: Recno SC8 (SC8->(Recno()))
//aPropostas[n,p,2,x,10]	: Ident. (SC8->C8_IDENT)
//aPropostas[n,p,2,x,11]	: Total de Itens da Cotação (Len(aItens))
//aPropostas[n,p,2,x,12]	: Nro. da Proposta (SC8->C8_NUMPRO)
//aPropostas[n,p,2,x,13]	: Preco Unitario (SC8->C8_PRECO)
//aPropostas[n,p,2,x,14]	: Flag vencendor (lWinAud)
//aPropostas[n,p,2,x,15]	: Motivo Vencedor (SC8->C8_MOTVENC)

/*------- -------------------------------------- --------*/
//Adiciona Array com quantidade de páginas, propostas e cabeçalho e itens de proposta pra cada

If Empty(aPropostas) 
	aPropostas := Array(npg,2,2,0)
Else
	For nX := 1 To nPg	
		aAdd(aPropostas,{{{},{}},{{},{}}})
	Next nX
Endif


// Variaveis de controle da pagina e proposta na tela.
nPag    := 1
nProp   := 1
nUltPag := nPag
nUltPro := nProp

While SC8MAPA->(!EOF()) // verifica se há itens com pedido vinculado.
	
	If !Empty(SC8MAPA->C8_NUMPED)
		If !lCotParc // impede a geração de cotação parcial.
			lBlqCot := .T.// Bloqueia a analise da cotação de forma parcial (verifica se já houve análise parcial)
		Elseif ascan(aPedCot,SC8MAPA->C8_PRODUTO + SC8MAPA->C8_IDENT) == 0
			aadd(aPedCot,SC8MAPA->C8_PRODUTO + SC8MAPA->C8_IDENT)
		Endif
	Else
		lNped := .T.	
	Endif
SC8MAPA->(DbSkip())	
EndDo
SC8MAPA->(DbGoTop())
If lNped .AND. lBlqCot .and. !lCotParc
	Help(,,STR0057,, STR0147, 1, 0,,,,,,{ STR0148})//' "Cotação analisada parcialmente!" / "Para efetuar a análise do restante dessa cotação, ativar o parâmetro MV_COTPARC"
Endif
//Array de Itens na grid de Produtos
While SC8MAPA->(!EOF())
	
	//Quebra do While de Propostas
	cQuebra := SC8MAPA->(C8_PRODUTO)
	
	While !SC8MAPA->(EOF()) .And. SC8MAPA->(C8_PRODUTO) == cQuebra
		
	 	cProduto := SC8MAPA->C8_PRODUTO
				
		If SC8MAPA->C8_GRADE == 'S'
			MatGrdPrRf(@cProduto, .T.)
			
			cDesc := MaGetDescGrd(cProduto) //Recupera nome do produto
		Else
			
			cDesc := Posicione("SC1", 1, cFilSC1+SC8MAPA->C8_NUMSC+SC8MAPA->C8_ITEMSC, "C1_DESCRI")
			
			If lCotParc
				lBlqCot := ascan(aPedCot,SC8MAPA->C8_PRODUTO + SC8MAPA->C8_IDENT) > 0 
			Endif
		EndIf
		
		nPosPro := AScan(aItens, {|i| i[1] + i[2] == SC8MAPA->C8_PRODUTO + SC8MAPA->C8_IDENT})
		
		If nPosPro == 0
			
			If lIntGC
				AAdd(aItens, {SC8MAPA->(C8_PRODUTO), SC8MAPA->C8_IDENT, SC8MAPA->C8_QUANT, SC8MAPA->C8_UM, SToD(SC8MAPA->C8_DATPRF), SC8MAPA->C8_FILENT, 0, cDesc, lBlqCot, SC8MAPA->C8_FORNECE, SC8MAPA->C8_LOJA, SC8MAPA->C8_ITEM, SC8MAPA->C8_NUMPRO, SC8MAPA->C8_ITEMSC, SC8MAPA->C8_PRECO, SC8MAPA->C8_CODGRP, SC8MAPA->C8_CODITE,SC8MAPA->C8_ITEMGRD})
			Else
				AAdd(aItens, {SC8MAPA->(C8_PRODUTO), SC8MAPA->C8_IDENT, SC8MAPA->C8_QUANT, SC8MAPA->C8_UM, SToD(SC8MAPA->C8_DATPRF), SC8MAPA->C8_FILENT, 0, cDesc, lBlqCot, SC8MAPA->C8_FORNECE, SC8MAPA->C8_LOJA, SC8MAPA->C8_ITEM, SC8MAPA->C8_NUMPRO, SC8MAPA->C8_ITEMSC, SC8MAPA->C8_PRECO,SC8MAPA->C8_ITEMGRD})
			EndIf
		Else
				
			If aItens[nPosPro][10] == SC8MAPA->C8_FORNECE .And. !Empty(SC8MAPA->C8_FORNECE) .And. aItens[nPosPro][11] == SC8MAPA->C8_LOJA .And. !Empty(SC8MAPA->C8_LOJA) .And. aItens[nPosPro][13] == SC8MAPA->C8_NUMPRO
				If lIntGC
					AAdd(aItens, {SC8MAPA->(C8_PRODUTO), SC8MAPA->C8_IDENT, SC8MAPA->C8_QUANT, SC8MAPA->C8_UM, SToD(SC8MAPA->C8_DATPRF), SC8MAPA->C8_FILENT, 0, cDesc, lBlqCot, SC8MAPA->C8_FORNECE, SC8MAPA->C8_LOJA, SC8MAPA->C8_ITEM, SC8MAPA->C8_NUMPRO, SC8MAPA->C8_ITEMSC, SC8MAPA->C8_PRECO, SC8MAPA->C8_CODGRP, SC8MAPA->C8_CODITE,SC8MAPA->C8_ITEMGRD})
				Else
					AAdd(aItens, {SC8MAPA->(C8_PRODUTO), SC8MAPA->C8_IDENT, SC8MAPA->C8_QUANT, SC8MAPA->C8_UM, SToD(SC8MAPA->C8_DATPRF), SC8MAPA->C8_FILENT, 0, cDesc, lBlqCot, SC8MAPA->C8_FORNECE, SC8MAPA->C8_LOJA, SC8MAPA->C8_ITEM, SC8MAPA->C8_NUMPRO, SC8MAPA->C8_ITEMSC, SC8MAPA->C8_PRECO,SC8MAPA->C8_ITEMGRD})
				EndIf
			EndIf
			
		EndIf
		
		// Controle de paginas para o caso de produtos cotados somente para alguns fornecedores dentro da mesma cotacao.
		nArmPg := AScan(aPags, {|f| f[1] == SC8MAPA->C8_FORNECE .And. f[2] == SC8MAPA->C8_LOJA .And. f[5] == SC8MAPA->C8_NUMPRO .AND. f[6] == SC8MAPA->C8_FORNOME})
		
		If nArmPg == 0 .Or. (nArmPg > 0 .And. Empty(SC8MAPA->C8_FORNECE) .And. Empty(SC8MAPA->C8_LOJA) .AND. Empty(SC8MAPA->C8_FORNOME))
			
			nPag  := nUltPag
			nProp := nUltPro
			
			If !(nPag == 1 .And. Len(aPags) == 0)
				
				If nProp == 1
					
					nProp := 2
					
				Else
					
					nPag++
					
					nProp := 1
					
				EndIf
				
			EndIf
			
			AAdd(aPags, {SC8MAPA->C8_FORNECE, SC8MAPA->C8_LOJA, nPag, nProp, SC8MAPA->C8_NUMPRO, SC8MAPA->C8_FORNOME })
			
			nUltPag := nPag
			nUltPro := nProp
			
		Else
			
			nPag  := aPags[nArmPg][3] 
			nProp := aPags[nArmPg][4]
			
		EndIf
		
		//Adiciona posição no Array na primeira passagem
		If Empty(SC8MAPA->C8_ITEMGRD) .Or. SC8MAPA->C8_ITEMGRD == StrZero(1, Len(SC8MAPA->C8_ITEMGRD)) .and. SC8MAPA->C8_GRADE <> 'S'
			
			AAdd(aPropostas[nPag, nProp, 2], {})
			
		EndIf

		//Tratamento para Preenche Array de aPropostas
		SC8->(DbSetOrder(1))
		If SC8->(DbSeek(xFilial("SC8")+cNum+SC8MAPA->(C8_FORNECE+C8_LOJA+C8_ITEM+C8_NUMPRO+C8_ITEMGRD)))
		
			//Tratamento para quando possuir mais de um fornecedor novo na cotação
			If SC8->(Recno()) <> SC8MAPA->SC8REC
				SC8->(DbGoTo(SC8MAPA->SC8REC))
			Endif
			
			//Inicia o Valor
			lWin := .F.
			lFim := .F.
			lWinAud := .F.
			
			//Verifica se tem numero de pedido e marca como vencedor
			If !Empty(SC8->C8_NUMPED) .Or. !Empty(SC8->C8_NUMCON)
				
				//Marca como Finalizado
				lFim := .T.
				
				//Marca como Vencedor/Perdedor				
				If SC8->C8_NUMPED # Replicate('X', Len(SC8->C8_NUMPED)) .Or.;
					(SC8->C8_NUMCON # Replicate('X', Len(SC8->C8_NUMCON)) .And. !Empty(SC8->C8_NUMCON))
					
					If SC8->(FieldPos("C8_MARKAUD")) > 0 .And. SC8->C8_MARKAUD
						lWinAud := .T.
					Else
						lWin := .T.
					EndIf
					
				Else
					
					lWin := .F.
										
				EndIf
				
			EndIf
			
			//Calcula o Custo para o valor total do produto
			MaFisIni(SC8->C8_FORNECE, SC8->C8_LOJA, "F", "N", "R")
			MaFisIniLoad(1)
			
			For nY := 1 To Len(aRefImpos)
				
				MaFisLoad(aRefImpos[nY, 3], SC8->(FieldGet(FieldPos(aRefImpos[nY, 2]))), 1)
				
			Next nY
			
			MaFisEndLoad(1)
			
			nCusto := Ma160Custo("SC8",1)
			
			MaFisEnd()
			
			// Tratamento para adicionar cabeçalho somente uma vez
			If Empty(aPropostas[nPag, nProp, 1])
				
				//Recupera condição de pagamento
				cPgto := Posicione("SE4", 1, xFilial("SE4")+SC8->C8_COND, "E4_DESCRI")
				
				//Preenche Array do Cabeçalho
				aPropostas[nPag, nProp, 1] := {SC8->C8_FORNECE, SC8->C8_LOJA, SC8MAPA->C8_FORNOME, SC8->C8_NUMPRO, cPgto, SC8->C8_TPFRETE, 0}
				
			EndIf
			
			//Tratamento para Itens de Grade
			If SC8->C8_GRADE == 'S'
				
				cCodRef := SC8->C8_PRODUTO
				cFrnRef := SC8->C8_FORNECE
				cLojRef := SC8->C8_LOJA
				
				lReferencia := MatGrdPrRf(@cCodRef, .T.)
				
				//Caso exista Item de Grade, apenas soma nCusto ao produto existente na Proposta				
				If !Empty(aPropostas[nPag, nProp, 2]) .And. !Empty(aPropostas[nPag, nProp, 2, 1]) .And. Type("aPropostas[nPag, nProp, 2, 3]") <> 'U' .And. (nPosRef := AScan(aPropostas[nPag, nProp, 2], {|x| x[3] == cCodRef} )) > 0
					
					aPropostas[nPag, nProp, 2, nPosRef, 4] += nCusto
					
					//Soma nCusto no Valor total do Cabeçalho
					aPropostas[nPag, nProp, 1, 7] += nCusto
					
				Else
					
					//Preenche Array dos Produtos de cada proposta
					If nPosMotC8 > 0 .And. lMemoMotC8
						aadd(aPropostas[nPag, nProp, 2],{lWin,SC8->C8_ITEM, SC8->C8_PRODUTO, nCusto, (DATE()+SC8->C8_PRAZO), SC8->C8_OBS, SC8->C8_FILENT, lFim, SC8->(Recno()), SC8->C8_IDENT, Len(aItens), SC8->C8_NUMPRO, SC8->C8_PRECO,lWinAud, SC8->C8_MOTVENC,SC8->C8_ITEMGRD, .F.} )
					Else
						aadd(aPropostas[nPag, nProp, 2],{lWin,SC8->C8_ITEM, SC8->C8_PRODUTO, nCusto, (DATE()+SC8->C8_PRAZO), SC8->C8_OBS, SC8->C8_FILENT, lFim, SC8->(Recno()), SC8->C8_IDENT, Len(aItens), SC8->C8_NUMPRO, SC8->C8_PRECO,lWinAud, Nil,SC8->C8_ITEMGRD,.F.} )
					EndIf
					
					//Soma nCusto no Valor total do Cabeçalho
					aPropostas[nPag, nProp, 1, 7] += nCusto
					
				EndIf
				
			Else
				
				//Preenche Array dos Produtos de cada proposta
				If nPosMotC8 > 0 .And. lMemoMotC8					
					aTail(aPropostas[nPag, nProp, 2]) := {lWin,SC8->C8_ITEM, SC8->C8_PRODUTO, nCusto, (DATE()+SC8->C8_PRAZO), SC8->C8_OBS, SC8->C8_FILENT, lFim, SC8->(Recno()), SC8->C8_IDENT, Len(aItens), SC8->C8_NUMPRO, SC8->C8_PRECO,lWinAud, SC8->C8_MOTVENC," ", .F.} 
				Else
					aTail(aPropostas[nPag, nProp, 2]) := {lWin,SC8->C8_ITEM, SC8->C8_PRODUTO, nCusto, (DATE()+SC8->C8_PRAZO), SC8->C8_OBS, SC8->C8_FILENT, lFim, SC8->(Recno()), SC8->C8_IDENT, Len(aItens), SC8->C8_NUMPRO, SC8->C8_PRECO,lWinAud,Nil," ",.F.} 
				EndIf

				//Soma nCusto no Valor total do Cabeçalho
				aPropostas[nPag, nProp, 1, 7] += nCusto
		
			EndIf
			
	
		EndIf
		
		If lWin
			
			aItens[Len(aItens), 7] := aPropostas[nPag, nProp, 2, Len(aPropostas[nPag, nProp, 2]), 4]
			
		EndIf
		
		//Preenche variáveis para verificar se é uma proposta (fornecedor) diferente
		cAtuPos := SC8MAPA->(C8_FORNECE+C8_LOJA+C8_NUMPRO)
		
		//Skip para a próxima linha da busca
		SC8MAPA->(DbSkip())
		
	EndDo
		
EndDo

// Tratamento para incluir linhas em branco no array aProposta, pois podemos ter uma proposta com mais produtos do que a outra e itens que não pertencem a todas as propostas
For nP := 1 To Len(aPropostas)
	For nR := 1 To Len(aPropostas[nP])
		If Len(aPropostas[nP][nR][2]) < Len(aItens)
			aAux := {}
			// Varre o array de itens
			For nI := 1 To Len(aItens)
				//Busca pela posicao do item na proposta
				nPosId := AScan(aPropostas[nP, nR, 2], {|i| i[10] == aItens[nI][2]  })
				If nPosId > 0 //Caso encontre o item na proposta, adiciona no array auxiliar
					aAdd(aAux,aPropostas[nP, nR, 2, nPosId])
				Else// Caso nao encontre, adiciona uma linha em branco
					If nPosMotC8 > 0 .And. lMemoMotC8
						aAdd(aAux,{.F., aItens[nI][2] , aItens[nI][1], 0, CToD('//'), '', '', .F., 0, '', 0, '',IiF(Val(aItens[nI][4]) > 0,aItens[nI][15],0),.F.,''," ",.F.}) 
					Else
						aAdd(aAux,{.F., aItens[nI][2] , aItens[nI][1], 0, CToD('//'), '', '', .F., 0, '', 0, '',IiF(Val(aItens[nI][4]) > 0,aItens[nI][15],0),.F.,Nil," ",.F.}) 
					EndIf 
				EndIf
			Next nI
			//Substitui o array da proposta, pelo array organizado
			aPropostas[nP, nR, 2] := aClone(aAux)	
		EndIf
	Next nR
Next nP

SC8MAPA->(DbCloseArea())

SC8->(RestArea(aAreaSC8))

Return Nil

//-------------------------------------------------------------------
/*{Protheus.doc} A161GerDoc 
Função responsavel por gerar pedidos utilizando a função MaAvalCot
@param aItens Array de Itens da cotação
@param aPropostas Array de propostas da cotação
@author Leonardo Quintania
@since 29/10/2013
@version P11.90
*/
//-------------------------------------------------------------------
Function A161GerDoc(aItens,aPropostas,nTipDoc)
Local cAliasSC8		:= 'SC8'
Local cVencedor		:= ''
Local cSeek			:= ''
Local cNumCot		:= SC8->C8_NUM

Local nEvento 		:= 4
Local nSaveSX8  	:= GetSX8Len()
Local nX			:= 0
Local nY			:= 0
Local nZ			:= 0
Local nW			:= 0
Local nV			:= 0
Local nRet			:= 0
Local nItem			:= 0
Local nIProp		:= 0
Local nWin			:= 0

Local aAux			:= A161SemPag(aPropostas) //Retira o array de paginas deixando as propostas sequenciais
Local aSC8			:= {}
Local aWinProp		:= {}
Local aButtons		:= {}
Local aArea
Local aPedidos		:= {}		

Local lRet			:= .T.
Local lExit			:= .F.
Local lClicB		:= A131VerInt()

Local lMt161Cnt		:= ExistBlock("MT161CNT")   
Local lCntEsp		:= .F.
Local lGrade        := MaGrade()
Local lIdent		:= .F.

Private cCadastro	:= STR0052//'Cadastro de Fornecedores'
Private aHeadSCE	:= {}

SX3->(dbSetOrder(1))
SX3->(dbSeek("SCE"))
While !SX3->(Eof()) .And. SX3->X3_ARQUIVO == "SCE"
	If ( X3Uso(SX3->X3_USADO) .And. cNivel >= SX3->X3_NIVEL ) .Or. AllTrim(SX3->X3_CAMPO) == "CE_NUMPRO"
			AADD(aHeadSCE,{ TRIM(X3Titulo()),;
				Trim(SX3->X3_CAMPO),;
				SX3->X3_PICTURE,;
				SX3->X3_TAMANHO,;
				SX3->X3_DECIMAL,;
				SX3->X3_VALID,;
				SX3->X3_USADO,;
				SX3->X3_TIPO,;
				SX3->X3_ARQUIVO,;
				SX3->X3_CONTEXT } )
		Endif
	SX3->(dbSkip())
EndDo
//	Adiciona os campos de Alias e Recno
ADHeadRec("SCE",aHeadSCE)

//Preenchimento dos arrays aWinProp e aSC8 quando existe Auditoria

If Len(aHeadAud) > 0 .And. Len(aGravaAud) > 0
	nPosProd	:= AScan(aHeadAud, {|x| x[2] == "CE_PRODUTO"})
	nPosQtd 	:= AScan(aHeadAud, {|x| x[2] == "CE_QUANT"})
	nPosNum		:= AScan(aHeadAud, {|x| x[2] == "CE_NUMCOT"})
	nPosFor		:= AScan(aHeadAud, {|x| x[2] == "CE_FORNECE"})
	nPosLoja	:= AScan(aHeadAud, {|x| x[2] == "CE_LOJA"})
	nPosItem	:= AScan(aHeadAud, {|x| x[2] == "CE_ITEMCOT"})
	nPosProp	:= AScan(aHeadAud, {|x| x[2] == "CE_NUMPRO"})
	nPosItg		:= AScan(aHeadAud, {|x| x[2] == "CE_ITEMGRD"})
	nPosMot		:= AScan(aHeadAud, {|x| x[2] == "CE_MOTIVO"})
	nPosEnt		:= AScan(aHeadAud, {|x| x[2] == "CE_ENTREGA"})
	nPosReg		:= AScan(aHeadAud, {|x| x[2] == "CE_REGIST"})
	nPosAli     := AScan(aHeadAud, {|x| x[2] == "CE_ALI_WT"})
	nPosRec 	:= AScan(aHeadAud, {|x| x[2] == "CE_REC_WT"})
	nPosRgt		:= AScan(aHeadAud, {|x| x[2] == "CE_REGIST"})
	nPosMotAud	:= AScan(aHeadAud, {|x| x[2] == "CE_MOTVENC"})
EndIf

//Realiza preenchimento no array aSC8 para utilização na função MaAvalCOT.
For nX:= 1 To Len(aItens)
	If !aItens[nX,9]

		AADD(aSC8,{} 		)
		AADD(aWinProp,{}	)

		
		nItem 	:= Len(aSC8)
		nWin 	:= Len(aWinProp)
		
		For nY:= 1 To Len(aAux)	 //Array aPropostas desconsiderando paginas
			For nZ:= 1 To Len(aAux[nY,2]) //Array de Itens das aPropostas
				If aItens[nX,2] == aAux[nY,2,nZ,10]	//Verifico se existe proposta para o item posicionado
					SC8->(dbGoTo(aAux[nY,2,nZ,9])) //Posiciono no SC8 para verificar se o fornecedor está preenchido
					If aAux[nY,2,nZ,1] .Or. aAux[nY,2,nZ,14] //Verifico se foi marcado o item como vencedor
						cVencedor:= SC8->(C8_FORNECE+C8_LOJA)
						If Empty(cVencedor)//Se estiver em branco esse fornecedor é um participante e deve ser cadastrado como fornecedor
							aButtons:= {STR0053,STR0054,STR0055,STR0056} //STR0053,STR0054,STR0055,STR0056//'Sim'//'Não'//'Sim p/ Todos'//'Não p/ Todos'
							If nRet < 3 //'Sim','Não','Sim p/ Todos'
								nRet:= Aviso(STR0057,STR0058+ aAux[nY,2,nZ,2]	+' - '+ AllTrim(aAux[nY,2,nZ,3]) +' - '+AllTrim(aItens[nX,8])+STR0059+AllTrim(aAux[nY,1,3])+STR0060,aButtons,2)//'Atenção'//'O item '//' teve como ganhador um participante não cadastrado como fornecedor ('//'). Deseja cadastrá-lo agora? Em caso negativo, este item da cotação não será finalizado.'
							EndIf
							If nRet==1 .Or. nRet==3 //'Sim','Sim p/ Todos'
								lRet := A020CotFor()
								If lRet
									A161AtuCot(SC8->C8_FORNOME,SA2->A2_COD,SA2->A2_LOJA)
									cVencedor:= SA2->(A2_COD+A2_LOJA)
								EndIf
							Else					
								lRet:= .F.
							EndIf
						EndIf
					EndIf
					If lRet
						
						cRefer := SC8->C8_PRODUTO
						
						AADD(aSC8[nItem],{})
						nIProp := Len(aSC8[nItem])
							
						AADD(aSC8[nItem,nIProp],{'C8_ITEM'		, SC8->C8_ITEM		} )
						AADD(aSC8[nItem,nIProp],{'C8_NUMPRO'	, SC8->C8_NUMPRO	} )
						AADD(aSC8[nItem,nIProp],{'C8_PRODUTO'	, SC8->C8_PRODUTO	} )
						AADD(aSC8[nItem,nIProp],{'C8_COND'		, SC8->C8_COND		} )
						AADD(aSC8[nItem,nIProp],{'C8_FORNECE'	, SC8->C8_FORNECE	} )
						AADD(aSC8[nItem,nIProp],{'C8_LOJA'		, SC8->C8_LOJA		} )
						AADD(aSC8[nItem,nIProp],{'C8_NUM'		, SC8->C8_NUM		} )
						AADD(aSC8[nItem,nIProp],{'C8_ITEMGRD'	, SC8->C8_ITEMGRD	} )
						AADD(aSC8[nItem,nIProp],{'C8_NUMSC'		, SC8->C8_NUMSC		} )
						AADD(aSC8[nItem,nIProp],{'C8_ITEMSC'	, SC8->C8_ITEMSC	} )	
						AADD(aSC8[nItem,nIProp],{'C8_FILENT'	, SC8->C8_FILENT	} )				
						AADD(aSC8[nItem,nIProp],{'C8_DATPRF'	, SC8->C8_DATPRF	} )
						AADD(aSC8[nItem,nIProp],{'C8_OBS'		, aAux[nY, 2, nZ, 6]} )
						AADD(aSC8[nItem,nIProp],{'SC8RECNO'		, SC8->(Recno())	} )

						If !aAux[nY,2,nZ,8] //Flag de Finalizado
							aitem := array(Len(aHeadSCE)) 
				
							nPosCE 		:= AScan(aHeadSCE, {|x| x[2] == "CE_NUMPRO"})
							If nPosCE > 0
								aItem[nPosCE] := SC8->C8_NUMPRO
							EndIf
							
							nPosCE 		:= AScan(aHeadSCE, {|x| x[2] == "CE_QUANT"})
							If nPosCE > 0 
								If cVencedor == SC8->(C8_FORNECE+C8_LOJA) .And. aAux[nY,2,nZ,1] 			//Verifica se é o fornecedor vencedor posicionado
									aItem[nPosCE] := SC8->C8_QUANT
									cVencedor:= ''
									aAux[nY,2,nZ,1] :=.F.
								ElseIf cVencedor == SC8->(C8_FORNECE+C8_LOJA) .And. aAux[nY,2,nZ,14]
									For nW := 1 To Len(aGravaAud)
										If lGrade .and. !Empty(SC8->C8_ITEMGRD)       
											lIdent := alltrim(SC8->C8_ITEMGRD) == alltrim(aGravaAud[nW][3])
										Else
											lIdent := SC8->C8_IDENT == aGravaAud[nW][1]
										Endif
										If lIdent
											For nV := 1 To Len(aGravaAud[nW][2])
												If cVencedor == aGravaAud[nW][2][nV][nPosFor] + aGravaAud[nW][2][nV][nPosLoja] .And. SC8->C8_NUMPRO == aGravaAud[nW][2][nV][nPosProp] 
													aItem[nPosCE] := aGravaAud[nW][2][nV][nPosQtd]
													cVencedor:= ''
													aAux[nY,2,nZ,14] := .F.
													If nTipDoc == 1 //-- Só atualiza SC8 neste momento se for PC, para contratos as infos serão atualizadas dentro da transação pela função A161AtSC8
														If SC8->(FieldPos("C8_MARKAUD")) > 0
															RecLock("SC8",.F.)
																SC8->C8_MARKAUD  := .T.
															MsUnlock()
														EndIf
														If nPosMotAud > 0 .And. lMemoMotCE .And. nPosMotC8 > 0 .And. lMemoMotC8
															RecLock("SC8",.F.)
																SC8->C8_MOTVENC := aGravaAud[nW][2][nV][nPosMotAud]
															MsUnlock()
														EndIf
													EndIf
													Exit
												EndIf
											Next nV
										EndIf
									Next nW
								Else
									aItem[nPosCE]   := 0				 		 //CE_QUANT com quantidade zero para marcar XXXXXXXX
									cVencedor:= ''
								EndIf
							EndIf
							
							nPosCE := AScan(aHeadSCE, {|x| x[2] == "CE_FORNECE"})
							If nPosCE > 0
								aItem[nPosCE] := SC8->C8_FORNECE
							EndIf
							
							nPosCE := AScan(aHeadSCE, {|x| x[2] == "CE_LOJA"})
							If nPosCE > 0
								aItem[nPosCE] := SC8->C8_LOJA
							EndIf
							
							nPosCE := AScan(aHeadSCE, {|x| x[2] == "CE_MOTIVO"})
							If nPosCE > 0 
								aItem[nPosCE] := SC8->C8_MOTIVO
							EndIf

							nPosCE := AScan(aHeadSCE, {|x| x[2] == "CE_MOTVENC"})
							If nPosCE > 0 
								aItem[nPosCE] := SC8->C8_MOTVENC
							EndIf
							
							nPosCE := AScan(aHeadSCE, {|x| x[2] == "CE_ENTREGA"})
							If nPosCE > 0
								If mvPAR08 == 2
									aItem[nPosCE] := SC8->C8_DATPRF
								Else
									aItem[nPosCE] := (Date()+SC8->C8_PRAZO)
								EndIf
							EndIf
							
							nPosCE := AScan(aHeadSCE, {|x| x[2] == "CE_REGIST"})
							If nPosCE > 0
								aItem[nPosCE] := 0
							EndIf
							
							nPosCE := AScan(aHeadSCE, {|x| x[2] == "CE_ITEMGRD"})
							If nPosCE > 0
								aItem[nPosCE] := SC8->C8_ITEMGRD
							EndIf
					
							nPosCE := AScan(aHeadSCE, {|x| x[2] == "CE_ITEMCOT"})
							If nPosCE > 0 
								aItem[nPosCE] := SC8->C8_ITEM
							EndIf
							
							nPosCE := AScan(aHeadSCE, {|x| x[2] == "CE_NUMCOT"})
							If nPosCE > 0 
								aItem[nPosCE] := SC8->C8_NUM
							EndIf

							nPosCE := AScan(aHeadSCE, {|x| x[2] == "CE_ALI_WT"})
							If nPosCE > 0
								aItem[nPosCE] :=  'SC8'
							EndIf

							nPosCE := AScan(aHeadSCE, {|x| x[2] == "CE_REC_WT"})
							If nPosCE > 0
								aItem[nPosCE] := SC8->(Recno())							
							EndIf

							AADD(aWinProp[nWin],aItem )
						EndIf
					Else
						If nRet > 2 //'Sim p/ Todos','Não p/ Todos'
							Aviso(STR0061,STR0062+AllTrim(aAux[nY,1,3])+STR0063+ aAux[nY,2,nZ,2]	+' - '+ AllTrim(aAux[nY,2,nZ,3]) +' - '+AllTrim(aItens[nX,8])+STR0064,{STR0065})//'Atenção'//'O cadastro do participante '//' foi cancelado e a cotação do item '//' não será finalizada.'//'Ok'
						EndIf
						lExit:= .T.
					EndIf
				EndIf
				If lExit
					Exit
				EndIf
			Next nZ
			If lExit
				Exit
			EndIf	
		Next nY
	EndIf
Next nX

aArea := GetArea()
Begin Transaction

	If nTipDoc == 1
		//Pedido de Compra
		If lRet .And. Len(aSC8) > 0 .And. ( MaAvalCOT(cAliasSC8, nEvento, aSC8, aHeadSCE, aWinProp, iif(mvPAR08==2,.T.,.F.), Nil, {|| .T.},, aPedidos) ) //Executa função que gera pedidos de compra.
			EvalTrigger()
			While ( GetSX8Len() > nSaveSX8 )
				ConfirmSx8()		
			EndDo
		Else
			While ( GetSX8Len() > nSaveSX8 )
				RollBackSx8()
			EndDo
		EndIf          		
	Else
		
		If lRet 
			
			If lMt161Cnt
				lCntEsp := ExecBlock("MT161CNT",.F.,.F.,{aWinProp,cNumCot})  //Ponto de entrada para geracao do contrato via customização 
			EndIf 
			
			If !lCntEsp
				lRet := A161Cntr(aWinProp)
			EndIf
			
		EndIf	
		
		If lRet 
			While ( GetSX8Len() > nSaveSX8 )
					ConfirmSx8()		
			EndDo
		Else
			While ( GetSX8Len() > nSaveSX8 )
				RollBackSx8()
			EndDo
		EndIf
		
	EndIf 	
	
	SC8->(dbSetOrder(4))
	SC8->(dbSeek(xFilial("SC8")+cNumCot))
	
	While !SC8->(Eof()) .AND. SC8->C8_NUM == cNumCot
		RecLock("SC8",.F.)
			SC8->C8_TPDOC := CvalToChar(nTipDoc)
		MsUnlock()
		SC8->(dbSkip())
	EndDo
	
End Transaction

//Ponto de entrada para Workflow
If ExistBlock( "MT160WF" )
	SC8->(dbSetOrder(1))
	SC8->(dbSeek(xFilial("SC8")+cNumCot))
	ExecBlock( "MT160WF", .f., .f., { cNumCot } )
EndIf

If lClicB
	A311RegCot(cNumCot,2)
Endif

If Len(aPedidos) > 0
	ComAvCot(aPedidos) 
EndIf 

RestArea( aArea )

Return Nil

//-------------------------------------------------------------------
/*{Protheus.doc} A161SemPag
Função responsavel por desconsiderar numero de pagina no array de aProposta
@param aPropostas Array de propostas da cotação
@author Leonardo Quintania
@since 30/10/2013
@version P11.90
*/
//-------------------------------------------------------------------
Function A161SemPag(aPropostas)
Local aAux	:= {}
Local nX	:=	0
Local nY	:= 	0

For nX:= 1 To Len(aPropostas)

	For nY:= 1 To Len(aPropostas[nX])

		aAdd(aAux, aPropostas[nX,nY] )

	Next nY

Next nX

Return aAux

//-------------------------------------------------------------------
/*{Protheus.doc} A161HisForn
Função responsavel por trazer o histórico do fornecedor
@author antenor.silva
@since 30/10/2013
@version P11.90
*/
//-------------------------------------------------------------------
Function A161HisForn(cFornece,cLoja)
Local aArea	:= GetArea()

SA2->(dbSetOrder(1))
If SA2->(dbSeek(xFilial('SA2')+cFornece+cLoja))

	If xPergunte("FIC030",.T.) 	
		Finc030("Fc030Con")
	EndIf

	xPergunte("MTA161",.F.)		

EndIf

RestArea(aArea)

Return Nil

//-------------------------------------------------------------------
/*{Protheus.doc} 
Função responsavel por trazer o histórico do produto
@author antenor.silva
@since 30/10/2013
@version P11.90
*/
//-------------------------------------------------------------------
Function A161HisPro(cProduto)
Local aArea	:=	GetArea()
Local bVKF4	:=	Nil
Local bVKF5	:=	Nil
Local bVKF6	:=	Nil
Local bVKF7	:=	Nil
Local bVKF8	:=	Nil

MaFisSave()
MaFisEnd()

If !AtIsRotina("MACOMVIEW")
	If !Empty(cProduto)
		bVKF4 := SetKey( VK_F4, {|| NIL} )
		bVKF5 := SetKey( VK_F5, {|| NIL} )
		bVKF6 := SetKey( VK_F6, {|| NIL} )
		bVKF7 := SetKey( VK_F7, {|| NIL} )
		bVKF8 := SetKey( VK_F8, {|| NIL} )

		MaComView(cProduto)

		SetKey( VK_F4, bVKF4 )
		SetKey( VK_F5, bVKF5 )
		SetKey( VK_F6, bVKF6 )
		SetKey( VK_F7, bVKF7 )
		SetKey( VK_F8, bVKF8 )
	EndIf
EndIf

MaFisRestore()

RestArea(aArea)

Return Nil

//-------------------------------------------------------------------
/*{Protheus.doc} A161DesMark
Desmarcar as propostas na seleção
@param nPag Pagina da proposta Atual para desconsiderar da seleção
@param nProp Numero da proposta Atual para desconsiderar da seleção
@param nLinha Linha da proposta Atual 
@param aPropostas Array de Propostas disponivel
@author Leonardo Quintania
@since 28/10/2013
@version P11.90
*/
//-------------------------------------------------------------------
Static Function A161DesMark(nPag,nProp,nLinha,aPropostas,aItens,oBrowse1,oBrowse2,oBrowse3,lObs)
Local nX 		:= 0
Local nMarkVenc := 0
Local lRet		:= .T.
Local lPcoTot	:= .F.
Local lIntPCO	:= SuperGetMV("MV_PCOINTE",.F.,"2")=="1"

If lIntPCO
	lPcoTot   := PcoTotCot()
Endif

lMarkVenc := .F.

lRet := IIf(Type("aColsAud") == "A",A160VeriAud(aPropostas, oBrowse2:nAt,1),.F.)

If lRet
	If !lObs
		lMarkVenc := .T.
	EndIf
	
	If !Empty(aPropostas[nPag,nProp,2,nLinha,2])
		If aPropostas[nPag, nProp, 2, nLinha, 4] > 0
			If !aPropostas[nPag,nProp,2,nLinha,8] //Verifica se na linha selecionada existe algum flag de finalizado.
				aPropostas[nPag,nProp,2,nLinha,1]:= !aPropostas[nPag,nProp,2,nLinha,1]
				If lObs
					
					aPropostas[nPag,nProp,2,nLinha,6]:= AllTrim(aPropostas[nPag,nProp,2,nLinha,6]) // ENCERRADO AUTOMATICAMENTE
					
				EndIf
				If aPropostas[nPag,nProp,2,nLinha,1]
					aItens[nLinha,7] := aItens[nLinha,7] + aPropostas[nPag,nProp,2,nLinha,4]
					aItens[nLinha,10]:= aPropostas[nPag,nProp,1,1]
					aItens[nLinha,11]:= aPropostas[nPag,nProp,1,2]
				Else
					aItens[nLinha,7] := aItens[nLinha,7] - aPropostas[nPag,nProp,2,nLinha,4]
				EndIf				
				For nX :=1 To Len(aPropostas)
					If aPropostas[nX,1,2,nLinha,1] .Or. (!Empty(aPropostas[nX,2,2]) .And. aPropostas[nX,2,2,nLinha,1])
						If nX # nPag .Or. nProp == 2
							
							If aPropostas[nX,1,2,nLinha,1]
								aPropostas[nX,1,2,nLinha,1] := .F.
								aItens[nLinha,7] := aItens[nLinha,7] - aPropostas[nX,1,2,nLinha,4]
							EndIf
							
						EndIf
						If (nX # nPag .Or. nProp == 1) .And. !Empty(aPropostas[nX,2,2])
							
							If aPropostas[nX,2,2,nLinha,1]
								aPropostas[nX,2,2,nLinha,1] := .F.
								aItens[nLinha,7] := aItens[nLinha,7] - aPropostas[nX,2,2,nLinha,4]
							EndIf
							
						EndIf
					EndIf
				Next nX

				If lIntPCO
					SC8->(dbGoTo(aPropostas[nPag,nProp,2,nLinha,9]))
					SC1->(DbSetOrder(1))
					SC1->(dbSeek(xFilial("SC1")+SC8->(C8_NUMSC+C8_ITEMSC)))
					If !A161PcoVld(!aPropostas[nPag,nProp,2,nLinha,1],lPcoTot)
															
						aPropostas[nPag,nProp,2,nLinha,1] := .F.
						
						If aPropostas[nPag,nProp,2,nLinha,1]
							aItens[nLinha,7] := aItens[nLinha,7] + aPropostas[nPag,nProp,2,nLinha,4]
						Else
							aItens[nLinha,7] := aItens[nLinha,7] - aPropostas[nPag,nProp,2,nLinha,4]
						EndIf
						For nX :=1 To Len(aPropostas)
							If aPropostas[nX,1,2,nLinha,1] .Or. (!Empty(aPropostas[nX,2,2]) .And. aPropostas[nX,2,2,nLinha,1])
								If nX # nPag .Or. nProp == 2
									If aPropostas[nX,1,2,nLinha,1]
										aPropostas[nX,1,2,nLinha,1] := .F.
										aItens[nLinha,7] := aItens[nLinha,7] - aPropostas[nX,1,2,nLinha,4]
									EndIf
								EndIf
								If (nX # nPag .Or. nProp == 1) .And. !Empty(aPropostas[nX,2,2])
									If aPropostas[nX,2,2,nLinha,1]
										aPropostas[nX,2,2,nLinha,1] := .F.
										aItens[nLinha,7] := aItens[nLinha,7] - aPropostas[nX,2,2,nLinha,4]
									EndIf
								EndIf
							EndIf
						Next nX
				
					EndIf  
				EndIf
				
			EndIf
			
			For nX := 1 To Len(aItens)
				nMarkVenc += aItens[nX][7]
			Next nX
			 
			oBrowse1:Refresh(.F.) // .F. para nao posicionar no primeiro registro apos a atualizacao.
			oBrowse2:Refresh(.F.) // .F. para nao posicionar no primeiro registro apos a atualizacao.
			oBrowse3:Refresh(.F.) // .F. para nao posicionar no primeiro registro apos a atualizacao.
		Endif
	EndIf
EndIf

Return Nil

//-------------------------------------------------------------------
/*{Protheus.doc} A161MarkAll
Efetua a marcação de todos os itens da grid da proposta atual

@author Leonardo Quintania
@since 28/10/2013
@version P11.90
*/
//-------------------------------------------------------------------
Static Function A161MarkAll(nPag,nProp,aPropostas,aItens,oBrowse1,oBrowse2,oBrowse3)
Local nX := 0
Local lDesmark := .F.
Local lRet	:= .T.

If Type("aGravaAud") == "A" .And. Len(aGravaAud) > 0
	lRet := .F.
	Help("",1,STR0111,,STR0095,1,0) // "A161AUDPROC" - "Opção Marcar Todos indisponível, pois existe quantidade informada na Auditoria"
EndIf

If lRet
	For nX :=1 To Len(aPropostas[nPag,nProp,2])
		If !aPropostas[nPag,nProp,2,nX,1]
			lDesmark := .T.
		EndIf
	Next nX
	
	For nX :=1 To Len(aPropostas[nPag,nProp,2])	
		If !aPropostas[nPag,nProp,2,nX,8] .And. !Empty(aPropostas[nPag,nProp,2,nX,2])
			If lDesmark
				If !aPropostas[nPag,nProp,2,nX,1]
					A161DesMark(nPag,nProp,nX,@aPropostas,@aItens,oBrowse1,oBrowse2,oBrowse3,.F.)
				Endif
			Else
				If aPropostas[nPag,nProp,2,nX,1]
					A161DesMark(nPag,nProp,nX,@aPropostas,@aItens,oBrowse1,oBrowse2,oBrowse3,.F.)
				Endif
			Endif
		EndIf
	Next nX
	
	
	oBrowse1:Refresh(.F.)
	oBrowse2:Refresh(.F.)
	oBrowse3:Refresh(.F.)
EndIf

Return Nil

//-------------------------------------------------------------------
/*{Protheus.doc} A161CalTot
Calcula valor final total da analise da cotação

@author Leonardo Quintania
@since 28/10/2013
@version P11.90
*/
//-------------------------------------------------------------------
Static Function A161CalTot(aPropostas)
Local nX	 := 0
Local nY	 := 0
Local nZ	 := 0
Local nTotal := 0

Default aPropostas := {}

For nX := 1 To Len(aPropostas)
	For nY := 1 To Len(aPropostas[nX])	
		If Len(aPropostas[nX][nY][1]) > 0
			For nZ := 1 To Len(aPropostas[nX][nY][2])
				If aPropostas[nX,nY,2,nZ,1]
					nTotal += aPropostas[nX,nY,2,nZ,4]
				EndIf
			Next nZ
		EndIf
	Next nY
Next nX

Return nTotal

//-------------------------------------------------------------------
/*{Protheus.doc} A161MovPag
Altera a pagina de propostas da cotação
@author Antenor Silva
@since 28/10/2013
@version P11.90
*/
//-------------------------------------------------------------------
Function A161MovPag(aPropostas, oBrowse2, oBrowse3, nPagina, cFor1, nProp1, cCondPag1, cTpFrete1, nVlTot1, cFor2, nProp2, cCondPag2, cTpFrete2, nVlTot2,oPanel3,oBrowse1)
Local lTam	:= 0

If (Len(aPropostas) >= nPagina) .And. (nPagina > 0) 
 
	If !Empty(aPropostas[nPagina][1][1]) // Comentado, pois esta impedindo o avanco das paginas em alguns casos.
       		lTam := !Empty(aPropostas[nPagina,2,1])

		oBrowse2:SetArray(aPropostas[nPagina,1,2])
       		oBrowse2:Refresh(.F.) // .F. para nao posicionar no primeiro registro apos a atualizacao.
              	
		cFor1 		:= aPropostas[nPagina][1][1][3]
		nProp1		:= aPropostas[nPagina][1][1][4]
		cCondPag1	:= aPropostas[nPagina][1][1][5]
		cTpFrete1	:= A161DscFrt(aPropostas[nPagina][1][1][6])
		nVlTot1	:= aPropostas[nPagina][1][1][7] 
              
       If !lTam
			//Esconde o segundo browse
	       oPanel3:lVisible := .F.
	       oBrowse3:Hide()
	       SetKey(VK_F8,{||Nil})
       Else
	       oBrowse3:Show()
	       oPanel3:lVisible := .T.
			oBrowse3:SetArray(aPropostas[nPagina,2,2])
			oBrowse3:Refresh(.F.) // .F. para nao posicionar no primeiro registro apos a atualizacao.
			SetKey( VK_F8,{||A161HisForn(aPropostas[nPagina][2][1][1],aPropostas[nPagina][2][1][2])})	
	          	
	        cFor2 		:= aPropostas[nPagina][2][1][3]
			nProp2		:= aPropostas[nPagina][2][1][4]
			cCondPag2	:= aPropostas[nPagina][2][1][5]
			cTpFrete2	:= A161DscFrt(aPropostas[nPagina][2][1][6])
			nVlTot2	:= aPropostas[nPagina][2][1][7]    	            
       EndIf
       oBrowse1:Refresh(.F.) // .F. para nao posicionar no primeiro registro apos a atualizacao.
	EndIf 
       
EndIf 
Return Nil

//-------------------------------------------------------------------
/*{Protheus.doc} A161AtuCot
Função que efetua atualização com o numero do fornecedor que foi cadastrado
@param cForNome Nome do fornecedor participante
@param cNewFor Codigo do fornecedor que foi cadastrado 
@param cNewLoj Loja do fornecedor que foi cadastrado 
@author Leonardo Quintania
@since 28/10/2013
@version P11.90
*/
//-------------------------------------------------------------------
Static Function A161AtuCot(cForNome,cNewFor,cNewLoj)
Local cFornece:= CriaVar("C8_FORNECE",.F.)
Local aAreaSC8 := SC8->(GetArea())

BeginSQL Alias 'SC8TMP'
		
	SELECT R_E_C_N_O_ SC8RECNO
	FROM %Table:SC8% SC8
	WHERE SC8.%NotDel% AND
	SC8.C8_FILIAL = %xFilial:SC8% AND
	SC8.C8_FORNOME = %Exp:cForNome% AND
	SC8.C8_FORNECE = %Exp:cFornece%

EndSql

//Percorrer o resultado do select
While !SC8TMP->(EOF())
	SC8->(dbGoto(SC8TMP->SC8RECNO))
	RecLock("SC8",.F.)
	SC8->C8_FORNECE	:= cNewFor
	SC8->C8_LOJA		:= cNewLoj
	SC8->(MsUnlock())

	SC8TMP->(dbSkip())	
EndDo

SC8TMP->(dbCloseArea())

RestArea(aAreaSC8)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} A161Cntr()
Função para geração de Contrato a partir do Mapa de Cotação
@Param aWinProp Array com resultado das cotações para a geração do 
		contrato
@author Flavio Lopes Rasta 
@since 09/01/2014
@version 1.0
@return lRet
/*/
//-------------------------------------------------------------------
Function A161Cntr(aWinProp)
Local aArea := GetArea()
Local lRet		:= .T.
Local aDados	:= A161Oderna(aWinProp)
Local cTpPla	:= SuperGetMV("MV_TPPLA", .T., "")
Local nTpContr	:= 1	
Local nX := 0
Local nQtdContr	:= 0

If Len(aDados) > 0
	CNL->(dbSetOrder(1))
	If	Empty(cTpPla)
		Help("",1,"MV_TPPLA",,STR0066,4,1)	//" Parâmetro não Preenchido. É necessário preencher o parâmetro MV_TPPLA com um Tipo de Planilha válido para a geração dos contratos"
		lRet	:= .F.
	ElseIf CNL->( ! DbSeek(xFilial("CNL")+cTpPla) )
		Help("",1,STR0067,,STR0068,4,1)//"Planilha Inválida"//"É necessário preencher o parâmetro MV_TPPLA com um Tipo de Planilha válido para a geração dos contratos"
		lRet	:= .F.
	Else
		lRet := CNVldPlFixa(cTpPla)//Valida o tipo de planilha(necessariamente precisa ser Fixa)
	EndIf
	If lRet
		If Len(aDados) > 1
			nTpContr	:= Aviso(STR0069,STR0070,{STR0071,STR0072})//"Tipo do Contrato"//"Será gerado um contrato em Conjunto(todos os fornecedores) ou Individual(um por fornecedor)?"//"Conjunto"//"Individual"
		Endif
		Begin Transaction
			If nTpContr == 1 //Um unico contrato, com N planilhas
				If !(lRet := ExecCtrMdl(aDados))					
					DisarmTransaction()
				Endif
				nQtdContr++
			Else
				For nX:=1 To Len(aDados)//Um contrato por fornecedor
					If !(lRet := ExecCtrMdl({aDados[nX]}))			
						DisarmTransaction()
						Exit
					EndIf
					nQtdContr++
				Next				
			EndIf
		End Transaction
	EndIf
Else
	Help("", 1, STR0137,, STR0138, 1, 0) //-- "A161CNTR" - "Não há vencedores selecionados nesta análise!"
	lRet:= .F.
Endif

If nQtdContr > 0
	ComMetric('contr',nQtdContr)
Endif

RestArea( aArea )
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} A161Oderna()
Função para geração de Contrato a partir do Mapa de Cotação
@Param aWinProp Array com resultado das cotações para a geração do 
		contrato
@author Flavio Lopes Rasta 
@since 09/01/2014
@version 1.0
@return lRet
/*/
//-------------------------------------------------------------------
Function A161Oderna(aWinProp)

Local aWinners	:=	{}
Local aFornece	:=	{}
Local aDados		:=	{}
Local nPosQuant	:=  0
Local nPosForn	:=  0
Local nPosLoj		:=  0
Local cFornCor	 
Local cLojaCor
Local nX,nY

//Busca os Fornecedores vencedores da cotação
nPosQuant := AScan(aHeadSCE, {|x| x[2] == "CE_QUANT"})

For nX:=1 To Len(aWinProp)
	For nY:=1 To Len(aWinProp[nX])
		If aWinProp[nX][nY][nPosQuant] > 0
			AADD(aWinners,aWinProp[nX][nY])
		Endif
	Next	
Next

If Len(aWinners) > 0
	// Agrupa vencedores por fornecedor 
	For nX:=1 To Len(aWinners)
	    nPosForn	  := AScan(aHeadSCE, {|x| x[2] == "CE_FORNECE"})
	    nPosLoj	  := AScan(aHeadSCE, {|x| x[2] == "CE_LOJA"})
		cFornCor := aWinners[nX][nPosForn]		
		cLojaCor := aWinners[nX][nPosLoj]
		If aScan(aFornece,{|x| x[1]+x[2] == cFornCor+cLojaCor }) == 0
			Aadd(aDados,cFornCor)
			Aadd(aDados,cLojaCor)
			For nY:=1 To Len(aWinners)
				If cFornCor == aWinners[nY][nPosForn] .And. cLojaCor == aWinners[nY][nPosLoj]
					Aadd(aDados,aWinners[nY])
				Endif 
			Next
			Aadd(aFornece,aDados)
			aDados := {}
		Endif
	Next
Endif
	
Return aFornece

//-------------------------------------------------------------------
/*/{Protheus.doc} A161MdlCot()
Função para geração de Contrato a partir do Mapa de Cotação
@Param aWinProp Array com resultado das cotações para a geração do 
		contrato
@author Flavio Lopes Rasta 
@since 09/01/2014
@version 1.0
@return lRet
/*/
//-------------------------------------------------------------------
Function A161MdlCot(oModel300,aDados)

Local aArea		 := GetArea( )
Local aAreaSC1 	:= SC1->( GetArea( ) )
Local aServ		 := {}

Local cItem		 := Replicate("0", (TamSx3('CNB_ITEM')[1]))
Local cItPla	 := Replicate("0",(TamSx3('CNA_NUMERO')[1]))
Local cTpPla	 := SuperGetMV("MV_TPPLA", .T., "")
Local cItemRat	 := ""
Local cCpEntAdic := ""
Local cSeekCNZ	 := ""

Local lRateio	 := .F.
Local lItem 	 := .F.
Local lAddPlaSv  := .F.

Local nPosNumCot := AScan(aHeadSCE, {|x| x[2] == "CE_NUMCOT"})
Local nPosForn   := AScan(aHeadSCE, {|x| x[2] == "CE_FORNECE"})
Local nPosLoj	 := AScan(aHeadSCE, {|x| x[2] == "CE_LOJA"})
Local nPosItCot  := AScan(aHeadSCE, {|x| x[2] == "CE_ITEMCOT"})
Local nPosNPro   := AScan(aHeadSCE, {|x| x[2] == "CE_NUMPRO"})
Local nPosQuant  := AScan(aHeadSCE, {|x| x[2] == "CE_QUANT"})
Local nQtEntAdic := 0
Local nI 		 := 0
Local nX		 := 0
Local nY		 := 0
Local nW		 := 0

Local oCN9Master := oModel300:GetModel('CN9MASTER')
Local oCNADetail := oModel300:GetModel('CNADETAIL')
Local oCNBDetail := oModel300:GetModel('CNBDETAIL')
Local oCNCDetail := oModel300:GetModel('CNCDETAIL')
Local oCNZDetail := oModel300:GetModel('CNZDETAIL')

// Popula o modelo do contrato
oCN9Master:SetValue('CN9_ESPCTR',"1")//Contrato de Compra
oCN9Master:SetValue('CN9_DTINIC',dDataBase)
oCN9Master:SetValue('CN9_UNVIGE',"4")//Ideterminada
oCN9Master:SetValue('CN9_NUMCOT',SC8->C8_NUM)
cItPla	:= soma1(cItPla)

//Verifica se há entidades contábeis adicionais criadas no ambiente
nQtEntAdic := CtbQtdEntd()

For nX := 1 To Len(aDados)
	
	cItem	:= Replicate("0", (TamSx3('CNB_ITEM')[1]))
	cItem	:= soma1(cItem)
	
	If nX > 1
		CNTA300BlMd(oCNADetail, .F.)
		oCNCDetail:AddLine()
		oCNADetail:AddLine()
		cItPla	:= soma1(cItPla)
	Endif
	
	oCNCDetail:SetValue('CNC_CODIGO',aDados[nX][1])
	oCNCDetail:SetValue('CNC_LOJA',aDados[nX][2])
	oCNADetail:SetValue('CNA_FORNEC',aDados[nX][1])
	oCNADetail:SetValue('CNA_LJFORN',aDados[nX][2])
	oCNADetail:SetValue('CNA_TIPPLA',cTpPla)
	oCNADetail:SetValue('CNA_NUMERO',cItPla)

	lItem := .F.

	For nY:=3 To Len(aDados[nX])
	
		SC1->(dbSetOrder(1))
		SC8->(dbSetOrder(1))//C8_NUM+CO_FORNECE+C8_LOJA+C8_ITEM+C8_NUMPRO+C8_ITEMGRD
		SC8->(DbSeek(xFilial('SC8')+aDados[nX][nY][nPosNumCot]+aDados[nX][nY][nPosForn]+aDados[nX][nY][nPosLoj]+aDados[nX][nY][nPosItCot]+aDados[nX][nY][nPosNPro]))		    
	
		IF Posicione("SB5",1,xFilial("SB5")+ SC8->C8_PRODUTO,"B5_TIPO") <> '2'
			lItem := .T.
			If !Empty( oCNBDetail:GetValue('CNB_PRODUT') )
				CNTA300BlMd(oCNBDetail, .F.)
				oCNBDetail:AddLine()
				cItem	:= Soma1(cItem)
			EndIf		
		
			oCNBDetail:SetValue('CNB_ITEM',cItem)
			oCNBDetail:SetValue('CNB_PRODUT',SC8->C8_PRODUTO)
			oCNBDetail:SetValue('CNB_QUANT',aDados[nX][nY][nPosQuant])
			oCNBDetail:SetValue('CNB_NUMSC',SC8->C8_NUMSC)
			oCNBDetail:SetValue('CNB_ITEMSC',SC8->C8_ITEMSC)
			oCNBDetail:SetValue('CNB_VLUNIT',SC8->C8_PRECO)
			oCNBDetail:SetValue('CNB_VLTOTR',SC8->C8_TOTAL)
			oCNBDetail:SetValue('CNB_IDENT',SC8->C8_IDENT)
			oCNBDetail:SetValue('CNB_DESC',((SC8->C8_VLDESC/SC8->C8_TOTAL)*100))

			//Verifica se possui rateio
			SCX->(DbSetOrder(1))
			lRateio := SCX->(dbSeek(cSeekCNZ := xFilial("SCX")+SC8->(C8_NUMSC+C8_ITEMSC)))
		
			If lRateio
				cItemRat := Replicate("0", (TamSx3('CNZ_ITEM')[1]))
				While SCX->(!Eof()) .And. SCX->(CX_FILIAL+CX_SOLICIT+CX_ITEMSOL) == cSeekCNZ 
					If cItemRat <> Replicate("0", (TamSx3('CNZ_ITEM')[1]))
						oCNZDetail:AddLine()		
					EndIf
					cItemRat := Soma1(cItemRat)
							
					oCNZDetail:SetValue('CNZ_ITEM',cItemRat)
					oCNZDetail:SetValue('CNZ_PERC',SCX->CX_PERC)
					oCNZDetail:SetValue('CNZ_CC',SCX->CX_CC)
					oCNZDetail:SetValue('CNZ_CONTA',SCX->CX_CONTA)
					oCNZDetail:SetValue('CNZ_ITEMCT',SCX->CX_ITEMCTA)
					oCNZDetail:SetValue('CNZ_CLVL',SCX->CX_CLVL)
					
					//Se tem entidades contábeis adicionais criadas (por padrão, já existem 4 entidades no Protheus), então informa as mesmas para o contrato 
					If nQtEntAdic > 4
						For nI := 5 To nQtEntAdic
							cCpEntAdic := "EC" + StrZero( nI, 2 ) + "DB"
							oCNZDetail:SetValue( ( "CNZ_" + cCpEntAdic ), &( "SCX->CX_" + cCpEntAdic ) )
							
							cCpEntAdic := "EC" + StrZero( nI, 2 ) + "CR"
							oCNZDetail:SetValue( ( "CNZ_" + cCpEntAdic ), &( "SCX->CX_" + cCpEntAdic ) )
						Next nI
					EndIf
					
					SCX->(dbSkip())			
				EndDo			
			Else

				SC1->(dbSeek(xFilial("SC1")+SC8->(C8_NUMSC+C8_ITEMSC)))
				oCNBDetail:SetValue('CNB_CC',SC1->C1_CC)
				oCNBDetail:SetValue('CNB_CLVL',SC1->C1_CLVL)
				oCNBDetail:SetValue('CNB_CONTA',SC1->C1_CONTA)
				oCNBDetail:SetValue('CNB_ITEMCT',SC1->C1_ITEMCTA)
				
				//Se tem entidades contábeis adicionais criadas (por padrão, já existem 4 entidades no Protheus), então informa as mesmas para o contrato 
				If nQtEntAdic > 4
					For nI := 5 To nQtEntAdic
						cCpEntAdic := "EC" + StrZero( nI, 2 ) + "DB"
						oCNBDetail:SetValue( ( "CNB_" + cCpEntAdic ), &( "SC1->C1_" + cCpEntAdic ) )
						
						cCpEntAdic := "EC" + StrZero( nI, 2 ) + "CR"
						oCNBDetail:SetValue( ( "CNB_" + cCpEntAdic ), &( "SC1->C1_" + cCpEntAdic ) )
					Next nI
				EndIf
				
			EndIf	
		Else
			aAdd(aServ,{SC8->C8_PRODUTO,;
			aDados[nX][nY][nPosQuant],;
			SC8->C8_NUMSC,;
			SC8->C8_ITEMSC,;
			SC8->C8_PRECO,;
			SC8->C8_TOTAL,;
			SC8->C8_IDENT,;
			((SC8->C8_VLDESC/SC8->C8_TOTAL)*100)})	
		EndIf
					
	Next nY
	
	If !Empty(aServ)
		If lItem		
			cItPla := Soma1(cItPla)
		EndIf
		If Len(aDados[nX]) > 3
			For nY := 1 To oCNADetail:Length()
				oCNADetail:GoLine(nY)
				For nW := 1 To oCNBDetail:Length()
					oCNBDetail:GoLine(nW)
					If !(oCNBDetail:IsEmpty())
						CNTA300BlMd(oCNADetail, .F.)
						oCNADetail:AddLine()	
						oCNADetail:GoLine(oCNADetail:GetLine())
						lAddPlaSv := .T.
						Exit
					EndIf
				Next nW
				If lAddPlaSv
					Exit
				EndIf
			Next nY
		EndIf
		oCNADetail:SetValue('CNA_FORNEC',aDados[nX][1])
		oCNADetail:SetValue('CNA_LJFORN',aDados[nX][2])
		oCNADetail:SetValue('CNA_TIPPLA',cTpPla)
		oCNADetail:SetValue('CNA_NUMERO',cItPla)
		cItem:= Soma1(Replicate("0", (TamSx3('CNB_ITEM')[1])))
		For nY := 1 to Len(aServ)
			If nY > 1
				CNTA300BlMd(oCNBDetail, .F.)
				oCNBDetail:AddLine()
				cItem	:= soma1(cItem)
			Endif
			
			oCNBDetail:SetValue('CNB_ITEM',cItem)
			oCNBDetail:SetValue('CNB_PRODUT',aServ[nY][1])			
			oCNBDetail:SetValue('CNB_QUANT',aServ[nY][2])
			oCNBDetail:SetValue('CNB_NUMSC',aServ[nY][3])
			oCNBDetail:SetValue('CNB_ITEMSC',aServ[nY][4])
			oCNBDetail:SetValue('CNB_VLUNIT',aServ[nY][5])
			oCNBDetail:SetValue('CNB_VLTOTR',aServ[nY][6])
			oCNBDetail:SetValue('CNB_IDENT',aServ[nY][7])
			oCNBDetail:SetValue('CNB_DESC',aServ[nY][8])
			
			SCX->(DbSetOrder(1)) //CX_FILIAL+CX_SOLICIT+CX_ITEMSOL+CX_ITEM
			lRateio := SCX->(dbSeek(cSeekCNZ := xFilial("SCX")+aServ[nY][3]+aServ[nY][4]))
		
			If lRateio
				cItemRat := Replicate("0", (TamSx3('CNZ_ITEM')[1]))
				While SCX->(!Eof()) .And. SCX->(CX_FILIAL+CX_SOLICIT+CX_ITEMSOL) == cSeekCNZ 
					If cItemRat <> Replicate("0", (TamSx3('CNZ_ITEM')[1]))
						oCNZDetail:AddLine()		
					EndIf
					cItemRat := Soma1(cItemRat)
							
					oCNZDetail:SetValue('CNZ_ITEM',cItemRat)
					oCNZDetail:SetValue('CNZ_PERC',SCX->CX_PERC)
					oCNZDetail:SetValue('CNZ_CC',SCX->CX_CC)		
					oCNZDetail:SetValue('CNZ_CONTA',SCX->CX_CONTA)
					oCNZDetail:SetValue('CNZ_ITEMCT',SCX->CX_ITEMCTA)
					oCNZDetail:SetValue('CNZ_CLVL',SCX->CX_CLVL)
					
					//Se tem entidades contábeis adicionais criadas (por padrão, já existem 4 entidades no Protheus), então informa as mesmas para o contrato 
					If nQtEntAdic > 4
						For nI := 5 To nQtEntAdic
							cCpEntAdic := "EC" + StrZero( nI, 2 ) + "DB"
							oCNZDetail:SetValue( ( "CNZ_" + cCpEntAdic ), &( "SCX->CX_" + cCpEntAdic ) )
							
							cCpEntAdic := "EC" + StrZero( nI, 2 ) + "CR"
							oCNZDetail:SetValue( ( "CNZ_" + cCpEntAdic ), &( "SCX->CX_" + cCpEntAdic ) )
						Next nI
					EndIf
					
					SCX->(dbSkip())
				EndDo			
			Else
			
				SC1->(dbSeek(xFilial("SC1")+aServ[nY][3]+aServ[nY][4]))
				oCNBDetail:SetValue('CNB_CC',SC1->C1_CC)
				oCNBDetail:SetValue('CNB_CLVL',SC1->C1_CLVL)		
				oCNBDetail:SetValue('CNB_CONTA',SC1->C1_CONTA)
				oCNBDetail:SetValue('CNB_ITEMCT',SC1->C1_ITEMCTA)
				
				//Se tem entidades contábeis adicionais criadas (por padrão, já existem 4 entidades no Protheus), então informa as mesmas para o contrato 
				If nQtEntAdic > 4
					For nI := 5 To nQtEntAdic
						cCpEntAdic := "EC" + StrZero( nI, 2 ) + "DB"
						oCNBDetail:SetValue( ( "CNB_" + cCpEntAdic ), &( "SC1->C1_" + cCpEntAdic ) )
						
						cCpEntAdic := "EC" + StrZero( nI, 2 ) + "CR"
						oCNBDetail:SetValue( ( "CNB_" + cCpEntAdic ), &( "SC1->C1_" + cCpEntAdic ) )
					Next nI
				EndIf
				          																											
			EndIf	
		Next nY
		aServ:={}
	EndIf
	
Next nX

oCNADetail:GoLine(1)
oCNBDetail:GoLine(1) 
oCNCDetail:GoLine(1) 
oCNZDetail:GoLine(1) 

CN300BlqCot(oModel300)

RestArea( aAreaSC1 )	
RestArea( aArea )

Return oModel300

//-------------------------------------------------------------------
/*/{Protheus.doc} A161AtSC8()
Função para atualização da cotação
após geração do contrato
@Param aWinProp Array com resultado das cotações para a geração do 
		contrato
@author Flavio Lopes Rasta 
@since 09/01/2014
@version 1.0
@return lRet
/*/
//-------------------------------------------------------------------
Function A161AtSC8(aDados,cContrato)
	Local aArea 	 := GetArea()
	Local aAreaSC8	 := SC8->(GetArea())
	Local aAreaSCE	 := SCE->(GetArea())
	
	Local cChavSC8 	 := ""
	
	Local lRet 		 := .F.
	Local lMarkAud   := .F.
	Local lLog       := SuperGetMV("MV_HABLOG",.F.,.F.)
	
	Local nX 		 := 0
	Local nY 		 := 0
	Local nPosRec	 := aScan(aHeadSCE, {|x| x[2] == "CE_REC_WT"})
	Local nPosMkAud  := SC8->(FieldPos("C8_MARKAUD"))
	Local lGrade        := MaGrade()
	
	For nX := 1 To Len(aDados)
		For nY := 3 To Len(aDados[nX])
			//-- Posiciona no registro vencedor
			SC8->(DbGoTo(aDados[nX][nY][nPosRec]))
			
			cChavSC8 := SC8->C8_FILIAL + SC8->C8_NUM + SC8->C8_IDENT
			
			//-- Grava C8_NUMCON para registro vencedor e inibe utilização de C8_NUMPED
			RecLock("SC8",.F.)
				SC8->C8_NUMCON := cContrato
				SC8->C8_NUMPED := Replicate("X", Len(SC8->C8_NUMPED))
				SC8->(MsUnlock())

			//-- Avalia se o item tem auditoria para gravação da tabela SCE e o flag C8_MARKAUD
			If Len(aGravaAud) > 0
				If lGrade
					lMarkAud := (aScan(aGravaAud, {|x| x[3] == SC8->C8_PRODUTO}) > 0)
				Else
					lMarkAud := (aScan(aGravaAud, {|x| x[1] == SC8->C8_IDENT}) > 0)
				Endif
				If lMarkAud .And. nPosMkAud > 0
					RecLock("SC8",.F.)
						SC8->C8_MARKAUD  := .T.
					MsUnlock()
				EndIf
			EndIf

			//-- Gera tabela SCE
			A161AtSCE(lMarkAud)
			
			If lLog				
				RSTSCLOG("CTR", 4) //Log de inclusao de contrato via analise de cotacao
			EndIf

			//-- Percorre os demais registros da chave (não vencedores) e inibe a utilização de C8_NUMCON e C8_NUMPED
			SC8->(DbSetOrder(4)) //-- C8_FILIAL+C8_NUM+C8_IDENT+C8_PRODUTO
			If SC8->(MsSeek(cChavSC8, .T.))
				While SC8->(!Eof()) .And. (SC8->C8_FILIAL + SC8->C8_NUM + SC8->C8_IDENT == cChavSC8)
					If Empty(SC8->C8_NUMCON) .And. Empty(SC8->C8_NUMPED)
						RecLock("SC8",.F.)
							SC8->C8_NUMCON := Replicate("X", Len(SC8->C8_NUMCON))
							SC8->C8_NUMPED := Replicate("X", Len(SC8->C8_NUMPED))
						SC8->(MsUnlock())	
					EndIf
					SC8->(DbSkip())
				EndDo
			EndIf
		Next nY
	Next nX
	
	SC8->(RestArea(aAreaSC8))
	SCE->(RestArea(aAreaSCE))
	RestArea(aArea)

	FwFreeArray(aArea)
	FwFreeArray(aAreaSC8)
	FwFreeArray(aAreaSCE)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} A161DscFrt()
Função para descrever o frete
após geração do contrato

@author Flavio Lopes Rasta 
@since 22/07/2014
@version 1.0
@return lRet
/*/
//-------------------------------------------------------------------
Function A161DscFrt(cTpFrete)
	Local cRet:=""
	
	If cTpFrete == 'C'
		cRet := STR0075 //"CIF"
	ElseIf cTpFrete == 'F'
		cRet := STR0076 //"FOB"
	ElseIf cTpFrete == 'T'
		cRet := STR0077 //"Terceiros"
	ElseIf cTpFrete == 'R'
		cRet := STR0092 //"Remetente"
	ElseIf cTpFrete == 'D'
		cRet := STR0093 //"Destinat."
	ElseIf cTpFrete == 'S' .OR. Empty(cTpFrete)
		cRet := STR0078 //"Sem Frete"
	Endif

Return cRet

Static Function ShowBMemo(aItem, oBrowse)
Local oEditor 	:= nil
Local oDlMemo 	:= nil
Local nRecno 	:= aItem[oBrowse:NAT][9]
Local nPosMemo  := 0
Local cCpoMemo 	:= oBrowse:aColumns[oBrowse:GetColumn():nGridId]:cReadVar

Local cString := ""
Local cTxtAnt := ""

Local bOk     := {}
Local bCancel := {|| oDlMemo:End() }  

SC8->(DbGoto(nRecno))

cString := SC8->&(cCpoMemo)
cTxtAnt := SC8->&(cCpoMemo)

If cCpoMemo == 'C8_OBS'
    nPosMemo := 6 //-- Campo C8_OBS
Else
    nPosMemo := 15 //-- Campo C8_MOTVENC
EndIf

aItem[oBrowse:NAT][nPosMemo] := SC8->&(cCpoMemo)

bOk := {|| TRATAMOT(oDlMemo, @cString, nRecno, cTxtAnt, cCpoMemo), aItem[oBrowse:NAT][nPosMemo] := @cString}

cStrBMemo := cString

DEFINE MSDIALOG oDlMemo FROM 180, 180 TO 550, 700 TITLE 'MEMO' PIXEL 
	
	If Empty(SC8->C8_NUMPED) .And. !aItem[oBrowse:NAT][14]
		oEditor := tMultiget():new(30,0,{|u| if( pCount()>0,cString := u, cString)},oDlMemo,263,155,,,,,,.T.)
	Else
		oEditor := tMultiget():new(30,0,{|u| if( pCount()>0,cString := u, cString)},oDlMemo,263,155,,,,,,.T.,,,,,,.T.)
    EndIf
    
ACTIVATE MSDIALOG oDlMemo CENTERED ON INIT EnchoiceBar(oDlMemo, bOk, bCancel)

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} A161CotVen()
Sugestão da cotação vencedora

@author Mauricio.Junior
 
@since 09/06/2019
@version 1.0
@return Nil
/*/
//-------------------------------------------------------------------
Static Function A161CotVen(aItens, aPropostas, oBrowse1, oBrowse2, oBrowse3, cNumCot)

Local aScoreAux	 := {}
Local aPropBKP	 := {}

Local lAnProp	 := (MV_Par04 == 2)
Local lAnPropOk	 := .T.
Local lIntPCO	 := SuperGetMV("MV_PCOINTE",.F.,"2")=="1"

Default aItens 		:= {}
Default aPropostas 	:= {}
Default oBrowse1 	:= Nil
Default oBrowse2 	:= Nil 
Default oBrowse3 	:= Nil
Default cNumCot 	:= ""

aPropBKP := aClone(aPropostas)

If lAnProp
	A161AnProp(aItens, aPropostas, cNumCot, @aScoreAux, @lAnPropOk) //-- Analisa as propostas e as ordena em aScoreAux
	If lAnPropOk //-- Somente prosseguir com a marcação dos vencedores caso os critérios da análise por proposta estiverem atendidos
		A161MarkW(aPropostas,, aScoreAux, lAnProp, @aItens, lIntPCO)
	EndIf
Else
	A161AnIt(aItens, aPropostas, cNumCot) //-- Analista item a item e marca-o como vencedor na proposta correspondente	
EndIf

//-- Se houve integração PCO e tiver alguma falha no processo, restaura o aPropostas com os dados originais antes da análise automática salvos em aPropBKP
If lIntPCO .And. !lOkPCO 
	aPropostas := aClone(aPropBKP)
EndIf

If oBrowse1 <> Nil
	oBrowse1:Refresh(.F.)
EndIf
If oBrowse2 <> Nil
	oBrowse2:Refresh(.F.)
EndIf
If oBrowse3 <> Nil
	oBrowse3:Refresh(.F.)
EndIf

FwFreeArray(aScoreAux)
	
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} A161MinMax()
Verificação de máximos e minimo para todos os critérios avaliados
@Param cCampo 'C8_PRECO', 'C8_PRAZO','C8_NOTA'
@Param cNumCot Numero da cotação
@Param cIdent Identificador
@Param cForn fornecedor
@Param cProd Produto
@Param cLoja Loja
@author Jose.Delmondes
@since 12/11/2019
@version 1.0
@return aMinMax
/*/
Static Function A161MinMax(cCampo, cNumCot, cIdent, cForn, cProd, cLoja, lAnProp,cItGrd)

	Local cAliasQry := GetNextAlias()
	Local aMinMax 	:= {}
	Local lGrade    := MaGrade()
	Local cWhereAux := ""
     
	Default lAnProp := (MV_PAR04 == 2)
	Default cItGrd := ""

	cWhereAux := If(lGrade,"% And SC8.C8_ITEMGRD = '"+cItGrd+"'%","%%")
	cCampo := '%'+cCampo+'%'

	If lAnProp //-- Análise por proposta

		BeginSQL Alias cAliasQry
			
		SELECT 		MAX(%Exp:cCampo%) AS MAXIMO, 
					MIN(%Exp:cCampo%) AS MINIMO
		FROM 		%Table:SC8% SC8
		LEFT JOIN 	%Table:SA5% SA5
		ON 			SA5.A5_FILIAL 		= %xFilial:SA5%
					AND SA5.A5_FORNECE 	= SC8.C8_FORNECE
					AND SA5.A5_LOJA 	= SC8.C8_LOJA	
					AND SA5.A5_PRODUTO	= SC8.C8_PRODUTO
					AND SA5.%NotDel%
		WHERE 		SC8.C8_FILIAL 		= %xFilial:SC8% 
					AND SC8.C8_NUM		= %Exp:cNumCot%
					AND SC8.C8_PRECO 	> 0
					AND SC8.%NotDel%
		EndSQL	

	Else //-- Análise por item
	
		BeginSQL Alias cAliasQry
				
		SELECT 		MAX(%Exp:cCampo%) AS MAXIMO, 
					MIN(%Exp:cCampo%) AS MINIMO
		FROM 		%Table:SC8% SC8
		LEFT JOIN 	%Table:SA5% SA5
		ON 			SA5.A5_FILIAL 		= %xFilial:SA5%
					AND SA5.A5_FORNECE 	= SC8.C8_FORNECE
					AND SA5.A5_LOJA 	= SC8.C8_LOJA	
					AND SA5.A5_PRODUTO	= SC8.C8_PRODUTO
					AND SA5.%NotDel%
		WHERE 		SC8.C8_FILIAL 		= %xFilial:SC8% 
					AND SC8.C8_NUM		= %Exp:cNumCot%
					AND SC8.C8_IDENT 	= %Exp:cIdent% 
					AND SC8.C8_PRECO 	> 0		
					AND SC8.%NotDel%
			 		%Exp:cWhereAux%

		EndSQL

	EndIf

	If !(cAliasQry)->(EOF()) 
		aAdd(aMinMax, (cAliasQry)->MINIMO)
		aAdd(aMinMax, (cAliasQry)->MAXIMO)
	EndIf

	(cAliasQry)->(DbCloseArea())

Return aMinMax

//-------------------------------------------------------------------
/*/{Protheus.doc} A161DToI()
Conversão de Data pra Inteiro

@author guilherme.pimentel
 
@since 11/11/2015
@version 1.0
@return lRet
/*/
//-------------------------------------------------------------------

Function A161DToI(dDate)
Local nRet := 0
Local nDia := 0
Local nMes := 0
Local nAno := 0 

nDia := Day(dDate)
nMes := Month(dDate) * 30
nAno := Year(dDate) * 365

nRet := nDia + nMes + nAno

Return nRet

//-------------------------------------------------------------------
/*{Protheus.doc} A161PcoVld
Valida bloqueios na integracao com SIGAPCO

@author Carlos Capeli
@since 13/11/2015
@version P12.1.7
*/
//-------------------------------------------------------------------

Static Function A161PcoVld(lDeleta,lPcoTot)

Local aAreaAnt	:= GetArea()
Local lRetPCO	:= .T.
Local lRetorno	:= .T.
Default lDeleta  := .F.
Default lPcoTot  := .F.


Default lDeleta := .F.

// Verifica se Solicitacao de Compra possui rateio e gera lancamentos no PCO
SCX->(dbSetOrder(1))
If SCX->(MsSeek(xFilial("SCX")+SC1->(C1_NUM+C1_ITEM)))
	While SCX->(!Eof()) .And. SCX->(CX_FILIAL+CX_SOLICIT+CX_ITEMSOL) == xFilial("SCX")+SC1->(C1_NUM+C1_ITEM)

		lRetPCO := PcoVldLan('000051','03',,,lDeleta)	// Solicitacao de compras - Rateio por CC na cotacao
		If !lRetPCO
			lRetorno := .F.
		EndIf

		SCX->(DbSkip())
	End
EndIf

// Inclusao de pedido de compras por cotacao"
If lRetorno .And. !lPcoTot
	lRetPCO := PcoVldLan('000052','02',,,lDeleta)
	If !lRetPCO
		lRetorno := .F.
	EndIf
EndIf

RestArea(aAreaAnt)

Return lRetorno

/*--------------------------------------------
Trata o campo memo de observacao.
--------------------------------------------*/

Static Function TRATAMOT(oDlMemo, cTexto, nRecno, cTxtAnt, cCpoMemo)
Local aArea    	:= SC8->(GetArea())
Local lMot 		:= GetNewPar("MV_MOTIVOK",.F.)
Local lTracker	:= FwIsInCallStack("MATRKSHOW") 

If !lTracker
	SC8->(dbGoTo(nRecno))

	If RecLock("SC8",.F.)
		SC8->&(cCpoMemo) := cTexto
		SC8->(MsUnlock())
	Endif

	If lMot
		If Empty(cTexto)
			Help("", 1, STR0130,, STR0131, 1, 0) // "A161TRATAMOT" - "O campo Motivo Venc. deve ser informado!"
		Else
			oDlMemo:End()
		EndIf
	Else
		oDlMemo:End()
	EndIf

	RestArea(aArea)
EndIf

Return

/*--------------------------------------------
Valida a tela de analise da cotacao.
--------------------------------------------*/

Static Function A161TOK(aPropostas, aItens, cTpDoc)

Local aArea    := GetArea()
Local aAreaSc8 := SC8->(GetArea())

Local lRet    	:= .T.
Local lRetPE 	:= Nil
Local lMot 		:= GetNewPar("MV_MOTIVOK",.F.)
Local nTotPco   := 0

Local nP 		:= 0
Local nI 		:= 0
Local nH 		:= 0
LocaL nx		:= 0
Local CPcoVtot  := ""
Local lPcoTot   := PcoTotCot(@CPcoVtot) 
Local lIntPCO	:= SuperGetMV("MV_PCOINTE",.F.,"2")=="1"
Local lLog      := SuperGetMV("MV_HABLOG",.F.,.F.)
Local lTracker	:= FwIsInCallStack("MATRKSHOW")
Local cNumCot	:= SC8->C8_NUM

If !lTracker
	If lMot .And. nPosMotC8 > 0 //-- Quando MV_MOTIVOK estiver ativo, valida o preenchimento do campo C8_MOTVENC para todos os itens analisados
		For nP := 1 To Len(aPropostas)
			For nI := 1 To Len(aPropostas[nP])
				For nH := 1 To Len(aPropostas[nP][nI][2])
					SC8->(DbGoTo(aPropostas[nP, nI, 2, nH, 9]))
					lVencorig := aPropostas[nP, nI, 2, nH, 17] // verifica se foi vencedor pra nao abrir o help para preenchimento do campo C8_MOTVENC
					If !aPropostas[nP, nI, 2, nH, 8] .And. aPropostas[nP, nI, 2, nH, 1] .And. Empty(SC8->C8_MOTVENC) .And. !lVencorig
						lRet := .F.
						Exit
					EndIf
				Next nH
				If !lRet
					Exit
				EndIf
			Next nI
			If !lRet
				Exit
			EndIf
		Next nP
		If !lRet  
			Help("", 1, STR0113,, STR0091, 1, 0) // "A161MOTIVO" - "Houve mudanca manual do vencedor. Informe o campo Motivo Venc. da proposta."
		EndIf
	EndIf
EndIf

If lRet .and. lIntPCO .and. lPcoTot .and. Empty(aColsAud)

	// efetua a totalização do lancamento para o pco
	dbselectarea("SC8")
	SC8->(DbSetOrder(1))
	SC8->(DbGoTop())
	For nx := 1 to len(aitens)
		If aitens[nX][7] > 0  .AND. !aitens[nX][9] .AND. SC8->(DbSeek(xFilial("SC8")+cNumCot+aitens[NX][10]+aitens[nx][11]+aitens[nx][2]+aitens[nx][11]))
			nTotPco += &(CPcoVtot)
			
		Endif
	Next
	SC8->(DbGoTop())
	For nx := 1 to len(aitens) 	// atualiza o campo de lancamento do pco.
		If SC8->(DbSeek(xFilial("SC8")+cNumCot+aitens[NX][10]+aitens[nx][11]+aitens[nx][2]+aitens[nx][11]))
			RecLock("SC8",.F.)
			SC8->C8_TOTPCO := nTotPco
			MsUnlock()			
		Endif
	Next
	 
	If lRet // faz a chamada do lancamento de contingencia do PCO.
		SC1->(DbSetOrder(1))
		SC1->(dbSeek(xFilial("SC1")+SC8->(C8_NUMSC+C8_ITEMSC)))
		lRet := A161PcoVld(.f.,!lPcoTot)
		PcoFreeBlq('000052')

		IF !lRet
			SC8->(DbGoTop())
			For nx := 1 to len(aitens) 	// caso for cancelado a tela de lancamento, retorna os valores do C8_TOTPCO
				If SC8->(DbSeek(xFilial("SC8")+cNumCot+aitens[NX][10]+aitens[nx][11]+aitens[nx][2]+aitens[nx][11]))
					RecLock("SC8",.F.)
					SC8->C8_TOTPCO := 0
					MsUnlock()			
				Endif
			Next
		Endif
	Endif
Endif

//Ponto de entrada para validar se permite a analise da cotacao
If ExistBlock("MT161TOK")
	lRetPE := ExecBlock("MT161TOK",.F.,.F.,{aItens, aPropostas, aGravaAud, cTpDoc})
	If ValType(lRetPE) == "L"
		lRet := lRetPE
	EndIf
EndIf

If lRet .AND. lLog 
	RSTSCLOG("ANL",1,/*cUser*/)
EndIf

RestArea(aArea)
RestArea(aAreaSc8)

Return lRet

//-------------------------------------------------------------------
/*{Protheus.doc} AtuForNome(cQuery)
Ajusta o campo nome do fornecedor (C8_FORNOME), para cotacoes que 
vieram migradas da versão 11 
@author Leonardo Bratti
@since 28/08/2017
@version P12.1.16
*/
//-------------------------------------------------------------------

Static Function AtuForNome(cQuery)

Local aAreaSC8 := SC8->(GetArea())

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"SC8NMFOR",.F.,.T.)
While SC8NMFOR->(!EOF())
	If Empty(SC8NMFOR->(C8_FORNOME))
	 	If SC8->(DbSeek(xFilial("SC8")+SC8NMFOR->(C8_NUM+C8_FORNECE+C8_LOJA+C8_ITEM+C8_NUMPRO+C8_ITEMGRD)))
	 		RecLock("SC8",.F.)
				SC8->C8_FORNOME := Posicione("SA2",1,xFilial("SA2")+SC8NMFOR->(C8_FORNECE+C8_LOJA),"A2_NREDUZ")
			MsUnlock()
		Endif
	EndIf
	SC8NMFOR->(DbSkip())
EndDo
SC8NMFOR->(DbCloseArea())
SC8->(RestArea(aAreaSC8))

Return

//-------------------------------------------------------------------
/*{Protheus.doc} A161Audit()
Implementação da funcionalidade Auditoria.
@author Romulo Batista
@since 23/11/2018
@version P12.1.17
*/
//------------------------------------------------------------------
Function A161Audit(oBrowse1, cTpDoc, aItens, aPropostas, oBrowse2, oBrowse3, lIntGC)

Local aCabec 		:= {"",0,Array(31,2),Nil,Nil,Nil,Nil,Nil,Nil,Nil,Nil,Nil}		
Local lOk 			:= .F.
Local nIdItCot 		:= 0
Local nPosQuant 	:= 0
Local aAuditoria 	:= {}
Local nX 			:= 0
Local nZ 			:= 0
Local nW 			:= 0
Local nA			:= 0
Local nB			:= 0
Local nQuant     	:= oBrowse1:Data():aarray[oBrowse1:At()][3]
Local nSaldo		:= 0
Local nQtdAud		:= 0
Local nHistSld		:= 0
Local aCoors		:= FWGetDialogSize( oMainWnd )
Local aAux 			:= {}

Local nSuperior		:= aCoors[1] + 80
Local nEsquerda 	:= aCoors[2]
Local nInferior 	:= aCoors[3]
Local nDireita		:= aCoors[4]
Local lGrade        := MaGrade()

Local cItGRd		:= ""
Local cDelOk 		:= "AllwaysFalse"
Local cForAnt		:= ""

Local lRet 			:= .T.

Default lIntGC 		:= SuperGetMv("MV_VEICULO",.F.,"N") == "S"

If !FwIsInCallStack("MAMAKEVIEW")
	If Type("aGravaAud") != "A"
		lRet := .F.
	EndIf

	For nX := 1 To Len(aItens)
		If nX == oBrowse1:At() .And. aItens[nX,9]
			lRet := .F.
			Help("",1,STR0121,,STR0120,1,0)
		EndIf
	Next nX

	If lRet
		If MaMontaCot(@aCabec,,@aAuditoria)
		
			nPosQuant := aScan(aCabec[CAB_HFLD2],{|x| AllTrim(x[2]) == "CE_QUANT"} )

			If lGrade
				nIdItCot := aScan(aGravaAud,{|x| x[3] == oBrowse1:Data():aarray[oBrowse1:At()][16]})
			Else
				nIdItCot := aScan(aGravaAud,{|x| x[1] == oBrowse1:Data():aarray[oBrowse1:At()][2]})
			Endif

			If (nIdItCot) > 0
				aColsAud := aClone(aGravaAud[nIdItCot][2])
				For nX := 1 To Len(aColsAud)
					nSaldo += aColsAud[nX][nPosQuant]
				Next nX  
			Else
				If oBrowse1:At() > 0
					aColsAud   := aAuditoria[oBrowse1:At()] //Verificar o aItens[nX,9] e pegar o aAuditoria[Len(aAuditoria)]
				EndIf 
			EndIf
			
			//Montagem historico do saldo do item auditoria
			If Len(aHistSld) == 0
				For nX := 1 To Len(aItens)
					aAdd(aHistSld,{aItens[nX,1],{}})
				Next nX
			EndIf
			
			If !lHistRst .And. aScan(aGravaAud,{|x| x[1] == oBrowse1:Data():aarray[oBrowse1:At()][1]}) > 0
				For nX := 1 To Len(aHistSld)
					If aHistSld[nX,1] == oBrowse1:Data():aarray[oBrowse1:At()][1]
						nHistSld := aHistSld[nX,2,1]
					EndIf
				Next nX
			EndIf
			If !A160VeriAud(aPropostas, oBrowse2:nAt, 0)
				lRet := .F.
				Help("",1,STR0112,,STR0097,1,0)//"A161MARKVENC" - "Auditoria não poderá ser utilizada, pois existe proposta com vencedor marcado."
			EndIf
			
			If lRet
				If lGrade
					cSaldo := IIF(aScan(aGravaAud,{|x| x[3] == oBrowse1:Data():aarray[oBrowse1:At()][16]}) == 0, oBrowse1:Data():aarray[oBrowse1:At()][3], nHistSld)
				Else
					cSaldo := IIF(aScan(aGravaAud,{|x| x[1] == oBrowse1:Data():aarray[oBrowse1:At()][2]}) == 0, oBrowse1:Data():aarray[oBrowse1:At()][3], nHistSld)
				Endif

				Define MsDialog oAudit Title STR0116 From aCoors[1], aCoors[2] To aCoors[3], aCoors[4] Pixel
				
				// TFont   
				oTFont := TFont():New(STR0117,,10,.T.,.T.)
				oTFont1 := TFont():New(STR0117,,16,,.F.)
				
				aHeadAud := aCabec[CAB_HFLD2]
				oGetDad:= MsNewGetDados():New(nSuperior,nEsquerda,nInferior,nDireita,GD_INSERT+GD_UPDATE+GD_DELETE,/*cLinok*/,/*cTudoOk*/,/*cIniCpos*/,/*aAltera*/,/*nFreeze*/,Len(aColsAud),/*cFieldok*/,/*cSuperdel*/,cDelOk,oAudit,aHeadAud,aColsAud)
				oGetNumSc 	:= tGet():New( 40,05,{||oBrowse1:Data():aarray[oBrowse1:At()][1]}, oAudit, 096,015, "@!",,0,,,.F.,,.T.,,.F.,{||.F.},.F.,.F.,,.F.,.F.,,"cTGet1",,,,,.F.,,STR0086,2,oTFont,,,,.T. )//Produto
				oGetDescr 	:= tGet():New( 40,145,{||oBrowse1:Data():aarray[oBrowse1:At()][8]}, oAudit, 155,015, "@!",,0,,,.F.,,.T.,,.F.,{||.F.},.F.,.F.,,.F.,.F.,,"cTGet2",,,,,.F.,,STR0118,2,oTFont,,,,.T. )//Descricao
				oGetQtd 	:= tGet():New( 40,345,{||oBrowse1:Data():aarray[oBrowse1:At()][3]}, oAudit, 096,015, "@E 999999999.99",,0,,,.F.,,.T.,,.F.,{||.F.},.F.,.F.,,.F.,.F.,,"cTGet3",,,,,.F.,,STR0100,2,oTFont,,,,.T. ) //Quantidade
				oGetSld 	:= tGet():New( 40,520,{|| cSaldo}, oAudit,096,015, "@E 999999999.99",,0,,,.F.,,.T.,,.F.,{||.F.},.F.,.F.,,.F.,.F.,,"cSaldo",,,,,.F.,,STR0099,2,oTFont ) // Saldo
				
				If lIntGC
					oGetNumSc := tGet():New( 61,05,{||oBrowse1:Data():aarray[oBrowse1:At()][17]}, oAudit, 096,015, "@!",,0,,,.F.,,.T.,,.F.,{||.F.},.F.,.F.,,.F.,.F.,,"cTGet1",,,,,.F.,,STR0135,2,oTFont,,,,.T. )//Produto (GC)
				EndIf
				
				oAudit:bInit := {||EnchoiceBar(oAudit,{||lOk := A161TudAud(nQuant,oGetDad:aCols,aHeadAud,aPropostas,aItens,aHistSld,oBrowse1,oBrowse2,oBrowse3),IIF(lOk,oAudit:End(),)},{||oAudit:End()})}
				
				ACTIVATE MSDIALOG oAudit CENTER
				
				If lOk
					If nIdItCot > 0
						aGravaAud[nIdItCot][2] := aClone(oGetDad:aCols)
					Else
						If lGrade
							cItGRd := ALLTRIM(GetAdvFval("SC8","C8_ITEMGRD",xFilial("SC8") +SC8->C8_NUM+oBrowse1:Data():aarray[oBrowse1:At()][2]+oBrowse1:Data():aarray[oBrowse1:At()][1]   ,4))
							aAdd(aGravaAud,{oBrowse1:Data():aarray[oBrowse1:At()][2],aClone(oGetDad:aCols),cItGRd})							
						Else
							aAdd(aGravaAud,{oBrowse1:Data():aarray[oBrowse1:At()][2],aClone(oGetDad:aCols)})
						Endif
					EndIf
				Else
					If Len(aGravaAud) == 0
						lHistRst := .T.
					EndIf
				EndIf
				
				For nW := 1 To Len(aGravaAud)
					For nZ := 1 To Len(aGravaAud[nW][2])
						nQtdAud += aGravaAud[nW][2][nZ][nPosQuant]
					Next nZ
				Next nW
				If nQtdAud == 0
					aGravaAud := {}
				EndIf
			EndIF
		EndIf
	EndIf
EndIf

Return

//-------------------------------------------------------------------
/*{Protheus.doc} A161Audit()
Valida a quantidade digitada na Auditoria.
@author Romulo Batista
@since 23/11/2017
@version P12.1.17
*/
//------------------------------------------------------------------
Function A161TudAud(nQuant,aColsAud,aHeadAud,aPropostas,aItens,aHistSld,oBrowse1,oBrowse2,oBrowse3)

Local lRet     	  := .T.
Local lMvMotOk 	  := SuperGetMv("MV_MOTIVOK", .F., .F.)
Local nX 	      := 0
Local nQtdEnt	  := 0
Local nPosQuant   := aScan(aHeadAud,{|x| AllTrim(x[2]) == "CE_QUANT"} )
Local nPMotVnCE   := aScan(aHeadAud,{|x| AllTrim(x[2]) == "CE_MOTVENC"} )
Local lCEMotMemo  := Iif(nPMotVnCE > 0, AllTrim(aHeadAud[nPMotVnCE][8]) == "M", .F.)
Local aColsAudBkp := aColsAud	

Default nQuant := 0
Default aColsAud := {}

For nX := 1 To Len(aColsAud)
	nQtdEnt += aColsAud[nX][nPosQuant]
Next nX
 
If nQtdEnt <> 0 .And. nQtdEnt <> nQuant
	lRet := .F.
	Help("",1,STR0115,,STR0096,1,0) // "A161QTDAUD" - "Quantidade de entrega difere da quantidade da cotação."
EndIf

//-- Quando MV_MOTIVOK estiver ativo, deverá validar a digitação do campo CE_MOTVENC para todos os fornecedores participantes da auditoria
If lRet .And. lMvMotOk
	If nPMotVnCE == 0 .Or. !lCEMotMemo
		Help("", 1, STR0113,, STR0132, 1, 0) // "A161MOTIVO" - "O campo CE_MOTVENC não existe no ambiente ou não é do tipo MEMO e a validação do parâmetro MV_MOTIVOK não será realizada!"
	Else 
		For nX := 1 To Len(aColsAud)
			If aColsAud[nX][nPosQuant] > 0 .And. Empty(aColsAud[nX][nPMotVnCE])
				lRet := .F.
				Help("", 1, STR0113,, STR0091, 1, 0) // "A161MOTIVO" - "Houve mudanca manual do vencedor. Informe o campo Motivo Venc. da proposta."
				Exit
			EndIf
		Next nX
	EndIf
EndIf

If lRet
	a161IcoAud(aPropostas, nPosQuant, oBrowse2:nAt, .F.,aColsAudBkp) //reset and set audits cells
EndIf

oBrowse1:Refresh(.F.)
oBrowse2:Refresh(.F.)
oBrowse3:Refresh(.F.)

nQtdSldBkp := 0
Return lRet

//-------------------------------------------------------------------
/*{Protheus.doc} 
Faz o papel de apagar e incluir os fornecedores escolhidos por auditoria

@author GUSTAVO MANTOVANI CÂNDIDO
@since 18/04/2019
@version P12.25
*/
//-------------------------------------------------------------------
Function a161IcoAud(aPropostas, nPosQuant, nPosCotacao, lProposta, aColsAudBkp)
	
	Local aAreaSC8 	 := SC8->(GetArea())
	Local nLenAcols  := Len(aColsAudBkp)
	Local nX 		 := 0
	Local nY 		 := 0
	Local nZ 		 := 0
	Local nPosFor    := 0 
	Local nPosLoja   := 0
	Local nPosNumPro := 0
	Local nPosMtVncCE:= 0
	Local nPosMtVncC8:= IIf(Type("nPosMotC8") == "N", nPosMotC8, SC8->(FieldPos("C8_MOTVENC")))
	Local nPosMot    := 0
	
	nPosFor		:= aScan(aHeadAud, {|x| AllTrim(x[2]) == "CE_FORNECE"})
	nPosLoja	:= aScan(aHeadAud, {|x| AllTrim(x[2]) == "CE_LOJA"})
	nPosNumPro	:= aScan(aHeadAud, {|x| AllTrim(x[2]) == "CE_NUMPRO"})
	nPosMtVncCE	:= aScan(aHeadAud, {|x| AllTrim(x[2]) == "CE_MOTVENC"})
	nPosMot		:= aScan(aHeadAud, {|x| AllTrim(x[2]) == "CE_MOTIVO"})

	//-- aPropostas[n,p,1,1 ]	: Cod Fornecedor  	
	//-- aPropostas[n,p,1,2 ]	: Loja 
	//-- aPropostas[n,p,1,4 ]	: Proposta 
	
	For nX := 1 To nLenAcols
		If aColsAudBkp[nX][nPosQuant] > 0 .Or. !lProposta
			For nY := 1 To Len(aPropostas)
				For nZ := 1 To Len(aPropostas[nY])
					If Len(aPropostas[nY][nZ][1]) > 0
						If  aColsAudBkp[nX, nPosFor] == aPropostas[nY][nZ][1][1]; 
							.And. aColsAudBkp[nX, nPosLoja] == aPropostas[nY][nZ][1][2];
							.And. aColsAudBkp[nX, nPosNumPro] == aPropostas[nY][nZ][1][4]
							aPropostas[nY][nZ][2][nPosCotacao][14] := lProposta
							If nPosMtVncC8 > 0 .And. nPosMtVncCE > 0
								SC8->(DbGoTo(aPropostas[nY][nZ][2][nPosCotacao][9]))
								RecLock("SC8", .F.)
									SC8->C8_MOTVENC := aColsAudBkp[nX, nPosMtVncCE]
								SC8->(MsUnLock())
							EndIf
							If nPosMot > 0 .And. !Empty(aColsAudBkp[nX, nPosMot])
								SC8->(DbGoTo(aPropostas[nY][nZ][2][nPosCotacao][9]))
								RecLock("SC8", .F.)
									SC8->C8_MOTIVO := aColsAudBkp[nX, nPosMot]
								SC8->(MsUnLock())
							EndIf
						EndIf
					EndIf
				Next nZ
			Next nY
		EndIf
	Next nX

	If !lProposta
		a161IcoAud(aPropostas, nPosQuant, nPosCotacao, .T.,aColsAudBkp) //set audits cells
	EndIf

	RestArea(aAreaSC8)

Return

//-------------------------------------------------------------------
/*{Protheus.doc} 
Verifica se existe alguma auditoria naquele item.

@author GUSTAVO MANTOVANI CÂNDIDO
@since 18/04/2019
@version P12.25
*/
//-------------------A160VeriAud------------------------------------------------
Function A160VeriAud(APROPOSTAS, nPosCotacao,nType)
Local nLenAcols 	:= Len(aColsAud)
Local lRet 			:= .T.
Local lVerifyAud 	:= .F.
Local nX 			:= 0
Local nY 			:= 0
Local nZ 			:= 0
Local nTypeCot		:= IIF(nType == 0, 1, 14)

For nX := 1 to nLenAcols
	For nY := 1 To Len(aPropostas)
		For nZ := 1 To Len(aPropostas[nY])
			If aPropostas[nY][nZ][2][nPosCotacao][nTypeCot]
				lVerifyAud := .T.
				Exit
			EndIf
		Next nZ
	Next nY
Next nX
lRet := !lVerifyAud
Return lRet

//-------------------------------------------------------------------
/*{Protheus.doc} 
Calcula valor total da analise da cotação

@author Romulo Batista
@since 18/04/2019
@version P12.25
*/
//-------------------------------------------------------------------
Function A161CalSal(oGetSld,oGetQtd,aHeadAud)

Local nQuant  := IIF(Type("M->CE_QUANT") == "N" ,M->CE_QUANT, 0)
Local nSldRst := 0
Local nSldTot := 0
Local nX  := 0
Local nQtdSld := 0
Local nPosQAud   := aScan(aHeadAud,{|x| AllTrim(x[2]) == "CE_QUANT"} )
Local nPosProd   := aScan(aHeadAud,{|x| AllTrim(x[2]) == "CE_PRODUTO"} )

nSldTot := oGetQtd:cText

If Len(aCols) > 0
	For nX := 1 To Len(aCols)
		If nX == oGetDad:nAt .And. aCols[nX,nPosQAud] <>  nQuant
			nSldRst += nQuant
		Else	
			nSldRst += aCols[nX,nPosQAud]
		EndIf
	Next nX
EndIf

nQtdSld  := nSldTot - nSldRst

If nQtdSld < 0
	M->CE_QUANT := aCols[oGetDad:nat,nPosQAud]
Else
	cSaldo := nQtdSld
	oGetSld:refresh()
	For nX := 1 To Len(aHistSld)
		If aHistSld[nX,1] == aCols[oGetDad:nat, nPosProd]
			If Len(aHistSld[nX]) < 2
				aAdd(aHistSld[nX],{nQtdSld})
			Else
				aAdd(aHistSld[nX,2], nQtdSld)
			EndIf
		EndIf
	Next nX 
	lHistRst 	:= .F.
	nQtdSldBkp 	:= nQtdSld
EndIf

Return .T. 

//-------------------------------------------------------------------
/*/{Protheus.doc} A161Score()
Calcula Score de cada participante  
@Param aMinMaxPrc - minimo[1] maximo[2] Preço 
@Param aMinMaxPrz - minimo[1] maximo[2] Prazo 
@Param aMinMaxNt - minimo[1] maximo[2] Nota
@Param nPreco - preço
@Param nPrazo - prazo
@Param nNota  - Nota
@author Mauricio.Junior
@since  12/11/2019
@version 1.0
@return nRegItens

/*/
//-------------------------------------------------------------------
Static Function A161Score(aMinMaxPrc, aMinMaxPrz, aMinMaxNt, nPreco, nPrazo, nNota)

Local nPpreco 	:= mvPAR05
Local nPprazo	:= mvPAR06
Local nPnota	:= mvPAR07
Local nScore	:= 0
Local nLenPrc	:= 0
Local nLenPrz	:= 0
Local nLenNt	:= 0

Default aMinMaxPrc 	:= {}
Default aMinMaxPrz 	:= {}
Default aMinMaxNt  	:= {}
Default nPreco 	   	:= 0
Default nPrazo		:= 0
Default nNota 		:= 0

nLenPrc := Len(aMinMaxPrc)
nLenPrz := Len(aMinMaxPrz)
nLenNt  := Len(aMinMaxNt)

If nLenPrc > 0 .And. nLenPrc <= 2
	nScore	+=	nPpreco * ( (nPreco - aMinMaxPrc[1]) / (aMinMaxPrc[2] - aMinMaxPrc[1]) ) 
EndIf
If nLenPrz > 0 .And. nLenPrz <= 2
	nScore	+=	nPprazo * ( (nPrazo - aMinMaxPrz[1]) / (aMinMaxPrz[2] - aMinMaxPrz[1]) )
EndIf
If nLenNt > 0 .And. nLenNt <= 2
	nScore	+=	nPnota	* ( (aMinMaxNt[2] - nNota)   / (aMinMaxNt[2]  - aMinMaxNt[1])  )
EndIf

Return nScore

//-------------------------------------------------------------------
/*/{Protheus.doc} A161MarkW()
Marca vencedor.

@author Mauricio.Junior
@estrut aPropostas[nX,nY,2,nZ,1]
@since  12/11/2019
@version 1.0
@return nRegItens
/*/
//-------------------------------------------------------------------
Static Function A161MarkW(aPropostas, aVencedor, aScoreAux, lAnProp, aItens, lIntPCO)

Local nX		 := 0
Local nY		 := 0
Local nZ		 := 0
Local nPosIdPro	 := 0
Local nPosIdIt   := 0
Local nRecSC1	 := 0
Local lGrade     := MaGrade()
Local nPosMark	 := 17
Local lFound	 := .F.
Local lPcoTot    := .F.

Local aAreaSC1	 := SC1->(GetArea())
Local aAreaSC8	 := SC8->(GetArea())

Default aPropostas 	:= {}
Default aVencedor 	:= {}
Default aItens	 	:= {}
Default aScoreAux   := {}
Default lAnProp 	:= (MV_PAR04 == 2)
Default lIntPCO		:= SuperGetMV("MV_PCOINTE",.F.,"2")=="1"
Default nPosMark   	:= 16

SC1->(DbSetOrder(1))
SC1->(DbGoTop())

If lIntPCO
	lPcoTot   := PcoTotCot()
Endif

If ( (Len(aVencedor) > 0 .And. !Empty(aVencedor[1]) ) .Or. ( Len(aScoreAux) > 0 ) )
	For nX := 1 To Len(aPropostas)
		For nY := 1 To Len(aPropostas[nX])	
			If Len(aPropostas[nX][nY][1]) > 0
				If lAnProp //-- Análise por proposta
					If (aPropostas[nX][nY][1][1] == aScoreAux[1][1]) .And. (aPropostas[nX][nY][1][2] == aScoreAux[1][2]) .And. (aPropostas[nX][nY][1][4] == aScoreAux[1][4]) .And. (aPropostas[nX][nY][1][3] == aScoreAux[1][5])
						For nZ := 1 To Len(aPropostas[nX][nY][2])
							If !(aPropostas[nX,nY,2,nZ,8]) .And. (aPropostas[nX,nY,2,nZ,4] > 0)
								If lIntPCO
									nRecSC1 := A161RecSC1(aPropostas[nX,nY,2,nZ,9]) //-- Através da SC8 busca-se o RECNO da SC1
									If nRecSC1 > 0
										SC8->(DbGoTo(aPropostas[nX,nY,2,nZ,9])) //-- Posiciona na SC8 correspondente
										SC1->(DbGoTo(nRecSC1)) //-- Com a SC1 posicionada, aciona validação PCO
										If !A161PcoVld(aPropostas[nX,nY,2,nZ,1],lPcoTot) //-- Caso a validação PCO falhe, não marca o registro como vencedor e para o processamento
											PcoFreeBlq('000051')
											PcoFreeBlq('000052')
											aPropostas[nX,nY,2,nZ,1] := .F.
											lOkPCO := .F.
											Exit
										Else
											aPropostas[nX,nY,2,nZ,1] := .T. //-- Marca vencedor
											aPropostas[nX,nY,2,nZ,nPosMark] := .T. //-- guarda vencedor no inicio 											
											If Len(aItens) > 0 .And. nZ <= Len(aItens)
												aItens[nZ][7] := aPropostas[nX,nY,2,nZ,4] //-- Atualiza valor total do item
											EndIf
										EndIf
									Else 
										Help("", 1, "A161MarkW",, STR0136, 1, 0) //-- "Falha na integridade das tabelas SC1 (Solicitações de Compra) e SC8 (Cotações)" 
										lOkPCO := .F.
										Exit
									EndIf
								Else
									aPropostas[nX,nY,2,nZ,1] := .T. //-- Marca vencedor
									aPropostas[nX,nY,2,nZ,nPosMark] := .T. //-- guarda vencedor no inicio 																				
									If Len(aItens) > 0 .And. nZ <= Len(aItens)
										aItens[nZ][7] := aPropostas[nX,nY,2,nZ,4] //-- Atualiza valor total do item
									EndIf
								EndIf
							EndIf
						Next nZ
						lFound := .T.
						Exit
					EndIf
				Else //-- Análise por item 
					If (aPropostas[nX][nY][1][1] == aVencedor[2]) .And. (aPropostas[nX][nY][1][2] == aVencedor[3]) .And. (aPropostas[nX][nY][1][4] == aVencedor[5])	
						If lGrade .And. !Empty(aVencedor[6])//Garante que só irá entrar se for produto com grade
							nPosIdPro := aScan(aPropostas[nX][nY][2], {|x| AllTrim(x[16]) == aVencedor[6]})
						Else
							nPosIdPro := aScan(aPropostas[nX][nY][2], {|x| AllTrim(x[10]) == aVencedor[1]})
						Endif
						
						If nPosIdPro > 0 .And. !(aPropostas[nX,nY,2,nPosIdPro,8]) .And. (aPropostas[nX,nY,2,nPosIdPro,4] > 0)
							If lIntPCO
								nRecSC1 := A161RecSC1(aPropostas[nX,nY,2,nPosIdPro,9]) //-- Através da SC8 busca-se o RECNO da SC1
								If nRecSC1 > 0
									SC8->(DbGoTo(aPropostas[nX,nY,2,nPosIdPro,9])) //-- Posiciona na SC8 correspondente
									SC1->(DbGoTo(nRecSC1)) //-- Com a SC1 posicionada, aciona validação PCO
									If !A161PcoVld(aPropostas[nX,nY,2,nPosIdPro,1],lPcoTot) //-- Caso a validação PCO falhe, não marca o registro como vencedor e para o processamento
										aPropostas[nX,nY,2,nPosIdPro,1] := .F. 
										aPropostas[nX,nY,2,nPosIdPro,nPosMark] := .T. //-- guarda vencedor no inicio 																					
									Else
										aPropostas[nX,nY,2,nPosIdPro,1] := .T.	//-- Marca vencedor
										aPropostas[nX,nY,2,nPosIdPro,nPosMark] := .T. //-- guarda vencedor no inicio 																					
										If Len(aItens) > 0 
											If lGrade .And. !Empty(aVencedor[6]) //Garante que só irá entrar se for produto com grade
												nPosIdIt := aScan(aItens, {|x| AllTrim(x[16]) == aVencedor[6]})
											Else
												nPosIdIt := aScan(aItens, {|x| AllTrim(x[2]) == aVencedor[1]})
											Endif
											If nPosIdIt > 0	
												aItens[nPosIdIt][7] := aPropostas[nX,nY,2,nPosIdPro,4] //-- Atualiza valor total do item
												If mvPAR03 == 1
													aItens[nPosIdIt][10] := aPropostas[nX,nY,1,1]  //-- Atualiza valor total dofoenecedor ( MV_PAR03 = 1)
													aItens[nPosIdIt][11] := aPropostas[nX,nY,1,2]  //-- Atualiza valor total da loja ( MV_PAR03 = 1)
												Endif
											EndIf
										EndIf
									EndIf
								Else
									Help("", 1, "A161MarkW",, STR0136, 1, 0) //-- "Falha na integridade das tabelas SC1 (Solicitações de Compra) e SC8 (Cotações)" 
									lOkPCO := .F.
									Exit
								EndIf
							Else
								aPropostas[nX,nY,2,nPosIdPro,1] := .T.	//-- Marca vencedor
								aPropostas[nX,nY,2,nPosIdPro,nPosMark] := .T.	//-- Guarda vencedor no inicio
							
								If Len(aItens) > 0 
									If lGrade .And. !Empty(aVencedor[6]) //Garante que só irá entrar se for produto com grade
										nPosIdIt := aScan(aItens, {|x| AllTrim(x[16]) == aVencedor[6]})
									Else
										nPosIdIt := aScan(aItens, {|x| AllTrim(x[2]) == aVencedor[1]})
									Endif

									If nPosIdIt > 0	
										aItens[nPosIdIt][7] := aPropostas[nX,nY,2,nPosIdPro,4] //-- Atualiza valor total do item
										If mvPAR03 == 1
											aItens[nPosIdIt][10] := aPropostas[nX,nY,1,1]  //-- Atualiza valor total dofoenecedor ( MV_PAR03 = 1)
											aItens[nPosIdIt][11] := aPropostas[nX,nY,1,2]  //-- Atualiza valor total da loja ( MV_PAR03 = 1)
										Endif
									EndIf
								EndIf
							EndIf
							lFound := .T.
							Exit
						EndIf 
					EndIf
				EndIf
			Else
				Loop
			EndIf
		Next nY
		If lFound
			Exit
		Endif	
	Next nX
EndIf

RestArea(aAreaSC1)
RestArea(aAreaSC8)
		
Return Nil 			

//-------------------------------------------------------------------
/*/{Protheus.doc} A161QtdItem()
Verificação da contagem de itens quando analise é feita por proposta.
@Param cNumCot  - Numero da cotação
@Param cCodForn - Fornecedor
@Param cLoja 	- Loja
@Param cNumPro 	- Numero da proposta
@author Mauricio.Junior
@since 12/11/2019
@version 1.0
@return nRegItens
/*/
//-------------------------------------------------------------------
Static Function A161QtdItem(cNumCot, cCodForn, cLoja, cNumPro)

Local cAliasQry := GetNextAlias()
Local nRegItens := 0

If cCodForn != NIL
	BeginSQL Alias cAliasQry
		
		SELECT 	COUNT(SC8.C8_IDENT) AS TOTIDT
		FROM 	%Table:SC8% SC8
		WHERE 	SC8.C8_FILIAL 		= %xFilial:SC8%
				AND SC8.C8_NUM 		= %Exp:cNumCot%   
				AND SC8.C8_FORNECE 	= %Exp:cCodForn%   
				AND SC8.C8_LOJA 	= %Exp:cLoja%
				AND SC8.C8_NUMPRO 	= %Exp:cNumPro%
				AND SC8.C8_PRECO 	> 0
				AND SC8.%NotDel%

	EndSQL			
	  	
Else 
	BeginSQL Alias cAliasQry

	   SELECT	COUNT(DISTINCT SC8.C8_IDENT) AS TOTIDT
	   FROM		%Table:SC8% SC8
	   WHERE 	SC8.C8_FILIAL 		= %xFilial:SC8%
	   			AND SC8.C8_NUM 		= %Exp:cNumCot%
	   			AND SC8.%NotDel%

	EndSQL
EndIf 

nRegItens := (cAliasQry)->TOTIDT

(cAliasQry)->(DbCloseArea())

Return nRegItens

//-------------------------------------------------------------------
/*/{Protheus.doc} A161MMPrc()
Retorna o valor total minimo e valor total maximo do item da proposta

@author leonardo.magalhaes
 
@since 05/09/2019
@version 1.0
@return Nil
/*/
//-------------------------------------------------------------------
Static Function A161MMPrc(cIdt, cCodFor, cLojaFor, cNumPro, aProp, lAnProp,cItgrd)

	Local aPrcAux	 := {}
	Local aRet    	 := {}

	Local nX		 := 0
	Local nY		 := 0
	Local nZ		 := 0
	Local nPosId     := 0
	Local lGrade     := MaGrade()

	Default lAnProp  := (MV_Par04 == 2)
	Default cIdt  	 := ""
	Default cCodFor  := ""
	Default cLojaFor := ""
	Default cNumPro  := ""
	Default cItgrd   := ""
	Default aProp 	 := {}

	//-- Posições do aPropostas que serão verificadas
	//-- Se for análise por proposta:
	//---- aPropostas[n,p,1,1 ]	: Cod Fornecedor 
	//---- aPropostas[n,p,1,2 ]	: Loja 
	//---- aPropostas[n,p,1,4 ]	: Proposta 
	//---- aPropostas[n,p,1,7 ]	: Valor total (soma de nCusto dos itens)
	//-- Se for análise por item:
	//---- aPropostas[n,p,2,x,4]	: Valor total (nCusto)
	//---- aPropostas[n,p,2,x,10]	: Ident. (SC8->C8_IDENT)

	If lAnProp //-- Análise por proposta
		For nX := 1 to Len(aProp)
			For nY := 1 To Len(aProp[nX])
				If Len(aProp[nX][nY][1]) > 0 
					If aProp[nX][nY][1][7] > 0
						aAdd(aPrcAux, {aProp[nX][nY][1][1] + aProp[nX][nY][1][2] + aProp[nX][nY][1][4], aProp[nX][nY][1][7]})
					EndIf
				EndIf
			Next nY
		Next nX
		
		//-- Ordena os preços
		If Len(aPrcAux) > 0
			aSort(aPrcAux,,, {|a,b| a[2] < b[2]})
			aAdd(aRet, aPrcAux[1,2])
			aAdd(aRet, aPrcAux[Len(aPrcAux),2])
		EndIf

	Else //-- Análise por item
		
		For nX := 1 to Len(aProp)
			For nY := 1 To Len(aProp[nX])
				For nZ := 1 To Len(aProp[nX][nY][2])
					If lGrade .And. !Empty(aProp[nX][nY][2][nZ][16])//Garante que só irá entrar se for produto com grade
						If (aProp[nX][nY][2][nZ][16] == cItgrd) .And. (aProp[nX][nY][2][nZ][4] > 0) 
							nPosId := aScan(aPrcAux, {|x| x[3] == aProp[nX][nY][2][nZ][16]}) 
							If nPosId == 0 
								aAdd(aPrcAux, {aProp[nX][nY][2][nZ][10], {aProp[nX][nY][2][nZ][4]},aProp[nX][nY][2][nZ][16]})
							Else
								aAdd(aPrcAux[nPosId][2], aProp[nX][nY][2][nZ][4])
							EndIf
						EndIf
					Else	
						If (aProp[nX][nY][2][nZ][10] == cIdt) .And. (aProp[nX][nY][2][nZ][4] > 0) 
							nPosId := aScan(aPrcAux, {|x| x[1] == aProp[nX][nY][2][nZ][10]}) 
							If nPosId == 0 
								aAdd(aPrcAux, {aProp[nX][nY][2][nZ][10], {aProp[nX][nY][2][nZ][4]},aProp[nX][nY][2][nZ][16]})
							Else
								aAdd(aPrcAux[nPosId][2], aProp[nX][nY][2][nZ][4])
							EndIf
						EndIf
					Endif					


				Next nZ
			Next nY
		Next nX
	
		//-- Ordena os preços
		If Len(aPrcAux) > 0
			aSort(aPrcAux[1,2])
			aAdd(aRet, aPrcAux[1,2,1])
			aAdd(aRet, aPrcAux[1,2,Len(aPrcAux[1,2])])
		EndIf
		
	EndIf

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} A161AnProp()
Realiza a análise da cotação pelo critério de propostas

@author leonardo.magalhaes
 
@since 13/09/2019
@version 1.0
@return Nil
/*/
//-------------------------------------------------------------------
Static Function A161AnProp(aItens, aPropostas, cNumCot, aScoreAux, lAnPropOk)

	Local aMinMaxPrc := 0
	Local aMinMaxPrz := 0
	Local aMinMaxNt  := 0
	
	Local cAliasAux := GetNextAlias()
	
	Local nQtIt := 0
	Local nVlTotProp := 0
	Local nPosPrpFor := 0

	Default aItens := {}
	Default aPropostas := {}
	Default aScoreAux := {}
	
	Default cNumCot := ""
	
	Default lAnPropOk := .T.

	BeginSQL Alias cAliasAux

		SELECT		C8_FORNECE,
					C8_LOJA,  										 
					C8_NUMPRO,
					C8_FORNOME,
					AVG(C8_PRAZO) AS C8PRAZO,
					AVG(ISNULL(A5_NOTA, 0)) AS A5NOTA
		FROM 		%Table:SC8% SC8
		LEFT JOIN 	%Table:SA5% SA5
		ON			SA5.A5_FILIAL  		= %xFilial:SA5%
					AND SA5.A5_FORNECE 	= SC8.C8_FORNECE
					AND A5_LOJA 		= SC8.C8_LOJA
					AND SA5.A5_PRODUTO  = SC8.C8_PRODUTO
					AND SA5.%NotDel%
		WHERE 		SC8.C8_FILIAL 		= %xFilial:SC8%
					AND SC8.C8_NUM 		= %Exp:cNumCot%
					AND SC8.%NotDel%
		GROUP BY    C8_FORNECE, C8_LOJA, C8_NUMPRO, C8_FORNOME
		ORDER BY 	C8_FORNECE, C8_LOJA, C8_NUMPRO, C8_FORNOME

	EndSQL

	//-- Encontra a quantidade de itens distintos da proposta
	nQtIt := A161QtdItem(cNumCot, )

	//-- Define o valores mínimos e máximos encontrados para as propostas 
	aMinMaxPrc := A161MMPrc(,,,, aPropostas, .T.)
	aMinMaxPrz := A161MinMax('C8_PRAZO', cNumCot,,,,, .T.)
	aMinMaxNt  := A161MinMax('A5_NOTA' , cNumCot,,,,, .T.)

	While (cAliasAux)->(!Eof()) 

		//-- Avaliar se análise por proposta poderá ser realizada, prosseguir somente se existir preço unitário para todos os itens em todas as propostas 
		cForn := (cAliasAux)->C8_FORNECE
		cLoja := (cAliasAux)->C8_LOJA
		cNumProp := (cAliasAux)->C8_NUMPRO
		If A161QtdItem(cNumCot, cForn, cLoja, cNumProp ) < nQtIt .And. lAnPropOk
			Help("", 1, "A161ANPROP",, STR0122, 1, 0,,,,,, {STR0123}) //-- "Impossível sugerir proposta vencedora pois existem fornecedores sem preço unitário informado para um ou mais itens da proposta!" "Utilize o critério de avaliação por item ou informe preço unitário para todos os itens de todas as propostas para que a análise por proposta possa ser realizada."
			lAnPropOk := .F.
			Exit
		EndIf
	
		//-- Calcular valor total da proposta corrente
		nVlTotProp := A161VlTPro((cAliasAux)->(C8_FORNECE), (cAliasAux)->(C8_LOJA), (cAliasAux)->(C8_NUMPRO), aPropostas,(cAliasAux)->(C8_FORNOME))

		//-- Montar o score da proposta corrente
		nPosPrpFor := aScan(aScoreAux, {|x| x[1] + x[2] + x[4] + x[5] == (cAliasAux)->(C8_FORNECE+C8_LOJA+C8_NUMPRO+C8_FORNOME)})

		If nPosPrpFor == 0
			nScoreAux := A161Score(aMinMaxPrc, aMinMaxPrz, aMinMaxNt, nVlTotProp, (cAliasAux)->C8PRAZO, (cAliasAux)->(A5NOTA))
			aAdd(aScoreAux, {(cAliasAux)->(C8_FORNECE), (cAliasAux)->(C8_LOJA), nScoreAux, (cAliasAux)->(C8_NUMPRO), (cAliasAux)->(C8_FORNOME)})
		EndIf 

		(cAliasAux)->(DbSkip())

	EndDo

	//-- Ordenar o array de score para que seja retornada a melhor proposta de acordo com os pesos utilizados
	If lAnPropOk .And. Len(aScoreAux) > 0 .And. !Empty(aScoreAux[1])
		aSort(aScoreAux,,, {|x,y| x[3] < y[3]})
	EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} A161AnIt()
Realiza a análise da cotação pelo critério de item

@author leonardo.magalhaes
 
@since 13/09/2019
@version 1.0
@return Nil
/*/
//-------------------------------------------------------------------
Static Function A161AnIt(aItens, aPropostas, cNumCot)

	Local aVencedor	 := {'', '', '', 0, '',''}
	Local aMinMaxPrc := {}
	Local aMinMaxPrz := {}
	Local aMinMaxNt  := {}

	Local cIdent 	 := ''
	Local cItemGrd	 := ""
	Local cAliasAux	 := GetNextAlias()
	Local lGrade     := MaGrade()
	Local cWhereAux  := "% (C8_PRODUTO >= '" + MV_PAR01 + "'  AND C8_PRODUTO <= '" + MV_PAR02 + "' ) %"

	Local nScoreAux	 := 0
	Local lFirst	 := .T.

	Default aItens 		:= {}
	Default aPropostas 	:= {}
	Default cNumCot 	:= ""

	BeginSQL Alias cAliasAux

		SELECT		C8_PRODUTO,
					SC8.R_E_C_N_O_ SC8REC,
					C8_IDENT,
					C8_ITEMGRD,
					C8_NUMPRO,
					C8_FORNECE,
					C8_LOJA,  										 
					C8_ITEM,
					C8_PRAZO,
					C8_PRECO,
					ISNULL(A5_NOTA, 0) A5NOTA
		FROM 		%Table:SC8% SC8
		LEFT JOIN 	%Table:SA5% SA5
		ON			SA5.A5_FILIAL  		= %xFilial:SA5%
					AND SA5.A5_FORNECE 	= SC8.C8_FORNECE
					AND A5_LOJA 		= SC8.C8_LOJA
					AND SA5.A5_PRODUTO  = SC8.C8_PRODUTO
					AND SA5.%NotDel%
		WHERE 		C8_FILIAL 		= %xFilial:SC8%
					AND C8_NUM 		= %Exp:cNumCot%
					AND %Exp:cWhereAux%
					AND SC8.%NotDel%
		ORDER BY 	C8_IDENT, C8_PRODUTO, C8_NUMPRO, C8_FORNECE, C8_LOJA, C8_FORNOME

	EndSQL 

	While (cAliasAux)->(!EOF())
		
		If Empty(cIdent) .Or. cIdent <> (cAliasAux)->(C8_IDENT)	.OR. (lGrade .And. cItemGrd <>(cAliasAux)->(C8_ITEMGRD))
			
			If !Empty(cIdent)	
				A161MarkW(aPropostas, aVencedor,, .F., @aItens)
			EndIf
				
			aVencedor[1] := ""
			aVencedor[2] := ""
			aVencedor[3] := ""
			aVencedor[4] := 0
			aVencedor[5] := ""
			aVencedor[6] := ""

			lFirst		 := .T.			
			cIdent := (cAliasAux)->(C8_IDENT)
			cItemGrd := (cAliasAux)->(C8_ITEMGRD)

			aMinMaxPrc := A161MMPrc((cAliasAux)->(C8_IDENT), (cAliasAux)->(C8_FORNECE), (cAliasAux)->(C8_LOJA), (cAliasAux)->(C8_NUMPRO), aPropostas, .F.,(cAliasAux)->(C8_ITEMGRD)) 
			aMinMaxPrz := A161MinMax( 'C8_PRAZO', cNumCot, (cAliasAux)->(C8_IDENT),,,, .F.,(cAliasAux)->(C8_ITEMGRD) )
			aMinMaxNt  := A161MinMax( 'A5_NOTA' , cNumCot, (cAliasAux)->(C8_IDENT),,,, .F.,(cAliasAux)->(C8_ITEMGRD) )
		EndIf
		
		If (cAliasAux)->(C8_PRECO) > 0
			
			nVlTotIt := A161VlTIt((cAliasAux)->(C8_IDENT), (cAliasAux)->(C8_FORNECE), (cAliasAux)->(C8_LOJA), (cAliasAux)->(C8_NUMPRO), aPropostas,(cAliasAux)->(C8_ITEMGRD))
		
			nScoreAux := A161Score(aMinMaxPrc, aMinMaxPrz, aMinMaxNt, nVlTotIt, (cAliasAux)->(C8_PRAZO), (cAliasAux)->(A5NOTA))
					
			If lFirst .Or. nScoreAux < aVencedor[4]
				aVencedor[1] := (cAliasAux)->(C8_IDENT)
				aVencedor[2] := (cAliasAux)->(C8_FORNECE)
				aVencedor[3] := (cAliasAux)->(C8_LOJA)
				aVencedor[4] := nScoreAux
				aVencedor[5] := (cAliasAux)->(C8_NUMPRO)
				aVencedor[6] := (cAliasAux)->(C8_ITEMGRD)
				lFirst := .F.
			EndIf

		EndIf

		(cAliasAux)->(DbSkip())
		
	EndDo
	
	A161MarkW(aPropostas, aVencedor,, .F., @aItens) //-- Roda o ultimo item pendente antes de sair da função
	FwFreeArray(aVencedor)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} A161VlTPro()
Retorna valor total da proposta

@author leonardo.magalhaes
 
@since 13/09/2019
@version 1.0
@return Nil
/*/
//-------------------------------------------------------------------
Static Function A161VlTPro(cCodFor, cLojaFor, cNumProp, aProp,cNomFor)
	
	Local nRet 		 := 0
	Local nX		 := 0
	Local nY		 := 0

	Default cCodFor  := ""
	Default cLojaFor := ""
	Default cNumProp := ""
	Default aProp 	 := {}

	//-- Posições do aPropostas que serão verificadas para análise por proposta:
	//---- aPropostas[n,p,1,1 ]	: Cod Fornecedor 
	//---- aPropostas[n,p,1,2 ]	: Loja 
	//---- aPropostas[n,p,1,4 ]	: Proposta 
	//---- aPropostas[n,p,1,7 ]	: Valor total (soma de nCusto dos itens)

	For nX := 1 to Len(aProp)
		For nY := 1 To Len(aProp[nX])
			If 	Len(aProp[nX][nY][1]) > 0 .And.; 
				aProp[nX][nY][1][7] > 0 .And.;
				(aProp[nX][nY][1][1] + aProp[nX][nY][1][2] + aProp[nX][nY][1][4]+ aProp[nX][nY][1][3] == cCodFor + cLojaFor + cNumProp+cNomFor)

				nRet := aProp[nX][nY][1][7]
			EndIf
			If nRet > 0
				Exit
			EndIf
		Next nY
		If nRet > 0
			Exit
		EndIf
	Next nX

Return nRet

//-------------------------------------------------------------------
/*/{Protheus.doc} A161VlTIt()
Retorna valor total do item

@author leonardo.magalhaes
 
@since 05/09/2019
@version 1.0
@return Nil
/*/
//-------------------------------------------------------------------
Static Function A161VlTIt(cIdt, cCodFor, cLojaFor, cNumProp, aProp,cItGrd)
	
	Local nRet 		 := 0
	Local nX		 := 0
	Local nY		 := 0
	Local nZ		 := 0
	Local lGrade     := MaGrade()

	Default cIdt 	 := ""
	Default cItGrd 	 := ""
	Default cCodFor  := ""
	Default cLojaFor := ""
	Default cNumProp := ""
	Default aProp 	 := {}

	//-- Posições do aPropostas que serão verificadas
	//-- aPropostas[n,p,1,1 ]	: Cod Fornecedor  	
	//-- aPropostas[n,p,1,2 ]	: Loja 
	//-- aPropostas[n,p,1,4 ]	: Proposta 
	//-- aPropostas[n,p,2,x,4]	: Valor total (nCusto)
	//-- aPropostas[n,p,2,x,10]	: Ident. (SC8->C8_IDENT)

	For nX := 1 to Len(aProp)
		For nY := 1 To Len(aProp[nX])
			If Len(aProp[nX][nY][1]) > 0
				If aProp[nX][nY][1][1] == cCodFor .And. aProp[nX][nY][1][2] == cLojaFor .And. aProp[nX][nY][1][4] == cNumProp
					For nZ := 1 To Len(aProp[nX][nY][2])
						If lGrade .And. !Empty(aProp[nX][nY][2][nZ][16])//Garante que só irá entrar se for produto com grade
							If (aProp[nX][nY][2][nZ][16] == cItGrd) .And. (aProp[nX][nY][2][nZ][4] > 0) 
								nRet := aProp[nX][nY][2][nZ][4]
								Exit
							EndIf
						Else
							If (aProp[nX][nY][2][nZ][10] == cIdt) .And. (aProp[nX][nY][2][nZ][4] > 0) 
								nRet := aProp[nX][nY][2][nZ][4]
								Exit
							EndIf
						EndIf 
					Next nZ
				EndIf
				If nRet > 0 
					Exit
				EndIf
			EndIf
		Next nY
		If nRet > 0 
			Exit
		EndIf
	Next nX

Return nRet

/*/{Protheus.doc} ExecCtrMdl
	Carrega o modelo do CNTA300, seta a operacao como inclusao, o ativa e preenche com os dados informados
em <aContrato> atraves da funcao <A161MdlCot>. Caso <aContrato> contenha dados invalidos, exibe alerta.
@author philipe.pompeu
@since 16/09/2019
@return lResult, bool, verdadeiro se gravado com sucesso.
@param aContrato, vetor, contem o registro esperado pela funcao <A161MdlCot> 
/*/
Static Function ExecCtrMdl(aContrato)
	Local lResult := .F.
	Local nGravou := 0
	Local cErrMsg := ""
	Local oModel300 := Nil
		
	oModel300 := FWLoadModel( "CNTA300" )
	oModel300:SetOperation(3)                                 
	oModel300:Activate()
	oModel300 := A161MdlCot(oModel300, aContrato)	
	If(!oModel300:HasErrorMessage())
		nGravou := FWExecView (STR0073 , "CNTA300" , MODEL_OPERATION_INSERT ,, {||.T.},,,,,,, oModel300)//'Incluir'
		A161AtSC8(aContrato, CN9->CN9_NUMERO)
	Else
		nGravou := 1		
		cErrMsg := oModel300:GetErrorMessage()[5] + "["+ oModel300:GetErrorMessage()[4] + "] - " + oModel300:GetErrorMessage()[6]
		Help("",1,STR0057,,cErrMsg,1,0)
	EndIf
	oModel300:DeActivate()
	oModel300 := Nil
	
	lResult := ( nGravou == 0 )
Return lResult

//-------------------------------------------------------------------
/*/{Protheus.doc} A161VlQAud()
Valida a digitação da quantidade para o item da auditoria

@author leonardo.magalhaes
 
@since 23/09/2019
@version 1.0
@return Nil
/*/
//-------------------------------------------------------------------
Function A161VlQAud()

	Local lRet 		 := .T.
	Local nPosNumCot := 0
	Local nPosItCot  := 0
	Local nPosFor    := 0 
	Local nPosLoja   := 0
	Local nPosNumPro := 0

	nPosNumCot	:= aScan(aHeader, {|x| AllTrim(x[2]) == "CE_NUMCOT"})
	nPosItCot	:= aScan(aHeader, {|x| AllTrim(x[2]) == "CE_ITEMCOT"})
	nPosFor		:= aScan(aHeader, {|x| AllTrim(x[2]) == "CE_FORNECE"})
	nPosLoja	:= aScan(aHeader, {|x| AllTrim(x[2]) == "CE_LOJA"})
	nPosNumPro	:= aScan(aHeader, {|x| AllTrim(x[2]) == "CE_NUMPRO"})

	If nPosNumCot > 0  .And. nPosItCot > 0 .And. nPosFor > 0 .And. nPosLoja > 0 .And. nPosNumPro > 0
		If M->CE_QUANT > 0
			If !A161ChkPrU(aCols[n][nPosNumCot], aCols[n][nPosItCot], aCols[n][nPosFor], aCols[n][nPosLoja], aCols[n][nPosNumPro])
				lRet := .F.
				Help(' ', 1, "A161VLQAUD",, STR0126, 2, 0,,,,,, {STR0127}) //-- "Fornecedor não poderá receber quantidade deste item pois não houve preço unitário informado em sua proposta ou a condição de pagamento é inválida!" "Atualize a cotação informando um preço unitário para este item na proposta do fornecedor e verifique a condição de pagamento!"	
			EndIf
		EndIf
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} A161ChkPrU()
Retorna se o item da cotação possui preço unitário informado para a
proposta do fornecedor e uma condição de pagamento válida

@author leonardo.magalhaes
 
@since 23/09/2019
@version 1.0
@return lRet
/*/
//-------------------------------------------------------------------
Function A161ChkPrU(cNumCot, cItCot, cCodFor, cLojaFor, cNumProp)
	
	Local lRet 		 := .T.
	Local cAliasAux  := GetNextAlias()
	Local cCongPgAux := Space(Len(SC8->C8_COND))

	Default cNumCot  := ""
	Default cItCot   := ""
	Default cCodFor  := ""
	Default cLojaFor := ""
	Default cNumProp := ""

	BeginSQL Alias cAliasAux
		SELECT 	1 
		FROM 	%Table:SC8% SC8 
		WHERE 	SC8.C8_FILIAL	    = %xFilial:SC8%
				AND SC8.C8_NUM 		= %Exp:cNumCot% 
				AND SC8.C8_ITEM 	= %Exp:cItCot% 
				AND SC8.C8_FORNECE 	= %Exp:cCodFor% 
				AND SC8.C8_LOJA 	= %Exp:cLojaFor% 
				AND SC8.C8_NUMPRO 	= %Exp:cNumProp%
				AND SC8.C8_PRECO 	> 0
				AND SC8.%NotDel%
				AND (SC8.C8_COND    <> %Exp:cCongPgAux%
				AND NOT EXISTS (SELECT 1 FROM %Table:SE4% SE4 WHERE SE4.E4_FILIAL = %xFilial:SE4% AND SE4.E4_CODIGO = SC8.C8_COND AND E4_TIPO = 'A' AND SE4.%NotDel%))
	EndSQL

	lRet := !(cAliasAux)->(Eof())

	(cAliasAux)->(DbCloseArea())

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} A161RecSC1()
Retorna o RECNO da SC1 correspondente ao item da cotação

@author leonardo.magalhaes
 
@since 29/11/2019
@version 1.0
@return lRet
/*/
//-------------------------------------------------------------------
Static Function A161RecSC1(nRecSC8)

	Local nRet := 0
	Local cAliasAux := GetNextAlias()

	Default nRecSC8 := SC8->(Recno())

	BeginSQL Alias cAliasAux
		SELECT 	SC1.R_E_C_N_O_ AS SC1RECNO
		FROM 	%Table:SC8% SC8
		JOIN 	%Table:SC1% SC1
		ON 		SC1.C1_FILIAL 		= %xFilial:SC1%
				AND SC1.C1_NUM		= SC8.C8_NUMSC
				AND SC1.C1_ITEM		= SC8.C8_ITEMSC
				AND SC1.%NotDel%
		WHERE 	SC8.R_E_C_N_O_ 		= %Exp:nRecSC8%
				AND SC8.%NotDel%
	EndSQL 

	If (cAliasAux)->(!Eof())
		nRet := (cAliasAux)->SC1RECNO
	EndIf

	(cAliasAux)->(DbCloseArea())

Return nRet

//-------------------------------------------------------------------
/*/{Protheus.doc} A161RstFld(aPropostas)
Restaura as informações de C8_MOTVENC caso a análise seja cancelada

@author leonardo.magalhaes
 
@since 29/11/2019
@version 1.0
@return lRet
/*/
//-------------------------------------------------------------------
Static Function A161RstFld(aPropostas)

	Local nP 		:= 0
	Local nI 		:= 0
	Local nH 		:= 0
	Local aAreaSC8  := SC8->(GetArea())

	Default aPropostas := {}

	For nP := 1 To Len(aPropostas)
		For nI := 1 To Len(aPropostas[nP])
			For nH := 1 To Len(aPropostas[nP][nI][2])
				If !aPropostas[nP, nI, 2, nH, 8] 
					SC8->(DbGoTo(aPropostas[nP, nI, 2, nH, 9]))
					If nPosMotC8 > 0 .And. !Empty(SC8->C8_MOTVENC)
						RecLock("SC8", .F.)
							SC8->C8_MOTVENC := ""
						SC8->(MsUnLock())
					EndIf 
					If !Empty(SC8->C8_MOTIVO)
						RecLock("SC8", .F.)
							SC8->C8_MOTIVO := ""
						SC8->(MsUnLock())
					EndIf
				EndIf
			Next nH
		Next nI
	Next nP

	RestArea(aAreaSC8)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} A161AtSCE()
Função para atualização da tabela SCE
após a geração do contrato (GCT), esta função depende do
posicionamento da SC8 executado pela A161AtSC8
@Param lMarkAud Indica se o item posicionado da SC8 está sendo analisado 
				via auditoria (.T. ou .F.)
		
@author leonardo.magalhaes
 
@since 08/04/2020
@version 1.0
@return Nil
/*/
//-------------------------------------------------------------------
Static Function A161AtSCE(lMarkAud)

	Local aArea 	 := GetArea()
	Local aAreaSCE 	 := SCE->(GetArea())
	Local aAreaSC8 	 := SC8->(GetArea())
	
	Local cFilSCE	 := xFilial("SCE")
	
	Local nW 		 := 0
	Local nZ 		 := 0
	Local nA 		 := 0
	Local nPosQtd	 := Iif(Len(aHeadAud) > 0, aScan(aHeadAud, {|x| x[2] == "CE_QUANT"}), 0)
	Local nPosMotAud := Iif(Len(aHeadAud) > 0, aScan(aHeadAud, {|x| x[2] == "CE_MOTVENC"}), 0)
	Local nPosEnt	 := Iif(Len(aHeadAud) > 0, aScan(aHeadAud, {|x| x[2] == "CE_ENTREGA"}), 0)
	Local nPosMot	 := Iif(Len(aHeadAud) > 0, aScan(aHeadAud, {|x| x[2] == "CE_MOTIVO"}), 0)
	Local nPosFor	 := Iif(Len(aHeadAud) > 0, aScan(aHeadAud, {|x| x[2] == "CE_FORNECE"}), 0)
	Local nPosLoj	 := Iif(Len(aHeadAud) > 0, aScan(aHeadAud, {|x| x[2] == "CE_LOJA"}), 0)
	Local nPosProp	 := Iif(Len(aHeadAud) > 0, aScan(aHeadAud, {|x| x[2] == "CE_NUMPRO"}), 0)
	
	Local lGravou    := .F.

	Default lMarkAud := .F.
	
	//-- Se for gerado via Auditoria, atualizar a SCE com os dados de aGravaAud e os campos C8_MARKAUD, C8_MOTVENC, C8_DATPRF, C8_PRAZO e C8_MOTIVO com as infomações da SCE
	//-- Caso contrário, atualizar SCE com dados da SC8
	If lMarkAud 
		For nW := 1 To Len(aGravaAud)
			For nZ := 1 To Len(aGravaAud[nW, 2])
				If aGravaAud[nW][1] == SC8->C8_IDENT 
					If 	(nPosQtd > 0 .And. aGravaAud[nW, 2, nZ, nPosQtd] > 0) .And.; 
						(nPosFor > 0 .And. aGravaAud[nW, 2, nZ, nPosFor] == SC8->C8_FORNECE) .And.;
						(nPosLoj > 0 .And. aGravaAud[nW, 2, nZ, nPosLoj] == SC8->C8_LOJA) .And.;
						(nPosProp > 0 .And. aGravaAud[nW, 2, nZ, nPosProp] == SC8->C8_NUMPRO)
						If nPosMotAud > 0 .And. lMemoMotCE .And. nPosMotC8 > 0 .And. lMemoMotC8
							RecLock("SC8",.F.)
								SC8->C8_MOTVENC := aGravaAud[nW][2][nZ][nPosMotAud]
							MsUnlock()
						EndIf
						If nPosEnt > 0
							RecLock("SC8",.F.)
								SC8->C8_DATPRF := Iif(MvPar08 == 2, aGravaAud[nW][2][nZ][nPosEnt], dDataBase+SC8->C8_PRAZO)
								SC8->C8_PRAZO  := SC8->C8_DATPRF - dDataBase
							MsUnlock()
						EndIf
						If nPosMot > 0 
							RecLock("SC8",.F.)
								SC8->C8_MOTIVO := aGravaAud[nW][2][nZ][nPosMot]
							MsUnlock()
						EndIf
						RecLock("SCE", .T.)
							SCE->CE_FILIAL := cFilSCE
							SCE->CE_ENTREGA := SC8->C8_DATPRF //-- Campo entrega depende da regra conforme o MV_PAR08
							For nA := 1 To Len(aHeadAud)
								//-- Nao grava campos virtuais e de controle (Walkthru)
								If 	!(IsHeadRec(Trim(aHeadAud[nA][2])) .Or.; 
									IsHeadAlias(Trim(aHeadAud[nA][2])) .Or.; 
									aHeadAud[nA][10] == "V" .Or.;
									aHeadAud[nA][2] == "CE_ENTREGA")
									If aGravaAud[nW, 2, nZ, nA] <> NIL
										SCE->(FieldPut(FieldPos(aHeadAud[nA][2]), aGravaAud[nW, 2, nZ, nA]))
									EndIf
								EndIf
							Next nA
						SCE->(MsUnLock())
						lGravou := .T.
						Exit
					EndIf
				EndIf
			Next nZ
			If lGravou
				Exit
			EndIf
		Next nW
	Else
		RecLock("SCE", .T.)
			SCE->CE_FILIAL := cFilSCE
			For nA := 1 To Len(aHeadSCE)
				cCampo := AllTrim(aHeadSCE[nA][2])
				If cCampo == "CE_NUMCOT"
					SCE->CE_NUMCOT := SC8->C8_NUM
				ElseIf cCampo == "CE_ITEMCOT"
					SCE->CE_ITEMCOT := SC8->C8_ITEM
				ElseIf cCampo == "CE_NUMPRO"
					SCE->CE_NUMPRO := SC8->C8_NUMPRO
				ElseIf cCampo == "CE_PRODUTO"
					SCE->CE_PRODUTO := SC8->C8_PRODUTO
				ElseIf cCampo == "CE_FORNECE"
					SCE->CE_FORNECE := SC8->C8_FORNECE
				ElseIf cCampo == "CE_DESCFOR"
					SCE->CE_DESCFOR := SC8->C8_FORNOME
				ElseIf cCampo == "CE_LOJA"
					SCE->CE_LOJA := SC8->C8_LOJA
				ElseIf cCampo == "CE_ITEMGRD"
					SCE->CE_ITEMGRD := SC8->C8_ITEMGRD
				ElseIf cCampo == "CE_ENTREGA"
					SCE->CE_ENTREGA := Iif(MvPar08 == 2, SC8->C8_DATPRF, dDataBase + SC8->C8_PRAZO)
				ElseIf cCampo == "CE_QUANT"
					SCE->CE_QUANT := SC8->C8_QUANT
				ElseIf cCampo == "CE_MOTIVO"
					SCE->CE_MOTIVO := SC8->C8_MOTIVO
				Else
					//-- Nao grava campos virtuais e de controle (Walkthru)
					If !(IsHeadRec(cCampo) .Or. IsHeadAlias(cCampo) .Or. aHeadSCE[nA][10] == "V")
						//-- Demais campos gravar pelo inicializador padrão do dicionário
						SCE->(FieldPut(FieldPos(cCampo), Criavar(cCampo, .T.)))
					EndIf
				EndIf
			Next nA
		SCE->(MsUnLock())
	EndIf

	SCE->(RestArea(aAreaSCE))
	SC8->(RestArea(aAreaSC8))
	RestArea(aArea)

Return Nil

//-------------------------------------------------------------------
/*{Protheus.doc} A161Venc
Verifica se na analise de cotação foi selecionado algum vencedor  

@author Mauricio Ferreira
@since 09/06/2020
@version 1.0
@return lVenc
*/
//-------------------------------------------------------------------
Static Function A161Venc(aPropostas)
Local nX	 := 0
Local nY	 := 0
Local nZ	 := 0
Local lVenc	 := .F.

Default aPropostas := {}

For nX := 1 To Len(aPropostas)
	For nY := 1 To Len(aPropostas[nX])	
		If Len(aPropostas[nX][nY][1]) > 0
			For nZ := 1 To Len(aPropostas[nX][nY][2])
				If (aPropostas[nX,nY,2,nZ,1] .Or. aPropostas[nX,nY,2,nZ,14]) .And. !aPropostas[nX,nY,2,nZ,8]
					lVenc := .T.
				EndIf
				If lVenc
					Exit
				EndIf	
			Next nZ
		EndIf
		If lVenc
			Exit
		EndIf
	Next nY
	If lVenc
		Exit
	EndIf
Next nX

Return lVenc

/*/{Protheus.doc} ComMetric
	Total de Pedidos/Cotratos gerados por Análise de Cotação via <FWCustomMetrics>
@author rd.santos
@since 26/05/2021
@return Nil, indefinido
/*/
Static Function ComMetric(cOper,nQuant)
Local cIdMetric		:= "compras-protheus_pedidos-contratos-gerados-cotacao_total"
Local cRotina		:= "mata161"
Local cSubRoutine	:= cRotina+'-'+cOper
Local lContinua		:= (FWLibVersion() >= "20210517") .And. FindClass('FWCustomMetrics')

If lContinua
	FWCustomMetrics():setSumMetric(cSubRoutine, cIdMetric, nQuant, /*dDateSend*/, /*nLapTime*/,cRotina)
Endif

Return

/*/{Protheus.doc} PcoTotCot
// verifica se o bloqueio utiliza o campo de total da cotação.
@author Leandro Nishihata
@since 16/08/2021
@return lPcoTot, Logico
/*/
Static Function PcoTotCot(CPcoVtot)

Local lPcoTot := .F.

Default CPcoVtot := ""

dbSelectArea("AKI")
CPcoVtot := ALLTRIM(GetAdvFval("AKI","AKI_VALOR1",xFilial("AKI") + "0000520201" ,1))

If !Empty(CPcoVtot) 
	lPcoTot := If( "C8_TOTPCO" $ UPPER(CPcoVtot),.T.,.F.)
Endif

CPcoVtot := StrTran(UPPER(CPcoVtot),"C8_TOTPCO","C8_TOTAL") // substitui o campo a ser utilizado para os campos totalizadores, afim de efetuar o preenchimento do campo C8_TOTPCO

return lPcoTot

/*/{Protheus.doc} ComMetrCot
	Total de cotações analisadas que utilizam o parâmetro MV_GRADE via <FWCustomMetrics>
@author Fabiano Dantas
@since 26/10/2021
@return Nil, indefinido
/*/
Static Function ComMetrCot(cOper,nQuant)
Local cIdMetric		:= "compras-protheus_total-mv_grade_total"
Local cRotina		:= "mata161"
Local cSubRoutine	:= cRotina+'-'+cOper
Local lContinua		:= (FWLibVersion() >= "20210517") .And. FindClass('FWCustomMetrics')

If lContinua
	FWCustomMetrics():setSumMetric(cSubRoutine, cIdMetric, nQuant, /*dDateSend*/, /*nLapTime*/,cRotina)
Endif

Return


/*/{Protheus.doc} A161LegPc
Verifica se cotação gerada por auditoria, teve pedido de compra excluido parcialmente
@author Fabiano Dantas
@since 23/12/2021
@return Nil, indefinido
/*/
Function A161LegPc()

	Local aAreaSC8	 := GetArea()
	Local lRet := .F. 
	Local aDados := {}
	Local nPos := 0
	
	
	BeginSql Alias "SCECOUNT" 
		SELECT COUNT(CE_NUMCOT) nCount,CE_NUMCOT CENUM, C8_NUM C8NUM 
			FROM %Table:SCE% SCE
				INNER JOIN %Table:SC8% SC8 ON 
					  SC8.C8_NUM = SCE.CE_NUMCOT
					AND SCE.CE_ITEMCOT = SC8.C8_ITEM
					AND SCE.CE_PRODUTO = SC8.C8_PRODUTO
			WHERE SC8.%NotDel%
			AND SCE.%NotDel%
			AND SC8.C8_MARKAUD = 'F'
			AND SC8.C8_NUMPED = ''
			AND SC8.C8_NUMCON = ''
			AND SCE.CE_PRODUTO = %Exp:SC8->C8_PRODUTO%
			AND SCE.CE_FILIAL = %xFilial:SCE% 
			AND SC8.C8_FILIAL = %xFilial:SC8% 
			GROUP BY SCE.CE_NUMCOT, SC8.C8_NUM
	EndSql

	While !SCECOUNT->(EOF())
		aAdd(aDados, SCECOUNT->CENUM)
		SCECOUNT->(dbSkip())
	EndDo

	If Len(aDados) > 0
		nPos := aScan(aDados,{|x| x == SC8->C8_NUM})
		If FwIsInCallStack("A161MAPCOT")
			If nPos == 0 
				lRet := .T. 
			EndIf
		Else 
			If nPos > 0 
				lRet := .T. 
			EndIf
		EndIf
	Else
		If FwIsInCallStack("A161MAPCOT")
			lRet := .T.
		EndIf 
	EndIf  

	SCECOUNT->(dbCloseArea())
	
	RestArea(aAreaSC8)

Return lRet
