#include "Protheus.ch"
#include "TOTVS.CH"
#include "TopConn.ch"
#include "RWMake.ch"

/*/{Protheus.doc} MTA681MNU
Inclusao do apontamento inicial no Menu

@author Douglas Negrello
@since 03/2019
@version 1.0

@param nOpc, oGet
/*/

User Function MTA681MNU()

aAdd(aRotina, {"Iniciar Apontamento", "U_APCP010", 0, 6 } ) 

Return


User Function APCP010(lIncSup)
	
	Local oRecurso		:= Nil
	Local oOrdemP		:= Nil
	Local oOperac		:= Nil
	Local oData			:= Nil
	Local oHora			:= Nil
	
	Private cRecurso	:= Space(TamSX3("H6_RECURSO")[1])
	Private cOrdemP		:= Space(TamSX3("H6_OP")[1])
	Private cOperac		:= Space(TamSX3("H6_OPERAC")[1])
	Private dData		:= dDataBase
	Private cHora		:= Time()
	
	Default lIncSup		:= .F.
	
	DEFINE MSDIALOG oDlg FROM  64,33 TO 320, 320 TITLE "Apontamento Inicial"  PIXEL
	
		@ 010,010 SAY "Recurso:" SIZE 245, 7 OF oDlg PIXEL
		@ 008,040 MSGET oRecurso VAR cRecurso SIZE 70,10 F3 "SH1" Valid ExistCpo("SH1",cRecurso) OF oDlg PIXEL
		@ 030,010 SAY "OP:" SIZE 245,07 OF oDlg PIXEL
		@ 028,040 MSGET oOrdemP VAR cOrdemP  SIZE 70,10 F3 "SC2" Valid ExistCpo("SC2",cOrdemP) .AND. APCP010B(cOrdemP,cOperac) OF oDlg PIXEL
		@ 050,010 SAY "Operacao:" SIZE 245,07 OF oDlg PIXEL
		@ 048,040 MSGET oOperac VAR cOperac SIZE 70,10  OF oDlg PIXEL
		@ 070,010 SAY "Data:" SIZE 245,07 OF oDlg PIXEL
		@ 068,040 MSGET oData VAR dData SIZE 40,10  WHEN lIncSup OF oDlg PIXEL
		@ 090,010 SAY "Hora:" SIZE 245,07 OF oDlg PIXEL
		@ 088,040 MSGET oHora VAR cHora SIZE 35,10  Picture "99:99" WHEN lIncSup OF oDlg PIXEL
		
		@ 110,55 BmpButton Type 1 Action (APCP010A(),close(oDlg)) 
		@ 110,90 BmpButton Type 2 Action close(oDlg)

	ACTIVATE MSDIALOG oDlg CENTERED
	
Return

//Grava apontamento inicial
Static Function APCP010A()
	
	DbSelectArea("Z10") 
	
	RecLock("Z10",.T.)
	Z10->Z10_FILIAL	:= xFilial("Z10")
	Z10->Z10_OP		:= cOrdemP
	Z10->Z10_OPERAC	:= cOperac
	Z10->Z10_RECURS	:= cRecurso
	Z10->Z10_DATA	:= dData
	Z10->Z10_HORA	:= cHora
	Z10->Z10_FINALI := "N"
	Z10->Z10_USUAR	:= SUBS(CUSUARIO,7,15)
	Z10->(MsUnlock())
	
	//close(oDlg)
	
Return
 
//Grava apontamento inicial
Static Function APCP010B(cOrdemP,cOperac)
	
	Local lRet := .T.
	
	DbSelectArea("Z10") 
	Z10->(DbSetOrder(1))
	Z10->(DbGoTop())
	If Z10->(DbSeek(xFilial("Z10")+cOrdemP+cOperac))
		If Z10->Z10_FINALI <> "S"
			MsgInfo("Já existe um apontamento inicial para esta OP!","Apontamento Inicial")
			lRet	:= .F.
		EndIf
	EndIf
	
Return(lRet)

//EXECUTADO APARTIR DA VALIDACAO DE CAMPO DO H6_OPERAC
//PREENCHE AUTOMATICAMENTE A DATA E HORA INICIAL OU CHAMA TELA DE LIBERACAO PELO SUPERIOR 	
User Function APCP010C()

	Local lRet		:= .T.
	Local cCoduser	:= ""
	
	DbSelectArea("Z10") 
	Z10->(DbSetOrder(1))
	Z10->(DbGoTop())
	If Z10->(DbSeek(xFilial("Z10")+M->H6_OP+H6_OPERAC)) .AND. Z10->Z10_FINALI <> "S"
		M->H6_DATAINI	:= 	Z10->Z10_DATA		
		M->H6_HORAINI	:= 	Z10->Z10_HORA		
	Else
		If MsgYesNo("Não existe apontamento inicial disponível, deseja incluir com autorização do superior?","Apontamento Inicial")
			cCoduser:= U_APCP010L()
			If 	cCoduser $ GetNewPar("MV_SUPPERM",'000772')
				U_APCP010( .T. )
				U_APCP010C()
				//Alert("OK")
			Else
				M->H6_DATAINI	:= M->H6_DATAFIN	
				
				nPos:=AT(":",M->H6_HORAFIN)
				If Val(Substr(M->H6_HORAFIN,nPos+1,2)) == 0
					If Val(Substr(M->H6_HORAFIN,1,nPos-1))==0
						nHora:=23
					Else
						nHora:=Val(Substr(M->H6_HORAFIN,1,nPos-1))-1
					EndIf
					nMinutos:=59
					M->H6_HORAINI :=StrZero(nHora,2)+":"+StrZero(nMinutos,2)
				Else
					nMinutos:=Val(Substr(M->H6_HORAFIN,nPos+1,2))-1
					M->H6_HORAINI :=Substr(M->H6_HORAFIN,1,nPos-1)+":"+StrZero(nMinutos,2)
				EndIf
	
				//M->H6_HORAINI	:= M->H6_HORAFIN		
				//Alert("Usuario sem autorização!")
			EndIf	
		Else
			M->H6_DATAINI	:= M->H6_DATAFIN
				
			nPos:=AT(":",M->H6_HORAFIN)
			If Val(Substr(M->H6_HORAFIN,nPos+1,2)) == 0
				If Val(Substr(M->H6_HORAFIN,1,nPos-1))==0
					nHora:=23
				Else
					nHora:=Val(Substr(M->H6_HORAFIN,1,nPos-1))-1
				EndIf
				nMinutos:=59
				M->H6_HORAINI :=StrZero(nHora,2)+":"+StrZero(nMinutos,2)
			Else
				nMinutos:=Val(Substr(M->H6_HORAFIN,nPos+1,2))-1
				M->H6_HORAINI :=Substr(M->H6_HORAFIN,1,nPos-1)+":"+StrZero(nMinutos,2)
			EndIf
						
			//M->H6_HORAINI	:= M->H6_HORAFIN		
		EndIf
	EndIf
		
Return(lRet)	

//É executado após a gravação dos dados na rotina de inclusão do apontamento de produção PCP Mod2.
User Function MT681INC()

 	DbSelectArea("Z10") 
	Z10->(DbSetOrder(1))
	Z10->(DbGoTop())
	
	If Z10->(DbSeek(xFilial("Z10")+SH6->H6_OP+SH6->H6_OPERAC))
		RecLock("Z10",.F.)
			Z10->Z10_FINALI := "S"
		MsUnlock()
	EndIf
Return

//VALIDACAO DE LOGIN E PERMISSAO DE USO DA ROTINA
User Function APCP010L()

	Local lRet		:= .T. 
	Local cSenha1	:= Space(30)
	Local cUsuario	:= Space(30)
	Local oUser		:= Nil
	Local oPass		:= Nil
	Local cCodUser	:= ""
	
	DEFINE MSDIALOG oDlg FROM  64,33 TO 250, 320 TITLE "Permissão de uso"  PIXEL
	
		@ 010,035 SAY "Usuário:" SIZE 245, 7 OF oDlg PIXEL
		@ 020,035 MSGET oUser VAR cUsuario SIZE 80,08 OF oDlg PIXEL
		@ 040,035 SAY "Senha:" SIZE 245, 7 OF oDlg PIXEL
		@ 050,035 MSGET oPass VAR cSenha1 PASSWORD SIZE 80,08  OF oDlg PIXEL
		
		@ 075,60 BmpButton Type 1 Action close(oDlg)

	ACTIVATE MSDIALOG oDlg CENTERED
	
	PswOrder(2) 								//Ordena a busca por  Nome do usuario
	If PswSeek(Alltrim(cUsuario),.T.)			//Posiciona no Nome do Usuario informado
	
		If !PswName(Alltrim(cSenha1))			//Retorna True se senha passada como parametro for igual a senha do nome posicionado acima
			//lRet := .F.
			Alert("Usuário ou senha incorretos!")
		Else
			//ONDE TUDO ACONTECE, APOS VALIDACAO DO USUARIO
			//
			cCodUser := PswRet(1)[1][1]

		EndIf
	Else
		//lRet := .F.
		Alert("Usuário ou senha incorretos!")
	EndIf
	
Return(cCodUser)



