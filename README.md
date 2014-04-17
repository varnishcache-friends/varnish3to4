varnish3to4
===========

Script to assist migrating a VCL file from Varnish 3 to 4.

Currently understands:

V3 | V4
:-- | :--
vcl_fetch | vcl_backend_response
vcl_error | vcl_synth
error code response | return (vcl_synth(code, response))
remove | unset
{bereq,req}.request | {bereq,req}.method
{beresp,obj,resp}.response | {beresp,obj,resp}.reason
req.backend | req.backend_hint
req.backend.healthy | std.healthy(backend)
req.grace | -
req.* in vcl_backend_response | bereq.*
{client,server}.port | std.port({client,server}.ip)
return (hit_for_pass) | set beresp.uncacheable = true;<br/>return (deliver);
return (lookup) in vcl_recv | return (hash)
return (hash) in vcl_hash | return (lookup)
synthetic .. | synthetic(..)

Not implemented yet:

V3 | V4
:-- | :--
 | import directors<br/>new xx = directors.yy();<br/>xx.add_backend(ss);<br/>set req.backend_hint = xx.backend()

Won't be implemented:

V3 | V4
:-- | :--
- | vcl 4.0
