#include "MATA181.CH"
#INCLUDE "PROTHEUS.CH" 
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE 'FWLIBVERSION.CH'
//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef()
Definicao do Modelo
@author Leonardo Quintania
@since 28/01/2013
@version 1.0
@return oModel
/*/
//-------------------------------------------------------------------
Static Function ModelDef()  
Local oStruCab := FWFormStruct(1,"DBJ") //Estrutura Cabecalho 
Local oStruDBH := FWFormStruct(1,"DBH") //Estrutura Itens DBH 
Local oStruDBI := FWFormStruct(1,"DBI") //Estrutura Itens DBI
Local oStruCPM := FWFormStruct(1,"CPM") //Estrutura da CPM
Local oModel   := MPFormModel():New("MATA181",/*Pre-Validacao*/, /*Pos-Validacao*/, /*bCommit*/,/*Cancel*/)
//------------------------------------------------------
//		Adiciona o componente de formulario no model 
//     Nao sera usado, mas eh obrigatorio ter
//------------------------------------------------------	
oModel:AddFields("DBJMASTER",/*cOwner*/ ,oStruCab) //Cabecalho
oModel:AddGrid("DBHDETAILS","DBJMASTER" ,oStruDBH) //Itens DBH
oModel:AddGrid("DBIDETAILS","DBHDETAILS",oStruDBI,{ |oModelGrid, nLine, cAction, cField| MTA181LPRE(oModelGrid,nLine,cAction,cField,"DBIDETAILS")}) //Itens DBI
oModel:AddGrid("CPMDETAILS","DBIDETAILS",oStruCPM) //Doc CPM

//--------------------------------------
//		Configura o model
//--------------------------------------
oModel:SetPrimaryKey( {} ) //Obrigatorio setar a chave primaria (mesmo que vazia)

oModel:SetRelation("DBHDETAILS",{{"DBH_FILIAL",'xFilial("DBH")'},{"DBH_SUGEST","DBJ_SUGEST"}},DBH->(IndexKey(2)))
oModel:SetRelation("DBIDETAILS",{{"DBI_FILIAL",'xFilial("DBI")'},{"DBI_SUGEST","DBH_SUGEST"},{"DBI_FILABA","DBH_FILABA"}},DBI->(IndexKey(1))) 
oModel:SetRelation("CPMDETAILS",{{"CPM_SUGEST","DBI_SUGEST"},{"CPM_FILABA","DBH_FILDIS"},{"CPM_PRODUT","DBI_PRODUT"}},CPM->(IndexKey(1)))

oModel:GetModel("DBHDETAILS" ):SetDescription(STR0001) //STR0001//"Abastecidas"
oModel:GetModel("DBIDETAILS" ):SetDescription(STR0002) //STR0002//"Produtos"


//Seta permissoes somente para nao incluir linhas
oModel:GetModel( "DBHDETAILS" ):SetNoInsertLine( .T. )
oModel:GetModel( "DBIDETAILS" ):SetNoInsertLine( .T. )

//Seta permissoes somente para nao deletar linhas
oModel:GetModel( "DBHDETAILS" ):SetNoDeleteLine( .T. )
oModel:GetModel( "DBIDETAILS" ):SetNoDeleteLine( .T. )

oModel:GetModel( "DBIDETAILS" ):SetOptional( .T. )



//Modelo de preechimento opcional
oModel:GetModel("CPMDETAILS" ):SetDescription(STR0029) // Documentos
oModel:GetModel( "CPMDETAILS" ):SetNoInsertLine( .T. )
oModel:GetModel( "CPMDETAILS" ):SetNoDeleteLine( .T. )
oModel:GetModel( "CPMDETAILS" ):SetNoUpdateLine( .T. )
oModel:GetModel( "CPMDETAILS" ):SetOptional( .T. )

//--------------------------------------
//		Validacao para nao permitir execucao de registros ja processados
//--------------------------------------
oModel:SetVldActivate( {|oModel| A181VLMod(oModel) } )

oStruDBI:SetProperty( "DBI_NECINF" , MODEL_FIELD_VALID, {|a,b,c,d,e| Positivo() .And. A181SldDis(a,b,c,d,e)} )
oStruDBI:SetProperty( "DBI_SLDTRA" , MODEL_FIELD_VALID, {|a,b,c,d,e| Positivo() .And. A181SldTra(a,b,c,d,e)} )

//--------------------------------------
//		Realiza carga dos grids antes da exibicao
//--------------------------------------
oModel:SetActivate( { |oModel| A181ActMod( oModel ) } )

//Muda comportamento de grid não criando acols
oModel:GetModel( 'DBHDETAILS' ):SetUseOldGrid( .F. )
oModel:GetModel( 'DBIDETAILS' ):SetUseOldGrid( .F. )

//--------------------------------------
//		Nao gravar dados de um componente do modelo de dados
//--------------------------------------
oModel:GetModel( "DBJMASTER"):SetOnlyQuery ( .T. )


Return oModel 

//--------------------------------------------------------------------
/*/{Protheus.doc} ViewDef()
Definicao da View
@author Leonardo Quintania
@since 28/01/2013
@version 1.0
@return oView
/*/
//--------------------------------------------------------------------
Static Function ViewDef()  
Local oModel   	:= FWLoadModel( "MATA181" )	 //Carrega model definido
Local oStruCab 	:= FWFormStruct(2,"DBJ",{|cCampo|  AllTrim(cCampo) $ "DBJ_FILDIS|DBJ_NFILDI|DBJ_SUGEST"}) //Estrutura Cabecalho 
Local oStruDBH 	:= FWFormStruct(2,"DBH",{|cCampo| !AllTrim(cCampo) $ "DBH_FILDIS|DBH_NFILDI|DBH_SUGEST"}) //Estrutura Itens DBH 
Local oStruDBI 	:= FWFormStruct(2,"DBI",{|cCampo| !AllTrim(cCampo) $ "DBI_SUGEST|DBI_FILABA|DBI_COND"})//Estrutura Itens
Local oStruCPM 	:= FWFormStruct(2,"CPM",{|cCampo|  AllTrim(cCampo) $ "CPM_FILABA|CPM_TIPO|CPM_NUMDOC"})//Estrutura da CPM 
Local oView	  	:= FWFormView():New()

//--------------------------------------
//		Associa o View ao Model
//--------------------------------------
oView:SetModel(oModel)  //-- Define qual o modelo de dados será utilizado
oView:SetUseCursor(.F.) //-- Remove cursor de registros'

//--------------------------------------
//		Insere os componentes na view
//--------------------------------------
oView:AddField("MASTER_DBJ",oStruCab,"DBJMASTER")	//Cabecalho da matriz de abastecimento
oView:AddGrid("DETAILS_DBH",oStruDBH,"DBHDETAILS")	//Cabecalho da matriz de abastecimento
oView:AddGrid("DETAILS_DBI",oStruDBI,"DBIDETAILS")	//Itens da matriz de abastecimento
oView:AddGrid("DETAILS_CPM",oStruCPM,"CPMDETAILS")	//Ites do documento

//--------------------------------------
//		Cria os Box's
//--------------------------------------
oView:CreateHorizontalBox("CABEC",12)
oView:CreateHorizontalBox("GRIDDBH",24)
oView:CreateHorizontalBox("GRIDDBI",40)
oView:CreateHorizontalBox("GRIDCPM",24)

//--------------------------------------
//		Associa os componentes
//--------------------------------------
oView:SetOwnerView("MASTER_DBJ" ,"CABEC")
oView:SetOwnerView("DETAILS_DBH","GRIDDBH")
oView:SetOwnerView("DETAILS_DBI","GRIDDBI")
oView:SetOwnerView("DETAILS_CPM","GRIDCPM")

oView:EnableTitleView("DBHDETAILS",STR0003)//"Abastecidas"
oView:EnableTitleView("DBIDETAILS",STR0004)//"Produtos"
oView:EnableTitleView("CPMDETAILS",STR0029) //"Documentos"

oView:AddUserButton( STR0006	, "" , {|oView| A181ConSB1()} )//"Histórico do Produtos"
oView:AddUserButton( STR0007	, "" , {|oView| A181ConSA2()} )//"Histórico do Fornecedor"
oView:AddUserButton( STR0008	, "" , {|oView| A181Histor()} )//"Parâmetros" 
oView:AddUserButton( STR0009	, "" , {|oView| A181Cal183(oModel)} )//"Alteração Massiva"
oView:AddUserButton( STR0025	, "" , {|oView| A181VisDoc()} )//"Visualiza Documento

//--------------------------------------
//		Permissoes dos campos
//--------------------------------------
oStruCab:SetProperty("DBJ_FILDIS" ,MVC_VIEW_CANCHANGE,.F.)//Filial Distribuidora 
oStruDBI:SetProperty("DBI_DOCOMP" ,MVC_VIEW_CANCHANGE,.F.)//Doc. Compra

//--------------------------------------
//		Remove os campos de acordo com o tipo de sugestao
//--------------------------------------
If DBJ->DBJ_TPSUG == "1"
	oStruDBI:RemoveField("DBI_SLDTRA")
Else
	oStruDBI:RemoveField("DBI_NECINF")
	oStruDBI:RemoveField("DBI_QTDCOM")
	oStruDBI:RemoveField("DBI_DOCOMP")
	oStruDBI:RemoveField("DBI_FORNEC")
	oStruDBI:RemoveField("DBI_LOJA")
	oStruDBI:RemoveField("DBI_COMPNA")
	oStruDBI:RemoveField("DBI_ENTRNA")
	oStruDBI:RemoveField("DBI_QTDCOM")
	oStruDBI:RemoveField("DBI_PRECO")
	oStruDBH:RemoveField("DBH_VALTOT")
EndIf

//--------------------------------------
//		Remove os campos de acordo com o tipo de aglutinacao
//--------------------------------------
If DBJ->DBJ_TPAGLU == "1"
	oStruDBH:RemoveField("DBH_CONTOT")
	oStruDBH:RemoveField("DBH_ABATOT")
Else
	oStruDBH:RemoveField("DBH_VALTOT")
EndIf

Return oView

//--------------------------------------------------------------------
/*/{Protheus.doc} A181VLMod()
Validacao do modelo para nao permitir alterar registros efetivados
@author Leonardo Quintania
@since 28/01/2013
@version 1.0
@return aReturn
/*/
//--------------------------------------------------------------------
Static Function A181VLMod(oModel)
Local lRet := .T.
Local nOperation := oModel:GetOperation()
Local aSaveLines := FWSaveRows()

If DBJ->DBJ_FLAG # "1" 
	If nOperation == MODEL_OPERATION_UPDATE
		Help(" ",1,"A179ALTER")//"A sugestao esta efetivada, nao sera possível alteracao"
		lRet:= .F.
	ElseIf nOperation == MODEL_OPERATION_DELETE
		Help(" ",1,"A179DEL")//"A sugestao esta efetivada, nao sera possível exclusao"
		lRet:= .F.
	EndIf
EndIf

FWRestRows( aSaveLines )
Return lRet

//--------------------------------------------------------------------
/*/{Protheus.doc} A181ConSB1()
Funcao que chama historico do produto MATC050
@author Leonardo Quintania
@since 28/01/2013
@version 1.0
@return aReturn
/*/
//--------------------------------------------------------------------
Function A181ConSB1()
Local oModel	:= FWModelActive()
Local oModelDBH	:= oModel:GetModel("DBHDETAILS")
Local oModelDBI	:= oModel:GetModel("DBIDETAILS")
Local cFilAba	:= xFilial("SB1",oModelDBH:GetValue("DBH_FILABA"))
Local cProduto	:= oModelDBI:GetValue("DBI_PRODUT")
Local aSaveLines:= FWSaveRows()

SB1->(dbSeek(cFilAba + cProduto))
If Pergunte("MTC050",.T.)
	MsgRun(STR0010,STR0011,{|| MC050Con()})//"Aguarde..."//"Processando"
EndIf

FWRestRows( aSaveLines )
Return .T.

//--------------------------------------------------------------------
/*/{Protheus.doc} A181ConSA2()
Funcao que chama funcao do historico do fornecedor FINC030
@author Leonardo Quintania
@since 28/01/2013
@version 1.0
@return aReturn
/*/
//--------------------------------------------------------------------
Function A181ConSA2()
Local oModel	:= FWModelActive()
Local oModelDBH	:= oModel:GetModel("DBHDETAILS")
Local oModelDBI	:= oModel:GetModel("DBIDETAILS")
Local cFilAba	:= xFilial("SA2",oModelDBH:GetValue("DBH_FILABA"))
Local cFornec	:= oModelDBI:GetValue("DBI_FORNEC")
Local aSaveLines:= FWSaveRows()

If !Empty(cFornec)
	SA2->(dbSeek(cFilAba + cFornec))
	If Pergunte("FIC030",.T.)
		MsgRun(STR0012,STR0013,{|| Finc030("Fc030Con")})//"Aguarde..."//"Processando"
	EndIf
EndIf

FWRestRows( aSaveLines )
Return .T.

//--------------------------------------------------------------------
/*/{Protheus.doc} A181Histor()
Funcao que visualiza os parametros informados do processamento 
@author Leonardo Quintania
@since 28/01/2013
@version 1.0
@return aReturn
/*/
//--------------------------------------------------------------------
Function A181Histor()
Local aSaveLines := FWSaveRows()

FWExecView (STR0014, "MATA179", MODEL_OPERATION_VIEW ,/*oDlg*/ , {||.T.},/*bOk*/ ,/*nPercReducao*/ ,/*aEnableButtons*/ , /*bCancel*/ )//"Parâmetros"

FWRestRows( aSaveLines )
Return .T.

//--------------------------------------------------------------------
/*/{Protheus.doc} A181Cal183()
Funcao que visualiza tela de alteração massiva
@author Leonardo Quintania
@since 28/01/2013
@version 1.0
@return aReturn
/*/
//--------------------------------------------------------------------
Function A181Cal183(oModel)
Local cTitulo   := STR0015//"Alteração Massiva"
Local cPrograma	:= "MATA183"
Local aSaveLines:= FWSaveRows(oModel)
Local oSaveModel:= FwModelActive(,.T.)

If oModel:GetOperation() == MODEL_OPERATION_VIEW
	Help(" ",1,"A181ALTMAS")//"Operação disponível somente para alteração."
Else
	FWExecView( cTitulo , cPrograma, MODEL_OPERATION_INSERT, /*oDlg*/, {|| .T. } ,{|| A181Massiv(oSaveModel),.T. } , /*nPercReducao*/, /*aEnableButtons*/, /*bCancel*/ , /*cOperatId*/, /*cToolBar*/, A181LoadFil() )
EndIf

FWRestRows( aSaveLines )
FwModelActive(oSaveModel)
Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} A181LoadFil()
Realiza Load no Exec. View para enviar dados para outro Model
@author Leonardo Quintania
@since 29/12/2011
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function A181LoadFil()
Local oModel    := FWLoadModel( "MATA183" )
Local oModelDB5	:= oModel:GetModel("DB5DETAILS")
Local oModelDBI	:= oModel:GetModel("DBIMASTER")
Local oModelDBH	:= FWModelActive()
Local cSelFil	:= oModelDBH:GetModel("DBHDETAILS"):GetValue("DBH_FILABA")
Local cSugest	:= FwFldGet("DBH_SUGEST")
Local nLinha	:= 0
Local aSaveLines := FWSaveRows()

BeginSQL Alias "DBHTMP"
	SELECT *
   	FROM %Table:DBH% DBH
   	WHERE DBH.DBH_FILIAL=%xFilial:DBH% AND DBH.DBH_SUGEST=%Exp:cSugest% AND DBH.%NotDel%
EndSQL

//-- Cria o objeto de View
oModel:SetOperation(3)                                 
oModel:Activate() 

//-------------------------------------------------------------------
// Preenche as linhas do Grid com novos dados
//-------------------------------------------------------------------
While !DBHTMP->(EOF())
	nLinha++
	If nLinha # 1
		oModelDB5:AddLine()
	EndIf
	oModelDB5:LoadValue("DB5_FILABA", DBHTMP->DBH_FILABA) 
	oModelDB5:LoadValue("DB5_NFILAB", PadR(FwFilialName(,DBHTMP->DBH_FILABA),TamSx3("DB5_NFILAB")[1]))  
	If AllTrim(cSelFil) == AllTrim(DBHTMP->DBH_FILABA) 
		oModelDB5:LoadValue("DB5_OK"	 , .T. )
	Else
		oModelDB5:LoadValue("DB5_OK"	 , .F. )
	EndIf
	DBHTMP->(dbSkip())
EndDo

//Força atualização na estrutura principal que obrigatoriamente deve sofrer modificações
oModelDBI:SetValue("DOCOMP","2")

oModelDB5:SetNoInsertLine( .T. )
oModelDB5:SetNoDeleteLine( .T. )
DBHTMP->(dbCloseArea())

FWRestRows( aSaveLines )

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} A181Massiv()
Realiza Load no Exec. View para enviar dados para outro Model
@author Leonardo Quintania
@since 29/12/2011
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function A181Massiv(oModel)
Local oMd183	:= FwModelActive()
Local oMd183DB5	:= oMd183:GetModel("DB5DETAILS")
Local oMd183DBI	:= oMd183:GetModel("DBIMASTER")
Local oModelDBH	:= oModel:GetModel("DBHDETAILS")
Local oModelDBI	:= oModel:GetModel("DBIDETAILS") 
Local nX		:= 0
Local nY		:= 0
Local nZ		:= 0

oMd183:SetCommit({ || .T.})

For nX:= 1 To oMd183DB5:GetQtdLine()
	oMd183DB5:GoLine( nX )
	If oMd183DB5:GetValue("DB5_OK")
		For nY:= 1 To oModelDBH:GetQtdLine()
			oModelDBH:GoLine( nY )
			If oModelDBH:GetValue("DBH_FILABA") == oMd183DB5:GetValue("DB5_FILABA")
				For nZ:= 1 To oModelDBI:GetQtdLine()
					oModelDBI:GoLine( nZ )
					oModelDBI:LoadValue("DBI_DOCOMP",oMd183DBI:GetValue("DOCOMP"))
					oModelDBI:LoadValue("DBI_COMPNA",oMd183DBI:GetValue("COMPNA"))
					oModelDBI:LoadValue("DBI_ENTRNA",oMd183DBI:GetValue("ENTRNA"))
				Next nZ
				oModelDBI:GoLine( 1 )
			EndIf
		Next nY
	EndIf
Next nX

Return

//--------------------------------------------------------------------
/*/{Protheus.doc} A181VldDoc()
Realiza criação de filtro da tabela SB1
@author Leonardo Quintania
@since 28/01/2013
@version 1.0
@return aReturn
/*/
//--------------------------------------------------------------------
Function A181VldDoc()
Local lRet 		:= .T.
Local cFornec	:= FwFldGet("DBI_FORNEC")   
Local cLoja		:= FwFldGet("DBI_LOJA")
Local cDocComp	:= FwFldGet("DBI_DOCOMP")
           
If cDocComp # "1" 
	If Empty(cFornec) .Or. Empty(cLoja) 
		Help(" ",1,"A179FILCOM")//"O fornecedor informado não está cadastrado na filial de compra.
		lRet := .F.		
	EndIf
EndIf

Return lRet       

//--------------------------------------------------------------------
/*/{Protheus.doc} A181VldSA2()
Realiza criação de filtro da tabela SB1
@author Leonardo Quintania
@since 28/01/2013
@version 1.0
@return aReturn
/*/
//--------------------------------------------------------------------
Function A181VldSA2()
Local lRet 		:= .T.
Local cFilDist	:= xFilial("SA2", FwFldGet("DBJ_FILDIS") )
Local cFilAba	:= xFilial("SA2", FwFldGet("DBI_FILABA") )
Local cFornec	:= FwFldGet("DBI_FORNEC")
Local cLoja		:= FwFldGet("DBI_LOJA")
Local cCompra	:= FwFldGet("DBI_COMPNA")
Local oModel	:= FWModelActive()
Local oModelDBI	:= oModel:GetModel("DBIDETAILS")
Local aArea   := SA2->(GetArea())

If ("DBI_FORNEC" $ ReadVar() .And. !Empty(cFornec)) .Or. !Empty(cFornec)
	If !SA2->(dbSeek(If(cCompra=="1",cFilDist,cFilAba)+cFornec+If(Empty(cLoja),"",cLoja)))
		Help(" ",1,"A179FORNEC")//"O fornecedor informado não está cadastrado na filial de compra.
		lRet:= .F.
	Else
		If Empty(SA2->A2_COND)
			Help(" ",1,"A179A2COND")//"Este fornecedor não possui condição de pagamento.      
			lRet:= .F.
		EndIf
	EndIf
EndIf

//Atualiza condição de pagamento na alteração da sugestão de compra de acordo com o fornecedor
If ALTERA .And. !Empty(cFornec) .And. !Empty(cLoja)
	SA2->(dbSetOrder(1))
	SA2->(MsSeek(xFilial("SA2")+cFornec+cLoja))
	cCond := SA2->A2_COND 
	oModelDBI:SetValue("DBI_COND",cCond)
EndIf 

RestArea(aArea)
Return lRet

//--------------------------------------------------------------------
/*/{Protheus.doc} A181SldDis()
Recalcula saldo a distribuir conforme necessidade informada
@author Leonardo Quintania
@since 28/01/2013
@version 1.0
@return aReturn
/*/
//--------------------------------------------------------------------
Function A181SldDis(oModel,cField,xConteud,nLine,xOldValue)
Local oMaster		:= oModel:GetModel()
Local oModelDBH	:= oMaster:GetModel("DBHDETAILS")
Local oModelDBI	:= oMaster:GetModel("DBIDETAILS")
Local aSaveLines := FWSaveRows(oMaster)
Local cProduto	:= FwFldGet("DBI_PRODUT")	
Local nX			:= 0
Local nY			:= 0
Local nSldDis		:= 0
Local nNecTot		:= A181CalNec(oModel,cProduto)
Local nNecLine	:= 0
Local lRet 		:= .T.
Local nPrcTot		:= 0

For nX:= 1 To oModelDBH:GetQtdLine()
	oModelDBH:GoLine( nX )
	nPrcTot := 0
	For nY:= 1 To oModelDBI:GetQtdLine()
		oModelDBI:GoLine( nY )
		If cProduto == oModelDBI:GetValue("DBI_PRODUT")
			If !Empty(oModelDBI:GetValue("DBI_SLDDIS"))
				nSldDis:= (oModelDBI:GetValue("DBI_SLDDIS")+ xOldValue) - xConteud 
			Else
				nSldDis:= oModelDBI:GetValue("DBI_SLDFIS")-nNecTot
				oModelDBI:LoadValue("DBI_SLDDIS", Max(0,nSldDis ) )
			EndIf
			oModelDBI:LoadValue("DBI_QTDCOM", Max(0,oModelDBI:GetValue("DBI_NECINF")- Max(0,(oModelDBI:GetValue("DBI_SLDFIS")- nNecLine ) ) ) )
			oModelDBI:LoadValue("DBI_SLDDIS", Max(0,nSldDis ) )
			nNecLine:= nNecLine + oModelDBI:GetValue("DBI_NECINF")
		EndIf		
		nPrcTot += ( oModelDBI:GetValue("DBI_QTDCOM") * oModelDBI:GetValue("DBI_PRECO") )
	Next nY
	oModelDBH:LoadValue("DBH_VALTOT",nPrcTot)
	oModelDBI:GoLine( 1 )
Next nX

FWRestRows( aSaveLines )

Return lRet


//--------------------------------------------------------------------
/*/{Protheus.doc} A181CalNec()
Retorna o valor total da necessidade do produto em todas as filiais
@author Leonardo Quintania
@since 28/01/2013
@version 1.0
@return aReturn
/*/
//--------------------------------------------------------------------
Function A181CalNec(oModel,cProduto)
Local oMaster		:= oModel:GetModel()
Local oModelDBH	:= oMaster:GetModel("DBHDETAILS")
Local oModelDBI	:= oMaster:GetModel("DBIDETAILS")
Local aSaveLines := FWSaveRows(oMaster)
Local nX			:= 0
Local nY			:= 0
Local nTotNec		:= 0

cProduto := FwFldGet("DBI_PRODUT")	

For nX:= 1 To oModelDBH:GetQtdLine()
	oModelDBH:GoLine( nX )
	For nY:= 1 To oModelDBI:GetQtdLine()
		oModelDBI:GoLine( nY )
		If cProduto == oModelDBI:GetValue("DBI_PRODUT")
			nTotNec+= oModelDBI:GetValue("DBI_NECINF")
		EndIf		
	Next nY
Next nX

FWRestRows( aSaveLines )

Return nTotNec

//--------------------------------------------------------------------
/*/{Protheus.doc} A181SldTra()
Recalcula saldo a distribuir conforme necessidade informada
@author Leonardo Quintania
@since 28/01/2013
@version 1.0
@return aReturn
/*/
//--------------------------------------------------------------------
Function A181SldTra(oModel,cField,xConteud,nLine,xOldValue)
Local oMaster		:= oModel:GetModel()
Local oModelDBH	:= oMaster:GetModel("DBHDETAILS")
Local oModelDBI	:= oMaster:GetModel("DBIDETAILS")
Local aSaveLines := FWSaveRows(oMaster)
Local cProduto	:= ""
Local nX			:= 0
Local nY			:= 0
Local lRet 		:= .T.

cProduto := FwFldGet("DBI_PRODUT")	

For nX:= 1 To oModelDBH:GetQtdLine()
	oModelDBH:GoLine( nX )
	If lRet
		For nY:= 1 To oModelDBI:GetQtdLine()
			oModelDBI:GoLine( nY )
			If cProduto == oModelDBI:GetValue("DBI_PRODUT")
				If ((oModelDBI:GetValue("DBI_SLDDIS")+ xOldValue) - xConteud 	) >= 0 
					oModelDBI:LoadValue("DBI_SLDDIS",(oModelDBI:GetValue("DBI_SLDDIS")+ xOldValue) - xConteud 	)						
				Else
					Help(" ",1,"QTDEV")//Quantidade solicitada e maior que o saldo disponivel.
					lRet := .F.
				EndIf
				Exit
			EndIf		
		Next nY
	EndIf
Next nX

FWRestRows( aSaveLines )

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} A181IniSld()
Inicializa Nome dos campos
@author Leonardo Quintania
@since 28/01/2013
@version 1.0
@return NIL
/*/
//-------------------------------------------------------------------
Function A181IniSld(cFilDist,cProduto)
Local oModel   	:= FWModelActive()
Local nSaldo		:= 0  
Local aAreaSB2	:= SB2->(GetArea())

If ValType(oModel) != "U"
	If oModel:GetOperation() != MODEL_OPERATION_INSERT
		SB2->(dbSetOrder(1))
		SB2->(dbSeek(xFilial("SB2",cFilDist)+cProduto))
		While SB2->(!Eof())  .And. SB2->(B2_FILIAL+B2_COD) == xFilial("SB2",cFilDist)+cProduto
			nSaldo += SaldoSB2()
		SB2->(DbSkip())
		EndDo	
	EndIf
EndIf

RestArea(aAreaSB2)

Return nSaldo

//-------------------------------------------------------------------
/*/{Protheus.doc} A181ActMod()
Realiza soma do preco e alimenta o campo DBH_VALTOT
@author Leonardo Quintania
@since 29/12/2011
@version 1.0
/*/
//-------------------------------------------------------------------
Function A181ActMod(oModel)
Local oMaster		:= oModel:GetModel()
Local oModelDBH	:= oMaster:GetModel("DBHDETAILS")
Local oModelDBI	:= oMaster:GetModel("DBIDETAILS")
Local aSaveLines	:= FWSaveRows()
Local cDbj_FilDis	:= FwFldGet("DBJ_FILDIS")
Local lDbj_EstSeg	:= DBJ->(FieldPos("DBJ_ESTSEG")) > 0 .And. FwFldGet("DBJ_ESTSEG")
Local lDbj_ConEst	:= FwFldGet("DBJ_CONEST")
Local lDbj_Reserv	:= FwFldGet("DBJ_RESERV")
Local lDbj_Empenh	:= FwFldGet("DBJ_EMPENH")
Local lDbj_PrvEnt	:= FwFldGet("DBJ_PRVENT")
Local lDbj_PdcArt	:= FwFldGet("DBJ_PDCART")
Local lDbj_SldTra	:= FwFldGet("DBJ_SLDTRA")
Local lA179ARMZ  	:= ExistBlock("A179ARMZ")
Local nOperation	:= oModel:GetOperation()
Local nI			:= 0
Local nJ			:= 0
Local nTot			:= 0
Local nSldDis		:= 0
Local lRet			:= .F.
Local lEfet		:= IsInCallStack("A181EFET") //Variavel utilizada para saber se foi utilizada a opção de efetivação.
Local lCalc		:= IsInCallStack("A179CALCEN") //Calculando as filiais
Local lExistSldF	:= DBI->(FieldPos("DBI_SLDFIS")) > 0

If lExistSldF .And. !lEfet .And. FwFldGet("DBJ_TPAGLU") == "1" //Se não for efetivação prossegue com a atualização dos saldos.
	If(nOperation == MODEL_OPERATION_UPDATE)
		If !lCalc
			lRet:= MsgYesNo("O saldo atual pode estar desatualizado em relação a data da sugestão. Deseja atualizar os saldos das filiais?. Este procedimento pode demorar alguns minutos.","Atenção")//"O saldo atual pode estar desatualizado em relação a data da sugestão. Deseja atualizar os saldos das filiais?. Este procedimento pode demorar alguns minutos."//"Atenção"
		Else
			lRet:= .T.
		EndIf
		//Calcula valor total 
		If lRet
			For nI:= 1 To oModelDBH:GetQtdLine()
				oModelDBH:GoLine( nI )
				For nJ:= 1 To oModelDBI:GetQtdLine()
					oModelDBI:GoLine( nJ )
					nSldDis:= A179SldFil(cDbj_FilDis,oModelDBI:GetValue("DBI_PRODUT"),.T.,lDbj_EstSeg,lDbj_ConEst,lDbj_Reserv,lDbj_Empenh,lDbj_PrvEnt,lDbj_PdcArt,lDbj_SldTra,lA179ARMZ)
					// Altera campo somente se houver sugestão de produto
					If nSldDis > 0 .And. !Empty(oModelDBI:GetValue("DBI_SUGEST"))
						oModelDBI:LoadValue("DBI_SLDFIS",nSldDis)
					Endif
				Next nJ
				oModelDBI:GoLine( 1 )
			Next nI
		EndIf
	EndIf
EndIf
FWRestRows( aSaveLines )

Return .T.

//--------------------------------------------------------------------
/*/{Protheus.doc} A181VldSld()
Realiza criação de filtro da tabela SB1
@author Leonardo Quintania
@since 28/01/2013
@version 1.0
@return aReturn
/*/
//--------------------------------------------------------------------
Function A181VldSld()
Local lRet 		:= .T.
Local nSldDistri	:= FwFldGet("DBI_SLDFIS")
Local nSldTransf	:= FwFldGet("DBI_SLDTRA")
Local aSaveLines := FWSaveRows()

//bloqueia campo
If FwFldGet("DBI_FILABA") == FwFldGet("DBH_FILDIS") .And. nSldTransf > 0
	Aviso(STR0031,STR0032,{"OK"}) //"Atenção" + "A filial distribuidora não pode transferir para ela mesma"
	lRet:= .F.
EndIf

If lRet .And. nSldTransf > nSldDistri
	Help(" ",1,"QTDEV")//Quantidade solicitada e maior que o saldo disponivel.
	lRet:= .F.
EndIf

FWRestRows( aSaveLines )
Return lRet

//--------------------------------------------------------------------
/*/{Protheus.doc} A181Efet()
Instancia os modelos de dados da rotina Central de Compras - DBJ/DBH/DBI
@author Rodrigo Toledo
@since 22/02/2013
@version 1.0
@return aReturn
/*/
//--------------------------------------------------------------------
Function A181Efet()
Local oModel		:= Nil
Local cSugest		:= ""
Local lRet			:= .T.
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Instancia modelo de dados(Model) do Central de Compras - DBH e DBI  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oModel := FWLoadModel("MATA181")
oModel:SetOperation(4)

//Verifica se existe bloqueio contábil
lRet := CtbValiDt(Nil,dDataBase,/*.T.*/ ,Nil ,Nil ,{"COM001"}/*,"Data de apuração bloqueada pelo calendário contábil."*/) 

If lRet .And. (lRet := oModel:Activate())
	cSugest := oModel:GetModel("DBJMASTER"):GetValue("DBJ_SUGEST")
	If MsgYesNo(STR0017 + cSugest + ' ?',STR0016)//'Central de Compras'//'Confirma a efetivação da sugestão de compra: '
		BEGIN TRANSACTION
			oProcess := MSNewProcess():New( { | lEnd | lOk := A181GerDoc( @lEnd,oModel,cSugest) }, STR0019, STR0018, .F. ) //'Aguarde, gerando os documentos...'//'Efetivando'
			oProcess:Activate()
		END TRANSACTION()
	EndIf
EndIf    

Return .T. 

//--------------------------------------------------------------------
/*/{Protheus.doc} A181GerDoc()
Efetiva as necessidades e cria os documentos(Solicitacao, Pedido de Compra ou Pedido de Venda)
@author Rodrigo Toledo
@since 22/02/2013
@version 1.0
@return aReturn
/*/
//--------------------------------------------------------------------
Static Function A181GerDoc(lEnd,oModel,cSugest)
Local oModelDBH		:= NIL
Local oModelDBI		:= NIL
Local oModelDBJ   	:= NIL

Local aAreaSC7		:= SC7->(GetArea())
Local aAreaSA2		:= SA2->(GetArea())
Local aAreaSC1		:= SC1->(GetArea())
Local aAreaSB1		:= SB1->(GetArea())
Local aAreaDBI		:= DBI->(GetArea())
Local aCliFor		:= {}
Local aPedVenda		:= {}    

Local nI			:= 0
Local nX			:= 0
Local nSaveSX8 		:= GetSX8Len()
Local nCountBar2	:= 0
Local nQtdDoc 		:= 0		

Local cFilCompNa	:= ""
Local cFilEntrNa	:= ""
Local cNumDoc		:= " "
Local cErro			:= ""
Local cFilAntBkp    := ""
Local cFor			:= ""
Local cLjForn		:= ""


Local cAliasPq	:= GetNextAlias()
Local cDbj_TpSug	:= oModel:GetModel("DBJMASTER"):GetValue("DBJ_TPSUG")
Local cDbj_FilDis	:= oModel:GetModel("DBJMASTER"):GetValue("DBJ_FILDIS")
Local cDbj_TsTran	:= oModel:GetModel("DBJMASTER"):GetValue("DBJ_TSTRAN")
Local cDbj_DocCom	:= oModel:GetModel("DBJMASTER"):GetValue("DBJ_DOCCOM")

Local lRet			:= .F.
Local lForBlq		:= .F. 

Local nPrc			:= 0
Local aDocs		  	:= {}
Local aResultados	:= {}


Private lMsErroAuto	:= .F. 


If FWFormCommit(oModel) 
	If cDbj_TpSug == "1"
		SB1->(dbSetOrder(1))
								
		BeginSQL Alias cAliasPq
			SELECT 
					CASE	
						WHEN DBI_COMPNA = '1' THEN DBJ_FILDIS
	 	          		ELSE DBI_FILABA 
	 	          	END COMPNA,
       			CASE
       				WHEN DBI_ENTRNA = '1' THEN DBJ_FILDIS
           			ELSE DBI_FILABA
           		END ENTRNA,
					DBI_COMPNA, DBI_ENTRNA, DBJ_FILDIS, DBI_FILABA, DBI_DOCOMP, DBI_FORNEC, DBJ_DIASCO,
				 	DBI_LOJA, DBI_COND, DBI_PRODUT, DBI_QTDCOM, DBI_PRECO, DBI.R_E_C_N_O_ DBIRECNO
				FROM 
					%table:DBI% DBI	
					JOIN %table:DBJ% DBJ ON 
						DBJ.%NotDel% AND
						DBJ_FILIAL = %xfilial:DBJ% AND
						DBJ_SUGEST = DBI_SUGEST
						
					JOIN  %table:DB5% DB5 ON 
						DB5.%NotDel% AND
						DB5_FILIAL = %xfilial:DB5% AND
						DB5_FILDIS = DBJ.DBJ_FILDIS AND 
						DB5_FILABA = DBI_FILABA	
						
					WHERE 
						DBI.%NotDel% AND 
						DBI_FILIAL = %xfilial:DBI% AND 
						DBI_SUGEST = %exp:cSugest% AND
						DBI_QTDCOM > 0
		EndSql
		
			// - Process query Produtos.
			nCountBar2 := 2 // Contrato / Pc ou SC
			oProcess:SetRegua2(nCountBar2)
		
		While !(cAliasPq)->(Eof())	
			nPrc:= COMPESQPRECO((cAliasPq)->DBI_PRODUT,cFilAnt,(cAliasPq)->DBI_FORNEC,(cAliasPq)->DBI_LOJA)
			Aadd(aDocs,{(cAliasPq)->DBI_PRODUT,(cAliasPq)->DBI_QTDCOM,(cAliasPq)->COMPNA,(cAliasPq)->ENTRNA,cDbj_DocCom,(cAliasPq)->DBI_FORNEC,(cAliasPq)->DBI_LOJA,(cAliasPq)->DBI_COND,nPrc,{},cSugest,"",,{}})
			
			If cDbj_DocCom == "2"//Se for pedido de compra, valida se o código está bloqueado
				cFor    := (cAliasPq)->DBI_FORNEC
				cLjForn := (cAliasPq)->DBI_LOJA

				If !Empty(cFor) .And. !Empty(cLjForn)
					SA2->(dbSetOrder(1))
					If SA2->(MsSeek(xFilial("SA2")+cFor+cLjForn))
						If !RegistroOk("SA2",.F.)
							lForBlq := .T.
							cErro += STR0042+AllTrim(cFor)+" "+STR0043+cLjForn+STR0044+CRLF+CRLF
							Exit
						Endif 
					EndIf 
				EndIf
			EndIf
			(cAliasPq)->(DbSkip()) 
		EndDo
		
		If !Empty(aDocs) .And. !lForBlq
			aResultados:= ComGeraDoc(aClone(aDocs),.T.,.F.,.F.,.T.,(cAliasPq)->DBJ_DIASCO,"MATA181",,2)
		EndIf
		
		(cAliasPq)->(DbCloseArea())

		 		
		For nI:=1 To Len(aResultados) .And. !lForBlq
			For nX:=1 To Len(aResultados[nI])
				A181GRVCPM(cSugest,aResultados[nI,nX,1],aDocs[nI,1],aResultados[nI,nX,2],aResultados[nI,nX,3],cFilAnt)				
			Next nX			
		Next nI
		
			
			
	ElseIf cDbj_TpSug == "2" .And. !lForBlq
		oModelDBH := oModel:GetModel("DBHDETAILS")
		oModelDBI := oModel:GetModel("DBIDETAILS")
		oModelDBJ := oModel:GetModel("DBJDETAILS")		
		//--------------------------
		// Transferencia (Doc Venda)			
		//--------------------------
		oProcess:SetRegua1(oModelDBH:GetQtdLine())
		//--------------------------------------------------------------------------------
		// Seta a quantidade de registros para ser utilizado na barra de processamento 
		//--------------------------------------------------------------------------------
		For nI:= 1 To oModelDBH:GetQtdLine()
			oModelDBH:GoLine(nI)
			oProcess:IncRegua1(STR0020) //'Aguarde... Gerando os documentos da filial abastecida'//"Aguarde... Gerando os documentos para filial abastecida..."
			For nX:=1 To oModelDBI:GetQtdLine() 
				oModelDBI:GoLine(nX)
				If cDbj_FilDis == oModelDBI:GetValue("DBI_FILABA") // Não permite gera PV para ela propia.
					Loop
				EndIf
				cFilCompNa := IIf(oModelDBI:GetValue("DBI_COMPNA") == "1",cDbj_FilDis,oModelDBI:GetValue("DBI_FILABA"))
				cFilEntrNa := IIf(oModelDBI:GetValue("DBI_ENTRNA") == "1",cDbj_FilDis,oModelDBI:GetValue("DBI_FILABA"))
				SB1->(dbSetOrder(1))
				DBI->(dbSetOrder(1))
				SB1->(dbSeek(xFilial("SB1",cFilEntrNa)))
				DBI->(dbSeek(xFilial("DBI",cFilEntrNa)+cSugest))
				If cDbj_TpSug == "2" .And. oModelDBI:GetValue("DBI_SLDTRA") > 0 
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Gera o Pedido de Venda ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					aCliFor := {'', '', ''}
					aCliFor[1] := oModelDBI:GetValue("DBI_FORNEC")
					aCliFor[2] := oModelDBI:GetValue("DBI_LOJA")
					aCliFor[3] := oModelDBI:GetValue("DBI_COND")
					If AScan(aPedVenda, {|x| x[1,3,2] + x[1,4,2] == aCliFor[1] + aCliFor[2]} ) == 0
						cFilAntBkp := cFilAnt
						A179AltFil(cDbj_FilDis) //Realiza alteração para a filial distribuidora
						cNumDoc	:= Criavar('C5_NUM',.T.)

						While ( GetSX8Len() > nSaveSX8) 
							ConfirmSx8() 
						EndDo

						A179AltFil(cFilAntBkp) //Retorna para a filial logada
						AAdd(aPedVenda, Array(2))
						ATail(aPedVenda)[1] := {}
						ATail(aPedVenda)[2] := {}
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Monta o cabecalho do pedido de venda ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						AAdd( ATail(aPedVenda)[1], {"C5_NUM"		, cNumDoc		, NIL})
						AAdd( ATail(aPedVenda)[1], {"C5_TIPO"		, 'N'			, NIL})
						AAdd( ATail(aPedVenda)[1], {"C5_CLIENTE"	, aCliFor[1]	, NIL})
						AAdd( ATail(aPedVenda)[1], {"C5_LOJACLI"	, aCliFor[2]	, NIL})
						AAdd( ATail(aPedVenda)[1], {"C5_TIPOCLI"	, 'F'			, NIL})
						AAdd( ATail(aPedVenda)[1], {"C5_CONDPAG"	, aCliFor[3]	, NIL})
						cItemPV := StrZero(0, Len(SC6->C6_ITEM))
					EndIf
					cItemPV := Soma1(cItemPV)
					//Consulta se cadastro possui TES Inteligente
					cTes	 := MaTesInt(2,M->DBJ_TPOPER,aCliFor[1],aCliFor[2],,oModelDBI:GetValue("DBI_PRODUT"))
					AAdd( ATail(aPedVenda)[2],{	{ "C6_NUM"		, cNumDoc									, NIL },;
													{ "C6_ITEM"	, cItemPV									, NIL },;
													{ "C6_PRODUTO", oModelDBI:GetValue("DBI_PRODUT")		, NIL },;
													{ "C6_QTDVEN"	, oModelDBI:GetValue("DBI_SLDTRA")		, NIL },;
													{ "C6_PRUNIT"	, oModelDBI:GetValue("DBI_PRECO")		, NIL },;
													{ "C6_TES"		, Iif(!Empty(cTes),cTes,cDbj_TsTran)	, NIL } } )
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Atualiza o numero do documento  ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

					
					
					A181GRVCPM(oModelDBI:GetValue("DBI_SUGEST"),oModelDBI:GetValue("DBI_FILABA"),oModelDBI:GetValue("DBI_PRODUT"),cNumDoc,"4",oModel:GetModel("DBJMASTER"):GetValue("DBJ_FILDIS"))

				EndIf
			Next nX
		Next nI
	EndIf
	
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Grava o pedido de venda via ExecAuto()³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Len(aPedVenda) > 0 
		cFilAntBkp := cFilAnt
		A179AltFil(cDbj_FilDis) //Realiza alteração para a filial distribuidora
		A181PedVend(aPedVenda) //Efetua entrada do pedido de venda
		A179AltFil(cFilAntBkp) //Retorna para a filial logada
	EndIf

	If lMsErroAuto .Or. lForBlq
		MostErCCom(cErro) //"Os produtos a seguir não foram efetivados pois ocorreram os seguintes erros: "
		DisarmTransaction()
	Else
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Atualiza a FLAG da sugestao de compra para que nao seja mas calculado  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		DBJ->(dbSetOrder(1))
		DBJ->(dbSeek(xFilial("DBJ")+cDbj_FilDis+cSugest))
		RecLock("DBJ",.F.)
		DBJ->DBJ_FLAG := "2"
		DBJ->(MsUnlock())
	EndIf
EndIf

//Metricas - Documentos gerados por tipo (SC e PC)
If !lMsErroAuto .And. lRet .And. Len(aResultados) > 0 .And. !Empty(aResultados[1][1][2])
	nQtdDoc++
	ComMetric("- inc",nQtdDoc,iif(aResultados[1][1][3]=="1","sc","pc"))
	nQtdDoc := 0
EndIf


RestArea(aAreaSC7)
RestArea(aAreaSA2)
RestArea(aAreaSC1)
RestArea(aAreaSB1)
RestArea(aAreaDBI)
Return lRet
                           
//--------------------------------------------------------------------
/*/{Protheus.doc} A181VisDoc()
Visualiza os documento que foram gerados pelo Central de Compras
@author Rodrigo Toledo
@since 28/02/2013
@version 1.0
@return aReturn
/*/
//--------------------------------------------------------------------
Function A181VisDoc()
Local aArea		:= GetArea()
Local cFilDoc		:= IIf(FwFldGet("DBI_COMPNA") == "1",FwFldGet("DBJ_FILDIS"),FwFldGet("DBH_FILABA"))
Local cFilAba		:= FwFldGet("DBH_FILABA")
Local cSugest		:= FwFldGet("DBJ_SUGEST")
Local cProd		:= FwFldGet("DBI_PRODUT")
Local cTpSug 		:= ''
Local cDocCom		:= ''
Local cNumDoc		:= ''
Local cCpmTp		:= ''
Local cFilDocBkp	:= '' 

// Foi necessario criar essas variaveis para que fosse possivel usar a funcao padrao do sistema A120Pedido()
Private aRotina   	:= {}
Private INCLUI      := .F.
Private ALTERA      := .F.
Private nTipoPed    := 1  
Private cCadastro   := STR0027  
Private l120Auto    := .F.  

//--Monta o aRotina para compatibilizacao
AAdd( aRotina, { '' , '' , 0, 1 } )
AAdd( aRotina, { '' , '' , 0, 2 } )
AAdd( aRotina, { '' , '' , 0, 3 } )
AAdd( aRotina, { '' , '' , 0, 4 } )
AAdd( aRotina, { '' , '' , 0, 5 } )

cNumDoc := FwFldGet("CPM_NUMDOC")
cCpmTp	 := FwFldGet("CPM_TIPO")
If  Empty(cNumDoc)
	DBI->(dbSetOrder(1)) //	DBI_FILIAL+DBI_SUGEST+DBI_FILABA+DBI_PRODUT
	If	DBI->(dbSeek(xFilial("DBI")+cSugest+cFilAba+cProd))
		If !Empty(DBI->(DBI_NUMDOC))
			MsgInfo(STR0030) //Rodar compatibilizador
		Else
				MsgInfo(STR0028)	//Não existe documento gerado para esse produto.			
		EndIf
	EndIf
Else
	cFilDocBkp:= cFilDoc
	A179AltFil(cFilDoc)
	If cCpmTp == '1' //--Visualizacao da Solicitacao de Compras			
		If SC1->(DbSeek(xFilial("SC1")+cNumDoc))
			A110Visual	("SC1",SC1->(Recno()),2)
		EndIf
		ElseIf cCpmTp $ '23' //--Visualizacao do Pedido de Compra ou Autorização de Entrega
		If SC7->(DbSeek(xFilial("SC7")+cNumDoc)) 
			A120Pedido("SC7",SC7->( Recno()),2)
		EndIf
	ElseIf cCpmTp $ '4'  //--Visualizacao do Pedido de Vendas
		If SC5->(DbSeek( xFilial("SC5") + cNumDoc))
			A410Visual	("SC5",SC5->(Recno()),2)
		EndIf		
		Else //--Visualizacao da Medição de Contrato
		dbSelectArea("CND")
		dbSetOrder(4)
		If CND->(dBSeek(xFilial("CND")+cNumDoc))
			CN130Manut("CND",CND->( Recno() ),2)
		Endif 
	EndIf  
	A179AltFil(cFilDocBkp)    	
EndIf	
	
RestArea(aArea)

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} A181GRVCPM(cSugest,cFilAba,cProd,cNumDoc,cTipo,cFilProc)
Grava o documento gerado na tabela CPM. 
@author antenor.silva
@since 18/11/2013
@version 1.0
@return Nil
/*/
//-------------------------------------------------------------------
Function A181GRVCPM(cSugest,cFilAba,cProd,cNumDoc,cTipo,cFilProc)
Local aAreaCPM	 := CPM->(GetArea())
Local nTamNumDoc := TamSx3("CPM_NUMDOC")[1]
Local cNumDocDB  := Left(cNumDoc,nTamNumDoc)
Default cFilProc := cFilAnt

dbSelectArea("CPM")
dbSetOrder(1)

iF !MsSeek(xFilial("CPM",cFilProc)+cSugest+cFilAba+cProd+cNumDocDB+cTipo)
	Begin Transaction
		RecLock("CPM",.T.)
		CPM->CPM_FILIAL	:=	xFilial("CPM",cFilProc)
		CPM->CPM_SUGEST	:=	cSugest
		CPM->CPM_FILABA	:=	cFilAba
		CPM->CPM_PRODUT	:=	cProd
		CPM->CPM_NUMDOC	:=	cNumDocDB
		CPM->CPM_TIPO 	:=	cTipo
		CPM->(MsUnLock())
	End Transaction()  
EndIf  
RestArea(aAreaCPM)		

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} A181EXCCPM(cTipo,cNumDoc)
Exclui o documento gerado na tabela CPM quando houver uma exclusão na SC1, SC7 e SC5. 
Tipo: 
	1=Solicitacao de Compra
	2=Pedido de Compra
	3=Autorizacao de Entrega
	4=Pedido de Venda 
@author antenor.silva
@since 18/11/2013
@version 1.0
@return Nil
/*/
//-------------------------------------------------------------------
Function A181EXCCPM(cTipo,cNumDoc)
Local aAreaCPM	:= CPM->(GetArea())

CPM->(dbSetOrder(2)) //CPM_FILIAL+CPM_TIPO+CPM_NUMDOC
If CPM->(dbSeek(xFilial("CPM")+cTipo+cNumDoc))
	While !CPM->(Eof()) 
		If CPM->(dbSeek(xFilial("CPM")+cTipo+cNumDoc))
			RecLock("CPM", .F.)
			CPM->(dbDelete())
			CPM->(MsUnLock())
			CPM->(dbSkip())
		Else
			Exit
		EndIf
	End
EndIf
RestArea(aAreaCPM)

Return Nil


//--------------------------------------------------------------------
/*/{Protheus.doc} A181PedVend()
Geração de Pedido de Vendas
@author Leonardo Quintania
@since 25/11/2014
@version 1.0
@return cError
/*/
//--------------------------------------------------------------------
Static Function A181PedVend(aPedVenda)
Local oIPC
Local nX
Local aCabDoc 	:= {}
Local aItemDoc 	:= {}
Local cSemaphore 	:= "MATA181"
Local cError		:= ""
Local nThreads   	:= SuperGetMv('MV_M179THR',.F.,10)

//-- Verifica Limite Maximo de 40 Threads
If nThreads > 40
	nThreads := 40
EndIf

oIPC := FWIPCWait():New(cSemaphore,10000)
oIPC:SetThreads( nThreads )
oIPC:SetEnvironment(cEmpAnt,cFilAnt)
oIPC:Start("A181GerPV")
oIPC:SetNoErrorStop(.T.) //Se der erro em alguma thread sai imadiatamente

For nX := 1 To Len(aPedVenda)
	aCabDoc  := aPedVenda[nX, 1]
	aItemDoc := aPedVenda[nX, 2]			
	oIPC:Go(aCabDoc,aItemDoc)
Next nX

oIPC:Stop()
cError:= oIPC:GetError()

If !Empty(cError)
	Help(,,"ERROR",,cError,1,0)
EndIf

Return	cError

//--------------------------------------------------------------------
/*/{Protheus.doc} A181GerPV()
Geração de Pedido de Vendas
@author Leonardo Quintania
@since 25/11/2014
@version 1.0
@return aReturn
/*/
//--------------------------------------------------------------------
Function A181GerPV(aCabDoc, aItemDoc)
Local cDetalhe	:= ""
Local aLog			:= {}
Local nI			:= 0

Private lMsErroAuto 		:= .F.
Private lMsHelpAuto		:= .T.
Private lAutoErrNoFile	:= .T.

MSExecAuto( {|x,y,z| MATA410(x, y, z) },aCabDoc, aItemDoc, 3)

If lMsErroAuto
	aLog := GETAUTOGRLOG()
	For nI := 1 to Len(aLog)
		cDetalhe += aLog[nI]
	Next nI
	lMsErroAuto := .F.
	UserException(cDetalhe)
EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} MTA181LPRE
Funcao para pre-validacao da linha do modelo.

@author rd.santos
@since 19/03/2020
@version 1.0
@param	oModelGrid	- Modelo DBI
		nLinha		- Linha que esta sendo alterada
		cAcao		- Acao que esta sendo executada
		cCampo		- Campo que esta sendo alterado
@return lRet 
/*/
//-------------------------------------------------------------------
Function MTA181LPRE(oModelGrid,nLinha,cAcao,cCampo,cModel)

Local lRet 		 := .T.
Local oModel 	 := oModelGrid:GetModel()
Local oModelDBI  := oModel:GetModel(cModel)
Local nOperation := oModel:GetOperation()
Local cSugest 	 := oModelDBI:GetValue("DBI_SUGEST")

If cAcao == "SETVALUE" .And. nOperation == MODEL_OPERATION_UPDATE .AND. Empty(cSugest)
	Help(" ",1,"A179ALT",,STR0040,; // 'Não há sugestão de produto para essa Filial Abastecida.'
	1, 0, NIL, NIL, NIL, NIL, NIL, {STR0041}) // "Altere uma sugestão de produto válida."
	
	lRet := .F.
EndIf

Return lRet

/*/{Protheus.doc} ComMetric
Tempo médio de execução da inclusão de um pedido de compra

@Param cOper		inc (Inclusão)
@Param lAuto		T (Rotina Automatica) / F (Tela Padrão)
@Param lClas		T (Inclusao via classificação) / F (Inclusão)
@Param cTipo		N (Normal) / C (Complemento) / D (Devolução) / B (Beneficiamento)
@Param nItemMetric	Quantidade de itens inseridos na inclusao do PC
@Param nSegsTot     Tempo gasto para inclusão de um documento de entrada

@author Fabiano Dantas
@since 26/10/2021
@return Nil, indefinido
/*/
Static Function ComMetric(cOper,nItemMetric,cTipo)

Local cIdMetric		:= "compras-protheus_total-de-scs-e-pcs-gerados_total"
Local cRotina		:= "mata181"
Local cSubRoutine	:= cRotina+cOper+"-"+cTipo+'-total'
Local lContinua		:= (FWLibVersion() >= "20210517") .And. FindClass('FWCustomMetrics')

If lContinua
	FWCustomMetrics():setSumMetric(cSubRoutine, cIdMetric, nItemMetric, /*dDateSend*/, /*nSegsTot*/, cRotina)
Endif

Return
