return {
  {
    "gregorias/nvim-mapper",
    dependencies = "nvim-telescope/telescope.nvim",
    config = function() require"nvim-mapper".setup{} end,
  },
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
    lazy = false,
    config = function()
      local conf = {
        -- default_command_agent = "ChatOllamaLlama3.1-8B",
        -- default_chat_agent = "ChatOllamaLlama3.1-8B",
        -- agents = {
          -- {
          --   name = "ChatGPT-o3-mini",
          --   disable=true
          -- },
          -- {
          --   provider = "ollama",
          --   name = "ChatOllamaLlama3.1-8B",
          --   chat = true,
          --   -- string with model name or table with model name and parameters
          --   model = {
          --     model = "llama3.1:8b",
          --     temperature = 0,
          --     top_p = 1,
          --     min_p = 0.05,
          --   },
          --   -- system prompt (use this to specify the persona/role of the AI)
          --   system_prompt = "You are a Senior Software Engineer.",
          -- }
        -- },
        -- For customization, refer to Install > Configuration in the Documentation/Readme
        providers = { 
          ollama = {
            endpoint = "http://localhost:11434/v1/chat/completions",
            secret ="dummy"
          },
          openai = {
      			endpoint = "https://openai.com/v1/chat/completions",
		      	secret = os.getenv("OPENAI_API_KEY"),
		      },
        }
      }
      require("gp").setup(conf)

      -- Setup shortcuts here (see Usage > Shortcuts in the Documentation/Readme)
    end,
  },
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
