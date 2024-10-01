return {
  {
    "supermaven-inc/supermaven-nvim",
    config = function()
      require("supermaven-nvim").setup({})
    end,
  },
  {
    "David-Kunz/gen.nvim",
    opts = {
      model = "llama3.1", -- The default model to use.
      display_mode = "split", -- The display mode. Can be "float" or "split" or "horizontal-split".
      show_prompt = false, -- Shows the prompt submitted to Ollama.
      no_auto_close = true, -- Never closes the window automatically.
    },
  },
}
