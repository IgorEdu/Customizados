#Include "TOTVS.CH"
#Include "RWMAKE.CH"
#Include "TOPCONN.CH"
#Include "FWMVCDEF.CH"
#Include "PROTHEUS.CH"
#Include "FWMBROWSE.CH"

#Define CLR Chr(13)+Chr(10)

/*/{Protheus.doc} ECommerce
Rotina para gerenciamento dos Pedidos do E-Commerce.
@author VAMILLY-Gabriel Alencar
@since 04/11/2019
@return return, return_description
/*/
User Function ECommerce()
	Local lMarcar := .F.

	Private oBrowse := FWMarkBrowse():New()
	Private lMsErroAuto := .F.
	Private lAutoErrNoFile := .T.

	oBrowse:SetAlias('Z03')
	oBrowse:SetDescription('Gest�o de Pedidos - E-Commerce')
	oBrowse:SetFieldMark('Z03_OK')

	oBrowse:AddLegend("Z03->Z03_MSBLQL == '1'"								, "PCOFXCANCEL"	, "Cancelado Internamente")
	oBrowse:AddLegend("!Empty(Z03->Z03_CHVNFE)"								, "BR_PRETO"	, "Faturado e transmitido")
	oBrowse:AddLegend("!Empty(Z03->Z03_DOCNF) .AND. Empty(Z03->Z03_CHVNFE)"	, "BR_LARANJA"	, "Faturado e n�o transmitido")
	oBrowse:AddLegend("!Empty(Z03->Z03_PEDERP) .AND. Empty(Z03->Z03_DOCNF)"	, "BR_VERMELHO"	, "Com Pedido do ERP n�o faturado")
	oBrowse:AddLegend("Empty(Z03->Z03_PEDERP)"								, "BR_VERDE"	, "Sem Pedido do ERP")
	oBrowse:SetValid({|| Empty(Z03->Z03_PEDERP) .AND. Z03->Z03_MSBLQL != '1' }) // S� permite a sele��o de pedidos e-commerce sem PV no ERP
	oBrowse:AddStatusColumns( {|| U_STATUSMED(Z03->Z03_PEDSIT) }, { || U_Mediador("Z05->Z05_PEDSIT == Z03->Z03_PEDSIT", "Comunica��es do Pedido " + cValToChar(Z03->Z03_PEDSIT)) } )
	oBrowse:AddStatusColumns( {|| IIF(!fSaldoPed(Z03->Z03_PEDSIT), "UPDERROR", "")  }, { || Nil } )
	oBrowse:SetAllMark( {|| BrwInvert(oBrowse:Mark(), lMarcar := !lMarcar), oBrowse:Refresh(.T.) } )

	// Adiciona filtros para o usu�rio
	fAddFilters()

	oBrowse:Activate()

Return Nil

/*/{Protheus.doc} Legenda
Exibe a legenda do GRID.
@author VAMILLY-Gabriel Alencar
@since 04/11/2019
@return return, return_description
/*/
Static function Legenda()
	Local aLegenda := {}

	aAdd(aLegenda, {"PCOFXCANCEL"	, "Cancelado Internamente"			})
	aAdd(aLegenda, {"BR_PRETO"		, "Faturado e transmitido"			})
	aAdd(aLegenda, {"BR_LARANJA"	, "Faturado e n�o transmitido"		})
	aAdd(aLegenda, {"BR_VERMELHO"	, "Com Pedido do ERP n�o faturado"	})
	aAdd(aLegenda, {"BR_VERDE"		, "Sem Pedido do ERP"				})
	aAdd(aLegenda, {"PMSINFO"		, "Com pend�ncia de Comunica��o"	})
	aAdd(aLegenda, {"UPDERROR"		, "Possui itens sem saldo"			})

	BrwLegenda("Legenda do Pedido", "Legenda", aLegenda)

Return Nil


/*/{Protheus.doc} BrwInvert
Fun��o para tratar a a marca��o de todos os itens do Browse.
@author VAMILLY-Gabriel Alencar
@since 04/11/2019
@return return, return_description
@param cMark, characters, Marca��o utilizada pelo browse
@param lMarcar, logical, Identificador se � para marcar ou desmarcar
/*/
Static Function BrwInvert(cMark, lMarcar)
	Local aArea := GetArea()

	DBSelectArea("Z03")
	Z03->(DBSetOrder(1)) // Z03_FILIAL + Z03_PEDSIT
	Z03->(DBGoTop())

	While !Z03->(Eof())

		// S� permite selecionar itens sem pedido no ERP e que n�o estejam canceladas internamente
		If Empty(Z03->Z03_PEDERP) .AND. Z03->Z03_MSBLQL != '1'
			RecLock("Z03", .F. )
				Z03->Z03_OK := IIF(lMarcar, cMark, "  ")
        	Z03->(MsUnlock())
		EndIf

	    Z03->(DBSkip())
	EndDo

	RestArea(aArea)

Return .T.

/*/{Protheus.doc} Z03PESSOA
Fun��o utilizada nos campos customizados de CPF/CNPJ para tratar a m�scara.
@author VAMILLY-Gabriel Alencar
@since 04/11/2019
@return return, return_description
/*/
User Function Z03PESSOA()
	Local cRet := PicCli(M->Z03_PESSOA)
Return cRet

/*/{Protheus.doc} fAddFilters
Adiciona filtros complementares para facilitar o trabalho do usu�rio.
@author VAMILLY-Gabriel Alencar
@since 04/11/2019
@return return, return_description
/*/
Static Function fAddFilters()
	Local aArea := GetArea()
	Local cAlias := GetNextAlias()
	Local cTitle := ""

	// Busca todos os status da base
	BeginSQL Alias cAlias
		SELECT DISTINCT Z03_STASIT
		  FROM %Table:Z03% Z03
		 WHERE Z03_FILIAL = %xFilial:Z03%
		 	   AND Z03.%NotDel%
	EndSQL

	While !(cAlias)->(Eof())

		cTitle := AllTrim(Upper((cAlias)->Z03_STASIT))

		// Adiciona um filtro para cada status existente na base
		oBrowse:AddFilter("Status: " + Capital(cTitle), "AllTrim(Upper(Z03->Z03_STASIT)) == " + ValToSQL(cTitle))

		(cAlias)->(DBSkip())
	EndDo

	If Select(cAlias) > 0
		(cAlias)->(DBCloseArea())
	EndIf

	// Busca todos os Marketplaces da base
	BeginSQL Alias cAlias
		SELECT DISTINCT Z03_AFILIA
		  FROM %Table:Z03% Z03
		 WHERE Z03_FILIAL = %xFilial:Z03%
		 	   AND Z03.%NotDel%
	EndSQL

	While !(cAlias)->(Eof())

		cTitle := AllTrim(Upper((cAlias)->Z03_AFILIA))

		// Trata o Marketplace vazio (Vendas pela PreCode)
		If Empty(cTitle)
			cTitle := "PreCode"
		EndIf

		// Adiciona um filtro para cada Marketplace existente na base
		oBrowse:AddFilter("Marketplace: " + Capital(cTitle), "AllTrim(Upper(Z03->Z03_AFILIA)) == " + ValToSQL(IIF(cTitle == "PreCode", "", cTitle)))

		(cAlias)->(DBSkip())
	EndDo

	If Select(cAlias) > 0
		(cAlias)->(DBCloseArea())
	EndIf

	RestArea(aArea)

Return Nil

/*/{Protheus.doc} fSaldoPed
Fun��o que verifica se todos os itens do pedido tem saldo suficiente no estoque.
@author VAMILLY-Gabriel Alencar
@since 04/11/2019
@return return, .T. = Todos itens com Saldo | .F. = Alguns ou todos itens sem saldo
@param nPedidoSite, numeric, C�digo do pedido a ser validado
/*/
Static Function fSaldoPed(nPedidoSite)
	Local nSaldo := 0
	Local cArmOri := GetNewPar("MV_XARMSIT", "01") // Armaz�m que controlar� o saldo dos itens do E-Commerce
	Local aAreaZ03 := Z03->(GetArea())
	Local aAreaZ04 := Z04->(GetArea())
	Local lSaldoPedido := .T.

	// N�o valida o saldo do pedido caso o mesmo j� tenha PV amarrado no Protheus
	If !Empty(Z03->Z03_PEDERP) .OR. (Z03->Z03_MSBLQL == "1")
		Return lSaldoPedido
	EndIf

	// Posiciona nos itens do pedido do site
	DBSelectArea("Z04")
	Z04->(DBSetOrder(1)) // Z04_FILIAL + Z04_PEDSIT
	Z04->(MSSeek(xFilial("Z04") + Str(nPedidoSite, TamSX3("Z04_PEDSIT")[1])) )

	DBSelectArea("SB2")
	SB2->(DBSetOrder(1))

	// Varre os itens da E-Commerce para verificar se todos os itens tem saldo
	While !Z04->(Eof()) .AND. AllTrim(Z04->Z04_FILIAL + Str(Z04->Z04_PEDSIT, TamSX3("Z04_PEDSIT")[1])) == AllTrim(xFilial("Z04") + Str(nPedidoSite, TamSX3("Z04_PEDSIT")[1]))

		// Vereifica se o item em quest�o tem saldo no armaz�m do E-Commerce
		If SB2->(MSSeek(xFilial("SB2") + Z04->Z04_PRODUT + PadR(cArmOri, TAMSX3("B2_LOCAL")[1])))
			nSaldo := SB2->B2_QATU - SB2->B2_QACLASS - SB2->B2_RESERVA  // Configuracao do parametro MV_TPSALDO esta Q e nesse caso considera esse campos movimentos internos.

			If nSaldo < Z04->Z04_QTDVEN
				lSaldoPedido := .F.
			EndIf

		Else
			lSaldoPedido := .F.
		EndIf

		// Caso n�o tenha saldo nao continua
		If !lSaldoPedido
			Exit
		EndIf

		Z04->(DBSkip())
	EndDo

	RestArea(aAreaZ04)
	RestArea(aAreaZ03)

Return lSaldoPedido

/*/{Protheus.doc} MenuDef
Defini��o dos menus da rotina.
@author VAMILLY-Gabriel Alencar
@since 04/11/2019
@return return, return_description
/*/
Static Function MenuDef()
	Local aRotina := {}
	Local aRotina2 := {}
	Local aRotina3 := {}

	aAdd( aRotina3, { 'Importar Aprovados'	   , 'StaticCall(ECommerce, fImpAprov)', 0, 3, 0, NIL } )
	aAdd( aRotina3, { 'Processar Comunica��es' , 'StaticCall(ECommerce, fMediador)', 0, 3, 0, NIL } )
	aAdd( aRotina3, { 'Processar Chaves NF'	   , 'StaticCall(ECommerce, fNFe)'	   , 0, 3, 0, NIL } )
	aAdd( aRotina3, { 'Buscar Status'		   , 'StaticCall(ECommerce, fStatus)'  , 0, 3, 0, NIL } )
	aAdd( aRotina3, { 'Envia Saldos'		   , 'StaticCall(ECommerce, fSaldo)'   , 0, 3, 0, NIL } )
	aAdd( aRotina3, { 'Envia Pre�os'		   , 'StaticCall(ECommerce, fPreco)'   , 0, 3, 0, NIL } )

	aAdd( aRotina2, { 'Sincronizar Tudo'	   , 'StaticCall(ECommerce, fSyncAll)' , 0, 3, 0, NIL } )
	aAdd( aRotina2, { 'Sincronizar Espec�ficos', aRotina3						   , 0, 8, 0, NIL } )
	aAdd( aRotina2, { 'Cancelar Internamente'  , 'StaticCall(ECommerce, fCancel)'  , 0, 3, 0, NIL } )

	aAdd( aRotina, { 'Pesquisar' 			, 'PesqBrw'        						, 0, 1, 0, .T. } )
	aAdd( aRotina, { 'Gerar Pedidos'		, 'StaticCall(ECommerce, fGeraPedidos)'	, 0, 4, 0, NIL } )
	aAdd( aRotina, { 'Visualizar'			, 'VIEWDEF.ECommerce'	 				, 0, 2, 0, NIL } )
	aAdd( aRotina, { 'Alterar'				, 'VIEWDEF.ECommerce'	 				, 0, 4, 0, NIL } )
	aAdd( aRotina, { 'A��es'				, aRotina2	 							, 0, 8, 0, NIL } )
	aAdd( aRotina, { 'Preparar Doc Saida' 	, 'StaticCall(ECommerce, fPrepNF)'		, 0, 4, 0, NIL } )
	aAdd( aRotina, { 'Comunica��es com Site', 'U_Mediador()'	 					, 0, 4, 0, NIL } )
	aAdd( aRotina, { 'LOGs do E-Commerce'	, 'U_Log()'			 					, 0, 4, 0, NIL } )
	aAdd( aRotina, { 'Imprimir Browse'		, 'VIEWDEF.ECommerce'	 				, 0, 8, 0, NIL } )
	aAdd( aRotina, { 'Legenda'  			, 'StaticCall(ECommerce, Legenda)'		, 0, 1, 0, NIL } )

Return aRotina

/*/{Protheus.doc} ViewDef
Defini��o da View da rotina.
@author VAMILLY-Gabriel Alencar
@since 04/11/2019
@return return, return_description
/*/
Static Function ViewDef()
	Local oView
	Local oModel := ModelDef()
	Local oStrZ03 := FWFormStruct(2, 'Z03')
	Local oStrZ04 := FWFormStruct(2, 'Z04')

	// Cria o objeto de View
	oView := FWFormView():New()

	// Define qual o Modelo de dados ser� utilizado
	oView:SetModel(oModel)

	// Remove o campo OK da Enchoice
	oStrZ03:RemoveField('Z03_OK')
	oStrZ04:RemoveField('Z04_PEDSIT')

	// Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
	oView:AddField('VIEW_Z03', oStrZ03, 'Z03MASTER')

	//Adiciona no nosso View um controle do tipo FormGrid(antiga newgetdados)
	oView:AddGrid('VIEW_Z04', oStrZ04, 'Z04DETAIL')

	// Criar um "box" horizontal para receber algum elemento da view
	oView:CreateHorizontalBox('PAI', 050)
	oView:CreateHorizontalBox('FILHO', 050)

	// Relaciona o ID da View com o "box" para exibicao
	oView:SetOwnerView('VIEW_Z03', 'PAI')
	oView:SetOwnerView('VIEW_Z04', 'FILHO')

	oView:EnableTitleView('VIEW_Z03', 'Pedido | E-Commerce' )
	oView:EnableTitleView('VIEW_Z04', 'Itens | E-Commerce' )

	oView:SetViewProperty('VIEW_Z03', 'SETCOLUMNSEPARATOR', {10})

	// For�a o fechamento da janela na confirma��o
	oView:SetCloseOnOk( {|| .T. } )

	// Define campos que terao Auto Incremento
	oView:AddIncrementField( 'VIEW_Z04', 'Z04_ITEM' )

	// Define as views que ser�o somente para visualiza��es
	// oView:SetOnlyView('Z03MASTER')
	oView:SetOnlyView('Z04DETAIL')

	// Define uma mensagem a ser mostrada para o usu�rio quando uma opera��o de atualiza��o for concluida.
	oView:SetUpdateMessage("Pedidos E-Commerce", "Manuten��o realizada com sucesso.")

Return oView

/*/{Protheus.doc} ModelDef
Defini��o do Modelo da rotina.
@author VAMILLY-Gabriel Alencar
@since 04/11/2019
@return return, return_description
/*/
Static Function ModelDef()
	Local oModel
	Local oStrZ03 := FWFormStruct( 1, 'Z03', /*bAvalCampo*/,/*lViewUsado*/ ) // Constru��o de uma estrutura de dados
	Local oStrZ04 := FWFormStruct( 1, 'Z04', /*bAvalCampo*/,/*lViewUsado*/ ) // Constru��o de uma estrutura de dados

	// Cria o objeto do Modelo de Dados
	// Irei usar uma fun��o fPostConf que ser� acionada quando eu clicar no bot�o "Confirmar"
	oModel := MPFormModel():New('ECOMMEM', /*bPreValidacao*/, /*{ | oModel | fPostConf(oModel) }*/ , /*{ | oModel | fCommit(oModel) }*/ ,, /*bCancel*/ )
	oModel:SetDescription('Gest�o Pedidos E-Commerce')

	// Adiciona ao modelo uma estrutura de formul�rio de edi��o por campo
	oModel:addFields('Z03MASTER',, oStrZ03, /*{|oModel| MVC001T(oModel)}*/,,)

	// Adiciona ao modelo uma estrutura de formul�rio de edi��o por grid
	oModel:AddGrid( 'Z04DETAIL', 'Z03MASTER', oStrZ04, /*bLinePre*/, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )

	// Faz relaciomaneto entre os componentes do model
	oModel:SetRelation( 'Z04DETAIL', { { 'Z04_FILIAL', 'Z03_FILIAL' } , { 'Z04_PEDSIT', 'Z03_PEDSIT' } } , Z04->(IndexKey(1)) )

	// Define a chave primaria utilizada pelo modelo
	oModel:SetPrimaryKey({'Z03_FILIAL', 'Z03_PEDSIT' })

	// Liga o controle de nao repeticao de linha
	// oModel:GetModel( 'Z04DETAIL' ):SetUniqueLine( { 'Z04_ITEM' } )

Return oModel

/*/{Protheus.doc} fSyncAll
Chama todos os JOBS de uma vez s�.
@author VAMILLY-Gabriel Alencar
@since 04/11/2019
@return return, return_description
/*/
Static Function fSyncAll()

	If MsgNoYes("Deseja realmente processar todas as seguintes a��es:" + CLR + ;
				"- Importar Aprovados" + CLR + ;
				"- Processar Comunica��es" + CLR + ;
				"- Processar Chaves NF" + CLR + ;
				"- Atualizar Status" + CLR + ;
				"- Envia Saldos" + CLR + ;
				"- Envia Pre�os" + CLR + CLR + ;
				"Obs.: Todas essas a��es s�o executadas automaticamente pelo sistema de tempo em tempo. " + ;
				"Execut�-las agora pode ocasionar lentid�o na sua sess�o.", "E-Commerce - Sincronizar Tudo")

		MsgRun("Importando pedidos aprovados", "Aguarde...", {|| nImportados := U_JobAprovados() } )
		MsgRun("Processando Chave dos pedidos transmitidos", "Aguarde...", {|| U_JobNFe() } )
		MsgRun("Buscando Status do Pedido", "Aguarde...", {|| U_JobStatus() } )
		MsgRun("Atualizando saldo dos produtos no E-Commerce", "Aguarde...", {|| U_JobSaldo() } )
		MsgRun("Atualizando pre�o dos produtos no E-Commerce", "Aguarde...", {|| U_JobPreco() } )
		MsgRun("Processando comunica��o dos pedidos", "Aguarde...", {|| U_JobMediador() } )
	EndIf

Return Nil

/*/{Protheus.doc} fImpAprov
Chama o JOB para importa��o dos pedidos aprovados.
@author VAMILLY-Gabriel Alencar
@since 04/11/2019
@return return, return_description
/*/
Static Function fImpAprov()
	Local nImportados := 0

	MsgRun("Importando pedidos aprovados", "Aguarde...", {|| nImportados := U_JobAprovados() } )

	If nImportados > 0
		FwAlertSuccess("Total de pedidos importados: " + cValToChar(nImportados), "Importa��o finalizada")
	Else
		MsgInfo("Nenhum pedido aprovado a importar.", "Importa��o de Pedidos")
	EndIf

	oBrowse:Refresh(.F.)

Return Nil

/*/{Protheus.doc} fMediador
Chama o JOB que processar� a comunica��o dos pedidos ainda com pendencias no mediador.
@author VAMILLY-Gabriel Alencar
@since 04/11/2019
@return return, return_description
/*/
Static Function fMediador()
	Local aArea := GetArea()

	MsgRun("Processando comunica��o dos pedidos", "Aguarde...", {|| U_JobMediador() } )

	MsgInfo("Processamento conclu�do", "Comunica��o dos Pedidos")

	oBrowse:Refresh(.F.)

	RestArea(aArea)

Return Nil

/*/{Protheus.doc} fNFe
Chama o JOB que processar� a chave dos pedidos com NFe transmitidas, mas sem chave no pedido e informa a NF para o E-Commerce.
@author VAMILLY-Gabriel Alencar
@since 04/11/2019
@return return, return_description
/*/
Static Function fNFe()
	Local aArea := GetArea()

	MsgRun("Processando Chave dos pedidos transmitidos", "Aguarde...", {|| U_JobNFe() } )

	MsgInfo("Processamento conclu�do. " + CLR + CLR + "Aguarde processamento das comunica��es para que seja integrado com o E-Commerce.", "Chave dos Pedidos Transmitidos")

	oBrowse:Refresh(.F.)

	RestArea(aArea)

Return Nil

/*/{Protheus.doc} fStatus
Fun��o que chama o JOB para processamento do status do pedido posicionado.
@author VAMILLY-Gabriel Alencar
@since 04/11/2019
@return return, return_description
/*/
Static Function fStatus()
	Local aArea := GetArea()
	Local cRet := ""

	MsgRun("Buscando Status do Pedido", "Aguarde...", {|| cRet := U_JobStatus(Z03->Z03_PEDSIT) } )

	Aviso("Status do Pedido: " + cValToChar(Z03->Z03_PEDSIT) + " - E-Commerce", cRet, {"Ok"}, 3, Nil,Nil,Nil,.T. )

	oBrowse:Refresh(.F.)

	RestArea(aArea)

Return Nil

/*/{Protheus.doc} fSaldo
Chama o JOB para atualiza��o do saldo no site dos itens vendidos no E-Commerce.
@author VAMILLY-Gabriel Alencar
@since 04/11/2019
@return return, return_description
/*/
Static Function fSaldo()
	Local aArea := GetArea()

	MsgRun("Atualizando saldo dos produtos no E-Commerce", "Aguarde...", {|| U_JobSaldo() } )

	MsgInfo("Processamento conclu�do. " + CLR + CLR + "Aguarde processamento das comunica��es para que seja integrado com o E-Commerce.", "Atualiza��o dos Saldos do E-Commerce")

	oBrowse:Refresh(.F.)

	RestArea(aArea)

Return Nil

/*/{Protheus.doc} fPreco
Chama o JOB para atualiza��o do pre�o no site dos itens vendidos no E-Commerce.
@author VAMILLY-Gabriel Alencar
@since 04/11/2019
@return return, return_description
/*/
Static Function fPreco()
	Local aArea := GetArea()

	MsgRun("Atualizando pre�o dos produtos no E-Commerce", "Aguarde...", {|| U_JobPreco() } )

	MsgInfo("Processamento conclu�do. " + CLR + CLR + "Aguarde processamento das comunica��es para que seja integrado com o E-Commerce.", "Atualiza��o dos Pre�os do E-Commerce")

	oBrowse:Refresh(.F.)

	RestArea(aArea)

Return Nil

/*/{Protheus.doc} fCancel
Cancela internamente o pedido.
@author VAMILLY-Gabriel Alencar
@since 04/11/2019
@return return, return_description
/*/
Static Function fCancel()
	Local aArea := GetArea()

	If !Empty(Z03->Z03_PEDERP)

		MsgAlert("Somente pedidos n�o amarrados a um pedido do ERP podem ser cancelados.", "Cancelamento interno de Pedidos")

	ElseIf Z03->Z03_MSBLQL == '1'

		MsgAlert("Pedido j� cancelado internamente.", "Cancelamento interno de Pedidos")

	Else
		If MsgNoYes("Esta op��o ir� cancelar o pedido internamente, impossibilitando seu uso posterior e n�o poder� ser revertido." + CLR + CLR + ;
					"Deve ser usado somente em EXTREMA necessidade e preferencialmente com recomenda��o da PreCode/Vamilly." + CLR + CLR + ;
					"Obs.: Nenhuma informa��o ser� enviada para o E-Commerce com essa a��o. Este ser� cancelado SOMENTE NO PROTHEUS." + CLR + CLR ;
					, "Deseja realmente cancelar o pedido " + cValToChar(Z03->Z03_PEDSIT) + " internamente?")

			RecLock("Z03", .F.)
				Z03->Z03_MSBLQL := "1"
			Z03->(MsUnlock())

			U_fAddLog(Z03->Z03_PEDSIT, "Cancelamento interno do pedido") // Fun��o compilada no TLog.prw

			MsgAlert("Pedido " + cValToChar(Z03->Z03_PEDSIT) + " cancelado internamente.", "Cancelamento interno de Pedidos")

		EndIf

	EndIf

	oBrowse:Refresh(.F.)

	RestArea(aArea)

Return Nil

/*/{Protheus.doc} fPrepNF
Chama a rotina de prepara��o de NF e mostra os resultados das notas geradas com sucesso ou erro.
@author VAMILLY-Gabriel Alencar
@since 04/11/2019
@return return, return_description
/*/
Static Function fPrepNF()
	Local aRet := {}
	Local aArea := GetArea()
	Local aArrSay := {}
	Local aArrBut := {}

	Local nI := 0
	Local lExeFun := .F.
	Local cMensagem := ""

	Pergunte("ECOMNFE   ", .F.)

	aAdd(aArrSay, 'Esta rotina tem por objetivo gerar as notas fiscais dos ')
	aAdd(aArrSay, 'pedidos do E-Commerce com Pedido ERP.')
	aAdd(aArrSay, '')
	aAdd(aArrSay, 'Obs.: Esta rotina ir� apenas preparar os documentos de sa�da. ')
	aAdd(aArrSay, 'A transmiss�o deve ser feita posteriormente pela rotina padr�o.')

	aAdd(aArrBut, {1, .T., {|| lExeFun := .T., FechaBatch()}})
	aAdd(aArrBut, {2, .T., {|| lExeFun := .F., FechaBatch()}})
	aAdd(aArrBut, {5, .T., {|| lExeFun := .F., Pergunte("ECOMNFE   ", .T.)}})

	// Tipos de Botoes
	// 1 Ok
	// 2 Cancelar
	// 3 Excluir
	// 4 Incluir
	// 5 Param.

	FormBatch('Gera��o de Documentos de Sa�da', aArrSay, aArrBut,,200,530)

	If lExeFun
		Processa( {|| aRet := fPrepDoc() }, "Aguarde, preparando documentos de sa�da...", "", .F.)

		cMensagem += "Pedido (s) com Sucesso:" + Chr(13) + Chr(10)

		For nI := 1 to Len(aRet[1])
			cMensagem += aRet[1][nI] + Chr(13) + Chr(10)
			cMensagem += "-----------------------------------------" + Chr(13) + Chr(10)
		Next

		cMensagem += Chr(13) + Chr(10)
		cMensagem += "Pedido (s) com Erro:" + Chr(13) + Chr(10)

		For nI := 1 to Len(aRet[2])
			cMensagem += aRet[2][nI] + Chr(13) + Chr(10)
			cMensagem += "-----------------------------------------" + Chr(13) + Chr(10)
		Next

		// Se n�o teve erro nem nota gerada, n�o havia nenhuma apta no range
		If Empty(aRet[1]) .AND. Empty(aRet[2])
			MsgInfo("Nenhum pedido Apto para gerar NF de acordo com os par�metros informados.", "Gera��o de Documentos de Sa�da - E-Commerce")
		Else
			u_zMsgLog(cMensagem, "Gera��o de Documentos de Sa�da - E-Commerce", 1, .F.)
		EndIf

	EndIf

	oBrowse:Refresh(.F.)

	RestArea(aArea)

Return Nil

/*/{Protheus.doc} fPrepDoc
Prepara os documentos de sa�da referente aos pedidos informados e n�o faturados.
@author VAMILLY-Gabriel Alencar
@since 04/11/2019
@return return, return_description
@obs Utilizado l�gica do Gilvan R. Prioto - 30/04/2018 para gera��o dos documentos de sa�da.
/*/
Static Function fPrepDoc()
	Local aOK := {}
	Local aErros := {}
	Local aPvlNfs := {}
	Local aAreaZ03 := Z03->(GetArea())

	Local cNota := ""
	Local cAlias := GetNextAlias()
	Local cSerieNF := GetNewPar("MV_XSERSIT", "A") // Serie padrao das NF do E-Commerce.

	Local nCount := 0
	Local nPrcVen := 0

	// Busca os pedidos que ainda n�o tem NF gerada
	BeginSQL Alias cAlias
		SELECT Z03_PEDSIT,
			   Z03_PEDERP,
			   R_E_C_N_O_ AS RECNO
		  FROM %Table:Z03% Z03
		 WHERE Z03_FILIAL = %xFilial:Z03%
		 	   AND Z03_PEDSIT BETWEEN %Exp:MV_PAR01% AND %EXP:MV_PAR02%
			   AND Z03_DOCNF = ''
			   AND Z03_PEDERP <> ''
		 	   AND Z03.%NotDel%
	EndSQL

	// Conta os itens e reposiciona no inicio
	Count To nCount
	(cAlias)->(DBGoTop())
	ProcRegua(nCount)

	While !(cAlias)->(Eof())

		IncProc("Preparando documento para o pedido " + AllTrim((cAlias)->Z03_PEDERP) + "...")
		ProcessMessage()

		Z03->(DBSetOrder(1)) // Z03_FILIAL + Z03_PEDSIT
		Z03->(MSSeek(xFilial("Z03") + Str((cAlias)->Z03_PEDSIT, TamSX3("Z03_PEDSIT")[1])) )

		DBSelectArea("SC5")
		SC5->(DBSetOrder(1))
		SC5->(DBSeek(xFilial("SC5") + (cAlias)->Z03_PEDERP))

		DBSelectArea("SC6")
		SC6->(DBSetOrder(1))
		SC6->(MSSeek(xFilial("SC6") + (cAlias)->Z03_PEDERP))

		aPvlNfs := {}

		// Se o pedido n�o estiver liberado, n�o continua
		// Regra do MATA410 para pedidos liberados "!Empty(C5_LIBEROK) .AND. Empty(C5_NOTA) .AND. Empty(C5_BLQ)"
		If !Empty(SC5->C5_LIBEROK) .AND. Empty(SC5->C5_NOTA) .AND. Empty(SC5->C5_BLQ)

			// Percorre os itens liberados do pedido para processar gerar a NF
			While !SC6->(Eof()) .AND. SC6->C6_FILIAL == xFilial("SC6") .AND. SC6->C6_NUM == SC5->C5_NUM

				SC9->(DBSetOrder(1))
				SC9->(MSSeek(xFilial("SC9") + SC6->(C6_NUM+C6_ITEM))) 			//FILIAL+NUMERO+ITEM

				SE4->(DBSetOrder(1))
				SE4->(DBSeek(xFilial("SE4") + SC5->C5_CONDPAG) )  				//FILIAL+CONDICAO PAGTO

				SB1->(DBSetOrder(1))
				SB1->(MSSeek(xFilial("SB1") + SC6->C6_PRODUTO))    				//FILIAL+PRODUTO

				SB2->(DBSetOrder(1))
				SB2->(MSSeek(xFilial("SB2") + SC6->(C6_PRODUTO+C6_LOCAL))) 	    //FILIAL+PRODUTO+LOCAL

				SF4->(DBSetOrder(1))
				SF4->(MSSeek(xFilial("SF4") + SC6->C6_TES))   					//FILIAL+TES

				nPrcVen := SC9->C9_PRCVEN

				// Caso a moeda do pedido seja diferente de R$, faz a convers�o
				If (SC5->C5_MOEDA != 1)
					nPrcVen := xMoeda(nPrcVen, SC5->C5_MOEDA, 1, MsDate())
				EndIf

				// Armazena dados para geracao da nota fiscal
				aAdd(aPvlNfs, { SC9->C9_PEDIDO,;
								SC9->C9_ITEM,;
								SC9->C9_SEQUEN,;
								SC9->C9_QTDLIB,;
								nPrcVen,;
								SC9->C9_PRODUTO,;
								.F.,;
								SC9->(Recno()),;
								SC5->(Recno()),;
								SC6->(Recno()),;
								SE4->(Recno()),;
								SB1->(Recno()),;
								SB2->(Recno()),;
								SF4->(Recno()) })

				SC6->(DBSkip())
			EndDo

			Begin Transaction

				// Rotina automatica que faz a geracao da nota fiscal
				cNota := MaPvlNfs(aPvlNfs, cSerieNF, .F., .F., .F., .T., .F., 0, 0, .T.,.F.,)

				If !Empty(cNota)
					aAdd(aOK, "Pedido: " + AllTrim((cAlias)->Z03_PEDERP) + " > NF/Serie: " + AllTrim(cNota) + "/" + cSerieNF )

					// Posiciona no pedido do e-commerce para adicionar a chave da NF gerada
					Z03->(DBGoTo((cAlias)->RECNO))

					RecLock("Z03", .F.)
						// Z03->Z03_CHVNFE := SF2->F2_CHVNFE
						Z03->Z03_DOCNF := cNota
						Z03->Z03_SERIE := cSerieNF
					Z03->(MsUnlock())

					U_fAddLog(Z03->Z03_PEDSIT, "Preparado Documento de Sa�da " + AllTrim(cNota) + "/" + cSerieNF) // Fun��o compilada no TLog.prw

				Else
					DisarmTransaction()
					aAdd(aErros, "Pedido: " + AllTrim((cAlias)->Z03_PEDERP) )
					U_fAddLog(Z03->Z03_PEDSIT, "Erro ao preparar Documento de Sa�da") // Fun��o compilada no TLog.prw
					Break
				EndIf

			End Transaction

		Else
			aAdd(aErros, "Pedido: " + AllTrim((cAlias)->Z03_PEDERP) + " n�o est� liberado." )
			U_fAddLog(Z03->Z03_PEDSIT, "Erro ao preparar Documento de Sa�da pois o pedido n�o est� liberado.") // Fun��o compilada no TLog.prw
		EndIf

		(cAlias)->(DBSkip())
	EndDo

	If Select(cAlias) > 0
		(cAlias)->(DBCloseArea())
	EndIf

	RestArea(aAreaZ03)

Return {aOK, aErros}

/*/{Protheus.doc} fGeraPedidos
Chama a rotina para cria��o dos pedidos de venda do ERP para os pedidos do site selecionados.
@author VAMILLY-Gabriel Alencar
@since 04/11/2019
@return return, return_description
/*/
Static Function fGeraPedidos()
	Local nI := 0
	Local aRet := {}
	Local aArea := GetArea()
	Local cMensagem := ""

	If MsgNoYes(" - Ser� gerado um PV para cada pedido do E-Commerce;" + CLR + ;
				" - Caso o cliente (CPF/CNPJ) + Endere�o n�o exista na base, este ser� cadastrado; " + CLR + ; //. Se existir seus dados ser�o atualizados;" + CLR + ;
				" - Este processo n�o pode ser desfeito, e o E-Commerce ser� informado que foi gerado um PV.", ;
				"Deseja realmente gerar PV para os pedidos selecionados? " )


		Processa( {|| aRet := fProcPedido() }, "Aguarde...", "", .F.)

		If aRet[2] > 0
			FwAlertSuccess("Total de pedidos gerados: " + cValToChar(aRet[2]) + ". Selecionados: " + cValToChar(aRet[1]), "Gera��o de Pedidos finalizada")


			For nI := 1 to Len(aRet[4])
				cMensagem += "Pedido Site: " + AllTrim(aRet[4][nI][1]) + " > Pedido ERP: " + AllTrim(aRet[4][nI][2]) + Chr(13) + Chr(10)
				cMensagem += "-----------------------------------------" + Chr(13) + Chr(10)
			Next

			u_zMsgLog(cMensagem, "Gera��o de Pedidos - E-Commerce", 1, .F.)

			// BrwInvert(oBrowse:Mark(), .F.)
			oBrowse:Refresh(.F.)

		Else
			MsgAlert("Nenhum pedido foi gerado.", "Gera��o de Pedidos - E-Commerce")
		EndIf

	EndIf

	RestArea(aArea)

Return Nil

/*/{Protheus.doc} fProcPedido
Processa a gera��o dos pedidos de venda dos itens marcados no Browse.
@author VAMILLY-Gabriel Alencar
@since 04/11/2019
@return return, return_description
/*/
Static Function fProcPedido()
	Local nI := 0
	Local nVolume := 0
	Local nValDiff := 0
	Local nPercDiff := GetNewPar("MV_XPERSIT", 0) // Percentual m�ximo de diferen�a entre o pre�o do site e da tabela de pre�o
	Local nRegistros := 0
	Local nProcessados := 0
	Local nValFrete
	Local nValDesc

	// Variaveis calculadas para manipula��o do pre�o
	Local nTotal := 0
	Local nAliqIPI := 0
	Local nPrVendido := 0
	Local nPrVendaUnit := 0

	Local cPedido := ""
	Local cFiltro := "Z03->Z03_OK == " + ValToSQL(oBrowse:Mark())
	Local cArmOri := GetNewPar("MV_XARMSIT", "01") // Armaz�m que controlar� o saldo dos itens do E-Commerce
	Local cTesVend := GetNewPar("MV_XTESITE", "501") // TES utilizada na venda dos pedidos para o E-Commerce
	Local cTabPreco := GetNewPar("MV_XTABSIT", "002") // Tabela de pre�o do E-Commerce
	Local cMensagem := ""
	Local cVendedor := ""
	Local cPostParam := ""

	Local aOK := {}
	Local aErros := {}
	Local aCabec := {}
	Local aItens := {}
	Local aLinha := {}
	Local aCadCli := {}
	Local aCliente := {}
	Local aAreaSA4 := SA4->(GetArea())
	Local aAreaSB1 := SB1->(GetArea())
	Local aTabPreco := {}
	Local aCondicao := {}

	Local oMediador := Nil

	Local lContinua := .T.
	Local lTravaSaldo := GetNewPar("MV_XSLDSIT", .T.) // Par�metro que define se a rotina de gera��o de pedidos ir� travar em caso de falta de saldo no sistema
	Local lTravaPreco := GetNewPar("MV_XPRCSIT", .T.) // Par�metro que define se a rotina de gera��o de pedidos ir� travar em caso de diferen�a percentual do pre�o do E-Commerce

	DBSelectArea("Z03")
	Z03->(DBSetOrder(1)) // Z03_FILIAL + Z03_PEDSIT
	Z03->(DBSetFilter({|| &cFiltro }, cFiltro))
	Z03->(DBGoTop())

	// Conta a quantidade de registros a importar e reposiciona
	Count to nRegistros
	ProcRegua(nRegistros)
	Z03->(DBGoTop())

	DBSelectArea("Z04")
	Z04->(DBSetOrder(1)) // Z04_FILIAL + Z04_PEDSIT

	DBSelectArea("SA1")
	DBSelectArea("SA4")
	DBSelectArea("SB1")

	While !Z03->(Eof())

		IncProc("Gerando pedidos de venda...")
		ProcessMessage()

		aCabec := {}
		aItens := {}
		aLinha := {}
		nVolume := 0

		Begin Transaction

			// Valida a existencia do vendedor, pois � usado no cadastro de cliente e do pedido
			cVendedor := fFindVend(Z03->Z03_AFILIA) // Busca o vendedor do Pedido, baseado no Marketplace utilizado pelo cliente

			If Empty(cVendedor)
				DisarmTransaction()
				aAdd(aErros, {cValToChar(Z03->Z03_PEDSIT), "Vendedor " + AllTrim(Z03->Z03_AFILIA) + " n�o encontrado no cadastro de regras do Marketplace." })
				U_fAddLog(Z03->Z03_PEDSIT, "Vendedor " + AllTrim(Z03->Z03_AFILIA) + " n�o encontrado no cadastro de regras do Marketplace.", Nil) // Fun��o compilada no TLog.prw
				Break
			EndIf

			//-----------------------------------------
			// Valida existencia do cliente/endere�o
			//-----------------------------------------
			aCliente := fLojExist(Z03->Z03_CGC, Z03->Z03_END)

			If !aCliente[1] // Se o cliente n�o existe, cadastra
				aCadCli := fCadCli()
			ElseIf aCliente[1] .AND. !aCliente[2] // Se o cliente existe, mas a loja ainda n�o, cadastra a loja
				aCadCli := fCadCli(.T.)
			Else // Se o cliente existe, e a loja tambem, altera o cadastro
				// aCadCli := fCadCli(.F., aCliente[3], aCliente[4])
				// Feito assim agora pois o Protheus est� com um erro no ExecAuto, que trata o alerta de CPF ja cadastrado como erro do ExecAuto.
				aCadCli := {.T., aCliente[3], aCliente[4]}
			EndIf

			// Obs.: � poss�vel que o comportamento das inclus�es seja igonorado, pois existem customiza��es do cliente nas codifica��es de cliente.

			If aCadCli[1]
				cCliente := aCadCli[2]
				cLoja := aCadCli[3]
			Else
				DisarmTransaction()
				aAdd(aErros, {cValToChar(Z03->Z03_PEDSIT), aCadCli[2]})
				U_fAddLog(Z03->Z03_PEDSIT, "Erro ao cadastrar/alterar cliente: " + Z03->Z03_CGC, Nil, fArrToStr(aCadCli[2])) // Fun��o compilada no TLog.prw
				Break
			EndIf

			// Caso a empresa deseje travar em caso de falta de saldo, valida o saldo dos itens do pedido
			If lTravaSaldo
				If !fSaldoPed(Z03->Z03_PEDSIT)
					DisarmTransaction()
					aAdd(aErros, {cValToChar(Z03->Z03_PEDSIT), "Pedido com itens sem saldo de produto acabado."})
					U_fAddLog(Z03->Z03_PEDSIT, "Pedido com itens sem saldo de produto acabado.") // Fun��o compilada no TLog.prw
					Break
				EndIf
			EndIf

			//----------------------------------
			// Processamento do Cabe�alho do pedido
			//----------------------------------
			// cPedido := GetSxeNum("SC5", "C5_NUM")
			aCondicao := fGetCond(cVendedor, Z03->Z03_QTDPAR) // Busca a condi��o de pagamento baseado nas parcelas e regras de pagamento do Marketplace (Afiliado) utilizado

			// N�o continua caso a condi��o de pagamento n�o exista, ou o Marketplace n�o possui regra definida
			If !aCondicao[1]
				DisarmTransaction()
				aAdd(aErros, {cValToChar(Z03->Z03_PEDSIT), aCondicao[3] })
				U_fAddLog(Z03->Z03_PEDSIT, "Erro na condi��o de pagamento do pedido.", Nil, aCondicao[3]) // Fun��o compilada no TLog.prw
				Break
			EndIf

			// aAdd(aCabec, {"C5_NUM"		, cPedido					, Nil})
   			aAdd(aCabec, {"C5_TIPO"		, "N"							, Nil}) // Normal
   			aAdd(aCabec, {"C5_CLIENTE"	, cCliente						, Nil})
   			aAdd(aCabec, {"C5_LOJACLI"	, cLoja							, Nil})
   			aAdd(aCabec, {"C5_CLIENT"	, cCliente						, Nil})
   			aAdd(aCabec, {"C5_LOJAENT"	, cLoja							, Nil})
   			aAdd(aCabec, {"C5_TIPOCLI"	, "F"							, Nil}) // Consumidor Final
   			aAdd(aCabec, {"C5_CONDPAG"	, aCondicao[2]					, Nil})
   			aAdd(aCabec, {"C5_TPFRETE"	, "C"							, Nil}) // CIF - https://tdn.totvs.com/display/public/ConSeg/Frete+-+Conceito+de+Frete+-+CIF+e+FOB
   			aAdd(aCabec, {"C5_FRETE"	, Z03->Z03_FRETE				, Nil})
   			aAdd(aCabec, {"C5_VEND1"	, cVendedor						, Nil})
   			aAdd(aCabec, {"C5_ESPECI1"	, "CAIXA"						, Nil})
   			aAdd(aCabec, {"C5_FECENT"	, Z03->Z03_PREENT				, Nil})

			// Caso haja transportadora informada, busca o c�digo da mesma e adiciona no pedido
			If !Empty(Z03->Z03_TRCGC)

				SA4->(DBSetOrder(3)) // A4_FILIAL + A4_CGC
				If SA4->(MSSeek(xFilial("SA4") + Z03->Z03_TRCGC))
   					aAdd(aCabec, {"C5_TRANSP", SA4->A4_COD	, Nil})
				EndIf

			EndIf

			nValFrete := Z03->Z03_FRETE
			nValDesc  := Z03->Z03_VALDES
			//----------------------------------
			// Processamento dos itens do pedido
			//----------------------------------

			Z04->(MSSeek(xFilial("Z04") + Str(Z03->Z03_PEDSIT, TamSX3("Z04_PEDSIT")[1])) )

			While !Z04->(Eof()) .AND. (Z04->Z04_FILIAL + Str(Z04->Z04_PEDSIT, TamSX3("Z04_PEDSIT")[1])) == (xFilial("Z04") + Str(Z03->Z03_PEDSIT, TamSX3("Z03_PEDSIT")[1]))
				aLinha := {}

				// Valida o pre�o de venda do E-Commerce x Pre�o da tabela
				// Somente se houver percentual definido e estiver configurado para tra var
				If nPercDiff > 0 .AND. lTravaPreco

					// Busca o pre�o do item na tabela de pre�o do E-Commerce
					aTabPreco := U_fTabPreco(cTabPreco, Z04->Z04_PRODUT) // Fun��o compilada no JobPreco.prw

					// Se o item tiver pre�o de tabela, faz as valida��es
					If aTabPreco[1]
						nValDiff := (nPercDiff / 100) * aTabPreco[2]

						// Verifica se a diferen�a entre Pre�o da Tabela - Pre�o vendido � maior que a tolerancia
						If (aTabPreco[2] - Z04->Z04_PRCVEN) > nValDiff

							cMensagem := ""
							cMensagem += "Pedido: " 	  + cValToChar(Z04->Z04_PEDSIT) + CLR
							cMensagem += "Item: " 		  + Z04->Z04_ITEM + CLR
							cMensagem += "Produto: " 	  + AllTrim(Z04->Z04_PRODUT) + CLR
							cMensagem += "Quantidade: "   + cValToChar(Z04->Z04_QTDVEN) + CLR
							cMensagem += "Pre�o Tabela: " + cValToChar(aTabPreco[2]) + CLR
							cMensagem += "Pre�o Site: "   + cValToChar(Z04->Z04_PRCVEN) + CLR
							cMensagem += "Toler�ncia: "   + cValToChar(nPercDiff) + "%" + CLR + CLR

							// Caso n�o deseje continuar, ser� necess�rio interven��o manual no site com a PreCode e TI para ajustar o pre�o
							If MsgNoYes(cMensagem + "Deseja prosseguir com a libera��o mediante senha?", "Toler�ncia entre Pre�o de Tabela x Pre�o do E-Commerce ultrapassada")

								// Valida a senha digitada
								If !fPassword()
									MsgAlert("Senha inv�lida. Pedido n�o ser� gerado.", "Toler�ncia entre Pre�o de Tabela x Pre�o do E-Commerce ultrapassada")
									lContinua := .F.
								Else
									U_fAddLog(Z03->Z03_PEDSIT, "Toler�ncia de pre�o liberada com senha", Nil, cMensagem) // Fun��o compilada no TLog.prw
								EndIf

							Else
								lContinua := .F.
							EndIf

							// Caso a senha n�o esteja correta, ou o usu�rio n�o quis continuar com a diferen�a, n�o processa este pedido
							If !lContinua

								DisarmTransaction()
								aAdd(aErros, {cValToChar(Z03->Z03_PEDSIT), "Toler�ncia de pre�o ultrapasasada." + CLR + cMensagem })
								U_fAddLog(Z03->Z03_PEDSIT, "Toler�ncia de pre�o n�o liberada", Nil, cMensagem) // Fun��o compilada no TLog.prw
								Break

							EndIf

						EndIf

					EndIf

				EndIf

				SB1->(DBSetOrder(1)) // B1_FILIAL + B1_COD
				SB1->(MSSeek(xFilial("SB1") + Z04->Z04_PRODUT))

				// ----------------------------------------------------------------------------------
				// Regra solicitada pelo Chan (Braslar), para desconsiderar do valor do item o IPI
				//  para que o Protheus calcule conforme a TES no faturamento do pedido.
				// ----------------------------------------------------------------------------------

				// Guarda a al�quota de IPI do item
				nAliqIPI := SB1->B1_IPI
				// Guarda os valores padr�es originados do E-Commerce
				nTotal := Z04->Z04_TOTAL + nValFrete
				nPrVendido := Z04->Z04_PRCVEN
				nPrVendaUnit := Z04->Z04_VALOR

				// Caso esteja definido uma aliquota para o item, faz os c�lculos de abatimento do IPI das vari�veis
				If nAliqIPI > 0

					nBaseIpi := nTotal/((100+nAliqIPI)/100)
					nBaseIpi := nBaseIpi - nValFrete

					// Guarda o fator de c�lculo
					//nAliqIPI := Round((nAliqIPI / 100), 2)

					// Subtrai a parte do valor que � referente a IPI
					//nPrVendido -= Round((nPrVendido * nAliqIPI), 2)
					nPrVendido := Round((nBaseIpi), 2)
				    nPrVendaUnit := Round((nPrVendaUnit - (nPrVendaUnit - nBaseIpi)), 2)

					// Recalcula o total
					nTotal := Round(Z04->Z04_QTDVEN * nPrVendido, 2)
				EndIf

				aAdd(aLinha, {"C6_ITEM"		, Z04->Z04_ITEM 							, Nil})
				aAdd(aLinha, {"C6_PRODUTO"	, Z04->Z04_PRODUT 							, Nil})
				aAdd(aLinha, {"C6_QTDVEN"	, Z04->Z04_QTDVEN 							, Nil})
				aAdd(aLinha, {"C6_PRCVEN"	, nPrVendido 								, Nil})
				aAdd(aLinha, {"C6_PRUNIT"	, nPrVendaUnit 								, Nil})
				aAdd(aLinha, {"C6_VALOR"	, nTotal 									, Nil})
				aAdd(aLinha, {"C6_TES"		, cTesVend 									, Nil})
				aAdd(aLinha, {"C6_LOCAL"	, cArmOri 									, Nil})
				aAdd(aLinha, {"C6_VALDESC"	, IIF(((nPrVendaUnit * Z04->Z04_QTDVEN) - nTotal) < 0,0,((nPrVendaUnit * Z04->Z04_QTDVEN) - nTotal)), Nil})
				aAdd(aLinha, {"C6_ENTREG"	, Z03->Z03_PREENT							, Nil})

				// todo: TRATAR ESTE CAMPO NO CLIENT
				// aAdd(aLinha, {"C6_UNSVEN"	, nTotal 	, Nil}) // Quant Seg. Unidadae de Medida

				// Incrementa a quantidade de volumes do pedido
				nVolume += Val(Z04->Z04_VOLUME)

				aAdd(aItens, aLinha)

				nValFrete := 0

				Z04->(DBSkip())
			EndDo

			// Campo quantidade de volumes do pedido
			aAdd(aCabec, {"C5_VOLUME1"	, nVolume			, Nil})

			// Restaurado area do cadastro de transportadora e produto para n�o dar erro na valida��o do ExecAuto pois utilizo outro indice
			RestArea(aAreaSB1)
			RestArea(aAreaSA4)

			// Processa a inclu��o do pedido
			lMsErroAuto := .F.
			MSExecAuto({|a, b, c, d| MATA410(a, b, c, d)}, aCabec, aItens, 3, .F.)

			If lMsErroAuto
				DisarmTransaction()
				aAdd(aErros, {cValToChar(Z03->Z03_PEDSIT), GetAutoGRLog()})
				U_fAddLog(Z03->Z03_PEDSIT, "Erro na gera��o do Pedido de Venda interno", Nil, fArrToStr(aErros[Len(aErros)][2])) // Fun��o compilada no TLog.prw
				// RollbackSx8()
				Break
			Else
				nProcessados++
				aAdd(aOK, {cValToChar(Z03->Z03_PEDSIT), SC6->C6_NUM})
				// ConfirmSx8()

				// Preenche o pedido do sistema no controle de pedidos do e-commerce
				RecLock("Z03", .F.)
					Z03->Z03_OK := " "
					Z03->Z03_PEDERP := SC6->C6_NUM
				Z03->(MsUnlock())

				cPostParam := '{"pedido": [{"codigoPedido": ' + cValToChar(Z03->Z03_PEDSIT) + ', "numeroPedidoERP": ' + cValToChar(Val(Z03->Z03_PEDERP)) + ' }]}'

				// Informa ao E-Commerce que o pedido foi gerado
				oMediador := TMediador():New()
				oMediador:Z05_PEDSIT := Z03->Z03_PEDSIT
				oMediador:Z05_DESC := "Aceite no Pedido " + cValToChar(Z03->Z03_PEDSIT)
				oMediador:Z05_VERBO := "PUT"
				oMediador:Z05_PATH := "erp/aceite"
				oMediador:Z05_POSTPA := cPostParam
				oMediador:Add()

				U_fAddLog(Z03->Z03_PEDSIT, "Gerado Pedido de Venda interno " + Z03->Z03_PEDERP) // Fun��o compilada no TLog.prw

				FWFreeVar(oMediador)

			EndIf

		End Transaction

		Z03->(DBSkip())

	EndDo

	If Len(aErros) > 0
		lAutoErrNoFile := .F.

		// AutoGrLog("-------------------------------------------------")
		AutoGrLog("Erro no processamento dos seguintes pedidos:")
		AutoGrLog("")

		For nI := 1 to Len(aErros)
			AutoGrLog("Pedido: " + aErros[nI][1])

			// Caso seja um erro de ExecAuto pode haver mais de uma linha de erro
			If ValType(aErros[nI][2]) == "A"
				AutoGrLog("Erros: ")
				AutoGrLog(fArrToStr(aErros[nI][2])) // Transforma o Array em texto

			Else
				AutoGrLog("Erro: " + aErros[nI][2])
			EndIf

		Next

		AutoGrLog("-------------------------------------------------")

		// Mostra a mensagem de Erro
		If !IsBlind()
			MostraErro()
		EndIf

		lAutoErrNoFile := .T.
	EndIf

	Z03->(DBClearFilter())

Return {nRegistros, nProcessados, aErros, aOK}

/*/{Protheus.doc} fCadCli
Efetua a manuten��o do cliente do E-Commerce conforme par�metros informados.
@author VAMILLY-Gabriel Alencar
@since 04/11/2019
@return return, return_description
@param lInserir, logical, Define se ir� inserir ou alterar.
@param cCliente, characters, C�digo do cliente a inserir/alterar
@param cLoja, characters, Loja do cliente a inserir/alterar
/*/
Static Function fCadCli(lInserir, cCliente, cLoja)
	Local aRet := {}
	Local aAreaCC2 := CC2->(GetArea())
	Local aSA1Auto := {}
	Local aAI0Auto := {}
	Local nOpcAuto := 0
	Local cVendedor := fFindVend(Z03->Z03_AFILIA)
	Local cNatureza := GetNewPar("MV_XNATSIT", "1010001") // Natureza padr�o dos clientes do E-Commerce
	Local cContaContabil := GetNewPar("MV_XCCTSIT", "101020100001") // Conta Cont�bil padr�o dos clientes do E-Commerce

	Default lInserir := .T.
	Default cCliente := ""
	Default cLoja := ""

	// Inserir ou alterar o cliente
	nOpcAuto := IIF(lInserir, 3, 4)

	//----------------------------------
	// Dados do Cliente
	//----------------------------------

	aAdd(aSA1Auto, {"A1_COD"	, cCliente 					, Nil})
	aAdd(aSA1Auto, {"A1_LOJA"	, cLoja 					, Nil})
	aAdd(aSA1Auto, {"A1_PESSOA"	, Z03->Z03_PESSOA			, Nil})
	aAdd(aSA1Auto, {"A1_NOME" 	, Z03->Z03_NOME				, Nil})
	aAdd(aSA1Auto, {"A1_NREDUZ"	, Z03->Z03_NREDUZ			, Nil})
	aAdd(aSA1Auto, {"A1_TIPO"	, "F"						, Nil}) // Consumidor FinaL
	aAdd(aSA1Auto, {"A1_EST" 	, Z03->Z03_EST				, Nil})
	aAdd(aSA1Auto, {"A1_COD_MUN", POSICIONE("CC2", 2, xFilial("CC2") + AllTrim(Upper(Z03->Z03_MUN)), "CC2_CODMUN" ), Nil})
	aAdd(aSA1Auto, {"A1_END" 	, Z03->Z03_END				, Nil})
	aAdd(aSA1Auto, {"A1_MUN" 	, LEFT(Upper(Z03->Z03_MUN),15), Nil})
	aAdd(aSA1Auto, {"A1_REGIAO"	, fTrataRegiao(Z03->Z03_EST), Nil})
	aAdd(aSA1Auto, {"A1_BAIRRO" , Z03->Z03_BAIRRO			, Nil})
	aAdd(aSA1Auto, {"A1_CGC" 	, Z03->Z03_CGC				, Nil})
	aAdd(aSA1Auto, {"A1_CEP" 	, Z03->Z03_CEP				, Nil})
	aAdd(aSA1Auto, {"A1_DDD" 	, IIF(Empty(Z03->Z03_CELULA), Left(Z03->Z03_TEL, 2), Left(Z03->Z03_CELULA, 2)), Nil})
	aAdd(aSA1Auto, {"A1_TEL" 	, IIF(Empty(Z03->Z03_CELULA), Z03->Z03_TEL, Z03->Z03_CELULA), Nil})
	aAdd(aSA1Auto, {"A1_FAX" 	, IIF(Empty(Z03->Z03_TEL), Z03->Z03_TELCOM, Z03->Z03_TEL), Nil})
	aAdd(aSA1Auto, {"A1_CONTATO", Z03->Z03_RESREC			, Nil})
	aAdd(aSA1Auto, {"A1_PAIS" 	, "105"						, Nil}) // Brasil
	aAdd(aSA1Auto, {"A1_DTNASC" , Z03->Z03_DTNASC			, Nil})
	aAdd(aSA1Auto, {"A1_EMAIL" 	, Z03->Z03_EMAIL			, Nil})
	aAdd(aSA1Auto, {"A1_COMPLEM", Z03->Z03_COMPEN			, Nil})
	aAdd(aSA1Auto, {"A1_NATUREZ", cNatureza					, Nil}) // VENDA PROD.MERC.INTERNO
	aAdd(aSA1Auto, {"A1_CONTA"	, cContaContabil			, Nil}) // CLIENTES NACIONAIS DIVERSOS
	aAdd(aSA1Auto, {"A1_COMPLEM", Z03->Z03_COMPEN			, Nil})
	aAdd(aSA1Auto, {"A1_CODPAIS", "01058"					, Nil}) // Brasil
	aAdd(aSA1Auto, {"A1_RISCO"	, "A"						, Nil}) // Risco A - Cr�dito Ok
	aAdd(aSA1Auto, {"A1_INCISS" , "N"						, Nil})
	aAdd(aSA1Auto, {"A1_VEND" 	, cVendedor					, Nil}) // Marketplace utilizado pelo Cliente
	aAdd(aSA1Auto, {"A1_ENDCOB"	, LEFT(Z03->Z03_END,30)		, Nil})
	aAdd(aSA1Auto, {"A1_MUNC"	, LEFT(Upper(Z03->Z03_MUN),15), Nil})
	aAdd(aSA1Auto, {"A1_CEPC"	, Upper(Z03->Z03_CEP)       , Nil})
	aAdd(aSA1Auto, {"A1_CONTRIB", "2"  						, Nil})
	aAdd(aSA1Auto, {"A1_SIMPLES", "2"  						, Nil})
	aAdd(aSA1Auto, {"A1_SIMPNAC", "2"  						, Nil})
	aAdd(aSA1Auto, {"A1_BAIRROC", LEFT(Z03->Z03_BAIRRO,30)	, Nil})
	aAdd(aSA1Auto, {"A1_ESTC"	, Z03->Z03_EST				, Nil})
	// aAdd(aSA1Auto, {"A1_IBGE" 	, Z03->Z03_IBGE		, Nil})

	//---------------------------------------------------------
	// Dados do Complemento do Cliente
	//---------------------------------------------------------
	aAdd(aAI0Auto, {"AI0_SALDO"  , 0						, Nil})

	// Restaurado area do cadastro de clientes para n�o dar erro na valida��o do ExecAuto pois utilizo outro indice
	RestArea(aAreaCC2)

	//------------------------------------
	// Chamada para cadastrar o cliente.
	//------------------------------------
	lMsErroAuto := .F.
	MSExecAuto({|a,b,c| CRMA980(a,b,c)}, aSA1Auto, nOpcAuto, aAI0Auto)

	If lMsErroAuto
		aRet := {.F., GetAutoGrLog()}
	Else
		aRet := {.T., SA1->A1_COD, SA1->A1_LOJA}
		U_fAddLog(Z03->Z03_PEDSIT, IIF(lInserir, "Cadastrado", "Alterado") + " cliente/loja: " + AllTrim(SA1->A1_COD) + "/" + SA1->A1_LOJA) // Fun��o compilada no TLog.prw
	EndIf

Return aRet

/*/{Protheus.doc} fTrataRegiao
Fun��o para tratar a regi�o dos estados do Brasil.
@author VAMILLY-Gabriel Alencar
@since 04/11/2019
@return return, return_description
@param cEstado, characters, descricao
@obs Fun��o criada, pois o campo regi�o � obrigat�rio na Braslar.
/*/
Static Function fTrataRegiao(cEstado)
	Local cRegiao := ""
	Local cNorte := "AM;RR;AP;PA;TO;RO;AC"
	Local cSul := "PR;RS;SC"
	Local cNordeste := "MA;PI;CE;RN;PE;PB;SE;AL;BA"
	Local cSudeste := "SP;RJ;ES;MG"
	Local cCentroOeste := "MT;MS;GO"

	Do Case
		Case AllTrim(cEstado) $ cNorte
			cRegiao := "001"
		Case AllTrim(cEstado) $ cSul
			cRegiao := "002"
		Case AllTrim(cEstado) $ cNordeste
			cRegiao := "003"
		Case AllTrim(cEstado) $ cSudeste
			cRegiao := "004"
		Case AllTrim(cEstado) $ cCentroOeste
			cRegiao := "005"
	End Case

Return cRegiao

/*/{Protheus.doc} fIsPedSite
Verifica se o pedido informado est� amarrado a um pedido do E-Commerce.
@author VAMILLY-Gabriel Alencar
@since 11/11/2019
@return return, return_description
@param cPedido, characters, Pedido a ser verificado
@param cSerie, characters, S�rie da nota a ser verificada
/*/
User Function fIsPedSite(cPedido)
    Local lRet := .F.
    Local aAreaZ03 := Z03->(GetArea())
	Local nPedidoSite := 0

    DBSelectArea("Z03")
    Z03->(DBSetOrder(2)) // Z03_FILIAL + Z03_PEDERP

    // Verifica se o pedido informado est� amarrado a um pedido do E-Commerce.
    If Z03->(MSSeek(xFilial("Z03") + PadR(cPedido, TamSX3("Z03_PEDERP")[1]) ))
        nPedidoSite := Z03->Z03_PEDSIT
		lRet := .T.
    EndIf

    RestArea(aAreaZ03)

Return {lRet, nPedidoSite}

/*/{Protheus.doc} fPassword
Mostra um Dialog para que o usu�rio informe a senha de libera��o da toler�ncia de pre�o.
@author Vamilly-Gabriel Alencar
@since 13/11/2019
@return return, return_description
/*/
Static Function fPassword()
	Local lRet := .F.
	Local cGetSenha := "                    "
	Local oDlgSenha := Nil

	@ 067,020 To 169,312 Dialog oDlgSenha Title OemToAnsi("Libera��o de Toler�ncia")
	@ 015,005 Say OemToAnsi("Informe a senha de libera��o:") Size 80,8
	@ 015,089 Get cGetSenha Size 50,10 Password
	@ 037,106 BmpButton Type 1 Action (lRet := fValidSenha(cGetSenha), oDlgSenha:End())
	@ 037,050 BmpButton Type 2 Action (lRet := .F., oDlgSenha:End())

	Activate Dialog oDlgSenha CENTERED

Return lRet

/*/{Protheus.doc} fValidSenha
Valida a senha informada em fPassword com a senha do par�metro.
@author Vamilly-Gabriel Alencar
@since 13/11/2019
@return return, return_description
@param cSenha, characters, Senha a ser validada.
/*/
Static Function fValidSenha(cSenha)
	Local lRet := .F.
	// Obs.: Para gerar uma senha nova, basta executar a fun��o MD5 conforme abaixo e gravar no par�metro o conte�do.
	Local cSenhaPreco := GetNewPar("MV_XSENPRC", MD5("123", 2)) // Senha utilizada para libera��o do pre�o com diferen�a maior que "MV_XPERSIT".

	// Criptografa a senha informada e compara com a senha j� criptografada no par�metro
	lRet := AllTrim(cSenhaPreco) == MD5(AllTrim(cSenha), 2)

Return lRet

/*/{Protheus.doc} fLojExist
Verifica se o cliente + Endere�o existem na base.
@author Vamilly-Gabriel Alencar
@since 18/11/2019
@return return, return_description
@param cCGC, characters, CNPJ/CPF do cliente a validar.
@param cEndereco, characters, Endere�o a validar.
/*/
Static Function fLojExist(cCGC, cEndereco)
	Local aAreaSA1 := SA1->(GetArea())
	Local lExist := .F.
	Local lLojaExist := .F.
	Local cLoja := ""
	Local cCliente := ""
	Local cLastLoja := ""

	DBSelectArea("SA1")
	SA1->(DBSetOrder(3)) // A1_FILIAL + A1_CGC
	lExist := SA1->(MSSeek(xFilial("SA1") + cCGC))

	// Se o cliente existir, verifica se ja existe o endere�o cadastrado
	If lExist
		// Guarda os dados do cliente
		cCliente := SA1->A1_COD
		cLoja := SA1->A1_LOJA

		While !SA1->(Eof()) .AND. (SA1->A1_FILIAL + SA1->A1_CGC) == (xFilial("SA1") + cCGC)

			// Caso o cliente j� exista e o endere�o for o mesmo continua, se n�o cria um novo cadastro
			If AllTrim(SA1->A1_END) == AllTrim(Z03->Z03_END)
				cCliente := SA1->A1_COD // Guarda o codigo do cliente do endere�o correspondente
				cLoja := SA1->A1_LOJA // Guarda a Loja do endere�o correspondente
				lLojaExist := .T. // Define que encontrou o endere�o em quest�o
				Exit // Sai do Loop sem desposicionar
			EndIf

			cLastLoja := SA1->A1_LOJA

			SA1->(DBSkip())
		EndDo

		// Comentado pois o Protheus n�o permite isso para clientes pessoa Fisica
		// Se o endere�o ainda n�o existir para o cliente encontrado, cria uma nova numera��o de loja
		// If !lLojaExist
		// 	cLoja := Soma1(cLastLoja)
		// EndIf

	EndIf

	RestArea(aAreaSA1)

Return {lExist, lLojaExist, cCliente, cLoja}

/*/{Protheus.doc} fArrToStr
Transforma um Array em String com quebra de linha.
@author Vamilly-Gabriel Alencar
@since 18/11/2019
@return return, return_description
@param aArray, array, Array a transformar.
/*/
Static Function fArrToStr(aArray)
	Local nI := 0
	Local cRet := ""

	For nI := 1 to Len(aArray)
		cRet += aArray[nI] + CLR
	Next

Return cRet

/*/{Protheus.doc} fFindVend
Busca o vendedor do Pedido, baseado no Marketplace utilizado pelo cliente
@author Vamilly-Gabriel Alencar
@since 19/11/2019
@return return, return_description
@param cAfiliado, characters, Nome do Afiliado a consultar.
/*/
Static Function fFindVend(cAfiliado)
	Local cRet := ""
	Local cVendDefault := GetNewPar("MV_XVESITE", "R00096") // C�digo do vendedor do E-Commerce PreCode

	DBSelectArea("Z07")
	Z07->(DBSetOrder(2)) // Z07_FILIAL + Z07_AFILIA

	// Se afiliado for Vazio, quer dizer que foi vendido pelo E-Commerce da PreCode, ent�o usa o vendedor Default
	If Empty(cAfiliado)
		cRet := cVendDefault
	ElseIf Z07->(MSSeek(xFilial("Z07") + PadR(Upper(cAfiliado), TamSX3("Z07_AFILIA")[1])) )
		cRet := Z07->Z07_VENDED
	EndIf

Return cRet

/*/{Protheus.doc} fGetCond
Busca a condi��o de pagamento baseado nas parcelas e regras de pagamento do Marketplace (Afiliado)
@author Vamilly-Gabriel Alencar
@since 20/11/2019
@return return, return_description
@param cVendedor, characters, Codigo do vendedor do Sistema.
@param nParcelas, numeric, Quantidade de parcelas do pedido.
/*/
Static Function fGetCond(cVendedor, nParcelas)
	Local lExist := .F.
	Local lAchou := .F.

	Local cErro := "Vendedor " + AllTrim(cVendedor) + " n�o cadastrado nas regras de Marketplace."
	Local cCondicao := ""
	// Condi��es de pagamento por parcela. Iniciando por Boleto, depois de 1 at� quantidade de parcelas utilizadas
	Local cCondPgto := GetNewPar("MV_XCONSIT", "1, 159, 207, 208, 209, 210, 211, 212, 213, 214, 215, 003, 004")

	Local aCondPgto := Strtokarr2(cCondPgto, ",", .F.) // Quebra as parcelas em um array

	DBSelectArea("Z07")
	Z07->(DBSetOrder(1)) // Z07_FILIAL + Z07_VENDED

	// Verifica se o vendedor est� cadastrado nas regras de Marketplace
	If Z07->(MSSeek(xFilial("Z07") + cVendedor) )
		lExist := .T.
		cErro := ""

		// Se for boleto, retorna a primeira condi��o
		If nParcelas == 0
			cCondicao := AllTrim(aCondPgto[1])
		Else
			// Trata a regra de Cart�o de Cr�dito conforme forma de pagamento do Afiliado do pedido
			// 1=Rateia Parcelas: Gera um t�tulo para cada parcela utilizada no pedido.
			// 2=Unifica Parcelas: Independente da quantidade de parcelas, gera apenas um t�tulo.

			If Z07->Z07_REGRA == "1"
				// Busca a condi��o de pagamento de acordo com as parcelas
				cCondicao := AllTrim(aCondPgto[nParcelas+1])
			Else
				// Condi��o de pagamento para 1 parcela
				cCondicao := AllTrim(aCondPgto[2])
			EndIf

			// Confirma se a condi��o de pagamento parametrizada existe
			SE4->(DBSetOrder(1)) // FILIAL + CONDICAO PAGTO
			If !SE4->(MSSeek(xFilial("SE4") + cCondicao) )
				lExist := .F.
				cErro := "Condi��o " + cCondicao + " n�o existe no cadastro de condi��es de pagamento."
			EndIf

		EndIf

	EndIf

Return {lExist, cCondicao, cErro}