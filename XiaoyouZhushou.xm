// XiaoyouZhushou.xm
// 小幼助手 —— 基于 WCEhance 改名的微信 UI 个性化 tweak（学习交流用途）
// 适配老猫 WCplugins 插件管理：在「我 → 插件」里显示「小幼助手」，点进去有多个功能开关。
// 仅作用于微信 (com.tencent.xin)，不修改业务数据、不绕过任何校验。

#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#include <dispatch/dispatch.h>

#define KEY_RENAME   @"xiaoyou_rename"
#define KEY_HIDEQR   @"xiaoyou_hideQR"
#define KEY_IMGCLOSE @"xiaoyou_imageclose"

static BOOL xy_enabled(NSString *key) {
    return [[NSUserDefaults standardUserDefaults] boolForKey:key];
}

#pragma mark - 微信原有 UI 修改（每项都由对应开关控制）

@interface WCTableViewCellLeftConfig : NSObject
@property(copy, nonatomic) NSString *title;
@end

@interface WCC2CImageScrollView : UIView
- (void)handleTapGesture:(UITapGestureRecognizer *)gesture;
@end

@interface CExtendInfoOfImg : NSObject
- (void)setImage:(id)arg1 withData:(id)arg2 isLongOriginImage:(BOOL)arg3;
- (void)setImage:(id)arg1 withData:(id)arg2 isOriginImage:(BOOL)arg3;
@end

%hook WCTableViewCellLeftConfig
- (NSString *)title {
    NSString *r = %orig;
    if (!xy_enabled(KEY_RENAME)) return r;
    if (r == nil) return nil;
    if ([r isEqualToString:@"订单与卡包"]) return @"卡包";
    if ([r isEqualToString:@"支付与服务"]) return @"服务";
    return r;
}
%end

%hook UIButton
- (void)setAccessibilityLabel:(NSString *)accessibilityLabel {
    %orig;
    if (xy_enabled(KEY_HIDEQR) && [accessibilityLabel isEqualToString:@"我的二维码"]) {
        self.hidden = YES;
    }
}
%end

%hook WCC2CImageScrollView
- (void)layoutSubviews {
    %orig;
    if (!xy_enabled(KEY_IMGCLOSE)) return;
    NSBundle *bundle = [NSBundle mainBundle];
    NSString *version = [bundle objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    if ([version compare:@"8.0.55" options:NSNumericSearch] != NSOrderedAscending) {
        BOOL hasGesture = NO;
        for (UIGestureRecognizer *gesture in self.gestureRecognizers) {
            if ([gesture isKindOfClass:[UITapGestureRecognizer class]]) {
                hasGesture = YES;
                break;
            }
        }
        if (!hasGesture) {
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
            [self addGestureRecognizer:tap];
        }
    }
    NSArray *subviews = [self.subviews copy];
    for (UIView *subview in subviews) {
        if ([subview class] == [UIView class]) {
            [subview removeFromSuperview];
        }
    }
}
%new
- (void)handleTapGesture:(UITapGestureRecognizer *)gesture {
    CGPoint location = [gesture locationInView:self];
    CGFloat width = self.bounds.size.width;
    CGFloat edgeWidth = width * 0.2;
    if (location.x <= edgeWidth || location.x >= (width - edgeWidth)) {
        SEL closeSelector = NSSelectorFromString(@"onCloseBtnClick:");
        if ([self respondsToSelector:closeSelector]) {
            [self performSelector:closeSelector withObject:nil];
        }
    }
}
%end

%hook CExtendInfoOfImg
%new
- (void)setImage:(id)arg1 withData:(id)arg2 isLongOriginImage:(BOOL)arg3 {
    [self setImage:arg1 withData:arg2 isOriginImage:arg3];
}
%end

#pragma mark - 小幼助手 设置页（点进插件看到的三个开关，手工布局，不依赖 ARC）

@interface XiaoyouZhushouViewController : UIViewController
- (void)switchChanged:(UISwitch *)sw;
@end

@implementation XiaoyouZhushouViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"小幼助手";
    self.view.backgroundColor = [UIColor whiteColor];

    NSArray *titles = [NSArray arrayWithObjects:@"改菜单文案（卡包 / 服务）", @"隐藏我的二维码", @"图片边缘点击关闭", nil];
    NSArray *keys   = [NSArray arrayWithObjects:KEY_RENAME, KEY_HIDEQR, KEY_IMGCLOSE, nil];

    CGFloat width = self.view.bounds.size.width;
    CGFloat y = 120.0;

    int i;
    for (i = 0; i < 3; i++) {
        UIView *row = [[UIView alloc] initWithFrame:CGRectMake(0, y, width, 50)];

        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(16, 10, width - 90, 30)];
        label.text = [titles objectAtIndex:i];
        label.font = [UIFont systemFontOfSize:15];
        label.textColor = [UIColor darkTextColor];
        [row addSubview:label];

        UISwitch *sw = [[UISwitch alloc] initWithFrame:CGRectMake(width - 67, 10, 51, 31)];
        sw.tag = i;
        sw.on = xy_enabled([keys objectAtIndex:i]);
        [sw addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];
        [row addSubview:sw];

        [self.view addSubview:row];
        y = y + 60;
    }
}
- (void)switchChanged:(UISwitch *)sw {
    NSArray *keys = [NSArray arrayWithObjects:KEY_RENAME, KEY_HIDEQR, KEY_IMGCLOSE, nil];
    NSString *key = [keys objectAtIndex:sw.tag];
    [[NSUserDefaults standardUserDefaults] setBool:sw.on forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
@end

#pragma mark - 注册到 WCplugins 插件管理

%ctor {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (NSClassFromString(@"WCPluginsMgr")) {
            id mgr = [objc_getClass("WCPluginsMgr") sharedInstance];
            if ([mgr respondsToSelector:@selector(registerControllerWithTitle:version:controller:)]) {
                [mgr registerControllerWithTitle:@"小幼助手" version:@"1.0" controller:@"XiaoyouZhushouViewController"];
            }
        }
    });
}
