#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "MATA162.CH"

#DEFINE CRLF Chr(13) + Chr(10)

//-------------------------------------------------------------------
/*/{Protheus.doc} MATA162
    Análise de Cotações
@author leonardo.magalhaes
@since 22/04/2020
@version 1.0
@return Nil
/*/
//-------------------------------------------------------------------
Function MATA162()

    Local oBrowse   as Object   //-- Objeto que recebe o BrowseDef

    Private aRotina as Array    //-- Private que recebe as opções de Menu

    //-- Inicializar as variáveis
    oBrowse := FWLoadBrw("MATA162")
    aRotina := MenuDef()

    //-- Ativar o Browse principal
    oBrowse:Activate()

    //-- Desativar o Browse principal
    oBrowse:DeActivate()
    
    //-- Limpar a memória
    oBrowse:Destroy()
    FreeObj(oBrowse)
    oBrowse := Nil

Return Nil


//-------------------------------------------------------------------
/*/{Protheus.doc} BrowseDef
    Definição do objeto de browse da rotina.

@author leonardo.magalhaes
@since 19/05/2020
@version 1.0
@return Nil
/*/
//-------------------------------------------------------------------
Static Function BrowseDef() as Object

    Local oRet       as Object      //-- Objeto de retorno do BrowseDef

    Local aLegenda	 as Array       //-- Controle de legenda padrão
    Local aLegUsr	 as Array       //-- Customização de legenda via ponto de entrada

    Local cUsrFilt   as Char        //-- Filtro de usuário para o Browse

    Local lMT162LEG  as Logical     //-- Controla existencia do ponto de entrada MT162LEG
    Local lMT162FIL  as Logical     //-- Controla existencia do ponto de entrada MT162FIL

    Local nX		 as Numeric     //-- Contador para loop

    //-- Inicializar as variáveis
    oRet       := FWMBrowse():New()
    aLegenda   := {}
    aLegUsr    := {}
    cUsrFilt   := ""
    lMT162LEG  := ExistBlock("MT162LEG")
    lMT162FIL  := ExistBlock("MT162FIL")
    nX         := 0

    //-- Configurar objeto de browse
    oRet:SetAlias("DHU") //-- Tabela DHU (Cabeçalho da Cotação)
    oRet:SetDescription(STR0004) //-- "Análise de Cotação"
    oRet:DisableDetails() //-- Desabilita a apresentação dos detalhes no Browse	

    //-- Definir as legendas do padrão
    AAdd(aLegenda, {"DHU_STATUS == '1'", "GREEN" , STR0001}) //-- "Cotação não analisada"
    AAdd(aLegenda, {"DHU_STATUS == '2'", "YELLOW", STR0002}) //-- "Cotação analisada parcialmente"
    AAdd(aLegenda, {"DHU_STATUS == '3'", "RED"   , STR0003}) //-- "Cotação totalmente analisada"

    //-- Customizar legendas
    If lMT162LEG
        aLegUsr := ExecBlock("MT162LEG", .F., .F., {aLegenda})
        If ValType(aLegUsr) == "A" .And. Len(aLegUsr) > 0
            aLegenda := aClone(aLegUsr)
        EndIf
    EndIf

    //-- Adicionar as legendas ao objeto de browse
    For nX := 1 To Len(aLegenda)
        If Len(aLegenda[nX]) >= 3
            oRet:AddLegend(aLegenda[nX][1], aLegenda[nX][2], aLegenda[nX][3])
        EndIf
    Next nX				

    //-- Customizar filtro de browse
    If lMT162FIL
        cUsrFilt := ExecBlock("MT162FIL", .F., .F., {"DHU"})
        If ValType(cUsrFilt) == "C" .And. !Empty(cUsrFilt)
            oRet:SetFilterDefault(cUsrFilt)
        EndIf
    EndIf

    //-- Limpar memória
    ASize(aLegenda, 0)
    aLegenda := Nil
    
    ASize(aLegUsr, 0)
    aLegUsr := Nil

Return oRet


//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
    Definição do menu de opções.

@author leonardo.magalhaes
@since 22/04/2020
@version 1.0
@return Nil
/*/
//-------------------------------------------------------------------
Static Function MenuDef() as Array

    Local aRet       as Array   //-- Retorno com as opções do MenuDef
    Local aRetUsr    as Array   //-- Auxiliar para considerar opções de usuário

    Local lMT162BUT  as Logical //-- Controla existencia do Ponto de Entrada MT162BUT

    //-- Inicializar as variáveis
    aRet      := {}
    aRetUsr   := {}
    lMT162BUT := ExistBlock("MT162BUT")

    //-- Definir as opções do padrão
    ADD OPTION aRet TITLE STR0005 ACTION "PesqBrw" OPERATION 1 ACCESS 0 //-- "Pesquisar"
    ADD OPTION aRet TITLE STR0021 ACTION "A162Vis" OPERATION 2 ACCESS 0 //-- "Visualizar"
    ADD OPTION aRet TITLE STR0017 ACTION "A162Imp" OPERATION 3 ACCESS 0 //-- "Importar"
    ADD OPTION aRet TITLE STR0006 ACTION "A162Anl" OPERATION 4 ACCESS 0 //-- "Analisar"
    ADD OPTION aRet TITLE STR0007 ACTION "MsDocument" OPERATION 4 ACCESS 0 //-- "Conhecimento"

    //-- Customizar as opções
    If lMT162BUT
        aRetUsr := ExecBlock("MT162BUT", .F., .F., {aRet})
        If ValType(aRetUsr) == "A" .And. Len(aRetUsr) > 0
            aRet := AClone(aRetUsr)
        EndIf
    EndIf

    //-- Limpar a memória
    ASize(aRetUsr, 0)
    aRetUsr := Nil

Return aRet


//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
    Definição do modelo de dados.

@author leonardo.magalhaes
@since 22/04/2020
@version 1.0
@return Nil
/*/
//-------------------------------------------------------------------
Static Function ModelDef() as Object

    Local oModel      as Object //-- Modelo de dados
    Local oStruDHU    as Object //-- Estrutura do cabeçalho
    Local oStruDHV    as Object //-- Estrutura do grid de produtos
    Local oStruSC8    as Object //-- Estrutura do grid de propostas de fornecimento
    Local oStruSCE    as Object //-- Estrutura do grid de encerramento de cotações
    Local oStruSCEQry as Object //-- Estrutura do grid de encerramento de cotações
    Local bInCusTot1  as Block  //-- Bloco de inicialização do campo C8_CUSTO1
    Local bInCusUni1  as Block  //-- Bloco de inicialização do campo C8_CUSUNI1

    //-- Inicializar as variáveis
    oModel      := MPFormModel():New("MATA162", /*bPre*/, /*bPos*/, /*bCommit*/, /*bCancel*/)
    oStruDHU    := FWFormStruct(1, "DHU")
    oStruDHV    := FWFormStruct(1, "DHV")
    oStruSC8    := FWFormStruct(1, "SC8")
    oStruSCE    := FWFormStruct(1, "SCE")
    oStruSCEQry := FWFormStruct(1, "SCE")

    bInCusTot1 := FWBuildFeature(STRUCT_FEATURE_INIPAD, "A162Custo(1)")
    bInCusUni1 := FWBuildFeature(STRUCT_FEATURE_INIPAD, "A162Custo(2)")

    //-- Campos adicionais - DHU
        oStruDHU:AddField( ;
                            AllTrim("") , ; 							// [01] C Titulo do campo
                            AllTrim("") , ; 							// [02] C ToolTip do campo
                            "DHU_AVAUT", ;              	 		    // [03] C identificador (ID) do Field
                            "L" , ;                     				// [04] C Tipo do campo
                            1 , ;                       				// [05] N Tamanho do campo
                            0 , ;                       				// [06] N Decimal do campo
                            NIL , ;                     				// [07] B Code-block de validação do campo
                            NIL , ;                     				// [08] B Code-block de validação When do campo
                            NIL , ;                     				// [09] A Lista de valores permitido do campo
                            NIL , ;                     				// [10] L Indica se o campo tem preenchimento obrigatório
                            {|| .F.}, ;	                                // [11] B Code-block de inicializacao do campo
                            NIL , ;                     				// [12] L Indica se trata de um campo chave
                            NIL , ;                     				// [13] L Indica se o campo pode receber valor em uma operação de update.
                            .T. ) 

    //-- Campos adicionais - DHV
        oStruDHV:AddField( ;
                            AllTrim("") , ; 							  // [01] C Titulo do campo
                            AllTrim("") , ; 							  // [02] C ToolTip do campo
                            "DHV_LEGEND", ;              	 		      // [03] C identificador (ID) do Field
                            "C" , ;                     				  // [04] C Tipo do campo
                            50 , ;                      				  // [05] N Tamanho do campo
                            0 , ;                       				  // [06] N Decimal do campo
                            NIL, ;                                        // [07] B Code-block de validação do campo
                            NIL , ;                     				  // [08] B Code-block de validação When do campo
                            NIL , ;                     				  // [09] A Lista de valores permitido do campo
                            NIL , ;                     				  // [10] L Indica se o campo tem preenchimento obrigatório
                            {|| A162SetLeg("DHV_LEGEND", oModel, 1)}, ;   // [11] B Code-block de inicializacao do campo
                            NIL , ;                     				  // [12] L Indica se trata de um campo chave
                            NIL , ;                     				  // [13] L Indica se o campo pode receber valor em uma operação de update.
                            .T. ) 

    //-- Campos adicionais - SC8
        oStruSC8:AddField( ;
                            AllTrim("") , ; 							// [01] C Titulo do campo
                            AllTrim("") , ; 							// [02] C ToolTip do campo
                            "C8_MARKW" , ;              	 		    // [03] C identificador (ID) do Field
                            "L" , ;                     				// [04] C Tipo do campo
                            1 , ;                      				    // [05] N Tamanho do campo
                            0 , ;                       				// [06] N Decimal do campo
                            {|| A162VldMkW(oModel)}, ;                  // [07] B Code-block de validação do campo
                            NIL , ;                     				// [08] B Code-block de validação When do campo
                            NIL , ;                     				// [09] A Lista de valores permitido do campo
                            NIL , ;                     				// [10] L Indica se o campo tem preenchimento obrigatório
                            {|| .F.}, ;	                                // [11] B Code-block de inicializacao do campo
                            NIL , ;                     				// [12] L Indica se trata de um campo chave
                            NIL , ;                     				// [13] L Indica se o campo pode receber valor em uma operação de update.
                            .T. ) 

        oStruSCE:AddField( ;
                            AllTrim("") , ; 							// [01] C Titulo do campo
                            AllTrim("") , ; 							// [02] C ToolTip do campo
                            "CE_LEGEND" , ;              	 		    // [03] C identificador (ID) do Field
                            "C" , ;                     				// [04] C Tipo do campo
                            50 , ;                      				// [05] N Tamanho do campo
                            0 , ;                       				// [06] N Decimal do campo
                            NIL, ;                                      // [07] B Code-block de validação do campo
                            NIL , ;                     				// [08] B Code-block de validação When do campo
                            NIL , ;                     				// [09] A Lista de valores permitido do campo
                            NIL , ;                     				// [10] L Indica se o campo tem preenchimento obrigatório
                            {|| ""}, ;	                                // [11] B Code-block de inicializacao do campo
                            NIL , ;                     				// [12] L Indica se trata de um campo chave
                            NIL , ;                     				// [13] L Indica se o campo pode receber valor em uma operação de update.
                            .T. )

        oStruSCEQry:AddField( ;
                            AllTrim("") , ; 							// [01] C Titulo do campo
                            AllTrim("") , ; 							// [02] C ToolTip do campo
                            "CE_LEGEND" , ;              	 		    // [03] C identificador (ID) do Field
                            "C" , ;                     				// [04] C Tipo do campo
                            50 , ;                      				// [05] N Tamanho do campo
                            0 , ;                       				// [06] N Decimal do campo
                            NIL, ;                                      // [07] B Code-block de validação do campo
                            NIL , ;                     			    // [08] B Code-block de validação When do campo
                            NIL , ;                     				// [09] A Lista de valores permitido do campo
                            NIL , ;                     				// [10] L Indica se o campo tem preenchimento obrigatório
                            {|| "BR_PRETO"}, ;	                        // [11] B Code-block de inicializacao do campo
                            NIL , ;                     				// [12] L Indica se trata de um campo chave
                            NIL , ;                     				// [13] L Indica se o campo pode receber valor em uma operação de update.
                            .T. )
    
    
    //-- Configurar gatilhos para DHV
    oStruDHV:AddTrigger("DHV_SALDO" /*cIdField*/, "DHV_TOTAL" /*cTargetIdField*/, {||.T.} /*bPre*/, {|| A162DHVTot(oModel)} /*bSetValue*/)
    
    //-- Configurar gatilhos para SC8
    oStruSC8:AddTrigger("C8_MARKW" /*cIdField*/, "C8_MARKW" /*cTargetIdField*/, {|| .T.} /*bPre*/, {||A162FillSCE(oModel)} /*bSetValue*/)
    
    //-- Configurar gatilhos para SCE
    oStruSCE:AddTrigger("CE_QUANT" /*cIdField*/, "CE_TOTAL" /*cTargetIdField*/, {||.T.} /*bPre*/, {|| A162SCETot(oModel)} /*bSetValue*/)
    
    //-- Configurar inicializador padrão de custos
    oStruSC8:SetProperty("C8_CUSTO1", MODEL_FIELD_INIT, bInCusTot1)
    oStruSC8:SetProperty("C8_CUSUNI1", MODEL_FIELD_INIT, bInCusUni1)

    //-- Adicionar submodelo de edição por campo (FormField)
    oModel:AddFields("DHUMASTER" /*cId*/, /*cOwner*/, oStruDHU /*oModelStruct*/, /*bPre*/, /*bPost*/, /*bLoad*/)
    
    //-- Adicionar submodelos de edição por grid (FormGrid)
    oModel:AddGrid("DHVDETAIL" /*cId*/, "DHUMASTER" /*cOwner*/, oStruDHV /*oModelStruct*/, /*bLinePre*/, /*bLinePost*/, /*bPre*/, /*bPost*/, /*bLoad*/)
    oModel:AddGrid("SC8DETAIL" /*cId*/, "DHVDETAIL" /*cOwner*/, oStruSC8 /*oModelStruct*/, {|oGridModel, nLine, cAction, cIDField, xValue, xCurrentValue| A162SC8LPre(oGridModel, nLine, cAction, cIDField, xValue, xCurrentValue)}/*bLinePre*/, /*bLinePost*/, /*bPre*/, /*bPost*/, /*bLoad*/)
    oModel:AddGrid("SCEDETAIL" /*cId*/, "DHVDETAIL" /*cOwner*/, oStruSCE /*oModelStruct*/, {|oGridModel, nLine, cAction, cIDField, xValue, xCurrentValue| A162SCELPre(oGridModel, nLine, cAction, cIDField, xValue, xCurrentValue)} /*bLinePre*/, /*bLinePost*/, /*bPre*/, /*bPost*/, /*bLoad*/)
    oModel:AddGrid("SCEQRY" /*cId*/, "DHVDETAIL" /*cOwner*/, oStruSCEQry /*oModelStruct*/, /*bLinePre*/, /*bLinePost*/, /*bPre*/, /*bPost*/, /*bLoad*/)

    //-- Atribuir a chave primária da entidade Modelo
    oModel:SetPrimaryKey({"DHU_FILIAL", "DHU_NUM"})

    //-- Atribuir o critério de relacionamento entre os submodelos
    oModel:SetRelation("DHVDETAIL" , {{"DHV_FILIAL", "xFilial('DHV')"}, {"DHV_NUM", "DHU_NUM"}}, DHV->(IndexKey(1))) //-- DHV_FILIAL, DHV_NUM, DHV_ITEM, DHV_PRODUTO
    oModel:SetRelation("SC8DETAIL" , {{"C8_FILIAL", "xFilial('SC8')"}, {"C8_NUM", "DHV_NUM"}, {"C8_IDENT", "DHV_ITEM"}, {"C8_PRODUTO", "DHV_CODPRO"}}, SC8->(IndexKey(3))) //-- C8_FILIAL, C8_NUM, C8_FORNECE, C8_LOJA, C8_ITEM, C8_NUMPRO, C8_ITEMGRD
    oModel:SetRelation("SCEDETAIL", {{"CE_FILIAL", "xFilial('SCE')"}, {"CE_NUMCOT", "DHV_NUM"}, {"CE_IDENT", "DHV_ITEM"}, {"CE_PRODUTO", "DHV_CODPRO"}, {"CASE WHEN LTRIM(RTRIM(CE_NUMPED)) = '' AND LTRIM(RTRIM(CE_NUMCTR)) = '' THEN '1' ELSE '0' END", "'1'"}}, SCE->(IndexKey(2))) //-- CE_FILIAL+CE_NUMCOT+CE_ITEMCOT+CE_PRODUTO+CE_ITEMGRD+CE_FORNECE+CE_LOJA+CE_NUMPRO+CE_IDENT+CE_SEQ
    oModel:SetRelation("SCEQRY", {{"CE_FILIAL", "xFilial('SCE')"}, {"CE_NUMCOT", "DHV_NUM"}, {"CE_IDENT", "DHV_ITEM"}, {"CE_PRODUTO", "DHV_CODPRO"}, {"CASE WHEN LTRIM(RTRIM(CE_NUMPED)) = '' AND LTRIM(RTRIM(CE_NUMCTR)) = '' THEN '1' ELSE '0' END", "'0'"}}, SCE->(IndexKey(2))) //-- CE_FILIAL+CE_NUMCOT+CE_ITEMCOT+CE_PRODUTO+CE_ITEMGRD+CE_FORNECE+CE_LOJA+CE_NUMPRO+CE_IDENT+CE_SEQ

    //-- Atribuir uma descrição ao modelo
    oModel:SetDescription(STR0026) //-- "Cotação"

    //-- Definir chave única dos grids
    oModel:GetModel("DHVDETAIL"):SetUniqueLine({"DHV_ITEM", "DHV_CODPRO"})
    oModel:GetModel("SC8DETAIL"):SetUniqueLine({"C8_NUM", "C8_FORNECE", "C8_LOJA", "C8_FORNOME", "C8_NUMPRO"})
    oModel:GetModel("SCEDETAIL"):SetUniqueLine({"CE_NUMCOT", "CE_IDENT", "CE_PRODUTO","CE_FORNECE", "CE_LOJA", "CE_NUMPRO", "CE_SEQ"})

    //-- Definir grids que não podem receber inserção/exclusão/atualização de linhas
        //-- DHV - Produtos
        oModel:GetModel("DHVDETAIL"):SetNoInsertLine(.T.)
        oModel:GetModel("DHVDETAIL"):SetNoDeleteLine(.T.)

        //-- SC8 - Propostas de Fornecimento
        oModel:GetModel("SC8DETAIL"):SetNoInsertLine(.T.)
        oModel:GetModel("SC8DETAIL"):SetNoDeleteLine(.T.)

        //-- SCE - Encerramento
        oModel:GetModel("SCEDETAIL"):SetNoInsertLine(.T.)
        oModel:GetModel("SCEDETAIL"):SetNoUpdateLine(.T.)
    
    //-- Definir grid como opcional
    oModel:SetOptional("SCEDETAIL", .T.)
    oModel:SetOptional("SCEQRY", .T.)
    oModel:GetModel("SCEQRY"):SetOnlyView("SCEQRY")

    //-- Configurar modo de edição de campos
        //-- DHV - Produtos
        oModel:GetModel("DHVDETAIL"):GetStruct():SetProperty("*", MODEL_FIELD_WHEN, {|| .F.})

        //-- SC8 - Propostas de Fornecimento
        oModel:GetModel("SC8DETAIL"):GetStruct():SetProperty("*", MODEL_FIELD_WHEN, {|| .F.})
        oModel:GetModel("SC8DETAIL"):GetStruct():SetProperty("C8_MARKW", MODEL_FIELD_WHEN, {|| .T.})

        //-- SCE - Encerramento
        oModel:GetModel("SCEDETAIL"):GetStruct():SetProperty("*", MODEL_FIELD_WHEN, {|| .F.})
        oModel:GetModel("SCEDETAIL"):GetStruct():SetProperty("CE_QUANT", MODEL_FIELD_WHEN, {|| .T.})
        oModel:GetModel("SCEDETAIL"):GetStruct():SetProperty("CE_MOTVENC", MODEL_FIELD_WHEN, {|| .T.})

    //-- Bloco de validação de ativação do modelo
    oModel:SetVldActive({|oModel| A162VldAtv(oModel)})

    //-- Instalar eventos
    oModel:InstallEvent("EVDEF",, MATA162EVDEF():New())

Return oModel


//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
    Definição da interface visual.

@author leonardo.magalhaes
@since 22/04/2020
@version 1.0
@return Nil
/*/
//-------------------------------------------------------------------
Static Function ViewDef() as Object

    Local oModel as Object  //-- Modelo de dados
    Local oView as Object  //-- View
    Local oStruDHU as Object  //-- Estrutura do header
    Local oStruDHV as Object  //-- Estrutura do grid de Produtos
    Local oStruSC8 as Object  //-- Estrutura do grid de Fornecedores
    Local oStruSCE as Object  //-- Estrutura do grid de Histórico da Cotação
    Local oStruSCEQry as Object  //-- Estrutura do grid de Análises Anteriores

    Local lIntGC as Logical //-- Integração com de Gestão de Concessionárias

    //-- Inicializar as variáveis
    oModel      := FWLoadModel("MATA162")
    oView       := FWFormView():New()
    lIntGC      := SuperGetMv("MV_VEICULO", .F., "N") == "S"
    oStruDHU    := FWFormStruct(2, "DHU", {|cCampo| !(AllTrim(cCampo) $ "DHU_STATUS|DHU_ORIGEM")})
    oStruDHV    := FWFormStruct(2, "DHV", {|cCampo| !(AllTrim(cCampo) $ "DHV_NUM|DHV_STATUS|DHV_ORIGEM")})
    oStruSC8    := FWFormStruct(2, "SC8", {|cCampo| !(AllTrim(cCampo) $ "C8_NUM|C8_ITEM|C8_PRODUTO|C8_IDENT|C8_QUANT|C8_UM|C8_SEGUM|C8_QTSEGUM|C8_MARKAUD|C8_CODED|C8_NUMPR|C8_NUMSC|C8_ITEMSC|C8_ITEMGRD|C8_NUMCON|C8_NUMPED|C8_ITEMPED|C8_GRADE|C8_GRUPCOM|C8_WF|C8_TPDOC|C8_OK|C8_ITSCGRD|C8_ACCNUM|C8_ACCITEM|C8_ORIGEM|C8_MOTVENC") .And. !(AllTrim(cCampo) == "C8_DESCRI")})
    oStruSCE    := FWFormStruct(2, "SCE", {|cCampo| Iif(lIntGC, .T., !AllTrim(cCampo) $ "CE_CODITE|CE_CODGRP")})
    oStruSCEQry := FWFormStruct(2, "SCE", {|cCampo| Iif(lIntGC, .T., !AllTrim(cCampo) $ "CE_CODITE|CE_CODGRP")})

    //-- Campos adicionais - DHV
        oStruDHV:AddField( ;                                // Ord. Tipo Desc.
                            "DHV_LEGEND" , ;             	// [01] C Nome do Campo
                            "00" , ;                     	// [02] C Ordem
                            AllTrim("") , ;				    // [03] C Titulo do campo
                            "" , ;					        // [04] C Descrição do campo
                            { "" } , ;   		    	    // [05] A Array com Help
                            "C" , ;                      	// [06] C Tipo do campo
                            "@BMP" , ;                   	// [07] C Picture
                            NIL , ;                      	// [08] B Bloco de Picture Var
                            "" , ;                       	// [09] C Consulta F3
                            .F. , ;                      	// [10] L Indica se o campo é editável
                            NIL , ;                      	// [11] C Pasta do campo
                            NIL , ;                      	// [12] C Agrupamento do campo
                            NIL , ;                      	// [13] A Lista de valores permitido do campo (Combo)
                            NIL , ;                      	// [14] N Tamanho Maximo da maior opção do combo
                            NIL , ;                         // [15] C Inicializador de Browse
                            .T. , ;                      	// [16] L Indica se o campo é virtual
                            NIL ) 

    //-- Campos adicionais - SC8
        oStruSC8:AddField( ;                                // Ord. Tipo Desc.
                            "C8_MARKW" , ;             	    // [01] C Nome do Campo
                            "00" , ;                     	// [02] C Ordem
                            AllTrim("") , ;				    // [03] C Titulo do campo
                            "" , ;					        // [04] C Descricao completa do campo
                            { "" } , ;   		    	    // [05] A Array com o Help dos campos
                            "L" , ;                      	// [06] C Tipo do campo
                            "@BMP" , ;                   	// [07] C Picture
                            Nil , ;                      	// [08] B Bloco de Picture Var
                            "" , ;                       	// [09] C Consulta F3
                            .T. , ;                      	// [10] L Indica se o campo é editável
                            Nil , ;                      	// [11] C Pasta do campo
                            Nil , ;                      	// [12] C Agrupamento do campo
                            Nil , ;                      	// [13] A Lista de valores permitido do campo (Combo)
                            Nil , ;                      	// [14] N Tamanho Maximo da maior opção do combo
                            Nil , ;                         // [15] C Inicializador de Browse
                            .T. , ;                      	// [16] L Indica se o campo é virtual
                            Nil , ;                         // [17] C Picture Variavel
                            Nil , ;                         // [18] L Indica pulo de linha após o campo
                            Nil )                           // [19] N Largura fixa da apresentação do campo

    //-- Campos adicionais - SCE
        oStruSCE:AddField( ;                                // Ord. Tipo Desc.
                            "CE_LEGEND" , ;             	// [01] C Nome do Campo
                            "00" , ;                     	// [02] C Ordem
                            AllTrim("") , ;				    // [03] C Titulo do campo
                            "" , ;					        // [04] C Descrição do campo
                            { "" } , ;   		    	    // [05] A Array com Help
                            "C" , ;                      	// [06] C Tipo do campo
                            "@BMP" , ;                   	// [07] C Picture
                            NIL , ;                      	// [08] B Bloco de Picture Var
                            "" , ;                       	// [09] C Consulta F3
                            .F. , ;                      	// [10] L Indica se o campo é editável
                            NIL , ;                      	// [11] C Pasta do campo
                            NIL , ;                      	// [12] C Agrupamento do campo
                            NIL , ;                      	// [13] A Lista de valores permitido do campo (Combo)
                            NIL , ;                      	// [14] N Tamanho Maximo da maior opção do combo
                            NIL , ;                         // [15] C Inicializador de Browse
                            .T. , ;                      	// [16] L Indica se o campo é virtual
                            Nil , ;                         // [17] C Picture Variavel
                            Nil , ;                         // [18] L Indica pulo de linha após o campo
                            Nil )                           // [19] N Largura fixa da apresentação do campo

        oStruSCEQry:AddField( ;                                // Ord. Tipo Desc.
                            "CE_LEGEND" , ;             	// [01] C Nome do Campo
                            "00" , ;                     	// [02] C Ordem
                            AllTrim("") , ;				    // [03] C Titulo do campo
                            "" , ;					        // [04] C Descrição do campo
                            { "" } , ;   		    	    // [05] A Array com Help
                            "C" , ;                      	// [06] C Tipo do campo
                            "@BMP" , ;                   	// [07] C Picture
                            NIL , ;                      	// [08] B Bloco de Picture Var
                            "" , ;                       	// [09] C Consulta F3
                            .F. , ;                      	// [10] L Indica se o campo é editável
                            NIL , ;                      	// [11] C Pasta do campo
                            NIL , ;                      	// [12] C Agrupamento do campo
                            NIL , ;                      	// [13] A Lista de valores permitido do campo (Combo)
                            NIL , ;                      	// [14] N Tamanho Maximo da maior opção do combo
                            NIL , ;                         // [15] C Inicializador de Browse
                            .T. , ;                      	// [16] L Indica se o campo é virtual
                            Nil , ;                         // [17] C Picture Variavel
                            Nil , ;                         // [18] L Indica pulo de linha após o campo
                            Nil )                           // [19] N Largura fixa da apresentação do campo


    //-- Definir o relacionamento da View com o Model
    oView:SetModel(oModel)

    //-- Adicionar um formulário do tipo FormFields
    oView:AddField("VIEW_DHU", oStruDHU, "DHUMASTER")

    //-- Adicionar um formulário do tipo FWFormGrid
    oView:AddGrid("VIEW_DHV", oStruDHV, "DHVDETAIL")
    oView:AddGrid("VIEW_SC8", oStruSC8, "SC8DETAIL")
    oView:AddGrid("VIEW_SCE", oStruSCE, "SCEDETAIL")
    oView:AddGrid("VIEW_QRY", oStruSCEQry, "SCEQRY")

    //-- Instanciar box superior (Critérios de Avaliação)
    oView:CreateHorizontalBox("TOPBOX", 20)
    oView:CreateFolder("TOPFLD", "TOPBOX")
    oView:CreateVerticalBox("TOPVERT1", 100, "TOPBOX")
    oView:CreateVerticalBox("TOPVERT2", 100, "TOPBOX", .T.)
    oView:AddOtherObject("OTHER_PANEL1", {|oPanel| A162Buttons(oPanel, oView, oModel, "DHUMASTER")}) //-- Botões do cabeçalho

    //-- Instanciar box médio (Produtos)
    oView:CreateHorizontalBox("MIDBOX", 30)
    oView:CreateVerticalBox("MIDVERT1", 100, "MIDBOX")
    oView:CreateVerticalBox("MIDVERT2", 100, "MIDBOX", .T.)
    oView:AddOtherObject("OTHER_PANEL2", {|oPanel| A162Buttons(oPanel, oView, oModel, "DHVDETAIL")}) //-- Botões do grid de Produtos

    //-- Instanciar box inferior (Propostas de Fornecimento e Encerramento)
    oView:CreateHorizontalBox("DOWNBOX", 50)
    oView:CreateFolder("DOWNFLD", "DOWNBOX")
    oView:AddSheet("DOWNFLD", "PROPSHEET", STR0010) //-- "Propostas de Fornecimento"
    oView:CreateVerticalBox("DOWNVERT1", 100, /*cOwner*/, /*lUsePixel*/, "DOWNFLD", "PROPSHEET")
    oView:CreateVerticalBox("DOWNVERT2", 100, /*cOwner*/, .T. , "DOWNFLD", "PROPSHEET")
    
    oView:AddSheet("DOWNFLD", "AUDITSHEET", STR0060) //-- "Encerramento"
    oView:CreateHorizontalBox( "AUDITBOX", 100, , .F., "DOWNFLD", "AUDITSHEET")
	oView:CreateFolder( "AUDITFLD", "AUDITBOX")
    oView:AddSheet("AUDITFLD","AUDITSH1", STR0023) //-- "Análise Atual"
	oView:AddSheet("AUDITFLD","AUDITSH2", STR0024) //-- "Histórico da Cotação"
    oView:CreateHorizontalBox("AUDITBX1", 100, /*cOwner*/, /*lUsePixel*/, "AUDITFLD", "AUDITSH1")
    oView:CreateHorizontalBox("AUDITBX2", 100, /*cOwner*/, /*lUsePixel*/, "AUDITFLD", "AUDITSH2")
    oView:AddOtherObject("OTHER_PANEL3", {|oPanel| A162Buttons(oPanel, oView, oModel, "SC8DETAIL")}) //-- Botões do grid de Propostas de Fornecimento

    //-- Relacionar o ID da View com os boxes para exibição
    oView:SetOwnerView("VIEW_DHU", "TOPVERT1")
    oView:SetOwnerView("VIEW_DHV", "MIDVERT1")
    oView:SetOwnerView("VIEW_SC8", "DOWNVERT1")
    oView:SetOwnerView("VIEW_SCE", "AUDITBX1")
    oView:SetOwnerView("VIEW_QRY", "AUDITBX2")
    oView:SetOwnerView("OTHER_PANEL1", "TOPVERT2")
    oView:SetOwnerView("OTHER_PANEL2", "MIDVERT2")
    oView:SetOwnerView("OTHER_PANEL3", "DOWNVERT2")

    //-- Definir propriedades de filtro e pesquisa nos grids
    oView:SetViewProperty("*", "ENABLENEWGRID") 
    oView:SetViewProperty("DHVDETAIL", "GRIDNOORDER") 
    oView:SetViewProperty("DHVDETAIL", "GRIDFILTER", {.T.}) 
    oView:SetViewProperty("*", "GRIDSEEK", {.T.})

    //-- Definir propriedades de duplo clique nos grids
    oView:SetViewProperty("VIEW_DHV", "GRIDDOUBLECLICK", {{|oView, cFieldName, nLineGrid, nLineModel| A162GdDbCl(oView, cFieldName, nLineGrid, nLineModel)}}) 
    oView:SetViewProperty("VIEW_SCE", "GRIDDOUBLECLICK", {{|oView, cFieldName, nLineGrid, nLineModel| A162GdDbCl(oView, cFieldName, nLineGrid, nLineModel)}}) 
    oView:SetViewProperty("VIEW_QRY", "GRIDDOUBLECLICK", {{|oView, cFieldName, nLineGrid, nLineModel| A162GdDbCl(oView, cFieldName, nLineGrid, nLineModel)}}) 

    //-- Definir títulos
    oView:EnableTitleView("VIEW_DHU", STR0022) //-- "Critérios de Avaliação"
    oView:EnableTitleView("VIEW_DHV", STR0009) //-- "Produtos"
    oView:EnableTitleView("VIEW_SC8", STR0010) //-- "Propostas de Fornecimento"
    oView:EnableTitleView("VIEW_SCE", STR0023) //-- "Análise Atual"
    oView:EnableTitleView("VIEW_QRY", STR0024) //-- "Histórico da Cotação"

    //-- Esconder folder de Análise Atual em caso de operações de visualização
    oView:SetAfterViewActivate({|oView| A162HideFl(oView)})

    //-- Desabilitar o botão "Salvar e criar novo"
    oView:SetCloseOnOk( {|| .T. })

Return oView


//-------------------------------------------------------------------
/*/{Protheus.doc} A162Anl
    Realiza a análise de cotação.

@author leonardo.magalhaes
@since 22/04/2020
@version 1.0
@return Nil
/*/
//-------------------------------------------------------------------
Function A162Anl()

    Local cNumCot := DHU->DHU_NUM
    Local cFilDHU := xFilial("DHU")

    //-- Avaliar registro em uso por outro usuário
    If LockByName("COT_" + cFilDHU + cNumCot, .T., .F.)

        //-- Executar a view em modo de atualização (update)
        FWMsgRun(, {|| FWExecView(STR0004, "MATA162", MODEL_OPERATION_UPDATE)}, STR0018, STR0027) //-- "Aguarde" "Carregando as informações..."
        
        //-- Liberar registro para uso
        UnLockByName("COT_" + cFilDHU + cNumCot, .T., .F.)

    EndIf

Return Nil


//-------------------------------------------------------------------
/*/{Protheus.doc} A162Imp
    Realiza a chamada das funções de importação de dados para as 
    tabelas DHU (Cabeçalho de Cotações) e DHV (Itens de Cotações).

@author leonardo.magalhaes
@since 13/05/2020
@version 1.0
@return Nil
/*/
//-------------------------------------------------------------------
Function A162Imp()

    //-- Processar importação de dados
    FWMsgRun(,{|| A162DHV(), A162DHU()}, STR0018, STR0028) //"Aguarde" Importando cotações..."

Return Nil 


//-------------------------------------------------------------------
/*/{Protheus.doc} A162Vis
    Visualizar a análise de cotações.

@author leonardo.magalhaes
@since 25/10/2020
@version 1.0
@return Nil
/*/
//-------------------------------------------------------------------
Function A162Vis()

    //-- Processar importação de dados
    FWMsgRun(, {|| FWExecView(STR0004, "MATA162", MODEL_OPERATION_VIEW)}, STR0018, STR0027) //-- "Aguarde" "Carregando as informações..."

Return Nil 

//-------------------------------------------------------------------
/*/{Protheus.doc} A162DHV
    Executa a importação de dados para a tabela DHV 
    (Itens de Cotações).

@author leonardo.magalhaes
@since 13/05/2020
@version 1.0
@return Nil
/*/
//-------------------------------------------------------------------
Static Function A162DHV()

    Local cAliasAux as Char
    Local cFilDHV as Char
    Local cFilSB1 as Char
    Local cFunName as Char
    Local nTotReg as Numeric
    Local nLenC8Ped as Numeric
    Local nLenC8Cnt as Numeric

    //-- Avaliar se existe a tabela DHV no ambiente
    If FWAliasInDic("DHV", .F.)

        //-- Inicializar as variáveis
        cAliasAux := GetNextAlias()
        cFilDHV   := xFilial("DHV")
        cFilSB1   := xFilial("SB1")
        cFunName  := FunName()
        nLenC8Ped := FWTamSX3("C8_NUMPED")[1]
        nLenC8Cnt := FWTamSX3("C8_NUMCON")[1]

        //-- Buscar registros para importação
        BeginSQL Alias cAliasAux		
            SELECT 
            DISTINCT    C8_NUM,
                        C8_IDENT,
                        C8_ITEMGRD,
                        C8_PRODUTO,
                        C8_QUANT,
                        C8_UM,
                        C8_SEGUM,
                        C8_QTSEGUM
            FROM        %Table:SC8% SC8
            WHERE       C8_FILIAL        = %xFilial:SC8%
                        AND SC8.%NotDel%
                        AND NOT EXISTS (SELECT 1 FROM %Table:SC8% SC8AUX WHERE SC8AUX.C8_FILIAL = SC8.C8_FILIAL AND SC8AUX.C8_NUM = SC8.C8_NUM AND SC8AUX.%NotDel% AND (SC8AUX.C8_NUMCON <> %Exp:Space(nLenC8Cnt)% OR SC8AUX.C8_NUMPED <> %Exp:Space(nLenC8Ped)%))
        EndSQL

        //-- Contar a quantidade de registros encontrados
        Count To nTotReg
        (cAliasAux)->(DbGoTop())

        //-- Selecionar a área para migração
        DbSelectArea("DHV")
        DHV->(DbSetOrder(1))

        //-- Avaliar quantidade de registros encontrados
        If nTotReg > 0

            //--Inicializar a régua de processamento
            ProcRegua(nTotReg)

            //-- Inicializar a transação de migração dos dados
            Begin Transaction
                While !(cAliasAux)->(Eof())
                    If !(DHV->(DbSeek(cFilDHV + (cAliasAux)->C8_NUM + (cAliasAux)->C8_IDENT + (cAliasAux)->C8_PRODUTO)))
                        RecLock("DHV", .T.)
                            DHV->DHV_FILIAL  := cFilDHV
                            DHV->DHV_NUM     := (cAliasAux)->C8_NUM
                            DHV->DHV_STATUS  := "1" //-- Item de cotação não analisado
                            DHV->DHV_ITEM    := (cAliasAux)->C8_IDENT
                            DHV->DHV_ITGRD   := (cAliasAux)->C8_ITEMGRD
                            DHV->DHV_CODPRO  := (cAliasAux)->C8_PRODUTO
                            DHV->DHV_DESCR   := Posicione("SB1", 1, cFilSB1 + (cAliasAux)->C8_PRODUTO, "B1_DESC")
                            DHV->DHV_ORIGEM  := cFunName
                            DHV->DHV_UM      := (cAliasAux)->C8_UM
                            DHV->DHV_QUANT   := (cAliasAux)->C8_QUANT
                            DHV->DHV_SALDO   := (cAliasAux)->C8_QUANT
                            DHV->DHV_SEGUM   := (cAliasAux)->C8_SEGUM
                            DHV->DHV_QTSEGUM := (cAliasAux)->C8_QTSEGUM
                        DHV->(MsUnlock())
                    EndIf
                    (cAliasAux)->(DbSkip())
                EndDo
            End Transaction
        Else
             Help(,, "A162NOIMP",, STR0020, 1, 0) //-- "Não há dados a serem importados!"
        EndIf

        //-- Fechar a tabela temporária
        (cAliasAux)->(DbCloseArea())

    Else
        Help(,, "A162NOTBL",, STR0020, 1, 0) //-- "Tabela DHV não encontrada!" //LMB
    EndIf

Return Nil


//-------------------------------------------------------------------
/*/{Protheus.doc} A162DHU
    Executa a importação de dados para a tabela DHU 
    (Cabeçalho de Cotações).

@author leonardo.magalhaes
@since 13/05/2020
@version 1.0
@return Nil
/*/
//-------------------------------------------------------------------
Static Function A162DHU()

    Local cAliasAux as Char
    Local cFilDHU   as Char
    Local cFunName  as Char
    Local nLenC8Ped as Numeric
    Local nLenC8Cnt as Numeric
    Local nTotReg   as Numeric

    //-- Avaliar se existe a tabela DHU no ambiente
    If FWAliasInDic("DHU", .F.)
        
        //-- Inicializar as variáveis
        cAliasAux := GetNextAlias()
        cFilDHU   := xFilial("DHU")
        cFunName  := FunName()
        nLenC8Ped := FWTamSX3("C8_NUMPED")[1]
        nLenC8Cnt := FWTamSX3("C8_NUMCON")[1]

        //-- Buscar registros para importação
        BeginSQL Alias cAliasAux		
            SELECT 
            DISTINCT    C8_FILIAL,
                        C8_NUM
            FROM        %Table:SC8% SC8
            WHERE       C8_FILIAL        = %xFilial:SC8% 
                        AND SC8.%NotDel%
                        AND NOT EXISTS (SELECT 1 FROM %Table:SC8% SC8AUX WHERE SC8AUX.C8_FILIAL = SC8.C8_FILIAL AND SC8AUX.C8_NUM = SC8.C8_NUM AND SC8AUX.%NotDel% AND (SC8AUX.C8_NUMCON <> %Exp:Space(nLenC8Cnt)% OR SC8AUX.C8_NUMPED <> %Exp:Space(nLenC8Ped)%))
        EndSQL

        //-- Contar a quantidade de registros encontrados
        Count To nTotReg
        (cAliasAux)->(DbGoTop())

        //-- Selecionar a área para migração
        DbSelectArea("DHU")
        DHU->(DbSetOrder(1))

        //-- Avaliar quantidade de registros encontrados
        If nTotReg > 0

            //--Inicializar a régua de processamento
            ProcRegua(nTotReg)

            //-- Inicializar a transação de migração dos dados
            Begin Transaction
                While !(cAliasAux)->(Eof())
                    If !(DHU->(DbSeek(cFilDHU + (cAliasAux)->C8_NUM)))
                        RecLock("DHU", .T.)
                            DHU->DHU_FILIAL := cFilDHU
                            DHU->DHU_NUM    := (cAliasAux)->C8_NUM
                            DHU->DHU_TPDOC  := "1"
                            DHU->DHU_STATUS := "1" //-- Cotação não analisada
                            DHU->DHU_ORIGEM := cFunName 
                        DHU->(MsUnlock())
                    EndIf
                    (cAliasAux)->(DbSkip())
                EndDo
            End Transaction
        Else
            Help(,, "A162NOIMP",, STR0020, 1, 0) //-- "Não há dados a serem importados!"
        EndIf

        //-- Fechar a tabela temporária
        (cAliasAux)->(DbCloseArea())

    Else
        Help(,, "A162NOTBL",, STR0020, 1, 0) //-- "Tabela DHU não encontrada!"
    EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} A162Buttons
    Botões da tela de análise de cotações

@author leonardo.magalhaes
@since 07/05/2020
@version 1.0
@return Nil
/*/
//-------------------------------------------------------------------
Static Function A162Buttons(oPanel as Object, oView as Object, oModel as Object, cIdGrid as Char)

    Local lWhen  as Logical //-- Controla se os botões estarão habilitados ou não

    Default oPanel  := Nil
    Default oView   := FWViewActive()
    Default oModel  := FWModelActive() //-- Modelo de dados utilizado na carga do grid
    Default cIdGrid := ""

    //-- Inicializar as variáveis
    lWhen  := .F.

    If oModel <> Nil .And. oModel:GetId() == "MATA162"
        
        lWhen  := !(oModel:GetOperation() == MODEL_OPERATION_VIEW)

        If cIdGrid == "DHUMASTER" //-- Grid de Produtos
            @ oPanel:nTop + 15, 5 Button STR0029 Size 40, 25 Message STR0030 Pixel Action FWMsgRun(, {|| A162Aval(oModel, oView)}, STR0018, STR0033) of oPanel When lWhen .And. !oModel:GetModel(cIdGrid):GetValue("DHU_AVAUT") //-- "Avaliar" "Avaliar as propostas de fornecimento automaticamente." "Aguarde" "Processando a avaliação automática...
            @ oPanel:nTop + 55, 5 Button STR0031 Size 40, 25 Message STR0032 Pixel Action FWMsgRun(, {|| A162Reset(oModel, oView)}, STR0018, STR0034) of oPanel When lWhen .And. oModel:GetModel(cIdGrid):GetValue("DHU_AVAUT") //-- "Reset" "Avaliar as propostas de fornecimento automaticamente." "Aguarde" "Resetando as informações..."
        ElseIf cIdGrid == "DHVDETAIL" //-- Grid de Produtos
            @ oPanel:nTop + 15, 5 Button STR0011 + CRLF + STR0012 + CRLF + STR0013 Size 40, 25 Message STR0015 Pixel Action A162PosP(oModel) of oPanel When lWhen //-- "Histórico do Produto" "Consultar o histórico do produto."
        ElseIf cIdGrid == "SC8DETAIL" //-- Grid de Propostas de Fornecimento
            @ oPanel:nTop + 15, 5 Button STR0011 + CRLF + STR0012 + CRLF + STR0014 Size 40, 25 Size 55, 20 Message STR0016 Pixel Action A162PosF(oModel) of oPanel When lWhen //-- "Histórico do Fornecedor" "Consultar o histórico do fornecedor."
            @ oPanel:nTop + 55, 5 Button STR0035 + CRLF + STR0036 + CRLF + STR0037 Size 40, 25 Message STR0038 Pixel Action FWMsgRun(, {|| A162MkAll(oModel, oView)}, STR0018, STR0039) of oPanel When lWhen //-- "Marca/Desmarca todos" "Marcar e/ou Desmarcar todoas as propostas de fornecimento." "Aguarde" "Marcando/desmarcando todas as propostas..." 
        EndIf

    EndIf 

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} A162VldAtv
    Avaliar se o modelo pode ser ativado.

@author leonardo.magalhaes
@since 21/01/2021
@version 1.0
@return Nil
/*/
//-------------------------------------------------------------------
Static Function A162VldAtv(oModel as Object) as Logical

    Local lRet as Logical

    //-- Inicializar as variáveis
    lRet := .T.

    //-- Avaliar se a cotação pode ser analisada (DHU_STATUS diferente de 3 - Cotação totalmente analisada)
    If oModel:GetOperation() <> MODEL_OPERATION_VIEW .And. DHU->DHU_STATUS == "3"
        Help(,, "A162VLDSTA",, STR0085, 4,1,,,,,, {STR0086}) //-- "A cotação não possui saldo disponível para análise!" "Utilize o modo de Visualização!"
        lRet := .F.
    EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} A162Aval
    Executa a avaliação automática das propostas de fornecimento.

@author leonardo.magalhaes
@since 07/05/2020
@version 1.0
@return Nil
/*/
//-------------------------------------------------------------------
Static Function A162Aval(oModel as Object, oView as Object, aItems as Array) as Logical

    Local aMinMaxPrc as Array
    Local aMinMaxPrz as Array
    Local aMinMaxNt as Array
    Local aRank as Array
    Local aSaveLines as Array
    Local bEvalGrdFlt as Block
    Local lRet as Logical
    Local lRateByItem as Logical
    Local lIsViewActv as Logical 
    Local lVldDueDate as Logical
    Local lHasGrdFilt as Logical
    Local nX   as Numeric
    Local nY   as Numeric
    Local nQtWin as Numeric
    Local nLenAux as Numeric
    Local nRatePrc as Numeric
    Local nRateTime as Numeric
    Local nRateNote as Numeric
    Local oDHUMaster as Object
    Local oDHVDetail as Object
    Local oSC8Detail as Object
    Local oSCEDetail as Object
    Local oSCEQry as Object
    Local oViewDHVInf as Object

    Default oModel := FWModelActive()
    Default oView := FWViewActive()
    Default aItems := {}
    
    //-- Inicializar as variáveis
    aMinMaxPrc := {}
    aMinMaxPrz := {}
    aMinMaxNt := {}
    aRank := {}
    aSaveLines := FWSaveRows()
    bEvalGrdFlt := {|| .T.}
    lRet := .T.
    lRateByItem := .T.
    nX := 0
    nY := 0
    nQtWin := 1
    nLenAux := 0
    lVldDueDate := .F.
    lIsViewActv := .F.
    lRatePrice := .F.
    lRateTime := .F.
    lRateNote := .F.
    lHasGrdFilt := .F.

    //-- Avaliar modelo e campos de peso
    If oModel <> Nil .And. oModel:GetId() == "MATA162"

        //-- Inicializar os submodelos
        oDHUMaster := oModel:GetModel("DHUMASTER")
        oDHVDetail := oModel:GetModel("DHVDETAIL")
        oSC8Detail := oModel:GetModel("SC8DETAIL")
        oSCEDetail := oModel:GetModel("SCEDETAIL")
        oSCEQry := oModel:GetModel("SCEQRY")

        nRatePrc := oDHUMaster:GetValue("DHU_PPRECO")
        nRateTime := oDHUMaster:GetValue("DHU_PPRAZO") 
        nRateNote := oDHUMaster:GetValue("DHU_PNOTA")

        lRatePrice := nRatePrc > 0
        lRateTime := nRateTime > 0
        lRateNote := nRateNote > 0

        If (lRatePrice .Or. lRateTime .Or. lRateNote)
            
            //-- Definir número da cotação
            cNumCot := oDHUMaster:GetValue("DHU_NUM")

            //-- Definir se é avaliação por 1=Item ou 2=Proposta
            lRateByItem := oDHUMaster:GetValue("DHU_TPAVAL") == "1"

            //-- Definir quantidade de vencedores (propostas ou itens)
            nQtWin := oDHUMaster:GetValue("DHU_QTWIN")

            //-- Definir se serão descartadas propostas vencidas
            lVldDueDate := oDHUMaster:GetValue("DHU_AVALVL") == "1"

            //-- Definir se a view está ativa
            lIsViewActv := oView <> Nil .And. oView:IsActive()

            //-- Definir o tamanho do campo de item
            nLenC8Item := FWTamSX3("DHV_ITEM")[1]

            //-- Obter informações da view para validações de tela
            If lIsViewActv
                oViewDHVInf := oView:GetViewObj("VIEW_DHV")

                bEvalGrdFlt := {||  oViewDHVInf <> Nil .And. Len(oViewDHVInf) >= 3 .And.;
                                    oViewDHVInf[3]:oBrowse <> Nil .And.;
                                    oViewDHVInf[3]:oBrowse:oFwFilter <> Nil .And.;
                                    oViewDHVInf[3]:oBrowse:oFwFilter:aCheckFil <> Nil .And.;
                                    Len(oViewDHVInf[3]:oBrowse:oFwFilter:aCheckFil) >= 1 .And.; 
                                    ValType(oViewDHVInf[3]:oBrowse:oFwFilter:aCheckFil[1]) == "L";
                                }

                If Eval(bEvalGrdFlt)

                    //-- Verificar se o grid possui filtro    
                    lHasGrdFilt := oViewDHVInf[3]:oBrowse:oFwFilter:aCheckFil[1]

                    If lHasGrdFilt
                        If oViewDHVInf[3]:aFieldID <> Nil .And. Len(oViewDHVInf[3]:aFieldID) >= 1
                            nPosItem := AScan(oViewDHVInf[3]:aFieldID, {|x| AllTrim(x) == "DHV_ITEM"})
                            If nPosItem > 0 .And. oViewDHVInf[3]:oBrowse:oData <> Nil .And. oViewDHVInf[3]:oBrowse:oData:aShow <> Nil
                                nLenAux := Len(oViewDHVInf[3]:oBrowse:oData:aShow)
                                For nX := 1 To nLenAux
                                    AAdd(aItems, oViewDHVInf[3]:oBrowse:oData:aShow[nX][nPosItem])
                                Next nX
                            EndIf
                        EndIf
                    EndIf        
                EndIf
            EndIf

            nLenItems := Len(aItems)
            lCheckItems := nLenItems > 0 .And. nLenItems <> oDHVDetail:Length(.T.)

            If lHasGrdFilt .And. !lRateByItem
                //-- Alertar sobre critérios de avaliação inválidos
                Help(,, "A162HASFILT",, STR0040, 4,1,,,,,, {STR0041}) //-- "Avaliação por propostas não é permitida com filtros ativos!" 
                lRet := .F.
            Else
                //-- Se for avaliação por item, basta existir um item com preço e condição de pagamento informada para prosseguir
                //-- Se for avaliação por propostas, verificar se todos os produtos possuem propostas de todos os fornecedores
                If A162EvalChk(cNumCot, lRateByItem, lVldDueDate)

                    //-- Avaliar se recalcula o custo unitário pela nova taxa informada (1=Sim, 2=Não)
                    If oDHUMaster:GetValue("DHU_ATUJUR") == "1"
                        
                        nTxJur := oDHUMaster:GetValue("DHU_TXJURO")

                        //-- Desbloquear modo de edição dos campos de custos e taxa
                        oSC8Detail:GetStruct():SetProperty("C8_CUSTO1", MODEL_FIELD_WHEN, {|| .T.})
                        oSC8Detail:GetStruct():SetProperty("C8_CUSUNI1", MODEL_FIELD_WHEN, {|| .T.})
                        oSC8Detail:GetStruct():SetProperty("C8_TAXAFIN", MODEL_FIELD_WHEN, {|| .T.})

                        If lCheckItems
                            For nX := 1 To nLenItems
                                If oDHVDetail:SeekLine({{"DHV_ITEM", aItems[nX]}}, .F., .T.)
                                    For nY := 1 To oSC8Detail:Length()
                                        oSC8Detail:GoLine(nY)
                                        If !oSC8Detail:IsDeleted()
                                            oSC8Detail:SetValue("C8_TAXAFIN", nTxJur)
                                            oSC8Detail:SetValue("C8_CUSTO1", A162Custo(1, nTxJur, oSC8Detail:GetDataId()))
                                            oSC8Detail:SetValue("C8_CUSUNI1", A162Custo(2, nTxJur, oSC8Detail:GetDataId()))
                                        EndIf
                                    Next nY
                                EndIf
                            Next nX
                        Else
                            For nX := 1 To oDHVDetail:Length()
                                oDHVDetail:GoLine(nX)
                                If !oDHVDetail:IsDeleted()
                                    For nY := 1 To oSC8Detail:Length()
                                        oSC8Detail:GoLine(nY)
                                        If !oSC8Detail:IsDeleted()
                                            oSC8Detail:SetValue("C8_TAXAFIN", nTxJur)
                                            oSC8Detail:SetValue("C8_CUSTO1", A162Custo(1, nTxJur, oSC8Detail:GetDataId()))
                                            oSC8Detail:SetValue("C8_CUSUNI1", A162Custo(2, nTxJur, oSC8Detail:GetDataId()))
                                        EndIf
                                    Next nY
                                EndIf
                            Next nX
                        EndIf
                        
                        //-- Bloquear modo de edição dos campos de custos e taxa
                        oSC8Detail:GetStruct():SetProperty("C8_CUSTO1", MODEL_FIELD_WHEN, {|| .F.})
                        oSC8Detail:GetStruct():SetProperty("C8_CUSUNI1", MODEL_FIELD_WHEN, {|| .F.})
                        oSC8Detail:GetStruct():SetProperty("C8_TAXAFIN", MODEL_FIELD_WHEN, {|| .F.})

                    EndIf

                    //-- Obter os valores mínimo e máximo de custo unitario, prazo e nota
                    If lRatePrice
                        aMinMaxPrc := A162MinMax(cNumCot, 1, oModel, oDHUMaster, oDHVDetail, oSC8Detail, lRateByItem, lCheckItems, aItems, lVldDueDate) 
                    EndIf

                    If lRateTime
                        aMinMaxPrz := A162MinMax(cNumCot, 2, oModel, oDHUMaster, oDHVDetail, oSC8Detail, lRateByItem, lCheckItems, aItems, lVldDueDate)
                    EndIf

                    If lRateNote
                        aMinMaxNt  := A162MinMax(cNumCot, 3, oModel, oDHUMaster, oDHVDetail, oSC8Detail, lRateByItem, lCheckItems, aItems, lVldDueDate)
                    EndIf

                    //-- Definir ranking de propostas
                    aRank := A162Rank(cNumCot, lRateByItem, lCheckItems, aItems, nQtWin, aMinMaxPrc, aMinMaxPrz, aMinMaxNt, nRatePrc, nRateTime, nRateNote, lVldDueDate, oDHUMaster, oDHVDetail, oSC8Detail)

                    If Len(aRank) > 0
                        //-- Marcar os vencedores
                        lRet := A162MkWin(lRateByItem, aRank, nQtWin, oDHVDetail, oSC8Detail, oSCEDetail, oSCEQry)
                            
                        If !lRet
                            Help(,, "A162NOWIN",, STR0042, 4,1,,,,,, {STR0043}) //-- "A marcação de vencedores não pode ser efetuada!" "Verifique os critérios de avaliação!"
                        EndIf
                    Else
                        Help(,, "A162NORANK",, STR0044, 4,1,,,,,, {STR0043}) //-- "O ranking de propostas não pode ser efetuado!" "Verifique os critérios de avaliação!"
                        lRet := .F.
                    EndIf

                Else
                    If lRateByItem
                        Help(,, "A162EVALCHK",, STR0045, 4,1,,,,,, {STR0046}) //-- "Não há proposta de fornecimento válida para os produtos!" "Ao menos um produto deve conter valor unitário e condição de pagamento informada!" 
                    Else
                        Help(,, "A162EVALCHK",, STR0047, 4,1,,,,,, {STR0048}) //-- "Impossível avaliar pelo critério de propostas!" "Todos os produtos devem receber a mesma quantidade de propostas por todos os fornecedores da cotação!"
                    EndIf
                    lRet := .F.
                EndIf
            EndIf
        Else
            //-- Alertar sobre critérios de avaliação inválidos
            Help(,, "A162NOPESO",, STR0049, 4,1,,,,,, {STR0050}) //-- "Nenhum peso atende aos critérios de avaliação!" "Ao menos um peso deve ser maior que zero."
            lRet := .F.
        EndIf
    EndIf

    //-- Flag de avaliação automática
    oDHUMaster:SetValue("DHU_AVAUT", lRet)

    //-- Restaurar os grids
    FWRestRows(aSaveLines)

    //-- Atualizar a view
    If lIsViewActv .And. lRet
        oView:Refresh("VIEW_DHU")
        oView:Refresh("VIEW_DHV")
        oView:Refresh("VIEW_SC8")
    EndIf

    //-- Limpar a memória
    aSize(aSaveLines, 0)
	aSaveLines := Nil

    aSize(aMinMaxPrc, 0)
    aMinMaxPrc := Nil

    aSize(aMinMaxPrz, 0)
    aMinMaxPrz := Nil

    aSize(aMinMaxNt, 0)
    aMinMaxNt := Nil

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} A162PosP
    Executa a consulta de posição do produto (histórico).

@author leonardo.magalhaes
@since 07/05/2020
@version 1.0
@return Nil
/*/
//-------------------------------------------------------------------
Static Function A162PosP(oModel as Object)
    
    Local aArea    as Array
     
    Local cCodProd as Char

    Default oModel := FWModelActive()

    //-- Inicializar as variáveis
    aArea    := {}
    cCodProd := ""

    //-- Avaliar modelo ativo
    If oModel <> Nil .And. oModel:GetId() == "MATA162"

        //-- Obter área ativa
        aArea := GetArea()
        
        //-- Obter código do produto a ser avaliado
        cCodProd := oModel:GetModel("DHVDETAIL"):GetValue("DHV_CODPRO")

        //-- Salvar referencias fiscais
        MaFisSave()
        MaFisEnd()

        //-- Executar a consulta
        If !FWIsInCallStack("MACOMVIEW")
            If !Empty(cCodProd)
                MaComView(cCodProd)
            EndIf
        EndIf

        //-- Restaurar referencias fiscais
        MaFisRestore()

        //-- Restaurar área ativa
        RestArea(aArea)

    EndIf

    //-- Limpar a memória
    ASize(aArea, 0)
    aArea := Nil

Return Nil


//-------------------------------------------------------------------
/*/{Protheus.doc} A162PosF
    Executa a consulta de posição do fornecedor (histórico).

@author leonardo.magalhaes
@since 07/05/2020
@version 1.0
@return Nil
/*/
//-------------------------------------------------------------------
Static Function A162PosF(oModel as Object)
    
    Local aArea	  as Array

    Local cCodFor as Char
    Local cLojFor as Char 

    Default oModel := FWModelActive()

    //-- Inicializar as variáveis
    aArea   := {}
    cCodFor := ""
    cLojFor := ""
    
    //-- Avaliar modelo ativo
    If oModel <> Nil .And. oModel:GetId() == "MATA162" 
    
        //-- Obter área ativa
        aArea   := GetArea()

        //-- Obter código do fornecedor a ser avaliado
        cCodFor := oModel:GetModel("SC8DETAIL"):GetValue("C8_FORNECE")
        
        //-- Obter loja do fornecedor a ser avaliado
        cLojFor := oModel:GetModel("SC8DETAIL"):GetValue("C8_LOJA")

        //-- Avaliar códigos vazios
        If !Empty(cCodFor) .And. !Empty(cLojFor)
            //-- Selecionar área do cadastro de fornecedores (SA2)
            DbSelectArea("SA2")
            SA2->(DbSetOrder(1)) //-- A2_FILIAL, A2_COD, A2_LOJA
            //-- Buscar pelo fornecedor
            If SA2->(DbSeek(xFilial("SA2") + cCodFor + cLojFor))
                //-- Executar os perguntes da consulta
                If Pergunte("FIC030", .T.) 	
                    //-- Executar a consulta
                    FinC030("Fc030Con")
                EndIf
            EndIf
        EndIf

        //-- Restaurar a área ativa
        RestArea(aArea)

    EndIf

    //-- Limpar a memória
    ASize(aArea, 0)
    aArea := Nil

Return Nil


Static Function A162MkAll(oModel as Object, oView as Object)

    Local aSaveLines as Array
    Local oDHVDetail as Object
    Local oSC8Detail as Object
    Local nX as Numeric

    Default oModel := FWModelActive()
    Default oView := FWViewActive()

    //-- Inicializar as variáveis
    aSaveLines := FWSaveRows()
    nX := 0
    
    //-- Avaliar modelo ativo
    If oModel <> Nil .And. oModel:GetId() == "MATA162" 
        
        //-- Obter submodelo das Propostas de Fornecimento (SC8)
        oDHVDetail := oModel:GetModel("DHVDETAIL")
        oSC8Detail := oModel:GetModel("SC8DETAIL")

        //-- Percorrer todo o grid
        If oDHVDetail:GetValue("DHV_SALDO") > 0
            For nX := 1 To oSC8Detail:Length()
                oSC8Detail:GoLine(nX)
                //-- Marcar/Desmarcar flag de vencedor
                oSC8Detail:SetValue("C8_MARKW", !oSC8Detail:GetValue("C8_MARKW"))
            Next nX
        Else
            Help(,, "A162NOSLD",, STR0059, 1, 0) //-- "Saldo em quantidade insuficiente do produto!"
        EndIf
    EndIf

    //-- Atualizar a view
    FWRestRows(aSaveLines)
    If oView <> Nil .And. oView:IsActive()
        oView:Refresh("VIEW_SC8")
    EndIf

    //-- Limpar a memória
    aSize(aSaveLines, 0)
	aSaveLines := Nil

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} A162SetLeg
    Define a legenda para os campos de legenda.

@author leonardo.magalhaes
@since 07/05/2020
@version 1.0
@return Nil
/*/
//-------------------------------------------------------------------
Static Function A162SetLeg(cIdField as Char, oModel as Object, nOperat as Numeric) as Char

    Local cRet as Char
    Local cStatus as Char

    Default cIdField := ""
    Default oModel   := FWModelActive()
    Default nOperat := 1

    //-- Inicializar as variáveis
    cRet := ""
    cStatus := ""

    //-- Avaliar o modelo ativo
    If oModel <> Nil .And. oModel:GetId() == "MATA162"
        //-- Avaliar os campos em tempo de execução 
        If cIdField == "DHV_LEGEND"

            //-- Avaliar operação (1 = Abertura do modelo, 2 = Atualização do modelo)
            If nOperat == 1
                cStatus := DHV->DHV_STATUS
            ElseIf nOperat == 2
                cStatus := FWFldGet("DHV_STATUS")
            EndIf

            //-- Definir legendas - DHV
            If cStatus == "1" //-- Item de cotação não analisado
                cRet := "BR_PINK"
            ElseIf cStatus == "2" //-- Item de cotação parcialmente analisado
                cRet := "BR_LARANJA"
            ElseIf cStatus == "3" //-- Item de cotação totalmente analisado
                cRet := "BR_AZUL"
            EndIf 

        EndIf
    EndIf

Return cRet

Static Function A162SC8LPre(oGridModel as Object, nLine as Numeric, cAction as Char, cIDField as Char, xValue, xCurrentValue) as Logical

    Local lRet     as Logical
    Local oGridSC8 as Object

    //-- Inicializar as variáveis
    lRet := .T.
    oGridSC8 := oGridModel:GetModel():GetModel("SC8DETAIL")

    //-- Avaliar ação em tempo de execução
    If cAction == "SETVALUE"
        //-- Avaliar campos em tempo de execução
        If cIdField == "C8_MARKW"

            //-- Avaliar preço unitário
            If oGridSC8:GetValue("C8_PRECO") == 0
                Help(,, "A162NOPRECO",, STR0053, 4, 1,,,,,, {STR0054}) //-- "Proposta sem preço unitário informado!" "Atualize a proposta informando um preço unitário ou escolha uma proposta válida!"
                lRet := .F.
            //-- Avaliar condição de pagamento
            ElseIf Empty(oGridSC8:GetValue("C8_COND"))
                Help(,, "A162NOCONDPG",, STR0055, 4, 1,,,,,, {STR0056}) //-- "Proposta sem condição de pagamento informada!" "Atualize a proposta informando uma condição de pagamento ou escolha uma proposta válida!"
                lRet := .F.
            EndIf

        EndIf
    EndIf

Return lRet

Static Function A162SCELPre(oGridModel as Object, nLine as Numeric, cAction as Char, cIDField as Char, xValue, xCurrentValue) as Logical

    Local lRet as Logical

    Local oDHVDetail as Object
    Local oSC8Detail as Object
    
    Local nDHVSldAtu as Numeric
    Local nDHVQuant as Numeric
    Local nSldAux as Numeric

    //-- Inicializar as variáveis
    lRet := .T.
    oDHVDetail := oGridModel:GetModel():GetModel("DHVDETAIL")
    oSC8Detail := oGridModel:GetModel():GetModel("SC8DETAIL")
    nDHVQuant := oDHVDetail:GetValue("DHV_QUANT")
    nDHVSldAtu := oDHVDetail:GetValue("DHV_SALDO")
    nSldAux := 0

    //-- Avaliar ação em tempo de execução
    If cAction == "SETVALUE"
        //-- Avaliar campos em tempo de execução
        If cIdField == "CE_QUANT"
            //-- Calcular saldo (Saldo Atual + Quantidade Atual - Quantidade Digitada)
            nSldAux := nDHVSldAtu + xCurrentValue - xValue
            
            //-- Avaliar saldo positivo
            If Positivo(nSldAux)
                //-- Liberar modo de edição do campo
                oDHVDetail:GetStruct():SetProperty("DHV_SALDO", MODEL_FIELD_WHEN, {|| .T.})
                
                //-- Atribuir ao saldo o valor calculado
                oDHVDetail:SetValue("DHV_SALDO", nSldAux)

                //-- Bloquear o modo de edição do campo
                oDHVDetail:GetStruct():SetProperty("DHV_SALDO", MODEL_FIELD_WHEN, {|| .F.})
            Else
                //-- Alertar saldo insuficiente
                Help(,, "A162NOSLD",, STR0057, 4, 1,,,,,, {STR0058 + cValToChar(nDHVSldAtu)}) //-- "Saldo insuficiente!" "Saldo disponível: "
                lRet := .F.
            EndIf
        EndIf
    ElseIf cAction == "DELETE"

        //-- Calcular saldo (Saldo Atual + Quantidade Atual)
        nSldAux := nDHVSldAtu + oGridModel:GetValue("CE_QUANT")
            
        //-- Avaliar saldo positivo
        If Positivo(nDHVQuant - nSldAux)
            //-- Liberar modo de edição do campo
            oDHVDetail:GetStruct():SetProperty("DHV_SALDO", MODEL_FIELD_WHEN, {|| .T.})
            
            //-- Atribuir ao saldo o valor calculado
            oDHVDetail:SetValue("DHV_SALDO", nSldAux)

            //-- Bloquear o modo de edição do campo
            oDHVDetail:GetStruct():SetProperty("DHV_SALDO", MODEL_FIELD_WHEN, {|| .F.})
        Else
            //-- Alertar saldo insuficiente
            Help(,, "A162NOSLD",, STR0057, 4, 1,,,,,, {STR0058 + cValToChar(nDHVQuant - nDHVSldAtu)}) //-- "Saldo insuficiente!" "Saldo disponível: "
            lRet := .F.
        EndIf

    ElseIf cAction == "UNDELETE"

        //-- Calcular saldo (Saldo Atual + Quantidade Atual)
        nSldAux := nDHVSldAtu + oGridModel:GetValue("CE_QUANT")
            
        //-- Avaliar saldo positivo
        If Positivo(nDHVQuant - nSldAux)
            //-- Liberar modo de edição do campo
            oDHVDetail:GetStruct():SetProperty("DHV_SALDO", MODEL_FIELD_WHEN, {|| .T.})
            
            //-- Atribuir ao saldo o valor calculado
            oDHVDetail:SetValue("DHV_SALDO", nSldAux)

            //-- Bloquear o modo de edição do campo
            oDHVDetail:GetStruct():SetProperty("DHV_SALDO", MODEL_FIELD_WHEN, {|| .F.})
        Else
            //-- Alertar saldo insuficiente
            Help(,, "A162NOSLD",, STR0057, 4, 1,,,,,, {STR0058 + cValToChar(nDHVSldAtu)}) //-- "Saldo insuficiente!" "Saldo disponível: "
            lRet := .F.
        EndIf

    EndIf

Return lRet
//-------------------------------------------------------------------
/*/{Protheus.doc} A162FillSCE
    Preenche as informações na SCE a partir do Marca/Desmarca do
    campo C8_MARKW.

@author leonardo.magalhaes
@since 07/05/2020
@version 1.0
@return Nil
/*/
//-------------------------------------------------------------------
Static Function A162FillSCE(oModel as Object)

    Local aSaveLines  as Array	
    Local lRet        as Logical
    Local lIsViewActv as Logical
    Local lNecessid   as Logical
    Local oDHUMaster  as Object
    Local oDHVDetail  as Object
    Local oSCEDetail  as Object
    Local oSCEQry     as Object
    Local oSC8Detail  as Object
    Local oView       as Object

    Default oModel := FWModelActive() //-- Modelo ativo como default

    //-- Inicializar as variáveis
    lRet := .T.
    aSaveLines := FWSaveRows()
    lIsViewActv := .F.
    oView := Nil
    lNecessid := .F.

    //-- Avaliar o modelo ativo
    If oModel <> Nil .And. oModel:GetId() == "MATA162"

        oView := FWViewActive()
        lIsViewActv := oView <> Nil .And. oView:IsActive()

        //--Inicializar o modelo do cabeçalho da cotação
        oDHUMaster := oModel:GetModel("DHUMASTER")
        oDHVDetail := oModel:GetModel("DHVDETAIL")
        lNecessid := (oDHUMaster:GetValue("DHU_AVENTR") == "2")
        oDHUMaster:SetValue("DHU_AVAUT", !oDHUMaster:GetValue("DHU_AVAUT"))

        //-- Inicializar o submodelo de Encerramento (SCE)
        oSCEDetail := oModel:GetModel("SCEDETAIL")
        oSCEQry := oModel:GetModel("SCEQRY")

        //-- Inicializar o submodelo das Propostas de Fornecimento (SC8)
        oSC8Detail := oModel:GetModel("SC8DETAIL")

        //-- Habilitar insert, delete e update de linha
        oSCEDetail:SetNoInsertLine(.F.)
        oSCEDetail:SetNoUpdateLine(.F.)
        oSCEDetail:SetNoDeleteLine(.F.)

        //-- Avaliar se é proposta marcada como vencedora
        If oSC8Detail:GetValue("C8_MARKW")

            //-- Legenda para item em análise
            oDHVDetail:LoadValue("DHV_LEGEND", "BR_VIOLETA")

            If oSCEDetail:SeekLine({{"CE_FORNECE", oSC8Detail:GetValue("C8_FORNECE")}, {"CE_LOJA", oSC8Detail:GetValue("C8_LOJA")}, {"CE_NUMPRO", oSC8Detail:GetValue("C8_NUMPRO")}, {"CE_SEQ", A162GetSeq(2, oSC8Detail, oSCEDetail, oSCEQry, .F.)}}, .T., .T.) .And. oSCEDetail:IsDeleted()
                oSCEDetail:UndeleteLine()
            Else

                //-- Verifica se é um novo grid, basta existir uma linha para que sejam adicionadas novas linhas
                If !oSCEDetail:IsEmpty()
                    oSCEDetail:AddLine()
                EndIf

                //-- Habilitar modo de edição dos campos
                oSCEDetail:GetStruct():SetProperty("*", MODEL_FIELD_WHEN, {|| .T.})

                //-- Preenche uma linha da SCE a partir da linha da SC8
                oSCEDetail:LoadValue("CE_LEGEND", "BR_BRANCO")
                oSCEDetail:SetValue("CE_NUMCOT", oSC8Detail:GetValue("C8_NUM"))
                oSCEDetail:SetValue("CE_FORNECE", oSC8Detail:GetValue("C8_FORNECE"))
                oSCEDetail:SetValue("CE_LOJA", oSC8Detail:GetValue("C8_LOJA"))
                oSCEDetail:SetValue("CE_DESCFOR", oSC8Detail:GetValue("C8_FORNOME"))
                oSCEDetail:SetValue("CE_NUMPRO", oSC8Detail:GetValue("C8_NUMPRO"))
                oSCEDetail:SetValue("CE_IDENT", oSC8Detail:GetValue("C8_IDENT"))
                oSCEDetail:SetValue("CE_ITEMCOT", oSC8Detail:GetValue("C8_ITEM"))
                oSCEDetail:SetValue("CE_PRODUTO", oSC8Detail:GetValue("C8_PRODUTO"))
                oSCEDetail:SetValue("CE_ITEMGRD", oSC8Detail:GetValue("C8_ITEMGRD"))
                oSCEDetail:SetValue("CE_SEQ", A162GetSeq(1, oSC8Detail, oSCEDetail, oSCEQry))
                oSCEDetail:SetValue("CE_VUNIT", oSC8Detail:GetValue("C8_PRECO"))
                oSCEDetail:LoadValue("CE_ENTREGA", Iif(lNecessid, oSC8Detail:GetValue("C8_DATPRF"), Date() + oSC8Detail:GetValue("C8_PRAZO")))
                oSCEDetail:SetValue("CE_CUSUNI1", oSC8Detail:GetValue("C8_CUSUNI1"))
                oSCEDetail:SetValue("CE_CUSTO1", oSC8Detail:GetValue("C8_CUSTO1"))
                oSCEDetail:SetValue("CE_MOTVENC", oSC8Detail:GetValue("C8_MOTVENC"))
                
                //-- Bloquear modo de edição dos campos
                oSCEDetail:GetStruct():SetProperty("*", MODEL_FIELD_WHEN, {|| .F.})

                //-- Restaurar modo de edição dos campos específicos
                oSCEDetail:GetStruct():SetProperty("CE_QUANT", MODEL_FIELD_WHEN, {|| .T.})
                oSCEDetail:GetStruct():SetProperty("CE_MOTVENC", MODEL_FIELD_WHEN, {|| .T.})
 
            EndIf

        Else

            //-- Restaurar a legenda do item de cotação
            oDHVDetail:LoadValue("DHV_LEGEND", A162SetLeg("DHV_LEGEND", oModel, 2))

            //-- Avaliar se é desmarcação de proposta vencedora e deletar o registro correspondente na SCE
            If oSCEDetail:SeekLine({{"CE_FORNECE", oSC8Detail:GetValue("C8_FORNECE")}, {"CE_LOJA", oSC8Detail:GetValue("C8_LOJA")}, {"CE_NUMPRO",oSC8Detail:GetValue("C8_NUMPRO")}, {"CE_SEQ", A162GetSeq(2, oSC8Detail, oSCEDetail, oSCEQry)}}, .F., .T.) .And. !oSCEDetail:IsDeleted()
                oSCEDetail:LoadValue("CE_LEGEND", "")
                oSCEDetail:DeleteLine()
            EndIf
        EndIf

        //-- Bloquear insert e delete de linha
        oSCEDetail:SetNoInsertLine(.T.)

    EndIf 

    //-- Restaurar os grids
    FWRestRows(aSaveLines)

    //-- Marcação manual deve atualizar a view do cabeçalho
    If lIsViewActv .And. !FWIsInCallStack("A162Aval")
        oView:Refresh("VIEW_DHU")
    EndIf

    //-- Limpar a memória
    aSize(aSaveLines, 0)
    aSaveLines := Nil

Return Nil


//-------------------------------------------------------------------
/*/{Protheus.doc} A162GetSeq
    Preenche as informações na SCE a partir do Marca/Desmarca do
    campo C8_MARKW.

@author leonardo.magalhaes
@since 07/05/2020
@version 1.0
@return Nil
/*/
//-------------------------------------------------------------------
Function A162GetSeq(nOper as Numeric, oSC8Detail as Object, oSCEDetail as Object, oSCEQry as Object, lChkLnDel as Logical) as Char
    
    Local aSaveLines as Array
    Local cRet       as Char
    Local nX         as Numeric

    Default nOper := 0
    Default lChkLnDel := .T.
    Default oSC8Detail := Nil
    Default oSCEDetail := Nil
    Default oSCEQry := Nil

    //-- Inicializar as variáveis
    aSaveLines := FWSaveRows()
    cRet := "001"
    nX := 0

    If nOper >= 1 .And. nOper <= 2 .And. oSC8Detail <> Nil .And. oSCEDetail <> Nil .And. oSCEQry <> Nil
    
        If nOper == 1
            For nX := 1 To oSCEQry:Length()
                oSCEQry:GoLine(nX)
                If !oSCEQry:IsDeleted() .And. oSC8Detail:GetValue("C8_FORNECE") + oSC8Detail:GetValue("C8_LOJA") + oSC8Detail:GetValue("C8_NUMPRO")  == oSCEQry:GetValue("CE_FORNECE") + oSCEQry:GetValue("CE_LOJA") + oSCEQry:GetValue("CE_NUMPRO")
                    cRet :=  Soma1(oSCEQry:GetValue("CE_SEQ"))
                EndIf
            Next nX
        ElseIf nOper == 2
            For nX := 1 To oSCEDetail:Length()
                oSCEDetail:GoLine(nX)
                If (Iif(lChkLnDel, !oSCEDetail:IsDeleted(), !lChkLnDel)) .And. oSC8Detail:GetValue("C8_FORNECE") + oSC8Detail:GetValue("C8_LOJA") + oSC8Detail:GetValue("C8_NUMPRO")  == oSCEDetail:GetValue("CE_FORNECE") + oSCEDetail:GetValue("CE_LOJA") + oSCEDetail:GetValue("CE_NUMPRO")
                    If !Empty(oSCEDetail:GetValue("CE_SEQ"))
                        cRet := oSCEDetail:GetValue("CE_SEQ")
                    EndIf
                EndIf
            Next nX
        EndIf

    EndIf

    //-- Restaurar os grids
    FWRestRows(aSaveLines)

    //-- Limpar a memória
    aSize(aSaveLines, 0)
    aSaveLines := Nil

Return cRet



Static Function A162DHVTot(oMdl as Object, oView as Object) as Numeric

    Local aSaveLines as Array

    Local nRet as Numeric
    Local nX   as Numeric 

    Local oGridDHV as Object
    Local oGridSCE as Object

    Local lIsViewActv as Logical
    
    Default oMdl := FWModelActive() //-- Modelo ativo como default
    Default oView := FWViewActive() //-- View ativa como default

    //-- Inicializar as variáveis
    nRet := 0
    aSaveLines := FWSaveRows()
    lIsViewActv := .F.

    //-- Avaliar o modelo ativo
    If oMdl <> Nil .And. oMdl:GetId() == "MATA162"

        //-- Inicializar os submodelos dos Produtos da Cotação (DHV) e Encerramento (SCE)
        oGridDHV := oMdl:GetModel("DHVDETAIL")
        oGridSCE := oMdl:GetModel("SCEDETAIL")

        //-- Definir se a view está ativa
        lIsViewActv := oView <> Nil .And. oView:IsActive()

        //-- Calcular o total em análise
        For nX := 1 To oGridSCE:Length()
            oGridSCE:GoLine(nX)
            If !oGridSCE:IsDeleted()
                nRet += oGridSCE:GetValue("CE_TOTAL")
            EndIf
        Next nX

        //-- Liberar o modo de edição do campo
        oGridDHV:GetStruct():SetProperty("DHV_TOTAL", MODEL_FIELD_WHEN, {|| .T.})

        //-- Atribuir ao total o valor calculado
        oGridDHV:LoadValue("DHV_TOTAL", nRet)

        //-- Bloquear modo de edição do campo
        oGridDHV:GetStruct():SetProperty("DHV_TOTAL", MODEL_FIELD_WHEN, {|| .F.})

        //-- Restaurar os grids
        FWRestRows(aSaveLines)
        
        //-- Atualizar a view
        If lIsViewActv
            oView:Refresh("VIEW_DHV")
        EndIf

        //-- Limpar a memória
        aSize(aSaveLines, 0)
        aSaveLines := Nil

    EndIf

Return nRet


Static Function A162SCETot(oMdl as Object, oView as Object) as Numeric

    Local aSaveLines as Array

    Local nRet as Numeric

    Local oGridSCE as Object
    
    Default oMdl := FWModelActive() //-- Modelo ativo como default
    Default oView := FWViewActive() //-- View ativa como default

    //-- Inicializar as variáveis
    nRet := 0
    aSaveLines := FWSaveRows()

    //-- Avaliar o modelo ativo
    If oMdl <> Nil .And. oMdl:GetId() == "MATA162"

        //-- Inicializar o submodelo da Encerramento (SCE)
        oGridSCE := oMdl:GetModel("SCEDETAIL")

        //-- Calcular o total
        nRet := Round(oGridSCE:GetValue("CE_QUANT") * oGridSCE:GetValue("CE_VUNIT"), 2)

        //-- Liberar o modo de edição do campo
        oGridSCE:GetStruct():SetProperty("CE_TOTAL", MODEL_FIELD_WHEN, {|| .T.})
        
        //-- Atribuir valor total calculado
        oGridSCE:LoadValue("CE_TOTAL", nRet)

        //-- Bloquear modo de edição do campo
        oGridSCE:GetStruct():SetProperty("CE_TOTAL", MODEL_FIELD_WHEN, {|| .F.})

        //-- Restaurar os grids
        FWRestRows(aSaveLines)
        
        //-- Atualizar a view
        oView:Refresh("VIEW_SCE")

        //-- Limpar a memória
        aSize(aSaveLines, 0)
        aSaveLines := Nil

    EndIf

Return nRet

Function A162Custo(nOper, nTxJuros, nRecSC8) as Numeric

    Local aRefImpos := {}
    Local aVencto   := {}
    Local aDupl     := {}
    Local aAuxDup   := {}
    Local aCusto    := {}
    Local cFilSF4   := xFilial("SF4")
    Local nX        := 0
    Local nTaxa     := 0
    Local nValor    := 0
    Local nTotal    := 0
    Local nValBase  := 0
    Local nValIPI   := 0
    Local nValSol   := 0
    Local nRet      := 0
    Local nItem     := 1
    Local lMA162CUS := ExistBlock("MA162CUS")
    Local lMtxFisCo := GetNewPar("MV_PERFORM", .T.)
    Local lAltC8TxFi:= .F. 
    Local nBaseDup  := 0 

    Default nOper := 0
    Default nTxJuros := SuperGetMV("MV_JUROS", .F., 5)
    Default nRecSC8 := 0


    If nOper == 1 .Or. nOper == 2

        //-- Array para a Referencia do Imposto
        aRefImpos := MaFisRelImp("MT162", {"SC8"})

        If nRecSC8 > 0
            SC8->(MsGoTo(nRecSC8))
        EndIf

        //-- Calcula o Custo para o valor total do produto
        MaFisIni(SC8->C8_FORNECE, SC8->C8_LOJA, "F", "N", "R")
        MaFisIniLoad(1)
        
        For nX := 1 To Len(aRefImpos)
            MaFisLoad(aRefImpos[nX, 3], SC8->(FieldGet(FieldPos(aRefImpos[nX, 2]))), 1)
        Next nX
        
        MaFisEndLoad(1)

        nBaseDup := Iif(lMtxFisCo, MaFisRet(, "NF_BASEDUP"), 0)

        //-- Indica se ira utilizar as funcoes fiscais para calcular o valor presente. So pode usar esse parametro quem utiliza calculo especifico via ponto de entrada.
        If !lMtxFisCo .And. !lMA162CUS
            nBaseDup  := MaFisRet(, "NF_BASEDUP")
        EndIf

        If lMA162CUS
            nRet := ExecBlock("MA162CUS", .F., .F., {"SC8", nItem})
            If Valtype(nRet) <> "N"
                nRet := 0
            EndIf
        Else	
            lAltC8TxFi := (GetSX3Cache("C8_TAXAFIN", "X3_VISUAL") $ " A")
            
            If lAltC8TxFi
                nTaxa := SC8->C8_TAXAFIN
            Else
                nTaxa := nTxJuros
            EndIf	
            
            //-- Melhorar performance
            DbSelectArea("SF4")
            DbSetOrder(1)
            MsSeek(cFilSF4 + SC8->C8_TES)	
            
            //-- Se utiliza TES que nao gera duplicata a referencia NF_BASEDUP fica zerada, neste caso considera a referencia NF_TOTAL
            If nBaseDup == 0 .And. SF4->F4_DUPLIC != "S"
                nBaseDup := MaFisRet(, "NF_TOTAL")
            EndIf

            nValBase := xMoeda(nBaseDup, SC8->C8_MOEDA, 1, SC8->C8_EMISSAO,, SC8->C8_TXMOEDA)
            nValIPI := xMoeda(MaFisRet(,"NF_VALIPI"), SC8->C8_MOEDA, 1, SC8->C8_EMISSAO,, SC8->C8_TXMOEDA)
            nValSol := xMoeda(MaFisRet(,"NF_VALSOL"), SC8->C8_MOEDA, 1, SC8->C8_EMISSAO,, SC8->C8_TXMOEDA)
            nValICMS := xMoeda(MaFisRet(,"NF_VALICM"), SC8->C8_MOEDA, 1, SC8->C8_EMISSAO,, SC8->C8_TXMOEDA)
            aVencto := Condicao(nValBase, SC8->C8_COND, nValIPI, dDataBase, nValSol)

            //-- Montar o array utilizado na geracao das duplicatas
            For nX := 1 to Len(aVencto)
                nValor := MaValPres(aVencto[nX][2], aVencto[nX][1], nTaxa)
                If nX == Len(aVencto) .And. ((nTotal + nValor) <> nValBase .And. !(nTaxa > 0))
                    nValor += (nBaseDup - (nTotal + nValor))
                EndIf
                nTotal += nValor
                AAdd(aAuxDup, {"MT160  ", "   ", " ", aVencto[nX][1], nValor})
            Next nX

            For nX := 1 to Len(aAuxDup)
                AAdd(aDupl, aAuxDup[nX][2] + "³" + aAuxDup[nX][1] + "³ " + aAuxDup[nX][3] + " ³" + DTOC(aAuxDup[nX][4]) + "³ " + Transform(aAuxDup[nX][5], PesqPict("SE2", "E2_VALOR", 14, 1)))
            Next nX
            
            DbSelectArea("SF4")
            DbSetOrder(1)
            MsSeek(cFilSF4 + SC8->C8_TES)

            If cPaisLoc <> "BRA"
                AAdd(aCusto, {nTotal,;
                              0,;
                              0,;
                              "N",;
                              "N",;
                              "0",;
                              "0",;
                              SC8->C8_PRODUTO,;
                              RetFldProd(SB1->B1_COD, "B1_LOCPAD"),;
                              SC8->C8_QUANT,;
                              0})
            Else
                AAdd(aCusto, {nTotal - IIf(!Empty(SC8->C8_TES) .And. SF4->F4_IPI == "R", 0, nValIPI) + MaFisRet(nItem, "IT_VALCMP"),;
                              nValIPI,;
                              nValICMS,;
                              Iif(Empty(SC8->C8_TES), "N", SF4->F4_CREDIPI),;
                              Iif(Empty(SC8->C8_TES), "N", SF4->F4_CREDICM),;
                              MaFisRet(nItem, "IT_NFORI"),;
                              MaFisRet(nItem, "IT_SERORI"),;
                              SC8->C8_PRODUTO,;
                              RetFldProd(SB1->B1_COD, "B1_LOCPAD"),;
                              SC8->C8_QUANT,;
                              Iif(!Empty(SC8->C8_TES) .And. SF4->F4_IPI == "R", nValIPI, 0),;
                              SF4->F4_CREDST,;
                              SC8->C8_VALSOL})
            EndIf

            nRet := RetCusEnt(aDupl, aCusto, "N")[1][1]

            If nOper == 2 //-- Custo Unitário
                nRet := Round(nRet/SC8->C8_QUANT, GetSX3Cache("C8_PRECO", "X3_DECIMAL")) 
            EndIf

        EndIf
    EndIf

Return nRet

Static Function A162MinMax(cNumCot as Char, nOper as Numeric, oModel as Object, oDHUMaster as Object, oDHVDetail as Object, oSC8Detail as Object, lRateByItem as Logical, lCheckItems as Logical, aItems as Array, lVldDueDate as Logical) as Array

    Local aRet as Array
    Local aAux as Array
    Local cAliasQry as Char
    Local cField as Char
    Local cWhereAux as Char
    Local nX as Numeric
    Local nY as Numeric
    Local nLenAux as Numeric

    Default cNumCot := DHU->DHU_NUM
    Default nOper := 0
    Default oModel := FWModelActive()
    Default oDHUMaster := Nil
    Default oDHVDetail := Nil
    Default oSC8Detail := Nil
    Default lRateByItem := .T.
    Default lCheckItems := .F.
    Default aItems := {}
    Default lVldDueDate := .F.

    //-- Inicializar as variáveis
    aRet := Iif(lRateByItem, {}, {0, 0})
    aAux := {}
    cAliasQry := ""
    cField := ""
    cWhereAux := "%%"
    nX := 0
    nY := 0
    nLenAux := 0

    If nOper > 0 .And. oModel <> Nil .And. oModel:GetId() == "MATA162" .And. oDHUMaster <> Nil .And. oDHVDetail <> Nil .And. oSC8Detail <> Nil

        If lVldDueDate
            cWhereAux := "% AND C8_VALIDA >='" + DToS(dDataBase) + "' %"
        EndIf

        Do Case 
            Case lRateByItem

                If nOper == 1 .Or. nOper == 2 //-- Obter Preço Mínimo/Preço Máximo e Prazo Máximo/Prazo Mínimo
                
                    cField := Iif(nOper == 1, "C8_CUSTO1", "C8_PRAZO")

                    If lCheckItems
                        For nX := 1 To Len(aItems)
                            If oDHVDetail:SeekLine({{"DHV_ITEM", aItems[nX]}}, .F., .T.)
                                AAdd(aAux, {oDHVDetail:GetValue("DHV_ITEM"), {}})
                                For nY := 1 To oSC8Detail:Length()
                                    oSC8Detail:GoLine(nY)
                                    If !oSC8Detail:IsDeleted() .And. Iif(lVldDueDate, oSC8Detail:GetValue("C8_VALIDA") >= dDataBase, .T.)
                                      AAdd(aAux[1][2], oSC8Detail:GetValue(cField))
                                    EndIf
                                Next nY
                                If Len(aAux[1][2]) > 0
                                    ASort(aAux[1][2],,, {|a,b| a < b})
                                    AAdd(aRet, {aAux[1][1], {aAux[1][2][1], aAux[1][2][Len(aAux[1][2])]}})
                                    ASize(aAux, 0)
                                Else
                                    AAdd(aRet, {aAux[1][1], {0, 0}})
                                    ASize(aAux, 0)
                                EndIf
                            EndIf
                        Next nX
                    Else
                        For nX := 1 To oDHVDetail:Length()
                            oDHVDetail:GoLine(nX)
                            If !oDHVDetail:IsDeleted()
                                AAdd(aAux, {oDHVDetail:GetValue("DHV_ITEM"), {}})
                                For nY := 1 To oSC8Detail:Length()
                                    oSC8Detail:GoLine(nY)
                                    If !oSC8Detail:IsDeleted() .And. Iif(lVldDueDate, oSC8Detail:GetValue("C8_VALIDA") >= dDataBase, .T.)
                                        AAdd(aAux[1][2], oSC8Detail:GetValue(cField))
                                    EndIf
                                Next nY
                                If Len(aAux[1][2]) > 0
                                    ASort(aAux[1][2],,, {|a,b| a < b})
                                    AAdd(aRet, {aAux[1][1], {aAux[1][2][1], aAux[1][2][Len(aAux[1][2])]}})
                                    ASize(aAux, 0)
                                Else
                                    AAdd(aRet, {aAux[1][1], {0, 0}})
                                    ASize(aAux, 0)
                                EndIf
                            EndIf
                        Next nX
                    EndIf
                ElseIf nOper == 3

                    cAliasQry := GetNextAlias()

                    If lCheckItems

                        For nX := 1 To Len(aItems)

                            BeginSQL Alias cAliasQry
                                    
                                SELECT 		C8_IDENT AS IDENT,
                                            MAX(ISNULL(A5_NOTA, 0)) AS MAXIMO, 
                                            MIN(ISNULL(A5_NOTA, 0)) AS MINIMO
                                FROM 		%Table:SC8% SC8
                                JOIN        %Table:DHV% DHV
                                ON          DHV.DHV_FILIAL      = %xFilial:DHV%
                                            AND DHV_NUM         = SC8.C8_NUM
                                            AND DHV.DHV_ITEM    = %Exp:aItems[nX]%
                                            AND DHV.DHV_CODPRO  = SC8.C8_PRODUTO
                                            AND DHV.%NotDel%
                                LEFT JOIN 	%Table:SA5% SA5
                                ON 			SA5.A5_FILIAL 		= %xFilial:SA5%
                                            AND SA5.A5_FORNECE 	= SC8.C8_FORNECE
                                            AND SA5.A5_LOJA 	= SC8.C8_LOJA	
                                            AND SA5.A5_PRODUTO	= SC8.C8_PRODUTO
                                            AND SA5.%NotDel%
                                WHERE 		SC8.C8_FILIAL 		= %xFilial:SC8% 
                                            AND SC8.C8_NUM		= %Exp:cNumCot%
                                            AND SC8.C8_PRECO 	> 0
                                            %Exp:cWhereAux%		
                                            AND SC8.%NotDel%
                                GROUP BY    C8_IDENT

                            EndSQL
                            
                            While !(cAliasQry)->(Eof())
                                nLenAux++ 
                                AAdd(aRet, {(cAliasQry)->IDENT, {}})
                                AAdd(aRet[nLenAux][2], (cAliasQry)->MINIMO)
                                AAdd(aRet[nLenAux][2], (cAliasQry)->MAXIMO)
                                (cAliasQry)->(DbSkip())
                            EndDo

                            (cAliasQry)->(DbCloseArea())
                        Next nX
                    Else

                        BeginSQL Alias cAliasQry
                                
                            SELECT 		C8_IDENT AS IDENT,
                                        MAX(ISNULL(A5_NOTA, 0)) AS MAXIMO, 
                                        MIN(ISNULL(A5_NOTA, 0)) AS MINIMO
                            FROM 		%Table:SC8% SC8
                            JOIN        %Table:DHV% DHV
                            ON          DHV.DHV_FILIAL      = %xFilial:DHV%
                                        AND DHV_NUM         = SC8.C8_NUM
                                        AND DHV.DHV_ITEM    = SC8.C8_IDENT
                                        AND DHV.DHV_CODPRO  = SC8.C8_PRODUTO
                                        AND DHV.%NotDel%
                            LEFT JOIN 	%Table:SA5% SA5
                            ON 			SA5.A5_FILIAL 		= %xFilial:SA5%
                                        AND SA5.A5_FORNECE 	= SC8.C8_FORNECE
                                        AND SA5.A5_LOJA 	= SC8.C8_LOJA	
                                        AND SA5.A5_PRODUTO	= SC8.C8_PRODUTO
                                        AND SA5.%NotDel%
                            WHERE 		SC8.C8_FILIAL 		= %xFilial:SC8% 
                                        AND SC8.C8_NUM		= %Exp:cNumCot%
                                        AND SC8.C8_PRECO 	> 0		
                                        %Exp:cWhereAux%
                                        AND SC8.%NotDel%
                            GROUP BY    C8_IDENT

                        EndSQL

                        While !(cAliasQry)->(Eof())
                            nLenAux++ 
                            AAdd(aRet, {(cAliasQry)->IDENT, {}})
                            AAdd(aRet[nLenAux][2], (cAliasQry)->MINIMO)
                            AAdd(aRet[nLenAux][2], (cAliasQry)->MAXIMO)
                            (cAliasQry)->(DbSkip())
                        EndDo

                        (cAliasQry)->(DbCloseArea())

                    EndIf

                EndIf

            Otherwise

                If nOper == 1 //-- Obter Preço Mínimo e Preço Máximo 
                    cAliasQry := GetNextAlias()

                    BeginSQL Alias cAliasQry
                
                        SELECT
                        DISTINCT    C8_FORNECE,
                                    C8_LOJA,
                                    C8_FORNOME,
                                    C8_NUMPRO
                        FROM 		%Table:SC8% SC8
                        JOIN        %Table:DHV% DHV
                        ON          DHV.DHV_FILIAL      = %xFilial:DHV%
                                    AND DHV_NUM         = SC8.C8_NUM
                                    AND DHV.DHV_ITEM    = SC8.C8_IDENT
                                    AND DHV.DHV_CODPRO  = SC8.C8_PRODUTO
                                    AND DHV.%NotDel%
                        WHERE 		SC8.C8_FILIAL 	    = %xFilial:SC8% 
                                    AND SC8.C8_NUM	    = %Exp:cNumCot%
                                    AND SC8.C8_PRECO    > 0
                                    AND SC8.C8_COND     <> %Exp:Space(FWTamSX3("C8_COND")[1])% 
                                    AND SC8.%NotDel%
                                    %Exp:cWhereAux% 

                    EndSQL

                    While !(cAliasQry)->(Eof()) 
                        AAdd(aAux, {(cAliasQry)->C8_FORNECE, (cAliasQry)->C8_LOJA, (cAliasQry)->C8_FORNOME, (cAliasQry)->C8_NUMPRO, 0})
                        (cAliasQry)->(DbSkip())
                    EndDo

                    (cAliasQry)->(DbCloseArea())

                    nLenAux := Len(aAux)

                    For nX := 1 To nLenAux
                        For nY := 1 To oDHVDetail:Length()
                            oDHVDetail:GoLine(nY)
                            If !oDHVDetail:IsDeleted()
                                If oSC8Detail:SeekLine({{"C8_FORNECE", aAux[nX][1]}, {"C8_LOJA", aAux[nX][2]}, {"C8_FORNOME", aAux[nX][3]}, {"C8_NUMPRO", aAux[nX][4]}}, .F., .T.)
                                    aAux[nX][5] += oSC8Detail:GetValue("C8_CUSTO1")
                                EndIf
                            EndIf
                        Next nY
                    Next nX

                    If nLenAux > 0
                        ASort(aAux,,, {|a,b| a[5] < b[5]})
                        aRet[1] := aAux[1][5]
                        aRet[2] := aAux[nLenAux][5]
                    EndIf

                ElseIf nOper == 2 .Or. nOper == 3//-- Obter Prazo e Nota Mínima e Prazo e Nota Máxima

                    cAliasQry := GetNextAlias()
                    cField := Iif(nOper == 2, "%C8_PRAZO%", "%A5_NOTA%")
                    
                    BeginSQL Alias cAliasQry
                
                        SELECT 		MAX(ISNULL(%Exp:cField%, 0)) AS MAXIMO, 
                                    MIN(ISNULL(%Exp:cField%, 0)) AS MINIMO
                        FROM 		%Table:SC8% SC8
                        JOIN        %Table:DHV% DHV
                        ON          DHV.DHV_FILIAL      = %xFilial:DHV%
                                    AND DHV_NUM         = SC8.C8_NUM
                                    AND DHV.DHV_ITEM    = SC8.C8_IDENT
                                    AND DHV.DHV_CODPRO  = SC8.C8_PRODUTO
                                    AND DHV.%NotDel%
                        LEFT JOIN 	%Table:SA5% SA5
                        ON 			SA5.A5_FILIAL 		= %xFilial:SA5%
                                    AND SA5.A5_FORNECE 	= SC8.C8_FORNECE
                                    AND SA5.A5_LOJA 	= SC8.C8_LOJA	
                                    AND SA5.A5_PRODUTO	= SC8.C8_PRODUTO
                                    AND SA5.%NotDel%
                        WHERE 		SC8.C8_FILIAL 		= %xFilial:SC8% 
                                    AND SC8.C8_NUM		= %Exp:cNumCot%
                                    AND SC8.C8_PRECO 	> 0
                                    AND SC8.%NotDel%

                    EndSQL

                    If !(cAliasQry)->(Eof()) 
                        aRet[1] := (cAliasQry)->MINIMO
                        aRet[2] := (cAliasQry)->MAXIMO
                    EndIf

                    (cAliasQry)->(DbCloseArea())

                EndIf
        EndCase
    EndIf

    //-- Limpar a memória
    If Len(aAux) > 0
        ASize(aAux, 0)
    EndIf
    aAux := Nil

Return aRet


Static Function A162EvalChk(nNumCot as Char, lRateByItem as Logical, lVldDueDate as Logical) as Logical

    Local lRet as Logical
    Local cAliasAux as Char
    Local nQuantIdt as Numeric
    
    Default cNumCot := DHU->DHU_NUM
    Default lRateByItem := .T.

    //-- Inicializar as variáveis
    lRet := .T.
    cAliasAux := GetNextAlias()
    nQuantIdt := 0

    //-- Query para obter a média de nota e prazos
    BeginSQL Alias cAliasAux

        SELECT	    COUNT(DISTINCT C8_IDENT) AS QUANTIDT
        FROM 	    %Table:SC8% SC8
        WHERE 	    SC8.C8_FILIAL 		= %xFilial:SC8%
                    AND SC8.C8_NUM 		= %Exp:cNumCot%
                    AND SC8.C8_PRECO    > 0
                    AND SC8.C8_COND     <> %Exp:Space(FWTamSX3("C8_COND")[1])% 
                    AND SC8.%NotDel%
    EndSQL

    If (cAliasAux)->(!Eof())
        nQuantIdt := (cAliasAux)->QUANTIDT
    EndIf

    (cAliasAux)->(DbCloseArea())

    If lRateByItem
        lRet := nQuantIdt > 0
    EndIf

    If lRet .And. !lRateByItem
        BeginSQL Alias cAliasAux

            SELECT      C8_FORNECE, 
                        C8_LOJA, 
                        C8_FORNOME, 
                        C8_NUMPRO,
                        COUNT(C8_IDENT) AS IDTXPRO
            FROM 		%Table:SC8% SC8
            WHERE 		SC8.C8_FILIAL 		= %xFilial:SC8%
                        AND SC8.C8_NUM 		= %Exp:cNumCot%
                        AND SC8.C8_PRECO    > 0
                        AND SC8.C8_COND     <> %Exp:Space(FWTamSX3("C8_COND")[1])% 
                        AND SC8.%NotDel%
            GROUP BY    C8_FORNECE, C8_LOJA, C8_FORNOME, C8_NUMPRO
            ORDER BY 	C8_FORNECE, C8_LOJA, C8_FORNOME, C8_NUMPRO
        EndSQL

        lRet := .F. //-- Reseta retorno

        While (cAliasAux)->(!Eof())
            
            lRet := nQuantIdt == (cAliasAux)->IDTXPRO
                
            If !lRet
                Exit
            EndIf

            (cAliasAux)->(DbSkip())
        EndDo

        (cAliasAux)->(DbCloseArea())
    EndIf


Return lRet

Static Function A162Rank(cNumCot as Char, lRateByItem as Logical, lCheckItems as Logical, aItems as Array, nQtWin as Numeric, aMinMaxPrc as Array, aMinMaxPrz as Array, aMinMaxNt as Array, nRatePrc as Numeric, nRateTime as Numeric, nRateNote as Numeric, lVldDueDate as Logical, oDHUMaster as Object, oDHVDetail as Object, oSC8Detail as Object) as Array

    Local aRet as Array
    Local aAux as Array
    Local aSaveLines as Array
    Local cFilSA5 as Char
    Local cAliasAux as Char
    Local cKeyProp as Char
    Local nLenPrc as Numeric
    Local nLenPrz as Numeric
    Local nLenNt as Numeric
    Local nScore as Numeric
    Local nX as Numeric
    Local nY as Numeric
    Local nZ as Numeric
    Local lPropOk as Logical

    Default cNumCot := DHU->DHU_NUM
    Default lRateByItem := .T.
    Default lCheckItems := .F.
    Default aItems := {}
    Default nQtWin := 1
    Default aMinMaxPrc := {}
    Default aMinMaxPrc := {}
    Default aMinMaxNt := {}
    Default lVldDueDate := .F.
    Default nRatePrc := 0
    Default nRateTime := 0
    Default nRateNote := 0
    Default oDHVDetail := Nil
    Default oSC8Detail := Nil

    //-- Inicializar variáveis
    aRet := {}
    aAux := {}
    aSaveLines := FWSaveRows()
    cFilSA5 := xFilial("SA5")
    cAliasAux := ""
    cKeyProp := ""
    nLenPrc := Len(aMinMaxPrc)
    nLenPrz := Len(aMinMaxPrz)
    nLenNt  := Len(aMinMaxNt)
    nX := 0
    nY := 0
    nZ := 0
    nScore := 0
    lPropOk := .T.

    If (oDHVDetail <> Nil .And. oSC8Detail <> Nil) .And. nQtWin > 0 .And. (nLenPrc > 0 .Or. nLenPrz > 0 .Or. nLenNt > 0) 
        If lRateByItem
            If lCheckItems
                For nX := 1 To Len(aItems)
                    If oDHVDetail:SeekLine({{"DHV_ITEM", aItems[nX]}}, .F., .T.)
                        AAdd(aAux, {oDHVDetail:GetValue("DHV_ITEM"), {}})
                        For nY := 1 To oSC8Detail:Length()
                            oSC8Detail:GoLine(nY)
                            nScore := 0
                            If !oSC8Detail:IsDeleted() .And. Iif(lVldDueDate, oSC8Detail:GetValue("C8_VALIDA") >= dDataBase, .T.)
                                If nLenPrc > 0 .And. nRatePrc > 0
                                    nScore	+=	nRatePrc * ( (oSC8Detail:GetValue("C8_CUSTO1") - aMinMaxPrc[nX][2][1]) / (aMinMaxPrc[nX][2][2] - aMinMaxPrc[nX][2][1]) ) 
                                EndIf
                                If nLenPrz > 0 .And. nRateTime > 0
                                    nScore	+=	nRateTime * ( (oSC8Detail:GetValue("C8_PRAZO") - aMinMaxPrz[nX][2][1]) / (aMinMaxPrz[nX][2][2] - aMinMaxPrz[nX][2][1]) ) 
                                EndIf
                                If nLenNt > 0 .And. nRateNote > 0
                                    nScore	+=	nRateNote * ( (GetAdvFVal("SA5","A5_NOTA", cFilSA5 + oSC8Detail:GetValue("C8_FORNECE") + oSC8Detail:GetValue("C8_LOJA") + oDHVDetail:GetValue("DHV_CODPRO"), 1, 0, .T.) - aMinMaxNt[nX][2][1]) / (aMinMaxNt[nX][2][2] - aMinMaxNt[nX][2][1]) ) 
                                EndIf    
                                AAdd(aAux[1][2], {oSC8Detail:GetValue("C8_FORNECE"), oSC8Detail:GetValue("C8_LOJA"), oSC8Detail:GetValue("C8_FORNOME"), oSC8Detail:GetValue("C8_NUMPRO"), nScore})
                            EndIf
                        Next nY
                        If Len(aAux[1][2]) > 0
                            AAdd(aRet, {aAux[1][1], {}})
                            ASort(aAux[1][2],,, {|a,b| a[5] < b[5]})
                            For nZ := 1 To nQtWin
                                AAdd(aRet[nX][2], aAux[1][2][nZ])
                            Next nZ
                        EndIf
                        ASize(aAux, 0)
                    EndIf
                Next nX
            Else
                For nX := 1 To oDHVDetail:Length()
                    oDHVDetail:GoLine(nX)
                    If !oDHVDetail:IsDeleted()
                        AAdd(aAux, {oDHVDetail:GetValue("DHV_ITEM"), {}})
                        For nY := 1 To oSC8Detail:Length()
                            oSC8Detail:GoLine(nY)
                            nScore := 0
                            If !oSC8Detail:IsDeleted() .And. Iif(lVldDueDate, oSC8Detail:GetValue("C8_VALIDA") >= dDataBase, .T.)
                                If nLenPrc > 0 .And. nRatePrc > 0
                                    nScore	+=	nRatePrc * ( (oSC8Detail:GetValue("C8_CUSTO1") - aMinMaxPrc[nX][2][1]) / (aMinMaxPrc[nX][2][2] - aMinMaxPrc[nX][2][1]) ) 
                                EndIf
                                If nLenPrz > 0 .And. nRateTime > 0
                                    nScore	+=	nRateTime * ( (oSC8Detail:GetValue("C8_PRAZO") - aMinMaxPrz[nX][2][1]) / (aMinMaxPrz[nX][2][2] - aMinMaxPrz[nX][2][1]) ) 
                                EndIf
                                If nLenNt > 0 .And. nRateNote > 0
                                    nScore	+=	nRateNote * ( (GetAdvFVal("SA5","A5_NOTA", cFilSA5 + oSC8Detail:GetValue("C8_FORNECE") + oSC8Detail:GetValue("C8_LOJA") + oDHVDetail:GetValue("DHV_CODPRO"), 1, 0, .T.) - aMinMaxNt[nX][2][1]) / (aMinMaxNt[nX][2][2] - aMinMaxNt[nX][2][1]) )
                                EndIf    
                                AAdd(aAux[1][2], {oSC8Detail:GetValue("C8_FORNECE"), oSC8Detail:GetValue("C8_LOJA"), oSC8Detail:GetValue("C8_FORNOME"), oSC8Detail:GetValue("C8_NUMPRO"), nScore})
                            EndIf
                        Next nY
                        If Len(aAux[1][2]) > 0
                            AAdd(aRet, {aAux[1][1], {}})
                            ASort(aAux[1][2],,, {|a,b| a[5] < b[5]})
                            For nZ := 1 To nQtWin
                                AAdd(aRet[nX][2], aAux[1][2][nZ])
                            Next nZ
                        EndIf
                        ASize(aAux, 0)
                    EndIf
                Next nX
            EndIf
        Else
            //-- Query para obter a média de nota e prazos
            cAliasAux := GetNextAlias()
            BeginSQL Alias cAliasAux

            SELECT		C8_FORNECE,
                        C8_LOJA,
                        C8_FORNOME,  										 
                        C8_NUMPRO,
                        AVG(C8_PRAZO) AS C8PRAZO,
                        AVG(ISNULL(A5_NOTA, 0)) AS A5NOTA
            FROM 		%Table:SC8% SC8
            LEFT JOIN 	%Table:SA5% SA5
            ON			SA5.A5_FILIAL  		= %xFilial:SA5%
                        AND SA5.A5_FORNECE 	= SC8.C8_FORNECE
                        AND A5_LOJA 		= SC8.C8_LOJA
                        AND SA5.A5_PRODUTO  = SC8.C8_PRODUTO
                        AND SA5.%NotDel%
            WHERE 		SC8.C8_FILIAL 		= %xFilial:SC8%
                        AND SC8.C8_NUM 		= %Exp:cNumCot%
                        AND SC8.C8_PRECO    > 0
                        AND SC8.C8_COND     <> %Exp:Space(FWTamSX3("C8_COND")[1])% 
                        AND SC8.%NotDel%
            GROUP BY    C8_FORNECE, C8_LOJA, C8_FORNOME, C8_NUMPRO
            ORDER BY 	C8_FORNECE, C8_LOJA, C8_FORNOME, C8_NUMPRO

            EndSQL

            While !(cAliasAux)->(Eof())
                aAdd(aAux, {(cAliasAux)->C8_FORNECE, (cAliasAux)->C8_LOJA, (cAliasAux)->C8_FORNOME, C8_NUMPRO, 0, {0, (cAliasAux)->C8PRAZO, (cAliasAux)->A5NOTA}})
                (cAliasAux)->(DbSkip())
            End

            (cAliasAux)->(DbCloseArea())

            If Len(aAux) > 0
                For nX := 1 To oDHVDetail:Length()
                    oDHVDetail:GoLine(nX)
                    If lPropOk .And. oDHVDetail:GetLine() == nX
                        If !oDHVDetail:IsDeleted()
                            For nY := 1 To oSC8Detail:Length()
                                oSC8Detail:GoLine(nY)
                                If oSC8Detail:GetLine() == nY 
                                    If !oSC8Detail:IsDeleted()
                                        cKeyProp := oSC8Detail:GetValue("C8_FORNECE") + oSC8Detail:GetValue("C8_LOJA") + oSC8Detail:GetValue("C8_FORNOME") + oSC8Detail:GetValue("C8_NUMPRO")
                                        nSumCost := 0
                                        nPosProp := AScan(aAux, {|x| x[1] + x[2] + x[3] + x[4] == cKeyProp})
                                        If nPosProp > 0
                                            If Len(aAux[nPosProp]) == 6
                                                If oSC8Detail:SeekLine({{"C8_FORNECE", aAux[nPosProp][1]}, {"C8_LOJA", aAux[nPosProp][2]}, {"C8_FORNOME", aAux[nPosProp][3]}, {"C8_NUMPRO", aAux[nPosProp][4]}}, .F., .T.)
                                                    aAux[nPosProp][6][1] += oSC8Detail:GetValue("C8_CUSTO1")
                                                EndIf
                                            EndIf
                                        EndIf
                                    EndIf
                                Else
                                    lPropOk := .F.
                                    Exit
                                EndIf
                            Next nY
                        EndIf
                    Else
                        lPropOk := .F.
                        Exit
                    EndIf
                Next nX

                If lPropOk
                    For nX := 1 To Len(aAux)
                        nScore := 0
                        If nLenPrc > 0 .And. nRatePrc > 0
                            nScore	+=	nRatePrc * ( (aAux[nX][6][1] - aMinMaxPrc[1]) / (aMinMaxPrc[2] - aMinMaxPrc[1]) ) 
                        EndIf
                        If nLenPrz > 0 .And. nRateTime > 0
                            nScore	+=	nRateTime * ( (aAux[nX][6][2] - aMinMaxPrz[1]) / (aMinMaxPrz[2] - aMinMaxPrz[1]) ) 
                        EndIf
                        If nLenNt > 0 .And. nRateNote > 0
                            nScore	+=	nRateNote * ( (aAux[nX][6][3] - aMinMaxNt[1]) / (aMinMaxNt[2] - aMinMaxNt[1]) )
                        EndIf
                        aAux[nX][5] := nScore
                    Next nX

                    ASort(aAux,,, {|a,b| a[5] < b[5]})

                    For nX := 1 To nQtWin
                        AAdd(aRet, aAux[nX])
                    Next nX
                EndIf

                //-- Limpar a memória
                ASize(aAux, 0)
                aAux := Nil
            EndIf
        EndIf
    EndIf

    //-- Restaurar posições dos grids
    FWRestRows(aSaveLines)

    //-- Limpar a Memória
    ASize(aSaveLines, 0)
    aSaveLines := Nil

Return aRet

Static Function A162MkWin(lRateByItem as Logical, aRank as Array, nQtWin as Numeric, oDHVDetail as Object, oSC8Detail as Object, oSCEDetail as Object, oSCEQry as Object) as Logical

    Local aSaveLines as Array
    Local lRet as Logical
    Local lOnly1Win as Logical
    Local nLenRank as Numeric
    Local nX as Numeric
    Local nY as Numeric
    Local nLineAux as Numeric
    
    Default lRateByItem := .T.
    Default aRank := {}
    Default nQtWin := 0
    Default oDHVDetail := Nil
    Default oSC8Detail := Nil
    Default oSCEDetail := Nil
    Default oSCEQry := Nil

    //-- Inicializar as variáveis
    aSaveLines := FWSaveRows()
    lRet := .T.
    nLenRank := Len(aRank)
    nX := 0
    nY := 0
    lOnly1Win := nQtWin == 1
    nLineAux := 1

    If nQtWin > 0 .And. nLenRank > 0 .And. oDHVDetail <> Nil .And. oSC8Detail <> Nil .And. oSCEDetail <> Nil .And. oSCEQry <> Nil
        If lRateByItem
            For nX := 1 To nLenRank
                    If oDHVDetail:SeekLine({{"DHV_ITEM", aRank[nX][1]}}, .F., .T.) .And. oDHVDetail:GetValue("DHV_SALDO") > 0
                        For nY := 1 To Len(aRank[nX][2])
                            If oSC8Detail:SeekLine({{"C8_FORNECE", aRank[nX][2][nY][1]}, {"C8_LOJA", aRank[nX][2][nY][2]}, {"C8_FORNOME", aRank[nX][2][nY][3]}, {"C8_NUMPRO", aRank[nX][2][nY][4]}}, .F., .T.)
                                If oSC8Detail:SetValue("C8_MARKW", .T.)
                                    oSC8Detail:LineShift(, nLineAux)
                                    nLineAux++
                                    If lOnly1Win .And. oSCEDetail:SeekLine({{"CE_FORNECE", aRank[nX][2][nY][1]}, {"CE_LOJA", aRank[nX][2][nY][2]}, {"CE_DESCFOR", aRank[nX][2][nY][3]}, {"CE_NUMPRO", aRank[nX][2][nY][4]}, {"CE_SEQ", A162GetSeq(2, oSC8Detail, oSCEDetail, oSCEQry)}}, .F., .T.)
                                        oSCEDetail:SetValue("CE_QUANT", oDHVDetail:GetValue("DHV_SALDO"))
                                    EndIf
                                EndIf
                            EndIf
                        Next nY
                    EndIf
                FWRestRows(aSaveLines)
            Next nX
        Else
            For nX := 1 To oDHVDetail:Length()
                oDHVDetail:GoLine(nX)
                If oDHVDetail:GetLine() == nX
                    If !oDHVDetail:IsDeleted() .And. oDHVDetail:GetValue("DHV_SALDO") > 0
                        For nY := 1 To nLenRank
                            If oSC8Detail:SeekLine({{"C8_FORNECE", aRank[nY][1]}, {"C8_LOJA", aRank[nY][2]}, {"C8_FORNOME", aRank[nY][3]}, {"C8_NUMPRO", aRank[nY][4]}}, .F., .T.)
                                If oSC8Detail:SetValue("C8_MARKW", .T.)
                                    oSC8Detail:LineShift(, nLineAux)
                                    nLineAux++
                                    If lOnly1Win .And. oSCEDetail:SeekLine({{"CE_FORNECE", aRank[nY][1]}, {"CE_LOJA", aRank[nY][2]}, {"CE_DESCFOR", aRank[nY][3]}, {"CE_NUMPRO", aRank[nY][4]}, {"CE_SEQ", A162GetSeq(2, oSC8Detail, oSCEDetail, oSCEQry)}}, .F., .T.)
                                        oSCEDetail:SetValue("CE_QUANT", oDHVDetail:GetValue("DHV_SALDO"))
                                    EndIf
                                EndIf
                            EndIf
                        Next nY
                        FWRestRows(aSaveLines)
                    EndIf
                Else
                    lRet := .F.
                    Exit
                EndIf
            Next nX
        EndIf
    Else
        lRet := .F.
    EndIf

    //-- Restaurar posições dos grids
    FWRestRows(aSaveLines)

    //-- Limpar a memória
    aSize(aSaveLines, 0)
    aSaveLines := Nil

Return lRet


Function A162VldMkW(oModel as Object) as Logical

    Local lRet as Logical

    Default oModel := FWModelActive()

    lRet := .T.

    If FWFldGet("C8_MARKW",, oModel) .And. FWFldGet("DHV_SALDO",, oModel) == 0
        Help(,, "A162NOSLD",, STR0059, 1, 0) //-- "Saldo em quantidade insuficiente do produto!"
        lRet := .F.
    EndIf
           
Return lRet


Static Function A162Reset(oModel, oView)

    Local nX as Numeric
    Local nY as Numeric
    Local nTaxa as Numeric
    Local nRecSC8 as Numeric
    Local aSaveLines as Array
    Local aAreaSC8 as Array
    Local lIsViewActv as Logical
    Local lAltC8TxFi as Logical
    Local oDHUMaster as Object
    Local oDHVDetail as Object
    Local oSC8Detail as Object
    Local oSCEDetail as Object

    Default oModel := FWModelActive()
    Default oView := FWViewActive()
    
    //-- Inicializar as variáveis
    aSaveLines := FWSaveRows()
    lIsViewActv := oView <> Nil .And. oView:IsActive()
    aAreaSC8 := {}
    lAltC8TxFi := (GetSX3Cache("C8_TAXAFIN", "X3_VISUAL") $ " A")
    nTaxa := 0
    nRecSC8 := 0
    
    If !lAltC8TxFi
        nTaxa := SuperGetMV("MV_JUROS", .F., 5)
    EndIf

    If oModel <> Nil .And. oModel:GetId() == "MATA162"

        oDHUMaster := oModel:GetModel("DHUMASTER")
        oDHVDetail := oModel:GetModel("DHVDETAIL")
        oSC8Detail := oModel:GetModel("SC8DETAIL")
        oSCEDetail := oModel:GetModel("SCEDETAIL")
        aAreaSC8 := SC8->(GetArea())

        //-- Desbloquear modo de edição dos campos de custos e taxa
        oSC8Detail:GetStruct():SetProperty("C8_CUSTO1", MODEL_FIELD_WHEN, {|| .T.})
        oSC8Detail:GetStruct():SetProperty("C8_CUSUNI1", MODEL_FIELD_WHEN, {|| .T.})
        oSC8Detail:GetStruct():SetProperty("C8_TAXAFIN", MODEL_FIELD_WHEN, {|| .T.})

        For nX := 1 To oDHVDetail:Length()
            oDHVDetail:GoLine(nX)
            For nY := 1 To oSC8Detail:Length()
                oSC8Detail:GoLine(nY)
                If !oSC8Detail:IsDeleted() 
                    
                    //-- Resetar taxa e custos
                    nRecSC8 := oSC8Detail:GetDataId()
                    SC8->(DbGoTo(nRecSC8))
                    If lAltC8TxFi
                        nTaxa := SC8->C8_TAXAFIN
                    EndIf
                    If oSC8Detail:GetValue("C8_TAXAFIN") <> nTaxa
                        oSC8Detail:SetValue("C8_TAXAFIN", nTaxa)
                        oSC8Detail:SetValue("C8_CUSTO1", A162Custo(1, nTaxa, nRecSC8))
                        oSC8Detail:SetValue("C8_CUSUNI1", A162Custo(2, nTaxa, nRecSC8))               
                    EndIf

                    //-- Desmarcar vencedor
                    If oSC8Detail:GetValue("C8_MARKW")
                        oSC8Detail:SetValue("C8_MARKW", .F.)
                    EndIf
                EndIf
            Next nY

            //-- Limpar análise atual
            If oSCEDetail:CanClearData()
                oSCEDetail:ClearData()
            EndIf

        Next nX

        //-- Bloquear modo de edição dos campos de custos e taxa
        oSC8Detail:GetStruct():SetProperty("C8_CUSTO1", MODEL_FIELD_WHEN, {|| .F.})
        oSC8Detail:GetStruct():SetProperty("C8_CUSUNI1", MODEL_FIELD_WHEN, {|| .F.})
        oSC8Detail:GetStruct():SetProperty("C8_TAXAFIN", MODEL_FIELD_WHEN, {|| .F.})

        //-- Flag de avaliação automática
        oDHUMaster:SetValue("DHU_AVAUT", .F.)

        //-- Restaura area da SC8
        RestArea(aAreaSC8)

    EndIf

    //-- Restaurar os grids
    FWRestRows(aSaveLines)

    //-- Atualizar a view
    If lIsViewActv
        oView:Refresh()
    EndIf

    //-- Limpar a memória
    ASize(aSaveLines, 0)
    aSaveLines := Nil

Return Nil


Static Function A162HideFl(oView as Object) as Logical

    If oView:GetOperation() == MODEL_OPERATION_VIEW
        oView:HideFolder("AUDITFLD", STR0023, 2)
    EndIf

Return Nil


Function A162MaxProp() as Logical

    Local nQtReg as Numeric 
    Local cAliasAux as Char
    Local lRet as Logical

    nQtReg := 0
    cAliasAux := GetNextAlias()
    lRet := .T.

    BeginSQL Alias cAliasAux
        SELECT 
        DISTINCT    C8_FILIAL,
                    C8_FORNECE,
                    C8_LOJA,
                    C8_FORNOME,
                    C8_NUMPRO
        FROM        %Table:SC8% SC8
        WHERE       C8_FILIAL = %xFilial:SC8%
                    AND C8_NUM = %Exp:FWFldGet("DHU_NUM")%
                    AND SC8.%NotDel%
    EndSQL

    //-- Conta a quantidade de registros encontrados
    Count To nQtReg
    (cAliasAux)->(DbCloseArea())

    If nQtReg > 0 .And. FWFldGet("DHU_QTWIN") > nQtReg
        Help(,, "A162MAXPROP",, STR0061, 4, 1,,,,,, {STR0062 + cValToChar(nQtReg)}) //-- "Quantidade inválida! "A quantidade máxima de vencedores permitida para essa cotação é igual a: "
        lRet := .F.
    EndIf

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} A162Cntr()
Função para geração de Contrato a partir do Mapa de Cotação
@Param aWinners, Array, Vetor com o resultado das cotações para a geração do contrato
@author leonardo.magalhaes
@since 09/10/2020
@version 1.0
@return lRet
/*/
//-------------------------------------------------------------------
Function A162Cntr(aWinners as Array, aHdSCE as Array, oSC8Detail as Object, oSCEDetail as Object, oSCEQry as Object) as Logical

    Local aArea as Array 
    Local lRet as Logical
    Local aDados as Array
    Local nTpContr as Numeric	
    Local nX as Numeric
    Local oView as Object
    Local lIsViewActv as Logical

    Default aWinners := {}
    Default aHdSCE := {}

    //-- Inicializar variáveis
    aArea := GetArea()
    lRet := .T.
    aDados	:= A162Ordena(aWinners, aHdSCE)
    nTpContr := 1
    nX := 1
    oView := FWViewActive()
    lIsViewActv := oView <> Nil .And. oView:IsActive()

    //-- Processar a geração de contratos
    If Len(aDados) > 0
        If lRet
            If Len(aDados) > 1
                If lIsViewActv
                    nTpContr := Aviso(STR0068, STR0069, {STR0070, STR0071}) //-- "Tipo do Contrato" "Será gerado um contrato em Conjunto(todos os fornecedores) ou Individual(um por fornecedor)?" "Conjunto" "Individual"
                EndIf
            EndIf
            Begin Transaction
                If nTpContr == 1 //-- Um unico contrato, com N planilhas
                    If !ExecCtrMdl(aDados, aHdSCE, oSC8Detail, oSCEDetail, oSCEQry)
                        lRet := .F.					
                        DisarmTransaction()
                    EndIf
                Else
                    For nX := 1 To Len(aDados) //-- Um contrato por fornecedor
                        If !ExecCtrMdl({aDados[nX]}, aHdSCE, oSC8Detail, oSCEDetail, oSCEQry)
                            lRet := .F.			
                            DisarmTransaction()
                            Exit
                        EndIf
                    Next				
                EndIf
            End Transaction
        EndIf
    Else
        Help("", 1, "A162CNTR",, STR0067, 1, 0) //-- "A162CNTR" - "Não há vencedores selecionados nesta análise!"
        lRet:= .F.
    EndIf		

    RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} A162Ordena()
Função para geração de Contrato a partir do Mapa de Cotação
@Param aWinners Array com resultado das cotações para a geração do 
		contrato
@author leonardo.magalhaes
@since 09/10/2020
@version 1.0
@return lRet
/*/
//-------------------------------------------------------------------
Function A162Ordena(aWin as Array, aHdSCE as Array) as Array

    Local aAux	as Array
    Local aRet  as Array
    Local aDados as Array
    Local nPosQuant	as Numeric
    Local nPosForn as Numeric
    Local nPosLoj as Numeric
    Local cFornCor as Char	 
    Local cLojaCor as Char
    Local nX as Numeric 
    Local nY as Numeric

    Default aWin := {}
    Default aHdSCE := {}

    //-- Inicializar as variáveis
    aAux :=	{}
    aRet :=	{}
    aDados := {}
    nPosQuant := 0
    nPosForn := 0
    nPosLoj	:= 0
    nPosQuant := AScan(aHdSCE, {|x| x[2] == "CE_QUANT"})
    nPosForn := AScan(aHdSCE, {|x| x[2] == "CE_FORNECE"})
    nPosLoj := AScan(aHdSCE, {|x| x[2] == "CE_LOJA"})
    cFornCor := ""	 
    cLojaCor := ""
    nX := 0
    nY := 0

    //-- Buscar os Fornecedores vencedores da cotação
    If nPosQuant > 0
        For nX := 1 To Len(aWin)
            For nY := 1 To Len(aWin[nX])
                If aWin[nX][nY][nPosQuant] > 0
                    AADD(aAux, aWin[nX][nY])
                EndIf
            Next nY	
        Next nX
    EndIf

    If Len(aAux) > 0
        //-- Agrupar vencedores por fornecedor 
        For nX := 1 To Len(aAux)
            
            cFornCor := aAux[nX][nPosForn]		
            cLojaCor := aAux[nX][nPosLoj]

            If AScan(aRet, {|x| x[1] + x[2] == cFornCor + cLojaCor }) == 0
                AAdd(aDados, cFornCor)
                AAdd(aDados, cLojaCor)
                
                For nY :=1 To Len(aAux)
                    If cFornCor == aAux[nY][nPosForn] .And. cLojaCor == aAux[nY][nPosLoj]
                        AAdd(aDados, aAux[nY])
                    EndIf 
                Next nY

                AAdd(aRet, aDados)
                aDados := {}
            EndIf
        Next nX
    EndIf
	
Return aRet

/*/{Protheus.doc} ExecCtrMdl
	Carrega o modelo do CNTA300, seta a operacao como inclusao, o ativa e preenche com os dados informados
em <aContrato> atraves da funcao <A161MdlCot>. Caso <aContrato> contenha dados invalidos, exibe alerta.
@author leonardo.magalhaes
@since 09/10/2020
@return lResult, boolean, verdadeiro se gravado com sucesso.
@param aContrato, array, contem o registro esperado pela funcao <A162MdlCot> 
/*/
Static Function ExecCtrMdl(aContrato as Array, aHdSCE as Array, oSC8Detail as Object, oSCEDetail as Object, oSCEQry as Object) as Logical
	
    Local lRet as Logical
	Local nGravou as Numeric
	Local cErrMsg as Char
    Local cFilDHU as Char
	Local oModel300 as Object

    Default aContrato := {}
    Default aHdSCE := {}

    //-- Inicializar as variáveis
    lRet := .F.
	nGravou := 0
	cErrMsg := ""
	oModel300 := FWLoadModel("CNTA300")
    cFilDHU := xFilial("DHU")

	oModel300:SetOperation(MODEL_OPERATION_INSERT)                                 
	oModel300:Activate()
	oModel300 := A162MdlCot(oModel300, aContrato, aHdSCE)

	If !oModel300:HasErrorMessage()
		nGravou := FWExecView (STR0066, "CNTA300", MODEL_OPERATION_INSERT ,, {||.T.},,,,,,, oModel300) //-- "Incluir"
		If nGravou == 0
            A162AtSC8(aContrato, CN9->CN9_NUMERO, aHdSCE, oSC8Detail, oSCEDetail, oSCEQry)
            cRetSitCot := A162RtHdSt(cFilDHU, CN9->CN9_NUMCOT)
            If !Empty(cRetSitCot)
                DbSelectArea("DHU")
                DbSetOrder(1) //-- DHU_FILIAL + DHU_NUM
                If MsSeek(cFilDHU + CN9->CN9_NUMCOT)
                    RecLock("DHU", .F., .T.)
                        DHU->DHU_STATUS := cRetSitCot
                    MsUnlock()
                EndIf
            EndIf
        EndIf
	Else
		nGravou := 1		
		cErrMsg := oModel300:GetErrorMessage()[5] + "["+ oModel300:GetErrorMessage()[4] + "] - " + oModel300:GetErrorMessage()[6]
		Help("", 1, STR0057,, cErrMsg, 1, 0)
	EndIf

	oModel300:DeActivate()
	oModel300 := Nil
	
	lRet := (nGravou == 0)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} A162MdlCot()
Função para geração de Contrato a partir do Mapa de Cotação
@Param oModel300, Object, Objeto da CNTA300
@Param aDados, Array, Array com resultado das cotações para a geração do contrato
@author leonardo.magalhaes
@since 09/10/2020
@version 1.0
@return lRet, Boolean, True se o objeto foi populado sem erros
/*/
//-------------------------------------------------------------------
Function A162MdlCot(oModel300 as Object, aDados as Array, aHdSCE as Array) as Object

    Local aArea		as Array
    Local aAreaSC1 	as Array
    Local aServ		as Array

    Local cItem		 as Char
    Local cItPla	 as Char
    Local cTpPla	 as Char
    Local cItemRat	 as Char
    Local cCpEntAdic as Char
    Local cSeekCNZ	 as Char

    Local lRateio	 as Logical
    Local lItem 	 as Logical
    Local lAddPlaSv  as Logical

    Local nPosNumCot as Numeric
    Local nPosForn   as Numeric
    Local nPosLoj	 as Numeric
    Local nPosItCot  as Numeric
    Local nPosNPro   as Numeric
    Local nPosQuant  as Numeric
    Local nQtEntAdic as Numeric
    Local nI 		 as Numeric
    Local nX		 as Numeric
    Local nY		 as Numeric
    Local nW		 as Numeric

    Local oCN9Master as Object
    Local oCNADetail as Object
    Local oCNBDetail as Object
    Local oCNCDetail as Object
    Local oCNZDetail as Object

    Default oModel300 := Nil
    Default aDados := {}
    Default aHdSCE := {}

    aArea := GetArea( )
    aAreaSC1 := SC1->( GetArea( ) )
    aServ := {}

    cItem := Replicate("0", (TamSx3('CNB_ITEM')[1]))
    cItPla := Replicate("0",(TamSx3('CNA_NUMERO')[1]))
    cTpPla := SuperGetMV("MV_TPPLA", .T., "")
    cItemRat := ""
    cCpEntAdic := ""
    cSeekCNZ := ""

    lRateio := .F.
    lItem := .F.
    lAddPlaSv := .F.

    nPosNumCot := AScan(aHdSCE, {|x| x[2] == "CE_NUMCOT"})
    nPosForn := AScan(aHdSCE, {|x| x[2] == "CE_FORNECE"})
    nPosLoj := AScan(aHdSCE, {|x| x[2] == "CE_LOJA"})
    nPosItCot := AScan(aHdSCE, {|x| x[2] == "CE_ITEMCOT"})
    nPosNPro := AScan(aHdSCE, {|x| x[2] == "CE_NUMPRO"})
    nPosQuant := AScan(aHdSCE, {|x| x[2] == "CE_QUANT"})
    nQtEntAdic := 0
    nI := 0
    nX := 0
    nY := 0
    nW := 0

    oCN9Master := oModel300:GetModel('CN9MASTER')
    oCNADetail := oModel300:GetModel('CNADETAIL')
    oCNBDetail := oModel300:GetModel('CNBDETAIL')
    oCNCDetail := oModel300:GetModel('CNCDETAIL')
    oCNZDetail := oModel300:GetModel('CNZDETAIL')

    //-- Popular o modelo do contrato
    oCN9Master:SetValue('CN9_ESPCTR',"1")//Contrato de Compra
    oCN9Master:SetValue('CN9_DTINIC',dDataBase)
    oCN9Master:SetValue('CN9_UNVIGE',"4")//Ideterminada
    oCN9Master:SetValue('CN9_NUMCOT',SC8->C8_NUM)
    cItPla	:= soma1(cItPla)

    //-- Verificar se há entidades contábeis adicionais criadas no ambiente
    nQtEntAdic := CtbQtdEntd()

    For nX := 1 To Len(aDados)
        
        cItem	:= Replicate("0", (TamSx3('CNB_ITEM')[1]))
        cItem	:= soma1(cItem)
        
        If nX > 1
            CNTA300BlMd(oCNADetail, .F.)
            oCNCDetail:AddLine()
            oCNADetail:AddLine()
            cItPla	:= soma1(cItPla)
        Endif
        
        oCNCDetail:SetValue('CNC_CODIGO',aDados[nX][1])
        oCNCDetail:SetValue('CNC_LOJA',aDados[nX][2])
        oCNADetail:SetValue('CNA_FORNEC',aDados[nX][1])
        oCNADetail:SetValue('CNA_LJFORN',aDados[nX][2])
        oCNADetail:SetValue('CNA_TIPPLA',cTpPla)
        oCNADetail:SetValue('CNA_NUMERO',cItPla)

        lItem := .F.

        For nY:=3 To Len(aDados[nX])
        
            SC1->(dbSetOrder(1))
            SC8->(dbSetOrder(1))//C8_NUM+CO_FORNECE+C8_LOJA+C8_ITEM+C8_NUMPRO+C8_ITEMGRD
            SC8->(DbSeek(xFilial('SC8')+aDados[nX][nY][nPosNumCot]+aDados[nX][nY][nPosForn]+aDados[nX][nY][nPosLoj]+aDados[nX][nY][nPosItCot]+aDados[nX][nY][nPosNPro]))		    
        
            IF Posicione("SB5",1,xFilial("SB5")+ SC8->C8_PRODUTO,"B5_TIPO") <> '2'
                lItem := .T.
                If !Empty( oCNBDetail:GetValue('CNB_PRODUT') )
                    CNTA300BlMd(oCNBDetail, .F.)
                    oCNBDetail:AddLine()
                    cItem	:= Soma1(cItem)
                EndIf		
            
                oCNBDetail:SetValue('CNB_ITEM',cItem)
                oCNBDetail:SetValue('CNB_PRODUT',SC8->C8_PRODUTO)
                oCNBDetail:SetValue('CNB_QUANT',aDados[nX][nY][nPosQuant])
                oCNBDetail:SetValue('CNB_NUMSC',SC8->C8_NUMSC)
                oCNBDetail:SetValue('CNB_ITEMSC',SC8->C8_ITEMSC)
                oCNBDetail:SetValue('CNB_VLUNIT',SC8->C8_PRECO)
                oCNBDetail:SetValue('CNB_VLTOTR',SC8->C8_TOTAL)
                oCNBDetail:SetValue('CNB_IDENT',SC8->C8_IDENT)
                oCNBDetail:SetValue('CNB_DESC',((SC8->C8_VLDESC/SC8->C8_TOTAL)*100))

                //-- Verificar se possui rateio
                SCX->(DbSetOrder(1))
                lRateio := SCX->(dbSeek(cSeekCNZ := xFilial("SCX")+SC8->(C8_NUMSC+C8_ITEMSC)))
            
                If lRateio
                    cItemRat := Replicate("0", (TamSx3('CNZ_ITEM')[1]))
                    While SCX->(!Eof()) .And. SCX->(CX_FILIAL+CX_SOLICIT+CX_ITEMSOL) == cSeekCNZ 
                        If cItemRat <> Replicate("0", (TamSx3('CNZ_ITEM')[1]))
                            oCNZDetail:AddLine()		
                        EndIf
                        cItemRat := Soma1(cItemRat)
                                
                        oCNZDetail:SetValue('CNZ_ITEM',cItemRat)
                        oCNZDetail:SetValue('CNZ_PERC',SCX->CX_PERC)
                        oCNZDetail:SetValue('CNZ_CC',SCX->CX_CC)
                        oCNZDetail:SetValue('CNZ_CONTA',SCX->CX_CONTA)
                        oCNZDetail:SetValue('CNZ_ITEMCT',SCX->CX_ITEMCTA)
                        oCNZDetail:SetValue('CNZ_CLVL',SCX->CX_CLVL)
                        
                        //-- Se tem entidades contábeis adicionais criadas (por padrão, já existem 4 entidades no Protheus), então informa as mesmas para o contrato 
                        If nQtEntAdic > 4
                            For nI := 5 To nQtEntAdic
                                cCpEntAdic := "EC" + StrZero( nI, 2 ) + "DB"
                                oCNZDetail:SetValue( ( "CNZ_" + cCpEntAdic ), &( "SCX->CX_" + cCpEntAdic ) )
                                
                                cCpEntAdic := "EC" + StrZero( nI, 2 ) + "CR"
                                oCNZDetail:SetValue( ( "CNZ_" + cCpEntAdic ), &( "SCX->CX_" + cCpEntAdic ) )
                            Next nI
                        EndIf
                        
                        SCX->(dbSkip())			
                    EndDo			
                Else

                    SC1->(dbSeek(xFilial("SC1")+SC8->(C8_NUMSC+C8_ITEMSC)))
                    oCNBDetail:SetValue('CNB_CC',SC1->C1_CC)
                    oCNBDetail:SetValue('CNB_CLVL',SC1->C1_CLVL)
                    oCNBDetail:SetValue('CNB_CONTA',SC1->C1_CONTA)
                    oCNBDetail:SetValue('CNB_ITEMCT',SC1->C1_ITEMCTA)
                    
                    //-- Se tem entidades contábeis adicionais criadas (por padrão, já existem 4 entidades no Protheus), então informa as mesmas para o contrato 
                    If nQtEntAdic > 4
                        For nI := 5 To nQtEntAdic
                            cCpEntAdic := "EC" + StrZero( nI, 2 ) + "DB"
                            oCNBDetail:SetValue( ( "CNB_" + cCpEntAdic ), &( "SC1->C1_" + cCpEntAdic ) )
                            
                            cCpEntAdic := "EC" + StrZero( nI, 2 ) + "CR"
                            oCNBDetail:SetValue( ( "CNB_" + cCpEntAdic ), &( "SC1->C1_" + cCpEntAdic ) )
                        Next nI
                    EndIf
                    
                EndIf	
            Else
                aAdd(aServ,{SC8->C8_PRODUTO,;
                aDados[nX][nY][nPosQuant],;
                SC8->C8_NUMSC,;
                SC8->C8_ITEMSC,;
                SC8->C8_PRECO,;
                SC8->C8_TOTAL,;
                SC8->C8_IDENT,;
                ((SC8->C8_VLDESC/SC8->C8_TOTAL)*100)})	
            EndIf
                        
        Next nY
        
        If !Empty(aServ)
            If lItem		
                cItPla := Soma1(cItPla)
            EndIf
            If Len(aDados[nX]) > 3
                For nY := 1 To oCNADetail:Length()
                    oCNADetail:GoLine(nY)
                    For nW := 1 To oCNBDetail:Length()
                        oCNBDetail:GoLine(nW)
                        If !(oCNBDetail:IsEmpty())
                            CNTA300BlMd(oCNADetail, .F.)
                            oCNADetail:AddLine()	
                            oCNADetail:GoLine(oCNADetail:GetLine())
                            lAddPlaSv := .T.
                            Exit
                        EndIf
                    Next nW
                    If lAddPlaSv
                        Exit
                    EndIf
                Next nY
            EndIf
            oCNADetail:SetValue('CNA_FORNEC',aDados[nX][1])
            oCNADetail:SetValue('CNA_LJFORN',aDados[nX][2])
            oCNADetail:SetValue('CNA_TIPPLA',cTpPla)
            oCNADetail:SetValue('CNA_NUMERO',cItPla)
            cItem:= Soma1(Replicate("0", (TamSx3('CNB_ITEM')[1])))
            For nY := 1 to Len(aServ)
                If nY > 1
                    CNTA300BlMd(oCNBDetail, .F.)
                    oCNBDetail:AddLine()
                    cItem	:= soma1(cItem)
                Endif
                
                oCNBDetail:SetValue('CNB_ITEM',cItem)
                oCNBDetail:SetValue('CNB_PRODUT',aServ[nY][1])			
                oCNBDetail:SetValue('CNB_QUANT',aServ[nY][2])
                oCNBDetail:SetValue('CNB_NUMSC',aServ[nY][3])
                oCNBDetail:SetValue('CNB_ITEMSC',aServ[nY][4])
                oCNBDetail:SetValue('CNB_VLUNIT',aServ[nY][5])
                oCNBDetail:SetValue('CNB_VLTOTR',aServ[nY][6])
                oCNBDetail:SetValue('CNB_IDENT',aServ[nY][7])
                oCNBDetail:SetValue('CNB_DESC',aServ[nY][8])
                
                SCX->(DbSetOrder(1)) //CX_FILIAL+CX_SOLICIT+CX_ITEMSOL+CX_ITEM
                lRateio := SCX->(dbSeek(cSeekCNZ := xFilial("SCX")+aServ[nY][3]+aServ[nY][4]))
            
                If lRateio
                    cItemRat := Replicate("0", (TamSx3('CNZ_ITEM')[1]))
                    While SCX->(!Eof()) .And. SCX->(CX_FILIAL+CX_SOLICIT+CX_ITEMSOL) == cSeekCNZ 
                        If cItemRat <> Replicate("0", (TamSx3('CNZ_ITEM')[1]))
                            oCNZDetail:AddLine()		
                        EndIf
                        cItemRat := Soma1(cItemRat)
                                
                        oCNZDetail:SetValue('CNZ_ITEM',cItemRat)
                        oCNZDetail:SetValue('CNZ_PERC',SCX->CX_PERC)
                        oCNZDetail:SetValue('CNZ_CC',SCX->CX_CC)		
                        oCNZDetail:SetValue('CNZ_CONTA',SCX->CX_CONTA)
                        oCNZDetail:SetValue('CNZ_ITEMCT',SCX->CX_ITEMCTA)
                        oCNZDetail:SetValue('CNZ_CLVL',SCX->CX_CLVL)
                        
                        //-- Se tem entidades contábeis adicionais criadas (por padrão, já existem 4 entidades no Protheus), então informa as mesmas para o contrato 
                        If nQtEntAdic > 4
                            For nI := 5 To nQtEntAdic
                                cCpEntAdic := "EC" + StrZero( nI, 2 ) + "DB"
                                oCNZDetail:SetValue( ( "CNZ_" + cCpEntAdic ), &( "SCX->CX_" + cCpEntAdic ) )
                                
                                cCpEntAdic := "EC" + StrZero( nI, 2 ) + "CR"
                                oCNZDetail:SetValue( ( "CNZ_" + cCpEntAdic ), &( "SCX->CX_" + cCpEntAdic ) )
                            Next nI
                        EndIf
                        
                        SCX->(dbSkip())
                    EndDo			
                Else
                
                    SC1->(dbSeek(xFilial("SC1")+aServ[nY][3]+aServ[nY][4]))
                    oCNBDetail:SetValue('CNB_CC',SC1->C1_CC)
                    oCNBDetail:SetValue('CNB_CLVL',SC1->C1_CLVL)		
                    oCNBDetail:SetValue('CNB_CONTA',SC1->C1_CONTA)
                    oCNBDetail:SetValue('CNB_ITEMCT',SC1->C1_ITEMCTA)
                    
                    //-- Se tem entidades contábeis adicionais criadas (por padrão, já existem 4 entidades no Protheus), então informa as mesmas para o contrato 
                    If nQtEntAdic > 4
                        For nI := 5 To nQtEntAdic
                            cCpEntAdic := "EC" + StrZero( nI, 2 ) + "DB"
                            oCNBDetail:SetValue( ( "CNB_" + cCpEntAdic ), &( "SC1->C1_" + cCpEntAdic ) )
                            
                            cCpEntAdic := "EC" + StrZero( nI, 2 ) + "CR"
                            oCNBDetail:SetValue( ( "CNB_" + cCpEntAdic ), &( "SC1->C1_" + cCpEntAdic ) )
                        Next nI
                    EndIf
                                                                                                                                        
                EndIf	
            Next nY
            aServ:={}
        EndIf
        
    Next nX

    oCNADetail:GoLine(1)
    oCNBDetail:GoLine(1) 
    oCNCDetail:GoLine(1) 
    oCNZDetail:GoLine(1) 

    If ExistFunc('CN300BlqCot')
        CN300BlqCot(oModel300)
    Else
        CNTA300BlMd(oModel300:GetModel('CNBDETAIL'),.T.)
        CNTA300BlMd(oModel300:GetModel('CNZDETAIL'),.T.)
        CNTA300BlMd(oModel300:GetModel('CNCDETAIL'),.T.)
        CNTA300BlMd(oModel300:GetModel('CNADETAIL'),.T.,.T.)
    EndIf

    RestArea(aAreaSC1)	
    RestArea(aArea)

Return oModel300

//-------------------------------------------------------------------
/*/{Protheus.doc} A162AtSC8()
Função para atualização da cotação após geração do contrato
@Param aDados, Array, Vetor com o resultado das cotações para a geração do contrato
@author leonardo.magalhaes
@since 09/10/2020
@version 1.0
@return lRet
/*/
//-------------------------------------------------------------------
Function A162AtSC8(aDados as Array, cContrato as Char, aHdSCE as Array, oSC8Detail as Object, oSCEDetail as Object, oSCEQry as Object)
	
    Local aArea 	 as Array
	Local aAreaSC8	 as Array
    Local aAreaSCE   as Array
	
	Local cChavSC8 	 as Char
    Local cFilSCE    as Char
	
	Local lPrjCni	 as Logical
	
	Local nX 		 as Numeric
	Local nY 		 as Numeric
	Local nPosRec	 as Numeric

    Local oDHVDetail as Object

    Default aDados := {}
    Default cContrato := ""
    Default aHdSCE := {}
	
    //-- Inicializar as variáveis
    aArea := GetArea()
	aAreaSC8 := SC8->(GetArea())
    aAreaSCE := SCE->(GetArea())
	
	cChavSC8 := ""
    cFilSCE := xFilial("SCE")
	
	lPrjCni := Iif(FindFunction("ValidaCNI"), ValidaCNI(), .F.)
	
	nX := 0
	nY := 0
	nPosRec := aScan(aHdSCE, {|x| x[2] == "CE_REC_WT"})

    oDHVDetail := oSC8Detail:GetModel():GetModel("DHVDETAIL")

	For nX := 1 To Len(aDados)
		For nY := 3 To Len(aDados[nX])
			//-- Posicionar no registro vencedor
			SC8->(DbGoTo(aDados[nX][nY][nPosRec]))
			
			cChavSC8 := SC8->C8_FILIAL + SC8->C8_NUM + SC8->C8_IDENT
			
			//-- Gravar C8_NUMCON para registro vencedor e inibe utilização de C8_NUMPED
			RecLock("SC8",.F.)
				SC8->C8_NUMCON := cContrato
				SC8->C8_NUMPED := Replicate("X", Len(SC8->C8_NUMPED))
                SC8->C8_ITEMPED := Replicate("X", Len(SC8->C8_ITEMPED))
			SC8->(MsUnlock())

            If oDHVDetail:SeekLine({{"DHV_ITEM", SC8->C8_IDENT}}, .F., .T.)
                If oSC8Detail:SeekLine({{"C8_FORNECE", SC8->C8_FORNECE}, {"C8_FORNECE", SC8->C8_FORNECE}, {"C8_LOJA", SC8->C8_LOJA}, {"C8_NUMPRO", SC8->C8_NUMPRO}, {"C8_PRODUTO", SC8->C8_PRODUTO}, {"C8_IDENT", SC8->C8_IDENT}}, .F., .T.)
                    //-- Gravar referencias na SCE
                    SCE->(DbSetOrder(2)) //-- CE_FILIAL+CE_NUMCOT+CE_ITEMCOT+CE_PRODUTO+CE_ITEMGRD+CE_FORNECE+CE_LOJA+CE_NUMPRO+CE_IDENT+CE_SEQ
                    If SCE->(MsSeek(cFilSCE + SC8->C8_NUM + SC8->C8_ITEM + SC8->C8_PRODUTO + SC8->C8_ITEMGRD + SC8->C8_FORNECE + SC8->C8_LOJA + SC8->C8_NUMPRO + SC8->C8_IDENT + A162GetSeq(2, oSC8Detail, oSCEDetail, oSCEQry, .F.)))
                        RecLock("SCE", .F.)
                            SCE->CE_NUMPED := SC8->C8_NUMPED
                            SCE->CE_ITEMPED := SC8->C8_ITEMPED
                            SCE->CE_NUMCTR := SC8->C8_NUMCON
                        SCE->(MsUnlock())
                    EndIf
                EndIf

                DHV->(DbGoTo(oDHVDetail:GetDataId()))
                If DHV->DHV_SALDO > 0 .And. DHV->DHV_SALDO < DHV->DHV_QUANT
                    RecLock("DHV", .F.)
                        DHV->DHV_STATUS := "2" //-- Item de cotação parcialmente analisado
                    DHV->(MsUnlock())
                ElseIf DHV->DHV_SALDO == 0
                    RecLock("DHV", .F.)
                        DHV->DHV_STATUS := "3" //-- Item de cotação totalmente analisado
                    DHV->(MsUnlock())
                EndIf
            EndIf
			
            //-- Gerar log de inclusao de contrato via analise de cotacao
			If lPrjCni				
				RSTSCLOG("CTR", 4)
			EndIf

			//-- Percorrer os demais registros da chave (não vencedores) e inibir a utilização de C8_NUMCON e C8_NUMPED
			SC8->(DbSetOrder(4)) //-- C8_FILIAL+C8_NUM+C8_IDENT+C8_PRODUTO
			If SC8->(MsSeek(cChavSC8, .T.))
				While SC8->(!Eof()) .And. (SC8->C8_FILIAL + SC8->C8_NUM + SC8->C8_IDENT == cChavSC8)
					If Empty(SC8->C8_NUMCON) .And. Empty(SC8->C8_NUMPED)
						RecLock("SC8",.F.)
							SC8->C8_NUMCON := Replicate("X", Len(SC8->C8_NUMCON))
							SC8->C8_NUMPED := Replicate("X", Len(SC8->C8_NUMPED))
                            SC8->C8_ITEMPED := Replicate("X", Len(SC8->C8_ITEMPED))
						SC8->(MsUnlock())	
					EndIf
					SC8->(DbSkip())
				EndDo
			EndIf
		Next nY
	Next nX
	
    //-- Restaurar areas
    SCE->(RestArea(aAreaSCE))
	SC8->(RestArea(aAreaSC8))
	RestArea(aArea)

	//-- Limpar a memória
    ASize(aArea, 0)
    aArea := Nil

    ASize(aAreaSC8, 0)
    aAreaSC8 := Nil

Return Nil


Function A162GdDbCl(oView as Object, cFieldName as Char, nLineGrid as Numeric, nLineModel as Numeric) as Logical

    Local aLeg as Array
    Local nOperat as Numeric
    Local lIsUpsert as Logical
    Local bFieldWhen as Block

    //-- Inicializar as variáveis
    aLeg := {}
    nOperat := oView:GetModel():GetOperation()
    lIsUpsert := nOperat <> MODEL_OPERATION_VIEW .And. nOperat <> MODEL_OPERATION_DELETE
    bFieldWhen := oView:GetModel():GetStruct():GetProperty(cFieldName, MODEL_FIELD_WHEN)

    If cFieldName == "DHV_LEGEND"
        aAdd(aLeg, {"BR_PINK", STR0077}) //-- "Item de cotação a analisar"
        aAdd(aLeg, {"BR_LARANJA", STR0078}) //-- "Item de cotação parcialmente analisado"
        If lIsUpsert
            aAdd(aLeg, {"BR_VIOLETA", STR0079}) //-- "Item de cotação em análise"
        EndIf
        aAdd(aLeg, {"BR_AZUL", STR0080}) //-- "Item de cotação totalmente analisado"
        
        BrwLegenda(STR0083, STR0009, aLeg) //-- "Produtos da Cotação - Legenda" "Produtos"
    ElseIf cFieldName  == "CE_LEGEND"   
        If lIsUpsert
            aAdd(aLeg, {"BR_BRANCO", STR0081}) //-- "Item de proposta de fornecimento a analisar"
        EndIf
        aAdd(aLeg, {"BR_PRETO", STR0082}) //-- "Item de proposta de fornecimento analisado"
        
        BrwLegenda(STR0084, STR0060, aLeg) //-- "Encerramento - Legenda" "Encerramento"
    EndIf

    If lIsUpsert
        lRet := Eval(bFieldWhen)
    Else
        lRet := .F.
    EndIf

    //-- Limpar a memória
    aSize(aLeg, 0)
    aLeg := Nil

Return lRet


/*/{Protheus.doc} A162RtHdSt
	Verifica a tabela DHV para retornar o status da tabela DHU (Nova Análise de Cotação).
    Requer posicionamento da DHU.
@author leonardo.magalhaes
@since 15/01/2021
@return cRet, char, Status da cotação (1 = Cotação Não Analisada, 2 = Cotação Analisada Parcialmente, 3 = Cotação Totalmente Analisada).
/*/
Function A162RtHdSt(cFilCot, cNumCot)

	Local cAliasAux := GetNextAlias()
	Local cRet := ""

    Default cFilCot := xFilial("DHU")
    Default cNumCot := DHU->DHU_NUM

	BeginSQL Alias cAliasAux
		SELECT	(SELECT SUM(DHV_SALDO) FROM %Table:DHV% DHV	 WHERE DHV_FILIAL = DHU.DHU_FILIAL AND DHV_NUM = DHU.DHU_NUM AND DHV.%NotDel%) AS SALDO,
				(SELECT COUNT(DHV_ITEM) FROM %Table:DHV% DHV WHERE DHV_FILIAL = DHU.DHU_FILIAL AND DHV_NUM = DHU.DHU_NUM AND DHV.%NotDel%) AS QTDITEM,
				(SELECT COUNT(DHV_ITEM) FROM %Table:DHV% DHV WHERE DHV_FILIAL = DHU.DHU_FILIAL AND DHV_NUM = DHU.DHU_NUM AND DHV_QUANT = DHV_SALDO AND DHV.%NotDel%) AS QTDFULL			
		FROM 	%Table:DHU% DHU	
		WHERE	DHU_FILIAL 		= %Exp:cFilCot% 
				AND DHU_NUM 	= %Exp:cNumCot%
				AND DHU.%NotDel%
	EndSQL

	If (cAliasAux)->(!Eof())
		If (cAliasAux)->SALDO == 0
			cRet := "3" //-- "Cotação totalmente analisada"
		ElseIf (cAliasAux)->QTDITEM == (cAliasAux)->QTDFULL
			cRet := "1"  //-- "Cotação não analisada"
		Else
			cRet := "2" //-- "Cotação analisada parcialmente"
		EndIf 
	EndIf

	(cAliasAux)->(DbCloseArea())

Return cRet


/*/{Protheus.doc} A162VldQnt
	Função de validação do campo CE_QUANT chamada via dicionário SX3 (X3_VALID).
@author leonardo.magalhaes
@since 15/01/2021
@return lRet, Boolean, Conteúdo recebido para o campo é válido (True) ou inválido (False).
/*/
Function A162VldQnt() as Logical

    Local lRet as Logical

    lRet := .T.

    If FWIsInCallStack("MATA160") .Or. FWIsInCallStack("MATA161")
        lRet := A160Grade() .And. Iif(FWIsInCallStack("MATA161"), A161CalSal(oGetSld, oGetQtd, aHeadAud), .T.)
    EndIf  

Return lRet
