varnish3to4
===========

[![Gitter](https://badges.gitter.im/Join Chat.svg)](https://gitter.im/fgsch/varnish3to4?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

Script to assist migrating a VCL file from Varnish 3 to 4.

### Suggested usage

```
 $ varnish3to4 -o <filename>.v4 <filename>
 $ diff -u <filename> <filename>.v4
```

To include changes for Varnish 4.1:

```
 $ varnish3to4 --41 -o <filename>.v4 <filename>
 $ diff -u <filename> <filename>.v4
```

### Currently understands

V3 | V4
:-- | :--
vcl_fetch | vcl_backend_response
vcl_error | vcl_backend_error and vcl_synth
error code response | return (synth(code, response))
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
return (fetch) in vcl_hit [1] | return (miss)
synthetic .. | synthetic(..)
obj.* in vcl_synth | resp.*
obj.hits - writing to | -
obj.lastuse | -

### Limited coverage

V3 | V4
:-- | :--
purge | -

### Might be implemented

V3 | V4
:-- | :--
- | vcl 4.0
- | import directors<br/>new xx = directors.yy();<br/>xx.add_backend(ss);<br/>set req.backend_hint = xx.backend();

Add imports resulting from changes in V4, complete purge handling and
any other changes missing from this document.

1. This change is optional in 4.1 but might be mandatory in future versions.
