#INCLUDE "MATA162.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "TOPCONN.CH" 

#DEFINE CRLF Chr(13) + Chr(10)


/*/{Protheus.doc} MATA061EVDEF
Eventos padrão da Análise de Cotação.

Documentação sobre eventos do MVC: https://tdn.totvs.com/x/pgoRE

@type classe
 
@author leonardo.magalhaes
@since 30/10/2020
@version 1.0
 
/*/
CLASS MATA162EVDEF FROM FWModelEvent

    DATA aHeadSCE as Array

    DATA nLenHdSCE as Numeric
    DATA nPosCENumPr as Numeric
    DATA nPosCEQnt as Numeric
    DATA nPosCEForn as Numeric
    DATA nPosCELoja as Numeric
    DATA nPosCEMot as Numeric
    DATA nPosCEMtVnc as Numeric
    DATA nPosCEEntr as Numeric
    DATA nPosCEReg as Numeric
    DATA nPosCEItGr as Numeric
    DATA nPosCEItem as Numeric
    DATA nPosCECot as Numeric
    DATA nPosCEAli as Numeric
    DATA nPosCERec as Numeric
	
	METHOD New() CONSTRUCTOR
	
    METHOD ModelPosVld()
    METHOD BeforeTTS()
    METHOD InTTS()
    METHOD AfterTTS()
	
ENDCLASS


/*/{Protheus.doc} New
Construtor da classe.

@type metodo
 
@author leonardo.magalhaes
@since 30/10/2020
@version 1.0
 
/*/
METHOD New() CLASS MATA162EVDEF
    
        //-- Obter aHeader da SCE por compatibilização com a MaAvalCot
        ::aHeadSCE := COMXHDCO("SCE")
                
        //-- Adicionar os campos de Alias e Recno
        ADHeadRec("SCE", ::aHeadSCE)

        //-- Obter tamanho do aHeader
        ::nLenHdSCE := Len(::aHeadSCE)

        //-- Padronizar o X3_CAMPO com AllTrim
        AEval(::aHeadSCE, {|x| x[2] := AllTrim(x[2])})

        //-- Obter posições do Header
        ::nPosCENumPr := AScan(::aHeadSCE, {|x| x[2] == "CE_NUMPRO"})
        ::nPosCEQnt   := AScan(::aHeadSCE, {|x| x[2] == "CE_QUANT"})
        ::nPosCEForn  := AScan(::aHeadSCE, {|x| x[2] == "CE_FORNECE"})
        ::nPosCELoja  := AScan(::aHeadSCE, {|x| x[2] == "CE_LOJA"})
        ::nPosCEMot   := AScan(::aHeadSCE, {|x| x[2] == "CE_MOTIVO"})
        ::nPosCEMtVnc := AScan(::aHeadSCE, {|x| x[2] == "CE_MOTVENC"})
        ::nPosCEEntr  := AScan(::aHeadSCE, {|x| x[2] == "CE_ENTREGA"})
        ::nPosCEReg   := AScan(::aHeadSCE, {|x| x[2] == "CE_REGIST"})
        ::nPosCEItGr  := AScan(::aHeadSCE, {|x| x[2] == "CE_ITEMGRD"})
        ::nPosCEItem  := AScan(::aHeadSCE, {|x| x[2] == "CE_ITEMCOT"})
        ::nPosCECot   := AScan(::aHeadSCE, {|x| x[2] == "CE_NUMCOT"})
        ::nPosCEAli   := AScan(::aHeadSCE, {|x| x[2] == "CE_ALI_WT"})
        ::nPosCERec   := AScan(::aHeadSCE, {|x| x[2] == "CE_REC_WT"})

Return Self


/*/{Protheus.doc} ModelPosVld
Metodo executado uma vez no contexto de validação do modelo principal.

@type metodo
 
@author leonardo.magalhaes
@since 04/01/2021
@version 1.0
 
/*/
METHOD ModelPosVld(oModel, cModelId) CLASS MATA162EVDEF

    Local lRet as Logical

    Local oDHUMaster as Object
    Local oDHVDetail as Object
    Local oSC8Detail as Object
    Local oSCEDetail as Object

    Local cTpDoc as Char
    Local cTpPla as Char

    Local nX as Numeric
    Local nY as Numeric

    Default oModel := FWModelActive() //-- Modelo ativo como default
    Default cModelId := "" //-- Modelo ativo como default

    lRet := .F.

    If oModel <> Nil .And. oModel:GetId() == "MATA162"

        //-- Inicializar as variáveis
        oDHUMaster := oModel:GetModel("DHUMASTER")
        oDHVDetail := oModel:GetModel("DHVDETAIL")
        oSC8Detail := oModel:GetModel("SC8DETAIL")
        oSCEDetail := oModel:GetModel("SCEDETAIL")
        lRet := .T.
        cTpDoc := oDHUMaster:GetValue("DHU_TPDOC")
        cTpPla := SuperGetMV("MV_TPPLA", .T., "")

        //-- Avaliar a existencia de ao menos uma linha marcada como proposta vencedora
        If !oSC8Detail:SeekLine({{"C8_MARKW", .T.}}, .F., .F.)
            //-- Alertar nenhum vencedor
            Help(,, "A162NOMARK",, STR0051, 4,1,,,,,, {STR0052}) //-- "Nenhuma proposta de fornecimento foi marcada como vencedora!" "Marque ao menos uma proposta de fornecimento para ao menos um produto!"
            lRet := .F.
        EndIf

        If lRet
            lRet := .F.
            For nX := 1 To oDHVDetail:Length()
                oDHVDetail:GoLine(nX)
                For nY := 1 To oSCEDetail:Length()
                    oSCEDetail:GoLine(nY)
                    If !oSCEDetail:IsDeleted()
                        If oSCEDetail:GetValue("CE_QUANT") > 0
                            lRet := .T.
                            Exit
                        EndIf
                    EndIf
                Next nY
                If lRet
                    Exit
                EndIf
            Next nX
            If !lRet
                Help(,, "A162NOQUANT",, STR0075, 4,1,,,,,, {STR0076}) //-- "Não existem quantidades válidas para as propostas marcadas como vencedoras!" "Distribua ao menos uma quantidade para uma proposta vencedora!"
            EndIf
        EndIf

        If lRet .And. cTpDoc == "2" //-- Para contratos, deve-se validar o tipo de planilha
            CNL->(DbSetOrder(1))
            If Empty(cTpPla)
                Help("", 1, "MV_TPPLA",, STR0073, 4, 1)	//-- "Parâmetro não Preenchido. É necessário preencher o parâmetro MV_TPPLA com um Tipo de Planilha válido para a geração dos contratos"
                lRet	:= .F.
            ElseIf CNL->(!DbSeek(xFilial("CNL") + cTpPla))
                Help("", 1, "A162VLDPLAN",, STR0072, 4, 1) //-- "É necessário preencher o parâmetro MV_TPPLA com um Tipo de Planilha válido para a geração dos contratos"
                lRet	:= .F.
            Else
                lRet := CNVldPlFixa(cTpPla) //-- Validar o tipo de planilha (necessariamente precisa ser Fixa)
            EndIf
        EndIf

    EndIf

Return lRet

/*/{Protheus.doc} BeforeTTS
Metodo executado uma vez no contexto de gravação do modelo principal e antes da transação.

@type metodo
 
@author leonardo.magalhaes
@since 30/10/2020
@version 1.0
 
/*/
METHOD BeforeTTS(oModel) CLASS MATA162EVDEF

    Local oDHUMaster as Object
    Local oDHVDetail as Object
    Local oSC8Detail as Object
    Local oSCEDetail as Object

    Local cTpDoc as Char

    Local aSaveLines as Array

    Local nX as Numeric
    Local nY as Numeric

    If oModel <> Nil .And. oModel:GetId() == "MATA162"
        
        //-- Inicializar as variáveis
        oDHUMaster := oModel:GetModel("DHUMASTER")
        oDHVDetail := oModel:GetModel("DHVDETAIL")
        oSC8Detail := oModel:GetModel("SC8DETAIL")
        oSCEDetail := oModel:GetModel("SCEDETAIL")
        
        aSaveLines := FWSaveRows()
        
        cTpDoc := oDHUMaster:GetValue("DHU_TPDOC")

        //-- Percorrer o grid de itens de produtos para ajustes antes da gravação
        For nX := 1 To oDHVDetail:Length()
            oDHVDetail:GoLine(nX)
            If !oDHVDetail:IsDeleted()
                //-- Deletar do grid da SCE (Histórico da Cotação) as linhas com quantidade zerada
                For nY := 1 To oSCEDetail:Length()
                    oSCEDetail:GoLine(nY)
                    If !oSCEDetail:IsDeleted() .And. oSCEDetail:IsInserted() .And. oSCEDetail:GetValue("CE_QUANT") == 0
                        oSCEDetail:DeleteLine()
                    EndIf
                Next nY

                //-- Setar para C8_TPDOC o conteudo de DHU_TPDOC
                For nY := 1 To oSC8Detail:Length()
                    oSC8Detail:GoLine(nY)
                    If !oSC8Detail:IsDeleted()
                        oSC8Detail:LoadValue("C8_TPDOC", cTpDoc)
                    EndIf
                Next nY
            EndIf
        Next nX

        FWRestRows(aSaveLines)

    EndIf
    
Return Nil


/*/{Protheus.doc} InTTS
Metodo executado uma vez no contexto de gravação do modelo principal e durante a transação.

@type metodo
 
@author leonardo.magalhaes
@since 30/10/2020
@version 1.0
 
/*/
METHOD InTTS(oModel) CLASS MATA162EVDEF

    Local oDHUMaster as Object
    Local oDHVDetail as Object
    Local oSC8Detail as Object
    Local oSCEDetail as Object
    Local oView as Object

    Local aSaveLines as Array
    Local aSeekLine as Array
    Local aSC8 as Array
    Local aItem as Array
    Local aDocs as Array
    Local aAreaSC8 as Array

    Local cFilDHU as Char
    Local cFilSC8 as Char
    Local cFilSCE as Char
    Local cRefer as Char
    Local cPedNbr as Char
    Local cUpdMsg as Char
    Local cRetSitCot as Char

    Local nX as Numeric
    Local nY as Numeric
    Local nIProp as Numeric
    Local nItem as Numeric
    Local nWin as Numeric
    Local nSaveSX8 as Numeric

    Local lNecessid as Logical
    Local lCtrOk as Logical
    Local lMt162Cnt as Logical
    Local lCntEsp as Logical
    Local lIsViewActv as Logical

    Private aColsSCE as Array
    
    Default oModel := FWModelActive()

    If oModel <> Nil .And. oModel:GetId() == "MATA162"

        //-- Inicializar as variáveis
        oDHUMaster := oModel:GetModel("DHUMASTER")
        oDHVDetail := oModel:GetModel("DHVDETAIL")
        oSC8Detail := oModel:GetModel("SC8DETAIL")
        oSCEDetail := oModel:GetModel("SCEDETAIL")
        oSCEQry := oModel:GetModel("SCEQRY")
        oView := FWViewActive()

        aItem := {}
        aSC8 := {}
        aColsSCE := {}
        aSaveLines := FWSaveRows()
        aSeekLine := {}
        aDocs := {}
        aAreaSC8 := SC8->(GetArea())

        cRefer := ""
        cFilSC8 := xFilial("SC8")
        cPedNbr := ""
        cFilSCE := xFilial("SCE")
        cFilDHU := xFilial("DHU")

        lCtrOk := .T.
        lNecessid := (oDHUMaster:GetValue("DHU_AVENTR") == "2")
        lMT162CNT := ExistBlock("MT162CNT")
        lCntEsp := .F.
        lIsViewActv := oView <> Nil .And. oView:IsActive()

        nX := 0
        nY := 0
        nIProp := 0
        nItem := 0
        nWin := 0
        nSaveSX8 := GetSX8Len()

        //-- Montar o aColsSCE e aSC8 para passagem de parâmetro da MaAvalCot
        For nX := 1 To oDHVDetail:Length()
            oDHVDetail:GoLine(nX)

            AAdd(aSC8, {})
            AAdd(aColsSCE, {})

            nItem := Len(aSC8)
            nWin := Len(aColsSCE)

            For nY := 1 To oSC8Detail:Length()
                oSC8Detail:GoLine(nY)
                SC8->(MsGoTo(oSC8Detail:GetDataId()))

                If !oSC8Detail:IsDeleted()
                    
                    AAdd(aSeekLine, {"CE_FORNECE", oSC8Detail:GetValue("C8_FORNECE")})
                    AAdd(aSeekLine, {"CE_LOJA"   , oSC8Detail:GetValue("C8_LOJA")})
                    AAdd(aSeekLine, {"CE_DESCFOR", oSC8Detail:GetValue("C8_FORNOME")}) 
                    AAdd(aSeekLine, {"CE_NUMPRO" , oSC8Detail:GetValue("C8_NUMPRO")}) 
                    AAdd(aSeekLine, {"CE_ITEMCOT", oSC8Detail:GetValue("C8_ITEM")})
                    AAdd(aSeekLine, {"CE_ITEMGRD", oSC8Detail:GetValue("C8_ITEMGRD")})
                    AAdd(aSeekLine, {"CE_PRODUTO", oSC8Detail:GetValue("C8_PRODUTO")})
                    AAdd(aSeekLine, {"CE_IDENT"  , oSC8Detail:GetValue("C8_IDENT")})

                    cRefer := oSC8Detail:GetValue("C8_PRODUTO")
                    lReferencia := MatGrdPrRf(@cRefer, .T.)

                    If lReferencia 
                        SC8->(DbSetOrder(4))//C8_FILIAL+C8_NUM+C8_IDENT+C8_PRODUTO
                        cSeek := cFilSC8 + SC8->C8_NUM + SC8->C8_IDENT
                        SC8->(DbSeek(cSeek)) 
                    EndIf
                
                    While !lReferencia .Or. (!SC8->(Eof()) .And. SC8->C8_FILIAL + SC8->C8_NUM + SC8->C8_IDENT == cSeek) 
                        
                        AAdd(aSC8[nItem], {})
                        nIProp := Len(aSC8[nItem])

                        AAdd(aSC8[nItem, nIProp], {"C8_ITEM"	, SC8->C8_ITEM })
                        AAdd(aSC8[nItem, nIProp], {"C8_NUMPRO"	, SC8->C8_NUMPRO })
                        AAdd(aSC8[nItem, nIProp], {"C8_PRODUTO"	, SC8->C8_PRODUTO })
                        AAdd(aSC8[nItem, nIProp], {"C8_COND"	, SC8->C8_COND })
                        AAdd(aSC8[nItem, nIProp], {"C8_FORNECE"	, SC8->C8_FORNECE })
                        AAdd(aSC8[nItem, nIProp], {"C8_LOJA"	, SC8->C8_LOJA })
                        AAdd(aSC8[nItem, nIProp], {"C8_NUM"		, SC8->C8_NUM })
                        AAdd(aSC8[nItem, nIProp], {"C8_ITEMGRD"	, SC8->C8_ITEMGRD })
                        AAdd(aSC8[nItem, nIProp], {"C8_NUMSC"	, SC8->C8_NUMSC })
                        AAdd(aSC8[nItem, nIProp], {"C8_ITEMSC"	, SC8->C8_ITEMSC })
                        AAdd(aSC8[nItem, nIProp], {"C8_FILENT"	, SC8->C8_FILENT })			
                        AAdd(aSC8[nItem, nIProp], {"C8_DATPRF"	, SC8->C8_DATPRF })
                        AAdd(aSC8[nItem, nIProp], {"C8_OBS"		, SC8->C8_OBS })
                        AAdd(aSC8[nItem, nIProp], {"SC8RECNO"   , SC8->(Recno()) })
                        
                        aItem := Array(::nLenHdSCE)

                        //-- Montar aCols da SCE para envio a MaAvalCot
                            If ::nPosCENumPr > 0
                                aItem[::nPosCENumPr] := SC8->C8_NUMPRO
                            EndIf

                            If ::nPosCEQnt > 0
                                If oSCEDetail:SeekLine(aSeekLine, .F., .T.)
                                    aItem[::nPosCEQnt] := oSCEDetail:GetValue("CE_QUANT")
                                Else
                                    aItem[::nPosCEQnt] := 0
                                EndIf
                            EndIf

                            If ::nPosCEForn > 0
                                aItem[::nPosCEForn] := SC8->C8_FORNECE
                            EndIf
                            
                            If ::nPosCELoja > 0
                                aItem[::nPosCELoja] := SC8->C8_LOJA
                            EndIf
                            
                            If ::nPosCEMot > 0 
                                aItem[::nPosCEMot] := SC8->C8_MOTIVO
                            EndIf

                            If ::nPosCEMtVnc > 0 
                                aItem[::nPosCEMtVnc] := SC8->C8_MOTVENC
                            EndIf
                            
                            If ::nPosCEEntr > 0
                                If lNecessid
                                    aItem[::nPosCEEntr] := SC8->C8_DATPRF
                                Else
                                    aItem[::nPosCEEntr] := Date() + SC8->C8_PRAZO
                                EndIf
                            EndIf
                            
                            If ::nPosCEReg > 0
                                aItem[::nPosCEReg] := 0
                            EndIf
                            
                            If ::nPosCEItGr > 0
                                aItem[::nPosCEItGr] := SC8->C8_ITEMGRD
                            EndIf

                            If ::nPosCEItem > 0 
                                aItem[::nPosCEItem] := SC8->C8_ITEM
                            EndIf
                            
                            If ::nPosCECot > 0 
                                aItem[::nPosCECot] := SC8->C8_NUM
                            EndIf

                            If ::nPosCEAli > 0
                                aItem[::nPosCEAli] := "SC8"
                            EndIf

                            If ::nPosCERec > 0
                                aItem[::nPosCERec] := SC8->(Recno())				
                            EndIf

                            AAdd(aColsSCE[nWin], aItem)
                        //-- Fim da montagem do aColsSCE[n]

                        If !lReferencia
                            aSeekLine := {}
                            Exit
                        Else
                            SC8->(DbSkip())
                        EndIf							
                    EndDo
                EndIf
            Next nY
        Next nX

        RestArea(aAreaSC8)
        FWRestRows(aSaveLines)

        //-- Gerar: 1 = Pedido de Compras   
        If oDHUMaster:GetValue("DHU_TPDOC") ==  "1"
            //-- Avaliar parâmetros da MaAvalCot
            If Len(aColsSCE) > 0 .And. Len(aSC8) > 0
                //-- Gerar pedidos de compra
                FWMsgRun(, {|| MaAvalCOT("SC8", 4, aSC8, ::aHeadSCE, aColsSCE, lNecessid,, {|| .T.},, aDocs, .T.)}, STR0026, STR0063) //-- "Aguarde" "Gerando os pedidos de compra..."
                
                //-- Executar gatilhos
                EvalTrigger()

                //-- Gravar controle de numeração
                While GetSX8Len() > nSaveSX8
                    ConfirmSx8()		
                EndDo

                //-- Definir mensagem de update
                If Len(aDocs) > 0 .ANd. lIsViewActv
                    For nX := 1 To Len(aDocs)
                        cPedNbr += CRLF + cValToChar(aDocs[nX][2]) + Chr(13) 
                    Next nX

                    cUpdMsg := STR0064 + CRLF + cPedNbr //-- "A cotação gerou os pedidos de compras: "
                    oView:SetUpdateMessage(STR0025, cUpdMsg) //-- "Cotação analisada com sucesso!" 
                EndIf

                aAreaSC8 := SC8->(GetArea())
                aAreaSCE := SCE->(GetArea())
                SCE->(DbSetOrder(2)) //-- CE_FILIAL+CE_NUMCOT+CE_ITEMCOT+CE_PRODUTO+CE_ITEMGRD+CE_FORNECE+CE_LOJA+CE_NUMPRO+CE_IDENT+CE_SEQ
                For nX := 1 To oDHVDetail:Length()
                    oDHVDetail:GoLine(nX)
                    If !oDHVDetail:IsDeleted()
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
                        For nY := 1 To oSC8Detail:Length()
                            oSC8Detail:GoLine(nY)
                            If !oSC8Detail:IsDeleted()
                                If oSCEDetail:SeekLine({{"CE_FORNECE", oSC8Detail:GetValue("C8_FORNECE")}, {"CE_LOJA", oSC8Detail:GetValue("C8_LOJA")}, {"CE_NUMPRO", oSC8Detail:GetValue("C8_NUMPRO")}, {"CE_ITEMCOT", oSC8Detail:GetValue("C8_ITEM")}, {"CE_IDENT", oSC8Detail:GetValue("C8_IDENT")}, {"CE_SEQ", A162GetSeq(2, oSC8Detail, oSCEDetail, oSCEQry, .F.)}}, .T., .T.)
                                    SC8->(DbGoTo(oSC8Detail:GetDataId()))
                                    If SCE->(MsSeek(cFilSCE + SC8->C8_NUM + SC8->C8_ITEM + SC8->C8_PRODUTO + SC8->C8_ITEMGRD + SC8->C8_FORNECE + SC8->C8_LOJA + SC8->C8_NUMPRO + SC8->C8_IDENT + oSCEDetail:GetValue("CE_SEQ")))
                                        RecLock("SCE", .F.)
                                            SCE->CE_NUMPED := SC8->C8_NUMPED
                                            SCE->CE_ITEMPED := SC8->C8_ITEMPED
                                            SCE->CE_NUMCTR := SC8->C8_NUMCON
                                        SCE->(MsUnlock())
                                    EndIf
                                EndIf
                           EndIf
                        Next nY
                    EndIf
                Next nX

                //-- Atualizar status do cabeçalho da cotação (DHU)
                cRetSitCot := A162RtHdSt()
                If !Empty(cRetSitCot)
                    DbSelectArea("DHU")
                    DHU->(DbSetOrder(1)) //-- DHU_FILIAL + DHU_NUM
                    If DHU->(MsSeek(cFilDHU + DHU->DHU_NUM))
                        RecLock("DHU", .F., .T.)
                            DHU->DHU_STATUS := cRetSitCot
                        MsUnlock()
                    EndIf
                EndIf

                RestArea(aAreaSC8)
                RestArea(aAreaSCE)
            Else
                //-- Restaurar controle de numeração
                 While GetSX8Len() > nSaveSX8
                    RollBackSx8()
                EndDo
                //-- Rollback na transação caso a inserção de pedido falhe
                DisarmTransaction()
            EndIf

        //-- Gerar: 2 = Contrato
        ElseIf oDHUMaster:GetValue("DHU_TPDOC") ==  "2"
            //-- Ponto de entrada para geração do contrato via customização 
            If lMT162CNT
                lCntEsp := ExecBlock("MT162CNT",.F.,.F., {aColsSCE, oDHUMaster:GetValue("DHU_NUM")}) 
            EndIf 
                
            If !lCntEsp
                FWMsgRun(, {|| lCtrOk := A162Cntr(aColsSCE, ::aHeadSCE, oSC8Detail, oSCEDetail, oSCEQry)}, STR0026, STR0065) //-- "Aguarde" "Gerando os contratos..."
            EndIf	
                
            If lCtrOk
                //-- Gravar controle de numeração 
                While (GetSX8Len() > nSaveSX8)
                    ConfirmSx8()		
                EndDo
                //-- Definir mensagem de update
                If lIsViewActv
                    oView:SetUpdateMessage(STR0025, STR0074) //-- "Cotação analisada com sucesso!" "Contratos gerados e disponíveis no módulo de Gestão de Contratos!"
                EndIf
            Else
                //-- Restaurar controle de numeração
                While (GetSX8Len() > nSaveSX8)
                    RollBackSx8()
                EndDo
                //-- Rollback na transação caso a inserção do contrato falhe
                DisarmTransaction()
            EndIf
        EndIf
    EndIf

Return Nil


/*/{Protheus.doc} AfterTTS
Metodo executado uma vez no contexto de gravação do modelo principal e após a transação.

@type metodo
 
@author leonardo.magalhaes
@since 30/10/2020
@version 1.0
 
/*/
METHOD AfterTTS(oModel) CLASS MATA162EVDEF

    Local lMT162WF as Logical
    Local lClicB as Logical
    Local oDHUMaster as Object
    Local cNumCot as Char
    Local aAreaSC8 as Array

    If oModel <> Nil .And. oModel:GetId() == "MATA162"

        //-- Inicializar variáveis
        lMT162WF := ExistBlock("MT162WF")
        lClicB := A131VerInt()

        oDHUMaster := oModel:GetModel("DHUMASTER")

        cNumCot := oDHUMaster:GetValue("DHU_NUM")

        aAreaSC8 := SC8->(GetArea())

        //-- Ponto de entrada para Workflow
        If lMT162WF
            SC8->(DbSetOrder(1))
            SC8->(DbSeek(xFilial("SC8") + cNumCot))
            ExecBlock("MT162WF", .F., .F., {cNumCot})
        EndIf

        //-- Integração ClickBusiness
        If lClicB
            A311RegCot(cNumCot, 2)
        EndIf

        RestArea(aAreaSC8)

    EndIf

Return Nil
