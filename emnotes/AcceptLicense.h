//
//  AcceptLicense.h
//  emnotes
//
//  Created by Sabin Dang on 4/4/11.
//  Copyright 2011 sabindang.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol AcceptLicenseDelegate <NSObject>
-(void)userDidAcceptLicense:(BOOL)status;
@end

@interface AcceptLicense : UIViewController {
    UIWebView *webView;
    id <AcceptLicenseDelegate> delegate;
}

@property (retain) IBOutlet UIWebView *webView;
@property (retain) id delegate;

- (IBAction)licenseAccepted;
- (void)hideMyself;

@end
