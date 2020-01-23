#include 'protheus.ch'
#include 'parmtype.ch'
#Include "TopConn.ch"
#INCLUDE "TBICONN.CH"

#Define STR_PULA		Chr(13)+Chr(10)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Autor ³ Igor Silva                                  ³ Data ³ 25/07/19 ³±±
±±ÃÄ0ÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Gerar parcela de ICMS-ST separada com prazo de 15 dias para ³±±
±±³          ³clientes que sejam solidarios.                              ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function M460FIM()

LOCAL aVetInc := {}
Local aArea := GetArea()

Local aAreaSF2 := SF2->(GetArea())
Local aAreaSD2 := SD2->(GetArea())
Local aAreaSC5 := SC5->(GetArea())
Local aAreaSE1 := SE1->(GetArea())
Local aAreaSA1 := SA1->(GetArea())

Local cPedido  := ''
Local cSerie := ''
Local cDoc := ''
Local nParc1 := ''
Local nSaldo := ''
Local nICMSST := ''
Local cCliente := ''
Local cLoja := ''
Local cNatureza := ''

Local _xMenCom	:= SF2->F2_XMENCOM

Private lMsErroAuto     := .F.


//Verifica se atende as condições para geração de nova parcela com ICMS-ST

DbSelectArea("SF2")
DbSelectArea("SE1")
SF2->(DbSetorder(1))
//If SF2->F2_TIPOCLI =='S'
If SF2->F2_ICMSRET > 0 //.AND. !Empty(SF2->F2_DUPL)

IF Aviso("Separa ICMS-ST","Título contém ICMS-ST. Deseja gerar parcela com valor de ICMS-ST separada?",{"SIM","NAO"}) == 1


//Procura o pedido
DbSelectArea("SD2")
SD2->(DbSetorder(3))
If SD2->(DbSeek(SF2->(F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA)))
	cPedido := SD2->D2_PEDIDO
	cSerie := SD2->D2_SERIE
	cDoc := SD2->D2_DOC
	nICMSST := SF2->F2_ICMSRET
	cCliente := SF2->F2_CLIENTE
	cLoja := SF2->F2_LOJA
	cNome := SA1->A1_NREDUZ
	cNatureza := SA1->A1_NATUREZ
Endif          
     
//Se tiver pedido
If !Empty(cPedido)
	DbSelectArea("SC5")
	SC5->(DbSetorder(1))
Endif     

//Filtra títulos dessa nota
	cSql := "SELECT R_E_C_N_O_ AS REC, E1_VALOR AS VALOR FROM "+RetSqlName("SE1")
    cSql += " WHERE E1_FILIAL = '"+xFilial("SE1")+"' AND D_E_L_E_T_<>'*' "
    cSql += " AND E1_PREFIXO = '"+SF2->F2_SERIE+"' AND E1_NUM = '"+SF2->F2_DOC+"' "
    cSql += " AND E1_TIPO = 'NF' "
    TcQuery ChangeQuery(cSql) New Alias "QRY"

/*
    //Se tiver dado, altera o valor da parcela
        SE1->(DbGoTo(QRY->REC))
        Alert(QRY->REC)
        Alert(QRY->VALOR)
        nParc1 := QRY->VALOR 
        nSaldo := nParc1 - nICMSST
        If !SE1->(EoF())
            aVetAlt := {}
            aAdd(aVetAlt, {"E1_FILIAL",  FWxFilial("SE1"),  Nil})
            aAdd(aVetAlt, {"E1_VALOR",   nSaldo,            Nil}) 
            aAdd(aVetAlt, {"E1_HIST",    'RETIRADO VALOR DE ICMS-ST',             Nil})
*/

//Prepara o array para o execauto
aVetInc := {}
aAdd(aVetInc, {"E1_FILIAL",  FWxFilial("SE1"),  Nil})
aAdd(aVetInc, {"E1_NUM",     cDoc,           Nil})
aAdd(aVetInc, {"E1_PREFIXO", cSerie,          Nil})
aAdd(aVetInc, {"E1_PARCELA", 'ST',          Nil})
aAdd(aVetInc, {"E1_TIPO",    'NF',             Nil})
aAdd(aVetInc, {"E1_NATUREZ", cNatureza,         Nil})
aAdd(aVetInc, {"E1_CLIENTE", cCliente,          Nil})
aAdd(aVetInc, {"E1_LOJA",    cLoja,             Nil})
aAdd(aVetInc, {"E1_NOMCLI",  cNome,           Nil})
aAdd(aVetInc, {"E1_EMISSAO", dDataBase,          Nil})
aAdd(aVetInc, {"E1_VENCTO",  dDataBase+15,           Nil})
aAdd(aVetInc, {"E1_VENCREA", dDataBase+16,         Nil})
aAdd(aVetInc, {"E1_VALOR",   nICMSST,            Nil}) 
//aAdd(aVetInc, {"E1_VALJUR",  '',         Nil})
//aAdd(aVetInc, {"E1_PORCJUR", '',        Nil})
aAdd(aVetInc, {"E1_HIST",    'VALOR ICMS-ST SEPARADO',             Nil})
aAdd(aVetInc, {"E1_MOEDA",   1,                 Nil})
aAdd(aVetInc, {"E1_PEDIDO",   cPedido,                 Nil})
aAdd(aVetInc, {"E1_SERIE",   cSerie,                 Nil})
aAdd(aVetInc, {"E1_ORIGEM",   'MATA460',                 Nil})
aAdd(aVetInc, {"E1_SDOC",   'A',                 Nil})

 
//Inicia o controle de transação
Begin Transaction
    //Chama a rotina automática
    lMsErroAuto := .F.
    MSExecAuto({|x,y| FINA040(x,y)}, aVetInc, 3)
     
    //Se houve erro, mostra o erro ao usuário e desarma a transação
    If lMsErroAuto
        MostraErro()
        DisarmTransaction()
    EndIf
//Finaliza a transação
End Transaction



//Se tiver dado, altera o valor da parcela
	SE1->(DbGoTo(QRY->REC)) 
	If !SE1->(EoF())
		RecLock("SE1",.F.) //Retira valor de ICMS-ST da primeira parcela
			SE1->E1_FILIAL := xFilial("SE1")
			SE1->E1_VALOR := QRY->VALOR - nICMSST
			SE1->E1_HIST := 'RETIRADO VALOR DE ICMS-ST'
            SE1->E1_SALDO := QRY->VALOR - nICMSST
            SE1->E1_BASCOM1 := QRY->VALOR - nICMSST
            SE1->E1_VLCRUZ := QRY->VALOR - nICMSST
		MsUnlock()
	EndIf

	QRY->(DbCloseArea())

    RestArea(aAreaSF2)
    RestArea(aAreaSD2)
    RestArea(aAreaSC5)
    RestArea(aAreaSE1)
    RestArea(aAreaSA1)
EndIf
EndIf


/**********************************************************
	Final da emissoa Nota fiscal
	Programador: Mario Araujo Oliveira - INNOVATE 09/01/19
	
	GERA BOLETO APÓS GERAÇÃO DE DOCUMENTO DE SAIDA
**********************************************************/


IF ExistBlock("IMPBOL2A") .AND. !Empty(SF2->F2_DUPL)
	IF Aviso("M460FIM","Deseja gerar o Boleto?",{"SIM","NAO"}) == 1
		Processa({|| U_IMPBOL2A()},"Aguarde .. ","Gerando Boletos..")
	EndIF 
EndIF 	
RestArea(aArea)
Retur .T.