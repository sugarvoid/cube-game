ground = {
    name = "ground",
    x = 0,
    y = 113,
    h = 16,
    w = 128,
    isWall = true,
}

wall_left = {
    name = "wall",
    x = 0,
    y = 113 - 8,
    h = 8,
    w = 8,
    isWall = true,
}

wall_right = {
    name = "wall",
    x = 120,
    y = 113 - 8,
    h = 8,
    w = 8,
    isWall = true,
}

world:add(ground, ground.x, ground.y, ground.w, ground.h)
world:add(wall_left, wall_left.x, wall_left.y, wall_left.w, wall_left.h)
world:add(wall_right, wall_right.x, wall_right.y, wall_right.w, wall_right.h)
