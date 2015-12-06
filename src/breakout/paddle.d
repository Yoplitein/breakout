module breakout.paddle;

import std.experimental.logger;

import gfm.math;
import gfm.sdl2;

import breakout;

struct Paddle
{
    enum width = 100;
    enum halfWidth = width / 2;
    enum height = 16;
    vec2i position;
    BoundingBox boundingBox;
    
    this(int height)
    {
        position.y = height;
    }
    
    void update(scope SDL2Mouse mouse)
    {
        position.x = mouse.x;
        boundingBox = BoundingBox(
            position.x - halfWidth,
            position.y - height,
            position.x + width,
            position.y + height,
        );
    }
    
    void render(scope SDL2Renderer renderer)
    {
        renderer.fillRect(
            position.x - halfWidth,
            position.y - height,
            width,
            height
        );
    }
}
