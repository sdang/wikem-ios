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
		//return YES; 
		return NO; //turn off. is crausing memory low and crash
	}
}
 

@end