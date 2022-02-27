module dtk.types.EnumWindowEvent;

enum EnumWindowEvent
{
    none,
    invalid, // reserved value for possible indication of error
    close,
    move,
    sizeChanged,
    resize,
    maximize,
    unmaximize,
    minimize,
    unminimize,
    restore,
    show,
    hide,
    expose,
    keyboardFocus,
    keyboardUnFocus,
    mouseFocus,
    mouseUnFocus,
    focus,
    unFocus,
    focusProposed,
}
