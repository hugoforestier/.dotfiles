return {
  {
  }
}
-- return {
--   {
--     enabled = true,
--     "yetone/avante.nvim",
--     build = "make",
--     dependencies = {
--       "stevearc/dressing.nvim",
--       "nvim-lua/plenary.nvim",
--       "zbirenbaum/copilot.lua",
--       "MunifTanjim/nui.nvim",
--       "nvim-tree/nvim-web-devicons", -- or echasnovski/mini.icons
--       -- {
--       --   "MeanderingProgrammer/render-markdown.nvim",
--       --   opts = { file_types = { "Avante", "markdown" } },
--       --   ft = { "Avante", "markdown" },
--       -- },
--     },
--     config = function()
--       require("avante").setup {
--         provider = "copilot",
--         providers = {
--           copilot = {
--             model = 'gpt-4o',
--             -- model = "claude-sonnet-4.5",
--             timeout = 30000,
--             extra_request_body = {
--               max_tokens = 20480,
--             }
--           },
--         },
--         custom_tools = {},
--         hints = { enabled = false },
--         acp_providers = {
--           ["opencode"] = {
--             command = "opencode",
--             args = { "acp" }
--           }
--         }
--       }
--     end,
--   },
-- }

