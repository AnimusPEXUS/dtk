module dtk.interfaces.ContainerI;

import dtk.interfaces.ContainerableI;

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
	ulong getChildX(ContainerableI child);
	ulong getChildY(ContainerableI child);
	ulong getChildWidth(ContainerableI child);
	ulong getChildHeight(ContainerableI child);
	void setChildX(ContainerableI child, ulong v);
	void setChildY(ContainerableI child, ulong v);
	void setChildWidth(ContainerableI child, ulong v);
	void setChildHeight(ContainerableI child, ulong v);
}
