varnish3to4
===========

[![Join the chat at https://gitter.im/fgsch/varnish3to4](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/fgsch/varnish3to4?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

Script to assist migrating a VCL file from Varnish 3 to 4.x. [1]

### Suggested usage

```
 $ varnish3to4 -o <filename>.v4 <filename>
 $ diff -u <filename> <filename>.v4
```

To limit changes for Varnish 4.0:

```
 $ varnish3to4 -v 4.0 -o <filename>.v4 <filename>
 $ diff -u <filename> <filename>.v4
```

### Currently understands

V3 | V4
:-- | :--
{bereq,req}.backend.healthy | std.healthy({bereq.backend,req.backend_hint})
{bereq,req}.request | {bereq,req}.method
bereq.* in vcl_pass and vcl_miss | req.*
{beresp,obj,resp}.response | {beresp,obj,resp}.reason
beresp.storage | beresp.storage_hint
{client,server}.port | std.port({client,server}.ip)
error code response | return (synth(code, response))
obj.hits - writing to | -
obj.* in vcl_synth | resp.*
obj.lastuse | -
remove | unset
req.backend | req.backend_hint
req.grace | -
req.* in vcl_backend_response | bereq.*
return (hash) in vcl_hash | return (lookup)
return (hit_for_pass) | set beresp.uncacheable = true;<br/>return (deliver);
return (lookup) in vcl_recv | return (hash)
return (pass) in vcl_pass | return (fetch)
return (restart) in vcl_fetch | return (retry)
std.real2integer(..) [2] | std.real2integer(.., n)
std.time2integer(..) [2] | std.time2integer(.., n)
std.time2real(..) [2] | std.time2real(.., n.n)
synthetic .. | synthetic(..)
vcl_error | vcl_backend_error and vcl_synth
vcl_fetch | vcl_backend_response

### Limited coverage

V3 | V4
:-- | :--
purge | -

### Won't be implemented

V3 | V4
:-- | :--
&nbsp;- | vcl 4.0
&nbsp;- | import directors<br/>new xx = directors.yy();<br/>xx.add_backend(ss);<br/>set req.backend_hint = xx.backend();

Add imports resulting from changes in V4, complete purge handling and
any other changes missing from this document.

### N/A for 3.0 (for documentation only)

V4.0 | V4.1
:---- | :----
return (fetch) in vcl_hit [3] | return (miss)

### Notes

1. Comments in VCL are treated as code and as such references within
   will be rewritten.
2. Required in 4.1 and above.
3. Optional in 4.1. Required in 5.0 and above.
