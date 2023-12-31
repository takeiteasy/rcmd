# rcmd

A simple MacOS application switcher, inspired by [rcmd](https://lowtechguys.com/rcmd/). I didn't want to spend $13 so I made a small app with a similar concept. **NOTE**: Neither I nor this repo have anything to do with the original rcmd app.

<p align="center">
  <img width="600" height="400" src="https://github.com/takeiteasy/rcmd/blob/master/demo.gif?raw=true">
</p>

## Usage

```
usage: rcmd [options]

  Description:
    Press and hold the right command key then type what process you
    want to switch to. The text is fuzzy matched against all running
    processes, for example typing `xcd` will probably switch to Xcode.

    By default the active window will update as you type, to disable
    this behaviour pass `--manual or -m` through the arguments. This
    will make it so you will to press the return (Enter) key to switch

  Arguments:
    * --manual/-m -- Press return key to switch windows
    * --blacklist/-b -- Path to app blacklist
    * --tolerance/-T -- Fuzzy matching tolerance (default: 1)
    * --no-dynamic-blacklist/-d -- Disable dynamically blacklisting apps
                                   with no windows on screen
    * --no-menubar/-x -- Disable menubar icon
    * --no-text/-t -- Disable buffer text window
    * --no-swtich/-s -- Disable application switching
    * --applescript/-a -- Path to AppleScript file to run on event
    * --font/-f -- Name of font to use
    * --font-size/-F -- Set size of font (default: 72)
    * --position/-p -- Set the window position, options: top, top-left,
                       top-right, bottom, bottom-left, bottom-right,
                       left, and right (default: centre)
    * --color/-c -- Set the background color of he window. Accepts colors
                    in hex (#FFFFFF) and rgb (rgb(255,255,255) formats.
                    (default: rgb(0,0,0)
    * --opacity/-o -- Set the opacity of the window (default: 0.5)
    * --lua/-l -- Path to Lua file to run on event. NOTE: This requires
                  rcmd to be build with -DRCMD_ENABLE_LUA
    * --verbose/-b -- Enable logging
    * --help/-h -- Display this message
```

## Build

You have three choices:

1. Run ```make``` and ```make install``` to build and intall the program
2. Run ```make app``` and ```make install-app``` to build and install the app version
3. Use [xcodegen](https://github.com/yonaskolb/XcodeGen) to generate the Xcode project

**NOTE**: This app needs accessibility permissions to run.

## Credits

- Levenshtein distance implementation taken from [Rosetta Code](https://rosettacode.org/wiki/Levenshtein_distance#C)
- String wildcard matching function by [tidwall/match.c](https://github.com/tidwall/match.c)
- Privileges check for accessibility by [koekeishiya/skhd](https://github.com/koekeishiya/skhd) 

## LICENSE
```
The MIT License (MIT)

Copyright (c) 2023 George Watson

Permission is hereby granted, free of charge, to any person
obtaining a copy of this software and associated documentation
files (the "Software"), to deal in the Software without restriction,
including without limitation the rights to use, copy, modify, merge,
publish, distribute, sublicense, and/or sell copies of the Software,
and to permit persons to whom the Software is furnished to do so,
subject to the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
```
