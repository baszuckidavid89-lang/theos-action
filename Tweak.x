#import <UIKit/UIKit.h>
#import <mach-o/dyld.h>
#import <substrate.h>

typedef struct Vector3 {
    float x;
    float y;
    float z;
} Vector3;

@interface GameHelper : NSObject
+ (instancetype)shared;
- (Vector3)getCameraPosition;
- (void)spawnItem:(NSString *)name at:(Vector3)pos;
@property (nonatomic, assign) void* spawnMethod;
@end

@interface ModMenuController : UIViewController <UIPickerViewDelegate, UIPickerViewDataSource>
@property (nonatomic, strong) UIView *container;
@property (nonatomic, strong) UITextField *xIn, *yIn, *zIn, *qtyIn; // Added qtyIn
@property (nonatomic, strong) UIPickerView *itemPicker;
@property (nonatomic, strong) NSArray *availableItems;
@end

@implementation ModMenuController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.availableItems = @[@"stellarsword_blue", @"flamethrower_skull", @"rpg_smshr"]; 
    [self setupMenuUI];
}

- (void)setupMenuUI {
    self.container = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 350, 520)]; // Increased height
    self.container.backgroundColor = [UIColor colorWithWhite:0.05 alpha:0.95];
    self.container.layer.cornerRadius = 20;
    self.container.center = self.view.center;
    [self.view addSubview:self.container];

    // X, Y, Z Fields
    self.xIn = [self addField:@"X Coord" at:40];
    self.yIn = [self addField:@"Y Coord" at:80];
    self.zIn = [self addField:@"Z Coord" at:120];
    
    // Quantity Field
    self.qtyIn = [self addField:@"Quantity (e.g. 10)" at:160];
    self.qtyIn.text = @"1"; // Default to 1

    self.itemPicker = [[UIPickerView alloc] initWithFrame:CGRectMake(25, 200, 300, 150)];
    self.itemPicker.delegate = self;
    [self.container addSubview:self.itemPicker];

    UIButton *spawnBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    spawnBtn.frame = CGRectMake(75, 370, 200, 50);
    [spawnBtn setTitle:@"GENERATE ITEMS" forState:UIControlStateNormal];
    [spawnBtn addTarget:self action:@selector(handleSpawn) forControlEvents:UIControlEventTouchUpInside];
    [self.container addSubview:spawnBtn];
}

- (UITextField*)addField:(NSString*)ph at:(CGFloat)y {
    UITextField *t = [[UITextField alloc] initWithFrame:CGRectMake(75, y, 200, 30)];
    t.placeholder = ph;
    t.backgroundColor = [UIColor whiteColor];
    t.borderStyle = UITextBorderStyleRoundedRect;
    t.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
    [self.container addSubview:t];
    return t;
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
    
    // --- Quantity Loop ---
    int count = [self.qtyIn.text intValue];
    if (count <= 0) count = 1; // Safety check
    if (count > 100) count = 100; // Anti-crash limit

    for (int i = 0; i < count; i++) {
        // We add a tiny offset to each spawn so they don't occupy the exact same physics space
        Vector3 jitterPos = finalPos;
        jitterPos.x += (i * 0.1f); 
        
        [[GameHelper shared] spawnItem:selected at:jitterPos];
    }
}

// Landscape support
- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        self.container.center = CGPointMake(size.width / 2, size.height / 2);
    } completion:nil];
}

// Picker Boilerplate...
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView { return 1; }
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component { return self.availableItems.count; }
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component { return self.availableItems[row]; }
@end

%ctor {
    NSLog(@"[Astraeus] Spawner Ready with Quantity Support");
}
