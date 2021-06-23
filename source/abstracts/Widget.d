// Traditional toolkit class

module dtk.abstracts.Widget;

class Widget
{
    private
    {
        Widget _parent;

        uint _minimal_width;
        uint _minimal_height;

        uint _maximal_width;
        uint _maximal_height;

        void delegate() _onevent;
        void delegate() _onclick;
        void delegate() _ondblclick;
        void delegate() _onmousemove;
        void delegate() _onmouseenter;
        void delegate() _onmouseleave;
        void delegate() _onkeypress;
    }
}
