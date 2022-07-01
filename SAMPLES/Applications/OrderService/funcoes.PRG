/*
  sistema     : ordem de serviço
  programa    : funções genéricas
  compilador  : harbour
  lib gráfica : minigui extended
*/

FUNCTION Chk_Mes( parametro, tipo )

   IF tipo == 1
      RETURN{ 'JAN', 'FEV', 'MAR', 'ABR', 'MAI', 'JUN', ;
         'JUL', 'AGO', 'SET', 'OUT', 'NOV', 'DEZ' } [ Parametro ]
   ELSEIF tipo == 2
      RETURN{ 'Janeiro  ', 'Fevereiro', 'Marco    ', 'Abril    ', 'Maio     ', 'Junho    ', ;
         'Julho    ', 'Agosto   ', 'Setembro ', 'Outubro  ', 'Novembro ', ;
         'Dezembro ' } [ Parametro ]
   ENDIF
   // -------------------------------------------------------------------------------
FUNCTION Extenso( Amount )

   LOCAL cents, final_amount, par[ 3 ], temp, base, x
   final_amount := ''

   IF amount < 0
      final_amount := 'INCAPAZ DE IMPRIMIR'
   ELSEIF amount == 0
      final_amount := 'Zero'
   ELSE
      cents := Val( SubStr( Str( amount, 12, 2 ), 11 ) )
      par[ 1 ] := Val( SubStr( Str( amount, 12, 2 ), 1, 3 ) )
      par[ 2 ] := Val( SubStr( Str( amount, 12, 2 ), 4, 3 ) )
      par[ 3 ] := Val( SubStr( Str( amount, 12, 2 ), 7, 3 ) )
      FOR x := 1 TO 3
         IF par[ x ] <> 0
            IF x == 2 .AND. par[ x ] == 1
               final_amount += ' Mil'
               IF par[ 3 ] > 0
                  final_amount += ' e'
               ENDIF
            ELSE
               final_amount += Checkextenso( par[ x ] )
               IF x == 1
                  IF par[ 1 ] == 1
                     final_amount += ' Milhao'
                  ELSE
                     final_amount += ' Milhoes'
                  ENDIF
                  IF par[ 2 ] > 0 .OR. par[ 3 ] > 0
                     final_amount += ' e'
                  ENDIF
               ELSEIF x == 2
                  final_amount += ' Mil'
                  IF par[ 3 ] > 0
                     final_amount += ' e'
                  ENDIF
               ENDIF
            ENDIF
         ENDIF
      NEXT

      IF Int( amount ) == 1
         final_amount += ' Real'
      ELSEIF Int( amount ) > 1 .AND. par[ 2 ] == 0 .AND. par[ 3 ] == 0
         final_amount += ' de Reais'
      ELSEIF Int( amount ) > 1
         final_amount += ' Reais'
      ENDIF

      IF Int( amount ) > 0 .AND. cents > 0
         final_amount += ' e'
      ENDIF

      IF cents > 0
         final_amount += Checkextenso( cents )
         IF cents == 1
            final_amount += ' Centavo'
         ELSE
            final_amount += ' Centavos'
         ENDIF
      ENDIF
   ENDIF

return( LTrim( final_amount ) )
// -------------------------------------------------------------------------------
FUNCTION Checkextenso( value )

   LOCAL temp
   LOCAL string := ''

   IF value > 99
      temp := Int( value / 100 )
      string += Centena( temp, value )
      VALUE -= ( temp * 100 )
      IF value > 0
         string += ' e'
      ENDIF
   ENDIF

   IF value > 19
      temp := Int( value / 10 ) - 1
      string += Dezena( temp )
      temp := Int( value / 10 ) * 10
      VALUE -= temp
      IF value > 0
         string += ' e'
      ENDIF
   ENDIF

   IF value > 0
      string += Unidade( value )
   ENDIF

return( string )
// -------------------------------------------------------------------------------
FUNCTION Unidade( unid )

   LOCAL vetor := {}

   AAdd( vetor, ' Um' )
   AAdd( vetor, ' Dois' )
   AAdd( vetor, ' Tres' )
   AAdd( vetor, ' Quatro' )
   AAdd( vetor, ' Cinco' )
   AAdd( vetor, ' Seis' )
   AAdd( vetor, ' Sete' )
   AAdd( vetor, ' Oito' )
   AAdd( vetor, ' Nove' )
   AAdd( vetor, ' Dez' )
   AAdd( vetor, ' Onze' )
   AAdd( vetor, ' Doze' )
   AAdd( vetor, ' Treze' )
   AAdd( vetor, ' Quatorze' )
   AAdd( vetor, ' Quinze' )
   AAdd( vetor, ' Dezesseis' )
   AAdd( vetor, ' Dezessete' )
   AAdd( vetor, ' Dezoito' )
   AAdd( vetor, ' Dezenove' )

return( vetor[ unid ] )
// -------------------------------------------------------------------------------
FUNCTION Dezena( deze )

   LOCAL vetor := {}

   AAdd( vetor, ' Vinte' )
   AAdd( vetor, ' Trinta' )
   AAdd( vetor, ' Quarenta' )
   AAdd( vetor, ' Cinquenta' )
   AAdd( vetor, ' Sessenta' )
   AAdd( vetor, ' Setenta' )
   AAdd( vetor, ' Oitenta' )
   AAdd( vetor, ' Noventa' )

return( vetor[ deze ] )
// -------------------------------------------------------------------------------
FUNCTION Centena( CENT, deta )

   LOCAL vetor := {}

   IF CENT == 1 .AND. deta == 100
      AAdd( vetor, ' Cem' )
   ELSE
      AAdd( vetor, ' Cento' )
   ENDIF

   AAdd( vetor, ' Duzentos' )
   AAdd( vetor, ' Trezentos' )
   AAdd( vetor, ' Quatrocentos' )
   AAdd( vetor, ' Quinhentos' )
   AAdd( vetor, ' Seiscentos' )
   AAdd( vetor, ' Setecentos' )
   AAdd( vetor, ' Oitocentos' )
   AAdd( vetor, ' Novecentos' )

return( vetor[ cent ] )
// -------------------------------------------------------------------------------
FUNCTION Chk_DiaSem( dData, nTipo )

   LOCAL cSem_ext, cSem_abv, cData

   IF nTipo == 1
      cSem_ext := { 'Domingo', 'Segunda-Feira', 'Terça-Feira', ;
         'Quarta-Feira', 'Quinta-Feira', 'Sexta-Feira', ;
         'Sábado' }
      cData := cSem_ext[ DoW( dData ) ]
      return( cData )
   ELSEIF nTipo == 2
      cSem_abv := { 'DOM', 'SEG', 'TER', 'QUA', 'QUI', 'SEX', 'SAB' }
      cData := cSem_abv[ DoW( dData ) ]
      return( cData )
   ENDIF

return( nil )
// -------------------------------------------------------------------------------
FUNCTION Chk_Cpf( parametro )

   LOCAL nConta
   LOCAL nResto
   LOCAL nDigito
   LOCAL nDigito1 := 0
   LOCAL nDigito2 := 0
   LOCAL nVez := 1

   IF Empty( parametro )
      MsgExclamation( 'O Nº do CPF não pode ser em branco', 'Atenção' )
      return( .T. )
   ENDIF

   IF parametro == '00000000000' ;
         .OR. parametro == '11111111111' ;
         .OR. parametro == '22222222222' ;
         .OR. parametro == '33333333333' ;
         .OR. parametro == '44444444444' ;
         .OR. parametro == '55555555555' ;
         .OR. parametro == '66666666666' ;
         .OR. parametro == '77777777777' ;
         .OR. parametro == '88888888888' ;
         .OR. parametro == '99999999999' ;
         .OR. parametro == '12345678909'
      MsgExclamation( 'Este Nº não é válido', 'Atenção' )
      return( .F. )
   ENDIF

   FOR nConta := 1 TO Len( parametro ) - 2
      IF At( subs( parametro, nConta, 1 ), '/-.' ) == 0
         nDigito1 := nDigito1 + ( 11 - nVez ) * Val( subs( parametro, nConta, 1 ) )
         nDigito2 := nDigito2 + ( 12 - nVez ) * Val( subs( parametro, nConta, 1 ) )
         nVez++
      ENDIF
   NEXT

   nResto := nDigito1 - ( Int( nDigito1 / 11 ) * 11 )
   nDigito := if( nResto < 2, 0, 11 - nResto )
   nDigito2 := nDigito2 + 2 * nDigito
   nResto := nDigito2 - ( Int( nDigito2 / 11 ) * 11 )
   nDigito := Val( Str( nDigito, 1 ) + Str( if( nResto < 2, 0, 11 - nResto ), 1 ) )

   IF nDigito <> Val( subs( parametro, Len( parametro ) - 1, 2 ) )
      MsgExclamation( 'Este Nº não é válido', 'Atenção' )
      return( .F. )
   ELSE
      return( .T. )
   ENDIF

return( nil )
// -------------------------------------------------------------------------------
FUNCTION Chk_Cnpj( parametro )

   LOCAL nConta
   LOCAL nResto
   LOCAL nDigito
   LOCAL nDigito1 := 0
   LOCAL nDigito4 := 0
   LOCAL nVez := 1

   IF Empty( parametro )
      MsgExclamation( 'O Nº do CNPJ não pode ser em branco', 'Atenção' )
      return( .T. )
   ENDIF

   FOR nConta := 1 TO Len( parametro ) - 2
      IF At( subs( parametro, nConta, 1 ), '/-.' ) == 0
         nDigito1 := nDigito1 + Val( subs( parametro, nConta, 1 ) ) * ( if( nVez < 5, 6, 14 ) - nVez )
         nDigito4 := nDigito4 + Val( subs( parametro, nConta, 1 ) ) * ( if( nVez < 6, 7, 15 ) - nVez )
         nVez++
      ENDIF
   NEXT

   nResto := nDigito1 - ( Int( nDigito1 / 11 ) * 11 )
   nDigito := if( nResto < 2, 0, 11 - nResto )
   nDigito4 := nDigito4 + 2 * nDigito
   nResto := nDigito4 - ( Int( nDigito4 / 11 ) * 11 )
   nDigito := Val( Str( nDigito, 1 ) + Str( if( nResto < 2, 0, 11 - nResto ), 1 ) )

   IF nDigito <> Val( subs( parametro, Len( parametro ) - 1, 2 ) )
      MsgExclamation( 'Este Nº não é válido', 'Atenção' )
      return( .F. )
   ELSE
      return( .T. )
   ENDIF

return( nil )
// -------------------------------------------------------------------------------
FUNCTION Calculadora()
   ShellExecute( '', 'open', 'calc.exe', '',, '' )

return( nil )
// -------------------------------------------------------------------------------
FUNCTION Valor_Coluna( xObj, xForm, nCol )

   LOCAL nPos := GetProperty( xForm, xObj, 'Value' )
   LOCAL aRet := GetProperty( xForm, xObj, 'Item', nPos )

RETURN aRet[ nCol ]
// -------------------------------------------------------------------------------
FUNCTION suportetecnico()
return( nil )
// -------------------------------------------------------------------------------
FUNCTION td( parametro )

   LOCAL v_data := ''
   LOCAL v_retorno := ''

   LOCAL v_dia := ''
   LOCAL v_mes := ''
   LOCAL v_ano := ''

   IF Empty( parametro )
      return( '2000-01-01' )
   ELSE
      v_data := DToC( parametro )
      v_dia := SubStr( v_data, 1, 2 )
      v_mes := SubStr( v_data, 4, 2 )
      v_ano := SubStr( v_data, 7, 4 )
      v_retorno := v_ano + '-' + v_mes + '-' + v_dia
      return( v_retorno )
   ENDIF
   // -------------------------------------------------------------------------------
FUNCTION dia_da_semana( p_data, p_tipo )

   LOCAL cSem_ext, cSem_abv, cData

   IF p_tipo == 1
      cSem_ext := { 'Domingo', 'Segunda', 'Terça', ;
         'Quarta', 'Quinta', 'Sexta', ;
         'Sábado' }
      cData := cSem_ext[ DoW( p_data ) ]
      return( cData )
   ELSEIF p_tipo == 2
      cSem_abv := { 'Dom', 'Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb' }
      cData := cSem_abv[ DoW( p_data ) ]
      return( cData )
   ENDIF

return( nil )
// -------------------------------------------------------------------------------
FUNCTION mes_do_ano( parametro, tipo )

   IF tipo == 1
      RETURN{ 'Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun', ;
         'Jul', 'Ago', 'Set', 'Out', 'Nov', 'Dez' } [ Parametro ]
   ELSEIF tipo == 2
      RETURN{ 'Janeiro  ', 'Fevereiro', 'Março    ', 'Abril    ', 'Maio     ', 'Junho    ', ;
         'Julho    ', 'Agosto   ', 'Setembro ', 'Outubro  ', 'Novembro ', ;
         'Dezembro ' } [ Parametro ]
   ENDIF
