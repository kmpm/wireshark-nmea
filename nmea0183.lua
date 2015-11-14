--
-- Copyright 2015 Peter Magnusson <peter@birchroad.net>

-- Licensed under the Apache License, Version 2.0 (the "License");
-- you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at

--    http://www.apache.org/licenses/LICENSE-2.0

-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.

function split (s, pattern, maxsplit)
  local pattern = pattern or ' '
  local maxsplit = maxsplit or -1
  local s = s
  local t = {}
  local patsz = #pattern
  while maxsplit ~= 0 do
    local curpos = 1
    local found = string.find(s, pattern)
    if found ~= nil then
      table.insert(t, string.sub(s, curpos, found - 1))
      curpos = found + patsz
      s = string.sub(s, curpos)
    else
      table.insert(t, string.sub(s, curpos))
      break
    end
    maxsplit = maxsplit - 1
    if maxsplit == 0 then
      table.insert(t, string.sub(s, curpos - patsz - 1))
    end
  end
  return t
end


function keep(s, pattern)
  local t = {}                   -- table to store the indices
  local pos = 0
  local a, b

  while true do
    a, b = string.find(s, pattern, pos+1)    -- find 'next' pattern
    if a == nil then break end
    pos = b
    --print('pos:' .. tostring(pos) .. 'a:' .. tostring(a) .. 'b:' .. tostring(b) )
    local m = {
      first = a,
      last = b,
      text = string.sub(s, a, b)
    }
    table.insert(t, m)
  end
  return t
end

--
-- return empty string if v == nil
-- function ts(v)
--   if (ts == nil) then
--     return ''
--   else
--     return tostring(v)
--   end
-- end


--
-- lookap a index in list, if missing return index .. '?'
function lookup(list, index)
  v = list[index]
  if (v == nil) then
    return index .. '?'
  end
  return v
end

function toNext(buffer, offset, s)
  local pos
  s = s or '[,*]'
  pos = 0
  local r
  local result = ''
  local buflen = buffer:len()
  while true and (offset + pos) < buflen do
    r = buffer(offset + pos, 1):string()
    if string.find(r, s) ~= nil or r == nil then break end
    pos = pos + 1
    result = result .. tostring(r)
  end
  return pos, result
end

do
  NMEAPROTO = Proto("NMEA0183", "NMEA 0183 Packet")
  NMEASENTENCE = Proto('NMEA', 'NMEA Sentence')
  --local bitw = require("bit")
  local fp = NMEAPROTO.fields
  local fm = NMEASENTENCE.fields

  fp.count = ProtoField.uint8('nmea.count', 'Sentences in packet')

  fm.sentence = ProtoField.string("nmea.sentence.data", "Sentence")
  fm.tag = ProtoField.string('nmea.sentence.tag', 'Tag')
  fm.field = ProtoField.string('nmea.sentence.field', 'Field')
  -- fp.talker = ProtoField.string('nmea.message.talker', 'Talker')
  -- fp.msgtype = ProtoField.string('nmea.message.type', 'Type')
  -- fp.payload = ProtoField.string('nmea.message.payload', 'Payload')
  -- fp.checksum = ProtoField.string('nmea.message.checksum', 'Checksum')




  local talkers = {}
  local types = {}
  talkers['GP'] = 'GPS Receiver'
  talkers['SD'] = 'Depth Sounder'

  types['APB'] = 'Autopilot Sentence "B"'
  types['DBT'] = 'Depth below transducer'
  types['DPT'] = 'Depth of Water'
  types['GGA'] = 'GPS Fix Data'
  types['GSA'] = 'GPS DOP and active satellites'
  types['GSV'] = 'Satellites in view'
  types['GLL'] = 'Geographic Position - Latitude/Longitude'
  types['MTW'] = 'Mean Temperature of Water'
  types['RMB'] = 'Recommended Minimum Navigation Information'
  types['RMC'] = 'Recommended Minimum Navigation Information'
  types['VHW'] = 'Water speed and heading'
  types['VLW'] = 'Distance Traveled through Water'

  function parseSentence(tree, buffer, offset, length)
    local last = offset + length
    --offset = offset + 1 --skip '$'
    local state = 'tag'
    local s, l, value
    while offset < last do
      if (state == 'tag') then
        l, value = toNext(buffer, offset)
        s = tree:add(fm.tag, buffer(offset, l))
        s:append_text(' # ' .. lookup(talkers, string.sub(value, 1, 2)))
        s:append_text(', ' .. lookup(types, string.sub(value, 3)))
        offset = offset + l + 1
        state = 'field'
      end

      if (state == 'field') then
        l, value = toNext(buffer, offset)
        tree:add(fm.field, buffer(offset, l))
        if (l ~= 0) then
          offset = offset + l + 1
        else
          offset = offset + 1
        end
      end
      if (offset > last - 4) then
        break
      end
    end
  end

  -- The dissector
  function NMEAPROTO.dissector(buffer, pinfo, tree)
    pinfo.cols.protocol = "NMEA0183"
    local msg_pattern = '%$[%w,%.]+*%x%x'
    local fields_pattern = ''
    local st
    local final = buffer:len()
    --forward to first '$'
    local offset = 0
    while buffer(offset, 1):string()~= '$' and offset < final do
      offset = offset + 1
    end

    local subtree = tree:add(NMEAPROTO, buffer(offset))
    local mo, fields
    local t = keep(buffer(offset):string(), msg_pattern)
    subtree:add(fp.count, #t)
    for index, message in ipairs(t) do
      st = subtree:add(NMEASENTENCE, buffer(offset+ message.first, message.last - message.first))
      st:append_text(' ' .. index .. ', ' .. message.text)
      mo = offset + message.first
      parseSentence(st, buffer, mo, message.last - message.first)
    end
  end

  -- Register the dissector
  udp_table = DissectorTable.get("udp.port")
  udp_table:add(2000, NMEAPROTO)
end
