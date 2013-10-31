module dsdl.common;

import derelict.sdl2.sdl;
import std.traits : ParameterTypeTuple;

shared static this()
{
	DerelictSDL2.load();
	CanFail!SDL_Init(SDL_INIT_EVERYTHING);
}

shared static ~this()
{
	SDL_Quit();
	DerelictSDL2.unload();
}

class SDLException : Exception
{
	this(string msg)
	{
		super(msg);
	}
}

void checkSDLError()
{
	auto msg = SDL_GetError().cStringToString();
	if(msg.length)
	{
		SDL_ClearError();
		throw new SDLException(msg);
	}
}

auto CanFail(alias func)(ParameterTypeTuple!func args)
{
	scope(exit) checkSDLError();
	return func(args);
}

string cStringToString(const(char)* cString) pure
{
	size_t idx = 0;
	while(cString[idx] != '\0') idx++;
	
	return cString[0 .. idx].idup;
}

struct ResourceDestructor(T, alias onDestroy)
{
	T resource;
	alias resource this;
	
	this(T resource)
	{
		this.resource = resource;
	}
	
	~this()
	{
		onDestroy(resource);
	}
	
	@disable this(this);
}

auto resourceDestructor(alias onDestroy, T)(T resource)
{
	return ResourceDestructor!(T, onDestroy)(resource);
}