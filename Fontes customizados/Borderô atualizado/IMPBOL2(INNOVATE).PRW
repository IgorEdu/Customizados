#include 'protheus.ch'
#INCLUDE "FWPrintSetup.ch"
#INCLUDE "rptDef.ch"
Static lBorDia := .T. //1 numero de Bordero por dia
/************************************************************************
	Seleciona os titulos, para impressão do Bordero 
	Programador: Mario Araujo Oliveira  -  INNOVATE           25/10/17
*************************************************************************/
User Function IMPBOL2()
Local aArea     := GetArea()
Local lConti    := .T.
Local bOK       := {||(lConti:= .T.,Odlg:End()) }
Local bCanc     := {||(lConti:= .F.,Odlg:End()) }
Local nI        := 1
Local cBancHab  := SuperGetMv("MV_BANCBOL",,"001/104/237/341/748")
Private cPerg   := "IMPBOL"
Private cAlias  := GetNextAlias()
Private aCampos := {"E1_PREFIXO","E1_NUM","E1_PARCELA","E1_CLIENTE","E1_LOJA","A1_NREDUZ","E1_NUMBOR"}
Private aBrowse := {}
Private cMark   := GetMark()
Private dDataIni
Private dDataFin
Private cPrefIni
Private cPrefFin
Private cNumIni 
Private cNumFin 
Private cParcIni
Private cParcFin
Private cBanco     
Private cAgencia   
Private cConta     
Private nComBor

aadd(aBrowse,{"OK" ,,"" })
For nI:=1 to len(aCampos)
	aadd(aBrowse,{aCampos[nI],,Avsx3(aCampos[nI],5)})
Next nI

CriaTemp()
//AjustaSX1()

If Pergunte(cPerg,.T.)
	cBanco   := AvKey(MV_PAR01,"A6_COD"    )
	cAgencia := AvKey(MV_PAR02,"A6_AGENCIA")
	cConta   := AvKey(MV_PAR03,"A6_NUMCON" )
	dDataIni := MV_PAR04
	dDataFin := MV_PAR05
	cPrefIni := MV_PAR06
	cPrefFin := MV_PAR07
	cNumIni  := MV_PAR08
	cNumFin  := MV_PAR09
	cParcIni := MV_PAR10
	cParcFin := MV_PAR11
	nComBor  := MV_PAR12
	
	If Empty(cBanco) .or. Empty(cAgencia) .or. Empty(cConta)
		lConti := .F.
		Aviso("Atenção","Os campos BANCO, AGENCIA, CONTA são obrigatorio! Operação Cancelada!",{"OK"})
	EndIF   	
	If !(AllTrim(cBanco) $ cBancHab)
		lConti := .F.
		Aviso("Atenção","Para o banco "+cBanco+" não está disponivel a emissão de Boletos!",{"OK"})
	EndIF 
	
	
	IF lConti 
		lConti := .F.
		Processa({|| CarregDad() },"Aguarde","Carregando dados..")
				
		DEFINE MSDIALOG oDlg TITLE "..:: Emissão Boletos ::.." FROM 000, 000 TO 350,800 PIXEL
		oBrw := MsSelect():New(((cAlias)),"OK","",aBrowse,,@cMark,{030,010,170,390},,,,,)
		oBrw:bMark := {| | Marca()} 
		ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg, bOK , bCanc,,)
				
		If lConti
			Processa({|| GeraBor() },"Aguarde","Gerando Bordero")
		EndIF
	EndIF 	
EndIF 

RestArea(aArea)

Return
/************************************************************************/
Static Function Marca()
If RecLock((cAlias),.F.)
	If Marked("OK")
		(cAlias)->OK := cMark
	Else
		(cAlias)->OK := Space(2)
	EndIF 
EndIF
oBrw:oBrowse:Refresh()
Return
/***********************************************************************
	PROTHEUS 12 não aceita criar perguntas pelo fonte 
**********************************************************************
Static Function AjustaSX1()
Local aHelpPor01 := {"Data de emissão de / até"}
Local aHelpPor02 := {"Prefixo de / até"}
Local aHelpPor03 := {"Numero de / até"}
Local aHelpPor04 := {"Bordero de / até"}
Local aHelpPor05 := {"Loja de / até"}
Local aRegs :={}

aAdd(aRegs,{cPerg,'01','Data de:     ?','','','mv_ch1','D',Avsx3("D1_DTDIGIT",3)   , 0, 0,'G','','   ','','','mv_par01','','','','','','','','','','','','','','','','',aHelpPor01,aHelpPor01,aHelpPor01})
aAdd(aRegs,{cPerg,'02','Data ate:    ?','','','mv_ch2','D',Avsx3("D1_DTDIGIT",3)   , 0, 0,'G','','   ','','','mv_par02','','','','','','','','','','','','','','','','',aHelpPor01,aHelpPor01,aHelpPor01})
aAdd(aRegs,{cPerg,'03','Prefixo de : ?','','','mv_ch3','C',Avsx3("E1_PREFIXO",3)   , 0, 0,'G','','   ','','','mv_par03','','','','','','','','','','','','','','','','',aHelpPor02,aHelpPor02,aHelpPor02})
aAdd(aRegs,{cPerg,'04','Prefixo até: ?','','','mv_ch4','C',Avsx3("E1_PREFIXO",3)   , 0, 0,'G','','   ','','','mv_par04','','','','','','','','','','','','','','','','',aHelpPor02,aHelpPor02,aHelpPor02})
aAdd(aRegs,{cPerg,'05','Numero de:   ?','','','mv_ch5','C',Avsx3("E1_NUM",3)       , 0, 0,'G','','   ','','','mv_par05','','','','','','','','','','','','','','','','',aHelpPor03,aHelpPor03,aHelpPor03})
aAdd(aRegs,{cPerg,'06','Numero até:  ?','','','mv_ch6','C',Avsx3("E1_NUM",3)       , 0, 0,'G','','   ','','','mv_par06','','','','','','','','','','','','','','','','',aHelpPor03,aHelpPor03,aHelpPor03})
aAdd(aRegs,{cPerg,'07','Parcela de:  ?','','','mv_ch7','C',Avsx3("E1_PARCELA",3)   , 0, 0,'G','','   ','','','mv_par07','','','','','','','','','','','','','','','','',aHelpPor05,aHelpPor05,aHelpPor05})
aAdd(aRegs,{cPerg,'08','Parcela até: ?','','','mv_ch8','C',Avsx3("E1_PARCELA",3)   , 0, 0,'G','','   ','','','mv_par08','','','','','','','','','','','','','','','','',aHelpPor05,aHelpPor05,aHelpPor05})
aAdd(aRegs,{cPerg,'09','Bordero de:  ?','','','mv_ch9','C',Avsx3("E1_NUMBOR",3)    , 0, 0,'G','','   ','','','mv_par09','','','','','','','','','','','','','','','','',aHelpPor04,aHelpPor04,aHelpPor04})
aAdd(aRegs,{cPerg,'10','Bordero até: ?','','','mv_chA','C',Avsx3("E1_NUMBOR",3)    , 0, 0,'G','','   ','','','mv_par10','','','','','','','','','','','','','','','','',aHelpPor04,aHelpPor04,aHelpPor04})

//putSx1(cPerg,'03','Filtro       ','','' ,'MV_CH3','C',2                         , 0, 1,'C','',''   ,'','','MV_PAR03',"01-Todas","","","","02-Somente Protheus","","","03-Somente PCF","","","04-Exis.Ambas","","",'','','',aHelpPor03,aHelpPor03,aHelpPor03)
//putSx1(cPerg,'04','Tipo NFs     ','','' ,'MV_CH4','C',2                         , 0, 1,'C','',''   ,'','','MV_PAR04',"01-NF Entrada","","","","02-NF Saída","","","","","","","","",'','','',aHelpPor03,aHelpPor03,aHelpPor03)
ValidPerg( aRegs, cPerg, .T.) // Incluir perguntas 

Return */
/***********************************************************************
	Cria o arquivo temporario 
***********************************************************************/
Static Function CriaTemp()
Local nI := 1
Local aStrut := {}
Local _cArqEmp

If Select((cAlias)) > 0
	(cAlias)->(DbCloseArea())
Endif
				
// Estrutura do arquivo temporario
aadd(aStrut,{"OK" ,"C",2,0})
For nI:=1 to len(aCampos)
	aadd(aStrut,{aCampos[nI] ,AvSx3(aCampos[nI],2),AvSx3(aCampos[nI],3),AvSx3(aCampos[nI],4)})
Next nI
_cArqEmp := CriaTrab(aStrut)
dbUseArea(.T.,__LocalDriver,_cArqEmp,(cAlias))

Return
/***********************************************************************
	Carrega os dados no arquivo temporario
***********************************************************************/
Static Function CarregDad()
Local cAliasA := GetNextAlias()
Local cConsul :=""
Local nI := 1
Local cWhere := ""

//Considera os tirulo com Bordero Não/SIM
If nComBor == 1
	cWhere += " AND E1_NUMBOR = '' "
	cWhere += " AND E1_SITUACA = '0' "
ElseIF nComBor == 2
	cWhere += " AND E1_NUMBOR <> '' "
	cWhere += " AND E1_SITUACA <> '0' "
	cWhere += " AND E1_PORTADO = '"+ cBanco+"' "
	cWhere += " AND E1_EMITBOL = 'S' " 
EndIF 
cWhere := "%"+cWhere+"%"

For nI:=1 to len(aCampos)
	IF !Empty(cConsul)
		cConsul+=" , "
	EndIF 
	cConsul += aCampos[nI]
Next nI
cConsul := "%"+cConsul+"%"

BeginSql alias cAliasA
	Select %Exp:cConsul%
	From %Table:SE1% 
	Inner Join  %Table:SA1% on 
		A1_FILIAL = %Exp:xFilial("SA1")%
		and A1_COD = E1_CLIENTE
		AND A1_LOJA = E1_LOJA
		AND A1_EST <> 'EX'
		AND %Table:SA1%.%NotDel%
	Where E1_FILIAL = %Exp:xFilial("SE1")%
	and E1_EMISSAO BETWEEN  %Exp:dDataIni% AND %Exp:dDataFin%
	AND E1_PREFIXO  BETWEEN  %Exp:cPrefIni% AND %Exp:cPrefFin%
	AND E1_NUM BETWEEN %Exp:cNumIni% AND %Exp:cNumFin%
	AND E1_PARCELA BETWEEN %Exp:cParcIni% AND %Exp:cParcFin%
	AND E1_SALDO > 0
	AND E1_BAIXA = ''
	%Exp:cWhere%
	AND %Table:SE1%.%NotDel%
    ORDER BY A1_COD,A1_LOJA
EndSQl

While (cAliasA)->(!Eof())
	IF RecLock((cAlias),.T.)
		For nI:=1 to len(aCampos)
			&((cAlias)+"->"+aCampos[nI]) := &((cAliasA)+"->"+aCampos[nI])
		Next nI
		(cAlias)->(MsUnLock())
	EndIF 
	(cAliasA)->(DbSkip())
End

IF Select((cAliasA)) >0 
	(cAliasA)->(DbCloseArea())
EndIF 

(cAlias)->(DbGoTop())

Return
/***********************************************************************
	Gera o Bordero com os Titulos selecionados
***********************************************************************/
Static Function GeraBor() 
Local cSituacao := "1"
Local cNumBord  := NumBor() //StrZero(Val(Soma1(GetMV("MV_NUMBORR"),6)), AvSx3("E1_NUMBOR",3))
Local cChave    := ""
Local lIMPBOL   := .F.
Local lInc      := .F.
Local lCont     := .T.
Local aImpBol   := {}
Local cSituAnt  := ""

DbSelectArea("SE1")
SE1->(DbSetOrder(2))

DbSelectArea("SEE")
SEE->(DbSetOrder(1))
If SEE->(!DbSeek(xFilial("SEE")+cBanco+cAgencia+cConta))
	Aviso("Atenção","Não foi localizado os parametros do banco!",{"OK"})
	lCont := .F.
EndIF 

(cAlias)->(DbGoTop())

IF lCont
	Begin Transaction
		While (cAlias)->(!Eof())
			If (cAlias)->OK == cMark
				IncProc('Impressão dos Boletos banco ')
				ProcessMessage()
				If Empty((cAlias)->E1_NUMBOR)
					cChave := xFilial("SE1")+(cAlias)->(E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM+E1_PARCELA)
					IF SE1->(DbSeek(cChave))
						lIMPBOL := .T.
						lInc    := .T.
						cSituAnt := ""
						IF aScan(aImpBol,{|X| X[1] == cNumBord  .and. X[2] == (cAlias)->E1_NUM  .and. X[3] == (cAlias)->E1_PARCELA }) <= 0
							aAdd(aImpBol,{cNumBord,(cAlias)->E1_NUM,(cAlias)->E1_PARCELA })
						EndIF 
						if RecLock("SEE",.F.)
							SEE->EE_FAXATU := StrZero(Val(SEE->EE_FAXATU)+1,IIF(len(alltrim(SEE->EE_CODEMP)) >= 7,10,5))
							SEE->(MsUnLock())
						EndIF 
						If RecLock("SE1",.F.)
							cSituAnt := SE1->E1_SITUACA 
							SE1->E1_PORTADO	:= cBanco
							SE1->E1_AGEDEP	:= cAgencia
							SE1->E1_CONTA	:= cConta
							SE1->E1_SITUACA	:= cSituacao
							SE1->E1_NUMBOR	:= cNumBord
							SE1->E1_DATABOR	:= dDataBase
							SE1->E1_MOVIMEN	:= dDataBase
							SE1->E1_NUMBCO  := SEE->EE_FAXATU 
							SE1->(MsUnlock())
						EndIF 
						IF RecLock("SEA",.T.)
							SEA->EA_FILIAL  := xFilial("SEA")
							SEA->EA_PREFIXO := SE1->E1_PREFIXO
							SEA->EA_NUM     := SE1->E1_NUM
							SEA->EA_PARCELA := SE1->E1_PARCELA
							SEA->EA_TIPO    := SE1->E1_TIPO
							SEA->EA_FILORIG := SE1->E1_FILORIG
							SEA->EA_PORTADO := cBanco
							SEA->EA_AGEDEP  := cAgencia
							SEA->EA_NUMCON  := cConta
							SEA->EA_NUMBOR  := cNumBord
							SEA->EA_DATABOR := dDataBase
							SEA->EA_CART    := 'R'
							SEA->EA_SITUACA := cSituacao
							SEA->EA_SITUANT := cSituAnt
							SEA->EA_ORIGEM  := "IMPBOL"
							SEA->(MsUnLock())
						EndIF
					EndIF
				Else
					lIMPBOL:= .T.
					IF aScan(aImpBol,{|X| X[1]==(cAlias)->E1_NUMBOR  .and. X[2]==(cAlias)->E1_NUM  .and. X[3]==(cAlias)->E1_PARCELA }) <= 0
						aAdd(aImpBol,{(cAlias)->E1_NUMBOR,(cAlias)->E1_NUM,(cAlias)->E1_PARCELA})
					EndIF 
				EndIF 
			EndIF 
			(cAlias)->(DbSkip())
		End
		If lInc
			PutMV("MV_NUMBORR", cNumBord)
			Aviso("Bordero","Foi gerado Borderô numero: "+cNumBord,{"OK"})
		EndIF
	End Transaction
EndIF 

If lIMPBOL
	IncProc('Impressão dos Boletos banco:'+cBanco)
	ProcessMessage()
	IMPBOL_A(aImpBol)
EndIF

Return
/***********************************************************************
	Efetua a impressão 
	aDados[x,1] = Numero Bordero
	aDados[x,2] = Numero titulo
	aDados[x,3] = parcela
***********************************************************************/
Static Function IMPBOL_A(aDados)
Local cNomeRel  := ""		  	//Nome do relatório   
Local lAtoL		:= .F.		  	//Ajusta o relatório nas proporções
Local lDs		:= .F.		  	//Disable setup
Local cLocal    := "\spool"   	//Local de impressao
Local cALiasA   := GetNextAlias()
Local nZ        := 0
Local cWhere    := ""
Private nI		:= 0			//Contador 
Private oBoleto := Nil		  	//Objeto de impressão  
				
//Define o nome do relatório
cNomeRel := "Boleto-" + Dtos(Date()) + StrTran(Time(), ":", "")
oBoleto := FWMSPrinter():New(cNomeRel, IMP_PDF, lAtoL, cLocal, lDS, , , , , , .F., )
oBoleto:SetPortrait()   
oBoleto:SetPaperSize(9) 

DbSelectArea("SA1")
DbSelectArea("SA6")
DbSelectArea("SEE")
DbSelectArea("SE1")

For nZ :=1 to len(aDados)
	If Select((cAliasA)) > 0
		(cAliasA)->(DbCloseArea())
	EndIF 
	IncProc('Impressão dos Boletos banco:'+cBanco +" Titulo:"+aDados[nZ,2])
	ProcessMessage()
	cWhere := " and SE1.E1_NUMBOR   = '"+ aDados[nZ,1] +"' "
	IF !Empty(AllTrim(aDados[nZ,2]))
		cWhere += " and SE1.E1_NUM = '"+ aDados[nZ,2] +"' "
	EndIF 
	IF !Empty(AllTrim(aDados[nZ,3]))
		cWhere += " and SE1.E1_PARCELA = '"+ aDados[nZ,3] +"' "
	EndIF 
	cWhere := "%"+cWhere+"%"
	
	//Busca dados 
	BeginSql Alias cAliasA
		Select SE1.R_E_C_N_O_ as E1REC
		,SA6.R_E_C_N_O_ as A6REC
		,SEE.R_E_C_N_O_ as EEREC
		,SA1.R_E_C_N_O_ as A1REC
		From %Table:SE1% as SE1 
		INNER JOIN %Table:SA6% as SA6 on 
			SA6.A6_FILIAL      = %Exp:xFilial('SA6')%
			and SA6.A6_COD     = SE1.E1_PORTADO
			and SA6.A6_AGENCIA = SE1.E1_AGEDEP
			and SA6.A6_NUMCON  = SE1.E1_CONTA
			AND SA6.%NOTDEL%
		INNER JOIN %Table:SA1% as SA1 on
		 	SA1.A1_FILIAL = %Exp:xFilial('SA1')%
		 	AND SA1.A1_COD    = SE1.E1_CLIENTE
		 	AND SA1.A1_LOJA   = SE1.E1_LOJA
		 	AND SA1.%NOTDEL%
		INNER JOIN %Table:SEE% as SEE on
			SEE.EE_FILIAL      = %Exp:xFilial('SEE')%
			AND SEE.EE_CODIGO  = SE1.E1_PORTADO
			AND SEE.EE_AGENCIA = SE1.E1_AGEDEP
			AND SEE.EE_CONTA   = SE1.E1_CONTA
			AND SEE.%NOTDEL%
		Where SE1.E1_FILIAL = %Exp:xFilial('SE1')%
		AND SE1.D_E_L_E_T_ = ''
		%Exp:cWhere%
	EndSql
		
	//Loop na query
	IF (cAliasA)->(Eof())
		Aviso("Atenção","Registros não localizados para o Bordero "+ cNumBord,{"OK"})
	Else
		While (cAliasA)->(!Eof())
			SE1->(DbGoTo((cAliasA)->E1REC))
			SEE->(DbGoTo((cAliasA)->EEREC))
			SA6->(DbGoTo((cAliasA)->A6REC))
			SA1->(DbGoTo((cAliasA)->A1REC))
			
			If SE1->(FieldPos("E1_EMITBOL")) > 0
				IF Alltrim(SE1->E1_EMITBOL) <> "S"
					IF RecLock("SE1",.F.)
						SE1->E1_EMITBOL := "S"
						SE1->(MsUnLock())
					EndIF
				EndIF 
			EndIF 
			
			Do Case  
				Case (SA6->A6_COD == "001") //Banco Brasil			
					If ExistBlock("RBol001")
						U_RBol001(oBoleto)
					Else
						Aviso("Atenção","Função de boleto não compilada! RBol001()",{"OK"})
					EndIF  
				Case (SA6->A6_COD == "237") //Banco Bradesco				
					If ExistBlock("RBol237")
						U_RBol237(oBoleto)
					Else
						Aviso("Atenção","Função de boleto não compilada! RBol237()",{"OK"})
					EndIF 
				Case (SA6->A6_COD == "341") //Banco Itau	 		
					If ExistBlock("RBol341")
						U_RBol341(oBoleto)
					Else
						Aviso("Atenção","Função de boleto não compilada! RBol341()",{"OK"})
					EndIF 
				Case (SA6->A6_COD == "748") //Sicredi
					If ExistBlock("RBol748")
						U_RBol748(oBoleto)
					Else
						Aviso("Atenção","Função de boleto não compilada! RBol748()",{"OK"})
					EndIF
				Case (SA6->A6_COD == "104") //Caixa Economica
					If ExistBlock("RBol104")
						U_RBol104(oBoleto)
					Else
						Aviso("Atenção","Função de boleto não compilada! RBol104()",{"OK"})
					EndIF  
			EndCase
			(cAliasA)->(DbSkip()) 
		End  
	EndIF 
Next nZ

IncProc('Finalizando.. ')
ProcessMessage()
//Verifica se houve impressao
If (oBoleto:nModalResult == PD_OK)
	  //Verifica se foi cancelado                         
	  If !(oBoleto:Canceled()) 
			//Visualiza
			oBoleto:Preview()
 	EndIf
EndIf       
//Descarrega spool
Ms_Flush()
Return
/***********************************************************************
	Retorna numero bordero.
***********************************************************************/
Static Function NumBor()
Local cRet   := ""
Local cAlias := GetNextAlias()
Local aArea  := GetArea()
IF lBorDia
	BeginSql alias cAlias
		Select Max(EA_NUMBOR) EA_NUMBOR
		From %Table:SEA%
		Where %NotDel%
		and EA_FILIAL = %Exp:xFilial("SEA")%
		And EA_DATABOR = %Exp:dDataBase%
	EndSql
	IF (cAlias)->(!Eof())
		cRet := (cAlias)->EA_NUMBOR
	Else
		cRet := StrZero(Val(Soma1(GetMV("MV_NUMBORR"),6)), AvSx3("E1_NUMBOR",3))
	EndIF 
Else
	cRet := StrZero(Val(Soma1(GetMV("MV_NUMBORR"),6)), AvSx3("E1_NUMBOR",3))
EndIF 
If Select((cAlias)) > 0
	(cAlias)->(DbCloseArea())
EndIF 
RestArea(aArea)
Return cRet
/***********************************************************************
	Geração de boletos no final da emissão da NFe
***********************************************************************/
User Function ImpBol2A()
Local cChave     := SF2->F2_FILIAL + SF2->F2_CLIENTE + SF2->F2_LOJA+ SF2->F2_PREFIXO + SF2->F2_DOC 
Local aDados     := {}
Local lCont      := .T.
Local lInc       := .F.
Local cSituAnt
Local cSituacao  := "1"
Local cNumBord   := NumBor() 
Private cPerg    := "IMPBOL"
Private dDataIni
Private dDataFin
Private cPrefIni
Private cPrefFin
Private cNumIni 
Private cNumFin 
Private cParcIni
Private cParcFin
Private cBanco     
Private cAgencia   
Private cConta     
Private nComBor

If Pergunte(cPerg,.T.)
	cBanco   := AvKey(MV_PAR01,"A6_COD"    )
	cAgencia := AvKey(MV_PAR02,"A6_AGENCIA")
	cConta   := AvKey(MV_PAR03,"A6_NUMCON" )
	dDataIni := MV_PAR04
	dDataFin := MV_PAR05
	cPrefIni := MV_PAR06
	cPrefFin := MV_PAR07
	cNumIni  := MV_PAR08
	cNumFin  := MV_PAR09
	cParcIni := MV_PAR10
	cParcFin := MV_PAR11
	nComBor  := MV_PAR12
	DbSelectArea("SEE")
	SEE->(DbSetOrder(1))
	If SEE->(!DbSeek(xFilial("SEE")+cBanco+cAgencia+cConta))
		Aviso("Atenção","Não foi localizado os parametros do banco!",{"OK"})
		lCont := .F.
	EndIF
	IF lCont
		DbSelectArea("SE1")
		SE1->(DbSetOrder(2))
		IF SE1->(DbSeek(cChave))
			Begin Transaction
				While SE1->(!Eof()) .and. SE1->(E1_FILIAL + E1_CLIENTE + E1_LOJA + E1_PREFIXO + E1_NUM) == cChave
					lInc    := .T.
					cSituAnt := ""
					If Empty(SE1->E1_NUMBOR)	
						if RecLock("SEE",.F.)
							SEE->EE_FAXATU := StrZero(Val(SEE->EE_FAXATU)+1,IIF(len(alltrim(SEE->EE_CODEMP)) >= 7,10,5))
							SEE->(MsUnLock())
						EndIF 
						If RecLock("SE1",.F.)
							cSituAnt := SE1->E1_SITUACA 
							SE1->E1_PORTADO	:= cBanco
							SE1->E1_AGEDEP	:= cAgencia
							SE1->E1_CONTA	:= cConta
							SE1->E1_SITUACA	:= cSituacao
							SE1->E1_NUMBOR	:= cNumBord
							SE1->E1_DATABOR	:= dDataBase
							SE1->E1_MOVIMEN	:= dDataBase
							SE1->E1_NUMBCO  := SEE->EE_FAXATU 
							SE1->(MsUnlock())
						EndIF 
						IF RecLock("SEA",.T.)
							SEA->EA_FILIAL  := xFilial("SEA")
							SEA->EA_PREFIXO := SE1->E1_PREFIXO
							SEA->EA_NUM     := SE1->E1_NUM
							SEA->EA_PARCELA := SE1->E1_PARCELA
							SEA->EA_TIPO    := SE1->E1_TIPO
							SEA->EA_FILORIG := SE1->E1_FILORIG
							SEA->EA_PORTADO := cBanco
							SEA->EA_AGEDEP  := cAgencia
							SEA->EA_NUMCON  := cConta
							SEA->EA_NUMBOR  := cNumBord
							SEA->EA_DATABOR := dDataBase
							SEA->EA_CART    := 'R'
							SEA->EA_SITUACA := cSituacao
							SEA->EA_SITUANT := cSituAnt
							SEA->EA_ORIGEM  := "IMPBOL"
							SEA->(MsUnLock())
						EndIF
					EndIF
					IF aScan(aDados,{|X| X[1] == cNumBord  .and. X[2] == SE1->E1_NUM  .and. X[3] == SE1->E1_PARCELA }) <= 0
						aAdd(aDados,{cNumBord,SE1->E1_NUM,SE1->E1_PARCELA}) 
					EndIF 
					SE1->(DbSkip()) 
				End
			End Transaction
			If lInc
				PutMV("MV_NUMBORR", cNumBord)
				Aviso("Bordero","Foi gerado Borderô numero: "+cNumBord,{"OK"})
				IncProc('Impressão dos Boletos banco:'+cBanco)
				ProcessMessage()
				IMPBOL_A(aDados)
			EndIf
		EndIF 
	EndIF 
EndIF 

Return