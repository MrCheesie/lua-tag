local Constants = {}

Constants.VIRTUAL_WIDTH = 1280
Constants.VIRTUAL_HEIGHT = 720

Constants.STATES = {
    TITLE = "TITLE",
    MAP_SELECT = "MAP_SELECT",
    CONTROLS = "CONTROLS",
    PLAYING = "PLAYING",
    PAUSED = "PAUSED",
    GAME_OVER = "GAME_OVER"
}

Constants.PLAYERS = {
    [1] = {
        id = 1,
        name = "BLUE",
        color = {0.08, 0.52, 0.93},
        darkColor = {0.04, 0.11, 0.31},
        themeColor = {0.08, 0.52, 0.93},
        bodyAsset = "assets/blue_guy_main.png",
        headbandAsset = "assets/blue_end_of_headband.png",
        keys = {
            left = "left",
            right = "right",
            jump = "up"
        },
        keyLabels = {
            jump = "↑",
            left = "←",
            right = "→"
        }
    },
    [2] = {
        id = 2,
        name = "RED",
        color = {0.89, 0.22, 0.22},
        darkColor = {0.29, 0.05, 0.09},
        themeColor = {0.89, 0.22, 0.22},
        bodyAsset = "assets/red_guy_main.png",
        headbandAsset = "assets/red_end_of_headband.png",
        keys = {
            left = "a",
            right = "d",
            jump = "w"
        },
        keyLabels = {
            jump = "W",
            left = "A",
            right = "D"
        }
    },
    [3] = {
        id = 3,
        name = "YELLOW",
        color = {0.94, 0.72, 0.05},
        darkColor = {0.29, 0.24, 0.04},
        themeColor = {0.94, 0.72, 0.05},
        bodyAsset = "assets/yellow_guy_main.png",
        headbandAsset = "assets/yellow_end_of_headband.png",
        keys = {
            left = "j",
            right = "l",
            jump = "i"
        },
        keyLabels = {
            jump = "I",
            left = "J",
            right = "L"
        }
    },
    [4] = {
        id = 4,
        name = "GREEN",
        color = {0.15, 0.72, 0.22},
        darkColor = {0.05, 0.22, 0.08},
        themeColor = {0.15, 0.72, 0.22},
        bodyAsset = "assets/green_guy_main.png",
        headbandAsset = "assets/green_end_of_headband.png",
        keys = {
            left = "f",
            right = "h",
            jump = "t"
        },
        keyLabels = {
            jump = "T",
            left = "F",
            right = "H"
        }
    }
}

Constants.BUFF_TYPES = {
    SHIELD = "SHIELD",
    BUBBLE = "BUBBLE",
    SPEED = "SPEED"
}

Constants.MAPS = {
    CLASSIC = "classic",
    SNOW = "snow",
    DESERT = "desert"
}

Constants.SFX_FILES = {
    DESERT_MUSIC = "assets/sfx/desert_bg_music.mp3",
    SNOW_MUSIC = "assets/sfx/snow_bg_music.mp3",
    CLASSIC_MUSIC = "assets/sfx/classic_bg_music.mp3",
    TAGGED = "assets/sfx/tagged.mp3",
    BOUNCE = "assets/sfx/bounce.mp3",
    TELEPORT = "assets/sfx/teleport.mp3",
    GAME_OVER = "assets/sfx/game_over.mp3",
    BUTTON_PRESSED = "assets/sfx/button_pressed.mp3"
}

return Constants
