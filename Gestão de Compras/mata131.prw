#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE "FWEVENTVIEWCONSTS.CH"
#INCLUDE 'FWLIBVERSION.CH' 
#INCLUDE "MATA130.CH"
#INCLUDE 'TOPCONN.ch'
 
//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Definição do modelo de Dados

@author alexandre.gimenez
@since 22/10/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oModel
Local lCotRatP := SuperGetMv("MV_COTRATP",.F.,.F.)
Local lSelFor  := SuperGetMv("MV_SELFOR",.F.,"N") == "S"
Local lIntGC   := SuperGetMv("MV_VEICULO",.F.,"N") == "S"
Local cEntidade:= IIF(lCotRatP,",C1_CC     ,C1_CONTA  ,C1_ITEMCTA,C1_CLVL   ","")
Local cVeiculos:= IIf(lIntGC,", C1_CODGRP , C1_CODITE ","")
Local oStruXXX := NIL
Local oStruSBM := FWFormStruct( 1, 'SBM', {|cCampo| cCampo $ "BM_GRUPO  ,BM_DESC   "} )
Local oStruSC1 := FWFormStruct( 1, 'SC1', {|cCampo| cCampo $ "C1_PRODUTO,C1_DESCRI  ,C1_QUANT  ,C1_DATPRF ,C1_OBS    ,C1_QTSEGUM"+cEntidade+cVeiculos })
Local oStruSC8 := FWFormStruct( 1, 'SC8')
Local oStruTMP := StructTMP(1)
Local aScs		 := {}
Local cNumCot  := ""
Local nSaveSX8 := 0
local nX		 := 0  

oStruXXX := FWFormModelStruct():New()
oStruXXX:AddTable("   ",{" "}," ")
oStruXXX:AddField( ;                                                  
                        AllTrim('') , ; 			// [01] C Titulo do campo
                        AllTrim('') , ; 			// [02] C ToolTip do campo
                        'XXX_X' , ;               // [03] C identificador (ID) do Field
                        'C' , ;                     // [04] C Tipo do campo
                        1 , ;                      // [05] N Tamanho do campo
                        0 , ;                       // [06] N Decimal do campo
                        NIL , ;                     // [07] B Code-block de validação do campo
                        NIL , ;                     // [08] B Code-block de validação When do campo
                        NIL , ;                     // [09] A Lista de valores permitido do campo
                        NIL , ;                     // [10] L Indica se o campo tem preenchimento obrigatório
                        Nil , ;  					// [11] B Code-block de inicializacao do campo
                        NIL , ;                     // [12] L Indica se trata de um campo chave
                        NIL , ;                     // [13] L Indica se o campo pode receber valor em uma operação de update.
                        .T. )                       // [14] L Indica se o campo é virtual

oStruSBM:AddField( ;                                                  
                        AllTrim('') , ; 			// [01] C Titulo do campo
                        AllTrim('') , ; 			// [02] C ToolTip do campo
                        'LEGENDA' , ;         // [03] C identificador (ID) do Field
                        'C' , ;                     // [04] C Tipo do campo
                        50 , ;                      // [05] N Tamanho do campo
                        0 , ;                       // [06] N Decimal do campo
                        NIL , ;                     // [07] B Code-block de validação do campo
                        NIL , ;                     // [08] B Code-block de validação When do campo
                        NIL , ;                     // [09] A Lista de valores permitido do campo
                        NIL , ;                     // [10] L Indica se o campo tem preenchimento obrigatório
                        { || "BR_VERDE" } , ;  		// [11] B Code-block de inicializacao do campo
                        NIL , ;                     // [12] L Indica se trata de um campo chave
                        NIL , ;                     // [13] L Indica se o campo pode receber valor em uma operação de update.
                        .T. )                       // [14] L Indica se o campo é virtual
                        
oStruSBM:SetProperty("BM_GRUPO",MODEL_FIELD_OBRIGAT,.F.)

oStruSC1:AddField( ;                                                  
                        AllTrim('') , ; 			// [01] C Titulo do campo
                        AllTrim('') , ; 			// [02] C ToolTip do campo
                        'LEGENDA' , ;         // [03] C identificador (ID) do Field
                        'C' , ;                     // [04] C Tipo do campo
                        50 , ;                      // [05] N Tamanho do campo
                        0 , ;                       // [06] N Decimal do campo
                        NIL , ;                     // [07] B Code-block de validação do campo
                        NIL , ;                     // [08] B Code-block de validação When do campo
                        NIL , ;                     // [09] A Lista de valores permitido do campo
                        NIL , ;                     // [10] L Indica se o campo tem preenchimento obrigatório
                        { || "BR_VERDE" } , ;  		// [11] B Code-block de inicializacao do campo
                        NIL , ;                     // [12] L Indica se trata de um campo chave
                        NIL , ;                     // [13] L Indica se o campo pode receber valor em uma operação de update.
                        .T. )                       // [14] L Indica se o campo é virtual

oStruSC1:AddField( ;                                                  
                        AllTrim('ITEMSC') , ; 			// [01] C Titulo do campo
                        AllTrim('') , ; 			// [02] C ToolTip do campo
                        'ITEMSC' , ;         // [03] C identificador (ID) do Field
                        'M' , ;                     // [04] C Tipo do campo
                        80 , ;                      // [05] N Tamanho do campo
                        0 , ;                       // [06] N Decimal do campo
                        NIL , ;                     // [07] B Code-block de validação do campo
                        NIL , ;                     // [08] B Code-block de validação When do campo
                        NIL , ;                     // [09] A Lista de valores permitido do campo
                        NIL , ;                     // [10] L Indica se o campo tem preenchimento obrigatório
                        NIL , ;  		// [11] B Code-block de inicializacao do campo
                        NIL , ;                     // [12] L Indica se trata de um campo chave
                        NIL , ;                     // [13] L Indica se o campo pode receber valor em uma operação de update.
                        .T. )                       // [14] L Indica se o campo é virtual                        

oStruSC1:AddField( ;                                                  
                        AllTrim('GRADE') , ; 			// [01] C Titulo do campo
                        AllTrim('') , ; 			// [02] C ToolTip do campo
                        'GRADE' , ;         // [03] C identificador (ID) do Field
                        'L' , ;                     // [04] C Tipo do campo
                         1, ;                      // [05] N Tamanho do campo
                        0 , ;                       // [06] N Decimal do campo
                        NIL , ;                     // [07] B Code-block de validação do campo
                        NIL , ;                     // [08] B Code-block de validação When do campo
                        NIL , ;                     // [09] A Lista de valores permitido do campo
                        NIL , ;                     // [10] L Indica se o campo tem preenchimento obrigatório
                        {|| .F.} , ;  		// [11] B Code-block de inicializacao do campo
                        NIL , ;                     // [12] L Indica se trata de um campo chave
                        NIL , ;                     // [13] L Indica se o campo pode receber valor em uma operação de update.
                        .T. )                       // [14] L Indica se o campo é virtual   
                        
                        
oStruSC8:AddField( ;                                                  
                        AllTrim(STR0100) , ; 			// [01] C Titulo do campo
                        AllTrim('') , ; 			// [02] C ToolTip do campo
                        'C8_CRITER' , ;         // [03] C identificador (ID) do Field
                        'C' , ;                     // [04] C Tipo do campo
                        40 , ;                      // [05] N Tamanho do campo
                        0 , ;                       // [06] N Decimal do campo
                        NIL , ;                     // [07] B Code-block de validação do campo
                        NIL , ;                     // [08] B Code-block de validação When do campo
                        NIL , ;                     // [09] A Lista de valores permitido do campo
                        NIL , ;                     // [10] L Indica se o campo tem preenchimento obrigatório
                        { || STR0072 } , ;  		// [11] B Code-block de inicializacao do campo
                        NIL , ;                     // [12] L Indica se trata de um campo chave
                        NIL , ;                     // [13] L Indica se o campo pode receber valor em uma operação de update.
                        .T. )                       // [14] L Indica se o campo é virtual                        

oStruSC8:AddField( ;                                                  
                        AllTrim(STR0101) , ; 			// [01] C Titulo do campo
                        AllTrim('') , ; 			// [02] C ToolTip do campo
                        'C8_ALIAS' , ;         // [03] C identificador (ID) do Field
                        'C' , ;                     // [04] C Tipo do campo
                        10 , ;                      // [05] N Tamanho do campo
                        0 , ;                       // [06] N Decimal do campo
                        NIL , ;                     // [07] B Code-block de validação do campo
                        NIL , ;                     // [08] B Code-block de validação When do campo
                        NIL , ;                     // [09] A Lista de valores permitido do campo
                        NIL , ;                     // [10] L Indica se o campo tem preenchimento obrigatório
                        Nil, ;  					// [11] B Code-block de inicializacao do campo
                        NIL , ;                     // [12] L Indica se trata de um campo chave
                        NIL , ;                     // [13] L Indica se o campo pode receber valor em uma operação de update.
                        .T. )                       // [14] L Indica se o campo é virtual                        
 oStruSC8:AddField( ;                                                  
                        AllTrim(STR0102) , ; 			// [01] C Titulo do campo
                        AllTrim('') , ; 			// [02] C ToolTip do campo
                        'C8_RECNO' , ;         // [03] C identificador (ID) do Field
                        'N' , ;                     // [04] C Tipo do campo
                        8, ;                      // [05] N Tamanho do campo
                        0 , ;                       // [06] N Decimal do campo
                        NIL , ;                     // [07] B Code-block de validação do campo
                        NIL , ;                     // [08] B Code-block de validação When do campo
                        NIL , ;                     // [09] A Lista de valores permitido do campo
                        NIL , ;                     // [10] L Indica se o campo tem preenchimento obrigatório
                        Nil, ;  					// [11] B Code-block de inicializacao do campo
                        NIL , ;                     // [12] L Indica se trata de um campo chave
                        NIL , ;                     // [13] L Indica se o campo pode receber valor em uma operação de update.
                        .T. )                       // [14] L Indica se o campo é virtual  
                                                
oModel := MPFormModel():New('MATA131',/*bPreValidacao*/,{|oModel| a131Posvld(oModel,aSCs,@cNumCot,lSelFor,,@nSaveSX8) }/*bPosValidacao*/, {|oModel|a131GrvMvc(oModel,aSCs,cNumCot,nSaveSX8)}/*bCommit*/, /*bCancel*/ )

oModel:AddFields( 'XXXMASTER',/*cOwner*/, oStruXXX, /*bPreValidacao*/, /*bPosValidacao*/, {|| {""}}/*bCarga*/ )
oModel:AddGrid( 'SBMDETAIL', 'XXXMASTER', oStruSBM, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )
oModel:AddGrid( 'SC1DETAIL', 'SBMDETAIL', oStruSC1, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )
oModel:AddGrid( 'SC8DETAIL', 'SC1DETAIL', oStruSC8, {|oModelGrid,  nLine,cAction,  cField|PreValSC8(oModelGrid, nLine, cAction, cField)}/*bPreValidacao*/, {|oModelGrid,  nLine,cAction,  cField|PosValSC8(oModelGrid, nLine, cAction, cField)}/*bPosValidacao*/, /*bCarga*/ )
oModel:AddGrid( 'TMPDETAIL', 'SC1DETAIL',oStruTMP)

oModel:GetModel("XXXMASTER"):SetOnlyQuery(.T.)
oModel:GetModel("SBMDETAIL"):SetOnlyQuery(.T.)
oModel:GetModel("SC1DETAIL"):SetOnlyQuery(.T.)
oModel:GetModel("TMPDETAIL"):SetOnlyQuery(.T.)

oModel:GetModel("SC8DETAIL"):SetMaxLine( GetNewPar("MV_COMLMAX", 99999) )

a131Bloq(oModel,.T.)


oModel:GetModel("SBMDETAIL"):SetOptional(.T.)
oModel:GetModel("SC1DETAIL"):SetOptional(.T.)
oModel:GetModel("SC8DETAIL"):SetOptional(.T.)
oModel:GetModel("TMPDETAIL"):SetOptional(.T.)

// Adiciona a descricao do Modelo de Dados
oModel:SetDescription( STR0054 ) //'Selecionar Fornecedores da Cotação'

// Adiciona a descricao do Componente do Modelo de Dados
oModel:GetModel( 'XXXMASTER' ):SetDescription( STR0054 )//'Selecionar Fornecedores da Cotação'
oModel:GetModel( 'SC8DETAIL' ):SetDescription( STR0054 + STR0077 )//'Selecionar Fornecedores da Cotação'
oModel:GetModel( 'SBMDETAIL' ):SetDescription( STR0117 ) // Grupo de produto
oModel:GetModel( 'SC1DETAIL' ):SetDescription( STR0120 ) // Solicitações de compra
oModel:GetModel( 'TMPDETAIL' ):SetDescription( STR0110 ) // Fornecedor Marketplace

oModel:SetPrimarykey({})
oModel:GetModel('SC8DETAIL'):SetUniqueLine( { 'C8_FORNECE','C8_LOJA','C8_FORNOME'} )

oModel:SetActivate({|oModel| a131Active(oModel)})

Return oModel


//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Definição do interface

@author alexandre.gimenez

@since 22/10/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oView
Local oModel   := FWLoadModel( 'MATA131' )
Local lCotRatP := SuperGetMv("MV_COTRATP",.F.,.F.)
Local lIntGC   := SuperGetMv("MV_VEICULO",.F.,"N") == "S"
Local cEntidade:= IIF(lCotRatP,",C1_CC     ,C1_CONTA  ,C1_ITEMCTA,C1_CLVL   ","")   
Local cVeiculos:= IIf(lIntGC,", C1_CODGRP , C1_CODITE ","")
Local oStruXXX := Nil
Local cCampoC8 := 'C8_FORNECE|C8_LOJA|C8_FORNOME|C8_FORMAIL|C8_OBS'
Local cMT131C8 := ' '
Local oStruSBM := FWFormStruct( 2, 'SBM', {|cCampo| cCampo $ "BM_GRUPO  ,BM_DESC   "} )
Local oStruSC1 := FWFormStruct( 2, 'SC1', {|cCampo| cCampo $ "ITEMSC,GRADE,C1_PRODUTO,C1_DESCRI  ,C1_QUANT  ,C1_DATPRF ,C1_OBS    "+cEntidade+cVeiculos })
Local oStruSC8


If ExistBlock("MT131C8")
    cMT131C8 := ExecBlock( "MT131C8", .F., .F.)
    cCampoC8 +=  IIF(VALTYPE(cMT131C8) == 'C',cMT131C8,'')
Endif

oStruSC8 := FWFormStruct( 2, 'SC8', {|cCampo| AllTrim(cCampo) $ cCampoC8})
 
oStruXXX := FWFormViewStruct():New()

oStruXXX:AddField( ;                        // Ord. Tipo Desc.
														'XXX_X'                       , ;      // [01]  C   Nome do Campo
														'1'                             , ;      // [02]  C   Ordem
														AllTrim( STR0103    )          , ;      // [03]  C   Titulo do campo
														AllTrim( STR0104 )       , ;      // [04]  C   Descricao do campo
														{ STR0105 } , ;      // [05]  A   Array com Help
														'C'                                , ;      // [06]  C   Tipo do campo
														'@!'                               , ;      // [07]  C   Picture
														NIL                                , ;      // [08]  B   Bloco de Picture Var
														''                                 , ;      // [09]  C   Consulta F3
														.T.                                , ;      // [10]  L   Indica se o campo é alteravel
														NIL                                , ;      // [11]  C   Pasta do campo
														NIL                                , ;      // [12]  C   Agrupamento do campo
														NIL                  , ;      // [13]  A   Lista de valores permitido do campo (Combo)
														NIL                                , ;      // [14]  N   Tamanho maximo da maior opção do combo
														NIL                                , ;      // [15]  C   Inicializador de Browse
														.T.                                , ;      // [16]  L   Indica se o campo é virtual
														NIL;                                //, ;      // [17]  C   Picture Variavel
														)        // [18]  L   Indica pulo de linha após o campo
														
oStruSBM:AddField( ;                                                            // Ord. Tipo Desc.
                                               'LEGENDA' , ;                    // [01] C Nome do Campo
                                               '00' , ;                         // [02] C Ordem
                                               AllTrim('') , ;				   	// [03] C Titulo do campo
                                               AllTrim( STR0106 ) , ;   	// [04] C Descrição do campo
                                               { STR0106 } , ;           // [05] A Array com Help
                                               'C' , ;                          // [06] C Tipo do campo
                                               '@BMP' , ;                       // [07] C Picture
                                               NIL , ;                          // [08] B Bloco de Picture Var
                                               '' , ;                           // [09] C Consulta F3
                                               .F. , ;                          // [10] L Indica se o campo é evitável
                                               NIL , ;                          // [11] C Pasta do campo
                                               NIL , ;                          // [12] C Agrupamento do campo
                                               NIL , ;                          // [13] A Lista de valores permitido do campo (Combo)
                                               NIL , ;                          // [14] N Tamanho Maximo da maior opção do combo
                                               NIL , ;                          // [15] C Inicializador de Browse
                                               .T. , ;                          // [16] L Indica se o campo é virtual
                                               NIL )                            // [17] C Picture Variável
														
														
oStruSC1:AddField( ;                                                            // Ord. Tipo Desc.
                                               'LEGENDA' , ;                    // [01] C Nome do Campo
                                               '00' , ;                         // [02] C Ordem
                                               AllTrim('') , ;				   	// [03] C Titulo do campo
                                               AllTrim( STR0106 ) , ;   	// [04] C Descrição do campo
                                               { STR0106 } , ;           // [05] A Array com Help
                                               'C' , ;                          // [06] C Tipo do campo
                                               '@BMP' , ;                       // [07] C Picture
                                               NIL , ;                          // [08] B Bloco de Picture Var
                                               '' , ;                           // [09] C Consulta F3
                                               .F. , ;                          // [10] L Indica se o campo é evitável
                                               NIL , ;                          // [11] C Pasta do campo
                                               NIL , ;                          // [12] C Agrupamento do campo
                                               NIL , ;                          // [13] A Lista de valores permitido do campo (Combo)
                                               NIL , ;                          // [14] N Tamanho Maximo da maior opção do combo
                                               NIL , ;                          // [15] C Inicializador de Browse
                                               .T. , ;                          // [16] L Indica se o campo é virtual
                                               NIL )                            // [17] C Picture Variável


oStruSC8:AddField( ;                                                            // Ord. Tipo Desc.
                                               'C8_CRITER' , ;                    // [01] C Nome do Campo
                                               '5' , ;                         // [02] C Ordem
                                               AllTrim(STR0100) , ;				   	// [03] C Titulo do campo
                                               AllTrim( STR0100 ) , ;   	// [04] C Descrição do campo
                                               { STR0100 } , ;           // [05] A Array com Help
                                               'C' , ;                          // [06] C Tipo do campo
                                               '@!' , ;                       // [07] C Picture
                                               NIL , ;                          // [08] B Bloco de Picture Var
                                               '' , ;                           // [09] C Consulta F3
                                               .F. , ;                          // [10] L Indica se o campo é evitável
                                               NIL , ;                          // [11] C Pasta do campo
                                               NIL , ;                          // [12] C Agrupamento do campo
                                               NIL , ;                          // [13] A Lista de valores permitido do campo (Combo)
                                               NIL , ;                          // [14] N Tamanho Maximo da maior opção do combo
                                               NIL , ;                          // [15] C Inicializador de Browse
                                               .T. , ;                          // [16] L Indica se o campo é virtual
                                               NIL )                            // [17] C Picture Variável


oView := FWFormView():New()
oView:SetModel(oModel)

oView:AddGrid('VIEW_SBM' , oStruSBM,'SBMDETAIL') 
oView:AddGrid('VIEW_SC1' , oStruSC1,'SC1DETAIL')
oView:AddGrid('VIEW_SC8' , oStruSC8,'SC8DETAIL')

oView:CreateHorizontalBox( 'TOP'	, 20 )
oView:CreateHorizontalBox( 'MIDDLE'	, 40 )
oView:CreateHorizontalBox( 'BOTTON'	, 40 )

oView:SetOwnerView('VIEW_SBM','TOP')
oView:SetOwnerView('VIEW_SC1','MIDDLE')

oView:SetOnlyView("VIEW_SC1", "MIDDLE")

oView:EnableTitleView('VIEW_SBM' , STR0055 ) //'Grupo de Materias' 
oView:EnableTitleView('VIEW_SC1' , STR0056 ) //'Produtos'
oView:EnableTitleView('VIEW_SC8' , STR0057 ) //'Fornecedores / Participantes'

oView:SetAfterViewActivate({|oModel| a131AtuLeg(oModel) , a131OpenV(oModel)})

oView:AddUserButton(STR0058, 'CLIPS', {|oModel|  a131Replic(oModel)})//Replicar Grupo
oView:AddUserButton(STR0121, 'CLIPS', {|oModel|  a131RepAll(oModel)})//Replicar p/ TODOS
oView:AddUserButton(STR0059, 'CLIPS', {|oModel|  a131HisForn(oModel)})//Histórico do Fornecedor
oView:AddUserButton(STR0060, 'CLIPS', {|oModel|  a131HisPro(oModel)})//Histórico do Produto

If A131VerInt()
	oView:AddUserButton(STR0078	, 'CLIPS', {|oModel|  a131CalCom(oModel)})//Portal de Compras
	oView:AddUserButton(STR0079 , 'CLIPS', {|oModel|  a131CalPer(oModel)})//Perfil do Fornecedor
	oView:AddUserButton(STR0080	, 'CLIPS', {|oModel|  a131CalBus(oModel)})//Buscar Fornecedor
EndIf

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} a131RepAll(oModel)
Rotina para replicar fornecedores participantes

@author rodrigo pontes
@since 31/10/2017
@version 1.0
/*/
//------------------------------------------------------------------

Static Function a131RepAll(oModel)

//-----------------------------
// Estrutura do Array a aDados
// [1] C8_FORNECE
// [2] C8_LOJA
// [3] C8_FORNOME
// [4] C8_FORMAIL
// [5] C8_OBS
//------------------------------ 
Local aDados		:= {}
Local lRet			:= .T. 
Local nY			:= 0
local nZ			:= 0
Local nW			:= 0
local nX			:= 0
Local nA			:= 0
Local nL1			:= oModel:GetModel("SBMDETAIL"):nLine
Local nL2			:= oModel:GetModel("SC1DETAIL"):nLine
Local nL3			:= oModel:GetModel("SC8DETAIL"):nLine
Local nAviso		:= 0
Local aBotoes		:= {STR0062,STR0063} //"Todos" * "Abortar"
Local cTexto		:= STR0122; //"Esta opção tem por objetivo replicar o(s) participante(s) deste produto para todos os produtos em todos os grupos"
						+CRLF+ STR0066; //"Todos - Replica todos particapantes;"
						+CRLF+ STR0067 //"Abortar - Aborta este procedimento;"

nAviso := Aviso(STR0123,cTexto,aBotoes, 3 )

If nAviso == 1 //Todos
	
	For nZ := 1 to oModel:GetModel("SC8DETAIL"):Length()
		oModel:GetModel("SC8DETAIL"):GoLine(nZ)
		//----------------------------------
		// Copia Informação do Participante
		//----------------------------------
		If !oModel:GetModel("SC8DETAIL"):IsDeleted() .And. ;
		(!Empty(oModel:GetModel("SC8DETAIL"):Getvalue("C8_FORNECE")) .Or. !Empty(oModel:GetModel("SC8DETAIL"):Getvalue("C8_FORNOME"))  )
		
			aAdd(aDados,{oModel:GetModel("SC8DETAIL"):Getvalue("C8_FORNECE"),;
							oModel:GetModel("SC8DETAIL"):Getvalue("C8_LOJA"),;
							oModel:GetModel("SC8DETAIL"):Getvalue("C8_FORNOME"),;
							oModel:GetModel("SC8DETAIL"):Getvalue("C8_FORMAIL"),;
							oModel:GetModel("SC8DETAIL"):Getvalue("C8_OBS"),; 
							oModel:GetModel("SC8DETAIL"):Getvalue("C8_VALIDA");							
							})
		EndIf
	Next nZ
	
	If Len(aDados) == 0
		Help("",1,"FORNDELETED2",,STR0108,4,1)
	Else	
		//----------------------------------
		// Limpa Participantes Atuais
		//----------------------------------
		For nW := 1 to oModel:GetModel("SBMDETAIL"):Length()
			
			//Posiciona Grupo
			oModel:GetModel("SBMDETAIL"):GoLine(nW)
			
			//Quantidade de Produtos
			nA := oModel:GetModel("SC1DETAIL"):GetQtdLine()
			
			For nY := 1 to nA
				
				//Limpa todos exceto o que deseja replicar
				If nY == nL2 .And. nW == nL1
					loop
				EndIf
				
				//Posiciona Produto
				oModel:GetModel("SC1DETAIL"):GoLine(nY)
				
				//Quantidade Fornecedores
				nX := oModel:GetModel("SC8DETAIL"):GetQtdLine()
				
				//Apaga Fornecedores
				For nZ := 1 To nX
					oModel:GetModel("SC8DETAIL"):GoLine(nZ)
					oModel:GetModel("SC8DETAIL"):DeleteLine(.T.,.T.)	
				Next nZ
				
				If oModel:GetModel("SC8DETAIL"):IsDeleted()
					oModel:GetModel("SC8DETAIL"):UnDeleteLine()
				EndIf
				
				//Cria linha em branco
				oModel:GetModel("SC8DETAIL"):LoadValue("C8_FORNECE",CriaVar("C8_FORNECE",.F.))
				oModel:GetModel("SC8DETAIL"):LoadValue("C8_LOJA",CriaVar("C8_LOJA",.F.))
				oModel:GetModel("SC8DETAIL"):LoadValue("C8_FORNOME",CriaVar("C8_FORNOME",.F.))
				oModel:GetModel("SC8DETAIL"):LoadValue("C8_FORMAIL",CriaVar("C8_FORMAIL",.F.))
				oModel:GetModel("SC8DETAIL"):LoadValue("C8_OBS",CriaVar("C8_OBS",.F.))
				oModel:GetModel("SC8DETAIL"):LoadValue("C8_CRITER",STR0072)	
			Next nY
		Next nW

		//----------------------------------
		// Inclui Participantes Salvos
		//----------------------------------
		For nW := 1 to oModel:GetModel("SBMDETAIL"):Length()
			
			//Posiciona Grupo
			oModel:GetModel("SBMDETAIL"):GoLine(nW)
			
			//Quantidade de Produtos
			nA := oModel:GetModel("SC1DETAIL"):GetQtdLine()
			
			For nY := 1 to nA
				If nY == nL2 .And. nW == nL1
					loop
				EndIf
				
				//Posiciona Produto
				oModel:GetModel("SC1DETAIL"):GoLine(nY)
				
				For nZ := 1 to Len(aDados)
					If nZ != 1
						oModel:GetModel("SC8DETAIL"):AddLine()
					EndIf	
					oModel:GetModel("SC8DETAIL"):SetValue("C8_FORNECE",aDados[nZ,1])
					oModel:GetModel("SC8DETAIL"):SetValue("C8_LOJA",aDados[nZ,2])
					oModel:GetModel("SC8DETAIL"):SetValue("C8_FORNOME",aDados[nZ,3])
					oModel:GetModel("SC8DETAIL"):SetValue("C8_FORMAIL",aDados[nZ,4])
					oModel:GetModel("SC8DETAIL"):SetValue("C8_OBS",aDados[nZ,5])	
					oModel:GetModel("SC8DETAIL"):SetValue("C8_CRITER",STR0076)
					oModel:GetModel("SC8DETAIL"):SetValue("C8_FILENT",SC1->C1_FILENT)
					oModel:GetModel("SC8DETAIL"):SetValue("C8_VALIDA",aDados[nZ,6])							
				Next nZ
			Next nY
		Next nW
	EndIf
Endif

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} a131Replic(oModel)
Rotina para replicar fornecedores participantes da licitação

@author alexandre.gimenez
@since 31/10/2013
@version 1.0
/*/
//------------------------------------------------------------------
Static Function a131Replic(oModel,lReplica)
//-----------------------------
// Estrutura do Array a aDados
// [1] C8_FORNECE
// [2] C8_LOJA
// [3] C8_FORNOME
// [4] C8_FORMAIL
// [5] C8_OBS
//------------------------------ 
Local aDados		:= {}    
Local lRet			:= .T. 
Local nY			:= 0
local nZ			:= 0
Local nW			:= 0
Local nL2			:= oModel:GetModel("SC1DETAIL"):nLine
Local nL3			:= oModel:GetModel("SC8DETAIL"):nLine
local nX			:= 0
Local nAviso		:= 0
Local aBotoes		:= {STR0061,STR0062,STR0063} //"Participante" * "Todos" * "Abortar"
Local cTexto		:= STR0064; //Esta opção tem por objetivo replicar o(s) participante(s) deste produto para todos os produtos do grupo:
						+CRLF+ STR0065 ; //"Participante - Replica o particapante posicionado;"
						+CRLF+ STR0066; //"Todos - Replica todos particapantes;"
						+CRLF+ STR0067; //"Abortar - Aborta este procedimento;"

Default lReplica	:= .F.
					
If !lReplica
	nAviso := Aviso(STR0068,cTexto,aBotoes, 3 ) //"Replicar Grupo"
EndIf

If nAviso == 1 
	//----------------------------------
	// Copia Informação do Participante
	//----------------------------------
	If oModel:GetModel("SC8DETAIL"):IsDeleted() .Or. ;
	( Empty(oModel:GetModel("SC8DETAIL"):Getvalue("C8_FORNECE"))  .And. ;
	  Empty(oModel:GetModel("SC8DETAIL"):Getvalue("C8_LOJA")) .And. ;
	  Empty(oModel:GetModel("SC8DETAIL"):Getvalue("C8_FORNOME"))  )
	  
		Help("",1,"FORNDELETED",,STR0107,4,1)
	Else	
		aAdd(aDados,{oModel:GetModel("SC8DETAIL"):Getvalue("C8_FORNECE"),;
						oModel:GetModel("SC8DETAIL"):Getvalue("C8_LOJA"),;
						oModel:GetModel("SC8DETAIL"):Getvalue("C8_FORNOME"),;
						oModel:GetModel("SC8DETAIL"):Getvalue("C8_FORMAIL"),;
						oModel:GetModel("SC8DETAIL"):Getvalue("C8_OBS"),; 
						oModel:GetModel("SC8DETAIL"):Getvalue("C8_VALIDA");							
						})
	
		For nY := 1 to oModel:GetModel("SC1DETAIL"):Length()
			oModel:GetModel("SC1DETAIL"):GoLine(nY)
			oModel:GetModel("SC8DETAIL"):GoLine(1)
			If nY == nL2  .And. MTFindMVC(oModel:GetModel("SC8DETAIL"),{{"C8_FORNECE",aDados[1,1]},{"C8_LOJA",aDados[1,2]},{"C8_FORNOME",aDados[1,3]}}) > 0
				Loop
			Else
				If !(Empty(oModel:GetModel("SC8DETAIL"):GetValue("C8_FORNECE"))) .Or. !(Empty(oModel:GetModel("SC8DETAIL"):Getvalue("C8_FORNOME")))
					oModel:GetModel("SC8DETAIL"):AddLine()
				EndIf
				oModel:GetModel("SC8DETAIL"):SetValue("C8_FORNECE",aDados[1,1])
				oModel:GetModel("SC8DETAIL"):SetValue("C8_LOJA",aDados[1,2])
				oModel:GetModel("SC8DETAIL"):SetValue("C8_FORNOME",aDados[1,3])
				oModel:GetModel("SC8DETAIL"):SetValue("C8_FORMAIL",aDados[1,4])
				oModel:GetModel("SC8DETAIL"):SetValue("C8_OBS",aDados[1,5])		
				oModel:GetModel("SC8DETAIL"):SetValue("C8_CRITER",STR0076)	
			EndIf	
		Next nY
	EndIf
ElseIf nAviso = 2

	For nZ := 1 to oModel:GetModel("SC8DETAIL"):Length()
		oModel:GetModel("SC8DETAIL"):GoLine(nZ)
		//----------------------------------
		// Copia Informação do Participante
		//----------------------------------
		If !oModel:GetModel("SC8DETAIL"):IsDeleted() .And. ;
		(!Empty(oModel:GetModel("SC8DETAIL"):Getvalue("C8_FORNECE"))  .Or. !Empty(oModel:GetModel("SC8DETAIL"):Getvalue("C8_FORNOME"))  )
		
			aAdd(aDados,{oModel:GetModel("SC8DETAIL"):Getvalue("C8_FORNECE"),;
							oModel:GetModel("SC8DETAIL"):Getvalue("C8_LOJA"),;
							oModel:GetModel("SC8DETAIL"):Getvalue("C8_FORNOME"),;
							oModel:GetModel("SC8DETAIL"):Getvalue("C8_FORMAIL"),;
							oModel:GetModel("SC8DETAIL"):Getvalue("C8_OBS"),; 
							oModel:GetModel("SC8DETAIL"):Getvalue("C8_VALIDA");							
							})
		EndIf
	Next nZ
	
	If Len(aDados) == 0
		Help("",1,"FORNDELETED2",,STR0108,4,1)
	Else	
		//----------------------------------
		// Limpa Participantes Atuais
		//----------------------------------
		For nY := 1 to oModel:GetModel("SC1DETAIL"):Length()
			If nY == nL2
				loop
			EndIf
			oModel:GetModel("SC1DETAIL"):GoLine(nY)
			nX := oModel:GetModel("SC8DETAIL"):GetQtdLine()
			For nZ := nX To 1 STEP -1
				oModel:GetModel("SC8DETAIL"):GoLine(nZ)
				oModel:GetModel("SC8DETAIL"):DeleteLine(.T.,.T.)	
			Next nZ
			If oModel:GetModel("SC8DETAIL"):IsDeleted()
				oModel:GetModel("SC8DETAIL"):UnDeleteLine()
			EndIf
			oModel:GetModel("SC8DETAIL"):LoadValue("C8_FORNECE",CriaVar("C8_FORNECE",.F.))
			oModel:GetModel("SC8DETAIL"):LoadValue("C8_LOJA",CriaVar("C8_LOJA",.F.))
			oModel:GetModel("SC8DETAIL"):LoadValue("C8_FORNOME",CriaVar("C8_FORNOME",.F.))
			oModel:GetModel("SC8DETAIL"):LoadValue("C8_FORMAIL",CriaVar("C8_FORMAIL",.F.))
			oModel:GetModel("SC8DETAIL"):LoadValue("C8_OBS",CriaVar("C8_OBS",.F.))
			oModel:GetModel("SC8DETAIL"):LoadValue("C8_CRITER",STR0072)	
		Next nY

		//----------------------------------
		// Inclui Participantes Salvos
		//----------------------------------
		For nY := 1 to oModel:GetModel("SC1DETAIL"):Length()
			If nY == nL2
				loop
			EndIf
			oModel:GetModel("SC1DETAIL"):GoLine(nY)
			For nZ := 1 to Len(aDados)
				If nZ != 1
					oModel:GetModel("SC8DETAIL"):AddLine()
				EndIf	
				oModel:GetModel("SC8DETAIL"):SetValue("C8_FORNECE",aDados[nZ,1])
				oModel:GetModel("SC8DETAIL"):SetValue("C8_LOJA",aDados[nZ,2])
				oModel:GetModel("SC8DETAIL"):SetValue("C8_FORNOME",aDados[nZ,3])
				oModel:GetModel("SC8DETAIL"):SetValue("C8_FORMAIL",aDados[nZ,4])
				oModel:GetModel("SC8DETAIL"):SetValue("C8_OBS",aDados[nZ,5])	
				oModel:GetModel("SC8DETAIL"):SetValue("C8_CRITER",STR0076)
				oModel:GetModel("SC8DETAIL"):SetValue("C8_FILENT",SC1->C1_FILENT)
				oModel:GetModel("SC8DETAIL"):SetValue("C8_VALIDA",aDados[nZ,6])							
			Next nZ
		Next nY		
		
	EndIf
ElseIf lReplica
	For nZ := 1 to oModel:GetModel("SC8DETAIL"):Length()
		oModel:GetModel("SC8DETAIL"):GoLine(nZ)
		//----------------------------------
		// Copia Informação do Participante
		//----------------------------------
		If !oModel:GetModel("SC8DETAIL"):IsDeleted() .And. ;
		(!Empty(oModel:GetModel("SC8DETAIL"):Getvalue("C8_FORNECE"))  .Or. !Empty(oModel:GetModel("SC8DETAIL"):Getvalue("C8_FORNOME"))  )
		
			aAdd(aDados,{oModel:GetModel("SC8DETAIL"):Getvalue("C8_FORNECE"),;
							oModel:GetModel("SC8DETAIL"):Getvalue("C8_LOJA"),;
							oModel:GetModel("SC8DETAIL"):Getvalue("C8_FORNOME"),;
							oModel:GetModel("SC8DETAIL"):Getvalue("C8_FORMAIL"),;
							oModel:GetModel("SC8DETAIL"):Getvalue("C8_OBS"),; 
							oModel:GetModel("SC8DETAIL"):Getvalue("C8_VALIDA");
							})
		EndIf
	Next nZ
	
	If Len(aDados) == 0
		Help("",1,"FORNDELETED2",,STR0108,4,1)
	Else	
		//----------------------------------
		// Limpa Participantes Atuais
		//----------------------------------
		For nW := 1 To oModel:GetModel("SBMDETAIL"):Length()
			oModel:GetModel("SBMDETAIL"):GoLine(nW)
			For nY := 1 to oModel:GetModel("SC1DETAIL"):Length()
				If nY == nL2
					loop
				EndIf
				oModel:GetModel("SC1DETAIL"):GoLine(nY)
				nX := oModel:GetModel("SC8DETAIL"):GetQtdLine()
				For nZ := nX To 1 STEP -1
					oModel:GetModel("SC8DETAIL"):GoLine(nZ)
					oModel:GetModel("SC8DETAIL"):DeleteLine(.T.,.T.)	
				Next nZ
				If oModel:GetModel("SC8DETAIL"):IsDeleted()
					oModel:GetModel("SC8DETAIL"):UnDeleteLine()
				EndIf
				oModel:GetModel("SC8DETAIL"):LoadValue("C8_FORNECE",CriaVar("C8_FORNECE",.F.))
				oModel:GetModel("SC8DETAIL"):LoadValue("C8_LOJA",CriaVar("C8_LOJA",.F.))
				oModel:GetModel("SC8DETAIL"):LoadValue("C8_FORNOME",CriaVar("C8_FORNOME",.F.))
				oModel:GetModel("SC8DETAIL"):LoadValue("C8_FORMAIL",CriaVar("C8_FORMAIL",.F.))
				oModel:GetModel("SC8DETAIL"):LoadValue("C8_OBS",CriaVar("C8_OBS",.F.))
				oModel:GetModel("SC8DETAIL"):LoadValue("C8_CRITER",STR0072)	
			Next nY
		Next nW

		//----------------------------------
		// Inclui Participantes Salvos
		//----------------------------------
		For nW := 1 To oModel:GetModel("SBMDETAIL"):Length()
			oModel:GetModel("SBMDETAIL"):GoLine(nW)
			For nY := 1 to oModel:GetModel("SC1DETAIL"):Length()
				If nY == nL2 .And. nW == nL2
					loop
				EndIf
				oModel:GetModel("SC1DETAIL"):GoLine(nY)
				For nZ := 1 to Len(aDados)
					If nZ != 1
						oModel:GetModel("SC8DETAIL"):AddLine()
					EndIf	
					oModel:GetModel("SC8DETAIL"):SetValue("C8_FORNECE",aDados[nZ,1])
					oModel:GetModel("SC8DETAIL"):SetValue("C8_LOJA",aDados[nZ,2])
					oModel:GetModel("SC8DETAIL"):SetValue("C8_FORNOME",aDados[nZ,3])
					oModel:GetModel("SC8DETAIL"):SetValue("C8_FORMAIL",aDados[nZ,4])
					oModel:GetModel("SC8DETAIL"):SetValue("C8_OBS",aDados[nZ,5])	
					oModel:GetModel("SC8DETAIL"):SetValue("C8_CRITER",STR0076)
					oModel:GetModel("SC8DETAIL"):SetValue("C8_FILENT",SC1->C1_FILENT)
					oModel:GetModel("SC8DETAIL"):SetValue("C8_VALIDA",aDados[nZ,6])							
				Next nZ
			Next nY		
		Next nW
	EndIf
EndIf

oModel:GetModel("SC1DETAIL"):GoLine(nL2)
oModel:GetModel("SC8DETAIL"):GoLine(nL3)	
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} PreValSC8(oModelGrid, nLinha, cAcao, cCampo)
Rotina de Pre validação do modelo SC8(Solicitações)

@author alexandre.gimenez
@param oModelGrid Modelo
@param nLinha Linha corrente
@param cAcao  Ação ("DELETE", "SETVALUE", e etc)
@param cCampo Campo atualizado
@return lRet
@since 24/10/2013
@version 1.0
/*/
//------------------------------------------------------------------
Static Function PreValSC8(oModelGrid, nLinha, cAcao, cCampo)
local lRet			:= .T.
Local lAchou		:= .F.
Local nX			:= 0
Local oView := FwViewActive()
Local lView := oView <> Nil .And. oView:IsActive()
Local aSaveLines := FWSaveRows()

If cAcao == "UNDELETE"
	a131LegSC1(.T.)
EndIf

If cAcao = "DELETE"
	For nX := 1 to oModelGrid:length()
		oModelGrid:GoLine(nX)
		If !oModelGrid:Isdeleted() .And. nX != nLinha
			If !Empty(oModelGrid:GetValue("C8_FORNECE")) .OR. !Empty(oModelGrid:GetValue("C8_FORNOME"))
				lAchou:= .T.
				Exit
			EndIf
		EndIf	
	Next nX
	oModelGrid:GoLine(nLinha)	
	If lAchou
		a131LegSC1(.T.)
	Else
		a131LegSC1(.F.,'SC1DETAIL')
	EndIf
EndIf


If lView
	If (cAcao == 'ADDLINE')
		FWRestRows(aSaveLines)
		oView:Refresh("VIEW_SC8")
	EndIf 
Else
	oModelGrid:GoLine(nLinha)
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} PreValSC8(oModelGrid, nLinha, cAcao, cCampo)
Rotina de Pre validação do modelo SC8(Solicitações)

@author alexandre.gimenez
@param oModelGrid Modelo
@param nLinha Linha corrente
@param cAcao  Ação ("DELETE", "SETVALUE", e etc)
@param cCampo Campo atualizado
@return lRet
@since 24/10/2013
@version 1.0
/*/
//------------------------------------------------------------------
Static Function PosValSC8(oModelGrid, nLinha, cAcao, cCampo)
Local aArea		 := GetArea()
local lRet		 := .T.
Local lAchou	 := .F.
Local nX		 := 0
Local nMaxFornec := 0
Local nFornec 	 := 0
Local oView 	 := FwViewActive()
Local lView 	 := oView <> Nil .And. oView:IsActive()
Local aSaveLines := FWSaveRows()


Pergunte("MTA131",.F.)
nMaxFornec := MV_PAR01 

If  ((!Empty(oModelGrid:GetValue("C8_FORNECE")).And. Empty(oModelGrid:GetValue("C8_LOJA"))) .OR. ;
			(Empty(oModelGrid:GetValue("C8_FORNECE")).And. !Empty(oModelGrid:GetValue("C8_LOJA"))) .OR.; 
			(Empty(oModelGrid:GetValue("C8_FORNOME")).And.(Empty(oModelGrid:GetValue("C8_FORNECE")).And.Empty(oModelGrid:GetValue("C8_LOJA")).And.!oModelGrid:IsDeleted())))		
		Help(Nil, 1, "A131VALSC8", Nil, STR0135, 1, 0, Nil, Nil, Nil, Nil, Nil, {STR0136})
	lRet := .F. 
EndIf 	

If lRet 
	For nX := 1 to oModelGrid:length()
		oModelGrid:GoLine(nX)
		If !oModelGrid:Isdeleted()
			If !Empty(oModelGrid:GetValue("C8_FORNECE")) .OR. !Empty(oModelGrid:GetValue("C8_FORNOME"))
				lAchou:= .T.
				a131LegSC1(.T.)
				Exit
			EndIf
		EndIf	
		
	Next nX
EndIf 

If lRet 
	For nX := 1 to oModelGrid:length()
		oModelGrid:GoLine(nX)
		If !oModelGrid:Isdeleted()
			nFornec++
		EndIf
	Next nX
EndIf 

If lRet .And. SuperGetMV("MV_SELFOR", .T., .F.) == 'S' 
	If nFornec > nMaxFornec
		Help( , , 'Help', ,"Quantidade máxima de fornecedores foi atingida", 1, 0 )  
		lRet := .F.
	EndIf
EndIf	

If lRet .And. !lAchou
	a131LegSC1(.F.)
EndIf


If lRet .And. lView
	FWRestRows(aSaveLines)
  	oView:Refresh("VIEW_SC8")
Else
	oModelGrid:GoLine(nLinha)
EndIf

// Adicionada pilha da rotina pois estava passando 2x nessa função
If lRet .And. nFornec > 0 .And. IsInCallStack('VLDDATA')
	ComMetric(nFornec)
Endif

	 
RestArea(aArea)
Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} a131Bloq(lBloq)
Função para bloquear e desbloquear modelo

@author alexandre.gimenez
@since 24/10/2013
@version 1.0
/*/
//------------------------------------------------------------------
Static Function a131Bloq(oModel,lBloq)

oModel:GetModel("SC1DETAIL"):SetNoUpdateLine(lBloq)
oModel:GetModel("SBMDETAIL"):SetNoUpdateline(lBloq)
oModel:GetModel("SC1DETAIL"):SetNoDeleteLine(lBloq)
oModel:GetModel("SBMDETAIL"):SetNoDeleteLine(lBloq)
oModel:GetModel("SC1DETAIL"):SetNoInsertLine(lBloq)
oModel:GetModel("SBMDETAIL"):SetNoInsertLine(lBloq)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} a131LegSC1(lStatus)
Função atualizar legenda

@author alexandre.gimenez
@since 24/10/2013
@version 1.0
/*/
//------------------------------------------------------------------
Static Function a131LegSC1(lStatus)
Local oModel 		:= FWModelActive()
Local oView		:= FwViewActive()
Local lView		:= ValType(oView)== "O"
Local nL		 	:= oModel:GetModel("SC1DETAIL"):nLine
Local lSepGrd		:= IsInCallStack("A131SEPGRD")

If lView .And. !lSepGrd
	a131Bloq(oModel,.F.)
EndIf

If lStatus
	oModel:GetModel("SC1DETAIL"):SetValue("LEGENDA","BR_VERDE")
Else
	oModel:GetModel("SC1DETAIL"):SetValue("LEGENDA","BR_VERMELHO")
EndIf

a131LegSBM(oModel)

If lView .And. !lSepGrd .And. oView:GetViewObj("VIEW_SC1",.F.) # Nil

	a131Bloq(oModel,.T.)
EndIf
  
oModel:GetModel("SC1DETAIL"):GoLine(nL)	
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} a131LegSBM(oModel)
Função atualizar legenda

@author alexandre.gimenez
@since 24/10/2013
@version 1.0
/*/
//------------------------------------------------------------------
Static Function a131LegSBM(oModel)
Local nX 		:= 0
Local oModSC	:= oModel:GetModel("SC1DETAIL")
Local oModGR	:= oModel:GetModel("SBMDETAIL") 
Local nL1		:= oModSC:nLine
Local nL2		:= oModGR:nLine
Local lAchou	:= .F.

For nX:= 1 to oModSC:Length()
	oModSC:GoLine(nX)
	If Alltrim(oModSc:GetValue("LEGENDA")) == "BR_VERMELHO"
		lAchou := .T.
		Exit
	EndIf
next nX

If lAchou
	oModGR:SetValue("LEGENDA","BR_VERMELHO")	
Else	
	oModGR:SetValue("LEGENDA","BR_VERDE")
EndIf

oModSC:GoLine(nL1)	
oModGR:GoLine(nL2)	
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} a131VldFor(oModel,cField,cValue,nLine)
Rotina para validar Fornecedor.

@author alexandre.gimenez
@since 25/10/2013
@version 1.0
/*/
//------------------------------------------------------------------
Function a131VldFor()
Local lRet 	:= .T.	
Local aArea	:= GetArea()
Local oModel	:= FWModelActive()
Local l131		:= ValType(oModel) == "O" .And. oModel:GetId() == "MATA131"  .And. IsInCallStack("MATA131")
Local oModFor := IIF(l131,oModel:GetModel("SC8DETAIL"),Nil)
Local oModSC1 := IIF(l131,oModel:GetModel("SC1DETAIL"),Nil)
local lSeek	:= .T. 
local cField	:= Substr(ReadVar(),4)  
Local cValue	:= &(ReadVar())
Local nValFrete	:= 0
Local nAmarracao := MV_PAR06
Local lNewForn	:= .F.

If l131	
   If cField == 'C8_LOJA' .And. !(Empty(oModFor:GetValue("C8_FORNECE")))
		If !SA2->(DBSeek(xFilial("SA2")+oModFor:GetValue("C8_FORNECE")+cValue))
			HELP(" ",1,"A131NGERA")
			lSeek := .F.
			lRet  := .F.
		EndIf
	EndIf
	//----------------------
	// Validação
	//----------------------
	If cField == 'C8_FORNOME'
		lRet := !Empty(cValue)
	EndIf

	If lRet .And. lSeek
		DbSelectArea("SA2")
		DbSetOrder(1)
		If !(Empty(oModFor:GetValue("C8_LOJA")))
			lRet := SA2->(DBSeek(xFilial("SA2")+oModFor:GetValue("C8_FORNECE")+oModFor:GetValue("C8_LOJA")))
		ElseIf !(Empty(oModFor:GetValue("C8_FORNECE")))
			SA2->(DBSeek(xFilial("SA2")+oModFor:GetValue("C8_FORNECE")))
			lRet := .F.
			While !SA2->(Eof())  .And. SA2->A2_COD == oModFor:GetValue("C8_FORNECE") 
				If  RegistroOk("SA2")
					lRet := .T.
					Exit
				Endif		
			SA2->(dbSkip())
			EndDo
		Else
			lNewForn := .T.
		Endif

		If lRet .And. !lNewForn .And. RegistroOk("SA2")
			oModFor:LoadValue("C8_FORNOME",PadR(SA2->A2_NOME,Len(SC8->C8_FORNOME)))
			oModFor:LoadValue("C8_FORMAIL",PadR(SA2->A2_EMAIL,Len(SC8->C8_FORMAIL)))
			oModFor:LoadValue("C8_CONTATO",PadR(SA2->A2_CONTATO,Len(SC8->C8_CONTATO)))
			oModFor:LoadValue("C8_COND",SA2->A2_COND)
			oModFor:LoadValue("C8_LOJA",SA2->A2_LOJA)
		Elseif !lNewForn
			lRet := .F. 
		EndIf
	EndIf
	
	//Inicializa campos obrigatorios
	If Empty(oModFor:GetValue("C8_PRODUTO"))
		oModFor:LoadValue("C8_PRODUTO",oModSC1:GetValue("C1_PRODUTO"))
	EndIf
	
	DbSelectArea("SB1")
	SB1->(DbSetOrder(1))
	SB1->(DBSeek(xFilial("SB1")+oModFor:GetValue("C8_PRODUTO")))
	
	If Empty(oModFor:GetValue("C8_QUANT"))
		oModFor:LoadValue("C8_QUANT",oModSC1:GetValue("C1_QUANT"))
	EndIf
	If Empty(oModFor:GetValue("C8_UM"))
		oModFor:LoadValue("C8_UM",SB1->B1_UM)	
	EndIf	
	
	cCodTab := ""
	If !lNewForn
		dbSelectArea("SA5")
		SA5->(dbSetOrder(1))
		If SA5->(DbSeek(xFilial("SA5")+oModFor:GetValue("C8_FORNECE")+oModFor:GetValue("C8_LOJA")+oModFor:GetValue("C8_PRODUTO")))
			cCodTab := SA5->A5_CODTAB
		Else	
			SA5->(dbSetOrder(9))
			If SA5->(DbSeek(xFilial("SA5")+oModFor:GetValue("C8_FORNECE")+oModFor:GetValue("C8_LOJA")+oModFor:GetValue("C8_PRODUTO")))
				cCodTab := SA5->A5_CODTAB
			Endif
		Endif
			
		If (nAmarracao == 2 .Or. nAmarracao == 3 )// Grupo
			dbSelectArea("SAD")
			SAD->(dbSetOrder(2))
			If MsSeek(xFilial("SAD")+SB1->B1_GRUPO+oModFor:GetValue("C8_FORNECE")+oModFor:GetValue("C8_LOJA"))
				If Empty(cCodTab)
					cCodTab := SAD->AD_CODTAB
				EndIf
			Endif
		EndIf
		
		oModFor:LoadValue("C8_CODTAB",cCodTab)
		
		If !Empty(cCodTab)
			dbSelectArea("AIA")
			dbSetOrder(1)
			If MsSeek(xFilial("AIA")+oModFor:GetValue("C8_FORNECE")+oModFor:GetValue("C8_LOJA")+cCodTab)
				If !Empty(AIA->AIA_CONDPG)
					oModFor:LoadValue("C8_COND",AIA->AIA_CONDPG)
				EndIf
				oModFor:LoadValue("C8_PRECO",MaTabPrCom(cCodTab,oModFor:GetValue("C8_PRODUTO"),oModFor:GetValue("C8_QUANT"),oModFor:GetValue("C8_FORNECE"),oModFor:GetValue("C8_LOJA"),oModFor:GetValue("C8_MOEDA"),dDataBase,,@nValFrete))
				oModFor:LoadValue("C8_VALFRE",nValFrete)
				oModFor:LoadValue("C8_TOTAL",NoRound(oModFor:GetValue("C8_QUANT") * oModFor:GetValue("C8_PRECO"),2))
			EndIf
		EndIf
	Endif
EndIf
	
RestArea(aArea)
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} a131Active(oModel)
Rotina pos validação do Modelo

@author alexandre.gimenez
@since 25/10/2013
@version 1.0
/*/
//------------------------------------------------------------------
Static Function a131Active(oModel)
Local lRet 	:= .T.
Local oModelSC1 := oModel:GetModel("SC1DETAIL")
Local aFildeSc1 := oModelSC1:GetStruct():GetFields()
Local lCotRatP := SuperGetMv("MV_COTRATP",.F.,.F.)
Local nX := 0

oModel:GetModel("XXXMASTER"):LoadValue("XXX_X","X")
oModel:GetModel("SC8DETAIL"):GetStruct():SetProperty("C8_FORNECE",MODEL_FIELD_OBRIGAT,.F.)
oModel:GetModel("SC8DETAIL"):GetStruct():SetProperty("C8_LOJA",MODEL_FIELD_OBRIGAT,.F.)
oModel:GetModel("SC8DETAIL"):GetStruct():SetProperty("C8_COND",MODEL_FIELD_OBRIGAT,.F.)
oModel:GetModel("SC8DETAIL"):GetStruct():SetProperty("C8_CONTATO",MODEL_FIELD_OBRIGAT,.F.)
oModel:GetModel("SC8DETAIL"):GetStruct():SetProperty("C8_PRODUTO",MODEL_FIELD_OBRIGAT,.F.)
oModel:GetModel("SC8DETAIL"):GetStruct():SetProperty("C8_QUANT",MODEL_FIELD_OBRIGAT,.F.)
oModel:GetModel("SC8DETAIL"):GetStruct():SetProperty("C8_UM",MODEL_FIELD_OBRIGAT,.F.)
oModel:GetModel("SC8DETAIL"):GetStruct():SetProperty("C8_NUMPRO",MODEL_FIELD_OBRIGAT,.F.)
oModel:GetModel("SC8DETAIL"):GetStruct():SetProperty("C8_PRECO",MODEL_FIELD_OBRIGAT,.F.)
oModel:GetModel("SC8DETAIL"):GetStruct():SetProperty("C8_NUM",MODEL_FIELD_OBRIGAT,.F.)
oModel:GetModel("SC8DETAIL"):GetStruct():SetProperty("C8_ITEM",MODEL_FIELD_OBRIGAT,.F.)
oModel:GetModel("SC8DETAIL"):GetStruct():SetProperty("C8_TOTAL",MODEL_FIELD_OBRIGAT,.F.)
oModel:GetModel("SC8DETAIL"):GetStruct():SetProperty("C8_TES",MODEL_FIELD_OBRIGAT,.F.)
If  lCotRatP
	For nX = 1 to Len(aFildeSc1)
		oModel:GetModel("SC1DETAIL"):GetStruct():SetProperty(aFildeSc1[nX][3],MODEL_FIELD_OBRIGAT,.F.)
	Next nX
EndIF


A131RstV(oModel)


Return lRet
//-------------------------------------------------------------------
/*/{Protheus.doc} a131OpenV(oModel)
Rotina para posicionar o Modelo na abertura da View

@author alexandre.gimenez
@since 25/10/2013
@version 1.0
/*/
//------------------------------------------------------------------
Static Function a131OpenV(oModel)
Local lRet := .T.
Local oView		:= FwViewActive()

A131RstV(oModel)

oView:Refresh("VIEW_SC1")
oView:Refresh("VIEW_SBM")
oView:Refresh("VIEW_SC8")

Return lRet



//-------------------------------------------------------------------
/*/{Protheus.doc} a131AtuLeg(oModel)
Rotina para atualizar todas as legendas do modelo

@author alexandre.gimenez
@since 28/10/2013
@version 1.0
/*/
//------------------------------------------------------------------
Static Function a131AtuLeg(oModel,lPos)
Local lRet			:= .T.
Local aSaveLines 	:= FWSaveRows()
Local nX			:= 0
Local nY			:= 0
local nZ			:= 0
Local nL1			:= oModel:GetModel("SBMDETAIL"):nLine
Local nL2			:= oModel:GetModel("SC1DETAIL"):nLine
Local nL3			:= oModel:GetModel("SC8DETAIL"):nLine
local lAchou 		:= .F.
Local lAvisou		:= .F.
Local oView			:= FwViewActive()
Local lView			:= ValType(oView)== "O"
Local nPrdRed		:= 0

Default lPos		:= .F.

For nX := 1 to oModel:GetModel("SBMDETAIL"):Length() 
	oModel:GetModel("SBMDETAIL"):GoLine(nX)
	For nY := 1 to oModel:GetModel("SC1DETAIL"):Length()
		oModel:GetModel("SC1DETAIL"):GoLine(nY)

		If Alltrim(oModel:GetModel("SC1DETAIL"):GetValue("LEGENDA")) == "BR_VERMELHO"
			nPrdRed++
		Endif

		lAchou := .F.
		For nZ := 1 to oModel:GetModel("SC8DETAIL"):Length()
			oModel:GetModel("SC8DETAIL"):GoLine(nZ)
			If !oModel:GetModel("SC8DETAIL"):Isdeleted()
				If !Empty(oModel:GetModel("SC8DETAIL"):GetValue("C8_FORNECE")) ;
				.OR. !Empty(oModel:GetModel("SC8DETAIL"):GetValue("C8_FORNOME"))
					lAchou:= .T.
					a131LegSC1(.T.)
					Exit
				EndIf
			EndIf	
		Next nZ
		//-----------------------------
		If !lAchou
			a131LegSC1(.F.)		
			If !lAvisou .And. lView .And. lPos .And. !MsgYesNo(STR0069,STR0070) //"Produtos sem Fornecedores não farão parte do processo de cotação, Deseja continuar ?" * "Aviso"
				lRet := .F.
			EndIf
			lAvisou:= .T.
		EndIf
		//------------------------------
	Next nY
Next nX

If lRet .And. lAvisou .And. lView .And. lPos
	If nPrdRed == oModel:GetModel("SC1DETAIL"):Length()
		Help("",1,"NOFORNECE",,STR0134,1,1) //"Nenhum fornecedor foi informado, não sera gerado nenhum cotação."
		lRet := .F.
	Else
		For nX := 1 to oModel:GetModel("SBMDETAIL"):Length() 
			oModel:GetModel("SBMDETAIL"):GoLine(nX)
			For nY := 1 to oModel:GetModel("SC1DETAIL"):Length()
				oModel:GetModel("SC1DETAIL"):GoLine(nY)
				For nZ := 1 to oModel:GetModel("SC8DETAIL"):Length()
					oModel:GetModel("SC8DETAIL"):GoLine(nZ)
					If !oModel:GetModel("SC8DETAIL"):Isdeleted()
						If Empty(oModel:GetModel("SC8DETAIL"):GetValue("C8_FORNECE")) .And. Empty(oModel:GetModel("SC8DETAIL"):GetValue("C8_FORNOME"))
							oModel:GetModel("SC8DETAIL"):DeleteLine()					
						EndIf
					EndIf	
				Next nZ
			Next nY
		Next nX
	Endif
Endif

oModel:GetModel("SBMDETAIL"):GoLine(nL1)
oModel:GetModel("SC1DETAIL"):GoLine(nL2)
oModel:GetModel("SC8DETAIL"):GoLine(nL3)	
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} a131AtuFor()
Rotina para atualizar fornecedor quando a inclusao for manual

@author alexandre.gimenez
@since 28/10/2013
@version 1.0
/*/
//------------------------------------------------------------------
Static Function a131AtuFor(oModel,nQtdSC,nQtdSC2,dValidade)
Local oModFor		:= oModel:GetModel("SC8DETAIL")

oModFor:LoadValue("C8_FILIAL",xFilial("SC8"))
oModFor:LoadValue("C8_FILENT",SC1->C1_FILENT)
oModFor:LoadValue("C8_EMISSAO",dDataBase)
oModFor:LoadValue("C8_GRUPCOM",SC1->C1_GRUPCOM)
oModFor:LoadValue("C8_PRODUTO",SC1->C1_PRODUTO)
oModFor:LoadValue("C8_PRAZO",RetFldProd(SB1->B1_COD,"B1_PE"))
oModFor:LoadValue("C8_UM",SC1->C1_UM)
oModFor:LoadValue("C8_VALIDA",dValidade)
oModFor:LoadValue("C8_QUANT",nQtdSC)
oModFor:LoadValue("C8_QTSEGUM",nQtdSC2)
oModFor:LoadValue("C8_NUMPRO","01")
oModFor:LoadValue("C8_DATPRF",Max(SC1->C1_DATPRF,dDataBase))
oModFor:LoadValue("C8_NUMSC",SC1->C1_NUM)
oModFor:LoadValue("C8_ITEMSC",SC1->C1_ITEM)
oModFor:LoadValue("C8_ITSCGRD",SC1->C1_ITEMGRD)
oModFor:LoadValue("C8_OBS",SC1->C1_OBS)
oModFor:LoadValue("C8_SEGUM",SC1->C1_SEGUM)
oModFor:LoadValue("C8_ORIGEM",SC1->C1_ORIGEM)
oModFor:LoadValue("C8_MOEDA",Iif(MV_PAR16 > 0, Iif(MV_PAR16 <= MoedFin(), MV_PAR16, 1), 1))// Caso o usuario nao informe a moeda ou seja invalida, o sistema assume a moeda 1.

If cPaisLoc == "BRA"
	oModFor:LoadValue("C8_PICM",SB1->B1_PICM)
	oModFor:LoadValue("C8_ALIIPI",SB1->B1_IPI)
EndIf

If SC8->(FieldPos("C8_PRECOOR")) > 0
	oModFor:LoadValue("C8_PRECOOR",SC1->C1_VUNIT)
EndIf
	
If ExistBlock("MTA131C8")
	Execblock("MTA131C8",.F.,.F.,{@oModFor})
EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} a131HisForn
Função responsavel por trazer o histórico do fornecedor
@author alexandre.gimenez
@since 30/10/2013
@version P11.90
/*/
//-------------------------------------------------------------------
Static Function a131HisForn(oModel)
Local aArea := GetArea()

If Empty(oModel:GetModel("SC8DETAIL"):GetValue("C8_FORNECE"))
	Help("",1,"NOFORNECE",,STR0071,4,1) //"Somente é possivel exibir histórico de fornecedor cadastrado."
Else
	SA2->(dbSetOrder(1))
	If SA2->(dbSeek(xFilial('SA2')+oModel:GetModel("SC8DETAIL"):GetValue("C8_FORNECE")+oModel:GetModel("SC8DETAIL"):GetValue("C8_LOJA")))
		Finc030("Fc030Con")
	EndIf
	RestArea(aArea)
EndIf

Return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc}  A131HisPro(oModel)
Função responsavel por trazer o histórico do produto
@author alexandre.gimenez
@since 30/10/2013
@version P11.90
/*/
//-------------------------------------------------------------------
Static Function A131HisPro(oModel)
Local aArea 	 :=    GetArea()
Local cProduto := oModel:GetModel("SC1DETAIL"):GetValue("C1_PRODUTO")

MaFisSave()
MaFisEnd()

If !AtIsRotina("MACOMVIEW")
      If !Empty(cProduto)
            MaComView(cProduto)
      EndIf
EndIf

MaFisRestore()

RestArea(aArea)
Return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} a131SepGrd(nLinha)
Rotina Para separar um item de grade aglutinado pela referencia
para itens de produtos individualmente.

@author alexandre.gimenez
@since 04/11/2013
@version 1.0
/*/
//------------------------------------------------------------------
Static Function a131SepGrd(nLinha)
Local aArea	:= GetArea()
Local oModel	:= FWModelActive()
Local oModPro	:= oModel:GetModel("SC1DETAIL")
Local oModFor	:= oModel:GetModel("SC8DETAIL")
Local nZ		:= 0
Local nF		:= 0
Local aDados	:= {}
Local aScs		:= STRTOKARR(oModPro:GetValue("ITEMSC"),";")
Local lQuebrou:= .F.
Local cProd	:=	""
Local nQtdSc	:= 0
Local nqtdSc2	:= 0

a131Bloq(oModel,.F.)
oModPro:GoLine(nLinha)
//----------------------------------
// Copia Informação do Participante
//----------------------------------
For nZ := 1 to oModFor:Length()
	oModFor:GoLine(nZ)
	If !oModFor:Isdeleted() .And. ; 
	(!Empty(oModFor:Getvalue("C8_FORNECE"))  .Or. !Empty(oModFor:Getvalue("C8_FORNOME"))  )
		
		aAdd(aDados,{oModFor:Getvalue("C8_FORNECE"),;
						oModFor:Getvalue("C8_LOJA"),;
						oModFor:Getvalue("C8_FORNOME"),;
						oModFor:Getvalue("C8_FORMAIL"),;
						oModFor:Getvalue("C8_OBS") })
	EndIf
Next nZ


//--------------------------------
// Adicona Scs Novamente
// Agora Produtos individualmente
//--------------------------------
DBSelectArea("SC1")
DBSetOrder(1)
For nZ := 1 to Len(aScs)
	If SC1->(DBSeek(xFilial("SC1")+aSCs[nZ]))
		lQuebrou :=  cProd # SC1->C1_PRODUTO
		If lQuebrou
			//---------------
			// Posiciona SB1
			//---------------
			cProd := SC1->C1_PRODUTO
			DBSelectArea("SB1")
			DBSetOrder(1)
			SB1->(DBSeek(xFilial("SB1")+cProd))
			nQtdSC := 0
			nQtdSC2 := 0	
		EndIf
		//---------------
		// Adiciona Sc
		//---------------
		nQtdSC += (SC1->C1_QUANT - SC1->C1_QUJE )
		nQtdSC2 +=  SC1->C1_QTSEGUM
		a131AddSc(oModel,"SC1",nQtdSc,nQtdSc2,lQuebrou,.T./*lSepara*/)		
		//------------------------
		// Adiciona Fornecedores
		//------------------------
		If lQuebrou
			For nF := 1 to Len(aDados)
				If nF != 1
					oModFor:AddLine()
				EndIf	
				oModFor:SetValue("C8_FORNECE",aDados[nF,1])
				oModFor:SetValue("C8_LOJA",aDados[nF,2])
				oModFor:SetValue("C8_FORNOME",aDados[nF,3])
				oModFor:SetValue("C8_FORMAIL",aDados[nF,4])
				oModFor:SetValue("C8_OBS",aDados[nF,5])			
			Next nF			
		EndIf
	EndIf
Next nZ

//---------------------------
// Exclui Produto referencia
//---------------------------
oModPro:GoLine(nLinha)
oModPro:DeleteLine(.T.,.T.)

RestArea(aArea)
a131Bloq(oModel,.T.)

Return Nil
//-------------------------------------------------------------------
/*/{Protheus.doc} a131Posvld(oModel)
Rotina valida o modelo.

@author alexandre.gimenez
@since 28/10/2013
@version 1.0
/*/
//------------------------------------------------------------------
Static Function a131Posvld(oModel,aSCs,cNumCot,lSelFor,lReplica)
Local aArea 	:= GetArea() 
Local oModGrp	:= oModel:GetModel("SBMDETAIL")
Local oModPro	:= oModel:GetModel("SC1DETAIL")
Local oModFor	:= oModel:GetModel("SC8DETAIL")
Local nL1		:= oModGrp:nLine
Local nL2		:= oModPro:nLine
Local nL3		:= oModFor:nLine
Local nG		:= 0
Local nP		:= 0
Local nF		:= 0
Local nSC1		:= 0
Local nSC2		:= 0
Local aIdent	:= {}
Local aItem		:= {}
Local aItemRef	:= {}
Local nIdent	:= 0
Local nIdentR	:= 0
Local nItemGd	:= 0
Local nPosRef	:= 0
Local nItem		:= 0
local lGrade	:= 0
Local cProdRef	:= ""
Local cIdentSC	:= ""
Local cGrpRef	:= ""
Local lRet		:= .T.
Local nX		:= 0
Local nY		:= 0  
Local nDiasVal	:= 0
Local dValidade	:= dDataBase

Default lReplica := .F.
Default cNumCot:= ""

Pergunte("MTA130",.F.)

nDiasVal	:= MV_PAR04

If Empty(cNumCot)
	cNumCot:= GetNumSC8(.F.)
	nSaveSX8 := GetSX8Len()
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Calcula a Data de Validade da Cotacao descontando Sab/Dom e Feriados³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
While nDiasVal > 0
	dValidade ++
	dValida := DataValida(dValidade)
	If dValida == dValidade
		nDiasVal--
	EndIf
EndDo

If lSelFor .And. lReplica
	a131Replic(oModel,lReplica,dValidade)
EndIf

lRet := a131AtuLeg(oModel,.T.)

If lRet
	For nG := 1 to oModGrp:Length()
		oModGrp:GoLine(nG)
		nP := 0
		While nP < oModPro:Length()
			++nP
			oModPro:GoLine(nP)	
			//---------------------------------------
			//Validar se existe Fornecedores Validos
			//----------------------------------------
			If Alltrim(oModPro:GetValue("LEGENDA")) == "BR_VERMELHO"
				Loop
			EndIf	
			
			//---------------------------------------
			// Verifica se Produto Grade (Referencia)
			// Separa Produtos para Itens Individuais
			//----------------------------------------
			cProdRef := oModPro:GetValue("C1_PRODUTO")
			cGrpRef  := oModGrp:GetValue("BM_GRUPO")
			lGrade   := MatGrdPrrf(@cProdRef, .T.) .And. oModPro:GetValue("GRADE")
			
			If oModPro:GetValue("GRADE") .And. !oModPro:Isdeleted() .And. AllTrim(cProdRef) == AllTrim(oModPro:GetValue("C1_PRODUTO"))
				a131SepGrd(nP)
				Loop
			EndIf	
			//-----------------------
			// Buscar Ident
			//-----------------------
			If lGrade
				nPosRef := aScan(aIdent,{ |x| x[1] == cProdRef+cGrpRef })
				If nPosRef == 0
					aAdd(aIdent,{cProdRef+cGrpRef,++nIdent,1})
					nIdentR := nIdent
					nItemGd := aIdent[len(aIdent)][3]
				Else
					nIdentR := aIdent[nPosRef][2]
					++aIdent[nPosRef][3]
					nItemGd := aIdent[nPosRef][3]
				EndIf	
			Else
				nIdent++
			EndIf
			
			//------------------------------
			// Separa Scs e Busca Ident
			//------------------------------
			cIdentSC := StrZero(iif(lGrade,nIdentR,nIdent),TamSX3("C8_IDENT")[1])
			aAdd(aSCs,{cIdentSC,STRTOKARR(oModPro:GetValue("ITEMSC"),";")})
			
			For nF := 1 to oModFor:Length()
				
				oModFor:GoLine(nF)

				If oModFor:IsDeleted() 
					Loop
				Endif
				
				//-----------------------------------
				// Atualiza dados caso fornecedor 
				// seja incluido pelo usuario
				//-----------------------------------
				If UPPER(AllTrim(oModFor:GetValue("C8_CRITER"))) == STR0072 .Or.;
				   UPPER(AllTrim(oModFor:GetValue("C8_CRITER"))) == STR0097 .Or.;
				         AllTrim(oModFor:GetValue("C8_CRITER"))  == STR0076 //"INCLUSAO MANUAL"###"INCLUSAO CLICBUSINESS"###"Replicado"
					//------------------------
					// Posiciona SC1,SB1
					//------------------------
					DBSelectArea("SC1")
					DbSetOrder(1)
					nSC1:= len(aSCs)	
					For nSC2:= 1 to Len(aSCs[nSC1][2])
						SC1->(DBSeek(xFilial("SC1")+aSCs[nSC1][2][nSC2]))
					Next nSC2						
					DBSelectArea("SB1")
					DbSetOrder(1)
					SB1->(DBSeek(xFilial("SB1")+oModPro:GetValue("C1_PRODUTO")))
					//--------------------
					//Atualiza Forncedor
					//--------------------
					a131AtuFor(oModel,oModPro:GetValue("C1_QUANT"),oModPro:GetValue("C1_QTSEGUM"),dValidade)
				EndIf
				
				//---------------------
				// Busca Item
				//---------------------
				nItem := aScan(aItem,{|x| x[1] == oModFor:GetValue("C8_FORNECE")+oModFor:GetValue("C8_LOJA")+oModFor:GetValue("C8_FORNOME")})
				If nItem == 0
					aAdd(aItem,{oModFor:GetValue("C8_FORNECE")+oModFor:GetValue("C8_LOJA")+oModFor:GetValue("C8_FORNOME"),1})
					nItem := aItem[len(aItem)][2]
					If lGrade
						aAdd(aItemRef,{cProdRef+oModFor:GetValue("C8_FORNECE")+oModFor:GetValue("C8_LOJA")+oModFor:GetValue("C8_FORNOME"),1})
					EndIf
				Else
					If lGrade .And. (nPosRef := aScan(aItemRef,{|x| x[1] == cProdRef+oModFor:GetValue("C8_FORNECE")+oModFor:GetValue("C8_LOJA")+oModFor:GetValue("C8_FORNOME")})) > 0
						nItem := aItemRef[nPosRef,2]
					Else
						++aItem[nItem][2]
						nItem := aItem[nItem][2]
						If lGrade
							aAdd(aItemRef,{cProdRef+oModFor:GetValue("C8_FORNECE")+oModFor:GetValue("C8_LOJA")+oModFor:GetValue("C8_FORNOME"),nItem})
						EndIf						
					EndIf
				EndIf
				If lGrade
					oModFor:LoadValue("C8_IDENT",StrZero(nIdentR,TamSX3("C8_IDENT")[1]))
					oModFor:LoadValue("C8_GRADE","S")
					oModFor:LoadValue("C8_ITEMGRD",StrZero(nItemGd,TamSX3("C8_ITEMGRD")[1]))
				Else
					oModFor:LoadValue("C8_IDENT",StrZero(nIdent,TamSX3("C8_IDENT")[1]))
					oModFor:LoadValue("C8_GRADE","")				
				EndIf			
				oModFor:LoadValue("C8_ITEM",StrZero(nItem,TamSX3("C8_ITEM")[1]))
				oModFor:LoadValue("C8_NUM",cNumCot)
				
				// Verifica se a linha nao esta deletada e se foi informado pelo menos o nome do fornecedor, uma vez que na Analise da Cotacao,
				// o sistema ira checar se o fornecedor esta cadastrado, caso nao esteja, sera solicitado o cadastro antes da geracao do pedido de compras.
				IF Empty(oModFor:GetValue("C8_FORNOME")) .And. !(oModFor:IsDeleted(nF))
		            Help("",1,"VERIFICAR",,STR0016,4,1) // Nome do fornecedor.
		            lRet := .F.
                EndIf
              
              //VERIFICA SE O FORNECEDOR ESTÁ BLOQUEADO
              If !Empty(oModFor:GetValue("C8_FORNECE"))
              	DBSelectArea("SA2")
               	DbSetOrder(1)
               	SA2->(DBSeek(xFilial("SA2")+oModFor:GetValue("C8_FORNECE")+oModFor:GetValue("C8_LOJA")))
                If lRet .And. !RegistroOk("SA2")
                 	lRet := .F.
                EndIf
              EndIf
								
			Next nF	
		End//Next nP
	Next nG
EndIf
		
oModGrp:GoLine(nL1)
oModPro:GoLine(nL2)
oModFor:GoLine(nL3)

RestArea(aArea)
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} a131GrvMVC(oModel)
Rotina que efetua a gravação do modelo.

@author alexandre.gimenez
@since 28/10/2013
@version 1.0
/*/
//------------------------------------------------------------------
Static Function a131GrvMVC(oModel,aSCs,cNumCot,nSaveSX8)
Local aArea 	:= GetArea()
Local lRet		:= .F. 
Local lClicInt:= A131VerInt()
Local lRegClic:= .F.
Local nSC1		:= 0
Local nSC2		:= 0
Local cChaveRat:= ""
Local lLog 		:= GetNewPar("MV_HABLOG",.F.)
Local nLastRecno:= 0 //Guarda o último recno do processo para envio de e-mail.

Local lEnvCot	:= SuperGetMV("MV_ENVCOT")
Local aItens	:= {}
Local aForns	:= {}
Local aCots	:= {}
/* aCots 	[x]
			[x,1] 			- Num. Cotação.
			[x,2] 			- Data Emissão.
			[x,3,y] 		- Array de Fornecedores (aForns).
			[x,3,y,1]		- Cod.  Fornecedor.
			[x,3,y,2]		- Loja  Fornecedor.
			[x,3,y,3]		- eMail Fornecedor.
			[x,3,y,4,z]	- Array de Itens por Fornecedor (aItens).
			[x,3,y,4,z,1]	- Cod. Produto.
			[x,3,y,4,z,2] - Quantidade.
			[x,3,y,4,z,3]	- Prazo de entrega.
*/
Local nFind	:= 0
Local nFindF	:= 0
Local nCPos	:= 1
Local nI		:= 0
Local nJ		:= 0
Local cBody	:= 0

//----------------------------
// Grava o Modelo de Dados
//----------------------------
BEGIN TRANSACTION 
	IF FwFormCommit(oModel)	
		//----------------------------------
		// Confirma a utilizacao do SX8                                            
		//----------------------------------
		While ( GetSX8Len() > nSaveSX8 )
			ConfirmSx8()
		EndDo	
		//-----------------------------
		// Atualiza SC1
		//-----------------------------
		DbSelectArea("SC1")
		DbSetorder(1)
		For nSC1:= 1 to len(aSCs)
			For nSC2:= 1 to Len(aSCs[nSC1][2])
				If SC1->(DBSeek(xFilial("SC1")+aSCs[nSC1][2][nSC2]))
					RecLock("SC1",.F.)
						SC1->C1_COTACAO := cNumCot
						SC1->C1_IDENT   := aSCs[nSC1][1]

						If lLog
							//Caio.Santos - 11/01/13 - Req.72
							RSTSCLOG("COT",1,/*cUser*/)					
						EndIf					

						MaAvalSC("SC1",4)
						//--------------------------------------------------------------------
					MsUnlock()
					lRegClic:= .T.
				EndIf
				Next nSC2
		Next nSC1		

		EndIf
		 cCotNum := cNumCot
		 	
	lRet:= .T.
	//Grava tipo de documento na cotação
	SC8->(dbSetOrder(4))
	SC8->(dbSeek(xFilial("SC8")+cNumCot))
	While !SC8->(Eof()) .AND. SC8->C8_NUM == cNumCot
		RecLock("SC8",.F.)
		SC8->C8_TPDOC := CvalToChar(MV_PAR17)
		
		//Atualiza itens que foram replicados, que estão sem o numero e item da SC 
		If Empty(SC8->C8_NUMSC)
			For nSC1:= 1 to len(aSCs)
				If aSCs[nSC1,1] == SC8->C8_IDENT
					If SC1->(DBSeek(xFilial("SC1")+aSCs[nSC1,2,1]))
						SC8->C8_NUMSC := SC1->C1_NUM
						SC8->C8_ITEMSC:= SC1->C1_ITEM
						Exit
					EndIf
				EndIf
			Next nSC1		
		EndIf	
		
		//- Preeche array contendo informações para gerar e-mail solicitando cotação.
		If lEnvCot .AND. !Empty(SC8->C8_FORMAIL)
			aItens := {}
			aAdd(aItens,allTrim(SC8->C8_PRODUTO))
			aAdd(aItens,SC8->C8_QUANT)
			aAdd(aItens,SC8->C8_PRAZO)
			aAdd(aItens,SC8->C8_ITEM)
						
			aForns := {}
			aAdd(aForns,SC8->C8_FORNECE)
			aAdd(aForns,SC8->C8_LOJA)
			aAdd(aForns,allTrim(SC8->C8_FORMAIL))
			aAdd(aForns,{})
			aAdd(aForns[4],aItens)

			nFind := aScan(aCots,{|x| x[1] == SC8->C8_NUM })

			If  nFind == 0
				aAdd(aCots,{})
				aAdd(aCots[nCPos],allTrim(SC8->C8_NUM))
				aAdd(aCots[nCPos],SC8->C8_EMISSAO)
				aAdd(aCots[nCPos],{})
				aAdd(aCots[nCPos][3],aForns)
				nCPos++
			Else
				nFindF := aScan(aCots[nFind][3],{|x| x[1] + x[2] == SC8->C8_FORNECE + SC8->C8_LOJA})
				If nFindF == 0
					aAdd(aCots[nFind][3],aForns)
				Else
					aAdd(aCots[nFind][3][nFindF][4],aItens)
				EndIf
			EndIf
		EndIf
		MsUnlock()
		nLastRecno := SC8->(Recno())
		SC8->(dbSkip())
	EndDo

	//Envio de e-mail - Event Messenger 003
	If nLastRecno > 0
		SC8->(MsGoto(nLastRecno))
		MaAvalCOT("SC8",1,,,,,.T.)
		SC8->(DbSkip())
	Endif 
	
	If lEnvCot .And. File("samples/wf/MATA131_Mail001.html")
		For nI := 1 To Len(aCots)
			For nJ := 1 to Len(aCots[nI][3])
				If !Empty(aCots[nI][3][nJ][3])
					cBody := A131GerMail(aCots[nI][1],aCots[nI][2],aCots[nI][3][nJ])
					MTSendMail({aCots[nI][3][nJ][3]},OemToAnsi(STR0001),cBody)
				EndIf
			Next nJ
		Next nI
	EndIf

	//Integração com ClicBusinnes
	If lRet .And. lClicInt .And. lRegClic
		A311RegCot(cNumCot,1)
	Endif
END TRANSACTION

RestArea(aArea)
Return lRet


//----------------------------------------------------------------------
// Migração do Fonte MATa131, disponibilizado no release 11.9			 |
// Atualização efetuada em 30/10/12										 |
//----------------------------------------------------------------------


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ MATA131  ³ Autor ³  Edson Maricate       ³ Data ³ 01.09.98  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Monta o arquivo de cotacoes a partir das solicitacoes de     ³±±
±±³          ³compra em aberto.                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function MATA131(lTrm)

Local aArea		 := GetArea()
Local aCores     := {}
Local aCoresNew  := {}
Local aGrupo	 := {}
Local cGrupComp  := ""
Local cFiltroSC1 := ""
Local cQueryGrp	 := ""
Local lTpDoc	 := SuperGetMv("MV_TPOPDOC",.F.,.F.)
Local nCntFor	 := 0
Local nX         := 0    
Local lFiltra	 := .F.
Local lContinua  := a131CHKCPO()  //Verifica tamanho dos campos de prazo de entrega
Local aFiltra    := {}
Local oFWFilter	:= Nil
local aColunas	:= {}
Local lCotFil    := SuperGetMv("MV_COTFILT",.T.,.T.) 
Local xAuxFil    := Nil

Static aCotMark  := {} 

PRIVATE aRotina   := MenuDef()
PRIVATE aRecMark  := {}
PRIVATE cQuerySC1	 := ""
PRIVATE cCadastro := STR0001  // "Solicita‡”es"
PRIVATE cMarca    := GetMark()
PRIVATE lInverte  := .F.
PRIVATE lMultCot  := GetNewPar("MV_MULTCOT",.F.) // Ativa o Uso da Cotacao MultUsuario permitindo que mais de um usuario utilize a rotina simultaneamente

DEFAULT lTrm := .F.  

DbSelectArea("SA5")
DbCloseArea()

If lContinua
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Especifico para Integracao com modulo de Gestao de Contratos ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aAdd(aCores,{'C1_FLAGGCT=="1"' , 'LIGHTBLU'})	//SC Totalmente Atendida pelo SIGAGCT
	
	aAdd(aCores,{'!Empty(C1_RESIDUO)'													 ,'BR_PRETO'  })//SC Eliminada por Residuo
	aAdd(aCores,{'C1_QUJE==0.And.C1_COTACAO==Space(Len(C1_COTACAO)).And.C1_APROV$" ,L"'	 ,'ENABLE'	  })//SC em Aberto
	aAdd(aCores,{'C1_QUJE==0.And.C1_COTACAO==Space(Len(C1_COTACAO)).And.C1_APROV="R"' 	 ,'BR_LARANJA'})//SC Rejeitada
	aAdd(aCores,{'C1_QUJE==0.And.C1_COTACAO==Space(Len(C1_COTACAO)).And.C1_APROV="B"' 	 ,'BR_CINZA'  })//SC Bloqueada
	aAdd(aCores,{'C1_QUJE==C1_QUANT'													 ,'DISABLE'	  })//SC com Pedido Colocado
	aAdd(aCores,{'C1_QUJE>0'															 ,'BR_AMARELO'})//SC com Pedido Colocado Parcial
	aAdd(aCores,{'C1_QUJE==0.And.C1_COTACAO<>Space(Len(C1_COTACAO)).And. C1_IMPORT <>"S"','BR_AZUL'	  })//SC em Processo de Cotacao
	aAdd(aCores,{'C1_QUJE==0.And.C1_COTACAO<>Space(Len(C1_COTACAO)).And. C1_IMPORT =="S"','BR_PINK'	  })//SC com Produto Importado
	
	If ExistBlock("MT131COR")
		aCoresNew := ExecBlock("MT131COR",.F.,.F.,{aCores})
		If ValType(aCoresNew) == "A"
			aCores := aCoresNew
		EndIf
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Carrega as perguntas selecionadas                            ³
	//³                                                              ³
	//³ mv_par01 // Filtra por data   (S/N)                          ³
	//³ mv_par02 // data de emissao inicial                          ³
	//³ mv_par03 // data de emissao final                            ³
	//³ mv_par04 // dias uteis para calcular data de validade        ³
	//³ mv_par05 // Filtra Solicitacoes ja Geradas (S/N)             ³
	//³ mv_par06 // Amarracao por Produto ou Grupo                   ³
	//³ mv_par07 // Imprime Cotacao (S/N)                            ³
	//³ mv_par08 // Tipo de Cotacao (Aberta/Fechada)                 ³
	//³ mv_par12 // C.Custo inicial                                  ³
	//³ mv_par13 // C.Custo final                                    ³	
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If (Pergunte("MTA130",.T.)) 
	 
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//	PE - Adiciona dados ao filtro                              ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If ExistBlock("MT131FIL")
			xAuxFil := ExecBlock("MT131FIL",.F.,.F.) 
			
			If ValType(xAuxFil) == "C" .And. !Empty(xAuxFil)
				cFiltroSC1 := " .And. " + xAuxFil
			Elseif ValType(xAuxFil) == "A" //Exp ADVPL + SQL
				If !Empty(xAuxFil[1])
					cFiltroSC1	:= " .And. " + xAuxFil[1]
				Endif
				
				If !Empty(xAuxFil[2])
					cQuerySC1	:= " AND " + xAuxFil[2]
				Endif 
			EndIf
		EndIf 
		 
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Avalia se ha necessidade de Filtrar Grupo de Compradores  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If ( SuperGetMv("MV_RESTCOM",.F.,"N")=="S")
			aGrupo := UsrGrComp(RetCodUsr())
			If ( Ascan(aGrupo,"*") == 0 )
				cGrupComp  := " .And. (C1_GRUPCOM=='"+Space(Len(SC1->C1_GRUPCOM))+"'"
				For nCntFor := 1 To Len(aGrupo)
					If nCntFor == 1
						cGrupComp += " .Or. C1_GRUPCOM $ '"+aGrupo[nCntFor]+""						
					Else
						cGrupComp += ","+aGrupo[nCntFor]										
					Endif	
				Next nCntFor
				If Len(aGrupo) > 0
					cGrupComp  += "'"					
				Endif
				cGrupComp  += ")"				

				cQueryGrp:= ' AND C1_GRUPCOM IN(SELECT AJ_GRCOM FROM '+RetSqlName('SAJ') 
				cQueryGrp+= " WHERE AJ_FILIAL='"+xFilial('SAJ')+"' AND AJ_USER='"+RetCodUsr()+"' )"
				
			EndIf
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica se havera necessidade de Filtragem dos Registros para a MarkBrowse ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		lFiltra := ( MV_PAR05==1 .Or. MV_PAR01==1 .Or. !Empty(cFiltroSC1) .Or. !Empty(cGrupComp) .Or. lTrm )
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Posiciona Registros                                                     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea("SC1")
		dbSetOrder(1)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Montagem da Query                                                       ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If ( lFiltra )
			cFiltroSC1+= " .And. C1_FILIAL=='"+xFilial("SC1")+"'"
			cQuerySC1 += " AND C1_FILIAL='"+xFilial("SC1")+"'"
	
			If SC1->(FieldPos("C1_ACCPROC")) > 0
				cFiltroSC1+= " .And. C1_ACCPROC<>'1'"
				cQuerySC1 += " AND C1_ACCPROC<>'1'"
			EndIf
				
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ATENCAO!!!Se for EXPRESS retira o filtro Solicitacao de /ate³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If !__lPyme
				cFiltroSC1+= " .And. C1_NUM >= '"+MV_PAR09+"'"
				cQuerySC1 += " AND C1_NUM >= '"+MV_PAR09+"'"
				cFiltroSC1+= " .And. C1_NUM <= '"+MV_PAR10+"'"
				cQuerySC1 += " AND C1_NUM <= '"+MV_PAR10+"'"
	        EndIf
	
			If ( MV_PAR01==1 ) // Filtra por Data
				cFiltroSC1+= " .And. Dtos(C1_EMISSAO)>='"+Dtos(MV_PAR02)+"'"
				cQuerySC1 += " AND C1_EMISSAO >= '"+Dtos(MV_PAR02)+"'"
				cFiltroSC1+= " .And. Dtos(C1_EMISSAO)<='"+Dtos(MV_PAR03)+"'"
				cQuerySC1 += " AND C1_EMISSAO <= '"+Dtos(MV_PAR03)+"'"
			EndIf
			If ( MV_PAR05==1 )
				cFiltroSC1+= " .And. C1_COTACAO=='"+Space(Len(SC1->C1_COTACAO))+"'.And.C1_QUJE<C1_QUANT.And.C1_TPOP<>'P'.And.C1_APROV$' ,L'"
				cQuerySC1 += " AND C1_COTACAO= '"+Space(Len(SC1->C1_COTACAO))+"' AND C1_QUJE<C1_QUANT AND C1_TPOP<>'P' AND C1_APROV IN(' ','L') "
			EndIf
			If !Empty(MV_PAR12)
				cFiltroSC1+= " .And. C1_CC>='"+MV_PAR12+"'"
				cQuerySC1 += " AND C1_CC >= '"+MV_PAR12+"'"
			EndIf
			If !Empty(MV_PAR13)
				cFiltroSC1+= " .And. C1_CC<='"+MV_PAR13+"'"
				cQuerySC1 += " AND  C1_CC<='"+MV_PAR13+"'"
			EndIf
			cFiltroSC1 += cGrupComp
			cQuerySC1  += cQueryGrp
	
			If lTrm
				cFiltroSC1 += " .And. C1_ORIGEM == 'TRM     ' "
				cQuerySC1  += " AND C1_ORIGEM = 'TRM     ' "
			EndIf                           
			
			// Filtro para desconsiderar itens da solicitacao de compras eliminados por residuo.
			cFiltroSC1 += " .And. C1_RESIDUO <> 'S' "
			cQuerySC1  += " AND C1_RESIDUO <> 'S' "
			
			If ExistBlock("MT130IFC")
				aFiltra := ExecBlock("MT130IFC",.F.,.F.)
				cFiltroSC1 += aFiltra[1]
				cQuerySC1  += aFiltra[2]
			EndIf
			
			//Realiza a Filtragem de todas as SC's empenhadas pelo Modulo do SIGAGCT
			cFiltroSC1 += IIF(Empty(cFiltroSC1),"C1_FLAGGCT <> '1'"," .And. C1_FLAGGCT <> '1'")
			cQuerySC1 += IIF(Empty(cQuerySC1),"C1_FLAGGCT <> '1'"," And C1_FLAGGCT <> '1'")
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Retira o Primeiro .And.                                                 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cFiltroSc1:=SubStr(cFiltroSC1,8)
			cQuerySc1 :=SubStr(cQuerySC1,6)
		Else
			dbSelectArea("SC1")
			MsSeek(xFilial("SC1"))
			
			If ExistBlock("MT130IFR")
				aFiltra := ExecBlock("MT130IFR",.F.,.F.)
				cFiltroSC1 += aFiltra[1]
				cQuerySC1  += aFiltra[2]
			EndIf
		EndIf
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Filtra SC's do tipo Licitacao                                ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cFiltroSC1 += IIf(Empty(cFiltroSC1),"C1_TPSC <> '2'"," .And. C1_TPSC <> '2'")
		cQuerySC1 += IIf(Empty(cQuerySC1),"C1_TPSC <> '2'"," AND  C1_TPSC <> '2'")

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Filtra SC's Firmes quando MV_TPOPDOC ligado                  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lTpDoc
			cFiltroSC1 += " .And. C1_TPOP = 'F' "
			cQuerySC1  += " AND C1_TPOP =  'F' "
		EndIf

		//-- Campos que irao para o filtro
		SX3->(dbSetOrder(1))
		SX3->(dbSeek("SC1"))
		While !SX3->(EOF()) .And. SX3->X3_ARQUIVO == "SC1"
			If (X3Uso(SX3->X3_USADO) .And. cNivel >= SX3->X3_NIVEL) .Or. AllTrim(SX3->X3_CAMPO) == "C1_FILIAL"
				aAdd(aColunas,{ AllTrim(SX3->X3_CAMPO),AllTrim(X3Titulo()),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL,;
								SX3->X3_PICTURE,Str2Arr(SX3->X3_CBOX,";"),SX3->X3_F3})
			EndIf                                
			SX3->(dbSkip())
		End

		If lCotFil
			oFWFilter := FWFilter():New(GetWndDefault())
			oFWFilter:SetSQLFilter()
			oFWFilter:DisableValid()
			oFWFilter:LoadFilter()
			oFWFilter:SaveFilter()
			oFWFilter:SetField(aColunas)
			If oFWFilter:FilterBar() 		
				If !empty(AllTrim(oFwFilter:GetExprSQL()))
					cQuerySC1 += " And " + AllTrim(oFwFilter:GetExprSQL())
					cFiltroSC1 += ".And." + AllTrim(oFwFilter:GetExprAdvpl())
				EndIf
			EndIf
		EndIf

		dbGotop()
				
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Endereca a funcao de MarkBrowse                              ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If ValType(xAuxFil) == "C" .And. !Empty(xAuxFil)
			cQuerySC1 := " "
		EndIf

		If !SC1->(EOF()) .Or. SC1->(FieldPos("C1_COMPRAC")) > 0
			MarkBrow("SC1","C1_OK","(C1_COTACAO+IIf(C1_TPOP=='P'.Or.(C1_APROV$'R,B'),'X',' '))",,lInverte,cMarca,"a131AllMark()",,,,"a131Mark()",,cQuerySC1,,aCores,,,cFiltroSC1)
		Else
			Help(" ",1,"RECNO")
			lContinua := .F.
		EndIf
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³A rotina a seguir varre o Array aRecMark com os registros locados pela  ³
		//³markbrowse quando o MV_MULTCOT estiver ativo para limpar as marcas reali³
		//³zadas no C1_OK de todos os registros marcados pelo usuario.             ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		
		dbSelectArea("SC1") 
	    For nX:=1 To Len(aRecMark) 
			SC1->( dbGoto( aRecMark[nX] ) )   
			IF IsInCallStack("FWMARKBROWSE")
				If IsMark("C1_OK",cMarca)
					If SimpleLock("SC1",.F.)
				        SC1->C1_OK      := Space(Len(SC1->C1_OK))   
						If SC1->(FieldPos("C1_USRCODE")) > 0
							SC1->C1_USRCODE := Space(Len(SC1->C1_USRCODE)) 
						EndIf
						MsUnLock()
			        EndIf
			   EndIf
		    EndIf
	    Next nX 
		SC1->(dbCommit())					
	
		dbSelectArea("SC8")
		dbClearFilter()
		RetIndex("SC8")
	EndIf
EndIf

//Apaga o campo C1_OK caso possua alguma SC marcada e clique no botão fechar cancelando a operação 
If Len(aRecMark) > 0 .And. !Empty(cCancela) 
	For nX := 1 to Len(aRecMark)			
		dbSelectArea("SC1")
		MsGoto(aRecMark[nx])
		If SimpleLock("SC1")
			SC1->C1_OK := " "
		Endif

		SC1->(MsRUnlock())
	Next nX
EndIf 

RestArea(aArea)
Return(Nil)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³A131AllMark³ Autor ³Alexandre Inacio Lemes³ Data ³13/06/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Utilizada pela MarkBrowse para marcar os itens             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATa131                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function A131AllMark()

Local aArea  	:= GetArea()
Local lMarca 	:= Nil
Local nRecnoSC1	:= 0
Local lUSRCODE	:= SC1->(FieldPos("C1_USRCODE")) > 0
Local lAviso	:= .F.
Local aRecSC1	:= {}
Local cFilSC1	:= xFilial("SC1")
Local nI		:= 0

dbSelectArea("SC1") 
If SC1->(dbSeek(cFilSC1))
	While SC1->(!Eof()) .And. SC1->C1_FILIAL == cFilSC1
		aAdd(aRecSC1,SC1->(Recno()))
		SC1->(DbSkip())
	EndDo
EndIf

If Len(aRecSC1) > 0
	For nI := 1 To Len(aRecSC1)
		nRecnoSC1 := aRecSC1[nI]
		SC1->(DbGoto(nRecnoSC1))

		lMarca := (SC1->C1_OK == cMarca)

		If !lMultCot
			If RecLock("SC1",.F.)
				SC1->C1_OK := Iif( lMarca,Space(Len(SC1->C1_OK)),cMarca )
				SC1->(MsUnLock())
			Endif	
		Else
			lAviso := .F.
			If SimpleLock("SC1",.F.)
				If RecLock("SC1",.F.)
					SC1->C1_OK := Iif( lMarca,Space(Len(SC1->C1_OK)),cMarca )

					If lUSRCODE
						SC1->C1_USRCODE := Iif(!Empty(SC1->C1_OK) , RetCodUsr() , Space(Len(SC1->C1_USRCODE)) )
					EndIf

					SC1->(MsUnLock())
				Endif			
			Else
				If !Empty(SC1->C1_OK) .And. lUSRCODE
					Aviso("A130NOMARK", STR0048 + "(" + SC1->C1_NUM + ") " + SC1->C1_USRCODE + " " + UsrRetName(SC1->C1_USRCODE),{"Ok"},1) //"Este Registro ja foi marcado e esta sendo utilizado pelo usuario "
					lAviso := .T.
				Else
					Aviso("A130NOLOCK", STR0047 + "(" + SC1->C1_NUM + ")",{"Ok"},1) //"Este Registro esta sendo utilizado por outro processo de atualização no momento e não podera ser marcado."
					lAviso := .T.
				EndIf
			Endif
		Endif

		If !lAviso
			A131ATUCOTREC(lMarca,nRecnoSC1)
		Endif
	Next nI
Endif

RestArea(aArea)
MarkBRefresh()

Return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} A131ATUCOTREC()
Atualiza array aCotMark e aRecMark com as seleção das cotações.
@author rodrigo.mpontes
@since 20/11/2020
@version 1.0
@return NIL
/*/
//-------------------------------------------------------------------

Static Function A131ATUCOTREC(lMarca,nRecnoSC1)

Local nPos	:= 0

nPos := aScan(aCotMark,{|x| x == nRecnoSC1})
If !lMarca
	If nPos == 0
		AAdd( aCotMark, nRecnoSC1 )
	Endif
Else
	If nPos > 0
		ADEL( aCotMark, nPos )
		ASIZE( aCotMark, Len(aCotMark)-1 )
	Endif
Endif

nPos := aScan(aRecMark,{|x| x == nRecnoSC1})
If !lMarca 
	If nPos == 0
		AAdd( aRecMark, nRecnoSC1 )
	Endif
Else
	If nPos > 0
		ADEL( aRecMark, nPos )
		ASIZE( aRecMark, Len(aRecMark)-1 )
	Endif
Endif

Return 

//-------------------------------------------------------------------
/*/{Protheus.doc} A131CleanMark()
Ao finalizar geração da cotação, SC e array aCotMark e aRecMark devem
ser atualizados para não gerar conflitos nas proximas gerações.

@author rodrigo.mpontes
@since 24/03/2021
@version P12
/*/
//-------------------------------------------------------------------

Static Function A131CleanMark()

Local nI		:= 0
Local cSeekSC1	:= 0
Local lUSRCODE	:= SC1->(FieldPos("C1_USRCODE")) > 0
Local lGrade	:= MaGrade()
Local aClean	:= aClone(aCotMark)

For nI := 1 To Len(aClean)
	SC1->(DbGoto(aClean[nI]))
	
	cSeekSC1	:= SC1->C1_FILIAL+SC1->C1_NUM+SC1->C1_ITEM

	If lMultCot
		If SimpleLock("SC1",.F.)
			If RecLock("SC1",.F.)
				SC1->C1_OK := Space(Len(SC1->C1_OK))
				
				If lUSRCODE
					SC1->C1_USRCODE := Space(Len(SC1->C1_USRCODE))
				EndIf

				A131ATUCOTREC(.T.,aClean[nI])
				SC1->(MsUnlock())
			Endif
				
			If lGrade
				dbSelectArea("SC1")
				SC1->(dbSetOrder(1))
				If SC1->(MsSeek(cSeekSC1,.F.))
					Do While SC1->(!Eof()) .And. cSeekSC1 == SC1->C1_FILIAL+SC1->C1_NUM+SC1->C1_ITEM
						If !(aClean[nI] == SC1->(Recno()))
							If SimpleLock("SC1",.F.)
								If RecLock("SC1",.F.)
									SC1->C1_OK := Space(Len(SC1->C1_OK))
									
									If lUSRCODE
										SC1->C1_USRCODE := Space(Len(SC1->C1_USRCODE))
									Endif
									SC1->(MsUnlock())
								Endif
								A131ATUCOTREC(.T.,SC1->(Recno()))
							EndIf
						EndIf
						SC1->(dbSkip())
					Enddo
				EndIf
			EndIf
		Endif
	Else
		If RecLock("SC1",.F.)
			SC1->C1_OK := Space(Len(SC1->C1_OK))
			SC1->(MsUnLock())
		Endif

		A131ATUCOTREC(.T.,aClean[nI])

		If lGrade
			dbSelectArea("SC1")
			SC1->(dbSetOrder(1))
			If SC1->(MsSeek(cSeekSC1,.F.))
				Do While SC1->(!Eof()) .And. cSeekSC1 == SC1->C1_FILIAL+SC1->C1_NUM+SC1->C1_ITEM
					If !(aClean[nI] == SC1->(Recno()))
						If Reclock("SC1", .F.)
							SC1->C1_OK := Space(Len(SC1->C1_OK))
							SC1->(MsUnlock())
						Endif
						A131ATUCOTREC(.T.,SC1->(Recno()))
					EndIf
					SC1->(dbSkip())
				Enddo
			EndIf
		Endif
	Endif
Next nI

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ A131Mark  ³ Autor ³Alexandre Inacio Lemes³ Data ³13/06/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Utilizada pela MarkBrowse para marcar os itens             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATa131                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function A131Mark()

Local aArea   	:= GetArea()
Local cSeekSC1	:= SC1->C1_FILIAL+SC1->C1_NUM+SC1->C1_ITEM
Local nRecno  	:= SC1->(Recno())
Local lUSRCODE	:= SC1->(FieldPos("C1_USRCODE")) > 0
Local lMarca 	:= Nil
Local lGrade	:= MaGrade()
 
If lMultCot
	//Codigo para tratamento da marca e lock de registros para versao Multi-Usuario
	SC1->(dbGoTo(nRecno))
	
	lMarca := (SC1->C1_OK == cMarca)

	If SimpleLock("SC1",.F.)
		If RecLock("SC1",.F.)
			SC1->C1_OK := Iif( lMarca, Space(Len(SC1->C1_OK)), cMarca )
		
			If lUSRCODE
				SC1->C1_USRCODE := Iif(!Empty(SC1->C1_OK) , RetCodUsr() , Space(Len(SC1->C1_USRCODE)) )
			EndIf

			A131ATUCOTREC(lMarca,nRecno)
			SC1->(MsUnlock())
		Endif
		
		If lGrade
			dbSelectArea("SC1")
			SC1->(dbSetOrder(1))
			If SC1->(MsSeek(cSeekSC1,.F.))
				Do While SC1->(!Eof()) .And. cSeekSC1 == SC1->C1_FILIAL+SC1->C1_NUM+SC1->C1_ITEM
					If !(nRecno == SC1->(Recno()))
						If SimpleLock("SC1",.F.)
							If RecLock("SC1",.F.)
								SC1->C1_OK := Iif( lMarca, Space(Len(SC1->C1_OK)), cMarca )
								
								If lUSRCODE
									SC1->C1_USRCODE := Iif(!Empty(SC1->C1_OK) , RetCodUsr() , Space(Len(SC1->C1_USRCODE)) )
								Endif
								SC1->(MsUnlock())
							Endif
							A131ATUCOTREC(lMarca,SC1->(Recno()))
						EndIf
					EndIf
					SC1->(dbSkip())
				Enddo
			EndIf
		EndIf				
	Else		
		If !Empty(SC1->C1_OK) 
			Aviso("a131NOMARK", STR0048 + SC1->C1_USRCODE + " " + UsrRetName(SC1->C1_USRCODE),{"Ok"},1) //"Este Registro ja foi marcado e esta sendo utilizado pelo usuario "
		Else
			Aviso("a131NOLOCK", STR0047 ,{"Ok"},1) //"Este Registro esta sendo utilizado por outro processo de atualização no momento e não podera ser marcado."
		EndIf		
	EndIf
Else
	SC1->(dbGoTo(nRecno))
	//Codigo para tratamento da marca e lock de registros para versao Mono-Usuario

	lMarca := (SC1->C1_OK == cMarca)

	If RecLock("SC1",.F.)
		SC1->C1_OK := Iif( lMarca, Space(Len(SC1->C1_OK)), cMarca )
		SC1->(MsUnLock())
	Endif

	A131ATUCOTREC(lMarca,nRecno)

	If lGrade
		dbSelectArea("SC1")
		SC1->(dbSetOrder(1))
		If SC1->(MsSeek(cSeekSC1,.F.))
			Do While SC1->(!Eof()) .And. cSeekSC1 == SC1->C1_FILIAL+SC1->C1_NUM+SC1->C1_ITEM
				If !(nRecno == SC1->(Recno()))
					If Reclock("SC1", .F.)
						SC1->C1_OK := Iif( lMarca, Space(Len(SC1->C1_OK)), cMarca )
						SC1->(MsUnlock())
					Endif
					A131ATUCOTREC(lMarca,SC1->(Recno()))
				EndIf
				SC1->(dbSkip())
			Enddo
		EndIf
	Endif		
EndIf

RestArea(aArea)
MarkBRefresh()

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³A131Lock  ³ Autor ³Ben-Hur M.Castilho     ³ Data ³ 19.05.99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Tratamento do Bloqueio da Geracao das Cotacoes              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpL1: Indica se a operacao eh de bloqueio ou nao           ³±±
±±³          ³ExpA2: Locks dos grupos de compra                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpL1: Indica se foi possivel efetuar o travamento          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function A131Lock( lTrava , aLocks )

Local aArea		:= GetArea()
Local aGrupos   := {}
Local lRetorno  := .F.
Local nLimite   := 0
Local nX        := 0


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica o parametro de restricao de compradores                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Empty(aGrupos) .And. SuperGetMv("MV_RESTCOM")=="S" .And. lTrava
	aGrupos := UsrGrComp(RetCodUsr())
Else
	If !lTrava
		aGrupos := aLocks
	EndIf
EndIf

If Empty(aGrupos)

	If lTrava
		While !lRetorno .And. nLimite <= 5 
			lRetorno := MsRLock()
			If ( !lRetorno )
				nLimite++
				Inkey(nLimite)
			EndIf
		EndDo
		If ( !lRetorno )
			HELP(" ",1,"a131NGERA")
		EndIf
	Else
		MsRUnLock()
	EndIf
Else
	If lTrava
		For nX := 1 To Len(aGrupos)
			If LockByName("MATa131LOCKCT"+aGrupos[nX],.T.,!Empty(xFilial("SC1")),.T.)
				aadd(aLocks,"MATa131LOCKCT"+aGrupos[nX])
				lRetorno := .T.
			Else
				HELP(" ",1,"a131NGERA")
				For nX := 1 To Len(aLocks)
					UnLockByName(aLocks[nX],.T.,!Empty(xFilial("SC1")),.T.)
				Next nX
				lRetorno := .F.
				nX := Len(aGrupos) + 1
			EndIf
		Next nX
	Else
		For nX := 1 To Len(aLocks)
			UnLockByName(aLocks[nX],.T.,!Empty(xFilial("SC1")),.T.)
		Next nX
	EndIf
EndIf

RestArea(aArea)
Return( lRetorno )

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³A131Gera  ³ Autor ³Edson Maricate         ³ Data ³01.09.98  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Gera Cotacoes atraves da Solicitacoes marcadas              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cExpC1: Alias do Arquivo                                    ³±±
±±³          ³cExpC2: Campo do Arquivo                                    ³±±
±±³          ³cExpN3: Opcao selecionada                                   ³±±
±±³          ³cExpC4: Marca realizada no campo                            ³±±
±±³          ³cExpL5: Indica se a marca esta invertida                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function A131Gera(cAlias,cCampo,nOpcE,cMarca,lInverte)

Local aArea		  := GetArea()
Local aLocks      := {}
Local dValidade	  := dDataBase
Local nFornec	  := 0
Local nDiasVal    := MV_PAR04
Local nAmarracao  := MV_PAR06
Local nUltForn 	  := 0
Local nX          := 0
Local lRelatorio  := MV_PAR07 == 1
Local lContinua	  := .T.
Local la131Lock   := .T.
Local aAreaSC1	  := {}
Local cFilSC1	  := ""

If lContinua .And. Len(aCotMark) > 0
	aAreaSC1 := SC1->(GetArea())
	For nX := 1 to Len(aCotMark)
		SC1->(DbGoto(aCotMark[nX]))
		If Empty(cFilSC1)
			cFilSC1 := SC1->C1_FILIAL
		Else
			If cFilSC1 <> SC1->C1_FILIAL
				Help("",1,"A131GERFIL1",,STR0132,1,1) //"Para geração da cotação, selecione solicitações de compras de uma filial por vez."
				lContinua := .F.
				Exit
			Endif
		Endif
	Next nX

	If lContinua .And. !Empty(cFilSC1) .And. cFilSC1 <> xFilial("SC1")
		Help("",1,"A131GERFIL2",,STR0133,1,1) //"Mantenha posicionado na filial da SC que sera gerada a cotação."
		lContinua := .F.
	Endif

	RestArea(aAreaSC1)
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Quando nao estiver sendo utilizado o recurso de Multiusuario mantem o   ³
//³controle de semaforo padrao utilizado antes da implementacao do         ³
//³MV_MULTCOT.                                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !lMultCot
	la131Lock :=( a131Lock(.T.,@aLocks) )
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se nenhum outro usuario esta gerando cotacao.                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If la131Lock   

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Calcula a Data de Validade da Cotacao descontando Sab/Dom e Feriados³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	While nDiasVal > 0

        dValidade ++

		dValida := DataValida(dValidade)

        If dValida == dValidade
			nDiasVal--
        EndIf
        
	EndDo

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica se o usuario pode selecionar fornecedores                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Len(aCotMark) > 0 .Or. Len(aRecMark) > 0
		If ( GetMv("MV_SELFOR",.F.,"N")="S" )
			While ( lContinua )
				If ( Pergunte("MTA131",.T.) )
					If ( MV_PAR01 < MV_PAR02 )
						Help(" ",1,"a130SELE")
					Else
						Exit
					EndIf
				Else
					lContinua := .F.
					Exit
				EndIf
			EndDo
	
			nFornec	 := MV_PAR01
			nUltForn 	 := MV_PAR02
	
		EndIf
	Else
		lContinua := .F.
	EndIf	
	
	If lContinua
		//-FSW-Ponto de Entrada criado para realizar validacoes nas selecoes feitas pelo usuario
		If ExistBlock("MT131VAL")
			lContinua := ExecBlock("MT131VAL",.F.,.F.,{cMarca,cQuerySC1}) 
		EndIf
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Inicia o Processamento de geracao das cotacoes                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lContinua
		Processa({|lEnd| a131Proces(nAmarracao,nFornec,nUltForn,dValidade,lRelatorio)})
	EndIf	

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Desbloqueia a geracao de Cotacao                                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !lMultCot
		a131Lock(.F.,aLocks)
    Endif
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³A rotina a seguir varre o Array aRecMark com os registros locados pela  ³
	//³markbrowse quando o MV_MULTCOT estiver ativo para limpar as marcas reali³
	//³zadas no C1_OK de todos os registros marcados pelo usuario.             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	a131CleanMark()
EndIf

RestArea(aArea)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Caso nenhuma ordem esteja selecionada, seleciona a ordem 1   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Empty( SC1->( IndexOrd() ) )
	SC1->( dbSetOrder( 1 ) )
EndIf

Return(Nil)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³a131Proces³ Autor ³Eduardo Riera          ³ Data ³19.05.99  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Rotina de processamento da solicitacoes de compra que devem ³±±
±±³          ³gerar cotacao.                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpN1: 1 - Produto | 2 - Grupo ( Gera Cotacao por ? )       ³±±
±±³          ³ExpN2: Numero de Fornecedores                               ³±±
±±³          ³ExpN3: Numero de Fornecimentos                              ³±±
±±³          ³ExpD4: Data de Validade da Cotacao                          ³±±
±±³          ³ExpL5: Indicador de exibicao dos relatorios                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function a131Proces(nAmarracao,nFornec,nUltForn,dValidade,lRelatorio)

Local aArea		:= GetArea()
Local aAreaSC1  := SC1->(GetArea())
Local aStruSC1  := SC1->(dbStruct())
Local aRegSC	:= {}
Local aSC8Num	:= {}
Local aSc1It  := {}
Local aQuebra   := {}
Local aScMono   := {}
Local aReplForn := {}
Local aErros    := {}

Local bQuebra	:= {|| C1_FILENT+C1_GRADE+C1_FORNECE+C1_LOJA+C1_PRODUTO+C1_DESCRI+Dtos(C1_DATPRF)+C1_CC+C1_CONTA+C1_ITEMCTA+C1_CLVL+C1_RATEIO}

Local cFilQry	:= cQuerySC1
Local cAliasSC1 := "SC1"
Local cAliasSC8 := "SC8"
Local cQuery	:= ""
Local cIndex	:= ""
Local cKey		:= ""
Local cQuebra	:= ""
Local cNumCot	:= ""
Local cItem		:= ""
Local cIdent	:= ""
Local cNumScs   := ""

Local nX        := 0
Local nY		  := 0
Local nZ		  := 0
Local nI        := 0
Local nIndex	:= 0
Local nQtdSC	:= 0
Local nQtdSC2 := 0
Local nCntFor	:= 0
Local nRegSC8   := 0
Local nScan     := Nil  

Local lMta131Sk := ExistBlock("MTA131SK")
Local lProcessa	:= .F.
Local lLast     := .F.
Local lPrdxForn := .T.   
Local lNumCot   := .F.
Local lReplica  := .F.
Local lControle := .T.
Local lContinua := .T.
Local lClicB	  := A131VerInt()

Local cKey130   := ''
Local lCotRatP  := SuperGetMv("MV_COTRATP",.F.,.F.)
Local lSelFor	:= If(SuperGetMv("MV_SELFOR",.F.,"N")="S",.T.,.F.) 
Local oModel  	:= FWLoadModel( "MATA131" )	
Local oModGrp		:= oModel:GetModel('SBMDETAIL')
Local oModTmp		:= oModel:GetModel('TMPDETAIL')
Local oModCot		:= oModel:GetModel('SC8DETAIL')
Local oModPrd		:= oModel:GetModel('SC1DETAIL')
Local lQuebrou		:= .F.

Local lGravou		:= .F.
Local lPimsInt      := .F.

PRIVATE aGrade     := {{"","","0000","000","0000"}}
PRIVATE aFirstIdent:= {}
PRIVATE cCotNum	:= "" //número da cotação

If SuperGetMv("MV_PIMSINT",.F.,.F.) .and. SC1->(FieldPos("C1_NRBPIMS")) > 0
	lPimsInt      := .T.
Endif

If mv_par15 == 1		// Considera C1_OP na quebra?
	If !lPimsInt 
		bQuebra := {|| C1_FILENT+C1_GRADE+C1_FORNECE+C1_LOJA+C1_PRODUTO+C1_DESCRI+Dtos(C1_DATPRF)+C1_CC+C1_CONTA+C1_ITEMCTA+C1_CLVL+C1_RATEIO+C1_OP}
	Else
		bQuebra := {|| C1_FILENT+C1_GRADE+C1_FORNECE+C1_LOJA+C1_PRODUTO+C1_DESCRI+Dtos(C1_DATPRF)+C1_CC+C1_CONTA+C1_ITEMCTA+C1_CLVL+C1_RATEIO+C1_OP+C1_NUM+C1_ITEM}		
	Endif
Else
	If !lPimsInt 
		bQuebra := {|| C1_FILENT+C1_GRADE+C1_FORNECE+C1_LOJA+C1_PRODUTO+C1_DESCRI+Dtos(C1_DATPRF)+C1_CC+C1_CONTA+C1_ITEMCTA+C1_CLVL+C1_RATEIO}
	Else
		bQuebra := {|| C1_FILENT+C1_GRADE+C1_FORNECE+C1_LOJA+C1_PRODUTO+C1_DESCRI+Dtos(C1_DATPRF)+C1_CC+C1_CONTA+C1_ITEMCTA+C1_CLVL+C1_RATEIO+C1_NUM+C1_ITEM}
	Endif
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Ponto de Entrada que permite incluir um bloco de código que realizará   ³
//as quebras das solicitações de compras.                                  ³  
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock("MA131QSC")
	bQuebra := ExecBlock("MA131QSC",.F.,.F.,{bQuebra})
	If ValType(bQuebra)#"B"
		If !lPimsInt 	
			bQuebra := {|| C1_FILENT+C1_GRADE+C1_FORNECE+C1_LOJA+C1_PRODUTO+C1_DESCRI+Dtos(C1_DATPRF)+C1_CC+C1_CONTA+C1_ITEMCTA+C1_CLVL+C1_RATEIO}
		Else
			bQuebra := {|| C1_FILENT+C1_GRADE+C1_FORNECE+C1_LOJA+C1_PRODUTO+C1_DESCRI+Dtos(C1_DATPRF)+C1_CC+C1_CONTA+C1_ITEMCTA+C1_CLVL+C1_RATEIO+C1_NUM+C1_ITEM}
		Endif	
	EndIf
Else 
	If lCotRatP
		If !lPimsInt 	
			bQuebra := {|| C1_FILENT+C1_GRADE+C1_FORNECE+C1_LOJA+C1_PRODUTO+C1_DESCRI+Dtos(C1_DATPRF)}
		Else
			bQuebra := {|| C1_FILENT+C1_GRADE+C1_FORNECE+C1_LOJA+C1_PRODUTO+C1_DESCRI+Dtos(C1_DATPRF)+C1_NUM+C1_ITEM}
		Endif
	Endif
Endif


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica a melhor ordem de processamento                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ThisInv() 
	cKey := "C1_FILIAL+C1_GRADE+C1_FORNECE+C1_LOJA+C1_PRODUTO+C1_DESCRI+DTOS(C1_DATPRF)+C1_CC+C1_CONTA+C1_ITEMCTA+C1_CLVL+C1_RATEIO+C1_FILENT"
Else
	cKey := "C1_FILIAL+C1_OK+C1_GRADE+C1_FORNECE+C1_LOJA+C1_PRODUTO+C1_DESCRI+DTOS(C1_DATPRF)+C1_CC+C1_CONTA+C1_ITEMCTA+C1_CLVL+C1_RATEIO+C1_FILENT"
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Ponto de Entrada para ajustar a chave de ordenacao para usar em conjunto³
//³com o PE  MA131QSC                                   					 ³  
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock("MA131KEY")
	cKey130 := ExecBlock("MA131KEY",.F.,.F.,{cKey})
	If ValType(cKey130)=="C"
		cKey    := cKey130
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Monta a Query para Processamento das SCs                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

cQuery += "SELECT SC1.*,SC1.R_E_C_N_O_ SC1RECNO, "
cQuery += "CASE C1_GRADE WHEN 'S' THEN B4_GRUPO ELSE B1_GRUPO END GRUPO "
cQuery += "FROM "+RetSqlName("SC1")+" SC1 "

cQuery += "JOIN "+RetSqlName("SB1")+ " SB1 ON SB1.D_E_L_E_T_ = ' ' AND SB1.B1_FILIAL = '"+xFilial("SB1") +"'"
cQuery += " AND SB1.B1_COD = SC1.C1_PRODUTO "

cQuery += "LEFT JOIN "+RetSqlName("SBM")+" SBM ON SBM.D_E_L_E_T_ = ' ' AND SBM.BM_FILIAL = '"+xFilial("SBM")+"'"
cQuery += " AND SBM.BM_GRUPO = SB1.B1_GRUPO "

cQuery += "LEFT JOIN "+RetSqlName("SB4")+" SB4 ON SB4.D_E_L_E_T_ = ' ' AND SB4.B4_FILIAL = '"+xFilial("SB4") +"'"
cQuery += " AND SB4.B4_COD = CASE C1_GRADE WHEN 'S' "
cQuery += " THEN SUBSTRING(C1_PRODUTO,1,"+ SubStr(SuperGetMv("MV_MASCGRD",.F.,"11,02,02"),1,At(",",SuperGetMv("MV_MASCGRD",.F.,"11,02,02"))-1)+ ")"
cquery += " ELSE ' ' END "

cQuery += "WHERE "+cFilQry
If ( Empty(cFilQry) )
	cQuery += " C1_FILIAL='"+xFilial("SC1")+"'"
	If SC1->(FieldPos("C1_ACCPROC")) > 0
		cQuery += " AND C1_ACCPROC <> '1'"
	EndIf
EndIf
If ( ValType(MV_PAR01)=="N" .And. ValType(MV_PAR02)=="D" .And. ValType(MV_PAR03)=="D" )
	If ( MV_PAR01==1 ) // Filtra por Data
		cQuery += " AND C1_EMISSAO >= '"+Dtos(MV_PAR02)+"'"
		cQuery += " AND C1_EMISSAO <= '"+Dtos(MV_PAR03)+"'"
	EndIf
EndIf
If ( !"C1_COTACAO"$cFilQry )
	cQuery += " AND C1_COTACAO = '"+Space(Len(SC1->C1_COTACAO))+"'"
	cQuery += " AND C1_QUJE < C1_QUANT"
	cQuery += " AND C1_TPOP <> 'P' "
	cQuery += " AND C1_APROV IN('L',' ') "
EndIf
If ( !ThisInv() )
	cQuery += " AND C1_OK = '"+ThisMark()+"'"
Else
	cQuery += " AND C1_OK <> '"+ThisMark()+"'"
EndIf
If SC1->(FieldPos("C1_ACCPROC")) > 0
	cQuery += " AND C1_ACCPROC <> '1'"
EndIf
cQuery += " AND SC1.D_E_L_E_T_ = ' '"
cQuery += " ORDER BY GRUPO,"+SqlOrder(cKey)
cQuery := ChangeQuery(cQuery)
cAliasSC1 := "a131PROCES"
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSC1,.T.,.T.)
For nCntFor := 1 To Len(aStruSc1)
	If ( aStruSC1[nCntFor][2] $ "NDL" ) 
		TcSetField(cAliasSC1,aStruSC1[nCntFor][1],aStruSC1[nCntFor][2],aStruSC1[nCntFor][3],aStruSC1[nCntFor][4])
	EndIf
Next nCntFor

ProcRegua(SC1->(LastRec()))

//---------------------------------------
//Ativa o Modelo MATA131
//----------------------------------------
oModel:SetOperation(MODEL_OPERATION_INSERT)
If oModel:Activate()	
	a131Bloq(oModel,.F.)
	While !Eof() .And. (cAliasSC1)->C1_FILIAL == xFilial("SC1",(cAliasSC1)->C1_FILIAL) .And. ( ThisMark() == (cAliasSC1)->C1_OK .Or. ThisInv() )
	
		If IsMark("C1_OK",ThisMark(),ThisInv()) 
	
			lProcessa := .T. 
			
			If lMta131Sk
				SC1->(MsGoto((cAliasSC1)->SC1RECNO))
				lProcessa	:= ExecBlock("MTA131SK",.F.,.F.)
				If ValType(lProcessa)#"L"
					lProcessa := .T.
				EndIf
			EndIf
			
			lQuebrou := !(Empty(oModel:GetModel("SC1DETAIL"):GetValue("C1_PRODUTO"))) .And. cQuebra # Eval(bQuebra)

				
			If lProcessa  
				SC1->(MsGoto((cAliasSC1)->SC1RECNO))
			EndIf
	
			If SB1->(MsSeek(xFilial("SB1")+(cAliasSC1)->C1_PRODUTO))
				If !RegistroOk("SB1")
					lProcessa := .F.
				EndIf
				If !Empty(SB1->B1_PROC) .And. SB1->B1_MONO == "S"
					aadd(aScMono,(cAliasSC1)->C1_NUM+"-"+(cAliasSC1)->C1_ITEM)
					lProcessa	:= .F.
				Endif
			Endif
	
			If lProcessa 
				nQtdSC += ( (cAliasSC1)->C1_QUANT - (cAliasSC1)->C1_QUJE )
				nQtdSC2 +=  (cAliasSC1)->C1_QTSEGUM
				aadd(aRegSC,(cAliasSC1)->SC1RECNO)
				//----------------------
				// Adiciona Produto
				//----------------------
				If Empty((cAliasSC1)->C1_ITEMGRD)
					a131AddSC(oModel,cAliasSC1,nQtdSC,nQtdSC2,lQuebrou)
				Else
					a131AddSC(oModel,cAliasSC1,( (cAliasSC1)->C1_QUANT - (cAliasSC1)->C1_QUJE ),(cAliasSC1)->C1_QTSEGUM,lQuebrou)
				EndIf							
			EndIf
			
		EndIf
	
		dbSelectArea(cAliasSC1)
		cQuebra := Eval(bQuebra)
	
		Aadd(aSc1It, {(cAliasSC1)->C1_NUM, (cAliasSC1)->C1_ITEM, (cAliasSC1)->C1_ITEMGRD})
	
		dbSkip()
		IncProc()
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Realiza a quebra da SC conforme o bQuebra para a Geracao do SC8³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If cQuebra != (cAliasSC1)->(Eval(bQuebra)) .Or. Len(aRegSC)>4000 
			If !Empty(cQuebra) .And. nQtdSC > 0
				If ( a131Grava(nAmarracao,aRegSC,nQtdSC,nFornec,nUltForn,dValidade,@cNumCot,@cItem,@cIdent,@aQuebra,@lPrdxForn,@aReplForn,@lReplica,@lControle,@oModel,nQtdSC2) )
					lGravou := .T.
				EndIf
				aRegSC := {}
				nQtdSc := 0
				nQtdSc2 := 0
			EndIf
		EndIf
		
		
	
	EndDo
	
	If lClicB
		aSaveLines 	:= FWSaveRows()
		
		For nX := 1 To oModGrp:Length()
			oModGrp:GoLine(nX)
			For nY:=1 To oModPrd:Length()
				oModPrd:GoLine(nY)
				For nZ:=1 To oModTmp:Length()
					oModTmp:GoLine(nZ)
					If !Empty(oModTmp:GetValue('TMP_CGC'))
						SA2->(DbSetOrder(3))
						If SA2->(DbSeek(xFilial('SA2')+oModTmp:GetValue('TMP_CGC')))
							If !Empty(oModCot:GetValue("C8_FORNECE"))
								oModCot:AddLine()
							EndIf
							oModCot:SetValue("C8_FORNECE",SA2->A2_COD)
							oModCot:SetValue("C8_LOJA",SA2->A2_LOJA)
							oModCot:SetValue("C8_FORNOME",PadR(SA2->A2_NOME,Len(SC8->C8_FORNOME)))
							oModCot:SetValue("C8_FORMAIL",PadR(SA2->A2_EMAIL,Len(SC8->C8_FORMAIL)))
							oModCot:LoadValue("C8_CRITER",STR0097)//"INCLUSÃO CLICBUSINESS"
						Endif
					Endif
				Next nz
			Next nY
		Next nX	
		
		FWRestRows( aSaveLines )
	Endif
	If	lSelFor 
		a131Bloq(oModel,.T.)
		oModel:GetModel("SBMDETAIL"):GoLine(1)
		oModel:getModel("SC1DETAIL"):GoLine(1)
		oModel:getModel("SC8DETAIL"):GoLine(1)
		oModel:getModel("TMPDETAIL"):GoLine(1)
		FWExecView ('', "MATA131A",  MODEL_OPERATION_INSERT,/*oDlg*/ , {||.T.},,,,/*{||.F.}*/,,,oModel)			
	Else
		If oModel:VldData()
			oModel:CommitData()
			If Empty(cNumCot)
				cNumCot := oModel:GetModel("SC8DETAIL"):Getvalue("C8_NUM")
			EndIf
		Else
			aErros := oModel:GetErrorMessage()
			Aviso(aErros[5],aErros[4]+chr(13)+chr(10)+aErros[6],{STR0030},3)		// Codigo do erro # Campo + Descricao do erro # Ok
		EndIf
	EndIf
Else 
	Help("",1,"NOACTIVE",,STR0074,4,1) //"Ocorreu um erro e não foi possivel ativar o modelo de dados, assim o processo foi abortado."
EndIf	
oModel  := Nil


If !lPrdxForn .And. !lSelFor .And. Len(aReplForn) == 0
	Aviso(STR0024,STR0031,{STR0030}, 2)
	lContinua := .F.
Endif     

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Restaura o SC1                                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea(cAliasSC1)
dbCloseArea()
dbSelectArea("SC1")

If lGravou

	For nI := 1 To Len(aSc1It)
		
		SC1->(DbSetOrder(1)) // Indice 1 - C1_FILIAL+C1_NUM+C1_ITEM+C1_ITEMGRD
		If SC1->(DbSeek(xFilial('SC1')+aSc1It[nI][1]+aSc1It[nI][2]+aSc1It[nI][3]))
			
			If AScan(aSc8Num, SC1->C1_COTACAO) == 0 
				AAdd(aSc8Num, SC1->C1_COTACAO) 
			EndIf
			
		EndIf
		
	Next nI
	
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Integracao com WF.                                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Len(aSc8Num) > 0 .And. ExistBlock("MT131WF")
	ExecBlock("MT131WF",.F.,.F.,{aSc8Num[1],aSc8Num})
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Chamada do Relatorio.                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lRelatorio .And. ( Len(aSc8Num) > 0 .Or. !Empty(cCotNum) )                             
	dbSelectArea("SC8")
	dbSetOrder(1)
	If Len(aSc8Num) > 0
		
		MsSeek(xFilial("SC8")+IF(Empty(aSc8Num[1]),cCotNum,aSc8Num[1]))
		
	Else
		
		MsSeek(xFilial("SC8")+cCotNum)
		
	EndIf
	SC1->(dbClearFilter())

	If !Empty(SC8->C8_NUM)
		a131Impri(SC8->C8_NUM)
	EndIf

	Pergunte("MTA130",.F.)
	dbSelectArea("SC1")
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Mostra as Solicitacoes que nao foram geradas.                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Len(aScMono) > 0
	For nX:= 1 To Len(aScMono)
		If nX == 1
			cNumScs := aScMono[nX]
		Else
			cNumScs += ", "+aScMono[nX]
		Endif
	Next nX
	Aviso(STR0024,STR0029+cNumScs,{STR0030}, 2)
Endif

RestArea(aAreaSC1)
RestArea(aArea)

Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³GetNumSC8 ³ Autor ³Eduardo Riera          ³ Data ³ 19.05.99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Inicializa o Numero das Cotacoes de Compra                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³lConfirma : Confirma a utilizacao do Numero                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Numero da Cotacao de Compra                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function GetNumSC8(lConfirma)

Local aArea	   := GetArea()
Local aAreaSC8 := SC8->(GetArea())
Local cNumCot  := GetSx8Num("SC8","C8_NUM")
Local nSaveSX8 := GetSX8Len()

lConfirma := IIf(lConfirma==Nil,.F.,lConfirma)

dbSelectArea("SC8")
dbSetOrder(1)
While SC8->(MsSeek(xFilial("SC8")+cNumCot))
	While ( GetSX8Len() > nSaveSX8 )
		ConfirmSX8()
	EndDo
	cNumCot := GetSx8Num("SC8","C8_NUM")
EndDo

If lConfirma
	While GetSX8Len() > nSaveSX8
		ConfirmSx8()
	EndDo
EndIf

RestArea(aAreaSC8)
RestArea(aArea)

Return(cNumCot)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³a131UlForn³ Autor ³Eduardo Riera          ³ Data ³20.05.99  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Localizar os ultimos fornecimentos de um Produto            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpN1: Numero de Fornecedores a serem avaliados             ³±±
±±³          ³ExpC2: Codigo do Produto                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpA1: Array com os ultimos fornecimentos                   ³±±
±±³          ³       [1] Codigo do Fornecedor                             ³±±
±±³          ³       [2] Loja do Fornecedor                               ³±±
±±³          ³       [3] Emissao da Nota Fiscal                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function a131UlForn(nNumFor,cProduto)

Local aArea		:= GetArea()
Local aAreaSD1  := SD1->(GetArea())
Local aUltFor	:= {}
Local cAliasSD1 := "A131SELFOR"
Local cQuery 	:= ""
Local nPosFor	:= 0	
Local lGrava 	:= .T.
Default nNumFor := 0

	cQuery := "SELECT  D1_FORNECE, D1_LOJA, D1_EMISSAO "
	cQuery += "FROM "+RetSqlName("SD1")
	cQuery += " WHERE D1_FILIAL = '"+xFilial("SD1")+"' AND"
	cQuery += " D1_COD = '"+cProduto+"' AND"
	cQuery += " D1_TIPO = 'N' AND"
	cQuery += " D_E_L_E_T_ = '' "
	cQuery += "ORDER BY D1_EMISSAO DESC"
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSD1,.T.,.T.)
	
	While Len(aUltFor) < nNumFor .And. !(cAliasSD1)->(EOF())
		lGrava := .T.
		nPosFor := aScan(aUltFor,{|x| x[1]==(cAliasSD1)->D1_FORNECE})
		If nPosFor > 0  
			If  aUltFor[nPosFor][2]==(cAliasSD1)->D1_LOJA
				lgrava := .F.					
			Else
				lGrava := .T.
			EndIf
	    EndIf
		If lGrava   
			aadd(aUltFor,{ (cAliasSD1)->D1_FORNECE,(cAliasSD1)->D1_LOJA,STR0028+DtoC(StoD((cAliasSD1)->D1_EMISSAO)) })
		EndIf
	(cAliasSD1)->(dbSkip())
	EndDo	
	dbSelectArea(cAliasSD1)
	dbCloseArea()

RestArea(aAreaSD1)
RestArea(aArea)

Return(aUltFor)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³a131Grava ³ Autor ³Eduardo Riera          ³ Data ³19.05.99  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Efetua a Gravacao das Cotacoes                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpN1: 1 - Produto ( Qual Tipo de Amarracao utilizar )      ³±±
±±³          ³       2 - Grupo                                            ³±±
±±³          ³ExpN2: Quantidade a ser considerada                         ³±±
±±³          ³ExpA3: Array com as cotacoes a serem consideradas           ³±±
±±³          ³ExpN4: Numero de Fornecedores a serem escolhidos            ³±±
±±³          ³ExpN5: Numero de Ultimos Fornecimentos                      ³±±
±±³          ³ExpD6: Data de Validade da Cotacao                          ³±±
±±³          ³ExpC7: Numero da Cotacao  [Referencia]                      ³±±
±±³          ³ExpC8: Item da Cotacao    [Referencia]                      ³±±
±±³          ³ExpC9: Identificador da Cotacao [Referencia]                ³±±
±±³          ³ExpCA: Controle de quebra da cotacao                        ³±±
±±³          ³ExpCB: Modelo de dados MVC                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpL1: Indica se efetuou a gravacao                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function a131Grava(nAmarracao,aSCs,nQtdSC,nFornec,nUltForn,dValidade,cNumCot,cItem,cIdent,aQuebra,lPrdxForn,aReplForn,lReplica,lControle,oModel,nQtdSC2)

Local aArea		  := GetArea()
Local aAreaSC1	  := SC1->(GetArea())
Local aAreaSB1	  := SB1->(GetArea())
Local aAreaSA2	  := SA2->(GetArea())
Local aAreaSA5	  := SA5->(GetArea())
Local aAreaSAD	  := SAD->(GetArea())
Local aStruSA5	  := SA5->(dbStruct())
Local aStruSAD	  := SAD->(dbStruct())
Local aUltFor	  := {}
Local cAliasSA5	  := "SA5"
Local cAliasSAD	  := "SAD"
Local cQuery	  := ""
Local cRefGrd     := ""
Local nCntFor	  := 0
Local nCont		  := 0
Local lReferencia := .F.
Local lFornBloq   := .F.
Local lExistPxF	 := .F.	
Local nAddedForn := 0
Local nAddedUltF := 0
Local cCodTab    := ''
Local aFornec		:= {}
Local aOrdFor		:= {}
Local aFornecAux	:= {}

Default aReplForn  := {}
Default lReplica   := .F.
Default lControle  := .T.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Posiciona Registros e Atualiza a Amarracao                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SC1")
dbSetOrder(1)
MsGoto(aSCs[1])

dbSelectArea("SB1")
dbSetOrder(1)
MsSeek( xFilial("SB1")+SC1->C1_PRODUTO)

dbSelectArea("SA2")
dbSetOrder(1)
MsSeek( xFilial("SA2")+SC1->C1_FORNECE+SC1->C1_LOJA)

If nAmarracao == 1 .Or. nAmarracao == 3 //Produto
	If !Empty(SC1->C1_FORNECE)
		cRefGrd:=Pad( AtuSA5(SC1->C1_FORNECE,SC1->C1_LOJA,SC1->C1_PRODUTO,MV_PAR11==2),14)
	Else
		cRefGrd := SC1->C1_PRODUTO
		lReferencia:= MatGrdPrrf(@cRefGrd,.T.)	
		cRefGrd := Pad(cRefGrd,14)
	EndIf
Else  //Grupo
	If !Empty(SC1->C1_FORNECE) .And. !Empty(SB1->B1_GRUPO)
		dbSelectArea("SAD")
		dbSetOrder(2)
		If ( !MsSeek(xFilial("SAD")+SB1->B1_GRUPO+SC1->C1_FORNECE+SC1->C1_LOJA) )
			RecLock("SAD",.T.)
			SAD->AD_FILIAL		:= xFilial("SAD")
			SAD->AD_GRUPO   	:= SB1->B1_GRUPO
			SAD->AD_FORNECE 	:= SC1->C1_FORNECE
			SAD->AD_LOJA		:= SC1->C1_LOJA
			SAD->AD_NOMEFOR	:= AllTrim(SA2->A2_NOME)
			SAD->AD_NOMGRUP	:= Tabela("03",SB1->B1_GRUPO)
			MsUnLock()
		EndIf
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Adiciona as amarracoes cadastradas                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nAmarracao == 1 .Or. nAmarracao == 3  //Produto

	cQuery := "SELECT " 
	cQuery += a131CpoStr(aStruSa5,"M")
	cQuery +=" ,SA5.R_E_C_N_O_ SA5RECNO  "
	cQuery += "  FROM "+RetSqlName("SA5")+" SA5 "
	cQuery += " WHERE SA5.A5_FILIAL='"+xFilial("SA5")+"'"
	cQuery += "   AND SA5.A5_PRODUTO='"+SC1->C1_PRODUTO+"' AND "
	If !Empty(SC1->C1_FORNECE)
		cQuery += "SA5.A5_FORNECE='"+SC1->C1_FORNECE+"' AND "
	EndIf
	If !Empty(SC1->C1_LOJA) 
		cQuery += "SA5.A5_LOJA='"+SC1->C1_LOJA+"' AND "
	EndIf
	cQuery += "SA5.D_E_L_E_T_ = ' '"
	cQuery += "UNION "
	cQuery += "SELECT "
	cQuery += a131CpoStr(aStruSa5,"M")
	cQuery += "	,SA5.R_E_C_N_O_ SA5RECNO  "
	cQuery += "  FROM "+RetSqlName("SA5")+" SA5 "
	cQuery += " WHERE SA5.A5_FILIAL='"+xFilial("SA5")+"'"
	cQuery += "   AND SA5.A5_REFGRD='"+cRefGrd+"' AND "
	If !Empty(SC1->C1_FORNECE) 
		cQuery += "SA5.A5_FORNECE='"+SC1->C1_FORNECE+"' AND "
	EndIf
	If !Empty(SC1->C1_LOJA) 
		cQuery += "SA5.A5_LOJA='"+SC1->C1_LOJA+"' AND "
	EndIf
	cQuery += "SA5.D_E_L_E_T_ = ' '"
	cQuery += "AND ( SELECT Count(*) "
	cQuery += "        FROM "+RetSqlName("SA5")+" SA52 "
	cQuery += "       WHERE SA52.A5_PRODUTO='"+SC1->C1_PRODUTO+"'  "
	If MaConsRefG()
		cQuery += "AND SA5.A5_FORNECE=SA52.A5_FORNECE "
	EndIf
	cQuery += "AND SA52.D_E_L_E_T_ = ' ') = 0"
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"a131GRAVA",.T.,.T.)
	cAliasSA5 := "a131GRAVA"
	For nCntFor := 1 To Len(aStruSA5)
		If ( aStruSA5[nCntFor][2] $ "NDL" ) 
			TcSetField(cAliasSA5,aStruSA5[nCntFor][1],aStruSA5[nCntFor][2],aStruSA5[nCntFor][3],aStruSA5[nCntFor][4])
		EndIf
	Next nCntFor
	
	dbSelectArea(cAliasSA5)
	While ( !Eof() .And. xFilial("SA5") == (cAliasSA5)->A5_FILIAL .And.;
			(SC1->C1_PRODUTO== (cAliasSA5)->A5_PRODUTO .Or. cRefGrd==(cAliasSA5)->A5_REFGRD)  .And.;
			(SC1->C1_FORNECE == (cAliasSA5)->A5_FORNECE .Or. Empty(SC1->C1_FORNECE)) .And.;
			(SC1->C1_LOJA == (cAliasSA5)->A5_LOJA .Or. Empty(SC1->C1_LOJA)) )
	
		// Verifica se houve Produto X Fornecedor
		lExistPxF := .T.
		// Verifica se o Fornecedor esta bloqueado
		lFornBloq := .F.
		If SA2->(MsSeek(xFilial("SA2")+(cAliasSA5)->A5_FORNECE+(cAliasSA5)->A5_LOJA))
			If !RegistroOk("SA2",.F.)
				lFornBloq := .T.
			EndIf
		EndIf
		// Verifica se o Produto X Fornecedor esta bloqueado
		If !lFornBloq
			SA5->(dbSetOrder(1))
			If SA5->(MsSeek(xFilial("SA5")+(cAliasSA5)->A5_FORNECE+(cAliasSA5)->A5_LOJA+(cAliasSA5)->A5_PRODUTO))
				If !RegistroOk("SA5",.F.)
					lFornBloq := .T.
				EndIf
			EndIf
		EndIf
		//Verifica se o Produto x Fornecedor nao foi bloqueado pela Qualidade
		If QieSitFornec((cAliasSA5)->A5_FORNECE,(cAliasSA5)->A5_LOJA,SC1->C1_PRODUTO,.F.) .And. !lFornBloq
			If Empty(SC1->C1_CC) .Or. (cAliasSA5)->(FieldPos("A5_CCUSTO"))==0 .Or. Empty((cAliasSA5)->(FieldGet(FieldPos("A5_CCUSTO"))))
				If nFornec > nAddedForn .Or. GetMv("MV_SELFOR")<>"S"
					nAddedForn++
					aAdd(aFornec,{(cAliasSA5)->A5_FORNECE,(cAliasSA5)->A5_LOJA,"","SA5",(cAliasSA5)->SA5RECNO})
				EndIf
			ElseIf (cAliasSA5)->(FieldPos("A5_CCUSTO"))<>0 .And. (cAliasSA5)->(FieldGet(FieldPos("A5_CCUSTO"))) == SC1->C1_CC
				If nFornec > nAddedForn .Or. GetMv("MV_SELFOR")<>"S"
					nAddedForn++
					aadd(aFornec,{(cAliasSA5)->A5_FORNECE,(cAliasSA5)->A5_LOJA,"","SA5",(cAliasSA5)->SA5RECNO})
				EndIf			
			EndIf
		EndIf
	
		dbSelectArea(cAliasSA5)
		dbSkip()
	
	EndDo
	
	If lPrdxForn
		lPrdxForn := lExistPxF
	EndIf
	
	//Replica Fornecedores
	If MV_PAR14 == 1 .And. Len(aReplForn) == 0
		aReplForn  := aClone(aFornec)
	EndIf
	
	dbSelectArea(cAliasSA5)
	dbCloseArea()
	dbSelectArea("SA5")
EndIf	
If nAmarracao == 2 .Or. nAmarracao == 3 // Grupo

	cQuery := "SELECT SAD.*,SAD.R_E_C_N_O_ SADRECNO  "
	cQuery += "FROM "+RetSqlName("SAD")+" SAD "
	cQuery += "INNER JOIN "+RetSqlName("SA2")+" SA2 ON A2_FILIAL = '"+xFilial("SA2")+"' AND A2_COD = AD_FORNECE"
	cQuery += " AND A2_LOJA = AD_LOJA "
	cQuery += "WHERE SAD.AD_FILIAL='"+xFilial("SAD")+"' AND "
	cQuery += "SAD.AD_GRUPO='"+SB1->B1_GRUPO+"' AND A2_MSBLQL != '1' AND "
	If !Empty(SC1->C1_FORNECE) 
		cQuery += "SAD.AD_FORNECE='"+SC1->C1_FORNECE+"' AND "
	EndIf
	If !Empty(SC1->C1_LOJA) 
		cQuery += "SAD.AD_LOJA='"+SC1->C1_LOJA+"' AND "
	EndIf
	cQuery += "SAD.D_E_L_E_T_ = ' ' AND SA2.D_E_L_E_T_ = ' '"
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"a131GRAVA",.T.,.T.)
	cAliasSAD := "a131GRAVA"
	For nCntFor := 1 To Len(aStruSAD)
		If ( aStruSAD[nCntFor][2] $ "NDL" ) 
			TcSetField(cAliasSAD,aStruSAD[nCntFor][1],aStruSAD[nCntFor][2],aStruSAD[nCntFor][3],aStruSAD[nCntFor][4])
		EndIf
	Next nCntFor
	
	dbSelectArea(cAliasSAD)
	While ( !Eof() .And. xFilial("SAD") == (cAliasSAD)->AD_FILIAL .And.;
			SB1->B1_GRUPO== (cAliasSAD)->AD_GRUPO .And.;
			(SC1->C1_FORNECE == (cAliasSAD)->AD_FORNECE .Or. Empty(SC1->C1_FORNECE)) .And.;
			(SC1->C1_LOJA == (cAliasSAD)->AD_LOJA .Or. Empty(SC1->C1_LOJA)) )
		
		// Verifica se o Fornecedor esta bloqueado
		lFornBloq := .F.
		If SA2->(MsSeek(xFilial("SA2")+(cAliasSAD)->AD_FORNECE+(cAliasSAD)->AD_LOJA))
			If !RegistroOk("SA2",.F.)
				lFornBloq := .T.
			EndIf
		EndIf
		
		If MTFindMVC(oModel:GetModel("SC8DETAIL"),{{"C8_FORNECE",(cAliasSAD)->AD_FORNECE},{"C8_LOJA",(cAliasSAD)->AD_LOJA}}) == 0 .And. !lFornBloq
			If nFornec > nAddedForn .Or. GetMv("MV_SELFOR")<>"S"
				nAddedForn++
				aadd(aFornec,{(cAliasSAD)->AD_FORNECE,(cAliasSAD)->AD_LOJA,"","SAD",(cAliasSAD)->SADRECNO})
			EndIf
		EndIf
		
		dbSelectArea(cAliasSAD)
		dbSkip()
	EndDo
	
	dbSelectArea(cAliasSAD)
	dbCloseArea()
	dbSelectArea("SAD")
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se deve permitir escolher fornecedores                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If GetMv("MV_SELFOR")=="S"
	aUltFor := a131UlForn(nUltForn,SC1->C1_PRODUTO)
	For nCntFor := 1 To Len(aUltFor)
		nCont := aScan(aFornec,{|x| x[1] == aUltFor[nCntFor][1] .And. x[2] == aUltFor[nCntFor][2]})
		If nCont == 0 
			SA2->(MsSeek( xFilial("SA2")+aUltFor[nCntFor][1]+aUltFor[nCntFor][2]))
			If nAmarracao == 1 //Amarração Produto x Fornecedor
				If nFornec >= Len(aFornec).And. nUltForn > nAddedUltF .AND. RegistroOk("SA2",.F.)
					If lExistPxF .and. !empty(aFornec) .And. nFornec == Len(aFornec)	
						aDel(aFornec,1)
						aSize(aFornec,Len(aFornec)-1)
					EndIf					
	 				nAddedForn++
					nAddedUltF++
					aadd(aFornec,{ aUltFor[nCntFor][1],aUltFor[nCntFor][2],aUltFor[nCntFor][3],"SA2",SA2->(Recno())})
					aadd(aOrdFor,{ aUltFor[nCntFor][1],aUltFor[nCntFor][2],aUltFor[nCntFor][3],"SA2",SA2->(Recno())})
				EndIf
			Else
				If nFornec > Len(aFornec).And. nUltForn > nAddedUltF .AND. RegistroOk("SA2",.F.)	
	 				nAddedForn++
					nAddedUltF++
					aadd(aFornec,{ aUltFor[nCntFor][1],aUltFor[nCntFor][2],aUltFor[nCntFor][3],"SA2",SA2->(Recno())})
					aadd(aOrdFor,{ aUltFor[nCntFor][1],aUltFor[nCntFor][2],aUltFor[nCntFor][3],"SA2",SA2->(Recno())})
				Else
					If Len(aUltFor) > 0 .And. RegistroOk("SA2",.F.)
						aadd(aFornec,{ aUltFor[nCntFor][1],aUltFor[nCntFor][2],aUltFor[nCntFor][3],"SA2",SA2->(Recno())})
						aadd(aOrdFor,{ aUltFor[nCntFor][1],aUltFor[nCntFor][2],aUltFor[nCntFor][3],"SA2",SA2->(Recno())})
						aDel(aFornec,1)
						aSize(aFornec,Len(aFornec)-1)
					EndIf
				EndIf
			EndIf
		Else			
			aadd(aFornec,{ aUltFor[nCntFor][1],aUltFor[nCntFor][2],aUltFor[nCntFor][3],"SA2",SA2->(Recno())})
			aDel(aFornec,1)
			aSize(aFornec,Len(aFornec)-1)
			aadd(aOrdFor,aFornec[nCont])
		EndIf
	Next nCntFor
	
	For nCntFor := 1 To Len(aFornec)
		nCont := aScan(aOrdFor,{|x| x[1]==aFornec[nCntFor][1] .And. x[2]==aFornec[nCntFor][2]})
		If nCont == 0
			aadd(aOrdFor,aFornec[nCntFor])
		EndIf
	Next nCntFor
	
	If Len(aOrdFor) == Len(aFornec)
		aFornec := aOrdFor
	EndIf
	
	If ExistBlock("MT131FOR")
		aFornecAux	:= aClone(aFornec)
		aFornec	:= ExecBlock("MT131FOR",.F.,.F.,{aFornec})
		
		If ValType(aFornec) <> "A"
			aFornec := aClone(aFornecAux)
		EndIf
	EndIf
Else
	If ExistBlock("MT131FOR")
		aFornecAux	:= aClone(aFornec)
		aFornec	:= ExecBlock("MT131FOR",.F.,.F.,{aFornec})
		
		If ValType(aFornec) <> "A"
			aFornec := aClone(aFornecAux)
		EndIf
	EndIf
	//Replica Fornecedores
	If MV_PAR14 == 1 .And.Len(aFornec) == 0
		aFornec := aClone(aReplForn)
	EndIf
EndIf

If Len(aFornec) > 0
	For nCntFor := 1 To Len(aFornec)
		a131AddFor(aFornec[nCntFor][1],aFornec[nCntFor][2],aFornec[nCntFor][3],aFornec[nCntFor][4],aFornec[nCntFor][5],@oModel,nQtdSC,nQtdSC2,dValidade,"",nAmarracao)
	Next nCntFor
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Restaura a Entrada                                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
RestArea(aAreaSC1)
RestArea(aAreaSB1)
RestArea(aAreaSA5)
RestArea(aAreaSA2)
RestArea(aAreaSAD)
RestArea(aArea)

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ a131Impri³ Autor ³ Sergio Silveira       ³ Data ³12/09/2001³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Efetua a chamada do relatorio padrao ou do usuario         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ ExpX1 := a131Impri( ExpC1 )                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 -> Numero da cotacao                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ ExpX1 -> Retorno do relatorio                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function a131Impri(cNumero)

Local cPrinter := GetMV("MV_COTIMPR" ,, "" )
Local xRet     := .T.

If !Empty( cPrinter ) .And. Existblock( cPrinter )
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Faz a chamada do relatorio de usuario                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	ExecBlock( cPrinter, .F., .F., { cNumero } )
Else
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Faz a chamada do relatorio padrao                            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	xRet := MATR150( cNumero )
EndIf

dbSelectArea("SC1") 

Return( xRet )

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³a131Legenda³ Autor ³Nereu Humberto Junior ³ Data ³17.04.2006 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Exibe uma janela contendo a legenda da mBrowse.              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Exclusivo MATa131                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function a131Legenda()

Local aCores     := {}
Local aCoresNew  := {}

aAdd(aCores,{"LIGHTBLU"		,STR0045}) //"Integração Modulo Gestão de Contratos"
aAdd(aCores,{"ENABLE"		,STR0037}) //"Solicitacao Pendente"
aAdd(aCores,{"DISABLE"		,STR0038}) //"Solicitacao Totalmente Atendida"
aAdd(aCores,{"BR_AMARELO"	,STR0039}) //"Solicitacao Parcialmente Atendida"
aAdd(aCores,{"BR_AZUL"		,STR0040}) //"Solicitacao em Processo de Cotacao"
aAdd(aCores,{"BR_PRETO"		,STR0041}) //"Elim. por Residuo"
aAdd(aCores,{"BR_CINZA"		,STR0042}) //"Solicitacäo Bloqueada"
aAdd(aCores,{"BR_PINK"		,STR0043}) //"Solicitação de produto Importado"
aAdd(aCores,{"BR_LARANJA"	,STR0044}) //"Solicitacäo Rejeitada"

If ExistBlock("MT131LEG")
	aCoresNew := ExecBlock("MT131LEG",.F.,.F.,{aCores})
	If ValType(aCoresNew) == "A"
		aCores := aCoresNew
	Endif
EndIf

BrwLegenda(cCadastro,STR0032,aCores) //Legenda

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³MenuDef   ³ Autor ³ Fabio Alves Silva     ³ Data ³01/11/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Utilizacao de menu Funcional                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Array com opcoes da rotina.                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Parametros do array a Rotina:                               ³±±
±±³          ³1. Nome a aparecer no cabecalho                             ³±±
±±³          ³2. Nome da Rotina associada                                 ³±±
±±³          ³3. Reservado                                                ³±±
±±³          ³4. Tipo de Transa‡„o a ser efetuada:                        ³±±
±±³          ³	  1 - Pesquisa e Posiciona em um Banco de Dados           ³±±
±±³          ³    2 - Simplesmente Mostra os Campos                       ³±±
±±³          ³    3 - Inclui registros no Bancos de Dados                 ³±±
±±³          ³    4 - Altera o registro corrente                          ³±±
±±³          ³    5 - Remove o registro corrente do Banco de Dados        ³±±
±±³          ³5. Nivel de acesso                                          ³±±
±±³          ³6. Habilita Menu Funcional                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MenuDef()
PRIVATE aRotina	:= {	{ STR0002,"PesqBrw" 	,0,1,0,.F.},;  	//"Pesquisar"
						{ STR0025,"a131VisuSC" 	,0,2,0,NIL},;		//"Visualiza"
						{ STR0003,"a131Gera"   	,0,4,0,NIL},;   	//"Gera Cotacao"
						{ STR0032,"a131Legenda"	,0,5,0,.F.},;  	//"Legenda"
						{ STR0052,"MAComCent"  	,0,3,0,.F.}}	 	// Compras Centralizadas
						
	If ExistBlock("MT131MNU")
    	ExecBlock("MT131MNU",.F.,.F.)
	EndIf
						
Return aRotina

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³a131VisuPC ³ Autor ³ Ricardo Berti        ³ Data ³10/11/2008 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Chamada a funcao A110Visual - visualizacao da SC.            ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias do arquivo                                    ³±±
±±³          ³ ExpN2 = Numero do registro                                  ³±±
±±³          ³ ExpN3 = Numero da opcao selecionada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ MATa131                                           		   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function a131VisuSC(cAlias,nReg,nOpcx)

A110Visual(cAlias,nReg,nOpcx)
Pergunte("MTA130",.F.)
Return Nil

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³a131CpoStr ³ Autor ³ Julio C.Guerato      ³ Data ³13/03/2009 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Retorna os Campos de um Vetor no formato de String           ³±±
±±³			 ³desconsiderando os tipos de campos solicitados               ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpA1 = Vetor com a estrutura                               ³±±
±±³			 ³ ExpC1 = Tipo de Campos a serem desconsiderados              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ MATa131                                           		   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function a131CpoStr(aStru,aTipo)
Local nCpoStr	 := 0 
Local cStru		 := ""

For nCpoStr := 1 To Len(aStru)
	If !(aStru[nCpoStr][2]	$ aTipo )   
        cStru += iif(len(cStru)>0,", " + aStru[nCpoStr][1],aStru[nCpoStr][1])
	EndIf
Next nCpoStr      

Return (cStru)    

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³a131CHKCPO ³ Autor ³ Turibio Miranda      ³ Data ³18/06/2010 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Verifica se os campo B1_PE e C8_PRAZO estao com tamanhos	   ³±±
±±³			 ³Diferentes, caso estiverem, alerta para alterar via CFG 	   ³±±
±±³          ³e sai da rotina MATa131									   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum						                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ MATa131                                           		   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function a131CHKCPO()
Local aAreaSX3:= SX3->( GetArea() )
Local lRet 	  := .T.
Local nTamB1  := nTamB1:= TamSX3("B1_PE")[1]
Local nTamC8  := nTamC8:= TamSX3("C8_PRAZO")[1]

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica o tamanho dos campos B1_PE e C8_PRAZO	³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nTamB1 <> nTamC8
	lRet:= .F.
	Aviso(STR0024,STR0051,{STR0030},2) //"Atencao"###"Os campos B1_PE e C8_PRAZO não possuem o mesmo tamanho. Verifique o tamanho dos campos através do configurador."###"Ok"
EndIf               

RestArea( aAreaSX3 )
Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} IntegDef
Chamada da Mensagem Unica de Cadsatro de comprador

@param cXml Xml passado para a rotina
@param nType Determina se e uma mensagem a ser enviada/recebida ( TRANS_SEND ou TRANS_RECEIVE)
@param cTypeMsg Tipo de mensagem ( EAI_MESSAGE_WHOIS,EAI_MESSAGE_RESPONSE,EAI_MESSAGE_BUSINESS)

@return aRet[1] boleano determina se a mensagem foi executada ou nao com sucesso
@return aRet[2] string xml

@author Raphael Augustos
@since 02/06/2013
@version MP11.80
/*/
//-------------------------------------------------------------------

Static Function IntegDef( cXml, nTypeTrans, cTypeMessage, cVersion )

Local aRet := {}

aRet:= MATI130( cXml, nTypeTrans, cTypeMessage, cVersion )

Return aRet


//-------------------------------------------------------------------
/*/{Protheus.doc} a131AddFor
Carga do modelo de Dados de Fornecedor

@author alexandre.gimenez
@since 22/10/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function a131AddFor(cCodFor,cLojaFor,cDoc,cCriterio,cRecno,oModel,nQtdSC,nQtdSC2,dValidade,cCodTab,nAmarracao)

Local aArea		:= GetArea()
Local oModFor		:= oModel:GetModel("SC8DETAIL")
Local cProdRef	:= SC1->C1_PRODUTO
Local lGrade		:= SC1->C1_GRADE == "S" .And. MatGrdPrrf(@cProdRef, .T.)
Local nLFor		:= 0
Local nMoeda		:= Iif(MV_PAR16 > 0, Iif(MV_PAR16 <= MoedFin(), MV_PAR16, 1), 1) // Caso o usuario nao informe a moeda ou seja invalida, o sistema assume a moeda 1.
Local nValFrete	:= 0
Local aFornec		:= {}
Local aFornecAux	:= {}

dbSelectArea("SA2")
SA2->(dbSetOrder(1))
MsSeek(xFilial("SA2")+cCodFor+cLojaFor)

dbSelectArea("SA5")
SA5->(dbSetOrder(1))
If MsSeek(xFilial("SA5")+cCodFor+cLojaFor+SC1->C1_PRODUTO)
	cCodTab := SA5->A5_CODTAB
Else
	cProdRef := SC1->C1_PRODUTO
	lReferencia := MatGrdPrrf(@cProdRef, .T.)
	
	SA5->(dbSetOrder(9))
	If MsSeek(xFilial("SA5")+cCodFor+cLojaFor+cProdRef)
		cCodTab := SA5->A5_CODTAB
	Endif
Endif

If (nAmarracao == 2 .Or. nAmarracao == 3 )// Grupo
	dbSelectArea("SAD")
	SAD->(dbSetOrder(2))
	If MsSeek(xFilial("SAD")+SB1->B1_GRUPO+cCodFor+cLojaFor)
		If Empty(cCodTab)
			cCodTab := SAD->AD_CODTAB
		EndIf
	Endif
EndIf

If !Empty(oModFor:GetValue("C8_FORNECE"))
	nLFor = MTFindMVC(oModel:GetModel("SC8DETAIL"),{{"C8_FORNECE",cCodFor},{"C8_LOJA",cLojaFor}})
	If nLFor > 0
		oModFor:GoLine(nlFor)
	Else
		oModFor:AddLine()
	EndIf 
EndIf

oModFor:LoadValue("C8_FILIAL",xFilial("SC8"))
oModFor:LoadValue("C8_FILENT",SC1->C1_FILENT)
oModFor:LoadValue("C8_EMISSAO",dDataBase)
oModFor:LoadValue("C8_GRUPCOM",SC1->C1_GRUPCOM)
oModFor:LoadValue("C8_COND",SA2->A2_COND)
oModFor:LoadValue("C8_FORNECE",cCodFor)
oModFor:LoadValue("C8_LOJA",cLojaFor)
oModFor:LoadValue("C8_FORNOME",PadR(SA2->A2_NOME,Len(SC8->C8_FORNOME)))
oModFor:LoadValue("C8_FORMAIL",PadR(SA2->A2_EMAIL,Len(SC8->C8_FORMAIL)))
oModFor:LoadValue("C8_CONTATO",PadR(SA2->A2_CONTATO,Len(SC8->C8_CONTATO)))
If lGrade
	oModFor:LoadValue("C8_PRODUTO",cProdRef)
Else
	oModFor:LoadValue("C8_PRODUTO",SC1->C1_PRODUTO)
EndIf
oModFor:LoadValue("C8_PRAZO",RetFldProd(SB1->B1_COD,"B1_PE"))
oModFor:LoadValue("C8_UM",SC1->C1_UM)
oModFor:LoadValue("C8_VALIDA",dValidade)
oModFor:LoadValue("C8_QUANT",nQtdSC)
oModFor:LoadValue("C8_QTSEGUM",nQtdSC2)
oModFor:LoadValue("C8_NUMPRO","01")
oModFor:LoadValue("C8_DATPRF",Max(SC1->C1_DATPRF,dDataBase))
oModFor:LoadValue("C8_NUMSC",SC1->C1_NUM)
oModFor:LoadValue("C8_ITEMSC",SC1->C1_ITEM)
oModFor:LoadValue("C8_ITSCGRD",SC1->C1_ITEMGRD)
oModFor:LoadValue("C8_OBS",SC1->C1_OBS)
oModFor:LoadValue("C8_SEGUM",SC1->C1_SEGUM)
oModFor:LoadValue("C8_CODTAB",cCodTab)
oModFor:LoadValue("C8_ORIGEM",SC1->C1_ORIGEM)
oModFor:LoadValue("C8_MOEDA",nMoeda)

If cPaisLoc == "BRA"
	oModFor:LoadValue("C8_PICM",SB1->B1_PICM)
	oModFor:LoadValue("C8_ALIIPI",SB1->B1_IPI)
EndIf

If SC8->(FieldPos("C8_PRECOOR")) > 0
	oModFor:LoadValue("C8_PRECOOR",SC1->C1_VUNIT)
EndIf

If !Empty(cCodTab)
	dbSelectArea("AIA")
	dbSetOrder(1)
	If MsSeek(xFilial("AIA")+SA2->A2_COD+SA2->A2_LOJA+cCodTab)
		If !Empty(AIA->AIA_CONDPG)
			oModFor:LoadValue("C8_COND",AIA->AIA_CONDPG)
		EndIf
		oModFor:LoadValue("C8_PRECO",MaTabPrCom(cCodTab,SC1->C1_PRODUTO,nQtdSC,SA2->A2_COD,SA2->A2_LOJA,nMoeda,dDataBase,,@nValFrete))
		oModFor:LoadValue("C8_VALFRE",nValFrete)
		oModFor:LoadValue("C8_TOTAL",NoRound(nQtdSC*oModFor:GetValue("C8_PRECO"),2))
	EndIf
EndIf

If cCriterio == "SA5" .AND. cDoc == ''
	oModFor:LoadValue("C8_CRITER","SA5 - Produto X Fornecedor")
ElseIf cCriterio == "SAD" .AND. cDoc == ''
	oModFor:LoadValue("C8_CRITER","SAD - Grupo X Fornecedor")
Else
	oModFor:LoadValue("C8_CRITER",cDoc)	
Endif

oModFor:LoadValue("C8_ALIAS",cCriterio)
oModFor:LoadValue("C8_RECNO",cRecno)

If ExistBlock("MTA131C8")
	Execblock("MTA131C8",.F.,.F.,{@oModFor})
EndIf

RestArea(aArea)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} a131AddSC
Carga do modelo de Dados de Fornecedor

@author alexandre.gimenez
@since 22/10/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function a131AddSC(oModel,cAliasSC1,nQtdSC,nQtdSC2,lQuebrou,lSepara)
Local oModSC		:= oModel:GetModel("SC1DETAIL")
Local oModGrp		:= oModel:GetModel("SBMDETAIL")
Local oModTmp		:= oModel:GetModel("TMPDETAIL")
Local aArea		:= getArea()
Local nLGrp		:= 0
Local nLRef		:= 0
Local cProdRef	:= (cAliasSC1)->C1_PRODUTO
Local lGrade		:= (cAliasSC1)->C1_GRADE == "S" .And. MatGrdPrrf(@cProdRef, .T.)
Local lIntGC        := SuperGetMv("MV_VEICULO",.F.,"N") == "S"
Local cGrpRef		:= ""
Local cGrupo		:= SB1->B1_GRUPO
Local cAliasTemp	:= ""
Local cIndex		:= ""

Default lSepara	:= .F.

//------------------------------
// Desativa tratamento de Grade
//------------------------------
If lSepara
	lGrade := .F.
	cGrupo := oModGrp:GetValue("BM_GRUPO")
EndIf

//-------------------------------------------------------
// Primeira vez (Ou) Houve Quebra (Ou) Produto de Grade
//-------------------------------------------------------
If Empty(oModSC:GetValue("C1_PRODUTO")) .OR. lQuebrou .Or. lGrade
	//------------------------------
	// Verificar grupo de Materiais
	//-----------------------------
	If lGrade
		DbSelectArea("SB4")
		DbSetOrder(1)
		If SB4->(DbSeek(xFilial("SB4")+cProdRef))
			cGrpRef := SB4->B4_GRUPO
		EndIf
		nLGrp := MTFindMVC(oModGrp,{{"BM_GRUPO",cGrpRef}})
	Else
		nLGrp := MTFindMVC(oModGrp,{{"BM_GRUPO",cGrupo}})
	EndIf  
	
	If nLGrp > 0
		oModGrp:GoLine(nLGrp)
		If Empty(oModGrp:GetValue("BM_DESC"))
			oModGrp:LoadValue("BM_DESC",STR0075) //"Sem grupo de materias definido"
		EndIf
	Else
		If !Empty(oModGrp:GetValue("BM_DESC"))
			oModGrp:AddLine()
		EndIf
		lQuebrou := .F.
		oModGrp:LoadValue("BM_GRUPO",cGrupo)
		DbSelectArea("SBM")
		DbSetOrder(1)
		If SBM->(DBSeek(XFilial("SBM")+cGrupo))
			oModGrp:LoadValue("BM_DESC",SBM->BM_DESC)
		Else
			oModGrp:LoadValue("BM_DESC",STR0075) //"Sem grupo de materias definido"
		EndIf
	EndIf
	//--------------------------------
	//Carrega Produto
	//--------------------------------
	If lQuebrou .And. !lGrade
		oModSC:AddLine()
	EndIf
	If lGrade
		nLRef := MTFindMVC(oModSC,{{"C1_PRODUTO",cProdRef}})
		If nLRef == 0
			If !(Empty(oModSC:GetValue("C1_PRODUTO")))
				oModSC:AddLine()
			EndIf				
			oModSC:LoadValue("C1_PRODUTO",cProdRef)
			oModSc:Loadvalue("C1_DATPRF",(cAliasSC1)->C1_DATPRF)
			oModSc:Loadvalue("C1_DESCRI",MaGetDescGrd(cProdRef))
			oModSC:LoadValue("C1_OBS",(cAliasSC1)->C1_OBS)
			oModSc:LoadValue("GRADE",.T.)
		Else
			oModSC:GoLine(nLRef)
		EndIf			
	Else
		If lSepara
			oModSc:LoadValue("GRADE",.T.)
		EndIf
		oModSC:LoadValue("C1_PRODUTO",(cAliasSC1)->C1_PRODUTO )
		oModSc:Loadvalue("C1_DATPRF",(cAliasSC1)->C1_DATPRF)
		oModSc:Loadvalue("C1_DESCRI",(cAliasSC1)->C1_DESCRI)
		oModSC:LoadValue("C1_OBS",(cAliasSC1)->C1_OBS)
	
	EndIf

	If lIntGC
		oModSC:LoadValue("C1_CODGRP",Posicione("SB1",1,xFilial("SB1")+(cAliasSC1)->C1_PRODUTO,"B1_GRUPO"))
		oModSC:LoadValue("C1_CODITE",Posicione("SB1",1,xFilial("SB1")+(cAliasSC1)->C1_PRODUTO,"B1_CODITE"))
	EndIf

	If !Empty(cGrupo) .And. A131VerInt()
		A131GetFor(oModel,@cAliasTemp,@cIndex)		
		If SA2MKT->(DbSeek(cGrupo))
			While !SA2MKT->(Eof()) .And. SA2MKT->TMP_GRUPO == cGrupo
				If MTFindMVC(oModTmp,{{"TMP_GRUPO",cGrupo},{"TMP_CGC",SA2MKT->TMP_CGC}}) == 0
					If !Empty(oModTmp:GetValue("TMP_NOME"))
						oModTmp:AddLine()
					EndIf
					oModTmp:LoadValue("TMP_CGC"		, SA2MKT->TMP_CGC)
					oModTmp:LoadValue("TMP_NOME"		, SA2MKT->TMP_NOME)
					oModTmp:LoadValue("TMP_REPUTA"	, SA2MKT->TMP_REPUTA)
					oModTmp:LoadValue("TMP_GRUPO"		, SA2MKT->TMP_GRUPO)
					oModTmp:LoadValue("TMP_DESCGR"	, SA2MKT->TMP_DESCGR)
				EndIf
				SA2MKT->(DbSkip())
			End		
		EndIf
		oModTmp:GoLine(1)
		Ferase(cIndex+OrdBagExt())	
	EndIf
	
EndIf
//--------------------------------
// Atualiza Produto
//--------------------------------
If lGrade
	oModSC:LoadValue("C1_QUANT",oModSC:GetValue("C1_QUANT")+nQtdSC )
	oModSC:LoadValue("C1_QTSEGUM",oModSC:GetValue("C1_QTSEGUM")+nQtdSC2 )
Else
	oModSC:LoadValue("C1_QUANT",nQtdSC )
	oModSC:LoadValue("C1_QTSEGUM",nQtdSC2 )
EndIf

If Empty(oModSC:GetValue("ITEMSC"))
	oModSC:Loadvalue("ITEMSC", (cAliasSC1)->C1_NUM+(cAliasSC1)->C1_ITEM+(cAliasSC1)->C1_ITEMGRD)
Else
	oModSC:Loadvalue("ITEMSC", oModSC:GetValue("ITEMSC")+";"+(cAliasSC1)->C1_NUM+(cAliasSC1)->C1_ITEM+(cAliasSC1)->C1_ITEMGRD)				
EndIf				

RestArea(aArea)
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} A131GETFOR
Preenche a tabela temporária do protheus com os melhores fornecedores de cada categoria do ClickBusiness

@author Raphael Augustos
@since 22/10/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Function A131GETFOR(oModel,cAliasTemp,cIndex)
Local cArq			:= ""
Local cArqName	:= "SA2MKT"
Local cCodGrupo		:= ""
Local cDesGrupo		:= ""

Local lRet			:= .F. 
Local lCriaTMP	:= .F.
Local aStru			:=	{}
Local aRet			:= {}
Local aFornecedor	:= {}
Local aAreaSBM		:= {}

Local oWs
Local oCategoria

Local nX			:= 1
Local nY			:= 1

Local cUrl			:= SuperGetMV("MV_CLCBUFO",.F.,"")
Local cCgc			:= SuperGetMV("MV_CLCBCGC",.F.,"")
Local cRazao		:= AllTrim(SM0->M0_NOMECOM)

If Select("SA2MKT") == 0
	If MsFile(cArqName,Nil,"TOPCONN")
		dbUseArea(.T., "TOPCONN", cArqName , "SA2MKT", .T., .F.)
		If dDatabase - SA2MKT->TMP_DATA > 30 //Atualizar fornecedores a cada 30 dias
			cQuery := "DROP TABLE SA2MKT"
			SA2MKT->(dbCloseArea())
			If ( TCSqlExec( cQuery ) < 0)
				Help( ,, "A131GETFOR",, STR0109 + TCSQLError() +'  ', 1, 0 )
				lCriaTMP := .F.
			EndIf
			lCriaTMP	:= .T.
		Endif
	Else
		lCriaTMP	:= .T.	
	Endif
	
	If lCriaTMP
	
		aStru := {}
		AADD(aStru,{"TMP_FILIAL"				,"C", 	Len(cFilAnt)				,0	})
		AADD(aStru,{"TMP_CGC"				,"C", 	14							,0	})
		AADD(aStru,{"TMP_NOME"   			,"C", 	40							,0	})
		AADD(aStru,{"TMP_REPUTA" 			,"N",	1							,0	})
		AADD(aStru,{"TMP_GRUPO" 				,"C",	TAMSX3("BM_GRUPO")[1]	,0	})
		AADD(aStru,{"TMP_DESCGR" 			,"C",	TAMSX3("BM_DESC")[1]	,0	})
		AADD(aStru,{"TMP_DATA"	 			,"D",	8		,0	})
		
		FWDBCreate(cArqName,aStru,"TOPCONN", .T. )
		dbUseArea(.T., "TOPCONN", cArqName , "SA2MKT", .T., .F.)
		DBCreateIndex(cArqName+"1","TMP_GRUPO+TMP_CGC")
		Set Index To (cArqName+"1")
		
		DbSelectArea("SA2MKT")		
		
		aAreaSBM := SBM->(GetArea())
		DbSelectArea("SBM")
		SBM->(DbGoTop())
		While !SBM->(Eof()) .And. xFilial("SBM") == SBM->BM_FILIAL
			cCodGrupo := SBM->BM_GRUPO
			cDesGrupo := AllTrim(SBM->BM_DESC)
			If !Empty(cDesGrupo)
				oWs := WSFornecedorServico():new()
				oWs:_URL 	:=  cUrl			
				oWs:OWSOBJEMPRESALICENCIADA:CSDSEMAILCONTATO		:= ""
				oWs:OWSOBJEMPRESALICENCIADA:CSNMRAZAOSOCIAL		:= cRazao
				oWs:OWSOBJEMPRESALICENCIADA:CSNRCNPJ				:= cCgc
				oWs:OWSOBJEMPRESALICENCIADA:CSNRTELEFONECONTATO	:= "" 			
			
				oCategoria := FornecedorServico_CategoriaDTO():New()
				oCategoria:CSDSCATEGORIA 	:= AllTrim(cDesGrupo)
				oCategoria:CSIDCATEGORIA	 	:= Padl(cCodGrupo,8,"0")
	
				AADD(oWs:OWSLLSTCATEGORIAS:OWSCATEGORIADTO,oCategoria )	
				lRet := oWs:PesquisarMelhores()
	
				If lRet <> NIL .And. lRet
					aRet:= 	oWs:OWSPESQUISARMELHORESRESULT:OWSRESULTADOPESQUISAFORNECEDORDTO
					For nX := 1 To Len(aRet)
						For nY := 1 To Len(aRet[nX]:OWSLSTFORNECEDORES:OWSFORNECEDORDTO)
							RecLock("SA2MKT",.T.)
							SA2MKT->TMP_CGC 		:= aRet[nX]:OWSLSTFORNECEDORES:OWSFORNECEDORDTO[nY]:CSNRCNPJ
							SA2MKT->TMP_NOME 		:= aRet[nX]:OWSLSTFORNECEDORES:OWSFORNECEDORDTO[nY]:CSNMRAZAOSOCIAL
							SA2MKT->TMP_REPUTA	:= aRet[nX]:OWSLSTFORNECEDORES:OWSFORNECEDORDTO[nY]:NDVLREPUTACAO
							SA2MKT->TMP_GRUPO 	:= cCodGrupo
							SA2MKT->TMP_DESCGR	:= cDesGrupo
							SA2MKT->TMP_DATA		:= dDataBase
							SA2MKT->(MsUnLock())
							SA2MKT->(DbSkip())						
						   	
						   	//Não foi documentado e especifica
						  	aRet[nX]:OWSLSTFORNECEDORES:OWSFORNECEDORDTO[nY]:OWSCONTATO:CSDSEMAIL
						   	aRet[nX]:OWSLSTFORNECEDORES:OWSFORNECEDORDTO[nY]:OWSCONTATO:CSNMCONTATO
						   	aRet[nX]:OWSLSTFORNECEDORES:OWSFORNECEDORDTO[nY]:OWSCONTATO:CSNRTELEFONE	
						Next nY
					Next nX
				EndIf
			EndIf
			SBM->(DbSkip())
			FreeObj(oWs)
			FreeObj(oCategoria)
			oCategoria := Nil
			oWs := Nil
		End
		RestArea(aAreaSBM)
	EndIf	
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} a131CalCom
Chamada para função da Página informativa ClicBusiness

@author leonardo.quintania
@since 02/04/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Function a131CalCom(oModel)
Local cUrl:= "http://qaclic.pta.com.br/externo/netmarket/publico/Conteudo.aspx?nCdSite=1&nCdConteudo=69"

ShellExecute("open",cUrl,"","",1)


Return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} a131CalPer
Chamada para função da Página do Perfil do Fornecedor

@author leonardo.quintania
@since 02/04/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function a131CalPer(oModel)
Local cUrl:= "http://www.clicbusiness.com.br/FromExterno.aspx?sNrCnpjLicenciado=11111111111111&sNmRazaoSocialLicenciado=TOTVS&nCdFuncionalidade=97036&sIdUsuario=1&sNrCnpjFornecedor=62691043000118"
/*
sNrCnpjLicenciado: CNPJ da empresa licenciada para uso do ERP
sNmRazaoSocialLicenciado: Razão social da empresa licenciada
nCdFuncionalidade: ID da funcionalidade, será fixo: 97036
sIdUsuario: Login do usuário logado
sNrCnpjFornecedor: CNPJ do fornecedor selecionado na tela
*/
ShellExecute("open",cUrl,"","",1)

Return NIL
//-------------------------------------------------------------------
/*/{Protheus.doc} a131CalBus
Chamada para função da Busca do Fornecedor

@author leonardo.quintania
@since 02/04/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function a131CalBus(oModel)
Local cUrl:= "http://www.clicbusiness.com.br/FromExterno.aspx?sNrCnpjLicenciado=11111111111111&sNmRazaoSocialLicenciado=TOTVS&nCdFuncionalidade=97036&sIdUsuario=1&nIdTipoOrigem=8"
/*
sNrCnpjLicenciado: CNPJ da empresa licenciada para uso do ERP
sNmRazaoSocialLicenciado: Razão social da empresa licenciada
nCdFuncionalidade: ID da funcionalidade, será fixo: 97034
sIdUsuario: Login do usuário logado
nIdTipoOrigem: Tipo do processo, será fixo: 8
nCdOrigem: Receberá o número da Solicitação de Compra (“ord” + número da SC) 
Lista de categorias (Famílias):
sIdCategoria: Código da família (Grupo de produtos) 
sDsCategoria: Descrição da família 
*/
ShellExecute("open",cUrl,"","",1)

Return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} A131VerInt
Verifica se está integrado para Demo do MarketPlace

@author leonardo.quintania
@since 02/04/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Function A131VerInt()
Local lRet			:= .F.
Local lMkPlace	:= SuperGetMv("MV_MKPLACE",.F.,.F.)
Local lMkIntDemo	:= SuperGetMv("MV_MKPLINT",.F.,.F.)
Local lMkAcTermo	:= GetMv("MV_MKPLTAC",.F.,.F.) //Usuario pode ter aceitado.

If !lMkPlace
	If lMkIntDemo 
		If lMkAcTermo		 
			lRet:= .T.
		Else
			A131ExAce()
		EndIf
	EndIf
Endif

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} A131ExAce
Define se exibe ou não Termo de Aceite. 
True = Aceita
False = Não Exibe
@author leonardo.quintania
@since 02/04/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Function A131ExAce()
Local lRet			:= .F.
Local lMkLeTermo	:= SuperGetMv("MV_MKPVIST",.F.,.F.)

If !lMkLeTermo
	GetTermo()
	lRet:= .T.
Endif

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GetTermo
Monta tela de aceite dos termos
@author leonardo.quintania
@since 02/04/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Function GetTermo()
Local oDlg		:= NIL
Local oBtOk	:= NIL  
Local oBtCanc	:= NIL
Local oBtAbr	:= NIL
Local oAceito	:= NIL		       
Local cTexto	:= STR0081 //"Aceito os Termos de Uso da Experiência de uso do Totvs MarketPlace." 
Local lAceito	:= .F.
Local oFonte	:= TFont():New("Tahoma",0,16,,.T.)

DEFINE MSDIALOG oDlg TITLE STR0082 FROM 000,000 TO 200,400 OF oMainWnd PIXEL	//"Termo de Aceite"

@ 005, 005 SAY cTexto FONT oFonte SIZE 200,030 PIXEL OF oDlg //"Aceito os Termos de Uso da Experiência de uso do Totvs MarketPlace." 
@ 035, 005 CHECKBOX oAceito VAR lAceito PROMPT STR0083 SIZE 168, 08	OF oDlg PIXEL //"Li os Termos de Uso e Aceito"
@ 025, 120 BUTTON oBtAbr PROMPT STR0084 SIZE 060, 015 OF oDlg PIXEL ACTION OpenTermo()  //"Abrir os Termos de Uso"

@ 080, 100 BUTTON oBtOk   PROMPT STR0085 SIZE 042, 015 OF oDlg PIXEL ACTION If(lAceito,DoneTermo(oDlg) ,Help("",1,"SELECTERMO", )) //"Confirma"
@ 080, 150 BUTTON oBtCanc PROMPT STR0086  SIZE 042, 015 OF oDlg PIXEL ACTION If(RejTermo(),oDlg:End(),"") //"Cancela"
	
ACTIVATE MSDIALOG oDlg CENTERED	
		 	

Return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} OpenTermo
Efetua abertura do termo de aceite
@author leonardo.quintania
@since 02/04/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function OpenTermo()
Local lRet 		:= .T.
Local aDadosWord	:= {}
Local cArquivo	:= "TermoDeAceite"
Local cArqDest	:= "TermoDeAceite"

AAdd(aDadosWord , {"Adv_Empresa"    , SM0->M0_NOMECOM})
AAdd(aDadosWord , {"Adv_Endereco"   , SM0->M0_ENDCOB})
AAdd(aDadosWord , {"Adv_CNPJ"   	 , SM0->M0_CGC})

A131OpenDot(cArquivo,cArqDest,aDadosWord)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} DoneTermo
Realiza gravação no SX6 dos parametros MV_MKPVIST e MV_MKPLTAC de Aceite
@author leonardo.quintania
@since 02/04/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function DoneTermo(oDlg)
Local lRet := .T.

PutMV("MV_MKPLTAC","T")
PutMV("MV_MKPVIST","T")
A131EnWf()
oDlg:End()

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} RejTermo
Realiza gravação no SX6 dos parametros MV_MKPVIST de Rejeição
@author leonardo.quintania
@since 02/04/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function RejTermo()
Local lRet 		:= .F.
Local cMensagem	:= STR0087//"Esta mensagem não será mais apresentada. Caso deseje aceitar o Termo de Experiência do TOTVS Marketplace utilize o parâmetro MV_MKPVIST através do módulo do configurador do Protheus"
Local nConfirma	:= 0

nConfirma:= Aviso(STR0088,cMensagem,{STR0085,STR0086},1,STR0082)//"Totvs MarketPlace"#"Confirmar"#"Cancelar"#"Termo de Aceite"

If nConfirma # 2
	PutMV("MV_MKPVIST","T")
	lRet:= .T.
EndIf

Return lRet
//-------------------------------------------------------------------
/*/{Protheus.doc} A131OpenDot
Abre o Termo de Aceite do Dot
@author leonardo.quintania
@since 02/04/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Function A131OpenDot(cArquivo,cArqDest,aCampos)

Local cArqDot 	:= cArquivo+".DOT"     //-- Nome do Arquivo MODELO do Word
Local cPathDot	:= AllTrim("\samples\documents\compras\dot\") //-- PATH DO ARQUIVO MODELO WORD
Local nCount		:= 0
Local lRet			:= .F.
Private oWord		:= OLE_CreateLink()
Private nCntLin	:= 0 ; nCntCol := 0
Private cPathEst	:= Alltrim("C:\WORDTMP\") // PATH DO ARQUIVO A SER ARMAZENADO NA ESTAÇÃO

If Empty(cArquivo)
	Return("")
Endif
If Empty(cPathEst)
	cPathEst := "C:\WORDTMP\"
EndIf
MontaDir(cPathEst)
If !File(cPathDot + cArqDot) //-- Verifica a existencia do DOT no ROOTPATH Protheus / Servidor 
	cMsg := STR0008 + cPathDot + cArqDot + STR0009 //-- nao encontrado no Servidor 
	Help("",1,"GCPARQ","",cMsg,1,0)
	Return("")
EndIf
//-- Caso encontre arquivo ja gerado na estacao com o mesmo nome
//-- apaga primeiramente antes de gerar a nova impressao
If File( cPathEst + cArqDot )
	Ferase( cPathEst + cArqDot )
EndIf
//-- Copia do Server para o Remote
CpyS2T(cPathDot+cArqDot,cPathEst,.T.) 

//-- Cria novo arquivo no Word na estacao
OLE_NewFile( oWord, cPathEst + cArqDot)

//--  Preenche Variaveis do .DOT
//--  Verificar nomes de variaveis no .DOT via Word ... atraves da tecla ALT+F9
For nCount:=1 To Len(aCampos)
	OLE_SetDocumentVar(oWord, aCampos[nCount,1], aCampos[nCount,2])
Next nCount
//-- Atualizando as variaveis do documento do Word 
OLE_UpdateFields(oWord)
OLE_SaveAsFile( oWord, cPathEst + cArqDest+".DOC", , , .F.)

//-- Alterado o MsgYesNo para Aviso, retirando a pergunta Sim ou Nao
While .T.
	Aviso(STR0089, STR0090 ,{STR0096})// "Emissão de Termo" / "Deseja fechar o documento ?" / Sim 
		OLE_CloseFile(oWord)	
		OLE_CloseLink(oWord)
		Exit
		lRet:= .T.
EndDo
If File(cPathEst + cArqDest+".DOT")
	FErase(cPathEst + cArqDest+".DOT")'
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} A131EnWf(cEventID, cMensagem)
Função para enviar um WF
@author leonardo.quintania
@since 03/04/2014
@version 1.0
@return NIL
/*/
//-------------------------------------------------------------------
Static Function A131EnWf(cEventID, cMensagem)
Local cUser		:= Alltrim(RetCodUsr())

Default cEventID	:= "059"	//-- Aceite dos Termos do MarketPlace - Tabela generica E3
Default cMensagem	:= STR0091 + cUser  + STR0092//"O Usuario "#"aceitou os termos de uso do marketplace no dia "

EventInsert(FW_EV_CHANEL_ENVIRONMENT, FW_EV_CATEGORY_MODULES, cEventID,FW_EV_LEVEL_INFO,""/*cCargo*/,STR0093,cMensagem)//MarketPlace

Return Nil
//-------------------------------------------------------------------
/*/{Protheus.doc} StructTMP
Cria a estrutura do campos da tabela temporária para a modeldef e viewdef 

@author Raphael.Augustos
@since 02/04/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Function StructTMP(nOpc)
Local oStruTMP

If nOpc == 1
	
	oStruTMP := FWFormModelStruct():New()
	oStruTMP:AddTable("TMP",{" "},STR0110)
	oStruTMP:AddField( ;                                                  
	                        AllTrim('TMP_NOME') , ; 			// [01] C Titulo do campo
	                        AllTrim(STR0111) , ; 			// [02] C ToolTip do campo
	                        'TMP_NOME' , ;               // [03] C identificador (ID) do Field
	                        'C' , ;                     // [04] C Tipo do campo
	                        40 , ;                      // [05] N Tamanho do campo
	                        0 , ;                       // [06] N Decimal do campo
	                        NIL , ;                     // [07] B Code-block de validação do campo
	                        NIL , ;                     // [08] B Code-block de validação When do campo
	                        NIL , ;                     // [09] A Lista de valores permitido do campo
	                        NIL , ;                     // [10] L Indica se o campo tem preenchimento obrigatório
	                        Nil , ;  					// [11] B Code-block de inicializacao do campo
	                        NIL , ;                     // [12] L Indica se trata de um campo chave
	                        NIL , ;                     // [13] L Indica se o campo pode receber valor em uma operação de update.
	                        .T. )                       // [14] L Indica se o campo é virtual
	
	oStruTMP:AddField( ;                                                  
	                        AllTrim('TMP_CGC') , ; 			// [01] C Titulo do campo
	                        AllTrim(STR0112) , ; 			// [02] C ToolTip do campo
	                        'TMP_CGC' , ;         // [03] C identificador (ID) do Field
	                        'C' , ;                     // [04] C Tipo do campo
	                        14 , ;                      // [05] N Tamanho do campo
	                        0 , ;                       // [06] N Decimal do campo
	                        NIL , ;                     // [07] B Code-block de validação do campo
	                        NIL , ;                     // [08] B Code-block de validação When do campo
	                        NIL , ;                     // [09] A Lista de valores permitido do campo
	                        NIL , ;                     // [10] L Indica se o campo tem preenchimento obrigatório
	                        Nil , ;  						// [11] B Code-block de inicializacao do campo
	                        NIL , ;                     // [12] L Indica se trata de um campo chave
	                        NIL , ;                     // [13] L Indica se o campo pode receber valor em uma operação de update.
	                        .T. )                       // [14] L Indica se o campo é virtual
	                        
	oStruTMP:AddField( ;                                                  
	                        AllTrim('TMP_REPUTA') , ; 			// [01] C Titulo do campo
	                        AllTrim(STR0113) , ; 			// [02] C ToolTip do campo
	                        'TMP_REPUTA' , ;         // [03] C identificador (ID) do Field
	                        'N' , ;                     // [04] C Tipo do campo
	                        1 , ;                      // [05] N Tamanho do campo
	                        0 , ;                       // [06] N Decimal do campo
	                        NIL , ;                     // [07] B Code-block de validação do campo
	                        NIL , ;                     // [08] B Code-block de validação When do campo
	                        NIL , ;                     // [09] A Lista de valores permitido do campo
	                        NIL , ;                     // [10] L Indica se o campo tem preenchimento obrigatório
	                        Nil , ;  						// [11] B Code-block de inicializacao do campo
	                        NIL , ;                     // [12] L Indica se trata de um campo chave
	                        NIL , ;                     // [13] L Indica se o campo pode receber valor em uma operação de update.
	                        .T. )                       // [14] L Indica se o campo é virtual
	oStruTMP:AddField( ;                                                  
	                        AllTrim('TMP_GRUPO') , ; 			// [01] C Titulo do campo
	                        AllTrim(STR0114) , ; 			// [02] C ToolTip do campo
	                        'TMP_GRUPO' , ;         // [03] C identificador (ID) do Field
	                        'C' , ;                     // [04] C Tipo do campo
	                        TAMSX3("BM_GRUPO")[1] , ;                      // [05] N Tamanho do campo
	                        0 , ;                       // [06] N Decimal do campo
	                        NIL , ;                     // [07] B Code-block de validação do campo
	                        NIL , ;                     // [08] B Code-block de validação When do campo
	                        NIL , ;                     // [09] A Lista de valores permitido do campo
	                        NIL , ;                     // [10] L Indica se o campo tem preenchimento obrigatório
	                        Nil , ;  						// [11] B Code-block de inicializacao do campo
	                        NIL , ;                     // [12] L Indica se trata de um campo chave
	                        NIL , ;                     // [13] L Indica se o campo pode receber valor em uma operação de update.
	                        .T. )                       // [14] L Indica se o campo é virtual
	                        
	oStruTMP:AddField( ;                                                  
	                        AllTrim('TMP_DESCGR') , ; 			// [01] C Titulo do campo
	                        AllTrim(STR0115) , ; 			// [02] C ToolTip do campo
	                        'TMP_DESCGR' , ;         // [03] C identificador (ID) do Field
	                        'C' , ;                     // [04] C Tipo do campo
	                        TAMSX3("BM_DESC")[1] , ;                      // [05] N Tamanho do campo
	                        0 , ;                       // [06] N Decimal do campo
	                        NIL , ;                     // [07] B Code-block de validação do campo
	                        NIL , ;                     // [08] B Code-block de validação When do campo
	                        NIL , ;                     // [09] A Lista de valores permitido do campo
	                        NIL , ;                     // [10] L Indica se o campo tem preenchimento obrigatório
	                        Nil, ;  						// [11] B Code-block de inicializacao do campo
	                        NIL , ;                     // [12] L Indica se trata de um campo chave
	                        NIL , ;                     // [13] L Indica se o campo pode receber valor em uma operação de update.
	                        .T. )                       // [14] L Indica se o campo é virtual	                        
	                        	                        	                        
ElseIf nOpc == 2

	oStruTMP := FWFormViewStruct():New()
	oStruTMP:AddField( ;                        // Ord. Tipo Desc.
															'TMP_NOME'                       , ;      // [01]  C   Nome do Campo
															'01'                             , ;      // [02]  C   Ordem
															AllTrim( STR0111    )          , ;      // [03]  C   Titulo do campo
															AllTrim( STR0111 )       , ;      // [04]  C   Descricao do campo
															{ '' } , ;      // [05]  A   Array com Help
															'C'                                , ;      // [06]  C   Tipo do campo
															'@!'                               , ;      // [07]  C   Picture
															NIL                                , ;      // [08]  B   Bloco de Picture Var
															''                                 , ;      // [09]  C   Consulta F3
															.F.                                , ;      // [10]  L   Indica se o campo é alteravel
															NIL                                , ;      // [11]  C   Pasta do campo
															NIL                                , ;      // [12]  C   Agrupamento do campo
															NIL                  , ;      // [13]  A   Lista de valores permitido do campo (Combo)
															NIL                                , ;      // [14]  N   Tamanho maximo da maior opção do combo
															NIL                                , ;      // [15]  C   Inicializador de Browse
															.T.                                , ;      // [16]  L   Indica se o campo é virtual
															NIL;                                //, ;      // [17]  C   Picture Variavel
															)        // [18]  L   Indica pulo de linha após o campo
															
	oStruTMP:AddField( ;                                                            // Ord. Tipo Desc.
	                                               'TMP_CGC' , ;                    // [01] C Nome do Campo
	                                               '02' , ;                         // [02] C Ordem
	                                               AllTrim('CNPJ') , ;				   	// [03] C Titulo do campo
	                                               AllTrim( STR0112 ) , ;   	// [04] C Descrição do campo
	                                               { '' } , ;           // [05] A Array com Help
	                                               'C' , ;                          // [06] C Tipo do campo
	                                               '@!' , ;                       // [07] C Picture
	                                               NIL , ;                          // [08] B Bloco de Picture Var
	                                               '' , ;                           // [09] C Consulta F3
	                                               .F. , ;                          // [10] L Indica se o campo é evitável
	                                               NIL , ;                          // [11] C Pasta do campo
	                                               NIL , ;                          // [12] C Agrupamento do campo
	                                               NIL , ;                          // [13] A Lista de valores permitido do campo (Combo)
	                                               NIL , ;                          // [14] N Tamanho Maximo da maior opção do combo
	                                               NIL , ;                          // [15] C Inicializador de Browse
	                                               .T. , ;                          // [16] L Indica se o campo é virtual
	                                               NIL )                            // [17] C Picture Variável
															
															
	oStruTMP:AddField( ;                                                            // Ord. Tipo Desc.
	                                               'TMP_REPUTA' , ;                    // [01] C Nome do Campo
	                                               '03' , ;                         // [02] C Ordem
	                                               AllTrim(STR0116) , ;				   	// [03] C Titulo do campo
	                                               AllTrim( STR0116 ) , ;   	// [04] C Descrição do campo
	                                               { '' } , ;           // [05] A Array com Help
	                                               'N' , ;                          // [06] C Tipo do campo
	                                               '@' , ;                       // [07] C Picture
	                                               NIL , ;                          // [08] B Bloco de Picture Var
	                                               '' , ;                           // [09] C Consulta F3
	                                               .F. , ;                          // [10] L Indica se o campo é evitável
	                                               NIL , ;                          // [11] C Pasta do campo
	                                               NIL , ;                          // [12] C Agrupamento do campo
	                                               NIL , ;                          // [13] A Lista de valores permitido do campo (Combo)
	                                               NIL , ;                          // [14] N Tamanho Maximo da maior opção do combo
	                                               NIL , ;                          // [15] C Inicializador de Browse
	                                               .T. , ;                          // [16] L Indica se o campo é virtual
	                                               NIL )                            // [17] C Picture Variável
	
	
	oStruTMP:AddField( ;                                                            // Ord. Tipo Desc.
	                                               'TMP_GRUPO' , ;                    // [01] C Nome do Campo
	                                               '5' , ;                         // [02] C Ordem
	                                               AllTrim(STR0117) , ;				   	// [03] C Titulo do campo
	                                               AllTrim( STR0118 ) , ;   	// [04] C Descrição do campo
	                                               { '' } , ;           // [05] A Array com Help
	                                               'C' , ;                          // [06] C Tipo do campo
	                                               '@!' , ;                       // [07] C Picture
	                                               NIL , ;                          // [08] B Bloco de Picture Var
	                                               '' , ;                           // [09] C Consulta F3
	                                               .F. , ;                          // [10] L Indica se o campo é evitável
	                                               NIL , ;                          // [11] C Pasta do campo
	                                               NIL , ;                          // [12] C Agrupamento do campo
	                                               NIL , ;                          // [13] A Lista de valores permitido do campo (Combo)
	                                               NIL , ;                          // [14] N Tamanho Maximo da maior opção do combo
	                                               NIL , ;                          // [15] C Inicializador de Browse
	                                               .T. , ;                          // [16] L Indica se o campo é virtual
	                                               NIL )                            // [17] C Picture Variável
												   
	oStruTMP:AddField( ;                                                            // Ord. Tipo Desc.
	                                               'TMP_DESCGR' , ;                    // [01] C Nome do Campo
	                                               '5' , ;                         // [02] C Ordem
	                                               AllTrim(STR0115) , ;				   	// [03] C Titulo do campo
	                                               AllTrim( STR0119 ) , ;   	// [04] C Descrição do campo
	                                               { '' } , ;           // [05] A Array com Help
	                                               'C' , ;                          // [06] C Tipo do campo
	                                               '@!' , ;                       // [07] C Picture
	                                               NIL , ;                          // [08] B Bloco de Picture Var
	                                               '' , ;                           // [09] C Consulta F3
	                                               .F. , ;                          // [10] L Indica se o campo é evitável
	                                               NIL , ;                          // [11] C Pasta do campo
	                                               NIL , ;                          // [12] C Agrupamento do campo
	                                               NIL , ;                          // [13] A Lista de valores permitido do campo (Combo)
	                                               NIL , ;                          // [14] N Tamanho Maximo da maior opção do combo
	                                               NIL , ;                          // [15] C Inicializador de Browse
	                                               .T. , ;                          // [16] L Indica se o campo é virtual
	                                               NIL )                            // [17] C Picture Variável
                                               
EndIf

Return oStruTMP



//-------------------------------------------------------------------
/*/{Protheus.doc} A311RegCot(oModel)
Atualiza a cotação no portal ClicBusiness

@author Flavio Lopes Rasta
@since 04/04/2014
@version 1.0
/*/
//-------------------------------------------------------------------

Function A311RegCot(cNumCot,nOpc,lExcluiT)
Local oWs						:= Nil
Local oCotacao				:= Nil
Local oComprador				:= Nil
Local oWSLstItens 			:= Nil
Local oItem					:= Nil
Local oWSLstParticipantes	:= Nil
Local oIDCot					:= Nil
Local oEmpLic					:= Nil
Local aAreaSC8	:= SC8->( GetArea() )
Local nX 		:= 0
Local nY 		:= 0 
Local lRet 	:= .F.
Local cAliasSC8	:= GetNextAlias()
Local cAliasSC8x	:= GetNextAlias()
Local cQuery 		:= ""
Local cGrupo		:= ""
Local cItem		:= ""
Local cTpExc		:= '*'
DEFAULT lExcluiT := .F.

SC8->(DbSetOrder(4))

BeginSql Alias cAliasSC8
	SELECT 
		SC8.C8_NUM,
		SB1.B1_GRUPO,
		SBM.BM_DESC,
		SC8.C8_ITEM,
		SC8.C8_PRODUTO,
		SB1.B1_DESC,
		SC8.C8_UM,
		SC8.C8_DATPRF,
		SC8.C8_QUANT
	FROM 
		%table:SC8% SC8 INNER JOIN
		%table:SB1% SB1 ON
			SB1.B1_FILIAL = SC8.C8_FILIAL AND
			SB1.B1_COD = SC8.C8_PRODUTO
		INNER JOIN
		%table:SBM% SBM ON
			SBM.BM_FILIAL = SB1.B1_FILIAL AND
			SBM.BM_GRUPO = SB1.B1_GRUPO
	WHERE 
           SC8.C8_NUM = %exp:cNumCot%
     	AND SC8.C8_INTCLIC <> 'E'
		AND SC8.C8_FILIAL = %xfilial:SC8%
		AND SB1.B1_FILIAL = %xfilial:SB1%
		AND SBM.BM_FILIAL = %xfilial:SBM%
		AND SC8.%NotDel%
		AND SB1.%NotDel%
		AND SBM.%NotDel%
	GROUP BY 
		SC8.C8_ITEM,
		SC8.C8_NUM,
		SB1.B1_GRUPO,
		SBM.BM_DESC,	
		SC8.C8_PRODUTO,
		SB1.B1_DESC,
		SC8.C8_UM,
		SC8.C8_DATPRF,
		SC8.C8_QUANT
	ORDER BY SB1.B1_GRUPO,SC8.C8_NUM,SC8.C8_ITEM

EndSql


oWs						:= WSCotacaoServico():new()
oEmpLic				:= CotacaoServico_EmpresaLicenciadaDTO():New()
oCotacao				:= CotacaoServico_CotacaoDTO():New()
oComprador				:= CotacaoServico_CompradorDTO():New()
oWSLstItens 			:= CotacaoServico_ArrayOfItemDTO():New()
oWs:_URL          	:= SuperGetMV("MV_CLCBURL",.F.,"")
oWs:CSIDUSUARIO										:= SuperGetMV("MV_CLCBUSR",.F.,"")
oEmpLic:CSDSEMAILCONTATO								:= SuperGetMV("MV_CLCBCON",.F.,"")
oEmpLic:CSNMRAZAOSOCIAL								:=	AllTrim(SM0->M0_NOMECOM)
oEmpLic:CSNRCNPJ										:=	SuperGetMV("MV_CLCBCGC",.F.,"")
oEmpLic:CSNRTELEFONECONTATO							:=	""

oWs:OWSOBJEMPRESALICENCIADA := oEmpLic

Do Case
	Case nOpc == 1
		//--Inicializa oCotacao
		oCotacao:CSDSPROCESSO 	:= STR0094 + AllTrim(cNumCot+(cAliasSC8)->B1_GRUPO) //"Cotação: "
		oCotacao:CSIDCOTACAO 	:= AllTrim(cNumCot+(cAliasSC8)->B1_GRUPO) 
		oCotacao:CSNRPROCESSO 	:= cNumCot
		oCotacao:CTDTINICIO 		:= SUBSTR(dTos(dDatabase),1, 4)+'-'+SUBSTR(dTos(dDatabase),5,2)+'-'+SUBSTR(dTos(dDatabase),7,2)//"YYYY-MM-DD"
		oCotacao:CTDTTERMINO 	:= SUBSTR((cAliasSC8)->C8_DATPRF,1, 4)+'-'+SUBSTR((cAliasSC8)->C8_DATPRF,5,2)+'-'+SUBSTR((cAliasSC8)->C8_DATPRF,7,2)	//"YYYY-MM-DD"
		oCotacao:LBFLVISIVEL 	:= .T.		
		oComprador:CSNMRAZAOSOCIAL					:= AllTrim(SM0->M0_NOMECOM)
		oComprador:CSNRCNPJ							:= AllTrim(SM0->M0_CGC)
		oComprador:OWSCONTATO						:= CotacaoServico_ContatoDTO():New()
		oComprador:OWSCONTATO:CSDSEMAIL 			:= ""
		oComprador:OWSCONTATO:CSNMCONTATO			:= AllTrim(SM0->M0_NOMECOM)
		oComprador:OWSCONTATO:CSNRTELEFONE			:= ""
		oComprador:OWSENDERECO						:= CotacaoServico_EnderecoDTO():New()	
		oComprador:OWSENDERECO:CSDSCOMPLEMENTO		:= ""
		oComprador:OWSENDERECO:CSDSLOGRADOURO		:= AllTrim(SM0->M0_ENDCOB)
		oComprador:OWSENDERECO:CSIDCIDADE			:= AllTrim(SM0->M0_CODMUN)
		oComprador:OWSENDERECO:CSIDESTADO			:= AllTrim(SM0->M0_ESTCOB)
		oComprador:OWSENDERECO:CSIDPAIS				:= "BR"
		oComprador:OWSENDERECO:CSNMCIDADE			:= AllTrim(SM0->M0_CIDCOB)
		oComprador:OWSENDERECO:CSSGESTADO			:= AllTrim(SM0->M0_ESTCOB)
		oComprador:OWSENDERECO:CSSGPAIS				:= "BR"
		
		cGrupo := (cAliasSC8)->B1_GRUPO 
		cItem  := (cAliasSC8)->C8_ITEM
		While (cAliasSC8)->(!EOF())	
			oItem := CotacaoServico_ItemDTO():New()		
			oItem:CSDSCATEGORIA		:= (cAliasSC8)->BM_DESC			
			oItem:CSDSITEM			:= (cAliasSC8)->B1_DESC	
			oItem:CSIDCATEGORIA		:= Padl((cAliasSC8)->B1_GRUPO,8,"0")
			oItem:CSIDITEM			:= (cAliasSC8)->C8_ITEM		
			oItem:CSSGUNIDADEMEDIDA	:= (cAliasSC8)->C8_UM		
			oItem:CTDTENTREGA			:= SUBSTR((cAliasSC8)->C8_DATPRF,1, 4)+'-'+SUBSTR((cAliasSC8)->C8_DATPRF,5,2)+'-'+SUBSTR((cAliasSC8)->C8_DATPRF,7,2)	//"YYYY-MM-DD"
			oItem:NDQTSOLICITADA		:= (cAliasSC8)->C8_QUANT		
			AADD(oWSLstItens:OWSItemDTO,oItem)	
			(cAliasSC8)->(Dbskip())
			If (cAliasSC8)->(EOF()) .OR. (cAliasSC8)->B1_GRUPO # cGrupo
				oWSLstParticipantes := A311SA2MKT(cGrupo)
				If !Empty(oWSLstParticipantes) 
					oCotacao:OWSCOMPRADOR 			:= oComprador
					oCotacao:oWSLstParticipantes	:= oWSLstParticipantes
					oCotacao:oWSLstItens				:= oWSLstItens
					AADD(oWs:oWSLSTCOTACAO:OWSCOTACAODTO,oCotacao)
				EndIf
				cGrupo 		:= (cAliasSC8)->B1_GRUPO
				oCotacao				:= Nil
				oWSLstItens			:= Nil
				oWSLstParticipantes	:= Nil 
				oWSLstItens			:= CotacaoServico_ArrayOfItemDTO():New()
				oCotacao				:= CotacaoServico_CotacaoDTO():New()
				oWSLstParticipantes	:= CotacaoServico_ArrayOfParticipanteDTO():New()
				oCotacao:CSDSPROCESSO 	:= STR0094+AllTrim(cNumCot+(cAliasSC8)->B1_GRUPO)//"Cotação: "
				oCotacao:CSIDCOTACAO 	:= AllTrim(cNumCot+(cAliasSC8)->B1_GRUPO) 
				oCotacao:CSNRPROCESSO 	:= cNumCot
				oCotacao:CTDTINICIO 		:= SUBSTR(dTos(dDatabase),1, 4)+'-'+SUBSTR(dTos(dDatabase),5,2)+'-'+SUBSTR(dTos(dDatabase),7,2)//"YYYY-MM-DD"
				oCotacao:CTDTTERMINO 	:= SUBSTR((cAliasSC8)->C8_DATPRF,1, 4)+'-'+SUBSTR((cAliasSC8)->C8_DATPRF,5,2)+'-'+SUBSTR((cAliasSC8)->C8_DATPRF,7,2)	//"YYYY-MM-DD"
				oCotacao:LBFLVISIVEL 	:= .T.
			Endif
		EndDo
		lRet 	:= oWs:Registrar()
		SC8->(DbSetOrder(4))
		If	SC8->(DbSeek(xFilial("SC8")+cNumCot))
			While !SC8->(Eof()) .AND. xFilial("SC8")+cNumCot	== SC8->(C8_FILIAL+C8_NUM) 
				If SC8->C8_INTCLIC # "E"
					RecLock("SC8",.F.)
						SC8->C8_INTCLIC := "I"
					MsUnlock()
				Endif
				SC8->(DbSkip())
			End
		Endif	
	Case nOpc == 2 //Encerra
		SC8->(DbSetOrder(4))
		If	SC8->(DbSeek(xFilial("SC8")+cNumCot))
			While !SC8->(Eof()) .AND. xFilial("SC8")+cNumCot	== SC8->(C8_FILIAL+C8_NUM)
				If !Empty(SC8->C8_NUMPED) .And. SC8->C8_INTCLIC == "I"
					oWs:OWSOBJEMPRESALICENCIADA := oEmpLic
					oWs:OWSLSTCOTACAOR:OWSIDENTIFICACAOCOTACAODTO := {}
					oIDCot := CotacaoServico_IdentificacaoCotacaoDTO():New()
					oIDCot:csIDCotacao := AllTrim(cNumCot)+Posicione("SB1",1,xFilial("SB1")+SC8->C8_PRODUTO,"B1_GRUPO")
					oIDCot:OWSLSTITENS := {}
					oIDCotIt:=CotacaoServico_IdentificacaoItemDTO():NEW()
					oIDCotIt:CSIDITEM :=  AllTrim(SC8->C8_ITEM)
					oIDCot:OWSLSTITENS := CotacaoServico_ArrayOfIdentificacaoItemDTO():New()
					AADD(oIDCot:OWSLSTITENS:OWSIDENTIFICACAOITEMDTO,oIDCotIt)	
					AADD( oWs:OWSLSTCOTACAOR:OWSIDENTIFICACAOCOTACAODTO, oIDCot )
					
					lRet:= oWS:Encerrar()
					RecLock("SC8",.F.)
					SC8->C8_INTCLIC := "E"
					MsUnlock()
				EndIf
				SC8->(DbSkip())
			End
		Endif	
	Case nOpc == 3 //Exclui
		If lExcluiT
			cTpExc:=''
		Endif
				
		BeginSql Alias cAliasSC8x
		
		SELECT 
			SB1.B1_GRUPO,SC8.C8_ITEM
		FROM 
			SC8T10 SC8 INNER JOIN
			SB1T10 SB1 ON
				SB1.B1_FILIAL = SC8.C8_FILIAL AND
				SB1.B1_COD = SC8.C8_PRODUTO	
		WHERE SC8.C8_NUM = %exp:cNumCot%
		  AND SC8.C8_INTCLIC <> 'X'
         AND SC8.D_E_L_E_T_ = %exp:cTpExc%
		GROUP BY 
				SB1.B1_GRUPO,SC8.C8_ITEM
		EndSql			
		
		While (cAliasSC8x)->(!EOF())
			oWs:OWSOBJEMPRESALICENCIADA := oEmpLic				
			oWs:OWSLSTCOTACAOR:OWSIDENTIFICACAOCOTACAODTO := {}
			oIDCot := CotacaoServico_IdentificacaoCotacaoDTO():New()
			oIDCot:csIDCotacao := AllTrim(cNumCot)+AllTrim((cAliasSC8x)->B1_GRUPO)
			oIDCot:OWSLSTITENS := {}
			oIDCotIt:=CotacaoServico_IdentificacaoItemDTO():NEW()
			If lExcluiT
				oIDCotIt:CSIDITEM := ""
			Else
				oIDCotIt:CSIDITEM := AllTrim((cAliasSC8x)->C8_ITEM)
			Endif
			oIDCot:OWSLSTITENS := CotacaoServico_ArrayOfIdentificacaoItemDTO():New()
			AADD(oIDCot:OWSLSTITENS:OWSIDENTIFICACAOITEMDTO,oIDCotIt)	
			AADD( oWs:OWSLSTCOTACAOR:OWSIDENTIFICACAOCOTACAODTO, oIDCot )
			lRet:= oWS:Remover()	
			(cAliasSC8x)->(DbSkip())
		End	
			If lExcluiT
				Alert(STR0095)//"Cotação Removida do ClicBusiness"
			Endif
			cQuery := "UPDATE "+RetSqlName("SC8") +" "
			cQuery += "SET C8_INTCLIC = 'X' "
			cQuery += "WHERE C8_NUM = '"+cNumCot+"' "
			cQuery += "AND D_E_L_E_T_ = '*' "
			cQuery += "AND C8_INTCLIC <> 'X' "		
			TCSQLEXEC( cQuery )
EndCase	
RestArea( aAreaSC8 )
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} A311SA2MKT(cGrupo)
Retorna um objeto contendo os participante do ClicBusiness

@author Flavio Lopes Rasta
@since 14/04/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Function A311SA2MKT(cGrupo)
Local cArqName				:= "SA2MKT"
Local cIndex					:= ""
Local oWSLstParticipantes	:= Nil
Local oParticip 				:= Nil

If Select("SA2MKT") == 0 .And. MsFile(cArqName,Nil,"TOPCONN")
	dbUseArea(.T., "TOPCONN", cArqName , "SA2MKT", .T., .F.)
EndIf

If Select("SA2MKT") <> 0 
	SA2MKT->(DbSetOrder(1))
	If SA2MKT->(DbSeek(cGrupo))
		oWSLstParticipantes	:= CotacaoServico_ArrayOfParticipanteDTO():New()
		While !SA2MKT->(EOF()) .And. cGrupo == SA2MKT->TMP_GRUPO
			oParticip := CotacaoServico_ParticipanteDTO():New()			
			oParticip:CSNMRAZAOSOCIAL				:= AllTrim(SA2MKT->TMP_NOME)	
			oParticip:CSNRCNPJ						:= AllTrim(SA2MKT->TMP_CGC)	
			oParticip:OWSCONTATO						:= CotacaoServico_ContatoDTO():New()
			oParticip:OWSCONTATO:CSDSEMAIL 			:= ""
			oParticip:OWSCONTATO:CSNMCONTATO		:= ""
			oParticip:OWSCONTATO:CSNRTELEFONE		:= ""
			oParticip:OWSENDERECO					:= CotacaoServico_EnderecoDTO():New()	
			oParticip:OWSENDERECO:CSDSCOMPLEMENTO	:= ""
			oParticip:OWSENDERECO:CSDSLOGRADOURO	:= ""
			oParticip:OWSENDERECO:CSIDCIDADE		:= ""
			oParticip:OWSENDERECO:CSIDESTADO		:= ""
			oParticip:OWSENDERECO:CSIDPAIS			:= ""
			oParticip:OWSENDERECO:CSNMCIDADE		:= ""
			oParticip:OWSENDERECO:CSSGESTADO		:= ""
			oParticip:OWSENDERECO:CSSGPAIS			:= ""
			AADD(oWSLstParticipantes:OWSParticipanteDTO,oParticip)	
			SA2MKT->(DbSkip())
		End
	EndIf
	SA2MKT->(DbCloseArea())
EndIf

Return oWSLstParticipantes


//-------------------------------------------------------------------
/*/{Protheus.doc} A131RstV(oModel)
Restaura posição inicial da View

@author Flavio Lopes Rasta
@since 15/05/2014
@version 1.0
/*/
//-------------------------------------------------------------------

Function A131RstV(oModel)
Local nX := 0
Local nY := 0
Local lClicB := A131VerInt()

For nX := 1 To oModel:GetModel("SBMDETAIL"):Length()
	oModel:GetModel("SBMDETAIL"):GoLine(nX)
	For nY := 1 To oModel:getModel("SC1DETAIL"):Length()
		oModel:getModel("SC1DETAIL"):GoLine(nY)
		oModel:getModel("SC8DETAIL"):GoLine(1)
		If lClicB
			oModel:getModel("TMPDETAIL"):GoLine(1)
		Endif
	Next nY
	oModel:getModel("SC1DETAIL"):GoLine(1)
Next nX
oModel:GetModel("SBMDETAIL"):GoLine(1)

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} A131GerMail()
Gera corpo do e-mail enviado para informar disponibilidade de retirada
de itens da S.A no armazem.
@author israel.escorizza
@since 24/02/2015
@version P12
/*/
//-------------------------------------------------------------------

Function A131GerMail (cNumCot, cDtEmiCot, aForn)
	Local nI	:= 0
	Local nY	:= 0
	Local cRet	:= ""
	Local aArea := {}
	Local cHTMLSrc 	:= "samples/wf/MATA131_Mail001.html"
	Local cHTMLDst	:= "samples/wf/MATA131_MTmp001.htm" //Destino deve ser .htm pois o metodo :SaveFile salva somente neste formato.
	Local oHTMLBody := Nil
	Local aItem := {}
	Local lMT131AI  := ExistBlock("MT131AI")
	Local nTamCot   := TamSX3("C1_COTACAO")[1]
	Local nTamProd  := TamSX3("C1_PRODUTO")[1]
	Local nTamIdent := TamSX3("C1_IDENT")[1]
	Local lContinua := .T.

	If File( cHTMLSrc )
		oHTMLBody := TWFHTML():New( cHTMLSrc )
	Else
		lContinua := .F.
	EndIf

	If lContinua
		aArea := GetArea()

		oHTMLBody:ValByName('cNumCot',cNumCot)

		//- Cabeçalho do informe.
		oHTMLBody:ValByName('cNomeCli'	, allTrim(SM0->M0_NOMECOM))
		oHTMLBody:ValByName('cDataEmis'	, cDtEmiCot)
		oHTMLBody:ValByName('cCNPJCli'	, SM0->M0_CGC)
		oHTMLBody:ValByName('cEndeCli'	, allTrim(SM0->M0_ENDENT)+" - "+allTrim(SM0->M0_CIDENT)+" - "+allTrim(SM0->M0_ESTENT))
		oHTMLBody:ValByName('cCepCli'	, SM0->M0_CEPENT)
		oHTMLBody:ValByName('cFoneCli'	, allTrim(SM0->M0_TEL))
		
		DbSelectArea("SA2")
		DbSetOrder(1)
		If(SA2->(DBSeek(xFilial("SA2")+aForn[1]+aForn[2])))
			oHTMLBody:ValByName('cNomeFor',allTrim(SA2->A2_NOME))
			oHTMLBody:ValByName('cCNPJFor',allTrim(SA2->A2_CGC))
		EndIf
		
		//- Detalhamento dos itens
		For nI := 1 to Len(aForn[4])
			DbSelectArea("SB1")
			If (SB1->(DBSeek(xFilial("SB1")+aForn[4][nI][1])))
				aADD(oHTMLBody:ValByName('It.cProDesc')	,allTrim(SB1->B1_DESC))
				aADD(oHTMLBody:ValByName('It.cQuant')	,aForn[4][nI][2])
				aADD(oHTMLBody:ValByName('It.cDtEnt')	,Iif(aForn[4][nI][3]>0,cDtEmiCot+aForn[4][nI][3],""))
			EndIf
			If lMT131AI
				SC1->(DbSetOrder(5)) // C1_FILIAL+C1_COTACAO+C1_PRODUTO+C1_IDENT 
				If SC1->(DBSeek(xFilial("SC1")+PadR(cNumCot,nTamCot)+PadR(aForn[4][nI][1],nTamProd)+PadR(aForn[4][nI][4],nTamIdent))) // Posicionar em cada item da SC para carregar os dados do campo observação de acordo com o item. 
					aItem := ExecBlock("MT131AI") // Ponto de Entrada para adicionar mais itens dos campos
					If ValType(aItem) == "A" .And. Len(aItem) > 0
						For nY := 1 to Len(aItem)
							If "It." $ aItem[nY,1]
								aADD(oHTMLBody:ValByName(aItem[nY,1]),aItem[nY,2])
							Else
								oHTMLBody:ValByName(aItem[nY,1],aItem[nY,2])
							EndIf 
						Next nY
					Endif
				EndIf
			EndIf
		Next 
		
		oHTMLBody:SaveFile(cHTMLDst)
		cRet:= MtHTML2Str(cHTMLDst)
		FErase(cHTMLDst)
		RestArea(aArea)
	EndIf

Return cRet

/*/{Protheus.doc} ComMetric
	Média de fornecedores utilizados na Cotação via <FWCustomMetrics>
@author rd.santos
@since 27/05/2021
@return Nil, indefinido
/*/
Static Function ComMetric(nQuant)
Local cIdMetric		:= "compras-protheus_media-fornecedores-cotacao_average"
Local cRotina		:= "mata131"
Local cSubRoutine	:= cRotina+'-media'
Local lContinua		:= (FWLibVersion() >= "20210517") .And. FindClass('FWCustomMetrics')

If lContinua
	FWCustomMetrics():setAverageMetric(cSubRoutine, cIdMetric, nQuant, /*dDateSend*/, /*nLapTime*/,cRotina)
Endif

Return
