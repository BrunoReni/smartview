#INCLUDE "Protheus.ch"    

/*/
______________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+------------------------------------------------------------------------+¦¦
¦¦¦Funcao    ¦  COMA050    ¦ Autor ¦ Bruna Paola      ¦ Data ¦ 27/04/11    ¦¦¦
¦¦+----------+-------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Cadastro de tipos de documentos.				   			   ¦¦¦
¦¦+----------+-------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo TOTVS.								   			   ¦¦¦
¦¦+----------+-------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/
Function COMA050 ()  

Local cAlias := "COL"
Private cCadastro := "Tipo de Documentos"
Private aRotina := {}
  
AADD(aRotina,{"Pesquisar"	,"AxPesqui",0,1})
AADD(aRotina,{"Visualisar"	,"AxVisual",0,2})
AADD(aRotina,{"Incluir"    	,"CM050INC",0,3})
AADD(aRotina,{"Alterar"    	,"CM050MTC",0,4})
AADD(aRotina,{"Excluir"    	,"CM050MTC",0,5}) 

dbSelectArea(cAlias)
dbSetOrder(1)
mBrowse(6,1,22,75,cAlias)

Return Nil        
     

Function CM050MTC(cAlias, nReg, nOpc)

Local nOpcao := 0
Local cMsg := ""   
Local cVldAlt := ".T." // Validacao para permitir a alteracao. Pode-se utilizar ExecBlock.
Local cVldExc := ".T." // Validacao para permitir a exclusao. Pode-se utilizar ExecBlock.

DbSelectArea("COE")
DbSetOrder(2)  //COE_FILIAL+COE_DOC //Tipo de Documento 
DbGoTop()

cVldExc := ".T."
cVldAlt := ".T."  

Do While !(Eof())   
     
	If (COL->COL_COD == COE->COE_DOC) //Verifica se existe intervalo de codigo vinculado ao tipo de documento
		cVldExc := ".F."
		cVldAlt := ".F." 
		Exit		
	EndIf   
	
	dbSkip()
EndDo
 
 // Existe SC vinculada a sequencia 
If (cVldExc == ".F." .Or. cVldAlt == ".F.")

	If (nOpc == 4)
		cMsg := "O tipo de documento nao pode ser alterado, pois esta vinculado a Intervalo de Codigos"
	Else
		cMsg := "O tipo de docuemnto nao pode ser excluido, pois esta vinculado a Intervalo de Codigos"
	EndIf 
	
	MsgAlert(cMsg,"ATENCAO")
	  
	Return Nil
	
EndIf

If (nOpc == 4)
	nOpcao := AxAltera(cAlias,nReg,nOpc)   
Else
	nOpcao := AxDeleta(cAlias,nReg,nOpc) 
EndIf
 
Return Nil   
 
/*/
______________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+------------------------------------------------------------------------+¦¦
¦¦¦Funcao    ¦  CM050MTC    ¦ Autor ¦ Bruna Paola      ¦ Data ¦ 08/06/11   ¦¦¦
¦¦+----------+-------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Cadastro de tipos de documentos(Inclusao).	   			   ¦¦¦
¦¦+----------+-------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo TOTVS.								   			   ¦¦¦
¦¦+----------+-------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/
Function CM050INC(cAlias, nReg, nOpc)

Local aParam := {} 

//adiciona codeblock a ser executado no inicio, meio e fim
aAdd( aParam,  {|| 				 	} )  //antes da abertura
aAdd( aParam,  {|| CM050VlInc()		} )  //ao clicar no botao ok
aAdd( aParam,  {|| 					} )  //durante a transacao
aAdd( aParam,  {|| ConfirmSX8() 	} )       //termino da transacao
                                                                                   
                                                                                   
AxInclui(cAlias,nReg,nOpc,,,,,,,,aParam) 

Return             

Function CM050VlInc()
Local aArea := GetArea()
Local lRet := .T.

DbSelectArea("COL")
DbSetOrder(1)
If COL->( DbSeek( xFilial("COL") + M->COL_COD ) )
	MsgInfo("Código já cadastrado.")
	lRet := .F.
End If

RestArea(aArea)
Return lRet