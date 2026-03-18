-- Set <space> as the leader key
-- See `:help mapleader`
--  NOTE: Must happen before plugins are loaded (otherwise wrong leader will be used)
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Set to true if you have a Nerd Font installed and selected in the terminal
vim.g.have_nerd_font = true

-- [[ Setting options ]]
-- See `:help vim.o`

-- Session options for auto-session
vim.o.sessionoptions = "blank,buffers,curdir,folds,help,tabpages,winsize,winpos,terminal,localoptions"

-- Make line numbers default
vim.o.number = true
-- Add relative line numbers
vim.o.relativenumber = true

-- Don't show the mode, since it's already in the status line
vim.o.showmode = false

-- Enable mouse mode
vim.o.mouse = "a"

-- Sync clipboard between OS and Neovim.
vim.schedule(function()
  vim.o.clipboard = "unnamedplus"
end)

-- Enable break indent
vim.o.breakindent = true

-- Save undo history
vim.o.undofile = true

-- Case-insensitive searching UNLESS \C or one or more capital letters in the search term
vim.o.ignorecase = true
vim.o.smartcase = true

-- Keep signcolumn on by default
vim.o.signcolumn = "yes"

-- Decrease update time
vim.o.updatetime = 250
vim.o.timeoutlen = 300

-- Configure how new splits should be opened
vim.o.splitright = true
vim.o.splitbelow = true

-- Sets how neovim will display certain whitespace characters in the editor.
vim.o.list = true
vim.opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }

-- Preview substitutions live, as you type!
vim.o.inccommand = "split"

-- Show which line your cursor is on
vim.o.cursorline = true

-- Minimal number of screen lines to keep above and below the cursor.
vim.o.scrolloff = 10

-- Confirm before closing unsaved files
vim.o.confirm = true

-- Set highlight on search
vim.o.hlsearch = false

-- Set completeopt to have a better completion experience
vim.o.completeopt = "menuone,noselect"

-- NOTE: You should make sure your terminal supports this
vim.o.termguicolors = true

-- Set spell checking
vim.opt.spelllang = "en_us,pt_br"
vim.opt.spell = true

-- [[ Basic Keymaps ]]
--  See `:help vim.keymap.set()`

-- Clear highlights on search when pressing <Esc> in normal mode
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")

-- Diagnostic keymaps
vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, { desc = "Go to previous diagnostic message" })
vim.keymap.set("n", "]d", vim.diagnostic.goto_next, { desc = "Go to next diagnostic message" })
vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float, { desc = "Open floating diagnostic message" })
vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Open diagnostic [Q]uickfix list" })

-- Exit terminal mode in the builtin terminal with a shortcut
vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

-- Keybinds to make split navigation easier.
vim.keymap.set("n", "<C-h>", "<C-w><C-h>", { desc = "Move focus to the left window" })
vim.keymap.set("n", "<C-l>", "<C-w><C-l>", { desc = "Move focus to the right window" })

-- Custom movement keymaps (avoiding conflict with window navigation)
vim.keymap.set("n", "<C-j>", "3j", { noremap = true, silent = true, desc = "Move 3 lines down" })
vim.keymap.set("n", "<C-k>", "3k", { noremap = true, silent = true, desc = "Move 3 lines up" })

-- [[ Basic Autocommands ]]
--  See `:help lua-guide-autocommands`

-- Highlight when yanking (copying) text
vim.api.nvim_create_autocmd("TextYankPost", {
  desc = "Highlight when yanking (copying) text",
  group = vim.api.nvim_create_augroup("kickstart-highlight-yank", { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})

-- Kitty margin management
vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    vim.defer_fn(function()
      vim.cmd("silent !kitty @ set-spacing margin=0")
    end, 100)
  end,
})

vim.api.nvim_create_autocmd("VimLeave", {
  callback = function()
    vim.cmd("silent !kitty @ set-spacing margin=21.75")
  end,
})

-- [[ Install `lazy.nvim` plugin manager ]]
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    error("Error cloning lazy.nvim:\n" .. out)
  end
end
vim.opt.rtp:prepend(lazypath)

-- [[ Configure and install plugins ]]
require("lazy").setup({
  -- Modern tab/indent detection
  "NMAC427/guess-indent.nvim",

  -- Essential tools
  "tpope/vim-fugitive",
  "tpope/vim-rhubarb",
  "tpope/vim-eunuch",

  -- Better "gf" for javascript
  "hotoo/jsgf.vim",

  -- Quick math calculations
  "jbyuki/quickmath.nvim",

  -- TypeScript tools
  {
    "pmizio/typescript-tools.nvim",
    dependencies = { "nvim-lua/plenary.nvim", "neovim/nvim-lspconfig" },
    opts = {},
  },

  -- Hardtime for better vim habits
  -- {
  -- 	"m4xshen/hardtime.nvim",
  -- 	lazy = false,
  -- 	dependencies = { "MunifTanjim/nui.nvim" },
  -- 	opts = {},
  -- },

  -- Enhanced UI with noice
  -- {
  --   "folke/noice.nvim",
  --   event = "VeryLazy",
  --   opts = {
  --     lsp = {
  --       override = {
  --         ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
  --         ["vim.lsp.util.stylize_markdown"] = true,
  --         ["cmp.entry.get_documentation"] = true,
  --       },
  --     },
  --     presets = {
  --       bottom_search = true,
  --       command_palette = true,
  --       long_message_to_split = true,
  --       inc_rename = false,
  --       lsp_doc_border = false,
  --     },
  --   },
  --   dependencies = {
  --     "MunifTanjim/nui.nvim",
  --     "rcarriga/nvim-notify",
  --   },
  -- },

  -- Px to rem converter
  {
    "jsongerber/nvim-px-to-rem",
    opts = {},
  },

  -- Blade syntax highlighting
  "Eduruiz/vim-blade",

  -- File explorer
  {
    "echasnovski/mini.files",
    version = "false",
    opts = {},
    dependencies = {
      { "echasnovski/mini.icons", version = "*" },
    },
  },

  -- Movement plugin
  {
    "ggandor/leap.nvim",
    config = function()
      -- Don't create default mappings to avoid conflicts
      -- require('leap').create_default_mappings()

      -- Use different keys that don't conflict
      vim.keymap.set({ "n", "x", "o" }, "gs", "<Plug>(leap-forward)", { desc = "Leap forward" })
      vim.keymap.set({ "n", "x", "o" }, "gS", "<Plug>(leap-backward)", { desc = "Leap backward" })
      vim.keymap.set({ "n", "x", "o" }, "gz", "<Plug>(leap-from-window)", { desc = "Leap from window" })
    end,
    dependencies = { "tpope/vim-repeat" },
  },

  -- Floating terminal
  {
    "voldikss/vim-floaterm",
    keys = {
      { "<F1>", ":FloatermToggle<CR>" },
      { "<F1>", "<C-\\><C-n>:FloatermToggle<CR>", mode = "t" },
    },
    cmd = { "FloatermToggle" },
    init = function()
      vim.g.floaterm_width = 0.8
      vim.g.floaterm_height = 0.8
    end,
  },

  -- Scrollbar
  {
    "petertriho/nvim-scrollbar",
    opts = {
      excluded_filetypes = { "neo-tree" },
      marks = {
        Cursor = {
          text = " ",
          priority = 99,
        },
      },
      handle = {
        blend = 90,
        highlight = "Cursor",
      },
    },
  },

  -- Find and replace
  {
    "nvim-pack/nvim-spectre",
    opts = {},
    dependencies = { "nvim-lua/plenary.nvim" },
  },

  -- AI completion
  {
    "Exafunction/codeium.vim",
    config = function()
      vim.g.codium_chat_enabled = true
      vim.keymap.set("i", "<C-g>", function()
        return vim.fn["codeium#Accept"]()
      end, { expr = true, silent = true })
      vim.keymap.set("i", "<c-;>", function()
        return vim.fn["codeium#CycleCompletions"](1)
      end, { expr = true, silent = true })
      vim.keymap.set("i", "<c-,>", function()
        return vim.fn["codeium#CycleCompletions"](-1)
      end, { expr = true, silent = true })
      vim.keymap.set("i", "<c-x>", function()
        return vim.fn["codeium#Clear"]()
      end, { expr = true, silent = true })
    end,
  },

  -- Session management
  -- { "rmagatti/auto-session", opts = {} },

  -- Git signs
  {
    "lewis6991/gitsigns.nvim",
    opts = {
      signs = {
        add = { text = "+" },
        change = { text = "~" },
        delete = { text = "_" },
        topdelete = { text = "‾" },
        changedelete = { text = "~" },
      },
      on_attach = function(bufnr)
        local gs = package.loaded.gitsigns
        local function map(mode, l, r, opts)
          opts = opts or {}
          opts.buffer = bufnr
          vim.keymap.set(mode, l, r, opts)
        end

        -- Navigation
        map({ "n", "v" }, "]c", function()
          if vim.wo.diff then
            return "]c"
          end
          vim.schedule(function()
            gs.next_hunk()
          end)
          return "<Ignore>"
        end, { expr = true, desc = "Jump to next hunk" })

        map({ "n", "v" }, "[c", function()
          if vim.wo.diff then
            return "[c"
          end
          vim.schedule(function()
            gs.prev_hunk()
          end)
          return "<Ignore>"
        end, { expr = true, desc = "Jump to previous hunk" })

        -- Actions
        map("v", "<leader>hs", function()
          gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
        end, { desc = "stage git hunk" })
        map("v", "<leader>hr", function()
          gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
        end, { desc = "reset git hunk" })
        map("n", "<leader>hs", gs.stage_hunk, { desc = "git stage hunk" })
        map("n", "<leader>hr", gs.reset_hunk, { desc = "git reset hunk" })
        map("n", "<leader>hS", gs.stage_buffer, { desc = "git Stage buffer" })
        map("n", "<leader>hu", gs.undo_stage_hunk, { desc = "undo stage hunk" })
        map("n", "<leader>hR", gs.reset_buffer, { desc = "git Reset buffer" })
        map("n", "<leader>hp", gs.preview_hunk, { desc = "preview git hunk" })
        map("n", "<leader>hb", function()
          gs.blame_line({ full = false })
        end, { desc = "git blame line" })
        map("n", "<leader>hd", gs.diffthis, { desc = "git diff against index" })
        map("n", "<leader>hD", function()
          gs.diffthis("~")
        end, { desc = "git diff against last commit" })

        -- Toggles
        map("n", "<leader>tb", gs.toggle_current_line_blame, { desc = "toggle git blame line" })
        map("n", "<leader>td", gs.toggle_deleted, { desc = "toggle git show deleted" })

        -- Text object
        map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>", { desc = "select git hunk" })
      end,
    },
  },

  -- Enhanced which-key
  {
    "folke/which-key.nvim",
    event = "VimEnter",
    opts = {
      delay = 0,
      icons = {
        mappings = vim.g.have_nerd_font,
        keys = vim.g.have_nerd_font and {} or {
          Up = "<Up> ",
          Down = "<Down> ",
          Left = "<Left> ",
          Right = "<Right> ",
          C = "<C-…> ",
          M = "<M-…> ",
          D = "<D-…> ",
          S = "<S-…> ",
          CR = "<CR> ",
          Esc = "<Esc> ",
          ScrollWheelDown = "<ScrollWheelDown> ",
          ScrollWheelUp = "<ScrollWheelUp> ",
          NL = "<NL> ",
          BS = "<BS> ",
          Space = "<Space> ",
          Tab = "<Tab> ",
          F1 = "<F1>",
          F2 = "<F2>",
          F3 = "<F3>",
          F4 = "<F4>",
          F5 = "<F5>",
          F6 = "<F6>",
          F7 = "<F7>",
          F8 = "<F8>",
          F9 = "<F9>",
          F10 = "<F10>",
          F11 = "<F11>",
          F12 = "<F12>",
        },
      },
      spec = {
        { "<leader>c", group = "[C]ode" },
        { "<leader>d", group = "[D]ocument" },
        { "<leader>r", group = "[R]ename" },
        { "<leader>s", group = "[S]earch" },
        { "<leader>w", group = "[W]orkspace" },
        { "<leader>t", group = "[T]oggle" },
        { "<leader>h", group = "Git [H]unk", mode = { "n", "v" } },
      },
    },
  },

  -- Telescope fuzzy finder
  {
    "nvim-telescope/telescope.nvim",
    event = "VimEnter",
    dependencies = {
      "nvim-lua/plenary.nvim",
      {
        "nvim-telescope/telescope-fzf-native.nvim",
        build = "make",
        cond = function()
          return vim.fn.executable("make") == 1
        end,
      },
      { "nvim-telescope/telescope-ui-select.nvim" },
      { "nvim-tree/nvim-web-devicons", enabled = vim.g.have_nerd_font },
    },
    config = function()
      require("telescope").setup({
        defaults = {
          layout_config = {
            preview_width = 50,
            horizontal = {
              width = 0.9,
              preview_cutoff = 0,
            },
          },
          path_display = { "smart" },
          mappings = {
            i = {
              ["<C-;>"] = require("telescope.actions.layout").toggle_preview,
            },
          },
        },
        extensions = {
          ["ui-select"] = {
            require("telescope.themes").get_dropdown(),
          },
        },
      })

      pcall(require("telescope").load_extension, "fzf")
      pcall(require("telescope").load_extension, "ui-select")

      local builtin = require("telescope.builtin")
      vim.keymap.set("n", "<leader>sh", builtin.help_tags, { desc = "[S]earch [H]elp" })
      vim.keymap.set("n", "<leader>sk", builtin.keymaps, { desc = "[S]earch [K]eymaps" })
      vim.keymap.set("n", "<leader>sf", builtin.find_files, { desc = "[S]earch [F]iles" })
      vim.keymap.set("n", "<leader>ss", builtin.builtin, { desc = "[S]earch [S]elect Telescope" })
      vim.keymap.set("n", "<leader>sw", builtin.grep_string, { desc = "[S]earch current [W]ord" })
      vim.keymap.set("n", "<leader>sg", function()
        builtin.live_grep({ additional_args = { "--fixed-strings" } })
      end, { desc = "[S]earch by [G]rep (literal)" })
      vim.keymap.set("n", "<leader>sR", builtin.live_grep, { desc = "[S]earch by [R]egex" })
      vim.keymap.set("n", "<leader>sd", builtin.diagnostics, { desc = "[S]earch [D]iagnostics" })
      vim.keymap.set("n", "<leader>sr", builtin.resume, { desc = "[S]earch [R]esume" })
      vim.keymap.set("n", "<leader>s.", builtin.oldfiles, { desc = '[S]earch Recent Files ("." for repeat)' })
      vim.keymap.set("n", "<leader><leader>", builtin.buffers, { desc = "[ ] Find existing buffers" })

      vim.keymap.set("n", "<leader>/", function()
        builtin.current_buffer_fuzzy_find(require("telescope.themes").get_dropdown({
          winblend = 10,
          previewer = false,
        }))
      end, { desc = "[/] Fuzzily search in current buffer" })

      vim.keymap.set("n", "<leader>s/", function()
        builtin.live_grep({
          grep_open_files = true,
          prompt_title = "Live Grep in Open Files",
          additional_args = { "--fixed-strings" },
        })
      end, { desc = "[S]earch [/] in Open Files" })

      vim.keymap.set("n", "<leader>sn", function()
        builtin.find_files({ cwd = vim.fn.stdpath("config") })
      end, { desc = "[S]earch [N]eovim files" })

      -- Custom telescope functions
      local function find_git_root()
        local current_file = vim.api.nvim_buf_get_name(0)
        local current_dir
        local cwd = vim.fn.getcwd()
        if current_file == "" then
          current_dir = cwd
        else
          current_dir = vim.fn.fnamemodify(current_file, ":h")
        end

        local git_root =
        vim.fn.systemlist("git -C " .. vim.fn.escape(current_dir, " ") .. " rev-parse --show-toplevel")[1]
        if vim.v.shell_error ~= 0 then
          print("Not a git repository. Searching on current working directory")
          return cwd
        end
        return git_root
      end

      local function live_grep_git_root()
        local git_root = find_git_root()
        if git_root then
          require("telescope.builtin").live_grep({
            search_dirs = { git_root },
            additional_args = { "--fixed-strings" },
          })
        end
      end

      vim.api.nvim_create_user_command("LiveGrepGitRoot", live_grep_git_root, {})
      vim.keymap.set("n", "<leader>sG", ":LiveGrepGitRoot<cr>", { desc = "[S]earch by [G]rep on Git Root" })
      vim.keymap.set("n", "<leader>gf", builtin.git_files, { desc = "Search [G]it [F]iles" })
      vim.keymap.set("n", "<leader>f", builtin.find_files, { desc = "[S]earch [F]iles" })
      vim.keymap.set("n", "<leader>st", builtin.tags, { desc = "[S]earch [T]Tags" })
    end,
  },

  -- LSP Configuration
  {
    "folke/lazydev.nvim",
    ft = "lua",
    opts = {
      library = {
        { path = "${3rd}/luv/library", words = { "vim%.uv" } },
      },
    },
  },

  {
    "neovim/nvim-lspconfig",
    dependencies = {
      { "mason-org/mason.nvim", opts = {} },
      "mason-org/mason-lspconfig.nvim",
      "WhoIsSethDaniel/mason-tool-installer.nvim",
      { "j-hui/fidget.nvim", opts = {} },
      "saghen/blink.cmp",
    },
    config = function()
      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("kickstart-lsp-attach", { clear = true }),
        callback = function(event)
          local map = function(keys, func, desc, mode)
            mode = mode or "n"
            vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
          end

          -- Modern LSP keybindings
          map("grn", vim.lsp.buf.rename, "[R]e[n]ame")
          map("gra", vim.lsp.buf.code_action, "[G]oto Code [A]ction", { "n", "x" })
          map("grr", require("telescope.builtin").lsp_references, "[G]oto [R]eferences")
          map("gri", require("telescope.builtin").lsp_implementations, "[G]oto [I]mplementation")
          map("grd", require("telescope.builtin").lsp_definitions, "[G]oto [D]efinition")
          map("grD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")
          map("gO", require("telescope.builtin").lsp_document_symbols, "Open Document Symbols")
          map("gW", require("telescope.builtin").lsp_dynamic_workspace_symbols, "Open Workspace Symbols")
          map("grt", require("telescope.builtin").lsp_type_definitions, "[G]oto [T]ype Definition")

          -- Keep some classic bindings for compatibility
          map("K", vim.lsp.buf.hover, "Hover Documentation")
          map("<leader>rn", vim.lsp.buf.rename, "[R]e[n]ame")
          map("<leader>ca", vim.lsp.buf.code_action, "[C]ode [A]ction")
          map("<leader>D", require("telescope.builtin").lsp_type_definitions, "Type [D]efinition")
          map("<leader>ds", require("telescope.builtin").lsp_document_symbols, "[D]ocument [S]ymbols")
          map(
            "<leader>ws",
            require("telescope.builtin").lsp_dynamic_workspace_symbols,
            "[W]orkspace [S]ymbols"
          )
          map("gd", require("telescope.builtin").lsp_definitions, "[G]oto [D]efinition")
          map("gr", require("telescope.builtin").lsp_references, "[G]oto [R]eferences")
          map("gI", require("telescope.builtin").lsp_implementations, "[G]oto [I]mplementation")
          map("gD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")
          local client = vim.lsp.get_client_by_id(event.data.client_id)

          -- Helper function for version compatibility
          local function client_supports_method(client, method, bufnr)
            if vim.fn.has("nvim-0.11") == 1 then
              return client:supports_method(method, bufnr)
            else
              return client.supports_method(method, { bufnr = bufnr })
            end
          end

          -- Highlight references
          if
            client
            and client_supports_method(
              client,
              vim.lsp.protocol.Methods.textDocument_documentHighlight,
              event.buf
            )
          then
            local highlight_augroup =
            vim.api.nvim_create_augroup("kickstart-lsp-highlight", { clear = false })
            vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
              buffer = event.buf,
              group = highlight_augroup,
              callback = vim.lsp.buf.document_highlight,
            })

            vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
              buffer = event.buf,
              group = highlight_augroup,
              callback = vim.lsp.buf.clear_references,
            })

            vim.api.nvim_create_autocmd("LspDetach", {
              group = vim.api.nvim_create_augroup("kickstart-lsp-detach", { clear = true }),
              callback = function(event2)
                vim.lsp.buf.clear_references()
                vim.api.nvim_clear_autocmds({ group = "kickstart-lsp-highlight", buffer = event2.buf })
              end,
            })
          end

          -- Inlay hints toggle
          if
            client
            and client_supports_method(client, vim.lsp.protocol.Methods.textDocument_inlayHint, event.buf)
          then
            map("<leader>th", function()
              vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = event.buf }))
            end, "[T]oggle Inlay [H]ints")
          end

          -- Create Format command
          vim.api.nvim_buf_create_user_command(event.buf, "Format", function(_)
            vim.lsp.buf.format()
          end, { desc = "Format current buffer with LSP" })
        end,
      })

      -- Diagnostic configuration
      vim.diagnostic.config({
        severity_sort = true,
        float = { border = "rounded", source = "if_many" },
        underline = { severity = vim.diagnostic.severity.ERROR },
        signs = vim.g.have_nerd_font and {
          text = {
            [vim.diagnostic.severity.ERROR] = "󰅚 ",
            [vim.diagnostic.severity.WARN] = "󰀪 ",
            [vim.diagnostic.severity.INFO] = "󰋽 ",
            [vim.diagnostic.severity.HINT] = "󰌶 ",
          },
        } or {
            text = {
              [vim.diagnostic.severity.ERROR] = "E",
              [vim.diagnostic.severity.WARN] = "W",
              [vim.diagnostic.severity.INFO] = "I",
              [vim.diagnostic.severity.HINT] = "H",
            },
          },
        virtual_text = {
          source = "if_many",
          spacing = 2,
        },
      })

      local capabilities = require("blink.cmp").get_lsp_capabilities()

      -- Helper function para ignorar buffers especiais
      local function should_attach_lsp(bufnr)
        local bufname = vim.api.nvim_buf_get_name(bufnr)
        if bufname:match("^fugitive://") or bufname:match("^term://") or bufname:match("^git://") then
          return false
        end
        local buftype = vim.api.nvim_get_option_value("buftype", { buf = bufnr })
        return buftype == ""
      end

      local servers = {
        stylelint_lsp = { filetypes = { "css", "scss", "vue" } },
        ts_ls = {},
        html = { filetypes = { "html", "vue", "blade", "twig", "hbs" } },
        lua_ls = {
          settings = {
            Lua = {
              completion = { callSnippet = "Replace" },
              workspace = { checkThirdParty = false },
              telemetry = { enable = false },
            },
          },
        },
      }

      local ensure_installed = vim.tbl_keys(servers or {})
      vim.list_extend(ensure_installed, { "stylua" })
      require("mason-tool-installer").setup({ ensure_installed = ensure_installed })

      require("mason-lspconfig").setup({
        ensure_installed = {},
        automatic_installation = true,
        automatic_enable = false,
        handlers = {
          function(server_name)
            -- Desabilita o eslint LSP completamente (usamos eslint_d via conform)
            if server_name == "eslint" then
              return
            end

            local server = servers[server_name] or {}
            server.capabilities = vim.tbl_deep_extend("force", {}, capabilities, server.capabilities or {})

            -- Adiciona verificação para não anexar a buffers especiais
            local original_on_attach = server.on_attach
            server.on_attach = function(client, bufnr)
              if not should_attach_lsp(bufnr) then
                vim.lsp.buf_detach_client(bufnr, client.id)
                return
              end
              if original_on_attach then
                original_on_attach(client, bufnr)
              end
            end

            require("lspconfig")[server_name].setup(server)
          end,
        },
      })
    end,
  },

  -- Autoformat
  {
    "stevearc/conform.nvim",
    event = { "BufWritePre" },
    cmd = { "ConformInfo" },
    keys = {
      {
        "<leader>fm",
        function()
          require("conform").format({ async = true, lsp_format = "fallback" })
        end,
        mode = "",
        desc = "[F]or[m]at buffer",
      },
    },
    opts = {
      notify_on_error = false,
      format_on_save = false,
      -- format_on_save = function(bufnr)
      -- 	local disable_filetypes = { c = true, cpp = true, vue = true, javascript = true, typescript = true }
      -- 	if disable_filetypes[vim.bo[bufnr].filetype] then
      -- 		return nil
      -- 	else
      -- 		return {
      -- 			timeout_ms = 20000,
      -- 			lsp_format = "fallback",
      -- 		}
      -- 	end
      -- end,
      formatters_by_ft = {
        lua = { "stylua" },
        javascript = { "eslint_d", "prettier" },
        vue = { "eslint_d", "prettier" },
        typescript = { "eslint_d", "prettier" },
        javascriptreact = { "eslint_d", "prettier" },
        typescriptreact = { "eslint_d", "prettier" },
      },
    },
  },

  -- Modern completion with blink.cmp
  {
    "saghen/blink.cmp",
    event = "VimEnter",
    version = "1.*",
    dependencies = {
      {
        "L3MON4D3/LuaSnip",
        version = "2.*",
        build = (function()
          if vim.fn.has("win32") == 1 or vim.fn.executable("make") == 0 then
            return
          end
          return "make install_jsregexp"
        end)(),
        dependencies = {
          "rafamadriz/friendly-snippets",
          "mlaursen/vim-react-snippets",
        },
        config = function()
          require("luasnip.loaders.from_vscode").lazy_load()
          require("vim-react-snippets").lazy_load()
          require("luasnip").config.setup({})
        end,
      },
      "folke/lazydev.nvim",
    },
    opts = {
      keymap = { preset = "default" },
      appearance = { nerd_font_variant = "mono" },
      completion = {
        documentation = { auto_show = false, auto_show_delay_ms = 500 },
      },
      sources = {
        default = { "lsp", "path", "snippets", "lazydev" },
        providers = {
          lazydev = { module = "lazydev.integrations.blink", score_offset = 100 },
        },
      },
      snippets = { preset = "luasnip" },
      fuzzy = { implementation = "lua" },
      signature = { enabled = true },
    },
  },
  -- TokyoNight theme with custom configuration
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    opts = {
      styles = {
        comments = { italic = false },
      },
      on_colors = function(colors)
        colors.gitSigns = {
          add = colors.teal,
          change = colors.purple,
          delete = colors.red,
        }
      end,
      on_highlights = function(hl, c)
        local util = require("tokyonight.util")
        local prompt = "#2d3149"

        -- Your custom highlighting
        hl.BufferlineInactive = { bg = c.bg_dark }
        hl.BufferlineActiveSeparator = {
          bg = c.bg,
          fg = util.darken(c.bg_dark, 0.85, "#000000"),
        }
        hl.BufferlineInactiveSeparator = {
          bg = c.bg_dark,
          fg = util.darken(c.bg_dark, 0.85, "#000000"),
        }

        hl.NeoTreeFileNameOpened = { fg = c.orange }
        hl.GitSignsCurrentLineBlame = { fg = c.fg_gutter }

        -- Status line
        hl.StatusLine = {
          bg = util.darken(c.bg_dark, 0.85, "#000000"),
          fg = c.fg_dark,
        }
        hl.StatusLineComment = {
          bg = util.darken(c.bg_dark, 0.85, "#000000"),
          fg = c.comment,
        }

        -- Line numbers
        hl.LineNrAbove = { fg = c.fg_gutter }
        hl.LineNr = { fg = util.lighten(c.fg_gutter, 0.7) }
        hl.LineNrBelow = { fg = c.fg_gutter }

        -- Telescope
        hl.TelescopeNormal = { bg = c.bg_dark, fg = c.fg_dark }
        hl.TelescopeBorder = { bg = c.bg_dark, fg = c.bg_dark }
        hl.TelescopePromptNormal = { bg = prompt }
        hl.TelescopePromptBorder = { bg = prompt, fg = prompt }
        hl.TelescopePromptTitle = { bg = c.bg, fg = c.fg_dark }
        hl.TelescopePreviewTitle = { bg = c.bg_dark, fg = c.bg_dark }
        hl.TelescopeResultsTitle = { bg = c.bg_dark, fg = c.bg_dark }

        -- Floaterm
        hl.Floaterm = { bg = prompt }
        hl.FloatermBorder = { bg = prompt, fg = prompt }

        -- Copilot/Codeium
        hl.CopilotSuggestion = { fg = c.comment }

        -- Other customizations
        hl.MsgArea = { bg = util.darken(c.bg_dark, 0.85, "#000000") }
        hl.SpellBad = { undercurl = true, sp = "#7F3A43" }
      end,
    },
    config = function(plugin, opts)
      require("tokyonight").setup(opts)
      vim.cmd("colorscheme tokyonight")
    end,
  },

  -- Lualine statusline
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {
      options = {
        icons_enabled = true,
        theme = "auto",
        component_separators = "|",
        section_separators = "",
      },
      sections = {
        lualine_c = {
          {
            "filename",
            path = 1, -- relative path
          },
        },
      },
      tabline = {
        lualine_a = { "buffers" },
      },
    },
  },

  -- Comments
  { "numToStr/Comment.nvim", opts = {} },

  -- Todo comments
  {
    "folke/todo-comments.nvim",
    event = "VimEnter",
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = { signs = false },
  },

  -- Mini.nvim collection
  {
    "echasnovski/mini.nvim",
    config = function()
      -- Better Around/Inside textobjects
      require("mini.ai").setup({ n_lines = 500 })

      -- Add/delete/replace surroundings (enhanced vim-surround)
      require("mini.surround").setup()
    end,
  },

  -- Treesitter
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    main = "nvim-treesitter.configs",
    dependencies = {
      "nvim-treesitter/nvim-treesitter-textobjects",
      "nvim-tree/nvim-web-devicons",
    },
    opts = {
      ensure_installed = {
        "bash",
        "c",
        "diff",
        "html",
        "lua",
        "luadoc",
        "markdown",
        "markdown_inline",
        "query",
        "vim",
        "vimdoc",
        "cpp",
        "go",
        "python",
        "rust",
        "tsx",
        "javascript",
        "typescript",
      },
      auto_install = true,
      highlight = {
        enable = true,
        additional_vim_regex_highlighting = { "ruby", "scss" },
      },
      indent = { enable = true, disable = { "ruby" } },
      incremental_selection = {
        enable = true,
        keymaps = {
          init_selection = "<c-space>",
          node_incremental = "<c-space>",
          scope_incremental = "<c-s>",
          node_decremental = "<M-space>",
        },
      },
      textobjects = {
        select = {
          enable = true,
          lookahead = true,
          keymaps = {
            ["aa"] = "@parameter.outer",
            ["ia"] = "@parameter.inner",
            ["af"] = "@function.outer",
            ["if"] = "@function.inner",
            ["ac"] = "@class.outer",
            ["ic"] = "@class.inner",
          },
        },
        move = {
          enable = true,
          set_jumps = true,
          goto_next_start = {
            ["]m"] = "@function.outer",
            ["]]"] = "@class.outer",
          },
          goto_next_end = {
            ["]M"] = "@function.outer",
            ["]["] = "@class.outer",
          },
          goto_previous_start = {
            ["[m"] = "@function.outer",
            ["[["] = "@class.outer",
          },
          goto_previous_end = {
            ["[M"] = "@function.outer",
            ["[]"] = "@class.outer",
          },
        },
        swap = {
          enable = true,
          swap_next = {
            ["<leader>a"] = "@parameter.inner",
          },
          swap_previous = {
            ["<leader>A"] = "@parameter.inner",
          },
        },
      },
    },
  },

  -- File tree
  {
    "nvim-tree/nvim-tree.lua",
    opts = {
      sort = { sorter = "case_sensitive" },
      view = { width = 30 },
      renderer = { group_empty = true },
      filters = { dotfiles = true },
    },
  },
}, {
    ui = {
      icons = vim.g.have_nerd_font and {} or {
        cmd = "⌘",
        config = "🛠",
        event = "📅",
        ft = "📂",
        init = "⚙",
        keys = "🗝",
        plugin = "🔌",
        runtime = "💻",
        require = "🌙",
        source = "📄",
        start = "🚀",
        task = "📌",
        lazy = "💤 ",
      },
    },
  })

-- [[ Custom Keymaps ]]

-- Insert mode mappings to quickly exit to normal mode
vim.keymap.set("i", "jk", "<Esc>", { noremap = true })
vim.keymap.set("i", "kj", "<Esc>", { noremap = true })
vim.keymap.set("i", "jj", "<Esc>", { noremap = true })
vim.keymap.set("i", "kk", "<Esc>", { noremap = true })

-- Use ; as : (no need to use shift)
vim.keymap.set("n", ";", ":", { noremap = true })

-- Save with Ctrl+S
vim.keymap.set("n", "<C-s>", ":w<CR>", { noremap = true })
vim.keymap.set("i", "<C-s>", "<Esc>:w<CR>a", { noremap = true })

-- Toggle spell check
vim.keymap.set("n", "<F3>", ":setlocal spell! spelllang=en_us<CR>", { noremap = true })

-- Fix word spell with first suggestion
vim.keymap.set("n", "<Leader>z", "1z=", { noremap = true, desc = "Fix word spell with first suggestion" })

-- Convert px to rem
vim.keymap.set("n", "<leader>pxx", ":PxToRemCursor<CR>", { noremap = true })
vim.keymap.set("n", "<leader>pxl", ":PxToRemLine<CR>", { noremap = true })
vim.keymap.set("v", "<leader>px", ":PxToRemLine<CR>", { noremap = true })

-- Laravel specific maps
vim.keymap.set("n", "<Leader>lr", ":e routes/web.php<CR>", { noremap = true })
vim.keymap.set("n", "<Leader>lc", ":e config/app.php<CR>", { noremap = true })
vim.keymap.set("n", "<Leader>lv", ":e resources/views/<CR>", { noremap = true })

-- File shortcuts
vim.keymap.set("n", "<Leader>ov", ":e ~/.config/nvim/init.lua<CR>", { noremap = true, desc = "Open nvim config file" })
vim.keymap.set("n", "<Leader>or", ":so ~/.config/nvim/init.lua<CR>", { noremap = true, desc = "Reload nvim config" })
vim.keymap.set(
  "n",
  "<Leader>oh",
  ":e ~/Dropbox/docs/appcivico/hours.md<CR>",
  { noremap = true, desc = "Open hours md file" }
)
vim.keymap.set(
  "n",
  "<Leader>op",
  ":e ~/Dropbox/docs/appcivico/proposta<CR>",
  { noremap = true, desc = "Open proposal file" }
)
vim.keymap.set(
  "n",
  "<Leader>ot",
  ":e ~/Dropbox/docs/appcivico/vagas.md<CR>",
  { noremap = true, desc = "Open job op file" }
)
vim.keymap.set("n", "<Leader>ok", ":e ~/.config/kitty/kitty.conf<CR>", { noremap = true, desc = "Open kitty config" })
vim.keymap.set(
  "n",
  "<Leader>od",
  ":e ~/.config/hypr/custom/keybinds.conf<CR>",
  { noremap = true, desc = "Open desktop (hyprland) file" }
)

-- Minifiles shortcut
vim.keymap.set("n", "<F2>", ":lua MiniFiles.open()<CR>", { noremap = true, desc = "Open minifiles explorer" })

-- Buffer management
vim.keymap.set("n", "<C-6>", ":b#<CR>", { noremap = true })
vim.keymap.set("n", "<Leader>x", ":bd<CR>", { noremap = true, desc = "Close current buffer" })
vim.keymap.set("n", "<leader>b", require("telescope.builtin").buffers, { desc = "Find existing [b]uffers" })

-- [[ Custom Commands ]]

-- Words I can't get right
vim.cmd([[iabbrev lenght length]])

-- JSON prettify
vim.cmd("command! -nargs=0 PrettifyJson %!python3 -m json.tool")


-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et
