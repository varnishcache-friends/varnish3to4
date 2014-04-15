varnish3to4
===========

Tool to help migrating VCL from Varnish 3.0 to 4.0.

Currently understands:

V3 syntax | V4 syntax
:-- | :--
vcl_fetch | vcl_backend_response
vcl_error | vcl_synth
error nnn sss | return (vcl_synth(nnn, sss))
req.backend | req.backend_hint |
req.grace |
{bereq,req}.request | {bereq,req}.method
{beresp,obj,resp}.response | {beresp,obj,resp}.reason
remove | unset
directors | import directors<br/>new xx = directors.yy();<br/>xx.add_backend(ss);<br/>set req.backend_hint = xx.backend()
