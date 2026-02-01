#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioServices.h>
#import <dlfcn.h>
#import <mach-o/dyld.h>

// --- STRUCTURES & POINTERS ---
typedef struct { float x, y, z; } Vector3;

static void* (*il2cpp_runtime_invoke)(void* method, void* obj, void** params, void** exc);
static void* (*il2cpp_string_new)(const char* str);
static void* (*spawnItemMethod);
static void* (*getLocalPlayer)();

// --- THE INTERFACE ---
@interface SpawnerMenu : UIView <UIPickerViewDelegate, UIPickerViewDataSource>
@property (nonatomic, strong) UIView *container;
@property (nonatomic, strong) UIPickerView *itemPicker;
@property (nonatomic, strong) NSArray *items;
@property (nonatomic, strong) NSString *selectedItem;
@property (nonatomic, strong) UIButton *spawnButton;
@end

@implementation SpawnerMenu

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Items pulled directly from your binary dump
        self.items = @[@"item_ac_cola", @"item_alphablade", @"item_anti_gravity_grenade", 
                       @"item_arena_pistol", @"item_arena_shotgun", @"item_axe", 
                       @"item_banana", @"item_boombox", @"item_flamethrower", 
                       @"item_goldbar", @"item_jetpack", @"item_landmine",
                       @"item_moneygun", @"item_rpg_ammo", @"item_clapper"];
        self.selectedItem = self.items[0];
        [self setupUI];
        [self initIL2CPP];
    }
    return self;
}

- (void)initIL2CPP {
    void* handle = dlopen(NULL, RTLD_NOW);
    il2cpp_runtime_invoke = (void*(*)(void*, void*, void**, void**))dlsym(handle, "il2cpp_runtime_invoke");
    il2cpp_string_new = (void*(*)(const char*))dlsym(handle, "il2cpp_string_new");
    
    // Resolving offsets from your Linker Map
    spawnItemMethod = dlsym(handle, "_spawnItemMethod"); 
    getLocalPlayer = (void*(*)())dlsym(handle, "_getLocalPlayerMethod");
}

- (void)executeSpawn {
    void* player = getLocalPlayer();
    if (!player || !spawnItemMethod) return;

    // Convert item ID to Unity String format
    void* unityItemName = il2cpp_string_new([self.selectedItem UTF8String]);

    // Coordinates: Spawning at origin or camera offset (0,0,0 as base)
    Vector3 spawnPos = {0.0f, 1.0f, 0.0f}; 
    
    // Injecting the RPC through the established network tunnel
    void* args[] = { unityItemName, &spawnPos };
    il2cpp_runtime_invoke(spawnItemMethod, NULL, args, NULL);

    // Haptic Feedback for the iPhone 11 Pro Max
    AudioServicesPlaySystemSound(1521);
}

- (void)setupUI {
    self.container = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 300, 350)];
    self.container.center = self.center;
    self.container.backgroundColor = [UIColor colorWithRed:0.05 green:0.05 blue:0.1 alpha:0.95];
    self.container.layer.cornerRadius = 25;
    self.container.layer.borderWidth = 1.5;
    self.container.layer.borderColor = [UIColor cyanColor].CGColor;
    [self addSubview:self.container];

    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, 300, 40)];
    title.text = @"AC MATERIALIZER";
    title.textColor = [UIColor cyanColor];
    title.textAlignment = NSTextAlignmentCenter;
    title.font = [UIFont boldSystemFontOfSize:18];
    [self.container addSubview:title];

    self.itemPicker = [[UIPickerView alloc] initWithFrame:CGRectMake(10, 50, 280, 150)];
    self.itemPicker.delegate = self;
    self.itemPicker.dataSource = self;
    [self.container addSubview:self.itemPicker];

    self.spawnButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.spawnButton.frame = CGRectMake(50, 240, 200, 60);
    [self.spawnButton setTitle:@"SPAWN IN VR" forState:UIControlStateNormal];
    self.spawnButton.backgroundColor = [UIColor cyanColor];
    [self.spawnButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    self.spawnButton.titleLabel.font = [UIFont boldSystemFontOfSize:20];
    self.spawnButton.layer.cornerRadius = 15;
    [self.spawnButton addTarget:self action:@selector(executeSpawn) forControlEvents:UIControlEventTouchUpInside];
    [self.container addSubview:self.spawnButton];
}

// Picker Delegate Methods
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView { return 1; }
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component { return self.items.count; }
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component { return self.items[row]; }
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component { self.selectedItem = self.items[row]; }

- (void)toggle { self.hidden = !self.hidden; }
@end

static SpawnerMenu *menu;
%ctor {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        UIWindow *win = [UIApplication sharedApplication].keyWindow;
        menu = [[SpawnerMenu alloc] initWithFrame:win.bounds];
        menu.hidden = YES;
        [win addSubview:menu];

        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(20, 100, 50, 50);
        btn.backgroundColor = [UIColor cyanColor];
        btn.layer.cornerRadius = 25;
        [btn setTitle:@"M" forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [btn addTarget:menu action:@selector(toggle) forControlEvents:UIControlEventTouchUpInside];
        [win addSubview:btn];
    });
}
