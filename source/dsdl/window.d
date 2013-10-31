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
		
		void displayMode(SDL_DisplayMode mode)
		{
			CanFail!SDL_SetWindowDisplayMode(window, &mode);
		}
		
		auto displayMode()
		{
			SDL_DisplayMode mode;
			CanFail!SDL_GetWindowDisplayMode(window, &mode);
			return mode;
		}
		
		auto displayModes()
		{
			return getDisplayModes(CanFail!SDL_GetWindowDisplayIndex(window));
		}
		
		void size(SDL_Point size)
		{
			SDL_SetWindowSize(window, size.x, size.y);
		}
		
		auto size()
		{
			SDL_Point size;
			SDL_GetWindowSize(window, &size.x, &size.y);
			return size;
		}
		
		void position(SDL_Point point)
		{
			SDL_SetWindowPosition(window, point.x, point.y);
		}
		
		auto position()
		{
			SDL_Point position;
			SDL_GetWindowPosition(window, &position.x, &position.y);
			return position;
		}
		
		void maximumSize(SDL_Point size)
		{
			SDL_SetWindowMaximumSize(window, size.x, size.y);
		}
		
		auto maximumSize()
		{
			SDL_Point point;
			SDL_GetWindowMaximumSize(window, &point.x, &point.y);
			return point;
		}
		
		void minimumSize(SDL_Point size)
		{
			SDL_SetWindowMinimumSize(window, size.x, size.y);
		}
		
		auto minimumSize()
		{
			SDL_Point size;
			SDL_GetWindowMinimumSize(window, &size.x, &size.y);
			return size;
		}
		
		void visible(bool visible)
		{
			if(visible)
			{
				SDL_ShowWindow(window);
			}
			else
			{
				SDL_HideWindow(window);
			}
		}
		
		bool visible()
		{
			return !!(SDL_GetWindowFlags(window) & SDL_WINDOW_SHOWN);
		}
		
		void fullscreen(bool fullscreen)
		{
			SDL_SetWindowFullscreen(window, fullscreen ? SDL_WINDOW_FULLSCREEN : 0u);
		}
		
		bool fullscreen()
		{
			return !!(SDL_GetWindowFlags(window) & SDL_WINDOW_FULLSCREEN);
		}
		
		void grab(bool grab)
		{
			SDL_SetWindowGrab(window, grab);
		}
		
		bool grab()
		{
			return SDL_GetWindowGrab(window);
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