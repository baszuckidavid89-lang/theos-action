#import <UIKit/UIKit.h>
#import <mach-o/dyld.h>
#import <substrate.h>

typedef struct Vector3 {
    float x; float y; float z;
} Vector3;

// --- GameHelper Implementation ---
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
- (Vector3)getCameraPosition { return (Vector3){0, 0, 0}; }
- (void)spawnItem:(NSString *)name at:(Vector3)pos {
    // Logic to call il2cpp_runtime_invoke
}
@end

// --- ModMenuController Implementation ---
@interface ModMenuController : UIViewController <UIPickerViewDelegate, UIPickerViewDataSource>
@property (nonatomic, strong) UIView *container;
@property (nonatomic, strong) UITextField *xIn, *yIn, *zIn, *qtyIn;
@property (nonatomic, strong) UIPickerView *itemPicker;
@property (nonatomic, strong) NSArray *availableItems;
@end

@implementation ModMenuController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.availableItems = @[@"stellarsword_blue", @"flamethrower_skull", @"rpg_smshr"];
    [self setupMenuUI];
}

// --- MANDATORY PICKER DATA SOURCE METHODS (Fixes Build Error) ---
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1; // One column of items
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return self.availableItems.count; // Number of items in our list
}

// --- PICKER DELEGATE METHODS ---
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return self.availableItems[row];
}

// --- UI AND LOGIC ---
- (void)setupMenuUI {
    self.container = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 350, 520)];
    self.container.backgroundColor = [UIColor blackColor];
    self.container.center = self.view.center;
    [self.view addSubview:self.container];

    self.itemPicker = [[UIPickerView alloc] initWithFrame:CGRectMake(25, 200, 300, 150)];
    self.itemPicker.delegate = self;
    self.itemPicker.dataSource = self; // Contract signed
    [self.container addSubview:self.itemPicker];
    
    // ... rest of your UI (Inputs, Buttons) ...
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        self.container.center = CGPointMake(size.width / 2, size.height / 2);
    } completion:nil];
}

@end

%ctor {
    NSLog(@"[Astraeus] Picker methods implemented. Build should succeed.");
}
