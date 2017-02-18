#import <Foundation/Foundation.h>

@class ARRenderer;
@class ARVertexBuffer;
@class ARMeshNode;

@interface ARMesh : NSObject

@property (nonatomic) ARVertexBuffer *vertexBuffer;
@property (nonatomic) unsigned indexBuffer;

/**
 The number of triangles in this mesh.
 */
@property (nonatomic, readonly) NSUInteger numberOfIndices;

/**
 The number of vertices in this mesh.
 */
@property (nonatomic) unsigned numberOfVertices;
@property (nonatomic) unsigned vertexStride;

- (void)prepareRenderer:(ARRenderer *)renderer meshNode:(ARMeshNode *)meshNode;

+ (id)testMesh;
+ (id)testMeshWithUV;

/**
 Whether this mesh has normals in its vertex data.
 */
@property (nonatomic) BOOL hasNormals;

@property (nonatomic) BOOL hasTangents;

/**
 Whether this mesh has UVs in its vertex data. If it doesn't, materials with textures shouldn't be used.
 */
@property (nonatomic) BOOL hasUVs;

/**
 Whether this mesh has bones in its vertex data.
 */
@property (nonatomic) BOOL hasBones;

/**
 Whether this mesh has blend shape deformers.
 */
@property (nonatomic) BOOL hasBlendShapes;

+ (instancetype)texturedMeshWidth:(float)width height:(float)height;
+ (instancetype)meshWithWidth:(float)width height:(float)height;

- (instancetype)initWithVertexData:(NSData *)vertexData indexData:(NSData *)indexData hasNormals:(BOOL)hasNormals hasUVs:(BOOL)hasUVs;
- (instancetype)initWithVertexData:(NSData *)vertexData indexData:(NSData *)indexData hasNormals:(BOOL)hasNormals hasUVs:(BOOL)hasUVs hasUVs2:(BOOL)hasUVs2 hasTangents:(BOOL)hasTangents maxBones:(unsigned)maxBones;

- (instancetype)initWithVertexData:(NSData *)vertexData indexData:(NSData *)index12Data hasNormals:(BOOL)hasNormals hasUVs:(BOOL)hasUVs maxBones:(unsigned)maxBones;

- (instancetype)initWithVertices:(NSData *)vertices normals:(NSData *)normals UVs:(NSData *)UVs indices:(NSData *)indices;

- (NSData *)createVertexDataWithVertices:(NSData *)vertices UVs:(NSData *)UVs indices:(NSData *)indices;

- (instancetype)initWithEmpty;

- (void)setVertexData:(NSData *)vertexData;

- (instancetype)initWithTestMeshWithUV:(float)width height:(float)height;
- (instancetype)initWithTestMeshWithUV:(float)width height:(float)height u:(float)u v:(float)v;

/**
 The list of ARBoneNode bones that are part of this mesh.
 */
@property (nonatomic) NSMutableArray *bones;

@end
