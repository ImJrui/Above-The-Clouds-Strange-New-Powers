--[[
使用该脚本将自动读取strings目录下的文件，然后生成对应的翻译文本到scripts\languages\plreb_chinese_s.po
]]
local function processPOFiles()
    -- 获取当前脚本的路径
    local info = debug.getinfo(1, "S")
    if not info or not info.source then
        print("错误: 无法获取脚本路径")
        return
    end
    
    local script_path = info.source:sub(2)  -- 移除开头的@符号
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
    
    -- 确保路径分隔符正确
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
    
    print("输入目录: " .. input_dir)
    print("输出文件: " .. output_file)
    
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
    
    -- 获取目录中的.lua文件列表
    local files = {}
    for file in io.popen('dir "' .. input_dir .. '\\*.lua" /b'):lines() do
        table.insert(files, file)
        print("找到Lua文件: " .. file)
    end
    
    if #files == 0 then
        print("错误: 在目录中没有找到任何.lua文件: " .. input_dir)
        return
    end
    
    print("\n共找到 " .. #files .. " 个.lua文件")
    
    -- 打开输出文件
    local output = io.open(output_file, "w")
    if not output then
        print("错误: 无法创建输出文件: " .. output_file)
        return
    end
    
    -- 写入PO文件头
    output:write("msgid \"\"\n")
    output:write("msgstr \"\"\n")
    output:write("\"Language: zh-CN\\n\"\n")
    output:write("\"Content-Type: text/plain; charset=utf-8\\n\"\n")
    output:write("\"Content-Transfer-Encoding: 8bit\\n\"\n")
    output:write("\"POT Version: 2.0\"\n\n")
    
    -- 处理每个文件
    for index, filename in ipairs(files) do
        print("\n=== 处理文件 [" .. index .. "/" .. #files .. "]: " .. filename .. " ===")
        
        local filepath = input_dir .. "\\" .. filename
        
        -- 读取文件内容
        local file_handle = io.open(filepath, "r")
        if not file_handle then
            print("警告: 无法打开文件: " .. filepath)
            goto continue
        end
        
        local content = file_handle:read("*a")
        file_handle:close()
        
        -- 【关键修改】在内存中临时修改文件内容：将_Translator函数中的return string["EN"]改为return string
        -- 使用字符串替换，匹配模式：return后跟空格、参数名、["EN"]，并捕获参数名
        content = content:gsub('return%s*(%w+)%["EN"%]', 'return %1')
        
        -- 创建一个安全的环境来执行翻译文件
        local env = {
            -- 这里保留_Translator定义作为备用，但修改内容后可能不再需要
            _Translator = function(t)
                return t
            end,
            -- 添加其他可能需要的全局变量
            land = "EN",
            GetModConfigData = function(key)
                if key == "LANGUAGE" then
                    return "EN"
                end
                return nil
            end
        }
        
        -- 设置元表，使环境可以访问标准库
        setmetatable(env, {__index = _G})
        
        -- 尝试加载并执行文件（使用修改后的内容）
        local chunk, load_error = load(content, filename, "t", env)
        if not chunk then
            print("错误: 无法加载文件: " .. load_error)
            goto continue
        end
        
        local success, translation_table = pcall(chunk)
        if not success then
            print("错误: 执行文件失败: " .. translation_table)
            goto continue
        end
        
        if not translation_table then
            print("警告: 文件没有返回表数据")
            goto continue
        end
        
        -- 确定前缀
        local prefix = ""
        if filename == "common.lua" then
            prefix = "STRINGS."
        elseif filename == "generic.lua" then
            prefix = "STRINGS.CHARACTERS.GENERIC."
        else
            local char_name = filename:gsub("%.lua$", ""):upper()
            prefix = "STRINGS.CHARACTERS." .. char_name .. "."
        end
        
        -- 递归遍历表，提取翻译条目
        local function traverseTable(t, current_path, entries)
            for key, value in pairs(t) do
                local key_str = tostring(key)
                local new_path = current_path and (current_path .. "." .. key_str) or key_str
                
                if type(value) == "table" then
                    -- 检查是否是翻译条目（包含EN和CN键）
                    if value.EN and value.CN then
                        table.insert(entries, {
                            path = new_path,
                            en = tostring(value.EN),
                            cn = tostring(value.CN)
                        })
                        -- print("找到翻译条目: " .. new_path)
                    else
                        -- 递归遍历子表
                        traverseTable(value, new_path, entries)
                    end
                end
            end
        end
        
        local entries = {}
        traverseTable(translation_table, nil, entries)
        
        print("提取到 " .. #entries .. " 个翻译条目")
        
        -- 写入PO文件
        for i, entry in ipairs(entries) do
            local full_path = prefix .. entry.path
            
            -- 正确处理转义字符
            local en_escaped = entry.en:gsub("\n", "\\n"):gsub('"', '\\"')
            local cn_escaped = entry.cn:gsub("\n", "\\n"):gsub('"', '\\"')
            
            output:write("#. " .. full_path .. "\n")
            output:write("msgctxt \"" .. full_path .. "\"\n")
            output:write("msgid \"" .. en_escaped .. "\"\n")
            output:write("msgstr \"" .. cn_escaped .. "\"\n")
            output:write("\n")
            
            if i <= 3 or i > #entries - 3 then
                print("处理条目 " .. i .. ": " .. full_path)
            elseif i == 4 and #entries > 6 then
                print("... 中间条目省略 ...")
            end
        end
        
        ::continue::
    end
    
    output:close()
    print("\n=== 转换完成 ===")
    print("输出文件: " .. output_file)
    print("总处理文件数: " .. #files)
end

-- 运行脚本
processPOFiles()