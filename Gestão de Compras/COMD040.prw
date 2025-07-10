#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "COMD040.CH"
 
//------------------------------------------------------------------------
/*/{Protheus.doc} COMD040
  API - Grafico de Devolução de Documentos de Entrada por Periodo

  @author		rd.santos
  @since		14/01/2021
  @version  12.1.27
  @return 	Json
/*/
//------------------------------------------------------------------------
WSRESTFUL COMD040 DESCRIPTION STR0001 // "Gráfico de Devolução de Documentos de Entrada por Período"

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

WSMETHOD GET form WSSERVICE COMD040

  Local oResponse  := JsonObject():New()
  Local oCoreDash  := CoreDash():New()

  oCoreDash:SetPOForm(STR0006, "charttype"       , 6   , STR0006 ,.T.,; // "Tipo de Gráfico"
  "string", oCoreDash:SetPOCombo({{"line",STR0008}, {"bar",STR0009}}))  // "Linha" # "Barra"
  
  oCoreDash:SetPOForm(""     , "datadereferencia", 6   , STR0007  , .F., "date") // "Data de Referência"

  oResponse  := oCoreDash:GetPOForm()

  Self:SetResponse( EncodeUtf8(oResponse:ToJson()))

Return .T.

WSMETHOD GET filterItens WSSERVICE COMD040

  Local aItem     := {}
  Local aItems    := {}
  Local oResponse	:= JsonObject():New()

  aItem := JsonObject():New()
  aItem["property"] :=	"vendorId"
  aItem["label"]    :=	STR0010 // "Fornecedor"

  AADD(aItems, aItem)

  aItem := JsonObject():New()
  aItem["property"] :=	"vendorStore"
  aItem["label"]    :=	STR0011 // "Loja"

  AADD(aItems, aItem)

  oResponse["items"] := aItems

  Self:SetResponse( EncodeUtf8(oResponse:ToJson()))

Return .T.

WSMETHOD POST retdados WSRECEIVE JsonFilter WSSERVICE COMD040

  Local oResponse   := JsonObject():New()
  Local oCoreDash   := CoreDash():New()
  Local oJson       := JsonObject():New()
  Local oJsonParam  := JsonObject():New()
  Local cDataRef    := ""

  oJson:FromJson(DecodeUtf8(Self:GetContent()))

  If ValType(oJson) <> 'U' .And. ValType(oJson["datadereferencia"]) == "C"
    cDataRef := StrTran(oJson["datadereferencia"],'-','')
  Else
    cDataRef := DTOS(dDataBase)
  EndIf

  retDados(@oResponse, oCoreDash, oJson, cDataRef)

  Self:SetResponse( EncodeUtf8(oResponse:ToJson()))

  //-------------------------------------------------------||
  // Telemetria - Uso da classe FWLsPutAsyncInfo           ||
  // Mecanismo para registro de métricas e envio           ||
  // das mesmas ao License Serve da Totvs                  ||
  //-------------------------------------------------------||
  FWLsPutAsyncInfo("LS006",RetCodUsr(),"02","COMD040")

  oResponse := Nil
  FreeObj( oResponse )

  oCoreDash:Destroy()
  FreeObj( oCoreDash )

  oJsonParam := Nil
  FreeObj(oJsonParam)

Return .T.

WSMETHOD POST itemsDetails WSRECEIVE JsonFilter, drillDownFilter WSRESTFUL COMD040

  Local aHeader     := {}
  Local aItems      := {}
  Local aRet        := {}
  Local cBody       := DecodeUtf8(Self:GetContent())
  Local cError		  := STR0012 // "Erro na Requisição"
  Local cSelect     := ""
  Local cFilter     := ""
  Local lRet			  := .T.
  Local oCoreDash   := CoreDash():New()
  Local oBody       := JsonObject():New()
  Local oJsonFilter := JsonObject():New()
  Local oJsonDD     := JsonObject():New()
  Local cDataRef    := ""
  Local lMSSQL      := "MSSQL"$TCGetDB()

  If !Empty(cBody)
    oBody:FromJson(cBody)

    If ValType(oBody["chartFilter"]) == "J"
      oJsonFilter := oBody["chartFilter"]

      If ValType(oJsonFilter["datadereferencia"]) == "C" 
        cDataRef := oJsonFilter["datadereferencia"]        
        cDataRef := StrTran(cDataRef,'-','')
      Endif
    EndIf

    If ValType(oBody["detailFilter"]) == "A"
      oJsonDD := oBody["detailFilter"]
    EndIf

  EndIf

  If Empty(cDataRef)
    cDataRef := DTOS(dDatabase)
  Endif

  Self:SetContentType("application/json")

  If oJsonFilter:GetJsonText("level") == "null" .Or. Len(oJsonFilter["level"]) == 0
    If Len(oJsonDD) == 0
      aHeader := {;
        {"F1_DOC"     , STR0013 ,"link" },; // "Documento"  
        {"F1_SERIE"	  , STR0014         },; // "Série"     
        {"F1_FORNECE" , STR0010         },; // "Fornecedor"
        {"F1_LOJA"    , STR0011         },; // "Loja"      
        {"F1_FORMUL"  , STR0015         };  // "Formulário"
      }

      aItems := {;
        {"F1_DOC"     , "F1_DOC"      },;
        {"F1_SERIE"	  , "F1_SERIE"    },;
        {"F1_FORNECE" , "F1_FORNECE"  },;
        {"F1_LOJA"    , "F1_LOJA"     },;
        {"F1_FORMUL"  , "F1_FORMUL"   };
      }

      cFilter += Iif(lMSSQL," SUBSTRING"," SUBSTR")+"(SF1.F1_EMISSAO,1,4) = '"+Substr(cDataRef,1,4)+"' "
      cFilter += " AND (SD1.D1_QTDEDEV > 0 OR SF1.F1_TIPO = 'D') "

      aRet := QryDocEnt(/*cSelect*/,cFilter,/*cGroup*/,.T., .F.)

    Elseif Len(oJsonDD) == 1

      aHeader := {;
          {"D1_ITEM"    , STR0016 },; // "Item"         
          {"D1_COD"     , STR0017 },; // "Produto"      
          {"B1_DESC"    , STR0018 },; // "Descrição"    
          {"D1_VUNIT"   , STR0019 },; // "Vlr.Unitário" 
          {"D1_QUANT"   , STR0020 },; // "Quantidade"   
          {"D1_TOTAL"   , STR0021 },; // "Vlr.Total"    
          {"D1_QTDEDEV" , STR0022 },; // "Qtd.Devolvida"
          {"D1_VALDEV"  , STR0023 };  // "Vlr.Devolvido"
        }

        aItems := {;
          {"D1_ITEM"      , "D1_ITEM"   },;
          {"D1_COD"	      , "D1_COD"    },;
          {"B1_DESC"      , "B1_DESC"   },;
          {"D1_VUNIT"     , "D1_VUNIT"  },;
          {"D1_QUANT"     , "D1_QUANT"  },;
          {"D1_TOTAL"     , "D1_TOTAL"  },;
          {"D1_QTDEDEV"   , "D1_QTDEDEV"},;
          {"D1_VALDEV"    , "D1_VALDEV" };
        }

        cSelect := " SD1.D1_ITEM, SD1.D1_COD, SB1.B1_DESC, SD1.D1_QUANT, SD1.D1_QTDEDEV, SD1.D1_VUNIT, SD1.D1_TOTAL, SD1.D1_VALDEV "
        
        cFilter := " SF1.F1_DOC = '" + Padr(oJsonDD[1]['F1_DOC'],TamSX3("F1_DOC")[1]) + "' AND "
        cFilter += " SF1.F1_SERIE = '" + Padr(oJsonDD[1]['F1_SERIE'],TamSX3("F1_SERIE")[1]) + "' "
        cFilter += " AND (SD1.D1_QTDEDEV > 0 OR SF1.F1_TIPO = 'D') "
        cFilter += " AND "+Iif(lMSSQL,"SUBSTRING","SUBSTR")+"(SF1.F1_EMISSAO,1,4) = '"+Substr(cDataRef,1,4)+"' "
                
        aRet := QryDocEnt(cSelect,cFilter,/*cGroup*/,.T., .T.)
    Endif
  ElseIf Len(oJsonFilter["level"]) == 1
    If Len(oJsonDD) == 0
          aHeader := {;
          {"D1_DOC"    , STR0013 },; // "Documento" 
          {"D1_SERIE"  , STR0014 },; // "Série"     
          {"D1_FORNECE", STR0010 },; // "Fornecedor"
          {"D1_LOJA"   , STR0011 },; // "Loja"      
          {"D1_ITEM"   , STR0016 },; // "Item"      
          {"D1_COD"    , STR0017 },; // "Produto"   
          {"B1_DESC"   , STR0018 },; // "Descrição" 
          {"D1_QUANT"  , STR0020 };  // "Quantidade"
        }

        aItems := {;
          {"D1_DOC"    , "D1_DOC"     },;
          {"D1_SERIE"  , "D1_SERIE"   },;
          {"D1_FORNECE", "D1_FORNECE" },;
          {"D1_LOJA"   , "D1_LOJA"    },;
          {"D1_ITEM"   , "D1_ITEM"    },;
          {"D1_COD"	   , "D1_COD"     },;
          {"B1_DESC"   , "B1_DESC"    },;
          {"D1_QUANT"  , "D1_QUANT"   };
        }

        cSelect := " SD1.D1_DOC, SD1.D1_SERIE, SD1.D1_ITEM, SD1.D1_COD, SB1.B1_DESC, SD1.D1_QUANT "
        
        If ValType(oJsonFilter["level"][1]['label']) == "C"
          cMes := oJsonFilter["level"][1]['label']
          cMes := Substr(cMes,4,4)+Substr(cMes,1,2)

          cFilter += Iif(lMSSQL," SUBSTRING"," SUBSTR")+"(SF1.F1_EMISSAO,1,6) = '"+cMes+"'"
        Else
          cFilter += Iif(lMSSQL," SUBSTRING"," SUBSTR")+"(SF1.F1_EMISSAO,1,4) = '"+Substr(cDataRef,1,4)+"' "
        Endif
        cFilter += " AND (SD1.D1_QTDEDEV > 0 OR SF1.F1_TIPO = 'D') "

        aRet := QryDocEnt(cSelect,cFilter,,.T.,.T.)
    Endif
  Endif

  oCoreDash:SetQuery(aRet[1])
  oCoreDash:SetWhere(aRet[2])
  oCoreDash:SetGroupBy(aRet[3])
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

Static Function retDados(oResponse, oCoreDash, oJson, cDataRef)
  Local aData     := {}
  Local aDataFim  := {}
  Local aCab      := {}
  Local aRet      := {}
  Local cRedLht   := "rgba(227, 73, 64, 1)"
  Local cGreenLht := "rgba(  0,201,161, 1)"
  
  If oJson:GetJsonText("level") == "null" .Or. Len(oJson["level"]) == 0
    
    aRet  := GetPeriodo(cDataRef)
    aCab  := aRet[1]
    aData := aRet[2] 

    oCoreDash:SetChartInfo( aData, STR0024 , /*cType*/, cRedLht /*"cColorBackground"*/ )  // "Documentos" 
    aAdd(aDataFim, oCoreDash:SetChart(aCab,/*aData*/,/*lCurrency*/,,/*STR0025*/))             // "Devoluções por Período"

  ElseIf Len(oJson["level"]) == 1
    
    aRet  := GetProdutos(cDataRef,oJson)
    aCab  := aRet[1]
    aData := aRet[2] 

    oCoreDash:SetChartInfo( aData, STR0026 , /*cType*/, cGreenLht /*"cColorBackground"*/ )  // "Produtos"
    aAdd(aDataFim, oCoreDash:SetChart(aCab,/*aData*/,/*lCurrency*/,,STR0027))               // "Produtos por Período"

  Endif

  oResponse["items"] := aDataFim

Return Nil

Static Function GetPeriodo(cDataRef)

Local aData     := Array(12)
Local aCab      := {}
Local nMes      := 0
Local cAno      := ""
Local cAliasQry := GetNextAlias()
Local cSelect   := ""
Local cWhere    := ""
Local lMSSQL    := "MSSQL"$TCGetDB()

Default cDataRef := DTOS(dDatabase)

cAno := Substr(cDataRef,1,4)

For nMes := 1 To 12
  aAdd(aCab, StrZero(nMes,2)+'/'+cAno)  
Next

Afill(aData,0)

cSelect := Iif(lMSSQL," SUBSTRING"," SUBSTR")+"(SF1.F1_EMISSAO,1,6) MESANO, COUNT(DISTINCT SF1.F1_DOC) TOTAL "

cWhere += Iif(lMSSQL," SUBSTRING"," SUBSTR")+"(SF1.F1_EMISSAO,1,4) = '"+cAno+"' "

aRet := QryDocEnt(cSelect, cWhere,,.T.)
cSelect := aRet[1]
cWhere  := aRet[2]

cSelect := cSelect+" WHERE "+cWhere+" GROUP BY "+Iif(lMSSQL,"SUBSTRING","SUBSTR")+"(SF1.F1_EMISSAO,1,6)"
cSelect := ChangeQuery(cSelect)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSelect),cAliasQry,.T.,.T.)

While (cAliasQry)->(!Eof())
  aData[Val(Substr((cAliasQry)->MESANO,5,2))] := (cAliasQry)->TOTAL
  (cAliasQry)->(DbSkip())
EndDo

(cAliasQry)->(dbCloseArea())

Return {aCab,aData}

Static Function GetProdutos(cDataRef,oJson)

Local aData     := {}
Local aCab      := {}
Local cAno      := ""
Local cAliasQry := GetNextAlias()
Local cSelect   := ""
Local cWhere    := ""
Local lMSSQL    := "MSSQL"$TCGetDB()
Local cMes      := ""

Default cDataRef := DTOS(dDatabase)

cAno := Substr(cDataRef,1,4)

If ValType(oJson["level"][1]['label']) == "C"
  cMes := oJson["level"][1]['label']
  cMes := Substr(cMes,4,4)+Substr(cMes,1,2)
Endif

cSelect := " SD1.D1_COD, SUM(SD1.D1_QUANT) TOTAL"

If !Empty(cMes)
  cWhere += Iif(lMSSQL," SUBSTRING"," SUBSTR")+"(SF1.F1_EMISSAO,1,6) = '"+cMes+"'"
Endif

aRet := QryDocEnt(cSelect, cWhere,,.T.)
cSelect := aRet[1]
cWhere  := aRet[2]

cSelect := cSelect+" WHERE "+cWhere+" GROUP BY SD1.D1_COD "
cSelect := ChangeQuery(cSelect)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSelect),cAliasQry,.T.,.T.)

While (cAliasQry)->(!Eof())
  Aadd(aCab, (cAliasQry)->D1_COD)
  Aadd(aData,(cAliasQry)->TOTAL)
  
  (cAliasQry)->(DbSkip())
EndDo

(cAliasQry)->(dbCloseArea())

Return {aCab,aData}

Static Function QryDocEnt(cSelect as Char, cFilter as Char, cGroup as Char, lItems as logical, lDescPro as Logical) as Array

  Local cQuery as Char
  Local cWhere as Char

  Default cSelect := " SF1.F1_DOC, SF1.F1_SERIE, SF1.F1_FORNECE, SF1.F1_LOJA, SF1.F1_FORMUL "
  Default cFilter := ""
  Default cGroup  := ""
  Default lItems  := .F.
  Default lDescPro := .F.

  cQuery := " SELECT " + cSelect + " FROM " + RetSqlName("SF1") + " SF1 "

  If lItems
    cQuery += " INNER JOIN " + RetSqlName("SD1") + " SD1 ON "
    cQuery += " SD1.D1_FILIAL = SF1.F1_FILIAL AND "
    cQuery += " SD1.D1_DOC = SF1.F1_DOC AND "
    cQuery += " SD1.D1_SERIE = SF1.F1_SERIE AND "
    cQuery += " SD1.D1_FORNECE = SF1.F1_FORNECE AND "
    cQuery += " SD1.D1_LOJA = SF1.F1_LOJA AND "
    cQuery += " SD1.D1_FORMUL = SF1.F1_FORMUL AND "
    cQuery += " SD1.D_E_L_E_T_ = SF1.D_E_L_E_T_ "

    If lDescPro
        cQuery += " INNER JOIN " + RetSqlName("SB1") + " SB1 ON B1_FILIAL = '" + xFilial("SB1") + "'"
        cQuery += " AND B1_COD = SD1.D1_COD AND SB1.D_E_L_E_T_ = SD1.D_E_L_E_T_ "
    Endif
  Endif

  cWhere := " SF1.F1_FILIAL = '" + xFilial("SF1") + "' "
  cWhere += " AND (SD1.D1_QTDEDEV > 0 OR SF1.F1_TIPO = 'D') "

  If !Empty(cFilter)
    cWhere += " AND " + cFilter
  
  Endif
  cWhere += " AND SF1.D_E_L_E_T_ = ' ' "  

  If Empty(cGroup)
    cGroup := cSelect
  Endif

Return {cQuery, cWhere, cGroup}
