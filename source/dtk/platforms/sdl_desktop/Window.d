module dtk.platforms.sdl_desktop.Window;

import std.conv;
import std.string;
import std.typecons;
import std.stdio;
import std.algorithm;
import std.exception;

import bindbc.sdl;

import dtk.interfaces.PlatformI;
import dtk.interfaces.DrawingSurfaceI;
// import dtk.interfaces.FormI;
import dtk.interfaces.WindowI;
// import dtk.interfaces.WindowEventMgrI;
import dtk.interfaces.LaFI;

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
import dtk.types.Widget;
import dtk.types.WindowBorderSizes;

// import dtk.miscs.WindowEventMgr;
// import dtk.miscs.mixin_event_handler_reg;
import dtk.miscs.signal_tools;

import dtk.widgets.Form;

import dtk.signal_mixins.Window;



const auto WindowProperties = cast(PropSetting[]) [
PropSetting("gsun", "SDLDesktopPlatform", "platform", "Platform", "null"),
PropSetting("gsun", "Form", "form", "Form", "null"),
PropSetting("gsun", "LaFI", "forced_laf", "ForcedLaf", "null"),
// PropSetting("gsun", "WindowEventMgrI", "emgr", "WindowEventMgr", "null"),
PropSetting("gsun", "DrawingSurfaceI", "drawing_surface", "DrawingSurface", "null"),

PropSetting("gs_w_d", "dstring", "title", "Title", q{""d}),

// XYWH - XY relative to screen. XYWH = [form XYWH] plus window borders
PropSetting("gs_w_d", "int", "x", "X", "0"),
PropSetting("gs_w_d", "int", "y", "Y", "0"),
PropSetting("gs_w_d", "int", "width", "Width", "0"),
PropSetting("gs_w_d", "int", "height", "Height", "0"),

// [form XYWH] - XY relative to screen. [form XYWH] = XYWH minus window borders
PropSetting("gs_w_d", "int", "formX", "FormX", "0"),
PropSetting("gs_w_d", "int", "formY", "FormY", "0"),
PropSetting("gs_w_d", "int", "formWidth", "FormWidth", "0"),
PropSetting("gs_w_d", "int", "formHeight", "FormHeight", "0"),
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
    	
    	static foreach (v;["X", "Y", "Width", "Height"])
    	{
    		mixin(
    			q{
    				SignalConnection cs_%1$sChange;
    				SignalConnection cs_Form%1$sChange;
    			}.format(v)
    			);
    		
    	}
    	
    	SignalConnection platform_signal_connection;
    }
    
    public
    {
    	bool mouseIn;
    	int mouseX;
    	int mouseY;
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
        
        if (!window_settings.popup_menu.isNull()
        	&& window_settings.popup_menu.get())
        {
        	flags |= SDL_WINDOW_POPUP_MENU;
        }
        
        
        string tt = to!string(window_settings.title);
        
        sdl_window = SDL_CreateWindow(
        	tt.toStringz(),
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
        
        static foreach (v;["X", "Y", "Width", "Height"])
    	{
    		mixin(
    			q{
    				cs_%1$sChange = connectTo%1$s_onAfterChanged(
    					delegate void(
    						int old_value,
    						int new_value
    						)
    					{
    						collectException(
    							{
    								if (old_value == new_value)
    									return;
    								
    								static if ("%1$s" == "X" || "%1$s" == "Y")
    								{
    									intWindowPosChanged();
    								}
    								else
    								{
    									intWindowSizeChanged();
    								}
    							}()
    							);
    					}
    					);
    				
    				cs_Form%1$sChange = connectToForm%1$s_onAfterChanged(
    					delegate void(
    						int old_value,
    						int new_value
    						)
    					{
    						collectException(
    							{
    								if (old_value == new_value)
    									return;
    								
    								static if ("%1$s" == "X" || "%1$s" == "Y")
    								{
    									intWindowFormPosChanged();
    								}
    								else
    								{
    									intWindowFormSizeChanged();
    								}
    							}()
    							);
    					}
    					);
    			}.format(v));
    	}
    }
    
    private void intWindowPosChanged()
    {
    	auto validFormXY = positionRemoveWindowBorder(
    		Position2D(
    			getX(), 
    			getY()
    			)
    		);
    	
    	if (getFormX() != validFormXY.x)
    		setFormX(validFormXY.x);
    	
    	if (getFormY() != validFormXY.y)
    		setFormY(validFormXY.y);
    }
    
    private void intWindowSizeChanged()
    {
    	auto validFormWH = sizeRemoveWindowBorder(
    		Size2D(
    			getWidth(), 
    			getHeight()
    			)
    		);    	
    	
    	if (getFormWidth() != validFormWH.width)
    		setFormWidth(validFormWH.width);
    	
    	if (getFormHeight() != validFormWH.height)
    		setFormHeight(validFormWH.height);
    }
    
    private void intWindowFormPosChanged()
    {
    	auto validXY = positionAddWindowBorder(
    		Position2D(
    			getFormX(), 
    			getFormY()
    			)
    		);
    	
    	if (getX() != validXY.x)
    	{
    		setX(validXY.x);
    	}
    	
    	if (getY() != validXY.y)
    	{
    		setY(validXY.y);
    	}
    	
    	// int x;
    	// int y;
    	
    	// SDL_GetWindowPosition(sdl_window, &x, &y);
    	// if (x != getFormX() || y != getFormY())
    	// SDL_SetWindowPosition(sdl_window, getFormX(), getFormY());
    }
    
    private void intWindowFormSizeChanged()
    {
    	auto validWH = sizeAddWindowBorder(
    		Size2D(
    			getFormWidth(), 
    			getFormHeight()
    			)
    		);    	
    	
    	if (getWidth() != validWH.width)
    	{
    		setWidth(validWH.width);
    	}
    	
    	if (getHeight() != validWH.height)
    	{
    		setHeight(validWH.height);
    	}
    	
    	// int w;
    	// int h;
    	// 
    	// SDL_GetWindowSize(sdl_window, &w, &h);
    	// if (w != getFormWidth() || h != getFormHeight())
    		// SDL_SetWindowSize(sdl_window, getFormWidth(), getFormHeight());
    }
    
    private void windowSyncPosition(bool externalStronger)
    {
    	int x;
    	int y;
    	SDL_GetWindowPosition(
    		this.sdl_window,
    		&x,
    		&y,
    		);
    	
    	auto fx = getFormX();
    	auto fy = getFormY();
    	
    	bool changed_x = (x != fx);
    	bool changed_y = (y != fy);
    	
    	WindowBorderSizes wbs;
    	
    	if (changed_x || changed_y)
    	{
    		wbs = getBorderSizes();
    	}
    	
    	if (externalStronger)
    	{
    		if (changed_x)
    		{
    			setFormX(x);
    		}
    		if (changed_y)
    		{
    			setFormY(y);
    		}
    	}
    	else
    	{
    		SDL_SetWindowPosition(
    			this.sdl_window,
    			fx,
    			fy,
    			);
    	}
    }
    
    private void windowSyncSize(bool externalStronger)
    {
    	int w;
    	int h;
    	SDL_GetWindowSize(
    		this.sdl_window,
    		&w,
    		&h,
    		);
    	
    	auto fw = getFormWidth();
    	auto fh = getFormHeight();
    	
    	bool changed_w = (w != fw);
    	bool changed_h = (h != fh);
    	
    	WindowBorderSizes wbs;
    	
    	if (changed_w || changed_h)
    	{
    		wbs = getBorderSizes();
    	}
    	
    	if (externalStronger)
    	{
    		if (changed_w)
    		{
    			setFormWidth(w);
    		}
    		if (changed_w)
    		{
    			setFormHeight(h);
    		}
    	}
    	else
    	{
    		SDL_SetWindowSize(
    			this.sdl_window,
    			fw,
    			fh,
    			);
    	}
    }
    
    LaFI getLaf()
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
    			
    			// NOTE: this moved to platform
    			// if (event.type == EventType.mouse
    			// && event.em.type == EventMouseType.movement)
    			// {
    			// // TODO: save relative values too?
    			// mouseX = event.em.x;
    			// mouseY = event.em.y;
    			// }
    			//
    			// {
    			// event.mouseX = mouseX;
    			// event.mouseY = mouseY;
    			// }
    			
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
    					debug writeln(
    						"Setting window form size to %sx%s".format(
    							w,h
    							)
    						);
    					setFormWidth(w);
    					setFormHeight(h);
    					
    					windowSyncSize(true);
    					
    					// NOTE: falling through here, because resizing may
    					//       imply movement
    					goto case;
    				case EnumWindowEvent.move:
    					int x;
    					int y;
    					SDL_GetWindowPosition(
    						this.sdl_window,
    						&x,
    						&y,
    						);
    					debug writeln(
    						"Setting window position to %sx%s".format(
    							x,y
    							)
    						);
    					
    					// NOTE: on SDL SDL_GetWindowPosition returns values
    					//       with borders added
    					setFormX(x);
    					setFormY(y);
    					
    					windowSyncPosition(true);
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
    
    void formDesiredPosSizeChanged()
    {
    	auto f = getForm();
    	if (!f)
    		return;
    	//setFormX(f.getDesiredX());
    	//setFormY(f.getDesiredY());
    	setFormWidth(f.getDesiredWidth());
    	setFormHeight(f.getDesiredHeight());
    	windowSyncPosition(false);
    }
    
    Tuple!(bool, Position2D) getMousePosition()
    {
    	return tuple(mouseIn, Position2D(mouseX, mouseY));
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
    
    // return bool true on success
    WindowBorderSizes getBorderSizes()
    {
    	
    	WindowBorderSizes ret;
    	auto res = SDL_GetWindowBordersSize(
    		sdl_window,
    		&ret.leftTop.height,
    		&ret.leftTop.width,
    		&ret.rightBottom.height,
    		&ret.rightBottom.width,
    		);
    	// TODO: add exception here
    	if (res != 0)
    	{
    		throw new Exception("can't get window border sizes");
    	}
    	return ret;
    }
    
    // convert value without border to value with border.
    // Window Form XY should be passed as parameter
    Position2D positionAddWindowBorder(Position2D pos)
    {
    	auto bs = getBorderSizes();
    	auto ret = Position2D(
    		pos.x - bs.leftTop.width,
    		pos.y - bs.leftTop.height
    		);
    	return ret;
    }
    
    // convert value without border to value with border.
    // Window XY should be passed as parameter
    Position2D positionRemoveWindowBorder(Position2D pos)
    {
    	auto bs = getBorderSizes();
    	auto ret = Position2D(
    		pos.x + bs.leftTop.width,
    		pos.y + bs.leftTop.height
    		);
    	return ret;
    }
    
    Size2D sizeAddWindowBorder(Size2D size)
    {
    	auto bs = getBorderSizes();
    	auto ret = Size2D(
    		size.width + bs.leftTop.width + bs.rightBottom.width,
    		size.height + bs.leftTop.height + bs.rightBottom.height,
    		);
    	return ret;
    }

    Size2D sizeRemoveWindowBorder(Size2D size)
    {
    	auto bs = getBorderSizes();
    	auto ret = Size2D(
    		size.width - bs.leftTop.width + bs.rightBottom.width,
    		size.height - bs.leftTop.height + bs.rightBottom.height,
    		);
    	return ret;
    }

    void setPosition(Position2D pos)
    {
    	pos = positionRemoveWindowBorder(pos);
    	setFormPosition(pos);
    }

    void setFormPosition(Position2D pos)
    {
    	SDL_SetWindowPosition(sdl_window, pos.x, pos.y);
    }
    
    void setSize(Size2D size)
    {
    	size = sizeRemoveWindowBorder(size);
    	setFormSize(size);
    }

    void setFormSize(Size2D size)
    {
    	SDL_SetWindowSize(sdl_window, size.width, size.height);
    }
}
