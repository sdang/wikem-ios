//
//  AcceptLicense.m
//  emnotes
//
//  Created by Sabin Dang on 4/4/11.
//  Copyright 2011 sabindang.com. All rights reserved.
//

#import "AcceptLicense.h"
#import "UpdateViewController.h"


@implementation AcceptLicense

@synthesize webView;
@synthesize delegate;

- (IBAction)licenseAccepted
{
    [self.delegate userDidAcceptLicense:YES];
    [self hideMyself];
}

- (void)hideMyself
{
    UIApplication *app = [UIApplication sharedApplication];
    CGRect hiddenRect = CGRectMake(0.0,self.view.bounds.size.height + app.statusBarFrame.size.height, self.view.bounds.size.width, self.view.bounds.size.height);
    
    [UIView transitionWithView:self.view
                      duration:0.5
                       options:UIViewAnimationOptionTransitionNone
                    animations:^{ self.view.frame = hiddenRect; }
                    completion:NULL];
    
    NSLog(@"Accepted Disclaimer");       
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
    self.webView = nil;
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    NSString *path = [[NSBundle mainBundle] pathForResource:@"disclaimer" ofType:@"html"];    
    NSString *disclaimer = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:NULL];
    [self.webView loadHTMLString:disclaimer baseURL:nil];
//    [self.webView loadHTMLString:[NSString stringWithContentsOfFile:@"disclaimer.html" baseURL:[NSURL URLWithString:@"/"]]];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    self.webView = nil;
}

 

@end
