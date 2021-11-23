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

import dtk.types.Position2D;
import dtk.types.Size2D;

/* import dtk.types.Laf; */
import dtk.types.LineStyle;
import dtk.types.FillStyle;
import dtk.types.Property;

import dtk.widgets.mixins;
import dtk.widgets.Widget;

class Form : Widget, FormI
{
    
    mixin mixin_install_multiple_properties!(
        cast(PropSetting[])[
        PropSetting("gsun", "WindowI", "window", "Window", ""),
        PropSetting("gsun", "LafI", "laf", "Laf", ""),
        PropSetting("gsun", "ContainerableWidgetI", "child", "Child", ""),
        
        PropSetting("gsun", "WidgetI", "focused_widget", "FocusedWidget", ""),
        PropSetting("gsun", "WidgetI", "default_widget", "DefaultWidget", ""),
        ]
        );
    
    private {
    	SignalConnectionContainer con_cont;
    }
    
    this()
    {
        con_cont.add(connectToChild_onAfterChanged(&onChildChanged));
    }

    void onChildChanged(ContainerableWidgetI old_v, ContainerableWidgetI new_v) nothrow
    {
        try
        {
            debug writeln("Form child changed");
            auto c = getChild();
            c.setParent(this);
            /* c.setPosition(Position2D(5,5));
            auto = this_size
            c.setSize(Size2D()); */
            this.recalculateChildrenPositionsAndSizes();
        }
        catch (Exception e)
        {
        	
        }
        
    }
    
    override DrawingSurfaceI getDrawingSurface()
    {
        DrawingSurfaceI ret = null;
        if (isSetWindow())
            ret = getWindow().getDrawingSurface();
        return ret;
    }
    
    /* private nothrow void onwindowchanged()
    {
    try {
    debug writeln("onwindowchanged()");
    } catch (Exception e) {
    // TODO:
    }
    } */
    
    override typeof(this) setParent(WidgetI widget)
    {
        return null;
    }
    
    override typeof(this) unsetParent()
    {
        return null;
    }
    
    override WidgetI getParent()
    {
        return null;
    }
    
    override Form getForm()
    {
        return this;
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
            debug writeln("getChild().redraw();");
            getChild().redraw();
        }
        
        auto ds = getDrawingSurface();
        ds.present();
    }
    
    mixin mixin_getWidgetAtPosition;
    
    void focusTo(WidgetI widget)
    {
        debug writeln("Form:focusTo: ", widget);
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
    
    override WidgetI getNextFocusableWidget()
    {
        return null;
    }
    
    override WidgetI getPrevFocusableWidget()
    {
        return null;
    }
    
}
