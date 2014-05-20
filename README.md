varnish3to4
===========

Unofficial script to assist migrating a VCL file from Varnish 3 to 4.

### Suggested usage

```
 $ varnish3to4 -o <filename>.v4 <filename>
 $ diff -u <filename> <filename>.v4
```

### Currently understands

V3 | V4
:-- | :--
vcl_fetch | vcl_backend_response
vcl_error | vcl_backend_error and vcl_synth
error code response | return (synth(code, response))
purge | return (purge)
remove | unset
{bereq,req}.request | {bereq,req}.method
{beresp,obj,resp}.response | {beresp,obj,resp}.reason
{bereq,req}.backend.healthy | std.healthy({bereq.backend,req.backend_hint})
beresp.storage | beresp.storage_hint
req.backend | req.backend_hint
req.grace | -
req.* in vcl_backend_response | bereq.*
{client,server}.port | std.port({client,server}.ip)
return (hit_for_pass) | set beresp.uncacheable = true;<br/>return (deliver);
return (lookup) in vcl_recv | return (hash)
return (hash) in vcl_hash | return (lookup)
return (pass) in vcl_pass | return (fetch)
return (restart) in vcl_fetch | return (retry)
synthetic .. | synthetic(..)
obj.* in vcl_synth | resp.*
obj.hits - writing to | -
obj.lastuse | -

### Might be implemented

V3 | V4
:-- | :--
- | import directors<br/>new xx = directors.yy();<br/>xx.add_backend(ss);<br/>set req.backend_hint = xx.backend()

And any other change missing from these tables.

### Won't be implemented

V3 | V4
:-- | :--
- | vcl 4.0
