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


	DEFINE MSDIALOG oDlg FROM  60,30 TO 220, 220 TITLE "Impress�o de Etiquetas"  PIXEL
		
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
	
	//Local cEtiq
	Local cInfEt1	:= ""
	Local cInfEt2	:= ""
	Local cInfEt3	:= ""
	Local cInfEt4	:= ""
	Local cInfEt5	:= ""
	Local cInfEt6	:= ""
	Local cSerial	:= ""
	
	Local lImpImg	:= .F.
	
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
	
	/*DbSelectArea("CB0")
	CB0->(DbSetOrder(7))
	CB0->(DbGoTop())
	If CB0->(DbSeek(xFilial("CB0") + SC2->C2_NUM + SC2->C2_ITEM + SC2->C2_SEQUEN ))
		
		cEtiq	:= CB0->CB0_CODETI
	
	Else
	
		cEtiq	:= GETSXENUM("CB0", "CB0_CODETI")
		
		RecLock("CB0", .T.)
		CB0->CB0_FILIAL		:= xFilial("SG1")
		CB0->CB0_CODETI 	:= cEtiq
		CB0->CB0_DTNASC		:= dDataBase	
		CB0->CB0_CODPRO		:= SC2->C2_PRODUTO
		CB0->CB0_QTDE  		:= 1
		CB0->CB0_USUARI		:= __cUserID
		CB0->CB0_OP    		:= SC2->C2_NUM + SC2->C2_ITEM + SC2->C2_SEQUEN
		CB0->CB0_NUMSEQ		:= cEtiq
		CB0->(MSUnLock())
		
		ConfirmSX8()
	EndIf
	*/
	
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
	
	for i:=1 to _qimp 
		nLin	:= 5
		cSerial		:= U_etiqueta()
		//Conout("Qtd. etiquetas: " + CValToChar(i))
		oPrint:StartPage()
		
		If !lImpImg
			oPrint:Say(nLin,580,"BRASLAR DO BRASIL LTDA",oFont03,,,,2) //
			nLin+= 42
			oPrint:Say(nLin,580,"AVENIDA CONTINENTAL, n� S/N - DISTRITO INDUSTRIAL - PONTA GROSSA - PR",oFont03,,,,2) //
			nLin+= 42
			oPrint:Say(nLin,580,"CNPJ:04.016.420/0001-17 - Insc. 90219779666",oFont03,,,,2) //
			nLin+= 42
			oPrint:Say(nLin,580,"TELEFONE:42 32205650 Web Site: www.fogoesbraslar.com.br",oFont03,,,,2) //
		Else
			oPrint:SayBitmap(nLin,250,fFoto() ,600,165)
			nLin+= 126
		EndIf
		
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
		oPrint:Say(nLin,050,dToC(dDataBase),oFont01,) //Data Fabrica��o
		oPrint:Say(nLin,450,cSerial,oFont01,)   // Num OP
		nLin+= 82
		oPrint:line(nLin-2 ,020 ,nLin-2 ,1100)					//Linha Horizontal
		oPrint:line(nLin-3 ,020 ,nLin-3 ,1100)					//Linha Horizontal
		msBar3( 'CODE128', 5.50 ,000 , cSerial, oPrint, .F., , .T., 0.022, 1.2, .F., 'TAHOMA', 'B', .F. )  
		
		oPrint:Say(nLin,700,"INDUSTRIA BRASILEIRA",oFont03,)   // Num OP
		msBar3( 'EAN13', 5.50 ,007 , cGTIN, oPrint, .F., , .T., 0.027, 1.2, .F., 'TAHOMA', 'B', .F. )  
		//oPrint:Say(055,520,_cHora,oFont03,) //Hora Fabrica��o
		/*If !Empty(_aLote)
			oPrint:Say(190,010,_aLote,oFont01,) 
			msBar3( 'CODE128', 2.00 ,000 , _aLote , oPrint, .F., , .T., 0.025, 0.6, .F., 'TAHOMA', 'B', .F. ) //Lote
		EndIf
		If !Empty(_aLote)//caso n�o tenha lote, imprimie o desenho na posicao do lote
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
	//oPrint:Print()
	Conout("Final")
	
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
	��������������������������������������������������������������Ŀ
	� Carrega a Foto do Produto								   �
	����������������������������������������������������������������*/
	cBmpPict := Upper( AllTrim( SA1->A1_BITMAP))
	cPathPict 	:= ( cPath + cBmpPict )

	//ConOut("Produto: "+SB5->B5_COD+" Imagem: "+cPathPict)
	/*
	��������������������������������������������������������������Ŀ
	� Para impressao da foto eh necessario abrir um dialogo para   �
	� extracao da foto do repositorio.No entanto na impressao,nao  |
	� ha a necessidade de visualiza-lo( o dialogo).Por esta razao  �
	� ele sera montado nestas coordenadas fora da Tela             �
	����������������������������������������������������������������*/
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
					ConOut("Falha na dele��o do Arquivo: "+cPathPict+".JPG")
				EndIf
			EndIf

			If File(cPathPict+".BMP")

				If  (FERASE(cPathPict+".BMP") == -1)
					ConOut("Falha na dele��o do Arquivo: "+cPathPict+".BMP")
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

#include 'protheus.ch'
#include 'parmtype.ch'
#include 'TOPCONN.CH'

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

