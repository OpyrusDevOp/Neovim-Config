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
| Arduino / C++ | Arduino-Nvim, arduino-language-server, clangd |

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

### Arduino
| Key | Action |
|-----|--------|
| `<Leader>ac` | Compile sketch |
| `<Leader>au` | Compile and upload sketch |
| `<Leader>as` | Serial monitor |
| `<Leader>ap` | Set the sketch's default port |

### Terminals
| Key | Action |
|-----|--------|
| `<A-h>` | Toggle horizontal terminal |
| `<A-v>` | Toggle vertical terminal |
| `<A-i>` | Toggle floating terminal |

## Arduino

Opening a `.ino` sets up the sketch automatically:

- **`sketch.yaml`**: created on first open from the connected board (or a board picker), so arduino-language-server knows the FQBN.
- **`compile_commands.json`**: regenerated on save (`arduino-cli compile --only-compilation-database`, built into `.build/`), so clangd works for the sketch's `.h`/`.cpp` modules as well as the `.ino`.
- Missing libraries show up as diagnostics instead of a silently dead LSP.

| Command | Action |
|---------|--------|
| `:ArduinoPort [port]` | Set the default port in `sketch.yaml` and `.arduino_config.lua` (picker if no argument) |
| `:ArduinoSketchInit` | Regenerate `sketch.yaml` |
| `:ArduinoCompileDb` | Regenerate `compile_commands.json` |

Prefer the stable `/dev/serial/by-id/...` path over `/dev/ttyACM*`, which can renumber when the board is replugged.

Workarounds for arduino-language-server 0.7.x with clangd ≥ 21 (see `lua/plugins/lsp.lua`): document symbols and highlights are disabled for `.ino` files (they crash the server), and insert/replace completion edits are turned off.

> `arduino-cli upload` does not compile. Use `<Leader>au` or `arduino-cli compile -u`.

## Installation

```bash
git clone https://github.com/opyrusdev/nvim-config ~/.config/nvim
nvim
```

Dependencies: `git`, `ripgrep`, `fd`, `node`, `cargo`, Mason will handle LSP servers.

For Arduino: `arduino-cli` (with the board core installed, e.g. `arduino-cli core install arduino:avr`), `arduino-language-server` and `clangd` on `PATH`.
