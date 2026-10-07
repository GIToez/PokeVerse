function Protocol_create(byte)
   local protocol      = {}
         protocol[1]   = {}
         protocol[2]   = 0
         protocol[3]   = byte
  
   return protocol
end

function Protocol_add(protocol, string)
   table.insert(protocol[1], string)
end

function Protocol_read(protocol)
   protocol[2] = protocol[2] + 1

   return protocol[1][protocol[2]]
end