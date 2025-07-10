#INCLUDE "PROTHEUS.CH"
#INCLUDE "COMPGONL11.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ ComPgOnl1³ Autor ³     Eduardo Dias      ³ Data ³ 23/08/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Monta array para Painel de Gestao On-line Tipo 5:          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Array = { cClick, aCabec, aValores }                       ³±±
±±³          ³ cClick   = Funcao p/ execucao do duplo-click no browse     ³±±
±±³          ³ aCabec   = Array contendo o cabecalho                	  ³±±
±±³          ³ aValores = Array contendo os valores da lista       		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGACOM (Equador)										  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function ComPgOnl11()
Local aCabec   := {}
Local aValores := {}
Local aRet     := {}
Local cOrderBy := ""

Pergunte("MTREQ1",.F.)

//-- Monta cabecalho do painel
aAdd(aCabec,RetTitle("D1_DTDIGIT"))
aAdd(aCabec,RetTitle("A2_NOME"))
aAdd(aCabec,RetTitle("D1_DOC"))
aAdd(aCabec,SerieNfId("SD1",6,"D1_SERIE"))
aAdd(aCabec,RetTitle("D1_ITEM"))
aAdd(aCabec,RetTitle("D1_COD"))
aAdd(aCabec,RetTitle("D1_QUANT"))
aAdd(aCabec,RetTitle("D1_VUNIT"))
aAdd(aCabec,RetTitle("D1_TOTAL"))
aAdd(aCabec,STR0001) //Saldo em Qtde
aAdd(aCabec,STR0002) //Saldo em Vlr

cOrderBY := '%SD1RCN.D1_DTDIGIT,SA2.A2_NOME,SD1RCN.D1_DOC,SD1RCN.D1_SERIE,SD1RCN.D1_ITEM%'
BeginSQL Alias "TRBSD1"

SELECT 	SA2.A2_COD, SA2.A2_LOJA, SA2.A2_NOME, SD1RCN.D1_DOC, SD1RCN.D1_DTDIGIT, SD1RCN.D1_DOC,
		SD1RCN.D1_SERIE, SD1RCN.D1_ITEM, SD1RCN.D1_COD, SD1RCN.D1_QUANT, SD1RCN.D1_VUNIT, SD1RCN.D1_TOTAL, 
            SD1RCN.D1_QUANT - CASE WHEN SUM(SD1NF.D1_QUANT) IS NULL THEN 0 ELSE SUM(SD1NF.D1_QUANT) END AS SALDOQTD,  
            SD1RCN.D1_TOTAL - CASE WHEN SUM(SD1NF.D1_TOTAL) IS NULL THEN 0 ELSE SUM(SD1NF.D1_TOTAL) END AS SALDOVLR
FROM %Table:SD1% SD1RCN          
	JOIN %Table:SA2% SA2 ON
		SA2.%NotDel% AND
		SA2.A2_FILIAL = %xFilial:SA2% AND
		SA2.A2_COD = SD1RCN.D1_FORNECE AND
		SA2.A2_LOJA = SD1RCN.D1_LOJA
	LEFT JOIN %Table:SD1% SD1NF ON
		SD1NF.D1_FILIAL = %xFilial:SD1% AND 
            SD1NF.D1_ESPECIE = 'NF' AND
            SD1NF.D1_REMITO = SD1RCN.D1_DOC AND
            SD1NF.D1_SERIREM = SD1RCN.D1_SERIE AND 
            SD1NF.D1_ITEMREM = SD1RCN.D1_ITEM AND
		SD1NF.%NotDel%
WHERE SD1RCN.D1_DTDIGIT >= %Exp:Dtos(mv_par01)% AND 
        SD1RCN.D1_DTDIGIT <= %Exp:Dtos(mv_par02)% AND               
        SD1RCN.D1_FORNECE >= %Exp:mv_par03% AND 
        SD1RCN.D1_FORNECE <= %Exp:mv_par04% AND                    
        SD1RCN.D1_COD >= %Exp:mv_par05% AND 
    SD1RCN.D1_COD <= %Exp:mv_par06% AND 
	SD1RCN.D1_FILIAL   =   %xFilial:SD2% AND
	SD1RCN.D1_ESPECIE  = 'RCN' AND
	SD1RCN.D1_QTDACLA > 0 AND
	SD1RCN.%NotDel%
GROUP BY SA2.A2_COD, SA2.A2_LOJA, SA2.A2_NOME, SD1RCN.D1_DTDIGIT, SD1RCN.D1_DOC, SD1RCN.D1_SERIE, 
		SD1RCN.D1_ITEM, SD1RCN.D1_COD, SD1RCN.D1_QUANT, SD1RCN.D1_VUNIT, SD1RCN.D1_TOTAL
HAVING CASE WHEN SUM(SD1NF.D1_QUANT) IS NULL THEN 0 ELSE SUM(SD1NF.D1_QUANT) END < SD1RCN.D1_QUANT
ORDER BY %Exp:cOrderby%       

EndSQL

TcSetField("TRBSD1","D1_DTDIGIT","D",TamSX3("D1_DTDIGIT")[1],TamSX3("D1_DTDIGIT")[2])
TcSetField("TRBSD1","D1_QUANT","N",TamSX3("D1_QUANT")[1],TamSX3("D1_QUANT")[2])
TcSetField("TRBSD1","D1_VUNIT","N",TamSX3("D1_VUNIT")[1],TamSX3("D1_VUNIT")[2])
TcSetField("TRBSD1","D1_TOTAL","N",TamSX3("D1_TOTAL")[1],TamSX3("D1_TOTAL")[2])	
TcSetField("TRBSD1","SALDOQTD","N",TamSX3("D1_QUANT")[1],TamSX3("D1_QUANT")[2])
TcSetField("TRBSD1","SALDOVLR","N",TamSX3("D1_TOTAL")[1],TamSX3("D1_TOTAL")[2])	

dbSelectArea("TRBSD1")
While !EOF()
	If SALDOQTD > 0
		aAdd(aValores,{})
		aAdd(aTail(aValores),D1_DTDIGIT)
		aAdd(aTail(aValores),A2_NOME)
		aAdd(aTail(aValores),D1_DOC)
		aAdd(aTail(aValores),D1_SERIE)
		aAdd(aTail(aValores),D1_ITEM)
		aAdd(aTail(aValores),D1_COD)
		aAdd(aTail(aValores),TransForm(D1_QUANT,PesqPictQt("D1_QUANT")))
		aAdd(aTail(aValores),TransForm(D1_VUNIT,PesqPictQt("D1_VUNIT")))
		aAdd(aTail(aValores),TransForm(D1_TOTAL,PesqPictQt("D1_TOTAL")))
		aAdd(aTail(aValores),TransForm(SALDOQTD,PesqPictQt("D1_QUANT")))
		aAdd(aTail(aValores),TransForm(SALDOVLR,PesqPictQt("D1_TOTAL")))
	EndIf
	dbSkip()
EndDo

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Preenche array do Painel de Gestao                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aRet := {/*cClick*/, aCabec, aValores} 

dbSelectArea("TRBSD1")
dbCloseArea()

Return aRet