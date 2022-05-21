module dtk.miscs.layoutCollection;

import std.stdio;
import std.format;

import dtk.types.Orientation;
import dtk.types.Widget;

import dtk.widgets.Layout;

// TODO: add alignment?
void linearLayout(Layout w, Orientation o)
{
	auto wWidth = w.getWidth();
	auto wHeight = w.getHeight();
	Widget c;
	int currentOffset = 0;
	for (int i = 0 ; i != w.getLayoutChildCount(); i++)
	{
		c = w.getLayoutChild(i);
		if (o == Orientation.horizontal)
		{
			c.setX(currentOffset);
			c.setY(0);
			c.setWidth(c.getDesiredWidth());
			c.setHeight(wHeight);
			currentOffset += c.getWidth();
		}
		else
		{
			c.setX(0);
			c.setY(currentOffset);
			c.setWidth(wWidth);
			c.setHeight(c.getDesiredHeight());
			currentOffset += c.getHeight();
		}
		debug writeln("linearLayout child %s aligned: %sx%s %sx%s".format(
			i,
			c.getX(),
			c.getY(),
			c.getWidth(),
			c.getHeight(),
			));
	}
}
