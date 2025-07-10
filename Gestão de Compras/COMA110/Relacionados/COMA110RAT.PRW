#INCLUDE "PROTHEUS.CH"
#INCLUDE "CM110.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "FWMVCDEF.CH"                 
#INCLUDE "FWADAPTEREAI.CH"
#include "TbIconn.ch"
#include "TopConn.ch"

/*/{Protheus.doc} COMA110RAT
Eventos do MVC relacionado as validações do rateio 
@author Leonardo Bratti
@since 28/09/2017
@version P12.1.17 
/*/

CLASS COMA110RAT FROM FWModelEvent
	
	DATA lRatDupl
	
	METHOD New() CONSTRUCTOR
	METHOD GridLinePosVld()
	
ENDCLASS

METHOD New() CLASS  COMA110RAT
	::lRatDupl	:= GetNewPar("MV_RATDUPL",.F.)
	
Return

//----------------------------------------------------------------------
/*/{Protheus.doc} GridLinePosVld()
Validações de linha do Rateio
@author Leonardo Bratti
@since 09/10/2017
@version 1.0
@return .T.
/*/
//----------------------------------------------------------------------
METHOD GridLinePosVld(oModel, cID, nLine) CLASS COMA110RAT
 	Local lRet          := .T.
 	Local cNum         
 	Local cItem         
 	Local cCC
 	Local cRateio                 
 	Local oModelSCX
 	Local oModelSCXR
 	Local oModelM      := FWModelActive()
 	Local aSaveLines
 	Local nI           := 0
 	Local nRat         := 0  
 	Local aSaveLines := FWSaveRows()

 	If cID == "SC1DETAIL" 
 		cNum          := oModel:getValue("C1_NUM")
	 	cItem         := oModel:getValue("C1_ITEM")
	 	cCC           := oModel:getValue("C1_CC")
	 	cRateio       := oModel:getValue("C1_RATEIO")
	 	oModelSCX     := oModelM:GetModel("SCXDETAIL")	
 		If !Empty(cCC) .And. !(oModel:IsDeleted()) .And. cRateio == "1"
			If oModelSCX:Length() > 0 
				Help( , , 'Help', ,STR0072, 1, 0 ) 
				lRet:=.F.			
			EndIf
		EndIf
		
		For nI := 1 To oModelSCX:Length()
			If !(oModelSCX:IsDeleted())
				nRat += oModelSCX:GetValue("CX_PERC")
			EndIf
		Next nI
		
		If nRat < 100 .And. nRat <> 0
			Help( , , 'Help', ,STR0073, 1, 0 )
			lRet := .F.
		Endif	
	EndIf
	
	If cID == "SCXDETAIL"
	   oModelSCXR    := oModelM:GetModel("SCXMASTER1")		
 	   cCusto        := oModel:getValue("CX_CC") 	
 	   
		For nI := 1 To oModel:Length()
		
			oModel:GoLine( nI )
			If !(oModel:IsDeleted())
				If cCusto == oModel:getValue("CX_CC")	.And. oModel:GetLine() <> nLine
					Help(" ",1,"CCEXIST")
					lRet := .F.
				EndIf
				
				nRat += oModel:GetValue("CX_PERC")
				If nRat > 100
					Help( , , 'Help', ,STR0074, 1, 0 )
					lRet := .F.
				EndIf		
			EndIf
		Next nI
		//oModelSCXR:LoadValue("CI_PCARAT",(100 - nRat))	
		//oModelSCXR:LoadValue("CI_PCRAT",(nRat))					
	EndIf 	
	FWRestRows( aSaveLines )	
Return lRet

Function ConfirmRat()
	Local lRet       := .T.
	Local oModel     := FWModelActive()
	Local oModelSCX  := oModel:GetModel("SCXDETAIL")
	Local nI           := 0
 	Local nRat         := 0  
 	Local aSaveLines := FWSaveRows()
 	Local oView 	:= FwViewActive()
	
	For nI := 1 To oModelSCX:Length()
		oModelSCX:GoLine(nI)
		If !(oModelSCX:IsDeleted())
			nRat += oModelSCX:GetValue("CX_PERC")
		EndIf
	Next nI
	
	If nRat < 100 .And. nRat <> 0
		Help( , , 'Help', ,STR0073, 1, 0 )
		lRet := .F.
	Endif	
	
	FWRestRows( aSaveLines )	
	oView:Refresh()
Return lRet

Function AltRatTot()
	Local lRet       := .T.
	Local oModel     := FWModelActive()
	Local oModelSCX  := oModel:GetModel("SCXDETAIL")
	Local oModelSCXR := oModel:GetModel("SCXMASTER1")	
	Local nI         := 0
 	Local nRat       := 0  
 	Local aSaveLines := FWSaveRows()

	For nI := 1 To oModelSCX:Length()
		oModelSCX:GoLine(nI)
		If !(oModelSCX:IsDeleted())
			nRat += oModelSCX:GetValue("CX_PERC")
		EndIf
	Next nI
	
	If nRat > 100 .And. nRat <> 0
		Help( , , 'Help', ,STR0075, 1, 0 )
		lRet := .F.
	Endif
	
	oModelSCXR:LoadValue('CI_PCARAT' ,(100 - nRat))	
	oModelSCXR:LoadValue('CI_PCRAT'  ,nRat)	
	
	FWRestRows( aSaveLines )	
Return lRet





