module breakout.text;

import std.typecons;

import gfm.sdl2;

void textInit(SDLTTF ttf, int width, int height)
{
    import breakout.main: renderer;
    
    .ttf = ttf;
    .width = width;
    .height = height;
    
    font = new SDLFont(ttf, fontPath, fontSize);
    texture = new SDL2Texture(
        renderer,
        SDL_PIXELFORMAT_RGBA8888,
        SDL_TEXTUREACCESS_STATIC,
        width,
        height,
    );
    
    texture.setBlendMode(SDL_BLENDMODE_BLEND);
}

void textFini()
{
    font.destroy;
}

void textRender(scope SDL2Renderer renderer, string text)
{
    if(currentString != text)
        update(text);
    
    const textWidth = texture.width;
    const textHeight = texture.height;
    
    const srcRect = SDL_Rect(
        0, 0,
        textWidth, textHeight,
    );
    const dstRect = srcRect;
    
    renderer.copy(
        texture,
        srcRect,
        dstRect,
    );
}

private:

version(Windows)
{
    enum fontPath = "C:\\Windows\\Fonts\\verdana.ttf";
    enum fontSize = 25;
}
else
    static assert(false, "TODO: fill in font paths for other system (or runtime configure?)");

SDLTTF ttf;
SDLFont font;
SDL2Texture texture;
int width;
int height;
string currentString;

void update(string newText)
{
    import breakout.main: sdl;
    
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
        width,
        height,
        bitDepth,
        redMask,
        greenMask,
        blueMask,
        alphaMask,
    );
    auto textSurface = font.renderTextBlended(newText, SDL_Color(255, 255, 255, 255));
    auto srcRect = SDL_Rect(
        0, 0,
        textSurface.width, textSurface.height,
    );
    auto dstRect = SDL_Rect(
        width / 2 - textSurface.width / 2,
        height / 2 - textSurface.height / 2,
        texture.width,
        texture.height,
    );
    
    SDL_BlitSurface(
        textSurface.handle,
        &srcRect,
        surface.handle,
        &dstRect,
    );
    texture.updateTexture(surface.pixels, surface.pitch);
    textSurface.destroy;
}
