#include "protheus.ch"
#include "topconn.ch"
#include "fwmbrowse.ch"
#include "fwmvcdef.ch"
#include "colors.ch"

/*
+---------------------------------------------------------------------------------+
!                         FICHA TÉCNICA DO PROGRAMA                               !
+---------------------------------------------------------------------------------+
!DADOS DO PROGRAMA                                                                !
+------------------+--------------------------------------------------------------+
!Tipo              ! Rotina Específica                                            !
+------------------+--------------------------------------------------------------+
!Módulo            ! OMS                                                          !
+------------------+--------------------------------------------------------------+
!Nome              ! AOMS200A                                                     !
+------------------+--------------------------------------------------------------+
!Descrição         ! Rotina para conferencia de carrregamento                     !
+------------------+--------------------------------------------------------------+
!Autor             ! Douglas Negrello                                             !
+------------------+--------------------------------------------------------------+
!Data de Criação   ! 31/07/2019                                                   !
+------------------+--------------------------------------------------------------+
!ATUALIZACÕES                                                                     !
+-------------------------------------------+------------+------------+-----------+
!Descrição detalhada da atualização         !Nome do     !Analista    !Data da    !
!                                           !Solicitante !Responsável !Atualização!
+-------------------------------------------+------------+------------+-----------+
!                                           !            !            !           !
!                                           !            !            !           !
+-------------------------------------------+------------+------------+-----------+
!                                           !            !            !           !
!                                           !            !            !           !
+-------------------------------------------+------------+------------+-----------+
*/

Static cTitulo := "Conferencia de carregamento"

//User Function OM200US
//  AAdd(aRotina,{'Conferencia','U_AOMS200A()',0,3 })
//Return aRotina
		
User Function AOMS200A()

Local aArea   := GetArea()
Local oBrowse := FWMBrowse():New()

oBrowse:SetAlias("DAI")
oBrowse:SetDescription(cTitulo)
oBrowse:SetMenuDef("CARGAS_OMSA200")

oBrowse:DisableDetails()
oBrowse:SetUseCursor(.F.)

//oBrowse:DeleteFilter( "DAK_BLQCAR" )
oBrowse:AddFilter( "Bloqueados", "U_AOMS200F()", .T., .T., "", , , "" )
oBrowse:ExecuteFilter()	
		
//oBrowse:AddLegend("!Empty(ZAA->ZAA_NFPROT)", "BR_VERDE   ", "Nota Fiscal Emitida   ")
//oBrowse:AddLegend("Empty(ZAA->ZAA_NFPROT) ", "BR_VERMELHO", "Aguardando Nota Fiscal")
//oBrowse:AddLegend("Empty(ZAA->ZAA_TRANSP) ", "BR_AMARELO ", "Cadastro Inconsistente")

oBrowse:Activate()

RestArea(aArea)

Return

//-----------------------
//Criação do menu
//-----------------------
Static Function MenuDef()

Local aRot := {}

ADD OPTION aRot TITLE "Conferir  " ACTION "U_AOMS200B"             OPERATION 3 ACCESS 0
//ADD OPTION aRot TITLE "Alterar   " ACTION "VIEWDEF.CARGAS_OMSA200"     OPERATION 4 ACCESS 0
ADD OPTION aRot TITLE "Visualizar" ACTION "VIEWDEF.CARGAS_OMSA200"     OPERATION 2 ACCESS 0
//ADD OPTION aRot TITLE "Legenda   " ACTION "U_AOMS200L            " OPERATION 6 ACCESS 0

Return aRot


//------------------------------
//Criação do modelo de dados MVC
//------------------------------
Static Function ModelDef()

	Local oModel := MPFormModel():New("CARGAS_OMSA200",,,,)
	Local oStDAI := FWFormStruct(1,"DAI")
	Local aAux   := {}
	
	oModel:AddFields("FORMDAI",,oStDAI)
	oModel:SetPrimaryKey({"DAI_FILIAL","DAI_COD"})
	oModel:SetDescription(cTitulo)
	oModel:GetModel("FORMDAI"):SetDescription(cTitulo)

Return oModel

//-----------------------
//Criação da visão MVC
//-----------------------
Static Function ViewDef()

	Local oModel := FWLoadModel("CARGAS_OMSA200")
	Local oStDAI := FWFormStruct(2, "DAI")
	Local oView  := FWFormView():New()
	
	oView:SetModel(oModel)
	oView:AddField("VIEW_DAI",oStDAI,"FORMDAI")
	
	oView:CreateHorizontalBox("SUPERIOR",100)
	oView:SetOwnerView("VIEW_DAI","SUPERIOR")
	
	oView:EnableTitleView("VIEW_DAI", "")
	oView:SetCloseOnOk({||.T.})
	
	oView:EnableControlBar(.F.)
	oView:SetUseCursor(.F.)

Return oView


User Function AOMS200F()

	Local lRet		:= .F.
	Local aAreaDAI 	:= DAI->(GetArea())
	
	//CARGAS
	DbSelectArea("DAK")
	DAK->(DbSetOrder(1))
	DAK->(DbGoTop())    
	If DAK->(DbSeek(xFilial("DAK")+DAI->DAI_COD))
		If DAK->DAK_BLQCAR == '1'
			lRet := .T.
		EndIf
	EndIf

	RestArea(aAreaDAI)

Return(lRet)

//----------------------
/*
User Function AOMS200L()

	Local aLegenda := {}
	
	AADD(aLegenda,{"BR_VERDE   ", "Nota Fiscal Emitida   "})
	AADD(aLegenda,{"BR_VERMELHO", "Aguardando Nota Fiscal"})
	AADD(aLegenda,{"BR_AMARELO ", "Cadastro Inconsistente"})
	
	BrwLegenda("Status Ticket","",aLegenda)

Return
*/

//----------------------
User Function AOMS200B()

	Local aArea  := GetArea()
	Local cQuery :=  ""
	local nInd
	
	U_AOMS200C()

Return


User Function AOMS200C()

	Local aSizeAuto := MsAdvSize()

	Private aHead1 := {}
	Private aCols1 := {}
	Private cIniCpos	:= "+ITEM"
	
	Private cCodigo		:= DAI->DAI_COD
	Private cTransp		:= ""
	Private cPedido		:= DAI->DAI_PEDIDO
	Private cRota		:= POSICIONE("DA8",1,XFILIAL("DA8") + DAI->DAI_ROTEIR,"DA8_DESC")
	Private dData		:= DAI->DAI_DATA
	Private cHora		:= DAI->DAI_HORA
	Private cCodBar		:= Space(TAMSX3("B1_CODBAR")[1]) //ALTER: B1_COD to B1_CODBAR
	
	cCodTransp	:= POSICIONE("DAK",1,XFILIAL("DAK")+DAI->DAI_COD,"DAK_TRANSP")
	
	cTransp		:= POSICIONE("SA4",1,XFILIAL("SA4")+cCodTransp,"A4_NOME")
	
	aHead1 := fHeader()

	nPosItem	:= aScan(aHead1, {|x| AllTrim(x[2]) == "ITEM"})
	nPosProd	:= aScan(aHead1, {|x| AllTrim(x[2]) == "PROD"})
	nPosQtdP	:= aScan(aHead1, {|x| AllTrim(x[2]) == "QTDP"})
	nPosQtdC	:= aScan(aHead1, {|x| AllTrim(x[2]) == "QTDC"})
	nPosStat	:= aScan(aHead1, {|x| AllTrim(x[2]) == "STAT"})
	nPosRecn 	:= aScan(aHead1, {|x| AllTrim(x[2]) == "RECN"})
	
	aCols1 := fCols()

	nColDel := Len(aCols1[1])
	
	oDlgSep 	:= MSDialog():New(aSizeAuto[7], 020, 520, 850,"Conferencia de Carregamento",,,.F.,,,,,,.T.,,,.T. )
	oSayCodi 	:= TSay():New( 08,010 ,{||"Carga:"} ,oDlgSep,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,060,008)
	oGetCodi 	:= TGet():New( 05,030 ,bSetGet(cCodigo),oDlgSep,060,012,"",,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","",,)
	oSayTran 	:= TSay():New( 08,100 ,{||"Transportador:"} ,oDlgSep,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,060,008)
	oGetTran 	:= TGet():New( 05,140 ,bSetGet(cTransp),oDlgSep,120,012,"",,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","",,)
	
	oSayPedi 	:= TSay():New( 27,010 ,{||"Pedido:"} ,oDlgSep,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,060,008)
	oGetPedi 	:= TGet():New( 24,030 ,bSetGet(cPedido),oDlgSep,038,012,"",,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","",,)
	oSayData 	:= TSay():New( 27,085 ,{||"Data:"} ,oDlgSep,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,065,008)
	oGetData 	:= TGet():New( 24,100 ,bSetGet(dData),oDlgSep,035,012,"",,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","",,)
	oSayHora 	:= TSay():New( 27,150 ,{||"Hora:"} ,oDlgSep,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,065,008)
	oGetHora 	:= TGet():New( 24,165 ,bSetGet(cHora),oDlgSep,20,012,"",,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","",,)
	oSayRota 	:= TSay():New( 27,220 ,{||"Rota:"} ,oDlgSep,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,060,008)
	oGetRota 	:= TGet():New( 24,235 ,bSetGet(cRota),oDlgSep,120,012,"",,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","",,)
	
	nBrwLarg 	:= (oDlgSep:nClientWidth / 2)// - 10 
	nBrwAlt 	:= (oDlgSep:nClientHeight / 2) - 52 //* .20
	oBrw1 		:= MsNewGetDados():New( 42 , 0, nBrwAlt, nBrwLarg,0,"AllwaysTrue()","AllwaysTrue()",cIniCpos,{},0,99,,,{|| .F.},oDlgSep,aHead1,aCols1)
	oBrw1:oBrowse:bdelete:= {|| oBrw1:DelLine()}
	
	oSayCBar 	:= TSay():New( nBrwAlt + 16,080 ,{||"Codigo de Barras:"} ,oDlgSep,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,060,008)
	oGetCBar 	:= TGet():New( nBrwAlt + 6,140 ,bSetGet(cCodBar),oDlgSep,120,024,"",{||U_AOMS200V()},CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","",,)
	
	oBtConf 	:= TButton():New( nBrwAlt + 6 , nBrwLarg - 150,"Confirmar"	,oDlgSep,{|| U_AOMS200O()},060,025,,,,.T.,,"",,,,.F. )
	oBtCanc 	:= TButton():New( nBrwAlt + 6 , nBrwLarg - 080,"Cancelar" 	,oDlgSep,{|| oDlgSep:End()},060,025,,,,.T.,,"",,,,.F. )
		
	oGetCodi:Disable()
	oGetTran:Disable()
	oGetPedi:Disable()
	oGetData:Disable()
	oGetHora:Disable()
	oGetRota:Disable()
	
	oBrw1:oBrowse:bLDblClick := {|| ""}
	 	
	oDlgSep:Activate(,,,.T.)
	
Return

Static Function fHeader()

	Local aAux := {}
	
	//Aadd( aHeader, { Rtrim( SX3->(X3Titulo())),	SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,SX3->X3_USADO,SX3->X3_TIPO,".T.",SX3->X3_CONTEXT,SX3->X3_CBOX })
	
	Aadd(aAux,{"Item"					,"ITEM"		,"@!"	, 3  , 0 , "" , "û" , "C" , ,"V" })			
	Aadd(aAux,{"Produto"				,"PROD"		,"@!"	, 30 , 0 , "" , "û" , "C" , ,"V",""})
	Aadd(aAux,{"Quant. Pedido"			,"QTDP"		,"@!"	, 9  , 0 , "" , "û" , "N" , ,"V","" })
	Aadd(aAux,{"Quant. Conferido"		,"QTDC"		,"@!"	, 9  , 0 , "" , "û" , "N" , ,"V","" })
	Aadd(aAux,{"Concluido" 				,"STAT"		,"@!"	, 1  , 0 , "" , "û" , "C" , ,"V","1=Pendente;2=OK;3=Deferido" })
	Aadd(aAux,{"WT recno"				,"RECN" 	,"@!"	, 10 , 0 , "" , "û" , "C" , ,"V" })	
	
Return(aAux)

Static Function fCols()

	Local aAux := {}
	Local cAliasQry := GetNextAlias()	

	DbSelectArea("SC9")
	SC9->(DbSetOrder(3))//C9_FILIAL+C9_PEDIDO+C9_GRUPO+C9_PRODUTO
	SC9->(DbGoTop())
	If SC9->(DbSeek(xFilial("DAI")+DAI->DAI_PEDIDO))
	
		While SC9->(!Eof()) .AND. DAI->DAI_PEDIDO == SC9->C9_PEDIDO
	
			If SC9->(FieldPos("C9_CONFERI")) > 0 .AND. SC9->C9_CONFERI	== "S"
				cConferido := "2"
				nQuantConf	:= SC9->C9_QTDLIB
			Else
				cConferido := "1"
				nQuantConf	:= 0
			EndIf
			
			aAdd(aAux,{ SC9->C9_ITEM,;
					SC9->C9_PRODUTO,;
					SC9->C9_QTDLIB,;
					nQuantConf,;
					cConferido,;
					SC9->(recno()),;
					.F.})
			SC9->(DbSkip())
		EndDo
		aAux	:= aSort(aAux,,,{|x,y| x[1] < y[1]})
	EndIf
	
Return(aAux)


User Function AOMS200V()

Local nLinPro	:= 0
Local cProduto := " "
Local aEtiqueta := {}


aEtiqueta := CBRetEtiEan(cCodBar)
cProduto := aEtiqueta[1]

nLinPro :=	aScan(oBrw1:ACOLS,{|x| Alltrim(x[2]) == cProduto})

If nLinPro <> 0
	oBrw1:aCols[nLinPro][nPosQtdC] 	:= oBrw1:ACOLS[nLinPro][nPosQtdC]+1
	
	If oBrw1:aCols[nLinPro][nPosQtdP] == oBrw1:aCols[nLinPro][nPosQtdC]
		oBrw1:aCols[nLinPro][nPosStat] := "2"
	EndIf
	
	//CONFERIDO MAIOR QUE A QUANTIDADE NO ITEM LBERADO DO PEDIDO (SC9)
	If oBrw1:aCols[nLinPro][nPosStat] == "2" .AND. oBrw1:aCols[nLinPro][nPosQtdC] > oBrw1:aCols[nLinPro][nPosQtdP]
		oBrw1:aCols[nLinPro][nPosStat] := "3"
	EndIf
	
	cCodBar := Space(TAMSX3("B1_CODBAR")[1]) // ALTER
	oGetCBar:Refresh()
	oBrw1:Refresh()
Else
	alert("Produto nao encontrado no pedido atual!")
EndIf

Return(.T.)


User Function AOMS200O()

	If SC9->(FieldPos("C9_CONFERI")) > 0 
		DbSelectArea("SC9") 
		For nLin := 1 To Len(oBrw1:aCols)
			If oBrw1:aCols[nLin][nPosStat] == "2"
				dbGoto(oBrw1:aCols[nLin][nPosRecn])
				RecLock("SC9",.F.)
				SC9->C9_CONFERI	:= "S"
				MsUnlock()
			EndIf
		Next nLin
	Else
		Alert("Atualização de dicionário necessária, campo 'C9_CONFERI' não encontrado!")
	EndIf
	
	oDlgSep:End()
	//C9_CONFERI

Return

