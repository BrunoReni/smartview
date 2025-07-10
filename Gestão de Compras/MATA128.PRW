#INCLUDE "MATA128.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "PARMTYPE.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} MATA128
Matriz de Fornecimento

@author Rodrigo Toledo Silva
@since 15/06/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Function MATA128()
Local oBrowse

Private aRotina := MenuDef()

If !GetRpoRelease() > 'R7' .and. substr(GetRpoRelease(),1,2) <> '12'
	Aviso(STR0008,STR0009, {"Ok"})
	Return NIL
EndIf

oBrowse := FWMBrowse():New()
oBrowse:SetAlias("SDU")
oBrowse:SetDescription(STR0001) // Matriz De Fornecimento por produto
oBrowse:SetLocate()
oBrowse:Activate()

Return NIL
                                                                                    

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Menu Funcional

@author Rodrigo Toledo Silva
@since 15/06/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

ADD OPTION aRotina TITLE STR0003 ACTION "AxPesqui"        OPERATION 1 ACCESS 0
ADD OPTION aRotina TITLE STR0004 ACTION "VIEWDEF.MATA128" OPERATION 2 ACCESS 0
ADD OPTION aRotina TITLE STR0005 ACTION "VIEWDEF.MATA128" OPERATION 3 ACCESS 0
ADD OPTION aRotina TITLE STR0006 ACTION "VIEWDEF.MATA128" OPERATION 4 ACCESS 0
ADD OPTION aRotina TITLE STR0007 ACTION "VIEWDEF.MATA128" OPERATION 5 ACCESS 0

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de dados da Matriz de Fornecimento

@author Rodrigo Toledo Silva
@since 15/06/2012
@version 1.0

/*/
//-------------------------------------------------------------------
Static Function Modeldef()
Local oModel := NIL
Local oStruHEAD := FWFormStruct( 1, "SDU", {|cCampo|   AllTRim(cCampo) $ "|DU_PRODUTO|DU_DESC|DU_DTINI|DU_DTFIM" } )
Local oStruGRID := FWFormStruct( 1, "SDU", {|cCampo| !(AllTRim(cCampo) $ "|DU_PRODUTO|DU_DESC|DU_DTINI|DU_DTFIM") } )

//-----------------------------------------
//Monta o modelo do formulário
//-----------------------------------------
oModel:= MPFormModel():New( "MATA128", /*Pre-Validacao*/,/*Pos-Validacao*/, ,/*Cancel*/)
oModel:AddFields( "MATA128_Head", NIL, oStruHEAD, /*Pre-Validacao*/, /*Pos-Validacao*/ )
oModel:AddGrid  ( "MATA128_Grid", "MATA128_Head", oStruGRID,,{ |oModel| A128PosLin( oModel ) }, /*bPre*/, { |oModel| A128PosMod( oModel ) } )
oModel:SetRelation("MATA128_Grid",{{"DU_FILIAL",'xFilial("SDU")'},{"DU_PRODUTO",'DU_PRODUTO'},{"DU_DTINI","DU_DTINI"},{"DU_DTFIM","DU_DTFIM"}},"DU_FILIAL+DU_PRODUTO+DTOS(DU_DTINI)+DTOS(DU_DTFIM)")
oModel:GetModel("MATA128_Grid"):SetDelAllLine(.T.)
oModel:SetDescription(STR0002) // "Modelo de Dados da Matriz de Fornececimento por Produto"
oModel:SetPrimaryKey( {"DU_PRODUTO","DU_DTINI","DU_DTFIM"} )
oModel:GetModel( 'MATA128_Grid' ):SetUniqueLine( { 'DU_FORNECE','DU_LOJA' } )

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
View de dados da Matriz de Fornecimento

@author Rodrigo Toledo Silva
@since 15/06/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oView
Local oModel    := FWLoadModel( "MATA128" )
Local oStruHEAD := FWFormStruct( 2, "SDU", {|cCampo| AllTRim(cCampo) $ "|DU_PRODUTO|DU_DESC|DU_DTINI|DU_DTFIM" } )
Local oStruGRID := FWFormStruct( 2, "SDU", {|cCampo| !(AllTRim(cCampo) $ "|DU_PRODUTO|DU_DESC|DU_DTINI|DU_DTFIM" )} )

SDU->(dbSetOrder(1))                  
oView := FWFormView():New()
oView:SetModel( oModel )
oView:AddField( "MATA128_VHEAD", oStruHead, "MATA128_Head"  )
oView:AddGrid ( "MATA128_VGRID", oStruGrid, "MATA128_Grid"  )
oView:CreateHorizontalBox( "SDUFIELDS", 20 )
oView:CreateHorizontalBox( "SDUGRID"  , 80 )      
oView:SetOwnerView( "MATA128_VHEAD", "SDUFIELDS" )
oView:SetOwnerView( "MATA128_VGRID", "SDUGRID" )
oView:SetDescription(STR0001) // "Matriz de Fornecimento por Produto"
oView:EnableControlBar( .T. )

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} A128PosMod()
Valida se os percentuais informados na Matriz de Fornecimento correspondem a 100%

@author Rodrigo Toledo Silva
@since 15/06/2012
@version 1.0

/*/
//-------------------------------------------------------------------
Function A128PosMod(oModel)

Local nOperation := oModel:GetOperation()
Local nPerc := 0
Local lRet := .T.
Local nCont := 1
Local aSaveLines := FWSaveRows()

If nOperation == 3 .or. nOperation == 4   
	For nCont := 1 To oModel:Length()
		oModel:GoLine(nCont)         
		If !oModel:IsDeleted()
			nPerc := nPerc + FwFldGet("DU_PERCENT")
		Endif
	End
Endif            

If nPerc <> 100  
	Help(" ",1,"A128PERC")
	lRet := .F. 
	nPerc := 0
Endif

FWRestRows( aSaveLines )
Return lRet                          
	
//-------------------------------------------------------------------
/*/{Protheus.doc} A128VldFor()
Valida Fornecedor e loja para preenchimento de campo virtual DU_NOME

@author Rodrigo Toledo Silva
@since 15/06/2012
@version 1.0

/*/
//-------------------------------------------------------------------

Function A128VldFor()
Local lRet  := .T.
Local cForn := If(ReadVar() == "M->DU_FORNECE",M->DU_FORNECE,FwFldGet("DU_FORNECE"))
Local cLoja := If(ReadVar() == "M->DU_LOJA",M->DU_LOJA,"")

SA2->(dbSetOrder(1))
lRet := ExistCpo("SA2",cForn+cLoja)

If lRet
	If ReadVar() == "M->DU_LOJA" .Or. SA2->(A2_FILIAL+A2_COD) # xFilial("SA2")+cForn
		SA2->(dbSeek(xFilial("SA2")+cForn+cLoja))
	EndIf
	If ReadVar() == "M->DU_FORNECE" 
		FwFldPut("DU_LOJA",SA2->A2_LOJA)
	EndIf
	FwFldPut("DU_NOME",PadR(SA2->A2_NOME,TamSX3("DU_NOME")[1]))
EndIf

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} A128PosLin()
Verifica se o campo de percentual foi preenchido com valos maior que 100%
@author Rodrigo Toledo Silva
@since 15/06/2012
@version 1.0

/*/
//-------------------------------------------------------------------
Static Function A128PosLin(oModel)
Local lRet		:= .T.
Local aSaveLines := FWSaveRows()

If Empty(FWFldGet("DU_PERCENT"))
	Help(" ",1,"OBRIGAT2")
	lRet := .F.
EndIf
If FWFldGet("DU_PERCENT") > 100
	Help(" ",1,"A128VALO")
	lRet := .F.
EndIf


FWRestRows( aSaveLines )
Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} A128VldCab()
Valida produto informado no cabeçalho da rotina e inclui automaticamente fornecedor principal com percentual de participação de 100%.

@author Rodrigo Toledo Silva
@since 16/06/2012
@version 1.0

/*/
//-------------------------------------------------------------------
Function A128VldCab()
Local lRet	:= .T.
Local aArea	:= SDU->(GetArea())
Local cChave	:= DToS(FWFldGet("DU_DTINI"))+DToS(FWFldGet("DU_DTFIM"))
Local dDtIni	:= FWFldGet("DU_DTINI")
Local dDtFim	:= FWFldGet("DU_DTFIM")

If !Empty(FwFldGet("DU_PRODUTO"))
	lRet := ExistCpo('SB1',FwFldGet("DU_PRODUTO"))
EndIf

If lRet
	//-- Garante que a data digitada nao esta entre outra matriz
	If !Empty(dDtIni) .And. !Empty(dDtFim)
		SDU->(dbSetOrder(1))
		SDU->(dbSeek(xFilial("SDU")+FwFldGet("DU_PRODUTO")))
		While SDU->(!EOF()) .And. xFilial("SDU")+FwFldGet("DU_PRODUTO") == SDU->(DU_FILIAL+DU_PRODUTO)
			If cChave # DToS(SDU->DU_DTINI)+DToS(SDU->DU_DTFIM) .And. ;		
								dDtIni >= SDU->DU_DTINI .And. dDtIni <= SDU->DU_DTFIM .And. ;
								dDtFim >= SDU->DU_DTINI .And. dDtFim <= SDU->DU_DTFIM
				Help(" ",1,"A128DATA")
				lRet := .F.
				Exit
	        EndIf
			SDU->(dbSkip())
		End
		
	EndIf   
EndIf

If lRet
	FwFldPut("DU_DESC",PadR(Posicione("SB1",1,xFilial("SB1")+FwFldGet("DU_PRODUTO"),"B1_DESC"),TamSX3("DU_DESC")[1]))
EndIf

SDU->(RestArea(aArea))

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} A128VldCab()
Valida se para o periodo informado já existe uma planilha cadastrada neste intervalo.

@author Rodrigo Toledo Silva
@since 16/06/2012
@version 1.0

/*/
//-------------------------------------------------------------------
Function A128VldDat()
Local aArea	:= SDU->(GetArea())
Local lRet   	:= .T.
Local dDtVal 	:= &(ReadVar())
Local cChave 	:= DToS(SDU->DU_DTINI)+DToS(SDU->DU_DTFIM)

//-- Garante que data fim e maior que data inicio
If !Empty(FwFldGet("DU_DTINI")) .And. !Empty(FwFldGet("DU_DTFIM")) .And. FwFldGet("DU_DTINI") > FwFldGet("DU_DTFIM")
	Help(" ",1,"DATA2INVAL")
	lRet := .F.
EndIf

//-- Garante que a data digitada nao esta entre outra matriz
If !Empty(dDtVal)
	SDU->(dbSetOrder(1))
	SDU->(dbSeek(xFilial("SDU")+FwFldGet("DU_PRODUTO")))
	While SDU->(!EOF()) .And. xFilial("SDU")+FwFldGet("DU_PRODUTO") == SDU->(DU_FILIAL+DU_PRODUTO)
		If cChave == DToS(SDU->DU_DTINI)+DToS(SDU->DU_DTFIM) .Or. dDtVal >= SDU->DU_DTINI .And. dDtVal <= SDU->DU_DTFIM
			Help(" ",1,"A128DATA")
			lRet := .F.
			Exit
        EndIf
		SDU->(dbSkip())
	End
	
EndIf      

SDU->(RestArea(aArea))

Return lRet
