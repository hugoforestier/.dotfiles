return {
  {
    enabled = true,
    "yetone/avante.nvim",
    build = "make",
    dependencies = {
      "stevearc/dressing.nvim",
      "nvim-lua/plenary.nvim",
      "zbirenbaum/copilot.lua",
      "MunifTanjim/nui.nvim",
      "nvim-tree/nvim-web-devicons", -- or echasnovski/mini.icons
      -- {
      --   "MeanderingProgrammer/render-markdown.nvim",
      --   opts = { file_types = { "Avante", "markdown" } },
      --   ft = { "Avante", "markdown" },
      -- },
    },
    config = function()
      require("avante").setup {
        provider = "copilot",
        providers = {
          copilot = {
            model = "claude-sonnet-4.5",
            --endpoint = "https://api.anthropic.com",
            --timeout = 30000, -- Timeout in milliseconds
            --temperature = 0,
            --max_tokens = 4096,
            --disable_tools = true,
          },
        },
        custom_tools = {},
        hints = { enabled = false },
      }
    end,
  },
}

