---@meta

---@class vscode_files_properties
---@field ["files.auto_save"] "after_delay"|"on_window_change"|"off" 自动保存触发机制
---@field ["files.auto_save_delay"] integer 自动保存缓冲区等待延迟时间 (单位:毫秒)

local contrib_base = require("core")

local files = contrib_base:new({
    actions = {
        -- 保存当前已修改的缓冲区到硬盘
        ["files.action.save"] = {
            description = "File: Force synchronize current buffer modifications to storage",
            key = "<C-s>",
            callback = function()
                vim.cmd("silent! write")
            end
        },

        -- 执行自动化审查条件并引发隐式自动保存
        ["files.action.execute_auto_save"] = {
            description = "File: Run structural conditions audit to trigger implicit auto-save",
            callback = function()
                -- 严格条件防错拦截：只针对可写文件、非空文件、非虚拟弹窗(NvimTree等)进行静默写入
                if vim.bo.modifiable and vim.fn.empty(vim.fn.expand("%:t")) == 0 and vim.bo.buftype == "" then
                    vim.cmd("silent! write")
                end
            end
        }
    },
    properties = {
        -- 属性处理器：通过配置数据类型，在内部自动搭建并管理 Autocmd 拦截器网
        ["files.auto_save"] = function(val)
            local gid = vim.api.nvim_create_augroup("vscode_files_auto_save_group", { clear = true })

            if val == "after_delay" then
                -- 模式一：失去焦点、或者光标停止输入一段延迟时间后自动保存 (对应 CursorHold)
                vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI", "FocusLost" }, {
                    group = gid,
                    pattern = "*",
                    callback = function() m:execute("files.action.execute_auto_save")() end
                })
            elseif val == "on_window_change" then
                -- 模式二：离开当前窗口、切换标签页时进行拦截自动保存
                vim.api.nvim_create_autocmd({ "WinLeave", "TabLeave" }, {
                    group = gid,
                    pattern = "*",
                    callback = function() m:execute("files.action.execute_auto_save")() end
                })
            end
        end,

        ["files.auto_save_delay"] = function(val)
            -- 自动映射为 Neovim 的内置事件空闲延迟判定参数 updatetime
            vim.o.updatetime = val
        end
    }
})

return files
