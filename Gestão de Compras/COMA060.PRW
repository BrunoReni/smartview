#INCLUDE "Protheus.ch"    
#INCLUDE "rwmake.ch"

/*/
______________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+------------------------------------------------------------------------+¦¦
¦¦¦Funcao    ¦  COMA060    ¦ Autor ¦ Bruna Paola      ¦ Data ¦ 27/04/11    ¦¦¦
¦¦+----------+-------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Cadastro de Intervalos de codigos.				   		   ¦¦¦
¦¦+----------+-------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo TOTVS.								   			   ¦¦¦
¦¦+----------+-------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/ 
Function COMA060 () 

Local cAlias := "COE"
Private cCadastro := "Intervalo de Codigos"
Private aRotina := {}
  
AADD(aRotina,{"Pesquisar"   ,"AxPesqui",0,1})
AADD(aRotina,{"Visualisar"  ,"AxVisual",0,2})
AADD(aRotina,{"Incluir"     ,"CM060INC",0,3})
AADD(aRotina,{"Alterar" 	,"CM060MTC",0,4})
AADD(aRotina,{"Excluir" 	,"CM060MTC",0,5}) 

dbSelectArea(cAlias)
dbSetOrder(1)
mBrowse(6,1,22,75,cAlias)

Return Nil    

/*/
______________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+------------------------------------------------------------------------+¦¦
¦¦¦Funcao    ¦  CM060INC    ¦ Autor ¦ Bruna Paola       ¦ Data ¦ 23/05/11  ¦¦¦
¦¦+----------+-------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Inclusao do intervalo de codigos.						   ¦¦¦
¦¦+----------+-------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo TOTVS.								   			   ¦¦¦
¦¦+----------+-------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/  
Function CM060INC(cAlias, nReg, nOpc)
 
Local aParam := {} 

//adiciona codeblock a ser executado no inicio, meio e fim
aAdd( aParam,  {|| } )  //antes da abertura
aAdd( aParam,  {|| CM060VL6()} )  //ao clicar no botao ok
aAdd( aParam,  {|| } )  //durante a transacao
aAdd( aParam,  {|| ConfirmSX8() } )       //termino da transacao

AxInclui(cAlias,nReg,nOpc,,,,,,,,aParam)
	
Return Nil

/*/
______________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+------------------------------------------------------------------------+¦¦
¦¦¦Funcao    ¦  CM060VL6    ¦ Autor ¦ Bruna Paola       ¦ Data ¦ 23/05/11  ¦¦¦
¦¦+----------+-------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Validacao do botao confirma da inclusao de intervalo.	   ¦¦¦
¦¦+----------+-------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo TOTVS.								   			   ¦¦¦
¦¦+----------+-------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/  
Function CM060VL6(cAlias, nReg, nOpc)

Local cMsg := "" 

If (nOpc == 4)
	If (COE->COE_FINAL <= COE->COE_INICIO)
		cMsg := "O valor final deve ser maior que o inicial!" 
		             
		MsgAlert(cMsg,"ATENCAO")
		Return (.F.)
	EndIf
Else
	If (M->COE_FINAL <= M->COE_INICIO)
		cMsg := "O valor final deve ser maior que o inicial!" 
		             
		MsgAlert(cMsg,"ATENCAO")
		Return (.F.)
	EndIf
EndIf

Return (.T.)

/*/
______________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+------------------------------------------------------------------------+¦¦
¦¦¦Funcao    ¦  CM060MTC    ¦ Autor ¦ Bruna Paola       ¦ Data ¦ 02/05/11  ¦¦¦
¦¦+----------+-------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Funcao de manutencao de cadastro da COE(altera e exclui).   ¦¦¦
¦¦+----------+-------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo TOTVS.								   			   ¦¦¦
¦¦+----------+-------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/  
Function CM060MTC(cAlias, nReg, nOpc)

Local nOpcao := 0
Local nAltExc := 0 
Local cMsg := ""      

DbSelectArea("SC1")
DbSetOrder(1)  //C1_FILIAL+C1_NUM+C1_ITEM  
DbGoTop()  

Do While !(Eof())   
     
	If (COE->COE_DOC == SC1->C1_XTIPOSC) //Verifica se existe SC vinculada ao tipo de documento 
		
		If (SC1->C1_NUM >= COE->COE_INICIO).And.(SC1->C1_NUM <= COE->COE_FINAL) //Verifica se o Num da SC esta entre o range cadastrado
		    nAltExc := 1
		    Exit
		EndIf		
	EndIf   
	
	dbSkip()
EndDo
  
 // Existe SC vinculada a sequencia 
If (nAltExc == 1)
	
	If (nOpc == 4)
		cMsg := "O intervalo nao pode ser alterado, pois esta vinculado a Solicitacao de Compras"
	Else
		cMsg := "O intervalo nao pode ser excluido, pois esta vinculado a Solicitacao de Compras"
	EndIf
	     
	MsgAlert(cMsg,"ATENCAO")
	  
	Return Nil
EndIf                                          

If (nOpc == 4)
	nOpcao := AxAltera(cAlias,nReg,nOpc,,,,,"CM060VL6()")
Else
	nOpcao := AxDeleta(cAlias,nReg,nOpc) 
EndIf
 
Return Nil
        
                        
/*/
______________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+------------------------------------------------------------------------+¦¦
¦¦¦Funcao    ¦  CM060MSG    ¦ Autor ¦ Bruna Paola      	¦ Data ¦ 26/04/11  ¦¦¦
¦¦+----------+-------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Apresenta mensagem de erro para o usuario.	   			   ¦¦¦
¦¦+----------+-------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo TOTVS.								   			   ¦¦¦
¦¦+----------+-------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/
Function CM060MSG(cMSG)   

MsgAlert(cMSG,"ATENCAO")    

return (.F.)

    
/*/
______________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+------------------------------------------------------------------------+¦¦
¦¦¦Funcao    ¦  CM060VL1    ¦ Autor ¦ Bruna Paola      	¦ Data ¦ 26/04/11  ¦¦¦
¦¦+----------+-------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Verfica o tamanho da string digitada.		   			   ¦¦¦
¦¦+----------+-------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo TOTVS.								   			   ¦¦¦
¦¦+----------+-------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/
Function CM060VL1(cString)

cString := AllTrim(cString)    

If (LEN(cString) <> 6)
	MsgAlert("O valor deve ter 6 caracteres.", "ATENCAO")
	return (.F.)  	
ElseIf (CM060VL5(cString))     
	MsgAlert("O valor deve ter ao menos um caracter alpha.", "ATENCAO")
	return (.F.)  
Else
	If ( CM060VL2(cString) == .F.)
		return (.F.)
	EndIf
EndIf                                                   

return (.T.)  


/*/
______________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+------------------------------------------------------------------------+¦¦
¦¦¦Funcao    ¦  CM060VL2    ¦ Autor ¦ Bruna Paola      	¦ Data ¦ 27/04/11  ¦¦¦
¦¦+----------+-------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Verifica o intervalo dos ranges definidos.    			   ¦¦¦
¦¦+----------+-------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo TOTVS.								   			   ¦¦¦
¦¦+----------+-------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/                                                                              
Function CM060VL2(cRange) 

Local cChave := "" 
              
//Tabela de cadastro de intervalo de codigo(range)
DbSelectArea("COE")
DbSetOrder(1) 
DbGoTop()

Do	While !( Eof() )   
         
	cChave := COE->COE_FILIAL+COE->COE_COD //Indice da tabela    
	
	Do	While !( Eof() ) .And. ( COE->COE_FILIAL+COE->COE_COD == cChave )
	
		//Verifica se o valor inicial e final estao dentro de outro intervalo
		If (cRange >= COE->COE_INICIO).And.(cRange <= COE->COE_FINAL)
			    
		   CM060MSG("Este valor esta dentro de um intervalo ja definido.") 
		   
		   return (.F.)  
		EndIf  
	 
		DbSkip()
	EndDo

EndDo   

return (.T.)      

/*/
______________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+------------------------------------------------------------------------+¦¦
¦¦¦Funcao    ¦  CM060VL2    ¦ Autor ¦ Bruna Paola      	¦ Data ¦ 27/04/11  ¦¦¦
¦¦+----------+-------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Verifica se o campo de range tem pelo menos uma letra.	   ¦¦¦
¦¦+----------+-------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo TOTVS.								   			   ¦¦¦
¦¦+----------+-------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/ 
Static Function CM060VL5(cExp)

LOCAL lReturn:= .T.
LOCAL I

FOR I:= 1 TO LEN(cExp)
    if !(substr(cExp,i,1) $ "0123456789")
       lReturn:= .F.
    endif
    if !lReturn
       EXIT
    endif
NEXT
Return(lReturn)
