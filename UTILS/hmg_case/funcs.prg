FUNCTION sbrand

LOCAL _rrr, _ttt

_ttt = STRZERO( SECONDS(), 5 )
_rrr = SUBSTR( _ttt, 2, 4 )

RETURN _rrr
*:**********************************
FUNCTION del( _arg )

LOCAL xi, xd, _ret
xd := directory( _arg )
for each xi in xd
   _ret = ferase(xi[1])
next

RETURN _ret
*:********************************************
