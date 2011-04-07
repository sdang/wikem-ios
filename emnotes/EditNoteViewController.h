//
//  EditNoteViewController.h
//  emnotes
//
//  Created by Sabin Dang on 4/6/11.
//  Copyright 2011 sabindang.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PersonalNote.h"

@protocol EditNoteViewControllerDelegate <NSObject>
@optional
-(void)userSavedChanges;
@end

@interface EditNoteViewController : UIViewController <UITextFieldDelegate, UITextViewDelegate> {
    UITextField *noteTitleTextField;
    UITextView *noteContentTextField;
    NSManagedObjectContext *managedObjectContext;
    BOOL editingMode;
    PersonalNote *personalNote;
    id delegate;
}

@property (nonatomic, retain) id <EditNoteViewControllerDelegate> delegate;
@property (assign) BOOL editingMode;
@property (nonatomic, retain) PersonalNote *personalNote;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) IBOutlet UITextField *noteTitleTextField;
@property (nonatomic, retain) IBOutlet UITextView *noteContentTextField;

- (id)initWithNote:(PersonalNote *)aPersonalNote;
- (void)setContentFieldToNormal;

@end
