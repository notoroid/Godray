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

#define kGodrayAnimType @"kGodrayAnimType"
#define kGodrayAnimTypePackage @"kGodrayAnimTypePackage"
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

    CGFloat scale = [[UIScreen mainScreen] respondsToSelector:NSSelectorFromString(@"scale")] ? [UIScreen mainScreen].scale : 1.0f;
    // スケールを判別
	NSString* packageImageName = ( scale > 1.0f ) ? @"Package@2x.png" : @"Package.png"; // Retina Display かによって読み込む画像切り分け
	NSString* packageSourcePath = [[NSBundle mainBundle] pathForResource:[packageImageName stringByDeletingPathExtension] ofType:[packageImageName pathExtension] ]; // 絶対パスを取得する
    
    // 画像リソースを読み込む
	NSData* packageDataGodRay = [[NSData alloc] initWithContentsOfFile:packageSourcePath];
	UIImage* packageImageGodRay = [[UIImage alloc] initWithData:packageDataGodRay];

	CGSize layersize = self.packageView.frame.size;
	packageLayer_ = [[CALayer alloc] init];
	packageLayer_.bounds = CGRectMake(0.0f,0.0f,layersize.width  ,layersize.height ); // 画像サイズを引き渡す
	packageLayer_.position = CGPointMake(layersize.width * 0.5f , layersize.height * 0.5f );
	packageLayer_.contents = (id)[packageImageGodRay CGImage];
    
    // 利用済み画像リソースを削除
	[packageDataGodRay release];
	[packageImageGodRay release];
    
	[self.packageView.layer addSublayer:packageLayer_];
        // CALayer のインスタンスをsublayer として追加
    
    // ここからアニメーションを登録
    // 紙箱をpopup する
    CABasicAnimation* popupAnimation = [[CABasicAnimation alloc] init];
    popupAnimation.keyPath = @"position.y";
    popupAnimation.fromValue = [NSNumber numberWithFloat:packageLayer_.position.y + PACKAGE_POPUP_LENGTH]; // 下から移動開始
    popupAnimation.toValue = [NSNumber numberWithFloat:packageLayer_.position.y ]; // CALayer のposition.y で移動終了
    popupAnimation.duration = 0.8f; // 0.8秒 [秒].[ミリ秒]
    popupAnimation.repeatCount = 1.0f; // 繰り返し回数は1回
    
    // delegate を登録。NSObject の派生クラスはアニメーションのdelegate として登録可能
    popupAnimation.delegate = self;
    [popupAnimation setValue:kGodrayAnimTypePackage forKey:kGodrayAnimType]; // 独自の値をCALayer のインスタンスに格納
    
    [packageLayer_ addAnimation:popupAnimation forKey:@"popupPackageAnimation"]; // アニメーションをキー名@"popupPackageAnimation" として追加
    
    [popupAnimation release]; // 追加済みアニメーションを解放
}

- (void) animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    NSString* godrayAnimatinoType = [anim valueForKey:kGodrayAnimType];
        // 識別用の値をキー値kGodrayAnimTypeを指定して取り出す
    
    if( flag == YES && godrayAnimatinoType != nil && [godrayAnimatinoType compare:kGodrayAnimTypePackage] == NSOrderedSame ){
        [packageLayer_ removeAllAnimations]; // 全てのアニメーションを削除
        
        // 既存のレイヤーを削除する
        [godRayLayer_ removeFromSuperlayer];
        [godRayLayer_ release];
        godRayLayer_ = nil;
        
        // start god ray animation
        CGFloat scale = [[UIScreen mainScreen] respondsToSelector:NSSelectorFromString(@"scale")] ? [UIScreen mainScreen].scale : 1.0f;
        // スケールを判別
        NSString* godrayImageName = ( scale > 1.0f ) ? @"god_ray@2x.png" : @"god_ray.png"; // Retina Display かによって読み込む画像切り分け
        NSString* godrayAbstPath = [[NSBundle mainBundle] pathForResource:[godrayImageName stringByDeletingPathExtension] ofType:[godrayImageName pathExtension] ];	
            // 絶対パスを取得する
        
        NSData* godrayDataGodRay = [[NSData alloc] initWithContentsOfFile:godrayAbstPath];
            // 画像をデータとして取得する
        UIImage* godrayImageGodRay = [[UIImage alloc] initWithData:godrayDataGodRay];
            // データからイメージを読み込む
        
        // CALayer を作成
        CGSize godraysize = self.godrayView.frame.size; // サイズはCAlayer 追加先のview のサイズを元とする
        godRayLayer_ = [[CALayer alloc] init]; // CALayer のインスタンスを生成
        godRayLayer_.bounds = CGRectMake(0.0f,0.0f,godraysize.width ,godraysize.height ); // CALayer のサイズを設定
        godRayLayer_.position = CGPointMake(godraysize.width * 0.5f ,godraysize.height * 0.5f ); // 位置は挿入先の中央
        godRayLayer_.hidden = YES; // 最初は非表示
        godRayLayer_.contents = (id)[godrayImageGodRay CGImage]; // contents を設定
        godRayLayer_.hidden = NO; // 最初は非表示
        godRayLayer_.opacity = 0.0f; // 不透明度0
        
        // 必要なくなったイメージリソースは削除
        [godrayDataGodRay release];
        [godrayImageGodRay release];
        
        [self.godrayView.layer addSublayer:godRayLayer_];
            // レイヤーに追加する
        
        CABasicAnimation* fadeinAnimation = [[CABasicAnimation alloc] init]; // アニメーションのインスタンスを作成
        fadeinAnimation.keyPath = @"opacity"; // 不透過率
        fadeinAnimation.duration = 1.0f; // 秒数 [秒].[ミリ秒]
        fadeinAnimation.fromValue = [NSNumber numberWithFloat:0.0f]; // 開始不透過率
        fadeinAnimation.toValue = [NSNumber numberWithFloat:1.0f]; // 終了不透過率
        godRayLayer_.opacity = 1.0; // アニメーション終了後の値を設定
        [godRayLayer_ addAnimation:fadeinAnimation forKey:@"goRayFadein"]; // アニメーションをキー名@"goRayFadein" で追加
        [fadeinAnimation release]; // 追加終了したアニメーションを削除
        
        // Animation for god ray
        CABasicAnimation* rotationAnimation = [[CABasicAnimation alloc] init];
        rotationAnimation.keyPath = @"transform.rotation.z"; // z軸回転
        rotationAnimation.fromValue = [NSNumber numberWithFloat:DegreesToRadians(0.0f) ]; // 開始角度
        rotationAnimation.toValue = [NSNumber numberWithFloat:DegreesToRadians(359.95f)]; // ここで360.0f を渡すと開始と終了を同じ値として見てしまう
        rotationAnimation.duration = 6.25f; // 回転間隔
        rotationAnimation.repeatCount = 99999; // 大きな値を渡して繰り返す
        
        [godRayLayer_ addAnimation:rotationAnimation forKey:@"godRayRotation"]; // アニメーションをキー@"godRayRotation" で追加
        
        [rotationAnimation release]; // 追加終了したアニメーションを削除
    }
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - View lifecycle

- (void)viewDidUnload
{
    self.godrayView = nil;
    self.packageView = nil;
    [super viewDidUnload];
}

- (void)dealloc
{
    [godRayLayer_ release];
    [packageLayer_ release];
    
    [_godrayView release];
    [_packageView release];
    [super dealloc];
}


@end
