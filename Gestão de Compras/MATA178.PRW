#INCLUDE "MATA178.CH"
#INCLUDE "PROTHEUS.CH"        
#INCLUDE "TBICONN.CH"

Static lLGPD  := FindFunction("SuprLGPD") .And. SuprLGPD()
/*                                 
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³MATA178  ³Autor        ³Vitor Raspa     ³Data ³ 18.Jun.08³±±
±±³          ³         ³Padronização ³Julio C.Guerato ³Data ³ 15.Set.09³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³AGLUTINACAO DOS PEDIDOS DE COMPRA                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³SigaCom                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function MATA178()               
Local cPerg  := 'MTA178'       
Local cTitle := STR0001 
Local aSays  := {}
Local nOpcA  := 0
             
Pergunte( cPerg, .F. )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³PARAMETROS                       ³
//ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
//³MV_PAR01: Da Data?               ³
//³MV_PAR02: Ate a Data?            ³
//³MV_PAR03: Do Pedido?             ³
//³MV_PAR04: Ate o Pedido?          ³
//³MV_PAR05: Do Fornecedor?         ³
//³MV_PAR06: Da Loja?               ³
//³MV_PAR07: Ate o Fornecedor?      ³
//³MV_PAR08: Ate a Loja?            ³
//³MV_PAR09: Filial Central?        ³
//³MV_PAR10: Exibir os Dados?       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

//--Inicio do Processo
AAdd( aSays, STR0002)
AAdd( aSays, STR0003)
AAdd( aSays, ' ' )
AAdd( aSays, STR0004)

FormBatch (	cTitle, aSays,;
		  {{5, .T., {|o| Pergunte (cPerg, .T.)}},;
		  { 1, .T., {|o| nOpcA := 1, o:oWnd:End()}},;
		  { 2, .T., {|o| nOpcA := 2, o:oWnd:End()}}})

If nOpcA == 1
	Processa( {|lEnd| A178ProcPC( @lEnd )}, STR0005, STR0006, .T. )
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A178ProcPC³Autor        ³Vitor Raspa     ³Data  ³ 18.Jun.08³±±
±±³          ³          ³Padronização ³Julio C.Guerato ³Data  ³ 15.Set.09³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³Processamento da Rotina                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function A178ProcPC( lEnd )
Local cQuery    := ''
Local cAliasQry := ''
Local cFilSA2   := ''

Local aButtons  := {}
Local aCabec    := {}
Local aItens    := {}

Local oOk       := LoadBitmap( GetResources(), 'LBOK' )
Local oNo       := LoadBitmap( GetResources(), 'LBNO' )
Local oDlg, oBrwPC            

Local nOpcA     := 0
Local nTotReg   := 0
Local nTamFilSA2:= 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³MONTAGEM DA QUERY                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nTamFilSA2:=Len(AllTrim(xFilial('SA2')))
cFilSA2   :=Substr(MV_PAR09,1,nTamFilSA2)

//--Obtem a Qtd. de Registros a serem processados...
cQuery := "Select COUNT(*) NUMREG "
cQuery += "  From " + RetSQLTab('SC7')
cQuery += " Where SC7.C7_FILIAL     = '" + MV_PAR09 + "' "
cQuery += "   And SC7.C7_EMISSAO   BETWEEN '" + DtoS( MV_PAR01 ) + "' AND '" + DtoS( MV_PAR02 ) + "'"
cQuery += "   And SC7.C7_NUM       BETWEEN '" + MV_PAR03 + "' AND '" + MV_PAR04 + "'"
cQuery += "   And SC7.C7_FORNECE   BETWEEN '" + MV_PAR05 + "' AND '" + MV_PAR07 + "'"
cQuery += "   And SC7.C7_LOJA      BETWEEN '" + MV_PAR06 + "' AND '" + MV_PAR08 + "'"
cQuery += "   And SC7.C7_FILENT    <> '" + MV_PAR09 + "'"
cQuery += "   And SC7.C7_RESIDUO    = ' ' "
cQuery += "   And SC7.D_E_L_E_T_    = ' ' "                         

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³EXECUCAO DA QUERY                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cAliasQry := GetNextAlias()
cQuery    := ChangeQuery( cQuery )
DbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasQry, .T., .F. )
nTotReg := (cAliasQry)->NUMREG
(cAliasQry)->( DbCloseArea() )

If nTotReg > 0
	//--Query principal - Selecao dos Registros
	cQuery := "Select SC7.C7_NUM,     SC7.C7_EMISSAO, SC7.C7_TIPO, "
	cQuery += "       SC7.C7_FORNECE, SC7.C7_LOJA,    SA2.A2_NOME, SC7.C7_FILENT "
	cQuery += "  From " + RetSQLTab('SC7') + ", " + RetSQLTab('SA2') 
	cQuery += " Where SC7.C7_FILIAL     = '" + MV_PAR09 + "'"
	cQuery += "   And SC7.C7_EMISSAO    BETWEEN '" + DtoS( MV_PAR01 ) + "' AND '" + DtoS( MV_PAR02 ) + "'"
	cQuery += "   And SC7.C7_NUM        BETWEEN '" + MV_PAR03 + "' AND '" + MV_PAR04 + "'"
	cQuery += "   And SC7.C7_FORNECE    BETWEEN '" + MV_PAR05 + "' AND '" + MV_PAR07 + "'"
	cQuery += "   And SC7.C7_LOJA       BETWEEN '" + MV_PAR06 + "' AND '" + MV_PAR08 + "'"
	cQuery += "   And SC7.C7_FILENT     <> '" + MV_PAR09 + "'"
	cQuery += "   And SC7.C7_RESIDUO    = ' ' "
	cQuery += "   And SC7.D_E_L_E_T_    = ' ' "
	cQuery += "   And SA2.A2_FILIAL     = '" + cFilSA2 + "'"
	cQuery += "   And SA2.A2_COD        = SC7.C7_FORNECE "
	cQuery += "   And SA2.A2_LOJA       = SC7.C7_LOJA "
	cQuery += "   And SA2.D_E_L_E_T_    = ' ' "
	cQuery += "Group BY SC7.C7_NUM, SC7.C7_EMISSAO, SC7.C7_TIPO, SC7.C7_FORNECE, SC7.C7_LOJA, "
	cQuery += "      SA2.A2_NOME,   SC7.C7_FILENT "
	cQuery += "Order BY SC7.C7_FORNECE, SC7.C7_LOJA, SC7.C7_FILENT "
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³EXECUCAO DA QUERY                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cAliasQry := GetNextAlias()
	cQuery    := ChangeQuery( cQuery )
	DbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasQry, .T., .F. )

	//--Ajusta o Campo Data
	TCSetField( cAliasQry, "C7_EMISSAO" ,"D", TamSX3("C7_EMISSAO")[1], 0)

	//--Exibe os dados em tela
	If MV_PAR10 == 1
		//--Cabecalho
		AAdd( aCabec, '' )
		AAdd( aCabec, RetTitle( 'C7_NUM' ) )
		AAdd( aCabec, RetTitle( 'C7_EMISSAO' ) )
		AAdd( aCabec, RetTitle( 'C7_TIPO' ) )
		AAdd( aCabec, RetTitle( 'C7_FORNECE' ) )
		AAdd( aCabec, RetTitle( 'C7_LOJA' ) )
		AAdd( aCabec, RetTitle( 'A2_NOME' ) )
		AAdd( aCabec, RetTitle( 'C7_FILENT' ) )

		//--Itens
		ProcRegua( nTotReg )
		While !(cAliasQry)->( Eof() ) .And. !lEnd
			AAdd( aItens, {	.T.,;			//--[01]
				(cAliasQry)->C7_NUM,;		//--[02]
				(cAliasQry)->C7_EMISSAO,;	//--[03]
				(cAliasQry)->C7_TIPO,;		//--[04]
				(cAliasQry)->C7_FORNECE,;	//--[05]
				(cAliasQry)->C7_LOJA,;		//--[06]
				(cAliasQry)->A2_NOME,;		//--[07]
				(cAliasQry)->C7_FILENT } )	//--[08]

			(cAliasQry)->( DbSkip() )
			IncProc()
		EndDo

		//--Montagem da Tela / Browse
		AAdd( aButtons, {'TK_FIND' 		, {|| A178Brw( @aItens, @oBrwPC ) }  		, 'Pesquisar'			, 'Pesquisar'} )
		AAdd( aButtons, {'PMSZOOMIN'	, {|| A178ViewPC( MV_PAR09, aItens[oBrwPC:nAT,02] ) }	, 'Visualizar Pedido'	, 'Pedido'   } )

		Define MSDialog oDlg Title 'Seleção dos Pedidos' From 000, 000 To 450, 855 Pixel
			oBrwPC := TWBrowse():New(	035, 005, 420, 180,, aCabec,, oDlg,,,,, {||},,,,,,, .F.,, .T.,, .F. )

			oBrwPC:bLDblClick := {|| aItens[oBrwPC:nAT,1] := !aItens[oBrwPC:nAT,1] }
		
			oBrwPC:SetArray( aItens )
			oBrwPC:bLine := {|| {	If( aItens[ oBrwPC:nAT, 01 ], oOk, oNo ),; 
									aItens[ oBrwPC:nAT, 02 ], aItens[ oBrwPC:nAT, 03 ], aItens[ oBrwPC:nAT, 04 ],; 
									aItens[ oBrwPC:nAT, 05 ], aItens[ oBrwPC:nAT, 06 ], aItens[ oBrwPC:nAT, 07 ],;
									aItens[ oBrwPC:nAT, 08 ] } }
									
			If lLGPD
				oBrwPC:aObfuscatedCols := {.F., .F., .F., .F.,.F., .F., ;
				OfuscaLGPD(,"A2_NOME") , .F.}
			Endif

		Activate MSDialog oDlg Center On Init EnchoiceBar( oDlg,	{|| nOpcA := 1, oDlg:End()},; 
																	{|| nOpcA := 0, oDlg:End()},, aButtons )
	Else
		nOpcA := 1	
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³CONFIRMA O PROCESSAMENTO            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nOpcA == 1
		//--Aglutina os Pedidos
		Processa( {|| A178Aglut( cAliasQry, aItens, nTotReg )}, STR0005, STR0008, .F. )
	EndIf
	(cAliasQry)->( DbCloseArea() )

Else
	Aviso( STR0007, STR0009, {'OK'} )
EndIf


Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A178Aglut ³Autor        ³Vitor Raspa     ³Data  ³ 18.Jun.08³±±
±±³          ³          ³Padronização ³Julio C.Guerato ³Data  ³ 15.Set.09³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Realiza a Aglutinacao dos Pedidos de Compra               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function A178Aglut( cAliasQry, aItens, nTotReg )
Local aPedCom    := {}
Local aCbPC      := {}
Local aItPC      := {}
Local aMsgErr    := {}
Local aArea      := GetArea()
Local aAreaSC7   := SC7->( GetArea())

Local cItemPC    := ''
Local cItemPCAtu := ''

Local cQuebra    := ''
Local cFilEntr   := ''
Local cTxtLog    := ''
Local cFilAntBKP := cFilAnt

Local nCount     := 0
Local nPosPC     := 0
Local nResiduo   := 0

Local lProcPC    := .F.   
Local lMT178GRV  := ExistBlock("MT178GRV")   

Private lMsErroAuto := .F.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³INICIO DO PROCESSAMENTO             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cFilAnt := MV_PAR09
(cAliasQry)->( DbGoTop() )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³INICIO DA TRANSACAO                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Begin Transaction

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ELIMINACAO DE RESIDUO               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ProcRegua( nTotReg )
While !(cAliasQry)->( Eof() )

	SC7->( DbSetOrder(1) )
	If SC7->( DbSeek( xFilial('SC7') + (cAliasQry)->C7_NUM ) )
		If cQuebra <> SC7->(C7_FORNECE + C7_LOJA)
			aCbPC   := {}
			aItPC   := {}
			cItemPC := StrZero(0, Len( SC7->C7_ITEM ) )
			cQuebra := (cAliasQry)->(C7_FORNECE + C7_LOJA)
		
			//--Cabecalho do PC
			AAdd( aCbPC, {"C7_NUM"		, Criavar("C7_NUM",.T.)		, Nil})	//--Numero do Pedido
			AAdd( aCbPC, {"C7_EMISSAO"	, dDataBase					, Nil})	//--Data de Emissao
			AAdd( aCbPC, {"C7_FORNECE"	, SC7->C7_FORNECE			, Nil})	//--Fornecedor
			AAdd( aCbPC, {"C7_LOJA"		, SC7->C7_LOJA				, Nil})	//--Loja do Fornecedor
			AAdd( aCbPC, {"C7_COND"		, SC7->C7_COND				, Nil})	//--Condicao de Pagamento
			AAdd( aCbPC, {"C7_CONTATO"	, SC7->C7_CONTATO			, Nil})	//--Contato
			AAdd( aCbPC, {"C7_FILENT"	, MV_PAR09					, Nil})	//--Filial de Entrega

			AAdd( aPedCom, Array(2) )
			ATail(aPedCom)[1] := aCbPC
			ATail(aPedCom)[2] := {}
		EndIf

		While !SC7->( Eof() ) .And. SC7->(C7_FILIAL + C7_NUM) == xFilial('SC7') + (cAliasQry)->C7_NUM
			//--Se os dados foram exibidos em tela, 
			//--verifica se o pedido em questao foi selecionado para o processamento!
			lProcPC := .T.
			If MV_PAR10 == 1
				nPosPC := ASCan( aItens, {|x| x[2] == SC7->C7_NUM} )
				If nPosPC <> 0 .And. aItens[nPosPC,1]
					lProcPC := .T.
				Else
					lProcPC := .F.
				EndIf
			EndIf
	
			If lProcPC
				//--Elimina 100% do residuo
				nResiduo := ( SC7->C7_QUANT * 100 ) / 100
				If SC7->( C7_QUANT - C7_QUJE ) <= nResiduo .And. SC7->( C7_QUANT > C7_QUJE )
						cFilEntr := SC7->C7_FILENT
						If !SB2->( DbSeek( cFilEntr + SC7->(C7_PRODUTO + C7_LOCAL) ) )
							CriaSb2( SC7->C7_PRODUTO, SC7->C7_LOCAL, cFilEntr )
						Endif
				
						RecLock( 'SC7', .F. )
							SC7->C7_RESIDUO := 'S'
						SC7->( MsUnLock() )				

						//--Atualiza os dados do SB2 (B2_SALPEDI)
						GravaB2Pre( '-' , (SC7->(C7_QUANT-C7_QUJE-C7_QTDACLA)), SC7->C7_TPOP,; 
									( SC7->(C7_QUANT-C7_QUJE-C7_QTDACLA) * ( SC7->(C7_QTSEGUM/C7_QUANT) ) ) )

						//--Adiciona item para geracao de um novo PC
						If Len( ATail(aPedCom)[2] ) > 0
							nPosPC := AScan( ATail(aPedCom)[2], {|x| x[2,2] == SC7->C7_PRODUTO} )
						Else
							nPosPC := 0
						EndIf
				
						If nPosPC == 0		
							cItemPC := Soma1( cItemPC )
							cItemPCAtu := cItemPC
							
							AAdd( ATail(aPedCom)[2], {	{ "C7_ITEM"		, cItemPC				, NIL },;
														{ "C7_PRODUTO"	, SC7->C7_PRODUTO		, NIL },;
														{ "C7_QUANT"	, SC7->C7_QUANT			, NIL },;
														{ "C7_PRECO"	, SC7->C7_PRECO			, NIL },;
														{ "C7_TES"		, SC7->C7_TES			, NIL },;
														{ "C7_COND"		, SC7->C7_COND			, NIL } } )
						Else
						 	ATail(aPedCom)[2,nPosPC,3,2] += SC7->C7_QUANT
						 	cItemPCAtu := ATail(aPedCom)[2,nPosPC,1,2]
						EndIf
						
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Ponto de Entrada: MT17GRV   ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ   
						If lMT178GRV
							ExecBlock("MT178GRV",.T.,.T.,{aCbPC,aPedCom})
						EndIf
						
						//--Atualiza os dados na tabela auxiliar de controle
						//--de saldos previstos...
						RecLock('SDP', .T. )
							SDP->DP_FILIAL := xFilial('SDP') 
							SDP->DP_FILCEN := MV_PAR09
							SDP->DP_FILNEC := SC7->C7_FILENT
							SDP->DP_CODPRO := SC7->C7_PRODUTO
							SDP->DP_QUANT  := SC7->C7_QUANT
							SDP->DP_PEDCEN := aCbPC[1,2]
							SDP->DP_ITPCCN := cItemPCAtu                             
							SDP->DP_PEDORI := SC7->C7_NUM
							SDP->DP_ITPCOR := SC7->C7_ITEM
						SDP->( MsUnLock() )
				EndIf
			EndIf
			SC7->( DbSkip() )
		EndDo
	EndIf
	(cAliasQry)->( DbSkip() )
	IncProc()
EndDo

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³GERACAO DOS PEDIDOS AGLUTINADOS     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
IncProc(STR0010)
ProcRegua( Len( aPedCom ) )
For nCount := 1 To Len( aPedCom )
	aCbPC := aPedCom[nCount,1]
	aItPC := aPedCom[nCount,2]
	If Len( aCbPC ) > 0 .And. Len( aItPC ) > 0
		lMsErroAuto := .F.
		MSExecAuto({|v,x,y,z,w| MATA120(v, x, y, z, w) }, 1, aCbPC, aItPC, 3, .F. )
		If lMsErroAuto
			cTxtLog := NomeAutoLog()
			If ValType( cTxtLog ) == 'C'
				AAdd( aMsgErr, Memoread( cTxtLog ) )
			EndIf			
			DisarmTransaction()
		EndIf
	EndIf
	IncProc()
Next nCount

End Transaction

//--Exibe LOG com as inconsistencias encontradas...
If Len( aMsgErr ) > 0
	For nCount := 1 To Len( aMsgErr )
		AutoGrLog( aMsgErr[nCount] )
	Next nCount
	AutoGrLog('')
	MostraErro()
EndIf

//--Restaura o Ambiente
cFilAnt := cFilAntBKP
RestArea( aArea )
RestArea( aAreaSC7 )
Return              	

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A178ViewPC³Autor        ³Vitor Raspa     ³Data  ³ 18.Jun.08³±±
±±³          ³          ³Padronização ³Julio C.Guerato ³Data  ³ 15.Set.09³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Visualiza o Pedido de Compra     			             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function A178ViewPC( cFilCen, cNumPC )
Local aArea       := GetArea()
Local aAreaSC7    := SC7->( GetArea() )

Local cFilAntBKP  := cFilAnt

Private aRotina   := {}
Private l120Auto  := .F. //-- Variavel utilizada pelo MATA120
Private nTipoPed  := 1   //-- Variavel utilizada pelo MATA120
Private cCadastro := STR0011

Default cNumPC := ''

cFilAnt := cFilCen
SC7->( DbSetOrder(1) )
If SC7->( DbSeek( xFilial('SC7') + cNumPC ) )

	INCLUI := .F.
	ALTERA := .F.

	//--Monta o aRotina para compatibilizacao
	AAdd( aRotina, { '' , '' , 0, 1 } )
	AAdd( aRotina, { '' , '' , 0, 2 } )
	AAdd( aRotina, { '' , '' , 0, 3 } )
	AAdd( aRotina, { '' , '' , 0, 4 } )
	AAdd( aRotina, { '' , '' , 0, 5 } )

	//--Visualizacao do Pedido de Compra
	A120Pedido( 'SC7', SC7->( Recno() ), 2 )

EndIf

cFilAnt := cFilAntBKP
RestArea( aArea )
RestArea( aAreaSC7 )
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A178Brw   ³Autor        ³Vitor Raspa     ³Data  ³ 18.Jun.08³±±
±±³          ³          ³Padronização ³Julio C.Guerato ³Data  ³ 15.Set.09³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Realiza pesquisa no browse       			             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function A178Brw( aItens, oBrwPC )
Local aCboOrdens := {}

Local cOrdem     := ''
Local cCpoPesq   := Space(40)

Local nOrdem     := 1
Local nSeek      := 0

Local lSeek      := .F.
                                                
Local oDlgPesq, oCboOrdens, oCpoPesq

//--Adiciona as Ordens de Pesquisa...
AAdd( aCboOrdens, STR0012 )
AAdd( aCboOrdens, STR0013 )
AAdd( aCboOrdens, STR0014 )            
AAdd( aCboOrdens, STR0015 )
AAdd( aCboOrdens, STR0016 )

Define MSDialog oDlgPesq Title STR0017 From 00,00 To 100,490 Pixel

	@ 05,05 ComboBox oCboOrdens Var cOrdem Items aCboOrdens Size 206,36 Pixel Of oDlgPesq On Change (nOrdem := oCboOrdens:nAT)
	@ 22,05 MSGet oCpoPesq Var cCpoPesq Picture '@!' Size 206,10 Pixel Of oDlgPesq

	Define SButton From 05,215 Type 1 Of oDlgPesq Enable Action ( lSeek := .T., oDlgPesq:End() )
	Define SButton From 20,215 Type 2 Of oDlgPesq Enable Action ( lSeek := .F., oDlgPesq:End() )

Activate MSDialog oDlgPesq Center

If lSeek
	cCpoPesq := AllTrim( cCpoPesq )

	If nOrdem == 1
		//--Pedido
		ASort( aItens,,,{|x,y| x[2] < y[2] } )
		nSeek := AScan( aItens, {|x| x[2] == cCpoPesq } )

	ElseIf nOrdem == 2
		//--Fornecedor
		ASort( aItens,,,{|x,y| x[5] + x[6] < y[5] + y[6] } )
		nSeek := AScan( aItens, {|x| x[5] + x[6] == cCpoPesq } )
	
	ElseIf nOrdem == 3
		//--Razao social Fornecedor
		ASort( aItens,,,{|x,y| x[7] < y[7] } )
		nSeek := AScan( aItens, {|x| AllTrim( x[7] )  == cCpoPesq } )
	
	ElseIf nOrdem == 4
		//--Filial de Entrega
		ASort( aItens,,,{|x,y| x[8] < y[8] } )
		nSeek := AScan( aItens, {|x| x[8]  == cCpoPesq } )
	
	ElseIf nOrdem == 5
		//--Emissao
		ASort( aItens,,,{|x,y| x[3] < y[3] } )
		nSeek := AScan( aItens, {|x| x[3] == CtoD( cCpoPesq ) } )

	EndIf

	If	nSeek > 0
		oBrwPC:nAT := nSeek		
	EndIf
                            
	oBrwPC:Refresh()
	oBrwPC:SetFocus()
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A178Consulta ³Autor        ³Vitor Raspa     ³Data  ³ 18.Jun.08 ³±±
±±³          ³             ³Padronização ³Julio C.Guerato ³Data  ³ 15.Set.09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Consulta padrao especifica em cima da tabela SDP              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Utilizacao³ Programa de Entrada de Notas Fiscais (Campo D1_PCCENTR),      ³±±
±±³          ³ consulta padrao                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/                                                                                      
Function A178Consulta()

Local aCabec    := {}
Local aItens    := {}
Local aArea     := GetArea()
Local aAreaSM0  := SM0->(GetArea())
Local aAreaSA2  := SA2->(GetArea())

Local cQuery    := ''
Local cAliasQry := ''
Local cFilCen   := ''
Local cCodPro   := ''

Local nRegSDP   := 0
Local nOpcA     := 0

Local lRet      := .T.
Local oDlg, oBrowse, oFont


//--Obtem a filial de onde esta vindo o produto
SA2->( DbSetOrder(1) )
SA2->( DbSeek( xFilial('SA2') + cA100For + cLoja ) )

SM0->( DbSetOrder(1) )
SM0->( DbSeek( cEmpAnt ) )
While !SM0->( Eof() ) .And. Empty( cFilCen )
	If AllTrim( SA2->A2_CGC ) == AllTrim( SM0->M0_CGC )
		cFilCen := FWGETCODFILIAL
	EndIf
	SM0->( DbSkip() )
End

RestArea( aAreaSM0 )
RestArea( aAreaSA2 )
RestArea( aArea )

//--Obtem os Pedidos Centrais
cCodPro := GDFieldGet( 'D1_COD', n )
If !Empty( cCodPro )
	//--Montagem da query para obter os pedidos
	cQuery := "Select SDP.DP_FILCEN, SDP.DP_FILNEC, SDP.DP_CODPRO, "
	cQuery += "       SDP.DP_QUANT,  SDP.DP_QTDENT, SDP.DP_PEDCEN, "
	cQuery += "       SDP.DP_ITPCCN, SDP.R_E_C_N_O_ NUMREG"
	cQuery += "  From " + RetSQLTab('SDP') 
	cQuery += " Where SDP.DP_FILIAL = '" + xFilial('SDP') + "'"
	cQuery += "   And SDP.DP_FILCEN = '" + cFilCen + "'"
	cQuery += "   And SDP.DP_FILNEC = '" + cFilAnt + "'"
	cQuery += "   And SDP.DP_CODPRO = '" + cCodPro + "'"
	cQuery += "   And (SDP.DP_QUANT - SDP.DP_QTDENT)>0 "
	cQuery += "   And SDP.D_E_L_E_T_ = ' ' "
	
	//--Executa a Query...
	cAliasQry := GetNextAlias()
	cQuery    := ChangeQuery( cQuery )
	DbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasQry, .T., .F. )
	
	If !(cAliasQry)->( Eof() )		
		//--Cabecalho do Grid
		AAdd( aCabec, RetTitle( 'DP_FILCEN' ) )
		AAdd( aCabec, RetTitle( 'DP_PEDCEN' ) )
		AAdd( aCabec, RetTitle( 'DP_ITPCCN' ) ) 
		AAdd( aCabec, RetTitle( 'DP_QUANT'  ) )
		AAdd( aCabec, RetTitle( 'DP_QTDENT' ) )
		AAdd( aCabec, 'Saldo Atual' )
		
		//--Itens		
		While !(cAliasQry)->( Eof() )
			AAdd( aItens, {	(cAliasQry)->DP_FILCEN,;
				(cAliasQry)->DP_PEDCEN,;
				(cAliasQry)->DP_ITPCCN,;
				(cAliasQry)->DP_QUANT,;
				(cAliasQry)->DP_QTDENT,;
				(cAliasQry)->(DP_QUANT - DP_QTDENT),;
				(cAliasQry)->NUMREG } )

			(cAliasQry)->( DbSkip() )
		EndDo

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³TELA                                ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ			
		Define MSDialog oDlg Title STR0028 From 000, 000 To 250, 500 Pixel
			oFont := TFont():New( 'Arial',, -12,, .T. )
			TSay():New( 18, 05, {|| STR0029 + AllTrim( cCodPro ) + ' - ' + Posicione('SB1', 1, xFilial('SB1') + cCodPro, 'B1_DESC')},;
							oDlg,, oFont,,,,.T., CLR_RED, CLR_WHITE, 220, 020 )

			oBrowse := TWBrowse():New(	035, 005, 240, 080,, aCabec,, oDlg,,,,, {||},,,,,,, .F.,, .T.,, .F. )
			oBrowse:bLDblClick := {|| nOpcA := 1, nRegSDP := aItens[oBrowse:nAT,7], oDlg:End() }		
			oBrowse:SetArray( aItens )
			oBrowse:bLine := {|| {	aItens[ oBrowse:nAT, 01 ], aItens[ oBrowse:nAT, 02 ],; 
									aItens[ oBrowse:nAT, 03 ], aItens[ oBrowse:nAT, 04 ],;
									aItens[ oBrowse:nAT, 05 ], aItens[ oBrowse:nAT, 06 ] } }

		Activate MSDialog oDlg Center On Init EnchoiceBar( oDlg, {|| nOpcA := 1, nRegSDP := aItens[oBrowse:nAT,7], oDlg:End()},;
																	{|| nOpcA := 0, oDlg:End()} )

		If nOpcA == 1
			lRet := .T.
			SDP->( DbGoTo( nRegSDP ) )
		Else
			lRet := .F.
		EndIf

	Else
		lRet := .F.
		Aviso(STR0030,STR0031,{'OK'})
	EndIf
    (cAliasQry)->( DbCloseArea() )
    
Else
	lRet := .F.
	Aviso(STR0030,STR0032,{'OK'})
EndIf

Return( lRet )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A178Valida ³Autor        ³Vitor Raspa     ³Data  ³ 18.Jun.08³±±
±±³          ³           ³Padronização ³Julio C.Guerato ³Data  ³ 15.Set.09³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Valida a digitacao dos valores no campo D1_PCCENTR e       ³±±
±±³          ³ D1_ITPCCEN                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A178Valid( cCampo )
Local cFilCen  := ''

Local aArea    := GetArea()
Local aAreaSM0 := SM0->( GetArea() )
Local aAreaSA2 := SA2->( GetArea() )

Local lRet     := .F.

Default cCampo := ReadVar()

//--Obtem a filial de onde esta vindo o produto
SA2->( DbSetOrder(1) )
SA2->( DbSeek( xFilial('SA2') + cA100For + cLoja ) )

SM0->( DbSetOrder(1) )
SM0->( DbSeek( cEmpAnt ) )
While !SM0->( Eof() ) .And. Empty( cFilCen )
	If AllTrim( SA2->A2_CGC ) == AllTrim( SM0->M0_CGC )
		cFilCen := FWGETCODFILIAL
	EndIf
	SM0->( DbSkip() )
EndDo
		
RestArea( aAreaSM0 )
RestArea( aAreaSA2 )
RestArea( aArea )

//--Valida os campos...
If cCampo $ 'M->D1_PCCENTR'
	If !Empty( GDFieldGet( 'D1_ITPCCEN', n ) )
		SDP->( DbSetOrder(2) ) //--DP_FILIAL+DP_FILCEN+DP_FILNEC+DP_PEDCEN+DP_ITPCCN
		If SDP->( DbSeek( xFilial('SDP') + cFilCen + cFilAnt + M->D1_PCCENTR + GDFieldGet( 'D1_ITPCCEN', n ) ) )
			If GDFieldGet('D1_COD',n) == SDP->DP_CODPRO
				If SDP->(DP_QUANT - DP_QTDENT)  > 0			
					lRet := .T.
					If Empty( GDFieldGet( 'D1_QUANT', n ) )
						GDFieldPut( 'D1_QUANT', SDP->(DP_QUANT-DP_QTDENT), n )
					EndIf
				Else
					lRet := .F.      
					Aviso(STR0030,STR0033,{'OK'})
				EndIf
			Else
				lRet := .F. 
				Aviso(STR0030,STR0037+CHR(13)+SDP->DP_CODPRO,{'OK'})
			EndIf                                                    
		Else
			lRet := .F.
			Aviso(STR0030,STR0034,{'OK'})
		EndIf
	Else
		lRet := .T.
	EndIf

ElseIf cCampo $ 'M->D1_ITPCCEN'
	If !Empty( GDFieldGet( 'D1_PCCENTR', n ) )
		SDP->( DbSetOrder(2) ) //--DP_FILIAL+DP_FILCEN+DP_FILNEC+DP_PEDCEN+DP_ITPCCN
		If SDP->( DbSeek( xFilial('SDP') + cFilCen + cFilAnt + GDFieldGet( 'D1_PCCENTR', n ) + M->D1_ITPCCEN ) )
			If GDFieldGet('D1_COD',n) == SDP->DP_CODPRO
				If SDP->(DP_QUANT - DP_QTDENT) > 0
					lRet := .T. 
					If Empty( GDFieldGet( 'D1_QUANT', n ) )
						GDFieldPut( 'D1_QUANT', SDP->(DP_QUANT - DP_QTDENT), n )
					EndIf
				Else
					lRet := .F. 
					Aviso(STR0030,STR0033,{'OK'})
				EndIf
			Else
				lRet := .F. 
				Aviso(STR0030,STR0037+CHR(13)+SDP->DP_CODPRO,{'OK'})
			EndIf                                                    
		Else
			lRet := .F.
			Aviso(STR0030,STR0034,{'OK'})
		EndIf
	Else
		lRet := .T.
	EndIf
EndIf		

Return( lRet )
