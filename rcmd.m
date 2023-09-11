#include <stdio.h>
#include <unistd.h>
#include <sys/types.h>
#include <Carbon/Carbon.h>
#include <Cocoa/Cocoa.h>

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
        [label setFont:[NSFont systemFontOfSize:72]];
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

-(void)resize {
    if (![labelText length]) {
        [self setFrame:NSMakeRect(0, 0, 0, 0)
               display:YES];
        [view setFrame:NSMakeRect(0, 0, 0, 0)];
        [label setFrame:NSMakeRect(0, 0, 0, 0)];
    } else {
        [label setStringValue:labelText];
        [label sizeToFit];
        int x = ([[NSScreen mainScreen] visibleFrame].origin.x + [[NSScreen mainScreen] visibleFrame].size.width / 2) - ([label frame].size.width / 2);
        int y = ([[NSScreen mainScreen] visibleFrame].origin.y + [[NSScreen mainScreen] visibleFrame].size.height / 2) - ([label frame].size.height / 2);
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

- (id)init {
    if (self = [super init]) {
        running = NO;
    }
    return self;
}

-(void)begin {
    if (!running) {
        running = YES;
        textWindow = [[TextWindow alloc] initWithDelegate:self];
    }
}

-(void)end {
    if (running) {
        running = NO;
        [textWindow close];
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
    if (running)
        [textWindow resize];
}
@end

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
                    case INVALID_KEY:
                        break;
                    case KEY_DELETE:
                    case KEY_BACKSPACE:
                        if (oldText && [oldText length]) {
                            resizeWindow = YES;
                            [app setLabelText:[oldText substringWithRange:NSMakeRange(0, [oldText length] - 1)]];
                        }
                        break;
                    case KEY_ESCAPE:
                        [app setLabelText:@""];
                    case KEY_RETURN:
                        [app end];
                        break;
                    default:
                        resizeWindow = YES;
                        [app setLabelText:[oldText stringByAppendingFormat:@"%c", keycode]];
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

int main(int argc, const char *argv[]) {
    int error = CheckPrivileges();
    if (error)
        return error;

    tap = CGEventTapCreate(kCGSessionEventTap, kCGHeadInsertEventTap, 0, kCGEventMaskForAllEvents, EventCallback, NULL);
    CFRunLoopSourceRef loop = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, tap, 0);
    CGEventTapEnable(tap, 1);
    CFRunLoopAddSource(CFRunLoopGetCurrent(), loop, kCFRunLoopCommonModes);
    
    @autoreleasepool {
        app = [AppDelegate new];
        [NSApplication sharedApplication];
        [NSApp setActivationPolicy:NSApplicationActivationPolicyAccessory];
        [NSApp setDelegate:app];
        [NSApp activateIgnoringOtherApps:YES];
        [NSApp run];
    }
    return 0;
}
