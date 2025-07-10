#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "FWMVCDEF.CH"                 
#INCLUDE "FWADAPTEREAI.CH"
#include "TbIconn.ch"
#include "TopConn.ch"

/*/{Protheus.doc} COMA110EVCTB
Eventos do MVC relacionados a integração da solicitação de compras
com o modulo contabil
@author Leonardo Bratti
@since 28/09/2017
@version P12.1.17 
/*/

CLASS COMA110EVCTB FROM FWModelEvent
	Data lVldHead
	METHOD New() CONSTRUCTOR
	METHOD GridLinePosVld()
	
ENDCLASS

METHOD New() CLASS  COMA110EVCTB

	
Return

//----------------------------------------------------------------------
/*/{Protheus.doc} GridLinePosVld()
Validações de linha do CTB
@author Leonardo Bratti
@since 09/10/2017
@version 1.0
@return .T.
/*/
//----------------------------------------------------------------------
METHOD GridLinePosVld(oModel, cID, nLine) CLASS COMA110EVCTB
	Local oModelM      := FWModelActive()    
 	Local lRet          := .T. 
	Local cProduto,cConta,cConta,cCusto,cItemCTA,cCLVL,cEC05DB,cEC06DB,cEC07DB,cEC08DB,cEC09DB,cEC05CR,cEC06CR,cEC07CR,cEC08CR,cEC09CR
 	Local aEntid        := {}
 	Local aEntid2       := {}

 	If cID == "SC1DETAIL"
 		cProduto      := IIF(oModel:HasField("C1_PRODUTO") ,oModel:getValue("C1_PRODUTO") , Nil)
	 	cConta        := IIF(oModel:HasField("C1_CONTA")   ,oModel:getValue("C1_CONTA")   , Nil)
	 	cCusto        := IIF(oModel:HasField("C1_CC")      ,oModel:getValue("C1_CC")      , Nil)
	 	cItemCTA      := IIF(oModel:HasField("C1_ITEMCTA") ,oModel:getValue("C1_ITEMCTA") , Nil) 
	 	cCLVL         := IIF(oModel:HasField("C1_CLVL")    ,oModel:getValue("C1_CLVL")    , Nil) 
	 	cEC05DB       := IIF(oModel:HasField("C1_EC05DB")  ,oModel:getValue("C1_EC05DB")  , Nil) 
	 	cEC06DB       := IIF(oModel:HasField("C1_EC06DB")  ,oModel:getValue("C1_EC06DB")  , Nil) 
	 	cEC07DB       := IIF(oModel:HasField("C1_EC07DB")  ,oModel:getValue("C1_EC07DB")  , Nil) 
	 	cEC08DB       := IIF(oModel:HasField("C1_EC08DB")  ,oModel:getValue("C1_EC08DB")  , Nil) 
	 	cEC09DB       := IIF(oModel:HasField("C1_EC09DB")  ,oModel:getValue("C1_EC09DB")  , Nil)
	 	cEC05CR       := IIF(oModel:HasField("C1_EC05CR")  ,oModel:getValue("C1_EC05CR")  , Nil)
	 	cEC06CR       := IIF(oModel:HasField("C1_EC06CR")  ,oModel:getValue("C1_EC06CR")  , Nil)
	 	cEC07CR       := IIF(oModel:HasField("C1_EC07CR")  ,oModel:getValue("C1_EC07CR")  , Nil)
	 	cEC08CR       := IIF(oModel:HasField("C1_EC08CR")  ,oModel:getValue("C1_EC08CR")  , Nil)
	 	cEC09CR       := IIF(oModel:HasField("C1_EC09CR")  ,oModel:getValue("C1_EC09CR")  , Nil)

 		aAdd(aEntid, cConta  )
 		aAdd(aEntid, cCusto  )
 		aAdd(aEntid, cItemCTA)
 		aAdd(aEntid, cCLVL   )
 		aAdd(aEntid, cEC05DB )
 		aAdd(aEntid, cEC06DB )
 		aAdd(aEntid, cEC07DB )
 		aAdd(aEntid, cEC08DB )
 		aAdd(aEntid, cEC09DB )
 		
 		aAdd(aEntid2, cConta  )
 		aAdd(aEntid2, cCusto  )
 		aAdd(aEntid2, cItemCTA)
 		aAdd(aEntid2, cCLVL   )
 		aAdd(aEntid2, cEC05CR )
 		aAdd(aEntid2, cEC06CR )
 		aAdd(aEntid2, cEC07CR )
 		aAdd(aEntid2, cEC08CR )
 		aAdd(aEntid2, cEC09CR )
 		
 		If lRet .And.;
		((!CtbAmarra(cConta,cCusto,cItemCTA,cCLVL,/*lPosiciona*/,/*lHelp*/,/*lValidLinOk*/,aEntid) .Or.;
		!CtbAmarra(  cConta,cCusto,cItemCTA,cCLVL,/*lPosiciona*/,/*lHelp*/,/*lValidLinOk*/,aEntid2)) .Or.;
		(!Empty(cConta)  .And. !Ctb105Cta(cConta)) .Or.;
		(!Empty(cCusto)  .And. !Ctb105CC(cCusto)) .Or.;
		(!Empty(cItemCTA).And. !Ctb105Item(cItemCTA)) .Or.;
		(!Empty(cCLVL)   .And. !Ctb105ClVl(cCLVL)))		
							
		lRet := .F.			
		Endif   
	EndIf
	
	If cID == "SCXDETAIL"
	   oModelSC1G    := oModelM:GetModel("SC1DETAIL")	
	   cProduto      := IIF(oModelSC1G:HasField("C1_PRODUTO") ,oModelSC1G:getValue("C1_PRODUTO") , Nil)
 	   cConta        := IIF(oModel:HasField("CX_CONTA")   ,oModel:getValue("CX_CONTA")   , Nil)
 	   cCusto        := IIF(oModel:HasField("CX_CC")      ,oModel:getValue("CX_CC")      , Nil)
 	   cItemCTA      := IIF(oModel:HasField("CX_ITEMCTA") ,oModel:getValue("CX_ITEMCTA") , Nil) 
 	   cCLVL         := IIF(oModel:HasField("CX_CLVL")    ,oModel:getValue("CX_CLVL")    , Nil) 
 	   cEC05DB       := IIF(oModel:HasField("CX_EC05DB")  ,oModel:getValue("CX_EC05DB")  , Nil) 
 	   cEC06DB       := IIF(oModel:HasField("CX_EC06DB")  ,oModel:getValue("CX_EC06DB")  , Nil) 
 	   cEC07DB       := IIF(oModel:HasField("CX_EC07DB")  ,oModel:getValue("CX_EC07DB")  , Nil) 
 	   cEC08DB       := IIF(oModel:HasField("CX_EC08DB")  ,oModel:getValue("CX_EC08DB")  , Nil) 
 	   cEC09DB       := IIF(oModel:HasField("CX_EC09DB")  ,oModel:getValue("CX_EC09DB")  , Nil)
 	   cEC05CR       := IIF(oModel:HasField("CX_EC05CR")  ,oModel:getValue("CX_EC05CR")  , Nil)
 	   cEC06CR       := IIF(oModel:HasField("CX_EC06CR")  ,oModel:getValue("CX_EC06CR")  , Nil)
 	   cEC07CR       := IIF(oModel:HasField("CX_EC07CR")  ,oModel:getValue("CX_EC07CR")  , Nil)
 	   cEC08CR       := IIF(oModel:HasField("CX_EC08CR")  ,oModel:getValue("CX_EC08CR")  , Nil)
 	   cEC09CR       := IIF(oModel:HasField("CX_EC09CR")  ,oModel:getValue("CX_EC09CR")  , Nil)	
 	   
       aAdd(aEntid, cConta  )
 		aAdd(aEntid, cCusto  )
 		aAdd(aEntid, cItemCTA)
 		aAdd(aEntid, cCLVL   )
 		aAdd(aEntid, cEC05DB )
 		aAdd(aEntid, cEC06DB )
 		aAdd(aEntid, cEC07DB )
 		aAdd(aEntid, cEC08DB )
 		aAdd(aEntid, cEC09DB )
 		
 		aAdd(aEntid2, cConta  )
 		aAdd(aEntid2, cCusto  )
 		aAdd(aEntid2, cItemCTA)
 		aAdd(aEntid2, cCLVL   )
 		aAdd(aEntid2, cEC05CR )
 		aAdd(aEntid2, cEC06CR )
 		aAdd(aEntid2, cEC07CR )
 		aAdd(aEntid2, cEC08CR )
 		aAdd(aEntid2, cEC09CR )
 	   
 	   If (!CtbAmarra(cConta,cCusto,cItemCTA,cCLVL,/*lPosiciona*/,/*lHelp*/,/*lValidLinOk*/,aEntid) .Or.;
	 	   !CtbAmarra(cConta,cCusto,cItemCTA,cCLVL,/*lPosiciona*/,/*lHelp*/,/*lValidLinOk*/,aEntid2))
	   		lRet := .F.
		EndIf
	EndIf
	
Return lRet