-- keymappings [view all the defaults by pressing <leader>Lk]
lvim.leader = 'space'
-- add your own keymapping
lvim.keys.normal_mode['<C-s>'] = ':w<cr>'
-- unmap a default keymapping
-- lvim.keys.normal_mode["<C-Up>"] = ""
-- edit a default keymapping
-- lvim.keys.normal_mode["<C-q>"] = ":q<cr>"

-- Change Telescope navigation to use j and k for navigation and n and p for history in both input and normal mode.
-- we use protected-mode (pcall) just in case the plugin wasn't loaded yet.
-- local _, actions = pcall(require, "telescope.actions")
-- lvim.builtin.telescope.defaults.mappings = {
--   -- for input mode
--   i = {
--     ["<C-j>"] = actions.move_selection_next,
--     ["<C-k>"] = actions.move_selection_previous,
--     ["<C-n>"] = actions.cycle_history_next,
--     ["<C-p>"] = actions.cycle_history_prev,
--   },
--   -- for normal mode
--   n = {
--     ["<C-j>"] = actions.move_selection_next,
--     ["<C-k>"] = actions.move_selection_previous,
--   },
-- }

-- use the default vim behavior for H and L
lvim.keys.normal_mode['<S-l>'] = nil
lvim.keys.normal_mode['<S-h>'] = nil

-- When text is wrapped, move by terminal rows, not lines, unless a count is provided
vim.api.nvim_set_keymap('n', 'j', '(v:count == 0 ? "gj" : "j")',
                        {noremap = true, expr = true, silent = true})
vim.api.nvim_set_keymap('n', 'k', '(v:count == 0 ? "gk" : "k")',
                        {noremap = true, expr = true, silent = true})

-- move around *visually*

-- make Y consistent with other capitals
lvim.keys.normal_mode['Y'] = 'y$'

-- easy align
lvim.keys.normal_mode['ga'] = ':EasyAlign<CR>'
lvim.keys.visual_mode['ga'] = ':EasyAlign<CR>'

-- Maintain the cursor position when yanking a visual selection
-- http://ddrscott.github.io/blog/2016/yank-without-jank/
lvim.keys.visual_mode['y'] = 'myy`y'
lvim.keys.visual_mode['Y'] = ' myY`y'

-- make . to work with visually selected lines
lvim.keys.visual_mode['.'] = ':normal . <CR>'

-- insert mode mappings
lvim.keys.insert_mode['<C-a>'] = '<C-o>^'
lvim.keys.insert_mode['<C-e>'] = '<C-o>$'
lvim.keys.insert_mode['<C-f>'] = '<C-o>w'
lvim.keys.insert_mode['<C-b>'] = '<C-o>b'
lvim.keys.insert_mode['<C-k>'] = '<C-o>d$'
lvim.keys.insert_mode['<C-u>'] = '<C-o>d^'
lvim.keys.insert_mode['<C-s>'] = '<c-g>u<Esc>[s1z=`]a<c-g>u'
