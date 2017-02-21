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

class ViewController: ARCameraViewController, RPPreviewViewControllerDelegate, AVCaptureVideoDataOutputSampleBufferDelegate {
	
	var modelNode : ARModelNode = ARModelNode()
	var targetNode : ARModelNode = ARModelNode()
	var arbiButtonState : ArbiTrackState = ArbiTrackState.ARBI_PLACEMENT
	//var lastScale : CGFloat = CGFloat()
	var lastScale : CGFloat? = nil
	var lastPanX : CGFloat? = nil
	var userPhoto : UIImage? = nil
	var firstPlacement = true
	var numModels = 1
	
	var videoRenderTarget : ARRenderTarget? = nil
	
	override func viewDidLoad() {
		super.viewDidLoad()
		print("View loaded")
		
		let screenBounds = UIScreen.main.bounds
		let width = screenBounds.width
		let height = screenBounds.height
		videoRenderTarget = ARRenderTarget.init(width: Float(width), height: Float(height))
		
		// hide the navigation bar
		self.navigationController?.setNavigationBarHidden(true, animated: false)
		if isFirstLoad {
			if SHUTTER_BTN != nil && SELECT_BTN != nil {
				SHUTTER_BTN?.isHidden = false // hide the shutter button
				SELECT_BTN?.isHidden = false
				
				// trigger recording
//				RPScreenRecorder.shared().startRecording(handler: { (error: Error?) -> Void in
//					if error == nil {
//						RPScreenRecorder.shared().stopRecording { (previewController: RPPreviewViewController?, error: Error?) -> Void in
//							if previewController != nil {
//								RPScreenRecorder.shared().discardRecording(handler: { () -> Void in
//									// Executed once recording has successfully been discarded
//								})
//							}
//						}
//					}
//				})
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
		let tapSelectGesture : UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(changeOBJ))
		
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
		longPressGesture.minimumPressDuration = 2
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
		let modelNames : [String] = ["Happy", "Lol", "SweatSmile", "Smile", "Innocent", "Wink", "Love", "Kissing", "Tongue", "Sunglasses", "Smirk", "Dissapointed", "Confused", "Confounded", "Rage", "Expressionless", "Worried", "Dizzy", "Surprised", "Bawling", "Sleep", "Grimmace", "Trophy", "Ghost", "Poop", "WCpaper", "KeepIt100", "SleepingText", "QuestionMark", "ExclamationPoint"]
		let modelName : String = modelNames[currentModel]
		var modelNode : ARModelNode? = nil
		var loadSource : String = "Created Model"
		numModels = modelNames.count
		
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
			GREY_BG?.image = userPhoto
			GREY_BG?.alpha = 1
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
		Flurry.logEvent("Tapped_Share");
		// set up activity view controller
		let imageToShare = [ userPhoto! ]
		let activityViewController = UIActivityViewController(activityItems: imageToShare, applicationActivities: nil)
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
		GREY_BG?.alpha = 0
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
				print("Start screen recording")
				Flurry.logEvent("LongPress_Record_Video", withParameters: nil, timed: true);
				SHUTTER_BTN?.isHidden = true
				SELECT_BTN?.isHidden = true
				LIGHT_BTN?.isHidden = true
				WATERMARK?.isHidden = false
				startRecording()
			} else if gesture.state == UIGestureRecognizerState.ended {
				print("Stop screen recording")
				Flurry.endTimedEvent("LongPress_Record_Video", withParameters: nil);
				stopRecording()
				SHUTTER_BTN?.isHidden = false
				SELECT_BTN?.isHidden = false
				LIGHT_BTN?.isHidden = false
				WATERMARK?.isHidden = true
			}
		}
	}
	
	lazy var cameraSession: AVCaptureSession = {
		let s = AVCaptureSession()
		s.sessionPreset = AVCaptureSessionPresetLow
		return s
	}()
	
	func setupCameraSession() {
		let captureDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo) as AVCaptureDevice
		
		do {
			let deviceInput = try AVCaptureDeviceInput(device: captureDevice)
			
			cameraSession.beginConfiguration()
			
			if (cameraSession.canAddInput(deviceInput) == true) {
				cameraSession.addInput(deviceInput)
			}
			
			let dataOutput = AVCaptureVideoDataOutput()
			dataOutput.videoSettings = [(kCVPixelBufferPixelFormatTypeKey as NSString) : NSNumber(value: kCVPixelFormatType_420YpCbCr8BiPlanarFullRange as UInt32)]
			dataOutput.alwaysDiscardsLateVideoFrames = true
			
			if (cameraSession.canAddOutput(dataOutput) == true) {
				cameraSession.addOutput(dataOutput)
			}
			
			cameraSession.commitConfiguration()
			
			let queue = DispatchQueue(label: "com.mojiapp.videoQueue")
			dataOutput.setSampleBufferDelegate(self, queue: queue)
			
		}
		catch let error as NSError {
			NSLog("\(error), \(error.localizedDescription)")
		}
	}
	
	func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!, from connection: AVCaptureConnection!) {
		// Here you collect each frame and process it
		// ARRenderer.getInstance().addRenderTarget(self.cameraSession as ARRenderTarget)
	}
	
	func captureOutput(_ captureOutput: AVCaptureOutput!, didDrop sampleBuffer: CMSampleBuffer!, from connection: AVCaptureConnection!) {
		// Here you can count how many frames are dopped
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
		
		// synchronize
		objc_sync_enter(ARRenderer.getInstance())
		modelNode.rotate(byDegrees: Float(degX), axisX: 0, y: 1, z: 0)
		objc_sync_exit(ARRenderer.getInstance())
		
		lastPanX = x
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
			
			//if lastPanX != nil {
				//modelNode.rotate(byDegrees: Float(lastPanX!), axisX: 0, y: 1, z: 0)
			//}
			
			if lastScale != nil {
				modelNode.scale(byUniform: Float(lastScale!))
			}
			
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
	
	// start/stop screen recording
	func startRecording() {
		print("recording screen")
		let recorder = RPScreenRecorder.shared()
		
		recorder.startRecording{(error) in
			if let unwrappedError = error {
				print(unwrappedError.localizedDescription)
				self.stopRecording()
			}
		}
	}
	
	func stopRecording() {
		let recorder = RPScreenRecorder.shared()
		print("done recording screen")
		recorder.stopRecording {(preview, error) in
			let renderer = ARRenderer.getInstance()
			objc_sync_enter(renderer)
			print("Pausing renderer")
			renderer?.pause()
			if let unwrappedPreview = preview {
				Flurry.logEvent("View_Recording_Preview", withParameters: nil, timed: true);
				ViewController().resignFirstResponder() // reset first responder
				// preview the recording
				unwrappedPreview.previewControllerDelegate = self
				self.present(unwrappedPreview, animated: true)
			} else {
				print("there was an error - resuming renderer")
				Flurry.logEvent("ERROR_Preview_Unavailable");
				ARRenderer.getInstance()?.resume()
			}
			objc_sync_exit(renderer)
		}
	}
	
	func previewControllerDidFinish(_ previewController: RPPreviewViewController) {
		dismiss(animated: true)
		modelDict = [:]
		self.navigationController?.pushViewController(ViewController(), animated: false)
		LIGHT_BTN?.setImage(UIImage.init(named: "lightDisabled"), for: .normal)
		Flurry.endTimedEvent("View_Recording_Preview", withParameters: nil);
	}
}

