# Neovim Config

Personal Neovim configuration built on top of LazyVim and NvChad, supporting full-stack development across multiple languages.

## Stack

- **Plugin manager**: [lazy.nvim](https://github.com/folke/lazy.nvim)
- **Base**: [LazyVim](https://github.com/LazyVim/LazyVim) + [NvChad](https://github.com/NvChad/NvChad)
- **Shell**: Fish

## Languages

| Language | Tooling |
|----------|---------|
| C# / .NET | Roslyn, OmniSharp, rzls (Razor) |
| Rust | rustaceanvim, crates.nvim |
| Go | LazyVim Go extra |
| TypeScript / JavaScript | tsserver |
| Python | venv-selector |
| PHP | phpactor |
| Flutter / Dart | flutter-tools.nvim |
| Web (HTML, CSS, Tailwind, Svelte) | cssls, html, tailwindcss |
| SQL | vim-dadbod + UI |
| Lua | lua_ls, lazydev.nvim |

## Notable Plugins

- **Telescope** — fuzzy finder for files, buffers, grep, git
- **nvim-tree** — file explorer (`<C-n>`)
- **conform.nvim** — formatting (`<Leader>fm`)
- **nvim-cmp** + LuaSnip — completion and snippets
- **gitsigns.nvim** — git diff in sign column
- **trouble.nvim** — diagnostics list
- **flash.nvim** — quick navigation
- **noice.nvim** — UI improvements
- **mini.*** — surround, move, diff, animate, ai, files
- **presence.nvim** — Discord Rich Presence

## Key Mappings

`<Leader>` = `<Space>`

### Files & Buffers
| Key | Action |
|-----|--------|
| `<C-n>` | Toggle file tree |
| `<C-s>` | Save file |
| `<Tab>` / `<S-Tab>` | Next / previous buffer |
| `<Leader>x` | Close buffer |

### Telescope
| Key | Action |
|-----|--------|
| `<Leader>ff` | Find files |
| `<Leader>fw` | Live grep |
| `<Leader>fb` | Find buffers |
| `<Leader>fo` | Recent files |
| `<Leader>cm` | Git commits |
| `<Leader>gt` | Git status |

### LSP
| Key | Action |
|-----|--------|
| `gd` | Go to definition |
| `gr` | References |
| `gi` | Implementation |
| `<Leader>ca` | Code actions |
| `<Leader>ra` | Rename |
| `<Leader>ds` | Diagnostics |
| `<Leader>fm` | Format file |

### Terminals
| Key | Action |
|-----|--------|
| `<A-h>` | Toggle horizontal terminal |
| `<A-v>` | Toggle vertical terminal |
| `<A-i>` | Toggle floating terminal |

## Installation

```bash
git clone https://github.com/opyrusdev/nvim-config ~/.config/nvim
nvim
```

Dependencies: `git`, `ripgrep`, `fd`, `node`, `cargo`, Mason will handle LSP servers.
