## Regtee

Copy text yanked to the unnamed register to a sticky register.

### Configuration

```lua
require("regtee").setup({
    enabled = true, -- default value
})
```

### Usage

```vim
" Copy everything yanked to the unnamed register (`"`) to the register `a`.
" The register `a` is also cleared first (set to an empty string).
:Regtee a

" Use an uppercase letter to avoid clearing the register. Text will thus be appended.
:Regtee A

" Stop copying to the register set beforehand.
:Regtee
```
