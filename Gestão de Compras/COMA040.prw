#INCLUDE "COMA040.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³COMA040   ºAutor  ³Silvia Monica       º Data ³  26/04/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Cadastro de Divergencias da Nota Fiscal Entrada             º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP Especifico para CNI                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function COMA040
	Local cVldAlt := ".T."	// Validacao para permitir a alteracao. Pode-se utilizar ExecBlock.
	Local lMvNfeDvg := SuperGetMV("MV_NFEDVG", .F., .T.)

	Private cString := "COF"

	dbSelectArea("COF")
	dbSetOrder(1)

	If lMvNfeDvg
		AxCadastro(cString,STR0001,"ExcDiv()",cVldAlt) //#"Cadastro de Divergencias"
	Else
		Help(,, "A040CHKSX6",, STR0003, 4, 1,,,,,, {STR0004}) //-- Funcionalidade desabilitada!" "Ative o parâmetro MV_NFEDVG."
	EndIf

Return

/*/{Protheus.doc} ExcDiv
	Funcao para tratar a exclusao do cadastro de divergencias
@author Silvia Monica (Fabrica de software)
@since 28/12/2020
/*/
Function ExcDiv()
	Local aArea  := GetArea()                  
	Local lRet      := .T.
	
	dbSelectArea("COG")
	dbSetOrder(2)
																										
	if  dbSeek(xFilial("COG")+COF->COF_CODIGO)
		Help(" ",1,STR0002) // #"Codigo foi usado em NF, não pode ser deletado"
		lRet := .F.
	Endif

	RestArea(aArea)	
Return (lRet)                                             
         
/*/{Protheus.doc} CA040MAN
	Funcao para incluir e alterar as divergencias no checkbox da Pre-Nota
@author Silvia Monica (Fabrica de software)
@since 28/12/2020
/*/
 Function CA040MAN( _aDivPNF )
	Local _cArea    := GetArea()
	Local n			:= 0
	Local cChaveF1	:= SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA
	
	dbSelectArea("COG")    
	COG->(dbSetOrder(1)) //COG_FILIAL+COG_DOC+COG_SERIE+COG_FORNEC+COG_LOJA+COG_CODIGO  /COG_FILIAL+COG_CODIGO

	For n := 1 To Len(_aDivPNF) 
		If  _aDivPNF[n][1] = .T.  .And. (INCLUI .Or. ALTERA)
			If !COG->(DbSeek(xFilial('COG')+cChaveF1+_aDivPNF[n][3]))
				RecLock("COG", .T.)
					COG->COG_FILIAL := xFilial()
					COG->COG_DOC    := SF1->F1_DOC
					COG->COG_SERIE  := SF1->F1_SERIE 
					COG->COG_FORNEC := SF1->F1_FORNECE
					COG->COG_LOJA   := SF1->F1_LOJA
					COG->COG_CODIGO := _aDivPNF[n][3]
				MsUnLock()    
			Endif    
			_aDivPNF[n][1] := .F.                            
		ElseIf _aDivPNF[n][1] = .F. .And. ALTERA
			If COG->(DbSeek(xFilial('COG')+cChaveF1+_aDivPNF[n][3]))		 
				RecLock( "COG", .F. )
					dbDelete()  
				MsUnLock()    
			Endif 
		Endif 
	Next                 
		
	_aDivPNF := {}            // limpa o checkbox

	RestArea(_cArea)			                 
		
Return

/*/{Protheus.doc} CA040MAN
	Exclui as divergencias que estiverem  no checkbox da Pre-Nota
@author Silvia Monica (Fabrica de software)
@since 28/12/2020
/*/
Function CA040EXC()
	Local _cArea    := GetArea()  

	dbSelectArea("COG")    
	dbSetOrder(1)   

	dbSeek(xFilial("COG")+SF1->(F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA))

	Do While !Eof() .and. xFilial("COG")+COG->(COG_DOC+COG_SERIE+COG_FORNECE+COG_LOJA) = xFilial("SF1")+SF1->(F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA) 
		RecLock( "COG", .F. )
			dbDelete()  
		MsUnLock()    
		dbSkip()
	Enddo 

	If  Type("_aDivPNF") != "U"
		_aDivPNF := {} //   limpa o checkbox das divergencias
	Endif   
		
	RestArea(_cArea)			     
Return

/*/{Protheus.doc} CA040MAN
	mostra as divergencias no checkbox que estiverem cadastradas na Pre-Nota
@author Silvia Monica (Fabrica de software)
@since 28/12/2020
/*/ 
Function CA040VER(cDoc,cSerie,cFornece,cLoja,cDiv)
	Local lRet := .F.    
	Local _cArea:= GetArea()

	dbSelectArea("COG")    
	dbSetOrder(1)  
	
	lRet := dbSeek(xFilial("COG")+cDoc+cSerie+cFornece+cLoja+cDiv)
						
	RestArea(_cArea)	
Return(lRet)
