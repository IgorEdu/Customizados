#include 'protheus.ch'
#include 'parmtype.ch'
#INCLUDE 'TOPCONN.CH'
	
//Constantes
#Define STR_PULA		Chr(13)+Chr(10)
	
/*/{Protheus.doc} xUltcomp
Relatório - Ultimas Compras               
@author Igor Silva
@since 02/10/2019
@version 1.0
	@example
	u_xResumoRep()
/*/
	
User Function xResumoRep()
	Local aArea   := GetArea()
	Local oReport
	Local lEmail  := .F.
	Local cPara   := ""
	Private cPerg := ""
	
	//Cria as definições do relatório 
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Variaveis utilizadas para parametros                        ³
	//³ mv_par01		// Data de:			                        ³
	//³ mv_par02		// Data até:		                        ³
	//³ mv_par03		// Vendedor de:		                        ³
	//³ mv_par04		// Vendedor até:	                        ³
	//³ mv_par05		// Ordem:			                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		
	Pergunte("RESUMOREP",.T.) 
	oReport := fReportDef()
	
	//Será enviado por e-Mail?
	If lEmail
		oReport:nRemoteType := NO_REMOTE
		oReport:cEmail := cPara
		oReport:nDevice := 3 //1-Arquivo,2-Impressora,3-email,4-Planilha e 5-Html
		oReport:SetPreview(.F.)
		oReport:Print(.F., "", .T.)
	//Senão, mostra a tela
	Else
		oReport:PrintDialog()
	EndIf
	
	RestArea(aArea)
Return
	
/*-------------------------------------------------------------------------------*
 | Func:  fReportDef                                                             |
 | Desc:  Função que monta a definição do relatório                              |
 *-------------------------------------------------------------------------------*/
	
Static Function fReportDef()
	Local oReport
	Local oSectDad := Nil
	Local oBreak := Nil
	
	//Criação do componente de impressão
	oReport := TReport():New(	"xResumoRep",;		//Nome do Relatório
								"Resumo de faturamento dos representantes",;		//Título
								cPerg,;		//Pergunte ... Se eu defino a pergunta aqui, será impresso uma página com os parâmetros, conforme privilégio 101
								{|oReport| fRepPrint(oReport)},;		//Bloco de código que será executado na confirmação da impressão
								)		//Descrição
	oReport:SetTotalInLine(.F.)
	oReport:lParamPage := .F.
	oReport:oPage:SetPaperSize(9) //Folha A4
	oReport:SetPortrait()
	
	//Criando a seção de dados
	oSectDad := TRSection():New(	oReport,;		//Objeto TReport que a seção pertence
									"Dados",;		//Descrição da seção
									{"QRY_AUX2"})		//Tabelas utilizadas, a primeira será considerada como principal da seção
	oSectDad:SetTotalInLine(.F.)  //Define se os totalizadores serão impressos em linha ou coluna. .F.=Coluna; .T.=Linha
	
	//Colunas do relatório
	TRCell():New(oSectDad, "REPRES", "QRY_AUX2", "Codigo", /*Picture*/, 15, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "NOME", "QRY_AUX2", "Representante", /*Picture*/, 80, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "PRCVEN", "QRY_AUX2", "Valor s/ IPI", /*Picture*/, 20, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "TOTAL", "QRY_AUX2", "Valor c/ IPI", /*Picture*/, 20, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "QUANT", "QRY_AUX2", "Quantidade", /*Picture*/, 15, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
Return oReport
	
/*-------------------------------------------------------------------------------*
 | Func:  fRepPrint                                                              |
 | Desc:  Função que imprime o relatório                                         |
 *-------------------------------------------------------------------------------*/
	
Static Function fRepPrint(oReport)
	Local aArea		:= GetArea()
	Local cQryAux	:= ""
	Local cQryAux2	:= ""
	Local cQryAux3	:= ""
	Local oSectDad 	:= Nil
	Local nAtual   	:= 0
	Local nTotal   	:= 0
	Local cDtIni	:= DTOS(mv_par01)
	Local cDtFim	:= DTOS(mv_par02)
	Local cVenIni	:= mv_par03
	Local cVenFim	:= mv_par04
	Local cOrdem	:= mv_par05
	
	//Pegando as seções do relatório
	oSectDad := oReport:Section(1)
	
	//Montando consulta de dados
	cQryAux := ""
	cQryAux += "SELECT F2.F2_DOC F2DOC, F2.F2_CLIENTE CLIENTE, "				+ STR_PULA
	cQryAux += "F2.F2_LOJA LOJA, F2.F2_EMISSAO EMISSAO, F2.F2_VEND1 REPRES, "	+ STR_PULA
	cQryAux += "COALESCE(A3.A3_NOME,'') NOME,"									+ STR_PULA
	cQryAux	+= "COALESCE(D2.D2_PRCVEN,'') PRCVEN,"								+ STR_PULA
	cQryAux += "COALESCE(D2.D2_VALIPI+D2.D2_PRCVEN,'') TOTAL"					+ STR_PULA
	cQryAux += "FROM SF2010 F2"													+ STR_PULA
	cQryAux += "LEFT JOIN SA3010 A3 ON F2.F2_VEND1=A3.A3_COD"					+ STR_PULA
	cQryAux += "LEFT JOIN SD2010 D2 ON F2.F2_DOC=D2.D2_DOC"						+ STR_PULA
	cQryAux += "WHERE F2.D_E_L_E_T_ = '' AND F2.F2_EMISSAO>='20190101'" 		+ STR_PULA
	cQryAux += "AND F2.F2_EMISSAO<='20191002'"									+ STR_PULA
	
	cQryAux := ChangeQuery(cQryAux)
	
	
	//Executando consulta e setando o total da régua
	TCQuery cQryAux New Alias "QRY_AUX"
	
	
	cQryAux2 := ""
	cQryAux2 += "SELECT F2.F2_VEND1 REPRES, "										+ STR_PULA
	cQryAux2 += "COALESCE(A3.A3_NOME,'') NOME,"										+ STR_PULA
	cQryAux2 += "COALESCE(SUM(D2.D2_PRCVEN),'') PRCVEN,"							+ STR_PULA
	cQryAux2 += "COALESCE(SUM(D2.D2_VALIPI+D2.D2_PRCVEN),'') TOTAL,"					+ STR_PULA
	cQryAux2 += "COALESCE(SUM(D2.D2_QUANT),'') QUANT"								+ STR_PULA
	cQryAux2 += "FROM SF2010 F2"													+ STR_PULA
	cQryAux2 += "INNER JOIN SD2010 D2 ON F2.F2_DOC=D2.D2_DOC"						+ STR_PULA
	cQryAux2 += "INNER JOIN SA3010 A3 ON F2.F2_VEND1=A3.A3_COD"						+ STR_PULA
	cQryAux2 += "WHERE F2.D_E_L_E_T_ = '' AND F2.F2_EMISSAO>='" + cDtIni + "'" 		+ STR_PULA
	cQryAux2 += "AND F2.F2_EMISSAO<='" + cDtFim + "'"								+ STR_PULA
	cQryAux2 += "AND F2.F2_VEND1>='" +cVenIni+"' AND F2.F2_VEND1<='" +cVenFim+"'"	+ STR_PULA
	cQryAux2 += "GROUP BY F2.F2_VEND1, A3.A3_NOME"									+ STR_PULA
	cQryAux2 += "ORDER BY F2.F2_VEND1"												+ STR_PULA
	
	cQryAux2 := ChangeQuery(cQryAux2)
	
	TCQuery cQryAux2 New Alias "QRY_AUX2"
	/*
	cQryAux3 := ""
	cQryAux3 += "SELECT REPRES REPRES,SUM(PRCVEN) AS PRCVEN, SUM(TOTAL) AS TOTAL "	+ STR_PULA
	cQryAux3 += "FROM QRY_AUX2"												+ STR_PULA
	cQryAux3 += "GROUP BY REPRES"												+ STR_PULA
	
	cQryAux3 := ChangeQuery(cQryAux3)
	
	TCQuery cQryAux3 New Alias "QRY_AUX3"
	*/

/*	Count to nTotal
	oReport:SetMeter(nTotal)
*/
	//Enquanto houver dados
	oSectDad:Init()
	QRY_AUX2->(DbGoTop())
	While ! QRY_AUX2->(Eof())
		//Incrementando a régua
		nAtual++
		oReport:SetMsgPrint("Imprimindo registro "+cValToChar(nAtual)+" de "+cValToChar(nTotal)+"...")
		oReport:IncMeter()
		
		//Imprimindo a linha atual
		oSectDad:PrintLine()
		
		QRY_AUX2->(DbSkip())
	EndDo
	oSectDad:Finish()
	QRY_AUX2->(DbCloseArea())
	
	RestArea(aArea)
Return