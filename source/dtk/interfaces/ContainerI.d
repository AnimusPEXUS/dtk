module dtk.interfaces.ContainerI;

//import dtk.interfaces.ContainerableI;
import dtk.interfaces.WidgetI;
import dtk.interfaces.DrawingSurfaceI;

/* interface ContainerI
{
    /* void addChild(ContainerableI item); /
    size_t getChildrenCount();
    ContainerableI getChildByIndex(size_t index);
    void deleteChild(size_t index);
    void swapChildren(size_t index0, size_t index1);

    void insertChild(size_t index, ContainerableI item);
    void insertChild(ContainerableI after_this, ContainerableI item);
    void putChildToStart(ContainerableI item);
    void putChildToEnd(ContainerableI item);
    /* ContainerableI popChildFromStart();
    ContainerableI popChildFromEnd(); /
} */

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
	
	ContainerI getParent();
	
	DrawingSurfaceI getDrawingSurface();
}
