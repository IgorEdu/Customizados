#include 'protheus.ch'
User Function FISTRFNFE

aadd(aRotina,{"Etiquetas Expd","U_ETIQEXPD()"     ,0,2,0 ,NIL})

Return


//*****************************************************************************
USer function ETIQEXPD()
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
     
	oFont01N := Tfont():New("TAHOMA",,18,,.T.,,,,.F.,.F.,) 
	oFont03  := Tfont():New("TAHOMA",,10,,.F.,,,,.F.,.F.,) 
	
	cDoc		:= Alltrim(SF2->F2_DOC + " " + SF2->F2_SERIE) 
	cNomeCli 	:= AllTrim(Posicione("SA1",1,xFilial("SA1")+SF2->(F2_CLIENTE+F2_LOJA),"A1_NOME"))
	cNomeTra 	:= AllTrim(Posicione("SA4",1,xFilial("SA4")+SF2->F2_TRANSP,"A4_NOME"))
	
	for i:=1 to SF2->F2_VOLUME1 
		nLin	:= 15
		//Conout("Qtd. etiquetas: " + CValToChar(i))
		oPrint:StartPage()
		
		oPrint:Say(nLin,450,cNomeCli,oFont03,,,,2) //
		nLin+= 60
		oPrint:Say(nLin,450,"NF: " + cDoc ,oFont01N,,,,2) //
		nLin+= 70
		oPrint:Say(nLin,450,"Seq: " + StrZero(i,4)+" Vol: "+StrZero(SF2->F2_VOLUME1,4),oFont01N,,,,2) //
		//nLin+= 42
		//oPrint:Say(nLin,580,cValToChar(i)+"/"+cValToChar(SF2->F2_VOLUME1),oFont03,,,,2) //
		nLin+= 80
		oPrint:Say(nLin,450,cNomeTra,oFont03,,,,2) //
		nLin+= 50
 		oPrint:Say(nLin,450,dToC(SF2->F2_EMISSAO),oFont01N,,,,2)
		oPrint:EndPage()
		//oPrint:Preview() //Visualiza antes da impressao
	next

	oPrint:Print()
	Conout("Final")
	
Return


