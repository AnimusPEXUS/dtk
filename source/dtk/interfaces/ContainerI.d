module dtk.interfaces.ContainerI;

import std.typecons;

import dtk.types.Position2D;
import dtk.types.Image;

import dtk.interfaces.WidgetI;
import dtk.interfaces.DrawingSurfaceI;

interface ContainerI
{
	Tuple!(WidgetI, Position2D) getChildAtPosition(Position2D point);

	int getChildX(WidgetI child);
	int getChildY(WidgetI child);
	int getChildWidth(WidgetI child);
	int getChildHeight(WidgetI child);
	void setChildX(WidgetI child, int v);
	void setChildY(WidgetI child, int v);
	void setChildWidth(WidgetI child, int v);
	void setChildHeight(WidgetI child, int v);
	
	void addChild(WidgetI child);
	void removeChild(WidgetI child);
	bool haveChild(WidgetI child);
	
	void drawChild(WidgetI child, Image img);
	void drawChild(DrawingSurfaceI ds, WidgetI child, Image img);
	
	ContainerI getParent();
	
	DrawingSurfaceI getDrawingSurface();
	DrawingSurfaceI shiftDrawingSurfaceForChild(
		DrawingSurfaceI ds, 
		WidgetI child
		);
}
