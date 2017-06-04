//
//  ARCaptureRenderTarget.swift
//  moji
//
//  Created by Macbook on 4/8/17.
//  Copyright © 2017 Digitally Savvy. All rights reserved.
//

import Foundation
import KudanAR
import AVFoundation


class ARCaptureRenderTargetSwift : ARRenderTarget {
    
    var assetWriter: AVAssetWriter?
    var isvideoFinishing: Bool?
    var fbo : GLuint = GLuint.init()
    var assetWriterPixelBufferInput : AVAssetWriterInputPixelBufferAdaptor?
    var startDate : Date?
    
    override init() {
        super.init()
    }
    
    convenience init(_ width: Float, height: Float){
        self.init(width: width, height: height)
    }
    
    override init(width: Float, height: Float) {
        super.init(width: width, height: height)
        
        // Account for the scaling factor associated with some iOS devices.
        self.width = Float(UIScreen.main.scale)
        self.height = Float(UIScreen.main.scale)
        // Set up the required render target assets.
        setupAssetWriter()
        setupFBO()
        isvideoFinishing = false
    }
    
    func setupAssetWriter() {
        // Set up asset writer.
        // Write the video file to the application's library directory, with the name "video.mp4".
        let libsURL: URL? = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask).last
        let outputURL: URL? = libsURL?.appendingPathComponent("video.mp4")
        // Delete a file with the same path if one exists.
        if FileManager.default.fileExists(atPath: (outputURL?.path)!) {
            try? FileManager.default.removeItem(at: outputURL!)
        }
        assetWriter = try? AVAssetWriter(url: outputURL!, fileType: AVFileTypeQuickTimeMovie)
        if assetWriter == nil {
            assert(false, "Error creating AVAssetWriter")
        }
        // Set up asset writer inputs.
        // Set up the asset writer to encode video in the H.264 format, with the height and width equal to that
        // of the framebuffer object.
        let assetWriterInputAttributesDictionary: [AnyHashable: Any] = [
            AVVideoCodecKey : AVVideoCodecH264,
            AVVideoWidthKey : Int(width),
            AVVideoHeightKey : Int(height)
        ]
        
        let assetWriterInput = AVAssetWriterInput(mediaType: AVMediaTypeVideo, outputSettings: assetWriterInputAttributesDictionary as? [String : Any])
        // Assume the input pixel buffer is in BGRA format, the iOS standard format.
        let sourcePixelBufferAttributesDictionary: [AnyHashable: Any] = [
            kCVPixelBufferPixelFormatTypeKey as AnyHashable : Int(kCVPixelFormatType_32BGRA),
            kCVPixelBufferWidthKey as AnyHashable : Int(width),
            kCVPixelBufferHeightKey as AnyHashable : Int(height)
        ]
        
        assetWriterPixelBufferInput = AVAssetWriterInputPixelBufferAdaptor(assetWriterInput: assetWriterInput, sourcePixelBufferAttributes: sourcePixelBufferAttributesDictionary as? [String : Any])
        // Add the input to the writer if possible.
        if (assetWriter?.canAdd(assetWriterInput))! {
            assetWriter?.add(assetWriterInput)
        }
        else {
            assert(false, "Error adding asset writer input")
        }
    }
    
    
    func setupFBO() {
        // Make the renderer context current, necessary to create any new OpenGL objects.
        ARRenderer.getInstance().useContext()
        // Create the FBO.
        glActiveTexture(GLenum(GL_TEXTURE1))
        glGenFramebuffers(1, &fbo)
        bindBuffer()
        // Create the OpenGL texture cache.
        var cvTextureCacheRef:CVOpenGLESTextureCache?
        var err =  CVOpenGLESTextureCacheCreate(kCFAllocatorDefault, nil, EAGLContext.current(), nil, &cvTextureCacheRef)
        if err != kCVReturnSuccess {
            assert(false, "Error at CVOpenGLESTextureCacheCreate \(err)")
        }
        // Create the OpenGL texture we will be rendering to.
        var pixelBuffer : CVPixelBuffer?
        guard let writerPixelBufferInput = assetWriterPixelBufferInput else { print("no assetWriterPixelBufferInput" ); return }
        guard let pixelBufferPool = writerPixelBufferInput.pixelBufferPool else { print("no pixelBufferPool" ); return }
        err = CVPixelBufferPoolCreatePixelBuffer(kCFAllocatorDefault, pixelBufferPool, &pixelBuffer)
        if err != kCVReturnSuccess {
            print ("error msg createing Pixelbuffer pool \(err)")
            return
        }
        
        var renderTexture: CVOpenGLESTexture?
        err = CVOpenGLESTextureCacheCreateTextureFromImage(kCFAllocatorDefault,
                                                     cvTextureCacheRef!,
                                                     pixelBufferPool as! CVImageBuffer,
                                                     nil,
                                                     // texture attributes
                                                     GLenum(GL_TEXTURE_2D), GL_RGBA,     // opengl format
                                                     GLsizei(Int(width)), GLsizei(Int(height)), GLenum(GL_BGRA),     // native iOS format
                                                     GLenum(GL_UNSIGNED_BYTE),
                                                     0,
                                                     &renderTexture)
        if err != kCVReturnSuccess {
            print ("error CVOpenGLESTextureCacheCreateTextureFromImage \(err)")
            return
        }
        // Attach the OpenGL texture to the framebuffer.
        glBindTexture(CVOpenGLESTextureGetTarget(renderTexture!), CVOpenGLESTextureGetName(renderTexture!))
        glTexParameterf(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_WRAP_S), GLfloat(GL_CLAMP_TO_EDGE))
        glTexParameterf(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_WRAP_T), GLfloat(GL_CLAMP_TO_EDGE))
        glFramebufferTexture2D(GLenum(GL_FRAMEBUFFER), GLenum(GL_COLOR_ATTACHMENT0), GLenum(GL_TEXTURE_2D), CVOpenGLESTextureGetName(renderTexture!), 0)
        // Create a depth buffer for correct drawing.
        var depthRenderbuffer: GLuint = GLuint.init()
        glGenRenderbuffers(1, &depthRenderbuffer)
        glBindRenderbuffer(GLenum(GL_RENDERBUFFER), depthRenderbuffer)
        glRenderbufferStorage(GLenum(GL_RENDERBUFFER), GLenum(GL_DEPTH24_STENCIL8_OES), GLsizei(width), GLsizei(height))
        glFramebufferRenderbuffer(GLenum(GL_FRAMEBUFFER), GLenum(GL_DEPTH_ATTACHMENT), GLenum(GL_RENDERBUFFER), depthRenderbuffer)
        // Check the FBO is complete and ready for rendering
        self.checkFBO()
    }
    
    override func bindBuffer() {
        glBindFramebuffer(GLenum(GL_FRAMEBUFFER), fbo)
    }
    
    override func draw() {
        // Draw content to the framebuffer as normal.
        super.draw()
        // Prevent encoding of a new frame if the AVAssetWriter is not writing or if the video is completed.
        if assetWriter?.status != .writing || isvideoFinishing! {
            return
        }
        // Wait for all OpenGL commands to finish.
        glFinish()
        // Lock the pixel buffer to allow it to be used for encoding.
        CVPixelBufferLockBaseAddress(bindBuffer as! CVPixelBuffer, CVPixelBufferLockFlags(rawValue: 0))
        // Submit the pixel buffer for the current frame to the asset writer with the correct timestamp.
        let currentTime: CMTime = CMTimeMakeWithSeconds(Date().timeIntervalSince(startDate!), 120)
        if !assetWriterPixelBufferInput!.append(bindBuffer as! CVPixelBuffer, withPresentationTime: currentTime) {
            print("Problem appending pixel buffer at time: \(currentTime.value)")
        }
        // Unlock the pixel buffer to free it.
        CVPixelBufferUnlockBaseAddress(bindBuffer as! CVPixelBuffer, CVPixelBufferLockFlags(rawValue: 0))
    }
    
    func startRecording() {
        assetWriter?.startWriting()
        assetWriter?.startSession(atSourceTime: kCMTimeZero)
        // Store the date when the asset writer started recording video.
        startDate = Date()
        // Check the asset writer has started.
        if assetWriter?.status == .failed {
            assert(false, "Error starting asset writer \(String(describing: assetWriter?.error))")
        }
    }
    
    func stopRecording(completionBlock: (() -> Void)?) {
        isvideoFinishing = true
        let completion: ((_: Void) -> Void)? = {() -> Void in
            DispatchQueue.main.async(execute: {() -> Void in
                if (completionBlock != nil) {
                    completionBlock!()
                }
            })
        }
        assetWriter?.finishWriting(completionHandler: {() -> Void in
            print("Finished writing video.")
            completion!()
        })
    }
    
    func getOutputUrl() -> URL {
        let libsURL: URL? = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask).last
        return (libsURL?.appendingPathComponent("video.mp4"))!
    }
    
    
}
