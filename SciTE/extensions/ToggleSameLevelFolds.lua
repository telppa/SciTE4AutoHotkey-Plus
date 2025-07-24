-- 手动实现按位与（兼容 SciTE 内置 Lua）
function band(a, b)
  local result = 0
  local bitval = 1
  while a > 0 or b > 0 do
    if (a % 2 == 1) and (b % 2 == 1) then
      result = result + bitval
    end
    a = math.floor(a / 2)
    b = math.floor(b / 2)
    bitval = bitval * 2
  end
  return result
end

-- 从光标行向上查找最近的折叠头行
function find_nearest_fold_header(startLine)
  local SC_FOLDLEVELHEADERFLAG = 0x2000
  for line = startLine, 0, -1 do
    local foldLevel = editor.FoldLevel[line]
    if band(foldLevel, SC_FOLDLEVELHEADERFLAG) ~= 0 then
      return line
    end
  end
  return nil
end

-- 切换与光标行所在“折叠头”同层级的所有折叠块
function ToggleFoldSameLevel()
  local SC_FOLDLEVELNUMBERMASK = 0x0FFF
  local SC_FOLDLEVELHEADERFLAG = 0x2000
  local SC_FOLDACTION_CONTRACT = 0
  local SC_FOLDACTION_EXPAND = 1

  local pos = editor.CurrentPos
  local cursorLine = editor:LineFromPosition(pos)
  local headerLine = find_nearest_fold_header(cursorLine)
  if not headerLine then
    print("未找到向上最近的折叠头行。")
    return
  end

  local targetLevel = band(editor.FoldLevel[headerLine], SC_FOLDLEVELNUMBERMASK)
  local targetAction = editor.FoldExpanded[headerLine] and SC_FOLDACTION_CONTRACT or SC_FOLDACTION_EXPAND

  local maxLine = editor.LineCount - 1
  local count = 0

  for line = 0, maxLine do
    local foldLevel = editor.FoldLevel[line]
    if band(foldLevel, SC_FOLDLEVELNUMBERMASK) == targetLevel and band(foldLevel, SC_FOLDLEVELHEADERFLAG) ~= 0 then
      editor:FoldLine(line, targetAction)
      count = count + 1
    end
  end

  local actionName = (targetAction == SC_FOLDACTION_CONTRACT) and "折叠" or "展开"
  print("已" .. actionName .. "层级为 " .. targetLevel .. " 的 " .. count .. " 个折叠头（以第 " .. (headerLine + 1) .. " 行为基准）")
end
