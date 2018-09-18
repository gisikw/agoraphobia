local modem = require("component").modem
local event = require("event")

modem.open(123)
modem.broadcast(6020, "CHECK", "3|2|1", (modem.address).."|123")
local _, _, from, port, _, message, col, row, shelf, contents = event.pull("modem_message")
print("Got message from " .. from .. " on port " .. port .. ": " .. tostring(message) .. " " .. tostring(col) .. " " .. tostring(row) .. " " .. tostring(shelf) .. " " .. tostring(contents))
