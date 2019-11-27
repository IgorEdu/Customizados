#include "Protheus.ch"
#include "rwmake.ch"        // incluido pelo assistente de conversao do AP5 IDE em 02/08/01
//#INCLUDE "TBICONN.CH" 

Static _cRepDb	:= GetSrvProfString("RepositInDataBase","")
Static _cRep	:= SuperGetMv("MV_REPOSIT",.F.,"1")
Static _lRepDb	:= ( _cRepDb == "1" .And. _cRep == "2" )

User Function MA650BUT

	AAdd( aRotina, { 'Etiquetas', 'U_ETIQBAR()', 0, 5 } ) 
	
Return(aRotina)

User Function ETIQBAR(_aCod,_aOP,_aOperador,_aData,_quant,_cHora,_cLocal,_aLote)

	Default _cHora	:= ""
	Default _cLocal := ""

	Private _qimp := 0


	DEFINE MSDIALOG oDlg FROM  60,30 TO 220, 220 TITLE "Impressão de Etiquetas"  PIXEL
		
		@ 013, 023 SAY OemToAnsi("Quantas etiquetas ?:")  SIZE 065, 08 PIXEL OF oDlg
		@ 023, 023 MSGET _qimp PICTURE "@E 9999" WHEN .T. SIZE 040, 10 PIXEL OF oDlg
		
		@ 040,025 BmpButton Type 1 Action (nOpc:=1,close(oDlg))
		@ 040,055 BmpButton Type 2 Action (nOpc:=0,close(oDlg))

	ACTIVATE MSDIALOG oDlg CENTERED
	
	If nOpc == 1
		U_Start()
	Endif
	
Return(Nil)

//*****************************************************************************
USer function Start()
	//Close(oDlg)
	//Set Filter To
	RptStatus({|| RptDetalhe() })// Substituido pelo assistente de conversao do AP5 IDE em 12/09/01 ==> RptStatus({|| Execute(RptDetalhe) })
Return

//***********************************************************************************
Static Function RptDetalhe() 
	oPrint := TMSprinter():New("Etiquetas")	
	oPrint:SetPortrait()  //Modo Retrato
    
    
    If !oPrint:Setup()
		oPrint:Cancel() //Cancela impressao
		Alert("Impressao cancelada!")
		Conout("Impressao cancelada!")
		Return 
    EndIf

	oFont01  := Tfont():New("TAHOMA",,14,,.F.,,,,.F.,.F.,)       
	oFont01N := Tfont():New("TAHOMA",,14,,.T.,,,,.F.,.F.,) 
	oFont03  := Tfont():New("TAHOMA",,08,,.F.,,,,.F.,.F.,) 
	oFont03N := Tfont():New("TAHOMA",,08,,.T.,,,,.F.,.F.,) 
	
	
	cCod		:= SC2->C2_PRODUTO
	cDescProd 	:= AllTrim(Posicione("SB1",1,xFilial("SB1")+cCod,"B1_DESC"))
	
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
	
	for i:=1 to _qimp 
		nLin	:= 5
		//Conout("Qtd. etiquetas: " + CValToChar(i))
		oPrint:StartPage()
		
		oPrint:Say(nLin,580,"BRASLAR DO BRASIL LTDA",oFont03,,,,2) //
		nLin+= 42
		oPrint:Say(nLin,580,"AVENIDA CONTINENTAL, nº S/N - DISTRITO INDUSTRIAL - PONTA GROSSA - PR",oFont03,,,,2) //
		nLin+= 42
		oPrint:Say(nLin,580,"CNPJ:04.016.420/0001-17 - Insc. 90219779666",oFont03,,,,2) //
		nLin+= 42
		oPrint:Say(nLin,580,"TELEFONE:42 32205650 Web Site: www.fogoesbraslar.com.br",oFont03,,,,2) //
		nLin+= 47
 		oPrint:Say(nLin,580,cCod,oFont01N,,,,2)
		oPrint:line(nLin-2 ,020 ,nLin-2 ,1100)					//Linha Horizontal
		oPrint:line(nLin-3 ,020 ,nLin-3 ,1100)					//Linha Horizontal
		nLin+= 80
 		oPrint:Say(nLin,575,SubStr(cDescProd,1,35),oFont01N,,,,2)
		oPrint:line(nLin-2 ,020 ,nLin-2 ,1100)					//Linha Horizontal
		oPrint:line(nLin-3 ,020 ,nLin-3 ,1100)					//Linha Horizontal
		If Len(cDescProd) > 35
			nLin+= 82
	 		oPrint:Say(nLin,575,SubStr(cDescProd,36,35),oFont01N,,,,2)
 		EndIf
		//If Len(cDescProd) > 50
		//	nLin+= 85
	 	//	oPrint:Say(nLin,575,SubStr(cDescProd,51,25),oFont01N,,,,2)
		//EndIf
		nLin+= 87
 		oPrint:Say(nLin,565,SubStr(cDescCient,1,70),oFont03N,,,,2)
		oPrint:line(nLin-1 ,020 ,nLin-1 ,1100)					//Linha Horizontal
		oPrint:line(nLin-2 ,020 ,nLin-2 ,1100)					//Linha Horizontal
	 	nLin+= 42
		/*
		If Len(cDescCient) > 70
			oPrint:Say(nLin,565,SubStr(cDescCient,71,70),oFont03N,,,,2)
	 		nLin+= 45
		EndIf
		If Len(cDescCient) > 140
			oPrint:Say(nLin,565,SubStr(cDescCient,141,70),oFont03N,,,,2)
	 		nLin+= 45
		EndIf
		*/
		oPrint:line(nLin-1 ,020 ,nLin-1 ,1100)					//Linha Horizontal
		oPrint:line(nLin-2 ,020 ,nLin-2 ,1100)					//Linha Horizontal
 		oPrint:Say(nLin,050,cInfEt1,oFont03,)  // OP
 		oPrint:Say(nLin,550,cInfEt2,oFont03,)  // OP
		nLin+= 42
 		oPrint:Say(nLin,050,cInfEt3,oFont03,)  // OP
 		oPrint:Say(nLin,550,cInfEt4,oFont03,)  // OP
		nLin+= 42
 		oPrint:Say(nLin,050,cInfEt5,oFont03,)  // OP
 		oPrint:Say(nLin,550,cInfEt6,oFont03,)  // OP
		nLin+= 42
		oPrint:line(nLin-1 ,020 ,nLin-1 ,1100)					//Linha Horizontal
		oPrint:line(nLin-2 ,020 ,nLin-2 ,1100)					//Linha Horizontal
		oPrint:Say(nLin,050,dToC(dDataBase),oFont01,) //Data Fabricação
		//oPrint:Say(nLin,450,"123451234512345",oFont01,)   // Num OP
		nLin+= 82
		oPrint:line(nLin-2 ,020 ,nLin-2 ,1100)					//Linha Horizontal
		oPrint:line(nLin-3 ,020 ,nLin-3 ,1100)					//Linha Horizontal
		msBar3( 'CODE128', 6.00 ,000 , "10010001", oPrint, .F., , .T., 0.027, 1.2, .F., 'TAHOMA', 'B', .F. )  
		
		oPrint:Say(nLin,700,"INDUSTRIA BRASILEIRA",oFont03,)   // Num OP
		msBar3( 'EAN13', 6.00 ,006 , "7898385060428", oPrint, .F., , .T., 0.027, 1.2, .F., 'TAHOMA', 'B', .F. )  
		//oPrint:Say(055,520,_cHora,oFont03,) //Hora Fabricação
		/*If !Empty(_aLote)
			oPrint:Say(190,010,_aLote,oFont01,) 
			msBar3( 'CODE128', 2.00 ,000 , _aLote , oPrint, .F., , .T., 0.025, 0.6, .F., 'TAHOMA', 'B', .F. ) //Lote
		EndIf
		If !Empty(_aLote)//caso não tenha lote, imprimie o desenho na posicao do lote
			//B5_FILIAL+B5_COD
			If !Empty (Posicione("SB5",1,xFilial("SB5")+_acod,'B5_BITMAP'))
				oPrint:SayBitmap(340,010,fFoto(_aCod) ,600,600)
			EndIf
		Else
			//B5_FILIAL+B5_COD
			If !Empty (Posicione("SB5",1,xFilial("SB5")+_acod,'B5_BITMAP'))
				oPrint:SayBitmap(200,010,fFoto(_aCod) ,600,600)
			EndIf
		EndIf
		*/	
		oPrint:EndPage()
		//oPrint:Preview() //Visualiza antes da impressao
	next
	
	oPrint:Preview()
	oPrint:Print()
	Conout("Final")
	
Return


Static Function fFoto(cComponente)

	Local aArea		:= GetArea()
	Local cAlias	:= "PROTHEUS_REPOSIT"
	Local cBmpPict	:= ""
	Local cPath		:= "\IMAGENS_PROD\"	//GetSrvProfString("Startpath","")
	Local lFile
	Local oDlg8
	Local oBmp


	dbSelectArea("SB5")
	SB5->(DbSetOrder(1))  // B1_FILIAL+B1_COD
	SB5->(DbGoTop())
	If !SB5->(DbSeek(xFilial("SB5") + cComponente))
		Alert("Produto nao " + cComponente + " encontrado! ")
	EndIf

	/*
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³ Carrega a Foto do Produto								   ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	cBmpPict := Upper( AllTrim( SB5->B5_BITMAP))
	cPathPict 	:= ( cPath + cBmpPict )

	ConOut("Produto: "+SB5->B5_COD+" Imagem: "+cPathPict)
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
		IF !Empty( cBmpPict := Upper( AllTrim( SB5->B5_BITMAP ) ) )
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

					cLocalImg	:= "C:\TEMP\" + LOWER(AllTrim( SB5->B5_BITMAP ))  + ".jpg"
					cPathPict	:= cPathPict + ".JPG"
					CpyS2T( cPathPict , "C:\TEMP\", .T. , .T. )
					ConOut("Extraido aqruivo: "+cPathPict)
				ElseIf File(cPathPict+".BMP")
					//oPrint:SayBitmap(400,75,cPathPict + ".BMP",370,480)
					//aAdd(aFotos,cPathPict + ".BMP")

					cLocalImg	:= "C:\TEMP\" + LOWER(AllTrim( SB5->B5_BITMAP ))  + ".bmp"
					cPathPict	:= cPathPict + ".BMP"
					CpyS2T( cPathPict , "C:\TEMP\", .T. , .T. )
					ConOut("Extraido aqruivo: "+cPathPict)
				EndIf
			EndIf
		EndIf
	EndIf

	ACTIVATE MSDIALOG oDlg8 ON INIT (oBmp:lStretch := .T., oDlg8:End())

	RestArea(aArea)

Return (cLocalImg) 



