#INCLUDE 'PROTHEUS.CH'
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "MATA103C.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} MATA103C()
Consolidação NF x XML

@author Leandro Fini
@since 18/07/2022
@version 1.0
/*/
//-------------------------------------------------------------------
Function MATA103C()
Local oBrowse	:= Nil    

	
oBrowse := FWMBrowse():New()
oBrowse:SetAlias('DKA')
oBrowse:SetDescription(STR0001)//"NF x XML"

oBrowse:Activate()    
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef()
Menu Funcional da Rotina 

@author Leandro Fini
@since 18/07/2022
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()   

Local aRotina := {}

ADD OPTION aRotina Title STR0002			Action 'VIEWDEF.MATA103C' OPERATION 2 ACCESS 0//Visualizar
ADD OPTION aRotina Title STR0003   			Action 'VIEWDEF.MATA103C' OPERATION 8 ACCESS 0//Imprimir


Return(aRotina) 

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef()
Estrutura do Modelo de Dados

@author Leandro Fini
@since 18/07/2022
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef() 

Local oStrCab   := FWFormStruct( 1, 'DKA' ,{|cCampo| AllTrim(cCampo)$ "DKA_FILIAL|DKA_DOC|DKA_SERIE|DKA_FORNEC|DKA_LOJA|DKA_XNOMFO"} )
Local oStrDKA   := FWFormStruct( 1, 'DKA' )
Local oStrDKB   := FWFormStruct( 1, 'DKB' )
Local oStrDKC   := FWFormStruct( 1, 'DKC' )
Local bPreVlDKA	:= {|oModelGrid,nLine,cAction,cField,xValue,xOldValue| A103LPrVld(oModelGrid,nLine,cAction,cField,xValue,xOldValue)}
Local oModel 	 := Nil  

oStrCab:AddField(	STR0004,;								// 	[01]  C   Titulo do campo //"Nome Fornecedor"
					STR0005,;								// 	[02]  C   ToolTip do campo //Nome For.
					 "DKA_XNOMFO",;								// 	[03]  C   Id do Field
					 "C",;										// 	[04]  C   Tipo do campo
					 TamSX3("A2_NOME")[1],;					// 	[05]  N   Tamanho do campo
					 0,;										// 	[06]  N   Decimal do campo
					 NIL,;										// 	[07]  B   Code-block de validação do campo
					 NIL,;										// 	[08]  B   Code-block de validação When do campo
					 NIL,;										//	[09]  A   Lista de valores permitido do campo
					 .F.,;										//	[10]  L   Indica se o campo tem preenchimento obrigatório
					 {|| iniCampo() },;									//	[11]  B   Code-block de inicializacao do campo
					 NIL,;										//	[12]  L   Indica se trata-se de um campo chave
					 .T.,;										//	[13]  L   Indica se o campo pode receber valor em uma operação de update.
					 .T.)										// 	[14]  L   Indica se o campo é virtual

oModel := MPFormModel():New('MATA103C',/*bPreVld*/, {|oModel| A103CPosVld()}/*bPosVld*/,{|oModel| A103CCommit(oModel)} ) 

oModel:AddFields( 'DKAMASTER', /*cOwner*/ , oStrCab)
oModel:AddGrid('DKADETAIL','DKAMASTER',oStrDKA,bPreVlDKA, /*bPosVld*/)
oModel:SetRelation('DKADETAIL',{{'DKA_FILIAL','fwxFilial("DKA")'},{'DKA_DOC','DKA_DOC'},{'DKA_SERIE','DKA_SERIE'},{'DKA_FORNEC','DKA_FORNEC'},{'DKA_LOJA','DKA_LOJA'}},DKA->(IndexKey(1)))

oModel:AddGrid  ( 'DKBDETAIL', 'DKADETAIL', oStrDKB,,,,, )		
oModel:SetRelation('DKBDETAIL', { { 'DKB_FILIAL', 'fwxFilial("DKA")' }, { 'DKB_DOC', 'DKA_DOC' }, { 'DKB_SERIE', 'DKA_SERIE' },{ 'DKB_FORNEC', 'DKA_FORNEC' },{ 'DKB_LOJA', 'DKA_LOJA' },{ 'DKB_ITXML', 'DKA_ITXML' } },  DKB->(IndexKey(1)) )

oModel:AddGrid  ( 'DKCDETAIL', 'DKADETAIL', oStrDKC,,,,, )		
oModel:SetRelation('DKCDETAIL', { { 'DKC_FILIAL', 'fwxFilial("DKA")' }, { 'DKC_DOC', 'DKA_DOC' }, { 'DKC_SERIE', 'DKA_SERIE' },{ 'DKC_FORNEC', 'DKA_FORNEC' },{ 'DKC_LOJA', 'DKA_LOJA' },{ 'DKC_ITXML', 'DKA_ITXML' } },  DKC->(IndexKey(1)) )

oModel:SetPrimaryKey({ 'DKA_FILIAL', 'DKA_DOC', 'DKA_SERIE', 'DKA_FORNEC', 'DKA_LOJA', 'DKA_ITXML' })

oModel:GetModel('DKBDETAIL'):SetOptional(.T.)
oModel:GetModel('DKCDETAIL'):SetOptional(.T.) 

oStrDKA:SetProperty( "*", MODEL_FIELD_OBRIGAT, .F. )
oStrDKC:SetProperty( "*", MODEL_FIELD_OBRIGAT, .F. )

oModel:SetDescription( STR0001 ) //NFE x XML' 
oModel:GetModel( 'DKAMASTER' ):SetDescription( STR0006 )//"Documento"

oStrDKA:AddTrigger('DKA_UMXML', 'DKA_FATOR', {|| .T.},{||getFator(FWFldGet("DKA_PRODUT"), FWFldGet("DKA_UMXML"))})	// Trigger

oModel:SetVldActivate( {|| .T. } )

Return oModel


//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef()
Estrutura de Visualização

@author Leandro Fini
@since 18/07/2022
@version 1.0
/*/
//-------------------------------------------------------------------

Static Function ViewDef() 

Local oModel 	:= FWLoadModel('MATA103C')
Local oStrCab 	:= FWFormStruct( 2, 'DKA', {|cCampo| AllTrim(cCampo)$ "DKA_DOC|DKA_SERIE|DKA_FORNEC|DKA_LOJA|DKA_XNOMFO"} )  
Local oStrDKA 	:= FWFormStruct( 2, 'DKA' , {|cCampo| !AllTrim(cCampo)$ "DKA_FILIAL|DKA_DOC|DKA_SERIE|DKA_FORNEC|DKA_LOJA|DKA_ITEMNF"} )
Local oStrDKB 	:= FWFormStruct( 2, 'DKB' , {|cCampo| !AllTrim(cCampo)$ "DKB_FILIAL|DKB_DOC|DKB_SERIE|DKB_FORNEC|DKB_LOJA|DKB_ITXML"} )
Local oStrDKC 	:= FWFormStruct( 2, 'DKC', {|cCampo| !AllTrim(cCampo)$ "DKC_DOC|DKC_SERIE|DKC_FORNEC|DKC_LOJA|DKC_ITXML|DKC_FILIAL"} )

Private oView := Nil

oStrCab:AddField( ;									// Ord. Tipo Desc.
						"DKA_XNOMFO",;					// [01] C Nome do Campo
						"4",;							// [02] C Ordem
						STR0004,;						// [03] C Titulo do campo # "Local" //"Nome Fornecedor"
						STR0005,;						// [04] C Descrição do campo # "Local" //"Nome For."
						Nil,;							// [05] A Array com Help
						"C",;							// [06] C Tipo do campo
						"@!",;							// [07] C Picture
						NIL,;							// [08] B Bloco de Picture Var
						"",;							// [09] C Consulta F3
						.T.,;							// [10] L Indica se o campo é editável
						NIL,;							// [11] C Pasta do campo
						NIL,;							// [12] C Agrupamento do campo
						NIL,;							// [13] A Lista de valores permitido do campo (Combo)
						NIL,;							// [14] N Tamanho Maximo da maior opção do combo
						NIL,;							// [15] C Inicializador de Browse
						.T.,;							// [16] L Indica se o campo é virtual
						NIL )							// [17] C Picture Variável


oStrDKA:SetProperty( "DKA_UMXML", MVC_VIEW_LOOKUP,"D3Q" )

oView:= FWFormView():New() 

oView:SetModel( oModel )

oView:AddField( 'VIEW_SF1' , oStrCab, 'DKAMASTER' )
oView:AddGrid ( 'VIEW_DKA' , oStrDKA, 'DKADETAIL' )
oView:AddGrid ( 'VIEW_DKB' , oStrDKB, 'DKBDETAIL' )
oView:AddGrid ( 'VIEW_DKC' , oStrDKC, 'DKCDETAIL' )

oView:CreateHorizontalBox	( 'SUPERIOR'   , 015 )
oView:CreateHorizontalBox	( 'INFERIOR1'  , 035 )
oView:CreateHorizontalBox	( 'INFERIOR2'  , 025 )   
oView:CreateHorizontalBox	( 'INFERIOR3'  , 025 )

oView:SetOwnerView( 'VIEW_SF1', 'SUPERIOR'	)
oView:SetOwnerView( 'VIEW_DKA', 'INFERIOR1'	)
oView:SetOwnerView( 'VIEW_DKB', 'INFERIOR2'	) 
oView:SetOwnerView( 'VIEW_DKC', 'INFERIOR3'	)  

oView:EnableTitleView('VIEW_DKA', STR0007	)//'Consolidação Itens XML'
oView:EnableTitleView('VIEW_DKB', STR0008	)//'Impostos x Itens'
oView:EnableTitleView('VIEW_DKC', STR0009	)//'Itens da NF'

Return oView

/*/{Protheus.doc} A103CCommit
	Bloco de commit do modelo
@author Leandro Fini
@since 10/08/2022
/*/
Static Function A103CCommit(oModel)

Local lRet := .T.

if ( FwIsInCallStack("MATA103") .Or. FwIsInCallStack("MATA910") ) .and. type("lGrvCSD") == "L" .and. lGrvCSD
    FWFormCommit( oModel )
elseif ( !FwIsInCallStack("MATA103") .And. !FwIsInCallStack("MATA910") ) .or. oModel:GetOperation() == 5 //Exclusão
    FWFormCommit( oModel )
endif

Return lRet

/*/{Protheus.doc} A103CPosVld
	Pós validação geral do modelo.
    @lGrvCSD = Controle de gravação
    .T. -> Confirmação de dados para commit
    .F. -> Criação de tela para edição do usuário.
@author Leandro Fini
@since 10/08/2022
/*/
Static Function A103CPosVld()

Local oModel := FwModelActive()
Local oModelCab
Local oMdlItXML
Local oMdlImp 
Local oMdlItNF
Local oStruct
Local aCampos := {}
Local oStrImp
Local aCpoImp := {}
Local oStrDKC
Local aCpoItNF := {}
Local nCol    := 1
Local nX      := 1
Local nY      := 1
Local nI      := 1

if(oMdlCSDGRV <> nil) .and. type("lGrvCSD") == "L" .and. lGrvCSD
    if oMdlCSDGRV:IsActive()
        oMdlCSDGRV:DeActivate()
    endif
    oMdlCSDGRV:Destroy() 
    oMdlCSDGRV := nil
endif

if ( FwIsInCallStack("MATA103") .Or. FwIsInCallStack("MATA910") ) .and. type("lGrvCSD") == "L" .and. lGrvCSD
    oMdlCSDGRV := FWLoadModel( "MATA103C" )
	oMdlCSDGRV:SetOperation( MODEL_OPERATION_INSERT ) 
	oMdlCSDGRV:Activate()
    lGrvCSD := .F. //Controle de gravação para não realizar o commit em seguida.

    oModelCab := oModel:GetModel("DKAMASTER")//Cabeçalho
    oMdlItXML := oModel:GetModel("DKADETAIL")//Itens de consolidação XML
    oMdlImp   := oModel:GetModel("DKBDETAIL")//Impostos
    oMdlItNF   := oModel:GetModel("DKCDETAIL")//Itens dos pedidos

    oStruct    := oModelCab:GetStruct()
    aCampos    := oStruct:GetFields()

    For nCol := 1 To Len(aCampos)   
        oMdlCSDGRV:LoadValue("DKAMASTER", aCampos[nCol][3], oModelCab:GetValue(aCampos[nCol][3]))
    Next nCol

    oStruct    := oMdlItXML:GetStruct()
    aCampos    := oStruct:GetFields()

    oStrDKC    := oMdlItNF:GetStruct()
    aCpoItNF    := oStrDKC:GetFields()

    oStrImp    := oMdlImp:GetStruct()
    aCpoImp    := oStrImp:GetFields()

    for nX := 1 to oMdlItXML:Length()
        oMdlItXML:SetLine(nX)
        if nX > 1
            oMdlCSDGRV:GetModel("DKADETAIL"):AddLine()
        endif
        For nCol := 1 To Len(aCampos)
            oMdlCSDGRV:LoadValue("DKADETAIL", aCampos[nCol][3], oMdlItXML:GetValue(aCampos[nCol][3]))
        Next nCol

        for nI := 1 to oMdlImp:Length()
            oMdlImp:SetLine(nI)
            if nI > 1
                oMdlCSDGRV:GetModel("DKBDETAIL"):AddLine()
            endif
            For nCol := 1 To Len(aCpoImp)
                oMdlCSDGRV:LoadValue("DKBDETAIL", aCpoImp[nCol][3], oMdlImp:GetValue(aCpoImp[nCol][3]))
            Next nCol
        next nI

        for nY := 1 to oMdlItNF:Length()
            oMdlItNF:SetLine(nY)
            if nY > 1
                oMdlCSDGRV:GetModel("DKCDETAIL"):AddLine()
            endif
            For nCol := 1 To Len(aCpoItNF)
                oMdlCSDGRV:LoadValue("DKCDETAIL", aCpoItNF[nCol][3], oMdlItNF:GetValue(aCpoItNF[nCol][3]))
            Next nCol
        next nY

    next nX

endif

Return .T.

/*/{Protheus.doc} A103LPrVld
	Pré validação da linha do modelo da DKA(Itens XML)

	@oModelDKA = Modelo ativo
	@nLine  = Linha alterada
	@cAction = Ação efetuada no modelo
    @cField = Campo alterado
    @xValue = Valor inserido
    @xOldValue = Valor antes da alteração
@author Leandro Fini
@since 10/08/2022
/*/
Static Function A103LPrVld(oModelDKA,nLine,cAction,cField,xValue,xOldValue)

Local lRet     := .T.
Local nQtdConv := 0
Local cProd    := ""
Local cUnCom   := ""
Local cUnSB1   := ""
Local nQtdSD1  := 0
Local nQtdXML  := 0

DbSelectArea("D3Q")
D3Q->(DbSetOrder(1))//D3Q_FILIAL + D3Q_PROD + D3Q_UNICOM 

if cField == "DKA_QTDXML" .and. cAction == "SETVALUE"

    cProd       := oModelDKA:GetValue("DKA_PRODUT")
    cUnCom      := oModelDKA:GetValue("DKA_UMXML")
    cUnSB1      := oModelDKA:GetValue("DKA_UM")
    nQtdSD1     := oModelDKA:GetValue("DKA_QUANT")
    nQtdXML     := xValue
    nQtdConv    := nQtdXML

    if cUnSB1 <> cUnCom
        nQtdConv := EstConvUM(cProd,cUnCom,nQtdXML)
    endif

    if nQtdConv > 0
        if nQtdConv <> nQtdSD1
            lRet := .F.
            //"A quantidade total da NF(D1_QUANT) não bate com a quantidade convertida do item XML(DKA_QTDXML)."
            Help(" ",1,"A103LPrVld",,STR0010,1,0)
        endif
    endif
elseif cField == "DKA_UMXML" .and. cAction == "SETVALUE"

    cProd       := oModelDKA:GetValue("DKA_PRODUT")
    cUnCom      := fwfldget("DKA_UMXML")

    if !empty(cUnCom)
        if !D3Q->(MsSeek(fwxFilial("D3Q") + cProd + cUnCom))
            lRet := .F.
            Help(" ",1,"CSDCONV",,"A unidade selecionada não pertence a este produto.",1,0)
        endif
    endif

endif 

Return lRet 

/*/{Protheus.doc} A103CPosDKA
	Pós validação da linha do modelo da DKA(Itens XML)

	@oModelDKA = Modelo ativo
@author Leandro Fini
@since 08/09/2022
/*/
Function A103CPosDKA(oModelDKA)

Local lRet    := .T.
Local nX      := 1
Local nQtdLin := oModelDKA:Length()

for nX := 1 to nQtdLin

    oModelDKA:GoLine(nX)

    if oModelDKA:GetValue("DKA_QTDXML") <= 0
        lRet := .F.
    elseif oModelDKA:GetValue("DKA_FATOR") == 0
        lRet := .F.
    elseif empty(oModelDKA:GetValue("DKA_UMXML"))
        lRet := .F.
    endif

next nX

oModelDKA:GoLine(1)

Return lRet

/*/{Protheus.doc} iniCampo
	Inicializa campo virtual do nome do fornecedor.
@author Leandro Fini
@since 10/08/2022
/*/
Static Function iniCampo()

Local xRet := ""

if FwIsInCallStack("MATA103") .Or. FwIsInCallStack("MATA910")
    xRet := GetAdvFVal("SA2","A2_NOME",fwxFilial("SA2") + cA100For + cLoja ,1)
else 
    xRet := GetAdvFVal("SA2","A2_NOME",fwxFilial("SA2") + DKA->(DKA_FORNEC + DKA_LOJA) ,1)
endif

Return xRet

/*/{Protheus.doc} iniCampo
	Realiza um gatilho no preenchimento do campo DKA_UMXML
    Buscando o fator de conversão na D3Q para preencher DKA_FATOR.
@author Leandro Fini
@since 04/10/2022
/*/
Static Function getFator(cProd, cUMXml)

Local nRet := 0

Default cProd  := ""
Default cUMXml := ""

nRet := GetAdvFVal("D3Q","D3Q_FATOR",fwxFilial("D3Q") + cProd + cUMXml ,1)

Return nRet

/*/{Protheus.doc} A103CSDQTD
	Retorna quantidade informada no QTDXML

@author rodrigo.mpontes
@since 04/10/2022
/*/

Function A103CSDQTD(cForn,cLoj,cNF,cSer,cPrd,cItXML)

Local nQtdXML   := 0
Local oQtdXML   := Nil
Local cQryStat  := ""
Local cAliTmp   := GetNextAlias()
    
oQtdXML := FWPreparedStatement():New()  

cQry := " SELECT SUM(DT_QTDXML) DT_QTDXML FROM " + RetSqlName("SDT")
cQry += " WHERE D_E_L_E_T_ = ' '" 
cQry += " AND DT_FILIAL = ?"
cQry += " AND DT_DOC = ?"
cQry += " AND DT_SERIE = ?"
cQry += " AND DT_FORNEC = ?"
cQry += " AND DT_LOJA = ?"
cQry += " AND DT_COD = ?"
cQry += " AND DT_ITXML = ?"
cQry := ChangeQuery(cQry)

oQtdXML:SetQuery(cQry)
oQtdXML:SetString(1,xFilial("SDT"))
oQtdXML:SetString(2,cNF)
oQtdXML:SetString(3,cSer)
oQtdXML:SetString(4,cForn)
oQtdXML:SetString(5,cLoj)
oQtdXML:SetString(6,cPrd)
oQtdXML:SetString(7,cItXML)

cQryStat := oQtdXML:GetFixQuery()
MpSysOpenQuery(cQryStat,cAliTmp)

If (cAliTmp)->(!EOF())
    nQtdXML := (cAliTmp)->DT_QTDXML
Endif

(cAliTmp)->(DbCloseArea())
oQtdXML:Destroy()

Return nQtdXML
