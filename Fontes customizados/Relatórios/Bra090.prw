#INCLUDE "MATR090.CH"
#INCLUDE "PROTHEUS.CH"
/*/
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддддбдддддддбдддддддддддддддддддддддбддддддбдддддддддд©╠╠
╠╠ЁFun┤┘o    Ё BRA090  Ё Autor Ё CИsar O Afonso - Vamilly      Ё30/12/2019Ё╠╠
╠╠цддддддддддеддддддддддадддддддадддддддддддддддддддддддаддддддадддддддддд╢╠╠
╠╠ЁDescri┤┘o Ё Emiss└o da rela┤└o de Compras                              Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁSintaxe   Ё BRA090(void)                                              Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё Uso      Ё Generico                                                   Ё╠╠
╠╠цддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/
User Function Bra090()
Local oReport
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//ЁInterface de impressao                                                Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды 	
	oReport:= ReportDef()
	oReport:PrintDialog()
Return

/*/
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддддбдддддддбдддддддддддддддддддддддбддддддбдддддддддд©╠╠
╠╠ЁPrograma  Ё ReportDefЁAutor  ЁCИsar O Affonso - Vamilly     Ё30/12/2019Ё╠╠
╠╠цддддддддддеддддддддддадддддддадддддддддддддддддддддддаддддддадддддддддд╢╠╠
╠╠ЁDescri┤┘o Ё Emiss└o da rela┤└o de Compras                              Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁRetorno   Ё oExpO1: Objeto do relatorio                                Ё╠╠
╠╠юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/
Static Function ReportDef()

Local aOrdem   := {"Fornecedor","Data De Digitacao","Tipo+Grupo+Codigo","Grupo+Codigo"}//"Fornecedor"###"Data De Digitacao"###"Tipo+Grupo+Codigo"###" Grupo+Codigo"
Local aArea	   := Getarea() 
Local aSB1Cod  := TamSX3("B1_COD")
Local aSB1Ite  := TAMSX3("B1_CODITE")
Local lVeiculo := Upper(GetMV("MV_VEICULO")) == "S"
Local nTamCli  := Max(TAMSX3("A1_NOME")[1],TAMSX3("A2_NOME")[1])-15
Local cTitle   := "Conf NF Entr Impostos" //STR0001 //"Relacao de Compras"
Local cPictImp := X3Picture("D1_TOTAL")
Local oReport 
Local oSection1
Local oSection2
Local cAliasSD1 := GetNextAlias()
Local aTP      :=  {.F., .T., .F.}
DbCommitall()
RestArea(aArea)

Pergunte("MTR090",.F.)
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//ЁCriacao do componente de impressao                                      Ё
//Ё                                                                        Ё
//ЁTReport():New                                                           Ё
//ЁExpC1 : Nome do relatorio                                               Ё
//ЁExpC2 : Titulo                                                          Ё
//ЁExpC3 : Pergunte                                                        Ё
//ЁExpB4 : Bloco de codigo que sera executado na confirmacao da impressao  Ё
//ЁExpC5 : Descricao                                                       Ё
//Ё                                                                        Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
oReport:= TReport():New("BRA090",cTitle,"MTR090", {|oReport| ReportPrint(oReport,aOrdem,cAliasSD1)},STR0002 + "Este relatorio ira imprimir a relacao de itens referentes a compras efetuadas.") //"Este relatorio ira imprimir a relacao de itens referentes a compras efetuadas."
oReport:SetTotalInLine(.F.)
oReport:SetLandscape()
oReport:lParamPage := .F.
oReport:SetDevice(4) //Direto para planilha
oReport:lHeaderVisible := .F. //Enibe o cabeГalho do RelatСrio 
oReport:lFooterVisible := .F. //Suprime a impressЦo do rodapИ
//oReport:SetTpPlanilha(aTp)  //Mostra as opГУes de formataГЦo da planilha (nЦo serve)

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//ЁCriacao da secao utilizada pelo relatorio                               Ё
//Ё                                                                        Ё
//ЁTRSection():New                                                         Ё
//ЁExpO1 : Objeto TReport que a secao pertence                             Ё
//ЁExpC2 : Descricao da seГao                                              Ё
//ЁExpA3 : Array com as tabelas utilizadas pela secao. A primeira tabela   Ё
//Ё        sera considerada como principal para a seГЦo.                   Ё
//ЁExpA4 : Array com as Ordens do relatСrio                                Ё
//ЁExpL5 : Carrega campos do SX3 como celulas                              Ё
//Ё        Default : False                                                 Ё
//ЁExpL6 : Carrega ordens do Sindex                                        Ё
//Ё        Default : False                                                 Ё
//Ё                                                                        Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//ЁCriacao da celulas da secao do relatorio                                Ё
//Ё                                                                        Ё
//ЁTRCell():New                                                            Ё
//ЁExpO1 : Objeto TSection que a secao pertence                            Ё
//ЁExpC2 : Nome da celula do relatСrio. O SX3 serА consultado              Ё
//ЁExpC3 : Nome da tabela de referencia da celula                          Ё
//ЁExpC4 : Titulo da celula                                                Ё
//Ё        Default : X3Titulo()                                            Ё
//ЁExpC5 : Picture                                                         Ё
//Ё        Default : X3_PICTURE                                            Ё
//ЁExpC6 : Tamanho                                                         Ё
//Ё        Default : X3_TAMANHO                                            Ё
//ЁExpL7 : Informe se o tamanho esta em pixel                              Ё
//Ё        Default : False                                                 Ё
//ЁExpB8 : Bloco de cСdigo para impressao.                                 Ё
//Ё        Default : ExpC2                                                 Ё
//Ё                                                                        Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
oSection1:= TRSection():New(oReport,STR0001,{"SD1","SF1","SD2","SF2","SB1","SA1","SA2","SF4"},aOrdem)
oSection1:SetTotalInLine(.F.)
oSection1:SetHeaderPage()    
oSection1:SetLineStyle(.F.)
oSection1:SetReadOnly() //NAO RETIRAR
                                              
oSection1:SetNoFilter("SA1")
oSection1:SetNoFilter("SA2")
oSection1:SetNoFilter("SF1")
oSection1:SetNoFilter("SF2")
oSection1:SetNoFilter("SD2")
oSection1:SetNoFilter("SF4")
oSection1:SetNoFilter("SD2")
oSection1:SetNoFilter("SB1")

TRCell():New(oSection1,"D1_DOC"    ,"SD1",/*Titulo*/	,/*Picture*/, TamSX3("D1_DOC")[1]+5,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,"D1_COD"    ,"SD1",/*Titulo*/	,/*Picture*/,TamSX3("D1_COD")[1]+15,/*lPixel*/,/*{|| code-block de impressao }*/,/**/,/**/, /**/, /**/, /**/,.F.)

//If lVeiculo
//   TRCell():New(oSection1,"D1_CODITE" ,"SD1",RetTitle("B1_CODITE"),/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
//EndIf

TRCell():New(oSection1,"COD"       ,"SD1",/*Titulo*/	,/*Picture*/,/*Tamanho*/,/*lPixel*/,{|| cCod })  // CИlula para controle do cСdigo do produto, nЦo serА impressa
oSection1:Cell("COD"):Disable()
TRCell():New(oSection1,"B1_DESC"   ,"SB1",/*Titulo*/	,/*Picture*/,15,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,"D1_QUANT"  ,"SD1",/*Titulo*/	,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,"D1_UM"     ,"SD1",STR0031		,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,"VALUNIT"   ,"   ",STR0023		,/*Picture*/,/*Tamanho*/,/*lPixel*/,{|| nValUnit })
TRCell():New(oSection1,"VALTOTAL"  ,"   ",STR0026,/*Picture*/,/*Tamanho*/,/*lPixel*/,{|| nValTot  })
TRCell():New(oSection1,"D1_VALFRE" ,"SD1",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,"D1_DESPESA","SD1",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,"D1_VALIPI" ,"SD1",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,"VALTIPI"   ,"   ","Vl Tot + IPI + FRT + Desp",/*Picture*/,/*Tamanho*/,/*lPixel*/,{|| nValTIPI })
TRCell():New(oSection1,"D1_VALICM" ,"SD1",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,"D1_FORNECE","SD1",STR0032		,/*Picture*/,TamSX3("D1_FORNECE")[1]+10,/*lPixel*/,/*{|| code-block de impressao }*/)
//TRCell():New(oSection1,"RAZAOSOC"  ,"   ",STR0027		,/*Picture*/,nTamCli-10	,/*lPixel*/,{|| cRazao })
TRCell():New(oSection1,"D1_TIPO"   ,"SD1",STR0033		,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,"D1_TES"    ,"SD1",STR0034		,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)

TRCell():New(oSection1,"D1_CF"     ,"SD1","CFOP"		,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,"D1_TP"     ,"SD1",STR0035		,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,"D1_GRUPO"  ,"SD1",/*Titulo*/	,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,"D1_DTDIGIT","SD1",STR0036		,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,"VALCUSTO"  ,"   ",STR0028		,/*Picture*/,/*Tamanho*/,/*lPixel*/,{|| nValCusto })
TRCell():New(oSection1,"D1_LOCAL"  ,"SD1",STR0037		,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,"PERCUST"   ,"   ","Perc Custo"	,/*Picture*/,/*Tamanho*/,/*lPixel*/,{|| nPerCust })
TRCell():New(oSection1,"GERADP"    ,"   ","Gera Fat"	,/*Picture*/,/*Tamanho*/,/*lPixel*/,{|| cGeraDP })
TRCell():New(oSection1,"D1_CONTA"  ,"SD1","Conta Contabil",/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,"CDPAG"     ,"   ","Cond Pag"	,/*Picture*/,60,/*lPixel*/,{|| CDPAG })

oSection1:Cell("VALUNIT"):GetFieldInfo("D1_VUNIT")
oSection1:Cell("VALTOTAL"):GetFieldInfo("D1_TOTAL")
oSection1:Cell("VALCUSTO"):GetFieldInfo("D1_CUSTO")

oSection2:= TRSection():New(oSection1,STR0001,{"SD2","SF2","SD1","SF1","SB1","SA1","SA2","SF4"}) 
oSection2:SetHeaderPage()
oSection2:SetTotalInLine(.F.)   
oSection2:SetLineStyle()
oSection2:SetReadOnly() //NAO RETIRAR

oSection2:SetNoFilter("SA1")
oSection2:SetNoFilter("SA2")
oSection2:SetNoFilter("SF1")
oSection2:SetNoFilter("SF2")
oSection2:SetNoFilter("SD2")
oSection2:SetNoFilter("SF4")
oSection2:SetNoFilter("SD1")
oSection2:SetNoFilter("SB1")

TRCell():New(oSection2,"D2_DOC"    ,"SD2",/*Titulo*/,/*Picture*/,6			 ,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection2,"D2_COD"    ,"SD2",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection2,"B1_DESC"   ,"SB1",/*Titulo*/,/*Picture*/,15/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection2,"D2_QUANT"  ,"SD2",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,{|| SD2->D2_QUANT * -1 })
TRCell():New(oSection2,"D2_UM"     ,"SD2",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection2,"PRCVEN"    ,"   ",STR0023	 ,/*Picture*/,/*Tamanho*/,/*lPixel*/,{|| nValUnit })
TRCell():New(oSection2,"D2_IPI","SD2",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection2,"VALTOTAL"  ,"   ",STR0026,/*Picture*/,/*Tamanho*/,/*lPixel*/,{|| nValTot * -1 })
// nValTIPI
TRCell():New(oSection2,"D2_VALICM","SD2",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection2,"D2_CLIENTE","SD2",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
//TRCell():New(oSection2,"RAZAOSOC"  ,"   ",STR0027	 ,/*Picture*/,nTamCli-10 ,/*lPixel*/,{|| cRazao })
TRCell():New(oSection2,"D2_TIPO"   ,"SD2",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection2,"D2_TES"    ,"SD2",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection2,"D2_TP"     ,"SD2",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection2,"D2_GRUPO"  ,"SD2",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection2,"D2_EMISSAO","SD2",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection2,"VALCUSTO"  ,"   ",STR0028	 ,/*Picture*/,/*Tamanho*/,/*lPixel*/,{|| nValCusto * -1 })
TRCell():New(oSection2,"D2_LOCAL"  ,"SD2",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)

oSection2:Cell("PRCVEN"  	):GetFieldInfo("D2_PRCVEN"	)	 
oSection2:Cell("VALTOTAL"	):GetFieldInfo("D2_TOTAL"	)
oSection2:Cell("VALCUSTO"	):GetFieldInfo("D2_CUSTO"	)
oSection2:Cell("D2_DOC"		):GetFieldInfo("D1_DOC"		)
oSection2:Cell("D2_CLIENTE"	):GetFieldInfo("D1_FORNECE"	)
oSection2:Cell("D2_TIPO"	):GetFieldInfo("D1_TIPO"	)
oSection2:Cell("D2_TES"		):GetFieldInfo("D1_TES"		)
oSection2:Cell("D2_TP"		):GetFieldInfo("D1_TP"		)
oSection2:Cell("D2_GRUPO"	):GetFieldInfo("D1_GRUPO"	)
oSection2:Cell("D2_EMISSAO"	):GetFieldInfo("D1_DTDIGIT"	)

oSection2:Cell("D2_DOC"		):HideHeader()
oSection2:Cell("D2_COD"		):HideHeader()
oSection2:Cell("B1_DESC"	):HideHeader()
oSection2:Cell("D2_QUANT"	):HideHeader()
oSection2:Cell("D2_UM"		):HideHeader()
oSection2:Cell("PRCVEN"		):HideHeader()
oSection2:Cell("D2_IPI"	):HideHeader()
oSection2:Cell("VALTOTAL"   ):HideHeader()
//oSection2:Cell("D2_PICM"    ):HideHeader()
oSection2:Cell("D2_CLIENTE"	):HideHeader()
//oSection2:Cell("RAZAOSOC"	):HideHeader()
oSection2:Cell("D2_TIPO"	):HideHeader()
oSection2:Cell("D2_TES"		):HideHeader()
oSection2:Cell("D2_TP"		):HideHeader()
oSection2:Cell("D2_GRUPO"	):HideHeader()
oSection2:Cell("D2_EMISSAO"	):HideHeader()
oSection2:Cell("VALCUSTO"	):HideHeader()
oSection2:Cell("D2_LOCAL"	):HideHeader()

Return(oReport)

/*/
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддддбдддддддбдддддддддддддддддддддддбддддддбдддддддддд©╠╠
╠╠ЁPrograma  ЁReportPrinЁ Autor ЁAlexandre Inacio Lemes ЁData  Ё06/07/2006Ё╠╠
╠╠цддддддддддеддддддддддадддддддадддддддддддддддддддддддаддддддадддддддддд╢╠╠
╠╠ЁDescri┤┘o Ё Emiss└o da rela┤└o de Compras                              Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁRetorno   ЁNenhum                                                      Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁParametrosЁExpO1: Objeto Report do RelatСrio                           Ё╠╠
╠╠юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/
Static Function ReportPrint(oReport,aOrdem,cAliasSD1)

Local oSection1  := oReport:Section(1) 
Local oSection2  := oReport:Section(1):Section(1)   
Local nOrdem     := oReport:Section(1):GetOrder()
Local aImpostos  := {}
Local aRecno     := {}
Local cCampImp   := ""
Local cTipo1	 := ""
Local cTipo2	 := ""
Local cFilUsrSD1 := ""
Local cCondSD2   := ""
Local cArqTrbSD2 := ""
Local nNewIndSD2 := 0
Local nImpos     := 0
Local nY         := 0
Local nDecs      := Msdecimais(mv_par09) //casas decimais utilizadas na moeda da impressao
Local oBreak
Local oBreak1    
Local oBreak2    
Local oBreak3    
Local lQuery     := .F.
Local lMoeda     := .T.

Local cSelect   := ""
Local cSelect1  := ""
Local cOrder    := ""
Local cWhereSB1 := ""
Local cWhereSF1 := ""
Local cWhereSF4 := "%%" 
Local cFrom     := "%%"
Local cAliasSF4 := cAliasSD1
Local aStrucSD1 := SD1->(dbStruct())      
Local cName		:= ""
Local nX        := 0
Local lCabec    := .T.
PRIVATE cRazao   := ""
PRIVATE lVeiculo := Upper(GetMV("MV_VEICULO")) == "S"
PRIVATE nValUnit := 0
PRIVATE nValTot  := 0
PRIVATE nValTIPI := 0
PRIVATE cGeraDP  := ""
PRIVATE nValCusto:= 0 
PRIVATE nPerCust := 0
PRIVATE	nImpInc  :=	0
PRIVATE	nImpNoInc:=	0
PRIVATE cCod	 := ""
PRIVATE CODPAG   := ""

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Adiciona a ordem escolhida ao titulo do relatorio          Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
oReport:SetTitle(oReport:Title() + " ("+AllTrim(aOrdem[nOrdem])+") ")

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё O campo Custo recebe o nome referente ao seu tipo de moeda.Ё
//Ё 							Custo MoedaX							Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
oSection1:Cell("VALCUSTO"):GetFieldInfo("D1_CUSTO" + IIF(mv_par09 == 1, "", AllTrim(str(mv_par09))))

dbSelectArea("SD1")
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//ЁFiltragem do relatСrio                                                  Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды

 	MakeSqlExpr(oReport:uParam)
    
 	oReport:Section(1):BeginQuery()	

    lQuery := .T.

cSelect := "%" 
    	
cSelect += ", " + GetValImp() 

If lVeiculo
	cSelect   += ",B1_CODITE "	
    cWhereSB1 := "%"
	cWhereSB1 += " B1_CODITE >= '" + MV_PAR01 + "'"
	cWhereSB1 += " AND B1_CODITE <= '" + MV_PAR02 + "'"
    cWhereSB1 += "%"
    Else
    cWhereSB1 := "%"
	cWhereSB1 += " D1_COD >= '" + MV_PAR01 + "'"
	cWhereSB1 += " AND D1_COD <= '" + MV_PAR02 + "'"
    cWhereSB1 += "%"
 	Endif

    //зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
    //ЁEsta rotina foi escrita para adicionar no select os campos         Ё
    //Ёusados no filtro do usuario quando houver, a rotina acrecenta      Ё
    //Ёsomente os campos que forem adicionados ao filtro testando         Ё
    //Ёse os mesmo jА existem no select ou se forem definidos novamente   Ё
    //Ёpelo o usuario no filtro, esta rotina acrecenta o minimo possivel  Ё
    //Ёde campos no select pois pelo fato da tabela SD1 ter muitos campos |
    //Ёe a query ter UNION, ao adicionar todos os campos do SD1 podera'   |
    //Ёderrubar o TOP CONNECT e abortar o sistema.                        |
    //юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды	   	
cSelect1 := "D1_FILIAL, D1_DOC, D1_SERIE, D1_FORNECE, D1_LOJA, D1_DTDIGIT, D1_COD,   D1_QUANT, D1_VUNIT,"
cSelect1 += "D1_TOTAL,  D1_TES, D1_VALIPI,D1_VALICM,    D1_TIPO, D1_TP,      D1_GRUPO, D1_CUSTO, D1_LOCAL, D1_QTDEDEV, D1_ITEM, D1_UM," 
   	cFilUsrSD1:= oSection1:GetAdvplExp()
    If !Empty(cFilUsrSD1)
	For nX := 1 To SD1->(FCount())
		cName := SD1->(FieldName(nX))
	 	If AllTrim( cName ) $ cFilUsrSD1
      		If aStrucSD1[nX,2] <> "M"  
      			If !cName $ cSelect .And. !cName $ cSelect1
	        		cSelect += ","+cName 
	          	Endif 	
	       	EndIf
		EndIf 			       	
	Next
    Endif    

If mv_par11 == 1
	cSelect += ", F4_AGREG "	
    cFrom := "%"
    cFrom += "," + RetSqlName("SF4") + " SF4 "
    cFrom += "%" 	    

    cWhereSF4 := "%"
	cWhereSF4 += " SF4.F4_FILIAL ='" + xFilial("SF4") + "'"
	cWhereSF4 += " AND SF4.F4_CODIGO = SD1.D1_TES"
	If mv_par13 == 1
		cWhereSF4 += " AND SF4.F4_ESTOQUE = 'S' "
	elseIf mv_par13 == 2
		cWhereSF4 += " AND SF4.F4_ESTOQUE <> 'S' "
	endif
	If mv_par14 == 1
		cWhereSF4 += " AND SF4.F4_DUPLIC = 'S' "
	elseIf mv_par14 == 2
		cWhereSF4 += " AND SF4.F4_DUPLIC <> 'S' "
	endif
	cWhereSF4 += " AND SF4.D_E_L_E_T_ <> '*' AND "
    cWhereSF4 += "%"
EndIf

If (mv_par12 == 1)
	cTipo1 := "D','B"
	cTipo2 := cTipo1
Else
	cTipo1 := "B"
	cTipo2 := "D','B"
EndIf

    cSelect += "%"

cWhereSF1 := "%"
cWhereSF1 += "NOT ("+IsRemito(3,'SF1.F1_TIPODOC')+ ") AND "
cWhereSF1 += "%"

If nOrdem == 1
	cOrder := "% D1_FILIAL, D1_FORNECE, D1_LOJA,    D1_DOC,   D1_SERIE,  D1_ITEM %"
ElseIf nOrdem == 2
	cOrder := "% D1_FILIAL, D1_DTDIGIT, D1_FORNECE, D1_LOJA,   D1_DOC,   D1_SERIE, D1_ITEM %"
ElseIf nOrdem == 3 .And. lVeiculo
	cOrder := "% D1_FILIAL, D1_TP,	    D1_GRUPO,   B1_CODITE, D1_DTDIGIT %"
ElseIf nOrdem == 3 .And. !lVeiculo
	cOrder := "% D1_FILIAL, D1_TP,		D1_GRUPO,   D1_COD,    D1_DTDIGIT %"
ElseIf nOrdem == 4 .And. lVeiculo
	cOrder := "% D1_FILIAL, D1_GRUPO,   D1_CODITE,  D1_DTDIGIT %"
ElseIf nOrdem == 4 .And. !lVeiculo
	cOrder := "% D1_FILIAL, D1_GRUPO,   D1_COD,     D1_DTDIGIT %"
EndIf

BeginSql Alias cAliasSD1
		
SELECT D1_FILIAL,D1_DOC, D1_SERIE,  D1_FORNECE, D1_LOJA,    D1_DTDIGIT, D1_COD, D1_QUANT, D1_VUNIT,
	   D1_TOTAL, D1_TES, D1_VALFRE, D1_DESPESA, D1_VALIPI,  D1_VALICM,  D1_CF, D1_TIPO, D1_TP, D1_GRUPO, D1_CUSTO, D1_LOCAL, D1_QTDEDEV, 
	   D1_ITEM,  D1_UM,  D1_CONTA,  F1_MOEDA,   F1_TXMOEDA, F1_DTDIGIT, F1_COND, Substring(B1_DESC,1,30) B1_DESC, B1_UM,  A1_NOME RAZAO, A1_NREDUZ RAZAORED, SD1.R_E_C_N_O_ SD1RECNO,
       B1_CODITE D1_CODITE,  'C' TIPO
       %Exp:cSelect%

FROM %table:SF1% SF1 , %table:SD1% SD1 , %table:SB1% SB1 , %table:SA1% SA1 %Exp:cFrom%

   	WHERE SF1.F1_FILIAL   = %xFilial:SF1%   AND 
      %Exp:cWhereSF1%
      SF1.%NotDel%                      AND
          SD1.D1_FILIAL   =  %xFilial:SD1%  AND
          SD1.D1_DOC      =  SF1.F1_DOC     AND
          SD1.D1_SERIE    =  SF1.F1_SERIE   AND  
          SD1.D1_FORNECE  =  SF1.F1_FORNECE AND
          SD1.D1_LOJA     =  SF1.F1_LOJA    AND  
      SD1.D1_TIPO  IN (%Exp:cTipo1%)    AND 
      SD1.%NotDel%                      AND
          SB1.B1_FILIAL   =  %xFilial:SB1%  AND
          SB1.B1_COD      =  SD1.D1_COD     AND
      SB1.%NotDel%                      AND
          SA1.A1_FILIAL   =  %xFilial:SA1%  AND
          SA1.A1_COD      =  SD1.D1_FORNECE AND
          SA1.A1_LOJA     =  SD1.D1_LOJA    AND
      SA1.%NotDel%                      AND
      %Exp:cWhereSF4%
 	      SD1.D1_DTDIGIT >= %Exp:Dtos(mv_par03)% AND 
      SD1.D1_DTDIGIT <= %Exp:Dtos(mv_par04)% AND 
	  SD1.D1_FORNECE >= %Exp:mv_par05% AND 
      SD1.D1_FORNECE <= %Exp:mv_par06% AND      
      %Exp:cWhereSB1%

UNION

SELECT D1_FILIAL, D1_DOC, D1_SERIE,  D1_FORNECE, D1_LOJA,    D1_DTDIGIT, D1_COD,  D1_QUANT, D1_VUNIT,
	   D1_TOTAL,  D1_TES, D1_VALFRE, D1_DESPESA, D1_VALIPI,  D1_VALICM,  D1_CF,   D1_TIPO,  D1_TP, D1_GRUPO, D1_CUSTO, D1_LOCAL, D1_QTDEDEV, 
	   D1_ITEM,   D1_UM,  D1_CONTA,  F1_MOEDA,   F1_TXMOEDA, F1_DTDIGIT, F1_COND, Substring(B1_DESC,1,30) B1_DESC, B1_UM, A2_NOME RAZAO, A2_NREDUZ RAZAORED, SD1.R_E_C_N_O_ SD1RECNO,
   	   B1_CODITE  D1_CODITE,  'F' TIPO
       %Exp:cSelect%

FROM %table:SF1% SF1 , %table:SD1% SD1 , %table:SB1% SB1 , %table:SA2% SA2 %Exp:cFrom%

   	WHERE SF1.F1_FILIAL   = %xFilial:SF1%   AND 
      %Exp:cWhereSF1%
      SF1.%NotDel%                      AND
          SD1.D1_FILIAL   =  %xFilial:SD1%  AND
          SD1.D1_DOC      =  SF1.F1_DOC     AND
          SD1.D1_SERIE    =  SF1.F1_SERIE   AND  
          SD1.D1_FORNECE  =  SF1.F1_FORNECE AND
          SD1.D1_LOJA     =  SF1.F1_LOJA    AND  
      SD1.D1_TIPO NOT IN (%Exp:cTipo2%)  AND 
      SD1.%NotDel%                      AND
          SB1.B1_FILIAL   =  %xFilial:SB1%  AND
          SB1.B1_COD      =  SD1.D1_COD     AND
      SB1.%NotDel%                      AND
          SA2.A2_FILIAL   =  %xFilial:SA2%  AND
          SA2.A2_COD      =  SD1.D1_FORNECE AND
          SA2.A2_LOJA     =  SD1.D1_LOJA    AND
      SA2.%NotDel%                      AND
      %Exp:cWhereSF4%
 	      SD1.D1_DTDIGIT >= %Exp:Dtos(mv_par03)% AND 
      SD1.D1_DTDIGIT <= %Exp:Dtos(mv_par04)% AND 
	  SD1.D1_FORNECE >= %Exp:mv_par05% AND 
      SD1.D1_FORNECE <= %Exp:mv_par06% AND      
      %Exp:cWhereSB1%

ORDER BY %Exp:cOrder%
				
EndSql 
aSQL := GetLastQuery()

oReport:Section(1):EndQuery(/*Array com os parametros do tipo Range*/)

	
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Monta IndRegua caso liste NFs de devolucao                   Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If mv_par07 == 1
	cArqTrbSD2:= CriaTrab("",.F.)
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Verifica data caso FILTRE NFs de devolucao fora do periodoЁ
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	If mv_par08 == 1
		cCondSD2	:=	( "D2_FILIAL == '" + xFilial("SD2") + "'" )
		cCondSD2	+=	( " .And. DTOS(D2_EMISSAO)>='" + DTOS(mv_par03) + "'" )
		cCondSD2	+=	( " .And. DTOS(D2_EMISSAO)<='" + DTOS(mv_par04) + "'" )
	Else
		cCondSD2	:=	( "D2_FILIAL == '" + xFilial("SD2") + "'")
	EndIf
	cCondSD2 +=	( ".And. !(" + IsRemito(2,'SD2->D2_TIPODOC') + ")" )
				
	dbSelectArea("SD2")
	IndRegua("SD2",cArqTrbSD2,"D2_FILIAL+D2_COD+D2_NFORI+D2_ITEMORI+D2_SERIORI+D2_CLIENTE+D2_LOJA",,cCondSD2,STR0010)		//"Selecionando Registros..."
	nNewIndSD2 := RetIndex("SD2")
	dbSelectArea("SD2")
	dbSetOrder(nNewIndSD2+1)
	dbGoTop()
EndIf

cFilUsrSD1:= oSection1:GetAdvplExp()

If nOrdem == 1

	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Definicao das quebras e totalizadores que serao Impressos.   Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды	
	oBreak1 := TRBreak():New(oSection1,oSection1:Cell("D1_DOC")    ,STR0017,.F.,"NFE") // "TOTAL NOTA FISCAL --> "
	oBreak2 := TRBreak():New(oSection1,oSection1:Cell("D1_FORNECE"),STR0018,.F.) // "TOTAL FORNECEDOR  --> "

	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё A ordem de chamada de cada TRFunction nao deve ser alterada, pois representa a ordem da celula gerada para planilha XML  Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды		
	TRFunction():New(oSection1:Cell("D1_QUANT"),NIL,"SUM",oBreak1,,/*cPicture*/,/*uFormula*/,.F.,.F. ,,, {|| IIf( mv_par11 == 1 ,(cAliasSF4)->F4_AGREG <> "N" , .T. ) } ) 
	TRFunction():New(oSection1:Cell("VALTOTAL"),NIL,"SUM",oBreak1,,/*cPicture*/,/*uFormula*/,.F.,.F. ,,, {|| IIf( mv_par11 == 1 ,(cAliasSF4)->F4_AGREG <> "N" , .T. ) } ) 
	TRFunction():New(oSection1:Cell("VALCUSTO"),NIL,"SUM",oBreak1,,/*cPicture*/,/*uFormula*/,.F.,.F. ,,, {|| IIf( mv_par11 == 1 ,(cAliasSF4)->F4_AGREG <> "N" , .T. ) } ) 

	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Dispara a funcao PrintDevol() para a impressao da oSection2  Ё
	//Ё apartir do Break NFE abaixo apos a impressao do totalizador. Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды	
	oBreak:= oReport:Section(1):GetBreak("NFE")
	oBreak:OnPrintTotal({|| PrintDevol(aRecno,lQuery,oReport,oSection1,oSection2,cAliasSD1,(cAliasSD1)->SD1RECNO) })
	
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Impressao dos totalizadores SD1 (-) SD2 Devolucoes.          Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды	
	TRFunction():New(oSection1:Cell("D1_QUANT"),NIL,"ONPRINT",oBreak2,,/*cPicture*/,{|lSection,lReport,lPage| If( !lReport, oSection1:GetFunction("SD1QTD2"):GetValue() + oSection2:GetFunction("SD2QTD2"):GetValue() , oSection1:GetFunction("SD1QTD2"):ReportValue() + oSection2:GetFunction("SD2QTD2"):ReportValue() ) },.F.,.T. ,,, {|| IIf( mv_par11 == 1 ,(cAliasSF4)->F4_AGREG <> "N" , .T. ) } ) 
	TRFunction():New(oSection1:Cell("VALTOTAL"),NIL,"ONPRINT",oBreak2,,/*cPicture*/,{|lSection,lReport,lPage| If( !lReport, oSection1:GetFunction("SD1TOT2"):GetValue() + oSection2:GetFunction("SD2TOT2"):GetValue() , oSection1:GetFunction("SD1TOT2"):ReportValue() + oSection2:GetFunction("SD2TOT2"):ReportValue() ) },.F.,.T. ,,, {|| IIf( mv_par11 == 1 ,(cAliasSF4)->F4_AGREG <> "N" , .T. ) } ) 
	TRFunction():New(oSection1:Cell("VALCUSTO"),NIL,"ONPRINT",oBreak2,,/*cPicture*/,{|lSection,lReport,lPage| If( !lReport, oSection1:GetFunction("SD1CUS2"):GetValue() + oSection2:GetFunction("SD2CUS2"):GetValue() , oSection1:GetFunction("SD1CUS2"):ReportValue() + oSection2:GetFunction("SD2CUS2"):ReportValue() ) },.F.,.T. ,,, {|| IIf( mv_par11 == 1 ,(cAliasSF4)->F4_AGREG <> "N" , .T. ) } ) 		

ElseIf nOrdem == 2

	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Definicao das quebras e totalizadores que serao Impressos.   Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды	
	oBreak1 := TRBreak():New(oSection1,oSection1:Cell("D1_DOC")    ,STR0017,.F.,"NFE") // "TOTAL NOTA FISCAL --> "
	oBreak2 := TRBreak():New(oSection1,oSection1:Cell("D1_FORNECE"),STR0018,.F.) // "TOTAL FORNECEDOR  --> "
	oBreak3 := TRBreak():New(oSection1,oSection1:Cell("D1_DTDIGIT"),STR0019,.F.) // "TOT. NA DATA "

	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё A ordem de chamada de cada TRFunction nao deve ser alterada, pois representa a ordem da celula gerada para planilha XML  Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды    
	TRFunction():New(oSection1:Cell("D1_QUANT"),NIL,"SUM",oBreak1,,/*cPicture*/,/*uFormula*/,.F.,.F. ,,, {|| IIf( mv_par11 == 1 ,(cAliasSF4)->F4_AGREG <> "N" , .T. ) } ) 
	TRFunction():New(oSection1:Cell("VALTOTAL"),NIL,"SUM",oBreak1,,/*cPicture*/,/*uFormula*/,.F.,.F. ,,, {|| IIf( mv_par11 == 1 ,(cAliasSF4)->F4_AGREG <> "N" , .T. ) } ) 
	TRFunction():New(oSection1:Cell("VALCUSTO"),NIL,"SUM",oBreak1,,/*cPicture*/,/*uFormula*/,.F.,.F. ,,, {|| IIf( mv_par11 == 1 ,(cAliasSF4)->F4_AGREG <> "N" , .T. ) } ) 

	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Dispara a funcao PrintDevol() para a impressao da oSection2  Ё
	//Ё apartir do Break NFE abaixo apos a impressao do totalizador. Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды	
	oBreak:= oReport:Section(1):GetBreak("NFE")
	oBreak:OnPrintTotal({|| PrintDevol(aRecno,lQuery,oReport,oSection1,oSection2,cAliasSD1,(cAliasSD1)->SD1RECNO) })

	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Impressao dos totalizadores SD1 (-) SD2 Devolucoes.          Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды	
	TRFunction():New(oSection1:Cell("D1_QUANT"),NIL,"ONPRINT",oBreak2,,/*cPicture*/,{|| oSection1:GetFunction("SD1QTD2"):GetValue() + oSection2:GetFunction("SD2QTD2"):GetValue() },.F.,.F. ,,, {|| IIf( mv_par11 == 1 ,(cAliasSF4)->F4_AGREG <> "N" , .T. ) } ) 
	TRFunction():New(oSection1:Cell("VALTOTAL"),NIL,"ONPRINT",oBreak2,,/*cPicture*/,{|| oSection1:GetFunction("SD1TOT2"):GetValue() + oSection2:GetFunction("SD2TOT2"):GetValue() },.F.,.F. ,,, {|| IIf( mv_par11 == 1 ,(cAliasSF4)->F4_AGREG <> "N" , .T. ) } ) 
	TRFunction():New(oSection1:Cell("VALCUSTO"),NIL,"ONPRINT",oBreak2,,/*cPicture*/,{|| oSection1:GetFunction("SD1CUS2"):GetValue() + oSection2:GetFunction("SD2CUS2"):GetValue() },.F.,.F. ,,, {|| IIf( mv_par11 == 1 ,(cAliasSF4)->F4_AGREG <> "N" , .T. ) } ) 		
	TRFunction():New(oSection1:Cell("D1_QUANT"),NIL,"ONPRINT",oBreak3,,/*cPicture*/,{|lSection,lReport,lPage| If( !lReport, oSection1:GetFunction("SD1QTD3"):GetValue() + oSection2:GetFunction("SD2QTD3"):GetValue() , oSection1:GetFunction("SD1QTD3"):ReportValue() + oSection2:GetFunction("SD2QTD3"):ReportValue() ) },.F.,.T. ,,, {|| IIf( mv_par11 == 1 ,(cAliasSF4)->F4_AGREG <> "N" , .T. ) } ) 
	TRFunction():New(oSection1:Cell("VALTOTAL"),NIL,"ONPRINT",oBreak3,,/*cPicture*/,{|lSection,lReport,lPage| If( !lReport, oSection1:GetFunction("SD1TOT3"):GetValue() + oSection2:GetFunction("SD2TOT3"):GetValue() , oSection1:GetFunction("SD1TOT3"):ReportValue() + oSection2:GetFunction("SD2TOT3"):ReportValue() ) },.F.,.T. ,,, {|| IIf( mv_par11 == 1 ,(cAliasSF4)->F4_AGREG <> "N" , .T. ) } ) 
	TRFunction():New(oSection1:Cell("VALCUSTO"),NIL,"ONPRINT",oBreak3,,/*cPicture*/,{|lSection,lReport,lPage| If( !lReport, oSection1:GetFunction("SD1CUS3"):GetValue() + oSection2:GetFunction("SD2CUS3"):GetValue() , oSection1:GetFunction("SD1CUS3"):ReportValue() + oSection2:GetFunction("SD2CUS3"):ReportValue() ) },.F.,.T. ,,, {|| IIf( mv_par11 == 1 ,(cAliasSF4)->F4_AGREG <> "N" , .T. ) } ) 		

ElseIf nOrdem == 3

	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Definicao das quebras e totalizadores que serao Impressos.   Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды	
	oBreak1 := TRBreak():New(oSection1,oSection1:Cell("COD"),STR0014,.F.,"PROD") // "TOTAL PRODUTO     --> "
	oBreak2 := TRBreak():New(oSection1,oSection1:Cell("D1_GRUPO")  ,STR0015,.F.) // "TOTAL GRUPO "
	oBreak3 := TRBreak():New(oSection1,oSection1:Cell("D1_TP")     ,STR0016,.F.) // "TOTAL TIPO  "
	
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Dispara a funcao PrintDevol() para a impressao da oSection2  Ё
	//Ё apartir do Break NFE abaixo apos a impressao do totalizador. Ё      
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды	
	oBreak:= oReport:Section(1):GetBreak("PROD")
	oBreak:OnBreak({|| PrintDevol(aRecno,lQuery,oReport,oSection1,oSection2,cAliasSD1,(cAliasSD1)->SD1RECNO) })
    
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Impressao dos totalizadores SD1 (-) SD2 Devolucoes.          Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды	
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё A ordem de chamada de cada TRFunction nao deve ser alterada, pois representa a ordem da celula gerada para planilha XML  Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	TRFunction():New(oSection1:Cell("D1_QUANT"),NIL,"ONPRINT",oBreak1,,/*cPicture*/,{|| oSection1:GetFunction("SD1QTD1"):GetValue() + oSection2:GetFunction("SD2QTD1"):GetValue() },.F.,.F. ,,, {|| IIf( mv_par11 == 1 ,(cAliasSF4)->F4_AGREG <> "N" , .T. ) } ) 
	TRFunction():New(oSection1:Cell("VALTOTAL"),NIL,"ONPRINT",oBreak1,,/*cPicture*/,{|| oSection1:GetFunction("SD1TOT1"):GetValue() + oSection2:GetFunction("SD2TOT1"):GetValue() },.F.,.F. ,,, {|| IIf( mv_par11 == 1 ,(cAliasSF4)->F4_AGREG <> "N" , .T. ) } ) 
	TRFunction():New(oSection1:Cell("VALCUSTO"),NIL,"ONPRINT",oBreak1,,/*cPicture*/,{|| oSection1:GetFunction("SD1CUS1"):GetValue() + oSection2:GetFunction("SD2CUS1"):GetValue() },.F.,.F. ,,, {|| IIf( mv_par11 == 1 ,(cAliasSF4)->F4_AGREG <> "N" , .T. ) } ) 		
	TRFunction():New(oSection1:Cell("D1_QUANT"),NIL,"ONPRINT",oBreak2,,/*cPicture*/,{|| oSection1:GetFunction("SD1QTD2"):GetValue() + oSection2:GetFunction("SD2QTD2"):GetValue() },.F.,.F. ,,, {|| IIf( mv_par11 == 1 ,(cAliasSF4)->F4_AGREG <> "N" , .T. ) } ) 
	TRFunction():New(oSection1:Cell("VALTOTAL"),NIL,"ONPRINT",oBreak2,,/*cPicture*/,{|| oSection1:GetFunction("SD1TOT2"):GetValue() + oSection2:GetFunction("SD2TOT2"):GetValue() },.F.,.F. ,,, {|| IIf( mv_par11 == 1 ,(cAliasSF4)->F4_AGREG <> "N" , .T. ) } ) 
	TRFunction():New(oSection1:Cell("VALCUSTO"),NIL,"ONPRINT",oBreak2,,/*cPicture*/,{|| oSection1:GetFunction("SD1CUS2"):GetValue() + oSection2:GetFunction("SD2CUS2"):GetValue() },.F.,.F. ,,, {|| IIf( mv_par11 == 1 ,(cAliasSF4)->F4_AGREG <> "N" , .T. ) } ) 		
	TRFunction():New(oSection1:Cell("D1_QUANT"),NIL,"ONPRINT",oBreak3,,/*cPicture*/,{|lSection,lReport,lPage| If( !lReport, oSection1:GetFunction("SD1QTD3"):GetValue() + oSection2:GetFunction("SD2QTD3"):GetValue() , oSection1:GetFunction("SD1QTD3"):ReportValue() + oSection2:GetFunction("SD2QTD3"):ReportValue() ) },.F.,.T. ,,, {|| IIf( mv_par11 == 1 ,(cAliasSF4)->F4_AGREG <> "N" , .T. ) } ) 
	TRFunction():New(oSection1:Cell("VALTOTAL"),NIL,"ONPRINT",oBreak3,,/*cPicture*/,{|lSection,lReport,lPage| If( !lReport, oSection1:GetFunction("SD1TOT3"):GetValue() + oSection2:GetFunction("SD2TOT3"):GetValue() , oSection1:GetFunction("SD1TOT3"):ReportValue() + oSection2:GetFunction("SD2TOT3"):ReportValue() ) },.F.,.T. ,,, {|| IIf( mv_par11 == 1 ,(cAliasSF4)->F4_AGREG <> "N" , .T. ) } ) 
	TRFunction():New(oSection1:Cell("VALCUSTO"),NIL,"ONPRINT",oBreak3,,/*cPicture*/,{|lSection,lReport,lPage| If( !lReport, oSection1:GetFunction("SD1CUS3"):GetValue() + oSection2:GetFunction("SD2CUS3"):GetValue() , oSection1:GetFunction("SD1CUS3"):ReportValue() + oSection2:GetFunction("SD2CUS3"):ReportValue() ) },.F.,.T. ,,, {|| IIf( mv_par11 == 1 ,(cAliasSF4)->F4_AGREG <> "N" , .T. ) } ) 		

ElseIf nOrdem == 4

	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Definicao das quebras e totalizadores que serao Impressos.   Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды	
	oBreak1 := TRBreak():New(oSection1,oSection1:Cell("COD"),STR0014,.F.,"PROD") // "TOTAL PRODUTO     --> "
	oBreak2 := TRBreak():New(oSection1,oSection1:Cell("D1_GRUPO")  ,STR0015,.F.) // "TOTAL GRUPO "

	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Dispara a funcao PrintDevol() para a impressao da oSection2  Ё
	//Ё apartir do Break NFE abaixo apos a impressao do totalizador. Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды	
	oBreak:= oReport:Section(1):GetBreak("PROD")
	oBreak:OnBreak({|| PrintDevol(aRecno,lQuery,oReport,oSection1,oSection2,cAliasSD1,(cAliasSD1)->SD1RECNO) })

	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Impressao dos totalizadores SD1 (-) SD2 Devolucoes.          Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды	
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё A ordem de chamada de cada TRFunction nao deve ser alterada, pois representa a ordem da celula gerada para planilha XML  Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	TRFunction():New(oSection1:Cell("D1_QUANT"),NIL,"ONPRINT",oBreak1,,/*cPicture*/,{|| oSection1:GetFunction("SD1QTD1"):GetValue() + oSection2:GetFunction("SD2QTD1"):GetValue() },.F.,.F. ,,, {|| IIf( mv_par11 == 1 ,(cAliasSF4)->F4_AGREG <> "N" , .T. ) } ) 
	TRFunction():New(oSection1:Cell("VALTOTAL"),NIL,"ONPRINT",oBreak1,,/*cPicture*/,{|| oSection1:GetFunction("SD1TOT1"):GetValue() + oSection2:GetFunction("SD2TOT1"):GetValue() },.F.,.F. ,,, {|| IIf( mv_par11 == 1 ,(cAliasSF4)->F4_AGREG <> "N" , .T. ) } ) 
	TRFunction():New(oSection1:Cell("VALCUSTO"),NIL,"ONPRINT",oBreak1,,/*cPicture*/,{|| oSection1:GetFunction("SD1CUS1"):GetValue() + oSection2:GetFunction("SD2CUS1"):GetValue() },.F.,.F. ,,, {|| IIf( mv_par11 == 1 ,(cAliasSF4)->F4_AGREG <> "N" , .T. ) } ) 		
	TRFunction():New(oSection1:Cell("D1_QUANT"),NIL,"ONPRINT",oBreak2,,/*cPicture*/,{|lSection,lReport,lPage| If( !lReport, oSection1:GetFunction("SD1QTD2"):GetValue() + oSection2:GetFunction("SD2QTD2"):GetValue() , oSection1:GetFunction("SD1QTD2"):ReportValue() + oSection2:GetFunction("SD2QTD2"):ReportValue() ) },.F.,.T. ,,, {|| IIf( mv_par11 == 1 ,(cAliasSF4)->F4_AGREG <> "N" , .T. ) } ) 
	TRFunction():New(oSection1:Cell("VALTOTAL"),NIL,"ONPRINT",oBreak2,,/*cPicture*/,{|lSection,lReport,lPage| If( !lReport, oSection1:GetFunction("SD1TOT2"):GetValue() + oSection2:GetFunction("SD2TOT2"):GetValue() , oSection1:GetFunction("SD1TOT2"):ReportValue() + oSection2:GetFunction("SD2TOT2"):ReportValue() ) },.F.,.T. ,,, {|| IIf( mv_par11 == 1 ,(cAliasSF4)->F4_AGREG <> "N" , .T. ) } ) 
	TRFunction():New(oSection1:Cell("VALCUSTO"),NIL,"ONPRINT",oBreak2,,/*cPicture*/,{|lSection,lReport,lPage| If( !lReport, oSection1:GetFunction("SD1CUS2"):GetValue() + oSection2:GetFunction("SD2CUS2"):GetValue() , oSection1:GetFunction("SD1CUS2"):ReportValue() + oSection2:GetFunction("SD2CUS2"):ReportValue() ) },.F.,.T. ,,, {|| IIf( mv_par11 == 1 ,(cAliasSF4)->F4_AGREG <> "N" , .T. ) } ) 		

EndIf

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Os TRFunctions abaixo nao sao impressos, servem apenas para  Ё
//Ё acumular os valores das oSection1 e oSection2 para serem     Ё
//Ё utilizados na impressao do totalizador geral da oSection1    Ё
//Ё acima ONPRINT que subtrai as devolucoes SD1 - SD2.           Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If nOrdem == 3 .Or. nOrdem == 4

	TRFunction():New(oSection1:Cell("D1_QUANT"),"SD1QTD1","SUM",oBreak1,,/*cPicture*/,/*uFormula*/,.F.,.T. ,,, {|| IIf( mv_par11 == 1 ,(cAliasSF4)->F4_AGREG <> "N" , .T. ) } ) 
	TRFunction():New(oSection1:Cell("VALTOTAL"),"SD1TOT1","SUM",oBreak1,,/*cPicture*/,/*uFormula*/,.F.,.T. ,,, {|| IIf( mv_par11 == 1 ,(cAliasSF4)->F4_AGREG <> "N" , .T. ) } ) 
	TRFunction():New(oSection1:Cell("VALCUSTO"),"SD1CUS1","SUM",oBreak1,,/*cPicture*/,/*uFormula*/,.F.,.T. ,,, {|| IIf( mv_par11 == 1 ,(cAliasSF4)->F4_AGREG <> "N" , .T. ) } ) 
    oSection1:GetFunction("SD1QTD1"):Disable()
    oSection1:GetFunction("SD1TOT1"):Disable()
    oSection1:GetFunction("SD1CUS1"):Disable()

	TRFunction():New(oSection2:Cell("D2_QUANT"),"SD2QTD1","SUM",oBreak1,,/*cPicture*/,/*uFormula*/,.F.,.T. ,,, {|| IIf( mv_par11 == 1 ,(cAliasSF4)->F4_AGREG <> "N" , .T. ) } ) 
	TRFunction():New(oSection2:Cell("VALTOTAL"),"SD2TOT1","SUM",oBreak1,,/*cPicture*/,/*uFormula*/,.F.,.T. ,,, {|| IIf( mv_par11 == 1 ,(cAliasSF4)->F4_AGREG <> "N" , .T. ) } ) 
	TRFunction():New(oSection2:Cell("VALCUSTO"),"SD2CUS1","SUM",oBreak1,,/*cPicture*/,/*uFormula*/,.F.,.T. ,,, {|| IIf( mv_par11 == 1 ,(cAliasSF4)->F4_AGREG <> "N" , .T. ) } ) 
    oSection2:GetFunction("SD2QTD1"):Disable()
    oSection2:GetFunction("SD2TOT1"):Disable()
    oSection2:GetFunction("SD2CUS1"):Disable()

EndIf

TRFunction():New(oSection1:Cell("D1_QUANT"),"SD1QTD2","SUM",oBreak2,,/*cPicture*/,/*uFormula*/,.F.,.T. ,,, {|| IIf( mv_par11 == 1 ,(cAliasSF4)->F4_AGREG <> "N" , .T. ) } )
TRFunction():New(oSection1:Cell("VALTOTAL"),"SD1TOT2","SUM",oBreak2,,/*cPicture*/,/*uFormula*/,.F.,.T. ,,, {|| IIf( mv_par11 == 1 ,(cAliasSF4)->F4_AGREG <> "N" , .T. ) } )
TRFunction():New(oSection1:Cell("VALCUSTO"),"SD1CUS2","SUM",oBreak2,,/*cPicture*/,/*uFormula*/,.F.,.T. ,,, {|| IIf( mv_par11 == 1 ,(cAliasSF4)->F4_AGREG <> "N" , .T. ) } )
oSection1:GetFunction("SD1QTD2"):Disable()
oSection1:GetFunction("SD1TOT2"):Disable()
oSection1:GetFunction("SD1CUS2"):Disable()

TRFunction():New(oSection2:Cell("D2_QUANT"),"SD2QTD2","SUM",oBreak2,,/*cPicture*/,/*uFormula*/,.F.,.T. ,,, {|| IIf( mv_par11 == 1 ,(cAliasSF4)->F4_AGREG <> "N" , .T. ) } )
TRFunction():New(oSection2:Cell("VALTOTAL"),"SD2TOT2","SUM",oBreak2,,/*cPicture*/,/*uFormula*/,.F.,.T. ,,, {|| IIf( mv_par11 == 1 ,(cAliasSF4)->F4_AGREG <> "N" , .T. ) } )
TRFunction():New(oSection2:Cell("VALCUSTO"),"SD2CUS2","SUM",oBreak2,,/*cPicture*/,/*uFormula*/,.F.,.T. ,,, {|| IIf( mv_par11 == 1 ,(cAliasSF4)->F4_AGREG <> "N" , .T. ) } )
oSection2:GetFunction("SD2QTD2"):Disable()
oSection2:GetFunction("SD2TOT2"):Disable()
oSection2:GetFunction("SD2CUS2"):Disable()

If nOrdem == 2 .Or. nOrdem == 3

	TRFunction():New(oSection1:Cell("D1_QUANT"),"SD1QTD3","SUM",oBreak3,,/*cPicture*/,/*uFormula*/,.F.,.T. ,,, {|| IIf( mv_par11 == 1 ,(cAliasSF4)->F4_AGREG <> "N" , .T. ) } ) 
	TRFunction():New(oSection1:Cell("VALTOTAL"),"SD1TOT3","SUM",oBreak3,,/*cPicture*/,/*uFormula*/,.F.,.T. ,,, {|| IIf( mv_par11 == 1 ,(cAliasSF4)->F4_AGREG <> "N" , .T. ) } ) 
	TRFunction():New(oSection1:Cell("VALCUSTO"),"SD1CUS3","SUM",oBreak3,,/*cPicture*/,/*uFormula*/,.F.,.T. ,,, {|| IIf( mv_par11 == 1 ,(cAliasSF4)->F4_AGREG <> "N" , .T. ) } ) 
    oSection1:GetFunction("SD1QTD3"):Disable()
    oSection1:GetFunction("SD1TOT3"):Disable()
    oSection1:GetFunction("SD1CUS3"):Disable()

	TRFunction():New(oSection2:Cell("D2_QUANT"),"SD2QTD3","SUM",oBreak3,,/*cPicture*/,/*uFormula*/,.F.,.T. ,,, {|| IIf( mv_par11 == 1 ,(cAliasSF4)->F4_AGREG <> "N" , .T. ) } ) 
	TRFunction():New(oSection2:Cell("VALTOTAL"),"SD2TOT3","SUM",oBreak3,,/*cPicture*/,/*uFormula*/,.F.,.T. ,,, {|| IIf( mv_par11 == 1 ,(cAliasSF4)->F4_AGREG <> "N" , .T. ) } ) 
	TRFunction():New(oSection2:Cell("VALCUSTO"),"SD2CUS3","SUM",oBreak3,,/*cPicture*/,/*uFormula*/,.F.,.T. ,,, {|| IIf( mv_par11 == 1 ,(cAliasSF4)->F4_AGREG <> "N" , .T. ) } ) 
    oSection2:GetFunction("SD2QTD3"):Disable()
    oSection2:GetFunction("SD2TOT3"):Disable()
    oSection2:GetFunction("SD2CUS3"):Disable()

EndIf

oReport:SetMeter(SD1->(LastRec()))
dbSelectArea(cAliasSD1)

oSection1:Init()

While !oReport:Cancel() .And. !(cAliasSD1)->(Eof())

	lMoeda := .T.

	oReport:IncMeter()
	If oReport:Cancel()
		Exit
	EndIf

	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Considera filtro escolhido                                   Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	dbSelectArea(cAliasSD1)
	If !Empty(cFilUsrSD1)
	    If !(&(cFilUsrSD1))
	       dbSkip()
    	   Loop
    	EndIf   
	EndIf

	If lQuery
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Desconsidera quando for Cliente e Tipo da NF <> Devolucao ou Beneficiamento  Ё
		//| Em situaГУes onde o CСdigo do Cliente e CСdigo do Fornecedor sЦo iguais      |
		//| e necessАrio este critИrio para nЦo imprimir o relatСrio incorretamente.     |
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды   
	 	if (cAliasSD1)->TIPO == "C" 
		   If !(cAliasSD1)->D1_TIPO $ "DB"
			   dbSkip()
    		   Loop
    		EndIf
    	EndIf         
		
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Nao imprimir notas com moeda diferente da escolhida.         Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		If mv_par10==2 
			If If((cAliasSD1)->F1_MOEDA==0,1,(cAliasSD1)->F1_MOEDA) != mv_par09
				lMoeda := .F.
			Endif
		EndIf
	
		cRazao   := (cAliasSD1)->RAZAO			
        nValUnit := xmoeda((cAliasSD1)->D1_VUNIT,(cAliasSD1)->F1_MOEDA,mv_par09,(cAliasSD1)->F1_DTDIGIT,nDecs+1)
        nValTot  := xmoeda((cAliasSD1)->D1_TOTAL,(cAliasSD1)->F1_MOEDA,mv_par09,(cAliasSD1)->F1_DTDIGIT,nDecs+1)
        nValTIPI := (cAliasSD1)->D1_TOTAL + (cAliasSD1)->D1_VALIPI + (cAliasSD1)->D1_VALFRE + (cAliasSD1)->D1_DESPESA
        cGeraDP  := Posicione("SF4",1,xFilial("SF4")+(cAliasSD1)->D1_TES,"F4_DUPLIC")
        CDPAG    := Posicione("SE4",1,xFilial("SE4")+(cAliasSD1)->F1_COND,"E4_COND")      
		nValCusto:= xmoeda((cAliasSD1)->D1_CUSTO,1,mv_par09,(cAliasSD1)->F1_DTDIGIT,nDecs+1)
		nPerCust := If((cAliasSD1)->D1_TP = "MP",(cAliasSD1)->D1_CUSTO / (cAliasSD1)->D1_TOTAL * 100,0)
		
		// VariАvel para atualizar o CСdigo quando for estiver usando veМculo ou nЦo
		If lVeiculo
		   cCod:=(cAliasSD1)->D1_CODITE
		Else
		   cCod:= (cAliasSD1)->D1_COD
		EndIf

		If cPaisLoc <> "BRA"
			aImpostos:=TesImpInf((cAliasSD1)->D1_TES)
			nImpInc	:=	0
			nImpNoInc:=	0
			nImpos	:=	0
			For nY:=1 to Len(aImpostos)
				cCampImp:=(cAliasSD1)+"->"+(aImpostos[nY][2])
				nImpos:=&cCampImp
				nImpos:=xmoeda(nImpos,(cAliasSD1)->F1_MOEDA,mv_par09,(cAliasSD1)->F1_DTDIGIT,nDecs+1,(cAliasSD1)->F1_TXMOEDA)
				If ( aImpostos[nY][3]=="1" )
					nImpInc	+=nImpos
				Else
					If aImpostos[nY][3]=="2"
						nImpInc-=nImpos
					Else
						nImpNoInc+=nImpos
					Endif
				EndIf
			Next
		EndIf
	Else
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Nao imprimir notas com moeda diferente da escolhida.         Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		If mv_par10==2 
			If If(SF1->F1_MOEDA==0,1,SF1->F1_MOEDA) != mv_par09
				lMoeda := .F.
			Endif
		EndIf	

		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//ЁPosiciona o Fornecedor SA2 ou Cliente SA1 conf. o tipo da Nota Ё
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды	
		If (cAliasSD1)->D1_TIPO $ "DB"
			SA1->(dbSetOrder(1))
			SA1->(MsSeek( xFilial("SA1") + (cAliasSD1)->D1_FORNECE + (cAliasSD1)->D1_LOJA ))
			cRazao := SA1->A1_NOME
		Else
			SA2->(dbSetOrder(1))
			SA2->(MsSeek( xFilial("SA2") + (cAliasSD1)->D1_FORNECE + (cAliasSD1)->D1_LOJA ))
			cRazao := SA2->A2_NOME
		EndIf

		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё posiciona o SF1                                              Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		SF1->(MsSeek((cAliasSD1)->D1_FILIAL+(cAliasSD1)->D1_DOC+(cAliasSD1)->D1_SERIE+(cAliasSD1)->D1_FORNECE+(cAliasSD1)->D1_LOJA))

		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё posiciona o SF4                                              Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		If mv_par11 == 1
			SF4->(MsSeek( xFilial("SF4") + (cAliasSD1)->D1_TES ))
		EndIf
		
		nValUnit := xmoeda((cAliasSD1)->D1_VUNIT,SF1->F1_MOEDA,mv_par09,SF1->F1_DTDIGIT,nDecs+1) 
		nValTot  := xmoeda((cAliasSD1)->D1_TOTAL,SF1->F1_MOEDA,mv_par09,SF1->F1_DTDIGIT,nDecs+1)
		nValIPI  := (cAliasSD1)->D1_TOTAL + (cAliasSD1)->D1_VALIPI
		nValCusto:= xmoeda((cAliasSD1)->D1_CUSTO,1,mv_par09,SF1->F1_DTDIGIT,nDecs+1)

		If cPaisLoc <> "BRA"
			aImpostos:=TesImpInf((cAliasSD1)->D1_TES)
			nImpInc	:=	0
			nImpNoInc:=	0
			nImpos	:=	0
			For nY:=1 to Len(aImpostos)
				cCampImp:=(cAliasSD1)+"->"+(aImpostos[nY][2])
				nImpos:=&cCampImp
				nImpos:=xmoeda(nImpos,SF1->F1_MOEDA,mv_par09,SF1->F1_DTDIGIT,nDecs+1,SF1->F1_TXMOEDA)
				If ( aImpostos[nY][3]=="1" )
					nImpInc	+=nImpos
				Else
					If aImpostos[nY][3]=="2"
						nImpInc-=nImpos
					Else
						nImpNoInc+=nImpos
					Endif
				EndIf
			Next
		EndIf

	EndIf
			    
    If lMoeda 
       // Para imprimir o cabeГalho da seГЦo apenas uma vez
	   If lCabec 
		  lCabec := .F.
		 Else
		  oSection1:SetHeaderSection(.F.) 
       Endif  

		oSection1:PrintLine()		
    
		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Verificar a existencia de Devolucoes de Compras.              Ё
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		If (cAliasSD1)->D1_QTDEDEV <> 0 .And. mv_par07 == 1
			AADD(aRecno,IIf(lQuery,(cAliasSD1)->SD1RECNO,Recno()))
		Endif

    EndIf
    
	dbSelectArea(cAliasSD1)
	dbSkip()

EndDo

oSection1:Finish()

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Exclui o Arquivo Trabalho SD2 quando imprime NFs de devolucaoЁ
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If mv_par07 == 1

	RetIndex("SD2")
	dbSelectArea("SD2")
	dbClearFilter()
	dbSetOrder(1)
	
	If File(cArqTrbSD2+OrdBagExt())
		Ferase(cArqTrbSD2+OrdBagExt())
	EndIf
	
EndIf

Return Nil

/*/
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддддбдддддддбдддддддддддддддддддддддбддддддбдддддддддд©╠╠
╠╠ЁPrograma  ЁPrintDevolЁ Autor ЁAlexandre Inacio Lemes ЁData  Ё07/08/2006Ё╠╠
╠╠цддддддддддеддддддддддадддддддадддддддддддддддддддддддаддддддадддддддддд╢╠╠
╠╠ЁDescri┤┘o Ё Imprime as devolucoes de compras SD2                       Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁRetorno   ЁNenhum                                                      Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁParametrosЁ                                                            Ё╠╠
╠╠юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/
Static Function PrintDevol(aRecno,lQuery,oReport,oSection1,oSection2,cAliasSD1,nRecno)

Local nDecs    := Msdecimais(mv_par09) //casas decimais utilizadas na moeda da impressao
Local nX       := 0
Local nY       := 0
Local nSaveRec := If( lQuery, nRecno, Recno() )

oSection2:Init()
		
TRPosition():New(oSection2,"SB1",1,{|| xFilial("SB1")+SD2->D2_COD })

For nX :=1 to Len(aRecno)
	
	dbSelectArea("SD1")
	dbGoto(aRecno[nX])
	dbSelectArea("SD2")
	MsSeek(SD1->D1_FILIAL+SD1->D1_COD+SD1->D1_DOC+SD1->D1_ITEM+SD1->D1_SERIE+SD1->D1_FORNECE+SD1->D1_LOJA)
	SF2->(MsSeek(SD2->D2_FILIAL+SD2->D2_DOC+SD2->D2_SERIE+SD2->D2_CLIENTE+SD2->D2_LOJA))
	
	While !Eof() .And. SD1->D1_FILIAL+SD1->D1_COD+SD1->D1_DOC+SD1->D1_ITEM+SD1->D1_SERIE+SD1->D1_FORNECE+SD1->D1_LOJA ==;
		SD2->D2_FILIAL+SD2->D2_COD+SD2->D2_NFORI+SD2->D2_ITEMORI+SD2->D2_SERIORI+SD2->D2_CLIENTE+SD2->D2_LOJA
		
		If nX == 1
			oReport:PrintText(STR0012,,oSection2:Cell("D2_DOC"):ColPos()) //'-Devolucoes:'
		Endif
		
		If lVeiculo
			oReport:PrintText("[ " + SB1->B1_CODITE + " ]",,oSection2:Cell("D2_COD"):ColPos())
		EndIf
		
		If cPaisLoc <> "BRA"
			aImpostos:=TesImpInf(SD2->D2_TES)
			nImpInc	:=	0
			nImpNoInc:=	0
			nImpos	:=	0
			For nY:=1 to Len(aImpostos)
				cCampImp:="SD2->"+(aImpostos[nY][2])
				nImpos:=&cCampImp
				nImpos:=xmoeda(nImpos,SF2->F2_MOEDA,mv_par09,SF2->F2_EMISSAO,nDecs+1,SF2->F2_TXMOEDA)
				If ( aImpostos[nY][3]=="1" )
					nImpInc	+=nImpos
				Else
					If aImpostos[nY][3]=="2"
						nImpInc-=nImpos
					Else
						nImpNoInc+=nImpos
					Endif
				EndIf
			Next nY
		Endif
		
   		nValUnit := xmoeda(SD2->D2_PRCVEN,SF2->F2_MOEDA,mv_par09,SF2->F2_EMISSAO,nDecs+1) 
		nValTot  := xmoeda(SD2->D2_TOTAL,SF2->F2_MOEDA,mv_par09,SF2->F2_EMISSAO,nDecs+1)
		nValTIPI := SD2->D2_TOTAL + SD2->D2_VALIPI + SD2->D2_VALFRE + SD2->D2_DESPESA 
		cGeraDP  := Posicione("SF4",1,xFilial("SF4")+ SD2->D2_TES,"F4_DUPLIC")
		CDPAG    := Posicione("SE4",1,xFilial("SE4")+(cAliasSD1)->F1_COND,"E4_COND") 
		nValCusto:= xmoeda(SD2->D2_CUSTO1,1,mv_par09,SF2->F2_EMISSAO,nDecs+1)
		nPerCust := If(SD2->D2_TP = "MP",SD2->D2_CUSTO1 / SD2->D2_TOTAL * 100,0)

		SA2->(dbSetOrder(1))
		SA2->(MsSeek( xFilial("SA2") + SD2->D2_CLIENTE + SD2->D2_LOJA ))
		cRazao := SA2->A2_NOME

		oSection2:PrintLine()
		
		dbSelectArea("SD2")
		dbSkip()
		
	EndDo

    If nX == Len(aRecno)		
		oReport:ThinLine()
		oReport:SkipLine()		
    EndIf
      
Next nX

oSection2:Finish()

dbSelectArea(cAliasSD1)
dbgoto(nSaveRec)
aRecno := {}

Return

/*/
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддддбдддддддбдддддддддддддддддддддддбддддддбдддддддддд©╠╠
╠╠ЁPrograma  ЁGetValImp Ё Autor Ё Suprimentos           Ё Data Ё09/08/2018Ё╠╠
╠╠цддддддддддеддддддддддадддддддадддддддддддддддддддддддаддддддадддддддддд╢╠╠
╠╠ЁDescri┤┘o Ё Retorna os campos de imposto variavel                      Ё╠╠
╠╠юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/
Static Function GetValImp()

Local aStru := FWFormStruct(3,"SD1")[1]
Local nX
Local cRet	:= ""

// Retorno da FWFormStruct = 3
//[01][03] ExpC:idField
//[01][14] ExpL:Campo virtual?

For nX := 1 To Len(aStru)
	If "D1_VALIMP" $ aStru[nX][3]
		cRet += (IIf( Empty(Alltrim(cRet)),"",", ") + aStru[nX][3] )
	EndIf
Next nX

Return cRet