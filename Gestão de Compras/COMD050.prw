#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "COMD050.CH"

//------------------------------------------------------------------------
/*/{Protheus.doc} COMD050
  API - Gráfico de Pedidos de Compra em Atraso

  @author		rd.santos
  @since		20/01/2021
  @version  12.1.27
  @return 	Json
/*/
//------------------------------------------------------------------------
WSRESTFUL COMD050 DESCRIPTION STR0001 // "Gráfico de Pedidos de Compra em Atraso"

  WSDATA JsonFilter       AS STRING	 OPTIONAL
  WSDATA drillDownFilter  AS STRING	 OPTIONAL
  WSDATA Page				      AS INTEGER OPTIONAL
  WSDATA PageSize			    AS INTEGER OPTIONAL

  WSMETHOD GET form ;
    DESCRIPTION STR0002 ; // "Carrega os campos que serão apresentados no formulário"
    WSSYNTAX "/charts/form/" ;
    PATH "/charts/form";
    PRODUCES APPLICATION_JSON

  WSMETHOD GET filterItens ;
    DESCRIPTION STR0003 ; // "Carrega os filtros utilizados"
    WSSYNTAX "/charts/filterItens/" ;
    PATH "/charts/filterItens";
    PRODUCES APPLICATION_JSON

  WSMETHOD POST retdados ;
    DESCRIPTION STR0004 ; // "Carrega os itens"
    WSSYNTAX "/charts/retdados/{JsonFilter}" ;
    PATH "/charts/retdados";
    PRODUCES APPLICATION_JSON

  WSMETHOD POST itemsDetails ;
    DESCRIPTION STR0005 ; // "Carrega os Itens Utilizados para Montagem dos detalhes"
    WSSYNTAX "/charts/itemsDetails/{JsonFilter}" ;
    PATH "/charts/itemsDetails";
    PRODUCES APPLICATION_JSON

ENDWSRESTFUL

WSMETHOD GET form WSSERVICE COMD050

  Local oResponse  := JsonObject():New()
  Local oCoreDash  := CoreDash():New()

  oCoreDash:SetPOForm(STR0006 , "charttype"     , 6 , STR0006 ; // "Tipo de Gráfico"
  , .T., "string" , oCoreDash:SetPOCombo({{"gauge",STR0007}}))  // "Gauge"
  
  oCoreDash:SetPOForm(STR0008 , "datainicio"    , 6 , STR0009 ; // "Período" ## "Data de"         
  , .F., "date"   )
  
  oCoreDash:SetPOForm(""      , "datafim"       , 6 , STR0010 ; // "Data até"        
  , .F., "date"   )

  oResponse  := oCoreDash:GetPOForm()

  Self:SetResponse( EncodeUtf8(oResponse:ToJson()))

Return .T.

WSMETHOD GET filterItens WSSERVICE COMD050

  Local aItem     := {}
  Local aItems    := {}
  Local oResponse	:= JsonObject():New()

  aItem := JsonObject():New()
  aItem["property"] := "vendorId"
  aItem["label"]    := STR0011 // "Fornecedor"

  AADD(aItems, aItem)

  aItem := JsonObject():New()
  aItem["property"] := "vendorStore"
  aItem["label"]    := STR0012 // "Loja"

  AADD(aItems, aItem)

  oResponse["items"] := aItems

  Self:SetResponse( EncodeUtf8(oResponse:ToJson()))

Return .T.

WSMETHOD POST retdados WSRECEIVE JsonFilter WSSERVICE COMD050

  Local oResponse   := JsonObject():New()
  Local oCoreDash   := CoreDash():New()
  Local oJson       := JsonObject():New()
  Local oJsonParam  := JsonObject():New()
  Local dDataIni    := FirstYDate(dDatabase)
  Local dDataFim    := LastYDate(dDatabase)

  oJson:FromJson(DecodeUtf8(Self:GetContent()))
  
  If ValType(oJson["datainicio"]) == "C" .And. ValType(oJson["datafim"]) == "C"
    dDataIni := STOD(StrTran(oJson["datainicio"],'-',''))
    dDataFim := STOD(StrTran(oJson["datafim"],'-',''))
  Endif

  retDados(@oResponse, oCoreDash, oJson, dDataIni, dDataFim)

  Self:SetResponse( EncodeUtf8(oResponse:ToJson()))

  //-------------------------------------------------------||
  // Telemetria - Uso da classe FWLsPutAsyncInfo           ||
  // Mecanismo para registro de métricas e envio           ||
  // das mesmas ao License Serve da Totvs                  ||
  //-------------------------------------------------------||
  FWLsPutAsyncInfo("LS006",RetCodUsr(),"02","COMD050")

  oResponse := Nil
  FreeObj( oResponse )

  oCoreDash:Destroy()
  FreeObj( oCoreDash )

  oJsonParam := Nil
  FreeObj(oJsonParam)

Return .T.

WSMETHOD POST itemsDetails WSRECEIVE JsonFilter, drillDownFilter WSRESTFUL COMD050

  Local aHeader     := {}
  Local aItems      := {}
  Local aRet        := {}
  Local cBody       := DecodeUtf8(Self:GetContent())
  Local cError		  := STR0013 // "Erro na Requisição"
  Local cSelect     := ""
  Local cFilter     := ""
  Local lRet			  := .T.
  Local oCoreDash   := CoreDash():New()
  Local oBody       := JsonObject():New()
  Local oJsonFilter := JsonObject():New()
  Local oJsonDD     := JsonObject():New()
  Local dDataIni    := FirstYDate(dDatabase)
  Local dDataFim    := LastYDate(dDatabase)
  Local lMSSQL      := "MSSQL"$TCGetDB()

  If !Empty(cBody)
    oBody:FromJson(cBody)

    If ValType(oBody["chartFilter"]) == "J"
      oJsonFilter := oBody["chartFilter"]
      
      If ValType(oJsonFilter["datainicio"]) == "C" .And. ValType(oJsonFilter["datafim"]) == "C"
        dDataIni := STOD(StrTran(oJsonFilter["datainicio"],'-',''))
        dDataFim := STOD(StrTran(oJsonFilter["datafim"],'-',''))
      Endif
    EndIf

    If ValType(oBody["detailFilter"]) == "A"
      oJsonDD := oBody["detailFilter"]
    EndIf

  EndIf

  Self:SetContentType("application/json")

  If oJsonFilter:GetJsonText("level") == "null" .Or. Len(oJsonFilter["level"]) == 0
    If Len(oJsonDD) == 0
      aHeader := {;
        {"C7_NUM"     , STR0014 , , , .T. , .T.   },; // "Pedido"        
        {"C7_ITEM"    , STR0015                   },; // "Item"          
        {"C7_PRODUTO" , STR0016 , , , .T. , .T.   },; // "Produto"       
        {"B1_DESC"    , STR0017                   },; // "Descrição"     
        {"C7_FORNECE" , STR0011 , , , .T. , .T.   },; // "Fornecedor"    
        {"C7_LOJA"    , STR0012                   },; // "Loja"          
        {"A2_NOME"    , STR0018                   },; // "Razão Social"  
        {"C7_EMISSAO" , STR0019                   },; // "Dt.Emissão"    
        {"C7_DATPRF"  , STR0020                   },; // "Dt.Entrega"    
        {"ATRASO"     , STR0021                   };  // "Dias em Atraso"
      }

      aItems := {;
        {"C7_NUM"     , "C7_NUM"      },;
        {"C7_ITEM"    , "C7_ITEM"     },;
        {"C7_PRODUTO" , "C7_PRODUTO"  },;
        {"B1_DESC"    , "B1_DESC"     },;
        {"C7_FORNECE"	, "C7_FORNECE"  },;
        {"C7_LOJA"    , "C7_LOJA"     },;
        {"A2_NOME"    , "A2_NOME"     },;
        {"C7_EMISSAO" , "C7_EMISSAO"  },;
        {"C7_DATPRF"  , "C7_DATPRF"   },;
        {"ATRASO"     , "ATRASO"      };
      }

      cSelect := " DISTINCT SC7.C7_NUM,SC7.C7_ITEM, SC7.C7_PRODUTO,SB1.B1_DESC, "
      cSelect += "SC7.C7_FORNECE,SC7.C7_LOJA,SA2.A2_NOME, SC7.C7_EMISSAO,SC7.C7_DATPRF," 
      cSelect += " CAST("+Iif(lMSSQL,"GETDATE()","CURRENT_DATE")
      cSelect += "-CAST(SC7.C7_DATPRF AS "+Iif(lMSSQL,"DATETIME","DATE")+") AS INT) ATRASO "
      
      cFilter := "C7_EMISSAO BETWEEN '" + DTos(dDataIni) + "' AND '"+ DTos(dDataFim) + "'"
      
      aRet    := QuerySC7(cSelect, cFilter, /*cGroup*/, .T., .T., .T.)
    
    Endif
  Endif

  oCoreDash:SetQuery(aRet[1])
  oCoreDash:SetWhere(aRet[2])
  oCoreDash:SetFields(aItems)
  oCoreDash:SetApiQstring(Self:aQueryString)
  oCoreDash:BuildJson()

	If lRet
    oCoreDash:SetPOHeader(aHeader)
		Self:SetResponse( oCoreDash:ToObjectJson() )
	Else
		cError := oCoreDash:GetJsonError()
		SetRestFault( 500,  EncodeUtf8(cError) )
	EndIf

  oCoreDash:Destroy()
  FreeObj(oJsonDD)
  FreeObj(oJsonFilter)
  FreeObj(oBody)

  aSize(aRet, 0)
  aSize(aItems, 0)
  aSize(aHeader, 0)

Return lRet

Static Function retDados(oResponse, oCoreDash, oJson, dDataIni, dDataFim)
  Local aData    := {}
  Local aDataFim := {}
  Local aCab     := {}

  aCab := {STR0022} // "Total em Atraso"

  oData   := JsonObject():New()

  aData   := { GetOrders( dDataIni, dDataFim ) }

  aDataFim := {}
  aAdd(aDataFim, oCoreDash:SetChart(aCab, aData,/*lCurrency*/))

  oResponse["items"] := aDataFim

Return Nil

Static Function GetOrders( dDataIni, dDataFim )

  Local cTempSC7  := GetNextAlias()
  Local cTempTot  := GetNextAlias()
  Local nQtd      := 0
  Local nTotal    := 0
  Local nPerc     := 0
  Local aQuerySC7 := {}

  Default dDataIni    := FirstYDate(dDatabase)
  Default dDataFim    := LastYDate(dDatabase)

  aQuerySC7 := QuerySC7("COUNT(DISTINCT C7_NUM) TOTAL", "C7_EMISSAO BETWEEN '" + DTos(dDataIni) + "' AND '"+ DTos(dDataFim) + "'",/*"C7_NUM "*/,.F.,.F.)
  cQuery    := aQuerySC7[1]
  cQuery    += " WHERE " + aQuerySC7[2]
  
  MPSysOpenQuery( cQuery , cTempTot )

  nTotal := (cTempTot)->TOTAL
 
  (cTempTot)->(DbCloseArea())


  aQuerySC7 := QuerySC7("COUNT(DISTINCT C7_NUM) ATRASO", "C7_EMISSAO BETWEEN '" + DTos(dDataIni) + "' AND '"+ DTos(dDataFim) + "'",""/*" C7_NUM "*/,.T.,.T.)

  cQuery    := aQuerySC7[1]
  cQuery    += " WHERE " + aQuerySC7[2]
  
  MPSysOpenQuery( cQuery , cTempSC7 )

  nQtd := (cTempSC7)->ATRASO

  (cTempSC7)->(DbCloseArea())


  nPerc := (nQtd * 100) / nTotal  

Return nPerc

Static Function QuerySC7(cSelect as Char, cFilter as Char, cGroup as Char, lFornece as Logical, lAbertos as Logical, lProduto as Logical) as Array

  Local cQuery as Char
  Local cWhere as Char

  Default cSelect   := " SC7.C7_NUM, SC7.C7_ITEM, SC7.C7_SEQUEN, SC7.C7_ITEMGRD "
  Default cFilter   := ""
  Default cGroup    := ""
  Default lFornece  := .F.
  Default lAbertos  := .T.
  Default lProduto  := .F.

  cQuery := " SELECT " + cSelect + " FROM " + RetSqlName("SC7") + " SC7 "

  If lFornece
    cQuery += " INNER JOIN " + RetSqlName("SA2") + " SA2 "
    cQuery += " ON SA2.A2_FILIAL = '" + xFilial("SA2") + "' "
    cQuery += " AND SA2.A2_COD = SC7.C7_FORNECE "
    cQuery += " AND SA2.A2_LOJA = SC7.C7_LOJA "
    cQuery += " AND SA2.D_E_L_E_T_ = ' ' "
  Endif

  If lProduto
    cQuery += " INNER JOIN " + RetSqlName("SB1") + " SB1 "
    cQuery += " ON SB1.B1_FILIAL = '" + xFilial("SB1") + "' "
    cQuery += " AND SB1.B1_COD = SC7.C7_PRODUTO "
    cQuery += " AND SA2.D_E_L_E_T_ = ' ' "
  Endif

  cWhere := " SC7.C7_FILIAL = '" + xFilial("SC7") + "' "
  If !Empty(cFilter)
    cWhere += " AND " + cFilter
  Endif

  If  lAbertos
    cWhere += " AND SC7.C7_QUANT > SC7.C7_QUJE "
    cWhere += " AND SC7.C7_DATPRF < '" + DToS(dDatabase) + "' "
    cWhere += " AND SC7.C7_RESIDUO <> 'S' "
  Endif

  cWhere += " AND SC7.D_E_L_E_T_ = ' ' "

  If Empty(cGroup)
    cGroup := cSelect
  Endif

Return {cQuery, cWhere, cGroup}
