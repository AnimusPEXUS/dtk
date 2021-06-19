// Traditional toolkit class

module dtk.widgets.Widget;

class Widget
{
    private
    {
        Widget _parent;

        void delegate() _onevent;
        void delegate() _onclick;
        void delegate() _ondblclick;
        void delegate() _onmousemove;
        void delegate() _onmouseenter;
        void delegate() _onmouseleave;
        void delegate() _onkeypress;
    }
}
