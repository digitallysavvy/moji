//
//  ViewController.swift
//  moji
//
//  Created by Macbook on 1/21/17.
//  Copyright © 2017 Digitally Savvy. All rights reserved.
//


import UIKit
import ReplayKit
import AVFoundation
import KudanAR

enum ArbiTrackState: Int {
	case ARBI_PLACEMENT
	case ARBI_TRACKING
}

class ViewController: ARCameraViewController, AVCaptureVideoDataOutputSampleBufferDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
	
	var modelNode : ARModelNode = ARModelNode()
	var targetNode : ARModelNode = ARModelNode()
	var arbiButtonState : ArbiTrackState = ArbiTrackState.ARBI_PLACEMENT
	//var lastScale : CGFloat = CGFloat()
	var lastScale : CGFloat? = nil
//    var totalScale : CGFloat? = nil
	var lastPanX : CGFloat? = nil
	var userPhoto : UIImage? = nil
	var firstPlacement = true
	var numModels = 1
	
	var videoRenderTarget : ARCaptureRenderTarget? = nil
	
	override func viewDidLoad() {
		SELECT_VIEW?.allowsSelection = true
        super.viewDidLoad()
		print("View loaded")
        
        // set data source and delegate
        SELECT_VIEW?.delegate = self
        SELECT_VIEW?.dataSource = self
		
        // Create the ARCaptureRenderTarget offscreen render target object.
		videoRenderTarget = ARCaptureRenderTarget.init(width: Float(view.frame.size.width), height: Float(view.frame.size.height))
        
        // Add the viewports that need rendering to the the render target.
        videoRenderTarget?.addViewPort(cameraView.cameraViewPort) // add the camera image viewport
        videoRenderTarget?.addViewPort(cameraView.contentViewPort) //add the 3D content viewport
        
        ARRenderer.getInstance().add(videoRenderTarget as! ARRendererDelegate) // Add the offscreen render target to the renderer.
		
		// hide the navigation bar
		self.navigationController?.setNavigationBarHidden(true, animated: false)
		if isFirstLoad {
			if SHUTTER_BTN != nil && SELECT_BTN != nil {
				SHUTTER_BTN?.isHidden = false // hide the shutter button
				SELECT_BTN?.isHidden = false
			}
		} else {
			// reset some vars
			firstPlacement = true
		}
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		// Do any additional setup after loading the view, typically from a nib.
		Flurry.logEvent("AR_View_Did_Appear");
		print("View Appeared")
		if isFirstLoad {
			isFirstLoad = false
		}
	}
	
	override func setupContent() {
		print("setting up content")
		// setup
		modelNode = setupModel()
		setupArbiTrack()
		print("init setup complete addng touch gestures")
		
		// Recognized gestures
		//	- Single tap to place / remove objct
		//	- Pinch to scale model
		//	- Single finger pan to rotate model
		
		// shutter button
		let longPressShutterGesture : UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(recordScreen))
		longPressShutterGesture.minimumPressDuration = 0.75
		
		let tapShutterGesture : UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(takePhoto))
		
		if SHUTTER_BTN != nil {
			SHUTTER_BTN?.addGestureRecognizer(longPressShutterGesture)
			SHUTTER_BTN?.addGestureRecognizer(tapShutterGesture)
		}
		
		// swap out model
		let tapSelectGesture : UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(toggleSelectMenu))
		
		if SELECT_BTN != nil {
			SELECT_BTN?.addGestureRecognizer(tapSelectGesture)
		}
		
		// flashlight button
		let tapLightGesture : UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapLightIcon))
		
		if LIGHT_BTN != nil {
			LIGHT_BTN?.addGestureRecognizer(tapLightGesture)
		}
		
		let tapShareGesture : UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(sharePhoto))
		
		if SHARE_BTN != nil {
			SHARE_BTN?.addGestureRecognizer(tapShareGesture)
		}
		
		// screen gestures
		let longPressGesture : UILongPressGestureRecognizer = UILongPressGestureRecognizer(target:self, action:#selector(longPressReset))
		longPressGesture.minimumPressDuration = 1.25
		longPressGesture.require(toFail: longPressShutterGesture)
		self.cameraView.addGestureRecognizer(longPressGesture);
		
		let pinchGesture : UIPinchGestureRecognizer = UIPinchGestureRecognizer(target:self, action:#selector(arbiPinch))
		self.cameraView.addGestureRecognizer(pinchGesture);
		
		let panGesture : UIPanGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(arbiPan))
		panGesture.maximumNumberOfTouches = 1
		self.cameraView.addGestureRecognizer(panGesture);
	}
	
	func setupModel() -> ARModelNode {
		// print("setting up model")
		var objctParams : [String: String] = [:] // tracking purposes
        let modelNames = MOJI_LIST
        let modelName : String = modelNames![currentModel]
		var modelNode : ARModelNode? = nil
		var loadSource : String = "Created Model"
		numModels = (modelNames?.count)!
		
		objctParams["Model"] = modelName; // track which model is being setup
		
		Flurry.logEvent("Load_Moji", withParameters: nil, timed: true);
		
		// find model in dict or create a new one
		if let dictModel = modelDict[modelName] {
			loadSource = "Loaded Existing Model"
			modelNode = dictModel
			if (modelDefs[modelName]?.animated)! {
				modelNode?.start()
				modelNode?.shouldLoop = true;
			}
		} else {
			// customize rotation planes
			let rotX : Int8 = 0;
			let rotY : Int8 = 1;
			let rotZ : Int8 = 0;
			
			// get objct definitions
			if let template = modelDefs[modelName]{
				// print("creating new model for: \(template.name)!")
				// Import model from file.
				let arFile : String = (template.armodel)!
				let importer : ARModelImporter = ARModelImporter.init(bundled: arFile)
				modelNode = importer.getNode()
				
				//Light Material
				let material : ARLightMaterial = ARLightMaterial.init()
				
				// apply textures to material
				if let colour = template.diffuseTexure {
					material.colour.texture = ARTexture.init(uiImage: UIImage(named: colour))
				}
				
				if let normal = template.normalTexture {
					if normal != "" {
						material.normal.texture = ARTexture.init(uiImage: UIImage(named: normal))
					}
				}
				
				if let specular = template.specularTexture {
					if specular != "" {
						material.specular.texture = ARTexture.init(uiImage: UIImage(named: specular))
					}
				}
				
				// apply materials
				material.ambient.value = ARVector3.init(vector: (template.ambient)!)
				material.specular.value = ARVector3.init(vector: (template.specular)!)
				material.shininess = Float(template.shininess)
				material.reflection.reflectivity = Float(template.reflectivity)
				
				// reflection maps -- defined: back, front, up, down, right, left.
				if let reflectionMap = template.reflectionMap  {
					switch reflectionMap {
					case "mattPlastic":
						// print("added mattPlastic reflectionMap")
						material.reflection.environment = ARTextureCube.init(uiImages: [UIImage(named:"PLASTIC_0.jpg")!,UIImage(named:"PLASTIC_1.jpg")!,UIImage(named:"PLASTIC_2.jpg")!,UIImage(named:"PLASTIC_3.jpg")!,UIImage(named:"PLASTIC_4.jpg")!,UIImage(named:"PLASTIC_5.jpg")!])
					case "mattCeramic":
						// print("added mattCeramic reflectionMap")
						material.reflection.environment = ARTextureCube.init(uiImages: [UIImage(named:"CERAMIC_0.jpg")!,UIImage(named:"CERAMIC_1.jpg")!,UIImage(named:"CERAMIC_2.jpg")!,UIImage(named:"CERAMIC_3.jpg")!,UIImage(named:"CERAMIC_4.jpg")!,UIImage(named:"CERAMIC_5.jpg")!])
					case "mattMetal":
						// print("added mattMetal reflectionMap")
						material.reflection.environment = ARTextureCube.init(uiImages: [UIImage(named:"PLATINUM_0.jpg")!,UIImage(named:"PLATINUM_1.jpg")!,UIImage(named:"PLATINUM_2.jpg")!,UIImage(named:"PLATINUM_3.jpg")!,UIImage(named:"PLATINUM_4.jpg")!,UIImage(named:"PLATINUM_5.jpg")!])
					default: break
						// print("No reflection map to set")
					}
				} else {
					print("unable to load reflection maps")
				}
				
				// apply material to model meshes
				for meshNode in (modelNode?.meshNodes)! {
					(meshNode as! ARMeshNode).material = material;
				}
				
				// apply scaling and rotations
				modelNode?.scale(byUniform: Float(template.scale))
				modelNode?.rotate(byDegrees: Float(template.rotation), axisX: Float(rotX), y: Float(rotY), z: Float(rotZ))
				
				// add touch event
				modelNode?.addTouchTarget(self, withAction: #selector(tapToPlace))
				
				//add to model dictionary
				modelDict[modelName] = modelNode
				// print("adding model to dict")
				
				//check if the model should be animated
				if (template.animated)! {
					modelNode?.start()
					modelNode?.shouldLoop = true;
				}
			} else {
				print("unable to load model \(modelName)")
				
				// track the error
				objctParams["Error"] = "Unable to Create Objct";
				Flurry.endTimedEvent("Load_Moji", withParameters: objctParams);
			}
		}
		
		// track which models were loaded for display and how
		objctParams["LoadType"] = loadSource;
		Flurry.endTimedEvent("Load_Moji", withParameters: objctParams);
		
		return modelNode!
	}
	
	func setupArbiTrack(){
		print("setting up tracker")
		// Initialise gyro placement. Gyro placement positions content on a virtual floor plane where the device is aiming.
		let gyroPlaceManager : ARGyroPlaceManager = ARGyroPlaceManager.getInstance()
		gyroPlaceManager.initialise()
		
		// Set up the target node on which the model is placed.
		let targetNode : ARNode = ARNode.init(name: "targetNode")
		gyroPlaceManager.world.addChild(targetNode)
		
		// Add a visual reticle to the target node for the user.
		let targetImageNode : ARImageNode = ARImageNode.init(image: UIImage(named: "target-moji-square.png"))
		targetImageNode.addTouchTarget(self, withAction: #selector(tapToPlace))
		targetNode.addChild(targetImageNode)
		
		// Scale and rotate the image to the correct transformation.
		targetImageNode.scale(byUniform: 0.1)
		targetImageNode.rotate(byDegrees: 90.0, axisX: 1.0, y: 0.0, z: 0.0)
		
		// Initialise the arbiTracker, do not start until user placement.
		let arbiTrack : ARArbiTrackerManager = ARArbiTrackerManager.getInstance()
		arbiTrack.initialise()
		
		// Set the arbiTracker target node to the node moved by the user.
		arbiTrack.targetNode = targetNode;
		arbiTrack.world.addChild(self.modelNode)
	}
	
	func hideShowUI() {
		if arbiButtonState == ArbiTrackState.ARBI_PLACEMENT {
			if SHUTTER_BTN != nil && SELECT_BTN != nil {
				SHUTTER_BTN?.isHidden = false
				SELECT_BTN?.isHidden = false
			}
		} else if arbiButtonState == ArbiTrackState.ARBI_TRACKING {
			if SHUTTER_BTN != nil && SELECT_BTN != nil {
				SHUTTER_BTN?.isHidden = true
				SELECT_BTN?.isHidden = true
			}
		}
	}
	
	func tapToPlace() {
        WEB_VIEW?.loadRequest(NSURLRequest(url: NSURL(string: "about:blank")! as URL) as URLRequest)
		//		hideShowUI()
		let arbiTrack = ARArbiTrackerManager.getInstance()
		if arbiButtonState == ArbiTrackState.ARBI_PLACEMENT {
			// print("place object")
			Flurry.logEvent("Tapped_To_Place_Moji");
			arbiTrack?.start()
			arbiTrack?.targetNode.visible = false
			if !firstPlacement {
				modelNode.scale(by: ARVector3(valuesX: 1.0, y: 1.0, z: 1.0))
			} else {
				firstPlacement = false
			}
			arbiButtonState = ArbiTrackState.ARBI_TRACKING
		} else if arbiButtonState == ArbiTrackState.ARBI_TRACKING {
			Flurry.logEvent("Tapped_To_Display_Tracker");
			lastScale = nil
			lastPanX = nil
			arbiTrack?.stop()
			arbiTrack?.targetNode.visible = true
			arbiButtonState = ArbiTrackState.ARBI_PLACEMENT
		}
	}
	
	func takePhoto (gesture : UIGestureRecognizer) {
		print("screenshot")
		Flurry.logEvent("Tapped_Take_Photo");
		if arbiButtonState == ArbiTrackState.ARBI_TRACKING {
			SHUTTER_BTN?.isHidden = true
			SELECT_BTN?.isHidden = true
			LIGHT_BTN?.isHidden = true
			WATERMARK?.isHidden = false
			objc_sync_enter(ARRenderer.getInstance())
			let renderer = UIGraphicsImageRenderer(size: (overlayView?.bounds.size)!)
			userPhoto = renderer.image {
				ctx in overlayView?.drawHierarchy(in: (overlayView?.bounds)!, afterScreenUpdates: true)
			}
			
			// write the userPhoto to photos
			//UIImageWriteToSavedPhotosAlbum(screenCap, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
			
			// preview userPhoto
			PHOTO_PREVIEW?.image = userPhoto
            PHOTO_PREVIEW?.isHidden = false
			objc_sync_exit(ARRenderer.getInstance())
			BACK_BTN?.isHidden = false
			SHARE_BTN?.isHidden = false
			WATERMARK?.isHidden = true
			SHUTTER_BTN?.isHidden = false
			SELECT_BTN?.isHidden = false
			LIGHT_BTN?.isHidden = false
		}
	}
	
	func sharePhoto (gesture : UIGestureRecognizer) {
        // set up activity view controller
        let activityViewController :UIActivityViewController
        if (PHOTO_PREVIEW?.isHidden)! {
            Flurry.logEvent("Tapped_Share_Video");
            let userVideo = [ VideoPreviewURL! ]
            activityViewController = UIActivityViewController(activityItems: userVideo, applicationActivities: nil)
        } else {
            Flurry.logEvent("Tapped_Share_Photo");
            let userPhoto = [ self.userPhoto! ]
            activityViewController = UIActivityViewController(activityItems: userPhoto, applicationActivities: nil)
        }
		activityViewController.popoverPresentationController?.sourceView = self.view // so that iPads won't crash
		
		// exclude some activity types from the list (optional)
		activityViewController.excludedActivityTypes = [ UIActivityType.airDrop, UIActivityType.postToFacebook ]
		
		// present the view controller
		self.present(activityViewController, animated: true, completion: nil)
		activityViewController.completionWithItemsHandler = afterShareCompleted
	}
	
	func afterShareCompleted(activityType: UIActivityType?, shared: Bool, items: [Any]?, error: Error?) {
		SHARE_BTN?.isHidden = true
		BACK_BTN?.isHidden = true
        PHOTO_PREVIEW?.isHidden = true
        VIDEO_PREVIEW?.isHidden = true
		if (shared) {
			Flurry.logEvent("Share_Successful");
		}
		else {
			Flurry.logEvent("Share_Canceled");
		}
	}
	
	
	func recordScreen (gesture : UIGestureRecognizer) {
		if arbiButtonState == ArbiTrackState.ARBI_TRACKING {
            if gesture.state == UIGestureRecognizerState.began {
//                let recorder : ASScreenRecorder = ASScreenRecorder.sharedInstance()
                let renderer = ARRenderer.getInstance()
				print("Start screen recording")
				Flurry.logEvent("LongPress_Record_Video", withParameters: nil, timed: true);
				SHUTTER_BTN?.isHidden = true
				SELECT_BTN?.isHidden = true
				LIGHT_BTN?.isHidden = true
				WATERMARK?.isHidden = false
                // startRecording
                objc_sync_enter(renderer)
//                recorder.startRecording()
                videoRenderTarget?.startRecording()
                objc_sync_exit(renderer)
            } else if gesture.state == UIGestureRecognizerState.ended {
//                let recorder : ASScreenRecorder = ASScreenRecorder.sharedInstance()
                let renderer = ARRenderer.getInstance()
				print("Stop screen recording")
				Flurry.endTimedEvent("LongPress_Record_Video", withParameters: nil);
				// stopRecording
                objc_sync_enter(renderer)
                videoRenderTarget?.stopRecording(completionBlock: {
                    print("recording finished")
                    self.previewVideo()
                })
//                recorder.stopRecording(completion: {
//                    print("recording finished")
//                    self.previewVideo()
//                })
                objc_sync_exit(renderer)
				SHUTTER_BTN?.isHidden = false
				SELECT_BTN?.isHidden = false
				LIGHT_BTN?.isHidden = false
				WATERMARK?.isHidden = true
			}
		}
	}
    
    func previewVideo() {
//        let previewURL = UserDefaults.standard.value(forKey: "previewURL")
//        VideoPreviewURL = URL(string: previewURL! as! String)
        VideoPreviewURL = videoRenderTarget?.getOutputUrl()
        PLAYER_INSTANCE = AVPlayer(url: VideoPreviewURL! as URL)
        PLAYER_INSTANCE?.actionAtItemEnd = .none
        PLAYER_INSTANCE?.isMuted = true
        PLAYER_INSTANCE?.play()
        NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: PLAYER_INSTANCE?.currentItem, queue: nil, using: { (_) in
            DispatchQueue.main.async {
                PLAYER_INSTANCE?.seek(to: kCMTimeZero)
                PLAYER_INSTANCE?.play()
            }
        })
        VIDEO_PREVIEW?.player = PLAYER_INSTANCE
        VIDEO_PREVIEW?.isHidden = false
        BACK_BTN?.isHidden = false
        SHARE_BTN?.isHidden = false
    }
	
    
	// Reset the tracker
	func longPressReset(gesture : UIGestureRecognizer) {
		// print("tapLongPress gesture -- state: \(gesture.state.rawValue)")
		if arbiButtonState == ArbiTrackState.ARBI_TRACKING && gesture.state == UIGestureRecognizerState.began {
			let arbiTrack = ARArbiTrackerManager.getInstance()
			Flurry.logEvent("Tracker_Reset");
			arbiTrack?.stop()
			arbiTrack?.targetNode.visible = true
			arbiButtonState = ArbiTrackState.ARBI_PLACEMENT
		}
	}
	
	func arbiPinch(gesture:UIPinchGestureRecognizer) {
		// print("pinch gesture")
		if gesture.state == UIGestureRecognizerState.began {
			lastScale = 1
			Flurry.logEvent("Pinch_Scale_Moji");
		}
		
		let scaleFactor : CGFloat = 1 - (lastScale! - gesture.scale)
		lastScale = gesture.scale
//        if totalScale != nil {
//            totalScale = totalScale! + scaleFactor
//        } else {
//            totalScale = scaleFactor
//        }
		// synchronize
		objc_sync_enter(ARRenderer.getInstance())
		modelNode.scale(byUniform: Float(scaleFactor))
		objc_sync_exit(ARRenderer.getInstance())
	}
	
	func arbiPan(gesture:UIPanGestureRecognizer) {
		// print("pan gesture")
		let x = gesture.translation(in: self.cameraView).x
		if gesture.state == UIGestureRecognizerState.began {
			lastPanX = x
			Flurry.logEvent("Pan_Rotate_Moji");
		}
		
		let diffX : CGFloat = x - lastPanX!
		let degX : CGFloat = diffX * 0.5
        lastPanX = x
		
		// synchronize
		objc_sync_enter(ARRenderer.getInstance())
		modelNode.rotate(byDegrees: Float(degX), axisX: 0, y: 1, z: 0)
		objc_sync_exit(ARRenderer.getInstance())
	}
    
    func toggleSelectMenu(gesture:UIGestureRecognizer) {
        if (SELECT_VIEW?.isHidden)! {
            Flurry.logEvent("Tapped_To_Select_Moji");
            SELECT_BTN?.isHidden = true
            SHUTTER_BTN?.isHidden = true
            LIGHT_BTN?.isHidden = true
            SELECT_VIEW?.isHidden = false
            BACK_BTN?.isHidden = false
        }
    }
    
    func updateMoji() {
        // add log to track current model displayed
        if arbiButtonState == ArbiTrackState.ARBI_TRACKING {
            Flurry.logEvent("Updating_Visible_Moji");
        } else {
            Flurry.logEvent("Updating_Hidden_Moji");
        }
        objc_sync_enter(ARRenderer.getInstance())
        let arbiTrack : ARArbiTrackerManager = ARArbiTrackerManager.getInstance()
        arbiTrack.world.removeChild(self.modelNode)
        modelNode = setupModel()
        arbiTrack.world.addChild(self.modelNode)
//        if totalScale != nil {
//            modelNode.scale(byUniform: Float(totalScale!))
//        }
        objc_sync_exit(ARRenderer.getInstance())
    }
	
	func changeOBJ(gesture:UIGestureRecognizer) {
		Flurry.logEvent("Tapped_To_Change_Moji");
		// add log to track current model displayed
		if arbiButtonState == ArbiTrackState.ARBI_TRACKING {
			currentModel = (currentModel + 1) % numModels
			objc_sync_enter(ARRenderer.getInstance())
			let arbiTrack : ARArbiTrackerManager = ARArbiTrackerManager.getInstance()
			arbiTrack.world.removeChild(self.modelNode)
			modelNode = setupModel()
			arbiTrack.world.addChild(self.modelNode)
//			if lastPanX != nil {
//				modelNode.rotate(byDegrees: Float(lastPanX!), axisX: 0, y: 1, z: 0)
//			}
//			if totalScale != nil {
//				modelNode.scale(byUniform: Float(totalScale!))
//			}
			objc_sync_exit(ARRenderer.getInstance())
		}
	}
	
	//flashlight
	func tapLightIcon(gesture:UIGestureRecognizer) {
		toggleFlashlight()
	}
	
	func toggleFlashlight() {
		guard let device = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo) else { return }
		if device.hasTorch {
			do {
				try device.lockForConfiguration()
				if device.torchMode == .off {
					device.torchMode = .on
					LIGHT_BTN?.setImage(UIImage(named: "lightActive"), for: .normal)
					Flurry.logEvent("Tapped_Flashlight_On");
				} else {
					device.torchMode = .off
					LIGHT_BTN?.setImage(UIImage(named: "lightDisabled"), for: .normal)
					Flurry.logEvent("Tapped_Flashlight_Off");
				}
				device.unlockForConfiguration()
			} catch {
				print("Torch could not be used")
			}
		} else {
			print("Torch is not available")
		}
	}

//        Flurry.logEvent("View_Recording_Preview", withParameters: nil, timed: true);
//        Flurry.endTimedEvent("View_Recording_Preview", withParameters: nil);

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 30 // Set the number of items in the collection view.
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // Access
        let cell = SELECT_VIEW?.dequeueReusableCell(withReuseIdentifier: "mojiSelectionCellIdentifier", for: indexPath) as! MojiSelectionCell
        // Modifications to custom cell, referencing the outlets defined
        let currIndex : Int = (indexPath.section * 30) + indexPath.row
        let select_icon : String = SELECT_ICON_LIST![currIndex]
        cell.image.image = UIImage(named: select_icon)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        Flurry.logEvent("Tapped_To_Change_Moji");
        SELECT_BTN?.isHidden = false
        SHUTTER_BTN?.isHidden = false
        LIGHT_BTN?.isHidden = false
        SELECT_VIEW?.isHidden = true
        BACK_BTN?.isHidden = true
        currentModel = (indexPath.section * 30) + indexPath.row
        updateMoji()
    }
    
    // Set spacing between items in the collection view.
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 2
    }
}

