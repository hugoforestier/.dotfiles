local nnoremap = require("acty.keymap").nnoremap
local inoremap = require("acty.keymap").inoremap
local xnoremap = require("acty.keymap").xnoremap

nnoremap("<leader>pv", "<cmd>:Ex<CR>")
xnoremap("<leader>p", "\"_dP")
inoremap("jj", "<Esc>")
