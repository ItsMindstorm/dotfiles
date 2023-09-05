vim.g.tex_flavor = "latex"
vim.opt.relativenumber = true
vim.opt.termguicolors = true
vim.keymap.set("n", "<leader>sp", ":set spell<CR> <bar> :set spelllang=en_gb<CR>")
vim.keymap.set("n", "<leader>vp", "<cmd> vsplit <CR>")
vim.keymap.set("n", "<leader>h", "<cmd> split <CR>")

vim.cmd([[
set backupdir=~/nvim/backup//
]])

if vim.g.neovide then
	vim.g.neovide_scale_factor = "1.0"
	vim.opt.guifont = { "JetBrains Mono NF", ":h15" }
end

local enable_providers = {
	"python3_provider",
}

for _, plugin in pairs(enable_providers) do
	vim.g["loaded_" .. plugin] = nil
	vim.cmd("runtime " .. plugin)
end
