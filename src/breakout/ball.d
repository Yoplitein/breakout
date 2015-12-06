module breakout.ball;

import std.experimental.logger;
import std.typecons;

import gfm.math;
import gfm.sdl2;

struct Ball
{
    enum radius = 25;
    enum pixelsPerSecond = 30;
    SDL2Texture ballTexture;
    vec2f position;
    vec2f velocity;
    int width;
    int height;
    
    this(int width, int height)
    {
        this.width = width;
        this.height = height;
        position = vec2i(width / 2, height / 2);
        velocity = vec2i(1, 1);
        ballTexture = generateBallTexture(radius);
    }
    
    void update(real deltaTime)
    {
        position += velocity * pixelsPerSecond * deltaTime;
        
        if(position.x < 0)
            velocity.x = 1;
        
        if(position.x > width)
            velocity.x = -1;
        
        if(position.y < 0)
            velocity.y = 1;
        
        if(position.y > height)
            velocity.y = -1;
    }
    
    void render(scope SDL2Renderer renderer)
    {
        enum halfRadius = radius / 2;
        
        renderer.fillRect(
            cast(int)position.x - halfRadius,
            cast(int)position.y - halfRadius,
            radius,
            radius,
        );
    }
}

SDL2Texture generateBallTexture(int radius)
{
    //auto surface = scoped!SDL2Surface(sdl, ); //crap
    //auto renderer = scoped!SDL2Renderer(surface);
    return null;
}
