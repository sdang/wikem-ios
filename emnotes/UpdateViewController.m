//
//  UpdateViewController.m
//  TabViewTest
//
//  Created by Sabin Dang on 4/1/11.
//  Copyright 2011 sabindang.com. All rights reserved.
//

#import "UpdateViewController.h"
#import "Category.h"
#import "Note.h"
#import "TBXML.h"
#import "NSString+HTML.h"

@implementation UpdateViewController
@synthesize managedObjectContext;
@synthesize tabBarItem;



- (void)addNoteFromXMLElement:(TBXMLElement *)subElement
{
    NSString *content = [NSString stringWithString:[TBXML textForElement:[TBXML childElementNamed:@"content" parentElement:subElement]]];
    NSSet *categories = [NSSet setWithObject:[Category categoryWithTitle:[TBXML textForElement:[TBXML childElementNamed:@"folder" parentElement:subElement]] inManagedObjectContext:self.managedObjectContext]];
    if (![[categories anyObject] isKindOfClass:[Category class]]) {
        NSLog(@"Found a note without a category");
        categories = [NSSet setWithObject:[Category categoryWithTitle:@"Uncategorized" inManagedObjectContext:self.managedObjectContext]];
    }
    
    // [TBXML textForElement:[TBXML childElementNamed:@"content" parentElement:subElement]];
    [Note noteWithName:[TBXML textForElement:[TBXML childElementNamed:@"name" parentElement:subElement]]
                author:[TBXML textForElement:[TBXML childElementNamed:@"author" parentElement:subElement]]
               content:[content stringByDecodingHTMLEntities]
            lastUpdate:[NSDate date]
            categories:categories
inManagedObjectContext:self.managedObjectContext];
}


- (void)parseXMLDatabaseFile {
    NSLog(@"Running parse xml");
    // NSURL *theURL = [NSURL URLWithString:@"http://dl.android.wikem.org/database.xml"];
    // NSURL *theURL = [NSURL URLWithString:@"file:///database.xml"];
    // TBXML *tbxml = [TBXML tbxmlWithURL:theURL];
    // NSLog(@"%@", [NSString stringWithContentsOfURL:theURL encoding:nil error:nil]);    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"database" ofType:@"xml"];
    NSString *content = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:NULL];
    

    TBXML *tbxml = [TBXML tbxmlWithXMLString:content];
    
    if (tbxml.rootXMLElement) {
        
        // Parse Categories
        TBXMLElement *categories = [TBXML childElementNamed:@"categories" parentElement:tbxml.rootXMLElement];
        TBXMLElement *subElement = categories->firstChild;
        do {
            NSString *title = [NSString stringWithString:[TBXML valueOfAttributeNamed:@"title" forElement:subElement]];
            [Category categoryWithTitle:title inManagedObjectContext:self.managedObjectContext];
        } while ((subElement = subElement->nextSibling));
        
        // Parse Notes
        TBXMLElement *notes = [TBXML childElementNamed:@"pages" parentElement:tbxml.rootXMLElement];
        subElement = notes->firstChild;
        do {
            // NSLog(@"%@", [TBXML valueOfAttributeNamed:@"id" forElement:subElement]);
            [self addNoteFromXMLElement:subElement];
            
        } while ((subElement = subElement->nextSibling));
        
        [self.managedObjectContext save:nil];
        
    }

}

- (IBAction)clearWikEMData
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    request.entity = [NSEntityDescription entityForName:@"Note" inManagedObjectContext:self.managedObjectContext];
    [request setIncludesPropertyValues:NO];
    NSArray *notes = [self.managedObjectContext executeFetchRequest:request error:nil];
    for (Note *note in notes) {
        [self.managedObjectContext deleteObject:note];
    }
    [request release];
    
    NSFetchRequest *requestC = [[NSFetchRequest alloc] init];
    requestC.entity = [NSEntityDescription entityForName:@"Category" inManagedObjectContext:self.managedObjectContext];
    [requestC setIncludesPropertyValues:NO];
    NSArray *categories = [self.managedObjectContext executeFetchRequest:requestC error:nil];
    for (Category *category in categories) {
        [self.managedObjectContext deleteObject:category];
    }
    
    [requestC release];


    
}




- (void)setupTabBarItem
{
    UITabBarItem *item = [[UITabBarItem alloc] initWithTitle:@"Update" image:[UIImage imageNamed:@"10-medical.png"] tag:0];
    self.tabBarItem = item;
    [item release];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        [self setupTabBarItem];
    }
    return self;
}

- (void)dealloc
{
    [tabBarItem release];
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
}

- (void)viewDidUnload
{
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
