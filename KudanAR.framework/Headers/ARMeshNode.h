#import <Foundation/Foundation.h>
#import <KudanAR/ARNode.h>

@class ARMaterial;
@class ARMesh;
@class ARTexture;

/**
 A node representing a drawable mesh. The geometry to be used, as well as its shading, is specifed via this node.
 */
@interface ARMeshNode : ARNode

/**
 The mesh geometry to use. Meshes can be shared between ARMeshNode objects.
 */
@property (nonatomic) ARMesh *mesh;

/**
 The material to use for shading the mesh attached to this node. nil materials will not be drawn. Materials can be shared between ARMeshNode objects.
 */
@property (nonatomic) ARMaterial *material;

+ (instancetype)testMeshNodeWithRed:(float)red green:(float)green blue:(float)blue;
+ (instancetype)testMeshNodeWithTexture:(ARTexture *)texture;

+ (instancetype)meshNodeWithTexture:(ARTexture *)texture width:(float)width height:(float)height;
+ (instancetype)meshNodeWithRed:(float)red green:(float)green blue:(float)blue width:(float)width height:(float)height;

@property (nonatomic) BOOL cull;

@end
