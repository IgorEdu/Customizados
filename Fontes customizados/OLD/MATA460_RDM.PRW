/**********************************************************
	Final da emissoa Nota fiscal
	Programador: Mario Araujo Oliveira - INNOVATE 09/01/19
**********************************************************/
User function M460FIM()
Local aArea := GetArea()
IF ExistBlock("IMPBOL2A")
	IF Aviso("M460FIM","Deseja gerar o Boleto?",{"SIM","NAO"}) == 1
		Processa({|| U_IMPBOL2A()},"Aguarde .. ","Gerando Boletos..")
	EndIF 
EndIF 	
RestArea(aArea)
Return