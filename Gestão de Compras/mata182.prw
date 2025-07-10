#include "MATA182.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TBICONN.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef()
Definicao do Modelo
@author Leonardo Quintania
@since 28/01/2013
@version 1.0
@return oModel
/*/
//-------------------------------------------------------------------
Static Function ModelDef()  
Local oStruCab := FWFormStruct(1,"DBJ") //Estrutura Cabecalho 
Local oStruDBH := FWFormStruct(1,"DBH",{|cCampo| AllTrim(cCampo) $ "DBH_SUGEST|DBH_FILABA|DBH_PRIORI|DBH_CONTOT|DBH_ABATOT|DBH_NECTOT"}) //Estrutura Itens DBH
Local oStruDBI := FWFormStruct(1,"DBI",{|cCampo| AllTrim(cCampo) $ "DBI_PRODUT|DBI_DESCPR|DBI_CONSUM|DBI_SLDABA|DBI_NECALC|DBI_NECINF|DBI_SLDFIS|DBI_SLDDIS|DBI_SLDTRA|DBI_QTDCOM"}) //Estrutura Itens DBI
Local oStruCPM := FWFormStruct(1,"CPM") //Estrutura da CPM
Local oModel   := NIL

//------------------------------------------------------
//		Cria a estrutura basica
//------------------------------------------------------
oModel:= MPFormModel():New("MATA182", /*Pre-Validacao*/,/*Pos-Validacao*/, { |oModel| A182Commit( oModel ) },/*Cancel*/)

oStruDBI:SetProperty( "DBI_NECINF" , MODEL_FIELD_VALID, {|a,b,c,d,e| Positivo() .And. A182CalNec(a,b,c,d,e)} )
oStruDBI:SetProperty( "DBI_SLDTRA" , MODEL_FIELD_VALID, {|a,b,c,d,e| Positivo() .And. A181VldSld() .And. A182CalSld(a,b,c,d,e)} )
oStruDBI:SetProperty( "DBI_SLDFIS" , MODEL_FIELD_INIT, {|a,b,c,d,e| A179SldFil(DBJ->DBJ_FILDIS, DBI->DBI_PRODUT,.T.)} )

//-- Campo Nome da Filial
oStruDBH:AddField("Nome"		   													,;	// 	[01]  C   Titulo do campo  - Matriz de Abastecimento//"Cod. Produto"
				 "Nome"															,;	// 	[02]  C   ToolTip do campo - Codigo da Matriz de Abastecimento//"Código do produto"
				 "DBH_NFILAB"														,;	// 	[03]  C   Id do Field
				 "C"																,;	// 	[04]  C   Tipo do campo
				 15																	,;	// 	[05]  N   Tamanho do campo
				 0																	,;	// 	[06]  N   Decimal do campo
				 NIL																,;	// 	[07]  B   Code-block de validação do campo
				 NIL																,;	// 	[08]  B   Code-block de validação When do campo
				 NIL																,;	//	[09]  A   Lista de valores permitido do campo
				 .F.																,;	//	[10]  L   Indica se o campo tem preenchimento obrigatório
				 NIL																,;	//	[11]  B   Code-block de inicializacao do campo
				 NIL																,;	//	[12]  L   Indica se trata-se de um campo chave
				 NIL																,;	//	[13]  L   Indica se o campo pode receber valor em uma operação de update.
				 .F.																)	// 	[14]  L   Indica se o campo é virtual
				 
//-- Campo Necessidade Informada
oStruDBH:AddField("Nec. Inf"													,;	// 	[01]  C   Titulo do campo  - Doc. de Compra
				 STR0003															,;	// 	[02]  C   ToolTip do campo - Doc. de Compra//"Necessidade Informada"
				 "DBH_NECINF"														,;	// 	[03]  C   Id do Field
				 "N"																,;	// 	[04]  C   Tipo do campo
				 14																	,;	// 	[05]  N   Tamanho do campo
				 0																	,;	// 	[06]  N   Decimal do campo
				 {|a,b,c,d,e| A182CalQtd(a,b,c,d,e) }							,;	// 	[07]  B   Code-block de validação do campo
				 NIL																,;	// 	[08]  B   Code-block de validação When do campo
				 NIL																,;	//	[09]  A   Lista de valores permitido do campo
				 .F.																,;	//	[10]  L   Indica se o campo tem preenchimento obrigatório
				 NIL																,;	//	[11]  B   Code-block de inicializacao do campo
				 NIL																,;	//	[12]  L   Indica se trata-se de um campo chave
				 NIL																,;	//	[13]  L   Indica se o campo pode receber valor em uma operação de update.
				 .F.																)	// 	[14]  L   Indica se o campo é virtual

//-- Campo Saldo a transferir
oStruDBH:AddField(STR0006														,;	// 	[01]  C   Titulo do campo  - Doc. de Compra//"Sld. Transf."
				 STR0007															,;	// 	[02]  C   ToolTip do campo - Doc. de Compra//"Saldo a Transferir"
				 "DBH_SLDTRA"														,;	// 	[03]  C   Id do Field
				 "N"																,;	// 	[04]  C   Tipo do campo
				 14																	,;	// 	[05]  N   Tamanho do campo
				 0																	,;	// 	[06]  N   Decimal do campo
				 {|a,b,c,d,e| A182VldSld(a,b,c,d,e)} 							,;	// 	[07]  B   Code-block de validação do campo
				 NIL																,;	// 	[08]  B   Code-block de validação When do campo
				 NIL																,;	//	[09]  A   Lista de valores permitido do campo
				 .F.																,;	//	[10]  L   Indica se o campo tem preenchimento obrigatório
				 NIL																,;	//	[11]  B   Code-block de inicializacao do campo
				 NIL																,;	//	[12]  L   Indica se trata-se de um campo chave
				 NIL																,;	//	[13]  L   Indica se o campo pode receber valor em uma operação de update.
				 .F.																)	// 	[14]  L   Indica se o campo é virtual

//-- Campo Quantidade a Comprar
oStruDBH:AddField(STR0008														,;	// 	[01]  C   Titulo do campo  - Doc. de Compra//"Qtd. Comprar"
				 STR0009															,;	// 	[02]  C   ToolTip do campo - Doc. de Compra//"Quantidade a Comprar"
				 "DBH_QTDCOM"														,;	// 	[03]  C   Id do Field
				 "N"																,;	// 	[04]  C   Tipo do campo
				 14																	,;	// 	[05]  N   Tamanho do campo
				 0																	,;	// 	[06]  N   Decimal do campo
				 NIL																,;	// 	[07]  B   Code-block de validação do campo
				 NIL																,;	// 	[08]  B   Code-block de validação When do campo
				 NIL																,;	//	[09]  A   Lista de valores permitido do campo
				 .F.																,;	//	[10]  L   Indica se o campo tem preenchimento obrigatório
				 NIL																,;	//	[11]  B   Code-block de inicializacao do campo
				 NIL																,;	//	[12]  L   Indica se trata-se de um campo chave
				 NIL																,;	//	[13]  L   Indica se o campo pode receber valor em uma operação de update.
				 .F.																)	// 	[14]  L   Indica se o campo é virtual
				 		 
//-- Campo Doc. de Compra
oStruDBH:AddField(STR0010															,;	// 	[01]  C   Titulo do campo  - Doc. de Compra//"Doc. de Compra"
				 STR0011															,;	// 	[02]  C   ToolTip do campo - Doc. de Compra//"Doc. de Compra"
				 "DBH_DOCOMP"														,;	// 	[03]  C   Id do Field
				 "C"																,;	// 	[04]  C   Tipo do campo
				 1																	,;	// 	[05]  N   Tamanho do campo
				 0																	,;	// 	[06]  N   Decimal do campo
				 FwBuildFeature( STRUCT_FEATURE_VALID,"Pertence('12') .And. A182VldDoc()")	,;	// 	[07]  B   Code-block de validação do campo
				 NIL																,;	// 	[08]  B   Code-block de validação When do campo
				 {STR0012,STR0013}													,;	//	[09]  A   Lista de valores permitido do campo//"1=Solicitação de Compra"//"2=Pedido de Compra"
				 .F.																,;	//	[10]  L   Indica se o campo tem preenchimento obrigatório
				 FwBuildFeature( STRUCT_FEATURE_INIPAD, "'1'" )			  			,;	//	[11]  B   Code-block de inicializacao do campo
				 NIL																,;	//	[12]  L   Indica se trata-se de um campo chave
				 NIL																,;	//	[13]  L   Indica se o campo pode receber valor em uma operação de update.
				 .F.																)	// 	[14]  L   Indica se o campo é virtual

//-- Campo Fornecedor
oStruDBH:AddField(STR0014							  								,;	// 	[01]  C   Titulo do campo  - Doc. de Compra//"Fornecedor"
				 STR0015															,;	// 	[02]  C   ToolTip do campo - Doc. de Compra//"Código do Fornecedor"
				 "DBH_FORNEC"														,;	// 	[03]  C   Id do Field
				 "C"																,;	// 	[04]  C   Tipo do campo
				 TamSX3("A2_COD")[1]												,;	// 	[05]  N   Tamanho do campo
				 0																	,;	// 	[06]  N   Decimal do campo
				 {|| A182VldSA2() }	  												,;	// 	[07]  B   Code-block de validação do campo
				 NIL																,;	// 	[08]  B   Code-block de validação When do campo
				 NIL																,;	//	[09]  A   Lista de valores permitido do campo
				 .F.																,;	//	[10]  L   Indica se o campo tem preenchimento obrigatório
				 NIL																,;	//	[11]  B   Code-block de inicializacao do campo
				 NIL																,;	//	[12]  L   Indica se trata-se de um campo chave
				 NIL																,;	//	[13]  L   Indica se o campo pode receber valor em uma operação de update.
				 .F.																)	// 	[14]  L   Indica se o campo é virtual
			 
//-- Campo Loja
oStruDBH:AddField(STR0016												  			,;	// 	[01]  C   Titulo do campo  - Doc. de Compra//"Loja"
				 STR0017															,;	// 	[02]  C   ToolTip do campo - Doc. de Compra//"Loja do Fornecedor"
				 "DBH_LOJA"												   			,;	// 	[03]  C   Id do Field
				 "C"																,;	// 	[04]  C   Tipo do campo
				 TamSX3("A2_LOJA")[1]									  			,;	// 	[05]  N   Tamanho do campo
				 0																	,;	// 	[06]  N   Decimal do campo
				 {|| A182VldSA2() }													,;	// 	[07]  B   Code-block de validação do campo
				 NIL																,;	// 	[08]  B   Code-block de validação When do campo
				 NIL																,;	//	[09]  A   Lista de valores permitido do campo
				 .F.																,;	//	[10]  L   Indica se o campo tem preenchimento obrigatório
				 NIL																,;	//	[11]  B   Code-block de inicializacao do campo
				 NIL																,;	//	[12]  L   Indica se trata-se de um campo chave
				 NIL																,;	//	[13]  L   Indica se o campo pode receber valor em uma operação de update.
				 .F.																)	// 	[14]  L   Indica se o campo é virtual
				 
//-- Campo Comprar na
oStruDBH:AddField(STR0018															,;	// 	[01]  C   Titulo do campo  - Comprar na//"Comprar na"
				 STR0019															,;	// 	[02]  C   ToolTip do campo - Comprar na//"Comprar na"
				 "DBH_COMPNA"														,;	// 	[03]  C   Id do Field
				 "C"																,;	// 	[04]  C   Tipo do campo
				 1																	,;	// 	[05]  N   Tamanho do campo
				 0																	,;	// 	[06]  N   Decimal do campo
				 FwBuildFeature( STRUCT_FEATURE_VALID,"Pertence('12')")	 			,;	// 	[07]  B   Code-block de validação do campo
				 NIL																,;	// 	[08]  B   Code-block de validação When do campo
				 {STR0020,STR0021}										  			,;	//	[09]  A   Lista de valores permitido do campo//"1=Distribuidora"//"2=Abastecida"
				 .F.																,;	//	[10]  L   Indica se o campo tem preenchimento obrigatório
				 FwBuildFeature( STRUCT_FEATURE_INIPAD, "'1'" )						,;	//	[11]  B   Code-block de inicializacao do campo
				 NIL																,;	//	[12]  L   Indica se trata-se de um campo chave
				 NIL																,;	//	[13]  L   Indica se o campo pode receber valor em uma operação de update.
				 .F.																)	// 	[14]  L   Indica se o campo é virtual

//-- Campo Entregar na
oStruDBH:AddField(STR0022												 			,;	// 	[01]  C   Titulo do campo  - Entregar na//"Entregar na"
				 STR0023															,;	// 	[02]  C   ToolTip do campo - Entregar na//"Entregar na"
				 "DBH_ENTRNA"														,;	// 	[03]  C   Id do Field
				 "C"																,;	// 	[04]  C   Tipo do campo
				 1																	,;	// 	[05]  N   Tamanho do campo
				 0																	,;	// 	[06]  N   Decimal do campo
				 FwBuildFeature( STRUCT_FEATURE_VALID,"Pertence('12')")	  			,;	// 	[07]  B   Code-block de validação do campo
				 NIL																,;	// 	[08]  B   Code-block de validação When do campo
				 {STR0024,STR0025}										  			,;	//	[09]  A   Lista de valores permitido do campo//"1=Distribuidora"//"2=Abastecida"
				 .F.																,;	//	[10]  L   Indica se o campo tem preenchimento obrigatório
				 FwBuildFeature( STRUCT_FEATURE_INIPAD, "'1'" )			  			,;	//	[11]  B   Code-block de inicializacao do campo
				 NIL																,;	//	[12]  L   Indica se trata-se de um campo chave
				 NIL																,;	//	[13]  L   Indica se o campo pode receber valor em uma operação de update.
				 .F.																)	// 	[14]  L   Indica se o campo é virtual

//------------------------------------------------------
//		Adiciona o componente de formulario no model 
//     Nao sera usado, mas eh obrigatorio ter
//------------------------------------------------------	
oModel:AddFields("DBJMASTER",/*cOwner*/ ,oStruCab) //Cabecalho
oModel:AddGrid  ("DBIDETAILS","DBJMASTER" ,oStruDBI ,/*Pre-Validacao*/,/*Pos-Validacao*/,/*bPre*/,/*bPost*/,{ |oModel| A182LdDBI(oModel) }) //-- Itens DBI
oModel:AddGrid  ("DBHDETAILS","DBIDETAILS",oStruDBH ,{ |oModelGrid, nLine, cAction, cField| MTA182LPRE(oModelGrid,nLine,cAction,cField,"DBHDETAILS")},/*Pos-Validacao*/,/*bPre*/,/*bPost*/,{ |oModel| A182LdDBH(oModel) }) //-- Itens DBH
oModel:AddGrid  ("CPMDETAILS","DBHDETAILS",oStruCPM) //Itens da CPM

//--------------------------------------
//		Configura o model
//--------------------------------------
oModel:SetPrimaryKey( {} ) //Obrigatorio setar a chave primaria (mesmo que vazia)
oModel:SetRelation("DBIDETAILS",{{"DBI_FILIAL",'xFilial("DBI")'},{"DBI_SUGEST","DBJ_SUGEST"}},DBI->(IndexKey(1)))
oModel:SetRelation("DBHDETAILS",{{"DBH_FILIAL",'xFilial("DBH")'},{"DBH_SUGEST","DBI_SUGEST"}},DBH->(IndexKey(2)))
oModel:SetRelation("CPMDETAILS",{{"CPM_SUGEST","DBH_SUGEST"},{"CPM_FILABA","DBH_FILABA"},{"CPM_PRODUT","DBI_PRODUT"}},CPM->(IndexKey(1)))	

oModel:GetModel("DBHDETAILS" ):SetDescription(STR0026) //"Abastecidas"
oModel:GetModel("DBIDETAILS" ):SetDescription(STR0027) //"Produtos"

//Seta permissoes somente para nao incluir linhas
oModel:GetModel( "DBHDETAILS" ):SetNoInsertLine( .T. )
oModel:GetModel( "DBIDETAILS" ):SetNoInsertLine( .T. )


//Seta permissoes somente para nao deletar linhas
oModel:GetModel( "DBHDETAILS" ):SetNoDeleteLine( .T. )
oModel:GetModel( "DBIDETAILS" ):SetNoDeleteLine( .T. )
oModel:GetModel("CPMDETAILS" ):SetDescription(STR0059) //'Documentos')
oModel:GetModel( "CPMDETAILS" ):SetNoInsertLine( .T. )
oModel:GetModel( "CPMDETAILS" ):SetNoDeleteLine( .T. )
oModel:GetModel( "CPMDETAILS" ):SetNoUpdateLine( .T. )
oModel:GetModel( "CPMDETAILS" ):SetOptional( .T. )

//--------------------------------------
//		Validacao para nao permitir execucao de registros ja processados
//--------------------------------------
oModel:SetVldActivate( {|oModel| A182VLMod(oModel) } )
Return oModel 

//--------------------------------------------------------------------
/*/{Protheus.doc} ViewDef()
Definicao da View
@author Leonardo Quintania
@since 28/01/2013
@version 1.0
@return oView
/*/
//--------------------------------------------------------------------
Static Function ViewDef()  
Local oModel   	:= FWLoadModel( "MATA182" )	 //Carrega model definido
Local oStruCab 	:= FWFormStruct(2,"DBJ",{|cCampo| AllTrim(cCampo) $ "DBJ_FILDIS|DBJ_NFILDI|DBJ_SUGEST"}) //Estrutura Cabecalho 
Local oStruDBI 	:= FWFormStruct(2,"DBI",{|cCampo| AllTrim(cCampo) $ "DBI_PRODUT|DBI_DESCPR|DBI_CONSUM|DBI_SLDABA|DBI_NECALC|DBI_NECINF|DBI_SLDFIS|DBI_SLDDIS|DBI_SLDTRA|DBI_QTDCOM"})//Estrutura Itens DBI
Local oStruDBH 	:= FWFormStruct(2,"DBH",{|cCampo| AllTrim(cCampo) $ "DBH_FILABA|DBH_PRIORI|DBH_CONTOT|DBH_ABATOT|DBH_NECTOT"}) //Estrutura Itens DBH
Local oStruCPM 	:= FWFormStruct(2,"CPM",{|cCampo|  AllTrim(cCampo) $ "CPM_FILABA|CPM_TIPO|CPM_NUMDOC"}) //Estrutura da CPM 
 
Local oView	  	:= FWFormView():New()

//-- Campo Necessidade Informada
oStruDBH:AddField(	"DBH_NFILAB"												,;	// [01]  C   Nome do Campo
				"06"																,;	// [02]  C   Ordem
				"Nome" 															,;	// [03]  C   Titulo do campo
				"Nome"																,;	// [04]  C   Descricao do campo//"Necessidade Informada"
				NIL																	,;	// [05]  A   Array com Help
				"C"																	,;	// [06]  C   Tipo do campo
				"@!"																,;	// [07]  C   Picture
				NIL																	,;	// [08]  B   Bloco de Picture Var
				NIL																	,;	// [09]  C   Consulta F3
				.F.																	,;	// [10]  L   Indica se o campo é alteravel
				NIL																	,;	// [11]  C   Pasta do campo
				NIL																	,;	// [12]  C   Agrupamento do campo
				NIL																	,;	// [13]  A   Lista de valores permitido do campo (Combo)
				NIL																	,;	// [14]  N   Tamanho maximo da maior opção do combo
				NIL																	,;	// [15]  C   Inicializador de Browse
				.T.																	,;	// [16]  L   Indica se o campo é virtual
				NIL																	,;	// [17]  C   Picture Variavel
				NIL																	)	// [18]  L   Indica pulo de linha após o campo
			
//-- Campo Necessidade Informada
oStruDBH:AddField(	"DBH_NECINF"												,;	// [01]  C   Nome do Campo
				"25"																,;	// [02]  C   Ordem
				"Nec. Inf" 														,;	// [03]  C   Titulo do campo
				STR0028															,;	// [04]  C   Descricao do campo//"Necessidade Informada"
				NIL																	,;	// [05]  A   Array com Help
				"C"																	,;	// [06]  C   Tipo do campo
				"@E 99,999,999,999.99"											,;	// [07]  C   Picture
				NIL																	,;	// [08]  B   Bloco de Picture Var
				NIL																	,;	// [09]  C   Consulta F3
				.T.																	,;	// [10]  L   Indica se o campo é alteravel
				NIL																	,;	// [11]  C   Pasta do campo
				NIL																	,;	// [12]  C   Agrupamento do campo
				NIL																	,;	// [13]  A   Lista de valores permitido do campo (Combo)
				NIL																	,;	// [14]  N   Tamanho maximo da maior opção do combo
				NIL																	,;	// [15]  C   Inicializador de Browse
				.F.																	,;	// [16]  L   Indica se o campo é virtual
				NIL																	,;	// [17]  C   Picture Variavel
				NIL																	)	// [18]  L   Indica pulo de linha após o campo	

//-- Campo Saldo a Transferir
oStruDBH:AddField(	"DBH_SLDTRA"												,;	// [01]  C   Nome do Campo
				"27"																,;	// [02]  C   Ordem
				STR0031 															,;	// [03]  C   Titulo do campo//"Sld. Transf."
				STR0032															,;	// [04]  C   Descricao do campo//"Saldo a Transferir"
				NIL																	,;	// [05]  A   Array com Help
				"N"																	,;	// [06]  C   Tipo do campo
				"@E 99,999,999,999.99"											,;	// [07]  C   Picture
				NIL																	,;	// [08]  B   Bloco de Picture Var
				NIL																	,;	// [09]  C   Consulta F3
				.T.																	,;	// [10]  L   Indica se o campo é alteravel
				NIL																	,;	// [11]  C   Pasta do campo
				NIL																	,;	// [12]  C   Agrupamento do campo
				NIL																	,;	// [13]  A   Lista de valores permitido do campo (Combo)
				NIL																	,;	// [14]  N   Tamanho maximo da maior opção do combo
				NIL																	,;	// [15]  C   Inicializador de Browse
				.F.																	,;	// [16]  L   Indica se o campo é virtual
				NIL																	,;	// [17]  C   Picture Variavel
				NIL																	)	// [18]  L   Indica pulo de linha após o campo
					
//-- Campo Quantidade Comprar
oStruDBH:AddField(	"DBH_QTDCOM"												,;	// [01]  C   Nome do Campo
				"28"																,;	// [02]  C   Ordem
				STR0033 															,;	// [03]  C   Titulo do campo//"Qtd. Comprar"
				STR0034															,;	// [04]  C   Descricao do campo//"Quantidade a Comprar"
				NIL																	,;	// [05]  A   Array com Help
				"N"																	,;	// [06]  C   Tipo do campo
				"@E 99,999,999,999.99"											,;	// [07]  C   Picture
				NIL																	,;	// [08]  B   Bloco de Picture Var
				NIL																	,;	// [09]  C   Consulta F3
				.F.																	,;	// [10]  L   Indica se o campo é alteravel
				NIL																	,;	// [11]  C   Pasta do campo
				NIL																	,;	// [12]  C   Agrupamento do campo
				NIL																	,;	// [13]  A   Lista de valores permitido do campo (Combo)
				NIL																	,;	// [14]  N   Tamanho maximo da maior opção do combo
				NIL																	,;	// [15]  C   Inicializador de Browse
				.F.																	,;	// [16]  L   Indica se o campo é virtual
				NIL																	,;	// [17]  C   Picture Variavel
				NIL																	)	// [18]  L   Indica pulo de linha após o campo
				
//-- Campo Doc. de Compra
oStruDBH:AddField(	"DBH_DOCOMP"												,;	// [01]  C   Nome do Campo
				"29"																,;	// [02]  C   Ordem
				STR0035 															,;	// [03]  C   Titulo do campo//"Doc. de Compra"
				STR0036															,;	// [04]  C   Descricao do campo//"Doc. de Compra"
				NIL																	,;	// [05]  A   Array com Help
				"C"																	,;	// [06]  C   Tipo do campo
				""																	,;	// [07]  C   Picture
				NIL																	,;	// [08]  B   Bloco de Picture Var
				NIL																	,;	// [09]  C   Consulta F3
				.T.																	,;	// [10]  L   Indica se o campo é alteravel
				NIL																	,;	// [11]  C   Pasta do campo
				NIL																	,;	// [12]  C   Agrupamento do campo
				{STR0037,STR0038}													,;	// [13]  A   Lista de valores permitido do campo (Combo)//"1=Solicitação de Compra"//"2=Pedido de Compra"
				NIL																	,;	// [14]  N   Tamanho maximo da maior opção do combo
				NIL																	,;	// [15]  C   Inicializador de Browse
				.F.																	,;	// [16]  L   Indica se o campo é virtual
				NIL																	,;	// [17]  C   Picture Variavel
				NIL																	)	// [18]  L   Indica pulo de linha após o campo

//-- Campo Fornecedor
oStruDBH:AddField(	"DBH_FORNEC"												,;	// [01]  C   Nome do Campo
				"30"																,;	// [02]  C   Ordem
				STR0039 															,;	// [03]  C   Titulo do campo//"Fornecedor"
				STR0040															,;	// [04]  C   Descricao do campo//"Código do Fornecedor"
				NIL																	,;	// [05]  A   Array com Help
				"C"																	,;	// [06]  C   Tipo do campo
				""																	,;	// [07]  C   Picture
				NIL																	,;	// [08]  B   Bloco de Picture Var
				NIL																	,;	// [09]  C   Consulta F3
				.T.																	,;	// [10]  L   Indica se o campo é alteravel
				NIL																	,;	// [11]  C   Pasta do campo
				NIL																	,;	// [12]  C   Agrupamento do campo
				NIL																	,;	// [13]  A   Lista de valores permitido do campo (Combo)
				NIL																	,;	// [14]  N   Tamanho maximo da maior opção do combo
				NIL																	,;	// [15]  C   Inicializador de Browse
				.F.																	,;	// [16]  L   Indica se o campo é virtual
				NIL																	,;	// [17]  C   Picture Variavel
				NIL																	)	// [18]  L   Indica pulo de linha após o campo	

//-- Campo Loja
oStruDBH:AddField(	"DBH_LOJA"													,;	// [01]  C   Nome do Campo
				"31"																,;	// [02]  C   Ordem
				STR0041 															,;	// [03]  C   Titulo do campo//"Loja"
				STR0042															,;	// [04]  C   Descricao do campo//"Loja do Fornecedor"
				NIL																	,;	// [05]  A   Array com Help
				"C"																	,;	// [06]  C   Tipo do campo
				""																	,;	// [07]  C   Picture
				NIL																	,;	// [08]  B   Bloco de Picture Var
				NIL																	,;	// [09]  C   Consulta F3
				.T.																	,;	// [10]  L   Indica se o campo é alteravel
				NIL																	,;	// [11]  C   Pasta do campo
				NIL																	,;	// [12]  C   Agrupamento do campo
				NIL																	,;	// [13]  A   Lista de valores permitido do campo (Combo)
				NIL																	,;	// [14]  N   Tamanho maximo da maior opção do combo
				NIL																	,;	// [15]  C   Inicializador de Browse
				.F.																	,;	// [16]  L   Indica se o campo é virtual
				NIL																	,;	// [17]  C   Picture Variavel
				NIL																	)	// [18]  L   Indica pulo de linha após o campo	
								
//-- Campo Comprar na
oStruDBH:AddField(	"DBH_COMPNA"												,;	// [01]  C   Nome do Campo
				"32"																,;	// [02]  C   Ordem
				STR0043 															,;	// [03]  C   Titulo do campo//"Comprar na"
				STR0044															,;	// [04]  C   Descricao do campo//"Comprar na"
				NIL																	,;	// [05]  A   Array com Help
				"C"																	,;	// [06]  C   Tipo do campo
				""																	,;	// [07]  C   Picture
				NIL																	,;	// [08]  B   Bloco de Picture Var
				NIL																	,;	// [09]  C   Consulta F3
				.T.																	,;	// [10]  L   Indica se o campo é alteravel
				NIL																	,;	// [11]  C   Pasta do campo
				NIL																	,;	// [12]  C   Agrupamento do campo
				{STR0045,STR0046}													,;	// [13]  A   Lista de valores permitido do campo (Combo)//"1=Distribuidora"//"2=Abastecida"
				NIL																	,;	// [14]  N   Tamanho maximo da maior opção do combo
				NIL																	,;	// [15]  C   Inicializador de Browse
				.F.																	,;	// [16]  L   Indica se o campo é virtual
				NIL																	,;	// [17]  C   Picture Variavel
				NIL																	)	// [18]  L   Indica pulo de linha após o campo	

//-- Campo Entregar na
oStruDBH:AddField(	"DBH_ENTRNA"												,;	// [01]  C   Nome do Campo
				"33"																,;	// [02]  C   Ordem
				STR0047 															,;	// [03]  C   Titulo do campo//"Entregar na"
				STR0048															,;	// [04]  C   Descricao do campo//"Entregar na"
				NIL																	,;	// [05]  A   Array com Help
				"C"																	,;	// [06]  C   Tipo do campo
				""																	,;	// [07]  C   Picture
				NIL																	,;	// [08]  B   Bloco de Picture Var
				NIL																	,;	// [09]  C   Consulta F3
				.T.																	,;	// [10]  L   Indica se o campo é alteravel
				NIL																	,;	// [11]  C   Pasta do campo
				NIL																	,;	// [12]  C   Agrupamento do campo
				{STR0049,STR0050}													,;	// [13]  A   Lista de valores permitido do campo (Combo)//"1=Distribuidora"//"2=Abastecida"
				NIL																	,;	// [14]  N   Tamanho maximo da maior opção do combo
				NIL																	,;	// [15]  C   Inicializador de Browse
				.F.																	,;	// [16]  L   Indica se o campo é virtual
				NIL																	,;	// [17]  C   Picture Variavel
				NIL																	)	// [18]  L   Indica pulo de linha após o campo	
//--------------------------------------
//		Associa o View ao Model
//--------------------------------------
oView:SetModel(oModel)  //-- Define qual o modelo de dados será utilizado
oView:SetUseCursor(.F.) //-- Remove cursor de registros'

//--------------------------------------
//		Insere os componentes na view
//--------------------------------------
oView:AddField("DBJMASTER",oStruCab)   //Cabecalho da matriz de abastecimento
oView:AddGrid("DBIDETAILS",oStruDBI)	  //Itens da matriz de abastecimento
oView:AddGrid("DBHDETAILS",oStruDBH)   //Cabecalho da matriz de abastecimento
oView:AddGrid("CPMDETAILS",oStruCPM)	//Itens do documento

//--------------------------------------
//		Cria os Box's
//--------------------------------------
oView:CreateHorizontalBox("CABEC",12)
oView:CreateHorizontalBox("GRIDDBI",40)
oView:CreateHorizontalBox("GRIDDBH",24)
oView:CreateHorizontalBox("GRIDCPM",24)

//--------------------------------------
//		Associa os componentes
//--------------------------------------
oView:SetOwnerView("DBJMASTER" ,"CABEC")
oView:SetOwnerView("DBIDETAILS","GRIDDBI")
oView:SetOwnerView("DBHDETAILS","GRIDDBH")
oView:SetOwnerView("CPMDETAILS","GRIDCPM")
oView:EnableTitleView("DBIDETAILS",STR0051)//"Produtos"
oView:EnableTitleView("DBHDETAILS",STR0052)//"Abastecidas"
oView:EnableTitleView("CPMDETAILS",STR0059) //Documentos

oView:AddUserButton( STR0053 , "" , {|oView| A182ConSB1()} )//"Histórico do Produtos"
oView:AddUserButton( STR0055 , "" , {|oView| A182ConSA2()} )//"Histórico do Fornecedor"
oView:AddUserButton( STR0054 , "" , {|oView| A181Histor()})//"Parâmetros"
oView:AddUserButton( STR0056 , "" , {|oView| A182VisDoc()} )//"Visualiza Documento
//--------------------------------------
//		Permissoes dos campos
//--------------------------------------
oStruCab:SetProperty( "DBJ_FILDIS" , MVC_VIEW_CANCHANGE,.F.)

//--------------------------------------
//		Remove os campos de acordo com a Sugestao
//--------------------------------------

If DBJ->DBJ_TPSUG == "1"
	oStruDBH:RemoveField("DBH_SLDTRA")
	oStruDBI:RemoveField("DBI_SLDTRA")
Else
	oStruDBI:RemoveField("DBI_NECINF")
	oStruDBI:RemoveField("DBI_QTDCOM")
	oStruDBH:RemoveField("DBH_NECINF")
	oStruDBH:RemoveField("DBH_QTDCOM")
	oStruDBH:RemoveField("DBH_DOCOMP")
	oStruDBH:RemoveField("DBH_FORNEC")
	oStruDBH:RemoveField("DBH_LOJA")
	oStruDBH:RemoveField("DBH_COMPNA")
	oStruDBH:RemoveField("DBH_ENTRNA")
EndIf

Return oView

//--------------------------------------------------------------------
/*/{Protheus.doc} A182LdDBI()
Realiza o Load da tabela DBI (Produtos)
@author Leonardo Quintania
@since 28/01/2013
@version 1.0
@return aReturn
/*/
//--------------------------------------------------------------------
Function A182LdDBI(oModel)
Local aRet	 := {}
Local aLine	 := {}
Local cSugest:= FwFldGet("DBJ_SUGEST")

//-------------------------------------------------------------------
// Procura os produtos da tabela DBI
//-------------------------------------------------------------------
BeginSQL Alias "DBITMP"
   	SELECT DBI.DBI_SUGEST,DBI_PRODUT  , SUM(DBI.DBI_CONSUM) DBI_CONSUM ,
		 SUM(DBI.DBI_SLDABA) DBI_SLDABA, SUM(DBI.DBI_NECALC) DBI_NECALC ,
		 SUM(DBI.DBI_NECINF) DBI_NECINF, MIN(DBI.DBI_SLDDIS) DBI_SLDDIS ,
		 SUM(DBI.DBI_SLDTRA) DBI_SLDTRA, SUM(DBI.DBI_QTDCOM) DBI_QTDCOM				 
		 FROM %Table:DBI% DBI 
		 WHERE  DBI.DBI_SUGEST=%Exp:cSugest% AND DBI.%NotDel%
		 GROUP BY DBI.DBI_SUGEST,DBI.DBI_PRODUT
EndSQL

//-------------------------------------------------------------------
// Preenche as linhas do Grid com novos dados
//-------------------------------------------------------------------
While !DBITMP->(EOF()) 
	Aadd(aLine, DBITMP->DBI_PRODUT)
	Aadd(aLine, AllTrim(POSICIONE("SB1",1,XFILIAL("SB1")+DBITMP->DBI_PRODUT,"B1_DESC")))
	Aadd(aLine, DBITMP->DBI_CONSUM)
	Aadd(aLine, DBITMP->DBI_SLDABA)
	Aadd(aLine, DBITMP->DBI_NECALC)
	Aadd(aLine, DBITMP->DBI_NECINF)
	Aadd(aLine, A181IniSld(FwFldGet("DBJ_FILDIS"),DBITMP->DBI_PRODUT))
	Aadd(aLine, DBITMP->DBI_SLDDIS)
	Aadd(aLine, DBITMP->DBI_SLDTRA)
	Aadd(aLine, DBITMP->DBI_QTDCOM)
	Aadd(aRet,{ DBITMP->(Recno()),aLine})
	aLine	:= {}
	DBITMP->(dbSkip())
EndDo

DBITMP->(dbCloseArea())

Return aRet

//--------------------------------------------------------------------
/*/{Protheus.doc} A182LdDBH()
Realiza o Load da tabela DBH (Produtos)
@author Leonardo Quintania
@since 28/01/2013
@version 1.0
@return aReturn
/*/
//--------------------------------------------------------------------
Function A182LdDBH(oModel)
Local aArea	:= GetArea()
Local aRet		:= {}
Local aLine	:= {}
Local cSugest	:= FwFldGet("DBJ_SUGEST")
Local cProduto:= FwFldGet("DBI_PRODUT")

//-------------------------------------------------------------------
// Procura os produtos da tabela DBI
//-------------------------------------------------------------------
BeginSQL Alias "DBHTMP"
	SELECT *
	FROM %Table:DBH% DBH , %Table:DBI% DBI  
	WHERE DBH.DBH_SUGEST=%Exp:cSugest% AND DBH.%NotDel% AND
			DBH.DBH_SUGEST = DBI.DBI_SUGEST AND 
			DBH.DBH_FILABA = DBI.DBI_FILABA AND DBI.DBI_PRODUT =%Exp:cProduto% ORDER BY DBH.DBH_PRIORI
EndSQL

//-------------------------------------------------------------------
// Preenche as linhas do Grid com novos dados
//-------------------------------------------------------------------
While !DBHTMP->(EOF())
	Aadd(aLine, cSugest)
	Aadd(aLine, DBHTMP->DBH_FILABA)
	Aadd(aLine, DBHTMP->DBH_PRIORI)
	Aadd(aLine, DBHTMP->DBI_CONSUM)
	Aadd(aLine, DBHTMP->DBI_SLDABA)
	Aadd(aLine, DBHTMP->DBI_NECALC)
	Aadd(aLine, AllTrim(FwFilialName(,DBHTMP->DBH_FILABA)))
	Aadd(aLine, DBHTMP->DBI_PRODUT)
	Aadd(aLine, DBHTMP->DBI_NECINF)
	Aadd(aLine, DBHTMP->DBI_SLDTRA)
	Aadd(aLine, DBHTMP->DBI_QTDCOM)
	Aadd(aLine, DBHTMP->DBI_DOCOMP)
	Aadd(aLine, DBHTMP->DBI_FORNEC)
	Aadd(aLine, DBHTMP->DBI_LOJA)
	Aadd(aLine, DBHTMP->DBI_COMPNA)
	Aadd(aLine, DBHTMP->DBI_ENTRNA)	
	Aadd(aRet,{ DBHTMP->(Recno()),aLine})
	aLine	:= {}
	DBHTMP->(dbSkip())	
End

DBHTMP->(dbCloseArea())

RestArea(aArea)

Return aRet

//--------------------------------------------------------------------
/*/{Protheus.doc} A182VLMod()
Validacao do modelo para nao permitir alterar registros efetivados
@author Leonardo Quintania
@since 28/01/2013
@version 1.0
@return aReturn
/*/
//--------------------------------------------------------------------
Static Function A182VLMod(oModel)
Local lRet 		:= .T.
Local nOperation:= oModel:GetOperation()
Local aSaveLines:= FWSaveRows()

If DBJ->DBJ_FLAG # "1" 
	If nOperation == MODEL_OPERATION_UPDATE
		Help(" ",1,"A179ALTER")//"A sugestao esta efetivada, nao sera possível alteracao"
		lRet:= .F.
	ElseIf nOperation == MODEL_OPERATION_DELETE
		Help(" ",1,"A179DEL")//"A sugestao esta efetivada, nao sera possível exclusao"
		lRet:= .F.
	EndIf
EndIf

FWRestRows( aSaveLines )
Return lRet

//--------------------------------------------------------------------
/*/{Protheus.doc} A182CalQtd()
Efetua calculo do valor informado para gatilha a quantidade a comprar
@author Leonardo Quintania
@since 28/01/2013
@version 1.0
@return aReturn
/*/
//--------------------------------------------------------------------
Static Function A182CalQtd(oModel,cField,xConteud,nLine,xOldValue)
Local oMaster	:= oModel:GetModel()
Local oModelDBI	:= oMaster:GetModel("DBIDETAILS")
Local nSaldo	:= oModelDBI:GetValue("DBI_SLDFIS")
Local nI		:= 0
Local aSaveLines:= FWSaveRows(oMaster)
Local lRet		:= .T.

//-------------------------------------------------------------------
// Recalcula saldo da distribuidora com base na prioridade de abastecimento (Itens)
//-------------------------------------------------------------------
For nI:= 1 To oModel:GetQtdLine()
	oModel:GoLine( nI )	
	oModel:LoadValue("DBH_QTDCOM",Max(NoRound(oModel:GetValue("DBH_NECINF") - nSaldo ,TamSX3("DBI_QTDCOM")[2]),0 ) )
	nSaldo := Max(nSaldo - oModel:GetValue("DBH_NECINF"),0)
Next nI
//-------------------------------------------------------------------
// Recalcula total informado
//-------------------------------------------------------------------
oModelDBI:LoadValue("DBI_NECINF",(oModelDBI:GetValue("DBI_NECINF") - xOldValue) + xConteud )
//-------------------------------------------------------------------
// Recalcula quantidade a comprar da tabela DBI (Cabecalho)
//-------------------------------------------------------------------	
oModelDBI:LoadValue("DBI_QTDCOM",Max(NoRound(xConteud - oModelDBI:GetValue("DBI_SLDFIS") ,TamSX3("DBI_SLDFIS")[2]),0 ) )
//-------------------------------------------------------------------
// Recalcula saldo a distribuir tabela DBI (Cabecalho)
//-------------------------------------------------------------------	
oModelDBI:LoadValue("DBI_SLDDIS",Max(NoRound(oModelDBI:GetValue("DBI_SLDFIS") - oModelDBI:GetValue("DBI_NECINF") ,TamSX3("DBI_SLDFIS")[2]),0 ) )	

oModelDBI:GoLine( 1 )
FWRestRows( aSaveLines )

Return lRet
                    
//--------------------------------------------------------------------
/*/{Protheus.doc} A182CalNec()
Efetua calculo de distribuicao de saldo entre as filiais abastecidas
@author Leonardo Quintania
@since 28/01/2013
@version 1.0
@return aReturn
/*/
//--------------------------------------------------------------------
Function A182CalNec(oModel,cField,xConteud,nLine,xOldValue)
Local oMaster	:= oModel:GetModel()
Local oModelDBH	:= oMaster:GetModel("DBHDETAILS")
Local aSaveLines:= FWSaveRows(oMaster)
Local nSaldo	:= oModel:GetValue("DBI_SLDFIS")
Local nTotNecInf		:= 0
Local nTotNecCal		:= 0
Local lRet		:= .T.
Local nPercent	:= 0
Local nValPerc	:= 0
Local nI		:= 0

If DBJ->DBJ_TPAGLU # "1"
	//-------------------------------------------------------------------
	// Soma o valor de todas as colunas DBH_NECINF e DBH_NECTOT
	//-------------------------------------------------------------------	
	For nI:= 1 To oModelDBH:GetQtdLine()
		oModelDBH:GoLine( nI )	
		nTotNecInf += oModelDBH:GetValue("DBH_NECINF")
		nTotNecCal += oModelDBH:GetValue("DBH_NECTOT")
	Next nI
	
	For nI:= 1 To oModelDBH:GetQtdLine()
		oModelDBH:GoLine( nI )
		If !Empty(nTotNecInf)
			nPercent := Round(oModelDBH:GetValue("DBH_NECINF") / xOldValue,2) 
			nValPerc := nPercent * xConteud
		ElseIf !Empty(nTotNecCal)
			nPercent := Round(oModelDBH:GetValue("DBH_NECTOT")/oModel:GetValue("DBI_NECALC"),2)
			nValPerc := nPercent * xConteud
		Else
			nValPerc := xConteud / oModelDBH:GetQtdLine()
		EndIf 		
		oModelDBH:LoadValue("DBH_NECINF",nValPerc)	
		oModelDBH:LoadValue("DBH_QTDCOM",Max(NoRound(oModelDBH:GetValue("DBH_NECINF") - nSaldo ,TamSX3("DBI_QTDCOM")[2]),0 ) )	
		nSaldo := Max(nSaldo - nValPerc,0)
	Next nI 
	oModelDBH:GoLine( 1 )
	//-------------------------------------------------------------------
	// Recalcula saldo a distribuir tabela DBI (Cabecalho)
	//-------------------------------------------------------------------	
	oModel:LoadValue("DBI_SLDDIS",Max(NoRound(oModel:GetValue("DBI_SLDFIS") - xConteud ,TamSX3("DBI_SLDFIS")[2]),0 ) )
	//-------------------------------------------------------------------
	// Recalcula quantidade a comprar da tabela DBI (Cabecalho)
	//-------------------------------------------------------------------	
	oModel:LoadValue("DBI_QTDCOM",Max(NoRound(xConteud - oModel:GetValue("DBI_SLDFIS") ,TamSX3("DBI_SLDFIS")[2]),0 ) )	
EndIf

FWRestRows( aSaveLines )

Return lRet

//--------------------------------------------------------------------
/*/{Protheus.doc} A182CalSld()
Efetua calculo de saldo de distribuicao de saldo entre as filiais abastecidas
@author Leonardo Quintania
@since 28/01/2013
@version 1.0
@return aReturn
/*/
//--------------------------------------------------------------------
Function A182CalSld(oModel,cField,xConteud,nLine,xOldValue)
Local oMaster	:= oModel:GetModel()
Local oModelDBH	:= oMaster:GetModel("DBHDETAILS")
Local aSaveLines:= FWSaveRows(oMaster)
Local lRet		:= .T.
Local nTotTransf := 0
Local nTotNecCal := 0
Local nPercent	:= 0
Local nValPerc	:= 0
Local nI		:= 0

//-------------------------------------------------------------------
// Soma o valor de todas as colunas DBH_SLDTRA e DBH_NECTOT
//-------------------------------------------------------------------	
For nI:= 1 To oModelDBH:GetQtdLine()
	oModelDBH:GoLine( nI )	
	nTotTransf += oModelDBH:GetValue("DBH_SLDTRA")
	nTotNecCal += oModelDBH:GetValue("DBH_NECTOT")
Next nI

For nI:= 1 To oModelDBH:GetQtdLine()
	oModelDBH:GoLine( nI )	
	If !Empty(nTotTransf)
		nPercent := Round(oModelDBH:GetValue("DBH_SLDTRA") / xOldValue,2) 
		nValPerc := nPercent * xConteud
	ElseIf !Empty(nTotNecCal)
		nPercent := Round(oModelDBH:GetValue("DBH_NECTOT")/oModel:GetValue("DBI_NECALC"),2)
		nValPerc := nPercent * xConteud
	Else
		nValPerc := xConteud / oModelDBH:GetQtdLine()
	EndIf 
	oModelDBH:LoadValue("DBH_SLDTRA",nValPerc)
	
Next nI

oModelDBH:GoLine( 1 )
//-------------------------------------------------------------------
// Recalcula saldo a distribuir tabela DBI (Cabecalho)
//-------------------------------------------------------------------	
oModel:LoadValue("DBI_SLDDIS",Max(NoRound(oModel:GetValue("DBI_SLDFIS") - xConteud ,TamSX3("DBI_SLDFIS")[2]),0 ) )	

FWRestRows( aSaveLines )
Return lRet

//--------------------------------------------------------------------
/*/{Protheus.doc} A182VldSld()
Realiza criação de filtro da tabela SB1
@author Leonardo Quintania
@since 28/01/2013
@version 1.0
@return aReturn
/*/
//--------------------------------------------------------------------
Function A182VldSld(oModel,cField,xConteud,nLine,xOldValue)
Local oMaster		:= oModel:GetModel()
Local oModelDBH	:= oMaster:GetModel("DBHDETAILS")
Local oModelDBI	:= oMaster:GetModel("DBIDETAILS")
Local aSaveLines := FWSaveRows(oMaster)
Local nSldTot		:= 0
Local nSldDis		:= FwFldGet("DBI_SLDFIS")
Local nI			:= 0
Local lRet 		:= .T.

//-------------------------------------------------------------------
// Soma os valores de toda a grid
//-------------------------------------------------------------------
For nI:= 1 To oModelDBH:GetQtdLine()
	oModelDBH:GoLine( nI )
	nSldTot =  nSldTot + oModelDBH:GetValue("DBH_SLDTRA")	
Next nI 

If nSldTot > nSldDis
	Help(" ",1,"QTDEV")//Quantidade solicitada e maior que o saldo disponivel.
	lRet:= .F.
Else
	//-------------------------------------------------------------------
	// Recalcula Saldo Total
	//-------------------------------------------------------------------
	oModelDBI:LoadValue("DBI_SLDTRA",(oModelDBI:GetValue("DBI_SLDTRA") - xOldValue) + xConteud )	
	oModelDBI:LoadValue("DBI_SLDDIS",(oModelDBI:GetValue("DBI_SLDFIS") - nSldTot) )	
EndIf

FWRestRows( aSaveLines )

Return lRet

//--------------------------------------------------------------------
/*/{Protheus.doc} A182VldDoc()
Realiza criação de filtro da tabela SB1
@author Leonardo Quintania
@since 28/01/2013
@version 1.0
@return aReturn
/*/
//--------------------------------------------------------------------
Function A182VldDoc()
Local lRet 		:= .T.
Local cFornec	:= FwFldGet("DBH_FORNEC")   
Local cLoja		:= FwFldGet("DBH_LOJA")
Local cDocComp	:= FwFldGet("DBH_DOCOMP")
           
If cDocComp # "1" 
	If Empty(cFornec) .Or. Empty(cLoja) 
		Help(" ",1,"A179FILCOM")//"O fornecedor informado não está cadastrado na filial de compra.
		lRet := .F.		
	EndIf
EndIf

Return lRet       

//--------------------------------------------------------------------
/*/{Protheus.doc} A182VldSA2()
Realiza criação de filtro da tabela SB1
@author Leonardo Quintania
@since 28/01/2013
@version 1.0
@return aReturn
/*/
//--------------------------------------------------------------------
Function A182VldSA2()
Local lRet 		:= .T.
Local cFilDist	:= xFilial("SA2", FwFldGet("DBJ_FILDIS") )
Local cFilAba	:= xFilial("SA2", FwFldGet("DBH_FILABA") )
Local cFornec	:= FwFldGet("DBH_FORNEC")
Local cLoja		:= FwFldGet("DBH_LOJA")
Local cCompra	:= FwFldGet("DBH_COMPNA")

If ("DBH_FORNEC" $ ReadVar() .And. !Empty(cFornec)) .Or. !Empty(cFornec)
	If !SA2->(dbSeek(If(cCompra=="1",cFilDist,cFilAba)+cFornec+If(Empty(cLoja),"",cLoja)))
		Help(" ",1,"A179FORNEC")//"O fornecedor informado não está cadastrado na filial de compra.
		lRet:= .F.
	Else
		If Empty(SA2->A2_COND)
			Help(" ",1,"A179A2COND")//"Este fornecedor não possui condição de pagamento.      
			lRet:= .F.
		EndIf
	EndIf
EndIf

Return lRet

//--------------------------------------------------------------------
/*/{Protheus.doc} A182ConSA2()
Funcao que chama funcao do historico do fornecedor FINC030
@author Leonardo Quintania
@since 28/01/2013
@version 1.0
@return aReturn
/*/
//--------------------------------------------------------------------
Function A182ConSA2()
Local oModel	:= FWModelActive()
Local oModelDBH	:= oModel:GetModel("DBHDETAILS")
Local oModelDBI	:= oModel:GetModel("DBIDETAILS")
Local cFilAba	:= xFilial("SA2",oModelDBH:GetValue("DBH_FILABA"))
Local cFornec	:= oModelDBH:GetValue("DBH_FORNEC")
Local aSaveLines:= FWSaveRows()

If !Empty(cFornec)
	SA2->(dbSeek(cFilAba + cFornec))
	If Pergunte("FIC030",.T.)
		MsgRun(STR0012,STR0013,{|| Finc030("Fc030Con")})//"Aguarde..."//"Processando"
	EndIf
EndIf

FWRestRows( aSaveLines )
Return .T.

//--------------------------------------------------------------------
/*/{Protheus.doc} A182ConSB1()
Funcao que chama historico do produto MATC050
@author Leonardo Quintania
@since 28/01/2013
@version 1.0
@return aReturn
/*/
//--------------------------------------------------------------------
Function A182ConSB1()
Local oModel	:= FWModelActive()
Local oModelDBH	:= oModel:GetModel("DBHDETAILS")
Local oModelDBI	:= oModel:GetModel("DBIDETAILS")
Local cFilAba	:= xFilial("SB1",oModelDBH:GetValue("DBH_FILABA"))
Local cProduto	:= oModelDBI:GetValue("DBI_PRODUT")
Local aSaveLines:= FWSaveRows()

SB1->(dbSeek(cFilAba + cProduto))
If Pergunte("MTC050",.T.)
	MsgRun(STR0010,STR0011,{|| MC050Con()})//"Aguarde..."//"Processando"
EndIf

FWRestRows( aSaveLines )
Return .T.

//--------------------------------------------------------------------
/*/{Protheus.doc} A182Commit()
Realiza gravacao manual da tabela DBI
@author Leonardo Quintania
@since 28/01/2013
@version 1.0
@return aReturn
/*/
//--------------------------------------------------------------------
Static Function A182Commit(oModel)
Local oModelDBI	:= oModel:GetModel("DBIDETAILS")
Local oModelDBH	:= oModel:GetModel("DBHDETAILS")
Local nI			:= 0
Local nJ			:= 0
Local cSugest		:= oModelDBH:GetValue("DBH_SUGEST")

For nI:= 1 To oModelDBI:GetQtdLine()
	oModelDBI:GoLine( nI )
	For nJ:= 1 To oModelDBH:GetQtdLine()
		oModelDBH:GoLine( nJ )
		If oModelDBH:IsUpdated()
			If DBI->(dbSeek(xFilial("DBI")+cSugest+oModelDBH:GetValue("DBH_FILABA")+oModelDBI:GetValue("DBI_PRODUT")))
				RecLock("DBI",.F.)
				DBI->DBI_NECINF := oModelDBH:GetValue("DBH_NECINF")
				DBI->DBI_QTDCOM	:= oModelDBH:GetValue("DBH_QTDCOM")
				DBI->DBI_DOCOMP	:= oModelDBH:GetValue("DBH_DOCOMP")
				DBI->DBI_FORNEC	:= oModelDBH:GetValue("DBH_FORNEC")
				DBI->DBI_LOJA	:= oModelDBH:GetValue("DBH_LOJA")
				DBI->DBI_COMPNA	:= oModelDBH:GetValue("DBH_COMPNA")
				DBI->DBI_ENTRNA	:= oModelDBH:GetValue("DBH_ENTRNA")
				DBI->DBI_SLDTRA := oModelDBH:GetValue("DBH_SLDTRA")
				DBI->DBI_SLDDIS := oModelDBI:GetValue("DBI_SLDDIS") // Forca a atualização do campo calculado
				DBI->(MsUnlock())
			EndIf
		EndIf
	Next nJ	
Next nI

Return .T.         

//--------------------------------------------------------------------
/*/{Protheus.doc} A181VisDoc()
Visualiza os documento que foram gerados pelo Central de Compras
@author Rodrigo Toledo
@since 28/02/2013
@version 1.0
@return aReturn
/*/
//--------------------------------------------------------------------
Function A182VisDoc()
Local cProd		:= FwFldGet("DBI_PRODUT")
Local aArea		:= GetArea()
Local cFilDoc		:= IIf(FwFldGet("DBH_COMPNA") == "1",FwFldGet("DBJ_FILDIS"),FwFldGet("DBH_FILABA"))
Local cFilAba		:= FwFldGet("DBH_FILABA")
Local cSugest		:= FwFldGet("DBJ_SUGEST")
Local cTpSug 		:= ''
Local cDocCom		:= ''
Local cNumDoc		:= ''
Local cCpmTp		:= ''
Local cFilDocBkp	:= '' 

// Foi necessario criar essas variaveis para que fosse possivel usar a funcao padrao do sistema A120Pedido()
Private aRotina   	:= {}
Private INCLUI      := .F.
Private ALTERA      := .F.
Private nTipoPed    := 1  
Private cCadastro   := STR0057  
Private l120Auto    := .F.  

//--Monta o aRotina para compatibilizacao
AAdd( aRotina, { '' , '' , 0, 1 } )
AAdd( aRotina, { '' , '' , 0, 2 } )
AAdd( aRotina, { '' , '' , 0, 3 } )
AAdd( aRotina, { '' , '' , 0, 4 } )
AAdd( aRotina, { '' , '' , 0, 5 } )

cNumDoc := FwFldGet("CPM_NUMDOC")
cCpmTp	 := FwFldGet("CPM_TIPO")
If  Empty(cNumDoc)
	DBI->(dbSetOrder(1)) //	DBI_FILIAL+DBI_SUGEST+DBI_FILABA+DBI_PRODUT
	If	DBI->(dbSeek(xFilial("DBI")+cSugest+cFilAba+cProd))
		If !Empty(DBI->(DBI_NUMDOC))
			MsgInfo(STR0060) //Rodar compatibilizador
		Else
			MsgInfo(STR0058)	//Não existe documento gerado para esse produto.
		EndIf
	EndIf
Else
	cFilDocBkp:= cFilDoc
	A179AltFil(cFilDoc)
	If cCpmTp == '1' //--Visualizacao da Solicitacao de Compras
		If SC1->(DbSeek(xFilial("SC1")+cNumDoc))
			A110Visual	("SC1",SC1->(Recno()),2)
		EndIf
	ElseIf cCpmTp $ '23' //--Visualizacao do Pedido de Compra ou Autorização de Entrega
		If SC7->(DbSeek(xFilial("SC7")+cNumDoc))
			A120Pedido("SC7",SC7->( Recno()),2)
		EndIf
	ElseIf cCpmTp $ '4'  //--Visualizacao do Pedido de Vendas
		If SC5->(DbSeek( xFilial("SC5") + cNumDoc))
			A410Visual	("SC5",SC5->(Recno()),2)
		EndIf
	Else //--Visualizacao da Medição de Contrato
		dbSelectArea("CND")
		dbSetOrder(4)
		If CND->(dBSeek(xFilial("CND")+cNumDoc))
			CN130Manut("CND",CND->( Recno() ),2)
		Endif
	EndIf
	A179AltFil(cFilDocBkp)
EndIf
	
RestArea(aArea)
Return .T.


//-------------------------------------------------------------------
/*/{Protheus.doc} MTA182LPRE
Funcao para pre-validacao da linha do modelo.

@author rd.santos
@since 24/03/2020
@version 1.0
@param	oModelGrid	- Modelo DBH
		nLinha		- Linha que esta sendo alterada
		cAcao		- Acao que esta sendo executada
		cCampo		- Campo que esta sendo alterado
@return lRet 
/*/
//-------------------------------------------------------------------
Function MTA182LPRE(oModelGrid,nLinha,cAcao,cCampo,cModel)

Local lRet 		 := .T.
Local oModel 	 := oModelGrid:GetModel()
Local oModelDBH  := oModel:GetModel(cModel)
Local nOperation := oModel:GetOperation()
Local cSugest 	 := oModelDBH:GetValue("DBH_SUGEST")

If cAcao == "SETVALUE" .And. nOperation == MODEL_OPERATION_UPDATE .AND. Empty(cSugest)
	Help(" ",1,"A179ALT",,STR0063,; // 'Não há sugestão de produto para essa Filial Abastecida.'
	1, 0, NIL, NIL, NIL, NIL, NIL, {STR0064}) // "Altere uma sugestão de produto válida."
	
	lRet := .F.
EndIf

Return lRet
