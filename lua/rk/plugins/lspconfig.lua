return {
  "neovim/nvim-lspconfig",
  event = { "BufReadPre", "BufNewFile" },
  dependencies = {
    "hrsh7th/cmp-nvim-lsp",
    { "antosha417/nvim-lsp-file-operations", config = true }, -- Loads and runs setup by default
    { "folke/neodev.nvim", opts = {} }, -- Loads and runs setup with default opts
  },
  config = function()
    -- import lspconfig plugin
    local lspconfig = require("lspconfig")

    -- import cmp-nvim-lsp plugin
    local cmp_nvim_lsp = require("cmp_nvim_lsp")

    local keymap = vim.keymap -- for conciseness

    -- Autocommand that runs when an LSP server attaches to a buffer
    vim.api.nvim_create_autocmd("LspAttach", {
      group = vim.api.nvim_create_augroup("UserLspConfig", {}), -- Create a unique augroup
      callback = function(ev)
        -- Buffer local mappings.
        -- See `:help vim.lsp.*` for documentation on any of the below functions
        local opts = { buffer = ev.buf, silent = true }

        -- set keybinds
        opts.desc = "Show LSP references"
        keymap.set("n", "gR", "<cmd>Telescope lsp_references<CR>", opts) -- show definition, references

        opts.desc = "Go to declaration"
        keymap.set("n", "gD", vim.lsp.buf.declaration, opts) -- go to declaration

        opts.desc = "Show LSP definitions"
        keymap.set("n", "gd", "<cmd>Telescope lsp_definitions<CR>", opts) -- show lsp definitions

        opts.desc = "Show LSP implementations"
        keymap.set("n", "gi", "<cmd>Telescope lsp_implementations<CR>", opts) -- show lsp implementations

        opts.desc = "Show LSP type definitions"
        keymap.set("n", "gt", "<cmd>Telescope lsp_type_definitions<CR>", opts) -- show lsp type definitions

        opts.desc = "See available code actions"
        keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, opts) -- see available code actions, in visual mode will apply to selection

        opts.desc = "Smart rename"
        keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts) -- smart rename

        opts.desc = "Show buffer diagnostics"
        keymap.set("n", "<leader>D", "<cmd>Telescope diagnostics bufnr=0<CR>", opts) -- show diagnostics for file

        opts.desc = "Show line diagnostics"
        keymap.set("n", "<leader>d", vim.diagnostic.open_float, opts) -- show diagnostics for line

        opts.desc = "Go to previous diagnostic"
        keymap.set("n", "[d", vim.diagnostic.goto_prev, opts) -- jump to previous diagnostic in buffer

        opts.desc = "Go to next diagnostic"
        keymap.set("n", "]d", vim.diagnostic.goto_next, opts) -- jump to next diagnostic in buffer

        opts.desc = "Show documentation for what is under cursor"
        keymap.set("n", "K", vim.lsp.buf.hover, opts) -- show documentation for what is under cursor

        opts.desc = "Restart LSP"
        keymap.set("n", "<leader>rs", ":LspRestart<CR>", opts) -- mapping to restart lsp if necessary
      end,
    })

    -- Default capabilities for LSP servers, enabling autocompletion support
    local capabilities = cmp_nvim_lsp.default_capabilities()

    -- Change the Diagnostic symbols in the sign column (gutter)
    local signs = { Error = " ", Warn = " ", Hint = "󰠠 ", Info = " " }
    for type, icon in pairs(signs) do
      local hl = "DiagnosticSign" .. type
      vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
    end

    -- List of LSP servers to be installed by mason-lspconfig and configured below
    -- Add any other servers you use here, e.g., "tsserver", "pyright", "rust_analyzer", etc.
    local servers = {
      "lua_ls",
      "svelte",
      "graphql",
      "emmet_ls",
      "ts_ls",
      "pyright",
      "gopls",
      "jsonls",
      "yamlls",
      "bashls",
      "dockerls",
      "tailwindcss",
      "marksman",
      "rust_analyzer"
    }


    -- Configure each LSP server
    for _, server_name in ipairs(servers) do
      -- Default options for each server
      local opts = {
        capabilities = capabilities,
        -- The `LspAttach` autocommand above will be triggered for general setup (like keymaps)
        -- Server-specific `on_attach` functions or other settings can be defined below.
      }

      -- Server-specific configurations
      if server_name == "lua_ls" then
        opts.settings = {
          Lua = {
            -- Make the language server recognize "vim" global
            diagnostics = {
              globals = { "vim" },
            },
            completion = {
              callSnippet = "Replace",
            },
            -- `neodev.nvim` will also automatically augment `lua_ls` settings
            -- for Neovim configuration development.
          },
        }
      elseif server_name == "svelte" then
        -- Svelte-specific on_attach to notify server about JS/TS file changes
        opts.on_attach = function(client, bufnr)
          -- This on_attach runs *after* the global LspAttach autocommand defined above.
          vim.api.nvim_create_autocmd("BufWritePost", {
            pattern = { "*.js", "*.ts" },
            group = vim.api.nvim_create_augroup("SvelteLspNotify_" .. bufnr, { clear = true }), -- Unique augroup per buffer
            buffer = bufnr, -- Buffer-local autocommand
            callback = function(args)
              -- `args.file` provides the full path of the written file
              if client and client.is_active() and args.file then
                client.notify("$/onDidChangeTsOrJsFile", { uri = vim.uri_from_fname(args.file) })
              end
            end,
          })
        end
      elseif server_name == "graphql" then
        opts.filetypes = { "graphql", "gql", "svelte", "typescriptreact", "javascriptreact" }
      elseif server_name == "emmet_ls" then
        opts.filetypes = { "html", "typescriptreact", "javascriptreact", "css", "sass", "scss", "less", "svelte" }
      -- Add other server specific configurations here:
      -- elseif server_name == "tsserver" then
      --   opts.settings = { ... }
      --   opts.root_dir = function ...
      end

      -- Setup the server with lspconfig
      lspconfig[server_name].setup(opts)
    end
  end,
}
