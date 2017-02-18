//
//  OverlayViewConroller.swift
//  moji
//
//  Created by Macbook on 1/21/17.
//  Copyright © 2017 Digitally Savvy. All rights reserved.
//

import UIKit
import KudanAR

var SHUTTER_BTN : UIButton?
var SELECT_BTN : UIButton?
var LIGHT_BTN : UIButton?
var WATERMARK : UIImageView?
var GREY_BG : UIImageView?
var BACK_BTN : UIButton?
var SHARE_BTN : UIButton?

var isFirstLoad : Bool = true
var currentModel : Int = 0
var modelDict : [String : ARModelNode] = [:]
var modelDefs : [String : ModelObject] = [:]

var overlayView : UIView?

class OverlayViewController: UIViewController {
	
	// @IBOutlet weak var InfoButton: UIButton!
	@IBOutlet weak var ShutterButtton: UIButton!
	@IBOutlet weak var LightBtn: UIButton!
	@IBOutlet weak var SelectBtn: UIButton!
	@IBOutlet weak var Watermark: UIImageView!
	@IBOutlet weak var GreyBG: UIImageView!
	@IBOutlet weak var AnimationView: UIImageView!
	@IBOutlet weak var BackBtn: UIButton!
	@IBOutlet weak var ShareBtn: UIButton!
	
	@IBAction func BackBtnPressed(_ sender: Any) {
		BackBtn.isHidden = true
		ShareBtn.isHidden = true
		GreyBG.alpha = 0
		Flurry.logEvent("Tapped_Back_From_Preview");
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		// Do any additional setup after loading the view.
		SHUTTER_BTN = ShutterButtton
		SELECT_BTN = SelectBtn
		LIGHT_BTN = LightBtn
		WATERMARK = Watermark
		GREY_BG = GreyBG
		BACK_BTN = BackBtn
		SHARE_BTN = ShareBtn
		
		// Hide Preview Buttons
		BackBtn.isHidden = true
		ShareBtn.isHidden = true
		Watermark.isHidden = true
		
		// add overlay view
		overlayView = self.view
		
		// read in objct model definitions
		let url = Bundle.main.url(forResource: "armodels", withExtension: "json")
		let data = NSData(contentsOf: url!)
		
		do {
			//parse the JSON definitions
			let jsonObj = try JSONSerialization.jsonObject(with: data! as Data, options: .allowFragments)
			if let jsonDict = jsonObj as? [String: AnyObject] {
				if let modelJSONDefs = jsonDict["models"] as? [[String: AnyObject]]{
					// loop through definitions and add to dict
					for mDef in modelJSONDefs {
						guard let name : String = mDef["name"] as! String? else { return }
						modelDefs[name] = ModelObject.init(jsonModel: mDef)
						print("model: \(name) added to modelDefs")
					}
				}
			}
		} catch {
			// Handle Error
			print("failed to load models")
		}
		
		//setup launch animation
		var imgListArray:[UIImage] = []
		
		for countValue in 0...160 {
			imgListArray.append(UIImage(named: "frame_\(countValue).gif")!)
		}
		
		AnimationView.animationImages = imgListArray
		AnimationView.animationDuration = 4
		AnimationView.startAnimating()
		
	}
	
	override func viewDidAppear(_ animated: Bool) {
		if isFirstLoad {
			// AnimationView.startAnimating()
			AnimationView.alpha = 1.0
			GreyBG.alpha = 1.0
			UIView.animate(withDuration: 1, delay:2.5, animations: { () -> Void in
				self.AnimationView.alpha = 0
				self.GreyBG.alpha = 0
			})			
		}

	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	// hide the status bar
	override var prefersStatusBarHidden: Bool {
		return true
	}
	
	
	/*
	// MARK: - Navigation
	
	// In a storyboard-based application, you will often want to do a little preparation before navigation
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
	// Get the new view controller using segue.destinationViewController.
	// Pass the selected object to the new view controller.
	}
	*/
	
}
