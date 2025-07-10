#Include 'Protheus.ch'
#Include 'TopConn.ch'
#Include "FWAdapterEAI.ch"

/*
{Protheus.doc} MATA020A()
	Informação dos Fornecedores, tem a finalidade de verificar atraves do CPF/CNPJ 
	se determinado fornecedor esta cadastrado.                                
			
	@author	Leonardo Quintania
	@version	P12
	@since	05/06/2015
*/
Function MATA020A()
Return FwIntegDef("MATA020A")
 
/*
{Protheus.doc} IntegDef(cXML,nTypeTrans,cTypeMessage,cVersion)
	Informação dos Fornecedores                            
		
	@param	cXML      		Conteudo xml para envio/recebimento
	@param nTypeTrans		Tipo de transacao. (Envio/Recebimento)              
	@param	cTypeMessage  Tipo de mensagem. (Business Type, WhoIs, etc)
	@param	cVersion		Versão em uso
	
	@retorno aRet			Array contendo o resultado da execucao e a mensagem Xml de retorno.
				aRet[1]	(boolean) Indica o resultado da execução da função
				aRet[2]	(caracter) Mensagem Xml para envio                             
	
	@author	Leonardo Quintania
	@version	P12
	@since	05/06/2015
*/
Static Function IntegDef(cXML,nTypeTrans,cTypeMessage,cVersion)
Return MATI020A(cXml,nTypeTrans,cTypeMessage,cVersion)