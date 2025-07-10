#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "COMD030.CH"

//------------------------------------------------------------------------
/*/{Protheus.doc} COMD030
  API de integração de Painéis: Painel de LeadTime
  Pedido de compras x Nota Fiscal de Entrada

  @author		Rafael Duram
  @since		11/01/2021
  @version  12.1.27
  @return 	Json
/*/
//------------------------------------------------------------------------
WSRESTFUL COMD030 DESCRIPTION STR0001 // "Card de Lead Time Pedido de Compras x Nota Fiscal de Entrada"
	WSDATA Fields			AS STRING	  OPTIONAL
	WSDATA Order			AS STRING	  OPTIONAL
	WSDATA Page				AS INTEGER	OPTIONAL
	WSDATA PageSize		AS INTEGER	OPTIONAL
	WSDATA Code		    AS STRING	  OPTIONAL

    WSMETHOD POST itemsDetails ;
    DESCRIPTION STR0002 ; // "Carrega os Itens Utilizados para Montagem do Painel"
    WSSYNTAX "/cards/itemsDetails/{Order, Page, PageSize, Fields}" ;
    PATH "/cards/itemsDetails";
    PRODUCES APPLICATION_JSON

    WSMETHOD GET headerItens ;
    DESCRIPTION STR0003 ; // "Carrega o Cabeçalho a ser apresentado nos detalhes"
    WSSYNTAX "/cards/headerItens/" ;
    PATH "/cards/headerItens";
    PRODUCES APPLICATION_JSON

    WSMETHOD GET cardInfo ;
    DESCRIPTION STR0004 ; // "Carrega as informações do Painel"
    WSSYNTAX "/cards/cardInfo/" ;
    PATH "/cards/cardInfo";
    PRODUCES APPLICATION_JSON

    WSMETHOD GET fieldsInfo ;
    DESCRIPTION STR0005 ; // "Carrega os campos que podem que ser utilizados"
    WSSYNTAX "/cards/fieldsInfo/" ;
    PATH "/cards/fieldsInfo";
    PRODUCES APPLICATION_JSON

ENDWSRESTFUL

WSMETHOD POST itemsDetails WSRECEIVE Order, Page, PageSize, Fields WSSERVICE COMD030

  Local aHeader     := {}
  Local aRet        := {}
  Local cError		  := STR0006 // "Erro na Requisição"
	Local lRet			  := .T.
  Local oCoreDash   := CoreDash():New()
  Local lMSSQL      := "MSSQL"$TCGetDB()
  Local cSelect     := ""
  Local aFilter     := {}
  Local cFilter     := ""
  Local nFiltro     := 0

  Self:SetContentType("application/json")

  oCoreDash:SetFields(DePara())
  oCoreDash:SetApiQstring(Self:aQueryString)
  aFilter := oCoreDash:GetApiFilter()

  For nFiltro := 1 to Len(aFilter)
    cFilter += IIf(nFiltro > 1," AND ","") + aFilter[nFiltro][1]
  Next

  aHeader := {;
    {"pedido"     , STR0007 , , , .T. , .T. },; // "Pedido"  
    {"item"	      , STR0008                 },; // "Item"        
    {"prod"       , STR0009 , , , .T. , .T. },; // "Cod. Produto"
    {"descr"      , STR0010                 },; // "Descrição"
    {"quantPC"    , STR0022                 },; // "Qtd.Pedido"    
    {"dtEmPC"	    , STR0011                 },; // "Emissão PC"
    {"dtEntrPC"   , STR0024                 },; // "Prev.Entrega"  
    {"doc"	      , STR0012 , , , .T. , .T. },; // "Nota Fiscal"
    {"quantNF"    , STR0023                 },; // "Qtd.Recebida"  	   
    {"dtEntNF"	  , STR0013                 },; // "Entrada NF"  
    {"fornec"	    , STR0014 , , , .T. , .T. },; // "Fornecedor"  
    {"loja"	      , STR0015                 },; // "Loja"        
    {"razaoSoc"	  , STR0016                 },; // "Razão Social"
    {"leadTime"	  , STR0021                 };  // "Lead Time"
  }  

  cSelect := " SC7.C7_NUM, SC7.C7_ITEM, SC7.C7_PRODUTO, SB1.B1_DESC, SC7.C7_QUANT, SC7.C7_EMISSAO, SC7.C7_DATPRF, " 
  cSelect += "SD1.D1_DOC, SD1.D1_DTDIGIT, SD1.D1_QUANT, SD1.D1_FORNECE, SD1.D1_LOJA, SA2.A2_NOME "
  cSelect += ",CAST(CAST(SD1.D1_DTDIGIT AS "+Iif(lMSSQL,"DATETIME)","DATE)")
  cSelect += "-CAST(SC7.C7_EMISSAO AS "+Iif(lMSSQL,"DATETIME","DATE")+") AS INT) LEADTIME "

  aRet := MntQuery(cSelect,cFilter)

  oCoreDash:SetQuery(aRet[1])
  oCoreDash:SetWhere(aRet[2])

  oCoreDash:SetFields(DePara())
  //oCoreDash:SetApiQstring(Self:aQueryString)
  oCoreDash:BuildJson()

	If lRet
    oCoreDash:SetPOHeader(aHeader)
		Self:SetResponse( oCoreDash:ToObjectJson())
	Else
		cError := oCoreDash:GetJsonError()
		SetRestFault( 500,  EncodeUtf8(cError) )
	EndIf

	oCoreDash:Destroy()
  FreeObj(aRet)

Return lRet

WSMETHOD GET headerItens WSSERVICE COMD030

  Local aHeader   := {}
  Local oCoreDash := CoreDash():New()
  Local oResponse	:= JsonObject():New()

  aHeader := {;
    {"pedido"     , STR0007 },; // "Pedido"  
    {"item"	      , STR0008 },; // "Item"        
    {"prod"       , STR0009 },; // "Cod. Produto"
    {"descr"      , STR0010 },; // "Descrição"
    {"quantPC"    , STR0022 },; // "Qtd.Pedido"   
    {"dtEmPC"	    , STR0011 },; // "Emissão PC"
    {"dtEntrPC"   , STR0024 },; // "Prev.Entrega"   
    {"doc"	      , STR0012 },; // "Nota Fiscal"
    {"quantNF"    , STR0023 },; // "Qtd.Recebida"  	   
    {"dtEntNF"	  , STR0013 },; // "Entrada NF"  
    {"fornec"	    , STR0014 },; // "Fornecedor"  
    {"loja"	      , STR0015 },; // "Loja"        
    {"razaoSoc"	  , STR0016 };  // "Razão Social"    
  }

  oResponse["items"]  := oCoreDash:SetPOHeader(aHeader)


  Self:SetResponse( EncodeUtf8(oResponse:ToJson()))
Return .T.

WSMETHOD GET cardInfo WSRESTFUL COMD030
  Local aFilter     := {}
  Local cFilter     := ""
  Local lRet			  := .T.
  Local nFiltro     := 0
  Local oCoreDash   := CoreDash():New()
  Local oResponse		:= JsonObject():New()

  oCoreDash:SetFields(DePara())
  oCoreDash:SetApiQstring(Self:aQueryString)
  aFilter := oCoreDash:GetApiFilter()

  For nFiltro := 1 to Len(aFilter)
    cFilter += IIf(nFiltro > 1," AND ","") + aFilter[nFiltro][1]
  Next

  RetCardInfo(@oResponse, cFilter)

  self:SetResponse(EncodeUtf8(FwJsonSerialize(oResponse, .T., .T.)))

  //-------------------------------------------------------||
  // Telemetria - Uso da classe FWLsPutAsyncInfo           ||
  // Mecanismo para registro de métricas e envio           ||
  // das mesmas ao License Serve da Totvs                  ||
  //-------------------------------------------------------||
  FWLsPutAsyncInfo("LS006",RetCodUsr(),"02","COMD030")

  oResponse := Nil
  FreeObj( oResponse )
  oCoreDash := Nil
  FreeObj( oCoreDash )
  aSize(aFilter, 0)

Return( lRet )

WSMETHOD GET fieldsInfo WSSERVICE COMD030

    Local aItems    := {}
    Local oItem
    Local oResponse := JsonObject():New()

    oItem := JsonObject():New()
    oItem["label"] :=	STR0017 //"Pedidos em Atendimento: "
    oItem["value"] :=	"totalAberto"

    AADD(aItems, oItem)

    oItem := JsonObject():New()
    oItem["label"] :=	STR0018 //"Pedidos Finalizados: "
    oItem["value"] :=	"totalFinal"

    AADD(aItems, oItem)

    oItem := JsonObject():New()
    oItem["label"] :=	STR0019 //"Total de Pedidos: "
    oItem["value"] :=	"totalPC"

    AADD(aItems, oItem)

    oItem := JsonObject():New()
    oItem["label"] :=	STR0020 //"Lead Time: "
    oItem["value"] :=	"leadTime"

    AADD(aItems, oItem)

    oResponse["items"] := aItems

    Self:SetResponse( FwHTTPEncode(oResponse:ToJson()))

Return .T.

Static Function RetCardInfo( oResponse, cWhere )
    Local aItems  := {}
    Local oItem   := JsonObject():New()
    Local nAberto := RetTotais('totalAberto',cWhere)
    Local nFinal  := RetTotais('totalFinal',cWhere) 
    Local nLead   := RetTotais('leadTime',cWhere)

    oItem["totalAberto"]  :=	nAberto
    oItem["totalFinal"]   :=	nFinal
    oItem["totalPC"]      :=	nAberto + nFinal
    oItem["leadTime"]     :=	CValToChar(nLead) + " Dias"

    AADD(aItems, oItem)

    FreeObj(oItem)

    oResponse['hasNext']    := 'false'
    oResponse["items"]      := aItems

Return Nil

Static Function MntQuery(cSelect as Char, cFilter as Char) as Array

  Local cQuery as Char
  Local cWhere as Char

  Default cSelect := " SC7.C7_NUM, SC7.C7_ITEM, SC7.C7_PRODUTO, SB1.B1_DESC, SC7.C7_QUANT, SC7.C7_EMISSAO, SC7.C7_DATPRF, SD1.D1_DOC, SD1.D1_QUANT, SD1.D1_DTDIGIT, SD1.D1_FORNECE, SD1.D1_LOJA, SA2.A2_NOME "
  Default cFilter := ""

  cQuery := " SELECT " + cSelect + " FROM " + RetSqlName("SC7") + " SC7 "
  cQuery += " INNER JOIN " + RetSqlName("SD1") + " SD1 ON "
  cQuery += " SC7.C7_FILIAL = SD1.D1_FILIAL AND "
  cQuery += " SC7.C7_NUM = SD1.D1_PEDIDO AND "
  cQuery += " SC7.C7_ITEM = SD1.D1_ITEMPC AND "
  cQuery += " SC7.D_E_L_E_T_ = SD1.D_E_L_E_T_ "
  cQuery += " INNER JOIN " + RetSqlName("SB1") + " SB1 ON SB1.B1_FILIAL = '" + xFilial("SB1") + "' AND SB1.B1_COD = C7_PRODUTO AND SB1.D_E_L_E_T_ = SC7.D_E_L_E_T_ "
  cQuery += " INNER JOIN " + RetSqlName("SA2") + " SA2 ON SA2.A2_FILIAL = '" + xFilial("SA2") + "' AND SA2.A2_COD = SD1.D1_FORNECE AND SA2.A2_LOJA = SD1.D1_LOJA AND SA2.D_E_L_E_T_ = SC7.D_E_L_E_T_ "

  cWhere := " SC7.C7_FILIAL = '" + xFilial("SC7") + "' "

  If !Empty(cFilter)
    cWhere += " AND " + cFilter
  Endif

  cWhere += " AND (SC7.C7_QUJE = SC7.C7_QUANT OR SC7.C7_RESIDUO = 'S')"
  cWhere += " AND SC7.D_E_L_E_T_ = ' '"

Return {cQuery, cWhere}

Static Function DePara()
  Local aCampos := {}
  aCampos := {;
    {"pedido"     , "SC7.C7_NUM"      },;
    {"item"	      , "SC7.C7_ITEM"     },;
    {"prod"       , "SC7.C7_PRODUTO"  },;
    {"descr"      , "SB1.B1_DESC"     },;
    {"quantPC"	  , "SC7.C7_QUANT"    },;
    {"dtEmPC"	    , "SC7.C7_EMISSAO"  },;
    {"dtEntrPC"   , "SC7.C7_DATPRF"   },;
    {"doc"	      , "SD1.D1_DOC"  	  },;
    {"quantNF"	  , "SD1.D1_QUANT" 	  },;
    {"dtEntNF"	  , "SD1.D1_DTDIGIT"  },;
    {"fornec"	    , "SD1.D1_FORNECE"  },;
    {"loja"	      , "SD1.D1_LOJA"     },;
    {"razaoSoc"	  , "SA2.A2_NOME"     },;
    {"leadTime"	  , "LEADTIME"        };
  }
Return aCampos

Static Function RetTotais(cColuna,cFilter)
Local nRet      := 0
Local aRet      := MntQuery(,cFilter)
Local cQuery    := aRet[1]
Local cWhere    := aRet[2]
Local cWhere2   := ""
Local nPos      := 0
Local cAliasQry := GetNextAlias()
Local cSelect   := ""
Local lMSSQL    := "MSSQL"$TCGetDB()

cWhere2 := StrTran(cWhere,"SC7.C7_QUJE = SC7.C7_QUANT OR SC7.C7_RESIDUO = 'S'", ;
                          "SC7.C7_QUJE < SC7.C7_QUANT AND SC7.C7_RESIDUO <> 'S'" )

If cColuna == 'totalAberto'
  cSelect := "SELECT COUNT(DISTINCT SC7.C7_NUM) TOTAL "
  cWhere := cWhere2
Elseif cColuna == 'totalFinal'  
  cSelect := "SELECT COUNT(DISTINCT SC7.C7_NUM) TOTAL "  
Elseif cColuna == 'leadTime'  
  cSelect := "SELECT ROUND(AVG(CAST(CAST(SD1.D1_DTDIGIT AS "+Iif(lMSSQL,"DATETIME)","DATE)")
  cSelect += "-CAST(SC7.C7_EMISSAO AS "+Iif(lMSSQL,"DATETIME","DATE")+") AS FLOAT)),0) TOTAL "     
Endif

nPos := At('FROM', cQuery)
cQuery := cSelect+Substr(cQuery,nPos)
cQuery += "WHERE "+cWhere
cQuery := ChangeQuery(cQuery)

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.T.,.T.)

If (cAliasQry)->(!Eof())
  nRet := (cAliasQry)->TOTAL
Endif

(cAliasQry)->(dbCloseArea())

Return nRet
