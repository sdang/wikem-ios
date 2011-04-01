//
//  Category.m
//  TabViewTest
//
//  Created by Sabin Dang on 4/1/11.
//  Copyright 2011 sabindang.com. All rights reserved.
//

#import "Category.h"



@implementation Category

@synthesize categories;

- (id)init {
    [super init];
    self.categories = [NSArray arrayWithObjects:@"Heme/Onc", @"Cards", nil];
    return self;
}

- (void) dealloc {
    [self.categories release];
    [super dealloc];
}

- (NSString *)nameOfCategory:(int)categoryIndex {
    return [categories objectAtIndex:(NSUInteger)categoryIndex];
}

- (int)totalNumberOfCategories {
    return [categories count];
}

- (int)numberOfNotesInCategory:(int)categoryIndex {
    return 1;
}

@end
