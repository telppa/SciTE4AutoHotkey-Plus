-- 自动完成增强版 v1.0
-- base on AutoComplete v0.8 by Lexikos
-- https://gist.github.com/Lexikos/bc17b8d55ae8a8102e35

-- 更新日志：
-- 修复了Lexikos的关键字砍头、取词长度不正确、api文件不存在会报错的bug。
-- 实现了中文、英文（应该也包括韩文日文等）关键字的提示。
-- 实现了实时提取关键字（原版仅在打开文件时提取），解决了实时提取关键字的性能问题。
-- 改进了自动完成框的闪烁问题。
-- 实现了跨文件关键字共享，但默认关闭了这个功能。
-- lua也可以自动完成。

-- 可以继续改进的地方：
-- 自动完成框显示出的内容不变（滚动条下面的变化无所谓，反正看不见）就可以不刷新。这将进一步降低闪烁问题。
-- 最完美的实时提取关键字应该是实时全文件更新，但这样会有性能问题。
-- 比较折衷的方式是抓取文件所有被修改的的行，然后进行处理，但目前暂做不到。
-- 原来的自动完成可以直接匹配“.”开头的关键字，现在只能间接匹配。

-- List of styles per lexer that autocomplete should not occur within.
-- 不在下面样式列表中提取关键字。
local IGNORE_STYLES = { -- Should include comments, strings and errors.
    [SCLEX_AHK1] = {1,2,3,6,20},
    [SCLEX_AHK2] = {1,2,3,5,15},
    [SCLEX_LUA]  = {1,2,3,6,7,8,12}
}
-- 不在下面样式列表中进行花括号自动缩进。
local ignoreStylesTable = {
    [SCLEX_AHK1] = {SCE_AHK_COMMENTLINE, SCE_AHK_COMMENTBLOCK, SCE_AHK_STRING, SCE_AHK_ERROR, SCE_AHK_ESCAPE},
    [SCLEX_AHK2] = {SCE_AHK2_COMMENTLINE, SCE_AHK2_COMMENTBLOCK, SCE_AHK2_STRING, SCE_AHK2_ERROR, SCE_AHK2_ESCAPE},
}

local SHARING_KEYWORDS_BETWEEN_FILES = false   -- 跨文件关键字共享。比如同时打开A、B两个文件，A文件中抓到的关键字“haha”，在B文件中也可以提示。
local INCREMENTAL = true    -- 根据关键字变化不断减少自动完成列表内容。false则和SciTE原版一致，只变动光标，不改变列表。
local IGNORE_CASE = true    -- 关键字匹配时忽略大小写
local CASE_CORRECT = true   -- 自动纠正大小写
local CASE_CORRECT_INSTANT = false
local WRAP_ARROW_KEYS = false
local CHOOSE_SINGLE = props["autocomplete.choose.single"]

-- Number of chars to type before the autocomplete list appears:
local MIN_PREFIX_LEN = 1    -- 最少输入几个字符后，开始匹配自动完成列表。
-- Length of shortest word to add to the autocomplete list:
local MIN_IDENTIFIER_LEN = 3    -- 添加到自动完成列表的关键字的最小长度（不影响从“ahk.api”添加关键字的长度）。
-- List of regex patterns for finding suggestions for the autocomplete menu:
-- 这个表达式的本质，就是通过排除ASCII码表的字符，来构建一个字符组。
-- 特别注意，这个表达式是给“editor:findtext()”使用的，那么看起来应该遵循SciTE的正则语法。
-- 可是实际上它是调用的lua，并且默认大小写不敏感，即使指定“SCFIND_REGEXP”参数也如此！！！
-- 因此还需要手动加上“SCFIND_MATCHCASE”参数！！！！！！！！！！！！！！！！！！！！！！！
-- [^\1-\64\91-\94\96\123-\127] 在ASCII码表中等于 [a-zA-Z_] 但因为使用了排除的形式，所以可以匹配到中文。
-- [^\1-\47\58-\64\91-\94\96\123-\127] 在ASCII码表中等于 [a-zA-Z0-9_] 但因为使用了排除的形式，所以可以匹配到中文。
-- 因此整个表达式的意思就是{"[a-zA-Z_中文日文韩文][a-zA-Z0-9_中文日文韩文]+"}
-- 需要注意的是，如果在SciTE编辑器中使用这个表达式，需要把\1替换为\x00。
-- 原因是\0 也就是空字符会让lua出错，因此lua使用这个表达式就必须从\1开始。
-- 另一个需要注意的地方是，这个表达式会同样匹配到中文的标点，例如“，”“。”等等。
-- 之所以这里让它匹配到标点的原因是，lua和scite都不支持unicode字符的匹配，因此难以单独只匹配汉字。
-- 另一个原因则是，实际上在代码中，你是可以用中文标点作为变量名的，加上表达式被限制为不在注释等地方匹配，因此确实可以匹配到正确结果。
-- 这是SciTE编辑器中Ctrl+F使用的版本 {"[^\x00-\x40\x5B-\x5E\x60\x7B-\x7F][^\x00-\x2F\x3A-\x40\x5B-\x5E\x60\x7B-\x7F]+"}
local IDENTIFIER_PATTERNS = {"[^\1-\64\91-\94\96\123-\127][^\1-\47\58-\64\91-\94\96\123-\127]+"}

-- Override settings that interfere with this script:
props["autocomplete.ahk1.start.characters"] = ""
props["autocomplete.ahk2.start.characters"] = ""

-- This feature is very awkward when combined with automatic popups:
props["autocomplete.choose.single"] = "0"


-- 不区分大小写的话，normalize函数就直接大写取到的字符。
-- 将大写后的字符存为key，可以避免重复记录“word” “Word”这样的单词。
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
            return isInTable(IGNORE_STYLES[editor.Lexer], editor.StyleAt[pos])
        end
    else
        -- Optional: Disable autocomplete popups for unknown lexers.
        shouldIgnorePos = function(pos) return true end
    end
end


local names = {}
local unique = {}   -- 让unique持久的储存数据。这个对象是以unique["key"]=value 形式储存值的，所以key都是唯一的。
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
    setLexerSpecificStuff()   -- 获取需要忽略的样式的坐标，例如所有注释部分的坐标。
    local startPos, endPos
    endPos = _startPos - 1   -- 修复了Lexikos的bug，这里必须 -1 ，否则文首抓到的关键字会被砍头“msgbox”变“sgbox”。
    -- Collect all words matching the given patterns. 根据规则提取关键字。
    for i, pattern in ipairs(IDENTIFIER_PATTERNS) do
        while true do
            -- SCFIND_REGEXP 表示使用正则表达式去匹配。默认大小写不敏感，因此需要手动加上大小写敏感的参数 SCFIND_MATCHCASE！
            startPos, endPos = editor:findtext(pattern, SCFIND_REGEXP + SCFIND_MATCHCASE, endPos + 1)
            if (not startPos) or (endPos > _endPos) then
                break
            end
            -- 匹配到的内容不在注释中
            if not shouldIgnorePos(startPos) then
                if endPos-startPos >= MIN_IDENTIFIER_LEN then   -- 修复了Lexikos的bug。原版是“endPos-startPos+1”。
                    -- Create one key-value pair per unique word:
                    local name = editor:textrange(startPos, endPos)
                    print("本次取到的关键字："..name)
                    unique[normalize(name)] = name    -- normalize 在忽略大小写的情况下，实际上是把所有单词最大化了一遍，以避免重复添加单词。
                end
            end
        end
    end
end
local function buildApiNames()  -- 从“ahk.api”和“user\user.ahk.api”文件中取关键字。
    local apiFiles = props["APIPath"] or ""
    apiFiles:gsub("[^;]+", function(apiFile) -- For each in ;-delimited list. 删除“;”之外的字符，也就是删得只剩分隔符“;”了。
        if FileExists(apiFile) then   -- 文件存在再进行操作。不然会报错找不到文件。
            for name in io.lines(apiFile) do
                name = name:gsub("[\(, ].*", "") -- Discard parameters/comments. 删除“(, ”左括号、逗号、空格及其后面的全部字符。
                if string.len(name) > 0 then
                    unique[normalize(name)] = name    -- This also "case-corrects"; e.g. "gui" -> "Gui".
                end
                if string.sub(name, 0, 1) == "." then   -- 把“.MaxIndex”再存一遍“MaxIndex”形式的。
                    name = string.sub(name, 2)
                    unique[normalize(name)] = name
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
    -- 从API文件创建关键字
    buildApiNames()
    -- 从当前打开文件创建关键字
    buildDocNames()
    -- 将关键字转为自动完成列表
    unique2names()
end


local notempty = next
local lastAutoCItem = 0 -- Used by handleKey().
local menuItems
local list_old = ""   -- 储存旧的list的值，用于和新的list做对比，没变化就不刷新列表，降低闪烁。
local function handleChar(char, calledByHotkey)
    print("--------------------")
    -- This function should only run when the Editor pane is focused.
    if not editor.Focus then return false end
    if not INCREMENTAL and editor:AutoCActive() then
        -- Nothing to do.
        return false
    end
    local ignoreStyles = ignoreStylesTable[editor.Lexer]

    -- 行模式的意义就是——关键字在换行后就被实时创建，同时又不会因为每次更新关键字都是全文更新而造成性能问题。
    -- 缺点就是最完美的做法实际上是获取文件所有被修改的行，然后提取这些行的关键字。
    -- 但目前的做法是提取按了回车的那一行，这当然包括了大部分代码被修改的情况，但显然修改某行后，鼠标点走的情况没被包括在内。
    if char == "\n" then
        -- 获取按下回车时的那行的首尾坐标。
        local line_num = editor:LineFromPosition(editor.CurrentPos)
        local line_start = editor:PositionFromLine(line_num-1)
        local line_end = editor.LineEndPosition[line_num-1]
        -- 这里是更新unique，所以不要去清空unique。
        buildNamesFromPos(line_start, line_end)
        unique2names()
        saveCache()
        -- 自动缩进
        local prevStyle = editor.StyleAt[getPrevLinePos()]
        if not isInTable(ignoreStyles, prevStyle) then
            return AutoIndent_OnNewLine()   -- fincs原版这里就用的return。
        end
    elseif char == "{" then
        local curStyle = editor.StyleAt[editor.CurrentPos-2]
        if not isInTable(ignoreStyles, curStyle) then
            AutoIndent_OnOpeningBrace()
        end
    elseif char == "}" then
        local curStyle = editor.StyleAt[editor.CurrentPos-2]
        if not isInTable(ignoreStyles, curStyle) then
            AutoIndent_OnClosingBrace()
        end
    end

    local pos = editor.CurrentPos
    local startPos = editor:WordStartPosition(pos, true)
    local len = pos - startPos
    if len < MIN_PREFIX_LEN then
        if editor:AutoCActive() then
            if len == 0 then
            print(1)
                -- Happens sometimes after typing ")".
                editor:AutoCCancel()
                return
            end
            -- Otherwise, autocomplete is already showing so may as well
            -- keep it updated even though len < MIN_PREFIX_LEN.
        else
            if char then
            print(2)
                -- Not enough text to trigger autocomplete, so return.
                return
            end
            -- Otherwise, we were called explicitly without a param.
        end
    end
    if not editor:AutoCActive() then
    print(3)
        -- 由于自动完成可以通过包括但不限于 中途{enter}、中途{tab}、全部输完等方式完成。
        -- 为了避免bug也为了避免到处去清空list_old，因此统一在只要没有自动完成框时就清空旧变量！
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
        -- 这里字符开始插入自动完成框了。
        -- 字符串是可以比较大小的，“ABC”是大于“ABB”的。
        -- 当我们输入“ms”时，names会被遍历，直到“Multi”时停下，因为在names中，Multi就是MsgBox的下一个关键字。
        -- 之所以要在下一个关键字的地方停下，是因为列表被排序过，比如为了完整获取所有“gui”开头的关键字，那么就得在“guj”停下。
        if s >= prefix then   -- 大于等于用得很巧妙。等于时 代表关键字匹配，大于时 代表匹配完了，可以跳出。
            if s == prefix then
                table.insert(menuItems, name)   -- 这里已经把所有匹配的关键字全部存入menuItems了。
            else
                break -- There will be no more matches.
            end
        end
    end
    print("3.1|匹配列表："..table.concat(menuItems, "\1"))
    if notempty(menuItems) then
    print(4)
        -- Show or update the auto-complete list.
        local list = table.concat(menuItems, "\1")
        editor.AutoCIgnoreCase = IGNORE_CASE
        editor.AutoCCaseInsensitiveBehaviour = 1 -- Do NOT pre-select a case-sensitive match
        editor.AutoCSeparator = 1
        editor.AutoCMaxHeight = 5
        -- if not editor:AutoCActive() then   -- 另一种降低闪烁的方式，和SciTE原版一样，只要自动完成框出现了，就只跳转位置而不刷新。
        if list~=list_old then    -- 降低自动完成框的闪烁，只有匹配的关键字发生变化时才刷新。
        print(5)
            editor:AutoCShow(len, list)
            list_old=list
        end
        -- Check if we should auto-auto-complete.
        if normalize(menuItems[1]) == prefix and not calledByHotkey then
            -- User has completely typed the only item, so cancel.
            if CASE_CORRECT then
                if CASE_CORRECT_INSTANT or #menuItems == 1 then
                print(6)
                    -- Make sure the correct item is selected.
                    editor:AutoCShow(len, menuItems[1])
                    editor:AutoCComplete()
                end
                if #menuItems > 1 then
                print(7)
                    editor:AutoCShow(len, list)
                end
            end
            if #menuItems == 1 then
            print(8)
                editor:AutoCCancel()
                return
            end
        end
        lastAutoCItem = #menuItems - 1
        if lastAutoCItem == 0 and calledByHotkey and CHOOSE_SINGLE then
        print(9)
            editor:AutoCComplete()
        end
    else
        -- No relevant items.
        if editor:AutoCActive() then
        print(10)
            editor:AutoCCancel()
        end
    end
    -- 不让其它OnChar函数继续处理，否则会造成中文关键字显示被打断。
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
        -- 不同文件的buffer值是唯一的，因此用它来缓存对应文件的关键字。
        if not buffer.namesCache then
            -- 打开或切换一个文件时，正常的事件顺序是OnOpen、OnSwitchFile。
            -- 但当打开SciTE时，已经打开了一个ahk文件，那么事件被激活的顺序会是OnSwitchFile、OnOpen。
            -- 由于OnSwitchFile先被激活，此时editor.TextLength的值就会是0。
            -- 所以此时buildNames()无法获得正确结果。
            -- 因此需要跳过，在OnOpen事件中再处理。
            if editor.TextLength > 0 then
                -- Otherwise, build a new list.
                print("OnSwitchFile_no_cache|   endpos:"..editor.TextLength)
                buildNames()
                saveCache()
                buffer.namesCache = true
            end
        else
            print("OnSwitchFile_have_cache|   endpos:"..editor.TextLength)
            loadCache()
        end
    end,
    OnOpen          = function()
        -- Ensure the document is styled first, so we can filter out
        -- words in comments and strings.
        editor:Colourise(0, editor.Length)
        -- Then do the real work.
        if not buffer.namesCache then
            print("OnOpen_no_cache|   endpos:"..editor.TextLength)
            -- Otherwise, build a new list.
            buildNames()
            saveCache()
            buffer.namesCache = true
        else
            print("OnOpen_have_cache|   endpos:"..editor.TextLength)
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
