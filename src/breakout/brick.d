module breakout.brick;

import std.experimental.logger;

import gfm.math;
import gfm.sdl2;

import breakout;

struct Brick
{
    enum height = 8;
    static size_t colorIndex;
    int width;
    vec2i position;
    bool broken;
    vec3i color;
    BoundingBox boundingBox;
    
    this(int width, vec2i position)
    {
        this.width = width;
        this.position = position;
        color = nextColor;
        boundingBox = BoundingBox(
            position.x,
            position.y,
            position.x + width,
            position.y + height,
        );
    }
    
    static vec3i nextColor()
    {
        const colors = [
            vec3i(255, 0, 0),
            vec3i(0, 255, 0),
            vec3i(0, 0, 255),
            vec3i(255, 255, 0),
            vec3i(0, 255, 255),
            //vec3i(255, 0, 255),
        ];
        
        return colors[colorIndex++ % $];
    }
    
    void render(scope SDL2Renderer renderer)
    {
        renderer.setColor(color.r, color.g, color.b);
        renderer.fillRect(
            position.x,
            position.y,
            width,
            height
        );
    }
}
