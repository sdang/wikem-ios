//
//  NoteViewController.h
//  TabViewTest
//
//  Created by Sabin Dang on 4/1/11.
//  Copyright 2011 sabindang.com. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface NoteViewController : UIViewController <UIWebViewDelegate> {
    UIWebView *webView;
}

@property (retain) IBOutlet UIWebView *webView;

@end
