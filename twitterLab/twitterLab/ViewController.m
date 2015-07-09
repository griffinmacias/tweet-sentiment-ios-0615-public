//
//  ViewController.m
//  twitterLab
//
//  Created by Mason Macias on 7/9/15.
//  Copyright (c) 2015 Mason Macias. All rights reserved.
//

#import "ViewController.h"
#import <STTwitter/STTwitter.h>
@interface ViewController ()
@property (nonatomic, strong) NSMutableArray *formattedMentions;
@property (nonatomic, strong) NSMutableArray *sentiments;
@property (weak, nonatomic) IBOutlet UILabel *averageNumberLabel;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.sentiments = [NSMutableArray array];
    [self getMentionsAndReturnFormattedMention];
    
}

- (void)getMentionsAndReturnFormattedMention
{
    STTwitterAPI *twitter = [STTwitterAPI twitterAPIAppOnlyWithConsumerKey:@"zfkFrXsTV6teGOZtMwHx09lwI"
                                                            consumerSecret:@"VO3NYpNoXpP6fKdOztXeCrCDB8iS9yySFdBneVEqv7uuxuJk3n"];
    
    [twitter verifyCredentialsWithUserSuccessBlock:^(NSString *username, NSString *userID) {
        
        [twitter getSearchTweetsWithQuery:@"@FlatironSchool" successBlock:^(NSDictionary *searchMetadata, NSArray *statuses)
         
        {
            
            for (NSInteger i = 0; i < statuses.count; i++) {
                NSString *mention = statuses[i][@"text"];
                
                NSString *escapedMention = [mention stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]];

                NSURLSession *urlSession = [NSURLSession sharedSession];
                
                NSString *baseURL = @"http://www.sentiment140.com/api/classify?text=";
                
                NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",baseURL,escapedMention]];
                
                NSURLSessionDataTask *task = [urlSession dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                    
                    NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                    [self.sentiments addObject:dictionary[@"results"][@"polarity"]];
                    if (self.sentiments.count == statuses.count) {
                        CGFloat totalNumber = 0;
                        for (NSNumber *number in self.sentiments) {
                           totalNumber = number.floatValue + totalNumber;
                        }
                        
                        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                             self.averageNumberLabel.text = [NSString stringWithFormat:@"%f",totalNumber / self.sentiments.count];
                        }];
                      
                    
                    
                    }
                }];
        
                      [task resume];
        }
            
        } errorBlock:^(NSError *error) {
            NSLog (@"Error:%@",error);
        }];
        
        
    } errorBlock:^(NSError *error) {
        NSLog (@"Error:%@",error);
    }];
}

- (void)getSentimentWithCompletion:(void (^)(NSArray *result))block
{
    
  [self getMentionsAndReturnFormattedMention];
    
    
   
    
    
  
    
}




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
