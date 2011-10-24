//
//  PersonalNote.m
//  emnotes
//
//  Created by Sabin Dang on 4/6/11.
//  Copyright (c) 2011 sabindang.com. All rights reserved.
//

#import "PersonalNote.h"


@implementation PersonalNote
@dynamic title;
@dynamic content;

+ (PersonalNote *)personalNoteWithTitle:(NSString *)title content:(NSString *)content inManagedObjectContext:(NSManagedObjectContext *)context forceCreate:(BOOL)forceCreate
{
    PersonalNote *note = nil;
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    request.entity = [NSEntityDescription entityForName:@"PersonalNote" inManagedObjectContext:context];
    request.predicate = [NSPredicate predicateWithFormat:@"title = %@", title];
    request.fetchBatchSize = 1;
    NSError *error = nil;
    note = [[context executeFetchRequest:request error:&error] lastObject];
    
    // if the note doesn't exist, or if we want to force create it
    if ((!error && !note) || (forceCreate)) {
        note = [NSEntityDescription insertNewObjectForEntityForName:@"PersonalNote" inManagedObjectContext:context];
        note.title = title;
        note.content = content;
        [context save:NULL];
    }
    
    [request release];
    return note;
}


@end
