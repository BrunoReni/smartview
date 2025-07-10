#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "COMD020.CH"

//------------------------------------------------------------------------
/*/{Protheus.doc} COMD020
  API de integração de Grafico Pedidos de Compra por Fornecedor
  Solicitação de Compras x Pedido de compras

  @author		rd.santos
  @since		29/12/2020
  @version  12.1.27
  @return 	Json
/*/
//------------------------------------------------------------------------
WSRESTFUL COMD020 DESCRIPTION STR0001 // "Grafico Pedidos de Compra por Fornecedor"
	WSDATA JsonFilter       AS STRING	OPTIONAL
  WSDATA drillDownFilter  AS STRING	OPTIONAL
  WSDATA Page				      AS INTEGER	OPTIONAL
  WSDATA PageSize			    AS INTEGER	OPTIONAL

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
    DESCRIPTION STR0005 ; // "Carrega os Itens Utilizados para Montagem do itens"
    WSSYNTAX "/charts/itemsDetails/{JsonFilter}" ;
    PATH "/charts/itemsDetails";
    PRODUCES APPLICATION_JSON

ENDWSRESTFUL

//-------------------------------------------------------------------
/*/{Protheus.doc} GET form
Retorna os campos que serão apresentados no formulário.
O padrão do campo deve seguir o Dynamic Form do Portinari.

@author rd.santos
@since 29/12/2020
@version 12.1.27
/*/
//-------------------------------------------------------------------
WSMETHOD GET form WSSERVICE COMD020

  Local oResponse  := JsonObject():New()
  Local oCoreDash  := CoreDash():New()

  oCoreDash:SetPOForm(STR0006 , "charttype" , 6   , STR0006 ; // "Tipo de Gráfico"
  , .T., "string", oCoreDash:SetPOCombo({{"bar",STR0036}}))   // "Barra"
    
  oCoreDash:SetPOForm(STR0007 , "datainicio", 6   , STR0008 ; // "Datas" ## "Dt. Emissão Inicio"
  , .F., "date" )

  oCoreDash:SetPOForm(""      , "datafim"   , 6   , STR0009 ; // "Dt. Emissão Fim"
  , .F., "date" )

  oCoreDash:SetPOForm(STR0031 , "iniforn"   , 6   , STR0032 ; // "Fornecedores" ## "Fornecedor De:"
  , .F., , GetFornec(), .F.)

  oCoreDash:SetPOForm(""      , "fimforn"   , 6   , STR0033 ; // "Fornecedor Ate:"
  , .F., , GetFornec(), .F.)

  oCoreDash:SetPOForm(STR0027+'/'+STR0029 , "onlypurchaser" , 6   , STR0028 ; // "Comprador" ## "Produtos" ## "Somente Pedidos do Comprador"
  , .T., "string", oCoreDash:SetPOCombo({{"yes",STR0034},{"no",STR0035}}))    // "Sim" ## "Não"
  
  oCoreDash:SetPOForm(""      , "prodgp"    , 6   , STR0030  , .F., , GetProdGp()  , .T.) // "Grupos de Produtos"

  

  oResponse := oCoreDash:GetPOForm()

  Self:SetResponse( EncodeUtf8(oResponse:ToJson()))

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} GET form
Retorna os campos que serão apresentados no formulário.
O padrão do campo deve seguir o Dynamic Form do Portinari.

@author rd.santos
@since 29/12/2020
@version 12.1.27
/*/
//-------------------------------------------------------------------
WSMETHOD GET filterItens WSSERVICE COMD020

  Local aItem     := {}
  Local aItems    := {}
  Local oResponse	:= JsonObject():New()

  aItem := JsonObject():New()
  aItem["property"]  :=	"providerId"
  aItem["label"]     :=	STR0010 // "Fornecedor"

  AADD(aItems, aItem)

  oResponse["items"] := aItems

  Self:SetResponse( EncodeUtf8(oResponse:ToJson()))

Return .T.

WSMETHOD POST retdados WSRECEIVE JsonFilter WSSERVICE COMD020

  Local oResponse  := JsonObject():New()
  Local oCoreDash  := CoreDash():New()
  Local oJson      := JsonObject():New()

  oJson:FromJson(DecodeUtf8(Self:GetContent()))

  retDados(@oResponse, oCoreDash, oJson)

  Self:SetResponse( EncodeUtf8(oResponse:ToJson()))

  //-------------------------------------------------------||
  // Telemetria - Uso da classe FWLsPutAsyncInfo           ||
  // Mecanismo para registro de métricas e envio           ||
  // das mesmas ao License Serve da Totvs                  ||
  //-------------------------------------------------------||
  FWLsPutAsyncInfo("LS006",RetCodUsr(),"02","COMD020")

  oResponse := Nil
  FreeObj( oResponse )

  oCoreDash:Destroy()
  FreeObj( oCoreDash )

Return .T.

WSMETHOD POST itemsDetails WSRECEIVE JsonFilter, drillDownFilter WSRESTFUL COMD020

  Local aHeader     := {}
  Local aItems      := {}
  Local aRet        := {}
  Local cBody       := DecodeUtf8(Self:GetContent())
  Local cError		  := STR0012 // "Erro na Requisição"
  Local cSelect     := ""
  Local cWhere      := ""
  Local lRet			  := .T.
  Local oCoreDash   := CoreDash():New()
  Local oBody       := JsonObject():New()
  Local oJsonFilter := JsonObject():New()
  Local oJsonDD     := JsonObject():New()
  Local cDataIni    := ""
  Local cDataFim    := ""
  Local cFornDe     := ""
  Local cFornAte    := ""
  Local lPedCompr   := .F.
  Local aGrpProd    := {}
  Local nGrpProd    := 0
  Local nOutros     := 0
  Local aOutrosFor  := {}
  Local aOutrosPed  := {}        

  If !Empty(cBody)
    oBody:FromJson(cBody)

    If ValType(oBody["chartFilter"]) == "J"
      oJsonFilter := oBody["chartFilter"]

      aOutrosFor := GetForn(oJsonFilter)[3]
      aOutrosPed := GetPCForn(oJsonFilter)[3]  

      If ValType(oJsonFilter["datainicio"]) == "C" ;
      .And. ValType(oJsonFilter["datafim"]) == "C"
        cDataIni := oJsonFilter["datainicio"]
        cDataFim := oJsonFilter["datafim"]

        cDataIni := StrTran(cDataIni,'-','')
        cDataFim := StrTran(cDataFim,'-','')
      Endif

      If ValType(oJsonFilter["iniforn"]) == "C" ;
      .And. ValType(oJsonFilter["fimforn"]) == "C"
        cFornDe   := oJsonFilter["iniforn"]
        cFornAte  := oJsonFilter["fimforn"]
      Endif

      If ValType(oJsonFilter["onlypurchaser"]) == "C" ;
      .And. oJsonFilter["onlypurchaser"] == "yes"
        lPedCompr := .T.
      Endif

      If ValType(oJsonFilter["prodgp"]) == "A"
        aGrpProd := oJsonFilter["prodgp"]
      EndIf

      If ValType(oJsonFilter["level"]) == "A"
        oJsonDD := oJsonFilter["level"]
      EndIf
    EndIf        

  EndIf

  Self:SetContentType("application/json")

  If ValType(oJsonDD) == "A" .And. Len(oJsonDD) > 0 
    If Len(oJsonDD) == 1

      aHeader := {;
          {"branchDelivery", STR0041 , , , .T. , .T.     },; //"Fil.Entrega"
          {"purchaseOrder" , STR0013 , , , .T. , .T.     },; //"Pedido"        
          {"item"          , STR0014                     },; //"Item"         
          {"product"       , STR0015 , , , .T. , .T.     },; //"Produto" 
          {"descript"      , STR0016                     },; //"Desc.Produto"
          {"ValUnit"       , STR0017 , "number"  ,'1.2-5'},; //"Vlr.Unitario" 
          {"qty"           , STR0018 , "number"  ,'1.2-5'},; //"Qtde"
          {"qtyDelivery"   , STR0042 , "number"  ,'1.2-5'},; //"Qtd.Entregue"         
          {"total"         , STR0019 , "number"  ,'1.2-5'},; //"Vlr.Total"
          {"currency"      , STR0043 , , , .T. , .T.     },; //"Moeda"
          {"dateOfIssue"   , STR0021 , , , .T. , .T.     },; //"Emissão" 
          {"dateDelivery"  , STR0044 , , , .T. , .T.     },; //"Dt.Entrega"   
          {"warehouse"     , STR0020 , , , .T. , .T.     };  //"Armazem"      
        }

        aItems := {;
          {"branchDelivery", "C7_FILENT" },;
          {"purchaseOrder" , "C7_NUM"    },;
          {"item"          , "C7_ITEM"   },;
          {"product"	     , "C7_PRODUTO"},;
          {"descript"      , "B1_DESC"   },;
          {"ValUnit"       , "C7_PRECO"  },;
          {"qty"           , "C7_QUANT"  },;
          {"qtyDelivery"   , "C7_QUJE"   },;
          {"total"         , "C7_TOTAL"  },;          
          {"currency"      , "C7_MOEDA"  },;
          {"dateOfIssue"   , "C7_EMISSAO"},;
          {"dateDelivery"  , "C7_DATPRF" },;          
          {"warehouse"     , "C7_LOCAL"  };
        }

        cSelect := " C7_FILENT, C7_NUM, C7_ITEM, C7_PRODUTO, B1_DESC, C7_PRECO, C7_QUANT,"
        cSelect += " C7_QUJE, C7_TOTAL, C7_MOEDA, C7_EMISSAO, C7_DATPRF, C7_LOCAL "
        
        If oJsonDD[1]['labelDataSet'] == STR0037 .And. Len(aOutrosFor) > 0 // "Outros"
          cWhere += Iif(!Empty(cWhere)," AND ","")+" C7_FORNECE IN ("
          For nOutros := 1 To Len(aOutrosFor)
            cWhere += Iif(nOutros > 1,",","")+"'"+aOutrosFor[nOutros,1]+"'"
          Next nOutros
          cWhere += ")"          
        Else
          cWhere := " C7_FORNECE = '" + oJsonDD[1]['labelDataSet'] + "' " 
        Endif

        If !Empty(cDataIni) .And. !Empty(cDataFim)
          cWhere  += " AND C7_EMISSAO BETWEEN '"+cDataIni+"' AND '"+cDataFim+"' "
        Endif

        If !Empty(cFornDe) .And. !Empty(cFornAte)
          cWhere  += " AND C7_FORNECE BETWEEN '"+cFornDe+"' AND '"+cFornAte+"' "
        Endif

        If lPedCompr
          cWhere  += " AND C7_USER = '"+RetCodUsr()+"'"
        Endif

        If Len(aGrpProd) > 0
          cWhere += " AND B1_GRUPO IN ("
          For nGrpProd := 1 To Len(aGrpProd)
            cWhere += Iif(nGrpProd > 1,",","")+"'"+aGrpProd[nGrpProd]+"'"
          Next nGrpProd
          cWhere += ")"
        Endif

        aRet := QueryForn(cSelect, cWhere)

    Elseif Len(oJsonDD) == 2

      aHeader := {;
        {"branchDelivery", STR0041  , , , .T. , .T.     },; //"Fil.Entrega"
        {"item"          , STR0014                      },; //"Item"         
        {"product"       , STR0015  , , , .T. , .T.     },; //"Produto" 
        {"descript"      , STR0016                      },; //"Desc.Produto"
        {"ValUnit"       , STR0017  , "number"  ,'1.2-5'},; //"Vlr.Unitario" 
        {"qty"           , STR0018  , "number"  ,'1.2-5'},; //"Qtde"
        {"qtyDelivery"   , STR0042  , "number"  ,'1.2-5'},; //"Qtd.Entregue"         
        {"total"         , STR0019  , "number"  ,'1.2-5'},; //"Vlr.Total"
        {"currency"      , STR0043  , , , .T. , .T.     },; //"Moeda"
        {"dateOfIssue"   , STR0021  , , , .T. , .T.     },; //"Emissão" 
        {"dateDelivery"  , STR0044  , , , .T. , .T.     },; //"Dt.Entrega"     
        {"warehouse"     , STR0020  , , , .T. , .T.     };  //"Armazem"      
      }
      
      aItems := {;
        {"branchDelivery", "C7_FILENT" },;
        {"item"          , "C7_ITEM"   },;
        {"product"	     , "C7_PRODUTO"},;
        {"descript"      , "B1_DESC"   },;
        {"ValUnit"       , "C7_PRECO"  },;
        {"qty"           , "C7_QUANT"  },;
        {"qtyDelivery"   , "C7_QUJE"   },;
        {"total"         , "C7_TOTAL"  },;
        {"currency"      , "C7_MOEDA"  },;
        {"dateOfIssue"   , "C7_EMISSAO"},;
        {"dateDelivery"  , "C7_DATPRF" },;     
        {"warehouse"     , "C7_LOCAL"  };
      }
      
      cSelect := " C7_FILENT, C7_ITEM, C7_PRODUTO, B1_DESC, C7_PRECO, C7_QUANT,"
      cSelect += " C7_QUJE, C7_TOTAL, C7_MOEDA, C7_EMISSAO, C7_DATPRF, C7_LOCAL "
      
      If oJsonDD[1]['labelDataSet'] == STR0037 .And. Len(aOutrosFor) > 0 // "Outros"
        cWhere += Iif(!Empty(cWhere)," AND ","")+" C7_FORNECE IN ("
        For nOutros := 1 To Len(aOutrosFor)
          cWhere += Iif(nOutros > 1,",","")+"'"+aOutrosFor[nOutros,1]+"'"
        Next nOutros
        cWhere += ")"          
      Else
        cWhere := " C7_FORNECE = '" + oJsonDD[1]['labelDataSet'] + "' " 
      Endif
      
      If oJsonDD[2]['labelDataSet'] == STR0037 .And. Len(aOutrosPed) > 0 // "Outros"
        cWhere += Iif(!Empty(cWhere)," AND ","")+" C7_NUM IN ("
        For nOutros := 1 To Len(aOutrosPed)
          cWhere += Iif(nOutros > 1,",","")+"'"+aOutrosPed[nOutros,1]+"'"
        Next nOutros
        cWhere += ")"   
      Else
        cWhere += " AND C7_NUM = '" + oJsonDD[2]['labelDataSet'] + "' "
      Endif
      
      If !Empty(cDataIni) .And. !Empty(cDataFim)
        cWhere  += " AND C7_EMISSAO BETWEEN '"+cDataIni+"' AND '"+cDataFim+"' "
      Endif

      If lPedCompr
        cWhere  += " AND C7_USER = '"+RetCodUsr()+"'"
      Endif

      If Len(aGrpProd) > 0
        cWhere += " AND B1_GRUPO IN ("
        For nGrpProd := 1 To Len(aGrpProd)
          cWhere += Iif(nGrpProd > 1,",","")+"'"+aGrpProd[nGrpProd]+"'"
        Next nGrpProd
        cWhere += ")"
      Endif
      
      aRet := QueryForn(cSelect, cWhere)

    Endif
  Else
      aHeader := {;
        {"branchDelivery", STR0041 , , , .T. , .T.     },; //"Fil.Entrega"
        {"purchaseOrder" , STR0013 , , , .T. , .T.     },; //"Pedido"       
        {"item"          , STR0014                     },; //"Item"        
        {"product"       , STR0015 , , , .T. , .T.     },; //"Produto"
        {"qty"           , STR0018 , "number"  ,'1.2-5'},; //"Qtde"
        {"qtyDelivery"   , STR0042 , "number"  ,'1.2-5'},; //"Qtd.Entregue"
        {"provider"      , STR0010 , , , .T. , .T.     },; //"Fornecedor"          
        {"store"         , STR0011                     },; //"Loja"        
        {"dateOfIssue"   , STR0021                     },; //"Emissão"
        {"dateDelivery"  , STR0044 , , , .T. , .T.     }; //"Dt.Entrega"     
      }

      aItems := {;
        {"branchDelivery", "C7_FILENT"   },;
        {"purchaseOrder" , "C7_NUM"      },;
        {"item"          , "C7_ITEM"     },;        
        {"product"       , "C7_PRODUTO"  },;
        {"qty"           , "C7_QUANT"    },;
        {"qtyDelivery"   , "C7_QUJE"     },;
        {"provider"      , "C7_FORNECE"  },;
        {"store"         , "C7_LOJA"     },;
        {"dateOfIssue"   , "C7_EMISSAO"  },;
        {"dateDelivery"  , "C7_DATPRF"   };
      }

      cSelect := " C7_FILENT, C7_NUM, C7_ITEM, C7_PRODUTO, C7_QUANT,"
      cSelect += " C7_QUJE, C7_FORNECE, C7_LOJA, C7_EMISSAO, C7_DATPRF "
      
      If !Empty(cDataIni) .And. !Empty(cDataFim)
        cWhere := " C7_EMISSAO BETWEEN '"+cDataIni+"' AND '"+cDataFim+"' "
      Endif

      If !Empty(cFornDe) .And. !Empty(cFornAte)
        cWhere += Iif(!Empty(cWhere)," AND ","")+" C7_FORNECE BETWEEN '"+cFornDe+"' AND '"+cFornAte+"' "
      Endif

      If lPedCompr
        cWhere += Iif(!Empty(cWhere)," AND ","")+" C7_USER = '"+RetCodUsr()+"' "
      Endif

      If Len(aGrpProd) > 0
        cWhere += Iif(!Empty(cWhere)," AND ","")+" B1_GRUPO IN ("
        For nGrpProd := 1 To Len(aGrpProd)
          cWhere += Iif(nGrpProd > 1,",","")+"'"+aGrpProd[nGrpProd]+"'"
        Next nGrpProd
        cWhere += ")"
      Endif

      aRet := QueryCab(cSelect, cWhere)
  EndIf

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

/*Cabeçalho*/
Static Function QueryCab(cSelect as Char, cFilter as Char) as Array

  Local cQuery  := ""
  Local cWhere  := ""

  Default cSelect := " SC7.C7_NUM, SC7.C7_FORNECE, SC7.C7_LOJA, SC7.C7_EMISSAO "
  Default cFilter := ""

  cQuery += " SELECT " + cSelect + " FROM " + RetSqlName("SC7") + " SC7 "
  cQuery += " INNER JOIN " + RetSqlName("SB1") + " SB1 "
  cQuery += " ON B1_FILIAL = '" + xFilial("SB1") + "' AND B1_COD = C7_PRODUTO AND SB1.D_E_L_E_T_ = ' ' "

  cWhere := " SC7.C7_FILIAL = '" + xFilial("SC7") + "' "
  If !Empty(cFilter)
    cWhere += " AND " + cFilter
  Endif
  cWhere += " AND SC7.D_E_L_E_T_ = ' ' "

Return { cQuery, cWhere }

/*Items*/
Static Function QueryForn(cSelect as Char, cFilter as Char) as Array

  Local cQuery  := ""
  Local cWhere  := ""

  Default cSelect := " SC7.C7_NUM, SC7.C7_ITEM, SC7.C7_PRODUTO "
  Default cFilter := ""

  cQuery += " SELECT " + cSelect + " FROM " + RetSqlName("SC7") + " SC7 "
  cQuery += " INNER JOIN " + RetSqlName("SB1") + " SB1 " 
  cQuery += " ON B1_FILIAL = '" + xFilial("SB1") + "' AND B1_COD = C7_PRODUTO AND SB1.D_E_L_E_T_ = ' ' "

  cWhere := " SC7.C7_FILIAL = '" + xFilial("SC7") + "' "
  If !Empty(cFilter)
    cWhere += " AND " + cFilter
  Endif
  cWhere += " AND SC7.D_E_L_E_T_ = ' ' "

Return {cQuery, cWhere}

Static Function retDados(oResponse, oCoreDash, oJson)
  Local aData     := {}
  Local aDataFim  := {}
  Local aCab      := {}
  Local aRet      := {}
  Local nX        := 0
    
  If oJson:GetJsonText("level") == "null" .Or. Len(oJson["level"]) == 0
    
    aRet  := GetForn(oJson)
    aCab  := aRet[1]
    aData := aRet[2]  

    For nX := 1 To Len(aData)
      oCoreDash:SetChartInfo( {aData[nX,1]}, aCab[nX] , /*cType*/, aData[nX,2] /*"cColorBackground"*/ )
    Next nX

    aAdd(aDataFim, oCoreDash:SetChart(/*aCab*/{STR0038},/*aData*/,/*lCurrency*/,,/*STR0022*/)) // "Fornecedores" ## "Pedidos de Compras por Fornecedor"
  
  ElseIf Len(oJson["level"]) == 1
    
    aRet  := GetPCForn(oJson)
    aCab  := aRet[1]
    aData := aRet[2]

    For nX := 1 To Len(aData)
      oCoreDash:SetChartInfo( {aData[nX,1]}, aCab[nX] , /*cType*/, aData[nX,2] /*"cColorBackground"*/ )
    Next nX  

    aAdd(aDataFim, oCoreDash:SetChart({STR0039}/*aCab*/,/*aData*/,.T./*lCurrency*/,,STR0023)) // "Pedidos" ## "Pedidos de Compras do Fornecedor"

  ElseIf Len(oJson["level"]) == 2

    aRet  := GetPC(oJson)
    aCab  := aRet[1]
    aData := aRet[2]

    For nX := 1 To Len(aData)
      oCoreDash:SetChartInfo( {aData[nX,1]}, aCab[nX] , /*cType*/, aData[nX,2] /*"cColorBackground"*/ )
    Next nX  

    aAdd(aDataFim, oCoreDash:SetChart({STR0040}/*aCab*/,/*aData*/,.T./*lCurrency*/,,STR0024)) // "Produtos" ## "Produtos do Pedido de Compras"

  Endif

  oResponse["items"] := aDataFim

Return Nil

Static Function GetForn(oJson)
Local cDataIni    := ""
Local cDataFim    := ""
Local aCab        := {}
Local aData       := {}
Local aRet        := {}
Local cSelect     := ""
Local cWhere      := ""
Local cAliasQry   := GetNextAlias()
Local cFornDe     := ""
Local cFornAte    := ""
Local lPedCompr   := .F.
Local aGrpProd    := {}
Local nGrpProd    := 0
Local oCoreDash   := CoreDash():New()
Local aCores      := oCoreDash:GetColorChart()
Local nTOutros    := 0
Local nCor        := 0
Local aOutrosFor  := {}

If ValType(oJson) <> 'U' .And. ValType(oJson["datainicio"]) == "C" ;
.And. ValType(oJson["datafim"]) == "C"
  cDataIni := StrTran(oJson["datainicio"],'-','')
  cDataFim := StrTran(oJson["datafim"],'-','')
EndIf

If ValType(oJson["iniforn"]) == "C" ;
.And. ValType(oJson["fimforn"]) == "C"
  cFornDe   := oJson["iniforn"]
  cFornAte  := oJson["fimforn"]
Endif

If ValType(oJson["onlypurchaser"]) == "C" ;
.And. oJson["onlypurchaser"] == "yes"
  lPedCompr := .T.
Endif

If ValType(oJson["prodgp"]) == "A"
  aGrpProd := oJson["prodgp"]
EndIf

cSelect := " SC7.C7_FORNECE,COUNT(DISTINCT SC7.C7_NUM) TOTAL "
      
If !Empty(cDataIni) .And. !Empty(cDataFim)
  cWhere  += " C7_EMISSAO BETWEEN '"+cDataIni+"' AND '"+cDataFim+"' "
Endif

If !Empty(cFornDe) .And. !Empty(cFornAte)
  cWhere  += Iif(!Empty(cWhere)," AND ","")+" C7_FORNECE BETWEEN '"+cFornDe+"' AND '"+cFornAte+"' "
Endif

If lPedCompr
  cWhere  += Iif(!Empty(cWhere)," AND ","")+" C7_USER = '"+RetCodUsr()+"'"
Endif

If Len(aGrpProd) > 0
  cWhere += Iif(!Empty(cWhere)," AND ","")+" B1_GRUPO IN ("
  For nGrpProd := 1 To Len(aGrpProd)
    cWhere += Iif(nGrpProd > 1,",","")+"'"+aGrpProd[nGrpProd]+"'"
  Next nGrpProd
  cWhere += ")"
Endif

aRet := QueryCab(cSelect, cWhere)
cSelect := aRet[1]
cWhere  := aRet[2]

cSelect := cSelect+" WHERE "+cWhere
cSelect += " GROUP BY SC7.C7_FORNECE"
cSelect += " ORDER BY COUNT(DISTINCT SC7.C7_NUM) DESC"

cSelect := ChangeQuery(cSelect)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSelect),cAliasQry,.T.,.T.)

While (cAliasQry)->(!Eof())
  If Len(aCab) < Len(aCores)-1 // Reserva a última cor para os Fornecedores restantes
    nCor++ // Atualiza para próxima cor
    Aadd(aCab, (cAliasQry)->C7_FORNECE)
    Aadd(aData,{(cAliasQry)->TOTAL,aCores[nCor,3]})    
  Else
    Aadd(aOutrosFor,{(cAliasQry)->C7_FORNECE,(cAliasQry)->TOTAL})
    nTOutros += (cAliasQry)->TOTAL
  Endif
  (cAliasQry)->(DbSkip())
EndDo

If nTOutros > 0
  Aadd(aCab, STR0037) // "Outros"
  Aadd(aData,{nTOutros,aCores[Len(aCores),3]})  
Endif

(cAliasQry)->(dbCloseArea())

Return {aCab, aData, aOutrosFor}

Static Function GetPCForn(oJson)
Local cDataIni    := ""
Local cDataFim    := ""
Local aCab        := {}
Local aData       := {}
Local aRet        := {}
Local cSelect     := ""
Local cWhere      := ""
Local cAliasQry   := GetNextAlias()
Local cFornDe     := ""
Local cFornAte    := ""
Local lPedCompr   := .F.
Local aGrpProd    := {}
Local nGrpProd    := 0
Local oCoreDash   := CoreDash():New()
Local aCores      := oCoreDash:GetColorChart()
Local nTOutros    := 0
Local nCor        := 0
Local nOutros     := 0
Local aOutrosFor  := GetForn(oJson)[3]
Local aOutrosPed  := {}
Local oJsonDD     := JsonObject():New()
Local nTotalPC    := 0

If ValType(oJson["datainicio"]) == "C" ;
.And. ValType(oJson["datafim"]) == "C" 
  
  cDataIni := oJson["datainicio"]
  cDataFim := oJson["datafim"]

  cDataIni := StrTran(cDataIni,'-','')
  cDataFim := StrTran(cDataFim,'-','')
EndIf

If ValType(oJson["iniforn"]) == "C" ;
.And. ValType(oJson["fimforn"]) == "C"
  cFornDe   := oJson["iniforn"]
  cFornAte  := oJson["fimforn"]
Endif

If ValType(oJson["onlypurchaser"]) == "C" ;
.And. oJson["onlypurchaser"] == "yes"
  lPedCompr := .T.
Endif

If ValType(oJson["prodgp"]) == "A"
  aGrpProd := oJson["prodgp"]
EndIf

If ValType(oJson["level"]) == "A"
  oJsonDD := oJson["level"]
EndIf

cSelect := " C7_NUM, C7_MOEDA, C7_TXMOEDA, C7_EMISSAO, COUNT(DISTINCT C7_ITEM) ITENS, SUM(C7_TOTAL) TOTAL "

If ValType(oJsonDD) == "A" .And. Len(oJsonDD) > 0
  If oJsonDD[1]['labelDataSet'] == STR0037 .And. Len(aOutrosFor) > 0 // "Outros"
    cWhere += Iif(!Empty(cWhere)," AND ","")+" C7_FORNECE IN ("
    For nOutros := 1 To Len(aOutrosFor)
      cWhere += Iif(nOutros > 1,",","")+"'"+aOutrosFor[nOutros,1]+"'"
    Next nOutros
    cWhere += ")"          
  Else
    cWhere := " C7_FORNECE = '" + oJsonDD[1]['labelDataSet'] + "' " 
  Endif
Endif

If !Empty(cDataIni) .And. !Empty(cDataFim)
  cWhere  += Iif(Empty(cWhere),""," AND")+" C7_EMISSAO BETWEEN '"+cDataIni+"' AND '"+cDataFim+"' "
EndIf

If !Empty(cFornDe) .And. !Empty(cFornAte)
  cWhere  += Iif(Empty(cWhere),""," AND")+" C7_FORNECE BETWEEN '"+cFornDe+"' AND '"+cFornAte+"' "
Endif

If lPedCompr
  cWhere  += Iif(Empty(cWhere),""," AND")+" C7_USER = '"+RetCodUsr()+"'"
Endif

If Len(aGrpProd) > 0
  cWhere += Iif(Empty(cWhere),""," AND")+" B1_GRUPO IN ("
  For nGrpProd := 1 To Len(aGrpProd)
    cWhere += Iif(nGrpProd > 1,",","")+"'"+aGrpProd[nGrpProd]+"'"
  Next nGrpProd
  cWhere += ")"
Endif

aRet := QueryForn(cSelect, cWhere)
cSelect := aRet[1]
cWhere  := aRet[2]

cSelect := cSelect+" WHERE "+cWhere
cSelect += " GROUP BY SC7.C7_NUM, SC7.C7_MOEDA, SC7.C7_TXMOEDA, SC7.C7_EMISSAO"
cSelect += " ORDER BY SUM(C7_TOTAL) DESC"

cSelect := ChangeQuery(cSelect)

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSelect),cAliasQry,.T.,.T.)

While (cAliasQry)->(!Eof())
  
  // Calculo do Total considerando a Moeda
  If (cAliasQry)->C7_MOEDA > 1
    If (cAliasQry)->C7_TXMOEDA > 0
      nTotalPC := (cAliasQry)->TOTAL * (cAliasQry)->C7_TXMOEDA
    Else
      nTotalPC := xMoeda((cAliasQry)->TOTAL, (cAliasQry)->C7_MOEDA, 1, STOD((cAliasQry)->C7_EMISSAO), 2)
    Endif 
  Else
    nTotalPC := (cAliasQry)->TOTAL      
  Endif
  
  If Len(aCab) < Len(aCores)-1 // Reserva a última cor para os Pedidos restantes
    nCor++ // Atualiza para próxima cor
    Aadd(aCab, (cAliasQry)->C7_NUM)
    Aadd(aData,{nTotalPC,aCores[nCor,3]})    
  Else
    Aadd(aOutrosPed,{(cAliasQry)->C7_NUM,nTotalPC})
    nTOutros += nTotalPC
  Endif
  (cAliasQry)->(DbSkip())
EndDo

If nTOutros > 0
  Aadd(aCab, STR0037) // "Outros"
  Aadd(aData,{nTOutros,aCores[Len(aCores),3]})  
Endif

(cAliasQry)->(dbCloseArea())

Return {aCab, aData, aOutrosPed}

Static Function GetPC(oJson)
Local cDataIni    := ""
Local cDataFim    := ""
Local aCab        := {}
Local aData       := {}
Local aRet        := {}
Local cSelect     := ""
Local cWhere      := ""
Local cAliasQry   := GetNextAlias()
Local cFornDe     := ""
Local cFornAte    := ""
Local lPedCompr   := .F.
Local aGrpProd    := {}
Local nGrpProd    := 0
Local oCoreDash   := CoreDash():New()
Local aCores      := oCoreDash:GetColorChart()
Local nTOutros    := 0
Local nCor        := 0
Local nOutros     := 0
Local aOutrosFor  := GetForn(oJson)[3]
Local aOutrosPed  := GetPCForn(oJson)[3]
Local nTotalProd  := 0 

If ValType(oJson["datainicio"]) == "C" ;
.And. ValType(oJson["datafim"]) == "C" 
  
  cDataIni := oJson["datainicio"]
  cDataFim := oJson["datafim"]

  cDataIni := StrTran(cDataIni,'-','')
  cDataFim := StrTran(cDataFim,'-','')
EndIf

If ValType(oJson["iniforn"]) == "C" ;
.And. ValType(oJson["fimforn"]) == "C"
  cFornDe   := oJson["iniforn"]
  cFornAte  := oJson["fimforn"]
Endif

If ValType(oJson["onlypurchaser"]) == "C" ;
.And. oJson["onlypurchaser"] == "yes"
  lPedCompr := .T.
Endif

If ValType(oJson["prodgp"]) == "A"
  aGrpProd := oJson["prodgp"]
EndIf

cSelect := " C7_PRODUTO, C7_TOTAL, C7_MOEDA, C7_TXMOEDA, C7_EMISSAO "

If oJson["level"][1]['labelDataSet'] == STR0037 .And. Len(aOutrosFor) > 0 // "Outros"
  cWhere += Iif(!Empty(cWhere)," AND ","")+" C7_FORNECE IN ("
  For nOutros := 1 To Len(aOutrosFor)
    cWhere += Iif(nOutros > 1,",","")+"'"+aOutrosFor[nOutros,1]+"'"
  Next nOutros
  cWhere += ")"          
Else
  cWhere := " C7_FORNECE = '" + oJson["level"][1]['labelDataSet'] + "' " 
Endif

If oJson["level"][2]['labelDataSet'] == STR0037 .And. Len(aOutrosPed) > 0 // "Outros"
  cWhere += Iif(!Empty(cWhere)," AND ","")+" C7_NUM IN ("
  For nOutros := 1 To Len(aOutrosPed)
    cWhere += Iif(nOutros > 1,",","")+"'"+aOutrosPed[nOutros,1]+"'"
  Next nOutros
  cWhere += ")"   
Else
  cWhere += " AND C7_NUM = '" + oJson["level"][2]['labelDataSet'] + "' "
Endif

If !Empty(cDataIni) .And. !Empty(cDataFim)
  cWhere  += " AND C7_EMISSAO BETWEEN '"+cDataIni+"' AND '"+cDataFim+"' "
EndIf

If !Empty(cFornDe) .And. !Empty(cFornAte)
  cWhere  += " AND C7_FORNECE BETWEEN '"+cFornDe+"' AND '"+cFornAte+"' "
Endif

If lPedCompr
  cWhere  += " AND C7_USER = '"+RetCodUsr()+"'"
Endif

If Len(aGrpProd) > 0
  cWhere += " AND B1_GRUPO IN ("
  For nGrpProd := 1 To Len(aGrpProd)
    cWhere += Iif(nGrpProd > 1,",","")+"'"+aGrpProd[nGrpProd]+"'"
  Next nGrpProd
  cWhere += ")"
Endif

aRet := QueryForn(cSelect, cWhere)
cSelect := aRet[1]
cWhere  := aRet[2]

cSelect := cSelect+" WHERE "+cWhere
cSelect := ChangeQuery(cSelect)

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSelect),cAliasQry,.T.,.T.)

While (cAliasQry)->(!Eof())

  // Calculo do Total considerando a Moeda
  If (cAliasQry)->C7_MOEDA > 1
    If (cAliasQry)->C7_TXMOEDA > 0
      nTotalProd := (cAliasQry)->C7_TOTAL * (cAliasQry)->C7_TXMOEDA
    Else
      nTotalProd := xMoeda((cAliasQry)->C7_TOTAL, (cAliasQry)->C7_MOEDA, 1, STOD((cAliasQry)->C7_EMISSAO), 2)
    Endif 
  Else
    nTotalProd := (cAliasQry)->C7_TOTAL      
  Endif

  If Len(aCab) < Len(aCores)-1 // Reserva a última cor para os Produtos restantes
    nCor++ // Atualiza para próxima cor
    Aadd(aCab, (cAliasQry)->C7_PRODUTO)
    Aadd(aData,{nTotalProd,aCores[nCor,3]})    
  Else
    nTOutros += nTotalProd
  Endif
  (cAliasQry)->(DbSkip())
EndDo

If nTOutros > 0
  Aadd(aCab, STR0037) // "Outros"
  Aadd(aData,{nTOutros,aCores[Len(aCores),3]})  
Endif

(cAliasQry)->(dbCloseArea())

Return {aCab, aData}

// Retorna Grupos de Produtos
Static Function GetProdGp()

  Local aProdGp := {}
  Local cQuery  := ""
  Local cTemp   := GetNextAlias()
  Local oItem   := NIL
  
  cQuery := " SELECT BM_GRUPO, BM_DESC  "
  cQuery += " FROM " + RetSqlName("SBM") + " SBM " 
  cQuery += " WHERE "
  cQuery += " SBM.BM_FILIAL = '" + xFilial("SBM") + "' "
  cQuery += " AND SBM.D_E_L_E_T_ = ' ' "


  DBUseArea( .T., "TOPCONN", TCGenQry( ,, cQuery ), cTemp, .F., .T. )

  While (cTemp)->( !Eof() )
      oItem := JsonObject():New()
      oItem["label"] := (cTemp)->BM_DESC
      oItem["value"] := (cTemp)->BM_GRUPO
      aAdd( aProdGp, oItem)
     (cTemp)->(DbSkip())
  EndDo

  (cTemp)->( DBCloseArea() )

Return aProdGp

// Retorna código de Fornecedores para Filtro
Static Function GetFornec()
Local aFornec     := {}
Local aRet        := {}
Local cSelect     := ""
Local cWhere      := ""
Local cAliasQry   := GetNextAlias()
Local oItem       := NIL

cSelect := " DISTINCT SC7.C7_FORNECE, SA2.A2_NOME "
      
aRet := QueryCab(cSelect, cWhere)
cSelect := aRet[1]
cWhere  := aRet[2]

cSelect += " INNER JOIN "+ RetSqlName("SA2") + " SA2 ON SA2.A2_FILIAL = '"+xFilial("SA2")+"'"
cSelect += " AND SA2.A2_COD = SC7.C7_FORNECE AND SA2.A2_LOJA = SC7.C7_LOJA AND SA2.D_E_L_E_T_ = SC7.D_E_L_E_T_"
cSelect += " WHERE "+cWhere

cSelect := ChangeQuery(cSelect)

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSelect),cAliasQry,.T.,.T.)

// Item em Branco caso não queira utilizar esse Filtro
oItem := JsonObject():New()
oItem["label"] := " - "
oItem["value"] := ""
Aadd(aFornec, oItem)

While (cAliasQry)->(!Eof())
  oItem := JsonObject():New()
  oItem["label"] := (cAliasQry)->C7_FORNECE + " - " + (cAliasQry)->A2_NOME
  oItem["value"] := (cAliasQry)->C7_FORNECE
  Aadd(aFornec, oItem)
  (cAliasQry)->(DbSkip())
EndDo

(cAliasQry)->(dbCloseArea())

Return aFornec
