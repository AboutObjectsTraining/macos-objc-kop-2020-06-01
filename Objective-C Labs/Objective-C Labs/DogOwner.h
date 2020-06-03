#import <Foundation/Foundation.h>
#import "Person.h"
#import "Dog.h"

@interface DogOwner : Person <DogDelegate>
{
    NSMutableArray *_dogs;
}

@property (strong, nonatomic) NSArray *dogs;
//- (NSArray *)dogs;

- (void)addDogs:(NSArray *)newDogs;

@end
