#include "Protheus.ch"
#include "MATA020B.ch" 

Static cCodUnq		:= ""
Static cCGC			:= ""
Static cIE			:= ""
Static cRG			:= ""

/*/{Protheus.doc} MATA020B
//Rotina de Integração código unico
@author tiago.dsantos
@since 08/06/2017
@version undefined
@param lUpdChave, 	logical,  .T. para quando existir a chave unica CNPJ CPF + Inscricao Estadual
@param cCodigo, 	characters, retorno do código disponibilizado por referencia
@param cRotina, 	characters, nome da rotina de cadastro
@param lShowMsg, 	boolean, Exibe mensagem?
@param lLimpaCache,	boolean, Exclui Cache?
@param lCriaMem,	boolean, Re-Cria variáveis de memória?
@type function
/*/
Function MATA020B( lUpdChave , cCodigo , cRotina, lShowMsg , lLimpaCache, lCriaMem )
Local   lRet       := .F.

Default lUpdChave 	:= .F.
Default cCodigo		:= ""
Default cRotina    	:= FunName()
Default lShowMsg   	:= !IsBlind()	
Default lLimpaCache	:= .F. 
Default lCriaMem	:= .F. 

If !Empty(cCodUnq)	
	If RTrim(cCodigo) <> RTrim(cCodUnq)
		lUpdChave	:= .F. 
		
		If lCriaMem
			lUpdChave	:= .T. 
		EndIf
		
	Else
		lUpdChave	:= .T. 
	EndIf	
EndIf

If lCriaMem
	If cRotina	== "MATA020"
	
		//-- Cria variaveis de memória
		CriaVar("A2_COD",.F.)
		CriaVar("A2_CGC",.F.)
		CriaVar("A2_INSCR",.F.)
		CriaVar("A2_PFISICA",.F.)
		
		//-- Atribui valores estáticos
		M->A2_COD		:= cCodUnq
		M->A2_CGC		:= cCGC
		M->A2_INSCR 	:= cIE
		M->A2_PFISICA	:= cRG
		
	ElseIf cRotina == "MATA030"
	
		//-- Cria variaveis de memória
		CriaVar("A1_COD",.F.)
		CriaVar("A1_INSCR",.F.)
		CriaVar("A1_CGC",.F.)
		CriaVar("A1_PFISICA",.F.)
		
		//-- Atribui valores estáticos
		M->A1_COD		:= cCodUnq
		M->A1_INSCR		:= cIE
		M->A1_CGC		:= cCGC
		M->A1_PFISICA	:= cRG
		
	ElseIf cRotina == "MATA050"
		
		//-- Cria variáveis de memória
		CriaVar("A4_COD",.F.)
		CriaVar("A4_CGC",.F.)
		CriaVar("A4_INSEST",.F.)
		
		//-- Atribui valores estáticos
		M->A4_COD		:= cCodUnq
		M->A4_CGC		:= cCGC
		M->A4_INSEST	:= cIE
		
	EndIf
EndIF

If lShowMsg
	MsgRun(STR0005,STR0006, {|| lRet := A020BInteg(lUpdChave,@cCodigo,cRotina) })
Else
	lRet := A020BInteg(lUpdChave,cCodigo,cRotina)
EndIf

//-- Exclui variáveis estaticas
If lLimpaCache
	A020BReset()
EndIf

Return lRet

/*/{Protheus.doc} A020BInteg
//TODO Descrição auto-gerada.
@author tiago.dsantos
@since 08/06/2017
@version undefined
@param lUpdChave, logical, descricao
@param cCodigo, characters, descricao
@param cRotina, characters, descricao
@type function
/*/
Static Function A020BInteg(lUpdChave,cCodigo,cRotina)
Local cResult       := ""
Local aEAIRET       := {}
Local lRet          := .T.
Local lEAIFun       := FwHasEAI("MATA020B",.T.,.T.,.T.)//Envia=.T.,Recebe=.T.,Mensagem Única=.T.
Local cRotBkp		:= GetRotInteg()

Private cUnqOrigem  := ""
Private cUnqKey     := ""
Private cCodResult  := ""
Private lHasCode    := .F.

Default cCodigo     := ""
Default lUpdChave   := .F.
Default cRotina     := Funname()

//-- cRotina é informado para determinar a rotina de chamada como sendo MATA020,MATA030 ou MATA050
If !Empty(cRotina)
	cUnqOrigem := cRotina
EndIf

If lEAIFun 
	lHasCode := lUpdChave
	
	SetRotInteg("MATA020B")
	aEAIRet := FwIntegDef("MATA020B",,,,"MATA020B") //| Chamada da rotina de integração.
	
	If ValType(aEAIRet) == "U"
		Help('',1,'MATA020B-01',,STR0004,01,02) //-- "Integracao Nao Realizada"
		lRet := .F.
	Else
		If aEAIRet[1] == .F.
			Help('',1,'MATA020B-02',,aEAIRET[2],01,02)
			lRet := .F.
		Else
			cCodigo := cCodResult //-- cCodResult tem o valor atribuído pelo Response da rotina NLockerEAI chamada pela rotina MATA020B cadastrada no adapter.
			GuardaCod( cCodigo ) //-- Atribui a variavel estatica
		EndIf
	EndIf
	
	SetRotInteg(cRotBkp)	
EndIf

Return lRet

/*/{Protheus.doc} IntegDef
//TODO Descrição auto-gerada.
@author tiago.dsantos
@since 08/06/2017
@version undefined
@param cXml, characters, descricao
@param nType, numeric, descricao
@param cTypeMsg, characters, descricao
@param cVersion, characters, descricao
@type function
/*/
Static Function IntegDef(cXml,nType,cTypeMsg,cVersion)
Local aRet := {}

aRet := MATI020B(cXml,nType,cTypeMsg,cVersion)

Return aRet 

/*/{Protheus.doc} GuardaCod
//Função que armazena o código
@author caio.y
@since 21/06/2017
@version undefined
@param cCodigo, characters, descricao
@type function
/*/
Static Function GuardaCod( cCodigo )
Local cRotina 	:= Upper( FunName() ) 

Default cCodigo	:= ""

cCodUnq	:= cCodigo	 

If Upper(cRotina) == "MATA020"
	cIE  	:= M->A2_INSCR
	cRG		:= M->A2_PFISICA
	cCGC  	:= M->A2_CGC		
ElseIf Upper(cRotina) == "MATA030"
	cIE  	:= M->A1_INSCR
	cRG		:= M->A1_PFISICA
	cCGC  	:= M->A1_CGC
ElseIf Upper(cRotina) == "MATA050"
	cIE  	:= M->A4_INSEST
	cCGC  	:= M->A4_CGC
	cRG		:= ""
EndIf

Return .T. 


/*/{Protheus.doc} A020BReset
//Reseta variáveis staticas
@author caio.y
@since 21/06/2017
@version undefined

@type function
/*/
Static Function A020BReset()

cCodUnq		:= ""
cCGC		:= ""
cIE			:= ""
cRG			:= ""

Return .T. 

