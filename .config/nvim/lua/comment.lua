-- Functional wrapper for mapping custom keybindings
-- function map(mode, lhs, rhs, opts)
    -- local options = { noremap = true }
    -- if opts then
        -- options = vim.tbl_extend("force", options, opts)
    -- end
    -- vim.api.nvim_set_keymap(mode, lhs, rhs, options)
-- end

require('Comment').setup({
 toggler = {
     line = '<leader>c',
     block = '<leader>C'
 },
 opleader = {
     line = '<leader>c',
     block = '<leader>C'
 }
})

-- function _G.__toggle_contextual(vmode)
 -- local cfg = A.get_config()
 -- local range = U.get_region(vmode)
 -- local same_line = range.srow == range.erow
 -- local ctx = {
     -- cmode = U.cmode.toggle,
     -- range = range,
     -- cmotion = U.cmotion[vmode] or U.cmotion.line,
     -- ctype = same_line and U.ctype.line or U.ctype.block,
 -- }
 -- local lcs, rcs = U.parse_cstr(cfg, ctx)
 -- local lines = U.get_lines(range)

 -- local params = {
     -- range = range,
     -- lines = lines,
     -- cfg = cfg,
     -- cmode = ctx.cmode,
     -- lcs = lcs,
     -- rcs = rcs,
 -- }
 -- if same_line then
     -- Op.linewise(params)
 -- else
     -- Op.blockwise(params)
 -- end
-- end

-- map('n', '<Leader>c', '<cmd>set operatorfunc=v:lua.__toggle_contextual<CR>g@')
-- map('x', '<Leader>c', '<cmd>set operatorfunc=v:lua.__toggle_contextual<CR>g@')
