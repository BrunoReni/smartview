#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
#Include "MATA114.CH"
#INCLUDE 'FWLIBVERSION.CH'

Static lUsrCampos	:= ExistBlock("MT114CAB")
Static cCabCampos   := ""
Static cUsrCampos	:= ""
Static lUsrCpoGrid	:= ExistBlock("MT114GRID")
Static cUsrCpoGrid	:= ""
Static lDesIniPad   := .F.

Static lAjItemDBL	:= .F.
Static nTItemAnt	:= 0

Function MATA114()

Local oBrowse

If FwModeAccess("SAL") <> FwModeAccess("DBL")
	MsgAlert(STR0020) // "Para o correto funcionamento da rotina o compartilhamento das tabelas SAL/DBL precisam estar iguais."
Endif  

LoadUsrCpo()

oBrowse := FWMBrowse():New()
oBrowse:SetAlias("SAL")                                          
oBrowse:SetDescription(STR0001)  //"Grupos de aprovação"
oBrowse:Activate()

Return

//-------------------------------------------------------------------	
/*/{Protheus.doc} ModelDef
Definição do modelo de Dados

@author guilherme.pimentel

@since 27/08/2013
@version 1.0
/*/
//-------------------------------------------------------------------

Static Function ModelDef()

Local oModel
Local oStr1	:= Nil
Local oStr2 := Nil
Local oStr3	:= FWFormStruct(1,'DBL')
Local oStr4	:= FWFormStruct(1,'DHM') // ,{|cCampo| !AllTrim(cCampo) $ "DHM_GRUPO|DHM_APROV|DHM_TIPCOM"}
Local aUniqLn
Local nTItem:= TamSX3("DBL_ITEM")[1]


LoadUsrCpo()

oStr1 := FWFormStruct(1,'SAL',{|cCampo| AllTrim(cCampo) $ cCabCampos} ) 
oStr2 := FWFormStruct(1,'SAL',{|cCampo| !AllTrim(cCampo) $ cCabCampos}) 

oModel := MPFormModel():New('MATA114',,{|o| MATA114POS(o)}, {|o|A114Commit(oModel)}, {|o|A114Cancel(oModel)})
oModel:SetDescription(STR0002)  //"Grupo de Aprovação"
oStr1:SetProperty('AL_DESC',MODEL_FIELD_OBRIGAT,.T.)

oModel:addFields('ModelSAL',,oStr1)
oModel:SetPrimaryKey({ 'AL_FILIAL', 'AL_COD', 'AL_ITEM' })

oModel:addGrid('DetailSAL','ModelSAL',oStr2, { |oModelGrid, nLine, cAction, cField| MATA114LPRE(oModelGrid,nLine,cAction,cField,"DetailSAL")},{|oModelGrid| A114LinOK(oModelGrid)},{|oModelGrid,nLine,cAction,cField,xValue,xOldValue| A114PRE6(nLine,cAction,cField,xValue,xOldValue,oModelGrid)} )
oModel:GetModel('DetailSAL'):SetUniqueLine( { 'AL_APROV' } )

//Validação: modelos Grid da tabela DBL e SAL
oModel:addGrid('DetailDBL','ModelSAL',oStr3,,{ |oModelGrid| MATA114LPOS(oModelGrid)} )

aUniqLn := { 'DBL_CC', 'DBL_CONTA', 'DBL_ITEMCT', 'DBL_CLVL' } 
aUniqLn := MTGETFEC("DBL","DBL", aUniqLn)
oModel:GetModel('DetailDBL'):SetUniqueLine( aUniqLn )

oModel:addGrid('DetailDHM','DetailSAL',oStr4)
oModel:GetModel('DetailDHM'):SetUniqueLine( {"DHM_GRUPO","DHM_APROV","DHM_TIPCOM"} )

oModel:SetRelation('DetailSAL', { { 'AL_FILIAL', 'xFilial("SAL")' }, { 'AL_COD', 'AL_COD' } }, SAL->(IndexKey(1)) )
oModel:SetRelation('DetailDBL', { { 'DBL_FILIAL', 'xFilial("DBL")' }, { 'DBL_GRUPO', 'AL_COD' } }, DBL->(IndexKey(1)) )
oModel:SetRelation('DetailDHM', { { 'DHM_FILIAL', 'xFilial("DHM")' }, { 'DHM_GRUPO', 'AL_COD' } , { 'DHM_APROV', 'AL_APROV' }  }, DHM->(IndexKey(1)) )

oModel:getModel('ModelSAL'):SetDescription(STR0006) //"Cabeçalho"
oModel:getModel('DetailSAL'):SetDescription(STR0007) //"Grupos de Aprov."
oModel:getModel('DetailDBL'):SetDescription(STR0008) //"Entidades Cont X Grp Apr"
oModel:getModel('DetailDHM'):SetDescription(STR0021) //"Tp.Compra X Aprovador"

oModel:getModel('ModelSAL'):SetOnlyQuery(.F.)
oModel:getModel('DetailSAL'):SetOptional(.T.)
oModel:getModel('DetailDBL'):SetOptional(.T.)
oModel:getModel('DetailDHM'):SetOptional(.T.)

If nTItem > 2 // Verifica se o campo DBL_ITEM aumentou de tamanho
	oModel:getModel('DetailDBL'):SetMaxLine(9999)
Endif

oModel:AddRules( 'DetailDBL', 'DBL_CONTA', 'DetailDBL', 'DBL_CC', 3 )
oModel:AddRules( 'DetailDBL', 'DBL_ITEMCT', 'DetailDBL', 'DBL_CONTA', 3 )
oModel:AddRules( 'DetailDBL', 'DBL_CLVL', 'DetailDBL', 'DBL_ITEMCT', 3 )

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Definição do interface

@author guilherme.pimentel

@since 27/08/2013
@version 1.0
/*/
//-------------------------------------------------------------------

Static Function ViewDef()

Local oView
Local oModel := ModelDef()
Local lAbaDoc := SuperGetMV("MV_ALTPDOC", .F., .F.)
Local oStr1	:= Nil
Local oStr2	:= Nil 
Local oStr3	:= FWFormStruct(2,'DBL')
Local oStr4	:= FWFormStruct(2,'DHM', {|cCampo| !AllTrim(cCampo) $ "DHM_GRUPO|DHM_APROV||"})
Local nTItem:= TamSX3("DBL_ITEM")[1]

lAjItemDBL := .F. // Reseta conteúdo a cada abertura de Grupo de aprovação

LoadUsrCpo()

oStr2 := FWFormStruct(2,'SAL',{|cCampo| !(AllTrim(cCampo) $ cCabCampos) .Or. AllTrim(cCampo) $ cUsrCpoGrid}) 

If !lAbaDoc
	oStr1 := FWFormStruct(2,'SAL',{|cCampo| AllTrim(cCampo) $ ("AL_COD|AL_DESC"+cUsrCampos)})
Else
	oStr1 := FWFormStruct(2,'SAL',{|cCampo| AllTrim(cCampo) $ cCabCampos})
EndIf

oView := FWFormView():New()
oView:SetModel(oModel)

oView:AddField('Master_SAL' , oStr1,'ModelSAL' )
oView:AddGrid('Detail_SAL' , oStr2,'DetailSAL')
oView:AddGrid('Detail_DBL' , oStr3,'DetailDBL')  
oView:AddGrid('Detail_DHM' , oStr4,'DetailDHM')  

oView:CreateHorizontalBox( 'CAB', 25)
oView:CreateHorizontalBox( 'ITENS', 75)

oView:CreateFolder( 'FOLDER', 'ITENS')
oView:AddSheet('FOLDER','FLD01',STR0003) //"Aprovadores"
oView:AddSheet('FOLDER','FLD02',STR0004) //"Entidades Contábeis"

oView:CreateHorizontalBox( 'Aprov', 50, /*owner*/, /*lUsePixel*/, 'FOLDER', 'FLD01')
oView:CreateHorizontalBox( 'EntCont', 100, /*owner*/, /*lUsePixel*/, 'FOLDER', 'FLD02')
oView:CreateHorizontalBox( 'ITBAIXO', 50, /*owner*/, /*lUsePixel*/, 'FOLDER', 'FLD01')

oView:CreateFolder( 'FOLDER2', 'ITBAIXO')
oView:AddSheet('FOLDER2','FLD05',STR0021) //"Tp.Compra X Aprovadores"
oView:CreateHorizontalBox( 'TpcAprov', 100, /*owner*/, /*lUsePixel*/, 'FOLDER2', 'FLD05')

oView:SetOwnerView('Master_SAL','CAB')
oView:SetOwnerView('Detail_SAL','Aprov')
oView:SetOwnerView('Detail_DBL','EntCont')
oView:SetOwnerView('Detail_DHM','TpcAprov')

oView:EnableTitleView('Master_SAL' , STR0005 ) //"Grupo de aprovadores" 

oView:AddIncrementField('Detail_SAL' , 'AL_ITEM' ) 
oView:AddIncrementField('Detail_DBL' , 'DBL_ITEM' )

If nTItem > 2 // Verifica se o campo DBL_ITEM aumentou de tamanho
	oView:SetViewProperty('Detail_DBL', 'CHANGELINE', {{ |oView| changeLine(oView) }})
Endif

oStr3:RemoveField( 'DBL_GRUPO' )

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} MENUDEF()
Função para criar do menu 

@author guilherme.pimentel
@since 29/08/2013
@version 1.0
@return aRotina 
/*/
//-------------------------------------------------------------------

Static Function MenuDef() 

Local aRotina := {} //Array utilizado para controlar opcao selecionada

ADD OPTION aRotina TITLE STR0009	ACTION "VIEWDEF.MATA114"	OPERATION 2	ACCESS 0	//"Visualizar"
ADD OPTION aRotina TITLE STR0010	ACTION "VIEWDEF.MATA114"	OPERATION 3	ACCESS 0	//"Incluir"
ADD OPTION aRotina TITLE STR0011	ACTION "VIEWDEF.MATA114"	OPERATION 4	ACCESS 0	//"Alterar"
ADD OPTION aRotina TITLE STR0012	ACTION "VIEWDEF.MATA114"	OPERATION 5	ACCESS 3	//"Excluir"
ADD OPTION aRotina TITLE STR0013	ACTION "VIEWDEF.MATA114"	OPERATION 8	ACCESS 0	//"Imprimir"
ADD OPTION aRotina TITLE STR0017	ACTION "A114SubApr()"	 	OPERATION 8 ACCESS 0 	//"Subst. de Aprovadores"	

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} A114Aprov()
Validação de existencia do aprovador 

@author guilherme.pimentel
@since 29/08/2013
@version 1.0
@return lRet 
/*/
//-------------------------------------------------------------------

Function A114Aprov()

Local oModel 		:= FWModelActive()	
Local oSAL_DETAIL 	:= oModel:GetModel('DetailSAL')
Local cVarAprov 	:= oSAL_DETAIL:GetValue("AL_APROV") 
Local nX        	:= 0
Local lRet      	:= .T.
Local nLinAtual 	:= oSAL_Detail:nLine

cVarAprov := If(Empty(cVarAprov),"",cVarAprov)

SAK->(dbSetOrder(1))
SAK->(MsSeek(xFilial("SAK")+cVarAprov))

For nX := 1 to oSAL_Detail:Length()
	oSAL_Detail:GoLine(nX)
	
	If (SAK->AK_USER == oSAL_DETAIL:GetValue("AL_USER") .And. oSAL_Detail:IsDeleted() )
		Help(" ",1,"JAGRAVADO")
		lRet := .F.
		Exit
	EndIf
	
Next nX

oSAL_Detail:Goline(nLinAtual)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} MATA114POS(oModel)
Função para validação completa do modelo.(tudok)

@author Vitor Pires
@since 24/09/2015
@version 1.0
@param oModel Modelo atual.
@return lRet 
/*/
//-------------------------------------------------------------------

Function MATA114POS(oModel)

Local oGridEC
Local nI
Local aSaveLine
Local oModelSAL := oModel:GetModel("DetailSAL")
Local cCodG		:= SAL->AL_COD
Local nDeletado	:= 0  
Local aAreaAl
Local lAviso	:= .T.
Local lAvisoOK	:= .F.   

//Inclusão: as linhas já foram validadas .ou. Não alterou campo - tipos de documento ? 
lRet := (oModel:GetOperation() == 3) .Or. (!oModelSAL:isModified()) .Or. (oModel:GetOperation() == 4) 
   
If lRet

	//Grid das entidades contabeis
	oGridEC := oModel:GetModel('DetailDBL')
	
	//Salva posição da linha no grid
	aSaveLine := FWSaveRows()
	
	//Revalida as linhas
	For nI := 1 to oGridEC:Length()
		
		oGridEC:GoLine(nI)
		lRet := MATA114LPOS(oGridEC)
		
		If ! lRet
			Exit		
		EndIf
		
	Next nI
	
	//Volta à posição da linha anterior no grid
	FWRestRows( aSaveLine )


EndIf

If lRet
	If oModel:GetOperation()== MODEL_OPERATION_DELETE

		//Valida se o Grupo de Aprovação é utilizado nos Cadastros de Compradores
		dbSelectArea("SY1")
		dbSeek(xFilial())
		While !Eof() .And. xFilial()==Y1_FILIAL
			If (SY1->Y1_GRAPROV==cCodG) .Or. (SY1->Y1_GRAPRCP==cCodG)
				Help(" ",1,"A096EXGRAP")
				lRet := .F.
			EndIf
			dbSkip()
		EndDo
		
		//Valida se o Grupo de Aprovação é utilizado em parâmetros padrões
		If AllTrim(GetMv("MV_PCAPROV")) == AllTrim(cCodG)
			Help(" ",1,"A114PCAPROV")
			lRet := .F.
		EndIf
		
		If AllTrim(GetMv("MV_NFAPROV")) == AllTrim(cCodG)
			Help(" ",1,"A114NFAPROV")
			lRet := .F.
		EndIf
		
		If AllTrim(GetMv("MV_APGRDFL")) == AllTrim(cCodG)
			Help(" ",1,"A114APGRDFL")
			lRet := .F.
		EndIf
		
		aAreaAL := SAL->(GetArea())
		cGrupo  := SAL->AL_COD
		SAL->(DbSetOrder(1))
		SAL->(DbSeek(xFilial("SAL")+cGrupo))
		While SAL->(!Eof()) .AND. SAL->AL_COD == cGrupo			
			//Valida se o aprovador possui pendências
			lRet := VldPendSCR(4,,SAL->AL_APROV)
			
			If !lRet
				Exit
			EndIf
			
			SAL->(dbSkip())
		EndDo
		RestArea(aAreaAL)
	EndIf
EndIf

If lRet .And. oModel:GetOperation()== MODEL_OPERATION_UPDATE
	For nI := 1 To oModelSAL:Length()
		oModelSAL:GoLine( nI )
		If (oModelSAL:IsDeleted())
			nDeletado++
		EndIf
	Next nI	
	
	//Exclusão de todos os itens - Permitida apenas pela opção "Excluir"
	If nDeletado == oModelSAL:Length()		
		Help(" ",1,"A114EXULAP")
		lRet := .F.
	EndIf

		aAreaAl := SAL->(GetArea())
		SAL->(DbSetOrder(1))
		SAL->(DbSeek(xFilial("SAL")+cCodG))
		While SAL->(!Eof()) .AND. SAL->AL_COD == cCodG			
			//Valida se o aprovador possui pendências
			lRet := VldPendSCR(4,,SAL->AL_APROV,,lAviso,@lAvisoOK) // Apenas avisa o usuário causo houver alçadas abertas
			
			If !lRet .Or. lAvisoOK // Para emitir o aviso só uma vez
				Exit
			EndIf
			
			SAL->(dbSkip())
		EndDo
		restArea(aAreaAl)
EndIf


Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} MATA114LPRE
Funcao para pre-validacao da linha do modelo.

@author carlos.capeli
@since 13/04/2016
@version 1.0
@param	oModelGrid	- Modelo SAL
		nLinha		- Linha que esta sendo alterada
		cAcao		- Acao que esta sendo executada
		cCampo		- Campo que esta sendo alterado
@return lRet 
/*/
//-------------------------------------------------------------------
Function MATA114LPRE(oModelGrid,nLinha,cAcao,cCampo,cModel)

Local lRet 		 := .T.
Local oModel 	 := oModelGrid:GetModel()
Local oModelSAL  := oModel:GetModel("DetailSAL")
Local nOperation := oModel:GetOperation()
Local cAprov 	 := oModelSAL:GetValue("AL_APROV")


If cAcao == 'DELETE' .And. nOperation == MODEL_OPERATION_UPDATE .AND. cModel == "DetailSAL"
	If oModelSAL:aDataModel[nLinha][4] > 0//Se Recno Maior que Zero - Registro pré-existente
	    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄPPÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ-Ä¿
		//³ Nao permite excluir o aprovador do GRUPO DE APROVACAO, se    ³
		//³ houver documento pendente para ser aprovado                  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ-ÄÄÙ

		lRet := VldPendSCR(2,,cAprov)	
	EndIf
	//Valida se a linha esta Ok para exclusão 	
	If lRet
		lRet := A114LinOK(oModelGrid)
	EndIf	

EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} MATA114LPOS(oModel)
Função para validação da linha do modelo.

@author guilherme.pimentel
@since 29/08/2013
@version 1.0
@param oModel Modelo atual.
@return lRet 
/*/
//-------------------------------------------------------------------

Function MATA114LPOS(oModelDBL)

Local oModel	:= FWModelActive()
Local oModelCab	:= oModel:GetModel('ModelSAL')

Local aEntCont 	:= { 'DBL_CC', 'DBL_CONTA', 'DBL_ITEMCT', 'DBL_CLVL' } 
Local aTpDoc	:= { 'AL_DOCAE','AL_DOCCP', 'AL_DOCMD', 'AL_DOCNF', 'AL_DOCPC', 'AL_DOCSA', 'AL_DOCSC', 'AL_DOCST', 'AL_DOCIP', 'AL_DOCCT', 'AL_DOCGA' } 

Local cFiltOpc	:= ""
Local cUpdSAL	:= ""
Local cEntX		:= ""
Local cGrupo  	:= oModelDBL:GetValue('DBL_GRUPO')
Local cCC     	:= oModelDBL:GetValue('DBL_CC')
Local cConta  	:= oModelDBL:GetValue('DBL_CONTA')
Local cItemCT 	:= oModelDBL:GetValue('DBL_ITEMCT')
Local cClvl   	:= oModelDBL:GetValue('DBL_CLVL')

Local nX		:= 0
Local nCount	:= 0

Local lRet		:= .T.

// Ponto de entrada para tratar o tipos de documentos incluidos via ponto de entrada MT114CAB
If Existblock("MT114TDC")
	aTpDoc := Execblock("MT114TDC",.F.,.F.,{aTpDoc}) 
EndIf

aEntCont := MTGETFEC("DBL","DBL", aEntCont)
cFiltOpc := "%"

//-- Filtra entidades contabeis
If Len(aEntCont) > 4
	For nX := 5 to Len(aEntCont)
		cEntX := oModelDBL:GetValue(aEntCont[nX])
		cFiltOpc += " AND " +aEntCont[nX]+ "= '" +cEntX+ "'"
	Next nX
	
EndIf

If lRet
	If Len(aTpDoc) > 0
		//-- Filtra conforme tipos de documentos
		cFiltOpc += " AND  ("
		
		For nX := 1 to Len(aTpDoc)
			If lMark := oModelCab:GetValue(aTpDoc[nX])
				nCount++
				If nCount > 1
					cFiltOpc += " OR "
				EndIf
				cFiltOpc 	+= "  " +aTpDoc[nX]+ "= 'T'"
				If Empty(cUpdSAL)
					cUpdSAL	+= "  " +aTpDoc[nX]+ "= 'T'"
				Else
					cUpdSAL	+= ",  " +aTpDoc[nX]+ "= 'T'"
				EndIf
			Else
				If Empty(cUpdSAL)
					cUpdSAL	+= "  " +aTpDoc[nX]+ "= 'F'"
				Else
					cUpdSAL	+= ",  " +aTpDoc[nX]+ "= 'F'"
				EndIf
			EndIf
		Next nX
		
		cFiltOpc += " ) "	
	EndIf

cFiltOpc += "%"

// Limpa filtro caso nao haja nenhum tipo marcado
	If '( )' $ cFiltOpc
		cFiltOpc := "%%"
	EndIf
	
	BeginSQL Alias "QTDENTCO"
	
		SELECT 
		  DBL_GRUPO,
		  AL_DOCAE,
		  AL_DOCCP,
		  AL_DOCMD,
		  AL_DOCNF,
		  AL_DOCPC,
		  AL_DOCSA,
		  AL_DOCSC,
		  AL_DOCST,
		  AL_DOCIP,
		  AL_DOCCT,
		  AL_DOCGA
		FROM %Table:DBL% DBL
		LEFT JOIN %Table:SAL% SAL
		ON DBL.DBL_GRUPO = SAL.AL_COD
		WHERE DBL.DBL_FILIAL = %xFilial:DBL%
		
			AND DBL.DBL_FILIAL=SAL.AL_FILIAL
			
			AND DBL.DBL_GRUPO <> %exp:cGrupo%
			AND DBL.DBL_CC = %exp:cCC%
			AND DBL.DBL_CONTA = %exp:cConta%
			AND DBL.DBL_ITEMCT = %exp:cItemCT%
			AND DBL.DBL_CLVL = %exp:cClvl%
			AND DBL.%NotDel%
			
			AND SAL.%NotDel%
			
			%Exp:cFiltOpc%			
		EndSql
	
	
		If QTDENTCO->(!Eof())
			lRet := .F.
			Help(' ', 1,'MAT114lDUP')
		Else
			//Grava Marcacao para Todos os Aprovadores
			TCSqlExec("UPDATE " + RetSqlName("SAL") + " SET " + cUpdSAL + " WHERE D_E_L_E_T_ = ' ' AND AL_COD='" + oModelCab:GetValue("AL_COD") + "' AND AL_FILIAL='" + xFilial("SAL") + "' ") 
		EndIf
	
	QTDENTCO->(dbCloseArea())
EndIf

if oModelCab:GetOperation() == 3 //inclusão
	oModelCab:LoadValue('AL_DESC',oModelCab:GetValue('AL_DESC'))
endif

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} VldPendSCR(oFields)
Função para validação de pendencias/históricos dos aprovadores na SCR.

@author brunno.costa
@since 06/02/2018
@version 1.0
@return lRet 
/*/
//-------------------------------------------------------------------

Static Function VldPendSCR(nOpc, oFields, cAprov, oFilITGRP, lAviso, lAvisoOK)

	Local lRet		:= .T.
	Local cAlias 	:= ""
	Local cIndex 	:= ""
	Local cFiltro 	:= ""
	Local cGrupo 	:= SAL->AL_COD
	Local cHelp		:= "A114APROV"
	Local lValida	:= .T.
	Local cStatus	:= "|01|02|04|"//Bloqueado aguardando outros niveis | Aguardando liberacao do proprio usuario | Doc. bloqueado
	Local cFilITGRP	:= ""
	Local nRecSal   := 0
	Local cModel	:= FWModelActive()
	
	DEFAULT cAprov 		:= SAL->AL_APROV
	DEFAULT oFields		:= NIL
	DEFAULT oFilITGRP 	:= ""
	DEFAULT lAviso		:= .F. // Apenas avisa o usuário que há alçadas pendentes que não serão atualizadas
	DEFAULT lAvisoOK	:= .F. // Para que o aviso das pendências seja mostrado só uma vez
	
	//Se Inclui ou Não possui Recno na Linha (Adição de nova linha)	
	If cModel:GetOperation() == MODEL_OPERATION_INSERT .OR. (oFields != NIL .AND. oFields:aDataModel[oFields:nLine][4] == 0)
		lValida := .F.
	EndIf

	//Se Altera posiciona na tabela SAL conforme o Recno	
	If cModel:GetOperation() == MODEL_OPERATION_UPDATE .And. (oFields != NIL .And. ( nRecSal := oFields:aDataModel[oFields:nLine][4] ) > 0)	// Recno do registro gravado
		SAL->(DbGoto(nRecSal))
	EndIf

	If lValida .And. !lAvisoOK 
		If nOpc == 1//Validação do Campo AL_APROV
			cAprov := SAL->AL_APROV
		ElseIf nOpc == 3
			// Validação Alteração da DBM - Não permite alteração se houverem registros na SCR para não perder integridade de registros ref. CR_ITGRP
			cHelp		:= "A114ENTID"
			If !Empty(oFilITGRP)
				//cStatus 	:= "|01|02|03|04|05|06|" //Todos
				cFilITGRP	:= oFilITGRP
				cHelp		:= "A114ENTIDINTR"
			EndIf
		ElseIf nOpc == 4 // Validação Exclusão SAL
			cHelp		:= "A114ENTID"
		ElseIf nOpc == 5 // Validação Exclusão DBM
			cHelp		:= "A114ENTID"
		EndIf
		
		DbSelectArea("DBM")
		DBM->(DbSetOrder(1))//DBM_FILIAL+DBM_TIPO+DBM_NUM+DBM_GRUPO+DBM_ITGRP+DBM_USER+DBM_USEROR
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ-Ä¿
		//³ Nao permite alteração do aprovador do GRUPO DE APROVACAO, se ³
		//³ houver documento pendente para ser aprovado                  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ-ÄÄÙ                      
		cAlias := "SCR"
		cIndex := CriaTrab(Nil,.F.)
		cFiltro := "CR_FILIAL == '"+xFilial("SCR")+"' .AND. CR_APROV='"+cAprov+"' .AND. CR_STATUS $ '"+cStatus+"' .AND. CR_GRUPO='"+cGrupo+"'"
		If !Empty(cFilITGRP)//Alteração de Entidade Contábil na DBL, valida qualquer aprovador que já passou pelo Grupo de Aprovação
			cFiltro += " .OR. (CR_FILIAL == '"+xFilial("SCR")+"' .AND. CR_GRUPO='"+cGrupo+"' .AND. CR_ITGRP == '"+cFilITGRP+"')"
		EndIf
		IndRegua("SCR",cIndex,"CR_APROV",,cFiltro,'')
		SC7->(dbSetOrder(1))
		SCR->(DbGoTop())
		While !SCR->(Eof())
			If SCR->CR_TIPO == "IP"	// Aprovacao por item de pedido
				If SCR->CR_GRUPO == SAL->AL_COD .And. SCR->CR_APROV == cAprov
				 	//DBM_FILIAL+DBM_TIPO+DBM_NUM+DBM_GRUPO+DBM_ITGRP+DBM_USER+DBM_USEROR
					If Empty(SCR->CR_ITGRP) .OR. !DBM->(DbSeek(xFilial("DBM")+"IP"+SCR->CR_NUM+SCR->CR_GRUPO+SCR->CR_ITGRP))
						If SC7->(dbSeek(xFilial("SC7")+Padr(SCR->CR_NUM,Len(SC7->C7_NUM))))
							While !SC7->(Eof()) .And. SC7->C7_NUM == Padr(SCR->CR_NUM,Len(SC7->C7_NUM))
								If SC7->C7_CONAPRO == "B" .AND. Empty(SC7->C7_RESIDUO)
									If lAviso
										MsgInfo(STR0019) // 'Existem alçadas pendentes de aprovação para esse Grupo. As alterações serão aplicadas somente as novas alçadas geradas.'
										lAvisoOK := .T.
									Else
										Help(" ",1,cHelp)
										lRet := .F.										
									Endif
									Exit
								EndIf
								SC7->(dbSkip())
							EndDo							
						EndIf
					Else
						If SC7->(dbSeek(xFilial("SC7")+Padr(SCR->CR_NUM,Len(SC7->C7_NUM))+DBM->DBM_ITEM))
							If SC7->C7_CONAPRO == "B" .AND. Empty(SC7->C7_RESIDUO)
								If lAviso
									MsgInfo(STR0019) // 'Existem alçadas pendentes de aprovação para esse Grupo. As alterações serão aplicadas somente as novas alçadas geradas.'
									lAvisoOK := .T.
								Else
									Help(" ",1,cHelp)
									lRet := .F.									
								Endif
								Exit
							EndIf
						EndIf
					EndIf
				EndIf
			ElseIf SCR->CR_TIPO $ "PC|AE"	// Pedido|Autorização de Entrega
				If SCR->CR_GRUPO == SAL->AL_COD .And. SCR->CR_APROV == cAprov 
					If SC7->(dbSeek(xFilial("SC7")+Padr(SCR->CR_NUM,Len(SC7->C7_NUM))))
						While !SC7->(Eof()) .And. SC7->C7_NUM == Padr(SCR->CR_NUM,Len(SC7->C7_NUM))
							If SC7->C7_CONAPRO == "B" .AND. Empty(SC7->C7_RESIDUO)
								If lAviso
									MsgInfo(STR0019) // 'Existem alçadas pendentes de aprovação para esse Grupo. As alterações serão aplicadas somente as novas alçadas geradas.'
									lAvisoOK := .T.
								Else
									Help(" ",1,cHelp)
									lRet := .F.									
								Endif
								Exit
							EndIf
							SC7->(dbSkip())
						EndDo						
					EndIf
				EndIf
			ElseIf SCR->CR_TIPO == "SC"	// Aprovacao de SC por item contabil
				If SCR->CR_GRUPO == SAL->AL_COD .And. SCR->CR_APROV == cAprov 
					SC1->(dbSetOrder(1))
					If SC1->(dbSeek(xFilial("SC1")+Padr(SCR->CR_NUM,Len(SC1->C1_NUM))))
						While !SC1->(Eof()) .And. SC1->C1_NUM == Padr(SCR->CR_NUM,Len(SC1->C1_NUM))
							If SC1->C1_APROV == "B"
								If lAviso
									MsgInfo(STR0019) // 'Existem alçadas pendentes de aprovação para esse Grupo. As alterações serão aplicadas somente as novas alçadas geradas.'
									lAvisoOK := .T.
								Else
									Help(" ",1,cHelp)
									lRet := .F.									
								Endif
								Exit
							EndIf
							SC1->(dbSkip())
						EndDo						
					EndIf
				EndIf
			ElseIf SCR->CR_GRUPO == SAL->AL_COD .And. SCR->CR_APROV == cAprov 	// Aprovacao de mais documentos pendente
				If lAviso
					MsgInfo(STR0019) // 'Existem alçadas pendentes de aprovação para esse Grupo. As alterações serão aplicadas somente as novas alçadas geradas.'
					lAvisoOK := .T.
				Else
					Help(" ",1,cHelp)
					lRet := .F.
				Endif
				Exit
			EndIf
			SCR->(dbSkip())
			
			If !lRet .Or. lAvisoOK // Sair do primeiro laço quando houver pendências ou avisos
				Exit
			Endif
		EndDo
		Ferase(cIndex+OrdBagExt())
		RetIndex("SCR")
	EndIf


Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} A114SuPDif

Valida se o superior é igual ao aprovador

@author guilherme.pimentel
@since 19/10/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Function A114SuPDif(oModel)

Local lRet := .T.

If !Empty(oModel:GetValue("AL_APROSUP"))
	If oModel:GetValue("AL_APROSUP") == oModel:GetValue("AL_APROV") 
		Help(" ",1,"A114SuPDif",,STR0016,1,4)
		lRet := .F.
	EndIf
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} A114SubApr

Substituição de aprovadores

@author guilherme.pimentel
@since 20/10/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Function A114SubApr()

Return FWExecView(STR0017,"COMA220",MODEL_OPERATION_INSERT,,{|| .T.})

//-------------------------------------------------------------------
/*/{Protheus.doc} A114Commit
Ações na gravação Commit
@author Antenor.Silva
@since 26/11/2015
@version 12.1.6
@return lRet 
/*/
//-------------------------------------------------------------------
Function A114Commit(oModel)

Local lRet 		:= .T.
Local oModSAL	:= oModel:GetMOdel("ModelSAL")
Local oModDBL	:= oModel:GetModel("DetailDBL")
Local cDescG	:= oModSAL:GetValue("AL_DESC")
Local cCodG		:= oModSAL:GetValue("AL_COD")
Local cQuery	:= ""
Local lMSSQL    := "MSSQL"$TCGetDB()
Local nTDBLItem	:= TamSX3('DBL_ITEM')[1]
Local nQtdAprov	:= 0


// -- Alterar a descrição do grupo de aprovação para todos os aprovadores
If oModel:GetOperation()== MODEL_OPERATION_UPDATE
	SAL->(DbSetOrder(1)) //AL_FILIAL+AL_COD+AL_ITEM
	If SAL->(DbSeek(xFilial("SAL") + cCodG))
		While !SAL->(Eof()) .And. SAL->AL_FILIAL == xFilial("SAL") .And. SAL->AL_COD == cCodG .And. SAL->AL_DESC <> cDescG  
			Reclock("SAL",.F.)
			SAL->AL_DESC := cDescG
			SAL->(MsUnLock())
			SAL->(DbSkip())
		End
	EndIf
EndIf

lRet := FWFormCommit(oModel)

//Exclui registros da DBL caso não exista ao menos um registro relacionado na SAL
If oModel:GetOperation()== MODEL_OPERATION_UPDATE
	If Empty(cCodG) .And. !(oModDBL == Nil)
		cCodG := oModDBL:GetValue("DBL_GRUPO")
	EndIf
	DBL->(DbSetOrder(1)) //DBL_FILIAL+DBL_GRUPO+DBL_ITEM
	If DBL->(DbSeek(xFilial("DBL") + cCodG))
		While !DBL->(Eof()) .And. DBL->DBL_FILIAL == xFilial("DBL") .And. DBL->DBL_GRUPO == cCodG  
			If !SAL->(DbSeek(xFilial("SAL") + cCodG))
				Reclock("DBL",.F.)
				DBL->(DbDelete())
				DBL->(MsUnLock())
			EndIf
			DBL->(DbSkip())
		End
	EndIf
EndIf

lDesIniPad := .F.

// Ajusta alçadas pendentes no aumento do tamanho do campo DBL_ITEM
If lRet .And. lAjItemDBL .And. nTItemAnt > 0
	// Atualiza campo CR_ITGRP
	cQuery := "UPDATE "+RetSqlName('SCR')
	cQuery += " SET CR_ITGRP = '"+Replicate('0',nTDBLItem-nTItemAnt)+"'"+Iif(lMSSQL,'+','||')+"CR_ITGRP"
	cQuery += " WHERE CR_FILIAL = '"+xFilial('SCR')+"' AND CR_GRUPO = '"+cCodG+"' AND "
	cQuery += Iif(lMSSQL,"LEN","LENGTH")+"(RTRIM(CR_ITGRP))="+cValToChar(nTItemAnt)+" AND D_E_L_E_T_ = ' '"
	TcSqlExec(cQuery)

	// Atualiza campo DBM_ITGRP
	cQuery := "UPDATE "+RetSqlName('DBM')
	cQuery += " SET DBM_ITGRP = '"+Replicate('0',nTDBLItem-nTItemAnt)+"'"+Iif(lMSSQL,'+','||')+"DBM_ITGRP"
	cQuery += " WHERE DBM_FILIAL = '"+xFilial("DBM")+"' AND DBM_GRUPO = '"+cCodG+"' AND "
	cQuery += Iif(lMSSQL,"LEN","LENGTH")+"(RTRIM(DBM_ITGRP))="+cValToChar(nTItemAnt)+" AND D_E_L_E_T_ = ' '"
	TcSqlExec(cQuery)
	
	lAjItemDBL := .F.
Endif

//Telemetria - Média de aprovadores por grupo de aprovação.
If oModel:GetOperation() == MODEL_OPERATION_INSERT .Or. oModel:GetOperation()== MODEL_OPERATION_UPDATE
	SAL->(DbSetOrder(1)) //AL_FILIAL+AL_COD+AL_ITEM
	If SAL->(DbSeek(xFilial("SAL") + cCodG))
		While !SAL->(Eof()) .And. SAL->AL_FILIAL == xFilial("SAL") .And. SAL->AL_COD == cCodG
			nQtdAprov++
			SAL->(DbSkip())
		Enddo
	EndIf

	If nQtdAprov > 0
		ComMetric(nQtdAprov)
	Endif
Endif

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} A114Cancel
Ações no Cancel
@author Willian.Alves
@since 11/12/2018
@version 12.1.17
@return lRet 
/*/
//-------------------------------------------------------------------
Function A114Cancel(oModel)
Local lRet := .T.
lDesIniPad := .F.

FwformCancel(oModel)
lAjItemDBL := .F. //Restaura a variavel para que o código do item seja ajustado ao clicar no botão cancelar

Return lRet


//-------------------------------------------------------------------
/*{Protheus.doc} A114DESCR
Inicializador padrão para os campos descrição

@author Lucas.Crevilari
@since 26/07/2017
@version P12.1.16
@return cRet
*/
//-------------------------------------------------------------------
Function A114DESCR(nOpc)  

Local cModel	:= FWModelActive()
Local cRet		:= ""

If nOpc == 1
	cRet := If(cModel:GetOperation()==MODEL_OPERATION_INSERT,'',If(lDesIniPad,'',Posicione('SAK',2,xFilial('SAK')+AL_USER,'AK_NOME')))
Else
	cRet := If(cModel:GetOperation()==MODEL_OPERATION_INSERT,'',If(lDesIniPad,'',Posicione('DHL',1,xFilial('DHL')+AL_PERFIL,'DHL_DESCRI')))
EndIf

Return cRet

//-------------------------------------------------------------------
/*{Protheus.doc} ExistUsr
Validação superior

@author Rodrigo Pontes
@since 26/07/2017
@version P12.1.17
@return lRet
*/
//-------------------------------------------------------------------

Function ExistUsr(cUsuario)

Local lRet		:= .T.
Local oModel	:= FWModelActive()
Local oModelIt	:= oModel:GetModel('DetailSAL')


If !ExistCpo('SAK',cUsuario,2)
	lRet := .F.
Endif

If lRet
	If !Empty(oModelIt:GetValue("AL_USER"))
		If oModelIt:GetValue("AL_USER") == cUsuario
			Help(" ",1,"A114SuPDif",,STR0018,1,4)
			lRet := .F.
		EndIf
	EndIf
Endif


Return lRet

// Pre valid do 6o parametro
Static Function A114Pre6(nLine,cAction,cCampo,xValue,xOldValue,oModelGrid)

Local lRet			:= .T.

If cAction == "ADDLINE"
	lDesIniPad := .T.	// Desabilita inicializador padrao para os campos de descricao da SAL
EndIf

Return lRet

/*/{Protheus.doc} LoadUsrCpo
	Preenche as variaveis estaticas <cCabCampos>,<cUsrCampos> e <cUsrCpoGrid>
@author PHILIPE.POMPEU
@since 15/05/2019
@return Nil, nulo
/*/
Static Function LoadUsrCpo()
	If(Empty(cCabCampos))		
		cCabCampos := "AL_COD|AL_DESC|AL_DOCAE|AL_DOCCP|AL_DOCMD|AL_DOCNF|AL_DOCPC|AL_DOCIP|AL_DOCSA|AL_DOCSC|AL_DOCST|AL_DOCCT|AL_DOCGA"
		If SAL->(FieldPos("AL_AGRCNNG")) > 0
			cCabCampos += "|AL_AGRCNNG"
		Endif
		If lUsrCampos
			cUsrCampos := ExecBlock("MT114CAB",.F.,.F.)
			If ValType(cUsrCampos) == "C" .And. !Empty(cUsrCampos)
				cCabCampos += cUsrCampos
			EndIf
		EndIf
	EndIf
	
	If Empty(cUsrCpoGrid) .And. lUsrCpoGrid
		cUsrCpoGrid := ExecBlock("MT114GRID",.F.,.F.)
	EndIf	
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} A114LINOK(oModelGrid)
 Pôs-validação de linha - Linha Ok.

@author Junior.Mauricio
@since 28/09/2020
@return lRet
/*/
//-------------------------------------------------------------------

Static Function A114LinOK(oModelGrid)

Local lRet 			:= .T.
Local nOperation 	:= oModelGrid:GetOperation()
Local cAprov		:= oModelGrid:GetValue("AL_APROV")
Local cItem			:= oModelGrid:GetValue("AL_ITEM")
Local aAreaAnt		:= GetArea()
Local aAreaSAL		:= SAL->(GetArea())


SAL->(dbSetOrder(1))
SAL->(MsSeek(xFilial("SAL")+SAL->AL_COD+cItem ))
//Valida se o aprovador anterior possui alguma pendência 
If nOperation == 4 .And. cAprov <> SAL->AL_APROV 
	lRet := VldPendSCR(4,,SAL->AL_APROV)
EndIf

RestArea(aAreaSAL)
RestArea(aAreaAnt)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} ChangeLine(oView)
 Função executada na troca de linha da tabela DBL (DetailDBL)

@author rd.santos
@since 13/05/2021
@return lRet
/*/
//-------------------------------------------------------------------

Static Function ChangeLine(oView)
Local lRet 		:= .T.
Local oModel	:= FWModelActive()
Local oModelDBL	:= oModel:GetModel("DetailDBL")
Local oModelSAL	:= oModel:GetModel("ModelSAL")
Local cItem		:= oModelDBL:GetValue("DBL_ITEM")
Local cGrupo	:= oModelSAL:GetValue("AL_COD")
Local nLines	:= oModelDBL:Length()
Local cItemAnt	:= ""
Local cItemNew	:= ""
Local nOperation:= oView:GetOperation()
Local nProxIt	:= 0
Local nX		:= 0

// Ajusta numeração no aumento do campo DBL_ITEM
If !lAjItemDBL .And. nOperation == 4 ; // Verifica se já fez o ajuste
.And. Val(cItem) > nLines // Verifica se há necessidade de ajuste
	cItemAnt := RTrim(RetLastIt(cGrupo))
	
	// Verifica se o ultimo item cadastrado tem menos caracteres
	If !Empty(cItemAnt) .And. Len(cItemAnt) < Len(cItem) 
		nProxIt	 := Val(cItemAnt)+1
		cItemNew := STrZero(nProxIt,Len(cItem))
		oModelDBL:LoadValue('DBL_ITEM'  , cItemNew )

		// Posiciona em cada Linha da Grid para ajustar a numeração dos itens
		For nX := 1 To nLines
			oModelDBL:GoLine(nX)
			cItemNew := RTrim(oModelDBL:GetValue('DBL_ITEM'))
			If Len(cItemNew) < Len(cItem)
				cItemNew := Replicate('0',Len(cItem)-Len(cItemNew))+cItemNew
				oModelDBL:LoadValue('DBL_ITEM',cItemNew)
			Endif
		Next nX 

		lAjItemDBL 	:= .T. // Para fazer o Reset uma única vez
		nTItemAnt	:= Len(cItemAnt)

		oView:Refresh() // Atualiza View para mostrar o Reset
	Endif
	
Endif

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} RetLastIt(oModelGrid)
 Retorna o último item de entidade contábil do Grupo de Aprovação

@author rd.santos
@since 14/05/2021
@return lRet
/*/
//-------------------------------------------------------------------
Static Function RetLastIt(cGrupo)
Local cItem 	:= ""
Local cAliasDBL	:= GetNextAlias()

BeginSql Alias cAliasDBL

	SELECT MAX(DBL_ITEM) AS ITEM
	FROM
		%table:DBL% DBL
	WHERE
		DBL.DBL_FILIAL = %xFilial:DBL% AND
		DBL.DBL_GRUPO = %Exp:cGrupo% AND
		DBL.%notDel%		
EndSql

If ValType((cAliasDBL)->ITEM) == 'C'
	cItem := (cAliasDBL)->ITEM
Endif

(cAliasDBL)->(dbCloseArea())

Return cItem

/*/{Protheus.doc} ComMetric
	Média de aprovadores por grupo de aprovação utilizados via <FWCustomMetrics>
@author rodrigo.mpontes
@since 25/10/2021
@return Nil, indefinido
/*/
Static Function ComMetric(nQtdAprov)
Local cIdMetric		:= "compras-protheus_media-de-aprovadores-por-grupo_average"
Local cRotina		:= "mata114"
Local cSubRoutine	:= cRotina+"-media-aprovadores"
Local lContinua		:= (FWLibVersion() >= "20210517") .And. FindClass('FWCustomMetrics')

If lContinua
	FWCustomMetrics():setAverageMetric(cSubRoutine, cIdMetric, nQtdAprov,/*dDateSend*/, /*nLapTime*/,cRotina)
Endif

Return
