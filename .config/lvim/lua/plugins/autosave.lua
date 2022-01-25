require('autosave').setup({
  enabled = vim.g.auto_save,
  -- execution_message = 'autosaved at : ' .. vim.fn.strftime('%H:%M:%S'),
  -- events = {'InsertLeave', 'TextChanged'},
  -- conditions = {exists = true, filetype_is_not = {}, modifiable = true},
  write_all_buffers = true,
  on_off_commands = true,
  clean_command_line_interval = 2500
})
