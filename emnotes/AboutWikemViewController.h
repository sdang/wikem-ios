//
//  AboutWikemViewController.h
//  emnotes
//
//  Created by Sabin Dang on 4/6/11.
//  Copyright 2011 sabindang.com. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface AboutWikemViewController : UIViewController {
    
    UIWebView *webView;
}
@property (nonatomic, retain) IBOutlet UIWebView *webView;
- (IBAction)closeAboutView:(id)sender;
- (IBAction)openWikEMWebsite:(id)sender;

@end
