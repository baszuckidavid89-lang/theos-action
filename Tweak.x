#import <UIKit/UIKit.h>

@interface AstraeusMenu : UIView
@property (nonatomic, strong) UIView *container;
@property (nonatomic, strong) UIScrollView *scroll;
@property (nonatomic, strong) UILabel *title;
@property (nonatomic, strong) NSArray *currentMods;
@end

@implementation AstraeusMenu

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.4];

        // Main Box
        self.container = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 330, 550)];
        self.container.center = self.center;
        self.container.backgroundColor = [UIColor colorWithRed:0.05 green:0.05 blue:0.1 alpha:1.0];
        self.container.layer.cornerRadius = 30;
        self.container.layer.borderColor = [UIColor purpleColor].CGColor;
        self.container.layer.borderWidth = 2;
        self.container.clipsToBounds = YES;
        [self addSubview:self.container];

        // Title
        self.title = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, 330, 40)];
        self.title.text = @"ASTRAEUS V2";
        self.title.textColor = [UIColor purpleColor];
        self.title.textAlignment = NSTextAlignmentCenter;
        self.title.font = [UIFont fontWithName:@"Verdana-Bold" size:24];
        [self.container addSubview:self.title];

        // Scroll Area
        self.scroll = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 70, 330, 400)];
        [self.container addSubview:self.scroll];

        // Category Tabs (The 3 Categories)
        NSArray *cats = @[@"Visuals", @"Pranks", @"Chaos"];
        for (int i = 0; i < cats.count; i++) {
            UIButton *tab = [UIButton buttonWithType:UIButtonTypeSystem];
            tab.frame = CGRectMake(10 + (i * 105), 480, 100, 50);
            [tab setTitle:cats[i] forState:UIControlStateNormal];
            [tab setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            tab.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.1];
            tab.layer.cornerRadius = 10;
            tab.tag = i;
            [tab addTarget:self action:@selector(changeCategory:) forControlEvents:UIControlEventTouchUpInside];
            [self.container addSubview:tab];
        }

        [self loadModsForCategory:0]; // Start with Visuals
    }
    return self;
}

- (void)loadModsForCategory:(NSInteger)cat {
    [[self.scroll subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    NSArray *modList;
    if (cat == 0) modList = @[@"RGB Border", @"Screen Shake", @"Confetti Rain", @"Old Film Filter", @"Matrix Code", @"Invert Colors", @"Night Vision", @"Neon Icons", @"Snowfall", @"Sparkle Touch"];
    else if (cat == 1) modList = @[@"Fake Crash", @"Ghost Touch", @"Upside Down", @"Low Battery Prank", @"Glitch Screen", @"Meme Popups", @"Speedup UI", @"Slowmo UI", @"Random Vibrate", @"Reverse Text"];
    else modList = @[@"Gravity Box", @"Explosion Effect", @"Disco Lights", @"Water Ripple", @"Fire Particles", @"Magnifier", @"Flashbang", @"Bouncing Menu", @"Pixelate", @"Warp Drive"];

    self.scroll.contentSize = CGSizeMake(330, modList.count * 60);
    for (int i = 0; i < modList.count; i++) {
        UILabel *l = [[UILabel alloc] initWithFrame:CGRectMake(20, i * 60, 200, 50)];
        l.text = modList[i];
        l.textColor = [UIColor whiteColor];
        [self.scroll addSubview:l];
        
        UISwitch *s = [[UISwitch alloc] initWithFrame:CGRectMake(260, i * 60 + 10, 0, 0)];
        s.onTintColor = [UIColor purpleColor];
        [s addTarget:self action:@selector(modToggled:) forControlEvents:UIControlEventValueChanged];
        [self.scroll addSubview:s];
    }
}

- (void)changeCategory:(UIButton *)sender {
    [self loadModsForCategory:sender.tag];
}

- (void)modToggled:(UISwitch *)s {
    if (s.on) {
        // Fun Trigger: Haptic Feedback
        UIImpactFeedbackGenerator *gen = [[UIImpactFeedbackGenerator alloc] initWithStyle:UIImpactFeedbackStyleHeavy];
        [gen impactOccurred];
        
        // Visual Trigger: Flash the screen purple
        UIView *flash = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        flash.backgroundColor = [UIColor purpleColor];
        flash.alpha = 0.3;
        [[UIApplication sharedApplication].keyWindow addSubview:flash];
        [UIView animateWithDuration:0.5 animations:^{ flash.alpha = 0; } completion:^(BOOL finished){ [flash removeFromSuperview]; }];
    }
}

- (void)toggle { self.hidden = !self.hidden; }
@end

static AstraeusMenu *menu;
%ctor {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        UIWindow *win = [[UIApplication sharedApplication] keyWindow];
        menu = [[AstraeusMenu alloc] initWithFrame:win.bounds];
        menu.hidden = YES;
        [win addSubview:menu];

        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(20, 150, 60, 60);
        btn.backgroundColor = [UIColor purpleColor];
        btn.layer.cornerRadius = 30;
        [btn setTitle:@"A" forState:UIControlStateNormal];
        [btn addTarget:menu action:@selector(toggle) forControlEvents:UIControlEventTouchUpInside];
        [win addSubview:btn];
    });
}
