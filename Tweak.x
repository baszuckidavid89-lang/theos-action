#import <UIKit/UIKit.h>
#import <mach-o/dyld.h>
#import <substrate.h>

typedef struct Vector3 { float x; float y; float z; } Vector3;

// --- CUSTOM PASSTHROUGH WINDOW ---
@interface AstraeusWindow : UIWindow @end
@implementation AstraeusWindow
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *hitView = [super hitTest:point withEvent:event];
    // If the hit is the background window itself, or the root view, return nil to pass touch to game
    if (hitView == self || hitView == self.rootViewController.view) {
        return nil; 
    }
    return hitView; // Otherwise, let the user touch the buttons/sliders
}
@end

// --- Mod Menu Controller ---
@interface ModMenuController : UIViewController <UIPickerViewDelegate, UIPickerViewDataSource>
@property (nonatomic, strong) UIVisualEffectView *blurContainer;
@property (nonatomic, strong) UIButton *circleButton;
@property (nonatomic, strong) UITextField *xField, *yField, *zField;
@property (nonatomic, strong) UISlider *qtySlider;
@property (nonatomic, strong) UILabel *qtyLabel;
@property (nonatomic, strong) UIPickerView *itemPicker;
@property (nonatomic, strong) NSArray *availableItems;
@end

@implementation ModMenuController

- (void)viewDidLoad {
    [super viewDidLoad];
    // CLEAR BACKGROUND is essential so you can see the game!
    self.view.backgroundColor = [UIColor clearColor];
    self.availableItems = @[@"stellarsword_blue", @"flamethrower_skull", @"rpg_smshr", @"item_backpack"];
    
    [self setupCircleButton];
    [self setupMainSection];
}

- (void)setupCircleButton {
    self.circleButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.circleButton.frame = CGRectMake(40, 80, 65, 65);
    self.circleButton.backgroundColor = [UIColor purpleColor];
    self.circleButton.layer.cornerRadius = 32.5; 
    self.circleButton.layer.borderWidth = 2;
    self.circleButton.layer.borderColor = [UIColor whiteColor].CGColor;
    [self.circleButton setTitle:@"A" forState:UIControlStateNormal];
    self.circleButton.titleLabel.font = [UIFont boldSystemFontOfSize:24];
    
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleDrag:)];
    [self.circleButton addGestureRecognizer:pan];
    [self.circleButton addTarget:self action:@selector(toggleMenu) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.circleButton];
}

- (void)handleDrag:(UIPanGestureRecognizer *)p {
    CGPoint translation = [p translationInView:self.view];
    self.circleButton.center = CGPointMake(self.circleButton.center.x + translation.x, self.circleButton.center.y + translation.y);
    [p setTranslation:CGPointZero inView:self.view];
}

- (void)setupMainSection {
    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    self.blurContainer = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    self.blurContainer.frame = CGRectMake(0, 0, 320, 520);
    self.blurContainer.center = self.view.center;
    self.blurContainer.layer.cornerRadius = 30;
    self.blurContainer.layer.masksToBounds = YES;
    self.blurContainer.layer.borderColor = [[UIColor purpleColor] CGColor];
    self.blurContainer.layer.borderWidth = 2.0;
    self.blurContainer.hidden = YES;
    [self.view addSubview:self.blurContainer];

    // BRANDING: Astraeus - AC Mod Menu
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 15, 320, 30)];
    titleLabel.text = @"Astraeus - AC Mod Menu";
    titleLabel.textColor = [UIColor purpleColor];
    titleLabel.font = [UIFont boldSystemFontOfSize:18];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.blurContainer.contentView addSubview:titleLabel];

    // XYZ Fields
    [self addLabel:@"SPAWN POSITION (X | Y | Z)" at:65];
    self.xField = [self addSmallField:90 xPos:40];
    self.yField = [self addSmallField:90 xPos:125];
    self.zField = [self addSmallField:90 xPos:210];

    // Quantity
    self.qtyLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 145, 300, 20)];
    self.qtyLabel.textColor = [UIColor whiteColor];
    self.qtyLabel.textAlignment = NSTextAlignmentCenter;
    self.qtyLabel.text = @"Quantity: 1";
    [self.blurContainer.contentView addSubview:self.qtyLabel];

    self.qtySlider = [[UISlider alloc] initWithFrame:CGRectMake(40, 170, 240, 30)];
    self.qtySlider.minimumValue = 1;
    self.qtySlider.maximumValue = 100;
    self.qtySlider.tintColor = [UIColor purpleColor];
    [self.qtySlider addTarget:self action:@selector(qChanged) forControlEvents:UIControlEventValueChanged];
    [self.blurContainer.contentView addSubview:self.qtySlider];

    // Picker
    [self addLabel:@"SELECT ITEM" at:215];
    self.itemPicker = [[UIPickerView alloc] initWithFrame:CGRectMake(10, 235, 300, 150)];
    self.itemPicker.delegate = self;
    self.itemPicker.dataSource = self;
    [self.blurContainer.contentView addSubview:self.itemPicker];

    // Spawn Button
    UIButton *spawn = [[UIButton alloc] initWithFrame:CGRectMake(60, 415, 200, 50)];
    spawn.backgroundColor = [UIColor purpleColor];
    spawn.layer.cornerRadius = 15;
    [spawn setTitle:@"GENERATE" forState:UIControlStateNormal];
    [self.blurContainer.contentView addSubview:spawn];

    // Styled X Close Button
    UIButton *close = [[UIButton alloc] initWithFrame:CGRectMake(275, 15, 30, 30)];
    [close setTitle:@"✕" forState:UIControlStateNormal];
    close.titleLabel.font = [UIFont systemFontOfSize:20 weight:UIFontWeightBold];
    [close setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    close.backgroundColor = [UIColor colorWithRed:0.9 green:0.2 blue:0.2 alpha:1.0];
    close.layer.cornerRadius = 15;
    [close addTarget:self action:@selector(toggleMenu) forControlEvents:UIControlEventTouchUpInside];
    [self.blurContainer.contentView addSubview:close];
}

- (UITextField*)addSmallField:(CGFloat)y xPos:(CGFloat)x {
    UITextField *f = [[UITextField alloc] initWithFrame:CGRectMake(x, y, 70, 35)];
    f.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.1];
    f.textColor = [UIColor whiteColor];
    f.textAlignment = NSTextAlignmentCenter;
    f.layer.cornerRadius = 8;
    f.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
    [self.blurContainer.contentView addSubview:f];
    return f;
}

- (void)addLabel:(NSString*)txt at:(CGFloat)y {
    UILabel *l = [[UILabel alloc] initWithFrame:CGRectMake(0, y, 320, 20)];
    l.text = txt; l.textColor = [UIColor lightGrayColor];
    l.font = [UIFont systemFontOfSize:11 weight:UIFontWeightBold];
    l.textAlignment = NSTextAlignmentCenter;
    [self.blurContainer.contentView addSubview:l];
}

- (void)qChanged { self.qtyLabel.text = [NSString stringWithFormat:@"Quantity: %d", (int)self.qtySlider.value]; }

- (void)toggleMenu {
    self.blurContainer.hidden = !self.blurContainer.hidden;
    self.circleButton.hidden = !self.blurContainer.hidden;
    [self.view endEditing:YES]; 
}

// Picker Boilerplate
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)p { return 1; }
- (NSInteger)pickerView:(UIPickerView *)p numberOfRowsInComponent:(NSInteger)c { return self.availableItems.count; }
- (NSString *)pickerView:(UIPickerView *)p titleForRow:(NSInteger)r forComponent:(NSInteger)c { return self.availableItems[r]; }
@end

// --- THE NEW FIXED INJECTOR ---
static AstraeusWindow *modWindow;

%ctor {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        // We create a separate window for the menu so it doesn't mess with the game window
        modWindow = [[AstraeusWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
        modWindow.rootViewController = [[ModMenuController alloc] init];
        modWindow.windowLevel = UIWindowLevelStatusBar + 1; // Put it above EVERYTHING
        modWindow.backgroundColor = [UIColor clearColor];
        [modWindow makeKeyAndVisible];
        
        // This is the secret sauce: pass touches through the window!
        modWindow.userInteractionEnabled = YES;
    });
}
