-- ┌────────────────────────┐
-- │ TypeScript LSP config  │
-- └────────────────────────┘
--
-- This file contains configuration of 'ts_ls' language server.
-- Source: https://github.com/typescript-language-server/typescript-language-server
--
-- It is used by `:h vim.lsp.enable()` and `:h vim.lsp.config()`.
-- See `:h vim.lsp.Config` and `:h vim.lsp.ClientConfig` for all available fields.
return {
	on_attach = function(client, buf_id)
		-- Formatting is handled by 'conform.nvim' (prettier), not tsserver
		client.server_capabilities.documentFormattingProvider = false
		client.server_capabilities.documentRangeFormattingProvider = false
	end,
}
