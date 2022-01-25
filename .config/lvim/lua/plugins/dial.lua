local dial = require 'dial'
vim.cmd [[
    nmap <C-a> <Plug>(dial-increment)
      nmap <C-x> <Plug>(dial-decrement)
      vmap <C-a> <Plug>(dial-increment)
      vmap <C-x> <Plug>(dial-decrement)
      vmap g<C-a> <Plug>(dial-increment-additional)
      vmap g<C-x> <Plug>(dial-decrement-additional)
    ]]

dial.augends['custom#boolean'] = dial.common.enum_cyclic {
  name = 'boolean',
  strlist = {'true', 'false'}
}
table.insert(dial.config.searchlist.normal, 'custom#boolean')

-- For Languages which prefer True/False, e.g. python.
dial.augends['custom#Boolean'] = dial.common.enum_cyclic {
  name = 'Boolean',
  strlist = {'True', 'False'}
}
table.insert(dial.config.searchlist.normal, 'custom#Boolean')

dial.augends['custom#directions'] = dial.common.enum_cyclic {
  name = 'directions',
  strlist = {'left', 'right', 'top', 'bottom'}
}
table.insert(dial.config.searchlist.normal, 'custom#directions')

dial.augends['custom#yesno'] = dial.common.enum_cyclic {
  name = 'yesno',
  strlist = {'yes', 'no'}
}
table.insert(dial.config.searchlist.normal, 'custom#yesno')

dial.augends['custom#YesNo'] = dial.common.enum_cyclic {
  name = 'YesNo',
  strlist = {'Yes', 'No'}
}
table.insert(dial.config.searchlist.normal, 'custom#YesNo')
