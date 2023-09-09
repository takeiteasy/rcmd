#include <stdio.h>
#include <unistd.h>
#include <sys/types.h>
#include <Carbon/Carbon.h>

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

static CFMachPortRef tap = nil;

static CGEventRef EventCallback(CGEventTapProxy proxy, CGEventType type, CGEventRef event, void *ref) {
    switch (type) {
        case kCGEventKeyDown:
            break;
        case kCGEventTapDisabledByTimeout:
        case kCGEventTapDisabledByUserInput:
            tap = (CFMachPortRef)ref;
            CGEventTapEnable(tap, 1);
        default:
            goto BAIL;
    }
    
    uint32_t flags = (uint32_t)CGEventGetFlags(event);
    uint8_t keycode = ConvertMacKey((uint16_t)CGEventGetIntegerValueField(event, kCGKeyboardEventKeycode));
    uint32_t mods = ConvertMacMod(flags);
    if (mods != MOD_SUPER || !(flags & NX_DEVICERCMDKEYMASK))
        goto BAIL;
    
    return NULL;
    
BAIL:
    return event;
}

int main(int argc, const char *argv[]) {
    if (geteuid()) {
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
    
    tap = CGEventTapCreate(kCGSessionEventTap, kCGHeadInsertEventTap, 0, CGEventMaskBit(kCGEventKeyDown) | CGEventMaskBit(kCGEventKeyUp), EventCallback, NULL);
    CFRunLoopSourceRef loop = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, tap, 0);
    CGEventTapEnable(tap, 1);
    CFRunLoopAddSource(CFRunLoopGetMain(), loop, kCFRunLoopCommonModes);
    CFRunLoopRun();
    return 0;
}
