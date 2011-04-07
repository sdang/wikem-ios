//
//  PersonalNotesViewController.m
//  emnotes
//
//  Created by Sabin Dang on 4/6/11.
//  Copyright 2011 sabindang.com. All rights reserved.
//

#import "PersonalNotesViewController.h"


@implementation PersonalNotesViewController
@synthesize noteTextField;
@synthesize personalNote;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // add an edit button
        UIBarButtonItem *editButton = [[UIBarButtonItem alloc] initWithTitle:@"Edit" style:UIBarButtonSystemItemAction target:self action:@selector(editNote)];
        self.navigationItem.rightBarButtonItem = editButton;
        [editButton release];
    }
    return self;
}

- (void)dealloc
{
    [noteTextField release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    if (self.personalNote) {
        self.title = self.personalNote.title;
        self.noteTextField.text = self.personalNote.content;
    }
}

- (void)viewDidUnload
{
    [self setNoteTextField:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
