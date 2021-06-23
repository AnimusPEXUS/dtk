// MenuItem should be used as a placeholder for other widgets.
// Usual MenuItem is used with Label child and looks like usual menu item with
// text (and all it's common things, like hotkey textual representation)
module dtk.widgets.MenuItem;

import dtk.interfaces.ContainerableI;

class MenuItem : ContainerableI
{
    private
    {
        ContainerableI _contained;
    }
}
