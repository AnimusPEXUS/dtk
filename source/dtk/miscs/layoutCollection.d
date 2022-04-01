module dtk.miscs.layoutCollection;

import std.format;

import dtk.interfaces.WidgetI;
import dtk.interfaces.ContainerI;

// Button

void alignParentChild(
	float valign,
	float halign,
	ContainerI parent,
	WidgetI child
	)
in
{
	assert(valign >=0 && valign <=1);
	assert(halign >=0 && halign <=1);
	assert(parent !is null);
	assert(child !is null);
}
do
{
	if (parent.getChild() != child)
	{
		throw new Exception("child not the Parent's child");
	}
	
	auto w = (cast(WidgetI)parent).getWidth();
	auto h = (cast(WidgetI)parent).getHeight();
	
	auto cw = child.getWidth();		 
	auto ch = child.getHeight();
	
	child.setX(cast(int)((w - cw)*halign));
	child.setY(cast(int)((h - ch)*valign));		
	
	return;
}
