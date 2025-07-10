#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE "FWEVENTVIEWCONSTS.CH"
#INCLUDE "MATA130.CH"
#INCLUDE 'TOPCONN.ch' 

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Definição da interface
@author Raphael Augustos
@since 22/10/2013
@version 1.0
/*/
//-------------------------------------------------------------------

Static Function ViewDef() 

Local oView	:= FwLoadView("MATA131")
Local oStruTMP := StructTMP(2)

oView:CreateFolder( 'FOLDER', 'BOTTON') 

oView:AddSheet( 'FOLDER', 'SHEET1', STR0057 )
oView:CreateHorizontalBox( 'PASTA_SC8', 100, , , 'FOLDER', 'SHEET1' )
oView:SetOwnerView('VIEW_SC8','PASTA_SC8')

If A131VerInt() 
	oView:AddGrid('VIEW_TMP' , oStruTMP,'TMPDETAIL')
	oView:AddSheet( 'FOLDER', 'SHEET2', STR0057 + "  ClicBusiness" )
	oView:CreateHorizontalBox( 'PASTA_TMP', 100, , , 'FOLDER', 'SHEET2' )
	oView:SetOwnerView('VIEW_TMP','PASTA_TMP')
	oView:EnableTitleView('VIEW_TMP' , STR0057 + " ClicBusiness") //'Fornecedores / Participantes'
Endif	

Return oView


//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Definição do modelo
@author Raphael Augustos
@since 22/10/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oModel	:= FwLoadModel("MATA131")
A131GETFOR(oModel)
Return oModel

