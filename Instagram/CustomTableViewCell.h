//
//  CustomTableViewCell.h
//  Instagram
//
//  Created by Ronald Hernandez on 4/7/15.
//  Copyright (c) 2015 MobileMakers. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *feedImage;
@property (weak, nonatomic) IBOutlet UITextView *imageInfoText;

@property (weak, nonatomic) IBOutlet UIImageView *imageOwnerProfilePicture;
@property (weak, nonatomic) IBOutlet UILabel *imageOwnerUsername;

@property (weak, nonatomic) IBOutlet UIImageView *heartImage;

@end
