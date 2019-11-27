#Include "rwmake.ch"
#include 'protheus.ch'
#include 'parmtype.ch'
#Include "TopConn.ch"
#INCLUDE "TBICONN.CH"
  
/*
+----------------------------------------------------------------------------+
!                         FICHA TECNICA DO PROGRAMA                          !
+----------------------------------------------------------------------------+
!   DADOS DO PROGRAMA                                                        !
+------------------+---------------------------------------------------------+                                `
!Tipo              ! Rotina                                                  !
+------------------+---------------------------------------------------------+
!Modulo            ! FAT                                                     !
+------------------+---------------------------------------------------------+
!Nome              ! MtaSF2                                                  !
+------------------+---------------------------------------------------------+
!Descricao         ! Este P.E. esta localizado na funcao A460GeraF2          !
!                  ! (Gera Registros em SF2 e acumula valores)               !
!                  ! E executado apos a atualizacao de quase todos os        !
!                  ! campos do SF2.                                          ! 
!                  !                                                         !
+------------------+---------------------------------------------------------+
!Autor             ! Douglas Giovanni Negrello                               !
+------------------+---------------------------------------------------------+
!Data de Criacao   ! 12/01/19                                                !
+------------------+---------------------------------------------------------+
!   ATUALIZACOES                                                             !
+-------------------------------------------+-----------+-----------+--------+
!   Descricao detalhada da atualizacao      !Nome do    ! Analista  !Data da !
!                                           !Solicitante! Respons.  !Atualiz.!
+-------------------------------------------+-----------+-----------+--------+
!                                           !           !           !        !
!                                           !           !           !        !
+-------------------------------------------+-----------+-----------+--------+
*/

User Function MtaSF2()

Local _xMenCom	:= F2_XMENCOM

LOCAL aVetInc := {}
Local aArea := GetArea()

Local aAreaSF2 := SF2->(GetArea())
	
	DbSelectArea("SA4")
	SA4->(DbSetOrder(1))
	If SA4->(DbSeek(xfilial()+SC5->C5_REDESP))
		If SC5->(FieldPos("C5_TPFTREF")) > 0
			If SC5->C5_TPFTREF == 'C'
				_xMenCom += "Frete por conta do "
			Else
				_xMenCom += "Contrata��o do frete por conta do destin�tario (FOB) "
			EndIf
		EndIf
		_xMenCom += "Dados para redespacho: "
		_xMenCom += "Transp: "+Alltrim(SA4->A4_NOME) 
		_xMenCom += " - End: "+AllTrim(A4_END)
		_xMenCom += " - Bairro: "+AllTrim(A4_BAIRRO)
		_xMenCom += " - Cep: "+Transform(SA4->A4_CEP,"@R 99999-999")
		_xMenCom += " - Mun/Est:"+AllTrim(A4_MUN)
		_xMenCom += " - "+AllTrim(A4_EST)
		_xMenCom += " - Fone: ("+AllTrim(A4_DDD)+") "+Transform(SA4->A4_TEL,"@R 9999-9999")
	EndIf	
	
	If SF2->F2_ICMSRET > 0 //.AND. !Empty(SF2->F2_DUPL)
		_xMenCom += " / NFe com valor de ICMS-ST separado das parcelas"
		_xMenCom += " - Valor do t�tulo separado: R$"+ cValtoChar(SF2->F2_ICMSRET)
	EndIf
	
	
	If SF2->(FieldPos("F2_XMENCOM")) > 0
		SF2->F2_XMENCOM	:= _xMenCom
	EndIf


Return(nil)

