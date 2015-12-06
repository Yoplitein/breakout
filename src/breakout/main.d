module breakout.main;

import std.datetime;
import std.experimental.logger;
import std.string;
import std.typecons;

import gfm.logger;
import gfm.sdl2;

import breakout.paddle;
import breakout.ball;

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
    auto time = Time(60);
    auto paddle = Paddle(HEIGHT);
    auto ball = Ball(WIDTH, HEIGHT);
    
    window.setTitle("Breakout");
    
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
        renderer.setColor(255, 255, 255);
        paddle.render(renderer);
        ball.render(renderer);
        renderer.present;
    }
}
