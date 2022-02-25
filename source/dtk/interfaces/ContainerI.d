module dtk.interfaces.ContainerI;

import std.typecons;

import dtk.types.Position2D;
import dtk.types.Image;

import dtk.interfaces.WidgetI;
import dtk.interfaces.DrawingSurfaceI;

interface ContainerI
{
	Tuple!(WidgetI, Position2D) getChildAtPosition(Position2D point);

	ulong getChildX(WidgetI child);
	ulong getChildY(WidgetI child);
	ulong getChildWidth(WidgetI child);
	ulong getChildHeight(WidgetI child);
	void setChildX(WidgetI child, ulong v);
	void setChildY(WidgetI child, ulong v);
	void setChildWidth(WidgetI child, ulong v);
	void setChildHeight(WidgetI child, ulong v);
	
	void addChild(WidgetI child);
	void removeChild(WidgetI child);
	bool haveChild(WidgetI child);
	
	void drawChild(WidgetI child, Image img);
	
	ContainerI getParent();
	
	DrawingSurfaceI getDrawingSurface();
}
