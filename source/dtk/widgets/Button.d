/++
Button Widget. used both freely on form or as ToolBar button
there should not be separate radiobutton or checkbutton: this Button class
should be visually transformed to such using it's properties.
+/

module dtk.widgets.Button;

import std.stdio;
import std.typecons;
import std.exception;

import dtk.interfaces.ContainerI;
// import dtk.interfaces.ContainerableI;
import dtk.interfaces.WidgetI;
// import dtk.interfaces.FormI;

import dtk.types.Size2D;
import dtk.types.EventMouse;
import dtk.types.Property;
import dtk.types.Position2D;
import dtk.types.Image;
import dtk.types.Event;
import dtk.types.EventForm;

import dtk.widgets.Widget;
import dtk.widgets.Form;
import dtk.widgets.mixins;

import dtk.miscs.RadioGroup;
import dtk.miscs.signal_tools;
import dtk.miscs.formEventFilter;

/// Button class
class Button : Widget, WidgetI
{
    mixin mixin_multiple_properties_forward!(WidgetProperties, true);
    mixin mixin_forwardXYWH_from_Widget!();
    mixin mixin_Widget_renderImage!("Button");
    mixin mixin_widget_redraw_using_propagateRedraw!();
    mixin mixin_propagateRedraw_children_none!();
    
    bool button_is_down;
    
    private 
    {
    	SignalConnection sc_parentChange;
    	SignalConnection sc_formEvent;
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
    	sc_parentChange = connectToParent_onAfterChanged(
    		delegate void(
    			ContainerI o,
    			ContainerI n
    			)
    		{
    			collectException(
    				{
    					debug writeln("Button parent changed from ",o," to ",n);
    					
    					scope(exit) 
    					{
    						propagateParentChangeEmision();
    					}
    					
    					if (o == n)
    						return;
    					
    					sc_formEvent.disconnect();
    					
    					if (n !is null)
    					{
    						auto f = getForm();
    						if (f is null)
    						{
    							debug writeln("button window other event: no form");
    							return;
    						}
    						
    						debug writeln("button window other event: connecting");
    						sc_formEvent = f.connectToSignal_Event(
    							&buttonTypeSpecificEventHandler
    							);
    					}
    					
    				}()
    				);
    		}
    		);
    }
    
    void buttonTypeSpecificEventHandler(EventForm* event) nothrow
    {
    	collectException(
    		{
    			auto f = getForm();
    			if (f is null)
    				return;
    			debug writeln("filtering events for button");
    			formEventFilter(
    				event,
    				f,
    				false,
    				false,
    				true,
    				true,
    				this,
    				this,
    				false,
    				null,
    				delegate bool(
    					Form form,
    					EventForm* fe,
    					)
    				{
    					debug writeln("1111111111111111: ", fe.event.eventType);
    					return true;
    				}
    				);
    		}()
    		);
    }
    
    void on_mouse_click_internal(
    	EventMouse* event, 
    	ulong mouseWidget_x, 
    	ulong mouseWidget_y
    	)
    {
        return ;
    }
    
    void on_mouse_down_internal(
    	EventMouse* event, 
    	ulong mouseWidget_x, 
    	ulong mouseWidget_y
    	)
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
    
    void on_mouse_up_internal(
    	EventMouse* event, 
    	ulong mouseWidget_x, 
    	ulong mouseWidget_y
    	)
    {
        button_is_down = false;
        redraw();
        return ;
    }
    
    override void propagatePosAndSizeRecalc()
	{
	}    
	

    
}
