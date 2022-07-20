#!/usr/bin/env rdmd

import std.algorithm;
import std.typecons;
import std.stdio;
import std.file;
import std.csv;
import std.format;

import generator_utils;


string generate_convertSDLKeycodeToEnumKeyboardKeyCode(string keyinfo_csv)
{
    string ret;
    string cases;

    {
        auto reader = makecsvreader(keyinfo_csv);

        loop: foreach (row; reader)
        {
            if (row[TableColumns.COLUMN_BUTTONS].strip(' ') == END_GENERATION_MARKER)
                break;

            if (skipRow(row[TableColumns.COLUMN_BUTTONS]))
                continue;

            if (skipRow(row[TableColumns.COLUMN_SDL_KEYCODE]))
                continue;

            foreach (subitem; row[TableColumns.COLUMN_SDL_KEYCODE].splitter(','))
            {
                cases ~=
                    q{
                    case SDL_Keycode.%1$s:
                        return tuple(EnumKeyboardKeyCode.%2$s, cast(Exception) null);
                }.format(
                    subitem,
                    row[TableColumns.COLUMN_BUTTONS],
            );
            }
        }
    }

    ret =
        q{
            Tuple!(EnumKeyboardKeyCode, Exception) convertSDLKeycodeToEnumKeyboardKeyCode(
                SDL_Keycode keycode
            )
            {
                switch (keycode)
                {
                    default:
                        return tuple(cast(EnumKeyboardKeyCode)0, new Exception("keycode not supported"));
            %s
                }
            }
        }.format(cases);

    return ret;
}

string generate_convertEnumKeyboardKeyCodeToSDLKeycode(string keyinfo_csv)
{
    string ret;
    string cases;

    {
        auto reader = makecsvreader(keyinfo_csv);

        loop: foreach (row; reader)
        {
            if (row[TableColumns.COLUMN_BUTTONS].strip(' ') == END_GENERATION_MARKER)
                break;

            if (skipRow(row[TableColumns.COLUMN_BUTTONS]))
                continue;

            if (skipRow(row[TableColumns.COLUMN_SDL_KEYCODE]))
                continue;

            cases ~=
                q{
                case EnumKeyboardKeyCode.%1$s:
                    return tuple(SDL_Keycode.%2$s, cast(Exception) null);
            }.format(
                row[TableColumns.COLUMN_BUTTONS],
                row[TableColumns.COLUMN_SDL_KEYCODE],
            );
        }
    }

    ret =
        q{
            Tuple!(SDL_Keycode, Exception) convertEnumKeyboardKeyCodeToSDLKeycode(
                EnumKeyboardKeyCode keycode
            )
            {
                switch (keycode)
                {
                    default:
                        return tuple(cast(SDL_Keycode)0, new Exception("keycode not supported"));
            %s
                }
            }
        }.format(cases);

    return ret;
}

string generate_convertSingleSDLKeymodToEnumKeyboardModCode(string keyinfo_csv)
{
    string ret;
    ret ~= (
            "Tuple!(EnumKeyboardModCode, Exception) convertSingleSDLKeymodToEnumKeyboardModCode(SDL_Keymod code)\n{\n");

    ret ~= ("    switch (code) {\n");
    ret ~= ("        default:\n");
    ret ~= (
            "            return tuple(cast(EnumKeyboardModCode)0, new Exception(\"could not decode supplied keycode: \"~ format(\"%s\", code)) );\n");

    auto reader = makecsvreader(keyinfo_csv);
    /* auto reader = makecsvreader(keyinfo_csv); */
    bool skipped = false;
    main_loop3: foreach (row; reader)
    {
        if (!skipped)
        {
            skipped = true;
            continue;
        }
        switch (row[TableColumns.COLUMN_BUTTONS])
        {
        default:
            break;
        case "":
            continue main_loop3;
        case END_GENERATION_MARKER:
            break main_loop3;
        }

        if (row[TableColumns.COLUMN_SDL_KEYMOD] == "")
        {
            continue;
        }

        ret ~= ("        case SDL_Keymod." ~ row[TableColumns.COLUMN_SDL_KEYMOD] ~ ":\n");
        ret ~= ("            return tuple(EnumKeyboardModCode."
                ~ row[TableColumns.COLUMN_BUTTONS] ~ ", cast(Exception)null);\n");
    }

    ret ~= ("    }\n");
    ret ~= ("}\n");
    ret ~= ("\n");

    return ret;
}

string generate_convertSingleEnumKeyboardModCodeToSDLKeymod(string keyinfo_csv)
{
    string ret;
    ret ~= (
            "Tuple!(SDL_Keymod, Exception) convertSingleEnumKeyboardModCodeToSDLKeymod(EnumKeyboardModCode code)\n{\n");

    ret ~= ("    switch (code) {\n");
    ret ~= ("        default:\n");
    ret ~= (
            "            return tuple(cast(SDL_Keymod)0, new Exception(\"could not decode supplied keycode: \"~ format(\"%s\", code)) );\n");

    auto reader = makecsvreader(keyinfo_csv);
    /* auto reader = makecsvreader(keyinfo_csv); */
    bool skipped = false;
    main_loop4: foreach (row; reader)
    {
        if (!skipped)
        {
            skipped = true;
            continue;
        }
        switch (row[TableColumns.COLUMN_SDL_KEYMOD])
        {
        default:
            break;
        case "":
            continue main_loop4;
        case END_GENERATION_MARKER:
            break main_loop4;
        }

        if (row[TableColumns.COLUMN_SDL_KEYCODE] == "")
        {
            continue;
        }

        ret ~= (
                "        case EnumKeyboardModCode." ~ row[TableColumns.COLUMN_BUTTONS] ~ ":\n");
        ret ~= (
                "            return tuple(SDL_Keymod."
                ~ row[TableColumns.COLUMN_SDL_KEYMOD] ~ ",cast(Exception)null);\n");
    }

    ret ~= ("    }\n");
    ret ~= ("}\n");
    ret ~= ("\n");
    return ret;
}

string generate_convertCombinationSDLKeymodToEnumKeyboardModCode(string keyinfo_csv)
{
    string ret;

    ret ~= ("Tuple!(EnumKeyboardModCode, Exception) convertCombinationSDLKeymodToEnumKeyboardModCode(SDL_Keymod code)\n{\n");

    ret ~= ("    EnumKeyboardModCode ret;\n");

    auto reader = makecsvreader(keyinfo_csv);
    /* auto reader = makecsvreader(keyinfo_csv); */
    bool skipped = false;
    main_loop5: foreach (row; reader)

    {
        if (!skipped)
        {
            skipped = true;
            continue;
        }
        switch (row[TableColumns.COLUMN_BUTTONS])
        {
        default:
            break;
        case "":
            continue main_loop5;
        case END_GENERATION_MARKER:
            break main_loop5;
        }

        if (row[TableColumns.COLUMN_SDL_KEYMOD] == "")
        {
            continue;
        }

        ret ~= (format("if ((code & SDL_Keymod.%s) != 0)\n",
                row[TableColumns.COLUMN_SDL_KEYMOD]));
        ret ~= ("{\n");
        ret ~= (format("    ret |= EnumKeyboardModCode.%s;\n",
                row[TableColumns.COLUMN_BUTTONS]));
        ret ~= ("}\n");

    }

    ret ~= ("   return tuple(ret, cast(Exception) null);\n");

    ret ~= ("}\n");
    ret ~= ("\n");
    return ret;
}

string generate_convertCombinationEnumKeyboardModCodeToSDLKeymod(string keyinfo_csv)
{
    string ret;

    ret ~= ("Tuple!(SDL_Keymod, Exception) convertCombinationEnumKeyboardModCodeToSDLKeymod(EnumKeyboardModCode code)\n{\n");

    ret ~= ("    SDL_Keymod ret;\n");

    auto reader = makecsvreader(keyinfo_csv);
    /* auto reader = makecsvreader(keyinfo_csv); */
    bool skipped = false;
    main_loop6: foreach (row; reader)
    {
        if (!skipped)
        {
            skipped = true;
            continue;
        }
        switch (row[TableColumns.COLUMN_SDL_KEYMOD])
        {
        default:
            break;
        case "":
            continue main_loop6;
        case END_GENERATION_MARKER:
            break main_loop6;
        }

        if (row[TableColumns.COLUMN_SDL_KEYCODE] == "")
        {
            continue;
        }

        ret ~= (format("if ((code & EnumKeyboardModCode.%s) != 0)\n",
                row[TableColumns.COLUMN_BUTTONS]));
        ret ~= ("{\n");
        ret ~= (format("    ret |= SDL_Keymod.%s;\n",
                row[TableColumns.COLUMN_SDL_KEYMOD]));
        ret ~= ("}\n");
    }

    ret ~= ("   return tuple(ret, cast(Exception)null);\n");

    ret ~= ("}\n");
    ret ~= ("\n");

    return ret;
}

int main()
{
    string cwd = getcwd();

    string keyinfo_csv;

    {
        auto f = File(cwd ~ "/KeyInfo.csv");
        /* scope(exit) f.close(); */
        ubyte[] b;
        b.length = f.size;
        keyinfo_csv = cast(string) f.rawRead(b).idup;
    }
    
    string txt;

    txt ~= ("module dtk.backends.sdl_desktop.keyconversion;\n\n");

    txt ~= (HEADER_TEXT);

    txt ~= ("
import std.typecons;
import std.format;

import bindbc.sdl;

import dtk.types.EnumKeyboardKeyCode;
import dtk.types.EnumKeyboardModCode;


");

    txt ~= ("\n");

    // ------------------ Key Codes ------------------

    txt ~= (generate_convertSDLKeycodeToEnumKeyboardKeyCode(keyinfo_csv)~"\n\n");
    txt ~= (generate_convertEnumKeyboardKeyCodeToSDLKeycode(keyinfo_csv)~"\n\n");

    // ------------------ Mod Codes ------------------ Single

    txt ~= (generate_convertSingleSDLKeymodToEnumKeyboardModCode(keyinfo_csv)~"\n\n");
    txt ~= (generate_convertSingleEnumKeyboardModCodeToSDLKeymod(keyinfo_csv)~"\n\n");


    // ------------------ Mod Codes ------------------ Combination

    txt ~= (generate_convertCombinationSDLKeymodToEnumKeyboardModCode(keyinfo_csv)~"\n\n");
    txt ~= (generate_convertCombinationEnumKeyboardModCodeToSDLKeymod(keyinfo_csv)~"\n\n");

    auto fout = File(cwd ~ "/keyconversion.d", "wb");
    scope (success)
        fout.close();

    fout.rawWrite(txt);

    return 0;
}
