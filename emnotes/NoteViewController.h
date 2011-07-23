//
//  NoteViewController.h
//  TabViewTest
//
//  Created by Sabin Dang on 4/1/11.
//  Copyright 2011 sabindang.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Note.h"


@interface NoteViewController : UIViewController <UIWebViewDelegate, UIAlertViewDelegate> {
    UIWebView *webView;
    Note *note;
}

@property (retain) IBOutlet UIWebView *webView;
@property (retain) Note *note;
//adda context for notes, initialize it in appdelegate
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;


- (NSString*) convertURLString: (NSString *) myString ;

@end
