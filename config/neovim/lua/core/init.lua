---@meta

---@class contrib_action_meta
---@field description string Action descriptor
---@field callback function Native fallback callback)
---@field key? string Default physical binding

---@class contrib_base
---@field actions table<string, contrib_action_meta> 子模块声明的贡献行为
---@field properties table<string, function> 子模块声明的属性处理器
local contrib_base = {}

-- 全局状态注册表
local global_action_registry = {}
local global_keys = {}
local global_actions_pool = {}

-- 面向对象：构造函数
function contrib_base:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    return o
end

-- 物理键位绑定器
function contrib_base:bind_physical_key(action_id, key_str, description)
    global_keys[action_id] = key_str
    vim.keymap.set("n", key_str, self:execute(action_id), {
        noremap = true,
        silent = true,
        desc = description or action_id
    })
end

-- 注册器：子模块初始化时调用，自动汇流数据并绑定默认快捷键
function contrib_base:register_contributions()
    if not self.actions then return end

    for action_id, data in pairs(self.actions) do
        global_actions_pool[action_id] = data
        global_action_registry[action_id] = global_action_registry[action_id] or {}

        -- 将子模块自带的原生 callback 注入为最低优先级 (-1) 作为 fallback 兜底
        table.insert(global_action_registry[action_id], {
            cb = data.callback,
            priority = -1,
            source = "native_fallback" -- 标记来源为原生兜底
        })

        -- 自动扫描并激活内聚的默认推荐按键
        if data.key and data.key ~= "" then
            self:bind_physical_key(action_id, data.key, data.description)
        end
    end
end

-- 用户改键服务
function contrib_base:bind_key(action_id, new_key)
    local old_key = global_keys[action_id]
    if old_key and old_key ~= "" then pcall(vim.keymap.del, "n", old_key) end
    local action_data = self.actions and self.actions[action_id]
    local desc = action_data and action_data.description or action_id
    if new_key and new_key ~= "" then self:bind_physical_key(action_id, new_key, desc) else global_keys[action_id] = nil end
end

-- 供高级插件接管核心行为（注入接管源 source）
function contrib_base:action(action_id, callback, opts)
    opts = opts or {}
    local priority = opts.priority or 10
    local plugin_name = opts.plugin or "unknown_plugin"

    local safe_callback = function()
        if opts.plugin then
            local lazy_config = require("lazy.core.config")
            local plugin = lazy_config.plugins[opts.plugin]
            if plugin and not plugin._.loaded then
                require("lazy").load({ plugins = { opts.plugin } })
            end
        end
        callback()
    end

    global_action_registry[action_id] = global_action_registry[action_id] or {}
    table.insert(global_action_registry[action_id], {
        cb = safe_callback,
        priority = priority,
        source = plugin_name
    })

    -- 按优先级由大到小严格排序（保证 chain[1] 永远是获胜者）
    table.sort(global_action_registry[action_id], function(a, b) return a.priority > b.priority end)
end

-- 统一路由执行器
function contrib_base:execute(action_id)
    return function()
        local chain = global_action_registry[action_id]
        if chain and #chain > 0 then chain[1].cb() end -- 执行当前优先级最高的胜出者
    end
end

-- 迁移入父类的属性应用器
function contrib_base:apply_properties(user_props)
    if not self.properties then return end
    for key, val in pairs(user_props) do
        local handler = self.properties[key]
        if type(handler) == "function" then handler(val) end
    end
end

-- 自动扫描挂载引擎
function contrib_base.contrib_loader(dir_name)
    local config_root = vim.fn.stdpath("config")
    local target_path = string.format("%s/lua/%s", config_root, dir_name)

    if vim.fn.isdirectory(target_path) == 0 then return end

    for name, type_str in vim.fs.dir(target_path) do
        if type_str == "file" and name:match("%.lua$") and name ~= "init.lua" and name ~= "language_base.lua" then
            local module_name = name:gsub("%.lua$", "")
            local require_path = string.format("%s.%s", dir_name:gsub("/", "."), module_name)

            -- 1. 安全加载该子模块文件
            local success, module_or_err = pcall(require, require_path)

            if success then
                -- 2. 🌟 核心机制：检查返回的对象是否是一个合法的由微内核派生的子类实例
                -- 如果它拥有父类的注册方法，则由 Loader 在后台自动替它完成注册和按键绑定！
                if type(module_or_err) == "table" and type(module_or_err.register_contributions) == "function" then
                    module_or_err:register_contributions()
                end
            else
                vim.notify(string.format("内核 Loader 全自动挂载 [%s] 失败: %s", require_path, module_or_err), vim.log.levels.ERROR)
            end
        end
    end
end

-- Healthcheck 审计的 CommandLine 引擎
function contrib_base.init_commandline_engine()
    vim.api.nvim_create_user_command("Code", function(opts)
        local arg = opts.args

        -- 拦截特殊关键字: health
        if arg == "health" then
            local health_lines = {
                "======================================================================",
                "                 Neovim Framework Core Healthcheck                     ",
                "======================================================================",
                string.format("%-46s │ %-10s │ %-20s", "ACTION IDENTIFIER", "KEYMAP", "ACTIVE MANAGEMENT"),
                "----------------------------------------------------------------------",
            }

            -- 遍历中央注册表中的所有动作，提取当前的实际接管状态
            local sorted_actions = {}
            for action_id, _ in pairs(global_action_registry) do
                table.insert(sorted_actions, action_id)
            end
            table.sort(sorted_actions)

            for _, action_id do
                local chain = global_action_registry[action_id]
                local bind_key = global_keys[action_id] or "none"
                local status_str = "unknown"

                if chain and #chain > 0 then
                    local winner = chain[1] -- 拿到当前排序第一的获胜者
                    if winner.source == "native_fallback" then
                        status_str = "⚡ native_fallback"
                    else
                        status_str = string.format("🔌 %s (p:%d)", winner.source, winner.priority)
                    end
                end

                local line = string.format("%-46s │ %-10s │ %-20s", action_id, bind_key, status_str)
                table.insert(health_lines, line)
            end

            table.insert(health_lines, "======================================================================")

            -- 创建一个浮动的临时缓冲区来优雅展示健康数据面板
            local buf = vim.api.nvim_create_buf(false, true)
            vim.api.nvim_buf_set_lines(buf, 0, -1, false, health_lines)
            vim.bo[buf].modifiable = false
            vim.bo[buf].filetype = "markdown"

            -- 弹出一个居中的垂直分割窗口展示
            vim.cmd("botright vsplit")
            vim.api.nvim_win_set_buf(0, buf)
            return
        end

        -- 正常执行通用 Action 路由
        local chain = global_action_registry[arg]
        if chain and #chain > 0 then
            chain[1].cb()
        else
            vim.notify("Unknown command: " .. arg, vim.log.levels.ERROR)
        end
    end, {
        nargs = 1,
        complete = function(arg_lead)
            -- 将 "health" 动态追加进补全候选池中
            local matches = { "health" }
            for action_id, _ in pairs(global_actions_pool) do
                if action_id:find(arg_lead, 1, true) then table.insert(matches, action_id) end
            end
            table.sort(matches)
            return matches
        end,
    })
end

return contrib_base
