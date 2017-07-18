return {
  name = "creationix/blake2",
  version = "1.0.2",
  homepage = "https://github.com/creationix/blake2",
  description = "FFI bindings to the reference blake2b implementation.",
  tags = {"ffi", "hash", "crypto", "blake2"},
  author = { name = "Tim Caswell" },
  license = "MIT",
  files = {
    "package.lua",
    "init.lua",
    "blake2.h",
    "$OS-$ARCH/*",
  }
}
