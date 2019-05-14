import std.math : sin;

import derelict.sdl2.sdl;
import derelict.sdl2.image;

import window;

immutable width = 480;
immutable height = 640;

immutable birdWidth = 80;
immutable birdHeight = 50;
immutable floorHeight = 64;

struct GameState {
	enum GameMoment {
		WAITING,
		PLAYING,
		LOST
	}

	GameMoment currentMoment = GameMoment.WAITING;
	long advance = 0;
	float yPos = height / 2;
	float ySpeed = 0;
}

immutable initialState = GameState();

enum GameAction {
	IDLE,
	PROCEED,
	JUMP,
}

GameState reducer(GameState state = initialState, GameAction action = GameAction.IDLE) {
	GameState newState = state;

	switch (action) {
	case GameAction.PROCEED:

		if (newState.currentMoment == GameState.GameMoment.PLAYING) {
			newState.advance++;
			newState.yPos -= newState.ySpeed;
			newState.ySpeed -= 0.0001;
			if (newState.yPos >= height - birdHeight / 2 - floorHeight) {
				newState.currentMoment = GameState.GameMoment.LOST;
			}
		}
		else if (newState.currentMoment == GameState.GameMoment.WAITING) {
			newState.advance++;
			newState.yPos = height / 2 + sin(newState.advance / 500.0) * birdHeight / 4;
		}
		return newState;

	case GameAction.JUMP:
		if (newState.currentMoment == GameState.GameMoment.PLAYING) {
			if (newState.yPos > birdHeight) {
				newState.ySpeed = 0.1;
			}
		}
		else if (newState.currentMoment == GameState.GameMoment.WAITING) {
			newState.currentMoment = GameState.GameMoment.PLAYING;
		}
		return newState;

	default:
		return newState;
	}
}

void renderBackground(Window window) {
	SDL_Rect r;
	r.x = 0;
	r.y = 0;
	r.w = width;
	r.h = height;
	window.drawRectangle(r, 0x65, 0xBD, 0xC7, 0xFF);
}

void renderBird(Window window, float posY) {
	SDL_Rect r;
	r.x = width / 2 - birdWidth / 2;
	r.y = cast(int)(posY - birdHeight / 2);
	r.w = birdWidth;
	r.h = birdHeight;
	window.drawRectangle(r, 255, 50, 50, 255);
}

void renderFloor(Window window, int startX) {
	SDL_Rect backgroundR;
	backgroundR.x = 0;
	backgroundR.y = height - floorHeight + 8;
	backgroundR.w = width;
	backgroundR.h = floorHeight - 8;
	window.drawRectangle(backgroundR, 0xD9, 0xD2, 0x8A, 0xFF);

	SDL_Rect backgroundR2;
	backgroundR2.x = 0;
	backgroundR2.y = height - floorHeight;
	backgroundR2.w = width;
	backgroundR2.h = 8;
	window.drawRectangle(backgroundR2, 0x68, 0xB7, 0x29, 0xFF);

	while (startX < width) {
		SDL_Rect r;
		r.x = startX;
		r.y = height - floorHeight;
		r.w = 8;
		r.h = 8;
		window.drawRectangle(r, 0x92, 0xE2, 0x4F, 0xFF);
		startX += 32;
	}
}

void render(GameState state, Window window) {
	renderBackground(window);
	renderBird(window, state.yPos);
	renderFloor(window, cast(int)(-state.advance / 30) % width);
}

GameAction handleKeyDown(SDL_Event e) {
	switch (e.key.keysym.sym) {
	case SDLK_SPACE:
		return GameAction.JUMP;
	default:
		return GameAction.IDLE;
	}
}

void main() {
	InitSDL();
	scope (exit)
		EndSDL();

	auto state = reducer();

	auto window = new Window(width, height);
	window.run(delegate(events) {
		state = reducer(state, GameAction.PROCEED);
		render(state, window);

		foreach (e; events) {
			if (e.type == SDL_QUIT) {
				return false;
			}
			else if (e.type == SDL_KEYDOWN) {
				state = reducer(state, handleKeyDown(e));
			}
		}

		return true;
	});
}
