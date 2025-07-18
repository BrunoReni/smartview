#INCLUDE "Protheus.ch"
#INCLUDE "MSgraphi.ch"
#INCLUDE "ComPgOnl07.ch"
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �ComPgOnl07�Autor  �Alexandre Inacio Lemes �Data  �06/02/2007���
�������������������������������������������������������������������������Ĵ��
���Descricao � Monta array para Painel de Gestao On-line Tipo\Padrao 2.2: ���
���          � Contratos de Parceria em Aberto                            ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � Array = {cTypeGraf,{cTitleG,bClickG,aEixoX,aEixoY},        ���
���          � {cTitleT,bClickT,aTabela}}                                 ���
���          � cTypeGraph = Tipo do grafico                       		  ���
���          � cTitleG    = Titulo do grafico                      		  ���
���          � bClickG    = Bloco de codigo executado no click do grafico ���
���          � aEixoX     = Atributos do eixo X                           ���
���          � aEixoY     = Atributos do eixo Y                           ���
���          � cTitleT    = Titulo da tabela                              ���
���          � bClickT    = Bloco de codigo executado no click da tabela  ���
���          � aTabela    = Array multidimensional contendo os array por  ���
���          � filtro, no formato{"filtro",aCabec,aValores}               ���
�������������������������������������������������������������������������Ĵ��
���Uso       � SIGACOM                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function ComPgOnl07()

Local aTitle    := {STR0001,STR0002,STR0003,STR0004,STR0005,STR0006} //"Contrato"###"Fornecedor"###"Data Emiss�o"###"Data Incial"###"Data Final"###"Filial de Entrega"
Local aTipoSC3  := {}
Local aQtdSC3   := {}
Local aSC3Open  := {}
Local aSC3Parc  := {}
Local aSC3Bloq  := {}
Local aPanel    := {}
Local aTable    := {}

Local cAliasSC3 := "SC3"
Local cWhere    := ""
Local cCondicao := ""
Local cIndSC3	:= ""
Local cNumSC3   := ""
Local cFilEntr  := ""
Local cPerg     := "COMPGONL07"         
Local dEmissao  := dDataBase
Local dInicialCP:= dDataBase
Local dFinalCP  := dDataBase

Local nOrderSC3 := 0
Local lQuery    := .F.
Local lOpen     := .F.
Local lParcial  := .F.
Local lBloqued  := .F.

//��������������������������������������������������������������Ŀ
//� Variaveis utilizadas para parametros                         �
//�                                                              �
//� mv_par01            // Produto                     (Range)   �
//� mv_par02            // Fornecedor                  (Range)   �
//� mv_par03            // Loja                        (Range)   �
//� mv_par04            // Data de Emissao             (Range)   �
//����������������������������������������������������������������
Pergunte(cPerg,.F.)
FullRange(cPerg)

dbSelectArea("SA2")
dbSetOrder(1)

dbSelectArea("SC3")
dbSetOrder(1)

//������������������������������������������������������������������������Ŀ
//�Transforma parametros Range em expressao SQL                            �	
//��������������������������������������������������������������������������
MakeSqlExpr(cPerg)
mv_par01 := '%'+mv_par01+'%'
mv_par02 := '%'+mv_par02+'%'
mv_par03 := '%'+mv_par03+'%'
mv_par04 := '%'+mv_par04+'%'

    lQuery    := .T.
cAliasSC3 := GetNextAlias()	

cWhere :="%"
cWhere += " (C3_QUANT - C3_QUJE) > 0 AND C3_RESIDUO = ' ' "	
cWhere +="%"	

BeginSql Alias cAliasSC3

SELECT SC3.* , SC3.R_E_C_N_O_ SC3RecNo 

FROM %table:SC3% SC3

WHERE SC3.C3_FILIAL = %xFilial:SC3%  
AND %Exp:cWhere%
AND SC3.%NotDel% 
AND %Exp:mv_par01%
AND %Exp:mv_par02%
AND %Exp:mv_par03%
AND %Exp:mv_par04%
		  
ORDER BY %Order:SC3% 
		
EndSql 

dbSelectArea(cAliasSC3)

cNumSC3   := (cAliasSC3)->C3_NUM 
cFilEntr  := (cAliasSC3)->C3_FILENT
dEmissao  := STOD((cAliasSC3)->C3_EMISSAO)
dInicialCP:= STOD((cAliasSC3)->C3_DATPRI)
dFinalCP  := STOD((cAliasSC3)->C3_DATPRF)

Do While (cAliasSC3)->(!Eof()) .And. (cAliasSC3)->C3_FILIAL = xFilial("SC3")
	
	SA2->(dbSetOrder(1))
	SA2->(dbSeek( xFilial("SA2") + (cAliasSC3)->C3_FORNECE + (cAliasSC3)->C3_LOJA ))
			
	//������������������������������������������������������������������������������������������������������Ŀ
	//�Identifica se o CP esta em aberto, sendo que nao deve existir nenhum item do CP parcialmente atendido �	
	//��������������������������������������������������������������������������������������������������������
	If (cAliasSC3)->C3_QUJE == 0 .And. (cAliasSC3)->C3_CONAPRO <> "B" .And. lParcial == .F.
        lOpen    := .T.	
	EndIf
	//������������������������������������������������������������������������������������������������������Ŀ
	//�Se exitir um item do CP parcialmente atendido ou atendido o CP sera considerado parcialmente atendido �	
	//��������������������������������������������������������������������������������������������������������	
	If (cAliasSC3)->C3_QUJE > 0 .And. (cAliasSC3)->C3_CONAPRO <> "B"
        lOpen    := .F.	
        lParcial := .T.    
    EndIf
	//������������������������������������������������������������������������������������������������������Ŀ
	//�Se o CP estiver Bloqueado independente do atendimento sera considerado Aguardando liberacao.          �	
	//��������������������������������������������������������������������������������������������������������	    
	If (cAliasSC3)->C3_CONAPRO == "B"
        lBloqued := .T.
	EndIf

	(cAliasSC3)->(dbSkip())

    If (cAliasSC3)->C3_NUM <> cNumSC3 .Or. (cAliasSC3)->(Eof())

	    If lOpen
			Aadd(aSC3Open,{cNumSC3,SA2->A2_NOME,dEmissao,dInicialCP,dFinalCP,cFilEntr })          
		ElseIf lParcial
	 		Aadd(aSC3Parc,{cNumSC3,SA2->A2_NOME,dEmissao,dInicialCP,dFinalCP,cFilEntr })          
	    ElseIf lBloqued
			Aadd(aSC3Bloq,{cNumSC3,SA2->A2_NOME,dEmissao,dInicialCP,dFinalCP,cFilEntr })          
	    EndIf

		//��������������������������������������������������������������������������������������������������Ŀ
		//�Apos a Classificacao do PC alimenta as variaveis para avaliacao do proximo PC a ser classificado. �	
		//����������������������������������������������������������������������������������������������������	    
		cNumSC3   := (cAliasSC3)->C3_NUM 
		cFilEntr  := (cAliasSC3)->C3_FILENT
		dEmissao  := STOD((cAliasSC3)->C3_EMISSAO)
		dInicialCP:= STOD((cAliasSC3)->C3_DATPRI)
		dFinalCP  := STOD((cAliasSC3)->C3_DATPRF)
		
        lOpen     := .F.
        lParcial  := .F.
        lBloqued  := .F.

    EndIf
     
EndDo

If !Empty(aSC3Open)
	Aadd(aTipoSC3,STR0007)  //"N�o Atendidos"
	Aadd(aTable , {aTipoSC3[Len(aTipoSC3)] , aTitle , aSC3Open})
	Aadd(aQtdSC3,Len(aSC3Open))  
EndIf

If !Empty(aSC3Parc)
	Aadd(aTipoSC3,STR0008)  //"Parcialmente Atendidos"
	Aadd(aTable , {aTipoSC3[Len(aTipoSC3)] , aTitle , aSC3Parc})
	Aadd(aQtdSC3,Len(aSC3Parc))  
EndIf

If !Empty(aSC3Bloq)
	Aadd(aTipoSC3, STR0009)  //"Aguardando Libera��o"
	Aadd(aTable , {aTipoSC3[Len(aTipoSC3)] , aTitle , aSC3Bloq})
	Aadd(aQtdSC3,Len(aSC3Bloq))
EndIf

If Empty(aSC3Open) .And. Empty(aSC3Parc) .And. Empty(aSC3Bloq)
	Aadd(aTipoSC3, STR0012) //"Nao foram encotrados Contratos de Parceria em Aberto"
	Aadd(aTable , {aTipoSC3[Len(aTipoSC3)] , aTitle , {{" "," "," "," "," "," "}} })
	Aadd(aQtdSC3,1)
EndIf

//������������������������������������������������������������������������Ŀ
//�Preenche array do Painel de Gestao                                      �
//��������������������������������������������������������������������������
aPanel:= {GRP_PIE, {STR0010,/*bClickG*/,aTipoSC3,aQtdSC3},{STR0011,{ |x| COMPView07( x[1] ) },aTable}} //"Numero de Contratos em Aberto"###"Contratos de Parceria"
			
//�������������������������������������������������������������������������������������Ŀ
//� Apaga os arquivos de trabalho, cancela os filtros e restabelece as ordens originais.|
//���������������������������������������������������������������������������������������
If lQuery
	dbSelectArea(cAliasSC3)
	dbCloseArea()
Else
  	dbSelectArea("SC3") 
	RetIndex("SC3") 
	dbClearFilter()
	Ferase(cIndSC3+OrdBagExt())
EndIf

Return aPanel 

/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �COMPView07� Autor �Alexandre Inacio Lemes � Data � 06/02/2007 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o �Consulta os documentos de Contrato de Parceria                ���
���������������������������������������������������������������������������Ĵ��
���Uso       � ComPgOnl07                                                   ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/
Function COMPView07(cContrato)

Local aArea := GetArea()

dbSelectArea("SC3")
dbSetOrder(1)
If MsSeek(xFilial("SC3")+Substr(cContrato,1,len(SC3->C3_NUM)))
//	Mata125(NIL,NIL,NIL,2) // Aguardando Depto de tecnologia para definicao das regras para chamadas dos programas. 06/02/2007 
EndIf

RestArea(aArea)

Return
