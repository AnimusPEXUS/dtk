import std.csv;
import std.typecons;

const HEADER_TEXT = "/*
    This file generated using one of the generators inside
    KeyboardSourcesGenerator directory.

    Do not directly edit this file. Make changes to KeyboardSourcesGenerator
    contents, regenerate this file and replace it.
*/
";

mixin template makecsvreader()
{
    auto reader = csvReader!(Tuple!(string, string, string, string, string))(keyinfo_csv);
}

/* alias makecsvreader = csvReader!(Tuple!(string, string, string, string, string)); */

enum TableColumns
{
    COLUMN_BUTTONS,
    COLUMN_MOD_BITS,
    COLUMN_DESCRIPTION,
    COLUMN_SDL_KEYCODE,
    COLUMN_SDL_KEYMOD,
}
