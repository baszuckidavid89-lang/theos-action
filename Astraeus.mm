#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

// --- Interface for the Menu ---
@interface AstraeusMenu : UIView <UIPickerViewDelegate>
@property (nonatomic, strong) UIView *container;
@property (nonatomic, strong) CAGradientLayer *backgroundGradient;
@property (nonatomic, strong) UILabel *headerLabel;
@end

@implementation AstraeusMenu

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupLayout];
    }
    return self;
}

- (void)setupLayout {
    // 1. Setup the Centered Container (300x450)
    self.container = [[UIView alloc] initWithFrame:CGRectMake((self.frame.size.width - 300)/2, (self.frame.size.height - 450)/2, 300, 450)];
    self.container.layer.cornerRadius = 20;
    self.container.layer.masksToBounds = YES;
    self.container.layer.borderWidth = 2.0;
    self.container.layer.borderColor = [UIColor whiteColor].CGColor;

    // 2. Gradient Background (Purple to Black)
    self.backgroundGradient = [CAGradientLayer layer];
    self.backgroundGradient.frame = self.container.bounds;
    self.backgroundGradient.colors = @[(id)[UIColor colorWithRed:0.2 green:0.0 blue:0.4 alpha:1.0].CGColor, (id)[UIColor blackColor].CGColor];
    [self.container.layer insertSublayer:self.backgroundGradient atIndex:0];

    // 3. Header Text: Astraeus
    self.headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 15, 300, 40)];
    self.headerLabel.text = @"Astraeus";
    self.headerLabel.textColor = [UIColor whiteColor];
    self.headerLabel.font = [UIFont boldSystemFontOfSize:24];
    self.headerLabel.textAlignment = NSTextAlignmentCenter;
    [self.container addSubview:self.headerLabel];

    // 4. Create the 5 Specific Tabs
    NSArray *tabNames = @[@"Lackson", @"Astraeus", @"Robxify", @"Ratters", @"Skidders"];
    for (int i = 0; i < tabNames.count; i++) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(20, 70 + (i * 60), 260, 45);
        [btn setTitle:tabNames[i] forState:UIControlStateNormal];
        btn.backgroundColor = [[UIColor grayColor] colorWithAlphaComponent:0.2];
        btn.layer.cornerRadius = 10;
        btn.titleLabel.font = [UIFont systemFontOfSize:18 weight:UIFontWeightMedium];
        [self.container addSubview:btn];
    }

    [self addSubview:self.container];
}

- (void)toggle {
    self.hidden = !self.hidden;
}
@end

// --- Global Menu Instance ---
static AstraeusMenu *menuInstance;

// --- Entry Point Hook ---
__attribute__((constructor))
static void initializeAstraeus() {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        UIWindow *window = [[UIApplication sharedApplication] keyWindow];
        if (!window) return;

        menuInstance = [[AstraeusMenu alloc] initWithFrame:window.bounds];
        menuInstance.hidden = YES;
        [window addSubview:menuInstance];

        // --- Floating Gradient Toggle Button (Top Left) ---
        UIButton *toggleBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        toggleBtn.frame = CGRectMake(40, 50, 160, 45); // Adjusted for iPhone 11 Pro Max Notch
        [toggleBtn setTitle:@"Open Astraeus Menu" forState:UIControlStateNormal];
        toggleBtn.titleLabel.font = [UIFont boldSystemFontOfSize:14];
        toggleBtn.layer.cornerRadius = 22;
        toggleBtn.clipsToBounds = YES;

        // Button Gradient
        CAGradientLayer *btnGrad = [CAGradientLayer layer];
        btnGrad.frame = toggleBtn.bounds;
        btnGrad.colors = @[(id)[UIColor blueColor].CGColor, (id)[UIColor purpleColor].CGColor];
        btnGrad.startPoint = CGPointMake(0, 0.5);
        btnGrad.endPoint = CGPointMake(1, 0.5);
        [toggleBtn.layer insertSublayer:btnGrad atIndex:0];

        [toggleBtn addTarget:menuInstance action:@selector(toggle) forControlEvents:UIControlEventTouchUpInside];
        [window addSubview:toggleBtn];
        
        NSLog(@"[Astraeus] Menu Injected Successfully.");
    });
}o