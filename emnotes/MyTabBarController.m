//
//  MyTabBarConroller.m
//  emnotes
//
//  Created by Busby on 7/28/11.
//  Copyright 2011 sabindang.com. All rights reserved.
//

#import "MyTabBarController.h"


@implementation MyTabBarController

@synthesize dontrotate;

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	if (dontrotate){
		//NSLog(@"inshouldautorotate in mytabcontroller");
		return NO;
	}else{
		return YES; }
}

/* try to make tabview more transparent..doesnt work...
- (void)viewDidLoad {
    [super viewDidLoad];
	
    CGRect frame = CGRectMake(0.0, 0.0, self.view.bounds.size.width, 48);
    UIView *v = [[UIView alloc] initWithFrame:frame];
 //   [v setBackgroundColor:kMainColor];
    [v setAlpha:0.2];
    [[self tabBar] addSubview:v];
    [v release];
	
}*/

@end