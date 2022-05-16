--[[
    更新日志：
    1.6
        修复中文输入法在注释中输入英文会触发自动完成的问题。 bug #3
        修复 INCREMENTAL = false 模式下，空白内容也可能触发自动完成的问题。
    1.5
        修复 %abc 无法触发自动完成的问题。 bug #2
        支持 .abc 形式的关键词提取与匹配。
        去除文件编码检测功能（已由 智能编码.ahk 更好的实现）。
    1.4
        合并调试功能。
    1.3
        增加文件编码检测功能。
    1.2
        合并 fincs 和 Lexikos 的样式。
    1.1
        修复已经打开了文件又新建空文档时自动完成功能失效的问题。 bug #1
    1.0
        修复了 Lexikos 的关键字砍头、取词长度不正确、 api 文件不存在会报错的 bug 。
        实现了中文、英文（应该也包括韩文日文等）关键字的提示。
        实现了实时提取关键字（原版仅在打开文件时提取），解决了实时提取关键字的性能问题。
        改进了自动完成框的闪烁问题。
        实现了跨文件关键字共享，但默认关闭了这个功能。
        lua 也可以自动完成。
    
    可以继续改进的地方：
        自动完成框显示出的内容不变（滚动条下面的变化无所谓，反正看不见）就可以不刷新。这将进一步降低闪烁问题。
        最完美的实时提取关键字应该是实时全文件更新，但这样会有性能问题。
        比较折衷的方式是抓取文件所有被修改的的行，然后进行处理，但目前暂做不到。
    
    base on AutoComplete v0.8 by Lexikos
    https://gist.github.com/Lexikos/bc17b8d55ae8a8102e35
    
    editor APIs
    https://www.scintilla.org/PaneAPI.html
--]]

--[[
    List of styles per lexer that autocomplete should not occur within.
    Should include comments and strings.
    下面样式列表中不提取关键字、不进行花括号自动缩进。
    不要把样式20包含进去，这会导致 %ms 无法触发 msgbox 的自动完成。 bug #2
--]]
local IGNORE_STYLES = {
    [SCLEX_AHK1] = {1,2,3,6},
    [SCLEX_AHK2] = {1,2,3,5,15},
    [SCLEX_LUA]  = {1,2,3,6,7,8,12}
}

local DEBUG_MODE = false                      -- 调试模式。
local SHARING_KEYWORDS_BETWEEN_FILES = false  -- 跨文件关键字共享。比如同时打开 AB 两个文件， A 文件中抓到的关键字 “haha” ，在 B 文件中也可以提示。
local INCREMENTAL = false                     -- 根据关键字变化不断减少自动完成列表内容。 false 则和 SciTE 原版一致，只变动光标，不改变列表。
local IGNORE_CASE = true                      -- 关键字匹配时忽略大小写
local CASE_CORRECT = true                     -- 自动纠正大小写
local CASE_CORRECT_INSTANT = false
local WRAP_ARROW_KEYS = false
local MIN_PREFIX_LEN = 2                      -- 最少输入几个字符后，开始匹配自动完成列表。 Number of chars to type before the autocomplete list appears.
local MIN_IDENTIFIER_LEN = 3                  -- 添加到自动完成列表的关键字的最小长度（不影响从 “ahk.api” 添加关键字的长度）。 Length of shortest word to add to the autocomplete list.

--[[
    List of regex patterns for finding suggestions for the autocomplete menu:
    这个表达式的本质，就是通过排除 ASCII 码表的字符，来构建一个字符组。
    特别注意，这个表达式是给 “editor:findtext()” 使用的，那么看起来应该遵循 SciTE 的正则语法。
    可是实际上它是调用的 lua ，并且默认大小写不敏感，即使指定 “SCFIND_REGEXP” 参数也如此！！！
    因此还需要手动加上 “SCFIND_MATCHCASE” 参数！！！！！！！！！！！！！！！！！！！！！！！！
    [\46] 表示 “.” 。实践表明 “\.” 跟预期不一致所以用这种写法替代。
    [^\1-\64\91-\94\96\123-\127] 在 ASCII 码表中等于 [a-zA-Z_] 但因为使用了排除的形式，所以可以匹配到中文。
    [^\1-\47\58-\64\91-\94\96\123-\127] 在 ASCII 码表中等于 [a-zA-Z0-9_] 但因为使用了排除的形式，所以可以匹配到中文。
    因此整个表达式的意思就是 {"\.*[a-zA-Z_中文日文韩文][a-zA-Z0-9_中文日文韩文]+"}
    需要注意的是，如果在 SciTE 编辑器中使用这个表达式，需要把 “\1” 替换为 “\x00” 。
    原因是 “\0” 也就是空字符会让 lua 出错，因此 lua 使用这个表达式就必须从 “\1” 开始。
    另一个需要注意的地方是，这个表达式会同样匹配到中文的标点，例如 “，” “。” 等等。
    之所以这里让它匹配到标点的原因是， lua 和 SciTE 都不支持 unicode 字符的匹配，因此难以单独只匹配汉字。
    另一个原因则是，实际上在代码中，你是可以用中文标点作为变量名的，加上表达式被限制为不在注释等地方匹配，因此确实可以匹配到正确结果。
    这是 SciTE 编辑器中 Ctrl+F 使用的版本 {"\.*[^\x00-\x40\x5B-\x5E\x60\x7B-\x7F][^\x00-\x2F\x3A-\x40\x5B-\x5E\x60\x7B-\x7F]+"}
--]]
local IDENTIFIER_PATTERNS = {"[\46]*[^\1-\64\91-\94\96\123-\127][^\1-\47\58-\64\91-\94\96\123-\127]+"}

local CHOOSE_SINGLE = props["autocomplete.choose.single"]
-- This feature is very awkward when combined with automatic popups:
props["autocomplete.choose.single"] = "0"

-- Override settings that interfere with this script:
props["autocomplete.ahk1.start.characters"] = ""
props["autocomplete.ahk2.start.characters"] = ""



-- 不区分大小写的话， normalize 函数就直接大写取到的字符。
-- 将大写后的字符存为 key ，可以避免重复记录 “word” “Word” 这样的单词。
local normalize
if IGNORE_CASE then
    normalize = string.upper
else
    normalize = function(word) return word end
end



local shouldIgnorePos -- init'd by buildNames().
local function setLexerSpecificStuff()
    -- Disable collection of words in comments, strings, etc.
    -- Also disables autocomplete popups while typing there.
    if IGNORE_STYLES[editor.Lexer] then
        -- Define a function for calling later:
        shouldIgnorePos = function(pos)
            local flag1 = isInTable(IGNORE_STYLES[editor.Lexer], editor.StyleAt[pos])
            -- use chinese ime to type "win" in comment, StyleAt[pos] = 0(that's wrong), StyleAt[pos-1] = 1 or 2(that's right).
            local flag2 = (editor.StyleAt[pos-1] == 1 or editor.StyleAt[pos-1] == 2) -- bug #3
            return (flag1 or flag2)
        end
    else
        -- Optional: Disable autocomplete popups for unknown lexers.
        shouldIgnorePos = function(pos) return true end
    end
end



local names = {}
local unique = {} -- 让 unique 持久的储存数据。这个对象是以 unique["key"]=value 形式储存值的，所以 key 都是唯一的。
local function unique2names()
    names = {}
    for _,name in pairs(unique) do
        table.insert(names, name)
    end
    table.sort(names, function(a,b) return normalize(a) < normalize(b) end)
end
local function loadCache()
    names = buffer.namesForAutoComplete
    unique = buffer.uniqueForAutoComplete
end
local function saveCache()
    buffer.namesForAutoComplete = names
    buffer.uniqueForAutoComplete = unique
end
local function buildNamesFromPos(_startPos, _endPos)
    setLexerSpecificStuff() -- 获取需要忽略的样式的坐标，例如所有注释部分的坐标。
    local startPos, endPos
    endPos = _startPos - 1 -- 这里必须 -1 ，否则文首抓到的关键字会被砍头 “msgbox” 变 “sgbox” 。
    -- Collect all words matching the given patterns. 根据规则提取关键字。
    for i, pattern in ipairs(IDENTIFIER_PATTERNS) do
        while true do
            -- SCFIND_REGEXP 表示使用正则表达式去匹配。默认大小写不敏感，因此需要手动加上大小写敏感的参数 SCFIND_MATCHCASE ！
            startPos, endPos = editor:findtext(pattern, SCFIND_REGEXP + SCFIND_MATCHCASE, endPos + 1)
            if (not startPos) or (endPos > _endPos) then
                break
            end
            -- 匹配到的内容不在注释中
            if not shouldIgnorePos(startPos) then
                if endPos-startPos >= MIN_IDENTIFIER_LEN then
                    -- Create one key-value pair per unique word:
                    local name = editor:textrange(startPos, endPos)
                    if DEBUG_MODE then print("本次取到的关键字："..name) end
                    unique[normalize(name)] = name -- normalize 在忽略大小写的情况下，实际上是把所有单词大写化了一遍，以避免重复添加单词。
                end
            end
        end
    end
end
local function buildApiNames() -- 从 “ahk.api” 和 “user\user.ahk.api” 文件中取关键字。
    local apiFiles = props["APIPath"] or ""
    apiFiles:gsub("[^;]+", function(apiFile) -- For each in ;-delimited list. 删除 “;” 之外的字符，也就是删得只剩分隔符 “;” 了。
        if FileExists(apiFile) then -- 文件存在再进行操作。不然会报错找不到文件。
            for name in io.lines(apiFile) do
                name = name:gsub("[\(, ].*", "") -- Discard parameters/comments. 删除左括号、逗号、空格及其后面的全部字符。
                if string.len(name) > 0 then
                    unique[normalize(name)] = name -- This also "case-corrects"; e.g. "gui" -> "Gui".
                end
            end
        end
    end)
end
local function buildDocNames()
    buildNamesFromPos(0, editor.TextLength)
end
local function buildNames()
    unique = {}
    -- 从 API 文件创建关键字
    buildApiNames()
    -- 从当前打开文件创建关键字
    buildDocNames()
    -- 将关键字转为自动完成列表
    unique2names()
end



local notempty = next
local lastAutoCItem = 0 -- Used by handleKey().
local menuItems
local list_old = "" -- 储存旧的 list 的值，用于和新的 list 做对比，没变化就不刷新列表，降低闪烁。
local function handleChar(char, calledByHotkey)
    -- This function should only run when the Editor pane is focused.
    if not editor.Focus then return false end
    if DEBUG_MODE then print("--------------------") end
    --[[
        实际上，如果打开 SciTE 时没有任何文件被打开，那么此时 OnOpen 事件是会被激活的。
        有问题的就是已经打开了文件，此时新建文件， OnOpen 事件又不会被激活。
        此时 OnClear() 是唯一能在创建新文件时被激活的事件。
        但是激活此事件时， buffer 并没有被清空，值还是前一个文件的。
        也就是说在唯一能够变相捕获创建新文件的事件中，没法做任何事。
        因此只能在此处验证并建立关键字列表。 bug #1
    --]]
    if not buffer.namesCache then
        if DEBUG_MODE then print("OnNewFile_no_cache|   endpos:"..editor.TextLength) end
        -- Otherwise, build a new list.
        buildNames()
        saveCache()
        buffer.namesCache = true
    end

    --[[
        行模式的意义就是——关键字在换行后就被实时创建，同时又不会因为每次更新关键字都是全文更新而造成性能问题。
        缺点就是最完美的做法实际上是获取文件所有被修改的行，然后提取这些行的关键字。
        但目前的做法是提取按了回车的那一行，这当然包括了大部分代码被修改的情况，但显然修改某行后，鼠标点走的情况没被包括在内。
    --]]
    if char == "\n" then
        -- 获取按下回车时的那行的首尾坐标。
        local line_num = editor:LineFromPosition(editor.CurrentPos)
        local line_start = editor:PositionFromLine(line_num-1)
        local line_end = editor.LineEndPosition[line_num-1]
        -- 这里是更新 unique ，所以不要去清空 unique 。
        buildNamesFromPos(line_start, line_end)
        unique2names()
        saveCache()
        -- 自动缩进
        local prevStyle = editor.StyleAt[getPrevLinePos()]
        if not isInTable(IGNORE_STYLES[editor.Lexer], prevStyle) then
            return AutoIndent_OnNewLine() -- fincs 原版这里就用的 return 。
        end
    elseif char == "{" then
        local curStyle = editor.StyleAt[editor.CurrentPos-2]
        if not isInTable(IGNORE_STYLES[editor.Lexer], curStyle) then
            AutoIndent_OnOpeningBrace()
        end
    elseif char == "}" then
        local curStyle = editor.StyleAt[editor.CurrentPos-2]
        if not isInTable(IGNORE_STYLES[editor.Lexer], curStyle) then
            AutoIndent_OnClosingBrace()
        end
    end

    local pos = editor.CurrentPos
    local startPos = editor:WordStartPosition(pos, true)
    if editor:textrange(startPos-1, startPos)=="." then startPos = startPos - 1 end -- 往前取一个字符看能不能取到 “.” 。
    if DEBUG_MODE then print("本次键入的关键字："..editor:textrange(startPos, pos)) end
    local len = pos - startPos
    if len < MIN_PREFIX_LEN then
        if editor:AutoCActive() then
            if len == 0 then
                if DEBUG_MODE then print("branch1") end
                -- Happens sometimes after typing ")".
                editor:AutoCCancel()
                return
            end
            -- Otherwise, autocomplete is already showing so may as well
            -- keep it updated even though len < MIN_PREFIX_LEN.
        else
            if char then
                if DEBUG_MODE then print("branch2") end
                -- Not enough text to trigger autocomplete, so return.
                return
            end
            -- Otherwise, we were called explicitly without a param.
        end
    end

    if not INCREMENTAL and editor:AutoCActive() then
        -- Nothing to do.
        return false
    end

    if not editor:AutoCActive() then
        if DEBUG_MODE then print("branch3") end
        -- 由于自动完成可以通过包括但不限于 中途{enter}、中途{tab}、全部输完等方式完成。
        -- 为了避免 bug 也为了避免到处去清空 list_old ，因此统一在只要没有自动完成框时就清空旧变量！
        list_old = ""
        if shouldIgnorePos(startPos) and not calledByHotkey then
        -- User is typing in a comment or string, so don't automatically
        -- pop up the auto-complete window.
            return
        end
    end
    local prefix = normalize(editor:textrange(startPos, pos))
    menuItems = {}
    for i, name in ipairs(names) do
        local s = normalize(string.sub(name, 1, len))
        --[[
        这里字符开始插入自动完成框了。
        字符串是可以比较大小的， “ABC” 是大于 “ABB” 的。
        当我们输入 “ms” 时， names 会被遍历，直到 “Multi” 时停下，因为在 names 中， Multi 就是 MsgBox 的下一个关键字。
        之所以要在下一个关键字的地方停下，是因为列表被排序过，比如为了完整获取所有 “gui” 开头的关键字，那么就得在 “guj” 停下。
        --]]
        if s >= prefix then -- 大于等于用得很巧妙。等于时 代表关键字匹配，大于时 代表匹配完了，可以跳出。
            if s == prefix then
                table.insert(menuItems, name) -- 这里已经把所有匹配的关键字全部存入 menuItems 了。
            else
                break -- There will be no more matches.
            end
        end
    end
    if DEBUG_MODE then print("3.1|匹配列表："..table.concat(menuItems, "\1")) end
    if notempty(menuItems) then
        if DEBUG_MODE then print("branch4") end
        -- Show or update the auto-complete list.
        local list = table.concat(menuItems, "\1")
        editor.AutoCIgnoreCase = IGNORE_CASE
        editor.AutoCCaseInsensitiveBehaviour = 1 -- Do NOT pre-select a case-sensitive match
        editor.AutoCSeparator = 1
        editor.AutoCMaxHeight = 5
        -- if not editor:AutoCActive() then -- 另一种降低闪烁的方式，和 SciTE 原版一样，只要自动完成框出现了，就只跳转位置而不刷新。
        if list~=list_old then -- 降低自动完成框的闪烁，只有匹配的关键字发生变化时才刷新。
            if DEBUG_MODE then print("branch5") end
            editor:AutoCShow(len, list)
            list_old=list
        end
        -- Check if we should auto-auto-complete.
        if normalize(menuItems[1]) == prefix and not calledByHotkey then
            -- User has completely typed the only item, so cancel.
            if CASE_CORRECT then
                if CASE_CORRECT_INSTANT or #menuItems == 1 then
                    if DEBUG_MODE then print("branch6") end
                    -- Make sure the correct item is selected.
                    editor:AutoCShow(len, menuItems[1])
                    editor:AutoCComplete()
                end
                if #menuItems > 1 then
                    if DEBUG_MODE then print("branch7") end
                    editor:AutoCShow(len, list)
                end
            end
            if #menuItems == 1 then
                if DEBUG_MODE then print("branch8") end
                editor:AutoCCancel()
                return
            end
        end
        lastAutoCItem = #menuItems - 1
        if lastAutoCItem == 0 and calledByHotkey and CHOOSE_SINGLE then
            if DEBUG_MODE then print("branch9") end
            editor:AutoCComplete()
        end
    else
        -- No relevant items.
        if editor:AutoCActive() then
            if DEBUG_MODE then print("branch10") end
            editor:AutoCCancel()
        end
    end
    -- 不让其它 OnChar 函数继续处理，否则会造成中文关键字显示被打断。
    return true
end



local function handleKey(key, shift, ctrl, alt)
    if key == 0x20 and ctrl and not (shift or alt) then -- ^Space
        handleChar(nil, true)
        return true
    end
    if alt or not editor:AutoCActive() then return end
    if key == 0x8 then -- VK_BACK
        if not ctrl then
            -- Need to handle it here rather than relying on the default
            -- processing, which would occur after handleChar() returns:
            editor:DeleteBack()
            handleChar()
            return true
        end
    elseif key == 0x25 then -- VK_LEFT
        if not shift then
            if ctrl then
                editor:WordLeft() -- See VK_BACK for comments.
            else
                editor:CharLeft() -- See VK_BACK for comments.
            end
            handleChar()
            return true
        end
    elseif key == 0x26 then -- VK_UP
        if editor.AutoCCurrent == 0 then
            -- User pressed UP when already at the top of the list.
            if WRAP_ARROW_KEYS then
                -- Select the last item.
                editor:AutoCSelect(menuItems[#menuItems])
                return true
            end
            -- Cancel the list and let the caret move up.
            editor:AutoCCancel()
        end
    elseif key == 0x28 then -- VK_DOWN
        if editor.AutoCCurrent == lastAutoCItem then
            -- User pressed DOWN when already at the bottom of the list.
            if WRAP_ARROW_KEYS then
                -- Select the first item.
                editor:AutoCSelect(menuItems[1])
                return true
            end
            -- Cancel the list and let the caret move down.
            editor:AutoCCancel()
        end
    elseif key == 0x5A and ctrl then -- ^z
        editor:AutoCCancel()
    end
end



-- Event handlers
local events = {
    OnChar          = handleChar,
    OnKey           = handleKey,
    OnSwitchFile    = function()
        -- 不同文件的 buffer 值是唯一的，因此用它来缓存对应文件的关键字。
        if not buffer.namesCache then
            --[[
                打开或切换一个文件时，正常的事件顺序是 OnOpen OnSwitchFile 。
                但当打开 SciTE 时，已经打开了一个 lua 文件，那么事件被激活的顺序会是 OnSwitchFile OnOpen 。
                由于 OnSwitchFile 先被激活，此时 editor.TextLength 的值就会是0。
                所以此时 buildNames() 无法获得正确结果。
                因此需要跳过，在 OnOpen 事件中再处理。
            --]]
            if editor.TextLength > 0 then
                if DEBUG_MODE then print("OnSwitchFile_no_cache|   endpos:"..editor.TextLength) end
                -- Otherwise, build a new list.
                buildNames()
                saveCache()
                buffer.namesCache = true
            end
        else
            if DEBUG_MODE then print("OnSwitchFile_have_cache|   endpos:"..editor.TextLength) end
            loadCache()
        end
    end,
    OnOpen          = function()
        -- Ensure the document is styled first, so we can filter out
        -- words in comments and strings.
        editor:Colourise(0, editor.Length)
        -- Then do the real work.
        if not buffer.namesCache then
            if DEBUG_MODE then print("OnOpen_no_cache|   endpos:"..editor.TextLength) end
            -- Otherwise, build a new list.
            buildNames()
            saveCache()
            buffer.namesCache = true
        else
            if DEBUG_MODE then print("OnOpen_have_cache|   endpos:"..editor.TextLength) end
            loadCache()
        end
    end
}
-- Add event handlers in a cooperative fashion:
for evt, func in pairs(events) do
    local oldfunc = _G[evt]
    if oldfunc then
        _G[evt] = function(...) return func(...) or oldfunc(...) end
    else
        _G[evt] = func
    end
end
