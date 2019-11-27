#include 'protheus.ch'
#include 'parmtype.ch'
#INCLUDE 'TOPCONN.CH'

User Function A030CGC

Local     aAreaOld     := SA1->(GetArea())
Local     cCNPJ        := M->A1_CGC
Local     cA1_COD      := M->A1_COD
Local     cA1_LOJA     := M->A1_LOJA
Local     cCGCBAse     
Local     nLoja    
Local cSql := ''     
Local cProxCod := ''  
Local aArea := GetArea()     
     
// Forço atualização para Juridica se o numero de digitos for maior que 11
If Len(Alltrim(cCNPJ)) > 11
     M->A1_PESSOA = "J"
Endif

If M->A1_PESSOA == "J"
     cA1_LOJA     := SubStr(cCNPJ,10,3)
     nLoja          := Val(cA1_LOJA)

     cCGCBase := SubStr(cCNPJ,1,8)
     DbSelectArea("SA1")
     DbSetOrder(3)
     If DbSeek(xFilial("SA1")+cCGCBase) 
          cA1_COD      := SA1->A1_COD
          // Efetua loop para evitar duplicidade de Loja, mesmo que não corresponda a loja do CNPJ
          While .T.
               DbSelectArea("SA1")
               DbSetOrder(1)
               If DbSeek(xFilial("SA1")+cA1_COD+cA1_LOJA) 
                  cA1_LOJA := Soma1(cA1_LOJA)
               Else
                    Exit
               Endif
          Enddo
     Else
     	cSql := "SELECT MAX(A1_COD) AS CODIGO FROM "+RetSqlName("SA1010") 
     	cSql += " WHERE A1_FILIAL = '"+xFilial("SA1")+"' AND D_E_L_E_T_<>'*' AND SUBSTRING(A1_COD,1,2) = 'C0'" 
     	
     	If !Empty(cSql) 
     	If select("QRY") > 0 
     		QRY->(DbCloseArea()) 
     	Endif 

     	TcQuery ChangeQuery(cSql) New Alias "QRY" 

     	If Empty(QRY->CODIGO) 
     		cA1_COD := 'C00001' 
     	Else                      
     		cA1_COD := SubStr(QRY->CODIGO,1,1) + Soma1(Alltrim(SubStr(QRY->CODIGO,2,5)))
     	Endif 
                                    
     	QRY->(dbclosearea())     
     	Endif                          
     	RestArea(aArea) 

     	 
     Endif
     M->A1_COD      := cA1_COD
     M->A1_LOJA      := cA1_LOJA
     RestArea(aAreaOld)
Else
cSql := "SELECT MAX(A1_COD) AS CODIGO FROM "+RetSqlName("SA1010") 
     	cSql += " WHERE A1_FILIAL = '"+xFilial("SA1")+"' AND D_E_L_E_T_<>'*' AND SUBSTRING(A1_COD,1,2) = 'C0'" 
     	
     	If !Empty(cSql) 
     	If select("QRY") > 0 
     		QRY->(DbCloseArea()) 
     	Endif 

     	TcQuery ChangeQuery(cSql) New Alias "QRY" 

     	If Empty(QRY->CODIGO) 
     		cA1_COD := 'C00001' 
     	Else                      
     		cA1_COD := SubStr(QRY->CODIGO,1,1) + Soma1(Alltrim(SubStr(QRY->CODIGO,2,5))) 
     	Endif 
                                    
     	QRY->(dbclosearea())     
     	Endif                          
     	RestArea(aArea) 

     	 
     M->A1_COD      := cA1_COD
     M->A1_LOJA      := '001'
     RestArea(aAreaOld)

Endif

Return A030CGC(M->A1_PESSOA, M->A1_CGC)