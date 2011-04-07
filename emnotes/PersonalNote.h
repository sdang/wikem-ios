//
//  PersonalNote.h
//  emnotes
//
//  Created by Sabin Dang on 4/6/11.
//  Copyright (c) 2011 sabindang.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface PersonalNote : NSManagedObject {
@private
}
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * content;

@end
