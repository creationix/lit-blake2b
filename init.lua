local names = {
  ["Windows-x64"] = "blake2.dll",
  ["Linux-arm"] = "libblake2.so",
  ["Linux-x64"] = "libblake2.so",
  ["OSX-x64"] = "libblake2.dylib",
}

local ffi = require('ffi')
ffi.cdef((module:load("blake2.h")))

local arch = ffi.os .. "-" .. ffi.arch
return module:action(arch .. "/" .. names[arch], function (path)
  local lib = ffi.load(path)

  local exports = {}

  -- Simple blake2b for static data
  -- lua string goes in, lua string of raw hash comes out.
  -- Usage:
  --
  --    blake2b(data, key, len) -> hash
  --
  function exports.blake2b(data, key, olen)
    olen = olen or 32
    local o = ffi.new('uint8_t[?]', olen)
    local ilen = #data
    local i = ffi.new('uint8_t[?]', ilen, data)
    local klen = key and #key or 0
    local k = key and ffi.new('uint8_t[?]', klen, key)
    assert(lib.blake2b(o, olen, i, ilen, k, klen) == 0)
    return ffi.string(o, olen)
  end

  -- Streaming interface to blake2b
  -- Usage:
  --
  --    blake2b_init(key, len):update(data):final() -> hash
  --
  function exports.blake2b_init(key, olen)
    olen = olen or 32
    local self = ffi.new('blake2b_state')
    if key then
      local klen = #key
      local k = ffi.new('uint8_t[?]', klen, key)
      assert(lib.blake2b_init_key(self, olen, k, klen) == 0)
    else
      assert(lib.blake2b_init(self, olen) == 0)
    end
    return self
  end

  ffi.metatype("blake2b_state", { __index = {

    update = function (self, data)
      local ilen = #data
      local i = ffi.new('uint8_t[?]', ilen, data)
      assert(lib.blake2b_update(self, i, ilen) == 0)
      return self
    end,

    final = function (self)
      local olen = self.outlen
      local o = ffi.new('uint8_t[?]', olen)
      assert(lib.blake2b_final(self, o, olen) == 0)
      return ffi.string(o, olen)
    end

  }})

  return exports
end)
