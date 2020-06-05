#Include "TOTVS.CH"
#Include "RWMAKE.CH"
#Include "TOPCONN.CH"
#Include "FWMVCDEF.CH"
#Include "PROTHEUS.CH"
#Include "FWMBROWSE.CH"

/*/{Protheus.doc} TClientRest
Classe para gerenciar as chamadas REST para consumo da API da PreCode.
@author VAMILLY-Gabriel Alencar
@since 04/11/2019
/*/
Class TClientRest
	// Propriedades
	Data aHeader
	Data cURLBase
	Data cLastError

	// Métodos
	Method New() Constructor
	Method CallWS(cPath, cVerb, aHeadParam, cPostParam)
	Method GetAprovados(nPage)
	Method GetStatus(nPedidoSite)

EndClass

/*/{Protheus.doc} New
Método construtor da instancia da classe.
@author VAMILLY-Gabriel Alencar
@since 04/11/2019
@return return, return_description
/*/
Method New() Class TClientRest
	Local cRestBase := GetNewPar("MV_XRESTBA", "replicade.com.br/api/v1/") // URL base da API REST da PreCode
	Local cAuthorization := GetNewPar("MV_XRESTAU", "Authorization: Basic SmtYYjc3YXEwZnpqM3h4Rzg6") // Autenticação REST da API da PreCode

	// Define os Headers da chamada REST
	::aHeader := {}

	aAdd(::aHeader, cAuthorization)
	// aAdd(::aHeader, "Authorization: Basic " + Encode64("app01:fTdUlDgdQQ4MRQhLahykiKhON6k97Zfly5SV6fwpa5zCE"))
	aAdd(::aHeader, "Content-Type: application/json")

	// Define a URL base do WebService
	::cURLBase := cRestBase

Return Self

/*/{Protheus.doc} MyError
Função para tratamento customizado dos erros.
@author VAMILLY-Gabriel Alencar
@since 04/11/2019
@return return, return_description
@param oError, object, Objeto de Exception a ser utilizado
@param cLastError, characters, Variável que terá seu valor alterado por referência com o erro de oError.
/*/
Static Function MyError(oError, cLastError)

	// Caso tenha interface com usuário mostra uma mensagem em tela
	If IsBlind()
		Conout("Exception in TClientRest - " + oError:Description)
	Else
		MsgBox(oError:Description, "Exception in TClientRest", "STOP")
	EndIf

	// Guarda a ultima Exception
	cLastError := oError:Description

	Break

Return

/*/{Protheus.doc} CallWS
Consome a API da PreCode utilizando um dos verbos REST e passando os parametros necessários.
@author VAMILLY-Gabriel Alencar
@since 04/11/2019
@return return, return_description
@param cPath, characters, Caminho da API a ser chamada
@param cVerb, characters, Verbo REST a ser utilizado (GET, POST, PUT, DELETE)
@param aHeadParam, array, Parâmetros de Header a ser enviado na chamada
@param cPostParam, characters, Parâmetro do Verbo POST/PUT a ser enviado á API
/*/
Method CallWS(cPath, cVerb, aHeadParam, cPostParam) Class TClientRest
	Local nI := 0
	Local aHead := AClone(::aHeader)
	Local bError := Nil
	Local xResult := Nil
	Local lReturn := .F.
	Local oRestClient := Nil

	Default cVerb := "GET"
	Default cPostParam := ""

	// Complementa os parâmetros do cabeçalho da chamada caso tenha sido informado
	If !Empty(aHeadParam)

		For nI := 1 to Len(aHeadParam)
			AAdd(aHead, aHeadParam[nI])
		Next

	EndIf

	// Instancia a classe Client Rest
	oRestClient := FWRest():New(::cURLBase)

	// Salva bloco de código do tratamento de erro
	bError := ErrorBlock( { |oError| MyError( oError, @::cLastError ) } )

	// Tratamento para casos de Exception nas requisições
	Begin Sequence

		// Define o caminho para requisição
		If !Empty(cPath)
			oRestClient:SetPath(AllTrim(cPath))
		EndIf

		// Trata o verbo a ser utilizado para fazer as requisições
		Do Case
			Case AllTrim(cVerb) == "GET"
				lReturn := oRestClient:Get(aHead)

			Case AllTrim(cVerb) == "POST"
				// Define os parâmetros de Post
				oRestClient:SetPostParams(cPostParam)

				lReturn := oRestClient:Post(aHead)

			Case AllTrim(cVerb) == "PUT"

				If !Empty(cPostParam)
					lReturn := oRestClient:Put(aHead, EncodeUTF8(cPostParam))
				Else
					lReturn := oRestClient:Put(aHead)
				EndIf

			Case AllTrim(cVerb) == "DELETE"
				lReturn := oRestClient:Delete(aHead)

			Otherwise
				UserException("Verbo " + cVerb + " não tratado por este Client")
		EndCase

		// Caso a chamada tenha sido bem sucedida, devolve o retorno
		If lReturn
			xResult := DecodeUTF8(oRestClient:GetResult(), "cp1252")

			U_fAddLog(-999999999, "Chamada REST " + AllTrim(cPath) + " com Verbo " + AllTrim(cVerb), Nil, xResult) // Função compilada no TLog.prw

		Else
			xResult := oRestClient:GetLastError()

			// Guarda o ultimo erro do Rest
			::cLastError := xResult

			If !Empty(oRestClient:GetResult())
				xResult += Chr(13) + Chr(10) + "--- Result: ---" + Chr(13) + Chr(10) + DecodeUTF8(oRestClient:GetResult(), "cp1252")
			EndIf

			U_fAddLog(-999999999, "Erro na chamada REST " + AllTrim(cPath) + " com Verbo " + AllTrim(cVerb), Nil, xResult) // Função compilada no TLog.prw

		EndIf

		Recover // Se ocorreu erro, após o BREAK
			lReturn := .F.
			xResult := ::cLastError
			U_fAddLog(-999999999, "Exception na chamada REST " + AllTrim(cPath) + " com Verbo " + AllTrim(cVerb), Nil, xResult) // Função compilada no TLog.prw

	End Sequence

	// Restaura tratamento de erro padrão do sistema
	ErrorBlock(bError)

	FWFreeVar(@oRestClient)

Return {lReturn, xResult}

/*/{Protheus.doc} GetAprovados
Consome a API que busca o JSON de pedidos aprovados
@author VAMILLY-Gabriel Alencar
@since 04/11/2019
@return return, return_description
@param nPage, numeric, Página (paginator) a ser considerado na chamada da API. Por Default a API retorna os primeiros 100 registros.
/*/
Method GetAprovados(nPage) Class TClientRest
	Local aRet := {}

	Default nPage := 1

	// Recupera lista de pedidos aprovados. (pedidos prontos para serem faturados).
	aRet := ::CallWS("erp/aprovado/" + cValToChar(nPage)) // erp/pedido/{númerodapagina}

Return aRet

/*/{Protheus.doc} GetStatus
Consome a API que busca o JSON de status de um pedido.
@author VAMILLY-Gabriel Alencar
@since 04/11/2019
@return return, return_description
@param nPedidoSite, numeric, descricao
/*/
Method GetStatus(nPedidoSite) Class TClientRest
	Local aRet := {}

	// Recupera o status do pedido
	aRet := ::CallWS("erp/status/" + cValToChar(nPedidoSite))

Return aRet