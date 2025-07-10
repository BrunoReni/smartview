#INCLUDE "PROTHEUS.CH"
#INCLUDE "COMPGONL12.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ComPgOnl12³ Autor ³     Eduardo Dias      ³ Data ³ 23/08/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Monta painel com RCD's sem NCP					          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ ComPgOnl2()				                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Array = { cClick, aCabec, aValores }                       ³±±
±±³          ³ cClick   = Funcao p/ execucao do duplo-click no browse     ³±±
±±³          ³ aCabec   = Array contendo o cabecalho                	  ³±±
±±³          ³ aValores = Array contendo os valores da lista       		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGACOM (Equador)		                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function ComPgOnl12()
Local aCabec    := {}
Local aValores  := {}
Local aRet      := {}
Local cOrderBy  := ""

//-- Utiliza mesmas perguntas do relatorio
Pergunte("MTREQ2",.F.)

aAdd(aCabec,RetTitle("D2_EMISSAO"))
aAdd(aCabec,RetTitle("A2_NOME"))
aAdd(aCabec,RetTitle("D2_DOC"))
aAdd(aCabec,RetTitle("D2_SERIE"))
aAdd(aCabec,RetTitle("D2_ITEM"))
aAdd(aCabec,RetTitle("D2_COD"))
aAdd(aCabec,RetTitle("D2_QUANT"))
aAdd(aCabec,RetTitle("D2_PRCVEN"))
aAdd(aCabec,RetTitle("D2_TOTAL"))
aAdd(aCabec,STR0001) //Saldo em Qtde
aAdd(aCabec,STR0002) //Saldo em Vlr

cOrderBY := '%SD2RCD.D2_EMISSAO,SA2.A2_NOME,SD2RCD.D2_DOC,SD2RCD.D2_SERIE,SD2RCD.D2_ITEM%'
BeginSQL Alias "TRBSD2"

SELECT SA2.A2_COD, SA2.A2_LOJA, SA2.A2_NOME, SD2RCD.D2_EMISSAO, SD2RCD.D2_DOC, SD2RCD.D2_SERIE,
	SD2RCD.D2_ITEM, SD2RCD.D2_COD, SD2RCD.D2_QUANT, SD2RCD.D2_PRCVEN, SD2RCD.D2_TOTAL,  
	SD2RCD.D2_QUANT - CASE WHEN SUM(SD2NCP.D2_QUANT) IS NULL THEN 0 ELSE SUM(SD2NCP.D2_QUANT) END AS SALDOQTD, 
    SD2RCD.D2_TOTAL - CASE WHEN SUM(SD2NCP.D2_TOTAL) IS NULL THEN 0 ELSE SUM(SD2NCP.D2_TOTAL) END AS SALDOVLR 
FROM %Table:SD2% SD2RCD
	JOIN %Table:SA2% SA2 ON
		SA2.%NotDel% AND
		SA2.A2_FILIAL = %xFilial:SA2% AND
		SA2.A2_COD = SD2RCD.D2_CLIENTE AND
		SA2.A2_LOJA = SD2RCD.D2_LOJA			
	LEFT JOIN %Table:SD2% SD2NCP ON
		SD2NCP.D2_FILIAL  = %xFilial:SD2% AND 
		SD2NCP.D2_ESPECIE LIKE 'NC%' AND 
		SD2NCP.D2_CLIENTE = SD2RCD.D2_CLIENTE AND
		SD2NCP.D2_LOJA = SD2RCD.D2_LOJA AND
		SD2NCP.D2_REMITO  = SD2RCD.D2_DOC AND
		SD2NCP.D2_SERIREM = SD2RCD.D2_SERIE AND 
		SD2NCP.D2_ITEMREM = SD2RCD.D2_ITEM AND
		SD2NCP.%NotDel%
WHERE SD2RCD.D2_EMISSAO >= %Exp:Dtos(mv_par01)% AND 
	SD2RCD.D2_EMISSAO <= %Exp:Dtos(mv_par02)% AND               
    SD2RCD.D2_CLIENTE >= %Exp:mv_par03% AND 
    SD2RCD.D2_CLIENTE <= %Exp:mv_par04% AND                    
    SD2RCD.D2_COD >= %Exp:mv_par05% AND 
	SD2RCD.D2_COD <= %Exp:mv_par06% AND 
	SD2RCD.D2_FILIAL   =   %xFilial:SD2% AND
	SD2RCD.D2_ESPECIE  = 'RCD' AND
	SD2RCD.%NotDel%
GROUP BY SA2.A2_COD, SA2.A2_LOJA, SA2.A2_NOME, SD2RCD.D2_EMISSAO, SD2RCD.D2_DOC, SD2RCD.D2_SERIE,
	SD2RCD.D2_ITEM, SD2RCD.D2_COD, SD2RCD.D2_QUANT, SD2RCD.D2_PRCVEN, SD2RCD.D2_TOTAL                                    
HAVING CASE WHEN SUM(SD2NCP.D2_QUANT) IS NULL THEN 0 ELSE SUM(SD2NCP.D2_QUANT) END < SD2RCD.D2_QUANT	
ORDER BY %Exp:cOrderby%

EndSQL
TcSetField("TRBSD2","D2_EMISSAO","D",TamSX3("D2_EMISSAO")[1],TamSX3("D2_EMISSAO")[2])
TcSetField("TRBSD2","D2_QUANT","N",TamSX3("D2_QUANT")[1],TamSX3("D2_QUANT")[2])
TcSetField("TRBSD2","D2_PRCVEN","N",TamSX3("D2_PRCVEN")[1],TamSX3("D2_PRCVEN")[2])
TcSetField("TRBSD2","D2_TOTAL","N",TamSX3("D2_TOTAL")[1],TamSX3("D2_TOTAL")[2])
TcSetField("TRBSD2","SALDOQTD","N",TamSX3("D2_QUANT")[1],TamSX3("D2_QUANT")[2])
TcSetField("TRBSD2","SALDOVLR","N",TamSX3("D2_TOTAL")[1],TamSX3("D2_TOTAL")[2])

dbSelectArea("TRBSD2")	
While !EOF()
	If SALDOQTD > 0
		aAdd(aValores,{})
		aAdd(aTail(aValores),D2_EMISSAO)
		aAdd(aTail(aValores),A2_NOME)
		aAdd(aTail(aValores),D2_DOC)
		aAdd(aTail(aValores),D2_SERIE)
		aAdd(aTail(aValores),D2_ITEM)
		aAdd(aTail(aValores),D2_COD)
		aAdd(aTail(aValores),TransForm(D2_QUANT,PesqPictQt("D2_QUANT")))
		aAdd(aTail(aValores),TransForm(D2_PRCVEN,PesqPictQt("D2_PRCVEN")))
		aAdd(aTail(aValores),TransForm(D2_TOTAL,PesqPictQt("D2_TOTAL")))
		aAdd(aTail(aValores),TransForm(SALDOQTD,PesqPictQt("D2_QUANT")))
		aAdd(aTail(aValores),TransForm(SALDOVLR,PesqPictQt("D2_TOTAL")))
	EndIf 
	dbSkip()
EndDo

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Preenche array do Painel de Gestao                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aRet := {/*cClick*/, aCabec, aValores} 

dbSelectArea("TRBSD2")
dbCloseArea()

Return aRet