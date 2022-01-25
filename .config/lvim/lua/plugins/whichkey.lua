lvim.builtin.which_key.mappings['<tab>'] = {'<C-^>', 'alternate file'}
lvim.builtin.which_key.mappings['\\'] = {':vnew<CR>', 'vsplit'}
lvim.builtin.which_key.mappings['-'] = {':new<CR>', 'hsplit'}

-- hop mappings
lvim.builtin.which_key.mappings['w'] = {':HopWord<CR>', 'Hop word'}
lvim.builtin.which_key.mappings['j'] = {':HopLineStartAC<CR>', 'Hop line'}
lvim.builtin.which_key.mappings['k'] = {':HopLineStartBC<CR>', 'Hop line'}

lvim.builtin.which_key.mappings['r'] = {
  ':set invrelativenumber<CR>', 'Toggle relative number'
}
lvim.builtin.which_key.mappings['i'] = {':SymbolsOutline<CR>', 'Index view'}

lvim.builtin.which_key.mappings['P'] = {
  '<cmd>Telescope projects<CR>', 'Projects'
}

lvim.builtin.which_key.mappings['S'] = {
  name = 'Session',
  c = {
    '<cmd>lua require(\'persistence\').load()<cr>',
    'Restore last session for current dir'
  },
  l = {
    '<cmd>lua require(\'persistence\').load({ last = true })<cr>',
    'Restore last session'
  },
  Q = {
    '<cmd>lua require(\'persistence\').stop()<cr>',
    'Quit without saving session'
  }
}
lvim.builtin.which_key.mappings['d'] = {
  -- " Available Debug Adapters:
  -- "   https://microsoft.github.io/debug-adapter-protocol/implementors/adapters/
  -- " Adapter configuration and installation instructions:
  -- "   https://github.com/mfussenegger/nvim-dap/wiki/Debug-Adapter-installation
  -- " Debug Adapter protocol:
  -- "   https://microsoft.github.io/debug-adapter-protocol/
  -- " Debugging
  name = 'Debug',
  e = {':call vimspector#Reset()<cr>', 'exit debug mode'},
  l = {':call vimspector#StepInto()<cr>', 'step into'},
  j = {':call vimspector#StepOver()<cr>', 'step over'},
  h = {':call vimspector#StepOut()<cr>', 'step out'},
  k = {':call vimspector#Restart()<cr>', 'restart debugging'},
  c = {':call vimspector#Continue()<cr>', 'continue'},
  r = {':call vimspector#RunToCursor()<cr>', 'run to cursor'},
  d = {':call vimspector#Launch()<cr>', 'Launch'},
  b = {':call vimspector#ToggleBreakpoint()<cr>', 'toggle breakpoint'},
  B = {'<Plug>VimspectorToggleConditionalBreakpoint', 'toggle breakpoint'},
  C = {':call vimspector#ClearBreakpoints()<cr>', 'clear breakpoints'},
  i = {'<Plug>VimspectorBalloonEval', 'inspect'}
}

-- lvim.builtin.which_key.mappings['t'] = {
--   name = '+Trouble',
--   r = {'<cmd>Trouble lsp_references<cr>', 'References'},
--   f = {'<cmd>Trouble lsp_definitions<cr>', 'Definitions'},
--   d = {'<cmd>Trouble lsp_document_diagnostics<cr>', 'Diagnostics'},
--   q = {'<cmd>Trouble quickfix<cr>', 'QuickFix'},
--   l = {'<cmd>Trouble loclist<cr>', 'LocationList'},
--   w = {'<cmd>Trouble lsp_workspace_diagnostics<cr>', 'Diagnostics'}
-- }
