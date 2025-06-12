ground = {
    name = "ground",
    x = 0,
    y = 113,
    h = 16,
    w = 128,
    isWall = true,
}

ground_left = {
    name = "ground_lef",
    x = 0,
    y = 113 - 8,
    h = 8,
    w = 8,
    isWall = true,
}

ground_right = {
    name = "ground_right",
    x = 100,
    y = 113 - 8,
    h = 8,
    w = 8,
    isWall = true,
}

world:add(ground, ground.x, ground.y, ground.w, ground.h)
world:add(ground_left, ground_left.x, ground_left.y, ground_left.w, ground_left.h)
world:add(ground_right, ground_right.x, ground_right.y, ground_right.w, ground_right.h)
