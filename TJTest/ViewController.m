//
//  ViewController.m
//  TJTest
//
//  Created by Andrey Nikolin on 22.05.15.
//  Copyright (c) 2015 Andrey Nikolin. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController
{
    NSArray *tableData;
    NSURL *apilink;
}

- (void)refresh:(UIRefreshControl *)refreshControl {
    [self updateData];
    NSLog(@"Updating data from server");
    [refreshControl endRefreshing];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    [self.SearchTable addSubview:refreshControl];
    self->apilink = [NSURL URLWithString:@"https://itunes.apple.com/search?term=jack&limit=200&country=RU"];
    self.SearchTable.dataSource = self;
    self.SearchTable.delegate = self;
    [self updateData];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void) updateData
{
    [ViewController downloadDataFromURL:self->apilink withCompletionHandler:^(NSData *data) {
        if (data != nil) {
            NSError *error;
            NSMutableDictionary *returnedDict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
            
            self->tableData = [returnedDict objectForKey:@"results"];
            
            NSLog(@"%@", [self->tableData objectAtIndex:0]);
            if (error != nil) {
                UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
                
                messageLabel.text = @"Connection error. Can't load data(Pull to Refresh)";
                messageLabel.textColor = [UIColor blackColor];
                messageLabel.numberOfLines = 0;
                messageLabel.textAlignment = NSTextAlignmentCenter;
                messageLabel.font = [UIFont fontWithName:@"System" size:30];
                [messageLabel sizeToFit];
                self.SearchTable.backgroundView = messageLabel;
                self.SearchTable.separatorStyle = UITableViewCellSeparatorStyleNone;
                NSLog(@"%@", [error localizedDescription]);
            }
            else{
                [self.SearchTable reloadData];
            }
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

+(void)downloadDataFromURL:(NSURL *)url withCompletionHandler:(void (^)(NSData *))completionHandler{
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
    
    
    NSURLSessionDataTask *task = [session dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        if (error != nil) {
            NSLog(@"%@", [error localizedDescription]);
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                completionHandler(data);
            }];
        }
        else{
            
            NSInteger HTTPStatusCode = [(NSHTTPURLResponse *)response statusCode];
            
            
            if (HTTPStatusCode != 200) {
                NSLog(@"HTTP status code = %ld", (long)HTTPStatusCode);
            }
            
            
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                completionHandler(data);
            }];
        }
    }];
    
    
    [task resume];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    long selectedRow = indexPath.row;
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[[self->tableData objectAtIndex:selectedRow] objectForKey:@"trackViewUrl"]]];
    NSLog(@"touch on row %ld", selectedRow);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [tableData count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"SearchResult";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    NSString *image = [[tableData objectAtIndex:indexPath.row] objectForKey:@"artworkUrl100"];
    NSURL *imageurl = [NSURL URLWithString:image];
    NSData *imageData = [NSData dataWithContentsOfURL:imageurl];
    NSString *title = [[tableData objectAtIndex:indexPath.row] objectForKey:@"artistName"];
    NSString *description = [[tableData objectAtIndex:indexPath.row] objectForKey:@"longDescription"];
    
    cell.imageView.image = [[UIImage alloc] initWithData:imageData];
    cell.textLabel.text = title;
    cell.detailTextLabel.text = description;
    cell.detailTextLabel.numberOfLines = 12;
    
    return cell;
}

@end
