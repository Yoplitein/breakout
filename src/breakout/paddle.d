module breakout.paddle;

import std.experimental.logger;

import gfm.math;
import gfm.sdl2;

struct Paddle
{
    enum width = 100;
    enum height = 16;
    vec2i position;
    
    this(int height)
    {
        position.y = height;
    }
    
    void update(scope SDL2Mouse mouse)
    {
        position.x = mouse.x;
    }
    
    void render(scope SDL2Renderer renderer)
    {
        enum halfWidth = width / 2;
        
        renderer.fillRect(
            position.x - halfWidth,
            position.y - height,
            width,
            height
        );
    }
}
