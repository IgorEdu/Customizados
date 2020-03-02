#INCLUDE "protheus.ch"
#INCLUDE "topconn.ch"
#INCLUDE "ap5mail.ch"

/*VAMILLY
+---------------------------------------------------------------------------+
|Programa  | BRAFAT03  | Autor | C้sar O Affonso     | Data | 13/02/2020    |
+----------+-----------+-------+---------------------+------+---------------+
|Descricao | Relatorio de notas pendentes de cancelamento                   |
+----------+----------------------------------------------------------------+
| Uso      | Braslar                                                        |
+---------------------------------------------------------------------------+
*/

User Function BRAFAT03()

	Private cPerg    := "BRAFAT"
	Private oExcel   := FWMsExcel():New()
	Private cDir     := "C:\TEMP\"
	Private cFileTmp := "BRAFAT"+"_"+DtoS(MsDate())+"_"+strtran(Time(),":","")+".xml"
	Private aEmp     := {} 
	Private cPathUser:= GetTempPath()
	Private lJob     := .F.
	VPerg(cPerg)
	If Pergunte(cPerg,.T.)

		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณ Seleciona Filiais para processar                     ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		dbSelectArea("SM0")
		nRecno  := Recno()
		cCodEmp := SM0->M0_CODIGO
		dbGoTop()
		While !Eof()

			If SM0->M0_CODIGO == "99"
				dbSelectArea("SM0")
				dbSkip()
				Loop
			Endif

			If aScan(aEmp,{|x| x[1] == SM0->M0_CODFIL }) == 0 

				AADD(aEmp,{SM0->M0_CODFIL, rtrim(SM0->M0_FILIAL), SM0->M0_CGC, SM0->M0_INSC })

			Endif

			dbSelectArea("SM0")
			dbSkip()

		End

		dbSelectArea("SM0")
		dbGoTo(nRecno)

		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณ Cria arquivo temporario do markbrowse                ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		MsgRun(OemToAnsi("Selecionando dados para processamento, Aguarde..."),"",{|| CursorWait(), BraNF() ,CursorArrow()})

		If __CopyFile( cDir+cFileTmp, cPathUser+cFileTmp )

			oExcelApp := MsExcel():New()
			oExcelApp:WorkBooks:Open( cPathUser+cFileTmp )
			oExcelApp:SetVisible(.T.)
			oExcelApp:Destroy() 

		Endif

	Endif

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณBRANF          บAutor ณC้sar O Affonso      บ Data ณ  13/02/2020 บฑฑ
ฑฑฬออออออออออุอออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณProcessa os dados para selecao do usuario                        บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณBraslar                                                          บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function BraNF()
Local cSQL := ""

	Private cAlias   := "RNC" //GetNextAlias() 
	Private aRetCanc := {{'   ','Nao houve tentativa de cancelamento'},;
	{'015','Cancelamento Autorizado'},;
	{'025','Cancelamento nao transmitido (Aguardando retorno do SEFAZ)'},;
	{'026','Cancelamento nao autorizado'},;
	{'030','Inutilizacao de numeracao autorizada'},;
	{'036','Cancelamento autorizado fora do prazo'}}

	cSQL := " SELECT F2_FILIAL,  A1_NOME, F2_DOC, F2_VALBRUT, F2_EMISSAO, F2_STATUS,'' AS RETSEFAZ "
	cSQL += " FROM "+RetSqlName("SF2")+" SF2 "
	cSQL += " INNER JOIN "+RetSqlName("SD2")+" SD2 ON D2_FILIAL = F2_FILIAL AND D2_DOC = F2_DOC AND D2_SERIE = F2_SERIE AND D2_CLIENTE = F2_CLIENTE AND D2_LOJA = F2_LOJA AND SD2.D_E_L_E_T_ = '' "
	cSQL += " INNER JOIN "+RetSqlName("SA1")+" SA1 ON A1_FILIAL = '"+xFilial("SA1")+"' AND A1_COD = F2_CLIENTE AND A1_LOJA = F2_LOJA AND SA1.D_E_L_E_T_ = '' "
	cSQL += " WHERE F2_FILIAL BETWEEN '" + mv_par03 + "' AND '" + mv_par04 + "' "
	cSQL += " AND F2_EMISSAO BETWEEN '"+DtoS(mv_par01)+"' AND '"+DtoS(mv_par02)+"' "
	cSQL += " AND F2_STATUS <> ''
	cSQL += " AND SF2.D_E_L_E_T_ = ''

	cSQL += " UNION "

	cSQL += " SELECT F2_FILIAL, A1_NOME, F2_DOC, F2_VALBRUT, F2_EMISSAO, F2_STATUS, '' AS RETSEFAZ "
	cSQL += " FROM "+RetSqlName("SF2")+" SF2"
	cSQL += " INNER JOIN "+RetSqlName("SD2")+" SD2 ON D2_FILIAL = F2_FILIAL AND D2_DOC = F2_DOC AND D2_SERIE = F2_SERIE AND D2_CLIENTE = F2_CLIENTE AND D2_LOJA = F2_LOJA AND SD2.D_E_L_E_T_ = '' "
	cSQL += " INNER JOIN "+RetSqlName("SA1")+" SA1 ON A1_FILIAL = '"+xFilial("SA1")+"' AND A1_COD = F2_CLIENTE AND A1_LOJA = F2_LOJA AND SA1.D_E_L_E_T_ = '' "
	cSQL += " WHERE F2_FILIAL BETWEEN '" + mv_par03 + "' AND '" + mv_par04 + "' "
	cSQL += " AND F2_EMISSAO BETWEEN '"+DtoS(mv_par01)+"' AND '"+DtoS(mv_par02)+"' "
	cSQL += " AND SUBSTRING(D2_CF,2,3) IN ('151','152')"
	cSQL += " AND F2_TIPO NOT IN ('B','D')"
	cSQL += " AND F2_CLIENTE IN ('000078')"
	cSQL += " AND SF2.D_E_L_E_T_ = ''"
	//Nใo considera as notas que foram devolvidas porque nใo puderam ser canceladas
	cSQL += " AND F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA NOT IN "
	cSQL += " (SELECT D1_NFORI+D1_SERIORI+F2_CLIENTE+F2_LOJA "
	cSQL += " FROM "+RetSqlName("SD1")+" SD1 "
	cSQL += " WHERE D1_FILIAL = F2_FILIAL "
	cSQL += " AND D1_NFORI = F2_DOC "
	cSQL += " AND D1_SERIORI = F2_SERIE "
	cSQL += " AND SD1.D_E_L_E_T_ = '') "

	cSQL += " UNION " 

	cSQL += " SELECT F3_FILIAL as F2_FILIAL, A1_NOME, F3_NFISCAL AS F2_DOC, F3_VALCONT AS F2_VALBRUT, F3_ENTRADA AS F2_EMISSAO, F3_CODRSEF AS F2_STATUS, F3_DESCRET AS RETSEFAZ"
	cSQL += " FROM "+RetSqlName("SF3")+" SF3 "
	cSQL += " INNER JOIN "+RetSqlName("SA1")+" SA1 ON A1_FILIAL = '"+xFilial("SA1")+"' AND A1_COD = F3_CLIEFOR AND A1_LOJA = F3_LOJA AND SA1.D_E_L_E_T_ = ''"
	cSQL += " WHERE F3_FILIAL BETWEEN '"+mv_par03+"' AND '"+mv_par04+"' "
	cSQL += " AND F3_ENTRADA BETWEEN '"+DtoS(mv_par01)+"' AND '"+DtoS(mv_par02)+"'"
	cSQL += " AND F3_CODRSEF <> ''"
	cSQL += " AND F3_CODRSEF <> '100'"
	cSQL += " AND F3_DTCANC = ''"
	cSQL += " AND SF3.D_E_L_E_T_ = ''"
	cSQL += " AND F3_FILIAL+F3_NFISCAL+F3_SERIE+F3_CLIEFOR+F3_LOJA IN "
	cSQL += " (SELECT F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA FROM SF2010 WHERE F2_FILIAL = F3_FILIAL AND F2_DOC = F3_NFISCAL AND F2_SERIE = F3_SERIE AND F2_CLIENTE = F3_CLIEFOR AND F2_LOJA = F3_LOJA AND D_E_L_E_T_ = '')"	
	cSQL += " ORDER BY F2_EMISSAO "

	If Select("RNC") <> 0
		dbSelectArea("RNC")
		dbCloseArea()
	Endif
	TcQuery cSQL NEW ALIAS "RNC"
	TCSETFIELD("RNC","F2_EMISSAO","D",08,00)
    MemoWrit("C:\Temp\BraFat.sql", cSQL) 	
	

	cSQL := " SELECT '' F2_FILIAL, 'Erro na Sequencia de Notas Fiscais' A1_NOME,'' F2_DOC,''  F2_VALBRUT,  '' F2_EMISSAO, '' F2_STATUS, '' RETSEFAZ " 
	cSQL += " UNION "
	cSQL += " SELECT '' F2_FILIAL, 'NF Inicial' A1_NOME, 'NF Final' F2_DOC, 'ERRO_SEQ' F2_VALBRUT, '' F2_EMISSAO, '' F2_STATUS, '' RETSEFAZ "
	cSQL += " UNION "
	cSQL += " SELECT '01' F2_FILIAL, Cast(SEQ.N_DOCA As varchar) A1_NOME, Cast(SEQ.N_DOC As varchar) F2_DOC, Cast(ERRO_SEQ As varchar) F2_VALBRUT, '' F2_EMISSAO, '' F2_STATUS, '' RETSEFAZ "
	cSQL += " FROM "
	cSQL += "     (SELECT F2_DOC - 1 N_DOC, LAG(F2_DOC, 1,0) OVER (ORDER BY F2_DOC) + 1 N_DOCA, "                
	cSQL += "         CASE WHEN Cast(LAG(F2_DOC, 1,0) OVER (ORDER BY F2_DOC) as int) > 0 "           
	cSQL += "              THEN  Cast(SF2.F2_DOC As int)  - Cast(LAG(F2_DOC, 1,0) OVER (ORDER BY F2_DOC) as int) - 1 " 			       
	cSQL += "             ELSE  0 "
	cSQL += "         END ERRO_SEQ " 	           
	cSQL += "         FROM " + RetSqlName("SF2") + " SF2) SEQ " 	   
	cSQL += " WHERE ERRO_SEQ > 0 " 
	
	If Select("SNF") <> 0
		dbSelectArea("SNF")
		dbCloseArea()
	Endif
	TcQuery cSQL NEW ALIAS "SNF"
	MemoWrit("C:\Temp\BraFat01.sql", cSQL) 




/*
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Gera Planilha Excel com as informacoes               ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If (cAlias)->(!Eof())
		If !lJob
			BRAExcel()
		Else
			BRAEmail()
		Endif
	Endif
*/
BRAExcel()
If Select("RNC") <> 0
	dbSelectArea("RNC")
	dbCloseArea()
Endif
If Select("SNF") <> 0
	dbSelectArea("SNF")
	dbCloseArea()
Endif

Return   

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณBRAExcel      บAutor ณCesar O Affonso       บ Data ณ  13/02/2020 บฑฑ
ฑฑฬออออออออออุอออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณProcessa os dados para gerar Excel                               บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSELENA                                                           บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function BRAExcel()

	Local cExcel    := "Notas com Cancelamento Pendente" 
	Local cPlanilha := "Notas" //"Plan1"
	Local i

	//Cria Planilha
	oExcel:AddworkSheet(cExcel)
	oExcel:AddTable(cExcel,cPlanilha)
	oExcel:AddColumn(cExcel,cPlanilha,"Filial",1,1)
	oExcel:AddColumn(cExcel,cPlanilha,"Cliente",1,1)
	oExcel:AddColumn(cExcel,cPlanilha,"Nota Fiscal",1,1)
	oExcel:AddColumn(cExcel,cPlanilha,"Emissao",1,4)
	oExcel:AddColumn(cExcel,cPlanilha,"Valor",3,2)
	oExcel:AddColumn(cExcel,cPlanilha,"Status",1,1)
	//oExcel:AddColumn(cExcel,cPlanilha,"Usuแrio",1,1)

	("RNC")->(dbGoTop())
	While ("RNC")->(!Eof())

		aDados := {}

		AADD(aDados, aEmp[aScan( aEmp,{|x| left(x[1],6) == ("RNC")->F2_FILIAL }) ][2])
		AADD(aDados, rtrim(("RNC")->A1_NOME))
		AADD(aDados, rtrim(("RNC")->F2_DOC)  )
		AADD(aDados, DtoC(("RNC")->F2_EMISSAO) )
		AADD(aDados, ("RNC")->F2_VALBRUT )
		AADD(aDados, aRetCanc[aScan( aRetCanc,{|x| x[1] == ("RNC")->F2_STATUS }) ][2]) 
		//AADD(aDados, UsrRetName((cAlias)->F2_XUSERID))

		oExcel:AddRow(cExcel,cPlanilha,aDados)        

		("RNC")->(dbSkip()) 
	End
	
	("SNF")->(dbGoTop())
	While ("SNF")->(!Eof())

		aDados := {}

		AADD(aDados, aEmp[aScan( aEmp,{|x| left(x[1],6) == ("SNF")->F2_FILIAL }) ][2])
		AADD(aDados, rtrim(("SNF")->A1_NOME))
		AADD(aDados, rtrim(("SNF")->F2_DOC)  )
		AADD(aDados, DtoC(("SNF")->F2_EMISSAO) )
		AADD(aDados, ("SNF")->F2_VALBRUT )
		AADD(aDados, aRetCanc[aScan( aRetCanc,{|x| x[1] == ("SNF")->F2_STATUS }) ][2]) 
		//AADD(aDados, UsrRetName((cAlias)->F2_XUSERID))

		oExcel:AddRow(cExcel,cPlanilha,aDados)        

		("SNF")->(dbSkip()) 
	End

	oExcel:SetLineSizeFont(10) //Cor de fonte da linha (Preto)
	oExcel:Set2LineSizeFont(10) //Cor de fonte da linha (Preto)

	oExcel:SetLineFrColor('#000000') //Cor de fonte da linha (Preto)
	oExcel:SetLineBgColor('#FFFFFF') //Cor de preenchimento da linha (Branco)

	oExcel:Set2LineFrColor('#000000') //Cor de fonte da linha 2 (Preto)
	oExcel:Set2LineBgColor('#FFFFFF') //Cor de preenchimento da linha 2 (Branco)

	oExcel:Activate()
	oExcel:GetXMLFile(cDir+cFileTmp)

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณ ENVEMAIL ณ Autor ณ C้sar O Affonso     ณ Data ณ 13/02/2020 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณ Envia e-mail da Cota็ใo para o Fornecedor                  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณUso       ณ Braslar                                                    ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Static Function BRAEmail()

	Local nI        := 1
	Local cMensagem := BRAHTML()
	Local lOk 
	Local lAutOk     := .F.
	Local lSmtpAuth  := GetMv("MV_RELAUTH",,.F.)
	Local cServer    := GetMV("MV_RELSERV")
	Local cPSW       := GetMV("MV_RELPSW")	// acrescentado parametro da senha
	Local cCnt       := GetMV("MV_RELACNT")  // acrescentado parametro da conta de email
	Local lSendOk    := .F.
	Local cAnexos    := ""
	local cSubject   := "[Braslar] Notas com cancelamento pendente"
	Local _cPara     := GetMV("MV_BRAMAIL")
	Local _cUsr      := 'ti@fogoesbraslar.com.br'    
	Local _cCco      := ''//'edinei@vamilly.com.br'    
	Local _Ccc       := ''        

	CONNECT SMTP SERVER cServer ACCOUNT cCnt PASSWORD cPSW TIMEOUT 60 RESULT lOk

	//Retirar comentario para teste
	//_cPara := _cCc := _cCco := _cUsr := 'edinei@vamilly.com.br'//    'edinei@vamilly.com.br'
	//_cPara := 'joelma@kraemer.com.br'
	//_cCCo  := 'edinei@vamilly.com.br'

	If !lAutOk 
		If ( lSmtpAuth ) 
			lAutOk := MailAuth(cCnt,cPSW)
		Else
			lAutOk := .T.
		EndIf 
	EndIf 			        

	If lOk .And. lAutOk
		SEND MAIL FROM rtrim(_cUsr);
		TO rtrim(_cPara);
		CC rtrim(_cCc);
		BCC rtrim(_cCco);
		SUBJECT cSubject ;
		BODY  cMensagem ;
		ATTACHMENT cAnexos;
		RESULT lSendOK
		If !lSendOk
			GET MAIL ERROR cError
			//MsgInfo(cError, "Erro no envio do e-mail. Tente Novamente") 
			Conout("Erro: "+cError+" no envio do e-mail. Tente Novamente") 
		Else
			Conout("e-mail enviado com sucesso para "+_cPara+";"+_cCc+";"+_cCco)
		EndIf
	Else
		GET MAIL ERROR cError
		//MsgInfo(cError, "Erro no envio do e-mail. Tente Novamente") 		
		Conout(cError+" Erro no envio do e-mail. Tente Novamente") 		
	Endif 

	DISCONNECT SMTP SERVER 

Return Nil 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณBRAHTML       บAutor ณ Cesar O Affonso      บ Data ณ  13/02/2020 บฑฑ
ฑฑฬออออออออออุอออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณProcessa os dados para gerar e-mail                              บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณBRASLAR                                                          บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function BRAHTML()

	Local cHtml := ""

	cHtml := '<!DOCTYPE html> '
	cHtml += ' <html>'
	cHtml += ' 	<head>'
	cHtml += ' 		<meta charset="utf-8">'
	cHtml += ' 	</head>'

	cHtml += ' 	<body style="margin-bottom:20px;background-color:#c8e6c9 !important;width:1024px;margin:auto;font-family: Helvetica Neue,Helvetica,Arial,sans-serif;color:#333;">'

	cHtml += ' 		<div style="padding: 20px; margin-top:25px; background-color:#fff; border-style: double; border-width: 3px; border-color: #66bb6a; text-align: center;">'

	cHtml += ' 			<table style="table-layout:fixed; width:100%;">'
	cHtml += ' 				<tr>'
	//cHtml += ' 					<td style="width:30%;">'
	//cHtml += ' 						<img  src="http://www.vamilly.com.br/logo_clientes/logo_kraemer.png" width="270" height="100">'
	//cHtml += ' 					</td>'
	cHtml += ' 					<td style="width:40%;text-align:left;">'
	cHtml += ' 						<p style="margin-left:30px;"><strong>Braslar do Brasil Ltda</strong></p>			'
	cHtml += ' 						<p style="font-size:12px;margin-left:30px;">Av. Continental, s/n - Cara-Cara,Ponta Grossa - PR, CEP: 84043-735 (42) 3220-5650</p>'
	cHtml += ' 					</td>'
	cHtml += '     			</tr>'
	cHtml += ' 			</table>'
	cHtml += ' 		</div>'

	cHtml += ' 		<div style="padding: 20px; margin-top:25px; margin-bottom:25px; background-color:#fff; border-style: double; border-width: 3px; border-color: #66bb6a">'
	/*
	cHtml += ' 			<td style="width:40%;text-align:left;">
	cHtml += ' 				<p style="margin-left:30px;"><strong>NOTAS COM CANCELAMENTO PENDENTE</strong></p>		
	cHtml += ' 			</td>
	*/
	cHtml += ' 			<table style="text-align:left;border-spacing: 0;border-collapse: collapse; line-height:2; width: 100%;">'
	cHtml += ' 				<thead>'
	cHtml += ' 					<tr style="font-size:11px; border-bottom: 1px solid #ddd;">'
	cHtml += '					<th>Filial</th>'
	cHtml += '					<th>Cliente</th>'
	cHtml += '					<th>Nota Fiscal</th>'
	cHtml += '					<th>Emissao</th>'
	cHtml += '					<th>Valor</th>'
	cHtml += '					<th>Status</th>'
	cHtml += '					<th>Usuario</th>'
	cHtml += ' 					</tr>'
	cHtml += ' 				</thead>'
	cHtml += ' 				<tbody style="font-size:11px;">'

	(cAlias)->(dbGoTop())
	While (cAlias)->(!Eof())

		cHtml += ' 		<tr style="border-bottom: 1px solid #ddd;">'
		cHtml += ' 		<td>'+aEmp[aScan( aEmp,{|x| left(x[1],6) == (cAlias)->F2_FILIAL }) ][2]+'</td>'
		cHtml += ' 		<td>'+rtrim((cAlias)->A1_NOME)+'</td>'
		cHtml += ' 		<td>'+rtrim((cAlias)->F2_DOC)+'</td>'
		cHtml += ' 		<td>'+DtoC((cAlias)->F2_EMISSAO)+'</td>'
		cHtml += ' 		<td>'+Transform((cAlias)->F2_VALBRUT,"@E 9,999,999.99")+'</td>'
		If Empty((cAlias)->RETSEFAZ)
			cHtml += ' 		<td>'+aRetCanc[aScan( aRetCanc,{|x| x[1] == (cAlias)->F2_STATUS }) ][2]+'</td>'
			//cHtml += ' 		<td>'+UsrRetName((cAlias)->F2_XUSERID)+'</td>'
		Else
			cHtml += ' 		<td>'+(cAlias)->RETSEFAZ+'</td>'
			cHtml += ' 		<td>'+''+'</td>'

		Endif
		cHtml += '  	</tr>'				

		(cAlias)->(dbSkip()) 

	End

	cHtml += ' 				</tbody>'
	cHtml += ' 			</table>'
	cHtml += ' 		</div>'
	cHtml += ' 	</body>'
	cHtml += ' </html>'

Return(cHtml)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณRPTDIARJOBบAutor  ณ                    บ Data ณ  11/04/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณExecuta funcao via JOB                                      บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function BRAJ01()

	Private cPerg    := "BRAJ01"
	Private lJob     := .T.
	Private aEmp     := {} 

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Seta job para nao consumir licencas                                 ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	RpcSetType(3)
	Conout(DtoC(MsDate())+" - "+Time()+" - "+"Entrou agendamento")

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Inicia nova sessao 									                                ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	RpcSetEnv('01','01  01',,,,,{})

	Conout(DtoC(MsDate())+" - "+Time()+" - "+"Iniciando Relat๓rios Diแrios") 

	Pergunte(cPerg,.F.)
	mv_par01 := DToS(Ddatabase) //Ctod("01/08/17")
	mv_par02 := DToS(Ddatabase) //Ctod("31/12/49")
	mv_par03 := ""
	mv_par04 := "ZZZZZZ"

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Seleciona Filiais para processar                     ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	dbSelectArea("SM0")
	nRecno  := Recno()
	cCodEmp := SM0->M0_CODIGO
	dbGoTop()
	While !Eof()

		If SM0->M0_CODIGO == "99"
			dbSelectArea("SM0")
			dbSkip()
			Loop
		Endif

		If aScan(aEmp,{|x| x[1] == SM0->M0_CODFIL }) == 0 

			AADD(aEmp,{SM0->M0_CODFIL, rtrim(SM0->M0_FILIAL), SM0->M0_CGC, SM0->M0_INSC })

		Endif

		dbSelectArea("SM0")
		dbSkip()

	End

	dbSelectArea("SM0")
	dbGoTo(nRecno)

	BraNF() //Relatorio de VENDAS automatico

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Libera ambiente                                                     ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	RpcClearEnv()

	Conout(DtoC(MsDate())+" - "+Time()+" - "+"Finalizando Relat๓rios Diแrios")

Return 

/* Perguntas */
Static Function VPerg(cPerg)
aArea := GetArea()
DBSelectArea("SX1")
DBSetOrder(1)
cPerg := PADR(cPerg,10)
aRegs := {}



Aadd(aRegs,{cPerg,"01","Data Inicial ?"   ,"","","mv_ch1","D",08,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
Aadd(aRegs,{cPerg,"02","Data Final ? "    ,"","","mv_ch2","D",08,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
Aadd(aRegs,{cPerg,"03","Emp/Fil Inicial?" ,"","","mv_ch3","C",06,0,0,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
Aadd(aRegs,{cPerg,"04","Emp/Fil Final?"   ,"","","mv_ch4","C",06,0,0,"G","","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})

For I:=1 to Len(aRegs)
	If !DBSeek(PADR(cPerg,10) + aRegs[I,2])
		RecLock("SX1",.T.)
		For J:=1 to Max(FCount(), Len(aRegs[I]))
			FieldPut(J,aRegs[I,J])
		Next
		MsUnlock()
	Endif
Next

RestArea(aArea)
Return
