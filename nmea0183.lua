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

--#region Helper Functions

--
-- lookup a index in list, if missing return 'Unknown (index'
local function lookup(arr, index)
  local item = arr[index]
  if item == nil then
    return string.format('Unknown (%s)', index)
  end
  return item
end

--
-- Correct rounding
local function round(x)
  return x >= 0 and math.floor(x+0.5) or math.ceil(x-0.5)
end

--
-- bin2SignInt converts a binary value to a signed integer
local function bin2SignInt(value)
  local sign = value:sub(1, 1)
  value = tonumber(value:sub(2), 2)
  if sign == '1' then
    value = value * -1
  end
  return value
end


-- verifyChecksum takes message and returns msgcrc, calccrc 
-- and stat: string['Valid'|'Invalid']
local function verifyChecksum(message)
  local msgcrc = message.text:sub(-2)				-- HEX ������
  --msgcrc = tonumber(msgcrc, 16)				-- ������� � DEC �����
  local calccrc = string.byte(message.text, 2)			-- DEC �����
  for i = 3, #message.text - 3 do
    local ascii = string.byte(message.text, i)		-- DEC �����
    calccrc = bit32.bxor(calccrc, ascii)			-- DEC �����
  end
  msgcrc = string.format('0x%s', msgcrc)
  local calcCrcHex = string.format('0x%02X', calccrc)			-- ������� � HEX ������
  local crcstat = 'Unverified'
  if calccrc == msgcrc then
    crcstat = 'Valid'
  else
    crcstat = 'Invalid'
  end
  return msgcrc, calccrc, crcstat
end


-- 
-- isNMEA checks payload for NMEA specifies
local function isNMEA(buffer)
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

--#endregion


--#region Constants & lookup values

-- Talker ID
local TALKERS = {}
TALKERS['AB'] = 'Independent AIS Base Station'
TALKERS['AD'] = 'Dependant AIS Base Station'
TALKERS['AG'] = 'Autopilot - General'
TALKERS['AI'] = 'Mobile AIS Station, Class A or B'
TALKERS['AN'] = 'Aid to Navigation AIS Station'
TALKERS['AP'] = 'Autopilot - Magnetic'
TALKERS['AR'] = 'AIS Receiving Station'
TALKERS['AS'] = 'AIS Limited Base Station'
TALKERS['AT'] = 'AIS Transmitting Station'
TALKERS['AX'] = 'AIS Simplex Repeater Station'
TALKERS['BD'] = 'Beidou Positioning System Receiver'
TALKERS['BI'] = 'Bilge Systems'
TALKERS['BN'] = 'Bridge Navigational Watch Alarm System (BNWAS)'
TALKERS['CA'] = 'Central Alarm Management'
TALKERS['CD'] = 'Communications - Digital Selective Calling (DSC)'
TALKERS['CR'] = 'Communications - Data Receiver'
TALKERS['CS'] = 'Communications - Satellite'
TALKERS['CT'] = 'Communications - Radio-Telephone MF-HF'
TALKERS['CV'] = 'Communications - Radio-Telephone VHF'
TALKERS['CX'] = 'Communications - Scanning Receiver'
TALKERS['DE'] = 'Decca navigator'
TALKERS['DF'] = 'Radio Direction Finder'
TALKERS['DM'] = 'Velocity Sensor, Speed Log, Water, Magnetic'
TALKERS['DP'] = 'Dynamic Position'
TALKERS['DU'] = 'Duplex Repeater Station'
TALKERS['EC'] = 'Electronic Chart System (ECS)'
TALKERS['EI'] = 'Electronic Chart Display and Information System (ECDIS)'
TALKERS['EP'] = 'Emergency Position Indicating Radio Beacon (EPIRB)'
TALKERS['ER'] = 'Engine Room Monitoring Systems'
TALKERS['FD'] = 'Fire Door Controller/Monitoring Point'
TALKERS['FE'] = 'Fire Extinguisher System'
TALKERS['FR'] = 'Fire Detection Point'
TALKERS['FR'] = 'Franson software'
TALKERS['FS'] = 'Fire Sprinkler System'
TALKERS['GA'] = 'Galileo positioning system receiver'
TALKERS['GB'] = 'BeiDou positioning system receiver'
TALKERS['GC'] = 'Unknown positioning system receiver'
TALKERS['GI'] = 'NavIC (IRNSS)'
TALKERS['GL'] = 'GLONASS Positioning System Receiver'
TALKERS['GN'] = 'Global Navigation Satellite System (GNSS)'
TALKERS['GP'] = 'Global Positioning System Receiver (GPS)'
TALKERS['GQ'] = 'QZSS'
TALKERS['GY'] = 'Global Positioning System Receiver (GPS)'
TALKERS['HC'] = 'Compass, Magnetic'
TALKERS['HD'] = 'Hull Door Controller/Monitoring Panel'
TALKERS['HE'] = 'Gyro, North Seeking'
TALKERS['HF'] = 'Fluxgate'
TALKERS['HN'] = 'Gyro, Non North Seeking'
TALKERS['HS'] = 'Hull Stress Monitoring'
TALKERS['II'] = 'Integrated Instrumention'
TALKERS['IN'] = 'Integrated Navigation'
TALKERS['IO'] = 'Input Output Information'
TALKERS['JA'] = 'Alarm and Monitoring System'
TALKERS['JB'] = 'Reefer Monitoring System'
TALKERS['JC'] = 'Power Management System'
TALKERS['JD'] = 'Propulsion Control System'
TALKERS['JE'] = 'Engine Control Console'
TALKERS['JF'] = 'Propulsion Boiler'
TALKERS['JG'] = 'Auxiliary Boiler'
TALKERS['JH'] = 'Electronic Governor System'
TALKERS['LC'] = 'Loran C'
TALKERS['MX'] = 'Multiplexer'
TALKERS['NA'] = 'Navigation - Unknown'
TALKERS['NL'] = 'Navigation Light Controller'
TALKERS['NW'] = 'Navigation - Unknown'
TALKERS['QZ'] = 'QZSS regional GPS augmentation system'
TALKERS['RA'] = 'RADAR and/or ARPA (RADAR plotting)'
TALKERS['RB'] = 'Record Book'
TALKERS['RC'] = 'Propulsion Machinery Including Remote Control'
TALKERS['RI'] = 'Rudder Angle Indicator'
TALKERS['SA'] = 'Physical Shore AIS Station'
TALKERS['SD'] = 'Sounder, depth'
TALKERS['SE'] = 'True Heading'
TALKERS['SG'] = 'Steering Gear/Steering Engine'
TALKERS['SN'] = 'Electronic Positioning System other - general'
TALKERS['SP'] = 'Speed Sensor'
TALKERS['SS'] = 'Scanning Sounder'
TALKERS['ST'] = 'Skytraq debug output'
TALKERS['TC'] = 'Track Control System'
TALKERS['TI'] = 'Turn Rate Indicator'
TALKERS['TM'] = 'Transas VTS / SML tracking system'
TALKERS['TR'] = 'TRANSIT Navigation System'
TALKERS['U0'] = 'User Configured talker identifier 0'
TALKERS['U1'] = 'User Configured talker identifier 1'
TALKERS['U2'] = 'User Configured talker identifier 2'
TALKERS['U3'] = 'User Configured talker identifier 3'
TALKERS['U4'] = 'User Configured talker identifier 4'
TALKERS['U5'] = 'User Configured talker identifier 5'
TALKERS['U6'] = 'User Configured talker identifier 6'
TALKERS['U7'] = 'User Configured talker identifier 7'
TALKERS['U8'] = 'User Configured talker identifier 8'
TALKERS['U9'] = 'User Configured talker identifier 9'
TALKERS['UP'] = 'Microprocessor Controller'
TALKERS['VA'] = 'VHF Data Exchange System, ASM'
TALKERS['VD'] = 'Velocity Sensor, Doppler, other/general'
TALKERS['VM'] = 'Velocity Sensor, Speed Log, Water, Magnetic'
TALKERS['VR'] = 'Voyage Data Recorder'  
TALKERS['VS'] = 'VHF Data Exchange System, Satellite'
TALKERS['VT'] = 'VHF Data Exchange System, Terrestrial'
TALKERS['VW'] = 'Velocity Sensor, Speed Log, Water, Mechanical'
TALKERS['WD'] = 'Watertight Door Controller/Monitoring Panel'
TALKERS['WI'] = 'Weather Instruments'
TALKERS['YX'] = 'Transducer'
TALKERS['ZA'] = 'Timekeeper - Atomic Clock'
TALKERS['ZC'] = 'Timekeeper - Chronometer'
TALKERS['ZQ'] = 'Timekeeper - Quartz'
TALKERS['ZV'] = 'Timekeeper - Radio Update, WWV or WWVH'



-- Talker Proprietary Manufacturer's Code
local TALKER_PROPS = {}
-- Proprietary \ Proprietary Code \ Vendor Specific
TALKER_PROPS['PAAR'] = 'Proprietary (Asian American Resources)'
TALKER_PROPS['PACE'] = 'Proprietary (Auto-Comm Engineering)'
TALKER_PROPS['PACR'] = 'Proprietary (ACR Electronics)'
TALKER_PROPS['PACS'] = 'Proprietary (Arco Solar)'
TALKER_PROPS['PACT'] = 'Proprietary (Advanced Control Technology)'
TALKER_PROPS['PAGI'] = 'Proprietary (Airguide Instrument)'
TALKER_PROPS['PAHA'] = 'Proprietary (Autohelm of America)'
TALKER_PROPS['PAIP'] = 'Proprietary (Aiphone)'
TALKER_PROPS['PALD'] = 'Proprietary (Alden Electronics)'
TALKER_PROPS['PAMR'] = 'Proprietary (AMR Systems)'
TALKER_PROPS['PAMT'] = 'Proprietary (Airmar Technology)'
TALKER_PROPS['PANS'] = 'Proprietary (Antenna Specialists)'
TALKER_PROPS['PANX'] = 'Proprietary (Analytyx Electronic Systems)'
TALKER_PROPS['PANZ'] = 'Proprietary (Anschutz of America)'
TALKER_PROPS['PAPC'] = 'Proprietary (Apelco)'
TALKER_PROPS['PAPN'] = 'Proprietary (American Pioneer)'
TALKER_PROPS['PAPX'] = 'Proprietary (Amperex)'
TALKER_PROPS['PAQC'] = 'Proprietary (Aqua-Chem)'
TALKER_PROPS['PAQD'] = 'Proprietary (Aquadynamics)'
TALKER_PROPS['PAQM'] = 'Proprietary (Aqua Meter Instrument)'
TALKER_PROPS['PASH'] = 'Proprietary (Ashtech)'
TALKER_PROPS['PASP'] = 'Proprietary (American Solar Power)'
TALKER_PROPS['PATE'] = 'Proprietary (Aetna Engineering)'
TALKER_PROPS['PATM'] = 'Proprietary (Atlantic Marketing)'
TALKER_PROPS['PATR'] = 'Proprietary (Airtron)'
TALKER_PROPS['PATV'] = 'Proprietary (Activation)'
TALKER_PROPS['PAVN'] = 'Proprietary (Advanced Navigation)'
TALKER_PROPS['PAWA'] = 'Proprietary (Awa New Zealand)'
TALKER_PROPS['PBBL'] = 'Proprietary (BBL Industries)'
TALKER_PROPS['PBBR'] = 'Proprietary (BBR and Associates)'
TALKER_PROPS['PBDV'] = 'Proprietary (Brisson Development)'
TALKER_PROPS['PBEC'] = 'Proprietary (Boat Electric)'
TALKER_PROPS['PBGS'] = 'Proprietary (Barringer Geoservice)'
TALKER_PROPS['PBGT'] = 'Proprietary (Brookes and Gatehouse)'
TALKER_PROPS['PBHE'] = 'Proprietary (BH Electronics)'
TALKER_PROPS['PBHR'] = 'Proprietary (Bahr Technologies)'
TALKER_PROPS['PBLB'] = 'Proprietary (Bay Laboratories)'
TALKER_PROPS['PBME'] = 'Proprietary (Bartel Marine Electronics)'
TALKER_PROPS['PBNI'] = 'Proprietary (Neil Brown Instrument Systems)'
TALKER_PROPS['PBNS'] = 'Proprietary (Bowditch Navigation Systems)'
TALKER_PROPS['PBRM'] = 'Proprietary (Mel Barr)'
TALKER_PROPS['PBRY'] = 'Proprietary (Byrd Industries)'
TALKER_PROPS['PBTH'] = 'Proprietary (Benthos)'
TALKER_PROPS['PBTK'] = 'Proprietary (Baltek)'
TALKER_PROPS['PBTS'] = 'Proprietary (Boat Sentry)'
TALKER_PROPS['PBXA'] = 'Proprietary (Bendix-Avalex)'
TALKER_PROPS['PCAT'] = 'Proprietary (Catel)'
TALKER_PROPS['PCBN'] = 'Proprietary (Cybernet Marine Products)'
TALKER_PROPS['PCCA'] = 'Proprietary (Copal of America)'
TALKER_PROPS['PCCC'] = 'Proprietary (Coastal Communications)'
TALKER_PROPS['PCCL'] = 'Proprietary (Coastal Climate)'
TALKER_PROPS['PCCM'] = 'Proprietary (Coastal Communications)'
TALKER_PROPS['PCDC'] = 'Proprietary (Cordic)'
TALKER_PROPS['PCEC'] = 'Proprietary (Ceco Communications)'
TALKER_PROPS['PCHI'] = 'Proprietary (Charles Industries)'
TALKER_PROPS['PCKM'] = 'Proprietary (Cinkel Marine Electronics Industries)'
TALKER_PROPS['PCMA'] = 'Proprietary (Societe Nouvelle D\'Equiment du Calvados)'
TALKER_PROPS['PCMC'] = 'Proprietary (Coe Manufacturing)'
TALKER_PROPS['PCME'] = 'Proprietary (Cushman Electronics)'
TALKER_PROPS['PCMP'] = 'Proprietary (C-Map)'
TALKER_PROPS['PCMS'] = 'Proprietary (Coastal Marine Sales)'
TALKER_PROPS['PCMV'] = 'Proprietary (CourseMaster USA)'
TALKER_PROPS['PCNI'] = 'Proprietary (Continental Instruments)'
TALKER_PROPS['PCNV'] = 'Proprietary (Coastal Navigator)'
TALKER_PROPS['PCNX'] = 'Proprietary (Cynex Manufactoring)'
TALKER_PROPS['PCPL'] = 'Proprietary (Computrol)'
TALKER_PROPS['PCPN'] = 'Proprietary (Compunav)'
TALKER_PROPS['PCPS'] = 'Proprietary (Columbus Positioning)'
TALKER_PROPS['PCPT'] = 'Proprietary (CPT)'
TALKER_PROPS['PCRE'] = 'Proprietary (Crystal Electronics)'
TALKER_PROPS['PCRO'] = 'Proprietary (The Caro Group)'
TALKER_PROPS['PCRY'] = 'Proprietary (Crystek Crystals)'
TALKER_PROPS['PCSI'] = 'Proprietary (Communication Systems Int.)'
TALKER_PROPS['PCSM'] = 'Proprietary (Comsat Maritime Services)'
TALKER_PROPS['PCST'] = 'Proprietary (Cast)'
TALKER_PROPS['PCSV'] = 'Proprietary (Combined Services)'
TALKER_PROPS['PCTA'] = 'Proprietary (Current Alternatives)'
TALKER_PROPS['PCTB'] = 'Proprietary (Cetec Benmar)'
TALKER_PROPS['PCTC'] = 'Proprietary (Cell-tech Communications)'
TALKER_PROPS['PCTE'] = 'Proprietary (Castle Electronics)'
TALKER_PROPS['PCTL'] = 'Proprietary (C-Tech)'
TALKER_PROPS['PCWD'] = 'Proprietary (Cubic Western Data)'
TALKER_PROPS['PCWV'] = 'Proprietary (Celwave R.F.)'
TALKER_PROPS['PCYZ'] = 'Proprietary (cYz)'
TALKER_PROPS['PDCC'] = 'Proprietary (Dolphin Components)'
TALKER_PROPS['PDEB'] = 'Proprietary (Debeg GmbH)'
TALKER_PROPS['PDFI'] = 'Proprietary (Defender Industries)'
TALKER_PROPS['PDGC'] = 'Proprietary (Digicourse)'
TALKER_PROPS['PDME'] = 'Proprietary (Digital Marine Electronics)'
TALKER_PROPS['PDMI'] = 'Proprietary (Datamarine Int.)'
TALKER_PROPS['PDNS'] = 'Proprietary (Dornier System)'
TALKER_PROPS['PDNT'] = 'Proprietary (Del Norte Technology)'
TALKER_PROPS['PDPS'] = 'Proprietary (Danaplus)'
TALKER_PROPS['PDRL'] = 'Proprietary (R.L. Drake)'
TALKER_PROPS['PDSC'] = 'Proprietary (Dynascan)'
TALKER_PROPS['PDYN'] = 'Proprietary (Dynamote)'
TALKER_PROPS['PDYT'] = 'Proprietary (Dytek Laboratories)'
TALKER_PROPS['PEBC'] = 'Proprietary (Emergency Beacon)'
TALKER_PROPS['PECT'] = 'Proprietary (Echotec)'
TALKER_PROPS['PEEV'] = 'Proprietary (EEV)'
TALKER_PROPS['PEFC'] = 'Proprietary (Efcom Communication Systems)'
TALKER_PROPS['PELD'] = 'Proprietary (Electronic Devices)'
TALKER_PROPS['PEMC'] = 'Proprietary (Electric Motion)'
TALKER_PROPS['PEMS'] = 'Proprietary (Electro Marine Systems)'
TALKER_PROPS['PENA'] = 'Proprietary (Energy Analysts)'
TALKER_PROPS['PENC'] = 'Proprietary (Encron)'
TALKER_PROPS['PEPM'] = 'Proprietary (Epsco Marine)'
TALKER_PROPS['PEPT'] = 'Proprietary (Eastprint)'
TALKER_PROPS['PERC'] = 'Proprietary (The Ericsson)'
TALKER_PROPS['PESA'] = 'Proprietary (European Space Agency)'
TALKER_PROPS['PFDN'] = 'Proprietary (Fluiddyne)'
TALKER_PROPS['PFEC'] = 'Proprietary (Furuno Electric (??))'
TALKER_PROPS['PFHE'] = 'Proprietary (Fish Hawk Electronics)'
TALKER_PROPS['PFJN'] = 'Proprietary (Jon Fluke)'
TALKER_PROPS['PFMM'] = 'Proprietary (First Mate Marine Autopilots)'
TALKER_PROPS['PFNT'] = 'Proprietary (Franklin Net and Twine)'
TALKER_PROPS['PFRC'] = 'Proprietary (The Fredericks)'
TALKER_PROPS['PFTG'] = 'Proprietary (T.G. Faria)'
TALKER_PROPS['PFUJ'] = 'Proprietary (Fujitsu Ten of America)'
TALKER_PROPS['PFUR'] = 'Proprietary (Furuno USA)'
TALKER_PROPS['PGAM'] = 'Proprietary (GRE America)'
TALKER_PROPS['PGCA'] = 'Proprietary (Gulf Cellular Associates)'
TALKER_PROPS['PGES'] = 'Proprietary (Geostar)'
TALKER_PROPS['PGFC'] = 'Proprietary (Graphic Controls)'
TALKER_PROPS['PGIS'] = 'Proprietary (Galax Integrated Systems)'
TALKER_PROPS['PGLO'] = 'Proprietary (Quectel)'
TALKER_PROPS['PGPI'] = 'Proprietary (Global Positioning Instrument)'
TALKER_PROPS['PGRM'] = 'Proprietary (Garmin)'
TALKER_PROPS['PGSC'] = 'Proprietary (Gold Star)'
TALKER_PROPS['PGTO'] = 'Proprietary (Gro Electronics)'
TALKER_PROPS['PGVE'] = 'Proprietary (Guest)'
TALKER_PROPS['PGVT'] = 'Proprietary (Great Valley Technology)'
TALKER_PROPS['PHAL'] = 'Proprietary (HAL Communications)'
TALKER_PROPS['PHAR'] = 'Proprietary (Harris)'
TALKER_PROPS['PHIG'] = 'Proprietary (Hy-Gain)'
TALKER_PROPS['PHIT'] = 'Proprietary (Hi-Tec)'
TALKER_PROPS['PHPK'] = 'Proprietary (Hewlett-Packard)'
TALKER_PROPS['PHRC'] = 'Proprietary (Harco Manufacturing)'
TALKER_PROPS['PHRT'] = 'Proprietary (Hart Systems)'
TALKER_PROPS['PHTI'] = 'Proprietary (Heart Interface)'
TALKER_PROPS['PHUL'] = 'Proprietary (Hull Electronics)'
TALKER_PROPS['PHWM'] = 'Proprietary (Honeywell Marine Systems)'
TALKER_PROPS['PICO'] = 'Proprietary (Icom of America)'
TALKER_PROPS['PIFD'] = 'Proprietary (Int. Fishing Devices)'
TALKER_PROPS['PIFI'] = 'Proprietary (Instruments for Industry)'
TALKER_PROPS['PIME'] = 'Proprietary (Imperial Marine Equipment)'
TALKER_PROPS['PIMI'] = 'Proprietary (I.M.I.)'
TALKER_PROPS['PIMM'] = 'Proprietary (ITT MacKay Marine)'
TALKER_PROPS['PIMP'] = 'Proprietary (Impulse Manufacturing)'
TALKER_PROPS['PIMT'] = 'Proprietary (Int. Marketing and Trading)'
TALKER_PROPS['PINM'] = 'Proprietary (Inmar Electronic and Sales)'
TALKER_PROPS['PINT'] = 'Proprietary (Intech)'
TALKER_PROPS['PIRT'] = 'Proprietary (Intera Technologies)'
TALKER_PROPS['PIST'] = 'Proprietary (Innerspace Technology)'
TALKER_PROPS['PITM'] = 'Proprietary (Intermarine Electronics)'
TALKER_PROPS['PITR'] = 'Proprietary (Itera)'
TALKER_PROPS['PJAN'] = 'Proprietary (Jan Crystals)'
TALKER_PROPS['PJFR'] = 'Proprietary (Ray Jefferson)'
TALKER_PROPS['PJMT'] = 'Proprietary (Japan Marine Telecommunications)'
TALKER_PROPS['PJRC'] = 'Proprietary (Japan Radio)'
TALKER_PROPS['PJRI'] = 'Proprietary (J-R Industries)'
TALKER_PROPS['PJTC'] = 'Proprietary (J-Tech Associates)'
TALKER_PROPS['PJTR'] = 'Proprietary (Jotron Radiosearch)'
TALKER_PROPS['PKBE'] = 'Proprietary (KB Electronics)'
TALKER_PROPS['PKBM'] = 'Proprietary (Kennebec Marine)'
TALKER_PROPS['PKLA'] = 'Proprietary (Klein Associates)'
TALKER_PROPS['PKMR'] = 'Proprietary (King Marine Radio)'
TALKER_PROPS['PKNG'] = 'Proprietary (King Radio)'
TALKER_PROPS['PKOD'] = 'Proprietary (Koden Electronics)'
TALKER_PROPS['PKRP'] = 'Proprietary (Krupp Int.)'
TALKER_PROPS['PKVH'] = 'Proprietary (KVH)'
TALKER_PROPS['PKYI'] = 'Proprietary (Kyocera Int.)'
TALKER_PROPS['PLAT'] = 'Proprietary (Latitude)'
TALKER_PROPS['PLEC'] = 'Proprietary (Lorain Electronics)'
TALKER_PROPS['PLMM'] = 'Proprietary (Lamarche Manufacturing)'
TALKER_PROPS['PLRD'] = 'Proprietary (Lorad)'
TALKER_PROPS['PLSE'] = 'Proprietary (Littlemore Scientific Engineering)'
TALKER_PROPS['PLSP'] = 'Proprietary (Laser Plot)'
TALKER_PROPS['PLTF'] = 'Proprietary (Littlefuse)'
TALKER_PROPS['PLWR'] = 'Proprietary (Lowrance Electronics)'
TALKER_PROPS['PMCL'] = 'Proprietary (Micrologic)'
TALKER_PROPS['PMDL'] = 'Proprietary (Medallion Instruments)'
TALKER_PROPS['PMEC'] = 'Proprietary (Marine Engine Center)'
TALKER_PROPS['PMEG'] = 'Proprietary (Maritec Engineering)'
TALKER_PROPS['PMES'] = 'Proprietary (Marine Electronics Service)'
TALKER_PROPS['PMFR'] = 'Proprietary (Modern Products)'
TALKER_PROPS['PMFW'] = 'Proprietary (Frank W. Murphy Manufacturing)'
TALKER_PROPS['PMGN'] = 'Proprietary (Magellan)'
TALKER_PROPS['PMGS'] = 'Proprietary (MG Electronic Sales)'
TALKER_PROPS['PMIE'] = 'Proprietary (Mieco)'
TALKER_PROPS['PMIM'] = 'Proprietary (Marconi Int. Marine)'
TALKER_PROPS['PMLE'] = 'Proprietary (Martha Lake Electronics)'
TALKER_PROPS['PMLN'] = 'Proprietary (Matlin)'
TALKER_PROPS['PMLP'] = 'Proprietary (Marlin Products)'
TALKER_PROPS['PMLT'] = 'Proprietary (Miller Technologies)'
TALKER_PROPS['PMMB'] = 'Proprietary (Marsh-McBirney)'
TALKER_PROPS['PMME'] = 'Proprietary (Marks Marine Engineering)'
TALKER_PROPS['PMMP'] = 'Proprietary (Metal Marine Pilot)'
TALKER_PROPS['PMMS'] = 'Proprietary (Mars Marine Systems)'
TALKER_PROPS['PMNI'] = 'Proprietary (Micro-Now Instrument)'
TALKER_PROPS['PMNT'] = 'Proprietary (Marine Technology)'
TALKER_PROPS['PMNX'] = 'Proprietary (Marinex)'
TALKER_PROPS['PMOT'] = 'Proprietary (Motorola)'
TALKER_PROPS['PMPN'] = 'Proprietary (Memphis Net and Twine)'
TALKER_PROPS['PMQS'] = 'Proprietary (Marquis Industries)'
TALKER_PROPS['PMRC'] = 'Proprietary (Marinecomp)'
TALKER_PROPS['PMRE'] = 'Proprietary (Morad Electronics)'
TALKER_PROPS['PMRP'] = 'Proprietary (Mooring Products of New England)'
TALKER_PROPS['PMRR'] = 'Proprietary (II Morrow)'
TALKER_PROPS['PMRS'] = 'Proprietary (Marine Radio Service)'
TALKER_PROPS['PMSB'] = 'Proprietary (Mitsubishi Electric)'
TALKER_PROPS['PMSE'] = 'Proprietary (Master Electronics)'
TALKER_PROPS['PMSM'] = 'Proprietary (Master Mariner)'
TALKER_PROPS['PMST'] = 'Proprietary (Mesotech Systems)'
TALKER_PROPS['PMTA'] = 'Proprietary (Marine Technical Associates)'
TALKER_PROPS['PMTG'] = 'Proprietary (Narine Technical Assistance Group)'
TALKER_PROPS['PMTK'] = 'Proprietary (Martech)'
TALKER_PROPS['PMTR'] = 'Proprietary (Mitre)'
TALKER_PROPS['PMTS'] = 'Proprietary (Mets)'
TALKER_PROPS['PMUR'] = 'Proprietary (Murata Erie North America)'
TALKER_PROPS['PMVX'] = 'Proprietary (Magnavox Advanced Products and Systems)'
TALKER_PROPS['PMXX'] = 'Proprietary (Maxxima Marine)'
TALKER_PROPS['PNAT'] = 'Proprietary (Nautech)'
TALKER_PROPS['PNEF'] = 'Proprietary (New England Fishing Gear)'
TALKER_PROPS['PNGS'] = 'Proprietary (Navigation Sciences)'
TALKER_PROPS['PNMR'] = 'Proprietary (Newmar)'
TALKER_PROPS['PNOM'] = 'Proprietary (Nav-Com)'
TALKER_PROPS['PNOV'] = 'Proprietary (NovAtel Communications)'
TALKER_PROPS['PNSM'] = 'Proprietary (Northstar Marine)'
TALKER_PROPS['PNTK'] = 'Proprietary (Novatech Designs)'
TALKER_PROPS['PNVC'] = 'Proprietary (Navico)'
TALKER_PROPS['PNVO'] = 'Proprietary (Navionics)'
TALKER_PROPS['PNVS'] = 'Proprietary (Navstar)'
TALKER_PROPS['POAR'] = 'Proprietary (O.A.R.)'
TALKER_PROPS['PODE'] = 'Proprietary (Ocean Data Equipment)'
TALKER_PROPS['PODN'] = 'Proprietary (Odin Electronics)'
TALKER_PROPS['POIN'] = 'Proprietary (Ocean instruments)'
TALKER_PROPS['POKI'] = 'Proprietary (Oki Electronic Industry)'
TALKER_PROPS['POLY'] = 'Proprietary (Navstar (Polytechnic Electronics))'
TALKER_PROPS['POMN'] = 'Proprietary (Omnetics)'
TALKER_PROPS['PORE'] = 'Proprietary (Ocean Research)'
TALKER_PROPS['POTK'] = 'Proprietary (Ocean Technology)'
TALKER_PROPS['PPCE'] = 'Proprietary (Pace)'
TALKER_PROPS['PPDM'] = 'Proprietary (Prodelco Marine Systems)'
TALKER_PROPS['PPLA'] = 'Proprietary (Plath, C. Division of Litton)'
TALKER_PROPS['PPLI'] = 'Proprietary (Pilot Instruments)'
TALKER_PROPS['PPMI'] = 'Proprietary (Pernicka Marine Products)'
TALKER_PROPS['PPMP'] = 'Proprietary (Pacific Marine Products)'
TALKER_PROPS['PPRK'] = 'Proprietary (Perko)'
TALKER_PROPS['PPSM'] = 'Proprietary (Pearce-Simpson)'
TALKER_PROPS['PPTC'] = 'Proprietary (Petro-Com)'
TALKER_PROPS['PPTG'] = 'Proprietary (P.T.I./Guest)'
TALKER_PROPS['PPTH'] = 'Proprietary (Pathcom)'
TALKER_PROPS['PRAC'] = 'Proprietary (Racal Marine)'
TALKER_PROPS['PRAE'] = 'Proprietary (RCA Astro-Electronics)'
TALKER_PROPS['PRAY'] = 'Proprietary (Raytheon Marine)'
TALKER_PROPS['PRCA'] = 'Proprietary (RCA Service)'
TALKER_PROPS['PRCH'] = 'Proprietary (Roach Engineering)'
TALKER_PROPS['PRCI'] = 'Proprietary (Rochester Instruments)'
TALKER_PROPS['PRDI'] = 'Proprietary (Radar Devices)'
TALKER_PROPS['PRDM'] = 'Proprietary (Ray-Dar Manufacturing)'
TALKER_PROPS['PREC'] = 'Proprietary (Ross Engineering)'
TALKER_PROPS['PRFP'] = 'Proprietary (Rolfite Products)'
TALKER_PROPS['PRGC'] = 'Proprietary (RCS Global Communications)'
TALKER_PROPS['PRGY'] = 'Proprietary (Regency Electronics)'
TALKER_PROPS['PRME'] = 'Proprietary (Racal Marine Electronics)'
TALKER_PROPS['PRMR'] = 'Proprietary (RCA Missile and Surface Radar)'
TALKER_PROPS['PRSL'] = 'Proprietary (Ross Laboratories)'
TALKER_PROPS['PRSM'] = 'Proprietary (Robertson-Shipmate, USA)'
TALKER_PROPS['PRTN'] = 'Proprietary (Robertson Tritech Nyaskaien)'
TALKER_PROPS['PRWI'] = 'Proprietary (Rockwell Int.)'
TALKER_PROPS['PSAI'] = 'Proprietary (SAIT)'
TALKER_PROPS['PSBR'] = 'Proprietary (Sea-Bird electronics)'
TALKER_PROPS['PSCR'] = 'Proprietary (Signalcrafters)'
TALKER_PROPS['PSEA'] = 'Proprietary (SEA)'
TALKER_PROPS['PSEC'] = 'Proprietary (Sercel Electronics of Canada)'
TALKER_PROPS['PSEP'] = 'Proprietary (Steel and Engine Products)'
TALKER_PROPS['PSFN'] = 'Proprietary (Seafarer Navigation Int.)'
TALKER_PROPS['PSGC'] = 'Proprietary (SGC)'
TALKER_PROPS['PSIG'] = 'Proprietary (Signet)'
TALKER_PROPS['PSIM'] = 'Proprietary (Simrad)'
TALKER_PROPS['PSKA'] = 'Proprietary (Skantek)'
TALKER_PROPS['PSKP'] = 'Proprietary (Skipper Electronics)'
TALKER_PROPS['PSLI'] = 'Proprietary (Starlink)'
TALKER_PROPS['PSME'] = 'Proprietary (Shakespeare Marine Electronics)'
TALKER_PROPS['PSMF'] = 'Proprietary (Seattle Marine and Fishing Supply)'
TALKER_PROPS['PSMI'] = 'Proprietary (Sperry Marine)'
TALKER_PROPS['PSML'] = 'Proprietary (Simerl Instruments)'
TALKER_PROPS['PSNV'] = 'Proprietary (Starnav)'
TALKER_PROPS['PSOM'] = 'Proprietary (Sound Marine Electronics)'
TALKER_PROPS['PSOV'] = 'Proprietary (Sell Overseas America)'
TALKER_PROPS['PSPL'] = 'Proprietary (Spelmar)'
TALKER_PROPS['PSPT'] = 'Proprietary (Sound Powered Telephone)'
TALKER_PROPS['PSRD'] = 'Proprietary (SRD Labs)'
TALKER_PROPS['PSRF'] = 'Proprietary (SiRF)'
TALKER_PROPS['PSRS'] = 'Proprietary (Scientific Radio Systems)'
TALKER_PROPS['PSRS'] = 'Proprietary (Shipmate, Rauff & Sorensen)'
TALKER_PROPS['PSRT'] = 'Proprietary (Standard Radio and Telefon)'
TALKER_PROPS['PSSI'] = 'Proprietary (Sea Scout Industries)'
TALKER_PROPS['PSTC'] = 'Proprietary (Standard Communications)'
TALKER_PROPS['PSTI'] = 'Proprietary (Sea-Temp Instrument)'
TALKER_PROPS['PSTM'] = 'Proprietary (Si-Tex Marine Electronics)'
TALKER_PROPS['PSVY'] = 'Proprietary (Savoy Electronics)'
TALKER_PROPS['PSWI'] = 'Proprietary (Swoffer Marine Instruments)'
TALKER_PROPS['PTBB'] = 'Proprietary (Thompson Brothers Boat Manufacturing)'
TALKER_PROPS['PTCN'] = 'Proprietary (Trade Commission of Norway (THE))'
TALKER_PROPS['PTDL'] = 'Proprietary (Tideland Signal)'
TALKER_PROPS['PTHR'] = 'Proprietary (Thrane and Thrane)'
TALKER_PROPS['PTLS'] = 'Proprietary (Telesystems)'
TALKER_PROPS['PTMT'] = 'Proprietary (Tamtech)'
TALKER_PROPS['PTNL'] = 'Proprietary (Trimble Navigation)'
TALKER_PROPS['PTRC'] = 'Proprietary (Tracor)'
TALKER_PROPS['PTSI'] = 'Proprietary (Techsonic Industries)'
TALKER_PROPS['PTTK'] = 'Proprietary (Talon Technology)'
TALKER_PROPS['PTTS'] = 'Proprietary (Transtector Systems)'
TALKER_PROPS['PTWC'] = 'Proprietary (Transworld Communications)'
TALKER_PROPS['PTXI'] = 'Proprietary (Texas Instruments)'
TALKER_PROPS['PUBX'] = 'Proprietary (u-blox)'
TALKER_PROPS['PUME'] = 'Proprietary (Umec)'
TALKER_PROPS['PUNF'] = 'Proprietary (Uniforce Electronics)'
TALKER_PROPS['PUNI'] = 'Proprietary (Uniden of America)'
TALKER_PROPS['PUNP'] = 'Proprietary (Unipas)'
TALKER_PROPS['PVAN'] = 'Proprietary (Vanner)'
TALKER_PROPS['PVAR'] = 'Proprietary (Varian Eimac Associates)'
TALKER_PROPS['PVCM'] = 'Proprietary (Videocom)'
TALKER_PROPS['PVEX'] = 'Proprietary (Vexillar)'
TALKER_PROPS['PVIS'] = 'Proprietary (Vessel Information Systems)'
TALKER_PROPS['PVMR'] = 'Proprietary (Vast Marketing)'
TALKER_PROPS['PWAL'] = 'Proprietary (Walport)'
TALKER_PROPS['PWBG'] = 'Proprietary (Westberg Manufacturing)'
TALKER_PROPS['PWEC'] = 'Proprietary (Westinghouse Electric)'
TALKER_PROPS['PWHA'] = 'Proprietary (W-H Autopilots)'
TALKER_PROPS['PWMM'] = 'Proprietary (Wait Manufacturing and Marine Sales)'
TALKER_PROPS['PWMR'] = 'Proprietary (Wesmar Electronics)'
TALKER_PROPS['PWNG'] = 'Proprietary (Winegard)'
TALKER_PROPS['PWSE'] = 'Proprietary (Wilson Electronics)'
TALKER_PROPS['PWST'] = 'Proprietary (West Electronics)'
TALKER_PROPS['PWTC'] = 'Proprietary (Watercom)'
TALKER_PROPS['PYAS'] = 'Proprietary (Yaesu Electronics)'



-- Message Types
local MSG_TYPES = {}
MSG_TYPES['AAM'] = 'Waypoint arrival alarm'
MSG_TYPES['ABM'] = 'UAIS Addressed binary and safety related message (Type 6, 12)'
MSG_TYPES['ACK'] = 'Alarm acknowledgment'
MSG_TYPES['ADS'] = 'Automatic device status'
MSG_TYPES['AKD'] = 'Acknowledge detail alarm condition'
MSG_TYPES['ALA'] = 'Set detail alarm condition'
MSG_TYPES['ALM'] = 'GPS almanac data'
MSG_TYPES['ALR'] = 'Set alarm state'
MSG_TYPES['APA'] = 'Heading/track controller (Autopilot) Message "A"'
MSG_TYPES['APB'] = 'Heading/track controller (Autopilot) Message "B"'
MSG_TYPES['ASD'] = 'Autopilot system data'
MSG_TYPES['BBM'] = 'UAIS Broadcast Binary Message (Type 8, 14)'
MSG_TYPES['BEC'] = 'Bearing and distance to waypoint, dead reckoning'
MSG_TYPES['BOD'] = 'Bearing, origin to destination'
MSG_TYPES['BWC'] = 'Bearing and distance to waypoint, great circle'
MSG_TYPES['BWR'] = 'Bearing and distance to waypoint, rhumb line'
MSG_TYPES['BWW'] = 'Bearing, waypoint to waypoint'
MSG_TYPES['CEK'] = 'Configure encryption key command'
MSG_TYPES['CMP'] = 'OCTANS latitude and speed'
MSG_TYPES['COP'] = 'Configure the operational period, command'
MSG_TYPES['CUR'] = 'Water current layer'
MSG_TYPES['DBK'] = 'Depth below keel'
MSG_TYPES['DBS'] = 'Depth below surface'
MSG_TYPES['DBT'] = 'Depth below transducer'
MSG_TYPES['DCN'] = 'Decca position'
MSG_TYPES['DCR'] = 'Device capability report'
MSG_TYPES['DDC'] = 'Device dimming control'
MSG_TYPES['DOR'] = 'Door status detection'
MSG_TYPES['DPT'] = 'Depth of Water'
MSG_TYPES['DSC'] = 'Digital Selective Calling information'
MSG_TYPES['DSE'] = 'Extended Digital Selective Calling'
MSG_TYPES['DSI'] = 'Digital Selective Calling transponder initiate'
MSG_TYPES['DSR'] = 'Digital Selective Calling transponder response'
MSG_TYPES['DTM'] = 'Datum Reference'
MSG_TYPES['ETL'] = 'Engine Telegraph Operation Status'
MSG_TYPES['EVE'] = 'General Event Message'
MSG_TYPES['FIR'] = 'Fire detetction'
MSG_TYPES['FSI'] = 'Frequency set information'
MSG_TYPES['GBS'] = 'GNSS satellite fault detection'
MSG_TYPES['GGA'] = 'GPS Fix Data'
MSG_TYPES['GLL'] = 'Geographic Position - Latitude/Longitude'
MSG_TYPES['GNS'] = 'GNSS fix data'
MSG_TYPES['GRS'] = 'GNSS range residuals'
MSG_TYPES['GSA'] = 'GNSS DOP and active satellites'
MSG_TYPES['GST'] = 'GNSS pseudo range error statistics'
MSG_TYPES['GSV'] = 'GNSS satellites in view'
MSG_TYPES['GTD'] = 'Geographic location in time differences'
MSG_TYPES['HDG'] = 'Heading, deviation and variation'
MSG_TYPES['HDM'] = 'Heading, magnetic'
MSG_TYPES['HDT'] = 'Heading, true'
MSG_TYPES['HFB'] = 'Trawl headrope to footrope and bottom'
MSG_TYPES['HMR'] = 'Heading monitor - receive'
MSG_TYPES['HMS'] = 'Heading monitor - set'
MSG_TYPES['HSC'] = 'Heading steering command'
MSG_TYPES['HTC'] = 'Heading track control command'
MSG_TYPES['HTD'] = 'Heading track control data'
MSG_TYPES['INF'] = 'OCTANS status'
MSG_TYPES['ITS'] = 'Trawl door spread to distance'
MSG_TYPES['LIN'] = 'OCTANS surge, sway and heave'
MSG_TYPES['MDA'] = 'Meteorological composite'
MSG_TYPES['MLA'] = 'GLONASS almanac data'
MSG_TYPES['MSK'] = 'MSK control for a beacon receiver'
MSG_TYPES['MSS'] = 'MSK beacon receiver status'
MSG_TYPES['MWD'] = 'Wind direction and speed'
MSG_TYPES['MWV'] = 'Wind speed and angle'
MSG_TYPES['MTW'] = 'Mean temperature of water'
MSG_TYPES['MWD'] = 'Mean wind direction and speed'
MSG_TYPES['MWV'] = 'Mean wind speed and angle'
MSG_TYPES['NST'] = 'Magellan status'
MSG_TYPES['OSD'] = 'Own ship data'
MSG_TYPES['RMA'] = 'Recommended minimum navigation information'
MSG_TYPES['RMB'] = 'Recommended minimum navigation information'
MSG_TYPES['RMC'] = 'Recommended minimum GNSS navigation information'
MSG_TYPES['RME'] = 'Garmin estimated error'
MSG_TYPES['RME'] = 'Garmin altitude'
MSG_TYPES['ROO'] = 'Waypoints in active route'
MSG_TYPES['ROT'] = 'Rate of turn'
MSG_TYPES['RPM'] = 'Revolutions per minute'
MSG_TYPES['RSA'] = 'Rudder sensor angle'
MSG_TYPES['RSD'] = 'RADAR system data'
MSG_TYPES['RTE'] = 'Routes'
MSG_TYPES['SFI'] = 'Scanning frequency information'
MSG_TYPES['RSA'] = 'Rudder sensor angle'
MSG_TYPES['SHR'] = 'RT300 proprietary roll and pitch message'
MSG_TYPES['SPD'] = 'OCTANS speed'
MSG_TYPES['STN'] = 'Multiple data ID'
MSG_TYPES['TDS'] = 'Trawler Door Spread Distance'
MSG_TYPES['TFI'] = 'Trawl Filling Indicator'
MSG_TYPES['TLB'] = 'Target label'
MSG_TYPES['TLL'] = 'Target latitude and longitude'
MSG_TYPES['TPC'] = 'Trawl position cartesian coordinates'
MSG_TYPES['TPR'] = 'Trawl position relative vessel'
MSG_TYPES['TPT'] = 'Trawl position true'
MSG_TYPES['TRO'] = 'OCTANS pitch and roll'
MSG_TYPES['TTM'] = 'Tracked target message'
MSG_TYPES['TXT'] = 'Text transmission'
MSG_TYPES['VBW'] = 'Dual ground/water speed'
MSG_TYPES['VDM'] = 'UAIS VHF Data-link Message (Type 1-3)' --'AIS data message'
MSG_TYPES['VDO'] = 'UAIS VHF Data-link Own-vessel report (Type 1-3)' --'AIS own vessel report'
MSG_TYPES['VDR'] = 'Set and drift'
MSG_TYPES['VHW'] = 'Water speed and heading'
MSG_TYPES['VLW'] = 'Distance traveled through water'
MSG_TYPES['VPW'] = 'Speed, measured parallel to wind'
MSG_TYPES['VTG'] = 'Track made good and ground speed'
MSG_TYPES['VWR'] = 'Apparent wind angle and speed'
MSG_TYPES['WCV'] = 'Waypoint closure velocity'
MSG_TYPES['WDC'] = 'Distance to waypoint, great circle'
MSG_TYPES['WDR'] = 'Distance to waypoint, rhumb line'
MSG_TYPES['WNC'] = 'Distance, waypoint to waypoint'
MSG_TYPES['WPL'] = 'Waypoint location'
MSG_TYPES['XDR'] = 'Transducer measurements'
MSG_TYPES['XTE'] = 'Cross-track error, measured'
MSG_TYPES['XTR'] = 'Cross-track error, dead reckoning'
MSG_TYPES['ZDA'] = 'Time & Date - UTC, day, month, year and local time zone'
MSG_TYPES['ZDL'] = 'Time and distance to variable point'
MSG_TYPES['ZFO'] = 'UTC and time from origin waypoint'
MSG_TYPES['ZTG'] = 'UTC and time to destination waypoint'

-- Status
local STATUS_VALUES = {}
STATUS_VALUES['A'] = 'Valid'
STATUS_VALUES['B'] = 'Not Valid'

-- Position Fix Indicator
local POS_FIX_VALUES = {}
POS_FIX_VALUES['0'] = 'Not Fix'
POS_FIX_VALUES['1'] = 'GPS SPS Fix'
POS_FIX_VALUES['2'] = 'DGPS SPS Fix'
POS_FIX_VALUES['3'] = 'GPS PPS Fix'

-- AIS Channel
local AIS_CHANNELS = {}
AIS_CHANNELS['0'] = 'N/A'
AIS_CHANNELS['1'] = 'A'
AIS_CHANNELS['2'] = 'B'
AIS_CHANNELS['3'] = 'A and B'

-- 6-bit Codes of Symbols in Payload of Encapsulated Messages ('!') 
local SIX_BIT_CODES = {}
SIX_BIT_CODES['0'] = '000000'
SIX_BIT_CODES['1'] = '000001'
SIX_BIT_CODES['2'] = '000010'
SIX_BIT_CODES['3'] = '000011'
SIX_BIT_CODES['4'] = '000100'
SIX_BIT_CODES['5'] = '000101'
SIX_BIT_CODES['6'] = '000110'
SIX_BIT_CODES['7'] = '000111'
SIX_BIT_CODES['8'] = '001000'
SIX_BIT_CODES['9'] = '001001'
SIX_BIT_CODES[':'] = '001010'
SIX_BIT_CODES[';'] = '001011'
SIX_BIT_CODES['<'] = '001100'
SIX_BIT_CODES['='] = '001101'
SIX_BIT_CODES['>'] = '001110'
SIX_BIT_CODES['?'] = '001111'
SIX_BIT_CODES['@'] = '010000'
SIX_BIT_CODES['A'] = '010001'
SIX_BIT_CODES['B'] = '010010'
SIX_BIT_CODES['C'] = '010011'
SIX_BIT_CODES['D'] = '010100'
SIX_BIT_CODES['E'] = '010101'
SIX_BIT_CODES['F'] = '010110'
SIX_BIT_CODES['G'] = '010111'
SIX_BIT_CODES['H'] = '011000'
SIX_BIT_CODES['I'] = '011001'
SIX_BIT_CODES['J'] = '011010'
SIX_BIT_CODES['K'] = '011011'
SIX_BIT_CODES['L'] = '011100'
SIX_BIT_CODES['M'] = '011101'
SIX_BIT_CODES['N'] = '011110'
SIX_BIT_CODES['O'] = '011111'
SIX_BIT_CODES['P'] = '100000'
SIX_BIT_CODES['Q'] = '100001'
SIX_BIT_CODES['R'] = '100010'
SIX_BIT_CODES['S'] = '100011'
SIX_BIT_CODES['T'] = '100100'
SIX_BIT_CODES['U'] = '100101'
SIX_BIT_CODES['V'] = '100110'
SIX_BIT_CODES['W'] = '100111'
SIX_BIT_CODES["'"] = '101000'
SIX_BIT_CODES['a'] = '101001'
SIX_BIT_CODES['b'] = '101010'
SIX_BIT_CODES['c'] = '101011'
SIX_BIT_CODES['d'] = '101100'
SIX_BIT_CODES['e'] = '101101'
SIX_BIT_CODES['f'] = '101110'
SIX_BIT_CODES['g'] = '101111'
SIX_BIT_CODES['h'] = '110000'
SIX_BIT_CODES['i'] = '110001'
SIX_BIT_CODES['j'] = '110010'
SIX_BIT_CODES['k'] = '110011'
SIX_BIT_CODES['l'] = '110100'
SIX_BIT_CODES['m'] = '110101'
SIX_BIT_CODES['n'] = '110110'
SIX_BIT_CODES['o'] = '110111'
SIX_BIT_CODES['p'] = '111000'
SIX_BIT_CODES['q'] = '111001'
SIX_BIT_CODES['r'] = '111010'
SIX_BIT_CODES['s'] = '111011'
SIX_BIT_CODES['t'] = '111100'
SIX_BIT_CODES['u'] = '111101'
SIX_BIT_CODES['v'] = '111110'
SIX_BIT_CODES['w'] = '111111'


-- AIS Related constants
-- Message Type
local AIS_MSG_TYPES = {}
AIS_MSG_TYPES[1] = 'Position Report Class A'
AIS_MSG_TYPES[2] = 'Position Report Class A (Assigned schedule)'
AIS_MSG_TYPES[3] = 'Position Report Class A (Response to interrogation)'
AIS_MSG_TYPES[4] = 'Base Station Report'
AIS_MSG_TYPES[5] = 'Static and Voyage Related Data'
AIS_MSG_TYPES[6] = 'Binary Addressed Message'
AIS_MSG_TYPES[7] = 'Binary Acknowledge'
AIS_MSG_TYPES[8] = 'Binary Broadcast Message'
AIS_MSG_TYPES[9] = 'Standard SAR Aircraft Position Report'
AIS_MSG_TYPES[10] = 'UTC and Date Inquiry'
AIS_MSG_TYPES[11] = 'UTC and Date Response'
AIS_MSG_TYPES[12] = 'Addressed Safety Related Message'
AIS_MSG_TYPES[13] = 'Safety Related Acknowledgement'
AIS_MSG_TYPES[14] = 'Safety Related Broadcast Message'
AIS_MSG_TYPES[15] = 'Interrogation'
AIS_MSG_TYPES[16] = 'Assignment Mode Command'
AIS_MSG_TYPES[17] = 'DGNSS Binary Broadcast Message'
AIS_MSG_TYPES[18] = 'Standard Class B CS Position Report'
AIS_MSG_TYPES[19] = 'Extended Class B Equipment Position Report'
AIS_MSG_TYPES[20] = 'Data Link Management'
AIS_MSG_TYPES[21] = 'Aid-to-Navigation Report'
AIS_MSG_TYPES[22] = 'Channel Management'
AIS_MSG_TYPES[23] = 'Group Assignment Command'
AIS_MSG_TYPES[24] = 'Static Data Report'
AIS_MSG_TYPES[25] = 'Single Slot Binary Message'
AIS_MSG_TYPES[26] = 'Multiple Slot Binary Message With Communications State'
AIS_MSG_TYPES[27] = 'Position Report For Long-Range Applications'
--arraismsgtype[] = ''

-- Navigation Status
local NAV_STATUS_VALUES = {}
NAV_STATUS_VALUES[0] = 'Underway using engine'
NAV_STATUS_VALUES[1] = 'At anchor'
NAV_STATUS_VALUES[2] = 'Not under command'
NAV_STATUS_VALUES[3] = 'Restricted manoeuverability'
NAV_STATUS_VALUES[4] = 'Constrained by her draught'
NAV_STATUS_VALUES[5] = 'Moored'
NAV_STATUS_VALUES[6] = 'Aground'
NAV_STATUS_VALUES[7] = 'Engaged in Fishing'
NAV_STATUS_VALUES[8] = 'Underway sailing'
NAV_STATUS_VALUES[9] = 'Reserved for future amendment of Navigational Status for HSC'
NAV_STATUS_VALUES[10] = 'Reserved for future amendment of Navigational Status for WIG'
NAV_STATUS_VALUES[11] = 'Reserved for future use'
NAV_STATUS_VALUES[12] = 'Reserved for future use'
NAV_STATUS_VALUES[13] = 'Reserved for future use'
NAV_STATUS_VALUES[14] = 'AIS-SART is active'
NAV_STATUS_VALUES[15] = 'N/A' --'Not defined'


local DEGREE = string.char(0xC2, 0xB0)
-- Rate of Turn
local ROT_VALUES = {}
ROT_VALUES['0'] = 'Not turning'
ROT_VALUES['-127'] = string.format('Turning left at more than 720 %s/min (No TI available)', DEGREE) --'Turning left at more than 5deg/30s (No TI available)'
ROT_VALUES['127'] = string.format('Turning right at more than 720 %s/min (No TI available)', DEGREE) --'Turning right at more than 5deg/30s (No TI available)'
ROT_VALUES['128'] = 'N/A'

-- Speed over Ground
local SOG_VALUES = {}
SOG_VALUES[1022] = 'N/A'
SOG_VALUES[1023] = '102.2 knots or higher'

-- Position Accuracy
local POS_ACCURACY = {}
POS_ACCURACY[0] = 'Low (> 10m), Autonomous mode'
POS_ACCURACY[1] = 'High (< 10m), Differential mode'

-- Time Stamp
local TS_VALUES = {}
TS_VALUES[60] = 'N/A'
TS_VALUES[61] = 'Device is in manual input mode' --'EPFS is ...'
TS_VALUES[62] = 'Device is in estimated (dead reckoning) mode' --'EPFS is ...'
TS_VALUES[63] = 'Device is inoperative' --'EPFS is ...'

-- Maneuver Indicator
local MANEUVER_INDICATORS = {}
MANEUVER_INDICATORS[0] = 'N/A'
MANEUVER_INDICATORS[1] = 'No special maneuver'
MANEUVER_INDICATORS[2] = 'Special maneuver'

-- RAIM Flag
local RAIM_FLAGS = {}
RAIM_FLAGS[0] = 'Not in use'
RAIM_FLAGS[1] = 'In use'

-- Communication State \ Sync State
local SYNC_STATES = {}
SYNC_STATES[0] = 'UTC direct'
SYNC_STATES[1] = 'UTC indirect'
SYNC_STATES[2] = 'Base station'
SYNC_STATES[3] = 'Number of received stations'

-- Communication State \ Slot Timeout
local SLOT_TIMEOUTS = {}
SLOT_TIMEOUTS[0] = 'Last transmission in this slot' --'0 frame is left until slot change'
SLOT_TIMEOUTS[1] = '1 frame is left until slot change'
SLOT_TIMEOUTS[2] = '2 frames are left until slot change'
SLOT_TIMEOUTS[3] = '3 or more frames are left until slot change'



--#endregion


--#region Protocol

NMEAPROTO = Proto('nmea', 'NMEA 0183 Protocol')
NMEAPROTO.prefs.ports = Pref.string("Ports", "2000,3100", "Ports to dissect as NMEA 0183")

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


-- Messages Fields
local msgFields = {}
msgFields[1] = {msgtype = 'GLL', num = 1, name = 'Latitude', proto = pf.field_lat, length = 2}
msgFields[2] = {msgtype = 'GLL', num = 2, name = 'Longitude', proto = pf.field_lon, length = 2}
msgFields[3] = {msgtype = 'GLL', num = 3, name = 'Time', proto = pf.field_time, length = 1}
msgFields[4] = {msgtype = 'GLL', num = 4, name = 'Status', proto = pf.field_stat, length = 1}
msgFields[5] = {msgtype = 'GGA', num = 1, name = 'Time', proto = pf.field_time, length = 1}
msgFields[6] = {msgtype = 'GGA', num = 2, name = 'Latitude', proto = pf.field_lat, length = 2}
msgFields[7] = {msgtype = 'GGA', num = 3, name = 'Longitude', proto = pf.field_lon, length = 2}
msgFields[8] = {msgtype = 'GGA', num = 4, name = 'Position Fix', proto = pf.field_pos_fix, length = 1}
msgFields[9] = {msgtype = 'GGA', num = 5, name = 'Satellites Used', proto = pf.field_sat_used, length = 1}
msgFields[10] = {msgtype = 'GGA', num = 6, name = 'HDOP', proto = pf.field_hdop, length = 1}
msgFields[11] = {msgtype = 'GGA', num = 7, name = 'MSL Altitude', proto = pf.field_msl_alt, length = 2}
msgFields[12] = {msgtype = 'GGA', num = 8, name = 'Geoid Separation', proto = pf.field_geoid_sep, length = 2}
msgFields[13] = {msgtype = 'GGA', num = 9, name = 'Age of Differential Correction', proto = pf.field_age_diff_corr, length = 1}
msgFields[14] = {msgtype = 'GGA', num = 10, name = 'Differential Reference Station ID', proto = pf.field_drs_id, length = 1}
msgFields[15] = {msgtype = 'RMC', num = 1, name = 'Time', proto = pf.field_time, length = 1}
msgFields[16] = {msgtype = 'RMC', num = 2, name = 'Status', proto = pf.field_stat, length = 1}
msgFields[17] = {msgtype = 'RMC', num = 3, name = 'Latitude', proto = pf.field_lat, length = 2}
msgFields[18] = {msgtype = 'RMC', num = 4, name = 'Longitude', proto = pf.field_lon, length = 2}
msgFields[19] = {msgtype = 'RMC', num = 5, name = 'Speed Over Ground', proto = pf.field_sog, length = 1}
msgFields[20] = {msgtype = 'RMC', num = 6, name = 'Course Over Ground', proto = pf.field_cog, length = 1}
msgFields[21] = {msgtype = 'RMC', num = 7, name = 'Date', proto = pf.field_date, length = 1}
msgFields[22] = {msgtype = 'RMC', num = 8, name = 'Magnetic Variation', proto = pf.field_magn_var, length = 2}
msgFields[23] = {msgtype = 'VDM', num = 1, name = 'Total Parts', proto = pf.total_parts, length = 1} -- Messages Count
msgFields[24] = {msgtype = 'VDM', num = 2, name = 'Part #', proto = pf.part_num, length = 1} -- Message #
msgFields[25] = {msgtype = 'VDM', num = 3, name = 'Sequential Message ID', proto = pf.seq_msg_id, length = 1} -- 0 for messages that fit into one sentence
msgFields[26] = {msgtype = 'VDM', num = 4, name = 'AIS Channel', proto = pf.field_ais_ch, length = 1} -- 0 when the channel identification is not provided
msgFields[27] = {msgtype = 'VDM', num = 5, name = 'Encapsulated Radio Message', proto = pf.field_encaps_msg, length = 1}
msgFields[28] = {msgtype = 'VDM', num = 6, name = 'Number of Fill-Bits', proto = pf.field_num_fillbits, length = 1}
msgFields[29] = {msgtype = 'VDO', num = 1, name = 'Total Parts', proto = pf.total_parts, length = 1} -- Messages Count
msgFields[30] = {msgtype = 'VDO', num = 2, name = 'Part #', proto = pf.part_num, length = 1} -- Message #
msgFields[31] = {msgtype = 'VDO', num = 3, name = 'Sequential Message ID', proto = pf.seq_msg_id, length = 1} -- 0 for messages that fit into one sentence
msgFields[32] = {msgtype = 'VDO', num = 4, name = 'AIS Channel', proto = pf.field_ais_ch, length = 1} -- 0 when the channel identification is not provided
msgFields[33] = {msgtype = 'VDO', num = 5, name = 'Encapsulated Radio Message', proto = pf.field_encaps_msg, length = 1}
msgFields[34] = {msgtype = 'VDO', num = 6, name = 'Number of Fill-Bits', proto = pf.field_num_fillbits, length = 1}
msgFields[35] = {msgtype = 'BBM', num = 1, name = 'Total Parts', proto = pf.total_parts, length = 1} -- Messages Count
msgFields[36] = {msgtype = 'BBM', num = 2, name = 'Part #', proto = pf.part_num, length = 1} -- Message #
msgFields[37] = {msgtype = 'BBM', num = 3, name = 'Sequential Message ID', proto = pf.seq_msg_id, length = 1} -- 0 for messages that fit into one sentence
msgFields[38] = {msgtype = 'BBM', num = 4, name = 'AIS Channel', proto = pf.field_ais_ch, length = 1}
msgFields[39] = {msgtype = 'BBM', num = 5, name = 'AIS Message Type', proto = pf.field_ais_msg_type, length = 1}
msgFields[40] = {msgtype = 'BBM', num = 6, name = 'Encapsulated Radio Message', proto = pf.field_encaps_msg, length = 1}
msgFields[41] = {msgtype = 'BBM', num = 7, name = 'Number of Fill-Bits', proto = pf.field_num_fillbits, length = 1}
msgFields[42] = {msgtype = 'ABM', num = 1, name = 'Total Parts', proto = pf.total_parts, length = 1} -- Messages Count
msgFields[43] = {msgtype = 'ABM', num = 2, name = 'Part #', proto = pf.part_num, length = 1} -- Message #
msgFields[44] = {msgtype = 'ABM', num = 3, name = 'Sequential Message ID', proto = pf.seq_msg_id, length = 1} -- 0 for messages that fit into one sentence
msgFields[45] = {msgtype = 'ABM', num = 4, name = 'MMSI of the destination AIS unit', proto = pf.field_mmsi_dst_ais, length = 1}
msgFields[46] = {msgtype = 'ABM', num = 5, name = 'AIS Channel', proto = pf.field_ais_ch, length = 1}
msgFields[47] = {msgtype = 'ABM', num = 6, name = 'AIS Message Type', proto = pf.field_ais_msg_type, length = 1}
msgFields[48] = {msgtype = 'ABM', num = 7, name = 'Encapsulated Radio Message', proto = pf.field_encaps_msg, length = 1}
msgFields[49] = {msgtype = 'ABM', num = 8, name = 'Number of Fill-Bits', proto = pf.field_num_fillbits, length = 1}



-- AIS Messages
-- AIS Message Type 1-3 Fields
local aisMsg123Fields = {}
aisMsg123Fields[1] = {name = 'Message Type', proto = pf.ais_msg_type, length = 6, value = ''}
aisMsg123Fields[2] = {name = 'Repeat Indicator', proto = pf.ais_repeat, length = 2, value = ''}
aisMsg123Fields[3] = {name = 'MMSI', proto = pf.ais_mmsi, length = 30, value = ''}
aisMsg123Fields[4] = {name = 'Navigational Status', proto = pf.ais_nav_stat, length = 4, value = ''}
aisMsg123Fields[5] = {name = 'Rate of Turn', proto = pf.ais_rot, length = 8, value = ''}
aisMsg123Fields[6] = {name = 'Speed Over Ground', proto = pf.ais_sog, length = 10, value = ''}
aisMsg123Fields[7] = {name = 'Position Accuracy', proto = pf.ais_pos_acc, length = 1, value = ''}
aisMsg123Fields[8] = {name = 'Longitude', proto = pf.ais_lon, length = 28, value = ''}
aisMsg123Fields[9] = {name = 'Latitude', proto = pf.ais_lat, length = 27, value = ''}
aisMsg123Fields[10] = {name = 'Course Over Ground', proto = pf.ais_cog, length = 12, value = ''}
aisMsg123Fields[11] = {name = 'True Heading', proto = pf.ais_hdg, length = 9, value = ''}
aisMsg123Fields[12] = {name = 'Time Stamp', proto = pf.ais_time_stamp, length = 6, value = ''}
aisMsg123Fields[13] = {name = 'Maneuver Indicator', proto = pf.ais_maneuver, length = 2, value = ''}
aisMsg123Fields[14] = {name = 'Spare', proto = pf.ais_spare, length = 3, value = ''}
aisMsg123Fields[15] = {name = 'Receiver Autonomous Integrity Monitoring Flag', proto = pf.ais_raim, length = 1, value = ''}
aisMsg123Fields[16] = {name = 'Communication State', proto = pf.ais_comm, length = 19, value = ''}

local arrsotdmafield = {}
arrsotdmafield[1] = {name = 'Sync State', proto = pf.ais_comm_sync_state, length = 2, value = ''}
arrsotdmafield[2] = {name = 'Slot Timeout', proto = pf.ais_comm_slot_timeout, length = 3, value = ''}
arrsotdmafield[3] = {name = 'Sub Message', proto = nil, length = 12, value = ''}

local arritdmafield = {}
arritdmafield[1] = {name = 'Sync State', proto = pf.ais_comm_sync_state, length = 2, value = ''}
arritdmafield[2] = {name = 'Slot Allocation', proto = pf.ais_comm_slot_alloc, length = 13, value = ''}
arritdmafield[3] = {name = 'Number of Slots', proto = pf.ais_comm_total_slots, length = 2, value = ''}
arritdmafield[4] = {name = 'Keep Flag', proto = pf.ais_comm_keep_flag, length = 1, value = ''}


-- Communication State \ Sub Message
local arrsubmsg = {}
arrsubmsg[0] = {name = 'Slot Offset', proto = pf.ais_comm_slot_offset}
arrsubmsg[1] = {name = 'Hours and Minutes', proto = pf.ais_comm_hhmm}
arrsubmsg[2] = {name = 'Slot Number', proto = pf.ais_comm_slot_num}
arrsubmsg[3] = {name = 'Received Stations', proto = pf.ais_comm_rx_stations}




-- parseMessages parses messages in packet and returns table
local function parseMessages(buffer)
  local buffstr = buffer():string() or ''
  local pattern = '()([%!%$]%u%u%u%u[%w%+%-%.%,%:%;%<%=%>%?%@%`]+%*%x%x)()' -- ...%x%x()$'
  local messages = {}
  for itstart, item, itfinish in buffstr:gmatch(pattern) do
    local msg = {
      start = itstart - 1,
      length = itfinish - itstart,
      --length = #item,
      text = item
    }
    table.insert(messages, msg)
  end
  return messages
end


-- Parsing fields in message
local function parseFields(message)
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
local function str2SixBitStr(payload)
  local sixbits = {} -- Table temp
  
  for i = 1, #payload do

    sixbits[#sixbits + 1] = SIX_BIT_CODES[payload:sub(i, i)] -- String temp
  end
  return table.concat(sixbits) -- Table temp
end


local runonce = true -- Flag for remove\insert in table

-- Parsing fields in AIS Message (Type 1-3)
local function parseAIS(message, aistree)
  --local start = 0
  local start = 1
  local finish = 0
  local aismsgtype = tonumber(message:sub(1, aisMsg123Fields[1].length), 2)
  if runonce then
    if aismsgtype < 3 then
      table.remove(aisMsg123Fields)
      for _, field in ipairs(arrsotdmafield) do
        table.insert(aisMsg123Fields, field)
      end
    end
    if aismsgtype == 3 then
      table.remove(aisMsg123Fields)
      for _, field in ipairs(arritdmafield) do
        table.insert(aisMsg123Fields, field)
      end
    end
    runonce = false
  end
  for _, field in ipairs(aisMsg123Fields) do
    local fieldlen = field.length
    finish = finish + fieldlen
    field.value = message:sub(start, finish)
    start = start + fieldlen
  end
end

-- Processing AIS Field ROT
local function aisFieldROT(value)
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
    return string.format('%s %s %s %.1f %s/min', 'Turning', direct, 'at', fieldvalue, degree) --'deg/min'
  end
  
  return lookup (ROT_VALUES, tostring(fieldvalue))
end

-- Processing AIS Field Latitude/Longitude
local function aisFieldLotLan(value, max, positive, negative)
  local fieldvalue = bin2SignInt(value) / 600000
  if fieldvalue < max then
    local direct = positive
    if fieldvalue < 0 then
      fieldvalue = fieldvalue * -1
      direct = negative
    end
    local degree = string.char(0xC2, 0xB0)
    return string.format('%.4f%s%s', fieldvalue, degree, direct)
  end
  return "N/A"
end

-- Output AIS fields to tree
local function outputAISFields(buffer, tree)
  local degree = string.char(0xC2, 0xB0)
  local aismsgtype
  for _, field in ipairs(aisMsg123Fields) do
    local fieldvalue
    if field.name == 'Message Type' then
      aismsgtype = tonumber(field.value, 2)
      fieldvalue = aismsgtype
      fieldvalue = lookup(AIS_MSG_TYPES, fieldvalue)
    end
    if field.name == 'Reapet Indicator' then
      fieldvalue = tonumber(field.value, 2)
      if fieldvalue == 3 then
        fieldvalue = 'Do not repeat'
      end
    end
    if field.name == 'Navigational Status' then
      fieldvalue = tonumber(field.value, 2)
      fieldvalue = lookup(NAV_STATUS_VALUES, fieldvalue)
    end
    if field.name == 'Rate of Turn' then
      fieldvalue = aisFieldROT(field.value)
    end
    if field.name == 'Speed Over Ground' then
      fieldvalue = tonumber(field.value, 2)
      if fieldvalue < 1022 then
        fieldvalue = string.format('%s knot(s)', fieldvalue / 10)
      else
        fieldvalue = lookup (SOG_VALUES, fieldvalue)
      end
    end
    if field.name == 'Position Accuracy' then
      fieldvalue = tonumber(field.value, 2)
      fieldvalue = lookup (POS_ACCURACY, fieldvalue)
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
        fieldvalue = lookup(TS_VALUES, fieldvalue)
      end
    end
    if field.name == 'Maneuver Indicator' then
      fieldvalue = tonumber(field.value, 2)
      fieldvalue = lookup(MANEUVER_INDICATORS, fieldvalue)
    end
    if field.name == 'Receiver Autonomous Integrity Monitoring Flag' then
      fieldvalue = tonumber(field.value, 2)
      fieldvalue = lookup(RAIM_FLAGS, fieldvalue)
    end
    if field.name == 'Sync State' then
      fieldvalue = tonumber(field.value, 2)
      fieldvalue = lookup(SYNC_STATES, fieldvalue)
    end
    if aismsgtype < 3 then
      if field.name == 'Slot Timeout' then
        fieldvalue = tonumber(field.value, 2)
        fieldvalue = lookup(SLOT_TIMEOUTS, fieldvalue)
      end
        if field.name == 'Sub Message' then
        local index = tonumber(aisMsg123Fields[#aisMsg123Fields - 1].value, 2)
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
local function outputHeader(buffer, tree, start, header)
  --local start = msgstart + 1
  local headerlen = #header
  local talkerlen = 2
  local talker
  if header:sub(1,1) == 'P' then
    talkerlen = 4
    local talkers = header:sub(1, talkerlen)
    talker = TALKER_PROPS[talkers] or string.format('Proprietary (%s)', talkers:sub(2)) -- lookup(arrtalkerprop, header:sub(1, talkerlen))
  else
    local talkers = header:sub(1, talkerlen)
    talker = TALKERS[talkers] or string.format('Unknown (%s)', talkers) -- lookup(arrtalker, header:sub(1, talkerlen))
  end
  local typeshort = header:sub(talkerlen + 1)
  local msgtype = lookup(MSG_TYPES, typeshort)
  local tagtree = tree:add(buffer(start, headerlen), 'Tag: ')
  tagtree:append_text(string.format('%s - %s / %s', header, talker, msgtype))
  tagtree:add(pf.header, buffer(start, headerlen), header)
  tagtree:add(pf.talker, buffer(start, talkerlen), talker)
  tagtree:add(pf.msgtype, buffer(start + talkerlen, headerlen - talkerlen), msgtype)
  return talker, typeshort, msgtype
end

local arraismsg = {}

-- Output fields to tree
local function outputFields(buffer, tree, msgstart, typeshort, fields)
  -- Known type
  local isknowntype = false
  local known_fields = {}
  local i = 1
  for _, msgfield in ipairs(msgFields) do
    if msgfield.msgtype == typeshort then
      isknowntype = true
      known_fields[i] = msgfield --arrknownfield[#arrknownfield + 1]
      i = i + 1
    end
  end
  --
  if isknowntype then
    local index = 2
    for _, knownfield in ipairs(known_fields) do
      local start = msgstart + fields[index].start
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
          fieldvalue = lookup(POS_FIX_VALUES, fieldvalue)
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
          fieldvalue = lookup(STATUS_VALUES, fieldvalue)
        end
        if knownfield.name == 'AIS Channel' then
          fieldvalue = lookup(AIS_CHANNELS, fieldvalue)
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
          local start = msgstart + field.start
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

--#endregion

-- register_pref_ports is a helper function to register the protocol to each configured port using provided table
local function register_pref_ports(tab)
  for v in string.gmatch(NMEAPROTO.prefs.ports, "([^,]+)") do
    tab:add(tonumber(v), NMEAPROTO)
  end
end

--
-- handler for when preferences is changed
function NMEAPROTO.prefs_changed()
  local udp_table = DissectorTable.get("udp.port")
  -- remove all registerd ports
  udp_table:remove_all(NMEAPROTO)    
  -- update registration with new values
  register_pref_ports(udp_table)
end

-- Register the dissector
local udp_table = DissectorTable.get("udp.port")
register_pref_ports(udp_table)

