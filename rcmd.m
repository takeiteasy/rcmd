#include <stdio.h>
#include <unistd.h>
#include <sys/types.h>
#include <Carbon/Carbon.h>
#include <Cocoa/Cocoa.h>
#include <CoreServices/CoreServices.h>

#if !defined(MAX_SUGGESTIONS)
#define MAX_SUGGESTIONS 5
#endif

typedef enum {
    KEY_PAD0=128,KEY_PAD1,KEY_PAD2,KEY_PAD3,KEY_PAD4,KEY_PAD5,KEY_PAD6,KEY_PAD7,KEY_PAD8,KEY_PAD9,
    KEY_PADMUL,KEY_PADADD,KEY_PADENTER,KEY_PADSUB,KEY_PADDOT,KEY_PADDIV,
    KEY_F1,KEY_F2,KEY_F3,KEY_F4,KEY_F5,KEY_F6,KEY_F7,KEY_F8,KEY_F9,KEY_F10,KEY_F11,KEY_F12,
    KEY_BACKSPACE,KEY_TAB,KEY_RETURN,KEY_SHIFT,KEY_CONTROL,KEY_ALT,KEY_PAUSE,KEY_CAPSLOCK,
    KEY_ESCAPE,KEY_SPACE,KEY_PAGEUP,KEY_PAGEDN,KEY_END,KEY_HOME,KEY_LEFT,KEY_UP,KEY_RIGHT,KEY_DOWN,
    KEY_INSERT,KEY_DELETE,KEY_LWIN,KEY_RWIN,KEY_NUMLOCK,KEY_SCROLL,KEY_LSHIFT,KEY_RSHIFT,
    KEY_LCONTROL,KEY_RCONTROL,KEY_LALT,KEY_RALT,KEY_SEMICOLON,KEY_EQUALS,KEY_COMMA,KEY_MINUS,
    KEY_DOT,KEY_SLASH,KEY_BACKTICK,KEY_LSQUARE,KEY_BACKSLASH,KEY_RSQUARE,KEY_TICK
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
            return '0';
        case kVK_ANSI_1:
            return '1';
        case kVK_ANSI_2:
            return '2';
        case kVK_ANSI_3:
            return '3';
        case kVK_ANSI_4:
            return '4';
        case kVK_ANSI_5:
            return '5';
        case kVK_ANSI_6:
            return '6';
        case kVK_ANSI_7:
            return '7';
        case kVK_ANSI_8:
            return '8';
        case kVK_ANSI_9:
            return '9';
        case kVK_ANSI_Keypad0:
            return KEY_PAD0;
        case kVK_ANSI_Keypad1:
            return KEY_PAD1;
        case kVK_ANSI_Keypad2:
            return KEY_PAD2;
        case kVK_ANSI_Keypad3:
            return KEY_PAD3;
        case kVK_ANSI_Keypad4:
            return KEY_PAD4;
        case kVK_ANSI_Keypad5:
            return KEY_PAD5;
        case kVK_ANSI_Keypad6:
            return KEY_PAD6;
        case kVK_ANSI_Keypad7:
            return KEY_PAD7;
        case kVK_ANSI_Keypad8:
            return KEY_PAD8;
        case kVK_ANSI_Keypad9:
            return KEY_PAD9;
        case kVK_ANSI_KeypadMultiply:
            return KEY_PADMUL;
        case kVK_ANSI_KeypadPlus:
            return KEY_PADADD;
        case kVK_ANSI_KeypadEnter:
            return KEY_PADENTER;
        case kVK_ANSI_KeypadMinus:
            return KEY_PADSUB;
        case kVK_ANSI_KeypadDecimal:
            return KEY_PADDOT;
        case kVK_ANSI_KeypadDivide:
            return KEY_PADDIV;
        case kVK_F1:
            return KEY_F1;
        case kVK_F2:
            return KEY_F2;
        case kVK_F3:
            return KEY_F3;
        case kVK_F4:
            return KEY_F4;
        case kVK_F5:
            return KEY_F5;
        case kVK_F6:
            return KEY_F6;
        case kVK_F7:
            return KEY_F7;
        case kVK_F8:
            return KEY_F8;
        case kVK_F9:
            return KEY_F9;
        case kVK_F10:
            return KEY_F10;
        case kVK_F11:
            return KEY_F11;
        case kVK_F12:
            return KEY_F12;
        case kVK_Shift:
            return KEY_LSHIFT;
        case kVK_Control:
            return KEY_LCONTROL;
        case kVK_Option:
            return KEY_LALT;
        case kVK_CapsLock:
            return KEY_CAPSLOCK;
        case kVK_Command:
            return KEY_LWIN;
        case kVK_Command - 1:
            return KEY_RWIN;
        case kVK_RightShift:
            return KEY_RSHIFT;
        case kVK_RightControl:
            return KEY_RCONTROL;
        case kVK_RightOption:
            return KEY_RALT;
        case kVK_Delete:
            return KEY_BACKSPACE;
        case kVK_Tab:
            return KEY_TAB;
        case kVK_Return:
            return KEY_RETURN;
        case kVK_Escape:
            return KEY_ESCAPE;
        case kVK_Space:
            return KEY_SPACE;
        case kVK_PageUp:
            return KEY_PAGEUP;
        case kVK_PageDown:
            return KEY_PAGEDN;
        case kVK_End:
            return KEY_END;
        case kVK_Home:
            return KEY_HOME;
        case kVK_LeftArrow:
            return KEY_LEFT;
        case kVK_UpArrow:
            return KEY_UP;
        case kVK_RightArrow:
            return KEY_RIGHT;
        case kVK_DownArrow:
            return KEY_DOWN;
        case kVK_Help:
            return KEY_INSERT;
        case kVK_ForwardDelete:
            return KEY_DELETE;
        case kVK_F14:
            return KEY_SCROLL;
        case kVK_F15:
            return KEY_PAUSE;
        case kVK_ANSI_KeypadClear:
            return KEY_NUMLOCK;
        case kVK_ANSI_Semicolon:
            return KEY_SEMICOLON;
        case kVK_ANSI_Equal:
            return KEY_EQUALS;
        case kVK_ANSI_Comma:
            return KEY_COMMA;
        case kVK_ANSI_Minus:
            return KEY_MINUS;
        case kVK_ANSI_Slash:
            return KEY_SLASH;
        case kVK_ANSI_Backslash:
            return KEY_BACKSLASH;
        case kVK_ANSI_Grave:
            return KEY_BACKTICK;
        case kVK_ANSI_Quote:
            return KEY_TICK;
        case kVK_ANSI_LeftBracket:
            return KEY_LSQUARE;
        case kVK_ANSI_RightBracket:
            return KEY_RSQUARE;
        case kVK_ANSI_Period:
            return KEY_DOT;
        default:
            return 0;
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

@interface TextView : NSView {}
@end

@interface TextWindow : NSWindow {
    TextView* view;
    NSTextField* label;
}
@property (nonatomic, strong) NSMutableString *labelText;
@end

@interface AppDelegate : NSObject <NSApplicationDelegate, NSWindowDelegate> {
    BOOL running;
}
@property (nonatomic, strong) TextWindow *textWindow;
@property (nonatomic, strong) TextWindow *suggestionWindow;
@property (nonatomic, strong) NSMutableArray *suggestions;
@property int maxSuggestions;
@end

@implementation TextView
- (id)initWithFrame:(NSRect)frame {
    if (self = [super initWithFrame:frame]) {}
    return self;
}

- (void)drawRect:(NSRect)frame {
    NSBezierPath* path = [NSBezierPath bezierPathWithRoundedRect:frame
                                                         xRadius:6.0
                                                         yRadius:6.0];
    [[NSColor colorWithRed:0
                     green:0
                      blue:0
                     alpha:.75] set];
    [path fill];
}
@end

@implementation TextWindow
@synthesize labelText;

-(id)initWithDelegate:(id<NSWindowDelegate>)delegate andFontSize:(double)fontSize {
    if (self = [super initWithContentRect:NSMakeRect(0, 0, 0, 0)
                                styleMask:NSWindowStyleMaskBorderless
                                  backing:NSBackingStoreBuffered
                                    defer:NO]) {
        label = [[NSTextField alloc] initWithFrame:NSMakeRect(0, 0, 0, 0)];
        view = [[TextView alloc] initWithFrame:NSMakeRect(0, 0, 0, 0)];
        
        labelText = [NSMutableString stringWithString:@""];
        
        [label setBezeled:NO];
        [label setDrawsBackground:NO];
        [label setEditable:NO];
        [label setSelectable:NO];
        [label setAlignment:NSTextAlignmentCenter];
        [label setFont:[NSFont systemFontOfSize:fontSize]];
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

-(void)update:(BOOL)offset {
    if (![labelText length]) {
        [self setFrame:NSMakeRect(0, 0, 0, 0)
               display:YES];
        [view setFrame:NSMakeRect(0, 0, 0, 0)];
        [label setFrame:NSMakeRect(0, 0, 0, 0)];
    } else {
        [label setStringValue:labelText];
        [label sizeToFit];
        int x = ([[NSScreen mainScreen] visibleFrame].origin.x + [[NSScreen mainScreen] visibleFrame].size.width / 2) - ([label frame].size.width / 2);
        int y = ([[NSScreen mainScreen] visibleFrame].origin.y + [[NSScreen mainScreen] visibleFrame].size.height / (offset ? 4 : 2)) - ([label frame].size.height / 2);
        int w = [label frame].size.width + 10;
        int h = [label frame].size.height + 10;
        [self setFrame:NSMakeRect(x, y, w, h)
               display:YES];
        [view setFrame:NSMakeRect(0, 0, w, h)];
        [label setFrame:NSMakeRect(0, 0, w, h)];
    }
    [view setNeedsDisplay:YES];
}
@end

@implementation AppDelegate : NSObject
@synthesize textWindow;
@synthesize suggestionWindow;
@synthesize suggestions;
@synthesize maxSuggestions;

- (id)init {
    if (self = [super init]) {
        running = NO;
        maxSuggestions = MAX_SUGGESTIONS;
    }
    return self;
}

-(void)begin {
    if (!running) {
        running = YES;
        textWindow = [[TextWindow alloc] initWithDelegate:self
                                              andFontSize:72.0];
        suggestionWindow = [[TextWindow alloc] initWithDelegate:self
                                                    andFontSize:32.0];
        suggestions = [[NSMutableArray alloc] init];
    }
}

-(void)end {
    if (running) {
        running = NO;
        [textWindow close];
        [suggestionWindow close];
    }
}

-(BOOL)isRunning {
    return running;
}

-(NSMutableString*)getLabelText {
    return [textWindow labelText];
}

-(void)setLabelText:(NSString*)str {
    if (running) {
        [textWindow setLabelText:[NSMutableString stringWithString:str ? str : @""]];
        [suggestions removeAllObjects];
    }
}

-(void)addSuggestion:(NSString*)name {
    if (running) {
        NSString *fullPath = [NSString stringWithFormat:@"/Applications/%@.app", name];
        [suggestions addObject:fullPath];
    }
}

-(void)updateWindow {
    [textWindow update:NO];
    NSMutableString *suggestionText = [[NSMutableString alloc] init];
    for (int i = 0; i < [suggestions count]; i++) {
        [suggestionText appendString:(NSString*)[suggestions objectAtIndex:i]];
        if (i != [suggestions count] - 1)
            [suggestionText appendString:@"\n"];
    }
    [suggestionWindow setLabelText:suggestionText];
    [suggestionWindow update:YES];
}
@end

static CFMachPortRef tap = nil;
static AppDelegate *app = nil;
static int rCmd = 0;
static NSMutableArray *apps = nil;

#define MIN3(a, b, c) ((a) < (b) ? ((a) < (c) ? (a) : (c)) : ((b) < (c) ? (b) : (c)))

int StringDistance(const char* a, const char* b) {
    size_t aLength = strlen(a), bLength = strlen(b);
    int c[aLength + 1];
    for (int y = 1; y <= aLength; y++)
        c[y] = y;
    for (int x = 1; x <= bLength; ++x) {
        c[0] = x;
        for (int y = 1, l = x - 1; y <= aLength; ++y) {
            int o = c[y];
            c[y] = MIN3(c[y] + 1, c[y - 1] + 1, l + (a[y - 1] == b[x - 1] ? 0 : 1));
            l = o;
        }
    }
    return c[aLength];
}

typedef struct {
    const char *path;
    const char *test;
    int distance;
} FileDistance;

static int CompareFileDistance(const void *a, const void *b) {
    FileDistance *da = (FileDistance*)a;
    FileDistance *db = (FileDistance*)b;
    return da->distance - db->distance;
}

static CGEventRef EventCallback(CGEventTapProxy proxy, CGEventType type, CGEventRef event, void *ref) {
    int keyUp = 0;
    switch (type) {
        case kCGEventKeyUp:
            keyUp = 1;
        case kCGEventKeyDown: {
            if (!rCmd)
                break;
            
            uint32_t flags = (uint32_t)CGEventGetFlags(event);
            uint8_t keycode = ConvertMacKey((uint16_t)CGEventGetIntegerValueField(event, kCGKeyboardEventKeycode));
            uint32_t mods = ConvertMacMod(flags);
            if (rCmd && (mods != MOD_SUPER || !(flags & NX_DEVICERCMDKEYMASK))) {
                rCmd = false;
                break;
            }
            
            if (keyUp) {
                NSString *newText = [[app getLabelText] stringByAppendingString:[[NSString stringWithFormat:@"%c", keycode] lowercaseString]];
                [app setLabelText:newText];
                
                FileDistance *distances = malloc([apps count] * sizeof(FileDistance));
                for (int i = 0; i < [apps count]; i++) {
                    NSString *str = (NSString*)[apps objectAtIndex:i];
                    distances[i].path = [str UTF8String];
                    distances[i].test = [[str lowercaseString] UTF8String];
                    distances[i].distance = StringDistance([str UTF8String], [newText UTF8String]);
                }
                qsort((void*)distances, [apps count], sizeof(FileDistance), CompareFileDistance);
                for (int i = 0; i < [app maxSuggestions]; i++)
                    [app addSuggestion:@(distances[i].path)];
                [app updateWindow];
                break;
            } else
                return NULL;
        }
        case kCGEventFlagsChanged: {
            uint32_t flags = (uint32_t)CGEventGetFlags(event);
            uint32_t mods = ConvertMacMod(flags);
            if (mods == MOD_SUPER && flags & NX_DEVICERCMDKEYMASK) {
                if (!rCmd && ![app isRunning])
                    [app begin];
                rCmd = true;
            } else {
                if (rCmd && [app isRunning])
                    [app end];
                rCmd = false;
            }
            break;
        }
        case kCGEventTapDisabledByTimeout:
        case kCGEventTapDisabledByUserInput:
            tap = (CFMachPortRef)ref;
            CGEventTapEnable(tap, 1);
        default:
            break;
    }
    return event;
}

static int CheckPrivileges(void) {
    if (getuid() || geteuid()) {
        fprintf(stderr, "ERROR: Run as root\n");
        return 1;
    }
    
    const void *keys[] = { kAXTrustedCheckOptionPrompt };
    const void *values[] = { kCFBooleanTrue };
    CFDictionaryRef options = CFDictionaryCreate(kCFAllocatorDefault,
                                                 keys, values, sizeof(keys) / sizeof(*keys),
                                                 &kCFCopyStringDictionaryKeyCallBacks,
                                                 &kCFTypeDictionaryValueCallBacks);
    int result = AXIsProcessTrustedWithOptions(options);
    CFRelease(options);
    if (!result) {
        fprintf(stderr, "ERROR: Requires accessibility permissions\n");
        return 2;
    }
    return 0;
}

static void UpdateAppList(void) {
    [apps removeAllObjects];
    NSError *err = nil;
    NSArray* dirs = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:@"/Applications"
                                                                        error:&err];
    if (err) {
        fprintf(stderr, "ERROR: %s\n", [[err description] UTF8String]);
        [NSApp terminate:nil];
    }
    for (NSString *str in dirs)
        [apps addObject:[[str lastPathComponent] stringByDeletingPathExtension]];
    [app setMaxSuggestions:MAX_SUGGESTIONS > [apps count] ? (int)[apps count] : MAX_SUGGESTIONS];
}

static void FSEventCallback(ConstFSEventStreamRef streamRef, void *clientCallBackInfo, size_t numEvents, void *eventPaths, const FSEventStreamEventFlags eventFlags[], const FSEventStreamEventId eventIds[]) {
    if (apps)
        UpdateAppList();
}

int main(int argc, const char *argv[]) {
    int error = CheckPrivileges();
    if (error)
        return error;

    tap = CGEventTapCreate(kCGSessionEventTap, kCGHeadInsertEventTap, 0, kCGEventMaskForAllEvents, EventCallback, NULL);
    CFRunLoopSourceRef loop = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, tap, 0);
    CGEventTapEnable(tap, 1);
    CFRunLoopAddSource(CFRunLoopGetCurrent(), loop, kCFRunLoopCommonModes);
    
    CFStringRef path = CFSTR("/Applications");
    FSEventStreamRef stream = FSEventStreamCreate(NULL,
                                                  &FSEventCallback,
                                                  NULL,
                                                  CFArrayCreate(NULL, (const void**)&path, 1, NULL),
                                                  kFSEventStreamEventIdSinceNow,
                                                  3.0,
                                                  kFSEventStreamCreateFlagNone);
    FSEventStreamScheduleWithRunLoop(stream, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode);
    FSEventStreamStart(stream);
    
    @autoreleasepool {
        apps = [[NSMutableArray alloc] init];
        UpdateAppList();
        app = [AppDelegate new];
        [NSApplication sharedApplication];
        [NSApp setActivationPolicy:NSApplicationActivationPolicyAccessory];
        [NSApp setDelegate:app];
        [NSApp run];
    }
    return 0;
}
