// root widget fro placing into Window or other pratform-provided host

module dtk.widgets.Form;

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
import dtk.interfaces.ContainerableI;
// import dtk.interfaces.LayoutI;

import dtk.types.Position2D;
import dtk.types.Size2D;
import dtk.types.LineStyle;
import dtk.types.FillStyle;
import dtk.types.Property;
import dtk.types.Event;
import dtk.types.FormEvent;

import dtk.widgets.mixins;
import dtk.widgets.Widget;

import dtk.miscs.signal_tools;

import dtk.signal_mixins.Form;

const auto FormProperties = cast(PropSetting[]) [
PropSetting("gsun", "WindowI", "window", "Window", ""),
PropSetting("gsun", "LafI", "laf", "Laf", ""),
PropSetting("gsun", "ContainerableI", "child", "Child", ""),

PropSetting("gsun", "WidgetI", "focused_widget", "FocusedWidget", ""),
PropSetting("gsun", "WidgetI", "default_widget", "DefaultWidget", ""),
];

class Form : ContainerI
{
    private {
    	SignalConnection sc_childChange;
    	SignalConnection sc_windowChange;
    	SignalConnection sc_windowOtherEvents;
    }
    
    mixin(mixin_FormSignals(false));
    mixin mixin_multiple_properties_define!(FormProperties);
    mixin mixin_multiple_properties_forward!(FormProperties, false);
    
    this()
    {
    	mixin(mixin_multiple_properties_inst(FormProperties));
    	
    	sc_childChange = connectToChild_onAfterChanged(
    		delegate void(
    			ContainerableI o,
    			ContainerableI n
    			)
    		{
    			collectException(
    				{
    					if (o !is null)
    						o.unsetParent();
    					if (n !is null && n.getParent() != this)
    						n.setParent(this);
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
    					sc_windowOtherEvents.disconnect();
    					if (n !is null)
    					{
    						sc_windowOtherEvents = n.connectToSignal_OtherEvents(
    							delegate void(Event* e) 
    							{
    								collectException(
    									{
    										FormEvent* fe = new FormEvent();
    										
    										WidgetI focusedWidget = this.getFocusedWidget();
    										WidgetI mouseFocusedWidget;
    										
    										ulong mouseFocusedWidget_x = 0;
    										ulong mouseFocusedWidget_y = 0;
    										
    										{
    											if (e.eventType == EventType.mouse)
    											{
    												auto res = this.getWidgetAtPosition(
    													Position2D(
    														e.em.x,
    														e.em.y
    														)
    													);
    												mouseFocusedWidget = res[0];
    												auto pos = res[1];
    												mouseFocusedWidget_x = pos.x;
    												mouseFocusedWidget_y = pos.y;
    											}
    											else
    											{
    												// TODO: todo
    											}
    										}
    										
    										fe.event = e;
    										fe.focusedWidget = focusedWidget;
    										fe.mouseFocusedWidget = mouseFocusedWidget;
    										fe.mouseFocusedWidget_x = mouseFocusedWidget_x;
    										fe.mouseFocusedWidget_y = mouseFocusedWidget_y;
    										
    										this.emitSignal_Event(fe);
    									}()
    									);
    							}
    							);
    					}
    				}()
    				);
    		}
    		);
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
        if (isSetWindow())
            ret = getWindow().getDrawingSurface();
        return ret;
    }
    
    void propagatePosAndSizeRecalc()
    {
    	auto c = getChild();
    	if (c !is null)
    		c.propagatePosAndSizeRecalc();
    }
    
    Form getForm()
    {
    	return this;
    }
    
    void redraw()
    {
        mixin(mixin_widget_redraw("Form"));
        
        if (isSetChild())
        {
        	getChild().redraw();
        }
        
        auto ds = getDrawingSurface();
        ds.present();
    }
    
    // mixin mixin_getWidgetAtPosition;
    
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
    
    Tuple!(WidgetI, Position2D) getWidgetAtPosition(Position2D point)
    {
    	return tuple(cast(WidgetI) null, Position2D(0,0));
    }
    
    ulong getChildX(ContainerableI child)
    {
    	return 0;
    }
    
    ulong getChildY(ContainerableI child)
    {
    	return 0;
    }
    
    ulong getChildWidth(ContainerableI child)
    {
    	return getWidth();
    }
    
    ulong getChildHeight(ContainerableI child)
    {
    	return getHeight();
    }
    
    void setChildX(ContainerableI child, ulong v)
    {}
    
    void setChildY(ContainerableI child, ulong v)
    {}
    
    void setChildWidth(ContainerableI child, ulong v)
    {}
    
    void setChildHeight(ContainerableI child, ulong v)
    {}
    
    void addChild(ContainerableI child)
    {
    	setChild(child);
    }
    
    void removeChild(ContainerableI child)
    {
    	if (haveChild(child))
    	{
    		unsetChild();
    	}
    }
    
    bool haveChild(ContainerableI child)
    {
    	return getChild() == child;
    }
    
}
