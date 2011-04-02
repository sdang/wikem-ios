//
//  Category.m
//  emnotes
//
//  Created by Sabin Dang on 4/1/11.
//  Copyright (c) 2011 sabindang.com. All rights reserved.
//

#import "Category.h"


@implementation Category
@dynamic title;

+ (Category *)categoryWithTitle:(NSString *)title inManagedObjectContext:(NSManagedObjectContext *)context
{
    Category *category = nil;
    
    // request category of title
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    request.entity = [NSEntityDescription entityForName:@"Category" inManagedObjectContext:context];
    request.predicate = [NSPredicate predicateWithFormat:@"title = %@", title];
    request.fetchBatchSize = 1;
    
    NSError *error = nil;
    category = [[context executeFetchRequest:request error:&error] lastObject];

    if (!error && !category) {
        // set category parameters
        category = [NSEntityDescription insertNewObjectForEntityForName:@"Category" inManagedObjectContext:context];
        category.title = title;
    }
    
    [request release];
    return category;
}

@end
