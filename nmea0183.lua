--
-- Copyright 2015 Peter Magnusson <me@kmpm.se>

-- Licensed under the Apache License, Version 2.0 (the "License");
-- you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at

--    http://www.apache.org/licenses/LICENSE-2.0

-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.

-- Original source https://github.com/kmpm/wireshark-nmea

--#region help functions

local function keep(s, pattern)
  local t = {}                   -- table to store the indices
  local pos = 0
  local a, b

  while true do
    a, b = string.find(s, pattern, pos+1)    -- find 'next' pattern
    if a == nil or b==nil then break end
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
-- lookap a index in list, if missing return index .. '?'
local function lookup(list, index)
  local v = list[index]
  if (v == nil) then
    return index .. '?'
  end
  return v
end


--
-- toNext 
local function toNext(buffer, offset, s)
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

--#endregion

--#region constants
-- 
-- Defined Talkers
local talkers = {}
talkers['AB'] = 'Independent AIS Base Station'
talkers['AD'] = 'Dependant AIS Base Station'
talkers['AG'] = 'Autopilot - General'
talkers['AI'] = 'Mobile AIS Station, Class A or B'
talkers['AN'] = 'Aid to Navigation AIS Station'
talkers['AP'] = 'Autopilot - Magnetic'
talkers['AR'] = 'AIS Receiving Station'
talkers['AS'] = 'AIS Limited Base Station'
talkers['AT'] = 'AIS Transmitting Station'
talkers['AX'] = 'AIS Simplex Repeater Station'
talkers['BD'] = 'Beidou Positioning System Receiver'
talkers['BI'] = 'Bilge Systems'
talkers['BN'] = 'Bridge Navigational Watch Alarm System (BNWAS)'
talkers['CA'] = 'Central Alarm Management'
talkers['CD'] = 'Communications - Digital Selective Calling (DSC)'
talkers['CR'] = 'Communications - Data Receiver'
talkers['CS'] = 'Communications - Satellite'
talkers['CT'] = 'Communications - Radio-Telephone MF-HF'
talkers['CV'] = 'Communications - Radio-Telephone VHF'
talkers['CX'] = 'Communications - Scanning Receiver'
talkers['DE'] = 'Decca navigator'
talkers['DF'] = 'Radio Direction Finder'
talkers['DM'] = 'Velocity Sensor, Speed Log, Water, Magnetic'
talkers['DP'] = 'Dynamic Position'
talkers['DU'] = 'Duplex Repeater Station'
talkers['EC'] = 'Electronic Chart System (ECS)'
talkers['EI'] = 'Electronic Chart Display and Information System (ECDIS)'
talkers['EP'] = 'Emergency Position Indicating Radio Beacon (EPIRB)'
talkers['ER'] = 'Engine Room Monitoring Systems'
talkers['FD'] = 'Fire Door Controller/Monitoring Point'
talkers['FE'] = 'Fire Extinguisher System'
talkers['FR'] = 'Fire Detection Point'
talkers['FR'] = 'Franson software'
talkers['FS'] = 'Fire Sprinkler System'
talkers['GA'] = 'Galileo positioning system receiver'
talkers['GB'] = 'BeiDou positioning system receiver'
talkers['GC'] = 'Unknown positioning system receiver'
talkers['GI'] = 'NavIC (IRNSS)'
talkers['GL'] = 'GLONASS Positioning System Receiver'
talkers['GN'] = 'Global Navigation Satellite System (GNSS)'
talkers['GP'] = 'Global Positioning System Receiver (GPS)'
talkers['GQ'] = 'QZSS'
talkers['GY'] = 'Global Positioning System Receiver (GPS)'
talkers['HC'] = 'Compass, Magnetic'
talkers['HD'] = 'Hull Door Controller/Monitoring Panel'
talkers['HE'] = 'Gyro, North Seeking'
talkers['HF'] = 'Fluxgate'
talkers['HN'] = 'Gyro, Non North Seeking'
talkers['HS'] = 'Hull Stress Monitoring'
talkers['II'] = 'Integrated Instrumention'
talkers['IN'] = 'Integrated Navigation'
talkers['IO'] = 'Input Output Information'
talkers['JA'] = 'Alarm and Monitoring System'
talkers['JB'] = 'Reefer Monitoring System'
talkers['JC'] = 'Power Management System'
talkers['JD'] = 'Propulsion Control System'
talkers['JE'] = 'Engine Control Console'
talkers['JF'] = 'Propulsion Boiler'
talkers['JG'] = 'Auxiliary Boiler'
talkers['JH'] = 'Electronic Governor System'
talkers['LC'] = 'Loran C'
talkers['MX'] = 'Multiplexer'
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
talkers['RB'] = 'Record Book'
talkers['RC'] = 'Propulsion Machinery Including Remote Control'
talkers['RI'] = 'Rudder Angle Indicator'
talkers['SA'] = 'Physical Shore AIS Station'
talkers['SD'] = 'Sounder, depth'
talkers['SE'] = 'True Heading'
talkers['SG'] = 'Steering Gear/Steering Engine'
talkers['SN'] = 'Electronic Positioning System other - general'
talkers['SP'] = 'Speed Sensor'
talkers['SS'] = 'Scanning Sounder'
talkers['ST'] = 'Skytraq debug output'
talkers['TC'] = 'Track Control System'
talkers['TI'] = 'Turn Rate Indicator'
talkers['TR'] = 'TRANSIT Navigation System'
talkers['U0'] = 'User Configured talker identifier 0'
talkers['U1'] = 'User Configured talker identifier 1'
talkers['U2'] = 'User Configured talker identifier 2'
talkers['U3'] = 'User Configured talker identifier 3'
talkers['U4'] = 'User Configured talker identifier 4'
talkers['U5'] = 'User Configured talker identifier 5'
talkers['U6'] = 'User Configured talker identifier 6'
talkers['U7'] = 'User Configured talker identifier 7'
talkers['U8'] = 'User Configured talker identifier 8'
talkers['U9'] = 'User Configured talker identifier 9'
talkers['UP'] = 'Microprocessor Controller'
talkers['VA'] = 'VHF Data Exchange System, ASM'
talkers['VD'] = 'Velocity Sensor, Doppler, other/general'
talkers['VM'] = 'Velocity Sensor, Speed Log, Water, Magnetic'
talkers['VR'] = 'Voyage Data Recorder'  
talkers['VS'] = 'VHF Data Exchange System, Satellite'
talkers['VT'] = 'VHF Data Exchange System, Terrestrial'
talkers['VW'] = 'Velocity Sensor, Speed Log, Water, Mechanical'
talkers['WD'] = 'Watertight Door Controller/Monitoring Panel'
talkers['WI'] = 'Weather Instruments'
talkers['YX'] = 'Transducer'
talkers['ZA'] = 'Timekeeper - Atomic Clock'
talkers['ZC'] = 'Timekeeper - Chronometer'
talkers['ZQ'] = 'Timekeeper - Quartz'
talkers['ZV'] = 'Timekeeper - Radio Update, WWV or WWVH'

-- 
-- Defined types
local types = {}
types['3SN'] = '3-S Navigation'
types['AAM'] = 'Waypoint arrival alarm'
types['AAR'] = 'Asian american resources'
types['ABK'] = 'AIS adressed binary and safety related message'
types['ACA'] = 'AIS regional channel assignment message'
types['ACE'] = 'Auto-comm engineering corp.'
types['ACF'] = 'General ATON station configuration command'
types['ACG'] = 'Extended general ATON station configuration command'
types['ACK'] = 'Alarm acknowledgment'
types['ACM'] = 'AIS base station addressed channel management command'
types['ACR'] = 'ACR electronics, inc.'
types['ACS'] = 'AIS channel management information source'
types['ACT'] = 'Advanced control technology'
types['ADI'] = 'Aditel'
types['ADN'] = 'AD Navigation'
types['ADS'] = 'Automatic device status'
types['AFB'] = 'ATON Forced broadcast command'
types['AGA'] = 'AIS Base station broadcast of a group assignment command'
types['AGI'] = 'Airguide instrument co.'
types['AHA'] = 'Autohelm of America'
types['AID'] = 'ATON identification configuration command'
types['AIP'] = 'Aiphone Corp.'
types['AIR'] = 'AIS Interrogation request'
types['AKD'] = 'Acknowledge detail alarm condition'
types['ALA'] = 'Set detail alarm condition'
types['ALD'] = 'ALDEN Electronics, Inc.'
types['ALM'] = 'GPS almanac data'
types['ALR'] = 'Set alarm state'
types['AMC'] = 'Alltek marine electronics corp.'
types['AMI'] = 'Advanced marine electronics corp.'
types['AMR'] = 'AMR systems'
types['AMT'] = 'AIRMAR technology'
types['AND'] = 'Andrew corporation'
types['ANI'] = 'Autonautical instrumental S.L.'
types['ANS'] = 'Antenna specialist'
types['ANX'] = 'Analytyx electronic systems'
types['ANZ'] = 'Anschutz of america'
types['AOB'] = 'Aerobytes ltd'
types['APA'] = 'Heading/track controller (Autopilot) Sentence "A"'
types['APB'] = 'Heading/track controller (Autopilot) Sentence "B"'
types['APC'] = 'Apelco'
types['APN'] = 'American pioneer, inc.'
types['ADI'] = 'Automatic power, Inc. - Pharos marine'
types['ADI'] = 'Amperec, inc.'
types['AQC'] = 'Aqua-chem, inc.'
types['AQD'] = 'Aquadynamics, inc.'
types['AQM'] = 'Aqua meter instrument co.'
types['ARL'] = 'Active research limited'
types['ASD'] = 'Autopilot system data'
types['ASH'] = 'Ashtech'
types['ASN'] = 'AIS Base station broadcast of assignment command'
types['ASP'] = 'American solar power'
types['ATC'] = 'Advanced C technology, ltd'
types['ATE'] = 'Atena engineering'
types['ATM'] = 'Atlantic marketing company'
types['ATR'] = 'Airtron'
types['ATV'] = 'Activation, inc.'
types['AVN'] = 'Advanced navigation, inc.'
types['AWA'] = 'Awa New Zealand, ltd.'
types['AXN'] = 'Axiom navigation, inc.'
types['BBG'] = 'BBG Incorporated'
types['BBL'] = 'BBL Industries, inc.'
types['BBM'] = 'AIS Broadcast binary message'
types['BBR'] = 'BBR and associates'
types['BCG'] = 'Base station configuration, general command'
types['BCL'] = 'Base station configuration, local command'
types['BDV'] = 'Brisson development, inv.'
types['BEC'] = 'Bearing and distance to waypoint, dead reckoning'
types['BFA'] = 'Blueflow Americas'
types['BGG'] = 'Bodensee graavitymeter geosystems gmbh'
types['BGS'] = 'Barringer geoservice'
types['BGT'] = 'Brookes and gatehouse, inc.'
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
types['THS'] = 'True Heading and Speed'
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
types['VWR'] = 'Apparent wind angle and speed'
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

--#endregion



--# region Protocol

NMEA0183PROTO = Proto("NMEA0183", "NMEA 0183 Packet")
local fp = NMEA0183PROTO.fields
fp.count = ProtoField.uint8('nmea.count', 'Sentences in packet')

NMEA0183SENTENCE = Proto('NMEA0183SENTENCE', 'NMEA Sentence')
local fm = NMEA0183SENTENCE.fields
fm.sentence = ProtoField.string("nmea.sentence.data", "Sentence")
fm.tag = ProtoField.string('nmea.sentence.tag', 'Tag')
fm.index = ProtoField.uint8('nmea.sentence.index', 'Index')
fm.field = ProtoField.string('nmea.sentence.field', 'Field')


-- wireshark protocol preferences
NMEA0183PROTO.prefs.ports = Pref.string("Ports", "2000,3100", "Ports to dissect as NMEA 0183")

-- parseSentence parses and adds a sentence to the tree
local function parseSentence(tree, buffer, offset, length, index)
  local last = offset + length
  --offset = offset + 1 --skip '$'
  tree:add(fm.index, index)
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

-- The dissector implementation
function NMEA0183PROTO.dissector(buffer, pinfo, tree)
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

  local subtree = tree:add(NMEA0183PROTO, buffer(offset))
  local mo, fields
  local t = keep(buffer(offset):string(), msg_pattern)
  subtree:add(fp.count, #t)
  
  -- loop through all sentences 
  for index, message in ipairs(t) do
    st = subtree:add(NMEA0183SENTENCE, buffer(offset+ message.first, message.last - message.first))
    st:append_text(' ' .. index .. ', ' .. message.text)
    mo = offset + message.first
    parseSentence(st, buffer, mo, message.last - message.first, index)
  end
end

--#endregion

-- register_pref_ports is a helper function to register the protocol to each configured port using provided table
local function register_pref_ports(tab)
  for v in string.gmatch(NMEA0183PROTO.prefs.ports, "([^,]+)") do
    tab:add(tonumber(v), NMEA0183PROTO)
  end
end

--
-- handler for when preferences is changed
function NMEA0183PROTO.prefs_changed()
  local udp_table = DissectorTable.get("udp.port")
  -- remove all registerd ports
  udp_table:remove_all(NMEA0183PROTO)    
  -- update registration with new values
  register_pref_ports(udp_table)
end

-- Register the dissector
local udp_table = DissectorTable.get("udp.port")
register_pref_ports(udp_table)


