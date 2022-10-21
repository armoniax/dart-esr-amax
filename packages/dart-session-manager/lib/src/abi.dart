String AbiString = '''
{
  "version": "amax::abi/1.1",
  "types": [],
  "variants": [],
  "structs": [   { "name": "sealed_message",
         "base": "",
         "fields": [
            {
               "name": "from",
               "type": "public_key"
            },
            {
               "name": "nonce",
               "type": "uint64"
            },
            {
               "name": "ciphertext",
               "type": "bytes"
            },
            {
               "name": "checksum",
               "type": "uint32"
            }
         ]},{ "name": "link_create",
         "base": "",
         "fields": [
            {
               "name": "session_name",
               "type": "name"
            },
            {
               "name": "request_key",
               "type": "public_key"
            },
            {
               "name": "user_agent",
               "type": "string",
               "extension":true
            }
            
         ]},{ "name": "encoded",
         "base": "",
         "fields": [
            {
               "name": "object",
               "type": "uint64"
            }         
         ]},{ "name": "link_info",
         "base": "",
         "fields": [
            {
               "name": "expiration",
               "type": "time_point_sec"
            }         
         ]}],
  "actions": [],
  "tables": [],
  "ricardian_clauses": []
}
''';
