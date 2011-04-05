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
#import "AcceptLicense.h"

@implementation UpdateViewController
@synthesize tabBarItem;
@synthesize ranInitialSetup, displayingLicense, licenseViewController;
@synthesize persistentStoreCoordinator;



- (void)addNoteFromXMLElement:(TBXMLElement *)subElement context:(NSManagedObjectContext *)managedObjectContext
{
    NSString *content = [NSString stringWithString:[TBXML textForElement:[TBXML childElementNamed:@"content" parentElement:subElement]]];
    NSSet *categories = [NSSet setWithObject:[Category categoryWithTitle:[TBXML textForElement:[TBXML childElementNamed:@"folder" parentElement:subElement]] inManagedObjectContext:managedObjectContext]];
    if (![[categories anyObject] isKindOfClass:[Category class]]) {
        NSLog(@"Found a note without a category");
        categories = [NSSet setWithObject:[Category categoryWithTitle:@"Uncategorized" inManagedObjectContext:managedObjectContext]];
    }
    
    // [TBXML textForElement:[TBXML childElementNamed:@"content" parentElement:subElement]];
    [Note noteWithName:[TBXML textForElement:[TBXML childElementNamed:@"name" parentElement:subElement]]
                author:[TBXML textForElement:[TBXML childElementNamed:@"author" parentElement:subElement]]
               content:[content stringByDecodingHTMLEntities]
            lastUpdate:[NSDate date]
            categories:categories
inManagedObjectContext:managedObjectContext];
}


- (void)parseXMLDatabaseFile {
    dispatch_queue_t parseQueue = dispatch_queue_create("Parse XML Queue", NULL);
    dispatch_async(parseQueue, ^{
        [self disableAllTabBarItems:YES];
        NSManagedObjectContext *managedObjectContext = [[NSManagedObjectContext alloc] init];
        [managedObjectContext setPersistentStoreCoordinator:self.persistentStoreCoordinator];
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
                [Category categoryWithTitle:title inManagedObjectContext:managedObjectContext];
            } while ((subElement = subElement->nextSibling));
            
            // Parse Notes
            TBXMLElement *notes = [TBXML childElementNamed:@"pages" parentElement:tbxml.rootXMLElement];
            subElement = notes->firstChild;
            do {
                // NSLog(@"%@", [TBXML valueOfAttributeNamed:@"id" forElement:subElement]);
                [self addNoteFromXMLElement:subElement context:managedObjectContext];
                
            } while ((subElement = subElement->nextSibling));
            
            [managedObjectContext save:nil];
            [self disableAllTabBarItems:NO];
        }
    });

}

- (IBAction)clearWikEMData
{
    [self disableAllTabBarItems:YES];
    dispatch_queue_t deleteQueue = dispatch_queue_create("Delete Queue", NULL);
    dispatch_async(deleteQueue, ^{
        NSLog(@"Deleting All Notes");
        NSManagedObjectContext *managedObjectContext = [[NSManagedObjectContext alloc] init];
        [managedObjectContext setPersistentStoreCoordinator:self.persistentStoreCoordinator];
        
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        request.entity = [NSEntityDescription entityForName:@"Note" inManagedObjectContext:managedObjectContext];
        [request setIncludesPropertyValues:NO];
        NSArray *notes = [managedObjectContext executeFetchRequest:request error:nil];
        for (Note *note in notes) {
            [managedObjectContext deleteObject:note];
        }
        [request release];
        
        NSFetchRequest *requestC = [[NSFetchRequest alloc] init];
        requestC.entity = [NSEntityDescription entityForName:@"Category" inManagedObjectContext:managedObjectContext];
        [requestC setIncludesPropertyValues:NO];
        NSArray *categories = [managedObjectContext executeFetchRequest:requestC error:nil];
        for (Category *category in categories) {
            [managedObjectContext deleteObject:category];
        }
        
        [requestC release];
        [managedObjectContext save:nil];
        [managedObjectContext release];
        NSLog(@"Deleted All Notes");
    });
    [self disableAllTabBarItems:NO];
}

- (void)userDidAcceptLicense:(BOOL)status {
    if (status) {        
        NSLog(@"Updater Class Knows User Accepted Disclaimer");
        [self parseXMLDatabaseFile];
        [self updateAvailable:NO];
    }
}


#pragma mark - Tab Bar Controls

- (void)setupTabBarItem
{
    UITabBarItem *item = [[UITabBarItem alloc] initWithTitle:@"Update" image:[UIImage imageNamed:@"10-medical.png"] tag:0];
    self.tabBarItem = item;
    [item release];
}

- (void)updateAvailable:(BOOL)status
{
    if (status) {
        [[[[[self tabBarController] tabBar] items] objectAtIndex:3] setBadgeValue:@""];
    } else {
        [[[[[self tabBarController] tabBar] items] objectAtIndex:3] setBadgeValue:nil];
    }
    
}

- (void)disableAllTabBarItems:(BOOL)status {
    BOOL x;
    if (status) {
        x = FALSE;
    } else {
        x = TRUE;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [[[[[self tabBarController] tabBar] items] objectAtIndex:0] setEnabled:x];
        [[[[[self tabBarController] tabBar] items] objectAtIndex:1] setEnabled:x];
        [[[[[self tabBarController] tabBar] items] objectAtIndex:2] setEnabled:x];
    });
    
}



#pragma mark - View lifecycle

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
    [persistentStoreCoordinator release];
    [licenseViewController release];
    [tabBarItem release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated {
    
    if (!self.ranInitialSetup && !self.displayingLicense) {
        [self disableAllTabBarItems:YES];
        self.licenseViewController = [[AcceptLicense alloc] init];
        if (!ranInitialSetup) {
            UIApplication *app = [UIApplication sharedApplication];
            CGRect finalRect = CGRectMake(0.0,0, self.view.bounds.size.width, self.view.bounds.size.height);
            CGRect hiddenRect = CGRectMake(0.0,self.view.bounds.size.height, self.view.bounds.size.width, self.view.bounds.size.height - app.statusBarFrame.size.height);
            licenseViewController.view.frame = hiddenRect;
            licenseViewController.delegate = self;
            
            [UIView transitionWithView:licenseViewController.view
                              duration:0.5
                               options:UIViewAnimationOptionTransitionCurlDown
                            animations:^{ licenseViewController.view.frame = finalRect; }
                            completion:NULL];
            
            
            [self.view addSubview:licenseViewController.view];

            self.displayingLicense = YES;
            [self updateAvailable:YES];
        }
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    self.licenseViewController = nil;
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
