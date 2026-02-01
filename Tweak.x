#import <UIKit/UIKit.h>
#import <mach-o/dyld.h>
#import <substrate.h>

// Vector3 structure used by Unity/IL2CPP games
typedef struct Vector3 { float x; float y; float z; } Vector3;

// --- 1. THE SPAWNING SYSTEM ---
@interface GameHelper : NSObject
+ (instancetype)shared;
- (void)spawnItem:(NSString *)name at:(Vector3)pos;
@end

@implementation GameHelper
+ (instancetype)shared {
    static GameHelper *inst;
    static dispatch_once_t once;
    dispatch_once(&once, ^{ inst = [[GameHelper alloc] init]; });
    return inst;
}

// This is the core feature you asked for
- (void)spawnItem:(NSString *)name at:(Vector3)pos {
    // Note: To make this work ingame, you must use an IL2CPP Resolver 
    // to find the 'CreateObject' or 'Spawn' function in the game's memory.
    NSLog(@"[Astraeus] Attempting to spawn: %@ at X:%.2f Y:%.2f Z:%.2f", name, pos.x, pos.y, pos.z);
}
@end

// --- 2. THE UI CONTROLLER ---
@interface ModMenuController : UIViewController <UIPickerViewDelegate, UIPickerViewDataSource>
@property (nonatomic, strong) UIView *container;
@property (nonatomic, strong) UIButton *circleButton;
@property (nonatomic, strong) UITextField *xIn, *yIn, *zIn;
@property (nonatomic, strong) UISlider *qtySlider;
@property (nonatomic, strong) UILabel *qtyLabel;
@property (nonatomic, strong) UIPickerView *itemPicker;
@property (nonatomic, strong) NSArray *availableItems;
@end

@implementation ModMenuController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // THE ITEM IDS YOU REQUESTED
    self.availableItems = @[
        @"stellarsword_blue", 
        @"flamethrower_skull", 
        @"rpg_smshr", 
        @"item_backpack"
    ];
    
    [self setupCircleButton];
    [self setupMainSection];
}

- (void)setupCircleButton {
    self.circleButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.circleButton.frame = CGRectMake(40, 80, 70, 70); // Top-left safe area
    self.circleButton.backgroundColor = [UIColor purpleColor];
    self.circleButton.layer.cornerRadius = 35; // Circular
    self.circleButton.layer.borderWidth = 2;
    self.circleButton.layer.borderColor = [UIColor whiteColor].CGColor;
    [self.circleButton setTitle:@"M" forState:UIControlStateNormal];
    
    // Dragging Logic
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleDrag:)];
    [self.circleButton addGestureRecognizer:pan];
    [self.circleButton addTarget:self action:@selector(toggleMenu) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:self.circleButton];
}

- (void)handleDrag:(UIPanGestureRecognizer *)p {
    CGPoint translation = [p translationInView:self.view];
    self.circleButton.center = CGPointMake(self.circleButton.center.x + translation.x, 
                                          self.circleButton.center.y + translation.y);
    [p setTranslation:CGPointZero inView:self.view];
}

- (void)setupMainSection {
    self.container = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 500)];
    self.container.backgroundColor = [UIColor colorWithWhite:0.1 alpha:0.95];
    self.container.layer.cornerRadius = 20;
    self.container.center = self.view.center;
    self.container.hidden = YES;
    [self.view addSubview:self.container];

    // Close Button
    UIButton *close = [[UIButton alloc] initWithFrame:CGRectMake(280, 10, 30, 30)];
    [close setTitle:@"X" forState:UIControlStateNormal];
    [close setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [close addTarget:self action:@selector(toggleMenu) forControlEvents:UIControlEventTouchUpInside];
    [self.container addSubview:close];

    // XYZ Fields
    self.xIn = [self addField:@"X" at:60];
    self.yIn = [self addField:@"Y" at:100];
    self.zIn = [self addField:@"Z" at:140];

    // Quantity Slider (The feature u asked for)
    self.qtyLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 180, 300, 20)];
    self.qtyLabel.textColor = [UIColor whiteColor];
    self.qtyLabel.textAlignment = NSTextAlignmentCenter;
    self.qtyLabel.text = @"Qty: 1";
    [self.container addSubview:self.qtyLabel];

    self.qtySlider = [[UISlider alloc] initWithFrame:CGRectMake(40, 200, 240, 30)];
    self.qtySlider.minimumValue = 1;
    self.qtySlider.maximumValue = 100;
    [self.qtySlider addTarget:self action:@selector(qChanged) forControlEvents:UIControlEventValueChanged];
    [self.container addSubview:self.qtySlider];

    // Picker
    self.itemPicker = [[UIPickerView alloc] initWithFrame:CGRectMake(10, 240, 300, 120)];
    self.itemPicker.delegate = self;
    self.itemPicker.dataSource = self;
    [self.container addSubview:self.itemPicker];

    // Spawn Button
    UIButton *spawn = [[UIButton alloc] initWithFrame:CGRectMake(60, 400, 200, 50)];
    spawn.backgroundColor = [UIColor greenColor];
    [spawn setTitle:@"SPAWN" forState:UIControlStateNormal];
    [spawn addTarget:self action:@selector(onSpawn) forControlEvents:UIControlEventTouchUpInside];
    [self.container addSubview:spawn];
}

- (UITextField*)addField:(NSString*)ph at:(CGFloat)y {
    UITextField *f = [[UITextField alloc] initWithFrame:CGRectMake(60, y, 200, 30)];
    f.placeholder = ph; f.backgroundColor = [UIColor whiteColor];
    f.borderStyle = UITextBorderStyleRoundedRect;
    [self.container addSubview:f];
    return f;
}

- (void)qChanged { self.qtyLabel.text = [NSString stringWithFormat:@"Qty: %d", (int)self.qtySlider.value]; }

- (void)toggleMenu { self.container.hidden = !self.container.hidden; }

- (void)onSpawn {
    Vector3 p = {[self.xIn.text floatValue], [self.yIn.text floatValue], [self.zIn.text floatValue]};
    int q = (int)self.qtySlider.value;
    NSString *name = self.availableItems[[self.itemPicker selectedRowInComponent:0]];
    for(int i=0; i<q; i++) {
        [[GameHelper shared] spawnItem:name at:p];
    }
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)p { return 1; }
- (NSInteger)pickerView:(UIPickerView *)p numberOfRowsInComponent:(NSInteger)c { return self.availableItems.count; }
- (NSString *)pickerView:(UIPickerView *)p titleForRow:(NSInteger)r forComponent:(NSInteger)c { return self.availableItems[r]; }
@end

// --- 3. THE SAFE INJECTOR (Prevents Launch Crashes) ---
%ctor {
    // Wait for the app to actually be visible before injecting the UI
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        UIWindow *window = [UIApplication sharedApplication].keyWindow;
        if (window) {
            ModMenuController *vc = [[ModMenuController alloc] init];
            [window addSubview:vc.view];
            [window.rootViewController addChildViewController:vc];
        }
    });
}
