//
//  GameViewController.swift
//  MetalShaderSceneKit
//
//  Created by M.Ike on 2016/07/04.
//  Copyright (c) 2016年 M.Ike. All rights reserved.
//

import UIKit
import QuartzCore
import SceneKit

class GameViewController: UIViewController {
    
    struct CustomBuffer {
        var color: float4
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // create a new scene
        let scene = SCNScene(named: "art.scnassets/ship.scn")!
        
        // create and add a camera to the scene
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        scene.rootNode.addChildNode(cameraNode)
        
        // place the camera
        cameraNode.position = SCNVector3(x: 0, y: 0, z: 15)
        
        // retrieve the ship node
        let ship = scene.rootNode.childNodeWithName("ship", recursively: true)!
        
        // animate the 3d object
        ship.runAction(SCNAction.repeatActionForever(SCNAction.rotateByX(0, y: 2, z: 0, duration: 1)))
        
        // retrieve the SCNView
        let scnView = self.view as! SCNView
        
        // set the scene to the view
        scnView.scene = scene
        
        // allows the user to manipulate the camera
        scnView.allowsCameraControl = true
        
        // show statistics such as fps and timing information
        scnView.showsStatistics = true
        
        // configure the view
        scnView.backgroundColor = UIColor.blackColor()
        
        // add a tap gesture recognizer
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        scnView.addGestureRecognizer(tapGesture)

        // 対象のマテリアルを取得
        guard let material = ship.childNodes.first?.geometry?.firstMaterial else { return }
        
        // Metalのシェーダを設定
        let program = SCNProgram()
        program.vertexFunctionName = "textureVertex"
        program.fragmentFunctionName = "textureFragment"
        material.program = program
        
        // マテリアルに設定されているテクスチャをシェーダ用に設定
        guard let contents = material.diffuse.contents else { return }
        material.setValue(SCNMaterialProperty(contents: contents), forKey: "texture")
        var custom = CustomBuffer(color: float4(0, 0, 0, 1))
        material.setValue(NSData(bytes: &custom, length:sizeof(CustomBuffer)), forKey: "custom")
    }
    
    func handleTap(gestureRecognize: UIGestureRecognizer) {
        // retrieve the SCNView
        let scnView = self.view as! SCNView
 
        // タップしたら色を変える
        let ship = scnView.scene!.rootNode.childNodeWithName("ship", recursively: true)!
        guard let material = ship.childNodes.first?.geometry?.firstMaterial else { return }

        var custom = CustomBuffer(color: float4(1, 0, 0, 1))
        material.setValue(NSData(bytes: &custom, length:sizeof(CustomBuffer)), forKey: "custom")
        
        // check what nodes are tapped
        let p = gestureRecognize.locationInView(scnView)
        let hitResults = scnView.hitTest(p, options: nil)
        // check that we clicked on at least one object
        if hitResults.count > 0 {
            // retrieved the first clicked object
            let result: AnyObject! = hitResults[0]
            
            // get its material
            let material = result.node!.geometry!.firstMaterial!
            
            // highlight it
            SCNTransaction.begin()
            SCNTransaction.setAnimationDuration(0.5)
            
            // on completion - unhighlight
            SCNTransaction.setCompletionBlock {
                SCNTransaction.begin()
                SCNTransaction.setAnimationDuration(0.5)
                
                material.emission.contents = UIColor.blackColor()
                
                SCNTransaction.commit()
            }
            
            material.emission.contents = UIColor.redColor()
            
            SCNTransaction.commit()
        }
    }
    
    override func shouldAutorotate() -> Bool {
        return true
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            return .AllButUpsideDown
        } else {
            return .All
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

}
