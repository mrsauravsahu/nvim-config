return {
  {
    "stevearc/conform.nvim",
    -- event = 'BufWritePre', -- uncomment for format on save
    opts = require "configs.conform",
  },

  -- These are some examples, uncomment them if you want to see them work!
  {
    "neovim/nvim-lspconfig",
    config = function()
      require "configs.lspconfig"
    end,
  },

  {
    "nvim-tree/nvim-tree.lua",
    config = function()
      require("nvim-tree").setup({
        hijack_directories = { auto_open = true }, 
        view = {
          side = "right"
        },
        git = {
          enable = true,
          ignore = false, -- show git ignored files
        },
        filters = {
          dotfiles = false, -- optional: show dotfiles too
        },
      })
    end,
  },
  {
      "robitx/gp.nvim",
      config = function()
          local conf = {
              -- For customization, refer to Install > Configuration in the Documentation/Readme
          }
          require("gp").setup(conf)

          -- Setup shortcuts here (see Usage > Shortcuts in the Documentation/Readme)
      end,
  }
  -- test new blink
  -- { import = "nvchad.blink.lazyspec" },

  -- {
  -- 	"nvim-treesitter/nvim-treesitter",
  -- 	opts = {
  -- 		ensure_installed = {
  -- 			"vim", "lua", "vimdoc",
  --      "html", "css"
  -- 		},
  -- 	},
  -- },
}
