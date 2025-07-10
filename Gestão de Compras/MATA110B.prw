#Include 'Protheus.ch'
#Include 'RwMake.ch'
#Include 'TopConn.ch'
#Include "FWAdapterEAI.ch"

/*
{Protheus.doc} MATA110B(cXML,nTypeTrans,cTypeMessage,cVersion)
	Rastreabilidade de solicitação de compra ou armazem                                                            
	
	@author	Rodrigo Machado Pontes
	@version	P11
	@since	21/03/2013
*/

Function MATA110B()

FwIntegDef("MATA110B")

Return

/*
{Protheus.doc} IntegDef(cXML,nTypeTrans,cTypeMessage,cVersion)
	Rastreabilidade de solicitação de compra ou armazem                                
		
	@param	cXML      		Conteudo xml para envio/recebimento
	@param nTypeTrans		Tipo de transacao. (Envio/Recebimento)              
	@param	cTypeMessage  Tipo de mensagem. (Business Type, WhoIs, etc)
	@param	cVersion		Versão em uso
	
	@retorno aRet			Array contendo o resultado da execucao e a mensagem Xml de retorno.
				aRet[1]	(boolean) Indica o resultado da execução da função
				aRet[2]	(caracter) Mensagem Xml para envio                             
	
	@author	Rodrigo Machado Pontes
	@version	P11
	@since	21/03/2013
*/

Static Function IntegDef( cXML, nTypeTrans, cTypeMessage, cVersion )

Local aRet := {}

aRet := MATI110B(cXml, nTypeTrans, cTypeMessage, AllTrim(cVersion))

Return aRet

