local character = {
    parts = {
        {
            name = "body",
            part = require("assets.models.parts.body"),
            offset = {
                x = 0,
                y = 0
            }
        },
        {
            name = "head",
            part = require("assets.models.parts.head"),
            offset = {
                x = 0,
                y = -8
            }
        },
        {
            name = "hat",
            part = require("assets.models.parts.hat"),
            offset = {
                x = 0,
                y = -10
            }
        }
    }
}

return character;
