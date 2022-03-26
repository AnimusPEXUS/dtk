module dtk.widgets.mixins;

import std.stdio;

mixin template mixin_forwardXYWH_from_Widget()
{
	static foreach (v; ["X", "Y", "Width", "Height"])
    {
    	import std.format;
    	mixin(
    		q{
    			override int get%1$s()
    			{
    				return super.get%1$s();
    			}
    			
    			override typeof(this) set%1$s(int v)
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

mixin template mixin_widget_redraw_using_propagateRedraw()
{
	override void redraw()
    {
		auto img = propagateRedraw();
		auto ds = getDrawingSurface();
		ds.drawImage(Position2D(0,0), img);
		ds.present();
    }
}


/* mixin template mixin_widget_redraw_using_parent()
{
override void redraw()
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
} */

mixin template mixin_Widget_renderImage(
	string widgetType,
	string override_str="override"
	)
{
	import std.stdio;
	import std.format;
	
	import dtk.types.Image;
	import dtk.widgets.Form;
	
	mixin(
		q{
			%2$s Image renderImage()
			{
				debug writeln(this, ".renderImage() called");
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
			
			%2$s Image renderImage(int x, int y, int w, int h)
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


mixin template mixin_propagateRedraw_children_none(string override_str="override")
{
	import std.format;
	mixin(
		q{
			%1$s Image propagateRedraw()
			{
				auto img = this.renderImage();
				return img;
			}
    	}.format(override_str)
    	);
}

mixin template mixin_propagateRedraw_children_one(string override_str="override")
{
	import std.format;
	mixin(
		q{
			%1$s void propagateRedraw()
			{
				auto img = this.renderImage();
				
				auto c = getChild();
				if (c !is null)
				{
					auto c_img = c.propagateRedraw();
					this.drawChild(img, c, c_img);
				}
			}
		}.format(override_str)
		);
}


/* string mixin_propagateParentChangeEmision_this()
{
return q{
import core.sync.mutex;
propagateParentChangeEmision_recursion_protection_mtx = new Mutex();
};
} */

mixin template mixin_propagateParentChangeEmision()
{
	private
    {
		import core.sync.mutex;
    	bool propagateParentChangeEmision_recursion_protection;
    	Mutex propagateParentChangeEmision_recursion_protection_mtx;
    }
    
    override void propagateParentChangeEmision()
    {
    	import dtk.miscs.recursionGuard;
    	import core.sync.mutex;
    	
    	synchronized
    	{
    		if (propagateParentChangeEmision_recursion_protection_mtx is null)
    			propagateParentChangeEmision_recursion_protection_mtx = new Mutex();
    		
    		recursionGuard(
    			propagateParentChangeEmision_recursion_protection,
    			propagateParentChangeEmision_recursion_protection_mtx,
    			0,
    			delegate int() {
    				import dtk.widgets.Form;
    				
    				static if (is(typeof(this) == Form))
    				{
    					pragma(msg, "propagateParentChangeEmision for Form");
    					setWindow(getWindow());
    				}
    				else
    				{
    					pragma(msg, "propagateParentChangeEmision for simple widget");
    					setParent(getParent());
    				}
    				
    				static if (__traits(hasMember, this, "children"))
    				{
    					foreach (c; children)
    					{
    						c.child.propagateParentChangeEmision();
    					}
    				}
    				else static if (__traits(hasMember, this, "getChild"))
    				{
    					auto c = getChild();
    					if (c !is null)
    						c.propagateParentChangeEmision();
    				}
    				return 0;
    			}
    			);
    	}
    }
}
