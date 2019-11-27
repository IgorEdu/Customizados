#include 'protheus.ch'
#include 'parmtype.ch'
//--------------------------------------------------------------
/*/{Protheus.doc} MyFunction
Description

@param xParam Parameter Description
@return xRet Return Description
@author  -
@since 21/08/2019
/*/
//--------------------------------------------------------------
User Function APNT_ETQ()
 
Private oSay1
Private oDlg
Private oGet1
Private oGet2
Private oGet3
Private oGet4
Private oGet5
Private oGet6
Private oGet7
Private oGet8
Private _cNumSer := SPACE(18)
Private _cNumSer2 := SPACE(18)
Private _cNumSer3 := SPACE(18)
Private _cNumSer4 := SPACE(18)
Private _cDesc := "TESTE"
Private _cDesc2 := "TESTE 2"
Private _cDesc3 := "TEST3"
Private _cDesc4 := "TESTE 4"


chkfile("Z02")

  DEFINE MSDIALOG oDlg TITLE "APONTAMENTO DE PRODUÇÃO" FROM 000, 000  TO 500, 500 COLORS 0, 16777215 PIXEL

    @ 000, 000 SAY oSay1 SIZE 250, 250 OF oDlg COLORS 0, 16777215 PIXEL
    @ 018, 050 SAY "Item 1" OF oSay1 PICTURE "@!" SIZE 076, 010 COLORS 0, 16777215 PIXEL
    @ 025, 050 MSGET oGet1 VAR _cNumSer SIZE 150, 012 OF oSay1 COLORS 0, 16777215 PIXEL VALID PRDZ_ETQ(_cNumSer, oGet1, oDlg)
    @ 037, 050 MSGET oGet2 VAR _cDesc SIZE 150, 012 OF oDlg COLORS 0, 16777215 PIXEL WHEN .F.
    @ 055, 050 SAY "Item 2" OF oSay1 PICTURE "@!" SIZE 076, 010 COLORS 0, 16777215 PIXEL
    @ 062, 050 MSGET oGet3 VAR _cNumSer2 SIZE 150, 012 OF oDlg COLORS 0, 16777215 PIXEL VALID PRDZ_ETQ(_cNumSer2, oGet3, oDlg)
    @ 075, 050 MSGET oGet4 VAR _cDesc2 SIZE 150, 012 OF oDlg COLORS 0, 16777215 PIXEL WHEN .F.
/*    @ 093, 050 SAY "Item 3" OF oSay1 PICTURE "@!" SIZE 076, 010 COLORS 0, 16777215 PIXEL
    @ 100, 050 MSGET oGet5 VAR _cNumSer3 SIZE 150, 012 OF oDlg COLORS 0, 16777215 PIXEL VALID PRDZ_ETQ(_cNumSer3, oGet5, oDlg)
    @ 112, 050 MSGET oGet6 VAR _cDesc3 SIZE 150, 012 OF oDlg COLORS 0, 16777215 PIXEL WHEN .F.
    @ 130, 050 SAY "Item 4" OF oSay1 PICTURE "@!" SIZE 076, 010 COLORS 0, 16777215 PIXEL
    @ 137, 050 MSGET oGet7 VAR _cNumSer4 SIZE 150, 012 OF oDlg COLORS 0, 16777215 PIXEL VALID PRDZ_ETQ(_cNumSer4, oGet7, oDlg)
    @ 150, 050 MSGET oGet8 VAR _cDesc4 SIZE 150, 012 OF oDlg COLORS 0, 16777215 PIXEL WHEN .F.
*/
    
    oGet1:SetFocus()

  ACTIVATE MSDIALOG oDlg CENTERED

Return(Nil)

//------------------------------------------------------------------------------------

Static Function PRDZ_ETQ(cOrdApt,oGet1, oGet3, oGet5, oGet7, oDlg)

Local aArea := GetArea()
//Local aAreaZ02 := Z02->(GetArea())

Local _cOP := ''
Local cCod := ''

Local aVetInc := {}
Local dData := dDataBase
Local nOpc := 3
Local _cItem :=''
Local _cC2seq := ''
Local _cAPNTD := ''

Private lMsErroAuto     := .F.

	If Len(Alltrim(_cNumSer)) == 18
		//Alert ("Deu certo")
		cOrdApt:= _cNumSer
		//Alert (_cNumSer)
		
		DbSelectArea("Z02")
		//ChkFile("Z02")
		Z02->(DbSetOrder(2))
		Z02->(DbGoTop())
		Z02->(dbSeek(xFilial("SC2") + _cNumSer))
		_cOP := Z02->Z02_OP
		//Alert(_cOP)
		_cItem := Z02->Z02_ITEM
		//Alert (_cItem)
		_cC2seq := Z02->Z02_C2SEQ
		//Alert (_cC2seq)
		_cAPNTD := Z02->Z02_APNTD
		//Alert (_cAPNTD)

		If _cAPNTD != "SIM"
			DbSelectArea("SC2")
			SC2->(DbSetOrder(1))
			SC2->(DbGoTop())
			If SC2->(DbSeek(xFilial("SC2") + _cOP ))
				cCod := SC2 -> C2_PRODUTO
				//Alert (cCod)
			EndIf
		
			DbSelectArea("SB1")
			SB1->(DbSetOrder(1))
			SB1->(DbGoTop())
			If SB1->(DbSeek(xFilial("SB1") + cCod ))
				_cDesc := SB1 -> B1_DESC
				//Alert (_cDesc)
			EndIf
			
			//Prepara o array para o execauto
			If SC2->C2_QUANT - SC2->C2_QUJE == 1
				aVetInc := {}
				aAdd(aVetInc, {"D3_FILIAL",  FWxFilial("SC2"),  Nil})
				aAdd(aVetInc, {"D3_TM", "001", Nil})
				aAdd(aVetInc, {"D3_COD", cCod, Nil})
				aAdd(aVetInc, {"D3_UM", "UN", Nil})
				aAdd(aVetInc, {"D3_QUANT", 1, Nil})
				aAdd(aVetInc, {"D3_OP", _cOP+_cItem+_cC2seq, Nil})
				aAdd(aVetInc, {"D3_PARCTOT" , "T"                  , NIL})
				aAdd(aVetInc, {"D3_LOCAL", "01", Nil})
				aAdd(aVetInc, {"D3_EMISSAO", dData, Nil})
			Else
				aVetInc := {}
				aAdd(aVetInc, {"D3_FILIAL",  FWxFilial("SC2"),  Nil})
				aAdd(aVetInc, {"D3_TM", "001", Nil})
				aAdd(aVetInc, {"D3_COD", cCod, Nil})
				aAdd(aVetInc, {"D3_UM", "UN", Nil})
				aAdd(aVetInc, {"D3_QUANT", 1, Nil})
				aAdd(aVetInc, {"D3_OP", _cOP+_cItem+_cC2seq, Nil})
				aAdd(aVetInc, {"D3_PARCTOT" , "P"                  , NIL})
				aAdd(aVetInc, {"D3_LOCAL", "01", Nil})
				aAdd(aVetInc, {"D3_EMISSAO", dData, Nil})
			EndIf
			//Inicia o controle de transação
			Begin Transaction
			//Chama a rotina automática
			dbselectarea ("SD3")
			lMsErroAuto := .F.
			MsgRun("Encerramento da OP do ultimo Palete. Aguarde...","MATA250 - Encerramento de OP",{|| MSExecAuto({|x,y| MATA250(x,y)},aVetInc, 3) })
			//MsExecAuto({|x|MATA250(x)}, aVetInc, 3)
     
			//Se houve erro, mostra o erro ao usuário e desarma a transação
			If lMsErroAuto
				MostraErro()
				DisarmTransaction()
			EndIf
			//Finaliza a transação
			End Transaction	
			
			RecLock("Z02",.F.) 
				Z02->Z02_APNTD := "SIM"
            MsUnlock()
		Else
			Alert ("Sequencia de etiqueta já apontada")
		EndIf
	
		_cNumSer:= SPACE(18)
		//RestArea(aAreaZ02)
	
	EndIf
	If Len(Alltrim(_cNumSer2)) == 18
		//Alert ("Deu certo")
		cOrdApt:= _cNumSer2
		//Alert (_cNumSer2)
		
		DbSelectArea("Z02")
		Z02->(DbSetOrder(2))
		//Z02->(DbGoTop())
		Z02->(dbSeek(xFilial("SC2") + cOrdApt))
		_cOP := Z02->Z02_OP
		//Alert(_cOP)
		_cItem := Z02->Z02_ITEM
		//Alert (_cItem)
		_cC2seq := Z02->Z02_C2SEQ
		//Alert (_cC2seq)
		_cAPNTD := Z02->Z02_APNTD
		//Alert (_cAPNTD)

		If _cAPNTD != "SIM"
			DbSelectArea("SC2")
			SC2->(DbSetOrder(1))
			SC2->(DbGoTop())
			If SC2->(DbSeek(xFilial("SC2") + _cOP ))
				cCod := SC2 -> C2_PRODUTO
				//Alert (cCod)
			EndIf
		
			DbSelectArea("SB1")
			SB1->(DbSetOrder(1))
			SB1->(DbGoTop())
			If SB1->(DbSeek(xFilial("SB1") + cCod ))
				_cDesc2 := SB1 -> B1_DESC
				//Alert (_cDesc)
			EndIf
			
			//Prepara o array para o execauto
			aVetInc := {}
			aAdd(aVetInc, {"D3_FILIAL",  FWxFilial("SC2"),  Nil})
			aAdd(aVetInc, {"D3_TM", "001", Nil})
			aAdd(aVetInc, {"D3_COD", cCod, Nil})
			aAdd(aVetInc, {"D3_UM", "UN", Nil})
			aAdd(aVetInc, {"D3_QUANT", 1, Nil})
			aAdd(aVetInc, {"D3_OP", _cOP+_cItem+_cC2seq, Nil})
			aAdd(aVetInc, {"D3_PARCTOT" , "P"                  , NIL})
			aAdd(aVetInc, {"D3_LOCAL", "01", Nil})
			aAdd(aVetInc, {"D3_EMISSAO", dData, Nil})
			
			//Inicia o controle de transação
			Begin Transaction
			//Chama a rotina automática
			dbselectarea ("SD3")
			lMsErroAuto := .F.
			MsgRun("Encerramento da OP do ultimo Palete. Aguarde...","MATA250 - Encerramento de OP",{|| MSExecAuto({|x,y| MATA250(x,y)},aVetInc, 3) })
			//MsExecAuto({|x|MATA250(x)}, aVetInc, 3)
     
			//Se houve erro, mostra o erro ao usuário e desarma a transação
			If lMsErroAuto
				MostraErro()
				DisarmTransaction()
			EndIf
			//Finaliza a transação
			End Transaction	
			
			RecLock("Z02",.F.) 
				Z02->Z02_APNTD := "SIM"
				//Z02->Z02_
            MsUnlock()
		Else
			Alert ("Sequencia de etiqueta já apontada")
		EndIf

		_cNumSer2:= SPACE(18)
		//RestArea(aAreaZ02)
	
	EndIf
		/*If Len(Alltrim(_cNumSer3)) == 18
		Alert ("Deu certo")
		cOrdApt:= _cNumSer3
		Alert (cOrdApt)
		//_cNumSer3:= SPACE(18)
	EndIf
	If Len(Alltrim(_cNumSer4)) == 18
		Alert ("Deu certo")
		cOrdApt:= _cNumSer4
		Alert (cOrdApt)
		//_cNumSer4:= SPACE(18)
	EndIf
*/
	//oDlg:Refresh()
	//oGet1:Refresh()

RestArea (aArea)

Return (.T., oGet3, oGet5, oGet7, oDlg)