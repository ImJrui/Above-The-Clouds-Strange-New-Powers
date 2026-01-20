--[[
使用该脚本将自动读取strings目录下的文件：
1. 生成中文翻译文件 scripts\languages\plreb_chinese_s.po（原功能）
2. 同时生成翻译模板 strings\strings.pot（新增功能）
]]

local function processPOFiles()
    -- 获取当前脚本的路径
    local info = debug.getinfo(1, "S")
    if not info or not info.source then
        print("错误: 无法获取脚本路径")
        return
    end

    local script_path = info.source:sub(2)
    local script_dir = script_path:match("(.*[/\\])")

    if not script_dir then
        print("错误: 无法获取脚本目录")
        return
    end

    print("脚本路径: " .. script_path)
    print("脚本目录: " .. script_dir)

    -- 获取模组根目录
    local mod_root = script_dir:gsub("[/\\]strings[/\\]tools[/\\]$", "")
    if mod_root == script_dir then
        mod_root = script_dir:match("(.*)[/\\]") or script_dir
        print("警告: 使用回退方式获取模组根目录")
    end

    local function ensureTrailingSeparator(path)
        if path:sub(-1) ~= "/" and path:sub(-1) ~= "\\" then
            return path .. "\\"
        end
        return path
    end

    mod_root = ensureTrailingSeparator(mod_root)
    print("模组根目录: " .. mod_root)

    local input_dir = mod_root .. "strings"
    local output_file = mod_root .. "scripts\\languages\\plreb_chinese_s.po"
    local pot_file = mod_root .. "scripts\\languages\\strings.pot" -- ★ 新增

    print("输入目录: " .. input_dir)
    print("PO输出文件: " .. output_file)
    print("POT输出文件: " .. pot_file)

    -- 检查输入目录是否存在
    local test_cmd = 'if exist "' .. input_dir .. '" echo EXIST'
    local test_result = io.popen(test_cmd)
    if not test_result then
        print("错误: 无法检查输入目录是否存在")
        return
    end

    local result = test_result:read("*a")
    test_result:close()

    if not result:match("EXIST") then
        print("错误: 输入目录不存在: " .. input_dir)
        return
    end

    -- 创建输出目录
    local output_dir = output_file:match("(.*)[/\\]")
    if output_dir then
        os.execute('mkdir "' .. output_dir .. '" 2>nul')
    end

    -- 获取 Lua 文件列表
    local files = {}
    for file in io.popen('dir "' .. input_dir .. '\\*.lua" /b'):lines() do
        table.insert(files, file)
        -- print("找到Lua文件: " .. file)
    end

    if #files == 0 then
        print("错误: 在目录中没有找到任何.lua文件")
        return
    end

    print("\n共找到 " .. #files .. " 个.lua文件")

    -- 打开输出文件
    local output = io.open(output_file, "w")
    if not output then
        print("错误: 无法创建PO文件")
        return
    end

    local pot_output = io.open(pot_file, "w")
    if not pot_output then
        print("错误: 无法创建POT文件")
        output:close()
        return
    end

    -- ===== 写入 PO 文件头（原功能）=====
    output:write("msgid \"\"\n")
    output:write("msgstr \"\"\n")
    output:write("\"Language: zh-CN\\n\"\n")
    output:write("\"Content-Type: text/plain; charset=utf-8\\n\"\n")
    output:write("\"Content-Transfer-Encoding: 8bit\\n\"\n")
    output:write("\"POT Version: 2.0\"\n\n")

    -- ===== 写入 POT 文件头（新增）=====
    pot_output:write("\"Application: Don't Starve\\n\"\n")
    pot_output:write("\"POT Version: 2.0\\n\"\n\n")

    -- 处理每个文件
    for index, filename in ipairs(files) do
        print("\n=== 处理文件 [" .. index .. "/" .. #files .. "]: " .. filename .. " ===")

        local filepath = input_dir .. "\\" .. filename
        local file_handle = io.open(filepath, "r")
        if not file_handle then
            print("警告: 无法打开文件: " .. filepath)
            goto continue
        end

        local content = file_handle:read("*a")
        file_handle:close()

        -- 1. 忽略 GLOBAL.setfenv
        content = content:gsub("GLOBAL%.setfenv%(%s*1%s*,%s*GLOBAL%s*%)", "")

        -- 2. 兼容旧 Translator（可留）
        -- content = content:gsub('return%s*(%w+)%["EN"%]', 'return %1')


        local env = {
            en_zh = function(t) return t end,
            land = "EN",
            GetModConfigData = function(key)
                if key == "LANGUAGE" then return "EN" end
            end
        }
        setmetatable(env, { __index = _G })

        local chunk, load_error = load(content, filename, "t", env)
        if not chunk then
            print("错误: 加载失败: " .. load_error)
            goto continue
        end

        local ok, translation_table = pcall(chunk)
        if not ok or not translation_table then
            print("错误: 执行失败")
            goto continue
        end

        local prefix = ""
        if filename == "common.lua" then
            prefix = "STRINGS."
        elseif filename == "generic.lua" then
            prefix = "STRINGS.CHARACTERS.GENERIC."
        else
            local char_name = filename:gsub("%.lua$", ""):upper()
            prefix = "STRINGS.CHARACTERS." .. char_name .. "."
        end

        local entries = {}

        local function traverseTable(t, current_path)
            for k, v in pairs(t) do
                local key = tostring(k)
                local path = current_path and (current_path .. "." .. key) or key

                if type(v) == "table" then
                    if v.EN and v.CN then
                        table.insert(entries, {
                            path = path,
                            en = tostring(v.EN),
                            cn = tostring(v.CN)
                        })
                    else
                        traverseTable(v, path)
                    end
                end
            end
        end

        traverseTable(translation_table, nil)
        print("提取到 " .. #entries .. " 个翻译条目")

        for _, entry in ipairs(entries) do
            local full_path = prefix .. entry.path
            local en = entry.en:gsub("\n", "\\n"):gsub('"', '\\"')
            local cn = entry.cn:gsub("\n", "\\n"):gsub('"', '\\"')

            -- 原 PO 输出
            output:write("#. " .. full_path .. "\n")
            output:write("msgctxt \"" .. full_path .. "\"\n")
            output:write("msgid \"" .. en .. "\"\n")
            output:write("msgstr \"" .. cn .. "\"\n\n")

            -- 新增 POT 输出
            pot_output:write("#. " .. full_path .. "\n")
            pot_output:write("msgctxt \"" .. full_path .. "\"\n")
            pot_output:write("msgid \"" .. en .. "\"\n")
            pot_output:write("msgstr \"\"\n\n")
        end

        ::continue::
    end

    output:close()
    pot_output:close()

    print("\n=== 转换完成 ===")
    print("PO文件: " .. output_file)
    print("POT文件: " .. pot_file)
end

-- 运行脚本
processPOFiles()
