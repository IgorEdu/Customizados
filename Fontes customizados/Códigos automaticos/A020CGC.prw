#include 'protheus.ch'
#include 'parmtype.ch'
#INCLUDE 'TOPCONN.CH'

User Function A020CGC

Local     aAreaOld     := SA2->(GetArea())
Local     cCNPJ        := M->A2_CGC
Local     cA2_COD      := M->A2_COD
Local     cA2_LOJA     := M->A2_LOJA
Local     cCGCBAse     
Local     nLoja    
Local cSql := ''     
Local cProxCod := ''  
Local aArea := GetArea()     
     
// Forço atualização para Juridica se o numero de digitos for maior que 11
If Len(Alltrim(cCNPJ)) > 11
     M->A2_TIPO = "J"
Endif

If M->A2_TIPO == "J"
     cA2_LOJA     := SubStr(cCNPJ,10,3)
     nLoja          := Val(cA2_LOJA)

     cCGCBase := SubStr(cCNPJ,1,8)
     DbSelectArea("SA2")
     DbSetOrder(3)
     If DbSeek(xFilial("SA2")+cCGCBase) 
          cA2_COD      := SA2->A2_COD
          // Efetua loop para evitar duplicidade de Loja, mesmo que não corresponda a loja do CNPJ
          While .T.
               DbSelectArea("SA2")
               DbSetOrder(1)
               If DbSeek(xFilial("SA2")+cA2_COD+cA2_LOJA) 
                  cA2_LOJA := Soma1(cA2_LOJA)
               Else
                    Exit
               Endif
          Enddo
     Else
     	cSql := "SELECT MAX(A2_COD) AS CODIGO FROM "+RetSqlName("SA2010") 
     	cSql += " WHERE A2_FILIAL = '"+xFilial("SA2")+"' AND D_E_L_E_T_<>'*' AND SUBSTRING(A2_COD,1,2) = 'F0'" 
     	
     	If !Empty(cSql) 
     	If select("QRY") > 0 
     		QRY->(DbCloseArea()) 
     	Endif 

     	TcQuery ChangeQuery(cSql) New Alias "QRY" 

     	If Empty(QRY->CODIGO) 
     		cA2_COD := 'F00001' 
     	Else                      
     		cA2_COD := SubStr(QRY->CODIGO,1,1) + Soma1(Alltrim(SubStr(QRY->CODIGO,2,5))) 
     	Endif 
                                    
     	QRY->(dbclosearea())     
     	Endif                          
     	RestArea(aArea) 

     	 
     Endif
     M->A2_COD      := cA2_COD
     M->A2_LOJA      := cA2_LOJA
     RestArea(aAreaOld)
Else
	cSql := "SELECT MAX(A2_COD) AS CODIGO FROM "+RetSqlName("SA2010") 
    cSql += " WHERE A2_FILIAL = '"+xFilial("SA2")+"' AND D_E_L_E_T_<>'*' AND SUBSTRING(A2_COD,1,2) = 'F0'" 
     	
    If !Empty(cSql) 
    If select("QRY") > 0 
     	QRY->(DbCloseArea()) 
    Endif 

    TcQuery ChangeQuery(cSql) New Alias "QRY" 

    If Empty(QRY->CODIGO) 
    	cA2_COD := 'F00001' 
    Else                      
    	cA2_COD := SubStr(QRY->CODIGO,1,1) + Soma1(Alltrim(SubStr(QRY->CODIGO,2,5)))
    Endif 
                                   
    QRY->(dbclosearea())     
    Endif                          
    RestArea(aArea) 

     M->A2_COD      := cA2_COD
     M->A2_LOJA      := '001'
     RestArea(aAreaOld)

Endif

Return A020CGC(M->A2_TIPO, M->A2_CGC)