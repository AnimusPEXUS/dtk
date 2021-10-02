module dtk.interfaces.FontMgrI;

import std.typecons;

import dtk.interfaces.FaceI;

import dtk.types.fontinfo;

interface FontMgrI
{
    FaceInfo*[] getFaceInfoList();
    FaceI loadFace(FaceInfo* face_info);
    final FaceI loadFace(string filename)
    {
        auto x = new FaceInfo;
        x.on_fs = true;
        x.on_fs_filename = filename;
        return loadFace(x);
    }
}
