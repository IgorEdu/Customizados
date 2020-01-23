#include 'protheus.ch'
#include 'parmtype.ch'
/*
+-----------+-----------+-------+--------------------------+------------+
¦Funçäo     ¦ BRAEST01  ¦ Autor ¦Cesar O Affonso           ¦ 06/12/2019 ¦
+-----------+-----------+-------+--------------------------+------------¦
¦Descriçäo  ¦ Registra a leitura (leitor cód de Barras) dos produtos    ¦
¦           ¦ acabados e faz o apontamento da produção                  ¦
¦           ¦ Tabela Z02 - Numeração Etiqueta Produção                  ¦
¦           ¦                                                           ¦
+-----------+-----------------------------------------------------------¦
¦ Empresa   ¦ Braslar                                                   ¦
+-----------+-----------------------------------------------------------+
*/
User Function BRAEST01()
Local aButtons := {}
Local aCores   := {}
Private aItens := {} 
Private oSay1
Private oDlg
Private oGet1
Private oGet2
Private cNumSer := Space(19)
Private _cDesc  := ""
Private nList   := 1
Private oList
Private aFields := {}
Private aStruct := {}
Private aCores 	:= {}
Private oMark    
Private cMark   := GetMark()
Private lInvert := .F.
Private cAlias  := "TAP" 
Private nQtT    := 0
Private nQtL    := 0
Private nQtAp   := 0

// Executa funcao de montagem da estrutura
//Aadd(aStruct, {"OK","C", 02 ,00, "Ok" })
//Aadd(aFields, {"OK",   ,"Ok","@!" })
//Define as cores dos itens de legenda.
aCores := {}
aAdd(aCores,{"TAP->Z02_STATUS == 'L'","BR_VERDE"  })
aAdd(aCores,{"TAP->Z02_STATUS == ' ' ","BR_AMARELO"})
aAdd(aCores,{"TAP->Z02_STATUS == 'P'","BR_VERMELHO"})

DBSelectArea("SX3")
SX3->( DBSetOrder(1) )	
SX3->( DBSeek("Z02") )	
	
While !Eof() .And. SX3->X3_ARQUIVO == "Z02"
   If AllTrim(SX3->X3_CAMPO) $ "Z02_STATUS/Z02_OP/Z02_SEQUEN/Z02_HORA/Z02_DATA"
      Aadd(aStruct, {SX3->X3_CAMPO,  SX3->X3_TIPO, SX3->X3_TAMANHO, SX3->X3_DECIMAL, AllTrim(SX3->X3_TITULO)})
      Aadd(aFields, {SX3->X3_CAMPO,, AllTrim(X3Titulo()), SX3->X3_PICTURE})
   Endif          
   SX3->(DbSkip())     
End
*/
Define MSDialog oDlg Title "APONTAMENTO DE PRODUÇÃO" From 000, 000  To 500, 1000 COLORS 0, 16777215 PIXEL
   Aadd( aButtons, {"HISTORIC", {|| Vld_Aprov(), AtuTmp(cNumSer)}, "Apontamento Prod...", "Apontamento" , {|| .T.}} )  
//    @ 000, 000 SAY oSay1 SIZE 250, 250 OF oDlg COLORS 0, 16777215 PIXEL
   @ 038, 020 SAY "Codigo" OF oDlg     SIZE 076, 010 COLORS 0, 16777215 PIXEL
   @ 045, 020 MSGET oGet1  VAR cNumSer SIZE 150, 012 OF oDlg COLORS 0, 16777215 PIXEL Valid LEtiq(cNumSer)
   //oGet1:bChange := {||LEtiq(cNumSer)}  
   @ 057, 020 MSGET oGet2 VAR _cDesc SIZE 150, 012         Of oDlg COLORS 0, 65280 PIXEL
   @ 090, 020 Say "Total de Etiquetas....:"      + Str(nQtT,4)       Of oDlg Size 085, 010 COLORS 0, 16777215 PIXEL
   @ 100, 020 Say "Etiq. Lidas................:" + Str(nQtL,4)       Of oDlg Size 085, 010 COLORS 0, 16777215 PIXEL   
   @ 110, 020 Say "Etiq. não Lidas.........:"    + Str(nQtT-nQtL-nQtAp,4) Of oDlg Size 085, 010 COLORS 0, 16777215 PIXEL   
   @ 120, 020 Say "Etiq. Apontadas.......:"      + Str(nQtAp,4)      Of oDlg Size 085, 010 COLORS 0, 16777215 PIXEL   
   @ 130, 020 Say "Etiq. não Apontadas:"         + Str(nQtT-nQtAp,4) Of oDlg Size 085, 010 COLORS 0, 16777215 PIXEL  
   AtuTmp(cNumSer)
   oMark := MsSelect():New(cAlias,,"",aFields,@lInvert,@cMark,{040, 180, 220, 500},,, oDlg,, aCores)

Activate MSDialog oDlg ON INIT (EnchoiceBar(oDlg,{||lOk:=.T., oDlg:End()},{||oDlg:End()},,@aButtons,,,.F.,.T.,.F.,.T.,.F.))
Return(Nil)

Static Function LEtiq(cNumSer)
DbSelectArea("Z02")
Z02->(DbSetOrder(2))
If !dbSeek(xFilial("Z02") + Alltrim(cNumSer)) .And. !Empty(cNumSer)
   MsgAlert("Etiqueta não Encontrada!...")
   oGet1:Refresh() 
   oGet1:SetFocus()
   Return  
  Elseif Empty(Alltrim(cNumSer))	
   _cDesc := ""
   oGet1:Refresh() 
   oGet1:SetFocus()
   Return
  Elseif Z02->Z02_STATUS == "L"
   MsgAlert("Etiqueta já Lida!...")
   cCod   := Posicione("SC2",1,xFILIAL("SC2")+Z02->Z02_OP,"C2_PRODUTO")	
   _cDesc := cNumSer + " - " + Posicione("SB1",1,xFILIAL("SB1")+cCod,"B1_DESC")
   AtuTmp(cNumSer)
   oGet1:Refresh() 
   oGet1:SetFocus()
   Return 
  Elseif Z02->Z02_STATUS == "P"
   MsgAlert("Produção já Apontada!...")
   cCod   := Posicione("SC2",1,xFILIAL("SC2")+Z02->Z02_OP,"C2_PRODUTO")	
   _cDesc := cNumSer + " - " + Posicione("SB1",1,xFILIAL("SB1")+cCod,"B1_DESC")
   AtuTmp(cNumSer)
   oGet1:Refresh() 
   oGet1:SetFocus()
   Return     
Endif

RecLock("Z02",.F.) 
  Z02->Z02_STATUS := "L"
  Z02->Z02_HORA   := Time()
  Z02->Z02_DATA   := DdataBase
MsUnlock()

cCod   := Posicione("SC2",1,xFILIAL("SC2")+Z02->Z02_OP,"C2_PRODUTO")	
_cDesc := cNumSer + " - " + Posicione("SB1",1,xFILIAL("SB1")+cCod,"B1_DESC")
AtuTmp(cNumSer)

If nQtT = nQtL + nQtAp//Caso tenha lido todas as etiquetas fazer apontamento
   ApProd(.T.)
   AtuTmp(cNumSer)
Endif   
oGet1:Refresh() 
oGet1:SetFocus()

Return()


/*
+-----------------------------------------------------------------+
| Cria Temporario Carrega ou Atualiza os Dados pois foi alterado  |
| nRegs := Retorna a quantidade de registros                      |
+-----------------------------------------------------------------+
*/
Static Function AtuTmp(cNumSer)
Local _cOP  := "" 
Local _cSeq := "" 
nQtT    := 0
nQtL    := 0
nQtAp   := 0
If Select("TAP") > 0
   TAP->(DbCloseArea())
Endif

FErase("TAP.DBF")  //Para limpar os dados
cTemp := CriaTrab(aStruct, .T.)
DBUseArea(.T., __LocalDrive, cTemp, cAlias)
DBSelectArea("TAP")	
IndRegua("TAP", cTemp, "Z02_OP+Z02_SEQUEN",,,)

DbSelectArea("Z02")
Z02->(DbSetOrder(2))	
If !DbSeek(xFilial("Z02") + Alltrim(cNumSer)) .And. !Empty(cNumSer)
   MsgAlert("Etiqueta não Encontrada!...")
   Return  
  Elseif Empty(cNumSer)  
   Return 
Endif
_cOP  := Z02->Z02_OP
_cSeq := Z02->Z02_SEQUEN

Z02->(DbSetOrder(1))
DbSeek(xFilial("Z02") + _cOP)

While Z02->(!Eof()) .And. Z02->Z02_OP == Alltrim(_cOP)
   nQtL  := Iif(Z02->Z02_STATUS == "L", nQtL+1,nQtL)
   nQtAp := Iif(Z02->Z02_STATUS == "P",nQtAp+1,nQtAp)
   DBSelectArea("TAP")			    		
   RecLock("TAP", .T.)		
    //TAP->OK         := ''        	
    TAP->Z02_OP     := Z02->Z02_OP
    TAP->Z02_SEQUEN := Z02->Z02_SEQUEN 
    TAP->Z02_HORA   := Z02->Z02_HORA
    TAP->Z02_DATA   := Z02->Z02_DATA
    TAP->Z02_STATUS := Z02->Z02_STATUS    	   
   TAP->( MsUnlock() )							      	
   DBSelectArea("Z02")
   Z02->(DbSkip())
   nQtT++
End

@cNumSer:= Space(19)
oGet1:Refresh() 

DBSelectArea("TAP")
DbSeek(_cOP + _cSeq)
oMark:oBrowse:Refresh()
Return()

/*
+-----------------------------------------------------------------+
| Valida a senha para fazer os apontamentos                       |
| Parâmetro -> BR_APPROD                                          |
+-----------------------------------------------------------------+
*/
Static Function Vld_Aprov()
Local oDlg1
Local oBt1
Private cSAprov := Space(10) 
Private cAprov  := SuperGetMV("BR_APPROD",.T.,"1234")
DbSelectArea("Z02")
Z02->(DbSetOrder(2))
DbSeek(xFilial("Z02") + cNumSer)

Define MSDialog oDlg1 Title "Apontar a Produção" From 000, 000  To 185, 500 COLORS 0, 16777215 PIXEL
   @ 010, 020 Say "Senha para Validar o Apontamento da Ord. de Prod. Nr.: " + Z02->Z02_OP Of oDlg1 SIZE 250, 010 COLORS 0, 16777215 PIXEL
   @ 020, 020 Say "Digite a Senha: "  Of oDlg1 SIZE 150, 010 COLORS 0, 16777215 PIXEL
   @ 030, 020 MsGet cSAprov  PASSWORD SIZE 70, 012   Of oDlg1 COLORS 0, 16777215 PIXEL 
   oBt1 := TButton():New( 75, 205, "Ok",oDlg1,{||ApProd(.F.,cSAprov),oDlg1:End()},30,12,,,.F.,.T.,.F.,,.F.,,,.F. )  
Activate MSDialog oDlg1 Centered
Return

/*
+-----------------------------------------------------------------+
| Executa o apontamento parcial ou total de todas as etiquetas    |
| lidas até o momento                                             |
+-----------------------------------------------------------------+
*/
Static Function ApProd(lColet,cSAprov)
Local _cOP    := ""
Local _cItem  := ""
Local _cC2seq := ""
Local cCod    := ""
Local aVetInc := {}
Local lMsErroAuto := .F.
Default lColet  := .F.
Default cSAprov := ""
Default cAprov  := ""

If Alltrim(cSAprov) != Alltrim(cAprov) .And. !lColet
   MsgAlert("Senha não Confere!...")
   Return 
Endif
DbSelectArea("Z02")
Z02->(DbSetOrder(2))
	
If !DbSeek(xFilial("Z02") + cNumSer) .And. !Empty(cNumSer)
   MsgAlert("Etiqueta não Encontrada!...")
   Return  
  Elseif Empty(cNumSer)  
   Return 
Endif
_cOP     := Z02->Z02_OP
_cItem   := Z02->Z02_ITEM
_cC2Seq  := Z02->Z02_C2SEQ
_cStatus := Z02->Z02_STATUS

If nQtL = 0
   MsgAlert("Não existe produção a ser apontada!...")
   Return
Endif

cCod := Posicione("SC2",1,xFILIAL("SC2")+Z02->Z02_OP,"C2_PRODUTO")
If  !Empty(SC2->C2_DATRF)
   MsgAlert("Ordem de Produção Fechada!...")
   Return
Endif
aAdd(aVetInc, {"D3_FILIAL"  , FWxFilial("Z02"),  Nil})
aAdd(aVetInc, {"D3_TM"      , "001" , Nil})
aAdd(aVetInc, {"D3_COD"     , cCod  , Nil})
aAdd(aVetInc, {"D3_UM"      , "UN"  , Nil})
aAdd(aVetInc, {"D3_QUANT"   , nQtL  , Nil})
aAdd(aVetInc, {"D3_OP"      , _cOP + _cItem + _cC2Seq, Nil})
aAdd(aVetInc, {"D3_PARCTOT" ,Iif(SC2->C2_QUANT > nQtL + SC2->C2_QUJE,"P","T"), NIL})
aAdd(aVetInc, {"D3_LOCAL"   , "01" , Nil})
aAdd(aVetInc, {"D3_EMISSAO" , dDataBase, Nil})
Begin Transaction
  Dbselectarea ("SD3")
  Processa({|| MSExecAuto({|x,y| MATA250(x,y)},aVetInc, 3)}, "Por Favor Aguarde...", "Executando o Apontamento da Produção...",.F.)
  If lMsErroAuto
     MostraErro()
     DisarmTransaction()
    Else
     DbSelectArea("Z02")
     Z02->(DbSetOrder(1))
     DbSeek(xFilial("Z02") + _cOP) 
     While Z02->(!Eof()) .And. Z02->Z02_OP == Alltrim(_cOP)
       If Z02->Z02_STATUS == "L" 
	      RecLock("Z02",.F.) 
	         Z02->Z02_STATUS := 'P'
	         Z02->Z02_APNTD  := 'SIM'
          MsUnlock()	
       Endif
       Z02->(DbSkip())
     End    		    	
  EndIf
End Transaction	
Return