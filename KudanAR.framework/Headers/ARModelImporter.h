#import <Foundation/Foundation.h>
#import <KudanAR/ARNode.h>
#import <KudanAR/ARModelNode.h>

/**
 Class for importing 3D models from the binary format.
 */
@interface ARModelImporter : NSObject

/**
 Initialises the importer with a full path name.
 @param path The full pathname of the model file.
 @return the initialised model importer.
 */
- (instancetype)initWithPath:(NSString *)path;

/**
 Initialises the importer with a file in the app bundle.
 @param path The filename relative to the app's main bundle.
 @return the initialised model importer.
 */
- (instancetype)initWithBundled:(NSString *)file;

/**
 The node representing everything imported from the model file.
 */
- (ARModelNode *)getNode;

/**
 The list of ARMeshNode objects imported from the model file.
 */
@property () NSMutableArray *meshNodes;

@end
