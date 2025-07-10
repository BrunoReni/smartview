#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "FWMVCDEF.CH"                 
#INCLUDE "FWADAPTEREAI.CH"
#include "TbIconn.ch"
#include "TopConn.ch"
#INCLUDE "CM110.CH"

/*/{Protheus.doc} COMA110EVPMS
Eventos do MVC relacionado a integração da solicitação de compras
com o modulo SIGAPMS
@author Leonardo Bratti
@since 28/09/2017
@version P12.1.17 
/*/

CLASS COMA110EVPMS FROM FWModelEvent
	
	METHOD New() CONSTRUCTOR
	METHOD GridLinePosVld()
	
ENDCLASS

METHOD New() CLASS  COMA110EVPMS

	
Return

//----------------------------------------------------------------------
/*/{Protheus.doc} GridLinePosVld()
Validações de linha do PMS
@author Leonardo Bratti
@since 09/10/2017
@version 1.0
@return .T.
/*/
//----------------------------------------------------------------------
METHOD GridLinePosVld(oModel, cID, nLine) CLASS COMA110EVPMS
 	Local lRet          := .T.
 	Local cNum , cItem       
 	Local nQtd          
 	Local nTotAFG	      := 0
 	Local nPosAFG       := 0 
 	Local nA            := 0
 	Private aRatAFG     := {}
 	Private aHdrAFG     := {} 	

 	If cID == "SC1DETAIL"
 		cNum          := oModel:getValue("C1_NUM")
 		cItem         := oModel:getValue("C1_ITEM")
 		nQtd          := oModel:getValue("C1_QUANT")
 		If IntePms()	
			If IsUpdated() .And. Len(aRatAFG)=0
				PmsDlgSC(6,cNum,.F.) //Carrega os valores que serao utilizados para a validacao
			EndIf
			If Len(aRatAFG) > 0
				nPosAFG  := Ascan(aRatAFG,{|x|x[1]== cItem})
				nPosQtde := Ascan(aHdrAFG,{|x|Alltrim(x[2])=="AFG_QUANT"})
				nTotAFG	:= 0
				If (nPosAFG > 0) .And. (nPosQtde > 0)
					For nA := 1 To Len(aRatAFG[nPosAFG][2])
						If !aRatAFG[nPosAFG][2][nA][LEN(aRatAFG[nPosAFG][2][nA])]
							nTotAFG	+= aRatAFG[nPosAFG][2][nA][nPosQtde]
						EndIf
					Next nA
					If nTotAFG > nQtd
						Help("   ",1,"PMSQTNF")
						lRet := .F.
					EndIf
				EndIf
			EndIf
		EndIf		
	EndIf
Return lRet

//----------------------------------------------------------------------
/*/{Protheus.doc} C110PmsDlg()
Esta funcao cria uma janela para configuracao e utilizacao da Solicitacao em um determinado Projeto.
@author Luiz Henrique Bourscheid
@since 28/11/2017
@version 1.0
@return .T.
/*/
//----------------------------------------------------------------------
Function C110PmsDlg(oViewPai, nOpcao, cNumSC, lGetDados, aRatAuto)
	Local oStruAFGR := FWFormStruct(2,'AFG')
	Local oStruAFGI := FWFormViewStruct():New()
	Local oView     := Nil
	Local oExecView := FWViewExec():New()
	Local oModel
	Local lRet      := .T.
	
	Default oViewPai := FWViewActive()

	oModel := oViewPai:GetModel()

	oView := FWFormView():New(oViewPai)
	oView:SetModel(oModel)
	oView:SetOperation(oViewPai:GetOperation())

	oStruAFGI:AddField( ;                   // Ord. Tipo Desc.
		                   'CI_NUM' , ;     // [01] C Nome do Campo
		                   '01' , ;         // [02] C Ordem
		                   STR0090 , ;    // [03] C Titulo do campo 
		                   ' ', ;           // [04] C Descrição do campo 
		                   {} , ;           // [05] A Array com Help 
		                   'C' , ;          // [06] C Tipo do campo
		                   '@!' , ;         // [07] C Picture
		                   NIL , ;          // [08] B Bloco de Picture Var
		                   '' , ;           // [09] C Consulta F3
		                   .T. , ;          // [10] L Indica se o campo é evitável
		                   NIL , ;          // [11] C Pasta do campo
		                   NIL , ;          // [12] C Agrupamento do campo
		                   Nil , ;          // [13] A Lista de valores permitido do campo (Combo)
		                   Nil , ;          // [14] N Tamanho Máximo da maior opção do combo
		                   C110PMSLd() , ;  // [15] C Inicializador de Browse
		                   .T. , ;          // [16] L Indica se o campo é virtual
		                   NIL , ;          // [17] C Picture Variável
						   .F.)	            // [18]  L   Indica pulo de linha após o campo
	
	oStruAFGI:AddField( ;                                 // Ord. Tipo Desc.
		                   'CI_QUANT' , ;                 // [01] C Nome do Campo
		                   '02' , ;                       // [02] C Ordem
		                   STR0091 , ;               // [03] C Titulo do campo 
		                   ' ', ;                         // [04] C Descrição do campo 
		                   {} , ;                         // [05] A Array com Help 
		                   'N' , ;                        // [06] C Tipo do campo
		                   PesqPict("SC1","C1_QUANT") , ; // [07] C Picture
		                   NIL , ;                        // [08] B Bloco de Picture Var
		                   '' , ;                         // [09] C Consulta F3
		                   .F. , ;                        // [10] L Indica se o campo é evitável
		                   NIL , ;                        // [11] C Pasta do campo
		                   NIL , ;                        // [12] C Agrupamento do campo
		                   Nil , ;                        // [13] A Lista de valores permitido do campo (Combo)
		                   Nil , ;                        // [14] N Tamanho Máximo da maior opção do combo
						   C110PMSLd() , ;                // [15] C Inicializador de Browse
		                   .F. , ;                        // [16] L Indica se o campo é virtual
		                   NIL , ;                        // [17] C Picture Variável
						   .F.)	                          // [18]  L   Indica pulo de linha após o campo

	oView:AddField( 'VIEW_AFGI', oStruAFGI,  'AFGMASTER' )
	oView:AddGrid('VIEW_AFGG' ,oStruAFGR,'AFGDETAIL', , )
	
	oView:CreateHorizontalBox( 'BOXITEM', 14)
	oView:CreateVerticalBox( 'BOXC', 100, 'BOXITEM' )
	
	oView:CreateHorizontalBox( 'BOXPROJ', 86)
	oView:SetOwnerView('VIEW_AFGG','BOXPROJ')
	oView:SetOwnerView('VIEW_AFGI','BOXC')
	
	oView:EnableTitleView('VIEW_AFGG' , STR0092 )

	oStruAFGR:SetProperty( 'AFG_TAREFA', MVC_VIEW_LOOKUP, "")
	
	oStruAFGR:RemoveField( 'AFG_FILIAL' )
	oStruAFGR:RemoveField( 'AFG_NUMSC'  )
	oStruAFGR:RemoveField( 'AFG_ITEMSC' )
	oStruAFGR:RemoveField( 'AFG_COD'    )
	oStruAFGR:RemoveField( 'AFG_AFAITE' )
	oStruAFGR:RemoveField( 'AFG_NATEND' )
	oStruAFGR:RemoveField( 'AFG_NATEN2' )
	oStruAFGR:RemoveField( 'AFG_IDPROT' )
	
	//Proteção para execução com View ativa.
	If oModel != Nil .And. oModel:isActive()
	  oExecView:setModel(oModel)
	  oExecView:setView(oView)
	  oExecView:setTitle(STR0092)
	  oExecView:setOperation(oViewPai:GetOperation())
	  oExecView:setReduction(65)
	  oExecView:setButtons({{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.T.,STR0095},{.T.,STR0096},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil}})
	  oExecView:SetCloseOnOk({|| .T.})
	  oExecView:openView(.F.)

	  If oExecView:getButtonPress() == VIEW_BUTTON_OK
	    lRet := .T.
	  Endif
	EndIf 

Return lRet

//----------------------------------------------------------------------
/*/{Protheus.doc} C110PMSQte()
Funcao de validacao da quantidade da Solicitacao de Compras.
@author Luiz Henrique Bourscheid
@since 28/11/2017
@version 1.0
@return .T.
/*/
//----------------------------------------------------------------------
Function C110PMSQte()
	Local oModel     := FWModelActive()
	Local oModelSC1  := oModel:GetModel("SC1MASTER")
	Local oModelSC1G := oModel:GetModel("SC1DETAIL")
	Local oModelAFG  := oModel:GetModel("AFGDETAIL")
	Local lErro		:= .F.
	Local nPosPlanej
	Local lPmsScBlq	:= SuperGetMv("MV_PMSCBLQ",,.F.)
	Local nTotAFG
	Local lErro     := .F.
	Local nA        := 0
	
	if  AllTrim(ReadVar()) == "M->C1_QUANT" .And. ALTERA
		if oModelSC1G:GetValue("C1_QUANT") == M->C1_QUANT .or. Empty(oModelSC1G:GetValue("C1_QUANT"))
			If oModelAFG:GetValue("AFG_ITEMSC") <> oModelSC1G:GetValue("C1_ITEM")
				C110PmsDlg(Nil,6,oModelSC1:GetValue("C1_NUM"),.F.) //Carrega os valores que serao utilizados para a validacao
			EndIf
			Return .T.
		endif
	endif

	If ALTERA .And. oModelAFG:GetValue("AFG_ITEMSC") <> oModelSC1G:GetValue("C1_ITEM")
		C110PmsDlg(Nil,6,oModelSC1:GetValue("C1_NUM"),.F.) //Carrega os valores que serao utilizados para a validacao
	EndIf

	// valida se a quantidade do item da SC é menor que a quantidade associada a tarefa dos projetos
	If !Empty(oModelAFG:GetValue("AFG_ITEMSC"))
		nTotAFG	:= 0
		//se a SC eh gerada a partir de planejamento nao pode ser alterada a quantidade
		If !Empty(oModelAFG:GetValue("AFG_PLANEJ"))
			For nA := 1 To oModelAFG:Length()
				oModelAFG:GoLine(nA)
				If !(oModelAFG:IsDeleted()) .And. lPmsScBlq
					Help( " ", 1,"PMSSCPLAN" ,STR0093) // "Este Item não pode ser alterado por ter sido gerada pelo planejamento PMS."
					Return .F.
				EndIf
			Next nA
		EndIf

		If !Empty(oModelAFG:GetValue("AFG_QUANT"))
			For nA := 1 To oModelAFG:Length()
				oModelAFG:GoLine(nA)
				If !(oModelAFG:IsDeleted())
					nTotAFG	+= oModelAFG:GetValue("AFG_QUANT")
				EndIf
			Next nA
			// se a quantidade associada for maior que a quantidade do item da solicitacao de compra, critica
			If nTotAFG # 0 .And. nTotAFG >  oModelSC1G:GetValue("C1_QUANT")
				Help("   ",1,"PMSQTSC")
				lErro := .T.
			Endif
			// se a quantidade associada for menor que a quantidade do item da solicitacao de compra, adverte
			If nTotAFG # 0 .And. nTotAFG < oModelSC1G:GetValue("C1_QUANT")
				Help( , , 'Help', ,STR0094, 1, 0 ) //"A quantidade informada é maior que foi associada as tarefas do(s) projetos"
			Endif
		Endif
		If lErro
			C110PmsDlg(Nil, oModel:GetOperation(), oModelSC1:GetValue("C1_NUM"))
		EndIf
	EndIf
Return .T.

//----------------------------------------------------------------------
/*/{Protheus.doc} C110PMSLd()
Funcao de validacao da quantidade da Solicitacao de Compras.
@author Luiz Henrique Bourscheid
@since 28/11/2017
@version 1.0
@return .T.
/*/
//----------------------------------------------------------------------
Static Function C110PMSLd()
	Local oModel     := FWModelActive()
	Local oModelSC1  := oModel:GetModel("SC1MASTER")
	Local oModelSC1G := oModel:GetModel("SC1DETAIL")
	Local oModelAFGI := oModel:GetModel("AFGMASTER")

	 oModelAFGI:LoadValue("CI_NUM",oModelSC1:GetValue("C1_NUM")+"/"+oModelSC1G:GetValue("C1_ITEM"))
	 oModelAFGI:LoadValue("CI_QUANT",oModelSC1G:GetValue("C1_QUANT"))
Return oModelAFGI:GetValue("CI_NUM")
//----------------------------------------------------------------------
/*/{Protheus.doc} C110PmsTrt()
Funcao de validacao da sequencia de empenho do projeto.
@author Luiz Henrique Bourscheid
@since 28/11/2017
@version 1.0
@return .T.
/*/
//----------------------------------------------------------------------
Function C110PmsTrt()
	Local oModel     := FWModelActive()
	Local oModelAFG  := oModel:GetModel("AFGDETAIL")

Return Vazio().Or. ExistChav("AFJ",oModelAFG:GetValue("AFG_PROJET")+oModelAFG:GetValue("AFG_TAREFA")+M->AFG_TRT,3)