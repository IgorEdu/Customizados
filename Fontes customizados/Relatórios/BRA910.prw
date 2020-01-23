#INCLUDE "MATR910.CH"
#INCLUDE "PROTHEUS.CH"
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � BRA910  � Autor � C�sar O Afonso - Vamilly      �30/12/2019���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Kardex fisico - financeiro                                 ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   ���
�������������������������������������������������������������������������Ĵ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User Function BRA910()
Local oReport

//������������������������������������������������������������������������Ŀ
//�Interface de impressao                                                  �
//��������������������������������������������������������������������������
oReport:= ReportDef()
oReport:PrintDialog()

Return
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �ReportDef � Autor �Nereu Humberto Junior  � Data �11.07.2006���
�������������������������������������������������������������������������Ĵ��
���Descri��o �A funcao estatica ReportDef devera ser criada para todos os ���
���          �relatorios que poderao ser agendados pelo usuario.          ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �ExpO1: Objeto do relatorio                                  ���
�������������������������������������������������������������������������Ĵ��
���Parametros�Nenhum                                                      ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���   DATA   � Programador   �Manutencao efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���          �               �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function ReportDef()

Local oReport 
Local oSection1
Local oSection2
Local oSection3
Local aOrdem    := {}
Local aSB1Cod   := {}
Local aSB1Ite   := {}
Local aTabelas	:= {"SB2"}
Local cPicB2Tot := PesqPict("SB2","B2_VATU1" ,18)
Local cTamB2Tot := TamSX3('B2_VATU1')[1]
Local cPicB2Qt  := PesqPict("SB2","B2_QATU" ,18)
Local cTamB2Qt  := TamSX3('B2_QATU')[1]
Local cPicB2Cust:= PesqPict("SB2","B2_CM1",18)
Local cTamB2Cust:= TamSX3('B2_CM1')[1]
Local cPicD1Qt  := PesqPict("SD1","D1_QUANT" ,18)
Local cTamD1Qt  := TamSX3('D1_QUANT')[1]
Local cPicD1Cust:= PesqPict("SD1","D1_CUSTO",18)
Local cTamD1Cust:= TamSX3('D1_CUSTO')[1]
Local cPicD2Qt  := PesqPict("SD2","D2_QUANT" ,18)
Local cTamD2Qt  := TamSX3('D2_QUANT')[1]
LOCAL cPicD2Cust:= PesqPict("SD2","D2_CUSTO1",18)
Local cTamD2Cust:= TamSX3('D2_CUSTO1')[1]
Local lVEIC 	:= UPPER(GETMV("MV_VEICULO"))=="S"
Local nTamSX1 	:= Len(SX1->X1_GRUPO)
Local cTamD1CF  := TamSX3('D1_CF')[1]
Local nTamData 	:= IIF(__SetCentury(),10,8)
//��������������������������������������������������������������Ŀ
//� Verifica se utiliza custo unificado por Empresa/Filial       �
//����������������������������������������������������������������
Local lCusUnif := A330CusFil()

//������������������������������������������������������������������������Ŀ
//�Criacao do componente de impressao                                      �
//�                                                                        �
//�TReport():New                                                           �
//�ExpC1 : Nome do relatorio                                               �
//�ExpC2 : Titulo                                                          �
//�ExpC3 : Pergunte                                                        �
//�ExpB4 : Bloco de codigo que sera executado na confirmacao da impressao  �
//�ExpC5 : Descricao                                                       �
//�                                                                        �
//��������������������������������������������������������������������������
oReport:= TReport():New("BRA910",STR0003,"MTR910", {|oReport| ReportPrint(oReport,oSection1)},STR0001+" "+STR0002) //"Kardex Fisico-Financeiro (DIA)"##"Este programa emitir� uma rela��o com as movimenta��es"##"dos produtos Selecionados,Ordenados por Dia."
oReport:SetLandscape()    
oReport:SetTotalInLine(.F.)
oReport:lParamPage := .F.
oReport:SetDevice(4) //Direto para planilha
Pergunte("MTR910",.F.)

Aadd( aOrdem, STR0004 ) // " Codigo Produto "
Aadd( aOrdem, STR0005 ) // " Tipo do Produto"
//��������������������������������������������������������������Ŀ
//� Definicao da Secao 1 - Dados do Produto                      �
//����������������������������������������������������������������
//-- So adiciona SB1 no personalizavel quando nao compartilhado ou sem gestao de empresas
//-- Isto para habilitar o recurso de impressao em N filiais (botao Gestao de Empresas)
If FWModeAccess("SB1",1) == "E" .Or. (At("E",FWSM0Layout()) == 0 .And. At("U",FWSM0Layout()) == 0)
	oSection1 := TRSection():New(oReport,STR0062,{"SB1","SB2"},aOrdem) //"Produto (Parte 1)"
Else
	oSection1 := TRSection():New(oReport,STR0062,{"SB2"},aOrdem) //"Produto (Parte 1)"
EndIf
oSection1 :SetTotalInLine(.F.)
oSection1 :SetReadOnly()
oSection1 :SetLineStyle()

TRCell():New(oSection1,"cProduto","   ",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
oSection1:Cell("cProduto"):GetFieldInfo("B1_COD")
TRCell():New(oSection1,"B1_DESC"	,"SB1",/*Titulo*/	,/*Picture*/,30			,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,"B1_UM"		,"SB1",STR0056		,/*Picture*/,3			,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,"cTipo"		,"   ",STR0057		,"@!"		,3			,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,"B1_GRUPO"	,"SB1",STR0058		,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,"nCusMed"	,"   ",STR0059		,cPicB2Cust	,cTamB2Cust	,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,"nQtdSal"	,"   ",STR0054		,cPicB2Qt	,cTamB2Qt	,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,"nVlrSal"	,"   ",STR0055		,cPicB2Tot	,cTamB2Tot	,/*lPixel*/,/*{|| code-block de impressao }*/)
//��������������������������������������������������������������Ŀ
//� Definicao da Secao 2 - Cont. dos dados do Produto            �
//����������������������������������������������������������������
//-- So adiciona SB1 e NNR no personalizavel quando nao compartilhado ou sem gestao de empresas
//-- Isto para habilitar o recurso de impressao em N filiais (botao Gestao de Empresas)
If FWModeAccess("SB1",1) == "E" .Or. (At("E",FWSM0Layout()) == 0 .And. At("U",FWSM0Layout()) == 0)
	aAdd(aTabelas,"SB1")
EndIf
If FWModeAccess("NNR",1) == "E" .Or. (At("E",FWSM0Layout()) == 0 .And. At("U",FWSM0Layout()) == 0)
	aAdd(aTabelas,"NNR")
EndIf

oSection2 := TRSection():New(oSection1,STR0063,aTabelas) //"Produto (Parte 2)"
oSection2 :SetTotalInLine(.F.)
oSection2 :SetReadOnly()
oSection2 :SetLineStyle()

TRCell():New(oSection2,"B1_POSIPI","SB1",STR0060,/*Picture*/,/*Tamanho*/,/*lPixel*/,{|| SB1->B1_POSIPI })
TRCell():New(oSection2,"NNR_DESCRI","NNR",STR0061,/*Picture*/,/*Tamanho*/,/*lPixel*/, {|| If(lCusUnif , MV_PAR08 , Posicione("NNR",1,xFilial("NNR")+MV_PAR08,"NNR_DESCRI")) })
//��������������������������������������������������������������Ŀ
//� Definicao da Secao 3 - Movimentos                            �
//����������������������������������������������������������������
oSection3 := TRSection():New(oSection2,STR0064,{"SD1","SD2","SD3"}) //"Movimenta��o dos Produtos"
oSection3 :SetHeaderPage()
oSection3 :SetTotalInLine(.F.)
oSection3 :SetTotalText(STR0017) //"T O T A I S  :"
oSection3 :SetReadOnly()

TRCell():New(oSection3,"cProd"      ,"   ","Codigo",/*Picture*/,14,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection3,"cDescr"	    ,"   ","Descricao",/*Picture*/,30			,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection3,"cTpM"		,"   ",STR0057    ,"@!"		,3			,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection3,"cGrp"	    ,"   ",STR0058	  ,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)

TRCell():New(oSection3,"dDtMov"		,"   ",STR0038+CRLF+STR0039,/*Picture*/		,nTamData	,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection3,"cTES"		,"   ",STR0040				,"@!"			,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection3,"cCF"		,"   ",STR0041				,"@!"			,cTamD1CF	,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection3,"cDoc"		,"   ",STR0042+CRLF+STR0043	,"@!"			,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection3,"nENTQtd"	,"   ",STR0044+CRLF+STR0045	,cPicD1Qt		,cTamD1Qt	,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection3,"nENTCus"	,"   ",STR0044+CRLF+STR0046	,cPicD1Cust		,cTamD1Cust	,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection3,"nCusMov"	,"   ",STR0047+CRLF+STR0048	,cPicB2Cust		,cTamB2Cust	,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection3,"nSAIQtd"	,"   ",STR0049+CRLF+STR0045	,cPicD2Qt		,cTamD2Qt	,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection3,"nSAICus"	,"   ",STR0049+CRLF+STR0046	,cPicD2Cust		,cTamD2Cust	,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection3,"nSALDQtd"	,"   ",STR0050+CRLF+STR0045	,cPicB2Qt		,cTamB2Qt	,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection3,"nSALDCus"	,"   ",STR0050+CRLF+STR0051	,cPicB2Tot		,cTamB2Cust	,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection3,"cCCPVPJOP"	,"   ",STR0052+CRLF+STR0053	,"@!"			,26			,/*lPixel*/,/*{|| code-block de impressao }*/)

//Definir o formato Data.
oSection3:Cell("dDtMov"):SetType("D")

// Definir o formato de valores negativos (para o caso de devolucoes)
oSection3:Cell("nENTQtd"):SetNegative("PARENTHESES")
oSection3:Cell("nENTCus"):SetNegative("PARENTHESES")
oSection3:Cell("nSAIQtd"):SetNegative("PARENTHESES")
oSection3:Cell("nSAICus"):SetNegative("PARENTHESES")

TRFunction():New(oSection3:Cell("nENTQtd")	,NIL,"SUM"		,/*oBreak*/,"",cPicD1Qt		,{|| oSection3:Cell("nENTQtd"):GetValue(.T.) },.T.,.F.) 
TRFunction():New(oSection3:Cell("nENTCus")	,NIL,"SUM"		,/*oBreak*/,"",cPicD1Cust	,{|| oSection3:Cell("nENTCus"):GetValue(.T.) },.T.,.F.) 

TRFunction():New(oSection3:Cell("nSAIQtd")	,NIL,"SUM"		,/*oBreak*/,"",cPicD2Qt		,{|| oSection3:Cell("nSAIQtd"):GetValue(.T.) },.T.,.F.) 
TRFunction():New(oSection3:Cell("nSAICus")	,NIL,"SUM"		,/*oBreak*/,"",cPicD2Cust	,{|| oSection3:Cell("nSAICus"):GetValue(.T.) },.T.,.F.) 

TRFunction():New(oSection3:Cell("nSALDQtd"),NIL,"ONPRINT"	,/*oBreak*/,"",cPicB2Qt		,{|| oSection3:Cell("nSALDQtd"):GetValue(.T.) },.T.,.F.) 
TRFunction():New(oSection3:Cell("nSALDCus"),NIL,"ONPRINT"	,/*oBreak*/,"",cPicB2Tot	,{|| oSection3:Cell("nSALDCus"):GetValue(.T.) },.T.,.F.) 

oSection3:SetNoFilter("SD1")
oSection3:SetNoFilter("SD2")
oSection3:SetNoFilter("SD3")
Return(oReport)

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �ReportPrin� Autor �Nereu Humberto Junior  � Data �21.06.2006���
�������������������������������������������������������������������������Ĵ��
���Descri��o �A funcao estatica ReportDef devera ser criada para todos os ���
���          �relatorios que poderao ser agendados pelo usuario.          ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �Nenhum                                                      ���
�������������������������������������������������������������������������Ĵ��
���Parametros�ExpO1: Objeto Report do Relat�rio                           ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���   DATA   � Programador   �Manutencao efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���          �               �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function ReportPrint(oReport,oSection)

Static lIxbConTes := NIL
Local oSection1 := oReport:Section(1) 
Local oSection2 := oReport:Section(1):Section(1)  
Local oSection3 := oReport:Section(1):Section(1):Section(1)  
Local nOrdem    := oReport:Section(1):GetOrder() 
Local cSelectD1 := '', cWhereD1 := ''
Local cSelectD2 := '', cWhereD2 := ''
Local cSelectD3 := '', cWhereD3 := ''
Local cSelectVe := '', cUnion := '%%'
Local aDadosTran:={},lContinua := .F.
Local cProdAnt  := ""
Local cLocalAnt := ""
Local nCusMed   := 0
Local lFirst1   := .T.
Local aSalAtu   := { 0,0,0,0,0,0,0 }
Local aSalAlmox := {}
Local nGEntrada := 0, nGSaida :=0
Local nRec1,nRec2,nRec3,nSavRec,dCntData
Local cPicB2Cust:= PesqPict("SB2","B2_CM"+Str(mv_par11,1),18)
Local cPicD1Cust:= PesqPict("SD1","D1_CUSTO"+IIF(mv_par11 == 1 ,"",Str(mv_par11,1)),18)
Local cPicD2Cust:= PesqPict("SD2","D2_CUSTO"+Str(mv_par11,1),18)
Local cPicB2Tot := PesqPictQt("B2_VATU1",18)
Local cPicB2Qt  := PesqPictQt("B2_QATU" ,18)
Local cPicB2Qt2 := PesqPictQt("B2_QTSEGUM" ,18)
Local cCusto, lImpLivro, lImpTermos, cCond1, cCond2
Local nAcho,i,aGrupos:={},cAlias
Local cTRBSD1	:= CriaTrab(,.f.)
Local cTRBSD2	:= Subs(cTrbSD1,1,7)+"A"
Local cTRBSD3	:= Subs(cTrbSD1,1,7)+"B"
Local nInd,cIndice	:="",cCampo1,cCampo2,cCampo3,cCampo4
Local cNumSeqTr := "" , nRegTr := 0
Local cSeqIni 	:= Replicate("z",6)
Local nTotRegs  := 0
Local nTamSX1 := Len(SX1->X1_GRUPO)
// Indica se esta listando relatorio do almox. de processo
Local lLocProc:= mv_par08 == GetMvNNR('MV_LOCPROC','99')
// Indica se deve imprimir movimento invertido (almox. de processo)
Local lInverteMov :=.F.
Local lPriApropri :=.T.
//��������������������������������������������������������������Ŀ
//� Verifica se existe ponto de entrada                          �
//����������������������������������������������������������������
Local lTesNEst := .F.
//��������������������������������������������������������������Ŀ
//� Codigo do produto importado - NAO DEVE SER LISTADO           �
//����������������������������������������������������������������
Local cProdImp := GETMV("MV_PRODIMP")
//��������������������������������������������������������������Ŀ
//� Variaveis tipo Local para SIGAVEI, SIGAPEC e SIGAOFI         �
//����������������������������������������������������������������
Local cArq1    := ""
Local nInd1    := 0

Local nRecTrf1 := 0
Local nRecTrf2 := 0
Local aRecTRF  := {}

Local cWhereB1A:= " " 
Local cWhereB1B:= " " 
Local cWhereB1C:= " " 
Local cWhereB1D:= " " 

Local cQueryB1A:= " " 
Local cQueryB1B:= " " 
Local cQueryB1C:= " " 
Local cQueryB1D:= " " 
Local bBloco  := { |nV,nX| Trim(nV)+IIf(Valtype(nX)='C',"",Str(nX,1)) }
Local lVEIC := UPPER(GETMV("MV_VEICULO"))=="S"
Local lImpSMov := .F.
Local lImpS3   := .F.
Local cFilUser := oSection:GetAdvplExp()

//�����������������������������������������������������Ŀ
//� Variavel utilizada para inicar a pagina do relatorio�
//�������������������������������������������������������
Local n_pag     := mv_par12   
Local cAliasTop := ""
Local cProdMNT := GetMv("MV_PRODMNT")
Local cProdTER := GetMv("MV_PRODTER")
Local aProdsMNT := {}
Local nX
Local lWmsNew	:= SuperGetMv("MV_WMSNEW",.F.,.F.)
Local lD3Servi	:= IIF(lWmsNew,.F.,GetMV('MV_D3SERVI',.F.,'N')=='N')
Local lCabec := .T.

cProdMNT := cProdMNT + Space(15-Len(cProdMNT))
cProdTER := cProdTER  + Space(15-Len(cProdTER))

//��������������������������������������������������������������Ŀ
//� Verifica se utiliza custo unificado por Empresa/Filial       �
//����������������������������������������������������������������
Private lCusUnif := A330CusFil()
lCusUnif:=lCusUnif .And. mv_par08 == Repl("*",TamSX3("B2_LOCAL")[1])
Private lDev := .F. // Flag que indica se nota � devolu�ao (.T.) ou nao (.F.)
Private aDriver := ReadDriver()
//��������������������������������������������������������������Ŀ
//� Impressao de Termo / Livro                                   �
//����������������������������������������������������������������
Do Case
	Case mv_par15==1 ; lImpLivro:=.t. ; lImpTermos:=.f.
	Case mv_par15==2 ; lImpLivro:=.t. ; lImpTermos:=.t.
	Case mv_par15==3 ; lImpLivro:=.f. ; lImpTermos:=.t.
EndCase
oReport:SetPageNumber(n_pag)     
oReport:SetTitle(STR0013+mv_par08)
If nOrdem == 1
	oReport:SetTitle( oReport:Title()+Alltrim(STR0014+STR0004+STR0015+AllTrim(GetMv("MV_SIMB"+Ltrim(Str(mv_par11))))+")"))
Else
	oReport:SetTitle( oReport:Title()+Alltrim(STR0014+STR0005+STR0015+AllTrim(GetMv("MV_SIMB"+Ltrim(Str(mv_par11))))+")"))	
Endif	
oReport:SetTitle( oReport:Title()+AllTrim(IIf(mv_par16==1,OemToAnsi(STR0030),OemToAnsi(STR0031))))

dbSelectArea("SD1")   // Itens de Entrada
nTotRegs += LastRec()

dbSelectArea("SD2")   // Itens de Saida
nTotRegs += LastRec()

dbSelectArea("SD3")   // movimentacoes internas (producao/requisicao/devolucao)
nTotRegs += LastRec()

dbSelectArea("SB2")  // Saldos em estoque
dbSetOrder(1)
nTotRegs += LastRec()

lIxbConTes := IF(lIxbConTes == NIL,ExistBlock("MTAAVLTES"),lIxbConTes)

//������������������������������������������������������������������������Ŀ
//�Filtragem do relat�rio                                                  �
//��������������������������������������������������������������������������
MakeSqlExpr(oReport:uParam)
cAliasTop := GetNextAlias()    

//������������������������������������������������������������������������Ŀ
//�Query do relat�rio da secao 1                                           �
//��������������������������������������������������������������������������
oReport:Section(1):BeginQuery()	

//������������������������������������������������������������������������Ŀ
//�Complemento do SELECT da tabela SD1                                     �
//��������������������������������������������������������������������������
cSelectD1 := "% D1_CUSTO"
If mv_par11 > 1
	cSelectD1 += Str(mv_par11,1,0) // Coloca a Moeda do Custo
EndIf
cSelectD1 += " CUSTO,"
cSelectD1 += "%"
//������������������������������������������������������������������������Ŀ
//�Complemento do SELECT da tabela SB1 para MV_VEICULO                     �
//��������������������������������������������������������������������������	
cSelectVe := "%" 
cSelectVe += ","
IF lVEIC
	cSelectVe += "SB1.B1_CODITE B1_CODITE,"	
ENDIF
cSelectVe += "%" 
//������������������������������������������������������������������������Ŀ
//�Complemento do Where da tabela SD1                                      �
//��������������������������������������������������������������������������	
cWhereD1 := "%" 
cWhereD1 += "AND" 
If !lCusUnif
	cWhereD1 += " D1_LOCAL = '" + mv_par08 + "' AND"
EndIf
cWhereD1 += "%" 
//������������������������������������������������������������������������Ŀ
//�Complemento do SELECT da tabela SD2                                     �
//��������������������������������������������������������������������������
cSelectD2 := "% D2_CUSTO"
cSelectD2 += Str(mv_par11,1,0) // Coloca a Moeda do Custo
cSelectD2 += " CUSTO,"
    cSelectD2 += "%"	
//������������������������������������������������������������������������Ŀ
//�Complemento do Where da tabela SD1                                      �
//��������������������������������������������������������������������������	
cWhereD2 := "%" 
cWhereD2 += "AND" 
If !lCusUnif
	cWhereD2 += " D2_LOCAL = '" + mv_par08 + "' AND"
EndIf
cWhereD2 += "%"    
//������������������������������������������������������������������������Ŀ
//�Complemento do SELECT da tabelas SD3                                    �
//��������������������������������������������������������������������������
cSelectD3 := "% D3_CUSTO"
cSelectD3 += Str(mv_par11,1,0) // Coloca a Moeda do Custo
cSelectD3 +=	" CUSTO," 
cSelectD3 += "%"    
//������������������������������������������������������������������������Ŀ
//�Complemento do WHERE da tabela SD3                                      �
//��������������������������������������������������������������������������
    cWhereD3 := "%"
If SuperGetMV('MV_D3ESTOR', .F., 'N') == 'N'
	cWhereD3 += " D3_ESTORNO <> 'S' AND"
EndIf
If lD3Servi .And. IntDL()
	cWhereD3 += " ( (D3_SERVIC = '   ') OR (D3_SERVIC <> '   ' AND D3_TM <= '500')  "
	cWhereD3 += " OR  (D3_SERVIC <> '   ' AND D3_TM > '500' AND D3_LOCAL ='" + GetMvNNR('MV_CQ','98') + "') ) AND"
EndIf
If !lCusUnif .And. !lLocProc
	cWhereD3 += " D3_LOCAL = '"+mv_par08+"' AND" 
EndIf
If	!lVEIC
	cWhereD3+= " SB1.B1_COD >= '"+mv_par01+"' AND SB1.B1_COD <= '"+mv_par02+"' AND"
Else
	cWhereD3+= " SB1.B1_CODITE >= '"+mv_par01+"' AND SB1.B1_CODITE <= '"+mv_par02+"' AND"
EndIf	
cWhereD3 += " SB1.B1_FILIAL = '"+xFilial("SB1")+"' AND SB1.B1_TIPO >= '"+mv_par03+"' AND SB1.B1_TIPO <= '"+mv_par04+"' AND"
cWhereD3 += " SB1.B1_GRUPO >= '"+mv_par18+"' AND SB1.B1_GRUPO <= '"+mv_par19+"' AND SB1.B1_COD <> '"+cProdimp+"' AND "
cWhereD3 += " SB1.D_E_L_E_T_=' ' AND"
cWhereD3 += "%"	
//������������������������������������������������������������������������Ŀ
//�Complemento do WHERE da tabela SB1 para todos os selects                �
//��������������������������������������������������������������������������
cWhereB1A:= "%" 
   	cWhereB1B:= "%" 
    cWhereB1C:= "%" 
    cWhereB1D:= "%" 	

	cWhereB1A+= " AND SB1.B1_COD >= '"+mv_par01+"' AND SB1.B1_COD <= '"+mv_par02+"'"
	cWhereB1B+= " AND SB1.B1_COD = SB1EXS.B1_COD"
	cWhereB1C+= " SB1.B1_FILIAL = '"+xFilial("SB1")+"' AND SB1.B1_TIPO >= '"+mv_par03+"' AND SB1.B1_TIPO <= '"+mv_par04+"' AND"
	cWhereB1D+= " SB1EXS.B1_FILIAL = '"+xFilial("SB1")+"' AND SB1EXS.B1_COD >= '"+mv_par01+"' AND SB1EXS.B1_COD <= '"+mv_par02+"' AND SB1EXS.B1_TIPO >= '"+mv_par03+"' AND SB1EXS.B1_TIPO <= '"+mv_par04+"' AND"
cWhereB1C += " SB1.B1_GRUPO >= '"+mv_par18+"' AND SB1.B1_GRUPO <= '"+mv_par19+"' AND SB1.B1_COD <> '"+cProdimp+"' AND "
cWhereB1C += " SB1.D_E_L_E_T_=' '"
cWhereB1D += " SB1EXS.B1_GRUPO >= '"+mv_par18+"' AND SB1EXS.B1_GRUPO <= '"+mv_par19+"' AND SB1EXS.B1_COD <> '"+cProdimp+"' AND "
cWhereB1D += " SB1EXS.D_E_L_E_T_=' '"	

cQueryB1A:= Subs(cWhereB1A,2)
cQueryB1B:= Subs(cWhereB1B,2)
cQueryB1C:= Subs(cWhereB1C,2)
cQueryB1D:= Subs(cWhereB1D,2)

cWhereB1A+= "%" 
   	cWhereB1B+= "%" 
    cWhereB1C+= "%" 
    cWhereB1D+= "%" 	
 	//��������������������������������������������������������Ŀ
//� So inclui as condicoes a seguir qdo lista produtos sem �
//� movimento                                              �
//����������������������������������������������������������
cQueryD1 := " FROM "
cQueryD1 += RetSqlName("SB1") + " SB1"
cQueryD1 += (", " + RetSqlName("SD1")+ " SD1 ")
cQueryD1 += (", " + RetSqlName("SF4")+ " SF4 ")
cQueryD1 += " WHERE SB1.B1_COD = D1_COD"
cQueryD1 += (" AND D1_FILIAL = '"+xFilial("SD1")+"'")
cQueryD1 += (" AND F4_FILIAL = '" + xFilial("SF4") + "'")
cQueryD1 += (" AND SD1.D1_TES = F4_CODIGO AND F4_ESTOQUE = 'S'")
cQueryD1 += (" AND D1_DTDIGIT >= '" + DTOS(mv_par05) + "'")
cQueryD1 += (" AND D1_DTDIGIT <= '" + DTOS(mv_par06) + "'")
cQueryD1 +=  " AND D1_ORIGLAN <> 'LF'"
If !lCusUnif
	cQueryD1 += " AND D1_LOCAL = '" + mv_par08 + "'"
EndIf
//������������������������������������������������������Ŀ
//� N�o imprimir o produto MANUTENCAO (MV_PRDMNT) qdo integrado com MNT.       �
//��������������������������������������������������������
If MTR910IsMNT() 
	aProdsMNT := aClone(NGProdMNT())
	For nX := 1 To Len(aProdsMNT)
		cQueryD1 += " AND SB1.B1_COD <> '" + aProdsMNT[nX] + "'"
	Next nX
EndIf	
cQueryD1 += " AND SD1.D_E_L_E_T_=' ' AND SF4.D_E_L_E_T_=' '"

cQueryD2 := " FROM "
cQueryD2 += RetSqlName("SB1") + " SB1 , "+ RetSqlName("SD2")+ " SD2 , "+ RetSqlName("SF4")+" SF4 "
cQueryD2 += " WHERE SB1.B1_COD = D2_COD AND D2_FILIAL = '"+xFilial("SD2")+"'"
cQueryD2 += " AND F4_FILIAL = '"+xFilial("SF4")+"' AND SD2.D2_TES = F4_CODIGO AND F4_ESTOQUE = 'S'"
cQueryD2 += " AND D2_EMISSAO >= '"+DTOS(mv_par05)+"' AND D2_EMISSAO <= '"+DTOS(mv_par06)+"'"
cQueryD2 += " AND D2_ORIGLAN <> 'LF'"
If !lCusUnif
	cQueryD2 += " AND D2_LOCAL = '"+mv_par08+"'"
EndIf
//������������������������������������������������������Ŀ
//� N�o imprimir o produto MANUTENCAO (MV_PRDMNT) qdo integrado com MNT.       �
//��������������������������������������������������������
If MTR910IsMNT() 
	aProdsMNT := aClone(NGProdMNT())
	For nX := 1 To Len(aProdsMNT)
		cQueryD2 += " AND SB1.B1_COD <> '" + aProdsMNT[nX] + "'"
	Next nX
EndIf	
cQueryD2 += " AND SD2.D_E_L_E_T_=' ' AND SF4.D_E_L_E_T_=' '"	

cQueryD3 := " FROM "
cQueryD3 += RetSqlName("SB1") + " SB1 , "+ RetSqlName("SD3")+ " SD3 "
cQueryD3 += " WHERE SB1.B1_COD = D3_COD AND D3_FILIAL = '"+xFilial("SD3")+"' "
cQueryD3 += " AND D3_EMISSAO >= '"+DTOS(mv_par05)+"' AND D3_EMISSAO <= '"+DTOS(mv_par06)+"'"
If SuperGetMV('MV_D3ESTOR', .F., 'N') == 'N'
	cQueryD3 += " AND D3_ESTORNO <> 'S'"
EndIf
If lD3Servi .And. IntDL()
	cQueryD3 += " AND ( (D3_SERVIC = '   ') OR (D3_SERVIC <> '   ' AND D3_TM <= '500')  "
	cQueryD3 += " OR  (D3_SERVIC <> '   ' AND D3_TM > '500' AND D3_LOCAL ='" + GetMvNNR('MV_CQ','98') + "') )"
EndIf					
If !lCusUnif .And. !lLocProc
	cQueryD3 += " AND D3_LOCAL = '"+mv_par08+"'"
EndIf
//����������������������������������������������������������������������Ŀ
//� Nao imprimir o produto MANUTENCAO (MV_PRDMNT) qdo integrado com MNT. �
//������������������������������������������������������������������������
If MTR910IsMNT() 
	aProdsMNT := aClone(NGProdMNT())
	For nX := 1 To Len(aProdsMNT)
		cQueryD3 += " AND SB1.B1_COD <> '" + aProdsMNT[nX] + "'"
	Next nX
EndIf	
cQueryD3 += " AND SD3.D_E_L_E_T_=' '"	

cQuerySub:= "SELECT 1 "

If mv_par07 == 1
	cQuery2 := " AND NOT EXISTS (" + cQuerySub + cQueryD1
	cQuery2 += cQueryB1B
	cQuery2 += " AND "
	cQuery2 += cQueryB1C
	cQuery2 += ") AND NOT EXISTS ("
	cQuery2 += cQuerySub + cQueryD2
	cQuery2 += cQueryB1B
	cQuery2 += " AND "
	cQuery2 += cQueryB1C
	cQuery2 += ") AND NOT EXISTS ("
	cQuery2 += cQuerySub + cQueryD3
	cQuery2 += cQueryB1B
	cQuery2 += " AND "
	cQuery2 += cQueryB1C + ")"
        
	cUnion := "%"
	cUnion += " UNION SELECT 'SB1'"		// 01
	cUnion += ", SB1EXS.B1_COD"			// 02
	cUnion += ", SB1EXS.B1_TIPO"		// 03
	cUnion += ", SB1EXS.B1_UM"			// 04
	cUnion += ", SB1EXS.B1_GRUPO"		// 05
	cUnion += ", SB1EXS.B1_DESC"		// 06
	cUnion += ", SB1EXS.B1_POSIPI"		// 07
	cUnion += ", ''"					// 08
	cUnion += ", ''"					// 09
	cUnion += ", ''"					// 10
	cUnion += ", ''"					// 11
	cUnion += ", ''"					// 12
	cUnion += ", ''"					// 13
	cUnion += ", ''"					// 14
	cUnion += ", 0"						// 15
	cUnion += ", 0"						// 16
	cUnion += ", ''"					// 17
	cUnion += ", ''"					// 18
	cUnion += ", ''"					// 19
	cUnion += ", ''"					// 20
	cUnion += ", ''"					// 21
	cUnion += ", ''"					// 22
	cUnion += ", ''"					// 23
	cUnion += ", ''"					// 24
	cUnion += ", 0"						// 25
	cUnion += ", ''"					// 26
	If lVEIC
		cUnion += ", SB1EXS.B1_CODITE CODITE"	// 27
	EndIf
	cUnion += ", ''"					// 28
	cUnion += ", 0"						// 29
	cUnion += " FROM "+RetSqlName("SB1") + " SB1EXS WHERE"
	cUnion += cQueryB1D
	cUnion += cQuery2
	cUnion += "%"
EndIf

cOrder := "%"
If nOrdem == 1
	If ! lVEIC
		cOrder += " 2,9,"
	Else
		cOrder += " 27, 9,"
	EndIf	
ElseIf nOrdem == 2
	If ! lVEIC
		cOrder += " 3,2,9,"
	Else
		cOrder += " 3, 27, 9,"
	EndIf	
EndIf
If mv_par16 == 1
//		cOrder += "17,12"+IIf(lVEIC,',29',',28')
	cOrder += "12"+IIf(lVEIC,',29',',28')
Else
	If lCusUnif
		cOrder += "8,12"+IIf(lVEIC,',29',',28')
	Else
//			cOrder += "17,8,12"+IIf(lVEIC,',29',',28')
		cOrder += "8"+IIf(lVEIC,',29',',28')
	EndIf
EndIf	
cOrder += "%"

BeginSql Alias cAliasTop

	SELECT 	'SD1' ARQ, 				//-- 01 ARQ
			 SB1.B1_COD PRODUTO, 	//-- 02 PRODUTO
			 SB1.B1_TIPO TIPO, 		//-- 03 TIPO
			 SB1.B1_UM,   			//-- 04 UM
			 SB1.B1_GRUPO GRUPO,  	//-- 05 GRUPO
			 SB1.B1_DESC DESCR ,  	//-- 06 DESCR
		     SB1.B1_POSIPI, 		//-- 07
		     D1_SEQCALC SEQCALC,    //-- 08
			 D1_DTDIGIT DTDIGIT,	//-- 09 DTDIGIT
			 D1_TES TES,			//-- 10 TES
			 D1_CF CF,				//-- 11 CF
			 D1_NUMSEQ SEQUENCIA,	//-- 12 SEQUENCIA
			 D1_DOC DOCUMENTO,		//-- 13 DOCUMENTO
			 D1_SERIE SERIE,		//-- 14 SERIE
			 D1_QUANT QUANTIDADE,	//-- 15 QUANTIDADE
			 D1_QTSEGUM QUANT2UM,	//-- 16 QUANT2UM
			 D1_LOCAL ARMAZEM,		//-- 17 ARMAZEM
             ' ' PROJETO,			//-- 18 PROJETO
			 ' ' OP,				//-- 19 OP
			 ' ' CC,				//-- 20 OP
			 D1_FORNECE FORNECEDOR,	//-- 21 FORNECEDOR
			 D1_LOJA LOJA,			//-- 22 LOJA
			 ' ' PEDIDO,            //-- 23 PEDIDO
			 D1_TIPO TIPONF,		//-- 24 TIPO NF
			 %Exp:cSelectD1%		//-- 25 CUSTO 
			 ' ' TRT 				//-- 26 TRT
			 %Exp:cSelectVe%        //-- 27 CODITE
			 D1_LOTECTL LOTE, 	    //-- 28 LOTE					 
			 SD1.R_E_C_N_O_ NRECNO  //-- 29 RECNO

	FROM %table:SB1% SB1,%table:SD1% SD1,%table:SF4% SF4
	
	WHERE SB1.B1_COD     =  SD1.D1_COD		AND  	SD1.D1_FILIAL  =  %xFilial:SD1%		AND
		  SF4.F4_FILIAL  =  %xFilial:SF4%  	AND 	SD1.D1_TES     =  SF4.F4_CODIGO		AND
		  SF4.F4_ESTOQUE =  'S'				AND 	SD1.D1_DTDIGIT >= %Exp:mv_par05%   AND
		  SD1.D1_DTDIGIT <= %Exp:mv_par06%	AND		SD1.D1_ORIGLAN <> 'LF'				   
		  %Exp:cWhereD1%
		  SD1.%NotDel%						AND 	SF4.%NotDel%                           
		  %Exp:cWhereB1A%                   AND
		  %Exp:cWhereB1C%

    UNION
    
	SELECT 'SD2',	     			
			SB1.B1_COD,	        	
			SB1.B1_TIPO,		    
			SB1.B1_UM,				
			SB1.B1_GRUPO,		    
			SB1.B1_DESC,		    
			SB1.B1_POSIPI,
			D2_SEQCALC,
			D2_EMISSAO,				
			D2_TES,					
			D2_CF,					
			D2_NUMSEQ,				
			D2_DOC,					
			D2_SERIE,				
			D2_QUANT,				
			D2_QTSEGUM,				
			D2_LOCAL,				
			' ',					
			' ',					
			' ',					
			D2_CLIENTE,				
			D2_LOJA,				
			D2_PEDIDO,
			D2_TIPO,				
			%Exp:cSelectD2%			
			' ' 					
			%Exp:cSelectVe%
			D2_LOTECTL,
		    SD2.R_E_C_N_O_ SD2RECNO 	// 29

	FROM %table:SB1% SB1,%table:SD2% SD2,%table:SF4% SF4
	
	WHERE	SB1.B1_COD     =  SD2.D2_COD		AND	SD2.D2_FILIAL  = %xFilial:SD2%		AND
			SF4.F4_FILIAL  = %xFilial:SF4% 		AND	SD2.D2_TES     =  SF4.F4_CODIGO		AND
			SF4.F4_ESTOQUE =  'S'				AND	SD2.D2_EMISSAO >= %Exp:mv_par05%	AND
			SD2.D2_EMISSAO <= %Exp:mv_par06%	AND	SD2.D2_ORIGLAN <> 'LF'				   
			%Exp:cWhereD2%
			SD2.%NotDel%						AND SF4.%NotDel%						   
			%Exp:cWhereB1A%                     AND
		  	%Exp:cWhereB1C%

	UNION		

	SELECT 	'SD3',	    			
			SB1.B1_COD,	    	    
			SB1.B1_TIPO,		    
			SB1.B1_UM,				
			SB1.B1_GRUPO,	     	
			SB1.B1_DESC,		    
			SB1.B1_POSIPI,
			D3_SEQCALC,
			D3_EMISSAO,				
			D3_TM,					
			D3_CF,					
			D3_NUMSEQ,				
			D3_DOC,					
			' ',					
			D3_QUANT,				
			D3_QTSEGUM,				
			D3_LOCAL,				
			D3_PROJPMS,
			D3_OP,					
			D3_CC,
			' ',					
			' ',					
			' ',					
			' ',									
			%Exp:cSelectD3%			
			D3_TRT 
			%Exp:cSelectVe%
			D3_LOTECTL,
			SD3.R_E_C_N_O_ SD3RECNO 	// 29

	FROM %table:SB1% SB1,%table:SD3% SD3

	WHERE	SB1.B1_COD     =  SD3.D3_COD 		AND SD3.D3_FILIAL  =  %xFilial:SD3%		AND
			SD3.D3_EMISSAO >= %Exp:mv_par05%	AND	SD3.D3_EMISSAO <= %Exp:mv_par06%	AND
			%Exp:cWhereD3% 	
			SD3.%NotDel% 

			
	%Exp:cUnion%			

	ORDER BY %Exp:cOrder%

EndSql 

//������������������������������������������������������������������������Ŀ
//�Metodo EndQuery ( Classe TRSection )                                    �
//�                                                                        �
//�Prepara o relat�rio para executar o Embedded SQL.                       �
//�                                                                        �
//�ExpA1 : Array com os parametros do tipo Range                           �
//�                                                                        �
//��������������������������������������������������������������������������
oReport:Section(1):EndQuery(/*Array com os parametros do tipo Range*/)

//������������������������������������������������������������������������Ŀ
//�Inicio da impressao do fluxo do relat�rio                               �
//��������������������������������������������������������������������������
dbSelectArea(cAliasTop)
oReport:SetMeter(nTotRegs)

TcSetField(cAliasTop,DTDIGIT ,"D", TamSx3("D1_DTDIGIT")[1], TamSx3("D1_DTDIGIT")[2] )

While !oReport:Cancel() .And. !(cAliasTop)->(Eof()) .And. lImpLivro

	If oReport:Cancel()
		Exit
	EndIf

	//��������������������������������������������������������������Ŀ
	//� Considera filtro escolhido                                   �
	//����������������������������������������������������������������
	If !Empty(cFilUser) .And. SUBSTR(cFilUser,2,2) == "B1"
		dbSelectArea("SB1")
		SB1->(dbSetOrder(1))
	    SB1->(dbSeek(xFilial("SB1")+(cAliasTop)->PRODUTO))
	    If !(&(cFilUser))
  			   dbSelectArea(cAliasTop)	 	    
	       dbSkip()
    	   Loop
    	EndIf  
    ElseIf !Empty(cFilUser) .And. SUBSTR(cFilUser,2,2) == "B2"
   			dbSelectArea("SB2")
		SB2->(dbSetOrder(1))
	    SB2->(dbSeek(xFilial("SB2")+(cAliasTop)->PRODUTO))
	    If !(&(cFilUser))
  			   dbSelectArea(cAliasTop)	 	    
	       dbSkip()
    	   Loop
    	EndIf    
	EndIf

	dbSelectArea(cAliasTop)
	oReport:IncMeter()
	//��������������������������������������������������Ŀ
	//� Se nao encontrar no arquivo de saldos ,nao lista �
	//����������������������������������������������������
	dbSelectArea("SB2")
	If !dbSeek(xFilial("SB2")+(cAliasTop)->PRODUTO+If(lCusUnif,"",mv_par08))
		dbSelectArea(cAliasTop)
		dbSkip()
		Loop
	EndIf
	// Nao lista de saldo for igual a zero
	If mv_par20 == 2 .And. SB2->B2_QATU == 0
		dbSelectArea(cAliasTop)
		dbSkip()
		Loop
	EndIf
	// Nao lista de saldo for negativo
	If mv_par21 == 2 .And. SB2->B2_QATU < 0
		dbSelectArea(cAliasTop)
		dbSkip()
		Loop
	EndIf

	dbSelectArea(cAliasTop)
	cProdAnt  := (cAliasTop)->PRODUTO
	cLocalAnt := SB2->B2_LOCAL
	lFirst:=.F.

	//������������������������������������������������Ŀ
	//� Calcula o Saldo Inicial do Produto             �
	//��������������������������������������������������
	If lCusUnif
		aArea:=GetArea()
		aSalAtu  := { 0,0,0,0,0,0,0 }
		dbSelectArea("SB2")
		dbSetOrder(1)
		MsSeek(cSeek:=xFilial("SB2")+(cAliasTOP)->PRODUTO)
		While !Eof() .And. B2_FILIAL+B2_COD == cSeek
			aSalAlmox := CalcEst((cAliasTOP)->PRODUTO,SB2->B2_LOCAL,mv_par05)
			For i:=1 to Len(aSalAtu)
				aSalAtu[i] += aSalAlmox[i]
			Next i
			dbSkip()
		End
		RestArea(aArea)
	Else
		aSalAtu := CalcEst((cAliasTOP)->PRODUTO,mv_par08,mv_par05)
	EndIf

	If (nAcho := ASCAN(aGrupos,{|x| (cAliasTOP)->TIPO == x[1]})) > 0
		aGrupos[nAcho][4] += aSalAtu[mv_par11+1]
	Else
		AADD(aGrupos,{(cAliasTOP)->TIPO,0,0,aSalAtu[mv_par11+1]})
	EndIf

	//������������������������������������������������Ŀ
	//� Calcula o Custo Medio do Produto               �
	//��������������������������������������������������
	
	If AsalAtu[1] > 0
		nCusmed := aSalAtu[mv_par11+1]/aSalAtu[1]
	ElseIf AsalAtu[1] == 0 .and. AsalAtu[mv_par11+1] == 0
		nCusMed := 0
	Else
		SB2->(dbSeek(xFilial("SB2") + (cAliasTOP)->PRODUTO + (cAliasTOP)->ARMAZEM))
		nCusmed := &("SB2->B2_CM" + Str(mv_par11,1))
	EndIf
	MR910ImpS1(aSalAtu,nCusMed,cAliasTop,lVEIC,lCusUnif,oSection1,oSection2)
	
	lFirst1 := .F.

	oSection3:Init() 
    oSection3:Cell("cProd"):SetValue((cAliasTop)->PRODUTO)
    oSection3:Cell("cDescr"):SetValue((cAliasTop)->DESCR)
    oSection3:Cell("cTpM"):SetValue((cAliasTop)->TIPO)
    oSection3:Cell("cGrp"):SetValue((cAliasTop)->GRUPO)
    
    	
	While !oReport:Cancel() .And. !(cAliasTop)->(Eof()) .And. (cAliasTop)->PRODUTO = cProdAnt
		oReport:IncMeter()
		lContinua := .F.
		lImpSMov  := .F.
		lImpS3    := .F.

		If Alltrim((cAliasTop)->ARQ) $ "SD1/SD2"
			lFirst:=.T.
			SF4->(dbSeek(xFilial("SF4")+(cAliasTop)->TES))
			//��������������������������������������������������������������Ŀ
			//� Despreza Notas Fiscais Lancadas Pelo Modulo do Livro Fiscal  �
			//����������������������������������������������������������������
			//��������������������������������������������������������������Ŀ
			//� Executa ponto de entrada para verificar se considera TES que �
			//� NAO ATUALIZA saldos em estoque.                              �
			//����������������������������������������������������������������
			If lIxbConTes .And. SF4->F4_ESTOQUE != "S"
				lTesNEst := ExecBlock("MTAAVLTES",.F.,.F.)
				lTesNEst := If(ValType(lTesNEst) # "L",.F.,lTesNEst)
			EndIf
			If SF4->F4_ESTOQUE != "S" .And. !lTesNEst
				dbSkip()
				Loop
			EndIf
		ElseIf Alltrim((cAliasTop)->ARQ) == "SD3"
			lFirst:=.T.
			//����������������������������������������������������������������Ŀ
			//� Quando movimento ref apropr. indireta, so considera os         �
			//� movimentos com destino ao almoxarifado de apropriacao indireta.�
			//������������������������������������������������������������������
			lInverteMov:=.F.
			If (cAliasTop)->ARMAZEM != cLocalAnt .Or. lCusUnif
				If !(Substr((cAliasTop)->CF,3,1) == "3")
					If !lCusUnif
						dbSkip()
						Loop
					EndIf
				ElseIf lPriApropri
					lInverteMov:=.T.
				EndIf
			EndIf
			//����������������������������������������������������������������Ŀ
			//� Caso seja uma transferencia de localizacao verifica se lista   �
			//� o movimento ou nao                                             �
			//������������������������������������������������������������������
			If mv_par17 == 2 .And. Substr((cAliasTop)->CF,3,1) == "4"
				cNumSeqTr := (cAliasTOP)->(PRODUTO+SEQUENCIA+ARMAZEM)
				aDadosTran:={(cAliasTOP)->TES,(cAliasTOP)->QUANTIDADE,(cAliasTOP)->CUSTO,(cAliasTOP)->QUANT2UM,(cAliasTOP)->TIPO,;
					(cAliasTOP)->DTDIGIT,(cAliasTOP)->CF,(cAliasTOP)->SEQUENCIA,(cAliasTOP)->DOCUMENTO,(cAliasTOP)->PRODUTO,;
					(cAliasTOP)->OP,(cAliasTOP)->PROJETO,(cAliasTOP)->CC,(cAliasTOP)->ARQ}
				dbSkip()
				If (cAliasTOP)->(PRODUTO+SEQUENCIA+ARMAZEM) == cNumSeqTr
					dbSkip()
					Loop
				Else
					lContinua := .T.
					If lFirst
						oSection3:Cell("dDtMov"):SetValue(STOD(aDadosTran[6]))			
						oSection3:Cell("cTES"):SetValue(aDadosTran[1])										
						If ( cPaisLoc=="BRA" )
							oSection3:Cell("cCF"):Show()
							oSection3:Cell("cCF"):SetValue(aDadosTran[7])
							/*
							If	lInverteMov
								@Li , 018 PSay "*"
							EndIf
							*/
						Else
							oSection3:Cell("cCF"):Hide()
							oSection3:Cell("cCF"):SetValue("   ")
						EndIf
						If mv_par09 $ "Ss"
							oSection3:Cell("cDoc"):SetValue(aDadosTran[8])			
						Else
							oSection3:Cell("cDoc"):SetValue(aDadosTran[9])			
						Endif
					EndIf
					If aDadosTran[1] <= "500"
						oSection3:Cell("nENTQtd"):Show()
						oSection3:Cell("nENTCus"):Show()
						oSection3:Cell("nCusMov"):Show()

						oSection3:Cell("nENTQtd"):SetValue(aDadosTran[2])			
						oSection3:Cell("nENTCus"):SetValue(aDadosTran[3])			
						oSection3:Cell("nCusMov"):SetValue(aDadosTran[3] / aDadosTran[2])			
						
						oSection3:Cell("nSAIQtd"):Hide()
						oSection3:Cell("nSAICus"):Hide()
						oSection3:Cell("nSAIQtd"):SetValue(0)			
						oSection3:Cell("nSAICus"):SetValue(0)			
                            
						aSalAtu[1] += aDadosTran[2]
						aSalAtu[mv_par11+1] += aDadosTran[3]
						aSalAtu[7] += aDadosTran[4]
						
						If (nAcho := ASCAN(aGrupos,{|x| aDadosTran[5] == x[1]})) > 0
							aGrupos[nAcho][2]+=aDadosTran[3]
							aGrupos[nAcho][4]+=aDadosTran[3]
						Else
							AADD(aGrupos,{aDadosTran[5],aDadosTran[3],0,aSalAtu[mv_par11+1]})
						EndIf
					Else
						oSection3:Cell("nENTQtd"):Hide()
						oSection3:Cell("nENTCus"):Hide()
						oSection3:Cell("nENTQtd"):SetValue(0)
						oSection3:Cell("nENTCus"):SetValue(0)
						
						oSection3:Cell("nCusMov"):Show()
						oSection3:Cell("nSAIQtd"):Show()
						oSection3:Cell("nSAICus"):Show()

						oSection3:Cell("nCusMov"):SetValue(aDadosTran[3] / aDadosTran[2])			
						oSection3:Cell("nSAIQtd"):SetValue(aDadosTran[2])			
						oSection3:Cell("nSAICus"):SetValue(aDadosTran[3])			

						aSalAtu[1] -= aDadosTran[2]
						aSalAtu[mv_par11+1] -= aDadosTran[3]
						aSalAtu[7] -= aDadosTran[4]
						If (nAcho := ASCAN(aGrupos,{|x| aDadosTran[5] == x[1]})) > 0
							aGrupos[nAcho][3]+=aDadosTran[3]
							aGrupos[nAcho][4]-=aDadosTran[3]
						Else
							AADD(aGrupos,{aDadosTran[5],0,aDadosTran[3],-(aSalAtu[mv_par11+1])})
						EndIf
					EndIf
				EndIf
			EndIf
		elseIf Alltrim((cAliasTop)->ARQ) $ "SB1"
			oSection3:Cell("nENTQtd"):SetValue(0)	
			oSection3:Cell("nENTCus"):SetValue(0)	
			oSection3:Cell("nCusMov"):SetValue(0)	
			oSection3:Cell("nENTQtd"):SetValue(0)		
			oSection3:Cell("nENTCus"):SetValue(0)		
			oSection3:Cell("nCusMov"):SetValue(0)			
			oSection3:Cell("nSAIQtd"):SetValue(0)	
			oSection3:Cell("nSAICus"):SetValue(0)	
			oSection3:Cell("nSAIQtd"):SetValue(0)			
			oSection3:Cell("nSAICus"):SetValue(0)
			oSection3:Cell("cCCPVPJOP"):SetValue(" ")
			lFirst:=.T.
		EndIf	
		If lFirst .And. !lContinua
			oSection3:Cell("dDtMov"):SetValue(STOD(DTDIGIT))			
			oSection3:Cell("cTES"):SetValue(TES)														
			If ( cPaisLoc=="BRA" )
				oSection3:Cell("cCF"):Show()
				oSection3:Cell("cCF"):SetValue(CF)					
				/*
				If	lInverteMov
					@Li , 018 PSay "*"
				EndIf
				*/
			Else
				oSection3:Cell("cCF"):Hide()
				oSection3:Cell("cCF"):SetValue("   ")				
			EndIf
			If mv_par09 $ "Ss"
				oSection3:Cell("cDoc"):SetValue(SEQUENCIA)			
			Else
				oSection3:Cell("cDoc"):SetValue(DOCUMENTO)						
			Endif	
		EndIf

		Do Case
			Case Alltrim((cAliasTop)->ARQ) == "SD1" .And. !lContinua
				lDev:=MTR910Dev(cAliasTop)
				If (cAliasTOP)->TES <= "500" .And. !lDev
					If (cAliasTOP)->TIPONF != "C"
						oSection3:Cell("nCusMov"):SetValue((cAliasTOP)->CUSTO / (cAliasTOP)->QUANTIDADE)
						oSection3:Cell("nCusMov"):Show()
					Else
						oSection3:Cell("nCusMov"):SetValue(0)
						oSection3:Cell("nCusMov"):Hide()
					EndIf
					
					oSection3:Cell("nENTQtd"):Show()
					oSection3:Cell("nENTCus"):Show()
					
					oSection3:Cell("nENTQtd"):SetValue((cAliasTOP)->QUANTIDADE)			
					oSection3:Cell("nENTCus"):SetValue((cAliasTOP)->CUSTO)			
					
					oSection3:Cell("nSAIQtd"):Hide()
					oSection3:Cell("nSAICus"):Hide()						
					oSection3:Cell("nSAIQtd"):SetValue(0)
					oSection3:Cell("nSAICus"):SetValue(0)
					
					aSalAtu[1] += (cAliasTOP)->QUANTIDADE
					aSalAtu[mv_par11+1] += (cAliasTOP)->CUSTO
					aSalAtu[7] += (cAliasTOP)->QUANT2UM
					If (nAcho := ASCAN(aGrupos,{|x| (cAliasTOP)->TIPO == x[1]})) > 0
						aGrupos[nAcho][2]+=(cAliasTOP)->CUSTO
						aGrupos[nAcho][4]+=(cAliasTOP)->CUSTO
					Else
						AADD(aGrupos,{(cAliasTOP)->TIPO,(cAliasTOP)->CUSTO,0,aSalAtu[mv_par11+1]})
					EndIf
				Else
					If (cAliasTOP)->TIPONF != "C"
						oSection3:Cell("nCusMov"):SetValue((cAliasTOP)->CUSTO / (cAliasTOP)->QUANTIDADE)			
						oSection3:Cell("nCusMov"):Show()
					Else
						oSection3:Cell("nCusMov"):SetValue(0)									
						oSection3:Cell("nCusMov"):Hide()
					EndIf

					oSection3:Cell("nENTQtd"):Hide()
					oSection3:Cell("nENTCus"):Hide()
					oSection3:Cell("nENTQtd"):SetValue(0)
					oSection3:Cell("nENTCus"):SetValue(0)
						
					oSection3:Cell("nSAIQtd"):Show()
					oSection3:Cell("nSAICus"):Show()

					If lDev

						oSection3:Cell("nSAIQtd"):SetValue((cAliasTOP)->QUANTIDADE * -1)
						oSection3:Cell("nSAICus"):SetValue((cAliasTOP)->CUSTO * -1)
						
						aSalAtu[1] += (cAliasTOP)->QUANTIDADE
						aSalAtu[mv_par11+1] += (cAliasTOP)->CUSTO
						aSalAtu[7] += (cAliasTOP)->QUANT2UM
						If (nAcho := ASCAN(aGrupos,{|x| (cAliasTOP)->TIPO == x[1]})) > 0
							aGrupos[nAcho][3]-=(cAliasTOP)->CUSTO
							aGrupos[nAcho][4]+=(cAliasTOP)->CUSTO
						Else
							AADD(aGrupos,{(cAliasTOP)->TIPO,0,-((cAliasTOP)->CUSTO),aSalAtu[mv_par11+1]})
						EndIf
					Else
						oSection3:Cell("nSAIQtd"):SetValue((cAliasTOP)->QUANTIDADE)			
						oSection3:Cell("nSAICus"):SetValue((cAliasTOP)->CUSTO)																
						
						aSalAtu[1] -= (cAliasTOP)->QUANTIDADE
						aSalAtu[mv_par11+1] -= (cAliasTOP)->CUSTO
						aSalAtu[7] -= (cAliasTOP)->QUANT2UM
						If (nAcho := ASCAN(aGrupos,{|x| (cAliasTOP)->TIPO == x[1]})) > 0
							aGrupos[nAcho][3]+=(cAliasTOP)->CUSTO
							aGrupos[nAcho][4]-=(cAliasTOP)->CUSTO
						Else
							AADD(aGrupos,{(cAliasTOP)->TIPO,0,(cAliasTOP)->CUSTO,-(aSalAtu[mv_par11+1])})
						EndIf
					EndIf
				EndIf
			Case Alltrim((cAliasTop)->ARQ) = "SD2" .And. !lContinua
				lDev:=MTR910Dev(cAliasTop)
				If (cAliasTOP)->TES <= "500" .Or. lDev
					If lDev
						
						oSection3:Cell("nENTQtd"):Show()
						oSection3:Cell("nENTCus"):Show()

						oSection3:Cell("nENTQtd"):SetValue((cAliasTOP)->QUANTIDADE * -1)
						oSection3:Cell("nENTCus"):SetValue((cAliasTOP)->CUSTO * -1)
						
						aSalAtu[1] -= (cAliasTOP)->QUANTIDADE
						aSalAtu[mv_par11+1] -= (cAliasTOP)->CUSTO
						aSalAtu[7] -= (cAliasTOP)->QUANT2UM
						If (nAcho := ASCAN(aGrupos,{|x| (cAliasTOP)->TIPO == x[1]})) > 0
							aGrupos[nAcho][2]-=(cAliasTOP)->CUSTO
							aGrupos[nAcho][4]-=(cAliasTOP)->CUSTO
						Else
							AADD(aGrupos,{(cAliasTOP)->TIPO,-((cAliasTOP)->CUSTO),0,-(aSalAtu[mv_par11+1])})
						EndIf
					Else
						oSection3:Cell("nENTQtd"):Show()
						oSection3:Cell("nENTCus"):Show()
						
						oSection3:Cell("nENTQtd"):SetValue((cAliasTOP)->QUANTIDADE)			
						oSection3:Cell("nENTCus"):SetValue((cAliasTOP)->CUSTO)										
						
						aSalAtu[1] += (cAliasTOP)->QUANTIDADE
						aSalAtu[mv_par11+1] += (cAliasTOP)->CUSTO
						aSalAtu[7] += (cAliasTOP)->QUANT2UM
						If (nAcho := ASCAN(aGrupos,{|x| (cAliasTOP)->TIPO == x[1]})) > 0
							aGrupos[nAcho][2]+=(cAliasTOP)->CUSTO
							aGrupos[nAcho][4]+=(cAliasTOP)->CUSTO
						Else
							AADD(aGrupos,{(cAliasTOP)->TIPO,(cAliasTOP)->CUSTO,0,aSalAtu[mv_par11+1]})
						EndIf
					EndIf

					If (cAliasTOP)->TIPONF != "C"
						oSection3:Cell("nCusMov"):SetValue((cAliasTOP)->CUSTO / (cAliasTOP)->QUANTIDADE)																
						oSection3:Cell("nCusMov"):Show()
					Else
						oSection3:Cell("nCusMov"):SetValue(0)
						oSection3:Cell("nCusMov"):Hide()
					EndIf
					oSection3:Cell("nSAIQtd"):Hide()
					oSection3:Cell("nSAICus"):Hide()
					oSection3:Cell("nSAIQtd"):SetValue(0)
					oSection3:Cell("nSAICus"):SetValue(0)
				Else
					If (cAliasTOP)->TIPONF != "C"
						oSection3:Cell("nCusMov"):SetValue((cAliasTOP)->CUSTO / (cAliasTOP)->QUANTIDADE)																
						oSection3:Cell("nCusMov"):Show()
					Else
						oSection3:Cell("nCusMov"):SetValue(0)																						
						oSection3:Cell("nCusMov"):Hide()
					EndIf						
					
					oSection3:Cell("nENTQtd"):Hide()
					oSection3:Cell("nENTCus"):Hide()
					oSection3:Cell("nENTQtd"):SetValue(0)
					oSection3:Cell("nENTCus"):SetValue(0)

					oSection3:Cell("nSAIQtd"):Show()
					oSection3:Cell("nSAICus"):Show()
					
					oSection3:Cell("nSAIQtd"):SetValue((cAliasTOP)->QUANTIDADE)			
					oSection3:Cell("nSAICus"):SetValue((cAliasTOP)->CUSTO)																						
					
					aSalAtu[1] -= (cAliasTOP)->QUANTIDADE
					aSalAtu[mv_par11+1] -= (cAliasTOP)->CUSTO
					aSalAtu[7] -= (cAliasTOP)->QUANT2UM
					If (nAcho := ASCAN(aGrupos,{|x| (cAliasTOP)->TIPO == x[1]})) > 0
						aGrupos[nAcho][3]+=(cAliasTOP)->CUSTO
						aGrupos[nAcho][4]-=(cAliasTOP)->CUSTO
					Else
						AADD(aGrupos,{(cAliasTOP)->TIPO,0,(cAliasTOP)->CUSTO,-(aSalAtu[mv_par11+1])})
					EndIf
				EndIf
			Case Alltrim((cAliasTop)->ARQ) == "SD3" .And. !lContinua
				lDev := .F.
				If	lInverteMov
					If (cAliasTOP)->TES > "500"

						oSection3:Cell("nENTQtd"):Show()
						oSection3:Cell("nENTCus"):Show()
						oSection3:Cell("nCusMov"):Show()

						oSection3:Cell("nENTQtd"):SetValue((cAliasTOP)->QUANTIDADE)			
						oSection3:Cell("nENTCus"):SetValue((cAliasTOP)->CUSTO)			
						oSection3:Cell("nCusMov"):SetValue((cAliasTOP)->CUSTO / (cAliasTOP)->QUANTIDADE)										
						
						oSection3:Cell("nSAIQtd"):Hide()
						oSection3:Cell("nSAICus"):Hide()							
						oSection3:Cell("nSAIQtd"):SetValue(0)
						oSection3:Cell("nSAICus"):SetValue(0)														
						
						aSalAtu[1] += (cAliasTOP)->QUANTIDADE
						aSalAtu[mv_par11+1] += (cAliasTOP)->CUSTO
						aSalAtu[7] += (cAliasTOP)->QUANT2UM
						If (nAcho := ASCAN(aGrupos,{|x| (cAliasTOP)->TIPO == x[1]})) > 0
							aGrupos[nAcho][2]+=(cAliasTOP)->CUSTO
							aGrupos[nAcho][4]+=(cAliasTOP)->CUSTO
						Else
							AADD(aGrupos,{(cAliasTOP)->TIPO,(cAliasTOP)->CUSTO,0,aSalAtu[mv_par11+1]})
						EndIf
					Else
						oSection3:Cell("nENTQtd"):Hide()
						oSection3:Cell("nENTCus"):Hide()
						oSection3:Cell("nENTQtd"):SetValue(0)
						oSection3:Cell("nENTCus"):SetValue(0)
						
						oSection3:Cell("nCusMov"):Show()
						oSection3:Cell("nSAIQtd"):Show()
						oSection3:Cell("nSAICus"):Show()
						
						oSection3:Cell("nCusMov"):SetValue((cAliasTOP)->CUSTO / (cAliasTOP)->QUANTIDADE)			
						oSection3:Cell("nSAIQtd"):SetValue((cAliasTOP)->QUANTIDADE)			
						oSection3:Cell("nSAICus"):SetValue((cAliasTOP)->CUSTO)										
						
						aSalAtu[1] -= (cAliasTOP)->QUANTIDADE
						aSalAtu[mv_par11+1] -= (cAliasTOP)->CUSTO
						aSalAtu[7] -= (cAliasTOP)->QUANT2UM
						If (nAcho := ASCAN(aGrupos,{|x| (cAliasTOP)->TIPO == x[1]})) > 0
							aGrupos[nAcho][3]+=(cAliasTOP)->CUSTO
							aGrupos[nAcho][4]-=(cAliasTOP)->CUSTO
						Else
							AADD(aGrupos,{(cAliasTOP)->TIPO,0,(cAliasTOP)->CUSTO,-(aSalAtu[mv_par11+1])})
						EndIf
					EndIf 
					If lCusUnif
						lPriApropri:=.F.
					EndIf
				Else
					If (cAliasTOP)->TES <= "500"

						oSection3:Cell("nENTQtd"):Show()
						oSection3:Cell("nENTCus"):Show()
						oSection3:Cell("nCusMov"):Show()

						oSection3:Cell("nENTQtd"):SetValue((cAliasTOP)->QUANTIDADE)			
						oSection3:Cell("nENTCus"):SetValue((cAliasTOP)->CUSTO)			
						oSection3:Cell("nCusMov"):SetValue((cAliasTOP)->CUSTO / (cAliasTOP)->QUANTIDADE)																	
						
						oSection3:Cell("nSAIQtd"):Hide()
						oSection3:Cell("nSAICus"):Hide()							
						oSection3:Cell("nSAIQtd"):SetValue(0)
						oSection3:Cell("nSAICus"):SetValue(0)
						
						aSalAtu[1] += (cAliasTOP)->QUANTIDADE
						aSalAtu[mv_par11+1] += (cAliasTOP)->CUSTO
						aSalAtu[7] += (cAliasTOP)->QUANT2UM
						If (nAcho := ASCAN(aGrupos,{|x| (cAliasTOP)->TIPO == x[1]})) > 0
							aGrupos[nAcho][2]+=(cAliasTOP)->CUSTO
							aGrupos[nAcho][4]+=(cAliasTOP)->CUSTO
						Else
							AADD(aGrupos,{(cAliasTOP)->TIPO,(cAliasTOP)->CUSTO,0,aSalAtu[mv_par11+1]})
						EndIf
					Else

						oSection3:Cell("nENTQtd"):Hide()
						oSection3:Cell("nENTCus"):Hide()
						oSection3:Cell("nENTQtd"):SetValue(0)
						oSection3:Cell("nENTCus"):SetValue(0)
						
						oSection3:Cell("nCusMov"):Show()
						oSection3:Cell("nSAIQtd"):Show()
						oSection3:Cell("nSAICus"):Show()

						oSection3:Cell("nCusMov"):SetValue((cAliasTOP)->CUSTO / (cAliasTOP)->QUANTIDADE)			
						oSection3:Cell("nSAIQtd"):SetValue((cAliasTOP)->QUANTIDADE)			
						oSection3:Cell("nSAICus"):SetValue((cAliasTOP)->CUSTO)																	
						
						aSalAtu[1] -= (cAliasTOP)->QUANTIDADE
						aSalAtu[mv_par11+1] -= (cAliasTOP)->CUSTO
						aSalAtu[7] -= (cAliasTOP)->QUANT2UM
						If (nAcho := ASCAN(aGrupos,{|x| (cAliasTOP)->TIPO == x[1]})) > 0
							aGrupos[nAcho][3]+=(cAliasTOP)->CUSTO
							aGrupos[nAcho][4]-=(cAliasTOP)->CUSTO
						Else
							AADD(aGrupos,{(cAliasTOP)->TIPO,0,(cAliasTOP)->CUSTO,-(aSalAtu[mv_par11+1])})
						EndIf
					EndIf
					If lCusUnif
						lPriApropri:=.T.
					EndIf
				EndIf
		EndCase
		If lFirst
			oSection3:Cell("nSALDQtd"):SetValue(aSalAtu[1])			
			oSection3:Cell("nSALDCus"):SetValue(aSalAtu[mv_par11+1])			
		EndIf
		Do Case
			Case Alltrim((cAliasTop)->ARQ) == "SD3" .And. !lContinua
				If Empty((cAliasTOP)->OP) .And. Empty((cAliasTOP)->PROJETO)
					oSection3:Cell("cCCPVPJOP"):SetValue('CC'+(cAliasTOP)->CC)			
				ElseIf !Empty((cAliasTOP)->PROJETO)
					oSection3:Cell("cCCPVPJOP"):SetValue('PJ'+(cAliasTOP)->PROJETO)
				ElseIf !Empty((cAliasTOP)->OP)
					oSection3:Cell("cCCPVPJOP"):SetValue('OP'+(cAliasTOP)->OP)
				EndIf
			Case Alltrim((cAliasTop)->ARQ) == "SD1" .And. !lContinua
				oSection3:Cell("cCCPVPJOP"):SetValue('F-'+(cAliasTOP)->FORNECEDOR)
			Case Alltrim((cAliasTop)->ARQ) == "SD2" .And. !lContinua
				oSection3:Cell("cCCPVPJOP"):SetValue('P-'+(cAliasTOP)->PEDIDO)					
			Case lContinua .And. aDadosTran[14] == "SD3"
				If Empty(aDadosTran[11]) .And. Empty(aDadosTran[12])
					oSection3:Cell("cCCPVPJOP"):SetValue('CC'+aDadosTran[13])	
				ElseIf !Empty(aDadosTran[12])
					oSection3:Cell("cCCPVPJOP"):SetValue('PJ'+aDadosTran[12])
				ElseIf !Empty(aDadosTran[11])
					oSection3:Cell("cCCPVPJOP"):SetValue('OP'+aDadosTran[11])
				EndIf
		EndCase
            
		// Para imprimir o cabe�alho da se��o apenas uma vez
		If lCabec 
		   lCabec := .F.
		  Else
		   oSection3:SetHeaderSection(.F.) 
        Endif  
		If lFirst
			oSection3:PrintLine()
		Endif	

		If !lInverteMov .Or. (lInverteMov .And. lPriApropri)
			If !lContinua //Acerto para utilizar o Array aDadosTran[]
				dbSkip()
			EndIf
		EndIf
	EndDo
    /*
	If lFirst
		oReport:PrintText(STR0018+TransForm(aSalAtu[7],cPicB2Qt2),,oSection3:Cell('nSAICus'):ColPos()) //"QTD. NA SEGUNDA UM: "											
		lImpS3 := .T.
	Else
		If !MTR910IsMNT()
			oReport:PrintText(STR0019)	//"NAO HOUVE MOVIMENTACAO PARA ESTE PRODUTO"
			oReport:ThinLine()
			lImpSMov := .T.
		Else
			aProdsMNT := aClone(NGProdMNT())
			If aScan(aProdsMNT, {|x| AllTrim(x) == AllTrim(SB1->B1_COD) }) == 0
				oReport:PrintText(STR0019)	//"NAO HOUVE MOVIMENTACAO PARA ESTE PRODUTO"
				oReport:ThinLine()
				lImpSMov := .T.
			EndIf
		EndIf	
	EndIf
    */
	oSection1:Finish()
	oSection2:Finish()
	If !lImpSMov .And. lImpS3
		oSection3:Finish()				
	Endif	
EndDo
dbSelectArea(cAliasTop)
/*
If !Empty(aGrupos)
	
	oReport:SkipLine()    
	oReport:PrintText(STR0020) //"R E S U M O"
	oReport:SkipLine() 
	 
	dbSelectArea("SX5")
	For i:=1 to Len(aGrupos)
		dbSeek(xFilial("SX5")+"02"+aGrupos[i][1])
		oReport:PrintText(X5Descri(),oReport:Row())
		oReport:PrintText(TransForm(aGrupos[i][2],cPicD1Cust),oReport:Row(),oSection3:Cell('nENTCus'):ColPos())														
		oReport:PrintText(TransForm(aGrupos[i][3],cPicD2Cust),oReport:Row(),oSection3:Cell('nSAICus'):ColPos())
		oReport:PrintText(TransForm(aGrupos[i][4],cPicB2Tot ),oReport:Row(),oSection3:Cell('nSALDCus'):ColPos())			
		oReport:SkipLine()    
	Next i
EndIf	
*/
//��������������������������������������������������������������Ŀ
//� Impressao de Termos Abertura e Encerramento                  �
//����������������������������������������������������������������
If lImpTermos // Impressao dos Termos

	If !lImpLivro 
		oReport:HideHeader() 
		oReport:HideFooter() 
		oReport:HideParamPage()
	Endif

	cArqAbert:=GetMv("MV_LMOD3AB")
	cArqEncer:=GetMv("MV_LMOD3EN")

	dbSelectArea("SM0")
	aVariaveis:={}

	For i:=1 to FCount()
		If FieldName(i)=="M0_CGC"
			AADD(aVariaveis,{FieldName(i),Transform(FieldGet(i),"@R 99.999.999/9999-99")})
		Else
			If FieldName(i)=="M0_NOME"
				Loop
			EndIf
			AADD(aVariaveis,{FieldName(i),FieldGet(i)})
		EndIf
	Next

	dbSelectArea("SX1")
	dbSeek(PADR("MTR910",nTamSX1)+"01")

	While SX1->X1_GRUPO==PADR("MTR910",nTamSX1)
		AADD(aVariaveis,{Rtrim(Upper(X1_VAR01)),&(X1_VAR01)})
		dbSkip()
	EndDo

	If !File(cArqAbert)
		aSavSet:=__SetSets()
		//Editor de Termos de Livros
		cArqAbert:=CFGX024(,OemToAnsi(STR0021))		//" Edi��o do Termo de Abertura "
		__SetSets(aSavSet)
		Set(24,Set(24),.t.)
	EndIf

	If !File(cArqEncer)
		aSavSet:=__SetSets()
		// Editor de Termos de Livros
		cArqEncer:=CFGX024(,OemToAnsi(STR0022)) 		//" Edi��o do Termo de Encerramento "
		__SetSets(aSavSet)
		Set(24,Set(24),.t.)
	EndIf

	cDriver:=aDriver[4]
    oReport:HideHeader()
	If cArqAbert#NIL
		oReport:EndPage()
		ImpTerm(cArqAbert,aVariaveis,&cDriver,,,.T.,oReport)
	EndIf

	If cArqEncer#NIL
		oReport:EndPage()
		ImpTerm(cArqEncer,aVariaveis,&cDriver,,,.T.,oReport)
	EndIf

EndIf

Return NIL

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � MTR910val� Autor � Paulo Boschetti       � Data � 22.12.92 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Fun��o utilizada em valida��o no SX1                       ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function Mtr910val()
Local lRet := .T.

If mv_par09 $ "dsDS"
	lRet := .T.
Else
	lRet := .F.
EndIf

Return lRet

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � MTR910Dev� Autor � Rodrigo de A. Sartorio� Data � 25.04.96 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Avalia se item pertence a uma nota de devolu�ao             ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � MATR910                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function MTR910Dev(cAliasTop)
Static lListaDev := NIL
LOCAL lRet:=.F.

// Identifica se lista dev. na mesma coluna
lListaDev := If(ValType(lListaDev)#"L",GetMV("MV_LISTDEV"),lListaDev)


If lListaDev .And. (cAliasTop)->ARQ == "SD1"
	dbSelectArea("SF1")
	If dbSeek(xFilial("SF1")+(cAliasTop)->DOCUMENTO+(cAliasTop)->SERIE+(cAliasTop)->FORNECEDOR+(cAliasTop)->LOJA) .And. (cAliasTop)->TIPONF == "D"
		lRet:=.T.
	EndIf
ElseIf lListaDev .And. (cAliasTop)->ARQ == "SD2"
	dbSelectArea("SF2")
	If dbSeek(xFilial("SF2")+(cAliasTop)->DOCUMENTO+(cAliasTop)->SERIE+(cAliasTop)->FORNECEDOR+(cAliasTop)->LOJA) .And. (cAliasTop)->TIPONF == "D"
		lRet:=.T.
	EndIf
EndIf
dbSelectArea(cAliasTop)


Return lRet


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �MTR910VAlm � Autor �Rodrigo de A. Sartorio � Data �26/06/00 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Valida Almoxarifado do KARDEX com relacao a custo unificado ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � .T. / .F.                                                  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � MATR910                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function MTR910VAlm()
LOCAL lRet:=.T.
LOCAL cConteudo:=&(ReadVar())
LOCAL nOpc:=2
//��������������������������������������������������������������Ŀ
//� Verifica se utiliza custo unificado por Empresa/Filial       �
//����������������������������������������������������������������
LOCAL lCusUnif := A330CusFil()
If lCusUnif .And. cConteudo != Repl("*",TamSX3("B2_LOCAL")[1])
	nOpc := Aviso(STR0034,STR0035,{STR0036,STR0037})	//"Aten��o"###"Ao alterar o almoxarifado o custo medio unificado sera desconsiderado."###"Confirma"###"Abandona"
	If nOpc == 2
		lRet:=.F.
	EndIf
EndIf
Return lRet

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �MR910ImpS1� Autor � Nereu Humberto Junior � Data � 12/07/06 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Imprime secoes 1 e 2 (Dados do produto)                    ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � MR910ImpS1(ExpA1,ExpN1,ExpC1,ExpL1,ExpL2,ExpO1,ExpO2)	  ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpA1 = Array com informacoes do saldo inicial do item     ���
���          �   [1] = Saldo inicial em quantidade                        ���
���          �   [2] = Saldo inicial em valor                             ���
���          �   [3] = Saldo inicial na 2a unidade de medida              ���
���          � ExpN1 = Custo medio do item                                ���
���          � ExpC1 = Alias                                              ���
���          � ExpL1 = Veiculo                                            ���
���          � ExpL2 = Custo Unificado                                    ���
���          � ExpO1 = Secao 1                                            ���
���          � ExpO2 = Secao 2                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � MATR910                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function MR910ImpS1(aSalAtu,nCusMed,cAliasTop,lVEIC,lCusUnif,oSection1,oSection2)

Local aArea := GetArea()

oSection1:Init()
oSection2:Init()
/*
oSection1:Cell("nCusMed"):SetValue(nCusMed)
oSection1:Cell("nQtdSal"):SetValue(aSalAtu[1])
oSection1:Cell("nVlrSal"):SetValue(aSalAtu[mv_par11+1])			

oSection1:Cell("cProduto"):SetValue((cAliasTop)->PRODUTO)			
oSection1:Cell("cTipo"):SetValue((cAliasTop)->TIPO	)
*/
/*
oSection2:Cell("B1_POSIPI"):SetValue((cAliasTop)->B1_POSIPI)
*/
dbSelectArea("SB2")
MsSeek(xFilial("SB2")+(cAliasTop)->PRODUTO+If(lCusUnif,"",mv_par08))

//oSection1:PrintLine()
//oSection2:PrintLine()

RestArea(aArea)

RETURN


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �MTR910IsMNT� Autor � Lucas                � Data � 03.10.06 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Verifica se h� integra��o com o modulo SigaMNT/NG          ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � MATR910                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function MTR910IsMNT()
Local aArea     := {}
Local aAreaSB1  := {}
Local aProdsMNT := {}
Local nX        := 0
Local lIntegrMNT:= .F.

//Esta funcao encontra-se no modulo Manutencao de Ativos (NGUTIL05.PRX), e retorna os produtos (pode ser MAIS de UM), dos parametros de
//Manutencao - "M" (MV_PRODMNT) / Terceiro - "T" (MV_PRODTER) / ou Ambos - "*" ou em branco
aProdsMNT := aClone(NGProdMNT("M"))
If Len(aProdsMNT) > 0
	aArea	 := GetArea()
	aAreaSB1 := SB1->(GetArea())
	SB1->(dbSelectArea( "SB1" ))
	SB1->(dbSetOrder(1))
	For nX := 1 To Len(aProdsMNT)
		If SB1->(dbSeek( xFilial("SB1") + aProdsMNT[nX] ))
			lIntegrMNT := .T.
			Exit
		EndIf 
	Next nX
	RestArea(aAreaSB1)
	RestArea(aArea)
EndIf
Return( lIntegrMNT )