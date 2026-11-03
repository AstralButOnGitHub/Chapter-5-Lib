return {
    ---@param cutscene WorldCutscene
    okay = function(cutscene, event)
        cutscene:setSpeaker("ralsei")
        cutscene:text("* This watering can looks somewhat important...")
        cutscene:text("* Kris, perhaps if you held it in your hands, you could...")
        cutscene:shakeCamera(6, 6)
        event:giveWateringCan(Game.world.player)
        Assets.playSound("locker")
        cutscene:wait(1)
        cutscene:text("* Okay.")
    end
}