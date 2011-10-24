//
//  Category.h
//  emnotes
//
//  Created by Sabin Dang on 4/1/11.
//  Copyright (c) 2011 sabindang.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Category : NSManagedObject {
@private
}

@property (nonatomic, retain) NSString * title;

+ (Category *)categoryWithTitle:(NSString *)title inManagedObjectContext:(NSManagedObjectContext *)context;

@end
