About
=====

This is DTK (D graphical ToolKit).

Currntly under heavy and deep develpment. It's far event to alpha.

DTK is thought to be higly portable, but currently it actually supports only SDL
backend.


Establishing Development Environment
------------------------------------

Basically, you'll have to 'git clone' repo somewhere and config local dub
to be able to find dtk.

Let's suppose you cloned dtk repo under directory /home/user/projects/dtk 
(so /home/user/projects/dtk/README.md is file you are currently reading).

Now 

1. go to ~/.dub/packages 
2. and create file with name 'local-packages.json'
3. put text like this into 'local-packages.json' file:
```json
[
        {
                "name": "*",
                "path": "/home/user/dpath_work"
        }
]
```
4. create this '/home/user/dpath_work' directory and cd into it
5. now create symlink (with name 'dtk') to /home/user/projects/dtk

after succeeding steps abowe, the example project inside of examples/hello 
shuold become buildable with 'dub build'. 

NOTE: usually, I comment with 'compilable' commits which succeed in 'dub build'.
   currently not all commits to 'master' branch are compilable.
   
Dependencies
------------

Currently DTK depends at least on following things and their development files:

* SDL
* font-config
* freetype
