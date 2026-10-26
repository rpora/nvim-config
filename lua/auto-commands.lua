-- Remove auto comment on new line below a comment
local format_group = vim.api.nvim_create_augroup("FormatOptions", { clear = true })
vim.api.nvim_create_autocmd("FileType", {
  group = format_group,
  callback = function()
    vim.opt_local.formatoptions:remove("cro")
  end,
})

-- Highlight on yank
local yank_group = vim.api.nvim_create_augroup("YankHighlight", { clear = true })
vim.api.nvim_create_autocmd("TextYankPost", {
  group = yank_group,
  callback = function()
    vim.hl.on_yank({ timeout = 300 })
  end,
})

-- Restore last cursor position when reopening a file
local last_cursor_group = vim.api.nvim_create_augroup("LastCursor", { clear = true })
vim.api.nvim_create_autocmd("BufReadPost", {
  group = last_cursor_group,
  callback = function()
    local mark = vim.api.nvim_buf_get_mark(0, '"')
    local lcount = vim.api.nvim_buf_line_count(0)
    if mark[1] > 0 and mark[1] <= lcount then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

-- Highlight the symbol under the cursor in the document, in buffers whose LSP supports it
local document_highlight_group = vim.api.nvim_create_augroup("LspDocumentHighlight", { clear = true })
vim.api.nvim_create_autocmd("LspAttach", {
  group = document_highlight_group,
  callback = function(event)
    local client = vim.lsp.get_client_by_id(event.data.client_id)
    if not (client and client:supports_method("textDocument/documentHighlight", event.buf)) then
      return
    end

    vim.api.nvim_clear_autocmds({ group = document_highlight_group, buffer = event.buf })
    vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
      group = document_highlight_group,
      buffer = event.buf,
      callback = vim.lsp.buf.document_highlight,
    })
    vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
      group = document_highlight_group,
      buffer = event.buf,
      callback = vim.lsp.buf.clear_references,
    })
  end,
})
