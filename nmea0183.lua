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
  talkers['AB'] = 'Independent AIS Base Station'
  talkers['AD'] = 'Dependant AIS Base Station'
  talkers['AG'] = 'Autopilot - General'
  talkers['AI'] = 'Mobile AIS Station'
  talkers['AN'] = 'Aid to Navigation AIS Station'
  talkers['AR'] = 'AIS Receiving Station'
  talkers['AS'] = 'AIS Limited Base Station'
  talkers['AT'] = 'AIS Transmitting Station'
  talkers['AX'] = 'Repeater AIS Station'
  talkers['AI'] = 'Mobile AIS Station'
  talkers['AP'] = 'Autopilot - Magnetic'
  talkers['BD'] = 'Beidou Positioning System Receiver'
  talkers['BN'] = 'Bridge Navigational Watch Alarm System (BNWAS)'
  talkers['CD'] = 'Global Maritime Distress and Safety System - Digital Selective Calling (DSC)'
  talkers['CR'] = 'Communications - Data Receiver'
  talkers['CS'] = 'Communications - Satellite'
  talkers['CT'] = 'Communications - Radio-Telephone MF-HF'
  talkers['CV'] = 'Communications - Radio-Telephone VHF'
  talkers['CX'] = 'Communications - Scanning Receiver'
  talkers['DE'] = 'Decca navigator'
  talkers['DF'] = 'Radio Direction Finder'
  talkers['DM'] = 'Velocity Sensor, Speed Log, Water, Magnetic'
  talkers['DU'] = 'Duplex Repeater Station'
  talkers['EC'] = 'Electronic Chart Displays and Information System (ECDIS)'
  talkers['EP'] = 'Emergency Position Indicating Beacon (EPIRB)'
  talkers['ER'] = 'Engine Room Monitoring Systems'
  talkers['FR'] = 'Franson software'
  talkers['GA'] = 'Galileo positioning system receiver'
  talkers['GB'] = 'Beidou positioning system receiver'
  talkers['GC'] = 'Unknown positioning system receiver'
  talkers['GL'] = 'Glonass Positioning System Receiver'
  talkers['GN'] = 'Mixed GPS and GLONASS data'
  talkers['GP'] = 'Global Positioning System Receiver (GPS)'
  talkers['GY'] = 'Global Positioning System Receiver (GPS)'
  talkers['HC'] = 'Heading - Magnetic Compass'
  talkers['HE'] = 'Heading - North Seeking Gyro'
  talkers['HN'] = 'Heading - Non North Seeking Gyro'
  talkers['II'] = 'Integrated Instrumention'
  talkers['IN'] = 'Integrated Navigation'
  talkers['IO'] = 'Input Output Information'
  talkers['NA'] = 'Navigation - Unknown'
  talkers['NL'] = 'Navigation Light Controller'
  talkers['NW'] = 'Navigation - Unknown'
  talkers['PA'] = 'Vendor Specific / Rhotheta'
  talkers['PB'] = 'Vendor Specific'
  talkers['PC'] = 'Vendor Specific'
  talkers['PD'] = 'Vendor Specific'
  talkers['PE'] = 'Vendor Specific'
  talkers['PF'] = 'Vendor Specific'
  talkers['PG'] = 'Vendor Specific / Garmin'
  talkers['PH'] = 'Vendor Specific / IxBlue'
  talkers['PI'] = 'Vendor Specific'
  talkers['PJ'] = 'Vendor Specific'
  talkers['PK'] = 'Vendor Specific'
  talkers['PL'] = 'Vendor Specific'
  talkers['PM'] = 'Vendor Specific / Magellan'
  talkers['PN'] = 'Vendor Specific'
  talkers['PO'] = 'Vendor Specific'
  talkers['PP'] = 'Vendor Specific'
  talkers['PQ'] = 'Vendor Specific'
  talkers['PR'] = 'Vendor Specific / Rockwell'
  talkers['PS'] = 'Vendor Specific / Miniplex'
  talkers['PT'] = 'Vendor Specific'
  talkers['PU'] = 'Vendor Specific / u-blox'
  talkers['PV'] = 'Vendor Specific'
  talkers['PW'] = 'Vendor Specific'
  talkers['PX'] = 'Vendor Specific'
  talkers['PY'] = 'Vendor Specific'
  talkers['PZ'] = 'Vendor Specific'
  talkers['QZ'] = 'QZSS regional GPS augmentation system'
  talkers['RA'] = 'RADAR and/or ARPA (RADAR plotting)'
  talkers['SA'] = 'AIS Physical Shore AIS Station'
  talkers['SD'] = 'Depth Sounder'
  talkers['SE'] = 'True Heading'
  talkers['SN'] = 'Electronic Positioning System other - general'
  talkers['SP'] = 'Speed Sensor'
  talkers['SS'] = 'Scanning Sounder'
  talkers['ST'] = 'Skytraq debug output'
  talkers['TI'] = 'Turn Rate Indicator'
  talkers['TR'] = 'TRANSIT Navigation System'
  talkers['U0'] = 'User Configured 0'
  talkers['U1'] = 'User Configured 1'
  talkers['U2'] = 'User Configured 2'
  talkers['U3'] = 'User Configured 3'
  talkers['U4'] = 'User Configured 4'
  talkers['U5'] = 'User Configured 5'
  talkers['U6'] = 'User Configured 6'
  talkers['U7'] = 'User Configured 7'
  talkers['U8'] = 'User Configured 8'
  talkers['U9'] = 'User Configured 9'
  talkers['UP'] = 'Microprocessor Controller'
  talkers['VD'] = 'Velocity Sensor, Doppler, other/general'
  talkers['VM'] = 'Velocity Sensor, Magnetic'
  talkers['VR'] = 'Voyage Data Recorder'
  talkers['VW'] = 'Velocity Sensor, Speed Log, Water, Mechanical'
  talkers['WI'] = 'Weather Instruments'
  talkers['YX'] = 'Transducer'
  talkers['ZA'] = 'Timekeeper - Atomic Clock'
  talkers['ZC'] = 'Timekeeper - Chronometer'
  talkers['ZQ'] = 'Timekeeper - Quartz'
  talkers['ZV'] = 'Timekeeper - Radio Update, WWV or WWVH'

  types['AAM'] = 'Waypoint arrival alarm'
  types['ACK'] = 'Alarm acknowledgment'
  types['ADS'] = 'Automatic device status'
  types['AKD'] = 'Acknowledge detail alarm condition'
  types['ALA'] = 'Set detail alarm condition'
  types['ALM'] = 'GPS almanac data'
  types['ALR'] = 'Set alarm state'
  types['APA'] = 'Heading/track controller (Autopilot) Sentence "A"'
  types['APB'] = 'Heading/track controller (Autopilot) Sentence "B"'
  types['ASD'] = 'Autopilot system data'
  types['BEC'] = 'Bearing and distance to waypoint, dead reckoning'
  types['BOD'] = 'Bearing, origin to destination'
  types['BWC'] = 'Bearing and distance to waypoint, great circle'
  types['BWR'] = 'Bearing and distance to waypoint, rhumb line'
  types['BWW'] = 'Bearing, waypoint to waypoint'
  types['CEK'] = 'Configure encryption key command'
  types['CMP'] = 'OCTANS latitude and speed'
  types['COP'] = 'Configure the operational period, command'
  types['CUR'] = 'Water current layer'
  types['DBK'] = 'Depth below keel'
  types['DBS'] = 'Depth below surface'
  types['DBT'] = 'Depth below transducer'
  types['DCN'] = 'Decca position'
  types['DCR'] = 'Device capability report'
  types['DDC'] = 'Device dimming control'
  types['DOR'] = 'Door status detection'
  types['DPT'] = 'Depth of Water'
  types['DSC'] = 'Digital Selective Calling information'
  types['DSE'] = 'Extended Digital Selective Calling'
  types['DSI'] = 'Digital Selective Calling transponder initiate'
  types['DSR'] = 'Digital Selective Calling transponder response'
  types['DTM'] = 'Datum Reference'
  types['ETL'] = 'Engine Telegraph Operation Status'
  types['EVE'] = 'General Event Message'
  types['FIR'] = 'Fire detetction'
  types['FSI'] = 'Frequency set information'
  types['GBS'] = 'GNSS satellite fault detection'
  types['GGA'] = 'GPS Fix Data'
  types['GLL'] = 'Geographic Position - Latitude/Longitude'
  types['GNS'] = 'GNSS fix data'
  types['GRS'] = 'GNSS range residuals'
  types['GSA'] = 'GNSS DOP and active satellites'
  types['GST'] = 'GNSS pseudo range error statistics'
  types['GSV'] = 'GNSS satellites in view'
  types['GTD'] = 'Geographic location in time differences'
  types['HDG'] = 'Heading, deviation and variation'
  types['HDM'] = 'Heading, magnetic'
  types['HDT'] = 'Heading, true'
  types['HFB'] = 'Trawl headrope to footrope and bottom'
  types['HMR'] = 'Heading monitor - receive'
  types['HMS'] = 'Heading monitor - set'
  types['HSC'] = 'Heading steering command'
  types['HTC'] = 'Heading track control command'
  types['HTD'] = 'Heading track control data'
  types['INF'] = 'OCTANS status'
  types['ITS'] = 'Trawl door spread to distance'
  types['LIN'] = 'OCTANS surge, sway and heave'
  types['MDA'] = 'Meteorological composite'
  types['MLA'] = 'GLONASS almanac data'
  types['MSK'] = 'MSK control for a beacon receiver'
  types['MSS'] = 'MSK beacon receiver status'
  types['MWD'] = 'Wind direction and speed'
  types['MWV'] = 'Wind speed and angle'
  types['MTW'] = 'Mean temperature of water'
  types['MWD'] = 'Mean wind direction and speed'
  types['MWV'] = 'Mean wind speed and angle'
  types['NST'] = 'Magellan status'
  types['OSD'] = 'Own ship data'
  types['RMA'] = 'Recommended minimum navigation information'
  types['RMB'] = 'Recommended minimum navigation information'
  types['RMC'] = 'Recommended minimum GNSS navigation information'
  types['RME'] = 'Garmin estimated error'
  types['RME'] = 'Garmin altitude'
  types['ROO'] = 'Waypoints in active route'
  types['ROT'] = 'Rate of turn'
  types['RPM'] = 'Revolutions per minute'
  types['RSA'] = 'Rudder sensor angle'
  types['RSD'] = 'RADAR system data'
  types['RTE'] = 'Routes'
  types['SFI'] = 'Scanning frequency information'
  types['RSA'] = 'Rudder sensor angle'
  types['SHR'] = 'RT300 proprietary roll and pitch sentence'
  types['SPD'] = 'OCTANS speed'
  types['STN'] = 'Multiple data ID'
  types['TDS'] = 'Trawler Door Spread Distance'
  types['TFI'] = 'Trawl Filling Indicator'
  types['TLB'] = 'Target label'
  types['TLL'] = 'Target latitude and longitude'
  types['TPC'] = 'Trawl position cartesian coordinates'
  types['TPR'] = 'Trawl position relative vessel'
  types['TPT'] = 'Trawl position true'
  types['TRO'] = 'OCTANS pitch and roll'
  types['TTM'] = 'Tracked target message'
  types['TXT'] = 'Text transmission'
  types['VBW'] = 'Dual ground/water speed'
  types['VDM'] = 'AIS data message'
  types['VDO'] = 'AIS, own vessel report'
  types['VDR'] = 'Set and drift'
  types['VHW'] = 'Water speed and heading'
  types['VLW'] = 'Distance traveled through water'
  types['VPW'] = 'Speed, measured parallel to wind'
  types['VTG'] = 'Track made good and ground speed'
  types['WCV'] = 'Waypoint closure velocity'
  types['WDC'] = 'Distance to waypoint, great circle'
  types['WDR'] = 'Distance to waypoint, rhumb line'
  types['WNC'] = 'Distance, waypoint to waypoint'
  types['WPL'] = 'Waypoint location'
  types['XDR'] = 'Transducer measurements'
  types['XTE'] = 'Cross-track error, measured'
  types['XTR'] = 'Cross-track error, dead reckoning'
  types['ZDA'] = 'Time & Date - UTC, day, month, year and local time zone'
  types['ZDL'] = 'Time and distance to variable point'
  types['ZFO'] = 'UTC and time from origin waypoint'
  types['ZTG'] = 'UTC and time to destination waypoint'
  
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
    local msg_pattern = '%$[%w,%.%+%-]+*%x%x'
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
  udp_table:add(5018, NMEAPROTO)
end
