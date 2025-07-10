#Include "Protheus.ch"
#Include "ApWizard.ch"
#include "TopConn.ch"
#include "RwMake.ch"
#include "TbIconn.ch" 
#include "FILEIO.CH"
#include "FWEVENTVIEWCONSTS.CH"
#include "WizImp.ch"

#DEFINE _CRLF	Chr(13) + Chr(10) 

Static oTFont := Nil 

/*/{Protheus.doc} WizImp
Wizard para configuração do ambiente TOTVS Colaboração

@author Rodrigo.mpontes
@since 21/10/2013
/*/

Function WizImp()  

Private oOK 	    := LoadBitmap(GetResources(),'NGBIOALERTA_02.png')
Private oNO 	    := LoadBitmap(GetResources(),'NGBIOALERTA_03.png')
Private oYE         := LoadBitmap(GetResources(),'NGBIOALERTA_01.png')
Private oDlg        := Nil
Private oPanelWiz   := Nil
Private oStepWiz    := Nil
Private oNewPag1    := Nil
Private oNewPag2    := Nil
Private oNewPag3    := Nil
Private oNewPag4    := Nil
Private oNewPag5    := Nil
Private oNewPag6    := Nil
Private oNewPag7    := Nil
Private oNewPag8    := Nil
Private oNewPag9    := Nil
Private oBrw1Pg2    := Nil 
Private oBrw1Pg3    := Nil
Private oBrw1Pg4    := Nil
Private oBrw1Pg5    := Nil
Private oBrw1Pg7    := Nil
Private oBrw2Pg7    := Nil
Private oBrw3Pg7    := Nil
Private oBrw1Pg8    := Nil
Private oBrw1Pg9    := Nil
Private oBrw2Pg9    := Nil
Private oG1Pg7      := Nil
Private oG2Pg7      := Nil
Private oMGetPg7    := Nil
Private oG1Pg8      := Nil
Private oG2Pg8      := Nil
Private oMGetPg8    := Nil
Private oGrp1Pg7    := Nil
Private oGrp2Pg7    := Nil
Private oGrp3Pg7    := Nil
Private oGrp1Pg8    := Nil
Private cMsgTab     := ""
Private cMsgPrw     := ""
Private cMsgMV1     := ""
Private cMsgMV2     := ""
Private cMVNGIN     := ""
Private cMVNGLI     := ""
Private cMVPar      := ""
Private xMVCont     := Nil
Private cMVDesc     := ""
Private cGMVNGI     := Space(50)
Private cGMVNGL     := Space(50)
Private aMVGer      := {}
Private aMVNFe      := {}
Private aMVCTe      := {}
Private aMVIxT      := {}
Private aGrp        := {}
Private aFilGrp     := {}

oTFont := TFont():New('Arial',,-16,.T.)

//Para que a tela da classe FWWizardControl fique no layout com bordas arredondadas iremos fazer com que a janela do Dialog oculte as bordas e a barra de titulo
//para isso usaremos os estilos WS_VISIBLE e WS_POPUP
DEFINE DIALOG oDlg TITLE STR0001 PIXEL STYLE nOR(  WS_VISIBLE ,  WS_POPUP ) //'Importador de XML'
    
    oDlg:nWidth := 1150
    oDlg:nHeight := 620

    oPanelWiz:= tPanel():New(0,0,"",oDlg,,,,,,300,150)
    oPanelWiz:Align := CONTROL_ALIGN_ALLCLIENT

    //Instancia a classe FWWizard
    oStepWiz:= FWWizardControl():New(oPanelWiz)
    oStepWiz:ActiveUISteps()

    // Pagina 1
    oNewPag1 := oStepWiz:AddStep("1")
    oNewPag1:SetStepDescription(STR0002) //"Boas Vindas"
    oNewPag1:SetConstruction({|Panel| WizImpPg(Panel,1)})
    oNewPag1:SetNextAction({||.T.})
    oNewPag1:SetCancelAction({|| .T., oDlg:End()})

    //Pagina 2
    oNewPag2 := oStepWiz:AddStep("2")
    oNewPag2:SetStepDescription(STR0003) //"Tabelas e Estrutura"
    oNewPag2:SetConstruction({|Panel| WizImpPg(Panel,2)})
    oNewPag2:SetNextAction({|| WizImpVld(2)})
    oNewPag2:SetCancelAction({|| .T., oDlg:End()})
    oNewPag2:SetPrevAction({|| .T.})
    oNewPag2:SetPrevTitle(STR0004) //"Voltar"

    //Pagina 3
    oNewPag3 := oStepWiz:AddStep("3")
    oNewPag3:SetStepDescription(STR0005) //"Programas / Binário"
    oNewPag3:SetConstruction({|Panel| WizImpPg(Panel,3)})
    oNewPag3:SetNextAction({|| WizImpVld(3)})
    oNewPag3:SetCancelAction({|| .T., oDlg:End()})
    oNewPag3:SetPrevAction({|| .T.})
    oNewPag3:SetPrevTitle(STR0004) //"Voltar"

    //Pagina 4
    oNewPag4 := oStepWiz:AddStep("4")
    oNewPag4:SetStepDescription(STR0006) //"Parâmetros Importador XML"
    oNewPag4:SetConstruction({|Panel| WizImpPg(Panel,4)})
    oNewPag4:SetNextAction({|| WizImpVld(4)})
    oNewPag4:SetCancelAction({|| .T., oDlg:End()})
    oNewPag4:SetPrevAction({|| .T.})
    oNewPag4:SetPrevTitle(STR0004) //"Voltar"

    //Pagina 5
    oNewPag5 := oStepWiz:AddStep("5")
    oNewPag5:SetStepDescription(STR0007) //"Parâmetros Totvs Transmite"
    oNewPag5:SetConstruction({|Panel| WizImpPg(Panel,5)})
    oNewPag5:SetNextAction({|| WizImpVld(5)})
    oNewPag5:SetCancelAction({|| .T., oDlg:End()})
    oNewPag5:SetPrevAction({|| .T.})
    oNewPag5:SetPrevTitle(STR0004) //"Voltar"

    //Pagina 6
    oNewPag6 := oStepWiz:AddStep("6")
    oNewPag6:SetStepDescription(STR0008) //"Config NGINN / NGLIDOS"
    oNewPag6:SetConstruction({|Panel| WizImpPg(Panel,6)})
    oNewPag6:SetNextAction({|| WizImpVld(6)})
    oNewPag6:SetCancelAction({|| .T., oDlg:End()})
    oNewPag6:SetPrevAction({|| .T.})
    oNewPag6:SetPrevTitle(STR0004) //"Voltar"

    //Pagina 7
    oNewPag7 := oStepWiz:AddStep("7")
    oNewPag7:SetStepDescription(STR0009) //"Config MV's Importador XML"
    oNewPag7:SetConstruction({|Panel| WizImpPg(Panel,7)})
    oNewPag7:SetNextAction({|| WizImpVld(7)})
    oNewPag7:SetCancelAction({|| .T., oDlg:End()})
    oNewPag7:SetPrevAction({|| .T.})
    oNewPag7:SetPrevTitle(STR0004) //"Voltar"

    //Pagina 8
    oNewPag8 := oStepWiz:AddStep("8")
    oNewPag8:SetStepDescription(STR0010) //"Config MV's Totvs Transmite"
    oNewPag8:SetConstruction({|Panel| WizImpPg(Panel,8)})
    oNewPag8:SetNextAction({|| WizImpVld(8)})
    oNewPag8:SetCancelAction({|| .T., oDlg:End()})
    oNewPag8:SetPrevAction({|| .T.})
    oNewPag8:SetPrevTitle(STR0004) //"Voltar"

    //Pagina 9
    oNewPag9 := oStepWiz:AddStep("9")
    oNewPag9:SetStepDescription(STR0011) //"Config Emp/Fil Transmite"
    oNewPag9:SetConstruction({|Panel| WizImpPg(Panel,9)})
    oNewPag9:SetNextAction({|| .T., oDlg:End()}) 
    oNewPag9:SetCancelAction({|| .T., oDlg:End()})
    oNewPag9:SetPrevAction({|| .T.})
    oNewPag9:SetPrevTitle(STR0004) //"Voltar"

    oStepWiz:Activate()

    ACTIVATE DIALOG oDlg CENTER

    oStepWiz:Destroy()

Return

/*/{Protheus.doc} WizImpPg
Wizard - Dados das paginas para configuração do Importador XML x Totvs Transmite

@param  oPanel  Painel de dados
@param  nPage   Pagina do painel

@author rodrigo.mpontes
@since 21/10/2013
/*/

Static Function WizImpPg(oPanel,nPage)

Local cDesc1    := ""
Local aTabelas  := {}
Local aFontes   := {}
Local aMVImp    := {}
Local aMVTra    := {}
Local aHdTab    := {}
Local aTamTab   := {}
Local aAllGroup := {}
Local aFilial   := {}
Local aAux      := {}
Local nI        := 0

If nPage == 1 
    cDesc1 := STR0012 + CRLF + CRLF + STR0013 //'Boas Vindas:'#'Essa ferramenta tem a finalidade de facilitar a configuração e validação do Importador XML e a integração com o TOTVS Transmite'
    oS1Pg1 := TSay():New(10,10,{|| cDesc1 },oPanel,,oTFont,,,,.T.,,,500,100)

    oS2Pg1 := TSay():New(080,10,{|| STR0014 },oPanel,,oTFont,,,,.T.,,,100,50) //"Links Recomendados:"
    oS2Pg1 := TSay():New(100,10,{|| STR0015 },oPanel,,oTFont,,,,.T.,,,500,50) //"Guia de Referência - Importador XML"
    oS2Pg1:blClicked := {|| WizImpOpen("https://tdn.totvs.com/pages/releaseview.action?pageId=485858148")}
    oS2Pg1:nClrText  := CLR_BLUE

    oS3Pg1 := TSay():New(120,10,{|| STR0016 },oPanel,,oTFont,,,,.T.,,,500,50) //"Integração Importador XML x Totvs Transmite"
    oS3Pg1:blClicked := {|| WizImpOpen("https://tdn.totvs.com/pages/releaseview.action?pageId=678583195")}
    oS3Pg1:nClrText  := CLR_BLUE

    oS4Pg1 := TSay():New(140,10,{|| STR0017 },oPanel,,oTFont,,,,.T.,,,500,50) //"Expedição Contínua Compras"
    oS4Pg1:blClicked := {|| WizImpOpen("https://tdn.totvs.com/pages/releaseview.action?pageId=522011099")}
    oS4Pg1:nClrText  := CLR_BLUE

    oS5Pg1 := TSay():New(160,10,{|| STR0018 },oPanel,,oTFont,,,,.T.,,,500,50) //"Expedição Contínua TSS (ColAutoRead)"
    oS5Pg1:blClicked := {|| WizImpOpen("https://tdn.totvs.com/pages/releaseview.action?pageId=525010692")}
    oS5Pg1:nClrText  := CLR_BLUE

Elseif nPage == 2 
    aTabelas := WizImpTab()
    aHdTab    := {STR0019,STR0020,STR0021} //"Ok"#"Tabela"#"Descrição"
    aTamTab   := {1,10,200}
    cDesc1 := STR0022 + CRLF + CRLF + STR0023 //'Descrição:'#'Finalidade de validar tabelas e campos do Importador XML e da integração com o TOTVS Transmite'
    oS1Pg2 := TSay():New(10,10,{|| cDesc1 },oPanel,,oTFont,,,,.T.,,,600,100)

    oBrw1Pg2 	:= TWBrowse():New(70,10,290,125,,aHdTab,aTamTab,oPanel,,,,,,,,,,,,.F.,,.T.,,.F.,,,)
	oBrw1Pg2:SetArray(aTabelas)
	oBrw1Pg2:bLine	:= { || {   Iif(aTabelas[oBrw1Pg2:nAt,1]==1,oOK,Iif(aTabelas[oBrw1Pg2:nAt,1]==2,oNO,oYE)),;
							    aTabelas[oBrw1Pg2:nAt,2],;
                                aTabelas[oBrw1Pg2:nAt,3]}}

    oMGetPg2 := tMultiget():new( 70, 310, {| u | if( pCount() > 0, cMsgTab := u, cMsgTab ) },oPanel, 220, 125, , , , , , .T. )
Elseif nPage == 3
    aFontes := WizImpPrw()
    aHdTab    := {STR0019,STR0005,STR0024,STR0025,STR0026} //"Ok"#"Programas/Binário"#"Responsavel"#"Data OK"#"Data Ambiente"
    aTamTab   := {1,80,40,60,60}
    cDesc1 := STR0022 + CRLF + CRLF + STR0027 //'Descrição:'#'Finalidade de validar binário e programas do Importador XML e da integração com o TOTVS Transmite'
    oS1Pg3 := TSay():New(10,10,{|| cDesc1 },oPanel,,oTFont,,,,.T.,,,600,100)

    oBrw1Pg3 	:= TWBrowse():New(70,10,290,125,,aHdTab,aTamTab,oPanel,,,,,,,,,,,,.F.,,.T.,,.F.,,,)
	oBrw1Pg3:SetArray(aFontes)
	oBrw1Pg3:bLine	:= { || {   Iif(aFontes[oBrw1Pg3:nAt,1]==1,oOK,Iif(aFontes[oBrw1Pg3:nAt,1]==2,oNO,oYE)),;
							    aFontes[oBrw1Pg3:nAt,2],;
                                aFontes[oBrw1Pg3:nAt,3],;
                                aFontes[oBrw1Pg3:nAt,4],;
                                aFontes[oBrw1Pg3:nAt,5]}}

    oMGetPg3 := tMultiget():new( 70, 310, {| u | if( pCount() > 0, cMsgPrw := u, cMsgPrw ) },oPanel, 220, 125, , , , , , .T. )
Elseif nPage == 4
    aMVImp  := WizImpMV("Imp")
    aHdTab  := {STR0019,STR0028,STR0021} //"Ok"#"Parâmetro"#"Descrição"
    aTamTab := {1,60,100}
    cDesc1 := STR0022 + CRLF + CRLF + STR0029 //'Descrição:'#'Finalidade de validar parâmetros do Importador XML'
    oS1Pg4 := TSay():New(10,10,{|| cDesc1 },oPanel,,oTFont,,,,.T.,,,600,100)

    oBrw1Pg4 	:= TWBrowse():New(70,10,290,125,,aHdTab,aTamTab,oPanel,,,,,,,,,,,,.F.,,.T.,,.F.,,,)
	oBrw1Pg4:SetArray(aMVImp)
	oBrw1Pg4:bLine	:= { || {   Iif(aMVImp[oBrw1Pg4:nAt,1]==1,oOK,Iif(aMVImp[oBrw1Pg4:nAt,1]==2,oNO,oYE)),;
							    aMVImp[oBrw1Pg4:nAt,2],;
                                aMVImp[oBrw1Pg4:nAt,3]}}

    oMGetPg4 := tMultiget():new( 70, 310, {| u | if( pCount() > 0, cMsgMV1 := u, cMsgMV1 ) },oPanel, 220, 125, , , , , , .T. )
Elseif nPage == 5
    aMVTra    := WizImpMV("Tra")
    aHdTab    := {STR0019,STR0028,STR0021} //"Ok"#"Parâmetro"#"Descrição"
    aTamTab   := {1,60,100}
    cDesc1 := STR0022 + CRLF + CRLF + STR0030 //'Descrição:'#'Finalidade de validar parâmetros da integração do Importador XML com Totvs Transmite'
    oS1Pg5 := TSay():New(10,10,{|| cDesc1 },oPanel,,oTFont,,,,.T.,,,600,100)

    oBrw1Pg5 	:= TWBrowse():New(70,10,290,125,,aHdTab,aTamTab,oPanel,,,,,,,,,,,,.F.,,.T.,,.F.,,,)
	oBrw1Pg5:SetArray(aMVTra)
	oBrw1Pg5:bLine	:= { || {   Iif(aMVTra[oBrw1Pg5:nAt,1]==1,oOK,Iif(aMVTra[oBrw1Pg5:nAt,1]==2,oNO,oYE)),;
							    aMVTra[oBrw1Pg5:nAt,2],;
                                aMVTra[oBrw1Pg5:nAt,3]}}

    oMGetPg5 := tMultiget():new( 70, 310, {| u | if( pCount() > 0, cMsgMV2 := u, cMsgMV2 ) },oPanel, 220, 125, , , , , , .T. )
Elseif nPage == 6
    cMVNGIN	:= SuperGetMV("MV_NGINN",.F.,Space(50))
    If !Empty(cMVNGIN)
        cGMVNGI := cMVNGIN + Space(50)
    Endif
    cMVNGLI	:= SuperGetMV("MV_NGLIDOS",.F.,Space(50))
    If !Empty(cMVNGLI)
        cGMVNGL := cMVNGLI + Space(50)
    Endif

    cDesc1 := STR0022 + CRLF + CRLF + STR0031 + CRLF +; //'Descrição:'#"Definir caminho de onde serão importados os XML (Parâmetros)"
			 STR0032 //"Obs: o caminho deve estar dentro do DATA do Protheus."
    oS1Pg6 := TSay():New(10,10,{|| cDesc1 },oPanel,,oTFont,,,,.T.,,,600,100)

    oS2Pg6 := TSay():New(80,10,{|| "MV_NGINN: "},oPanel,,oTFont,,,,.T.,,,80,20)
	oG1Pg6 := TGet():New(78,120,{|u|If(PCount()==0,cGMVNGI,cGMVNGI := u ) },oPanel,200,20,"@!",,,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,,"cGMVNGI",,,,)
	
	oS3Pg6 := TSay():New(110,10,{|| "MV_NGLIDOS: "},oPanel,,oTFont,,,,.T.,,,80,20)
    oG2Pg6 := TGet():New(108,120,{|u|If(PCount()==0,cGMVNGL,cGMVNGL := u ) },oPanel,200,20,"@!",,,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,,"cGMVNGL",,,,)

    oS4Pg6 := TSay():New(150,10,{|| STR0033 },oPanel,,oTFont,,,,.T.,,,500,50) //"Documentação: Estrutura de pastas"
    oS4Pg6:blClicked := {|| WizImpOpen("https://tdn.totvs.com/pages/releaseview.action?pageId=485869252")}
    oS4Pg6:nClrText  := CLR_BLUE
Elseif nPage == 7
    aMVGer  := WizImpMV("Ger")
    aMVNfe  := WizImpMV("Nfe")
    aMVCte  := WizImpMV("Cte") 
    
    aHdTab    := {STR0028,STR0034,STR0021} //"Parâmetro"#"Conteudo"#"Descrição"
    aTamTab   := {40,20,100}

    //Geral
    oGrp1Pg7:= TGroup():New(05,05,100,185,STR0035,oPanel,,,.T.) //'Geral'
	oBrw1Pg7 	:= TWBrowse():New(15,10,170,80,,aHdTab,aTamTab,oGrp1Pg7,,,,,,,,,,,,.F.,,.T.,,.F.,,,)
	oBrw1Pg7:SetArray(aMVGer)
	oBrw1Pg7:bLine	:= { || {   aMVGer[oBrw1Pg7:nAt,1],;
							    aMVGer[oBrw1Pg7:nAt,2],;
                                aMVGer[oBrw1Pg7:nAt,3]}}  
    oBrw1Pg7:bChange := {|| WizImpAtuMV(oBrw1Pg7,oBrw1Pg7:nAt,oG1Pg7,oG2Pg7,oMGetPg7)}

    //NFe
    oGrp2Pg7:= TGroup():New(05,195,100,380,STR0036,oPanel,,,.T.) //'NFe'
	oBrw2Pg7 	:= TWBrowse():New(15,200,175,80,,aHdTab,aTamTab,oGrp2Pg7,,,,,,,,,,,,.F.,,.T.,,.F.,,,)
	oBrw2Pg7:SetArray(aMVNFe)
	oBrw2Pg7:bLine	:= { || {   aMVNFe[oBrw2Pg7:nAt,1],;
							    aMVNFe[oBrw2Pg7:nAt,2],;
                                aMVNFe[oBrw2Pg7:nAt,3]}}
    oBrw2Pg7:bChange := {|| WizImpAtuMV(oBrw2Pg7,oBrw2Pg7:nAt,oG1Pg7,oG2Pg7,oMGetPg7)}
    
    //CTe
    oGrp3Pg7:= TGroup():New(05,385,100,570,STR0037,oPanel,,,.T.) //'CTe'
	oBrw3Pg7 	:= TWBrowse():New(15,390,175,80,,aHdTab,aTamTab,oGrp3Pg7,,,,,,,,,,,,.F.,,.T.,,.F.,,,)
	oBrw3Pg7:SetArray(aMVCte)
	oBrw3Pg7:bLine	:= { || {   aMVCte[oBrw3Pg7:nAt,1],;
							    aMVCte[oBrw3Pg7:nAt,2],;
                                aMVCte[oBrw3Pg7:nAt,3]}} 
    oBrw3Pg7:bChange := {|| WizImpAtuMV(oBrw3Pg7,oBrw3Pg7:nAt,oG1Pg7,oG2Pg7,oMGetPg7)}
				
	oS2Pg7 := TSay():New(110,010,{|| STR0038},oPanel,,oTFont,,,,.T.,,,80,20) //"Parâmetro: "
	oG1Pg7 := TGet():New(108,075,{|u|If(PCount()==0,cMVPar,cMVPar := u ) },oPanel,100,20,"@!",,,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,,"cMVPar",,,,)
    oG1Pg7:bWhen := {|| .F.}
	
	oS3Pg7 := TSay():New(140,010,{|| STR0039},oPanel,,oTFont,,,,.T.,,,80,20) //"Conteudo: "
	oG2Pg7 := TGet():New(138,075,{|u|If(PCount()==0,xMVCont,xMVCont := u ) },oPanel,100,20,,,,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,,"xMVCont",,,,)

    oS4Pg7 := TSay():New(110,180,{|| STR0022},oPanel,,oTFont,,,,.T.,,,80,20) //"Descrição: "
	oMGetPg7 := tMultiget():new(108, 245, {| u | if( pCount() > 0, cMVDesc := u, cMVDesc ) },oPanel, 320, 085, , , , , , .T. )
	
    oBtPg7 := TBrowseButton():New( 140,180,STR0040,oPanel, {|| WizImpSaveMV({oBrw1Pg7,oBrw2Pg7,oBrw3Pg7})},40,20,,,.F.,.T.,.F.,,.F.,,,) //'Salvar'
    oBtPg7:SetColor( CLR_WHITE, rgb(9, 123, 152)) 
Elseif nPage == 8
    aMVIxT  := WizImpMV("IxT")  
    
    aHdTab    := {STR0028,STR0034,STR0021}  //"Parametro"#"Conteudo"#"Descrição"
    aTamTab   := {40,20,100}

    //Totvs Transmite
    oGrp1Pg8:= TGroup():New(05,05,190,280,STR0041,oPanel,,,.T.) //'Integração Importador XML x Totvs Transmite'
	oBrw1Pg8 	:= TWBrowse():New(15,10,265,170,,aHdTab,aTamTab,oGrp1Pg8,,,,,,,,,,,,.F.,,.T.,,.F.,,,)
	oBrw1Pg8:SetArray(aMVIxT)
	oBrw1Pg8:bLine	:= { || {   aMVIxT[oBrw1Pg8:nAt,1],;
							    aMVIxT[oBrw1Pg8:nAt,2],;
                                aMVIxT[oBrw1Pg8:nAt,3]}}
    oBrw1Pg8:bChange := {|| WizImpAtuMV(oBrw1Pg8,oBrw1Pg8:nAt,oG1Pg8,oG2Pg8,oMGetPg8)}
				
	oS2Pg8 := TSay():New(10,310,{|| STR0038},oPanel,,oTFont,,,,.T.,,,80,20) //"Parametro: "
	oG1Pg8 := TGet():New(08,375,{|u|If(PCount()==0,cMVPar,cMVPar := u ) },oPanel,150,20,"@!",,,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,,"cMVPar",,,,)
    oG1Pg8:bWhen := {|| .F.}
	
	oS3Pg8 := TSay():New(40,310,{|| STR0039},oPanel,,oTFont,,,,.T.,,,80,20) //"Conteudo: "
	oG2Pg8 := TGet():New(38,375,{|u|If(PCount()==0,xMVCont,xMVCont := u ) },oPanel,150,20,,,,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,,"xMVCont",,,,)

    oS4Pg8 := TSay():New(70,310,{|| STR0022},oPanel,,oTFont,,,,.T.,,,80,20) //"Descrição: "
	oMGetPg8 := tMultiget():new(68, 375, {| u | if( pCount() > 0, cMVDesc := u, cMVDesc ) },oPanel, 150, 70, , , , , , .T. )
                
    oBt1Pg8 := TBrowseButton():New( 115,310,STR0040,oPanel, {|| WizImpSaveMV({oBrw1Pg8})},40,20,,,.F.,.T.,.F.,,.F.,,,) //'Salvar'
    oBt1Pg8:SetColor( CLR_WHITE, rgb(9, 123, 152) )
Elseif nPage == 9
    If (Empty(oBrw1Pg8:aArray[aScan(oBrw1Pg8:aArray,{|x| AllTrim(x[1]) == "MV_XMLCID"}),2]) .And. Empty(oBrw1Pg8:aArray[aScan(oBrw1Pg8:aArray,{|x| AllTrim(x[1]) == "MV_XMLCSEC"}),2]))
        oNewPag9:SetStepDescription(STR0042)
        oNewPag9:SetNextAction({|| .T., oDlg:End()})

        cDesc1 := STR0043 //'Finalizada configuração do Importador XML'
        oS1Pg9 := TSay():New(90,210,{|| cDesc1 },oPanel,,oTFont,,,,.T.,,,500,100)
    Else
        oNewPag9:SetNextAction({|| .T., WizImpHlp(STR0044,"C"), oDlg:End()}) //'Finalizada configuração do Importador XML x Totvs Transmite'
        aAllGroup := FwLoadSM0()
        
        For nI := 1 To Len(aAllGroup)
            nPos := aScan(aFilial,{|x| x[1] == aAllGroup[nI,1]} )
            If nPos == 0
                aAdd(aFilial,{aAllGroup[nI,1],aAllGroup[nI,2]})
            Else
                aFilial[nPos,2] += "|" + aAllGroup[nI,2] 
            Endif
        Next nI

        aAux := WizImpGrp(aFilial,1)

        If Len(aAux) > 0
            aGrp    := aAux[1]
            aFilGrp := aAux[2] 

            oS1Pg9 := TSay():New(10,05,{|| STR0088},oPanel,,oTFont,,,,.T.,,,180,150) //"Descrição: Selecione a(s) filial(ais) que serão conectadas e/ou desconectadas ao Totvs Transmite"

            //Grupo Empresa
            oBrw1Pg9 	:= TWBrowse():New(40,05,190,155,,{STR0045},{05,20},oPanel,,,,,,,,,,,,.F.,,.T.,,.F.,,,) //"Grupo Empresa"
            oBrw1Pg9:SetArray(aGrp)
            oBrw1Pg9:bLine	:= { || {  aGrp[oBrw1Pg9:nAt]}}
            oBrw1Pg9:bChange    := {|| WizImpAGrp(oBrw1Pg9:nAt,aFilial,oBrw2Pg9)}
            
            //Grupo Empresa - Filiais
            oBrw2Pg9 	:= TWBrowse():New(10,210,350,185,,{STR0046,STR0045,STR0047,STR0048},{50,50,50,100},oPanel,,,,,,,,,,,,.F.,,.T.,,.F.,,,) //"Selecione Filial"#"Grupo Empresa"#"Filial"#"Desc Filial"
            oBrw2Pg9:SetArray(aFilGrp) 
            oBrw2Pg9:bLine	:= { || {   Iif(aFilGrp[oBrw2Pg9:nAt,1],oOK,oNO),;
                                        aFilGrp[oBrw2Pg9:nAt,2],;
                                        aFilGrp[oBrw2Pg9:nAt,3],;
                                        aFilGrp[oBrw2Pg9:nAt,4]}}
            oBrw2Pg9:bLDblClick := {|| WizImpCGrp(oBrw2Pg9,@aFilGrp)}
            oBrw2Pg9:bHeaderClick := {|| Processa({|| WizImpCGrp(oBrw2Pg9,@aFilGrp,"A") }, STR0049) } //"Processando"
        Endif
    Endif
Endif

Return

/*/{Protheus.doc} WizImpCGrp
Wizard - Importador XML x Totvs Transmite
Duplo clique para selecionar Filial integrada com o Totvs Transmite

@param  oObj    Browse de dados
@param  aDados  Array de dados
@param  cOpc    A - ALL / I - Item

@author rodrigo.mpontes
@since 21/10/2013
/*/

Static Function WizImpCGrp(oObj,aDados,cOpc)

Local nI        := 0
Local nPerc     := 0
Local cMsgAdd   := ""
Local cMsgNAd   := ""
Local cMsgDel   := ""

Default cOpc    := "I"

If cOpc == "I"
    //Grava DHW ou Deleta DHW (CodFil)
    aDados[oObj:nAt,1] := WizImpTGrp(!aDados[oObj:nAt,1],oObj)
Elseif cOpc == "A"
    ProcRegua(Len(aDados))
    For nI := 1 To Len(aDados)
        nPerc := Round((nI*100)/Len(aDados),0)
        IncProc(STR0050 + AllTrim(Str(nPerc)) + "%") //"Verificando se filial(ais) integra com o Totvs Transmite: "
        aDados[nI,1] := WizImpTGrp(!aDados[nI,1],oObj,nI,@cMsgAdd,@cMsgNAd,@cMsgDel)
    Next nI
Endif

//Atualiza Browse
oObj:SetArray(aDados)
oObj:bLine := {|| {If(aDados[oObj:nAT,1],oOK,oNo),aDados[oObj:nAt,02],aDados[oObj:nAt,03],aDados[oObj:nAt,04]}}
oObj:Refresh()

If cOpc == "A"
    WizImpHlp(cMsgAdd + CRLF + CRLF + cMsgNAd + CRLF + CRLF + cMsgDel,"D")
Endif

Return

/*/{Protheus.doc} WizImpTGrp
Wizard - Importador XML x Totvs Transmite
Gravação ou Exclusão da DHW - Amarração Protheus x Totvs Transmite (CodFil)

@param  lGrvDhW Logico para verificar se filial foi gravada ou não
@param  oObj    Objeto - Browse

@author rodrigo.mpontes
@since 21/10/2013
/*/

Static Function WizImpTGrp(lGrvDhW,oObj,nLin,cMsgAdd,cMsgNAd,cMsgDel)

Local lFindDHW  := .F.
Local nTamGrp   := TamSX3("DHW_GRPEMP")[1]
Local nTamFil   := TamSX3("DHW_FILEMP")[1]
Local aSM0Dados	:= {}
Local cCodFil   := ""
Local lAll      := .F.

Default nLin    := 0

If nLin == 0
    nLin := oObj:nAt
Else //Header Click
    lAll := .T.
Endif

DbSelectArea("DHW") 
DHW->(DbSetOrder(1))
lFindDHW := DHW->(DbSeek(xFilial("DHW") + PadR(oObj:aArray[nLin,2],nTamGrp) + PadR(oObj:aArray[nLin,3],nTamFil)))

If lGrvDhW .And. !lFindDHW //Grava DHW
    aSM0Dados 	:= FWSM0Util():GetSM0Data( oObj:aArray[nLin,2] , oObj:aArray[nLin,3] , { "M0_CGC","M0_INSC","M0_ESTENT" } )
    cCodFil		:= WizImpCodFil(oObj:aArray[nLin,2],oObj:aArray[nLin,3],aSM0Dados[1,2],aSM0Dados[2,2],aSM0Dados[3,2])
    
    If !Empty(cCodFil) 
        If RecLock("DHW",.T.)
            DHW->DHW_FILIAL := xFilial("DHW") 
            DHW->DHW_GRPEMP := oObj:aArray[nLin,2]
            DHW->DHW_FILEMP := oObj:aArray[nLin,3]
            DHW->DHW_CGC    := aSM0Dados[1,2]
            DHW->DHW_IE     := aSM0Dados[2,2]
            DHW->DHW_UF     := aSM0Dados[3,2]
            DHW->DHW_CODFIL := cCodFil 
            
            DHW->(MsUnlock())
        Endif
        If lAll
            If Empty(cMsgAdd)
                cMsgAdd += STR0051 + AllTrim(oObj:aArray[nLin,3]) //"Filial(ais) conectadas ao Totvs Transmite: "
            Else
                cMsgAdd += " | " + AllTrim(oObj:aArray[nLin,3])
            Endif
        Endif
    Else
        lGrvDhW := .F.
        If lAll
            If Empty(cMsgNAd)
                cMsgNAd += STR0052 + AllTrim(oObj:aArray[nLin,3]) //"Filial(ais) não encontradas no Totvs Transmite: "
            Else
                cMsgNAd += " | " + AllTrim(oObj:aArray[nLin,3])
            Endif
        Else
            WizImpHlp(STR0053,"B") //"Não foi encontrada Grp Empresa/Filial no Totvs Transmite"
        Endif
    Endif
Elseif !lGrvDhW .And. lFindDHW //Deleta DHW
    If RecLock("DHW",.F.)
        DHW->(dbDelete())
        DHW->(MsUnlock())
    Endif
    If lAll
        If Empty(cMsgDel)
            cMsgDel += STR0054 + AllTrim(oObj:aArray[nLin,3]) //"Filial(ais) desconectadas ao Totvs Transmite: "
        Else
            cMsgDel += " | " + AllTrim(oObj:aArray[nLin,3])
        Endif
    Endif
Endif

Return lGrvDhW

/*/{Protheus.doc} WizImpCodFil
Integração com Transmite para busca Codigo Filial correspondente

@author rodrigo.mpontes
@since 05/08/19
/*/

Static Function WizImpCodFil(cEmp,cFil,cCGC,cIE,cUF)

Local oComTransmite	:= Nil
Local lImpXML       := SuperGetMv("MV_IMPXML",.F.,.F.) .And. CKO->(FieldPos("CKO_ARQXML")) > 0 .And. !Empty(CKO->(IndexKey(5)))
Local cConteudo		:= ""

If lImpXML
	oComTransmite := ComTransmite():New()

	If oComTransmite:TokenTotvsTransmite()
		cConteudo := oComTransmite:GetCodigoFilial(cCGC,cIE,cUF,cEmp,cFil)
	Endif
	
	FreeObj(oComTransmite)
Endif 

Return cConteudo

/*/{Protheus.doc} WizImpAGrp
Wizard - Importador XML x Totvs Transmite
Atualização de Filiais por Grupo de Empresa

@param  nEmpLin     Posição do Grupo de Empresa
@param  aFilial     Dados dos Grupos e Filiais    
@param  oObjFil     Objeto - Browse

@author rodrigo.mpontes 
@since 21/10/2013
/*/

Static Function WizImpAGrp(nEmpLin,aFilial,oObjFil) 

//Busca Filiais, a partir da Grupo selecionado
Local aAux  := WizImpGrp(aFilial,nEmpLin)

If Len(aAux) > 0
    aFilGrp := aAux[2]
    oObjFil:SetArray(aFilGrp)
	oObjFil:bLine := {|| {If(aFilGrp[oObjFil:nAT,1],oOK,oNo),aFilGrp[oObjFil:nAt,02],aFilGrp[oObjFil:nAt,03],aFilGrp[oObjFil:nAt,04]}}
	oObjFil:Refresh()
Endif

Return

/*/{Protheus.doc} WizImpGrp
Wizard - Importador XML x Totvs Transmite
Carrega todos Grupos e Filias

@param  aFilial     Dados dos Grupos e Filiais    
@param  nEmp        Posição do Grupo de Empresa

@author rodrigo.mpontes 
@since 21/10/2013
/*/

Static Function WizImpGrp(aFilial,nEmp)

Local nI        := 0
Local aAux      := 0
Local aGrp      := {}
Local aFilGrp   := {}
Local aSM0Dados := {}
Local nTamGrp   := TamSX3("DHW_GRPEMP")[1]
Local nTamFil   := TamSX3("DHW_FILEMP")[1]

//Grupo de Empresas
For nI := 1 To Len(aFilial)
    aAdd(aGrp,aFilial[nI,1])
Next nI

//Filiais do Grupo
aAux := Separa(aFilial[nEmp,2],"|")
For nI := 1 To Len(aAux)
    
    aSM0Dados 	:= FWSM0Util():GetSM0Data( aFilial[nEmp,1] , aAux[nI] , { "M0_FILIAL" } )

    //Verifica se ja possui vinculo com o Transmite (DHW)
    If !Empty(GetAdvFVal("DHW","DHW_CODFIL",xFilial("DHW") + PadR(aFilial[nEmp,1],nTamGrp) + PadR(aAux[nI],nTamFil),1))
        aAdd(aFilGrp,{.T.,aFilial[nEmp,1],aAux[nI],aSM0Dados[1,2]}) 
    Else
        aAdd(aFilGrp,{.F.,aFilial[nEmp,1],aAux[nI],aSM0Dados[1,2]}) 
    Endif
Next nI

If Len(aGrp) > 0 .And. Len(aFilGrp) > 0
    aRet := {aGrp,aFilGrp}
Endif

Return aRet

/*/{Protheus.doc} WizImpVld
Wizard - Importador XML x Totvs Transmite
Validações das paginas

@param  nPage   Pagina a ser validada

@author rodrigo.mpontes 
@since 21/10/2013
/*/

Static Function WizImpVld(nPage)

Local lRet      := .T.
Local nI        := 0
Local cMsg      := ""
Local cOpc      := "" // B-Bloqueio / A-Aviso
Local cXMLCID   := ""
Local cXMLCSEC  := ""
Local cAPITRAN  := ""

If nPage == 2
    For nI := 1 To Len(oBrw1Pg2:aArray)
        If oBrw1Pg2:aArray[nI,1] == 2
            lRet := .F.
            cMsg := STR0055 + CRLF + STR0056 //"Possui tabelas inexistente e/ou invalidas em seu ambiente. "#"Favor verificar seu ambiente"
            cOpc := "B"
            Exit
        Endif
    Next nI
Elseif nPage == 3
    For nI := 1 To Len(oBrw1Pg3:aArray)
        If oBrw1Pg3:aArray[nI,1] == 2
            lRet := .F.
            cMsg := STR0057 + CRLF + STR0056 //"Possui fontes inexistente em seu ambiente. "#"Favor verificar seu ambiente"
            cOpc := "B"
            Exit
        Elseif oBrw1Pg3:aArray[nI,1] == 3
            lRet := .F.
            cMsg := STR0058 + CRLF + STR0059 //"Possui fontes desatualizados em seu ambiente. "#"Importador XML e/ou integração com Totvs Transmite pode não funcionar corretamente. Deseja Prosseguir?"
            cOpc := "A"
            Exit
        Endif
    Next nI
Elseif nPage  == 4
    For nI := 1 To Len(oBrw1Pg4:aArray)
        If oBrw1Pg4:aArray[nI,1] == 2
            lRet := .F.
            cMsg := STR0060 + CRLF + STR0056 //"Possui parâmetros inexistente em seu ambiente. "#"Favor verificar seu ambiente"
            cOpc := "B"
            Exit
        Endif
    Next nI
Elseif nPage  == 5
    For nI := 1 To Len(oBrw1Pg5:aArray)
        If oBrw1Pg5:aArray[nI,1] == 2
            lRet := .F.
            cMsg := STR0060 + CRLF + STR0056 //"Possui parâmetros inexistente em seu ambiente. "#"Favor verificar seu ambiente"
            cOpc := "B"
            Exit
        Endif
    Next nI
Elseif nPage == 6
    If Empty(cGMVNGI) .Or. Empty(cGMVNGL)
        lRet := .F.
            cMsg := STR0061 + CRLF + STR0062 //"Parâmetro MV_NGINN e/ou MV_NGLIDOS não foram preenchidos."#"Favor preencher parâmetros"
        cOpc := "B"
    Endif

    If lRet
        PutMV("MV_IMPXML"   ,.T.)
    	PutMV("MV_NGINN"    ,cGMVNGI)
    	PutMV("MV_NGLIDOS"  ,cGMVNGL)
    Endif
Elseif nPage == 8
    cXMLCID     := oBrw1Pg8:aArray[aScan(oBrw1Pg8:aArray,{|x| AllTrim(x[1]) == "MV_XMLCID"}),2]
    cXMLCSEC    := oBrw1Pg8:aArray[aScan(oBrw1Pg8:aArray,{|x| AllTrim(x[1]) == "MV_XMLCSEC"}),2]
    cAPITRAN    := oBrw1Pg8:aArray[aScan(oBrw1Pg8:aArray,{|x| AllTrim(x[1]) == "MV_APITRAN"}),2]

    If Empty(cXMLCID) .Or. Empty(cXMLCSEC) .Or. Empty(cAPITRAN)
        lRet := .F.
        cMsg := STR0063 + ; //"Sem informação nos parametros MV_XMLCID/MV_XMLCSEC/MV_APITRAN integração com Totvs Transmite não funcionara "
                CRLF + STR0064
        cOpc := "A"
    Elseif !Empty(cXMLCID) .Or. !Empty(cXMLCSEC) .Or. !Empty(cAPITRAN)
        lRet := .F.
        cMsg := STR0065 //"Validando conexão com o Totvs Transmite!"
        cOpc := "C"

        lRet := WizImpHlp(cMsg,cOpc)

        If lRet
            lRet := WizImpVldTra(cXMLCID,cXMLCSEC,cAPITRAN)
            cMsg := ""
        Endif
    Endif
Endif

If !lRet .And. !Empty(cMsg)
    lRet := WizImpHlp(cMsg,cOpc)
Endif

Return lRet

/*/{Protheus.doc} WizImpHlp
Wizard - Importador XML x Totvs Transmite
Avisos do wizard

@param  cMsg   Mensagem a ser exibida
@param  cOpc   B-Bloqueio / A-Aviso    

@author rodrigo.mpontes 
@since 21/10/2013
/*/

Static Function WizImpHlp(cMsg,cOpc)

Local lRet      := .F.
Local aOpc    := {}
Local nOpc      := 0

If cOpc == "B" .Or. cOpc == "C"
    aOpc := {STR0019} //"Ok"
Elseif cOpc == "A"
    aOpc := {STR0066,STR0067} //"Sim"#"Não"
Endif

If cOpc <> "D"
    nOpc := Aviso(STR0068,cMsg,aOpc) //"Atenção"
Elseif cOpc == "D"
    DEFINE MSDIALOG oDlgFil TITLE STR0069 FROM 000,000 TO 600,800 PIXEL //"Filial(ais) - Importador XML x Totvs Transmite"

    oTMGetFil := tMultiget():new(05,05, {| u | if( pCount() > 0, cMsg := u, cMsg ) },oDlgFil, 390, 290, , , , , , .T. ) 

    ACTIVATE MSDIALOG oDlgFil CENTERED  
Endif

If cOpc == "A"
    If nOpc == 1
        lRet := .T.
    Endif
Elseif cOpc == "C" .Or. cOpc == "D"
    lRet := .T.
Endif

Return lRet

/*/{Protheus.doc} WizImpTab
Wizard - Importador XML x Totvs Transmite
Validação das tabelas/estrutura

@author rodrigo.mpontes 
@since 21/10/2013
/*/

Static Function WizImpTab()

Local aTabVer   := {{"CKO",;
                     {"CKO_ARQUIV","CKO_XMLRET","CKO_FLAG","CKO_CODEDI","CKO_CODERR","CKO_FILPRO","CKO_EMPPRO","CKO_CNPJIM","CKO_ARQXML","CKO_MSGERR",;
                     "CKO_DOC","CKO_NOMFOR","CKO_SERIE","CKO_CHVDOC","CKO_ORIGEM","CKO_STRAN","CKO_ERRTRA"}},;
                     {"SDS",;
                     {"DS_DOC","DS_SERIE","DS_FORNEC","DS_LOJA","DS_NOMEFOR","DS_CNPJ","DS_TIPO","DS_ESPECI","DS_EMISSA","DS_FORMUL","DS_EST","DS_ARQUIVO",;
                     "DS_CHAVENF","DS_UFDESTR","DS_MUDESTR","DS_MUORITR","DS_UFORITR"}},;
                     {"SDT",;
                     {"DT_ITEM","DT_COD","DT_PRODFOR","DT_DESCFOR","DT_FORNEC","DT_LOJA","DT_DOC","DT_SERIE","DT_CNPJ","DT_QUANT","DT_VUNIT","DT_PEDIDO",;
                     "DT_ITEMPC","DT_NFORI","DT_SERIORI","DT_ITEMORI","DT_TES","DT_LOTE","DT_DTVALID","DT_LOCAL","DT_CHVNFO","DT_UM","DT_SEGUM","DT_QTSEGUM","DT_CLASFIS"}},;
                     {"DHW",;
                     {"DHW_GRPEMP","DHW_FILEMP","DHW_CGC","DHW_IE","DHW_UF","DHW_CODFIL"}},;
                     {"DHY",;
                     {"DHY_CODFIL","DHY_ID","DHY_TPXML","DHY_DTID","DHY_FILTRO"}},;
                     {"DHZ",;
                     {"DHZ_CODFIL","DHZ_ID","DHZ_TPXML","DHZ_DTID","DHZ_FILTRO","DHZ_DTLID"}}}

Local aTabRet   := {}
Local nI        := 0
Local cMsgEst   := ""

For nI := 1 To Len(aTabVer)
    cMsgTab += STR0070 + aTabVer[nI,1] + CRLF //"Tabela: "
    cMsgEst := ""
    If ChkFile(aTabVer[nI,1])
        If aTabVer[nI,1] == "CKO"
            If RetSqlName("CKO") <> "CKOCOL"
                cMsgTab += "[ERROR].......... " + STR0071 + CRLF + CRLF + CRLF + CRLF //"Tabela: inexistente e/ou diferente de CKOCOL no ambiente"
                aAdd(aTabRet,{2,aTabVer[nI,1],FwSX2Util():GetX2Name(aTabVer[nI,1])})
            Else
                cMsgTab += "[OK]............. " + STR0072 + CRLF //"Tabela: OK"
                cMsgEst := WizImpEst(aTabVer[nI,1],aTabVer[nI,2]) + CRLF + CRLF + CRLF
                cMsgTab += cMsgEst
                aAdd(aTabRet,{Iif("WARNING" $ cMsgEst,3,1),aTabVer[nI,1],FwSX2Util():GetX2Name(aTabVer[nI,1])})
            Endif
        Else
            cMsgTab += "[OK]............. " + STR0072 + CRLF //"Tabela: OK"
            cMsgEst := WizImpEst(aTabVer[nI,1],aTabVer[nI,2]) + CRLF + CRLF + CRLF
            cMsgTab += cMsgEst
            aAdd(aTabRet,{Iif("WARNING" $ cMsgEst,3,1),aTabVer[nI,1],FwSX2Util():GetX2Name(aTabVer[nI,1])}) 
        Endif
    Else
        cMsgTab += "[ERROR].......... " + STR0073 + CRLF + CRLF + CRLF + CRLF //"Tabela: inexistente no ambiente"
        aAdd(aTabRet,{2,aTabVer[nI,1],FwSX2Util():GetX2Name(aTabVer[nI,1])})
    Endif
Next nI

Return aTabRet

/*/{Protheus.doc} WizImpEst
Wizard - Importador XML x Totvs Transmite
Validação das estrutura da tabela

@author rodrigo.mpontes 
@since 21/10/2013
/*/

Static Function WizImpEst(cTab,aEstTab)

Local aAllCpo   := FWSX3Util():GetAllFields( cTab ,.T.)
Local cMsgRet   := ""
Local nI        := 0
Local cMsg      := ""

For nI := 1 To Len(aEstTab)
    nPos := aScan(aAllCpo,{|x| AllTrim(x) == AllTrim(aEstTab[nI])})
    If nPos == 0
        cMsg += " | " + aEstTab[nI]
    Endif
Next nI

If !Empty(cMsg)
    cMsg := SubStr(cMsg,4,Len(cMsg))
    cMsgRet += "[WARNING]........ " + STR0074 + cMsg + STR0075 //"Estrutura: "#" campo(s) inexistente(s) no ambiente"
Else
    cMsgRet += "[OK]............. " + STR0076 //"Estrutura: OK"
Endif

Return cMsgRet

/*/{Protheus.doc} WizImpEst
Wizard - Importador XML x Totvs Transmite
Validação do binario e fontes

@author rodrigo.mpontes 
@since 21/10/2013
/*/

Static Function WizImpPrw()

Local aPrwVer   := {{"APPSERVER","20.3.0.14","TEC"},;
                    {"COLAUTOREAD.PRW","06/10/2022","TSS"},;
                    {"COMTRANSMITE.PRW","12/11/2022","COM"},;
                    {"SCHEDCOMCOL.PRW","03/02/2023","COM"},;
                    {"COMXCOL.PRW","09/02/2023","COM"},;
                    {"COMXCOL2.PRW","05/12/2022","COM"},;
                    {"MATA140I.PRW","05/12/2022","COM"},;
                    {"MATA116I.PRW","09/02/2023","COM"}}
Local aPrwRet   := {}
Local nI        := 0
Local aDados    := {}
Local cDtTime   := ""
Local cDtTRpo   := ""
Local cBuild    := ""

For nI := 1 To Len(aPrwVer)
    If aPrwVer[nI,1] <> "APPSERVER" 
        cMsgPrw += STR0077 + aPrwVer[nI,1] + CRLF //"Programa: "
        cDtTime := aPrwVer[nI,2]
        
        aDados := GetApoInfo(aPrwVer[nI,1])

        If Len(aDados) > 0
            cDtTRpo := DtoC(aDados[4])
            
            If CtoD(cDtTRpo) < CtoD(cDtTime)
                cMsgPrw += "[WARNING]........ " + STR0078 + CRLF + CRLF //"Programa: Desatualizado"
                aAdd(aPrwRet,{3,aPrwVer[nI,1],aPrwVer[nI,3],cDtTime,cDtTRpo}) 
            Else
                cMsgPrw += "[OK]............. " + STR0079 + CRLF + CRLF //"Programa: OK"
                aAdd(aPrwRet,{1,aPrwVer[nI,1],aPrwVer[nI,3],cDtTime,cDtTRpo}) 
            Endif
        Else
            cMsgPrw += "[ERROR].......... " + STR0080 + CRLF + CRLF //"Programa: inexistente no ambiente"
            aAdd(aPrwRet,{2,aPrwVer[nI,1],aPrwVer[nI,3],cDtTime,""})
        Endif
    ElseIf aPrwVer[nI,1] == "APPSERVER" 
        cMsgPrw += "AppServer" + CRLF
        cBuild  := GetSrvVersion()
        cMsgPrw += Iif(cBuild < aPrwVer[nI,2],"[WARNING]........ " + STR0081 + CRLF + CRLF,"[OK]............. " + STR0082 + CRLF + CRLF)
        
        aAdd(aPrwRet,{Iif(cBuild < aPrwVer[nI,2],3,1),aPrwVer[nI,1],aPrwVer[nI,3],aPrwVer[nI,2],cBuild})
    Endif
Next nI

Return aPrwRet

/*/{Protheus.doc} WizImpMV
Wizard - Importador XML x Totvs Transmite
Validação dos parametros

@param  cOpc    Tipo dos parametros
                    Imp - Importador XML
                    Tra/IxT - Importador XML x Totvs Transmite
                    Ger - Geral - Importador XML
                    NFe - NFe - Importador XML
                    CTe - CTe - Importador XML

@author rodrigo.mpontes 
@since 21/10/2013
/*/

Static Function WizImpMV(cOpc)

Local aMVVer    := {}
Local aMVRet    := {}
Local aAux      := {}
Local nI        := 0
Local cMsg      := ""
Local cDescMV   := ""
Local xConteudo := Nil

If cOpc == "Imp" //Importador XML
    aMVVer := {"MV_IMPXML","MV_COMCOL1","MV_COMCOL2","MV_COMCOL3","MV_MSGCOL","MV_FILREP","MV_XMLCFPC","MV_XMLCFBN","MV_XMLCFDV","MV_XMLCFND","MV_XMLCFNO",;
                "MV_CTECLAS","MV_XMLPFCT","MV_XMLTECT","MV_XMLCPCT","MV_COLVCHV"}
Elseif cOpc == "Tra" .Or. cOpc == "IxT" //Importador XML x Totvs Transmite
    aMVVer := {"MV_DOCIMP","MV_TRAXML","MV_XMLCID","MV_XMLCSEC","MV_APITRAN","MV_XMLDIAS","MV_XMLHIST","MV_TRAEXP"}
Elseif cOpc == "Ger" //Geral
    aMVVer := {"MV_COMCOL1","MV_COMCOL2","MV_COMCOL3","MV_MSGCOL","MV_FILREP"}
Elseif cOpc == "Nfe"
    aMVVer := {"MV_XMLCFPC","MV_XMLCFBN","MV_XMLCFDV","MV_XMLCFND","MV_XMLCFNO"}
Elseif cOpc == "Cte"
    aMVVer := {"MV_CTECLAS","MV_XMLPFCT","MV_XMLTECT","MV_XMLCPCT","MV_COLVCHV"}
Endif

dbSelectArea( "SX6" )
SX6->( dbSetOrder( 1 ) )

For nI := 1 To Len(aMVVer)
    cMsg += "Parâmetro: " + aMVVer[nI] + CRLF
    cDescMV := ""
    
    If FWSX6Util():ExistsParam( aMVVer[nI] )
        If SX6->( MsSeek( FwxFilial("SX6") + aMVVer[nI] ) )
            cDescMV     := AllTrim(X6Descric()) + " " + AllTrim(X6Desc1()) + " " + AllTrim(X6Desc2())
            xConteudo	:= X6Conteud()

            cMsg += "[OK]............. " + STR0083 + CRLF + CRLF //"Parâmetro: OK"
            aAdd(aMVRet,{1,aMVVer[nI],cDescMV,xConteudo}) 
        Endif
    Else
        cMsg += "[ERROR].......... " + STR0084 + CRLF + CRLF //"Parâmetro: inexistente no ambiente"
        aAdd(aMVRet,{2,aMVVer[nI],cDescMV})
    Endif
Next nI

If cOpc == "Imp"
    cMsgMV1 := cMsg
Elseif cOpc == "Tra"
    cMsgMV2 := cMsg
Endif

If cOpc == "Ger" .Or. cOpc == "Nfe" .Or. cOpc == "Cte" .Or. cOpc == "IxT"
    For nI := 1 To Len(aMVRet)
        aAdd(aAux,{aMVRet[nI,2],aMVRet[nI,4],aMVRet[nI,3]})
    Next nI

    If Len(aAux) > 0
        aMVRet := aAux
    Endif
Endif

Return aMVRet

/*/{Protheus.doc} WizImpAtuMV
Wizard - Importador XML x Totvs Transmite
Refresh Parametros

@author rodrigo.mpontes 
@since 21/10/2013
/*/

Static Function WizImpAtuMV(oObj,nLinha,oObjG1,oObjG2,oObjM1)

cMVPar  := oObj:aArray[nLinha,1]
xMVCont := oObj:aArray[nLinha,2]
cMVDesc := oObj:aArray[nLinha,3]

oObjG1:Refresh()
oObjG2:Refresh()
oObjM1:Refresh()

Return

/*/{Protheus.doc} WizImpSaveMV
Wizard - Importador XML x Totvs Transmite
Atualizar parametros MV

@author rodrigo.mpontes 
@since 21/10/2013
/*/

Static Function WizImpSaveMV(aObj)

Local nPos  := 0
Local nI    := 0
Local oObj  := Nil

PutMV(cMVPar,xMVCont)

For nI := 1 To Len(aObj)
    oObj := aObj[nI]

    nPos := aScan(oObj:aArray,{|x| AllTrim(x[1]) == AllTrim(cMVPar)})
    If nPos > 0
        oObj:aArray[nPos,2] := xMVCont
        oObj:Refresh()
    Endif
Next nI

Return .T.

/*/{Protheus.doc} WizImpVldTra
Wizard - Importador XML x Totvs Transmite
Valida conexão com o Totvs Transmite

@author rodrigo.mpontes 
@since 21/10/2013
/*/

Static Function WizImpVldTra(cXMLCID,cXMLCSEC,cAPITRAN)

Local oComTransmite := ComTransmite():New()
Local lRet          := .F.
Local cMsg          := ""

oComTransmite:cMVXMLCID := AllTrim(cXMLCID)
oComTransmite:cMVXMLCSEC := AllTrim(cXMLCSEC)
oComTransmite:cMVAPITran := AllTrim(cAPITRAN)

If oComTransmite:TokenTotvsTransmite()
    lRet := .T.
    cMsg := STR0085 //"Conexão Totvs Transmite: OK "
Else
    cMsg := STR0086 + CRLF + STR0087 //"Conexão Totvs Transmite: Não OK "#" Verificar parametro MV_XMLCID/MV_XMLCSEC/MV_APITRAN"
Endif

WizImpHlp(cMsg,"B")

FreeObj(oComTransmite)

Return lRet

/*/{Protheus.doc} WizImpOpen
Wizard - Importador XML x Totvs Transmite
Abre link recomendado

@author rodrigo.mpontes 
@since 21/10/2013
/*/

Static Function WizImpOpen(cLink)

ShellExecute("Open", cLink, "", "", 1)

Return
