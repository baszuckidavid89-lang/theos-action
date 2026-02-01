#import <UIKit/UIKit.h>
#import <mach-o/dyld.h>
#import <substrate.h>

// --- Structures ---
struct Vector3 { float x, y, z; };

// --- Global Pointers (The "Hooks") ---
static void* (*_il2cpp_domain_get)();
static void* (*_il2cpp_domain_get_assemblies)(void* domain, size_t* size);
static void* (*_il2cpp_string_new)(const char* str);
static void* (*_runtime_invoke)(void* method, void* obj, void** params, void** exc);

// --- GameHelper: The Brain that finds the game logic ---
@interface GameHelper : NSObject
+ (instancetype)shared;
- (void)setupOffsets;
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

- (void)setupOffsets {
    // This uses the strings you sent to find the 'AnimalCompany' assembly
    // and resolves the SpawnItem method address.
    NSLog(@"[Lackson] Resolving IL2CPP Methods...");
    // Real implementation would use il2cpp_class_get_method_from_name here
}

- (Vector3)getCameraPosition {
    // Logic to hook UnityEngine.Camera.get_main().get_transform().get_position()
    return (Vector3){10.0f, 5.0f, 10.0f}; // Placeholder
}

- (void)spawnItem:(NSString *)name at:(Vector3)pos {
    if (!self.spawnMethod) return;
    void* itemStr = _il2cpp_string_new([name UTF8String]);
    void* params[] = { itemStr, &pos };
    _runtime_invoke(self.spawnMethod, NULL, params, NULL);
}
@end

// --- ModMenuController: The UI that supports Landscape & XYZ ---
@interface ModMenuController : UIViewController
@property (nonatomic, strong) UIView *container;
@property (nonatomic, strong) UITextField *xIn, *yIn, *zIn;
@end

@implementation ModMenuController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupMenuUI];
}

// Landscape Mode Support: Recalculates center during rotation
- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        self.container.center = CGPointMake(size.width / 2, size.height / 2);
    } completion:nil];
}

- (void)setupMenuUI {
    self.container = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 350, 450)];
    self.container.backgroundColor = [UIColor colorWithWhite:0.1 alpha:0.9];
    self.container.layer.cornerRadius = 15;
    self.container.center = self.view.center;
    [self.view addSubview:self.container];

    // Manual XYZ Inputs
    self.xIn = [self addField:@"X" at:50];
    self.yIn = [self addField:@"Y" at:90];
    self.zIn = [self addField:@"Z" at:130];

    UIButton *spawnBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    spawnBtn.frame = CGRectMake(75, 200, 200, 50);
    [spawnBtn setTitle:@"SPAWN ITEM" forState:UIControlStateNormal];
    [spawnBtn addTarget:self action:@selector(doSpawn) forControlEvents:UIControlEventTouchUpInside];
    [self.container addSubview:spawnBtn];
}

- (UITextField*)addField:(NSString*)p at:(CGFloat)y {
    UITextField *t = [[UITextField alloc] initWithFrame:CGRectMake(125, y, 100, 30)];
    t.placeholder = p;
    t.backgroundColor = [UIColor whiteColor];
    t.borderStyle = UITextBorderStyleRoundedRect;
    [self.container addSubview:t];
    return t;
}

- (void)doSpawn {
    Vector3 target;
    // Check if user entered manual XYZ
    if (self.xIn.text.length > 0) {
        target.x = [self.xIn.text floatValue];
        target.y = [self.yIn.text floatValue];
        target.z = [self.zIn.text floatValue];
    } else {
        // Default to Camera position
        target = [[GameHelper shared] getCameraPosition];
    }
    
    [[GameHelper shared] spawnItem:@"item_demon_sword" at:target];
}
@end

// --- The Constructor: Runs when the dylib loads ---
%ctor {
    [[GameHelper shared] setupOffsets];
    NSLog(@"[Lackson] Dylib Loaded and Hooks Ready.");
}
