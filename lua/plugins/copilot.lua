return {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    event = "InsertEnter",
    config = function()
        require("copilot").setup({
            suggestion = {
                enabled = false,
                auto_trigger = false,
                debounce = 75,
                keymap = {
                    accept = "<M-i>",
                    accept_word = false,
                    accept_line = false,
                    next = "<M-e>",
                    prev = "<M-n>",
                    dismiss = "<M-o>",
                },
            },
        })
    end,
}
