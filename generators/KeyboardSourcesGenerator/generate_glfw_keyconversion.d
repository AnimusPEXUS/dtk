#!/usr/bin/env rdmd

import std.algorithm;
import std.typecons;
import std.stdio;
import std.file;
import std.csv;
import std.format;

import generator_utils;


string generate_convertGLWFKeycodeToEnumKeyboardKeyCode(string keyinfo_csv)
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

            if (skipRow(row[TableColumns.COLUMN_GLFW_KEYCODE]))
                continue;

            foreach (subitem; row[TableColumns.COLUMN_GLFW_KEYCODE].splitter(','))
            {
                cases ~=
                    q{
                    case int.%1$s:
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
            Tuple!(EnumKeyboardKeyCode, Exception) convertGLWFKeycodeToEnumKeyboardKeyCode(
                int keycode
            )
            {
                switch (keycode)
                {
                    default:
                    case GLFW_KEY_UNKNOWN:
                        return tuple(cast(EnumKeyboardKeyCode)0, new Exception("keycode not supported"));
            %s
                }
            }
        }.format(cases);

    return ret;
}

string generate_convertEnumKeyboardKeyCodeToGLWFKeycode(string keyinfo_csv)
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

            if (skipRow(row[TableColumns.COLUMN_GLFW_KEYCODE]))
                continue;

            cases ~=
                q{
                case EnumKeyboardKeyCode.%1$s:
                    return tuple(int.%2$s, cast(Exception) null);
            }.format(
                row[TableColumns.COLUMN_BUTTONS],
                row[TableColumns.COLUMN_GLFW_KEYCODE],
            );
        }
    }

    ret =
        q{
            Tuple!(int, Exception) convertEnumKeyboardKeyCodeToGLWFKeycode(
                EnumKeyboardKeyCode keycode
            )
            {
                switch (keycode)
                {
                    default:
                        return tuple(cast(int)0, new Exception("keycode not supported"));
            %s
                }
            }
        }.format(cases);

    return ret;
}

string generate_convertSingleGLWFKeymodToEnumKeyboardModCode(string keyinfo_csv)
{
    string ret;
    ret ~= (
            "Tuple!(EnumKeyboardModCode, Exception) convertSingleGLWFKeymodToEnumKeyboardModCode(int code)\n{\n");

    ret ~= ("    switch (code) {\n");
    ret ~= ("        default:\n");
    ret ~= (
            "            return tuple(cast(EnumKeyboardModCode)0, new Exception(\"could not decode supplied keycode: \"~ format(\"%s\", code)) );\n");

    auto reader = makecsvreader(keyinfo_csv);

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

        if (row[TableColumns.COLUMN_GLFW_KEYMOD] == "")
        {
            continue;
        }

        ret ~= ("        case cast(int) " ~ row[TableColumns.COLUMN_GLFW_KEYMOD] ~ ":\n");
        ret ~= ("            return tuple(EnumKeyboardModCode."
                ~ row[TableColumns.COLUMN_BUTTONS] ~ ", cast(Exception) null);\n");
    }

    ret ~= ("    }\n");
    ret ~= ("}\n");
    ret ~= ("\n");

    return ret;
}

string generate_convertSingleEnumKeyboardModCodeToGLWFKeymod(string keyinfo_csv)
{
    string ret;
    ret ~= (
            "Tuple!(int, Exception) convertSingleEnumKeyboardModCodeToGLWFKeymod(EnumKeyboardModCode code)\n{\n");

    ret ~= ("    switch (code) {\n");
    ret ~= ("        default:\n");
    ret ~= (
            "            return tuple(cast(int) 0, new Exception(\"could not decode supplied keycode: \"~ format(\"%s\", code)) );\n");

    auto reader = makecsvreader(keyinfo_csv);

    bool skipped = false;
    main_loop4: foreach (row; reader)
    {
        if (!skipped)
        {
            skipped = true;
            continue;
        }
        switch (row[TableColumns.COLUMN_GLFW_KEYMOD])
        {
        default:
            break;
        case "":
            continue main_loop4;
        case END_GENERATION_MARKER:
            break main_loop4;
        }

        if (row[TableColumns.COLUMN_GLFW_KEYCODE] == "")
        {
            continue;
        }

        ret ~= (
                "        case EnumKeyboardModCode." ~ row[TableColumns.COLUMN_BUTTONS] ~ ":\n");
        ret ~= (
                "            return tuple(cast(int) "
                ~ row[TableColumns.COLUMN_GLFW_KEYMOD] ~ ",cast(Exception)null);\n");
    }

    ret ~= ("    }\n");
    ret ~= ("}\n");
    ret ~= ("\n");
    return ret;
}

string generate_convertCombinationGLWFKeymodToEnumKeyboardModCode(string keyinfo_csv)
{
    string ret;

    ret ~= ("Tuple!(EnumKeyboardModCode, Exception) convertCombinationGLWFKeymodToEnumKeyboardModCode(int code)\n{\n");

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

        if (row[TableColumns.COLUMN_GLFW_KEYMOD] == "")
        {
            continue;
        }

        ret ~= (format("if ((code & %s) != 0)\n",
                row[TableColumns.COLUMN_GLFW_KEYMOD]));
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

string generate_convertCombinationEnumKeyboardModCodeToGLWFKeymod(string keyinfo_csv)
{
    string ret;

    ret ~= ("Tuple!(int, Exception) convertCombinationEnumKeyboardModCodeToGLWFKeymod(EnumKeyboardModCode code)\n{\n");

    ret ~= ("    int ret;\n");

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
        switch (row[TableColumns.COLUMN_GLFW_KEYMOD])
        {
        default:
            break;
        case "":
            continue main_loop6;
        case END_GENERATION_MARKER:
            break main_loop6;
        }

        if (row[TableColumns.COLUMN_GLFW_KEYCODE] == "")
        {
            continue;
        }

        ret ~= (format("if ((code & EnumKeyboardModCode.%s) != 0)\n",
                row[TableColumns.COLUMN_BUTTONS]));
        ret ~= ("{\n");
        ret ~= (format("    ret |= cast(int) %s;\n",
                row[TableColumns.COLUMN_GLFW_KEYMOD]));
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

    txt ~= ("module dtk.backends.glfw_desktop.keyconversion;\n\n");

    txt ~= (HEADER_TEXT);

    txt ~= ("
import std.typecons;
import std.format;

import bindbc.glfw;

import dtk.types.EnumKeyboardKeyCode;
import dtk.types.EnumKeyboardModCode;


");

    txt ~= ("\n");

    // ------------------ Key Codes ------------------

    txt ~= (generate_convertGLWFKeycodeToEnumKeyboardKeyCode(keyinfo_csv)~"\n\n");
    txt ~= (generate_convertEnumKeyboardKeyCodeToGLWFKeycode(keyinfo_csv)~"\n\n");

    // ------------------ Mod Codes ------------------ Single

    txt ~= (generate_convertSingleGLWFKeymodToEnumKeyboardModCode(keyinfo_csv)~"\n\n");
    txt ~= (generate_convertSingleEnumKeyboardModCodeToGLWFKeymod(keyinfo_csv)~"\n\n");


    // ------------------ Mod Codes ------------------ Combination

    txt ~= (generate_convertCombinationGLWFKeymodToEnumKeyboardModCode(keyinfo_csv)~"\n\n");
    txt ~= (generate_convertCombinationEnumKeyboardModCodeToGLWFKeymod(keyinfo_csv)~"\n\n");

    auto fout = File(cwd ~ "/keyconversion.d", "wb");
    scope (success)
        fout.close();

    fout.rawWrite(txt);

    return 0;
}
