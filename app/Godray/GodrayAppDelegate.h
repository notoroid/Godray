//
//  GodrayAppDelegate.h
//  Godray
//
//  Created by Kaname Noto on 11/05/20.
//  Copyright 2011 Irimasu Densan Planning. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GodrayViewController;

@interface GodrayAppDelegate : NSObject <UIApplicationDelegate> {

}

@property (nonatomic, retain) IBOutlet UIWindow *window;

@property (nonatomic, retain) IBOutlet GodrayViewController *viewController;

@end
