module breakout.main;

import std.experimental.logger;
import std.typecons;

import gfm.logger;
import gfm.sdl2;

enum WIDTH = 800;
enum HEIGHT = 600;

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
        SDL_RENDERER_ACCELERATED,
    );
    
    window.setTitle("Breakout");
    
    while(!sdl.wasQuitRequested)
    {
        sdl.processEvents;
        
        if(sdl.keyboard.testAndRelease(SDLK_ESCAPE))
            break;
        
        renderer.setColor(0, 0, 0);
        renderer.clear;
        renderer.setColor(255, 0, 255);
        renderer.fillRect(100, 100, 100, 100);
        renderer.present;
    }
}
