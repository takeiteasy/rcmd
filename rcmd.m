/* rcmd.m -- https://github.com/takeiteasy/rcmd
 
 rcmd -- use the right cmd key to swtich between apps

 Copyright (C) 2024  George Watson

 This program is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.

 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.

 You should have received a copy of the GNU General Public License
 along with this program.  If not, see <https://www.gnu.org/licenses/>.*/
 
#include <stdio.h>
#include <unistd.h>
#include <sys/types.h>
#include <Carbon/Carbon.h>
#include <Cocoa/Cocoa.h>
#include <getopt.h>
#if defined(RCMD_ENABLE_LUA)
#include <lua.h>
#include <lualib.h>
#include <lauxlib.h>
#endif

#if !defined(DEFAULT_TOLERANCE)
#define DEFAULT_TOLERANCE 1
#endif

#if !defined(DEFAULT_WINDOW_PADDING)
#define DEFAULT_WINDOW_PADDING 10
#endif

#if !defined(DEFAULT_EDGE_PADDING)
#define DEFAULT_EDGE_PADDING 10
#endif

#if !defined(DEFAULT_FONT_SIZE)
#define DEFAULT_FONT_SIZE 72
#endif

#if !defined(DEFAULT_OPACITY)
#define DEFAULT_OPACITY .75f
#endif

#define POSITIONS                  \
    X(Top, "top")                  \
    X(TopLeft, "top-left")         \
    X(TopRight, "top-right")       \
    X(Bottom, "bottom")            \
    X(BottomLeft, "bottom-left")   \
    X(BottomRight, "bottom-right") \
    X(Left, "left")                \
    X(Right, "right")

typedef enum {
    Centre = 0,
#define X(VAR, TXT) VAR,
    POSITIONS
#undef X
} Position;

static struct {
#if defined(RCMD_ENABLE_LUA)
    lua_State *luaState;
#endif
    BOOL enableManualMode;
    BOOL enableVerboseMode;
    int matchTolerance;
    BOOL disableDynamicBlacklist;
    BOOL disableMenuBar;
    BOOL disableText;
    BOOL disableSwitching;
    NSString *runScript;
    Position windowPosition;
    int windowPadding;
    int screenEdgePadding;
    const char *fontName;
    int fontSize;
    struct {
        float r, g, b;
    } windowColor;
    float opacity;
} Args = {
#if defined(RCMD_ENABLE_LUA)
    .luaState = NULL,
#endif
    .enableManualMode = NO,
    .enableVerboseMode = NO,
    .matchTolerance = DEFAULT_TOLERANCE,
    .disableDynamicBlacklist = NO,
    .disableMenuBar = NO,
    .disableText = NO,
    .disableSwitching = NO,
    .runScript = nil,
    .windowPosition = Centre,
    .windowPadding = DEFAULT_WINDOW_PADDING,
    .screenEdgePadding = DEFAULT_EDGE_PADDING,
    .fontName = NULL,
    .fontSize = DEFAULT_FONT_SIZE,
    .windowColor = {
        .r = 0.f,
        .g = 0.f,
        .b = 0.f
    },
    .opacity = DEFAULT_OPACITY
};

static void SetWindowColor(unsigned char r, unsigned char g, unsigned char b) {
    Args.windowColor.r = (float)r / 255.f;
    Args.windowColor.g = (float)g / 255.f;
    Args.windowColor.b = (float)b / 255.f;
}

#define LOGF(MSG, ...)             \
do {                               \
    if (Args.enableVerboseMode)    \
        NSLog((MSG), __VA_ARGS__); \
} while(0)

#define LOG(MSG) LOGF(@"%@", (MSG))

static struct option long_options[] = {
    {"manual", no_argument, NULL, 'm'},
    {"blacklist", required_argument, NULL, 'b'},
    {"tolerance", required_argument, NULL, 'T'},
    {"no-dynamic-blacklist", no_argument, NULL, 'd'},
    {"no-menubar", no_argument, NULL, 'x'},
    {"no-text", no_argument, NULL, 't'},
    {"no-switch", no_argument, NULL, 's'},
    {"applescript", required_argument, NULL, 'a'},
    {"font", required_argument, NULL, 'f'},
    {"font-size", required_argument, NULL, 'F'},
    {"position", required_argument, NULL, 'p'},
    {"color", required_argument, NULL, 'c'},
    {"opacity", required_argument, NULL, 'o'},
    {"lua", required_argument, NULL, 'l'},
    {"verbose", no_argument, NULL, 'v'},
    {"help", no_argument, NULL, 'h'},
    {NULL, 0, NULL, 0}
};

static void usage(void) {
    puts("usage: rcmd [options]");
    puts("");
    puts("  Description:");
    puts("    Press and hold the right command key then type what process you");
    puts("    want to switch to. The text is fuzzy matched against all running");
    puts("    processes, for example typing `xcd` will probably switch to Xcode.");
    puts("");
    puts("    By default the active window will update as you type, to disable");
    puts("    this behaviour pass `--manual or -m` through the arguments. This");
    puts("    will make it so you will to press the return (Enter) key to switch");
    puts("");
    puts("  Arguments:");
    puts("    * --manual/-m -- Press return key to switch windows");
    puts("    * --blacklist/-b -- Path to app blacklist");
    puts("    * --tolerance/-T -- Fuzzy matching tolerance (default: 1)");
    puts("    * --no-dynamic-blacklist/-d -- Disable dynamically blacklisting apps");
    puts("                                   with no windows on screen");
    puts("    * --no-menubar/-x -- Disable menubar icon");
    puts("    * --no-text/-t -- Disable buffer text window");
    puts("    * --no-swtich/-s -- Disable application switching");
    puts("    * --applescript/-a -- Path to AppleScript file to run on event");
    puts("    * --font/-f -- Name of font to use");
    puts("    * --font-size/-F -- Set size of font (default: 72)");
    puts("    * --position/-p -- Set the window position, options: top, top-left,");
    puts("                       top-right, bottom, bottom-left, bottom-right,");
    puts("                       left, and right (default: centre)");
    puts("    * --color/-c -- Set the background color of he window. Accepts colors");
    puts("                    in hex (#FFFFFF) and rgb (rgb(255,255,255) formats.");
    puts("                    (default: rgb(0,0,0)");
    puts("    * --opacity/-o -- Set the opacity of the window (default: 0.5)");
    puts("    * --lua/-l -- Path to Lua file to run on event. NOTE: This requires");
    puts("                  rcmd to be build with -DRCMD_ENABLE_LUA");
    puts("    * --verbose/-b -- Enable logging");
    puts("    * --help/-h -- Display this message");
}

typedef enum {
    INVALID_KEY,
    KEY_BACKSPACE,
    KEY_RETURN,
    KEY_ESCAPE,
    KEY_DELETE
} Key;

typedef enum {
    MOD_SHIFT     = 1 << 0,
    MOD_CONTROL   = 1 << 1,
    MOD_ALT       = 1 << 2,
    MOD_SUPER     = 1 << 3
} Modifier;

static uint8_t ConvertMacKey(uint16_t key) {
    switch (key) {
        case kVK_ANSI_Q:
            return 'Q';
        case kVK_ANSI_W:
            return 'W';
        case kVK_ANSI_E:
            return 'E';
        case kVK_ANSI_R:
            return 'R';
        case kVK_ANSI_T:
            return 'T';
        case kVK_ANSI_Y:
            return 'Y';
        case kVK_ANSI_U:
            return 'U';
        case kVK_ANSI_I:
            return 'I';
        case kVK_ANSI_O:
            return 'O';
        case kVK_ANSI_P:
            return 'P';
        case kVK_ANSI_A:
            return 'A';
        case kVK_ANSI_S:
            return 'S';
        case kVK_ANSI_D:
            return 'D';
        case kVK_ANSI_F:
            return 'F';
        case kVK_ANSI_G:
            return 'G';
        case kVK_ANSI_H:
            return 'H';
        case kVK_ANSI_J:
            return 'J';
        case kVK_ANSI_K:
            return 'K';
        case kVK_ANSI_L:
            return 'L';
        case kVK_ANSI_Z:
            return 'Z';
        case kVK_ANSI_X:
            return 'X';
        case kVK_ANSI_C:
            return 'C';
        case kVK_ANSI_V:
            return 'V';
        case kVK_ANSI_B:
            return 'B';
        case kVK_ANSI_N:
            return 'N';
        case kVK_ANSI_M:
            return 'M';
        case kVK_ANSI_0:
        case kVK_ANSI_Keypad0:
            return '0';
        case kVK_ANSI_1:
        case kVK_ANSI_Keypad1:
            return '1';
        case kVK_ANSI_2:
        case kVK_ANSI_Keypad2:
            return '2';
        case kVK_ANSI_3:
        case kVK_ANSI_Keypad3:
            return '3';
        case kVK_ANSI_4:
        case kVK_ANSI_Keypad4:
            return '4';
        case kVK_ANSI_5:
        case kVK_ANSI_Keypad5:
            return '5';
        case kVK_ANSI_6:
        case kVK_ANSI_Keypad6:
            return '6';
        case kVK_ANSI_7:
        case kVK_ANSI_Keypad7:
            return '7';
        case kVK_ANSI_8:
        case kVK_ANSI_Keypad8:
            return '8';
        case kVK_ANSI_9:
        case kVK_ANSI_Keypad9:
            return '9';
        case kVK_ANSI_KeypadMultiply:
            return '*';
        case kVK_ANSI_KeypadPlus:
            return '+';
        case kVK_ANSI_KeypadEnter:
            return KEY_RETURN;
        case kVK_ANSI_Minus:
        case kVK_ANSI_KeypadMinus:
            return '-';
        case kVK_ANSI_Period:
        case kVK_ANSI_KeypadDecimal:
            return '.';
        case kVK_ANSI_Slash:
        case kVK_ANSI_KeypadDivide:
            return '/';
        case kVK_Delete:
            return KEY_BACKSPACE;
        case kVK_Return:
            return KEY_RETURN;
        case kVK_Escape:
            return KEY_ESCAPE;
        case kVK_Space:
            return ' ';
        case kVK_ANSI_Semicolon:
            return ';';
        case kVK_ANSI_Equal:
            return '=';
        case kVK_ANSI_Comma:
            return ',';
        case kVK_ANSI_Backslash:
            return '\\';
        case kVK_ANSI_Grave:
            return '`';
        case kVK_ANSI_Quote:
            return '\'';
        case kVK_ANSI_LeftBracket:
            return '[';
        case kVK_ANSI_RightBracket:
            return ']';
        default:
            return INVALID_KEY;
    }
}

static unsigned int ConvertMacMod(unsigned int flags) {
    int result = 0;
    if (flags & kCGEventFlagMaskShift)
        result |= MOD_SHIFT;
    if (flags & kCGEventFlagMaskControl)
        result |= MOD_CONTROL;
    if (flags & kCGEventFlagMaskAlternate)
        result |= MOD_ALT;
    if (flags & kCGEventFlagMaskCommand)
        result |= MOD_SUPER;
    return result;
}

// Source: https://rosettacode.org/wiki/Levenshtein_distance#C
/* s, t: two strings; ls, lt: their respective length */
static int distance(const char *s, int ls, const char *t, int lt) {
        int a, b, c;

        /* if either string is empty, difference is inserting all chars
         * from the other
         */
        if (!ls) return lt;
        if (!lt) return ls;

        /* if last letters are the same, the difference is whatever is
         * required to edit the rest of the strings
         */
        if (s[ls - 1] == t[lt - 1])
                return distance(s, ls - 1, t, lt - 1);

        /* else try:
         *      changing last letter of s to that of t; or
         *      remove last letter of s; or
         *      remove last letter of t,
         * any of which is 1 edit plus editing the rest of the strings
         */
        a = distance(s, ls - 1, t, lt - 1);
        b = distance(s, ls,     t, lt - 1);
        c = distance(s, ls - 1, t, lt    );

        if (a > b) a = b;
        if (a > c) a = c;

        return a + 1;
}

// Copyright 2020 Joshua J Baker. All rights reserved.
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file.
//
// match returns true if str matches pattern. This is a very
// simple wildcard match where '*' matches on any number characters
// and '?' matches on any one character.
//
// pattern:
//   { term }
// term:
//      '*'         matches any sequence of non-Separator characters
//      '?'         matches any single non-Separator character
//      c           matches character c (c != '*', '?')
//     '\\' c       matches character c
static bool match(const char *pat, long plen, const char *str, long slen)  {
    if (plen < 0)
        plen = strlen(pat);
    if (slen < 0)
        slen = strlen(str);
    while (plen > 0) {
        if (pat[0] == '\\') {
            if (plen == 1)
                return false;
            pat++;
            plen--;
        } else if (pat[0] == '*') {
            if (plen == 1)
                return true;
            if (pat[1] == '*') {
                pat++;
                plen--;
                continue;
            }
            if (match(pat+1, plen-1, str, slen))
                return true;
            if (slen == 0)
                return false;
            str++;
            slen--;
            continue;
        }
        if (slen == 0)
            return false;
        if (pat[0] != '?' && str[0] != pat[0])
            return false;
        pat++;
        plen--;
        str++;
        slen--;
    }
    return slen == 0 && plen == 0;
}

@implementation NSString (c)
-(NSUInteger)distanceToString:(NSString*)string {
    return distance([self UTF8String], (int)[self length], [string UTF8String], (int)[string length]);
}

-(BOOL)wildcardMatchString:(NSString*)pattern {
    return match([pattern UTF8String], -1, [self UTF8String], -1);
}
@end

#if defined(RCMD_ENABLE_LUA)
static void LuaDumpTable(lua_State* L, int idx) {
    printf("--------------- LUA TABLE DUMP ---------------\n");
    lua_pushvalue(L, idx);
    lua_pushnil(L);
    int t, j = (idx < 0 ? -idx : idx), i = idx - 1;
    const char *key = NULL, *tmp = NULL;
    while ((t = lua_next(L, i))) {
        lua_pushvalue(L, idx - 1);
        key = lua_tostring(L, idx);
        switch (lua_type(L, idx - 1)) {
            case LUA_TSTRING:
                printf("%s (string, %d) => `%s'\n", key, j, lua_tostring(L, i));
                break;
            case LUA_TBOOLEAN:
                printf("%s (boolean, %d) => %s\n", key, j, lua_toboolean(L, i) ? "true" : "false");
                break;
            case LUA_TNUMBER:
                printf("%s (integer, %d) => %g\n", key, j, lua_tonumber(L, i));
                break;
            default:
                tmp = lua_typename(L, i);
                printf("%s (%s, %d) => %s\n", key, tmp, j, tmp);
                if (!strncmp(lua_typename(L, t), "table", 5))
                    LuaDumpTable(L, i);
                break;
        }
        lua_pop(L, 2);
    }
    lua_pop(L, 1);
    printf("--------------- END TABLE DUMP ---------------\n");
}

static int LuaDumpStack(lua_State* L) {
    int t, i = lua_gettop(L);
    const char* tmp = NULL;
    printf("--------------- LUA STACK DUMP ---------------\n");
    for (; i; --i) {
        
        switch ((t = lua_type(L, i))) {
            case LUA_TSTRING:
                printf("%d (string): `%s'\n", i, lua_tostring(L, i));
                break;
            case LUA_TBOOLEAN:
                printf("%d (boolean): %s\n", i, lua_toboolean(L, i) ? "true" : "false");
                break;
            case LUA_TNUMBER:
                printf("%d (integer): %g\n",  i, lua_tonumber(L, i));
                break;
            default:
                tmp = lua_typename(L, t);
                printf("%d (%s): %s\n", i, lua_typename(L, t), tmp);
                break;
        }
    }
    printf("--------------- END STACK DUMP ---------------\n");
    return 0;
}
#endif

//! MARK: Interfaces

@interface TextView : NSView {}
@end

@interface TextWindow : NSWindow {
    TextView* view;
    NSTextField* label;
}
@property (nonatomic, strong) NSMutableString *labelText;
@end

@interface Window : NSObject {}
@property BOOL isOnScreen;
@property long parentPID;
@property long windowNumber;
@property (nonatomic, strong) NSString *parentName;
@property NSRect bounds;
@end

@interface WindowManager : NSObject {
    NSArray *localBlacklist;
    NSMutableArray *dynamicBlacklist;
}
@property (nonatomic, strong) NSMutableArray *windows;
@end

@interface AppDelegate : NSObject <NSApplicationDelegate, NSWindowDelegate> {
    BOOL running;
}
@property (nonatomic, strong) TextWindow *textWindow;
@property (nonatomic, strong) WindowManager *windowManager;
@property (nonatomic, strong) NSStatusItem *statusBar;
@property (nonatomic, strong) NSApplication *applescript;
@end

//! MARK: Implementations

@implementation TextView
- (id)initWithFrame:(NSRect)frame {
    if (self = [super initWithFrame:frame]) {}
    return self;
}

- (void)drawRect:(NSRect)frame {
    NSBezierPath* path = [NSBezierPath bezierPathWithRoundedRect:frame
                                                         xRadius:6.0
                                                         yRadius:6.0];
    [[NSColor colorWithRed:Args.windowColor.r
                     green:Args.windowColor.g
                      blue:Args.windowColor.b
                     alpha:Args.opacity] set];
    [path fill];
}
@end

//! MARK: TextWindow Implementation

@implementation TextWindow
@synthesize labelText;

-(id)initWithDelegate:(id<NSWindowDelegate>)delegate {
    if (self = [super initWithContentRect:NSMakeRect(0, 0, 0, 0)
                                styleMask:NSWindowStyleMaskBorderless
                                  backing:NSBackingStoreBuffered
                                    defer:NO]) {
        label = [[NSTextField alloc] initWithFrame:NSMakeRect(0, 0, 0, 0)];
        view = [[TextView alloc] initWithFrame:NSMakeRect(0, 0, 0, 0)];
        
        labelText = [[NSMutableString alloc] initWithString:@""];
        
        [label setBezeled:NO];
        [label setDrawsBackground:NO];
        [label setEditable:NO];
        [label setSelectable:NO];
        [label setAlignment:NSTextAlignmentCenter];
        [label setFont:Args.fontName ? [NSFont fontWithName:@(Args.fontName) size:Args.fontSize] : [NSFont systemFontOfSize:Args.fontSize]];
        [label setTextColor:[NSColor whiteColor]];
        [[label cell] setBackgroundStyle:NSBackgroundStyleRaised];
        [label sizeToFit];
        
        [self setTitle:NSProcessInfo.processInfo.processName];
        [self setOpaque:NO];
        [self setExcludedFromWindowsMenu:NO];
        [self setBackgroundColor:[NSColor clearColor]];
        [self setIgnoresMouseEvents:YES];
        [self makeKeyAndOrderFront:self];
        [self setLevel:NSFloatingWindowLevel];
        [self setCanHide:NO];
        [self setDelegate:delegate];
        [self setReleasedWhenClosed:NO];
        
        [self setContentView:view];
        [view addSubview:label];
    }
    return self;
}

-(BOOL)canBecomeKeyWindow {
    return YES;
}

-(void)resize {
    if (![labelText length]) {
        [self setFrame:NSMakeRect(0, 0, 0, 0)
               display:YES];
        [view setFrame:NSMakeRect(0, 0, 0, 0)];
        [label setFrame:NSMakeRect(0, 0, 0, 0)];
    } else {
        [label setStringValue:labelText];
        [label sizeToFit];
        
        int x = 0, y = 0;
        switch (Args.windowPosition) {
            case Bottom:
            case Top:
            case Centre:
                x = ([[NSScreen mainScreen] visibleFrame].origin.x + [[NSScreen mainScreen] visibleFrame].size.width / 2) - ([label frame].size.width / 2);
                break;
            case Left:
            case TopLeft:
            case BottomLeft:
                x = [[NSScreen mainScreen] visibleFrame].origin.x + Args.screenEdgePadding;
                break;
            case TopRight:
            case BottomRight:
            case Right:
                x = ([[NSScreen mainScreen] visibleFrame].origin.x + [[NSScreen mainScreen] visibleFrame].size.width) - ([label frame].size.width + Args.screenEdgePadding);
                break;
        }
        switch (Args.windowPosition) {
            case Left:
            case Right:
            case Centre:
                y = ([[NSScreen mainScreen] visibleFrame].origin.y + [[NSScreen mainScreen] visibleFrame].size.height / 2) - ([label frame].size.height / 2);
                break;
            case Top:
            case TopLeft:
            case TopRight:
                y = ([[NSScreen mainScreen] visibleFrame].origin.y + [[NSScreen mainScreen] visibleFrame].size.height) - ([label frame].size.height + Args.screenEdgePadding);
                break;
            case Bottom:
            case BottomLeft:
            case BottomRight:
                y = [[NSScreen mainScreen] visibleFrame].origin.y + Args.screenEdgePadding;
                break;
        }
        int w = [label frame].size.width + Args.windowPadding;
        int h = [label frame].size.height + Args.windowPadding;
        [self setFrame:NSMakeRect(x, y, w, h)
               display:YES];
        [view setFrame:NSMakeRect(0, 0, w, h)];
        [label setFrame:NSMakeRect(0, 0, w, h)];
    }
    [view setNeedsDisplay:YES];
}
@end

//! MARK: Window Implementation

@implementation Window
-(id)initWithValues:(BOOL)isOnScreen PID:(long)parentPID parentName:(NSString*)parentName windowNumber:(long)windowNumber andBounds:(NSRect)bounds {
    if (self = [super init]) {
        _isOnScreen = isOnScreen;
        _parentPID = parentPID;
        _parentName = parentName;
        _windowNumber = windowNumber;
        _bounds = bounds;
    }
    return self;
}

-(id)init {
    return [self initWithValues:NO
                            PID:-1
                     parentName:nil
                   windowNumber:-1
                      andBounds:NSMakeRect(0.f, 0.f, 0.f, 0.f)];
}
@end

//! MARK: WindowManager Implementation

static const char *globalBlacklist[] = {
    "WindowManager",
    "TextInputMenuAgent",
    "Notification Centre",
    "Universal Control",
    "Dock",
    "Control Centre",
    "Spotlight",
    "Window Server",
    "SystemUIServer",
    "rcmd",
    "com.apple.Safari.SandboxBroker"
};

@implementation WindowManager
@synthesize windows;

-(id)init {
    if (self = [super init]) {
        windows = [[NSMutableArray alloc] init];
        localBlacklist = nil;
        dynamicBlacklist = [[NSMutableArray alloc] init];
        [self refreshWindowList];
    }
    return self;
}

-(BOOL)loadBlacklistFromPath:(NSString*)path {
    NSError *error = nil;
    NSString* fileContents = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&error];
    if (error) {
        NSLog(@"ERROR: Failed to read \"%@\" reading file: %@", path, error.localizedDescription);
        return NO;
    }
    localBlacklist = [fileContents componentsSeparatedByString:@"\n"];
    return localBlacklist && [localBlacklist count];
}

-(BOOL)checkAgainstBlacklists:(NSString*)test {
    if (!Args.disableDynamicBlacklist)
        for (NSString *rule in dynamicBlacklist)
            if ([test isEqualToString:rule])
                return YES;
    
    if (!localBlacklist)
        return NO;
    for (NSString *rule in localBlacklist)
        if ([test wildcardMatchString:rule])
            return YES;
    return NO;
}

-(void)refreshWindowList {
    if (Args.disableSwitching)
        return;
    [windows removeAllObjects];
    CFArrayRef windowList = CGWindowListCopyWindowInfo(kCGWindowListExcludeDesktopElements, kCGNullWindowID);
    for (int i = 0; i < CFArrayGetCount(windowList); i++) {
        NSDictionary *dict = CFArrayGetValueAtIndex(windowList, i);
        NSString *parentName = (NSString*)[dict objectForKey:@"kCGWindowOwnerName"];
        BOOL skip = NO;
        for (int i = 0; i < sizeof(globalBlacklist) / sizeof(const char*); i++)
            if (!strncmp(globalBlacklist[i], [parentName UTF8String], [parentName length])) {
                skip = YES;
                break;
            }
        if (!skip)
            skip = [self checkAgainstBlacklists:parentName];
        if (skip)
            continue;
        
        NSNumber *windowNumber = (NSNumber*)[dict objectForKey:@"kCGWindowNumber"];
        NSDictionary *windowBounds = (NSDictionary*)[dict objectForKey:@"kCGWindowBounds"];
        NSNumber *parentPID = (NSNumber*)[dict objectForKey:@"kCGWindowOwnerPID"];
        [windows addObject:[[Window alloc] initWithValues:(BOOL)[dict objectForKey:@"kCGWindowIsOnscreen"]
                                                      PID:[parentPID integerValue]
                                               parentName:parentName
                                             windowNumber:[windowNumber integerValue]
                                                andBounds:NSMakeRect([(NSNumber*)[windowBounds objectForKey:@"X"] floatValue],
                                                                     [(NSNumber*)[windowBounds objectForKey:@"Y"] floatValue],
                                                                     [(NSNumber*)[windowBounds objectForKey:@"Width"] floatValue],
                                                                     [(NSNumber*)[windowBounds objectForKey:@"Height"] floatValue])]];
    }
}

-(NSArray*)getWindows:(long)parentPID {
    NSMutableArray *result = [[NSMutableArray alloc] init];
    for (int i = 0; i < [windows count]; i++) {
        Window *window = [windows objectAtIndex:i];
        if ([window parentPID] == parentPID)
            [result addObject:window];
    }
    return [result count] ? result : nil;
}

-(NSArray*)uniqueParents {
    NSMutableArray *parents = [[NSMutableArray alloc] init];
    for (int i = 0; i < [windows count]; i++) {
        Window *window = [windows objectAtIndex:i];
        [parents addObject:[window parentName]];
    }
    return [parents count] ? [parents valueForKeyPath:[NSString stringWithFormat:@"@distinctUnionOfObjects.%@", @"self"]] : nil;
}

-(NSArray*)findBestMatch:(NSString*)test {
    if (![windows count] || !test || ![test length])
        return nil;
    
    LOGF(@"* SEARCHING FOR \"%@\":", [test uppercaseString]);
    
    NSString *testLower = [test lowercaseString];
    NSArray *parents = [self uniqueParents];
    NSMutableDictionary *results = [[NSMutableDictionary alloc] init];
    NSString *closest = nil;
    long lowestDistance = LONG_MAX;
    for (NSString *parent in parents) {
        if ([self checkAgainstBlacklists:parent])
            continue;
        
        NSString *test = parent;
        if ([[test pathExtension] isEqualToString:@"app"])
            test = [[test lastPathComponent] stringByDeletingPathExtension];
        
        long d = [[test lowercaseString] distanceToString:testLower];
        [results setObject:[NSNumber numberWithLong:d] forKey:parent];
        if (d < lowestDistance) {
            closest = parent;
            lowestDistance = d;
        }
    }
    assert(closest);
    
    long mostSimilarities = LONG_MIN;
    for (NSString *key in results) {
        NSNumber *value = [results objectForKey:key];
        if ([value longValue] <= lowestDistance+Args.matchTolerance) {
            NSString *test = [key lowercaseString];
            if ([[test pathExtension] isEqualToString:@"app"])
                test = [[test lastPathComponent] stringByDeletingPathExtension];
            
            long similiarities = 0;
            for (int i = 0; i < [testLower length]; i++)
                for (int j = 0; j < [test length]; j++)
                    if ([test characterAtIndex:j] == [testLower characterAtIndex:i])
                        similiarities++;
            
            LOGF(@"* MATCH: \"%@\" (%ld)", key, similiarities);
            if (similiarities > mostSimilarities) {
                closest = key;
                mostSimilarities = similiarities;
            }
        }
    }
    assert(closest);
    
    long parentPID = 0;
    for (int i = 0; i < [windows count]; i++) {
        Window *window = [windows objectAtIndex:i];
        if ([[window parentName] isEqualToString:closest]) {
            parentPID = [window parentPID];
            break;
        }
    }
    assert(parentPID);
    
    return [self getWindows:parentPID];
}

-(void)focusWindow:(NSString*)test {
    if (Args.runScript) {
        NSAppleScript *script = [[NSAppleScript alloc] initWithSource:[NSString stringWithFormat:@"%@ \"%@\"\n%@", @"set RCMDTEXT to", test, Args.runScript]];
        NSDictionary *osaError = nil;
        NSAppleEventDescriptor *result = [script executeAndReturnError:&osaError];
        if (!result)
            NSLog(@"ERROR: Failed to execute AppleScript -- %@", osaError);
    }
    
#if defined(RCMD_ENABLE_LUA)
    if (Args.luaState) {
        lua_getglobal(L, "on_rcmd_event");
        lua_pushlstring(Args.luaState, [test UTF8String], [test length]);
        if (lua_pcall(Args.luaState, 1, 0, 0)) {
            fprintf(stderr, "LUA ERROR: %s", lua_tostring(Args.luaState, -1));
            LuaDumpStack(Args.luaState);
        }
        lua_pop(L, 1);
    }
#endif
    
    if (Args.disableSwitching)
        return;
    NSArray *results = [self findBestMatch:test];
    assert(results && [results count]);
    Window *focuedWindow = nil;
    for (Window *window in results)
        if ([window isOnScreen]) {
            focuedWindow = window;
            break;
        }
    if (!focuedWindow) {
        LOGF(@"* NO ON SCREEN WINDOWS FOUND FOR \"%@\"", test);
        NSString *name = [(Window*)[results objectAtIndex:0] parentName];
        if (!Args.disableDynamicBlacklist) {
            LOGF(@"* ADDING \"%@\" TO BLACKLIST", name);
            [dynamicBlacklist addObject:name];
        }
        return;
    }
    LOGF(@"* FOCUSING WINDOW: %@ (pid:%ld, wid:%ld)", [focuedWindow parentName], [focuedWindow parentPID], [focuedWindow windowNumber]);
    
    pid_t pid = (pid_t)[focuedWindow parentPID];
    AXUIElementRef axWindows = AXUIElementCreateApplication(pid);
    NSRunningApplication *app = [NSRunningApplication runningApplicationWithProcessIdentifier:pid];
    [app activateWithOptions:NSApplicationActivateIgnoringOtherApps];
    AXUIElementPerformAction(axWindows, kAXRaiseAction);
}
@end

//! MARK: AppDelegate Implementation

@implementation AppDelegate
@synthesize textWindow;
@synthesize windowManager;

- (id)init {
    if (self = [super init]) {
        running = NO;
        windowManager = [[WindowManager alloc] init];
    }
    return self;
}

-(void)applicationDidFinishLaunching:(NSNotification *)notification {
    if (Args.disableMenuBar)
        return;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(terminate:)
                                                 name:NSApplicationWillTerminateNotification
                                               object:nil];
    _statusBar = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    _statusBar.button.image = [NSImage imageWithSystemSymbolName:@"command"
                                       accessibilityDescription:nil];
#if __MAC_OS_X_VERSION_MAX_ALLOWED < MAC_OS_X_VERSION_10_4
    statusBar.highlightMode = YES;
#endif
    NSMenu *menu = [[NSMenu alloc] init];
    [menu addItemWithTitle:@"Quit" action:@selector(terminate:) keyEquivalent:@"q"];
    _statusBar.menu = menu;
}

-(void)begin {
    if (!running) {
        running = YES;
        textWindow = [[TextWindow alloc] initWithDelegate:self];
        [windowManager refreshWindowList];
#if defined(RCMD_ENABLE_LUA)
        if (Args.luaState) {
            lua_getglobal(L, "on_rcmd_pressed");
            if (!lua_isfunction(Args.luaState, -1) || lua_pcall(Args.luaState, 0, 0, 0)) {
                fprintf(stderr, "LUA ERROR: %s", lua_tostring(Args.luaState, -1));
                LuaDumpStack(Args.luaState);
            }
        }
#endif
        LOG(@"* RCMD ACTIVATED");
    }
}

-(void)end {
    if (running) {
        running = NO;
        [textWindow close];
#if defined(RCMD_ENABLE_LUA)
        if (Args.luaState) {
            lua_getglobal(L, "on_rcmd_released");
            if (!lua_isfunction(Args.luaState, -1) || lua_pcall(Args.luaState, 0, 0, 0)) {
                fprintf(stderr, "LUA ERROR: %s", lua_tostring(Args.luaState, -1));
                LuaDumpStack(Args.luaState);
            }
        }
#endif
        LOG(@"* RCMD STOPPED");
    }
}

-(BOOL)isRunning {
    return running;
}

-(NSMutableString*)getLabelText {
    return [textWindow labelText];
}

-(void)setLabelText:(NSString*)str {
    if (running)
        [[textWindow labelText] setString:str];
}

-(void)resizeWindow {
    if (running && !Args.disableText)
        [textWindow resize];
}
@end

//! MARK: Globals

static CFMachPortRef tap = nil;
static AppDelegate *app = nil;
static BOOL rCmdDown = NO;

static CGEventRef EventCallback(CGEventTapProxy proxy, CGEventType type, CGEventRef event, void *ref) {
    int keyUp = 0;
    switch (type) {
        case kCGEventKeyUp:
            keyUp = 1;
        case kCGEventKeyDown: {
            if (!rCmdDown)
                break;
            uint32_t flags = (uint32_t)CGEventGetFlags(event);
            uint8_t keycode = ConvertMacKey((uint16_t)CGEventGetIntegerValueField(event, kCGKeyboardEventKeycode));
            uint32_t mods = ConvertMacMod(flags);
            if (mods != MOD_SUPER || !(flags & NX_DEVICERCMDKEYMASK)) {
                rCmdDown = NO;
                break;
            }
            
            if (keyUp) {
                BOOL resizeWindow = NO;
                NSMutableString *oldText = [app getLabelText];
                switch (keycode) {
                    case INVALID_KEY: break;
                    case KEY_DELETE:
                    case KEY_BACKSPACE:
                        if (oldText && [oldText length]) {
                            resizeWindow = YES;
                            NSString *newText = [oldText substringWithRange:NSMakeRange(0, [oldText length] - 1)];
                            [app setLabelText:newText];
                            if (!Args.enableManualMode)
                                [[app windowManager] focusWindow:newText];
                        }
                        break;
                    case KEY_ESCAPE:
                        [oldText setString:@""];
                        [app setLabelText:@""];
                        LOG(@"* RCMD CANCELLED (ESC KEY)");
                    case KEY_RETURN:
                        if (Args.enableManualMode && [oldText length])
                            [[app windowManager] focusWindow:oldText];
                        [app end];
                        break;
                    default:
                        resizeWindow = YES;
                        NSString *newText = [oldText stringByAppendingFormat:@"%c", keycode];
                        [app setLabelText:newText];
                        if (!Args.enableManualMode)
                            [[app windowManager] focusWindow:newText];
                        break;
                }
                
                if (resizeWindow)
                    [app resizeWindow];
            }
            break;
        }
        case kCGEventFlagsChanged: {
            uint32_t flags = (uint32_t)CGEventGetFlags(event);
            uint32_t mods = ConvertMacMod(flags);
            if (mods == MOD_SUPER && flags & NX_DEVICERCMDKEYMASK) {
                rCmdDown = YES;
                [app begin];
            } else {
                if (rCmdDown) {
                    rCmdDown = NO;
                    [app end];
                }
            }
            break;
        }
        case kCGEventTapDisabledByTimeout:
        case kCGEventTapDisabledByUserInput:
            CGEventTapEnable(tap, 1);
        default:
            break;
    }
    return rCmdDown ? NULL : event;
}

static int CheckPrivileges(void) {
    const void *keys[] = { kAXTrustedCheckOptionPrompt };
    const void *values[] = { kCFBooleanTrue };
    CFDictionaryRef options = CFDictionaryCreate(kCFAllocatorDefault,
                                                 keys, values, sizeof(keys) / sizeof(*keys),
                                                 &kCFCopyStringDictionaryKeyCallBacks,
                                                 &kCFTypeDictionaryValueCallBacks);
    int result = AXIsProcessTrustedWithOptions(options);
    CFRelease(options);
    if (!result) {
        fprintf(stderr, "ERROR: Process requires accessibility permissions\n");
        return 2;
    }
    return 0;
}

int main(int argc, char *argv[]) {
    if (getuid() == 0 || geteuid() == 0) {
        fprintf(stderr, "ERROR: You shouldn't run this as root\n");
        return 1;
    }
    
    int opt;
    extern int optind;
    extern char* optarg;
    extern int optopt;
    const char *blacklistPath = NULL;
    while ((opt = getopt_long(argc, argv, "hvdTtsxma:b:f:F:p:c:o:l:", long_options, NULL)) != -1) {
        switch (opt) {
            case 'm':
                Args.enableManualMode = YES;
                break;
            case 'b':
                blacklistPath = optarg;
                break;
            case 'T':
                Args.matchTolerance = atoi(optarg);
                break;
            case 'd':
                Args.disableDynamicBlacklist = YES;
                break;
            case 'x':
                Args.disableMenuBar = YES;
                break;
            case 't':
                Args.disableText = YES;
                break;
            case 's':
                Args.disableSwitching = YES;
                break;
            case 'a': {
                if (![[NSFileManager defaultManager] fileExistsAtPath:@(optarg)]) {
                    fprintf(stderr, "ERROR: No script found at \"%s\"\n", optarg);
                    return 4;
                }
                NSError *error = nil;
                Args.runScript = [NSString stringWithContentsOfFile:@(optarg)
                                                           encoding:NSUTF8StringEncoding
                                                              error:&error];
                if (error) {
                    fprintf(stderr, "ERROR: Failed to load script at \"%s\" -- %s\n", optarg, [[error localizedDescription] UTF8String]);
                    return 5;
                }
                break;
            }
            case 'f':
                Args.fontName = optarg;
                break;
            case 'F':
                Args.fontSize = atoi(optarg);
                break;
            case 'p': {
                long s = strlen(optarg);
#define X(VAR, TXT)             \
if (!strncmp((TXT), optarg, s)) \
    Args.windowPosition = (VAR);
                POSITIONS
#undef X
                break;
            }
            case 'c':
                if (optarg[0] == '#') {
                    int _r, _g, _b;
                    sscanf(optarg, "%02x%02x%02x", &_r, &_g, &_b);
                    SetWindowColor(_r, _g, _b);
                } else if (!strncmp(optarg, "rgb", 3)) {
                    int _r, _g, _b;
                    sscanf(optarg, "rgb(%d,%d,%d)", &_r, &_g, &_b);
                    SetWindowColor(_r, _g, _b);
                } else {
                    fprintf(stderr, "ERROR: Invalid color format\n");
                    usage();
                    return 6;
                }
                break;
            case 'o':
                Args.opacity = atof(optarg);
                break;
            case 'l': {
#if defined(RCMD_ENABLE_LUA)
                Args.luaState = luaL_newstate();
                luaL_openlibs(Args.luaState);
                int result = luaL_dofile(Args.luaState, optarg);
                if (result) {
                    fprintf(stderr, "LUA ERROR: %s\n", lua_tostring(L, -1));
                    LuaDumpStack(Args.luaState);
                    return 7;
                }
#else
                fprintf(stderr, "ERROR: Cannot use --lua/-l, rcmd needs to be build with -DRCMD_ENABLE_LUA\n");
                return 8;
#endif
                break;
            }
            case 'v':
                Args.enableVerboseMode = YES;
                break;
            case 'h':
                usage();
                return 0;
            case '?':
                fprintf(stderr, "ERROR: Unknown argument \"-%c\"\n", optopt);
                usage();
                return 3;
        }
    }
    
    int error = CheckPrivileges();
    if (error)
        return error;
    
    tap = CGEventTapCreate(kCGSessionEventTap, kCGHeadInsertEventTap, 0, kCGEventMaskForAllEvents, EventCallback, NULL);
    assert(tap);
    LOG(@"* EVENT TAP ENABLE");
    CFRunLoopSourceRef loop = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, tap, 0);
    CGEventTapEnable(tap, 1);
    CFRunLoopAddSource(CFRunLoopGetCurrent(), loop, kCFRunLoopCommonModes);
    
    @autoreleasepool {
        app = [AppDelegate new];
        LOG(@"* APP DELEGATE CREATED");
        if (blacklistPath) {
            LOGF(@"* LOADING BLACK LIST FROM \"%s\"", blacklistPath);
            LOGF(@"* %s LOADING BLACKLIST AT \"%s\"", ![[app windowManager] loadBlacklistFromPath:@(blacklistPath)] ? "ERROR" : "SUCCESS", blacklistPath);
        }
        [NSApplication sharedApplication];
        [NSApp setActivationPolicy:NSApplicationActivationPolicyAccessory];
        [NSApp setDelegate:app];
        [NSApp activateIgnoringOtherApps:YES];
        [NSApp run];
    }
    return 0;
}
