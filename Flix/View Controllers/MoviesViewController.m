//
//  MoviesViewController.m
//  Flix
//
//  Created by Sarah Wen Gu on 6/23/21.
//

#import "MoviesViewController.h"
#import "MovieCell.h"
#import "UIImageView+AFNetworking.h"
#import "AFNetworking.h"
#import "DetailsViewController.h"
#import "SVProgressHUD.h"

@interface MoviesViewController () <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray *movies;
@property (nonatomic, strong) NSArray *filteredData;
@property (nonatomic, strong) UIRefreshControl *refreshControl;

@end

@implementation MoviesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status){
          NSLog(@"status changed");
         //check for isReachable here
        if ([[AFNetworkReachabilityManager sharedManager] isReachable])
        {
            self.tableView.dataSource = self;
            self.tableView.delegate = self;
            self.searchBar.delegate = self;
            [SVProgressHUD show];
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [self fetchMovies];
                
            });

            self.refreshControl = [[UIRefreshControl alloc] init];
            [self.refreshControl addTarget:self action:@selector(fetchMovies) forControlEvents:UIControlEventValueChanged];
            [self.tableView addSubview:self.refreshControl];
        }
        else
        {
            [self alertControl];
        }
        
    }];

    
    // Do any additional setup after loading the view.


    

}


- (void)alertControl {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error" message:@"Unable to Load Content" preferredStyle:(UIAlertControllerStyleAlert)];
    // create a cancel action
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel"
                                                        style:UIAlertActionStyleCancel
                                                      handler:^(UIAlertAction * _Nonnull action) {
                                                             // handle cancel response here. Doing nothing will dismiss the view.
                                                      }];
    // add the cancel action to the alertController
    [alert addAction:cancelAction];

    // create an OK action
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK"
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * _Nonnull action) {
                                                             // handle response here.
                                                     }];
    // add the OK action to the alert controller
    [alert addAction:okAction];
    [self presentViewController:alert animated:YES completion:^{
        // optional code for what happens after the alert controller has finished presenting
    }];
}

- (void)fetchMovies{
    
    NSURL *url = [NSURL URLWithString:@"https://api.themoviedb.org/3/movie/now_playing?api_key=a07e22bc18f5cb106bfe4cc1f83ad8ed"]; //swap in desired endpoint (instead of now_playing)
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10.0];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
           if (error != nil) {
               NSLog(@"%@", [error localizedDescription]);
           }
           else {
               NSDictionary *dataDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
               
               dispatch_async(dispatch_get_main_queue(),^{
                   [SVProgressHUD dismiss];
               });
               
               NSLog(@"%@", dataDictionary);
               
               self.movies = dataDictionary[@"results"];
               self.filteredData = self.movies;
               for (NSDictionary *movie in self.movies){
                   NSLog(@"%@", movie[@"title"]);
               }
            
               [self.tableView reloadData];
               // TODO: Get the array of movies
               // TODO: Store the movies in a property to use elsewhere
               // TODO: Reload your table view data
           }
           [self.refreshControl endRefreshing];
       }];
    [task resume];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.filteredData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MovieCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MovieCell"];
    //UITableViewCell *cell = [[UITableViewCell alloc] init];
    
    //NSLog(@"%@", [NSString stringWithFormat:@"row: %d, section %d", indexPath.row, indexPath.section]);
    //NSDictionary *movie = self.movies[indexPath.row];
    NSDictionary *movie = self.filteredData[indexPath.row];
    cell.titleLabel.text = movie[@"title"];
    cell.synopsisLabel.text = movie[@"overview"];
    NSDictionary *genres = @{@28:@"Action", @12:@"Adventure", @16:@"Animation",@35:@"Comedy", @80:@"Crime", @99:@"Documentary", @18:@"Drama", @10751:@"Family", @14:@"Fantasy", @36:@"History",@27:@"Horror",@10402:@"Music",@9648:@"Mystery", @10749:@"Romance", @878:@"Science Fiction", @10770:@"TV Movie", @53:@"Thriller",   @10752:@"War", @37:@"Western"   };
    
    NSArray *movieGenres = movie[@"genre_ids" ];
    cell.genreLabel.text = @""; 
    for (id myGenre in movieGenres){
        NSString *named_genre = genres[myGenre];
        cell.genreLabel.text = [cell.genreLabel.text stringByAppendingFormat:@"%@, ", named_genre];
    }
  //  cell.textLabel.text = movie[@"title"];
    NSString *baseURLString_high = @"https://image.tmdb.org/t/p/original";
    NSString *posterURLString = movie[@"poster_path"];
    NSString *fullPosterURLString_high = [baseURLString_high stringByAppendingString:posterURLString];
    
    NSURL *posterURL_high = [NSURL URLWithString:fullPosterURLString_high];
    NSURLRequest *request_high = [NSURLRequest requestWithURL:posterURL_high];
    
    NSString *baseURLString_low = @"https://image.tmdb.org/t/p/w45";
    NSString *fullPosterURLString_low = [baseURLString_low stringByAppendingString:posterURLString];
    NSURL *posterURL_low = [NSURL URLWithString:fullPosterURLString_low];
    NSURLRequest *request_low = [NSURLRequest requestWithURL:posterURL_low];
    
    cell.posterView.image = nil;
    
    [cell.posterView setImageWithURLRequest:request_low placeholderImage:nil success:^(NSURLRequest *  imageRequest, NSHTTPURLResponse * imageResponse, UIImage * smallImage) {
        if(imageResponse != nil){
            cell.posterView.alpha = 0.0;
            cell.posterView.image = smallImage;
            
            [UIView animateWithDuration:0.3 animations:^{
                cell.posterView.alpha = 1.0;
            } completion:^(BOOL finished){
                [cell.posterView setImageWithURLRequest:request_high
                                       placeholderImage:smallImage
                                                success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *largeImage){
                    cell.posterView.image = largeImage;
                }
                                                failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error){
                    NSLog(@"Error in image request");
                }];
            }];
        
        }
        else{
            [cell.posterView setImageWithURLRequest:request_high
                                   placeholderImage:smallImage
                                            success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *largeImage){
                cell.posterView.image = largeImage;
            }
                                            failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error){
                NSLog(@"Error in image request");
            }];
        }
    } failure:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, NSError * _Nonnull error) {
        NSLog(@"Error in image request");
    }];
    
    
//    NSString *baseURLString = @"https://image.tmdb.org/t/p/w500";
//    NSString *posterURLString = movie[@"poster_path"];
//    NSString *fullPosterURLString = [baseURLString stringByAppendingString:posterURLString];
//
//    NSURL *posterURL = [NSURL URLWithString:fullPosterURLString];
//
//    NSURLRequest *request = [NSURLRequest requestWithURL:posterURL];
//    cell.posterView.image = nil;
//
//   // [cell.posterView setImageWithURL:posterURL];
//    [cell.posterView setImageWithURLRequest:request placeholderImage:nil success:^(NSURLRequest *  imageRequest, NSHTTPURLResponse * imageResponse, UIImage * image) {
//        if(imageResponse){
//            cell.posterView.alpha = 0.0;
//            cell.posterView.image = image;
//
//            [UIView animateWithDuration:2 animations:^{
//                cell.posterView.alpha = 1.0;
//            }];
//
//        }
//        else{
//            cell.posterView.image = image;
//        }
//    } failure:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, NSError * _Nonnull error) {
//        NSLog(@"Error in image request");
//    }];
//
    return cell;
}
-(void)searchBar:(UISearchBar *)searchBar textDidChange:(nonnull NSString *)searchText{
    if(searchText.length != 0){
       NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(NSDictionary *evaluatedObject, NSDictionary *bindings){
            return [evaluatedObject[@"title"] containsString:searchText];
       }];
        
       // NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(title CONTAINS[cd] %@)", searchText];
        self.filteredData = [self.movies filteredArrayUsingPredicate:predicate];
    }
    else{
        self.filteredData = self.movies;
    }
    [self.tableView reloadData];
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    self.searchBar.showsCancelButton = YES;
}
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    self.searchBar.showsCancelButton = NO;
    self.searchBar.text = @"";
    [self.searchBar resignFirstResponder];
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    UITableViewCell *tappedCell = sender;
    NSIndexPath *indexPath = [self.tableView indexPathForCell:tappedCell];
    NSDictionary *movie = self.filteredData[indexPath.row];
    
    DetailsViewController *detailsViewController = [segue destinationViewController];
    detailsViewController.movie = movie; 
    NSLog(@"Tapping on a movie!");
    
}


@end
