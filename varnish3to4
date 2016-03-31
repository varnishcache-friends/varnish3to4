#!/usr/bin/env python
#
# Copyright (c) 2014-2016, Federico G. Schwindt <fgsch@lodoss.net>
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
#
# 1. Redistributions of source code must retain the above copyright
#    notice, this list of conditions and the following disclaimer.
#
# 2. Redistributions in binary form must reproduce the above copyright
#    notice, this list of conditions and the following disclaimer in the
#    documentation and/or other materials provided with the distribution.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
# "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
# LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
# A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
# HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
# SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED
# TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
# PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
# LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
# NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
# SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

import argparse
import re


def fixup(config, include_41):
    v3v4 = [
        ('(vcl_fetch)', 'vcl_backend_response'),
        ('([ \t]*)(purge\s*;)',
            '\g<1>#\n'
            '\g<1># This is now handled in vcl_recv.\n'
            '\g<1>#\n'
            '\g<1># \g<2>'),
        ('(error\s+(\d+)\s+("[^"]*"|[^;]*))',
            'return (synth(\g<2>, \g<3>))'),
        ('(error\s+(\d+))', 'return (synth(\g<2>))'),
        ('(((bereq|req)\.\w+)\.healthy)', 'std.healthy(\g<2>)'),
        ('([ \t]*)(set\s+req\.grace[^;]*;)',
            '\g<1>#\n'
            '\g<1># This is now handled in vcl_hit.\n'
            '\g<1>#\n'
            '\g<1># \g<2>'),
        ('((bereq|req)\.(request))', '\g<2>.method'),
        ('((beresp|obj|resp)\.(response))', '\g<2>.reason'),
        ('(beresp\.storage(?!_))', 'beresp.storage_hint'),
        ('(remove\s+((bereq|beresp|req|resp|obj)\.))',
            'unset \g<2>'),
        ('(([ \t]*)return\s*\(?hit_for_pass\)?\s*;)',
            '\g<2># set beresp.ttl = 120s;\n'
            '\g<2>set beresp.uncacheable = true;\n'
            '\g<2>return (deliver);'),
        ('((client|server)\.port)', 'std.port(\g<2>.ip)'),
        ('(set\s+obj\.hits[^;]*;)', '# \g<1>'),
    ]
    if include_41:
        v3v4.extend((
            ('(std.(?:real|time)2integer)\(([^\)]*)\)',
                '\g<1>(\g<2>, 0)'),
            ('(std.time2real)\s*\(([^\)]*)\)',
                '\g<1>(\g<2>, 0.0)'),
        ))
    for v3, v4 in v3v4:
        config = re.sub(v3, v4, config)
    return config


def fixup_multi(config, include_41):
    def repl(v):
        def func(m):
            s = m.group()
            return (s, '# ' + s)[v in s]
        return func
    v3v4 = [
        ('(set\s+[^;]*;)', '^(.*)$', repl('obj.lastuse')),
        ('(sub\s+vcl_recv\s(((?!sub ).)*$))',
            'return\s*\(?lookup\)?[^;]', 'return (hash)'),
        ('(sub\s+vcl_hash\s(((?!sub ).)*$))',
            'return\s*\(?hash\)?[^;]', 'return (lookup)'),
        ('(sub\s+vcl_pass\s(((?!sub ).)*$))',
            'return\s*\(?pass\)?[^;]', 'return (fetch)'),
        ('^\s*(synthetic\s+[{"].*?["}];)', '(?ms)\s+(.*);',
            '(\g<1>);'),
        ('^\s*(synthetic\s+[^;]*);', '\s+(.*)',
            '(\g<1>)'),
        ('(sub\s+vcl_error\s(((?!sub ).)*$))',
            '(?ms)sub\s+vcl_error\s(.*)$',
            'sub vcl_backend_error \g<1>\n'
            'sub vcl_synth \g<1>'),
        ('(sub\s+vcl_synth\s(((?!sub ).)*$))',
            '(set\s+[^;]*;)', repl('obj.ttl')),
        ('(sub\s+vcl_synth\s(((?!sub ).)*$))',
            'obj\.(?!ttl)', 'resp.'),
        ('(sub\s+vcl_backend_(error|response)\s(((?!sub ).)*$))',
            '((?<!be)req\.(\w+))', 'bereq.\g<2>'),
        ('(sub\s+vcl_backend_error\s(((?!sub ).)*$))',
            '(obj\.(\w+))', 'beresp.\g<2>'),
        ('(sub\s+vcl_backend_error\s(((?!sub ).)*$))',
            '(bereq\.restarts)', 'bereq.retries'),
        ('(sub\s+vcl_(hit|miss|pass|pipe|recv|synth)\s(((?!sub ).)*$))',
            '(req\.backend(?!_))', 'req.backend_hint'),
        ('(sub\s+vcl_backend_(error|response)\s(((?!sub ).)*$))',
            'return\s*\(?restart\)?[^;]', 'return (retry)'),
    ]
    if include_41:
        v3v4.append(
            ('(sub\s+vcl_hit\s(((?!sub ).)*$))',
                'return\s*\(?fetch\)?[^;]', 'return (miss)')
        )
    for s, v3, v4 in v3v4:
        for m in re.finditer(s, config, re.S | re.M):
            config = config.replace(m.group(1), re.sub(v3, v4, m.group(1)))
    return config


def main():
    parser = argparse.ArgumentParser(prog='varnish3to4')
    parser.add_argument('config', type=argparse.FileType('r'),
                        help='Varnish 3 VCL file')
    parser.add_argument('--41', action='store_true',
                        help='Include changes for 4.1')
    parser.add_argument('-o', '--output', type=argparse.FileType('w'),
                        default='-')
    args = parser.parse_args()

    include_41 = getattr(args, '41')

    config = fixup(args.config.read(), include_41)
    config = fixup_multi(config, include_41)
    args.output.write(config)

if __name__ == '__main__':
    main()
