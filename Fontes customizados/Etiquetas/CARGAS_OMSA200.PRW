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
!Alteração para leitura através do          !            !Igor        ! 30/01/2020!
!número de série ao invés do EAN            !            !(Braslar)   !           !
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

ADD OPTION aRot TITLE "Conferir  " ACTION "U_AOMS200B"             OPERATION 4 ACCESS 0
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
/*User Function AOMS200B()

	//Local aArea  := GetArea()
	//Local cQuery :=  ""
	//local nInd
	
	U_AOMS200C()

Return*/


User Function AOMS200B() //Alterado (AOMS200C)

	Local aSizeAuto := MsAdvSize()
	Local aButtons := {}

	Private aHead1 := {}
	Private aCols1 := {}
	Private cIniCpos	:= "+ITEM"
	
	Private cCodigo		:= DAI->DAI_COD
	Private cTransp		:= ""
	Private cPedido		:= DAI->DAI_PEDIDO
	Private cRota		:= POSICIONE("DA8",1,XFILIAL("DA8") + DAI->DAI_ROTEIR,"DA8_DESC")
	Private dData		:= DAI->DAI_DATA
	Private cHora		:= DAI->DAI_HORA
	Private cCodBar		:= Space(19)//Space(TAMSX3("Z02_SEQUEN")[1]) //ALTER: B1_COD to B1_CODBAR
	Private nRadio		:= 1
	Private aItens		:= {'Leitura Normal', 'Leitura Cancelamento'}
	
/*	//Input outras ações
	Aadd(aButtons,{"Cancela Item",{||U_AOMS200D()},"Cancela Item separadamente","Cancela Item",{||.T.}})			
*/	
	
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
	
	oDlgSep 	:= MSDialog():New(aSizeAuto[7], 020, 550, 1200,"Conferencia de Carregamento",,,.F.,,,,,,.T.,,,.T. )
	oSayCodi 	:= TSay():New( 38,010 ,{||"Carga:"} ,oDlgSep,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,060,008)
	oGetCodi 	:= TGet():New( 35,030 ,bSetGet(cCodigo),oDlgSep,060,012,"",,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","",,)
	oSayTran 	:= TSay():New( 38,100 ,{||"Transportador:"} ,oDlgSep,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,060,008)
	oGetTran 	:= TGet():New( 35,140 ,bSetGet(cTransp),oDlgSep,120,012,"",,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","",,)
	
	oSayPedi 	:= TSay():New( 57,010 ,{||"Pedido:"} ,oDlgSep,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,060,008)
	oGetPedi 	:= TGet():New( 54,030 ,bSetGet(cPedido),oDlgSep,038,012,"",,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","",,)
	oSayData 	:= TSay():New( 57,085 ,{||"Data:"} ,oDlgSep,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,065,008)
	oGetData 	:= TGet():New( 54,100 ,bSetGet(dData),oDlgSep,035,012,"",,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","",,)
	oSayHora 	:= TSay():New( 57,150 ,{||"Hora:"} ,oDlgSep,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,065,008)
	oGetHora 	:= TGet():New( 54,165 ,bSetGet(cHora),oDlgSep,20,012,"",,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","",,)
	oSayRota 	:= TSay():New( 57,220 ,{||"Rota:"} ,oDlgSep,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,060,008)
	oGetRota 	:= TGet():New( 54,235 ,bSetGet(cRota),oDlgSep,120,012,"",,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","",,)
	
	nBrwLarg 	:= (oDlgSep:nClientWidth / 2)// - 10 
	nBrwAlt 	:= (oDlgSep:nClientHeight / 2) - 52 //* .20
	oBrw1 		:= MsNewGetDados():New( 70 , 0, nBrwAlt, nBrwLarg,0,"AllwaysTrue()","AllwaysTrue()",cIniCpos,{},0,99,,,{|| .F.},oDlgSep,aHead1,aCols1)
	oBrw1:oBrowse:bdelete:= {|| oBrw1:DelLine()}
	
	oSayCBar 	:= TSay():New( nBrwAlt + 16,080 ,{||"Codigo de Barras:"} ,oDlgSep,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,060,008)
	oGetCBar 	:= TGet():New( nBrwAlt + 6,140 ,bSetGet(cCodBar),oDlgSep,120,024,"",{||U_AOMS200V()},CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","",,)
	
	oRadio := TRadMenu():New ( nBrwAlt + 10, 300,aItens,,oDlgSep,,,,,,,,100,12,,,,.T.)
	oRadio:bSetGet := {|u|Iif (PCount()==0,nRadio,nRadio:=u)}
		
	//oBtConf 	:= TButton():New( nBrwAlt + 6 , nBrwLarg - 150,"Confirmar"	,oDlgSep,{|| U_AOMS200O(),oDlgSep:End()},060,025,,,,.T.,,"",,,,.F. )
	//oBtCanc 	:= TButton():New( nBrwAlt + 6 , nBrwLarg - 080,"Cancelar" 	,oDlgSep,{|| U_AOMS200E(),oDlgSep:End()},060,025,,,,.T.,,"",,,,.F. )
		
	oGetCodi:Disable()
	oGetTran:Disable()
	oGetPedi:Disable()
	oGetData:Disable()
	oGetHora:Disable()
	oGetRota:Disable()
	
	oGetCBar:SetFocus() //IGOR (Incluido foco)
	
	//oBrw1:oBrowse:bLDblClick := {|| ""}
	 	
	//oDlgSep:Activate(,,,.T.)
	Activate MSDialog oDlgSep ON INIT (EnchoiceBar(oDlgSep,{|| oDlgSep:End()},{|| U_AOMS200E(	), oDlgSep:End()},,@aButtons,,,.F.,.T.,.F.,.T.,.F.))
	
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
	Local cOP := ""

	DbSelectArea("SC9")
	SC9->(DbSetOrder(3))//C9_FILIAL+C9_PEDIDO+C9_GRUPO+C9_PRODUTO
	SC9->(DbGoTop())
	If SC9->(DbSeek(xFilial("SC9")+DAI->DAI_PEDIDO))
	
		While SC9->(!Eof()) .AND. C9_PEDIDO == DAI->DAI_PEDIDO
	
			If SC9->(FieldPos("C9_CONFERI")) > 0 .AND. SC9->C9_CONFERI	== "S"
				cConferido := "2"
				DbSelectArea("Z02")
				Z02->(DbSetOrder(3))//Z02_FILAL+Z02_PEDIDO
				If Z02->(DbSeek(xFilial("Z02")+SC9->C9_PEDIDO)) .AND. SC2->(DbSeek(xFilial("SC2")+Z02->Z02_OP)) .AND. Z02->Z02_CARGA = "L"
				SC2->(DbSeek(xFilial("SC2")+Z02->Z02_OP))
					While Z02->Z02_PEDIDO == SC9->C9_PEDIDO
						nQuantConf := Iif(SC2->C2_PRODUTO = SC9->C9_PRODUTO,SC9->C9_QTDLIB,nQuantConf)	
					Z02->(DbSkip())	
					EndDo
				EndIf
			Else
				nQuantConf	:= 0
				cConferido := "1"
				DbSelectArea("Z02")
				Z02->(DbSetOrder(3))//Z02_FILAL+Z02_PEDIDO
				If Z02->(DbSeek(xFilial("Z02")+SC9->C9_PEDIDO))
					While Z02->(!Eof()) .AND. SC9->C9_PEDIDO = Z02->Z02_PEDIDO
					//Msgalert("Z02" + str(recno()))
					If Z02->Z02_CARGA = "L"
							DbSelectArea("SC2")
							SC2->(DbSetOrder(1))
							If SC2->(DbSeek(xFilial("SC2")+Z02->Z02_OP)) 
							//While Z02->(!Eof()) .AND. Z02->Z02_PEDIDO == SC9->C9_PEDIDO
								nQuantConf := Iif(SC2->C2_PRODUTO = SC9->C9_PRODUTO,nQuantConf+1,nQuantConf)	
							//Z02->(DbSkip())	
							//EndDo
							EndIf
					EndIf 
					   DbSelectArea("Z02")
					   DbSkip()
					EndDo	
				EndIf
			EndIf
			
			aAdd(aAux,{ SC9->C9_ITEM,;
					SC9->C9_PRODUTO,;
					SC9->C9_QTDLIB,;
					nQuantConf,;
					cConferido,;
					SC9->(recno()),;
					.F.})
			DbSelectArea("SC9")
			SC9->(DbSkip())
			//Msgalert("SC9" + str(recno()))
		EndDo
		aAux	:= aSort(aAux,,,{|x,y| x[1] < y[1]})
	EndIf
	
Return(aAux)

//----------------------------------------------------------------------------------------

User Function AOMS200V()

Local nLinPro	:= 0
Local cProduto 	:= " "
Local cEtiqueta := ""
Local aAreaSC2	:= SC2->(GetArea())
Local aAreaZ02	:= Z02->(GetArea())

Local lTodosOk	:= .T.


//cEtiqueta := cCodBar

If nRadio = 2
	If Len(Alltrim(cCodBar)) > 0
		DbSelectArea("Z02")
		Z02->(DbSetOrder(2))
		Z02->(DbGoTop())    
		If Z02->(DbSeek(xFilial("Z02")+Alltrim(cCodBar)))
			If Z02->Z02_STATUS = "P"
				//If Alltrim(Z02->Z02_CARGA) != "" .OR. Alltrim(Z02->Z02_CARGA) != "C"
				If Alltrim(Z02->Z02_CARGA) = "L"
					If Z02->Z02_PEDIDO == DAI->DAI_PEDIDO
						cEtiqueta:= Z02->Z02_OP
						DbSelectArea("SC2")
						SC2->(DbSetOrder(1))
						SC2->(DbGoTop())
							If SC2->(DbSeek(xFilial("SC2")+cEtiqueta))
								cProduto:= AllTrim(SC2->C2_PRODUTO)
								RecLock("Z02",.F.)
									Z02->Z02_CARGA 	:= "C"
									//Z02->Z02_PEDIDO	:= cPedido
								MsUnlock()
							EndIf
					Else
						msgalert("Número de série não faz parte do pedido")
					EndIf
				Else
					alert("Número de série com status liberado para leitura")
				EndIf
			Else
				alert("Ordem de produção em aberto (Número de série não apontado)")
			EndIf
		EndIf
		RestArea(aAreaSC2)
		RestArea(aAreaZ02)
		//cProduto := AllTrim(cEtiqueta)  //IGOR (Incluido AllTrim)
	Else
		Return(.T.)
	EndIf
	
	nLinPro :=	aScan(oBrw1:ACOLS,{|x| Alltrim(x[2]) == cProduto})

	If nLinPro <> 0

		oBrw1:aCols[nLinPro][nPosQtdC] 	:= oBrw1:ACOLS[nLinPro][nPosQtdC]-1

	If oBrw1:aCols[nLinPro][nPosQtdP] == oBrw1:aCols[nLinPro][nPosQtdC]
		oBrw1:aCols[nLinPro][nPosStat] := "1"

	EndIf

	oGetCBar:Refresh()
	oGetCBar:SetFocus() //IGOR (Incluido foco)
	oBrw1:Refresh()

	Else
		If Z02->Z02_CARGA = ""
			alert("Produto nao encontrado no pedido atual! " +cProduto+ "!!!")
		EndIf
	EndIf
	//oGetCBar:Refresh()
	//oGetCBar:SetFocus() //IGOR (Incluido foco)

Return(.T.)
	
Else
	If Len(Alltrim(cCodBar)) > 0
		DbSelectArea("Z02")
		Z02->(DbSetOrder(2))
		Z02->(DbGoTop())    
		If Z02->(DbSeek(xFilial("Z02")+Alltrim(cCodBar)))
			If Z02->Z02_STATUS = "P"
				If Alltrim(Z02->Z02_CARGA) = "" .OR. Alltrim(Z02->Z02_CARGA) = "C"
					cEtiqueta:= Z02->Z02_OP
					DbSelectArea("SC2")
					SC2->(DbSetOrder(1))
						If SC2->(DbSeek(xFilial("SC2")+cEtiqueta))
							cProduto:= AllTrim(SC2->C2_PRODUTO)
							RecLock("Z02",.F.)
								Z02->Z02_CARGA 	:= "L"
								Z02->Z02_PEDIDO	:= cPedido
							MsUnlock()
						EndIf
					Else
					alert("Número de série com status já lido")
				EndIf
			Else
				alert("Ordem de produção em aberto (Número de série não apontado)")
			EndIf
		EndIf
		RestArea(aAreaSC2)
		RestArea(aAreaZ02)
		//cProduto := AllTrim(cEtiqueta)  //IGOR (Incluido AllTrim)
	Else
		Return(.T.)
	EndIf

	nLinPro :=	aScan(oBrw1:ACOLS,{|x| Alltrim(x[2]) == cProduto})

	If nLinPro <> 0

		oBrw1:aCols[nLinPro][nPosQtdC] 	:= oBrw1:ACOLS[nLinPro][nPosQtdC]+1

		If oBrw1:aCols[nLinPro][nPosQtdP] == oBrw1:aCols[nLinPro][nPosQtdC]
			oBrw1:aCols[nLinPro][nPosStat] := "2"
		
			DbSelectArea("SC9") 
			For nLin := 1 To Len(oBrw1:aCols)
				If oBrw1:aCols[nLin][nPosStat] <> "2"
					lTodosOk := .F.
					Exit
				EndIf
			Next nLin
		
			If lTodosOk
				U_AOMS200O()
			EndIf
		EndIf
	
		//CONFERIDO MAIOR QUE A QUANTIDADE NO ITEM LBERADO DO PEDIDO (SC9)
		If oBrw1:aCols[nLinPro][nPosStat] == "2" .AND. oBrw1:aCols[nLinPro][nPosQtdC] > oBrw1:aCols[nLinPro][nPosQtdP]
			//oBrw1:aCols[nLinPro][nPosStat] := "3" //ALTERADO PARA NÃO AUTORIZAR LER MAIS DO QUE O PEDIDO
			Alert ("Item "+cProduto+" já conferido completamente")
		EndIf
	
		//cCodBar := Space(18)//Space(TAMSX3("Z02_SEQUEN")[1]) // ALTER
		oGetCBar:Refresh()
		oGetCBar:SetFocus() //IGOR (Incluido foco)
		oBrw1:Refresh()
		//oGetCBar:SetFocus() //IGOR (Incluido foco)
	Else
		//If Z02->Z02_CARGA = ""
			alert("Produto nao encontrado no pedido atual! " +cProduto+ "!!!")
		//EndIf
	EndIf
	//oGetCBar:Refresh()
	//oGetCBar:SetFocus() //IGOR (Incluido foco)
EndIf
Return(.T.)


User Function AOMS200O()

	Local aAreaDAI 	:= DAI->(GetArea())
	Local lTodosOk	:= .T.
			
	If SC9->(FieldPos("C9_CONFERI")) > 0 
		DbSelectArea("SC9") 
		For nLin := 1 To Len(oBrw1:aCols)
			If oBrw1:aCols[nLin][nPosStat] <> "2"
				lTodosOk := .F.
				Exit
			EndIf
		Next nLin
		
		If lTodosOk
			For nLin := 1 To Len(oBrw1:aCols)
				dbGoto(oBrw1:aCols[nLin][nPosRecn])
				RecLock("SC9",.F.)
					SC9->C9_CONFERI	:= "S"
				MsUnlock()
			Next nLin
			
			//CARGAS
			DbSelectArea("DAK")
			DAK->(DbSetOrder(1))
			DAK->(DbGoTop())    
			If DAK->(DbSeek(xFilial("DAK")+cCodigo))
				RecLock("DAK",.F.)
				DAK->DAK_BLQCAR := '2'
				MsUnlock()
			EndIf
		
			RestArea(aAreaDAI)
		EndIf
	Else
		Alert("Atualização de dicionário necessária, campo 'C9_CONFERI' não encontrado!")
	EndIf
	
	oDlgSep:End()

Return


//--------------------------------------------------------------------------------------------------------------------------------------
/*Caso seja cancelada a conferência verificar se deseja zerar as sequencias já lidas para reaproveita-las*/
User Function AOMS200E()

Local aAreaZ02 	:= Z02->(GetArea())

If MsgYesNo ('Zerar os saldos das númerações já lidas para reaproveitamento da sequencia?', 'Zerar saldos')
	DbSelectArea("Z02")
	Z02->(DbSetOrder(3))
	Z02->(DbGoTop()) 
	If Z02->(DbSeek(xFilial("Z02")+DAI->DAI_PEDIDO))
		While Z02->(!Eof()) .AND. DAI->DAI_PEDIDO = Z02->Z02_PEDIDO
			If Z02->Z02_CARGA != "C"
				RecLock("Z02",.F.)
					Z02->Z02_CARGA 	:= "C"
				MsUnlock()
			EndIf 
			DbSelectArea("Z02")
			Z02->(DbSkip())
		EndDo	
	EndIf
	RestArea(aAreaZ02)
EndIf

//oDlgSep:End()
Return