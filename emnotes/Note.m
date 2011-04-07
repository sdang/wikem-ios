//
//  Note.m
//  emnotes
//
//  Created by Sabin Dang on 4/1/11.
//  Copyright (c) 2011 sabindang.com. All rights reserved.
//

#import "Note.h"
#import "Category.h"


@implementation Note
@dynamic author;
@dynamic content;
@dynamic name;
@dynamic lastUpdate;
@dynamic categories;
@dynamic firstLetter;

+ (Note *)noteWithName:(NSString *)name
                author:(NSString *)author 
               content:(NSString *)content 
            lastUpdate:(NSDate *)lastUpdate
            categories:(NSSet *)categories
inManagedObjectContext:(NSManagedObjectContext *)context
{
    Note *note = nil;
    
    // request category of title
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    request.entity = [NSEntityDescription entityForName:@"Note" inManagedObjectContext:context];
    request.predicate = [NSPredicate predicateWithFormat:@"name = %@", name];
    request.fetchBatchSize = 1;
    
    NSError *error = nil;
    note = [[context executeFetchRequest:request error:&error] lastObject];
    
    if (!error && !note) {
        // set note parameters
        note = [NSEntityDescription insertNewObjectForEntityForName:@"Note" inManagedObjectContext:context];
        note.name = name;
        note.author = author;
        note.content = content;
        note.categories = categories;
        note.lastUpdate = lastUpdate;
    }
    
    [request release];
    return note;
}

- (NSString *) getFirstLetter {
    [self willAccessValueForKey:@"firstLetter"];
    NSString *firstLetter = [[self name] substringToIndex:1];
    [self didAccessValueForKey:@"firstLetter"];
    return firstLetter;
}

- (void)addCategoriesObject:(Category *)value {    
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    [self willChangeValueForKey:@"categories" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
    [[self primitiveValueForKey:@"categories"] addObject:value];
    [self didChangeValueForKey:@"categories" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
    [changedObjects release];
}

- (void)removeCategoriesObject:(Category *)value {
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    [self willChangeValueForKey:@"categories" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
    [[self primitiveValueForKey:@"categories"] removeObject:value];
    [self didChangeValueForKey:@"categories" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
    [changedObjects release];
}

- (void)addCategories:(NSSet *)value {    
    [self willChangeValueForKey:@"categories" withSetMutation:NSKeyValueUnionSetMutation usingObjects:value];
    [[self primitiveValueForKey:@"categories"] unionSet:value];
    [self didChangeValueForKey:@"categories" withSetMutation:NSKeyValueUnionSetMutation usingObjects:value];
}

- (void)removeCategories:(NSSet *)value {
    [self willChangeValueForKey:@"categories" withSetMutation:NSKeyValueMinusSetMutation usingObjects:value];
    [[self primitiveValueForKey:@"categories"] minusSet:value];
    [self didChangeValueForKey:@"categories" withSetMutation:NSKeyValueMinusSetMutation usingObjects:value];
}

- (NSString *)formattedContent {
    NSString* cssTags = @"<html><head><link href=\"note-style.css\" rel=\"Stylesheet\" type=\"text/css\" /></head><body>";
	NSString* htmlContent = [cssTags stringByAppendingString:self.content];
	htmlContent = [htmlContent stringByAppendingString:@"</body></html>"];
    
    return htmlContent;
}


@end
