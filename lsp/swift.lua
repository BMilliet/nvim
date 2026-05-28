local function find_root(bufnr, on_dir)
    local filename = vim.api.nvim_buf_get_name(bufnr)
    local start = vim.fs.dirname(filename)

    if not start then
        return
    end

    local function find_marker(markers)
        local matches = vim.fs.find(function(name)
            for _, marker in ipairs(markers) do
                if marker == "*.xcodeproj" and name:match("%.xcodeproj$") then
                    return true
                end

                if marker == "*.xcworkspace" and name:match("%.xcworkspace$") then
                    return true
                end

                if name == marker then
                    return true
                end
            end

            return false
        end, { path = start, upward = true, limit = 1 })

        return matches[1] and vim.fs.dirname(matches[1]) or nil
    end

    local root = find_marker({ "buildServer.json", ".bsp" })
        or find_marker({ "*.xcodeproj", "*.xcworkspace" })
        or find_marker({ "compile_commands.json", "Package.swift" })
        or find_marker({ ".git" })
        or start

    on_dir(root)
end

return {
    cmd = { "xcrun", "sourcekit-lsp" },
    filetypes = { "swift" },
    root_dir = find_root,
    capabilities = {
        workspace = {
            didChangeWatchedFiles = {
                dynamicRegistration = true,
            },
        },
        textDocument = {
            diagnostic = {
                dynamicRegistration = true,
                relatedDocumentSupport = true,
            },
        },
    },
}
