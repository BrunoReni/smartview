#include 'Protheus.ch'
#include 'FWMVCDef.ch'
#include 'MATA020.ch'

Static lLGPD  := FindFunction("SuprLGPD") .And. SuprLGPD()

/*/{Protheus.doc} MATA020EVBRA
Eventos do MVC para o BRASIL, qualquer regra que se aplique somente para BRASIL
deve ser criada aqui, se for uma regra geral deve estar em MATA020EVDEF.

Todas as validações de modelo, linha, pré e pos, também todas as interações com a gravação
são definidas nessa classe.

Importante: Use somente a função Help para exibir mensagens ao usuario, pois apenas o help
é tratado pelo MVC. 

Documentação sobre eventos do MVC: http://tdn.totvs.com/pages/viewpage.action?pageId=269552294

@type classe
 
@author Juliane Venteu
@since 02/02/2017
@version P12.1.17
/*/
CLASS MATA020EVBRA From FWModelEvent
	
	DATA nOpc
	DATA lFKJ
	DATA lFacFis
	
	DATA cCodigo
	DATA cLoja
	
	METHOD New() CONSTRUCTOR
	
	METHOD ModelPosVld()
	METHOD InTTS()
	METHOD AfterTTS(oModel, cModelId)
	
ENDCLASS

//-----------------------------------------------------------------
METHOD New() CLASS MATA020EVBRA
	::lFKJ := FwAliasInDic("FKJ") .and. FindFunction("FINA993")
	::lFacFis := IIf(FindFunction("FSA172VLD"), FSA172VLD(), .F.)
Return

/*/{Protheus.doc} ModelPosVld
Executa a validação do modelo antes de realizar a gravação dos dados.
Se retornar falso, não permite gravar.

@type metodo
 
@author Juliane Venteu
@since 02/02/2017
@version P12.1.17
 
/*/
METHOD ModelPosVld(oModel, cID) CLASS MATA020EVBRA
Local lValid := .T.
Local lPosValid := .T.
Local cTpPessoa  := M->A2_TIPO

	::nOpc := oModel:GetOperation()
	::cCodigo := oModel:GetValue("SA2MASTER","A2_COD")
	::cLoja := oModel:GetValue("SA2MASTER","A2_LOJA")
		
	If ::nOpc == MODEL_OPERATION_DELETE		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verfica se fornecedor esta associado ao cadastro de Documentos Exigidos X Fornecedor  |
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea("DD1")
		If dbSeek(xFilial("DD1")+::cCodigo)
			lValid := .F.
			Help(" ",1,"MA020TEMDC")
		EndIf
	EndIf	

	If ::nOpc == MODEL_OPERATION_UPDATE .Or. ::nOpc == MODEL_OPERATION_INSERT
		If lValid .And. !Empty(M->A2_CGC)
			If Empty(cTpPessoa)
				cTpPessoa := IIf(Len(AllTrim(M->A2_CGC))==11, "F", "J")
			EndIf
			lValid := A020CGC(cTpPessoa, M->A2_CGC, lPosValid)
		EndIf
	EndIf

Return lValid

/*/{Protheus.doc} InTTS
Metodo executado após a gravação dos dados, mas dentro da transação.

Não retorna nada, se chegou até aqui os dados serão gravados.

@type metodo
 
@author Juliane Venteu
@since 02/02/2017
@version P12.1.17
 
/*/
METHOD InTTS(oModel, cID) CLASS MATA020EVBRA
	
	If ::nOpc == MODEL_OPERATION_DELETE
		If ::lFKJ
			Fa993excl(2,M->A2_COD,M->A2_LOJA)
		EndIf
	
	ElseIf ::nOpc == MODEL_OPERATION_INSERT .Or. ::nOpc == MODEL_OPERATION_UPDATE
		If ::lFKJ 
			Fa993grava(1)
		EndIf
	EndIf
	
Return

/*/{Protheus.doc} AfterTTS
Metodo executado após a gravação dos dados, após a transação.

@type metodo
@author Totvs
@since 16/11/2018
@version P12.1.17
/*/
METHOD AfterTTS(oModel, cModelId) CLASS MATA020EVBRA

	// Não acionar o facilitador de dentro do FISA170 pois se o fornecedor estiver sendo cadastrado pela
	// consulta padrão ele já será vinculado ao perfil.
	If ::lFacFis .And. ::nOpc == MODEL_OPERATION_INSERT .And. FunName() <> "FISA170"
		FSA172FAC({STR0088, ::cCodigo, ::cLoja})	// FORNECEDOR
	EndIf

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³A020CGC   ³ Autor ³ Eduardo Riera         ³ Data ³ 17.04.06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Validacao do campo A2_CGC.                                  ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Cadastro de clientes                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
//RETIRAR STATIC
Static Function A020CGC(cTipPes,cCNPJ,lPosValid)

Local aArea     	:= GetArea()
Local aAreaSA2  	:= SA2->(GetArea())
Local lRetorno  	:= .T.
Local cCNPJBase 	:= ""
Local cMv_ValCNPJ	:= GetNewPar("MV_VALCNPJ","1")
Local cMv_ValCPF 	:= GetNewPar("MV_VALCPF","1")
Local cCod       	:= ""
Local cLoja      	:= ""
Local nCad       	:= 0
Local oViewActive	:= FWViewActive()
Local lAuto
Local cStr			:= ""
Local lForBlq		:= .F.
Local cCodBlq 		:= ""

DEFAULT cCNPJ   	:= &(ReadVar())
DEFAULT lPosValid := .F.

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Valida o tipo de pessoa                                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If cTipPes == "F" .And. (!(Len(AllTrim(cCNPJ))==11) .OR. Len(Alltrim(Transform( cCNPJ, "@R 999.999.999-99" ))) < 14) .And. (!M->A2_EST $ "SP|MG")
		Help(" ",1,"CPFINVALID")
		lRetorno := .F.
	ElseIf cTipPes == "F" .And. (!(Len(AllTrim(cCNPJ))==11) .OR. Len(Alltrim(Transform( cCNPJ, "@R 999.999.999-99" ))) < 14) .And. (M->A2_INDRUR = "0" .And. M->A2_EST $ "SP|MG")
		Help(" ",1,"CPFINVALID")
		lRetorno := .F.
	ElseIf cTipPes == "J" .And. (!(Len(AllTrim(cCNPJ))==14) .OR. Len(Alltrim(Transform( cCNPJ, "@R 99.999.999/9999-99" ))) < 18)
		Help(" ",1,"CGC")
		lRetorno := .F.
	EndIf

	If (oViewActive <> NIL .And. oViewActive:GetModel():GetId() == "CUSTOMERVENDOR" )
		//Se existe uma view do MATA020, não é rotina automatica
		lAuto := .F.
	Else
		//Se não existe uma view do MATA020, é uma rotina automatica
		lAuto := .T.
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Valida a duplicidade do CGC                                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lRetorno .And. Pcount() > 1
		If cTipPes == "J"  // Validação pessoa juridica
		
		    //Verifica quantidade de Fornecedores cadastrados com o mesmo código e obtém o 1a código 
		    //de cadastro diferente do fornecedor que está sendo alterado ou incluído
			dbSelectArea("SA2")
			dbSetOrder(3)
			dbSeek(xFilial("SA2")+cCNPJ)
			Do While !Eof() .And. SA2->A2_FILIAL == xFilial("SA2") .AND. SA2->A2_CGC == cCNPJ
			    If (M->A2_COD+M->A2_LOJA <> SA2->A2_COD+SA2->A2_LOJA) .And. Empty(cCod)
			    	 cCod:=SA2->A2_COD
			    	 cLoja:=SA2->A2_LOJA
			    EndIf      
		    	nCad++
				If !RegistroOk("SA2",.F.)//Validar se há fornecedor bloqueado com o mesmo CNPJ
					lForBlq := .T.
					cCodBlq := SA2->A2_COD //Guarda o código do fornecedor bloqueado
					Exit
				Endif 
				DbSkip()
			EndDo
			
			If nCad>0
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³O parametro MV_VALCNPJ verifica se a validacao do CNPJ deve ser feita:                            ³
				//³1 = informando ao usuario que ja existe o CNPJ na base e verificando se deseja incluir mesmo assim³
				//³2 = nao permitindo que o usuario insira o mesmo CNPJ                                              ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If !Empty(cCod)
				    //Posiciona no código de fornecedor
					dbSelectArea("SA2")
					dbSetOrder(1)
					dbSeek(xFilial("SA2")+cCod+cLoja)
					If cMv_ValCNPJ == "1"
						If !lAuto .And. !lPosValid
							If Aviso(STR0011,STR0025+SA2->A2_COD+"/"+SA2->A2_LOJA+" - "+;
							If(lLGPD,RetTxtLGPD(SA2->A2_NOME,"A2_NOME"),SA2->A2_NOME)+" - "+AllTrim(RetTitle("A2_INSCR"))+": "+;
							If(lLGPD,RetTxtLGPD(SA2->A2_INSCR,"A2_INSCR"),SA2->A2_INSCR),{STR0027,STR0028},2)<>1//"Atenção"###"O CNPJ informado já foi utilizado no fornecedor "###"Aceitar"###"Cancelar"
								lRetorno := .F.
							EndIf
						EndIf
					Else
						//Validar se o fornecedor está bloqueado na alteração de fornecedor ativo 
						//Ou se está tentando alterar fornecedor já bloqueado caso o parâmetro MV_VALCNPJ seja alterado no meio do processo
						If !lForBlq .Or. cCod <> cCodBlq .Or. M->A2_COD <> cCod
							Help(" ",1,"CGCJAINF",,STR0025+SA2->A2_COD+"/"+SA2->A2_LOJA+" - "+;
							If(lLGPD,RetTxtLGPD(SA2->A2_NOME,"A2_NOME"),SA2->A2_NOME)+".",5,0)
							lRetorno := .F.	
						EndIf 				
					Endif
				EndIf
			 ElseIf lRetorno
				cCNPJBase := SubStr(cCNPJ,1,8)
				dbSelectArea("SA2")
				dbSetOrder(3)
				If dbSeek(xFilial("SA2")+cCNPJBase) .And. M->A2_COD+M->A2_LOJA <> SA2->A2_COD+SA2->A2_LOJA
					If cMv_ValCNPJ == "1" .And. SA2->A2_TIPO == "J"
						If !lAuto
							If Aviso(STR0011,STR0035+" "+SA2->A2_COD+"/"+SA2->A2_LOJA+" - "+SA2->A2_NOME+".",{STR0027,STR0028},2)<>1//"Atenção"###"A base do CNPJ informado já foi utilizada no fornecedor "###"Aceitar"###"Cancelar"
								lRetorno := .F.
							EndIf
						EndIf
					Endif
				EndIf
			EndIf
		ElseIf cTipPes <> "X" //Se o Fornecedor for do A2_TIPO = X 'Outros', nao deve validar
			dbSelectArea("SA2")
			dbSetOrder(3)
			If dbSeek(xFilial("SA2")+cCNPJ) .And. M->A2_COD+M->A2_LOJA <> SA2->A2_COD+SA2->A2_LOJA
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³O parametro MV_VALCPF verifica se a validacao do CPF deve ser feita:                             ³
				//³1 = informando ao usuario que ja existe o CPF na base e verificando se deseja incluir mesmo assim³
				//³2 = nao permitindo que o usuario insira o mesmo CPF                                              ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If SA2->A2_INDRUR <> "0" .And. SA2->A2_EST $ "SP|MG" .And. SA2->A2_TIPO == "F"
					cStr := STR0025 // O CNPJ informado já foi utilizado no fornecedor
				Else
					cStr := STR0026 // O CPF informado já foi utilizado no fornecedor
				EndIf
				If cMv_ValCPF == "1"
					If !lAuto .And. !lPosValid
						If Aviso(STR0011,cStr+SA2->A2_COD+"/"+SA2->A2_LOJA+" - "+;
						If(lLGPD,RetTxtLGPD(SA2->A2_NOME,"A2_NOME"),SA2->A2_NOME)+".",{STR0027,STR0028},2)<>1//"Atenéˆ¬o"###"O CPF informado jãƒ»foi utilizado fornecedor "###"Aceitar"###"Cancelar"
							lRetorno := .F.
						EndIf
					EndIf
				Else			
					Help(" ",1,"CGCJAINF",,cStr+SA2->A2_COD+"/"+SA2->A2_LOJA+" - "+;
					If(lLGPD,RetTxtLGPD(SA2->A2_NOME,"A2_NOME"),SA2->A2_NOME)+".",5,0)
					lRetorno := .F.				
				Endif
			EndIf
		EndIf
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Avalia o site da Receita Federal - Mashups                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lRetorno .And. GetNewPar("MV_MASHUPS",.F.) .And. !_SetAutoMode()
		RFMashups(M->A2_CGC,{"M->A2_NOME","M->A2_NREDUZ","M->A2_END","M->A2_CEP","M->A2_BAIRRO","M->A2_MUN","M->A2_EST"})
	EndIf

RestArea(aAreaSA2)
RestArea(aArea)
Return lRetorno

//Funções de compatiblidade
//Excluir as funções abaixo quando for descontinuado o MATA020 e o MATA020M virar padrão
//Retirar o "Static" das funções que conterem o comentário //RETIRAR STATIC
//-----------------------------------
Function MA020CGC(cTipPes,cCNPJ)
Return A020CGC(cTipPes,cCNPJ)
//-----------------------------------

//-------------------------------------------------------------------
/*/{Protheus.doc} MA020PcCgc
Pesquisa a picture do campo A2_CGC, nessária para nova legislação em que
produtores rurais de SP são pessoas físicas com CNPJ.
@author 	Luiz Henrique Bourscheid
@since 		05/12/2017
@version 	1.0
@project MA3
/*/
//-------------------------------------------------------------------
//RETIRAR STATIC
Static Function MA020PcCgc()
Return PICPES(IIf((M->A2_INDRUR <> "0" .And. M->A2_EST $ "SP|MG" .And. M->A2_TIPO == "F"), "J", M->A2_TIPO ))
