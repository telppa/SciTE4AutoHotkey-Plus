-- �ֶ�ʵ�ְ�λ�루���� SciTE ���� Lua��
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

-- �ӹ�������ϲ��Ҷ�Ӧ���۵�ͷ��
function find_nearest_fold_header(startLine)
  local SC_FOLDLEVELHEADERFLAG = 0x2000
  local SC_FOLDLEVELNUMBERMASK = 0x0FFF

  -- �����ǰ�б������۵�ͷ��ֱ�ӷ���
  local startLineFoldLevel = editor.FoldLevel[startLine]
  if band(startLineFoldLevel, SC_FOLDLEVELHEADERFLAG) ~= 0 then
    return startLine
  end

  -- ���������Ҳ㼶�ȵ�ǰ��С���۵�ͷ
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

-- �۵�/չ���뵱ǰ��ͬ�㼶�������۵��飬��������ͼ�ȶ�
function ToggleFoldSameLevel()
  local SC_FOLDLEVELNUMBERMASK = 0x0FFF
  local SC_FOLDLEVELHEADERFLAG = 0x2000
  local SC_FOLDACTION_CONTRACT = 0
  local SC_FOLDACTION_EXPAND = 1

  local pos = editor.CurrentPos
  local cursorLine = editor:LineFromPosition(pos)
  local headerLine = find_nearest_fold_header(cursorLine)
  if not headerLine then
    print("δ�ҵ�����������۵�ͷ�С�")
    return
  end

  local targetLevel = band(editor.FoldLevel[headerLine], SC_FOLDLEVELNUMBERMASK)
  local targetAction = editor.FoldExpanded[headerLine] and SC_FOLDACTION_CONTRACT or SC_FOLDACTION_EXPAND

  -- ��¼���������Ļ��ʾ��λ�ڵڼ���
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

  -- �ӳٻָ���ͼ�����۵���ɺ��ٹ�����
  scite.SendEditor(SCI_SETYCARETPOLICY, 0, 0) -- ȡ���Զ�����
  scite.SendEditor(SCI_SETVISIBLEPOLICY, 0, 0) -- ��ֹǿ����ʾĳ�е�������
  editor:LineScroll(0, editor:VisibleFromDocLine(cursorLine) - editor.FirstVisibleLine - screenLine_cursor)

  local actionName = (targetAction == SC_FOLDACTION_CONTRACT) and "�۵�" or "չ��"
  print("��" .. actionName .. "�㼶Ϊ " .. targetLevel .. " �� " .. count .. " ���۵�ͷ���Ե� " .. (headerLine + 1) .. " ��Ϊ��׼��")
end
