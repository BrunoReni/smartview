#Include 'PROTHEUS.CH'
#Include 'TOTVS.CH'
#Include "PARMTYPE.CH" 
#Include "RwMake.ch"
#Include "TbiConn.ch"
#Include "FILEIO.CH"
#include "RESTFUL.ch"

Function ImpTraTool()

Local aTools		:= {"COLAUTOREAD COM LOG","CONSULTAR RECIBO","INCLUIR RECIBO"}
Local cRecibo		:= "" 
Local cRecInc		:= ""
Local aDHWImp		:= {}
Local cDHWFil		:= ""
Local aXML			:= {"NFE","NFS","CTE","CTEOS"}
Local cTpXML		:= ""
Local aDHWTra		:= {}

Private cImpTraTool		:= ""
Private oF1B1			:= Nil
Private oF1MG1			:= Nil
Private oF2B1			:= Nil
Private oF2S1			:= Nil
Private oF2G1			:= Nil
Private oF2MG1			:= Nil
Private oT1B1			:= Nil
Private oT1B2			:= Nil
Private oT1B3			:= Nil
Private oF3B1			:= Nil
Private oF3S1			:= Nil
Private oF3G1			:= Nil
Private oF3S2			:= Nil
Private oF3S3			:= Nil
Private oF3CB1			:= Nil
Private oF3CB2			:= Nil
Private oF3B2			:= Nil
Private oTFolder		:= Nil
Private oComTransmite 	:= ComTransmite():New()

aDHWTra		:= oComTransmite:GetCodFilDHW()
aDHWImp		:= ImpTraDHW(aDHWTra,1)
cRecibo		:= Space(oComTransmite:nTamId)
cRecInc		:= Space(oComTransmite:nTamId)

DEFINE MSDIALOG oDlgFil TITLE "Ferramentas - Importador XML x Totvs Transmite" FROM 000,000 TO 650,1200 PIXEL //"Filial(ais) - Importador XML x Totvs Transmite"

oTFolder := TFolder():New(5,5,aTools,,oDlgFil,,,,.T.,,590,290)
oTFolder:bChange := {|| (cImpTraTool := "",oF1MG1:Refresh(),oF2MG1:Refresh(),oF3MG1:Refresh())}
 
//Folder COLAUTOREAD COM LOG
oF1B1 := TBrowseButton():New(05,05,"ColAutoRead com LOG",oTFolder:aDialogs[1], {|| ColAutoRead()},60,12,,,.F.,.T.,.F.,,.F.,,,)
oF1B1:SetColor( CLR_WHITE, rgb(9, 123, 152))

oF1MG1 := tMultiget():new(22,05, {| u | if( pCount() > 0, cImpTraTool := u, cImpTraTool ) },oTFolder:aDialogs[1], 580, 253, , , , , , .T. ) 

//Folder CONSULTA RECIBO
oF2B1 := TBrowseButton():New(05,05,"Consulta Recibo",oTFolder:aDialogs[2], {|| Iif(!Empty(cRecibo),ImpTraConsult(cRecibo),.F.)},60,12,,,.F.,.T.,.F.,,.F.,,,)
oF2B1:SetColor( CLR_WHITE, rgb(9, 123, 152))

oF2S1 := TSay():New(08,80,{|| 'Recibo: '},oTFolder:aDialogs[2],,,,,,.T.,,,40,12)
oF2G1 := TGet():New(05,120,{|u|If(PCount()==0,cRecibo,cRecibo := u ) },oTFolder:aDialogs[2],120,10,,,,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,,"cRecibo",,,,)

oF2MG1 := tMultiget():new(22,05, {| u | if( pCount() > 0, cImpTraTool := u, cImpTraTool ) },oTFolder:aDialogs[2], 580, 253, , , , , , .T. ) 

//Folder INCLUIR RECIBO
oF3B1 := TBrowseButton():New(05,05,"Incluir Recibo",oTFolder:aDialogs[3], {|| Iif(!Empty(cRecInc),ImpTraIncId(cRecInc,cTpXML,cDHWFil,,1),.F.)},60,12,,,.F.,.T.,.F.,,.F.,,,)
oF3B1:SetColor( CLR_WHITE, rgb(9, 123, 152))

oF3S1 := TSay():New(08,80,{|| 'Recibo: '},oTFolder:aDialogs[3],,,,,,.T.,,,40,12)
oF3G1 := TGet():New(05,120,{|u|If(PCount()==0,cRecInc,cRecInc := u ) },oTFolder:aDialogs[3],120,10,,,,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,,"cRecInc",,,,)

oF3S2 := TSay():New(08,250,{|| 'Tipo XML: '},oTFolder:aDialogs[3],,,,,,.T.,,,40,12)
oF3CB1:= TComboBox():New(07,290,{|u|if(PCount()>0,cTpXML:=u,cTpXML)},aXML,35,13,oTFolder:aDialogs[3],,{|| },,,,.T.,,,,,,,,,'cTpXML')

oF3S3 := TSay():New(08,335,{|| 'Empresa/Filial: '},oTFolder:aDialogs[3],,,,,,.T.,,,40,12)
oF3CB2:= TComboBox():New(07,375,{|u|if(PCount()>0,cDHWFil:=u,cDHWFil)},aDHWImp,100,13,oTFolder:aDialogs[3],,{|| },,,,.T.,,,,,,,,,'cDHWFil')

oF3B2 := TBrowseButton():New(05,510,"Recibos com ERRO (DHZ)",oTFolder:aDialogs[3], {|| ImpTraIdErr("2")},70,12,,,.F.,.T.,.F.,,.F.,,,)
oF3B2:SetColor( CLR_WHITE, rgb(9, 123, 152))

oF3MG1 := tMultiget():new(22,05, {| u | if( pCount() > 0, cImpTraTool := u, cImpTraTool ) },oTFolder:aDialogs[3], 580, 253, , , , , , .T. ) 

//Final Tela - Imprimir/Sair/Limpar
oT1B1 := TBrowseButton():New(305,460,"Imprimir",oDlgFil, {|| ImpTraPrint()},60,12,,,.F.,.T.,.F.,,.F.,,,)
oT1B1:SetColor( CLR_WHITE, rgb(9, 123, 152))

oT1B2 := TBrowseButton():New(305,530,"Sair",oDlgFil, {|| oDlgFil:End()},60,12,,,.F.,.T.,.F.,,.F.,,,)
oT1B2:SetColor( CLR_WHITE, rgb(9, 123, 152))

oT1B3 := TBrowseButton():New(305,390,"Limpar",oDlgFil, {|| (cImpTraTool := "",oF1MG1:Refresh(),oF2MG1:Refresh(),oF3MG1:Refresh())},60,12,,,.F.,.T.,.F.,,.F.,,,)
oT1B3:SetColor( CLR_WHITE, rgb(9, 123, 152))

ACTIVATE MSDIALOG oDlgFil CENTERED

Return

Static Function ImpTraConsult(cRecibo)

Local lFindDHY		:= .F.
Local lFindDHZ		:= .F.
Local cMsg			:= ""
Local cXMLDHZ		:= ""
Local aTpXML		:= {}
Local nY			:= 0

cImpTraTool := ""

ImpTraFind("DHY",cRecibo,@lFindDHY,@cMsg)
cImpTraTool += cMsg + CRLF
oF2MG1:Refresh()
cMsg := ""
ImpTraFind("DHZ",cRecibo,@lFindDHZ,@cMsg,@cXMLDHZ)
cImpTraTool += cMsg + CRLF
oF2MG1:Refresh()
cMsg := ""

If oComTransmite:TokenTotvsTransmite()
	If !lFindDHZ
		If "NFE" $ oComTransmite:cMVDOCIMP
			aAdd(aTpXML,{"NFE",oComTransmite:cApiUrlExpNFE,oComTransmite:cApiUrlZipNFE})
		Endif

		If "NFS" $ oComTransmite:cMVDOCIMP
			aAdd(aTpXML,{"NFS",oComTransmite:cApiUrlExpNFS,oComTransmite:cApiUrlZipNFS})
		Endif
		
		If "CTE" $ oComTransmite:cMVDOCIMP
			aAdd(aTpXML,{"CTE"  ,oComTransmite:cApiUrlExpCTE,oComTransmite:cApiUrlZipCTE})
			aAdd(aTpXML,{"CTEOS",oComTransmite:cApiUrlExpCTO,oComTransmite:cApiUrlZipCTO})
		Endif
	Else
		If "NFE" $ cXMLDHZ
			aAdd(aTpXML,{"NFE",oComTransmite:cApiUrlExpNFE,oComTransmite:cApiUrlZipNFE})
		Endif

		If "NFS" $ cXMLDHZ
			aAdd(aTpXML,{"NFS",oComTransmite:cApiUrlExpNFS,oComTransmite:cApiUrlZipNFS})
		Endif
		
		If "CTE" $ cXMLDHZ
			aAdd(aTpXML,{"CTE"  ,oComTransmite:cApiUrlExpCTE,oComTransmite:cApiUrlZipCTE})
			aAdd(aTpXML,{"CTEOS",oComTransmite:cApiUrlExpCTO,oComTransmite:cApiUrlZipCTO})
		Endif
	Endif		

	oRest 	:= FwRest():New(oComTransmite:cApiTra)
	aHeader	:= oComTransmite:GetHeader()

	For nY := 1 To Len(aTpXML)
		cMsg := ""
		oJsonResp := JsonObject():New()
		cResource := aTpXml[nY,3] + cRecibo
		oRest:SetPath(cResource) 

		cRetorno    := ""
		nStatus     := 0
		If oRest:Get(aHeader) 
			cTextJson := oRest:GetResult() 
			oJsonResp:FromJson(cTextJson)
			xRetorno    := oJsonResp:GetJsonObject("Retorno")
			cRetorno    := Iif(ValType(xRetorno)=="C",xRetorno,oJsonResp:GetJsonObject("retorno"))

			If !Empty(cRetorno)
				cMsg	+= "Recibo: " + cRecibo + " com retorno: " + SubStr(cRetorno,1,50) + CRLF
			Else
				cMsg	+= "Recibo: " + cRecibo + " sem retorno" + CRLF
			Endif

			xStatus     := oJsonResp:GetJsonObject("Status")
			nStatus     := Iif(ValType(xStatus)=="N",xStatus,oJsonResp:GetJsonObject("status"))

			xMessage     := oJsonResp:GetJsonObject("Descricao")
			cMessage     := Iif(ValType(xMessage)=="C",xMessage,oJsonResp:GetJsonObject("descricao"))

			cMsg	+= "Tipo XML: " + aTpXml[nY,1] + " Status: " + AllTrim(Str(nStatus)) + " Mensagem: " + cMessage + CRLF

			cImpTraTool += cMsg + CRLF
			oF2MG1:Refresh()
		Else
			cTextJson := oRest:GetResult()
			oComTransmite:cLastError := oRest:GetLastError()
			oComTransmite:lAPIError := .T.

			cMsg	+= "Recibo: " + cRecibo + " com erro" + CRLF
			cMsg	+= "Tipo XML: " + aTpXml[nY,1] + CRLF
			cMsg	+= " Erro cTextJson: " + cTextJson + CRLF
			cMsg	+= " Erro GetLastError: " + oRest:GetLastError() + CRLF
			
			cImpTraTool += cMsg + CRLF
			oF2MG1:Refresh()
		EndIf
	Next nY
Endif
oF2MG1:Refresh()

Return

Static Function ImpTraFind(cTab,cRecibo,lFind,cMsg,cXMLDHZ)

Local cAliasImp := GetNextAlias()
Local oQryDoc   := Nil
Local cQryStat  := ""
Local cCpo1		:= cTab + "_ID"
Local cCpo2		:= cTab + "_CODFIL"
Local cCpo3		:= cTab + "_TPXML"
Local cCpo4		:= cTab + "_STATUS"
Local cCpo5		:= ""
Local lCpoFil	:= oComTransmite:lDHYFil .And. oComTransmite:lDHZFil

If lCpoFil
	cCpo5 := cTab + "_FILTRO"
Endif

oQryDoc := FWPreparedStatement():New()  

cQry := " SELECT " + cCpo1 + ", " + cCpo2 + ", " + cCpo3 + ", " + cCpo4
If lCpoFil
	cQry += ", " + cCpo5
Endif
cQry += " FROM " + RetSqlName(cTab)
cQry += " WHERE D_E_L_E_T_ = ' '"
cQry += " AND " + cTab + "_ID = ?"
cQry := ChangeQuery(cQry)

oQryDoc:SetQuery(cQry)
oQryDoc:SetString(1,cRecibo)

cQryStat := oQryDoc:GetFixQuery()
MpSysOpenQuery(cQryStat,cAliasImp)

If (cAliasImp)->(!EOF())
	lFind := .T.
	cMsg := "Recibo: " + cRecibo + " encontrado na tabela: " + cTab + CRLF
	cMsg += "Tipo XML: " + (cAliasImp)->&(cCpo3) + ", CodFilial: " + (cAliasImp)->&(cCpo2) + " e Status: " + (cAliasImp)->&(cCpo4) + CRLF
	If lCpoFil
		cMsg += "Filtro: " + (cAliasImp)->&(cCpo5) + CRLF
	Endif

	If cTab == "DHZ"
		cXMLDHZ := (cAliasImp)->&(cCpo3)
    Endif
Else
	lFind := .F.
	cMsg := "Recibo: " + cRecibo + " não encontrado na tabela: " + cTab + CRLF
Endif

(cAliasImp)->(DbCloseArea())

Return

Static Function ImpTraDHW(aDHWTra,nOpc,cEmp,cFil)

Local cAliasImp := GetNextAlias()
Local oQryDHW   := Nil
Local cQryStat  := ""
Local aRet		:= {}
Local cRet		:= ""

oQryDHW := FWPreparedStatement():New()  

cQry := " SELECT DHW_GRPEMP, DHW_FILEMP, DHW_CODFIL"
cQry += " FROM " + RetSqlName("DHW")
cQry += " WHERE D_E_L_E_T_ = ' '"
If nOpc == 1
	cQry += " AND DHW_CODFIL IN (?)"
Elseif nOpc == 2
	cQry += " AND DHW_GRPEMP = ?"
	cQry += " AND DHW_FILEMP = ?"
Endif

cQry := ChangeQuery(cQry)

oQryDHW:SetQuery(cQry)
If nOpc == 1
	oQryDHW:SetIn(1,aDHWTra)
Elseif nOpc == 2
	oQryDHW:SetString(1,cEmp)
	oQryDHW:SetString(2,cFil)
Endif

cQryStat := oQryDHW:GetFixQuery()
MpSysOpenQuery(cQryStat,cAliasImp)

While (cAliasImp)->(!EOF())
	If nOpc == 1
		aAdd(aRet,AllTrim((cAliasImp)->DHW_GRPEMP) + " - " + AllTrim((cAliasImp)->DHW_FILEMP) )
	Elseif nOpc == 2
		cRet := (cAliasImp)->DHW_CODFIL
	Endif
	(cAliasImp)->(DbSkip())	
Enddo

(cAliasImp)->(DbCloseArea())

Return Iif(nOpc==1,aRet,cRet)

Static Function ImpTraIncId(cRecInc,cTpXML,cDHWFil,cFilCod,nOpc)

Local aDados	:= {}
Local cCodFil	:= ""
Local cMsg		:= ""
Local cFiltro	:= ""
Local lCpoFil	:= oComTransmite:lDHYFil .And. oComTransmite:lDHZFil

If nOpc == 1
	aDados	:= Separa(cDHWFil,"-")
	cCodFil	:= ImpTraDHW(,2,AllTrim(aDados[1]),AllTrim(aDados[2]))
Elseif nOpc == 2
	cCodFil	:= cFilCod
Endif

DbSelectArea("DHZ")
DHZ->(DbSetOrder(1))
If DHZ->(MsSeek(xFilial("DHZ") + PadR(cCodFil,oComTransmite:nTamCod) + PadR(cTpXML,oComTransmite:nTamTp) + PadR(cRecInc,oComTransmite:nTamId)))
	cMsg := "Recibo: " + cRecInc + " excluido do historico (DHZ)" + CRLF
	If lCpoFil
		cFiltro := DHZ->DHZ_FILTRO
	Endif

	If DHZ->(RecLock("DHZ",.F.))
		DHZ->(DbDelete())
		DHZ->(MSUNLOCK())
	Endif

	cImpTraTool += cMsg + CRLF
	oF3MG1:Refresh()
	cMsg := ""
Endif

DbSelectArea("DHY")
DHY->(DbSetOrder(1))
If !DHY->(MsSeek(xFilial("DHY") + PadR(cCodFil,oComTransmite:nTamCod) + PadR(cTpXML,oComTransmite:nTamTp) + PadR(cRecInc,oComTransmite:nTamId)))
	If RecLock("DHY",.T.)
		DHY->DHY_FILIAL := xFilial("DHY")
		DHY->DHY_CODFIL := cCodFil
		DHY->DHY_TPXML  := cTpXML
		DHY->DHY_ID     := cRecInc
		If lCpoFil
			DHY->DHY_DTID   := dDataBase
			DHY->DHY_TENT   := 0
			DHY->DHY_FILTRO := cFiltro
		Endif
		DHY->DHY_STATUS := "0"
		DHY->(MsUnlock())
	Endif
	cMsg := "Recibo: " + cRecInc + " inserido com sucesso na DHY" + CRLF
	
	cImpTraTool += cMsg + CRLF
	oF3MG1:Refresh()
Else
	cMsg := "Recibo: " + cRecInc + " ja inserido na DHY" + CRLF
	
	cImpTraTool += cMsg + CRLF
	oF3MG1:Refresh()
Endif

Return

Static Function ImpTraIdErr(cStatus)

Local cAliasImp := GetNextAlias() 
Local oQryDHZ   := Nil
Local cQryStat  := ""
Local aRet		:= {}
Local nI		:= 0
Local lCpoFil	:= oComTransmite:lDHYFil .And. oComTransmite:lDHZFil

cImpTraTool := ""

oQryDHZ := FWPreparedStatement():New()  

cQry := " SELECT DHZ_CODFIL, DHZ_ID, DHZ_TPXML"
If lCpoFil
	cQry += ", DHZ_FILTRO"
Endif
cQry += " FROM " + RetSqlName("DHZ")
cQry += " WHERE D_E_L_E_T_ = ' '"
cQry += " AND DHZ_STATUS = ?"

cQry := ChangeQuery(cQry)

oQryDHZ:SetQuery(cQry)
oQryDHZ:SetString(1,cStatus)

cQryStat := oQryDHZ:GetFixQuery()
MpSysOpenQuery(cQryStat,cAliasImp)

While (cAliasImp)->(!EOF())
	aAdd(aRet,{(cAliasImp)->DHZ_CODFIL,(cAliasImp)->DHZ_ID,(cAliasImp)->DHZ_TPXML,Iif(lCpoFil,(cAliasImp)->DHZ_FILTRO,"")})
	(cAliasImp)->(DbSkip())	
Enddo

(cAliasImp)->(DbCloseArea())

If Len(aRet) == 0
	cMsg := "Não existem recibo(s) com o status: " + cStatus
	
	cImpTraTool += cMsg + CRLF
	oF3MG1:Refresh()
Else
	For nI := 1 To Len(aRet)
		ImpTraIncId(aRet[nI,2],aRet[nI,3],,aRet[nI,1],2)
	Next nI	
Endif

Return aRet

Static Function ImpTraPrint()

Local cCaminho	:= ""
Local cLog		:= "ImpTraTool.Log"
Local cCamLog	:= ""
Local nHandle	:= 0

cCaminho := cGetFile( "*.log", "Log (.log)", 1, 'C:\', .F., nOR( GETF_LOCALHARD, GETF_LOCALFLOPPY, GETF_RETDIRECTORY ), .T., .T.)

If !Empty(cCaminho)
	cCamLog := cCaminho + cLog

	If File(cCamLog)
		FErase(cCamLog)
	Endif

	nHandle := FCREATE(cCamLog)
  
    if nHandle > 0
        FWrite(nHandle, cImpTraTool)
        FClose(nHandle)

		ShellExecute( "open", cCamLog, "", "", 1 )
    Endif
Endif

Return
