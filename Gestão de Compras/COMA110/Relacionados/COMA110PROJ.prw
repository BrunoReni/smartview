#INCLUDE "PROTHEUS.CH"
#INCLUDE "CM110.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "FWMVCDEF.CH"                 
#INCLUDE "FWADAPTEREAI.CH"
#include "TbIconn.ch"
#include "TopConn.ch"
//----------------------------------------------------------------------
/*/{Protheus.doc} COMA110PROJ
Eventos do MVC relacionado as validações do rateio 
@author Luiz Henrique Bourscheid
@since 29/11/2017
@version P12.1.17 
/*/
//----------------------------------------------------------------------
CLASS COMA110PROJ FROM FWModelEvent

	METHOD New() CONSTRUCTOR
	METHOD GridLinePosVld()
	
ENDCLASS

METHOD New() CLASS COMA110PROJ
	
Return

//----------------------------------------------------------------------
/*/{Protheus.doc} GridLinePosVld()
Validações de linha do Rateio por projeto.
@author Luiz Henrique Bourscheid
@since 29/11/2017
@version 1.0
@return .T.
/*/
//----------------------------------------------------------------------
METHOD GridLinePosVld(oModel, cID, nLine) CLASS COMA110PROJ
 	Local lRet       := .T.
    Local cMensagem	 := ""
 	Local oModelM    := FWModelActive()
 	Local aSaveLines := FWSaveRows()
    Local lPmsScBlq	 := SuperGetMv("MV_PMSCBLQ",,.F.)
    Local oModelAFG  := oModel:GetModel("AFGDETAIL")

 	If cID == "AFGDETAIL" 
        If lPmsScBlq .and. !Empty(oModelAFG:GetValue("AFG_PLANEJ"))
            Help( " ", 1, "PXFUNPLAN",, STR0097, 1, 0 ) //"Esta Solicitação foi gerada via Planejamento do módulo SIGAPMS. Não sera possível excluí-la. Verificar parâmetrp MV_PMSCBLQ."
            AutoGrLog(STR0097) //"Esta Solicitação foi gerada via Planejamento do módulo SIGAPMS. Não sera possível excluí-la. Verificar parâmetrp MV_PMSCBLQ."
            lRet:=.F.
        EndIf
    EndIf
	
	FWRestRows( aSaveLines )	
Return lRet
//----------------------------------------------------------------------
/*/{Protheus.doc} ConfirmAFG()
TudoOk da tabela AFG (Projetos)
@author Luiz Henrique Bourscheid
@since 29/11/2017
@version 1.0
@return .T.
/*/
//----------------------------------------------------------------------
Function ConfirmAFG()
	Local lRet       := .T.
	Local oModel     := FWModelActive()
	Local oModelAFG  := oModel:GetModel("AFGDETAIL")
	Local oModelSC1G := oModel:GetModel("SC1DETAIL")
 	Local aSaveLines := FWSaveRows()
 	Local oView 	   := FwViewActive()
	Local nTotQuant  := 0
	Local lPMSAFGMB  := ExistBlock("PMSAFGMB")
	Local nI         := 0
	
	For nI := 1 To oModelAFG:Length()
		oModelAFG:GoLine(nI)
		If !(oModelAFG:IsDeleted())
            nTotQuant += oModelAFG:GetValue("AFG_QUANT")
		EndIf
	Next nI
	
	If (nTotQuant > oModelSC1G:GetValue("C1_QUANT")) .and. lRet
        Help("   ",1,"PMSQTSC")
        lRet := .F.
    EndIf

    If lPMSAFGMB
        lRet := ExecBlock("PMSAFGMB", .F., .F., {lRet})
    EndIf
	
	FWRestRows( aSaveLines )	
	oView:Refresh()
Return lRet
//----------------------------------------------------------------------
/*/{Protheus.doc} AFGQtdVld()
Validação do campo quantidade da tabela AFG.
@author Luiz Henrique Bourscheid
@since 30/11/2017
@version 1.0
@return .T.
/*/
//----------------------------------------------------------------------
Function AFGQtdVld()
    Local lRet		:= .T.
    Local cCampo	:= AllTrim(ReadVar())
    Local lGerEmp   := .F.
    Local nOption   := 0
    Local nCnt		:= 0
    Local nTotEmp   := 0
    Local lPmsScBlq	:= SuperGetMv("MV_PMSCBLQ",,.F.)
    Local oModel    := FWModelActive()
    Local oModelAFG := oModel:GetModel("AFGDETAIL")

    If !Empty(oModelAFG:GetValue("AFG_PLANEJ")) .and. !Empty(oModelAFG:GetValue("AFG_TRT"))
        If oModelAFG:GetValue("AFG_QUANT") > ( nTotEmp := C110GetEmp(2) )
            Help(,,"PMSMAXAMA",,STR0098+Alltrim(STR(nTotEmp))) // "QUANTIDADE MAXIMA PERMITIDADE DE AMARRACAO: "
            lRet := .F.
        EndIf
    EndIf

    If lRet .and. lPmsScBlq .and. !(Empty(oModelAFG:GetValue("AFG_PLANEJ")))
        if oModelAFG:GetValue("AFG_QUANT") != &cCampo
            Help(,,"PMSSCPLAN",,STR0097) //"Esta Solicitação foi gerada via Planejamento do módulo SIGAPMS. Não será possível alterar informações principais. Verificar parâmetro MV_PMSCBLQ."
            lRet:=.F.
        Endif
    Endif

    If lRet
        Do Case
            Case cCampo == 'M->AFG_PROJET'
                cProjeto:= M->AFG_PROJET
                lRet := PMSExistCPO("AF8") .And. PmsVldFase("AF8",M->AFG_PROJET,"52", .T.)
            Case cCampo == 'M->AFG_TAREFA'
                cTarefa	:= M->AFG_TAREFA
                lRet := ExistCpo("AF9",oModelAFG:GetValue("AFG_PROJET")+oModelAFG:GetValue("AFG_REVISA")+M->AFG_TAREFA,1)
        EndCase
    Endif

    If lRet .AND. !Empty(oModelAFG:GetValue("AFG_PROJET")) .AND. !Empty(oModelAFG:GetValue("AFG_TAREFA"))
        // verifica os direitos do usuario
        lRet := PmsChkUser(oModelAFG:GetValue("AFG_PROJET"),oModelAFG:GetValue("AFG_TAREFA"),,"",3,"GERSC",oModelAFG:GetValue("AFG_REVISA"))
        If !lRet
            Help(,,"PMSGERSC",,STR0099)//"Usuario sem permissäo para executar a solicitação de compra para o projeto. Verifique os direitos do usuario na estrutura deste projeto e/ou tarefa."
        EndIf

        If lRet .And. Empty(oModelAFG:GetValue("AFG_TRT"))
        // parametro que determina se gera empenho direto sem perguntar nada (.T.)
            lGerEmp := GetNewPar("MV_PMSSCGE",.F.)
            If lGerEmp .and. Empty(oModelAFG:GetValue("AFG_PLANEJ"))  // gera empenho direto sem perguntar nada, se não for um planejamento
                oModelAFG:LoadValue("AFG_TRT", PmsPrxEmp(oModelAFG:GetValue("AFG_PROJET"),oModelAFG:GetValue("AFG_REVISA"),oModelAFG:GetValue("AFG_TAREFA")))
            ElseIf GetMV("MV_PMSBXEM")
                If Empty(oModelAFG:GetValue("AFG_PLANEJ"))
                    //Se não for planejamento
                    If Aviso(STR0100,STR0101,{STR0038,STR0039},2)==1  //"Gerenciamento de Projetos"##"Voce deseja gerar um empenho deste item ao projeto ?##Sim##Nao"
                        oModelAFG:LoadValue("AFG_TRT", PmsPrxEmp(oModelAFG:GetValue("AFG_PROJET"),oModelAFG:GetValue("AFG_REVISA"),oModelAFG:GetValue("AFG_TAREFA")))
                    EndIf
                Else
                    nOption := Aviso(STR0100,STR0102,{STR0103,STR0104,STR0096},2) //"Gerenciamento de Projetos"##"Deseja associar ao empenho gerado pelo planejamento ou a um novo empenho?##Planejamento##Novo Empenho##Cancelar"
                    If nOption == 1
                        oModelAFG:LoadValue("AFG_TRT", PmsPlnEmp(oModelAFG:GetValue("AFG_PROJET"),oModelAFG:GetValue("AFG_TAREFA"),oModelAFG:GetValue("AFG_PLANEJ")))
                    ElseIf nOption == 2
                        oModelAFG:LoadValue("AFG_TRT", PmsPrxEmp(oModelAFG:GetValue("AFG_PROJET"),oModelAFG:GetValue("AFG_REVISA"),oModelAFG:GetValue("AFG_TAREFA")))
                    Else
                        oModelAFG:LoadValue("AFG_TRT", SPACE(LEN(AFG->AFG_TRT)))
                    EndIf
                EndIf
            Else
                oModelAFG:LoadValue("AFG_TRT", SPACE(LEN(AFG->AFG_TRT)))
            EndIf
        EndIf
    EndIf

Return lRet
//----------------------------------------------------------------------
/*/{Protheus.doc} C110GetEmp()
Funcao de alteracao de um empenho perneta com nova amarracao ou pesquisa de empenho existente na propria aCols
@author Luiz Henrique Bourscheid
@since 30/11/2017
@version 1.0
@return .T.
/*/
//----------------------------------------------------------------------
Function C110GetEmp(nOpc)
    Local nEmp 		:= 0
    Local nX 		:= 0
    Local nSubtrai 	:= 0
    Local aAreaAFJ	:= AFJ->(GetArea())
    Local lMantem   := .F.
    Local oModel    := FWModelActive()
    Local oModelAFG := oModel:GetModel("AFGDETAIL")

    Default nOpc  	:= 1

	Do Case
		Case nOpc == 1 // Alterar Registro

			dbSelectarea("AFJ")
			dbsetorder(3) // AFJ_FILIAL+AFJ_PROJET+AFJ_TAREFA+AFJ_TRT
			If dbSeek(xFilial("AFJ")+oModelAFG:GetValue("AFG_PROJET")+oModelAFG:GetValue("AFG_TAREFA")+oModelAFG:GetValue("AFG_TRT"))
				If Alltrim(AFJ->AFJ_PLANEJ) == alltrim(oModelAFG:GetValue("AFG_PLANEJ")) .AND.;
					(AFJ->AFJ_QEMP > (AFJ->AFJ_QATU+AFJ->AFJ_EMPEST)) .AND.;
					 (AFJ->AFJ_QEMP - (AFJ->AFJ_QATU+AFJ->AFJ_EMPEST) >= oModelAFG:GetValue("AFG_QUANT"))

					IF (AFJ->AFJ_QEMP <> oModelAFG:GetValue("AFG_QUANT"))
						Reclock("AFJ",.F.)
							AFJ->AFJ_QEMP := AFJ->AFJ_QEMP - oModelAFG:GetValue("AFG_QUANT")
						MsUnlock("AFJ")
					else
						lMantem := .T.
					Endif
				EndIf
			Endif

		Case nOpc == 2 // Procurar registro
			dbSelectarea("AFJ")
			dbsetorder(3) // AFJ_FILIAL+AFJ_PROJET+AFJ_TAREFA+AFJ_TRT
			If dbSeek(xFilial("AFJ")+oModelAFG:GetValue("AFG_PROJET")+oModelAFG:GetValue("AFG_TAREFA")+oModelAFG:GetValue("AFG_TRT"))
				nEmp :=	AFJ->AFJ_QEMP - (AFJ->AFJ_QATU+Iif(AFJ->(FieldPos("AFJ_EMPEST")) > 0,AFJ->AFJ_EMPEST,0) )

				For nX := 1 to oModelAFG:Length()
					lAchou	:= .F.
					If oModelAFG:GetValue("AFG_PROJET") == AFJ->AFJ_PROJET .AND. oModelAFG:GetValue("AFG_TAREFA") == AFJ->AFJ_TAREFA;
		 			   .AND. oModelAFG:GetValue("AFG_TRT") == AFJ->AFJ_TRT .AND. oModelAFG:GetValue("AFG_PLANEJ") == AFJ->AFJ_PLANEJ
		 			    lAchou := .T.
		 			EndIf

				 	If lAchou
				 		nSubtrai += oModelAFG:GetValue("AFG_QUANT")
					EndIf
				Next nX
			EndIf
	EndCase

RestArea(aAreaAFJ)

Return Iif(nOpc == 1, lMantem, nEmp-nSubtrai)