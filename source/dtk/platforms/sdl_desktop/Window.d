module dtk.platforms.sdl_desktop.Window;

import std.typecons;
import std.stdio;
import std.algorithm;

import bindbc.sdl;

import dtk.interfaces.PlatformI;
import dtk.interfaces.DrawingSurfaceI;
import dtk.interfaces.FormI;
import dtk.interfaces.WindowI;
import dtk.interfaces.WidgetI;
import dtk.interfaces.WindowEventMgrI;
import dtk.interfaces.LafI;

import dtk.platforms.sdl_desktop.DrawingSurface;
import dtk.platforms.sdl_desktop.SDLDesktopPlatform;
import dtk.platforms.sdl_desktop.utils;

import dtk.types.Position2D;
import dtk.types.Size2D;
import dtk.types.WindowCreationSettings;
// import dtk.types.Event;
import dtk.types.EventWindow;
import dtk.types.EventKeyboard;
import dtk.types.EventMouse;
import dtk.types.EventTextInput;

import dtk.miscs.WindowEventMgr;

class Window : WindowI
{
	
    private
    {
        SDLDesktopPlatform platform;
        
        DrawingSurface drawing_surface;
        
        FormI form;
        
        // Position2D _point;
        // Size2D _size;
        
        // Position2D _form_point;
        // Size2D _form_size;
        
        int x;
        int y;
        ulong width;
        ulong height;
        
        ulong form_width;
        ulong form_height;
        
        string title;
        
        bool minimized;
        bool maximized;
        
        bool visible;
        
        LafI laf;
        WindowEventMgrI emgr;
    }
    
    public
    {
        SDL_Window* sdl_window;
        typeof(SDL_WindowEvent.windowID) sdl_window_id;
    }
    
    @disable this();
    
    this(WindowCreationSettings window_settings, SDLDesktopPlatform platform)
    {
        platform = platform;
        title = window_settings.title;
        
        if (!window_settings.x.isNull())
        {
            this.x = window_settings.x.get();
        }
        
        static foreach (v; ["x", "y", "width", "height"])
        {
        	mixin(
        		q{
        			if (!window_settings.%1$s.isNull())
        			{
        				this.%1$s = window_settings.%1$s.get();
        			}.format(v);
        		}
        		);
        }
        
        _drawing_surface = new DrawingSurface(this);
        
        auto flags = cast(SDL_WindowFlags) 0 /* else flags init with FULLSCREEN option */ ;
        
        if (!window_settings.resizable.isNull() && window_settings.resizable.get())
            flags |= SDL_WINDOW_RESIZABLE;
        
        sdl_window = SDL_CreateWindow(
        	cast(char*) window_settings.title, 
        	x, 
        	y, 
        	width, 
        	height, 
        	flags
        	);
        if (sdl_window is null)
        {
            throw new Exception("window creation error");
        }
        
        {
            SDL_CreateRenderer(sdl_window, -1, SDL_RENDERER_SOFTWARE);
            auto r = SDL_GetRenderer(sdl_window);
            SDL_RendererInfo ri;
            SDL_GetRendererInfo(r, &ri);
        }
        
        sdl_window_id = SDL_GetWindowID(sdl_window);
        if (sdl_window_id == 0)
        {
            throw new Exception("error getting SDL window id");
        }
        
        setEventManager(new WindowEventMgr(this));
        if (window_settings.laf !is null)
            setLaf(window_settings.laf);
        else
        {
            auto platform_laf = platform.getLaf();
            if (platform_laf is null)
            {
            	throw new Exception("platform doesn't have Laf defined. this is not ok");
            }
            setLaf(platform_laf);
        }
        
        platform.registerWindow(this);
    }
    
    ~this()
    {
        _platform.unregisterWindow(this);
    }
    
    void setEventManager(WindowEventMgrI mgr)
    {
        _emgr = mgr;
    }
    
    WindowEventMgrI getEventManager()
    {
        return _emgr;
    }
    
    void setLaf(LafI laf)
    {
        _laf = laf;
        if (_emgr !is null)
        {
            _emgr.removeAllActions();
            assert(_laf !is null);
            _laf.addEventHandling(_emgr);
        }
    }
    
    void handle_SDL_Event(SDL_Event* event)
    {
        switch (event.type)
        {
        default:
            return;
        case SDL_WINDOWEVENT:
            handle_SDL_WindowEvent(&event.window);
            break;
        case SDL_KEYDOWN:
        case SDL_KEYUP:
            handle_SDL_KeyboardEvent(&event.key);
            break;
        case SDL_MOUSEMOTION:
            handle_SDL_MouseMotionEvent(&event.motion);
            break;
        case SDL_MOUSEBUTTONDOWN:
        case SDL_MOUSEBUTTONUP:
            handle_SDL_MouseButtonEvent(&event.button);
            break;
        case SDL_MOUSEWHEEL:
            handle_SDL_MouseWheelEvent(&event.wheel);
            break;
        case SDL_TEXTINPUT:
            handle_SDL_TextInputEvent(&event.text);
            break;
        }
        
    }
    
    // ? status: started. fast checked ok.
    void handle_SDL_WindowEvent(SDL_WindowEvent* event)
    {
        // TODO: ensure event consistency
        auto res = convertSDLWindowEventToDtkEventWindow(event);
        handle_event_window(res);
    }
    
    // ? status: started. fast checked ok.
    void handle_SDL_KeyboardEvent(SDL_KeyboardEvent* event)
    {
        // TODO: ensure event consistency
        auto res = convertSDLKeyboardEventToDtkEventKeyboard(event);
        if (res[1]!is null)
        {
            return;
        }
        handle_event_keyboard(res[0]);
    }
    
    // ? status: started.  fast checked ok.
    void handle_SDL_MouseMotionEvent(SDL_MouseMotionEvent* event)
    {
        // TODO: ensure event consistency
        auto res = convertSDLMouseMotionEventToDtkEventMouse(event);
        handle_event_mouse(res);
    }
    
    // ? status: started. fast checked ok.
    void handle_SDL_MouseButtonEvent(SDL_MouseButtonEvent* event)
    {
        // TODO: ensure event consistency
        auto res = convertSDLMouseButtonEventToDtkEventMouse(event);
        handle_event_mouse(res);
    }
    
    // ? status: needs completion
    void handle_SDL_MouseWheelEvent(SDL_MouseWheelEvent* event)
    {
        // TODO: ensure event consistency
        auto res = convertSDLMouseWheelEventToDtkEventMouse(event);
        handle_event_mouse(res);
    }
    
    // ? status: fast checked ok.
    void handle_SDL_TextInputEvent(SDL_TextInputEvent* event)
    {
        // TODO: ensure event consistency
        auto res = convertSDLTextInputEventToDtkEventTextInput(event);
        handle_event_textinput(res);
    }
    
    bool handle_event_window(EventWindow* e)
    {
    	if (e.eventId == EnumWindowEvent.resize)
    	{
    		int w, h;
    		
    		SDL_GetWindowSize(_sdl_window, &w, &h);
    		
    		form_width = w;
    		form_height = h;
    		width = form_width;
    		height = form_height;
    		
    		
    		int t, l, b, r;
    		auto res = SDL_GetWindowBordersSize(_sdl_window, &t, &l, &b, &r);
    		if (res != -1)
    		{
    			height = form_height + t + b;
    			width = form_width + l + r;
    		}
    		
    	}
        auto emgr = getEventManager();
        if (!emgr)
            return false;
        return emgr.handle_event_window(e);
    }
    
    bool handle_event_keyboard(EventKeyboard* e)
    {
        auto emgr = getEventManager();
        if (!emgr)
            return false;
        return emgr.handle_event_keyboard(e);
    }
    
    bool handle_event_mouse(EventMouse* e)
    {
        auto emgr = getEventManager();
        if (!emgr)
            return false;
        return emgr.handle_event_mouse(e);
    }
    
    bool handle_event_textinput(EventTextInput* e)
    {
        auto emgr = getEventManager();
        if (!emgr)
            return false;
        return emgr.handle_event_textinput(e);
    }
    
    void redraw()
    {
        if (this._form is null)
            return;
        
        this._form.redraw();
    }
    
    void printParams()
    {
        writeln(_title, " : ", this._point.x, " ", this._point.y, " ",
        	this._size.width, " ", this._size.height);
    }
    
    PlatformI getPlatform()
    {
        return _platform;
    }
    
    DrawingSurfaceI getDrawingSurface()
    {
        return _drawing_surface;
    }
    
    void installForm(FormI form)
    {
        uninstallForm();
        
        setForm(form);
        auto x = getForm();
        assert(x !is null);
        x.setWindow(this);
        /* x.setDrawingSurface(this._drawing_surface); */
        x.setLaf(getPlatform().getLaf());
    }
    
    void uninstallForm()
    {
        auto x = getForm();
        if (x !is null)
        {
            x.unsetLaf();
            /* x.unsetDrawingSurface(); */
            x.unsetWindow();
        }
        this.unsetForm();
    }
    
    void setForm(FormI form)
    {
        this._form = form;
    }
    
    void unsetForm()
    {
        this._form = null;
    }
    
    FormI getForm()
    {
        return _form;
    }
    
    Position2D getPoint()
    {
        return _point;
    }
    
    Tuple!(bool, Position2D) setPoint(Position2D point)
    {
        this._point = point;
        return tuple(true, this._point);
    }
    
    Size2D getSize()
    {
        return _size;
    }
    
    Tuple!(bool, Size2D) setSize(Size2D size)
    {
        this._size = size;
        return tuple(true, this._size);
    }
    
    string getTitle()
    {
        return _title;
    }
    
    void setTitle(string value)
    {
        _title = value;
    }
    
    ulong getFormWidth()
    {
    	return form_width;
    }
    
    ulong getFormHeight()
    {
    	return form_height;
    }
}
