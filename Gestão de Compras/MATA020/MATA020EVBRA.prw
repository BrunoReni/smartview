#include 'Protheus.ch'
#include 'FWMVCDef.ch'
#include 'MATA020.ch'

Static lLGPD  := FindFunction("SuprLGPD") .And. SuprLGPD()

/*/{Protheus.doc} MATA020EVBRA
Eventos do MVC para o BRASIL, qualquer regra que se aplique somente para BRASIL
deve ser criada aqui, se for uma regra geral deve estar em MATA020EVDEF.

Todas as valida��es de modelo, linha, pr� e pos, tamb�m todas as intera��es com a grava��o
s�o definidas nessa classe.

Importante: Use somente a fun��o Help para exibir mensagens ao usuario, pois apenas o help
� tratado pelo MVC. 

Documenta��o sobre eventos do MVC: http://tdn.totvs.com/pages/viewpage.action?pageId=269552294

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
Executa a valida��o do modelo antes de realizar a grava��o dos dados.
Se retornar falso, n�o permite gravar.

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
		//��������������������������������������������������������������������������������������Ŀ
		//�Verfica se fornecedor esta associado ao cadastro de Documentos Exigidos X Fornecedor  |
		//����������������������������������������������������������������������������������������
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
Metodo executado ap�s a grava��o dos dados, mas dentro da transa��o.

N�o retorna nada, se chegou at� aqui os dados ser�o gravados.

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
Metodo executado ap�s a grava��o dos dados, ap�s a transa��o.

@type metodo
@author Totvs
@since 16/11/2018
@version P12.1.17
/*/
METHOD AfterTTS(oModel, cModelId) CLASS MATA020EVBRA

	// N�o acionar o facilitador de dentro do FISA170 pois se o fornecedor estiver sendo cadastrado pela
	// consulta padr�o ele j� ser� vinculado ao perfil.
	If ::lFacFis .And. ::nOpc == MODEL_OPERATION_INSERT .And. FunName() <> "FISA170"
		FSA172FAC({STR0088, ::cCodigo, ::cLoja})	// FORNECEDOR
	EndIf

Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �A020CGC   � Autor � Eduardo Riera         � Data � 17.04.06 ���
�������������������������������������������������������������������������Ĵ��
���Descricao �Validacao do campo A2_CGC.                                  ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Uso       � Cadastro de clientes                                       ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
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

	//��������������������������������������������������������������Ŀ
	//� Valida o tipo de pessoa                                      �
	//����������������������������������������������������������������
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
		//Se existe uma view do MATA020, n�o � rotina automatica
		lAuto := .F.
	Else
		//Se n�o existe uma view do MATA020, � uma rotina automatica
		lAuto := .T.
	EndIf
	
	//��������������������������������������������������������������Ŀ
	//� Valida a duplicidade do CGC                                  �
	//����������������������������������������������������������������
	If lRetorno .And. Pcount() > 1
		If cTipPes == "J"  // Valida��o pessoa juridica
		
		    //Verifica quantidade de Fornecedores cadastrados com o mesmo c�digo e obt�m o 1a c�digo 
		    //de cadastro diferente do fornecedor que est� sendo alterado ou inclu�do
			dbSelectArea("SA2")
			dbSetOrder(3)
			dbSeek(xFilial("SA2")+cCNPJ)
			Do While !Eof() .And. SA2->A2_FILIAL == xFilial("SA2") .AND. SA2->A2_CGC == cCNPJ
			    If (M->A2_COD+M->A2_LOJA <> SA2->A2_COD+SA2->A2_LOJA) .And. Empty(cCod)
			    	 cCod:=SA2->A2_COD
			    	 cLoja:=SA2->A2_LOJA
			    EndIf      
		    	nCad++
				If !RegistroOk("SA2",.F.)//Validar se h� fornecedor bloqueado com o mesmo CNPJ
					lForBlq := .T.
					cCodBlq := SA2->A2_COD //Guarda o c�digo do fornecedor bloqueado
					Exit
				Endif 
				DbSkip()
			EndDo
			
			If nCad>0
				//��������������������������������������������������������������������������������������������������Ŀ
				//�O parametro MV_VALCNPJ verifica se a validacao do CNPJ deve ser feita:                            �
				//�1 = informando ao usuario que ja existe o CNPJ na base e verificando se deseja incluir mesmo assim�
				//�2 = nao permitindo que o usuario insira o mesmo CNPJ                                              �
				//����������������������������������������������������������������������������������������������������
				If !Empty(cCod)
				    //Posiciona no c�digo de fornecedor
					dbSelectArea("SA2")
					dbSetOrder(1)
					dbSeek(xFilial("SA2")+cCod+cLoja)
					If cMv_ValCNPJ == "1"
						If !lAuto .And. !lPosValid
							If Aviso(STR0011,STR0025+SA2->A2_COD+"/"+SA2->A2_LOJA+" - "+;
							If(lLGPD,RetTxtLGPD(SA2->A2_NOME,"A2_NOME"),SA2->A2_NOME)+" - "+AllTrim(RetTitle("A2_INSCR"))+": "+;
							If(lLGPD,RetTxtLGPD(SA2->A2_INSCR,"A2_INSCR"),SA2->A2_INSCR),{STR0027,STR0028},2)<>1//"Aten��o"###"O CNPJ informado j� foi utilizado no fornecedor "###"Aceitar"###"Cancelar"
								lRetorno := .F.
							EndIf
						EndIf
					Else
						//Validar se o fornecedor est� bloqueado na altera��o de fornecedor ativo 
						//Ou se est� tentando alterar fornecedor j� bloqueado caso o par�metro MV_VALCNPJ seja alterado no meio do processo
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
							If Aviso(STR0011,STR0035+" "+SA2->A2_COD+"/"+SA2->A2_LOJA+" - "+SA2->A2_NOME+".",{STR0027,STR0028},2)<>1//"Aten��o"###"A base do CNPJ informado j� foi utilizada no fornecedor "###"Aceitar"###"Cancelar"
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
				//�������������������������������������������������������������������������������������������������Ŀ
				//�O parametro MV_VALCPF verifica se a validacao do CPF deve ser feita:                             �
				//�1 = informando ao usuario que ja existe o CPF na base e verificando se deseja incluir mesmo assim�
				//�2 = nao permitindo que o usuario insira o mesmo CPF                                              �
				//���������������������������������������������������������������������������������������������������
				If SA2->A2_INDRUR <> "0" .And. SA2->A2_EST $ "SP|MG" .And. SA2->A2_TIPO == "F"
					cStr := STR0025 // O CNPJ informado j� foi utilizado no fornecedor
				Else
					cStr := STR0026 // O CPF informado j� foi utilizado no fornecedor
				EndIf
				If cMv_ValCPF == "1"
					If !lAuto .And. !lPosValid
						If Aviso(STR0011,cStr+SA2->A2_COD+"/"+SA2->A2_LOJA+" - "+;
						If(lLGPD,RetTxtLGPD(SA2->A2_NOME,"A2_NOME"),SA2->A2_NOME)+".",{STR0027,STR0028},2)<>1//"Aten鈬o"###"O CPF informado j・foi utilizado fornecedor "###"Aceitar"###"Cancelar"
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
	//��������������������������������������������������������������Ŀ
	//� Avalia o site da Receita Federal - Mashups                   �
	//����������������������������������������������������������������
	If lRetorno .And. GetNewPar("MV_MASHUPS",.F.) .And. !_SetAutoMode()
		RFMashups(M->A2_CGC,{"M->A2_NOME","M->A2_NREDUZ","M->A2_END","M->A2_CEP","M->A2_BAIRRO","M->A2_MUN","M->A2_EST"})
	EndIf

RestArea(aAreaSA2)
RestArea(aArea)
Return lRetorno

//Fun��es de compatiblidade
//Excluir as fun��es abaixo quando for descontinuado o MATA020 e o MATA020M virar padr�o
//Retirar o "Static" das fun��es que conterem o coment�rio //RETIRAR STATIC
//-----------------------------------
Function MA020CGC(cTipPes,cCNPJ)
Return A020CGC(cTipPes,cCNPJ)
//-----------------------------------

//-------------------------------------------------------------------
/*/{Protheus.doc} MA020PcCgc
Pesquisa a picture do campo A2_CGC, ness�ria para nova legisla��o em que
produtores rurais de SP s�o pessoas f�sicas com CNPJ.
@author 	Luiz Henrique Bourscheid
@since 		05/12/2017
@version 	1.0
@project MA3
/*/
//-------------------------------------------------------------------
//RETIRAR STATIC
Static Function MA020PcCgc()
Return PICPES(IIf((M->A2_INDRUR <> "0" .And. M->A2_EST $ "SP|MG" .And. M->A2_TIPO == "F"), "J", M->A2_TIPO ))
