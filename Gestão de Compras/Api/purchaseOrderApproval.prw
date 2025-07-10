#Include "totvs.ch"
#Include "topconn.ch"
#Include "restful.ch"

static __oWSPurchaseOrder := FWHashMap():New()
static __cPOMoreFields := NIL

#DEFINE OP_LIB	"001" // Liberado
#DEFINE OP_REJ	"005" // Rejeitado

//-------------------------------------------------------------------
/*/{Protheus.doc} purchaseOrderApproval
API para retornar os dados relacionados ao processo de aprovação 
de pedido de compra para o cenário de aprovação 
via aplicativo Meu Protheus.

@author TOTVS
@since 13/08/2020 
/*/
//-------------------------------------------------------------------
WSRESTFUL purchaseOrderApproval DESCRIPTION "Aprovação de pedido de compras." FORMAT APPLICATION_JSON

    WSDATA page			            AS INTEGER OPTIONAL 
    WSDATA pageSize		            AS INTEGER OPTIONAL
    WSDATA status		            AS STRING OPTIONAL
    WSDATA purchaseOrderNumber		AS STRING OPTIONAL
    WSDATA purchaseOrderItem		AS STRING OPTIONAL
    WSDATA objectCode       		AS STRING OPTIONAL
    WSDATA approverCode		        AS STRING OPTIONAL
    WSDATA productCode              AS STRING OPTIONAL
    WSDATA isapproved               AS BOOLEAN OPTIONAL
    WSDATA purchaseOrderBranch      AS STRING OPTIONAL
    WSDATA purchaseOrderMessage     AS STRING OPTIONAL
    WSDATA itemGroup                AS STRING OPTIONAL
    WSDATA searchKey                AS STRING OPTIONAL
    WSDATA cInitDate                AS STRING OPTIONAL
    WSDATA cEndDate                 AS STRING OPTIONAL
    
    WSMETHOD PUT ApprovalOrderPC ;
        DESCRIPTION "Realiza a aprovação do documento" ;
        PATH "api/com/purchaseorderapproval/v1/approvalorderpc"  ;
        TTALK "v1" ;
        WSSYNTAX "api/com/purchaseorderapproval/v1/approvalorderpc" ;
        PRODUCES APPLICATION_JSON

    WSMETHOD GET isUserApprover ;
        DESCRIPTION "Verifica se o usuário é um aprovador no cenário de pedido de compras." ;
        PATH "api/com/purchaseorderapproval/v1/isuserapprover"  ;
        TTALK "v1" ;
        WSSYNTAX "api/com/purchaseorderapproval/v1/isuserapprover" ;
        PRODUCES APPLICATION_JSON

    WSMETHOD GET purchaseOrderList ;
        DESCRIPTION "Retorna a lista de pedidos de compra aguardando aprovação do usuário." ;
        PATH "api/com/purchaseorderapproval/v1/purchaseorderlist"  ;
        TTALK "v1" ;
        WSSYNTAX "api/com/purchaseorderapproval/v1/purchaseorderlist" ;
        PRODUCES APPLICATION_JSON
    
    WSMETHOD GET itemListPurchaseOrder ;
        DESCRIPTION "Retorna a lista de itens de um pedido de compra." ;
        PATH "api/com/purchaseorderapproval/v1/itemlistpurchaseorder"  ;
        TTALK "v1" ;
        WSSYNTAX "api/com/purchaseorderapproval/v1/itemlistpurchaseorder" ;
        PRODUCES APPLICATION_JSON
    
    WSMETHOD GET itemAdditionalInformation ;
        DESCRIPTION "Retorna as informações adicionais para um item de um pedido de compra." ;
        PATH "api/com/purchaseorderapproval/v1/itemadditionalinformation"  ;
        TTALK "v1" ;
        WSSYNTAX "api/com/purchaseorderapproval/v1/itemadditionalinformation" ;
        PRODUCES APPLICATION_JSON

    WSMETHOD GET historyByItem ;
        DESCRIPTION "Retorna a lista com as últimas compras para o produto." ;
        PATH "api/com/purchaseorderapproval/v1/historybyitem"  ;
        TTALK "v1" ;
        WSSYNTAX "api/com/purchaseorderapproval/v1/historybyitem" ;
        PRODUCES APPLICATION_JSON

    WSMETHOD GET attachments ;
        DESCRIPTION "Retorna um anexo do pedido de compra." ;
        PATH "api/com/purchaseorderapproval/v1/attachments"  ;
        TTALK "v1" ;
        WSSYNTAX "api/com/purchaseorderapproval/v1/attachments" ;
        PRODUCES APPLICATION_JSON

    WSMETHOD GET listAttachments ;
        DESCRIPTION "Retorna a lista de anexos do item do pedido." ;
        PATH "api/com/purchaseorderapproval/v1/listAttachments"  ;
        TTALK "v1" ;
        WSSYNTAX "api/com/purchaseorderapproval/v1/listAattachments" ;
        PRODUCES APPLICATION_JSON

END WSRESTFUL

//-------------------------------------------------------------------
/*/{Protheus.doc} approvalorderpc
Método para aprovar pedido de compras (PC e/ou IP)

@author TOTVS
@since 13/08/2020
/*/
//-------------------------------------------------------------------
WSMETHOD PUT approvalorderpc WSSERVICE purchaseOrderApproval

    Local oResponse     := JsonObject():New()
    Local cJson         := ""
    Local cChave        := ""
    Local lRet          := .F.
    Local nRecno        := 0
    Local nTamC7Num     := TamSX3("C7_NUM")[1]
    Local cAprovCode    := __cUserId
    Local cMsgRet       := ""
    Local aSaldo        := {}
    Local nVlrSCR       := 0

    Local cBody	        := self:GetContent()
    Local oParams       := JsonObject():New()
    Local cIdOption     := ""

    oParams:FromJSON( cBody )

    If !Empty( oParams["keyOrder"] )
        nRecno := LoadRecnoPC(oParams["keyOrder"], cAprovCode, oParams["itemGroup"])
        
        If nRecno > 0
            If oParams["approved"] //Aprovação
                SCR->(DbGoto(nRecno))
                SAK->(MsSeek(fwxFilial("SAK")+SCR->CR_APROV))
                nVlrSCR := SCR->CR_TOTAL
                aSaldo := MaSalAlc(SCR->CR_APROV,dDataBase,.T.)
                if Len(aSaldo) == 3 .and. aSaldo[2] <> SCR->CR_MOEDA//Caso o limite do aprovador seja em moeda diferente do pedido. 
                    nVlrSCR := xMoeda(nVlrSCR,SCR->CR_MOEDA,aSaldo[2],SCR->CR_EMISSAO,TamSX3("C7_PRECO")[2],SCR->CR_TXMOEDA)
                endif
                if aSaldo[1] >= nVlrSCR .OR. LibVisto(SCR->CR_APROV, SCR->CR_GRUPO)
                    A097ProcLib(nRecno,2,nVlrSCR,,,DecodeUTF8(oParams["message"]),dDataBase) 
                    lRet      := .T.
                    cMsgRet   := "Pedido APROVADO com sucesso."
                    cIdOption := OP_LIB
                else 
                    lRet      := .F.
                    SetRestFault( 400, EncodeUTF8( "Aprovador não possui saldo suficiente para aprovação."), .T., 400, EncodeUTF8( "Aprovador não possui saldo suficiente para aprovação." )  )
                endif
            Elseif !oParams["approved"] //Rejeição
                SCR->(DbGoto(nRecno))
                cChave := xFilEnt(xFilial("SC7"),"SC7")+PadR(SCR->CR_NUM,nTamC7Num)
                MaAlcDoc({SCR->CR_NUM,SCR->CR_TIPO,,SCR->CR_APROV,,SCR->CR_GRUPO,,,,dDataBase, DecodeUTF8(oParams["message"])}, dDataBase ,7,,,SCR->CR_ITGRP,,,,cChave)
                lRet      := .T.
                cMsgRet   := "Pedido REPROVADO com sucesso."
                cIdOption := OP_REJ
            Endif

            If lRet
                oResponse["success"] := .T.
                oResponse["message"] := cMsgRet

                If ExistBlock("MT094END")
                    ExecBlock("MT094END",.F.,.F.,{SCR->CR_NUM,SCR->CR_TIPO,Val(Substr(cIdOption,3,1)),SCR->CR_FILIAL})
                EndIf
            Endif            

        Else
            SetRestFault( 400, EncodeUTF8( "Pedido não encontrado para aprovação"), .T., 400, EncodeUTF8( "Pedido não encontrado para aprovação" )  )
        Endif         

        cJson := FWJsonSerialize( oResponse, .F., .F., .T. )

        ::SetResponse( cJson )
    Else
        SetRestFault( 400, EncodeUTF8( "Pedido não encontrado para aprovação"), .T., 400, EncodeUTF8( "Pedido não informado para aprovação." )  )
    EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} isUserApprover
Método para retornar se um usuário é aprovador ou não.

@author TOTVS
@since 13/08/2020
/*/
//-------------------------------------------------------------------
WSMETHOD GET isUserApprover WSSERVICE purchaseOrderApproval

    Local oResponse := JsonObject():New()
    Local cJson     := ""
    Local lRet      := .T.

    dbSelectArea( "SAK" )
    dbSetOrder( 2 ) //AK_FILIAL + AK_USER

    If MsSeek( xFilial( "SAK" ) + __cUserId )

        oResponse[ "isUserApprover" ] := .T.   
        
        cJson := FWJsonSerialize( oResponse, .F., .F., .T. )

        ::SetResponse( cJson )

        lRet := .T.
    Else
        oResponse[ "isUserApprover" ] := .F.   
        cJson := FWJsonSerialize( oResponse, .F., .F., .T. )
        ::SetResponse( cJson )
    EndIf

Return lRet  


//------------------------------------------------------------------------------------------------
/*/{Protheus.doc} purchaseOrderList
Método para retornar a lista de pedidos de compra aguardando a análise do usuário logado.

@param page, number, número da página para retorno
@param pageSize, number, número de registros por página
@param status, caracter, status da aprovação

@return Json, informações do pedido de compras
    - Nome do Fornecedor;
    - Número do pedido;
    - Descrição da Condição de pagamento;
    - Comprador;
    - Valor total;
    - Filial;
    - Data do pedido;
    - Símbolo da moeda

@author TOTVS
@since 30/08/2020
/*/
//------------------------------------------------------------------------------------------------
WSMETHOD GET purchaseOrderList WSRECEIVE page, pageSize, status, searchKey, cInitDate, cEndDate, itemGroup  WSSERVICE purchaseOrderApproval
    Local oResponse     := JsonObject():New() 
    Local cOper         := "purchaseOrders"
    Local cJson         := ""
    Local lRet          := .F.

    Default Self:page        := 1
    Default Self:pageSize    := 10
    Default Self:status      := "02"
    Default Self:searchKey  := ""
    Default Self:cInitDate   := ""
    Default Self:cEndDate    := ""
    Default Self:itemGroup    := ""

    lRet := LoadOrderResult( @oResponse, @Self, cOper, self:searchKey, self:cInitDate, self:cEndDate, self:itemGroup )
    
    cJson := FWJsonSerialize( oResponse, .F., .F., .T. )

    ::SetResponse( cJson )
Return lRet 

//-------------------------------------------------------------------
/*/{Protheus.doc} itemListPurchaseOrder
Método para retornar a lista de itens do pedidos de compra aguardando 
a análise do usuário logado.

@author TOTVS
@since 30/08/2020

@return Json, informações dos itens do pedido de compras
    - Número do pedido;
    - Item do pedido
    - Centro de custo;
    - Quantidade;
    - Valor total;
    - Valor unitário;
    - Código do produto;
    - Descrição do protduto;
    - Unidade de medida do produto;
    - Símbolo da moeda
/*/
//-------------------------------------------------------------------
WSMETHOD GET itemListPurchaseOrder WSRECEIVE page, pageSize, purchaseOrderNumber, itemGroup WSSERVICE purchaseOrderApproval
    Local oResponse     := JsonObject():New()
    Local cOper         := "purchaseOrderItems"
    Local cJson         := ""
    Local lRet          := .F.

    Default Self:page        := 1
    Default Self:pageSize    := 10
    Default Self:purchaseOrderNumber  := ""

    iF !empty( Self:purchaseOrderNumber )
        lRet := LoadOrderResult( @oResponse, @Self, cOper,,,, self:itemGroup)
        
        cJson := FWJsonSerialize( oResponse, .F., .F., .T. )

        ::SetResponse( cJson )
    Else
        SetRestFault( 400, EncodeUTF8( "Número do pedido de compra não informado."), .T., 400, EncodeUTF8( "Pedido de compra não informado na consulta." ) )
    endif
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} itemAdditionalInformation
Método para retornar as informações adicionais de um item do PC.

@author TOTVS
@since 01/08/2020

/*/
//-------------------------------------------------------------------
WSMETHOD GET itemAdditionalInformation WSRECEIVE purchaseOrderNumber, purchaseOrderItem WSSERVICE purchaseOrderApproval
    Local oResponse     := JsonObject():New()
    Local aFields       := {}
    Local cJson         := ""
    Local cFields       := ""
    Local cField        := ""
    Local cType         := ""
    Local lRet          := .F.
    LOcal nRec          := 1

    Default Self:purchaseOrderNumber    := ""
    Default Self:purchaseOrderItem      := ""

    iF !empty( Self:purchaseOrderNumber ) .And. !empty( Self:purchaseOrderItem )
        dbSelectArea( "SAK" )
        dbSetOrder( 2 ) //AK_FILIAL + AK_USER

        If MsSeek( xFilial( "SAK" ) + __cUserId )
            cFields := GetMoreFields()
            aFields := StrToArray( cFields, ',' )
            
            oResponse[ "itemsAdditionalInformation" ] := {}
            oResponse[ "hasNext" ] := .F.

            dbSelectArea( "SC7" )
            dbSetOrder( 1 ) //C7_FILIAL+C7_NUM+C7_ITEM+C7_SEQUEN
            If SC7->( dbSeek( XFilial ( "SC7" ) + Self:purchaseOrderNumber + Self:purchaseOrderItem ) )
                For nRec := 1 To Len( aFields )
                    cField := aFields[ nRec ]
                    cType := FWSX3Util():GetFieldType( cField ) 
                    
                    oItem := JsonObject():New()
                    
                    oItem[ "label" ]  := FWX3Titulo( cField )
                    oItem[ "type" ]   := cType

                    If cType == "D"
                        oItem[ "data" ]   := DToS( &( "SC7->" + cField ) )
                    ElseIf cType == "M" .or. "C7_OBS" $ cField
                        oItem[ "data" ]   := EncodeUTF8(&( "SC7->" + cField ))
                    Else
                        oItem[ "data" ]   := &( "SC7->" + cField )
                    EndIf

                    Aadd(oResponse[ "itemsAdditionalInformation" ], oItem )
                Next
            EndIf

            cJson := FWJsonSerialize( oResponse, .F., .F., .T. )

            ::SetResponse( cJson )

            lRet := .T.
        Else
            SetRestFault( 400, EncodeUTF8( "Usuário não está cadastrado como aprovador." ), .T., 400, EncodeUTF8( "O seu usuário não está cadastrado com aprovador no ERP." ) )
        EndIf
    Else
        If Empty( Self:purchaseOrderNumber )
            SetRestFault( 400, EncodeUTF8( "Número do pedido de compra não informado."), .T., 400, EncodeUTF8( "Pedido de compra não informado na consulta." )  )
        elseif Empty( Self:purchaseOrderItem )
            SetRestFault( 400, EncodeUTF8( "Número do item não informado."), .T., 400, EncodeUTF8( "Item não informado na consulta." )  )
        else
            SetRestFault( 400, EncodeUTF8( "Informações necessárias para execução não foram fornecidas."), .T., 400, EncodeUTF8( "Informações necessárias não foram fornecidas." )  )
        EndIf    
    endif

    FreeObj( oItem )
    FWFreeArray( aFields )
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} purchaseOrderItemHistory
Método para retornar a lista de itens do pedidos de compra aguardando 
a análise do usuário logado.

@author TOTVS
@since 30/08/2020

@return Json, informações dos itens do pedido de compras
    - Número do pedido;
    - Item do pedido
    - Centro de custo;
    - Quantidade;
    - Valor total;
    - Valor unitário;
    - Código do produto;
    - Descrição do protduto;
    - Unidade de medida do produto;
    - Símbolo da moeda
/*/
//-------------------------------------------------------------------
WSMETHOD GET historyByItem WSRECEIVE page, pageSize, productCode WSSERVICE purchaseOrderApproval
    Local oResponse     := JsonObject():New()
    Local cOper         := "historyByItem"
    Local cJson         := ""
    Local lRet          := .F.

    Default Self:page        := 1
    Default Self:pageSize    := 10
    Default Self:productCode  := ""

    If !Empty( Self:productCode )
        lRet := LoadOrderResult( @oResponse, @Self, cOper )
        
        cJson := FWJsonSerialize( oResponse, .F., .F., .T. )

        ::SetResponse( cJson )
    Else
        SetRestFault( 400, EncodeUTF8( "Produto não informado."), .T., 400, EncodeUTF8( "Produto não informado na consulta." )  )
    EndIf
Return lRet

//----------------------------------------------------------------------------------
/*/{Protheus.doc} GetQuery
Função responsável por verificar no cache se a query já foi executada anteriormente.
Caso ainda não tenha sido executada, cria a query base de acordo com a operação que
está sendo executada.

@param cOper, caracter, Identifica qual a query será retornada

@return object, Objeto contendo a query a ser executada pelo REST.
@author Marcia Junko
@since 03/09/2020
/*/
//----------------------------------------------------------------------------------
Static Function GetQuery( cOper, searchKey, cInitDate, cEndDate, cItemGroup )
    
    Local oPrepare

    Default searchKey     := ''
    Default cInitDate   := '' 
    Default cEndDate    := ''
    Default cItemGroup    := ''

    //if !__oWSPurchaseOrder:containsKey( cOper )
        oPrepare := CreateQueryModel( cOper, searchKey, cInitDate, cEndDate, cItemGroup)
    //else
    //    oPrepare := __oWSPurchaseOrder:get( cOper )
    //endif
Return oPrepare

//----------------------------------------------------------------------------------
/*/{Protheus.doc} CreateQueryModel
Função responsável por criar a query base de acordo com a operação solicitada.
As querys devem ser montadas respeitando o conceito da função FWPreparedStatement().

IMPORTANTE: Ao utilizar o controle de paginação (<<PAGE_CONTROL>>) na query, ao 
        renomear a coluna é OBRIGATÓRIO o uso do identificador "AS" para que não 
        ocorra quebra ao efetuar o parsear. Exemplo: SUM(TOTAL) AS TOTAL

@param cOper, caracter, Identifica qual a query será montada

@return object, Objeto contendo a query base a ser executada pelo REST.
@author Marcia Junko
@since 03/09/2020
/*/
//----------------------------------------------------------------------------------
Static Function CreateQueryModel( cOper, searchKey, cInitDate, cEndDate, cItemGroup)
    Local oPrepare
    Local cQuery := ''
    Local cOrderBy := ''
    Local nTesSize := 0

    Default searchKey     := ''
    Default cInitDate   := '' 
    Default cEndDate    := ''
    Default cItemGroup    := ''
    
    Do Case
        Case cOper == 'purchaseOrders'
            cOrderBy := 'C7_NUM DESC'

            cQuery := "SELECT <<PAGE_CONTROL>>, A2_NREDUZ, C7_NUM, E4_DESCRI, Y1_NOME, SUM(CR_TOTAL) / COUNT(*) AS TOTAL, C7_FILIAL, C7_EMISSAO, C7_MOEDA, CR_ITGRP, CR_GRUPO, '' CCENTER "
            cQuery +=   " FROM " + RetSqlName( "SCR" ) + " SCR " 

            cQuery +=   " INNER JOIN " + RetSqlName( "SC7" ) + " SC7 ON C7_FILIAL = '" + XFilial( "SC7" ) + "' AND CR_NUM = C7_NUM AND SC7.D_E_L_E_T_ = ' ' "

            If !Empty(cInitDate) .AND. !Empty(cEndDate)
                cQuery +=   " AND C7_EMISSAO BETWEEN '" + AllTrim(cInitDate) + "' AND  '" + AllTrim(cEndDate) + "' "
            EndIf
            
            cQuery +=   " INNER JOIN " + RetSqlName( "SA2" ) + " SA2 ON A2_FILIAL = '" + XFilial( "SA2" ) + "' AND C7_FORNECE = A2_COD AND C7_LOJA = A2_LOJA AND SA2.D_E_L_E_T_ = ' '  "

            If !Empty(searchKey)
                cQuery +=   " AND (A2_NOME LIKE '%" + searchKey + "%' OR A2_NREDUZ LIKE '%" + searchKey + "%' OR A2_COD LIKE '%" + searchKey + "%' OR C7_NUM LIKE '%" + searchKey + "%' ) "
            EndIf

            cQuery +=   " INNER JOIN " + RetSqlName( "SE4" ) + " SE4 ON E4_FILIAL = '" + XFilial( "SE4" ) + "' AND E4_CODIGO = C7_COND AND SE4.D_E_L_E_T_ = ' ' "

            cQuery +=   " LEFT JOIN " + RetSqlName( "CTT" ) + " CTT ON CTT_FILIAL = '" + XFilial( "CTT" ) + "' AND C7_CC = CTT_CUSTO AND CTT.D_E_L_E_T_ = ' ' "
            cQuery +=   " LEFT JOIN " + RetSqlName( "SY1" ) + " SY1 ON Y1_FILIAL = '" + XFilial( "SY1" ) + "' AND C7_USER = Y1_USER AND SY1.D_E_L_E_T_ = ' ' "

            cQuery +=   " WHERE CR_FILIAL = '" + XFilial("SCR") + "' "
            cQuery +=     " AND CR_STATUS = ? "
            cQuery +=     " AND CR_TIPO IN ( 'PC', 'IP', 'AE' ) "
            cQuery +=     " AND CR_USER = ? "
            cQuery +=     " AND SCR.D_E_L_E_T_ = ' ' "
            cQuery +=   " GROUP BY A2_NREDUZ, C7_NUM, E4_DESCRI, Y1_NOME, C7_FILIAL, C7_EMISSAO, C7_MOEDA, CR_ITGRP, CR_GRUPO "  
        
        Case cOper == 'purchaseOrderItems'
            cOrderBy := 'C7_ITEM'

            cQuery := "SELECT <<PAGE_CONTROL>>, C7_NUM, C7_ITEM, C7_CC, C7_QUANT, C7_TOTAL, C7_PRECO, C7_PRODUTO, C7_UM, B1_DESC, C7_MOEDA, C7_DESCRI, CR_GRUPO, CR_ITGRP "
            cQuery +=   " FROM " + RetSqlName( "SC7" ) + " SC7 "
            cQuery +=   " INNER JOIN " + RetSqlName( "SCR" ) + " SCR ON CR_FILIAL = '" + XFilial("SCR") + "' AND CR_NUM = C7_NUM AND SCR.D_E_L_E_T_ = ' ' AND CR_ITGRP = ? AND CR_USER = ? "
            cQuery +=   " INNER JOIN " + RetSqlName( "SB1" ) + " SB1 ON B1_FILIAL = '" + XFilial( "SB1" ) + "' AND B1_COD = C7_PRODUTO AND SB1.D_E_L_E_T_ = ' ' "
            
            If !Empty(cItemGroup)
                cQuery +=   " INNER JOIN " + RetSqlName( "DBM" ) + " DBM ON DBM_FILIAL = '" + XFilial("DBM") + "' AND DBM_NUM = C7_NUM AND DBM_ITEM = C7_ITEM AND CR_ITGRP = DBM_ITGRP"
                cQuery +=   " AND CR_USER = DBM_USER AND DBM.D_E_L_E_T_ = ' ' "
            EndIf

            cQuery +=   " WHERE C7_FILIAL = '" + XFilial("SC7") + "' "
            cQuery +=     " AND C7_NUM = ? "
            cQuery +=     " AND SC7.D_E_L_E_T_ = ' ' "
            cQuery +=     " GROUP BY C7_NUM,C7_ITEM,C7_CC,C7_QUANT,C7_TOTAL ,C7_PRECO,C7_PRODUTO,C7_UM,B1_DESC,C7_MOEDA,C7_DESCRI,CR_GRUPO,CR_ITGRP "
        
        Case cOper == "historyByItem"
            nTesSize := TamSX3( 'D1_TES' )[1]
            cOrderBy := 'D1_EMISSAO DESC '
        
            cQuery := "SELECT <<PAGE_CONTROL>>, D1_EMISSAO, A2_NOME, D1_QUANT, D1_VUNIT "
            cQuery +=   " FROM " + RetSqlName( "SD1" ) + " SD1 "
            cQuery +=   " INNER JOIN " + RetSqlName( "SA2" ) + " SA2 ON A2_FILIAL = '" + XFilial( "SA2" ) + "' AND A2_COD = D1_FORNECE AND A2_LOJA = D1_LOJA AND SA2.D_E_L_E_T_ = ' ' "
            cQuery +=   " WHERE D1_FILIAL = '" + XFilial("SD1") + "' "
            cQuery +=     " AND D1_COD = ? "
            cQuery +=     " AND D1_TIPO NOT IN ('D', 'B') "
            cQuery +=     " AND D1_TES <> '" + Space( nTesSize ) + "' "
            cQuery +=     " AND SD1.D_E_L_E_T_ = ' ' "
        
    EndCase

    If !Empty( cQuery )
        cQuery := QueryPageControl( cQuery, cOrderBy )
        cQuery := ChangeQuery( cQuery )
        oPrepare := FWPreparedStatement():New( cQuery )
        __oWSPurchaseOrder:put( cOper, oPrepare )
    EndIf
Return oPrepare


//----------------------------------------------------------------------------------
/*/{Protheus.doc} QueryPageControl
Função responsável por atribuir o tratamento de paginação, caso a tag PAGE_CONTROL
seja utilizada ma query.

@param cQuery, caracter, Query original para tratamento
@param cOrderBy, caracter, Instrução de ordenação por operação

@return caracter, Query com o tratamento para paginação
@author Marcia Junko
@since 08/09/2020
/*/
//----------------------------------------------------------------------------------
Static Function QueryPageControl( cQuery, cOrderBy )
	Local nPosStart   := 0
	Local nPosEnd     := 0
	Local nPosFrom    := 0
	Local cAuxQuery    := ""
    Local cFields      := ""
    Local cPageControl := ""
    Local cTag         := "<<PAGE_CONTROL>>"

	Default cQuery   := ""
	
	IF At( cTag, cQuery ) > 0 
		nPosStart  := At( cTag, cQuery )
		cAuxQuery  := SubStr( cQuery, nPosStart )
	
        nPosEnd := Len( cTag )
        nPosFrom := At( " FROM ", cAuxQuery )
        cFields := Alltrim( Subs( cAuxQuery, nPosEnd + 2, nPosFrom - nPosEnd - 2 ) )
        cFields := AdjustFields( cFields )

        cPageControl := cFields + ' FROM ( SELECT ROW_NUMBER() OVER ( ORDER BY ' + cOrderBy + ' ) AS LINE '
    
        cQuery := StrTran( cQuery, cTag, cPageControl )
        cQuery += ' ) TABLE_AUX WHERE LINE BETWEEN ? AND ? '
	EndIf
Return cQuery

//----------------------------------------------------------------------------------
/*/{Protheus.doc} AdjustFields
Função responsável por ajustar os campos na query de paginação quando utilizado 
alguma função de agregação ou renomear o nome do campo.
Esta função só é acionada quando o controle de paginação está sendo usado.

@param cFields, caracter, Campos da query

@return caracter, Campos tratados da query
@author Marcia Junko
@since 08/09/2020
/*/
//----------------------------------------------------------------------------------
Static Function AdjustFields( cFields )
	Local aFields := {}
    Local nItem := 0
    Local nPosAs := 0
	Local cAdjustFields := ''    
    Local cField := ''

    If At( ' AS ', cFields ) > 0
        aFields := StrToArray( cFields, ',' )
        For nItem := 1 to len( aFields )
            If nItem > 1
                cAdjustFields += ', '
            EndIf

            cField := aFields[ nItem ]
            If ' AS ' $ Upper( cField )
                nPosAs := At( " AS ", Upper( cField ) )

                cAdjustFields += SubStr( cField, nPosAs + 4 )
            Else
                cAdjustFields += cField
            EndIf
        Next
    Else
        cAdjustFields := cFields
    EndIf
Return cAdjustFields

//----------------------------------------------------------------------------------
/*/{Protheus.doc} SetQueryValues
Função responsável por atribuir os valores na query de acordo com a operação

@param @oQuery, object, Objeto que armazena as informações da query
@param cOper, caracter, Identifica qual a query será montada
@param oSelf, object, Objeto principal do WS

@author Marcia Junko
@since 03/09/2020
/*/
//----------------------------------------------------------------------------------
Static Function SetQueryValues( oQuery, cOper, oSelf )
    Local nRecStart     := 0
    Local nRecFinish    := 0 
    
    nRecStart := ( ( oSelf:page - 1 ) * oSelf:pageSize ) + 1
    nRecFinish := ( nRecStart + oSelf:pageSize ) - 1

    Do Case
        Case cOper == "purchaseOrders"
            oQuery:setString( 1, oSelf:status )    
            oQuery:setString( 2, oSelf:approverCode )
            oQuery:setNumeric( 3, nRecStart )
            oQuery:setNumeric( 4, nRecFinish )
        
        Case cOper == "purchaseOrderItems" 
            oQuery:setString( 1, oSelf:itemGroup )   
            oQuery:setString( 2, oSelf:approverCode ) 
            oQuery:setString( 3, oSelf:purchaseOrderNumber )     
            oQuery:setNumeric( 4, nRecStart )
            oQuery:setNumeric( 5, nRecFinish )
        
        Case cOper == "historyByItem"
            oQuery:setString( 1, oSelf:productCode )    
            oQuery:setNumeric( 2, nRecStart )
            oQuery:setNumeric( 3, nRecFinish )
    EndCase
Return

//----------------------------------------------------------------------------------
/*/{Protheus.doc} SetPropByOper
Função responsável por definir as propriedades do JSON de acordo com a operação

@param cOper, caracter, Identifica qual a query será montada

@return json, componente com a estrutura do Json
@author Marcia Junko
@since 03/09/2020
/*/
//----------------------------------------------------------------------------------
Static Function SetPropByOper( cOper )
    Local aProperties := {}
    Local nSize := 50
    Local nDecimal := 0

    Do Case
        Case cOper == 'purchaseOrders'
            aProperties := { ;
                { "A2_NREDUZ", "supplyerName", 'C', nSize, nDecimal }, ;
                { "C7_NUM", "purchaseOrderNumber", 'C', nSize, nDecimal }, ;
                { "E4_DESCRI", "paymentTermDescription", 'C', nSize, nDecimal }, ;
                { "Y1_NOME", "purchaserName", 'C', nSize, nDecimal }, ;
                { "TOTAL", "orderTotal", 'N', nSize, nDecimal }, ;
                { "C7_FILIAL", "branchDescription", 'C', nSize, nDecimal }, ;
                { "C7_EMISSAO", "orderDate", 'C', nSize, nDecimal }, ;
                { "C7_MOEDA", "currency", 'C', nSize, nDecimal }, ; 
                { 'CCENTER', "costCenter", 'C', nSize, nDecimal }, ;
                { "CR_GRUPO", "groupAprov", 'C', nSize, nDecimal }, ; 
                { "CR_ITGRP", "itemGroup", 'C', nSize, nDecimal } ; 
            }
        Case cOper == 'purchaseOrderItems'
            aProperties := { ;
                { 'C7_NUM', "purchaseOrderNumber", 'C', nSize, nDecimal }, ;
                { 'C7_ITEM', 'purchaseOrderItem', 'C', nSize, nDecimal }, ;
                { 'C7_CC', "costCenter", 'C', nSize, nDecimal }, ;
                { 'C7_QUANT', "quantity", 'N', nSize, nDecimal }, ;
                { 'C7_TOTAL', "itemTotal", 'N', nSize, nDecimal }, ;
                { 'C7_PRECO', "unitValue", 'N', nSize, nDecimal }, ;
                { 'C7_PRODUTO', "itemSku", 'N', nSize, nDecimal }, ;
                { 'C7_DESCRI', "itemSkuDescription", 'C', nSize, nDecimal }, ;
                { 'B1_DESC', "productSkuDescription", 'C', nSize, nDecimal }, ;
                { 'C7_UM', "unitMeasurement", 'C', nSize, nDecimal }, ;
                { "CR_GRUPO", "groupAprov", 'C', nSize, nDecimal }, ; 
                { "CR_ITGRP", "itemGroup", 'C', nSize, nDecimal }, ; 
                { 'C7_MOEDA', "currency", 'C', nSize, nDecimal } ;
            }
        
        Case cOper == "historyByItem"
            aProperties := { ;
                { 'D1_EMISSAO', "purchaseDate", 'C', nSize, nDecimal }, ;
                { 'A2_NOME', 'supplyerName', 'C', nSize, nDecimal }, ;
                { 'D1_QUANT', "quantity", 'N', nSize, nDecimal }, ;
                { 'D1_VUNIT', "unitValue", 'N', nSize, nDecimal } ;
            }
    EndCase
Return aProperties

//----------------------------------------------------------------------------------
/*/{Protheus.doc} SetJsonProperties
Função responsável por atribuir a estrutura do JSON de acordo com a operação

@param aProperties, array, vetor com a lista de propriedades do JSON

@return json, componente com a estrutura do Json
@author Marcia Junko
@since 03/09/2020
/*/
//----------------------------------------------------------------------------------
Static Function SetJsonProperties( aProperties )
    Local oJsonProperties
    Local nProp := 0
    Local nSize := 0
    Local nDecimal := 0
    Local cField := ''
    Local cLabel := ''
    Local cType := ''

    oJsonProperties := JsonObject():New()
    For nProp := 1 to len( aProperties )
        cField := aProperties[ nProp ][1]
        cLabel := aProperties[ nProp ][2]
        cType := aProperties[ nProp ][3]
        nSize := aProperties[ nProp ][4]
        nDecimal := aProperties[ nProp ][5]

        oJsonProperties[ cField ] := createJSonField( cLabel, cType, nSize, nDecimal )
    Next
Return oJsonProperties

//----------------------------------------------------------------------------------
/*/{Protheus.doc} createJSonField
Função responsável por atribuir a estrutura do JSON de acordo com a operação

@param cLabel, caracter, Label da propriedade no JSON
@param cType, caracter, Tipo de conteúdo
@param nWidth, number, Tamanho do conteúdo
@param nDecimal, number, Quantidade de decimais

@return json, propriedades das colunas
@author Marcia Junko
@since 03/09/2020
/*/
//----------------------------------------------------------------------------------
static function createJSonField( cLabel, cType, nWidth, nDecimal )
    local jField := JsonObject():New()

    Default nWidth := 0
    Default nDecimal := 0

    jField["name"] := cLabel
    jField["type"] := cType
    jField["width"] := nWidth
    jField["decimal"] := nDecimal
return jField

//----------------------------------------------------------------------------------
/*/{Protheus.doc} ResultToJson
Função que atribui o resultado da query ao JSON

@param cAlias, caracter, Alias da query
@param @oJson, JSON, componente que receberá os registros
@param cItemsName, caracter, Nome do nó principal onde os registros serão armazenados
@param oProperties, JSON, componente com a estrutura do Json

@author Marcia Junko
@since 04/09/2020
/*/
//----------------------------------------------------------------------------------
Static function ResultToJson( cAlias, oJson, cItemsName, oProperties )
    local aFields   := ( cAlias )->( dbStruct() )
    Local aSymbol   := { SUPERGETMV("MV_SIMB1"), SUPERGETMV("MV_SIMB2"), SUPERGETMV("MV_SIMB3"), SUPERGETMV("MV_SIMB4"), SUPERGETMV("MV_SIMB5") }
    local oItem
    local cPropertyName := ''
    local nField    := 0
    local nVlr      := 0
    
    ( cAlias )->( DBGoTop() )
    While ( cAlias )->( !EOF() )
        oItem := JsonObject():new()

        For nField := 1 to len( aFields )
            If aFields[ nField ][ 1 ] != 'LINE'
                cPropertyName := oProperties[ aFields[ nField ][ 1 ] ][ "name" ]
                If cPropertyName == 'currency'
                    oItem[ cPropertyName ] := aSymbol[ ( cAlias )->( fieldget( nField ) ) ]
                    if cItemsName == "purchaseOrders" .and. (cAlias)->C7_MOEDA <> SAK->AK_MOEDA
                        oItem[ cPropertyName ] := aSymbol[ SAK->AK_MOEDA ]
                    endif
                Else
                    If cPropertyName <> 'costCenter'
                        If empty( cPropertyName )
                            cPropertyName := aFields[ nField ][1]
                        Endif
                        oItem[ cPropertyName ] := getValueJson( ( cAlias )->( fieldget( nField ) ), aFields[ nField ][2] )
                        if cItemsName == "purchaseOrders" .and. cPropertyName == "orderTotal"
                            if (cAlias)->C7_MOEDA <> SAK->AK_MOEDA
                                DbSelectArea("SC7")
                                SC7->(DbSetOrder(1))//C7_FILIAL+C7_NUM+C7_ITEM
                                if SC7->(MsSeek(fwxFilial("SC7")+(cAlias)->C7_NUM))
                                    nVlr := oItem[ cPropertyName ]
                                    oItem[ cPropertyName ] := xMoeda(nVlr,(cAlias)->C7_MOEDA,SAK->AK_MOEDA,SC7->C7_EMISSAO,TamSX3("C7_PRECO")[2],SC7->C7_TXMOEDA)
                                endif
                            endif
                        endif
                    Else
                        cCCenter := Posicione("DBL", 1, XFilial("DBL") + (cAlias)->CR_GRUPO + (cAlias)->CR_ITGRP, "DBL_CC")

                        If Empty(cCCenter) .AND. cItemsName == "purchaseOrderItems"
                            cCCenter := Posicione("SC7", 1, XFilial("SC7") + (cAlias)->C7_NUM + (cAlias)->C7_ITEM, "C7_CC")
                        EndIf
                        
                        cDescCC  := Posicione("CTT", 1, XFilial("CTT") + cCCenter, "CTT_DESC01")
                        oItem[ cPropertyName ] := getValueJson( cDescCC, aFields[ nField ][2] )                  
                    EndIf
                EndIf
            EndIf
        Next 

        aAdd( oJson[ cItemsName ], oItem )
        
        ( cAlias )->( dbskip() )
    End

    FWFreeArray( aFields )
    FWFreeArray( aSymbol )
    FreeObj( oItem )
return 

//----------------------------------------------------------------------------------
/*/{Protheus.doc} getValueJson
Função para tratar os conteúdos do tipo caracter, tirando os espaços e adequando os
caracteres especiais

@param xValue, any, Conteúdo a tratar
@param cType, caracter, Tipo do campo

@return any, Conteúdo tratado do JSON
@author Marcia Junko
@since 04/09/2020
/*/
//----------------------------------------------------------------------------------
static function getValueJson( xValue, cType )
    if cType == "C"
        xValue := EncodeUTF8( Alltrim( xValue ) )
    endif
return xValue

//----------------------------------------------------------------------------------
/*/{Protheus.doc} LoadOrderResult
Função responsável pela busca das informações de pedidos de compras

@param @oResponse, object, Objeto que armazena os registros a apresentar.
@param @oSelf, object, Objeto principal do WS
@param cOper, caracter, Identifica qual ação será retornada

@return boolean, .T. se encontrou registros e .F. se ocorreu erro.
@author Marcia Junko
@since 04/09/2020
/*/
//----------------------------------------------------------------------------------
Static Function LoadOrderResult( oResponse, oSelf, cOper, searchKey, cInitDate, cEndDate, cItemGroup)
    Local oQuery
    Local oProperties
    Local cTmp          := ""
    Local nRecords      := 0
    Local lRet          := .T.
    Local lHasNext      := .T.
    Local aProperties   := {}

    Default searchKey     := ''
    Default cInitDate   := '' 
    Default cEndDate    := ''
    Default cItemGroup   := ''

    dbSelectArea( "SAK" )
    dbSetOrder( 2 ) //AK_FILIAL + AK_USER

    If MsSeek( xFilial( "SAK" ) + __cUserId )
        cTmp := GetNextAlias()
        oSelf:approverCode := SAK->AK_USER

        oQuery := GetQuery( cOper , searchKey, cInitDate, cEndDate, cItemGroup )
        SetQueryValues( @oQuery, cOper, oSelf )
        aProperties := SetPropByOper( cOper )
        oProperties := SetJsonProperties( aProperties )

        MPSysOpenQuery( oQuery:getFixQuery(), cTmp )

        dbSelectArea( cTmp )

        oResponse[ cOper ] := {}
        oResponse[ "hasNext" ] := .F.

        If ( cTmp )->( !Eof() )
            COUNT TO nRecords

            ResultToJson( cTmp, @oResponse, cOper, oProperties )
            
            IF ( nRecords < oSelf:pageSize ) .Or. cOper == 'historyByItem'
                lHasNext := .F.
            EndIf
        Else
            lHasNext := .F.
        EndIf  
        
        oResponse[ "hasNext" ] := lHasNext

        ( cTmp )->( DBCloseArea() )
    Else
        lRet := .F.
        SetRestFault(400, EncodeUTF8( "Usuário não está cadastrado como aprovador." ), .T., 400, EncodeUTF8( "O seu usuário não está cadastrado com aprovador no ERP." ) )
    EndIf

    oQuery := NIL
    FreeObj( oQuery )
    FreeObj( oProperties )
    FWFreeArray( aProperties )
Return lRet

//----------------------------------------------------------------------------------
/*/{Protheus.doc} GetMoreFields
Função que retorna os campos adicionais do pedido de compras

@return caracter, Campos de retorno do JSON 
@author Marcia Junko
@since 22/09/2020
/*/
//----------------------------------------------------------------------------------
static function GetMoreFields()
    Local cFields := ""

    If __cPOMoreFields == NIL
        cFields := AddFieldsbyPE( )
    Else
        cFields := __cPOMoreFields
    EndIf
Return cFields

//----------------------------------------------------------------------------------
/*/{Protheus.doc} AddFieldsbyPE
Função para retornar as informações adicionais de um item do PC definido no PE MT094CPC

@return caracter, Campos de retorno do JSON ( fixos ou adicionados pelo PE )
@author Marcia Junko
@since 22/09/2020
/*/
//----------------------------------------------------------------------------------
static function AddFieldsbyPE()
    Local lMt094Cpc := ExistBlock( "MT094CPC" )
    Local aFields := {}
    Local cResult := ""
    Local cField := ""
    Local cMoreFields := ""
    Local nItem := 0

    cMoreFields := "C7_DATPRF, C7_QUJE"
    If lMt094Cpc
        cResult := ExecBlock( "MT094CPC", .F., .F. )

        IF !Empty( cResult )
            aFields := StrToArray( cResult, '|' )
            For nItem := 1 to len( aFields )
                cField := aFields[ nItem ]

                If !( cField + ',' $ cMoreFields + ',' )
                    cMoreFields += ', ' + cField
                EndIf
            Next
        EndIf

        FWFreeArray( aFields )
    endif
    __cPOMoreFields := cMoreFields
return cMoreFields

Static Function LoadRecnoPC(cKey,cAprovCode, cItemGroup)

Local cQuery    := ""
Local cAliRec   := GetNextAlias()
Local nRet      := 0

Default cItemGroup := ""

cQuery := " SELECT SCR.R_E_C_N_O_ AS RECNO "
cQuery += " FROM " + RetSqlName( "SCR" ) + " SCR "
cQuery += " LEFT JOIN " + RetSqlName( "DBM" ) + " DBM ON DBM_FILIAL = '" + xFilial( "DBM" ) + "' AND CR_NUM = DBM_NUM AND DBM.D_E_L_E_T_ = ' ' "

If !Empty(cItemGroup)
    cQuery += " AND DBM_ITGRP = '" + cItemGroup + "'"
EndIf

cQuery += " WHERE SCR.CR_STATUS = '02'"

cQuery += " AND CR_FILIAL = '"+XFilial("SCR")+"' AND  SCR.CR_NUM = '" + cKey + "'"

If !Empty(cItemGroup)
    cQuery += " AND SCR.CR_ITGRP = '" + cItemGroup + "'"
EndIf

cQuery += " AND SCR.CR_USER = '" + cAprovCode + "'"
cQuery += " AND SCR.D_E_L_E_T_ = ' ' "

cQuery := ChangeQuery( cQuery )
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliRec,.T.,.T.)

If (cAliRec)->(!EOF())
    nRet := (cAliRec)->RECNO
Endif

(cAliRec)->(DbCloseArea())

Return nRet

//-------------------------------------------------------------------
/*/{Protheus.doc} PosMsDoc()
Se existir, Posiciona no Banco de Conhecimento da Entidade
@author TOTVS
@since 14/07/2021
/*/
//-------------------------------------------------------------------
Static Function PosMsDoc(cEntidade, oMod)

	Local aRet	  := Array(2)
	Local cChave  := ""
	
	cChave  := FwXFilial("FLE") + oMod:GetValue("FLE_TIPO") + oMod:GetValue("FLE_PRESTA") + oMod:GetValue("FLE_PARTIC") + oMod:GetValue("FLE_ITEM")

	aRet[1] := cChave
	aRet[2] := .F.
	AC9->(DbSetOrder(2)) // AC9_FILIAL+AC9_ENTIDA+AC9_FILENT+AC9_CODENT+AC9_CODOBJ
	If AC9->(DbSeek(FwXFilial("AC9") + cEntidade + FwXFilial(cEntidade) + cChave))
		ACB->(DbSetOrder(1)) //	ACB_FILIAL+ACB_CODOBJ
		ACB->(DbSeek(FwXFilial("ACB") + AC9->AC9_CODOBJ))
		aRet[2] := .T.
	EndIf

Return aRet


//-------------------------------------------------------------------
/*/{Protheus.doc} attachments
Método para retornar a lista de anexos do item do pedido

@author TOTVS
@since 30/08/2020

@return Json, informações dos itens do pedido de compras
/*/
//-------------------------------------------------------------------
WSMETHOD GET attachments WSRECEIVE purchaseOrderNumber, purchaseOrderItem, objectCode WSSERVICE purchaseOrderApproval
    Local oResponse     := JsonObject():New()
    Local aFields       := {}
    Local cJson         := ""
    Local lRet          := .F.
    Local cEntidade     := "SC7"
    Local cDirDoc       := Alltrim(MsDocPath())
    Local cArq          := ""
    Local nSavSize      := 0

    Default Self:purchaseOrderNumber    := ""
    Default Self:purchaseOrderItem      := ""
    Default Self:objectCode             := ""

    iF !empty( Self:purchaseOrderNumber ) .And. !empty( Self:purchaseOrderItem )
        
        dbSelectArea( "SAK" )
        dbSetOrder( 2 ) //AK_FILIAL + AK_USER

        If MsSeek( xFilial( "SAK" ) + __cUserId )
      
            oResponse[ "itemsAttachments" ] := {}
            oResponse[ "hasNext" ] := .F.

            dbSelectArea( "SC7" )
            dbSetOrder( 1 ) //C7_FILIAL+C7_NUM+C7_ITEM+C7_SEQUEN
            If SC7->( dbSeek( XFilial ( "SC7" ) + Self:purchaseOrderNumber + Self:purchaseOrderItem ) )

                AC9->(DbSetOrder(2)) // AC9_FILIAL, AC9_ENTIDA, AC9_FILENT, AC9_CODENT, AC9_CODOBJ
                If AC9->(DbSeek(XFilial("AC9") + cEntidade + FwXFilial(cEntidade)+  PADR(XFILIAL("SC7")+SC7->C7_NUM+SC7->C7_ITEM, TamSX3("AC9_CODENT")[1]) + Self:objectCode ))

                   oItem := JsonObject():New() 

                    ACB->(DbSetOrder(1)) //	ACB_FILIAL+ACB_CODOBJ
                    If ACB->(DbSeek(FwXFilial("ACB") + AC9->AC9_CODOBJ))
                        
                        cFilePath := Lower(ACB->ACB_OBJETO)
                        If !Empty(cFilePath)
                            cImg	  := cDirDoc + "\" + cFilePath
                            nHdl	  := FOpen(cImg)
                            nSize	  := FSeek(nHdl,0,2)
                            nSavSize  := nSize
                            FSeek(nHdl,0)
                            While nSize > 0
                                nRead	:= Min(4096,nSize) 
                                cAux 	:= Space(nRead)
                                FRead(nHdl,	@cAux, nRead) 
                                cArq 	+= cAux
                                nSize 	:= nSize - nRead
                            EndDo

                            oItem[ "name" ]  := AllTrim(SubStr(ACB->ACB_OBJETO, 1 , At(".", ACB->ACB_OBJETO)-1))
                            oItem[ "type" ]  := Alltrim(SubStr(ACB->ACB_OBJETO, At(".", ACB->ACB_OBJETO)+1, 10))
                            oItem[ "file" ]  := Encode64(cArq)

                            Aadd(oResponse[ "itemsAttachments" ], oItem )
                            
                            FClose(nHdl)
                        EndIf
                    EndIf
                    
                EndIf

            EndIf

            cJson := FWJsonSerialize( oResponse, .F., .F., .T. )

            ::SetResponse( cJson )

            lRet := .T.
        Else
            SetRestFault( 400, EncodeUTF8( "Usuário não está cadastrado como aprovador." ), .T., 400, EncodeUTF8( "O seu usuário não está cadastrado com aprovador no ERP." ) )
        EndIf
    Else
        If Empty( Self:purchaseOrderNumber )
            SetRestFault( 400, EncodeUTF8( "Número do pedido de compra não informado."), .T., 400, EncodeUTF8( "Pedido de compra não informado na consulta." )  )
        elseif Empty( Self:purchaseOrderItem )
            SetRestFault( 400, EncodeUTF8( "Número do item não informado."), .T., 400, EncodeUTF8( "Item não informado na consulta." )  )
        else
            SetRestFault( 400, EncodeUTF8( "Informações necessárias para execução não foram fornecidas."), .T., 400, EncodeUTF8( "Informações necessárias não foram fornecidas." )  )
        EndIf    
    endif

    If Type("oItem") <> 'U'
        FreeObj( oItem )
    EndIf

    FWFreeArray( aFields )
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} listttachments
Método para retornar a lista de anexos do item do pedido

@author TOTVS
@since 30/08/2020

@return Json, informações dos itens do pedido de compras
/*/
//-------------------------------------------------------------------
WSMETHOD GET listAttachments WSRECEIVE purchaseOrderNumber, purchaseOrderItem WSSERVICE purchaseOrderApproval
    Local oResponse     := JsonObject():New()
    Local aFields       := {}
    Local cJson         := ""
    Local cDirDoc       := Alltrim(MsDocPath())
    Local lRet          := .F.
    Local nSavSize      := 0
    Local cEntidade     := "SC7"

    Default Self:purchaseOrderNumber    := ""
    Default Self:purchaseOrderItem      := ""

    iF !empty( Self:purchaseOrderNumber ) .And. !empty( Self:purchaseOrderItem )
        
        dbSelectArea( "SAK" )
        dbSetOrder( 2 ) //AK_FILIAL + AK_USER

        If MsSeek( xFilial( "SAK" ) + __cUserId )
      
            oResponse[ "itemsAttachments" ] := {}
            oResponse[ "hasNext" ] := .F.

            dbSelectArea( "SC7" )
            dbSetOrder( 1 ) //C7_FILIAL+C7_NUM+C7_ITEM+C7_SEQUEN
            If SC7->( dbSeek( XFilial ( "SC7" ) + Self:purchaseOrderNumber + Self:purchaseOrderItem ) )

                AC9->(DbSetOrder(2)) // AC9_FILIAL, AC9_ENTIDA, AC9_FILENT, AC9_CODENT, AC9_CODOBJ
                If AC9->(DbSeek(XFilial("AC9") + cEntidade + FwXFilial(cEntidade)+ XFILIAL("SC7")+SC7->C7_NUM+SC7->C7_ITEM))

                    While (AC9->AC9_FILIAL + AC9->AC9_ENTIDA + AC9->AC9_FILENT + AllTrim(AC9->AC9_CODENT))  == (XFilial("AC9") + cEntidade + FwXFilial(cEntidade)+ XFILIAL("SC7")+SC7->C7_NUM+SC7->C7_ITEM)
                    
                        oItem := JsonObject():New() 

                        ACB->(DbSetOrder(1)) //	ACB_FILIAL+ACB_CODOBJ
                        If ACB->(DbSeek(FwXFilial("ACB") + AC9->AC9_CODOBJ))

                            cFilePath := Lower(ACB->ACB_OBJETO)
                            
                            If !Empty(cFilePath)
                                cImg	  := cDirDoc + "\" + cFilePath
                                nHdl	  := FOpen(cImg)
                                nSize	  := FSeek(nHdl,0,2)
                                nSavSize  := Round((nSize/1024)/1024, 2)
                                FClose(nHdl)
                            EndIf

                            oItem[ "name" ]  := AllTrim(SubStr(ACB->ACB_OBJETO, 1 , At(".", ACB->ACB_OBJETO)-1))
                            oItem[ "code" ]  := AllTrim(AC9->AC9_CODOBJ)
                            oItem[ "type" ]  := Alltrim(SubStr(ACB->ACB_OBJETO, At(".", ACB->ACB_OBJETO)+1, 10))
                            oItem[ "size" ]  := nSavSize
                            oItem[ "sizeType" ]  := "MB"

                            Aadd(oResponse[ "itemsAttachments" ], oItem )

                        EndIf
                        
                        AC9->(dbSkip()) 
                    EndDo
                    
                EndIf

            EndIf

            cJson := FWJsonSerialize( oResponse, .F., .F., .T. )

            ::SetResponse( cJson )

            lRet := .T.
        Else
            SetRestFault( 400, EncodeUTF8( "Usuário não está cadastrado como aprovador." ), .T., 400, EncodeUTF8( "O seu usuário não está cadastrado com aprovador no ERP." ) )
        EndIf
    Else
        If Empty( Self:purchaseOrderNumber )
            SetRestFault( 400, EncodeUTF8( "Número do pedido de compra não informado."), .T., 400, EncodeUTF8( "Pedido de compra não informado na consulta." )  )
        elseif Empty( Self:purchaseOrderItem )
            SetRestFault( 400, EncodeUTF8( "Número do item não informado."), .T., 400, EncodeUTF8( "Item não informado na consulta." )  )
        else
            SetRestFault( 400, EncodeUTF8( "Informações necessárias para execução não foram fornecidas."), .T., 400, EncodeUTF8( "Informações necessárias não foram fornecidas." )  )
        EndIf    
    endif

    If Type("oItem") <> 'U'
        FreeObj( oItem )
    EndIf

    FWFreeArray( aFields )
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} LibVisto
Retorna se aprovação é do tipo VISTO

@author Leandro Fini
@since 18/01/2022
/*/
//-------------------------------------------------------------------
Static Function LibVisto(cAprov, cGrupo)

Local lRet := .F.

Default cAprov := "" 
Default cGrupo := ""

DbSelectArea("SAL")
SAL->(DbSetOrder(3))//AL_FILIAL+AL_COD+AL_APROV
If SAL->(MsSeek(fwxFilial("SAL") + cGrupo + cAprov ))
    If Alltrim(SAL->AL_LIBAPR) == "V"
        lRet := .T. //Aprovação por visto, sem necessidade de verificar saldo.
    Endif 
Endif

Return lRet
