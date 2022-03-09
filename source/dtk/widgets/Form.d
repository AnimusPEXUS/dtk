// root widget fro placing into Window or other pratform-provided host

module dtk.widgets.Form;

import core.sync.mutex;
import std.stdio;
import std.typecons;
import std.exception;

import observable.signal;

import dtk.interfaces.WindowI;
// import dtk.interfaces.FormI;
import dtk.interfaces.LafI;
import dtk.interfaces.WidgetI;
import dtk.interfaces.DrawingSurfaceI;
import dtk.interfaces.ContainerI;
// import dtk.interfaces.WidgetI;
// import dtk.interfaces.LayoutI;

import dtk.types.Position2D;
import dtk.types.Size2D;
import dtk.types.LineStyle;
import dtk.types.FillStyle;
import dtk.types.Property;
import dtk.types.Event;
import dtk.types.EventWindow;
import dtk.types.EventForm;
import dtk.types.Image;

import dtk.widgets.mixins;
import dtk.widgets.Widget;

import dtk.miscs.signal_tools;
import dtk.miscs.DrawingSurfaceShift;

import dtk.signal_mixins.Form;

const auto FormProperties = cast(PropSetting[]) [
PropSetting("gsun", "WindowI", "window", "Window", ""),
PropSetting("gsun", "LafI", "forced_laf", "ForcedLaf", ""),
PropSetting("gsun", "WidgetI", "child", "Child", ""),

PropSetting("gsun", "WidgetI", "focused_widget", "FocusedWidget", ""),
PropSetting("gsun", "WidgetI", "default_widget", "DefaultWidget", ""),
];

class Form : ContainerI, WidgetI
{
    mixin(mixin_FormSignals(false));
    mixin mixin_multiple_properties_define!(FormProperties);
    mixin mixin_multiple_properties_forward!(FormProperties, false);
    mixin mixin_Widget_renderImage!("Form", "");
    // mixin mixin_propagateRedraw_children_one!("");
    
    mixin mixin_propagateParentChangeEmision!();
    
    private {
    	SignalConnection sc_childChange;
    	SignalConnection sc_windowChange;
    	
    	SignalConnection sc_windowOtherEvents;
    	SignalConnection sc_windowEvents;
    }
    
    this()
    {
    	mixin(mixin_multiple_properties_inst(FormProperties));

    	// mixin(mixin_propagateParentChangeEmision_this());

    	sc_childChange = connectToChild_onAfterChanged(
    		delegate void(
    			WidgetI o,
    			WidgetI n
    			)
    		{
    			collectException(
    				{
    					if (o !is null)
    						o.unsetParent();
    					if (n !is null && n.getParent() != this)
    					{
    						n.setParent(this);
    						debug writeln(n, " setParent ", this);
    					}
    				}()
    				);
    		}
    		);
    	
    	sc_windowChange = connectToWindow_onAfterChanged(
    		delegate void(
    			WindowI o,
    			WindowI n
    			)
    		{
    			// TODO: simplify this
    			collectException(
    				{
    					debug writeln("Form window changed from ",o," to ",n);
    					
    					if (o == n)
    						return;
    					
    					sc_windowOtherEvents.disconnect();
    					sc_windowEvents.disconnect();
    					
    					if (o !is null)
    					{
    						o.unsetForm();
    					}
    					
    					if (n !is null)
    					{
    						sc_windowOtherEvents = n.connectToSignal_OtherEvents(
    							&onWindowOtherEvent
    							);
    						sc_windowEvents = n.connectToSignal_WindowEvents(
    							&onWindowEvent
    							);
    					}
    					
    					propagateParentChangeEmision();
    					
    				}()
    				);
    		}
    		);
    }
    
    void onWindowOtherEvent(Event* event) nothrow
    {
    	collectException(
    		{
    			EventForm* fe = new EventForm();
    			debug writeln("Form.onWindowOtherEvent: ", event.eventType);
    			
    			WidgetI focusedWidget = this.getFocusedWidget();
    			WidgetI mouseFocusedWidget;
    			
    			ulong mouseFocusedWidget_x = 0;
    			ulong mouseFocusedWidget_y = 0;
    			
    			{    			
    				
    				ulong form_mouse_x;
    				ulong form_mouse_y;
    				
    				/* if (event.eventType == EventType.mouse)
    				{
    					form_mouse_x = cast(ulong)event.em.x;
    					form_mouse_y = cast(ulong)event.em.y;
    				}
    				else */
    				{
    					auto w = getWindow();
    					if (w is null)
    					{
    						debug writeln("onWindowOtherEvent w is null");
    						return;
    					}
    					auto res = w.getMousePosition();
    					if (!res[0])
    					{
    						debug writeln("onWindowOtherEvent getMousePosition false");
    						return;
    					}
    					form_mouse_x = res[1].x;
    					form_mouse_y = res[1].y;
    				}
    				auto res = this.getChildAtPosition(
    					Position2D(
    						cast(int)form_mouse_x,
    						cast(int)form_mouse_y
    						)
    					);
    				mouseFocusedWidget = res[0];
    				auto pos = res[1];
    				mouseFocusedWidget_x = pos.x;
    				mouseFocusedWidget_y = pos.y;
    			}
    			
    			fe.event = event;
    			fe.focusedWidget = focusedWidget;
    			fe.mouseFocusedWidget = mouseFocusedWidget;
    			fe.mouseFocusedWidget_x = mouseFocusedWidget_x;
    			fe.mouseFocusedWidget_y = mouseFocusedWidget_y;
    			
    			this.emitSignal_Event(fe);
    		}()
    		);
    }
    
    void onWindowEvent(EventWindow* event) nothrow
    {
    	collectException(
    		{
    			auto e = collectException(
    				{
    					bool propogate_resize_and_repaint = false;
    					
    					debug writeln("form received window event: ", event.eventId);
    					
    					switch (event.eventId)
    					{
    					default:
    						break;
    					case EnumWindowEvent.resize:
    					case EnumWindowEvent.show:
    						propogate_resize_and_repaint = true;
    					}
    					
    					if (propogate_resize_and_repaint)
    					{
    						auto ds = getDrawingSurface();
    						if (ds is null)
    						{
    							debug writeln(new Exception("drawing surface unavailable"));
    							return;
    						}
    						debug writeln("calling propagatePosAndSizeRecalc");
    						propagatePosAndSizeRecalc();
    						debug writeln("calling redraw");
    						redraw();
    					}
    				}()
    				);
    			debug if (e !is null) writeln("exception: ", e);
    		}()
    		);
    }
    
    ContainerI getParent()
    {
    	return null;
    }
    
    
    LafI getLaf()
    {
    	auto l = getForcedLaf();
    	if (l !is null)
    		return l;
    	auto w = getWindow();
    	if (w is null)
    	{
    		throw new Exception("getLaf(): both ForcedLaf and Window is not set");
    	}
    	l = w.getLaf();
    	if (l is null)
    	{
    		throw new Exception("Window returned null Laf");
    	}
    	return l;
    }
    
    ulong getX()
    {
    	return 0;
    }
    
    ulong getY()
    {
    	return 0;
    }
    
    ulong getWidth()
    {
    	if (isSetWindow())
    	{
    		return getWindow.getFormWidth();
    	}
    	return 0;
    }
    
    ulong getHeight()
    {
    	if (isSetWindow())
    	{
    		return getWindow.getFormHeight();
    	}
    	return 0;
    }
    
    Form setX(ulong v)
    {
    	return this;
    }
    
    Form setY(ulong v)
    {
    	return this;
    }
    
    Form setWidth(ulong v)
    {
    	return this;
    }
    
    Form setHeight(ulong v)
    {
    	return this;
    }
    
    DrawingSurfaceI getDrawingSurface()
    {
        DrawingSurfaceI ret = null;
        debug if (!isSetWindow())
        {
        	writeln("window is not set on Form.getDrawingSurface()");
        }
        if (isSetWindow())
        {
            ret = getWindow().getDrawingSurface();
        }
        assert(ret !is null);
        return ret;
    }
    
    DrawingSurfaceI shiftDrawingSurfaceForChild(
		DrawingSurfaceI ds,
		WidgetI child
		)
    {
    	if (getChild() != child)
    		throw new Exception("not a child");
    	
    	auto x = getChildX(child);
        auto y = getChildY(child);
        
        auto ret = new DrawingSurfaceShift(
        	ds,
        	cast(int)x,
        	cast(int)y
        	);
        
        return ret;
    }
    
    Form getForm()
    {
    	return this;
    }
    
    void focusTo(WidgetI widget)
    {
        auto x = getFocusedWidget();
        setFocusedWidget(widget);
        if (x !is null)
        {
            x.redraw();
        }
    }
    
    private WidgetI focusXWidget(WidgetI delegate() getXFocusableWidget)
    {
        WidgetI cfw;
        
        if (isSetFocusedWidget())
        {
            cfw = getFocusedWidget();
        }
        
        auto w = getXFocusableWidget();
        setFocusedWidget(w);
        if (w is null)
        {
            unsetFocusedWidget();
        }
        
        return (isSetFocusedWidget() ? getFocusedWidget() : null);
    }
    
    WidgetI focusNextWidget()
    {
        return focusXWidget(&getNextFocusableWidget);
    }
    
    WidgetI focusPrevWidget()
    {
        return focusXWidget(&getPrevFocusableWidget);
    }
    
    WidgetI getNextFocusableWidget()
    {
        return null;
    }
    
    WidgetI getPrevFocusableWidget()
    {
        return null;
    }
    
    Tuple!(WidgetI, Position2D) getChildAtPosition(Position2D point)
    {
    	
    	auto ret_this = tuple(cast(WidgetI)this, Position2D(0,0));
    	
    	auto c = getChild();
    	
    	if (c is null)
    	{
    		return ret_this;
    	}
    	
    	auto w = getWidth();
    	auto h = getHeight();
    	
    	if (w <= 10 || h <= 10)
    	{
    		return ret_this;
    	}
    	
    	auto p_x = point.x;
    	auto p_y = point.y;
    	
    	if (p_x < 5
    		|| p_y < 5
    	|| (p_x < w && p_x > w-5)
    	|| (p_y < h && p_y > h-5)
    	)
    	{
    		return ret_this;
    	}
    	
    	return c.getChildAtPosition(Position2D(p_x - 5, p_y - 5));
    }
    
    ulong getChildX(WidgetI child)
    {
    	return 5;
    }
    
    ulong getChildY(WidgetI child)
    {
    	return 5;
    }
    
    ulong getChildWidth(WidgetI child)
    {
    	auto x = getWidth();
    	if (x>5)
    		return x-10;
    	else
    		return 0;
    }
    
    ulong getChildHeight(WidgetI child)
    {
    	auto x = getHeight();
    	if (x>5)
    		return x-10;
    	else
    		return 0;
    }
    
    void setChildX(WidgetI child, ulong v)
    {}
    
    void setChildY(WidgetI child, ulong v)
    {}
    
    void setChildWidth(WidgetI child, ulong v)
    {}
    
    void setChildHeight(WidgetI child, ulong v)
    {}
    
    void addChild(WidgetI child)
    {
    	setChild(child);
    }
    
    void removeChild(WidgetI child)
    {
    	if (haveChild(child))
    	{
    		unsetChild();
    	}
    }
    
    bool haveChild(WidgetI child)
    {
    	return getChild() == child;
    }
    
    void propagatePosAndSizeRecalc()
    {
    	auto w = getWindow();
    	if (w !is null)
    	{
    		setWidth(w.getFormWidth());
    		setHeight(w.getFormHeight());
    	}
    	
    	auto c = getChild();
    	if (c !is null)
    		c.propagatePosAndSizeRecalc();
    }
    
    void redraw()
    {
    	auto img = propagateRedraw();
    	auto ds = getDrawingSurface();
    	ds.drawImage(Position2D(0,0), img);
    	ds.present();
    }
    
    Image propagateRedraw()
    {
    	auto img = this.renderImage();
    	
    	auto c = getChild();
    	if (c !is null)
    	{
    		auto c_img = c.propagateRedraw();
    		this.drawChild(img, c, c_img);
    	}
    	return img;
    }
    
    void drawChild(WidgetI child, Image img)
    {
    	auto ds = getDrawingSurface();
    	drawChild(ds, child, img);
    	return;
    }
    
    void drawChild(DrawingSurfaceI ds, WidgetI child, Image img)
    {
    	ds = shiftDrawingSurfaceForChild(ds, child);
    	ds.drawImage(Position2D(0, 0), img);
    }
    
    WidgetI setParent(ContainerI container)
    {
    	return this;
    }
    
    WidgetI unsetParent()
    {
    	return this;
    }
    
}
