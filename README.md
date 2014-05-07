varnish3to4
===========

A script to assist migrating a VCL file from Varnish 3 to 4.

Currently understands:

V3 | V4
:-- | :--
vcl_fetch | vcl_backend_response
vcl_error | vcl_backend_error and vcl_synth
error code response | return (synth(code, response))
purge | return (purge)
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
return (pass) in vcl_pass | return (fetch)
synthetic .. | synthetic(..)
obj.* in vcl_synth | resp.*
obj.hits - writing to | -
obj.last_use | -

Might be implemented:

V3 | V4
:-- | :--
- | import directors<br/>new xx = directors.yy();<br/>xx.add_backend(ss);<br/>set req.backend_hint = xx.backend()

Won't be implemented:

V3 | V4
:-- | :--
- | vcl 4.0
