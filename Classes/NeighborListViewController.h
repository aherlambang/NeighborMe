//
//  NeighborListViewController.h
//  NeighborMe
//
//  Created by Aditya Herlambang on 11/22/10.
//  Copyright 2010 University of Arizona. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NeighborMapViewController.h"
#import "NeighborProfileViewController.h"

@interface NeighborListViewController : UITableViewController<UITableViewDelegate, UITableViewDataSource> {
	//UIBarButtonItem * toggle;
	NeighborMapViewController * mapViewController;
	NeighborProfileViewController * childController;
	NSMutableData *responseData;
	NSArray *results;
}

@property(nonatomic, retain) NeighborMapViewController * mapViewController;
//@property(nonatomic, retain) IBOutlet UIBarButtonItem * toggle;
@property(nonatomic, retain) NeighborProfileViewController * childController;

- (IBAction)toggleAction:(id)sender;	// when the toggle button is clicked

@end

