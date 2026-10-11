// XiaoyouZhushou.xm
// 小幼助手 —— 基于 WCEhance 改名的微信 UI 个性化 tweak（学习交流用途）
// 同时适配老猫的 WCplugins 插件管理框架：会在「我 → 插件」里显示「小幼助手」。
// 仅作用于微信 (com.tencent.xin)，不修改任何业务数据、不绕过任何校验。

#import <UIKit/UIKit.h>

#pragma mark - 原有 UI 修改逻辑

@interface WCTableViewCellLeftConfig : NSObject
@property(copy, nonatomic) NSString *title; // @synthesize title=_title;
@end

@interface WCC2CImageScrollView : UIView
- (void)handleTapGesture:(UITapGestureRecognizer *)gesture;
@end

@interface CExtendInfoOfImg : NSObject
- (void)setImage:(id)arg1 withData:(id)arg2 isLongOriginImage:(_Bool)arg3;
- (void)setImage:(id)arg1 withData:(id)arg2 isOriginImage:(BOOL)arg3;
@end

%hook WCTableViewCellLeftConfig

- (NSString *)title {
	NSString *r = %orig;

	if (r == nil) {
		return nil;
	}
	if ([r isEqualToString:@"订单与卡包"]) {
		return @"卡包";
	}
	if ([r isEqualToString:@"支付与服务"]) {
		return @"服务";
	}

	return r;
}

%end

%hook UIButton

- (void)setAccessibilityLabel:(NSString *)accessibilityLabel {
	%orig;

	if ([accessibilityLabel isEqualToString:@"我的⼆维码"]) {

		self.hidden = YES;
	}
}

%end

%hook WCC2CImageScrollView

- (void)layoutSubviews {
	%orig;

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

#pragma mark - 小幼助手 设置页（在 WCplugins 插件管理里点进来看到的内容）

@interface XiaoyouZhushouViewController : UIViewController
@end

@implementation XiaoyouZhushouViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	self.title = @"小幼助手";
	if (@available(iOS 13.0, *)) {
		self.view.backgroundColor = [UIColor systemBackgroundColor];
	} else {
		self.view.backgroundColor = [UIColor whiteColor];
	}

	UILabel *label = [[UILabel alloc] init];
	label.numberOfLines = 0;
	label.textAlignment = NSTextAlignmentCenter;
	label.font = [UIFont systemFontOfSize:15];
	if (@available(iOS 13.0, *)) {
		label.textColor = [UIColor labelColor];
	} else {
		label.textColor = [UIColor darkTextColor];
	}
	label.text = @"小幼助手 v1.0\n\n微信 UI 个性化（学习交流）\n\n· 订单与卡包 → 卡包\n· 支付与服务 → 服务\n· 隐藏「我的二维码」\n· 图片点击边缘关闭";
	label.translatesAutoresizingMaskIntoConstraints = NO;
	[self.view addSubview:label];

	[NSLayoutConstraint activateConstraints:@[
		[label.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
		[label.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor],
		[label.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:24],
		[label.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-24],
	]];
}

@end

#pragma mark - 注册到 WCplugins 插件管理（让「我 → 插件」里出现「小幼助手」）

%ctor {
	// 延迟注册，确保 WCplugins 的 WCPluginsMgr 已经加载
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
		Class mgr = NSClassFromString(@"WCPluginsMgr");
		if (mgr && [mgr respondsToSelector:@selector(sharedInstance)]) {
			id instance = [mgr sharedInstance];
			if ([instance respondsToSelector:@selector(registerControllerWithTitle:version:controller:)]) {
				[instance registerControllerWithTitle:@"小幼助手"
				                             version:@"1.0"
				                         controller:@"XiaoyouZhushouViewController"];
			}
		}
	});
}
