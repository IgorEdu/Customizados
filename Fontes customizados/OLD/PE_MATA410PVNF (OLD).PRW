User function M410PVNF()

Local lRet := .T.

	DbSelectArea("DAI")//ITENS DA CARGA
	DAI->(DbSetOrder(4))//DAI_FILIAL+DAI_PEDIDO+DAI_COD+DAI_SEQCAR
	DAI->(DbGoTop())
	If DAI->(DbSeek(xFilial("DAI")+SC5->C5_NUM))
		DbSelectArea("SC9")//PEDIDOS LIBERADOS
		SC9->(DbSetOrder(1))//C9_FILIAL+C9_PEDIDO+C9_GRUPO+C9_PRODUTO
		SC9->(DbGoTop())
		If SC9->(DbSeek(xFilial("SC9")+SC5->C5_NUM))
			While SC9->(!Eof()) .AND. SC5->C5_NUM == SC9->C9_PEDIDO
				If SC9->C9_CONFERI <> "S"
					MSgInfo("Para emissão de documento é necessária a liberação da carga!","Preparação de Documento Bloqueado!")
					lRet := .F.
					Exit
				EndIf
				SC9->(DbSkip())
			EndDo
		EndIf
	EndIf

Return lRet