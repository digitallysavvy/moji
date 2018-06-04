//
//  ModelObject.swift
//  moji
//
//  Created by Hermes Frangoudis on 1/21/17.
//  Copyright © 2017 Digitally Savvy. All rights reserved.
//

import Foundation
import KudanAR

class ModelObject {
	
	var name : String?
	var armodel : String?
	var diffuseTexure : String?
	var normalTexture : String?
	var specularTexture : String?
	var scale : Float = 0
	var rotation : Float = 0
	var ambient : ARVector3?
	var specular : ARVector3?
	var shininess : Float = 0
	var reflectivity : Float = 0
	var reflectionMap : String?
	var animated : Bool? = false
    var selectIcon : String?
	
	init(jsonModel: [String:AnyObject]) {
		if let name = jsonModel["name"] as! String?{
			let armodel = jsonModel["armodel"] as! String?
			let diffuseTexure = jsonModel["diffuse-texure"] as! String?
			let normalTexture = jsonModel["normal-texture"] as! String?
			let specularTexture = jsonModel["specular-texure"] as! String?
			let scale = (jsonModel["scale"] as! NSNumber).floatValue
			let rotation = (jsonModel["rotation"] as! NSNumber).floatValue
			let shininess = (jsonModel["shininess"] as! NSNumber).floatValue
            let reflectivity = (jsonModel["reflectivity"] as! NSNumber).floatValue
			let reflectionMap = jsonModel["reflection-map"] as! String?
			let animated = jsonModel["animated"] as! String?
            let selectIcon = jsonModel["icon"] as! String?
			
			self.name = name
			self.armodel = armodel
			self.diffuseTexure = diffuseTexure
			self.normalTexture = normalTexture
			self.specularTexture = specularTexture
            self.scale = scale
            self.rotation = rotation
            self.shininess = shininess
            self.reflectivity = reflectivity
			self.reflectionMap = reflectionMap
            self.selectIcon = selectIcon
			
			if animated == "true" {
				self.animated = true
			}
			if let ambientVector = jsonModel["ambient"] as! [String : AnyObject]? {
				guard let ambient = ARVector3(valuesX: (ambientVector["x"]?.floatValue)!, y: (ambientVector["y"]?.floatValue)!, z: (ambientVector["z"]?.floatValue)!) else {
					return
				}
				self.ambient = ambient
			}
			if let specularVector = jsonModel["specular"] as! [String : NSNumber]? {
                guard let specular = ARVector3(valuesX: (specularVector["x"]?.floatValue)!, y: (specularVector["y"]?.floatValue)!, z: (specularVector["z"]?.floatValue)!) else {
					return
				}
				self.specular = specular
			}
		}
		else {
			print("unable to read json")
			return
		}
	}
}
