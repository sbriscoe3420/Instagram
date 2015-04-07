//
//  SignUpViewController.m
//  Instagram
//
//  Created by Mert Akanay on 4/6/15.
//  Copyright (c) 2015 MobileMakers. All rights reserved.
//

#import "SignUpViewController.h"
#import <Parse/Parse.h>

@interface SignUpViewController ()<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UITextField *confirmPasswordTextField;
@property (weak, nonatomic) IBOutlet UITextField *fullNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;

@end

@implementation SignUpViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.userInteractionEnabled = YES;

}


//Helper method to display error to user.
-(void)displayAlert:(NSString *)error{


    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"Error in form" message:error delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];

    [alertView show];

}
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}
- (IBAction)onRegisterButtonPressed:(UIButton *)sender
{
    NSString *signUpError = @"";


    //first need to check if any of the fields are empty.

    if ([self.usernameTextField.text isEqualToString:@""] || [self.passwordTextField.text isEqualToString:@""] || [self.confirmPasswordTextField.text isEqualToString:@""] || [self.fullNameTextField.text isEqualToString:@""] || [self.emailTextField.text isEqualToString:@""]) {

        signUpError = @"One or more fields are blank. Please try again!";

    }else if (![self.passwordTextField.text isEqualToString:self.confirmPasswordTextField.text]){

        signUpError = @"Passwords do not match, please try again.";

    }else if ([self.passwordTextField.text length] < 8 || [self.confirmPasswordTextField.text length] < 8){

        signUpError = @"Password must be at least 8 characters long. Please try again.";

    }else {

        //declare all the parse variables needed sign up our user.
        PFUser *user = [PFUser user];
        user.username = self.usernameTextField.text;
        user.password = self.passwordTextField.text;
        user.email = self.emailTextField.text;
        user[@"name"] = self.fullNameTextField.text;



        [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            //if call is succcessful - let the user use the app and take them to next screen.
            if (!error)
            {
                [self performSegueWithIdentifier:@"toSelectFirstTimeFollowers" sender:self];
                
            } else {
                //else diplay an alert to the user.

                NSString *errorString = [error userInfo][@"error"];
                //signUpError = errorString;
                [self displayAlert:errorString];


            }
        }];
        
    }

    //display the error message
    if (![signUpError isEqualToString:@""]) {
        [self displayAlert:signUpError];
    }
  
}



@end