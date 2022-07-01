/*

 BadaSystem
 Program       : nextnumber
 Modulo        : nextnumber
 Compilador    : MINIGUI - Harbour Win32 GUI
 Link          : BCC 32 bit
 Autor         : Marcos Jarrín
 email         : marvijarrin@gmail.com
 website       : badasystem.org
 Date          : 01/05/2010
 Update        : 28/07/2022

*/

/*
 NextNumber( <cAlias>,
                <cFieldname>,
                [<nIndexOrder>] ) --> value+ 1

   Arguments:  <cAlias>      alias of the target database which
                              contains the value to be incremented
                <cFieldName>  field name which is to be incremented
                <nIndexOrder> index order of key field index

    Description
        Increment the value of a key field in a target database.
        May be character or numeric.
        Useful for incrementing invoice numbers and the like

    Example:     nextnumber('test', 'id', 1)
*/
FUNCTION NextNumber( cAlias, cFieldName, nIndexOrder )

   LOCAL nOldOrder := ( cAlias )->( IndexOrd() ) // target file index order
   LOCAL nTargetPos := ( cAlias )->( RecNo() ) // position of target file
   LOCAL retvalue // return value
   LOCAL size // field size

   IF nIndexOrder == NIL
      nIndexOrder := 0
   ENDIF

   ( cAlias )->( dbSetOrder( nIndexOrder ) ) // set index order
   ( cAlias )->( dbGoBottom() ) // bottom of target file

   // fetch value to be incremented
   retvalue := ( cAlias )->( FieldGet( FieldPos( cFieldName ) ) )

   // check if the return variable is empty
   IF Empty( retvalue )
      IF ValType( retvalue ) == "C"
         retvalue := StrZero( 1, Len( retvalue ) )
      ELSEIF ValType( retvalue ) == "N"
         retvalue := 1
      ENDIF
   ELSEIF ValType( retvalue ) == "C"
      size := Len( retvalue )
      retvalue := LTrim( Str( Val( retvalue ) + 1 ) )
      size -= Len( retvalue )
      retvalue := Replicate( "0", size ) + retvalue
   ELSEIF ValType( retvalue ) == "N"
      retvalue++
   ENDIF

   ( cAlias )->( dbGoto( nTargetPos ) ) // reposition target file
   ( cAlias )->( dbSetOrder( nOldOrder ) ) // restore index order

RETURN retvalue
