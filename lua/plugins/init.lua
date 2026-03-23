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
          {
            provider = "ollama",
            name = "qwen3-5",
            chat = true,
            commmand = true,
            model = {
              model = "qwen3.5",
            },
            system_prompt = "You are a Senior Software Engineer.",
          },
          {
            provider = "ollama",
            name = "llama",
            chat = true,
            commmand = true,
            model = {
              model = "llama3.1",
              temperature = 0,
            },
            system_prompt = "You are a Senior Software Engineer.",
          },
          {
            provider = "anthropic",
            name = "haiku",
            chat = true,
            command = true,
            model = {
              model = "claude-haiku-4-5-20251001",
              temperature = 0,
            },
            system_prompt = "You are a Senior Software Engineer.",
          },
          -- { disable = true, name = "ChatGPT4o" },
          -- { disable = true, name = "ChatGPT4o-mini" },
          -- { disable = true, name = "ChatGPT-o3-mini" },
          -- { disable = true, name = "ChatCopilot" },
          -- { disable = true, name = "ChatGemini" },
          -- { disable = true, name = "ChatPerplexityLlama3.1-8B" },
          -- { disable = true, name = "ChatClaude-3-7-Sonnet" },
          -- { disable = true, name = "ChatClaude-Sonnet-4-Thinking" },
          -- { disable = true, name = "ChatClaude-3-5-Haiku" },
          -- { disable = true, name = "ChatOllamaLlama3.1-8B" },
          -- -- { disable = true, name = "ChatQwen3-8B" },
          -- { disable = true, name = "ChatLMStudio" },
          -- { disable = true, name = "CodeGPT4o" },
          -- { disable = true, name = "CodeGPT-o3-mini" },
          -- { disable = true, name = "CodeGPT4o-mini" },
          -- { disable = true, name = "CodeCopilot" },
          -- { disable = true, name = "CodeGemini" },
          -- { disable = true, name = "CodePerplexityLlama3.1-8B" },
          -- { disable = true, name = "CodeClaude-3-7-Sonnet" },
          -- { disable = true, name = "CodeClaude-3-5-Haiku" },
          -- {
          --   name = "gpt5nano",
          --   model = "gpt-5-nano-2025-08-07",
          --   provider = "openai",
          --   system_prompt = "You are a Senior Software Engineer.",
          --   chat = true,
          --   command = true,
          -- },
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
        },
        default_command_agent = "qwen3.5",
        default_chat_agent = "qwen3.5",
        providers = {
          ollama = {
            endpoint = "http://localhost:11434/api/chat",
            secret = "dummy_secret_123456789"
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
  "nickjvandyke/opencode.nvim",
  version = "*", -- Latest stable release
  dependencies = {
    {
      -- `snacks.nvim` integration is recommended, but optional
      ---@module "snacks" <- Loads `snacks.nvim` types for configuration intellisense
      "folke/snacks.nvim",
      optional = true,
      opts = {
        input = {}, -- Enhances `ask()`
        picker = { -- Enhances `select()`
          actions = {
            opencode_send = function(...) return require("opencode").snacks_picker_send(...) end,
          },
          win = {
            input = {
              keys = {
                ["<a-a>"] = { "opencode_send", mode = { "n", "i" } },
              },
            },
          },
        },
      },
    },
  },
    config = function()
      ---@type opencode.Opts
      vim.g.opencode_opts = {
        -- Your configuration, if any; goto definition on the type or field for details
      }

      vim.o.autoread = true -- Required for `opts.events.reload`

      -- Recommended/example keymaps
      vim.keymap.set({ "n", "x" }, "<C-a>", function() require("opencode").ask("@this: ", { submit = true }) end, { desc = "Ask opencode…" })
      vim.keymap.set({ "n", "x" }, "<C-x>", function() require("opencode").select() end,                          { desc = "Execute opencode action…" })
      vim.keymap.set({ "n", "t" }, "<C-.>", function() require("opencode").toggle() end,                          { desc = "Toggle opencode" })

      vim.keymap.set({ "n", "x" }, "go",  function() return require("opencode").operator("@this ") end,        { desc = "Add range to opencode", expr = true })
      vim.keymap.set("n",          "goo", function() return require("opencode").operator("@this ") .. "_" end, { desc = "Add line to opencode", expr = true })

      vim.keymap.set("n", "<S-C-u>", function() require("opencode").command("session.half.page.up") end,   { desc = "Scroll opencode up" })
      vim.keymap.set("n", "<S-C-d>", function() require("opencode").command("session.half.page.down") end, { desc = "Scroll opencode down" })

      -- You may want these if you use the opinionated `<C-a>` and `<C-x>` keymaps above — otherwise consider `<leader>o…` (and remove terminal mode from the `toggle` keymap)
      vim.keymap.set("n", "+", "<C-a>", { desc = "Increment under cursor", noremap = true })
      vim.keymap.set("n", "-", "<C-x>", { desc = "Decrement under cursor", noremap = true })
    end,
  },
  {
		"ThePrimeagen/99",
		config = function()
			local _99 = require("99")

            -- For logging that is to a file if you wish to trace through requests
            -- for reporting bugs, i would not rely on this, but instead the provided
            -- logging mechanisms within 99.  This is for more debugging purposes
            local cwd = vim.uv.cwd()
            local basename = vim.fs.basename(cwd)
      -- TODO: can i do easy switch
			_99.setup({
                -- provider = _99.Providers.ClaudeCodeProvider,  -- default: OpenCodeProvider
        provider = _99.Providers.OpenCodeProvider,
        -- provider = _99.Providers.ClaudeCodeProvider,
        model = "qwen3.5",
				logger = {
					level = _99.DEBUG,
					path = "/tmp/" .. basename .. ".99.debug",
					print_on_error = true,
				},
                -- When setting this to something that is not inside the CWD tools
                -- such as claude code or opencode will have permission issues
                -- and generation will fail refer to tool documentation to resolve
                -- https://opencode.ai/docs/permissions/#external-directories
                -- https://code.claude.com/docs/en/permissions#read-and-edit
                tmp_dir = "./tmp",

                --- Completions: #rules and @files in the prompt buffer
                completion = {
                    -- I am going to disable these until i understand the
                    -- problem better.  Inside of cursor rules there is also
                    -- application rules, which means i need to apply these
                    -- differently
                    -- cursor_rules = "<custom path to cursor rules>"

                    --- A list of folders where you have your own SKILL.md
                    --- Expected format:
                    --- /path/to/dir/<skill_name>/SKILL.md
                    ---
                    --- Example:
                    --- Input Path:
                    --- "scratch/custom_rules/"
                    ---
                    --- Output Rules:
                    --- {path = "scratch/custom_rules/vim/SKILL.md", name = "vim"},
                    --- ... the other rules in that dir ...
                    ---
                    custom_rules = {
                      "scratch/custom_rules/",
                    },

                    --- Configure @file completion (all fields optional, sensible defaults)
                    files = {
                        -- enabled = true,
                        -- max_file_size = 102400,     -- bytes, skip files larger than this
                        -- max_files = 5000,            -- cap on total discovered files
                        -- exclude = { ".env", ".env.*", "node_modules", ".git", ... },
                    },
                    --- File Discovery:
                    --- - In git repos: Uses `git ls-files` which automatically respects .gitignore
                    --- - Non-git repos: Falls back to filesystem scanning with manual excludes
                    --- - Both methods apply the configured `exclude` list on top of gitignore

                    --- What autocomplete engine to use. Defaults to native (built-in) if not specified.
                    source = "native", -- "native" (default), "cmp", or "blink"
                },

                --- WARNING: if you change cwd then this is likely broken
                --- ill likely fix this in a later change
                ---
                --- md_files is a list of files to look for and auto add based on the location
                --- of the originating request.  That means if you are at /foo/bar/baz.lua
                --- the system will automagically look for:
                --- /foo/bar/AGENT.md
                --- /foo/AGENT.md
                --- assuming that /foo is project root (based on cwd)
				md_files = {
					"AGENT.md",
				},
			})

            -- take extra note that i have visual selection only in v mode
            -- technically whatever your last visual selection is, will be used
            -- so i have this set to visual mode so i dont screw up and use an
            -- old visual selection
            --
            -- likely ill add a mode check and assert on required visual mode
            -- so just prepare for it now
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
