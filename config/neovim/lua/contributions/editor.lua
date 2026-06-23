---@meta

---@class vscode_editor_properties
---@field ["editor.tab_size"] integer 一个制表符占据的空格数
---@field ["editor.insert_spaces"] boolean 按 Tab 时是否转换为空格
---@field ["editor.line_numbers"] "on"|"off"|"relative" 行号显示模式
---@field ["editor.word_wrap"] "on"|"off" 是否自动折行

local contrib_base = require("core")

local editor = contrib_base:new({
    actions = {
        -- 格式化当前文本文件
        ["editor.action.format_document"] = {
            description = "Format: Standardize active text document layout",
            key = "<leader>f", -- 默认推荐物理按键
            callback = function()
                -- Fallback：优先采用当前缓冲区的原生 LSP 格式化，未连接 LSP 时降级为普通对齐
                if next(vim.lsp.get_clients({ bufnr = 0 })) ~= nil then
                    vim.lsp.buf.format({ async = true })
                else
                    vim.cmd("normal! gg=G")
                end
            end
        },

        -- 跳转到函数/变量定义声明处
        ["editor.action.go_to_definition"] = {
            description = "GoTo: Hop directly to code item declaration",
            key = "gd",
            callback = function()
                vim.lsp.buf.definition()
            end
        }
    },
    properties = {
        -- 属性解析器：将规范数据转换为 Neovim 内置全局 Options
        ["editor.font_size"] = function(val)
            if vim.o.guifont ~= "" then vim.o.guifont = string.format("Fira Code:h%d", val) end
        end,
        ["editor.tab_size"] = function(val)
            vim.opt.tabstop = val; vim.opt.shiftwidth = val
        end,
        ["editor.insert_spaces"] = function(val)
            vim.opt.expandtab = val
        end,
        ["editor.line_numbers"] = function(val)
            if val == "on" then
                vim.opt.number = true; vim.opt.relativenumber = false
            elseif val == "relative" then
                vim.opt.number = true; vim.opt.relativenumber = true
            else
                vim.opt.number = false; vim.opt.relativenumber = false
            end
        end,
        ["editor.word_wrap"] = function(val)
            vim.opt.wrap = (val == "on")
        end
    }
})

-- 多语言局部级联属性重写注册表
local lang_overrides_registry = {}

function m.register_language_props(file_type, props)
    lang_overrides_registry[file_type] = props
end

function editor.override_language_props(file_type, user_props)
    if not lang_overrides_registry[file_type] then lang_overrides_registry[file_type] = {} end
    for key, val in pairs(user_props) do lang_overrides_registry[file_type][key] = val end
end

-- 级联覆盖引擎：利用 FileType Autocmd 实现 Buffer 级别局部选项的无损遮蔽
function editor.init_cascading_engine()
    local gid = vim.api.nvim_create_augroup("vscode_editor_cascading_overrides", { clear = true })
    vim.api.nvim_create_autocmd("FileType", {
        group = gid,
        pattern = "*",
        callback = function()
            local current_ft = vim.bo.filetype
            local local_props = lang_overrides_registry[current_ft]
            if local_props then
                if local_props["editor.tab_size"] then
                    vim.bo.tabstop = local_props["editor.tab_size"]
                    vim.bo.shiftwidth = local_props["editor.tab_size"]
                end
                if local_props["editor.insert_spaces"] ~= nil then
                    vim.bo.expandtab = local_props["editor.insert_spaces"]
                end
            end
        end
    })
end

return editor
