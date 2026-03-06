return {
  {
    "lewis6991/gitsigns.nvim",
    lazy = false,
    config = function()
      require('gitsigns').setup({
        current_line_blame = true,
      })
    end
  },
  {
    "mrsauravsahu/model-cmp.nvim",
    branch = "tmp/local-stuff",
    lazy = false,
    -- cmd = {"ModelCmp"},
    config = function()
      require("model_cmp").setup({
        requests = {
          delay_ms = 1000,
          max_retries = 5,
          timeout_ms = 300000,
        },
        api = {
          apikeys = {
            GEMINI_API_KEY = ""
          },
          custom_url = {
            url = "http://127.0.0.1",
            port = "9000"
          }
        },
        virtualtext = {
          enable = true,
          type = "inline",
          style = { -- This is just a highlight group
            fg = "#b53a3a",
            italic = false,
            bold = false
          }
        },
      })
    end,
  },
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
          { disable = true, name = "ChatGPT4o" },
          { disable = true, name = "ChatGPT4o-mini" },
          { disable = true, name = "ChatGPT-o3-mini" },
          { disable = true, name = "ChatCopilot" },
          { disable = true, name = "ChatGemini" },
          { disable = true, name = "ChatPerplexityLlama3.1-8B" },
          { disable = true, name = "ChatClaude-3-7-Sonnet" },
          { disable = true, name = "ChatClaude-Sonnet-4-Thinking" },
          { disable = true, name = "ChatClaude-3-5-Haiku" },
          { disable = true, name = "ChatOllamaLlama3.1-8B" },
          { disable = true, name = "ChatQwen3-8B" },
          { disable = true, name = "ChatLMStudio" },
          { disable = true, name = "CodeGPT4o" },
          { disable = true, name = "CodeGPT-o3-mini" },
          { disable = true, name = "CodeGPT4o-mini" },
          { disable = true, name = "CodeCopilot" },
          { disable = true, name = "CodeGemini" },
          { disable = true, name = "CodePerplexityLlama3.1-8B" },
          { disable = true, name = "CodeClaude-3-7-Sonnet" },
          { disable = true, name = "CodeClaude-3-5-Haiku" },
          { disable = true, name = "CodeOllamaLlama3.1-8B" },
          {
            name = "gpt5nano",
            model = "gpt-5-nano-2025-08-07",
            provider = "openai",
            system_prompt = "You are a Senior Software Engineer.",
            chat = true,
            command = true,
          },
          -- {
          --   provider = "ollama",
          --   name = "ollama-qwen",
          --   chat = true,
          --   -- string with model name or table with model name and parameters
          --   model = {
          --     model = "qwen2.5-coder:latest",
          --     temperature = 0,
          --     top_p = 1,
          --     min_p = 0.05,
          --   },
          --   -- system prompt (use this to specify the persona/role of the AI)
          --   system_prompt = "You are a Senior Software Engineer.",
          -- },
          {
            provider = "ollama",
            name = "llama",
            chat = true,
            commmand = true,
            -- string with model name or table with model name and parameters
            model = {
              model = "llama3.2-vision:11b",
              temperature = 0,
              top_p = 1,
              min_p = 0.05,
            },
            -- system prompt (use this to specify the persona/role of the AI)
            system_prompt = "You are a Senior Software Engineer.",
          },
          {
            provider = "anthropic",
            name = "haiku",
            chat = true,
            command = true,
            -- string with model name or table with model name and parameters
            model = {
              model = "claude-haiku-4-5-20251001",
              temperature = 0,
              -- top_p = 1,
              -- min_p = 0.05,
            },
            -- system prompt (use this to specify the persona/role of the AI)
            system_prompt = "You are a Senior Software Engineer.",
          },
        },
        default_command_agent = "llama",
        default_chat_agent = "llama",
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
          anthropic = {
            endpoint = os.getenv('ANTHROPIC_API_HOST'),
            secret = os.getenv("ANTHROPIC_API_KEY"),
          },
        }
      }
      require("gp").setup(conf)
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
