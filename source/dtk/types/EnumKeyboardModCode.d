module dtk.types.EnumKeyboardModCode;

/*
    This file generated using one of the generators inside
    KeyboardSourcesGenerator directory.

    Do not directly edit this file. Make changes to KeyboardSourcesGenerator
    contents, regenerate this file and replace it.
*/

enum EnumKeyboardModCode : ushort
{
None          =  0,
    LeftShift = 0b1,
    LeftControl = 0b10,
    LeftMenu = 0b100,
    LeftSuper = 0b1000,
    LeftAlt = 0b10000,
    LeftMode = 0b100000,
    RightShift = 0b1000000,
    RightControl = 0b10000000,
    RightMenu = 0b100000000,
    RightSuper = 0b1000000000,
    RightAlt = 0b10000000000,
    RightMode = 0b100000000000,
    CapsLock = 0b1000000000000,
    NumLock = 0b10000000000000,
    ScrollLock = 0b100000000000000,
};



    enum EnumKeyboardModCodeNOT : ushort
    {
        None          =  cast(EnumKeyboardModCodeNOT)~cast(uint)EnumKeyboardModCode.None,
        LeftShift     = cast(EnumKeyboardModCodeNOT)~cast(uint)EnumKeyboardModCode.LeftShift,
        LeftControl   = cast(EnumKeyboardModCodeNOT)~cast(uint)EnumKeyboardModCode.LeftControl,
        LeftMenu      = cast(EnumKeyboardModCodeNOT)~cast(uint)EnumKeyboardModCode.LeftMenu,
        LeftSuper     = cast(EnumKeyboardModCodeNOT)~cast(uint)EnumKeyboardModCode.LeftSuper,
        LeftAlt       = cast(EnumKeyboardModCodeNOT)~cast(uint)EnumKeyboardModCode.LeftAlt,
        LeftMode      = cast(EnumKeyboardModCodeNOT)~cast(uint)EnumKeyboardModCode.LeftMode,
        RightShift    = cast(EnumKeyboardModCodeNOT)~cast(uint)EnumKeyboardModCode.RightShift,
        RightControl  = cast(EnumKeyboardModCodeNOT)~cast(uint)EnumKeyboardModCode.RightControl,
        RightMenu     = cast(EnumKeyboardModCodeNOT)~cast(uint)EnumKeyboardModCode.RightMenu,
        RightSuper    = cast(EnumKeyboardModCodeNOT)~cast(uint)EnumKeyboardModCode.RightSuper,
        RightAlt      = cast(EnumKeyboardModCodeNOT)~cast(uint)EnumKeyboardModCode.RightAlt,
        RightMode     = cast(EnumKeyboardModCodeNOT)~cast(uint)EnumKeyboardModCode.RightMode,
        CapsLock      = cast(EnumKeyboardModCodeNOT)~cast(uint)EnumKeyboardModCode.CapsLock,
        NumLock       = cast(EnumKeyboardModCodeNOT)~cast(uint)EnumKeyboardModCode.NumLock,
        ScrollLock    = cast(EnumKeyboardModCodeNOT)~cast(uint)EnumKeyboardModCode.ScrollLock,
        Locks = ScrollLock & NumLock & CapsLock
    };

    
