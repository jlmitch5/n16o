local start_up = {}

local midi_signal_in
local ccTo301CVPort = {}
local ccTo301TRPort = {}

-- config vars

local nkChannel = 1
local er301FirstCVPort = 1
local er301FirstTRPort = 1
local er301MaxCVVolts = 10
local screenDebug = false

-- init

function start_up.init(params)
  if params == nil then
    params = {}
  end
  if params.nkChannel ~= nil then
    nkChannel = params.nkChannel
  end
  if params.er301FirstCVPort ~= nil then
    er301FirstCVPort = util.clamp(params.er301FirstCVPort, 1, 83)
  end
  if params.er301FirstTRPort ~= nil then
    er301FirstTRPort = util.clamp(params.er301FirstTRPort, 1, 65)
  end
  if params.er301MaxCVVolts ~= nil then
    er301MaxCVVolts = util.clamp(params.er301MaxCVVolts, 1, 10)
  end
  if params.screenDebug ~= nil then
    screenDebug = params.screenDebug
  end
  
  compute301PortOffsets()
  for i = er301FirstCVPort, er301FirstCVPort + 15 do
    set301CVSlew(i)
  end

  midi_signal_in = midi.connect(nkChannel)
  midi_signal_in.event = on_midi_event

  crow.ii.pullup(true)
end

function compute301PortOffsets()
  ccTo301CVPort = {}
  for i = 1, 16 do
    if i <= 8 then
      -- faders on ports 1 - 8
      ccTo301CVPort[i - 1] = i + er301FirstCVPort - 1
    else
      -- pan knobs on ports 9 - 16
      ccTo301CVPort[i + 7] = i + er301FirstCVPort - 1
    end
  end

  ccTo301TRPort = {}
  -- channel buttons 1 - 24 are momentary
  for i = 1, 24 do
    if i <= 8 then
      -- R buttons on ports 1 - 8
      ccTo301TRPort[i + 63] = i + er301FirstTRPort - 1
    elseif i <= 16 then
      -- M buttons on ports 9 - 16
      ccTo301TRPort[i + 39] = i + er301FirstTRPort - 1
    else
      -- S buttons on ports 17 - 24
      ccTo301TRPort[i + 15] = i + er301FirstTRPort - 1
    end
  end
  
  -- transport buttons 25 - 35 are latching
  ccTo301TRPort[43] = 25 + er301FirstTRPort
  ccTo301TRPort[44] = 26 + er301FirstTRPort
  ccTo301TRPort[42] = 27 + er301FirstTRPort
  ccTo301TRPort[41] = 28 + er301FirstTRPort
  ccTo301TRPort[45] = 29 + er301FirstTRPort
  ccTo301TRPort[46] = 30 + er301FirstTRPort
  ccTo301TRPort[60] = 31 + er301FirstTRPort
  ccTo301TRPort[61] = 32 + er301FirstTRPort
  ccTo301TRPort[62] = 33 + er301FirstTRPort
  ccTo301TRPort[58] = 34 + er301FirstTRPort
  ccTo301TRPort[59] = 35 + er301FirstTRPort
end

function set301CVSlew(port)
  local cvSlewAmt = 50
  local command = "ii.er301.cv_slew(" .. tostring(port) .. ", " .. cvSlewAmt .. ")"
  crow.send(command)
  print(command)
  redraw(command)
end

-- main

function on_midi_event(data)
  msg = midi.to_msg(data)
  if msg.ch == nkChannel then
    if ccTo301CVPort[msg.cc] ~= nil then
      set301CV(ccTo301CVPort[msg.cc], msg.val)
    elseif ccTo301TRPort[msg.cc] ~= nil then
      set301TR(ccTo301TRPort[msg.cc], msg.val)
    end
  end
end

function convertMidiValToVolts(value)
  return value * er301MaxCVVolts / 127
end

function set301CV(port, midiVal)
  local command = "ii.er301.cv(" .. tostring(port) .. ", " .. string.format("%.3f", convertMidiValToVolts(midiVal)) .. ")"
  crow.send(command)
  print(command)
  redraw(command)
end

function set301TR(port, midiVal)
  local trState = midiVal == 0 and 0 or 1
  local command = nil
  if port - (er301FirstTRPort - 1) <= 24 then
    command = "ii.er301.tr(" .. tostring(port) .. ", " .. tostring(trState) .. ")"
  elseif trState == 1 then
    command = "ii.er301.tr_tog(" .. tostring(port) .. ")"
  end

  if command ~= nil then
    crow.send(command)
    print(command)
    redraw(command)
  end
end

-- render

function redraw(msg)
  if screenDebug == true then
    screen.level(15)
    screen.aa(0)
    screen.font_face(1)
    screen.font_size(8)
    screen.clear()
    screen.move(1, 60)
    if msg ~= nil then
      screen.text(msg)
    end
    screen.update()
  end
end

return start_up
