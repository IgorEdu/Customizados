#include "Totvs.ch"
#include "Rwmake.ch"
#include "protheus.ch"
#INCLUDE "FWPrintSetup.ch"
#INCLUDE "RPTDEF.CH"
#include "shell.ch"
#INCLUDE "RPTDEF.CH"
#INCLUDE "FWPrintSetup.ch"
#INCLUDE "protheus.ch"

User Function Teste()
    aTeste := GetImpWindows(.F.)
Return Nil

User Function totvsprt()
	RpcSetType(3)
	RpcSetEnv("01", "01  01",,,, )
	// RpcSetEnv("99", "01",,,,)

	oFont01  := Tfont():New("Arial",,14,,.F.,,,,.F.,.F.,)
	oFont01N := Tfont():New("Arial",,14,,.T.,,,,.F.,.F.,)
	oFont03  := Tfont():New("Arial",,08,,.F.,,,,.F.,.F.,)
	oFont03N := Tfont():New("Arial",,08,,.T.,,,,.F.,.F.,)

	lAdjustToLegacy := .F.
	lDisableSetup  := .F.
	oPrint := FWMSPrinter():New("Etiquetas", IMP_SPOOL, .F., , lDisableSetup,,, GetImpWindows(.F.)[1], .F.)
	oPrint:SetResolution(78)
	oPrint:SetPortrait()
	// oPrint:SetMargin(0,0,0,0)

	oPrint:StartPage()

	oPrint:SayBitmap(05,090, "\cprova\Geral.jpg" , 100, 30)

	// oPrint:Say( 08, 00, PadC("BRASLAR DO BRASIL LTDA",112) , oFont03)
	// oPrint:Say( 16, 00, "AVENIDA CONTINENTAL, nº S/N - DISTRITO INDUSTRIAL - PONTA GROSSA - PR", oFont03)
	// oPrint:Say( 24, 00, PadC("CNPJ:04.016.420/0001-17 - Insc. 90219779666", 112), oFont03)
	// oPrint:Say( 32, 00, PadC("TELEFONE:42 32205650 Web Site: www.fogoesbraslar.com.br", 112), oFont03)
	// oPrint:Say( 34, 00, Replicate("_", 090), oFont03)

	oPrint:Say( 48, 00, PadC("10010001", 80), oFont01N)
	oPrint:Say( 58, 00, PadC("FOGAO 4 BC SIRIUS BCO", 80), oFont01N)
	oPrint:Say( 68, 00, PadC("COMPLEMENTO", 80), oFont01N)

	oPrint:Say( 74, 00, Replicate("_", 075), oFont03)
	oPrint:Say( 84, 00, PadC("CATEGORIA:I3 APARELHO CLASSE: 01 PRESSÃO: 2,75 KPA", 100), oFont03N)
	oPrint:Say( 86, 00, Replicate("_", 075), oFont03)

	oPrint:Say(100, 0, "Potencia Nominal: 8,91 kW", oFont03)
	oPrint:Say(100, 150, "Tensão Nominal: 127V - 220V", oFont03)

	oPrint:Say(108, 0, "Frequência: 50-60 Hz", oFont03)
	oPrint:Say(108, 150, "Potência: 40W(127V) 40W(220V)", oFont03)

	oPrint:Say(116, 0, "Tipo de Ligação: Y", oFont03)
	oPrint:Say(116, 150, "Grau de Proteção: IPXO", oFont03)

	oPrint:Say(122, 00, Replicate("_", 075), oFont03)
	oPrint:Say(136, 0, "25/11/2019", oFont01)
	oPrint:Say(136, 150, "S4BCO_S_0000021638", oFont01)
	oPrint:Say(142, 00, Replicate("_", 075), oFont03)

	oPrint:Say( 156, 150, "INDUSTRIA BRASILEIRA", oFont03)

	oPrint:Code128(166/*nRow*/ ,0/*nCol*/, "S4BCO_S_0000021638"/*cCode*/,1/*nWidth*/,40/*nHeigth*/,.F./*lSay*/,,180)
	oPrint:FWMSBAR("EAN13" /*cTypeBar*/,13.5/*nRow*/ ,16/*nCol*/ ,"7898385060428"  /*cCode*/,oPrint/*oPrint*/,/*lCheck*/,/*Color*/,/*lHorz*/, 0.020/*nWidth*/,1.2/*nHeigth*/,/*lBanner*/,"Arial" /*cFont*/, /*cMode*/,.F./*lPrint*/,/*nPFWidth*/,/*nPFHeigth*/, .F. /*lCmtr2Pix*/)

	oPrint:EndPage()

	oPrint:Preview()

	RpcClearEnv()

Return
