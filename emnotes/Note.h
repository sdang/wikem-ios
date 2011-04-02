//
//  Note.h
//  emnotes
//
//  Created by Sabin Dang on 4/1/11.
//  Copyright (c) 2011 sabindang.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Category;

@interface Note : NSManagedObject {
@private
}
@property (nonatomic, retain) NSString * author;
@property (nonatomic, retain) NSString * content;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSDate * lastUpdate;
@property (nonatomic, retain) NSSet* categories;

+ (Note *)noteWithName:(NSString *)name
                author:(NSString *)author 
               content:(NSString *)content 
            lastUpdate:(NSDate *)lastUpdate
            categories:(NSSet *)categories
inManagedObjectContext:(NSManagedObjectContext *)context;

@end
