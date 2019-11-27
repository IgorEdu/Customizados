#Include "Protheus.ch"

/*/{Protheus.doc} MA650BUT
Ponto de Entrada 'MA650BUT', utilizado para adicionar itens no menu  principal do fonte MATA650.PRX.
@author Braslar
@since -
@return return, return_description
@see https://tdn.totvs.com/display/public/PROT/MA650BUT+-+Adiciona+itens+no+menu+principal+do+fonte+MATA650
@history 27/11/2019, Vamilly-Gabriel Alencar, Movido função para um arquivo próprio.
/*/
User Function MA650BUT()

	aAdd( aRotina, { 'Etiquetas', 'U_ETIQBAR()', 0, 5 } )

Return aRotina