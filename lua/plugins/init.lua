return {
  {
    "gregorias/nvim-mapper",
    dependencies = "nvim-telescope/telescope.nvim",
    config = function() require"nvim-mapper".setup{} end,
  },
  {
    "stevearc/conform.nvim",
    opts = require "configs.conform",
  },

  {
    "NvChad/nvterm",
    config = function()
      require("nvterm").setup({
      terminals = {
        shell = vim.o.shell,
        list = {},
        type_opts = {
          float = {
            relative = 'editor',
            row = 0.3,
            col = 0.25,
            width = 0.5,
            height = 0.4,
            border = "single",
          },
          horizontal = { location = "rightbelow", split_ratio = 1 },
          vertical = { location = "rightbelow", split_ratio = .5 },
        }
      },
      behavior = {
        autoclose_on_quit = {
          enabled = false,
          confirm = true,
        },
        close_on_exit = true,
        auto_insert = true,
      },
    })
    end,
  },
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
      agents = {
        {
          name = "ChatGPT-o3-mini",
          disable = true
        },
        {
          name = "gpt5",
          model = "gpt-5-nano-2025-08-07",
          provider = "openai",
          system_prompt = "You are a Senior Software Engineer.",
          chat = true,
          command = true,
        },
        {
          provider = "ollama",
          name = "ollama-qwen",
          chat = true,
          -- string with model name or table with model name and parameters
          model = {
            model = "qwen2.5-coder:latest",
            temperature = 0,
            top_p = 1,
            min_p = 0.05,
          },
          -- system prompt (use this to specify the persona/role of the AI)
          system_prompt = "You are a Senior Software Engineer.",
          },
          {
            provider = "ollama",
            name = "ollama-llama",
            chat = true,
            -- string with model name or table with model name and parameters
            model = {
              model = "llama3.1:8b",
              temperature = 0,
              top_p = 1,
              min_p = 0.05,
            },
            -- system prompt (use this to specify the persona/role of the AI)
            system_prompt = "You are a Senior Software Engineer.",
          }
      },
        default_command_agent = "ollama-llama",
        default_chat_agent = "ollama-llama",
        -- },
        -- For customization, refer to Install > Configuration in the Documentation/Readme
        providers = {
          ollama = {
            endpoint = "http://localhost:11434/api/chat",
            secret = "dummy"
          },
          openai = {
            endpoint = os.getenv("OPENAI_API_HOST"),
            secret = os.getenv("OPENAI_API_KEY"),
          },
        }
      }
      require("gp").setup(conf)

      -- Setup shortcuts here (see Usage > Shortcuts in the Documentation/Readme)
    end,
  },
  {
    "rmagatti/auto-session",
    lazy = false,

    ---enables autocomplete for opts
    ---@module "auto-session"
    ---@type AutoSession.Config
    opts = {
      suppressed_dirs = { "~/", "~/Projects", "~/Downloads", "/" },
      -- log_level = 'debug',
    },
  },
  {
  	"nvim-treesitter/nvim-treesitter",
  	opts = {
  		ensure_installed = {
        "vim",
        "lua",
        "vimdoc",
        "html",
        "css"
  		},
  	},
  },
  -- test new blink
  -- { import = "nvchad.blink.lazyspec" },
}
