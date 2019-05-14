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
		newState.advance++;

		if (newState.currentMoment == GameState.GameMoment.PLAYING) {
			newState.yPos -= newState.ySpeed;
			newState.ySpeed -= 0.0001;
			if (newState.yPos >= height - birdHeight / 2 - floorHeight) {
				newState.currentMoment = GameState.GameMoment.LOST;
			}
		}
		else if (newState.currentMoment == GameState.GameMoment.WAITING) {
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

void renderFloor(Window window, float posX) {
	SDL_Rect r;
	r.x = 0;
	r.y = height - floorHeight;
	r.w = width;
	r.h = floorHeight;
	window.drawRectangle(r, 0xD9, 0xD2, 0x8A, 0xFF);
}

void render(GameState state, Window window) {
	renderBackground(window);
	renderBird(window, state.yPos);
	renderFloor(window, state.advance / 100);
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
