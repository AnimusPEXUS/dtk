module dtk.widgets.Widget;

import std.stdio;
import std.conv;
import std.typecons;

import dtk.interfaces.FormI;
import dtk.interfaces.WidgetI;
import dtk.interfaces.DrawingSurfaceI;
import dtk.interfaces.LayoutI;
import dtk.interfaces.ContainerI;

import dtk.types.EventWindow;
import dtk.types.EventKeyboard;
import dtk.types.EventMouse;
import dtk.types.EventTextInput;
import dtk.types.Property;
import dtk.types.MoveT;

import dtk.types.Size2D;
import dtk.types.Position2D;

import dtk.miscs.DrawingSurfaceShift;
import dtk.miscs.mixin_event_handler_reg;

/* import dtk.widgets.WidgetLocator; */
// import dtk.widgets;
/* import dtk.widgets.WidgetDrawingSurface; */

import dtk.widgets.Layout;

const auto WidgetProperties = cast(PropSetting[]) [
PropSetting("gsun", "ContainerI", "parent_container", "Parent", "null"),
];

class Widget : WidgetI
{
	
	mixin mixin_multiple_properties_define!(WidgetProperties);
    mixin mixin_multiple_properties_forward!(WidgetProperties, false);
    this() {
    	mixin(mixin_multiple_properties_inst(WidgetProperties));
    }
    
    
    /++ return FormI on which this Widget is placed. returns null in case if
    there is no attached form or if this widget is deeper than 200 levels to
    FormI instance (too deep); +/
    FormI getForm()
    {
        /* WidgetI w = this;
        Form ret;
        
        for (auto failure_countdown = cast(byte) 200; failure_countdown != -1; failure_countdown--)
        {
        
        ret = cast(Form) w;
        if (ret !is null)
        {
        return ret;
        }
        
        if (w.isUnsetParent())
        {
        return null;
        }
        
        w = w.getParent();
        if (w is null)
        {
        return null;
        }
        }
        
        return ret; */
        return null;
    }
    
    DrawingSurfaceI getDrawingSurface()
    {
        /* auto p = getPosition();
        return new DrawingSurfaceShift(getParent().getDrawingSurface(), p.x, p.y); */
        return null;
    }
    
    void redraw()
    {
        this.redraw_x(this);
    }
    
    void redraw_x(T)(T new_this)
    {
    	
        /* alias A1 = typeof(new_this); */
        
        const id = __traits(identifier, new_this);
        const id_t = __traits(identifier, T);
        
        static if (!is(T == Widget))
        {
            const drawid = "draw" ~ id_t;
            
            FormI form = new_this.getForm();
            if (form is null)
            {
                throw new Exception("error: redraw() function couldn't get Form");
            }
            
            auto theme = form.getLaf();
            
            if (theme is null)
            {
                throw new Exception("theme not set");
            }
            
            static if (!__traits(hasMember, theme, drawid))
            {
                return;
            }
            else
            {
                __traits(getMember, theme, drawid)(new_this);
            }
        }
    }
    
    void positionAndSizeRequest(Position2D position, Size2D size)
    {
        /* setPosition(position);
        setSize(size); */
    }
    
    void recalculateChildrenPositionsAndSizes()
    {
        return;
    }
    
    bool handle_event_keyboard(EventKeyboard* e)
    {
        return false;
    }
    
    bool handle_event_mouse(EventMouse* e)
    {
        return false;
    }
    
    bool handle_event_textinput(EventTextInput* e)
    {
        return false;
    }
    
    Tuple!(WidgetI, Position2D) getWidgetAtPosition(Position2D point)
    {
        return tuple(cast(WidgetI)this, Position2D(0, 0));
    }
    
    WidgetI getNextFocusableWidget()
    {
        return null;
    }
    
    WidgetI getPrevFocusableWidget()
    {
        return null;
    }
    
    static foreach(v; ["Keyboard", "Mouse", "TextInput"])
    {
    	mixin(mixin_event_handler_reg(v));
    }
    
    void exceptionIfParentNotSet()
    {
    	if (isUnsetParent())
    	{
    		throw new Exception("parent not set");
    	}
    	if (getParent() is null)
    	{
    		throw new Exception("parent not set: null");
    	}
    }
    
    static foreach (v; ["X", "Y", "Width", "Height"])
    {
    	import std.format;
    	mixin(
    		q{
    			ulong get%1$s()
    			{
    				exceptionIfParentNotSet();
    				return getParent().getChild%1$s(this);
    			}
    			
    			typeof(this) set%1$s(ulong v)
    			{
    				exceptionIfParentNotSet();
    				getParent().setChild%1$s(this, v);
    				return this;
    			}
    			
    		}.format(v)
    		);
    }
    
    void propagatePosAndSizeRecalc()
    {
    }
}
