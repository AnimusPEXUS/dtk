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
import dtk.types.Property;

import dtk.miscs.WindowEventMgr;

const auto WindowProperties = cast(PropSetting[]) [
PropSetting("gs_w_d", "int", "x", "X", "0"),
PropSetting("gs_w_d", "int", "y", "Y", "0"),
PropSetting("gs_w_d", "ulong", "width", "Width", "0"),
PropSetting("gs_w_d", "ulong", "height", "Height", "0"),
PropSetting("gs_w_d", "ulong", "form_width", "FormWidth", "0"),
PropSetting("gs_w_d", "ulong", "form_height", "FormHeight", "0"),
];

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


	mixin mixin_multiple_properties_define!(WindowProperties);
    mixin mixin_multiple_properties_forward!(WindowProperties);
    
    @disable this();
    
    this(WindowCreationSettings window_settings, SDLDesktopPlatform platform)
    {
    	mixin(mixin_multiple_properties_inst(WindowProperties));
    	
        platform = platform;
        title = window_settings.title;
        
        static foreach (
        	Tuple!(string, string) v; 
        	[
        	tuple("x", "X"), 
        	tuple("y", "Y"), 
        	tuple("width", "Width"), 
        	tuple("height", "Height")
        	]
        	)
        {
        	import std.format;
        	mixin(
        		q{
        			if (!window_settings.%1$s.isNull())
        			{
        				set%2$s(window_settings.%1$s.get());
        			}
        		}.format(v[0], v[1])
        		);
        }
        
        drawing_surface = new DrawingSurface(this);
        
        auto flags = cast(SDL_WindowFlags) 0 /* else flags init with FULLSCREEN option */ ;
        
        if (!window_settings.resizable.isNull() && window_settings.resizable.get())
            flags |= SDL_WINDOW_RESIZABLE;
        
        sdl_window = SDL_CreateWindow(
        	cast(char*) window_settings.title, 
        	getX(), 
        	getY(), 
        	cast(int) getWidth(), 
        	cast(int) getHeight(), 
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
        platform.unregisterWindow(this);
    }
    
    void setEventManager(WindowEventMgrI mgr)
    {
        emgr = mgr;
    }
    
    WindowEventMgrI getEventManager()
    {
        return emgr;
    }
    
    void setLaf(LafI laf)
    {
        this.laf = laf;
        if (emgr !is null)
        {
            emgr.removeAllActions();
            assert(this.laf !is null);
            this.laf.addEventHandling(emgr);
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
    		
    		SDL_GetWindowSize(sdl_window, &w, &h);
    		
    		setFormWidth(w);
    		setFormHeight(h);
    		setWidth(w);
    		setHeight(h);
    		
    		
    		// int t, l, b, r;
    		// TODO: undefined identifier `SDL_GetWindowBordersSize`
    		/*
    		auto res = SDL_GetWindowBordersSize(sdl_window, &t, &l, &b, &r);
    		if (res != -1)
    		{
    			height = form_height + t + b;
    			width = form_width + l + r;
    		}
    		*/
    		
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
        if (form is null)
            return;
        
        form.redraw();
    }
    
    void printParams()
    {
    	import std.format;
        writeln(
        	q{
title      : %s         		
x          : %d
y          : %d
width      : %d
height     : %d
form_width : %d
form_height: %d
        	}.format(
        		title, 
        		getX(),
        		getY(),
        		getWidth(),
        		getHeight(), 
        		getFormWidth(),
        		getFormHeight()
        		)
        	);
    }
    
    PlatformI getPlatform()
    {
        return platform;
    }
    
    DrawingSurfaceI getDrawingSurface()
    {
        return drawing_surface;
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
        this.form = form;
    }
    
    void unsetForm()
    {
        this.form = null;
    }
    
    FormI getForm()
    {
        return form;
    }
    
    // Position2D getPoint()
    // {
        // return _point;
    // }
    // 
    // Tuple!(bool, Position2D) setPoint(Position2D point)
    // {
        // this._point = point;
        // return tuple(true, this._point);
    // }
    // 
    // Size2D getSize()
    // {
        // return _size;
    // }
    // 
    // Tuple!(bool, Size2D) setSize(Size2D size)
    // {
        // this._size = size;
        // return tuple(true, this._size);
    // }
    
    string getTitle()
    {
        return title;
    }
    
    void setTitle(string value)
    {
        title = value;
    }     
    
}
