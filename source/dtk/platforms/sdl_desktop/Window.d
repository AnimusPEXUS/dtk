module dtk.platforms.sdl_desktop.Window;

import std.typecons;
import std.stdio;
import std.algorithm;
import std.exception;

import bindbc.sdl;

import dtk.interfaces.PlatformI;
import dtk.interfaces.DrawingSurfaceI;
// import dtk.interfaces.FormI;
import dtk.interfaces.WindowI;
import dtk.interfaces.WidgetI;
// import dtk.interfaces.WindowEventMgrI;
import dtk.interfaces.LafI;

import dtk.platforms.sdl_desktop.DrawingSurface;
import dtk.platforms.sdl_desktop.SDLDesktopPlatform;
import dtk.platforms.sdl_desktop.utils;

import dtk.types.Position2D;
import dtk.types.Size2D;
import dtk.types.WindowCreationSettings;
import dtk.types.Event;
import dtk.types.EventWindow;
import dtk.types.EventKeyboard;
import dtk.types.EventMouse;
import dtk.types.EventTextInput;
import dtk.types.Property;

// import dtk.miscs.WindowEventMgr;
// import dtk.miscs.mixin_event_handler_reg;
import dtk.miscs.signal_tools;

import dtk.signal_mixins.Window;

import dtk.widgets.Form;


const auto WindowProperties = cast(PropSetting[]) [
PropSetting("gsun", "SDLDesktopPlatform", "platform", "Platform", "null"),
PropSetting("gsun", "Form", "form", "Form", "null"),
PropSetting("gsun", "LafI", "forced_laf", "ForcedLaf", "null"),
// PropSetting("gsun", "WindowEventMgrI", "emgr", "WindowEventMgr", "null"),
PropSetting("gsun", "DrawingSurfaceI", "drawing_surface", "DrawingSurface", "null"),

PropSetting("gs_w_d", "dstring", "title", "Title", q{""d}),
PropSetting("gs_w_d", "int", "x", "X", "0"),
PropSetting("gs_w_d", "int", "y", "Y", "0"),
PropSetting("gs_w_d", "ulong", "width", "Width", "0"),
PropSetting("gs_w_d", "ulong", "height", "Height", "0"),
PropSetting("gs_w_d", "ulong", "form_width", "FormWidth", "0"),
PropSetting("gs_w_d", "ulong", "form_height", "FormHeight", "0"),
];

class Window : WindowI
{
	
    // TODO: maybe this shouldn't be public
    public
    {
        SDL_Window* sdl_window;
        typeof(SDL_WindowEvent.windowID) sdl_window_id;
    }
    
    private
    {
    	SignalConnection cs_PlatformChange;
    	// SignalConnection cs_LafChange;
    	SignalConnection cs_FormChange;
    	
    	SignalConnection platform_signal_connection;
    }
    
    private
    {
    	bool mouse_in;
    	ulong mouse_x;
    	ulong mouse_y;
    }
    
	mixin mixin_multiple_properties_define!(WindowProperties);
    mixin mixin_multiple_properties_forward!(WindowProperties, false);
    
    mixin(mixin_WindowSignals(false));
    
    @disable this();
    
    this(WindowCreationSettings window_settings)
    {
    	mixin(mixin_multiple_properties_inst(WindowProperties));
    	
        setTitle(window_settings.title);
        
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
        
        setDrawingSurface(new DrawingSurface(this));
        
        // without this SDL makes fullscreen window;
        auto flags = cast(SDL_WindowFlags) 0;
        
        if (!window_settings.resizable.isNull()
        	&& window_settings.resizable.get())
        {
        	flags |= SDL_WINDOW_RESIZABLE;
        }
        
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
            // TODO: add SDL info print on debug build?
            // auto r = SDL_GetRenderer(sdl_window);
            // SDL_RendererInfo ri;
            // SDL_GetRendererInfo(r, &ri);
        }
        
        sdl_window_id = SDL_GetWindowID(sdl_window);
        if (sdl_window_id == 0)
        {
            throw new Exception("error getting SDL window id");
        }
        
        // setWindowEventMgr(new WindowEventMgr(this));
        
        cs_PlatformChange = connectToPlatform_onAfterChanged(
        	delegate void(
        		SDLDesktopPlatform old_value,
        		SDLDesktopPlatform new_value
        		)
        	{
        		collectException(
        			{
        				if (old_value == new_value)
        					return;
        				
        				platform_signal_connection.disconnect();
        				
        				if (old_value !is null)
        					old_value.removeWindow(this);
        				
        				if (new_value !is null)
        				{
        					if (!new_value.haveWindow(this))
        						new_value.addWindow(this);
        					platform_signal_connection=
        					new_value.connectToSignal_Event(
        						&onPlatformEvent
        						);
        				}
        			}()
        			);
        	}
        	);
        
        cs_FormChange = connectToForm_onAfterChanged(
        	delegate void(
        		Form old_value,
        		Form new_value
        		)
        	{
        		collectException(
        			{
        				if (old_value == new_value)
        					return;
        				
        				if (old_value !is null)
        					old_value.unsetWindow();
        				
        				if (new_value !is null && new_value.getWindow() != this)
        					new_value.setWindow(this);
        			}()
        			);
        	}
        	);
    }
    
    LafI getLaf()
    {
    	auto l = getForcedLaf();
    	if (l !is null)
    		return l;
    	auto p = getPlatform();
    	if (p is null)
    	{
    		throw new Exception("getLaf(): both ForcedLaf and Platform is not set");
    	}
    	l = p.getLaf();
    	if (l is null)
    	{
    		throw new Exception("Platform returned null Laf");
    	}
    	return l;
    }
    
    void onPlatformEvent(Event* event) nothrow
    {
    	collectException(
    		{
    			if (event.window != this)
    				return;
    			
    			if (event.type == EventType.none)
    			{
    				debug writeln("event.type == EventType.none");
    				return;
    			}
    			
    			if (event.type == EventType.mouse
    				&& event.em.type == EventMouseType.movement)
    			{
    				// TODO: save relative values too?
    				mouse_x = event.em.x;
    				mouse_y = event.em.y;
    			}
    			
    			{
    				event.mouse_x = cast(int)mouse_x;
    				event.mouse_y = cast(int)mouse_y;
    			}
    			
    			if (event.type == EventType.window)
    			{
    				switch (event.ew.eventId)
    				{
    				default:
    					break;
    				case EnumWindowEvent.resize:
    				case EnumWindowEvent.show:
    					int w;
    					int h;
    					SDL_GetWindowSize(
    						this.sdl_window,
    						&w,
    						&h,
    						);
    					setFormWidth(w);
    					setFormHeight(h);
    				}
    				emitSignal_WindowEvents(event.ew);
    			}
    			else
    			{
    				emitSignal_OtherEvents(event);
    			}
    		}()
    		);
        return;
    }
    
    Tuple!(bool, Position2D) getMousePosition()
    {
    	/*     	auto ret_fail = tuple(false, Position2D(0,0));
    	int x;
    	int y;
    	SDL_GetMouseState(&x, &y);
    	if (x < 0 || y < 0)
    	{
    	debug writeln("getMousePosition: x or y is negative");
    	return ret_fail;
    	}
    	return tuple(true, Position2D(x,y)); */
    	return tuple(mouse_in, Position2D(cast(int)mouse_x,cast(int)mouse_y));
    }
    
    void redraw()
    {
    	auto form = getForm();
    	
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
    
    // private void installForm(Form form)
    // {
    // uninstallForm();
    //
    // setForm(form);
    // auto x = getForm();
    // assert(x !is null);
    // x.setWindow(this);
    // /* x.setDrawingSurface(this._drawing_surface); */
    // x.setLaf(getPlatform().getLaf());
    // }
    //
    // private void uninstallForm()
    // {
    // auto x = getForm();
    // if (x !is null)
    // {
    // x.unsetLaf();
    // /* x.unsetDrawingSurface(); */
    // x.unsetWindow();
    // }
    // this.unsetForm();
    // }
    
    /* static foreach(v; ["Window", "Keyboard", "Mouse", "TextInput"])
    {
    mixin(mixin_event_handler_reg(v));
    } */
    
}
