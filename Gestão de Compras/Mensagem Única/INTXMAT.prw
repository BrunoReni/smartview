#Include 'Protheus.ch'    
 
Function INTXMAT()

Return

/*/{Protheus.doc} INTREG()
Verifica se o registro foi originado via integração

@author  Rodrigo Machado Pontes
@version P12
@since   26/10/2015
@return  lRet
/*/

Function INTREG(cAliasReg,cNumero) 

Local aArea	:= GetArea()
Local lRet		:= .F.

If cAliasReg == "SC7"
	DbSelectArea("SC7")
	SC7->(DbSetOrder(1))
	If SC7->(DbSeek(xFilial("SC7") + PadR(cNumero,TamSx3("C7_NUM")[1])))
		If AllTrim(SC7->C7_ORIGEM) == "MSGEAI"
			lRet := .T.
		Else
			DbSelectArea("SC1")
			SC1->(DbSetOrder(1))
			If SC1->(DbSeek(xFilial("SC1") + PadR(SC7->C7_NUMSC,TamSx3("C1_NUM")[1])))
				If AllTrim(SC1->C1_ORIGEM) == "SOLUM" .Or. AllTrim(SC1->C1_ORIGEM) == "MSGEAI"
					lRet := .T.
				Endif
			Endif
		Endif
	Endif
Elseif cAliasReg == "SC1"
	DbSelectArea("SC1")
	SC1->(DbSetOrder(1))
	If SC1->(DbSeek(xFilial("SC1") + PadR(cNumero,TamSx3("C1_NUM")[1])))
		If AllTrim(SC1->C1_ORIGEM) == "SOLUM" .Or. AllTrim(SC1->C1_ORIGEM) == "MSGEAI"
			lRet := .T.
		Endif
	Endif
Endif

RestArea(aArea)

Return lRet

/*/{Protheus.doc} INTELIRES()
Verifica se o PC ou SC houve uma eliminação de residuo, 
caso SIM é enviada a mensagem de retorno

@author  Rodrigo Machado Pontes
@version P12
@since   26/10/2015
@return  lRet
/*/

Function INTELIRES(cAliasEli)

Local lRet			:= .F.
Local lResiduo	:= .F.
Local lIntReg		:= .F.

If cAliasEli == "SC7" 
	
	If INCLUI .Or. ALTERA
		//Somente envia ORDER, quando for um eliminação de residuo do PC
		//e a SC ou PC foi originada via integração
		If INTREG("SC7",SC7->C7_NUM) .And. AllTrim(SC7->C7_RESIDUO) == "S"
			lIntReg 	:= .T.
			lResiduo	:= .T.
		Endif	
	Else
		//Somente envia ORDER (DELETE), quando a SC foi originada via integração
		//e houve eliminação de residuo da SC ou do PC
		DbSelectArea("SC7")
		SC7->(DbSetOrder(1))
		If SC7->(DbSeek(xFilial("SC7") + PadR(SC7->C7_NUM,TamSx3("C7_NUM")[1])))
			If (AllTrim(Posicione("SC1",1,xFilial("SC1") + Padr(SC7->C7_NUMSC,TamSx3("C1_NUM")[1]),"C1_RESIDUO")) == "S" .Or. AllTrim(SC7->C7_RESIDUO) == "S") .And. INTREG("SC7",SC7->C7_NUM) 
				lIntReg 	:= .T.
				lResiduo	:= .T.
			Endif
		Endif
	Endif 
	
	If lIntReg .And. lResiduo
		lRet := .T.
	Endif

Elseif cAliasEli == "SC1"
	//Somente envia REQUEST, quando for um eliminação de residuo da SC
	//e a SC foi originada via integração
	If INCLUI .Or. ALTERA
		If AllTrim(SC1->C1_RESIDUO) == "S" .And. INTREG("SC1",SC1->C1_NUM)
			lIntReg 	:= .T.
			lResiduo	:= .T.
		Endif
	Endif
	
	If (INCLUI .Or. ALTERA) .And. lIntReg .And. lResiduo
		lRet := .T.
	Endif 
Endif

Return lRet

/*/{Protheus.doc} INTDTANO()
Ajusta o campo DATA para que o ano sempre tenho 4 digitos.

@author  Rodrigo Machado Pontes
@version P12
@since   07/05/2018
@return  lRet
/*/

Function INTDTANO(dData)

Local cDataRet	:= ""

If ValType(dData) == "C"
	If "/" $ dData
		dData := CtoD(dData)
	Else
		dData := StoD(dData)
	Endif
Endif

cDataRet := AllTrim(Str(Year(dData))) + "-" + AllTrim(StrZero(Month(dData),2)) + "-" + AllTrim(StrZero(Day(dData),2))

Return cDataRet