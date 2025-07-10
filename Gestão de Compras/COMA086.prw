#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDef.CH'
#INCLUDE 'COMA086.CH'
#INCLUDE "TbIconn.ch"
#INCLUDE "TopConn.ch" 
#INCLUDE "FWBROWSE.CH"

/*/{Protheus.doc} COMA086
Grupo de Compras
@author Rodrigo M Pontes
@since 18/10/2018
@version version
/*/

Function COMA086(xAutoCab,xAutoItens,xnOpcAuto)
 
Local oBrowse	:= Nil
Local l086MVC	:= .F.
Local cAviso	:= STR0001 //"Rotina não possui atributos para utilização em MVC"

Private lC086Auto	:= Iif(xAutoCab == Nil .And. xAutoItens == Nil,.F.,.T.)

DbSelectArea("SAJ")
If SAJ->(FieldPos("AJ_DESC")) > 0
	l086MVC := .T.
Endif

If l086MVC
	If xAutoCab == Nil .And. xAutoItens == Nil
		oBrowse := FWMBrowse():New()
		oBrowse:SetAlias("SAJ")
		oBrowse:SetDescription(STR0002)  //"Grupo de Compras"
		oBrowse:Activate()
	Else
		FWMVCRotAuto(ModelDef(),"SAJ", xnOpcAuto, {{"SAJMASTER",xAutoCab},{"SAJDETAILS",xAutoItens}},,.T.)
	EndIf
Else
	Help(" ",1,"COMA086",,cAviso,1,0)
Endif

Return

/*/{Protheus.doc} CA086Commit
Validação do cammpo AJ_CHECK e AJ_GRCOM

@author José Renato Silva Dourado de Souza jose.souza2
@since 08/12/2020
@version 1.0
/*/
Function CA086Commit(oModel)

If FwFldGet("AJ_CHECK")
	FwFldPut("AJ_GRCOM","*")
Endif

FWFormCommit(oModel)

//Caso seja alterada a descrição do grupo, atualiza tabela de produtos do MRP
If FindFunction("UpdGCDescP") .And. oModel:GetModel('SAJMASTER'):IsFieldUpdated("AJ_DESC") == .T.
	UpdGCDescP(FwFldGet("AJ_GRCOM"), FwFldGet("AJ_DESC"))
EndIf

Return .T.

/*/{Protheus.doc} CA086WHEN
Função que realiza busca na tabela SAJ de cadastros que possam ter utilizado asterisco *

@author José Renato Silva Dourado de Souza jose.souza2
@since 08/12/2020
@version 1.0
/*/
Static Function CA086WHEN()

Local lRet := .T.

If SAJ->(DbSeek(xFilial("SAJ") + PadR("*",TamSX3("AJ_GRCOM")[1])))
	lRet := .F.
Endif

Return lRet

/*/{Protheus.doc} ModelDef
Definição do modelo de Dados

@author Rodrigo M Pontes
@since 18/10/2018
@version 1.0
/*/

Static Function ModelDef() 

Local oModel
Local oStrSAJH := FWFormStruct(1,'SAJ',{|cCampo| ALLTRIM(cCampo) $ "AJ_GRCOM|AJ_DESC"})
Local oStrSAJI := FWFormStruct(1,'SAJ',{|cCampo| !(ALLTRIM(cCampo) $ "AJ_GRCOM|AJ_DESC")})

oStrSAJH:AddField(  STR0012															    ,;	// 	[01]  C   Titulo do campo
					STR0012															    ,;	// 	[02]  C   ToolTip do campo
					"AJ_CHECK"															,;	// 	[03]  C   Id do Field
					"L"																    ,;	// 	[04]  L   Tipo do campo
					 1																	,;	// 	[05]  N   Tamanho do campo
					 0																	,;	// 	[06]  N   Decimal do campo
					 NIL																,;	// 	[07]  B   Code-block de validação do campo
					 {|| CA086WHEN()}													,;	// 	[08]  B   Code-block de validação When do campo
					 NIL																,;	//	[09]  A   Lista de valores permitido do campo
					 .F.																,;	//	[10]  L   Indica se o campo tem preenchimento obrigatório
					 NIL																,;	//	[11]  B   Code-block de inicializacao do campo
					 NIL																,;	//	[12]  L   Indica se trata-se de um campo chave
					 .T.																,;	//	[13]  L   Indica se o campo pode receber valor em uma operação de update.
					 .T.																)	// 	[14]  L   Indica se o campo é virtual

// FORM - FORM ModelView
oModel := MPFormModel():New('COMA086',,{|oModel| CA086PosVl(oModel)},{|oModel|CA086Commit(oModel)})
oModel:SetDescription(STR0002)  //"Grupo de Compras"

// MONTA A TELA:
oModel:addFields('SAJMASTER',,oStrSAJH) //Cabeçalho
oModel:addGrid('SAJDETAILS','SAJMASTER',oStrSAJI,{|a,b,c,d,e,f| CA086CpoOk(a,b,c,d,e,f)}) //Grid

oModel:GetModel("SAJDETAILS"):SetUseOldGrid()
oModel:GetModel("SAJDETAILS"):SetUniqueLine({"AJ_ITEM"})

oModel:SetPrimaryKey({"AJ_GRCOM"}) //Obrigatorio setar a chave primaria (mesmo que vazia)

//RELACIONAMENTO ENTRE CABECALHO E ITEM
oModel:SetRelation('SAJDETAILS',{{'AJ_FILIAL','XFILIAL("SAJ")'},{'AJ_GRCOM', 'AJ_GRCOM'},{'AJ_DESC', 'AJ_DESC'}},SAJ->(IndexKey(1)))

//DESCRIÇÃO
oModel:GetModel('SAJMASTER'):SetDescription(STR0002)  //Grupo de Compras
oModel:GetModel('SAJDETAILS'):SetDescription(STR0003) //Lista de Compradores

oModel:SetVldActivate({|oModel| CA086Delet(oModel)}) //Valida a exclusao do Grupo de Compras

Return oModel

/*/{Protheus.doc} ViewDef
Definição do interface

@author Rodrigo M Pontes
@since 18/10/2018
@version 1.0
/*/

Static Function ViewDef()

Local oView
Local oModel 	:= FWLoadModel( 'COMA086' )
Local oStrSAJH 	:= FWFormStruct(2,'SAJ',{|cCampo| ALLTRIM(cCampo) $ "AJ_GRCOM|AJ_DESC"})
Local oStrSAJI 	:= FWFormStruct(2,'SAJ',{|cCampo| !(ALLTRIM(cCampo) $ "AJ_GRCOM|AJ_DESC|AJ_CHECK")})

oStrSAJH:AddField(	"AJ_CHECK"															,;	// [01]  C   Nome do Campo
					"09"																,;	// [02]  C   Ordem
					STR0012																,;	// [03]  C   Titulo do campo//"Descrição"
					STR0012															    ,;	// [04]  C   Descricao do campo//"Descrição"
					NIL																	,;	// [05]  A   Array com Help
					"L"																	,;	// [06]  C   Tipo do campo
					NIL																	,;	// [07]  C   Picture
					NIL																	,;	// [08]  B   Bloco de Picture Var
					NIL																	,;	// [09]  C   Consulta F3
					.T.																	,;	// [10]  L   Indica se o campo é alteravel
					NIL																	,;	// [11]  C   Pasta do campo
					NIL																	,;	// [12]  C   Agrupamento do campo
					NIL																	,;	// [13]  A   Lista de valores permitido do campo (Combo)
					NIL																	,;	// [14]  N   Tamanho maximo da maior opção do combo
					NIL																	,;	// [15]  C   Inicializador de Browse
					.T.																	,;	// [16]  L   Indica se o campo é virtual
					NIL																	,;	// [17]  C   Picture Variavel
					NIL																	)	// [18]  L   Indica pulo de linha após o campo

oView := FWFormView():New()
oView:SetModel(oModel)

oView:showUpdateMsg(.F.)
oView:showInsertMsg(.F.)

oView:AddField('VIEWSAJH',oStrSAJH,'SAJMASTER')
oView:CreateHorizontalBox('SAJCAB',20)
oView:SetOwnerView( 'VIEWSAJH', 'SAJCAB' )

oView:AddGrid('VIEWSAJI',oStrSAJI,'SAJDETAILS')
oView:CreateHorizontalBox('SAJITE',80)
oView:SetOwnerView( 'VIEWSAJI', 'SAJITE' )

oView:EnableTitleView('VIEWSAJH',STR0002)  //Grupo de Compras
oView:EnableTitleView('VIEWSAJI',STR0004) // "Compradores"

oView:AddIncrementField( 'VIEWSAJI', 'AJ_ITEM' )


Return oView

/*/{Protheus.doc} MENUDEF()
Função para criar do menus

@author Rodrigo M Pontes
@since  18/10/2018
@version 1.0
@return aRotina 
/*/

Static Function MenuDef()

Local aRotina 		:= {} //Array utilizado para controlar opcao selecionada
Local aRotPE		:= {}
Local lMTA086MNU	:= ExistBlock("MTA086MNU")

ADD OPTION aRotina TITLE STR0005	ACTION "VIEWDEF.COMA086"	OPERATION 2		ACCESS 0  	//"Visualizar"
ADD OPTION aRotina TITLE STR0006	ACTION "VIEWDEF.COMA086"	OPERATION 3  	ACCESS 0	//"Incluir"
ADD OPTION aRotina TITLE STR0007	ACTION "VIEWDEF.COMA086"	OPERATION 4 	ACCESS 0	//"Alterar"
ADD OPTION aRotina TITLE STR0008	ACTION "VIEWDEF.COMA086"	OPERATION 5  	ACCESS 3	//"Excluir"

If lMTA086MNU
    aRotPE := ExecBlock("MTA086MNU",.F.,.F.,{aRotina})
	If ValType(aRotPE) == "A" .And. Len(aRotPE) > 0
		aRotina := aRotPE
	Endif
EndIF

Return aRotina

/*/{Protheus.doc} CA086CpoOk
Valida edição de campo na Grid

@author Rodrigo M Pontes
@since 18/10/2018
@version 1.0
/*/

Function CA086CpoOk(oModel,nLine,cAction,cIdField,xValue,xCurrentValue)

Local aArea 	:= GetArea()
Local lRet  	:= .T.
Local nX    	:= 0
Local cCod		:= ""
Local nPosUsr   := aScan(aHeader,{|x| AllTrim(x[2]) == "AJ_USER"})

If cIdField == "AJ_USER"
	If cAction == "SETVALUE"
		If !Empty(xValue)
			For nX := 1 to Len(aCols)
				If !aCols[nX,Len(aCols[nX])] .And. nX <> nLine
					If aCols[nX][nPosUsr] == xValue
						lRet := .F.
						Help(" ",1,"JAGRAVADO")
						Exit
					Endif
				EndIf
			Next nX
		Else
			lRet := .F.
			Help(" ",1,"A086LINOK")
		Endif
	Endif
Endif

If cAction == "UNDELETE"
	cCod := aCols[nLine,nPosUsr]
	If !Empty(cCod)
		For nX := 1 to Len(aCols)
			If !aCols[nX,Len(aCols[nX])] .And. nX <> nLine
				If aCols[nX][nPosUsr] == cCod
	       	    	lRet := .F.
	           	    Help(" ",1,"JAGRAVADO")
	           		Exit
	           	Endif
	       	EndIf
	   	Next nX
	Endif
ElseIf cAction == "DELETE"	
	cCod := aCols[nLine,nPosUsr]
	If !Empty(cCod)
		For nX := 1 to Len(aCols)
			If !aCols[nX,Len(aCols[nX])] .And. nX == nLine
				If aCols[nX][nPosUsr] == cCod
					lRet := CA086DelCo()
					If !lRet
						Help(" ",1,"CA086NoDel",,STR0011,1,0) //"Este Grupo de Compras possui amarracao em outra tabela, por isso, nao pode ser excluido."
					EndIf
				Endif
			EndIf
		Next nX
	Endif
Endif 

RestArea(aArea)

Return lRet

/*/{Protheus.doc} CA086PosVl
Pós Valide 
@1 - valida o campo descrição. 

@author Mauricio.Junior
@since 09/09/2019
@version 1.0
/*/
Function CA086PosVl(oModel)
Local lRet 		:= .T.
Local oModel 	:= FwModelActive()
Local oModelSAJ := oModel:GetModel('SAJMASTER')

If Empty(oModelSAJ:GetValue("AJ_DESC")) 
	lRet := .F.
	Help(" ",1,"COMA086A",, STR0010, 1, 0,,,,,,{STR0009})//É necessário preencher o campo (Desc Grp Com - Descrição do Grupo de Compras).
EndIf

Return lRet


/*/{Protheus.doc} CA086DelCo
Pós Valide 
@ - Verifica se eh possivel a exclusao de um Comprador. Executando as relacoes que antes era feita pelo SX9  
@ Retorno: ExpL1 = .T. se o comprador posicionado poder ser deletado
@author Eduardo Dias
@since 10/12/2019
/*/
Static Function CA086DelCo()
Local aArea     := GetArea()
Local aAreaSAJ  := SAJ->(GetArea())
Local aAreaSM0  := SM0->(GetArea())
Local aFilial   := {}
Local aTabExc	:= {}
Local nY		:= 0
Local lRetorno  := .T.
Local cFiliais	:= ""

lRetorno := ExistChav("SAJ",SAJ->AJ_GRCOM+SAJ->AJ_USER, 2)

If lRetorno //Verifica em todas as Filiais
	//Monta Array para verificar o compartilhamento das tabelas e montagem da string de filiais utilizada nas querys.
	//Se for alterar este Array, verifique a posição das tabelas na utilizacao das querys abaixo.
	Aadd(aTabExc,{"SS4","='"+xFilial("SS4")+"'"})
	Aadd(aTabExc,{"SY1","='"+xFilial("SY1")+"'"})
	Aadd(aTabExc,{"SC1","='"+xFilial("SC1")+"'"})
	Aadd(aTabExc,{"SC8","='"+xFilial("SC8")+"'"})
	Aadd(aTabExc,{"SCY","='"+xFilial("SCY")+"'"})
	Aadd(aTabExc,{"SAI","='"+xFilial("SAI")+"'"})
	Aadd(aTabExc,{"SB1","='"+xFilial("SB1")+"'"})
	Aadd(aTabExc,{"SC7","='"+xFilial("SC7")+"'"})
		
	dbSelectArea("SM0")
	MsSeek(cEmpAnt)
	While ! Eof() .And. SM0->M0_CODIGO == cEmpAnt
		If FWModeAccess("SAJ") != "E"
			Aadd(aFilial,FWGETCODFILIAL)
		EndIf
		cFiliais += "'"+FWGETCODFILIAL+"', "	
		dbSkip()
	EndDo

	RestArea(aAreaSM0)
	If FWModeAccess("SAJ") == "E"
		Aadd(aFilial,cFilAnt)
	EndIf

	For nY := 1 To Len(aTabExc)
		If FWModeAccess(aTabExc[nY][1]) == "E"
			aTabExc[nY][2] := "%IN (" + cFiliais
			aTabExc[nY][2] := Left(aTabExc[nY][2], Len(aTabExc[nY][2])-2)+')%'
		Else
			aTabExc[nY][2] := "%" + aTabExc[nY][2] + "%"
		EndIf	 
	Next nY

	If lRetorno .And. !Empty(RetSqlName( "SS4" )) //Verifica a existencia de registros em Descricao Generica do Produto - Tabela exclusiva BRA
		BeginSQL Alias "TMPSS4" //-- Monta query para verificar se o Grupo de Compras foi utilizado na tabela SS4
			SELECT COUNT(*) QTDSS4
			FROM %Table:SS4% SS4
			WHERE SS4.%NotDel% AND
				SS4.S4_FILIAL %Exp:aTabExc[1][2]% AND 
				SS4.S4_COD = %Exp:SAJ->AJ_GRCOM%
		EndSQL

		If TMPSS4->QTDSS4 != 0 //-- Verifica as condicoes caso exista registro no relacionamento entre as tabelas
			If FWIsInCallStack("CA086Delet")
				lRetorno := .F.
			Else
				lRetorno := CA086QTDAJ(SAJ->AJ_GRCOM)
			EndIf
		EndIf

		TMPSS4->(dbCloseArea())
	EndIf

	If lRetorno //Verifica a existencia de registros no Cadastro de Compradores
		BeginSQL Alias "TMPSY1" //-- Monta query para verificar se o Grupo de Compras foi utilizado na tabela SY1 (Compradores)
			SELECT COUNT(*) QTDSY1
			FROM %Table:SY1% SY1
			WHERE SY1.%NotDel% AND
				SY1.Y1_FILIAL %Exp:aTabExc[1][2]% AND //%xFilial:CNW% AND
				SY1.Y1_GRUPCOM = %Exp:SAJ->AJ_GRCOM% 
		EndSQL

		If TMPSY1->QTDSY1 != 0 //-- Verifica as condicoes caso exista registro no relacionamento entre as tabelas
			If FWIsInCallStack("CA086Delet")
				lRetorno := .F.
			Else
				lRetorno := CA086QTDAJ(SAJ->AJ_GRCOM)
			EndIf
		EndIf

		TMPSY1->(dbCloseArea())

	EndIf

	If lRetorno //Verifica a existencia de registros na Solicitação de Compras para este grupo
		BeginSQL Alias "TMPSC1" //-- Monta query para verificar se o Grupo de Compras foi utilizado na tabela SC1 (Solicitacao de Compras)
			SELECT COUNT(*) QTDSC1
			FROM %Table:SC1% SC1
			WHERE SC1.%NotDel% AND
				SC1.C1_FILIAL %Exp:aTabExc[3][2]% AND
				SC1.C1_GRUPCOM = %Exp:SAJ->AJ_GRCOM% 
		EndSQL

		If TMPSC1->QTDSC1 != 0 //-- Verifica as condicoes caso exista registro no relacionamento entre as tabelas
			If FWIsInCallStack("CA086Delet")
				lRetorno := .F.
			Else
				lRetorno := CA086QTDAJ(SAJ->AJ_GRCOM)
			EndIf
		EndIf

		TMPSC1->(dbCloseArea())

	EndIf

	If lRetorno //Verifica a existencia de registros na Solicitação de Compras para este grupo
		BeginSQL Alias "TMPSC8" //-- Monta query para verificar se o Grupo de Compras foi utilizado na tabela SC1 (Solicitacao de Compras)
			SELECT COUNT(*) QTDSC8
			FROM %Table:SC8% SC8
			WHERE SC8.%NotDel% AND
				SC8.C8_FILIAL %Exp:aTabExc[4][2]% AND
				SC8.C8_GRUPCOM = %Exp:SAJ->AJ_GRCOM% 
		EndSQL

		If TMPSC8->QTDSC8 != 0 //-- Verifica as condicoes caso exista registro no relacionamento entre as tabelas
			If FWIsInCallStack("CA086Delet")
				lRetorno := .F.
			Else
				lRetorno := CA086QTDAJ(SAJ->AJ_GRCOM)
			EndIf
		EndIf

		TMPSC8->(dbCloseArea())

	EndIf

	If lRetorno //Verifica a existencia de registros no historico de Pedido de Compras
		BeginSQL Alias "TMPSCY" //-- Monta query para verificar se o Grupo de Compras foi utilizado na tabela SCY (Historico de Pedido de Compras)
			SELECT COUNT(*) QTDSCY
			FROM %Table:SCY% SCY
			WHERE SCY.%NotDel% AND
				SCY.CY_FILIAL %Exp:aTabExc[4][2]% AND
				SCY.CY_GRUPCOM = %Exp:SAJ->AJ_GRCOM% 
		EndSQL

		If TMPSCY->QTDSCY != 0 //-- Verifica as condicoes caso exista registro no relacionamento entre as tabelas
			If FWIsInCallStack("CA086Delet")
				lRetorno := .F.
			Else
				lRetorno := CA086QTDAJ(SAJ->AJ_GRCOM)
			EndIf
		EndIf

		TMPSCY->(dbCloseArea())

	EndIf

	If lRetorno //Verifica a existencia de registros no Cadastro de solicitantes
		BeginSQL Alias "TMPSAI" //-- Monta query para verificar se o Grupo de Compras foi utilizado na tabela SAI (Solicitantes)
			SELECT COUNT(*) QTDSAI
			FROM %Table:SAI% SAI
			WHERE SAI.%NotDel% AND
				SAI.AI_FILIAL %Exp:aTabExc[5][2]% AND
				SAI.AI_GRUPCOM = %Exp:SAJ->AJ_GRCOM% 
		EndSQL

		If TMPSAI->QTDSAI != 0 //-- Verifica as condicoes caso exista registro no relacionamento entre as tabelas
			If FWIsInCallStack("CA086Delet")
				lRetorno := .F.
			Else
				lRetorno := CA086QTDAJ(SAJ->AJ_GRCOM)
			EndIf
		EndIf

		TMPSAI->(dbCloseArea())

	EndIf

	If lRetorno //Verifica a existencia de registros no Cadastro de Produto
		BeginSQL Alias "TMPSB1" //-- Monta query para verificar se o Grupo de Compras foi utilizado na tabela SB1 (Produtos)
			SELECT COUNT(*) QTDSB1
			FROM %Table:SB1% SB1
			WHERE SB1.%NotDel% AND
				SB1.B1_FILIAL %Exp:aTabExc[6][2]% AND
				SB1.B1_GRUPCOM = %Exp:SAJ->AJ_GRCOM% 
		EndSQL

		If TMPSB1->QTDSB1 != 0 //-- Verifica as condicoes caso exista registro no relacionamento entre as tabelas
			If FWIsInCallStack("CA086Delet")
				lRetorno := .F.
			Else
				lRetorno := CA086QTDAJ(SAJ->AJ_GRCOM)
			EndIf
		EndIf

		TMPSB1->(dbCloseArea())

	EndIf

	If lRetorno //Verifica a existencia de registros no Pedido de Compras
		BeginSQL Alias "TMPSC7" //-- Monta query para verificar se o Grupo de Compras foi utilizado na tabela SC7 (Pedido de Compras)
			SELECT COUNT(*) QTDSC7
			FROM %Table:SC7% SC7
			WHERE SC7.%NotDel% AND
				SC7.C7_FILIAL %Exp:aTabExc[6][2]% AND
				SC7.C7_GRUPCOM = %Exp:SAJ->AJ_GRCOM% 
		EndSQL

		If TMPSC7->QTDSC7 != 0 //-- Verifica as condicoes caso exista registro no relacionamento entre as tabelas
			If FWIsInCallStack("CA086Delet")
				lRetorno := .F.
			Else
				lRetorno := CA086QTDAJ(SAJ->AJ_GRCOM)
			EndIf
		EndIf

		TMPSC7->(dbCloseArea())

	EndIf
EndIf

RestArea(aAreaSM0)
RestArea(aAreaSAJ)
RestArea(aArea)

Return(lRetorno)

//-------------------------------------------------------------------
/*/{Protheus.doc} CA086DelCo
@ - Verifica a quantidade de registro no Grupo de Compra (SAJ)  
@ Retorno: ExpL1 = .T. se o comprador posicionado pode ser deletado
@author Eduardo Dias
@since 11/12/2019
/*/
//-------------------------------------------------------------------
Static Function CA086QTDAJ(cGrpCom)
Local aArea		:= GetArea()
Local cAliasSAJ	:= GetNextAlias()
Local lRet		:= .T.

Default cGrpCom := " "
Default clocal	:= " "

BeginSQL Alias cAliasSAJ //-- Monta query para verificar a quantidade de compradores existente no Grupo de Compras posicionado),
	SELECT COUNT(*) QTDSAJ
	FROM %Table:SAJ% SAJ
	WHERE SAJ.%NotDel% AND
		SAJ.AJ_GRCOM = %Exp:cGrpCom% 
EndSQL

If (cAliasSAJ)->QTDSAJ < 2 //Se houver apenas 1 comprador no cadastro, nao deve permitir a exclusao
	lRet := .F.
EndIf

(cAliasSAJ)->(dbCloseArea())

RestArea(aArea)

Return lRet	  


//-------------------------------------------------------------------
/*/{Protheus.doc} CA086Delet
@Rotina para tratamento na opcao de exclusao
@Verifica se o Grupo de compras está sendo utilizado em uma das tabelas 
	(SS4, SY1, SC1, SC8, SCY, SAI, SB1, SC7)

@author Eduardo.Dias
@since 11/12/2019
/*/
//-------------------------------------------------------------------
Function CA086Delet(oModel)
Local lExclui	:= oModel:GetOperation() == MODEL_OPERATION_DELETE
Local lRet		:= .T.

If lExclui
	lRet := CA086DelCo() //Verifica se o Grupo de compras tem vinculo em alguma das tabelas informadas acima

	If !lRet
		Help(" ",1,"CA086NoDel",,STR0011,1,0) //"Este Grupo de Compras possui amarracao em outra tabela, por isso, nao pode ser excluido."
	EndIf
EndIf

Return lRet
