/++
Button Widget. used both freely on form or as ToolBar button
there should not be separate radiobutton or checkbutton: this Button class
should be visually transformed to such using it's properties.
+/

module dtk.widgets.Button;

import std.format;
import std.stdio;
import std.datetime;
import std.typecons;
import std.exception;

// import dtk.interfaces.ContainerI;
// import dtk.interfaces.ContainerableI;
//import dtk.interfaces.WidgetI;
// import dtk.interfaces.FormI;
import dtk.interfaces.DrawingSurfaceI;

import dtk.types.Size2D;
import dtk.types.Property;
import dtk.types.Position2D;
import dtk.types.Image;
import dtk.types.Event;
import dtk.types.Widget;

// import dtk.widgets.Widget;
import dtk.miscs.RadioGroup;
import dtk.miscs.signal_tools;
import dtk.miscs.layoutCollection;
import dtk.miscs.layoutTools;
import dtk.miscs.DrawingSurfaceShift;

import dtk.widgets.Form;
import dtk.widgets.TextEntry;
import dtk.widgets.mixins;


const auto ButtonProperties = cast(PropSetting[]) [
// PropSetting("gsun", "WidgetChild", "captionWidget", "CaptionWidget", q{null}),
];

class Button : Widget
{
	mixin mixin_multiple_properties_define!(ButtonProperties);
    mixin mixin_multiple_properties_forward!(ButtonProperties, false);
    mixin mixin_Widget_renderImage!("Button");
    // mixin mixin_widget_redraw_using_propagateRedraw!();
    
    this()
    {
    	super(0, 0);
    	mixin(mixin_multiple_properties_inst(ButtonProperties));
    }
    
    private
    {
    	WidgetChild captionWidget;
    }
    
    WidgetChild getCaptionWidget()
    {
    	return captionWidget;
    }

	override WidgetChild[] calcWidgetServiceChildrenArray()
    {
    	return [captionWidget];
    }    

    Button setTextLabel(dstring text)
    {
    	auto cWidget = Label(text);
    	cWidget.setParent(this);
    	captionWidget = new WidgetChild(cWidget);
    	return this;
    }
    
    override bool intIsVisuallyPressed()
    {
    	return getVisuallyPressed();
    }
    
    override void intVisuallyPress(Widget widget, EventForm* event)
    {
    	setVisuallyPressed(true);
    	redraw();
    }
    override void intVisuallyRelease(Widget widget, EventForm* event)
    {
    	setVisuallyPressed(false);
    	redraw();
    }
    
    override void intMousePressRelease(Widget widget, EventForm* event)
    {debug writeln("click");}
    
    override void propagatePosAndSizeRecalcBefore()
    {
    	auto cc = getChildCount();
    	debug writeln("Button child count %s".format(cc));
    	/* if (text_view !is null)
    	{
    		text_view.recalculateWidthAndHeight();
    	} */
    	if (cc != 0)
    	{
    		auto c = getCaptionWidget();
    		debug writeln(
    			"Button child x: %s, y: %s, w: %s, h: %s".format(
    				c.getX(),
    				c.getY(),
    				c.getWidth(),
    				c.getHeight()
    				)
    			);
    	}
    }
    
    override void propagatePosAndSizeRecalcAfter()
    {
    	auto c = getCaptionWidget();
    	if (c !is null)
    	{
    		alignParentChild(0.5, 0.5, this, c.child);
    	}
    }
    
}
