varnish3to4
===========

Script to assist migrating a VCL file from Varnish 3 to 4.

Currently understands:

V3 | V4
:-- | :--
vcl_fetch | vcl_backend_response
vcl_error | vcl_synth
error code response | return (vcl_synth(code, response))
req.backend | req.backend_hint
req.backend.healthy | std.healthy(backend)
req.grace | -
{bereq,req}.request | {bereq,req}.method
{beresp,obj,resp}.response | {beresp,obj,resp}.reason
remove | unset

Planned but not implemented yet:

V3 | V4
:-- | :--
- | vcl 4.0
 | import directors<br/>new xx = directors.yy();<br/>xx.add_backend(ss);<br/>set req.backend_hint = xx.backend()
