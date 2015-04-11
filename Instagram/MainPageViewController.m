//
//  MainPageViewController.m
//  Instagram
//
//  Created by Mert Akanay on 4/6/15.
//  Copyright (c) 2015 MobileMakers. All rights reserved.
//

#import "MainPageViewController.h"
#import <Parse/Parse.h>
#import "CustomTableViewCell.h"
#import "Image.h"
#import "DetailPictureViewController.h"

@interface MainPageViewController ()<UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate, UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property NSMutableArray *imagesObjectsArray;
@property (strong, nonatomic) Image *imageObject;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *logOutButton;
@property BOOL hasLiked;
@property NSIndexPath *someIndexPath;
@end

@implementation MainPageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.imageObject = [Image new];
    self.hasLiked = false;





}
-(void)viewWillAppear:(BOOL)animated{
    self.imagesObjectsArray = [NSMutableArray new];
    NSMutableArray *listOfUser = [NSMutableArray new];

    User *currentUser = [User currentUser];
    PFRelation *followings = currentUser.followings;
    [[followings query] findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        for (User *user in objects) {
            NSLog(@"%@",user.username);


            [listOfUser addObject:user.username];

        }
        [listOfUser addObject:currentUser.username];
        
        PFQuery *query = [Image query];
        [query whereKey:@"username" containedIn:listOfUser];
        [query orderByDescending:@"createdAt"];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (!error) {
                // The find succeeded.
                NSLog(@"Successfully retrieved %lu images.", (unsigned long)objects.count);

                self.imagesObjectsArray = objects.copy;



                [self.tableView reloadData];


            } else {
                // Log details of the failure
                NSLog(@"Error: %@ %@", error, [error userInfo]);
            }
        }];

    }];




}

//On Double Tap - the user is able to like the picture. The heart overlaying the the image appears when the user taps on the image.
- (void)doubleTapGestureCaptured:(UITapGestureRecognizer*)gesture{
    NSLog(@"Left Image clicked");


    UIImageView *imageV = (UIImageView *)gesture.view;
    NSInteger row = imageV.tag;
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
    CustomTableViewCell *cell = (CustomTableViewCell*)[self.tableView cellForRowAtIndexPath:indexPath];


    //hasLiked
    if (self.hasLiked == false) {
        self.hasLiked = true;

        //increment the like counts
        self.imageObject = self.imagesObjectsArray[indexPath.row];
        cell.heartImage.image = [UIImage imageNamed:@"heart.png"];

        [self.tableView reloadData];

        [self.imageObject incrementKey:@"likesCounter" byAmount:[NSNumber numberWithInt:1]];
        [self.imageObject saveInBackground];

        [UIView animateWithDuration:(.5) animations:^{
            cell.heartImage.alpha = 1.0;

        } completion:^(BOOL finished) {
            [UIView animateWithDuration:.5 animations:^{

                cell.heartImage.alpha = 0.0;
            }];
        }];

    } else {

        //increment the like counts
        self.imageObject = self.imagesObjectsArray[indexPath.row];
        cell.heartImage.image = [UIImage imageNamed:@"brokenheart"];

        [self.tableView reloadData];

        [self.imageObject incrementKey:@"likesCounter" byAmount:[NSNumber numberWithInt:-1]];
        [self.imageObject saveInBackground];
        self.hasLiked = false;

        [UIView animateWithDuration:(.5) animations:^{
            cell.heartImage.alpha = 1.0;

        } completion:^(BOOL finished) {
            [UIView animateWithDuration:.5 animations:^{

                cell.heartImage.alpha = 0.0;
            }];
        }];

    }


}


- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    return YES;
}

#pragma marks - UITableView Delegate Methods


-(CustomTableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{

    self.someIndexPath = indexPath;
    CustomTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CellID"];
    // cell.imageInfoText.text = @"Hi";



    self.imageObject = self.imagesObjectsArray[indexPath.row];

    //get the number of likes

    NSNumber *numberOfLikes = self.imageObject.likesCounter;

    if (numberOfLikes == nil) {
        self.imageObject.likesCounter = 0;
        numberOfLikes = 0;

    }

    //image text formatting
    cell.imageInfoText.text = [NSString stringWithFormat:@"%@ Likes \n%@ %@", numberOfLikes, self.imageObject.username, self.imageObject.imageDescription];

    //set the user for of person who posted.
    cell.imageOwnerUsername.text = self.imageObject.username;





    //username attributted text
    NSRange range = [cell.imageInfoText.text rangeOfString:[NSString stringWithFormat:@"%@ Likes \n%@", numberOfLikes, self.imageObject.username]];

    NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc]initWithString:cell.imageInfoText.text];
    [attributedText setAttributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:17.0f]} range:range];
    [attributedText addAttribute:NSForegroundColorAttributeName value:[UIColor blueColor] range:range];
    [cell.imageInfoText  setAttributedText:attributedText];

    cell.imageInfoText.attributedText = attributedText;

    cell.imageInfoText.tag = indexPath.row;
    NSLog(@"\n\n row = %li", (long)indexPath.row);






    PFQuery *query = [User query];
    [query whereKey:@"username" equalTo:self.imageObject.username];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if (!error) {


            PFFile *someFile = ((User *)object).profileImage;

            [someFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {



                UIImage *profileImage = [UIImage imageWithData:data];
                cell.imageOwnerProfilePicture.image = profileImage;
                cell.imageOwnerProfilePicture.layer.cornerRadius = cell.imageOwnerProfilePicture.frame.size.height / 2;
                cell.imageOwnerProfilePicture.layer.masksToBounds = YES;
                cell.imageOwnerProfilePicture.layer.borderWidth = 2.0;

            }];



        } else {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];



    [self.imageObject.imageFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {

        if (!error){


            UIImage *cellImage = [UIImage imageWithData:data];
            //UIImage *userImage = [UIImage imagewithdata]


            cell.feedImage.image = cellImage;
            //cell.imageOwnerProfilePicture =
            cell.feedImage.clipsToBounds = true;
        }
    }];

    cell.feedImage.userInteractionEnabled = YES;
    cell.feedImage.tag = indexPath.row;

    UITapGestureRecognizer *tapped = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTapGestureCaptured:)];
    tapped.numberOfTapsRequired = 2;
    [cell.feedImage addGestureRecognizer:tapped];

    //set the tag image.
    cell.feedImage.tag = indexPath.row;
    
    
    
    
    
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{



}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.imagesObjectsArray.count;
}

- (IBAction)logOutButtonTapped:(UIBarButtonItem *)sender {
    [PFUser logOut];
    
}


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{

    DetailPictureViewController *detailVC = segue.destinationViewController;
    NSLog(@"\n\n\nshit  %li",((UIGestureRecognizer *)sender).view.tag);
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:((UIGestureRecognizer *)sender).view.tag inSection:0];
    CustomTableViewCell *cell = (CustomTableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];

    detailVC.photo = self.imagesObjectsArray[self.someIndexPath.row];

    //detailVC.photoImage = cell.feedImage.image;
    //self.imagesObjectsArray[((UIGestureRecognizer *)sender).view.tag];
}

@end
