module dtk.widgets.mixins;

import std.stdio;

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

mixin template mixin_widget_redraw_using_propagateRedraw()
{
	override void redraw()
    {
		propagateRedraw();
		getDrawingSurface().present();
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


mixin template mixin_propagateRedraw_children_none(string override_str="override")
{
	import std.format;
	mixin(
		q{
			%1$s void propagateRedraw()
			{
				auto img = this.renderImage();
				auto ds = getDrawingSurface();
				ds.drawImage(Position2D(0,0),img);
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
				auto ds = getDrawingSurface();
				ds.drawImage(Position2D(0,0), img);
				
				/* auto c = getChild();
				if (c !is null)
					c.propagateRedraw(); */
			}
		}.format(override_str)
		);
}
