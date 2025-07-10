#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWADAPTEREAI.CH"
#INCLUDE "MATA111.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} MATA111
Fonte com as funcoes para envio das Solicitacoes de Compra atraves da integracao 
Protheus X MarketPlace ( WBC - Paradigma)

@author Leonardo Quintania
@since 10/05/2013
@version 1.0
/*/
//-------------------------------------------------------------------

Function MATA111()

Local cPerg      := "MTA111"
Local aCores  	 := {}
Local cFilSC1    := xFilial("SC1")
Local cFilSB5    := xFilial("SB5")
Local cFilSB1    := xFilial("SB1")   

Private oMarkBrow  := NIL
Private aRotina	   := MenuDef()
Private cCadastro  := STR0001 //"Integração Portal Marketplace"
Private cFilBrw    := ""


//-------------------------------------------------------------------
/*/
mv_par01: Solicitacao de:				
mv_par02: Solicitacao ate:				
mv_par03: Produto de:					
mv_par04: Produto ate: 					
mv_par05: Emissao de:	 				
mv_par06: Emissao ate:  				
mv_par07: Previsao entrega de:			
mv_par08: Previsao entrega ate:			
/*/
//-------------------------------------------------------------------

If Pergunte(cPerg,.T.)
	//-- Monta filtro para browse
	cFilBrw := " C1_NUM >= '" +mv_par01 +"' .And. C1_NUM <= '" +mv_par02 +"' .And. "
	cFilBrw += " C1_PRODUTO >= '" +mv_par03 +"' .And. C1_PRODUTO <= '" +mv_par04 +"' .And. "
	cFilBrw += " DToS(C1_EMISSAO) >= '"  +DToS(mv_par05) +"' .And. DToS(C1_EMISSAO) <= '"  +DToS(mv_par06) +"' .And. "
	cFilBrw += " DToS(C1_DATPRF) >= '"  +DToS(mv_par07) +"' .And. DToS(C1_DATPRF) <= '"  +DToS(mv_par08) +"' .And. "
	cFilBrw += " C1_ACCPROC <> '1' .And. " //Apenas solicitacoes que possuem integracao.
	
	cFilBrw += " C1_QUJE == 0  .And."   								//Somente o que nao foi atendida
	cFilBrw += " C1_COTACAO == '"+Space(Len(SC1->C1_COTACAO))+"' .And. " 		//Nao possui cotacao 
	cFilBrw += " C1_RESIDUO <> 'S' .And. " 							//Nao e residuo
	cFilBrw += " C1_IMPORT <> 'S' .And. " 							//Nao e produto importado
	cFilBrw += " C1_APROV $ ' ,L'" 									//Nao possui controle de alcadas ou alcadas esta aprovada.
	
	oMarkBrow:= FWMarkBrowse():New()
	oMarkBrow:SetDescription( STR0007 ) 							// Marketplace
	oMarkBrow:SetAlias( 'SC1' )
	oMarkBrow:SetMenuDef( 'MATA111' )
	oMarkBrow:SetFieldMark( "C1_OK" )
	oMarkBrow:SetCustomMarkRec({|| A111MkB(oMarkBrow) })
	oMarkBrow:SetAllMark({|| A111MkBTud(oMarkBrow) })
	oMarkBrow:SetWalkThru(.F.)
	oMarkBrow:SetAmbiente(.F.) 
	oMarkBrow:SetFilterDefault( cFilBrw )
    oMarkBrow:AddFilter("PRODUTO","C1_PRODUTO = (SELECT SB1.B1_COD FROM "+RetSqlName("SB1")+" SB1, " + RetSqlName("SB5") + " SB5 WHERE C1_FILIAL = '" + cFilSC1 + "' AND B1_FILIAL = '" + cFilSB1 + "' AND B5_FILIAL = '" + cFilSB5 + "' AND C1_PRODUTO=SB1.B1_COD AND C1_PRODUTO=SB5.B5_COD AND SB5.B5_ENVMKT<>'0' AND  SB5.D_E_L_E_T_ = ' ' )",.T.,.T.,"SB1")
	oMarkBrow:SetParam({||Pergunte(cPerg,.T.)})
	oMarkBrow:DisableReport(.T.)
	oMarkBrow:Activate()
EndIf	

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
@return aRotina - Estrutura
[n,1] Nome a aparecer no cabecalho
[n,2] Nome da Rotina associada
[n,3] Reservado
[n,4] Tipo de Transação a ser efetuada:
	1 - Pesquisa e Posiciona em um Banco de Dados
	2 - Simplesmete Mostra os Campos
	3 - Inclui registros no Bancos de Dados
	4 - Altera o registro corrente
	5 - Remove o registro corrente do Banco de Dados
	6 - Alteração sem inclusão de registros
	7 - Cópia
	8 - Imprimir
[n,5] Nivel de acesso
[n,6] Habilita Menu Funcional
@author Raphael Augustos
@since 10/05/2013
@version 1.0
/*/
//-------------------------------------------------------------------

Static Function MenuDef()
PRIVATE aRotina	:= {}

ADD OPTION aRotina TITLE STR0002			ACTION 'PesqBrw'       					OPERATION 1  ACCESS 0 //"Pesquisar"
ADD OPTION aRotina TITLE STR0003			ACTION 'VIEWDEF.MATA111' 				OPERATION 2  ACCESS 0 //"Visualizar"
ADD OPTION aRotina TITLE STR0004			ACTION 'StaticCall(MATA111,A111Enviar)'		OPERATION 4  ACCESS 0 //"Enviar para o Portal" 

Return aRotina
                      
//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
ViewDef
@author Raphael Augusto
@since 18/07/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oModel    := FWLoadModel( "MATA111" )
Local oStruSC1  := FWFormStruct( 2, "SC1" )
Local oView

oView := FWFormView():New()
oView:SetModel( oModel )
oView:AddField( "VIEW_SC1", oStrusC1, "SC1MASTER" )

Return oView 

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Model
@author Raphael Augusto
@since 18/07/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oStruSC1 := FWFormStruct( 1, "SC1", /*bAvalCampo*/,/*lViewUsado*/ )
Local oModel

oModel := MPFormModel():New("MATA111", /*bPreValidacao*/, /**/, /*bCommit*/, /*bCancel*/ )
oModel:AddFields( "SC1MASTER", /*cOwner*/, oStruSC1, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )
oModel:SetDescription("Solicitcação de Compra")
oModel:GetModel( "SC1MASTER" ):SetDescription("Solicitação de Compra")

Return oModel 

//-------------------------------------------------------------------
/*/{Protheus.doc} Enviar
Processa o envio das solicitacoes ao portal Marketplace
@author Raphael Augustos
@since 10/05/2013
@version 1.0
/*/
//-------------------------------------------------------------------

Static Function A111Enviar()
Local aAreaSC1   := SC1->(GetArea())
//-- Variavel usada para verificar se o disparo da funcao IntegDef() pode ser feita manualmente
Local lIntegDef  := FWHasEAI("MATA110",.T.,,.T.)

If MsgYesNo(STR0005, STR0006) //-- Confirma o envio das Solicitacoes de Compra ao portal Marketplace? # Atencao
	If lIntegDef
		oMarkBrow:SetFilterDefault( cFilBrw ) 
		(oMarkBrow:Alias())->( DbGoTop() )
		While (oMarkBrow:Alias())->( !Eof() )
			If ( oMarkBrow:IsMark() ) // Transmite apenas as notas selecionadas
				Inclui:=.T.			
				SetRotInteg('MATA110')
				FwIntegDef( 'MATA110') // Executa chamada IntegDef do proprio fonte que chama MATA110
			EndIf
		(oMarkBrow:Alias())->( DbSkip() )
		End
		Aviso(STR0007,STR0018,{STR0009})
	Else
		Aviso(STR0007,STR0008,{STR0009}) //"MarketPlace" | "É necessario efetuar configurações do EAI." | "OK"
	EndIf		
EndIf	

oMarkBrow:Refresh()
oMarkBrow:SetFilterDefault( cFilBrw )
RestArea(aAreaSC1)  
Return

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} A111MkB
Funcao para os marcar os registros da MarkBrowse.
		
@return	ExpL	Verdadeiro / Falso
@author	Leonardo Quintania
@since		24/05/2012       
@version	P11   
/*/        
//--------------------------------------------------------------------------------
Static Function A111MkB(oMrkBrowse)

If ( !oMrkBrowse:IsMark() )
	RecLock(oMrkBrowse:Alias(),.F.)
	(oMrkBrowse:Alias())->C1_OK  := oMrkBrowse:Mark()
	(oMrkBrowse:Alias())->(MsUnLock())
	
Else
	RecLock(oMrkBrowse:Alias(),.F.)
	(oMrkBrowse:Alias())->C1_OK  := ""
	(oMrkBrowse:Alias())->(MsUnLock())
EndIf     

Return( .T. )


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} A111MkBTud
Funcao para os marcar os registros da MarkBrowse.
		
@return	ExpL	Verdadeiro / Falso
@author	Raphael Augusts
@since		24/05/2012       
@version	P11   
/*/        
//--------------------------------------------------------------------------------
Static Function A111MkBTud(oMrkBrowse)
Local cAlias		:= oMrkBrowse:Alias()
Local aAreaSC1   	:= SC1->(GetArea())

(cAlias)->(DbSeek(xFilial((cAlias))))
While (cAlias)->(!Eof()) .And. (cAlias)->C1_FILIAL == xFilial(cAlias)
	If (!oMrkBrowse:IsMark())
		RecLock((cAlias),.F.)
		(cAlias)->C1_OK  := oMrkBrowse:Mark()
		(cAlias)->(MsUnLock())
	Else
		RecLock(cAlias,.F.)
		(cAlias)->C1_OK  := ""
		(cAlias)->(MsUnLock())
	EndIf 
	(cAlias)->(DbSkip())  
End

oMarkBrow:Refresh()
oMarkBrow:SetFilterDefault( cFilBrw )
RestArea(aAreaSC1) 
Return( .T. )
