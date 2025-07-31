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

-- 从光标行向上查找对应的折叠头行
function find_nearest_fold_header(startLine)
  local SC_FOLDLEVELHEADERFLAG = 0x2000
  local SC_FOLDLEVELNUMBERMASK = 0x0FFF

  -- 如果当前行本身是折叠头，直接返回
  local startLineFoldLevel = editor.FoldLevel[startLine]
  if band(startLineFoldLevel, SC_FOLDLEVELHEADERFLAG) ~= 0 then
    return startLine
  end

  -- 否则向上找层级比当前行小的折叠头
  local startLineLevel = band(editor.FoldLevel[startLine], SC_FOLDLEVELNUMBERMASK)
  for line = startLine - 1, 0, -1 do
    local foldLevel = editor.FoldLevel[line]
    if band(foldLevel, SC_FOLDLEVELHEADERFLAG) ~= 0 then
      local level = band(foldLevel, SC_FOLDLEVELNUMBERMASK)
      if level < startLineLevel then
        return line
      end
    end
  end

  return nil
end

-- 折叠/展开与当前行同层级的所有折叠块，并保持视图稳定
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

  -- 记录光标行在屏幕显示中位于第几行
  local screenLine_cursor = editor:VisibleFromDocLine(cursorLine) - editor.FirstVisibleLine

  local maxLine = editor.LineCount - 1
  local count = 0

  for line = 0, maxLine do
    local foldLevel = editor.FoldLevel[line]
    if band(foldLevel, SC_FOLDLEVELNUMBERMASK) == targetLevel and band(foldLevel, SC_FOLDLEVELHEADERFLAG) ~= 0 then
      editor:FoldLine(line, targetAction)
      count = count + 1
    end
  end

  -- 延迟恢复视图（让折叠完成后再滚动）
  scite.SendEditor(SCI_SETYCARETPOLICY, 0, 0) -- 取消自动滚动
  scite.SendEditor(SCI_SETVISIBLEPOLICY, 0, 0) -- 防止强制显示某行导致跳屏
  editor:LineScroll(0, editor:VisibleFromDocLine(cursorLine) - editor.FirstVisibleLine - screenLine_cursor)

  local actionName = (targetAction == SC_FOLDACTION_CONTRACT) and "折叠" or "展开"
  print("已" .. actionName .. "层级为 " .. targetLevel .. " 的 " .. count .. " 个折叠头（以第 " .. (headerLine + 1) .. " 行为基准）")
end
