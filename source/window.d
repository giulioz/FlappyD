module window;

import derelict.sdl2.sdl;
import derelict.sdl2.image;

void InitSDL() {
  DerelictSDL2.load();
  // DerelictSDL2Image.load();
  SDL_Init(SDL_INIT_VIDEO);
}

void EndSDL() {
  SDL_Quit();
}

class Window {
  int width, height;
  SDL_Window* window;
  SDL_Renderer* renderer;

  this(int width, int height) {
    this.width = width;
    this.height = height;

    this.window = SDL_CreateWindow("SDL Output", SDL_WINDOWPOS_UNDEFINED,
        SDL_WINDOWPOS_UNDEFINED, width, height, SDL_WINDOW_SHOWN);

    this.renderer = SDL_CreateRenderer(window, -1, SDL_RENDERER_ACCELERATED);
    SDL_RenderSetLogicalSize(renderer, width, height);
  }

  ~this() {
    SDL_DestroyWindow(window);
  }

  void run(bool delegate(SDL_Event[]) loop) {
    while (true) {
      SDL_Event e;
      SDL_Event[] events = new SDL_Event[0];
      while (SDL_PollEvent(&e) != 0) {
        events = events ~ e;
      }

      SDL_RenderClear(renderer);
      if (!loop(events)) {
        return;
      }
      SDL_RenderPresent(renderer);
    }
  }

  void drawRectangle(SDL_Rect rect, ubyte r, ubyte g, ubyte b, ubyte a) {
    SDL_SetRenderDrawColor(renderer, r, g, b, a);
    SDL_RenderFillRect(renderer, &rect);
  }
}
