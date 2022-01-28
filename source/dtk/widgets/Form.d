// root widget fro placing into Window or other pratform-provided host

module dtk.widgets.Form;

import observable.signal;

import std.stdio;
import std.typecons;

import dtk.interfaces.WindowI;
import dtk.interfaces.FormI;
import dtk.interfaces.LafI;
import dtk.interfaces.WidgetI;
import dtk.interfaces.DrawingSurfaceI;
import dtk.interfaces.ContainerI;
import dtk.interfaces.ContainerableI;
import dtk.interfaces.LayoutI;

import dtk.types.Position2D;
import dtk.types.Size2D;

/* import dtk.types.Laf; */
import dtk.types.LineStyle;
import dtk.types.FillStyle;
import dtk.types.Property;
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

class Form : FormI, ContainerI
{
    private {
    	SignalConnectionContainer con_cont;
    }
    
    mixin(mixin_FormSignals(false));
    mixin mixin_multiple_properties_define!(FormProperties);
    mixin mixin_multiple_properties_forward!(FormProperties, false);
    
    this()
    {
    	mixin(mixin_multiple_properties_inst(FormProperties));
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
    
    override DrawingSurfaceI getDrawingSurface()
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
    
    override void redraw()
    {
    	
        /* this.redraw_x(this);
        
        if (isSetChild())
        {
            getChild().redraw();
        }
        
        auto ds = getDrawingSurface();
        ds.present(); */
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
}
