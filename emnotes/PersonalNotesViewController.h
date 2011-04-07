//
//  PersonalNotesViewController.h
//  emnotes
//
//  Created by Sabin Dang on 4/6/11.
//  Copyright 2011 sabindang.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PersonalNote.h"
#import "EditNoteViewController.h"

@interface PersonalNotesViewController : UIViewController <EditNoteViewControllerDelegate> {
    
    UITextView *noteTextField;
    PersonalNote *personalNote;
}

@property (nonatomic, retain) PersonalNote *personalNote;
@property (nonatomic, retain) IBOutlet UITextView *noteTextField;

- (void)updateNoteText;
@end
