#Include "Protheus.Ch"      
#Include "REPORT.CH"
#Include "COMA100.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³COMA100   ºAutor  ³Tiago Tudisco       º Data ³  20/05/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Rotina de criacao da tela de log dos processos de           º±±
±±º          ³solicitacao de compras.                                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ CNI                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ºAlterado por: Rodrigo Guerato - FSW - 15/01/2013                       º±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß        
*/                                   
Function COMA100()

Local oDlg
Local oLbx
Local oLbxCOK
Local oLbxCOH                                         
Local oGrp1
Local oGrp2
Local oGrp3
Local cTitulo 	:= STR0001//"Log dos Processos de Solicitação de Compras"
Local aCab 		:= {}
Local nOpca		:= 0
Local nCont		:= 1 
Local nPos		:= TamSX3("F1_DOC")[1] + 1 //posicao inicial para buscar os dados do pedido
Local nTamItCOH	:= TamSX3("COH_ITEM")[1]
Local nTamItPOH	:= TamSX3("COH_ITPED")[1]
Local nTamItCOI	:= TamSX3("COI_ITEM")[1]
Local nTamItCOK	:= TamSX3("COK_ITEM")[1]

Local cNumFilial:= ''
Local cNumSC	:= SC1->C1_NUM
Local cItemSC	:= SC1->C1_ITEM
Local cChave  := ""   
Local lFilOri := .F.

Local oPanel1 
Local oPAnel2

Local aArea		:= getArea()
Local aButtons	:= {}

Local lAnaCot := .F.
Local cFilCN9
Local nPosLog := 0
   
Private aVetor 	:= {}
Private aVetCOK 	:= {}
Private aVetCOH	:= {} 

//ADICIONA UMA OPCAO NA ENCHOICEBAR
aadd(aButtons   ,{"BUDGET",   {|| COMREL100()}    ,STR0020,STR0002}) //"Imprimir"##"Imprime Log de Processos"
                    
//Pega o nome da filial
If !Empty( SC1->C1_FILIAL )                                   
	cNumFilial := SC1->C1_FILIAL+' - '+AllTrim(SM0->M0_FILIAL)
EndIf         

lFilOri := !Empty(SC1->C1_FISCORI)


SC7->(DbSetOrder(1))//C7_FILIAL+C7_NUM+C7_ITEM+C7_SEQUEN

dbSelectArea("COI")
dbSetOrder(1)//COI_FILIAL+COI_NUMSC+COI_ITEM+COI_PNCHAV

dbSeek(xFilial() + SC1->C1_NUM + RIGHT(SC1->C1_ITEM,nTamItCOI))

// Carrega o vetor conforme a condicao. Rodrigo 
While !Eof() .And. xFilial() + SC1->C1_NUM + RIGHT(SC1->C1_ITEM,nTamItCOI) == xFilial()+COI_NUMSC+COI_ITEM
	//Carrego os dados no Array somente referente a tabela COI
	
   //SOLICITACAO DE COMPRAS     
   if ( !Empty(COI->COI_DOCSC) )
	   aAdd( aVetor, { COI->COI_DOCSC, ; //Caio.Santos - FSW - 24/02/2012 - Adicionados campos para gravar n. do documento envolvido no processo
   						STR0003, ; //"Solicitação de Compra"
   						Substring(COI->COI_DTHSOL,1,10), ;
   						Substring(COI->COI_DTHSOL,12,19), ;
   						COI->COI_USOL} )
   Endif
   					
	//APROVACAO	 
	if ( !Empty(COI->COI_DOCAPR) )
	   aAdd( aVetor, { COI->COI_DOCAPR, ;
   						STR0004, ; //"Aprovação"
   						Substring(COI->COI_DTHAPR,1,10), ;
   						Substring(COI->COI_DTHAPR,12,19), ;
   						COI->COI_UAPR} )
 	Endif
   					
 	//GERACAO DA COTACAO 
 	if ( !Empty(COI->COI_DOCCOT) )
 		aAdd( aVetor, { COI->COI_DOCCOT, ;
   						STR0006, ;   //"Geração da Cotação"
   						Substring(COI->COI_DTHCOT,1,10), ;
   						Substring(COI->COI_DTHCOT,12,19), ;
   						COI->COI_UCOT} )
  	Endif
   					
	//ANALISE DA COTACAO
	If ( !Empty(COI->COI_DOCANL) ) 
		DbSelectArea("SC8")
		SC8->(DbSetOrder(1))
		If (SC8->(DbSeek(xFilial("SC8") + SubStr(COI->COI_DOCANL, 1, TamSX3("C8_NUM")[1]))))
			While ((SC8->(!Eof())) .And. (SC8->C8_FILIAL == xFilial("SC8")) .And. (SC8->C8_NUM == SubStr(COI->COI_DOCANL, 1, TamSX3("C8_NUM")[1])))
				If !((Empty(SC8->C8_NUMPED)) .And. (SC8->C8_PRECO <> 0) .And. (!Empty(SC8->C8_COND)))
					lAnaCot := .T.
				Endif
				
				SC8->(DbSkip())
			Enddo
		Endif
		
		If (lAnaCot)
			aAdd( aVetor, { COI->COI_DOCANL, ;
   						STR0008, ; //"Análise da Cotação"
   						Substring(COI->COI_DTHANL,1,10), ;
   						Substring(COI->COI_DTHANL,12,19), ;
   						COI->COI_UANL} )
		Endif
  	Endif
   					
 	//CONTRATO
 	If ( !Empty(COI->COI_DOCCTR) ) 		
		If ! lAnaCot //não achou analise da cotação no passo anterior
			aAdd( aVetor, { COI->COI_DOCANL, ;
   						STR0008, ; //"Análise da Cotação"
   						Substring(COI->COI_DTHANL,1,10), ;
   						Substring(COI->COI_DTHANL,12,19), ;
   						COI->COI_UANL} )
		Endif

		aAdd( aVetor, {iif( lFilOri, AllTrim(COI->COI_DOCCTR) + " - " + SC1->C1_FISCORI, COI->COI_DOCCTR ), ;
					STR0009, ; //"Contrato"
					Substring(COI->COI_DTHCTR,1,10), ;
					Substring(COI->COI_DTHCTR,12,19), ;
					COI->COI_UCTR} ) 		
 		
   Endif
   					
 	//Geracao do Edital - Caio.Santos - FSW - 27/02/2012  
 	If ( !Empty(COI->COI_DOCEDT) )
	 	aAdd( aVetor, { COI->COI_DOCEDT, ;
   						STR0005, ; //"Geração do Edital"
   						Substring(COI->COI_DTHEDT,1,10), ;
   						Substring(COI->COI_DTHEDT,12,19), ;
   						COI->COI_UEDT} )  
   Endif
   					             
  	//Transferencia de SC entre Filiais - FSW - 15/01/2013
	If ( !Empty(COI->COI_DOCTRA) )   					
 		aAdd( aVetor, { COI->COI_DOCTRA + " - " + COI->COI_FILTRA, ;
  	 						STR0021, ; //"Transferência de SC"
   						Substring(COI->COI_DTHTRA,1,10), ;
   						Substring(COI->COI_DTHTRA,12,19), ;
   						COI->COI_UTRA} )  
  Endif
   					
   	//Alimento o array aVetCOK com base na tabela COK
   	dbSelectArea("COK")
   	COK->(dbSetOrder(1)) //COK_NUMSC+COK_ITEM+COK_FORNECE+COK_LOJA
   	COK->(dbSeek(xFilial("COK")+COI->COI_NUMSC+PADL(COI->COI_ITEM,nTamItCOK,"0")))
   	While COI->(!Eof()) .and. xFilial("COK")+COI->COI_NUMSC+PADL(COI->COI_ITEM,nTamItCOK,"0") == xFilial("COK")+COK->COK_NUMSC+COK->COK_ITEM 
   	
		//ATUALIZACA DA COTACAO
		If ( !Empty(COK->COK_DOCATL) )
			aAdd( aVetCOK, { COK->COK_FORNECE,;
		 						COK->COK_LOJA,   ; 
	 							COK->COK_DOCATL, ;
	   						STR0007, ;//"Atualização da Cotação"
	   						Substring(COK->COK_DTHATL,1,10), ;
	   						Substring(COK->COK_DTHATL,12,19), ;
	   						COK->COK_UATL} )
	  	Endif
	   					
	  	//INCLUSAO DO PEDIDO
		If ( !Empty(COK->COK_DOCPED) )			
			If((nPosLog := aScan(aVetCOK,{|x| Left(x[3], Len(COK->COK_DOCPED)) == COK->COK_DOCPED})) > 0)
				If(SC7->(DbSeek(xFilial("SC7") + COK->(Left(COK_DOCPED,Len(SC7->C7_NUM))+ Left(COK_ITPED,Len(SC7->C7_ITEM))))) .And. !Empty(SC7->C7_MEDICAO))
					aVetCOK[nPosLog, 4] := STR0028 + " - " + SC7->C7_MEDICAO
				EndIf
			EndIf
		
		 	aAdd( aVetCOK, { COK->COK_FORNECE,;
			 					COK->COK_LOJA,   ; 
			 					iif( lFilOri, AllTrim(COK->COK_DOCPED) + " - " + SC1->C1_FISCORI, COK->COK_DOCPED ), ;
	   						STR0010, ;//"Inclusão do Pedido"
	   						Substring(COK->COK_DTHPED,1,10), ;
	   						Substring(COK->COK_DTHPED,12,19), ;
	   						COK->COK_UPED} )
	   Endif

	  	//LIBERACAO DO PEDIDO     
		If ( !Empty(COK->COK_DOCLIB) )
		  	aAdd( aVetCOK, { COK->COK_FORNECE,;
		 						COK->COK_LOJA,   ;  
	  							COK->COK_DOCLIB, ;
	   						STR0011, ;//"Liberação do Pedido"
	   						Substring(COK->COK_DTHLIB,1,10), ;
	   						Substring(COK->COK_DTHLIB,12,19), ;
	   						COK->COK_ULIB} )
	 	Endif
	   					
	   	//Antes de trocar de registro, vejo se tem documentos para este pedido
	   	If (!Empty(COK->COK_DOCPED)) .and. (!Empty(COK->COK_ITPED))
	   		dbSelectArea("COH")
	   		COH->(dbSetOrder(1)) //COH_NUMSC+COH_ITEM+COH_DOCPED+COH_ITPED+COH_CHAVPN
	   		cChave := xFilial("COH") + COK->COK_NUMSC + RIGHT(COK->COK_ITEM,nTamItCOH) + PadR(COK->COK_DOCPED, TamSX3("COK_DOCPED")[1]) + RIGHT(COK->COK_ITPED,nTamItPOH)
	   		COH->(dbSeek(cChave))
	   		
	   		While COH->(!Eof()) .and. xFilial("COH")+COK->COK_NUMSC + RIGHT(COK->COK_ITEM,nTamItCOH)+COK->COK_DOCPED+ RIGHT(COK->COK_ITPED,nTamItPOH) == ;
	   										  xFilial("COH")+COH->COH_NUMSC + COH->COH_ITEM+COH->COH_DOCPED+COH->COH_ITPED
	   		
				//LANCAMENTO DA PRE-NOTA     COH->COH_PNCHAV
				if ( !Empty(COH->COH_PNCHAV) )
			 		aAdd( aVetCOH, {COH->COH_DOCPED, ;
									  COH->COH_ITPED,  ; 
									  SubString(COH->COH_PNCHAV,nPos,TamSX3("F1_SERIE")[1]) + " / " + SubString(COH->COH_PNCHAV,1,TamSX3("F1_DOC")[1]), ;
									  STR0012, ; //"Lançamento da Pré-Nota"
									  Substring(COH->COH_DTHLPN,1,10), ;
									  Substring(COH->COH_DTHLPN,12,19), ;
								  	  COH->COH_ULPN} )
				Endif
								  
				//ATESTO SOLICITANTE
				if ( !Empty(COH->COH_PNCHAV) .And. !Empty(COH->COH_DTHATS) )
			  		aAdd( aVetCOH, {COH->COH_DOCPED, ;
									  COH->COH_ITPED,  ;
									  SubString(COH->COH_PNCHAV,nPos,TamSX3("F1_SERIE")[1]) + " / " + SubString(COH->COH_PNCHAV,1,TamSX3("F1_DOC")[1]), ;
									  STR0013, ; //"Atesto Solicitante"
									  Substring(COH->COH_DTHATS,1,10), ;
									  Substring(COH->COH_DTHATS,12,19), ;
									  COH->COH_UATS} )
				Endif
				
				//CLASSIFICACAO DA NOTA   
				if ( !Empty(COH->COH_PNCHAV) .And. !Empty(COH->COH_DTHCLS) )
			  		aAdd( aVetCOH, {COH->COH_DOCPED, ;   	
									  COH->COH_ITPED,  ;
									  SubString(COH->COH_PNCHAV,nPos,TamSX3("F1_SERIE")[1]) + " / " + SubString(COH->COH_PNCHAV,1,TamSX3("F1_DOC")[1]), ;
									  STR0014, ; //"Classificação da Nota"
									  Substring(COH->COH_DTHCLS,1,10), ;
									  Substring(COH->COH_DTHCLS,12,19), ;
									  COH->COH_UCLS} ) 
				Endif
				
	   			COH->(dbSkip())
	   		End 
	   	Endif

   		COK->(dbSkip())
   	End
	
	COI->(dbSkip())
End

// Se não houver dados no vetor, avisar usuário e abandonar rotina.
If Len( aVetor ) == 0
   Aviso( cTitulo, STR0016+SC1->C1_NUM, {STR0017} )//"Não existe log gravado para esta Solicitação: "
   Return
Endif

// Monta a tela para usuário visualizar consulta.

DEFINE MSDIALOG oDlg TITLE cTitulo FROM 0,0 To 39,88 OF oMainWnd

@ 38, 006 SAY STR0025	 SIZE 70,7 PIXEL OF oPanel1  //"Filial:"
@ 52, 006 SAY STR0026	 SIZE 70,7 PIXEL OF oPanel1   //"Num. SC:"
@ 52, 095 SAY STR0027	 SIZE 70,7 PIXEL OF oPanel1   //"Item SC:"

@ 37, 030 MSGET cNumFilial 	When .F.	SIZE 130,7 PIXEL OF oPanel1 
@ 51, 030 MSGET cNumSC 		When .F. 	SIZE 060,7 PIXEL OF oPanel1 
@ 51, 120 MSGET cItemSC 		When .F.	SIZE 040,7 PIXEL OF oPanel1

oPanel1 := TPanel():New(0,0,"",oDlg,NIL,.T., .F.,NIL,NIL,0,30,.T.,.F.)

oGrp1 := TGroup():New(05,01,10,43,STR0022,oDlg,,,.F.) //"Documentos por Solicitação"
@ 80,12 LISTBOX oLbx FIELDS HEADER "N. Documento", "Processo", "Data", "Hora", "Usuário" SIZE 327,55 PIXEL OF oGrp1

oGrp2 := TGroup():New(10,01,15,43,STR0023,oDlg,,,.F.) //"Documentos por Fornecedor/Loja"
@ 150,12 LISTBOX oLbxCOK	FIELDS HEADER "Fornecedor", "Loja", "N. Documento", "Processo", "Data", "Hora", "Usuário" SIZE 327,55 PIXEL OF oGrp2

oGrp3 := TGroup():New(15,01,20,43,STR0024,oDlg,,,.F.) //"Documentos por Pedido/Item"
@ 220,12 LISTBOX oLbxCOH FIELDS HEADER "N. Pedido" , "Item Ped.", "N. Documento", "Processo", "Data", "Hora", "Usuário" SIZE 327,55 PIXEL OF oGrp3

If Len(aVetor) > 0
	//Antes de exibir, ordena por data/hora
	aSort( aVetor, , , {|x,y| DToS(CToD(x[3]))+x[4] < DToS(CToD(y[3]))+y[4] } )
	oLbx:SetArray(aVetor)
	oLbx:bLine 	:= {|| {aVetor[oLbx:nAt,1],;
                   		 aVetor[oLbx:nAt,2],;
                   		 aVetor[oLbx:nAt,3],;
                   		 aVetor[oLbx:nAt,4],;
                   		 aVetor[oLbx:nAt,5]}}
Endif

If Len(aVetCOK) > 0 
	//Antes de exibir, ordena por data
	aSort( aVetCOK, , , {|x,y| DToS(CToD(x[5]))+x[6] < DToS(CToD(y[5]))+y[6] } )
	oLbxCOK:SetArray(aVetCOK)
	oLbxCOK:bLine 	:= {|| {aVetCOK[oLbxCOK:nAt,1],;
                 			 aVetCOK[oLbxCOK:nAt,2],;
                   		 	 aVetCOK[oLbxCOK:nAt,3],;
                   		 	 aVetCOK[oLbxCOK:nAt,4],;
                   		 	 aVetCOK[oLbxCOK:nAt,5],;
                   		 	 aVetCOK[oLbxCOK:nAt,6],;
                   		 	 aVetCOK[oLbxCOK:nAt,7]}}
Endif                   		 
     
If Len(aVetCOH) > 0                    		 
	//Antes de exibir, ordena por data
	aSort( aVetCOH, , , {|x,y| DToS(CToD(x[5]))+x[6] < DToS(CToD(y[5]))+y[6] } )
	oLbxCOH:SetArray(aVetCOH)
	oLbxCOH:bLine 	:= {|| {aVetCOH[oLbxCOH:nAt,1],;
     	                	 aVetCOH[oLbxCOH:nAt,2],;
                   		 	 aVetCOH[oLbxCOH:nAt,3],;
	                    	 aVetCOH[oLbxCOH:nAt,4],;
                   		 	 aVetCOH[oLbxCOH:nAt,5],;
	                   		 aVetCOH[oLbxCOH:nAt,6],;
                   		 	 aVetCOH[oLbxCOH:nAt,7]}}
Endif
                   		 	  
ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg,{||oDlg:End()},{||oDlg:End()},,aButtons)

RestArea(aArea)

Return             
                 
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³COMREL100 ºAutor  ³Tiago Tudisco       º Data ³  23/05/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Emite relatorio dos dados apresentados no ListBox           º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ CNI                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function COMREL100()

Local cTitulo    := STR0018 //"Log dos Processos de Solicitação de Compras"

Local oDados1  //Section
Local oReport
Local aDados   := {aVetor,aVetCOK,aVetCOH}//Array com os dados a serem impressos no relatorio
Local cTmp 	 := GetNextAlias()	//tabela temporaria
Local aOrd		 := {}

oReport := TReport():New("COMREL100",cTitulo,,;
{|oReport| DefPrint( oReport, aOrd, cTitulo, aDados, cTmp )}, STR0019) //"Este relatório irá imprimir o Log dos Processos de SC conforme apresentados na consulta."

oReport:nFontBody  := 9  
oReport:nLineHeight:= 40

//DEFINE SECTION oDados1 OF oReport TABLES cTmp TITLE cTitulo ORDERS aOrd  
oDados1:=TRSection():New( oReport,"cTitulo",{cTmp},aOrd,,,,,,,,,3)

DEFINE CELL NAME "TMP_FORNE"	OF oDados1 ALIAS cTmp TITLE "Fornecedor"	SIZE 06
DEFINE CELL NAME "TMP_LOJA"	OF oDados1 ALIAS cTmp TITLE "Loja"		 	SIZE 02
DEFINE CELL NAME "TMP_NUMPED"	OF oDados1 ALIAS cTmp TITLE "Pedido   " 	SIZE 06
DEFINE CELL NAME "TMP_ITPED"	OF oDados1 ALIAS cTmp TITLE "Item PD"		SIZE 04
DEFINE CELL NAME "TMP_NUMPN"	OF oDados1 ALIAS cTmp TITLE "Pre-Nota"		SIZE 12
DEFINE CELL NAME "TMP_NUMSC"	OF oDados1 ALIAS cTmp TITLE "Num. SC"		SIZE 10
DEFINE CELL NAME "TMP_ITEM "	OF oDados1 ALIAS cTmp TITLE "Item" 			SIZE 06
DEFINE CELL NAME "TMP_PROCES"	OF oDados1 ALIAS cTmp TITLE "Processo"		SIZE 25
DEFINE CELL NAME "TMP_DATA"	OF oDados1 ALIAS cTmp TITLE "Data"			SIZE 10     
DEFINE CELL NAME "TMP_HORA"	OF oDados1 ALIAS cTmp TITLE "Hora"			SIZE 10
DEFINE CELL NAME "TMP_USUARI"	OF oDados1 ALIAS cTmp TITLE "Usuário"		SIZE 20

oReport:PrintDialog()                                       

Return
              
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³DefPrint  ºAutor  ³Tiago Tudisco       º Data ³  23/05/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Estrutura dados para impressao.                             º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³CNI											              º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function DefPrint( oReport, aOrd, cTitulo, aDados, cTmp)

Local oSection1 := oReport:Section(1)

//Criação do objeto
oTempTable := FWTemporaryTable():New( cTmp )

//Cria arquivo de trabalho
aStru := {}
AADD(aStru,{"TMP_FORNE"		,"C", 06, 0})
AADD(aStru,{"TMP_LOJA"		,"C", 02, 0})
AADD(aStru,{"TMP_NUMPED"	,"C", 12, 0})
AADD(aStru,{"TMP_ITPED"		,"C", 04, 0})
AADD(aStru,{"TMP_NUMPN"		,"C", 12, 0})
AADD(aStru,{"TMP_NUMSC"		,"C", 10, 0})
AADD(aStru,{"TMP_ITEM"		,"C", 06, 0})	
AADD(aStru,{"TMP_PROCES"	,"C", 25, 0})
AADD(aStru,{"TMP_DATA"		,"C", 10, 0})
AADD(aStru,{"TMP_HORA"		,"C", 10, 0})
AADD(aStru,{"TMP_USUARI"	,"C", 20, 0})

oTempTable:SetFields( aStru )

//Criação da tabela
oTempTable:Create()

//Preenche arquivo de trabalho conforme dados da tela
PreencheTMP(aDados, cTmp)
	
oReport:SetTitle(cTitulo)

oSection1:Print()

//Exclui a tabela 
oTempTable:Delete()

Return      

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PreencheTMPºAutor  ³Tiago Tudisco      º Data ³  23/05/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Preenche arquivo de trabalho utilizado para relatorio       º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ CNI                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function PreencheTMP(aDados, cAlias)
Local nY := 0
Local nX := 0   
	
	//Varre array de dados e grava informacoes na tabela temporaria
	For nX := 1 to Len(aDados)
		For nY := 1 to Len(aDados[nX])
			DbSelectArea(cAlias)
			RecLock(cAlias,.T.)
				//Todos os campos são do tipo caracter
				(cAlias)->( TMP_FORNE 	)	:= Iif(Len(aDados[nX][nY])==7,Iif(nX==2,aDados[nX][nY][1],""),"")  
				(cAlias)->( TMP_LOJA 	)	:= Iif(Len(aDados[nX][nY])==7,Iif(nX==2,aDados[nX][nY][2],""),"")
				(cAlias)->( TMP_NUMPED 	)	:= Iif(Len(aDados[nX][nY])==7,Iif(nX==3,aDados[nX][nY][1],""),"")
				(cAlias)->( TMP_ITPED 	)	:= Iif(Len(aDados[nX][nY])==7,Iif(nX==3,aDados[nX][nY][2],""),"")   
				(cAlias)->( TMP_NUMPN 	)	:= Iif(Len(aDados[nX][nY])==7,aDados[nX][nY][3],aDados[nX][nY][1])
				(cAlias)->( TMP_NUMSC 	)	:= SC1->C1_NUM 
				(cAlias)->( TMP_ITEM 	)	:= SC1->C1_ITEM 
				(cAlias)->( TMP_PROCES	)	:= Iif(Len(aDados[nX][nY])==7,aDados[nX][nY][4],aDados[nX][nY][2]) //aDados[2] 		
				(cAlias)->( TMP_DATA  	) 	:= Iif(Len(aDados[nX][nY])==7,aDados[nX][nY][5],aDados[nX][nY][3]) //aDados[3] 
				(cAlias)->( TMP_HORA 	)	:= Iif(Len(aDados[nX][nY])==7,aDados[nX][nY][6],aDados[nX][nY][4]) //aDados[4] 
				(cAlias)->( TMP_USUARI	) 	:= Iif(Len(aDados[nX][nY])==7,aDados[nX][nY][7],aDados[nX][nY][5]) //aDados[5]
			MsUnlock()
			//GravaRecTMP(aDados[nX][nY], cAlias)
		Next nY
	Next nX	                                                                    			
	
Return
    
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GravaRecTMP ºAutor  ³Tiago Tudisco     º Data ³  23/05/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Funcao auxiliar para gravacao em arquivo de trabalho do relaº±±
±±º          ³torio.                                                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ CNI                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function GravaRecTMP(aDados, cAlias)

	DbSelectArea(cAlias)
	RecLock(cAlias,.T.)
		//Todos os campos são do tipo caracter
		(cAlias)->( TMP_NUMPN 	)	:= aDados[1]
		(cAlias)->( TMP_NUMSC 	)	:= SC1->C1_NUM 
		(cAlias)->( TMP_ITEM 	)	:= SC1->C1_ITEM 
		(cAlias)->( TMP_PROCES	)	:= aDados[2] 		
		(cAlias)->( TMP_DATA  	) 	:= aDados[3] 
		(cAlias)->( TMP_HORA 	)	:= aDados[4] 
		(cAlias)->( TMP_USUARI	) 	:= aDados[5] 

	MsUnlock()
	
Return
