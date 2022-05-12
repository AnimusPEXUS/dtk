module dtk.miscs.layoutCollection;

import std.format;

import dtk.types.Orientation;
import dtk.types.Widget;

// TODO: add alignment?
void linearLayout(Widget w, Orientation o)
{
	auto wWidth = w.getWidth();
	auto wHeight = w.getHeight();
	Widget c;
	int currentOffset = 0;
	if (o == Orientation.horizontal)
	{
		for (int i = 0 ; i != w.getChildCount(); i++)
		{
			c = w.getChild(i);
			c.setX(currentOffset);
			c.setY(0);
			c.setHeight(wHeight);
			currentOffset += c.getWidth();
		}
	}
	else
	{
		for (int i = 0 ; i != w.getChildCount(); i++)
		{
			c = w.getChild(i);
			c.setX(0);
			c.setY(currentOffset);
			currentOffset += c.getHeight();
			c.setWidth(wWidth);
		}
	}		
}