module breakout.main;

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
    auto time = Time(60);
    auto paddle = Paddle(HEIGHT);
    auto ball = Ball(WIDTH, HEIGHT);
    Brick[] bricks;
    
    window.setTitle("Breakout");
    placeBricks(bricks);
    
    while(!sdl.wasQuitRequested)
    {
        sdl.processEvents;
        time.frame(window);
        
        if(time.tick)
        {
            paddle.update(sdl.mouse);
            ball.update(time.deltaTime);
        }
        
        if(sdl.keyboard.testAndRelease(SDLK_ESCAPE))
            break;
        
        renderer.setColor(0, 0, 0);
        renderer.clear;
        
        foreach(brick; bricks)
            brick.render(renderer);
        
        renderer.setColor(255, 0, 0);
        ball.render(renderer);
        renderer.setColor(255, 255, 255);
        paddle.render(renderer);
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
