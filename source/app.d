import std.stdio;

import dsdl.window;
import derelict.sdl2.sdl;

import core.thread;

void main()
{
	auto window = Window("Hello world", 100, 100, 256, 256);
	
	foreach(mode; window.displayModes)
	{
		writeln(mode);
	}
	
	writeln("Mode: ", window.displayMode);
	
	Thread.sleep(2000.msecs);
	
	window.visible = false;
	
	Thread.sleep(2000.msecs);
	
	window.visible = true;
	window.fullscreen = true;
	
	Thread.sleep(2000.msecs);
}
