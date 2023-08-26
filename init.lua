vim.g.coq_settings = {
 -- auto_start = 'shut-up',
  keymap = {
    recommended = true,
  },
  clients = {
    paths = {
      path_seps = {
        "/"
      }
    },
    buffers = {
      match_syms = false,
      enabled = false
    }
  },
  display = {
    ghost_text = {
      enabled = true
    }
  },

}

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

vim.g.mapleader = " " -- Make sure to set `mapleader` before lazy so your mappings are correct

require("lazy").setup({
    "folke/tokyonight.nvim",
    { "nvim-treesitter/nvim-treesitter", build = ":TSUpdate"},
    {
    'nvim-telescope/telescope.nvim', tag = '0.1.2',
      dependencies = { 'nvim-lua/plenary.nvim' }
    },
    "neovim/nvim-lspconfig",
    { "ms-jpq/coq_nvim", branch = "coq" },
    { "ms-jpq/coq.artifacts", branch = "artifacts" },
    { "ms-jpq/coq.thirdparty", branch = "3p" },
    { "folke/neodev.nvim", opts = {} },
    {
        'windwp/nvim-autopairs',
        event = "InsertEnter",
        opts = {} -- this is equalent to setup({}) function
    },
    "simrat39/rust-tools.nvim",
    { "nvim-lualine/lualine.nvim", opts = {} },
    "mg979/vim-visual-multi",
    "williamboman/mason.nvim",
    "williamboman/mason-lspconfig.nvim",
    "spaceduck-theme/nvim",
    "neovim/nvim-lspconfig",
    "hrsh7th/cmp-nvim-lsp",
    "hrsh7th/cmp-buffer",
    "hrsh7th/cmp-path",
    "hrsh7th/cmp-cmdline",
    "hrsh7th/nvim-cmp",
    "L3MON4D3/LuaSnip",
    "saadparwaiz1/cmp_luasnip"
})

require("nvim-treesitter.configs").setup({
  sync_install = false,
  auto_install = true,
  highlight = {
    enable = true,
    additional_vim_regex_highlighting = false,
  },
})

require("tokyonight").setup({
    transparent = true,
    terminal_colors = true,
})



local remap = vim.api.nvim_set_keymap
local npairs = require('nvim-autopairs')

npairs.setup({ map_bs = false, map_cr = false })

vim.g.coq_settings = { keymap = { recommended = false, pre_select = true }, completion = {
    skip_after = {"{", "}", "[", "]", "(", ")", ";", ":"}
}, display = { pum = { fast_close = true, y_max_len = 4 }, preview = { enabled = false } }, clients = { buffers = { enabled = false } }
}

-- these mappings are coq recommended mappings unrelated to nvim-autopairs
-- remap('i', '<esc>', [[pumvisible() ? "<c-e><esc>" : "<esc>"]], { expr = true, noremap = true })
-- remap('i', '<c-c>', [[pumvisible() ? "<c-e><c-c>" : "<c-c>"]], { expr = true, noremap = true })
-- remap('i', '<tab>', [[pumvisible() ? "<c-n>" : "<tab>"]], { expr = true, noremap = true })
-- remap('i', '<s-tab>', [[pumvisible() ? "<c-p>" : "<bs>"]], { expr = true, noremap = true })

-- skip it, if you use another global object
-- _G.MUtils= {}

-- MUtils.CR = function()
--   if vim.fn.pumvisible() ~= 0 then
--    if vim.fn.complete_info({ 'selected' }).selected ~= -1 then
--      return npairs.esc('<c-y>')
--   else
--      return npairs.esc('<c-e>') .. npairs.autopairs_cr()
--    end
--  else
--    return npairs.autopairs_cr()
--  end
--end
--remap('i', '<cr>', 'v:lua.MUtils.CR()', { expr = true, noremap = true })

--MUtils.BS = function()
 -- if vim.fn.pumvisible() ~= 0 and vim.fn.complete_info({ 'mode' }).mode == 'eval' then
 --   return npairs.esc('<c-e>') .. npairs.autopairs_bs()
--  else
--    return npairs.autopairs_bs()
--  end
--end
--remap('i', '<bs>', 'v:lua.MUtils.BS()', { expr = true, noremap = true })

require("mason").setup()
require("mason-lspconfig").setup()

local cmp = require'cmp'

local capabilities = require("cmp_nvim_lsp").default_capabilities()

local lsp = require("lspconfig")
local coq = require("coq")


local luasnip = require("luasnip")


cmp.setup({
	snippet = {
		-- REQUIRED - you must specify a snippet engine
		expand = function(args)
			luasnip.lsp_expand(args.body) -- For `luasnip` users.
			-- require('snippy').expand_snippet(args.body) -- For `snippy` users.
			-- vim.fn["UltiSnips#Anon"](args.body) -- For `ultisnips` users.
		end,
	},
	window = {
		-- completion = cmp.config.window.bordered(),
		-- documentation = cmp.config.window.bordered(),
	},
	mapping = cmp.mapping.preset.insert({
		['<C-b>'] = cmp.mapping.scroll_docs(-4),
		['<C-f>'] = cmp.mapping.scroll_docs(4),
		['<C-Space>'] = cmp.mapping.complete(),
		['<C-e>'] = cmp.mapping.abort(),
		['<CR>'] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
	}),
	sources = cmp.config.sources({
		{ name = 'nvim_lsp' },
		-- { name = 'vsnip' }, -- For vsnip users.
		{ name = 'luasnip' }, -- For luasnip users.
		-- { name = 'ultisnips' }, -- For ultisnips users.
		-- { name = 'snippy' }, -- For snippy users.
	}, {
		{ name = 'buffer' },
	}),

    experimental = {
        ghost_text = function()
        end
    }

})

-- Set configuration for specific filetype.
cmp.setup.filetype('gitcommit', {
	sources = cmp.config.sources({
		{ name = 'git' }, -- You can specify the `git` source if [you were installed it](https://github.com/petertriho/cmp-git).
	}, {
		{ name = 'buffer' },
	})
})

-- Use buffer source for `/` and `?` (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline({ '/', '?' }, {
	mapping = cmp.mapping.preset.cmdline(),
	sources = {
		{ name = 'buffer' }
	}
})

-- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline(':', {
	mapping = cmp.mapping.preset.cmdline(),
	sources = cmp.config.sources({
		{ name = 'path' }
	}, {
		{ name = 'cmdline' }
	})
})


--require("coq_3p") {
--    { src = "nvimlua", short_name = "nLUA", conf_only = false },
--}


-- lsp.lua_ls.setup(coq.lsp_ensure_capabilities({
--   settings = {
--     Lua = {
--       completion = {
--         callSnippet = "Replace"
--       }
--     }
--   }
-- }))

-- lsp.clangd.setup(coq.lsp_ensure_capabilities({}))
-- lsp.tsserver.setup(coq.lsp_ensure_capabilities({}))
-- lsp.svelte.setup(coq.lsp_ensure_capabilities({}))
-- lsp.cssls.setup(coq.lsp_ensure_capabilities({}))
-- lsp.tailwindcss.setup(coq.lsp_ensure_capabilities({}))
-- lsp.html.setup(coq.lsp_ensure_capabilities({}))

local get_servers = require("mason-lspconfig").get_installed_servers

for _, server_name in ipairs(get_servers()) do
    lsp[server_name].setup({
        capabilities = capabilities
    })
end

require("rust-tools").setup({})

local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>f', builtin.find_files, {})
vim.keymap.set('n', '<leader>sg', builtin.live_grep, {})

vim.keymap.set('n', '<space>e', vim.diagnostic.open_float)
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev)
vim.keymap.set('n', ']d', vim.diagnostic.goto_next)
vim.keymap.set('n', '<space>q', vim.diagnostic.setloclist)

vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('UserLspConfig', {}),
  callback = function(ev)
    -- Enable completion triggered by <c-x><c-o>
    vim.bo[ev.buf].omnifunc = 'v:lua.vim.lsp.omnifunc'

    -- Buffer local mappings.
    -- See `:help vim.lsp.*` for documentation on any of the below functions
    local opts = { buffer = ev.buf }
    vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
    vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
    vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
    vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
    vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, opts)
    vim.keymap.set('n', '<space>wa', vim.lsp.buf.add_workspace_folder, opts)
    vim.keymap.set('n', '<space>wr', vim.lsp.buf.remove_workspace_folder, opts)
    vim.keymap.set('n', '<space>wl', function()
      print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
    end, opts)
    vim.keymap.set('n', '<space>D', vim.lsp.buf.type_definition, opts)
    vim.keymap.set('n', '<space>rn', vim.lsp.buf.rename, opts)
    vim.keymap.set({ 'n', 'v' }, '<space>ca', vim.lsp.buf.code_action, opts)
    vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
  end,
})

vim.keymap.set("v", "J", ":m '>+1<cr>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<cr>gv=gv")
vim.keymap.set("n", "<space>c", ":bd<cr>", {silent = true})

vim.keymap.set({"i", "s"}, "<C-L>", function() luasnip.jump( 1) end, {silent = true})
vim.keymap.set({"i", "s"}, "<C-J>", function() luasnip.jump(-1) end, {silent = true})


local fontsize = 24
vim.keymap.set({"n"}, "<leader>+", function()
    fontsize = fontsize + 4
    vim.opt.guifont = "Monocraft:h" .. fontsize
end)

vim.keymap.set({"n"}, "<leader>-", function()
    fontsize = fontsize - 4
    vim.opt.guifont = "Monocraft:h" .. fontsize
end)

vim.opt.termguicolors = true
vim.cmd.colorscheme("tokyonight")
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.signcolumn = "yes"
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.hlsearch = false
vim.opt.incsearch = true
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undodir = os.getenv("HOME") .. "/.zvim/undodir"
vim.opt.undofile = true
vim.opt.scrolloff = 8
vim.opt.wrap = false
vim.opt.pumheight = 5

vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
vim.api.nvim_set_hl(0, "FloatBorder", { bg = "none" })
vim.api.nvim_set_hl(0, "TelescopeNormal", { bg = "none" })
vim.api.nvim_set_hl(0, "TelescopeBorder", { bg = "none" })
vim.api.nvim_set_hl(0, "Pmenu", { bg = "none" })


if vim.g.neovide then
    vim.g.neovide_refresh_rate = 144
    vim.opt.guifont = "Monocraft:h" .. fontsize
end
