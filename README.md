# Kotlin LSP nix flake

this flake will consume the artifacts from the official jetbrains [kotlin-lsp](https://github.com/Kotlin/kotlin-lsp) 
and produce a kotlin-lsp under $out/bin/kotlin-lsp that wraps and runs the kotlin-lsp jar file via temurin.

### Usage with neovim / lsp config

I had some issues using the default lspconfig script, so here is a sample config that works for me:

```lua
       lspconfigs.kotlin_lsp = {
         default_config = {
           cmd = { "kotlin-lsp", "--stdio" },
           filetypes = { "kotlin" },
           root_dir = lspconfig.util.root_pattern("build.gradle", "settings.gradle", ".git"),
           settings = {},
         }
       }
      
       lspconfig.kotlin_lsp.setup({})
```
