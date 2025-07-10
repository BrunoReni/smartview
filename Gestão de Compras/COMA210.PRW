#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDef.CH'
#include "COMA210.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} COMA210
Perfis de Aprovação
@author augustos.raphael	
@since 26/08/2015
@version version
/*/
//-------------------------------------------------------------------
Function COMA210() 
Local oBrowse  

oBrowse := FWMBrowse():New()
oBrowse:SetAlias("DHL")
oBrowse:SetDescription(STR0001)  //"Perfis de Aprovação"
oBrowse:Activate()

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Definição do modelo de Dados

@author raphael.augustos
@since 27/08/2013
@version 1.0
/*/
//-------------------------------------------------------------------

Static Function ModelDef()
Local oModel
Local oStr1	:= FWFormStruct(1,'DHL')

oModel := MPFormModel():New('COMA210')
oModel:SetDescription(STR0001)  //"Perfis de Aprovação"

oModel:addFields('ModelDHL',,oStr1)
oModel:SetPrimaryKey({ 'DHL_FILIAL', 'DHL_COD'})

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Definição do interface

@author raphael.augustos
@since 27/08/2013
@version 1.0
/*/
//-------------------------------------------------------------------

Static Function ViewDef()
Local oView
Local oModel := ModelDef()
Local oStr1	:= FWFormStruct(2,'DHL',{|cCampo| !ALLTRIM(cCampo) $ "DHL_LIMITE|DHL_TIPO"} )

oView := FWFormView():New()
oView:SetModel(oModel)

oView:AddField('Master_DHL' , oStr1,'ModelDHL' )
oView:EnableTitleView('Master_DHL' , STR0001 ) // "Perfis de Aprovação"  
 
Return oView


//-------------------------------------------------------------------
/*/{Protheus.doc} MENUDEF()
Função para criar do menu 

@author raphael.augustos
@since 25/06/2015
@version 1.0
@return aRotina 
/*/
//-------------------------------------------------------------------

Static Function MenuDef()  
Local aRotina := {} //Array utilizado para controlar opcao selecionada

ADD OPTION aRotina TITLE STR0002		ACTION "VIEWDEF.COMA210"	OPERATION 2	ACCESS 0  	//"Visualizar"
ADD OPTION aRotina TITLE STR0003		ACTION "VIEWDEF.COMA210"	OPERATION 3  	ACCESS 0	//"Incluir"
ADD OPTION aRotina TITLE STR0004		ACTION "VIEWDEF.COMA210"	OPERATION 4 	ACCESS 0	//"Alterar"
ADD OPTION aRotina TITLE STR0005		ACTION "VIEWDEF.COMA210"	OPERATION 5  	ACCESS 3	//"Excluir"
ADD OPTION aRotina TITLE STR0006		ACTION "VIEWDEF.COMA210"	OPERATION 8 	ACCESS 0	//"Imprimir"

Return aRotina


//-------------------------------------------------------------------
/*/{Protheus.doc} A095ChkVal
Validacao dos valores minimos e maximos
@author Andrews Egas
@since 29/05/2014
@version 1.0
/*/
//-------------------------------------------------------------------

Function C210ChkVal(nTipo)

Local lRet	:= .T.

If ( !Empty(FwFldGet("DHL_LIMMIN")) .And. !Empty(FwFldGet("DHL_LIMMAX")) .And. (FwFldGet("DHL_LIMMIN") > FwFldGet("DHL_LIMMAX")) ) 
	Help(" ",1,"",,"",1,1)     
	lRet := .F.
Endif

Return(lRet)
