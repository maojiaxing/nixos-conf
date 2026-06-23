---@meta
local contrib_base = require("core")

local workbench = contrib_base:new({
    properties = {
        -- 主题设置
        ["workbench.color_theme"] = function(val)
            -- 使用 pcall 保护防崩溃安全阀：防止用户在 config 里不小心拼错主题名字而导致开机瘫痪
            local success, err = pcall(vim.cmd, "colorscheme " .. val)
            if not success then
                vim.notify(string.format("工作台警告: 未找到主题 [%s], 降级为原生默认皮肤. 错误信息: %s", val, err), vim.log.levels.WARN)
            end
        end,

        -- 图标主题设置
        ["workbench.icon_theme"] = function(val)
            -- 侧边栏插件（如 neo-tree 或 nvim-tree）在惰性加载启动时，会主动读取此值来决定是否渲染精美图标
            if val == "none" then
                vim.g.nvim_web_devicons_enabled = false
            else
                vim.g.nvim_web_devicons_enabled = true
            end
        end,
    },

    actions = {
        -- 欢迎页
        ["workbench.action.show_welcome_page"] = {
            description = "View: Bring up the integrated start dashboard page",
            key = "<leader>ah",
            callback = function()
                if vim.bo.modified then
                    vim.notify("当前文件已修改，请先保存再进入欢迎页", vim.log.levels.WARN)
                    return
                end

                local buf = vim.api.nvim_create_buf(false, true)
                vim.bo[buf].buftype = "nofile"
                vim.bo[buf].bufhidden = "wipe"
                vim.bo[buf].swapfile = false
                vim.bo[buf].filetype = "welcome"

                -- 🌟 完美置换为全新的硬核盲文点阵 Header
                local welcome_lines = {
                    "",
                    "  ⣇⣿⠘⣿⣿⣿⡿⡿⣟⣟⢟⢟⢝⠵⡝⣿⡿⢂⣼⣿⣷⣌⠩⡫⡻⣝⠹⢿⣿⣷ ",
                    "  ⡆⣿⣆⠱⣝⡵⣝⢅⠙⣿⢕⢕⢕⢕⢝⣥⢒⠅⣿⣿⣿⡿⣳⣌⠪⡪⣡⢑⢝⣇ ",
                    "  ⡆⣿⣿⣦⠹⣳⣳⣕⢅⠈⢗⢕⢕⢕⢕⢕⢈⢆⠟⠋⠉⠁⠉⠉⠁⠈⠼⢐⢕⢽ ",
                    "  ⡗⢰⣶⣶⣦⣝⢝⢕⢕⠅⡆⢕⢕⢕⢕⢕⣴⠏⣠⡶⠛⡉⡉⡛⢶⣦⡀⠐⣕⢕ ",
                    "  ⡝⡄⢻⢟⣿⣿⣷⣕⣕⣅⣿⣔⣕⣵⣵⣿⣿⢠⣿⢠⣮⡈⣌⠨⠅⠹⣷⡀⢱⢕ ",
                    "  ⡝⡵⠟⠈⢀⣀⣀⡀⠉⢿⣿⣿⣿⣿⣿⣿⣿⣼⣿⢈⡋⠴⢿⡟⣡⡇⣿⡇⡀⢕ ",
                    "  ⡝⠁⣠⣾⠟⡉⡉⡉⠻⣦⣻⣿⣿⣿⣿⣿⣿⣿⣿⣧⠸⣿⣦⣥⣿⡇⡿⣰⢗⢄ ",
                    "  ⠁⢰⣿⡏⣴⣌⠈⣌⠡⠈⢻⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣬⣉⣉⣁⣄⢖⢕⢕⢕ ",
                    "  ⡀⢻⣿⡇⢙⠁⠴⢿⡟⣡⡆⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⣵⣵⣿ ",
                    "  ⡻⣄⣻⣿⣌⠘⢿⣷⣥⣿⠇⣿⣿⣿⣿⣿⣿⠛⠻⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿ ",
                    "  ⣷⢄⠻⣿⣟⠿⠦⠍⠉⣡⣾⣿⣿⣿⣿⣿⣿⢸⣿⣦⠙⣿⣿⣿⣿⣿⣿⣿⣿⠟ ",
                    "  ⡕⡑⣑⣈⣻⢗⢟⢞⢝⣻⣿⣿⣿⣿⣿⣿⣿⠸⣿⠿⠃⣿⣿⣿⣿⣿⣿⡿⠁⣠ ",
                    "  ⡝⡵⡈⢟⢕⢕⢕⢕⣵⣿⣿⣿⣿⣿⣿⣿⣿⣿⣶⣶⣿⣿⣿⣿⣿⠿⠋⣀⣈⠙ ",
                    "  ⡝⡵⡕⡀⠑⠳⠿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠿⠛⢉⡠⡲⡫⡪⡪⡣ ",
                    "",
                    "",
                    "    Quick Guides:",
                    "    • File Explorer  :  <leader>e  ->  workbench.action.toggle_sidebar_visibility",
                    "    • Command Palette:  <M-x>       ->  workbench.action.show_commands",
                    "    • Auto Format    :  <leader>fm  ->  editor.action.format_document",
                    "",
                    "    Type :Code <Tab> to explore all decoupled snake_case actions.",
                }

                vim.api.nvim_buf_set_lines(buf, 0, -1, false, welcome_lines)
                vim.api.nvim_set_current_buf(buf)
                vim.bo[buf].modifiable = false
            end
        },

        -- 切换侧边栏文件浏览器的显示与隐藏
        ["workbench.action.toggle_sidebar_visibility"] = {
            description = "View: Toggle primary sidebar directory explorer layout",
            key = "<leader>e",
            callback = function()
                if vim.bo.filetype == "netrw" then vim.cmd("bd") else vim.cmd("Lexplore") end
            end
        },

        -- 向右垂直拆分当前窗口
        ["workbench.action.split_editor"] = {
            description = "Window: Partition current editor group vertically to the right",
            key = "<leader>\\",
            callback = function() vim.cmd("vsplit") end
        },

        -- 将窗口光标焦点移动至左侧窗口
        ["workbench.action.focus_left_group"] = {
            description = "Navigate: Shift viewport focus to leftmost editor stack",
            key = "<C-h>",
            callback = function() vim.cmd("wincmd h") end
        },

        -- 将窗口光标焦点移动至右侧窗口
        ["workbench.action.focus_right_group"] = {
            description = "Navigate: Shift viewport focus to rightmost editor stack",
            key = "<C-l>",
            callback = function() vim.cmd("wincmd l") end
        },

        -- 快速调起原生命令行补全工具面板
        ["workbench.action.show_commands"] = {
            description = "Command: Invoke native command-line mapping prompt",
            key = "<M-x>",
            callback = function()
                vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(":Code ", true, false, true), "n", false)
            end
        }
    }
})

vim.api.nvim_create_autocmd("VimEnter", {
    callback = function()
        if vim.fn.argc() == 0 and vim.fn.line2byte("$") == -1 then
            m:execute("workbench.action.show_welcome_page")()
        end
    end
})

return workbench
