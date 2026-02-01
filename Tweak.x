#import <UIKit/UIKit.h>
#import <mach-o/dyld.h>
#import <substrate.h>

// --- 1. Vector3 Struct for Unity Math ---
typedef struct Vector3 {
    float x; float y; float z;
} Vector3;

// --- 2. GameHelper Interface ---
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
    // Logic to call il2cpp_runtime_invoke with name and pos
}
@end

// --- 3. Mod Menu Controller ---
@interface ModMenuController : UIViewController <UIPickerViewDelegate, UIPickerViewDataSource>
@property (nonatomic, strong) UIView *container;
@property (nonatomic, strong) UIButton *menuToggleButton;
@property (nonatomic, strong) UITextField *xIn, *yIn, *zIn;
@property (nonatomic, strong) UISlider *qtySlider;
@property (nonatomic, strong) UILabel *qtyLabel;
@property (nonatomic, strong) UIPickerView *itemPicker;
@property (nonatomic, strong) NSArray *availableItems;
@end

@implementation ModMenuController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Paste your items here
    self.availableItems = @[@"stellarsword_blue", @"flamethrower_skull", @"rpg_smshr", @"item_backpack"];
    
    [self setupToggleButton];
    [self setupMainSection];
}

- (void)setupToggleButton {
    // iPhone 11 Pro Max Safe Position
    self.menuToggleButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.menuToggleButton.frame = CGRectMake(50, 100, 80, 45); 
    [self.menuToggleButton setTitle:@"ASTRAEUS" forState:UIControlStateNormal];
    self.menuToggleButton.backgroundColor = [[UIColor purpleColor] colorWithAlphaComponent:0.9];
    [self.menuToggleButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.menuToggleButton.layer.cornerRadius = 12;
    self.menuToggleButton.layer.borderWidth = 1.5;
    self.menuToggleButton.layer.borderColor = [UIColor whiteColor].CGColor;
    
    // Draggable Logic
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleDrag:)];
    [self.menuToggleButton addGestureRecognizer:pan];
    [self.menuToggleButton addTarget:self action:@selector(toggleMenu) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:self.menuToggleButton];
}

- (void)handleDrag:(UIPanGestureRecognizer *)p {
    CGPoint translation = [p translationInView:self.view];
    self.menuToggleButton.center = CGPointMake(self.menuToggleButton.center.x + translation.x, 
                                               self.menuToggleButton.center.y + translation.y);
    [p setTranslation:CGPointZero inView:self.view];
}

- (void)setupMainSection {
    self.container = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 340, 540)];
    self.container.backgroundColor = [UIColor colorWithWhite:0.05 alpha:0.95];
    self.container.layer.cornerRadius = 25;
    self.container.layer.borderColor = [UIColor purpleColor].CGColor;
    self.container.layer.borderWidth = 2.5;
    self.container.center = self.view.center;
    self.container.hidden = YES; 
    [self.view addSubview:self.container];

    // Close Button
    UIButton *close = [[UIButton alloc] initWithFrame:CGRectMake(300, 15, 30, 30)];
    [close setTitle:@"✕" forState:UIControlStateNormal];
    [close setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [close addTarget:self action:@selector(toggleMenu) forControlEvents:UIControlEventTouchUpInside];
    [self.container addSubview:close];

    // XYZ Override Fields
    self.xIn = [self addField:@"X Offset" at:60];
    self.yIn = [self addField:@"Y Offset" at:100];
    self.zIn = [self addField:@"Z Offset" at:140];

    // Quantity Slider (1 to 50)
    self.qtyLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 185, 300, 20)];
    self.qtyLabel.text = @"Quantity: 1";
    self.qtyLabel.textColor = [UIColor whiteColor];
    self.qtyLabel.textAlignment = NSTextAlignmentCenter;
    [self.container addSubview:self.qtyLabel];

    self.qtySlider = [[UISlider alloc] initWithFrame:CGRectMake(40, 210, 260, 30)];
    self.qtySlider.minimumValue = 1;
    self.qtySlider.maximumValue = 50;
    self.qtySlider.value = 1;
    self.qtySlider.minimumTrackTintColor = [UIColor purpleColor];
    [self.qtySlider addTarget:self action:@selector(sliderChanged:) forControlEvents:UIControlEventValueChanged];
    [self.container addSubview:self.qtySlider];

    // Picker View
    self.itemPicker = [[UIPickerView alloc] initWithFrame:CGRectMake(10, 250, 320, 140)];
    self.itemPicker.delegate = self;
    self.itemPicker.dataSource = self;
    [self.container addSubview:self.itemPicker];

    // Big Generate Button
    UIButton *spawnBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    spawnBtn.frame = CGRectMake(70, 420, 200, 55);
    [spawnBtn setTitle:@"GENERATE ITEMS" forState:UIControlStateNormal];
    spawnBtn.backgroundColor = [UIColor greenColor];
    [spawnBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    spawnBtn.titleLabel.font = [UIFont boldSystemFontOfSize:18];
    spawnBtn.layer.cornerRadius = 15;
    [spawnBtn addTarget:self action:@selector(doSpawn) forControlEvents:UIControlEventTouchUpInside];
    [self.container addSubview:spawnBtn];
}

- (UITextField*)addField:(NSString*)ph at:(CGFloat)y {
    UITextField *t = [[UITextField alloc] initWithFrame:CGRectMake(70, y, 200, 32)];
    t.placeholder = ph;
    t.backgroundColor = [UIColor whiteColor];
    t.borderStyle = UITextBorderStyleRoundedRect;
    t.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
    [self.container addSubview:t];
    return t;
}

- (void)sliderChanged:(UISlider *)sender {
    int val = (int)sender.value;
    self.qtyLabel.text = [NSString stringWithFormat:@"Quantity: %d", val];
}

- (void)toggleMenu {
    self.container.hidden = !self.container.hidden;
    [self.view endEditing:YES];
}

- (void)doSpawn {
    Vector3 pos;
    if (self.xIn.text.length > 0) {
        pos.x = [self.xIn.text floatValue];
        pos.y = [self.yIn.text floatValue];
        pos.z = [self.zIn.text floatValue];
    } else {
        pos = [[GameHelper shared] getCameraPosition];
    }

    NSString *selectedID = self.availableItems[[self.itemPicker selectedRowInComponent:0]];
    int count = (int)self.qtySlider.value;

    for (int i = 0; i < count; i++) {
        Vector3 jitter = pos;
        jitter.x += (i * 0.12f); // Prevent physics explosions
        [[GameHelper shared] spawnItem:selectedID at:jitter];
    }
}

// --- UIPickerView Implementation ---
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)p { return 1; }
- (NSInteger)pickerView:(UIPickerView *)p numberOfRowsInComponent:(NSInteger)c { return self.availableItems.count; }
- (NSString *)pickerView:(UIPickerView *)p titleForRow:(NSInteger)r forComponent:(NSInteger)c { return self.availableItems[r]; }

// --- Orientation Handling ---
- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coord {
    [super viewWillTransitionToSize:size withTransitionCoordinator:coord];
    [coord animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> ctx) {
        self.container.center = CGPointMake(size.width / 2, size.height / 2);
    } completion:nil];
}
@end

// --- 4. Tweak Entry Hook ---
%hook UnityFramework
- (void)onUnityUpdate {
    %orig;
    static dispatch_once_t t;
    dispatch_once(&t, ^{
        ModMenuController *m = [[ModMenuController alloc] init];
        UIWindow *w = [[UIApplication sharedApplication] keyWindow];
        [w.rootViewController addChildViewController:m];
        [w addSubview:m.view];
    });
}
%end

%ctor {
    NSLog(@"[Astraeus] Fully Featured Menu Initialized for iPhone 11 Pro Max.");
}
