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
var SELECT_VIEW : UICollectionView?
var WEB_VIEW : UIWebView?

var MOJI_LIST : [String]? = ["Happy", "Innocent", "Kissing", "Lol", "Love", "Smirk", "Bawling", "Smile", "Sunglasses", "SweatSmile", "Tongue", "Wink", "Worried", "Dissapointed", "Grimmace", "Surprised", "Rage", "Sleep", "Expressionless", "Dizzy", "Confused", "Confounded", "Ghost", "KeepIt100", "SleepingText", "ExclamationPoint", "QuestionMark", "Poop", "WCpaper", "Trophy"]

var SELECT_ICON_LIST : [String]? = ["select_happy", "select_innocent", "select_kissing", "select_lol", "select_love", "select_smirk", "select_bawling", "select_smile", "select_sunglasses", "select_sweat-smile", "select_tongue", "select_wink", "select_worried", "select_dissapointed", "select_grimmace", "select_surprised", "select_rage", "select_sleeping", "select_expresionless", "select_dizzy", "select_confused", "select_confounded", "select_ghost", "select_keepit100", "select_sleeptext", "select_exclamation", "select_questionmark", "select_poop", "select_wcpaper", "select_trophy"]

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
    @IBOutlet weak var SelectCollectionView: UICollectionView!
    @IBOutlet weak var webAnimationView: UIWebView!
    @IBOutlet weak var launchHolder: UIImageView!
    
    let identifier = "CellIdentifier"
	
	@IBAction func BackBtnPressed(_ sender: Any) {
        if ShareBtn.isHidden {
            BackBtn.isHidden = true
            SelectCollectionView.isHidden = true
            LightBtn.isHidden = false
            SelectBtn.isHidden = false
            ShutterButtton.isHidden = false
            Flurry.logEvent("Tapped_Back_From_Select");
        } else {
            BackBtn.isHidden = true
            ShareBtn.isHidden = true
            GreyBG.alpha = 0
            Flurry.logEvent("Tapped_Back_From_Preview");
        }
	}
	
	override func viewDidLoad() {
        super.viewDidLoad()
		
		// set references
		SHUTTER_BTN = ShutterButtton
		SELECT_BTN = SelectBtn
		LIGHT_BTN = LightBtn
		WATERMARK = Watermark
		GREY_BG = GreyBG
		BACK_BTN = BackBtn
		SHARE_BTN = ShareBtn
        SELECT_VIEW = SelectCollectionView
        WEB_VIEW = webAnimationView
		
		// Hide Preview Buttons
		BackBtn.isHidden = true
		ShareBtn.isHidden = true
		Watermark.isHidden = true
        
        // Hide Selection Icons
        SELECT_VIEW?.isHidden = true
		
		// add overlay view
		overlayView = self.view
		
		// read in objct model definitions
		let url = Bundle.main.url(forResource: "moji", withExtension: "json")
		let data = NSData(contentsOf: url!)
        
        let htmlPath = Bundle.main.path(forResource: "WebViewAnimationContent", ofType: "html")
        let htmlURL = URL(fileURLWithPath: htmlPath!)
        let html = try? Data(contentsOf: htmlURL)
        
        self.webAnimationView.load(html!, mimeType: "text/html", textEncodingName: "UTF-8", baseURL: htmlURL.deletingLastPathComponent())
		
		do {
			//parse the JSON definitions
			let jsonObj = try JSONSerialization.jsonObject(with: data! as Data, options: .allowFragments)
			if let jsonDict = jsonObj as? [String: AnyObject] {
				if let modelJSONDefs = jsonDict["models"] as? [[String: AnyObject]]{
					// loop through definitions and add to dict
					for mDef in modelJSONDefs {
						guard let name : String = mDef["name"] as! String? else { return }
//                        guard let select_icon : String = mDef["icon"] as! String? else { return }
						modelDefs[name] = ModelObject.init(jsonModel: mDef)
//                        MOJI_LIST?.append(name)
//                        SELECT_ICON_LIST?.append(select_icon)
//						print("model: \(name) added to modelDefs")
					}
				}
			}
		} catch {
			// Handle Error
			print("failed to load models")
		}
	}
	
	override func viewDidAppear(_ animated: Bool) {
		currentModel = 0
        if isFirstLoad {
			webAnimationView.alpha = 1.0
			GreyBG.alpha = 1.0
            UIView.animate(withDuration: 0.5, delay:1.2, animations: { () -> Void in
                self.launchHolder.alpha = 0
            })
			UIView.animate(withDuration: 0.75, delay:5.0, animations: { () -> Void in
				self.webAnimationView.alpha = 0
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
