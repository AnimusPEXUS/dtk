/++
Button Widget. used both freely on form or as ToolBar button
there should not be separate radiobutton or checkbutton: this Button class
should be visually transformed to such using it's properties.
+/

module dtk.widgets.Button;

import std.stdio;
import std.datetime;
import std.typecons;
import std.exception;

import dtk.interfaces.ContainerI;
// import dtk.interfaces.ContainerableI;
import dtk.interfaces.WidgetI;
// import dtk.interfaces.FormI;
import dtk.interfaces.DrawingSurfaceI;

import dtk.types.Size2D;
import dtk.types.Property;
import dtk.types.Position2D;
import dtk.types.Image;
import dtk.types.Event;

import dtk.widgets.Widget;
import dtk.widgets.Form;
import dtk.widgets.TextEntry;
import dtk.widgets.mixins;

import dtk.miscs.RadioGroup;
import dtk.miscs.signal_tools;
import dtk.miscs.layoutCollection;
import dtk.miscs.DrawingSurfaceShift;


const auto ButtonProperties = cast(PropSetting[]) [
PropSetting("gsun", "WidgetI", "child", "Child", ""),
];

class Button : Widget, WidgetI, ContainerI
{
	mixin mixin_multiple_properties_define!(ButtonProperties);
    mixin mixin_multiple_properties_forward!(ButtonProperties, false);
    mixin mixin_multiple_properties_forward!(WidgetProperties, true);
    mixin mixin_forwardXYWH_from_Widget!();
    mixin mixin_Widget_renderImage!("Button");
    mixin mixin_widget_redraw_using_propagateRedraw!();
    mixin mixin_propagateRedraw_children_one!();
    
    bool button_is_down;
    
    private
    {
    	SignalConnection sc_parentChange;
    	SignalConnection sc_childChange;
    	SignalConnection sc_formEvent;
    }
    
    private
    {
    	int c_x;
    	int c_y;
    	int c_w;
    	int c_h;
    }
    
    // mixin mixin_getWidgetAtPosition;
    mixin mixin_forward_super_functions!(
    	[
    	"getForm",
    	"getNextFocusableWidget",
    	"getPrevFocusableWidget",
    	"getChildAtPosition",
    	"getDrawingSurface"
    	]
    	);
    
    mixin mixin_propagateParentChangeEmision!();
    
    this()
    {
    	mixin(mixin_multiple_properties_inst(ButtonProperties));
    	mixin(mixin_widgetSingleChildSet01("sc_childChange"));
    }
    
    Button setTextLabel(dstring text)
    {
    	setChild(NewLabel(text));
    	return this;
    }
    
    override void propagatePosAndSizeRecalc()
    {
    	if (getChild() !is null)
    	{
    		alignParentChild(
    			0.5, 0.5,
    			this,
    			getChild()
    			);
    	}
    }
    
    int getChildX(WidgetI child)
    {
    	return c_x;
    }
    
    int getChildY(WidgetI child)
    {
    	return c_y;
    }
    
    int getChildWidth(WidgetI child)
    {
    	return c_w;
    }
    
    int getChildHeight(WidgetI child)
    {
    	return c_h;
    }
    
    void setChildX(WidgetI child, int v)
    {
    	c_x = v;
    }
    
    void setChildY(WidgetI child, int v)
    {
    	c_y = v;
    }
    
    void setChildWidth(WidgetI child, int v)
    {
    	c_w = v;
    }
    
    void setChildHeight(WidgetI child, int v)
    {
    	c_h = v;
    }
    
    int getChildCount()
    {
    	return getChild() is null ? 0 : 1;
    }
    
    WidgetI getChild(int i)
    {
    	if (i == 0)
    	{
    		return getChild();
    	}
    	else
    	{
    		return null;
    	}
    }
    
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
    
	
    override void drawChild(WidgetI child, Image img)
    {
    	auto ds = getDrawingSurface();
    	drawChild(ds, child, img);
    	return;
    }
    
    override void drawChild(DrawingSurfaceI ds, WidgetI child, Image img)
    {
    	ds = shiftDrawingSurfaceForChild(ds, child);
    	ds.drawImage(Position2D(0, 0), img);
    }
    
    DrawingSurfaceI shiftDrawingSurfaceForChild(DrawingSurfaceI ds, WidgetI child)
    {
    	auto c = getChild();
    	return new DrawingSurfaceShift(ds, c.getX(), c.getY());
    }
	
	
    override void focusEnter(Form form, WidgetI widget)
    {}
    override void focusExit(Form form, WidgetI widget)
    {}
    
    override bool isVisualPressed()
    {
    	return button_is_down;
    }
    override void visualPress(Form form, WidgetI widget, EventForm* event)
    {
    	button_is_down=true;
    	redraw();
    }
    override void visualRelease(Form form, WidgetI widget, EventForm* event)
    {
    	button_is_down=false;
    	redraw();
    }
    
    override void intMousePress(Form form, WidgetI widget, EventForm* event)
    {
    }
    override void intMouseRelease(Form form, WidgetI widget, EventForm* event)
    {
    }
    override void intMousePressRelease(Form form, WidgetI widget, EventForm* event)
    {debug writeln("click");}
    override void intMouseLeave(Form form, WidgetI old_w, WidgetI new_w, EventForm* event)
    {
    }
    override void intMouseEnter(Form form, WidgetI old_w, WidgetI new_w, EventForm* event)
    {
    }
    override void intMouseMove(Form form, WidgetI widget, EventForm* event)
    {}
    
    
    override void intKeyboardPress(Form form, WidgetI widget, EventForm* event) {}
    override void intKeyboardRelease(Form form, WidgetI widget, EventForm* event) {}
    
    override void intTextInput(Form form, WidgetI widget, EventForm* event) {}
}
