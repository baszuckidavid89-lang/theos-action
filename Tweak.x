#import <UIKit/UIKit.h>
#import <mach-o/dyld.h>
#import <substrate.h>

// --- 1. Fix: Proper Struct Typedef for Compiler ---
typedef struct Vector3 {
    float x;
    float y;
    float z;
} Vector3;

// --- 2. Interface Declarations ---
@interface GameHelper : NSObject
+ (instancetype)shared;
- (void)setupOffsets;
- (Vector3)getCameraPosition;
- (void)spawnItem:(NSString *)name at:(Vector3)pos;
@property (nonatomic, assign) void* spawnMethod;
@property (nonatomic, assign) void* il2cpp_string_new_ptr;
@property (nonatomic, assign) void* runtime_invoke_ptr;
@end

@interface ModMenuController : UIViewController <UIPickerViewDelegate, UIPickerViewDataSource>
@property (nonatomic, strong) UIView *container;
@property (nonatomic, strong) UITextField *xIn, *yIn, *zIn;
@property (nonatomic, strong) UIPickerView *itemPicker;
@property (nonatomic, strong) NSArray *availableItems;
@property (nonatomic, assign) BOOL isUnlocked;
@end

// --- 3. GameHelper Implementation ---
@implementation GameHelper
+ (instancetype)shared {
    static GameHelper *inst;
    static dispatch_once_t once;
    dispatch_once(&once, ^{ inst = [[GameHelper alloc] init]; });
    return inst;
}

- (void)setupOffsets {
    // These would be resolved via dlsym or your Resolver logic
    self.il2cpp_string_new_ptr = dlsym(RTLD_DEFAULT, "il2cpp_string_new");
    self.runtime_invoke_ptr = dlsym(RTLD_DEFAULT, "il2cpp_runtime_invoke");
    // self.spawnMethod = resolve spawn method here...
}

- (Vector3)getCameraPosition {
    // Placeholder: In real use, you'd hook Camera.get_main
    return (Vector3){0.0f, 0.0f, 0.0f};
}

- (void)spawnItem:(NSString *)name at:(Vector3)pos {
    if (!self.spawnMethod || !self.il2cpp_string_new_ptr) return;
    
    // Convert NSString to IL2CPP String
    void* (*_strNew)(const char*) = (void*(*)(const char*))self.il2cpp_string_new_ptr;
    void* il2cppStr = _strNew([name UTF8String]);
    
    // Setup params for runtime_invoke
    void* params[] = { il2cppStr, &pos };
    void* (*_invoke)(void*, void*, void**, void**) = (void*(*)(void*, void*, void**, void**))self.runtime_invoke_ptr;
    _invoke(self.spawnMethod, NULL, params, NULL);
}
@end

// --- 4. UI Implementation with Landscape & XYZ Support ---
@implementation ModMenuController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.availableItems = @[@"stellarsword_blue", @"flamethrower_skull", @"rpg_smshr", @"teleport_gun"]; 
    [self setupMenuUI];
}

// Fix: Support Landscape Orientation
- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        self.container.center = CGPointMake(size.width / 2, size.height / 2);
    } completion:nil];
}

- (void)setupMenuUI {
    self.container = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 350, 480)];
    self.container.backgroundColor = [UIColor colorWithRed:0.05 green:0.05 blue:0.05 alpha:0.95];
    self.container.layer.cornerRadius = 20;
    self.container.layer.borderWidth = 2;
    self.container.layer.borderColor = [UIColor purpleColor].CGColor;
    self.container.center = self.view.center;
    [self.view addSubview:self.container];

    // X, Y, Z Fields
    self.xIn = [self addField:@"X Coordinate" at:40];
    self.yIn = [self addField:@"Y Coordinate" at:80];
    self.zIn = [self addField:@"Z Coordinate" at:120];

    // Item Picker
    self.itemPicker = [[UIPickerView alloc] initWithFrame:CGRectMake(25, 160, 300, 150)];
    self.itemPicker.delegate = self;
    self.itemPicker.dataSource = self;
    [self.container addSubview:self.itemPicker];

    // Action Button
    UIButton *spawnBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    spawnBtn.frame = CGRectMake(75, 330, 200, 50);
    [spawnBtn setTitle:@"GENERATE ITEM" forState:UIControlStateNormal];
    [spawnBtn setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
    [spawnBtn addTarget:self action:@selector(handleSpawn) forControlEvents:UIControlEventTouchUpInside];
    [self.container addSubview:spawnBtn];
}

- (UITextField*)addField:(NSString*)placeholder at:(CGFloat)y {
    UITextField *t = [[UITextField alloc] initWithFrame:CGRectMake(75, y, 200, 30)];
    t.placeholder = placeholder;
    t.backgroundColor = [UIColor whiteColor];
    t.borderStyle = UITextBorderStyleRoundedRect;
    t.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
    [self.container addSubview:t];
    return t;
}

- (void)handleSpawn {
    Vector3 finalPos;
    // logic: If X field is used, use manual coords. If empty, use Camera.
    if (self.xIn.text.length > 0) {
        finalPos.x = [self.xIn.text floatValue];
        finalPos.y = [self.yIn.text floatValue];
        finalPos.z = [self.zIn.text floatValue];
    } else {
        finalPos = [[GameHelper shared] getCameraPosition];
    }

    NSString *selected = self.availableItems[[self.itemPicker selectedRowInComponent:0]];
    [[GameHelper shared] spawnItem:selected at:finalPos];
}

// Picker Boilerplate
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView { return 1; }
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component { return self.availableItems.count; }
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component { return self.availableItems[row]; }

@end

// --- 5. Tweak Entry Point ---
%ctor {
    [[GameHelper shared] setupOffsets];
    NSLog(@"[Astraeus] Mod Menu Initialized");
}
