#INCLUDE "MATA295.ch"
#INCLUDE "PROTHEUS.ch"

#DEFINE nMesAval     MV_PAR01
#DEFINE nEstabilid   MV_PAR02 
#DEFINE nMedias      MV_PAR03 
#DEFINE nTendencia   MV_PAR04 
#DEFINE nSazonalid   MV_PAR05 
#DEFINE cCodFormu    MV_PAR06 
#DEFINE nClAVenda    MV_PAR07 
#DEFINE nClBVenda    MV_PAR08 
#DEFINE nClACusto    MV_PAR09 
#DEFINE nClBCusto    MV_PAR10 
#DEFINE ClCustMDe    MV_PAR11 
#DEFINE ClCustMAte   MV_PAR12 
#DEFINE nTipVenda    MV_PAR13 
#DEFINE cTipInclu    MV_PAR14 
#DEFINE cTipExcet    MV_PAR15 

Static cAnoMes 

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Descri‡…o ³ PLANO DE MELHORIA CONTINUA        ³Programa    MATA295.PRW ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ITEM PMC  ³ Responsavel              ³ Data                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³      01  ³                          ³                                 ³±±
±±³      02  ³ Ricardo Berti            ³ 15/12/05                        ³±±
±±³      03  ³                          ³                                 ³±±
±±³      04  ³ Ricardo Berti            ³ 15/12/05                        ³±±
±±³      05  ³                          ³                                 ³±±
±±³      06  ³                          ³                                 ³±±
±±³      07  ³                          ³                                 ³±±
±±³      08  ³                          ³                                 ³±±
±±³      09  ³                          ³                                 ³±±
±±³      10  ³ Ricardo Berti            ³ 15/12/05                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ MATA295  ³ Autor ³ Alex Sandro Valario   ³ Data ³ 14/04/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Acumulado para sugestao de compras                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ MATA295(void)                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/           
Function Mata295()     

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Perguntas                                       ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
MV_PAR01	N	2 		Meses para avaliacao da melhor sugestao
MV_PAR02 N	1 		Se utiliza a Formula de Estabilidade 1-Sim 2-Nao
MV_PAR03 N	1 		Se utiliza a Formula de Medias 1-Sim 2-Nao
MV_PAR04	N	1 		Se utiliza a Formula de Tendencia 1-Sim 2-Nao
MV_PAR05	N	1 		Se utiliza a Formula de Sazonalidade 1-Sim 2-Nao
MV_PAR06	C  30 		String contendo as os codigo da formulas que poderam estar cadastrada no SM4
MV_PAR07	N	2 		% da Classificacao A ref a Vendas
MV_PAR08	N	2 		% da Classificacao B ref a Vendas
MV_PAR09	N	2 		% da Classificacao A ref a Custos
MV_PAR10	N	2 		% da Classificacao B ref a Custos
MV_PAR11	N  15	2   Valor Classificacao Custo Medio de
MV_PAR12	N  15	2   Valor Classificacao Custo Medio ate
MV_PAR13	N   1 		Somente Vendas 1-Venda 2-Todos
MV_PAR14	C  40 	Tipo de Materiais
MV_PAR15	C  40 	Excessao de Tipo de Materiais
MV_PAR16	N   1 	Considerar TES que 1-Gera Duplicata 2-Nao gera Duplicata 3-Ambos
MV_PAR17	N   1 	Qto ao Estoque TES 1-Movimenta      2-Nao Movimenta      3-Ambos
*/

Local lContinua := .T.  

If Pergunte("MTA295")

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta o mes de trabalho do calculo das demandas                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	IF Month(dDataBase)==1 
		cAnoMes := StrZero(Year(dDataBase)-1,4)+"12" 
	Else
		cAnoMes := StrZero(Year(dDataBase),4)+StrZero(Month(dDataBase)-1,2) 
	EndIf   

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se nao existe SBL para reprocessar                            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DbSelectArea("SBL")
	DBSetOrder(2)  //SBL Acum.Sugest.Compra	->BL_FILIAL+BL_ANO+BL_MES
	If MsSeek(xFilial("SBL")+cAnoMes)  
		lContinua := MsgYesNo(STR0008,STR0009)// Confirma geracao
	Endif
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Processa das demandas                                                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    If lContinua
		Processa({ || Mt295Acum() })
	EndIf
Endif

Return (Nil)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Mt295Acum ³ Autor ³ Henry Fila            ³ Data ³ 14/04/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Acumulado para sugestao de compras                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ Mt295Acum()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Funcao principal para gerar os acumulados do SBL           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATA297()                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/           

Function Mt295Acum() 

Local lVeic := GetMV("MV_VEICULO") == "S"
Local lReq  := GetMV("MV_USAREQ")  == "S" 

ProcRegua(if(nTipVenda <> 3,if(lReq,7,6),if(lReq,9,8))) // MV_PAR13 Somente Venda 1- Venda 2-Todos

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Gera registros do SBL em branco para processamento                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
GeraSBL()       

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica os movimentos de entrada                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nTipVenda <> 1
	Mt295Sd1()
Endif	

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica os movimentos de saida                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Mt295Sd2()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica movimentos internos                                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Mt295Sd3() 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Vwrifica resgistro caso esteja integrado com modulo de veiculos        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lVeic .and. lReq
	AcumulaVO2() //Requisicoes
EndIF
If lVeic
	AcumulaVE6() //Vendas Perdidas
EndIF

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³PE "M295ACUM" executado ANTES do calculo da curva ABC das demandas.     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock("M295ACUM")
	ExecBlock("M295ACUM",.F.,.F.)
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Calcula a curva ABC das demandas                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Mt295Dem()   

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Calcula a curva ABC do custo                                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Mt295ABCCt()   

Mt295GrvFor()  

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ GERASBL  ³ Autor ³ Alex Sandro Valario   ³ Data ³ 14/04/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Acumulado os Produtos de arqco c/ as pergutas              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ GERASBL()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATA295                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/           
Static Function GeraSBL()                        
Local nX
Local nTamTip
Local nStandard 
Local lProcessa := .T.
Local lM295SBL := ExistBlock("M295SBL")
Static cAliasSB1 
Static cQuery
Static lQuery := .F.

//Pega o tamanho do campo B1_TIPO

nTamTip:=TamSX3("B1_TIPO")[1]

IncProc(STR0001) //"Processo: Inicializando"

DbSelectArea("SBL")
DBSetOrder(1)  //SBL Acum.Sugest.Compra	->BL_FILIAL+BL_PRODUTO+BL_ANO+BL_MES


#IFDEF TOP
	If ( TcSrvType()<>"AS/400")
		cAliasSB1 := GetNextAlias()
		lQuery  := .T.
		cQuery  := "SELECT SB1.B1_FILIAL, SB1.B1_COD, SB1.B1_FLAGSUG, SB1.B1_TIPO, SB1.B1_CLASSVE, SB1.B1_CUSTD, SB1.B1_MCUSTD FROM "+RetSqlName("SB1")+" SB1 "
		cQuery  += " WHERE SB1.B1_FILIAL='"+xFilial("SB1")+"' AND "
		cQuery  += " SB1.B1_FLAGSUG = '1' AND SB1.B1_CLASSVE = '1' AND "
		cQuery  += " SB1.D_E_L_E_T_=' ' AND "
		cQuery  += " NOT EXISTS (SELECT 1 FROM "+RetSqlName("SG1")+ " SG1 WHERE SG1.G1_FILIAL = '"+xFilial("SG1")+"' "
		cQuery  += " AND SG1.G1_COD = SB1.B1_COD AND SG1.D_E_L_E_T_=' ' )
		cQuery := ChangeQuery( cQuery )
		dbUseArea( .T., "TOPCONN", TcGenQry( ,,cQuery ), cAliasSB1, .F., .T. )
		TcSetField(cAliasSB1,"B1_CUSTD","N",TamSX3('B1_CUSTD')[1],TamSX3('B1_CUSTD')[2])
	Else
#ENDIF 
	cAliasSB1:='SB1'
	DbSelectArea("SB1")
	DbSetOrder(1)   //SB1 Produtos		    ->B1_FILIAL+B1_COD
	DbSeek(xFilial("SB1")) 
	#IFDEF TOP
		EndIf
	#ENDIF

While (cAliasSB1)->(!Eof()) .And. IIf(lQuery,.T.,xFilial("SB1") == (cAliasSB1)->B1_FILIAL )

   If (cAliasSB1)->B1_FLAGSUG == "1" .And. (cAliasSB1)->B1_CLASSVE == "1"       	
      lProcessa := .T.
      //Processa os tipos de produtos de acordo com os parametros para fazer
      //parte ou nao do processo	

      If !Empty(cTipInclu)
         For nX:=1 to Len(AllTrim(cTipInclu)) Step nTamTip
            IF (cAliasSB1)->B1_TIPO # SubStr(cTipInclu,nX,nTamTip)
               lProcessa := .F.
            EndIF
         Next
      EndIf

      IF !Empty(cTipExcet)
         For nX:=1 to Len(AllTrim(cTipExcet)) Step nTamTip
            IF (cAliasSB1)->B1_TIPO == SubStr(cTipExcet,nX,nTamTip)
               lProcessa := .F.
            EndIF
         Next
      EndIf

	  If !lQuery
	      SG1->(DbSetOrder(1))
	      If  SG1->(MsSeek(xFilial("SG1")+(cAliasSB1)->B1_COD))
	         lProcessa := .F.
	      EndIf   
	  EndIf

      If lProcessa	

         //Calcula o custo standard do produto
         nStandard := Mt295Custo((cAliasSB1)->B1_COD)
   
         DbSelectArea("SBL")
         If ! MsSeek(xFilial("SBL")+(cAliasSB1)->B1_COD+cAnoMes)  
            RecLock("SBL",.T.)
            SBL->BL_FILIAL  := xFilial("SBL") 
            SBL->BL_PRODUTO := (cAliasSB1)->B1_COD
            SBL->BL_ANO     := Left(cAnoMes,4)
            SBL->BL_MES     := Right(cAnoMes,2)
         Else
            RecLock("SBL",.F.)
         EndIf       

         SBL->BL_DEMANDA := 0
         SBL->BL_TOTDEM  := 0
         SBL->BL_TOTCUST := nStandard
         SBL->BL_FREQUEN := 0
         SBL->BL_ABCVEND := "C"
         SBL->BL_ABCCUST := "C"
         SBL->BL_VENDPER := 0 
         SBL->BL_CODFORM := ""
         SBL->BL_PORFOR1 := 0
         SBL->BL_QTDFOR1 := 0
         SBL->BL_CODFOR2 := ""
         SBL->BL_PORFOR2 := 0
         SBL->BL_QTDFOR2 := 0
         SBL->BL_CODFOR3 := ""
         SBL->BL_PORFOR3 := 0
         SBL->BL_QTDFOR3 := 0
         SBL->BL_CODFOR4 := ""
         SBL->BL_PORFOR4 := 0
         SBL->BL_QTDFOR4 := 0    
 
   		 If xMoeda((cAliasSB1)->B1_CUSTD,Val((cAliasSB1)->B1_MCUSTD),1,dDataBase) < ClCustMDe            
            SBL->BL_TIPCUST := "3"
 		 ElseIf xMoeda((cAliasSB1)->B1_CUSTD,Val((cAliasSB1)->B1_MCUSTD),1,dDataBase) > ClCustMAte 
            SBL->BL_TIPCUST := "1"
         Else   
            SBL->BL_TIPCUST := "2"      
         EndIf   

         MsUnlock()

         If lM295SBL
            Execblock("M295SBL",.f.,.f.)
         EndIf

      Endif   

   Endif
   If !lQuery
	   DbSelectArea("SB1")
	   DbSkip()
   Else
       (cAliasSB1)->(DbSkip())
   EndIf
EndDo
#IFDEF TOP
	Dbclosearea(cAliasSB1)
#ENDIF
Return                             


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ Mt295Custo³ Autor ³ Henry Fila            ³ Data ³ 14/04/00³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Calcula o custo do produto                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ Mt295Custo()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 - Codigo do Produto                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATA295                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/           

Static Function Mt295Custo(cCod)

Local cAlias := GetArea()
Local nValor :=0

DbSelectArea("SB2")
DBSetOrder(1)
MsSeek(xFilial("SB2")+cCod)

While (! eof() .and. SB2->B2_FILIAL == xFilial("SB2") .and. B2_COD == cCod)
   nValor  += B2_QATU*xMoeda((cAliasSB1)->B1_CUSTD,Val((cAliasSB1)->B1_MCUSTD),1,dDataBase)  
   DbSkip()
End
RestArea(cAlias)

Return nValor

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Mt295SD1³ Autor ³ Henry Fila              ³ Data ³ 14/04/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Processa o arquivo SD1 -> Itens das notas fiscais de entrda³±±
±±³          ³ verificando as devolucoes dos produtos                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Mt295SD1()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Mata295                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/           
Static Function Mt295SD1()

Local lProcessa := .T.
Local lRemito	  := .F.


IncProc(STR0002) //"Processo: Entradas"

DbSelectArea("SB1")
SB1->(DbSetOrder(1))  //SB1 Produtos		    ->B1_FILIAL+B1_COD

DbSelectArea("SD1")
SD1->(DbSetOrder(6))  //SD1 Itens de Entrada  	->D1_FILIAL+DTOS(D1_DTDIGIT)+D1_NUMSEQ

MsSeek(xFilial("SD1")+cAnoMes)


While ! SD1->(eof()) .and. SD1->D1_FILIAL == xFilial("SD1") .and. Left(DToS(SD1->D1_DTDIGIT),6) == cAnoMes
	
	lProcessa := .T.
			
	SF4->(MsSeek(xFilial("SF4")+SD1->D1_TES))
	If (mv_par17 == 1 .And. SF4->F4_ESTOQUE <> "S");
		.or. (mv_par17 == 2 .And. SF4->F4_ESTOQUE <> "N");
		.or. (mv_par16 == 1 .And. SF4->F4_DUPLIC <> "S");
		.or. (mv_par16 == 2 .And. SF4->F4_DUPLIC <> "N")
		lProcessa := .F.
	EndIf

	If lProcessa .And. ExistBlock("M295SD1")
		lProcessa := ExecBlock("M295SD1",.F.,.F.)
		If ValType(lProcessa) # 'L'
			lProcessa := .F.
		Endif
	EndIf
		
	// Despreza Notas Fiscais Lancadas Pelo Modulo do Livro Fiscal
	If SD1->D1_ORIGLAN <> "LF" .And. SD1->D1_TIPO == 'D'.And. lProcessa .And. ;
		Iif(lRemito,Empty(SD1->D1_REMITO),.T.) // Nao considerar faturas que possuam remito, para nao gerar duplicidade de demanda
		
		dbSelectArea("SBL")
		
		If MsSeek(xFilial("SBL")+SD1->D1_COD+cAnoMes)
			RecLock("SBL",.F.)
			SBL->BL_DEMANDA -=SD1->D1_QUANT
			SBL->BL_TOTDEM  -=SD1->D1_TOTAL
			SBL->(MsUnlock())
		Endif
		
	Endif
	dbSelectArea("SD1")
	dbSkip()
EndDo


Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Mt295Sd2  ³ Autor ³ Henry Fila            ³ Data ³ 14/04/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Processa o arquivo SD2 -> Itens das notas fiscais de Saida ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Mt295Sd2()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Mata295                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/           
Static Function Mt295Sd2()

Local lVeic     := GetMV("MV_VEICULO") == "S"
Local lReq      := GetMV("MV_USAREQ")  == "S"
Local lProcessa := .T.
Local lRemito	  := .F.

IncProc(STR0003) //"Processo: Saidas"

If lVeic .And. lReq
	If !("VOO"$cFopened)
		ChkFile("VOO",.F.)
	EndIf
	VOO->(dbSetOrder(4))
EndIF


DbSelectArea("SB1")
SB1->(DbSetOrder(1))  //SB1 Produtos		    ->B1_FILIAL+B1_COD

DbSelectArea("SD2")
DbSetOrder(5) //SD2 Itens de Saida    	->D2_FILIAL+DTOS(D2_EMISSAO)+D2_NUMSEQ
MsSeek(xFilial("SD2")+cAnoMes)


While ! SD2->(eof()) .and. SD2->D2_FILIAL == xFilial("SD2") .and. Left(DtoS(SD2->D2_EMISSAO),6) == cAnoMes
	
	lProcessa := .T.
	// Despreza Notas Fiscais Lancadas Pelo Modulo do Livro Fiscal
	If SD2->D2_ORIGLAN == "LF" .or. SD2->D2_TIPO $ "DB"
		lProcessa := .F.
	EndIf
	
	If lVeic .And. lReq
		IF VOO->(MsSeek(xFilial("VOO")+SD2->D2_DOC+SD2->D2_SERIE))
			lProcessa := .F.
		EndIF
	EndIf
	
	SF4->(MsSeek(xFilial("SF4")+SD2->D2_TES))
	If (SF4->F4_ISS == "S") .or. (mv_par17 == 1 .And. SF4->F4_ESTOQUE # "S");
		.or. (mv_par17 == 2 .And. SF4->F4_ESTOQUE # "N");
		.or. (mv_par16 == 1 .And. SF4->F4_DUPLIC # "S");
		.or. (mv_par16 == 2 .And. SF4->F4_DUPLIC # "N")
		lProcessa := .F.
	EndIf

	If lProcessa .And. ExistBlock("M295SD2")
		lProcessa := ExecBlock("M295SD2",.F.,.F.)
		If ValType(lProcessa) # 'L'
			lProcessa := .F.
		Endif
	EndIf
		
	If lProcessa .And. ;
	Iif(lRemito,Empty(SD2->D2_REMITO),.T.) // Nao considerar facturas que possuam remito, para nao gerar duplicidade de demanda
		
		dbSelectArea("SBL")
		If MsSeek(xFilial("SBL")+SD2->D2_COD+cAnoMes)
			RecLock("SBL",.F.)
			SBL->BL_DEMANDA +=SD2->D2_QUANT
			SBL->BL_TOTDEM  +=SD2->D2_CUSTO1
			SBL->BL_FREQUEN ++
			SBL->(MsUnlock())
		Endif
		dbSelectArea("SD2")
		
	Endif
	
	SD2->(DbSkip())
	
EndDo

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Mt295Sd3  ³ Autor ³ Henry Fila            ³ Data ³ 14/04/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Processa o arquivo movimentos internos       	  		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Mt295Sd3                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Mata295                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/           
Static Function Mt295Sd3()

Local lProcessa := .T.

IF nTipVenda == 3
	IncProc(STR0010)  //"Processo: Movimentos Internos"
	
	dbSelectArea("SB1")
	SB1->(DbSetOrder(1))  //SB1 Produtos		    ->B1_FILIAL+B1_COD
	
	dbSelectArea("SD3")
	SD3->(DbSetorder(6))  //SD3 Moviment.Internas 	->D3_FILIAL+DTOS(D3_EMISSAO)+D3_NUMSEQ+D3_CHAVE+D3_COD
	MsSeek(xFilial("SD3")+cAnoMes)
	
	While ! SD3->(eof()) .and. SD3->D3_FILIAL == xFilial("SD3") .and. Left(DToS(SD3->D3_EMISSAO),6) == cAnoMes

        lProcessa := .T.
        
		If ExistBlock("M295SD3")
			lProcessa := ExecBlock("M295SD3",.F.,.F.)
			If ValType(lProcessa) # 'L'
				lProcessa := .F.
			Endif
		EndIf
		
		If Subs(SD3->D3_CF,2,1) == "E" .And. !(Substr(D3_CF,3,1) $ "347") .And. lProcessa
			dbSelectArea("SBL")
			If MsSeek(xFilial("SBL")+SD3->D3_COD+cAnoMes)
				RecLock("SBL",.F.)
				If SD3->D3_TM <= "500"
					SBL->BL_DEMANDA -=SD3->D3_QUANT
					SBL->BL_TOTDEM  -=SD3->D3_CUSTO1
				Else
					SBL->BL_DEMANDA +=SD3->D3_QUANT
					SBL->BL_TOTDEM  +=SD3->D3_CUSTO1
				EndIf
				MsUnlock()
			Endif
		Endif
		
		dbSelectArea("SD3")
		dbSkip()
	EndDo
	
Endif

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³AcumulaVO2³ Autor ³ Valdir F. Silca       ³ Data ³ 22/08/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Processa o arquivo de Requisicoes						  		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ AcumulaVO2()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Mata295                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/           
Static Function AcumulaVO2()                        

IncProc(STR0004) //"Processo: Requisicoes"
If !("VO2"$cFopened)
  	ChkFile("VO2",.F.)
EndIf
If !("VO3"$cFopened)
   ChkFile("VO3",.F.)
EndIf

SB1->(DbSetOrder(1))  
VO2->(DbSetorder(3))  
VO2->(MsSeek(xFilial("VO2")+cAnoMes))
VO3->(DbSetorder(1))
While ! VO2->(eof()) .and. VO2->VO2_FILIAL == xFilial("VO2") .and. Left(DToS(VO2->VO2_DATREQ),6) == cAnoMes
   //Posiciona os Itens 
   VO3->(MsSeek(xFilial("VO3")+VO2->VO2_NOSNUM))
   While ! VO3->(eof()) .and. VO3->VO3_FILIAL == xFilial("VO3") .and. VO3->VO3_NOSNUM == VO2->VO2_NOSNUM
   	//Verifica se a OS esta Cancelada
	  If VO3->VO3_DATCAN # CTOD("  /  /  ","ddmmyy")
      	VO3->(dbSkip())
      	Loop	
   	EndIf                             
   	//Verifica se a OS esta fechada
		If VO3->VO3_DATFEC # CTOD("  /  /  ","ddmmyy")
      	VO3->(dbSkip())
      	Loop	
   	EndIf                             

   	If SBL->(MsSeek(xFilial("SBL")+VO3->VO3_PECINT+cAnoMes))      
	   	RecLock("SBL",.F.)
	     	//Verifica se e 1=Requisicao ou 0=devolucao
	     	If VO2->VO2_DEVOLU == "1"
   	  		SBL->BL_DEMANDA +=VO3->VO3_QTDREQ
    			SBL->BL_TOTDEM  +=(VO3->VO3_VALPEC*VO3->VO3_QTDREQ)
	      	SBL->BL_FREQUEN ++
   	   Else
	     		SBL->BL_DEMANDA -=VO3->VO3_QTDREQ
   	 		SBL->BL_TOTDEM  -=(VO3->VO3_VALPEC*VO3->VO3_QTDREQ)
      		SBL->BL_FREQUEN --  
	      EndIf
   		SBL->(MsUnlock())    	  	
   	EndIf
   	VO3->(dbSkip())
   EndDo
   VO2->(DbSkip())
EndDo      

Return    

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³AcumulaVE6³ Autor ³ Valdir F. Silca       ³ Data ³ 22/08/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Processa o arquivo de Requisicoes						  		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ AcumulaVE6()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Mata295                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/           
Static Function AcumulaVE6()                        
Local nRecSB1 := SB1->(Recno())
Local nOrdSB1 := SB1->(IndexOrd())
IncProc(STR0011) //"Processo: Vendas Perdidas"
If !("VE6"$cFopened)
  	ChkFile("VE6",.F.)
EndIf
If !("VE7"$cFopened)
   ChkFile("VE7",.F.)
EndIf
SB1->(DbSetOrder(7))
VE6->(dbsetorder(1))
VE7->(dbsetorder(1))
VE6->(MsSeek(xFilial("VE6")+"1"+cAnoMes))
While VE6->(!eof()) .and. VE6->VE6_FILIAL == xFilial("VE6") .and.;
      VE6->VE6_INDREG == "1" .and. Left(DTOS(VE6->(VE6_DATREG)),6) == cAnoMes 
	VE7->(MsSeek(xFilial("VE7")+VE6->VE6_INDREG))
	If VE7->VE7_INDMOT == "1"
		If SB1->(MsSeek(xFilial("SB1")+VE6->VE6_GRUITE+VE6->VE6_CODITE))
			If SBL->(DbSeek(xFilial("SBL")+SB1->B1_COD))
				RecLock("SBL",.F.)
				SBL->BL_DEMANDA +=VE6->VE6_QTDITE
				SBL->BL_TOTDEM  +=(VE6->VE6_VALPEC*VE6->VE6_QTDITE)
				SBL->BL_FREQUEN ++ 
				MsUnlock()   
			EndIf
		EndIf
	EndIF
	VE6->(dbSkip())
EndDo
SB1->(Dbgoto(nRecSB1))
SB1->(DbSetOrder(nOrdSB1))
Return    

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Mt295Dem  ³ Autor ³ Henry Fila            ³ Data ³ 14/04/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Classificacao ABC de Venda								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Mt295Dem                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Mata295                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/           
Static Function Mt295Dem()

Local cPAnoMes
Local nTotal :=0
Local nTotA  :=0
Local nTotB  :=0
Local nTotC  :=0                      
Local nPorC  := 100-(nClAVenda+nClBVenda)

IncProc(STR0005) //"Processo: Classificacao ABC Vendas"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Calcula o ano e mes final para verficar a curva ABC                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
IF Month(dDataBase)==12
   cPAnoMes := StrZero(Year(dDataBase)+1,4)+"01"
Else
   cPAnoMes := StrZero(Year(dDataBase),4)+StrZero(Month(dDataBase),2)
EndIf   

DbSelectArea("SB1")
SB1->(DbSetOrder(1))  //SB1 Produtos		    ->B1_FILIAL+B1_COD
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Calcula a demanda total posicionando no mes subsequente e calculando   ³
//³ de tras pra frente                                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("SBL")                                              
DbSetOrder(3)  //SBL Sugestao compras   ->BL_FILIAL+STR(BL_TOTDEM,15,2)
MsSeek(xFilial("SBL")+cPAnoMes,.t.)
DbSkip(-1)

While (! SBL->(BOF()) .and. xFilial("SBL")==SBL->BL_FILIAL  .and. SBL->(BL_ANO+BL_MES) == cAnoMes )
   nTotal += SBL->BL_TOTDEM
   SBL->(DbSkip(-1))
EndDo                         

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Calcula a faixa ABC para demanda                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nTotA   :=  nClAVenda * nTotal / 100
nTotB   := (nClBVenda * nTotal / 100) + nTotA
nTotC   := (nPorC     * nTotal / 100) + nTotB
nTotal  := 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Separa as demandas pelas faixas pela ordem inversa de valor            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SBL")
DbSetOrder(3)  //SBL Sugestao compras   ->BL_FILIAL+STR(BL_TOTDEM,15,2)
DbSeek(xFilial("SBL")+cPAnoMes,.t.)
DbSkip(-1)

While (! SBL->(BOF()) .and. xFilial("SBL")==SBL->BL_FILIAL .and. SBL->(BL_ANO+BL_MES) == cAnoMes)
   nTotal += SBL->BL_TOTDEM   
   If nTotal < nTotA
      cClasse := "A"
   ElseIf nTotal < nTotB
      cClasse := "B"
   Else
      cClasse := "C"
   Endif                                               

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Grava a classe                                                         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   SBL->(RecLock("SBL",.F.))
   SBL->BL_ABCVEND := cClasse
   SBL->(MsUnlock())
   SBL->(DbSkip(-1))      
EndDo

SBL->(DbSetOrder(1))

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Mt295ABCCt³ Autor ³ Alex Sandro Valario   ³ Data ³ 14/04/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Classificacao ABC de Venda								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Mt295Custo()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Mata295                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/           
Static Function Mt295ABCCt()

Local cPAnoMes := ""
Local nTotal   := 0
Local nTotA    := 0
Local nTotB    := 0
Local nTotC    := 0                      
Local nPorC    := 100-(nClACusto+nClBCusto)

IncProc(STR0006) //"Processo: Classificacao ABC Custo"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Calcula o ano e mes final para verficar a curva ABC                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
IF Month(dDataBase)==12
   cPAnoMes := StrZero(Year(dDataBase)+1,4)+"01"
Else
   cPAnoMes := StrZero(Year(dDataBase),4)+StrZero(Month(dDataBase),2)
EndIf   

DbSelectArea("SB1")
DbSetOrder(1)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Calcula o custo total                                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("SBL")                                              
DbSetOrder(4)
MsSeek(xFilial("SBL")+cPAnoMes,.t.)
DbSkip(-1)                         

While (! SBL->(BOF()) .and. xFilial("SBL")==SBL->BL_FILIAL .and. SBL->(BL_ANO+BL_MES) == cAnoMes) 
   nTotal += SBL->BL_TOTCUST
   DbSkip(-1)
EndDo                         

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Calcula a faixa ABC para e custo                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nTotA   :=  nClACusto * nTotal / 100
nTotB   := (nClBCusto * nTotal / 100) + nTotA
nTotC   := (nPorC     * nTotal / 100) + nTotB
nTotal  := 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Separa os custoss pelas faixas pela ordem inversa de valor             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("SBL")
DbSetOrder(4)  
MsSeek(xFilial("SBL")+cPAnoMes,.t.)
DbSkip(-1)

While (! SBL->(BOF()) .and. xFilial("SBL")==SBL->BL_FILIAL .and. SBL->(BL_ANO+BL_MES) == cAnoMes)
   nTotal += SBL->BL_TOTCUST
   If nTotal < nTotA
      cClasse := "A"
   ElseIf nTotal < nTotB
      cClasse := "B"
   Else
      cClasse := "C"
   Endif                                               
   
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Grava as classes                                                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   RecLock("SBL",.F.)
   SBL->BL_ABCCUST := cClasse
   MsUnlock()
	DbSkip(-1)
EndDo                         

DbSetOrder(1)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Mt295GrvFor  ³ Autor ³ Alex Sandro Valario   ³ Data ³ 14/04/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Grava a formula eleita                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Mt295GrvFor                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Mata295                                         	           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/           
Static Function Mt295GrvFor()

Local aFormula := 0

IncProc(STR0007) //"Processo: Classificacao Formula"

DbSelectArea("SB1")
DbSetOrder(1)  

DbSelectArea("SBL")                                              
DbSetOrder(2) 
MsSeek(xFilial("SBL")+cAnoMes)

While (! SBL->(EOF()) .and. xFilial("SBL")==SBL->BL_FILIAL .and. SBL->(BL_ANO+BL_MES) == cAnoMes)

   aFormula := Mt295Form(SBL->BL_PRODUTO)                                             
   
   IF Len(aFormula) > 0
	   SBL->(RecLock("SBL",.F.))
	   SBL->BL_CODFORM := aFormula[1,4]
	   SBL->BL_PORFOR1 := If(aFormula[1,2] > 999.99, 999.99, aFormula[1,2])
	   SBL->BL_QTDFOR1 := aFormula[1,3]
	   SBL->BL_CODFOR2 := aFormula[2,4]
	   SBL->BL_PORFOR2 := If(aFormula[2,2] > 999.99, 999.99, aFormula[2,2])
	   SBL->BL_QTDFOR2 := aFormula[2,3]
	   SBL->BL_CODFOR3 := aFormula[3,4]
	   SBL->BL_PORFOR3 := If(aFormula[3,2] > 999.99, 999.99, aFormula[3,2])
	   SBL->BL_QTDFOR3 := aFormula[3,3]
	   SBL->BL_CODFOR4 := aFormula[4,4]
	   SBL->BL_PORFOR4 := If(aFormula[4,2] > 999.99, 999.99, aFormula[4,2])
	   SBL->BL_QTDFOR4 := aFormula[4,3]
	   SBL->(MsUnlock())
   EndIf	   
   SBL->(DbSkip())             
EndDo                         
Return 
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Mt295Form    ³ Autor ³ Alex Sandro Valario   ³ Data ³ 14/04/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Sugere a melhor formula                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Mt295Form()                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Mata295                       	                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/           
Static Function Mt295Form(cCodProd)

Local aFormulas :={}
Local nX:=0
Local nY:=0
Local cMacroF1 := ""
Local cMacroF2 := ""
Local cMacroF3 := ""
Local cMacroF4 := ""

Private aConsumo :={}
Private nAtual                         

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Carrega formulas                                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If nEstabilid == 1
   Aadd(aFormulas,{"aConsumo[nAtual-1]",0,"PES"})
Else
   Aadd(aFormulas,{"0",0,"PES"})
endif   

If nMedias == 1                       
   Aadd(aFormulas,{"(aConsumo[nAtual-1]+aConsumo[nAtual-2]+aConsumo[nAtual-3])/3",0,"PME"})
Else
   Aadd(aFormulas,{"0",0,"PME"})
endif   

If nTendencia == 1                                                               
   Aadd(aFormulas,{"aConsumo[nAtual-1]+(aConsumo[nAtual-1]-aConsumo[nAtual-2])",0,"PTE"})
Else
   Aadd(aFormulas,{"0",0,"PTE"})
endif   

If nSazonalid == 1 
   Aadd(aFormulas,{"aConsumo[nAtual-12]*((aConsumo[nAtual-1]+aConsumo[nAtual-2]+aConsumo[nAtual-3])/(aConsumo[nAtual-13]+aConsumo[nAtual-14]+aConsumo[nAtual-15]))",0,"PSA"})
Else
   Aadd(aFormulas,{"0",0,"PSA"})
EndIf             

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Carrega Formula customizada do usuario                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If ! Empty(cCodFormu)  

   SB1->(MsSeek(xFilial("SB1")+SBL->BL_PRODUTO)) // Caso exista referencia á SB1 na formula
    
   For nX := 1 To Len(cCodFormu) Step 4
      IF Empty(Subs(cCodFormu,nX,3))
         Exit
      EndIf   
      SM4->(DbSetOrder(1)) //M4_FILIAL+M4_CODIGO
      IF SM4->(MsSeek(xFilial("SM4")+Subs(cCodFormu,nX,3)))
         Aadd(aFormulas,{&(SM4->M4_FORMULA),0,Subs(cCodFormu,nX,3)})
      EndIf
   Next
Endif 
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Carrega consumo                                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aConsumo := Mt295Cons(cAnoMes,cCodProd)

nAtual    :=len(aConsumo)
For nX := 1 to nMesAval
   For nY := 1 to Len(aFormulas)
		cFormula :=aFormulas[nY,1] 
		nValor := &cFormula // valor sugerido 
		aFormulas[nY,2] += ((nValor-aConsumo[nAtual])/aConsumo[nAtual])*100
   Next
   nAtual--                                 
Next              

For nX := 1 to  Len(aFormulas)
   aFormulas[nx,2] := Abs(aFormulas[nx,2])
Next

nAtual    :=len(aConsumo)
If nAtual > 0
	aFormulas := aSort(aFormulas,,,{|x,y| x[2] < y[2]})
	cMacroF1 :=aFormulas[1,1]
	cMacroF2 :=aFormulas[2,1]
	cMacroF3 :=aFormulas[3,1]
	cMacroF4 :=aFormulas[4,1]
Endif	

Return { { aFormulas[1,1],aFormulas[1,2],&cMacroF1,aFormulas[1,3] },;
      	{ aFormulas[2,1],aFormulas[2,2],&cMacroF2,aFormulas[2,3] },;
   		{ aFormulas[3,1],aFormulas[3,2],&cMacroF3,aFormulas[3,3] },;
   		{ aFormulas[4,1],aFormulas[4,2],&cMacroF4,aFormulas[4,3] } }

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Mt295Cons ³ Autor ³ Alex Sandro Valario   ³ Data ³ 14/04/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Acumula no Array aConsumo a demanda dos produtos			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Mt295Cons			 									  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Mata295                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/           
Function Mt295Cons(cAnoMes,cCodProd)

Local nX        := 0
Local nLen      := 0
Local nRecnoSBL := SBL->(Recno())
Local nOrdemSBL := SBL->(IndexOrd())
Local cPAnoMes  := ""
Local aConsumo  := {}            
Static nMeses	:= 0 
Static nAnoIni  := 0
Static nMesIni  := 0  

SBL->(DBSetOrder(1))
SBL->(MsSeek(xFilial("SBL")+cCodProd))

While (! SBL->(Eof()) .and. xFilial("SBL")==SBL->BL_FILIAL .and. SBL->BL_PRODUTO ==cCodProd);
	.And. SBL->BL_ANO+SBL->BL_MES <= cAnoMes

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Adiciona no array a demanda do produto                                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Aadd(aConsumo,SBL->BL_DEMANDA)
	cPAnoMes := SBL->BL_ANO+SBL->BL_MES

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Passa para o proximo registro e verfica o produto                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	SBL->(DbSkip())              
	If ! SBL->(Eof()) .and. SBL->BL_PRODUTO ==cCodProd
	
		IF Right(cPAnoMes,2)=="12"
			cPAnoMes := Str(Val(Left(cPAnoMes,4))+1,4)+"01"
		Else
			cPAnoMes := Left(cPAnoMes,4)+StrZero(Val(Right(cPAnoMes,2))+1,2)
		Endif
		
		While cPAnoMes < SBL->BL_ANO+SBL->BL_MES
			Aadd(aConsumo,0 )      
			IF Right(cPAnoMes,2)=="12"
				cPAnoMes := Str(Val(Left(cPAnoMes,4))+1,4)+"01"
			Else
				cPAnoMes := Left(cPAnoMes,4)+StrZero(Val(Right(cPAnoMes,2))+1,2)
			EndIf   
		EndDo
		
	EndIf
	
EndDo			              

SBL->(DbSetOrder(nOrdemSBL))        
SBL->(DbGoto(nRecnoSBL))

nLen :=len(aConsumo)

If Len(aConsumo) < 120
   For nX := 1 to 120-nLen
      aadd(aConsumo,0)
      aIns(aConsumo,1)
      aConsumo[1] := 0
   Next   
EndIf

Return aConsumo

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ A295Tipo ³ Autor ³ Aline Sebrian         ³ Data ³ 25/09/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Verifica a existencia do Tipo na Tabela de Parametros.     ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ A295Tipo()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T. / .F.                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MatA295                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A295Tipo()

Local cVar      := &(ReadVar())
Local aArea		:= GetArea()
Local lRet      := .T.

dbSelectArea("SX5")
MsSeek(xFilial("SX5")+"02"+cVar)
If !Found()
	Help(" ",1,"MA01002")
	lRet := .F.
EndIf
RestArea( aArea )
Return(lRet)
