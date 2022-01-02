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
import dtk.interfaces.ContainerableWidgetI;
import dtk.interfaces.LayoutI;

import dtk.types.Position2D;
import dtk.types.Size2D;

/* import dtk.types.Laf; */
import dtk.types.LineStyle;
import dtk.types.FillStyle;
import dtk.types.Property;

import dtk.widgets.mixins;
import dtk.widgets.Widget;

class Form : FormI
{

    mixin mixin_install_multiple_properties!(
        cast(PropSetting[])[
        PropSetting("gsun", "WindowI", "window", "Window", ""),
        PropSetting("gsun", "LafI", "laf", "Laf", ""),
        PropSetting("gsun", "LayoutI", "layout", "Layout", ""),
        
        PropSetting("gsun", "WidgetI", "focused_widget", "FocusedWidget", ""),
        PropSetting("gsun", "WidgetI", "default_widget", "DefaultWidget", ""),
        ]
        );
    
    private {
    	SignalConnectionContainer con_cont;
    }
    
    this()
    {
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
    
    override void positionAndSizeRequest(Position2D position, Size2D size)
    {
        super.positionAndSizeRequest(position, size);
        this.recalculateChildrenPositionsAndSizes();
    }
    
    override void recalculateChildrenPositionsAndSizes()
    {
        auto position = getPosition();
        auto size = getSize();
        if (isSetChild())
        {
            auto c = getChild();
            c.positionAndSizeRequest(Position2D(position.x + 5, position.y + 5),
            	Size2D(size.width - 10, size.height - 10));
        }
    }
    
    override void redraw()
    {
    	
        this.redraw_x(this);
        
        if (isSetChild())
        {
            getChild().redraw();
        }
        
        auto ds = getDrawingSurface();
        ds.present();
    }
    
    mixin mixin_getWidgetAtPosition;
    
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
    
}
