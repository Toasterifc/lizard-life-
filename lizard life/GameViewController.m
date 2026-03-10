#import "GameViewController.h"

@interface GameViewController ()
@property (nonatomic, strong) UIImageView *lizard;
@property (nonatomic, strong) NSMutableArray *flies;
@property (nonatomic, strong) NSMutableArray *barrels;
@property (nonatomic, strong) NSTimer *gameTimer;
@property (nonatomic, strong) NSTimer *spawnTimer;
@property (nonatomic, assign) NSInteger score;
@property (nonatomic, assign) NSInteger lives;
@property (nonatomic, strong) UILabel *scoreLabel;
@property (nonatomic, strong) UILabel *livesLabel;
@property (nonatomic, strong) UITapGestureRecognizer *gesture;
@property (nonatomic, assign) NSInteger highScore;
@property (nonatomic, strong) UILabel *highScoreLabel;
@end
@implementation GameViewController;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor greenColor];
    
    // Create lizard
    self.lizard = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"lizard.png"]];
    self.lizard.frame = CGRectMake(self.view.frame.size.width / 2 - 25, self.view.frame.size.height - 80, 50, 50);
    self.lizard.userInteractionEnabled = YES;
    [self.view addSubview:self.lizard];
    // Score Label
    self.score = 0;
    self.scoreLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 20, 100, 30)];
    self.scoreLabel.text = @"Score: 0";
    self.scoreLabel.font = [UIFont boldSystemFontOfSize:17];
    [self.view addSubview:self.scoreLabel];
    
    // Lives Label
    self.lives = 3;
    self.livesLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width - 80, 20, 100, 30)];
    self.livesLabel.text = @"Lives: 3";
    self.livesLabel.font = [UIFont boldSystemFontOfSize:17];
    [self.view addSubview:self.livesLabel];
    
    
    // High Score Label
    self.highScoreLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width / 2 - 75, 20, 150, 30)];
    self.highScoreLabel.text = [NSString stringWithFormat:@"High Score: %ld", (long)self.highScore];
    self.highScoreLabel.font = [UIFont boldSystemFontOfSize:17];
    self.highScoreLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:self.highScoreLabel];
    // Drag gesture recognizer
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(dragLizard:)];
    [self.lizard addGestureRecognizer:panGesture];
    
    // Initialize arrays
    self.flies = [NSMutableArray array];
    self.barrels = [NSMutableArray array];
    
    // Start game loop and spawning
    self.spawnTimer = [NSTimer scheduledTimerWithTimeInterval:0.4 target:self selector:@selector(spawnObject) userInfo:nil repeats:YES];
    self.gameTimer = [NSTimer scheduledTimerWithTimeInterval:0.02 target:self selector:@selector(updateGame) userInfo:nil repeats:YES];
}

- (void)dragLizard:(UIPanGestureRecognizer *)gesture {
    CGPoint translation = [gesture translationInView:self.view];
    CGFloat newX = self.lizard.center.x + translation.x;
    
    if (newX < self.lizard.frame.size.width / 2) {
        newX = self.lizard.frame.size.width / 2;
    } else if (newX > self.view.frame.size.width - self.lizard.frame.size.width / 2) {
        newX = self.view.frame.size.width - self.lizard.frame.size.width / 2;
    }
    
    self.lizard.center = CGPointMake(newX, self.lizard.center.y);
    [gesture setTranslation:CGPointZero inView:self.view];
}
- (void)spawnObject {
    int objectType = arc4random_uniform(2); // 0 = fly, 1 = barrel
    
    UIImageView *object;
    if (objectType == 0) {
        // Spawn a fly
        object = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"fly.png"]];
        object.frame = CGRectMake(arc4random_uniform(self.view.frame.size.width - 30), -30, 30, 30);
        [self.flies addObject:object];
    } else {
        // Spawn a barrel
        object = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Barrel_icon.png"]];
        object.frame = CGRectMake(arc4random_uniform(self.view.frame.size.width - 40), -40, 40, 40);
        [self.barrels addObject:object];
    }
    
    [self.view addSubview:object];
}

// Update game logic (move objects downward and check collisions)
- (void)updateGame {
    NSMutableArray *fliesToRemove = [NSMutableArray array];
    NSMutableArray *barrelsToRemove = [NSMutableArray array];
    
    for (UIImageView *fly in self.flies) {
        fly.center = CGPointMake(fly.center.x, fly.center.y + 2);
        
        if (CGRectIntersectsRect(self.lizard.frame, fly.frame)) {
            [fliesToRemove addObject:fly];
            self.score += 10;
            self.scoreLabel.text = [NSString stringWithFormat:@"Score: %ld", (long)self.score];
        }
        
        if (fly.frame.origin.y > self.view.frame.size.height) {
            [fliesToRemove addObject:fly];
        }
    }
    
    for (UIImageView *barrel in self.barrels) {
        barrel.center = CGPointMake(barrel.center.x, barrel.center.y + 3);
        
        if (CGRectIntersectsRect(self.lizard.frame, barrel.frame)) {
            [barrelsToRemove addObject:barrel];
            self.lives--;
            
            // Update Lives UI
            self.livesLabel.text = [NSString stringWithFormat:@"Lives: %ld", (long)self.lives];
            
            if (self.lives == 0) {
                [self gameOver];
                return;
            }
        }
        
        if (barrel.frame.origin.y > self.view.frame.size.height) {
            [barrelsToRemove addObject:barrel];
        }
    }
    
    for (UIImageView *fly in fliesToRemove) {
        [fly removeFromSuperview];
        [self.flies removeObject:fly];
    }
    
    for (UIImageView *barrel in barrelsToRemove) {
        [barrel removeFromSuperview];
        [self.barrels removeObject:barrel];
    }
}

- (void)gameOver {
    [self.spawnTimer invalidate];
    [self.gameTimer invalidate];
    
    if (self.score > self.highScore) {
        self.highScore = self.score;
        self.highScoreLabel.text = [NSString stringWithFormat:@"High Score: %ld", (long)self.highScore];
    }
    UILabel *gameOverLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width / 2 - 75, self.view.frame.size.height / 2 - 50, 150, 50)];
    gameOverLabel.text = @"Game Over";
    gameOverLabel.textColor = [UIColor redColor];
    gameOverLabel.font = [UIFont boldSystemFontOfSize:24];
    gameOverLabel.tag = 1001;
    gameOverLabel.textAlignment = NSTextAlignmentCenter;    [self.view addSubview:gameOverLabel];
    
    UIButton *restartButton = [UIButton buttonWithType:UIButtonTypeSystem];
    restartButton.frame = CGRectMake(self.view.frame.size.width / 2 - 50, self.view.frame.size.height / 2, 100, 40);
    [restartButton setTitle:@"Restart" forState:UIControlStateNormal];
    restartButton.titleLabel.font = [UIFont boldSystemFontOfSize:20];
    restartButton.tag = 1002;
    [restartButton addTarget:self action:@selector(restartGame) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:restartButton];
}
- (void)restartGame {
    [self.flies makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self.barrels makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self.flies removeAllObjects];
    [self.barrels removeAllObjects];
    [self.spawnTimer invalidate];
    [self.gameTimer invalidate];
    
    
    [[self.view viewWithTag:1001] removeFromSuperview]; // Game Over label
    [[self.view viewWithTag:1002] removeFromSuperview]; // Restart button
   
    self.score = 0;
    self.lives = 3;
    self.scoreLabel.text = @"Score: 0";
    self.livesLabel.text = @"Lives: 3";
    self.spawnTimer = [NSTimer scheduledTimerWithTimeInterval:0.4 target:self selector:@selector(spawnObject) userInfo:nil repeats:YES];
    self.gameTimer = [NSTimer scheduledTimerWithTimeInterval:0.02 target:self selector:@selector(updateGame) userInfo:nil repeats:YES];
}

@end
