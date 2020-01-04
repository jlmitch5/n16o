--
-- n16o
-- i2c-based er301 control
-- from a korg nanokontrol2
--
-- by default er301:
-- cv ports 1-8 correspond
-- to the nk2 faders (l to r)
--
-- cv ports 9-16 correspond
-- to the pan knobs
--
-- tr ports 1-8 correspond
-- to R buttons (momentary)
--
-- tr ports 9-16 correspond
-- to M buttons (momentary)
--
-- tr ports 17-24 correspond
-- to S buttons (momentary)
--
-- tr ports 25-35 correspond
-- to transport buttons
-- (ordered left to right,
-- bottom to top, latching)

-- to use in the background of any script, paste the following
-- lines in that script's init.  all params to init for
-- configuration are optional

n16o = include 'n16o/lib/start_up'
n16o.init({
  nkChannel = 1,              -- MIDI channel of nanokontrol2.
                              -- Defaults to 1.

  er301FirstCVPort = 1,       -- CV port of first fader.
                              -- All other CV ports follow sequentially.
                              -- Defaults to 1, so the first fader's
                              -- CV port is 1, second is 2, etc.
                              -- Min is 1, max is 83.

  er301FirstTRPort = 1,       -- TR port of first R button.
                              -- All other TR ports follow sequentially.
                              -- Defaults to 0, so the first R button's
                              -- TR port is 1, second is 2, etc.
                              -- Min is 1, max is 65.

  er301MaxCVVolts = 10,       -- CV at midi value 127.  Defaults to 10.
                              -- Min is 1, max is 10.

  screenDebug = true          -- Set to true to display commands sent to
                              -- crow on norns screen.  Defaults to false.
                              --
                              -- WARNING!!! will mess with host script
                              -- display.  Also may not work depending on
                              -- how host script uses the screen.
})
