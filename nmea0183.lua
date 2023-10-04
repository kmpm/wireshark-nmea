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

-- lookup a index in list, if missing return 'Unknown (index'
function lookup(arr, index)
  local item = arr[index]
  if item == nil then
    return string.format('Unknown (%s)', index)
  end
  return item
end

-- Correct rounding
function round(x)
  return x >= 0 and math.floor(x+0.5) or math.ceil(x-0.5)
end

function bin2SignInt(value)
  local sign = value:sub(1, 1)
  value = tonumber(value:sub(2), 2)
  if sign == '1' then
    value = value * -1
  end
  return value
end

do
  NMEAPROTO = Proto('nmea', 'NMEA 0183 Protocol')

  local pf = NMEAPROTO.fields
  pf.count = ProtoField.uint8('nmea.count', 'Messages in packet')
  pf.format = ProtoField.string('nmea.format', 'Message Format')
  -- Tag
  pf.header = ProtoField.string('nmea.header', 'Header')
  pf.talker = ProtoField.string('nmea.talker', 'Talker')
  pf.msgtype = ProtoField.string('nmea.type', 'Message Type')
  --
  pf.crcstat = ProtoField.string('nmea.checksum.status', 'Checksum Status')
  -- Fields
  pf.fields = ProtoField.string('nmea.fields', 'Fields')
  pf.field_lat = ProtoField.string('nmea.fields.lat', 'Latitude')
  pf.field_lon = ProtoField.string('nmea.fields.lon', 'Longitude')
  pf.field_alt = ProtoField.string('nmea.fields.alt', 'Altitude')
  pf.field_time = ProtoField.string('nmea.fields.time', 'Time (UTC)')
  pf.field_stat = ProtoField.string('nmea.fields.stat', 'Status')
  pf.field_pos_fix = ProtoField.string('nmea.fields.pos_fix', 'Position Fix')
  pf.field_sat_used = ProtoField.string('nmea.fields.sat_used', 'Satellites Used')
  pf.field_hdop = ProtoField.string('nmea.fields.hdop', 'HDOP')
  pf.field_msl_alt = ProtoField.string('nmea.fields.msl_alt', 'Mean See Level (MSL) Altitude')
  pf.field_geoid_sep = ProtoField.string('nmea.fields.geoid_sep', 'Geoid Separation')
  pf.field_age_diff_corr = ProtoField.string('nmea.fields.age_diff_corr', 'Age of Differential Correction')
  pf.field_drs_id = ProtoField.string('nmea.fields.drs_id', 'Differential Reference Station ID')
  pf.field_sog = ProtoField.string('nmea.fields.sog', 'Speed Over Ground (SOG)')
  pf.field_cog = ProtoField.string('nmea.fields.cog', 'Course Over Ground (COG)')
  pf.field_date = ProtoField.string('nmea.fields.date', 'Date')
  pf.field_magn_var = ProtoField.string('nmea.fields.magn_var', 'Magnetic Variation')
  pf.total_parts = ProtoField.string('nmea.total_parts', 'Total Parts') --Messages Count --ProtoField..uint8
  pf.part_num = ProtoField.string('nmea.part_num', 'Part #') --Message # --ProtoField..uint8
  pf.seq_msg_id = ProtoField.string('nmea.fields.seq_msg_id', 'Sequential Message ID') --ProtoField..uint8
  pf.field_ais_ch = ProtoField.string('nmea.fields.ais_ch', 'AIS Channel')
  pf.field_encaps_msg = ProtoField.string('nmea.fields.encaps_msg', 'Encapsulated Radio Message (ITU-R M.1371)') --'Encapsulated Message'/'Encapsulated Payload'
  pf.field_num_fillbits = ProtoField.string('nmea.fields.num_fillbits', 'Number of Fill-Bits')
  pf.field_ais_msg_type = ProtoField.string('nmea.fields.ais_msg_type', 'AIS Message Type (ITU-R M.1371)')
  pf.field_mmsi_dst_ais = ProtoField.string('nmea.fields.mmsi_dst_ais', 'MMSI of The Destination AIS Unit')
  --= ProtoField.string('nmea.field.', '')
  --= ProtoField.string('nmea.field.', '')
  --= ProtoField.string('nmea.field.', '')
  --= ProtoField.string('nmea.field.', '')
  -- AIS Message Fields
  pf.ais_msg_type = ProtoField.string('nmea.ais.msg_type', 'Message Type')
  pf.ais_repeat = ProtoField.string('nmea.ais.repeat_ind', 'Repeat Indicator') --ProtoField..uint8
  pf.ais_rot = ProtoField.string('nmea.ais.rot', 'Rate of Turn (ROT)')
  --local degree = string.char(0xC2, 0xB0)
  --pf.ais_rot = ProtoField.string('nmea.ais.rot', string.format('Rate of Turn (ROT), %s/min', degree))
  pf.ais_mmsi = ProtoField.string('nmea.ais.mmsi', 'MMSI') --ProtoField..uint8
  pf.ais_nav_stat = ProtoField.string('nmea.ais_nav_stat', 'Navigational Status')
  pf.ais_sog = ProtoField.string('nmea.ais.sog', 'Speed Over Ground (SOG)')
  pf.ais_pos_acc = ProtoField.string('nmea.ais.pos_acc', 'Position Accuracy')
  pf.ais_lon = ProtoField.string('nmea.ais.lon', 'Longitude')
  pf.ais_lat = ProtoField.string('nmea.ais.lat', 'Latitude')
  pf.ais_cog = ProtoField.string('nmea.ais.cog', 'Course Over Ground (COG)')
  pf.ais_hdg = ProtoField.string('nmea.ais.hdg', 'True Heading (HDG)')
  pf.ais_time_stamp = ProtoField.string('nmea.ais.time_stamp', 'Time Stamp')
  pf.ais_maneuver = ProtoField.string('nmea.ais.maneuver', 'Maneuver Indicator')
  pf.ais_spare = ProtoField.string('nmea.ais.spare', 'Spare') --ProtoField..uint8
  pf.ais_raim = ProtoField.string('nmea.ais.raim', 'Receiver Autonomous Integrity Monitoring (RAIM) Flag')
  pf.ais_comm = ProtoField.string('nmea.ais.comm', 'Communication State') --ProtoField..uint8
  pf.ais_comm_sync_state = ProtoField.string('nmea.ais.comm.sync_state', 'Sync State')
  pf.ais_comm_slot_timeout = ProtoField.string('nmea.ais.comm.slot_timeout', 'Slot Timeout')
  --pf.ais_comm_sub_msg = ProtoField.string('nmea.ais.comm.sub_msg', 'Sub Message')
  pf.ais_comm_rx_stations = ProtoField.string('nmea.ais.comm.rx_stations', 'Received Stations')
  pf.ais_comm_slot_num = ProtoField.string('nmea.ais.comm.slot_num', 'Slot Number')
  pf.ais_comm_hhmm = ProtoField.string('nmea.ais.comm.hhmm', 'Hours and Minutes (UTC)')
  pf.ais_comm_slot_offset = ProtoField.string('nmea.ais.comm.slot_offset', 'Slot Offset')
  --= ProtoField.string('nmea.ais.', '')

  --pf.ais = ProtoField.protocol('nmea.ais', 'AIS Message')
  --pf.ais.msg_type_ = ProtoField.string('nmea.ais.msg_type_', 'Message Type')

  --AISPROTO = Proto('ais', 'AIS Message')

  --local pfais = AISPROTO.fields
  --pfais.mmsi = ProtoField.uint8('ais.mmsi', 'MMSI')

  local runonce = true -- Flag for remove\insert in table

  -- Talker ID
  local arrtalker = {}
  arrtalker['AB'] = 'Independent AIS Base Station'
  arrtalker['AD'] = 'Dependant AIS Base Station'
  arrtalker['AG'] = 'Autopilot - General'
  arrtalker['AI'] = 'Mobile AIS Station, Class A or B'
  arrtalker['AN'] = 'Aid to Navigation AIS Station'
  arrtalker['AP'] = 'Autopilot - Magnetic'
  arrtalker['AR'] = 'AIS Receiving Station'
  arrtalker['AS'] = 'AIS Limited Base Station'
  arrtalker['AT'] = 'AIS Transmitting Station'
  arrtalker['AX'] = 'AIS Simplex Repeater Station'
  arrtalker['BD'] = 'Beidou Positioning System Receiver'
  arrtalker['BI'] = 'Bilge Systems'
  arrtalker['BN'] = 'Bridge Navigational Watch Alarm System (BNWAS)'
  arrtalker['CA'] = 'Central Alarm Management'
  arrtalker['CD'] = 'Communications - Digital Selective Calling (DSC)'
  arrtalker['CR'] = 'Communications - Data Receiver'
  arrtalker['CS'] = 'Communications - Satellite'
  arrtalker['CT'] = 'Communications - Radio-Telephone MF-HF'
  arrtalker['CV'] = 'Communications - Radio-Telephone VHF'
  arrtalker['CX'] = 'Communications - Scanning Receiver'
  arrtalker['DE'] = 'Decca navigator'
  arrtalker['DF'] = 'Radio Direction Finder'
  arrtalker['DM'] = 'Velocity Sensor, Speed Log, Water, Magnetic'
  arrtalker['DP'] = 'Dynamic Position'
  arrtalker['DU'] = 'Duplex Repeater Station'
  arrtalker['EC'] = 'Electronic Chart System (ECS)'
  arrtalker['EI'] = 'Electronic Chart Display and Information System (ECDIS)'
  arrtalker['EP'] = 'Emergency Position Indicating Radio Beacon (EPIRB)'
  arrtalker['ER'] = 'Engine Room Monitoring Systems'
  arrtalker['FD'] = 'Fire Door Controller/Monitoring Point'
  arrtalker['FE'] = 'Fire Extinguisher System'
  arrtalker['FR'] = 'Fire Detection Point'
  arrtalker['FR'] = 'Franson software'
  arrtalker['FS'] = 'Fire Sprinkler System'
  arrtalker['GA'] = 'Galileo positioning system receiver'
  arrtalker['GB'] = 'BeiDou positioning system receiver'
  arrtalker['GC'] = 'Unknown positioning system receiver'
  arrtalker['GI'] = 'NavIC (IRNSS)'
  arrtalker['GL'] = 'GLONASS Positioning System Receiver'
  arrtalker['GN'] = 'Global Navigation Satellite System (GNSS)'
  arrtalker['GP'] = 'Global Positioning System Receiver (GPS)'
  arrtalker['GQ'] = 'QZSS'
  arrtalker['GY'] = 'Global Positioning System Receiver (GPS)'
  arrtalker['HC'] = 'Compass, Magnetic'
  arrtalker['HD'] = 'Hull Door Controller/Monitoring Panel'
  arrtalker['HE'] = 'Gyro, North Seeking'
  arrtalker['HF'] = 'Fluxgate'
  arrtalker['HN'] = 'Gyro, Non North Seeking'
  arrtalker['HS'] = 'Hull Stress Monitoring'
  arrtalker['II'] = 'Integrated Instrumention'
  arrtalker['IN'] = 'Integrated Navigation'
  arrtalker['IO'] = 'Input Output Information'
  arrtalker['JA'] = 'Alarm and Monitoring System'
  arrtalker['JB'] = 'Reefer Monitoring System'
  arrtalker['JC'] = 'Power Management System'
  arrtalker['JD'] = 'Propulsion Control System'
  arrtalker['JE'] = 'Engine Control Console'
  arrtalker['JF'] = 'Propulsion Boiler'
  arrtalker['JG'] = 'Auxiliary Boiler'
  arrtalker['JH'] = 'Electronic Governor System'
  arrtalker['LC'] = 'Loran C'
  arrtalker['MX'] = 'Multiplexer'
  arrtalker['NA'] = 'Navigation - Unknown'
  arrtalker['NL'] = 'Navigation Light Controller'
  arrtalker['NW'] = 'Navigation - Unknown'
  arrtalker['QZ'] = 'QZSS regional GPS augmentation system'
  arrtalker['RA'] = 'RADAR and/or ARPA (RADAR plotting)'
  arrtalker['RB'] = 'Record Book'
  arrtalker['RC'] = 'Propulsion Machinery Including Remote Control'
  arrtalker['RI'] = 'Rudder Angle Indicator'
  arrtalker['SA'] = 'Physical Shore AIS Station'
  arrtalker['SD'] = 'Sounder, depth'
  arrtalker['SE'] = 'True Heading'
  arrtalker['SG'] = 'Steering Gear/Steering Engine'
  arrtalker['SN'] = 'Electronic Positioning System other - general'
  arrtalker['SP'] = 'Speed Sensor'
  arrtalker['SS'] = 'Scanning Sounder'
  arrtalker['ST'] = 'Skytraq debug output'
  arrtalker['TC'] = 'Track Control System'
  arrtalker['TI'] = 'Turn Rate Indicator'
  arrtalker['TM'] = 'Transas VTS / SML tracking system'
  arrtalker['TR'] = 'TRANSIT Navigation System'
  arrtalker['U0'] = 'User Configured talker identifier 0'
  arrtalker['U1'] = 'User Configured talker identifier 1'
  arrtalker['U2'] = 'User Configured talker identifier 2'
  arrtalker['U3'] = 'User Configured talker identifier 3'
  arrtalker['U4'] = 'User Configured talker identifier 4'
  arrtalker['U5'] = 'User Configured talker identifier 5'
  arrtalker['U6'] = 'User Configured talker identifier 6'
  arrtalker['U7'] = 'User Configured talker identifier 7'
  arrtalker['U8'] = 'User Configured talker identifier 8'
  arrtalker['U9'] = 'User Configured talker identifier 9'
  arrtalker['UP'] = 'Microprocessor Controller'
  arrtalker['VA'] = 'VHF Data Exchange System, ASM'
  arrtalker['VD'] = 'Velocity Sensor, Doppler, other/general'
  arrtalker['VM'] = 'Velocity Sensor, Speed Log, Water, Magnetic'
  arrtalker['VR'] = 'Voyage Data Recorder'  
  arrtalker['VS'] = 'VHF Data Exchange System, Satellite'
  arrtalker['VT'] = 'VHF Data Exchange System, Terrestrial'
  arrtalker['VW'] = 'Velocity Sensor, Speed Log, Water, Mechanical'
  arrtalker['WD'] = 'Watertight Door Controller/Monitoring Panel'
  arrtalker['WI'] = 'Weather Instruments'
  arrtalker['YX'] = 'Transducer'
  arrtalker['ZA'] = 'Timekeeper - Atomic Clock'
  arrtalker['ZC'] = 'Timekeeper - Chronometer'
  arrtalker['ZQ'] = 'Timekeeper - Quartz'
  arrtalker['ZV'] = 'Timekeeper - Radio Update, WWV or WWVH'

  -- Talker Proprietary Manufacturer's Code
  local arrtalkerprop = {}
  -- Proprietary \ Proprietary Code \ Vendor Specific
  arrtalkerprop['PAAR'] = 'Proprietary (Asian American Resources)'
  arrtalkerprop['PACE'] = 'Proprietary (Auto-Comm Engineering)'
  arrtalkerprop['PACR'] = 'Proprietary (ACR Electronics)'
  arrtalkerprop['PACS'] = 'Proprietary (Arco Solar)'
  arrtalkerprop['PACT'] = 'Proprietary (Advanced Control Technology)'
  arrtalkerprop['PAGI'] = 'Proprietary (Airguide Instrument)'
  arrtalkerprop['PAHA'] = 'Proprietary (Autohelm of America)'
  arrtalkerprop['PAIP'] = 'Proprietary (Aiphone)'
  arrtalkerprop['PALD'] = 'Proprietary (Alden Electronics)'
  arrtalkerprop['PAMR'] = 'Proprietary (AMR Systems)'
  arrtalkerprop['PAMT'] = 'Proprietary (Airmar Technology)'
  arrtalkerprop['PANS'] = 'Proprietary (Antenna Specialists)'
  arrtalkerprop['PANX'] = 'Proprietary (Analytyx Electronic Systems)'
  arrtalkerprop['PANZ'] = 'Proprietary (Anschutz of America)'
  arrtalkerprop['PAPC'] = 'Proprietary (Apelco)'
  arrtalkerprop['PAPN'] = 'Proprietary (American Pioneer)'
  arrtalkerprop['PAPX'] = 'Proprietary (Amperex)'
  arrtalkerprop['PAQC'] = 'Proprietary (Aqua-Chem)'
  arrtalkerprop['PAQD'] = 'Proprietary (Aquadynamics)'
  arrtalkerprop['PAQM'] = 'Proprietary (Aqua Meter Instrument)'
  arrtalkerprop['PASH'] = 'Proprietary (Ashtech)'
  arrtalkerprop['PASP'] = 'Proprietary (American Solar Power)'
  arrtalkerprop['PATE'] = 'Proprietary (Aetna Engineering)'
  arrtalkerprop['PATM'] = 'Proprietary (Atlantic Marketing)'
  arrtalkerprop['PATR'] = 'Proprietary (Airtron)'
  arrtalkerprop['PATV'] = 'Proprietary (Activation)'
  arrtalkerprop['PAVN'] = 'Proprietary (Advanced Navigation)'
  arrtalkerprop['PAWA'] = 'Proprietary (Awa New Zealand)'
  arrtalkerprop['PBBL'] = 'Proprietary (BBL Industries)'
  arrtalkerprop['PBBR'] = 'Proprietary (BBR and Associates)'
  arrtalkerprop['PBDV'] = 'Proprietary (Brisson Development)'
  arrtalkerprop['PBEC'] = 'Proprietary (Boat Electric)'
  arrtalkerprop['PBGS'] = 'Proprietary (Barringer Geoservice)'
  arrtalkerprop['PBGT'] = 'Proprietary (Brookes and Gatehouse)'
  arrtalkerprop['PBHE'] = 'Proprietary (BH Electronics)'
  arrtalkerprop['PBHR'] = 'Proprietary (Bahr Technologies)'
  arrtalkerprop['PBLB'] = 'Proprietary (Bay Laboratories)'
  arrtalkerprop['PBME'] = 'Proprietary (Bartel Marine Electronics)'
  arrtalkerprop['PBNI'] = 'Proprietary (Neil Brown Instrument Systems)'
  arrtalkerprop['PBNS'] = 'Proprietary (Bowditch Navigation Systems)'
  arrtalkerprop['PBRM'] = 'Proprietary (Mel Barr)'
  arrtalkerprop['PBRY'] = 'Proprietary (Byrd Industries)'
  arrtalkerprop['PBTH'] = 'Proprietary (Benthos)'
  arrtalkerprop['PBTK'] = 'Proprietary (Baltek)'
  arrtalkerprop['PBTS'] = 'Proprietary (Boat Sentry)'
  arrtalkerprop['PBXA'] = 'Proprietary (Bendix-Avalex)'
  arrtalkerprop['PCAT'] = 'Proprietary (Catel)'
  arrtalkerprop['PCBN'] = 'Proprietary (Cybernet Marine Products)'
  arrtalkerprop['PCCA'] = 'Proprietary (Copal of America)'
  arrtalkerprop['PCCC'] = 'Proprietary (Coastal Communications)'
  arrtalkerprop['PCCL'] = 'Proprietary (Coastal Climate)'
  arrtalkerprop['PCCM'] = 'Proprietary (Coastal Communications)'
  arrtalkerprop['PCDC'] = 'Proprietary (Cordic)'
  arrtalkerprop['PCEC'] = 'Proprietary (Ceco Communications)'
  arrtalkerprop['PCHI'] = 'Proprietary (Charles Industries)'
  arrtalkerprop['PCKM'] = 'Proprietary (Cinkel Marine Electronics Industries)'
  arrtalkerprop['PCMA'] = 'Proprietary (Societe Nouvelle D\'Equiment du Calvados)'
  arrtalkerprop['PCMC'] = 'Proprietary (Coe Manufacturing)'
  arrtalkerprop['PCME'] = 'Proprietary (Cushman Electronics)'
  arrtalkerprop['PCMP'] = 'Proprietary (C-Map)'
  arrtalkerprop['PCMS'] = 'Proprietary (Coastal Marine Sales)'
  arrtalkerprop['PCMV'] = 'Proprietary (CourseMaster USA)'
  arrtalkerprop['PCNI'] = 'Proprietary (Continental Instruments)'
  arrtalkerprop['PCNV'] = 'Proprietary (Coastal Navigator)'
  arrtalkerprop['PCNX'] = 'Proprietary (Cynex Manufactoring)'
  arrtalkerprop['PCPL'] = 'Proprietary (Computrol)'
  arrtalkerprop['PCPN'] = 'Proprietary (Compunav)'
  arrtalkerprop['PCPS'] = 'Proprietary (Columbus Positioning)'
  arrtalkerprop['PCPT'] = 'Proprietary (CPT)'
  arrtalkerprop['PCRE'] = 'Proprietary (Crystal Electronics)'
  arrtalkerprop['PCRO'] = 'Proprietary (The Caro Group)'
  arrtalkerprop['PCRY'] = 'Proprietary (Crystek Crystals)'
  arrtalkerprop['PCSI'] = 'Proprietary (Communication Systems Int.)'
  arrtalkerprop['PCSM'] = 'Proprietary (Comsat Maritime Services)'
  arrtalkerprop['PCST'] = 'Proprietary (Cast)'
  arrtalkerprop['PCSV'] = 'Proprietary (Combined Services)'
  arrtalkerprop['PCTA'] = 'Proprietary (Current Alternatives)'
  arrtalkerprop['PCTB'] = 'Proprietary (Cetec Benmar)'
  arrtalkerprop['PCTC'] = 'Proprietary (Cell-tech Communications)'
  arrtalkerprop['PCTE'] = 'Proprietary (Castle Electronics)'
  arrtalkerprop['PCTL'] = 'Proprietary (C-Tech)'
  arrtalkerprop['PCWD'] = 'Proprietary (Cubic Western Data)'
  arrtalkerprop['PCWV'] = 'Proprietary (Celwave R.F.)'
  arrtalkerprop['PCYZ'] = 'Proprietary (cYz)'
  arrtalkerprop['PDCC'] = 'Proprietary (Dolphin Components)'
  arrtalkerprop['PDEB'] = 'Proprietary (Debeg GmbH)'
  arrtalkerprop['PDFI'] = 'Proprietary (Defender Industries)'
  arrtalkerprop['PDGC'] = 'Proprietary (Digicourse)'
  arrtalkerprop['PDME'] = 'Proprietary (Digital Marine Electronics)'
  arrtalkerprop['PDMI'] = 'Proprietary (Datamarine Int.)'
  arrtalkerprop['PDNS'] = 'Proprietary (Dornier System)'
  arrtalkerprop['PDNT'] = 'Proprietary (Del Norte Technology)'
  arrtalkerprop['PDPS'] = 'Proprietary (Danaplus)'
  arrtalkerprop['PDRL'] = 'Proprietary (R.L. Drake)'
  arrtalkerprop['PDSC'] = 'Proprietary (Dynascan)'
  arrtalkerprop['PDYN'] = 'Proprietary (Dynamote)'
  arrtalkerprop['PDYT'] = 'Proprietary (Dytek Laboratories)'
  arrtalkerprop['PEBC'] = 'Proprietary (Emergency Beacon)'
  arrtalkerprop['PECT'] = 'Proprietary (Echotec)'
  arrtalkerprop['PEEV'] = 'Proprietary (EEV)'
  arrtalkerprop['PEFC'] = 'Proprietary (Efcom Communication Systems)'
  arrtalkerprop['PELD'] = 'Proprietary (Electronic Devices)'
  arrtalkerprop['PEMC'] = 'Proprietary (Electric Motion)'
  arrtalkerprop['PEMS'] = 'Proprietary (Electro Marine Systems)'
  arrtalkerprop['PENA'] = 'Proprietary (Energy Analysts)'
  arrtalkerprop['PENC'] = 'Proprietary (Encron)'
  arrtalkerprop['PEPM'] = 'Proprietary (Epsco Marine)'
  arrtalkerprop['PEPT'] = 'Proprietary (Eastprint)'
  arrtalkerprop['PERC'] = 'Proprietary (The Ericsson)'
  arrtalkerprop['PESA'] = 'Proprietary (European Space Agency)'
  arrtalkerprop['PFDN'] = 'Proprietary (Fluiddyne)'
  arrtalkerprop['PFEC'] = 'Proprietary (Furuno Electric (??))'
  arrtalkerprop['PFHE'] = 'Proprietary (Fish Hawk Electronics)'
  arrtalkerprop['PFJN'] = 'Proprietary (Jon Fluke)'
  arrtalkerprop['PFMM'] = 'Proprietary (First Mate Marine Autopilots)'
  arrtalkerprop['PFNT'] = 'Proprietary (Franklin Net and Twine)'
  arrtalkerprop['PFRC'] = 'Proprietary (The Fredericks)'
  arrtalkerprop['PFTG'] = 'Proprietary (T.G. Faria)'
  arrtalkerprop['PFUJ'] = 'Proprietary (Fujitsu Ten of America)'
  arrtalkerprop['PFUR'] = 'Proprietary (Furuno USA)'
  arrtalkerprop['PGAM'] = 'Proprietary (GRE America)'
  arrtalkerprop['PGCA'] = 'Proprietary (Gulf Cellular Associates)'
  arrtalkerprop['PGES'] = 'Proprietary (Geostar)'
  arrtalkerprop['PGFC'] = 'Proprietary (Graphic Controls)'
  arrtalkerprop['PGIS'] = 'Proprietary (Galax Integrated Systems)'
  arrtalkerprop['PGLO'] = 'Proprietary (Quectel)'
  arrtalkerprop['PGPI'] = 'Proprietary (Global Positioning Instrument)'
  arrtalkerprop['PGRM'] = 'Proprietary (Garmin)'
  arrtalkerprop['PGSC'] = 'Proprietary (Gold Star)'
  arrtalkerprop['PGTO'] = 'Proprietary (Gro Electronics)'
  arrtalkerprop['PGVE'] = 'Proprietary (Guest)'
  arrtalkerprop['PGVT'] = 'Proprietary (Great Valley Technology)'
  arrtalkerprop['PHAL'] = 'Proprietary (HAL Communications)'
  arrtalkerprop['PHAR'] = 'Proprietary (Harris)'
  arrtalkerprop['PHIG'] = 'Proprietary (Hy-Gain)'
  arrtalkerprop['PHIT'] = 'Proprietary (Hi-Tec)'
  arrtalkerprop['PHPK'] = 'Proprietary (Hewlett-Packard)'
  arrtalkerprop['PHRC'] = 'Proprietary (Harco Manufacturing)'
  arrtalkerprop['PHRT'] = 'Proprietary (Hart Systems)'
  arrtalkerprop['PHTI'] = 'Proprietary (Heart Interface)'
  arrtalkerprop['PHUL'] = 'Proprietary (Hull Electronics)'
  arrtalkerprop['PHWM'] = 'Proprietary (Honeywell Marine Systems)'
  arrtalkerprop['PICO'] = 'Proprietary (Icom of America)'
  arrtalkerprop['PIFD'] = 'Proprietary (Int. Fishing Devices)'
  arrtalkerprop['PIFI'] = 'Proprietary (Instruments for Industry)'
  arrtalkerprop['PIME'] = 'Proprietary (Imperial Marine Equipment)'
  arrtalkerprop['PIMI'] = 'Proprietary (I.M.I.)'
  arrtalkerprop['PIMM'] = 'Proprietary (ITT MacKay Marine)'
  arrtalkerprop['PIMP'] = 'Proprietary (Impulse Manufacturing)'
  arrtalkerprop['PIMT'] = 'Proprietary (Int. Marketing and Trading)'
  arrtalkerprop['PINM'] = 'Proprietary (Inmar Electronic and Sales)'
  arrtalkerprop['PINT'] = 'Proprietary (Intech)'
  arrtalkerprop['PIRT'] = 'Proprietary (Intera Technologies)'
  arrtalkerprop['PIST'] = 'Proprietary (Innerspace Technology)'
  arrtalkerprop['PITM'] = 'Proprietary (Intermarine Electronics)'
  arrtalkerprop['PITR'] = 'Proprietary (Itera)'
  arrtalkerprop['PJAN'] = 'Proprietary (Jan Crystals)'
  arrtalkerprop['PJFR'] = 'Proprietary (Ray Jefferson)'
  arrtalkerprop['PJMT'] = 'Proprietary (Japan Marine Telecommunications)'
  arrtalkerprop['PJRC'] = 'Proprietary (Japan Radio)'
  arrtalkerprop['PJRI'] = 'Proprietary (J-R Industries)'
  arrtalkerprop['PJTC'] = 'Proprietary (J-Tech Associates)'
  arrtalkerprop['PJTR'] = 'Proprietary (Jotron Radiosearch)'
  arrtalkerprop['PKBE'] = 'Proprietary (KB Electronics)'
  arrtalkerprop['PKBM'] = 'Proprietary (Kennebec Marine)'
  arrtalkerprop['PKLA'] = 'Proprietary (Klein Associates)'
  arrtalkerprop['PKMR'] = 'Proprietary (King Marine Radio)'
  arrtalkerprop['PKNG'] = 'Proprietary (King Radio)'
  arrtalkerprop['PKOD'] = 'Proprietary (Koden Electronics)'
  arrtalkerprop['PKRP'] = 'Proprietary (Krupp Int.)'
  arrtalkerprop['PKVH'] = 'Proprietary (KVH)'
  arrtalkerprop['PKYI'] = 'Proprietary (Kyocera Int.)'
  arrtalkerprop['PLAT'] = 'Proprietary (Latitude)'
  arrtalkerprop['PLEC'] = 'Proprietary (Lorain Electronics)'
  arrtalkerprop['PLMM'] = 'Proprietary (Lamarche Manufacturing)'
  arrtalkerprop['PLRD'] = 'Proprietary (Lorad)'
  arrtalkerprop['PLSE'] = 'Proprietary (Littlemore Scientific Engineering)'
  arrtalkerprop['PLSP'] = 'Proprietary (Laser Plot)'
  arrtalkerprop['PLTF'] = 'Proprietary (Littlefuse)'
  arrtalkerprop['PLWR'] = 'Proprietary (Lowrance Electronics)'
  arrtalkerprop['PMCL'] = 'Proprietary (Micrologic)'
  arrtalkerprop['PMDL'] = 'Proprietary (Medallion Instruments)'
  arrtalkerprop['PMEC'] = 'Proprietary (Marine Engine Center)'
  arrtalkerprop['PMEG'] = 'Proprietary (Maritec Engineering)'
  arrtalkerprop['PMES'] = 'Proprietary (Marine Electronics Service)'
  arrtalkerprop['PMFR'] = 'Proprietary (Modern Products)'
  arrtalkerprop['PMFW'] = 'Proprietary (Frank W. Murphy Manufacturing)'
  arrtalkerprop['PMGN'] = 'Proprietary (Magellan)'
  arrtalkerprop['PMGS'] = 'Proprietary (MG Electronic Sales)'
  arrtalkerprop['PMIE'] = 'Proprietary (Mieco)'
  arrtalkerprop['PMIM'] = 'Proprietary (Marconi Int. Marine)'
  arrtalkerprop['PMLE'] = 'Proprietary (Martha Lake Electronics)'
  arrtalkerprop['PMLN'] = 'Proprietary (Matlin)'
  arrtalkerprop['PMLP'] = 'Proprietary (Marlin Products)'
  arrtalkerprop['PMLT'] = 'Proprietary (Miller Technologies)'
  arrtalkerprop['PMMB'] = 'Proprietary (Marsh-McBirney)'
  arrtalkerprop['PMME'] = 'Proprietary (Marks Marine Engineering)'
  arrtalkerprop['PMMP'] = 'Proprietary (Metal Marine Pilot)'
  arrtalkerprop['PMMS'] = 'Proprietary (Mars Marine Systems)'
  arrtalkerprop['PMNI'] = 'Proprietary (Micro-Now Instrument)'
  arrtalkerprop['PMNT'] = 'Proprietary (Marine Technology)'
  arrtalkerprop['PMNX'] = 'Proprietary (Marinex)'
  arrtalkerprop['PMOT'] = 'Proprietary (Motorola)'
  arrtalkerprop['PMPN'] = 'Proprietary (Memphis Net and Twine)'
  arrtalkerprop['PMQS'] = 'Proprietary (Marquis Industries)'
  arrtalkerprop['PMRC'] = 'Proprietary (Marinecomp)'
  arrtalkerprop['PMRE'] = 'Proprietary (Morad Electronics)'
  arrtalkerprop['PMRP'] = 'Proprietary (Mooring Products of New England)'
  arrtalkerprop['PMRR'] = 'Proprietary (II Morrow)'
  arrtalkerprop['PMRS'] = 'Proprietary (Marine Radio Service)'
  arrtalkerprop['PMSB'] = 'Proprietary (Mitsubishi Electric)'
  arrtalkerprop['PMSE'] = 'Proprietary (Master Electronics)'
  arrtalkerprop['PMSM'] = 'Proprietary (Master Mariner)'
  arrtalkerprop['PMST'] = 'Proprietary (Mesotech Systems)'
  arrtalkerprop['PMTA'] = 'Proprietary (Marine Technical Associates)'
  arrtalkerprop['PMTG'] = 'Proprietary (Narine Technical Assistance Group)'
  arrtalkerprop['PMTK'] = 'Proprietary (Martech)'
  arrtalkerprop['PMTR'] = 'Proprietary (Mitre)'
  arrtalkerprop['PMTS'] = 'Proprietary (Mets)'
  arrtalkerprop['PMUR'] = 'Proprietary (Murata Erie North America)'
  arrtalkerprop['PMVX'] = 'Proprietary (Magnavox Advanced Products and Systems)'
  arrtalkerprop['PMXX'] = 'Proprietary (Maxxima Marine)'
  arrtalkerprop['PNAT'] = 'Proprietary (Nautech)'
  arrtalkerprop['PNEF'] = 'Proprietary (New England Fishing Gear)'
  arrtalkerprop['PNGS'] = 'Proprietary (Navigation Sciences)'
  arrtalkerprop['PNMR'] = 'Proprietary (Newmar)'
  arrtalkerprop['PNOM'] = 'Proprietary (Nav-Com)'
  arrtalkerprop['PNOV'] = 'Proprietary (NovAtel Communications)'
  arrtalkerprop['PNSM'] = 'Proprietary (Northstar Marine)'
  arrtalkerprop['PNTK'] = 'Proprietary (Novatech Designs)'
  arrtalkerprop['PNVC'] = 'Proprietary (Navico)'
  arrtalkerprop['PNVO'] = 'Proprietary (Navionics)'
  arrtalkerprop['PNVS'] = 'Proprietary (Navstar)'
  arrtalkerprop['POAR'] = 'Proprietary (O.A.R.)'
  arrtalkerprop['PODE'] = 'Proprietary (Ocean Data Equipment)'
  arrtalkerprop['PODN'] = 'Proprietary (Odin Electronics)'
  arrtalkerprop['POIN'] = 'Proprietary (Ocean instruments)'
  arrtalkerprop['POKI'] = 'Proprietary (Oki Electronic Industry)'
  arrtalkerprop['POLY'] = 'Proprietary (Navstar (Polytechnic Electronics))'
  arrtalkerprop['POMN'] = 'Proprietary (Omnetics)'
  arrtalkerprop['PORE'] = 'Proprietary (Ocean Research)'
  arrtalkerprop['POTK'] = 'Proprietary (Ocean Technology)'
  arrtalkerprop['PPCE'] = 'Proprietary (Pace)'
  arrtalkerprop['PPDM'] = 'Proprietary (Prodelco Marine Systems)'
  arrtalkerprop['PPLA'] = 'Proprietary (Plath, C. Division of Litton)'
  arrtalkerprop['PPLI'] = 'Proprietary (Pilot Instruments)'
  arrtalkerprop['PPMI'] = 'Proprietary (Pernicka Marine Products)'
  arrtalkerprop['PPMP'] = 'Proprietary (Pacific Marine Products)'
  arrtalkerprop['PPRK'] = 'Proprietary (Perko)'
  arrtalkerprop['PPSM'] = 'Proprietary (Pearce-Simpson)'
  arrtalkerprop['PPTC'] = 'Proprietary (Petro-Com)'
  arrtalkerprop['PPTG'] = 'Proprietary (P.T.I./Guest)'
  arrtalkerprop['PPTH'] = 'Proprietary (Pathcom)'
  arrtalkerprop['PRAC'] = 'Proprietary (Racal Marine)'
  arrtalkerprop['PRAE'] = 'Proprietary (RCA Astro-Electronics)'
  arrtalkerprop['PRAY'] = 'Proprietary (Raytheon Marine)'
  arrtalkerprop['PRCA'] = 'Proprietary (RCA Service)'
  arrtalkerprop['PRCH'] = 'Proprietary (Roach Engineering)'
  arrtalkerprop['PRCI'] = 'Proprietary (Rochester Instruments)'
  arrtalkerprop['PRDI'] = 'Proprietary (Radar Devices)'
  arrtalkerprop['PRDM'] = 'Proprietary (Ray-Dar Manufacturing)'
  arrtalkerprop['PREC'] = 'Proprietary (Ross Engineering)'
  arrtalkerprop['PRFP'] = 'Proprietary (Rolfite Products)'
  arrtalkerprop['PRGC'] = 'Proprietary (RCS Global Communications)'
  arrtalkerprop['PRGY'] = 'Proprietary (Regency Electronics)'
  arrtalkerprop['PRME'] = 'Proprietary (Racal Marine Electronics)'
  arrtalkerprop['PRMR'] = 'Proprietary (RCA Missile and Surface Radar)'
  arrtalkerprop['PRSL'] = 'Proprietary (Ross Laboratories)'
  arrtalkerprop['PRSM'] = 'Proprietary (Robertson-Shipmate, USA)'
  arrtalkerprop['PRTN'] = 'Proprietary (Robertson Tritech Nyaskaien)'
  arrtalkerprop['PRWI'] = 'Proprietary (Rockwell Int.)'
  arrtalkerprop['PSAI'] = 'Proprietary (SAIT)'
  arrtalkerprop['PSBR'] = 'Proprietary (Sea-Bird electronics)'
  arrtalkerprop['PSCR'] = 'Proprietary (Signalcrafters)'
  arrtalkerprop['PSEA'] = 'Proprietary (SEA)'
  arrtalkerprop['PSEC'] = 'Proprietary (Sercel Electronics of Canada)'
  arrtalkerprop['PSEP'] = 'Proprietary (Steel and Engine Products)'
  arrtalkerprop['PSFN'] = 'Proprietary (Seafarer Navigation Int.)'
  arrtalkerprop['PSGC'] = 'Proprietary (SGC)'
  arrtalkerprop['PSIG'] = 'Proprietary (Signet)'
  arrtalkerprop['PSIM'] = 'Proprietary (Simrad)'
  arrtalkerprop['PSKA'] = 'Proprietary (Skantek)'
  arrtalkerprop['PSKP'] = 'Proprietary (Skipper Electronics)'
  arrtalkerprop['PSLI'] = 'Proprietary (Starlink)'
  arrtalkerprop['PSME'] = 'Proprietary (Shakespeare Marine Electronics)'
  arrtalkerprop['PSMF'] = 'Proprietary (Seattle Marine and Fishing Supply)'
  arrtalkerprop['PSMI'] = 'Proprietary (Sperry Marine)'
  arrtalkerprop['PSML'] = 'Proprietary (Simerl Instruments)'
  arrtalkerprop['PSNV'] = 'Proprietary (Starnav)'
  arrtalkerprop['PSOM'] = 'Proprietary (Sound Marine Electronics)'
  arrtalkerprop['PSOV'] = 'Proprietary (Sell Overseas America)'
  arrtalkerprop['PSPL'] = 'Proprietary (Spelmar)'
  arrtalkerprop['PSPT'] = 'Proprietary (Sound Powered Telephone)'
  arrtalkerprop['PSRD'] = 'Proprietary (SRD Labs)'
  arrtalkerprop['PSRF'] = 'Proprietary (SiRF)'
  arrtalkerprop['PSRS'] = 'Proprietary (Scientific Radio Systems)'
  arrtalkerprop['PSRS'] = 'Proprietary (Shipmate, Rauff & Sorensen)'
  arrtalkerprop['PSRT'] = 'Proprietary (Standard Radio and Telefon)'
  arrtalkerprop['PSSI'] = 'Proprietary (Sea Scout Industries)'
  arrtalkerprop['PSTC'] = 'Proprietary (Standard Communications)'
  arrtalkerprop['PSTI'] = 'Proprietary (Sea-Temp Instrument)'
  arrtalkerprop['PSTM'] = 'Proprietary (Si-Tex Marine Electronics)'
  arrtalkerprop['PSVY'] = 'Proprietary (Savoy Electronics)'
  arrtalkerprop['PSWI'] = 'Proprietary (Swoffer Marine Instruments)'
  arrtalkerprop['PTBB'] = 'Proprietary (Thompson Brothers Boat Manufacturing)'
  arrtalkerprop['PTCN'] = 'Proprietary (Trade Commission of Norway (THE))'
  arrtalkerprop['PTDL'] = 'Proprietary (Tideland Signal)'
  arrtalkerprop['PTHR'] = 'Proprietary (Thrane and Thrane)'
  arrtalkerprop['PTLS'] = 'Proprietary (Telesystems)'
  arrtalkerprop['PTMT'] = 'Proprietary (Tamtech)'
  arrtalkerprop['PTNL'] = 'Proprietary (Trimble Navigation)'
  arrtalkerprop['PTRC'] = 'Proprietary (Tracor)'
  arrtalkerprop['PTSI'] = 'Proprietary (Techsonic Industries)'
  arrtalkerprop['PTTK'] = 'Proprietary (Talon Technology)'
  arrtalkerprop['PTTS'] = 'Proprietary (Transtector Systems)'
  arrtalkerprop['PTWC'] = 'Proprietary (Transworld Communications)'
  arrtalkerprop['PTXI'] = 'Proprietary (Texas Instruments)'
  arrtalkerprop['PUBX'] = 'Proprietary (u-blox)'
  arrtalkerprop['PUME'] = 'Proprietary (Umec)'
  arrtalkerprop['PUNF'] = 'Proprietary (Uniforce Electronics)'
  arrtalkerprop['PUNI'] = 'Proprietary (Uniden of America)'
  arrtalkerprop['PUNP'] = 'Proprietary (Unipas)'
  arrtalkerprop['PVAN'] = 'Proprietary (Vanner)'
  arrtalkerprop['PVAR'] = 'Proprietary (Varian Eimac Associates)'
  arrtalkerprop['PVCM'] = 'Proprietary (Videocom)'
  arrtalkerprop['PVEX'] = 'Proprietary (Vexillar)'
  arrtalkerprop['PVIS'] = 'Proprietary (Vessel Information Systems)'
  arrtalkerprop['PVMR'] = 'Proprietary (Vast Marketing)'
  arrtalkerprop['PWAL'] = 'Proprietary (Walport)'
  arrtalkerprop['PWBG'] = 'Proprietary (Westberg Manufacturing)'
  arrtalkerprop['PWEC'] = 'Proprietary (Westinghouse Electric)'
  arrtalkerprop['PWHA'] = 'Proprietary (W-H Autopilots)'
  arrtalkerprop['PWMM'] = 'Proprietary (Wait Manufacturing and Marine Sales)'
  arrtalkerprop['PWMR'] = 'Proprietary (Wesmar Electronics)'
  arrtalkerprop['PWNG'] = 'Proprietary (Winegard)'
  arrtalkerprop['PWSE'] = 'Proprietary (Wilson Electronics)'
  arrtalkerprop['PWST'] = 'Proprietary (West Electronics)'
  arrtalkerprop['PWTC'] = 'Proprietary (Watercom)'
  arrtalkerprop['PYAS'] = 'Proprietary (Yaesu Electronics)'

  -- Message Type
  local arrmsgtype = {}
  arrmsgtype['AAM'] = 'Waypoint arrival alarm'
  arrmsgtype['ABM'] = 'UAIS Addressed binary and safety related message (Type 6, 12)'
  arrmsgtype['ACK'] = 'Alarm acknowledgment'
  arrmsgtype['ADS'] = 'Automatic device status'
  arrmsgtype['AKD'] = 'Acknowledge detail alarm condition'
  arrmsgtype['ALA'] = 'Set detail alarm condition'
  arrmsgtype['ALM'] = 'GPS almanac data'
  arrmsgtype['ALR'] = 'Set alarm state'
  arrmsgtype['APA'] = 'Heading/track controller (Autopilot) Message "A"'
  arrmsgtype['APB'] = 'Heading/track controller (Autopilot) Message "B"'
  arrmsgtype['ASD'] = 'Autopilot system data'
  arrmsgtype['BBM'] = 'UAIS Broadcast Binary Message (Type 8, 14)'
  arrmsgtype['BEC'] = 'Bearing and distance to waypoint, dead reckoning'
  arrmsgtype['BOD'] = 'Bearing, origin to destination'
  arrmsgtype['BWC'] = 'Bearing and distance to waypoint, great circle'
  arrmsgtype['BWR'] = 'Bearing and distance to waypoint, rhumb line'
  arrmsgtype['BWW'] = 'Bearing, waypoint to waypoint'
  arrmsgtype['CEK'] = 'Configure encryption key command'
  arrmsgtype['CMP'] = 'OCTANS latitude and speed'
  arrmsgtype['COP'] = 'Configure the operational period, command'
  arrmsgtype['CUR'] = 'Water current layer'
  arrmsgtype['DBK'] = 'Depth below keel'
  arrmsgtype['DBS'] = 'Depth below surface'
  arrmsgtype['DBT'] = 'Depth below transducer'
  arrmsgtype['DCN'] = 'Decca position'
  arrmsgtype['DCR'] = 'Device capability report'
  arrmsgtype['DDC'] = 'Device dimming control'
  arrmsgtype['DOR'] = 'Door status detection'
  arrmsgtype['DPT'] = 'Depth of Water'
  arrmsgtype['DSC'] = 'Digital Selective Calling information'
  arrmsgtype['DSE'] = 'Extended Digital Selective Calling'
  arrmsgtype['DSI'] = 'Digital Selective Calling transponder initiate'
  arrmsgtype['DSR'] = 'Digital Selective Calling transponder response'
  arrmsgtype['DTM'] = 'Datum Reference'
  arrmsgtype['ETL'] = 'Engine Telegraph Operation Status'
  arrmsgtype['EVE'] = 'General Event Message'
  arrmsgtype['FIR'] = 'Fire detetction'
  arrmsgtype['FSI'] = 'Frequency set information'
  arrmsgtype['GBS'] = 'GNSS satellite fault detection'
  arrmsgtype['GGA'] = 'GPS Fix Data'
  arrmsgtype['GLL'] = 'Geographic Position - Latitude/Longitude'
  arrmsgtype['GNS'] = 'GNSS fix data'
  arrmsgtype['GRS'] = 'GNSS range residuals'
  arrmsgtype['GSA'] = 'GNSS DOP and active satellites'
  arrmsgtype['GST'] = 'GNSS pseudo range error statistics'
  arrmsgtype['GSV'] = 'GNSS satellites in view'
  arrmsgtype['GTD'] = 'Geographic location in time differences'
  arrmsgtype['HDG'] = 'Heading, deviation and variation'
  arrmsgtype['HDM'] = 'Heading, magnetic'
  arrmsgtype['HDT'] = 'Heading, true'
  arrmsgtype['HFB'] = 'Trawl headrope to footrope and bottom'
  arrmsgtype['HMR'] = 'Heading monitor - receive'
  arrmsgtype['HMS'] = 'Heading monitor - set'
  arrmsgtype['HSC'] = 'Heading steering command'
  arrmsgtype['HTC'] = 'Heading track control command'
  arrmsgtype['HTD'] = 'Heading track control data'
  arrmsgtype['INF'] = 'OCTANS status'
  arrmsgtype['ITS'] = 'Trawl door spread to distance'
  arrmsgtype['LIN'] = 'OCTANS surge, sway and heave'
  arrmsgtype['MDA'] = 'Meteorological composite'
  arrmsgtype['MLA'] = 'GLONASS almanac data'
  arrmsgtype['MSK'] = 'MSK control for a beacon receiver'
  arrmsgtype['MSS'] = 'MSK beacon receiver status'
  arrmsgtype['MWD'] = 'Wind direction and speed'
  arrmsgtype['MWV'] = 'Wind speed and angle'
  arrmsgtype['MTW'] = 'Mean temperature of water'
  arrmsgtype['MWD'] = 'Mean wind direction and speed'
  arrmsgtype['MWV'] = 'Mean wind speed and angle'
  arrmsgtype['NST'] = 'Magellan status'
  arrmsgtype['OSD'] = 'Own ship data'
  arrmsgtype['RMA'] = 'Recommended minimum navigation information'
  arrmsgtype['RMB'] = 'Recommended minimum navigation information'
  arrmsgtype['RMC'] = 'Recommended minimum GNSS navigation information'
  arrmsgtype['RME'] = 'Garmin estimated error'
  arrmsgtype['RME'] = 'Garmin altitude'
  arrmsgtype['ROO'] = 'Waypoints in active route'
  arrmsgtype['ROT'] = 'Rate of turn'
  arrmsgtype['RPM'] = 'Revolutions per minute'
  arrmsgtype['RSA'] = 'Rudder sensor angle'
  arrmsgtype['RSD'] = 'RADAR system data'
  arrmsgtype['RTE'] = 'Routes'
  arrmsgtype['SFI'] = 'Scanning frequency information'
  arrmsgtype['RSA'] = 'Rudder sensor angle'
  arrmsgtype['SHR'] = 'RT300 proprietary roll and pitch message'
  arrmsgtype['SPD'] = 'OCTANS speed'
  arrmsgtype['STN'] = 'Multiple data ID'
  arrmsgtype['TDS'] = 'Trawler Door Spread Distance'
  arrmsgtype['TFI'] = 'Trawl Filling Indicator'
  arrmsgtype['TLB'] = 'Target label'
  arrmsgtype['TLL'] = 'Target latitude and longitude'
  arrmsgtype['TPC'] = 'Trawl position cartesian coordinates'
  arrmsgtype['TPR'] = 'Trawl position relative vessel'
  arrmsgtype['TPT'] = 'Trawl position true'
  arrmsgtype['TRO'] = 'OCTANS pitch and roll'
  arrmsgtype['TTM'] = 'Tracked target message'
  arrmsgtype['TXT'] = 'Text transmission'
  arrmsgtype['VBW'] = 'Dual ground/water speed'
  arrmsgtype['VDM'] = 'UAIS VHF Data-link Message (Type 1-3)' --'AIS data message'
  arrmsgtype['VDO'] = 'UAIS VHF Data-link Own-vessel report (Type 1-3)' --'AIS own vessel report'
  arrmsgtype['VDR'] = 'Set and drift'
  arrmsgtype['VHW'] = 'Water speed and heading'
  arrmsgtype['VLW'] = 'Distance traveled through water'
  arrmsgtype['VPW'] = 'Speed, measured parallel to wind'
  arrmsgtype['VTG'] = 'Track made good and ground speed'
  arrmsgtype['VWR'] = 'Apparent wind angle and speed'
  arrmsgtype['WCV'] = 'Waypoint closure velocity'
  arrmsgtype['WDC'] = 'Distance to waypoint, great circle'
  arrmsgtype['WDR'] = 'Distance to waypoint, rhumb line'
  arrmsgtype['WNC'] = 'Distance, waypoint to waypoint'
  arrmsgtype['WPL'] = 'Waypoint location'
  arrmsgtype['XDR'] = 'Transducer measurements'
  arrmsgtype['XTE'] = 'Cross-track error, measured'
  arrmsgtype['XTR'] = 'Cross-track error, dead reckoning'
  arrmsgtype['ZDA'] = 'Time & Date - UTC, day, month, year and local time zone'
  arrmsgtype['ZDL'] = 'Time and distance to variable point'
  arrmsgtype['ZFO'] = 'UTC and time from origin waypoint'
  arrmsgtype['ZTG'] = 'UTC and time to destination waypoint'

  -- Status
  local arrstatus = {}
  arrstatus['A'] = 'Valid'
  arrstatus['B'] = 'Not Valid'

  -- Position Fix Indicator
  local arrposfix = {}
  arrposfix['0'] = 'Not Fix'
  arrposfix['1'] = 'GPS SPS Fix'
  arrposfix['2'] = 'DGPS SPS Fix'
  arrposfix['3'] = 'GPS PPS Fix'

  -- AIS Channel
  local arraischannel = {}
  arraischannel['0'] = 'N/A'
  arraischannel['1'] = 'A'
  arraischannel['2'] = 'B'
  arraischannel['3'] = 'A and B'

  -- Messages Fields
  local arrmsgfield = {}
  arrmsgfield[1] = {msgtype = 'GLL', num = 1, name = 'Latitude', proto = pf.field_lat, length = 2}
  arrmsgfield[2] = {msgtype = 'GLL', num = 2, name = 'Longitude', proto = pf.field_lon, length = 2}
  arrmsgfield[3] = {msgtype = 'GLL', num = 3, name = 'Time', proto = pf.field_time, length = 1}
  arrmsgfield[4] = {msgtype = 'GLL', num = 4, name = 'Status', proto = pf.field_stat, length = 1}
  arrmsgfield[5] = {msgtype = 'GGA', num = 1, name = 'Time', proto = pf.field_time, length = 1}
  arrmsgfield[6] = {msgtype = 'GGA', num = 2, name = 'Latitude', proto = pf.field_lat, length = 2}
  arrmsgfield[7] = {msgtype = 'GGA', num = 3, name = 'Longitude', proto = pf.field_lon, length = 2}
  arrmsgfield[8] = {msgtype = 'GGA', num = 4, name = 'Position Fix', proto = pf.field_pos_fix, length = 1}
  arrmsgfield[9] = {msgtype = 'GGA', num = 5, name = 'Satellites Used', proto = pf.field_sat_used, length = 1}
  arrmsgfield[10] = {msgtype = 'GGA', num = 6, name = 'HDOP', proto = pf.field_hdop, length = 1}
  arrmsgfield[11] = {msgtype = 'GGA', num = 7, name = 'MSL Altitude', proto = pf.field_msl_alt, length = 2}
  arrmsgfield[12] = {msgtype = 'GGA', num = 8, name = 'Geoid Separation', proto = pf.field_geoid_sep, length = 2}
  arrmsgfield[13] = {msgtype = 'GGA', num = 9, name = 'Age of Differential Correction', proto = pf.field_age_diff_corr, length = 1}
  arrmsgfield[14] = {msgtype = 'GGA', num = 10, name = 'Differential Reference Station ID', proto = pf.field_drs_id, length = 1}
  arrmsgfield[15] = {msgtype = 'RMC', num = 1, name = 'Time', proto = pf.field_time, length = 1}
  arrmsgfield[16] = {msgtype = 'RMC', num = 2, name = 'Status', proto = pf.field_stat, length = 1}
  arrmsgfield[17] = {msgtype = 'RMC', num = 3, name = 'Latitude', proto = pf.field_lat, length = 2}
  arrmsgfield[18] = {msgtype = 'RMC', num = 4, name = 'Longitude', proto = pf.field_lon, length = 2}
  arrmsgfield[19] = {msgtype = 'RMC', num = 5, name = 'Speed Over Ground', proto = pf.field_sog, length = 1}
  arrmsgfield[20] = {msgtype = 'RMC', num = 6, name = 'Course Over Ground', proto = pf.field_cog, length = 1}
  arrmsgfield[21] = {msgtype = 'RMC', num = 7, name = 'Date', proto = pf.field_date, length = 1}
  arrmsgfield[22] = {msgtype = 'RMC', num = 8, name = 'Magnetic Variation', proto = pf.field_magn_var, length = 2}
  arrmsgfield[23] = {msgtype = 'VDM', num = 1, name = 'Total Parts', proto = pf.total_parts, length = 1} -- Messages Count
  arrmsgfield[24] = {msgtype = 'VDM', num = 2, name = 'Part #', proto = pf.part_num, length = 1} -- Message #
  arrmsgfield[25] = {msgtype = 'VDM', num = 3, name = 'Sequential Message ID', proto = pf.seq_msg_id, length = 1} -- 0 for messages that fit into one sentence
  arrmsgfield[26] = {msgtype = 'VDM', num = 4, name = 'AIS Channel', proto = pf.field_ais_ch, length = 1} -- 0 when the channel identification is not provided
  arrmsgfield[27] = {msgtype = 'VDM', num = 5, name = 'Encapsulated Radio Message', proto = pf.field_encaps_msg, length = 1}
  arrmsgfield[28] = {msgtype = 'VDM', num = 6, name = 'Number of Fill-Bits', proto = pf.field_num_fillbits, length = 1}
  arrmsgfield[29] = {msgtype = 'VDO', num = 1, name = 'Total Parts', proto = pf.total_parts, length = 1} -- Messages Count
  arrmsgfield[30] = {msgtype = 'VDO', num = 2, name = 'Part #', proto = pf.part_num, length = 1} -- Message #
  arrmsgfield[31] = {msgtype = 'VDO', num = 3, name = 'Sequential Message ID', proto = pf.seq_msg_id, length = 1} -- 0 for messages that fit into one sentence
  arrmsgfield[32] = {msgtype = 'VDO', num = 4, name = 'AIS Channel', proto = pf.field_ais_ch, length = 1} -- 0 when the channel identification is not provided
  arrmsgfield[33] = {msgtype = 'VDO', num = 5, name = 'Encapsulated Radio Message', proto = pf.field_encaps_msg, length = 1}
  arrmsgfield[34] = {msgtype = 'VDO', num = 6, name = 'Number of Fill-Bits', proto = pf.field_num_fillbits, length = 1}
  arrmsgfield[35] = {msgtype = 'BBM', num = 1, name = 'Total Parts', proto = pf.total_parts, length = 1} -- Messages Count
  arrmsgfield[36] = {msgtype = 'BBM', num = 2, name = 'Part #', proto = pf.part_num, length = 1} -- Message #
  arrmsgfield[37] = {msgtype = 'BBM', num = 3, name = 'Sequential Message ID', proto = pf.seq_msg_id, length = 1} -- 0 for messages that fit into one sentence
  arrmsgfield[38] = {msgtype = 'BBM', num = 4, name = 'AIS Channel', proto = pf.field_ais_ch, length = 1}
  arrmsgfield[39] = {msgtype = 'BBM', num = 5, name = 'AIS Message Type', proto = pf.field_ais_msg_type, length = 1}
  arrmsgfield[40] = {msgtype = 'BBM', num = 6, name = 'Encapsulated Radio Message', proto = pf.field_encaps_msg, length = 1}
  arrmsgfield[41] = {msgtype = 'BBM', num = 7, name = 'Number of Fill-Bits', proto = pf.field_num_fillbits, length = 1}
  arrmsgfield[42] = {msgtype = 'ABM', num = 1, name = 'Total Parts', proto = pf.total_parts, length = 1} -- Messages Count
  arrmsgfield[43] = {msgtype = 'ABM', num = 2, name = 'Part #', proto = pf.part_num, length = 1} -- Message #
  arrmsgfield[44] = {msgtype = 'ABM', num = 3, name = 'Sequential Message ID', proto = pf.seq_msg_id, length = 1} -- 0 for messages that fit into one sentence
  arrmsgfield[45] = {msgtype = 'ABM', num = 4, name = 'MMSI of the destination AIS unit', proto = pf.field_mmsi_dst_ais, length = 1}
  arrmsgfield[46] = {msgtype = 'ABM', num = 5, name = 'AIS Channel', proto = pf.field_ais_ch, length = 1}
  arrmsgfield[47] = {msgtype = 'ABM', num = 6, name = 'AIS Message Type', proto = pf.field_ais_msg_type, length = 1}
  arrmsgfield[48] = {msgtype = 'ABM', num = 7, name = 'Encapsulated Radio Message', proto = pf.field_encaps_msg, length = 1}
  arrmsgfield[49] = {msgtype = 'ABM', num = 8, name = 'Number of Fill-Bits', proto = pf.field_num_fillbits, length = 1}
  --arrmsgfield[] = {msgtype = '', num = , name = '', proto = pf.field_, length = 1}
  --arrmsgfield[] = {msgtype = '', num = , name = '', proto = pf.field_, length = 1}
  --arrmsgfield[] = {msgtype = '', num = , name = '', proto = pf.field_, length = 1}

  -- 6-bit Codes of Symbols in Payload of Encapsulated Messages ('!') 
  local arrsixbitcode = {}
  arrsixbitcode['0'] = '000000'
  arrsixbitcode['1'] = '000001'
  arrsixbitcode['2'] = '000010'
  arrsixbitcode['3'] = '000011'
  arrsixbitcode['4'] = '000100'
  arrsixbitcode['5'] = '000101'
  arrsixbitcode['6'] = '000110'
  arrsixbitcode['7'] = '000111'
  arrsixbitcode['8'] = '001000'
  arrsixbitcode['9'] = '001001'
  arrsixbitcode[':'] = '001010'
  arrsixbitcode[';'] = '001011'
  arrsixbitcode['<'] = '001100'
  arrsixbitcode['='] = '001101'
  arrsixbitcode['>'] = '001110'
  arrsixbitcode['?'] = '001111'
  arrsixbitcode['@'] = '010000'
  arrsixbitcode['A'] = '010001'
  arrsixbitcode['B'] = '010010'
  arrsixbitcode['C'] = '010011'
  arrsixbitcode['D'] = '010100'
  arrsixbitcode['E'] = '010101'
  arrsixbitcode['F'] = '010110'
  arrsixbitcode['G'] = '010111'
  arrsixbitcode['H'] = '011000'
  arrsixbitcode['I'] = '011001'
  arrsixbitcode['J'] = '011010'
  arrsixbitcode['K'] = '011011'
  arrsixbitcode['L'] = '011100'
  arrsixbitcode['M'] = '011101'
  arrsixbitcode['N'] = '011110'
  arrsixbitcode['O'] = '011111'
  arrsixbitcode['P'] = '100000'
  arrsixbitcode['Q'] = '100001'
  arrsixbitcode['R'] = '100010'
  arrsixbitcode['S'] = '100011'
  arrsixbitcode['T'] = '100100'
  arrsixbitcode['U'] = '100101'
  arrsixbitcode['V'] = '100110'
  arrsixbitcode['W'] = '100111'
  arrsixbitcode["'"] = '101000'
  arrsixbitcode['a'] = '101001'
  arrsixbitcode['b'] = '101010'
  arrsixbitcode['c'] = '101011'
  arrsixbitcode['d'] = '101100'
  arrsixbitcode['e'] = '101101'
  arrsixbitcode['f'] = '101110'
  arrsixbitcode['g'] = '101111'
  arrsixbitcode['h'] = '110000'
  arrsixbitcode['i'] = '110001'
  arrsixbitcode['j'] = '110010'
  arrsixbitcode['k'] = '110011'
  arrsixbitcode['l'] = '110100'
  arrsixbitcode['m'] = '110101'
  arrsixbitcode['n'] = '110110'
  arrsixbitcode['o'] = '110111'
  arrsixbitcode['p'] = '111000'
  arrsixbitcode['q'] = '111001'
  arrsixbitcode['r'] = '111010'
  arrsixbitcode['s'] = '111011'
  arrsixbitcode['t'] = '111100'
  arrsixbitcode['u'] = '111101'
  arrsixbitcode['v'] = '111110'
  arrsixbitcode['w'] = '111111'

  -- AIS Messages

  -- AIS Message Type 1-3 Fields
  local arraismsg123field = {}
  arraismsg123field[1] = {name = 'Message Type', proto = pf.ais_msg_type, length = 6, value = ''}
  arraismsg123field[2] = {name = 'Repeat Indicator', proto = pf.ais_repeat, length = 2, value = ''}
  arraismsg123field[3] = {name = 'MMSI', proto = pf.ais_mmsi, length = 30, value = ''}
  arraismsg123field[4] = {name = 'Navigational Status', proto = pf.ais_nav_stat, length = 4, value = ''}
  arraismsg123field[5] = {name = 'Rate of Turn', proto = pf.ais_rot, length = 8, value = ''}
  arraismsg123field[6] = {name = 'Speed Over Ground', proto = pf.ais_sog, length = 10, value = ''}
  arraismsg123field[7] = {name = 'Position Accuracy', proto = pf.ais_pos_acc, length = 1, value = ''}
  arraismsg123field[8] = {name = 'Longitude', proto = pf.ais_lon, length = 28, value = ''}
  arraismsg123field[9] = {name = 'Latitude', proto = pf.ais_lat, length = 27, value = ''}
  arraismsg123field[10] = {name = 'Course Over Ground', proto = pf.ais_cog, length = 12, value = ''}
  arraismsg123field[11] = {name = 'True Heading', proto = pf.ais_hdg, length = 9, value = ''}
  arraismsg123field[12] = {name = 'Time Stamp', proto = pf.ais_time_stamp, length = 6, value = ''}
  arraismsg123field[13] = {name = 'Maneuver Indicator', proto = pf.ais_maneuver, length = 2, value = ''}
  arraismsg123field[14] = {name = 'Spare', proto = pf.ais_spare, length = 3, value = ''}
  arraismsg123field[15] = {name = 'Receiver Autonomous Integrity Monitoring Flag', proto = pf.ais_raim, length = 1, value = ''}
  arraismsg123field[16] = {name = 'Communication State', proto = pf.ais_comm, length = 19, value = ''}

  local arrsotdmafield = {}
  arrsotdmafield[1] = {name = 'Sync State', proto = pf.ais_comm_sync_state, length = 2, value = ''}
  arrsotdmafield[2] = {name = 'Slot Timeout', proto = pf.ais_comm_slot_timeout, length = 3, value = ''}
  arrsotdmafield[3] = {name = 'Sub Message', proto = nil, length = 12, value = ''}
  
  local arritdmafield = {}
  arritdmafield[1] = {name = 'Sync State', proto = pf.ais_comm_sync_state, length = 2, value = ''}
  arritdmafield[2] = {name = 'Slot Allocation', proto = pf.ais_comm_slot_alloc, length = 13, value = ''}
  arritdmafield[3] = {name = 'Number of Slots', proto = pf.ais_comm_total_slots, length = 2, value = ''}
  arritdmafield[4] = {name = 'Keep Flag', proto = pf.ais_comm_keep_flag, length = 1, value = ''}

  -- Message Type
  local arraismsgtype = {}
  arraismsgtype[1] = 'Position Report Class A'
  arraismsgtype[2] = 'Position Report Class A (Assigned schedule)'
  arraismsgtype[3] = 'Position Report Class A (Response to interrogation)'
  arraismsgtype[4] = 'Base Station Report'
  arraismsgtype[5] = 'Static and Voyage Related Data'
  arraismsgtype[6] = 'Binary Addressed Message'
  arraismsgtype[7] = 'Binary Acknowledge'
  arraismsgtype[8] = 'Binary Broadcast Message'
  arraismsgtype[9] = 'Standard SAR Aircraft Position Report'
  arraismsgtype[10] = 'UTC and Date Inquiry'
  arraismsgtype[11] = 'UTC and Date Response'
  arraismsgtype[12] = 'Addressed Safety Related Message'
  arraismsgtype[13] = 'Safety Related Acknowledgement'
  arraismsgtype[14] = 'Safety Related Broadcast Message'
  arraismsgtype[15] = 'Interrogation'
  arraismsgtype[16] = 'Assignment Mode Command'
  arraismsgtype[17] = 'DGNSS Binary Broadcast Message'
  arraismsgtype[18] = 'Standard Class B CS Position Report'
  arraismsgtype[19] = 'Extended Class B Equipment Position Report'
  arraismsgtype[20] = 'Data Link Management'
  arraismsgtype[21] = 'Aid-to-Navigation Report'
  arraismsgtype[22] = 'Channel Management'
  arraismsgtype[23] = 'Group Assignment Command'
  arraismsgtype[24] = 'Static Data Report'
  arraismsgtype[25] = 'Single Slot Binary Message'
  arraismsgtype[26] = 'Multiple Slot Binary Message With Communications State'
  arraismsgtype[27] = 'Position Report For Long-Range Applications'
  --arraismsgtype[] = ''

  -- Navigation Status
  local arrnavstat = {}
  arrnavstat[0] = 'Underway using engine'
  arrnavstat[1] = 'At anchor'
  arrnavstat[2] = 'Not under command'
  arrnavstat[3] = 'Restricted manoeuverability'
  arrnavstat[4] = 'Constrained by her draught'
  arrnavstat[5] = 'Moored'
  arrnavstat[6] = 'Aground'
  arrnavstat[7] = 'Engaged in Fishing'
  arrnavstat[8] = 'Underway sailing'
  arrnavstat[9] = 'Reserved for future amendment of Navigational Status for HSC'
  arrnavstat[10] = 'Reserved for future amendment of Navigational Status for WIG'
  arrnavstat[11] = 'Reserved for future use'
  arrnavstat[12] = 'Reserved for future use'
  arrnavstat[13] = 'Reserved for future use'
  arrnavstat[14] = 'AIS-SART is active'
  arrnavstat[15] = 'N/A' --'Not defined'

  -- Rate of Turn
  local degree = string.char(0xC2, 0xB0)
  local arrrot = {}
  arrrot['0'] = 'Not turning'
  arrrot['-127'] = string.format('Turning left at more than 720 %s/min (No TI available)', degree) --'Turning left at more than 5deg/30s (No TI available)'
  arrrot['127'] = string.format('Turning right at more than 720 %s/min (No TI available)', degree) --'Turning right at more than 5deg/30s (No TI available)'
  arrrot['128'] = 'N/A'

  -- Speed over Ground
  local arrsog = {}
  arrsog[1022] = 'N/A'
  arrsog[1023] = '102.2 knots or higher'

  -- Position Accuracy
  local arrposacc = {}
  arrposacc[0] = 'Low (> 10m), Autonomous mode'
  arrposacc[1] = 'High (< 10m), Differential mode'

  -- Time Stamp
  local arrtimestamp = {}
  arrtimestamp[60] = 'N/A'
  arrtimestamp[61] = 'Device is in manual input mode' --'EPFS is ...'
  arrtimestamp[62] = 'Device is in estimated (dead reckoning) mode' --'EPFS is ...'
  arrtimestamp[63] = 'Device is inoperative' --'EPFS is ...'

  -- Maneuver Indicator
  local arrmaneuverind = {}
  arrmaneuverind[0] = 'N/A'
  arrmaneuverind[1] = 'No special maneuver'
  arrmaneuverind[2] = 'Special maneuver'

  -- RAIM Flag
  local arrraimflag = {}
  arrraimflag[0] = 'Not in use'
  arrraimflag[1] = 'In use'

  -- Communication State \ Sync State
  local arrsyncstate = {}
  arrsyncstate[0] = 'UTC direct'
  arrsyncstate[1] = 'UTC indirect'
  arrsyncstate[2] = 'Base station'
  arrsyncstate[3] = 'Number of received stations'

  -- Communication State \ Slot Timeout
  local arrslottimeout = {}
  arrslottimeout[0] = 'Last transmission in this slot' --'0 frame is left until slot change'
  arrslottimeout[1] = '1 frame is left until slot change'
  arrslottimeout[2] = '2 frames are left until slot change'
  arrslottimeout[3] = '3 or more frames are left until slot change'

  -- Communication State \ Sub Message
  local arrsubmsg = {}
  arrsubmsg[0] = {name = 'Slot Offset', proto = pf.ais_comm_slot_offset}
  arrsubmsg[1] = {name = 'Hours and Minutes', proto = pf.ais_comm_hhmm}
  arrsubmsg[2] = {name = 'Slot Number', proto = pf.ais_comm_slot_num}
  arrsubmsg[3] = {name = 'Received Stations', proto = pf.ais_comm_rx_stations}
  --

  -- Check payload for NMEA
  function isNMEA(buffer)
    local nmea = false
    local bufflen = #buffer():string()
    if bufflen > 11 then
      local firstbyte = buffer(0, 1):string()
      local crcbyte = buffer(bufflen - 5, 1):string()
      --local lastbytes = buffer(bufflen - 2, 2):string() --0x0D 0x0A
      if ((firstbyte == '$') or (firstbyte == '!')) and (crcbyte == '*') then
        nmea = true
      end
    end
    return nmea
  end

  -- Parsing messages in packet
  function parseMessages(buffer)
    local buffstr = buffer():string() or ''
    local pattern = '()([%!%$]%u%u%u%u[%w%+%-%.%,%:%;%<%=%>%?%@%`]+%*%x%x)()' -- ...%x%x()$'
    local arrmessage = {}
    for itstart, item, itfinish in buffstr:gmatch(pattern) do
      local message = {
        start = itstart - 1,
        length = itfinish - itstart,
        --length = #item,
        text = item
      }
      table.insert(arrmessage, message)
    end
    return arrmessage
  end

  -- Verify message checksum
  function verifyChecksum(message)
    local msgcrc = message.text:sub(-2)				-- HEX строка
    --msgcrc = tonumber(msgcrc, 16)				-- перевод в DEC число
    local calccrc = string.byte(message.text, 2)			-- DEC число
    for i = 3, #message.text - 3 do
      local ascii = string.byte(message.text, i)		-- DEC число
      calccrc = bit32.bxor(calccrc, ascii)			-- DEC число
    end
    msgcrc = string.format('0x%s', msgcrc)
    calccrc = string.format('0x%02X', calccrc)			-- перевод в HEX строку
    local crcstat = 'Unverified'
    if calccrc == msgcrc then
      crcstat = 'Good'
    else
      crcstat = 'Bad'
    end
    return msgcrc, calccrc, crcstat
  end

  -- Parsing fields in message
  function parseFields(message)
    local pattern = '[%!%$%,%*]()([%w%+%-%.%:%;%<%=%>%?%@%`%x]*)()'
    local arrfield = {}
    for itstart, item, itfinish in message.text:gmatch(pattern) do
      local field = {
        start = itstart - 1,
        length = itfinish - itstart,
        --length = #item,
        value = item
      }
      table.insert(arrfield, field)
    end
    return arrfield
  end

  -- Convert payload of encapsulated message into 6-bit code string
  function str2SixBitStr(payload)
    arrsixbit = {} -- Table temp
    --sixbitstr = '' -- String temp
    for i = 1, #payload do
      -- Table method
      --sixbitstr = string.format('%s%s', sixbitstr, arrsixbitcode[payload:sub(i, i)]) -- Table temp
      arrsixbit[#arrsixbit + 1] = arrsixbitcode[payload:sub(i, i)] -- String temp
      --
      -- Mathematical method
      --local arrbit = {}
      --local ascii = string.byte(payload:sub(i, i)) + 80
      --if ascii > 168 then
      --  ascii = ascii - 8
      --end
      --repeat        
      --  arrbit[#arrbit + 1] = tostring(ascii % 2)
      --  ascii = math.floor(ascii / 2)
      --until ascii == 0
      --arrsixbit[#arrsixbit + 1] = table.concat(arrbit):reverse():sub(3)
      --
    end
    return table.concat(arrsixbit) -- Table temp
    --return sixbitstr -- String temp
  end

  -- Parsing fields in AIS Message (Type 1-3)
  function parseAIS(message)
    --local start = 0
    local start = 1
    local finish = 0
    local aismsgtype = tonumber(message:sub(1, arraismsg123field[1].length), 2)
    if runonce then
      if aismsgtype < 3 then
        table.remove(arraismsg123field)
        for _, field in ipairs(arrsotdmafield) do
          table.insert(arraismsg123field, field)
        end
      end
      if aismsgtype == 3 then
        table.remove(arraismsg123field)
        for _, field in ipairs(arritdmafield) do
          table.insert(arraismsg123field, field)
        end
      end
      runonce = false
    end
    for _, field in ipairs(arraismsg123field) do
      local fieldlen = field.length
      finish = finish + fieldlen
      field.value = message:sub(start, finish)
      start = start + fieldlen
    end
  end

  -- Processing AIS Field ROT
  function aisFieldROT(value)
    local fieldvalue = bin2SignInt(value)
    local sign = fieldvalue
    fieldvalue = math.abs(fieldvalue)
    if (fieldvalue >= 1) and (fieldvalue <= 126) then
      fieldvalue = math.pow(fieldvalue / 4.733, 2) --(fieldvalue / 4.733) * (fieldvalue / 4.733)
      local direct = 'right'
      if sign < 0 then
        direct = 'left'
      end
      local degree = string.char(0xC2, 0xB0)
      fieldvalue = string.format('%s %s %s %.1f %s/min', 'Turning', direct, 'at', fieldvalue, degree) --'deg/min'
    else
      fieldvalue = lookup (arrrot, tostring(fieldvalue))
    end
    return fieldvalue
  end

  -- Processing AIS Field Latitude/Longitude
  function aisFieldLotLan(value, max, positive, negative)
    local fieldvalue = bin2SignInt(value) / 600000
    if fieldvalue < max then
      local direct = positive
      if fieldvalue < 0 then
        fieldvalue = fieldvalue * -1
        direct = negative
      end
      local degree = string.char(0xC2, 0xB0)
      fieldvalue = string.format('%.4f%s%s', fieldvalue, degree, direct)
    else
      fieldvalue = 'N/A'
    end
    return fieldvalue
  end

  -- Output AIS fields to tree
  function outputAISFields(buffer, tree)
    local degree = string.char(0xC2, 0xB0)
    local aismsgtype
    for _, field in ipairs(arraismsg123field) do
      local fieldvalue
      if field.name == 'Message Type' then
        aismsgtype = tonumber(field.value, 2)
        fieldvalue = aismsgtype
        fieldvalue = lookup(arraismsgtype, fieldvalue)
      end
      if field.name == 'Reapet Indicator' then
        fieldvalue = tonumber(field.value, 2)
        if fieldvalue == 3 then
          fieldvalue = 'Do not repeat'
        end
      end
      if field.name == 'Navigational Status' then
        fieldvalue = tonumber(field.value, 2)
        fieldvalue = lookup(arrnavstat, fieldvalue)
      end
      if field.name == 'Rate of Turn' then
        fieldvalue = aisFieldROT(field.value)
      end
      if field.name == 'Speed Over Ground' then
        fieldvalue = tonumber(field.value, 2)
        if fieldvalue < 1022 then
          fieldvalue = string.format('%s knot(s)', fieldvalue / 10)
        else
          fieldvalue = lookup (arrsog, fieldvalue)
        end
      end
      if field.name == 'Position Accuracy' then
        fieldvalue = tonumber(field.value, 2)
        fieldvalue = lookup (arrposacc, fieldvalue)
      end      
      if field.name == 'Longitude' then
        fieldvalue = aisFieldLotLan(field.value, 181, 'E', 'W')
      end
      if field.name == 'Latitude' then
        fieldvalue = aisFieldLotLan(field.value, 91, 'N', 'S')
      end
      if field.name == 'Course Over Ground' then
        fieldvalue = tonumber(field.value, 2)
        if fieldvalue < 3600 then
          fieldvalue = string.format('%s%s', fieldvalue / 10, degree)
        else
          fieldvalue = 'N/A'
        end
      end
      if field.name == 'True Heading' then
        fieldvalue = tonumber(field.value, 2)
        if fieldvalue < 511 then
          fieldvalue = string.format('%s%s', fieldvalue, degree)
        else
          fieldvalue = 'N/A'
        end
      end
      if field.name == 'Time Stamp' then
        fieldvalue = tonumber(field.value, 2)
        if fieldvalue < 60 then
          fieldvalue = string.format('%ss', fieldvalue)
        else
          fieldvalue = lookup(arrtimestamp, fieldvalue)
        end
      end
      if field.name == 'Maneuver Indicator' then
        fieldvalue = tonumber(field.value, 2)
        fieldvalue = lookup(arrmaneuverind, fieldvalue)
      end
      if field.name == 'Receiver Autonomous Integrity Monitoring Flag' then
        fieldvalue = tonumber(field.value, 2)
        fieldvalue = lookup(arrraimflag, fieldvalue)
      end
      if field.name == 'Sync State' then
        fieldvalue = tonumber(field.value, 2)
        fieldvalue = lookup(arrsyncstate, fieldvalue)
      end
      if aismsgtype < 3 then
        if field.name == 'Slot Timeout' then
          fieldvalue = tonumber(field.value, 2)
          fieldvalue = lookup(arrslottimeout, fieldvalue)
        end
         if field.name == 'Sub Message' then
          local index = tonumber(arraismsg123field[#arraismsg123field - 1].value, 2)
          field.name = arrsubmsg[index].name
          field.proto = arrsubmsg[index].proto
        end
        if field.name == 'Hours and Minutes' then
          local hour = tonumber(field.value:sub(1, 5), 2)
          local minute = tonumber(field.value:sub(6, 12), 2)
          fieldvalue = string.format('%s:%s', hour, minute)
        end
      end
      if fieldvalue == nil then
      fieldvalue = tonumber(field.value, 2) or ''
      end
      --local commtree = tree:add(buffer(), 'Communication State', '(SOTDMA)')
      tree:add(field.proto, buffer(), fieldvalue)
      --tree:add(field.proto, buffer(), string.format('%s (%s)', fieldvalue, field.value))
    end
  end

  -- Output header to tree
  function outputHeader(buffer, tree, start, header)
    --local start = msgstart + 1
    local headerlen = #header
    local talkerlen = 2
    local talker
    if header:sub(1,1) == 'P' then
      talkerlen = 4
      local arrtalkerhort = header:sub(1, talkerlen)
      talker = arrtalkerprop[arrtalkerhort] or string.format('Proprietary (%s)', arrtalkerhort:sub(2)) -- lookup(arrtalkerprop, header:sub(1, talkerlen))
    else
      local arrtalkerhort = header:sub(1, talkerlen)
      talker = arrtalker[arrtalkerhort] or string.format('Unknown (%s)', arrtalkerhort) -- lookup(arrtalker, header:sub(1, talkerlen))
    end
    local typeshort = header:sub(talkerlen + 1)
    local msgtype = lookup(arrmsgtype, typeshort)
    local tagtree = tree:add(buffer(start, headerlen), 'Tag: ')
    tagtree:append_text(string.format('%s - %s / %s', header, talker, msgtype))
    tagtree:add(pf.header, buffer(start, headerlen), header)
    tagtree:add(pf.talker, buffer(start, talkerlen), talker)
    tagtree:add(pf.msgtype, buffer(start + talkerlen, headerlen - talkerlen), msgtype)
    return talker, typeshort, msgtype
  end

local arraismsg = {}

  -- Output fields to tree
  function outputFields(buffer, tree, msgstart, typeshort, fields)
    -- Known type
    local isknowntype = false
    local arrknownfield = {}
    local i = 1
    for _, msgfield in ipairs(arrmsgfield) do
      if msgfield.msgtype == typeshort then
        isknowntype = true
        arrknownfield[i] = msgfield --arrknownfield[#arrknownfield + 1]
        i = i + 1
      end
    end
    --
    if isknowntype then
      local index = 2
      for _, knownfield in ipairs(arrknownfield) do
        start = msgstart + fields[index].start
        local fieldlen = fields[index].length
        local fieldvalue = fields[index].value or ''
        if fieldvalue ~= '' then
          local degree = string.char(0xC2, 0xB0)
          local minute = string.char(0xE2, 0x80, 0xB2)
          if knownfield.name == 'Latitude' then
            fieldvalue = string.format('%s%s%s%s', fieldvalue:sub(1, 2), degree, fieldvalue:sub(3), minute)
          end
          if knownfield.name == 'Longitude' then
            fieldvalue = string.format('%s%s%s%s', fieldvalue:sub(1, 3), degree, fieldvalue:sub(4), minute)
          end
          if knownfield.name == 'Position Fix' then
            fieldvalue = lookup(arrposfix, fieldvalue)
          end
          if knownfield.name == 'Time' then
            fieldvalue = string.format('%s:%s:%s', fieldvalue:sub(1, 2), fieldvalue:sub(3, 4), fieldvalue:sub(5))
          end
          if knownfield.name == 'Date' then
            fieldvalue = string.format('%s-%s-%s', fieldvalue:sub(1, 2), fieldvalue:sub(3, 4), fieldvalue:sub(5))
          end
          if knownfield.name == 'Speed Over Ground' then
            fieldvalue = string.format('%s knot(s)', fieldvalue)
          end
          if knownfield.name == 'Course Over Ground' then
            fieldvalue = string.format('%s%s', fieldvalue, degree)
          end
          if knownfield.name == 'Magnetic Varuation' then
            fieldvalue = string.format('%s%s', fieldvalue, degree)
          end
          if knownfield.name == 'Status' then
            fieldvalue = lookup(arrstatus, fieldvalue)
          end
          if knownfield.name == 'AIS Channel' then
            fieldvalue = lookup(arraischannel, fieldvalue)
          end
          if knownfield.name == 'Encapsulated Radio Message' then
            fieldvalue = fieldvalue:sub(1, #fieldvalue - fields[#fields - 1].value)
            local aistree = tree:add(buffer(start, fieldlen), 'AIS Message:', fieldvalue)
            local sixbitstr = str2SixBitStr(fieldvalue)
	    if fields[3].value == fields[2].value then
	      table.insert(arraismsg, sixbitstr)
	    else
	      arraismsg[#arraismsg].value = arraismsg[#arraismsg].value .. sixbitstr 
	    end
            parseAIS(sixbitstr)
            --aistree:add(buffer(start, fieldlen), '6-bit Code:', sixbitstr)
            outputAISFields(buffer(start, fieldlen), aistree)
          end
        end
        if knownfield.length == 2 then
          if fields[index].length == 0 then
            fieldlen = 0
          else
            fieldlen = fieldlen + fields[index + 1].length + 1
            fieldvalue = string.format('%s%s', fieldvalue, fields[index + 1].value)
            index = index + 1
          end
        end
        tree:add(knownfield.proto, buffer(start, fieldlen), fieldvalue)
        index = index + 1
      end
    else
      for index, field in ipairs(fields) do
        if (index > 1) and (index < #fields) then
          local fieldvalue = field.value
          if fieldvalue ~= '' then
            start = msgstart + field.start
            tree:add(pf.fields, buffer(start, field.length), fieldvalue) --#' .. index .. ': '
          end
        end
      end
    end
  end

  -- The NMEA protocol dissector
  function NMEAPROTO.dissector(buffer, pinfo, tree)
    if not isNMEA(buffer) then -- and tree:referenced(NMEA)
      return
    end
    pinfo.cols.protocol = 'NMEA'
    local messages = parseMessages(buffer)							-- Parsing messages in packet
    local msgcount = #messages
    local colinfo = ''
    local nmeatree = tree:add(NMEAPROTO, buffer())
    nmeatree:add(pf.count, msgcount)
    for index, message in ipairs(messages) do
      local msgtree = nmeatree:add(buffer(message.start, message.length), string.format('Message #%s:', index), message.text)
      local msgformat = 'Parametric'
      if message.text:sub(1,1) == '!' then
        msgformat = 'Encapsulation'
      end
      msgtree:add(pf.format, buffer(message.start, 1), msgformat)
      local fields = parseFields(message)							-- Parsing fields in message
      local header = fields[1].value
      local msgstart = message.start
      local talker, typeshort, msgtype = outputHeader(buffer, msgtree, msgstart + 1, header)	-- Output header to tree
      outputFields(buffer, msgtree, msgstart, typeshort, fields)				-- Output fields to tree
      -- Output checksum to tree
      local msgcrc, calccrc, crcstat = verifyChecksum(message)					-- Verify message checksum
      local crcstart = message.start + message.length - 2
      msgtree:add(buffer(crcstart, 2), 'Checksum:', msgcrc)
      local crctree = msgtree:add(pf.crcstat, crcstat):set_generated(true)
      crctree:add(buffer(crcstart, 2), 'Calculated Checksum:', calccrc):set_generated(true)
      --
      -- Output checksum expert info to tree
      --if not (msgcrc == calccrc) then
        --local expert = ProtoExpert.new('bad_crc', 'Bad Checksum', expert.group.CHECKSUM, expert.severity.WARN)
        --NMEAPROTO.experts = { expert }
        --msgtree:add_proto_expert_info(expert, 'Bad Checksum')
        --msgtree:add_tvb_expert_info(expert, buffer())
      --end
      --
for _, aismsg in ipairs(arraismsg) do
local aistree = tree:add('AIS Message')
parseAIS(aismsg, aistree)
outputAISFields(buffer(), aistree)
end
arraismsg = {}
      -- Build pinfo.cols.info
      if index == 1 then
        colinfo = header
        if msgcount == 1 then
          colinfo = string.format('%s - %s / %s', colinfo, talker, msgtype)
        end
      else
        colinfo = string.format ('%s, %s', colinfo, header)
      end
      ---
    end
    pinfo.cols.info = colinfo
  end

  -- Register the dissector
  udp_table = DissectorTable.get('udp.port')
  udp_table:add(2000, NMEAPROTO)

  --function AISPROTO.dissector(buffer, pinfo, tree)
  --  tree:add(AISPROTO, buffer())
  --end

end
