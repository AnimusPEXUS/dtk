module dtk.widgets.Widget;

import core.sync.mutex;

import std.stdio;
import std.conv;
import std.typecons;
import std.format;

// import dtk.interfaces.FormI;
import dtk.interfaces.WidgetI;
import dtk.interfaces.DrawingSurfaceI;
// import dtk.interfaces.LayoutI;
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
import dtk.miscs.recursionGuard;
// import dtk.miscs.mixin_event_handler_reg;

/* import dtk.widgets.WidgetLocator; */
// import dtk.widgets;
/* import dtk.widgets.WidgetDrawingSurface; */

import dtk.widgets.Form;
import dtk.widgets.Layout;

const auto WidgetProperties = cast(PropSetting[]) [
PropSetting("gsun", "ContainerI", "parent_container", "Parent", "null"),
];

class Widget : WidgetI
{
	
	mixin mixin_multiple_properties_define!(WidgetProperties);
    mixin mixin_multiple_properties_forward!(WidgetProperties, false);
    
    private
    {
    	bool form_recursion_protection_bool;
    	Mutex form_recursion_protection_mutex;
    }
    
    this() {
    	mixin(mixin_multiple_properties_inst(WidgetProperties));
    	form_recursion_protection_mutex = new Mutex();
    }
    
    Form getForm()
    {
    	debug writeln("getForm() called at ", this);
    	auto ret = recursionGuard(
    		form_recursion_protection_bool,
    		form_recursion_protection_mutex,
    		delegate Form()
    		{
    			throw new Exception("parent-children circul detected: this is wrong");
    		},
    		delegate Form()
    		{
    			ContainerI p = this.getParent();
    			Form res;
    			
    			while (true)
    			{
    				debug writeln("p == ", p);
    				if (p is null)
    				{
    					return null;
    				}
    				
    				res = cast(Form) p;
    				if (res !is null)
    				{
    					return res;
    				}
    				
    				p = p.getParent();
    				debug writeln("(2) p == ", p);
    			}
    		}
    		);
        return ret;
    }

    DrawingSurfaceI getDrawingSurface()
    {
        auto x = getX();
        auto y = getY();
        return new DrawingSurfaceShift(
        	getParent().getDrawingSurface(), 
        	cast(int)x, cast(int)y
        	);
    }
    
    void redraw()
    {
        throw new Exception("this function must be overriden");
    }
    
    // void redraw_x(T)(T new_this)
    // {
    	// 
        // /* alias A1 = typeof(new_this); */
        // 
        // const id = __traits(identifier, new_this);
        // const id_t = __traits(identifier, T);
        // 
        // static if (!is(T == Widget))
        // {
            // const drawid = "draw" ~ id_t;
            // 
            // FormI form = new_this.getForm();
            // if (form is null)
            // {
                // throw new Exception("error: redraw() function couldn't get Form");
            // }
            // 
            // auto theme = form.getLaf();
            // 
            // if (theme is null)
            // {
                // throw new Exception("theme not set");
            // }
            // 
            // static if (!__traits(hasMember, theme, drawid))
            // {
                // return;
            // }
            // else
            // {
                // __traits(getMember, theme, drawid)(new_this);
            // }
        // }
    // }
    
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
    
    // static foreach(v; ["Keyboard", "Mouse", "TextInput"])
    // {
    	// mixin(mixin_event_handler_reg(v));
    // }
    
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
