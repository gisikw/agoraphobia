local modem = require("component").modem
local event = require("event")

-- Start conditions
--    input chest:
--      - 64 cobblestone
--      - 64 dirt
modem.broadcast(6020, "STORE", 1, 64, "1|1|1", 1, (modem.address).."|123")
sleep(10)
modem.broadcast(6020, "STORE", 2, 1, "1|1|1", 2, (modem.address).."|123")
sleep(10)
modem.broadcast(6020, "FETCH", "1|1|1", 1, 12, (modem.address).."|123")
-- End conditions:
--  input chest:
--    - empty
--    - 63 dirt
--  output chest:
--    - 12 cobble
--  1|1|1 chest:
--    - 52 cobble
--    - 1 dirt
