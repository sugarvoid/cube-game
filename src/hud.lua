hud = {
    new_score = 0,
    ticker = 0,
    draw = function()
        love.graphics.push("all")
        set_color_from_hex(COLORS.BLACK)
        love.graphics.rectangle("fill", 12, 120, 100, 20)
        set_color_from_hex(COLORS.WHITE)
        love.graphics.setFont(font_hud)
        love.graphics.print("Score:" .. player.score, 10, 118, 0, 0.2, 0.2)
        love.graphics.pop()
    end,
    reset = function(self)
        self.new_score = 0
        self.ticker = 0
    end,
    update = function(self)
        self.ticker = self.ticker + 1
        if self.ticker >= 2 then
            if player.score < self.new_score then
                player.score = player.score + 1
            end
            self.ticker = 0
        end
    end
}
