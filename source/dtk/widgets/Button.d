/++
Button Widget. used both freely on form or as ToolBar button
there should not be separate radiobutton or checkbutton: this Button class
should be visually transformed to such using it's properties.
+/

module dtk.widgets.Button;

import std.stdio;
import std.typecons;

import dtk.interfaces.ContainerI;
import dtk.interfaces.ContainerableI;
import dtk.interfaces.WidgetI;
// import dtk.interfaces.FormI;

import dtk.types.Size2D;
import dtk.types.EventMouse;
import dtk.types.Property;
import dtk.types.Position2D;

import dtk.widgets.Widget;
import dtk.widgets.Form;
import dtk.widgets.mixins;

import dtk.miscs.RadioGroup;

/// Button class
class Button : Widget, ContainerableI
{
    mixin mixin_multiple_properties_forward!(WidgetProperties, true);
    mixin mixin_forwardXYWH_from_Widget!();    
    
    bool button_is_down;
    
    this()
    {
        // setFocusable(true);
        
        // setMouseHandler("button-click", &on_mouse_click_internal);
        // setMouseHandler("button-down", &on_mouse_down_internal);
        // setMouseHandler("button-up", &on_mouse_up_internal);
    }
    
    // mixin mixin_getWidgetAtPosition;
    
    void on_mouse_click_internal(EventMouse* event, ulong mouseWidget_x, ulong mouseWidget_y)
    {
        return ;
    }
    
    void on_mouse_down_internal(EventMouse* event, ulong mouseWidget_x, ulong mouseWidget_y)
    {
        button_is_down = true;
        auto f = getForm();
        if (f !is null)
        {
            f.focusTo(this);
        }
        redraw();
        return ;
    }
    
    void on_mouse_up_internal(EventMouse* event, ulong mouseWidget_x, ulong mouseWidget_y)
    {
        button_is_down = false;
        redraw();
        return ;
    }
    
    override void redraw()
    {
        mixin(mixin_widget_redraw("Button"));
    }
    
    override void propagatePosAndSizeRecalc()
    {
    }
    
    override Tuple!(WidgetI, Position2D) getWidgetAtPosition(Position2D point)
    {
    	return tuple(cast(WidgetI)this, point);
    }
    
}
