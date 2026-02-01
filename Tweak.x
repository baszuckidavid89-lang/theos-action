#import <UIKit/UIKit.h>
#import <mach-o/dyld.h>
#import <substrate.h>

typedef struct Vector3 {
    float x; float y; float z;
} Vector3;

// --- 1. GameHelper Implementation (The missing piece) ---
@interface GameHelper : NSObject
+ (instancetype)shared;
- (Vector3)getCameraPosition;
- (void)spawnItem:(NSString *)name at:(Vector3)pos;
@property (nonatomic, assign) void* spawnMethod;
@end

@implementation GameHelper
+ (instancetype)shared {
    static GameHelper *inst;
    static dispatch_once_t once;
    dispatch_once(&once, ^{ inst = [[GameHelper alloc] init]; });
    return inst;
}

- (Vector3)getCameraPosition {
    // This is where you would normally call the Unity Camera hook
    return (Vector3){0, 0, 0}; 
}

- (void)spawnItem:(NSString *)name at:(Vector3)pos {
    // We use MSFindSymbol to get il2cpp functions at runtime
    void* (*_il2cpp_string_new)(const char*) = (void*(*)(const char*))MSFindSymbol(NULL, "il2cpp_string_new");
    void* (*_runtime_invoke)(void*, void*, void**, void**) = (void*(*)(void*, void*, void**, void**))MSFindSymbol(NULL, "il2cpp_runtime_invoke");

    if (_il2cpp_string_new && _runtime_invoke && self.spawnMethod) {
        void* il2cppStr = _il2cpp_string_new([name UTF8String]);
        void* params[] = { il2cppStr, &pos };
        _runtime_invoke(self.spawnMethod, NULL, params, NULL);
    }
}
@end

// --- 2. ModMenuController Implementation ---
@interface ModMenuController : UIViewController <UIPickerViewDelegate, UIPickerViewDataSource>
@property (nonatomic, strong) UIView *container;
@property (nonatomic, strong) UIButton *menuToggleButton;
@property (nonatomic, strong) UITextField *xIn, *yIn, *zIn, *qtyIn;
@property (nonatomic, strong) UIPickerView *itemPicker;
@property (nonatomic, strong) NSArray *availableItems;
@end

@implementation ModMenuController
// ... Keep your existing viewDidLoad, setupUI, handleSpawn, and toggleMenu logic here ...
// Make sure to call [[GameHelper shared] spawnItem:selected at:jitter];
- (void)viewDidLoad {
    [super viewDidLoad];
    self.availableItems = @[@"stellarsword_blue", @"flamethrower_skull", @"rpg_smshr"];
    // [self setupUI] etc...
}
@end

// --- 3. Hooking Unity to show the menu ---
%hook UnityFramework
- (void)onUnityUpdate { // Or a similar game loop method
    %orig;
    static BOOL created = NO;
    if (!created) {
        ModMenuController *menu = [[ModMenuController alloc] init];
        [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:menu animated:YES completion:nil];
        created = YES;
    }
}
%end

%ctor {
    NSLog(@"[Astraeus] Linker Fixed & Implementation Loaded.");
}
