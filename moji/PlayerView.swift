//
//  MojiSelectionCell.swift
//  moji
//
//  Created by Macbook on 2/25/17.
//  Copyright © 2017 Digitally Savvy. All rights reserved.
//

class PlayerView: UIView {
   
    var player: AVPlayer? {
        get {
            return playerLayer.player
        }
        set {
            playerLayer.player = newValue
        }
    }
    
    var playerLayer: AVPlayerLayer {
        return layer as! AVPlayerLayer
    }
    
    // Override UIView property
    override static var layerClass: AnyClass {
        return AVPlayerLayer.self
    }
}
