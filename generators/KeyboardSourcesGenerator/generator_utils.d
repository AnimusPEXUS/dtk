module generator_utils;

import std.algorithm;
import std.csv;
import std.typecons;

const END_GENERATION_MARKER = "++++++ (generation ends here) ++++++";

const HEADER_TEXT = `/*
    This file generated using one of the generators inside
    KeyboardSourcesGenerator directory.

    Do not directly edit this file. Make changes to KeyboardSourcesGenerator
    contents, regenerate this file and replace it.
*/
`;

alias csvTableType = Tuple!(string, string, string, string, string, string, string);
alias csvTableTypeReader = csvReader!(csvTableType, Malformed.throwException, string);

auto makecsvreader(string keyinfo_csv)
{
    // TODO: this have to be smarter
    auto reader = csvTableTypeReader(keyinfo_csv);
    // pragma(msg, "makecsvreader() type is ", typeof(reader));
    return reader;
}

enum TableColumns
{
    COLUMN_BUTTONS,
    COLUMN_MOD_BITS,
    COLUMN_DESCRIPTION,
    COLUMN_SDL_KEYCODE,
    COLUMN_SDL_KEYMOD,
    COLUMN_GLFW_KEYCODE,
    COLUMN_GLFW_KEYMOD,
}

bool skipRow(string cell_value)
{
    auto ss = cell_value.strip(' ').strip('\n').strip('\r');
    if (ss == "")
        return true;
    if (ss.canFind(' '))
        return true;
    return false;
}