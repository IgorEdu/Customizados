#Include "PROTHEUS.CH"
#Include "RWMAKE.CH"        // incluido pelo assistente de conversao do AP5 IDE em 02/08/01
#Include "RPTDEF.CH"
#Include "FWPRINTSETUP.CH"
#Include 'PARMTYPE.CH'
#Include 'TOPCONN.CH'

Static _cRepDb	:= GetSrvProfString("RepositInDataBase","")
Static _cRep	:= SuperGetMv("MV_REPOSIT",.F.,"1")
Static _lRepDb	:= ( _cRepDb == "1" .And. _cRep == "2" )

/*/{Protheus.doc} ETIQBAR
Função para impressão das etiquetas de produto acabado da Braslar.
@author Braslar
@since -
@return return, return_description
@history 27/11/2019, Vamilly-Gabriel Alencar, Implementado lógica da tela mediadora dos seriais a imprimir.
/*/
User Function ETIQBAR()
	// [1] Altura inicial
	// [2] Largura inicial
	// [3] Altura final
	// [4] Largura final
	Private alDms := FWGetDialogSize(oMainWnd)
	Private _qimp := 0

	DEFINE MSDIALOG oDlg FROM  60,30 TO 220, 220 TITLE "Impressão de Etiquetas"  PIXEL

		@ 013, 023 SAY OemToAnsi("Quantas etiquetas? :")  SIZE 065, 08 PIXEL OF oDlg
		@ 023, 023 MSGET _qimp PICTURE "@E 9999" WHEN .T. SIZE 040, 10 PIXEL OF oDlg

		@ 040,025 BmpButton Type 1 Action (nOpc:=1,close(oDlg))
		@ 040,055 BmpButton Type 2 Action (nOpc:=0,close(oDlg))

	ACTIVATE MSDIALOG oDlg CENTERED

	If nOpc == 1
		fPrepare(_qimp)
	Endif

Return(Nil)

/*/{Protheus.doc} fPrepare
Rotina mediadora dos seriais a imprimir, para permitir reimpressões em casos de falhas.
@author VAMILLY-Gabriel Alencar
@since 27/11/2019
@return return, return_description
@param nQtdEtiquetas, numeric, Quantidade de etiquetas a serem geradas (seriais).
/*/
Static Function fPrepare(nQtdEtiquetas)
	Local nI := 0
	Local lMarcar := .F.

	Local aSeek := {}
	Local aCampos := {}
	Local aColunas := {}

	Local oPanel := Nil
	Local oBrowse := Nil
	Local oFWLayer := Nil
	Local oDlgSerial := Nil
	Local oTempTable := FWTemporaryTable():New("TRB")

	// Caso não hajam etiquetas a gerar, cancela o processo
	If nQtdEtiquetas <= 0
		Return Nil
	EndIf

	// Criação da estrutura de campos
	aadd(aCampos,{"TR_OK"     	, "C", 002						, 0})
	aadd(aCampos,{"TR_NROETIQ"	, "C", 004						, 0})
	aadd(aCampos,{"TR_SERIAL"	, "C", TamSX3("Z02_SEQUEN")[1]	, 0})
	oTempTable:SetFields(aCampos)

	// Criação de Indices da tabela temporária
	oTempTable:AddIndex("IDX01", {"TR_NROETIQ"})
	oTempTable:AddIndex("IDX02", {"TR_SERIAL"})

	// Criação da tabela temporária no DB
	oTempTable:Create()

	// Gera um serial para cada etiqueta e guarda na tabela temporária
	For nI := 1 to nQtdEtiquetas

		RecLock("TRB", .T.)
			TRB->TR_OK 		:= ""
			TRB->TR_NROETIQ := StrZero(nI, 4)
			TRB->TR_SERIAL 	:= U_etiqueta()
		TRB->(MsUnlock())

	Next

	// Cria janela de diálogo do tipo modal
	oDlgSerial := MSDialog():New(alDms[1],alDms[2],alDms[3],alDms[4],"Etiquetas de Produto Acabado",,,.F.,,,,,,.T.,,,.T.)

	// Cria uma camada dentro do Dialog atual
	oFWLayer := FWLayer():New() // cria camada
	oFWLayer:Init(oDlgSerial, .F., .T.) // define em qual dialog a camada será inicializada
	oFWLayer:AddLine('UP', 100, .F.) // segmenta a camada em uma linha e define sua proporção perante o dialog principal
	oPanel := oFWLayer:GetLinePanel('UP') // retorna o objeto do painel referente à segmentação realizada

	// Cria a pesquisa que será apresentada na tela
	aAdd(aSeek,{"Nro. Etiqueta",{{"","C", 004						, 0, "Nro. Etiqueta" , "@!"}}})
	aAdd(aSeek,{"Serial"       ,{{"","C", TamSx3("Z02_SEQUEN")[1]	, 0, "Serial"        , "@!"}}})

	// Estrutura do FwMarkBrowse somente para tabelas temporárias
	// [n][01] Descrição do campo
	// [n][02] Nome do campo
	// [n][03] Tipo
	// [n][04] Tamanho
	// [n][05] Decimal
	// [n][06] Picture
	aadd(aColunas,{"Nro Etiqueta", "TR_NROETIQ"	, "C", 004					 	, 0, "@!"})
	aadd(aColunas,{"Serial"		 , "TR_SERIAL"	, "C", TamSx3("Z02_SEQUEN")[1]	, 0, "@!"})

	// Cria browse de marcação para seleção dos seriais desejados
	oBrowse := FwMarkBrowse():New()
	oBrowse:SetOwner(oPanel) // Indica o container para criação do Browse
	oBrowse:DisableConfig() // Desabilita a utilização das configurações do Browse
	// oBrowse:DisableReport() // Desabilita a impressão das informações disponíveis no Browse
	// oBrowse:SetLineHeight(30) // Indica a altura da linha no Browse
	// oBrowse:SetFontBrowse(oFont) // Define a fonte do Browse
	oBrowse:SetDescription("Etiquetas de PA") // Obs.: só funciona junto à opção de filtro/botões
	oBrowse:ForceQuitButton(.T.) // Força a exibição do botão de saída do Browse
	oBrowse:SetAlias('TRB') // Define a tabela/tabela temporária
	oBrowse:SetFieldMark('TR_OK') // Campo da tabela/tabela temporária a ser utilizado pela coluna de marcação (checkbox)
	oBrowse:SetAllMark({|| BrwInvert(oBrowse:Mark(), lMarcar := !lMarcar), oBrowse:Refresh(.T.) }) // Indica o Code-Block executado no clique do header da coluna de marca/desmarca
	oBrowse:SetFields(aColunas) // Define as colunas do Browse
	oBrowse:SetSeek(.T., aSeek) // Habilita a pesquisa do Browse
	oBrowse:AddButton("Imprimir", {|| (nOpc := 1, RptStatus({|| RptDetalhe(oBrowse:Mark()) }), oBrowse:Refresh(.T.) )},,,, .F., 2)
	oBrowse:AddButton("Cancelar", {|| (nOpc := 2, oDlgSerial:End())}, , , , .F., 2)
	oBrowse:SetTemporary(.T.) // Indica que o Browse utiliza tabela temporária
	oBrowse:SetIgnoreARotina(.T.) // Indica que a mbrowse, ira ignorar a variavel private aRotina na construção das opções de menu.
	oBrowse:SetMenuDef("SemMenu") // Indica o programa que será utilizado para a carga do menu funcional. Obs.: Feito assim para não conflitar com o Browse da rotina padrão
	oBrowse:Activate()

	oDlgSerial:lCentered := .T. // centraliza dialog
	oDlgSerial:Activate() // ativa o dialog

	If Select("TRB") > 0
		TRB->(DBCloseArea())
	EndIf

Return Nil

/*/{Protheus.doc} BrwInvert
Função para tratar a a marcação de todos os itens do Browse.
@author VAMILLY-Gabriel Alencar
@since 27/11/2019
@return return, return_description
@param cMark, characters, Marcação utilizada pelo browse
@param lMarcar, logical, Identificador se é para marcar ou desmarcar
/*/
Static Function BrwInvert(cMark, lMarcar)
	Local aArea := GetArea()

	DBSelectArea("TRB")
	TRB->(DBSetOrder(1)) // TR_NROETIQ
	TRB->(DBGoTop())

	While !TRB->(Eof())

		RecLock("TRB", .F. )
			TRB->TR_OK := IIF(lMarcar, cMark, "  ")
		TRB->(MsUnlock())

	    TRB->(DBSkip())
	EndDo

	RestArea(aArea)

Return .T.

/*/{Protheus.doc} RptDetalhe
Processa a geração da etiqueta de cada serial.
@author Braslar
@since -
@return return, return_description
@param cMark, characters, Texto de marcação utilizado pelo Browse.
@history 27/11/2019, Vamilly-Gabriel Alencar, Refatorado rotina para FWMSPrinter, pois na Release 23 não estava
funcionando o TMSPrinter, e a Braslar usa as impressoras Elgin, e estas não são compatíveis com o MSCBPrinter.
/*/
Static Function RptDetalhe(cMark)

	//Local cEtiq
	Local cInfEt1	:= ""
	Local cInfEt2	:= ""
	Local cInfEt3	:= ""
	Local cInfEt4	:= ""
	Local cInfEt5	:= ""
	Local cInfEt6	:= ""
	Local cSerial	:= ""
	Local cImgGeral := "\cprova\Geral.jpg"
	Local cDescCient:= ""

	Local aAreaTRB := TRB->(GetArea())

	Local lImpImg := .F.
	Local lHasLogo := .F.

	Private oFont01
	Private oFont01N
	Private oFont03
	Private oFont03N
	Private lAdjustToLegacy
	Private lDisableSetup


	oFont01  := Tfont():New("Arial",,14,,.F.,,,,.F.,.F.,)
	oFont01N := Tfont():New("Arial",,14,,.T.,,,,.F.,.F.,)
	oFont03  := Tfont():New("Arial",,08,,.F.,,,,.F.,.F.,)
	oFont03N := Tfont():New("Arial",,08,,.T.,,,,.F.,.F.,)

	lAdjustToLegacy := .F.
	lDisableSetup  := .F.
	oPrint := FWMSPrinter():New("Etiquetas", IMP_SPOOL, .F., , lDisableSetup,,,"", .F.)
	oPrint:SetResolution(78)
	oPrint:SetPortrait()

	cCod		:= SC2->C2_PRODUTO
	cDescProd 	:= AllTrim(Posicione("SB1",1,xFilial("SB1")+cCod,"B1_DESC"))
	cGTIN 		:= AllTrim(Posicione("SB1",1,xFilial("SB1")+cCod,"B1_CODGTIN"))

	DbSelectArea("SB5")
	SB5->(DbSetOrder(1))
	SB5->(DbGoTop())
	If SB5->(DbSeek(xFilial("SB5") + cCod ))
		cDescCient 	:= SB5->B5_CEME
		cInfEt1	:= SubStr(SB5->B5_ETIQ01,1,30)
		cInfEt2	:= SubStr(SB5->B5_ETIQ02,1,30)
		cInfEt3	:= SubStr(SB5->B5_ETIQ03,1,30)
		cInfEt4	:= SubStr(SB5->B5_ETIQ04,1,30)
		cInfEt5	:= SubStr(SB5->B5_ETIQ05,1,30)
		cInfEt6	:= SubStr(SB5->B5_ETIQ06,1,30)
	EndIf

	//B1_CODGTIN
	If !Empty(SC2->C2_PEDIDO)
		DbSelectArea("SC5")
		SC5->(DbSetOrder(1))
		SC5->(DbGoTop())
		If SC5->(DbSeek(xFilial("SC5") + SC2->C2_PEDIDO))
			If !Empty (Posicione("SA1",1,xFilial("SA1")+SC5->C5_CLIENTE + SC5->C5_LOJACLI,'A1_BITMAP'))
				lImpImg	:= .T.
			EndIf
		EndIf
	EndIf

	// Posiciona na tabela temporária
	DBSelectArea("TRB")
	TRB->(DBSetOrder(1)) // TR_NROETIQ
	TRB->(DBGoTop())

	While !TRB->(Eof())

		// Verifica se a etiqueta em questão está marcada para ser impressa
		If TRB->TR_OK != cMark
			TRB->(DBSkip())
			Loop
		EndIf

		nLin := 08
		cSerial := TRB->TR_SERIAL

		oPrint:StartPage()

		// Início Cabeçalho

		// Se o item Fogão a lenha, põe a logo da Geral
		If Left(cCod, 4) == "1004"
			oPrint:SayBitmap(05,090, cImgGeral, 100, 30)
			nLin += 34
			lHasLogo := .T.
		EndIf

		// Quando houver logo do cliente não imprime os dados da Braslar
		If !lImpImg
			// Testando foi detectado que para fonte oFont03 cabem 56 caracteres
			oPrint:Say( nLin, 00, PadC("BRASLAR DO BRASIL LTDA",112) , oFont03)
			nLin += 8
			oPrint:Say(nLin, 00, "AVENIDA CONTINENTAL, nº S/N - DISTRITO INDUSTRIAL - PONTA GROSSA - PR", oFont03)
			nLin += 8
			oPrint:Say(nLin, 00, PadC("CNPJ:04.016.420/0001-17 - Insc. 90219779666", 112), oFont03)
			nLin += 8
			oPrint:Say(nLin, 00, PadC("TELEFONE:42 32205650 Web Site: www.fogoesbraslar.com.br", 112), oFont03)
			nLin += 8
			oPrint:Say(nLin, 00, Replicate("_", 073), oFont03)
		Else
			oPrint:SayBitmap(05,050, fFoto(), 181, 56)
			nLin += 42
			// lHasLogo := .T.
		EndIf

		// Fim cabeçalho

		// Dados do Produto
		// Testando foi detectado que para fonte oFont01N cabem 39 caracteres
		nLin += 14
		oPrint:Say(nLin, 00, PadC(cCod, 80), oFont01N)
		nLin += 10
		oPrint:Say(nLin, 00, PadC(AllTrim(MemoLine(cDescProd,39,1)), 39), oFont01N)

		If !Empty(MemoLine(cDescProd,39,2))
			nLin += 10
			oPrint:Say(nLin, 00, PadC(AllTrim(MemoLine(cDescProd,39,2)), 39), oFont01N)
		EndIf

		// Só imprime essa parte quando não estiver logo no cabeçalho
		If !lHasLogo
			// Complemento do produto
			nLin += 6
			oPrint:Say(nLin, 00, Replicate("_", 073), oFont03)
			nLin += 10
			oPrint:Say(nLin, 00, cDescCient, oFont03N)
			nLin += 2
			oPrint:Say(nLin, 00, Replicate("_", 073), oFont03)

			// Informações adicionais do produto
			nLin += 14
			oPrint:Say(nLin, 0, cInfEt1, oFont03)
			oPrint:Say(nLin, 150, cInfEt2, oFont03)

			nLin += 8
			oPrint:Say(nLin, 0, cInfEt3, oFont03)
			oPrint:Say(nLin, 150, cInfEt4, oFont03)

			nLin += 8
			oPrint:Say(nLin, 0, cInfEt5, oFont03)
			oPrint:Say(nLin, 150, cInfEt6, oFont03)
		EndIf

		// Data e Serial
		nLin += 6
		oPrint:Say(nLin, 00, Replicate("_", 075), oFont03)

		nLin += 14
		oPrint:Say(nLin, 0, dToC(dDataBase), oFont01)
		oPrint:Say(nLin, 150, cSerial, oFont01)

		nLin += 6
		oPrint:Say(nLin, 00, Replicate("_", 075), oFont03)

		nLin += 14
		oPrint:Say(nLin, 150, "INDUSTRIA BRASILEIRA", oFont03)

		// Códigos de barras
		oPrint:Code128(166/*nRow*/ ,0/*nCol*/, cSerial/*cCode*/,1/*nWidth*/,40/*nHeigth*/,.F./*lSay*/,,180)
		oPrint:FWMSBAR("EAN13" /*cTypeBar*/,13.5/*nRow*/ ,16/*nCol*/ , cGTIN /*cCode*/,oPrint/*oPrint*/,/*lCheck*/,/*Color*/,/*lHorz*/, 0.020/*nWidth*/,1.2/*nHeigth*/,/*lBanner*/,"Arial" /*cFont*/, /*cMode*/,.F./*lPrint*/,/*nPFWidth*/,/*nPFHeigth*/, .F. /*lCmtr2Pix*/)

		oPrint:EndPage()

		TRB->(DBSkip())
	EndDo

	If oPrint:nModalResult == PD_OK
		oPrint:Preview()
	EndIf

	//oPrint:Print()
	Conout("Final")

	RestArea(aAreaTRB)

Return

Static Function fFoto(cComponente)

	Local aArea		:= GetArea()
	Local cAlias	:= "PROTHEUS_REPOSIT"
	Local cBmpPict	:= ""
	Local cPath		:= "\cprova\"	//GetSrvProfString("Startpath","")
	Local lFile
	Local oDlg8
	Local oBmp

	/*dbSelectArea("SB5")
	SB5->(DbSetOrder(1))  // B1_FILIAL+B1_COD
	SB5->(DbGoTop())
	If !SB5->(DbSeek(xFilial("SB5") + cComponente))
		Alert("Produto nao " + cComponente + " encontrado! ")
	EndIf
	*/

	/*
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³ Carrega a Foto do Produto								   ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	cBmpPict := Upper( AllTrim( SA1->A1_BITMAP))
	cPathPict 	:= ( cPath + cBmpPict )

	//ConOut("Produto: "+SB5->B5_COD+" Imagem: "+cPathPict)
	/*
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³ Para impressao da foto eh necessario abrir um dialogo para   ³
	³ extracao da foto do repositorio.No entanto na impressao,nao  |
	³ ha a necessidade de visualiza-lo( o dialogo).Por esta razao  ³
	³ ele sera montado nestas coordenadas fora da Tela             ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	DEFINE MSDIALOG oDlg8   FROM -1000000,-4000000 TO -10000000,-8000000  PIXEL
	@ -10000000, -1000000000000 REPOSITORY oBmp SIZE -6000000000, -7000000000 OF oDlg8

	If _lRepDb
		dbSelectArea(cAlias)
		(cAlias)->( dbSeek(cBmpPict) )
	EndIf

	// Verifica se a imagem existe no repositorio
	If oBMP:ExistBMP(cBmpPict)
		If !_lRepDb
			oBmp:LoadBmp(cBmpPict)
		EndIf

		//-- Box com  Foto
		//oPrint:Box( 380,60,900, 460 )
		IF !Empty( cBmpPict := Upper( AllTrim( SA1->A1_BITMAP ) ) )
			If File(cPathPict+".JPG")

				If (FERASE(cPathPict+".JPG") == -1)
					ConOut("Falha na deleção do Arquivo: "+cPathPict+".JPG")
				EndIf
			EndIf

			If File(cPathPict+".BMP")

				If  (FERASE(cPathPict+".BMP") == -1)
					ConOut("Falha na deleção do Arquivo: "+cPathPict+".BMP")
				Endif
			EndIf

			lFile:=oBmp:Extract(cBmpPict, cPathPict)

			If lFile
				If File(cPathPict+".JPG")
					//:SayBitmap(400,75,cPathPict + ".JPG",370,480)
					//aAdd(aFotos,cPathPict + ".JPG")

					cLocalImg	:= "C:\TEMP\" + LOWER(AllTrim( SA1->A1_BITMAP ))  + ".jpg"
					cPathPict	:= cPathPict + ".JPG"
					CpyS2T( cPathPict , "C:\TEMP\", .T. , .T. )
					ConOut("Extraido arquivo: "+cPathPict)
				ElseIf File(cPathPict+".BMP")
					//oPrint:SayBitmap(400,75,cPathPict + ".BMP",370,480)
					//aAdd(aFotos,cPathPict + ".BMP")

					cLocalImg	:= "C:\TEMP\" + LOWER(AllTrim( SA1->A1_BITMAP ))  + ".bmp"
					cPathPict	:= cPathPict + ".BMP"
					CpyS2T( cPathPict , "C:\TEMP\", .T. , .T. )
					ConOut("Extraido arquivo: "+cPathPict)
				EndIf
			EndIf
		EndIf
	EndIf

	ACTIVATE MSDIALOG oDlg8 ON INIT (oBmp:lStretch := .T., oDlg8:End())

	RestArea(aArea)

Return (cLocalImg)

//---------------------------------------------------------------------------------------

user function etiqueta()

Local cSql 		:=''
Local cSequen 	:=''
Local cOP 		:= SC2->C2_NUM
Local cItem 	:= SC2->C2_ITEM
Local cC2Seq 	:= SC2->C2_SEQUEN
Local aArea 	:= GetArea()
Local cPrefixo 	:= ''
Local cCont 	:= ''

cSql := "SELECT B5_PFXETQ AS PREFIXO FROM "+RetSqlName("SB5010")
cSql += " WHERE B5_FILIAL = '"+xFilial("SB5")+"' AND D_E_L_E_T_<>'*' AND B5_COD='"+SC2->C2_PRODUTO+"'"
TcQuery ChangeQuery(cSql) New Alias "QRY"

cPrefixo := QRY->PREFIXO


cSql := "SELECT MAX(Z02_SEQUEN) AS SEQUENCIA FROM "+RetSqlName("Z02010")
cSql += " WHERE Z02_FILIAL ='"+xFilial("SC2")+"' AND D_E_L_E_T_<>'*' AND SUBSTRING(Z02_SEQUEN,1,8)='"+QRY->PREFIXO+"'"
TcQuery ChangeQuery(cSql) New Alias "QRY1"

QRY->(dbclosearea())


If Empty(QRY1->SEQUENCIA)
	cSequen := cPrefixo + '0000000001'
Else
	cSequen := cPrefixo + Soma1(SUBSTR(QRY1->SEQUENCIA,9,18))
Endif

//MsgInfo (Soma1('0000000001'))
//MsgInfo (SUBSTR(QRY1->SEQUENCIA,9,18))
//Alert(cSequen)


QRY1->(dbclosearea())


DbSelectArea("Z02")

RecLock("Z02",.T.)
	Z02->Z02_FILIAL := xFilial('SC2')
	Z02->Z02_OP 	:= cOP
	Z02->Z02_ITEM 	:= cItem
	Z02->Z02_C2SEQ 	:= cC2Seq
	Z02->Z02_SEQUEN := cSequen
MsUnlock()


RestArea(aArea)


return (cSequen)
