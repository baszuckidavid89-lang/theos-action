#import <UIKit/UIKit.h>
#import <mach-o/dyld.h>
#import <substrate.h>

// --- Structs & Helpers ---
typedef struct Vector3 {
    float x;
    float y;
    float z;
} Vector3;

@interface GameHelper : NSObject
+ (instancetype)shared;
- (Vector3)getCameraPosition;
- (void)spawnItem:(NSString *)name at:(Vector3)pos;
@end

// --- Mod Menu Controller ---
@interface ModMenuController : UIViewController <UIPickerViewDelegate, UIPickerViewDataSource>
@property (nonatomic, strong) UIView *container;
@property (nonatomic, strong) UIButton *menuToggleButton;
@property (nonatomic, strong) UITextField *xIn, *yIn, *zIn, *qtyIn;
@property (nonatomic, strong) UIPickerView *itemPicker;
@property (nonatomic, strong) NSArray *availableItems;
@end

@implementation ModMenuController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.availableItems = @[@"stellarsword_blue", @"flamethrower_skull", @"rpg_smshr", @"item_backpack"]; 
    [self setupUI];
}

- (void)setupUI {
    // 1. Floating Toggle Button (Visible when menu is closed)
    self.menuToggleButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.menuToggleButton.frame = CGRectMake(40, 40, 70, 40);
    [self.menuToggleButton setTitle:@"MENU" forState:UIControlStateNormal];
    self.menuToggleButton.backgroundColor = [[UIColor purpleColor] colorWithAlphaComponent:0.8];
    [self.menuToggleButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.menuToggleButton.layer.cornerRadius = 10;
    self.menuToggleButton.hidden = YES; // Hidden when menu is open
    [self.menuToggleButton addTarget:self action:@selector(toggleMenu) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.menuToggleButton];

    // 2. Main Menu Container
    self.container = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 350, 520)];
    self.container.backgroundColor = [UIColor colorWithWhite:0.05 alpha:0.95];
    self.container.layer.cornerRadius = 20;
    self.container.layer.borderWidth = 1.5;
    self.container.layer.borderColor = [UIColor purpleColor].CGColor;
    self.container.center = self.view.center;
    [self.view addSubview:self.container];

    // Close Button
    UIButton *closeBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    closeBtn.frame = CGRectMake(310, 10, 30, 30);
    [closeBtn setTitle:@"X" forState:UIControlStateNormal];
    [closeBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [closeBtn addTarget:self action:@selector(toggleMenu) forControlEvents:UIControlEventTouchUpInside];
    [self.container addSubview:closeBtn];

    // Inputs (X, Y, Z, Qty)
    self.xIn = [self addField:@"X Coord" at:50];
    self.yIn = [self addField:@"Y Coord" at:90];
    self.zIn = [self addField:@"Z Coord" at:130];
    self.qtyIn = [self addField:@"Quantity (1-100)" at:170];
    self.qtyIn.text = @"1";

    // Item Picker
    self.itemPicker = [[UIPickerView alloc] initWithFrame:CGRectMake(25, 210, 300, 150)];
    self.itemPicker.delegate = self;
    [self.container addSubview:self.itemPicker];

    // Spawn Button
    UIButton *spawnBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    spawnBtn.frame = CGRectMake(75, 430, 200, 50);
    [spawnBtn setTitle:@"SPAWN ITEMS" forState:UIControlStateNormal];
    spawnBtn.backgroundColor = [UIColor greenColor];
    [spawnBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    spawnBtn.layer.cornerRadius = 12;
    [spawnBtn addTarget:self action:@selector(handleSpawn) forControlEvents:UIControlEventTouchUpInside];
    [self.container addSubview:spawnBtn];
}

- (UITextField*)addField:(NSString*)ph at:(CGFloat)y {
    UITextField *t = [[UITextField alloc] initWithFrame:CGRectMake(75, y, 200, 35)];
    t.placeholder = ph;
    t.backgroundColor = [UIColor whiteColor];
    t.borderStyle = UITextBorderStyleRoundedRect;
    t.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
    [self.container addSubview:t];
    return t;
}

- (void)toggleMenu {
    BOOL isCurrentlyHidden = self.container.hidden;
    self.container.hidden = !isCurrentlyHidden;
    self.menuToggleButton.hidden = isCurrentlyHidden;
    [self.view endEditing:YES];
}

- (void)handleSpawn {
    Vector3 finalPos;
    if (self.xIn.text.length > 0) {
        finalPos.x = [self.xIn.text floatValue];
        finalPos.y = [self.yIn.text floatValue];
        finalPos.z = [self.zIn.text floatValue];
    } else {
        finalPos = [[GameHelper shared] getCameraPosition];
    }

    NSString *selected = self.availableItems[[self.itemPicker selectedRowInComponent:0]];
    int count = [self.qtyIn.text intValue];
    if (count <= 0) count = 1;
    if (count > 100) count = 100;

    for (int i = 0; i < count; i++) {
        Vector3 jitter = finalPos;
        jitter.x += (i * 0.15f); // Tiny offset to prevent physics crash
        [[GameHelper shared] spawnItem:selected at:jitter];
    }
}

// Support Landscape Rotation
- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        self.container.center = CGPointMake(size.width / 2, size.height / 2);
    } completion:nil];
}

// Picker Delegates
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView { return 1; }
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component { return self.availableItems.count; }
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component { return self.availableItems[row]; }

@end

%ctor {
    NSLog(@"[Astraeus] Fully Featured Menu Loaded");
}
