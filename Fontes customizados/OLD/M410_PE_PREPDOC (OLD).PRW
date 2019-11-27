#include 'protheus.ch'
#include 'parmtype.ch'
#Include "TopConn.ch"
#INCLUDE "TBICONN.CH"

#Define STR_PULA		Chr(13)+Chr(10)

/* 
Descrição:
Ponto de entrada para validação.
Executado antes da rotina de geração de NF's (MA410PVNFS()).
VALIDA SE EXISTE UMA LIBERACAO DE CREDITO PARA O DIA ATUAL
CASO NAO EXISTA, VERIFICA SE EXISTEM TITULOS VENCIDOS CONSIDERANDO D + BS_DATRASO
SE EXISTIR, APRESENTA POSICAO DO CLIENTE E NAO LIBERA EMISSAO DA NF ATEH QUE SEJA FEITA UMA LIBERACAO DE CREDITO PARA O DIA.

CORRIGIDO BLOQUEIO DE RA E NCC
*/

User function M410PVNF()

Local lRet			:= .T.
Local aRetAnaCred	:= {}
Local lAvalCred		:= .F.
Local aTitVenc		:= {}
Local nTotal		:= 0




Private lMsErroAuto     := .F.		//Variaveis incluidas

Private nDAtraso	:= GetNewPar("BS_DATRASO",0)


//Validacoes do Usuario.
DbSelectArea("SC6")
SC6->(DbSetOrder(1)) //C6_FILIAL+C6_NUM+C6_ITEM+C6_PRODUTO
SC6->(DbGoTop())
If SC6->(DbSeek(xFilial("SC6")+	SC5->C5_NUM))
	While !SC6->(Eof()) .AND. SC5->C5_NUM == SC6->C6_NUM
		nTotal += SC6->C6_VALOR
		SC6->(DbSkip())
	End
EndIf

aRetAnaCred		:= U_AnaCred(SC5->C5_CLIENTE,SC5->C5_LOJACLI,nTotal)
//ANALISA LIBERACAO DE CREDITO
DbSelectArea("SC9")
SC9->(DbSetOrder(2)) //C9_FILIAL+C9_CLIENTE+C9_LOJA+C9_PEDIDO+C9_ITEM
SC9->(DbGoTop())
If SC9->(DbSeek(xFilial("SC9")+	SC5->C5_CLIENTE + SC5->C5_LOJACLI + SC5->C5_NUM))

	While !SC9->(Eof()) .AND. SC5->C5_CLIENTE + SC5->C5_LOJACLI + SC5->C5_NUM == SC9->C9_CLIENTE + SC9->C9_LOJA + SC9->C9_PEDIDO
	
		If SC9->C9_DATALIB == dDatabase .AND. SC9->C9_BLCRED != '01'
			lAvalCred	:= .T.
			Exit
		EndIf
		
		SC9->(DbSkip())
	End
		
EndIf

//NAO EXISTE AVALIACAO DE CREDITO PARA O DIA ATUAL
If !lAvalCred
	DbSelectArea("SE1")
	SE1->(DbSetOrder(2)) //E1_FILIAL+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
	SE1->(DbGoTop())
	If SE1->(DbSeek(xFilial("SE1")+	SC5->C5_CLIENTE + SC5->C5_LOJACLI))
		While !SE1->(Eof()) .AND. SC5->C5_CLIENTE + SC5->C5_LOJACLI == SE1->E1_CLIENTE + SE1->E1_LOJA
			If ROUND(SE1->E1_SALDO,2) > 0 .AND. SE1->E1_VENCREA+nDAtraso <= dDatabase .AND. SE1->E1_TIPO != 'RA' .AND. SE1->E1_TIPO != 'NCC'
				AADD(aTitVenc,{E1_PREFIXO,E1_NUM,E1_PARCELA,E1_TIPO})
			EndIf
			SE1->(DbSkip())
		End
	EndIf
	If Len(aTitVenc)>0
		Alert("Avaliação de crédito necessária! Existe(m) " + cValToChar(Len(aTitVenc)) + " titulo(s) próximo(s) do vencimento ou vencidos!")
		DbSelectArea("SA1")
		DbSetOrder(1)
		If SA1->(DbSeek(xFilial("SA1") + SC5->C5_CLIENTE + SC5->C5_LOJACLI))
			Finc010(2)
		EndIf
		lRet	:= .F.
	EndIf
EndIf




Return lRet
	
*-----------------------------------------------------------------------------------------
User Function AnaCred(cCliente,cLoja,nValor)
* Retorna dados sobre o credito disponivel do cliente:
* aRetorno[1]=Logico, se ha credito disponivel para o valor informado
* aRetorno[2]=Caracter 2 - Codigo do bloqueio, onde:
*-----------------------------------------------------------------------------------------
local cBlCred:='',aEmpenho:={},nVlrDisp

/* Chamada de MaAvalCred:

 01 - Bloqueio de Credito por Valor
 04 - Vencto do Limite de Credito
 05 - Bloqueio de Credito por Estorno
 06 - Bloqueio de Credito por Risco
 09 - Rejeicao de Credito

Parametros:
----------------------------------------------------------
ExpC1: Codigo do Cliente
ExpC2: Loja do Cliente
ExpN3: Valor a ser avaliado
ExpN4: Moeda do valor a ser avaliado
ExpL5: Considera acumulados de Pedido de Venda do SA1
ExpC6: Codigo do Bloqueio.
ExpC7: aEmpenho
ExpN8: Valor a ser adicionado ao limite de credito
----------------------------------------------------------
Retorna: Logico - Credito (Sim/Nao)
*/
//Alert("Analisar credito!")
lTemCred:=MaAvalCred(cCliente,cLoja,nValor,nMoeda:=1,lPedido:=.t.,@cBlCred,@aEmpenho,@nVlrDisp)
aRetorno:={lTemCred,cBlCred}

return aRetorno