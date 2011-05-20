//
//  GodrayViewController.h
//  Godray
//
//  Created by Kaname Noto on 11/05/20.
//  Copyright 2011 Irimasu Densan Planning. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface GodrayViewController : UIViewController {
    CALayer* godRayLayer_;
    CALayer* packageLayer_;
}

@property(nonatomic,retain) IBOutlet UIView* godrayView;
@property(nonatomic,retain) IBOutlet UIView* packageView;

- (IBAction) firedStart:(id)sender;

- (void) startGodrayAnimation;

@end
