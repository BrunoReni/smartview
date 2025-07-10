#Include "totvs.ch"
#Include "restful.ch"
#INCLUDE "FWMVCDef.ch"

static __oWSpurchaseRequestApproval := FWHashMap():New()
static __cPOMoreFields := NIL
Static __cServiceName := "purchaseRequestApproval"

#DEFINE OP_LIB	"001" // Liberado
#DEFINE OP_REJ	"005" // Rejeitado

//-------------------------------------------------------------------
/*/{Protheus.doc} purchaseRequestApproval
API para retornar os dados relacionados ao processo de aprovação 
de solicitação de compra para o cenário de aprovação 
via aplicativo Meu Protheus.

@author Marcia Junko
@since 20/01/2022 
/*/
//-------------------------------------------------------------------
WSRESTFUL purchaseRequestApproval DESCRIPTION "Registros em aprovação" FORMAT APPLICATION_JSON

    WSDATA page			            AS INTEGER OPTIONAL 
    WSDATA pageSize		            AS INTEGER OPTIONAL
    WSDATA status		            AS STRING OPTIONAL
    WSDATA type	    	            AS STRING OPTIONAL
    WSDATA recordID                 AS STRING OPTIONAL
    WSDATA requestNumber            AS STRING OPTIONAL
    WSDATA requestItem              AS STRING OPTIONAL
    WSDATA mainTable                AS STRING OPTIONAL
    WSDATA execBlock                AS STRING OPTIONAL

    WSDATA purchaseRequestNumber		AS STRING OPTIONAL
    WSDATA purchaseRequestItem		AS STRING OPTIONAL
    WSDATA objectCode       		AS STRING OPTIONAL
    WSDATA approverCode		        AS STRING OPTIONAL
    WSDATA productCode              AS STRING OPTIONAL
    WSDATA isapproved               AS BOOLEAN OPTIONAL
    WSDATA purchaseRequestBranch      AS STRING OPTIONAL
    WSDATA purchaseRequestMessage     AS STRING OPTIONAL
    WSDATA itemGroup                AS STRING OPTIONAL
    WSDATA searchKey                AS STRING OPTIONAL
    WSDATA cInitDate                AS STRING OPTIONAL
    WSDATA cEndDate                 AS STRING OPTIONAL    

    WSMETHOD GET isUserApprover ;
        DESCRIPTION "Verifica se o usuário é um aprovador." ;
        PATH "api/com/purchaseRequestApproval/v1/isuserapprover"  ;
        TTALK "v1" ;
        WSSYNTAX "api/com/purchaseRequestApproval/v1/isuserapprover" ;
        PRODUCES APPLICATION_JSON

    WSMETHOD GET records ;
        DESCRIPTION "Retorna a lista de registros aguardando aprovação do usuário." ;
        PATH "api/com/purchaseRequestApproval/v1/records"  ;
        TTALK "v1" ;
        WSSYNTAX "api/com/purchaseRequestApproval/v1/records" ;
        PRODUCES APPLICATION_JSON
    
    WSMETHOD GET itemsByRecord ;
        DESCRIPTION "Retorna a lista de itens de um registro." ;
        PATH "api/com/purchaseRequestApproval/v1/records/{recordID}/items"  ;
        TTALK "v1" ;
        WSSYNTAX "api/com/purchaseRequestApproval/v1/records/{recordID}/items" ;
        PRODUCES APPLICATION_JSON

    WSMETHOD GET historyByItem ;
        DESCRIPTION "Retorna a lista com os últimos lançamentos de compras para o produto." ;
        PATH "api/com/purchaseRequestApproval/v1/historybyitem"  ;
        TTALK "v1" ;
        WSSYNTAX "api/com/purchaseRequestApproval/v1/historybyitem" ;
        PRODUCES APPLICATION_JSON

    WSMETHOD GET additionalInformation ;
        DESCRIPTION "Retorna as informações adicionais para um item do registro." ;
        PATH "api/com/purchaseRequestApproval/v1/additionalinformation/{requestNumber}/item/{requestItem}"  ;
        TTALK "v1" ;
        WSSYNTAX "api/com/purchaseRequestApproval/v1/additionalinformation/{requestNumber}/item/{requestItem}" ;
        PRODUCES APPLICATION_JSON

    WSMETHOD PUT approveRecord  ;
        DESCRIPTION "Realiza a aprovação do registro" ;
        PATH "api/com/purchaseRequestApproval/v1/approve/{recordID}"  ;
        TTALK "v1" ;
        WSSYNTAX "api/com/purchaseRequestApproval/v1/approve/{recordID}" ;
        PRODUCES APPLICATION_JSON    

END WSRESTFUL

//-------------------------------------------------------------------
/*/{Protheus.doc} isUserApprover
Método para retornar se um usuário é aprovador ou não.

@author Marcia Junko
@since 01/02/2022 
/*/
//-------------------------------------------------------------------
WSMETHOD GET isUserApprover WSSERVICE purchaseRequestApproval
    Local cJson     := ""
    Local lRet      := .T.

    cJson := MobJUsrApprover()

    ::SetResponse( cJson )
Return lRet

//------------------------------------------------------------------------------------------------
/*/{Protheus.doc} records
Método para retornar a lista de documentos sob responsabilidade do usuário logado de acordo com o 
tipo do documento e status.

@param page, number, número da página para retorno
@param pageSize, number, número de registros por página
@param type, caracter, tipo de documento a avaliar ( CR_TIPO )
@param status, caracter, status da aprovação
@param searchKey, caracter, informação para busca
@param cInitDate, caracter, data inicial para pesquisa
@param cEndDate, caracter, data final para pesquisa

@author Marcia Junko
@since 01/02/2022 
/*/
//------------------------------------------------------------------------------------------------
WSMETHOD GET records WSRECEIVE page, pageSize, type, status, searchKey, cInitDate, cEndDate  WSSERVICE purchaseRequestApproval
    Local oResponse     := JsonObject():New() 
    Local cOper         := "recordsList"
    Local cJson         := ""
    Local lRet          := .F.

    Default Self:page        := 1
    Default Self:pageSize    := 10
    Default Self:type       := 'SC'
    Default Self:status      := "02"
    Default Self:searchKey  := ""
    Default Self:cInitDate   := ""
    Default Self:cEndDate    := ""

    lRet := LoadRecords( @oResponse, @Self, cOper )
    
    cJson := FWJsonSerialize( oResponse, .F., .F., .T. )

    ::SetResponse( cJson )
Return lRet 

//------------------------------------------------------------------------------------------------
/*/{Protheus.doc} itemsByRecord
Serviço que retorna os items de um documento específico de acordo com o ID de pesquisa.

@pathparam recordID, number, R_E_C_N_O_ do registro na tabela SCR

@param page, number, número da página para retorno
@param pageSize, number, número de registros por página
@param type, caracter, tipo de documento a avaliar ( CR_TIPO )

@author Marcia Junko
@since 01/02/2022 
/*/
//------------------------------------------------------------------------------------------------
WSMETHOD GET itemsByRecord PATHPARAM recordID WSRECEIVE  page, pageSize, type  WSSERVICE purchaseRequestApproval
    Local oResponse     := JsonObject():New() 
    Local cOper         := "itemsByRecord"
    Local cJson         := ""
    Local lRet          := .F.

    Default Self:page        := 1
    Default Self:pageSize    := 10
    Default Self:type       := 'SC'

    lRet := LoadRecords( @oResponse, @Self, cOper )

    cJson := FWJsonSerialize( oResponse, .F., .F., .T. )

    ::SetResponse( cJson )
Return lRet

//------------------------------------------------------------------------------------------------
/*/{Protheus.doc} additionalInformation
Serviço que retorna as informações adicionais de um item específico.

@pathparam requestNumber, caracter, código da requisição
@pathparam requestItem, caracter, item da requisição

@param type, caracter, tipo de documento a avaliar ( CR_TIPO )

@author Marcia Junko
@since 01/02/2022 
/*/
//------------------------------------------------------------------------------------------------
WSMETHOD GET additionalInformation PATHPARAM requestNumber, requestItem  WSRECEIVE type WSSERVICE purchaseRequestApproval
    Local oResponse     := JsonObject():New() 
    Local cOper         := "additional"
    Local cJson         := ""
    Local lRet          := .F.

    Default self:type := 'SC'

    // Coloca nessa propriedade o nome do PE para adicionar campos no response
    self:execBlock := 'TESTECPO2'

    lRet := LoadRecords( @oResponse, @Self, cOper )

    cJson := FWJsonSerialize( oResponse, .F., .F., .T. )

    ::SetResponse( cJson )
Return

//------------------------------------------------------------------------------------------------
/*/{Protheus.doc} historyByItem
Serviço que retorna as últimas compras de um determinado produto

@param page, number, número da página para retorno
@param pageSize, number, número de registros por página
@param productCode, caracter, código do produto para pesquisa

@author Marcia Junko
@since 01/02/2022 
/*/
//------------------------------------------------------------------------------------------------
WSMETHOD GET historyByItem WSRECEIVE page, pageSize, productCode WSSERVICE purchaseRequestApproval
    Local oResponse     := JsonObject():New()
    Local cOper         := "historyByItem"
    Local cJson         := ""
    Local lRet          := .F.

    Default Self:page        := 1
    Default Self:pageSize    := 10
    Default Self:productCode  := ""

    If !Empty( Self:productCode )
        lRet := LoadRecords( @oResponse, @Self, cOper )
        
        cJson := FWJsonSerialize( oResponse, .F., .F., .T. )

        ::SetResponse( cJson )
    Else
        SetRestFault( 400, EncodeUTF8( "Produto não informado."), .T., 400, EncodeUTF8( "Produto não informado na consulta." )  )
    EndIf
Return lRet

//------------------------------------------------------------------------------------------------
/*/{Protheus.doc} approveRecord
Serviço para aprovar um documento específico

@pathparam recordID, number, R_E_C_N_O_ do registro na tabela SCR

@param type, caracter, tipo de documento a avaliar ( CR_TIPO )

@author Marcia Junko
@since 01/02/2022 
/*/
//------------------------------------------------------------------------------------------------
WSMETHOD PUT approveRecord PATHPARAM recordID WSRECEIVE type WSSERVICE purchaseRequestApproval
    Local oJSONResponse
    Local cJSON
    Local lRet := .F.

    Default self:type := 'SC'

    If !Empty( self:recordID )
        If self:type == 'SC'
            Self:mainTable := 'SCR'     
        EndIf

        oJSONResponse := RunApproval( self, @lRet )

        If !lRet
            SetRestFault(Val(oJSONResponse["code"]), EncodeUTF8(oJSONResponse["message"]), .T., , EncodeUTF8(oJSONResponse["detailMessage"]) )
        else
            //-------------------------------------------------------------------
            // Serializa objeto Json
            //-------------------------------------------------------------------
            cJSON := FwJsonSerialize( oJSONResponse )
        
            //-------------------------------------------------------------------
            // Elimina objeto da memoria
            //-------------------------------------------------------------------
            FreeObj( oJSONResponse )
        
            //-------------------------------------------------------------------
            // Seta resposta
            //-------------------------------------------------------------------
            ::SetResponse( cJSON )
        EndIf
    EndIf
Return lRet

//----------------------------------------------------------------------------------
/*/{Protheus.doc} QueryModel
Função responsável por informar os dados necessários para criação da query base 
de acordo com a operação solicitada.

IMPORTANTE: Ao utilizar o controle de paginação (<<PAGE_CONTROL>>) na query, ao 
        renomear a coluna é OBRIGATÓRIO o uso do identificador "AS" para que não 
        ocorra quebra ao efetuar o parsear. Exemplo: SUM(TOTAL) AS TOTAL

@param cOper, caracter, Identifica qual a query será montada
@param oSelf, object, Componente do serviço REST que está sendo executado
@param @oService, object, Objeto da classe de serviço ( contém a estrutura da query ) 

@return object, Objeto contendo a query base a ser executada pelo REST.
@author Marcia Junko
@since 01/02/2022 
/*/
//----------------------------------------------------------------------------------
Static Function QueryModel( cOper, oSelf, oService )
    Local aQueryInfo := {}
    Local aMainWhere  := {}
    Local aVariables := {}
    Local cMainTable := ''
    Local cFields   := ''
    Local cQuery := ''
    Local nPos := 0
    
    Do Case
        Case cOper == 'recordsList'
            cMainTable := 'SCR'
            cFields := "SUM(CR_TOTAL) / COUNT(*) AS TOTAL, CR_GRUPO, C1_CC, C1_MOEDA"

            /* aMainWhere - Vetor com as condições do WHERE da tabela principal, onde:
                [1] - condição atribuída ao WHERE
                [2] - contéudo variável que será atribuída a condição, caso informado o caracter "?" na posição 1
            */
            aMainWhere := { {"CR_FILIAL = ? ", xFilial( cMainTable )}, ;
                            { "CR_TIPO = ? ", oSelf:type}, ;
                            { "CR_STATUS = ?", oSelf:status }, ;
                            { "CR_USER = ?", oSelf:approverCode } }

            /*aJoin - Vetor com as informações de montagem dos JOINs que farão parte da query, onde:
                [1] - tabela do join
                [2] - tipo do join ( LEFT, RIGHT ou INNER )
                [3] - campos do join que serão adicionados na query
                [4] - condição do join ( WHERE )
            */

            aJoin := { ;
                    { "SC1", "INNER", "C1_FILIAL, C1_NUM, C1_EMISSAO, C1_SOLICIT", { ;
                        { "C1_FILIAL = ?", xFilial( "SC1" ) }, ;
                        { "C1_NUM = CR_NUM" } } }, ;
                    { "SA2", "LEFT", , { ;
                        { "A2_FILIAL = ?", xFilial( "SA2" ) }, ;
                        { "C1_FORNECE = A2_COD" }, ;
                        { "C1_LOJA = A2_LOJA" } } } ;
                }

            // Se os parâmetros de data forem informados, adiciona o filtro na posição de condições do join
            If !Empty( oSelf:cInitDate ) .AND. !Empty( oSelf:cEndDate )
                nPos := Ascan( aJoin, {|x| x[ 1 ] == 'SC1' } )
                If nPos > 0
                    aAdd( aJoin[ nPos ][ 4 ],  { "C1_EMISSAO BETWEEN ? AND ?", { alltrim( oSelf:cInitDate ), alltrim( oSelf:cEndDate ) } } )
                EndIf
            EndIf

            /* aQryInfo - Vetor com as informações para montagem da query base
                [1] - nome da tabela principal do fluxo
                [2] - array ou string com os campos retornados na query
                [3] - array com as condições do Where para a tabela principal
                    [1] - condição do Where
                    [2] - array com o conteúdo das variáveis
                [4] - array com as informações de JOIN
                    [1] - nome da tabela para o JOIN
                    [2] - tipo de join
                    [3] - array ou string com os campos adicionais da query vindos do JOIN
                    [4] - array com as condições do Where para o JOIN
                    [1] - condição do Where
                    [2] - array com o conteúdo das variáveis
                [5] - string com a condição de GROUP BY, caso necessário. Caso não tenha sido informado e a query utilizar um campo de aggregação, o GTOUP BY será feito pelos demais campos.
                [6] - string com a condição de ORDER BY, caso não seja informado será usada o índice 1 da tabela principal
            */
            
            aQueryInfo := { cMainTable, cFields, aMainWhere, aJoin, NIL, "C1_NUM DESC" }

            /* Query montada pelo serviço 
            SELECT TOTAL,CR_ITGRP,CR_GRUPO,SCR_ID,C1_FILIAL,C1_NUM,C1_EMISSAO,A2_NREDUZ 
                FROM (SELECT ROW_NUMBER() OVER ( ORDER BY  C1_NUM DESC ) AS LINE,
                    SUM(CR_TOTAL) / COUNT(*) AS TOTAL,CR_ITGRP,CR_GRUPO,SCR.R_E_C_N_O_ AS SCR_ID,C1_FILIAL,C1_NUM,C1_EMISSAO,A2_NREDUZ 
                    FROM SCRT10 SCR 
                    INNER JOIN SC1T10 SC1 ON C1_FILIAL = ? AND C1_NUM = CR_NUM AND SC1.D_E_L_E_T_ = ' ' 
                    LEFT JOIN SA2T10 SA2 ON A2_FILIAL = ? AND C1_FORNECE = A2_COD AND C1_LOJA = A2_LOJA AND SA2.D_E_L_E_T_ = ' ' 
                    WHERE  CR_FILIAL = ? AND CR_TIPO = ? AND CR_STATUS = ? AND CR_USER = ? AND SCR.D_E_L_E_T_ = ' ' 
                    GROUP BY CR_ITGRP, CR_GRUPO, SCR.R_E_C_N_O_, C1_FILIAL, C1_NUM, C1_EMISSAO, A2_NREDUZ )  TABLE_AUX 
                WHERE  LINE BETWEEN ? AND ?             
            */
        Case cOper == 'itemsByRecord'
            cMainTable := 'SC1'
            cFields := 'C1_NUM, C1_ITEM, C1_PRODUTO, C1_UM, C1_QUANT, C1_CC, C1_TOTAL, C1_PRECO, C1_MOEDA'

            aMainWhere := { {"C1_FILIAL = ? ", xFilial( cMainTable ) } }

            aJoin := { { "SCR", "INNER", { 'CR_GRUPO', 'CR_ITGRP' }, ;
                        {   { "CR_FILIAL = ?", xFilial( "SCR" ) }, ;
                            { "CR_NUM = C1_NUM" }, ;
                            { 'SCR.R_E_C_N_O_ = ?', val( oSelf:recordID ) } } }, ;
                        { "SB1", "INNER", 'B1_DESC' , ;
                            { { "B1_FILIAL = ?", xFilial( "SB1" ) }, ;
                            { "B1_COD = C1_PRODUTO" } } }, ;
                        { "DBM", "INNER", '' , ;
                            { { "DBM_FILIAL = ?", xFilial( "DBM" ) }, ;
                            { "DBM_NUM = CR_NUM" }, ;
                            { "DBM_ITEM = C1_ITEM" }, ;
                            { "DBM_ITGRP = CR_ITGRP" }, ;
                            { "DBM_GRUPO = CR_GRUPO" }, ;
                            { "DBM_USER = CR_USER" } } } ;
                    }

            aQueryInfo := { cMainTable, cFields, aMainWhere, aJoin }

            /* Query montada pelo serviço 
            SELECT C1_NUM,C1_ITEM,C1_PRODUTO,C1_UM,C1_QUANT,C1_CC,C1_TOTAL,C1_PRECO,C1_MOEDA,SC1_ID,CR_GRUPO,CR_ITGRP,B1_DESC 
                FROM (SELECT ROW_NUMBER() OVER ( ORDER BY  C1_FILIAL,C1_NUM,C1_ITEM,C1_ITEMGRD ) AS LINE,
                    C1_NUM,C1_ITEM,C1_PRODUTO,C1_UM,C1_QUANT,C1_CC,C1_TOTAL,C1_PRECO,C1_MOEDA,SC1.R_E_C_N_O_ AS SC1_ID,CR_GRUPO,CR_ITGRP,B1_DESC 
                    FROM SC1T10 SC1 
                    INNER JOIN SCRT10 SCR ON CR_FILIAL = ? AND CR_NUM = C1_NUM AND SCR.R_E_C_N_O_ = ? AND SCR.D_E_L_E_T_ = ' ' 
                    INNER JOIN SB1T10 SB1 ON B1_FILIAL = ? AND B1_COD = C1_PRODUTO AND SB1.D_E_L_E_T_ = ' ' 
                    INNER JOIN DBMT10 DBM ON DBM_FILIAL = ? AND DBM_NUM = CR_NUM AND DBM_ITEM = C1_ITEM AND DBM_ITGRP = CR_ITGRP AND DBM_GRUPO = CR_GRUPO AND DBM_USER = CR_USER AND DBM.D_E_L_E_T_ = ' ' 
                    WHERE  C1_FILIAL = ? AND SC1.D_E_L_E_T_ = ' ' )  TABLE_AUX 
                WHERE  LINE BETWEEN ? AND ?              
            */

        Case cOper == "historyByItem"
            cMainTable := 'SD1'
            nTesSize := TamSX3( 'D1_TES' )[1]
            cOrderBy := 'D1_EMISSAO DESC '
        
            cQuery := "SELECT <<PAGE_CONTROL>>, D1_EMISSAO, A2_NOME, D1_QUANT, D1_VUNIT "
            cQuery +=   " FROM " + RetSqlName( "SD1" ) + " SD1 "
            cQuery +=   " INNER JOIN " + RetSqlName( "SA2" ) + " SA2 ON A2_FILIAL = ? AND A2_COD = D1_FORNECE AND A2_LOJA = D1_LOJA AND SA2.D_E_L_E_T_ = ' ' "
            cQuery +=   " WHERE D1_FILIAL = ? "
            cQuery +=     " AND D1_COD = ? "
            cQuery +=     " AND D1_TIPO NOT IN ('D', 'B') "
            cQuery +=     " AND D1_TES <> '" + Space( nTesSize ) + "' "
            cQuery +=     " AND SD1.D_E_L_E_T_ = ' ' "


            aAdd( aVariables, { 'C', 'A2_FILIAL = ?', XFilial( "SA2" ) } )
            aAdd( aVariables, { 'C', 'D1_FILIAL = ?', XFilial( "SD1" ) } )
            aAdd( aVariables, { 'C', 'D1_COD = ?', oSelf:productCode  } )

            oService := MobileService():New( )
            oStatement := oService:SetQuery( cQuery ) 
            oService:SetVariables( aVariables )
                    
        Case cOper == "additional"
            cMainTable := 'SC1'
            cQuery := "SELECT C1_SOLICIT FROM " + RetSqlName("SC1") + " SC1 " + ;
                    " WHERE  C1_FILIAL = ? AND C1_NUM = ? AND C1_ITEM = ? "
            
            aAdd( aVariables, { 'C', 'C1_FILIAL = ?', XFilial( "SC1" ) } )
            aAdd( aVariables, { 'C', 'C1_NUM = ?', oSelf:requestNumber } )
            aAdd( aVariables, { 'C', 'C1_ITEM = ?', oSelf:requestItem  } )

            oService := MobileService():New(  )
            oService:SetExecBlock( oSelf:execBlock )
            oStatement := oService:SetQuery( cQuery, .F. ) 
            oService:SetVariables( aVariables )

    EndCase

    If oService == NIL
        oService := MobileService():New( __cServiceName )
        oStatement := oService:MakeQueryModel( aQueryInfo ) 
    EndIf

    oSelf:mainTable := cMainTable

    FWFreeArray( aVariables )
Return oStatement

//----------------------------------------------------------------------------------
/*/{Protheus.doc} SetPropByOper
Função responsável por definir as propriedades do JSON de acordo com a operação

@param cOper, caracter, Identifica qual a query será montada
@param oService, object, Objeto da classe de serviço ( contém a estrutura da query ) 

@return array, Vetor com as propriedades que serão mostradas na requisição
@author Marcia Junko
@since 01/02/2022 
/*/
//----------------------------------------------------------------------------------
Static Function SetPropByOper( cOper )
    Local aProperties := {}

    Do Case
        Case cOper == 'recordsList'
            aProperties := { ;
                { "C1_NUM", "requestNumber" }, ;
                { "TOTAL", "requestTotal" }, ;
                { "C1_FILIAL", "branchDescription" }, ;
                { "C1_EMISSAO", "requestDate" }, ;
                { "C1_MOEDA", "currency" }, ; 
                { "C1_CC", "costCenter" }, ; 
                { "CR_GRUPO", "groupAprov" }, ; 
                { "C1_SOLICIT", "requesterName" } ;
            }
            /*Exemplo de array com o conteúdo do campo TOTAL sendo passado pela própria query
            aProperties := { ;
                { "C1_NUM", "requestNumber" }, ;
                { "C1_FILIAL", "branchDescription" }, ;
                { "C1_EMISSAO", "requestrDate" }, ;
                { "C1_MOEDA", "currency" }, ; 
                { "CR_GRUPO", "groupAprov" }, ; 
                { "CR_ITGRP", "itemGroup" }, ; 
                { "A2_NREDUZ", "supplyerName" } ;
            }*/
        Case cOper == 'itemsByRecord'
            aProperties := { ;
                { "C1_NUM", "requestNumber" }, ;
                { 'C1_ITEM', 'requestItem' }, ;
                { 'C1_PRODUTO', "itemProduct" }, ;                
                { 'C1_UM', "unitMeasurement" }, ;
                { 'C1_QUANT', "quantity" }, ;
                { 'C1_CC', "costCenter" }, ;
                { 'C1_TOTAL', "itemTotal" }, ;
                { 'C1_PRECO', "unitValue" }, ;
                { 'C1_MOEDA', "currency" }, ;                
                { 'B1_DESC', "itemSkuDescription" }, ;
                { "CR_GRUPO", "groupAprov" }, ; 
                { "CR_ITGRP", "itemGroup" } ;
            }
            
            /*Exemplo de array com o conteúdo do campo C1_NUM, C1_ITEM e B1_DESC sendo buscado no titulo da SX3 
            aProperties := { ;
                { 'C1_PRODUTO', "itemProduct" }, ;                
                { 'C1_UM', "unitMeasurement" }, ;
                { 'C1_QUANT', "quantity" }, ;
                { 'C1_CC', "costCenter" }, ;
                { 'C1_TOTAL', "itemTotal" }, ;
                { 'C1_PRECO', "unitValue" }, ;
                { 'C1_MOEDA', "currency" }, ;                
                { "CR_GRUPO", "groupAprov" }, ; 
                { "CR_ITGRP", "itemGroup" } ;
            }*/
        Case cOper == "historyByItem"
            // Se não for passado nenhum campo na lista, o aProperties será criado com base nos títulos da SX3.
            aProperties := { ;
                { 'D1_EMISSAO', "purchaseDate" }, ;
                { 'A2_NOME', 'supplyerName' }, ;
                { 'D1_QUANT', "quantity" }, ;
                { 'D1_VUNIT', "unitValue" } ;
            }
        Case cOper == "additional"
            aProperties := { ;
                { 'C1_SOLICIT', "solicit" } }
    EndCase
Return aProperties

//----------------------------------------------------------------------------------
/*/{Protheus.doc} LoadRecords
Função responsável pela busca das informações de pedidos de compras

@param @oResponse, object, Objeto que armazena os registros a apresentar.
@param @oSelf, object, Objeto principal do WS
@param cOper, caracter, Identifica qual ação será retornada

@return boolean, .T. se encontrou registros e .F. se ocorreu erro.
@author Marcia Junko
@since 20/01/2022 
/*/
//----------------------------------------------------------------------------------
Static Function LoadRecords( oResponse, oSelf, cOper )
    Local cApprover     := ""
    Local lRet          := .T.
    
    cApprover := MobChkApprover( 2 ) 
    
    If !Empty( cApprover )
        oSelf:approverCode := cApprover

        MobJSONResult( cOper, oSelf, @oResponse )
    else
        lRet := .F.
        SetRestFault(400, EncodeUTF8( "Usuário não está cadastrado como aprovador." ), .T., 400, EncodeUTF8( "O seu usuário não está cadastrado com aprovador no ERP." ) )
    EndIf
Return lRet

//----------------------------------------------------------------------------------
/*/{Protheus.doc} RunApproval
Função responsável por aprovar\reprovar o documento

@param oSelf, object, Objeto principal do WS

@return json, mensagens relativas ao sucesso\falha no processo de aprovação
@author Marcia Junko
@since 20/01/2022 
/*/
//----------------------------------------------------------------------------------
Static Function RunApproval( oSelf as Object, lRet as Logical ) as Object
    Local aSvAlias := GetArea()
    Local oModel := NIL
    Local oJSONReceived := NIL
    Local oJSONResponse := JsonObject():New()
    Local cBody := ''
    Local cReason := ''
    Local cOperation := ''
    Local lApprove
    Local cAlias

    Default oSelf := JsonObject():New()
    Default lRet  := .F.

    cBody := oSelf:GetContent()

    If !Empty( cBody )		
		FWJsonDeserialize( cBody , @oJSONReceived ) 
		lApprove:= oJSONReceived:approvalStatus 
		cReason	:= DecodeUTF8( oJSONReceived:reason )
        cAlias  := oSelf:mainTable

        IF lApprove
            cOperation := OP_LIB     // Aprova
        else
            cOperation := OP_REJ     // Reprova
        EndIf

        dbSelectArea(cAlias)

        (cAlias)->( DBGoto( val( oSelf:recordID ) ) )
        A094SetOp( cOperation )

        oModel := FWLoadModel("MATA094")
        oModel:SetOperation( MODEL_OPERATION_UPDATE )
        If oModel:Activate()
            If !Empty( cReason )
                oModel:GetModel("FieldSCR"):SetValue( 'CR_OBS' , cReason )
            EndIf
				
            If oModel:VldData() 
                oModel:CommitData()
                oJSONResponse['requestNumber'] := SCR->CR_NUM
                lRet := .T.
            Else
                oJSONResponse['code'] := "400"
                oJSONResponse['message']	:= "A operação não foi concluída."
                oJSONResponse['detailMessage']	:= EncodeUTF8( oModel:GetErrorMessage()[6] )
            EndIf
        else
            MsgAlert('Erro ao carregar modelo', 'Falhou')
            oJSONResponse['code'] := "400"
            oJSONResponse['message']	:= "Erro ao carregar o modelo de dados"
            oJSONResponse['detailMessage']	:= EncodeUTF8( oModel:GetErrorMessage()[6] )
        EndIf
    else
        oJSONResponse['code'] := "500"
        oJSONResponse['message']	:= "Dados insuficientes para executar a requisição"
    EndIf

    IF !Empty( aSvAlias )
        RestArea( aSvAlias )
    ENDIF

    FWFreeArray( aSvAlias )
    FreeObj( oModel )
    FreeObj( oJSONReceived )
Return oJSONResponse
