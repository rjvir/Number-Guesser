//
//  ViewController.m
//  Number Guesser
//
//  Created by Raj Vir on 5/26/14.
//  Copyright (c) 2014 Raj Vir. All rights reserved.
//

#import "ViewController.h"
@import AddressBook;

@interface ViewController ()

@end

@implementation ViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSLog(@"yoo");
    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 200, 40)];
    [button setBackgroundColor:[UIColor blueColor]];
    [button setTitle:@"What's my name?!!" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    CGRect bounds = self.view.bounds;
    button.center = CGPointMake(CGRectGetMidX(bounds), CGRectGetMidY(bounds));
    
    [self.view addSubview:button];

    // Do any additional setup after loading the view.
}

- (void)buttonTapped:(UIButton *)sender {
    
    UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 48, 48)];
    CGRect bounds = self.view.bounds;
    indicator.center = CGPointMake(CGRectGetMidX(bounds), CGRectGetMidY(bounds));
    [self.view addSubview:indicator];
    
    [indicator startAnimating];
    
    ABAddressBookRequestAccessWithCompletion(ABAddressBookCreateWithOptions(NULL, nil), ^(bool granted, CFErrorRef error) {
        if (!granted){
            //4
            NSLog(@"Just denied");
            return;
        }
        
        CFErrorRef *aError = NULL;
        ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, aError);
        CFArrayRef allPeople = ABAddressBookCopyArrayOfAllPeople(addressBook);
        CFIndex numberOfPeople = ABAddressBookGetPersonCount(addressBook);
        
        NSMutableDictionary *counts = [NSMutableDictionary dictionary];
        NSString *number;

        for(int i = 0; i < numberOfPeople; i++) {
            
            ABRecordRef person = CFArrayGetValueAtIndex( allPeople, i );
            
            ABMultiValueRef phoneNumbers = ABRecordCopyValue(person, kABPersonPhoneProperty);
            NSString *firstName = [(__bridge NSString *)(ABRecordCopyValue(person, kABPersonFirstNameProperty)) lowercaseString];
            NSString *lastName = [(__bridge NSString *)(ABRecordCopyValue(person, kABPersonLastNameProperty)) lowercaseString];
            
            if(lastName){
                if(counts[lastName]){
                    NSNumber *countObject = (NSNumber *) counts[lastName];
                    int count = [countObject intValue];
                    counts[lastName] = [NSNumber numberWithInt: count+1];
                } else {
                    [counts setValue:[NSNumber numberWithInt:1] forKey:lastName];
                    //                counts[lastName] = [NSNumber numberWithInt:1];
                }
                
            }
            
            int max = 0;
            
            for (CFIndex i = 0; i < ABMultiValueGetCount(phoneNumbers); i++) {
                NSString *phoneNumber = (__bridge_transfer NSString *) ABMultiValueCopyValueAtIndex(phoneNumbers, i);
                if([firstName isEqualToString:[self humanName]]){
                    if([counts[lastName] intValue] > max){
                        max = [counts[lastName] intValue];
                        number = phoneNumber;
                    }
                }
            }
        
        }
        
        // show alert
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [[[UIAlertView alloc] initWithTitle:@"Your number is..."
                                                              message:number
                                                             delegate:nil
                                                    cancelButtonTitle:@"OK"
                                                    otherButtonTitles:nil] show];
            [indicator stopAnimating];
        }];
        
    });
    
}

- (NSString *)humanName {
    NSString *deviceName = [[UIDevice currentDevice].name lowercaseString];
    for (NSString *string in @[@"’s iphone", @"’s ipad", @"’s ipod touch", @"’s ipod",
                               @"'s iphone", @"'s ipad", @"'s ipod touch", @"'s ipod",
                               @"s iphone", @"s ipad", @"s ipod touch", @"s ipod", @"iphone"]) {
        NSRange ownershipRange = [deviceName rangeOfString:string];
        
        if (ownershipRange.location != NSNotFound) {
            return [[deviceName substringToIndex:ownershipRange.location] componentsSeparatedByString:@" "][0];
        }
    }
    
    return [UIDevice currentDevice].name;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
