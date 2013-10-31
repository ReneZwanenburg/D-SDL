module dsdl.window;

import dsdl.common;
import derelict.sdl2.sdl;

import std.typecons : RefCounted, RefCountedAutoInitialize;
import std.string : toStringz;

struct Window
{
	enum DEFAULT_WINDOW_FLAGS = SDL_WINDOW_SHOWN;
	
	this(string title, int x, int y, int width, int height, int flags = DEFAULT_WINDOW_FLAGS)
	{
		window = typeof(window)(CanFail!SDL_CreateWindow(title.toStringz, x, y, width, height, flags));
	}
	
	@property
	{
		void title(string title)
		{
			SDL_SetWindowTitle(window, title.toStringz);
		}
		
		string title()
		{
			return SDL_GetWindowTitle(window).cStringToString();
		}
		
		auto displayModes()
		{
			return getDisplayModes(CanFail!SDL_GetWindowDisplayIndex(window));
		}
		
		auto displayMode()
		{
			SDL_DisplayMode mode;
			CanFail!SDL_GetWindowDisplayMode(window, &mode);
			return mode;
		}
	}
	
	private:
	alias Payload = ResourceDestructor!(SDL_Window*, CanFail!SDL_DestroyWindow );
	RefCounted!(Payload, RefCountedAutoInitialize.no) window;
}

auto getDisplayModes(int display = 0)
{
	static struct DisplayModeRange
	{	
		static auto opCall(int display)
		{
			DisplayModeRange range;
			range.display = display;
			range.max = CanFail!SDL_GetNumDisplayModes(display);
			return range;
		}
		
		@property
		{
			bool empty() const
			{
				return index >= max;
			}
			
			void popFront()
			{
				assert(!empty);
				++index;
			}
			
			auto front() const
			{
				SDL_DisplayMode mode;
				CanFail!SDL_GetDisplayMode(display, index, &mode);
				return mode;
			}
		}
		
		private:
		int display;
		int index = 0;
		int max;
	}
	
	return DisplayModeRange(display);
}