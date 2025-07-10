#Include 'PROTHEUS.CH'
#Include 'TOTVS.CH'
#Include "PARMTYPE.CH" 
#Include "RwMake.ch"
#Include "TbiConn.ch"
#Include "FILEIO.CH"
#include "RESTFUL.ch"

Static oFindCKO     := Nil
Static oNewDHW      := Nil
Static oUpdDHZ      := Nil

/*/{Protheus.doc} COMTransmite
	Classe/Objeto para integração do importador XML x Transmite
@author rodrigo.mpontes
@since 14/01/2022
/*/

Class COMTransmite
	Data cKeyGrant	    As Character
	Data cKeyScope	    As Character
    Data cApiToken      As Character
	Data cApiTra	    As Character
    Data cApiUrlToken   As Character
    Data cApiUrlCodFil  As Character
    Data cApiUrlExpNFE  As Character
    Data cApiUrlExpNFS  As Character
    Data cApiUrlExpCTE  As Character
    Data cApiUrlExpCTO  As Character
    Data cApiUrlZipNFE  As Character
    Data cApiUrlZipNFS  As Character
    Data cApiUrlZipCTE  As Character
    Data cApiUrlZipCTO  As Character
    Data cApiSetExpNFE  As Character
    Data cApiSetExpCTE  As Character
    Data cApiSetExpCTO  As Character
    Data cApiSetExpNFS  As Character
    Data cNGin          As Character
    Data cNGLidos       As Character
    Data cMVDOCIMP	    As Character
    Data cMVXMLTRA	    As Character
    Data cMVXMLCID	    As Character
    Data cMVXMLCSEC	    As Character
    Data cLastError     As Character
    Data cThreadId      As Character
    Data cDirTransmite  As Character
    Data cMVAPITran     As Character
    Data lExported      As Logical
    Data lSOWin         As Logical
    Data lAPIError      As Logical
    Data lDHW           As Logical
    Data lDHY           As Logical
    Data lDHZ           As Logical
    Data lHistDHY       As Logical
    Data lDHYFil        As Logical
    Data lDHZFil        As Logical
    Data lCkoRepro      As Logical
    Data lCkoTra        As Logical
    Data lCKO           As Logical
    Data aHeaderOut	    As Array
    Data aEdiCOM        As Array
    Data aExcEdi        As Array
    Data nDias          As Numeric
    Data nTamCod        As Numeric
    Data nTamTp         As Numeric
    Data nTamId         As Numeric
    Data nTArqXML       As Numeric   
	
	Method New() Constructor
    Method TokenTotvsTransmite()
    Method GetZIP()
    Method GetXML()
    Method GetParam()
    Method GetHeader()
    Method GetNumSeq()
    Method GetConvXML()
    Method GetDadosXML()
    Method GetConvFile()
    Method GetCodFilDHW()
    Method GetIdsExpXML()
    Method GetCodigoFilial()
    Method XMLINLIDOS()
    Method XMLTRANSMITE()
    Method PostXMLCKO()
    Method GrvIdDHY()
    Method GetIdDHY()
    Method PostStatusDHY()
    Method HistDHYDHZ()
    Method LogMessage()
    Method CleanUp()
    Method XMLEXPORTED()
    Method XMLSTATUSTRA()
    Method PostExported()
    Method FindXML()
    Method FindCKODOC()
    Method NewReceipt()
    Method GetDocUpdTra()
EndClass

/*/{Protheus.doc} New
	Método construtor
@author rodrigo.mpontes
@since 14/01/2022
/*/

Method New() Class COMTransmite
    Self:cKeyGrant      := "client_credentials" 
	Self:cKeyScope      := "authorization_api"
	Self:cApiUrlToken   := "/totvs.rac/connect/token" 
    Self:cApiUrlCodFil  := "/api/companies"
    Self:cApiUrlExpNFE  := "/api/mde/exportxmlbatch"
    Self:cApiUrlExpNFS  := "/api/nfserecebida/exportbatch"
    Self:cApiUrlExpCTE  := "/api/cterecebido/exportbatch"
    Self:cApiUrlExpCTO  := "/api/cteosrecebido/exportbatch"
    Self:cApiUrlZipNFE  := "/api/mde/exportbatch/"
    Self:cApiUrlZipNFS  := "/api/nfserecebida/exportxmlbatch/"
    Self:cApiUrlZipCTE  := "/api/cterecebido/exportbatch/"
    Self:cApiUrlZipCTO  := "/api/cteosrecebido/exportbatch/"
    Self:cApiSetExpNFE  := "/api/v2.0/mde/setstatusintegration"
    Self:cApiSetExpNFS  := "/api/nfserecebida/setstatusintegration"
    Self:cApiSetExpCTE  := "/api/cterecebido/setstatusintegration"
    Self:cApiSetExpCTO  := "/api/cteosrecebido/setstatusintegration"
    Self:lSOWin         := !isSrvUnix() //Se é SO Windows
    Self:cThreadId      := AllTrim(Str(ThreadId()))
    Self:cNGIn          := Self:GetParam(1)
    Self:cNGLidos       := Self:GetParam(2)
    Self:cMVXMLTRA      := Self:GetParam(3)
    Self:cMVDOCIMP      := Self:GetParam(4)
    Self:cMVXMLCID      := Self:GetParam(5)
    Self:cMVXMLCSEC     := Self:GetParam(6)
    Self:cMVAPITran     := Self:GetParam(14)
    Self:nDias          := Self:GetParam(7)
    Self:lHistDHY       := Self:GetParam(8)
    Self:cApiToken      := Self:GetParam(9)
	Self:cApiTra	    := Self:GetParam(10)
    Self:lExported      := Self:GetParam(11)
    Self:cDirTransmite  := Self:GetParam(12)
    Self:aExcEdi        := Self:GetParam(13)
    Self:aEdiCOM        := {"109","214","273","319"}
    Self:cLastError     := ''
    Self:lAPIError      := .F.
    Self:aHeaderOut     := {}
    Self:lDHW           := ChkFile("DHW") 
    Self:lDHY           := ChkFile("DHY")
    Self:lDHZ           := ChkFile("DHZ")
    Self:lCKO           := ChkFile("CKO")
    Self:lDHYFil        := Self:lDHY .And. DHY->(FieldPos("DHY_FILTRO")) > 0 .And. DHY->(FieldPos("DHY_TENT")) > 0 .And. DHY->(FieldPos("DHY_DTID")) > 0
    Self:lDHZFil        := Self:lDHZ .And. DHZ->(FieldPos("DHZ_FILTRO")) > 0 .And. DHZ->(FieldPos("DHZ_TENT")) > 0 .And. DHZ->(FieldPos("DHZ_DTID")) > 0 .And. DHZ->(FieldPos("DHZ_DTLID")) > 0
    Self:nTamCod        := TamSX3("DHY_CODFIL")[1]
    Self:nTamTp         := TamSX3("DHY_TPXML")[1]
    Self:nTamId         := TamSX3("DHY_ID")[1]
    Self:nTArqXML       := TamSX3("CKO_ARQXML")[1]
    Self:lCkoRepro      := Self:lCKO .And. CKO->(FieldPos("CKO_DOC")) > 0 .And. CKO->(FieldPos("CKO_SERIE")) > 0 .And. CKO->(FieldPos("CKO_NOMFOR")) > 0 .And. !Empty(SDS->(IndexKey(4)))
    Self:lCkoTra        := Self:lCKO .And. CKO->(FieldPos("CKO_CHVDOC")) > 0 .And. CKO->(FieldPos("CKO_ORIGEM")) > 0 .And. CKO->(FieldPos("CKO_STRAN")) > 0 .And. CKO->(FieldPos("CKO_ERRTRA")) > 0
Return Nil

/*/{Protheus.doc} GetParam
	Parametrização COMTransmite

@author rodrigo.mpontes
@since 14/01/2022
/*/

Method GetParam(nOpc) Class COMTransmite

    Local cBarra		:= If(!Self:lSOWin,"/","\") 
    Local cMVTransmite  := SuperGetMV("MV_TRAXML",.F.,"\transmite\")
    Local cMVNGIn       := SuperGetMV("MV_NGINN",.F.,"\neogrid\in")
    Local cMVNGLidos    := SuperGetMV("MV_NGLIDOS",.F.,"\neogrid\lidos")
    Local cMVDOCIMP     := SuperGetMV("MV_DOCIMP",.F.,"NFE/NFS/CTE")
    Local cMVXMLCID     := SuperGetMV("MV_XMLCID",.F.,"")
    Local cMVXMLCSEC    := SuperGetMV("MV_XMLCSEC",.F.,"")
    Local nMVDIAS       := SuperGetMV("MV_XMLDIAS",.F.,45)
    Local lHistDHY      := SuperGetMV("MV_XMLHIST",.F.,.F.)
    Local lExported     := SuperGetMV("MV_TRAEXP",.F.,.T.)
    Local cMVRet        := ""
    Local nMVRet        := 0
    Local cDir          := ""
    Local xMVRet        := Nil
    Local aDir          := {}
    Local nI            := 0

    If nOpc == 3
        cMVTransmite := Iif(Self:lSOWin,StrTran(cMVTransmite,"/",cBarra),StrTran(cMVTransmite,"\",cBarra))
        cMVRet := Iif(SubStr(cMVTransmite, Len(cMVTransmite)) <> cBarra,cMVTransmite+cBarra,cMVTransmite)
        cMVRet := Iif(SubStr(cMVRet,1,1) <> cBarra,cBarra+cMVRet,cMVRet)
        cMVRet := AllTrim(cMVRet)
        
        cDir := Self:cNGIn + SubStr( cMVRet, 2, Len(cMVRet)-2)

        If !ExistDir(cDir)
            MakeDir(cDir) 
        Endif

        cDirThread := Self:cNGIn + SubStr( cMVRet, 2, Len(cMVRet)) + Self:cThreadId

        If !ExistDir(cDirThread)
            MakeDir(cDirThread) 
        Endif

        cMVRet := cDirThread + cBarra
    Elseif nOpc == 1
        cMVNGIn := Iif(Self:lSOWin,StrTran(cMVNGIn,"/",cBarra),StrTran(cMVNGIn,"\",cBarra))
        cMVRet := Iif(SubStr(cMVNGIn, Len(cMVNGIn)) <> cBarra,cMVNGIn+cBarra,cMVNGIn)
        cMVRet := Iif(SubStr(cMVRet,1,1) <> cBarra,cBarra+cMVRet,cMVRet)
        cMVRet := AllTrim(cMVRet)

        aDir := Separa(cMVRet,cBarra)
        If Len(aDir) > 0
            cDir := ""
            For nI := 1 To Len(aDir)
                If !Empty(aDir[nI])
                    cDir += cBarra + aDir[nI]
                    If !ExistDir(cDir)
                        MakeDir(cDir) 
                    Endif
                Endif
            Next nI
        Endif        
    Elseif nOpc == 2
        cMVNGLidos := Iif(Self:lSOWin,StrTran(cMVNGLidos,"/",cBarra),StrTran(cMVNGLidos,"\",cBarra))
        cMVRet := Iif(SubStr(cMVNGLidos, Len(cMVNGLidos)) <> cBarra,cMVNGLidos+cBarra,cMVNGLidos)
        cMVRet := Iif(SubStr(cMVRet,1,1) <> cBarra,cBarra+cMVRet,cMVRet)
        cMVRet := AllTrim(cMVRet)

        aDir := Separa(cMVRet,cBarra)
        If Len(aDir) > 0
            cDir := ""
            For nI := 1 To Len(aDir)
                If !Empty(aDir[nI])
                    cDir += cBarra + aDir[nI]
                    If !ExistDir(cDir)
                        MakeDir(cDir) 
                    Endif
                Endif 
            Next nI
        Endif 
    Elseif nOpc == 4
        cMVRet := cMVDOCIMP
    Elseif nOpc == 5
        cMVRet := cMVXMLCID
    Elseif nOpc == 6
        cMVRet := cMVXMLCSEC
    Elseif nOpc == 7
        nMvRet := nMVDIAS
    Elseif nOpc == 8
        lMvRet := lHistDHY
    Elseif nOpc == 9
        cMVRet := Iif(Self:cMVAPITran == "production","https://admin.rac.totvs.app",;
                  Iif(Self:cMVAPITran == "staging","https://admin.rac.staging.totvs.app",;
                  Iif(Self:cMVAPITran == "development","https://admin.rac.dev.totvs.app","")))
    Elseif nOpc = 10
        cMVRet := Iif(Self:cMVAPITran == "production","https://api-transmite.totvs.app",;
                  Iif(Self:cMVAPITran == "staging","https://api-transmite.staging.totvs.app",;
                  Iif(Self:cMVAPITran == "development","https://api-transmite.dev.totvs.app","")))
    Elseif nOpc == 11
        lMvRet := lExported
    Elseif nOpc == 12
        cMVTransmite := Iif(Self:lSOWin,StrTran(cMVTransmite,"/",cBarra),StrTran(cMVTransmite,"\",cBarra))
        cDir         := Iif(SubStr(cMVTransmite, Len(cMVTransmite)) <> cBarra,cMVTransmite+cBarra,cMVTransmite)
        cDir         := Iif(SubStr(cDir,1,1) <> cBarra,cBarra+cDir,cDir)
        
        cMVRet := Self:cNGIn + SubStr( cDir, 2, Len(cDir))
    Elseif nOpc == 13
        cMVRet := &(GetNewPar("MV_EXCEDI",'{}'))
    Elseif nOpc == 14
        cMVRet := Lower(SuperGetMV("MV_APITRAN",.F.,"production"))
    Endif

    If nOpc <= 3 .Or. nOpc == 12
        cMVRet := Iif(Self:lSOWin,StrTran(cMVRet,"/",cBarra),StrTran(cMVRet,"\",cBarra))
    Endif

    If nOpc <=6 .Or. nOpc == 9 .Or. nOpc == 10 .Or. nOpc == 12 .Or. nOpc == 13 .Or. nOpc == 14
        xMVRet := cMVRet
    Elseif nOpc == 7 
        xMVRet := nMVRet
    Elseif nOpc == 8 .Or. nOpc == 11
        xMVRet := lMvRet
    Endif

Return xMVRet

/*/{Protheus.doc} TokenTotvsTransmite
	Método para autenticar usuario/senha
@param  lAuth       T = Autenticado / F = Não autenticado

@author rodrigo.mpontes
@since 14/01/2022
/*/

Method TokenTotvsTransmite() Class COMTransmite
    Local aHeader   	As Array
    Local cURL      	As Character
    Local cResource 	As Character
    Local cPostParam    As Character
    Local cTextJson 	As Character
    Local cToken    	As Character
    Local oJsonResp 	As Object
    Local oRest     	As Object
    Local lAuth         As Logical 
    
    lAuth 		:= .F.
    aHeader   	:= {}
    cURL     	:= Self:cApiToken
    
    aHeader := {"Content-Type:application/x-www-form-urlencoded"} 

	cResource 	:= Self:cApiUrlToken
    cPostParam  := 'grant_type='+Self:cKeyGrant+'&client_id='+Self:cMVXMLCID+'&client_secret='+Self:cMVXMLCSEC+'&scope='+Self:cKeyScope

    //Realiza o post de acordo com o cURL e cResource
    oRest := FwRest():New(cURL)
    oRest:SetPath(cResource)
    oRest:SetPostParams(cPostParam)
    oJsonResp := JsonObject():New()

    If lAuth := oRest:Post(aHeader)
        cTextJson := oRest:GetResult() 
		oJsonResp:FromJson(cTextJson)
		cToken := oJsonResp:GetJsonObject("access_token")
		
		//Monta header com token
		Self:aHeaderOut := {}
		aAdd(Self:aHeaderOut, 'Content-Type: application/json; charset=UTF-8')
		aAdd(Self:aHeaderOut, 'Accept: application/json')
		aAdd(Self:aHeaderOut, 'Authorization: Bearer ' + cToken)
        
        Self:LogMessage(cTextJson)
    Else
        cTextJson := oRest:GetResult()
        Self:cLastError := oRest:GetLastError()
        Self:lAPIError := .T.
        
        Self:LogMessage(cTextJson, oRest:GetLastError())
    EndIf

    //-- Limpa objetos da memória
    FreeObj(oJsonResp)
    FreeObj(oRest)
Return lAuth

/*/{Protheus.doc} GetHeader
	Retorna Header para comunicação do API Transmite (NFE/CTE/NFS)

@author rodrigo.mpontes
@since 14/01/2022
/*/

Method GetHeader() Class COMTransmite
	
	Local aHeader	As Array

	aHeader := {}
	aAdd(aHeader, Self:aHeaderOut[1])
	aAdd(aHeader, Self:aHeaderOut[2])
	aAdd(aHeader, Self:aHeaderOut[3])

Return aHeader

/*/{Protheus.doc} GetCodigoFilial
	Busca Id empresa no Transmite

@param  cTpXML      Tipo XML (NFE/CTE/NFS)
@param  aHeader     Header para comunicação API

@author rodrigo.mpontes
@since 14/01/2022
/*/

Method GetCodigoFilial(cCGC,cIE,cUF,cEmp,cFil) Class COMTransmite

    Local cRetId        As Character
    Local cUrl          As Character
    Local aHeader   	As Array
    Local cResource 	As Character
    Local cTextJson 	As Character
    Local oJsonResp 	As Object
    Local oRest     	As Object
    
    cUrl        := Self:cApiTra
    cGetParam   := "?$filter=CpfCnpj eq '" + AllTrim(cCGC) + "' and IE eq '" + AllTrim(cIE) + "'&$select=CodigoFilial
    cGetParam   := StrTran(cGetParam," ","%20")
    cResource   := Self:cApiUrlCodFil + cGetParam
    aHeader	    := Self:GetHeader()

    oRest 	:= FwRest():New(cURL)
    oRest:SetPath(cResource)
    
    oJsonResp := JsonObject():New() 
    
    If oRest:Get(aHeader)
        cTextJson := oRest:GetResult()
        cTextJson   := StrTran(cTextJson,"[","")
        cTextJson   := StrTran(cTextJson,"]","")
        oJsonResp:FromJson(cTextJson)
        cRetId := oJsonResp:GetJsonObject("CodigoFilial")
    Else
		cTextJson := oRest:GetResult()
		Self:cLastError := oRest:GetLastError()
		Self:lAPIError := .T.
		
		Self:LogMessage(cTextJson, oRest:GetLastError())
	EndIf
     
Return cRetId

/*/{Protheus.doc} LogMessage
	Registra mensagem de log

@param  cJson       Texto formato JSON
@param  cMessage    Texto

@author rodrigo.mpontes
@since 14/01/2022
/*/

Method LogMessage(cJson, cMessage) Class COMTransmite
    Default cJson := ''
    Default cMessage := ''

    FWLogMsg('WARN',, 'COMTransmite', FunName(), '', '01', 'COMTransmite:JSON: ' + cJson + ' COMTransmite:MSG: ' + cMessage, 0, 0, {})

    If FWIsInCallStack( "ImpTraTool" ) .And. FWIsInCallStack( "ColAutoRead" )
        cImpTraTool += 'COMTransmite:JSON: ' + cJson + CRLF
        cImpTraTool += 'COMTransmite:MSG: ' + cMessage + CRLF + CRLF
        oF1MG1:Refresh()
    Endif
Return Nil

/*/{Protheus.doc} CleanUp
	Limpa e move arquivos

@author rodrigo.mpontes
@since 14/01/2022
/*/

Method CleanUp(nOpc,aXML,cZip,nApaga) Class COMTransmite
    Local nI        As Numeric
    Local nZ        As Numeric
    Local aFiles    As Array
    Local aFiles2   As Array

    Default nApaga := 0

    If nOpc == 1 //Move arquivos da pasta IN para Lidos
        For nI := 1 To Len(aXML)
            If File(Self:cNGIn + aXML[nI,1])
                ( __CopyFile(Self:cNGIn+aXML[nI,1], Self:cNGLidos+aXML[nI,1],,,Self:lSOWin))
                FErase( Self:cNGIn+aXML[nI,1],,Self:lSOWin)
            Endif
        Next nI
    Elseif nOpc == 2 //Exclui arquivos importados via transmite
        If nApaga == 0
            For nI := 1 To Len(aXML)
                If File(Self:cMVXMLTRA + aXML[nI,1])
                    FErase( Self:cMVXMLTRA+aXML[nI,1],,Self:lSOWin)
                Endif
            Next nI

            FErase(cZip)
        Endif

        If nApaga == 1
            DirRemove(Self:cMVXMLTRA)
        Endif
    Elseif nOpc == 3
        aFiles  := {}
        aFiles2 := {}
        aFiles  := Directory(Self:cDirTransmite + "*.*", "D")

        If Len(aFiles) > 0
            For nI := 1 To Len(aFiles)
                If Val(aFiles[nI,1]) > 0 .And. aFiles[nI,5] == "D" .And. aFiles[nI,3] < dDataBase
                    If !DirRemove(Self:cDirTransmite+aFiles[nI,1])
                        aFiles2 := Directory(Self:cDirTransmite+aFiles[nI,1] + "\*.*", "D")
                        If Len(aFiles2) > 0
                            For nZ := 1 To Len(aFiles2)
                                If aFiles2[nZ,5] == "A"
                                    FErase(Self:cDirTransmite+aFiles[nI,1]+"\"+aFiles2[nZ,1])
                                Endif
                            Next nZ
                            DirRemove(Self:cDirTransmite+aFiles[nI,1])
                        Endif
                    Endif
                Endif
            Next nI
        Endif
        FwFreeArray(aFiles)
        FwFreeArray(aFiles2)
    Endif

    If nApaga == 2
        FwFreeArray(Self:aHeaderOut)
    Endif
Return Nil

/*/{Protheus.doc} XMLINLIDOS
	Busca XMLs a serem importador para CKO na pasta IN/Lidos

@author rodrigo.mpontes
@since 14/01/2022
/*/

Method XMLINLIDOS() Class COMTransmite
	
	Local aFiles	As Array
    Local aSizes	As Array
    Local aDatas	As Array
    Local aHoras	As Array
    Local aRet      As Array
    Local nI        As Numeric
	
    aRet    := {}
    aFiles  := {}
    
    Self:FindXML(Self:cNGIn,@aFiles,@aSizes,@aDatas,@aHoras)
    
    If Len(aFiles) > 0
        Self:LogMessage("","Lendo XMLs da pasta IN") 
        For nI := 1 To Len(aFiles)
            aAdd(aRet,{aFiles[nI],aDatas[nI],aHoras[nI]})
        Next nI

        If Len(aRet) > 0
            Self:LogMessage("","Gravando XMLs")
            Self:PostXMLCKO(aRet,"IN")

            Self:LogMessage("","Movendo arquivos da IN para Lidos")
            Self:Cleanup(1,aRet)
        Endif
    Endif

Return

/*/{Protheus.doc} FindXML
	Busca XMLs

@author rodrigo.mpontes
@since 14/01/2022
/*/

Method FindXML(cDir,aFiles,aSizes,aDatas,aHoras) Class COMTransmite

Local nI        := 1
Local nZ        := 0
Local aExt      := {".XML",".xml",".Xml",".xMl",".xmL",".XMl",".XmL",".xML"}
Local aDocXML   := {}

Default aFiles := {}
Default aSizes := {}
Default aDatas := {}
Default aHoras := {}

For nI := 1 To Len(aExt)
    aDocXML := Directory(cDir+"*.*","D")

    For nZ := 1 To Len(aDocXML)
        If aDocXML[nZ,5] == "A" .and. aExt[nI] $ SubStr(aDocXML[nZ,1],aT(".",aDocXML[nZ,1]),Len(aDocXML[nZ,1]))
            aAdd(aFiles,aDocXML[nZ,1])
            aAdd(aSizes,aDocXML[nZ,2])
            aAdd(aDatas,aDocXML[nZ,3])
            aAdd(aHoras,aDocXML[nZ,4])
        Endif
    Next nZ

    If Len(aFiles) > 0
        Exit
    Endif
Next nI

RETURN

/*/{Protheus.doc} XMLTRANSMITE
	Busca XMLs a serem importador atraves do Transmite para CKO

@author rodrigo.mpontes
@since 14/01/2022
/*/

Method XMLTRANSMITE() Class COMTransmite
	
	Local cResource	As Character
	Local cDtTempo	As Character
    Local cZip      As Character
    Local cRetorno  As Character
    Local oJsonResp As Object
    Local oRest     As Object
	Local aHeader	As Array
	Local nI		As Numeric
    Local nY        As Numeric
    Local nZ        As Numeric
    Local nStatus   As Numeric
    Local aCodFil   As Array
    Local aTpXml	As Array
    Local aIdCodFil As Array
    
    Local xRetorno  := NIL
    Local xStatus   := NIL
    Local xMessage  := Nil

    aTpXml := {}
    Self:LogMessage("","Verifica quais XML serão importados (NFE/NFS/CTE)")
    If "NFE" $ Self:cMVDOCIMP
        aAdd(aTpXML,{"NFE",Self:cApiUrlExpNFE,Self:cApiUrlZipNFE})
    Endif
    If "NFS" $ Self:cMVDOCIMP
        aAdd(aTpXML,{"NFS",Self:cApiUrlExpNFS,Self:cApiUrlZipNFS})
    Endif
    If "CTE" $ Self:cMVDOCIMP
        aAdd(aTpXML,{"CTE"  ,Self:cApiUrlExpCTE,Self:cApiUrlZipCTE})
        aAdd(aTpXML,{"CTEOS",Self:cApiUrlExpCTO,Self:cApiUrlZipCTO})
    Endif

    Self:LogMessage("","Verifica quais filiais estão configuradas com o Transmite")
    aCodFil := Self:GetCodFilDHW()

    If Len(aCodFil) > 0
        Self:LogMessage("","Busca Ids de exportação dos XML")
        Self:GetIdsExpXML(aTpXML,aCodFil)

        oRest 	:= FwRest():New(Self:cApiTra)
        aHeader	:= Self:GetHeader()
        
        For nI := 1 To Len(aCodFil) 
            For nY := 1 To Len(aTpXML)
                Self:LogMessage("","Busca recibos para Filial | Tipo XML: " + aCodFil[nI] + " | " + aTpXML[nY,1])
                aIdCodFil := Self:GetIdDHY(aCodFil[nI],aTpXML[nY,1])

                If Len(aIdCodFil) > 0
                    For nZ := 1 To Len(aIdCodFil)
                        Self:LogMessage("","Lendo recibo da Filial | Tipo XML: " + aIdCodFil[nZ])
                        oJsonResp := JsonObject():New()
                        cResource := aTpXml[nY,3] + aIdCodFil[nZ]
                        oRest:SetPath(cResource) 

                        cRetorno    := ""
                        nStatus     := 0
                        If oRest:Get(aHeader)
                            cTextJson := oRest:GetResult() 
                            oJsonResp:FromJson(cTextJson)
                            xRetorno    := oJsonResp:GetJsonObject("Retorno")
                            cRetorno    := Iif(ValType(xRetorno)=="C",xRetorno,oJsonResp:GetJsonObject("retorno"))

                            xStatus     := oJsonResp:GetJsonObject("Status")
                            nStatus     := Iif(ValType(xStatus)=="N",xStatus,oJsonResp:GetJsonObject("status"))

                            xMessage     := oJsonResp:GetJsonObject("Descricao")
			                cMessage     := Iif(ValType(xMessage)=="C",xMessage,oJsonResp:GetJsonObject("descricao"))
                            
                            cDtTempo := DtoS(Date())+StrTran(Time(),":","")
                            
                            If nStatus > 0
                                If nStatus == 1 .And. !Empty(cRetorno) //Recibo com retorno (tem XMLs)
                                    Self:LogMessage("","Descompacta XML do Id: " + aIdCodFil[nZ])
                                    cZip  := Self:GetZIP(cRetorno,aTpXML[nY,1],cDtTempo) //Gerar arquivo ZIP
                                    If !Empty(cZip) //Entra somente se foi criado o arquivo ZIP
                                        Self:LogMessage("","Gravando XMLs na CKO do Id: " + aIdCodFil[nZ])
                                        If Self:GetXML(cZip) //Entra somente se houver arquivos XML descompactados e atualiza status
                                            Self:LogMessage("","Atualiza status Id: " + aIdCodFil[nZ])
                                            Self:PostStatusDHY(aCodFil[nI],aTpXML[nY,1],aIdCodFil[nZ],nStatus)
                                        Endif
                                    Endif
                                Elseif nStatus == 1 .And. Empty(cRetorno)
                                    Self:LogMessage("","Recibo sem retorno: " + cMessage)
                                    Self:LogMessage("","Atualiza status Id: " + aIdCodFil[nZ])
                                    Self:PostStatusDHY(aCodFil[nI],aTpXML[nY,1],aIdCodFil[nZ],nStatus)
                                Endif
                            Elseif nStatus == 0
                                Self:LogMessage("","Atualiza status Id (Aguardando): " + aIdCodFil[nZ])
                                Self:PostStatusDHY(aCodFil[nI],aTpXML[nY,1],aIdCodFil[nZ],nStatus)
                            Endif
                            
                            Self:LogMessage(cTextJson)
                        Else
                            cTextJson := oRest:GetResult()
                            Self:cLastError := oRest:GetLastError()
                            Self:lAPIError := .T.
                            
                            Self:LogMessage(cTextJson, "Erro ao consultar recibo: " + oRest:GetLastError())
                            Exit
                        EndIf

                    Next nZ
                Endif
            Next nY
        Next nI

        Self:LogMessage("","Apaga Id/Historico") 
        Self:HistDHYDHZ() 
    Endif
    
    Self:LogMessage("","Apaga pasta com numero da Thread")
    Self:Cleanup(2,,,1)
    Self:Cleanup(3)
    
Return

/*/{Protheus.doc} HistDHYDHZ
	Grava Id gerados na DHZ como historico

@author rodrigo.mpontes
@since 14/01/2022
/*/

Method HistDHYDHZ() Class COMTransmite

Local cQry      := ""
Local cQryStat  := ""
Local cAliTmp   := ""

Self:LogMessage("","Backup DHY / DHZ")
If Self:lDHZ .And. Self:lHistDHY
    cAliTmp := GetNextAlias()

    If oUpdDHZ == Nil
        oUpdDHZ := FWPreparedStatement():New()

        cQry := " SELECT DHY_CODFIL, DHY_TPXML, DHY_ID, DHY_STATUS"
        If Self:lDHYFil .And. Self:lDHZFil
            cQry += " , DHY_FILTRO, DHY_DTID, DHY_TENT"
        Endif
        cQry += " FROM " + RetSqlName("DHY")
        cQry += " WHERE D_E_L_E_T_ = ' '"
        cQry += " AND DHY_STATUS <> '0'"
        cQry := ChangeQuery(cQry)

        oUpdDHZ:SetQuery(cQry)
    Endif

    cQryStat := oUpdDHZ:GetFixQuery()
    MpSysOpenQuery(cQryStat,cAliTmp)
    
    DbSelectArea("DHZ")
    DHZ->(DbSetOrder(1))

    While (cAliTmp)->(!EOF())
        If !DHZ->(MsSeek(xFilial("DHZ") + PadR((cAliTmp)->DHY_CODFIL,Self:nTamCod) + PadR((cAliTmp)->DHY_TPXML,Self:nTamTp) + PadR((cAliTmp)->DHY_ID,Self:nTamId)))
            If DHZ->(RecLock("DHZ",.T.))
                DHZ->DHZ_FILIAL := xFilial("DHZ")
                DHZ->DHZ_CODFIL := (cAliTmp)->DHY_CODFIL
                DHZ->DHZ_TPXML  := (cAliTmp)->DHY_TPXML
                DHZ->DHZ_ID     := (cAliTmp)->DHY_ID
                DHZ->DHZ_STATUS := (cAliTmp)->DHY_STATUS

                If Self:lDHYFil .And. Self:lDHZFil
                    DHZ->DHZ_FILTRO := (cAliTmp)->DHY_FILTRO
                    DHZ->DHZ_TENT   := (cAliTmp)->DHY_TENT
                    DHZ->DHZ_DTID   := StoD((cAliTmp)->DHY_DTID)
                    DHZ->DHZ_DTLID  := dDataBase
                Endif
                DHZ->(MsUnlock())
            Endif
        Endif
        (cAliTmp)->(DbSkip())
    Enddo

    (cAliTmp)->(DbCloseArea())
Endif

Self:LogMessage("","Apaga Ids ja lidos ou com erro")
cQry := " DELETE FROM " + RetSqlName("DHY")
cQry += " WHERE D_E_L_E_T_ = ' '"

If !Self:lDHYFil
    cQry += " AND DHY_STATUS <> '0'"
Else
    cQry += " AND (DHY_STATUS <> '0' OR (DHY_STATUS = '0' AND DHY_DTID < '" + DtoS(dDatabase-5) + "'))"
Endif

TcSqlExec(cQry)

Return

/*/{Protheus.doc} GetZIP
	Decodifica BASE64 e gera arquivo ZIP

@param  cMsg    Base64
@param  cTpXML  Tipo documento (NFE/CTE/NFS)
@param  cIdZip  Id arquivo ZIP

@author rodrigo.mpontes
@since 14/01/2022
/*/

Method GetZIP(cMsg,cTpXML,cIdZip) Class COMTransmite
	
	Local cArq		As Character
	Local cFileZip	As Character

    cArq := Self:cMVXMLTRA + "descompacta_"+Lower(cTpXML)+"_"+cIdZip+".zip"
    
    Self:LogMessage("","Decode arquivo: " + cArq)
	cFileZip	:= Decode64( cMsg , cArq , .T.)
  
Return cArq

/*/{Protheus.doc} GetXML
	Busca XMLs pelo Transmite e/ou pela pasta IN

@param  nOpc    1 = Descompacta Base64 / 2 = Pasta IN

@author rodrigo.mpontes
@since 14/01/2022
/*/

Method GetXML(cZip) Class COMTransmite
	
	Local aRet      As Array
    Local aFiles	As Array
    Local aSizes	As Array
    Local aDatas	As Array
    Local aHoras	As Array
	Local nI		As Numeric
    Local lRet      := .F.

    aRet := {}
    Self:LogMessage("","Descompactando XMLs")
    FUnZip(cZip,Self:cMVXMLTRA)
    
    Self:FindXML(Self:cMVXMLTRA,@aFiles,@aSizes,@aDatas,@aHoras) 
    
    If Len(aFiles) > 0
        lRet := .T.
        Self:LogMessage("","Lendo XMLs da Transmite")
        For nI := 1 To Len(aFiles)
            aAdd(aRet,{aFiles[nI],aDatas[nI],aHoras[nI]})
        Next nI

        If Len(aRet) > 0
            Self:LogMessage("","Gravando XMLs")
            Self:PostXMLCKO(aRet,"TR")

            Self:LogMessage("","Movendo arquivos da IN para Lidos")
            Self:Cleanup(2,aRet,cZip)
        Endif
    Endif

Return lRet

/*/{Protheus.doc} PostStatusDHY
Atualiza status do ID lido

@param  cCodFil Codigo Filial (DHW_CODFIL)
@param  cTpXML  Tipo XML (NFE/NFS/CTE)
@param  cId     Id da transação
@param  nStatus 1-Ok / 2-Erro
    
@author rodrigo.mpontes
@since 14/01/2022
/*/

Method PostStatusDHY(cCodFil,cTpXML,cId,nStatus) Class COMTransmite

If Self:lDHY
    DbSelectArea("DHY")
    DHY->(DbSetOrder(1)) 
    If DHY->(MsSeek(xFilial("DHY") + PadR(cCodFil,Self:nTamCod) + PadR(cTpXML,Self:nTamTp) + Padr(cId,Self:nTamId)))
        If RecLock("DHY",.F.)
            DHY->DHY_STATUS := AllTrim(Str(nStatus))
            If Self:lDHYFil
                DHY->DHY_TENT := DHY->DHY_TENT + 1

                If Empty(DHY->DHY_DTID)
                    DHY->DHY_DTID := dDataBase
                Endif
            Endif
            DHY->(MsUnlock())
        Endif
    Endif
Endif

Return

/*/{Protheus.doc} GetIdDHY
Busca Ids não importados

@param  cCodFil Codigo Filial (DHW_CODFIL)
@param  cTpXML  Tipo XML (NFE/NFS/CTE)
    
@author rodrigo.mpontes
@since 14/01/2022
/*/

Method GetIdDHY(cCodFil,cTpXML) Class COMTransmite

    Local cQry      As Character
    Local cAliTmp   As Character
    Local aRet      As Array

    aRet := {}
    If Self:lDHY

        cAliTmp := GetNextAlias()

        cQry := " SELECT DHY_ID FROM " + RetSqlName("DHY")
        cQry += " WHERE D_E_L_E_T_ = ' '"
        cQry += " AND DHY_CODFIL = '" + cCodFil + "'"
        cQry += " AND DHY_TPXML = '" + cTpXML + "'"
        cQry += " AND DHY_STATUS = '0'"
        
        cQry := ChangeQuery(cQry)
	    dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQry),cAliTmp,.T.,.T.)

        While (cAliTmp)->(!EOF())
            Self:LogMessage("","Recibos a serem lidos da Filial|Tipo XML: " + (cAliTmp)->DHY_ID)
            aAdd(aRet,(cAliTmp)->DHY_ID)
            (cAliTmp)->(DbSkip()) 
        Enddo
    Endif

Return aRet

/*/{Protheus.doc} GetIdsExpXML
Busca Ids não importados

@param  aTpXML  Tipo XML (NFE/NFS/CTE)
@param  aCodFil Codigo Filial (DHW_CODFIL)
    
@author rodrigo.mpontes
@since 14/01/2022
/*/

Method GetIdsExpXML(aTpXML,aCodFil) Class COMTransmite

    Local nI        As Numeric
    Local nY        As Numeric
    Local oRestPost As Object
    Local oJsonResp As Object
    Local cResource As Character
    Local aIdCodFil As Array
    Local cDataIni  As Character
    Local cDataFim  As Character
    Local cExp      As Character
    Local cExpOrd   As Character
    Local nMes      As Numeric
    Local nYear     As Numeric
    Local nDay      As Numeric
    Local dDataIni  As Date
    Local cFiltro   As Character
    Local cCnpjTom  As Character

    dDataIni    := dDatabase - Self:nDIAS
    nMes        := Month(dDataIni)
    nYear       := Year(dDataIni)
    nDay        := Day(dDataIni)
    cDataIni    := AllTrim(Str(nYear)) + "-" + AllTrim(StrZero(nMes,2)) + "-" + AllTrim(StrZero(nDay,2))  +"T00:00:00"
    
    nMes        := Month(dDatabase)
    nYear       := Year(dDatabase)
    nDay        := Day(dDatabase)
    cDataFim    := AllTrim(Str(nYear)) + "-" + AllTrim(StrZero(nMes,2)) + "-" + AllTrim(StrZero(nDay,2))  +"T23:59:59"

    aHeader     := Self:GetHeader()
    
    //Operador ge = Maior ou igual
    //Operador gt = Maior
    //Operador le = Menor ou igual
    //Operador lt = Menor 
    
    aIdCodFil := {} 
    cFiltro   := "" 
    For nI := 1 To Len(aCodFil)
        For nY := 1 To Len(aTpXML)

            If aTpXML[nY,1] == "NFE"
                cExp    := "DhEmi ge '" + cDataIni + "' and DhEmi le '" + cDataFim + "'"
                cExpOrd := "DhEmi"
            ElseIf aTpXML[nY,1] == "NFS"
                cExp    := "DataEmissao ge '" + cDataIni + "' and DataEmissao le '" + cDataFim + "'"
                cExpOrd := "DataEmissao"
            ElseIf aTpXML[nY,1] == "CTE" .Or. aTpXML[nY,1] == "CTEOS"
                cExp    := "Emissao ge '" + cDataIni + "' and Emissao le '" + cDataFim + "'"
                cExpOrd := "Emissao"

                cCnpjTom    := GetAdvFVal("DHW","DHW_CGC",xFilial("DHW") + aCodFil[nI],2)
                If !Empty(cCnpjTom)
                    cExp += " and CpfCnpjTomador eq '" + cCnpjTom + "'"
                Endif
            Endif

            cIdMsg      := "" 
            oRestPost 	:= FwRest():New(Self:cApiTra)
            If Self:lExported
                cResource   := aTpXML[nY,2] + "?$filter=CodigoFilial eq '" + aCodFil[nI] + "' and " + cExp + " and IntegracaoERP eq 'Pendente' &$orderby=" + cExpOrd + " desc,Numero desc,Serie asc"
                cFiltro     := "CodigoFilial eq '" + aCodFil[nI] + "' and " + cExp + " and IntegracaoERP eq 'Pendente'
            Else
                cResource   := aTpXML[nY,2] + "?$filter=CodigoFilial eq '" + aCodFil[nI] + "' and " + cExp + " and &$orderby=" + cExpOrd + " desc,Numero desc,Serie asc"
                cFiltro     := "CodigoFilial eq '" + aCodFil[nI] + "' and " + cExp
            Endif
            cResource   := StrTran(cResource," ","%20")

            If Self:NewReceipt(aTpXML[nY,1],cFiltro) 
                oJsonResp := JsonObject():New()  
                oRestPost:SetPath(cResource)

                Self:LogMessage("","Solicitando novo recibo ao Transmite")
                If oRestPost:Post(aHeader)  
                    cTextJson := oRestPost:GetResult() 
                    oJsonResp:FromJson(cTextJson)
                    cIdMsg := oJsonResp:GetJsonObject("receipt") 

                    If !Empty(cIdMsg)  
                        aAdd(aIdCodFil,{aCodFil[nI],aTpXML[nY,1],cIdMsg,cFiltro})
                        Self:LogMessage("","Novo recibo: " + cIdMsg + " - " + aTpXML[nY,1] + " - " + aCodFil[nI])
                    Endif
                Else
                    cTextJson := oRestPost:GetResult()
                    Self:cLastError := oRestPost:GetLastError()
                    Self:lAPIError := .T.
                    
                    Self:LogMessage(cTextJson, "Erro ao solicitar novo recibo: " + oRestPost:GetLastError())
                EndIf
            Endif
        Next nY
    Next nI

    If Len(aIdCodFil) > 0 .And. Self:lDHY
        Self:LogMessage("","Grava Ids de exportação dos XML")
        Self:GrvIdDHY(aIdCodFil)
    Endif
Return

/*/{Protheus.doc} GrvIdDHY
Busca Ids não importados

@param  aIdCodFil   Id transação
    
@author rodrigo.mpontes
@since 14/01/2022
/*/

Method GrvIdDHY(aIdCodFil) Class COMTransmite

    Local nI        As Numeric
    
    DbSelectArea("DHY")
    DHY->(DbSetOrder(1))
    For nI := 1 To Len(aIdCodFil)
        If !DHY->(MsSeek(xFilial("DHY") + PadR(aIdCodFil[nI,1],Self:nTamCod) + PadR(aIdCodFil[nI,2],Self:nTamTp) + PadR(aIdCodFil[nI,3],Self:nTamId)))
            If RecLock("DHY",.T.)
                DHY->DHY_FILIAL := xFilial("DHY")
                DHY->DHY_CODFIL := aIdCodFil[nI,1]
                DHY->DHY_TPXML  := aIdCodFil[nI,2]
                DHY->DHY_ID     := aIdCodFil[nI,3]
                If Self:lDHYFil
                    DHY->DHY_DTID   := dDataBase
                    DHY->DHY_TENT   := 0
                    DHY->DHY_FILTRO := aIdCodFil[nI,4]
                Endif
                DHY->DHY_STATUS := "0"
                DHY->(MsUnlock())
            Endif
            Self:LogMessage("","Gravado Ids: " + aIdCodFil[nI,3] + " - " + aIdCodFil[nI,2] + " - " + aIdCodFil[nI,1])
        Endif
    Next nI
Return

/*/{Protheus.doc} GetCodFilDHW
	Busca Id empresa na DHW

@author rodrigo.mpontes
@since 14/01/2022
/*/

Method GetCodFilDHW() Class COMTransmite

    Local aRetId        As Array
    Local cQry          As Character
    Local cAliTmp       As Character
    
    aRetId := {}
    If Self:lDHW

        cAliTmp := GetNextAlias()

        cQry := " SELECT DHW_CODFIL FROM " + RetSqlName("DHW")
        cQry += " WHERE D_E_L_E_T_ = ' '"
        cQry += " AND DHW_CODFIL <> ''"
        cQry += " GROUP BY DHW_CODFIL"

        cQry := ChangeQuery(cQry)
	    dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQry),cAliTmp,.T.,.T.)

        While (cAliTmp)->(!EOF())
            Self:LogMessage("","Adicionando Filial: " + (cAliTmp)->DHW_CODFIL)
            aAdd(aRetId,(cAliTmp)->DHW_CODFIL)
            (cAliTmp)->(DbSkip()) 
        Enddo
    Endif
    
Return aRetId

/*/{Protheus.doc} PostXMLCKO
	Grava XMLs na tabela CKO

@param  aXML    XMLs a serem importados
@param  cOpc    Modo de importação (IN - Pasta IN / TR - Transmite)

@author rodrigo.mpontes
@since 14/01/2022
/*/

Method PostXMLCKO(aXML,cOpc) Class COMTransmite
	
    Local nI        As Numeric
    Local cXML      As Character
    Local cFile     As Character
    Local cFileNew  As Character
    Local lNewReg	As Logical
    Local lGrvCKO	As Logical
    Local aCKODados	As Array
    Local cDocXML   As Character
    Local cSerXML   As Character
    Local cNomXML   As Character
    Local cChvXML   As Character
    Local aFindCKO  As Array

    lNewReg	    := .T.
    lGrvCKO	    := .T.
    aCKODados	:= {}
    
    For nI := 1 To Len(aXML)
        lGrvCKO	    := .T.
        cFile       := aXML[nI,1]
        lNewReg     := .T.
        aFindCKO    := {}

        Self:LogMessage("","Lendo XML: " + cFile)
    	cXML := Self:GetConvFile(cFile)  

        If !Empty(cXML)
            Self:LogMessage("","Convertendo arquivo XML com nomenclatura 109/214/273/319")
            cFileNew := Self:GetConvXML(cXML,cFile)
            
            Self:LogMessage("","Arquivo XML convertido: " + cFileNew)
            Self:LogMessage("","Verificando se XML ja gravado CKO")

            CKO->(dbSetorder(1))
            If CKO->(MsSeek(cFileNew))
                lNewReg	:= .F.
                lGrvCKO := Iif(CKO->CKO_FLAG<>'1',.T.,.F.) 	
            Endif

            Self:LogMessage("","Verificando se XML pertence ao COM (109/214/273/319)")
            // Verifica se tipo de XML está configurado para ser importado
            If !Empty(Self:aEdiCOM)
                If aScan(Self:aEdiCOM,{|x| AllTrim(x) == AllTrim(SubStr(cFileNew,1,3))}) == 0
                    lGrvCKO := .F.
                Endif
            Endif

            Self:LogMessage("","Verificando se XML pertence a alguma exceção")
            // Verifica se tipo de XML não está configurado como excessão de importação
            If !Empty(Self:aExcEdi)
                If aScan(Self:aExcEdi,{|x| AllTrim(x) == AllTrim(SubStr(cFileNew,1,3))}) > 0
                    lGrvCKO := .F.
                EndIf
            EndIf

            If lGrvCKO
                If Self:lCkoTra //Busca Chave DOC
                    aCKODados := Self:GetDadosXML(cXML,3)
                    If Len(aCKODados) > 0
                        cChvXML	:= aCKODados[1]
                    Endif
                Endif

                If Self:lCkoRepro 
                    aCKODados := Self:GetDadosXML(cXML,1)
                    If Len(aCKODados) > 0
                        cDocXML	:= aCKODados[1]
                        cSerXML	:= aCKODados[2]
                        cNomXML	:= aCKODados[3]
                    Endif
                Endif
                If lNewReg
                    aFindCKO := Self:FindCKODOC(cChvXML,cDocXML,cSerXML,cNomXML)
                    If !Empty(aFindCKO[1]) //Encontrou CKO
                        cFileNew := aFindCKO[1]
                        lNewReg  := .F.
                        lGrvCKO := Iif(aFindCKO[2]<>'1',.T.,.F.)
                        If lGrvCKO
                            CKO->(MsSeek(cFileNew))
                        Endif 	
                    Endif 
                Endif
            Endif

            If lGrvCKO 
                Self:LogMessage("","Gravando CKO")
                cEDI := SubStr(cFileNew,1,3) 
                cFileNew := PadR(Lower(cFileNew),Len(CKO->CKO_ARQUIV))

                Begin Transaction
                    
                    IF RecLock("CKO",lNewReg) 
                        CKO->CKO_ARQUIV	:= cFileNew
                        CKO->CKO_CODEDI	:= cEDI
                        CKO->CKO_XMLRET	:= cXML
                        CKO->CKO_DT_RET	:= aXML[nI,2] //Data do arquivo
                        CKO->CKO_HR_RET	:= aXML[nI,3] //Hora do arquivo
                        CKO->CKO_DT_IMP	:= Date() //Data da importacao pelo Schedule
                        CKO->CKO_HR_IMP	:= Time() //Hora da importacao pelo Schedule
                        CKO->CKO_STATUS	:= ColCKOStatus()[2][1]
                        CKO->CKO_DESSTA	:= ColCKOStatus()[2][2]
                        CKO->CKO_FLAG	:= "0"
                        CKO->CKO_ARQXML := cFile 
                        
                        //Gravação Documento/Serie/Nome fornecedor
                        If Self:lCkoRepro 
                            CKO->CKO_DOC	:= cDocXML
                            CKO->CKO_SERIE	:= cSerXML
                            CKO->CKO_NOMFOR	:= cNomXML
                        Endif

                        //Gravação Empresa/Filial
                        aCKODados := Self:GetDadosXML(cXML,2)
                        If Len(aCKODados) > 0
                            CKO->CKO_EMPPRO	:= aCKODados[1]
                            CKO->CKO_FILPRO	:= aCKODados[2]
                        Endif

                        //Gravção Chave do documento
                        If Self:lCkoTra
                            CKO->CKO_CHVDOC	:= cChvXML
                            If cOpc == "TR"
                                CKO->CKO_ORIGEM := "TRANSMITE"
                            Elseif cOpc == "IN"
                                CKO->CKO_ORIGEM := "IMP-IN"
                            Endif
                            If lNewReg .Or. Empty(CKO->CKO_STRAN)
                                CKO->CKO_STRAN  := "1"
                            Endif
                        Endif
                        CKO->( msUnlock() ) 
                    Endif
                                
                End Transaction
            Endif

        Endif

    Next nI
Return

/*/{Protheus.doc} GetConvFile
	Converte arquivo XML em cXML

@param  cFile    XML convertido

@author rodrigo.mpontes
@since 14/01/2022
/*/

Method GetConvFile(cFile) Class COMTransmite

Local cLine	:= ""
Local cXML  := ""
Local nArq  := 0

nArq := FT_FUse( Self:cNGIn + cFile )
If nArq < 0
    nArq := FT_FUse( Self:cMVXMLTRA + cFile )    
Endif

If nArq >= 0 

	cLine	:= ""
	cXml	:= ""
		
	While !FT_FEof() 
		cLine := FT_FReadLn()
		If ( Len(cLine) < 1023 )
			cXml += Alltrim(cLine)
		Else
			cLine := ""
			While .T.
				If ( Len(FT_fReadLn()) < 1023 )
					cLine	+= FT_FReadLn()
					cXml	+= cLine 
					Exit
				Else
					cLine += FT_FReadLn() 	 			
					FT_FSkip() 
				Endif
			Enddo
		Endif
		FT_FSkip()
	Enddo
	
	//-- Fecha o arquivo aberto
	FT_FUSE()
	
	If "ObsContxCampo" $ cXML
		cXml := StrTran(cXml,"ObsContxCampo","ObsCont xCampo")
	Endif
	 	 
	If "ReferenceURI" $ cXml
		cXml := StrTran(cXml,"ReferenceURI","Reference URI") 
	Endif
				
Endif
	
Return cXML 

/*/{Protheus.doc} GetConvXML
	Converte arquivo XML para nomenclatura a ser importada

@param  cXML    XML convertido
@param  cFile   Nome do arquivo

@author rodrigo.mpontes
@since 14/01/2022
/*/

Method GetConvXML(cXML,cFile) Class COMTransmite
    
    Local nPosPesq	:= 0
    Local cXMLEncod	:= ""
    Local cError	:= ""
    Local cWarning	:= ""
    Local cCodEdi	:= ""
    Local aArea		:= GetArea()
    local oFullXML	:= Nil

    If SubStr(cXml,1,1) != "<"
        nPosPesq := At("<",cXml)
        cXml  := SubStr(cXml,nPosPesq,Len(cXml))		// Remove caracteres estranhos antes da abertura da tag inicial do arquivo
    EndIf

    cXMLEncod := EncodeUtf8(cXml)

    If Empty(cXMLEncod)
        cXMLEncod 	:= cXml
        cXml 		:= A140IRemASC(cXMLEncod)
        cXMLEncod 	:= EncodeUtf8(cXml)
    EndIf

    If !Empty(cXMLEncod)
        oFullXML := XmlParser(cXMLEncod,"_",@cError,@cWarning)
    EndIf

    //Verificar com Transmite sobre UTF16(somente NFS está vindo com problema)
    If ValType(oFullXML) <> "O"
        cXMLEncod 	:= cXml
        cXml 		:= A140IRemASC(cXMLEncod)
        cXMLEncod 	:= EncodeUtf16(cXml)

        If !Empty(cXMLEncod)
            oFullXML := XmlParser(cXMLEncod,"_",@cError,@cWarning)
        Endif
    Endif

    //Verifica se estar importando uma NFE ou CTE
    If ValType(oFullXML) == "O"
        Do Case
            Case ValType(XmlChildEx(oFullXML,"_NFEPROC")) == "O" //-- Nota normal, devolucao, beneficiamento, bonificacao
                cCodEdi := "109_NFE_"
            Case ValType(XmlChildEx(oFullXML,"_CTE")) == "O" //-- Nota de transporte
                cCodEdi := "214_CTE_"		
            Case ValType(XmlChildEx(oFullXML,"_CTEPROC")) == "O" //-- Nota de transporte
                cCodEdi := "214_CTE_"
            Case ValType(XmlChildEx(oFullXML,"_CTEOSPROC")) == "O" //-- Nota de transporte CTEOS
                cCodEdi := "273_CTE_"
            Case ValType(XmlChildEx(oFullXML,"_PROCTRANSMITENFSE")) == "O" //-- Nota de Serviço
                cCodEdi := "319_NFS_"
        EndCase
    Endif

    //Busca pelo arquivo original, verificando se ja foi importado
    CKO->(DbSetOrder(5))
    If CKO->(MsSeek(PadR(lower(cFile),LEN(CKO->CKO_ARQXML)))) .Or. CKO->(MsSeek(PadR(upper(cFile),LEN(CKO->CKO_ARQXML)))) .Or. ;
        CKO->(MsSeek(PadR(cFile,LEN(CKO->CKO_ARQXML))))
        cRet := CKO->CKO_ARQUIV
    Else
        cRet := Self:GetNumSeq(cCodEdi)
    Endif

    RestArea(aArea)

    DelClassIntF()

Return cRet

/*/{Protheus.doc} GetNumSeq
	Sequencia para nomenclatura de arquivo

@param  cCodEdi Edi importado (109/214/273/319)

@author rodrigo.mpontes
@since 14/01/2022
/*/

Method GetNumSeq(cCodEdi) Class COMTransmite

    Local aArea		:= GetArea()
    Local cAliasImp	:= GetNextAlias()
    Local cNumSeq	:= "000000000000000001"
    Local cArq		:= cCodEdi + cNumSeq + ".xml"
    Local cQry		:= ""
    Local cEdiQry	:= SubStr(cCodEdi,1,3)

    cQry := " SELECT MAX(CKO_ARQUIV) AS ULT"
    cQry += " FROM " + RetSqlName("CKO")
    cQry += " WHERE CKO_CODEDI = '" + cEdiQry + "'"
    cQry += " AND CKO_ARQXML <> '" + Space(TamSX3("CKO_ARQXML")[1]) + "'"
    cQry += " AND D_E_L_E_T_ = ' '"

    cQry := ChangeQuery(cQry)

    dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),cAliasImp,.T.,.T.)

    If (cAliasImp)->(!EOF()) .And. !Empty((cAliasImp)->ULT)
        cNumSeq := StrTran(Upper((cAliasImp)->ULT),".XML","")
        cNumSeq := StrTran(cNumSeq,cCodEdi,"")
        cNumSeq := Soma1(cNumSeq)
    Endif

    cArq := cCodEdi + cNumSeq + ".xml"

    (cAliasImp)->(DbCloseArea())

    RestArea(aArea)

Return cArq

/*/{Protheus.doc} GetDadosXML
	Busca dados no XML

@param  cXML    XML
@param  nOpc    1 = Dados Doc e Forn / 2 = Empresa e Filial / 3 = Chave documento

@author rodrigo.mpontes
@since 14/01/2022
/*/

Method GetDadosXML(cXML,nOpc) Class COMTransmite

    Local aArea		:= GetArea()
    Local aRet		:= {}
    Local oFullXML	:= Nil
    Local cError	:= ""
    Local cWarning	:= ""
    Local cXMLEncod	:= ""
    Local cDocXML	:= ""
    Local cSerXML	:= ""
    Local cForXML	:= ""
    Local cCGC		:= ""
    Local cIE		:= ""
    Local cEmpCKO	:= ""
    Local cFilCKO	:= ""
    Local oXML		:= Nil
    Local cTagToma3	:= ""
    Local cTgTom3	:= ""
    Local cTagRem  	:= ""
    Local cTagDest 	:= ""
    Local cIERem   	:= ""
    Local cIEDest  	:= ""
    Local cTagToma4	:= ""
    Local cTagRec	:= ""
    Local cTagExp	:= ""
    Local cTagCGC	:= ""
    Local cDataNFS  := ""
    Local cDocNFS   := ""
    Local cCNPJNFS  := ""
    Local aSM0      := {}
    Local nX		:= 0
    Local nQtdCNPJ	:= 0
    Local nFilImp	:= 0
    Local aFilInsc	:= {}
    Local lInscDup	:= .F.
    Local lCOLFILDUP:= ExistBlock("COLFILDUP")
    Local lNFS		:= .F.

    If !Empty(cXML)
        If SubStr(cXML,1,1) != "<"
            nPosPesq := At("<",cXML)
            cXML  := SubStr(cXML,nPosPesq,Len(cXML))
        EndIf

        cXMLEncod := EncodeUtf8(cXML)
        // Verifica se o encode ocorreu com sucesso, pois alguns caracteres especiais provocam erro na funcao de encode, neste caso e feito o tratamento pela funcao A140IRemASC
        If Empty(cXMLEncod)
            cXML 		:= A140IRemASC(cXML)
            cXMLEncod 	:= EncodeUtf8(cXML)
        EndIf

        If Empty(cXMLEncod)
            cXMLEncod := cXML
        EndIf
        
        If !Empty(cXMLEncod)
            oFullXML := XmlParser(cXMLEncod,"_",@cError,@cWarning)
        EndIf

        //Verificar com Transmite sobre UTF16
        If ValType(oFullXML) <> "O"
            cXMLEncod 	:= cXml
            cXml 		:= A140IRemASC(cXMLEncod)
            cXMLEncod 	:= EncodeUtf16(cXml)

            If !Empty(cXMLEncod)
                oFullXML := XmlParser(cXMLEncod,"_",@cError,@cWarning)
            Endif
        Endif

        If nOpc == 1
            If Empty(cError) .And. !Empty(oFullXML)
                If ValType(XmlChildEx(oFullXML,"_INVOIC_NFE_COMPL")) == "O"
                    cDocXML := oFullXML:_INVOIC_NFE_COMPL:_NFE_SEFAZ:_NFE:_INFNFE:_IDE:_NNF:Text
                    cSerXML	:= oFullXML:_INVOIC_NFE_COMPL:_NFE_SEFAZ:_NFE:_INFNFE:_IDE:_SERIE:Text
                    cForXML := oFullXML:_INVOIC_NFE_COMPL:_NFE_SEFAZ:_NFE:_INFNFE:_EMIT:_XNOME:Text
                Elseif ValType(XmlChildEx(oFullXML,"_NFEPROC")) == "O"
                    cDocXML := oFullXML:_NFeProc:_NFe:_InfNfe:_Ide:_nNF:Text
                    cSerXML	:= oFullXML:_NFeProc:_NFe:_InfNfe:_Ide:_Serie:Text
                    cForXML := oFullXML:_NFeProc:_NFe:_InfNfe:_Emit:_xNome:Text
                Elseif ValType(XmlChildEx(oFullXML,"_CTEPROC")) == "O"
                    cDocXML := oFullXML:_CteProc:_CTe:_InfCte:_Ide:_nCt:Text
                    cSerXML	:= oFullXML:_CteProc:_CTe:_InfCte:_Ide:_Serie:Text
                    cForXML := oFullXML:_CteProc:_CTe:_InfCte:_Emit:_xNome:Text
                Elseif ValType(XmlChildEx(oFullXML,"_CTEOSPROC")) == "O"
                    cDocXML := oFullXML:_CteOsProc:_CTeOs:_InfCte:_Ide:_nCt:Text
                    cSerXML	:= oFullXML:_CteOsProc:_CTeOs:_InfCte:_Ide:_Serie:Text
                    cForXML := oFullXML:_CteOsProc:_CTeOs:_InfCte:_Emit:_xNome:Text
                Elseif ValType(XmlChildEx(oFullXML,"_CTE")) == "O"
                    cDocXML := oFullXML:_Cte:_InfCte:_Ide:_nCt:Text
                    cSerXML	:= oFullXML:_Cte:_InfCte:_Ide:_Serie:Text
                    cForXML := oFullXML:_Cte:_InfCte:_Emit:_xNome:Text
                Elseif ValType(XmlChildEx(oFullXML,"_PROCTRANSMITENFSE")) == "O"
                    cDocXML := oFullXML:_PROCTRANSMITENFSE:_TRANSMITE:_RETTRANSMITENFSE:_NNFSE:TEXT
                    cSerXML	:= ""
                    cForXML := oFullXML:_PROCTRANSMITENFSE:_TRANSMITE:_TRANSMITERPS:_RPS:_PRESTADOR:_RSOCIALPREST:TEXT
                Endif
                aAdd(aRet,cDocXML)
                aAdd(aRet,cSerXML)
                aAdd(aRet,ALLTRIM(Upper(cForXML)))
            Endif
        Elseif nOpc == 2 //Empresa / Filial
            If Empty(cError) .And. !Empty(oFullXML)
                If ValType(XmlChildEx(oFullXML,"_INVOIC_NFE_COMPL")) == "O"
                    If XmlChildEx(oFullXML:_INVOIC_NFE_COMPL:_NFE_SEFAZ:_NFE:_INFNFE:_DEST,"_CNPJ") # NIL
                        cCGC := oFullXML:_INVOIC_NFE_COMPL:_NFE_SEFAZ:_NFE:_INFNFE:_DEST:_CNPJ:TEXT
                    Elseif XmlChildEx(oFullXML:_INVOIC_NFE_COMPL:_NFE_SEFAZ:_NFE:_INFNFE:_DEST,"_CPF") # NIL
                        cCGC := oFullXML:_INVOIC_NFE_COMPL:_NFE_SEFAZ:_NFE:_INFNFE:_DEST:_CPF:TEXT
                    EndIf

                    If XmlChildEx(oFullXML:_INVOIC_NFE_COMPL:_NFE_SEFAZ:_NFE:_INFNFE:_DEST,"_IE") # NIL
                        cIE := oFullXML:_INVOIC_NFE_COMPL:_NFE_SEFAZ:_NFE:_INFNFE:_DEST:_IE:TEXT					
                    EndIf
                Elseif ValType(XmlChildEx(oFullXML,"_NFEPROC")) == "O"
                    
                    If XmlChildEx(oFullXML:_NFeProc:_NFe:_InfNfe:_DEST,"_CNPJ") # NIL
                        cCGC := oFullXML:_NFeProc:_NFe:_InfNfe:_DEST:_CNPJ:TEXT
                    Elseif XmlChildEx(oFullXML:_NFeProc:_NFe:_InfNfe:_DEST,"_CPF") # NIL
                        cCGC := oFullXML:_NFeProc:_NFe:_InfNfe:_DEST:_CPF:TEXT
                    EndIf

                    If XmlChildEx(oFullXML:_NFeProc:_NFe:_InfNfe:_DEST,"_IE") # NIL
                        cIE := oFullXML:_NFeProc:_NFe:_InfNfe:_DEST:_IE:TEXT					
                    EndIf

                Elseif ValType(XmlChildEx(oFullXML,"_CTEPROC")) == "O" .Or. ValType(XmlChildEx(oFullXML,"_CTEOSPROC")) == "O" .Or. ValType(XmlChildEx(oFullXML,"_CTE")) == "O" 
                    If ValType(XmlChildEx(oFullXML,"_CTEPROC")) == "O"
                        oXML := oFullXML:_CteProc:_CTe
                    Elseif ValType(XmlChildEx(oFullXML,"_CTEOSPROC")) == "O"
                        oXML := oFullXML:_CteOsProc:_CTeOs
                    Elseif ValType(XmlChildEx(oFullXML,"_CTE")) == "O"
                        oXML := oFullXML:_Cte
                    Endif

                    cTagRem  	:= If(ValType(XmlChildEx(oXML:_InfCte,"_REM")) == "O", If(ValType(XmlChildEx(oXML:_InfCte:_Rem,"_CNPJ")) == "O","_CNPJ","_CPF"),"")
                    cTagDest 	:= If(ValType(XmlChildEx(oXML:_InfCte,"_DEST")) == "O",If(ValType(XmlChildEx(oXML:_InfCte:_Dest,"_CNPJ")) == "O","_CNPJ","_CPF"),"")
                    cIERem   	:= If(ValType(XmlChildEx(oXML:_InfCte,"_REM")) == "O", If(ValType(XmlChildEx(oXML:_InfCte:_Rem,"_IE")) == "O","_IE",""),"")
                    cIEDest  	:= If(ValType(XmlChildEx(oXML:_InfCte,"_DEST")) == "O",If(ValType(XmlChildEx(oXML:_InfCte:_Dest,"_IE")) == "O","_IE",""),"")

                    If ValType(XmlChildEx(oXML:_InfCte:_Ide,"_TOMA03")) <> "U"
                        cTagToma3	:= AllTrim(oXML:_InfCte:_Ide:_Toma03:_TOMA:Text)
                        cTgTom3	:= "_TOMA03"
                    Elseif ValType(XmlChildEx(oXML:_InfCte:_Ide,"_TOMA3")) <> "U"
                        cTagToma3	:= AllTrim(oXML:_InfCte:_Ide:_Toma3:_TOMA:Text)
                        cTgTom3	:= "_TOMA3"
                    Endif

                    If ValType(XmlChildEx(oXML:_InfCte:_Ide,cTgTom3)) <> "U" 
                        If cTagToma3 == "0" //Remetente
                            If ValType(XmlChildEx(oXML:_InfCte:_Rem,cTagRem)) == "O"
                                cCGC 	:= AllTrim(XmlChildEx(oXML:_InfCte:_Rem,cTagRem):Text)
                            EndIf
                            
                            If ValType(XmlChildEx(oXML:_InfCte:_Rem,cIERem)) == "O"
                                cIE 	:= AllTrim(XmlChildEx(oXML:_InfCte:_Rem,cIERem):Text)
                            EndIf
                        ElseIf cTagToma3 == "1" //Expedidor
                            cTagExp := If(ValType(XmlChildEx(oXML:_InfCte:_Exped,"_CNPJ")) == "O","_CNPJ","_CPF")
                            
                            If ValType(XmlChildEx(oXML:_InfCte:_Exped,cTagExp)) == "O"
                                cCGC 	:= AllTrim(XmlChildEx(oXML:_InfCte:_Exped,cTagExp):Text)
                            EndIf
                            
                            If ValType(XmlChildEx(oXML:_InfCte:_Exped,"_IE")) == "O"
                                cIE 	:= AllTrim(XmlChildEx(oXML:_InfCte:_Exped,"_IE"):Text)
                            EndIf
                        ElseIf cTagToma3 == "2" //Recebedor
                            cTagRec := If(ValType(XmlChildEx(oXML:_InfCte:_Receb,"_CNPJ")) == "O","_CNPJ","_CPF")
                            
                            If ValType(XmlChildEx(oXML:_InfCte:_Receb,cTagRec)) == "O"
                                cCGC 	:= AllTrim(XmlChildEx(oXML:_InfCte:_Receb,cTagRec):Text)
                            EndIf
                            
                            If ValType(XmlChildEx(oXML:_InfCte:_Receb,"_IE")) == "O"
                                cIE 	:= AllTrim(XmlChildEx(oXML:_InfCte:_Receb,"_IE"):Text)
                            EndIf
                        ElseIf cTagToma3 == "3" //Destinatario
                            If ValType(XmlChildEx(oXML:_InfCte:_Dest,cTagDest)) == "O"
                                cCGC 	:= AllTrim(XmlChildEx(oXML:_InfCte:_Dest,cTagDest):Text)
                            EndIF
                            
                            If ValType(XmlChildEx(oXML:_InfCte:_Dest,cIEDest)) == "O"
                                cIE 	:= AllTrim(XmlChildEx(oXML:_InfCte:_Dest,cIEDest):Text)			
                            EndIF
                        EndIf
                    ElseIf ValType(XmlChildEx(oXML:_InfCte:_Ide,"_TOMA4")) <> "U"
                        If AllTrim(oXML:_InfCte:_Ide:_Toma4:_TOMA:Text) == "4"
                            cTagToma4 := If(ValType(XmlChildEx(oXML:_InfCte:_Ide:_Toma4,"_CNPJ")) == "O","_CNPJ","_CPF")
                            
                            If ValType(XmlChildEx(oXML:_InfCte:_Ide:_Toma4,cTagToma4)) == "O"
                                cCGC 	:= AllTrim(XmlChildEx(oXML:_InfCte:_Ide:_Toma4,cTagToma4):Text)
                            EndIf
                            
                            If ValType(XmlChildEx(oXML:_InfCte:_Ide:_Toma4,"_IE")) == "O"
                                cIE 	:= AllTrim(XmlChildEx(oXML:_InfCte:_Ide:_Toma4,"_IE"):Text)
                            EndIf
                        EndIf
                    Elseif ValType(XmlChildEx(oXML:_InfCte,"_TOMA")) <> "U"
                        cTagCGC := If(ValType(XmlChildEx(oXML:_InfCte:_Toma,"_CNPJ")) == "O","_CNPJ","_CPF")
                            
                        If ValType(XmlChildEx(oXML:_InfCte:_Toma,cTagCGC)) == "O"
                            cCGC 	:= AllTrim(XmlChildEx(oXML:_InfCte:_Toma,cTagCGC):Text)
                        EndIf
                        
                        If ValType(XmlChildEx(oXML:_InfCte:_Toma,"_IE")) == "O"
                            cIE 	:= AllTrim(XmlChildEx(oXML:_InfCte:_Toma,"_IE"):Text)
                        EndIf
                    Else //Se o xml não possui as tags Toma3 e Toma4, o documento será processado na filial do destinatario
                        If ValType(XmlChildEx(oXML:_InfCte,"_DEST")) == "O" .And. ValType(XmlChildEx(oXML:_InfCte:_Dest,cTagDest)) == "O"
                            cCGC 	:= AllTrim(XmlChildEx(oXML:_InfCte:_Dest,cTagDest):Text)
                        EndIF
                        
                        If ValType(XmlChildEx(oXML:_InfCte,"_DEST")) == "O" .And. ValType(XmlChildEx(oXML:_InfCte:_Dest,cIEDest)) == "O"
                            cIE 	:= AllTrim(XmlChildEx(oXML:_InfCte:_Dest,cIEDest):Text)			
                        EndIF
                    EndIf
                Elseif ValType(XmlChildEx(oFullXML,"_PROCTRANSMITENFSE")) == "O" 
                    cCGC := oFullXML:_PROCTRANSMITENFSE:_TRANSMITE:_TRANSMITERPS:_RPS:_TOMADOR:_CNPJTOM:TEXT
                    lNFS := .T.
                Endif

                If !Empty(cCGC)
                    aSM0       := FWLoadSM0()

                    For nX := 1 To Len(aSM0)
                        If cCGC $ aSM0[nX][SM0_CGC]
                            nQtdCNPJ++
                        EndIf
                    Next nX

                    If nQtdCNPJ == 1
                        If (nFilImp := (ASCan(aSM0,{|x| AllTrim(x[SM0_CGC]) == cCgc }))) > 0
                            cEmpCKO := AllTrim(aSM0[nFilImp][SM0_GRPEMP])				
                            cFilCKO := AllTrim(aSM0[nFilImp][SM0_CODFIL])	
                        Endif
                    Elseif nQtdCNPJ > 1

                        If !Empty(AllTrim(cIE))
                            //FORCA O CONTEUDO ISENTO
                            If "ISENT" $ cIE
                                cIE := "ISENTO"
                            EndIf  
                        Else
                            If !lNFS
                                cIE := "ISENTO"
                            Endif 
                        EndIf
                            
                        aFilInsc := InscEstSM0(cCgc,cIE,@lInscDup)
                        
                        If !Empty(aFilInsc)
                            cEmpCKO := aFilInsc[1]				
                            cFilCKO := aFilInsc[2]
                        Elseif Empty(aFilInsc) .And. lInscDup .And. lCOLFILDUP
                            aFilInsc := ExecBlock("COLFILDUP",.F.,.F.,{cCgc,cIE})
                            If ValType(aFilInsc) == "A" .And. Len(aFilInsc) == 2
                                cEmpCKO := aFilInsc[1]				
                                cFilCKO := aFilInsc[2] 
                            Endif
                        Endif
                    Endif
                Endif

                aAdd(aRet,cEmpCKO)
                aAdd(aRet,cFilCKO)
            Endif
        Elseif nOpc == 3

            If ValType(XmlChildEx(oFullXML,"_NFEPROC")) == "O"
                If ValType(XmlChildEx(oFullXML:_NFEPROC,"_PROTNFE")) == "O"
                    If ValType(XmlChildEx(oFullXML:_NFEPROC:_PROTNFE,"_INFPROT")) == "O"
                        If ValType(XmlChildEx(oFullXML:_NFEPROC:_PROTNFE:_INFPROT,"_CHNFE")) == "O"
                            aAdd(aRet,oFullXML:_NFEPROC:_PROTNFE:_INFPROT:_CHNFE:TEXT)
                        Endif
                    Endif
                Endif
            Elseif ValType(XmlChildEx(oFullXML,"_CTEPROC")) == "O"
                If ValType(XmlChildEx(oFullXML:_CTEPROC,"_PROTCTE")) == "O"
                    If ValType(XmlChildEx(oFullXML:_CTEPROC:_PROTCTE,"_INFPROT")) == "O"
                        If ValType(XmlChildEx(oFullXML:_CTEPROC:_PROTCTE:_INFPROT,"_CHCTE")) == "O"
                            aAdd(aRet,oFullXML:_CTEPROC:_PROTCTE:_INFPROT:_CHCTE:TEXT)
                        Endif
                    Endif
                Endif
            Elseif ValType(XmlChildEx(oFullXML,"_CTEOSPROC")) == "O"
                If ValType(XmlChildEx(oFullXML:_CTEOSPROC,"_PROTCTE")) == "O"
                    If ValType(XmlChildEx(oFullXML:_CTEOSPROC:_PROTCTE,"_INFPROT")) == "O"
                        If ValType(XmlChildEx(oFullXML:_CTEOSPROC:_PROTCTE:_INFPROT,"_CHCTE")) == "O"
                            aAdd(aRet,oFullXML:_CTEOSPROC:_PROTCTE:_INFPROT:_CHCTE:TEXT)
                        Endif
                    Endif
                Endif
            Elseif ValType(XmlChildEx(oFullXML,"_CTE")) == "O"
                If ValType(XmlChildEx(oFullXML:_CTE,"_PROTCTE")) == "O"
                    If ValType(XmlChildEx(oFullXML:_CTE:_PROTCTE,"_INFPROT")) == "O"
                        If ValType(XmlChildEx(oFullXML:_CTE:_PROTCTE:_INFPROT,"_CHCTE")) == "O"
                            aAdd(aRet,oFullXML:_CTE:_PROTCTE:_INFPROT:_CHCTE:TEXT)
                        Endif
                    Endif
                Elseif ValType(XmlChildEx(oFullXML:_CTE,"_INFCTE")) == "O"
                    If ValType(XmlChildEx(oFullXML:_CTE:_INFCTE,"_ID")) == "O"
                        aAdd(aRet,StrTran(Upper(oFullXML:_CTE:_INFCTE:_ID:TEXT),"CTE",""))
                    Endif
                Endif
            Elseif ValType(XmlChildEx(oFullXML,"_PROCTRANSMITENFSE")) == "O"
                If ValType(XmlChildEx(oFullXML:_PROCTRANSMITENFSE,"_TRANSMITE")) == "O"
                    If ValType(XmlChildEx(oFullXML:_PROCTRANSMITENFSE:_TRANSMITE,"_RETTRANSMITENFSE")) == "O"
                        If ValType(XmlChildEx(oFullXML:_PROCTRANSMITENFSE:_TRANSMITE:_RETTRANSMITENFSE,"_CNPJPREST")) == "O"
                            cCNPJNFS  := oFullXML:_PROCTRANSMITENFSE:_TRANSMITE:_RETTRANSMITENFSE:_CNPJPREST:TEXT
                        Endif

                        If ValType(XmlChildEx(oFullXML:_PROCTRANSMITENFSE:_TRANSMITE:_RETTRANSMITENFSE,"_NNFSE")) == "O"
                            cDocNFS   := oFullXML:_PROCTRANSMITENFSE:_TRANSMITE:_RETTRANSMITENFSE:_NNFSE:TEXT
                        Endif

                        If ValType(XmlChildEx(oFullXML:_PROCTRANSMITENFSE:_TRANSMITE:_RETTRANSMITENFSE,"_DTEMISNFSE")) == "O"
                            cDataNFS  := oFullXML:_PROCTRANSMITENFSE:_TRANSMITE:_RETTRANSMITENFSE:_DTEMISNFSE:TEXT
                        Endif
                        
                        If !Empty(cCNPJNFS) .And. !Empty(cDocNFS) .And. !Empty(cDataNFS)
                            aAdd(aRet,cDataNFS + "|" + cCNPJNFS + "|" + cDocNFS)
                        Endif 
                    Endif
                Endif
            Endif

        Endif
    Endif

    RestArea(aArea)

    oFullXML := Nil
    DelClassIntF()

Return aRet

/*/{Protheus.doc} XMLEXPORTED
	Informa transmite que documento foi importado

@param  nOpc 1-CKO / 2-DOC (F1/D1)
@param  aDoc Documentos a serem atualizados

@author rodrigo.mpontes
@since 14/01/2022
/*/

Method XMLEXPORTED(nOpc,aDoc) Class COMTransmite

    Local cJson     := ""
    Local cJsonDoc  := ""
    Local nCount    := 0
    Local aAux      := {}
    Local aDocRead  := {}
    Local aDocRet   := {}
    Local nI        := 0
    Local nDocs     := 200
    Local nTotDoc   := 0
    Local nCountDoc := 0
    Local nPosDoc	:= 0
    
    If Self:lCkoTra
        Self:LogMessage("","Busca documentos a serem atualizados no Transmite")

        If nOpc == 1
            aDocRead := Self:GetDocUpdTra(nOpc)
        Elseif nOpc == 2 .Or. nOpc == 3
            If Len(aDoc) > 0
                nTotDoc := Len(aDoc)

                While nTotDoc > 0
                    nDocs := If(nTotDoc < nDocs, nTotDoc, nDocs)
                
                    For nI := 1 To nDocs
                        aAdd(aAux,aDoc[nCountDoc+nI])
                        nPosDoc += 1
                    Next nI
                    aDocRet := Self:GetDocUpdTra(nOpc,aAux)
                    For nI := 1 To Len(aDocRet)
                        aAdd(aDocRead,aDocRet[nI])
                    Next nI
                    nCountDoc += nPosDoc
                    nPosDoc := 0
                    nTotDoc -= nDocs
                    aAux := {}
                Enddo
            Else
                aDocRead := Self:GetDocUpdTra(nOpc)
            Endif
        Endif  

        Self:LogMessage("","Atualizando Transmite com NFE/CTE/CTEOS/NFS")
        If Len(aDocRead) > 0
            nCount      := 0
            cJsonDoc    := ""

            For nI := 1 To Len(aDocRead)
                cJson := '{'
                If nOpc == 1 .Or. nOpc == 3
                    cJson += '"StatusIntegracao":"Exportada",'
                Elseif nOpc == 2
                    cJson += '"StatusIntegracao":"Integrada",'
                Endif
                
                If aDocRead[nI,1] == "NFS"
                    cJson += '"ChavesNfse":['
                Elseif aDocRead[nI,1] == "NFE"
                      cJson += '"CodigoFilial":"' + AllTrim(aDocRead[nI,4]) + '",'
                      cJson += '"Documentos":['

                Elseif aDocRead[nI,1] == "CTE" .Or. aDocRead[nI,1] == "CTO"
                    cJson += '"ChavesCte":['
                Endif
                
                If aDocRead[nI,1] $ "NFE"
                        cJson += '{'
                        cJson += '"Chave":"' + AllTrim(aDocRead[nI,2]) + '",'
                        cJson += '"DataLancamentoERP":"' + AllTrim(aDocRead[nI,3]) + '"'
                        cJson += '}'
                        cJsonDoc += aDocRead[nI,2]
                Endif

                If aDocRead[nI,1] $ "CTE/CTO"
                    cJson += '"' + aDocRead[nI,2] + '"'
                    cJsonDoc += aDocRead[nI,2]
                Elseif aDocRead[nI,1] == "NFS"
                    cJson += '{"DataEmissao":"' + aDocRead[nI,2] + '",'
                    cJson += '"Nfse":"' + AllTrim(aDocRead[nI,3]) + '",'
                    cJson += '"CnpjCpfPrestador":"' + aDocRead[nI,4] + '"}'
                    cJsonDoc += aDocRead[nI,2]+"|"+aDocRead[nI,4]+"|"+aDocRead[nI,3]
                Endif
                
                cJson += ']'
                cJson += '}'
                Self:PostExported(cJson,aDocRead[nI,1],nOpc,cJsonDoc)
                cJsonDoc:= "" 
            Next nI
        Endif
    Endif

    Self:CleanUp(2,,,3)
Return

/*/{Protheus.doc} PostExported
	Post no Transmite com documentos

@param  cJsonBody   Body com documentos a serem atualizados
@param  cTpXML      Tipo XML (NFE/NFS/CTE/CTEOS)
@param  nOpc        1-CKO / 2-DOC (F1/D1) / 3-F1 volta CKO
@param  cJsonDoc    Body apenas com os documentos a serem atualizados CKO

@author rodrigo.mpontes
@since 14/01/2022
/*/

Method PostExported(cJsonBody,cTpXML,nOpc,cJsonDoc) Class COMTransmite

    Local cResource := ""
    Local cTextJson := ""
    Local cAliasImp := ""
    Local cQry      := ""
    Local cMessage  := ""
    Local aHeader   := {}
    Local oRestPost := Nil
    Local aArea     := {}
    Local xMessage  := Nil

    aHeader     := Self:GetHeader()

    oRestPost 	:= FwRest():New(Self:cApiTra)
    If cTpXML == "NFE"
        cResource   := Self:cApiSetExpNFE
    Elseif cTpXML == "NFS"
        cResource   := Self:cApiSetExpNFS
    Elseif cTpXML == "CTE"
        cResource   := Self:cApiSetExpCTE
    Elseif cTpXML == "CTO"
        cResource   := Self:cApiSetExpCTO
    Endif

    cAliasImp := GetNextAlias()

    cQry := " SELECT R_E_C_N_O_ RECNO"
    cQry += " FROM " + RetSqlName("CKO")
    cQry += " WHERE CKO_CHVDOC = '" + cJsonDoc + "'"
    cQry += " AND D_E_L_E_T_ = ' '"
    cQry := ChangeQuery(cQry)

    dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),cAliasImp,.T.,.T.)

    aArea := GetArea()

    oJsonResp := JsonObject():New()  
    oRestPost:SetPath(cResource)
    oRestPost:SetPostParams(cJsonBody)

    If oRestPost:Post(aHeader)
        If (cAliasImp)->(!EOF())
            CKO->(DbGoto((cAliasImp)->RECNO))
            If RecLock("CKO",.F.)
                CKO->CKO_STRAN := Iif(nOpc==1 .Or. nOpc == 3,"2","3")
                If Self:lCkoTra
                    CKO->CKO_ERRTRA := ""
                Endif
                CKO->(MsUnlock())
            Endif
        Endif
        Self:LogMessage(,"Documentos atualizados no Transmite")
    Else
        cTextJson := oRestPost:GetResult()
        oJsonResp:FromJson(cTextJson)
        Self:cLastError := oRestPost:GetLastError()
        Self:lAPIError := .T.

        xMessage := oJsonResp:GetJsonObject("message")
        cMessage := Iif(ValType(xMessage) == "C",xMessage,oRestPost:oResponseH:cStatusCode + " - " + oRestPost:oResponseH:cReason)
        
        If Self:lCkoTra .And. (cAliasImp)->(!EOF())
            CKO->(DbGoto((cAliasImp)->RECNO))
            If RecLock("CKO",.F.)
                CKO->CKO_ERRTRA := cMessage
                CKO->(MsUnlock())
            Endif
        Endif
        
        Self:LogMessage(cTextJson, oRestPost:GetLastError())
    EndIf

    RestArea(aArea)

    (cAliasImp)->(DbCloseArea())

Return

/*/{Protheus.doc} FindCKODOC
	Busca mesmo documento na CKO

@param  cChvXML     Chave documento
@param  cDocXML     Numero documento
@param  cSerXML     Serie documento
@param  cNomXML     Nome fornecedor documento

@author rodrigo.mpontes
@since 14/01/2022
/*/

Method FindCKODOC(cChvXML,cDocXML,cSerXML,cNomXML) Class COMTransmite

Local cQry        := ""
Local cQryStat    := ""
Local cCKOAli     := ""
Local cFile       := "" //Preenchido = Encontro CKO / Em branco =  Não existe CKO
Local cFlag       := ""

If Self:lCkoTra .And. Self:lCkoRepro
    cCKOAli     := GetNextAlias()

    If oFindCKO == Nil
        oFindCKO := FWPreparedStatement():New()

        cQry := " SELECT CKO_ARQUIV, CKO_FLAG FROM " + RetSqlName("CKO") + " CKO"
        cQry += " WHERE CKO.D_E_L_E_T_ = ' '"
        cQry += " AND   ( "
        cQry += "       CKO.CKO_CHVDOC = ? "
        cQry += "       OR ( "
        cQry += "           CKO.CKO_DOC = ?"
        cQry += "           AND CKO.CKO_SERIE = ?"
        cQry += "           AND CKO.CKO_NOMFOR = ?
        cQry += "           )"
        cQry += "       )"
        cQry := ChangeQuery(cQry)

        oFindCKO:SetQuery(cQry) 
    Endif
    
    oFindCKO:SetString(1,cChvXML)
    oFindCKO:SetString(2,cDocXML)
    oFindCKO:SetString(3,cSerXML)
    oFindCKO:SetString(4,cNomXML)

    cQryStat := oFindCKO:GetFixQuery()
    MpSysOpenQuery(cQryStat,cCKOAli) 

    If (cCKOAli)->(!EOF())
        cFile := (cCKOAli)->CKO_ARQUIV
        cFlag := (cCKOAli)->CKO_FLAG
    Endif

    (cCKOAli)->(DbCloseArea())
Endif

Return {cFile,cFlag}

/*/{Protheus.doc} XMLSTATUSTRA
	Atualiza status Transmite

@author rodrigo.mpontes
@since 14/01/2022
/*/

Method XMLSTATUSTRA() Class COMTransmite

Local cQry          := ""
Local cQryStat      := ""
Local cAliTmp       := ""
Local aDoc          := {}
Local cChvXML       := ""
Local cDocXML       := ""
Local cSerXML       := ""
Local cNomXML       := ""
Local oAStaInteg    := Nil
Local oAStaExpor    := Nil
Local oAtuChvDoc    := Nil
Local aCKODados     := {}
Local lCkoChvDoc    := Self:lCkoRepro .And. Self:lCkoTra

//Atualizar documento sem chave documento
If lCkoChvDoc
    cAliTmp     := GetNextAlias()
    oAtuChvDoc  := FWPreparedStatement():New()

    cQry := " SELECT R_E_C_N_O_ RECNO, CKO_STRAN "
    cQry += " FROM " + RetSqlName("CKO") + " CKO "
    cQry += " WHERE D_E_L_E_T_ = ' '"
    cQry += " AND CKO_FLAG IN ('0','1','2')"
    cQry += " AND CKO_CHVDOC = ''"
    cQry := ChangeQuery(cQry)

    oAtuChvDoc:SetQuery(cQry)
    cQryStat := oAtuChvDoc:GetFixQuery()
    MpSysOpenQuery(cQryStat,cAliTmp)

    While (cAliTmp)->(!EOF())
        CKO->(DbGoto((cAliTmp)->RECNO))
        aCKODados := Self:GetDadosXML(CKO->CKO_XMLRET,3)
        If Len(aCKODados) > 0
            cChvXML	:= aCKODados[1]
        Endif
        aCKODados := Self:GetDadosXML(CKO->CKO_XMLRET,1)
        If Len(aCKODados) > 0
            cDocXML	:= aCKODados[1]
            cSerXML	:= aCKODados[2]
            cNomXML	:= aCKODados[3]
        Endif

        If !Empty(cChvXML) .Or. !Empty(cDocXML)
            If RecLock("CKO",.F.)
                CKO->CKO_CHVDOC := cChvXML
                CKO->CKO_DOC    := cDocXML
                CKO->CKO_SERIE  := cSerXML
                CKO->CKO_NOMFOR := cNomXML
                If Empty((cAliTmp)->CKO_STRAN)
                    CKO->CKO_STRAN  := "1"
                Endif
                CKO->(MsUnlock())
            Endif
        Endif
        (cAliTmp)->(DbSkip())
    Enddo

    oAtuChvDoc:Destroy()
Endif

//Atualização para status (Pendente = 1 para Exportada = 2)
Self:XMLEXPORTED(1)

//Atualização para status (Exportada = 2 para Integrada = 3)
cAliTmp     := GetNextAlias()
oAStaInteg  := FWPreparedStatement():New()

cQry := " SELECT CKO.CKO_ARQUIV, R_E_C_N_O_ RECNO FROM " + RetSqlName("CKO") + " CKO"
cQry += " WHERE CKO.D_E_L_E_T_ = ''"
cQry += " AND CKO.CKO_CHVDOC <> ''"
cQry += " AND CKO.CKO_ARQUIV IN (SELECT DS.DS_ARQUIVO FROM " + RetSqlName("SDS") + " DS WHERE DS.D_E_L_E_T_ = '' AND DS_STATUS = 'P')"
cQry += " AND CKO_STRAN <> '3'"
cQry := ChangeQuery(cQry)

oAStaInteg:SetQuery(cQry)
cQryStat := oAStaInteg:GetFixQuery()
MpSysOpenQuery(cQryStat,cAliTmp)

While (cAliTmp)->(!EOF())
    aAdd(aDoc,(cAliTmp)->CKO_ARQUIV)
    CKO->(DbGoto((cAliTmp)->RECNO))
    If RecLock("CKO",.F.)
        CKO->CKO_STRAN  := "2"
        CKO->(MsUnlock())
    Endif
    (cAliTmp)->(DbSkip())
Enddo

(cAliTmp)->(DbCloseArea())
oAStaInteg:Destroy()

If Len(aDoc) > 0
    Self:XMLEXPORTED(2,aDoc)
Endif

//Atualização para status (Integrada = 3 para Exportada = 2), documento que foram excluidos da SF1 e não retornou status
cAliTmp     := GetNextAlias()
oAStaExpor  := FWPreparedStatement():New()
aDoc        := {}

cQry := " SELECT CKO.CKO_ARQUIV FROM " + RetSqlName("CKO") + " CKO"
cQry += " WHERE CKO.D_E_L_E_T_ = ''"
cQry += " AND CKO.CKO_CHVDOC <> ''"
cQry += " AND CKO.CKO_ARQUIV IN (SELECT DS.DS_ARQUIVO FROM " + RetSqlName("SDS") + " DS WHERE DS.D_E_L_E_T_ = '' AND DS_STATUS <> 'P')"
cQry += " AND CKO_STRAN = '3'"
cQry := ChangeQuery(cQry)

oAStaExpor:SetQuery(cQry)
cQryStat := oAStaExpor:GetFixQuery()
MpSysOpenQuery(cQryStat,cAliTmp)

While (cAliTmp)->(!EOF())
    aAdd(aDoc,(cAliTmp)->CKO_ARQUIV)
    (cAliTmp)->(DbSkip())
Enddo

(cAliTmp)->(DbCloseArea())
oAStaExpor:Destroy()

If Len(aDoc) > 0
    Self:XMLEXPORTED(3,aDoc)
Endif

Self:CleanUp(2,,,2)

Return

/*/{Protheus.doc} NewReceipt
Valida se recibo ja foi lido para gerar novo

@param  cTpXML     Tipo XML
@param  cResource  String requisição
    
@author rodrigo.mpontes
@since 14/01/2022
/*/

Method NewReceipt(cTpXML,cResource) Class COMTransmite

Local cQry      := ""
Local cQryStat  := ""
Local cAliTmp   := ""
Local lRet      := .T.

If Self:lDHYFil
    cAliTmp := GetNextAlias()
    
    If oNewDHW == Nil
        oNewDHW := FWPreparedStatement():New()  

        cQry := " SELECT DHY_ID FROM " + RetSqlName("DHY")
        cQry += " WHERE D_E_L_E_T_ = ' '" 
        cQry += " AND DHY_FILTRO = ?"
        cQry += " AND DHY_TPXML = ?"
        cQry := ChangeQuery(cQry)

        oNewDHW:SetQuery(cQry)
    Endif

    oNewDHW:SetString(1,cResource)
    oNewDHW:SetString(2,cTpXML)

    cQryStat := oNewDHW:GetFixQuery()
    MpSysOpenQuery(cQryStat,cAliTmp)

    If (cAliTmp)->(!EOF())
        Self:LogMessage(,"NewReceipt: NÃO - Recibo ja existente para o filtro: " + cResource)
        lRet := .F.
    Else
        Self:LogMessage(,"NewReceipt: SIM - Solicitara novo recibo ao Transmite para o filtro: " + cResource)
    Endif

    (cAliTmp)->(DbCloseArea())
Endif

Return lRet

Method GetDocUpdTra(nOpc,aDoc) Class COMTransmite

Local cAliasImp := GetNextAlias()
Local oQryDoc   := Nil
Local cQryStat  := ""
local cCodFilT  := ""
local cEmpPro   := ""
local cFilPro   := ""
Local aAux      := {}
Local aRet      := {}
Default aDoc    := {}

oQryDoc := FWPreparedStatement():New()  

cQry := " SELECT CKO_CHVDOC, CKO_CODEDI, CKO_EMPPRO,CKO_FILPRO "
cQry += " FROM " + RetSqlName("CKO")
cQry += " WHERE CKO_CHVDOC <> ' '"
cQry += " AND CKO_STRAN = ?"
If Len(aDoc) > 0
    cQry += " AND CKO_ARQUIV IN (?)"
Endif
cQry := ChangeQuery(cQry)

oQryDoc:SetQuery(cQry)
oQryDoc:SetString(1,AllTrim(Str(nOpc)))
If Len(aDoc) > 0
    oQryDoc:SetIn(2,aDoc)
Endif

cQryStat := oQryDoc:GetFixQuery()
MpSysOpenQuery(cQryStat,cAliasImp)

While (cAliasImp)->(!EOF())
    If "|" $ (cAliasImp)->CKO_CHVDOC
        aAux := Separa((cAliasImp)->CKO_CHVDOC,"|")
    Endif

    If cEmpPro <> (cAliasImp)->CKO_EMPPRO .and. cFilPro <> (cAliasImp)->CKO_FILPRO
       cEmpPro := (cAliasImp)->CKO_EMPPRO
       cFilPro := (cAliasImp)->CKO_FILPRO
       cCodFilT:= GetCodFil(cEmpPro,cFilPro)
    Endif

    If Len(aAux) > 0
        aAdd(aRet,{"NFS",aAux[1],aAux[3],aAux[2]}) //NFS
    Else
        If (cAliasImp)->CKO_CODEDI == "109" //NFE
              aAdd(aRet,{"NFE",;
                         (cAliasImp)->CKO_CHVDOC,;
                         GetDataLanc((cAliasImp)->CKO_CHVDOC,(cAliasImp)->CKO_FILPRO),;
                         cCodFilT})

        ElseIf (cAliasImp)->CKO_CODEDI == "214" //CTE
            aAdd(aRet,{"CTE",(cAliasImp)->CKO_CHVDOC})
        ElseIf (cAliasImp)->CKO_CODEDI == "273" //CTEOS
            aAdd(aRet,{"CTO",(cAliasImp)->CKO_CHVDOC})
        Endif
    Endif
    aAux := {}
    (cAliasImp)->(DbSkip())
Enddo

(cAliasImp)->(DbCloseArea())

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GetDataLanc
Pega a data do lancamento
@param  cChv     Chave da Nfe
@param  cfilCko  Filial

@author	Valter Silva
@since 19/04/2022
/*/
//------------------------------------------------------------------- 

Static Function GetDataLanc(cChv,cfilCko)
Local aAreaSF1	:= SF1->(GetArea())
Local cDataLanc  := ''

DEFAULT cChv	:= ""
DEFAULT cfilCko := ""

//Busca pela chave do documento
If cChv <> ""
	DbSelectArea("SF1")
	SF1->(DbSetOrder(8))
	If SF1->(DbSeek(fwxfilial("SF1",cfilCko)+cChv))
        If !Empty(SF1->F1_DTDIGIT) .and. !Empty(SF1->F1_HORA)
            cDataLanc := FWTimeStamp(5,SF1->F1_DTDIGIT,SF1->F1_HORA)
        Endif
    Endif
Endif

RestArea(aAreaSF1)
Return cDataLanc

//-------------------------------------------------------------------
/*/{Protheus.doc} GetCodFil
Pega o codigo da Filial do Transmite
@param cEmp codigo da empresa
@param cFil codigo da filial
@Return cRet codigo da filial do transmite	
@author	Valter Silva
@since 19/04/2022
/*/
//------------------------------------------------------------------- 
Static Function GetCodFil(cEmp,cFil)
Local cAliasImp := GetNextAlias()
Local oQryDHW   := Nil
Local cQryStat  := ""
Local cRet		:= ""

oQryDHW := FWPreparedStatement():New()  

cQry := " SELECT DHW_GRPEMP, DHW_FILEMP, DHW_CODFIL"
cQry += " FROM " + RetSqlName("DHW")
cQry += " WHERE D_E_L_E_T_ = ' '"
cQry += " AND DHW_GRPEMP = ?"
cQry += " AND DHW_FILEMP = ?"

cQry := ChangeQuery(cQry)

oQryDHW:SetQuery(cQry)

oQryDHW:SetString(1,cEmp)
oQryDHW:SetString(2,cFil)

cQryStat := oQryDHW:GetFixQuery()
MpSysOpenQuery(cQryStat,cAliasImp)

cRet := (cAliasImp)->DHW_CODFIL

(cAliasImp)->(DbCloseArea())

Return cRet
