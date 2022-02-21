module dtk.widgets.mixins;

import std.stdio;

// import dtk.widgets;

/* mixin template mixin_getWidgetAtPosition()
{
import std.typecons;
import dtk.types.Position2D;

/// Note: x/y are local to widget the function is running at
override Tuple!(WidgetI, ulong, ulong) getChildAtPosition(Position2D point)
{
auto x = point.x;
auto y = point.y;

ulong local_x;
ulong local_y;
{
// auto pos = this.getPosition();
local_x=x;
local_y=y;
}

// if this have only single child - work with it
static if (__traits(hasMember, this, "getChild"))
{
auto isunset = this.isUnsetChild(); // __traits(getMember, this, "isUnsetChild")();
if (isunset)
{
return tuple(cast(WidgetI)this, local_x, local_y);
}

WidgetI c = this.getChild();
if (c is null)
{
return tuple(cast(WidgetI)this, local_x, local_y);
}

auto c_pos = c.getPosition();
auto c_size = c.getSize();

if (
x >= c_pos.x && x <= (c_pos.x + c_size.width) && y >= c_pos.y
&& y <= (c_pos.y + c_size.height))
{
return c.getChildAtPosition(Position2D(x - c_pos.x, y - c_pos.y));
}
}

// if this have many children - search the right one and work with it
static if (__traits(hasMember, this, "getChildren"))
{

auto children = this.getChildren();
if (children.length == 0)
{
return tuple(cast(WidgetI)this, local_x, local_y);
}

// TODO: optimize for visible part
foreach (c; children)
{
auto c_pos = c.getPosition();
auto c_size = c.getSize();

if (x >= c_pos.x && x <= (c_pos.x + c_size.width) && y >= c_pos.y
&& y <= (c_pos.y + c_size.height))
{
return c.getChildAtPosition(Position2D(x - c_pos.x, y - c_pos.y));
}
}

}

return tuple(cast(WidgetI)this, local_x, local_y);
}
}

*/

mixin template mixin_forwardXYWH_from_Widget()
{
	static foreach (v; ["X", "Y", "Width", "Height"])
    {
    	import std.format;
    	mixin(
    		q{
    			override ulong get%1$s()
    			{
    				return super.get%1$s();
    			}
    			
    			override typeof(this) set%1$s(ulong v)
    			{
    				super.set%1$s(v);
    				return this;
    			}
    			
    		}.format(v)
    		);
    }
}

string mixin_simple_parent_change_action()
{
	string ret = q{
		con_cont.add(
    		connectToParent_onAfterChanged(
    			delegate void(
    				ContainerI o,
    				ContainerI n
    				)
    			{
    				collectException(
    					{
    						if (o !is null && o.haveChild(this))
    						{
    							o.removeChild();
    						}
    						
    						if (n !is null && !n.haveChild(this))
    						{
    							n.addChild(this);
    						}
    					}()
    					);
    			}
    			)
    		);
    	
	};
	return ret;
}

string mixin_widget_redraw(string widgetType)
{
	import std.format;
	
	string ret = q{
		{
			Form form = this.getForm();
			if (form is null)
			{
				throw new Exception(this.toString() ~ ".redraw() requires Form to be set");
			}
			
			auto laf = form.getLaf();
			if (laf is null)
			{
				throw new Exception("Laf not set");
			}
			
			auto ds = getDrawingSurface();
			if (ds !is null)
			{
				laf.draw%1$s(this, ds);
			}
		}
	}.format(widgetType);
	return ret;
}


mixin template mixin_widget_redraw_using_parent()
{
	override void redraw(bool present=false)
	{
		auto p = getParent();
		if (p !is null)
		{
			p.redrawChild(this);
			if (present) 
			{
				auto ds = getDrawingSurface();
				if (ds !is null)
				{
					ds.present();
				}
			}
		}
	}
}

/* string mixin_Widget_renderImage(string widgetType)
{
import std.format;

string ret = q{
Form form = this.getForm();
if (form is null)
{
throw new Exception(this.toString() ~ ".redraw() requires Form to be set");
}

auto laf = form.getLaf();
if (laf is null)
{
throw new Exception("Laf not set");
}

laf.draw%1$s(this);
}.format(widgetType);
return ret;
} */

mixin template mixin_Widget_renderImage(
	string widgetType,
	string override_str="override"
	)
{
	import std.format;
	
	import dtk.types.Image;
	import dtk.widgets.Form;
	
	mixin(
		q{
			%2$s Image renderImage()
			{
				Form form = this.getForm();
				if (form is null)
				{
					throw new Exception(
						this.toString() ~ ".redraw() requires Form to be set"
						);
				}
				
				auto laf = form.getLaf();
				if (laf is null)
				{
					throw new Exception("Laf not set");
				}
				
				auto w = getWidth();
				auto h = getHeight();
				
				auto ds = new Image(w, h);
				
				static if (__traits(hasMember, this, "renderImageBeforeDraw"))
				{
					this.renderImageBeforeDraw(ds);
				}
				
				laf.draw%1$s(this, ds);
				
				static if (__traits(hasMember, this, "renderImageAfterDraw"))
				{
					this.renderImageAfterDraw(ds);
				}
				
				return ds;
			}
			
			%2$s Image renderImage(ulong x, ulong y, ulong w, ulong h)
			{
				return renderImage().getImage(x,y,w,h);
			}
			
		}.format(widgetType, override_str)
		);
}

mixin template mixin_forward_super_functions(string[] names)
{
	import std.format;
	import std.traits;
	import std.meta;
	
	static foreach (v; names)
	{
		mixin(
			q{
				override ReturnType!(super.%1$s) %1$s(AliasSeq!(Parameters!(super.%1$s)) args)
				{
					return super.%1$s(args);
				}
			}.format(v)
			);
	}
}
