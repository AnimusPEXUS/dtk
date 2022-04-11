module dtk.widgets.Layout;

import core.sync.mutex;
import std.conv;
import std.stdio;
import std.container;
import std.algorithm;
import std.typecons;
import std.array;
import std.exception;

//import dtk.interfaces.ContainerI;
// import dtk.interfaces.Widget;
import dtk.interfaces.DrawingSurfaceI;
import dtk.interfaces.LayoutEngineI;
import dtk.interfaces.LayoutChildSettingsI;

import dtk.types.Position2D;
import dtk.types.Size2D;
import dtk.types.Property;
import dtk.types.Image;
import dtk.types.VisibilityMap;
import dtk.types.Event;
import dtk.types.Widget;

import dtk.widgets.Form;
import dtk.widgets.mixins;

import dtk.miscs.signal_tools;
import dtk.miscs.calculateVisiblePart;
import dtk.miscs.DrawingSurfaceShift;

enum LayoutOverflowBehavior
{
    Ignore, // do nothing
    Scroll, // show scrollbar
    Clip, // don't draw overflow areas
    Resize, // resize self to fit everything
}

enum LayoutType : ubyte
{
    undefined,
    linearScrolled,
    linearWrapped,
}

const auto LayoutChildProperties = cast(PropSetting[]) [
// X, Y, Width and Height is for storring real effective values
// users should not change those unless Layout is set to use
// free positioning for widgets.
PropSetting("gs_w_d", "int", "x", "X", "0"),
PropSetting("gs_w_d", "int", "y", "Y", "0"),
PropSetting("gs_w_d", "int", "width", "Width", "0"),
PropSetting("gs_w_d", "int", "height", "Height", "0"),

// Each Layout Engine have it's own set of parameters for each child,
// so LayoutChild somehow have to store settings for any engine child.
// here's how it does this.
PropSetting("gsun", "LayoutChildSettingsI", "settings", "Settings", "null"),
];


class LayoutChild
{
	Widget child;
	
    mixin mixin_multiple_properties_define!(LayoutChildProperties);
    mixin mixin_multiple_properties_forward!(LayoutChildProperties, false);
    this(Widget widget) {
    	mixin(mixin_multiple_properties_inst(LayoutChildProperties));
    	this.child = widget;
    }
}


const auto LayoutProperties = cast(PropSetting[]) [
];

/++

new layouts can be implimented by inheriting Layout and overriding functions
such as positionAndSizeRequest() and redraw().

NOTE: Layout should not do any changes to any positions and sizes of it's
own children.

+/
class Layout : Element //, LayoutI
{
	
    // children field is public and is a normal array. you can use it to
    // add, remove or rearrange layout's children. checkChildren() method is
    // needed to be called after you've done what you wanted with children
    // array.
    LayoutChild[] children;
    VisibilityMap!(Widget) vm;
    
    mixin mixin_multiple_properties_define!(LayoutProperties);
    mixin mixin_multiple_properties_forward!(LayoutProperties, false);
    mixin mixin_multiple_properties_forward!(WidgetProperties, true);
    mixin mixin_forwardXYWH_from_Widget!();
    mixin mixin_Widget_renderImage!("Layout");
    mixin mixin_widget_redraw_using_propagateRedraw!();
    
    mixin mixin_propagateParentChangeEmission!();
    
    private {
    	SignalConnection sc_parentChange;
    }
    
    
    this()
    {
    	this([]);
    }
    
    this(LayoutChild[] children)
    {
    	mixin(mixin_multiple_properties_inst(LayoutProperties));
    	
    	// mixin(mixin_propagateParentChangeEmission_this());
    	
    	this.children = children;
    	
    	vm = new VisibilityMap!(Widget)();
    	
    	sc_parentChange = connectToParent_onAfterChanged(
    		delegate void(
    			ContainerI o,
    			ContainerI n,
    			)
    		{
    			collectException(writeln("Layout parent change form ", o, " to ", n));
    		}
    		);
    }
    
    override Form getForm()
    {
    	return super.getForm();
    }
    
    override Widget getNextFocusableWidget()
    {
    	return super.getNextFocusableWidget();
    }
    
    override Widget getPrevFocusableWidget()
    {
    	return super.getPrevFocusableWidget();
    }
    
    void checkChildren()
    {
    	foreach_reverse (i, v; children)
    	{
    		if (v.child is null)
    		{
    			children = children[0 .. i] ~ children[i+1 .. $];
    			continue;
    		}
    		
    		if (v.child.getParent() != this)
    		{
    			v.child.setParent(this);
    		}
    	}
    }
    
    LayoutChild getLayoutChildByChild(Widget child)
    {
    	foreach (v; children)
    	{
    		if (v.child == child)
    		{
    			return v;
    		}
    	}
    	return null;
    }
    
    override Tuple!(Widget, Position2D) getChildAtPosition(Position2D point)
    {
    	Widget c;
    	Position2D cp;
    	{
    		auto res = vm.getByPoint(point, false);
    		if (res.length == 0)
    			return tuple(cast(Widget)this, point);
    		auto x = res[$-1];
    		c = x[0].o;
    		cp = x[1];
    		assert(c !is null);
    	}
    	
    	return c.getChildAtPosition(cp);
    }
    
    static foreach(v;["X", "Y", "Width", "Height"])
    {
    	import std.format;
    	mixin(
    		q{
    			override int getChild%1$s(Widget child)
    			{
    				auto c = getLayoutChildByChild(child);
    				if (c is null)
    				{
    					writeln(child, " is not a layout child");
    					// TODO: is this good place for exception
    					throw new Exception("object is not in layout");
    				}
    				return c.get%1$s();
    			}
    			
    			override void setChild%1$s(Widget child, int v)
    			{
    				auto c = getLayoutChildByChild(child);
    				if (c is null)
    				{
    					writeln(child, " is not a layout child");
    					// TODO: is this good place for exception
    					throw new Exception("object is not in layout");
    				}
    				c.set%1$s(v);
    				return;
    			}
    		}.format(v)
    		);
    }

    int getChildMinCount()
    {
    	return 0;
    }
    
    int getChildMaxCount()
    {
    	return -1;
    }
    
    int getChildCount()
    {
    	return children.length;
    }
    
    Widget getChild()
    {
    	if (children.length == 0)
    	{
    		return null;
    	}
    	else
    	{
    		return children[0];
    	}
    }
    
    Widget getChild(int i)
    {
    	if (children.length == 0)
    		return null;
    	if (!(i >= 0 && i < children.length))
    		return null;
    	return children[i];
    }
    
    void addChild(Widget child)
    {
    	if (!haveChild(child))
    	{
    		children ~= new LayoutChild(child);
    		if (child.getParent() != this)
    		{
    			child.setParent(this);
    		}
    	}
    }
    
    void removeChild(Widget child)
    {
    	if (!haveChild(child))
    		return;
    	
    	Widget[] removed;
    	
    	foreach_reverse (i, v; children)
    	{
    		if (v.child == child)
    		{
    			removed~=v.child;
    			children = children[0 .. i] ~ children[i+1 .. $];
    		}
    	}
    	
    	foreach(v;removed)
    	{
    		v.unsetParent();
    	}
    }
    
    bool haveChild(Widget child)
    {
    	foreach(v;children)
    	{
    		if (v.child == child)
    			return true;
    	}
    	return false;
    }
    
    override DrawingSurfaceI getDrawingSurface()
    {
    	return super.getDrawingSurface();
    }
    
    DrawingSurfaceI shiftDrawingSurfaceForChild(
		DrawingSurfaceI ds,
		Widget child
		)
    {
    	if (!haveChild(child))
    		throw new Exception("not a child");
    	
        auto vp_x = getViewPortX();
    	auto vp_y = getViewPortY();
    	auto vp_w = getViewPortWidth();
    	auto vp_h = getViewPortHeight();
    	
    	auto cx = getChildX(child);
    	auto cy = getChildY(child);
    	auto cw = getChildWidth(child);
    	auto ch = getChildHeight(child);
    	
    	auto res = calculateVisiblePart(
    		vp_x,
    		vp_y,
    		vp_w,
    		vp_h,
    		cx,
    		cy,
    		cw,
    		ch
    		);
    	
        auto ret = new DrawingSurfaceShift(
        	ds,
        	cast(int)res[5],
        	cast(int)res[6]
        	);
        
        return ret;
    }
    
    override void propagatePosAndSizeRecalc()
    {
    	auto w = getWidth();
    	auto h = getHeight();
    	
    	setViewPortWidth(w);
    	setViewPortHeight(h);
    	
    	auto la = getLayoutEngine();
    	
    	if (la !is null)
    		la.performLayout();
    	
    	foreach (v; children)
        {
        	v.child.propagatePosAndSizeRecalc();
        }
        
        recalcVisibilityMap();
    }
    
    override Image propagateRedraw()
    {
    	auto img = this.renderImage();
    	// auto ds = getDrawingSurface();
    	// ds.drawImage(Position2D(0,0),img);
    	
    	foreach (c; vm.map)
    	{
    		assert(c.o !is null);
    		auto c_img = c.o.propagateRedraw();
    		this.drawChild(img, c.o, c_img);
    	}
    	return img;
    }
    
    void recalcVisibilityMap()
    {
    	vm.init(
    		getViewPortX(),
    		getViewPortY(),
    		getViewPortWidth(),
    		getViewPortHeight()
    		);
    	
    	bool started;
    	foreach (v; children)
    	{
    		auto res = vm.put(
    			v.getX(),
    			v.getY(),
    			v.getWidth(),
    			v.getHeight(),
    			v.child
    			);
    		if (!started && res)
    			started=true;
    		if (started && !res)
    			break;
    	}
    	
    	return;
    }
    
    override void drawChild(Widget child, Image img)
    {
    	auto ds = getDrawingSurface();
    	drawChild(ds, child, img);
    	return;
    }
    
    override void drawChild(DrawingSurfaceI ds, Widget child, Image img)
    {
    	ds = shiftDrawingSurfaceForChild(ds, child);
    	
    	auto vp_x = getViewPortX();
    	auto vp_y = getViewPortY();
    	auto vp_w = getViewPortWidth();
    	auto vp_h = getViewPortHeight();
    	
    	auto cx = getChildX(child);
    	auto cy = getChildY(child);
    	auto cw = getChildWidth(child);
    	auto ch = getChildHeight(child);
    	
    	auto res = calculateVisiblePart(
    		vp_x,
    		vp_y,
    		vp_w,
    		vp_h,
    		cx,
    		cy,
    		cw,
    		ch
    		);
    	if (!res[0])
    		return;
    	
    	// auto img = child.renderImage(cast(int)res[1], res[2], res[3], res[4]);
    	ds.drawImage(
    		Position2D(
    			0, 0
    			// NOTE: ds should be already shifted to correct position
    			// cast(int)res[5], cast(int)res[6]
    			),
    		img.getImage(res[1], res[2], res[3], res[4])
    		);
    }
    
    override void focusEnter(Form form, Widget widget)
    {}
    override void focusExit(Form form, Widget widget)
    {}
    
    override bool isVisuallyPressed()
    {return false;}
    override void visualPress(Form form, Widget widget, EventForm* event)
    {}
    override void visualRelease(Form form, Widget widget, EventForm* event)
    {}
    
    override void intMousePress(Form form, Widget widget, EventForm* event)
    {}
    override void intMouseRelease(Form form, Widget widget, EventForm* event)
    {}
    override void intMousePressRelease(Form form, Widget widget, EventForm* event)
    {}
    override void intMouseLeave(Form form, Widget old_w, Widget new_w, EventForm* event)
    {}
    override void intMouseEnter(Form form, Widget old_w, Widget new_w, EventForm* event)
    {}
    override void intMouseMove(Form form, Widget widget, EventForm* event)
    {}
    
    
    override void intKeyboardPress(Form form, Widget widget, EventForm* event) {}
    override void intKeyboardRelease(Form form, Widget widget, EventForm* event) {}
    
    override void intTextInput(Form form, Widget widget, EventForm* event) {}
    
}
