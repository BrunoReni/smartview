#Include "Protheus.ch"
#Include "TopConn.ch" 
	
/*/{Protheus.doc} MATR103D
Relatório - Documentos Desacordo                     
@since 04/12/2020
/*/
	
Function MATR103D()

Local aArea   := GetArea()
Local oReport

Private cPerg := "MTR103D"

oReport := fReportDef()
oReport:PrintDialog()

RestArea(aArea)

Return

/*/{Protheus.doc} fReportDef
Relatório - Documentos Desacordo                     
@since 04/12/2020
/*/

Static Function fReportDef()

Local oReport
Local oSectDad	:= Nil
Local cAliasQry	:= GetNextAlias()

//Criação do componente de impressão
oReport := TReport():New(	"MATR103D",;					//Nome do Relatório
							"Relatorio",;					//Título
							cPerg,;							//Pergunte
							{|oReport| fRepPrint(oReport,cAliasQry)},;//Bloco de código que será executado na confirmação da impressão
							)		//Descrição
oReport:SetTotalInLine(.F.)
oReport:lParamPage := .F.
oReport:oPage:SetPaperSize(9) //Folha A4
oReport:SetPortrait()

//Criando a seção de dados
oSectDad := TRSection():New( oReport,;		//Objeto TReport que a seção pertence
							 "Dados",;		//Descrição da seção
							 {cAliasQry})	//Tabelas utilizadas, a primeira será considerada como principal da seção
oSectDad:SetTotalInLine(.F.)  //Define se os totalizadores serão impressos em linha ou coluna. .F.=Coluna; .T.=Linha

//Colunas do relatório
TRCell():New(oSectDad, "F1_DOC", cAliasQry, "Numero", X3Picture("F1_DOC"), TamSx3("F1_DOC")[1]+10, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
TRCell():New(oSectDad, "F1_SERIE", cAliasQry, "Serie", X3Picture("F1_SERIE"), TamSx3("F1_SERIE")[1]+10 , /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
TRCell():New(oSectDad, "F1_FORNECE", cAliasQry, "Fornecedor", X3Picture("F1_FORNECE"), TamSx3("F1_FORNECE")[1]+10, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
TRCell():New(oSectDad, "F1_LOJA", cAliasQry, "Loja", X3Picture("F1_LOJA"), TamSx3("F1_LOJA")[1]+10, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
TRCell():New(oSectDad, "F1_EMISSAO", cAliasQry, "DT Emissao", X3Picture("F1_EMISSAO"), TamSx3("F1_EMISSAO")[1]+10, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
TRCell():New(oSectDad, "F1_CHVNFE", cAliasQry, "Chave NFe",X3Picture("F1_CHVNFE"), TamSx3("F1_CHVNFE")[1] +25 , /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
TRCell():New(oSectDad, "OBSERVACAO",  , "Observação Desacordo", /*Picture*/, 90 , /*lPixel*/,{|| ImpObs(cAliasQry) }/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)

Return oReport

/*/{Protheus.doc} fRepPrint
Relatório - Função que imprime o relatório                     
@since 04/12/2020
/*/
	
Static Function fRepPrint(oReport,cAliasQry)

Local aArea    := GetArea()
Local cQryAux  := ""
Local oSectDad := Nil

//Pegando as seções do relatório
oSectDad := oReport:Section(1)

//Montando consulta de dados
cQryAux := "SELECT F1_DOC,"
cQryAux += "       F1_SERIE,"
cQryAux += "       F1_FORNECE,"
cQryAux += "       F1_LOJA,"
cQryAux += "       F1_EMISSAO,"
cQryAux += "       F1_CHVNFE"
cQryAux += "FROM " + RetSqlName("SF1")
cQryAux += "WHERE  F1_IDDES = '6'"
cQryAux += "AND F1_FILIAL = '" + xFilial("SF1") + "'"

If !Empty(MV_PAR01) .And. !Empty(MV_PAR02) //Documento de/ate
	cQryAux += " AND F1_DOC BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "'"
Endif

If !Empty(MV_PAR03) .And. !Empty(MV_PAR04) .And. !Empty(MV_PAR05) .And. !Empty(MV_PAR06) //Fornecedor de/ate
	cQryAux += " AND F1_FORNECE >= '" + MV_PAR03 + "'"
	cQryAux += " AND F1_FORNECE <= '" + MV_PAR05 + "'"
	cQryAux += " AND F1_LOJA >= '" + MV_PAR04 + "'"
	cQryAux += " AND F1_LOJA <= '" + MV_PAR06 + "'" 
Endif

If !Empty(MV_PAR07) .And. !Empty(MV_PAR08)
	cQryAux += " AND F1_EMISSAO BETWEEN '" + DtoS(MV_PAR07) + "' AND '" + DtoS(MV_PAR08) + "'"
Endif

cQryAux += " AND D_E_L_E_T_ = '*' "
cQryAux += " GROUP  BY F1_DOC,"
cQryAux += "           F1_SERIE,"
cQryAux += "           F1_FORNECE,"
cQryAux += "           F1_LOJA,"
cQryAux += "           F1_EMISSAO,"
cQryAux += "           F1_CHVNFE"
cQryAux := ChangeQuery(cQryAux)

//Executando consulta e setando o total da régua
dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQryAux),cAliasQry,.T.,.T.)

TCSetField(cAliasQry, "F1_EMISSAO", "D") 

//Enquanto houver dados
oSectDad:Init()
(cAliasQry)->(DbGoTop())
While !(cAliasQry)->(Eof())
	//Imprimindo a linha atual
	oSectDad:PrintLine()
	
	(cAliasQry)->(DbSkip())
EndDo
oSectDad:Finish()
(cAliasQry)->(DbCloseArea())

RestArea(aArea)

Return

Static Function ImpObs(cAliasQry)

Local cRet		:= ""
Local cQry		:= ""
Local cAliasObs	:= GetNextAlias()

cQry := " SELECT DISTINCT R_E_C_N_O_ AS RECNO"
cQry += " FROM " + RetSqlName("SF1")
cQry += " WHERE F1_FILIAL = '" + xFilial("SF1") + "'"
cQry += " AND F1_CHVNFE = '" + (cAliasQry)->F1_CHVNFE + "'"
cQry += " AND D_E_L_E_T_ = '*'"

cQry := ChangeQuery(cQry)

//Executando consulta e setando o total da régua
dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQry),cAliasObs,.T.,.T.)

If (cAliasObs)->(!EOF())
	SF1->(DbGoto((cAliasObs)->RECNO))

	cRet := AllTrim(SF1->F1_OBSDES)
Endif

(cAliasObs)->(DbCloseArea())

Return cRet
