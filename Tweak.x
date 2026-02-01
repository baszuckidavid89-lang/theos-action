#import <UIKit/UIKit.h>

@interface AstraeusMenu : UIView <UIScrollViewDelegate>
@property (nonatomic, strong) UIView *container;
@property (nonatomic, strong) UIScrollView *scrollView;
@end

@implementation AstraeusMenu

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5]; // Dim background
        
        // 1. The Main Menu Box (Perfectly sized for iPhone 11 Pro Max)
        self.container = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 500)];
        self.container.center = self.center;
        self.container.backgroundColor = [UIColor colorWithRed:0.07 green:0.07 blue:0.07 alpha:1.0];
        self.container.layer.cornerRadius = 25;
        self.container.layer.borderWidth = 1.5;
        self.container.layer.borderColor = [UIColor purpleColor].CGColor;
        self.container.clipsToBounds = YES;
        [self addSubview:self.container];

        // 2. The Header (Astraeus Purple)
        UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 60)];
        header.backgroundColor = [UIColor colorWithRed:0.15 green:0.0 blue:0.3 alpha:1.0];
        [self.container addSubview:header];

        UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, 320, 40)];
        title.text = @"ASTRAEUS MENU";
        title.textColor = [UIColor whiteColor];
        title.textAlignment = NSTextAlignmentCenter;
        title.font = [UIFont fontWithName:@"AvenirNext-Bold" size:22];
        [header addSubview:title];

        // 3. Close Button (Top Right)
        UIButton *closeBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        closeBtn.frame = CGRectMake(270, 15, 35, 35);
        [closeBtn setTitle:@"✕" forState:UIControlStateNormal];
        [closeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        closeBtn.titleLabel.font = [UIFont systemFontOfSize:20 weight:UIFontWeightBold];
        [closeBtn addTarget:self action:@selector(toggleMenu) forControlEvents:UIControlEventTouchUpInside];
        [header addSubview:closeBtn];

        // 4. Scrollable Feature Area
        self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 60, 320, 440)];
        self.scrollView.contentSize = CGSizeMake(320, 600); // Larger than the box so it scrolls
        [self.container addSubview:self.scrollView];

        // 5. Adding the Tabs/Features
        NSArray *features = @[@"Speed Hack", @"Infinite Money", @"God Mode", @"Lackson Mode", @"Robxify Perks", @"Ratters Wall", @"Skidders Bypass"];
        
        for (int i = 0; i < features.count; i++) {
            UIView *row = [[UIView alloc] initWithFrame:CGRectMake(10, 10 + (i * 70), 300, 60)];
            row.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.05];
            row.layer.cornerRadius = 12;
            [self.scrollView addSubview:row];

            UILabel *fLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, 180, 60)];
            fLabel.text = features[i];
            fLabel.textColor = [UIColor whiteColor];
            fLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightMedium];
            [row addSubview:fLabel];

            UISwitch *fSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(240, 15, 0, 0)];
            fSwitch.onTintColor = [UIColor purpleColor];
            [row addSubview:fSwitch];
        }
    }
    return self;
}

- (void)toggleMenu {
    self.hidden = !self.hidden;
}

@end

static AstraeusMenu *mainMenu;

%ctor {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        UIWindow *keyWindow = nil;
        // Modern Window Scene handling
        for (UIWindowScene *scene in [UIApplication sharedApplication].connectedScenes) {
            if (scene.activationState == UISceneActivationStateForegroundActive) {
                for (UIWindow *window in scene.windows) {
                    if (window.isKeyWindow) {
                        keyWindow = window;
                        break;
                    }
                }
            }
        }

        if (keyWindow) {
            mainMenu = [[AstraeusMenu alloc] initWithFrame:keyWindow.bounds];
            mainMenu.hidden = YES; // Starts hidden
            [keyWindow addSubview:mainMenu];

            // Floating "A" Toggle Button
            UIButton *toggle = [UIButton buttonWithType:UIButtonTypeCustom];
            toggle.frame = CGRectMake(20, 150, 60, 60);
            toggle.backgroundColor = [UIColor purpleColor];
            toggle.layer.cornerRadius = 30;
            toggle.layer.shadowColor = [UIColor blackColor].CGColor;
            toggle.layer.shadowOffset = CGSizeMake(0, 4);
            toggle.layer.shadowOpacity = 0.5;
            [toggle setTitle:@"A" forState:UIControlStateNormal];
            toggle.titleLabel.font = [UIFont boldSystemFontOfSize:24];
            [toggle addTarget:mainMenu action:@selector(toggleMenu) forControlEvents:UIControlEventTouchUpInside];
            [keyWindow addSubview:toggle];
        }
    });
}
