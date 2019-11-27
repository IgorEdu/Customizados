#include 'protheus.ch'
#define __codBanco "104"                                                                                                                      
#define __nomBanco "Caixa Economica Federal"
#define nLarg  (605-35)
#define nAlt   842
/***********************************************************************************
	Fonte para emissão do Boleto do banco Caixa Economica Federeal 
*************************************************************************************/
User Function RBol104(oBoleto)
	Local nBloco1 := 0
	Local nBloco2 := 0
	Local nBloco3 := 0
	Local nPont
	Private oArial06  := TFont():New('Arial',06,06,,.F.,,,,.T.,.F.,.F.)
	Private oArial09N := TFont():New('Arial',10,10,,.T.,,,,.T.,.F.,.F.)
	Private oArial12N := TFont():New('Arial',12,12,,.T.,,,,.T.,.F.,.F.)
	Private oArial14  := TFont():New('Arial',16,16,,.F.,,,,.T.,.F.,.F.)
	Private oArial18N := TFont():New('Arial',21,21,,.T.,,,,.T.,.F.,.F.)
	Private aMensagens := {"","","",""}
		
	//calcula o valor dos abatimentos
	Private nValorAbatimentos := SomaAbat(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,"R",1,,SE1->E1_CLIENTE,SE1->E1_LOJA)
	//calculo valor total
	Private nValorDocumento := Round((((SE1->E1_SALDO+SE1->E1_ACRESC)-SE1->E1_DECRESC)*100)-(nValorAbatimentos*100),0)/100
	//nosso numero
	Private cNossoNumero := U_RBOL104A(SEE->EE_TPCOBRA) //mODALIDADE COBRANÇA 
	 
	//codigo de barras
	Private cCodigoBarra := BolCodBar()
	Private cLinhaDigitavel := BolLinhaDigitavel()
	Private lEnderecoCobranca := !Empty(SA1->A1_ENDCOB) .and. !Empty(SA1->A1_BAIRROC) .and. !Empty(SA1->A1_MUNC) .and. !Empty(SA1->A1_ESTC) .and. !Empty(SA1->A1_CEPC)
	
	//inicia pagina
	oBoleto:StartPage()

	//Nome do Banco
	oBoleto:Say(nBloco1+33,25,"CAIXA",oArial12N )
	//logo
	oBoleto:SayBitmap(nBloco1+20, 20, "\system\logo-banco-104.jpg", 75, 20)
	//Line(linha_inicial, coluna_inicial, linha final, coluna final)
	oBoleto:Line( nBloco1+20,  96, nBloco1+40,  96,,"01")
	oBoleto:Line( nBloco1+20, 146, nBloco1+40, 146,,"01")

	//Numero do Banco
	oBoleto:Say(nBloco1+35,99,"104-0", oArial18N )

	//adiciona mais dois ao depois
	nBloco1 += 3

	oBoleto:Say(nBloco1+33,455,"Comprovante de Entrega",oArial09N)

	//nome da empresa
	oBoleto:Say(nBloco1+43,25 ,"Beneficiário",oArial06)
	oBoleto:Say(nBloco1+50,25 ,substr(alltrim(SM0->M0_NOMECOM),1,47),oArial09N)
	oBoleto:Say(nBloco1+60,25 ,alltrim(SM0->M0_ENDCOB),oArial09N)

	oBoleto:Say(nBloco1+45,250,"Agência/Código Beneficiário",oArial06)
	oBoleto:Say(nBloco1+57,250,AllTrim(SEE->EE_AGENCIA)+"/"+Alltrim(SEE->EE_CODEMP)+"-"+MODULO11(Alltrim(SEE->EE_CODEMP),2,7) ,oArial09N)

	oBoleto:Say(nBloco1+45,350,"Nro. Documento",oArial06)
	oBoleto:Say(nBloco1+57,350,SE1->E1_PREFIXO+alltrim(SE1->E1_NUM)+" / "+alltrim(SE1->E1_PARCELA) ,oArial09N) //Prefixo +Numero+Parcela

	oBoleto:Say(nBloco1+70,25,"Sacado",oArial06)
	oBoleto:Say(nBloco1+82,25,SA1->A1_NOME ,oArial09N)				//Nome

	oBoleto:Say(nBloco1+70,250,"Vencimento",oArial06)
	oBoleto:Say(nBloco1+82,250, FormDate(SE1->E1_VENCTO),oArial09N)

	oBoleto:Say(nBloco1+70,350,"Valor do Documento",oArial06)
	oBoleto:Say(nBloco1+82,350,Transform(nValorDocumento,"@E 999,999,999.99"),oArial09N)

	oBoleto:Say(nBloco1+105,25,"Recebi(emos) o bloqueto/título",oArial09N)
	oBoleto:Say(nBloco1+117,25,"com as características acima.",oArial09N)

	oBoleto:Say(nBloco1+95,250,"Data",oArial06)
	oBoleto:Say(nBloco1+95,330,"Assinatura",oArial06)

	oBoleto:Say(nBloco1+120,250,"Data",oArial06)
	oBoleto:Say(nBloco1+120,330,"Entregador",oArial06)

	oBoleto:Say(nBloco1+ 50,455,"(  ) Mudou-se"                 ,oArial06)
	oBoleto:Say(nBloco1+ 60,455,"(  ) Ausente"                  ,oArial06)
	oBoleto:Say(nBloco1+ 70,455,"(  ) Não existe nº indicado"   ,oArial06)
	oBoleto:Say(nBloco1+ 80,455,"(  ) Recusado"                 ,oArial06)
	oBoleto:Say(nBloco1+ 90,455,"(  ) Não procurado"            ,oArial06)
	oBoleto:Say(nBloco1+100,455,"(  ) Endereço insuficiente"    ,oArial06)
	oBoleto:Say(nBloco1+110,455,"(  ) Desconhecido"             ,oArial06)
	oBoleto:Say(nBloco1+120,455,"(  ) Falecido"                 ,oArial06)
	oBoleto:Say(nBloco1+130,455,"(  ) Outros (anotar no verso)"  ,oArial06)

	//linhas horizontais
	oBoleto:Line(nBloco1+ 37,  20,nBloco1+ 37,nLarg,,"01")
	oBoleto:Line(nBloco1+ 62,  20,nBloco1+ 62, 450 ,,"01")
	oBoleto:Line(nBloco1+ 87,  20,nBloco1+ 87, 450 ,,"01")
	oBoleto:Line(nBloco1+112, 247,nBloco1+112, 450 ,,"01")
	oBoleto:Line(nBloco1+137,  20,nBloco1+137,nLarg ,,"01")

	//linhas vericais
	oBoleto:Line(nBloco1+ 37,247,nBloco1+137,247 ,,"01")
	oBoleto:Line(nBloco1+ 87,327,nBloco1+137,327 ,,"01")
	oBoleto:Line(nBloco1+ 37,347,nBloco1+ 87,347 ,,"01")
	oBoleto:Line(nBloco1+ 37,450,nBloco1+137,450 ,,"01")

	//ajuste fino
	nBloco2 += 5
	//Pontilhado separador
	For nPont := 10 to nLarg+10 Step 4
		oBoleto:Line(nBloco2+147, nPont,nBloco2+147, nPont+2,,)
	Next nPont

	//Nome do Banco
	oBoleto:Say(nBloco2+170,25,"CAIXA",oArial12N )
	//logo
	oBoleto:SayBitmap(nBloco2+157, 20, "\system\logo-banco-104.jpg", 75, 20)
	//Line(linha_inicial, coluna_inicial, linha final, coluna final)
	oBoleto:Line( nBloco2+157,  96, nBloco2+177,  96,,"01")
	oBoleto:Line( nBloco2+157, 146, nBloco2+177, 146,,"01")
	oBoleto:Line( nBloco2+177,  20, nBloco2+177,nLarg,,"01")

	//Numero do Banco
	oBoleto:Say(nBloco2+174,99,"104-0",oArial18N )

	//adiciona mais dois ao depois
	nBloco1 += 3

	oBoleto:Say(nBloco2+174,420,"Recibo do Pagador",oArial09N)

	ImprimeBloco(oBoleto, nBloco2)

	//CODIGO DE BARRAS 
	
//	oBoleto:Say(nBloco+418, 25, "SAC CAIXA: 0800 726 0101 (informações, reclamações, sugestões e elogios)",oArial09N)
//    oBoleto:Say(nBloco+425, 25, "   Para pessoas com deficiência auditiva ou de fala: 0800 726 2492      ",oArial09N)
//    oBoleto:Say(nBloco+432, 25, "                    Ouvidoria: 0800 725 7474.                           ",oArial09N)
//    oBoleto:Say(nBloco+439, 25, "                         caixa.gov.br                                   ",oArial09N)
//	oBoleto:FWMSBAR("INT25" ,61,2.3, cCodigoBarra ,oBoleto,.F.,,.T.,0.02,1,.F.,"Arial",NIL,.F.,2,2,.F.)

	//BLOCO 3
	nBloco3 := 50
	//Pontilha do separador
	For nPont := 10 to nLarg+10 Step 4
		oBoleto:Line(nBloco3+400, nPont,nBloco3+400, nPont+2,,)
	Next nPont


	//Nome do Banco
	oBoleto:Say(nBloco3+413,25,"CAIXA",oArial12N )
	//logo
	oBoleto:SayBitmap(nBloco3+400, 20, "\system\logo-banco-104.jpg", 75, 20)
	//Line(linha_inicial, coluna_inicial, linha final, coluna final)
	oBoleto:Line( nBloco3+400,  95, nBloco3+420,  95,,"01")
	oBoleto:Line( nBloco3+400, 146, nBloco3+420, 146,,"01")
	oBoleto:Line( nBloco3+420,  20, nBloco3+420,nLarg,,"01")

	//Numero do Banco
	oBoleto:Say(nBloco3+417,99,"104-0",oArial18N )
	//linha digitavel
	oBoleto:SayAlign(nBloco3+405,155,cLinhaDigitavel,oArial14,400,,,1)

	ImprimeBloco(oBoleto, nBloco3 + 250 )
		
	//Finaliza pagina
	oBoleto:EndPage()
Return
/************************************************************************************/
Static Function ImprimeBloco(oBoleto, nBloco)

	//bloco 2 linha 1 ->
	oBoleto:Say(nBloco+185,25 ,"Local de Pagamento",oArial06)
	oBoleto:Say(nBloco+197,25 ,"PREFERENCIALMENTE NAS CASAS LOTÉRICAS ATÉ O VALOR LIMITE",oArial09N)

	oBoleto:Say(nBloco+185,425 ,"Vencimento",oArial06)
	oBoleto:SayAlign(nBloco+187,435,FormDate(SE1->E1_VENCTO),oArial09N,100,10,,1)

	//bloco 2 linha 2 ->
	oBoleto:Line( nBloco+202,  20, nBloco+202,nLarg,,"01")
	oBoleto:Say(nBloco+207,25 , "Beneficiário",oArial06)
	oBoleto:Say(nBloco+215,25 , SM0->M0_NOMECOM + " - CNPJ: " + transform(SM0->M0_CGC,"@R 99.999.999/9999-99") ,oArial09N)
	oBoleto:Say(nBloco+225,25 ,alltrim(SM0->M0_ENDCOB),oArial09N)

	oBoleto:Say(nBloco+210,425 ,"Agência/Código Beneficiário",oArial06)
	oBoleto:SayAlign(nBloco+212,435,AllTrim(SEE->EE_AGENCIA)+"/"+Alltrim(SEE->EE_CODEMP)+"-"+MODULO11(Alltrim(SEE->EE_CODEMP),2,9) ,oArial09N,100,10,,1)

	//bloco 2 linha 4 ->
	oBoleto:Line( nBloco+227,  20, nBloco+227,nLarg,,"01")
	oBoleto:Say(nBloco+233,25, "Data de Emissão" ,oArial06)
	oBoleto:Say(nBloco+243,25, FormDate(SE1->E1_EMISSAO), oArial09N)

	oBoleto:Line(nBloco+227, 110, nBloco+247,110,,"01")
	oBoleto:Say(nBloco+233,115, "Nro. Documento"                                  ,oArial06)
	oBoleto:Say(nBloco+243,115, SE1->E1_PREFIXO+alltrim(SE1->E1_NUM)+alltrim(SE1->E1_PARCELA) ,oArial09N)

	oBoleto:Line(nBloco+227, 232, nBloco+247,232,,"01")
	oBoleto:Say(nBloco+233,237, "Espécie Doc."                                   ,oArial06)
	oBoleto:Say(nBloco+243,237, "DM"										,oArial09N) //Tipo do Titulo

	oBoleto:Line(nBloco+227, 293, nBloco+247,293,,"01")
	oBoleto:Say(nBloco+233,298, "Aceite"                                         ,oArial06)
	oBoleto:Say(nBloco+243,298, "N"                                             ,oArial09N)

	oBoleto:Line(nBloco+227, 339, nBloco+247,339,,"01")
	oBoleto:Say(nBloco+233,344, "Data Processamento"                          ,oArial06)
	oBoleto:Say(nBloco+243,344, FormDate(dDataBase),oArial09N) // Data impressao

	oBoleto:Say(nBloco+233,425 ,"Carteira/Nosso Número",oArial06)
	oBoleto:SayAlign(nBloco+234,435,Transform(cNossoNumero,"@R 99999999999999999-9"),oArial09N,100,10,,1)

	//bloco 2 linha 5 ->
	oBoleto:Line( nBloco+247,  20, nBloco+247,nLarg,,"01")
	oBoleto:Say(nBloco+253,25,"Uso do Banco"                                   ,oArial06)
	oBoleto:Say(nBloco+263,25,""                                   ,oArial09N)

	oBoleto:Line(nBloco+247,80, nBloco+267,80,,"01")
	//oBoleto:Say(nBloco+253,85 ,"CIP"                                       ,oArial06)
	//oBoleto:Say(nBloco+263,85 ,"000"                                  	,oArial09N)

	oBoleto:Line(nBloco+247,110, nBloco+267,110,,"01")
	oBoleto:Say(nBloco+253,115 ,"Carteira"                                       ,oArial06)
	oBoleto:Say(nBloco+263,115 ,SEE->EE_CODCART                                	,oArial09N)

	oBoleto:Line(nBloco+247, 171, nBloco+267,171,,"01")
	oBoleto:Say(nBloco+253,176 ,"Espécie"                                        ,oArial06)
	oBoleto:Say(nBloco+263,176 ,"R$"                                             ,oArial09N)

	oBoleto:Line(nBloco+247, 232, nBloco+267,232,,"01")
	oBoleto:Say(nBloco+253,237,"Quantidade"                                     ,oArial06)
	oBoleto:Line(nBloco+247,339, nBloco+267,339,,"01")
	oBoleto:Say(nBloco+253,344,"Valor"                                          ,oArial06)

	oBoleto:Say(nBloco+253,425 ,"Valor do Documento",oArial06)
	oBoleto:SayAlign(nBloco+254,435,Transform(nValorDocumento,"@E 999,999,999.99"),oArial09N,100,10,,1)


	//bloco 2 linha 6 ->
	oBoleto:Line( nBloco+267,  20, nBloco+267,nLarg,,"01")
	oBoleto:Say( nBloco+273,25, "Instruções (INSTRUÇÕES DE RESPONSABILIDADE DO CEDENTE. QUALQUER DÚVIDA SOBRE ESTE BOLETO, CONTATE O CEDENTE.)" , oArial06)

	aMensagens[1] := AllTrim(StrTran(SEE->EE_FORMEN1,"'"," "))
	aMensagens[2] := AllTrim(StrTran(SEE->EE_FORMEN2,"'"," "))
	aMensagens[3] := AllTrim(StrTran(SEE->EE_FOREXT1,"'"," "))
	aMensagens[4] := AllTrim(StrTran(SEE->EE_FOREXT2,"'"," "))

	oBoleto:Say(nBloco+283,0025,aMensagens[1] ,oArial09N)
	oBoleto:Say(nBloco+293,0025,aMensagens[2] ,oArial09N)
	oBoleto:Say(nBloco+303,0025,aMensagens[3] ,oArial09N)
	oBoleto:Say(nBloco+313,0025,aMensagens[4] ,oArial09N)
	//oBoleto:Say(nBloco+50,0025,If(SE1->E1_TIPO=="FT ","FAT: "+Alltrim(SE1->E1_NUM),If(SE1->E1_TIPO=="CE ","CTE: "+Alltrim(SE1->E1_NUMNOTA),"")),oArial09N)
	
	oBoleto:Say(nBloco+273,425,"(-)Desconto/Abatimento",oArial06)

	//bloco 2 linha 7 ->
	oBoleto:Line( nBloco+287,  420, nBloco+287,nLarg,,"01")
	oBoleto:Say(nBloco+293,425,"(-)Outras Deduções",oArial06)

	//bloco 2 linha 8 ->
	oBoleto:Line( nBloco+307,  420, nBloco+307,nLarg,,"01")
	oBoleto:Say(nBloco+313,425,"(+)Mora/Multa/Juros",oArial06)

	//bloco 2 linha 9 ->
	oBoleto:Line( nBloco+327,  420, nBloco+327,nLarg,,"01")
	oBoleto:Say(nBloco+333,425,"(+)Outros Acréscimos",oArial06)

	//bloco 2 linha 10 ->
	oBoleto:Line( nBloco+347,  420, nBloco+347,nLarg,,"01")
	oBoleto:Say(nBloco+353,425,"(=)Valor Cobrado",oArial06)
	oBoleto:Line( nBloco+177,  420, nBloco+367,420,,"01")

	//bloco 2 Sacado ->
	oBoleto:Line( nBloco+367,  20, nBloco+367,nLarg,,"01")
	oBoleto:Say(nBloco+376,25 ,"Pagador",oArial06)
	oBoleto:Say(nBloco+376,90 ,alltrim(SA1->A1_NOME) + " (" +SA1->A1_COD+" - "+SA1->A1_LOJA+")",oArial09N)
	oBoleto:Say(nBloco+386,90 ,IIF(lEnderecoCobranca,SA1->A1_ENDCOB,SA1->A1_END) + " - " + IIF(lEnderecoCobranca,SA1->A1_BAIRROC,SA1->A1_BAIRRO) ,oArial09N)
	oBoleto:Say(nBloco+396,90 ,transform(IIF(lEnderecoCobranca,SA1->A1_CEPC,SA1->A1_CEP),"@R 99999-999")+ " - " + alltrim(IIF(lEnderecoCobranca,SA1->A1_MUNC,SA1->A1_MUN))+"/"+IIF(lEnderecoCobranca,SA1->A1_ESTC,SA1->A1_EST) ,oArial09N)
	IF SA1->A1_TIPO == "J"
		oBoleto:Say(nBloco+406,90 ,"CNPJ: " + transform(SA1->A1_CGC,"@R 99.999.999/9999-99") ,oArial09N)
	Else
		oBoleto:Say(nBloco+406,90 ,"CPF: " + transform(SA1->A1_CGC,"@R 999.999.999-99") ,oArial09N)
	EndIF
	oBoleto:Say(nBloco+406,430 ,cNossoNumero ,oArial09N)

	//bloco 2 Sacado - autenticação ->
	oBoleto:Say(nBloco+406, 25, "Pagador/Avalista" , oArial06)
	oBoleto:Line( nBloco+410,  20, nBloco+410,nLarg,,"01")
	oBoleto:Say(nBloco+416,420, "Autenticação Mecânica - Ficha de compensação" , oArial06)
        
    // bloco 2 - informacao
    
    oBoleto:Say(nBloco+418, 25, "SAC CAIXA: 0800 726 0101 (informações, reclamações, sugestões e elogios)",oArial09N)
    oBoleto:Say(nBloco+425, 25, "   Para pessoas com deficiência auditiva ou de fala: 0800 726 2492      ",oArial09N)
    oBoleto:Say(nBloco+432, 25, "                    Ouvidoria: 0800 725 7474.                           ",oArial09N)
    oBoleto:Say(nBloco+439, 25, "                         caixa.gov.br                                   ",oArial09N)

Return
/*******************************************************************/
User Function RBOL104A(_TpCart)
Local _cNum  := STRZERO(VAL(SE1->E1_NUMBCO),15)
Local _cDig
Local _cEmisBloq := "4" //4-Cedente //Particularidade CEF
Default _TpCart := "1"	

_cDig := BolDigitoBarra(_TpCart+_cEmisBloq+_cNum,"NOSSONUM")

Return _TpCart+_cEmisBloq+_cNum+_cDig
/******************************************************************
	MONTA O CODIGO DE BARRAS
	
	Posição	Tamanho	Picture	Conteúdo	Observação	
	01 – 03	  3	      9 (3)	Identificação do banco (104)		
	04 – 04	  1	      9	    Código da moeda (9 - Real)		
	05 – 05	  1	      9	    DV Geral do Código de Barras	Nota 2 / Anexo I	
	06 - 09	  4	      9	    Fator de Vencimento	Anexo II	
	10 - 19	  10      9 (8) V99	Valor do Documento		
	20 – 25	  6	      9 (6)	Código do Beneficiário		Campo Livre
	26 – 26	  1	      9 (1)	DV do Código do Beneficiário	Nota 3 / Anexo VI	
	27 – 29	  3	      9 (3)	Nosso Número - Seqüência 1	Nota 1	
	30 – 30	  1	      9 (1)	Constante 1	Nota 1	
	31 – 33	  3	      9 (3)	Nosso Número - Seqüência 2	Nota 1	
	34 – 34	  1	      9 (1)	Constante 2	Nota 1	
	35 – 43	  9	      9 (9)	Nosso Número - Seqüência 3	Nota 1	
	44 – 44	  1	      9 (1)	DV do Campo Livre	Nota 4 / Anexo III	
	
	NOTA 1 – NOSSO NÚMERO DO SIGCB:
	•	É composto de 17 posições, sendo as 02 posições iniciais para identificar a Carteira e a Entrega do Boleto, e as 15 posições restantes são para livre utilização pelo Beneficiário.
	•	Está disposto no Código de Barras da seguinte maneira:
	• Constante 1:	1ª posição do Nosso Numero - Tipo de Cobrança (1-Registrada / 2-Sem Registro)
	• Constante 2:	2ª posição do Nosso Número - Identificador de Emissão do Boleto (4-Beneficiário)
	• Seqüência 1:	3ª a 5ª posição do Nosso Número
	• Seqüência 2:	6ª a 8ª posição do Nosso Número
	• Seqüência 3:	9ª a 17ª posição do Nosso Número
	
	NOTA 2 – DV GERAL DO CÓDIGO DE BARRAS (posição 5):
	Calculado através do Modulo 11, conforme ANEXO I.
	ATENÇÃO: Não admite 0 (zero).
	
	NOTA 3 – DV DO CÓDIGO DO BENEFICIÁRIO (posição 26):
	Calculado através do Modulo 11, conforme ANEXO VI.
	ATENÇÃO: Admite 0 (zero), diferentemente do DV Geral do Código de Barras.
	
	NOTA 4 – DV DO CAMPO LIVRE (posição 44):
	Calculado através do Modulo 11, conforme ANEXO III.
	ATENÇÃO: Admite 0 (zero), diferentemente do DV Geral do Código de Barras.

******************************************************************************/
Static Function BolCodBar()
	Local cCodigo := ""
	Local dFator := CTOD("07/10/1997")
	
	// Pos 01 a 03 - Identificacao do Banco
	cCodigo += "104"
	// Pos 04 a 04 - Moeda
	cCodigo += "9"
	// POS 05 Digito verificado geral,
	
	// Pos 06 a 09 - Fator de vencimento
	cCodigo += Str((SE1->E1_VENCTO - dFator),4)
	// Pos 10 a 19 - Valor
	cCodigo += StrZero(Int(nValorDocumento*100),10)
	// Pos 20 a 25 - Codigo Bcedente
	cCodigo +=  Alltrim(SEE->EE_CODEMP)  
	// Pos 26 DV codigo cedente
	cCodigo += BolDigitoBarra(Alltrim(SEE->EE_CODEMP),"CEDENTE") //MODULO11(Alltrim(SEE->EE_CODEMP),2,9) //retirado Peso diferente
	// Pos 27 a 29 - Nosso numero sequencia 1
	cCodigo += substr(cNossoNumero,3,3)
	//Pos 30 - contatante 1 nosso numero
	cCodigo += "1"
	//Pos 31 a 33  - Nosso numero sequencia 2 
	cCodigo += substr(cNossoNumero,6,3)
	//Pos 34 - Constante 2 Nosso numero
	cCodigo += "4"
	//Pos 35 a 43 - Nosso numero sequencia 3
	cCodigo += substr(cNossoNumero,9,9)
	//Pos 44 DV campo livre (campo livre da posição 20 a 43)
	cCodigo += BolDigitoBarra(Alltrim(substr(cCodigo,19)),"CPLIVRE")//MODULO11(substr(cCodigo,20),2,9)
	 
	// Monta codigo de barras com digito verificador
	cCodigo := Subs(cCodigo,1,4) + BolDigitoBarra(cCodigo,"GERAL") + Subs(cCodigo,5)
Return cCodigo
/***********************************************************************************
	Digito verificador do codigo de barras
************************************************************************************/
Static Function BolDigitoBarra(cCodigo,cOrigem)
	Local nResto := 0
	Local nDigitoBarra := ""
	Local nCnt   := 0
	Local nPeso  := 2
	Local n1     := 1
	Default cOrigem := "GERAL"
	For n1 := Len(cCodigo) To 1 Step -1
		nCnt  := nCnt + (Val(SubStr(cCodigo,n1,1))*nPeso)
		nPeso := nPeso+1
		If nPeso > 9
			nPeso := 2
		EndIf
	Next n1
	IF cOrigem == "CEDENTE" .or. cOrigem == "NOSSONUM" 
		nResto := (nCnt%11)	
		nResto := 11-nResto
		IF  nResto > 9
			nDigitoBarra := "0"
		Else
			nDigitoBarra := Str(nResto,1)
		EndIF
	ElseIF cOrigem == "CPLIVRE"
		IF nCnt < 11 //verifica se a soma é maior q o quociente
			nResto := 11-nCnt
		Else
			nResto := (nCnt%11)	
			nResto := 11-nResto
		EndIF 
		IF  nResto > 9
			nDigitoBarra := "0"
		Else
			nDigitoBarra := Str(nResto,1)
		EndIF
	ElseIF cOrigem == "GERAL" 
		nResto := (nCnt%11)	
		nResto := 11-nResto
		IF nResto == 0 .Or. nResto == 1 .Or. nResto > 9
			nDigitoBarra := "1"
		Else
			nDigitoBarra := Str(nResto,1)
		EndIF
	EndIF 

Return nDigitoBarra
/***********************************************************************************
	Monta a linha digitavel, representação numerica
************************************************************************************/
Static Function BolLinhaDigitavel()
	Local cLinha := ""
	Local cCodigo := ""
	
	// Calculo do Primeiro Campo
	cCodigo := ""
	cCodigo := Subs(cCodigoBarra,1,4)+Subs(cCodigoBarra,20,5)
	// Calculo do digito do Primeiro Campo
	cLinha += Subs(cCodigo,1,5)+"."+Subs(cCodigo,6,4)+alltrim(str(BolDigLinha(2,cCodigo)))

	// Insere espaco
	cLinha += " "

	// Calculo do Segundo Campo
	cCodigo := ""
	cCodigo := Subs(cCodigoBarra,25,10)
	// Calculo do digito do Segundo Campo
	cLinha += Subs(cCodigo,1,5)+"."+Subs(cCodigo,6,5)+Alltrim(Str(BolDigLinha(2,cCodigo)))

	// Insere espaco
	cLinha += " "

	// Calculo do Terceiro Campo
	cCodigo := ""
	cCodigo := Subs(cCodigoBarra,35,10)
	// Calculo do digito do Terceiro Campo
	cLinha += Subs(cCodigo,1,5)+"."+Subs(cCodigo,6,5)+Alltrim(Str(BolDigLinha(2,cCodigo)))

	// Insere espaco
	cLinha += " "

	// Calculo do Quarto Campo
	cCodigo := ""
	cCodigo := Subs(cCodigoBarra,5,1)
	cLinha += cCodigo

	// Insere espaco
	cLinha += " "

	// Calculo do Quinto Campo
	cCodigo := ""
	cCodigo := Subs(cCodigoBarra,6,4)+Subs(cCodigoBarra,10,10)
	cLinha += cCodigo

Return cLinha
/************************************************************************************/
Static Function BolDigLinha(nCnt,cCodigo)
	Local n1        := 1
	Local nAuxiliar := 0
	//Local nInteiro  := 0
	Local nDigito   := 0
	Local nResto     := 0
	Local nSoma     := 0
	For n1 := Len(cCodigo) To 1 Step -1
		nAuxiliar := Val(Substr(cCodigo,n1,1)) * nCnt
		If nAuxiliar >= 10
			nAuxiliar:= (Val(Substr(Str(nAuxiliar,2),1,1))+Val(Substr(Str(nAuxiliar,2),2,1)))
		Endif
		nCnt += 1
		If nCnt > 2
			nCnt := 1
		Endif
		//nDigito += nAuxiliar
		nSoma += nAuxiliar
	Next n1
	/* retirado 20190118
	IF (nDigito%10) > 0
		nInteiro    := Int(nDigito/10) + 1
	Else
		nInteiro    := Int(nDigito/10)
	EndIF
	nInteiro    := nInteiro * 10
	nDigito := nInteiro - nDigito */
	IF nSoma >= 10
		nResto := (nSoma%10)
		IF nResto > 0
			nDigito := 10-nResto
		Else
			nDigito := 0
		EndIF
	Else
		nDigito := 10 - nSoma
	EndIF  
Return nDigito
