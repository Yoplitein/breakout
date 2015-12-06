module breakout.brick;

import std.experimental.logger;

import gfm.math;
import gfm.sdl2;

struct Brick
{
    enum height = 8;
    int width;
    vec2i position;
    bool broken;
    
    this(int width, vec2i position)
    {
        this.width = width;
        this.position = position;
    }
    
    void render(scope SDL2Renderer renderer)
    {
        renderer.fillRect(
            position.x,
            position.y,
            width,
            height
        );
    }
}
