//
//  NeighborListViewController.m
//  NeighborMe
//
//  Created by Aditya Herlambang on 11/22/10.
//  Copyright 2010 University of Arizona. All rights reserved.
//

#import "NeighborListViewController.h"
#import "JSON.h"

@implementation NeighborListViewController
@synthesize mapViewController;
@synthesize childController;

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	self.tableView.rowHeight  = 75;
	mapViewController = [[NeighborMapViewController alloc] init];
	//[self presentModalViewController:self.navigationController animated:YES];
	self.navigationItem.title = @"Neighbors";
	self.navigationController.navigationBar.tintColor = [UIColor blackColor];
	UIBarButtonItem * test = [[UIBarButtonItem alloc] initWithTitle:@"Map" style:UIBarButtonItemStyleBordered target:self action:@selector(toggleAction:)];
	self.navigationItem.rightBarButtonItem = test;	
    [super viewDidLoad];
	responseData = [[NSMutableData data] retain];
	NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.adityaherlambang.me/webservice.php?user=all&format=json"]];
	[[NSURLConnection alloc] initWithRequest:request delegate:self];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
	[responseData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
	[responseData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
	NSLog(@"Connection failed: %@", [error description]);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	[connection release];
	
	NSString *responseString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
	[responseData release];
	
	results = [[responseString JSONValue] retain];
	[self.tableView reloadData];
}


-(IBAction) toggleAction:(id) sender {
	[UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:1.0];  
    [UIView setAnimationTransition:UIViewAnimationTransitionCurlUp forView:self.view cache:YES];
	
	//if(self.navigationItem.rightBarButtonItem.title == @"List"){
		self.navigationItem.rightBarButtonItem.title = @"Map";
		//[mapViewController.view removeFromSuperview];
	//}else {
		[self.navigationController pushViewController:mapViewController animated:YES];
	//	[mapViewController.view removeFromSuperview];
		//[self.view addSubview:mapViewController.view];
		//[self.view sendSubviewToBack:self.view];
		//self.navigationItem.title = @"Neighbor Map";
		//self.navigationItem.rightBarButtonItem.title = @"List";
		//[navController release];
	//}
	
	[UIView commitAnimations];
	
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
	//return [_userInfo.friendsInfo count];
	NSLog(@"Number of rows: %d", [results count]);
	return [results count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
	if (cell == nil){
		cell = [[[UITableViewCell alloc] initWithStyle: UITableViewCellStyleSubtitle reuseIdentifier:@"Cell"] autorelease];
	}
	
	 NSMutableDictionary *cellValue = [[results objectAtIndex:indexPath.row] objectForKey:@"user"];
	 
	 NSString *picURL = [cellValue objectForKey:@"PROF_PIC"];
	 if ((picURL != (NSString *) [NSNull null]) && (picURL.length !=0)) {
	 NSData *imgData = [[[NSData dataWithContentsOfURL:
	 [NSURL URLWithString:
	 [cellValue objectForKey:@"PROF_PIC"]]] autorelease] retain];
	 cell.image = [[UIImage alloc] initWithData:imgData];
	 
	 } else {
	 cell.image = nil;
	 }
	
	//NSLog(@"Name is : %@", [cellValue objectForKey:@"NAME"]);
	cell.textLabel.text = [cellValue objectForKey:@"NAME"];
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}


/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */


/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
 
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
 }   
 else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }   
 }
 */


/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
 }
 */


/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */


#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
	
	childController = [[NeighborProfileViewController alloc] initWithNibName:@"NeighborProfileViewController" bundle:nil];
	
	childController.title = [[[results objectAtIndex:[indexPath row]] objectForKey:@"user"] objectForKey:@"NAME"];
    childController.uid = [[[results objectAtIndex:[indexPath row]] objectForKey:@"user"] objectForKey:@"UID"];
	[self.navigationController pushViewController:childController animated:YES];
		 
	//if (self.profileViewController == nil){
	//profileViewController = [[ProfileViewController alloc] init];
	//self.profileViewController.user_info = [_userInfo.friendsInfo objectAtIndex:indexPath.row];
	//self.profileViewController = profile;
	//[profile release];
	//}
	
	//NSMutableDictionary *cellValue = [_userInfo.friendsInfo objectAtIndex:indexPath.row];
	
	//profileViewController.user_info = [_userInfo.friendsInfo objectAtIndex:indexPath.row];
	
	//[self.navigationController pushViewController:profileViewController animated:YES];
	
}


/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
	[results release];
	[childController release];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}


@end
