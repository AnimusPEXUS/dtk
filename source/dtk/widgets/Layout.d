module dtk.widgets.Layout;

import core.sync.mutex;

import std.format;
import std.conv;
import std.stdio;
import std.container;
import std.algorithm;
import std.typecons;
import std.array;
import std.exception;

// import dtk.interfaces.ContainerI;
// import dtk.interfaces.Widget;
import dtk.interfaces.DrawingSurfaceI;
// import dtk.interfaces.LayoutChildSettingsI;

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


const auto LayoutProperties = cast(PropSetting[]) [
PropSetting("gs_w_d", "int", "viewportposX", "ViewPortPosX", "0"),
PropSetting("gs_w_d", "int", "viewportposY", "ViewPortPosY", "0"),

PropSetting("gs_w_d", "int", "viewportX", "ViewPortX", "0"),
PropSetting("gs_w_d", "int", "viewportY", "ViewPortY", "0"),
PropSetting("gs_w_d", "int", "viewportWidth", "ViewPortWidth", "0"),
PropSetting("gs_w_d", "int", "viewportHeight", "ViewPortHeight", "0"),
];


class Layout : Widget
{
    mixin mixin_multiple_properties_define!(LayoutProperties);
    mixin mixin_multiple_properties_forward!(LayoutProperties, false);
    mixin mixin_Widget_renderImage!("Layout");
    
    private
    {
    	//WidgetChild scrollbarH;
    	//WidgetChild scrollbarV;
		WidgetChild[] children;
		VisibilityMap!(Widget) vm;
    }
    
    this()
    {
    	mixin(mixin_multiple_properties_inst(LayoutProperties));
    	vm = new VisibilityMap!(Widget)();
    }
    
	override WidgetChild[] calcWidgetChildrenArray()
    {
    	WidgetChild[] ret;
    	// if (this.scrollbarH)
    	// ret ~= this.scrollbarH;
    	// if (this.scrollbarV)
    	// ret ~= this.scrollbarV;
    	ret ~= children;
    	return ret;
    }
    
    public
    {
    	void delegate(Widget child) exceptionIfLayoutChildInvalid;
    }
    
    int getLayoutChildCount()
    {
    	return cast(int) children.length;
    }
    
    bool haveLayoutChild(Widget child)
    {
    	foreach (c; children)
    	{
    		if (c.child == child)
    		{
    			return true;
    		}
    	}
    	return false;
    }
    
    Widget getLayoutChild(int i)
    {
    	if (children.length == 0)
    		return null;
    	if (!(i >= 0 && i < children.length))
    		return null;
    	return children[i].child;
    }
    
    Layout addLayoutChild(Widget child)
    {
    	if (exceptionIfLayoutChildInvalid !is null)
    	{
    		exceptionIfLayoutChildInvalid(child);
    	}
    	// if (childMaxCount != -1 && children.length == childMaxCount)
    	// {
    	// throw new Exception("maximum children count reached");
    	// }
    	if (!haveChild(child))
    	{
    		children ~= new WidgetChild(this, child);
    		fixChildParent(child);
    	}
    	return this;
    }
    
    Layout removeLayoutChild(Widget child)
    {
    	// if (children.length == childMinCount)
    	// {
    	// throw new Exception("minimum children count reached");
    	// }
    	if (!haveLayoutChild(child))
    		return this;
    	
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
    	return this;
    }
    
    Layout removeAllLayoutChildren()
    {
    	auto children_copy = children;
    	foreach(v; children_copy)
    	{
    		if (v.child !is null)
    		{
    			removeLayoutChild(v.child);
    		}
    	}
    	return this;
    }
    
	void fixLayoutChildrenParents()
    {
    	foreach_reverse (i, v; children)
    	{
    		// TODO: maybe it's better to throw exception, instead of
    		//       trying to guess fix
    		if (v.child is null)
    		{
    			children = children[0 .. i] ~ children[i+1 .. $];
    			continue;
    		}
    	}
    	
    	foreach (v; children)
    	{
    		fixChildParent(v.child);
    	}
    }
    
    override void propagatePosAndSizeRecalc()
    {
    	auto w = getWidth();
    	auto h = getHeight();
    	
    	setViewPortWidth(w);
    	setViewPortHeight(h);
    	
    	super.propagatePosAndSizeRecalc();
    	
    	recalcChildrenVisibilityMap();
    }
    
    // override void propagatePosAndSizeRecalcAfter()
    // {
    // recalcChildrenVisibilityMap();
    // };
    
    void recalcChildrenVisibilityMap()
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
    
    override Image propagateRedraw()
    {
    	auto img = super.propagateRedraw();
    	
    	foreach (c; calcWidgetChildrenArray())
    	{
    		auto cc = c.child;
    		assert(cc !is null);
    		
    		// NOTE: the loop is stopped with first viewport child
    		if (haveLayoutChild(cc))
    			break;
    		
    		auto c_img = cc.propagateRedraw();
    		this.drawChild(img, cc, c_img);
    	}
    	
    	foreach (c; vm.map)
    	{
    		auto co = c.o;
    		assert(co !is null);
    		auto c_img = co.propagateRedraw();
    		this.drawLayoutChild(img, co, c_img);
    	}
    	
    	return img;
    }
    
    override Tuple!(Widget, Position2D) getChildAtPosition(Position2D point)
    {
    	auto px = point.x;
		auto py = point.y;
		
    	auto vpx = getViewPortPosX();
    	auto vpy = getViewPortPosY();
    	auto vx = getViewPortX();
    	auto vy = getViewPortY();
    	auto vw = getViewPortWidth();
    	auto vh = getViewPortHeight();
    	
    	debug writeln("pointer in viewport?");
    	if (
    		px >= vpx
    	&& px < vpx+vw
    	
    	&& py >= vpy
    	&& py < vpy+vh
    	)
    	{
    		debug writeln("   yes");
    		auto vp_pos = Position2D((px - vpx + vx), (py - vpy + vy));
    		auto res = vm.getByPoint(vp_pos, true);
    		if (res.length != 0)
    		{
    			auto viewport_child = res[$-1];
    			debug writeln("viewport_child: ", viewport_child);
    			auto viewport_child_visibility = viewport_child[0];
    			auto viewport_child_visibility_object = viewport_child_visibility.o;
    			assert(viewport_child_visibility_object !is null);
    			Position2D op = viewport_child[1];
    			debug writeln(
    				"      viewport child %s: try to get object under %sx%s".format(
    					viewport_child_visibility_object,
    					op.x,
    					op.y
    					)
    				);
    			return viewport_child_visibility_object.getChildAtPosition(op);
    		}
    		else
    		{
    			debug writeln("   no objects under cursor");
    			return tuple(cast(Widget)this, point);
    		}
    	}
    	else
    	{
    		debug writeln("   no");
    		return super.getChildAtPosition(point);
    	}
    }
    
    DrawingSurfaceI shiftDrawingSurfaceForLayoutChild(
		DrawingSurfaceI ds,
		Widget child
		)
    {
    	if (!haveLayoutChild(child))
    		throw new Exception("not a layout child");
    	
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
    
    void drawLayoutChild(DrawingSurfaceI ds, Widget child, Image img)
    {
    	if (!haveLayoutChild(child))
    		throw new Exception("not a layout child");
    	
    	ds = shiftDrawingSurfaceForLayoutChild(ds, child);
    	
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
    	
    	ds.drawImage(
    		// NOTE: ds should be already shifted to correct position
    		Position2D(0, 0),
    		img.getImage(res[1], res[2], res[3], res[4])
    		);
    }
    
    deprecated
    {
    	static foreach(v;["X", "Y", "Width", "Height"])
    	{
    		mixin(
    			q{
    				int getLayoutChild%1$s(Widget child)
    				{
    					throw new Exception(
    						"this function should not be used or implemented"
    						);
    				}
    				
    				void setLayoutChild%1$s(Widget child, int v)
    				{
    					throw new Exception(
    						"this function should not be used or implemented"
    						);
    				}
    			}.format(v)
    			);
    	}
    }
    
}