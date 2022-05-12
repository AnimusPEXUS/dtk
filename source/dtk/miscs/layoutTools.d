module dtk.miscs.layoutTools;

import std.format;

import dtk.types.Widget;
// import dtk.interfaces.WidgetI;

// Button

void alignParentChild(
	float valign,
	float halign,
	Widget parent,
	Widget child
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
	if (!parent.haveChild(child))
	{
		throw new Exception("child not the Parent's child");
	}
	
	auto w = parent.getWidth();
	auto h = parent.getHeight();
	
	auto cw = child.getWidth();		 
	auto ch = child.getHeight();
	
	child.setX(cast(int)((w - cw)*halign));
	child.setY(cast(int)((h - ch)*valign));		
	
	return;
}

