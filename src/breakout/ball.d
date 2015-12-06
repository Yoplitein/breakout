module breakout.ball;

import std.algorithm;
import std.experimental.logger;
import std.math;
import std.range;
import std.typecons;

import gfm.math;
import gfm.sdl2;

import breakout.brick;
import breakout.paddle;
import breakout;

struct Ball
{
    enum diameter = 50;
    enum radius = diameter / 2;
    enum pixelsPerSecond = 30;
    SDL2Texture ballTexture;
    vec2f position;
    vec2f velocity;
    int width;
    int height;
    BoundingBox boundingBox;
    bool outOfBounds;
    int deadTicks;
    
    this(int width, int height)
    {
        this.width = width;
        this.height = height;
        ballTexture = generateBallTexture(diameter);
        
        ballTexture.setColorMod(255, 0, 0);
        reset;
    }
    
    ~this()
    {
        ballTexture.destroy;
    }
    
    void reset()
    {
        position = vec2i(width / 2, height / 2);
        velocity = vec2i(1, 1);
        outOfBounds = false;
        deadTicks = 0;
    }
    
    void update(real deltaTime, ref Paddle paddle, ref Brick[] bricks)
    {
        position += velocity * pixelsPerSecond * deltaTime;
        
        if(position.x < 0)
            velocity.x = 1;
        
        if(position.x > width)
            velocity.x = -1;
        
        if(position.y < 0)
            velocity.y = 1;
        
        if(position.y > height)
        {
            outOfBounds = true;
            
            return;
        }
        
        updateBoundingBox;
        
        if(destroyBricks(bricks))
            velocity.y *= -1;
        
        if(velocity.y == 1 && close(paddle.boundingBox))
            if(boundingBox.intersects(paddle.boundingBox))
                velocity.y *= -1;
    }
    
    void updateBoundingBox()
    {
        enum halfRadius = radius / 2;
        const boxLimit = vec2f(diameter, diameter);
        
        boundingBox = BoundingBox(
            position.x - halfRadius,
            position.y - halfRadius,
            position.x + halfRadius,
            position.y + halfRadius,
        );
    }
    
    bool destroyBricks(ref Brick[] bricks)
    {
        auto relevant = bricks
            .filter!(brick => close(brick.boundingBox))
        ;
        bool hitAny = false;
        
        foreach(ref brick; relevant)
        {
            if(!boundingBox.intersects(brick.boundingBox))
                continue;
            
            hitAny = true;
            brick.broken = true;
        }
        
        return hitAny;
    }
    
    bool close(BoundingBox box)
    {
        return box.distance(boundingBox) <= diameter;
    }
    
    void render(scope SDL2Renderer renderer)
    {
        const srcRect = SDL_Rect(
            0, 0,
            diameter, diameter,
        );
        const dstRect = SDL_Rect(
            cast(int)position.x - radius,
            cast(int)position.y - radius,
            diameter,
            diameter,
        );
        
        renderer.copy(ballTexture, srcRect, dstRect);
    }
}

SDL2Texture generateBallTexture(int diameter)
{
    import breakout.main: sdl, renderer;
    
    int bitDepth;
    uint redMask;
    uint greenMask;
    uint blueMask;
    uint alphaMask;
    
    SDL_PixelFormatEnumToMasks(
        SDL_PIXELFORMAT_RGBA8888,
        &bitDepth,
        &redMask,
        &greenMask,
        &blueMask,
        &alphaMask,
    );
    
    auto surface = scoped!SDL2Surface(
        sdl,
        diameter, //width
        diameter, //height
        bitDepth,
        redMask,
        greenMask,
        blueMask,
        alphaMask,
    );
    auto ballRenderer = scoped!SDL2Renderer(surface);
    SDL2Texture result = new SDL2Texture(
        renderer,
        SDL_PIXELFORMAT_RGBA8888,
        SDL_TEXTUREACCESS_STATIC,
        diameter, //width
        diameter, //height
    );
    auto radius = diameter / 2;
    
    ballRenderer.setColor(0, 0, 0, 0);
    ballRenderer.clear;
    ballRenderer.setColor(255, 255, 255, 255);
    
    foreach(degree; iota(0, 360, 1.0L))
    {
        auto x = radius + cast(int)(radius * cos(degree.radians) / 2.0L);
        auto y = radius + cast(int)(radius * sin(degree.radians) / 2.0L);
        
        ballRenderer.drawLine(radius, radius, x, y);
    }
    
    result.setBlendMode(SDL_BLENDMODE_BLEND);
    result.updateTexture(surface.pixels, surface.pitch);
    
    return result;
}
