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

import dtk.types.Event;
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
    
    void propagateParentChangeEmision()
    {
    	throw new Exception("must be reimplemented");
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
    
    void focusEnter(WidgetI widget) {};
    void focusExit(WidgetI widget) {};
    
    void visualActivationStart(WidgetI widget, EventForm* event) {};
    void visualReset(WidgetI widget, EventForm* event) {};
    
    void intMousePress(WidgetI widget, EventForm* event) {};
    void intMouseRelease(WidgetI widget, EventForm* event) {};
    void intMouseLeave(WidgetI old_w, WidgetI new_w, EventForm* event) {};
    void intMouseEnter(WidgetI old_w, WidgetI new_w, EventForm* event) {};
    void intMouseMove(WidgetI widget, EventForm* event) {};
}
