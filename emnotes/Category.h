//
//  Category.h
//  TabViewTest
//
//  Created by Sabin Dang on 4/1/11.
//  Copyright 2011 sabindang.com. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Category : NSObject {
    @private
    NSArray *categories;
}

@property (retain) NSArray *categories;

- (int)totalNumberOfCategories;
- (NSString *)nameOfCategory:(int)categoryIndex;
- (int)numberOfNotesInCategory:(int)categoryIndex;

@end
