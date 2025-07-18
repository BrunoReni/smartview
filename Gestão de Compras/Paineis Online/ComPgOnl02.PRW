#INCLUDE "Protheus.ch"
#INCLUDE "Msgraphi.ch"
#INCLUDE "ComPgOnl02.ch"

Static aViewDoc  := {}

/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �ComPgOnl02� Autor �Alexandre Inacio Lemes � Data � 29/01/2007 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o �Monta array para Painel de Gestao Tipo 5:                     ���
���          �Aprovadores com Saldo Disponivel para Aprovacoes              ���
���������������������������������������������������������������������������Ĵ��
���Retorno   � Array  = {bClick,aCabec,aValores)                            ���
���          � bClick = Bloco de codigo para execucao duplo-click no Browse ���
���          � aCabec = Array contendo o cabecalho             		        ���
���          � aValores = Array contendo os valores da lista                ���
���������������������������������������������������������������������������Ĵ��
���Uso       � SIGACOM                                                      ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/        
Function ComPgOnl02()

Local aTitle    := {STR0001,STR0002,STR0003,STR0004}   //###### // //######### //"Aprovador"###"Nome"###"Saldo Disponivel"###"Limite"
Local aStruSCR  := {}
Local aArraySCR := {}
Local aPanel    := {}
Local aAprovador:= {}
Local aViewSLD  := {}
Local aPutVar   := {}

Local cAliasSCR := "SCR"
Local cIndSCR	:= ""
Local cQuery    := ""
Local cTipo     := ""
Local cSimbMoeda:= ""

Local nOrderSCR := 0 
Local nSaldo    := 0
Local nX        := 0

Local lQuery    := .F.

dbSelectArea("SCS")
dbSetOrder(2)

dbSelectArea("SAK")
dbSetOrder(2)

dbSelectArea("SCR")
dbSetOrder(1)

lQuery := .T.
cAliasSCR := GetNextAlias()
aStruSCR  := SCR->(dbStruct())
cQuery := "SELECT * "
cQuery += "FROM "+RetSqlName("SCR")+" "
cQuery += "WHERE CR_FILIAL='"+xFilial("SCR")+"' AND "
cQuery += "( CR_STATUS='01' OR CR_STATUS='02' ) AND "
cQuery += "D_E_L_E_T_ = ' ' "
cQuery += "ORDER BY "+SqlOrder(SCR->(IndexKey()))

cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSCR)

For nX := 1 To len(aStruSCR)
	If aStruSCR[nX][2] <> "C"
		TcSetField(cAliasSCR,aStruSCR[nX][1],aStruSCR[nX][2],aStruSCR[nX][3],aStruSCR[nX][4])
	EndIf
Next nX
dbSelectArea(cAliasSCR)

While ( !(cAliasSCR)->(Eof()) .And. (cAliasSCR)->CR_FILIAL == xFilial("SCR") )
	
	If Ascan(aArraySCR,(cAliasSCR)->CR_NUM + (cAliasSCR)->CR_TIPO ) == 0
		
		Aadd(aArraySCR, (cAliasSCR)->CR_NUM + (cAliasSCR)->CR_TIPO )
		
		SAK->(dbSetOrder(2))
		SAK->(MsSeek(xFilial("SAK") + (cAliasSCR)->CR_USER))
		If (cAliasSCR)->CR_TIPO <> "NF"  
			If Ascan(aAprovador, SAK->AK_COD ) == 0
				Aadd(aAprovador,SAK->AK_COD)
				aRetSaldo := MaSalAlc((cAliasSCR)->CR_APROV,dDataBase)
				nSaldo 	  := aRetSaldo[1]

				If SAK->AK_TIPO == "D"
				   cTipo := STR0005 // // //"Diario"
				ElseIf SAK->AK_TIPO == "S"
				   cTipo := STR0006 // // //"Semanal"
				ElseIf SAK->AK_TIPO == "M"
				   cTipo := STR0007 // // //"Mensal"
				EndIf
				      
        		cSimbMoeda := buscamoeda(SAK->AK_MOEDA)

                If nSaldo >= (cAliasSCR)->CR_TOTAL
					Aadd(aViewSLD,{Substr(SAK->AK_COD,1,6),Substr(SAK->AK_NOME,1,25),cSimbMoeda+" "+TransForm(aRetSaldo[1],"@E 9,999,999.99"),TransForm(SAK->AK_LIMITE,"@E 9,999,999.99")+" - "+Substr(cTipo,1,7)})
                EndIf
            EndIf
            if !empty((cAliasSCR)->CR_MOEDA) .and. alltrim((cAliasSCR)->CR_MOEDA) <> "0" 
            	cSimbMoeda := buscamoeda((cAliasSCR)->CR_MOEDA)
	        endif
			Aadd(aViewDoc,{DtoC((cAliasSCR)->CR_EMISSAO),Substr((cAliasSCR)->CR_NUM,1,6),(cAliasSCR)->CR_TIPO,cSimbMoeda+" "+TransForm((cAliasSCR)->CR_TOTAL,"@E 9,999,999.99"),(cAliasSCR)->CR_APROV  })
		EndIf
		
	EndIf
	
	(cAliasSCR)->(dbSkip())
	
EndDo

If Empty(aViewSLD)
	aViewSLD := {{"","","",""}}
EndIf

If Empty(aViewDoc)
	aViewDoc := {{"","","","",""}}
EndIf

//-- Salva as variaveis no server de paineis
aPutVar := { aViewDoc }
PutServerVar("COMPGONL02",aPutVar)

//������������������������������������������������������������������������Ŀ
//�Preenche array do Painel de Gestao tipo 5 - Browse                      �
//��������������������������������������������������������������������������
aPanel := { {|x| COMPView02( x[1] ) } , aTitle , aViewSLD }
//�������������������������������������������������������������������������������������Ŀ
//� Apaga os arquivos de trabalho, cancela os filtros e restabelece as ordens originais.|
//���������������������������������������������������������������������������������������
If lQuery
	dbSelectArea(cAliasSCR)
	dbCloseArea()
Else
  	dbSelectArea("SCR")
	RetIndex("SCR")
	dbClearFilter()
	Ferase(cIndSCR+OrdBagExt())
EndIf

Return aPanel  

/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �COMPView02� Autor �Alexandre Inacio Lemes � Data � 27/01/2007 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o �Consulta os documentos em processo de liberacao na tabela SCR ���
���������������������������������������������������������������������������Ĵ��
���Uso       � ComPanel01                                                   ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/
Function COMPView02(cAprovador)
                           
Local aHeadView := {STR0008,STR0009,STR0010,STR0011,STR0012}  //############ //############ //"Emissao"###"Numero"###"Documento"###"Valor"###"Aguardando Aprovador"
Local aView     := {}
Local aViewDlg  := {}
Local aGetVar   := {}
Local cTitle    := STR0013+cAprovador    // // //"Documentos Aguardando libera��o do Aprovador "
Local nX        := 1
Local oDialog
Local oBrowse

//-- Restaura as variaveis no server de paineis
aGetVar := GetServerVar("COMPGONL02")
If !Empty(aGetVar)
	aViewDoc := aGetVar[1]
EndIf

aViewDlg  := aClone(aViewDoc)

AEval( aViewDlg, { |x| IIF( x[5] == cAprovador , AAdd( aView, x ), ) } )

For nX := 1 to Len(aView)
	Adel( aView[nX] , Len(aView[nX]) )
	ASize(aView[nX] , Len(aView[nX]) - 1 )
Next nX

If Empty(aView)
	aView := {{"","","",""}}
EndIf

DEFINE MSDIALOG oDialog FROM 000,000 TO 245,392 TITLE cTitle OF oMainWnd PIXEL

oBrowse:= TWBrowse():New( 000,000,245,392,,aHeadView,,oDialog,,,,,,,,,,,,.F.,,.T.,,.F.,,,)
oBrowse:SetArray(aView)
oBrowse:bLine := { || aView[oBrowse:nAT] }

ACTIVATE MSDIALOG oDialog CENTERED

Return    

/*
���������������������������������������������������������������������������Ŀ��
���Fun��o    �buscamoeda�							    � Data � 26/10/2018 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o  Busca moeda utilizada, de acordo com a configurada no parametro  MV ���
���������������������������������������������������������������������������Ĵ��
���Uso       � ComPanel02                                                   ���
����������������������������������������������������������������������������ٱ�
*/  
Static function buscamoeda(cMoeda)
  Local cRet
   	cRet:= PadR(GetMv("MV_SIMB"+Alltrim(STR(cMoeda,2,0))),6)
return cRet
