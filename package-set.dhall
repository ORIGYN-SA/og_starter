let aviate_labs = https://github.com/aviate-labs/package-set/releases/download/v0.1.3/package-set.dhall sha256:ca68dad1e4a68319d44c587f505176963615d533b8ac98bdb534f37d1d6a5b47

let upstream = https://github.com/dfinity/vessel-package-set/releases/download/mo-0.6.21-20220215/package-set.dhall sha256:b46f30e811fe5085741be01e126629c2a55d4c3d6ebf49408fb3b4a98e37589b
let Package =
    { name : Text, version : Text, repo : Text, dependencies : List Text }

let additions =
    [{ name = "principal"
   , repo = "https://github.com/aviate-labs/principal.mo.git"
   , version = "v0.2.5"
   , dependencies = ["base"]
   },
   { name = "candy"
    , repo = "https://github.com/aramakme/candy_library.git"
    , version = "v0.1.9"
    , dependencies = ["base"]
   },
   { name = "pipelinify"
    , repo = "https://github.com/skilesare/pipelinify.mo.git"
    , version = "v0.1.1"
    , dependencies = ["base", "candy"]
    }, { name = "crypto"
    , repo = "https://github.com/aviate-labs/crypto.mo"
    , version = "v0.1.0"
    , dependencies = [ "base", "encoding" ]
  },
   { name = "encoding"
  , repo = "https://github.com/aviate-labs/encoding.mo"
  , version = "v0.3.2"
  , dependencies = [ "array", "base" ]
  },
  { name = "io"
  , repo = "https://github.com/aviate-labs/io.mo"
  , version = "v0.3.1"
  , dependencies = [ "base" ]
  },
  { name = "array"
  , repo = "https://github.com/aviate-labs/array.mo"
  , version = "v0.2.0"
  , dependencies = [ "base" ]
  },
  { name = "hash"
  , repo = "https://github.com/aviate-labs/hash.mo"
  , version = "v0.1.0"
  , dependencies = [ "array", "base" ]
  },
  { name = "ulid"
  , repo = "https://github.com/aviate-labs/ulid.mo"
  , version = "v0.1.2"
  , dependencies = [ "base", "encoding", "io" ]
  },
  { name = "rand"
  , repo = "https://github.com/aviate-labs/rand.mo"
  , version = "v0.2.2"
  , dependencies = [ "base" ]
  },] : List Package

let
  {- This is where you can override existing packages in the package-set

     For example, if you wanted to use version `v2.0.0` of the foo library:
     let overrides = [
         { name = "foo"
         , version = "v2.0.0"
         , repo = "https://github.com/bar/foo"
         , dependencies = [] : List Text
         }
     ]
  -}
  overrides =
    [] : List Package

in  aviate_labs # upstream # additions # overrides
