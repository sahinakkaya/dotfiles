--[[
lvim is the global options object

Linters should be
filled in as strings with either
a global executable or a path to
an executable
]] -- THESE ARE EXAMPLE CONFIGS FEEL FREE TO CHANGE TO WHATEVER YOU WANT
-- general
lvim.log.level = 'warn'
lvim.format_on_save = true
lvim.colorscheme = 'onedarker'

-- Use which-key to add extra bindings with the leader-key prefix
-- lvim.builtin.which_key.mappings["P"] = { "<cmd>Telescope projects<CR>", "Projects" }

-- TODO: User Config for predefined plugins
-- After changing plugin config exit and reopen LunarVim, Run :PackerInstall :PackerCompile
lvim.builtin.terminal.active = true
lvim.builtin.notify.active = true
lvim.builtin.nvimtree.setup.view.side = 'left'
lvim.builtin.nvimtree.show_icons.git = 0
-- lvim.builtin.nvimtree.git = 0
-- lvim.builtin.nvimtree.setup.git.ignore = false
lvim.builtin.autopairs.fast_wrap.map = '<C-l>'

-- if you don't want all the parsers change this to a table of the ones you want
lvim.builtin.treesitter.ensure_installed = {
  'bash', 'c', 'javascript', 'json', 'lua', 'python', 'typescript', 'css',
  'rust', 'java', 'yaml'
}

lvim.builtin.treesitter.ignore_install = {'haskell'}
lvim.builtin.treesitter.highlight.enabled = true

-- generic LSP settings

-- ---@usage disable automatic installation of servers
-- lvim.lsp.automatic_servers_installation = false

-- ---@usage Select which servers should be configured manually. Requires `:LvimCacheRest` to take effect.
-- See the full default list `:lua print(vim.inspect(lvim.lsp.override))`
-- vim.list_extend(lvim.lsp.override, { "pyright" })

-- ---@usage setup a server -- see: https://www.lunarvim.org/languages/#overriding-the-default-configuration
-- local opts = {} -- check the lspconfig documentation for a list of all possible options
-- require("lvim.lsp.manager").setup("pylsp", opts)

-- you can set a custom on_attach function that will be used for all the language servers
-- See <https://github.com/neovim/nvim-lspconfig#keybindings-and-completion>
-- lvim.lsp.on_attach_callback = function(client, bufnr)
--   local function buf_set_option(...)
--     vim.api.nvim_buf_set_option(bufnr, ...)
--   end
--   --Enable completion triggered by <c-x><c-o>
--   buf_set_option("omnifunc", "v:lua.vim.lsp.omnifunc")
-- end
-- you can overwrite the null_ls setup table (useful for setting the root_dir function)
-- lvim.lsp.null_ls.setup = {
--   root_dir = require("lspconfig").util.root_pattern("Makefile", ".git", "node_modules"),
-- }
-- or if you need something more advanced
-- lvim.lsp.null_ls.setup.root_dir = function(fname)
--   if vim.bo.filetype == "javascript" then
--     eturn require("lspconfig/util").root_pattern("Makefile", ".git", "node_modules")(fname)
--       or require("lspconfig/util").path.dirname(fname)
--   elseif vim.bo.filetype == "php" then
--     return require("lspconfig/util").root_pattern("Makefile", ".git", "composer.json")(fname) or vim.fn.getcwd()
--   else
--     return require("lspconfig/util").root_pattern("Makefile", ".git")(fname) or require("lspconfig/util").path.dirname(fname)
--   end
-- end

-- -- set a formatter, this will override the language server formatting capabilities (if it exists)
local formatters = require 'lvim.lsp.null-ls.formatters'
formatters.setup {
  {exe = 'black', filetypes = {'python'}},
  {exe = 'isort', filetypes = {'python'}}, {
    exe = 'lua-format',
    filetypes = {'lua'},
    args = {
      '--indent-width=2', '--chop-down-kv-table',
      '--double-quote-to-single-quote'
    }

  }, {
    exe = 'prettier',
    args = {'--print-width', '100'},
    filetypes = {'javascript', 'typescript', 'typescriptreact'}
  }
  -- {
  --   exe = "prettier",
  --   ---@usage arguments to pass to the formatter
  --   -- these cannot contain whitespaces, options such as `--line-width 80` become either `{'--line-width', '80'}` or `{'--line-width=80'}`
  --   args = { "--print-with", "100" },
  --   ---@usage specify which filetypes to enable. By default a providers will attach to all the filetypes it supports.
  --   filetypes = { "typescript", "typescriptreact" },
  -- },
}

-- -- set additional linters
-- local linters = require "lvim.lsp.null-ls.linters"
-- linters.setup {
--   { exe = "flake8", filetypes = { "python" } },
--   {
--     exe = "shellcheck",
--     ---@usage arguments to pass to the formatter
--     -- these cannot contain whitespaces, options such as `--line-width 80` become either `{'--line-width', '80'}` or `{'--line-width=80'}`
--     args = { "--severity", "warning" },
--   },
--   {
--     exe = "codespell",
--     ---@usage specify which filetypes to enable. By default a providers will attach to all the filetypes it supports.
--     filetypes = { "javascript", "python" },
--   },
-- }

lvim.builtin.telescope.extensions.media_files = {
  -- filetypes whitelist
  -- defaults to {"png", "jpg", "mp4", "webm", "pdf"}
  filetypes = {'png', 'webp', 'jpg', 'jpeg'},
  find_cmd = 'rg' -- find command (defaults to `fd`)
}

-- Additional Plugins
lvim.plugins = {
  {
    'Asocia/vim-tmux-navigator',
    config = function()
      vim.g.tmux_navigator_disable_when_zoomed = 1
      vim.g.tmux_navigator_no_wrap = 1
    end
  }, {
    'lukas-reineke/indent-blankline.nvim',
    event = 'BufRead',
    config = function() require('plugins.indent-blanckline') end
  }, {'tpope/vim-repeat'}, {'tpope/vim-unimpaired'}, {'tpope/vim-fugitive'},
  {'tpope/vim-abolish'}, {
    'phaazon/hop.nvim',
    event = 'BufRead',
    config = function()
      -- you can configure Hop the way you like here; see :h hop-config
      require('hop').setup({
        keys = 'dhnasoeifgqcrlwvjzpymkbxut',
        term_seq_bias = 1
      })
    end
  }, {
    'rmagatti/goto-preview',
    event = 'BufRead',
    config = function()
      require('goto-preview').setup {
        width = 120, -- Width of the floating window
        height = 25, -- Height of the floating window
        default_mappings = true, -- Bind default mappings
        debug = false, -- Print debug information
        opacity = nil, -- 0-100 opacity level of the floating window where 100 is fully transparent.
        post_open_hook = nil -- A function taking two arguments, a buffer and a window to be ran as a hook.
        -- You can use "default_mappings = true" setup option
        -- Or explicitly set keybindings
        -- vim.cmd("nnoremap gpd <cmd>lua require('goto-preview').goto_preview_definition()<CR>")
        -- vim.cmd("nnoremap gpi <cmd>lua require('goto-preview').goto_preview_implementation()<CR>")
        -- vim.cmd("nnoremap gP <cmd>lua require('goto-preview').close_all_win()<CR>")
      }
    end
  }, {'simrat39/symbols-outline.nvim', event = 'BufRead'}, -- {'tpope/vim-dadbod'}
  -- {"folke/tokyonight.nvim"},
  {
    'monaqa/dial.nvim',
    event = 'BufRead',
    config = function() require('plugins.dial') end
  }, {'folke/trouble.nvim', cmd = 'TroubleToggle'}, {
    'iamcco/markdown-preview.nvim',
    run = 'cd app && npm install',
    ft = 'markdown',
    cmd = 'MarkdownPreview',
    config = function() vim.g.mkdp_auto_start = 1 end
  }, {
    'folke/persistence.nvim',
    event = 'BufReadPre', -- this will only start session saving when an actual file was opened
    module = 'persistence',
    config = function()
      require('persistence').setup {
        dir = vim.fn.expand(vim.fn.stdpath 'config' .. '/session/'),
        options = {'buffers', 'curdir', 'tabpages', 'winsize'}
      }
    end

  }, {'felipec/vim-sanegx'}, {'tommcdo/vim-exchange', event = 'BufRead'}, {
    'lervag/vimtex',
    config = function()
      vim.g.vimtex_compiler_engine = 'xelatex'
      vim.g.vimtex_view_method = 'zathura'
      vim.g.tex_conceal = 'abdmg'

      vim.cmd([[
" Create mapping to toggle compiling with shell escape or not
    let g:vimtex_compiler_latexmk = {
        \ 'build_dir' : '',
        \ 'callback' : 1,
        \ 'continuous' : 1,
        \ 'executable' : 'latexmk',
        \ 'hooks' : [],
        \ 'options' : [
        \   '-verbose',
        \   '-file-line-error',
        \   '-synctex=1',
        \   '-interaction=nonstopmode',
        \ ],
        \}
nnoremap <F12> :call ShellEscape()<CR>
function! ShellEscape()
    if g:vimtex_compiler_latexmk.options[0] ==# '-shell-escape'
        call remove(g:vimtex_compiler_latexmk.options, 0)
        echo "shell escape disabled"
    else
        call insert(g:vimtex_compiler_latexmk.options, '-shell-escape', 0)
        echo "shell escape enabled"
    endif
    VimtexReload
endfunction
      ]])
    end
  },
  {'nathom/filetype.nvim', config = function() vim.g.did_load_filetypes = 1 end},
  {'gko/vim-coloresque'}, --   {'antonk52/bad-practices.nvim', config=function ()
  {
    'machakann/vim-sandwich',
    config = function()
      vim.cmd [[
runtime macros/sandwich/keymap/surround.vim
      ]]

    end
  }, --     require('bad_practices').setup({
  --     most_splits = 3, -- how many splits are considered a good practice(default: 3)
  --     most_tabs = 3, -- how many tabs are considered a good practice(default: 3)
  --     max_hjkl = 10, -- how many times you can spam hjkl keys in a row(default: 10)
  -- })
  --  end
  -- }
  {
    'nvim-telescope/telescope-media-files.nvim',
    config = function() require('telescope').load_extension('media_files') end
  }, {
    'ray-x/lsp_signature.nvim',
    config = function() require'lsp_signature'.on_attach() end,
    event = 'BufRead'
  }, {'junegunn/vim-easy-align'}, {
    'xiyaowong/nvim-transparent',
    config = function()
      require('transparent').setup({
        enable = true, -- boolean: enable transparent
        extra_groups = { -- table/string: additional groups that should be clear
          -- In particular, when you set it to 'all', that means all avaliable groups

          -- example of akinsho/nvim-bufferline.lua
          'BufferLineTabClose', 'BufferlineBufferSelected', 'BufferLineFill',
          'BufferLineBackground', 'BufferLineSeparator',
          'BufferLineIndicatorSelected'
        },
        exclude = {} -- table: groups you don't want to clear
      })
    end

  }

}

-- Autocommands (https://neovim.io/doc/user/autocmd.html)
lvim.autocommands.custom_groups = {
  -- {'ColorScheme', '*', 'lua require\'lightspeed\'.init_highlight(true)'},
  {'BufWinEnter', 'term://*', 'setlocal nonumber'},
  {'BufWinEnter,BufWinEnter', 'term://*', 'setlocal nonumber'},
  {'BufWinEnter,BufWinEnter', '*.tex', 'setlocal spell'},
  {'BufWinEnter,BufWinEnter', '*.asm', 'setlocal ft=nasm'},
  {'BufWinEnter,BufWinEnter', '*.s', 'setlocal ft=nasm'},
  {'BufWinEnter,BufWinEnter', '*.s', 'setlocal tabstop=4'},
  {'BufWinEnter,BufWinEnter', '*.s', 'setlocal shiftwidth=4'},
  {'BufWinEnter,BufWinEnter', '*.s', 'setlocal expandtab'}
}

lvim.autocommands._cursorline = {
  {'VimEnter,WinEnter,BufWinEnter', '*', 'setlocal cursorline'},
  {'WinLeave', '*', 'setlocal nocursorline'}
}
lvim.autocommands._toggle_relative_number = {
  {'InsertEnter', '*', ':setlocal norelativenumber'},
  {'InsertLeave', '*', ':setlocal relativenumber'}
}

lvim.autocommands._FirenvimOverrides = {}

require('settings')
require('keybindings')
require('plugins.dashboard')
lvim.builtin.which_key.on_config_done =
    function() require('plugins.whichkey') end

-- require'lsp_signature'.setup({
--   bind = true, -- This is mandatory, otherwise border config won't get registered.
--   handler_opts = {border = 'rounded'}
-- })
