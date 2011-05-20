//
//  GodrayViewController.m
//  Godray
//
//  Created by Kaname Noto on 11/05/20.
//  Copyright 2011 Irimasu Densan Planning. All rights reserved.
//

#import "GodrayViewController.h"

CGFloat DegreesToRadians(CGFloat degrees) {return degrees * M_PI / 180.0f;};
CGFloat RadiansToDegrees(CGFloat radians) {return radians * 180.0f / M_PI;};

@implementation GodrayViewController

@synthesize godrayView=_godrayView;
@synthesize packageView=_packageView;

#define kGodrayAnimatinoType @"kGodrayAnimatinoType"
#define kGodrayAnimatinoTypePopupPackage @"kGodrayAnimatinoTypePopupPackage"
#define PACKAGE_POPUP_LENGTH 500.0f

- (IBAction) firedStart:(id)sender
{
    // 箱レイヤを削除
    [packageLayer_ removeFromSuperlayer];
    [packageLayer_ release];
    packageLayer_ = nil;
    
    // Godrarレイヤを削除
    [godRayLayer_ removeFromSuperlayer];
    [godRayLayer_ release];
    godRayLayer_ = nil;

    
    CGFloat scale = [UIScreen mainScreen].scale;
	NSString* packageImageName = ( scale > 1.0f ) ? @"Package@2x.png" : @"Package.png"; // Retina Display かによって読み込む画像切り分け
	NSString* packageSourcePath = [[NSBundle mainBundle] pathForResource:[packageImageName stringByDeletingPathExtension] ofType:[packageImageName pathExtension] ];	
    
	NSData* packageDataGodRay = [[NSData alloc] initWithContentsOfFile:packageSourcePath];
	UIImage* packageImageGodRay = [[UIImage alloc] initWithData:packageDataGodRay];

	CGSize rectBounds = self.packageView.bounds.size;
	packageLayer_ = [[CALayer alloc] init];
	packageLayer_.bounds = CGRectMake(0.0f,0.0f,196.0f ,242.0f); // 画像サイズを引き渡す
	packageLayer_.position = CGPointMake(rectBounds.width * 0.5f , rectBounds.height * 0.5f );
	packageLayer_.contents = (id)[packageImageGodRay CGImage];
	[packageDataGodRay release];
	[packageImageGodRay release];
	[self.packageView.layer addSublayer:packageLayer_];
    
    
    // Animation for god ray
    CABasicAnimation* popupAnimation = [[CABasicAnimation alloc] init];
    popupAnimation.keyPath = @"position.y";
    popupAnimation.fromValue = [NSNumber numberWithFloat:packageLayer_.position.y + PACKAGE_POPUP_LENGTH]; // 下から移動
    popupAnimation.toValue = [NSNumber numberWithFloat:packageLayer_.position.y ];
    popupAnimation.duration = 0.8f;
    popupAnimation.repeatCount = 1.0f;
    
    popupAnimation.delegate = self;
    [popupAnimation setValue:kGodrayAnimatinoTypePopupPackage forKey:kGodrayAnimatinoType];
    
    [packageLayer_ addAnimation:popupAnimation forKey:@"popupPackageAnimation"];
    
    
    // アニメーション終了後のレイヤーへの値値反映はこのタイミングで記述
    
    
    [popupAnimation release];
    
}

- (void) animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    NSString* godrayAnimatinoType = [anim valueForKey:kGodrayAnimatinoType];
        // 識別用の値を取り出す
    
    if( godrayAnimatinoType != nil && [godrayAnimatinoType compare:kGodrayAnimatinoTypePopupPackage] == NSOrderedSame ){
        [packageLayer_ removeAllAnimations];
        
        // 既存のレイヤーを削除する
        [godRayLayer_ removeFromSuperlayer];
        [godRayLayer_ release];
        godRayLayer_ = nil;
        
        // start god ray animation
        CGFloat scale = [UIScreen mainScreen].scale;
        NSString* godrayImageName = ( scale > 1.0f ) ? @"god_ray@2x.png" : @"god_ray.png"; // Retina Display かによって読み込む画像切り分け
        NSString* godraySourcePath = [[NSBundle mainBundle] pathForResource:[godrayImageName stringByDeletingPathExtension] ofType:[godrayImageName pathExtension] ];	
        
        NSData* godrayDataGodRay = [[NSData alloc] initWithContentsOfFile:godraySourcePath];
        UIImage* godrayImageGodRay = [[UIImage alloc] initWithData:godrayDataGodRay];
        
        CGSize godrayRectBounds = self.godrayView.bounds.size;
        godRayLayer_ = [[CALayer alloc] init];
        godRayLayer_.bounds = CGRectMake(0.0f,0.0f,480.0f, 480.0f);
        godRayLayer_.position = CGPointMake(godrayRectBounds.width * 0.5f ,godrayRectBounds.height * 0.5f );
        godRayLayer_.hidden = YES;
        godRayLayer_.contents = (id)[godrayImageGodRay CGImage];
        [godrayDataGodRay release];
        [godrayImageGodRay release];
        [self.godrayView.layer addSublayer:godRayLayer_];
        
        [self startGodrayAnimation];
    }
}

- (void) startGodrayAnimation
{
    // CATransaction、CALayerに組み込み済みアニメーションを無効
    [CATransaction begin];
    [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
    godRayLayer_.hidden = NO;
    godRayLayer_.opacity = 0.0f;
    [CATransaction commit];
    [CATransaction flush];
    
    // CATransaction、CALayerに組み込み済みアニメーションを無効
    [CATransaction begin];
    
    // Animatioin for Fadein
    CABasicAnimation* fadeinAnimation = [[CABasicAnimation alloc] init];
    fadeinAnimation.keyPath = @"opacity";
    fadeinAnimation.duration = 1.0f;
    fadeinAnimation.fromValue = [NSNumber numberWithFloat:0.0f];
    fadeinAnimation.toValue = [NSNumber numberWithFloat:1.0f];
    godRayLayer_.opacity = 1.0;
    [godRayLayer_ addAnimation:fadeinAnimation forKey:@"goRayFadein"];
    [fadeinAnimation release];
    
    // Animation for god ray
    CABasicAnimation* rotationAnimation = [[CABasicAnimation alloc] init];
    rotationAnimation.keyPath = @"transform.rotation.z";
    rotationAnimation.fromValue = [NSNumber numberWithFloat:DegreesToRadians(0.0f) ];
    rotationAnimation.toValue = [NSNumber numberWithFloat:DegreesToRadians(359.95f)];
    rotationAnimation.duration = 6.25f;
    rotationAnimation.repeatCount = 99999;
    [godRayLayer_ addAnimation:rotationAnimation forKey:@"godRayRotation"];

    [rotationAnimation release];
    
    [CATransaction commit];
}


- (void)dealloc
{
    [packageLayer_ release];
    [packageLayer_ release];
    [_godrayView release];
    [_packageView release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - View lifecycle

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
}
*/

- (void)viewDidUnload
{
    [super viewDidUnload];
    self.godrayView = nil;
    self.packageView = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
