module breakout.main;

import std.algorithm;
import std.array;
import std.datetime;
import std.experimental.logger;
import std.string;
import std.typecons;

import gfm.logger;
import gfm.sdl2;
import gfm.math;

import breakout.ball;
import breakout.brick;
import breakout.paddle;

SDL2 sdl;
SDL2Renderer renderer;

private:

enum WIDTH = 800;
enum HEIGHT = 600;
enum TICKS_PER_SECOND = 60;

struct Time
{
    immutable real deltaTime;
    private SysTime lastTick;
    private Duration tickDelay;
    private SysTime lastFPS;
    private size_t frames;
    
    this(size_t ticksPerSecond)
    {
        auto timeMilliseconds = 1000.0L / ticksPerSecond;
        deltaTime = timeMilliseconds / 100;
        lastTick = lastFPS = Clock.currTime;
        tickDelay = msecs(cast(long)timeMilliseconds);
    }
    
    void frame(scope SDL2Window window)
    {
        auto now = Clock.currTime;
        
        if(now >= lastFPS + 1.seconds)
        {
            window.setTitle("Breakout %d fps".format(frames));
            
            frames = 0;
            lastFPS = now;
        }
        
        frames++;
    }
    
    bool tick()
    {
        auto now = Clock.currTime;
        bool result = now >= lastTick + tickDelay;
        
        if(result)
            lastTick = now;
        
        return result;
    }
}

void main()
{
    sharedLog = new ConsoleLogger;
    auto sdl = scoped!SDL2(sharedLog);
    .sdl = sdl;
    auto window = scoped!SDL2Window(
        sdl,
        SDL_WINDOWPOS_CENTERED, 35,
        WIDTH, HEIGHT,
        SDL_WINDOW_SHOWN,
    );
    auto renderer = scoped!SDL2Renderer(
        window,
        SDL_RENDERER_ACCELERATED | SDL_RENDERER_PRESENTVSYNC,
    );
    .renderer = renderer;
    auto time = Time(TICKS_PER_SECOND);
    auto paddle = Paddle(HEIGHT);
    auto ball = Ball(WIDTH, HEIGHT);
    Brick[] bricks;
    bool renderBoundingBoxes;
    int lives;
    bool dead;
    int deadTicks;
    
    void reset()
    {
        bricks.length = 0;
        lives = 3;
        dead = false;
        deadTicks = 0;
        
        placeBricks(bricks);
        ball.reset;
    }
    
    window.setTitle("Breakout");
    reset;
    
    while(!sdl.wasQuitRequested)
    {
        sdl.processEvents;
        time.frame(window);
        
        if(time.tick)
        {
            if(!dead) paddle.update(sdl.mouse);
            ball.update(time.deltaTime, paddle, bricks);
            
            bricks = bricks
                .filter!(brick => !brick.broken)
                .array
            ;
            
            if(!dead && ball.outOfBounds)
            {
                if(ball.deadTicks == 0)
                {
                    lives -= 1;
                    
                    if(lives == 0)
                        dead = true;
                }
                
                ball.deadTicks++;
                
                if(ball.deadTicks > TICKS_PER_SECOND)
                    ball.reset;
            }
            
            if(dead)
            {
                deadTicks++;
                
                if(deadTicks > TICKS_PER_SECOND * 5)
                    reset;
            }
        }
        
        if(sdl.keyboard.testAndRelease(SDLK_ESCAPE))
            break;
        
        if(sdl.keyboard.testAndRelease(SDLK_g))
        {
            ball.position = vec2f(WIDTH / 2, HEIGHT / 2);
            ball.velocity = (1, 1);
        }
        
        if(sdl.keyboard.testAndRelease(SDLK_b))
            renderBoundingBoxes = !renderBoundingBoxes;
        
        renderer.setColor(0, 0, 0);
        renderer.clear;
        
        foreach(brick; bricks)
            brick.render(renderer);
        
        ball.render(renderer);
        renderer.setColor(255, 255, 255);
        paddle.render(renderer);
        
        if(renderBoundingBoxes)
        {
            renderer.setColor(255, 0, 255);
            
            foreach(brick; bricks)
                renderer.drawRect(
                    cast(int)brick.boundingBox.min.x,
                    cast(int)brick.boundingBox.min.y,
                    cast(int)brick.boundingBox.width,
                    cast(int)brick.boundingBox.height,
                );
            
            renderer.drawRect(
                cast(int)ball.boundingBox.min.x,
                cast(int)ball.boundingBox.min.y,
                cast(int)ball.boundingBox.width,
                cast(int)ball.boundingBox.height,
            );
            renderer.drawRect(
                cast(int)paddle.boundingBox.min.x,
                cast(int)paddle.boundingBox.min.y,
                cast(int)paddle.boundingBox.width,
                cast(int)paddle.boundingBox.height,
            );
        }
        
        renderer.present;
    }
}

void placeBricks(ref Brick[] bricks)
{
    enum brickWidth = 32;
    enum halfBrickWidth = brickWidth / 2;
    enum columns = WIDTH / brickWidth;
    enum columnStride = brickWidth + 1;
    enum rows = cast(int)(HEIGHT * 0.35L) / Brick.height;
    enum rowStride = Brick.height + 1;
    
    foreach(row; 0 .. rows)
    {
        bool evenRow = row % 2 == 0;
        
        foreach(column; 0 .. columns)
            bricks ~= Brick(
                brickWidth,
                vec2i(
                    column * columnStride - (evenRow ? 0 : halfBrickWidth),
                    row * rowStride,
                ),
            );
    }
}
