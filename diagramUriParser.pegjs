   URI_reference = URI:URI { return URI; }
                 / relative_ref:relative_ref { return [{ "n": "Relative URI", l: location() }].concat(relative_ref); }

   URI           = scheme:scheme ":" hier_part:hier_part query:( "?" query )? fragment:( "#" fragment )?
{ return [{n: "URI", l: location() }].concat(scheme).concat(hier_part).concat(query ? query[1] : []).concat(fragment ? fragment[1] : []); }

   hier_part     = "//" authority:authority path:path_abempty { return authority.concat(path); }
                 / path:path_absolute { return path; }
                 / path:path_rootless { return path; }
                 / path:path_empty { return path; }
    

   absolute_URI  = scheme:scheme ":" hier_part:hier_part query:( "?" query )?  { return scheme.concat(hier_part).concat(query ? query[1] : []); }

   relative_ref  = relative_part:relative_part query:( "?" query )? fragment:( "#" fragment )? { return relative_part.concat(query ? query[1] : []).concat(fragment ? fragment[1] : []); }

   relative_part = "//" authority:authority path:path_abempty { return (authority || []).concat(path); }
                 / path:path_absolute { return path; }
                 / path:path_noscheme { return path; }
                 / path:path_empty { return path; }

   scheme        = ALPHA ( ALPHA / DIGIT / "+" / "-" / "." )* { return [ { n: "scheme", l: location() } ]; }

   authority     = userinfo:( userinfo "@" )? host:host port:( ":" port )? { return [{ n: "authority", l: location() }].concat(userinfo ? userinfo[0] : []).concat(host).concat(port ? port[1] : []); }
   userinfo      = ( unreserved / pct_encoded / sub_delims / ":" )* { return [ { n: "userinfo", l: location() }]; }

   host          = sub:IP_literal { return [ { n: "host", l: location() } ].concat(sub || []); }
                 / sub:IPv4address { return [ { n: "host", l: location() } ].concat(sub || []); }
                 / reg_name { return [ { n: "host", l: location() } ]; }

   port          = DIGIT* { return [ { n: "port", l: location() } ]; }

   IP_literal    = "[" literal:( IPv6addrz / IPv6address / IPvFuture  ) "]" { return literal; }

   ZoneID = ( unreserved / pct_encoded )+ { return [{ n: "ZoneId", l: location() }]; }

   IPv6addrz = IPv6address:IPv6address "%25" ZoneID:ZoneID { return IPv6address.concat(ZoneID); }

   IPvFuture     = "v" HEXDIG+ "." ( unreserved / sub_delims / ":" )+ { return [ { n: "IPvFuture", l: location() }]; }

   IPv6address   = HEXDIG* ":" (HEXDIG / ":")+ IPv4address? { return [ { n: "IPv6", l: location() } ]; }
   IPv4address   = dec_octet "." dec_octet "." dec_octet "." dec_octet { return [ { n: "IPv4", l: location() } ]; }

   dec_octet     = "25" [012345]          
                 / "2" [01234] DIGIT     
                 / "1" DIGIT DIGIT            
                 / [123456789] DIGIT         
                 / DIGIT                 

   reg_name      = ( unreserved / pct_encoded / sub_delims )* { return [ { n: "hostname", l: location() } ]; }

   path          = path_abempty     { return [ { n: "path", l: location() } ]; }
                 / path_absolute   { return [ { n: "path", l: location() } ]; }
                 / path_noscheme   { return [ { n: "path", l: location() } ]; }
                 / path_rootless   { return [ { n: "path", l: location() } ]; }
                 / path_empty      { return [ { n: "path", l: location() } ]; }

   path_abempty  = ( "/" segment )* { return [ { n: "path", l: location() } ] };
   path_absolute = "/" ( segment_nz ( "/" segment )* )?  { return [ { n: "path", l: location() } ] };
   path_noscheme = segment_nz_nc ( "/" segment )* { return [ { n: "path", l: location() } ] };
   path_rootless = segment_nz ( "/" segment )* { return [ { n: "path", l: location() } ] };
   path_empty    = "" { return [ { n: "path", l: location() } ] };

   segment       = pchar*
   segment_nz    = pchar+
   segment_nz_nc = ( unreserved / pct_encoded / sub_delims / "@" )+
                 

   pchar         = unreserved / pct_encoded / sub_delims / ":" / "@"

   query         = ( pchar / "/" / "?" )* { return [ { n: "query", l: location() } ] };

   fragment      = ( pchar / "/" / "?" )* { return [ { n: "fragment", l: location() } ] };

   pct_encoded   = "%" HEXDIG HEXDIG

   unreserved    = ALPHA / DIGIT / "-" / "." / "_" / "~"
   reserved      = gen_delims / sub_delims
   gen_delims    = ":" / "/" / "?" / "#" / "[" / "]" / "@"
   sub_delims    = "!" / "$" / "&" / "'" / "(" / ")"
                 / "*" / "+" / "," / ";" / "="

DIGIT = [0123456789]
ALPHA = [a-zA-Z]
HEXDIG = DIGIT / [abcdefABCDEF]


