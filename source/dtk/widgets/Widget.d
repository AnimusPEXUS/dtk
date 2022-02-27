module dtk.widgets.Widget;

import core.sync.mutex;

import std.stdio;
import std.conv;
import std.typecons;

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
import dtk.types.Image;

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
    	auto p = getParent();
    	if (p is null)
    		throw new Exception("parent is null");
    	auto ds = p.getDrawingSurface();
    	if (ds is null)
    		throw new Exception("parent drawing surface is null");
    	auto dsc = p.shiftDrawingSurfaceForChild(ds, this);
    	if (dsc is null)
    		throw new Exception("parent drawing surface for child is null");
    	return dsc;
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
    
    Tuple!(WidgetI, Position2D) getChildAtPosition(Position2D point)
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
    	// static assert(false, "must be reimplemented");
        throw new Exception("must be reimplemented");
    }
    
    Image propagateRedraw()
    {
    	// static assert(false, "must be reimplemented");
    	throw new Exception("must be reimplemented");
    }
    
    void redraw()
    {
    	// static assert(false, "must be reimplemented");
        throw new Exception("must be reimplemented");
    }
    
    Image renderImage(ulong x, ulong y, ulong w, ulong h)
    {
    	// static assert(false, "must be reimplemented");
    	throw new Exception("must be reimplemented");
    }
    
    Image renderImage()
    {
    	// static assert(false, "must be reimplemented");
    	throw new Exception("must be reimplemented");
    }
    
    void drawChild(WidgetI child, Image img)
    {
    	// static assert(false, "must be reimplemented");
    	throw new Exception("must be reimplemented");
    }
    
    void drawChild(DrawingSurfaceI ds, WidgetI child, Image img)
    {
    	// static assert(false, "must be reimplemented");
    	throw new Exception("must be reimplemented");
    }
    
}
